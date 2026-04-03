#!/usr/bin/env python3
"""
OWL 2 DL Reasoning via Robot
==============================

Runs the HermiT reasoner (via Robot) against the full Ontara ontology
stack and reports consistency, unsatisfiable classes, and inferred axioms.

Part of Stage 5 Phase 2 — Step 4.

Prerequisites:
  - Java 11+ installed (java on PATH)
  - Robot JAR downloaded to tools/robot.jar
    (see tools/README.md for instructions)
  - Pipeline has been run: python3 scripts/gen_owl_pipeline.py --save

Usage:
    python3 scripts/reason_kg.py                # Reason over full stack
    python3 scripts/reason_kg.py --verbose      # Show detailed output
    python3 scripts/reason_kg.py --test-violation  # Inject contradiction, confirm reasoner catches it
    python3 scripts/reason_kg.py --output results  # Save inferred ontology to file

Source: Stage 5 Phase 2 — Step 4 (Session 115)
Design decision: S111-D5 — Robot + HermiT
"""

import argparse
import os
import pathlib
import shutil
import subprocess
import sys
import tempfile

# ---------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------

REPO_ROOT = pathlib.Path(__file__).parent.parent

ROBOT_JAR = REPO_ROOT / "tools" / "robot.jar"

# Ontology files — loaded in order (imports first, then domain, then axioms)
ONTOLOGY_FILES = [
    {
        "file": REPO_ROOT / "ontology" / "imports" / "bfo-core.owl",
        "name": "BFO 2020 Core",
        "required": True,
    },
    {
        "file": REPO_ROOT / "ontology" / "imports" / "iao.owl",
        "name": "IAO (Information Artifact Ontology)",
        "required": True,
    },
    {
        "file": REPO_ROOT / "ontology" / "imports" / "CommonCoreOntologiesMerged.ttl",
        "name": "CCO (Common Core Ontologies)",
        "required": True,
    },
    {
        "file": REPO_ROOT / "generated" / "ontology" / "ontara-bmm.ttl",
        "name": "Ontara BMM (pipeline-generated)",
        "required": True,
    },
    {
        "file": REPO_ROOT / "ontology" / "axioms" / "ontara-bmm-axioms.ttl",
        "name": "Ontara BMM Axioms (hand-authored)",
        "required": True,
    },
]

# Violation test: a Turtle snippet that makes ValueProposition a subclass
# of ActivityModelElement, which contradicts the AllDisjointClasses axiom
# (ValueProposition is in ServiceConceptElement, not ActivityModelElement).
VIOLATION_TURTLE = """\
@prefix ontara-bmm: <https://ontara.dev/ontology/bmm/> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix owl: <http://www.w3.org/2002/07/owl#> .

# Deliberate contradiction: ValueProposition cannot be both a
# ServiceConceptElement and an ActivityModelElement (disjoint groups).
ontara-bmm:ValueProposition rdfs:subClassOf ontara-bmm:ActivityModelElement .
"""


# ---------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------

def check_java():
    """Verify Java is available."""
    try:
        result = subprocess.run(
            ["java", "-version"],
            capture_output=True, text=True, timeout=10,
        )
        # java -version outputs to stderr
        version_text = result.stderr or result.stdout
        if result.returncode != 0:
            print("ERROR: java -version returned non-zero exit code.")
            print(version_text)
            return False
        # Extract first line for display
        first_line = version_text.strip().split("\n")[0]
        print(f"  Java: {first_line}")
        return True
    except FileNotFoundError:
        print("ERROR: 'java' not found on PATH.")
        print("  Robot requires Java 11 or later.")
        return False
    except subprocess.TimeoutExpired:
        print("ERROR: java -version timed out.")
        return False


def check_robot():
    """Verify Robot JAR exists and is runnable."""
    if not ROBOT_JAR.exists():
        print(f"ERROR: Robot JAR not found at {ROBOT_JAR}")
        print("  Download it with:")
        print("    cd tools")
        print("    curl -L -o robot.jar https://github.com/ontodev/robot/releases/download/v1.9.8/robot.jar")
        return False

    try:
        result = subprocess.run(
            ["java", "-jar", str(ROBOT_JAR), "--version"],
            capture_output=True, text=True, timeout=30,
        )
        version = (result.stdout or result.stderr).strip()
        if result.returncode != 0:
            print(f"ERROR: Robot returned exit code {result.returncode}")
            print(version)
            return False
        print(f"  Robot: {version}")
        return True
    except subprocess.TimeoutExpired:
        print("ERROR: Robot --version timed out.")
        return False


def check_ontology_files():
    """Verify all required ontology files exist."""
    all_ok = True
    for entry in ONTOLOGY_FILES:
        exists = entry["file"].exists()
        size = entry["file"].stat().st_size if exists else 0
        status = f"{size:,} bytes" if exists else "MISSING"
        marker = "OK" if exists else "MISSING"

        if not exists and entry["required"]:
            all_ok = False
            marker = "FAIL"

        print(f"  [{marker}] {entry['name']}: {entry['file'].name} ({status})")

    return all_ok


def run_robot(args, verbose=False, timeout=300):
    """Run a Robot command and return (success, stdout, stderr)."""
    cmd = ["java", "-jar", str(ROBOT_JAR)] + args

    if verbose:
        print(f"  Command: {' '.join(cmd)}")

    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=timeout,
            cwd=str(REPO_ROOT),
        )

        if verbose:
            if result.stdout.strip():
                print(f"  stdout: {result.stdout.strip()[:2000]}")
            if result.stderr.strip():
                print(f"  stderr: {result.stderr.strip()[:2000]}")

        return result.returncode == 0, result.stdout, result.stderr

    except subprocess.TimeoutExpired:
        print(f"  ERROR: Robot command timed out after {timeout}s.")
        return False, "", "Timeout"


def count_axioms_in_file(filepath):
    """Count approximate axiom count in a Turtle or OWL file.

    This is a rough count — counts non-blank, non-prefix, non-comment lines.
    For a proper count, we use Robot's measure command.
    """
    if not filepath.exists():
        return 0

    count = 0
    with open(filepath, "r", encoding="utf-8") as f:
        for line in f:
            stripped = line.strip()
            if (stripped
                    and not stripped.startswith("#")
                    and not stripped.startswith("@prefix")
                    and not stripped.startswith("@base")):
                count += 1
    return count


# ---------------------------------------------------------------
# Core reasoning
# ---------------------------------------------------------------

def reason_ontology(verbose=False, output_path=None):
    """Merge all ontology files and run HermiT reasoning.

    Returns (consistent, unsatisfiable_classes, summary_text).
    """
    print("\n--- Merging ontology files ---")

    # Build the merge + reason command chain.
    # Robot supports chaining: merge --input A --input B reason --reasoner hermit
    args = ["merge"]

    for entry in ONTOLOGY_FILES:
        args.extend(["--input", str(entry["file"])])

    # Collapse imports so Robot doesn't try to fetch remote IRIs
    args.extend(["--collapse-import-closure", "true"])

    # Chain into reason with HermiT
    args.extend([
        "reason",
        "--reasoner", "hermit",
        "--annotate-inferred-axioms", "true",
        "--exclude-tautologies", "structural",
    ])

    # Optionally save the inferred ontology
    if output_path:
        args.extend(["--output", str(output_path)])
        print(f"  Inferred ontology will be saved to: {output_path}")

    print("\n--- Running HermiT reasoner ---")
    success, stdout, stderr = run_robot(args, verbose=verbose, timeout=600)

    combined_output = (stdout + "\n" + stderr).strip()

    if success:
        print("  CONSISTENT — HermiT found no contradictions.")
        return True, [], combined_output
    else:
        # Parse stderr for unsatisfiable classes
        unsatisfiable = []
        for line in stderr.split("\n"):
            # Robot reports unsatisfiable classes in its error output
            if "unsatisfiable" in line.lower() or "nothing" in line.lower():
                unsatisfiable.append(line.strip())

        if "InconsistentOntologyException" in combined_output:
            print("  INCONSISTENT — the ontology contains a logical contradiction.")
        elif unsatisfiable:
            print(f"  INCOHERENT — {len(unsatisfiable)} unsatisfiable class(es) found.")
        else:
            print(f"  FAILED — Robot returned an error.")

        if verbose or not success:
            # Show the error output (trimmed)
            error_lines = combined_output.split("\n")
            for line in error_lines[:30]:
                if line.strip():
                    print(f"    {line.strip()}")
            if len(error_lines) > 30:
                print(f"    ... ({len(error_lines) - 30} more lines)")

        return False, unsatisfiable, combined_output


def test_violation(verbose=False):
    """Inject a deliberate contradiction and verify the reasoner catches it.

    Creates a temporary Turtle file that makes ValueProposition a subclass
    of ActivityModelElement (contradicts the disjointness axiom), merges it
    with the full stack, and confirms HermiT reports inconsistency.

    Returns True if the reasoner correctly caught the violation.
    """
    print("\n=== VIOLATION TEST ===")
    print("  Injecting: ValueProposition rdfs:subClassOf ActivityModelElement")
    print("  Expected: HermiT should report inconsistency (disjoint groups)")

    # Write the violation to a temp file
    with tempfile.NamedTemporaryFile(
        mode="w", suffix=".ttl", delete=False, prefix="ontara-violation-"
    ) as f:
        f.write(VIOLATION_TURTLE)
        violation_file = f.name

    try:
        # Build merge + reason with the violation file added
        args = ["merge"]

        for entry in ONTOLOGY_FILES:
            args.extend(["--input", str(entry["file"])])

        # Add the violation file
        args.extend(["--input", violation_file])
        args.extend(["--collapse-import-closure", "true"])

        args.extend([
            "reason",
            "--reasoner", "hermit",
        ])

        print("\n  Running HermiT with deliberate contradiction...")
        success, stdout, stderr = run_robot(args, verbose=verbose, timeout=600)

        combined = (stdout + "\n" + stderr).strip()

        if not success:
            print("  PASS — Reasoner correctly rejected the contradictory ontology.")
            if verbose:
                for line in combined.split("\n")[:15]:
                    if line.strip():
                        print(f"    {line.strip()}")
            return True
        else:
            print("  FAIL — Reasoner did NOT catch the contradiction!")
            print("  This suggests the disjointness axioms may not be working.")
            return False

    finally:
        # Clean up temp file
        os.unlink(violation_file)


# ---------------------------------------------------------------
# Reporting
# ---------------------------------------------------------------

def print_summary(consistent, unsatisfiable, test_result=None):
    """Print a final summary."""
    print("\n=== REASONING SUMMARY ===")
    print(f"  Ontology stack: {len(ONTOLOGY_FILES)} files")
    print(f"  Reasoner:       HermiT (via Robot)")

    if consistent:
        print(f"  Consistency:    PASS")
    else:
        print(f"  Consistency:    FAIL")
        if unsatisfiable:
            print(f"  Unsatisfiable:  {len(unsatisfiable)} class(es)")

    if test_result is not None:
        label = "PASS (caught violation)" if test_result else "FAIL (missed violation)"
        print(f"  Violation test: {label}")

    overall = consistent and (test_result is None or test_result)
    status = "PASSED" if overall else "FAILED"
    print(f"  OVERALL:        {status}")

    return overall


# ---------------------------------------------------------------
# Main
# ---------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Run OWL 2 DL reasoning over the Ontara ontology stack."
    )
    parser.add_argument(
        "--verbose", action="store_true",
        help="Show detailed Robot output",
    )
    parser.add_argument(
        "--test-violation", action="store_true",
        help="Also run a deliberate violation test",
    )
    parser.add_argument(
        "--output", type=str, default=None,
        help="Save inferred ontology to this file path",
    )
    args = parser.parse_args()

    print("Ontara OWL 2 DL Reasoning (Robot + HermiT)")
    print(f"Repo root: {REPO_ROOT}")
    print()

    # Pre-flight checks
    print("--- Pre-flight checks ---")
    if not check_java():
        sys.exit(1)
    if not check_robot():
        sys.exit(1)
    if not check_ontology_files():
        print("\nMissing required ontology files — aborting.")
        sys.exit(1)
    print()

    # Run reasoning
    consistent, unsatisfiable, summary = reason_ontology(
        verbose=args.verbose,
        output_path=args.output,
    )

    # Violation test (optional)
    test_result = None
    if args.test_violation:
        test_result = test_violation(verbose=args.verbose)

    # Summary
    overall = print_summary(consistent, unsatisfiable, test_result)
    sys.exit(0 if overall else 1)


if __name__ == "__main__":
    main()
