# GSL — Systematic Work Analysis and Priorities

**Date:** 14 March 2026 (updated from 12 March 2026)
**Context:** Post Business Meta Model (Phases 1–7), post Knowledge Layer Elaboration (Phases 1–5), post CSW Extension Phase 6 (Session 25). 72-package model, 364KB SysML, 25 sessions, working generation pipeline, running coffee shop demonstrator with catalogue-driven Counter page and full Manager GUI. Active CSW Extension workstream underway. Self-service enabling architecture discussion paper complete (Session 25).
**Purpose:** Systematic analysis of all deferred and outstanding work, organised to support prioritisation decisions. Assessed against stated priorities: robust formalised constructs, correct SysML usage, best-practice approaches, reusable modular architecture.
**Changes from previous version:** CSW Extension Phase 6 complete — Manager GUI for stock and catalogue management. Catalogue constraint (cannot discontinue with active orders) now unblocked. Context updated. Workstream 9 (Self-Service Enabling Architecture) added in earlier Session 25 update.

---

## Assessment Framework

Each work item is assessed against four criteria aligned with stated priorities:

| Criterion | What it means |
|---|---|
| **Formalisation** | Replaces informal (string-typed, doc-block-described, convention-dependent) constructs with structurally enforced, tool-validated ones |
| **SysML Correctness** | Exercises SysML v2 constructs as intended by the specification; resolves known Syside limitations or workarounds |
| **Best Practice** | Follows established patterns (separation of concerns, single source of truth, metadata-driven generation, two-layer architecture) |
| **Reusability / Modularity** | Produces patterns, part defs, generators, or architectural structures that generalise across domains and pathways |

Items are grouped into nine workstreams (seven original + two new), each containing related items. Within each workstream, items are ordered by alignment with priorities (highest first). Estimated effort is expressed in stages (one stage ≈ 30–60 minutes of session time).

---

## ACTIVE: CSW Extension Workstream

*This workstream is currently in progress. Full plan: `gsl-workstream-csw-extension-2026-03-12.md`. Specification: `catalogue-inventory-spec-v2.md`.*

**Status:** Phases 1–6 complete. Phases 7–10 planned.

**Summary:** Extending the coffee shop demonstrator with catalogue management, inventory tracking, PostgreSQL business database, and a frontend reboot (Tailwind v4 + Flowbite Svelte). Exercises new architectural patterns and surfaces meta model gaps. Creates landing zones for Knowledge Layer Increments 1–3.

**Integration with other workstreams:** Touches 4.5 (KL increments — creates UI surface area), 4.3 (manifest enrichment — new concepts), 1.4 (domain-agnostic naming — tests generality), 5.x (business model — tests completeness), 8.x (meta model concepts), **9.1–9.2 (agency classification and authority model versioning — natural addition to Phase 10 Foundation metadata work)**.

This workstream takes priority over other items during active sessions. Items from other workstreams should not be pulled into CSW Extension sessions unless they directly enable the current phase.

---

## Workstream 1: Model Structural Formalisation

*Replaces informal string-typed cross-references with typed `ref` relationships, establishing machine-traceable links across the model. This is the most directly aligned workstream with the stated priority of robust, formalised constructs.*

### 1.1 Formalise `ref` from ServiceOffering to ClinicalPathways

**Current state:** `ServiceOffering.clinicalPathwayRef` is a `String` attribute. The business model references clinical pathways by name only — no structural traceability, no tool validation, no generator access.

**Work:** Replace with `ref clinicalPathway : HormoneTherapyInitiation[0..*]` (or a generalised pathway type). Requires a cross-domain import from `BusinessModel::ServiceConcept` to `ServiceDelivery::ClinicalPathways`. Syntax pattern (`ref` to `action def` across packages) needs verification in Syside.

**Priority alignment:** Formalisation ★★★ | SysML Correctness ★★ | Best Practice ★★★ | Reusability ★★★
**Effort:** 1–2 stages
**Dependencies:** None

---

### 1.2 Formalise `ref` from ScenarioComparison to ScenarioDefinition

**Current state:** `ScenarioComparison.scenarioRefs` is a `String`. Comparison references scenarios by name.

**Work:** Replace with `ref scenarios : ScenarioDefinition[2..*]`.

**Priority alignment:** Formalisation ★★★ | SysML Correctness ★★ | Best Practice ★★ | Reusability ★★
**Effort:** 1 stage
**Dependencies:** None

---

### 1.3 Investigate `ref` to `requirement def` as a type

**Current state:** `ResourceConstraint.regulatorySourceDescription` is a `String`.

**Work:** Syntax investigation. Document findings.

**Priority alignment:** Formalisation ★★★ | SysML Correctness ★★★ | Best Practice ★★ | Reusability ★★
**Effort:** 1 stage
**Dependencies:** None

---

### 1.4 Domain-agnostic naming in projection types

**Current state:** `ProjectionOutput.activePatientsTotal` uses healthcare-specific names.

**Work:** Rename to generic terms. Update all usages.

**CSW Extension note:** The CSW Extension workstream directly exercises domain-agnostic naming. New concepts (CatalogueEntry, InventoryRecord, PersistencePolicy) are all domain-neutral by design.

**Priority alignment:** Formalisation ★ | SysML Correctness ★ | Best Practice ★★ | Reusability ★★★
**Effort:** 1 stage
**Dependencies:** None

---

## Workstream 2: SysML v2 Language Depth

*Investigates and validates SysML v2 constructs that are currently unused or unverified in the model.*

### 2.1 Port definitions and connections

**Work:** Define `port def` elements for key Platform interfaces. Connect subsystems.

**Priority alignment:** Formalisation ★★★ | SysML Correctness ★★★ | Best Practice ★★★ | Reusability ★★★
**Effort:** 2–3 stages
**Dependencies:** None

---

### 2.2 Use case def elaboration (include, extend, subject, actor)

**Work:** Verify syntax. Elaborate representative subset. Model actors.

**Priority alignment:** Formalisation ★★★ | SysML Correctness ★★★ | Best Practice ★★★ | Reusability ★★
**Effort:** 2–3 stages
**Dependencies:** None

---

### 2.3 Metadata def specialisation and advanced patterns

**Work:** Investigate specialisation, enum-valued attributes, metadata on state defs.

**Self-service note:** Items 9.1–9.2 (AgencyClassification, AuthorityModelVersion) are new metadata definitions. If 2.3 is done before 9.1, the findings directly inform the metadata pattern used. If 9.1 is done first (in CSW Phase 10), it becomes a test case for 2.3.

**Priority alignment:** Formalisation ★★ | SysML Correctness ★★★ | Best Practice ★★★ | Reusability ★★★
**Effort:** 2 stages
**Dependencies:** None

---

### 2.4 Nested `:>>` redefinition inside contained parts

**Work:** Test pattern in syntax test file.

**Priority alignment:** Formalisation ★★★ | SysML Correctness ★★★ | Best Practice ★★ | Reusability ★★
**Effort:** 1 stage
**Dependencies:** None

---

## Workstream 3: Architecture Generalisation (Second Pathway)

### 3.1 Model a second clinical pathway

**Work:** Full two-layer pathway (likely Ongoing Monitoring). Domain flow, orchestration flow, constraints, evaluation specs, demonstrator parity.

**Self-service note:** Item 9.3 (NotificationTrigger metadata) should be included as a first-class modelling concern when the second pathway is built. This is not an add-on — it's part of the pathway definition, annotating state transitions with patient-facing notification rules. Agency classification (9.1) should also be applied to the new pathway's action nodes.

**Priority alignment:** Formalisation ★★★ | SysML Correctness ★★ | Best Practice ★★★ | Reusability ★★★
**Effort:** 4–6 stages (plus ~1 stage for notification triggers and agency classification)
**Dependencies:** Benefits from 1.1 and 1.3. Benefits from 9.1 (agency classification metadata available).

---

## Workstream 4: Generation Pipeline Maturation

### 4.1 Temporal workflow generator extension — evaluation engine calls

**Work:** Extend generator to emit evaluation calls from `@LogicRule` / `@SafetyConstraint` metadata.

**Priority alignment:** Formalisation ★★★ | SysML Correctness ★★ | Best Practice ★★★ | Reusability ★★★
**Effort:** 2–3 stages
**Dependencies:** 4.5 Increment 1 is the proving ground

---

### 4.2 Projection generator — SysML formulas to engine code

**Work:** Generator reads `ProjectionFormula` usages, produces engine code.

**Priority alignment:** Formalisation ★★★ | SysML Correctness ★★ | Best Practice ★★★ | Reusability ★★★
**Effort:** 3–4 stages
**Dependencies:** 5.1 (parameter validation)

---

### 4.3 System manifest generator enrichment

**Work:** Extend manifest with typed cross-references, ports, actors, business model elements.

**CSW Extension note:** Once CatalogueEntry, InventoryRecord, and PersistencePolicy are in the SysML model (CSW Extension Phase 10), the manifest generator should reflect them. This becomes a natural follow-on to the meta model update.

**Priority alignment:** Formalisation ★★ | SysML Correctness ★ | Best Practice ★★★ | Reusability ★★★
**Effort:** 2–3 stages
**Dependencies:** Benefits from 1.1, 1.2, 2.1, 2.2, and CSW Extension Phase 10

---

### 4.4 Migrate generators from regex to Syside Automator

**Work:** Migrate constraint evaluator, decision table evaluator, manifest generators to Automator API.

**Priority alignment:** Formalisation ★★ | SysML Correctness ★★ | Best Practice ★★★ | Reusability ★★★
**Effort:** 3–5 stages
**Dependencies:** Syside Automator stability (currently 0.8.5)

---

### 4.5 Coffee Shop Knowledge Layer Increments (1–4)

**Work:**
- Increment 1: Constraint evaluation at a pathway step
- Increment 2: Decision table for drink routing
- Increment 3: System self-assessment dashboard
- **Increment 4: OptionEvaluator — "Help Me Choose" feature (new — Session 25)**

**CSW Extension note:** The CSW Extension workstream creates the UI landing zones for Increments 1–3. Increment 3's dashboard maps to the System Status page (CSW Extension Phase 9). Increment 2 gains a natural use case with the catalogue's prepared/bought-in distinction. Increment 1 could include a catalogue constraint (cannot discontinue item with active orders).

**Self-service note:** Increment 4 (OptionEvaluator) is the coffee shop demonstrator for the Informed Choice Engine. It reads from the catalogue, filters by dietary constraints and availability, projects consequences (caffeine content, price, preparation time), and records the interaction. This validates the Generation 3 architecture before clinical deployment. Depends on Increments 1–3 being complete, as the OptionEvaluator consumes the ConstraintEvaluator.

**Priority alignment:** Formalisation ★★ | SysML Correctness ★ | Best Practice ★★★ | Reusability ★★★
**Effort:** 2–3 stages (Increments 1–3) + 2–3 stages (Increment 4)
**Dependencies:** CSW Extension Phases 5, 6, 9 create the landing zones for Increments 1–3. Increment 4 depends on Increments 1–3 and item 9.4 (OptionEvaluator in SysML model).

---

### 4.6 TypeScript type generator update (Session 20)

**Work:** Update `gen_typescript_types.py` to handle the revised domain model: MenuItem without price, new CatalogueEntry/InventoryRecord/ExternalReference types, new enums (AvailabilityStatus, ProvisionType, StockStatus). Potentially also generate a PostgreSQL DDL generator or at minimum document the model-to-table mapping conventions.

**Priority alignment:** Formalisation ★★ | SysML Correctness ★ | Best Practice ★★★ | Reusability ★★★
**Effort:** 1–2 stages
**Dependencies:** CSW Extension Phase 1 (SysML model update)

---

## Workstream 5: Business Model and Projection Refinement

### 5.1 Clinical pricing parameter validation

**Work:** Ella validates pricing against actual clinical intentions.

**Priority alignment:** Formalisation ★ | SysML Correctness ★ | Best Practice ★★ | Reusability ★
**Effort:** 1–2 stages
**Dependencies:** Ella's domain knowledge

---

### 5.2 Variant C elaboration — Consultancy + Platform Licence

**Work:** Model the Variant C scenario.

**Priority alignment:** Formalisation ★★ | SysML Correctness ★ | Best Practice ★★ | Reusability ★★
**Effort:** 2–3 stages
**Dependencies:** Benefits from 5.1

---

### 5.3 Projection engine — clinician utilisation model extension

**Work:** Extend utilisation calculation to include non-clinical time.

**Priority alignment:** Formalisation ★ | SysML Correctness ★ | Best Practice ★★ | Reusability ★★
**Effort:** 1–2 stages
**Dependencies:** 5.1

---

## Workstream 6: Model Consolidation and Quality

### 6.1 Naming consistency review

**Work:** Systematic review of all names. Document convention.

**Priority alignment:** Formalisation ★★ | SysML Correctness ★ | Best Practice ★★★ | Reusability ★★
**Effort:** 2–3 stages

---

### 6.2 Doc block completeness audit

**Work:** Systematic pass through every package and part def.

**Priority alignment:** Formalisation ★★ | SysML Correctness ★ | Best Practice ★★★ | Reusability ★★
**Effort:** 2–4 stages

---

### 6.3 Package hierarchy and structural simplification review

**Work:** Review for merges, splits, promotions.

**Priority alignment:** Formalisation ★ | SysML Correctness ★ | Best Practice ★★★ | Reusability ★★
**Effort:** 1–2 stages

---

### 6.4 README and repo conventions update

**Work:** Update README and conventions guide.

**Priority alignment:** Formalisation ★ | SysML Correctness ★ | Best Practice ★★ | Reusability ★★
**Effort:** 1 stage

---

## Workstream 7: Runtime and Integration (Deferred — Not Current Priority)

*Items that are architecturally designed but depend on implementation decisions, external system maturity, or clinical data readiness. Included for completeness; these are correctly deferred.*

### 7.1 CDR / openEHR clinical implementation
Clinical archetype design, SNOMED CT binding, FHIR bridge, production CDR hosting. **Why correctly deferred:** Depends on clinical content decisions downstream of pathway modelling.

### 7.2 Prolog / Tier 2 implementation
Tau Prolog integration, rule generator. **Why correctly deferred:** Tier 1 sufficient until compound inference demand.

### 7.3 ML/LLM / Tier 3 integration
Advisory intelligence, predictive analytics. **Why correctly deferred:** Interface-only until data volume and regulatory clarity.

**Self-service note:** The Informed Choice Engine (ICE) is the first concrete use case for Tier 3. The LLM operates in a constrained "explains vs decides" role, grounded in Knowledge Layer outputs. Item 9.4 (OptionEvaluator) is the prerequisite. The ICE itself is a Generation 3 capability — deferred until the OptionEvaluator is validated and regulatory classification is understood.

### 7.4 External clinical knowledge sources
NICE guidelines, BNF, drug interaction databases. **Why correctly deferred:** Depends on pathway breadth and clinical content decisions.

---

## Workstream 8: Meta Model Extension (Session 20)

*New concepts surfaced by the CSW Extension exercise that need formal representation in the BusinessModel or Platform packages. These will be implemented in CSW Extension Phase 10 but are listed here for completeness.*

### 8.1 CatalogueEntry and ExternalReference in BusinessModel

**Current state:** `ServiceOffering` is at package level only. No concept for individual orderable items within a service offering. No mechanism for referencing external knowledge sources.

**Work:** Add `CatalogueEntry` part def (item reference, price, availability, provision type) and `ExternalReference` part def (reference type, ID, source, notes) to `BusinessModel::ServiceConcept` or a new `Catalogue` sub-package.

**Priority alignment:** Formalisation ★★★ | SysML Correctness ★★ | Best Practice ★★★ | Reusability ★★★
**Effort:** 1–2 stages (part of CSW Extension Phase 10)
**Dependencies:** CSW Extension Phases 1–6 validate the concepts before meta model formalisation

---

### 8.2 InventoryRecord in ResourcePlanning

**Current state:** `ResourceType` covers planning-level resources. No concept for operational stock tracking.

**Work:** Add `InventoryRecord` part def to `BusinessModel::ResourcePlanning` or a new `InventoryManagement` sub-package.

**Priority alignment:** Formalisation ★★★ | SysML Correctness ★ | Best Practice ★★★ | Reusability ★★★
**Effort:** 1 stage (part of CSW Extension Phase 10)
**Dependencies:** CSW Extension Phases 1–6

---

### 8.3 PersistencePolicy in Foundation or Platform

**Current state:** No mechanism for the model to express where domain concepts are persisted and why.

**Work:** Add `PersistencePolicy` part def, `PersistenceLayer` enum, and `DataCharacteristic` enum. Instantiate policies for each CSW domain concept. This makes architectural reasoning about data placement explicit, queryable, and auditable.

**Priority alignment:** Formalisation ★★★ | SysML Correctness ★★ | Best Practice ★★★ | Reusability ★★★
**Effort:** 1–2 stages (part of CSW Extension Phase 10)
**Dependencies:** CSW Extension validates the pattern before formalisation

---

## Workstream 9: Self-Service Enabling Architecture (New — Session 25)

*Concepts and metadata definitions required to support the self-service generational roadmap described in `gsl-discussion-self-service-enabling-architecture-2026-03-14.md`. These items establish enabling patterns that the platform needs at every generation of self-service. They are low-cost investments that are harder to retrofit than to build in from the start.*

*Reference: The Apperta CoPHR Blueprint (2018) provides foundational governance principles — provenance, audit, irrevocable access to relied-upon data, medico-legal validity — that should inform the governance aspects of these items.*

### 9.1 AgencyClassification metadata definition in Foundation

**Current state:** Action nodes in pathways have no explicit annotation of who performs them (patient, clinician, system, collaborative). This is implicit from context or unspecified.

**Work:** Add `AgencyClassification` metadata definition to Foundation MetadataLibrary. Define `AgencyType` enum (Patient, Clinician, System, Collaborative). Include `AuthorityModelVersion` attribute to record which generation's authority rules were in effect (initially "G1-clinician-authority"). Annotate the existing hormone therapy initiation pathway action nodes with agency classifications — even though all are currently clinician-action or system-action. Apply to the coffee shop fulfilment pathway as a demonstrator validation.

**Why now:** Agency classification is a prerequisite for all four generations of self-service. The metadata pattern is identical to existing `@TemporalActivity` / `@TemporalSignal` metadata — no new SysML language features required. Adding it now, when all nodes are clinician/system, establishes the pattern cleanly. Retrofitting onto a mature model with patient-action nodes already implemented is significantly harder.

**Priority alignment:** Formalisation ★★★ | SysML Correctness ★★ | Best Practice ★★★ | Reusability ★★★
**Effort:** 1 stage (metadata def + enum + initial annotations)
**Dependencies:** None. Natural fit with CSW Extension Phase 10 (which already adds Foundation metadata).
**Timing:** CSW Extension Phase 10, or next model-touching session.

---

### 9.2 Authority Model Versioning

**Current state:** No mechanism for the model or the governance record to express which authority distribution was in effect at each decision point.

**Work:** Included in 9.1 — the `AuthorityModelVersion` attribute on `AgencyClassification`. Define the initial version ("G1-clinician-authority") and document the versioning convention for future generations.

**Why now:** The governance record needs to know which authority model was in effect at each point. Retrofitting is possible but loses historical traceability from the start.

**Priority alignment:** Formalisation ★★★ | SysML Correctness ★ | Best Practice ★★★ | Reusability ★★★
**Effort:** Included in 9.1.
**Dependencies:** None.
**Timing:** With 9.1.

---

### 9.3 NotificationTrigger metadata on pathway state transitions

**Current state:** Notifications are not modelled. If the coffee shop or clinical system sends notifications, they are hand-coded and not traceable to the model.

**Work:** Add `NotificationTrigger` metadata definition to Foundation MetadataLibrary. Define `NotificationType` enum (Progress, ActionRequired, Waiting, Reminder, Escalation, Milestone). Annotate state transitions on at least one pathway with notification triggers. Include channel preference, recipient role, delay, and template reference attributes.

**Why now (or rather, when):** Notifications are a Generation 1 requirement — the simplest form of patient self-service is proactive information. They should be modelled as part of the pathway, not added as application-level afterthoughts. The natural moment is when the second clinical pathway is modelled (Workstream 3), so that the pattern is established from the first pathway that's built with self-service in mind.

**Priority alignment:** Formalisation ★★★ | SysML Correctness ★★ | Best Practice ★★★ | Reusability ★★★
**Effort:** 1 stage (metadata def + initial annotations on one pathway)
**Dependencies:** Benefits from 9.1 (AgencyClassification provides the recipient role enum).
**Timing:** Integrated into Workstream 3 (Architecture Generalisation — second clinical pathway).

---

### 9.4 OptionEvaluator as Knowledge Layer Increment 4

**Current state:** The self-knowledge architecture has ConstraintEvaluator (answers "is this valid?"), GoalProjector (answers "where is this heading?"), GapAnalyser (answers "what's missing?"). No component answers "what are the available choices and their consequences?"

**Work:** Add `OptionEvaluator` part definition to the Knowledge Layer LogicEngine package. Define its interface: takes a decision point + patient/customer state, enumerates candidates from the domain model's option set, evaluates each against the ConstraintEvaluator, projects consequences via the GoalProjector, and returns a structured result with eligibility, projections, and explanatory metadata. Build the coffee shop "Help Me Choose" feature as the demonstrator — OptionEvaluator reads from the catalogue, filters by dietary constraints and availability, and presents options with consequence data (caffeine, allergens, price, preparation time).

**Why this sequence:** The OptionEvaluator consumes the ConstraintEvaluator and GoalProjector. KL Increments 1–3 must be operational first. The coffee shop demonstrator validates the architecture before clinical deployment. The OptionEvaluator is the enabling component for Generation 3 (Informed Choice with Shared Authority) — the generation where the Informed Choice Engine becomes patient-facing.

**Priority alignment:** Formalisation ★★ | SysML Correctness ★ | Best Practice ★★★ | Reusability ★★★
**Effort:** 2–3 stages (SysML modelling + coffee shop demonstrator implementation)
**Dependencies:** KL Increments 1–3 (4.5). Benefits from 9.1 (agency classification on decision points).
**Timing:** After KL Increments 1–3 complete (Phase B in the suggested sequencing).

---

### 9.5 CoPHR Governance Principles as Reference Requirements

**Current state:** The GSL governance architecture is implicit — provenance is supported by openEHR's native audit, but there is no explicit set of governance principles documented for the platform.

**Work:** Document the Apperta CoPHR Blueprint's nine principles as reference requirements in a GSL governance architecture document. Assess each principle for applicability to GenderSense (not all are immediately relevant — e.g. multi-repository ecosystem, discovery service). Formally adopt the principles on provenance, audit, irrevocable access to relied-upon data, medico-legal validity, and data portability. Annotate the SysML model's governance-related constructs (audit metadata, access control patterns) with references to the adopted principles.

**Why now:** The CoPHR principles encode well-tested thinking about the tension between patient control and clinical governance. Adopting them explicitly gives the GSL governance architecture a principled foundation rather than an emergent one. This is documentation and annotation work, not implementation.

**Priority alignment:** Formalisation ★★ | SysML Correctness ★ | Best Practice ★★★ | Reusability ★★★
**Effort:** 1 stage (documentation + model annotation)
**Dependencies:** None.
**Timing:** Can be done at any point. Natural fit with a governance-focused session or as preparation for clinical pathway work.

---

### 9.6 Patient-Facing Data Release Model in Persistence Architecture

**Current state:** The three-persistence-layer architecture (CDR, business database, process engine) serves clinician-facing and operator-facing views. No concept of controlled data release — what the patient sees immediately vs after clinician review vs only in consultation.

**Work:** Design a data release model as a configuration per data type: immediate release (appointment confirmations, pathway status), clinician-gated release (lab results, clinical assessments), and consultation-only release (clinical notes, exception handling records). This is a design task, not an implementation — the implementation comes when the patient portal is built. The design should specify the release categories, the default classification for each data type, and the mechanism for clinician sign-off on gated data.

**Why now (or rather, when):** The "Epic problem" — patients seeing raw results before their doctor — is a known source of clinical and governance complexity. Designing for controlled data release from the start avoids retrofitting when the patient portal is built. The natural moment is when patient portal design work begins, but the conceptual model can be documented earlier.

**Priority alignment:** Formalisation ★★ | SysML Correctness ★ | Best Practice ★★★ | Reusability ★★★
**Effort:** 1 stage (design document) + implementation effort when patient portal is built
**Dependencies:** None for the design. Implementation depends on patient portal work.
**Timing:** Before patient portal design begins. Can be documented alongside 9.5 in a governance-focused session.

---

## Summary: Priority Matrix

| # | Item | F | S | BP | R | Effort | Status / Recommendation |
|---|---|:---:|:---:|:---:|:---:|---|---|
| **CSW** | CSW Extension workstream | ★★★ | ★★ | ★★★ | ★★★ | 17–25 | **ACTIVE — Phase 5 complete** |
| **9.1** | **AgencyClassification metadata** | **★★★** | **★★** | **★★★** | **★★★** | **1** | **High — build in now, CSW Phase 10** |
| **9.2** | **Authority model versioning** | **★★★** | **★** | **★★★** | **★★★** | **incl.** | **High — included in 9.1** |
| **2.1** | Port definitions and connections | ★★★ | ★★★ | ★★★ | ★★★ | 2–3 | **High — new structural dimension** |
| **2.2** | Use case elaboration (include, actor) | ★★★ | ★★★ | ★★★ | ★★ | 2–3 | **High — 100+ use cases to formalise** |
| **1.1** | ServiceOffering → ClinicalPathways ref | ★★★ | ★★ | ★★★ | ★★★ | 1–2 | **High — core cross-domain link** |
| **3.1** | Second clinical pathway (+9.3) | ★★★ | ★★ | ★★★ | ★★★ | 5–7 | **High — architecture generalisation** |
| **4.5** | Coffee Shop Knowledge Layer (1–4) | ★★ | ★ | ★★★ | ★★★ | 4–6 | **High — lands in CSW Extension + Phase B** |
| **4.1** | Temporal generator — evaluation calls | ★★★ | ★★ | ★★★ | ★★★ | 2–3 | **High — closes generation chain** |
| **9.4** | **OptionEvaluator (KL Increment 4)** | **★★** | **★** | **★★★** | **★★★** | **2–3** | **High — after KL Increments 1–3** |
| **8.1** | CatalogueEntry + ExternalReference | ★★★ | ★★ | ★★★ | ★★★ | 1–2 | **In CSW Extension Phase 10** |
| **8.2** | InventoryRecord | ★★★ | ★ | ★★★ | ★★★ | 1 | **In CSW Extension Phase 10** |
| **8.3** | PersistencePolicy | ★★★ | ★★ | ★★★ | ★★★ | 1–2 | **In CSW Extension Phase 10** |
| **9.5** | **CoPHR governance principles** | **★★** | **★** | **★★★** | **★★★** | **1** | **Medium-high — documentation** |
| **4.6** | TypeScript type generator update | ★★ | ★ | ★★★ | ★★★ | 1–2 | **After CSW Extension Phase 1** |
| **2.3** | Metadata def specialisation | ★★ | ★★★ | ★★★ | ★★★ | 2 | **Medium-high** |
| **2.4** | Nested `:>>` redefinition | ★★★ | ★★★ | ★★ | ★★ | 1 | **Medium-high — quick answer** |
| **1.2** | ScenarioComparison → ScenarioDef ref | ★★★ | ★★ | ★★ | ★★ | 1 | **Medium** |
| **1.3** | Ref to requirement def investigation | ★★★ | ★★★ | ★★ | ★★ | 1 | **Medium** |
| **9.6** | **Data release model design** | **★★** | **★** | **★★★** | **★★★** | **1** | **Medium — before patient portal** |
| **6.1** | Naming consistency review | ★★ | ★ | ★★★ | ★★ | 2–3 | **Medium** |
| **6.2** | Doc block completeness | ★★ | ★ | ★★★ | ★★ | 2–4 | **Medium** |
| **4.3** | Manifest generator enrichment | ★★ | ★ | ★★★ | ★★★ | 2–3 | **After CSW Extension Phase 10** |
| **1.4** | Domain-agnostic naming | ★ | ★ | ★★ | ★★★ | 1 | **Medium — CSW exercises this** |
| **6.3** | Package hierarchy review | ★ | ★ | ★★★ | ★★ | 1–2 | **Medium** |
| **6.4** | README / conventions update | ★ | ★ | ★★ | ★★ | 1 | **Low-medium** |
| **4.4** | Generator migration to Automator | ★★ | ★★ | ★★★ | ★★★ | 3–5 | **Low-medium — Syside gate** |
| **4.2** | Projection generator | ★★★ | ★★ | ★★★ | ★★★ | 3–4 | **Low-medium — parameter gate** |
| **9.3** | **NotificationTrigger metadata** | **★★★** | **★★** | **★★★** | **★★★** | **1** | **Integrated into 3.1 timing** |
| **5.1** | Clinical pricing validation | ★ | ★ | ★★ | ★ | 1–2 | **When ready — Ella's input** |
| **5.2** | Variant C elaboration | ★★ | ★ | ★★ | ★★ | 2–3 | **Low** |
| **5.3** | Utilisation model extension | ★ | ★ | ★★ | ★★ | 1–2 | **Low** |

---

## Suggested Sequencing (Updated)

### Currently Active: CSW Extension (4–6 sessions)

Complete the CSW Extension workstream (Phases 6–10). Phase 10 (Meta Model Update) now includes items 8.1–8.3 (original meta model concepts) **and items 9.1–9.2 (AgencyClassification + AuthorityModelVersion metadata)**. These are natural companions — all add metadata or part definitions to Foundation or BusinessModel packages.

### Phase A: Structural Deepening (5–8 stages, 2–3 sessions)

After CSW Extension reaches Phase 7+ (operations pages built, main frontend work done).

1. Quick syntax investigations: nested `:>>` (2.4), `ref` to `requirement def` (1.3) — 2 stages
2. Port definitions and initial connections (2.1) — 2–3 stages
3. Use case elaboration: `include`, `actor` (2.2) — 2–3 stages
4. Formalise cross-references: ServiceOffering ref (1.1), ScenarioComparison ref (1.2) — 2 stages

**Governance documentation (flexible timing):** Items 9.5 (CoPHR governance principles) and 9.6 (data release model design) can be done during Phase A as documentation tasks, or held for a governance-focused session. They don't require SysML model changes and can be done in parallel with structural work.

### Phase B: Runtime Validation (6–9 stages, 2–3 sessions)

Can be interleaved with later CSW Extension phases as landing zones become available.

1. Coffee Shop Knowledge Layer Increments 1–3 (4.5) — 2–3 stages
2. Temporal generator extension for evaluation calls (4.1) — 2–3 stages
3. **Coffee Shop Knowledge Layer Increment 4: OptionEvaluator / "Help Me Choose" (9.4 + 4.5) — 2–3 stages**

### Phase C: Architecture Generalisation (7–12 stages, 3–4 sessions)

The most significant test remaining. After Structural Deepening.

1. Model consolidation review (6.1, 6.2, 6.3) — 3–5 stages
2. Second clinical pathway (3.1) **with notification triggers (9.3) and agency classification (9.1) applied** — 5–7 stages
3. Post-pathway: manifest enrichment (4.3), README update (6.4) — 2 stages

---

*Analysis updated 14 March 2026. Changes: Workstream 9 (Self-Service Enabling Architecture) added with six items (9.1–9.6) from Session 25 discussion paper. Items 9.1–9.2 integrated into CSW Extension Phase 10. Item 9.3 integrated into Workstream 3 (second pathway). Item 9.4 added as KL Increment 4 in Phase B. Items 9.5–9.6 positioned as flexible governance documentation. Item 4.5 expanded to include Increment 4. Cross-references added to 2.3, 3.1, 7.3. Priority matrix and suggested sequencing updated. Context updated to Session 25.*
