#!/usr/bin/env python3
"""
TypeScript types generator (platform-general).

Reads one package of a tenant model and writes ``types.ts``: a TypeScript
``enum`` for each ``enum def`` and an ``interface`` for each ``part def``
(attributes, ``ref`` features and ``part`` compositions; ``:>``
specialisation becomes ``extends``). Enums come first, then interfaces,
each in source order. A feature with multiplicity ``[0..1]`` is optional
(``name?: T``).

A type or specialisation written as a qualified name (``Pkg::Sub::Def``)
is a platform def. With ``--platform-model``, each one the package uses is
looked up there and emitted after the package's own declarations, sorted by
qualified name, with the platform defs it uses in turn. A platform def keeps
its own name, unless the package declares the same name: it is then
prefixed with its owning package's name (S518). A plain name that is not
the package's own and that a wildcard import (``import Pkg::Sub::*;``)
brings in from the platform model is resolved the same way (S0.4).

Status axes (S0.4). For each part def of the package that declares status
axes (see generation.status_axes), each axis gets its value type
(``<Type><Axis>Value``, with the values in declared order as
``<type><Axis>Values``), the type gets its axis tuple
(``<Type>AxisTuple``: one field per axis, named by ``axisName``), and its
interface carries the tuple as ``axes``.

Reading (S0.5 Pass A4): the model is read through OpenSysML's resolved model
(generation.resolved), loaded with the platform model folder, so every type
name is the definition OpenSysML resolves it to, imports included. A type
declared in the package, or a scalar (``ScalarValues``), is written by its
plain name; a type declared in the platform model folder is a platform def,
keyed by its full qualified name; any other type keeps its plain name. A
feature is read when it is a plain declaration (``attribute``, ``ref`` or
``part`` with a name, a ``:`` type and an optional multiplicity): one with a
body, a value, a redefinition or a subsetting is not a field, as before.

Usage (from the repository root):
    python3 -m generation.ts_types --model <tenant model folder> --out <folder> \\
        --package <package name> [--filename types.ts] [--model-name <name>] \\
        [--platform-model <platform model folder>]

Generalised at S0.2 from the Cafe's own generator. Two parsing defects that
had been patched by hand in the committed output are fixed here: an enum
whose first member follows a doc block lost that member, and a ``part``
feature written with a space before its multiplicity (``T [0..*]``) was
dropped.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

if __package__ in (None, ""):
    sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from generation.output import base_parser, header, write
from generation import resolved
from generation.status_axes import AxisType
from generation.sysml_text import ModelError, rel_path

TYPE_MAP = {
    "String": "string",
    "Boolean": "boolean",
    "Integer": "number",
    "Real": "number",
    "Natural": "number",
}


SCALARS = "ScalarValues"


class Reader:
    """The package's and the platform's definitions, read from the resolved model."""

    def __init__(self, rm: resolved.ResolvedModel, package_qualified: str, platform_documents: set[str]):
        self.rm = rm
        self.graph = rm.elements()
        self.package = package_qualified
        self.platform_documents = platform_documents

    def in_package(self, e: dict) -> bool:
        return (e.get("qualifiedName") or "").startswith(self.package + "::")

    def type_name(self, d: dict | None, local_plain: bool, qualified: str = "") -> str:
        """How a feature's type is written: plain for the package's own and scalars, qualified for platform defs.

        ``d`` is the type's element, or None when the element graph does not
        hold it (the standard library, built into sysml-grpc); then
        ``qualified`` is its resolved name from the symbol API.
        """
        if d is None:
            return qualified.split("::")[-1] if qualified else ""
        q = d.get("qualifiedName") or ""
        if q.startswith(SCALARS + "::") or (local_plain and self.in_package(d)):
            return d.get("declaredName") or q
        if self.graph.document(d) in self.platform_documents:
            return q
        return d.get("declaredName") or q

    def feature_type(self, f: dict, local_plain: bool) -> str:
        types = self.graph.get(f, "type")
        if types:
            return self.type_name(types[0], local_plain)
        sym = self.rm.sym(f["qualifiedName"])
        tf = sym.type_facts if sym is not None else None
        return self.type_name(None, local_plain, (tf.resolved_id or tf.declared or "") if tf else "")

    def multiplicity(self, e: dict) -> str | None:
        sym = self.rm.sym(e["qualifiedName"])
        return (sym.metadata or {}).get("multiplicity") if sym is not None else None

    def enum_members(self, e: dict) -> list[str]:
        return [m["declaredName"] for m in self.graph.member_list(e) if m["@type"] == "EnumerationUsage" and m.get("declaredName")]

    def _plain(self, f: dict) -> bool:
        """A plain feature declaration: name, ``:`` type, optional multiplicity, nothing else."""
        if not f.get("declaredName") or not f.get("ownedTyping") or f.get("sysx:hasBody"):
            return False
        if f.get("ownedRedefinition") or f.get("ownedSubsetting") or f.get("ownedReferenceSubsetting"):
            return False
        membership = self.graph.by_id.get((f.get("owningMembership") or {}).get("@id"), {})
        if membership.get("@type") != "FeatureMembership":
            return False
        return not any(r.get("@type") == "FeatureValue" for r in self.graph.get(f, "ownedRelationship"))

    def part(self, e: dict, local_plain: bool) -> dict:
        attributes, refs, compositions = [], [], []
        for f in self.graph.member_list(e):
            if not self._plain(f):
                continue
            entry = {
                "name": f["declaredName"],
                "type": self.feature_type(f, local_plain),
                "mult": self.multiplicity(f),
            }
            if f["@type"] == "AttributeUsage":
                attributes.append(entry)
            elif f["@type"] == "ReferenceUsage" or (f["@type"] == "PartUsage" and f.get("isReference")):
                refs.append(entry)
            elif f["@type"] == "PartUsage":
                compositions.append(entry)
        sup = self.graph.get(e, "specializes")
        parent = self.type_name(sup[0], local_plain) if sup else None
        return {"name": e["declaredName"], "parent": parent, "attributes": attributes, "refs": refs, "compositions": compositions}

    def package_defs(self) -> tuple[dict[str, list[str]], list[dict]]:
        """Enum defs and part defs inside the package, in source order."""
        enums: dict[str, list[str]] = {}
        parts: list[dict] = []
        for _, e in self.graph.tenant_elements():
            if not self.in_package(e) or not e.get("declaredName") or not e.get("sysx:hasBody"):
                continue
            if e["@type"] == "EnumerationDefinition":
                enums[e["declaredName"]] = self.enum_members(e)
            elif e["@type"] == "PartDefinition":
                parts.append(self.part(e, local_plain=True))
        return enums, parts

    def platform_def(self, qualified: str) -> dict | None:
        hits = [
            e for e in self.graph.data
            if e.get("qualifiedName") == qualified
            and e["@type"] in ("PartDefinition", "EnumerationDefinition")
            and self.graph.document(e) in self.platform_documents
        ]
        return hits[0] if len(hits) == 1 else None


def is_many(mult: str | None) -> bool:
    if not mult:
        return False
    mult = mult.strip()
    if mult == "*" or mult.endswith("*"):
        return True
    m = re.fullmatch(r"(\d+)\s*\.\.\s*(\d+)", mult)
    return bool(m) and int(m.group(2)) > 1


def is_optional(mult: str | None) -> bool:
    return bool(mult) and re.fullmatch(r"0\s*\.\.\s*1", mult.strip()) is not None


def ts_type(sysml_type: str, names: dict[str, str]) -> str:
    if sysml_type in TYPE_MAP:
        return TYPE_MAP[sysml_type]
    return names.get(sysml_type, sysml_type)


def resolve_platform(enums: dict[str, list[str]], parts: list[dict], reader: Reader) -> tuple[list[dict], list[str]]:
    """The platform defs the package uses, transitively, sorted by qualified name.

    Each is ``{"qualified", "kind", "name", ...}``: an enum carries
    ``members``, a part def the fields of ``Reader.part``. Also returns the
    header sources of the platform files used.
    """
    local = set(enums) | {p["name"] for p in parts}
    wanted = sorted({t for p in parts for t in _types_of(p) if "::" in t})
    found_defs: dict[str, dict] = {}
    while wanted:
        qualified = wanted.pop(0)
        if qualified in found_defs:
            continue
        e = reader.platform_def(qualified)
        if e is None:
            raise ModelError(f"platform def {qualified!r} is not found in the platform model folder")
        name = e["declaredName"]
        owner = qualified.split("::")[-2] if "::" in qualified else ""
        if e["@type"] == "EnumerationDefinition":
            entry = {"kind": "enum", "members": reader.enum_members(e)}
        else:
            entry = {"kind": "part", **reader.part(e, local_plain=False)}
            for t in sorted(_types_of(entry)):
                if "::" in t and t not in found_defs:
                    wanted.append(t)
        doc = reader.graph.document(e)
        entry.update(qualified=qualified, owner=owner, source=f"{doc} ({qualified})")
        entry["ts_name"] = name if name not in local else f"{owner}{name}"
        found_defs[qualified] = entry
    defs = [found_defs[q] for q in sorted(found_defs)]
    taken = [d["ts_name"] for d in defs] + sorted(local)
    clash = sorted({n for n in taken if taken.count(n) > 1})
    if clash:
        raise ModelError("platform defs give clashing TypeScript names: " + ", ".join(clash))
    return defs, sorted({d["source"].split(" (")[0] for d in defs})


def _types_of(part: dict) -> list[str]:
    types = [f["type"] for group in ("attributes", "refs", "compositions") for f in part[group]]
    return types + ([part["parent"]] if part["parent"] else [])


def _key(name: str) -> str:
    return name if re.fullmatch(r"[A-Za-z_$][\w$]*", name) else '"' + name + '"'


def render(
    enums: dict[str, list[str]],
    parts: list[dict],
    head: str,
    platform: list[dict] | None = None,
    axes: list[AxisType] | None = None,
) -> str:
    platform = platform or []
    axes = axes or []
    axis_by_type = {t.name: t for t in axes}
    names = {d["qualified"]: d["ts_name"] for d in platform}
    lines = [head.rstrip("\n"), ""]

    def enum(name: str, members: list[str]) -> None:
        lines.append(f"export enum {name} {{")
        for v in members:
            lines.append(f'  {v} = "{v}",')
        lines.append("}")
        lines.append("")

    def interface(name: str, part: dict) -> None:
        extends = f" extends {ts_type(part['parent'], names)}" if part["parent"] else ""
        lines.append(f"export interface {name}{extends} {{")
        for group in ("attributes", "refs", "compositions"):
            for f in part[group]:
                suffix = "[]" if is_many(f["mult"]) else ""
                optional = "?" if is_optional(f["mult"]) else ""
                lines.append(f"  {f['name']}{optional}: {ts_type(f['type'], names)}{suffix};")
        if name in axis_by_type:
            lines.append(f"  /** The status axis tuple: one value per declared axis. */")
            lines.append(f"  axes: {name}AxisTuple;")
        lines.append("}")
        lines.append("")

    for name, members in enums.items():
        enum(name, members)
    if axes:
        lines.append("// Status axes: each axis's value type, and each type's axis tuple")
        lines.append("")
    for t in axes:
        for ax in t.axes:
            vals = ", ".join('"' + v + '"' for v in ax.values)
            lines.append(f"/** {t.name} {ax.name}: values in declared order; default {ax.default}. */")
            lines.append(f"export const {ax.lower_ident}Values = [{vals}] as const;")
            lines.append(f"export type {ax.ident}Value = (typeof {ax.lower_ident}Values)[number];")
            lines.append("")
        lines.append(f"/** The axis tuple of {t.name}. */")
        lines.append(f"export interface {t.name}AxisTuple {{")
        for ax in t.axes:
            lines.append(f"  {_key(ax.name)}: {ax.ident}Value;")
        lines.append("}")
        lines.append("")
    for part in parts:
        interface(part["name"], part)
    if platform:
        lines.append("// Platform defs used by this package (from the platform model)")
        lines.append("")
        for d in platform:
            lines.append(f"/** {d['qualified']} */")
            if d["kind"] == "enum":
                enum(d["ts_name"], d["members"])
            else:
                interface(d["ts_name"], d)
    return "\n".join(lines)


def generate(
    model: Path,
    out: Path,
    root: Path,
    package: str,
    filename: str,
    model_name: str | None,
    platform_model: Path | None = None,
) -> Path:
    also = (platform_model,) if platform_model is not None else ()
    rm = resolved.load(model, root, also=also)
    graph = rm.elements()
    pkg = graph.find_one("Package", package, "package")
    platform_documents = set()
    if platform_model is not None:
        for f in sorted(platform_model.resolve().rglob("*.sysml")):
            platform_documents |= {rel_path(f, root), rel_path(f, resolved.REPO)}
    reader = Reader(rm, pkg["qualifiedName"], platform_documents)
    enums, parts = reader.package_defs()
    if not enums and not parts:
        raise ModelError(f"package {package!r} has no enum def or part def")
    platform, platform_sources = [], []
    outside = sorted({
        t for p in parts for t in _types_of(p) if t and t not in TYPE_MAP and t not in enums and t not in {x["name"] for x in parts}
    })
    if platform_model is None and outside:
        raise ModelError(f"package {package!r} uses qualified platform defs: pass --platform-model")
    if any("::" in t for p in parts for t in _types_of(p)):
        platform, platform_sources = resolve_platform(enums, parts, reader)
    axes = [t for t in rm.axis_types() if t.qualified.startswith(pkg["qualifiedName"] + "::")]
    for t in axes:
        part = next((p for p in parts if p["name"] == t.name), None)
        if part and any(f["name"] == "axes" for g in ("attributes", "refs", "compositions") for f in part[g]):
            raise ModelError(f"part def {t.name!r} has a feature named 'axes', which the axis tuple needs")
    head = header(__file__, [graph.source(pkg)] + platform_sources, model_name)
    path = write(out, filename, render(enums, parts, head, platform, axes))
    print(
        f"wrote {path} ({len(enums)} enums, {len(parts)} interfaces, {len(platform)} platform defs, "
        f"{sum(len(t.axes) for t in axes)} axes)"
    )
    return path


def main(argv: list[str] | None = None) -> int:
    p = base_parser("Generate TypeScript enums and interfaces from one model package.")
    p.add_argument("--package", required=True, help="package whose enum defs and part defs are generated")
    p.add_argument("--filename", default="types.ts", help="output file name (default: types.ts)")
    p.add_argument("--platform-model", type=Path, default=None, help="platform model folder, for qualified defs")
    a = p.parse_args(argv)
    try:
        generate(a.model, a.out, a.root, a.package, a.filename, a.model_name, a.platform_model)
    except ModelError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
