#!/usr/bin/env python3
"""
General element list generator (platform-general).

Lists, from a tenant's model, each General metamodel element the tenant
instantiates, with the instance names (S518, S0.3, decision 4: at Stage 0
selection is implied by instantiation, so the selected elements are
generated from the model, never hand-listed).

A General element is a definition (``part def``, ``action def`` and so on)
inside one of the packages named by ``--general-package``, read from the
platform model folder. The tenant instantiates it by:

- a usage typed by it (``part x : Element``, ``ref x : Element``, ...),
  written anywhere in the tenant model, at any depth;
- a tenant definition that specialises it (``part def X :> Element``);
- a usage typed by such a tenant definition, listed with the definition it
  goes through.

Attribute features are not instantiations and are left out. A plain type
name is resolved as the model resolves it: a definition in an enclosing
package, or one brought in by a wildcard or named import of the file. A
name that resolves two ways is an error (``make parse-check`` already
refuses the duplicate-import warning that would cause it).

The output is a plain text file, sorted throughout, so the same model always
gives the same bytes:

    Pkg::Sub::Element
      def Tenant::Specialisation
      part Tenant::Pkg::usageName
      part Tenant::Pkg::otherUsage (via Tenant::Specialisation)

Usage (from the repository root):
    python3 -m generation.element_list --model <tenant model folder> --out <folder> \\
        --platform-model <platform model folder> --general-package <name> [--general-package ...] \\
        [--filename general-elements.txt] [--model-name <name>]
"""

from __future__ import annotations

import re
import sys
from dataclasses import dataclass, field
from pathlib import Path

if __package__ in (None, ""):
    sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from generation.output import base_parser, header, write
from generation.sysml_text import ModelError, ModelFile, braced_body, load_model, mask_comments, rel_path

NAME = r"\w+(?:::\w+)*"
DEF_RE = re.compile(rf"\b((?:\w+\s+)?\w+)\s+def\s+(\w+)(?:\s*:>\s*({NAME}))?[^;{{}}]*[{{;]")
USAGE_KINDS = r"part|item|occurrence|action|state|requirement|ref(?:\s+part|\s+item)?|use\s+case"
USAGE_RE = re.compile(rf"(?<![\w:])({USAGE_KINDS})\s+(\w+)\s*:\s*({NAME})")
IMPORT_RE = re.compile(rf"\bimport\s+({NAME})(::\*)?\s*;")
SCOPE_RE = re.compile(r"\b(?:package\s+(\w+)\s*|(?:\w+\s+)?\w+\s+def\s+(\w+)[^;{}]*|(?:\w+\s+)+(\w+)\s*:[^;{}]*)\{")


@dataclass
class Def:
    qualified: str
    keyword: str
    parent: str | None  # the :> name as written
    file: ModelFile
    scope: list[str]  # enclosing scope names, outermost first
    resolved_parent: str | None = None


@dataclass
class FileScopes:
    file: ModelFile
    masked: str
    spans: list[tuple[int, int, str]] = field(default_factory=list)  # (open, close, name)
    imports: list[tuple[str, bool]] = field(default_factory=list)  # (name, is_wildcard)

    def scope_at(self, pos: int) -> list[str]:
        return [name for open_, close, name in self.spans if open_ < pos < close]


def read_scopes(f: ModelFile) -> FileScopes:
    masked = mask_comments(f.text)
    fs = FileScopes(file=f, masked=masked)
    for m in SCOPE_RE.finditer(masked):
        name = m.group(1) or m.group(2) or m.group(3)
        open_pos = m.end() - 1
        _, close = braced_body(masked, open_pos)
        fs.spans.append((open_pos, close, name))
    fs.imports = [(m.group(1), bool(m.group(2))) for m in IMPORT_RE.finditer(masked)]
    return fs


def read_defs(scopes: list[FileScopes]) -> dict[str, Def]:
    defs: dict[str, Def] = {}
    for fs in scopes:
        for m in DEF_RE.finditer(fs.masked):
            keyword = " ".join(m.group(1).split())
            if keyword.split()[-1] in ("metadata", "enum", "attribute", "calc", "constraint", "port", "interface"):
                continue
            scope = fs.scope_at(m.start())
            qualified = "::".join(scope + [m.group(2)])
            defs[qualified] = Def(qualified, keyword, m.group(3), fs.file, scope)
    return defs


class Resolver:
    """Resolves a type name, as written at a place in a file, to a definition."""

    def __init__(self, tenant: dict[str, Def], general: dict[str, Def]):
        self.tenant = tenant
        self.general = general
        self.by_name: dict[str, list[str]] = {}
        for q in list(tenant) + list(general):
            self.by_name.setdefault(q.rsplit("::", 1)[-1], []).append(q)

    def resolve(self, name: str, scope: list[str], imports: list[tuple[str, bool]]) -> str | None:
        simple = name.rsplit("::", 1)[-1]
        candidates = self.by_name.get(simple, [])
        if "::" in name:
            hits = [q for q in candidates if q == name or q.endswith("::" + name)]
        else:
            visible = set()
            for i in range(len(scope) + 1):
                visible.add("::".join(scope[:i]))
            hits = []
            for q in candidates:
                owner = q.rsplit("::", 1)[0] if "::" in q else ""
                if owner in visible:
                    hits.append(q)
                    continue
                for imp, wildcard in imports:
                    if (wildcard and (owner == imp or owner.endswith("::" + imp))) or (
                        not wildcard and (q == imp or q.endswith("::" + imp))
                    ):
                        hits.append(q)
                        break
        hits = sorted(set(hits))
        if len(hits) > 1:
            raise ModelError(f"type {name!r} resolves to more than one definition: {', '.join(hits)}")
        return hits[0] if hits else None


def general_root(q: str, tenant: dict[str, Def], general: dict[str, Def]) -> tuple[str | None, str | None]:
    """The General def that ``q`` is or specialises, and the tenant def it goes through."""
    seen = set()
    via = None
    while q and q not in seen:
        seen.add(q)
        if q in general:
            return q, via
        d = tenant.get(q)
        if d is None:
            return None, None
        if via is None:
            via = q
        q = d.resolved_parent
    return None, None


def collect(model_files: list[ModelFile], platform_files: list[ModelFile], packages: list[str]) -> dict[str, list[str]]:
    tenant_scopes = [read_scopes(f) for f in model_files]
    platform_scopes = [read_scopes(f) for f in platform_files]
    general = {q: d for q, d in read_defs(platform_scopes).items() if q.split("::", 1)[0] in packages}
    if not general:
        raise ModelError("no definitions found in the named General packages: " + ", ".join(packages))
    tenant = read_defs(tenant_scopes)
    resolver = Resolver(tenant, general)
    imports_of = {fs.file.rel: fs.imports for fs in tenant_scopes}

    for d in tenant.values():
        if d.parent:
            d.resolved_parent = resolver.resolve(d.parent, d.scope, imports_of[d.file.rel])

    listing: dict[str, set[str]] = {}
    for d in tenant.values():
        if d.resolved_parent:
            root, _ = general_root(d.resolved_parent, tenant, general)
            if root:
                listing.setdefault(root, set()).add(f"def {d.qualified}")
    for fs in tenant_scopes:
        for m in USAGE_RE.finditer(fs.masked):
            kind = " ".join(m.group(1).split())
            scope = fs.scope_at(m.start())
            target = resolver.resolve(m.group(3), scope, fs.imports)
            if target is None:
                continue
            root, via = general_root(target, tenant, general)
            if root is None:
                continue
            entry = f"{kind} {'::'.join(scope + [m.group(2)])}"
            listing.setdefault(root, set()).add(entry + (f" (via {via})" if via else ""))
    return {q: sorted(v) for q, v in sorted(listing.items())}


def render(listing: dict[str, list[str]], head: str) -> str:
    lines = [head.rstrip("\n"), ""]
    for q, entries in listing.items():
        lines.append(q)
        lines.extend(f"  {e}" for e in entries)
    return "\n".join(lines) + "\n"


def generate(
    model: Path,
    out: Path,
    root: Path,
    platform_model: Path,
    packages: list[str],
    filename: str,
    model_name: str | None,
) -> Path:
    model_files = load_model(model, root)
    if not model_files:
        raise ModelError(f"no .sysml files under {model}")
    listing = collect(model_files, load_model(platform_model, root), packages)
    sources = [rel_path(model, root) + "/", "General packages: " + ", ".join(packages)]
    path = write(out, filename, render(listing, header(__file__, sources, model_name, comment="#")))
    count = sum(len(v) for v in listing.values())
    print(f"wrote {path} ({len(listing)} General elements, {count} instances)")
    return path


def main(argv: list[str] | None = None) -> int:
    p = base_parser("List the General metamodel elements a tenant model instantiates.")
    p.add_argument("--platform-model", required=True, type=Path, help="platform model folder")
    p.add_argument(
        "--general-package", required=True, action="append", dest="packages",
        help="a top-level General package (repeat for each)",
    )
    p.add_argument("--filename", default="general-elements.txt", help="output file name (default: general-elements.txt)")
    a = p.parse_args(argv)
    try:
        generate(a.model, a.out, a.root, a.platform_model, a.packages, a.filename, a.model_name)
    except ModelError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
