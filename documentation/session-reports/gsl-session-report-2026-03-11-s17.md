# Session Report — 11 March 2026 (Session 17)

**Project:** GenderSense (GSL)
**Focus:** Business Meta Model Implementation — Phase 5 (Second Scenario and Comparison)
**Duration:** Single session (continuation from partial session interrupted by system errors)
**Outcome:** Phase 5 complete. All six stages delivered. Variant B fully modelled, projected, and compared.

---

## 1. Objectives and Outcomes

| Objective | Outcome |
|---|---|
| Stage 1 — Full Platform ServiceConcept extension | ✅ Complete (prior session) |
| Stage 2 — Full Platform Resource and Financial extension | ✅ Complete (prior session) |
| Stage 3 — Full Platform ScenarioDefinition | ✅ Complete — 12 params, 3 growth assumptions, 3 formulas, 5 outputs, 2 sensitivities |
| Stage 4 — Projection engine extension | ✅ Complete — `--scenario=full-platform`, `--compare`, `--sensitivity` for both variants |
| Stage 5 — Comparison output and SysML instantiation | ✅ Complete — `leanVsFullComparison : ScenarioComparison` |
| Stage 6 — Coffee shop demonstrator parity | ✅ Complete — subscription scenario validates formula pattern |

---

## 2. Files Modified

| File | Changes |
|---|---|
| `model/business-model.sysml` | +~280 lines. Full Platform ScenarioDefinition (Stage 3), ScenarioComparison (Stage 5), variantFullPlatform scenarioRef wired, doc blocks updated. Now ~1,900 lines. |
| `scripts/projection_engine.py` | Major extension. FULL_PLATFORM_PARAMS, subscription revenue in clinical projection, comparison mode, per-scenario sensitivity, Full Platform verification. |
| `exercises/coffeeshop-demonstrator/model/coffeeshop-scenarios.sysml` | +~130 lines. Subscription scenario, formula, parameters, growth assumption, variant. |
| `documentation/plans/gsl-plan-next-steps-and-deferred-items.md` | Phase 5 findings, completed items struck through, new deferred items. |

---

## 3. Files Created

| File | Purpose |
|---|---|
| `generated/projections/full-platform-projection.json` | Full 24-month projection, machine-readable |
| `generated/projections/full-platform-projection.csv` | Full 24-month projection, spreadsheet-compatible |
| `generated/projections/full-platform-summary.md` | Monthly projection table with subscription revenue breakdown |
| `generated/projections/full-platform-sensitivity.md` | Sensitivity analysis for 3 Variant B parameters |
| `generated/projections/lean-clinical-vs-full-platform-comparison.md` | Side-by-side comparison table |
| `generated/projections/lean-clinical-vs-full-platform-comparison.json` | Comparison summary, machine-readable |

---

## 4. Key Structural Finding: Subscription Revenue Formula

The Phase 5 plan posed a key structural question: does subscription revenue require a new ProjectionFormula, or can it be expressed as a parameter variation of existing formulas?

**Answer: Yes, it requires a new formula.** Subscription revenue has its own volume driver (`activeSubscribers`) distinct from assessment volume or monitoring volume. The existing Variant A formulas handle the clinical revenue component unchanged. The engine composes:

```
totalRevenue = clinicalRevenue + subscriptionRevenue
```

where `subscriptionRevenue = activeSubscribers × monthlyFee`.

This is a genuine new structural pattern, validated by the coffee shop demonstrator (`formulaCafeSubscriptionRevenue`), which uses the identical structure: `members × monthlyFee`.

---

## 5. Meta-Model Validation

Phase 5's primary purpose was to test whether the Phase 1–3 meta-model vocabulary handles a structurally different business model.

**Result: Validated.** No part defs were added or changed. The following elements from Variant B fit entirely within the existing vocabulary:

- 3 new ServiceOfferings (coaching, education, community) — subscription `pricingBasis`
- 1 new ValueProposition (holistic care model)
- 2 new ResourceTypes (gender coach, community moderator)
- 3 new ResourceInstances (coach, moderator, second clinician)
- 2 new Capabilities (coaching, community platform)
- 1 new CapacityModel (full platform)
- 1 new RevenueStream (subscription fees)
- 2 new CostDrivers (coach, moderator)
- 1 new PricingModel (subscription)
- 1 new UnitEconomics (subscription)
- 1 new FinancialProjection (full platform)
- 1 new ScenarioDefinition with 12 parameters, 3 formulas, 5 outputs

The only structural addition was the subscription revenue `ProjectionFormula` — a new formula, not a new part def.

---

## 6. Projection Comparison Summary

| Metric | Lean Clinical (A) | Full Platform (B) |
|---|---:|---:|
| Break-even month | Not reached | Not reached |
| Max cash deficit | £22,086 | £90,316 |
| Max deficit month | 14 | 20 |
| Margin at month 24 | £3,832/mo | £2,374/mo |
| Cumulative CF at month 24 | -£1,240 | -£85,078 |
| Active patients at month 24 | 76 | 76 |
| Clinician FTE at month 24 | 0.8 | 1.8 |
| Total staff FTE at month 24 | 1.1 | 2.8 |
| Revenue streams | 2 | 3 |
| Clinician utilisation at month 24 | 34% | 15% |

**Structural observations:**
- Variant B requires ~4.1× the capital of Variant A
- Variant B has more diversified revenue (3 streams vs 2)
- Subscription contributes ~39% of Variant B revenue by month 24
- Variant B has lower margin at month 24 despite subscription revenue — the additional staff costs (coach, moderator, second clinician) exceed subscription income at this patient volume
- Variant B clinician utilisation is very low (15%) — over-resourced at 1.8 FTE for 76 patients

All values are illustrative placeholders. This comparison tests structural capability, not validated business projections.

---

## 7. Sensitivity Analysis

**Lean Clinical (Variant A):** Patient acquisition dominates. At 2 patients/month (pessimistic), cumulative CF is -£39K. At 6 patients/month (optimistic), break-even is reached at month 15.

**Full Platform (Variant B):** Patient acquisition also dominates. Break-even is not reached in any sensitivity scenario within 24 months. Subscription price (£59–£149) swings cumulative CF by ~£81K. Subscription uptake at 60% vs 100% swings CF by ~£36K.

**Both variants:** The dominant risk is patient acquisition rate, not pricing or cost parameters. This is consistent across variants and suggests that marketing/channel effectiveness is the highest-leverage concern.

**Minor issue noted:** The sensitivity "dominant" text reports "99 months spread" when break-even is not reached in any scenario. This is a formatting artefact of the 99-vs-0 fallback, not a meaningful metric. Deferred to cleanup.

---

## 8. Coffee Shop Demonstrator Parity

The subscription revenue formula pattern was validated in the coffee shop domain:

| GSL Pattern | Coffee Shop Equivalent |
|---|---|
| `formulaSubscriptionRevenue` | `formulaCafeSubscriptionRevenue` |
| `formulaFullPlatformTotalRevenue` | `formulaCafeSubscriptionTotalRevenue` |
| `fullPlatformScenario` | `cafeSubscriptionScenario` |
| `fpParamSubscriptionFee` (£99/mo) | `subMonthlyFee` (£25/mo) |
| `fpGrowthSubscriptionBase` | `subMemberGrowth` |
| `variantFullPlatform` | `variantCafeSubscription` |

The coffee shop subscription scenario is modelled in SysML but not wired into the projection engine (no `coffeeshop-cafe-subscription` entry in `SCENARIOS`). This is noted as a low-priority deferred item — the SysML pattern validation is the Phase 5 deliverable.

---

## 9. Git Commits

| Commit | Content |
|---|---|
| (prior session) Stages 1-2 | Variant B ServiceConcept, ResourcePlanning, FinancialPlanning extensions |
| Stage 3 | `fullPlatformScenario` ScenarioDefinition with full parameterisation |
| Stage 4 | Projection engine — FULL_PLATFORM_PARAMS, comparison mode, subscription revenue |
| Stage 5 | `leanVsFullComparison : ScenarioComparison` instantiation |
| Stage 6 | Coffee shop subscription demonstrator parity |

---

## 10. Syntax Reference

No update required. No new SysML syntax patterns were discovered in Phase 5. All patterns used (part usages with `:>>`, doc blocks, enum references, package structure) were already verified in v3.10.

---

## 11. Deferred Items and Observations

### New deferred items

- **Sensitivity dominant text** — formatting issue when break-even not reached. Minor.
- **Coffee shop subscription engine wiring** — SysML complete, engine entry not added. Low priority.
- **`business-model.sysml` file size** — now ~1,900 lines. Exceeds the 1,500-line threshold noted in the Phase 5 plan. File splitting should be addressed before Phase 6.
- **Variant B parameter validation** — all values are illustrative. Real pricing, resource assumptions, and growth targets needed from Ella before any business decision use.

### Phase 3 deferred items resolved

- ~~Full Platform ScenarioDefinition~~ — Done
- ~~ScenarioComparison instantiation~~ — Done
- ~~Comparison mode in engine~~ — Done

### Items remaining for Phases 6-7

- `VarianceSource` enum used as typed attribute (Phase 6)
- PeriodActuals and VarianceAnalysis instantiation (Phase 6)
- Formal `ref` from ScenarioDefinition to ServiceOffering (Phase 7)
- Formal `satisfy` from StrategicObjective to Capability (Phase 7)
- Variant C elaboration (beyond Phase 7)

---

## 12. Phase 5 Success Criteria Assessment

Per the Phase 5 plan (section 14):

| Criterion | Result |
|---|---|
| Meta-model vocabulary handles Variant B without structural modification | ✅ No part defs added or changed |
| Projection engine produces Variant B projections using same architecture | ✅ Same `run_clinical_projection` with optional subscription/cost extensions |
| Comparison output is a single readable table reviewable in under 5 minutes | ✅ Both console and markdown comparison produced |
| No time spent tuning Variant B parameters | ✅ Set once from plan values, not adjusted |
| Coffee shop parity maintained | ✅ Subscription formula pattern validated in coffee shop domain |

**Phase 5 is complete.**

---

## 13. Recommendation for Next Session

Phase 6 (Operations Package Expansion and Steering Cycle) is the natural next step per the implementation plan. However, the `business-model.sysml` file size (~1,900 lines) should be addressed first — either by splitting ScenarioModelling into its own file or by extracting Variant A and Variant B instantiations into separate files.

An alternative next step would be to pause the linear Phase 6-7 progression and use the completed Phase 5 deliverables as the basis for a broader review: Ella reviews the comparison output with real pricing assumptions and makes structural decisions about which variant to pursue. This would inform whether Phase 6 (operational steering) is the right next investment or whether the model should evolve in a different direction.

---

*Session 17 report. Phase 5 of the Business Meta Model implementation complete.*
