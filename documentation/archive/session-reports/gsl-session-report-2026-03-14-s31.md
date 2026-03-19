# Session 28 Report — CSW Extension Phase 9: System Pages

**Date:** 14 March 2026
**Session number:** 28
**Workstream:** CSW Extension — Catalogue, Inventory & Frontend (Phase 9 of 10)
**Plan:** `gsl-plan-csw-extension-phase9-implementation-2026-03-14.md`

---

## Summary

Executed Phase 9 of the CSW Extension workstream: the two System pages — Process Model (`/pathway`) and System Status (`/system`). These are the final frontend pages in the workstream. Phase 9 also introduced the first new backend routes since Phase 3 — a health check endpoint and an operational metrics aggregation endpoint.

Additionally: a Phase 9 detailed implementation plan was created before execution.

---

## Work Completed

### Pre-Session: Phase 9 Plan

**Phase 9 Detailed Implementation Plan** (`gsl-plan-csw-extension-phase9-implementation-2026-03-14.md`) — 5-stage plan covering health check API, metrics API, interactive Process Model, System Status dashboard, and polish. The plan identified two risk areas (EHRbase client baseUrl access, PostgreSQL raw query access) and resolved both through interface investigation before coding began.

### Stage 1: Health Check API Route

**Created: `src/routes/api/system/health/+server.ts`** — Infrastructure health endpoint that pings all three persistence layers in parallel.

**EHRbase:** Uses `executeAql('SELECT e/ehr_id/value FROM EHR e LIMIT 1')` as the health probe — exercises the full CDR query path (connection, auth, AQL engine).

**PostgreSQL:** Uses `db.query('SELECT 1')` — the `PostgresClient` interface exposes a raw parameterised query method.

**Temporal:** Lists workflows with `pageSize: 1` to verify gRPC connectivity without heavy iteration.

**Import pattern:** `WORKFLOW_NAME` imported from `@coffeeshop/shared/dist/workflow-constants.js` (direct path) rather than the barrel export, continuing the pattern from Sessions 24 and 26 to avoid the transitive `pg` dependency issue.

**Response shape:** `{ overall: 'healthy' | 'degraded' | 'unavailable', services: [...], checkedAt }` — all three checks run via `Promise.all` so a single failure doesn't block the others.

### Stage 2: Metrics API Route

**Created: `src/routes/api/system/metrics/+server.ts`** — Operational metrics aggregation from seven data sources.

**Data sources:** PostgreSQL catalogue (all + active), PostgreSQL inventory, CDR entity orders (all + today), Temporal active orders, CDR governance audit. All queries run in parallel via `Promise.allSettled` for graceful degradation.

**Response shape:** Orders (total, today, active), catalogue (total, active, category breakdown), inventory (tracked, low stock, out of stock), governance (compliance rate, data gaps).

**Observation:** `totalOrders: 0` with `activeOrders: 3` is expected — the Temporal in-memory DB was restarted, so no CDR compositions exist from current orders. The metrics faithfully report what each persistence layer knows.

### Stage 3: Process Model Page

**Rewritten: `src/routes/pathway/+page.svelte`** — Complete rewrite replacing the static SVG + table with an interactive pathway view.

**Hand-crafted SVG pathway:** Rather than manipulating the Mermaid-generated SVG (which has hardcoded colours, opaque internal IDs, and no click handlers), the page uses a hand-crafted SVG themed to the coffee shop palette. Node positions are declared as a `Record<string, NodePosition>` and edge paths are computed as cubic Bézier curves. The pathway is stable (8 nodes, 9 edges from the SysML `FulfilDrink` action def) so this is a one-time effort with full control over interactivity and theming.

**Node types:** Start nodes (green stadium shape), end nodes (blue stadium shape), decision nodes (amber rectangle with heavier border), action nodes (light cream rectangle). All nodes are clickable.

**Step metadata modals:** Clicking any node opens a Flowbite Modal showing up to three panels:
- **Domain Layer** (green) — doc block from `drink-fulfilment.sysml`, e.g. "Combine the base and milk (if needed), add any extras, and finish the drink."
- **Orchestration Layer** (blue) — mapped workflow step from `fulfil-drink-orchestration.sysml`, with signal name and timeout metadata, e.g. "waitDrinkReady · Signal: drinkReady · Timeout: 15 min"
- **Clinical Analogy** (neutral) — the clinical mapping, e.g. "Lab results returned."

Decision nodes (Check Drink Type, Check Milk) show only domain layer and clinical analogy — they don't map to a Temporal workflow step.

**Active orders section:** Fetches `/api/orders/active` on mount and displays current orders with their XState lifecycle state mapped to orchestration step labels (placed → "Validate Order", preparing → "Prepare Drink", ready → "Wait for Collection").

**Two-layer reference:** Collapsible sections showing the domain and orchestration layer descriptions with SysML source file references. The orchestration workflow steps table is retained inside a collapsible.

### Stage 4: System Status Page

**Rewritten: `src/routes/system/+page.svelte`** — Complete rewrite replacing the placeholder card with a full operational dashboard.

**Infrastructure Health:** Three cards (EHRbase, PostgreSQL, Temporal) with live status indicator (green/yellow/red dot), service name, status text, and response time in milliseconds. Green background for healthy, yellow for degraded, red for unavailable. "↻ Check" button for re-running. Timestamp shows when last checked.

**Operational Metrics:** Five summary cards (Total Orders, Orders Today, Active Orders, Menu Items, Compliance Rate with progress bar) in a responsive grid. The compliance bar uses `$derived` for the rate calculation and conditional colour, following the Audit Dashboard pattern from Session 27.

**Catalogue & Inventory:** Category breakdown (Cold Drink: 4, Food: 2, Hot Drink: 6) as pill badges, stock alerts (1 low stock), tracked items count, and a "Manage stock" link to the Manager GUI.

**Structural Inventory:** Static metadata grid showing the system's scale — 3 persistence layers, 72 SysML packages, 10 model files, 19 API routes, 9 frontend pages, 1 Temporal workflow, 3 CDR archetypes, 4 PostgreSQL tables. Noted as static values from the strategic snapshot, with a future note about the System Model Manifest generator.

**Self-Assessment Placeholder:** Prominent dashed-border panel labelled "Knowledge Layer Increment 3 — Placeholder". Lists all five layers of the self-knowledge architecture with their coffee shop equivalents (ConstraintEvaluator, OperationalStateAggregator, GoalProjector, GapAnalyser, RemediationPlanner). Clinical analogy note explains the mapping.

**Cross-page links:** Footer links to Audit Dashboard, Stock & Catalogue, Process Model, and Order Board.

### Stage 5: Polish

**Layout TODO comment:** Added a detailed comment to `+layout.svelte` explaining that the navbar health indicators are static green dots, with the rationale for deferring live polling and the upgrade path via `/api/system/health`.

---

## Findings

### EHRbase Health Check via AQL

Using `executeAql('SELECT e/ehr_id/value FROM EHR e LIMIT 1')` as the EHRbase health probe is more robust than hitting the `/ehrbase/status` endpoint directly, because it exercises the full query path (connection, authentication, AQL engine) rather than just the HTTP server. The `EhrbaseClient` interface doesn't directly expose the base URL, so deriving it for a raw fetch would have required string manipulation on the OpenEHR API path.

### PostgresClient Exposes `query()` Method

The `PostgresClient` interface includes a `query<T>(sql, params?)` method as an "escape hatch for queries not covered by the typed methods." This made `SELECT 1` trivial for the health check. The interface was well-designed for extensibility — the Phase 2/3 work anticipated this kind of use.

### Phase 3 API Layer Continues to Hold

The metrics route consumes seven existing endpoints and direct database queries without any modifications. This extends the streak: zero backend changes across Phases 5, 6, 7, 8, and the frontend portions of Phase 9. The 17 API routes built in Phases A–D and Phase 3, plus the 2 new system routes (19 total), serve every current frontend need.

### Hand-Crafted SVG vs Mermaid

The hand-crafted SVG pathway is significantly better than the Mermaid-generated version for interactive use:
- Full control over node colours, matching the coffee shop palette
- Click handlers on every node — not possible with the Mermaid SVG without fragile overlay positioning
- Dark mode support via CSS variables (Mermaid hardcodes `fill:#ECECFF` etc.)
- Smaller payload — the Mermaid SVG is 45KB of verbose path data; the hand-crafted version is ~3KB of component code

The tradeoff is maintainability: if the SysML action flow changes, both the generated Mermaid and the hand-crafted SVG need updating. In practice, the domain pathway is stable — it has not changed since Session 1.

### Promise.allSettled for Metrics Aggregation

Using `Promise.allSettled` (not `Promise.all`) for the metrics route means individual query failures degrade gracefully. If EHRbase is down, the CDR-sourced metrics (order counts, governance) show as 0/N/A while the PostgreSQL-sourced metrics (catalogue, inventory) still populate correctly. This is the right pattern for a dashboard that aggregates across independent data sources.

---

## Coffee Shop Demonstrator Extension

**Capability demonstrated:** System self-awareness — live infrastructure health monitoring across all three persistence layers, operational metrics aggregation, interactive process model visualisation with two-layer domain/orchestration annotation, and a structured landing zone for the five-layer self-knowledge architecture.

**What was built:** Health check API pinging Temporal, EHRbase, and PostgreSQL. Metrics API aggregating orders, catalogue, inventory, and governance data. Process Model page with hand-crafted interactive SVG, step metadata modals, and active order tracking. System Status dashboard with health cards, operational metrics, catalogue/inventory summary, structural inventory, and KL3 self-assessment placeholder.

**What was learned:**
- AQL query is more robust than HTTP status check for EHRbase health probing
- Hand-crafted SVG gives full interactivity control for stable pathway diagrams
- `Promise.allSettled` is the right aggregation pattern for multi-source dashboards
- The two-layer model presentation (domain + orchestration) is clear and informative in the modal UI

**Clinical implementation confidence:** High. The patterns map directly to:
- **Infrastructure health:** Monitor EHRbase CDR uptime, Temporal workflow engine health, and business database — critical for a clinical service where system availability affects patient care.
- **Operational metrics:** "N patients in active pathways, N awaiting monitoring bloods, compliance rate for 3-month milestone."
- **Process Model:** Clinical pathway visualisation. Clicking "Initial Assessment" shows domain-level clinical actions (history, examination, consent) and orchestration-level workflow steps (schedule appointment, await results, update record).
- **Self-assessment:** The KL Increment 3 landing zone becomes the clinical service's self-knowledge dashboard.

---

## Architecture Notes

### New Files

| File | Purpose |
|---|---|
| `src/routes/api/system/health/+server.ts` | Infrastructure health check — pings Temporal, EHRbase, PostgreSQL |
| `src/routes/api/system/metrics/+server.ts` | Operational metrics aggregation from 7 data sources |

### Modified Files

| File | Change |
|---|---|
| `src/routes/pathway/+page.svelte` | **Rewritten** — interactive SVG pathway with step modals and active orders |
| `src/routes/system/+page.svelte` | **Rewritten** — operational dashboard with health, metrics, inventory, KL3 placeholder |
| `src/routes/+layout.svelte` | TODO comment on navbar health indicators |

### API Route Count

Total API routes: **19** (17 from Phases A–D and Phase 3, plus 2 new system routes).

---

## Git Log

| Commit | Description |
|---|---|
| `[committed]` | CSW backend: system health and metrics API routes (Phase 9, Stages 1-2) |
| `[committed]` | CSW frontend: interactive Process Model with step metadata modals and active order state (Phase 9, Stage 3) |
| `[committed]` | CSW frontend: System Status dashboard with live health, metrics, and KL3 placeholder (Phase 9, Stage 4) |
| `[committed]` | CSW frontend: Phase 9 polish — navbar health TODO, cross-page links |
| `[committed]` | Documentation: Phase 9 plan, next-steps update (Session 28) |

---

## Next Session

Continue CSW Extension workstream — **Phase 10: Meta Model Update**:
- Incorporate findings from the CSW Extension exercise into the GSL business meta model SysML
- CatalogueEntry, InventoryRecord, PersistencePolicy part defs
- Consider whether "maintain catalogue" warrants a new ActivityType
- Update the CSW business model with persistence policy instances

Phase 10 detailed implementation plan to be created at start of next session.

All three Knowledge Layer Increments are now unblocked with their UI landing zones built:
- KL Increment 1 → Order Timeline (Phase 7)
- KL Increment 2 → Counter page (Phase 5)
- KL Increment 3 → System Status (Phase 9)

---

## Syntax Reference

No update required — no SysML changes in this phase.

---

*Session 28 report prepared 14 March 2026.*
