#!/usr/bin/env python3
"""
OWL 2 DL Reasoning via Robot
==============================

Runs the HermiT reasoner (via Robot) against the full Ontara ontology
stack and reports consistency, unsatisfiable classes, and inferred axioms.

Part of Stage 5 Phase 2 — Steps 4 and 6.

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
import json
import os
import pathlib
import shutil
import subprocess
import sys
import tempfile
from datetime import datetime

# ---------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------

REPO_ROOT = pathlib.Path(__file__).parent.parent

ROBOT_JAR = REPO_ROOT / "tools" / "robot.jar"
CATALOG_FILE = REPO_ROOT / "ontology" / "catalog-v001.xml"

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
        "file": REPO_ROOT / "ontology" / "imports" / "prov-core.ttl",
        "name": "PROV-O Core Subset (W3C, Session 150)",
        "required": False,
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
    {
        "file": REPO_ROOT / "generated" / "ontology" / "ontara-bmm-properties.ttl",
        "name": "Ontara BMM Properties (pipeline-generated)",
        "required": False,
    },
    {
        "file": REPO_ROOT / "generated" / "ontology" / "ontara-bmm-weights.ttl",
        "name": "Ontara BMM Weighted Relationships (pipeline-generated)",
        "required": False,
    },
    {
        "file": REPO_ROOT / "ontology" / "governance" / "ontara-governance.ttl",
        "name": "Ontara Governance Vocabulary (hand-authored)",
        "required": False,
    },
    {
        "file": REPO_ROOT / "ontology" / "governance" / "cqc-reg12-individuals.ttl",
        "name": "CQC Regulation 12 Governance MVP (hand-authored)",
        "required": False,
    },
    {
        "file": REPO_ROOT / "ontology" / "domain" / "ontara-domain.ttl",
        "name": "Ontara Domain Identity Vocabulary (hand-authored, Session 144)",
        "required": False,
    },
    {
        "file": REPO_ROOT / "ontology" / "reasoning" / "ontara-reasoning.ttl",
        "name": "Ontara Reasoning Vocabulary (hand-authored, Session 150)",
        "required": False,
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
        elif not exists:
            marker = "SKIP"

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
# Object property extraction
# ---------------------------------------------------------------

def extract_object_properties():
    """Parse ontara-bmm-properties.ttl and return a list of property dicts.

    Uses rdflib (already a dependency via gen_owl_pipeline.py).
    Returns an empty list if the file doesn't exist or rdflib is unavailable.
    """
    props_file = REPO_ROOT / "generated" / "ontology" / "ontara-bmm-properties.ttl"
    if not props_file.exists():
        return []

    try:
        from rdflib import Graph, Namespace
        from rdflib.namespace import RDF, RDFS, OWL
    except ImportError:
        print("  WARNING: rdflib not available — object properties not extracted.", file=sys.stderr)
        return []

    g = Graph()
    g.parse(props_file, format="turtle")

    ONTARA_AX = Namespace("https://ontara.dev/ontology/bmm/axioms#")
    ONTARA_BMM = Namespace("https://ontara.dev/ontology/bmm/")

    properties = []
    for prop in g.subjects(RDF.type, OWL.ObjectProperty):
        name_raw = str(prop)
        name = name_raw.split("#")[-1] if "#" in name_raw else name_raw.split("/")[-1]
        label = str(g.value(prop, RDFS.label, default=""))
        # Strip language tags (rdflib includes them in str())
        if "@" in label:
            label = label.split("@")[0]
        comment = str(g.value(prop, RDFS.comment, default=""))
        if "@" in comment:
            comment = comment.split("@")[0]

        domain_uri = g.value(prop, RDFS.domain)
        range_uri = g.value(prop, RDFS.range)
        domain_name = str(domain_uri).split("/")[-1] if domain_uri else ""
        range_name = str(range_uri).split("/")[-1] if range_uri else ""

        functional = (prop, RDF.type, OWL.FunctionalProperty) in g

        properties.append({
            "name": name,
            "label": label,
            "domain": domain_name,
            "range": range_name,
            "functional": functional,
            "comment": comment,
        })

    properties.sort(key=lambda p: p["name"])
    return properties


def extract_reasoning_vocabulary():
    """Parse ontara-reasoning.ttl and extract vocabulary structure for console display.

    Returns a dict with classes, namedIndividuals, objectProperties,
    datatypeProperties, crossModuleAxioms, and moduleSummary.

    Stage 7 Phase 4, Session 158.
    """
    reasoning_file = REPO_ROOT / "ontology" / "reasoning" / "ontara-reasoning.ttl"
    if not reasoning_file.exists():
        return None

    try:
        from rdflib import Graph, Namespace, URIRef, Literal
        from rdflib.namespace import RDF, RDFS, OWL, XSD
    except ImportError:
        print("  WARNING: rdflib not available — reasoning vocabulary not extracted.", file=sys.stderr)
        return None

    g = Graph()
    g.parse(reasoning_file, format="turtle")

    ONTARA_RSN = Namespace("https://ontara.dev/ontology/reasoning/")
    ONTARA_GOV = Namespace("https://ontara.dev/ontology/governance/")
    PROV = Namespace("http://www.w3.org/ns/prov#")
    BFO = Namespace("http://purl.obolibrary.org/obo/")

    def short_iri(uri):
        """Convert full IRI to short display form."""
        uri_str = str(uri)
        prefixes = {
            "https://ontara.dev/ontology/reasoning/": "ontara-rsn:",
            "https://ontara.dev/ontology/governance/": "ontara-gov:",
            "https://ontara.dev/ontology/bmm/": "ontara-bmm:",
            "https://ontara.dev/ontology/domain/": "ontara-dom:",
            "http://purl.obolibrary.org/obo/": "bfo:",
            "http://www.w3.org/ns/prov#": "prov:",
            "http://purl.org/dc/terms/": "dcterms:",
        }
        for prefix_iri, prefix_label in prefixes.items():
            if uri_str.startswith(prefix_iri):
                return prefix_label + uri_str[len(prefix_iri):]
        return uri_str.split("/")[-1].split("#")[-1]

    def get_label(subject):
        label = g.value(subject, RDFS.label)
        if label:
            return str(label).split("@")[0]  # strip language tag
        return short_iri(subject)

    def get_comment(subject):
        comment = g.value(subject, RDFS.comment)
        if comment:
            raw = str(comment).split("@")[0]
            # Truncate long comments for JSON
            if len(raw) > 300:
                return raw[:297] + "..."
            return raw
        return ""

    # --- Functional grouping for classes ---
    # Map classes to display groups based on their characteristics
    FOUNDATION_CLASSES = {
        "ReasoningActivity", "Claim", "ReasoningAgent", "Decision",
    }
    EVIDENCE_CLASSES = {
        "EvidenceLine", "EvidenceItem", "ConfidenceAssessment",
    }
    PROBABILISTIC_CLASSES = {
        "StructuredProbabilisticComponent", "BayesianUpdater",
        "RiskCalculator", "PrognosticModel", "PredictiveAnalytics",
    }
    CONSTRAINT_CLASSES = {
        "Constraint", "HardConstraint", "SoftConstraint", "GradedRule",
    }
    SAFETY_CLASSES = {
        "SafetyConstraint", "ControlStructure", "ControlLoop",
        "ControlAction", "UnsafeControlAction",
        "FRAMFunction", "VariabilityProfile",
    }
    KNOWLEDGE_CLASSES = {
        "KnowledgeSource", "Heuristic", "HeuristicPack", "DecisionMode",
        "OrderingHeuristic", "ResourceAllocationHeuristic",
        "RiskPrioritisationHeuristic", "EscalationHeuristic",
    }

    def classify_module(class_name):
        if class_name in FOUNDATION_CLASSES:
            return "foundation"
        if class_name in EVIDENCE_CLASSES:
            return "evidence"
        if class_name in PROBABILISTIC_CLASSES:
            return "probabilistic"
        if class_name in CONSTRAINT_CLASSES:
            return "constraints"
        if class_name in SAFETY_CLASSES:
            return "safety"
        if class_name in KNOWLEDGE_CLASSES:
            return "knowledge"
        return "core"

    # --- Extract classes ---
    classes = []
    for cls in g.subjects(RDF.type, OWL.Class):
        cls_str = str(cls)
        if not cls_str.startswith(str(ONTARA_RSN)):
            continue  # only ontara-rsn: classes
        class_name = cls_str[len(str(ONTARA_RSN)):]
        parents = []
        for parent in g.objects(cls, RDFS.subClassOf):
            if isinstance(parent, URIRef):
                parents.append(short_iri(parent))
        classes.append({
            "iri": short_iri(cls),
            "label": get_label(cls),
            "comment": get_comment(cls),
            "parents": parents,
            "module": classify_module(class_name),
        })
    classes.sort(key=lambda c: c["iri"])

    # --- Extract named individuals ---
    named_individuals = []
    for ind in g.subjects(RDF.type, OWL.NamedIndividual):
        ind_str = str(ind)
        if not ind_str.startswith(str(ONTARA_RSN)):
            continue
        types = []
        for t in g.objects(ind, RDF.type):
            if t != OWL.NamedIndividual:
                types.append(short_iri(t))
        named_individuals.append({
            "iri": short_iri(ind),
            "label": get_label(ind),
            "types": types,
        })
    named_individuals.sort(key=lambda i: i["iri"])

    # --- Extract object properties ---
    obj_properties = []
    for prop in g.subjects(RDF.type, OWL.ObjectProperty):
        prop_str = str(prop)
        if not prop_str.startswith(str(ONTARA_RSN)):
            continue
        domain_uri = g.value(prop, RDFS.domain)
        range_uri = g.value(prop, RDFS.range)
        functional = (prop, RDF.type, OWL.FunctionalProperty) in g
        obj_properties.append({
            "name": short_iri(prop),
            "label": get_label(prop),
            "domain": short_iri(domain_uri) if domain_uri else "",
            "range": short_iri(range_uri) if range_uri else "",
            "functional": functional,
            "comment": get_comment(prop),
        })
    obj_properties.sort(key=lambda p: p["name"])

    # --- Extract datatype properties ---
    dt_properties = []
    for prop in g.subjects(RDF.type, OWL.DatatypeProperty):
        prop_str = str(prop)
        if not prop_str.startswith(str(ONTARA_RSN)):
            continue
        domain_uri = g.value(prop, RDFS.domain)
        range_uri = g.value(prop, RDFS.range)
        dt_properties.append({
            "iri": short_iri(prop),
            "label": get_label(prop),
            "domain": short_iri(domain_uri) if domain_uri else "",
            "range": short_iri(range_uri) if range_uri else "" if not range_uri else str(range_uri).split("#")[-1],
            "comment": get_comment(prop),
        })
    dt_properties.sort(key=lambda p: p["iri"])

    # --- Extract cross-module axioms ---
    # Look for rdfs:subClassOf triples where subject is ontara-rsn: or ontara-gov:
    # and object is in a different namespace
    cross_module = []
    for s, p, o in g.triples((None, RDFS.subClassOf, None)):
        if not isinstance(s, URIRef) or not isinstance(o, URIRef):
            continue
        s_str, o_str = str(s), str(o)
        s_ns = s_str.rsplit("/", 1)[0] + "/" if "/" in s_str else ""
        o_ns = o_str.rsplit("/", 1)[0] + "/" if "/" in o_str else ""
        # Cross-module: different namespaces, and at least one is ontara-rsn:
        if s_ns != o_ns and (str(ONTARA_RSN) in s_str or str(ONTARA_RSN) in o_str):
            # Describe the connection
            s_short = short_iri(s)
            o_short = short_iri(o)
            if str(ONTARA_GOV) in s_str:
                desc = f"{s_short} is a subclass of {o_short} (governance → reasoning alignment)"
            elif str(PROV) in o_str:
                desc = f"{s_short} inherits from {o_short} (PROV-O dual subclassing)"
            elif str(BFO) in o_str or "obo/" in o_str:
                desc = f"{s_short} grounded in {o_short} (BFO alignment)"
            else:
                desc = f"{s_short} rdfs:subClassOf {o_short}"
            cross_module.append({
                "subject": s_short,
                "predicate": "rdfs:subClassOf",
                "object": o_short,
                "description": desc,
            })

    # Also check governance file for cross-module axioms pointing into reasoning
    gov_file = REPO_ROOT / "ontology" / "governance" / "ontara-governance.ttl"
    if gov_file.exists():
        g_gov = Graph()
        g_gov.parse(gov_file, format="turtle")
        for s, p, o in g_gov.triples((None, RDFS.subClassOf, None)):
            if not isinstance(s, URIRef) or not isinstance(o, URIRef):
                continue
            if str(ONTARA_RSN) in str(o) and str(ONTARA_GOV) in str(s):
                cross_module.append({
                    "subject": short_iri(s),
                    "predicate": "rdfs:subClassOf",
                    "object": short_iri(o),
                    "description": f"{short_iri(s)} is a subclass of {short_iri(o)} (governance → reasoning alignment)",
                })

    cross_module.sort(key=lambda a: a["subject"])

    return {
        "classes": classes,
        "namedIndividuals": named_individuals,
        "objectProperties": obj_properties,
        "datatypeProperties": dt_properties,
        "crossModuleAxioms": cross_module,
        "moduleSummary": {
            "classCount": len(classes),
            "objectPropertyCount": len(obj_properties),
            "datatypePropertyCount": len(dt_properties),
            "namedIndividualCount": len(named_individuals),
        },
    }


def count_domain_classes():
    """Count OWL classes in Ontara domain ontology files using rdflib.

    Counts classes in ontara-bmm.ttl, ontara-governance.ttl, ontara-domain.ttl,
    and ontara-reasoning.ttl (all Ontara namespace classes, not imports).
    """
    try:
        from rdflib import Graph, URIRef
        from rdflib.namespace import RDF, OWL
    except ImportError:
        return 34  # fallback to old hardcoded value

    ontara_prefixes = [
        "https://ontara.dev/ontology/bmm/",
        "https://ontara.dev/ontology/governance/",
        "https://ontara.dev/ontology/domain/",
        "https://ontara.dev/ontology/reasoning/",
    ]

    domain_files = [
        REPO_ROOT / "generated" / "ontology" / "ontara-bmm.ttl",
        REPO_ROOT / "ontology" / "governance" / "ontara-governance.ttl",
        REPO_ROOT / "ontology" / "domain" / "ontara-domain.ttl",
        REPO_ROOT / "ontology" / "reasoning" / "ontara-reasoning.ttl",
    ]

    all_classes = set()
    for f in domain_files:
        if not f.exists():
            continue
        g = Graph()
        g.parse(f, format="turtle")
        for cls in g.subjects(RDF.type, OWL.Class):
            cls_str = str(cls)
            if any(cls_str.startswith(p) for p in ontara_prefixes):
                all_classes.add(cls_str)

    return len(all_classes) if all_classes else 34


def count_reified_weights():
    """Count reified weighted relationship individuals in ontara-bmm-weights.ttl."""
    weights_file = REPO_ROOT / "generated" / "ontology" / "ontara-bmm-weights.ttl"
    if not weights_file.exists():
        return 96  # fallback

    try:
        from rdflib import Graph
        from rdflib.namespace import RDF, OWL
    except ImportError:
        return 96

    g = Graph()
    g.parse(weights_file, format="turtle")
    return sum(1 for _ in g.subjects(RDF.type, OWL.NamedIndividual))


def count_sparql_queries():
    """Count SPARQL validation queries in validate_kg.py by scanning QUERIES list."""
    validate_file = REPO_ROOT / "scripts" / "validate_kg.py"
    if not validate_file.exists():
        return 0
    content = validate_file.read_text(encoding="utf-8")
    # Count entries in the QUERIES list — each query is a dict with "name" key
    return content.count('"name":')


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

    # Use XML catalog for local IRI resolution (avoids network fetch)
    if CATALOG_FILE.exists():
        args.extend(["--catalog", str(CATALOG_FILE)])

    for entry in ONTOLOGY_FILES:
        if not entry["file"].exists():
            if entry["required"]:
                print(f"  ERROR: Required file missing: {entry['name']}")
                return False, [], "Missing required file"
            else:
                print(f"  Skipping optional: {entry['name']}")
                continue
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

        # Use XML catalog for local IRI resolution
        if CATALOG_FILE.exists():
            args.extend(["--catalog", str(CATALOG_FILE)])

        for entry in ONTOLOGY_FILES:
            if not entry["file"].exists():
                continue
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
    parser.add_argument(
        "--save-summary", action="store_true",
        help="Save a reasoning summary JSON to generated/ontara/reasoning-summary.json",
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

    if args.save_summary:
        object_props = extract_object_properties()
        reasoning_vocab = extract_reasoning_vocabulary()
        domain_class_count = count_domain_classes()
        reified_weight_count = count_reified_weights()
        sparql_query_count = count_sparql_queries()

        summary = {
            "generatedAt": datetime.now().isoformat(),
            "generator": "reason_kg.py",
            "reasoner": "HermiT (via Robot)",
            "consistent": consistent,
            "unsatisfiableClasses": unsatisfiable,
            "ontologyStack": [
                {
                    "name": entry["name"],
                    "file": entry["file"].name,
                    "sizeBytes": entry["file"].stat().st_size if entry["file"].exists() else 0,
                    "present": entry["file"].exists(),
                }
                for entry in ONTOLOGY_FILES
            ],
            "objectProperties": object_props,
            "stats": {
                "ontologyFileCount": sum(1 for e in ONTOLOGY_FILES if e["file"].exists()),
                "objectPropertyCount": len(object_props),
                "reifiedWeightCount": reified_weight_count,
                "domainClassCount": domain_class_count,
                "axiomFilePresent": (REPO_ROOT / "ontology" / "axioms" / "ontara-bmm-axioms.ttl").exists(),
                "namedIndividualCount": reasoning_vocab["moduleSummary"]["namedIndividualCount"] if reasoning_vocab else 0,
                "datatypePropertyCount": reasoning_vocab["moduleSummary"]["datatypePropertyCount"] if reasoning_vocab else 0,
                "sparqlQueryCount": sparql_query_count,
            },
            "violationTest": {
                "ran": args.test_violation,
                "passed": test_result,
            },
        }

        if reasoning_vocab:
            summary["reasoningVocabulary"] = reasoning_vocab

        summary_path = REPO_ROOT / "generated" / "ontara" / "reasoning-summary.json"
        summary_path.parent.mkdir(parents=True, exist_ok=True)
        summary_path.write_text(json.dumps(summary, indent=2, default=str), encoding="utf-8")
        print(f"\nSummary saved: {summary_path}", file=sys.stderr)

    sys.exit(0 if overall else 1)


if __name__ == "__main__":
    main()
