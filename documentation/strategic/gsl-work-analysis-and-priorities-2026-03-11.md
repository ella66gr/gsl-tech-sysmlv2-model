# GSL — Systematic Work Analysis and Priorities

**Date:** 11 March 2026
**Context:** Post Business Meta Model (Phases 1–7), post Knowledge Layer Elaboration (Phases 1–5). 72-package model, 364KB SysML, 24 session reports, working generation pipeline, running coffee shop demonstrator.
**Purpose:** Systematic analysis of all deferred and outstanding work, organised to support prioritisation decisions. Assessed against stated priorities: robust formalised constructs, correct SysML usage, best-practice approaches, reusable modular architecture.

---

## Assessment Framework

Each work item is assessed against four criteria aligned with stated priorities:

| Criterion | What it means |
|---|---|
| **Formalisation** | Replaces informal (string-typed, doc-block-described, convention-dependent) constructs with structurally enforced, tool-validated ones |
| **SysML Correctness** | Exercises SysML v2 constructs as intended by the specification; resolves known Syside limitations or workarounds |
| **Best Practice** | Follows established patterns (separation of concerns, single source of truth, metadata-driven generation, two-layer architecture) |
| **Reusability / Modularity** | Produces patterns, part defs, generators, or architectural structures that generalise across domains and pathways |

Items are grouped into seven workstreams, each containing related items. Within each workstream, items are ordered by alignment with priorities (highest first). Estimated effort is expressed in stages (one stage ≈ 30–60 minutes of session time).

---

## Workstream 1: Model Structural Formalisation

*Replaces informal string-typed cross-references with typed `ref` relationships, establishing machine-traceable links across the model. This is the most directly aligned workstream with the stated priority of robust, formalised constructs.*

### 1.1 Formalise `ref` from ServiceOffering to ClinicalPathways

**Current state:** `ServiceOffering.clinicalPathwayRef` is a `String` attribute. The business model references clinical pathways by name only — no structural traceability, no tool validation, no generator access.

**Work:** Replace with `ref clinicalPathway : HormoneTherapyInitiation[0..*]` (or a generalised pathway type). Requires a cross-domain import from `BusinessModel::ServiceConcept` to `ServiceDelivery::ClinicalPathways`. Syntax pattern (`ref` to `action def` across packages) needs verification in Syside.

**Benefits:**
- Syside validates that the referenced pathway exists — renames and deletions are caught at parse time
- Generators can traverse the link: "for this service offering, what pathways does it deliver?" without string matching
- The business model ↔ service delivery mapping becomes a structural fact, not a convention
- Essential prerequisite for a second clinical pathway — without typed refs, cross-pathway analysis is string parsing

**Risks:** Creates a deliberate cross-domain coupling (business model → service delivery). This coupling is real and desirable — the concern noted in the deferral was about understanding the implications, which are now well understood after 7 phases of business model work.

**Priority alignment:** Formalisation ★★★ | SysML Correctness ★★ | Best Practice ★★★ | Reusability ★★★
**Effort:** 1–2 stages (including syntax verification)
**Dependencies:** None

---

### 1.2 Formalise `ref` from ScenarioComparison to ScenarioDefinition

**Current state:** `ScenarioComparison.scenarioRefs` is a `String`. Comparison references scenarios by name.

**Work:** Replace with `ref scenarios : ScenarioDefinition[2..*]`. Import already exists (BusinessScenarios is a peer package). The `ref x : Type[0..*]` pattern was verified in Phase 7 (v3.11).

**Benefits:**
- Structural link from comparison to the scenarios it compares — tool-validated, generator-accessible
- Consistent with the Phase 7 pattern where `ref relatedScenarios : ScenarioDefinition[0..*]` was verified in BusinessStrategy

**Priority alignment:** Formalisation ★★★ | SysML Correctness ★★ | Best Practice ★★ | Reusability ★★
**Effort:** 1 stage
**Dependencies:** None — syntax already verified

---

### 1.3 Investigate `ref` to `requirement def` as a type

**Current state:** `ResourceConstraint.regulatorySourceDescription` is a `String` describing which regulation requirement applies. The deferred question is whether `ref regulatorySource : ConsentBeforeTreatment` (typing a ref by a `requirement def`) works in Syside.

**Work:** Syntax investigation in a test file. If it works, formalise the ResourceConstraint → Regulation link. If it doesn't, document the limitation and confirm the current string-typed approach as the correct workaround.

**Benefits:**
- If successful: full traceability from business model resource constraints to regulatory requirements — the entire chain from strategy → capability → resource constraint → regulation becomes machine-navigable
- Either way: the syntax reference gains a verified finding, reducing uncertainty for future modelling

**Priority alignment:** Formalisation ★★★ | SysML Correctness ★★★ | Best Practice ★★ | Reusability ★★
**Effort:** 1 stage (investigation + documentation)
**Dependencies:** None

---

### 1.4 Domain-agnostic naming in projection types

**Current state:** `ProjectionOutput.activePatientsTotal` and `PeriodActuals.actualPatientCount` use healthcare-specific names. Coffee shop demonstrator sets these to 0.

**Work:** Rename to `activeCustomersTotal` / `actualCustomerCount` (or a more generic term like `activeUnitsTotal`). Update all usages in both main model and coffee shop demonstrator.

**Benefits:**
- The projection machinery becomes genuinely domain-agnostic — any service business can instantiate it without healthcare naming leaking through
- Consistent with the meta-modelling principle that the business model structures are generic and healthcare specifics arise only at instantiation

**Priority alignment:** Formalisation ★ | SysML Correctness ★ | Best Practice ★★ | Reusability ★★★
**Effort:** 1 stage (rename + verify parse)
**Dependencies:** None

---

## Workstream 2: SysML v2 Language Depth

*Investigates and validates SysML v2 constructs that are currently unused or unverified in the model. Extends the team's command of the language and potentially unlocks more expressive modelling.*

### 2.1 Port definitions and connections

**Current state:** Platform subsystems are modelled as part defs with attributes and use cases. Inter-subsystem interfaces are described in doc blocks but not structurally modelled.

**Work:** Define `port def` elements for key Platform interfaces (e.g. EHR ↔ Booking, Forms ↔ CDR, Messaging ↔ Orchestration). Connect subsystems using `connection` or `interface` elements. Verify the syntax in Syside.

**Benefits:**
- Platform subsystem interfaces become structural facts, not documentation — Syside validates that connections reference real ports
- Enables a future "interface inventory" in the system manifest: "what connects to what, through which ports"
- Exercises a major SysML v2 structural construct that the model currently doesn't use at all
- Foundation for eventual component diagram rendering in Syside (when view/viewpoint matures)
- Directly enables analysis of integration impact: "if I change the EHR API, what subsystems are affected?"

**Priority alignment:** Formalisation ★★★ | SysML Correctness ★★★ | Best Practice ★★★ | Reusability ★★★
**Effort:** 2–3 stages (investigation + initial ports + connections)
**Dependencies:** None, but benefits most from a consolidation context

---

### 2.2 Use case def elaboration (include, extend, subject, actor)

**Current state:** 100+ use case defs across the model, all at the simple `use case def Name { doc /* ... */ }` level. None use SysML v2's structural use case composition: `include use case`, `extend use case`, `subject`, or `actor`.

**Work:** Verify `include use case` and `actor` syntax in Syside. If supported, elaborate a representative subset of use cases (e.g. PatientJourney's five-phase arc) to demonstrate composition. Model actors (Patient, Clinician, SystemAdmin) as `part def` elements referenced by use cases.

**Benefits:**
- Use cases gain structural relationships — "RegisterPatient includes VerifyIdentity, CollectConsent, CreateAccount" is a model fact, not a doc block narrative
- Actors become first-class elements traceable across the model: "which use cases involve the Patient actor?"
- Generators could produce structured use case documentation (actor-goal tables, include/extend hierarchies)
- Moves towards standard use case modelling practice in SysML v2

**Priority alignment:** Formalisation ★★★ | SysML Correctness ★★★ | Best Practice ★★★ | Reusability ★★
**Effort:** 2–3 stages (syntax investigation + actor modelling + elaboration)
**Dependencies:** None

---

### 2.3 Metadata def specialisation and advanced patterns

**Current state:** All metadata defs are standalone definitions with scalar String attributes. The syntax reference notes three unverified patterns: enum-valued metadata attributes, metadata def specialisation (one extending another), and metadata applied to state def or requirement def elements.

**Work:** Investigate each pattern in test files. If specialisation works, consider refactoring the clinical metadata library: a base `@ClinicalAnnotation` with specialised variants `@ClinicalReviewGate :> ClinicalAnnotation`, `@SafetyConstraint :> ClinicalAnnotation`, sharing common attributes (e.g. `auditRequired : Boolean`).

**Benefits:**
- If specialisation works: the metadata library gains an inheritance hierarchy, reducing repetition and enabling generators to treat all clinical annotations uniformly at the base level while preserving specific attributes at the specialised level
- Enum-valued metadata attributes would allow constrained annotation values (e.g. `severity : Severity` instead of `severity : String`) — validated at parse time, not just by convention
- Metadata on state defs/requirement defs could annotate lifecycles and regulatory requirements with generation metadata — opening new generator targets

**Priority alignment:** Formalisation ★★ | SysML Correctness ★★★ | Best Practice ★★★ | Reusability ★★★
**Effort:** 2 stages (investigation + refactoring if viable)
**Dependencies:** None

---

### 2.4 Nested `:>>` redefinition inside contained parts

**Current state:** The `:>>` pattern works for top-level attributes in part usages. Whether it works for attributes of *contained* parts inside part usages is unverified. This matters for deeply structured evaluation specs where an InputDerivation part inside a ConstraintEvaluationSpec usage might need attribute redefinition.

**Work:** Test the pattern in a syntax test file. Document findings in the syntax reference.

**Benefits:**
- If it works: evaluation specs can carry fully redefined nested structures — moving InputDerivation detail from doc blocks into structural SysML, making them generator-accessible
- Either way: resolves a long-standing syntax reference TODO and clarifies the depth of the `:>>` pattern

**Priority alignment:** Formalisation ★★★ | SysML Correctness ★★★ | Best Practice ★★ | Reusability ★★
**Effort:** 1 stage
**Dependencies:** None

---

## Workstream 3: Architecture Generalisation (Second Pathway)

*Tests whether the architecture built around one clinical pathway generalises to a second, different pathway. This is the single most important architectural validation remaining.*

### 3.1 Model a second clinical pathway

**Current state:** One clinical pathway (Hormone Therapy Initiation) is fully modelled with two-layer action flows, entity lifecycle state machines, metadata annotations, and constraint evaluation specs. The entire Knowledge layer, generation pipeline, and evaluation architecture was designed and validated against this single pathway.

**Work:** Model a second pathway — likely Ongoing Monitoring, Shared Care Transition, or Follow-Up Assessment. This pathway would have different characteristics: shorter cadence (quarterly reviews vs. initiation sequence), fewer decision points, heavier emphasis on population-level monitoring, and different entity lifecycle patterns (prescription renewals, periodic lab reviews). Requires:
- Domain-layer action flow (governance)
- Orchestration-layer action flow (runtime, with metadata annotations)
- Entity lifecycle extensions or new entity types as needed
- Constraint defs for the new pathway's safety rules
- Constraint evaluation specs
- Decision tables if applicable (e.g. dose adjustment logic, shared care eligibility)

**Benefits:**
- **Validates architecture generalisation:** Does the two-layer pattern, metadata annotation scheme, constraint evaluation spec pattern, and generator pipeline work for a structurally different pathway? Any friction reveals architectural assumptions baked to the first pathway.
- **Triggers cross-pathway rule sharing:** Some constraints (consent, blood monitoring interval) apply to both pathways. This forces the question of how shared constraints are structured — per-pathway specs referencing shared constraint defs, or a constraint scope mechanism.
- **Exercises the ServiceOffering → ClinicalPathway mapping** (especially if 1.1 is done first): a service offering may now map to multiple pathways.
- **Validates the five-layer self-knowledge architecture** at a more realistic scope: governance audits across two pathways, gap analysis spanning different monitoring cadences.
- **Provides generator stress testing:** Do the constraint evaluator and decision table generators handle a second set of inputs cleanly? Does the manifest generator reflect the expanded model correctly?

**Priority alignment:** Formalisation ★★★ | SysML Correctness ★★ | Best Practice ★★★ | Reusability ★★★
**Effort:** 4–6 stages (domain flow + orchestration flow + constraints + evaluation specs + demonstrator parity). Likely a 2–3 session workstream.
**Dependencies:** Benefits from 1.1 (ServiceOffering ref) and 1.3 (ref to requirement def) being resolved first, but neither is strictly required.

---

## Workstream 4: Generation Pipeline Maturation

*Extends the generation pipeline from its current "proof of concept" state to a more robust, model-driven toolchain. Aligned with the separation principle: execution layer consumes representation layer via generation.*

### 4.1 Temporal workflow generator extension — evaluation engine calls

**Current state:** The Temporal workflow generator (`gen_temporal_workflow.py`) generates activity calls from `@TemporalActivity` annotations and signal handlers from `@TemporalSignal`. It does *not* yet generate evaluation engine calls from `@LogicRule` or `@SafetyConstraint` annotations. These are the annotations on clinical pathway steps that should invoke constraint evaluation at runtime.

**Work:** Extend the generator to recognise `@LogicRule` and `@SafetyConstraint` metadata and emit `await evaluationEngine.evaluate("constraintName", patientContext)` calls in the generated workflow. The evaluation result determines whether the workflow proceeds or blocks.

**Benefits:**
- Closes the end-to-end generation chain: SysML pathway model → generated Temporal workflow → runtime constraint evaluation → structured EvaluationResult → audit record
- Currently this chain is designed and documented (Architecture Decision document, section 1) but the generator gap means the last mile is hand-written. Closing the gap makes the pathway model the true single source of truth for runtime behaviour.
- The generator becomes the bridge between the Knowledge layer (constraint specs) and the ServiceDelivery layer (pathway action flows) — the wiring that the architecture describes becomes a generated artefact.

**Priority alignment:** Formalisation ★★★ | SysML Correctness ★★ | Best Practice ★★★ | Reusability ★★★
**Effort:** 2–3 stages
**Dependencies:** Coffee Shop Increment 1 (4.5 below) is the natural proving ground for this

---

### 4.2 Projection generator — SysML formulas to engine code

**Current state:** The projection engine (`projection_engine.py`) reads scenario parameters from a hand-maintained Python dictionary. The SysML model has `ProjectionFormula` usages that describe the same calculations structurally, but the engine doesn't consume them.

**Work:** Build a generator that reads `ProjectionFormula` usages from the SysML model and produces the corresponding projection engine code (or a configuration that the engine reads).

**Benefits:**
- The projection engine becomes model-driven: changing a formula in the SysML model automatically updates the projection calculations
- Currently, SysML formulas and engine code must be kept in sync manually — this is a violation of the single-source-of-truth principle
- The coffee shop demonstrator is the natural first target: its simpler formula set makes verification straightforward

**Priority alignment:** Formalisation ★★★ | SysML Correctness ★★ | Best Practice ★★★ | Reusability ★★★
**Effort:** 3–4 stages (formula parsing + code emission + verification against existing engine output)
**Dependencies:** Formula patterns should stabilise first — deferred until parameter validation (5.1) is done

---

### 4.3 System manifest generator enrichment

**Current state:** The manifest generator (`gen_system_manifest.py`) produces a JSON manifest with 8 inventory sections covering constraints, requirements, lifecycles, pathways, outcomes, decision tables, metadata, and use cases. The manifest is adequate for Layer 1 structural self-knowledge.

**Work:** Extend the manifest to include: typed cross-references (once 1.1/1.2 are done), port/connection inventory (once 2.1 is done), actor inventory (once 2.2 is done), business model elements (ServiceConcept, ActivityModel, ResourcePlanning), and scenario parameters.

**Benefits:**
- The manifest becomes a comprehensive structural projection of the entire model — everything a runtime component needs to know about the system's structure is in one machine-readable file
- Enables richer Layer 1 self-knowledge: "what service offerings exist, what pathways do they map to, what resources do they require, what constraints apply?"
- Foundation for model-aware dashboards and operational tooling

**Priority alignment:** Formalisation ★★ | SysML Correctness ★ | Best Practice ★★★ | Reusability ★★★
**Effort:** 2–3 stages (incremental — each new section is independent)
**Dependencies:** Benefits from 1.1, 1.2, 2.1, 2.2 being done first

---

### 4.4 Migrate generators from regex to Syside Automator

**Current state:** All generators use regex-based text parsing of `.sysml` files. This works because the formatting is controlled, but it is inherently fragile and doesn't support arbitrary formatting, comments in unexpected positions, or multi-line expressions.

**Work:** Migrate the constraint evaluator, decision table evaluator, and manifest generators to use Syside Automator's `evaluate_filter` API for semantic model access. The Automator spike (Session 12) passed all 10 evaluation tests.

**Benefits:**
- Generators become robust against formatting changes — they read the semantic model, not text
- Enables extraction of metadata annotations, cross-references, and nested structures that regex can't reliably parse
- The Automator API is the intended long-term generation interface — early migration reduces technical debt
- Unlocks new generator capabilities: traversing `ref` relationships, filtering by metadata, accessing inherited attributes

**Priority alignment:** Formalisation ★★ | SysML Correctness ★★ | Best Practice ★★★ | Reusability ★★★
**Effort:** 3–5 stages (per generator, incremental migration)
**Dependencies:** Syside Automator stability (currently 0.8.5 — approaching 1.0)

---

### 4.5 Coffee Shop Knowledge Layer Increments (1–3)

**Current state:** Three planned increments exercise the Knowledge layer in a running system. All infrastructure is in place (Temporal, SvelteKit, EHRbase, generators). None have been executed.

**Work:**
- **Increment 1 — Constraint evaluation at a pathway step.** SysML constraint def → generated evaluator → Temporal activity → structured EvaluationResult. Tests generator domain-agnosticism.
- **Increment 2 — Decision table for drink routing.** Decision table in coffee shop model → generated evaluator → workflow routing with explainable output.
- **Increment 3 — System self-assessment dashboard.** Manifest + operational queries + assessment assembly → SvelteKit dashboard showing live system state.

**Benefits:**
- **Increment 1** proves the full evaluation chain end-to-end in a running system — the most important validation gap remaining in the Knowledge layer
- **Increment 2** proves that the decision table pattern works at runtime, not just at generation time
- **Increment 3** proves the five-layer self-knowledge architecture produces visible, useful output — the first time the model's self-knowledge capability is exercised as a running feature
- All three are low-risk (toy domain, existing infrastructure) and high-learning
- Directly de-risks the clinical implementation of constraint evaluation, decision support, and governance dashboards

**Priority alignment:** Formalisation ★★ | SysML Correctness ★ | Best Practice ★★★ | Reusability ★★★
**Effort:** 2–3 stages total (estimated 1 session, per integration plan)
**Dependencies:** None — all infrastructure is in place

---

## Workstream 5: Business Model and Projection Refinement

*Refines the business meta model from illustrative to validated, and closes the loop between SysML parameters and engine calculations.*

### 5.1 Clinical pricing parameter validation

**Current state:** `effectiveMonthlyRevenuePerPatient` is derived from `monitoringFeePerQuarter` (£150) but the effective blended revenue is ~£134/patient/month. Overhead percentage (25%) may be too high. These are illustrative placeholders, not validated figures.

**Work:** Ella validates against actual clinical pricing intentions. Update the SysML model parameters and re-run projections.

**Benefits:**
- Projections become grounded in real pricing — shifts the business model from "structural test" to "planning instrument"
- Enables genuine sensitivity analysis: "what happens if I charge £180/quarter instead of £150?"
- Prerequisite for the projection generator (4.2) — formula patterns should stabilise on real parameters

**Priority alignment:** Formalisation ★ | SysML Correctness ★ | Best Practice ★★ | Reusability ★
**Effort:** 1–2 stages (Ella's clinical input + model update + re-run)
**Dependencies:** Requires Ella's domain knowledge, not session time with Claude

---

### 5.2 Variant C elaboration — Consultancy + Platform Licence

**Current state:** Two business model variants are fully elaborated (Lean Clinical, Full Platform). Variant C (Consultancy + Platform Licence — dual revenue from clinical practice and SaaS licensing) is a placeholder.

**Work:** Model the Variant C scenario: licence pricing structures, platform deployment for licensees, support and training cost structures, dual revenue stream interactions. Create a ScenarioDefinition with growth parameters and run projections.

**Benefits:**
- The three-variant comparison becomes complete — the business model genuinely supports strategic decision-making across the full option space
- Tests the business model's expressiveness for a structurally different revenue model (licensing vs. direct service)
- May reveal missing part defs or attributes in the BusinessModel that the first two variants didn't exercise

**Priority alignment:** Formalisation ★★ | SysML Correctness ★ | Best Practice ★★ | Reusability ★★
**Effort:** 2–3 stages
**Dependencies:** Benefits from 5.1 (validated parameters) being done first

---

### 5.3 Projection engine — clinician utilisation model extension

**Current state:** Utilisation model counts patient-facing clinical hours only. Non-patient-facing activities (governance, CPD, admin, documentation) are excluded.

**Work:** Extend the utilisation calculation to include non-clinical time as a proportion of total available hours. This is an ActivityModel concern — the activity taxonomy already classifies activities as service delivery, service-enabling, governance, development, and overhead.

**Benefits:**
- Utilisation figures become realistic — important for workforce planning and for demonstrating to investors that the model accounts for the full clinician workload
- Connects the ActivityModel taxonomy (already modelled in SysML) to the projection engine — another instance of model-driven calculation

**Priority alignment:** Formalisation ★ | SysML Correctness ★ | Best Practice ★★ | Reusability ★★
**Effort:** 1–2 stages
**Dependencies:** 5.1 (parameter validation)

---

## Workstream 6: Model Consolidation and Quality

*Steps back from feature development to review the model holistically for consistency, completeness, and clarity. The model has grown through 19 sessions and multiple architectural phases — consolidation catches accumulated inconsistencies.*

### 6.1 Naming consistency review

**Current state:** The model was built incrementally over three major workstreams. Naming conventions evolved: early packages use shorter names, later packages use more descriptive compound names. Some attribute names are healthcare-specific where they should be generic (1.4). Some enum literal styles vary (camelCase vs. lowercase).

**Work:** Systematic review of all part def, attribute, and enum names across the 10 model files. Apply consistent conventions: compound attribute names, camelCase enum literals, domain-agnostic names where the construct is generic. Document the naming convention in the repo conventions guide.

**Benefits:**
- The model reads as a coherent whole rather than a chronological accretion
- Generators produce consistent output (e.g. TypeScript interface names match a uniform convention)
- Reduces cognitive overhead when navigating the model
- The documented naming convention prevents future inconsistencies

**Priority alignment:** Formalisation ★★ | SysML Correctness ★ | Best Practice ★★★ | Reusability ★★
**Effort:** 2–3 stages
**Dependencies:** None — can be done at any time, but benefits from being done before major new modelling work

---

### 6.2 Doc block completeness audit

**Current state:** Core packages (Knowledge, ServiceDelivery, BusinessModel) have thorough doc blocks. Platform subsystems, Operations, and some Enterprise elements have minimal or placeholder doc blocks.

**Work:** Systematic pass through every package and part def. Ensure each has a doc block that explains: what it is, why it exists, how it relates to adjacent elements, and any design decisions. Focus on Platform (20+ subsystems) and Operations (6 sub-packages).

**Benefits:**
- The model becomes self-documenting — anyone reading a `.sysml` file can understand the intent without external documentation
- Doc blocks are the primary input for governance documentation generation (Mermaid diagrams, pathway documentation)
- Future LLM-assisted code generation benefits from rich doc blocks as context
- Catches modelling gaps: the act of documenting often reveals missing relationships or unclear boundaries

**Priority alignment:** Formalisation ★★ | SysML Correctness ★ | Best Practice ★★★ | Reusability ★★
**Effort:** 2–4 stages (largely mechanical but benefits from thoughtful review)
**Dependencies:** None

---

### 6.3 Package hierarchy and structural simplification review

**Current state:** 72 packages. Some packages (e.g. Knowledge::Analytics, Platform::Integration) are lightweight stubs. Others (e.g. Knowledge::LogicEngine at 21 parts) are densely populated. The hierarchy reflects design-time structuring decisions that may benefit from reassessment now that the model is more complete.

**Work:** Review the package hierarchy for: packages that should be merged (too thin to justify), packages that should be split (too large or covering multiple concerns), sub-packages that should be promoted or demoted, and naming that doesn't align with the current understanding of the domain.

**Benefits:**
- A cleaner hierarchy is easier to navigate, explain, and maintain
- The `gsl view` output becomes a more accurate map of the system
- Generator output (manifest, type generation) reflects a more intentional structure

**Priority alignment:** Formalisation ★ | SysML Correctness ★ | Best Practice ★★★ | Reusability ★★
**Effort:** 1–2 stages (review + targeted refactoring)
**Dependencies:** None

---

### 6.4 README and repo conventions update

**Current state:** The README describes the project as of the initial package skeleton (5 March 2026). The file structure section is out of date (missing business-model.sysml, business-scenarios.sysml, business-strategy.sysml). The repo conventions guide predates the business meta model work.

**Work:** Update the README to reflect the current project state: 72 packages, 10 model files, generation pipeline, coffee shop demonstrator, documentation corpus. Update the repo conventions guide to include the business model file split convention, the session report numbering scheme, and the plan file naming convention.

**Benefits:**
- Someone encountering the repo for the first time (including future-Ella after a break) gets an accurate orientation
- Conventions are documented where they can be followed consistently

**Priority alignment:** Formalisation ★ | SysML Correctness ★ | Best Practice ★★ | Reusability ★★
**Effort:** 1 stage
**Dependencies:** Best done after other consolidation work is complete

---

## Workstream 7: Runtime and Integration (Deferred — Not Current Priority)

*Items that are architecturally designed but depend on implementation decisions, external system maturity, or clinical data readiness. Included for completeness; these are correctly deferred.*

### 7.1 CDR / openEHR clinical implementation

Clinical archetype design from CKM, SNOMED CT terminology binding, FHIR bridge, production CDR hosting, openEHR SDK/code generation, composition builder generator, openEHR Folders.

**Why correctly deferred:** These depend on clinical content decisions (which archetypes, which terminology codes) that are downstream of pathway modelling. The CDR exercise validated all integration patterns. Implementation waits for clinical pathway breadth.

### 7.2 Prolog / Tier 2 implementation

Tau Prolog integration in Temporal, Prolog rule generator from constraint defs, compound deficit reasoning.

**Why correctly deferred:** The current constraint library is fully served by generated TypeScript (Tier 1). Tier 2 becomes valuable when clinical rules demand compound inference — likely triggered by the second clinical pathway or by compound deficit patterns in real governance audits.

### 7.3 ML/LLM / Tier 3 integration

Advisory intelligence, LLM-assisted explanations, predictive analytics.

**Why correctly deferred:** Tier 3 is interface-only in the model. Implementation depends on data volume, clinical validation requirements, and regulatory clarity around AI in clinical decision support.

### 7.4 External clinical knowledge sources

NICE guidelines, BNF, drug interaction databases.

**Why correctly deferred:** Integration concerns that depend on clinical pathway breadth and on specific clinical content decisions.

---

## Summary: Priority Matrix

| # | Item | Formalisation | SysML | Best Practice | Reusability | Effort | Recommendation |
|---|---|:---:|:---:|:---:|:---:|---|---|
| **2.1** | Port definitions and connections | ★★★ | ★★★ | ★★★ | ★★★ | 2–3 stages | **High — new structural dimension** |
| **2.2** | Use case elaboration (include, actor) | ★★★ | ★★★ | ★★★ | ★★ | 2–3 stages | **High — 100+ use cases to formalise** |
| **1.1** | ServiceOffering → ClinicalPathways ref | ★★★ | ★★ | ★★★ | ★★★ | 1–2 stages | **High — core cross-domain link** |
| **3.1** | Second clinical pathway | ★★★ | ★★ | ★★★ | ★★★ | 4–6 stages | **High — architecture generalisation** |
| **4.5** | Coffee Shop Knowledge Layer (1–3) | ★★ | ★ | ★★★ | ★★★ | 2–3 stages | **High — runtime validation** |
| **4.1** | Temporal generator — evaluation calls | ★★★ | ★★ | ★★★ | ★★★ | 2–3 stages | **High — closes generation chain** |
| **2.3** | Metadata def specialisation | ★★ | ★★★ | ★★★ | ★★★ | 2 stages | **Medium-high — advanced language** |
| **2.4** | Nested `:>>` redefinition | ★★★ | ★★★ | ★★ | ★★ | 1 stage | **Medium-high — quick syntax answer** |
| **1.2** | ScenarioComparison → ScenarioDef ref | ★★★ | ★★ | ★★ | ★★ | 1 stage | **Medium — straightforward** |
| **1.3** | Ref to requirement def investigation | ★★★ | ★★★ | ★★ | ★★ | 1 stage | **Medium — syntax investigation** |
| **6.1** | Naming consistency review | ★★ | ★ | ★★★ | ★★ | 2–3 stages | **Medium — hygiene** |
| **6.2** | Doc block completeness | ★★ | ★ | ★★★ | ★★ | 2–4 stages | **Medium — self-documentation** |
| **4.3** | Manifest generator enrichment | ★★ | ★ | ★★★ | ★★★ | 2–3 stages | **Medium — depends on other items** |
| **1.4** | Domain-agnostic naming | ★ | ★ | ★★ | ★★★ | 1 stage | **Medium — quick win** |
| **6.3** | Package hierarchy review | ★ | ★ | ★★★ | ★★ | 1–2 stages | **Medium — structural hygiene** |
| **6.4** | README / conventions update | ★ | ★ | ★★ | ★★ | 1 stage | **Low-medium — documentation** |
| **4.4** | Generator migration to Automator | ★★ | ★★ | ★★★ | ★★★ | 3–5 stages | **Low-medium — Syside maturity gate** |
| **4.2** | Projection generator | ★★★ | ★★ | ★★★ | ★★★ | 3–4 stages | **Low-medium — parameter gate** |
| **5.1** | Clinical pricing validation | ★ | ★ | ★★ | ★ | 1–2 stages | **When ready — Ella's input** |
| **5.2** | Variant C elaboration | ★★ | ★ | ★★ | ★★ | 2–3 stages | **Low — extends existing pattern** |
| **5.3** | Utilisation model extension | ★ | ★ | ★★ | ★★ | 1–2 stages | **Low — engine refinement** |

---

## Suggested Sequencing

Three natural groupings emerge from the dependency and priority analysis:

### Phase A: Structural Deepening (5–8 stages, 2–3 sessions)

Focus: Exercise underused SysML v2 constructs and formalise existing informal structures. Produces the foundation for subsequent modelling work.

1. Quick syntax investigations: nested `:>>` (2.4), `ref` to `requirement def` (1.3) — 2 stages
2. Port definitions and initial connections (2.1) — 2–3 stages
3. Use case elaboration: `include`, `actor` (2.2) — 2–3 stages
4. Formalise cross-references: ServiceOffering ref (1.1), ScenarioComparison ref (1.2) — 2 stages

Coffee shop parity: port pattern in coffee shop model (subsystem interfaces).

### Phase B: Runtime Validation (4–6 stages, 1–2 sessions)

Focus: Close the gap between modelled architecture and running system. Proves the Knowledge layer works at runtime.

1. Coffee Shop Knowledge Layer Increments 1–3 (4.5) — 2–3 stages
2. Temporal generator extension for evaluation calls (4.1) — 2–3 stages

Coffee shop parity: this *is* the coffee shop work.

### Phase C: Architecture Generalisation (6–10 stages, 2–4 sessions)

Focus: Second clinical pathway. The most significant architectural test remaining.

1. Model consolidation review (6.1, 6.2, 6.3) — 3–5 stages (preparation)
2. Second clinical pathway (3.1) — 4–6 stages
3. Post-pathway: manifest enrichment (4.3), README update (6.4) — 2 stages

Coffee shop parity: if a second pathway reveals new patterns, demonstrate in coffee shop.

---

*Analysis prepared 11 March 2026. Derived from: `gsl-plan-next-steps-and-deferred-items.md`, `gsl-validated-architectural-patterns.md`, `gsl-plan-coffeeshop-demonstrator-integration-2026-03-10.md`, `gsl-architecture-decision-knowledge-evaluation.md`, `gsl-platform-architecture-principles.md`, syntax reference v3.11, and direct review of the complete codebase.*
