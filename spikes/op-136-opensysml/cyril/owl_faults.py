"""OP-136 Step 2 (a): where the text route and the resolved route part company.

Spike code; never merged. For each edit below, a scratch copy of the
repository subset the OWL pipeline reads is made, the edit is applied to the
copy's ``model/business-metamodel-general.sysml``, the copy is validated with
the pinned ``sysml -validate``, and ``owl_reads.py`` (copied with it) runs
both routes. Its "committed" lines say whether each route still reproduces
the committed OWL (``generated/ontology/``, copied unchanged): an edit that
does not change the model's meaning must leave both routes there.

Nothing in the working tree is touched.

    python -I spikes/op-136-opensysml/cyril/owl_faults.py <scratch dir> [--out results/owl-faults]
"""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
SYSML = os.environ.get("SYSML", "/opt/homebrew/bin/sysml")
BMM = "model/business-metamodel-general.sysml"

# (label, meaning-preserving?, what it is, old text, new text)
EDITS = [
    ("m1-ref-multiplicity-spaced", True,
     "a space before a ref's multiplicity: `ResourceType [0..*]`",
     "ref linkedResource : ResourceType[0..*];",
     "ref linkedResource : ResourceType [0..*];"),
    ("m2-comment-after-closing-brace", True,
     "a trailing comment after the closing brace of CustomerSegment's @BfoType",
     '            mappingNotes = "A segment characterises a class of agents. GDC because the grouping pattern migrates between populations.";\n        }\n',
     '            mappingNotes = "A segment characterises a class of agents. GDC because the grouping pattern migrates between populations.";\n        } // end BfoType\n'),
    ("m3-brace-on-next-line", True,
     "CustomerSegment's @UserFacing with its opening brace on the next line",
     "        @UserFacing {\n            friendlyName = \"Customer Segment\";",
     "        @UserFacing\n        {\n            friendlyName = \"Customer Segment\";"),
    ("m4-quoted-word-in-description", False,
     "a quoted word inside CustomerSegment's @PurposiveDescription (content change; both routes should change, identically)",
     'description = "A group of people your service is designed for',
     'description = "A group of \\"people\\" your service is designed for'),
]

COPY = ["model", "libraries", "scripts", "ontology/config", "generated/ontology",
        "exercises/coffeeshop-demonstrator/model", "exercises/paws-demonstrator/model",
        "exercises/gendersense/model"]


def main() -> int:
    scratch = Path(sys.argv[1]).resolve()
    out = Path(sys.argv[sys.argv.index("--out") + 1]) if "--out" in sys.argv else HERE / "results" / "owl-faults"
    out = out.resolve()
    out.mkdir(parents=True, exist_ok=True)
    summary = []
    for label, preserving, what, old, new in EDITS:
        root = scratch / label
        if root.exists():
            shutil.rmtree(root)
        for rel in COPY:
            src = REPO / rel
            if src.exists():
                shutil.copytree(src, root / rel, ignore=shutil.ignore_patterns("__pycache__"))
        (root / "spikes/op-136-opensysml/cyril").mkdir(parents=True)
        shutil.copy2(HERE / "owl_reads.py", root / "spikes/op-136-opensysml/cyril/owl_reads.py")
        f = root / BMM
        text = f.read_text()
        assert text.count(old) == 1, f"{label}: edit site not unique ({text.count(old)})"
        f.write_text(text.replace(old, new))
        v = subprocess.run([SYSML, "-no-record-cache", "-validate", "model", "libraries"], cwd=root,
                           capture_output=True, text=True)
        valid = v.returncode == 0
        r = subprocess.run([sys.executable, "-I", str(root / "spikes/op-136-opensysml/cyril/owl_reads.py"),
                            "--out", str(out / label)], cwd=root, capture_output=True, text=True)
        lines = r.stdout.splitlines()
        committed = [l.strip() for l in lines if l.strip().startswith("committed ")]
        diffs = [l.strip() for l in lines if l.strip().startswith(("DIFF", "- text only", "+ resolved only"))]
        summary.append(f"## {label}: {what}")
        summary.append(f"   meaning-preserving: {preserving}; sysml -validate: {'passes' if valid else 'FAILS'}"
                       + ("" if valid else " — " + " | ".join(v.stdout.splitlines()[-3:] + v.stderr.splitlines()[-3:])))
        summary += [f"   {c}" for c in committed]
        summary += [f"   {d[:300]}" for d in diffs[:12]]
        summary.append(f"   owl_reads exit {r.returncode}")
        shutil.rmtree(root)
    text = "\n".join(summary) + "\n"
    (out / "summary.txt").write_text(text)
    print(text, end="")
    return 0


if __name__ == "__main__":
    sys.exit(main())
