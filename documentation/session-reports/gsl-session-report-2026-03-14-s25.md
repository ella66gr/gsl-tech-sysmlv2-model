# Session 25 Report — CSW Extension Phase 6: Manager GUI — Stock & Catalogue

**Date:** 14 March 2026
**Session number:** 25
**Workstream:** CSW Extension — Catalogue, Inventory & Frontend (Phase 6 of 10)
**Plan:** `gsl-plan-csw-extension-phase6-implementation-2026-03-14.md`

---

## Summary

Executed Phase 6 of the CSW Extension workstream: the Manager GUI for stock and catalogue management. The placeholder "Coming in Phase 6" card at `/management/catalogue` is now a fully functional management page with a catalogue table (11 → 12 items during testing), category-aware add item modal, inline editing panel, and inventory management panel with stock level bars and low-stock alerting. The full CRUD cycle was validated end-to-end, including cross-page verification: items added or modified in the Manager GUI are immediately reflected on the Counter page.

Additionally: a self-service enabling architecture discussion paper was produced earlier in the session, and the Phase 6 detailed implementation plan was created before execution began.

This phase required no backend changes — all Phase 3 API routes were consumed as-is.

---

## Work Completed

### Pre-Session: Discussion Paper and Phase 6 Plan

Two documents produced before execution began:

1. **Self-Service Enabling Architecture Discussion Paper** (`gsl-discussion-self-service-enabling-architecture-2026-03-14.md`) — captures architectural thinking about patient self-service as a foundational design principle. Covers the Apperta CoPHR Blueprint heritage, clinical authority problem, harm reduction principles in trans healthcare, six generational stages of self-service, and six architecture recommendations for immediate adoption (AgencyClassification metadata, authority model versioning, NotificationTrigger metadata, OptionEvaluator, CoPHR governance principles, data release model).

2. **Phase 6 Detailed Implementation Plan** (`gsl-plan-csw-extension-phase6-implementation-2026-03-14.md`) — 5-stage plan covering catalogue table with filtering, add item modal, inline editing, inventory panel, and polish. The plan confirmed that no backend changes were needed — all API routes from Phase 3 were already complete.

### Manager GUI Page

**Rewritten: `src/routes/management/catalogue/+page.svelte`** — Complete Manager GUI replacing the Phase 4 placeholder card. Single file, ~900 lines. All state management, data fetching, and interactive behaviour in one page component.

#### Catalogue Table (Stages 1 + 3)

- **Category filter tabs:** Pill-style buttons for All Items (12), Hot Drinks (6), Cold Drinks (4), Food (2). Same visual pattern as Counter page.
- **Sort toggle:** Name (default) or Price, as text links above the table.
- **Flowbite Table:** Columns for name, category (with emoji icon), price (monospaced, right-aligned), availability status badge, provision type, dietary badges (V, GF). Hidden columns on mobile for responsive layout.
- **Clickable rows:** Each row opens the inline edit panel below the table.
- **Inline edit panel:** Edits business decisions only — price (pence input with live preview), availability (Active / Seasonal / Temporarily Unavailable / Discontinued), status notes. Read-only summary of item's intrinsic properties (category, provision type, description). PUT to `/api/catalogue/[id]`.

#### Add Item Modal (Stage 2)

- **Flowbite Modal** with category-aware conditional field sets.
- **Common fields:** Name, category (select), description, price in pence with display preview, provision type (select), vegan (checkbox).
- **Drink fields** (shown for hot_drink, cold_drink): Available sizes (multi-select toggle buttons), default milk (select), caffeinated (checkbox).
- **Food fields** (shown for food): Gluten-free (checkbox), served warm (checkbox).
- **Initial inventory** (shown when provision type is "bought_in"): Initial stock quantity, low-stock threshold.
- **Category change side-effects:** Selecting "Food" sets provision to "bought_in", clears drink fields. Selecting drink categories sets defaults (hot drink → all 3 sizes, cold drink → medium/large).
- POST to `/api/catalogue` with `CreateCatalogueItemInput`.

#### Inventory Panel (Stage 4)

- **Right column** (desktop) / stacked below (mobile). Mirrors Counter page's active orders panel layout.
- **Inventory cards** for each bought-in item: name, stock status badge (In Stock / Low / Out of Stock / On Order), stock level bar with colour coding (green → yellow → red), price, last restocked date.
- **Inline restock/adjust forms:** Click "Restock" or "Adjust" to expand an inline form within the card. Restock defaults to 24; adjust starts at current level. PUT to `/api/inventory/[id]`.

#### Low-Stock Alerts and Polish (Stage 5)

- **Yellow alert banner** at page top when any items are below their low-stock threshold. Data from `GET /api/inventory?low=true`.
- **Page summary:** "12 items in catalogue — 12 active, 2 tracked in inventory".
- **Success messages** after add, edit, and stock adjustment operations.

### Layout Width Adjustment

- **`+layout.svelte`:** Increased main content area `max-w` from `6xl` (1152px) to `7xl` (1280px). The split-view pages (Counter, Manager) with table + side panel needed the extra width to avoid column clipping.

**Commit:** `ef63e6d` — CSW frontend: Manager catalogue table, add item modal, inline editing, and inventory panel

**Commit:** `51832ac` — Layout width increase (6xl → 7xl)

---

## Findings

### Flowbite Modal Footer Slot Failure

The `<svelte:fragment slot="footer">` pattern does not render with the current stack (flowbite-svelte 1.31.0, Svelte 5.53.7). The footer content is silently swallowed — no error, no warning, the buttons simply don't appear. This is likely a Svelte 5 snippet/slot compatibility issue in the Flowbite component.

**Workaround:** Place action buttons inside the modal body content with a `border-t` separator div. This is visually equivalent and fully reliable. The finding is documented in `gsl-plan-next-steps-and-deferred-items.md` §9 as a general caution: test each Flowbite named slot before relying on it.

### Category-Conditional Form Fields Validate Domain Model Hierarchy

The add item modal's conditional field rendering directly mirrors the SysML domain model's `Drink` / `FoodItem` specialisation hierarchy. Selecting "Food" hides drink-specific fields and shows food-specific ones; selecting a drink category does the reverse. The side-effects (food → bought_in provision, cold drink → medium/large sizes only) encode domain knowledge at the UI level.

This validates the "model drives the form" pattern: the domain model's type hierarchy determines which fields are relevant, and the UI respects that hierarchy. The clinical analogue is a prescribing form where selecting "hormone" vs "blocker" vs "supplement" reveals different field sets (dosing regimen, monitoring requirements, interaction checks).

### No Backend Changes Required

Phase 6 consumed all seven Phase 3 API endpoints without modification. The `GET /api/catalogue?all=true` query parameter (added in Phase 3 for the manager view), the `POST /api/catalogue` transaction (menu item + catalogue entry + optional inventory), and the `PUT` update endpoints all worked exactly as designed. This confirms that the Phase 3 API design was comprehensive and forward-looking.

### Cross-Page Data Flow Verified

Items added or modified in the Manager GUI are immediately visible on the Counter page (after a page refresh, since the Counter uses a `+page.ts` load function rather than polling). This validates the single-source-of-truth pattern: both pages read from the same catalogue API, which reads from the same PostgreSQL database. There is no state duplication to synchronise.

### Split-View Layout Pattern Stabilised

Both the Counter page (tiles + active orders) and the Manager page (table + inventory) use the same layout pattern: `flex flex-col gap-6 lg:flex-row` with `flex-1 min-w-0` for the main panel and `w-full lg:w-96 shrink-0` for the side panel. This is now a proven pattern for the clinical dashboard layout (consultation form + patient queue, formulary table + stock panel).

---

## Coffee Shop Demonstrator Extension

**Capability demonstrated:** Reference data management GUI — the system's catalogue and inventory are managed through a structured interface that respects the domain model's four-layer conceptual separation (item definition → catalogue entry → inventory record → external references).

**What was built:** Full Manager GUI with catalogue table, category filtering, add item modal with category-aware fields, inline editing of business decisions (price, availability, notes), inventory panel with stock level bars and restock/adjust controls, low-stock alerting.

**What was learned:**
- Flowbite Modal named slots don't work in the current Svelte 5 stack — use in-body buttons instead
- Category-conditional form fields effectively mirror the SysML domain model's type hierarchy
- The Phase 3 API design was comprehensive — zero backend changes needed for the full management GUI
- Cross-page data consistency (Manager → Counter) works via the single-source-of-truth pattern
- The split-view layout pattern (main panel + side panel) is now established for both operational and management pages

**Clinical implementation confidence:** High. The pattern — reference data table with filtering and status badges, category-aware creation form, inline editing of business decisions, side-panel operational monitoring with alerting — maps directly to formulary management and pharmacy stock tracking.

---

## Architecture Notes

### Modified Files

| File | Change |
|---|---|
| `src/routes/management/catalogue/+page.svelte` | **Rewritten** — full Manager GUI replacing placeholder |
| `src/routes/+layout.svelte` | max-w-6xl → max-w-7xl |

### No New API Routes

All operations use existing Phase 3 endpoints. No backend changes in this phase.

---

## Git Log

| Commit | Description |
|---|---|
| `ef63e6d` | CSW frontend: Manager catalogue table, add item modal, inline editing, and inventory panel |
| `51832ac` | Layout max-width 6xl → 7xl |

---

## Next Session

Continue CSW Extension workstream — **Phase 7: Remaining Operations Pages**:
- Order Board: Kanban columns by lifecycle state (Placed → In Preparation → Ready → Collected → Cancelled)
- Order Timeline: Visual state machine, event timeline, CDR record alongside workflow state
- Both use existing API routes — no backend changes expected

Phase 7 detailed implementation plan to be created at start of next session.

---

## Syntax Reference

No update required — no SysML changes in this phase.

---

*Session 25 report prepared 14 March 2026.*
