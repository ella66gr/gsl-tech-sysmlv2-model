# GSL - Next steps and deferred items

Last updated:

11/03/26

---

## Knowledge Layer Elaboration

### Deferred

- **Prolog implementation** — explored and evaluated, but not built until clinical rules demand inference capabilities beyond boolean constraints
- **DMN engine integration** — decision tables modelled in SysML; dedicated DMN engine is an optimisation
- **ML/LLM integration** — Tier 3 is interface-only; advisory capabilities depend on data volume and clinical validation
- **Cross-pathway rule sharing** — the hormone therapy constraints are pathway-specific; generalisation happens when a second pathway is modelled
- **External clinical knowledge sources** — NICE guidelines, BNF integration, drug interaction databases are integration concerns, not modelling concerns
- **Full manifest generation** — the manifest concept is designed; the generator is prototyped if time permits but is not a Phase 1 blocker
- **Compound remediation reasoning** — Layer 5 compound and advisory remediation is architecturally specified but implementation is deferred until the Prolog exploration matures and real deficit patterns are observed
- **Generated package hierarchy overview** — the markdown tree derived from the SysML model is a natural first output of the manifest generator, but it is a convenience, not a prerequisite

## Coffeeshop CDR Exercise

### Deferred

- **Clinical archetype design** — the hormone pathway identifies what data to capture; actual clinical archetype selection (from CKM) and template design happens after this exercise validates the integration patterns
- **SNOMED CT terminology binding** — the exercise uses local codes; SNOMED binding is a GenderSense concern that depends on specific clinical content
- **CDR hosting and deployment** — this exercise uses local Docker; production CDR hosting decisions (EHRbase self-hosted vs commercial openEHR CDR) are a later concern
- **openEHR SDK / code generation** — we use raw REST API calls; the openEHR Java/TypeScript SDKs and code generation from OPTs are optional optimisations
- **FHIR bridge** — EHRbase supports a FHIR-to-openEHR bridge; this is relevant for NHS interoperability but not for the CDR validation exercise
- **Folder organisation** — openEHR Folders can organise compositions within an EHR; not needed for the exercise's simple data model
- **Versioning and contributions** — openEHR supports composition versioning and audit-grade contributions; acknowledged but not exercised beyond basic commit
- **Generator updates** — modifying `gen_temporal_workflow.py` to emit CDR commit code is a Phase E / future concern

### Recommendations for GSL Clinical data

(Unchanged — sections 4.1–4.8 as before)

## Coffeeshop Demonstrator Spec

### Future Direction

(Unchanged)

## Generated Package Hierarchy Pipeline - Plan

(Unchanged)

## Hormone Initiation Modelling

(Unchanged)

## Knowledge Layer Phase 5 Implementation

(Unchanged)

## SysML.v2 Modelling Strategy

(Unchanged)

## Validated Architectural Patterns

### Future generators (designed, not built)

- Temporal workflow generator extension: emit `evaluationEngine.evaluate()` calls from `@LogicRule` / `@SafetyConstraint` metadata
- Composition builder generator: OPT XML → TypeScript CDR composition builders
- Outcome evaluator generator: `OutcomeDefinition` usages → TypeScript outcome evaluation functions
- Prolog rule generator: `constraint def` → Tau Prolog rules (contingent on Tier 2 adoption)

## Business Meta Model — Projection Engine (Phase 4)

### Revenue model parameter gap

- **`effectiveMonthlyRevenuePerPatient` as new SysML ProjectionParameter** — the existing `monitoringFeePerQuarter` (£150) captures only the quarterly blood review fee. The effective blended revenue is approximately £134/patient/month (~£400/quarter). A new parameter should be added to BusinessScenarios to make this explicit. Requires Ella to validate against actual clinical pricing intentions.

### SysML model updates (after parameter validation)

- Update illustrative `ProjectionOutput` values in `business-scenarios.sysml` to match validated engine output
- Consider splitting monitoring revenue into explicit initiation-period and stable-period fees
- Consider renaming or generalising `activePatientsTotal` field in ProjectionOutput for domain-agnostic use (low priority — carried forward from Session 15)

### Engine enhancements

- Clinician utilisation model extension — include non-patient-facing activities (governance, CPD, admin, documentation). Current model captures only direct patient-facing hours.
- Overhead percentage validation — 25% may be too high given the granular lab cost model
- Plotting / visualisation (matplotlib or similar) — currently CSV export to spreadsheet is sufficient
- Manifest integration — engine reads parameter values from generated System Model Manifest JSON
- Projection generator — SysML `ProjectionFormula` usages → engine code. Deferred until formula patterns stabilise through hand-written implementation.
- ~~Comparison mode — side-by-side output for two scenarios (prep for Phase 5)~~ **Done (Session 17)**
- Sensitivity "dominant" text misleading when break-even not reached in either scenario — the spread calculation falls back to 99-0=99. Minor formatting fix needed.
- Coffee shop subscription scenario not yet wired into the projection engine — SysML model is complete but engine `SCENARIOS` dict does not include a `coffeeshop-cafe-subscription` entry. Low priority — validates SysML pattern, not engine execution.

### Phase 3 deferred items (carried forward from Session 15)

- Formal `ref` from ScenarioDefinition to ServiceOffering (deferred to Phase 7)
- Full 24-month ProjectionOutput time series — now produced by the engine; SysML illustrative values cover months 1, 6, 12, 18, 24 only
- ~~ScenarioComparison instantiation (Phase 5)~~ **Done (Session 17)** — `leanVsFullComparison`
- ~~`VarianceSource` enum used as typed attribute~~ **Done (Session 18, Phase 6B)** — `varianceSource : VarianceSource` in VarianceAnalysis part def
- Formal `satisfy` from StrategicObjective to Capability (Phase 7)
- ~~Full Platform ScenarioDefinition (Phase 5)~~ **Done (Session 17)** — `fullPlatformScenario` with full parameterisation
- Variant C elaboration (beyond Phase 7)
- ~~File splitting strategy for `business-model.sysml`~~ **Done (Session 18, Phase 6A)** — split into three files
- ~~PeriodActuals and VarianceAnalysis instantiation~~ **Done (Session 18, Phase 6A/6B)** — coffee shop + GSL GoalProjection and Deficit

## Business Meta Model — Phase 5 Findings (Session 17)

(Unchanged)

## Business Meta Model — Phase 6A Findings (Session 18)

### File split

- **Promoted ScenarioModelling to BusinessScenarios** (top-level package, `business-scenarios.sysml`). Promoted StrategyAndEvolution to BusinessStrategy (`business-strategy.sysml`). BusinessModel retains ServiceConcept, ActivityModel, ResourcePlanning, FinancialPlanning.
- **Cross-file enum resolution confirmed** — `BusinessScenarios::GrowthShape::sCurve` resolves correctly from the coffee shop exercises directory through the `BusinessScenarios::*` import. No new syntax finding — consistent with v3.10.
- **Import path update scope was small** — only `coffeeshop-scenarios.sysml` needed updating. The other coffee shop files import from `BusinessModel::ServiceConcept::*` etc. which didn't change.

### Operations expansion

- **WorkforceRole part def** — captures the contract/qualification view of a role, complementing the planning view in ResourcePlanning::ResourceType. The two are connected by string reference (`resourceTypeRef`).
- **PremisesArrangement and EquipmentInventory** part defs — lightweight estates modelling. GSL instantiations confirm the solo-clinician model's minimal physical infrastructure.
- **ProduceBusinessModelMetrics use case** — the operational bridge to Phase 6B's steering cycle. This is where PeriodActuals data comes from.

### Coffee shop demonstrator (6A)

- **PeriodActuals and VarianceAnalysis validate for non-clinical domain** — the kiosk week 1 variance decomposition produces a readable explanation.
- **`actualPatientCount` domain mismatch confirmed** — the attribute name is healthcare-specific. Set to 0 in coffee shop context. Generalising to `actualCustomerCount` or similar is deferred (low priority).

## Business Meta Model — Phase 6B Findings (Session 18)

### Primary finding: self-knowledge architecture is domain-agnostic

**Zero new part defs added to Knowledge::LogicEngine.** The existing GoalProjection and Deficit part defs handle financial goals and variances without modification. A revenue shortfall is structurally identical to a clinical monitoring gap — both are cases where actual state falls short of expected state.

This validates the meta-modelling document section 4.7 thesis: "implementing the operational steering pattern is primarily an extension of existing infrastructure, not a parallel build."

### Structural changes

- **Foundation::CommonTypes** — 2 new enum literals: `DeficitDomain::financial`, `DataSourceType::accounting`
- **LogicEngine::OperationalSnapshot** — 8 new financial state attributes (forecast/actual revenue, cost, variance, active scenario)
- **LogicEngine::SystemStateAssessment** — 4 new business structural counters in Layer 1
- **LogicEngine::OperationalStateAggregator** — 1 new `financialDataQuery : OperationalQuery`
- **LogicEngine doc blocks** — GoalProjector, GapAnalyser, AssessmentOrchestrator, SelfExplanationService, InferenceEvaluator, Deficit all updated to document the business steering extension
- **BusinessScenarios::VarianceAnalysis** — `varianceSource` typed as `VarianceSource` enum (was String). Resolves Phase 3 deferred item.
- **BusinessScenarios** — new imports from `Knowledge::LogicEngine::*` and `Foundation::CommonTypes::*`. First cross-package dependency from business model to knowledge layer.

### Cross-package import validation

- `BusinessScenarios` importing `Knowledge::LogicEngine::*` resolves correctly — GoalProjection and Deficit part defs usable as part types for `:>>` redefinitions with Foundation::CommonTypes enum literals (`DeficitDomain::financial`, `Severity::warning`, `RemediationCategory::recommended`, `AssessmentScope::system`).
- Coffee shop exercises importing `Knowledge::LogicEngine::*` from the exercises directory also resolves correctly.

### Coffee shop demonstrator (6B)

- `VarianceSource::volume` enum literal resolves in `:>>` redefinition (was string `"volume"`)
- `GoalProjection` and `Deficit` instantiations for kiosk week 1 validate the pattern in a non-clinical domain
- The coffee shop deficit (`severity = informational`, `remediationCategory = advisory`) contrasts with the GSL deficit (`severity = warning`, `remediationCategory = recommended`) — showing the same remediation classification works at different severity levels

### Items remaining for Phase 7

- Formal `ref` from ScenarioDefinition to ServiceOffering
- Formal `satisfy` from StrategicObjective to Capability
- Governance cross-references (BusinessStrategy → Enterprise::Strategy, ResourceConstraint → Enterprise::Regulation)
- Variant C elaboration

### Standing items

- `activePatientsTotal` / `actualPatientCount` domain-specific naming — generalisation deferred
- Sensitivity "dominant" text formatting — minor
- Coffee shop subscription scenario not wired into projection engine — low priority

## Syntax Reference v3.7 (09.03.26)

### TODO: Patterns Not Yet Verified

- [ ] Port definitions and connections
- [ ] `metadata def` with non-scalar attribute types (e.g. enum-valued metadata attributes)
- [ ] `metadata def` specialisation (one metadata def extending another)
- [ ] `metadata def` applied to `state def` or `requirement def` elements
- [ ] `use case def` with `include use case`, `extend use case`, `subject`, `actor`
- [ ] SysML v2 `view` and `viewpoint` elements — Sensmetry forum (Jan 2026) confirms rendering from modelled views is "still a work in progress." Deferred.
- [ ] Syside CLI `viz` command for headless diagram export
- [ ] Generator: `gen_temporal_workflow.py` emitting `tryTransition()` from `@StateTransitionTrigger`
- [ ] Generator: `Promise.all()` from SysML `fork`/`join`
- [ ] Nested `:>>` redefinition inside contained parts inside part usages
