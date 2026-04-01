#!/usr/bin/env python3
"""
GraphDB Repository Setup and Ontology Loading
===============================================

Creates the `ontara-dev` repository in GraphDB Free and loads the
imported ontology stack (BFO 2020, CCO, IAO) in the correct order.

Prerequisites:
  - GraphDB Free running on localhost:7200
  - Ontology files downloaded to ontology/imports/
    (see ontology/imports/README.md for download commands)

Usage:
    python scripts/setup_graphdb.py              # Create repo + load ontologies
    python scripts/setup_graphdb.py --verify     # Run verification queries only
    python scripts/setup_graphdb.py --drop       # Drop and recreate the repo

Source: Stage 5 Phase 1 — Step 1 (Session 101)
"""

import argparse
import json
import sys
import pathlib
import urllib.request
import urllib.error
import urllib.parse
import uuid

# ---------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------

GRAPHDB_BASE = "http://localhost:7200"
REPO_ID = "ontara-dev"
REPO_ROOT = pathlib.Path(__file__).parent.parent
IMPORTS_DIR = REPO_ROOT / "ontology" / "imports"

# Named graphs per the three-stratum architecture (B28)
NAMED_GRAPHS = {
    "metamodel": "https://ontara.dev/graph/metamodel",
    "domain": "https://ontara.dev/graph/domain",
    "correspondence": "https://ontara.dev/graph/correspondence",
}

# Ontology files in import order (dependencies first)
ONTOLOGY_STACK = [
    {
        "file": "bfo-core.owl",
        "name": "BFO 2020",
        "graph": NAMED_GRAPHS["domain"],
        "content_type": "application/rdf+xml",
    },
    {
        "file": "CommonCoreOntologiesMerged.ttl",
        "name": "CCO (Merged)",
        "graph": NAMED_GRAPHS["domain"],
        "content_type": "text/turtle",
    },
    {
        "file": "iao.owl",
        "name": "IAO",
        "graph": NAMED_GRAPHS["domain"],
        "content_type": "application/rdf+xml",
    },
]

# Verification SPARQL queries
VERIFICATION_QUERIES = [
    {
        "name": "BFO Continuant subclasses",
        "description": "Direct subclasses of BFO:Continuant — confirms BFO loaded",
        "sparql": """
            PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
            PREFIX bfo: <http://purl.obolibrary.org/obo/>
            SELECT ?class ?label WHERE {
                ?class rdfs:subClassOf bfo:BFO_0000002 .
                OPTIONAL { ?class rdfs:label ?label }
            }
            ORDER BY ?class
        """,
        "min_results": 2,
    },
    {
        "name": "BFO Occurrent subclasses",
        "description": "Direct subclasses of BFO:Occurrent — confirms BFO hierarchy",
        "sparql": """
            PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
            PREFIX bfo: <http://purl.obolibrary.org/obo/>
            SELECT ?class ?label WHERE {
                ?class rdfs:subClassOf bfo:BFO_0000003 .
                OPTIONAL { ?class rdfs:label ?label }
            }
            ORDER BY ?class
        """,
        "min_results": 2,
    },
    {
        "name": "CCO classes present",
        "description": "Count of CCO classes — confirms CCO loaded",
        "sparql": """
            PREFIX owl: <http://www.w3.org/2002/07/owl#>
            SELECT (COUNT(DISTINCT ?class) AS ?count) WHERE {
                ?class a owl:Class .
                FILTER(STRSTARTS(STR(?class), "https://www.commoncoreontologies.org/"))
            }
        """,
        "min_results": 1,
    },
    {
        "name": "IAO classes present",
        "description": "Count of IAO classes — confirms IAO loaded",
        "sparql": """
            PREFIX owl: <http://www.w3.org/2002/07/owl#>
            SELECT (COUNT(DISTINCT ?class) AS ?count) WHERE {
                ?class a owl:Class .
                FILTER(STRSTARTS(STR(?class), "http://purl.obolibrary.org/obo/IAO_"))
            }
        """,
        "min_results": 1,
    },
    {
        "name": "Named graphs populated",
        "description": "Lists named graphs and their triple counts",
        "sparql": """
            SELECT ?graph (COUNT(*) AS ?triples) WHERE {
                GRAPH ?graph { ?s ?p ?o }
            }
            GROUP BY ?graph
            ORDER BY ?graph
        """,
        "min_results": 1,
    },
    {
        "name": "Total triple count",
        "description": "Total triples across all graphs",
        "sparql": """
            SELECT (COUNT(*) AS ?total) WHERE { ?s ?p ?o }
        """,
        "min_results": 1,
    },
]


# ---------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------

def graphdb_request(path, method="GET", data=None, content_type=None, accept="application/json"):
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


def graphdb_multipart_post(path, fields, accept="text/plain"):
    """POST multipart/form-data to GraphDB (used for repo creation)."""
    url = f"{GRAPHDB_BASE}{path}"
    boundary = uuid.uuid4().hex

    body = b""
    for field_name, (filename, file_data, file_content_type) in fields.items():
        body += f"--{boundary}\r\n".encode()
        body += f'Content-Disposition: form-data; name="{field_name}"; filename="{filename}"\r\n'.encode()
        body += f"Content-Type: {file_content_type}\r\n\r\n".encode()
        if isinstance(file_data, str):
            body += file_data.encode("utf-8")
        else:
            body += file_data
        body += b"\r\n"
    body += f"--{boundary}--\r\n".encode()

    headers = {
        "Content-Type": f"multipart/form-data; boundary={boundary}",
        "Accept": accept,
    }

    req = urllib.request.Request(url, data=body, headers=headers, method="POST")
    try:
        with urllib.request.urlopen(req) as resp:
            return resp.read().decode("utf-8")
    except urllib.error.HTTPError as e:
        err_body = e.read().decode("utf-8") if e.fp else ""
        print(f"  HTTP {e.code}: {err_body[:500]}")
        raise


def repo_exists():
    """Check if the ontara-dev repository exists."""
    try:
        repos = graphdb_request("/rest/repositories")
        return any(r.get("id") == REPO_ID for r in repos)
    except Exception:
        return False


# ---------------------------------------------------------------
# Repository Management
# ---------------------------------------------------------------

def create_repository():
    """Create the ontara-dev repository with OWL-Horst (Optimized) ruleset."""
    if repo_exists():
        print(f"  Repository '{REPO_ID}' already exists.")
        return True

    print(f"  Creating repository '{REPO_ID}' with OWL-Horst (Optimized)...")

    # GraphDB repository configuration in Turtle format
    config = f"""
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix rep: <http://www.openrdf.org/config/repository#> .
@prefix sr: <http://www.openrdf.org/config/repository/sail#> .
@prefix sail: <http://www.openrdf.org/config/sail#> .
@prefix graphdb: <http://www.ontotext.com/config/graphdb#> .

[] a rep:Repository ;
    rep:repositoryID "{REPO_ID}" ;
    rdfs:label "Ontara Development Repository" ;
    rep:repositoryImpl [
        rep:repositoryType "graphdb:SailRepository" ;
        sr:sailImpl [
            sail:sailType "graphdb:Sail" ;
            graphdb:base-URL "https://ontara.dev/" ;
            graphdb:defaultNS "" ;
            graphdb:entity-index-size "10000000" ;
            graphdb:entity-id-size "32" ;
            graphdb:imports "" ;
            graphdb:repository-type "file-repository" ;
            graphdb:ruleset "owl-horst-optimized" ;
            graphdb:storage-folder "storage" ;
            graphdb:enable-context-index "true" ;
            graphdb:enablePredicateList "true" ;
            graphdb:in-memory-literal-properties "true" ;
            graphdb:enable-literal-index "true" ;
            graphdb:check-for-inconsistencies "false" ;
            graphdb:disable-sameAs "true" ;
            graphdb:query-timeout "0" ;
            graphdb:query-limit-results "0" ;
            graphdb:throw-QueryEvaluationException-on-timeout "false" ;
            graphdb:read-only "false" ;
        ]
    ] .
"""

    try:
        graphdb_multipart_post(
            "/rest/repositories",
            fields={
                "config": ("repo-config.ttl", config, "text/turtle"),
            },
        )
        print(f"  Repository '{REPO_ID}' created successfully.")
        return True
    except urllib.error.HTTPError:
        print(f"  Failed to create repository.")
        return False


def drop_repository():
    """Delete the ontara-dev repository."""
    if not repo_exists():
        print(f"  Repository '{REPO_ID}' does not exist.")
        return True

    print(f"  Dropping repository '{REPO_ID}'...")
    try:
        graphdb_request(f"/rest/repositories/{REPO_ID}", method="DELETE", accept="text/plain")
        print(f"  Repository '{REPO_ID}' dropped.")
        return True
    except urllib.error.HTTPError:
        print(f"  Failed to drop repository.")
        return False


# ---------------------------------------------------------------
# Ontology Loading
# ---------------------------------------------------------------

def load_ontology(entry):
    """Load a single ontology file into the specified named graph."""
    filepath = IMPORTS_DIR / entry["file"]
    if not filepath.exists():
        print(f"  SKIP: {entry['file']} not found at {filepath}")
        print(f"         Run the download commands in ontology/imports/README.md")
        return False

    file_size = filepath.stat().st_size
    if file_size < 100:
        print(f"  SKIP: {entry['file']} is only {file_size} bytes — likely a 404 error page")
        print(f"         Re-download from the correct URL (see ontology/imports/README.md)")
        return False

    print(f"  Loading {entry['name']} ({entry['file']}, {file_size:,} bytes) into <{entry['graph']}>...")

    data = filepath.read_bytes()

    # Use the GraphDB statements endpoint with named graph
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
        print(f"  {entry['name']} loaded successfully.")
        return True
    except urllib.error.HTTPError:
        print(f"  Failed to load {entry['name']}.")
        return False


def load_all_ontologies():
    """Load the full ontology stack in order."""
    print("\nLoading ontology stack into GraphDB...")
    results = []
    for entry in ONTOLOGY_STACK:
        ok = load_ontology(entry)
        results.append((entry["name"], ok))

    print("\nLoad summary:")
    for name, ok in results:
        status = "OK" if ok else "FAILED"
        print(f"  [{status}] {name}")

    return all(ok for _, ok in results)


# ---------------------------------------------------------------
# Verification
# ---------------------------------------------------------------

def run_verification():
    """Run SPARQL verification queries against the repository."""
    print(f"\nRunning verification queries against '{REPO_ID}'...")

    if not repo_exists():
        print(f"  Repository '{REPO_ID}' does not exist. Run setup first.")
        return False

    all_pass = True
    for q in VERIFICATION_QUERIES:
        print(f"\n  [{q['name']}]")
        print(f"  {q['description']}")

        sparql_encoded = urllib.parse.quote(q["sparql"])
        try:
            result = graphdb_request(
                f"/repositories/{REPO_ID}?query={sparql_encoded}",
                accept="application/sparql-results+json",
            )
            if isinstance(result, str):
                result = json.loads(result)

            bindings = result.get("results", {}).get("bindings", [])
            count = len(bindings)

            if count >= q["min_results"]:
                print(f"  PASS — {count} result(s)")
            else:
                print(f"  FAIL — expected >= {q['min_results']}, got {count}")
                all_pass = False

            # Print first few results for inspection
            for i, row in enumerate(bindings[:10]):
                values = {k: v.get("value", "") for k, v in row.items()}
                print(f"    {values}")
            if count > 10:
                print(f"    ... and {count - 10} more")

        except Exception as e:
            print(f"  ERROR — {e}")
            all_pass = False

    print(f"\n{'ALL CHECKS PASSED' if all_pass else 'SOME CHECKS FAILED'}")
    return all_pass


# ---------------------------------------------------------------
# Main
# ---------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Set up GraphDB repository and load ontology stack for Ontara."
    )
    parser.add_argument("--verify", action="store_true", help="Run verification queries only")
    parser.add_argument("--drop", action="store_true", help="Drop and recreate the repository")
    args = parser.parse_args()

    print(f"GraphDB setup for Ontara ({GRAPHDB_BASE})")
    print(f"Repository: {REPO_ID}")
    print(f"Imports dir: {IMPORTS_DIR}")

    # Check GraphDB is reachable
    try:
        graphdb_request("/rest/repositories")
    except SystemExit:
        return

    if args.verify:
        run_verification()
        return

    if args.drop:
        drop_repository()

    # Create repository
    if not create_repository():
        print("Aborting — repository creation failed.")
        sys.exit(1)

    # Load ontologies
    if not load_all_ontologies():
        print("\nSome ontologies failed to load. Check the files exist in ontology/imports/")
        print("See ontology/imports/README.md for download commands")
        sys.exit(1)

    # Verify
    run_verification()


if __name__ == "__main__":
    main()
