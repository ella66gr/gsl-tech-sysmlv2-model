# Session Report — 11 March 2026 (Session 15)

**Project:** GenderSense (GSL)
**Focus:** Business Meta Model Implementation — Phase 3
**Duration:** Single session
**Outcome:** Phase 3 complete. All acceptance criteria met.

---

## 1. Objectives and Outcomes

| Objective | Outcome |
|---|---|
| Pre-flight syntax verification (`output`, `stepped`, `sCurve`) | ✅ All confirmed safe as attribute/enum names |
| Create ScenarioModelling sub-package (11 part defs + 2 enum defs) | ✅ Complete — structure only, Stage 1 |
| Lean Clinical ScenarioDefinition instantiation (~45 part usages) | ✅ Complete — full parameterisation, Stage 2 |
| Create StrategyAndEvolution sub-package (3 part defs + ~10 usages) | ✅ Complete — objectives, variants, pivot, Stage 3 |
| Coffee shop demonstrator extension (two scenarios) | ✅ Complete — Small Kiosk + Full Café, Stage 4 |
| Regenerate package hierarchy | ✅ Complete — 71 packages, both new sub-packages showing correctly |
| Negative Real `:>>` redefinitions | ✅ First verification — e.g. `attribute :>> margin = -3288.0;` |
| `GrowthShape::sCurve` enum `:>>` from exercises directory | ✅ Cross-project camelCase enum literal verified |

---

## 2. Files Created

| File | Purpose |
|---|---|
| `exercises/coffeeshop-demonstrator/model/coffeeshop-scenarios.sysml` | **New.** Coffee shop scenario modelling extension validating cross-project import of ScenarioModelling and StrategyAndEvolution. Two scenarios (Small Kiosk, Full Café), growth assumptions, illustrative outputs, variants, and pivot scenario. |

## 3. Files Modified

| File | Change |
|---|---|
| `model/business-model.sysml` | Added ScenarioModelling sub-package (2 enum defs + 11 part defs + ~45 GSL Lean Clinical instantiation usages) and StrategyAndEvolution sub-package (3 part defs + ~10 usages including 4 strategic objectives, 3 business model variants, 1 pivot scenario). Updated top-level doc block to reflect Phase 3 completion. FinancialPlanning part def doc blocks compacted to manage file size. |

## 4. Files Deleted

| File | Reason |
|---|---|
| `model/syntax-tests/business-model-phase3-names-test.sysml` | Pre-flight syntax test — served its purpose, removed after verification. |

---

## 5. Syntax Findings (v3.10)

### New confirmations

- **Attribute name `output` confirmed safe:** Not shadowed by reserved word `out`. Parses without error in `part def` bodies and in `:>>` redefinitions with Real type.
- **Enum literal `stepped` confirmed safe:** Not shadowed by reserved word `step`. Parses correctly in `enum def` and in `:>>` redefinitions via `GrowthShape::stepped`.
- **CamelCase enum literal `sCurve` confirmed safe:** Syside lexer accepts camelCase enum literals with leading lowercase. Verified both in-package and cross-project via `GrowthShape::sCurve`.
- **Negative Real values in `:>>` redefinitions:** First explicit verification. `attribute :>> margin = -3288.0;`, `attribute :>> cumulativeCashFlow = -18500.0;`, `attribute :>> margin = -2200.0;` all parse cleanly. Syside handles negative Real literals without issue.
- **Multiple enum defs in same sub-package:** `GrowthShape` and `VarianceSource` coexist in ScenarioModelling without conflict. Both are usable as attribute types and in `:>>` redefinitions within the same file and from cross-project imports.
- **Cross-project import of newly added sub-packages (Phase 3):** `private import BusinessModel::ScenarioModelling::*;` and `private import BusinessModel::StrategyAndEvolution::*;` from the exercises directory resolve immediately — no workspace re-index needed. Consistent with Phase 1 and Phase 2 findings.

### No new traps discovered

All proposed patterns worked on first attempt. No fallback names were needed.

---

## 6. Design Decisions

| # | Decision | Rationale |
|---|---|---|
| D1 | `ProjectionOutput` models a single period, not the full time series | Collection of usages (month1, month6, etc.) is the natural SysML pattern. Full series is Phase 4 projection engine output. |
| D2 | `ProjectionFormula.expression` is a String | Formulas described textually; projection engine implements as code. Progressive elaboration. |
| D3 | `VarianceAnalysis.varianceSource` as String, not `VarianceSource` enum | Decomposition narrative is richer than a single enum. Enum available for future typed categorisation. |
| D4 | `ScenarioComparison` is structural placeholder | Full comparison mechanics are Phase 5 when second scenario exists. |
| D5 | `PeriodActuals` uses Real for financial values | Consistent with Phase 2 UnitEconomics pattern. |
| D6 | `ForecastBaseline.parameterSnapshot` as String | Descriptive capture. Formal composition of ProjectionParameter usages adds complexity without value at this stage. |
| D7 | `GrowthAssumption.inflectionMonth` typed as Integer | Sub-month precision not meaningful for business projections. Zero when not applicable. |
| D8 | No `ref` relationships to Phase 1/2 part defs | Consistent with String cross-reference pattern. Formal `ref` deferred to Phase 7. |
| D9 | 5 illustrative ProjectionOutput periods (months 1, 6, 12, 18, 24) | Sufficient to show trajectory shape. Full series is projection engine output. |
| D10 | All parameter values use Real type including percentages | Consistent with Phase 2. Percentages stored as Real (25.0 for 25%). |
| D11 | Two separate ProjectionParameter usages for clinician FTE | Consistent with Phase 2 temporal variation pattern (D6 from Session 14). |
| D12 | GrowthAssumption startValue/endValue represent the quantity at period boundaries | Projection engine interprets these against the trajectory shape. |
| D13 | StrategicObjective.status as String not enum | Values like "planned", "in progress" may evolve. Enum premature. |
| D14 | BusinessModelVariant lighter than ScenarioDefinition | Strategic essence for boardroom comparison. Detailed scenario in ScenarioModelling. |
| D15 | One PivotScenario only (A → B) | Most likely transition path. Others deferred until Variant B elaborated (Phase 5). |
| D16 | No `satisfy` relationships from objectives to capabilities | Deferred to Phase 7 per parent plan. |
| D17 | FinancialPlanning doc blocks compacted | File size management. Part def structures and instantiations unchanged. |
| D18 | File kept as single `business-model.sysml` | Re-evaluate at Phase 4 planning. ~950 lines manageable for structural content. |

---

## 7. Coffee Shop Demonstrator Extension

**Capability demonstrated:** ScenarioModelling and StrategyAndEvolution — making the scenario structure and strategic direction explicit for a simple service business.

**What was built:**
- 2 ScenarioDefinitions (Small Kiosk: 1 barista, 50 drinks/day; Full Café: 3 baristas, 200 drinks/day)
- 8 ProjectionParameters (4 per scenario: daily drinks, price, barista cost, rent)
- 2 GrowthAssumptions (kiosk: linear 50→80; café: S-curve 120→200 with inflection at month 6)
- 2 illustrative ProjectionOutputs (month 6 snapshot for each scenario)
- 2 BusinessModelVariants (Kiosk ~£5K investment; Café ~£40K investment)
- 1 PivotScenario (Kiosk → Café when kiosk reaches 90% capacity)

**What was learned:**
- The cross-project import pattern works identically for ScenarioModelling and StrategyAndEvolution as for all previous sub-packages. No surprises.
- `GrowthShape::sCurve` resolves correctly through the cross-project import chain — first verification of a camelCase enum literal in this context.
- The ScenarioDefinition structure captures meaningfully different business configurations at coffee-shop scale. "Small Kiosk at month 6: £5,915 revenue, £4,732 cost, £1,183 margin" is immediately comprehensible and hand-verifiable.
- The PivotScenario concept works well at toy scale: "expand to full café when kiosk reaches 90% capacity" is a natural strategic trigger that maps directly to "transition to full platform when single-clinician capacity is exceeded."
- The `activePatientsTotal` and `clinicianUtilisation` fields in ProjectionOutput don't map to the coffee shop domain — set to 0. This is expected and acceptable. The part def is designed for clinical use; the coffee shop exercises the financial projection fields.

**Clinical implementation confidence:** High. ScenarioModelling and StrategyAndEvolution structures are ready for clinical use without modification.

---

## 8. Repository State

```
gsl-sysml-model/
├── model/
│   ├── business-model.sysml       ← MODIFIED (Phase 3: ScenarioModelling + StrategyAndEvolution)
│   ├── enterprise.sysml
│   ├── foundation.sysml
│   ├── gendersense.sysml
│   ├── knowledge.sysml
│   ├── operations.sysml
│   ├── platform.sysml
│   └── service-delivery.sysml
├── exercises/
│   └── coffeeshop-demonstrator/
│       └── model/
│           ├── coffeeshop-scenarios.sysml           ← NEW (demonstrator extension)
│           ├── coffeeshop-resource-financial.sysml
│           ├── coffeeshop-business-model.sysml
│           ├── coffeeshop-archetypes.sysml
│           └── domain/
│               └── fulfil-drink-orchestration.sysml
└── documentation/
    └── reference/
        └── gsl-sysml-v2-syntax-reference-v3.10-2026-03-11.md  ← NEW
```

**Package count:** 71 (up from 69 — added ScenarioModelling, StrategyAndEvolution)

**Model health:** All files parse clean in Syside Modeler 0.8.5. No errors, no warnings.

---

## 9. Recommended Next Steps

### Immediate (Phase 4 — next session)

**Projection Engine: Hand-Written Python**

Per `gsl-plan-business-meta-model-implementation-2026-03-10.md` section 6. Three stages:

1. **Projection engine core** (`scripts/projection_engine.py`): Read Lean Clinical parameter values (initially hard-coded from SysML model), implement monthly-interval formulas, produce 24-month time series as JSON. Key formulas: patient cohort tracking (assessment → initiation → stable with conversion and churn), monthly revenue by stream, monthly cost by driver, margin, cumulative cash flow, clinician utilisation.

2. **Projection visualisation**: CSV export, markdown summary table, key metrics (break-even month, maximum cash deficit, month 24 margin).

3. **Sensitivity analysis**: Parameterised runs varying the four sensitivity parameters. Output: sensitivity summary showing break-even shift per parameter variation.

**Verification targets from Phase 3:** The illustrative ProjectionOutput values (months 1, 6, 12, 18, 24) provide hand-calculated approximations. The projection engine should produce values in the same ballpark — significant divergence indicates either a model error or an engine error.

**File size evaluation:** `business-model.sysml` is now ~950 lines. If Phase 4 does not add SysML content (it shouldn't — it's a Python engine), the file size question defers to Phase 5 planning.

### Near-term

- **Coffee Shop Knowledge Layer Extension (Increments 1–3):** Independent of Business Meta Model phases. Can interleave.
- **Phase 5 — Second Scenario (Full Platform):** Depends on Phase 4 projection engine being operational.

### Deferred items to update

Add to `gsl-plan-next-steps-and-deferred-items.md`:
- Formal `ref` from ScenarioDefinition to ServiceOffering (deferred to Phase 7)
- Full 24-month ProjectionOutput time series (Phase 4 projection engine)
- ScenarioComparison instantiation (Phase 5)
- `VarianceSource` enum used as typed attribute (Phase 6)
- Formal `satisfy` from StrategicObjective to Capability (Phase 7)
- Full Platform ScenarioDefinition (Phase 5)
- Variant C elaboration (beyond Phase 5)
- File splitting strategy for `business-model.sysml` (Phase 5 planning)
- PeriodActuals and VarianceAnalysis instantiation (Phase 6)
- `activePatientsTotal` field in ProjectionOutput: consider renaming or generalising for domain-agnostic use (low priority)

---

*Session report prepared 11 March 2026 (Session 15). BusinessModel Phase 3 complete.*
