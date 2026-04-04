---
tags:
  - session-report
date: 2026-04-04
status: current
session: 130
---
# Session 130 — Report

**Date:** 4 April 2026
**Type:** Planning
**Session focus:** W-009 — MVP implementation plan for CQC governance (S121-Q5).

---

## Summary

Session 130 produced the [[session-130-stage5-cqc-governance-mvp-plan|CQC Governance MVP implementation plan]], resolving W-009 (the only Priority A work item). This was a pure planning session — no implementation, no model changes.

### Context Reading

The session opened with a full O1 context read: [[ontara-workflow-development-guide|workflow guide]], [[session-130-preparation-note|preparation note]] (Session 129), [[ontara-ref-work-items|work item tracker]], [[ontara-ref-strategic-snapshot|strategic snapshot]] (Session 127), and [[ontara-ref-master-register|master register]] Tier 1. All standing reference documents are current — no staleness flags at O2.

The two governance discussion papers were read in full: the [[ontara-discussion-deontic-governance-architecture-2026-04-03|Deontic Governance Architecture paper]] (Session 121) and the [[ontara-discussion-deontic-owl-class-design-2026-04-03|OWL Class Design paper]] (Session 125). The existing test individuals (`ontology/governance/test-individuals.ttl`, Session 126) were also read. CQC's own guidance on Regulation 12 and the statutory text structure (Regulation 12(2)(a)–(i)) were researched from authoritative sources to ground the plan in the real regulatory content.

### Plan Produced

The plan formalises CQC Regulation 12 (Safe Care and Treatment) as the single regulation for the MVP — one regulation in full depth rather than many at surface level. Regulation 12 was chosen because: it has a clear two-level structure (12(1) parent + 9 sub-obligations), it touches multiple BMM concerns, it has concrete evidential requirements, it's clinically relevant to [[domain-gsl|GSL]], and the test individuals already model a skeleton of it.

Six implementation phases:

- **Phase A** — Normative instrument hierarchy (4 instruments, inter-instrument relationships)
- **Phase B** — Regulation 12 obligation decomposition (12(1) + 12(2)(a)–(i) + 3–5 guidance-level directives, all with full structural properties)
- **Phase C** — Framework and obligation group assembly
- **Phase D** — Knowledge graph loading and Robot + HermiT consistency check
- **Phase E** — SPARQL validation extension (7 new queries)
- **Phase F** — Documentation and governance close

Estimated 3–4 sessions. Critical path is Phase B (obligation decomposition requiring Ella's clinical domain knowledge).

### Design Decisions

Three design decisions were agreed:

| ID | Decision | Rationale |
|---|---|---|
| S130-D1 | Archive existing test individuals; author MVP in new `cqc-reg12-individuals.ttl` | Test fixtures have served their axiom verification purpose. MVP individuals are production-quality. Archiving preserves provenance. |
| S130-D2 | "Reasonably practicable" qualifier represented in `directiveContent` string, with note in `exceptionCondition` | Pragmatic for MVP. Captures legal reality without new structural elements. Promotable if pattern recurs (J3). |
| S130-D3 | Full integration of MVP individuals into reasoning pipeline | Production content, not test fixtures. Ontology stack grows from 9 to 10 files. Exercises ABox, not just TBox. |

### What Is Explicitly Out of Scope

Activation tier (BoundObligation, GovernanceFrameworkActivation), operational tier (ComplianceAssessment), other CQC regulations, [[domain-ears|Ears]] demonstrator binding (W-015, kept separate per agreement), ingestion pipeline automation, and console integration.

## Register Concepts

### Concepts exercised

The plan exercises [[ontara-ref-master-register|B30]] (deontic directive vocabulary), [[ontara-ref-master-register|B31]] (governance framework library), [[ontara-ref-master-register|B33]] (normative instrument taxonomy), and [[ontara-ref-master-register|B35]] (governance ontology module) — all through the lens of production CQC content rather than test fixtures. [[concept-knowledge-graph|B22]], [[concept-bfo-ontological-grounding|B23]], [[concept-three-stratum-knowledge-graph|B28]], [[concept-authority-zones|B29]], [[principle-deterministic-over-probabilistic|A6]], [[principle-discipline-as-load-bearing-structure|A9]], and [[concept-non-constraining|J3]] are also relevant.

### No new concepts registered

The plan exercises existing concepts. If the implementation reveals vocabulary gaps, those would be candidates for registration.

## Tier 1 Principles

| Principle | How honoured |
|---|---|
| [[principle-separation-representation-execution|A1]] (separation of representation and execution) | Governance obligations represented in OWL; compliance checking via reasoning, not ad hoc code |
| [[principle-deterministic-over-probabilistic|A6]] (deterministic/auditable reasoning) | All compliance logic via OWL 2 DL + SPARQL — inspectable, deterministic |
| [[principle-discipline-as-load-bearing-structure|A9]] (discipline) | Careful formalisation of statutory obligations; plan-before-build discipline; full close sequence |
| [[concept-co-evolution|J2]] (co-evolution) | Model content (governance individuals) created alongside tooling (SPARQL queries) to exercise it |
| [[concept-non-constraining|J3]] (non-constraining) | String-typed data properties (S125-D5) preserved; MVP scope bounded to not foreclose activation tier |

## Emergent Ideas

No new emergent ideas captured this session.
