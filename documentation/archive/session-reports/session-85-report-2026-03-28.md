---
tags:
  - session-report
date: 2026-03-28
status: complete
session: 85
---
# Session 85 — Report

**Date:** 28 March 2026
**Type:** Discussion + Document Production
**Continuity:** Follows [[session-84-report-2026-03-28|Session 84]] (campus walk Part 1 — Sections 1–6, [[ontara-ref-master-register|B27]] registered, [[ontara-workflow-emergent-ideas-log|E016]] captured)

---

## Summary

Session 85 completed the campus walk workstream begun in Session 84. The session described the remaining 14 [[ontara-ref-master-register|architectural sections (B27)]] of the [[concept-dual-stack-architecture|dual-stack architecture]] — the right stack (Sections 7–11), the cross-cutting [[concept-reflective-simulation|reflective simulation]] (Section 12), the green container (Section 13), and the infrastructure sections (Sections 14–20) — using the same five-facet template established in Session 84 (purpose, representational modality, persistence, interfaces, [[domain-paws|Paws]] illustration).

The session then produced a comprehensive discussion paper — **"The Ontara Campus: Architectural Sections of the Dual-Stack Architecture"** ([[ontara-discussion-architectural-campus-walk-2026-03-28|discussion paper]]) — consolidating all 20 section descriptions into a single, structured, vault-ready document with six architectural observations, a summary table, register connections, and nine open questions.

This completes Priorities A and B from the [[session-85-preparation-note|Session 85 preparation note]]. Priority C (implementation plan scoping for `ArchitecturalSection` part def, `@ArchitecturalLocation` metadata def, generator extension, console view) was deferred to a future session.

---

## Work Completed

### 1. Campus walk Part 2 — Sections 7–20 described

All 14 remaining sections were described using the five-facet template. The descriptions are captured in full in the [[ontara-discussion-architectural-campus-walk-2026-03-28|discussion paper]].

**Right stack (Sections 7–11):**

| # | Section | Key points |
|---|---|---|
| 7 | System ontological categories | BFO-typed system constructs (Process, Information Content Entity, Process Boundary, Quality). OWL 2 DL. The topmost horizontal mapping — ontological categories of business entities constrain what system entities can realise them. |
| 8 | BSMM General vocabulary | Domain-neutral system concepts. Six capability groups ([[ontara-ref-master-register|B25]]). Architectural role axis ([[ontara-ref-master-register|B26]]). Many-to-many mappings to BMM. Designed (Session 76) but not yet implemented — the gap [[ontara-ref-master-register|B8]] acknowledges. |
| 9 | System instance | Concrete system configuration per tenant. Currently implicit in the [[domain-cafe|coffee shop demonstrator]]. Target: explicit SysML v2 declarations. |
| 10 | System domains | Running software modules. Dual persistence (model + operational stores). The genuine system descriptions — the Session 73 correction applied in reverse. |
| 11 | [[concept-operational-simulation|Operational simulation]] | The BSMM made live. Temporal workflows with human actors and connected applications as participants. Semantic lineage preserved end-to-end from BFO through BMM through BSMM to running workflow. The pipeline crossing point. |

**Cross-cutting (Section 12):**

| # | Section | Key points |
|---|---|---|
| 12 | [[concept-reflective-simulation|Reflective simulation]] | Cross-cutting vertical capability reading from all layers. Writes to operator (guidance) and [[concept-knowledge-graph|knowledge graph]] (derived knowledge). [[concept-coordinate-space-snapshots|Coordinate space snapshots (L8)]] with five [[concept-epistemic-modality|epistemic types (B17)]]. Advisory, not directive. Internal processing formalism is an open question. |

**Green container (Section 13):**

| # | Section | Key points |
|---|---|---|
| 13 | Rules and constraints | Governs dynamic behaviour inside the green container. Critical distinction: constraint *definitions* (structural, above container) vs constraint *enforcement* (dynamic, inside container). Maps to [[principle-clinical-governance-first-class|governance traceability chain (A8)]]. Multiple rule types: eligibility, CLP(FD), safety, governance, probabilistic. |

**Infrastructure (Sections 14–20):**

| # | Section | Key points |
|---|---|---|
| 14 | Terminology and information carriers | SNOMED CT, openEHR, ICD, FHIR, AQL for clinical tenants. Thin for non-clinical tenants. Tenant variation as architectural content. |
| 15 | [[ontara-ref-master-register|Mapping ontology (B24)]] | OWL ↔ SysML bridge. Existence committed, design deferred. openCAESAR may provide infrastructure. Makes [[concept-knowledge-graph|B22]] technically feasible. |
| 16 | [[concept-knowledge-graph|Knowledge graph (B22)]] | OWL 2 DL + triple store. Eventual canonical store. Everything converges here: ontological axioms, meta model vocabulary, instance data, [[concept-weighted-relationships|weighted relationships]], [[concept-coordinate-space-snapshots|coordinate space snapshots]], [[concept-reflective-simulation|reflective simulation]] derived knowledge. |
| 17 | SysML v2 | Engineering projection. Current primary source of truth (11 core files, ~73 packages). Target: projection from [[concept-knowledge-graph|KG]], condition: round-trip fidelity. |
| 18 | openEHR | Clinical data architecture. Empty for [[domain-paws|Paws]], central for [[domain-gsl|GSL]]. Tenant activation determined by [[concept-multi-tenancy|A13]]. |
| 19 | Temporal | Execution infrastructure for [[concept-operational-simulation|L5]]. Durable workflow orchestration. Generated from the model via compilation pipeline. |
| 20 | Operator | The human business operator — the guidance target. Every other section exists to serve the operator's understanding and agency. [[concept-valence|Valence (L7)]] is the operator's evaluative declarations. The Ontara Console is the primary interface. |

### 2. Discussion paper produced

The **[[ontara-discussion-architectural-campus-walk-2026-03-28|"The Ontara Campus" discussion paper]]** consolidates all 20 section descriptions into a single document. Beyond the section descriptions, it includes:

- **§9 — Architectural Observations** — six cross-cutting insights: the formalism gradient, the symmetry pattern, tenant variation as architectural content, the operator as architectural anchor, the definition/enforcement distinction, and the pipeline crossing.
- **§10 — Summary Table** — all 20 sections at a glance (group, formalism, persistence, Paws density).
- **§11 — Register Connections** — 13 T1 principles honoured, 17 concepts exercised.
- **§12 — Open Questions** — nine questions for future work.
- **Related Documents** — 16 linked documents.

The paper is filed in `05 Ontara Exploratory & Discussion Papers/Foundational Architecture/`.

### 3. Architectural observations

Six observations emerged from the campus walk that have architectural significance beyond the individual section descriptions:

1. **The formalism gradient** — OWL 2 DL at the top → SysML v2 in the middle → runtime execution at the bottom, with the [[ontara-ref-master-register|mapping ontology (B24)]] bridging the boundary.
2. **The symmetry pattern** — left and right stacks are structurally symmetric but the symmetry breaks in informative ways (capability vs concern organisation, many-to-many mappings, realisation complexity).
3. **Tenant variation as architectural content** — sections vary by tenant (openEHR is central for [[domain-gsl|GSL]], empty for [[domain-paws|Paws]]). This is [[concept-multi-tenancy|A13]] made spatially legible.
4. **The operator as architectural anchor** — every section's purpose can be stated in terms of what it contributes to the operator's understanding and agency.
5. **The definition/enforcement distinction** — constraint definition (structural, above the green container) vs constraint enforcement (dynamic, inside) maps to [[principle-clinical-governance-first-class|A8]].
6. **The pipeline crossing** — the [[ontara-discussion-paper-process-specification-layer|process specification layer]] pipeline crosses from Section 6 to Section 11. This is [[ontara-ref-master-register|B12]] at the most dynamic level.

---

## Register Concepts Exercised

| Concept | How exercised |
|---|---|
| [[concept-dual-stack-architecture\|B21]] (dual-stack architecture) | The entire session describes the dual-stack — all 20 sections |
| [[concept-knowledge-graph\|B22]] (knowledge graph) | Section 16 full description; target modality for every section |
| [[ontara-ref-master-register\|B23]] (OWL 2 DL mandatory) | Sections 1, 7, 15, 16 |
| [[ontara-ref-master-register\|B24]] (mapping ontology) | Section 15 — full description |
| [[ontara-ref-master-register\|B25]] (BSMM capability groups) | Section 8 — six groups |
| [[ontara-ref-master-register\|B26]] (architectural role axis) | Section 8 — four roles |
| [[ontara-ref-master-register\|B27]] (architectural section) | The concept this session completes |
| [[concept-ontology-stack\|B18]] (BFO mandatory) | Section 1 |
| [[concept-ontology-stack\|B19]] (ontology stack) | Section 2 |
| [[ontara-ref-master-register\|B8]] (BSMM implicit gap) | Section 8 — the gap being made explicit |
| [[concept-operational-simulation\|L5]] (operational simulation) | Section 11 — full description |
| [[concept-reflective-simulation\|L6]] (reflective simulation) | Section 12 — full description |
| [[concept-valence\|L7]] (valence) | Sections 12, 20 |
| [[concept-coordinate-space-snapshots\|L8]] (coordinate space snapshots) | Sections 12, 16 |
| [[concept-goal-seeking-computation\|L9]] (goal-seeking computation) | Sections 12, 16 |
| [[principle-two-meta-model-distinction\|A4]] (two meta model distinction) | §9.2 — the symmetry pattern |
| [[principle-intrinsic-self-knowledge\|A10]] (intrinsic self-knowledge) | Section 12, §9.4 — design-time to runtime |
| [[concept-multi-tenancy\|A13]] (multi-tenancy) | §9.3 — tenant variation as architectural content |
| [[concept-stakeholder-model\|StakeholderModel]] | Sections 3, 4 — sixth concern exercised |

### No new concepts introduced

B27 was introduced in Session 84. No new register concepts emerged from Session 85 — the session was consolidation, not extension.

---

## Emergent Ideas

No new emergent ideas. [[ontara-workflow-emergent-ideas-log|E016]] (`@ArchitecturalLocation` metadata def) was referenced throughout and remains the primary emergent idea from the campus walk workstream. Its routing is unchanged: design after campus walk content stabilises — which is now.

---

## Tier 1 Principles Honoured

| Principle | How honoured |
|---|---|
| [[principle-separation-representation-execution\|A1]] | Each section explicitly notes representational formalism and relation to execution |
| [[principle-self-describing-system\|A2]] | The campus walk is the system describing its own architecture |
| [[principle-model-generates-everything\|A3]] | Target: section descriptions as SysML metadata, extractable by generators |
| [[principle-two-meta-model-distinction\|A4]] | The dual-stack is A4 made spatial — both sides now fully described |
| [[principle-discipline-as-load-bearing-structure\|A9]] | Five-facet template applied consistently across all 20 sections |
| [[principle-intrinsic-self-knowledge\|A10]] | The architecture comprehends its own structural regions |
| [[principle-unity-principle\|A11]] | Same comprehension architecture applies to sections as to BMM elements |
| [[concept-co-evolution\|J2]] | Descriptions produced alongside console integration planning |
| [[concept-non-constraining\|J3]] | Each section notes current state and target, preserving KG-as-canonical direction |

---

## Open Questions

1. **Priority C deferred.** Implementation plan scoping for `ArchitecturalSection` part def, `@ArchitecturalLocation` metadata def ([[ontara-workflow-emergent-ideas-log|E016]]), generator extension, and console view — deferred to a future session. The campus walk content is now stable enough to proceed with design.
2. **Nine open questions in the discussion paper** (§12). These span SysML encoding, section numbering stability, BSMM vocabulary content, system ontological categories completeness, operational domain representation, reflective simulation formalism, and tenant activation model.

---

*Session 85 report — 28 March 2026 — GenderSense Limited*
