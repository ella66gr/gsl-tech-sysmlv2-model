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

from kg_utils import (
    GRAPHDB_BASE,
    REPO_ID,
    REPO_ROOT,
    GENERATED_ONTOLOGY_DIR,
    graphdb_request,
    sparql_query,
    sparql_update,
    shorten,
    check_graphdb,
)

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
           rdfs:subClassOf ?parent ;
           <http://www.w3.org/2004/02/skos/core#definition> ?defn .
    FILTER(STRSTARTS(STR(?class), "https://ontara.dev/ontology/bmm/"))
    FILTER(isIRI(?parent))
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
           rdfs:label ?label ;
           <http://www.w3.org/2004/02/skos/core#definition> ?defn .
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
        "expect_exactly": 23,
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
        "expect_exactly": 17,
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
    # --- Group 6: Governance MVP (CQC Regulation 12) ---
    {
        "id": "Q17",
        "group": "Governance-MVP",
        "name": "Obligation decomposition: Reg 12(1) components",
        "sparql": """
PREFIX ontara-gov: <https://ontara.dev/ontology/governance/>
PREFIX ontara-gov-ax: <https://ontara.dev/ontology/governance/axioms#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?component ?label WHERE {
  ontara-gov:reg12-1-safe-care ontara-gov-ax:hasComponentDirective ?component .
  ?component rdfs:label ?label .
}
ORDER BY ?label
""",
        "expect_exactly": 9,
        "display_vars": ["component", "label"],
    },
    {
        "id": "Q18",
        "group": "Governance-MVP",
        "name": "Normative instrument lineage",
        "sparql": """
PREFIX ontara-gov: <https://ontara.dev/ontology/governance/>
PREFIX ontara-gov-ax: <https://ontara.dev/ontology/governance/axioms#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?source ?sourceLabel ?rel ?target ?targetLabel WHERE {
  VALUES ?rel { ontara-gov-ax:implementsInstrument ontara-gov-ax:interpretsInstrument }
  ?source ?rel ?target .
  ?source rdfs:label ?sourceLabel .
  ?target rdfs:label ?targetLabel .
  FILTER(STRSTARTS(STR(?source), STR(ontara-gov:)))
  FILTER(!CONTAINS(STR(?source), "test-"))
}
ORDER BY ?sourceLabel
""",
        "expect_exactly": 3,
        "display_vars": ["sourceLabel", "rel", "targetLabel"],
    },
    {
        "id": "Q19",
        "group": "Governance-MVP",
        "name": "Directive provenance completeness (no orphans)",
        "sparql": """
PREFIX ontara-gov: <https://ontara.dev/ontology/governance/>
PREFIX ontara-gov-ax: <https://ontara.dev/ontology/governance/axioms#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?directive ?label WHERE {
  ?directive a/rdfs:subClassOf* ontara-gov:DeonticDirective ;
             rdfs:label ?label .
  FILTER(!CONTAINS(STR(?directive), "test-"))
  FILTER NOT EXISTS {
    ?directive ontara-gov-ax:derivesFrom ?instrument .
  }
}
""",
        "expect_exactly": 0,
        "display_vars": ["directive", "label"],
        "zero_is_pass": True,
    },
    {
        "id": "Q20",
        "group": "Governance-MVP",
        "name": "Structural property completeness",
        "sparql": """
PREFIX ontara-gov: <https://ontara.dev/ontology/governance/>
PREFIX ontara-gov-ax: <https://ontara.dev/ontology/governance/axioms#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?directive ?label ?missing WHERE {
  ?directive a/rdfs:subClassOf* ontara-gov:DeonticDirective ;
             rdfs:label ?label .
  FILTER(!CONTAINS(STR(?directive), "test-"))
  FILTER(
    NOT EXISTS { ?directive ontara-gov-ax:hasContentModality ?cm } ||
    NOT EXISTS { ?directive ontara-gov-ax:hasTemporalScope ?ts } ||
    NOT EXISTS { ?directive ontara-gov-ax:hasSanctionSeverity ?ss }
  )
  BIND(
    CONCAT(
      IF(!EXISTS { ?directive ontara-gov-ax:hasContentModality ?cm2 }, "contentModality ", ""),
      IF(!EXISTS { ?directive ontara-gov-ax:hasTemporalScope ?ts2 }, "temporalScope ", ""),
      IF(!EXISTS { ?directive ontara-gov-ax:hasSanctionSeverity ?ss2 }, "sanctionSeverity ", "")
    ) AS ?missing
  )
}
""",
        "expect_exactly": 0,
        "display_vars": ["directive", "label", "missing"],
        "zero_is_pass": True,
    },
    {
        "id": "Q21",
        "group": "Governance-MVP",
        "name": "Evidential specification coverage",
        "sparql": """
PREFIX ontara-gov: <https://ontara.dev/ontology/governance/>
PREFIX ontara-gov-ax: <https://ontara.dev/ontology/governance/axioms#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?directive ?label WHERE {
  ?directive a/rdfs:subClassOf* ontara-gov:DeonticDirective ;
             rdfs:label ?label .
  FILTER(!CONTAINS(STR(?directive), "test-"))
  FILTER NOT EXISTS {
    ?directive ontara-gov-ax:evidentialSpecification ?ev .
  }
}
""",
        "expect_exactly": 0,
        "display_vars": ["directive", "label"],
        "zero_is_pass": True,
    },
    {
        "id": "Q22",
        "group": "Governance-MVP",
        "name": "Framework directive containment",
        "sparql": """
PREFIX ontara-gov: <https://ontara.dev/ontology/governance/>
PREFIX ontara-gov-ax: <https://ontara.dev/ontology/governance/axioms#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?directive ?label WHERE {
  ontara-gov:cqc-reg12-framework ontara-gov-ax:containsDirective ?directive .
  ?directive rdfs:label ?label .
}
ORDER BY ?label
""",
        "expect_exactly": 15,
        "display_vars": ["directive", "label"],
    },
    {
        "id": "Q23",
        "group": "Governance-MVP",
        "name": "Safe group membership",
        "sparql": """
PREFIX ontara-gov: <https://ontara.dev/ontology/governance/>
PREFIX ontara-gov-ax: <https://ontara.dev/ontology/governance/axioms#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?directive ?label WHERE {
  ?directive ontara-gov-ax:belongsToGroup ontara-gov:cqc-safe-group ;
            rdfs:label ?label .
}
ORDER BY ?label
""",
        "expect_exactly": 15,
        "display_vars": ["directive", "label"],
    },
    # --- Group 7: Properties ---
    {
        "id": "Q24",
        "group": "Properties",
        "name": "BMM object properties with domain and range",
        "sparql": """
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?prop ?label ?domain ?range WHERE {
  ?prop a owl:ObjectProperty ;
        rdfs:label ?label ;
        rdfs:domain ?domain ;
        rdfs:range ?range .
  FILTER(STRSTARTS(STR(?prop), "https://ontara.dev/ontology/bmm/axioms#"))
}
ORDER BY ?label
""",
        "expect_exactly": 14,
        "display_vars": ["prop", "label", "domain", "range"],
    },
    {
        "id": "Q25",
        "group": "Properties",
        "name": "Functional BMM object properties",
        "sparql": """
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?prop ?label WHERE {
  ?prop a owl:ObjectProperty, owl:FunctionalProperty ;
        rdfs:label ?label .
  FILTER(STRSTARTS(STR(?prop), "https://ontara.dev/ontology/bmm/axioms#"))
}
ORDER BY ?label
""",
        "expect_exactly": 9,
        "display_vars": ["prop", "label"],
    },
    # --- Group 8: Axioms ---
    {
        "id": "Q26",
        "group": "Axioms",
        "name": "BMM concern-group disjointness declarations",
        "sparql": """
PREFIX owl: <http://www.w3.org/2002/07/owl#>

SELECT ?disjoint WHERE {
  ?disjoint a owl:AllDisjointClasses .
}
""",
        "expect_at_least": 9,
        "display_vars": ["count"],
    },
    {
        "id": "Q27",
        "group": "Axioms",
        "name": "Qualified cardinality restrictions on BMM classes",
        "sparql": """
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?class ?label ?prop ?cardinality WHERE {
  ?class rdfs:subClassOf ?restriction .
  ?restriction a owl:Restriction ;
               owl:onProperty ?prop ;
               owl:qualifiedCardinality ?cardinality .
  ?class rdfs:label ?label .
  FILTER(STRSTARTS(STR(?class), "https://ontara.dev/ontology/bmm/"))
  FILTER(STRSTARTS(STR(?prop), "https://ontara.dev/ontology/bmm/axioms#"))
}
ORDER BY ?label
""",
        "expect_exactly": 9,
        "display_vars": ["class", "label", "prop", "cardinality"],
    },
    # --- Group 9: Weights ---
    {
        "id": "Q28",
        "group": "Weights",
        "name": "Reified weighted relationship individuals",
        "sparql": """
PREFIX ontara-bmm: <https://ontara.dev/ontology/bmm/>

SELECT ?weight ?source ?target ?strength WHERE {
  ?weight a ontara-bmm:WeightedRelationship ;
          ontara-bmm:weightSource ?source ;
          ontara-bmm:weightTarget ?target ;
          ontara-bmm:weightStrength ?strength .
}
ORDER BY ?weight
""",
        "expect_exactly": 96,
        "display_vars": ["weight", "source", "target", "strength"],
    },
    {
        "id": "Q29",
        "group": "Weights",
        "name": "Weighted relationship correspondence records",
        "sparql": """
PREFIX ontara-corr: <https://ontara.dev/ontology/correspondence/>

SELECT ?record ?sysmlName ?weightTarget WHERE {
  GRAPH <https://ontara.dev/graph/correspondence> {
    ?record a ontara-corr:WeightMappingRecord ;
            ontara-corr:sysmlElementName ?sysmlName ;
            ontara-corr:weightTarget ?weightTarget .
  }
}
ORDER BY ?sysmlName ?weightTarget
""",
        "expect_exactly": 96,
        "display_vars": ["record", "sysmlName", "weightTarget"],
    },
    # --- Group 10: Domain Identity (Session 144) ---
    {
        "id": "Q30",
        "group": "Domain-Identity",
        "name": "Domain identity classes with BFO grounding",
        "sparql": """
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ontara-domain: <https://ontara.dev/ontology/domain/>

SELECT ?class ?label ?parent WHERE {
  GRAPH <https://ontara.dev/graph/domain> {
    ?class a owl:Class ;
           rdfs:label ?label ;
           rdfs:subClassOf ?parent .
    FILTER(?class IN (ontara-domain:DomainIdentity, ontara-domain:DomainConfiguration))
    FILTER(isIRI(?parent))
    FILTER(STRSTARTS(STR(?parent), "http://purl.obolibrary.org/obo/IAO"))
  }
}
ORDER BY ?label
""",
        "expect_exactly": 2,
        "display_vars": ["class", "label", "parent"],
    },
    {
        "id": "Q31",
        "group": "Domain-Identity",
        "name": "Domain identity individuals by regulatory tier",
        "sparql": """
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ontara-domain: <https://ontara.dev/ontology/domain/>
PREFIX ontara-domain-ax: <https://ontara.dev/ontology/domain/axioms#>

SELECT ?identity ?label ?tier ?tierLabel WHERE {
  ?identity a ontara-domain:DomainIdentity ;
            rdfs:label ?label ;
            ontara-domain-ax:hasRegulatoryTier ?tier .
  ?tier rdfs:label ?tierLabel .
}
ORDER BY ?tierLabel ?label
""",
        "expect_exactly": 4,
        "display_vars": ["label", "tierLabel"],
    },
    {
        "id": "Q32",
        "group": "Domain-Identity",
        "name": "Regulated activities for sector-regulated domains",
        "sparql": """
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ontara-domain: <https://ontara.dev/ontology/domain/>
PREFIX ontara-domain-ax: <https://ontara.dev/ontology/domain/axioms#>

SELECT ?identity ?identityLabel ?activity ?activityLabel WHERE {
  ?identity a ontara-domain:DomainIdentity ;
            rdfs:label ?identityLabel ;
            ontara-domain-ax:hasRegulatoryTier ontara-domain:sectorRegulated ;
            ontara-domain-ax:hasRegulatedActivity ?activity .
  ?activity rdfs:label ?activityLabel .
}
ORDER BY ?identityLabel ?activityLabel
""",
        "expect_exactly": 2,
        "display_vars": ["identityLabel", "activityLabel"],
    },
    {
        "id": "Q33",
        "group": "Domain-Identity",
        "name": "Horizontal mapping traversal (identity to configuration)",
        "sparql": """
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ontara-domain: <https://ontara.dev/ontology/domain/>
PREFIX ontara-domain-ax: <https://ontara.dev/ontology/domain/axioms#>

SELECT ?identityLabel ?configLabel ?canonicalKey ?tier WHERE {
  ?identity a ontara-domain:DomainIdentity ;
            rdfs:label ?identityLabel ;
            ontara-domain-ax:hasConfiguration ?config ;
            ontara-domain-ax:hasRegulatoryTier ?tierInd .
  ?config a ontara-domain:DomainConfiguration ;
          rdfs:label ?configLabel ;
          ontara-domain-ax:canonicalKey ?canonicalKey .
  ?tierInd rdfs:label ?tier .
}
ORDER BY ?canonicalKey
""",
        "expect_exactly": 4,
        "display_vars": ["identityLabel", "configLabel", "canonicalKey", "tier"],
    },
    {
        "id": "Q34",
        "group": "Domain-Identity",
        "name": "Domain enumeration classes with closed membership",
        "sparql": """
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ontara-domain: <https://ontara.dev/ontology/domain/>

SELECT ?class ?label (COUNT(?member) AS ?memberCount) WHERE {
  ?class a owl:Class ;
         rdfs:label ?label ;
         owl:equivalentClass ?eqClass .
  ?eqClass owl:oneOf ?list .
  ?list rdf:rest*/rdf:first ?member .
  FILTER(STRSTARTS(STR(?class), STR(ontara-domain:)))
}
GROUP BY ?class ?label
ORDER BY ?label
""",
        "expect_exactly": 6,
        "display_vars": ["label", "memberCount"],
    },
    {
        "id": "Q35",
        "group": "Domain-Identity",
        "name": "Domain object properties with domain and range",
        "sparql": """
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ontara-domain-ax: <https://ontara.dev/ontology/domain/axioms#>

SELECT ?prop ?label ?domain ?range WHERE {
  ?prop a owl:ObjectProperty ;
        rdfs:label ?label .
  OPTIONAL { ?prop rdfs:domain ?domain }
  OPTIONAL { ?prop rdfs:range ?range }
  FILTER(STRSTARTS(STR(?prop), STR(ontara-domain-ax:)))
}
ORDER BY ?label
""",
        "expect_exactly": 8,
        "display_vars": ["prop", "label", "domain", "range"],
    },
    # --- Group 11: Reasoning (Session 152) ---
    {
        "id": "Q36",
        "group": "Reasoning",
        "name": "All reasoning classes with labels",
        "sparql": """
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ontara-rsn: <https://ontara.dev/ontology/reasoning/>

SELECT DISTINCT ?class ?label WHERE {
  ?class a owl:Class ;
         rdfs:label ?label .
  FILTER(STRSTARTS(STR(?class), STR(ontara-rsn:)))
}
ORDER BY ?label
""",
        "expect_exactly": 34,
        "display_vars": ["class", "label"],
    },
    {
        "id": "Q37",
        "group": "Reasoning",
        "name": "Reasoning object properties with domain and range (Phase 1+2)",
        "sparql": """
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ontara-rsn: <https://ontara.dev/ontology/reasoning/>

SELECT ?prop ?label ?domain ?range WHERE {
  ?prop a owl:ObjectProperty ;
        rdfs:label ?label .
  OPTIONAL { ?prop rdfs:domain ?domain }
  OPTIONAL { ?prop rdfs:range ?range }
  FILTER(STRSTARTS(STR(?prop), STR(ontara-rsn:)))
}
ORDER BY ?label
""",
        "expect_exactly": 24,
        "display_vars": ["prop", "label", "domain", "range"],
    },
    {
        "id": "Q38",
        "group": "Reasoning",
        "name": "PROV-O dual subclassing (BFO + PROV-O parents)",
        "sparql": """
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX prov: <http://www.w3.org/ns/prov#>
PREFIX ontara-rsn: <https://ontara.dev/ontology/reasoning/>

SELECT ?class ?label ?provParent WHERE {
  ?class rdfs:subClassOf ?provParent ;
         rdfs:label ?label .
  FILTER(STRSTARTS(STR(?class), STR(ontara-rsn:)))
  FILTER(STRSTARTS(STR(?provParent), STR(prov:)))
}
ORDER BY ?label
""",
        "expect_exactly": 4,
        "display_vars": ["class", "label", "provParent"],
    },
    {
        "id": "Q39",
        "group": "Reasoning",
        "name": "Evidence architecture property chain",
        "sparql": """
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ontara-rsn: <https://ontara.dev/ontology/reasoning/>

SELECT ?prop ?label ?domain ?range WHERE {
  VALUES ?prop {
    ontara-rsn:supportedBy
    ontara-rsn:hasEvidence
    ontara-rsn:hasConfidence
    ontara-rsn:hasInterpretiveFrame
  }
  ?prop rdfs:label ?label ;
        rdfs:domain ?domain ;
        rdfs:range ?range .
}
ORDER BY ?label
""",
        "expect_exactly": 4,
        "display_vars": ["prop", "label", "domain", "range"],
    },
    {
        "id": "Q40",
        "group": "Reasoning",
        "name": "Constraint subtypes (Hard, Soft, Graded)",
        "sparql": """
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ontara-rsn: <https://ontara.dev/ontology/reasoning/>

SELECT ?class ?label WHERE {
  ?class rdfs:subClassOf ontara-rsn:Constraint ;
         rdfs:label ?label .
  FILTER(STRSTARTS(STR(?class), STR(ontara-rsn:)))
  FILTER(?class != ontara-rsn:Constraint)
}
ORDER BY ?label
""",
        "expect_exactly": 3,
        "display_vars": ["class", "label"],
    },
    {
        "id": "Q41",
        "group": "Reasoning",
        "name": "Structured probabilistic component subtypes",
        "sparql": """
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ontara-rsn: <https://ontara.dev/ontology/reasoning/>

SELECT DISTINCT ?class ?label WHERE {
  ?class rdfs:subClassOf+ ontara-rsn:StructuredProbabilisticComponent ;
         rdfs:label ?label .
  FILTER(STRSTARTS(STR(?class), STR(ontara-rsn:)))
  FILTER(?class != ontara-rsn:StructuredProbabilisticComponent)
}
ORDER BY ?label
""",
        "sparql_fallback": """
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ontara-rsn: <https://ontara.dev/ontology/reasoning/>

SELECT DISTINCT ?class ?label WHERE {
  {
    ?class rdfs:subClassOf ontara-rsn:StructuredProbabilisticComponent .
  } UNION {
    ?class rdfs:subClassOf ?mid .
    ?mid rdfs:subClassOf ontara-rsn:StructuredProbabilisticComponent .
  }
  ?class rdfs:label ?label .
  FILTER(STRSTARTS(STR(?class), STR(ontara-rsn:)))
  FILTER(?class != ontara-rsn:StructuredProbabilisticComponent)
}
ORDER BY ?label
""",
        "expect_exactly": 4,
        "display_vars": ["class", "label"],
        "soft": True,
    },
    {
        "id": "Q42",
        "group": "Reasoning",
        "name": "Governance alignment (Obligation/Prohibition as HardConstraint)",
        "sparql": """
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ontara-rsn: <https://ontara.dev/ontology/reasoning/>
PREFIX ontara-gov: <https://ontara.dev/ontology/governance/>

SELECT ?class ?label WHERE {
  VALUES ?class { ontara-gov:Obligation ontara-gov:Prohibition }
  ?class rdfs:subClassOf ontara-rsn:HardConstraint ;
         rdfs:label ?label .
}
ORDER BY ?label
""",
        "expect_exactly": 2,
        "display_vars": ["class", "label"],
    },
    {
        "id": "Q43",
        "group": "Reasoning",
        "name": "InterpretiveFrame named individuals",
        "sparql": """
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ontara-rsn: <https://ontara.dev/ontology/reasoning/>

SELECT ?ind ?label WHERE {
  ?ind a owl:NamedIndividual ,
         ontara-rsn:InterpretiveFrame ;
       rdfs:label ?label .
}
ORDER BY ?label
""",
        "expect_exactly": 3,
        "display_vars": ["ind", "label"],
    },
    {
        "id": "Q44",
        "group": "Reasoning",
        "name": "Heuristic subclass hierarchy (6 families)",
        "sparql": """
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ontara-rsn: <https://ontara.dev/ontology/reasoning/>

SELECT ?class ?label WHERE {
  ?class rdfs:subClassOf ontara-rsn:Heuristic ;
         rdfs:label ?label .
  FILTER(STRSTARTS(STR(?class), STR(ontara-rsn:)))
  FILTER(?class != ontara-rsn:Heuristic)
}
ORDER BY ?label
""",
        "expect_exactly": 6,
        "display_vars": ["class", "label"],
    },
    {
        "id": "Q45",
        "group": "Reasoning",
        "name": "HeuristicPack class with hasMember property",
        "sparql": """
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ontara-rsn: <https://ontara.dev/ontology/reasoning/>

SELECT ?class ?prop ?domain ?range WHERE {
  ontara-rsn:HeuristicPack a owl:Class ;
                            rdfs:label ?class .
  ontara-rsn:hasMember a owl:ObjectProperty ;
                       rdfs:label ?prop ;
                       rdfs:domain ?domain ;
                       rdfs:range ?range .
}
""",
        "expect_exactly": 1,
        "display_vars": ["class", "prop", "domain", "range"],
    },
    {
        "id": "Q46",
        "group": "Reasoning",
        "name": "DecisionMode named individuals (4 Cynefin domains)",
        "sparql": """
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ontara-rsn: <https://ontara.dev/ontology/reasoning/>

SELECT ?ind ?label WHERE {
  ?ind a owl:NamedIndividual ,
         ontara-rsn:DecisionMode ;
       rdfs:label ?label .
}
ORDER BY ?label
""",
        "expect_exactly": 4,
        "display_vars": ["ind", "label"],
    },
    {
        "id": "Q47",
        "group": "Reasoning",
        "name": "activatesComponent property declaration",
        "sparql": """
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ontara-rsn: <https://ontara.dev/ontology/reasoning/>

SELECT ?prop ?label ?domain ?range WHERE {
  ontara-rsn:activatesComponent a owl:ObjectProperty ;
                                 rdfs:label ?label ;
                                 rdfs:domain ?domain ;
                                 rdfs:range ?range .
  BIND(ontara-rsn:activatesComponent AS ?prop)
}
""",
        "expect_exactly": 1,
        "display_vars": ["prop", "label", "domain", "range"],
    },
    {
        "id": "Q48",
        "group": "Reasoning",
        "name": "CombinationAlgebra named individuals (4 algebras)",
        "sparql": """
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ontara-rsn: <https://ontara.dev/ontology/reasoning/>

SELECT ?ind ?label WHERE {
  ?ind a owl:NamedIndividual ,
         ontara-rsn:CombinationAlgebra ;
       rdfs:label ?label .
}
ORDER BY ?label
""",
        "expect_exactly": 4,
        "display_vars": ["ind", "label"],
    },
    {
        "id": "Q49",
        "group": "Reasoning",
        "name": "hasCombinationAlgebra is functional property",
        "sparql": """
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ontara-rsn: <https://ontara.dev/ontology/reasoning/>

SELECT ?prop ?label WHERE {
  ontara-rsn:hasCombinationAlgebra a owl:ObjectProperty ,
                                     owl:FunctionalProperty ;
                                   rdfs:label ?label .
  BIND(ontara-rsn:hasCombinationAlgebra AS ?prop)
}
""",
        "expect_exactly": 1,
        "display_vars": ["prop", "label"],
    },
    {
        "id": "Q50",
        "group": "Reasoning",
        "name": "composedWith is symmetric property",
        "sparql": """
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ontara-rsn: <https://ontara.dev/ontology/reasoning/>

SELECT ?prop ?label WHERE {
  ontara-rsn:composedWith a owl:ObjectProperty ,
                            owl:SymmetricProperty ;
                          rdfs:label ?label .
  BIND(ontara-rsn:composedWith AS ?prop)
}
""",
        "expect_exactly": 1,
        "display_vars": ["prop", "label"],
    },
]


# ---------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------


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
    if not check_graphdb():
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
