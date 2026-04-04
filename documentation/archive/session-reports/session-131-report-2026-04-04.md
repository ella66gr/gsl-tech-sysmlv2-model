---
tags:
  - session-report
date: 2026-04-04
status: current
session: 131
---
# Session 131 — Report

**Date:** 4 April 2026
**Type:** Implementation
**Session focus:** CQC Governance MVP — Phases A–E (normative instruments, obligation decomposition, framework assembly, reasoning, SPARQL validation).

---

## Summary

Session 131 implemented Phases A–E of the [[session-130-stage5-cqc-governance-mvp-plan|CQC Governance MVP plan]] (Session 130, W-009). This was the first real exercise of the deontic governance vocabulary ([[ontara-ref-master-register|B30]], [[ontara-ref-master-register|B31]], [[ontara-ref-master-register|B33]], [[ontara-ref-master-register|B35]]) with production-quality regulatory content.

### What Was Built

**Phase A — Normative instrument hierarchy.** Four normative instrument individuals authored in `ontology/governance/cqc-reg12-individuals.ttl`:

- Health and Social Care Act 2008 (PrimaryLegislation)
- HSCA 2008 (Regulated Activities) Regulations 2014, SI 2014/2936 (SecondaryLegislation)
- CQC Guidance for Providers on Meeting the Regulations (StatutoryGuidance)
- CQC Scope of Registration Guidance (StatutoryGuidance)

Inter-instrument relationships: Regulations 2014 `implementsInstrument` HSCA 2008; both CQC guidance documents `interpretsInstrument` Regulations 2014.

**Phase B — Regulation 12 obligation decomposition.** Complete formalisation of CQC Regulation 12 (Safe Care and Treatment):

- 1 parent obligation: Regulation 12(1) with `hasComponentDirective` to all 9 sub-obligations
- 9 sub-obligations: Regulation 12(2)(a) through 12(2)(i), each with full structural properties (`directiveContent`, `applicabilityCondition`, `evidentialSpecification`, `sourceReference`, `hasContentModality`, `hasTemporalScope`, `hasSanctionSeverity`, `derivesFrom`), plus `freshnessRequirement` where applicable and `exceptionCondition` on 12(2)(b)
- 5 guidance-level directives derived from CQC Guidance for Providers:
  - GL-1: Risk assessment methodology (decomposes 12(2)(a))
  - GL-2: Staff competence in gender identity healthcare (decomposes 12(2)(c))
  - GL-3: Medicines management in gender-affirming care (decomposes 12(2)(g))
  - GL-4: Risk-proportionate approach (Permission, from general CQC guidance)
  - GL-5: Multi-agency safety in shared care (decomposes 12(2)(i))

**Phase C — Framework and group assembly.** One `ObligationGroup` ("Safe", CQC Key Question S1) and one `GovernanceFramework` ("CQC Fundamental Standards (Healthcare) — Regulation 12 MVP") with all 15 directives contained, all 4 source instruments linked, and all directives assigned to the Safe group.

**Phase D — Reasoning.** Robot + HermiT: CONSISTENT. Full 10-file ontology stack (9 existing + MVP individuals). No contradictions. Domain expert review of directive content accepted by Ella — precise evidential specifications and freshness requirements are refinable through future tooling (see [[ontara-workflow-emergent-ideas-log|E022]]).

**Phase E — SPARQL validation.** Seven new queries (Q17–Q23) added to `scripts/validate_kg.py` in a "Governance-MVP" group. All 23 queries pass (23/23 PASSED). No regression on existing Q1–Q16.

### Design Decisions Applied

| ID | Decision | How Applied |
|---|---|---|
| S130-D1 | Archive test individuals; author MVP in new file | `test-individuals.ttl` archived as `test-individuals-s126-archive.ttl`. Original renamed to `DUPLICATE-TO-DELETE-test-individuals.ttl`. MVP authored in `cqc-reg12-individuals.ttl`. |
| S130-D2 | "Reasonably practicable" in directiveContent + exceptionCondition | 12(2)(b) carries the qualifier in its `directiveContent` string. `exceptionCondition` notes the Regulation 22 defence. |
| S130-D3 | Full pipeline integration | `reason_kg.py` updated to reference `cqc-reg12-individuals.ttl`. `catalog-v001.xml` updated. Ontology stack is now 10 files. |

### Pipeline and Tooling Changes

- `scripts/reason_kg.py`: file list updated — `test-individuals.ttl` → `cqc-reg12-individuals.ttl`
- `ontology/governance/catalog-v001.xml`: new entry for `cqc-reg12-individuals.ttl`
- `scripts/validate_kg.py`: 7 new SPARQL queries (Q17–Q23) in "Governance-MVP" group. Total query count: 23.

### MVP Individual Count

| Category | Count |
|---|---|
| Normative instruments | 4 |
| Statutory obligations (parent + 9 sub) | 10 |
| Guidance-level obligations | 4 |
| Guidance-level permission | 1 |
| Obligation group | 1 |
| Governance framework | 1 |
| **Total individuals** | **21** |

### Feedback Received

Ella noted that reviewing and editing `.ttl` files in VS Code (with Stardog RDF syntax highlighting) is workable for now, but Ontara needs domain-aware governance editing tooling for non-technical domain experts and for rapid iterative refinement. This was captured as E022.

## Register Concepts

### Concepts exercised

- [[ontara-ref-master-register|B30]] (deontic directive vocabulary) — first real-world exercise with CQC Regulation 12
- [[ontara-ref-master-register|B31]] (governance framework library) — first GovernanceFramework individual from real regulatory content
- [[ontara-ref-master-register|B33]] (normative instrument taxonomy) — four instrument types exercised (PrimaryLegislation, SecondaryLegislation, StatutoryGuidance ×2) with inter-instrument relationships
- [[ontara-ref-master-register|B35]] (governance ontology module) — extended from TBox-only to TBox + ABox with production content
- [[concept-knowledge-graph|B22]] (knowledge graph) — governance individuals in the default graph
- [[concept-bfo-ontological-grounding|B23]] (OWL 2 DL) — all individuals typed as BFO-grounded classes
- [[concept-three-stratum-knowledge-graph|B28]] (three-stratum graph) — domain graph content
- [[concept-authority-zones|B29]] (authority zones) — OWL-authoritative, hand-authored individuals

### No new concepts registered

The session exercised existing concepts. No structural vocabulary gaps were revealed.

### Emergent ideas captured

- **[[ontara-workflow-emergent-ideas-log|E022]]** — Governance ontology editing tooling. Domain-aware UI for reviewing, editing, and validating governance content without requiring Turtle syntax knowledge. Captured, not yet routed.

## Tier 1 Principles

| Principle | How honoured |
|---|---|
| [[principle-separation-representation-execution|A1]] (separation of representation and execution) | Governance obligations represented in OWL; compliance checking via reasoning, not ad hoc code |
| [[principle-self-describing-system|A2]] (self-describing system) | Governance framework carries its own formalisation provenance, endorsement status, and currency date |
| [[principle-deterministic-over-probabilistic|A6]] (deterministic/auditable reasoning) | All compliance logic via OWL 2 DL + SPARQL — inspectable, deterministic, reproducible |
| [[principle-discipline-as-load-bearing-structure|A9]] (discipline) | Faithful formalisation of statutory obligations; plan-before-build; full close sequence |
| [[concept-co-evolution|J2]] (co-evolution) | Model content (governance individuals) created alongside tooling (SPARQL queries) to exercise it |
| [[concept-non-constraining|J3]] (non-constraining) | String-typed data properties preserved (S125-D5); MVP scope bounded to not foreclose activation tier |

## Open Questions

None new. The existing open questions (W-013 decomposition granularity, W-014 legislative cross-references) remain relevant but were not directly addressed — the MVP exercises the vocabulary at one regulation's depth, which will inform answers to those questions when further regulations are formalised. See the [[ontara-ref-work-items|work item tracker]] for current status.

---
