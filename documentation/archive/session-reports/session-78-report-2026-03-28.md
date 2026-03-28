# Session 78 Report — StakeholderModel Detailed Design

**Date:** 28 March 2026
**Session type:** Discussion (with housekeeping)
**Previous session:** 77 (27 March 2026)

---

## Contents

- [§1. Summary](#1-summary)
- [§2. Housekeeping: Contents Index Convention](#2-housekeeping-contents-index-convention)
- [§3. Open Question Resolution](#3-open-question-resolution)
- [§4. Element Attribute Design](#4-element-attribute-design)
- [§5. New Enums](#5-new-enums)
- [§6. Conceptual Weight Design](#6-conceptual-weight-design)
- [§7. Deliverables](#7-deliverables)
- [§8. Register Concepts Exercised](#8-register-concepts-exercised)
- [§9. Tier 1 Principles](#9-tier-1-principles)
- [§10. Emergent Ideas](#10-emergent-ideas)
- [§11. Open Questions and Deferred Items](#11-open-questions-and-deferred-items)

---

## 1. Summary

Session 78 completed the detailed design for the six [[concept-stakeholder-model|StakeholderModel]] General elements proposed in [[session-76-report-2026-03-27|Session 76]]. All four open questions from the [[ontara-discussion-stakeholder-model-and-bsmm-vocabulary-2026-03-27|Session 76 discussion paper]] (§9) were resolved, typed attributes were designed for each element, three new enums were introduced, and conceptual weight design was produced for ~20 new weighted relationship annotations. A self-contained Claude Code instruction set was also prepared for retrofitting contents indices across ~28 vault documents.

The session was primarily discussion with a housekeeping component (contents index convention).

---

## 2. Housekeeping: Contents Index Convention

A new standing instruction was added to the [[ontara-workflow-development-guide|workflow guide]] §5 (Key Document Specifications): discussion papers, reference documents, and other substantial documents (roughly 5+ sections) must include a linked contents index immediately below the document header. Session reports, preparation notes, and short documents are exempt unless unusually long. Convention established Session 78.

Both target folders were scanned to produce a list of ~28 documents needing contents index retrofitting:

- **Reference & Guides:** 10 documents qualify (workflow guide, strategic snapshot, vision reference, master register, weighted relationship references, CLI reference, tooling guide, shell commands, wildcard import analysis). 5 short documents excluded.
- **Exploratory & Discussion Papers:** ~18 discussion papers qualify. All lack contents indices.

A self-contained Claude Code instruction set was prepared for this batch task. The four foundations papers in `04 Ontara Foundations` already have indices (added Session 64) and are not in scope.

---

## 3. Open Question Resolution

Four open questions from the Session 76 discussion paper §9 were resolved through structured discussion, with each question evaluated on both conceptual and practical/engineering grounds.

### Q1: ParticipationModel distinctness

**Decision: Separate sibling element.** Six independent `part def`s in `BusinessModel::StakeholderModel`, no specialisation hierarchy.

Conceptually, ParticipationModel has a different orientation from the other five elements — it faces inward at the customer's co-production role rather than outward at external entities. It connects to a distinct set of architectural concepts ([[principle-patient-autonomy|A7]], [[concept-agency-classification|H2]], [[ontara-discussion-service-participation-model-2026-03-21|O26]]).

The specialisation alternative was rejected on engineering grounds: undefined weight inheritance semantics, no console support for subtype rendering, no generator support for specialisation extraction, no precedent in the BMM, and coupling risk from parent evolution.

### Q2: GovernanceMapping boundary

**Decision: Dual classification with typed reference.** Rule content in GovernanceMapping, relationship structure in StakeholderModel, linked by `ref relatedGovernanceRequirements : GovernanceRequirement`.

The independence test was established as the design guideline: could this information exist independently in one concern without the other? The boundary was validated against CQC (GSL), COSHH/environmental health (Suds), food safety (Cafe), and animal welfare (Paws).

### Q3: Relationship Awareness

**Decision: No cross-cutting dimension.** Activity Awareness works because activities are the common currency across all concerns. Stakeholder relationships affect multiple concerns but do so through existing mechanisms — not as an atomic unit that every concern produces or consumes. The concern-level treatment is sufficient. Not foreclosed ([[concept-non-constraining|J3]]).

### Q4: Relationship nature taxonomy

**Decision: Closed `RelationshipNature` enum with six values** — regulatory, contractual, professional, advisory, commissioning, peer. Tailored extensions via `:>>` redefinition ([[concept-general-tailored-decomposition|B11]]).

The closed-vs-open decision was evaluated on engineering grounds: closed enums support exhaustive generator matching, tailored comprehension per value, nature-specific constraint checking, and avoid the "other" dumping ground. Consistent with existing BMM enum practice.

---

## 4. Element Attribute Design

Full attribute designs were produced for all six elements, following the established BMM pattern (String for qualitative, typed enums for structured classification, ref for cross-element connections):

- **StakeholderRelationship** — 9 attributes + 1 typed ref to GovernanceRequirement. The core abstraction for typed external relationships.
- **CooperativeArrangement** — 8 attributes. Distinguished by `sharedOutcome` — the thing neither party can deliver alone.
- **ReferralPathway** — 8 attributes including `direction : ReferralDirection` enum. Structured routes for directing/receiving work.
- **ExternalDependency** — 8 attributes including `criticality : DependencyCriticality` enum. Asymmetric reliance with contingency planning.
- **CommunityRelationship** — 6 attributes. Deliberately lighter on governance — community relationships are constitutive, not contractual.
- **ParticipationModel** — 7 attributes + 1 typed ref to ServiceOffering. Co-production patterns connecting the relational boundary back to the internal logic.

Two cross-concern typed references were established:
- `StakeholderRelationship.relatedGovernanceRequirements → GovernanceRequirement` (Q2 implementation)
- `ParticipationModel.relatedServiceOffering → ServiceOffering` (connecting StakeholderModel to ServiceConcept)

All elements were validated across all four demonstrator domains (§6 of the discussion paper).

---

## 5. New Enums

Three new closed enums introduced for `Foundation::CommonTypes`:

| Enum | Values | Used by |
|---|---|---|
| `RelationshipNature` | regulatory, contractual, professional, advisory, commissioning, peer | StakeholderRelationship |
| `ReferralDirection` | inbound, outbound, bidirectional | ReferralPathway |
| `DependencyCriticality` | essential, important, convenient | ExternalDependency |

---

## 6. Conceptual Weight Design

A middle-path approach was adopted for weighted relationships: conceptual weight design now (capturing which elements connect, at what strength, with what rationale), with annotation application during the SysML implementation session.

~16 outgoing weights were designed across the six elements (5 strong, 11 moderate), plus ~4 incoming weights from existing elements. Estimated total weight count after implementation: ~99 (79 existing + ~20 new). The strong-to-moderate ratio (~31%) is consistent with the existing model (33%).

Cross-element weights within StakeholderModel were identified as candidates for assessment during implementation.

---

## 7. Deliverables

| Deliverable | Type | Location |
|---|---|---|
| [[ontara-discussion-stakeholder-model-detailed-design-2026-03-28|StakeholderModel detailed design discussion paper]] | Discussion paper | Container artifact → vault `05 Ontara Exploratory & Discussion Papers` |
| Claude Code instruction: contents indices | Code instruction | Container artifact (for Ella to use with Claude Code) |
| Workflow guide §5 update | Direct edit | Vault (applied via MCP) |

---

## 8. Register Concepts Exercised

**Directly exercised:** [[concept-stakeholder-model|C7]] (StakeholderModel), C7a–C7f (all six General elements — detailed design completed), [[concept-horizontal-mappings|B12]] (horizontal mappings — two typed refs established), [[concept-weighted-relationships|B14]] (weighted relationships — conceptual weight design for ~20 new annotations), [[concept-general-tailored-decomposition|B11]] (General/Tailored decomposition).

**Governance boundary clarified:** Interaction between C7/C7a and C5 (GovernanceMapping) — dual-classification design guideline established.

**Connected to but not directly worked:** A7 (patient autonomy — connected via ParticipationModel), H2 (agency classification — connected via ParticipationModel), O26 (service participation framework — ParticipationModel is the StakeholderModel expression of this).

---

## 9. Tier 1 Principles

| Principle | How honoured |
|---|---|
| A4 (two meta model distinction) | All six elements designed as BMM concepts with clear boundary from BSMM |
| A9 (discipline) | Systematic resolution of all open questions before attribute design; structured engineering evaluation for each decision |
| A11 (unity principle) | New elements will participate in the weighted relationship model; conceptual weight design produced |
| A13 (multi-tenancy) | All elements General-level; validated across four domains |
| J1 (cross-domain validation) | All six elements validated across Cafe, Suds, Paws, GSL |
| J2 (co-evolution) | Console tooling assessed — generator pipeline will pick up new elements automatically; no console code changes required |
| J3 (non-constraining) | Relationship Awareness not foreclosed; closed enums extensible via Tailored `:>>`; sibling pattern preserves element independence |

---

## 10. Emergent Ideas

No new emergent ideas captured this session. The work was resolution and refinement of existing concepts rather than discovery of new ones.

---

## 11. Open Questions and Deferred Items

- **Tailored StakeholderModel elements** (from Session 76 §9.5) — healthcare-specific extensions (SharedCareProtocol, ClinicalReferralPathway, PatientAdvocacyRelationship) deferred to GSL instantiation scoping. Not needed for General vocabulary implementation.
- **[[ontara-service-business-meta-modelling-v2|Service Business Meta Modelling v2]] revision** — the foundations paper needs a sixth section for StakeholderModel. Scoped as significant work; deferred to a dedicated session.
- **Graph rendering refinements** (viewport fitting, bidirectional edge separation) — carried forward from Sessions 75/76/77. Code work.
- **KerML reserved word check** — `stakeholder` is a known SysML contextual keyword. Must verify all attribute names before SysML implementation.
- **Contents index retrofitting** — Claude Code instruction prepared; Ella to run when convenient.

---

*Session 78 report written 28 March 2026.*
