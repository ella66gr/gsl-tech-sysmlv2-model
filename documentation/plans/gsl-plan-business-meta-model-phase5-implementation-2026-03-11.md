# Plan: Business Meta Model Phase 5 — Second Scenario and Comparison

**Project:** GenderSense (GSL)
**Date:** 11 March 2026
**Status:** Draft for review
**Parent plan:** `gsl-plan-business-meta-model-implementation-2026-03-10.md` (Phase 5, section 7)
**Predecessor:** `gsl-plan-business-meta-model-phase4-implementation-2026-03-11.md`

---

## 1. Purpose

Add a second business model variant (Full Platform, Variant B) to the SysML model and projection engine, and produce a side-by-side comparison with the existing Lean Clinical variant (Variant A). This is the comparator exercise that validates whether the meta-model vocabulary and projection infrastructure are genuinely variant-flexible, not just Lean-Clinical-shaped.

**Critical scope principle:** The goal of Phase 5 is to demonstrate structural capability, not to produce a validated business plan. All parameter values for Variant B are illustrative placeholders. The acceptance criteria are about whether the infrastructure handles a structurally different business model, not whether the financial projections are correct. We are building a tool, not using the tool — that comes later, with Ella's input on real pricing and resource assumptions.

---

## 2. What Phase 5 Is Testing

Three capability questions:

1. **Does the SysML vocabulary accommodate a structurally different business model?** Variant B has subscription revenue (not per-episode), multiple resource types (clinician + coach + community moderator), and additional service offerings (coaching, education, community). If the Phase 1–3 part defs handle this without modification, the meta-model design is validated. If they need changes, that's an equally valuable finding — document the required changes and make them.

2. **Does the projection engine handle a second clinical configuration?** The engine already handles clinical and coffee shop via domain dispatch. Variant B is a second clinical configuration with a different revenue model and resource mix. This tests whether the parameterisation is flexible enough, or whether the engine has Variant-A assumptions baked in.

3. **Does the comparison output produce something Ella can look at and immediately assess?** A side-by-side table is the first tangible "so what?" deliverable from this entire workstream. It should be clear, concise, and obviously checkable.

---

## 3. Guardrails

These are explicit constraints to prevent the Phase 4 pattern of getting drawn into parameter finessing:

**G1. No parameter tuning against external benchmarks.** Variant B parameters are set once from the meta-modelling document (section 7.1) and reasonable extrapolation. They are not adjusted to produce "realistic" projections. If the numbers look implausible, that's noted as a finding, not fixed.

**G2. No debugging of financial divergences.** If Variant B projections produce surprising results, the response is to document the surprise, not to investigate root causes or calibrate parameters. Root cause analysis is Ella's prerogative with real pricing data.

**G3. Structural problems are fixed; content problems are noted.** If a part def can't represent subscription revenue, that's a structural problem — fix the part def. If the subscription price seems too high, that's a content problem — note it and move on.

**G4. Coffee shop demonstrator parity.** Every new SysML pattern used in Variant B must also be demonstrated in the coffee shop world. This maintains the coffeeshop-first validation principle.

**G5. Time-box per stage.** Each stage below should be completable in a single focused session. If a stage is running long, stop and assess whether the scope has crept.

---

## 4. Pre-flight Checks

Before starting implementation:

- [ ] Read the syntax reference (`documentation/reference/gsl-sysml-v2-syntax-reference-v3.10-2026-03-11.md`) — check for any patterns needed by Variant B that haven't been verified
- [ ] Verify `business-model.sysml` parses clean in current state (Syside check)
- [ ] Verify `projection_engine.py` runs without errors for Lean Clinical scenario
- [ ] Review the `variantFullPlatform` placeholder in StrategyAndEvolution to confirm what's already modelled

---

## 5. Stage 1 — Full Platform ServiceConcept Extension

### Scope

Add the Variant B service offerings and any additional customer segments, value propositions, or channels that Variant B requires but Variant A does not.

### Deliverables

New part usages in `ServiceConcept`:

- **ServiceOfferings** (3 new, extending the 3 existing ones):
  - `coachingService : ServiceOffering` — gender identity coaching, subscription-based
  - `educationService : ServiceOffering` — structured education modules, included in subscription
  - `communityAccess : ServiceOffering` — peer community platform, included in subscription

- **ValuePropositions** (1–2 new, if Variant B serves segments differently):
  - `holisticCareModel : ValueProposition` — clinical + coaching + community as integrated package

- **Channels** (0–1 new):
  - `communityReferral : Channel` — existing community members referring new patients (if materially different from existing channels)

### Design decisions

- New offerings use `pricingBasis = "subscription"` to contrast with Variant A's `"per-episode"`
- `clinicalPathwayRef` for coaching and education may be empty or reference future pathways — this is acceptable at placeholder level
- Existing Variant A offerings are shared, not duplicated — Variant B includes assessment + HRT + monitoring AND the new offerings

### Acceptance criteria

- Syside parses without errors
- New offerings are visible in hierarchy
- No changes to existing part defs required (if changes are needed, document them as a finding)

---

## 6. Stage 2 — Full Platform Resource and Financial Extension

### Scope

Add Variant B resource types, instances, capabilities, cost drivers, and revenue streams.

### Deliverables

**ResourcePlanning additions:**

- `genderCoach : ResourceType` — coaching qualification, contracted, cost TBD
- `communityModerator : ResourceType` — part-time community management role
- `coachInstance : ResourceInstance` — 0.5 FTE coach
- `moderatorInstance : ResourceInstance` — 0.2 FTE moderator
- `coachingCapability : Capability` — ability to deliver coaching sessions
- `communityCapability : Capability` — ability to run peer community platform
- `fullPlatformCapacity : CapacityModel` — 2 clinicians + coach + moderator capacity model

**FinancialPlanning additions:**

- `subscriptionRevenue : RevenueStream` — monthly subscription fee from active patients
- `coachCost : CostDriver` — coach personnel cost
- `moderatorCost : CostDriver` — moderator personnel cost
- `subscriptionPricing : PricingModel` — monthly subscription pricing logic
- `subscriptionUnitEconomics : UnitEconomics` — per-subscriber financial profile

### Illustrative parameter values

These are placeholders. They are set to produce a structurally complete model, not a validated projection:

| Parameter | Value | Basis |
|---|---|---|
| Subscription fee | £99/month | Placeholder — round number in plausible range |
| Coach cost | £3,000/FTE/month | Placeholder — below clinician rate |
| Moderator cost | £2,000/FTE/month | Placeholder — part-time community role |
| Second clinician (from month 6) | 0.5 FTE stepping to 1.0 FTE | Placeholder — earlier scaling than Variant A |
| Platform cost (Variant B) | £500/month | Higher than Variant A due to community infrastructure |

### Acceptance criteria

- Syside parses without errors
- New resource types and financial elements visible in hierarchy
- No changes to existing part defs required

---

## 7. Stage 3 — Full Platform ScenarioDefinition

### Scope

Create the `fullPlatformScenario : ScenarioDefinition` with full parameterisation in ScenarioModelling. This is the core of Phase 5.

### Deliverables

- `fullPlatformScenario : ScenarioDefinition` — Variant B scenario
- ~15–20 ProjectionParameter usages (revenue, cost, growth, conversion, churn — mirroring Variant A's parameter set but with different values and additional parameters for subscription and coaching)
- 3–5 GrowthAssumption usages (patient acquisition, subscription uptake, clinician scaling)
- ProjectionFormula usages only if Variant B requires formulas structurally different from Variant A (e.g. subscription revenue formula). If the same formulas apply with different parameter values, no new formulas are needed — document this as a finding.
- 3–5 illustrative ProjectionOutput usages (months 1, 6, 12, 18, 24) — hand-estimated, not engine-derived. These serve as sanity-check targets for the engine, same role as Variant A's illustrative values.
- SensitivityParameter usages for Variant B (subscription price sensitivity, coach utilisation sensitivity)

### Key structural question

**Does subscription revenue require a new ProjectionFormula, or can it be expressed as a parameter variation of the existing formulas?**

Variant A: `revenue = assessments × fee + stablePatients × quarterlyFee / 3`
Variant B: `revenue = assessments × fee + activeSubscribers × monthlySubscription + stablePatients × quarterlyFee / 3`

This is likely a new formula (subscription revenue is additive to clinical revenue). Document whether the existing formula vocabulary handles this or needs extension.

### Design decisions

- Variant B's ScenarioDefinition references both Variant A offerings (assessment, HRT, monitoring) AND the new Variant B offerings (coaching, education, community)
- `variantLabel = "B"` to distinguish from Variant A's `"A"`
- Update the existing `variantFullPlatform` placeholder in StrategyAndEvolution to reference the new ScenarioDefinition via `scenarioRef`

### Acceptance criteria

- Syside parses without errors
- ScenarioDefinition is self-contained — all inputs for projection are present
- Hierarchy generator shows correct element counts
- The structural question above is answered and documented

---

## 8. Stage 4 — Projection Engine Extension

### Scope

Add Variant B parameters to the projection engine and produce projections.

### Deliverables

- New parameter set in `projection_engine.py`: `FULL_PLATFORM_PARAMS`
- Command-line support: `--scenario=full-platform`
- Handle subscription revenue model (monthly subscription fee × active subscribers)
- Handle additional resource types (coach, moderator) in cost calculation
- Handle higher platform cost
- Handle second clinician scaling
- JSON, CSV, markdown output for Variant B

### Structural changes to engine

The key question is whether the existing engine architecture (cohort model → financial model → output) handles Variant B or needs restructuring:

- **Cohort model:** Likely unchanged — patients still flow through assessment → active pool. Subscription count may equal active patient count, or may differ if some patients are clinical-only. Simplest assumption: all active patients are subscribers. Document if this assumption is made.
- **Financial model:** Needs extension for subscription revenue line and additional cost lines (coach, moderator). The `compute_monthly_financials` function (or equivalent) needs to accept these additional parameters.
- **Output model:** ProjectionOutput part def already has the right fields. No changes expected.

### Acceptance criteria

- Engine runs for `--scenario=full-platform` and produces 24-month time series
- Revenue includes both clinical and subscription components
- Cost includes clinician, admin, coach, moderator, platform, insurance, lab, overhead
- Month 1 and month 12 values are hand-verifiable
- No changes to Variant A output (regression check)

---

## 9. Stage 5 — Comparison Output

### Scope

Produce a side-by-side ScenarioComparison and instantiate the `ScenarioComparison` part def in the SysML model.

### Deliverables

**Projection engine comparison mode:**

- Command-line: `--compare=lean-clinical,full-platform`
- Output: markdown table with side-by-side metrics

**Comparison metrics** (per meta-modelling document section 7.3):

| Metric | Variant A | Variant B |
|---|---|---|
| Initial investment estimate | | |
| Break-even month | | |
| Margin at month 24 | | |
| Cumulative cash flow at month 24 | | |
| Maximum cash deficit | | |
| Active patients at month 24 | | |
| Clinician FTE at month 24 | | |
| Total staff FTE at month 24 | | |
| Revenue diversification (streams) | | |
| Dominant sensitivity parameter | | |

**SysML instantiation:**

- `leanVsFullComparison : ScenarioComparison` in ScenarioModelling with summary notes

**Sensitivity comparison:**

- Run sensitivity analysis for both variants
- Identify which variant is more robust to acquisition shortfall (the dominant risk)
- Output as part of comparison markdown

### Acceptance criteria

- Comparison runs and produces readable output
- Ella can look at the table and immediately form a view on whether the numbers are in the right ballpark
- ScenarioComparison compiles in Syside

---

## 10. Stage 6 — Coffee Shop Demonstrator Parity

### Scope

Extend the coffee shop demonstrator to exercise any new SysML patterns introduced in Stages 1–5.

### Deliverables

This stage is conditional — only needed if new structural patterns were introduced. Likely candidates:

- If subscription revenue required a new ProjectionFormula pattern → add a "coffee subscription" scenario to the coffee shop demonstrator (e.g. a loyalty card / monthly pass model alongside per-drink pricing)
- If new resource types required changes to ResourcePlanning part defs → add corresponding coffee shop resources
- If no new structural patterns were needed → document this as a positive finding (the existing vocabulary was sufficient) and skip this stage

### Acceptance criteria

- Every new SysML pattern used in Variant B has a coffee shop equivalent
- Coffee shop demonstrator files parse in Syside
- Coffee shop projection scenarios run in the engine

---

## 11. File Impact Assessment

### Files likely to be modified

| File | Expected changes |
|---|---|
| `model/business-model.sysml` | New part usages in ServiceConcept, ResourcePlanning, FinancialPlanning, ScenarioModelling, StrategyAndEvolution. Estimated +200–300 lines. |
| `scripts/projection_engine.py` | New FULL_PLATFORM_PARAMS dict, subscription revenue handling, comparison mode. Estimated +150–200 lines. |

### Files likely to be created

| File | Purpose |
|---|---|
| `exercises/coffeeshop-demonstrator/model/coffeeshop-subscription.sysml` | Coffee shop subscription scenario (conditional — Stage 6) |

### Files not modified

| File | Rationale |
|---|---|
| All other `.sysml` files | Phase 5 is contained within BusinessModel |
| `documentation/reference/*.md` | Updated only if new syntax findings emerge |

### File size concern

`business-model.sysml` is currently ~950 lines. Phase 5 will push it to ~1,150–1,250 lines. This is still manageable as a single file, but if it crosses ~1,500 lines, a file-splitting strategy should be implemented (deferred item from Phase 3).

---

## 12. Relationship to Phase 4 Findings

Phase 4 (Session 16) identified several parameter questions. Phase 5's stance on each:

| Phase 4 finding | Phase 5 stance |
|---|---|
| `effectiveMonthlyRevenuePerPatient` = £134 (calibrated, not validated) | Use the same value for Variant B's clinical revenue component. Do not re-calibrate. |
| Cost 20–40% above illustrative values | Accept the engine's cost model as-is. Do not adjust overhead or lab costs. |
| Utilisation ~50% below illustrative values | Accept. Utilisation model extension is a future item. |
| Revenue model finding (monitoring fee doesn't capture full revenue) | Use `effectiveMonthlyRevenuePerPatient` for Variant B too. Subscription revenue is additive. |

**In short: inherit Variant A's parameter questions, don't try to solve them, and add Variant B's own placeholder parameters on top.**

---

## 13. Estimated Scope

| Stage | Estimated effort | Primary deliverable |
|---|---|---|
| Stage 1 — ServiceConcept extension | 30 min | 3 new service offerings + value proposition |
| Stage 2 — Resource and Financial extension | 45 min | New resource types, cost drivers, revenue stream |
| Stage 3 — ScenarioDefinition | 60 min | Full parameterisation of Variant B |
| Stage 4 — Projection engine extension | 60 min | Working projections for Variant B |
| Stage 5 — Comparison output | 30 min | Side-by-side table + SysML instantiation |
| Stage 6 — Coffee shop parity | 30 min (conditional) | Subscription scenario if needed |

Total: approximately 3.5–4.5 hours across 1–2 sessions.

---

## 14. Success Criteria (Phase Level)

Phase 5 is successful if:

1. The meta-model vocabulary (part defs from Phases 1–3) handles Variant B without structural modification, OR required modifications are identified, made, and documented.
2. The projection engine produces Variant B projections using the same architecture as Variant A, with subscription revenue handled cleanly.
3. The comparison output is a single readable table that Ella can review and assess in under 5 minutes.
4. No time was spent tuning Variant B parameters to look "right." All parameter values are documented as illustrative placeholders.
5. Coffee shop parity is maintained.

---

*Plan prepared 11 March 2026. Phase 5 of the Business Meta Model implementation.*
