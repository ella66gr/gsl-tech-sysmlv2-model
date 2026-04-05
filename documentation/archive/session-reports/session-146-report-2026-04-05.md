---
tags:
  - session-report
date: 2026-04-05
status: current
session: 146
---
# Session 146 — Report

**Date:** 5 April 2026
**Type:** Mixed (housekeeping + discussion)
**Session number:** 146

---

## Summary

Session 146 had two phases: housekeeping to clean up governance debt from the previous session, then a major architectural discussion on institutionalised reasoning that produced a substantial discussion paper establishing the conceptual framework for [[ontara-stage-4-high-level-plan-2026-03-21|Stage 7]].

### Phase 1: Housekeeping

The session opened with a methodical housekeeping pass ([[principle-discipline-as-load-bearing-structure|A9]]) to get things straight after a difficult Session 145. Three governance items were completed:

1. **[[ontara-ref-strategic-snapshot|Strategic snapshot]] refresh verification.** The S145 refresh was verified as complete — all six items from the S145 prep note (§4.3 cleanup, §5, R6, R7, §7, footer) were confirmed as having been applied. The [[ontara-ref-work-items|Document Currency Register]] was updated from "in-progress" to complete (S145, next due ~S152).

2. **Repo README.md currency check.** The README was 12 sessions stale (last updated S134). Seven targeted edits applied: Current State section rewritten to reflect through S145 (Phase 3 closure, Stage 6 Block A, 36 BMM elements, 11-file ontology stack, 35-query SPARQL suite), repository structure updated (diff_kg.py, kg_utils.py, ontology/domain/), Key Commands updated (35-query count, diff command), Companion Knowledge Base counts updated (~205 concepts, 31 papers, 117 reports), session number and footer updated. [[ontara-ref-work-items|Document Currency Register]] updated (S146, next due ~S158).

3. **[[ontara-ref-work-items|W-024]] [[ontara - index-research-background|Research & Background Index]] currency check.** The index was 17 sessions overdue (last checked S129). One unindexed document found: `ontara-research-(perplexity) - reasoning-problem-solving-heuristics.md` — the Perplexity research on institutionalised reasoning that had been commissioned but never added to the index. Index entry added with description and forward-links to [[concept-reasoning-formalisms|M7]] and the planned reasoning discussion. [[ontara-ref-work-items|Document Currency Register]] updated (S146, next due ~S153). W-024 moved to completed items.

The decision was taken not to refresh the three overdue foundations papers ([[ontara-ref-work-items|W-021, W-022, W-023]]) because the reasoning discussion would materially affect their content — refreshing them now would mean refreshing them again shortly.

### Phase 2: Institutionalised Reasoning Discussion

The main deliverable is the discussion paper: [[ontara-discussion-institutionalised-reasoning-2026-04-05|Institutionalised Reasoning: A Reasoning Metamodel for the Ontara Platform]].

The discussion began with a thorough reading of the [[ontara-research-(perplexity) - reasoning-problem-solving-heuristics|Perplexity research on reasoning, problem solving, and heuristics]] — a substantial three-section research document covering capability families, a proposed ~30-class metamodel, and dual UML/ontology views. Ella identified this as warranting a new stage (Stage 7) and correctly insisted that further foundational implementation should wait until the reasoning metamodel's implications are understood.

Two specific challenges from Ella improved the paper:

1. **Probabilistic reasoning research integration.** Ella asked whether the [[ontara-research-(perplexity) - probabilistic-reasoning|probabilistic reasoning research]] was suitably taken into consideration. It was not — the original draft treated [[concept-reasoning-formalisms|M7]] as gaining "an architectural home" without engaging with what semiring soft-constraints, fuzzy MCDM, and PSL actually contribute. A new §11 was added covering the three formalism families, three interpretive frames for weights, the pragmatic reasoning stack, and the three-way constraint distinction (hard/soft/graded).

2. **Bayesian reasoning and clinical medicine.** Ella asked whether Bayesian logic and probabilistic thinking had a strong enough foothold in the model design. It did not — [[principle-deterministic-over-probabilistic|A6]] had a single sentence permitting probabilistic methods for decision support. A new §11.6 was added giving Bayesian reasoning, predictive modelling, and diagnostic probability a first-class architectural position with four typed components (BayesianUpdater, RiskCalculator, PrognosticModel, PredictiveAnalytics), full integration with the evidence architecture, and connection to the [[concept-coordinate-framework|coordinate framework (A12)]].

**The discussion paper proposes:**
- Eight design decisions (S146-D1 to D8)
- Seven open questions (S146-Q1 to Q7)
- Seven candidate register concepts (B40–B46)
- Sixteen sections across 700+ lines

**Key architectural positions:**
- The reasoning metamodel is a cross-cutting extension of the SMM, not a third meta model (S146-D1) — preserving [[principle-two-meta-model-distinction|A4]]
- PROV-O should be added to the ontology import stack at platform level (S146-D2) — extending [[concept-bfo-ontology-stack|B19]]
- Goals reference [[concept-coordinate-framework|coordinate space]] regions, grounding the intentional cluster in [[concept-coordinate-framework|A12]] (S146-D4)
- The Constraint class must distinguish hard constraints, soft constraints, and graded rules (S146-D8)
- Bayesian reasoning gets architectural parity with deterministic rules, soft constraints, and fuzzy judgement (B46)
- The evidence/explanation architecture (SEPIO + PROV-O pattern) is the largest genuinely new contribution

## Register Concepts Exercised

The discussion paper proposes seven new concepts (B40–B46) but does not register them yet — they await resolution of the design decisions. Existing concepts exercised: [[principle-self-describing-system|A2]], [[principle-two-meta-model-distinction|A4]], [[principle-deterministic-over-probabilistic|A6]], [[principle-clinical-governance-first-class|A8]], [[principle-intrinsic-self-knowledge|A10]], [[principle-unity-principle|A11]], [[concept-coordinate-framework|A12]], [[concept-multi-tenancy|A13]], [[concept-weighted-relationships|B14]], [[concept-dual-stack-architecture|B21]], [[concept-bfo-ontological-grounding|B23]], B25, [[concept-three-stratum-knowledge-graph|B28]], [[concept-authority-zones|B29]], B30–B35, F1, [[concept-operational-simulation|L5]]–[[concept-goal-seeking-computation|L9]], [[concept-reasoning-formalisms|M7]].

## Emergent Ideas

No new [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]] entries this session. The reasoning metamodel is itself the elaboration of themes that have been building since [[concept-reasoning-formalisms|M7]] was registered (Session 46).

## Open Questions and Deferred Items

- S146-Q1 through Q7 (captured in the discussion paper)
- [[ontara-ref-work-items|W-021, W-022, W-023]] remain open (foundations paper refreshes — deliberately deferred until after Stage 7 implications are understood)
- Stage 7 implementation plan to be produced next session ([[ontara-ref-work-items|W-026]])

## Tier 1 Principles Relevant to This Session

| Principle | How honoured |
|---|---|
| [[principle-separation-representation-execution\|A1]] (Separation of representation and execution) | Reasoning structures placed in the representation layer (OWL/SysML); execution in the [[concept-operational-simulation\|operational simulation]] |
| [[principle-self-describing-system\|A2]] (Self-describing system) | Evidence/explanation cluster makes reasoning self-describing |
| [[principle-two-meta-model-distinction\|A4]] (Two meta model distinction) | Reasoning metamodel positioned as SMM extension, preserving BMM/SMM boundary |
| [[principle-deterministic-over-probabilistic\|A6]] (Deterministic/auditable reasoning) | Decision mode routing makes A6 structurally enforceable; Bayesian reasoning given proper architectural position within A6's intent |
| [[principle-discipline-as-load-bearing-structure\|A9]] (Discipline as load-bearing structure) | Methodical housekeeping before substantive work; governance debt addressed before discussion |
| [[principle-unity-principle\|A11]] (Unity principle) | Reasoning metamodel provides the unified framework within which all reasoning operates |
| [[concept-non-constraining\|J3]] (Non-constraining) | Metamodel defines vocabulary and slots, not implementation; STAMP/STPA and FRAM given architectural slots without requiring immediate implementation |
