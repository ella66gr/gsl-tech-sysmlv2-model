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

#### 4.1 Immediate: select clinical archetypes from CKM

Begin selecting existing archetypes from the openEHR Clinical Knowledge Manager for the hormone therapy initiation pathway. Many clinical concepts already have well-designed archetypes: laboratory results, medication orders and administration, vital signs, clinical assessments, patient questionnaires. The discipline of reuse-first is essential — the coffee shop exercise required custom archetypes because no coffee archetypes exist, but clinical archetypes are mature.

#### 4.2 Immediate: design GenderSense-specific templates

Templates compose existing archetypes into use-case-specific data sets. A "hormone monitoring bloods" template might compose existing lab result archetypes with GenderSense-specific constraints (which tests, which ranges). Design templates in Archetype Designer, export OPTs via Firefox.

#### 4.3 Near-term: generate composition builders from OPTs

Hand-maintained composition builders don't scale to clinical archetypes with hundreds of terms. Write a generator that reads the OPT XML and produces TypeScript builder functions with correct term mappings, RM hierarchy, and ISM transition handling for ACTION archetypes. This is the next generation pipeline extension after the existing SysML-to-Temporal generators.

#### 4.4 Near-term: SNOMED CT terminology binding

Design archetypes with SNOMED CT terminology binding from the outset. The binding pattern is the same as the local-code pattern used in the exercise — only the terminology source changes. The openEHR/SNOMED CT collaboration means binding patterns are increasingly well-documented.

#### 4.5 Near-term: modify `prepareDrink` to commit compositions

The preparation composition builder and EHRbase template are in place. Modifying the `prepareDrink` activity to commit preparation compositions (mirroring `validateOrder`) would bring workflow orders into governance compliance and complete the CDR integration for the coffee shop domain.

#### 4.6 Medium-term: scheduled governance audits as Temporal workflows

The on-demand governance audit (Phase D) should evolve into scheduled Temporal cron workflows for GenderSense. The pattern: query CDR for expected compositions (derived from pathway model constraints), query for actual compositions, join in application code, produce governance reports, and optionally trigger contingency workflows for identified gaps.

#### 4.7 Medium-term: evaluate EHRbase vs commercial CDR

EHRbase is excellent for development. For production, evaluate operational burden against commercial openEHR CDR options (Better, EHRbase commercial support). The REST API is standardised, so the application code is CDR-implementation-agnostic.

#### 4.8 Deferred: FHIR bridge for NHS interoperability

EHRbase supports a FHIR-to-openEHR bridge. This is relevant for NHS interoperability (GP Connect, NHS Spine) but not needed until GenderSense integrates with external NHS systems. Design the CDR layer correctly now; the FHIR bridge adds a translation layer later.

## Coffeeshop Demonstrator Spec

### Future Direction

This demonstrator is explicitly a proof of concept. The following are not in scope but are anticipated next steps if the approach validates successfully:

- **Syside Automator integration:** Replace regex-based generators with semantic model access for more robust and maintainable generation.
- **Guard condition support:** When Syside Modeler supports guard syntax in action flows, extend the Temporal generator to produce conditional branching from model-level guards.
- **Parallel execution:** SysML fork/join constructs mapped to Temporal `Promise.all()` for concurrent activity execution.
- **satisfy/verify relationships:** SysML requirement-to-constraint traceability used to auto-generate compliance check logic in audit reports.
- **Temporal Cloud evaluation:** Assess managed hosting vs self-hosted for production GenderSense deployment.
- **Clinical pathway demonstrator:** Apply the validated architecture to a real GenderSense clinical pathway (e.g. hormone therapy initiation) as the next domain exercise.

## Generated Package Hierarchy Pipeline - Plan

**Purpose:** Ensure the package hierarchy overview stays current, visible, and correct as the model evolves.

### Future Enhancements

- **Pre-commit hook** — auto-regenerate on commit so files are always current
- **Syside Automator mode** (`--mode=syside`) — semantic model access for accurate element counting and relationship traversal
- **Traceability overlay** — show satisfy/verify relationships in the mindmap
- **Clickable source links** — markmap nodes link to the `.sysml` file and line

## Hormone Initiation Modelling

**Context:** First clinical pathway for end-to-end SysML v2 modelling in GenderSense (06/03/26 )

### Deferred

- **openEHR archetype design** — the pathway identifies what clinical data is captured and when, which directly informs archetype design, but the archetype work itself is deferred to the CDR integration exercise
- **Generator migration** — Syside Automator is confirmed ready, but generators are not needed until we want to produce executable code from this pathway
- **Front-end design** — patient portal forms, clinician views, and patient-facing information are downstream of the model
- **Shared care protocol detail** — the transition-to-shared-care step is modelled as a single action; the internal complexity of shared care negotiation is a separate pathway to elaborate later
- **Prescribing protocol detail** — regimen selection logic is noted as a clinical decision point; the detailed decision table (DMN-style) is deferred to when we work on `Knowledge::DecisionModels`

## Knowledge Layer Phase 5 Implementation

### Intentionally not delivered

- **Production-ready generators** — these are prototypes that prove the generation pattern works against the current model. Production hardening is future work
- **Changes to the SysML model** — Phase 5 reads from the model; it does not modify it. If the model needs minor formatting adjustments to support reliable regex parsing, those changes are noted for a future session
- **Runtime evaluation engine** — the generators produce evaluation *functions*; the evaluation engine that invokes them at runtime (within Temporal activities) is a separate implementation concern
- **Temporal workflow generator extensions** — the existing `gen_temporal_workflow.py` needs extension to emit evaluation engine calls when it encounters `@LogicRule` or `@SafetyConstraint` metadata. This is noted as a future step, not a Phase 5 deliverable
- **CDR composition builder generators** — generating TypeScript composition builders from OPT XML depends on resolving the OPT generation blocker (Archetype Designer / Ocean Template Designer). Deferred. This was resolved by using Firefox.
- **Syside Automator-based generators** — Phase 5 uses regex-based parsing, consistent with the existing generators. Automator migration is planned when the API stabilises (targeted Syside 1.0)

### Future work enabled by Phase 5

Phase 5 deliverables opened several follow-on work streams:

**Immediate follow-on:**

- **Temporal workflow generator extension** — extend `gen_temporal_workflow.py` to emit `evaluationEngine.evaluate("constraintName", patient)` calls when it encounters `@LogicRule` or `@SafetyConstraint` metadata annotations on action steps
- **Composition builder generator** — once the OPT generation blocker is resolved, generate TypeScript composition builders from openEHR templates
- **Outcome evaluator generator** — extend the constraint evaluator pattern to generate outcome evaluation functions from OutcomeDefinition usages

**Medium-term:**

- **Syside Automator migration** — rewrite Phase 5 generators using Automator's semantic model access, using the regex generator outputs as verification baselines
- **Evaluation engine runtime** — build the TypeScript module that loads generated specs, resolves inputs via InputDerivation queries, calls generated evaluation functions, and produces EvaluationResults. This is the component that the LogicEngine::ConstraintEvaluator part def describes structurally
- **Manifest-driven UI** — build a clinician/admin dashboard that reads the System Model Manifest to display constraint inventory, pathway inventory, and entity lifecycle state
- **Scheduled governance Temporal workflow** — use the manifest + generated evaluators to run population-level constraint evaluation as a scheduled Temporal cron workflow (the Phase D governance audit generalisation)

**Longer-term:**

- **Prolog rule generation** — if the Tau Prolog spike is positive, build a generator that produces Prolog rules from SysML constraint defs for Tier 2 compound reasoning
- **Full CI/CD generation pipeline** — pre-commit hooks that regenerate all generated artefacts when `.sysml` files change, with diff checks to catch unexpected output changes

## SysML.v2 Modelling Strategy

## 9. Recommendations

### 9.1 Immediate Next Steps

#### 9.1.1 Establish the top-level package skeleton

Create the full package hierarchy in Syside Modeler with minimal content: package declarations, brief doc comments describing scope, and placeholder use case definitions where appropriate. This immediately provides the "nothing is off the map" assurance and creates the namespace structure for all subsequent work. Time estimate: one to two sessions.

#### 9.1.2 Gather and synthesise legacy artefacts

Collect legacy business analysis material from SHC/MedMind and other prior projects. Use Claude Cowork to trawl through the material and extract structural patterns, entity catalogues, process inventories, and recurring architectural themes. The output is a curated synthesis document that informs the SysML modelling, not a direct import. This can proceed in parallel with the package skeleton work.

#### 9.1.3 Model the first clinical pathway

Following the demonstrator's recommendation 7.2, model hormone therapy initiation end to end using the validated architecture. This pathway exercises long-running waits (lab results, specialist referrals), multiple participants (patient, GP, endocrinologist, phlebotomy), governance requirements (consent, clinical review intervals, monitoring schedules), and the full two-layer action flow pattern. It will be the proof that the architecture works at realistic clinical complexity.

### 9.2 Near-Term Priorities

#### 9.2.1 Validate the satisfy/verify traceability chain

Verify that SysML v2 requirement-to-constraint traceability (`satisfy`/`verify` relationships) works in Syside Modeler. For GenderSense, clinical requirements must trace to evaluable constraints, which must trace to runtime checks, which must trace to audit evidence. This was not verified in the demonstrator and should be an early priority.

#### 9.2.2 Extend the metadata library for clinical patterns

Build on the demonstrator's TemporalMetadata package with metadata definitions for clinical-specific patterns: consent requirements, clinical review gates, multi-participant handoff points, regulatory reporting triggers, logic rule markers, and decision table annotations. These form the shared vocabulary that all pathway models import.

#### 9.2.3 Evaluate Syside Automator for generation

The demonstrator used regex-based SysML parsing, which was adequate for controlled formatting but fragile for larger models maintained over longer periods. Syside Automator provides semantic model access and should replace the regex generators. Early evaluation will determine whether Automator's capabilities are sufficient for the planned generation targets.

#### 9.2.4 Validate the openEHR integration patterns

As identified in the Architecture Principles document, the immediate technical priority is validating the openEHR CDR integration: standing up EHRbase locally, designing minimal archetypes and templates, committing compositions from Temporal workflow activities, querying via AQL, and running a population-level governance query.

### 9.3 Medium-Term Considerations

#### 9.3.1 Logic engine integration

Determine the runtime target for logic programming: embedded Prolog (e.g. Tau Prolog in TypeScript), a dedicated constraint evaluation library, a DMN engine, or a combination. The choice should be informed by the complexity of the clinical decision rules encountered during the first pathway modelling. The architectural space is reserved in the Knowledge::LogicEngine package; the implementation technology decision can be deferred until the rules are better understood.

#### 9.3.2 Form generation from model

Investigate generation of clinical form definitions from SysML v2 model elements. Forms are a major surface area for clinical data capture and a natural candidate for model-driven generation. The form model should capture fields, validation rules, conditional logic, and mappings to openEHR compositions.

#### 9.3.3 Population-level governance

Extend the Phase D governance pattern from individual workflow audit to population-level clinical governance. This involves scheduled Temporal workflows that query the CDR, evaluate rules derived from the SysML model, and produce governance reports covering the entire patient cohort.

#### 9.3.4 Temporal deployment planning

Plan the transition from the development environment (`temporal server start-lite`) to a durable deployment. Self-hosted Temporal on a small cloud VM with PostgreSQL persistence is the recommended starting point, with Temporal Cloud as an option if operational overhead becomes a concern.

## Validated Architectural Patterns

### Future generators (designed, not built)

- Temporal workflow generator extension: emit `evaluationEngine.evaluate()` calls from `@LogicRule` / `@SafetyConstraint` metadata
- Composition builder generator: OPT XML → TypeScript CDR composition builders
- Outcome evaluator generator: `OutcomeDefinition` usages → TypeScript outcome evaluation functions
- Prolog rule generator: `constraint def` → Tau Prolog rules (contingent on Tier 2 adoption)

## Business Meta Model — Projection Engine (Phase 4)

### Revenue model parameter gap

- **`effectiveMonthlyRevenuePerPatient` as new SysML ProjectionParameter** — the existing `monitoringFeePerQuarter` (£150) captures only the quarterly blood review fee. The effective blended revenue is approximately £134/patient/month (~£400/quarter). A new parameter should be added to ScenarioModelling to make this explicit. Requires Ella to validate against actual clinical pricing intentions.

### SysML model updates (after parameter validation)

- Update illustrative `ProjectionOutput` values in `business-model.sysml` to match validated engine output
- Consider splitting monitoring revenue into explicit initiation-period and stable-period fees
- Consider renaming or generalising `activePatientsTotal` field in ProjectionOutput for domain-agnostic use (low priority — carried forward from Session 15)

### Engine enhancements

- Clinician utilisation model extension — include non-patient-facing activities (governance, CPD, admin, documentation). Current model captures only direct patient-facing hours.
- Overhead percentage validation — 25% may be too high given the granular lab cost model
- Plotting / visualisation (matplotlib or similar) — currently CSV export to spreadsheet is sufficient
- Manifest integration — engine reads parameter values from generated System Model Manifest JSON
- Projection generator — SysML `ProjectionFormula` usages → engine code. Deferred until formula patterns stabilise through hand-written implementation.
- Comparison mode — side-by-side output for two scenarios (prep for Phase 5)

### Phase 3 deferred items (carried forward from Session 15)

- Formal `ref` from ScenarioDefinition to ServiceOffering (deferred to Phase 7)
- Full 24-month ProjectionOutput time series — now produced by the engine; SysML illustrative values cover months 1, 6, 12, 18, 24 only
- ScenarioComparison instantiation (Phase 5)
- `VarianceSource` enum used as typed attribute (Phase 6)
- Formal `satisfy` from StrategicObjective to Capability (Phase 7)
- Full Platform ScenarioDefinition (Phase 5)
- Variant C elaboration (beyond Phase 5)
- File splitting strategy for `business-model.sysml` (Phase 5 planning)
- PeriodActuals and VarianceAnalysis instantiation (Phase 6)

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