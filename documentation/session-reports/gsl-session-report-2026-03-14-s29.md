# Session 29 Report — CSW Extension Phase 10: Meta Model Update

**Date:** 14 March 2026
**Session number:** 29
**Workstream:** CSW Extension — Catalogue, Inventory & Frontend (Phase 10 of 10 — final phase)
**Plan:** `gsl-plan-csw-extension-phase10-implementation-2026-03-14.md`

---

## Summary

Executed Phase 10 of the CSW Extension workstream: the Meta Model Update. This is the final phase of the workstream. Phase 10 lifts validated domain concepts from the coffee shop demonstrator into the generic meta models that all domains inherit from. Critically, this session also clarified and formally documented the distinction between the two meta models — the Business Meta Model and the Business System Meta Model — ensuring this foundational architectural principle is embedded in all relevant strategic and architectural documents.

Additionally: a Phase 10 detailed implementation plan was created before execution, an architectural clarification document was produced, and two existing architectural documents received bridging notes.

---

## Work Completed

### Pre-Execution: Conceptual Clarification

**The two meta model distinction.** Before executing Phase 10, a substantive discussion clarified the conceptual architecture of the project's meta modelling approach. The initial draft of the Phase 10 plan framed the work as "incorporating findings into the GSL business meta model SysML" — which conflated two distinct meta models into one.

The corrected framing, derived from the original `gsl-service-business-meta-modelling.md` §1:

- **Business Meta Model** — the structural template for what a service business *is*: service concept, financial model, resources, activities, governance. Lives in the `BusinessModel` package.
- **Business System Meta Model** — the structural template for how a business system *works*: processes, platform, data architecture, knowledge, operations. Currently implicit across Foundation, Platform, ServiceDelivery, Knowledge, and Operations.

Each new concept was explicitly classified into the correct meta model before implementation. This classification is now embedded in doc blocks, comments, the implementation plan, and a new standing architectural clarification document.

### Pre-Execution: Phase 10 Plan

**Phase 10 Detailed Implementation Plan** (`gsl-plan-csw-extension-phase10-implementation-2026-03-14.md`) — 6-stage plan covering Foundation system meta model additions, BusinessModel business meta model additions, coffee shop persistence policy instances, and documentation polish. The plan opens with the two meta model distinction and classifies every new concept.

### Stage 1: Foundation — PersistencePolicy and Supporting Types

**Added to `Foundation::CommonTypes`:**

- `PersistenceLayer` enum def — four literals: `clinicalDataRepository`, `businessDatabase`, `processEngine`, `externalReference`.
- `DataCharacteristic` enum def — eleven literals covering the distinguishing characteristics that determine persistence home.
- `PersistencePolicy` part def — maps a domain concept to its persistence layer with rationale. Attributes: `domainConcept`, `targetLayer`, `rationale`, `characteristics`.

All three carry doc blocks explicitly identifying them as **business system meta model concepts**.

**Syntax finding:** `DataCharacteristic [1..*]` multiplicity on the `characteristics` attribute parsed cleanly in Syside. Multi-valued enum-typed attributes on part defs are verified.

### Stage 2: Foundation — AgencyClassification Metadata

**Added to `Foundation::MetadataLibrary`:**

- `AgencyType` enum def — four literals: `patientAgent`, `clinicianAgent`, `automated`, `collaborative`.
- `AgencyClassification` metadata def — three attributes: `agencyType : AgencyType`, `authorityModelVersion : String`, `agencyNotes : String`.

Both carry doc blocks explicitly identifying them as **business system meta model concepts**.

**Syntax finding: `system` is a KerML reserved word.** The initial implementation used `patient`, `clinician`, `system`, `collaborative` as enum literals. Syside rejected the entire Foundation file silently — no parse error on the literal itself, but the package became unresolvable, causing cascading reference-errors in all consuming files. The fix was to rename: `patientAgent`, `clinicianAgent`, `automated`, `collaborative`. The `patient` and `clinician` literals were also suffixed with `Agent` as a precaution against potential future conflicts.

**Syntax finding: enum-typed attribute on metadata def works.** `agencyType : AgencyType` parsed cleanly on the `AgencyClassification` metadata def. This resolves syntax reference TODO item "metadata def with non-scalar attribute types."

### Stage 3: BusinessModel — CatalogueEntry and ExternalReference

**Added to `BusinessModel::ServiceConcept`:**

- `CatalogueEntry` part def — generic four-layer model: item definition → catalogue entry → inventory record → external reference. Seven String attributes. Doc block identifies it as a **business meta model concept**.
- `ExternalReference` part def — link to external knowledge. Four String attributes. Doc block identifies it as a **business meta model concept**.

**Design note:** The meta model uses String attributes rather than domain-specific typed refs. The meta model defines the *shape*; domain models (coffee shop, GSL clinical) provide typed specialisations with `ref item : MenuItem` or `ref medication : Medication`.

### Stage 4: BusinessModel — InventoryRecord

**Added to `BusinessModel::ResourcePlanning`:**

- `InventoryRecord` part def — operational stock tracking. Six attributes. Doc block distinguishes from `ResourceInstance` (strategic planning) and identifies it as a **business meta model concept**.

**ActivityType consideration:** No new abstract type added. `ActivityType` is already generic — the coffee shop instantiated `catalogueMaintenance` in Session 20, which is the correct level of abstraction.

`BusinessModel` package doc block updated to reflect Phase 10.

### Stage 5: Coffee Shop — PersistencePolicy Instances

**Added to `CoffeeShopBusinessModel`:**

Six persistence policy instances, one per domain concept:

| Instance | Domain concept | Target layer |
|---|---|---|
| `catalogueEntryPolicy` | CatalogueEntry | businessDatabase |
| `inventoryRecordPolicy` | InventoryRecord | businessDatabase |
| `orderRecordPolicy` | OrderRecord | clinicalDataRepository |
| `feedbackRecordPolicy` | FeedbackRecord | clinicalDataRepository |
| `orderWorkflowPolicy` | OrderWorkflow | processEngine |
| `externalKnowledgePolicy` | ExternalKnowledge | externalReference |

**Import pattern:** `private import Foundation::CommonTypes::*;` (wildcard). Specific named imports (`Foundation::CommonTypes::PersistencePolicy`) failed — Syside's cross-project resolution requires wildcard imports for the package, consistent with all other cross-project imports in the model.

**Deferred:** The `characteristics` attribute (multi-valued enum) was omitted from instances. The `rationale` String carries the reasoning in natural language. The multi-valued enum tuple syntax for `:>>` redefinition on instances is a separate syntax investigation.

### Stage 6: Documentation and Architectural Clarification

**New document: `gsl-architecture-clarification-two-meta-models-2026-03-14.md`** — Standing architectural principle document. Restates the two meta model distinction, maps the current SysML model to the two meta models, provides a classification guide for new concepts, and establishes five guard rails against conceptual drift (including the convention that every new part def must carry a doc block identifying its meta model).

**Bridging note added to `gsl-platform-sysml-modelling-strategy.md`** — Notes that the document predates the meta modelling paper and that its package structure implicitly describes the business system meta model.

**Clarification note added to `gsl-spec-catalogue-inventory-v2.1.md` §8** — Explicitly classifies which meta model implications are business meta model concepts and which are system meta model concepts.

---

## Findings

### `system` is a KerML Reserved Word

Using `system` as an enum literal causes a silent parse failure in Syside 0.8.5. The Foundation package becomes unresolvable — no error is shown on the literal itself, but all consumers of Foundation types get cascading reference-errors. This is a significant finding because the failure mode is non-obvious: you don't see an error at the point of the problem, only downstream.

**Resolution:** Use `automated` instead. Also suffixed `patient` and `clinician` with `Agent` as a precaution.

**Syntax reference update required:** Add `system` to the list of known reserved words that cannot be used as identifiers. Note the silent failure mode.

### Enum-Typed Attribute on Metadata Def: Verified

`attribute agencyType : AgencyType;` on `metadata def AgencyClassification` parses correctly. This resolves the syntax reference TODO "metadata def with non-scalar attribute types (e.g. enum-valued metadata attributes)." The enum and the metadata def must be in the same package (both in MetadataLibrary).

### Cross-Project Specific Named Imports: Do Not Work

`private import Foundation::CommonTypes::PersistencePolicy;` (specific named import) fails with "No Membership named 'PersistencePolicy' found." The wildcard form `private import Foundation::CommonTypes::*;` works. This is consistent with all other cross-project imports in the model and should be documented as a Syside limitation.

### Multi-Valued Enum Attribute on Part Def: Verified (Definition)

`attribute characteristics : DataCharacteristic [1..*];` on the `PersistencePolicy` part def parses cleanly. The `:>>` redefinition with tuple syntax on instances is deferred — the definition-level multiplicity works.

---

## Coffee Shop Demonstrator Extension

**Capability demonstrated:** Meta model formalisation — lifting validated domain concepts into generic abstractions with explicit meta model classification, plus architectural self-knowledge through persistence policy instances.

**What was built:** Five new part defs / enum defs in the business meta model (ServiceConcept and ResourcePlanning). Five new elements in the system meta model (Foundation CommonTypes and MetadataLibrary). Six persistence policy instances in the coffee shop business model.

**What was learned:**
- `system` is a KerML reserved word — silent failure mode in Syside
- Enum-typed attributes on metadata defs work in Syside
- Cross-project specific named imports don't work — use wildcards
- Multi-valued enum attribute definitions parse cleanly

**Clinical implementation confidence:** High. The patterns map directly to:
- **CatalogueEntry → Formulary entry:** The business decision to make a medication available, at what terms, for which patient groups.
- **InventoryRecord → Clinical stock:** Operational tracking of medication stock levels, reorder thresholds.
- **PersistencePolicy → Data placement rationale:** Why patient assessments live in the CDR (archetype-validated, versioned) while appointment scheduling lives in the business database (high-frequency CRUD).
- **AgencyClassification → Self-service readiness:** Annotating clinical pathway steps with who performs them, supporting the generational roadmap from clinician-led to patient self-service.

---

## Architecture Notes

### Modified Files

| File | Change | Meta model |
|---|---|---|
| `model/foundation.sysml` | +126 lines: PersistenceLayer, DataCharacteristic, PersistencePolicy (CommonTypes); AgencyType, AgencyClassification (MetadataLibrary) | System |
| `model/business-model.sysml` | +91 lines: CatalogueEntry, ExternalReference (ServiceConcept); InventoryRecord (ResourcePlanning); updated package doc | Business |
| `exercises/.../coffeeshop-business-model.sysml` | +63 lines: Foundation imports; 6 PersistencePolicy instances | CSW instantiation |
| `documentation/.../gsl-platform-sysml-modelling-strategy.md` | Bridging note (two meta model distinction) | — |
| `documentation/.../gsl-spec-catalogue-inventory-v2.1.md` | Clarification note on §8 meta model classification | — |

### New Documents (for download)

| Document | Purpose |
|---|---|
| `gsl-plan-csw-extension-phase10-implementation-2026-03-14.md` | Phase 10 detailed implementation plan |
| `gsl-architecture-clarification-two-meta-models-2026-03-14.md` | Standing architectural principle: the two meta models |

---

## Git Log

| Commit | Description |
|---|---|
| `e856c90` | Foundation: PersistencePolicy, AgencyClassification — system meta model concepts (CSW Phase 10, Stages 1-2) |
| `7cde0dc` | BusinessModel: CatalogueEntry, ExternalReference, InventoryRecord — business meta model (CSW Phase 10, Stages 3-4) |
| `b905e53` | CoffeeShop: PersistencePolicy instances for all domain concepts (CSW Phase 10, Stage 5) |
| `bed81c0` | Documentation: Phase 10 polish — two meta model bridging notes, doc block updates (Session 29) |
| `b38f19b` | Fix: rename AgencyType literals — 'system' is a KerML reserved word (Session 29) |

---

## CSW Extension Workstream — Complete

Phase 10 is the final phase. The CSW Extension workstream is now complete:

| Phase | Focus | Session |
|---|---|---|
| 0: Conceptual modelling | Specification document | Pre-session |
| 1: SysML domain model update | CoffeeShop package | 20 |
| 2: PostgreSQL foundation | Database, client, seed data | 21 |
| 3: Catalogue & inventory API routes | 17 API endpoints | 22 |
| 4: Frontend foundation | Tailwind v4 + Flowbite Svelte | 23 |
| 5: Counter page | Catalogue-driven order form | 24 |
| 6: Manager GUI | Stock & catalogue management | 25 |
| 7: Order Board & Order Timeline | Kanban + event timeline | 26 |
| 8: Data & Insights pages | Records, Audit, Customer Voice | 27 |
| 9: System pages | Process Model, System Status | 28 |
| **10: Meta model update** | **Business + system meta model** | **29** |

**10 phases across 10 sessions (Sessions 20–29).** The workstream extended the coffee shop demonstrator from a single-pathway, single-persistence-layer application to a full business system with catalogue management, inventory tracking, nine frontend pages, 19 API routes, three persistence layers, and meta model abstractions that generalise across domains.

---

## Next Session

The CSW Extension workstream is complete. Candidate next workstreams per the work analysis suggested sequencing:

1. **Knowledge Layer Increments 1–3** — all UI landing zones built (Order Timeline, Counter, System Status)
2. **Pattern Catalogue and Cross-Domain Concept Registry** — navigable knowledge network for the growing model
3. **Model Consolidation Review** — the model has grown substantially across 29 sessions; a review pass is due
4. **Structural Deepening** — port definitions, use case elaboration, cross-reference formalisation
5. **System Meta Model Extraction** — promote implicit system meta model concepts into a named structure

---

## Syntax Reference Update Required

New findings from this session:

- **KerML reserved word `system`:** Cannot be used as an enum literal. Causes silent parse failure — Foundation package becomes unresolvable, cascading reference-errors in consumers. No error shown at the point of the problem.
- **Enum-typed attribute on metadata def:** Verified ✓. `attribute agencyType : AgencyType;` works on a metadata def when enum and metadata def are in the same package.
- **Cross-project specific named imports:** Do not work. `private import Foundation::CommonTypes::PersistencePolicy;` fails. Wildcard `private import Foundation::CommonTypes::*;` works.
- **Multi-valued enum attribute on part def (definition level):** Verified ✓. `attribute characteristics : DataCharacteristic [1..*];` parses cleanly. Instance-level `:>>` redefinition with tuple syntax deferred.

---

*Session 29 report prepared 14 March 2026.*
