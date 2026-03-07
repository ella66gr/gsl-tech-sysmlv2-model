# GenderSense SysML v2 Modelling — Session Report

## 7 March 2026 (Session 5)

**Purpose:** Comprehensive progress report for continuity into the next chat session. This session resolved the OPT generation blocker from session 4 and completed all remaining steps of CDR Exercise Phase A, achieving the full round-trip: template upload → EHR creation → composition commit → composition retrieval → AQL query. It also corrected an archetype typo and exercised the template re-deployment process.

---

## 1. Session Objectives and Outcomes

### 1.1 Objectives set at session start

Resolve the OPT generation blocker (session 4 recommendation: install Ocean Template Designer). Complete CDR Exercise Phase A.

### 1.2 Completed

- **OPT blocker resolved:** Archetype Designer OPT export works in Firefox (Chrome-specific bug — export hangs indefinitely in Chrome). Ocean Template Designer was investigated but found to be Windows-only (.NET/VB.Net application), not viable on macOS
- **Step A4 — Template upload to EHRbase:** `coffeeshop-order-composition.v1` OPT uploaded successfully via REST API, template registered and listed
- **Step A5a — Test EHR created:** EHR created with system_id `coffeeshop.local`
- **Step A5b — Composition committed:** Canonical JSON composition for a coffee order committed successfully, validated against template
- **Step A5c — Composition retrieved:** Round-trip confirmed — retrieved composition matches committed data
- **Step A5d — AQL query working:** Entity-view query returned `["Coffee", "Large", "£2.85"]` — proving the CDR is fully queryable
- **Composition validation exercised:** Initial commit rejected with `Dv_Coded_Text value does not match` error due to archetype typo ("Oak milk" vs "Oat milk") — EHRbase correctly enforces term definition consistency
- **Archetype typo corrected:** Fixed "Oak milk" → "Oat milk" in Archetype Designer (archetype level, not template level — key learning), re-exported OPT, database reset, corrected OPT and composition re-uploaded and re-committed successfully
- **Archetype Designer learning:** Term definitions are edited in the archetype, not the template. Templates inherit from archetypes and constrain further, but terminology text lives at the archetype level
- **Template re-deployment process exercised:** EHRbase rejects duplicate template uploads (HTTP 409 Conflict). Resolution: `docker compose down -v` to destroy volumes, then `up -d` for a fresh database. Alternative: `ehrbase.template.allow-overwrite=true` environment variable (not tested)

### 1.3 Not started

- CDR Exercise Phases B–E (Temporal integration, querying/forms, governance audit, model updates)

---

## 2. Repository State

### 2.1 Repository

- **GitHub:** `ella66gr/gsl-tech-sysmlv2-model`
- **Local path:** `~/Developer/gsl-tech/gsl-sysml-model/`

### 2.2 Files created/modified this session

| File | Purpose |
|---|---|
| `exercises/coffeeshop-demonstrator/ehrbase/coffeeshop-order-composition.v1.opt` | Tooling-generated OPT from Archetype Designer (Firefox export), corrected "Oat milk" — replaces hand-written OPT from session 4 |
| `exercises/coffeeshop-demonstrator/ehrbase/test-order-composition.json` | Canonical JSON composition — large coffee, oat milk, extra shot, £2.85 |

### 2.3 No SysML model changes

No `.sysml` files were modified. The syntax reference remains at v3.3.

### 2.4 Git commits recommended

1. **CDR Exercise Phase A complete** — tooling-generated OPT (corrected), test composition, session report
2. Clean up: consider removing `minimal-test.opt` and `test-template.opt` (failed hand-written OPTs from session 4)

---

## 3. Phase A Exit Criteria — All Met

| Criterion | Status | Evidence |
|---|---|---|
| A1: EHRbase running locally | Done (session 4) | Docker Compose, both containers healthy |
| A2: ORDER_RECORD archetype designed | Done (session 4), corrected this session | Archetype in Archetype Designer with 5 data elements, "Oat milk" typo fixed |
| A3: Template created | Done (session 4) | Template wrapping ORDER_RECORD OBSERVATION |
| A4: Template uploaded to EHRbase | **Done (this session)** | Template listed via Definition API |
| A5: Test EHR + composition committed | **Done (this session)** | Composition committed, retrieved, and queried via AQL |
| Bonus: AQL query working | **Done (this session)** | Entity-view query returns `["Coffee", "Large", "£2.85"]` |

---

## 4. Key Findings

### 4.1 Archetype Designer OPT export is Chrome-specific bug

The "Export to OPT" function hangs indefinitely in Chrome but completes successfully in Firefox. This was the blocking issue from session 4. The workaround is simple: use Firefox for OPT export.

### 4.2 Ocean Template Designer is Windows-only

The Ocean Template Designer (previously recommended as the fallback OPT generation tool) is a .NET/VB.Net Windows application. It cannot run natively on macOS. The openEHR modelling tools page lists it as platform: Windows. Forum reports confirm Mac users have difficulty even via Parallels. This is not a viable path for this project.

### 4.3 Hand-written OPT XML is not viable (confirmed)

Comparing the tooling-generated OPT (677 lines) with the hand-written attempts from session 4 confirms the structural differences. Key observations:
- `xsi:type` annotations are required on every `children` and `attributes` element within the definition tree
- The `archetype_id` element appears *after* all `attributes` and `term_definitions` within `C_ARCHETYPE_ROOT` — not before or alongside `node_id` as might be expected
- `C_CODE_PHRASE` children carry `terminology_id` and `code_list` elements for local coded terms
- Every occurrence/existence range is fully spelled out with all six elements (lower_included, upper_included, lower_unbounded, upper_unbounded, lower, upper)

### 4.4 EHRbase validates DV_CODED_TEXT values against term definitions

The initial composition commit was rejected because the `value` field for Milk choice said "Oat milk" but the archetype term definition (at0016) said "Oak milk" (a typo in the archetype). EHRbase enforces exact text match between the composition's coded text value and the archetype's term definition text. This is correct behaviour — the CDR ensures data integrity at the semantic level.

**Implication for GenderSense:** Archetype term definitions must be accurate before templates are deployed. Typos in archetype terms propagate into the OPT and are enforced by the CDR. A term correction requires re-export of the OPT and re-upload to EHRbase.

### 4.5 Archetype Designer: edit terms in the archetype, not the template

When correcting a term definition, the edit must be made in the **archetype** view, not the template view. Templates inherit terminology from their component archetypes — the template constrains which terms are available but does not own the term text. This is consistent with openEHR's two-level modelling: archetypes own the semantics, templates select and constrain.

### 4.6 Template re-deployment requires database reset or overwrite config

EHRbase rejects uploading an OPT with a template_id that already exists (HTTP 409 Conflict). For development, the simplest resolution is to destroy the Docker volumes (`docker compose down -v`) and restart with a fresh database. For production scenarios, EHRbase supports `ehrbase.template.allow-overwrite=true` as a configuration option.

### 4.7 Canonical JSON composition structure

The canonical JSON format for openEHR compositions follows the RM hierarchy:
- COMPOSITION → content[] → OBSERVATION → data (HISTORY) → events[] → POINT_EVENT → data (ITEM_TREE) → items[] → ELEMENT → value
- Every node requires `_type`, `name` (DV_TEXT), and `archetype_node_id`
- OBSERVATION requires `language`, `encoding`, and `subject`
- COMPOSITION requires `language`, `territory`, `category`, `composer`, and `context`
- Context requires `start_time` and `setting` (coded using openehr terminology, e.g. "238" = "other care")
- Coded text values require both `value` (display text) and `defining_code` (terminology_id + code_string)

### 4.8 AQL path structure

AQL paths mirror the RM hierarchy using archetype node IDs:
```
c/content[openEHR-EHR-OBSERVATION.order_record.v0]
  /data[at0001]/events[at0002]/data[at0003]
  /items[at0005]/value/value
```
The final `/value/value` reaches through ELEMENT.value (the DV_CODED_TEXT) to the display string. The `/value/defining_code/code_string` path would reach the at-code.

---

## 5. Test Data Reference

Note: The database was reset during this session to deploy the corrected OPT. The EHR IDs and composition UIDs from the initial round have been superseded. The current state of the database after the final clean run:

### 5.1 Current EHR

| Field | Value |
|---|---|
| ehr_id | `08ab3485-c35e-4c9c-aaca-2f7b1b87785e` |
| system_id | `coffeeshop.local` |

### 5.2 Current Composition

| Field | Value |
|---|---|
| Template | `coffeeshop-order-composition.v1` |
| Drink name | Coffee (at0010) |
| Drink size | Large (at0009) |
| Milk choice | Oat milk (at0016) — corrected |
| Extras | Extra shot (free text) |
| Price | £2.85 (at0023) |
| Composer | Barista One |

---

## 6. Syntax Reference Status

**No changes to the syntax reference this session.** The syntax reference remains at v3.3 (6 March 2026). No SysML patterns were tested or verified during this session as the work was focused on openEHR CDR integration.

File: `documentation/gsl-sysml-v2-syntax-reference-v3.3-2026-03-06.md`

---

## 7. Design Decisions

### 7.1 Firefox for OPT export

Archetype Designer's OPT export is broken in Chrome. Use Firefox for all OPT exports going forward.

### 7.2 Canonical JSON for compositions (not flat/structured format)

The test composition uses openEHR canonical JSON format, which maps directly to the Reference Model. EHRbase also supports "flat" and "structured" simplified formats via the EHRscape API, which are more compact but use a different endpoint. For the exercise, canonical JSON is preferred because it exercises the standard openEHR REST API and makes the RM structure explicit. For GenderSense production, the flat format may be more practical for form-driven data entry.

### 7.3 Test composition matches archetype terms exactly

EHRbase validates that DV_CODED_TEXT values match the term definitions in the template. This means composition builders must use the exact text from the archetype terminology, not approximations. This has implications for code generation — a composition builder should derive display text from the template, not require developers to type it.

### 7.4 Database reset for template updates during development

During development, the simplest way to update a template is to destroy the database volumes and start fresh. This is acceptable for the exercise where test data is trivially recreatable. For Phase B onwards, a script to re-seed the database (upload template, create EHR, commit test compositions) would be useful.

---

## 8. Companion Documents

These documents are current as of this session and should be available to the next session:

1. **`gsl-sysml-v2-syntax-reference-v3.3-2026-03-06.md`** — Living syntax reference, unchanged this session
2. **`gsl-architecture-principles.md`** — Separation principle, openEHR CDR, governance patterns
3. **`gsl-sysml-modelling-strategy.md`** — Comprehensive modelling rationale
4. **`gsl-package-hierarchy-proposal.md`** — Tree diagram of the package hierarchy
5. **`gsl-hormone-initiation-modelling-plan-2026-03-06.md`** — Modelling plan, all substantive steps completed
6. **`gsl-coffeeshop-cdr-exercise-plan-2026-03-06.md`** — CDR extension exercise plan
7. **`gsl-session-report-2026-03-07-s1.md`** — Session 4 report (EHRbase setup, archetype design, OPT blocker)
8. **`gsl-session-report-2026-03-07-s2.md`** — This report (Phase A completion, typo correction, template re-deployment)

---

## 9. Recommended Next Steps

### 9.1 Immediate: Git commit Phase A milestone

Commit the corrected OPT, test composition, and this session report. Consider cleaning up the failed hand-written OPTs (`minimal-test.opt`, `test-template.opt`).

### 9.2 Near-term: Phase B — Temporal integration

Modify the existing coffee shop demonstrator workflow activities to commit compositions to EHRbase as part of order processing. Key deliverables:

- `ehrbase-client.ts` — TypeScript client module wrapping EHRbase REST API calls (create EHR, commit composition, query)
- Modified `validateOrder` activity — commits order composition on validation
- Modified `prepareDrink` activity — commits preparation composition (requires PREPARATION_EVENT archetype + template first)
- End-to-end test — workflow run produces correct compositions in EHRbase

**Dependency:** PREPARATION_EVENT archetype and template need to be designed in Archetype Designer and exported as OPT before the `prepareDrink` activity can commit preparation compositions. The ORDER_RECORD path can proceed immediately.

### 9.3 Near-term: Design remaining archetypes

- PREPARATION_EVENT (ACTION) — preparation method, barista, timing
- CUSTOMER_FEEDBACK (EVALUATION) — rating, comment

These should be designed in Archetype Designer, exported as OPTs (Firefox), and uploaded to EHRbase.

---

## 10. Working Practices Reminder

- **Syntax reference first:** Now at `documentation/gsl-sysml-v2-syntax-reference-v3.3-2026-03-06.md`
- **Version the syntax reference:** Bump version at the start of any session that adds verified findings
- **Verify in Syside:** All new SysML patterns tested and results captured
- **Phase exit criteria:** Document what was verified, what traps were found, TODO list updated
- **Git commits at checkpoints:** Commit when work is known-good
- **MCP filesystem access:** Claude has access to `~/Developer/gsl-tech/` and reads/writes files directly. Ella runs shell commands and pastes output back
- **Syside Modeler version:** 0.8.5 (VS Code extension, 1 March 2026)
- **Development environment:** macOS (MacBook Pro), Python 3.12, VS Code
- **EHRbase version:** 2.11.0 (Docker). PostgreSQL 16.2 (Docker). Pinned — do not upgrade mid-exercise
- **Archetype Designer:** Use Firefox for OPT export (Chrome hangs). Edit terms in the archetype, not the template
- **Monorepo:** All GenderSense development artefacts in `gsl-sysml-model/`
- **Docker commands:** Run from `exercises/coffeeshop-demonstrator/` with `-f docker-compose.ehrbase.yml`
- **EHRbase auth:** `ehrbase-user` / `SuperSecretPassword` (basic auth)
- **EHRbase API base:** `http://localhost:8080/ehrbase/rest/openehr/v1/`

---

*Report generated at end of session 5, 7 March 2026. For use as context in subsequent chat session.*
