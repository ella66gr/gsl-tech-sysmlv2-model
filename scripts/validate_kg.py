#!/usr/bin/env python3
"""
Knowledge Graph Validation Suite
=================================

Loads pipeline-generated OWL/Turtle into GraphDB and validates
correctness with a SPARQL query suite.

Part of Stage 5 Phase 1 — Step 5.

Prerequisites:
  - GraphDB Free running on localhost:7200
  - Repository 'ontara-dev' exists with BFO/CCO/IAO loaded
    (see setup_graphdb.py)
  - Pipeline has been run: python3 scripts/gen_owl_pipeline.py --save

Usage:
    python3 scripts/validate_kg.py                # Validate only
    python3 scripts/validate_kg.py --load          # Load + validate
    python3 scripts/validate_kg.py --load-only     # Load only
    python3 scripts/validate_kg.py --verbose        # Show all result rows

Source: Stage 5 Phase 1 — Step 5 (Session 106)
"""

import argparse
import json
import pathlib
import sys
import urllib.error
import urllib.parse
import urllib.request

# ---------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------

GRAPHDB_BASE = "http://localhost:7200"
REPO_ID = "ontara-dev"
REPO_ROOT = pathlib.Path(__file__).parent.parent

GENERATED_ONTOLOGY_DIR = REPO_ROOT / "generated" / "ontology"

# Files to load and their target named graphs
PIPELINE_FILES = [
    {
        "file": "ontara-bmm.ttl",
        "name": "Ontara BMM (pipeline)",
        "graph": "https://ontara.dev/graph/domain",
        "content_type": "text/turtle",
    },
    {
        "file": "ontara-correspondence.ttl",
        "name": "Ontara Correspondence (pipeline)",
        "graph": "https://ontara.dev/graph/correspondence",
        "content_type": "text/turtle",
    },
]

# ---------------------------------------------------------------
# Validation query suite
# ---------------------------------------------------------------

VALIDATION_QUERIES = [
    # --- Group 1: Structural ---
    {
        "id": "Q1",
        "group": "Structural",
        "name": "All BMM classes and declared parent",
        "sparql": """
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?class ?label ?parent WHERE {
  GRAPH <https://ontara.dev/graph/domain> {
    ?class a owl:Class ;
           rdfs:label ?label ;
           rdfs:subClassOf ?parent .
    FILTER(STRSTARTS(STR(?class), "https://ontara.dev/ontology/bmm/"))
  }
}
ORDER BY ?label
""",
        "expect_exactly": 34,
        "display_vars": ["class", "label", "parent"],
    },
    {
        "id": "Q2",
        "group": "Structural",
        "name": "BMM classes under BFO:Role",
        "sparql": """
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?class ?label WHERE {
  ?class a owl:Class ;
         rdfs:label ?label ;
         rdfs:subClassOf <http://purl.obolibrary.org/obo/BFO_0000023> .
  FILTER(STRSTARTS(STR(?class), "https://ontara.dev/ontology/bmm/"))
}
ORDER BY ?label
""",
        "expect_exactly": 2,
        "display_vars": ["class", "label"],
    },
    {
        "id": "Q3",
        "group": "Structural",
        "name": "BMM classes with CCO mid-level parent",
        "sparql": """
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?class ?label ?parent WHERE {
  ?class a owl:Class ;
         rdfs:label ?label ;
         rdfs:subClassOf ?parent .
  FILTER(STRSTARTS(STR(?class), "https://ontara.dev/ontology/bmm/"))
  FILTER(STRSTARTS(STR(?parent), "https://www.commoncoreontologies.org/"))
}
ORDER BY ?label
""",
        "expect_exactly": 4,
        "display_vars": ["class", "label", "parent"],
    },
    {
        "id": "Q4",
        "group": "Structural",
        "name": "BMM classes with complete annotations",
        "sparql": """
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT DISTINCT ?class ?label WHERE {
  GRAPH <https://ontara.dev/graph/domain> {
    ?class a owl:Class ;
           rdfs:label ?label ;
           rdfs:comment ?comment ;
           skos:definition ?defn .
    FILTER(STRSTARTS(STR(?class), "https://ontara.dev/ontology/bmm/"))
  }
}
ORDER BY ?label
""",
        "expect_exactly": 34,
        "display_vars": ["class", "label"],
    },
    # --- Group 2: Correspondence ---
    {
        "id": "Q5",
        "group": "Correspondence",
        "name": "All mapping records",
        "sparql": """
SELECT ?record ?sysmlName ?owlEntity ?classification WHERE {
  ?record a <https://ontara.dev/ontology/correspondence/MappingRecord> ;
          <https://ontara.dev/ontology/correspondence/sysmlElementName> ?sysmlName ;
          <https://ontara.dev/ontology/correspondence/owlEntity> ?owlEntity ;
          <https://ontara.dev/ontology/correspondence/classification> ?classification .
}
ORDER BY ?sysmlName
""",
        "expect_exactly": 34,
        "display_vars": ["sysmlName", "owlEntity", "classification"],
    },
    {
        "id": "Q6",
        "group": "Correspondence",
        "name": "Correspondence completeness (no orphan BMM classes)",
        "sparql": """
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?class ?label WHERE {
  GRAPH <https://ontara.dev/graph/domain> {
    ?class a owl:Class ;
           rdfs:label ?label .
    FILTER(STRSTARTS(STR(?class), "https://ontara.dev/ontology/bmm/"))
  }
  FILTER NOT EXISTS {
    GRAPH <https://ontara.dev/graph/correspondence> {
      ?record <https://ontara.dev/ontology/correspondence/owlEntity> ?class .
    }
  }
}
""",
        "expect_exactly": 0,
        "display_vars": ["class", "label"],
        "zero_is_pass": True,
    },
    {
        "id": "Q7",
        "group": "Correspondence",
        "name": "Specific lookup: CustomerSegment",
        "sparql": """
SELECT ?sysmlName ?sourceFile ?lineNum WHERE {
  ?record <https://ontara.dev/ontology/correspondence/owlEntity>
          <https://ontara.dev/ontology/bmm/CustomerSegment> ;
          <https://ontara.dev/ontology/correspondence/sysmlElementName> ?sysmlName ;
          <https://ontara.dev/ontology/correspondence/sysmlSourceFile> ?sourceFile ;
          <https://ontara.dev/ontology/correspondence/sysmlLineNumber> ?lineNum .
}
""",
        "expect_exactly": 1,
        "display_vars": ["sysmlName", "sourceFile", "lineNum"],
        "extra_check": lambda rows: (
            rows[0].get("sysmlName", {}).get("value") == "CustomerSegment"
            and rows[0].get("sourceFile", {}).get("value") == "model/business-model.sysml"
        ) if rows else False,
        "extra_check_desc": "sysmlName=CustomerSegment, sourceFile=model/business-model.sysml",
    },
    # --- Group 3: Inference ---
    {
        "id": "Q8",
        "group": "Inference",
        "name": "BMM classes that are BFO:Continuant (inferred)",
        "sparql": """
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?class ?label WHERE {
  ?class a owl:Class ;
         rdfs:label ?label ;
         rdfs:subClassOf+ <http://purl.obolibrary.org/obo/BFO_0000002> .
  FILTER(STRSTARTS(STR(?class), "https://ontara.dev/ontology/bmm/"))
}
ORDER BY ?label
""",
        "sparql_fallback": """
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?class ?label WHERE {
  ?class a owl:Class ;
         rdfs:label ?label ;
         rdfs:subClassOf <http://purl.obolibrary.org/obo/BFO_0000002> .
  FILTER(STRSTARTS(STR(?class), "https://ontara.dev/ontology/bmm/"))
}
ORDER BY ?label
""",
        "expect_at_least": 30,
        "ideal": 34,
        "display_vars": ["class", "label"],
        "soft": True,
    },
    {
        "id": "Q9",
        "group": "Inference",
        "name": "BMM classes that are BFO:Occurrent (inferred)",
        "sparql": """
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?class ?label WHERE {
  ?class a owl:Class ;
         rdfs:label ?label ;
         rdfs:subClassOf+ <http://purl.obolibrary.org/obo/BFO_0000003> .
  FILTER(STRSTARTS(STR(?class), "https://ontara.dev/ontology/bmm/"))
}
ORDER BY ?label
""",
        "sparql_fallback": """
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?class ?label WHERE {
  ?class a owl:Class ;
         rdfs:label ?label ;
         rdfs:subClassOf <http://purl.obolibrary.org/obo/BFO_0000003> .
  FILTER(STRSTARTS(STR(?class), "https://ontara.dev/ontology/bmm/"))
}
ORDER BY ?label
""",
        "expect_exactly": 0,
        "display_vars": ["class", "label"],
        "zero_is_pass": True,
    },
    # --- Group 4: Graph-level ---
    {
        "id": "Q10",
        "group": "Graph-level",
        "name": "Named graph triple counts",
        "sparql": """
SELECT ?graph (COUNT(*) AS ?triples) WHERE {
  GRAPH ?graph { ?s ?p ?o }
}
GROUP BY ?graph
ORDER BY ?graph
""",
        "expect_at_least_graphs": 2,
        "required_graphs": [
            "https://ontara.dev/graph/domain",
            "https://ontara.dev/graph/correspondence",
        ],
        "display_vars": ["graph", "triples"],
    },
    # --- Group 5: Governance Vocabulary ---
    {
        "id": "Q11",
        "group": "Governance",
        "name": "All governance classes with labels",
        "sparql": """
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ontara-gov: <https://ontara.dev/ontology/governance/>

SELECT ?class ?label ?parent WHERE {
  ?class a owl:Class ;
         rdfs:label ?label .
  OPTIONAL { ?class rdfs:subClassOf ?parent .
             FILTER(isIRI(?parent)) }
  FILTER(STRSTARTS(STR(?class), STR(ontara-gov:)))
}
ORDER BY ?label
""",
        "expect_at_least": 19,
        "display_vars": ["class", "label", "parent"],
    },
    {
        "id": "Q12",
        "group": "Governance",
        "name": "Governance enumeration individuals",
        "sparql": """
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ontara-gov: <https://ontara.dev/ontology/governance/>

SELECT ?ind ?label WHERE {
  ?ind a owl:NamedIndividual ;
       rdfs:label ?label .
  FILTER(STRSTARTS(STR(?ind), STR(ontara-gov:)))
}
ORDER BY ?ind
""",
        "expect_at_least": 24,
        "display_vars": ["ind", "label"],
    },
    {
        "id": "Q13",
        "group": "Governance",
        "name": "Governance object properties with domain and range",
        "sparql": """
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ontara-gov-ax: <https://ontara.dev/ontology/governance/axioms#>

SELECT ?prop ?label ?domain ?range WHERE {
  ?prop a owl:ObjectProperty ;
        rdfs:label ?label .
  OPTIONAL { ?prop rdfs:domain ?domain }
  OPTIONAL { ?prop rdfs:range ?range }
  FILTER(STRSTARTS(STR(?prop), STR(ontara-gov-ax:)))
}
ORDER BY ?label
""",
        "expect_exactly": 20,
        "display_vars": ["prop", "label", "domain", "range"],
    },
    {
        "id": "Q14",
        "group": "Governance",
        "name": "Governance data properties with domain and range",
        "sparql": """
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ontara-gov-ax: <https://ontara.dev/ontology/governance/axioms#>

SELECT ?prop ?label ?domain ?range WHERE {
  ?prop a owl:DatatypeProperty ;
        rdfs:label ?label .
  OPTIONAL { ?prop rdfs:domain ?domain }
  OPTIONAL { ?prop rdfs:range ?range }
  FILTER(STRSTARTS(STR(?prop), STR(ontara-gov-ax:)))
}
ORDER BY ?label
""",
        "expect_exactly": 16,
        "display_vars": ["prop", "label", "domain", "range"],
    },
    {
        "id": "Q15",
        "group": "Governance",
        "name": "DeonticDirective subclasses grounded in IAO",
        "sparql": """
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ontara-gov: <https://ontara.dev/ontology/governance/>

SELECT ?class ?label WHERE {
  ?class rdfs:subClassOf ontara-gov:DeonticDirective ;
         rdfs:label ?label .
  FILTER(?class != ontara-gov:DeonticDirective)
}
ORDER BY ?label
""",
        "expect_exactly": 4,
        "display_vars": ["class", "label"],
    },
    {
        "id": "Q16",
        "group": "Governance",
        "name": "NormativeInstrument subclasses (11 types)",
        "sparql": """
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ontara-gov: <https://ontara.dev/ontology/governance/>

SELECT ?class ?label WHERE {
  ?class rdfs:subClassOf ontara-gov:NormativeInstrument ;
         rdfs:label ?label .
  FILTER(?class != ontara-gov:NormativeInstrument)
}
ORDER BY ?label
""",
        "expect_exactly": 11,
        "display_vars": ["class", "label"],
    },
]


# ---------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------

def graphdb_request(path, method="GET", data=None, content_type=None,
                    accept="application/json"):
    """Make a request to the GraphDB REST API."""
    url = f"{GRAPHDB_BASE}{path}"
    headers = {"Accept": accept}
    if content_type:
        headers["Content-Type"] = content_type

    if data is not None:
        if isinstance(data, str):
            data = data.encode("utf-8")
        req = urllib.request.Request(url, data=data, headers=headers, method=method)
    else:
        req = urllib.request.Request(url, headers=headers, method=method)

    try:
        with urllib.request.urlopen(req) as resp:
            body = resp.read().decode("utf-8")
            if accept == "application/json" and body.strip():
                return json.loads(body)
            return body
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8") if e.fp else ""
        print(f"  HTTP {e.code}: {body[:500]}")
        raise
    except urllib.error.URLError as e:
        print(f"  Connection error: {e.reason}")
        print(f"  Is GraphDB running on {GRAPHDB_BASE}?")
        sys.exit(1)


def sparql_query(sparql):
    """Run a SPARQL SELECT query; return list of binding dicts."""
    encoded = urllib.parse.quote(sparql)
    result = graphdb_request(
        f"/repositories/{REPO_ID}?query={encoded}",
        accept="application/sparql-results+json",
    )
    if isinstance(result, str):
        result = json.loads(result)
    return result.get("results", {}).get("bindings", [])


def sparql_update(update):
    """Run a SPARQL UPDATE against the statements endpoint."""
    graphdb_request(
        f"/repositories/{REPO_ID}/statements",
        method="POST",
        data=update,
        content_type="application/sparql-update",
        accept="text/plain",
    )


def shorten(iri):
    """Return a compact curie-style label for display."""
    prefixes = {
        "https://ontara.dev/ontology/bmm/": "ontara-bmm:",
        "https://ontara.dev/ontology/correspondence/": "corr:",
        "https://ontara.dev/graph/": "graph:",
        "http://purl.obolibrary.org/obo/": "obo:",
        "https://www.commoncoreontologies.org/": "cco:",
        "http://www.w3.org/2000/01/rdf-schema#": "rdfs:",
        "http://www.w3.org/2002/07/owl#": "owl:",
    }
    for prefix, curie in prefixes.items():
        if iri.startswith(prefix):
            return curie + iri[len(prefix):]
    return iri


def format_row(row, display_vars):
    """Format a binding row for display."""
    parts = []
    for var in display_vars:
        if var in row:
            val = row[var].get("value", "")
            if row[var].get("type") == "uri":
                val = shorten(val)
            parts.append(f"{var}={val}")
    return "  " + " | ".join(parts)


def graph_triple_count(graph_iri):
    """Return the triple count for a named graph."""
    sparql = f"""
SELECT (COUNT(*) AS ?count) WHERE {{
  GRAPH <{graph_iri}> {{ ?s ?p ?o }}
}}
"""
    rows = sparql_query(sparql)
    if rows:
        return int(rows[0].get("count", {}).get("value", 0))
    return 0


# ---------------------------------------------------------------
# Loading
# ---------------------------------------------------------------

def clear_bmm_namespace():
    """Delete triples with subjects in the ontara-bmm: namespace from the domain graph."""
    print("  Clearing ontara-bmm: triples from domain graph...")
    update = """
DELETE {
  GRAPH <https://ontara.dev/graph/domain> {
    ?s ?p ?o .
  }
}
WHERE {
  GRAPH <https://ontara.dev/graph/domain> {
    ?s ?p ?o .
    FILTER(STRSTARTS(STR(?s), "https://ontara.dev/ontology/bmm/"))
  }
}
"""
    sparql_update(update)
    print("  Done.")


def clear_correspondence_graph():
    """Clear the correspondence graph entirely (pipeline-only content)."""
    print("  Clearing correspondence graph...")
    update = "CLEAR GRAPH <https://ontara.dev/graph/correspondence>"
    sparql_update(update)
    print("  Done.")


def load_pipeline_file(entry):
    """Load a pipeline-generated Turtle file into its named graph."""
    filepath = GENERATED_ONTOLOGY_DIR / entry["file"]
    if not filepath.exists():
        print(f"  ERROR: {filepath} not found. Run gen_owl_pipeline.py --save first.")
        return False

    file_size = filepath.stat().st_size
    print(f"  Loading {entry['name']} ({entry['file']}, {file_size:,} bytes) "
          f"into <{entry['graph']}>...")

    data = filepath.read_bytes()
    graph_encoded = urllib.parse.quote(entry["graph"], safe="")
    path = f"/repositories/{REPO_ID}/statements?context=%3C{graph_encoded}%3E"

    try:
        graphdb_request(
            path,
            method="POST",
            data=data,
            content_type=entry["content_type"],
            accept="text/plain",
        )
        count = graph_triple_count(entry["graph"])
        print(f"  Loaded. Graph now has {count:,} triples.")
        return True
    except urllib.error.HTTPError:
        print(f"  Failed to load {entry['name']}.")
        return False


def load_pipeline_output():
    """Clear old pipeline data and reload from generated files."""
    print(f"\nLoading pipeline output into GraphDB ({REPO_ID})...")

    # Step 1: clear BMM namespace triples from domain graph
    clear_bmm_namespace()

    # Step 2: clear correspondence graph
    clear_correspondence_graph()

    # Step 3: load each pipeline file
    results = []
    for entry in PIPELINE_FILES:
        ok = load_pipeline_file(entry)
        results.append((entry["name"], ok))

    print("\nLoad summary:")
    for name, ok in results:
        print(f"  [{'OK' if ok else 'FAILED'}] {name}")

    return all(ok for _, ok in results)


# ---------------------------------------------------------------
# Validation
# ---------------------------------------------------------------

def run_query(q, verbose):
    """Execute a single validation query and return (passed, count, rows)."""
    sparql = q["sparql"]
    used_fallback = False

    try:
        rows = sparql_query(sparql)
    except urllib.error.HTTPError as e:
        # Property paths may not be supported — try fallback
        if "sparql_fallback" in q:
            print(f"  (property path failed, using direct subClassOf fallback)")
            used_fallback = True
            try:
                rows = sparql_query(q["sparql_fallback"])
            except Exception as e2:
                print(f"  ERROR — {e2}")
                return False, 0, []
        else:
            print(f"  ERROR — {e}")
            return False, 0, []
    except Exception as e:
        print(f"  ERROR — {e}")
        return False, 0, []

    count = len(rows)

    # Determine pass/fail
    passed = True
    extra_note = ""

    if "expect_exactly" in q:
        expected = q["expect_exactly"]
        if q.get("zero_is_pass"):
            passed = (count == 0)
        else:
            passed = (count == expected)
        extra_note = f"expected: {expected}"

    elif "expect_at_least" in q:
        passed = (count >= q["expect_at_least"])
        ideal = q.get("ideal", q["expect_at_least"])
        extra_note = f"threshold: {q['expect_at_least']}, ideal: {ideal}"
        if passed and count < ideal:
            extra_note += f" — {ideal - count} classes below ideal (diagnostic)"

    elif "expect_at_least_graphs" in q:
        # Q10: check specific graphs are present with non-zero triples
        graph_counts = {
            row["graph"]["value"]: int(row["triples"]["value"])
            for row in rows
            if "graph" in row and "triples" in row
        }
        for g in q.get("required_graphs", []):
            if graph_counts.get(g, 0) == 0:
                passed = False
                extra_note += f" MISSING or empty: {shorten(g)}"
        if not extra_note:
            extra_note = f"graphs present: {count}"

    # Extra semantic check (Q7)
    if passed and "extra_check" in q and rows:
        if not q["extra_check"](rows):
            passed = False
            extra_note += f" | content check failed: {q['extra_check_desc']}"

    # Print result line
    if passed:
        print(f"  PASS — {count} result(s) ({extra_note})")
        if used_fallback:
            print(f"  (Note: used direct subClassOf — property paths not materialised)")
    else:
        print(f"  FAIL — {count} result(s) ({extra_note})")

    # Print sample rows
    display_vars = q.get("display_vars", [])
    limit = None if verbose else 5
    sample = rows if limit is None else rows[:limit]

    for row in sample:
        print(format_row(row, display_vars))

    if not verbose and len(rows) > 5:
        print(f"  ... ({len(rows) - 5} more rows — use --verbose to show all)")

    # Diagnostic: for Q8, show missing classes if below ideal
    if q["id"] == "Q8" and passed and count < q.get("ideal", 34):
        print(f"  Diagnostic: {q['ideal'] - count} classes not found in Continuant chain:")
        found = {row.get("class", {}).get("value") for row in rows}
        # We'd need all 34 to diff — just note the count
        print(f"  (Run with --verbose and compare to Q1 results to identify missing classes)")

    return passed, count, rows


def run_validation(verbose=False):
    """Run all 10 validation queries and print a summary."""
    print(f"\nRunning validation suite against '{REPO_ID}'...\n")

    groups = {}
    results = {}

    for q in VALIDATION_QUERIES:
        print(f"[{q['id']}] {q['name']}")
        passed, count, rows = run_query(q, verbose)
        print()

        group = q["group"]
        groups.setdefault(group, {"passed": 0, "total": 0, "notes": []})
        groups[group]["total"] += 1
        if passed:
            groups[group]["passed"] += 1
        results[q["id"]] = (passed, count)

    # Summary
    print("=== VALIDATION SUMMARY ===")
    total_passed = 0
    total_queries = 0

    for group_name, stats in groups.items():
        p = stats["passed"]
        t = stats["total"]
        total_passed += p
        total_queries += t

        # Extra note for Q8
        if group_name == "Inference" and "Q8" in results:
            q8_passed, q8_count = results["Q8"]
            ideal = next(q.get("ideal", 34) for q in VALIDATION_QUERIES if q["id"] == "Q8")
            note = f"Q8: {q8_count}/{ideal} Continuant"
            if q8_count == ideal:
                note += " — full chain"
            else:
                note += " — partial chain (diagnostic)"
            print(f"  {group_name + ':':<16} {p}/{t} passed ({note})")
        else:
            print(f"  {group_name + ':':<16} {p}/{t} passed")

    overall = "PASSED" if total_passed == total_queries else "FAILED"
    print(f"  {'OVERALL:':<16} {total_passed}/{total_queries} {overall}")

    return total_passed == total_queries


# ---------------------------------------------------------------
# Main
# ---------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Load and validate the Ontara knowledge graph."
    )
    parser.add_argument(
        "--load",
        action="store_true",
        help="Clear pipeline graphs, reload pipeline output, then validate",
    )
    parser.add_argument(
        "--load-only",
        action="store_true",
        help="Clear pipeline graphs and reload, skip validation",
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Show all query result rows (not just first 5)",
    )
    args = parser.parse_args()

    print(f"Ontara KG Validation Suite ({GRAPHDB_BASE})")
    print(f"Repository: {REPO_ID}")
    print(f"Generated ontology dir: {GENERATED_ONTOLOGY_DIR}")

    # Check GraphDB is reachable
    try:
        graphdb_request("/rest/repositories")
    except SystemExit:
        return

    if args.load or args.load_only:
        ok = load_pipeline_output()
        if not ok:
            print("\nLoading failed — aborting.")
            sys.exit(1)

    if args.load_only:
        print("\nLoad complete (--load-only, skipping validation).")
        return

    passed = run_validation(verbose=args.verbose)
    sys.exit(0 if passed else 1)


if __name__ == "__main__":
    main()
