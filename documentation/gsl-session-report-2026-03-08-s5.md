# GenderSense SysML v2 Modelling — Session Report

## 8 March 2026 (Session 5)

**Purpose:** Comprehensive progress report for continuity into the next chat session. This session completed CDR Exercise Phase D — Governance Audit — implementing the PREPARATION_EVENT archetype and template, a preparation composition builder, a test data seeding script, a population-level governance audit query with application-level join, and a SvelteKit governance report page with summary cards and expandable per-customer detail.

---

## 1. Session Objectives and Outcomes

### 1.1 Objectives set at session start

Complete CDR Exercise Phase D: design the PREPARATION_EVENT archetype, populate the CDR with test data including deliberate gaps, implement a governance audit query identifying data completeness gaps, and produce a governance report.

### 1.2 Completed

- **PREPARATION_EVENT archetype designed:** ACTION class archetype (`openEHR-EHR-ACTION.preparation_event.v0`) with five data elements: Preparation method (DV_CODED_TEXT: Hot path/Cold path), Barista name (DV_TEXT), Start time (DV_DATE_TIME), End time (DV_DATE_TIME), Preparation notes (DV_TEXT)
- **COMPOSITION archetype created:** `openEHR-EHR-COMPOSITION.preparation_composition.v0` (Event category)
- **Template created and exported:** `coffeeshop-preparation-composition.v1` — OPT exported via Firefox, uploaded to EHRbase
- **Archetype type corrections:** Barista name and Preparation notes were initially set to BOOLEAN (Archetype Designer default when no type explicitly selected). Corrected to DV_TEXT in the archetype. Also corrected equivalent issues in ORDER_RECORD and CUSTOMER_FEEDBACK archetypes. All three OPTs re-exported and re-uploaded after database reset
- **`preparation-composition-builder.ts`:** Canonical JSON composition builder for the ACTION archetype, including ISM transition (current_state: completed, openehr code 532). Builder follows the same patterns as order and feedback builders
- **`@coffeeshop/shared` index updated:** Preparation builder exported alongside existing builders
- **Step D1 — Test data seeded:** Standalone seeding script creates 5 customers with 9 orders and 5 preparation events, leaving 4 deliberate gaps. All compositions accepted by EHRbase, including the ACTION archetype with ISM transition — first ACTION composition committed in this exercise
- **Step D2 — Governance audit query:** Application-level join of order and preparation compositions by EHR ID. Two AQL queries (all orders, all preparations) executed, joined in TypeScript, gaps identified. Correctly found all 4 expected gaps across 3 non-compliant customers
- **Step D3 — Governance report (CLI):** Console report with summary statistics and per-customer detail, plus JSON output for machine consumption
- **Step D3 — Governance report (SvelteKit):** Full governance audit page at `/governance` with:
  - "Run Governance Audit" button triggering the API endpoint
  - Summary cards (customers, orders, preparations, gaps, compliance rate) with colour-coded backgrounds
  - Compliant/non-compliant breakdown
  - Expandable per-customer detail showing unmatched orders (highlighted), all orders, and preparation events
  - Navigation bar updated with Governance link
- **API endpoint:** `GET /api/entity/governance` — queries CDR for both composition types, includes preparation method and barista name from the ACTION description
- **Live demonstration of governance detection:** Additional orders placed via the workflow (which does not yet commit preparation compositions from `prepareDrink`) caused the compliance rate to drop from 40% to 25%, demonstrating the governance audit detecting real operational gaps rather than just synthetic test data

### 1.3 Not started

- CDR Exercise Phase E (SysML model updates — `@OpenEhrArchetype` metadata, Platform::EHR package)
- Modifying `prepareDrink` activity to commit preparation compositions (would bring workflow orders into compliance)

---

## 2. Repository State

### 2.1 Repository

- **GitHub:** `ella66gr/gsl-tech-sysmlv2-model`
- **Local path:** `~/Developer/gsl-tech/gsl-sysml-model/`

### 2.2 Files created/modified this session

| File | Purpose |
|---|---|
| `packages/shared/src/preparation-composition-builder.ts` | **New.** Canonical JSON composition builder for PREPARATION_EVENT ACTION archetype |
| `packages/shared/src/index.ts` | **Modified.** Added re-exports for preparation-composition-builder |
| `packages/temporal/src/test/seed-governance-data.ts` | **New.** Test data seeder — 5 customers, 9 orders, 5 preps, 4 gaps |
| `packages/temporal/src/test/run-governance-audit.ts` | **New.** CLI governance audit — queries CDR, joins application-side, produces report |
| `packages/web/src/routes/api/entity/governance/+server.ts` | **New.** SvelteKit API endpoint for governance audit |
| `packages/web/src/routes/governance/+page.svelte` | **New.** Governance audit UI page with summary cards and expandable detail |
| `packages/web/src/routes/+layout.svelte` | **Modified.** Added Governance link to navigation bar |
| `ehrbase/coffeeshop-preparation-composition.v1.opt` | **New.** OPT for preparation template (exported from Archetype Designer via Firefox) |
| `ehrbase/coffeeshop-order-composition.v1.opt` | **Modified.** Re-exported after archetype type corrections |
| `ehrbase/coffeeshop-feedback-composition.v1.opt` | **Modified.** Re-exported after archetype type corrections |
| `ehrbase/preparation-event-archetype-spec.md` | **New.** Design specification for the PREPARATION_EVENT archetype |

All paths relative to `exercises/coffeeshop-demonstrator/`.

### 2.3 No SysML model changes

No `.sysml` files were modified. The syntax reference remains at v3.3.

### 2.4 Git commit recommended

**CDR Exercise Phase D complete** — preparation archetype/OPT, composition builder, test data seeder, governance audit (CLI + SvelteKit), session report.

---

## 3. Phase D Exit Criteria — All Met

| Criterion | Status | Evidence |
|---|---|---|
| D1: CDR populated with test data including gaps | Done | 5 customers, 9 orders, 5 preparations, 4 deliberate gaps — all compositions accepted by EHRbase |
| D2: Governance audit query identifies gaps correctly | Done | Application-level join finds all 4 expected gaps across 3 non-compliant customers |
| D3: Governance report produced | Done | CLI report (JSON + console) and SvelteKit page with summary cards and expandable detail |

---

## 4. Key Findings

### 4.1 ACTION archetype canonical JSON structure

The ACTION RM class has a different structure from OBSERVATION and EVALUATION:

- **OBSERVATION:** content → OBSERVATION → data (HISTORY → POINT_EVENT → ITEM_TREE → items)
- **EVALUATION:** content → EVALUATION → data (ITEM_TREE → items)
- **ACTION:** content → ACTION → description (ITEM_TREE → items) + time + ism_transition

Key differences:
- ACTION uses `description` (not `data`) for its ITEM_TREE
- ACTION requires a `time` element (DV_DATE_TIME) representing when the action occurred
- ACTION requires an `ism_transition` element with a `current_state` coded text

The ISM transition uses openEHR terminology codes for the state machine:
- `526` = planned
- `245` = active
- `532` = completed
- `531` = aborted

For this exercise, all preparation events use `532` (completed) since they're recorded after the fact.

**Implication for GenderSense:** Clinical actions (medication administration, procedure performed, investigation performed) will use ACTION archetypes. The composition builder pattern needs to handle the ISM transition state machine — the state should reflect the actual clinical workflow state. For a medication administration that's been given, this would be `532` (completed). For one that's been prescribed but not yet administered, this might be `526` (planned).

### 4.2 Archetype Designer defaults unassigned elements to BOOLEAN

When adding a new ELEMENT in Archetype Designer without explicitly selecting a data type, the tool defaults to BOOLEAN — the first option alphabetically in the "Available types" dropdown. The dropdown provides no visual affordance indicating that scrolling reveals additional options (including the commonly needed Text, Coded Text, DateTime types which are further down the list).

This caused Barista name and Preparation notes to be saved as BOOLEAN. The same issue had previously occurred with elements in the ORDER_RECORD and CUSTOMER_FEEDBACK archetypes that should have been DV_TEXT.

**Resolution:** Always explicitly set the data type for every element. Scroll the "Available types" dropdown to find "Text" (for DV_TEXT) — it's near the bottom of the alphabetical list.

**Implication for GenderSense:** This is a training/documentation issue for anyone using Archetype Designer. A pre-flight checklist for archetype design should include: "Verify every element has its intended data type set — do not leave elements at the BOOLEAN default."

### 4.3 Archetype type corrections require full re-export and database reset

Correcting a data type in an archetype requires:
1. Edit the archetype (not the template)
2. Save the archetype
3. Open the template, refresh to pick up archetype changes
4. Re-export the OPT (Firefox)
5. Reset the EHRbase database (`docker compose down -v`, `up -d`) — EHRbase rejects duplicate template IDs
6. Re-upload all templates

This is the same process as the Phase A "Oak milk" → "Oat milk" correction, but applied to data types rather than terminology. In both cases, the change must be made at the archetype level and propagates through the template into the OPT.

### 4.4 Application-level join is the practical pattern for governance queries

The governance audit uses two separate AQL queries (one for orders, one for preparations) joined in TypeScript by EHR ID. This works well because:
- EHRbase 2.11.0 doesn't support NOT EXISTS subqueries or aggregate AQL
- The application code can apply arbitrary matching logic (by count, by timestamp, by reference ID)
- The join is fast for small-to-medium datasets (9 orders, 5 preparations — trivial)
- The pattern transfers directly to clinical governance: query each composition type separately, join in application code

**Implication for GenderSense:** Clinical governance queries ("patients on HRT without monitoring bloods after 3 months") will follow the same pattern: one AQL query per composition type, application-level join applying the governance rules. The rules themselves can be derived from the SysML model constraints — the SysML model defines what data should exist and when, the governance query checks whether it does.

### 4.5 Governance audit detects real operational gaps

After seeding the test data (40% compliance), additional orders placed via the Temporal workflow caused the compliance rate to drop to 25%. This happened because the `prepareDrink` activity does not yet commit preparation compositions to the CDR. The governance audit correctly identified these as gaps — demonstrating that the audit pattern works on live operational data, not just synthetic test scenarios.

---

## 5. Archetype and Template Reference

### 5.1 PREPARATION_EVENT archetype (new this session)

**Archetype ID:** `openEHR-EHR-ACTION.preparation_event.v0`
**RM class:** ACTION
**Template:** `coffeeshop-preparation-composition.v1`
**Composition archetype:** `openEHR-EHR-COMPOSITION.preparation_composition.v0`

| Element | Node ID | Data type | Coded terms |
|---|---|---|---|
| Description root (Item tree) | at0001 | ITEM_TREE | — |
| Preparation method | at0002 | DV_CODED_TEXT | Hot path (at0003), Cold path (at0004) |
| Barista name | at0005 | DV_TEXT | Free text |
| Start time | at0006 | DV_DATE_TIME | — |
| End time | at0007 | DV_DATE_TIME | — |
| Preparation notes | at0008 | DV_TEXT | Free text |

### 5.2 Templates in EHRbase

| Template ID | Archetype | RM class | Phase |
|---|---|---|---|
| `coffeeshop-order-composition.v1` | ORDER_RECORD | OBSERVATION | Phase A |
| `coffeeshop-feedback-composition.v1` | CUSTOMER_FEEDBACK | EVALUATION | Phase C |
| `coffeeshop-preparation-composition.v1` | PREPARATION_EVENT | ACTION | Phase D |

All three RM entry classes used in the coffee shop exercise (OBSERVATION, EVALUATION, ACTION) have now been exercised with archetype design, template creation, OPT export, composition commit, and AQL query.

---

## 6. Test Data State

### 6.1 Seeded test data (from seed-governance-data.ts)

| Customer | EHR ID | Orders | Preps | Gaps |
|---|---|---|---|---|
| Alice | d5f45968... | 2 | 2 | 0 |
| Bob | 736c9a66... | 2 | 1 | 1 |
| Charlie | 8b10c5d3... | 1 | 0 | 1 |
| Diana | 46dc7686... | 1 | 1 | 0 |
| Eve | 987e6440... | 3 | 1 | 2 |

Additional orders placed via the Temporal workflow have created further EHRs and order compositions without preparation events.

---

## 7. Design Decisions

### 7.1 ISM transition set to "completed" for all preparation events

All seeded preparation events use ISM current_state = completed (openehr code 532). In a real clinical system, the ISM state would reflect the actual workflow state. For the exercise, "completed" is appropriate since preparations are recorded after the fact.

### 7.2 Application-level join for governance audit

Two AQL queries joined in TypeScript by EHR ID, rather than attempting a CDR-level join. This is the practical pattern for EHRbase 2.11.0 and is actually the recommended approach for complex governance queries where the matching logic may exceed what AQL can express.

### 7.3 Count-based gap detection

The audit identifies gaps by comparing order count vs preparation count per EHR. This is a simplification — it doesn't match specific orders to specific preparations. For a more precise audit, the composition builder could include an order reference in the preparation event (analogous to linking a medication administration to a specific prescription). This level of precision is a Phase E consideration.

### 7.4 Governance page uses on-demand query, not pre-computed report

The SvelteKit governance page queries the CDR live when the "Run Governance Audit" button is clicked. This means it always reflects the current state of the CDR, including any orders added since the last audit. In a production system, governance audits might be scheduled (Temporal cron workflow) with results cached, but on-demand is appropriate for the exercise.

---

## 8. Syntax Reference Status

**No changes to the syntax reference this session.** The syntax reference remains at v3.3 (6 March 2026). No SysML patterns were tested or verified during this session as the work was focused on openEHR archetype design, TypeScript composition builders, and SvelteKit governance UI.

File: `documentation/gsl-sysml-v2-syntax-reference-v3.3-2026-03-06.md`

---

## 9. Companion Documents

These documents are current as of this session and should be available to the next session:

1. **`gsl-sysml-v2-syntax-reference-v3.3-2026-03-06.md`** — Living syntax reference, unchanged this session
2. **`gsl-platform-architecture-principles.md`** — Separation principle, openEHR CDR, governance patterns
3. **`gsl-platform-sysml-modelling-strategy.md`** — Comprehensive modelling rationale
4. **`gsl-platform-package-hierarchy-proposal.md`** — Tree diagram of the package hierarchy
5. **`gsl-plan-coffeeshop-cdr-exercise-2026-03-06.md`** — CDR extension exercise plan
6. **`gsl-session-report-2026-03-07-s1.md`** — Session 1 report (EHRbase setup, archetype design, OPT blocker)
7. **`gsl-session-report-2026-03-07-s2.md`** — Session 2 report (Phase A completion, typo correction, template re-deployment)
8. **`gsl-session-report-2026-03-07-s3.md`** — Session 3 report (Phase B completion, Temporal-EHRbase integration)
9. **`gsl-session-report-2026-03-07-s4.md`** — Session 4 report (Phase C completion, entity views, feedback form, comparison)
10. **`gsl-session-report-2026-03-08-s5.md`** — This report (Phase D completion, governance audit)

---

## 10. Recommended Next Steps

### 10.1 Immediate: Git commit Phase D milestone

Commit all new files (preparation builder, seeder, governance audit, SvelteKit governance page/endpoint, preparation OPT, corrected OPTs) and this session report.

### 10.2 Near-term: Modify prepareDrink to commit preparation compositions

The preparation composition builder and EHRbase template are now in place. Modifying the `prepareDrink` activity to commit preparation compositions (mirroring what `validateOrder` already does for orders) would bring workflow orders into governance compliance. This is straightforward — the pattern is established, the builder exists, and the EHR is already created by `validateOrder`.

### 10.3 Near-term: Phase E — SysML model updates

Record CDR integration patterns in the SysML model:
- `@OpenEhrArchetype` metadata def pattern — map part defs to archetype IDs and RM classes
- Platform::EHR package elaboration — CDR connection, archetype registry, composition commit interface
- Exercise summary document with recommendations for clinical CDR integration
- Assessment of which SysML patterns are useful for representing CDR integration and which are over-engineering

### 10.4 Medium-term: CDR exercise summary and recommendations

Write a summary document covering what was learned across all five phases of the CDR extension exercise, with specific recommendations for applying these patterns to GenderSense clinical data. Key topics: archetype design workflow, composition builder patterns, AQL query patterns, governance audit patterns, and tooling lessons (Archetype Designer quirks, EHRbase version considerations).

### 10.5 Medium-term: Clinical archetype selection

Begin selecting existing clinical archetypes from the Clinical Knowledge Manager (CKM) for the hormone therapy initiation pathway. The CDR exercise has validated the integration patterns; the next step is applying them to real clinical content. Key archetypes to source: medication order/administration, laboratory results, clinical assessment, vital signs, patient questionnaire.

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
- **Archetype Designer:** Use Firefox for OPT export (Chrome hangs). Edit terms in the archetype, not the template. **Always explicitly set data types — BOOLEAN default is a trap**
- **Monorepo:** All GenderSense development artefacts in `gsl-sysml-model/`
- **Docker commands:** Run from `exercises/coffeeshop-demonstrator/` with `-f docker-compose.ehrbase.yml`
- **EHRbase auth:** `ehrbase-user` / `SuperSecretPassword` (basic auth)
- **EHRbase API base:** `http://localhost:8080/ehrbase/rest/openehr/v1/`
- **EHRbase namespace pattern:** `[a-zA-Z][a-zA-Z0-9-_:/&+?]*` — no dots allowed
- **EHRbase composition commit:** Returns 204 with `Prefer: return=minimal`; UID in ETag header
- **EHRbase aggregate AQL:** COUNT/GROUP BY not supported in 2.11.0 — use application-level aggregation
- **TypeScript strict mode:** `exactOptionalPropertyTypes: true` — use conditional spread for optional fields
- **Temporal worker:** Must be run from compiled JS (`node dist/workers/worker.js`), not via `npx tsx`
- **ACTION RM class:** Uses `description` (not `data`), requires `time` and `ism_transition` elements. ISM state codes: planned=526, active=245, completed=532, aborted=531

---

*Report generated at end of session 8, 8 March 2026. For use as context in subsequent chat session.*
