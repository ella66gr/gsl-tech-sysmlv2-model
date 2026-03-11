# Plan: Business Meta Model Phase 6B — Steering Cycle Wiring

**Project:** GenderSense (GSL)
**Date:** 11 March 2026
**Status:** Draft for review
**Parent plan:** `gsl-plan-business-meta-model-implementation-2026-03-10.md` (Phase 6, section 8)
**Predecessor:** Phase 6A complete (Session 18) — file split, Operations expansion, coffee shop demonstrator

---

## 1. Purpose

Wire the BusinessScenarios operational steering vocabulary (PeriodActuals, VarianceAnalysis, ForecastBaseline) to the Knowledge layer's five-layer SystemStateAssessment. This is the architecturally significant half of Phase 6 — making the connection that the meta-modelling document section 4.7 describes: "implementing the operational steering pattern is primarily an extension of existing infrastructure, not a parallel build."

**Core thesis being tested:** A financial variance (revenue below forecast) is structurally identical to a clinical deficit (monitoring bloods overdue). Both are cases where actual state falls short of expected state. If the existing self-knowledge architecture handles both without a parallel build, the architecture is validated as genuinely domain-agnostic.

---

## 2. Scope Boundary

**In scope:**
- Extend existing LogicEngine part defs to accommodate financial/business data
- Extend Foundation::CommonTypes enums for business steering domain
- Add financial OperationalQuery to OperationalStateAggregator
- Update doc blocks on GoalProjector, GapAnalyser, AssessmentOrchestrator, SelfExplanationService
- Instantiate illustrative financial GoalProjections and Deficits in the GSL domain
- Type the `varianceSource` attribute in VarianceAnalysis with the `VarianceSource` enum (deferred item)
- Coffee shop demonstrator: SysML-only steering cycle equivalent

**Out of scope:**
- Projection engine changes
- Runtime implementation of any component
- New part defs parallel to existing self-knowledge components
- Changes to BusinessModel, BusinessScenarios, or BusinessStrategy part def structures

---

## 3. Architectural Approach: Extension, Not Parallel Build

The meta-modelling document section 4.7 establishes that operational steering is a domain extension of self-knowledge, not a separate system. Phase 6B follows this strictly.

**What changes:**

| Component | Change type | Detail |
|---|---|---|
| `Foundation::CommonTypes::DeficitDomain` | Enum extension | Add `financial` literal |
| `Foundation::CommonTypes::DataSourceType` | Enum extension | Add `accounting` literal |
| `LogicEngine::OperationalSnapshot` | Attribute addition | Add financial state attributes |
| `LogicEngine::SystemStateAssessment` | Attribute addition | Add business structural counters to Layer 1 |
| `LogicEngine::OperationalStateAggregator` | Part addition | Add `financialDataQuery : OperationalQuery` |
| `LogicEngine::GoalProjector` | Doc block update | Document financial goal projection pattern |
| `LogicEngine::GapAnalyser` | Doc block update | Document financial variance as deficit pattern |
| `LogicEngine::AssessmentOrchestrator` | Doc block update | Document combined clinical + business assessment |
| `LogicEngine::SelfExplanationService` | Doc block update | Add fifth audience: business steering |
| `BusinessScenarios::VarianceAnalysis` | Attribute type change | `varianceSource : String` → `varianceSource : VarianceSource` |

**What does NOT change:**
- No new part defs in LogicEngine (the existing vocabulary handles it)
- No changes to Deficit, EvaluationResult, ExplanationTrace, GoalProjection (they are already generic enough)
- No changes to the three-tier reasoning stack
- No changes to ConstraintEvaluator or ConstraintLibrary

This is the validation: if it works without new part defs, the self-knowledge architecture is genuinely domain-agnostic. If it needs new part defs, that's an equally valuable finding — document the gap and fill it.

---

## 4. Pre-flight Checks

- [ ] Verify `knowledge.sysml` parses clean in current state
- [ ] Verify `foundation.sysml` parses clean
- [ ] Verify `business-scenarios.sysml` parses clean
- [ ] Read syntax reference v3.10 — confirm enum extension pattern (adding literals to existing enum defs)
- [ ] Check reserved word list for any proposed new names

---

## 5. Stage 1 — Foundation Enum Extensions

### Scope

Extend two enums in `Foundation::CommonTypes` to accommodate the business steering domain.

### Deliverables

**DeficitDomain — add `financial`:**

Current: `clinical`, `operational`, `infrastructure`, `governance`

Add: `financial` — for deficits arising from financial variance (revenue shortfall, cost overrun, margin below forecast). Deliberately separate from `operational` because operational deficits are about process state (workflows blocked, monitoring overdue) while financial deficits are about the money flowing through those processes.

**DataSourceType — add `accounting`:**

Current: `cdr`, `temporal`, `platform`, `entity`

Add: `accounting` — for data derived from the accounting system (Xero). PeriodActuals are derived from Xero data via `Operations::Finance::ProduceManagementAccounts`. This is a distinct source from `platform` (which covers infrastructure health) and `entity` (which covers domain object lifecycle state).

### Naming Safety Check

- `financial` — not a KerML reserved word. Safe.
- `accounting` — not a KerML reserved word. Safe.

### Acceptance Criteria

- `foundation.sysml` parses without errors
- Both new enum literals resolve in `:>>` redefinitions (verified in Stage 3 instantiations)

---

## 6. Stage 2 — LogicEngine Part Def Extensions

### Scope

Extend three existing part defs in `Knowledge::LogicEngine` and update doc blocks on four components.

### 6.1 OperationalSnapshot — Financial State Extension

Add financial attributes to the existing OperationalSnapshot part def:

```
// Financial state summary (Phase 6B)
attribute periodLabel : String;           // which reporting period
attribute forecastRevenue : Real;         // projected revenue for this period
attribute actualRevenue : Real;           // actual revenue recorded
attribute forecastCost : Real;            // projected cost for this period
attribute actualCost : Real;              // actual cost recorded
attribute revenueVariance : Real;         // actual - forecast (negative = shortfall)
attribute costVariance : Real;            // actual - forecast (negative = over budget)
attribute activeScenarioRef : String;     // which scenario is the active baseline
```

**Design rationale:** These attributes sit alongside the existing process state, clinical data, and infrastructure health attributes. The OperationalSnapshot becomes a combined clinical + business snapshot — which is exactly what the meta-modelling document section 4.7 describes: "extended aggregator queries financial systems, activity records, and resource utilisation for current actuals."

The financial attributes are at the same level of granularity as the clinical attributes (totals, not per-stream breakdowns). Decomposition by revenue stream or cost driver is in the VarianceAnalysis, not in the snapshot — consistent with how clinical decomposition is in the Deficit, not in the snapshot.

### 6.2 SystemStateAssessment — Business Structural Counters

Add business model structural counters to the Layer 1 section:

```
// Layer 1 — Business model structural summary (Phase 6B)
attribute serviceOfferingsCount : Integer;
attribute revenueStreamsCount : Integer;
attribute scenarioDefinitionsCount : Integer;
attribute strategicObjectivesCount : Integer;
```

**Design rationale:** Layer 1 already counts packages, pathways, constraints, requirements, and entity lifecycles. These counters extend the same pattern to the business model domain. At runtime, they would be derived from the System Model Manifest, which already reads the SysML model structure.

### 6.3 OperationalStateAggregator — Financial Data Query

Add a fifth OperationalQuery to the aggregator:

```
part financialDataQuery : OperationalQuery;
```

This is the query that reads PeriodActuals from the accounting system (Xero via `Operations::Finance`). Structurally identical to the existing four queries — just a different source type (`accounting` instead of `temporal` or `cdr`).

### 6.4 Doc Block Updates (No Structural Changes)

**GoalProjector:** Update doc block to document that financial goals (ProjectionFormula outputs) are a fourth goal source alongside requirements, constraints, and outcome definitions. A forecast figure for a given period is a goal — "revenue should be £X this month" is structurally identical to "every patient should have monitoring bloods within N weeks."

**GapAnalyser:** Update doc block to document that financial variances are deficits. A revenue shortfall is a Deficit with `deficitDomain = DeficitDomain::financial`, `goalReference = "ProjectionFormula::totalMonthlyRevenue"`, `actualState = "£3,100"`, `expectedState = "£4,200"`. The decomposition (volume, price, mix, timing) goes in the Deficit's description or in a VarianceAnalysis cross-reference.

**AssessmentOrchestrator:** Update doc block to document the extended assessment sequence: step 2 now invokes the aggregator for both clinical and financial data; step 3 now projects both clinical and financial goals.

**SelfExplanationService:** Update doc block to add a fifth audience: business steering (founder, investor, board). "Revenue is below forecast because patient acquisition is running at 3/month vs the projected 4/month" is the same structured explanation pattern as "this safety check failed because the consent record is missing."

### Acceptance Criteria

- `knowledge.sysml` parses without errors
- No changes to existing part usages (no `:>>` redefinitions break)
- Doc block updates are visible in Syside hover tooltips

---

## 7. Stage 3 — VarianceSource Enum Typing and GSL Instantiations

### Scope

Type the `varianceSource` attribute in VarianceAnalysis with the `VarianceSource` enum (deferred item from Phase 3). Add illustrative financial GoalProjection and Deficit instantiations for the GSL domain.

### 7.1 VarianceAnalysis Attribute Typing

In `business-scenarios.sysml`, change:

```
attribute varianceSource : String;
```

to:

```
attribute varianceSource : VarianceSource;
```

This requires BusinessScenarios to import from itself (the VarianceSource enum is in the same package), which should work without an explicit import since it's within the same package scope.

**Existing coffee shop instantiation impact:** The `coffeeshop-scenarios.sysml` file has `attribute :>> varianceSource = "volume";` — this must change to `attribute :>> varianceSource = VarianceSource::volume;`. This is a syntax change from string literal to enum literal.

### 7.2 Illustrative Financial GoalProjections

Add to `business-scenarios.sysml` (after the existing Variant A forecast baseline):

Two illustrative GoalProjection usages that show how financial goals are expressed:

- `goalMonth6Revenue : GoalProjection` — "Lean Clinical month 6 revenue should be £2,550" (from the Variant A projection output)
- `goalMonth6PatientCount : GoalProjection` — "Lean Clinical month 6 should have 20 active patients" (from the projection)

These demonstrate that GoalProjection (from LogicEngine) works for financial goals without modification. The goalSource is "BusinessScenarios::leanClinicalScenario", the expectedCondition is "revenue >= £2,550", and the evaluationQuery is "Xero management accounts for month 6."

**Note:** GoalProjection is defined in `Knowledge::LogicEngine`. To use it in `business-scenarios.sysml`, we need to add `private import Knowledge::LogicEngine::GoalProjection;` (or `::*`). This creates a cross-package reference from BusinessScenarios to Knowledge — which is the first formal import between these two packages. This is deliberate and desirable — it's the structural manifestation of the steering cycle wiring.

### 7.3 Illustrative Financial Deficit

Add one illustrative Deficit usage showing how a financial variance is expressed as a deficit:

- `deficitMonth6Revenue : Deficit` — "Month 6 revenue is £2,100 vs expected £2,550. Volume variance: 3 new patients vs projected 4."

This requires importing `Knowledge::LogicEngine::Deficit` and `Foundation::CommonTypes::DeficitDomain` (plus `Severity`, `RemediationCategory`, `AssessmentScope` — but these are already imported via the existing `Foundation::CommonTypes::*` import chain).

**Wait — check this.** BusinessScenarios currently imports only `ScalarValues::*`. It does not import from Foundation or Knowledge. Adding imports from Knowledge::LogicEngine creates a new dependency. Is this desirable?

**Yes.** The whole point of Phase 6B is to wire the business model to the Knowledge layer. The import is the structural manifestation of that wiring. It should be explicit and documented.

### Acceptance Criteria

- `business-scenarios.sysml` parses with the new import and instantiations
- `coffeeshop-scenarios.sysml` parses with `VarianceSource::volume` enum literal
- GoalProjection and Deficit usages are visible in the hierarchy
- The cross-package import chain resolves correctly

---

## 8. Stage 4 — Coffee Shop Demonstrator

### Scope

Add one illustrative financial GoalProjection and one Deficit to the coffee shop demonstrator, mirroring Stage 3. Update the existing VarianceAnalysis to use the `VarianceSource` enum.

### Deliverables

- Update `kioskWeek1Variance` to use `VarianceSource::volume` instead of `"volume"`
- Add `coffeeshopGoalWeek1Revenue : GoalProjection` — "Week 1 kiosk revenue should be £875"
- Add `coffeeshopDeficitWeek1Revenue : Deficit` — "Week 1 revenue is £840 vs expected £875"
- This requires adding `private import Knowledge::LogicEngine::*;` and `private import Foundation::CommonTypes::*;` to the coffee shop scenarios file

### Acceptance Criteria

- Coffee shop scenarios parse without errors
- Enum literal `VarianceSource::volume` resolves correctly from the coffee shop exercises directory
- GoalProjection and Deficit usages resolve correctly via Knowledge::LogicEngine import

---

## 9. Stage 5 — Documentation and Commit

### Updates

- `documentation/plans/gsl-plan-next-steps-and-deferred-items.md` — Phase 6B findings, completed items
- Session report
- Syntax reference update if new patterns discovered (possible: cross-package import from exercises into Knowledge, enum typing of previously-String attributes)

### Git Commits

| Commit | Content |
|---|---|
| Stage 1 | Foundation enum extensions (DeficitDomain::financial, DataSourceType::accounting) |
| Stage 2 | LogicEngine extensions (OperationalSnapshot, SystemStateAssessment, OperationalStateAggregator, doc blocks) |
| Stage 3 | VarianceSource enum typing + GSL GoalProjection and Deficit instantiations |
| Stage 4 | Coffee shop demonstrator — GoalProjection, Deficit, VarianceSource enum |

---

## 10. File Impact Assessment

### Files modified

| File | Expected changes |
|---|---|
| `model/foundation.sysml` | +2 enum literals (DeficitDomain::financial, DataSourceType::accounting). ~5 lines. |
| `model/knowledge.sysml` | OperationalSnapshot +8 attributes, SystemStateAssessment +4 attributes, OperationalStateAggregator +1 part, 4 doc block updates. ~60–80 lines. |
| `model/business-scenarios.sysml` | Add Knowledge::LogicEngine import. VarianceSource attribute typing. +2 GoalProjection usages, +1 Deficit usage. ~50–60 lines. |
| `exercises/coffeeshop-demonstrator/model/coffeeshop-scenarios.sysml` | Add Knowledge/Foundation imports. VarianceSource enum typing. +1 GoalProjection, +1 Deficit. ~40 lines. |

### Files not modified

| File | Rationale |
|---|---|
| `model/business-model.sysml` | No business model part def changes needed |
| `model/business-strategy.sysml` | No strategy changes |
| `model/operations.sysml` | No operational process changes |
| `scripts/projection_engine.py` | No engine changes |

---

## 11. Key Structural Question

**Does the existing GoalProjection part def handle financial goals without modification?**

GoalProjection has: `goalName`, `goalSource`, `expectedCondition`, `evaluationQuery`, `scope`.

A financial goal: goalName = "Month 6 revenue target", goalSource = "BusinessScenarios::leanClinicalScenario", expectedCondition = "totalMonthlyRevenue >= 2550.0", evaluationQuery = "Xero management accounts query for period month-6", scope = AssessmentScope::system.

This fits. The expectedCondition is a String that describes the condition; the evaluationQuery is a String that describes how to check it. Both work for financial goals exactly as they work for clinical goals. **No modification needed.**

If this holds in Syside, it's a strong validation of the self-knowledge architecture's domain-agnosticism.

---

## 12. Estimated Scope

| Stage | Estimated effort | Primary deliverable |
|---|---|---|
| Stage 1 — Foundation enums | 10 min | 2 new enum literals |
| Stage 2 — LogicEngine extensions | 45–60 min | Extended OperationalSnapshot, SystemStateAssessment, doc blocks |
| Stage 3 — VarianceSource typing + instantiations | 30–40 min | Typed enum attribute, GoalProjection and Deficit usages |
| Stage 4 — Coffee shop demonstrator | 20 min | Demonstrator parity |
| Stage 5 — Documentation | 15 min | Updated plans, session report |

Total: approximately 2–2.5 hours.

---

## 13. Success Criteria

Phase 6B is successful if:

1. **No new part defs added to LogicEngine.** The existing vocabulary handles financial goals and deficits. (If new part defs are needed, document why and add them — this is an equally valid outcome.)
2. **VarianceSource enum is typed** — resolving the deferred item from Phase 3.
3. **Financial GoalProjections and Deficits compile** in both the GSL domain and coffee shop demonstrator, using the existing part def structures.
4. **The cross-package import** from BusinessScenarios to Knowledge::LogicEngine resolves correctly, establishing the structural wiring between the business model and self-knowledge layers.
5. **The coffee shop equivalent** validates the pattern in a non-clinical domain.

---

*Plan prepared 11 March 2026. Phase 6B of the Business Meta Model implementation — steering cycle wiring to the Knowledge layer.*
