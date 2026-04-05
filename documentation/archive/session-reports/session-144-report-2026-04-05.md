---
tags:
  - session-report
date: 2026-04-05
status: current
session: 144
---
# Session 144 — Report

**Date:** 5 April 2026
**Session type:** Implementation
**Scope:** [[ontara-ref-work-items|W-025]] (Block A Steps 3–4 of the [[session-141-domain-governance-convergence-plan|Domain Identity and Governance Convergence plan]]) — OWL implementation of the domain identity vocabulary. Plus Block A Step 5 (pipeline extension) as stretch goal.

---

## Summary

Session 144 implemented the domain identity OWL vocabulary designed in the [[ontara-discussion-domain-identity-dual-stack-2026-04-05|Session 142 discussion paper]] §9. A new hand-authored ontology module (`ontara-domain.ttl`) was created at `ontology/domain/`, bringing the ontology stack from 10 files to 11. The module was loaded into GraphDB, validated CONSISTENT by Robot + HermiT, and exercised by 6 new SPARQL queries (Q30–Q35) in a new "Domain-Identity" validation group — all passing, bringing the suite from 29 to 35 queries.

The stretch goal (Block A Step 5) was also completed: `gen_model_introspection.py` was extended with a `build_domain_registry()` function that extracts `DomainIdentity` and `DomainConfiguration` instances directly from the SysML model, producing a `domainRegistry` key in the output JSON. All four domains ([[domain-cafe|Cafe]], [[domain-suds|Suds]], [[domain-paws|Paws]], GSL) were successfully extracted with their full attribute sets, including Paws's multi-valued tuple for `domainPurpose`.

## What Was Built

### 1. Domain Identity OWL Vocabulary (`ontara-domain.ttl`)

Hand-authored ontology module at `ontology/domain/ontara-domain.ttl` (32,732 bytes). OWL-authoritative per [[concept-authority-zones|B29]].

**Namespace:** `https://ontara.dev/ontology/domain/` (prefix `ontara-domain:`), with properties at `https://ontara.dev/ontology/domain/axioms#` (prefix `ontara-domain-ax:`). Follows S142-D5 (separate namespace) and the [[ontara-discussion-deontic-owl-class-design-2026-04-03|governance vocabulary]]'s pattern.

**Content:**

- **2 classes:** `DomainIdentity` (subclass of `IAO:plan_specification`, [[ontara-discussion-domain-identity-dual-stack-2026-04-05|S142-D2]]) and `DomainConfiguration` (subclass of `IAO:data_item`, [[ontara-discussion-domain-identity-dual-stack-2026-04-05|S142-D2]]), with disjointness axiom
- **6 enumeration classes** with `owl:oneOf` closure and pairwise `owl:differentFrom`:
  - `RegulatoryTier` (4 members)
  - `BmmVocabularyScope` (3 members)
  - `DomainPurpose` (4 members — `productionUse` IRI used to avoid collision with `BmmVocabularyScope::production`)
  - `Jurisdiction` (5 members)
  - `RegulatedActivity` (13 members, from HSCA 2008 Schedule 1)
  - `OrganisationalForm` (4 members — uses `registeredIndividual` per Session 143 finding)
- **8 object properties** in `ontara-domain-ax:`: `hasConfiguration`, `hasIdentity` (functional, inverse-functional, inverse pair), `hasRegulatoryTier`, `hasBmmVocabularyScope`, `hasDomainPurpose` (not functional — multi-valued), `hasJurisdiction`, `hasRegulatedActivity` (not functional — multi-valued), `hasOrganisationalForm`
- **8 data properties** in `ontara-domain-ax:`: `domainDescription`, `introducedAtSession`, `canonicalKey`, `displayLabel`, `fullName`, `packageName`, `modelPath`, `isActive`
- **8 domain individuals** (4 identity + 4 configuration): Cafe, Suds, Paws, GSL — with all attribute values matching the SysML instances in `Foundation::DomainRegistry`
- **Axioms:** Disjointness (`DomainIdentity` ⊥ `DomainConfiguration`), minimum cardinality (≥1 `hasDomainPurpose` on `DomainIdentity`), functional property assertions, pairwise `differentFrom` on all 33 enum members

### 2. Robot + HermiT Consistency

11-file ontology stack. HermiT found no contradictions. CONSISTENT / PASS.

### 3. SPARQL Validation Suite Extension

6 new queries (Q30–Q35) in group 10 "Domain-Identity":

| Query | Name | Expected | Result |
|---|---|---|---|
| Q30 | Domain identity classes with BFO grounding | 2 | PASS |
| Q31 | Domain identity individuals by regulatory tier | 4 | PASS |
| Q32 | Regulated activities for sector-regulated domains | 2 | PASS |
| Q33 | Horizontal mapping traversal (identity to configuration) | 4 | PASS |
| Q34 | Domain enumeration classes with closed membership | 6 | PASS |
| Q35 | Domain object properties with domain and range | 8 | PASS |

Full suite: 35/35 PASSED across 10 groups.

**Q30 fix:** Initial version returned 15 rows due to GraphDB's OWL-Horst materialising transitive `rdfs:subClassOf` chain. Fixed by scoping to `GRAPH <domain>` (asserted triples only) and filtering for IAO parents specifically.

**Q8 note:** Now returns 35 instead of 34 Continuant subclasses — the 35th is likely an inferred class from the domain ontology. Passes with its `expect_at_least: 30` threshold (diagnostic only).

### 4. Pipeline Extension (Block A Step 5)

`gen_model_introspection.py` extended with:

- `build_domain_registry()` function — parses `Foundation::DomainRegistry` in `foundation.sysml`, extracting `DomainIdentity` and `DomainConfiguration` part instances with their attribute values
- `_parse_attr_value()` and `_parse_single_value()` helper functions — handle enum references (`EnumType::value`), tuple values (`(a, b)`), string literals, integers, and booleans
- `domainRegistry` key added to output JSON
- Domain registry diagnostics added to stderr output
- `import re` moved to module level

All four domains extracted correctly, including Paws's multi-valued `domainPurpose` tuple.

### 5. Infrastructure Changes

- `ontology/domain/` directory created
- `ontology/catalog-v001.xml` updated with `ontara-domain:` IRI mapping
- `scripts/reason_kg.py` `ONTOLOGY_FILES` list updated (11 files)
- Domain graph now at 27,014 triples

## Design Note: `productionUse` IRI

The SysML `DomainPurpose` enum has a literal `production`, and the SysML `BmmVocabularyScope` enum also has `production`. In SysML these live in separate `enum def`s so there is no conflict. In OWL, both are individuals in the `ontara-domain:` namespace, so `ontara-domain:production` would collide. The `DomainPurpose` individual was named `ontara-domain:productionUse` (label "Production Use") to avoid this. The `BmmVocabularyScope` individual retains `ontara-domain:production`.

## Register Concepts Exercised

| Concept | How exercised |
|---|---|
| [[principle-separation-representation-execution\|A1]] | Domain properties live in representation (SysML + OWL), not execution config |
| [[principle-self-describing-system\|A2]] | System can describe its own domains via the knowledge graph |
| [[principle-model-generates-everything\|A3]] | Generator derives domain metadata from model; OWL individuals hand-authored from same design |
| [[principle-two-meta-model-distinction\|A4]] | Domain identity split across BMM (identity) and SMM (configuration) with [[concept-horizontal-mappings\|horizontal mapping]] |
| [[principle-discipline-as-load-bearing-structure\|A9]] | Workflow discipline followed — plan before build, validation before close |
| [[concept-multi-tenancy\|A13]] | Multi-tenancy structurally expressed through formal domain identity in both SysML and OWL |
| [[concept-horizontal-mappings\|B12]] | `hasConfiguration` / `hasIdentity` horizontal mapping with functional + inverse-functional |
| [[ontara-discussion-domain-identity-architecture-2026-03-22-v2.1\|B15]] | Domain identity — first OWL representation |
| [[concept-dual-stack-architecture\|B21]] | [[concept-dual-stack-architecture\|Dual-stack]] split confirmed in OWL class design |
| [[concept-knowledge-graph\|B22]] | Domain identity represented as OWL individuals in the [[concept-knowledge-graph\|knowledge graph]] |
| [[concept-bfo-ontological-grounding\|B23]] | OWL 2 DL formalism — HermiT consistency check |
| [[concept-three-stratum-knowledge-graph\|B28]] | Domain individuals in the domain graph stratum |
| [[concept-authority-zones\|B29]] | Hand-authored domain ontology is OWL-authoritative |
| [[concept-co-evolution\|J2]] | Model (SysML), ontology (OWL), generator, and console data evolve together |
| [[concept-non-constraining\|J3]] | Design supports future domains, jurisdictions, and regulated activities without structural changes |

## Emergent Ideas

None captured this session.

## Open Questions

None.

## Tier 1 Principles Honoured

- **[[principle-model-generates-everything|A3]] (model generates everything):** The pipeline extension extracts domain metadata from the SysML model rather than relying on hardcoded Python dicts. The OWL individuals mirror the SysML instances.
- **[[principle-two-meta-model-distinction|A4]] (two meta model distinction):** The [[concept-dual-stack-architecture|dual-stack]] split is faithfully represented in OWL — `DomainIdentity` → `plan_specification` (BMM), `DomainConfiguration` → `data_item` (SMM), connected by functional inverse properties.
- **[[principle-discipline-as-load-bearing-structure|A9]] (discipline as load-bearing structure):** Full validation pipeline — HermiT consistency + 35 SPARQL queries + pipeline regression test. Q30 failure caught and fixed within the session.
- **[[concept-multi-tenancy|A13]] (multi-tenancy):** First OWL expression of multi-tenancy — all four domains are formally represented as individuals with their regulatory, jurisdictional, and organisational characteristics.
- **[[concept-co-evolution|J2]] (co-evolution):** OWL vocabulary, SPARQL queries, and pipeline extraction all built together in the same session.
