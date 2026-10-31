#!/usr/bin/env python3
"""
Mermaid pathway generator (platform-general).

Reads one domain-level ``action def`` (named with ``--action-def``) and
writes ``<action-def>-pathway.mmd``: a Mermaid flowchart with one node per
step and one edge per ``then`` succession. A ``then`` attaches to the most
recently declared step, so several ``then``s after one step are a branch.
The first step and the terminal steps are drawn as rounded nodes; branch
points are highlighted.

Usage (from the repository root):
    python3 -m generation.mermaid_pathway --model <tenant model folder> --out <folder> \\
        --action-def <name> [--model-name <name>]

The output is plain Mermaid source (no Markdown code fence), as a .mmd file
expects.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

if __package__ in (None, ""):
    sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from generation.output import base_parser, header, write
from generation.sysml_text import ModelError, find_one, kebab, load_model, mask_comments, top_level_members


def parse_flow(body: str) -> dict[str, list[str]]:
    """Steps in declaration order, each with its successors."""
    flat = top_level_members(mask_comments(body))
    steps: dict[str, list[str]] = {}
    current: str | None = None
    for stmt in flat.split(";"):
        stmt = " ".join(stmt.split())
        if not stmt:
            continue
        m = re.fullmatch(r"action\s+(\w+)(?:\s*:\s*\w+)?", stmt)
        if m:
            current = m.group(1)
            steps.setdefault(current, [])
            continue
        m = re.fullmatch(r"then\s+(\w+)", stmt)
        if m and current:
            target = m.group(1)
            steps.setdefault(target, [])
            if target not in steps[current]:
                steps[current].append(target)
    return steps


def label(name: str) -> str:
    """``receiveOrder`` -> ``Receive Order``."""
    return re.sub(r"([A-Z])", r" \1", name).strip().title()


def render(steps: dict[str, list[str]], head: str) -> str:
    L = [head.rstrip("\n"), "", "flowchart TD"]
    names = list(steps)
    first = names[0]
    terminal = [n for n in names if not steps[n]]
    for n in names:
        if n == first or n in terminal:
            L.append(f"    {n}([{label(n)}])")
        else:
            L.append(f"    {n}[{label(n)}]")
    L.append("")
    for n in names:
        for succ in steps[n]:
            L.append(f"    {n} --> {succ}")
    L.append("")
    L.append(f"    style {first} fill:#4CAF50,color:#fff,stroke:#388E3C")
    for t in terminal:
        L.append(f"    style {t} fill:#2196F3,color:#fff,stroke:#1565C0")
    for n in names:
        if len(steps[n]) > 1:
            L.append(f"    style {n} fill:#FF9800,color:#fff,stroke:#E65100")
    L.append("")
    return "\n".join(L)


def generate(model: Path, out: Path, root: Path, action_def: str, model_name: str | None) -> Path:
    files = load_model(model, root)
    found = find_one(files, r"action\s+def", action_def, "action def")
    steps = parse_flow(found.body)
    if not steps:
        raise ModelError(f"action def {action_def!r} has no steps")
    head = header(__file__, [found.source], model_name, comment="%%")
    path = write(out, f"{kebab(action_def)}-pathway.mmd", render(steps, head))
    print(f"wrote {path.name}: {len(steps)} steps")
    return path


def main(argv: list[str] | None = None) -> int:
    p = base_parser("Generate a Mermaid flowchart from a domain action flow.")
    p.add_argument("--action-def", required=True, help="the action def to draw")
    a = p.parse_args(argv)
    try:
        generate(a.model, a.out, a.root, a.action_def, a.model_name)
    except ModelError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
