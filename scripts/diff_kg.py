#!/usr/bin/env python3
"""
Knowledge Graph Round-Trip Diff Engine
========================================

Compares pipeline-generated OWL (Turtle files) against the live
GraphDB triple store, reporting discrepancies at the semantic unit
level. Operates within the SysML-authoritative and shared-constrained
authority zones only — OWL-authoritative content (hand-authored axioms,
governance vocabulary) is excluded.

Four semantic unit types are compared:
  - ClassDeclaration  (from ontara-bmm.ttl → domain graph)
  - PropertyDeclaration (from ontara-bmm-properties.ttl → domain graph)
  - WeightIndividual  (from ontara-bmm-weights.ttl → domain graph)
  - MappingRecord     (from ontara-correspondence.ttl → correspondence graph)

Each unit is compared as a whole: matched by IRI, then property sets
compared to classify as added/removed/modified/unchanged.

Output:
  - JSON report to generated/ontara/diff-report.json
  - Human-readable summary to stdout

Design decisions: S135-D3 (standalone), S135-D4 (semantic unit level),
S135-D5 (authority-zone-aware), S136-D1 (removals prominent),
S136-D2 (dual output).

Prerequisites:
  - GraphDB Free running on localhost:7200
  - Repository 'ontara-dev' loaded with current pipeline output
  - Pipeline has been run: python3 scripts/gen_owl_pipeline.py --save

Usage:
    python3 scripts/diff_kg.py              # Run diff
    python3 scripts/diff_kg.py --verbose    # Show all details
    python3 scripts/diff_kg.py --json-only  # JSON output only, no stdout summary

Source: Stage 5 Phase 3 — Step 5 (Session 137)
"""

import argparse
import json
import pathlib
import sys
from dataclasses import dataclass, field, asdict
from datetime import datetime, timezone
from typing import Optional

from kg_utils import (
    REPO_ROOT,
    GENERATED_ONTOLOGY_DIR,
    GENERATED_ONTARA_DIR,
    check_graphdb,
    sparql_query,
    shorten,
    get_binding_value,
)

# ---------------------------------------------------------------
# Semantic unit dataclasses
# ---------------------------------------------------------------

@dataclass
class ClassDeclaration:
    """A BMM class declaration — identified by IRI."""
    iri: str
    label: str = ""
    comment: str = ""
    definition: str = ""
    parent: str = ""
    unit_type: str = "ClassDeclaration"

    def props(self):
        return {
            "label": self.label,
            "comment": self.comment,
            "definition": self.definition,
            "parent": self.parent,
        }


@dataclass
class PropertyDeclaration:
    """A BMM object property declaration — identified by IRI."""
    iri: str
    label: str = ""
    comment: str = ""
    domain: str = ""
    range: str = ""
    functional: bool = False
    sub_property_of: str = ""
    unit_type: str = "PropertyDeclaration"

    def props(self):
        return {
            "label": self.label,
            "comment": self.comment,
            "domain": self.domain,
            "range": self.range,
            "functional": self.functional,
            "sub_property_of": self.sub_property_of,
        }


@dataclass
class WeightIndividual:
    """A reified weighted relationship individual — identified by IRI."""
    iri: str
    label: str = ""
    source: str = ""
    target: str = ""
    strength: str = ""
    rationale: str = ""
    unit_type: str = "WeightIndividual"

    def props(self):
        return {
            "label": self.label,
            "source": self.source,
            "target": self.target,
            "strength": self.strength,
            "rationale": self.rationale,
        }


@dataclass
class MappingRecord:
    """A correspondence mapping record — identified by IRI.

    Covers MappingRecord, PropertyMappingRecord, and WeightMappingRecord
    subtypes. The record_type field captures the subtype.
    """
    iri: str
    record_type: str = "MappingRecord"  # or PropertyMappingRecord, WeightMappingRecord
    sysml_element_name: str = ""
    owl_entity: str = ""
    classification: str = ""
    sysml_source_file: str = ""
    sysml_line_number: str = ""
    source_hash: str = ""
    authority_zone: str = ""
    # PropertyMappingRecord extras
    is_functional: Optional[bool] = None
    multiplicity: str = ""
    # WeightMappingRecord extras
    weight_strength: str = ""
    weight_target: str = ""
    unit_type: str = "MappingRecord"

    def props(self):
        base = {
            "record_type": self.record_type,
            "sysml_element_name": self.sysml_element_name,
            "owl_entity": self.owl_entity,
            "classification": self.classification,
            "sysml_source_file": self.sysml_source_file,
            "sysml_line_number": self.sysml_line_number,
            "source_hash": self.source_hash,
            "authority_zone": self.authority_zone,
        }
        if self.record_type == "PropertyMappingRecord":
            base["is_functional"] = self.is_functional
            base["multiplicity"] = self.multiplicity
        elif self.record_type == "WeightMappingRecord":
            base["weight_strength"] = self.weight_strength
            base["weight_target"] = self.weight_target
        return base


# ---------------------------------------------------------------
# SPARQL extraction from GraphDB (store side)
# ---------------------------------------------------------------

def extract_classes_from_store():
    """Extract ClassDeclaration units from the domain named graph."""
    sparql = """
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT ?class ?label ?comment ?definition ?parent WHERE {
  GRAPH <https://ontara.dev/graph/domain> {
    ?class a owl:Class ;
           rdfs:label ?label ;
           rdfs:subClassOf ?parent ;
           skos:definition ?definition .
    OPTIONAL { ?class rdfs:comment ?comment }
    FILTER(STRSTARTS(STR(?class), "https://ontara.dev/ontology/bmm/"))
    FILTER(isIRI(?parent))
  }
}
ORDER BY ?label
"""
    rows = sparql_query(sparql)
    units = {}
    for row in rows:
        iri = get_binding_value(row, "class")
        units[iri] = ClassDeclaration(
            iri=iri,
            label=get_binding_value(row, "label", ""),
            comment=get_binding_value(row, "comment", ""),
            definition=get_binding_value(row, "definition", ""),
            parent=get_binding_value(row, "parent", ""),
        )
    return units


def extract_properties_from_store():
    """Extract PropertyDeclaration units from the domain named graph.

    Scoped to ontara-ax: (BMM axioms) namespace — excludes governance
    properties (ontara-gov-ax:) per authority zone rules.
    """
    sparql = """
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?prop ?label ?comment ?domain ?range ?functional ?subProp WHERE {
  GRAPH <https://ontara.dev/graph/domain> {
    ?prop a owl:ObjectProperty ;
          rdfs:label ?label .
    OPTIONAL { ?prop rdfs:comment ?comment }
    OPTIONAL { ?prop rdfs:domain ?domain }
    OPTIONAL { ?prop rdfs:range ?range }
    OPTIONAL { ?prop rdfs:subPropertyOf ?subProp }
    FILTER(STRSTARTS(STR(?prop), "https://ontara.dev/ontology/bmm/axioms#"))
  }
  BIND(EXISTS {
    GRAPH <https://ontara.dev/graph/domain> {
      ?prop a owl:FunctionalProperty
    }
  } AS ?functional)
}
ORDER BY ?label
"""
    rows = sparql_query(sparql)
    units = {}
    for row in rows:
        iri = get_binding_value(row, "prop")
        func_val = get_binding_value(row, "functional", "false")
        units[iri] = PropertyDeclaration(
            iri=iri,
            label=get_binding_value(row, "label", ""),
            comment=get_binding_value(row, "comment", ""),
            domain=get_binding_value(row, "domain", ""),
            range=get_binding_value(row, "range", ""),
            functional=(func_val == "true"),
            sub_property_of=get_binding_value(row, "subProp", ""),
        )
    return units


def extract_weights_from_store():
    """Extract WeightIndividual units from the domain named graph."""
    sparql = """
PREFIX ontara-bmm: <https://ontara.dev/ontology/bmm/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?weight ?label ?source ?target ?strength ?rationale WHERE {
  GRAPH <https://ontara.dev/graph/domain> {
    ?weight a ontara-bmm:WeightedRelationship ;
            rdfs:label ?label ;
            ontara-bmm:weightSource ?source ;
            ontara-bmm:weightTarget ?target ;
            ontara-bmm:weightStrength ?strength .
    OPTIONAL { ?weight ontara-bmm:weightRationale ?rationale }
    FILTER(STRSTARTS(STR(?weight), "https://ontara.dev/ontology/bmm/"))
  }
}
ORDER BY ?weight
"""
    rows = sparql_query(sparql)
    units = {}
    for row in rows:
        iri = get_binding_value(row, "weight")
        units[iri] = WeightIndividual(
            iri=iri,
            label=get_binding_value(row, "label", ""),
            source=get_binding_value(row, "source", ""),
            target=get_binding_value(row, "target", ""),
            strength=get_binding_value(row, "strength", ""),
            rationale=get_binding_value(row, "rationale", ""),
        )
    return units


def extract_mappings_from_store():
    """Extract MappingRecord units (all subtypes) from the correspondence graph."""
    # Base MappingRecord instances
    sparql_base = """
PREFIX ontara-corr: <https://ontara.dev/ontology/correspondence/>
PREFIX dcterms: <http://purl.org/dc/terms/>

SELECT ?record ?sysmlName ?owlEntity ?classification ?sourceFile ?lineNum ?hash ?zone WHERE {
  GRAPH <https://ontara.dev/graph/correspondence> {
    ?record a ontara-corr:MappingRecord ;
            ontara-corr:sysmlElementName ?sysmlName ;
            ontara-corr:owlEntity ?owlEntity ;
            ontara-corr:classification ?classification .
    OPTIONAL { ?record ontara-corr:sysmlSourceFile ?sourceFile }
    OPTIONAL { ?record ontara-corr:sysmlLineNumber ?lineNum }
    OPTIONAL { ?record ontara-corr:sourceHash ?hash }
    OPTIONAL { ?record ontara-corr:authorityZone ?zone }
    FILTER(STRSTARTS(STR(?record), "https://ontara.dev/ontology/correspondence/"))
    FILTER NOT EXISTS { ?record a ontara-corr:PropertyMappingRecord }
    FILTER NOT EXISTS { ?record a ontara-corr:WeightMappingRecord }
  }
}
ORDER BY ?sysmlName
"""
    # PropertyMappingRecord instances
    sparql_prop = """
PREFIX ontara-corr: <https://ontara.dev/ontology/correspondence/>

SELECT ?record ?sysmlName ?owlEntity ?classification ?zone ?isFunctional ?multiplicity WHERE {
  GRAPH <https://ontara.dev/graph/correspondence> {
    ?record a ontara-corr:PropertyMappingRecord ;
            ontara-corr:sysmlElementName ?sysmlName ;
            ontara-corr:owlEntity ?owlEntity ;
            ontara-corr:classification ?classification .
    OPTIONAL { ?record ontara-corr:authorityZone ?zone }
    OPTIONAL { ?record ontara-corr:isFunctional ?isFunctional }
    OPTIONAL { ?record ontara-corr:multiplicity ?multiplicity }
    FILTER(STRSTARTS(STR(?record), "https://ontara.dev/ontology/correspondence/"))
  }
}
ORDER BY ?sysmlName
"""
    # WeightMappingRecord instances
    sparql_weight = """
PREFIX ontara-corr: <https://ontara.dev/ontology/correspondence/>

SELECT ?record ?sysmlName ?owlEntity ?classification ?sourceFile ?lineNum ?zone ?weightStrength ?weightTarget WHERE {
  GRAPH <https://ontara.dev/graph/correspondence> {
    ?record a ontara-corr:WeightMappingRecord ;
            ontara-corr:sysmlElementName ?sysmlName ;
            ontara-corr:owlEntity ?owlEntity ;
            ontara-corr:classification ?classification .
    OPTIONAL { ?record ontara-corr:sysmlSourceFile ?sourceFile }
    OPTIONAL { ?record ontara-corr:sysmlLineNumber ?lineNum }
    OPTIONAL { ?record ontara-corr:authorityZone ?zone }
    OPTIONAL { ?record ontara-corr:weightStrength ?weightStrength }
    OPTIONAL { ?record ontara-corr:weightTarget ?weightTarget }
    FILTER(STRSTARTS(STR(?record), "https://ontara.dev/ontology/correspondence/"))
  }
}
ORDER BY ?sysmlName
"""
    units = {}

    # Base mapping records
    for row in sparql_query(sparql_base):
        iri = get_binding_value(row, "record")
        units[iri] = MappingRecord(
            iri=iri,
            record_type="MappingRecord",
            sysml_element_name=get_binding_value(row, "sysmlName", ""),
            owl_entity=get_binding_value(row, "owlEntity", ""),
            classification=get_binding_value(row, "classification", ""),
            sysml_source_file=get_binding_value(row, "sourceFile", ""),
            sysml_line_number=get_binding_value(row, "lineNum", ""),
            source_hash=get_binding_value(row, "hash", ""),
            authority_zone=get_binding_value(row, "zone", ""),
        )

    # Property mapping records
    for row in sparql_query(sparql_prop):
        iri = get_binding_value(row, "record")
        func_val = get_binding_value(row, "isFunctional", "false")
        units[iri] = MappingRecord(
            iri=iri,
            record_type="PropertyMappingRecord",
            sysml_element_name=get_binding_value(row, "sysmlName", ""),
            owl_entity=get_binding_value(row, "owlEntity", ""),
            classification=get_binding_value(row, "classification", ""),
            authority_zone=get_binding_value(row, "zone", ""),
            is_functional=(func_val == "true"),
            multiplicity=get_binding_value(row, "multiplicity", ""),
        )

    # Weight mapping records
    for row in sparql_query(sparql_weight):
        iri = get_binding_value(row, "record")
        units[iri] = MappingRecord(
            iri=iri,
            record_type="WeightMappingRecord",
            sysml_element_name=get_binding_value(row, "sysmlName", ""),
            owl_entity=get_binding_value(row, "owlEntity", ""),
            classification=get_binding_value(row, "classification", ""),
            sysml_source_file=get_binding_value(row, "sourceFile", ""),
            sysml_line_number=get_binding_value(row, "lineNum", ""),
            authority_zone=get_binding_value(row, "zone", ""),
            weight_strength=get_binding_value(row, "weightStrength", ""),
            weight_target=get_binding_value(row, "weightTarget", ""),
        )

    return units


# ---------------------------------------------------------------
# Turtle file extraction (generated file side)
# ---------------------------------------------------------------

def _parse_turtle_simple(filepath):
    """Minimal Turtle parser using rdflib. Returns an rdflib.Graph."""
    try:
        import rdflib
    except ImportError:
        print("ERROR: rdflib is required. Install with: pip3 install rdflib")
        sys.exit(1)

    g = rdflib.Graph()
    g.parse(str(filepath), format="turtle")
    return g


def _val(g, subject, predicate, as_str=True):
    """Get a single value for (subject, predicate, ?) from an rdflib graph."""
    for obj in g.objects(subject, predicate):
        if as_str:
            return str(obj)
        return obj
    return ""


def _is_type(g, subject, type_uri):
    """Check if subject has rdf:type type_uri."""
    import rdflib
    return (subject, rdflib.RDF.type, type_uri) in g


def extract_classes_from_files():
    """Parse ontara-bmm.ttl and extract ClassDeclaration units."""
    import rdflib

    filepath = GENERATED_ONTOLOGY_DIR / "ontara-bmm.ttl"
    if not filepath.exists():
        print(f"  ERROR: {filepath} not found. Run gen_owl_pipeline.py --save first.")
        return {}

    g = _parse_turtle_simple(filepath)

    OWL = rdflib.OWL
    RDFS = rdflib.RDFS
    SKOS = rdflib.Namespace("http://www.w3.org/2004/02/skos/core#")
    BMM = rdflib.Namespace("https://ontara.dev/ontology/bmm/")

    units = {}
    for cls in g.subjects(rdflib.RDF.type, OWL.Class):
        iri = str(cls)
        if not iri.startswith("https://ontara.dev/ontology/bmm/"):
            continue

        # Get parent (named class only, skip restrictions)
        parent = ""
        for p in g.objects(cls, RDFS.subClassOf):
            if isinstance(p, rdflib.URIRef):
                parent = str(p)
                break

        units[iri] = ClassDeclaration(
            iri=iri,
            label=_val(g, cls, RDFS.label),
            comment=_val(g, cls, RDFS.comment),
            definition=_val(g, cls, SKOS.definition),
            parent=parent,
        )

    return units


def extract_properties_from_files():
    """Parse ontara-bmm-properties.ttl and extract PropertyDeclaration units."""
    import rdflib

    filepath = GENERATED_ONTOLOGY_DIR / "ontara-bmm-properties.ttl"
    if not filepath.exists():
        print(f"  ERROR: {filepath} not found. Run gen_owl_pipeline.py --save first.")
        return {}

    g = _parse_turtle_simple(filepath)

    OWL = rdflib.OWL
    RDFS = rdflib.RDFS
    AX_NS = "https://ontara.dev/ontology/bmm/axioms#"

    units = {}
    for prop in g.subjects(rdflib.RDF.type, OWL.ObjectProperty):
        iri = str(prop)
        if not iri.startswith(AX_NS):
            continue

        functional = (prop, rdflib.RDF.type, OWL.FunctionalProperty) in g

        units[iri] = PropertyDeclaration(
            iri=iri,
            label=_val(g, prop, RDFS.label),
            comment=_val(g, prop, RDFS.comment),
            domain=_val(g, prop, RDFS.domain),
            range=_val(g, prop, RDFS.range),
            functional=functional,
            sub_property_of=_val(g, prop, RDFS.subPropertyOf),
        )

    return units


def extract_weights_from_files():
    """Parse ontara-bmm-weights.ttl and extract WeightIndividual units."""
    import rdflib

    filepath = GENERATED_ONTOLOGY_DIR / "ontara-bmm-weights.ttl"
    if not filepath.exists():
        print(f"  ERROR: {filepath} not found. Run gen_owl_pipeline.py --save first.")
        return {}

    g = _parse_turtle_simple(filepath)

    BMM = rdflib.Namespace("https://ontara.dev/ontology/bmm/")
    RDFS = rdflib.RDFS

    units = {}
    for weight in g.subjects(rdflib.RDF.type, BMM.WeightedRelationship):
        iri = str(weight)
        if not iri.startswith("https://ontara.dev/ontology/bmm/"):
            continue

        units[iri] = WeightIndividual(
            iri=iri,
            label=_val(g, weight, RDFS.label),
            source=_val(g, weight, BMM.weightSource),
            target=_val(g, weight, BMM.weightTarget),
            strength=_val(g, weight, BMM.weightStrength),
            rationale=_val(g, weight, BMM.weightRationale),
        )

    return units


def extract_mappings_from_files():
    """Parse ontara-correspondence.ttl and extract MappingRecord units."""
    import rdflib

    filepath = GENERATED_ONTOLOGY_DIR / "ontara-correspondence.ttl"
    if not filepath.exists():
        print(f"  ERROR: {filepath} not found. Run gen_owl_pipeline.py --save first.")
        return {}

    g = _parse_turtle_simple(filepath)

    CORR = rdflib.Namespace("https://ontara.dev/ontology/correspondence/")
    DCTERMS = rdflib.Namespace("http://purl.org/dc/terms/")
    CORR_NS = "https://ontara.dev/ontology/correspondence/"

    units = {}

    for record in g.subjects(rdflib.RDF.type, None):
        iri = str(record)
        if not iri.startswith(CORR_NS):
            continue

        # Determine subtype
        is_prop_map = (record, rdflib.RDF.type, CORR.PropertyMappingRecord) in g
        is_weight_map = (record, rdflib.RDF.type, CORR.WeightMappingRecord) in g
        is_base_map = (record, rdflib.RDF.type, CORR.MappingRecord) in g

        if not (is_base_map or is_prop_map or is_weight_map):
            continue

        if is_prop_map:
            record_type = "PropertyMappingRecord"
        elif is_weight_map:
            record_type = "WeightMappingRecord"
        else:
            record_type = "MappingRecord"

        func_raw = _val(g, record, CORR.isFunctional)
        is_func = None
        if func_raw:
            is_func = func_raw.lower() == "true"

        line_num = _val(g, record, CORR.sysmlLineNumber)
        # rdflib may return the integer as "960" or as an int
        if line_num:
            line_num = str(line_num)

        units[iri] = MappingRecord(
            iri=iri,
            record_type=record_type,
            sysml_element_name=_val(g, record, CORR.sysmlElementName),
            owl_entity=_val(g, record, CORR.owlEntity),
            classification=_val(g, record, CORR.classification),
            sysml_source_file=_val(g, record, CORR.sysmlSourceFile),
            sysml_line_number=line_num,
            source_hash=_val(g, record, CORR.sourceHash),
            authority_zone=_val(g, record, CORR.authorityZone),
            is_functional=is_func,
            multiplicity=_val(g, record, CORR.multiplicity),
            weight_strength=_val(g, record, CORR.weightStrength),
            weight_target=_val(g, record, CORR.weightTarget),
        )

    return units


# ---------------------------------------------------------------
# Diff engine
# ---------------------------------------------------------------

@dataclass
class DiffEntry:
    """A single diff result for one semantic unit."""
    iri: str
    unit_type: str
    category: str  # added, removed, modified, unchanged
    label: str = ""
    modifications: dict = field(default_factory=dict)
    # For modified: {prop_name: {"file": val, "store": val}}


def diff_units(file_units, store_units, unit_type_name):
    """Compare two dicts of semantic units (keyed by IRI).

    Returns a list of DiffEntry objects.
    """
    results = []

    all_iris = set(file_units.keys()) | set(store_units.keys())

    for iri in sorted(all_iris):
        in_file = iri in file_units
        in_store = iri in store_units

        if in_file and not in_store:
            unit = file_units[iri]
            results.append(DiffEntry(
                iri=iri,
                unit_type=unit_type_name,
                category="added",
                label=getattr(unit, "label", "") or getattr(unit, "sysml_element_name", ""),
            ))
        elif in_store and not in_file:
            unit = store_units[iri]
            results.append(DiffEntry(
                iri=iri,
                unit_type=unit_type_name,
                category="removed",
                label=getattr(unit, "label", "") or getattr(unit, "sysml_element_name", ""),
            ))
        else:
            # Both exist — compare properties
            file_unit = file_units[iri]
            store_unit = store_units[iri]
            file_props = file_unit.props()
            store_props = store_unit.props()

            modifications = {}
            for key in set(file_props.keys()) | set(store_props.keys()):
                f_val = file_props.get(key, "")
                s_val = store_props.get(key, "")
                # Normalise for comparison: strip language tags, whitespace
                f_norm = _normalise(f_val)
                s_norm = _normalise(s_val)
                if f_norm != s_norm:
                    modifications[key] = {"file": f_val, "store": s_val}

            if modifications:
                results.append(DiffEntry(
                    iri=iri,
                    unit_type=unit_type_name,
                    category="modified",
                    label=getattr(file_unit, "label", ""),
                    modifications=modifications,
                ))
            else:
                results.append(DiffEntry(
                    iri=iri,
                    unit_type=unit_type_name,
                    category="unchanged",
                    label=getattr(file_unit, "label", ""),
                ))

    return results


def _normalise(val):
    """Normalise a value for comparison.

    Strips trailing whitespace, language tags (@en), and
    converts booleans to consistent strings.
    """
    if isinstance(val, bool):
        return str(val).lower()
    if val is None:
        return ""
    s = str(val).strip()
    # Strip rdflib language tags like @en
    if s.endswith("@en"):
        s = s[:-3]
    return s


# ---------------------------------------------------------------
# Report generation
# ---------------------------------------------------------------

def build_report(all_diffs):
    """Build the JSON report structure."""
    summary = {
        "added": 0,
        "removed": 0,
        "modified": 0,
        "unchanged": 0,
    }
    by_type = {}

    for entry in all_diffs:
        summary[entry.category] += 1
        by_type.setdefault(entry.unit_type, {
            "added": 0, "removed": 0, "modified": 0, "unchanged": 0
        })
        by_type[entry.unit_type][entry.category] += 1

    report = {
        "generated": datetime.now(timezone.utc).isoformat(),
        "source": "diff_kg.py — Stage 5 Phase 3 Step 5",
        "summary": summary,
        "by_type": by_type,
        "entries": [],
    }

    # Only include non-unchanged entries in the entries list
    for entry in all_diffs:
        if entry.category != "unchanged":
            entry_dict = {
                "iri": shorten(entry.iri),
                "iri_full": entry.iri,
                "unit_type": entry.unit_type,
                "category": entry.category,
                "label": entry.label,
            }
            if entry.modifications:
                entry_dict["modifications"] = {
                    k: {
                        "file": shorten(str(v["file"])) if isinstance(v.get("file"), str) and v["file"].startswith("http") else v.get("file", ""),
                        "store": shorten(str(v["store"])) if isinstance(v.get("store"), str) and v["store"].startswith("http") else v.get("store", ""),
                    }
                    for k, v in entry.modifications.items()
                }
            report["entries"].append(entry_dict)

    return report


def print_summary(report, verbose=False):
    """Print a human-readable summary to stdout."""
    s = report["summary"]
    total = s["added"] + s["removed"] + s["modified"] + s["unchanged"]

    print("\n=== ONTARA ROUND-TRIP DIFF REPORT ===")
    print(f"Generated: {report['generated']}")
    print(f"Total semantic units compared: {total}")
    print()

    # Overall summary
    print(f"  Unchanged:  {s['unchanged']}")
    print(f"  Added:      {s['added']}")
    print(f"  Modified:   {s['modified']}")

    # Removals get prominent display (S136-D1)
    if s["removed"] > 0:
        print(f"  *** REMOVED: {s['removed']} ***  (potential regression — review required)")
    else:
        print(f"  Removed:    {s['removed']}")

    print()

    # Per-type breakdown
    print("By semantic unit type:")
    for type_name, counts in report["by_type"].items():
        type_total = sum(counts.values())
        discrepancies = counts["added"] + counts["removed"] + counts["modified"]
        status = "CLEAN" if discrepancies == 0 else f"{discrepancies} discrepancies"
        print(f"  {type_name + ':':<25} {type_total} units — {status}")
        if discrepancies > 0 or verbose:
            for cat in ["added", "removed", "modified", "unchanged"]:
                if counts[cat] > 0:
                    marker = " ***" if cat == "removed" and counts[cat] > 0 else ""
                    print(f"    {cat}: {counts[cat]}{marker}")

    # Detail section for non-unchanged entries
    entries = report.get("entries", [])
    if entries:
        print()
        print("--- Discrepancy Details ---")
        for entry in entries:
            cat = entry["category"]
            prefix = "!!!" if cat == "removed" else "+++" if cat == "added" else "~~~"
            print(f"  {prefix} [{cat.upper()}] {entry['iri']} ({entry['unit_type']})")
            if entry.get("label"):
                print(f"      label: {entry['label']}")
            if entry.get("modifications"):
                for prop, vals in entry["modifications"].items():
                    print(f"      {prop}:")
                    print(f"        file:  {vals['file']}")
                    print(f"        store: {vals['store']}")
    else:
        print()
        print("No discrepancies found. Pipeline output matches the triple store.")

    # Final verdict
    discrepancy_count = s["added"] + s["removed"] + s["modified"]
    print()
    if discrepancy_count == 0:
        print("VERDICT: CLEAN — pipeline and store are in sync.")
    else:
        print(f"VERDICT: {discrepancy_count} DISCREPANCIES FOUND — review required.")

    return discrepancy_count


# ---------------------------------------------------------------
# Main
# ---------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Compare pipeline-generated OWL against the live triple store."
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Show per-type breakdown even for clean categories",
    )
    parser.add_argument(
        "--json-only",
        action="store_true",
        help="Write JSON report only, suppress stdout summary",
    )
    args = parser.parse_args()

    print("Ontara Round-Trip Diff Engine")
    print(f"Generated ontology dir: {GENERATED_ONTOLOGY_DIR}")

    # Check GraphDB
    check_graphdb()

    # Extract from files
    print("\nExtracting semantic units from pipeline-generated files...")
    file_classes = extract_classes_from_files()
    print(f"  ClassDeclaration:    {len(file_classes)}")
    file_props = extract_properties_from_files()
    print(f"  PropertyDeclaration: {len(file_props)}")
    file_weights = extract_weights_from_files()
    print(f"  WeightIndividual:    {len(file_weights)}")
    file_mappings = extract_mappings_from_files()
    print(f"  MappingRecord:       {len(file_mappings)}")

    # Extract from store
    print("\nExtracting semantic units from GraphDB store...")
    store_classes = extract_classes_from_store()
    print(f"  ClassDeclaration:    {len(store_classes)}")
    store_props = extract_properties_from_store()
    print(f"  PropertyDeclaration: {len(store_props)}")
    store_weights = extract_weights_from_store()
    print(f"  WeightIndividual:    {len(store_weights)}")
    store_mappings = extract_mappings_from_store()
    print(f"  MappingRecord:       {len(store_mappings)}")

    # Run diffs
    print("\nComparing semantic units...")
    all_diffs = []
    all_diffs.extend(diff_units(file_classes, store_classes, "ClassDeclaration"))
    all_diffs.extend(diff_units(file_props, store_props, "PropertyDeclaration"))
    all_diffs.extend(diff_units(file_weights, store_weights, "WeightIndividual"))
    all_diffs.extend(diff_units(file_mappings, store_mappings, "MappingRecord"))

    # Build report
    report = build_report(all_diffs)

    # Write JSON
    output_path = GENERATED_ONTARA_DIR / "diff-report.json"
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, "w") as f:
        json.dump(report, f, indent=2, default=str)
    print(f"\nJSON report written to: {output_path}")

    # Print summary
    if not args.json_only:
        discrepancy_count = print_summary(report, verbose=args.verbose)
    else:
        discrepancy_count = report["summary"]["added"] + report["summary"]["removed"] + report["summary"]["modified"]

    sys.exit(0 if discrepancy_count == 0 else 1)


if __name__ == "__main__":
    main()
