# GenderSense SysML Model — Strategic Snapshot

**Date:** 14 March 2026 (Session 27)
**Prepared by:** Claude (from direct review of the complete codebase and session 27 conversation)
**Scope:** The `gsl-sysml-model` project in its entirety — model, generators, demonstrator, documentation, development practice
**Changes from previous version:** CSW Extension Phase 8 (Data & Insights pages) complete. No SysML model changes. No backend changes.

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
| 26 | CSW Extension Phase 7 (Order Board kanban & Order Timeline) |
| **27** | **CSW Extension Phase 8 (Data & Insights — Records, Audit Dashboard, Customer Voice)** |

---

## 3. What Was Built in Session 27

### Records Page — Tabbed Entity View with Record Cards

The manual-trigger entity query page was replaced with a polished tabbed interface:

**Tabbed navigation:** Three tabs (All Orders / Today / By Customer) with auto-loading on mount and tab switch. The "By Customer" tab shows an inline EHR ID input.

**Record cards:** Orders display as visual cards in a responsive 3-column grid showing drink name, size, milk choice (filtered to hide "None"), price, relative timestamp, and abbreviated EHR ID. A card/table view toggle allows switching to the traditional Flowbite Table layout.

**AQL query details:** Collapsible panel showing query type, clinical analogy, and archetype identifier per tab.

**CDR source badge:** Indigo `CDR · EHRbase` badge in the header — visual distinction from operational/management pages.

### Audit Dashboard — Auto-Loading Compliance Gauge

The manual "Run Governance Audit" button was replaced with auto-loading:

**Auto-load on mount:** Audit runs automatically on page arrival. Subtle "↻ Refresh" link for re-running.

**Compliance progress bar:** Horizontal bar (green/yellow/red) replacing the plain percentage text. Uses `$derived` reactive declarations to avoid Svelte 5's `{@const}` placement constraint.

**Governance question banner:** Elevated to a prominent bordered panel with clinical analogy.

**Layout refinement:** Five-card summary grid with conditional colouring for Data Gaps and Compliance Rate.

### Customer Voice — Visual Star Ratings and Split-View

The feedback page was restructured into a split-view with visual enhancements:

**Star rating input:** Five interactive star buttons with hover preview and text label, replacing the `<Select>` dropdown.

**Split-view layout:** Submit form (left, fixed-width) and auto-loading feedback list (right, flexible). Stacks vertically on mobile.

**Feedback cards:** Visual star display, quoted comments in italics, relative timestamps, CDR metadata.

**Full form clearing:** All fields including customer name now reset after submission.

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
| **8: Data & Insights pages** | **✓ Complete** | **27** |
| 9: System pages | **Next** | |
| 10: Meta model update | Planned | |

**Phase 9 scope:** Process Model (interactive pathway SVG with step highlighting and metadata modals), System Status (infrastructure health indicators, structural inventory, placeholder self-assessment panel, catalogue statistics). Landing zone for Knowledge Layer Increment 3.

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

### New in Session 27

14. **CDR source provenance badges** — Entity-view pages carry a visible `CDR · EHRbase` indigo badge, visually distinguishing them from operational pages (Temporal/PostgreSQL) and management pages (PostgreSQL). This communicates the three-persistence-layer architecture to the user without being heavy-handed. Applicable to the clinical system where clinicians need to understand which data source they are viewing.

15. **Auto-loading entity views** — CDR data loads on page mount rather than requiring manual query execution. This shifts the entity-view pages from "CDR exercise tool" to "operational data view" — the same data, but presented as part of the normal application flow. The clinical analogue: a clinician navigating to "Lab Results" sees results immediately, not a "Run Query" button.

---

## 6. Technical Findings (Cumulative)

### Frontend (Sessions 23–27)

- **Tailwind v4 + Flowbite Svelte 1.31.0** works well with Svelte 5.53.7
- **Flowbite Modal `slot="footer"`** does not render — use in-body buttons with `border-t` separator
- **Flowbite Table, Badge, Button, Alert, Select, Input, Label, Spinner, Modal, Card** all work correctly
- **Dark mode** requires CSS overrides with `!important` for Flowbite Input/Select components
- **Layout max-width** at `7xl` (1280px) accommodates split-view pages
- **Temporal sandbox** requires selective imports when `@coffeeshop/shared` barrel export pulls in Node.js modules (pg)
- **SSR barrel export failure** (Session 26): importing from `@coffeeshop/shared` barrel on page components causes 500 during SSR — same transitive `pg` dependency issue. Fix: import directly from specific module paths
- **Svelte 5 `{@const}` placement** (Session 27): `{@const}` must be inside `{#if}`, `{#each}`, or similar control flow blocks — not at the top level of a template. Use `$derived` in the script block for top-level computed values
- **CDR "None" milk choice** (Session 27): AQL returns "None" as a string for the milk choice coded term. Display-layer filtering via `displayMilk()` helper

### Architecture (cumulative)

- **SvelteKit load functions** — right boundary for stable reference data; client-side polling for dynamic operational data
- **Phase 3 API design was comprehensive** — zero backend changes needed across Phases 5, 6, 7, and 8
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

1. **Phase 9 detailed implementation plan** — create at start of next session
2. **Phase 9 execution** — Process Model and System Status pages
3. Continue to Phase 10 (meta model update) to complete the CSW Extension workstream

---

## 9. Strategic Position

The project is 27 sessions in, with a 72-package SysML v2 model and a running demonstrator that now covers the full operational and data surface: order placement (Counter), operational queue management (Order Board kanban), individual order tracking with governance compliance (Order Timeline), reference data management (Manager GUI), CDR data exploration (Records), population-level governance auditing (Audit Dashboard), form-driven data entry (Customer Voice), and system visibility (Pathway, System Status — placeholder).

The CSW Extension workstream is at the 80% mark (8 of 10 phases complete). The remaining phases are: Phase 9 (System pages — the final frontend phase, and landing zone for KL Increment 3) and Phase 10 (meta model consolidation). Two of three Knowledge Layer Increments are now unblocked with their UI landing zones built.

The API layer has proven remarkably durable: zero backend changes were needed across Phases 5, 6, 7, and 8 (four consecutive phases). The 17 API routes built in Phases A–D and Phase 3 have served every subsequent frontend need. This validates the model-first approach: the domain model drives the API design, and a well-designed API layer supports multiple frontend consumers without modification.

The three-persistence-layer architecture is now visually communicated in the application itself via the indigo CDR source badges on entity-view pages — a small but meaningful UX pattern that demonstrates how the system's architecture can be made visible to its users.

---

*Strategic snapshot prepared 14 March 2026. Session 27.*
