#!/usr/bin/env python3
"""
Ontara OWL Pipeline Generator — gen_owl_pipeline.py
=====================================================

Pipeline generator that reads SysML v2 model files, classifies elements
via declarative mapping rules, and produces OWL/Turtle ontology output
using rdflib.

Pipeline stages:
  Stage 1 — Parse: Read .sysml files via the shared parser (sysml_parser.py)
  Stage 2 — Classify: Apply mapping-rules.yaml to categorise each element
  Stage 3 — Generate: Emit OWL/Turtle for classified elements using rdflib

Phase 1 scope: DomainClass + StructuralOnly classifications only.
Produces output semantically identical to the Session 102 gen_ontara_bmm.py
(validated by graph isomorphism).

Design decisions:
  S105-D2: Phase 1 scope — DomainClass + StructuralOnly only
  S105-D3: Rules engine — load YAML, evaluate declaratively
  S105-D4: IRI lookup tables self-contained in this generator
  S105-D5: Graph isomorphism for regression validation
  S105-D6: Three outputs — ontara-bmm.ttl, ontara-correspondence.ttl, mapping-ir.json

Usage:
    python scripts/gen_owl_pipeline.py                # Generate + print summary
    python scripts/gen_owl_pipeline.py --save         # Generate + save to generated/ontology/
    python scripts/gen_owl_pipeline.py --dry-run      # Print Turtle to stdout
    python scripts/gen_owl_pipeline.py --validate     # Compare pipeline output to baseline
    python scripts/gen_owl_pipeline.py --resolve-cco  # Populate CCO IRI lookup from GraphDB
    python scripts/gen_owl_pipeline.py --verify       # Check CCO lookup completeness

Source: Stage 5 Phase 1 — Step 4 (Session 105)
Depends on: sysml_parser.py (Session 104), mapping-rules.yaml, cco-iri-lookup.json
"""

import argparse
import hashlib
import json
import pathlib
import sys
import urllib.request
import urllib.error
import urllib.parse
from datetime import datetime, timezone

import yaml
from rdflib import Graph, Namespace, Literal, URIRef, BNode
from rdflib.namespace import RDF, RDFS, OWL, XSD, SKOS
from rdflib.compare import isomorphic

from sysml_parser import parse_sysml_file

# ---------------------------------------------------------------
# Path constants
# ---------------------------------------------------------------

REPO_ROOT = pathlib.Path(__file__).parent.parent
MODEL_DIR = REPO_ROOT / "model"
EXERCISES_DIR = REPO_ROOT / "exercises"
CONFIG_DIR = REPO_ROOT / "ontology" / "config"
OUTPUT_DIR = REPO_ROOT / "generated" / "ontology"
MAPPING_RULES_FILE = CONFIG_DIR / "mapping-rules.yaml"
CCO_LOOKUP_FILE = CONFIG_DIR / "cco-iri-lookup.json"

GRAPHDB_BASE = "http://localhost:7200"
REPO_ID = "ontara-dev"

# ---------------------------------------------------------------
# Domain source configuration
# ---------------------------------------------------------------

# Domain directories — same as gen_model_introspection.py
DOMAIN_SOURCES = {
    "core": {"model_dirs": [MODEL_DIR]},
    "cafe": {"model_dirs": [EXERCISES_DIR / "coffeeshop-demonstrator" / "model"]},
    "suds": {"model_dirs": [EXERCISES_DIR / "suds-demonstrator" / "model"]},
    "paws": {"model_dirs": [EXERCISES_DIR / "paws-demonstrator" / "model"]},
}

EXCLUDE_PATTERNS = ["test-", "spike-"]

# ---------------------------------------------------------------
# IRI Lookup tables (copied verbatim from gen_ontara_bmm.py)
# ---------------------------------------------------------------

BFO_NS = "http://purl.obolibrary.org/obo/"
IAO_NS = "http://purl.obolibrary.org/obo/"

BFO_IRI_LOOKUP = {
    # Top-level
    "Entity": f"{BFO_NS}BFO_0000001",
    "Continuant": f"{BFO_NS}BFO_0000002",
    "Occurrent": f"{BFO_NS}BFO_0000003",
    # Independent continuant
    "IndependentContinuant": f"{BFO_NS}BFO_0000004",
    "MaterialEntity": f"{BFO_NS}BFO_0000040",
    "ObjectAggregate": f"{BFO_NS}BFO_0000027",
    "FiatObjectPart": f"{BFO_NS}BFO_0000024",
    "Object": f"{BFO_NS}BFO_0000030",
    "Site": f"{BFO_NS}BFO_0000029",
    # Specifically dependent continuant
    "SpecificallyDependentContinuant": f"{BFO_NS}BFO_0000020",
    "Quality": f"{BFO_NS}BFO_0000019",
    "RealizableEntity": f"{BFO_NS}BFO_0000017",
    "Role": f"{BFO_NS}BFO_0000023",
    "Disposition": f"{BFO_NS}BFO_0000016",
    "Function": f"{BFO_NS}BFO_0000034",
    # Generically dependent continuant
    "GenericallyDependentContinuant": f"{BFO_NS}BFO_0000031",
    # Occurrents
    "Process": f"{BFO_NS}BFO_0000015",
    "ProcessBoundary": f"{BFO_NS}BFO_0000035",
    "TemporalRegion": f"{BFO_NS}BFO_0000008",
    # Spatial
    "SpatialRegion": f"{BFO_NS}BFO_0000006",
}

IAO_IRI_LOOKUP = {
    "IAO:InformationContentEntity": f"{IAO_NS}IAO_0000030",
    "IAO:PlanSpecification": f"{IAO_NS}IAO_0000104",
    "IAO:ObjectiveSpecification": f"{IAO_NS}IAO_0000005",
    "IAO:MeasurementDatum": f"{IAO_NS}IAO_0000109",
}

CCO_CLASSES_NEEDED = [
    "CCO:GroupOfAgents",
    "CCO:ArtifactFunction",
    "CCO:Agent",
]

CCO_LABEL_MAP = {
    "CCO:GroupOfAgents": "Group of Agents",
    "CCO:ArtifactFunction": "Artifact Function",
    "CCO:Agent": "Agent",
}

SPARQL_CCO_LOOKUP = """
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX cco: <https://www.commoncoreontologies.org/>

SELECT ?iri ?label WHERE {
    ?iri a owl:Class .
    ?iri rdfs:label ?label .
    FILTER(STRSTARTS(STR(?iri), "https://www.commoncoreontologies.org/"))
    FILTER(?label IN (
        "Group of Agents"@en,
        "Artifact Function"@en,
        "Agent"@en
    ))
}
ORDER BY ?label
"""


def load_cco_lookup():
    """Load the CCO label→IRI lookup from the config file."""
    if not CCO_LOOKUP_FILE.exists():
        return {}
    with open(CCO_LOOKUP_FILE) as f:
        return json.load(f)


def save_cco_lookup(lookup):
    """Save the CCO label→IRI lookup to the config file."""
    CONFIG_DIR.mkdir(parents=True, exist_ok=True)
    with open(CCO_LOOKUP_FILE, "w") as f:
        json.dump(lookup, f, indent=2)
    print(f"CCO lookup saved to {CCO_LOOKUP_FILE}")


def resolve_cco_iris():
    """Query GraphDB to resolve CCO class labels to opaque IRIs."""
    print(f"Querying GraphDB ({GRAPHDB_BASE}) for CCO class IRIs...")

    sparql_encoded = urllib.parse.quote(SPARQL_CCO_LOOKUP)
    url = f"{GRAPHDB_BASE}/repositories/{REPO_ID}?query={sparql_encoded}"

    req = urllib.request.Request(url, headers={"Accept": "application/sparql-results+json"})
    try:
        with urllib.request.urlopen(req) as resp:
            data = json.loads(resp.read().decode("utf-8"))
    except urllib.error.URLError as e:
        print(f"ERROR: Cannot reach GraphDB at {GRAPHDB_BASE}: {e}")
        print("Is GraphDB running?")
        sys.exit(1)

    bindings = data.get("results", {}).get("bindings", [])

    # Build reverse lookup: label → IRI
    label_to_iri = {}
    for row in bindings:
        label = row["label"]["value"]
        iri = row["iri"]["value"]
        label_to_iri[label] = iri
        print(f"  Found: {label} → {iri}")

    # Build our notation → IRI lookup
    lookup = {}
    for notation, label in CCO_LABEL_MAP.items():
        if label in label_to_iri:
            lookup[notation] = label_to_iri[label]
        else:
            print(f"  WARNING: {notation} (label '{label}') not found in GraphDB")

    # Report
    found = len(lookup)
    needed = len(CCO_LABEL_MAP)
    print(f"\nResolved {found}/{needed} CCO classes.")

    if found < needed:
        missing = set(CCO_LABEL_MAP.keys()) - set(lookup.keys())
        print(f"Missing: {missing}")
        print("These classes may use different labels in CCO 2.0.")
        print("Run a broader SPARQL query to investigate.")

    return lookup


def resolve_parent_iri(bfo_class, mid_level_class, cco_lookup):
    """
    Resolve the parent class IRI for rdfs:subClassOf.

    Design decision 2 (Session 102):
      - If midLevelClass is non-empty → use mid-level IRI
      - If midLevelClass is empty → use BFO IRI directly
    """
    if mid_level_class:
        # Try IAO first
        if mid_level_class in IAO_IRI_LOOKUP:
            return IAO_IRI_LOOKUP[mid_level_class]
        # Try CCO
        if mid_level_class in cco_lookup:
            return cco_lookup[mid_level_class]
        # Not resolved
        return None
    else:
        # No mid-level — fall back to BFO
        if bfo_class in BFO_IRI_LOOKUP:
            return BFO_IRI_LOOKUP[bfo_class]
        return None

# ---------------------------------------------------------------
# Mapping rules engine
# ---------------------------------------------------------------

def load_mapping_rules():
    """Load the declarative mapping rules from YAML."""
    with open(MAPPING_RULES_FILE) as f:
        return yaml.safe_load(f)


def classify_element(element, rules):
    """
    Apply mapping rules to a parsed SysML element.
    Returns the classification dict for the first matching rule,
    or None if no rule matches (should not happen — catch-all rule).

    Matching logic:
      - construct: matches element.kind (or "*" for any)
      - package_set: element.parent_package must be in the list
      - has_annotation: "@BfoType" means element.bfo_type must be non-empty;
                        null means element.bfo_type must be empty
    """
    for rule in rules:
        match = rule["match"]

        # Check construct type
        if match.get("construct", "*") != "*":
            if element.kind != match["construct"]:
                continue

        # Check package membership
        if "package_set" in match:
            if element.parent_package not in match["package_set"]:
                continue

        # Check annotation presence
        if "has_annotation" in match:
            ann = match["has_annotation"]
            if ann == "@BfoType" and not element.bfo_type:
                continue
            if ann is None and element.bfo_type:
                continue

        # All conditions passed — this rule matches
        return {
            "classification": rule["classification"],
            "target_graph": rule.get("target_graph"),
            "iri_template": rule.get("iri_template"),
            "notes": rule.get("notes", ""),
        }

    return {"classification": "Unmatched", "target_graph": None}

# ---------------------------------------------------------------
# Pipeline Stage 1 — Parse
# ---------------------------------------------------------------

def stage1_parse():
    """
    Pipeline Stage 1: Parse all SysML files and return elements.
    Uses the shared parser module (sysml_parser.py).
    """
    all_elements = []

    for domain_key, config in DOMAIN_SOURCES.items():
        for model_dir in config["model_dirs"]:
            if not model_dir.exists():
                continue
            for sysml_file in sorted(model_dir.glob("*.sysml")):
                # Skip excluded files
                if any(sysml_file.name.startswith(p) for p in EXCLUDE_PATTERNS):
                    continue
                elements = parse_sysml_file(sysml_file, domain_key, repo_root=REPO_ROOT)
                all_elements.extend(elements)

    return all_elements

# ---------------------------------------------------------------
# Pipeline Stage 2 — Classify
# ---------------------------------------------------------------

def stage2_classify(elements, rules):
    """
    Pipeline Stage 2: Apply classification rules to each element.
    Returns a list of (element, classification_result) tuples
    and a mapping IR dict for serialisation.
    """
    classified = []
    mapping_ir = {
        "version": rules.get("version", "unknown"),
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "session": rules.get("session", "unknown"),
        "summary": {},
        "elements": [],
    }

    category_counts = {}

    for elem in elements:
        result = classify_element(elem, rules["rules"])
        classified.append((elem, result))

        cat = result["classification"]
        category_counts[cat] = category_counts.get(cat, 0) + 1

        # Add to mapping IR
        ir_entry = {
            "name": elem.name,
            "kind": elem.kind,
            "parentPackage": elem.parent_package,
            "sourceFile": elem.source_file,
            "sourceDomain": elem.source_domain,
            "classification": cat,
            "targetGraph": result["target_graph"],
        }
        if result.get("iri_template"):
            ir_entry["iriTemplate"] = result["iri_template"]
        if elem.bfo_type:
            ir_entry["bfoType"] = elem.bfo_type
        mapping_ir["elements"].append(ir_entry)

    mapping_ir["summary"] = category_counts
    return classified, mapping_ir

# ---------------------------------------------------------------
# Namespace constants
# ---------------------------------------------------------------

ONTARA_BMM = Namespace("https://ontara.dev/ontology/bmm/")
ONTARA_CORR = Namespace("https://ontara.dev/ontology/correspondence/")
BFO = Namespace("http://purl.obolibrary.org/obo/")
CCO = Namespace("https://www.commoncoreontologies.org/")
DCTERMS = Namespace("http://purl.org/dc/terms/")

# ---------------------------------------------------------------
# Pipeline Stage 3a — Generate domain ontology
# ---------------------------------------------------------------

def stage3_generate_domain(classified, cco_lookup):
    """
    Pipeline Stage 3a: Generate domain ontology graph (ontara-bmm.ttl).

    For each DomainClass element:
      - Mint IRI: ontara-bmm:{ElementName}
      - Declare owl:Class
      - Add rdfs:subClassOf → resolved parent IRI (mid-level or BFO)
      - Add rdfs:label from @UserFacing.friendlyName
      - Add rdfs:comment from @UserFacing.shortDescription
      - Add skos:definition from @PurposiveDescription.description
    """
    g = Graph()

    # Bind prefixes for clean Turtle output
    g.bind("ontara-bmm", ONTARA_BMM)
    g.bind("bfo", BFO)
    g.bind("cco", CCO)
    g.bind("owl", OWL)
    g.bind("rdfs", RDFS)
    g.bind("skos", SKOS)
    g.bind("xsd", XSD)
    g.bind("dcterms", DCTERMS)

    # Ontology declaration
    ont_uri = URIRef(str(ONTARA_BMM))
    g.add((ont_uri, RDF.type, OWL.Ontology))
    g.add((ont_uri, RDFS.label, Literal("Ontara Business Meta Model", lang="en")))
    g.add((ont_uri, RDFS.comment, Literal(
        "OWL representation of the 34 BMM part defs from the Ontara platform. "
        "Each class is positioned under its BFO 2020 parent via @BfoType annotations.",
        lang="en"
    )))
    g.add((ont_uri, OWL.versionInfo, Literal(
        "Generated by gen_owl_pipeline.py — Session 105", lang="en"
    )))
    g.add((ont_uri, DCTERMS.created, Literal("2026-04-01", datatype=XSD.date)))

    # Class declarations
    domain_class_count = 0
    unresolved = []

    for elem, result in classified:
        if result["classification"] != "DomainClass":
            continue

        domain_class_count += 1
        class_uri = ONTARA_BMM[elem.name]

        # owl:Class
        g.add((class_uri, RDF.type, OWL.Class))

        # rdfs:subClassOf — resolve parent IRI
        bfo_class = elem.bfo_type.get("bfoClass", "")
        mid_level = elem.bfo_type.get("midLevelClass", "")
        parent_iri = resolve_parent_iri(bfo_class, mid_level, cco_lookup)

        if parent_iri:
            g.add((class_uri, RDFS.subClassOf, URIRef(parent_iri)))
        else:
            # Fallback to BFO directly
            bfo_iri = BFO_IRI_LOOKUP.get(bfo_class)
            if bfo_iri:
                g.add((class_uri, RDFS.subClassOf, URIRef(bfo_iri)))
            unresolved.append((elem.name, bfo_class, mid_level))

        # rdfs:label from @UserFacing.friendlyName
        friendly_name = elem.user_facing.get("friendlyName", "")
        if friendly_name:
            g.add((class_uri, RDFS.label, Literal(friendly_name, lang="en")))

        # rdfs:comment from @UserFacing.shortDescription
        short_desc = elem.user_facing.get("shortDescription", "")
        if short_desc:
            g.add((class_uri, RDFS.comment, Literal(short_desc, lang="en")))

        # skos:definition from @PurposiveDescription.description
        purposive = elem.purposive_description.get("description", "")
        if purposive:
            g.add((class_uri, SKOS.definition, Literal(purposive, lang="en")))

    return g, domain_class_count, unresolved

# ---------------------------------------------------------------
# Pipeline Stage 3b — Generate correspondence graph
# ---------------------------------------------------------------

def stage3_generate_correspondence(classified, cco_lookup):
    """
    Pipeline Stage 3b: Generate correspondence graph (ontara-correspondence.ttl).

    For each DomainClass element, record the mapping from SysML to OWL:
      - SysML source file + element name + line number
      - Source content hash (for change detection)
      - OWL entity IRI
      - Classification category
      - Authority zone
      - Generation timestamp
    """
    g = Graph()

    g.bind("ontara-bmm", ONTARA_BMM)
    g.bind("ontara-corr", ONTARA_CORR)
    g.bind("rdfs", RDFS)
    g.bind("xsd", XSD)
    g.bind("dcterms", DCTERMS)

    generation_time = Literal(
        datetime.now(timezone.utc).isoformat(),
        datatype=XSD.dateTime
    )

    for elem, result in classified:
        if result["classification"] != "DomainClass":
            continue

        # Mint a correspondence record URI
        record_uri = ONTARA_CORR[f"map-{elem.name}"]

        g.add((record_uri, RDF.type, ONTARA_CORR["MappingRecord"]))
        g.add((record_uri, ONTARA_CORR["sysmlElementName"],
               Literal(elem.name)))
        g.add((record_uri, ONTARA_CORR["sysmlSourceFile"],
               Literal(elem.source_file)))
        g.add((record_uri, ONTARA_CORR["sysmlLineNumber"],
               Literal(elem.line_number, datatype=XSD.integer)))

        # Content hash for change detection
        content_key = f"{elem.name}|{elem.source_file}|{elem.kind}|{json.dumps(elem.bfo_type, sort_keys=True)}"
        content_hash = hashlib.sha256(content_key.encode()).hexdigest()[:16]
        g.add((record_uri, ONTARA_CORR["sourceHash"],
               Literal(content_hash)))

        # Target OWL entity
        g.add((record_uri, ONTARA_CORR["owlEntity"],
               ONTARA_BMM[elem.name]))

        # Classification
        g.add((record_uri, ONTARA_CORR["classification"],
               Literal(result["classification"])))

        # Authority zone
        g.add((record_uri, ONTARA_CORR["authorityZone"],
               Literal("shared-constrained")))

        # Generation timestamp
        g.add((record_uri, DCTERMS.created, generation_time))

    return g

# ---------------------------------------------------------------
# Validation
# ---------------------------------------------------------------

def validate_against_baseline():
    """
    Compare pipeline-generated ontara-bmm.ttl against the baseline
    using rdflib graph isomorphism.

    Returns True if graphs are semantically identical.
    """
    baseline_path = OUTPUT_DIR / "ontara-bmm-baseline.ttl"
    pipeline_path = OUTPUT_DIR / "ontara-bmm.ttl"

    if not baseline_path.exists():
        print(f"ERROR: Baseline file not found at {baseline_path}")
        print("Run: cp generated/ontology/ontara-bmm.ttl generated/ontology/ontara-bmm-baseline.ttl")
        return False

    if not pipeline_path.exists():
        print(f"ERROR: Pipeline output not found at {pipeline_path}")
        print("Run: python scripts/gen_owl_pipeline.py --save")
        return False

    print("Loading baseline graph...")
    g_baseline = Graph()
    g_baseline.parse(str(baseline_path), format="turtle")
    print(f"  Baseline: {len(g_baseline)} triples")

    print("Loading pipeline graph...")
    g_pipeline = Graph()
    g_pipeline.parse(str(pipeline_path), format="turtle")
    print(f"  Pipeline: {len(g_pipeline)} triples")

    print("Comparing graphs (isomorphism check)...")
    if isomorphic(g_baseline, g_pipeline):
        print("✓ PASS — Graphs are semantically identical")
        return True
    else:
        # Report differences
        print("✗ FAIL — Graphs differ")
        in_baseline_only = g_baseline - g_pipeline
        in_pipeline_only = g_pipeline - g_baseline

        if in_baseline_only:
            print(f"\n  In baseline only ({len(in_baseline_only)} triples):")
            for s, p, o in sorted(in_baseline_only)[:20]:
                print(f"    {s} {p} {o}")

        if in_pipeline_only:
            print(f"\n  In pipeline only ({len(in_pipeline_only)} triples):")
            for s, p, o in sorted(in_pipeline_only)[:20]:
                print(f"    {s} {p} {o}")

        return False

# ---------------------------------------------------------------
# Main
# ---------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Ontara OWL Pipeline Generator (Stage 5 Phase 1 Step 4)"
    )
    parser.add_argument("--save", action="store_true",
                        help="Save outputs to generated/ontology/")
    parser.add_argument("--dry-run", action="store_true",
                        help="Print domain ontology Turtle to stdout")
    parser.add_argument("--validate", action="store_true",
                        help="Compare pipeline output to baseline (graph isomorphism)")
    parser.add_argument("--resolve-cco", action="store_true",
                        help="Query GraphDB to populate CCO IRI lookup")
    parser.add_argument("--verify", action="store_true",
                        help="Check CCO lookup completeness")
    parser.add_argument("--ir-only", action="store_true",
                        help="Run Stages 1–2 only and print mapping IR")
    args = parser.parse_args()

    # --- CCO resolution (migrated from gen_ontara_bmm.py) ---
    if args.resolve_cco:
        lookup = resolve_cco_iris()
        save_cco_lookup(lookup)
        return

    cco_lookup = load_cco_lookup()

    if args.verify:
        ok = True
        for notation in CCO_CLASSES_NEEDED:
            if notation not in cco_lookup:
                print(f"  MISSING: {notation}")
                ok = False
            else:
                print(f"  OK: {notation} → {cco_lookup[notation]}")
        sys.exit(0 if ok else 1)

    # --- Validation mode ---
    if args.validate:
        ok = validate_against_baseline()
        sys.exit(0 if ok else 1)

    # --- Pipeline execution ---
    print("=" * 60)
    print("Ontara OWL Pipeline — Stage 5 Phase 1 Step 4")
    print("=" * 60)

    # Stage 1: Parse
    print("\nStage 1: Parsing SysML files...")
    elements = stage1_parse()
    print(f"  Parsed {len(elements)} elements from {len(DOMAIN_SOURCES)} domains")

    # Stage 2: Classify
    print("\nStage 2: Classifying elements...")
    rules = load_mapping_rules()
    print(f"  Rules version: {rules.get('version', '?')}, {len(rules.get('rules', []))} rules loaded")
    classified, mapping_ir = stage2_classify(elements, rules)

    # Print classification summary
    print(f"\n  Classification summary:")
    for cat, count in sorted(mapping_ir["summary"].items()):
        print(f"    {cat}: {count}")

    if args.ir_only:
        print(json.dumps(mapping_ir, indent=2))
        return

    # Stage 3: Generate OWL
    print("\nStage 3: Generating OWL/Turtle...")

    # 3a: Domain ontology
    domain_graph, class_count, unresolved = stage3_generate_domain(classified, cco_lookup)
    print(f"  Domain graph: {len(domain_graph)} triples, {class_count} OWL classes")

    if unresolved:
        print(f"  Unresolved parent IRIs ({len(unresolved)}):")
        for name, bfo, mid in unresolved:
            if mid:
                print(f"    {name}: mid-level '{mid}' not in lookup — fallback to BFO:{bfo}")
            else:
                print(f"    {name}: no mid-level — using BFO:{bfo} directly")

    # 3b: Correspondence graph
    corr_graph = stage3_generate_correspondence(classified, cco_lookup)
    print(f"  Correspondence graph: {len(corr_graph)} triples")

    # --- Output ---
    if args.dry_run:
        print("\n--- Domain ontology (Turtle) ---\n")
        print(domain_graph.serialize(format="turtle"))
        return

    if args.save:
        OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

        # Domain ontology
        domain_path = OUTPUT_DIR / "ontara-bmm.ttl"
        domain_graph.serialize(str(domain_path), format="turtle")
        print(f"\n  Saved: {domain_path} ({domain_path.stat().st_size:,} bytes)")

        # Correspondence graph
        corr_path = OUTPUT_DIR / "ontara-correspondence.ttl"
        corr_graph.serialize(str(corr_path), format="turtle")
        print(f"  Saved: {corr_path} ({corr_path.stat().st_size:,} bytes)")

        # Mapping IR
        ir_path = OUTPUT_DIR / "mapping-ir.json"
        with open(ir_path, "w") as f:
            json.dump(mapping_ir, f, indent=2)
        print(f"  Saved: {ir_path} ({ir_path.stat().st_size:,} bytes)")

        print(f"\nPipeline complete. {class_count} domain classes generated.")

        if (OUTPUT_DIR / "ontara-bmm-baseline.ttl").exists():
            print("\nRun validation: python scripts/gen_owl_pipeline.py --validate")
    else:
        # Default: just print summary without saving
        print(f"\nPipeline summary: {class_count} domain classes, "
              f"{len(corr_graph)} correspondence triples. "
              f"Use --save to write files.")


if __name__ == "__main__":
    main()
