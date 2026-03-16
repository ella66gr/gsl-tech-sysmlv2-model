# GenderSense SysML Model — Strategic Snapshot

**Date:** 14 March 2026 (Session 28)
**Prepared by:** Claude (from direct review of the complete codebase and session 28 conversation)
**Scope:** The `gsl-sysml-model` project in its entirety — model, generators, demonstrator, documentation, development practice
**Changes from previous version:** CSW Extension Phase 9 (System pages) complete. Two new backend API routes. No SysML model changes.

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
| 20 | CSW Extension Phase 1 (SysML domain model update) |
| 21 | CSW Extension Phase 2 (PostgreSQL foundation) |
| 22 | CSW Extension Phase 3 (catalogue & inventory API) |
| 23 | CSW Extension Phase 4 (frontend foundation — Tailwind v4 + Flowbite Svelte) |
| 24 | CSW Extension Phase 5 (Counter page — catalogue-driven dynamic UI) |
| 25 | CSW Extension Phase 6 (Manager GUI — stock & catalogue) + self-service architecture discussion |
| 26 | CSW Extension Phase 7 (Order Board kanban & Order Timeline) |
| 27 | CSW Extension Phase 8 (Data & Insights — Records, Audit Dashboard, Customer Voice) |
| **28** | **CSW Extension Phase 9 (System pages — Process Model, System Status)** |

---

## 3. What Was Built in Session 28

### Health Check API — Live Infrastructure Monitoring

**`GET /api/system/health`** — Pings all three persistence layers in parallel via `Promise.all`:

- **EHRbase:** AQL query probe (`SELECT e/ehr_id/value FROM EHR e LIMIT 1`) — exercises the full CDR query path.
- **PostgreSQL:** `SELECT 1` via the `PostgresClient.query()` method.
- **Temporal:** Minimal `workflow.list()` with `pageSize: 1` to verify gRPC connectivity.

Returns `{ overall, services: [{ service, status, responseTimeMs, detail? }], checkedAt }`. Each service check is independent — a single failure doesn't block reporting on the others.

### Metrics API — Operational Aggregation

**`GET /api/system/metrics`** — Aggregates from seven data sources via `Promise.allSettled`:

PostgreSQL: catalogue (all + active), inventory. CDR: entity orders (all + today), governance audit. Temporal: active orders.

Returns order counts, catalogue stats with category breakdown, inventory alerts, and governance compliance. Graceful degradation — individual source failures don't block the response.

### Process Model — Interactive Two-Layer Pathway

The static SVG + table was replaced with an interactive pathway view:

**Hand-crafted SVG:** 8 nodes and 9 edges, themed to the coffee shop palette. Start nodes (green stadium), end nodes (blue stadium), decision nodes (amber), action nodes (cream). All nodes are clickable.

**Step metadata modals:** Clicking any node opens a modal showing up to three panels: Domain Layer (green, from `drink-fulfilment.sysml`), Orchestration Layer (blue, from `fulfil-drink-orchestration.sysml` with signal/timeout metadata), and Clinical Analogy. Decision nodes show only domain + analogy.

**Active orders section:** Fetches `/api/orders/active` on mount. Orders display with XState lifecycle state mapped to orchestration step labels.

**Two-layer reference:** Collapsible sections showing both SysML sources and the orchestration workflow steps table.

### System Status — Operational Dashboard

The placeholder card was replaced with a five-section dashboard:

**Infrastructure Health:** Three service cards with live status dots, response times, and conditional backgrounds (green/yellow/red). "↻ Check" button for re-running.

**Operational Metrics:** Five summary cards (Total Orders, Orders Today, Active Orders, Menu Items, Compliance Rate with progress bar).

**Catalogue & Inventory:** Category breakdown as pill badges, stock alerts with low/out-of-stock counts, link to Manager GUI.

**Structural Inventory:** Static metadata grid (persistence layers, SysML packages, model files, API routes, frontend pages, workflows, archetypes, tables).

**Self-Assessment Placeholder:** Dashed-border panel labelled "Knowledge Layer Increment 3 — Placeholder". All five layers of the self-knowledge architecture listed with coffee shop equivalents and clinical analogy.

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
| 6: Manager GUI | ✓ Complete | 25 |
| 7: Order Board & Order Timeline | ✓ Complete | 26 |
| 8: Data & Insights pages | ✓ Complete | 27 |
| **9: System pages** | **✓ Complete** | **28** |
| 10: Meta model update | **Next** | |

**Phase 10 scope:** Incorporate CSW Extension findings into the GSL business meta model SysML — CatalogueEntry, InventoryRecord, PersistencePolicy part defs, new ActivityType consideration, persistence policy instances. Phase 10 is the final phase of the CSW Extension workstream.

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
8. **Split-view management layout** — main panel + side panel pattern for operational and management pages
9. **Category-conditional form fields** — SysML domain model hierarchy drives form structure
10. **Cross-page data consistency** — single-source-of-truth via shared API layer
11. **Kanban as operational queue view** — XState lifecycle states map to kanban columns
12. **Audit-as-timeline data source** — audit endpoint provides step-by-step timing for event timeline
13. **Process + domain + governance unified view** — Temporal, XState, and SysML annotations in one page
14. **CDR source provenance badges** — indigo badges distinguish CDR entity-view pages from operational/management pages
15. **Auto-loading entity views** — CDR data loads on page mount, shifting from "query tool" to "operational view"

### New in Session 28

16. **Infrastructure health as application-level concern** — The system monitors its own persistence layers via a dedicated health endpoint. Each service is checked independently (`Promise.all`) with response time tracking. The health check uses the same client interfaces the application uses for data access (AQL for EHRbase, `query()` for PostgreSQL, `workflow.list()` for Temporal) — testing the actual data path, not just network reachability. The clinical analogue: a clinical platform that monitors its own CDR, workflow engine, and database availability is essential for patient safety.

17. **Multi-source metrics aggregation with graceful degradation** — The metrics endpoint aggregates from seven data sources across three persistence layers using `Promise.allSettled`. Individual source failures don't block the response — the dashboard shows what it can and marks the rest as unavailable. This is the correct pattern for a clinical system where partial visibility is better than no visibility.

18. **Two-layer model visualisation in the UI** — The Process Model page makes the domain/orchestration distinction visible and interactive. Each pathway step links to both its SysML domain action (what the clinician does) and its Temporal orchestration step (what the system manages). This is architecturally significant: clinicians read the domain layer for clinical governance; the system executes the orchestration layer. The UI now communicates both.

19. **Hand-crafted SVG for stable pathway diagrams** — When the pathway is stable (as defined by the SysML model), a hand-crafted SVG themed to the application palette with click handlers gives better results than manipulating generated Mermaid output. The tradeoff is maintainability, but for a pathway that changes rarely, the interactivity and theming control outweigh the cost.

---

## 6. Technical Findings (Cumulative)

### Backend (Session 28)

- **EHRbase health via AQL** is more robust than hitting `/ehrbase/status` directly — exercises the full query path (connection, auth, AQL engine), and the `EhrbaseClient` interface doesn't expose the base URL for a raw fetch
- **`PostgresClient.query()`** escape hatch method works well for lightweight operations like health checks — the Phase 2/3 interface design anticipated extensibility
- **`Promise.allSettled`** is the right aggregation pattern for dashboards spanning multiple data sources — `Promise.all` would fail entirely if one source is down
- **Direct module imports** for `WORKFLOW_NAME` in the health check route continue the pattern from Sessions 24 and 26, avoiding the barrel export's transitive `pg` dependency

### Frontend (Sessions 23–28)

- **Tailwind v4 + Flowbite Svelte 1.31.0** works well with Svelte 5.53.7
- **Flowbite Modal `slot="footer"`** does not render — use in-body buttons with `border-t` separator
- **Flowbite Table, Badge, Button, Alert, Select, Input, Label, Spinner, Modal, Card** all work correctly
- **Dark mode** requires CSS overrides with `!important` for Flowbite Input/Select components
- **Layout max-width** at `7xl` (1280px) accommodates split-view pages
- **Temporal sandbox** requires selective imports when `@coffeeshop/shared` barrel export pulls in Node.js modules (pg)
- **SSR barrel export failure** (Session 26): importing from `@coffeeshop/shared` barrel on page components causes 500 during SSR — same transitive `pg` dependency issue. Fix: import directly from specific module paths
- **Svelte 5 `{@const}` placement** (Session 27): must be inside control flow blocks. Use `$derived` for top-level computed values
- **CDR "None" milk choice** (Session 27): display-layer filtering via `displayMilk()` helper
- **Hand-crafted SVG** (Session 28): node positions as `Record<string, NodePosition>`, edge paths as cubic Bézier curves, click handlers per node. Better than Mermaid overlay for interactive use

### Architecture (cumulative)

- **SvelteKit load functions** — right boundary for stable reference data; client-side polling for dynamic operational data
- **Phase 3 API design was comprehensive** — zero backend changes needed across Phases 5, 6, 7, 8, and the frontend portions of Phase 9
- **Audit endpoint serves dual purpose** — compliance reporting (Phase D) and event timeline (Phase 7)
- **`@coffeeshop/shared` barrel export is a growing liability** — multiple consumers (Temporal worker, SSR, client, system API routes) have incompatible module resolution constraints. Package splitting is the long-term fix.

---

## 7. Knowledge Layer Increment Status

| Increment | Status | Landing zone |
|---|---|---|
| 1: Constraint evaluation at pathway step | **Unblocked** (Session 26) | Order Timeline page (Phase 7 ✓) |
| 2: Decision table for drink routing | **Unblocked** (Session 24) | Counter page (Phase 5 ✓) |
| **3: System self-assessment dashboard** | **Unblocked (Session 28)** | **System Status page (Phase 9 ✓)** |
| 4: OptionEvaluator / "Help Me Choose" | Not started | Counter page (after Increments 1–3) |
| Catalogue constraint: cannot discontinue with active orders | **Unblocked** (Session 25) | Manager GUI (Phase 6 ✓) |

All three core Knowledge Layer Increments are now unblocked with their UI landing zones built.

---

## 8. Immediate Next Steps

1. **Phase 10 detailed implementation plan** — create at start of next session
2. **Phase 10 execution** — meta model update to complete the CSW Extension workstream
3. After Phase 10: candidate workstreams include KL Increments 1–3, Pattern Catalogue, second clinical pathway, or model consolidation review

---

## 9. Strategic Position

The project is 28 sessions in, with a 72-package SysML v2 model and a running demonstrator that now covers the complete operational surface: order placement (Counter), operational queue management (Order Board kanban), individual order tracking with governance compliance (Order Timeline), reference data management (Manager GUI), CDR data exploration (Records), population-level governance auditing (Audit Dashboard), form-driven data entry (Customer Voice), interactive process model visualisation (Process Model), and system self-awareness (System Status).

The CSW Extension workstream is at the 90% mark (9 of 10 phases complete). The remaining phase is Phase 10 (meta model consolidation) — the only phase that modifies the SysML model. The entire frontend build (Phases 4–9, six consecutive phases) is complete.

The API layer has proven remarkably durable: the 17 routes built in Phases A–D and Phase 3 served every frontend need across Phases 5–8 without modification. Phase 9 added 2 new routes for system-level concerns (health, metrics), bringing the total to 19. The model-first approach validates: a well-designed domain model drives an API layer that supports multiple frontend consumers without modification.

All three core Knowledge Layer Increments are now unblocked. The five-layer self-knowledge architecture has a visible placeholder on the System Status page, communicating the architectural vision to anyone who visits the page. The infrastructure health monitoring makes the three-persistence-layer architecture tangible — the system can now report on its own health.

---

*Strategic snapshot prepared 14 March 2026. Session 28.*
