# GSL Workstream: Coffee Shop Extension — Catalogue, Inventory & Frontend

**Date:** 12 March 2026
**Status:** Active workstream — Phase 0 complete
**Context:** Post Business Meta Model Phase 7 (Session 19), post Knowledge Layer Elaboration (Phases 1–5). This workstream consolidates the catalogue/inventory exercise with the frontend reboot into a single coherent plan.
**Companion documents:** `catalogue-inventory-spec-v2.md` (archetype and database specification), `gsl-plan-coffeeshop-frontend-reboot-2026-03-12.md` (original frontend design reference)

---

## 1. Purpose

The CSW manager wants to add four new items to the menu: mocha latte, frappe, ginger biscuit, oat bar. This simple operational need is the forcing function for a systematic exercise that:

- Introduces **catalogue and inventory management** as new system capabilities
- Establishes a **PostgreSQL business database** alongside the CDR, with explicit architectural reasoning for the boundary
- Extends the **SysML domain model** with new concepts (CatalogueEntry, InventoryRecord, ExternalReference, PersistencePolicy)
- Identifies and fills **gaps in the business meta model** (individual orderable items, stock management, reference data management, persistence strategy)
- Reboots the **CSW frontend** with Tailwind v4 + Flowbite Svelte, creating a cohesive GUI that makes system capabilities visible
- Builds a **manager GUI** for stock and catalogue management
- Creates the **surface area** for Knowledge Layer Increments 1–3 to land in future sessions

The exercise demonstrates model-first discipline throughout: the SysML model is updated first, and implementation is derived from the model.

---

## 2. Architectural Decisions Made (Phase 0)

These decisions were reached through structured discussion on 12 March 2026 and are recorded in `catalogue-inventory-spec-v2.md`:

| Decision | Rationale |
|---|---|
| **Three persistence layers:** CDR (clinical), PostgreSQL (business), Temporal (process) | openEHR optimised for health records; business data needs simple CRUD, transactions, relational joins. Coffee shop catalogue and inventory live in PostgreSQL. |
| **Four-layer conceptual model:** item definition → catalogue entry → inventory record → external references | Separates intrinsic product properties from business decisions from operational state from external knowledge. Generalises to healthcare (medication → formulary → stock → SPC/BNF). |
| **Price moves off MenuItem onto CatalogueEntry** | Price is a business decision, not an intrinsic product property. Same item can appear in multiple catalogues at different prices. |
| **ADMIN_ENTRY for catalogue archetype (CDR pattern)** | Administrative registration, not measurement or assessment. Pattern retained as reference for when clinical reference data (formulary) needs CDR representation. |
| **OBSERVATION for inventory archetype (CDR pattern)** | Point-in-time measurement of stock. Pattern retained as reference for clinical stock records. |
| **Prepared vs bought-in provision type distinction** | Affects inventory semantics and preparation workflow. Prepared items track ingredients; bought-in items track finished products. |
| **PersistencePolicy as explicit meta model concept** | System carries queryable rationale for where each domain concept is persisted and why. Supports AI-assisted and human system evolution. |
| **ExternalReference as generic attachment point** | Items connect to external knowledge (SPCs, BNF, supplier datasheets) via references, not containment. System links to knowledge; doesn't reproduce it. |

---

## 3. Relationship to Work Analysis Priorities

This workstream touches several items from `gsl-work-analysis-and-priorities-2026-03-11.md`:

| Work analysis item | How this workstream relates |
|---|---|
| **4.5 Coffee Shop Knowledge Layer Increments 1–3** | Creates the UI surface area. System Status page = Increment 3 landing zone. Manager GUI can incorporate constraint evaluation (Increment 1). Catalogue properties enable decision table routing (Increment 2). |
| **4.3 Manifest generator enrichment** | New domain concepts (CatalogueEntry, InventoryRecord) should be reflected in the manifest once modelled. |
| **1.4 Domain-agnostic naming** | CatalogueEntry, InventoryRecord, PersistencePolicy are all domain-neutral. Tests meta model's generality. |
| **5.x Business model refinement** | Surfaces three meta model gaps. Catalogue exercise directly tests ServiceConcept completeness. |
| **6.1 Naming consistency** | New model elements follow consistent conventions from the outset. |

Items **not** in scope for this workstream: 1.1–1.3 (ref formalisation), 2.1–2.4 (SysML language depth), 3.1 (second clinical pathway), 7.x (deferred runtime items). These remain as separate workstreams per the work analysis.

---

## 4. Phases

### Phase 0: Conceptual Modelling ✓ COMPLETE

**Deliverables:**
- Four-layer conceptual model defined
- CDR/PostgreSQL architectural boundary established with rationale
- Archetype designs (ADMIN_ENTRY for catalogue, OBSERVATION for inventory) as CDR reference patterns
- PostgreSQL table design derived from domain model
- PersistencePolicy meta model concept designed
- ExternalReference pattern designed
- Seed data for 11 items (7 existing + 4 new) specified
- Meta model gap analysis (3 gaps identified in BusinessModel)
- Specification document: `catalogue-inventory-spec-v2.md`

---

### Phase 1: SysML Domain Model Update

**Goal:** Make the four-layer model real in SysML. This is the foundation everything downstream derives from.

**Work:**
1. Read the syntax reference (`sysml-v2-syntax-reference.md`) before writing any `.sysml`
2. Update `coffeeshop.sysml` (or wherever the domain model lives):
   - Remove `price` from `MenuItem`
   - Add `ExternalReference` part def
   - Add `CatalogueEntry` part def (with `ref item : MenuItem`)
   - Add `InventoryRecord` part def (with `ref catalogueEntry : CatalogueEntry`)
   - Add new enums: `AvailabilityStatus`, `ProvisionType`, `StockStatus`
   - Add `description` attribute to `MenuItem` if not already present
   - Add drink-specific attributes to `Drink` if needed: `isCaffeinated`
3. Verify in Syside Modeler — zero errors, zero warnings
4. Update `coffeeshop-business-model.sysml`:
   - Add catalogue entries for all 11 items as CatalogueEntry usages
   - Include provision type classification for each
5. Commit: `"CSW domain model: catalogue, inventory, external references"`

**Touches work analysis:** 1.4 (domain-agnostic naming), 5.x (business model refinement)
**Effort:** 1–2 stages

---

### Phase 2: PostgreSQL Foundation

**Goal:** Business database operational with catalogue and inventory tables, seeded with data. TypeScript client in `@coffeeshop/shared`.

**Work:**
1. Add PostgreSQL service to `docker-compose.ehrbase.yml` (or a new compose file). The EHRbase compose already runs PostgreSQL — decide whether to share the instance (separate database) or run a second container. Sharing is simpler; separate is cleaner.
2. Create database `coffeeshop_business`
3. Create tables from the specification (§4.1 of `catalogue-inventory-spec-v2.md`): `menu_items`, `external_references`, `catalogue_entries`, `inventory_records`
4. Run seed data SQL (§5.3 of spec)
5. Write `postgres-client.ts` in `@coffeeshop/shared` — thin wrapper around `pg` package, paralleling the `ehrbase-client.ts` pattern: connection configuration, typed query helpers, singleton factory
6. Add `pg` dependency to `@coffeeshop/shared`
7. Verify: connect, query catalogue, query inventory
8. Commit: `"CSW: PostgreSQL business database with catalogue and inventory"`

**Effort:** 1–2 stages

---

### Phase 3: Catalogue & Inventory API Routes

**Goal:** SvelteKit API endpoints for catalogue and inventory CRUD. Order form rewired to read from catalogue.

**Work:**
1. Add server-side PostgreSQL client singleton in `$lib/server/postgres.ts` (paralleling `$lib/server/ehrbase.ts`)
2. API routes:
   - `GET /api/catalogue` — all active catalogue entries joined with menu item details
   - `GET /api/catalogue/[id]` — single entry with full detail
   - `POST /api/catalogue` — add new menu item + catalogue entry (manager action)
   - `PUT /api/catalogue/[id]` — update price, availability, description
   - `GET /api/inventory` — all inventory records with catalogue item names
   - `PUT /api/inventory/[id]` — update stock level (manual adjustment)
3. Rewire `POST /api/orders` to validate drink/food type against catalogue (item must be active)
4. Test all endpoints via curl or the existing test patterns
5. Commit: `"CSW: catalogue and inventory API routes"`

**Effort:** 1–2 stages

---

### Phase 4: Frontend Foundation

**Goal:** Tailwind v4 + Flowbite Svelte installed and working. Layout shell with sidebar navigation. Coffee shop visual identity.

**Source:** Frontend reboot plan §4 (technology), §4.5 (theme), §5.1 (global shell)

**Work:**
1. Check current Flowbite Svelte version and Svelte 5 compatibility (npm registry, changelog)
2. Install dependencies into `packages/web/`:
   - `tailwindcss`, `@tailwindcss/vite`
   - `flowbite`, `flowbite-svelte`, `flowbite-svelte-icons`
   - `clsx`, `tailwind-merge`
3. Update `vite.config.ts` with `@tailwindcss/vite` plugin
4. Create `src/app.css` with Tailwind v4 + Flowbite integration + coffee shop `@theme` palette
5. Update `src/app.html` with dark mode initialisation script
6. Build layout shell: Flowbite `Sidebar` + `Navbar` replacing pipe-delimited nav
   - **Operations:** Counter (home), Order Board, Order History
   - **Management:** Stock & Catalogue (NEW)
   - **Data & Insights:** Records, Audit Dashboard, Customer Voice
   - **System:** Process Model, System Status
7. Verify: pnpm workspace `@source` path resolution, dark mode toggle, all existing API routes still work
8. Commit: `"CSW frontend: Tailwind v4 + Flowbite foundation"`

**Reference:** SV6 Setup Guide, known pitfalls documented in frontend reboot plan §4.3, §9
**Effort:** 1–2 stages

---

### Phase 5: Counter Page (Dynamic Order Form)

**Goal:** The landing page reads from the catalogue API. Customers can order drinks and food items. Visual tile selection replaces hardcoded `<select>`.

**Source:** Frontend reboot plan §5.2 (Counter design)

**Work:**
1. Build the Counter split view:
   - **Left panel:** Order form with visual tiles generated from `GET /api/catalogue`, grouped by category (hot drinks, cold drinks, food). Tiles show item name, price, dietary badges (vegan, GF), provision type indicator. Size selection as toggle buttons (from catalogue `available_sizes`).
   - **Right panel:** Active orders dashboard — live-updating cards showing each in-progress order with state, time elapsed, next action button.
2. Form submission creates order via existing `POST /api/orders`, but now validates against catalogue
3. Commit: `"CSW frontend: Counter page with catalogue-driven order form"`

**Effort:** 2 stages

---

### Phase 6: Manager GUI — Stock & Catalogue

**Goal:** The manager can view, add, edit, and manage catalogue items and inventory from the GUI.

**Work:**
1. **Catalogue view:** Flowbite `Table` showing all catalogue entries with: item name, category, price, provision type, availability status, dietary flags. Inline status badges. Filter by category. Sort by name/price/status.
2. **Add item:** Modal form (Flowbite `Modal`) for creating a new menu item + catalogue entry. Fields from the domain model: name, category, item type, price, description, dietary flags, provision type, drink-specific fields (sizes, milk, caffeinated) or food-specific fields (GF, served warm). Category selection determines which fields are shown.
3. **Edit item:** Click a row to edit price, availability, description, status notes. Changes go to `PUT /api/catalogue/[id]`.
4. **Inventory panel:** For bought-in items, show current stock level, stock status badge (in stock / low / out of stock), low-stock threshold. Manual stock adjustment (restock / adjust) via `PUT /api/inventory/[id]`.
5. **Low-stock alerts:** Flowbite `Alert` components at the top of the page for any items below threshold.
6. Commit: `"CSW frontend: Manager stock and catalogue GUI"`

**Effort:** 2–3 stages

---

### Phase 7: Remaining Operations Pages

**Source:** Frontend reboot plan §5.2, Phase 2

**Work:**
1. **Order Board:** Kanban columns by lifecycle state (Placed → In Preparation → Ready → Collected → Cancelled). Orders as Flowbite `Card` elements. Historical orders in a filterable table below.
2. **Order Timeline:** Visual state machine diagram, event timeline, CDR record alongside workflow state, inline audit compliance.
3. Both use existing API routes — no backend changes.
4. Commit: `"CSW frontend: Order Board and Order Timeline"`

**Effort:** 2–3 stages

---

### Phase 8: Data & Insights Pages

**Source:** Frontend reboot plan §5.2, Phase 3

**Work:**
1. **Records:** Entity views with tabbed interface (All / Today / By Customer), visual AQL query indicators, record cards instead of raw tables.
2. **Audit Dashboard:** Refine existing governance page — compliance gauge, customer detail with Flowbite Card/Alert, governance question prominence.
3. **Customer Voice:** Feedback integrated with order flow, visual star ratings, CDR source indicators.
4. Commit: `"CSW frontend: Records, Audit Dashboard, Customer Voice"`

**Effort:** 2–3 stages

---

### Phase 9: System Pages

**Source:** Frontend reboot plan §5.2, Phase 4. Landing zone for Knowledge Layer Increment 3.

**Work:**
1. **Process Model:** Interactive pathway SVG — highlight current step for active orders, click step for metadata annotations in modal, two-layer relationship display.
2. **System Status:**
   - Infrastructure health: Temporal, EHRbase, PostgreSQL connection indicators
   - Structural inventory from system manifest (if accessible)
   - Placeholder self-assessment panel: "N orders today, N in progress, preparation completion rate N%"
   - Catalogue statistics: "N items on the menu, N bought-in items tracked, N items currently low stock"
   - This page *runs ahead of the backend* — sketching the self-knowledge dashboard for GSL
3. Commit: `"CSW frontend: Process Model and System Status"`

**Effort:** 2 stages

---

### Phase 10: Meta Model Update

**Goal:** Incorporate all findings from this exercise into the GSL business meta model SysML.

**Work:**
1. Add to `BusinessModel::ServiceConcept` or a new `Catalogue` sub-package:
   - `CatalogueEntry` part def
   - `ExternalReference` part def
2. Add to `BusinessModel::ResourcePlanning` or a new `InventoryManagement` sub-package:
   - `InventoryRecord` part def
3. Add to a suitable location (Platform? Foundation?):
   - `PersistencePolicy` part def
   - `PersistenceLayer` enum
   - `DataCharacteristic` enum
4. Consider whether "maintain catalogue" warrants a new `ActivityType` instance in `ActivityModel`
5. Update the CSW business model with persistence policy instances for each domain concept
6. Verify in Syside Modeler
7. Commit: `"BusinessModel: CatalogueEntry, InventoryRecord, PersistencePolicy from CSW exercise"`

**Touches work analysis:** 5.x (business model refinement), 4.3 (manifest enrichment — new concepts to reflect)
**Effort:** 2–3 stages

---

## 5. Knowledge Layer Increment Integration Points

These are not in scope for this workstream but should be noted as natural follow-on work. The frontend pages built here create the landing zones:

| Increment | Landing zone | Trigger |
|---|---|---|
| **KL Increment 1:** Constraint evaluation at a pathway step | Order Timeline page — evaluation result appears inline | When Phase 7 (Order Timeline) is complete |
| **KL Increment 2:** Decision table for drink/food routing | Counter page — routing logic based on catalogue properties | When Phase 5 (Counter) is complete |
| **KL Increment 3:** System self-assessment dashboard | System Status page — live self-assessment panel | When Phase 9 (System Status) is complete |
| **Catalogue constraint:** Cannot discontinue item with active orders | Manager GUI — validation on status change | When Phase 6 (Manager GUI) is complete |

---

## 6. Estimated Effort

| Phase | Stages | Sessions |
|---|---|---|
| 0: Conceptual modelling | ✓ Done | ✓ Today |
| 1: SysML model update | 1–2 | |
| 2: PostgreSQL foundation | 1–2 | |
| 3: API routes | 1–2 | |
| 4: Frontend foundation | 1–2 | Session 2 |
| 5: Counter page | 2 | |
| 6: Manager GUI | 2–3 | Session 3 |
| 7: Operations pages | 2–3 | |
| 8: Data & Insights pages | 2–3 | Session 4 |
| 9: System pages | 2 | |
| 10: Meta model update | 2–3 | Session 5 |
| **Total** | **17–25 stages** | **4–6 sessions** |

Phases 1–3 can potentially be done in the remainder of today's session. Phases 4–6 are the core build. Phases 7–9 are the frontend reboot completion. Phase 10 is the meta model consolidation.

---

## 7. What This Does Not Change

- Existing Temporal workflows (fulfilDrink) — untouched
- Existing EHRbase integration (order, preparation, feedback compositions) — untouched
- Existing generators (TypeScript types, XState machines, Mermaid pathway, Temporal workflow) — untouched
- Generated code — untouched (though the TypeScript type generator will need updating for the MenuItem price removal and new types, which is a Phase 1 consequence)

**One breaking change:** Removing `price` from `MenuItem` in the SysML model means the generated `types.ts` will change. The `MenuItem` interface loses its `price` field. The composition builder's price handling needs updating to read from the catalogue rather than the item. This is addressed in Phase 3 (API routes).

---

*Workstream plan prepared 12 March 2026. Integrates catalogue-inventory-spec-v2.md, gsl-plan-coffeeshop-frontend-reboot-2026-03-12.md, and relevant items from gsl-work-analysis-and-priorities-2026-03-11.md.*
