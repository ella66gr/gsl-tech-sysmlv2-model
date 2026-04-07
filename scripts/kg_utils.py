#!/usr/bin/env python3
"""
Knowledge Graph Shared Utilities
=================================

Common GraphDB connection, SPARQL query execution, and IRI
shortening functions shared by validate_kg.py and diff_kg.py.

Extracted Session 137 to avoid duplicating ~80 lines of
connection/query infrastructure across KG pipeline scripts.

Source: Stage 5 Phase 3 — Step 5 (Session 137)
"""

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
GENERATED_ONTARA_DIR = REPO_ROOT / "generated" / "ontara"

# ---------------------------------------------------------------
# IRI shortening
# ---------------------------------------------------------------

IRI_PREFIXES = {
    "https://ontara.dev/ontology/bmm/axioms#": "ontara-ax:",
    "https://ontara.dev/ontology/bmm/": "ontara-bmm:",
    "https://ontara.dev/ontology/correspondence/": "corr:",
    "https://ontara.dev/ontology/governance/axioms#": "ontara-gov-ax:",
    "https://ontara.dev/ontology/governance/": "ontara-gov:",
    "https://ontara.dev/ontology/reasoning/": "ontara-rsn:",
    "https://ontara.dev/data/ears/reasoning/": "ears-rsn:",
    "https://ontara.dev/ontology/domain/axioms#": "ontara-dom-ax:",
    "https://ontara.dev/ontology/domain/": "ontara-dom:",
    "http://www.w3.org/ns/prov#": "prov:",
    "https://ontara.dev/graph/": "graph:",
    "http://purl.obolibrary.org/obo/": "obo:",
    "https://www.commoncoreontologies.org/": "cco:",
    "http://www.w3.org/2000/01/rdf-schema#": "rdfs:",
    "http://www.w3.org/2002/07/owl#": "owl:",
    "http://www.w3.org/2004/02/skos/core#": "skos:",
}


def shorten(iri):
    """Return a compact curie-style label for display."""
    for prefix, curie in IRI_PREFIXES.items():
        if iri.startswith(prefix):
            return curie + iri[len(prefix):]
    return iri


# ---------------------------------------------------------------
# GraphDB access
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


def check_graphdb():
    """Verify GraphDB is reachable. Exits on failure."""
    try:
        graphdb_request("/rest/repositories")
        return True
    except SystemExit:
        return False
    except Exception as e:
        print(f"Cannot reach GraphDB: {e}")
        sys.exit(1)


def get_binding_value(row, var, default=None):
    """Extract the value from a SPARQL binding, returning default if missing."""
    binding = row.get(var)
    if binding is None:
        return default
    return binding.get("value", default)


def get_binding_type(row, var):
    """Return the type ('uri', 'literal', 'bnode') of a SPARQL binding."""
    binding = row.get(var)
    if binding is None:
        return None
    return binding.get("type")
