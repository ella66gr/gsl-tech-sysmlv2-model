---
tags:
  - session-report
date: 2026-04-06
status: complete
session: 151
---
# Session 151 — Report

**Date:** 6 April 2026
**Session type:** Implementation (Stage 7 Phase 1)
**Stage:** Stage 7 — Reasoning Metamodel Implementation ([[stage7-plan-s.148-reasoning-metamodel|Stage 7 plan]])
**Phase:** Phase 1 — Reasoning Foundation
**Steps completed:** 1.2, 1.3, 1.4, 1.5, 1.7 (5 of 7 Phase 1 steps)

---

## What Was Done

### Gate check: HermiT consistency confirmed

Session 150's Step 1.1 (PROV-O import, dual subclassing per [[ontara-discussion-coordinate-framework-revisited-2026-04-05|S147-D4]]) was verified CONSISTENT via `python3 scripts/reason_kg.py --verbose`. 12-file ontology stack, `ontara-reasoning.ttl` at 8,540 bytes. Gate for Step 1.2 confirmed open.

### Step 1.2: Core reasoning classes — DONE, HermiT CONSISTENT

Authored 13 new classes in `ontara-reasoning.ttl` with BFO grounding:

**Reasoning context and episodes:** ReasoningContext (GDC, BFO_0000031), ReasoningComponent (GDC, BFO_0000031).

**Intentional structure:** Goal (directive info entity, IAO_0000033 — parallel to governance [[ontara-discussion-deontic-governance-architecture-2026-04-03|DeonticDirective]]), Obstacle (ICE, IAO_0000030), Measure (ICE, IAO_0000030).

**Decisions and plans:** Decision (ICE + prov:Entity — dual subclassed for provenance), Plan (plan specification, IAO_0000104).

**Constraint hierarchy ([[ontara-discussion-institutionalised-reasoning-2026-04-05|S146-D8]]/[[ontara-discussion-coordinate-framework-revisited-2026-04-05|S147-D3]]):** Constraint (ICE, IAO_0000030), HardConstraint (NormativeRegion boundary), SoftConstraint (ScalarField cost surface), GradedRule (ScalarField truth-value surface).

**Knowledge sources:** KnowledgeSource (ICE, IAO_0000030), Heuristic (subclass of KnowledgeSource — navigation strategy per [[ontara-discussion-coordinate-framework-revisited-2026-04-05|coordinate framework revisited]] §7.4).

**Plus:** DecisionMode (ICE, placeholder for Phase 2 Cynefin elaboration).

**Key design resolution (Session 151):** Constraints are **information** (GenericallyDependentContinuant via IAO), not dispositions (RealizableEntity). The [[ontara-discussion-coordinate-framework-revisited-2026-04-05|coordinate framework revisited paper]] §7 establishes that constraints describe what is permissible, preferred, or true — specifications that can be written down and shared. This aligns with the governance ontology pattern where DeonticDirective is already an IAO subclass.

9 object properties authored: hasContext, hasGoal, hasConstraint, hasObstacle, hasMeasure, producedDecision, hasDecisionMode (functional), hasPlan, hasKnowledgeSource. All with explicit domain and range declarations.

HermiT run: CONSISTENT, 33,581 bytes.

### Step 1.3: Evidence architecture (SEPIO pattern) — DONE

Authored 4 new classes: EvidenceLine, EvidenceItem, ConfidenceAssessment, InterpretiveFrame.

3 named individuals for the three interpretive frames (stable since Session 46): ProbabilityFrame, FuzzyMembershipFrame, PreferenceWeightFrame. Declared as named individuals (not owl:oneOf enumeration) to preserve [[concept-non-constraining|J3]] (non-constraining) for future extension.

4 new object properties: supportedBy, hasEvidence, hasConfidence, hasInterpretiveFrame (functional).

1 new datatype property: hasConfidenceValue (functional, xsd:decimal).

**Key design decision:** `wasProducedBy` from the plan is NOT created as a separate property — `prov:wasGeneratedBy` already applies to Claim via dual subclassing. Using the PROV-O property directly is the architecturally correct choice.

### Step 1.4: Structured probabilistic reasoning types — DONE

Authored 5 new classes implementing the new [[principle-deterministic-over-probabilistic|A6]] category ([[ontara-discussion-coordinate-framework-revisited-2026-04-05|S147-D5]]): StructuredProbabilisticComponent (abstract), BayesianUpdater, RiskCalculator (subclass of BayesianUpdater with validation metadata), PrognosticModel, PredictiveAnalytics.

2 new object properties: hasPrior, hasPosterior — both typed as Claim (not bare distributions), ensuring priors and posteriors carry provenance and evidence chains.

3 new datatype properties: hasValidationPopulation, hasPerformanceMetric, hasConfidenceInterval (all xsd:string — structured representation is a candidate for future elaboration).

### Step 1.5: Cross-domain validation — DONE (24/24 PASS)

Cross-domain validation analysis produced as a separate vault document ([[stage7-phase1-cross-domain-validation-s151|cross-domain validation S151]]). Every core reasoning class validated against [[domain-cafe|Cafe]] and [[domain-suds|Suds]] domains per [[concept-cross-domain-validation|A5/J1]]. 24/24 pass. RiskCalculator marginal in Cafe (expected — it targets clinical risk tools) but strong in Suds (COSHH dose-response models). Constraint hierarchy validates strongly in both domains.

### Step 1.7: Governance vocabulary alignment — DONE, HermiT CONSISTENT

**Design question resolved:** Alignment uses subclassing declared in the reasoning module, not in the governance module. Dependency direction: `ontara-rsn:` → `ontara-gov:` (reasoning knows about governance). Governance module remains independent. Per [[concept-authority-zones|B29]].

2 cross-module subclass axioms:
- `ontara-gov:Obligation rdfs:subClassOf ontara-rsn:HardConstraint`
- `ontara-gov:Prohibition rdfs:subClassOf ontara-rsn:HardConstraint`

Compliance assessments as Claims documented as a usage pattern (instance typing, not class subclassing). Illustrative example included in comments.

Compatibility with governance module's [[ontara-discussion-deontic-owl-class-design-2026-04-03|DeonticDirective covering axiom]] verified and documented.

**Final HermiT run (all Steps 1.2–1.4, 1.7): CONSISTENT, 46,674 bytes, 12-file stack.**

### Additional session work

**[[ontara-workflow-emergent-ideas-log|E026]] captured:** GraphRAG as a consumption pattern for the [[concept-knowledge-graph|Ontara knowledge graph]]. Sparked by Graphwise white paper on semantic layers. Ontara's KG is naturally positioned as a high-quality GraphRAG foundation but has not yet explicitly designed for LLM-grounded consumption. Routed as future work — architectural preconditions being laid in Stage 7. 26 EIL entries total.

**[[ontara-ref-work-items|W-028]] opened:** [[ontara-ref-vision-architecture|Vision & Architecture Reference]] refresh to v9, deliberately deferred to ~S155. Stage 7 Phase 1 moving fast; refreshing mid-phase would mean refreshing again within 3–4 sessions. Document Currency Register updated.

---

## Governance Actions This Session

- [[ontara-workflow-emergent-ideas-log|EIL]] updated: E026 added, YAML header updated to S151
- [[ontara-ref-work-items|Work item tracker]] updated: W-028 added (V&A refresh deferred), YAML header updated to S151
- Document Currency Register: V&A Reference next-due updated to ~S155 with deferral rationale

---

## Running Totals

| Metric | Value |
|---|---|
| `ontara-reasoning.ttl` size | 46,674 bytes |
| Classes in reasoning module | 24 |
| Named individuals | 3 |
| Object properties | 15 |
| Datatype properties | 4 |
| Cross-module subclass axioms | 2 |
| Ontology stack | 12 files |
| HermiT consistency | CONSISTENT (3 successful runs this session) |
| EIL entries | 26 (E001–E026) |

---

## Design Decisions Made This Session

| Decision | Resolution |
|---|---|
| BFO grounding for constraints | Constraints are ICE (information), not RealizableEntity (dispositions). Per [[ontara-discussion-coordinate-framework-revisited-2026-04-05\|coordinate framework revisited]] §7. |
| wasProducedBy property | Not created — prov:wasGeneratedBy via dual subclassing is the correct approach |
| InterpretiveFrame representation | Named individuals (not owl:oneOf) to preserve [[concept-non-constraining\|J3]] |
| hasPrior/hasPosterior range | Typed as Claim (not bare distributions) to ensure provenance traceability |
| hasDecisionMode cardinality | Functional — each context has exactly one decision mode |
| Governance alignment direction | Reasoning module declares subclass axioms about governance classes (not vice versa). Per [[concept-authority-zones\|B29]] |
| Obligation + Prohibition as HardConstraint | Both are HardConstraints — both define NormativeRegion boundaries |

---

## What Remains for Phase 1

| Step | Status | Notes |
|---|---|---|
| 1.1 | Done (S150) | PROV-O import, dual subclassing |
| 1.2 | Done (S151) | Core reasoning classes, HermiT CONSISTENT |
| 1.3 | Done (S151) | Evidence architecture, SEPIO pattern |
| 1.4 | Done (S151) | Structured probabilistic types |
| 1.5 | Done (S151) | Cross-domain validation, 24/24 pass |
| 1.6 | **Outstanding** | SPARQL validation suite extension — Claude Code task |
| 1.7 | Done (S151) | Governance alignment, HermiT CONSISTENT |

Phase 1 is 6/7 steps complete. Step 1.6 (SPARQL) is a Claude Code task.

---

*Session 151 report. 6 April 2026.*
