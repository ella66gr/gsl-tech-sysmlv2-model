"""OP-136 Step 2 (d): run the worked acceptance, and the E6 test, on the same cases.

Spike code; never merged. Nothing in the working tree is written except
``--out`` (default ``results/acceptance`` beside this folder).

For each case, a scratch copy of the Cafe model is made and edited:

  as-is            the Cafe model unchanged
  members          the moves and the precondition declared as members of the
                   metamodel's collections: ``part x : AxisTransition :>
                   permittedTransitions``, ``part p : AxisPrecondition :>
                   preconditions`` (a convention change; nothing else)
  members+unpaid   members, and the precondition admits unpaid as well as paid
  members+remake   members, and a new move ready -> inPreparation (a remake)
                   with no precondition
  members+express  members, and a second move queued -> inPreparation (an
                   express start) with no precondition
  members+reinstate members, and a move cancelled -> inPreparation (reinstate a
                   line) with no precondition: reachable while unpaid, since an
                   order cancelled before payment cancels its queued lines
  members+removed  members, and the precondition removed

Two judges, side by side:

1. The acceptance (``cafe-s04-acceptance.sysml``), by the pinned
   ``sysml -satisfy -json`` on ``model libraries <copy>``.
2. The E6 test as committed (``exercises/coffeeshop-demonstrator/tests/
   axis-preconditions.test.mts``), run against the guard and evaluator
   regenerated, by the Makefile's own generator commands, from the same edit
   applied WITHOUT the membership convention (the text readers do not read
   ``:> permittedTransitions``; see the report). For ``as-is`` this is the
   committed model.

    python3 spikes/op-136-opensysml/cyril/acceptance/run_acceptance.py <scratch dir> [--out DIR]
"""

from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[3]
SYSML = os.environ.get("SYSML", "/opt/homebrew/bin/sysml")
NODE = os.environ.get("NODE", "node")
PYTHON = os.environ.get("PYTHON", "python3")
ACCEPTANCE = HERE / "cafe-s04-acceptance.sysml"
CAFE = "exercises/coffeeshop-demonstrator"
DOMAIN = "model/domain/coffeeshop.sysml"
E6_TEST = "tests/axis-preconditions.test.mts"
GUARD_TEST = "tests/axis-guard.test.mts"

REMAKE_AFTER = """            part readyToCollected : AxisTransition {
                :>> fromValue = "ready";
                :>> toValue = "collected";
                :>> transitionLabel = "Customer: Collect Drink";
                :>> triggerEvent = "LineCollected";
                :>> requiredAuthority = (AxisAuthority::operatorSide);
            }
"""
REMAKE = """
            part readyToInPreparation : AxisTransition {
                :>> fromValue = "ready";
                :>> toValue = "inPreparation";
                :>> transitionLabel = "Barista: Remake Drink";
                :>> triggerEvent = "LineRemakeStarted";
                :>> requiredAuthority = (AxisAuthority::operatorSide);
            }
"""
EXPRESS = """
            part queuedToInPreparationExpress : AxisTransition {
                :>> fromValue = "queued";
                :>> toValue = "inPreparation";
                :>> transitionLabel = "Barista: Start Express";
                :>> triggerEvent = "LineExpressStarted";
                :>> requiredAuthority = (AxisAuthority::operatorSide);
            }
"""
REINSTATE = """
            part cancelledToInPreparation : AxisTransition {
                :>> fromValue = "cancelled";
                :>> toValue = "inPreparation";
                :>> transitionLabel = "Barista: Reinstate Line";
                :>> triggerEvent = "LineReinstated";
                :>> requiredAuthority = (AxisAuthority::operatorSide);
            }
"""
PRECONDITION = """
                // The Cafe's cross-axis rule (S0.4 item 4).
                part orderPaid : AxisPrecondition {
                    :>> relatedVia = "order";
                    :>> requiredAxis = "payment";
                    :>> requiredValues = ("paid");
                    :>> rejectionReason = "The order is not paid. A line cannot start preparation until its order is paid.";
                }
"""


def once(text: str, old: str, new: str) -> str:
    assert text.count(old) == 1, f"edit site found {text.count(old)} times"
    return text.replace(old, new)


def members(text: str) -> str:
    text = re.sub(r"part (\w+) : AxisTransition \{", r"part \1 : AxisTransition :> permittedTransitions {", text)
    return re.sub(r"part (\w+) : AxisPrecondition \{", r"part \1 : AxisPrecondition :> preconditions {", text)


FAULTS = {
    "": lambda t: t,
    "unpaid": lambda t: once(t, ':>> requiredValues = ("paid");', ':>> requiredValues = ("unpaid", "paid");'),
    "remake": lambda t: once(t, REMAKE_AFTER, REMAKE_AFTER + REMAKE),
    "removed": lambda t: once(t, PRECONDITION, "\n"),
    "express": lambda t: once(t, REMAKE_AFTER, REMAKE_AFTER + EXPRESS),
    "reinstate": lambda t: once(t, REMAKE_AFTER, REMAKE_AFTER + REINSTATE),
}

CASES = [
    ("as-is", "", False),
    ("members", "", True),
    ("members+unpaid", "unpaid", True),
    ("members+remake", "remake", True),
    ("members+express", "express", True),
    ("members+reinstate", "reinstate", True),
    ("members+removed", "removed", True),
]


def copy_model(dst: Path, edited: str) -> Path:
    if dst.exists():
        shutil.rmtree(dst)
    shutil.copytree(REPO / CAFE / "model", dst / "model")
    (dst / DOMAIN).write_text(edited)
    return dst / "model"


def acceptance(model_dir: Path) -> dict:
    r = subprocess.run([SYSML, "-no-record-cache", "model", "libraries", str(model_dir), str(ACCEPTANCE),
                        "-satisfy", "-json"], cwd=REPO, capture_output=True, text=True)
    try:
        d = json.loads(r.stdout)
    except json.JSONDecodeError:
        return {"verdict": "NO REPORT", "exit": r.returncode, "lines": (r.stdout + r.stderr).splitlines()[-4:]}
    lines = [l for c in d.get("checks") or [] for l in c.get("lines") or []]
    errs = [x.get("message") for x in d.get("diagnostics") or [] if x.get("severity") == "error"]
    return {"verdict": d.get("status"), "exit": r.returncode, "lines": lines + errs}


def e6(work: Path, edited: str) -> dict:
    """Regenerate the guard and the E6 evaluator from ``edited`` and run the committed test."""
    root = work / "repo"
    if root.exists():
        shutil.rmtree(root)
    for rel in ("generation", "model", "libraries"):
        shutil.copytree(REPO / rel, root / rel, ignore=shutil.ignore_patterns("__pycache__"))
    shutil.copytree(REPO / CAFE / "model", root / CAFE / "model")
    (root / CAFE / DOMAIN).write_text(edited)
    (root / CAFE / "tests").mkdir(parents=True)
    shutil.copy2(REPO / CAFE / E6_TEST, root / CAFE / E6_TEST)
    shutil.copy2(REPO / CAFE / GUARD_TEST, root / CAFE / GUARD_TEST)
    out = root / CAFE / "generated"
    gen = []
    for cmd in (
        [PYTHON, "-m", "generation.state_machine", "--model", f"{CAFE}/model", "--out", f"{CAFE}/generated",
         "--model-name", "CoffeeShop"],
        [PYTHON, "-m", "generation.constraint_evaluator", "--model", f"{CAFE}/model", "--out", f"{CAFE}/generated",
         "--model-name", "CoffeeShop", "--quiet"],
    ):
        g = subprocess.run(cmd, cwd=root, capture_output=True, text=True)
        gen.append(g.returncode)
        if g.returncode:
            return {"verdict": "GENERATION FAILED", "exit": g.returncode, "lines": (g.stdout + g.stderr).splitlines()[-3:]}
    t = subprocess.run([NODE, "--disable-warning=MODULE_TYPELESS_PACKAGE_JSON", "--test", f"{CAFE}/{E6_TEST}"],
                       cwd=root, capture_output=True, text=True)
    res = [l.strip() for l in t.stdout.splitlines() if l.strip().startswith(("✔", "✖")) and "test" not in l[:4]]
    tally = [l.strip() for l in t.stdout.splitlines() if l.strip().startswith(("ℹ pass", "ℹ fail"))]
    gt = subprocess.run([NODE, "--disable-warning=MODULE_TYPELESS_PACKAGE_JSON", "--test", f"{CAFE}/{GUARD_TEST}"],
                        cwd=root, capture_output=True, text=True)
    guard_fail = [l.strip() for l in gt.stdout.splitlines() if l.strip().startswith("✖") and "failing tests" not in l]
    guard = f"guard test (axis-guard.test.mts, for context): {'green' if gt.returncode == 0 else 'red'}" + (
        f"; failing: {sorted(set(guard_fail))}" if guard_fail else "")
    same = None
    if not edited != (REPO / CAFE / DOMAIN).read_text():
        same = all((out / f).read_bytes() == (REPO / CAFE / "generated" / f).read_bytes()
                   for f in ("axis-guard.ts", "axis-preconditions.ts"))
    return {"verdict": "green" if t.returncode == 0 else "red", "exit": t.returncode,
            "guard": guard, "lines": res + tally + [guard] + ([f"regenerated guard and evaluator equal the committed files: {same}"] if same is not None else [])}


def main() -> int:
    scratch = Path(sys.argv[1]).resolve()
    out = Path(sys.argv[sys.argv.index("--out") + 1]).resolve() if "--out" in sys.argv else HERE.parent / "results" / "acceptance"
    out.mkdir(parents=True, exist_ok=True)
    base = (REPO / CAFE / DOMAIN).read_text()
    report, table = [], ["| Case | Acceptance (sysml -satisfy) | E6 test, regenerated |", "|---|---|---|"]
    for label, fault, mem in CASES:
        edited = FAULTS[fault](base)
        a = acceptance(copy_model(scratch / f"acc-{label}", members(edited) if mem else edited))
        e = e6(scratch / f"e6-{label}", edited)
        report.append(f"## {label}")
        report.append(f"   acceptance: {a['verdict']} (exit {a['exit']})")
        report += [f"      {l}" for l in a["lines"]]
        report.append(f"   E6 test on the same edit without the membership convention: {e['verdict']} (exit {e['exit']})")
        report += [f"      {l}" for l in e["lines"]]
        g = e.get("guard", "")
        table.append(f"| {label} | {a['verdict']} | {e['verdict']} | {'red' if ': red' in g else ('green' if ': green' in g else 'not run')} |")
        shutil.rmtree(scratch / f"acc-{label}", ignore_errors=True)
        shutil.rmtree(scratch / f"e6-{label}", ignore_errors=True)
    text = "\n".join(table + [""] + report) + "\n"
    (out / "summary.txt").write_text(text)
    print(text, end="")
    return 0


if __name__ == "__main__":
    sys.exit(main())
