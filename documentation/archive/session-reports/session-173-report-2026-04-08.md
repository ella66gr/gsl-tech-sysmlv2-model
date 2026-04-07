---
tags:
  - session-report
date: 2026-04-08
status: current
session: 173
---
# Session 173 — Report

**Date:** 8 April 2026
**Type:** Housekeeping / Discussion (mixed)
**Duration:** Short session — governance improvement + research paper review

---

## Summary

Session 173 addressed two targeted pieces of work, both arising from the Session 172 preparation note:

1. **Downstream concept note check convention (OW-13).** Added a lightweight mechanism to the [[ontara-workflow-guide|workflow guide]] to prevent [[ontara - concept-graph-index|concept graph]] notes from silently drifting when their source documents are refreshed. The convention requires Claude to scan `Concept Graph/principles/` and `Concept Graph/concepts/` for notes referencing a refreshed foundations paper and update stale source references — performed as part of C3 in the same session as the refresh. Added to §7.1 (new paragraph) and §12 (new known pitfall row). OW-13 updated to `incorporated` status in the [[ontara-ref-work-items|OW register]].

2. **[[ontara-research-(claude) - modelling-approaches|Modelling Approaches]] research paper review.** Reviewed the [[ontara-research-(claude) - modelling-approaches|Modelling Approaches]] research paper (Sessions 31/48) against the current state of the platform. Assessed exploitation level of all seven paradigms: state machines and rule-based/declarative are substantially exploited; Petri net/token flow and contract/interaction are partially exploited; dataflow, event-driven, and agent-based are minimally or not exploited. The contract/interaction paradigm was identified as the most architecturally interesting underexploited area for GSL. Updated the research paper's Related Documents section (two superseded wikilinks corrected to current versions, three new links added).

3. **[[ontara-ref-modelling-paradigms|Modelling Paradigm Reference]] created.** New standing reference document (`ontara-ref-modelling-paradigms.md`) tabulating all seven paradigms with: core strength, current exploitation status, concrete future applications, when-to-consider triggers, and notes. Placed in `02 Ontara Development/Ontara Reference & Guides/`. Added to the [[ontara-ref-work-items|Document Currency Register]] with 20-session backstop threshold plus stage/phase boundary trigger.

## Register Concepts Exercised

- **[[principle-discipline-as-load-bearing-structure|A9]] (Discipline as load-bearing structure)** — the downstream concept note check formalises a governance gap into a repeatable practice
- **[[principle-deterministic-over-probabilistic|A6]] (Deterministic/auditable reasoning)** — paradigm review confirmed this as substantially served by the [[ontara-discussion-institutionalised-reasoning-2026-04-05|reasoning metamodel]]
- **[[concept-co-evolution|J2]] (Co-evolution)** — paradigm table notes that when a paradigm is exercised in the model, corresponding tooling must exist
- **[[concept-non-constraining|J3]] (Non-constraining)** — paradigm table explicitly notes that paradigm choices should not foreclose future paradigm adoption
- **[[principle-two-meta-model-distinction|A4]] (Two meta model distinction)** — paradigm review maps paradigms to BMM vs SMM (state machines/contracts primarily BMM; dataflow/event-driven primarily SMM)

## Emergent Ideas Captured

None this session.

## Observations and Watchpoints

None surfaced beyond what is already captured in the paradigm reference document itself (exploitation status assessments, cross-paradigm observations, contract/interaction paradigm as key GSL gap).

## Tier 1 Principles Relevant to This Session

- **[[principle-discipline-as-load-bearing-structure|A9]]** — both deliverables are governance improvements that propagate reliability through disciplined practice
- **[[concept-non-constraining|J3]]** — the paradigm review explicitly checked that underexploited paradigms remain architecturally accommodatable
- **[[concept-co-evolution|J2]]** — flagged in the paradigm table as a standing cross-check for future paradigm adoption

## Governance Actions

- [[ontara-workflow-guide|Workflow guide]] §7.1 amended (downstream concept note check convention added)
- [[ontara-workflow-guide|Workflow guide]] §12 amended (new known pitfall row)
- OW-13 status updated from `active` to `incorporated` in [[ontara-ref-work-items|OW register]]
- [[ontara-research-(claude) - modelling-approaches|Modelling Approaches]] research paper Related Documents updated (2 stale wikilinks fixed, 3 new links added)
- [[ontara-ref-modelling-paradigms|Modelling Paradigm Reference]] created and added to [[ontara-ref-work-items|Document Currency Register]]
