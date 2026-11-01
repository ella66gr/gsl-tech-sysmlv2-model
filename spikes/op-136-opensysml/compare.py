"""OP-136 spike: compare the OpenSysML axis reader with generation/status_axes.py.

Usage (from the repository root, in the spike venv; see README.md):

    python -I spikes/op-136-opensysml/compare.py <label> <model folder> [--out DIR]

Writes, under DIR (default spikes/op-136-opensysml/results):

    <label>.text.json       what generation/status_axes.py returns, or its error
    <label>.opensysml.json  what opensysml_axes.py returns, or its error
    <label>.diff.txt        a unified diff of the two, then a summary line

Both are serialised by the same function, so any difference is a difference
in what was read. Exit status: 0 when the two are identical, 1 when they
differ, 2 on a usage error.
"""

from __future__ import annotations

import argparse
import difflib
import json
import sys
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[1]
for p in (str(REPO), str(HERE)):
    if p not in sys.path:
        sys.path.insert(0, p)

from generation import status_axes  # noqa: E402
from generation.sysml_text import load_model  # noqa: E402

import opensysml_axes  # noqa: E402


def shape(types) -> list[dict]:
    """The data the generators read, per type, in the readers' order."""
    out = []
    for t in types:
        out.append({
            "type": t.name,
            "qualified": t.found.qualified,
            "source": t.source,
            "refs": {k: list(v) for k, v in sorted(t.refs.items())},
            "axes": [
                {
                    "usage": a.usage,
                    "name": a.name,
                    "ident": a.ident,
                    "values": a.values,
                    "default": a.default,
                    "authority": a.authorities,
                    "shape": a.shape,
                    "terminal": a.terminal_values,
                    "transitions": [
                        {
                            "name": m.name,
                            "from": m.source,
                            "to": m.target,
                            "label": m.label,
                            "event": m.event,
                            "requiredAuthority": m.authorities,
                            "preconditions": [
                                {
                                    "name": p.name,
                                    "relatedVia": p.related_via,
                                    "relatedType": p.related_type,
                                    "requiredAxis": p.required_axis,
                                    "requiredValues": p.required_values,
                                    "rejectionReason": p.rejection_reason,
                                }
                                for p in m.preconditions
                            ],
                        }
                        for m in a.moves
                    ],
                }
                for a in t.axes
            ],
        })
    return out


def run(fn):
    t0 = time.perf_counter()
    try:
        result = {"ok": True, "types": shape(fn())}
    except Exception as e:  # recorded, not raised: an error is a result here
        result = {"ok": False, "error": f"{type(e).__name__}: {e}"}
    return result, time.perf_counter() - t0


def main(argv=None) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("label")
    ap.add_argument("model")
    ap.add_argument("--out", default=str(HERE / "results"))
    a = ap.parse_args(argv)
    folder = (REPO / a.model).resolve() if not Path(a.model).is_absolute() else Path(a.model)
    out = Path(a.out)
    out.mkdir(parents=True, exist_ok=True)

    text, t_text = run(lambda: status_axes.axis_types(load_model(folder, REPO)))
    resolved, t_os = run(lambda: opensysml_axes.axis_types(folder, REPO))

    dumps = {}
    for kind, data in (("text", text), ("opensysml", resolved)):
        s = json.dumps(data, indent=2, ensure_ascii=False) + "\n"
        (out / f"{a.label}.{kind}.json").write_text(s, encoding="utf-8")
        dumps[kind] = s.splitlines(keepends=True)
    diff = list(difflib.unified_diff(
        dumps["text"], dumps["opensysml"],
        fromfile=f"{a.label}.text.json (generation/status_axes.py)",
        tofile=f"{a.label}.opensysml.json (opensysml_axes.py)",
    ))
    same = not diff

    def count(d):
        if not d["ok"]:
            return "error"
        ts = d["types"]
        return (f"{len(ts)} types, {sum(len(t['axes']) for t in ts)} axes, "
                f"{sum(len(x['transitions']) for t in ts for x in t['axes'])} transitions, "
                f"{sum(len(m['preconditions']) for t in ts for x in t['axes'] for m in x['transitions'])} preconditions")

    summary = (
        f"{a.label}: {'IDENTICAL' if same else 'DIFFERENT'}; "
        f"text {count(text)} in {t_text:.3f} s; opensysml {count(resolved)} in {t_os:.3f} s "
        f"(opensysml {opensysml.__version__ if (opensysml := __import__('opensysml')) else ''})\n"
    )
    (out / f"{a.label}.diff.txt").write_text("".join(diff) + ("\n" if diff else "") + summary, encoding="utf-8")
    sys.stdout.write(summary)
    return 0 if same else 1


if __name__ == "__main__":
    sys.exit(main())
