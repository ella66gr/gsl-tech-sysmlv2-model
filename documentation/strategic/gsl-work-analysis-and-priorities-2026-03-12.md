# GSL — Systematic Work Analysis and Priorities

**Date:** 12 March 2026 (updated from 11 March 2026)
**Context:** Post Business Meta Model (Phases 1–7), post Knowledge Layer Elaboration (Phases 1–5), post CSW Extension Phase 0 (Session 20). 72-package model, 364KB SysML, 24 session reports, working generation pipeline, running coffee shop demonstrator. Active CSW Extension workstream underway.
**Purpose:** Systematic analysis of all deferred and outstanding work, organised to support prioritisation decisions. Assessed against stated priorities: robust formalised constructs, correct SysML usage, best-practice approaches, reusable modular architecture.
**Changes from previous version:** CSW Extension workstream added (active). Items 4.5, 4.3, 1.4, 5.x annotated with CSW Extension integration points. New items 8.1–8.3 added for meta model concepts surfaced in Session 20.

---

## Assessment Framework

Each work item is assessed against four criteria aligned with stated priorities:

| Criterion | What it means |
|---|---|
| **Formalisation** | Replaces informal (string-typed, doc-block-described, convention-dependent) constructs with structurally enforced, tool-validated ones |
| **SysML Correctness** | Exercises SysML v2 constructs as intended by the specification; resolves known Syside limitations or workarounds |
| **Best Practice** | Follows established patterns (separation of concerns, single source of truth, metadata-driven generation, two-layer architecture) |
| **Reusability / Modularity** | Produces patterns, part defs, generators, or architectural structures that generalise across domains and pathways |

Items are grouped into eight workstreams (seven original + one new), each containing related items. Within each workstream, items are ordered by alignment with priorities (highest first). Estimated effort is expressed in stages (one stage ≈ 30–60 minutes of session time).

---

## ACTIVE: CSW Extension Workstream

*This workstream is currently in progress. Full plan: `gsl-workstream-csw-extension-2026-03-12.md`. Specification: `catalogue-inventory-spec-v2.md`.*

**Status:** Phase 0 (Conceptual Modelling) complete. Phases 1–10 planned.

**Summary:** Extending the coffee shop demonstrator with catalogue management, inventory tracking, PostgreSQL business database, and a frontend reboot (Tailwind v4 + Flowbite Svelte). Exercises new architectural patterns and surfaces meta model gaps. Creates landing zones for Knowledge Layer Increments 1–3.

**Integration with other workstreams:** Touches 4.5 (KL increments — creates UI surface area), 4.3 (manifest enrichment — new concepts), 1.4 (domain-agnostic naming — tests generality), 5.x (business model — tests completeness), 8.x (new meta model concepts below).

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

**Priority alignment:** Formalisation ★★★ | SysML Correctness ★★ | Best Practice ★★★ | Reusability ★★★
**Effort:** 4–6 stages
**Dependencies:** Benefits from 1.1 and 1.3

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

### 4.5 Coffee Shop Knowledge Layer Increments (1–3)

**Work:**
- Increment 1: Constraint evaluation at a pathway step
- Increment 2: Decision table for drink routing
- Increment 3: System self-assessment dashboard

**CSW Extension note:** The CSW Extension workstream creates the UI landing zones for all three increments. Increment 3's dashboard maps to the System Status page (CSW Extension Phase 9). Increment 2 gains a natural use case with the catalogue's prepared/bought-in distinction. Increment 1 could include a catalogue constraint (cannot discontinue item with active orders). These increments should be woven into the CSW Extension frontend phases as the relevant pages are built.

**Priority alignment:** Formalisation ★★ | SysML Correctness ★ | Best Practice ★★★ | Reusability ★★★
**Effort:** 2–3 stages total
**Dependencies:** CSW Extension Phases 5, 6, 9 create the landing zones

---

### 4.6 TypeScript type generator update (new — Session 20)

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

### 7.4 External clinical knowledge sources
NICE guidelines, BNF, drug interaction databases. **Why correctly deferred:** Depends on pathway breadth and clinical content decisions.

---

## Workstream 8: Meta Model Extension (New — Session 20)

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

## Summary: Priority Matrix

| # | Item | F | S | BP | R | Effort | Status / Recommendation |
|---|---|:---:|:---:|:---:|:---:|---|---|
| **CSW** | CSW Extension workstream | ★★★ | ★★ | ★★★ | ★★★ | 17–25 | **ACTIVE — Phase 0 complete** |
| **2.1** | Port definitions and connections | ★★★ | ★★★ | ★★★ | ★★★ | 2–3 | **High — new structural dimension** |
| **2.2** | Use case elaboration (include, actor) | ★★★ | ★★★ | ★★★ | ★★ | 2–3 | **High — 100+ use cases to formalise** |
| **1.1** | ServiceOffering → ClinicalPathways ref | ★★★ | ★★ | ★★★ | ★★★ | 1–2 | **High — core cross-domain link** |
| **3.1** | Second clinical pathway | ★★★ | ★★ | ★★★ | ★★★ | 4–6 | **High — architecture generalisation** |
| **4.5** | Coffee Shop Knowledge Layer (1–3) | ★★ | ★ | ★★★ | ★★★ | 2–3 | **High — lands in CSW Extension** |
| **4.1** | Temporal generator — evaluation calls | ★★★ | ★★ | ★★★ | ★★★ | 2–3 | **High — closes generation chain** |
| **8.1** | CatalogueEntry + ExternalReference | ★★★ | ★★ | ★★★ | ★★★ | 1–2 | **In CSW Extension Phase 10** |
| **8.2** | InventoryRecord | ★★★ | ★ | ★★★ | ★★★ | 1 | **In CSW Extension Phase 10** |
| **8.3** | PersistencePolicy | ★★★ | ★★ | ★★★ | ★★★ | 1–2 | **In CSW Extension Phase 10** |
| **4.6** | TypeScript type generator update | ★★ | ★ | ★★★ | ★★★ | 1–2 | **After CSW Extension Phase 1** |
| **2.3** | Metadata def specialisation | ★★ | ★★★ | ★★★ | ★★★ | 2 | **Medium-high** |
| **2.4** | Nested `:>>` redefinition | ★★★ | ★★★ | ★★ | ★★ | 1 | **Medium-high — quick answer** |
| **1.2** | ScenarioComparison → ScenarioDef ref | ★★★ | ★★ | ★★ | ★★ | 1 | **Medium** |
| **1.3** | Ref to requirement def investigation | ★★★ | ★★★ | ★★ | ★★ | 1 | **Medium** |
| **6.1** | Naming consistency review | ★★ | ★ | ★★★ | ★★ | 2–3 | **Medium** |
| **6.2** | Doc block completeness | ★★ | ★ | ★★★ | ★★ | 2–4 | **Medium** |
| **4.3** | Manifest generator enrichment | ★★ | ★ | ★★★ | ★★★ | 2–3 | **After CSW Extension Phase 10** |
| **1.4** | Domain-agnostic naming | ★ | ★ | ★★ | ★★★ | 1 | **Medium — CSW exercises this** |
| **6.3** | Package hierarchy review | ★ | ★ | ★★★ | ★★ | 1–2 | **Medium** |
| **6.4** | README / conventions update | ★ | ★ | ★★ | ★★ | 1 | **Low-medium** |
| **4.4** | Generator migration to Automator | ★★ | ★★ | ★★★ | ★★★ | 3–5 | **Low-medium — Syside gate** |
| **4.2** | Projection generator | ★★★ | ★★ | ★★★ | ★★★ | 3–4 | **Low-medium — parameter gate** |
| **5.1** | Clinical pricing validation | ★ | ★ | ★★ | ★ | 1–2 | **When ready — Ella's input** |
| **5.2** | Variant C elaboration | ★★ | ★ | ★★ | ★★ | 2–3 | **Low** |
| **5.3** | Utilisation model extension | ★ | ★ | ★★ | ★★ | 1–2 | **Low** |

---

## Suggested Sequencing (Updated)

### Currently Active: CSW Extension (4–6 sessions)

Complete the CSW Extension workstream (Phases 1–10). This creates infrastructure, exercises meta model concepts, and builds the frontend that receives Knowledge Layer increments.

### Phase A: Structural Deepening (5–8 stages, 2–3 sessions)

After CSW Extension reaches Phase 7+ (operations pages built, main frontend work done).

1. Quick syntax investigations: nested `:>>` (2.4), `ref` to `requirement def` (1.3) — 2 stages
2. Port definitions and initial connections (2.1) — 2–3 stages
3. Use case elaboration: `include`, `actor` (2.2) — 2–3 stages
4. Formalise cross-references: ServiceOffering ref (1.1), ScenarioComparison ref (1.2) — 2 stages

### Phase B: Runtime Validation (4–6 stages, 1–2 sessions)

Can be interleaved with later CSW Extension phases as landing zones become available.

1. Coffee Shop Knowledge Layer Increments 1–3 (4.5) — 2–3 stages
2. Temporal generator extension for evaluation calls (4.1) — 2–3 stages

### Phase C: Architecture Generalisation (6–10 stages, 2–4 sessions)

The most significant test remaining. After Structural Deepening.

1. Model consolidation review (6.1, 6.2, 6.3) — 3–5 stages
2. Second clinical pathway (3.1) — 4–6 stages
3. Post-pathway: manifest enrichment (4.3), README update (6.4) — 2 stages

---

*Analysis updated 12 March 2026. Changes: CSW Extension workstream added as active, items 8.1–8.3 added for meta model concepts from Session 20, item 4.6 added for type generator update, integration notes added to 4.5/4.3/1.4, sequencing updated to reflect active workstream.*
