# GenderSense SysML Model — Strategic Snapshot

**Date:** 14 March 2026 (Session 25)
**Prepared by:** Claude (from direct review of the complete codebase and session 25 conversation)
**Scope:** The `gsl-sysml-model` project in its entirety — model, generators, demonstrator, documentation, development practice
**Changes from previous version:** CSW Extension Phase 6 (Manager GUI — Stock & Catalogue) complete. Self-service enabling architecture discussion paper produced. No SysML model changes.

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
| Top-level packages | 10 (Enterprise, Foundation, Knowledge, ServiceDelivery, Platform, Operations, BusinessModel, BusinessScenarios, BusinessStrategy, GenderSense root) |
| Total packages | 72 |
| Model files | 10 `.sysml` files, 364 KB total |
| Largest file | `knowledge.sysml` — 114 KB |
| Use case definitions | 100+ |

### The demonstrator

| Metric | Value |
|---|---|
| Frontend pages | 9 (Counter, Order Board, Management/Catalogue, Entity/Records, Governance, Feedback, Pathway, System, Order Detail + Audit sub-pages) |
| API routes | 17 (catalogue CRUD, inventory CRUD, orders lifecycle, entity queries, governance audit, active orders) |
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
| 20 | CSW Extension Phase 1 (SysML domain model update) |
| 21 | CSW Extension Phase 2 (PostgreSQL foundation) |
| 22 | CSW Extension Phase 3 (catalogue & inventory API) |
| 23 | CSW Extension Phase 4 (frontend foundation — Tailwind v4 + Flowbite Svelte) |
| 24 | CSW Extension Phase 5 (Counter page — catalogue-driven dynamic UI) |
| 25 | CSW Extension Phase 6 (Manager GUI — stock & catalogue) + self-service architecture discussion |

---

## 3. What Was Built in Session 25

### Manager GUI — Stock & Catalogue (Phase 6)

The placeholder page at `/management/catalogue` was replaced with a fully functional management interface. The page has three interconnected panels:

**Catalogue Table:** Flowbite Table showing all 11+ items with category filter tabs (All / Hot Drinks / Cold Drinks / Food), sort by name or price, availability status badges, provision type, dietary badges. Clickable rows open an inline edit panel below the table for modifying business decisions (price, availability, status notes).

**Add Item Modal:** Category-aware creation form. Selecting "Food" shows food-specific fields (gluten-free, served warm) and defaults to "bought in" provision; selecting a drink category shows drink fields (sizes, milk, caffeinated) with category-appropriate size defaults. Optional initial inventory for bought-in items. Full validation and error handling.

**Inventory Panel:** Right-hand column showing bought-in items with stock level progress bars, status badges (In Stock / Low / Out of Stock), restock and adjust controls with inline forms, and last restocked dates. Low-stock alert banner at page top when items fall below threshold.

**No backend changes.** All seven Phase 3 API endpoints were consumed without modification.

### Self-Service Enabling Architecture Discussion Paper

A significant discussion paper exploring patient self-service as a foundational design principle. Covers the Apperta CoPHR Blueprint heritage, clinical authority problem, harm reduction in trans healthcare, six generational stages of self-service, and six architecture recommendations for immediate adoption. This paper influenced the work analysis (new Workstream 9 with items 9.1–9.6).

---

## 4. Active Workstream

### CSW Extension — Catalogue, Inventory & Frontend

| Phase | Status | Session |
|---|---|---|
| 0: Conceptual modelling | ✓ Complete | 20 |
| 1: SysML domain model update | ✓ Complete | 20 |
| 2: PostgreSQL foundation | ✓ Complete | 21 |
| 3: Catalogue & inventory API routes | ✓ Complete | 22 |
| 4: Frontend foundation | ✓ Complete | 23 |
| 5: Counter page | ✓ Complete | 24 |
| **6: Manager GUI** | **✓ Complete** | **25** |
| 7: Remaining operations pages | **Next** | |
| 8: Data & insights pages | Planned | |
| 9: System pages | Planned | |
| 10: Meta model update | Planned | |

**Phase 7 scope:** Order Board (kanban view by lifecycle state) and Order Timeline (visual state machine with event timeline and CDR record). Both use existing API routes.

---

## 5. Architectural Patterns Validated

### Established patterns (unchanged from previous snapshots)

1. **SysML v2 as single source of truth** — model → generators → running code
2. **Two-layer pathway modelling** — domain flow + orchestration flow
3. **Five-layer self-knowledge architecture** — ConstraintEvaluator → OperationalStateAggregator → GoalProjector → GapAnalyser → RemediationPlanner
4. **Coffee shop demonstrator as standing validation practice**
5. **Three-persistence-layer architecture** — CDR (clinical) + PostgreSQL (business) + Temporal (process)
6. **Four-layer conceptual model** — item definition → catalogue entry → inventory record → external references
7. **Catalogue-as-UI-contract** — `availableSizes`, dietary flags, and provision type drive UI structure

### New in Session 25

8. **Split-view management layout** — catalogue table (left) + inventory panel (right), matching the Counter page's order form + active orders pattern. Now a proven layout pattern for both operational and management pages.
9. **Category-conditional form fields** — the SysML domain model's `Drink` / `FoodItem` specialisation hierarchy directly drives which form fields appear. Validates the "model drives the form" pattern for clinical prescribing forms.
10. **Cross-page data consistency** — Manager and Counter pages both read from the same catalogue API; changes in one are immediately reflected in the other via the single-source-of-truth pattern.

---

## 6. Technical Findings (Cumulative)

### Frontend (Sessions 23–25)

- **Tailwind v4 + Flowbite Svelte 1.31.0** works well with Svelte 5.53.7
- **Flowbite Modal `slot="footer"`** does not render — use in-body buttons with `border-t` separator instead
- **Flowbite Table, Badge, Button, Alert, Select, Input, Label, Spinner, Modal** all work correctly (Modal body only; named slots unreliable)
- **Dark mode** requires CSS overrides with `!important` for Flowbite Input/Select components
- **Layout max-width** increased from `6xl` to `7xl` to accommodate split-view pages
- **Temporal sandbox** requires selective imports when `@coffeeshop/shared` barrel export pulls in Node.js modules (pg)

### Architecture (cumulative)

- **SvelteKit load functions** — right boundary for stable reference data; client-side polling for dynamic operational data
- **Three parallel fetches** on the Manager page (catalogue + inventory + low-stock) are fast and provide complete data in one render cycle
- **Phase 3 API design was comprehensive** — zero backend changes needed for the full Manager GUI (Phase 6)

---

## 7. Knowledge Layer Increment Status

| Increment | Status | Landing zone |
|---|---|---|
| 1: Constraint evaluation at pathway step | Not started | Order Timeline page (Phase 7) |
| 2: Decision table for drink routing | **Unblocked** (Session 24) | Counter page (Phase 5 ✓) |
| 3: System self-assessment dashboard | Not started | System Status page (Phase 9) |
| 4: OptionEvaluator / "Help Me Choose" | Not started | Counter page (after Increments 1–3) |
| Catalogue constraint: cannot discontinue with active orders | **Unblocked** (Session 25) | Manager GUI (Phase 6 ✓) |

---

## 8. Immediate Next Steps

1. **Phase 7 detailed implementation plan** — create at start of next session
2. **Phase 7 execution** — Order Board (kanban) and Order Timeline pages
3. Continue through Phases 8–10 to complete the CSW Extension workstream

---

## 9. Strategic Position

The project is 25 sessions in, with a 72-package SysML v2 model and a running demonstrator that now covers the full operational surface: order placement (Counter), operational management (Manager GUI), order lifecycle tracking (Order Board/Detail), clinical data (Records, Governance, Feedback), and system visibility (Pathway, System Status — placeholder).

The CSW Extension workstream is past the halfway point (6 of 10 phases complete). The remaining phases are frontend-only (7–9) plus the meta model consolidation (10). The self-service enabling architecture discussion paper has positioned six new work items (Workstream 9) for integration at appropriate points in the roadmap.

The model-driven architecture continues to validate: each new UI capability is built on top of the existing API layer, which was derived from the domain model, which is expressed in SysML. The generation chain is intact.

---

*Strategic snapshot prepared 14 March 2026. Session 25.*
