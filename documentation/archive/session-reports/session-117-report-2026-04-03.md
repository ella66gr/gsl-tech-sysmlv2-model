---
tags:
  - session-report
date: 2026-04-03
status: current
session: 117
---
# Session 117 Report — Weighted Relationship Mapping to OWL

**Date:** 3 April 2026 (Session 117)
**Type:** Implementation (Chat + Code)
**Plan:** [[session-111-stage5-phase2-plan|Stage 5 Phase 2]], Block A Step 6

---

## Contents

- [[#1. Summary|§1. Summary]]
- [[#2. What Was Built|§2. What Was Built]]
- [[#3. Design Decisions|§3. Design Decisions]]
- [[#4. Bonus Fix — XML Catalog for Robot|§4. Bonus Fix — XML Catalog for Robot]]
- [[#5. Pipeline Output Summary|§5. Pipeline Output Summary]]
- [[#6. Register Concepts Exercised|§6. Register Concepts Exercised]]
- [[#7. Emergent Ideas|§7. Emergent Ideas]]
- [[#8. Tier 1 Principles Honoured|§8. Tier 1 Principles Honoured]]
- [[#9. Open Questions and Deferred Items|§9. Open Questions and Deferred Items]]

---

## 1. Summary

Session 117 implemented [[session-111-stage5-phase2-plan|Stage 5 Phase 2]] Step 6: mapping the 96 `@WeightedRelationship` SysML annotations to reified OWL individuals in the [[concept-knowledge-graph|knowledge graph]]. A new pipeline stage (3e) was added to `gen_owl_pipeline.py`, producing 96 named individuals of type `ontara-bmm:WeightedRelationship` with source, target, strength, and rationale properties. The reasoner (HermiT via Robot) confirmed the extended ontology stack is consistent, and the violation test passed.

A pre-existing Robot import resolution error was discovered and fixed by creating an XML catalog file (ontology/catalog-v001.xml) that maps the ontara-bmm: IRI to the local generated file. This is the proper long-term fix and benefits all future reasoning runs.

## 2. What Was Built

### 2.1 Pipeline Stage 3e — Weighted Relationship Generation

New function `stage3e_generate_weights()` in `scripts/gen_owl_pipeline.py`. For each DomainClass element carrying @WeightedRelationship annotations, the stage:

- Resolves source and target names to OWL class IRIs in the ontara-bmm: namespace
- Mints a named individual with IRI pattern `ontara-bmm:weight-{Source}-to-{Target}`
- Declares the individual as `owl:NamedIndividual` and `rdf:type ontara-bmm:WeightedRelationship`
- Attaches four properties: `weightSource` (ObjectProperty), `weightTarget` (ObjectProperty), `weightStrength` (DatatypeProperty, xsd:string), `weightRationale` (DatatypeProperty, xsd:string)
- Adds rdfs:label (e.g. "CustomerSegment → ValueProposition (strong)")

The stage includes validation: empty targets, targets not in the DomainClass set, and duplicate source-target pairs are all detected and reported as warnings. All 96 relationships passed cleanly — zero warnings.

### 2.2 Schema Declarations

The generated `ontara-bmm-weights.ttl` file includes schema declarations for:

- `ontara-bmm:WeightedRelationship` — OWL class, subclass of [[concept-bfo-ontological-grounding|BFO]]:GenericallyDependentContinuant
- `ontara-bmm:weightSource` — ObjectProperty (domain: WeightedRelationship, range: owl:Class)
- `ontara-bmm:weightTarget` — ObjectProperty (domain: WeightedRelationship, range: owl:Class)
- `ontara-bmm:weightStrength` — DatatypeProperty (domain: WeightedRelationship, range: xsd:string)
- `ontara-bmm:weightRationale` — DatatypeProperty (domain: WeightedRelationship, range: xsd:string)

### 2.3 Correspondence Graph Extension

96 `ontara-corr:WeightMappingRecord` entries added to the correspondence graph, each carrying: source element name, target name, strength, source file, line number, OWL entity IRI, classification, authority zone, and generation timestamp. Correspondence graph grew from 418 to 1378 triples.

### 2.4 Mapping IR Extension

The mapping-ir.json now includes a `weightedRelationships` array with 96 records and a `WeightedRelationship: 96` entry in the summary.

### 2.5 Reasoner Integration

`scripts/reason_kg.py` updated to include `ontara-bmm-weights.ttl` in the 7-file ontology stack. Both the consistency check and the violation test passed.

## 3. Design Decisions

**S117-D1: Namespace — ontara-bmm:** The reified individuals are first-class domain content about BMM class relationships, not axioms (ontara-ax:) or correspondence metadata (ontara-corr:). They belong in the main domain namespace.

**S117-D2: Reification justified by per-instance attributes.** Each relationship carries strength and rationale that cannot be expressed on a bare triple. The reification heuristic (reify when you need an ID, lifecycle, constraints, or additional attributes) was explicitly evaluated and passed on all four criteria. 96 individuals (~700 triples) is a modest count with no bloat concern. [[concept-non-constraining|Non-constraining (J3)]] — the reification structure itself is stable; what hangs on it can evolve freely.

**S117-D3: Strength as xsd:string.** The strength value is stored as a plain string literal ("strong", "moderate", "weak", "contextual") rather than as OWL named individuals or a closed enum. This is deliberately non-constraining — future evolution to numeric weights, multi-dimensional strength models, or named strength individuals would change only the values stored, not the reification structure.

**S117-D4: IRI pattern — weight-{Source}-to-{Target}.** Readable, deterministic, unique. Verified that no duplicate source-target pairs exist in the data (the pipeline checks this at generation time).

**S117-D5: XML catalog for Robot import resolution.** Created `ontology/catalog-v001.xml` to map `https://ontara.dev/ontology/bmm/` to the local `generated/ontology/ontara-bmm.ttl`. This resolves a pre-existing issue where Robot's OWL API tried to fetch the IRI from the network before collapsing imports. The catalog is the proper OWL tooling solution and benefits Protégé as well as Robot.

## 4. Bonus Fix — XML Catalog for Robot

Robot's `merge` command processes `owl:imports` declarations by attempting to resolve them before applying `--collapse-import-closure`. When the target IRI (`https://ontara.dev/ontology/bmm/`) is not network-reachable, this fails. The issue was latent in the existing 6-file stack but surfaced reliably when the 7th file was added.

The fix: `ontology/catalog-v001.xml` provides local IRI-to-file mappings. The `reason_kg.py` script now passes `--catalog` to Robot in both the main reasoning run and the violation test. This is the standard OWL tooling approach and matches what Protégé uses for local development.

## 5. Pipeline Output Summary

| Output file | Size | Content |
|---|---|---|
| ontara-bmm.ttl | 21,264 bytes | 34 domain classes (unchanged) |
| ontara-bmm-properties.ttl | 5,941 bytes | 14 object properties (unchanged) |
| ontara-bmm-weights.ttl | 57,678 bytes | 96 reified weight individuals + schema (NEW) |
| ontara-correspondence.ttl | 81,739 bytes | 34 class + 14 property + 96 weight mapping records |
| mapping-ir.json | 258,267 bytes | Full mapping IR with weight records |

Reasoning: 7-file stack, HermiT CONSISTENT, violation test PASS. Runtime ~10 minutes (the 96 individuals add substantial tableau expansion work for HermiT).

## 6. Register Concepts Exercised

- **[[concept-weighted-relationships|B14]] (Weighted Relationships):** Core deliverable — 96 relationships now reified in OWL
- **B29 (OWL-Authoritative Axioms):** Axiom file unchanged; new weight individuals consistent with existing axioms
- **[[principle-model-generates-everything|A3]] (Model Generates Everything):** Weights generated from SysML annotations by the pipeline
- **[[principle-intrinsic-self-knowledge|A10]] (Intrinsic Self-Knowledge):** The [[concept-knowledge-graph|knowledge graph]] now knows its own inter-concept relationship strengths
- **[[principle-unity-principle|A11]] (Unity):** Same weight data that drives the console force-directed graph now exists in the knowledge graph
- **[[concept-non-constraining|J3]] (Non-Constraining):** Strength stored as xsd:string — explicitly designed for future evolution
- **B23 ([[concept-knowledge-graph|Correspondence Graph]]):** Extended with `WeightMappingRecord` type for full SysML-to-OWL traceability

## 7. Emergent Ideas

No new emergent ideas this session.

## 8. Tier 1 Principles Honoured

- **[[principle-model-generates-everything|A3]] (Model Generates Everything):** The 96 weight individuals are generated from SysML annotations, not hand-authored
- **[[principle-discipline-as-load-bearing-structure|A9]] (Discipline as Load-Bearing Structure):** Validation checks (duplicate detection, target resolution, reasoning) built into the pipeline
- **[[principle-intrinsic-self-knowledge|A10]] (Intrinsic Self-Knowledge):** The ontology now carries its own relationship strength data
- **[[concept-non-constraining|J3]] (Non-Constraining):** xsd:string strength representation keeps all future evolution paths open
- **J12 (Experimentation Before Convention):** Ordinal strength values are a starting point; the structure supports migration to richer models

## 9. Open Questions and Deferred Items

- **SPARQL validation suite:** The Phase 2 plan mentions extending the SPARQL suite, but no existing suite exists to extend. This is deferred — would be new work for a future session.
- **Reasoner performance:** HermiT took ~10 minutes with the 7-file stack including 96 individuals. Worth monitoring as the individual count grows. If reasoning time becomes prohibitive, consider ELK (faster, less expressive) for routine checks with HermiT reserved for full DL validation runs.
- **Priority B (carried forward):** Update CLAUDE.md for Code — carried forward from Session 116.
- **Console data source currency check:** Due ~Session 118 (10 sessions since last check at S110).
