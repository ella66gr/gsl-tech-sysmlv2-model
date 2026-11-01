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
from generation.status_axes import AxisType, axis_types
from generation.sysml_text import (
    ModelError,
    braced_body,
    find_all,
    find_one,
    load_model,
    remove_doc_blocks,
    mask_comments,
)

TYPE_MAP = {
    "String": "string",
    "Boolean": "boolean",
    "Integer": "number",
    "Real": "number",
    "Natural": "number",
}


NAME = r"\w+(?:::\w+)*"  # a plain or qualified name
FEATURE = rf"(\w+)\s*:\s*({NAME})(?:\s*\[([^\]]+)\])?"


def parse_package(body: str) -> tuple[dict[str, list[str]], list[dict]]:
    """Enum defs and part defs of a package body, in source order."""
    text = mask_comments(body)
    enums: dict[str, list[str]] = {}
    parts: list[dict] = []
    for m in re.finditer(rf"\b(enum\s+def|part\s+def)\s+(\w+)(?:\s*:>\s*({NAME}))?\s*\{{", text):
        kind, name, parent = m.group(1), m.group(2), m.group(3)
        inner, _ = braced_body(text, m.end() - 1)
        if kind.startswith("enum"):
            enums[name] = _enum_members(inner)
        else:
            parts.append(_parse_part(name, parent, remove_doc_blocks(inner)))
    return enums, parts


def _enum_members(inner: str) -> list[str]:
    members = []
    for item in remove_doc_blocks(inner).split(";"):
        item = item.strip()
        if not item:
            continue
        item = re.sub(r"^enum\s+", "", item)
        if re.fullmatch(r"\w+", item):
            members.append(item)
    return members


def _parse_part(name: str, parent: str | None, inner: str) -> dict:
    attributes, refs, compositions = [], [], []
    for stmt in inner.split(";"):
        stmt = " ".join(stmt.split())
        if not stmt:
            continue
        m = re.fullmatch(rf"attribute\s+{FEATURE}", stmt)
        if m:
            attributes.append({"name": m.group(1), "type": m.group(2), "mult": m.group(3)})
            continue
        m = re.fullmatch(rf"ref\s+(?:part\s+)?{FEATURE}", stmt)
        if m:
            refs.append({"name": m.group(1), "type": m.group(2), "mult": m.group(3)})
            continue
        m = re.fullmatch(rf"part\s+{FEATURE}", stmt)
        if m:
            compositions.append({"name": m.group(1), "type": m.group(2), "mult": m.group(3)})
            continue
    return {"name": name, "parent": parent, "attributes": attributes, "refs": refs, "compositions": compositions}


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


def resolve_platform(enums: dict[str, list[str]], parts: list[dict], platform_files: list) -> tuple[list[dict], list[str]]:
    """The platform defs the package uses, transitively, sorted by qualified name.

    Each is ``{"qualified", "kind", "name", ...}``: an enum carries
    ``members``, a part def the fields of ``_parse_part``. Also returns the
    header sources of the platform files used.
    """
    local = set(enums) | {p["name"] for p in parts}
    wanted = sorted({t for p in parts for t in _types_of(p) if "::" in t})
    resolved: dict[str, dict] = {}
    while wanted:
        qualified = wanted.pop(0)
        if qualified in resolved:
            continue
        found = [
            f for kw in (r"part\s+def", r"enum\s+def")
            for f in find_all(platform_files, kw, qualified.split("::")[-1])
            if f.qualified == qualified or f.qualified.endswith("::" + qualified)
        ]
        if len(found) != 1:
            how = "not found" if not found else "declared more than once"
            raise ModelError(f"platform def {qualified!r} is {how} in the platform model folder")
        f = found[0]
        owner = f.qualified.split("::")[-2] if "::" in f.qualified else ""
        header = mask_comments(f.file.text)[f.start : f.start + 200]
        if header.lstrip().startswith("enum"):
            entry = {"kind": "enum", "members": _enum_members(f.body)}
        else:
            m = re.match(rf"part\s+def\s+\w+(?:\s*:>\s*({NAME}))?", header)
            entry = {"kind": "part", **_parse_part(f.name, m.group(1) if m else None, remove_doc_blocks(mask_comments(f.body)))}
            # A plain non-scalar name inside a platform def is a sibling in its package.
            prefix = f.qualified.rsplit("::", 1)[0]
            for t in sorted(_types_of(entry)):
                q = t if "::" in t else f"{prefix}::{t}"
                if t not in TYPE_MAP and q not in resolved:
                    wanted.append(q)
            entry = _qualify_siblings(entry, prefix)
        entry.update(qualified=qualified, owner=owner, source=f"{f.file.rel} ({f.qualified})")
        entry["ts_name"] = f.name if f.name not in local else f"{owner}{f.name}"
        resolved[qualified] = entry
    defs = [resolved[q] for q in sorted(resolved)]
    taken = [d["ts_name"] for d in defs] + sorted(local)
    clash = sorted({n for n in taken if taken.count(n) > 1})
    if clash:
        raise ModelError("platform defs give clashing TypeScript names: " + ", ".join(clash))
    return defs, sorted({d["source"].split(" (")[0] for d in defs})


def _types_of(part: dict) -> list[str]:
    types = [f["type"] for group in ("attributes", "refs", "compositions") for f in part[group]]
    return types + ([part["parent"]] if part["parent"] else [])


def _qualify_siblings(part: dict, prefix: str) -> dict:
    def q(t: str) -> str:
        return t if "::" in t or t in TYPE_MAP else f"{prefix}::{t}"

    out = dict(part)
    for group in ("attributes", "refs", "compositions"):
        out[group] = [dict(f, type=q(f["type"])) for f in part[group]]
    out["parent"] = q(part["parent"]) if part["parent"] else None
    return out


def _key(name: str) -> str:
    return name if re.fullmatch(r"[A-Za-z_$][\w$]*", name) else '"' + name + '"'


def _qualify_imported(pkg_body: str, enums: dict, parts: list[dict], platform_files: list) -> list[dict]:
    """Rewrite plain names brought in by a wildcard import of a platform package to qualified names."""
    imports = re.findall(r"\bimport\s+(\w+(?:::\w+)*)::\*\s*;", mask_comments(pkg_body))
    local = set(enums) | {p["name"] for p in parts}
    cache: dict[str, str | None] = {}

    def resolve(t: str) -> str:
        if "::" in t or t in TYPE_MAP or t in local:
            return t
        if t not in cache:
            hits = sorted({
                f.qualified
                for kw in (r"part\s+def", r"enum\s+def")
                for f in find_all(platform_files, kw, t)
                for imp in imports
                if f.qualified == f"{imp}::{t}"
            })
            if len(hits) > 1:
                raise ModelError(f"{t!r} is imported from more than one platform package: {', '.join(hits)}")
            cache[t] = hits[0] if hits else None
        return cache[t] or t

    out = []
    for p in parts:
        q = dict(p)
        for g in ("attributes", "refs", "compositions"):
            q[g] = [dict(f, type=resolve(f["type"])) for f in p[g]]
        q["parent"] = resolve(p["parent"]) if p["parent"] else None
        out.append(q)
    return out


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
    files = load_model(model, root)
    pkg = find_one(files, r"package", package, "package")
    enums, parts = parse_package(pkg.body)
    if not enums and not parts:
        raise ModelError(f"package {package!r} has no enum def or part def")
    platform_files = load_model(platform_model, root) if platform_model is not None else []
    if platform_files:
        parts = _qualify_imported(pkg.body, enums, parts, platform_files)
    platform, platform_sources = [], []
    if any("::" in t for p in parts for t in _types_of(p)):
        if platform_model is None:
            raise ModelError(f"package {package!r} uses qualified platform defs: pass --platform-model")
        platform, platform_sources = resolve_platform(enums, parts, platform_files)
    axes = [t for t in axis_types(files) if t.found.qualified.startswith(pkg.qualified + "::")]
    for t in axes:
        part = next((p for p in parts if p["name"] == t.name), None)
        if part and any(f["name"] == "axes" for g in ("attributes", "refs", "compositions") for f in part[g]):
            raise ModelError(f"part def {t.name!r} has a feature named 'axes', which the axis tuple needs")
    head = header(__file__, [pkg.source] + platform_sources, model_name)
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
