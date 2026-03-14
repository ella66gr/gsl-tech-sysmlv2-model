# Plan: Business Meta Model Phase 6A — File Splitting and Operations Expansion

**Project:** GenderSense (GSL)
**Date:** 11 March 2026
**Status:** Draft for review
**Parent plan:** `gsl-plan-business-meta-model-implementation-2026-03-10.md` (Phase 6, section 8)
**Predecessor:** `gsl-session-report-2026-03-11-s17.md` (Phase 5 complete)

---

## 1. Purpose

Address the `business-model.sysml` file size issue (~1,900 lines, exceeding the 1,500-line threshold) and expand the Operations package per section 6 of the meta-modelling document. This is the structural housekeeping session that sets up Phase 6B (steering cycle wiring to the Knowledge layer).

Phase 6A is about making the model physically manageable and filling the remaining structural gaps in the Operations package. Phase 6B (separate session) is where the architecturally significant work happens — connecting the PeriodActuals/VarianceAnalysis/ForecastBaseline cycle to the Knowledge layer's five-layer SystemStateAssessment.

---

## 2. Scope Boundary

**In scope:**
- File splitting strategy for `business-model.sysml`
- Operations package expansion (Finance, People, EstatesAndFacilities, Reporting)
- Coffee shop demonstrator: SysML-only variance structure validation
- Root file (`gendersense.sysml`) updates for new package structure

**Out of scope (deferred to Phase 6B):**
- Steering cycle wiring to Knowledge layer
- Extensions to `knowledge.sysml`
- OperationalSnapshot extension for financial data
- Projection engine changes

---

## 3. Pre-flight Checks

- [ ] Verify `business-model.sysml` parses clean in Syside (current state post-Phase 5)
- [ ] Verify `operations.sysml` parses clean
- [ ] Count approximate line ranges per sub-package in `business-model.sysml`
- [ ] Read syntax reference v3.10 — specifically the multi-file model rules and the "global-namespace-distinguishability" constraint

---

## 4. Stage 1 — File Splitting Strategy and Execution

### 4.1 The Constraint

Syside does NOT merge same-named packages across files — this triggers `global-namespace-distinguishability` errors (syntax reference v3.10, section 1). Therefore, we cannot split `BusinessModel` into multiple files each declaring `package BusinessModel { ... }`.

### 4.2 Strategy: Promote Sub-Packages to Top-Level

Extract the two largest sub-packages into their own files as top-level packages with new names. The remaining sub-packages stay in `business-model.sysml`.

**Current structure (single file, ~1,900 lines):**
```
business-model.sysml
  package BusinessModel
    ├── package ServiceConcept          (~270 lines — part defs + all instantiations)
    ├── package ActivityModel            (~100 lines — part defs + enums)
    ├── package ResourcePlanning         (~280 lines — part defs + all instantiations)
    ├── package FinancialPlanning        (~210 lines — part defs + all instantiations)
    ├── package ScenarioModelling        (~850 lines — part defs + Variant A + Variant B + comparison)
    └── package StrategyAndEvolution     (~130 lines — part defs + variants + pivot)
```

**Proposed structure (three files):**

| File | Package | Content | Est. lines |
|---|---|---|---|
| `business-model.sysml` | `BusinessModel` | ServiceConcept, ActivityModel, ResourcePlanning, FinancialPlanning | ~860 |
| `business-scenarios.sysml` | `BusinessScenarios` | ScenarioModelling (all part defs, Variant A, Variant B, comparison, formulas, outputs) | ~850 |
| `business-strategy.sysml` | `BusinessStrategy` | StrategyAndEvolution (part defs, variants, pivot scenarios) | ~130 |

### 4.3 Why This Split

- **ScenarioModelling is the largest sub-package** (~850 lines) and will grow further when PeriodActuals and VarianceAnalysis instantiations are added (Phase 6B). It is also the most actively edited section — Phases 4 and 5 both concentrated changes here.
- **StrategyAndEvolution is logically separable** — it references ScenarioModelling via string attributes (`scenarioRef`), not formal SysML refs. Moving it to its own file has zero structural coupling cost.
- **ServiceConcept, ActivityModel, ResourcePlanning, and FinancialPlanning are tightly co-referenced** — part defs in one are used as attribute types or documentation references in others. Keeping them together avoids cross-file import chains during the current exploratory phase.

### 4.4 Naming Rationale

The new top-level packages are named `BusinessScenarios` and `BusinessStrategy` rather than retaining `BusinessModel::ScenarioModelling` because Syside requires distinct top-level names per file. The `Business` prefix maintains the naming family. An alternative would be `ScenarioModelling` and `StrategyAndEvolution` at top level — shorter, but loses the namespace grouping. The `Business` prefix is preferred for clarity in the hierarchy.

### 4.5 Import Chain

After splitting:

**`business-scenarios.sysml`** needs:
- `private import ScalarValues::*;`
- `private import BusinessModel::ScenarioModelling::GrowthShape;` — **No.** The enum defs move with ScenarioModelling. They become `BusinessScenarios::GrowthShape` and `BusinessScenarios::VarianceSource`.
- No imports from BusinessModel required — ScenarioDefinition references ServiceOfferings and parameters by string attribute values, not formal SysML refs.

**`business-strategy.sysml`** needs:
- `private import ScalarValues::*;`
- No imports from BusinessModel or BusinessScenarios — all cross-references are string attributes (`scenarioRef`, `activeOfferings`).

**`business-model.sysml`** needs:
- No changes to its existing imports.

**`gendersense.sysml`** needs:
- Add `private import BusinessScenarios::*;`
- Add `private import BusinessStrategy::*;`
- Update doc block to reflect new file structure.

**Coffee shop exercisese** — `coffeeshop-scenarios.sysml` currently uses:
- `private import BusinessModel::ScenarioModelling::*;`
- `private import BusinessModel::ScenarioModelling::GrowthShape;`
- `private import BusinessModel::StrategyAndEvolution::*;`

These must be updated to:
- `private import BusinessScenarios::*;`
- `private import BusinessScenarios::GrowthShape;` (or just `::*` which includes it)
- `private import BusinessStrategy::*;`

**Other coffee shop files** — check `coffeeshop-business-model.sysml` and `coffeeshop-resource-financial.sysml` for any imports from ScenarioModelling or StrategyAndEvolution.

### 4.6 Procedure

1. Create `model/business-scenarios.sysml` with top-level `package BusinessScenarios { ... }` containing everything currently in `BusinessModel::ScenarioModelling`.
2. Create `model/business-strategy.sysml` with top-level `package BusinessStrategy { ... }` containing everything currently in `BusinessModel::StrategyAndEvolution`.
3. Remove the `ScenarioModelling` and `StrategyAndEvolution` packages from `business-model.sysml`.
4. Update doc blocks in `business-model.sysml` to note the split.
5. Update `gendersense.sysml` with new imports and updated doc block.
6. Update coffee shop exercise imports.
7. Syside verification: all three new files plus all coffee shop files parse without errors.
8. Verify `gsl` hierarchy command reflects the new structure.
9. Git commit: "Split business-model.sysml into three files — promote ScenarioModelling and StrategyAndEvolution to top-level packages".

### 4.7 Risk: Cross-Package Enum References

The `GrowthShape` and `VarianceSource` enum defs currently live in `BusinessModel::ScenarioModelling`. After the split, they move to `BusinessScenarios`. Any file that imports these enums (currently the coffee shop exercises) must update its import paths. The syntax reference v3.10 confirms that cross-project enum imports resolve correctly through the import chain, so this is a mechanical change.

The `PricingType` enum in `FinancialPlanning` and the `ActivityCategory`/`GranularityLevel` enums in `ActivityModel` stay in `BusinessModel` — no change needed for those.

### 4.8 Acceptance Criteria

- All `.sysml` files parse without errors in Syside
- No `global-namespace-distinguishability` errors
- Coffee shop exercises parse and resolve all enum imports
- `gsl` hierarchy command shows correct package structure
- `business-model.sysml` is under 900 lines
- `business-scenarios.sysml` is under 900 lines
- Git history is clean with a single atomic commit for the split

---

## 5. Stage 2 — Operations Package Expansion

### 5.1 Scope

Expand the existing Operations package per section 6 of the meta-modelling document. The goal is structural completeness — enough sub-packages and part defs/use cases to show the operational machinery exists, while maintaining the "lightest level" principle established in the existing package.

The Operations package is currently ~70 lines with five sub-packages (Finance, People, Marketing, CRM, Reporting), three of which have use case defs and two of which are near-empty. The expansion adds structural depth to Finance, People, and Reporting, adds the new EstatesAndFacilities sub-package, and adds a new `BusinessModelMetrics` sub-package to Reporting.

### 5.2 Design Principle

Operations is the "how it actually runs day to day" package. It is distinct from `BusinessModel::FinancialPlanning` (structural economics) and `BusinessModel::ResourcePlanning` (structural resource needs). The distinction:

- **BusinessModel::FinancialPlanning** asks: "what are our revenue streams and cost drivers?"
- **Operations::Finance** asks: "how do we actually send invoices and reconcile payments?"
- **BusinessModel::ResourcePlanning** asks: "how many clinicians do we need for N patients?"
- **Operations::People** asks: "how do we recruit, contract, appraise, and insure those clinicians?"

The Phase 6A expansion adds part defs to Operations where they help make the operational machinery visible, but does not attempt to model the internal workings of each function in detail. Use case defs capture the "what" of operational processes; part defs capture the structural elements those processes operate on.

### 5.3 Deliverables

**Finance expansion:**

```
Finance (existing — expanded)
├── Invoicing              — existing ProcessInvoice use case
├── PaymentReconciliation  — existing ReconcilePayments use case
├── AccountingIntegration  — Xero integration (new use case)
└── FinancialReporting     — management accounts, cash flow (new use case)
```

New elements:
- `use case def ProduceManagementAccounts` — monthly management accounts from Xero data
- `use case def GenerateCashFlowForecast` — cash flow forecast from current actuals and projection parameters
- `part def AccountingIntegration` — describes the Xero integration touchpoint (name, syncFrequency, dataFlows, notes)

**People expansion:**

```
People (existing — expanded)
├── Workforce               — roles, contracts, FTE allocation
├── Recruitment              — hiring pipeline
├── ProfessionalDevelopment  — CPD, appraisal, revalidation
└── IndemnityAndInsurance    — professional indemnity, employer liability
```

New elements:
- `part def WorkforceRole` — a defined role within the workforce (roleName, contractType, requiredQualifications, fteAllocation, costBasis)
- `use case def ManageRecruitment` — hiring pipeline from need identification to onboarding
- `use case def ConductAppraisal` — annual appraisal and revalidation process
- `use case def ManageProfessionalDevelopment` — CPD tracking and planning
- `use case def RenewIndemnityInsurance` — annual insurance renewal cycle

Note: `WorkforceRole` is deliberately lightweight. It captures the operational view of a role (contract, qualification, FTE), not the business model view (which is `ResourcePlanning::ResourceType`). The two are connected by string reference, consistent with the existing cross-referencing approach.

**EstatesAndFacilities (new sub-package):**

```
EstatesAndFacilities (new)
├── Premises     — clinic rooms, office space
├── Equipment    — clinical and IT equipment
└── Procurement  — purchasing, supplier management
```

New elements:
- `part def PremisesArrangement` — describes a premises arrangement (premisesName, locationType, tenureType, monthlyCost, capacityNotes)
- `part def EquipmentInventory` — a category of equipment (equipmentCategory, items, maintenanceSchedule, replacementCycle)
- `use case def ManageProcurement` — purchasing workflow from need to delivery

**Reporting expansion:**

```
Reporting (existing — expanded)
├── OperationalDashboards  — existing GenerateOperationalDashboard use case
├── RegulatoryReporting    — existing ProduceRegulatoryReport use case
└── BusinessModelMetrics   — KPIs mapped to BusinessModel components (new)
```

New elements:
- `use case def ProduceBusinessModelMetrics` — generate KPI report mapped to BusinessModel components (patient acquisition rate vs projection, revenue vs forecast, clinician utilisation vs capacity model, churn vs assumption)
- This use case is the operational bridge to Phase 6B's steering cycle — it produces the raw data that PeriodActuals captures

### 5.4 Naming Safety Check

Against KerML reserved words (section 8.2.2.6):

| Proposed name | Reserved? | Action |
|---|---|---|
| `WorkforceRole` | No (`role` is not reserved; check: no) | Safe |
| `PremisesArrangement` | No | Safe |
| `EquipmentInventory` | No | Safe |
| `AccountingIntegration` | No | Safe |
| `procurement` | No (not in the reserved word list) | Safe |
| `workforce` | No | Safe |
| `premises` | No | Safe |
| `equipment` | No | Safe |
| `indemnity` | No | Safe |

All proposed names are safe.

### 5.5 Acceptance Criteria

- `operations.sysml` parses without errors in Syside
- All new sub-packages visible in hierarchy
- No circular import dependencies introduced
- Existing use cases unchanged
- Doc blocks establish the structural/operational distinction for each new element
- Estimated file size: ~200–250 lines (up from ~70)

---

## 6. Stage 3 — Coffee Shop Demonstrator Parity (SysML Only)

### 6.1 Scope

Model a coffee shop PeriodActuals and VarianceAnalysis instantiation in the coffee shop demonstrator. This validates that the operational steering part defs (already defined in ScenarioModelling, now in BusinessScenarios) accommodate a simple business's forecast-vs-actuals pattern.

No engine changes — SysML modelling only.

### 6.2 Deliverables

Add to `exercises/coffeeshop-demonstrator/model/coffeeshop-scenarios.sysml`:

**PeriodActuals — one illustrative week:**
```
part cafeKioskWeek1Actuals : PeriodActuals
    periodLabel = "Week 1"
    actualRevenue = 840.0        // 240 drinks × £3.50 average
    actualCost = 610.0           // barista + ingredients + overhead
    actualMargin = 230.0
    actualPatientCount = 0       // not applicable — note this is a domain mismatch
    recordedDate = "2026-03-17"
    notes = "240 drinks sold (projected 250). Rain on Wednesday reduced footfall."
```

**VarianceAnalysis — week 1 vs forecast:**
```
part cafeKioskWeek1Variance : VarianceAnalysis
    periodLabel = "Week 1"
    revenueVariance = -35.0      // £840 actual vs £875 projected
    costVariance = -10.0         // £610 actual vs £600 projected (unfavourable)
    marginVariance = -45.0       // £230 actual vs £275 projected
    varianceSource = "volume"    // primary cause: fewer drinks sold
    decomposition = "Revenue: volume variance -£35 (240 vs 250 drinks). Cost: ingredient waste +£10 unfavourable."
    rebaselineRecommended = "No — single week of data, within normal variation"
    notes = "Weather-driven footfall shortfall. Not structural."
```

### 6.3 Design Observation: `activePatientsTotal` in Non-Clinical Context

The `PeriodActuals` part def has `actualPatientCount : Integer`, which is domain-specific to healthcare. In the coffee shop context, this would be `actualCustomerCount` or similar. This is a known issue — the `ProjectionOutput` part def has the same `activePatientsTotal` attribute, which the coffee shop exercises already set to `0`.

This is noted as a finding, not fixed. Generalising these attribute names (e.g. `activeCustomersTotal`) is a Phase 7 concern or a deferred item. For now, the coffee shop exercises document the mismatch and set the value to `0`.

### 6.4 Import Update

The coffee shop scenarios file will already have been updated to import from `BusinessScenarios::*` (Stage 1). PeriodActuals and VarianceAnalysis are part defs within that package, so no additional imports are needed.

### 6.5 Acceptance Criteria

- Coffee shop scenarios file parses without errors
- PeriodActuals and VarianceAnalysis instantiations are visible in hierarchy
- Variance decomposition is humanly readable and makes common sense
- Domain mismatch (`actualPatientCount`) is documented in a doc block

---

## 7. Stage 4 — Documentation and Commit

### 7.1 Updates to Existing Files

| File | Changes |
|---|---|
| `gendersense.sysml` | Add imports for BusinessScenarios, BusinessStrategy. Update doc block. |
| `business-model.sysml` | Remove ScenarioModelling and StrategyAndEvolution. Update doc block. |
| `documentation/plans/gsl-plan-next-steps-and-deferred-items.md` | Phase 6A findings. Strike completed items. |

### 7.2 New Files

| File | Purpose |
|---|---|
| `model/business-scenarios.sysml` | Promoted ScenarioModelling package |
| `model/business-strategy.sysml` | Promoted StrategyAndEvolution package |

### 7.3 Git Commits

| Commit | Content |
|---|---|
| Stage 1 | File split — three files, updated imports, coffee shop import updates |
| Stage 2 | Operations package expansion |
| Stage 3 | Coffee shop demonstrator — PeriodActuals and VarianceAnalysis |

---

## 8. File Impact Assessment

### Files modified

| File | Expected changes |
|---|---|
| `model/business-model.sysml` | Remove ~980 lines (ScenarioModelling + StrategyAndEvolution). Update doc block. Result: ~860 lines. |
| `model/operations.sysml` | Add ~130–180 lines (new sub-packages, part defs, use cases). Result: ~200–250 lines. |
| `model/gendersense.sysml` | Add 2 import lines, update doc block. |
| `exercises/coffeeshop-demonstrator/model/coffeeshop-scenarios.sysml` | Update imports (BusinessModel::ScenarioModelling → BusinessScenarios). Add ~40 lines (PeriodActuals, VarianceAnalysis). |
| `exercises/coffeeshop-demonstrator/model/coffeeshop-business-model.sysml` | Check and update any imports from ScenarioModelling or StrategyAndEvolution. |
| `exercises/coffeeshop-demonstrator/model/coffeeshop-resource-financial.sysml` | Check and update any imports. |
| `documentation/plans/gsl-plan-next-steps-and-deferred-items.md` | Phase 6A findings, completed items. |

### Files created

| File | Purpose |
|---|---|
| `model/business-scenarios.sysml` | ScenarioModelling as top-level package (~850 lines) |
| `model/business-strategy.sysml` | StrategyAndEvolution as top-level package (~130 lines) |

### Files not modified

| File | Rationale |
|---|---|
| `model/knowledge.sysml` | Phase 6B concern |
| `scripts/projection_engine.py` | No engine changes in Phase 6A |
| `documentation/reference/*.md` | Updated only if new syntax findings emerge |

---

## 9. Relationship to Phase 6B

Phase 6A delivers:
- A manageable file structure for the business model
- An expanded Operations package with structural depth
- Coffee shop validation of the PeriodActuals/VarianceAnalysis vocabulary

Phase 6B (next session) builds on this to:
- Wire PeriodActuals → VarianceAnalysis → ForecastBaseline to the Knowledge layer's five-layer SystemStateAssessment
- Extend OperationalSnapshot with financial actuals
- Extend GoalProjector to project from ProjectionFormulas
- Extend GapAnalyser to produce financial variance Deficits
- Add the `VarianceSource` enum as a typed attribute (deferred item from Phase 3)
- Instantiate PeriodActuals and VarianceAnalysis in the GSL domain (not just coffee shop)

The architectural mapping from section 4.7 of the meta-modelling document drives Phase 6B:

| Self-Knowledge (Clinical) | Operational Steering (Business) |
|---|---|
| GoalProjector → projected goals | ProjectionFormulas → projected financial goals |
| OperationalStateAggregator → current state | Extended aggregator → financial actuals |
| GapAnalyser → Deficit records | VarianceAnalysis → structured variance decomposition |
| ExplanationTrace → "why" for clinicians | Extended explanation → "why" for business steering |

Phase 6A is necessary preparation: the Operations package needs structural depth before it can be meaningfully wired to the Knowledge layer, and the file split is necessary before adding more content to the scenario modelling area.

---

## 10. Estimated Scope

| Stage | Estimated effort | Primary deliverable |
|---|---|---|
| Stage 1 — File splitting | 45–60 min | Three manageable files, all parsing clean |
| Stage 2 — Operations expansion | 30–45 min | Expanded Operations with new sub-packages |
| Stage 3 — Coffee shop demonstrator | 15–20 min | PeriodActuals + VarianceAnalysis validated |
| Stage 4 — Documentation and commit | 15 min | Clean git history, updated plans |

Total: approximately 2–2.5 hours in a single session.

---

## 11. Success Criteria (Phase 6A Level)

Phase 6A is successful if:

1. `business-model.sysml` is under 900 lines and all three business model files parse without errors.
2. The import chain (root file, coffee shop exercises) resolves correctly after the split.
3. Operations package has structural depth matching section 6 of the meta-modelling document.
4. The coffee shop PeriodActuals/VarianceAnalysis instantiation validates the part def vocabulary for a non-clinical domain.
5. No time was spent on steering cycle wiring — that is cleanly scoped to Phase 6B.

---

## 12. Deferred Items and Observations (Pre-Session)

### Carried forward from Phase 5

- `activePatientsTotal` field naming is domain-specific — generalisation deferred
- Sensitivity "dominant" text formatting when break-even not reached — minor, deferred
- Coffee shop subscription scenario not wired into projection engine — low priority
- All Variant B parameter values are illustrative placeholders

### Anticipated findings from Phase 6A

- The file split will confirm whether cross-file enum resolution works for the `BusinessScenarios::GrowthShape` / `BusinessScenarios::VarianceSource` paths (should work per syntax reference, but needs verification)
- The Operations expansion may reveal part defs that should be shared with BusinessModel (e.g., WorkforceRole overlapping with ResourceType) — document but do not resolve; Phase 7 governance mapping addresses this
- The coffee shop VarianceAnalysis may expose limitations in the `varianceSource` attribute (currently String, deferred `VarianceSource` enum typing to Phase 6B)

---

*Plan prepared 11 March 2026. Phase 6A of the Business Meta Model implementation — file splitting and Operations expansion.*
