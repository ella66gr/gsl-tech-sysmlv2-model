# GenderSense SysML Model — Strategic Snapshot

**Date:** 15 March 2026 (Session 30)
**Prepared by:** Claude (from direct review of the complete codebase and session 30 conversation)
**Scope:** The `gsl-sysml-model` project in its entirety — model, generators, demonstrator, documentation, development practice
**Changes from previous version:** Concept Graph workstream Stages 1–4 complete. PatternCatalogue SysML package created (22 patterns, 11 domain instantiations). Obsidian vault integrated. Wildcard import collision discovered, fixed, and analysed. Three new standing conventions established. Model file count: 11 (was 10).

---

## 1. What This Project Is

GenderSense Limited is building a model-driven clinical service management platform for gender-affirming healthcare. The `gsl-sysml-model` project is the representation layer: a SysML v2 model that serves as the single source of truth for what the business is, how its clinical services work, what rules govern them, and how the technology platform supports them.

The architectural thesis — validated through a running coffee shop demonstrator application and now extended across the full business system — is that the model generates the execution layer rather than merely documenting it. Process knowledge lives in the model. Clinical data structure lives in openEHR archetypes. Decision rules live in constraints. Business data lives in a relational database. When anything changes, the change happens in the representation layer and propagates to execution via generation or configuration.

This is not a paper exercise. The model produces running code.

---

## 2. Scale and Maturity

### The model

| Metric | Value |
|---|---|
| Top-level packages | 11 (Enterprise, Foundation, Knowledge, ServiceDelivery, Platform, Operations, BusinessModel, BusinessScenarios, BusinessStrategy, PatternCatalogue, GenderSense root) |
| Total packages | 73 |
| Model files | 11 `.sysml` files |
| Largest file | `knowledge.sysml` — 114 KB |
| Concept graph | 22 patterns, 11 domain instantiations, 3 classification enums |

### The demonstrator

| Metric | Value |
|---|---|
| Frontend pages | 9 (Counter, Order Board, Management/Catalogue, Records, Audit Dashboard, Customer Voice, Pathway, System Status, Order Detail + Audit sub-pages) |
| API routes | 19 (catalogue CRUD, inventory CRUD, orders lifecycle, entity queries, governance audit, active orders, system health, system metrics) |
| Temporal workflows | 1 (FulfilDrink with XState lifecycle) |
| CDR integration | 3 archetypes (order, preparation, feedback), AQL queries, governance audit |
| PostgreSQL tables | 4 (menu_items, catalogue_entries, inventory_records, external_references) |
| Generated artefacts | TypeScript types, XState machine, Temporal workflow scaffold, Mermaid pathway diagram |
| Stack | SvelteKit + Tailwind v4 + Flowbite Svelte, Temporal, EHRbase, PostgreSQL |

### Sessions

| Range | Focus |
|---|---|
| 1–4 | Coffee shop demonstrator Phases A–D (model → generation → workflow → CDR) |
| 5–7 | Hormone therapy initiation clinical pathway |
| 8–12 | Knowledge layer elaboration (5 phases: constraints → evaluation → self-knowledge) |
| 13–19 | Business meta model (7 phases: service concept → financial → strategy → operations) |
| 20–29 | CSW Extension (10 phases: domain model → PostgreSQL → API → frontend → meta model) |
| **30** | **Concept Graph workstream Stages 1–4 (syntax investigation, PatternCatalogue, Obsidian vault, conventions)** |

---

## 3. What Was Built in Session 30

### PatternCatalogue SysML Package

New top-level package in `model/pattern-catalogue.sysml`. The model now describes its own architectural patterns — a self-knowledge capability at the meta level. Contains:

- Three classification enums (`PatternMaturity`, `MetaModelHome`, `PatternKind`)
- Two core part defs (`Pattern`, `DomainInstantiation`)
- 22 pattern instances covering all validated architectural patterns from the strategic snapshot plus 6 deferred/conceptual patterns
- 11 domain instantiations tracking where patterns have been implemented in CSW and GSL

### Obsidian Concept Graph

Integrated into the existing GenderSense Obsidian vault at `02 ARCHITECTURE & MODELLING/Concept Graph/`. 14 notes: 5 detailed pattern notes, 1 pattern index, 3 domain notes, 1 deferred item note, 3 templates, 1 index. Connected to the SysML layer via frontmatter `sysml_element` fields and a documented naming convention.

### Wildcard Import Collision Fix and Analysis

Discovered and fixed a pre-existing name collision where `CoffeeShop::CatalogueEntry` and `BusinessModel::ServiceConcept::CatalogueEntry` clashed via wildcard imports. Produced a full analysis (`gsl-analysis-wildcard-import-collision-2026-03-15.md`) mapping all current and latent collisions across the model.

### Three New Standing Conventions

1. **Import collision convention** — qualify domain types when meta model names overlap (repo conventions §9)
2. **Periodic code and model reviews** — proactive reviews at workstream boundaries (next-steps §2)
3. **PatternCatalogue–Obsidian cross-reference** — naming convention and frontmatter schema (repo conventions §10)

---

## 4. CSW Extension Workstream — Complete

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
| 10: Meta model update | Business + system meta model | 29 |

---

## 5. Architectural Patterns Validated

22 validated patterns now formally catalogued in the SysML `PatternCatalogue` package with cross-domain tracking. See `pattern-catalogue.sysml` for the full list and `Concept Graph Index.md` in the Obsidian vault for navigable descriptions.

**Business meta model patterns (4):** Four-layer item model, Activity taxonomy, Scenario comparison and projection, Persistence policy as queryable reasoning.

**Business system meta model patterns (17):** SysML v2 as single source of truth, Two-layer pathway modelling, Five-layer self-knowledge architecture, Metadata-driven generation, XState in Temporal, Three-persistence-layer architecture, Catalogue-as-UI-contract, Kanban-as-process-dashboard, Split-view management layout, Category-conditional form fields, Cross-page data consistency, Audit-as-timeline data source, Process + domain + governance unified view, CDR source provenance badges, Auto-loading entity views, Infrastructure health as application concern, Multi-source metrics with graceful degradation, Two-layer model visualisation, Hand-crafted SVG for stable pathways.

**Cross-cutting (1):** Coffee shop demonstrator as standing validation practice.

**Deferred/conceptual (6):** Composite order orchestration, Agency classification on actions, Self-assessment dashboard, OptionEvaluator, Data release model, Notification triggers.

---

## 6. Technical Findings (Cumulative)

### Session 30

- **`ref` to `metadata def` and `enum def` types:** All four variants (singular, multi-valued, to metadata def, to enum def) verified in Syside 0.8.5
- **Wildcard import name collision:** When two `private import X::*;` bring in identically-named types, Syside resolves silently. Type-errors appear downstream, not at the ambiguous import. Fix: qualify with full path. Convention established.
- **Obsidian MCP access:** Filesystem MCP server already has vault directory in allowed paths. No separate Obsidian plugin needed for Claude to read/write vault notes during sessions.

### Previous sessions (unchanged)

All prior findings remain current. See Session 29 report for the most recent cumulative list.

---

## 7. Knowledge Layer Increment Status

| Increment | Status | Landing zone |
|---|---|---|
| 1: Constraint evaluation at pathway step | **Unblocked** (Session 26) | Order Timeline page (Phase 7 ✓) |
| 2: Decision table for drink routing | **Unblocked** (Session 24) | Counter page (Phase 5 ✓) |
| 3: System self-assessment dashboard | **Unblocked** (Session 28) | System Status page (Phase 9 ✓) |
| 4: OptionEvaluator / "Help Me Choose" | Not started | Counter page (after Increments 1–3) |
| Catalogue constraint: cannot discontinue with active orders | **Unblocked** (Session 25) | Manager GUI (Phase 6 ✓) |

All three core Knowledge Layer Increments remain unblocked with their UI landing zones built.

---

## 8. Active and Planned Workstreams

### Active: Concept Graph (Stages 5–8 remaining)

Stages 1–4 complete (Session 30). Stages 5–8 planned for Session 31: full pattern population, Obsidian population, integration testing, workstream completion.

### Candidates (after Concept Graph completion)

1. **Knowledge Layer Increments 1–3** — all UI landing zones built
2. **Model Consolidation Review** — periodic review per new convention
3. **Second Clinical Pathway** — tests architecture generalisation
4. **Structural Deepening** — port definitions, use case elaboration
5. **System Meta Model Extraction** — longer-term architectural evolution

---

## 9. Strategic Position

The project is 30 sessions in, with an 11-package, 73-sub-package SysML v2 model, a running demonstrator covering the complete operational surface, and now a self-describing concept graph that catalogues the project's own architectural patterns.

The Concept Graph workstream represents a shift from building capabilities to building navigable knowledge about capabilities. The model now describes not just the business and its system, but the architectural patterns that compose them, where those patterns have been validated, and what remains to be built across domains. This is the meta-level extension of the self-describing system principle.

Three new standing conventions (import collision, periodic reviews, cross-reference) establish governance practices that scale with the model's growth. The wildcard import collision finding — discovered through careful verification rather than production failure — validates the periodic review approach.

The CSW Extension workstream is complete. All Knowledge Layer Increments are unblocked. The project is well-positioned for either deepening (KL Increments, second pathway) or broadening (model review, structural deepening) as the next priority.

---

*Strategic snapshot prepared 15 March 2026. Session 30.*
