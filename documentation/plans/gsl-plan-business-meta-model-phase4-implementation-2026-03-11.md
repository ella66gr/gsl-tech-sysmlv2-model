# Plan: Business Meta Model Phase 4 — Hand-Written Projection Engine

**Project:** GenderSense (GSL)
**Date:** 11 March 2026 (Session 16)
**Status:** Ready for execution
**Parent plan:** `gsl-plan-business-meta-model-implementation-2026-03-10.md` section 6
**Predecessor:** Phase 3 complete (Session 15) — ScenarioModelling and StrategyAndEvolution sub-packages with full Lean Clinical instantiation
**Companion:** `gsl-plan-coffeeshop-demonstrator-integration-2026-03-10.md` section 5 Phase 4 Extension

---

## 1. Purpose

Build a projection engine that reads the Lean Clinical ScenarioDefinition's parameter values (hard-coded initially) and produces a 24-month time-series financial projection. This is the first executable component derived from the business model — turning the structured SysML description into quantitative output that can be reviewed, challenged, and used for decision-making.

The engine is deliberately hand-written Python, not generated from the model. It serves as the verification baseline for a future generator, following the same pattern used throughout the project (hand-written coffee shop → generated from model).

---

## 2. Inputs from the SysML Model

All parameter values are drawn from `model/business-model.sysml` ScenarioModelling sub-package. The engine hard-codes these values in a clearly labelled parameter block so they can be updated independently of the calculation logic.

### 2.1 Revenue Parameters

| Parameter | Value | Source usage |
|---|---|---|
| assessmentFeePerPatient | £600 | `paramAssessmentFee` |
| monitoringFeePerQuarter | £150 | `paramMonitoringFee` |

### 2.2 Resource Cost Parameters

| Parameter | Value | Source usage |
|---|---|---|
| clinicianFTE (months 1–9) | 0.5 | `paramClinicianFTEEarly` |
| clinicianFTE (months 10–24) | 0.8 | `paramClinicianFTELater` |
| clinicianCostPerFTEPerMonth | £5,000 | `paramClinicianCost` |
| adminFTE | 0.3 | `paramAdminFTE` |
| adminCostPerFTEPerMonth | £1,800 | `paramAdminCost` |
| platformCostPerMonth | £200 | `paramPlatformCost` |
| insurancePerMonth | £250 | `paramInsuranceCost` |
| labCostPerBloodPanel | £45 | `paramLabCost` |
| overheadPercentage | 25% | `paramOverheadPercentage` |

### 2.3 Clinical Pathway–Derived Parameters

| Parameter | Value | Source usage |
|---|---|---|
| bloodPanelsPerInitiationEpisode | 5 | `paramBloodPanelsInitiation` |
| bloodPanelsPerMonitoringQuarter | 1 | `paramBloodPanelsMonitoring` |

### 2.4 Growth and Conversion Parameters

| Parameter | Value | Source usage |
|---|---|---|
| newPatientsPerMonth (year 1) | 4 | `paramNewPatientsYear1` |
| newPatientsPerMonth (year 2) | 6 | `paramNewPatientsYear2` |
| assessmentToInitiationConversion | 85% | `paramAssessmentConversion` |
| initiationToStableConversion | 90% over 9 months average | `paramInitiationConversion` |
| churnRatePerQuarter | 5% | `paramChurnRate` |
| availableHoursPerFTEPerMonth | 140 | `formulaUtilisation` notes |

---

## 3. Patient Cohort Model

The projection engine must track patients through three lifecycle stages. This is the clinical flow that drives everything — revenue, lab costs, and clinician utilisation all derive from how many patients are at each stage.

### 3.1 Three-Stage Pipeline

```
New patients → [Assessment] → [Initiation] → [Stable Monitoring]
                                   ↓                    ↓
                              (drop out)           (churn out)
```

**Assessment stage:** Each new patient enters assessment in the month they arrive. Assessment lasts approximately 2 weeks — for monthly modelling, the simplifying assumption is that assessment completes within the same month. The assessment fee is earned in that month.

**Initiation stage:** Patients who convert (85%) enter the initiation pipeline. The average initiation duration is 9 months (from meta-modelling section 7.2: "90% complete initiation over ~9 months average"). To model this as a pipeline with monthly resolution:

- Patients entering initiation in month M complete initiation in month M+9 (simplifying assumption: uniform 9-month duration).
- The 10% who don't complete initiation drop out gradually. For simplicity, model this as: of each month's initiation cohort, 90% emerge as stable patients 9 months later. The other 10% leave the system during the initiation period. (The exact month of dropout is not material to the financial projection — the costs and revenues during initiation are minimal beyond the initial assessment fee.)
- During initiation, patients consume blood panels (5 panels spread over the 9-month period, approximately 0.56 panels/month — round to the nearest integer when computing monthly lab costs) and clinician time.

**Stable monitoring stage:** Patients completing initiation enter the stable monitoring pool. They generate quarterly monitoring revenue (£150/quarter = £50/month) and consume 1 blood panel per quarter (0.33 panels/month). Churn removes 5% of the stable pool per quarter (approximately 1.67% per month).

### 3.2 Cohort Tracking Formulas

For each month M (1 to 24):

```
# New patient acquisition
newPatients[M] = 4  (months 1-12)  or  6  (months 13-24)

# Assessment → initiation conversion (same month)
enteringInitiation[M] = newPatients[M] × 0.85

# Initiation → stable conversion (9-month delay)
completingInitiation[M] = enteringInitiation[M-9] × 0.90   (if M > 9, else 0)

# Active initiation patients (pipeline)
patientsInInitiation[M] = patientsInInitiation[M-1]
    + enteringInitiation[M]
    - completingInitiation[M]
    - dropoutsThisMonth[M]

# Stable monitoring patients (pool with churn)
monthlyChurnRate = 1 - (1 - 0.05)^(1/3)   ≈ 0.0170 (1.70% per month)
patientsStable[M] = patientsStable[M-1]
    + completingInitiation[M]
    - floor(patientsStable[M-1] × monthlyChurnRate)

# Total active patients
activePatientsTotal[M] = newPatients[M] + patientsInInitiation[M] + patientsStable[M]
```

### 3.3 Design Decision: Initiation Dropout Modelling

The 10% initiation dropout can be modelled in several ways. The simplest approach for Phase 4:

- Track the initiation pipeline as a single number (not per-cohort).
- Each month, `completingInitiation[M]` draws from the cohort that entered 9 months ago.
- The 10% dropout is implicit: only 90% of each cohort emerges. The dropout patients silently leave the initiation count.
- If precise initiation counts matter (e.g. for lab cost accuracy), model dropouts as evenly distributed across the 9-month period (approximately 1.11% of the entering cohort per month). For Phase 4, the simpler approach is sufficient.

**Recommended implementation:** Track an initiation pipeline as a list/queue of monthly entry cohorts. Each month, add the new cohort and remove the cohort that has been in the pipeline for 9 months (at 90% conversion). This gives exact initiation patient counts at all times.

---

## 4. Financial Formulas

### 4.1 Monthly Revenue

```
assessmentRevenue[M] = newPatients[M] × assessmentFeePerPatient

monitoringRevenue[M] = patientsStable[M] × monitoringFeePerQuarter / 3

totalRevenue[M] = assessmentRevenue[M] + monitoringRevenue[M]
```

**Design note:** The meta-modelling document formula divides the assessment fee by 2 ("`patientsInAssessment[m] × assessmentFeePerPatient / 2`"), suggesting a 2-session assessment split across months. However, given the 2-week assessment duration and monthly granularity, the simplifying assumption that the full assessment fee is earned in the month of assessment is more appropriate. The hand-calculated illustrative outputs in the SysML model appear to use this assumption (month 1: 4 patients × £600 ÷ 2 = £1,200 — but this could also be 2 patients assessed in half a month). **The engine should use the full fee approach initially** (`newPatients × assessmentFee`) and check against the illustrative output for month 1 (£1,200). If the illustrative value implies the halved fee, adjust accordingly.

**Resolution:** Month 1 illustrative revenue is £1,200 with 4 new patients. £1,200 ÷ 4 = £300, which is exactly £600 ÷ 2. So the SysML model's illustrative values use the meta-modelling document's halved assessment fee formula. The engine should follow this: `assessmentRevenue[M] = newPatients[M] × assessmentFeePerPatient / 2`. The rationale is that assessment spans approximately 2 weeks and the fee is spread across two sessions, so on average half the fee is earned in the first month and half in a subsequent month. At a population level, this averages out to half the fee per patient per month of assessment.

### 4.2 Monthly Cost

```
# Clinician cost (step function)
clinicianFTE[M] = 0.5  (months 1-9)  or  0.8  (months 10-24)
clinicianMonthlyCost[M] = clinicianFTE[M] × clinicianCostPerFTEPerMonth

# Admin cost (fixed)
adminMonthlyCost[M] = adminFTE × adminCostPerFTEPerMonth
                     = 0.3 × 1800 = £540

# Fixed costs
platformMonthlyCost = £200
insuranceMonthlyCost = £250

# Lab costs (variable)
bloodPanelsThisMonth[M] = (patientsInInitiation[M] × bloodPanelsPerInitiationEpisode / 9)
                         + (patientsStable[M] × bloodPanelsPerMonitoringQuarter / 3)
labMonthlyCost[M] = bloodPanelsThisMonth[M] × labCostPerBloodPanel

# Direct cost total
monthlyDirectCost[M] = clinicianMonthlyCost[M]
                      + adminMonthlyCost[M]
                      + platformMonthlyCost
                      + insuranceMonthlyCost
                      + labMonthlyCost[M]

# Overhead
monthlyOverhead[M] = monthlyDirectCost[M] × overheadPercentage / 100

# Total cost
totalMonthlyCost[M] = monthlyDirectCost[M] + monthlyOverhead[M]
```

### 4.3 Margin and Cash Flow

```
monthlyMargin[M] = totalRevenue[M] - totalMonthlyCost[M]
cumulativeCashFlow[M] = cumulativeCashFlow[M-1] + monthlyMargin[M]
    (where cumulativeCashFlow[0] = 0)
```

### 4.4 Clinician Utilisation

```
# Assessment hours: 2 hours per patient (from UnitEconomics breakdown)
# Monitoring review: 0.5 hours per review
# Initiation: ongoing monitoring during titration — estimate 0.5 hours per
#   initiation patient per month (review of bloods, dose adjustments)

clinicianActivityHours[M] = (newPatients[M] × 2.0)
                           + (patientsInInitiation[M] × 0.5)
                           + (patientsStable[M] / 3 × 0.5)

clinicianAvailableHours[M] = clinicianFTE[M] × 140

clinicianUtilisation[M] = clinicianActivityHours[M] / clinicianAvailableHours[M] × 100
```

**Note:** The stable monitoring patients generate reviews quarterly (hence ÷ 3 to get monthly review count). The 140 available hours per FTE per month comes from the `formulaUtilisation` notes in the SysML model (35 hrs/wk × 4 wks).

---

## 5. Stages and Deliverables

### Stage 1 — Projection Engine Core

**File:** `scripts/projection_engine.py`

**Structure:**

```
projection_engine.py
├── Parameter block (clearly labelled, all values from SysML model)
├── Patient cohort model
│   ├── Initiation pipeline (list of monthly cohorts)
│   ├── Stable pool with churn
│   └── Monthly patient counts at each stage
├── Revenue calculation
├── Cost calculation
│   ├── Fixed costs (clinician, admin, platform, insurance)
│   ├── Variable costs (lab panels)
│   └── Overhead
├── Margin and cumulative cash flow
├── Clinician utilisation
├── Output: 24-month time series as list of dicts
└── JSON output to stdout or file
```

**Implementation approach:**

- Pure Python, no external dependencies (stdlib only — `json`, `math`, `csv`, `pathlib`)
- Single-file module with a `main()` function
- Parameter block as a Python dict at the top of the file, with comments referencing the SysML source usage for each value
- The `run_projection(params)` function takes a parameter dict and returns the time series — this enables reuse for sensitivity analysis and coffee shop scenarios
- Output as JSON matching the `ProjectionOutput` part def structure, plus additional fields for patient counts by stage and cost breakdown

**Output JSON shape:**

```json
{
  "scenario": "Lean Clinical (Variant A)",
  "generatedAt": "2026-03-11T...",
  "timelineMonths": 24,
  "parameters": { ... },
  "months": [
    {
      "month": 1,
      "periodLabel": "Month 1",
      "patients": {
        "newThisMonth": 4,
        "inAssessment": 4,
        "enteringInitiation": 3,
        "inInitiation": 3,
        "completingInitiation": 0,
        "stable": 0,
        "churnedThisMonth": 0,
        "totalActive": 7
      },
      "revenue": {
        "assessment": 1200.0,
        "monitoring": 0.0,
        "total": 1200.0
      },
      "cost": {
        "clinician": 2500.0,
        "admin": 540.0,
        "platform": 200.0,
        "insurance": 250.0,
        "lab": ...,
        "directTotal": ...,
        "overhead": ...,
        "total": ...
      },
      "margin": ...,
      "cumulativeCashFlow": ...,
      "clinicianUtilisation": ...,
      "confidenceProfile": "..."
    },
    ...
  ],
  "summary": {
    "breakEvenMonth": ...,
    "maxCashDeficit": ...,
    "maxCashDeficitMonth": ...,
    "marginAtMonth24": ...,
    "activePatientsAtMonth24": ...,
    "clinicianUtilisationAtMonth24": ...
  }
}
```

**Output file:** `generated/projections/lean-clinical-projection.json`

**Acceptance criteria:**

- Projection engine runs without errors: `python scripts/projection_engine.py`
- Produces 24-month time series as JSON
- Month 1 revenue matches illustrative value: ≈ £1,200
- Month 6 revenue in the ballpark of £2,550 (illustrative SysML value)
- Month 12 revenue in the ballpark of £4,800
- Month 24 revenue in the ballpark of £10,500
- Break-even month approximately 14 (per `leanClinicalProjection.breakEvenIndicator`)
- Maximum cumulative cash deficit approximately -£18,500 (per illustrative `outputMonth12.cumulativeCashFlow`)
- Month 24 cumulative cash flow approximately -£1,200 (per illustrative `outputMonth24.cumulativeCashFlow`)
- Cost breakdown is plausible and traceable to parameter values

**Verification approach:** The illustrative `ProjectionOutput` values in the SysML model (months 1, 6, 12, 18, 24) were hand-calculated approximations. The engine should produce values in the same ballpark. Significant divergence (>20% on revenue or cost at any illustrative checkpoint) indicates either a model error in the hand-calculated values or an engine formula error. In either case, the discrepancy should be investigated and the correct figure established, with the SysML illustrative values updated if the engine calculation is more accurate.

---

### Stage 2 — Output Formats and Visualisation

**Deliverables:**

1. **CSV export:** `generated/projections/lean-clinical-projection.csv` — one row per month, all columns. Suitable for opening in a spreadsheet for manual inspection and charting.

2. **Markdown summary table:** `generated/projections/lean-clinical-summary.md` — formatted for inclusion in documentation or sharing. Structure:

   ```
   # Lean Clinical (Variant A) — 24-Month Projection Summary

   ## Key Metrics
   - Break-even month: X
   - Maximum cash deficit: £X,XXX (month X)
   - Margin at month 24: £X,XXX/month
   - Active patients at month 24: XX
   - Clinician utilisation at month 24: XX%

   ## Monthly Projection

   | Month | New | Init | Stable | Total | Revenue | Cost | Margin | Cumulative | Utilisation |
   |-------|-----|------|--------|-------|---------|------|--------|------------|-------------|
   | 1     | 4   | 3    | 0      | 7     | £1,200  | ...  | ...    | ...        | ...         |
   | ...   |     |      |        |       |         |      |        |            |             |
   ```

3. **Console summary:** When run from the command line, the engine prints the key metrics and a compact monthly table to stdout.

**Implementation:** Extend `projection_engine.py` with `--format` argument (json, csv, markdown, console). Default: console + json file.

**Acceptance criteria:**

- `python scripts/projection_engine.py --format=csv` produces valid CSV
- `python scripts/projection_engine.py --format=markdown` produces readable markdown
- Summary metrics match JSON output
- CSV opens correctly in Numbers/Excel

---

### Stage 3 — Sensitivity Analysis

**Deliverables:**

Run the projection engine with the four sensitivity parameters from the SysML model, varying each independently while holding others at base values.

| Parameter | Pessimistic | Base | Optimistic |
|---|---|---|---|
| newPatientsPerMonth (year 1) | 2 | 4 | 6 |
| assessmentFeePerPatient | £450 | £600 | £750 |
| clinicianCostPerFTEPerMonth | £6,000 | £5,000 | £4,000 |
| overheadPercentage | 35% | 25% | 20% |

**Output:** `generated/projections/lean-clinical-sensitivity.md`

```
# Lean Clinical (Variant A) — Sensitivity Analysis

## Break-Even Month by Parameter Variation

| Parameter                  | Pessimistic | Base | Optimistic |
|----------------------------|-------------|------|------------|
| Patient acquisition (Y1)   | ~20         | ~14  | ~10        |
| Assessment fee             | ~17         | ~14  | ~12        |
| Clinician cost per FTE     | ~16         | ~14  | ~12        |
| Overhead percentage        | ~16         | ~14  | ~13        |

## Most Sensitive Parameter

Patient acquisition rate dominates. The difference between 2 and 6 new
patients per month shifts break-even by approximately 10 months.
[Validates SysML model prediction: "±6 months"]

## Additional Metrics per Scenario

[Table showing max cash deficit and month-24 margin for each variation]
```

**Implementation:** Add a `run_sensitivity(base_params, variations)` function that iterates over parameter variations, runs the projection for each, and collects the summary metrics. Output as a comparison table.

**Acceptance criteria:**

- Sensitivity analysis runs without errors
- Patient acquisition rate confirmed as the dominant sensitivity (largest break-even shift) — this validates the prediction in the SysML `sensitivityPatientGrowth.impactDescription` and meta-modelling section 7.2
- Break-even shifts are broadly consistent with the SysML predictions (±6 months for acquisition, ±3 for fee, ±2 for clinician cost, ±2 for overhead) — exact values will differ from the hand-estimated predictions, which is expected
- The analysis is readable and could be shared with a non-technical advisor

---

### Stage 4 — Coffee Shop Demonstrator Extension

Per `gsl-plan-coffeeshop-demonstrator-integration-2026-03-10.md` section 5 Phase 4 Extension.

**What it demonstrates:** The same projection engine can run against a completely different domain. If the coffee shop numbers come out right, the engine logic is sound.

**Concrete work:**

- Add a `coffeeshop_scenarios.py` module (or a parameter block within `projection_engine.py` selected by `--scenario=coffeeshop-kiosk` or `--scenario=coffeeshop-cafe`) with the Small Kiosk and Full Café parameter values from `coffeeshop-scenarios.sysml`:
  - Small Kiosk: 1 barista, 50 drinks/day, £3.50/drink, rent £500/month, barista £2,100/month, ingredients £0.80/drink, linear growth 50→80 drinks/day over 12 months
  - Full Café: 3 baristas, 120→200 drinks/day (S-curve, inflection month 6), £4.00/drink, rent £2,500/month, baristas £6,300/month, ingredients £0.85/drink

- The coffee shop scenarios exercise a simpler patient-flow model (no initiation pipeline — drinks are immediate) but the same financial projection structure (revenue, cost, margin, cumulative cash flow)

- The engine must handle the structural difference: clinical projections have a multi-stage patient pipeline, coffee shop projections have a single-stage volume model. The `run_projection()` function either accepts a domain-specific cohort model function, or the coffee shop has its own simpler projection function that reuses the financial calculation layer.

**Design decision:** The projection engine should have a clean separation between the cohort model (how volume grows over time) and the financial model (how volume translates to revenue and cost). The clinical scenario provides a cohort model with three stages and conversion/churn. The coffee shop provides a cohort model with one stage (daily volume × growth trajectory). The financial model structure is shared.

**Output:** `generated/projections/coffeeshop-kiosk-projection.json`, `generated/projections/coffeeshop-cafe-projection.json`

**Hand-verification target (from Session 15 report):**

> "Small Kiosk at month 6: £5,915 revenue, £4,732 cost, £1,183 margin"

The projection engine should produce values in this ballpark for the Small Kiosk at month 6. If the numbers diverge, check whether the session 15 values were approximate.

**Acceptance criteria:**

- Coffee shop projections run without errors
- Small Kiosk month 6 figures are in the same ballpark as the illustrative SysML values
- The structural separation between cohort model and financial model is clean
- Running the engine with `--scenario=lean-clinical` vs `--scenario=coffeeshop-kiosk` exercises the same financial calculation layer

**Estimated scope:** One sub-stage (~30 minutes), concurrent with Stage 1.

---

## 6. Design Decisions Pre-Registered

| # | Decision | Rationale |
|---|---|---|
| D1 | Pure Python, no external dependencies | Maximises portability. The engine is a script, not a framework. Plotting can be added later (matplotlib) or done in a spreadsheet from the CSV export. |
| D2 | Parameter block as a Python dict, not parsed from SysML | Hand-first-then-generate. The parameter block is the interface contract — a future generator reads the SysML model and produces this dict. |
| D3 | Initiation pipeline modelled as a list of monthly entry cohorts | Gives exact patient counts at all times. Simpler than differential equations, more accurate than a single-number approximation. |
| D4 | Monthly churn rate derived from quarterly rate: `1 - (1-0.05)^(1/3)` | Mathematically correct conversion from quarterly to monthly compounding. |
| D5 | Assessment fee halved per meta-modelling formula | Month 1 illustrative revenue (£1,200 for 4 patients at £600) confirms the halved-fee approach from the source document. |
| D6 | Blood panels during initiation spread evenly across 9 months | 5 panels ÷ 9 months ≈ 0.556 panels/patient/month. Applied to the initiation pool. |
| D7 | Clinician activity hours estimated from UnitEconomics breakdowns | Assessment: 2 hrs (from assessmentUnitEconomics). Monitoring review: 0.5 hrs (from monitoringUnitEconomics). Initiation ongoing: 0.5 hrs/patient/month (estimate). |
| D8 | No SysML model changes in Phase 4 | The engine reads parameters; it does not modify the model. If illustrative `ProjectionOutput` values need updating based on engine output, that is a separate commit. |
| D9 | Coffee shop uses a simpler cohort model | Clinical has three-stage pipeline; coffee shop has single-stage volume growth. The financial layer is shared. |
| D10 | `--scenario` argument selects parameter set and cohort model | Keeps a single entry point. Future scenarios (Full Platform) are added as new parameter sets. |
| D11 | Confidence profile assigned heuristically | Early months: "low"; months 6-12: "moderate — growth assumptions dominate"; months 18-24: "moderate — churn assumptions becoming significant". Matches SysML illustrative values. |

---

## 7. Verification Against Illustrative SysML Values

The illustrative `ProjectionOutput` values from Phase 3 provide the verification targets. These are hand-calculated approximations, so exact match is not expected — but they should be in the same ballpark.

| Month | SysML Revenue | SysML Cost | SysML Margin | SysML Cumulative | SysML Patients | SysML Utilisation |
|-------|---------------|------------|--------------|------------------|----------------|-------------------|
| 1 | £1,200 | £4,488 | -£3,288 | -£3,288 | 4 | 15% |
| 6 | £2,550 | £4,750 | -£2,200 | -£15,500 | 20 | 35% |
| 12 | £4,800 | £5,050 | -£250 | -£18,500 | 38 | 55% |
| 18 | £7,500 | £6,250 | £1,250 | -£12,500 | 52 | 72% |
| 24 | £10,500 | £6,650 | £3,850 | -£1,200 | 65 | 85% |

**Verification protocol:**

1. Run the engine for the base case
2. Extract values at months 1, 6, 12, 18, 24
3. Compare against the table above
4. For each metric, flag discrepancies >20%
5. Investigate any flagged discrepancy — determine whether the engine or the illustrative value is more accurate
6. Document the finding in the session report
7. If the engine values are more accurate, note the SysML illustrative values for updating (separate commit, not part of Phase 4 engine work — per D8)

---

## 8. File Locations

| Deliverable | Path |
|---|---|
| Projection engine | `scripts/projection_engine.py` |
| JSON output (Lean Clinical) | `generated/projections/lean-clinical-projection.json` |
| CSV output | `generated/projections/lean-clinical-projection.csv` |
| Markdown summary | `generated/projections/lean-clinical-summary.md` |
| Sensitivity analysis | `generated/projections/lean-clinical-sensitivity.md` |
| JSON output (Coffee Shop Kiosk) | `generated/projections/coffeeshop-kiosk-projection.json` |
| JSON output (Coffee Shop Café) | `generated/projections/coffeeshop-cafe-projection.json` |

The `generated/projections/` directory is new. Created by the engine on first run.

---

## 9. Execution Sequence

| Stage | Scope | Estimated time | Depends on |
|---|---|---|---|
| Stage 1 | Projection engine core + JSON output | 45–60 min | — |
| Stage 2 | CSV, markdown, console output formats | 20–30 min | Stage 1 |
| Stage 3 | Sensitivity analysis | 20–30 min | Stage 1 |
| Stage 4 | Coffee shop demonstrator extension | 20–30 min | Stage 1 |

Stages 2, 3, and 4 are independent of each other and can be done in any order after Stage 1. Total estimated session time: 1.5–2.5 hours.

---

## 10. Acceptance Criteria (Phase-Level)

1. **Projection engine runs and produces a 24-month time series** for the Lean Clinical scenario
2. **Revenue, cost, and margin figures are in the ballpark** of the illustrative SysML values at all five checkpoint months
3. **Break-even month is approximately 14** (within ±2 months)
4. **Sensitivity analysis confirms patient acquisition rate** as the dominant sensitivity parameter
5. **Coffee shop scenarios run through the same engine** and produce hand-verifiable numbers
6. **Output formats are readable and shareable** — the markdown summary could be shown to a non-technical advisor; the CSV opens in a spreadsheet
7. **No external dependencies** — the engine runs with Python stdlib only

---

## 11. Deferred Items (Not in Phase 4 Scope)

These items are noted for the deferred items list:

- **SysML illustrative value updates:** If the engine produces more accurate values than the Phase 3 hand-calculations, update the illustrative `ProjectionOutput` usages in `business-model.sysml` (separate commit)
- **Manifest integration:** The engine currently hard-codes parameters. A future version reads from the System Model Manifest JSON (when the manifest generator exists)
- **Plotting:** The engine produces data; plotting is done externally (spreadsheet from CSV, or future matplotlib addition). Plotting is not a Phase 4 deliverable
- **Full Platform scenario parameters:** Phase 5 adds the second scenario
- **Projection generator:** A generator that reads `ProjectionFormula` usages from SysML and produces engine code. Deferred until formula patterns stabilise through hand-written implementation
- **Initiation fee/revenue modelling:** The current model only captures assessment fee and monitoring fee. If there is a separate initiation-period fee (e.g. for titration appointments), this should be added when the pricing model matures
- **Shared care revenue impact:** When shared care arrangements redirect monitoring to GPs, the monitoring revenue stream changes. Not modelled in Phase 4
- **Seasonal variation:** All growth assumptions are linear or stepped. Seasonal effects (e.g. lower referrals in August) are not modelled

---

## 12. Relationship to Other Plans

| Plan | Relationship |
|---|---|
| Business Meta Model Phase 5 (Second Scenario) | Phase 5 adds Full Platform parameters and runs both scenarios through the engine. Phase 4 engine must support multiple parameter sets. |
| Coffee Shop Demonstrator Integration | Phase 4 Stage 4 delivers the demonstrator extension. |
| Knowledge Layer Elaboration | Independent. No interaction with Phase 4. |
| Coffee Shop Knowledge Layer Extension | Independent. Can interleave. |
| Next Steps and Deferred Items | Phase 4 deferred items (section 11 above) should be added to the master deferred items list at session end. |

---

*Plan prepared 11 March 2026 (Session 16). Ready for execution.*
