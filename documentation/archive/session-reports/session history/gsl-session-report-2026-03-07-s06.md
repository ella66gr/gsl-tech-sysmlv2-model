# GenderSense SysML v2 Modelling — Session Report

## 7 March 2026 (Session 3)

**Purpose:** Comprehensive progress report for continuity into the next chat session. This session completed CDR Exercise Phase B — Temporal integration — implementing a TypeScript EHRbase client, a canonical JSON composition builder, modified workflow activities that commit compositions to the CDR, and a standalone end-to-end integration test proving the full round-trip.

---

## 1. Session Objectives and Outcomes

### 1.1 Objectives set at session start

Complete CDR Exercise Phase B: implement the EHRbase client module, composition builder, modify workflow activities to commit compositions to the CDR, and verify end-to-end integration.

### 1.2 Completed

- **Step B1 — `ehrbase-client.ts`:** TypeScript REST API client wrapping EHRbase's openEHR REST API. Provides `createEhr`, `getOrCreateEhr`, `commitComposition`, `getComposition`, and `executeAql` operations. Uses canonical JSON format, basic auth, and default configuration matching the docker-compose setup
- **Step B2 — `composition-builder.ts`:** Canonical JSON composition builder that maps application-level order details to the archetype's internal coded terminology. Includes lookup tables for drink names (with common variant mapping, e.g. "flat white" → Coffee), sizes, milk choices, and prices. Enforces exact term text matching (lesson from Phase A "Oak milk" typo)
- **Step B3 — Modified `validateOrder` activity:** The activity now (1) gets or creates an EHR for the customer, (2) builds an order composition from the order details, (3) commits the composition to EHRbase, and (4) returns the EHR ID and composition UID alongside the existing validation result. Temporal's retry semantics handle transient CDR failures
- **Step B4 — End-to-end integration test:** Standalone test script exercising all six operations: EHR creation, composition building, composition commit, round-trip retrieval, AQL entity-view query, and getOrCreateEhr idempotency. All checks passed
- **`OrderDetails` interface extended:** Added optional `milkChoice` and `extras` fields for CDR composition building, backward-compatible with existing workflow callers
- **`@coffeeshop/shared` index updated:** New modules re-exported with explicit type exports for `verbatimModuleSyntax` compliance

### 1.3 Not started

- CDR Exercise Phases C–E (querying/forms, governance audit, model updates)
- Full Temporal workflow test with CDR integration live (worker + client script with EHRbase running)
- PREPARATION_EVENT and CUSTOMER_FEEDBACK archetypes (prerequisites for prepareDrink CDR commit and form-driven data entry)

---

## 2. Repository State

### 2.1 Repository

- **GitHub:** `ella66gr/gsl-tech-sysmlv2-model`
- **Local path:** `~/Developer/gsl-tech/gsl-sysml-model/`

### 2.2 Files created/modified this session

| File | Purpose |
|---|---|
| `packages/shared/src/ehrbase-client.ts` | **New.** EHRbase REST API client — EHR CRUD, composition commit, AQL query |
| `packages/shared/src/composition-builder.ts` | **New.** Canonical JSON composition builder with archetype term mappings |
| `packages/shared/src/index.ts` | **Modified.** Added re-exports for ehrbase-client and composition-builder |
| `packages/temporal/src/activities/barista.ts` | **Modified.** validateOrder now commits order composition to CDR |
| `packages/temporal/src/test/test-cdr-integration.ts` | **New.** Standalone end-to-end CDR integration test |

All paths relative to `exercises/coffeeshop-demonstrator/`.

### 2.3 No SysML model changes

No `.sysml` files were modified. The syntax reference remains at v3.3.

### 2.4 Git commit recommended

**CDR Exercise Phase B complete** — EHRbase client, composition builder, modified activity, integration test, session report.

---

## 3. Phase B Exit Criteria — All Met

| Criterion | Status | Evidence |
|---|---|---|
| B1: EHRbase client module implemented | Done | `ehrbase-client.ts` compiles, exports via `@coffeeshop/shared` |
| B2: Composition builder implemented | Done | `composition-builder.ts` builds valid canonical JSON, accepted by EHRbase |
| B3: validateOrder commits to CDR | Done | Activity creates EHR, builds composition, commits — compiles clean |
| B4: End-to-end integration test passes | Done | All 6 checks pass: create EHR, build, commit, retrieve, AQL query, idempotency |

---

## 4. Key Findings

### 4.1 EHRbase namespace validation regex

EHRbase validates the `namespace` field on `PARTY_REF.external_ref` against the pattern `[a-zA-Z][a-zA-Z0-9-_:/&+?]*`. Dots are **not** allowed. The initial attempt using `coffeeshop.customer` was rejected with HTTP 400. Changed to `coffeeshop-customer`.

**Implication for GenderSense:** When designing subject namespaces for patient EHR references (e.g. NHS number namespace), use hyphens or colons as separators, not dots. Example: `gendersense-patient` or `nhs-number`.

### 4.2 Composition commit returns 204 with Prefer: return=minimal

When `Prefer: return=minimal` is set on a composition commit request, EHRbase returns **HTTP 204 No Content** rather than 200 or 201. The composition UID is available in the **ETag** header (quoted, format `"uid::nodeName::version"`) and the **Location** header. The response body is empty.

This is correct HTTP semantics (204 = success with no body) but differs from the openEHR REST API specification which suggests 201 Created. The client must accept 200, 201, and 204 as success codes for composition commit.

**Implication for GenderSense:** Any CDR client code must handle 204 as a success status for composition operations. The ETag header is the most reliable source for the composition UID.

### 4.3 exactOptionalPropertyTypes requires conditional property inclusion

The project's `tsconfig.base.json` includes `exactOptionalPropertyTypes: true`, which means that optional properties typed as `prop?: T` cannot be assigned the value `undefined` — the property must either be absent or have a value of type `T`. This is stricter than the default TypeScript behaviour.

Two patterns encountered:
1. **fetch RequestInit body:** Cannot pass `body: undefined`. Solution: build the options object without `body`, then conditionally add it.
2. **Optional interface fields:** Cannot spread `{ milkChoice: order.milkChoice }` when `milkChoice` is `string | undefined`. Solution: conditional spread `...(order.milkChoice !== undefined && { milkChoice: order.milkChoice })`.

**Implication for GenderSense:** This is a useful strictness setting that catches real bugs (accidentally passing undefined where a value is expected). Keep it enabled. Adopt the conditional spread pattern as the standard approach for optional field forwarding.

### 4.4 Composition builder term mapping pattern

The composition builder maps application-level values (e.g. `drinkType: "flat white"`) to archetype coded terms (e.g. `{ code: "at0010", text: "Coffee" }`). This is done via lookup tables keyed by the application value.

This pattern works well for the coffee shop's small terminology but would not scale to clinical archetypes with hundreds of terms. For GenderSense, the mapping should be generated from the OPT or archetype definition rather than hand-maintained.

### 4.5 EHR creation with subject reference enables idempotent lookup

Creating an EHR with an `external_ref` (subject ID + namespace) allows subsequent lookup via `GET /ehr?subject_id=X&subject_namespace=Y`. This enables the `getOrCreateEhr` pattern where activities can safely call the client without worrying about whether the customer already has an EHR. EHRbase returns 200 with the existing EHR if found, or the client falls through to create a new one.

**Implication for GenderSense:** Patient registration should create the EHR with the NHS number (or internal patient ID) as the subject reference. All subsequent pathway activities use `getOrCreateEhr` with the same reference, making EHR resolution idempotent.

### 4.6 Composition UID format

EHRbase returns composition UIDs in the format `{uuid}::{nodeName}::{version}`, e.g. `74a4f9fb-e64e-42b0-9a25-564e75f43108::coffeeshop.local::1`. The `nodeName` matches the `SERVER_NODENAME` from the EHRbase Docker configuration. The version starts at 1 and increments on updates.

---

## 5. Test Data Reference

### 5.1 Test EHRs created this session

| Subject ID | Namespace | EHR ID |
|---|---|---|
| `test-customer-b4-{timestamp}` | `coffeeshop-customer` | `9c6e8eea-60a8-4800-a64a-3ee58cc50fa6` |
| `test-customer-b4-{timestamp}-other` | `coffeeshop-customer` | `293cb135-b755-4198-a623-bda0c361ef9e` |

Note: Previous session's test EHR (`08ab3485-...`, subject unlinked) also exists in the database.

### 5.2 Test composition committed

| Field | Value |
|---|---|
| Template | `coffeeshop-order-composition.v1` |
| Composition UID | `74a4f9fb-e64e-42b0-9a25-564e75f43108::coffeeshop.local::1` |
| Drink name | Coffee (at0010) — mapped from "flat white" |
| Drink size | Medium (at0008) |
| Milk choice | Oat milk (at0016) |
| Extras | Extra shot (free text) |
| Price | £2.85 (at0023) — premium price due to extras |
| Composer | Test Script |

### 5.3 AQL query result

Query: entity-view selecting drink_name, drink_size, milk_choice, price for the test EHR.
Result: `["Coffee", "Medium", "Oat milk", "£2.85"]` — 1 row returned.

---

## 6. Architecture Notes

### 6.1 Module placement

The EHRbase client and composition builder are in `@coffeeshop/shared` (not `@coffeeshop/temporal`) because they will also be consumed by the SvelteKit web package in Phase C for entity-view API endpoints and form-driven data entry. The shared package is the correct home for infrastructure that crosses the Temporal/web boundary.

### 6.2 CDR client as activity-level singleton

The `createEhrbaseClient()` call in `barista.ts` creates a single client instance for the worker process. This is efficient (one auth header computation, reusable across activity invocations) and safe (activities run in the normal Node.js environment, not in Temporal's sandboxed V8 isolate).

### 6.3 Temporal retry semantics for CDR failures

If EHRbase is temporarily unavailable when `validateOrder` tries to commit a composition, the activity throws an `EhrbaseError`. Temporal's retry configuration (maximum 3 attempts, as set in the workflow's `proxyActivities` options) handles this automatically. No additional retry logic is needed in the activity code.

### 6.4 prepareDrink CDR commit deferred

The `prepareDrink` activity does not yet commit a composition because the PREPARATION_EVENT archetype and template have not been designed in Archetype Designer. The ORDER_RECORD path proves the integration pattern; the preparation path requires:
1. Design PREPARATION_EVENT archetype (ACTION class) in Archetype Designer
2. Create template, export OPT (Firefox)
3. Upload OPT to EHRbase
4. Add a `buildPreparationComposition()` function to `composition-builder.ts`
5. Modify `prepareDrink` activity to commit

---

## 7. Syntax Reference Status

**No changes to the syntax reference this session.** The syntax reference remains at v3.3 (6 March 2026). No SysML patterns were tested or verified during this session as the work was focused on TypeScript CDR integration code.

File: `documentation/gsl-sysml-v2-syntax-reference-v3.3-2026-03-06.md`

---

## 8. Design Decisions

### 8.1 Default namespace: coffeeshop-customer

EHRbase rejects dots in namespace values. The default subject namespace is `coffeeshop-customer` (hyphen-separated). For GenderSense, use `gendersense-patient` or similar.

### 8.2 Conditional spread for optional properties

With `exactOptionalPropertyTypes: true`, optional properties must not be explicitly set to `undefined`. The pattern `...(value !== undefined && { prop: value })` is used to conditionally include optional fields in object literals. This is adopted as the standard pattern for the project.

### 8.3 Prefer: return=minimal for composition commits

The client sends `Prefer: return=minimal` on composition commits to avoid transferring the full composition back in the response body. The composition UID from the ETag header is sufficient for the activity's needs. This reduces network overhead, especially for large clinical compositions in GenderSense.

### 8.4 Drink type to archetype term mapping

Common drink type strings (flat white, latte, espresso, americano, cappuccino) all map to the Coffee archetype term (at0010). This is a pragmatic mapping for the exercise — the archetype only defines Coffee and Tea as drink categories. For GenderSense, clinical term mappings would be derived from the archetype/OPT rather than hand-maintained lookup tables.

### 8.5 Price determination by size with extras premium

Price is determined by drink size (small=£1.25, medium=£1.75, large=£2.30) unless extras are specified, in which case the premium price (£2.85) is used. This matches the archetype's coded price terms. The logic is simple for the exercise; clinical data would not have this kind of derived pricing.

---

## 9. Companion Documents

These documents are current as of this session and should be available to the next session:

1. **`gsl-sysml-v2-syntax-reference-v3.3-2026-03-06.md`** — Living syntax reference, unchanged this session
2. **`gsl-platform-architecture-principles.md`** — Separation principle, openEHR CDR, governance patterns
3. **`gsl-platform-sysml-modelling-strategy.md`** — Comprehensive modelling rationale
4. **`gsl-platform-package-hierarchy-proposal.md`** — Tree diagram of the package hierarchy
5. **`gsl-plan-coffeeshop-cdr-exercise-2026-03-06.md`** — CDR extension exercise plan
6. **`gsl-session-report-2026-03-07-s1.md`** — Session 4 report (EHRbase setup, archetype design, OPT blocker)
7. **`gsl-session-report-2026-03-07-s2.md`** — Session 5 report (Phase A completion, typo correction, template re-deployment)
8. **`gsl-session-report-2026-03-07-s3.md`** — This report (Phase B completion, Temporal-EHRbase integration)

---

## 10. Recommended Next Steps

### 10.1 Immediate: Git commit Phase B milestone

Commit the new files (`ehrbase-client.ts`, `composition-builder.ts`, `test-cdr-integration.ts`), modified files (`barista.ts`, `index.ts`), and this session report.

### 10.2 Near-term: Full Temporal workflow test with CDR

Run the complete order workflow (worker + `start-order.ts` client script) with EHRbase running. Verify that the `validateOrder` activity commits a composition to EHRbase as part of the normal workflow execution. This exercises the integration in the Temporal sandboxed environment rather than as a standalone script.

**Prerequisite:** Rebuild the temporal package (`pnpm --filter @coffeeshop/temporal build`) before starting the worker, so the compiled JS includes the CDR integration code.

### 10.3 Near-term: Phase C — Querying and entity views

Implement AQL-backed entity-view endpoints in the SvelteKit web package, a customer feedback form (data entry outside workflows), and demonstrate both process-view (Temporal) and entity-view (CDR) perspectives on the same order data.

**Dependencies:**
- The EHRbase client is already in `@coffeeshop/shared`, so SvelteKit can import it directly
- CUSTOMER_FEEDBACK archetype and template needed for the feedback form (design in Archetype Designer, export OPT via Firefox)

### 10.4 Near-term: Design remaining archetypes

- **PREPARATION_EVENT (ACTION)** — preparation method, barista, timing. Needed for prepareDrink CDR commit
- **CUSTOMER_FEEDBACK (EVALUATION)** — rating, comment. Needed for Phase C form-driven data entry

Both should be designed in Archetype Designer, exported as OPTs (Firefox), and uploaded to EHRbase.

### 10.5 Medium-term: Phase D — Governance audit

Population-level data completeness query: "does every completed order also have a preparation event?" This requires both ORDER_RECORD and PREPARATION_EVENT compositions in the CDR.

---

## 11. Working Practices Reminder

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
- **TypeScript strict mode:** `exactOptionalPropertyTypes: true` — use conditional spread for optional fields

---

*Report generated at end of session 6, 7 March 2026. For use as context in subsequent chat session.*
