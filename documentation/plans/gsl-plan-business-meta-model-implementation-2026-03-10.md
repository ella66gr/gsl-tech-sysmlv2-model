# Plan: Business Meta Model Implementation

**Project:** GenderSense (GSL)
**Date:** 10 March 2026 (Session 13)
**Status:** Approved for execution
**Source:** `gsl-service-business-meta-modelling.md` section 10 next steps
**Companion:** `gsl-plan-coffeeshop-demonstrator-integration-2026-03-10.md`

---

## 1. Purpose

Implement the Service Business Meta Model described in `gsl-service-business-meta-modelling.md` as a new top-level `BusinessModel` package in the SysML v2 model, alongside supporting infrastructure (projection engine, scenario definitions, Operations package expansion). The plan sequences the nine next steps from section 10 into seven implementation phases with dependencies, deliverables, and acceptance criteria.

---

## 2. Sequencing Rationale

The document identifies ServiceConcept and ScenarioModelling as likely first candidates. This plan sequences ServiceConcept first because it is the structural anchor — everything else (resources, finances, scenarios) derives from or references the service concept. ScenarioModelling follows ResourcePlanning and FinancialPlanning because scenarios compose parameters drawn from all three.

The projection engine (Phase 4) is deliberately hand-written, not generated, following the established pattern of hand-first-then-generate. The generation pipeline can be added when formula patterns stabilise.

The simulation harness (section 9) and system meta model extraction (section 8) are deferred as noted in the source document.

---

## 3. Phase 1 — ServiceConcept and Model Foundations

### Scope

Create `model/business-model.sysml`. Establish the top-level BusinessModel package with ServiceConcept and ActivityModel sub-packages.

### Deliverables

**Stage 1 — Package skeleton and ServiceConcept structure:**

- `BusinessModel` top-level package with doc block
- `BusinessModel::ServiceConcept` sub-package
- Part defs: `CustomerSegment`, `ValueProposition`, `ServiceOffering`, `Channel`, `DifferentiationClaim`
- Each with typed attributes per section 3.1 of the meta-modelling document
- `ServiceOffering` includes a reference to `ServiceDelivery::ClinicalPathways` (first cross-package connection between business model and system model)

**Stage 2 — GSL ServiceConcept instantiation:**

- Part usages instantiating the Lean Clinical variant's service concept:
  - CustomerSegments: self-referring individuals, GP-referred patients
  - ValuePropositions: faster access, integrated digital + clinical, specialist expertise
  - ServiceOfferings: InitialAssessment, HormoneTherapyInitiation, OngoingMonitoring
  - Channels: website/SEO, GP referral network
  - DifferentiationClaims: model-driven safety, patient portal visibility

**Stage 3 — ActivityModel sub-package:**

- `BusinessModel::ActivityModel` sub-package
- Part defs: `ActivityType`, `ActivityRecord`, `ActivityBudget`, `ActivityGranularity`, `ActivityCostAllocation`
- Enum def: `ActivityCategory` with five values (serviceDelivery, serviceEnabling, governance, development, overhead)
- Enum def: `GranularityLevel` with three values (envelope, category, tracked)
- Doc blocks establishing the progressive elaboration principle and cross-cutting nature

### Acceptance criteria

- Syside Modeler parses `business-model.sysml` without errors
- Import of `ServiceDelivery::ClinicalPathways` resolves correctly
- `gsl` hierarchy command shows BusinessModel with sub-packages and correct element counts
- Package hierarchy generator includes the new package

### Dependencies

- None (new file, new package)

### Syntax reference check

- Check `part def` with typed attributes pattern
- Check cross-package `import` syntax
- Check `enum def` syntax (verified previously)
- Check reserved word list before naming any attributes

---

## 4. Phase 2 — ResourcePlanning and FinancialPlanning

### Scope

Add ResourcePlanning and FinancialPlanning sub-packages to BusinessModel. These fill the two gaps identified in sections 4.3 and 4.4 of the meta-modelling document.

### Deliverables

**Stage 1 — ResourcePlanning:**

- `BusinessModel::ResourcePlanning` sub-package
- Part defs: `ResourceType`, `ResourceInstance`, `Capability`, `CapacityModel`, `ResourceConstraint`
- Each with typed attributes per section 3.3
- Doc block references to target packages (Platform capabilities, ServiceDelivery processes) — formal import relationships deferred until shapes are stable

**Stage 2 — FinancialPlanning:**

- `BusinessModel::FinancialPlanning` sub-package
- Part defs: `RevenueStream`, `CostDriver`, `UnitEconomics`, `PricingModel`, `FinancialProjection`
- Each with typed attributes per section 3.4
- Enum defs for pricing model types (perEpisode, subscription, tiered, slidingScale)

### Acceptance criteria

- Syside parses without errors
- Hierarchy generator shows correct element counts
- No circular import dependencies introduced

### Dependencies

- Phase 1 (ActivityModel must exist — CostDriver references ActivityCostAllocation)

### Design note

Cross-references to existing packages (Capabilities → Platform, CostStructure → Operations) are modelled as doc block references initially, not formal SysML imports. This avoids circular dependency traps in Syside while the structure is being explored. Formal references are added once the shapes are stable.

---

## 5. Phase 3 — ScenarioModelling and Lean Clinical Instantiation

### Scope

Add the ScenarioModelling sub-package and instantiate Variant A ("Lean Clinical") as a concrete ScenarioDefinition. This is steps 3–4 from section 10.

### Deliverables

**Stage 1 — ScenarioModelling structure:**

- `BusinessModel::ScenarioModelling` sub-package
- Part defs: `ScenarioDefinition`, `ProjectionParameter`, `GrowthAssumption`, `ProjectionFormula`, `ProjectionTimeline`, `ProjectionOutput`, `SensitivityParameter`, `ScenarioComparison`
- Part defs for operational steering: `PeriodActuals`, `VarianceAnalysis`, `ForecastBaseline`
- Enum defs: `GrowthShape` (linear, stepped, sCurve, custom), `VarianceSource` (volume, price, mix, timing)

**Stage 2 — Lean Clinical ScenarioDefinition:**

- Part usage: `leanClinicalScenario : ScenarioDefinition` with:
  - Active ServiceOfferings (referencing Phase 1 instantiations)
  - Concrete ProjectionParameter values per section 7.2
  - GrowthAssumptions per section 7.2
  - Key ProjectionFormulas (revenue, cost, margin, cumulative cash flow, utilisation)
  - SensitivityParameters per section 7.2

**Stage 3 — StrategyAndEvolution sub-package:**

- `BusinessModel::StrategyAndEvolution` sub-package
- Part defs: `StrategicObjective`, `BusinessModelVariant`, `PivotScenario`
- Variant A, B, C descriptions from section 7.1 as part usages (summary level — full elaboration of B and C is Phase 5)

### Acceptance criteria

- Syside parses without errors
- Lean Clinical scenario compiles with all parameter values
- The ScenarioDefinition is self-contained — given the scenario, all inputs required for projection are present or derivable
- Hierarchy generator counts match expected elements

### Dependencies

- Phase 1 (ServiceConcept instantiations referenced by ScenarioDefinition)
- Phase 2 (ResourcePlanning and FinancialPlanning part defs used as parameter types)

---

## 6. Phase 4 — Hand-Written Projection Engine

### Scope

Build a projection engine that takes the Lean Clinical ScenarioDefinition's parameters and produces time-series ProjectionOutputs. Step 5 from section 10. Also includes initial sensitivity analysis (step 6).

### Deliverables

**Stage 1 — Projection engine core:**

- Python module: `scripts/projection_engine.py`
- Reads scenario parameters (initially hard-coded from the SysML model values; later can read from the generated manifest)
- Implements the monthly-interval formulas from section 7.2:
  - Patient cohort tracking (assessment → initiation → stable, with conversion rates and churn)
  - Monthly revenue by stream
  - Monthly cost by driver (clinician, admin, platform, insurance, lab, overhead)
  - Monthly margin and cumulative cash flow
  - Clinician utilisation
- Produces ProjectionOutput as JSON (same structure as the SysML part def)
- Outputs to `generated/projections/lean-clinical-projection.json`

**Stage 2 — Projection visualisation:**

- Extend projection engine or add a companion script to produce:
  - CSV export (for spreadsheet review)
  - Markdown summary table (monthly figures for 24 months)
  - Key metrics: break-even month, maximum cash deficit, margin at month 24

**Stage 3 — Sensitivity analysis:**

- Parameterised runs varying the four sensitivity parameters from section 7.2:
  - newPatientsPerMonth: 2, 4, 6
  - assessmentFeePerPatient: £450, £600, £750
  - clinicianCostPerFTEPerMonth: £4,000, £5,000, £6,000
  - overheadPercentage: 20%, 25%, 35%
- Output: sensitivity summary showing break-even shift per parameter variation
- Identifies which parameters the scenario is most sensitive to

### Acceptance criteria

- Projection engine runs and produces 24-month time series
- Revenue, cost, and margin figures are hand-verifiable for at least month 1 and month 12
- Sensitivity analysis confirms that patient acquisition rate is the dominant sensitivity (per section 7.2 prediction)
- Output formats are readable and shareable

### Dependencies

- Phase 3 (scenario parameter values defined in the model)
- No SysML dependency — the engine reads parameters directly, not via generator

### Design note

This is deliberately hand-written Python, not generated from the SysML model. The generation pipeline for projection code is a future extension (section 7.4 of the meta-modelling document). Getting working projections quickly is the priority. The hand-written engine serves as the verification baseline for a future generator, following the same pattern used for constraint evaluators (hand-written coffee shop → generated from model).

---

## 7. Phase 5 — Second Scenario and Comparison

### Scope

Define Variant B ("Full Platform") as a ScenarioDefinition, run both variants through the projection engine, and produce a ScenarioComparison. Step 7 from section 10.

### Deliverables

**Stage 1 — Full Platform ScenarioDefinition in SysML:**

- Part usage: `fullPlatformScenario : ScenarioDefinition` with:
  - Extended ServiceOfferings (coaching, education, community, patient portal)
  - Higher resource levels (2 clinicians, 1 coach, 1 community moderator)
  - Subscription pricing model
  - Different growth assumptions (target 200 active patients in 18 months)
  - Higher investment and longer break-even horizon

**Stage 2 — Projection engine extension:**

- Add Full Platform parameters to the projection engine
- Handle subscription revenue model (distinct from per-episode)
- Handle multiple resource types (clinician, coach, moderator)

**Stage 3 — ScenarioComparison output:**

- Side-by-side comparison per section 7.3 structure:
  - Initial investment, break-even month, margin at month 24, maximum cash deficit
  - Resource requirements at month 24
  - Revenue diversification assessment
  - Sensitivity comparison (which variant is more robust to acquisition shortfall?)
- Output as markdown table and JSON

### Acceptance criteria

- Both scenarios produce plausible 24-month projections
- Comparison highlights structural trade-offs (capital requirement vs ceiling, risk profile vs diversification)
- The comparison format is suitable for discussion with a non-technical advisor

### Dependencies

- Phase 3 (Lean Clinical scenario already modelled)
- Phase 4 (projection engine operational)

---

## 8. Phase 6 — Operations Package Expansion and Steering Cycle

### Scope

Expand the existing Operations package per section 6 of the meta-modelling document. Wire the PeriodActuals → VarianceAnalysis → ForecastBaseline cycle to the Knowledge layer's self-knowledge infrastructure.

### Deliverables

**Stage 1 — Operations package expansion:**

- Expand `Operations::Finance` with sub-packages: Invoicing, PaymentReconciliation, AccountingIntegration, FinancialReporting
- Expand `Operations::People` with sub-packages: Workforce, Recruitment, ProfessionalDevelopment, IndemnityAndInsurance
- Add `Operations::EstatesAndFacilities` with: Premises, Equipment, Procurement
- Expand `Operations::Reporting` with: BusinessModelMetrics

**Stage 2 — Steering cycle wiring:**

- Map the forecast-actuals-rebaseline cycle to the Knowledge layer's five-layer SystemStateAssessment:
  - Layer 2 extension: OperationalStateAggregator queries financial actuals alongside clinical state
  - Layer 3 extension: GoalProjector projects from ProjectionFormulas alongside clinical requirements
  - Layer 4 extension: GapAnalyser produces financial variance Deficits alongside clinical deficits
  - Layer 5 extension: Remediation classification for business variances
- This may require additions to `model/knowledge.sysml` (extending existing part defs) or may be handled via doc block architectural notes

### Acceptance criteria

- Operations package compiles in Syside with expanded sub-packages
- The architectural connection between operational steering and self-knowledge is documented and structurally represented
- Hierarchy generator reflects expanded Operations structure

### Dependencies

- Phase 3 (ScenarioModelling components must exist for steering cycle to reference)
- Knowledge Layer Phases 1–5 (self-knowledge infrastructure must be in place)

---

## 9. Phase 7 — Governance Mapping and Strategy Elaboration

### Scope

Complete the BusinessModel package by elaborating StrategyAndEvolution and connecting Governance and Adaptation to the existing Enterprise package.

### Deliverables

**Stage 1 — StrategicObjective elaboration:**

- Concrete strategic objectives for GSL (200 active patients in 18 months, shared care with 50 GP practices, break-even by month 24)
- Satisfy relationships from objectives to capabilities and scenario parameters
- Timeframe and success criteria attributes

**Stage 2 — Governance cross-references:**

- Map `BusinessModel::StrategyAndEvolution` to `Enterprise::Strategy` (upgrading the current placeholder)
- Map `BusinessModel::ResourcePlanning::ResourceConstraint` to `Enterprise::Regulation` (regulatory constraints on resource use)
- Map `BusinessModel::FinancialPlanning` to `ServiceDelivery::ClinicalGovernance` (governance cost as a structural cost driver)

### Acceptance criteria

- All cross-references compile in Syside
- The five-concern framework (section 2.1) is fully represented across the BusinessModel and existing packages
- `gsl` hierarchy shows complete BusinessModel sub-package structure matching section 5.1

### Dependencies

- All preceding phases

---

## 10. Deferred Workstreams

### Simulation Harness (Section 9)

Architecturally enabled by Phases 1–5 above. Requires: patient generator, event generator, time compression mechanism, checkpoint/save/restore, decision point resolution agents, resource contention modelling. The Temporal workflow engine is the natural execution substrate. Significant design work — estimated multiple sessions.

**Trigger:** After the projection engine is working and at least two scenarios are evaluable (post-Phase 5).

### System Meta Model Extraction (Section 8)

Extract the generic system meta model from the maturing GSL SysML v2 model. Deferred until the existing six packages are stable enough to reveal genuinely generic patterns.

**Trigger:** When the GSL model has been applied to at least two clinical pathways and the business model package is structurally stable.

### Variant C ("Consultancy + Platform Licence")

A third ScenarioDefinition with dual revenue streams (clinical + SaaS). Requires modelling licence pricing, platform deployment for licensees, and support cost structures. Natural extension of Phase 5.

### Generation Pipeline for Projections

A generator that reads ScenarioDefinitions and ProjectionFormulas from the SysML model and produces projection engine code, paralleling the constraint evaluator generation pattern. Deferred until formula patterns stabilise through hand-written implementation.

---

## 11. Relationship to Existing Plans

| Existing plan | Relationship |
|---|---|
| Knowledge Layer Elaboration (Phases 1–5, complete) | Self-knowledge infrastructure referenced by Phase 6 steering cycle |
| Coffee Shop Knowledge Layer Extension (planned) | Independent workstream, interleaves with this plan |
| Coffee Shop Demonstrator Integration (companion plan) | Each phase above has a corresponding coffee shop demonstrator extension |
| Temporal Workflow Generator Extension (Session 12 recommendation 7.2) | Independent, can proceed in parallel |
| Evaluation Engine Runtime (Session 12 recommendation 7.3) | Independent, can proceed in parallel |

---

## 12. Estimated Scope

| Phase | Estimated sessions | Primary deliverable |
|---|---|---|
| Phase 1 — ServiceConcept + ActivityModel | 1 | `business-model.sysml` with two sub-packages |
| Phase 2 — ResourcePlanning + FinancialPlanning | 1 | Two additional sub-packages |
| Phase 3 — ScenarioModelling + Lean Clinical | 1–2 | Scenario sub-package + concrete instantiation |
| Phase 4 — Projection Engine | 1–2 | Working Python projection engine + sensitivity analysis |
| Phase 5 — Second Scenario + Comparison | 1 | Full Platform scenario + side-by-side comparison |
| Phase 6 — Operations Expansion + Steering | 1–2 | Expanded Operations + self-knowledge wiring |
| Phase 7 — Governance Mapping | 1 | Strategy elaboration + cross-references |

Total: approximately 7–11 sessions, depending on complexity encountered during instantiation and projection engine development.

---

*Plan prepared 10 March 2026 (Session 13). Companion to the Service Business Meta Modelling discussion document and the Coffee Shop Demonstrator Integration plan.*
