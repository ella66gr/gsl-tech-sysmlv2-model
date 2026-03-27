# Session 76 Report — 27 March 2026

**Session type:** Mixed (housekeeping + discussion)
**Date:** 27 March 2026

---

## Summary

Session 76 accomplished three things: [[ontara-workflow-development-guide|workflow guide]] refinements, vault version control setup, and a significant architectural discussion that identified a structural gap in the BMM and proposed its resolution.

The session began with two targeted workflow guide updates. First, a new close step C9a was added: after Ella confirms the repo commit/push, Claude updates the preparation note to record that archiving is complete, eliminating an unnecessary re-verification at the next session open. Second, the Obsidian vault was placed under git version control with a private GitHub remote (`gsl-obsidian-vault`), and a periodic reminder mechanism (every 5 sessions) was added to §7.1 and §13 of the workflow guide.

The substantive work was the BSMM vocabulary elaboration discussion from the [[session-75-preparation-note|Session 75 preparation note]]'s Priority C. The discussion proceeded through three phases: BSMM organising structure, BMM concern review, and the StakeholderModel proposal.

**BSMM vocabulary design decision.** Three approaches were evaluated for organising the BSMM General vocabulary: (A) mirror the BMM's concerns, (B) organise by system capability, (C) organise by architectural role. Approach A was rejected — one-to-one symmetry would ignore system engineering realities. Approaches B and C were evaluated against four engineering purposes (guide instantiation, enable generation, support horizontal mapping, ground the reflective simulation). Approach B won on three of four purposes; Approach C's advantage (richer typing for the [[concept-reflective-simulation|reflective simulation]]) is deferred. The adopted design is a **hybrid**: six capability groups as primary structure (Persistence & Data Management, Process Orchestration, Evaluation & Reasoning, Observation & Self-Knowledge, Integration & Communication, Identity & Access), with architectural role as a secondary classification axis (structural template, execution primitive, governance instrument, comprehension metadata). Many-to-many [[concept-horizontal-mappings|horizontal mappings (B12)]] to the BMM are accepted as the correct representation.

**StakeholderModel: a sixth BMM concern.** The BSMM discussion prompted Ella to question the solidity of the BMM's five concerns. Analysis revealed that all five are inward-facing — they describe the internal logic of the business. The relational dimension (how the business connects to, cooperates with, and jointly delivers value with external entities) is distributed across the five concerns but has no first-class home. Ella identified a cluster of concepts without a natural home: relationships, partnerships, commonality of endeavour, shared delivery, cooperative arrangements.

Three options were considered: a sixth concern, a cross-cutting dimension, or absorption into existing concerns. Option 3 was rejected as deferral dressed up. Option 2 was rejected as underpowered — relationships would never get their own vocabulary. Option 1 — a sixth concern — was adopted. The [[concept-non-constraining|J3 (non-constraining)]] argument was decisive: building the BSMM vocabulary against five concerns when there should be six would embed the gap structurally.

**StakeholderModel** is proposed with six General-level elements: `StakeholderRelationship`, `CooperativeArrangement`, `ReferralPathway`, `ExternalDependency`, `CommunityRelationship`, and `ParticipationModel`. All six elements have concrete content in all four demonstrator domains ([[domain-gsl|GSL]], [[domain-paws|Paws]], [[domain-cafe|Cafe]], [[domain-suds|Suds]]). A comprehensive [[ontara-discussion-stakeholder-model-and-bsmm-vocabulary-2026-03-27|discussion paper]] was produced capturing the reasoning, vocabulary, cross-domain validation, BSMM design decisions, and implications.

No implementation work was done. No model files were changed.

---

## Deliverables Produced

1. **Workflow guide updates** — C9a (preparation note handover update), vault git commit reminder in §7.1 and §13. Applied directly via MCP.
2. **Vault git repository** — initialised, committed, pushed to `ella66gr/gsl-obsidian-vault` (private). `.gitignore` created.
3. **Git quick reference** — [[ontara-ref-git-quick-reference|ontara-ref-git-quick-reference.md]] placed in the vault reference guides.
4. **Discussion paper** — [[ontara-discussion-stakeholder-model-and-bsmm-vocabulary-2026-03-27|StakeholderModel: A Sixth BMM Concern and the BSMM General Vocabulary]]. Container artifact for placement.
5. **[[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]] entry E015** — StakeholderModel inception capture. Applied directly via MCP.

---

## Register Concepts Exercised

| Concept | How exercised |
|---|---|
| [[principle-two-meta-model-distinction\|A4]] (two meta model distinction) | Central to both discussions — BSMM vocabulary elaboration and the StakeholderModel as a BMM concern |
| [[principle-discipline-as-load-bearing-structure\|A9]] (discipline as load-bearing structure) | Workflow guide refinements; vault version control; identifying the BMM gap before building on top of it |
| [[concept-co-evolution\|J2]] (co-evolution) | BSMM capability groups designed alongside BMM concern revision |
| [[concept-non-constraining\|J3]] (non-constraining) | The decisive argument for adding StakeholderModel now rather than deferring |
| [[principle-unity-principle\|A11]] (unity principle) | StakeholderModel elements will participate in the [[concept-weighted-relationships\|weighted relationship model]] |
| [[concept-coordinate-framework\|A12]] (coordinate framework) | Stakeholder relationships as trajectories; relationship health as coordinate axes |
| [[concept-multi-tenancy\|A13]] (multi-tenancy) | Each tenant has its own stakeholder landscape |
| [[concept-inception-capture\|J13]] (inception capture) | E015 captured immediately when the insight surfaced |
| [[concept-horizontal-mappings\|B12]] (horizontal mappings) | Many-to-many BSMM ↔ BMM mappings confirmed as the correct representation |
| [[concept-dual-stack-architecture\|B21]] (dual-stack architecture) | BSMM vocabulary designed for the right-hand stack |

---

## New Concepts Introduced

| Concept | Proposed tier | Status |
|---|---|---|
| StakeholderModel (sixth BMM concern) | T2 | Proposed — discussion paper produced |
| StakeholderRelationship | T3 | Proposed General BMM element |
| CooperativeArrangement | T3 | Proposed General BMM element |
| ReferralPathway | T3 | Proposed General BMM element |
| ExternalDependency | T3 | Proposed General BMM element |
| CommunityRelationship | T3 | Proposed General BMM element |
| ParticipationModel | T3 | Proposed General BMM element |
| BSMM capability groups (6) | T2 | Design decision — not yet implemented |
| Architectural role axis (4 roles) | T3 | Design decision — not yet implemented |

---

## Emergent Ideas Captured

E015 — StakeholderModel: a sixth BMM concern for the relational dimension of a service business. Full context, connections, cross-domain validation, and implications captured in the [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]].

---

## Open Questions

1. **ParticipationModel distinctness.** Is it a separate element or a type of StakeholderRelationship?
2. **GovernanceMapping boundary.** Dual-classification of regulatory relationships needs design guidelines.
3. **Weighted relationships for new elements.** ~6 new BMM elements will need weight annotations — phasing TBD.
4. **Tailored StakeholderModel elements.** Healthcare-specific extensions to be designed when GSL instantiation is scoped.
5. **Activity Awareness analogue.** Should StakeholderModel have a "Relationship Awareness" cross-cutting dimension?

---

## Tier 1 Principles Relevant to This Session

| Principle | How honoured |
|---|---|
| [[principle-two-meta-model-distinction\|A4]] | The two meta model distinction was the framing for the entire BSMM vocabulary discussion; StakeholderModel extends the BMM side |
| [[principle-discipline-as-load-bearing-structure\|A9]] | Three workflow discipline improvements made; structural gap identified and addressed before building on it |
| [[concept-co-evolution\|J2]] | BSMM vocabulary and BMM revision designed together, not sequentially |
| [[concept-non-constraining\|J3]] | The StakeholderModel decision was driven by the non-constraining principle — make the change before building the BSMM vocabulary against an incomplete BMM |
| [[principle-unity-principle\|A11]] | The hybrid BSMM design (capability groups + role axis) ensures the unity principle is preserved across both organising dimensions |

---

*Session 76 report written 27 March 2026.*
