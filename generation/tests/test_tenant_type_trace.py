"""S0.5 Pass A6 (H-0641): every tenant canonical runtime type has its trace.

Runs the QA suite's own Q67 and Q68 (``scripts/validate_kg.py``) with rdflib
over an in-memory dataset built from the committed generated OWL files, laid
out in the graphs ``validate_kg.py`` loads them into:

1. ``https://ontara.dev/graph/domain``: ``ontara-bmm.ttl`` and
   ``ontara-tenant-types.ttl``;
2. ``https://ontara.dev/graph/correspondence``: ``ontara-correspondence.ttl``.

Q67 returns every OWL class in the tenant namespace with no complete
correspondence record, and passes on zero rows. Q68 counts the tenant-type
records whose class exists, so Q67 cannot pass only because nothing was
loaded. Each case judges a result by the query entry's own keys, as
``run_query`` does. The fixtures are built at test time (no committed ``.ttl``
copy that would go stale), and nothing here touches GraphDB or the network.
Design: Cyril, session-522-s05-passA-step4-cyril, section 4 and extract D.
"""

from __future__ import annotations

import sys
import unittest
from pathlib import Path

from rdflib import Dataset, Graph, URIRef
from rdflib.namespace import OWL, RDF

REPO = Path(__file__).resolve().parents[2]
SCRIPTS = REPO / "scripts"
if str(SCRIPTS) not in sys.path:
    sys.path.insert(0, str(SCRIPTS))

import validate_kg  # noqa: E402

ONTOLOGY = REPO / "generated" / "ontology"
DOMAIN = URIRef("https://ontara.dev/graph/domain")
CORRESPONDENCE = URIRef("https://ontara.dev/graph/correspondence")
CORR = "https://ontara.dev/ontology/correspondence/"
ORDERLINE_RECORD = URIRef(CORR + "map-tenant-cafe-OrderLine")
ORDERLINE_CLASS = URIRef("https://ontara.dev/ontology/tenant/cafe/OrderLine")
FIXTURE_CLASS = URIRef("https://ontara.dev/ontology/tenant/fixture/Thing")

QUERIES = {q["id"]: q for q in validate_kg.VALIDATION_QUERIES}


def _parse(name):
    g = Graph()
    g.parse(ONTOLOGY / name, format="turtle")
    return g


# Parse once; each test copies into its own dataset.
_BMM = _parse("ontara-bmm.ttl")
_TENANT = _parse("ontara-tenant-types.ttl")
_CORR = _parse("ontara-correspondence.ttl")


def build(tenant_types=True):
    ds = Dataset()
    domain = ds.graph(DOMAIN)
    for t in _BMM:
        domain.add(t)
    if tenant_types:
        for t in _TENANT:
            domain.add(t)
    corr = ds.graph(CORRESPONDENCE)
    for t in _CORR:
        corr.add(t)
    return ds


def run(ds, qid):
    """(passed, rows) for one suite query, judged by its entry's keys."""
    q = QUERIES[qid]
    rows = list(ds.query(q["sparql"]))
    count = len(rows)
    if q.get("zero_is_pass"):
        passed = count == 0
    else:
        passed = count == q["expect_exactly"]
    return passed, rows


class TenantTypeTrace(unittest.TestCase):
    def test_suite_entries(self):
        self.assertTrue(QUERIES["Q67"].get("zero_is_pass"))
        self.assertEqual(QUERIES["Q67"]["group"], "Correspondence")
        self.assertEqual(QUERIES["Q68"]["group"], "Correspondence")
        self.assertEqual(QUERIES["Q68"]["expect_exactly"], 2)

    def test_1_as_generated_both_pass(self):
        ds = build()
        ok67, rows67 = run(ds, "Q67")
        ok68, rows68 = run(ds, "Q68")
        self.assertTrue(ok67, [str(r[0]) for r in rows67])
        self.assertTrue(ok68, len(rows68))
        self.assertEqual(sorted(str(r.qname) for r in rows68),
                         ["CoffeeShop::Order", "CoffeeShop::OrderLine"])

    def test_2_orderline_record_removed_both_fail(self):
        ds = build()
        corr = ds.graph(CORRESPONDENCE)
        removed = list(corr.triples((ORDERLINE_RECORD, None, None)))
        self.assertEqual(len(removed), 9)
        for t in removed:
            corr.remove(t)
        ok67, rows67 = run(ds, "Q67")
        ok68, rows68 = run(ds, "Q68")
        self.assertFalse(ok67)
        self.assertEqual([r[0] for r in rows67], [ORDERLINE_CLASS])
        self.assertFalse(ok68)
        self.assertEqual(len(rows68), 1)

    def test_3_orderline_qualified_name_removed_q67_fails(self):
        ds = build()
        corr = ds.graph(CORRESPONDENCE)
        qn = URIRef(CORR + "sysmlQualifiedName")
        self.assertEqual(len(list(corr.triples((ORDERLINE_RECORD, qn, None)))), 1)
        corr.remove((ORDERLINE_RECORD, qn, None))
        ok67, rows67 = run(ds, "Q67")
        self.assertFalse(ok67)
        self.assertEqual([r[0] for r in rows67], [ORDERLINE_CLASS])
        ok68, rows68 = run(ds, "Q68")
        self.assertFalse(ok68)
        self.assertEqual(len(rows68), 1)

    def test_4_other_tenant_namespace_class_q67_fails(self):
        ds = build()
        ds.graph(DOMAIN).add((FIXTURE_CLASS, RDF.type, OWL.Class))
        ok67, rows67 = run(ds, "Q67")
        self.assertFalse(ok67)
        self.assertEqual([r[0] for r in rows67], [FIXTURE_CLASS])
        ok68, _ = run(ds, "Q68")
        self.assertTrue(ok68)

    def test_5_tenant_types_not_loaded_q68_fails(self):
        ds = build(tenant_types=False)
        ok67, rows67 = run(ds, "Q67")
        self.assertTrue(ok67)  # vacuous: nothing to check
        ok68, rows68 = run(ds, "Q68")
        self.assertFalse(ok68)
        self.assertEqual(len(rows68), 0)


if __name__ == "__main__":
    unittest.main()
