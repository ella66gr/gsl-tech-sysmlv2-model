#!/usr/bin/env python3
"""
TypeScript types generator (platform-general).

Reads one package of a tenant model and writes ``types.ts``: a TypeScript
``enum`` for each ``enum def`` and an ``interface`` for each ``part def``
(attributes, ``ref`` features and ``part`` compositions; ``:>``
specialisation becomes ``extends``). Enums come first, then interfaces,
each in source order.

Usage (from the repository root):
    python3 -m generation.ts_types --model <tenant model folder> --out <folder> \\
        --package <package name> [--filename types.ts] [--model-name <name>]

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
from generation.sysml_text import (
    ModelError,
    braced_body,
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


def parse_package(body: str) -> tuple[dict[str, list[str]], list[dict]]:
    """Enum defs and part defs of a package body, in source order."""
    text = mask_comments(body)
    enums: dict[str, list[str]] = {}
    parts: list[dict] = []
    for m in re.finditer(r"\b(enum\s+def|part\s+def)\s+(\w+)(?:\s*:>\s*(\w+))?\s*\{", text):
        kind, name, parent = m.group(1), m.group(2), m.group(3)
        inner, _ = braced_body(text, m.end() - 1)
        inner = remove_doc_blocks(inner)
        if kind.startswith("enum"):
            members = []
            for item in inner.split(";"):
                item = item.strip()
                if not item:
                    continue
                item = re.sub(r"^enum\s+", "", item)
                if re.fullmatch(r"\w+", item):
                    members.append(item)
            enums[name] = members
        else:
            parts.append(_parse_part(name, parent, inner))
    return enums, parts


def _parse_part(name: str, parent: str | None, inner: str) -> dict:
    attributes, refs, compositions = [], [], []
    for stmt in inner.split(";"):
        stmt = " ".join(stmt.split())
        if not stmt:
            continue
        m = re.fullmatch(r"attribute\s+(\w+)\s*:\s*(\w+)(?:\s*\[([^\]]+)\])?", stmt)
        if m:
            attributes.append({"name": m.group(1), "type": m.group(2), "mult": m.group(3)})
            continue
        m = re.fullmatch(r"ref\s+(?:part\s+)?(\w+)\s*:\s*(\w+)(?:\s*\[([^\]]+)\])?", stmt)
        if m:
            refs.append({"name": m.group(1), "type": m.group(2), "mult": m.group(3)})
            continue
        m = re.fullmatch(r"part\s+(\w+)\s*:\s*(\w+)(?:\s*\[([^\]]+)\])?", stmt)
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


def ts_type(sysml_type: str) -> str:
    return TYPE_MAP.get(sysml_type, sysml_type)


def render(enums: dict[str, list[str]], parts: list[dict], head: str) -> str:
    lines = [head.rstrip("\n"), ""]
    for name, members in enums.items():
        lines.append(f"export enum {name} {{")
        for v in members:
            lines.append(f'  {v} = "{v}",')
        lines.append("}")
        lines.append("")
    for part in parts:
        extends = f" extends {part['parent']}" if part["parent"] else ""
        lines.append(f"export interface {part['name']}{extends} {{")
        for group in ("attributes", "refs", "compositions"):
            for f in part[group]:
                suffix = "[]" if is_many(f["mult"]) else ""
                lines.append(f"  {f['name']}: {ts_type(f['type'])}{suffix};")
        lines.append("}")
        lines.append("")
    return "\n".join(lines)


def generate(model: Path, out: Path, root: Path, package: str, filename: str, model_name: str | None) -> Path:
    files = load_model(model, root)
    pkg = find_one(files, r"package", package, "package")
    enums, parts = parse_package(pkg.body)
    if not enums and not parts:
        raise ModelError(f"package {package!r} has no enum def or part def")
    head = header(__file__, [pkg.source], model_name)
    path = write(out, filename, render(enums, parts, head))
    print(f"wrote {path} ({len(enums)} enums, {len(parts)} interfaces)")
    return path


def main(argv: list[str] | None = None) -> int:
    p = base_parser("Generate TypeScript enums and interfaces from one model package.")
    p.add_argument("--package", required=True, help="package whose enum defs and part defs are generated")
    p.add_argument("--filename", default="types.ts", help="output file name (default: types.ts)")
    a = p.parse_args(argv)
    try:
        generate(a.model, a.out, a.root, a.package, a.filename, a.model_name)
    except ModelError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
