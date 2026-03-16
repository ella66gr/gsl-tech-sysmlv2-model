# Session 26 Report — CSW Extension Phase 7: Order Board & Order Timeline

**Date:** 14 March 2026
**Session number:** 26
**Workstream:** CSW Extension — Catalogue, Inventory & Frontend (Phase 7 of 10)
**Plan:** `gsl-plan-csw-extension-phase7-implementation-2026-03-14.md`

---

## Summary

Executed Phase 7 of the CSW Extension workstream: the Order Board kanban view and Order Timeline detail page. The existing `/orders` page (a flat Temporal workflow list table) was replaced with a kanban board showing active orders grouped by XState lifecycle state (Placed → In Preparation → Ready), with inline signal actions and a collapsible historical orders table. The existing `/orders/[id]` page (a basic status card with signal button) was replaced with a rich Order Timeline showing a state machine progression visual, order summary card, step-by-step event timeline with compliance badges from the audit endpoint, and governance links.

Additionally: a Phase 7 detailed implementation plan was created before execution, and a composite orders (multi-item baskets) architectural item was formally documented in the deferred items tracker.

This phase required no backend changes — all existing API routes were consumed as-is.

---

## Work Completed

### Pre-Session: Phase 7 Plan

**Phase 7 Detailed Implementation Plan** (`gsl-plan-csw-extension-phase7-implementation-2026-03-14.md`) — 5-stage plan covering the Order Board kanban, historical orders table, Order Timeline with state machine visual, event timeline with audit integration, and polish. The plan confirmed no backend changes were needed. Key design decision: kanban cards show case ref + state + time elapsed rather than item details, since neither the active orders nor list endpoints carry drink name data. Item details are visible on drill-through to the Order Timeline.

### Order Board Page

**Rewritten: `src/routes/orders/+page.svelte`** — Complete kanban board replacing the flat workflow list table.

**Kanban columns:** Three columns matching XState lifecycle states — Placed (blue border), In Preparation (yellow), Ready (green). Each column shows a count badge and contains order cards.

**Order cards:** Each card displays the anonymised case reference (e.g. CASE-6FB5), time elapsed since order placement, lifecycle state badge, an inline action button for the next signal (Start Prep / Mark Ready / Collect), and a "View details →" link to the Order Timeline.

**Summary statistics bar:** Above the kanban — "4 active orders | 2 waiting  1 in preparation  1 ready for collection". Updates on each poll cycle.

**Inline signal actions:** Clicking "Start Prep" on a Placed card sends the `baristaStarted` signal via `POST /api/orders/[id]/signal`, then refreshes all data. The card moves to the In Preparation column on the next render.

**Historical orders:** Collapsible "Completed Orders" section below the kanban. Shows a Flowbite Table of completed/failed/cancelled workflows with case ref, Temporal status badge, start/end timestamps, and links to the Order Timeline and Audit Report. Collapsed by default.

**Polling:** 5-second interval refreshing both active orders and workflow list. Provides a live operational view.

**Empty state:** Dashed border box with "No active orders. Place a new order to see it here." when no workflows are running.

### Order Timeline Page

**Rewritten: `src/routes/orders/[id]/+page.svelte`** — Rich order detail view replacing the basic status card.

**State machine visual:** Horizontal progression indicator with four lifecycle steps (Placed → In Preparation → Ready → Collected). Completed steps show green circles with ✓. The active step has a highlighted ring with the step's emoji. Future steps are dimmed. Cancelled orders show a red alert.

**Order summary card:** Right-hand panel showing case ref, lifecycle status badge, Temporal workflow status, start time, and either completion time or elapsed time for running orders.

**Event timeline:** Vertical timeline with connector line and coloured dots. Each step from the audit endpoint is rendered with its label, type badge (Activity / Wait), compliance badge (✓ On time / ⚠ Exceeded), timestamps, duration, and target from the SysML model annotations. Active steps show a pulsing dot. Pending steps show hollow dots with "Pending" text.

**Next action button:** Below the state machine visual, showing the appropriate signal action for the current state. Disabled during signal sending.

**Governance note:** Panel at the bottom linking to the FulfilDrink process model page, full compliance audit report (for completed orders), CDR records page, and Temporal Web UI.

**Polling:** 3-second interval for running orders, stopped when terminal state reached.

### Audit Page Navigation Update

**Modified: `src/routes/orders/[id]/audit/+page.svelte`** — Back-navigation links updated from "Order status" / "All orders" to "Order Timeline" / "Order Board" for consistency with new page naming.

### Deferred Items Update

**Modified: `gsl-plan-next-steps-and-deferred-items.md`** — Added composite orders (multi-item baskets) as a formal architectural item in §8, with clinical analogue (clinical plan triggering multiple concurrent linked workflows). Updated Phase 7 status. Documented barrel export SSR failure finding. Marked KL Increment 1 as unblocked.

---

## Findings

### Barrel Export SSR Failure

Importing `anonymiseCaseRef` from `@coffeeshop/shared` (the barrel export) on page components causes a 500 Internal Server Error during SSR. The barrel export transitively pulls in the PostgreSQL client (`pg`), which fails in the server-side render context. This is the same root cause as the Temporal sandbox issue from Session 24 (transitive Node.js module pull-in), manifesting in a different context.

**Fix:** Import directly from `@coffeeshop/shared/dist/workflow-constants.js` instead of the barrel export. This bypasses the transitive `pg` dependency.

**Implication:** The `@coffeeshop/shared` package is becoming a liability as a single barrel export. Every consumer (Temporal worker, SvelteKit SSR, SvelteKit client) has different module resolution constraints. This reinforces the case for the two-phase generation pipeline's package splitting approach (`shared-types` for pure types and constants, `shared-clients` for runtime clients with Node.js dependencies).

### No Backend Changes Required

Phase 7 consumed six existing API endpoints without modification: `GET /api/orders/active`, `GET /api/orders/list`, `GET /api/orders/[id]`, `POST /api/orders/[id]/signal`, `GET /api/orders/[id]/audit`, plus the existing signal and audit infrastructure. This confirms the API layer's comprehensiveness across multiple frontend consumer pages.

### Kanban Without Item Details Is Operationally Useful

The kanban cards show case ref, state, and time elapsed — but not what was ordered. This was a deliberate design decision: neither the active orders nor list endpoints return the drink name. Despite this, the kanban is operationally effective for queue management. The barista can see at a glance: how many orders are waiting, how many are in preparation, and how many are ready for collection. Item details are available on drill-through. The clinical analogue holds: a pathway dashboard shows queue depth per stage, not patient clinical details.

### Audit Endpoint Works for Running Orders

The audit endpoint (`GET /api/orders/[id]/audit`) returns partial data for running orders — completed steps have timestamps and compliance assessment, while pending steps have no timing data. This maps naturally to the timeline's completed/active/pending visual states. No separate "timeline" endpoint was needed.

---

## Coffee Shop Demonstrator Extension

**Capability demonstrated:** Operational process monitoring — kanban queue management with inline lifecycle actions, and individual order drill-down with state machine visual, event timeline, and governance compliance assessment.

**What was built:** Order Board with three-column kanban (Placed / In Preparation / Ready), inline signal actions, summary statistics, collapsible historical orders table. Order Timeline with state machine progression visual, order summary card, step-by-step event timeline with SysML-derived compliance badges, and governance links.

**What was learned:**
- Barrel export SSR failure — same root cause as Temporal sandbox issue, different manifestation. Direct module imports are the reliable pattern.
- Kanban without item-level detail is operationally useful for queue management
- The audit endpoint provides sufficient data for both running and completed order timelines
- The state machine visual + event timeline combination effectively conveys process state at a glance

**Clinical implementation confidence:** High. The patterns map directly to:
- **Clinical pathway dashboard:** Kanban columns for pathway stages (Referral → Assessment → Initiation → Monitoring → Stable). Each card represents a patient's pathway instance.
- **Patient timeline:** State machine visual showing pathway progression. Event timeline with clinical audit steps and compliance against NICE guideline timings.
- **Governance integration:** Timing targets from the SysML model appearing as compliance badges demonstrates how model-derived clinical governance rules surface in the operational view.

---

## Architecture Notes

### Modified Files

| File | Change |
|---|---|
| `src/routes/orders/+page.svelte` | **Rewritten** — kanban board replacing flat table |
| `src/routes/orders/[id]/+page.svelte` | **Rewritten** — Order Timeline replacing basic status card |
| `src/routes/orders/[id]/audit/+page.svelte` | **Minor** — back-navigation text update |

### No New API Routes

All operations use existing endpoints. No backend changes in this phase.

---

## Git Log

| Commit | Description |
|---|---|
| `921337c` | CSW frontend: Order Board kanban view and Order Timeline with state machine visual, event timeline, and audit integration |

---

## Next Session

Continue CSW Extension workstream — **Phase 8: Data & Insights Pages**:
- Records: Entity views with tabbed interface, visual AQL query indicators, record cards
- Audit Dashboard: Refine existing governance page with compliance gauges and improved layout
- Customer Voice: Feedback integrated with order flow, visual star ratings, CDR source indicators
- All use existing API routes — no backend changes expected

Phase 8 detailed implementation plan to be created at start of next session.

**Infrastructure note for next session:** The coffee shop demonstrator requires four services running: Docker containers (PostgreSQL + EHRbase via `docker-compose.ehrbase.yml`), Temporal dev server (`temporal server start-dev --db-filename ""`), Temporal worker (`node packages/temporal/dist/workers/worker.js` after `pnpm --filter @coffeeshop/temporal build`), and the SvelteKit dev server (`pnpm --filter @coffeeshop/web dev`). The Temporal in-memory DB means no historical data persists between Temporal restarts.

---

## Syntax Reference

No update required — no SysML changes in this phase.

---

*Session 26 report prepared 14 March 2026.*
