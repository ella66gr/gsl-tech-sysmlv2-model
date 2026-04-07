---
tags:
  - session-report
date: 2026-04-07
status: current
session: 166
---
# Session 166 Report — Ears Reasoning Instance Population
> `= this.file.path`

**Date:** 7 April 2026
**Session type:** Implementation
**Focus:** W-015 reasoning instance population — first domain-specific exercise of the [[ontara-discussion-institutionalised-reasoning-2026-04-05|reasoning vocabulary]] with concrete clinical content

---

## Summary

Session 166 created the first domain-specific reasoning instances for the Ontara platform: `ontology/reasoning/ears-reasoning-instances.ttl`, a new OWL file containing ~83 named individuals exercising the reasoning vocabulary (`ontara-rsn:`) with clinical content from the [[domain-ears|Ears]] (Community Ear Care) domain.

Five clinical reasoning exercises from the [[ontara-ears-vertical-connection-map|vertical connection map]] §4.1–4.7 were instantiated:

1. **Pre-appointment triage** (§4.1) — 17 individuals. DecisionMode: Clear. Del applies a scripted screening protocol with 5 red-flag HardConstraints. Full SEPIO evidence chain (EvidenceLine → 5 EvidenceItems → ConfidenceAssessment with ProbabilityFrame). Validates the basic ReasoningContext + HardConstraint + DecisionPlan pattern.

2. **Contraindication check** (§4.2) — 20 individuals. DecisionMode: Complicated. The critical three-way constraint test: 7 absolute contraindications as HardConstraints, 4 relative contraindications as GradedRules with FuzzyMinMax combination algebra. Two-stage decision plan (hard boundary check first, graded assessment only if Stage 1 passes). Full evidence architecture with two evidence lines mirroring the two-stage plan.

3. **Procedure selection** (§4.3) — 12 individuals. DecisionMode: Complicated. Exercises HeuristicPack with 4 clinical heuristics mapped to 3 subtypes (DiagnosticHeuristic ×2, CoordinationHeuristic ×1, RiskHeuristic ×1). Multi-dimensional Goal with 3 Measures (clearance, safety, comfort). Two Obstacles (wax characteristics, patient anxiety).

4. **Post-procedure assessment** (§4.4) — 4 individuals. DecisionMode: Clear (with transition to Complicated for complex outcomes). Lightest exercise — validates the outcome-to-disposition plan structure.

5. **Capacity assessment** (§4.5) — 14 individuals. DecisionMode: Complicated. The most architecturally significant exercise — sits at the reasoning–governance intersection. MCA two-stage test maps to ReasoningContext → Plan → Decision. Two meta-constraints identified (MCA statutory principles operating on the reasoning process itself). Full evidence chain with 4 EvidenceItems mapping to the 4 MCA functional elements.

Additionally, 3 STAMP/STPA safety instances were created: the irrigation safety ControlStructure with ControlLoop, the canonical UnsafeControlAction ("irrigating a perforated eardrum" — ProvidedWhenNotNeeded type), and 3 SafetyConstraints (perforation prohibition, temperature control 37°C ± 1°C, maximum three cycles).

Shared resources: 3 ReasoningAgent individuals (Helen, Ade, Del) and 6 KnowledgeSource individuals referenced across exercises.

25 of the 42 reasoning classes were exercised. Of the 17 not exercised, 7 are abstract parent classes (correctly not instantiated), 4 are structured probabilistic types (not relevant to Ears — no validated risk calculators in community ear care), and 6 are heuristic subtypes or FRAM structures not directly exercised by the Ears domain. This is expected — not every domain exercises every class.

## Watchpoint Findings

The four watchpoints from the [[ontara-ears-coverage-map|coverage map]] §11 were the acceptance criteria. All reported on:

**WP-1 (Sub-field coverage stability):** Full coverage confirmed at instance level for all three specific fields flagged: contraindication logic (HardConstraint/GradedRule distinction maps precisely to absolute/relative), procedure selection (HeuristicPack family typing captures clinical heuristics without distortion), capacity assessment (MCA two-stage test fits ReasoningContext/DecisionPlan structure). One unanticipated finding: HardConstraints can operate at the meta-reasoning level (constraints on the reasoning process, not the clinical domain).

**WP-2 (Cross-vocabulary relation binding):** Governance→reasoning relation (MCA obligation → capacity ReasoningContext) is clean and natural — no ad hoc bridging needed. BMM→reasoning relation (clinical pathway step → reasoning context) is implicit rather than formally expressed — an observation for future cross-vocabulary formalisation, but not friction.

**WP-3 (Partial assessments):** Not directly tested by reasoning instances (which focus on core clinical reasoning, not service delivery structure). Deferred to Ears design note.

**WP-4 (Pattern stability):** HeuristicPack pattern holds its shape under instantiation. Four heuristics mapped to three different subtypes with meaningful ordering logic and authority basis. Pattern is stable — ready for PatternCatalogue consideration after cross-domain validation.

## Emergent Ideas

**E028 — Meta-constraints: governance constraints on the reasoning process itself.** Captured in the [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]]. The MCA's statutory principles (presumption of capacity, unwise decision ≠ incapacity) are HardConstraints that operate on the reasoning methodology, not the clinical domain. The [[concept-coordinate-framework|coordinate space]] has a reasoning-method dimension alongside domain dimensions. PatternCatalogue candidate pending cross-domain validation.

## Design Decisions

No formal design decisions this session — the instances exercise existing vocabulary without proposing structural changes. The key finding is confirmatory: the reasoning vocabulary's type-level design is validated at instance level. The meta-constraint observation (E028) is captured as an emergent idea rather than a design decision because it does not require vocabulary changes — the existing HardConstraint class accommodates it.

## Register Concepts Exercised

| Concept | How Exercised |
|---|---|
| [[principle-two-meta-model-distinction|A4]] (two meta model distinction) | Reasoning instances are SMM extension content, distinct from BMM structural skeleton |
| [[principle-deterministic-over-probabilistic|A6]] (deterministic/auditable reasoning) | All five exercises follow inspectable, deterministic decision paths. Clinician retains decision authority |
| [[principle-unity-principle|A11]] (unity principle) | Same HardConstraint class serves reasoning (contraindication), governance (MCA obligation), and safety (perforation prohibition) |
| [[concept-coordinate-framework|A12]] (coordinate framework) | Constraint geometry exercised with real clinical parameters: NormativeRegion boundaries (absolute contraindications), ScalarField truth-value surfaces (relative contraindications), bounded numerical regions (temperature 37°C ± 1°C) |
| [[concept-multi-tenancy|A13]] (multi-tenancy) | Ears instances use exclusively general reasoning vocabulary — no domain-specific class extensions needed |
| [[concept-co-evolution|J2]] (co-evolution) | Instance work reveals tooling needs: evidence browser (P4-2) and decision trace (P4-3) now unblocked |
| [[concept-non-constraining|J3]] (non-constraining) | No vocabulary changes required — existing classes accommodate all clinical content |
| P1–P7 (reasoning vocabulary) | 25 of 42 classes exercised with concrete individuals. Full SEPIO evidence chains. Three-way constraint hierarchy validated |
| B30–B35 (governance vocabulary) | Governance–reasoning intersection validated at instance level (capacity assessment, safety constraints) |

## Tier 1 Principles Honoured

- **[[principle-separation-representation-execution|A1]]** — Representation (OWL individuals) is primary; execution is downstream
- **[[principle-two-meta-model-distinction|A4]]** — Reasoning instances are SMM content, not BMM extensions
- **[[principle-deterministic-over-probabilistic|A6]]** — All reasoning exercises follow deterministic, inspectable paths
- **[[principle-discipline-as-load-bearing-structure|A9]]** — Systematic field-by-field instance population following the agreed plan
- **[[principle-unity-principle|A11]]** — Unity validated: same constraint vocabulary serves reasoning, governance, and safety
- **[[concept-multi-tenancy|A13]]** — Ears is a tenant instantiation using general vocabulary

---

*Session 166 — GenderSense Limited, 7 April 2026*
