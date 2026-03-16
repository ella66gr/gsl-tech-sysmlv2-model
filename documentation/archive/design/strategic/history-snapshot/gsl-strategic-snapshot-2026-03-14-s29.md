# GenderSense SysML Model — Strategic Snapshot

**Date:** 14 March 2026 (Session 29)
**Prepared by:** Claude (from direct review of the complete codebase and session 29 conversation)
**Scope:** The `gsl-sysml-model` project in its entirety — model, generators, demonstrator, documentation, development practice
**Changes from previous version:** CSW Extension Phase 10 (Meta Model Update) complete. CSW Extension workstream complete (10 phases, 10 sessions). Two meta model distinction formally documented. Three syntax findings.

---

## 1. What This Project Is

GenderSense Limited is building a model-driven clinical service management platform for gender-affirming healthcare. The `gsl-sysml-model` project is the representation layer: a SysML v2 model that serves as the single source of truth for what the business is, how its clinical services work, what rules govern them, and how the technology platform supports them.

The project maintains **two distinct meta models** (per `gsl-service-business-meta-modelling.md` §1, reinforced in `gsl-architecture-clarification-two-meta-models-2026-03-14.md`):

- **Business Meta Model** — the structural template for what a service business *is*: service concept, financial model, resources, activities, governance. Lives in the `BusinessModel`, `BusinessScenarios`, and `BusinessStrategy` packages.
- **Business System Meta Model** — the structural template for how a business system *works*: processes, platform, data architecture, knowledge, operations. Currently implicit across Foundation, Platform, ServiceDelivery, Knowledge, and Operations.

Both meta models are domain-agnostic. GSL (clinical) and CSW (coffee shop) each instantiate them with domain-specific types.

---

## 2. Scale and Maturity

### The model

| Metric | Value |
|---|---|
| Top-level packages | 10 (Enterprise, Foundation, Knowledge, ServiceDelivery, Platform, Operations, BusinessModel, BusinessScenarios, BusinessStrategy, GenderSense root) |
| Total packages | 72+ |
| Model files | 10 `.sysml` files |
| Largest file | `knowledge.sysml` — 114 KB |
| Use case definitions | 100+ |

### The demonstrator

| Metric | Value |
|---|---|
| Frontend pages | 9 |
| API routes | 19 |
| Temporal workflows | 1 (FulfilDrink with XState lifecycle) |
| CDR integration | 3 archetypes, AQL queries, governance audit |
| PostgreSQL tables | 4 |
| Generated artefacts | TypeScript types, XState machine, Temporal workflow scaffold, Mermaid pathway diagram |
| Stack | SvelteKit + Tailwind v4 + Flowbite Svelte, Temporal, EHRbase, PostgreSQL |

### Sessions

| Range | Focus |
|---|---|
| 1–4 | Coffee shop demonstrator Phases A–D |
| 5–7 | Hormone therapy initiation clinical pathway |
| 8–12 | Knowledge layer elaboration (5 phases) |
| 13–19 | Business meta model (7 phases) |
| 20–28 | CSW Extension Phases 1–9 (domain model → PostgreSQL → API → frontend → system pages) |
| **29** | **CSW Extension Phase 10 (meta model update) — workstream complete** |

---

## 3. What Was Built in Session 29

### Business Meta Model Additions

Three new part defs in `BusinessModel`:

- **`CatalogueEntry`** (ServiceConcept) — the business decision to offer an item. Generic four-layer model: item definition → catalogue entry → inventory record → external reference.
- **`ExternalReference`** (ServiceConcept) — a link to knowledge the system doesn't own.
- **`InventoryRecord`** (ResourcePlanning) — operational stock tracking, distinct from `ResourceInstance` (strategic planning).

### Business System Meta Model Additions

Five new elements in `Foundation`:

- **`PersistenceLayer`** enum (CommonTypes) — CDR, business database, process engine, external reference.
- **`DataCharacteristic`** enum (CommonTypes) — eleven characteristics determining persistence home.
- **`PersistencePolicy`** part def (CommonTypes) — maps domain concept → persistence layer with rationale.
- **`AgencyType`** enum (MetadataLibrary) — patientAgent, clinicianAgent, automated, collaborative.
- **`AgencyClassification`** metadata def (MetadataLibrary) — annotates pathway action nodes with agency and authority model version.

### Coffee Shop Instantiation

Six `PersistencePolicy` instances in `CoffeeShopBusinessModel`, one per domain concept, making the three-persistence-layer architecture's reasoning explicit and queryable.

### Architectural Clarification

New standing document: `gsl-architecture-clarification-two-meta-models-2026-03-14.md`. Bridging notes added to `gsl-platform-sysml-modelling-strategy.md` and `gsl-spec-catalogue-inventory-v2.1.md`.

---

## 4. CSW Extension Workstream — Complete

| Phase | Focus | Status | Session |
|---|---|---|---|
| 0: Conceptual modelling | ✓ Complete | Pre-session |
| 1: SysML domain model update | ✓ Complete | 20 |
| 2: PostgreSQL foundation | ✓ Complete | 21 |
| 3: Catalogue & inventory API routes | ✓ Complete | 22 |
| 4: Frontend foundation | ✓ Complete | 23 |
| 5: Counter page | ✓ Complete | 24 |
| 6: Manager GUI | ✓ Complete | 25 |
| 7: Order Board & Order Timeline | ✓ Complete | 26 |
| 8: Data & Insights pages | ✓ Complete | 27 |
| 9: System pages | ✓ Complete | 28 |
| **10: Meta model update** | **✓ Complete** | **29** |

**10 phases across 10 sessions.** The workstream is complete.

---

## 5. Architectural Patterns Validated

### Established patterns (unchanged)

1–19: All patterns from previous snapshots remain validated.

### New in Session 29

20. **Two meta model distinction as standing architectural principle.** Business meta model concepts (what the business offers) are structurally separated from system meta model concepts (how the system implements it). Every new part def or metadata def carries a doc block identifying its meta model. This is the architectural guarantee that business model changes and system changes can be iterated independently.

21. **Persistence policy as queryable architectural reasoning.** The system carries explicit, auditable rationale for where each domain concept is persisted. Six policies in the coffee shop demonstrator map concepts to CDR, PostgreSQL, Temporal, and external references with String rationale. The clinical analogue: "patient assessments in the CDR because archetype-validated and versioned; appointment scheduling in PostgreSQL because high-frequency CRUD."

22. **Agency classification as metadata on pathway actions.** The `@AgencyClassification` metadata def enables annotating any pathway action node with who performs it and which authority model version was in effect. This is the enabling foundation for all four generations of self-service. The metadata def's enum-typed attribute is a verified new pattern.

---

## 6. Technical Findings (Cumulative)

### SysML / Syside (Session 29)

- **`system` is a KerML reserved word** — cannot be used as an enum literal. Causes silent parse failure: the containing package becomes unresolvable, producing cascading reference-errors in all consumers. No error shown at the literal itself.
- **Enum-typed attribute on metadata def: verified** — `attribute agencyType : AgencyType;` works when enum and metadata def are in the same package (MetadataLibrary).
- **Cross-project specific named imports: do not work** — `private import Foundation::CommonTypes::PersistencePolicy;` fails. Wildcard `private import Foundation::CommonTypes::*;` works. This is a Syside limitation.
- **Multi-valued enum attribute on part def (definition): verified** — `attribute characteristics : DataCharacteristic [1..*];` parses cleanly. Instance-level `:>>` with tuple syntax deferred.

### Previous findings (Sessions 23–28) — unchanged

All frontend, backend, and architecture findings from previous sessions remain current.

---

## 7. Knowledge Layer Increment Status

| Increment | Status | Landing zone |
|---|---|---|
| 1: Constraint evaluation at pathway step | **Unblocked** (Session 26) | Order Timeline page |
| 2: Decision table for drink routing | **Unblocked** (Session 24) | Counter page |
| 3: System self-assessment dashboard | **Unblocked** (Session 28) | System Status page |
| 4: OptionEvaluator / "Help Me Choose" | Not started | Counter page (after 1–3) |
| Catalogue constraint: cannot discontinue with active orders | **Unblocked** (Session 25) | Manager GUI |

---

## 8. Immediate Next Steps

1. Choose next workstream from candidates: KL Increments 1–3, Pattern Catalogue, Model Consolidation Review, Structural Deepening, or System Meta Model Extraction.
2. Update syntax reference with Session 29 findings (KerML reserved word, enum-typed metadata attribute, cross-project named imports, multi-valued enum attribute).

---

## 9. Strategic Position

The project is 29 sessions in. The CSW Extension workstream — the largest single workstream at 10 phases across 10 sessions — is complete. The demonstrator now covers the complete operational surface with nine frontend pages, 19 API routes, three persistence layers, and a meta model that separates business concerns from system concerns at the structural level.

The two meta model distinction, clarified and formally documented in this session, is a foundational architectural commitment. It ensures that as additional service domains are added (addictions, other clinical specialities), they inherit shared structure from both meta models without conflating business strategy with system architecture. The `PersistencePolicy` and `AgencyClassification` additions prepare the system meta model for two critical future capabilities: multi-persistence architectural reasoning and self-service generational evolution.

All three core Knowledge Layer Increments remain unblocked with their UI landing zones built. The five-layer self-knowledge architecture has a visible placeholder on the System Status page. The infrastructure health monitoring, operational metrics aggregation, and interactive process model visualisation are all operational.

The model-first approach continues to validate: the Phase 3 API layer (Session 22) served every frontend need across seven subsequent phases without modification. The business meta model part defs defined in this session will serve as structural templates for clinical domain instantiation when that work begins.

---

*Strategic snapshot prepared 14 March 2026. Session 29.*
