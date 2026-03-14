# Session 24 Report — CSW Extension Phase 5: Counter Page (Dynamic Order Form)

**Date:** 13 March 2026
**Session number:** 24
**Workstream:** CSW Extension — Catalogue, Inventory & Frontend (Phase 5 of 10)
**Plan:** `gsl-plan-csw-extension-phase5-implementation-2026-03-13.md`

---

## Summary

Executed Phase 5 of the CSW Extension workstream: the dynamic Counter page. The coffee shop's landing page now reads from the catalogue API, presents visual item tiles grouped by category with per-item size selection, dietary badges, and provision type. An active orders dashboard occupies the right panel, showing running workflows with live state updates and inline action buttons to advance orders through the lifecycle. The full end-to-end flow was validated: place an order from catalogue tiles → order appears in active panel → advance through Placed → In Preparation → Ready → Collected — all from a single page.

Additionally: a Temporal workflow sandbox issue was diagnosed and fixed (barrel export pulling in pg modules), the dark mode colour palette was refined for contrast and readability, and a discussion paper on two-phase generation pipeline architecture was produced.

---

## Work Completed

### Pre-Session: Discussion Paper and Phase 5 Plan

Two documents produced before execution began:

1. **Two-Phase Generation Pipeline Discussion Paper** (`gsl-discussion-two-phase-generation-pipeline-2026-03-13.md`) — captures architectural thinking about Phase 1 (domain generators, model-aware, framework-agnostic) and Phase 2 (integration generators, framework-aware, model-agnostic), the manifest as contract between phases, four integration patterns evaluated, generatability spectrum, four-layer separation (Model → Domain Artefacts → Integration Glue → Application Code), and prototyping strategy.

2. **Phase 5 Detailed Implementation Plan** (`gsl-plan-csw-extension-phase5-implementation-2026-03-13.md`) — 4-stage plan: catalogue loading & category tabs, item tiles & size selection, active orders dashboard, polish & responsiveness.

### Stage 1+2: Catalogue-Driven Counter Page

Combined Stages 1 and 2 into a single commit as they are tightly coupled.

**New file: `src/routes/+page.ts`** — SvelteKit load function fetching active catalogue from `GET /api/catalogue`. Catalogue is stable reference data, loaded server-side so tiles render immediately without a loading spinner.

**Rewritten: `src/routes/+page.svelte`** — Complete Counter page:

- **Category tabs:** Pill-style buttons for Hot Drinks (6), Cold Drinks (3), Food (2). Active category highlighted with primary colour. Item counts shown in badges.
- **Item tiles:** 3-column grid of visual tiles generated from catalogue data. Each tile shows item name, price (`priceDisplay`), dietary badges (V for vegan, GF for gluten-free), and provision type ("Prepared" or "Bought in"). Selected tile highlighted with primary border.
- **Size selection:** Toggle buttons generated from each item's `availableSizes` array. Espresso shows only Small; Iced Latte shows Medium and Large; food items show no size selection. Medium auto-selected where available.
- **Order summary:** Confirmation line showing customer name, selected item, size, and price before submission.
- **Submit button:** Dynamic text ("Select an item" → "Place Order — Latte £2.80"). Disabled state with reduced opacity and border for visual definition.
- **Active orders panel:** Right-hand panel showing running workflows with state badges, elapsed time, and inline action buttons (Start Prep / Mark Ready / Collect). 3-second polling. Orders disappear when collected.

**New file: `src/routes/api/orders/active/+server.ts`** — API route returning only running workflows with their XState lifecycle state queried from Temporal. Optimised for the counter dashboard: filters to `ExecutionStatus = 'Running'`, queries each workflow's state individually, sorted newest-first.

**Commit:** `24dbd8f` — CSW frontend: Counter page with catalogue-driven tiles and active orders dashboard

### Dark Mode Palette Refinement

The initial dark mode was too dark (near-black backgrounds) with insufficient text contrast.

**Changes to `app.css`:**
- Shifted secondary palette lighter: `secondary-800` from `#292524` to `#3d3835`, `secondary-900` from `#1c1917` to `#342f2c`
- Added `secondary-600` intermediate value: `#504a45`
- Body background in dark mode: `secondary-700` (`#44403c`)
- CSS overrides for Flowbite Input/Select components to match the warmer palette

**Changes to `+layout.svelte`:**
- Navbar and sidebar: `dark:bg-secondary-900` (darkest but no longer near-black)
- Sidebar link text: `dark:text-secondary-300` (brighter for readability)
- Section headers: `dark:text-secondary-400`

**Changes to `+page.svelte`:**
- Tile backgrounds and borders: lightened for contrast
- "Prepared" text: `dark:text-secondary-300` (was 500 — biggest contrast fix)
- Labels: `dark:text-secondary-100` (clearly readable)
- Input field: explicit dark styling with border definition
- Light mode tiles: subtle warm tint with `bg-primary-50/30`

### Temporal Workflow Sandbox Fix

**Problem:** After Phase 2 added the PostgreSQL client to `@coffeeshop/shared`, the barrel export (`index.ts`) transitively pulls in `pg` and Node.js modules (`crypto`, `net`, `fs`, etc.). Temporal's V8 sandbox blocks these in workflow code.

**Root cause:** `fulfil-drink.ts` imported `orderLifecycleMachine` from `@coffeeshop/shared` — the barrel export.

**Fix:** Changed to a direct import from the generated dist file:
```typescript
import { orderLifecycleMachine } from '@coffeeshop/shared/dist/generated/order-lifecycle-machine.js';
```

This bypasses the barrel export entirely. The type-only import (`import type { OrderEvent }`) remains on the barrel since TypeScript strips it at compile time.

**Commit:** `6fd2be2` — Fix workflow sandbox: direct import for order lifecycle machine

**Note for future:** This is an instance of the integration concern discussed in the two-phase generation pipeline paper. When the barrel export grows to include modules with heavy transitive dependencies, selective imports become necessary for sandbox-constrained consumers. The manifest-driven approach would catch this — the manifest would record that `orderLifecycleMachine` has no Node.js dependencies and can be safely imported in sandboxed contexts.

---

## Findings

### SvelteKit Load Functions vs Client-Side Fetching

The catalogue data uses a `+page.ts` load function (server-side or universal load), while active orders use `onMount` + `setInterval` polling. This split maps to a real architectural distinction:

- **Catalogue:** Stable reference data that benefits from being available on first render. No loading spinner needed.
- **Active orders:** Dynamic operational data that changes every few seconds. Polling is appropriate.

The same pattern applies in the clinical system: formulary data loads on page render; patient queue polls for updates.

### Per-Item `availableSizes` Driving UI Toggles

The catalogue's `availableSizes` array directly controls which size buttons appear for each item. Espresso only offers Small; Iced Latte only offers Medium and Large. The UI enforces this without any hardcoded logic — the database drives the interface.

This validates the "catalogue as UI contract" pattern. Clinical analogue: a formulary entry's `availableDoses`, `availableRoutes`, and `availableFrequencies` would drive the prescribing form's option lists in the same way.

### Temporal Sandbox and Barrel Export Growth

As the shared package accumulates clients with heavy dependencies (pg, EHRbase HTTP client, etc.), the barrel export becomes toxic to Temporal's workflow sandbox. Two mitigation strategies:

1. **Selective imports** (what we did) — workflow code imports directly from the specific generated file
2. **Package splitting** — separate `@coffeeshop/shared-types` (safe for sandbox) from `@coffeeshop/shared-clients` (Node.js only)

For now, selective imports are sufficient. Package splitting is a future consideration if more workflow code needs shared types.

### Dark Mode Colour Tuning

The default Flowbite dark mode palette (gray-800/900 as near-black) doesn't work well with the warm coffee shop aesthetic. Shifting the secondary palette to lighter, warmer tones (`#3d3835` instead of `#292524`) and using CSS overrides for Flowbite Input components resolved the contrast issues. Key lesson: Flowbite components apply their own dark classes internally, so `app.css` overrides with `!important` are sometimes necessary to maintain palette consistency.

---

## Coffee Shop Demonstrator Extension

**Capability demonstrated:** Catalogue-driven dynamic UI — the system's reference data (catalogue) drives the user interface structure, replacing hardcoded options with data-driven tiles. Split-view operational dashboard with inline workflow control.

**What was built:** Dynamic Counter page reading from catalogue API, visual item tiles grouped by category, per-item size toggles from `availableSizes`, dietary badges, active orders panel with live polling and inline signal dispatch, new `/api/orders/active` route.

**What was learned:**
- SvelteKit load functions provide the right boundary for stable reference data vs dynamic operational data
- Per-item `availableSizes` driving UI toggles validates the catalogue-as-UI-contract pattern
- Inline signal dispatch from a dashboard card (rather than navigating to a detail page) is a significant UX improvement
- Temporal V8 sandbox requires careful management of shared package imports

**Clinical implementation confidence:** High. The pattern — reference data → visual selection tiles → context-sensitive sub-options → validated submission with split-view dashboard — maps directly to clinical workflows (formulary → prescribing form → patient queue).

---

## Architecture Notes

### New API Route

| Route | Method | Purpose |
|---|---|---|
| `/api/orders/active` | GET | Returns running workflows with XState lifecycle state |

### Modified Files

| File | Change |
|---|---|
| `src/routes/+page.ts` | **New** — catalogue load function |
| `src/routes/+page.svelte` | **Rewritten** — catalogue-driven Counter page |
| `src/routes/api/orders/active/+server.ts` | **New** — active orders API |
| `src/app.css` | Dark mode palette refinement |
| `src/routes/+layout.svelte` | Dark mode contrast improvements |
| `packages/temporal/src/workflows/fulfil-drink.ts` | Direct import for sandbox fix |

---

## Git Log

| Commit | Description |
|---|---|
| `24dbd8f` | CSW frontend: Counter page with catalogue-driven tiles and active orders dashboard |
| `6fd2be2` | Fix workflow sandbox: direct import for order lifecycle machine |

---

## Next Session

Continue CSW Extension workstream — **Phase 6: Manager GUI — Stock & Catalogue**:
- Catalogue view: Flowbite Table with all catalogue entries, inline status badges, filter by category
- Add item: Modal form for creating new menu item + catalogue entry
- Edit item: Click row to edit price, availability, description
- Inventory panel: Stock levels for bought-in items, manual adjustment
- Low-stock alerts

Phase 6 detailed implementation plan to be created at start of next session.

---

## Syntax Reference

No update required — no SysML changes in this phase.

---

*Session 24 report prepared 13 March 2026.*
