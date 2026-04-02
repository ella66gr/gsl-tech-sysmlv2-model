---
tags:
  - session-report
date: 2026-04-02
status: current
session: 112
---
# Session 112 Report — 2 April 2026

**Session type:** Implementation (Chat + Protégé)
**Focus:** Stage 5 Phase 2 Step 1 — Disjointness axioms

---

## Summary

Session 112 began Block A of the [[session-111-stage5-phase2-plan|Stage 5 Phase 2 plan]] ("Ontological Enrichment, Reasoning, and Console Integration"). The session delivered the first hand-authored OWL axiom file for the [[ontara-service-business-meta-modelling|Ontara BMM]], declaring the six concern groups as mutually disjoint. This is the first time the platform has used Protégé for ontology authoring, and the first time a HermiT reasoner has been run against the Ontara ontology.

---

## What Was Done

### Protégé setup

Ella downloaded and installed Protégé Desktop (v5.6.x) on macOS. The stock installation includes HermiT and Pellet reasoners — no additional plugins were needed.

### Axiom design

The disjointness axiom structure was designed collaboratively in Chat before Protégé work began:

- **Six union classes** — one per BMM concern group (`ServiceConceptElement`, `ActivityModelElement`, `ResourcePlanningElement`, `FinancialPlanningElement`, `GovernanceMappingElement`, `StakeholderModelElement`). Each is an `owl:equivalentClass` of the union of its member classes.
- **One `owl:AllDisjointClasses` declaration** across the six union classes, asserting that no class can belong to more than one concern group.

A design decision was made regarding [[concept-service-subject|ServiceSubject]] and [[concept-service-participant|ServiceParticipant]] (BFO:Role elements within ServiceConcept): these were kept in ServiceConceptElement because concern group membership is orthogonal to BFO category. The same reasoning applies to Channel (Role) in ServiceConcept, ResourceInstance (Role) in ResourcePlanning, and Capability (Disposition) in ResourcePlanning.

The union classes are ontological housekeeping — classification infrastructure with no BFO parent. They are not domain concepts and will not appear in the [[ontara-ref-master-register|Master Concept Register]].

### Axiom file production and import

Claude produced `ontara-bmm-axioms.ttl` as a container artifact. Ella opened it in Protégé alongside the pipeline-generated `ontara-bmm.ttl` (from the [[concept-knowledge-graph|knowledge graph]] pipeline). The import resolution required pointing Protégé at the local `ontara-bmm.ttl` file to resolve the `https://ontara.dev/ontology/bmm/` namespace URI. All 34 class references resolved correctly.

Protégé metrics confirmed: 6 EquivalentClasses axioms, 1 DisjointClasses axiom, 41 logical axioms total (34 SubClassOf from the imported BMM + 6 EquivalentClasses + 1 DisjointClasses).

### HermiT consistency check

HermiT was run from within Protégé. The ontology was confirmed consistent with no unsatisfiable classes.

### Deliberate violation tests

Two tests were performed to prove the disjointness axioms are operationally effective:

1. **CostDriver** (a FinancialPlanning member) was asserted as a subclass of ServiceConceptElement and StakeholderModelElement. After re-running HermiT, CostDriver was correctly flagged as **unsatisfiable** (equivalent to `owl:Nothing`), confirming the reasoner catches cross-concern misclassification.

2. **ExternalDependency** (a StakeholderModel member) was asserted as a subclass of StakeholderModelElement. This was correctly **accepted** as consistent — ExternalDependency genuinely belongs to that group. This accidental positive test provided a useful additional validation.

The violations were removed after testing.

### File saved to repo

The validated axiom file was saved from Protégé as Turtle to `ontology/axioms/ontara-bmm-axioms.ttl` — a new directory in the repo separating hand-authored ([[ontara-ref-master-register|OWL-authoritative, B29]]) axioms from pipeline-generated ontology files. A tautological self-subclass assertion (`ServiceConceptElement rdfs:subClassOf ServiceConceptElement`) left over from the testing was cleaned up via MCP. Protégé also generated a `catalog-v001.xml` in the same directory.

### Design decision confirmed

**S111-D4** (axiom file strategy): Single file `ontara-bmm-axioms.ttl` — confirmed. Steps 2 and 3 will add object property declarations and restrictions to this same file.

---

## Repo Changes

| Change | Path | Notes |
|---|---|---|
| New directory | `ontology/axioms/` | Hand-authored OWL axioms (OWL-authoritative, B29) |
| New file | `ontology/axioms/ontara-bmm-axioms.ttl` | Six union classes, one AllDisjointClasses, imports `ontara-bmm:` |
| New file | `ontology/axioms/catalog-v001.xml` | Protégé catalog (auto-generated) |

---

## Register Concepts Exercised

| Concept | How exercised |
|---|---|
| [[concept-ontology-stack\|B18]] (BFO — mandatory) | BFO categories inform disjointness axiom design (Role vs GDC distinction discussed) |
| [[concept-knowledge-graph\|B22]] (Knowledge graph as canonical store) | KG moves from taxonomy toward richly axiomatised ontology |
| [[ontara-ref-master-register\|B23]] (OWL 2 DL as mandatory) | First full OWL 2 DL reasoner (HermiT) run against Ontara ontology |
| [[ontara-ref-master-register\|B28]] (Three-stratum graph) | Axiom file will load alongside domain graph in GraphDB |
| [[ontara-ref-master-register\|B29]] (Authority zones) | Axioms are OWL-authoritative — hand-authored in Protégé, not pipeline-generated |
| [[principle-model-generates-everything\|A3]] (Model generates everything) | Pipeline-generated `ontara-bmm.ttl` imported as foundation for hand-authored axioms |
| [[principle-discipline-as-load-bearing-structure\|A9]] (Discipline as load-bearing structure) | Formal plan followed, validation at each step, deliberate violation testing |
| [[principle-intrinsic-self-knowledge\|A10]] (Intrinsic self-knowledge) | Disjointness constraints are declared knowledge about the ontology's own structure |

No new register concepts were introduced. No gaps identified.

---

## Emergent Ideas

No new emergent ideas captured this session.

---

## Open Questions

None from this session. The remaining design decisions (S111-D1, D2, D3, D5) remain open but are not needed until their respective steps. See [[session-111-stage5-phase2-plan|Phase 2 plan]] §4.

---

## Observations

This was Ella's first substantive use of Protégé. The tool proved straightforward for the axiom authoring workflow: import existing Turtle, inspect the class hierarchy, run the reasoner, perform violation tests, save as Turtle. The [[ontara-discussion-bfo-type-mapping-2026-04-01|BFO type mapping paper]] §5 provided the element-to-concern-group membership data. The Protégé → Turtle → GraphDB pipeline is now established as the workflow for hand-authored axioms ([[ontara-ref-master-register|B29]]).

The new `ontology/axioms/` directory establishes a clean separation in the repo:

```
ontology/
  axioms/          ← hand-authored (OWL-authoritative)
  config/          ← mapping rules, IRI lookups
  imports/         ← BFO, CCO, IAO
generated/
  ontology/        ← pipeline-generated (SysML-authoritative)
```

This mirrors the [[ontara-ref-master-register|authority zones architecture (B29)]] at the filesystem level.

---

*Session 112 report written 2 April 2026.*
