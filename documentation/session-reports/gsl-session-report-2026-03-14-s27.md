# Session 27 Report — CSW Extension Phase 8: Data & Insights Pages

**Date:** 14 March 2026
**Session number:** 27
**Workstream:** CSW Extension — Catalogue, Inventory & Frontend (Phase 8 of 10)
**Plan:** `gsl-plan-csw-extension-phase8-implementation-2026-03-14.md`

---

## Summary

Executed Phase 8 of the CSW Extension workstream: the three Data & Insights pages — Records (`/entity`), Audit Dashboard (`/governance`), and Customer Voice (`/feedback`). These pages were originally built during the Phase C/D CDR exercise (Sessions 3–6) and had received only minimal visual updates during Phase 4 (frontend foundation). Phase 8 brought them up to the standard established by the Counter (Phase 5), Manager GUI (Phase 6), and Order Board/Timeline (Phase 7).

Additionally: a Phase 8 detailed implementation plan was created before execution.

This phase required no backend changes — all existing CDR entity API routes were consumed as-is.

---

## Work Completed

### Pre-Session: Phase 8 Plan

**Phase 8 Detailed Implementation Plan** (`gsl-plan-csw-extension-phase8-implementation-2026-03-14.md`) — 5-stage plan covering the Records tabbed entity view with record cards, Audit Dashboard auto-loading compliance gauge, Customer Voice visual star ratings, and cross-page polish. The plan confirmed no backend changes were needed.

### Records Page

**Rewritten: `src/routes/entity/+page.svelte`** — Complete rewrite replacing manual-trigger buttons with a tabbed auto-loading entity view.

**Tabbed navigation:** Three tabs (All Orders / Today / By Customer) using Flowbite underline tab styling. Switching tabs auto-fetches the corresponding API endpoint. The "By Customer" tab shows an inline EHR ID input field.

**Auto-loading:** Data loads automatically on mount via `onMount` → `fetchOrders('all')`. No manual button click needed — this is an operational application, not a CDR exercise.

**Record cards:** Orders render as visual cards in a responsive 3-column grid. Each card shows drink name (bold title), size and milk choice (subtitle), price (right-aligned, primary colour), relative timestamp ("14:23 today", "Yesterday 09:15", "8 Mar 12:07"), and abbreviated EHR ID.

**Card/table view toggle:** A compact toggle button pair lets the user switch between the card view (default) and the existing Flowbite Table view. The table view shows EHR ID, order time, drink, size, price, and composition UID columns.

**AQL query details:** A collapsible `<details>` section below the metadata bar shows the query type, clinical analogy, and archetype identifier for the active tab's query. Demonstrates the CDR query model to the user.

**CDR source badge:** An indigo `CDR · EHRbase` badge in the page header visually identifies this as a CDR entity-view page, distinct from the operational and management pages.

**Milk choice filtering:** A `displayMilk()` helper filters out the CDR's "None" coded term value, so cards show "Large" rather than "Large · None".

### Audit Dashboard

**Rewritten: `src/routes/governance/+page.svelte`** — Auto-loading audit with compliance progress bar and refined layout.

**Auto-loading:** The governance audit runs automatically on page load via `onMount`. The manual "Run Governance Audit" button is replaced with a subtle "↻ Refresh" link in the header for re-running.

**Governance question banner:** Elevated to a prominent left-bordered panel with uppercase "GOVERNANCE QUESTION" label, the question text, and a clinical analogy note in italics.

**Summary cards:** Five-card responsive grid: Customers, Orders, Preparations, Data Gaps (red/green conditional), and Compliance Rate with a horizontal progress bar (green at 100%, yellow ≥75%, red below).

**Compliance progress bar:** Uses `$derived` reactive declarations for rate, bar colour, and card background — avoiding the Svelte 5 `{@const}` placement constraint (see Findings).

**Customer detail accordion:** Retained from the previous version with minor styling refinements. Non-compliant customers sort first. Expandable sections show order/preparation tables and unmatched order highlights.

### Customer Voice

**Rewritten: `src/routes/feedback/+page.svelte`** — Split-view with visual star ratings and auto-loading feedback cards.

**Split-view layout:** Form on the left (fixed-width `lg:w-96`), feedback list on the right (flexible). Stacks vertically on mobile.

**Visual star rating input:** Replaced the `<Select>` dropdown with five clickable/hoverable star buttons. Hover preview shows the prospective rating; click commits. A text label ("Good", "Excellent", etc.) appears alongside the stars.

**Auto-loading feedback list:** Feedback entries load automatically on mount. After each successful submission, the list refreshes to show the new entry immediately.

**Feedback cards:** Each entry renders as a card with visual star display (filled/unfilled stars), quoted comment in italics, relative timestamp, order reference (if present), and abbreviated EHR ID.

**Full form clearing:** All form fields including customer name reset after successful submission.

**Clinical analogy footer:** A styled panel at the bottom explains the PROM questionnaire analogy.

---

## Findings

### Svelte 5 `{@const}` Placement Constraint

The `{@const}` tag in Svelte 5 must be the immediate child of a control flow block (`{#if}`, `{#each}`, `{:else}`, etc.), `<svelte:fragment>`, or a component. It cannot be placed at the top level of a template block outside these structures.

**Impact:** The initial Audit Dashboard implementation placed `{@const rate = parseFloat(...)}` directly inside the summary cards grid div (not inside an `{#each}` or `{#if}`). This caused a compile error: `'{@const}' must be the immediate child of '{#snippet}', '{#if}', '{:else if}', '{:else}', '{#each}', '{:then}', '{:catch}', '<svelte:fragment>' or '<Component>'`.

**Fix:** Moved the compliance rate calculations to `$derived` reactive declarations in the script block (`let complianceRate = $derived(...)`, `let barColor = $derived(...)`, `let rateBg = $derived(...)`). These are evaluated reactively and available in the template without `{@const}`.

**Rule:** Use `{@const}` only inside `{#each}` or `{#if}` blocks for per-iteration or per-branch constants. For top-level computed values, use `$derived`.

### CDR "None" Milk Choice

The CDR stores the milk choice as a coded term, with "None" as the valid value for orders placed without a milk preference. The AQL query returns this as the string "None", which rendered visually as "Large · None" in the record cards.

**Fix:** A `displayMilk()` helper in the Records page filters out "None" (and "none") before display. The underlying CDR data is correct — this is a display-layer concern only.

### No Backend Changes Required (Again)

Phase 8 consumed six existing API endpoints without modification: `GET /api/entity/orders`, `GET /api/entity/orders/today`, `GET /api/entity/customers/[ehrId]/orders`, `GET /api/entity/feedback`, `POST /api/entity/feedback`, `GET /api/entity/governance`. This is the second consecutive phase (after Phase 7) requiring zero backend changes — confirming the API layer's comprehensiveness.

### Auto-Loading Pattern Validated

All three Phase 8 pages now auto-load on mount. The CDR queries complete in under 1 second with the demonstrator's data volume (19 orders, 5 preparations, 3 feedback entries). The loading spinner appears briefly but doesn't create a noticeable delay. This validates the auto-loading pattern for the clinical system, where entity-view pages will load patient data automatically rather than requiring manual query execution.

---

## Coffee Shop Demonstrator Extension

**Capability demonstrated:** Rich CDR data exploration — entity views with tabbed navigation, visual record cards, automated governance auditing with compliance visualisation, and form-driven data entry with visual star ratings and immediate feedback. CDR source provenance consistently indicated across all entity-view pages.

**What was built:** Records page with tabbed entity view (All / Today / By Customer), card and table view toggle, AQL query details. Audit Dashboard with auto-loading compliance gauge and governance question banner. Customer Voice with visual star rating input, split-view layout, and auto-loading feedback cards.

**What was learned:**
- Svelte 5 `{@const}` has strict placement rules — use `$derived` for top-level computed values
- CDR coded terms ("None" for milk) need display-layer filtering
- Auto-loading CDR data on page mount works well for the demonstrator's data volume
- The indigo CDR badge effectively communicates the three-persistence-layer architecture

**Clinical implementation confidence:** High. The patterns map directly to:
- **Clinical records view:** Tabbed entity view for lab results (All / Recent / By Patient). Record cards showing result values, reference ranges, and ordering clinician.
- **Governance dashboard:** Auto-loading compliance audit for pathway adherence. The compliance progress bar becomes a real governance metric.
- **Patient-reported outcomes:** The Customer Voice pattern maps directly to PROM questionnaire submission — structured data entry outside any workflow, committed directly to the CDR.

---

## Architecture Notes

### Modified Files

| File | Change |
|---|---|
| `src/routes/entity/+page.svelte` | **Rewritten** — tabbed entity view with record cards |
| `src/routes/governance/+page.svelte` | **Rewritten** — auto-loading audit with compliance gauge |
| `src/routes/feedback/+page.svelte` | **Rewritten** — split-view with star ratings |

### No New API Routes

All operations use existing CDR entity endpoints from Phases C and D. No backend changes in this phase.

---

## Git Log

| Commit | Description |
|---|---|
| `[pending]` | CSW frontend: Data & Insights pages — Records with tabbed entity view and record cards, Audit Dashboard with auto-loading compliance gauge, Customer Voice with visual star ratings |
| `[pending]` | CSW frontend: Data & Insights polish — fix milk 'None' display, remove dead code |

---

## Next Session

Continue CSW Extension workstream — **Phase 9: System Pages**:
- Process Model: Interactive pathway SVG — highlight current step for active orders, click step for metadata annotations
- System Status: Infrastructure health indicators, structural inventory, placeholder self-assessment panel, catalogue statistics
- Landing zone for Knowledge Layer Increment 3 (system self-assessment)

Phase 9 detailed implementation plan to be created at start of next session.

**Infrastructure note for next session:** The coffee shop demonstrator requires four services running: Docker containers (PostgreSQL + EHRbase via `docker-compose.ehrbase.yml`), Temporal dev server (`temporal server start-dev --db-filename ""`), Temporal worker (`node packages/temporal/dist/workers/worker.js` after `pnpm --filter @coffeeshop/temporal build`), and the SvelteKit dev server (`pnpm --filter @coffeeshop/web dev`). The Temporal in-memory DB means no historical data persists between Temporal restarts.

---

## Syntax Reference

No update required — no SysML changes in this phase.

---

*Session 27 report prepared 14 March 2026.*
