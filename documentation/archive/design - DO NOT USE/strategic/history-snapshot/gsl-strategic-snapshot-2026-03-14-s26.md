# GenderSense SysML Model — Strategic Snapshot

**Date:** 14 March 2026 (Session 26)
**Prepared by:** Claude (from direct review of the complete codebase and session 26 conversation)
**Scope:** The `gsl-sysml-model` project in its entirety — model, generators, demonstrator, documentation, development practice
**Changes from previous version:** CSW Extension Phase 7 (Order Board & Order Timeline) complete. Composite orders architectural item documented. No SysML model changes.

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
| **26** | **CSW Extension Phase 7 (Order Board kanban & Order Timeline)** |

---

## 3. What Was Built in Session 26

### Order Board — Kanban View

The flat Temporal workflow list table at `/orders` was replaced with a kanban board:

**Kanban columns:** Three columns matching XState lifecycle states — Placed (blue), In Preparation (yellow), Ready (green) — each with count badges and order cards.

**Order cards:** Anonymised case reference (e.g. CASE-6FB5), time elapsed, state badge, inline action button (Start Prep / Mark Ready / Collect), and detail link. Actions send signals directly from the card and the board refreshes via 5-second polling.

**Summary statistics:** "4 active orders | 2 waiting  1 in preparation  1 ready for collection" — live-updating.

**Historical orders:** Collapsible section below the kanban with a Flowbite Table of completed/failed workflows, linking to Order Timeline and Audit Report pages.

### Order Timeline — State Machine Visual & Event Timeline

The basic order status card at `/orders/[id]` was replaced with a rich detail page:

**State machine visual:** Horizontal progression showing Placed → In Preparation → Ready → Collected. Completed steps are green with checkmarks; the active step has a highlighted ring; future steps are dimmed.

**Order summary card:** Right-hand panel with case ref, lifecycle status badge, workflow status, start/completion times, and elapsed time.

**Event timeline:** Vertical timeline with coloured dots and connector line. Each step from the audit endpoint shows: label, type badge (Activity / Wait), compliance badge (✓ On time / ⚠ Exceeded), timestamps, duration, and SysML-derived target. Active steps pulse; pending steps show hollow dots.

**Governance integration:** Links to the process model page, full audit report (for completed orders), CDR records, and Temporal Web UI.

### Composite Orders — Architectural Item Documented

A formal deferred item was added for composite orders (multi-item baskets), covering the CSW domain model change (Order → OrderLineItem), workflow orchestration (parent/child workflows), and the clinical analogue: a clinical plan that triggers multiple concurrent linked workflows (blood test request, prescription, monitoring schedule) tracked both individually and as a group.

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
| **7: Order Board & Order Timeline** | **✓ Complete** | **26** |
| 8: Data & insights pages | **Next** | |
| 9: System pages | Planned | |
| 10: Meta model update | Planned | |

**Phase 8 scope:** Records (entity views with tabbed interface), Audit Dashboard (refined governance page), Customer Voice (feedback with star ratings and CDR indicators). All use existing API routes.

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

### New in Session 26

11. **Kanban as operational queue view** — XState lifecycle states directly map to kanban columns. The state machine model determines the board structure. Inline signal actions advance orders through the lifecycle from the board itself, without navigating to a detail page. Validates the pattern for clinical pathway dashboards.
12. **Audit-as-timeline data source** — The audit endpoint (designed for compliance reporting in Phase D) provides sufficient step-by-step timing data for the event timeline view. No separate timeline endpoint was needed. Model-derived timing targets appear as compliance badges inline with each step.
13. **Process + domain + governance unified view** — The Order Timeline combines Temporal process state (workflow status), XState domain state (lifecycle position), and governance data (compliance assessment against SysML model annotations) in a single page. This three-source unification pattern is directly applicable to the clinical patient timeline.

---

## 6. Technical Findings (Cumulative)

### Frontend (Sessions 23–26)

- **Tailwind v4 + Flowbite Svelte 1.31.0** works well with Svelte 5.53.7
- **Flowbite Modal `slot="footer"`** does not render — use in-body buttons with `border-t` separator
- **Flowbite Table, Badge, Button, Alert, Select, Input, Label, Spinner, Modal, Card** all work correctly
- **Dark mode** requires CSS overrides with `!important` for Flowbite Input/Select components
- **Layout max-width** at `7xl` (1280px) accommodates split-view pages
- **Temporal sandbox** requires selective imports when `@coffeeshop/shared` barrel export pulls in Node.js modules (pg)
- **SSR barrel export failure** (Session 26): importing from `@coffeeshop/shared` barrel on page components causes 500 during SSR — same transitive `pg` dependency issue. Fix: import directly from specific module paths (e.g. `@coffeeshop/shared/dist/workflow-constants.js`)

### Architecture (cumulative)

- **SvelteKit load functions** — right boundary for stable reference data; client-side polling for dynamic operational data
- **Phase 3 API design was comprehensive** — zero backend changes needed across Phases 5, 6, and 7
- **Audit endpoint serves dual purpose** — compliance reporting (Phase D) and event timeline (Phase 7)
- **`@coffeeshop/shared` barrel export is a growing liability** — multiple consumers (Temporal worker, SSR, client) have incompatible module resolution constraints. Package splitting is the long-term fix.

---

## 7. Knowledge Layer Increment Status

| Increment | Status | Landing zone |
|---|---|---|
| 1: Constraint evaluation at pathway step | **Unblocked** (Session 26) | Order Timeline page (Phase 7 ✓) |
| 2: Decision table for drink routing | **Unblocked** (Session 24) | Counter page (Phase 5 ✓) |
| 3: System self-assessment dashboard | Not started | System Status page (Phase 9) |
| 4: OptionEvaluator / "Help Me Choose" | Not started | Counter page (after Increments 1–3) |
| Catalogue constraint: cannot discontinue with active orders | **Unblocked** (Session 25) | Manager GUI (Phase 6 ✓) |

---

## 8. Immediate Next Steps

1. **Phase 8 detailed implementation plan** — create at start of next session
2. **Phase 8 execution** — Records, Audit Dashboard, and Customer Voice pages
3. Continue through Phases 9–10 to complete the CSW Extension workstream

---

## 9. Strategic Position

The project is 26 sessions in, with a 72-package SysML v2 model and a running demonstrator that now covers the full operational surface: order placement (Counter), operational queue management (Order Board kanban), individual order tracking with governance compliance (Order Timeline), reference data management (Manager GUI), clinical data (Records, Governance, Feedback), and system visibility (Pathway, System Status — placeholder).

The CSW Extension workstream is past the 70% mark (7 of 10 phases complete). The remaining phases are frontend-only (8–9) plus the meta model consolidation (10). Two of three Knowledge Layer Increments are now unblocked with their UI landing zones built (Increment 1: Order Timeline, Increment 2: Counter page).

The model-driven architecture continues to validate: each new UI capability is built on top of the existing API layer, which was derived from the domain model, which is expressed in SysML. The generation chain is intact. The governance integration — SysML model annotations surfacing as compliance badges in the operational view — demonstrates the thesis that the model drives the execution layer in a meaningful, auditable way.

---

*Strategic snapshot prepared 14 March 2026. Session 26.*
