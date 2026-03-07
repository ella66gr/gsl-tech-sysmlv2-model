# GenderSense SysML v2 Modelling — Session Report

## 7 March 2026 (Session 4)

**Purpose:** Comprehensive progress report for continuity into the next chat session. This session completed CDR Exercise Phase C — Querying and Entity Views — implementing AQL queries, SvelteKit entity-view endpoints, a form-driven feedback submission path (outside any workflow), and a process-view vs entity-view comparison endpoint demonstrating the "two views onto the same data" architecture principle.

---

## 1. Session Objectives and Outcomes

### 1.1 Objectives set at session start

Complete CDR Exercise Phase C: write and test AQL queries, implement entity-view API endpoints in SvelteKit, implement a customer feedback form (form-driven data entry outside workflows), and demonstrate both process-view (Temporal) and entity-view (CDR) perspectives on the same order data.

### 1.2 Completed

- **Step C1 — AQL queries:** Four AQL queries written and tested. Three work correctly (all orders, per-customer orders, orders today). The fourth (aggregate with COUNT/GROUP BY) is not supported by EHRbase 2.11.0 — returns HTTP 400. Finding documented: use application-level aggregation
- **Step C2 — Entity-view API endpoints:** Four SvelteKit endpoints implemented, all querying EHRbase via AQL:
  - `GET /api/entity/orders` — all orders across all customers
  - `GET /api/entity/orders/today` — today's orders (date-filtered)
  - `GET /api/entity/customers/[ehrId]/orders` — per-customer order history
  - `GET /api/entity/feedback` — all feedback compositions (entity view)
- **Step C3 — Feedback form (form-driven data entry):**
  - CUSTOMER_FEEDBACK archetype designed in Archetype Designer (EVALUATION class, Rating/Comment/Order reference)
  - Template `coffeeshop-feedback-composition.v1` created and OPT exported (Firefox) and uploaded to EHRbase
  - `feedback-composition-builder.ts` — canonical JSON composition builder for feedback
  - `POST /api/entity/feedback` — form submission endpoint that commits directly to CDR (no Temporal)
  - `/feedback` page — SvelteKit form with rating, comment, order reference; includes entity view of all feedback
  - Three test feedback submissions verified: all appear in entity view via AQL
- **Step C4 — Process view vs entity view comparison:**
  - `GET /api/compare/[orderId]` — retrieves both Temporal workflow state and CDR composition data in a single response
  - Verified with order `order-1772909977318`: process view shows COMPLETED/collected; entity view shows the order composition committed by the workflow activity
  - Both views reflect the same underlying event, from different perspectives
- **Entity Views UI page** (`/entity`) — browse all orders, today's orders, or per-customer orders from the CDR
- **Navigation updated** — nav bar now includes Entity Views and Feedback links
- **EHRbase client singleton** for SvelteKit (`$lib/server/ehrbase.ts`) — mirrors the Temporal client singleton pattern
- **Centralised AQL queries module** (`$lib/server/aql-queries.ts`) — all entity-view queries in one place
- **Cross-path data demonstrated:** Customer "Iris" has both an order composition (committed by Temporal workflow activity) and feedback compositions (committed by form endpoint) in the same EHR — the CDR does not distinguish how data arrived

### 1.3 Not started

- CDR Exercise Phase D (governance audit — population-level data completeness query)
- CDR Exercise Phase E (SysML model updates)
- PREPARATION_EVENT archetype (ACTION class) — needed for prepareDrink CDR commit and governance audit

---

## 2. Repository State

### 2.1 Repository

- **GitHub:** `ella66gr/gsl-tech-sysmlv2-model`
- **Local path:** `~/Developer/gsl-tech/gsl-sysml-model/`

### 2.2 Files created/modified this session

| File | Purpose |
|---|---|
| `packages/shared/src/feedback-composition-builder.ts` | **New.** Canonical JSON composition builder for customer feedback |
| `packages/shared/src/index.ts` | **Modified.** Added re-exports for feedback-composition-builder |
| `packages/web/src/lib/server/ehrbase.ts` | **New.** EHRbase client singleton for SvelteKit server endpoints |
| `packages/web/src/lib/server/aql-queries.ts` | **New.** Centralised AQL query definitions for entity views |
| `packages/web/src/routes/+layout.svelte` | **Modified.** Added Entity Views and Feedback nav links |
| `packages/web/src/routes/entity/+page.svelte` | **New.** Entity Views UI page — browse orders from CDR |
| `packages/web/src/routes/feedback/+page.svelte` | **New.** Customer feedback form and feedback entity view |
| `packages/web/src/routes/api/entity/orders/+server.ts` | **New.** GET all orders entity view |
| `packages/web/src/routes/api/entity/orders/today/+server.ts` | **New.** GET today's orders entity view |
| `packages/web/src/routes/api/entity/customers/[ehrId]/orders/+server.ts` | **New.** GET per-customer orders entity view |
| `packages/web/src/routes/api/entity/feedback/+server.ts` | **New.** POST feedback submission + GET feedback entity view |
| `packages/web/src/routes/api/compare/[orderId]/+server.ts` | **New.** GET process-view vs entity-view comparison |
| `packages/temporal/src/test/test-aql-queries.ts` | **New.** Standalone AQL query test script |
| `exercises/coffeeshop-demonstrator/ehrbase/coffeeshop-feedback-composition.v1.opt` | **New.** OPT for feedback template (exported from Archetype Designer via Firefox) |

All paths relative to `exercises/coffeeshop-demonstrator/`.

### 2.3 No SysML model changes

No `.sysml` files were modified. The syntax reference remains at v3.3.

### 2.4 Git commit recommended

**CDR Exercise Phase C complete** — AQL queries, entity-view endpoints, feedback form, comparison endpoint, feedback OPT, session report.

---

## 3. Phase C Exit Criteria — All Met

| Criterion | Status | Evidence |
|---|---|---|
| C1: AQL queries written and tested | Done | 3 of 4 queries pass; aggregate (COUNT/GROUP BY) not supported by EHRbase 2.11.0 — documented finding |
| C2: Entity-view API endpoints implemented | Done | 4 endpoints return correct data from CDR via AQL |
| C3: Feedback form works outside workflow | Done | Form submits feedback compositions directly to CDR; data appears in entity views |
| C4: Process view and entity view compared | Done | Comparison endpoint returns both views for same order; both reflect same underlying event |

---

## 4. Key Findings

### 4.1 EHRbase 2.11.0 does not support AQL aggregate functions

The query using `COUNT(c/uid/value)` with `GROUP BY` returns HTTP 400. This means population-level analytics queries (e.g. "how many orders by drink type") must use application-level aggregation: query the raw data via AQL, then aggregate in TypeScript.

**Implication for GenderSense:** Clinical analytics queries ("how many patients on each hormone regimen", "average time to first monitoring bloods") will likely need application-level aggregation rather than pure AQL. This is a practical consideration but not a limitation — the CDR provides the queryable data, the application layer does the counting. Some commercial openEHR CDR implementations may support aggregate AQL.

### 4.2 Form-driven data entry produces identical CDR data to workflow-committed data

The feedback compositions committed by the form endpoint (`POST /api/entity/feedback`) are structurally identical to the order compositions committed by the Temporal `validateOrder` activity. Both use canonical JSON format, both are validated against their templates by EHRbase, and both are queryable via the same AQL patterns.

**Implication for GenderSense:** Patient questionnaires, clinician ad-hoc notes, and administrative data entered outside any pathway produce the same structured, queryable data as pathway-driven clinical observations. The CDR is pathway-agnostic — it stores compositions regardless of how they were committed.

### 4.3 Single EHR collects data from multiple paths

Customer "Iris" has both order compositions (from workflow) and feedback compositions (from form) in the same EHR. The entity view retrieves both by querying the appropriate archetype/template within that EHR. The CDR organises data by type, not by source.

**Implication for GenderSense:** A patient's EHR will accumulate data from pathway activities, direct form entry, external system integrations (lab results, GP letters), and patient self-assessments — all queryable by type. The entity view is the natural way for clinicians to browse a patient's record ("show me all blood results", "show me all prescriptions") regardless of which pathway or process produced the data.

### 4.4 EVALUATION archetype structure differs from OBSERVATION

The EVALUATION RM class has a simpler data structure than OBSERVATION. OBSERVATION wraps data in HISTORY → POINT_EVENT → ITEM_TREE, while EVALUATION goes directly to ITEM_TREE (data). The AQL paths reflect this:
- OBSERVATION: `c/content[...]/data[at0001]/events[at0002]/data[at0003]/items[at0005]/value/value`
- EVALUATION: `c/content[...]/data[at0001]/items[at0002]/value/value`

This is correct openEHR behaviour — OBSERVATION models things that happen over time (events with timestamps), while EVALUATION models judgements/assessments (a single data tree).

### 4.5 Comparison endpoint demonstrates the architecture principle

The `GET /api/compare/[orderId]` endpoint concretely demonstrates the separation principle from the architecture document:
- **Process view** (Temporal): workflow status, lifecycle state, start/close timestamps — shows WHERE the order is
- **Entity view** (EHRbase): composition data with drink details, prices, timestamps — shows WHAT was ordered

These are complementary, not competing. A clinical user needs both: "Where is this patient in their pathway?" (process view) and "What are this patient's blood results?" (entity view).

### 4.6 Temporal worker requires compiled JS for workflow bundling

Running the worker with `npx tsx` (TypeScript execution) fails because Temporal's workflow bundler resolves `workflowsPath` to a `.js` file within the V8 isolate. The worker must be run from compiled output: `pnpm --filter @coffeeshop/temporal build` then `node packages/temporal/dist/workers/worker.js`. Activities run in normal Node.js and are fine either way.

---

## 5. Architecture Patterns Validated

### 5.1 Two views onto the same data

The comparison endpoint proves this concretely. A single order placed by a customer is visible as:
- A Temporal workflow execution (process view): status, state transitions, timing
- An openEHR composition in the CDR (entity view): structured data, queryable by type

Neither view is primary. They serve different purposes and different user needs.

### 5.2 Form-driven data entry alongside workflow-committed data

The feedback form proves that the CDR accepts data from any source, not just workflows. The data is identical in structure and queryability. This is essential for GenderSense where not all clinical data enters via pathways.

### 5.3 Entity views as query templates

Each entity-view endpoint is essentially an AQL query paired with a JSON transformation. The pattern is mechanical:
1. Define an AQL query selecting specific archetype paths
2. Execute via the EHRbase client
3. Map result rows to a response DTO
4. Return as JSON

For GenderSense, each entity view ("blood results", "prescriptions", "assessments") follows this same pattern. The AQL paths change to match the clinical archetypes, but the plumbing is identical.

---

## 6. Design Decisions

### 6.1 Separate API route tree for entity views

Entity-view endpoints are under `/api/entity/` to clearly distinguish them from process-view endpoints under `/api/orders/`. This makes the architectural separation visible in the URL structure:
- `/api/orders/*` — process view (queries Temporal)
- `/api/entity/*` — entity view (queries CDR)
- `/api/compare/*` — both views combined

### 6.2 EHRbase client singleton pattern

The `$lib/server/ehrbase.ts` module mirrors the existing `$lib/server/temporal.ts` pattern: a module-level variable initialised on first use. Both are server-only (in the `$lib/server/` directory) so they're never bundled into client-side code.

### 6.3 Centralised AQL queries

All AQL query strings are defined in `$lib/server/aql-queries.ts` rather than inline in each endpoint. This keeps the queries maintainable and makes it easy to see all entity-view queries in one place. The archetype constants and path fragments are shared across queries.

### 6.4 Feedback composition uses EVALUATION (not OBSERVATION)

EVALUATION is the correct RM class for feedback — it represents a judgement/assessment, not a time-series observation. This exercises a different RM class and different AQL path structure from the ORDER_RECORD OBSERVATION, which validates that the CDR integration pattern works across RM classes.

### 6.5 Application-level aggregation for analytics

Given EHRbase 2.11.0's lack of aggregate AQL support, analytics queries will fetch raw data and aggregate in TypeScript. This is actually the more flexible pattern — complex analytics often need application-level logic beyond what AQL can express.

---

## 7. Archetype and Template Reference

### 7.1 ORDER_RECORD (designed Phase A, session 1)

**Archetype ID:** `openEHR-EHR-OBSERVATION.order_record.v0`
**RM class:** OBSERVATION
**Template:** `coffeeshop-order-composition.v1`
**Composition archetype:** `openEHR-EHR-COMPOSITION.order_composition.v0`

| Element | Node ID | Data type | Coded terms |
|---|---|---|---|
| Data root (History) | at0001 | HISTORY | — |
| Any event | at0002 | POINT_EVENT | — |
| Tree | at0003 | ITEM_TREE | — |
| Drink name | at0005 | DV_CODED_TEXT | Coffee (at0010), Tea (at0011) |
| Drink size | at0006 | DV_CODED_TEXT | Small (at0007), Medium (at0008), Large (at0009) |
| Milk choice | at0012 | DV_CODED_TEXT | None (at0013), Whole milk (at0014), Semi-skimmed milk (at0015), Oat milk (at0016), Soy milk (at0017) |
| Extras | at0018 | DV_TEXT | Free text |
| Price | at0019 | DV_CODED_TEXT | £1.25 (at0020), £1.75 (at0021), £2.30 (at0022), £2.85 (at0023) |

### 7.2 CUSTOMER_FEEDBACK (designed this session)

**Archetype ID:** `openEHR-EHR-EVALUATION.customer_feedback.v0`
**RM class:** EVALUATION
**Template:** `coffeeshop-feedback-composition.v1`
**Composition archetype:** `openEHR-EHR-COMPOSITION.feedback_composition.v0`

| Element | Node ID | Data type | Coded terms |
|---|---|---|---|
| Data root (Item tree) | at0001 | ITEM_TREE | — |
| Rating | at0002 | DV_CODED_TEXT | 1 star (at0005), 2 stars (at0006), 3 stars (at0007), 4 stars (at0008), 5 stars (at0009) |
| Comment | at0003 | DV_TEXT | Free text |
| Order reference | at0004 | DV_TEXT | Free text (order ID or composition UID) |

**Note:** The "5 stars" term description has a typo ("Excelent" instead of "Excellent") in Archetype Designer. Not corrected — exercise data, and correction would require archetype edit → OPT re-export → database reset (per Phase A finding 4.5).

### 7.3 PREPARATION_EVENT (not yet designed)

**Planned archetype ID:** `openEHR-EHR-ACTION.preparation_event.v0`
**Planned RM class:** ACTION
**Planned template:** `coffeeshop-preparation-composition.v1`

Required for Phase D governance audit. Needs to be designed in Archetype Designer before Phase D can proceed.

### 7.4 Templates in EHRbase

| Template ID | Archetype | Uploaded |
|---|---|---|
| `coffeeshop-order-composition.v1` | ORDER_RECORD (OBSERVATION) | Phase A |
| `coffeeshop-feedback-composition.v1` | CUSTOMER_FEEDBACK (EVALUATION) | This session |

---

## 8. Test Data State

### 8.1 EHRs in EHRbase

| Subject / Customer | EHR ID | Data |
|---|---|---|
| Phase B test customers | `08ab3485...`, `9c6e8eea...`, `73f3c25f...` | Order compositions from integration tests |
| Iris | `f1eaf17b-e331-4b03-9ee4-a44eed8f4c58` | 1 order (workflow) + 1 feedback (form) |
| Feedback test customers | `ec99ab44...`, `bed84c0c...` | Feedback compositions (form) |

---

## 9. Syntax Reference Status

**No changes to the syntax reference this session.** The syntax reference remains at v3.3 (6 March 2026). No SysML patterns were tested or verified during this session as the work was focused on TypeScript CDR integration, AQL queries, and SvelteKit endpoints.

File: `documentation/gsl-sysml-v2-syntax-reference-v3.3-2026-03-06.md`

---

## 10. Companion Documents

These documents are current as of this session and should be available to the next session:

1. **`gsl-sysml-v2-syntax-reference-v3.3-2026-03-06.md`** — Living syntax reference, unchanged this session
2. **`gsl-platform-architecture-principles.md`** — Separation principle, openEHR CDR, governance patterns
3. **`gsl-platform-sysml-modelling-strategy.md`** — Comprehensive modelling rationale
4. **`gsl-platform-package-hierarchy-proposal.md`** — Tree diagram of the package hierarchy
5. **`gsl-plan-coffeeshop-cdr-exercise-2026-03-06.md`** — CDR extension exercise plan
6. **`gsl-session-report-2026-03-07-s1.md`** — Session 1 report (EHRbase setup, archetype design, OPT blocker)
7. **`gsl-session-report-2026-03-07-s2.md`** — Session 2 report (Phase A completion, typo correction, template re-deployment)
8. **`gsl-session-report-2026-03-07-s3.md`** — Session 3 report (Phase B completion, Temporal-EHRbase integration)
9. **`gsl-session-report-2026-03-07-s4.md`** — This report (Phase C completion, entity views, feedback form, comparison)

---

## 11. Recommended Next Steps

### 11.1 Immediate: Git commit Phase C milestone

Commit all new files (feedback builder, entity-view endpoints, feedback form, comparison endpoint, AQL test, feedback OPT) and this session report.

### 11.2 Near-term: Phase D — Governance audit

Population-level data completeness query: "Does every order that has been completed also have a preparation event recorded?" This requires:
1. Design PREPARATION_EVENT archetype (ACTION class) in Archetype Designer
2. Create template, export OPT (Firefox), upload to EHRbase
3. Modify `prepareDrink` activity to commit preparation compositions
4. Seed test data: run several orders through the workflow, deliberately leaving some without preparation events
5. Implement governance audit query (application-level join of order and preparation compositions)
6. Produce governance report (JSON/HTML)

**Dependency:** PREPARATION_EVENT archetype and template must be designed before the governance audit can query for them.

### 11.3 Near-term: Full Temporal workflow test with CDR live

The order workflow now commits order compositions to EHRbase as part of normal execution (verified this session with order-1772909977318). The next step is to also commit preparation compositions from the `prepareDrink` activity, which requires the PREPARATION_EVENT archetype.

### 11.4 Medium-term: Phase E — SysML model updates

Record CDR integration patterns in the SysML model:
- `@OpenEhrArchetype` metadata def pattern
- Platform::EHR package elaboration
- Exercise summary with recommendations for clinical CDR integration

---

## 12. Working Practices Reminder

- **Syntax reference first:** Now at `documentation/gsl-sysml-v2-syntax-reference-v3.3-2026-03-06.md`
- **Version the syntax reference:** Bump version at the start of any session that adds verified findings
- **Verify in Syside:** All new SysML patterns tested and results captured
- **Phase exit criteria:** Document what was verified, what traps were found, TODO list updated
- **Git commits at checkpoints:** Commit when work is known-good
- **MCP filesystem access:** Claude has access to `~/Developer/gsl-tech/` and reads/writes files directly. Ella runs shell commands and pastes output back
- **Syside Modeler version:** 0.8.5 (VS Code extension, 1 March 2026)
- **Development environment:** macOS (MacBook Pro), Python 3.12, VS Code, Node v25.7.0, pnpm v10.30.3
- **EHRbase version:** 2.11.0 (Docker). PostgreSQL 16.2 (Docker). Pinned — do not upgrade mid-exercise
- **Archetype Designer:** Use Firefox for OPT export (Chrome hangs). Edit terms in the archetype, not the template
- **Monorepo:** All GenderSense development artefacts in `gsl-sysml-model/`
- **Docker commands:** Run from `exercises/coffeeshop-demonstrator/` with `-f docker-compose.ehrbase.yml`
- **EHRbase auth:** `ehrbase-user` / `SuperSecretPassword` (basic auth)
- **EHRbase API base:** `http://localhost:8080/ehrbase/rest/openehr/v1/`
- **EHRbase namespace pattern:** `[a-zA-Z][a-zA-Z0-9-_:/&+?]*` — no dots allowed
- **EHRbase composition commit:** Returns 204 with `Prefer: return=minimal`; UID in ETag header
- **EHRbase aggregate AQL:** COUNT/GROUP BY not supported in 2.11.0 — use application-level aggregation
- **TypeScript strict mode:** `exactOptionalPropertyTypes: true` — use conditional spread for optional fields
- **Temporal worker:** Must be run from compiled JS (`node dist/workers/worker.js`), not via `npx tsx`

---

*Report generated at end of session 7, 7 March 2026. For use as context in subsequent chat session.*
