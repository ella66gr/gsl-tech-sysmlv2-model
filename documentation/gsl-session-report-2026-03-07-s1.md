# GenderSense SysML v2 Modelling — Session Report

## 7 March 2026 (Session 1)

**Purpose:** Comprehensive progress report for continuity into the next chat session. This session began execution of the Coffee Shop CDR Extension Exercise (Phase A — Infrastructure), standing up EHRbase locally and designing the ORDER_RECORD archetype and template in Archetype Designer. The session hit a blocking issue with OPT (Operational Template) generation and documented the findings.

---

## 1. Session Objectives and Outcomes

### 1.1 Objectives set at session start

Execute CDR exercise Phase A: stand up EHRbase locally, design archetypes and templates, upload templates, create a test EHR, and commit a hand-crafted composition.

### 1.2 Completed

- **Step A1 — EHRbase infrastructure:** Docker Compose file created, both containers running (EHRbase 2.11.0 + PostgreSQL 16.2), REST API verified responding, basic auth working
- **Step A2 — ORDER_RECORD archetype design:** Complete archetype designed in Better Archetype Designer with five data elements (Drink name, Drink size, Milk choice, Extras, Price), coded terminology for sizes/milks/prices, all verified in designer
- **Step A3 — Order composition template:** Template `coffeeshop-order-composition.v1` created wrapping the ORDER_RECORD archetype, verified in designer
- **Archetype Designer export:** Web template JSON and repository fileset (ADL) exported successfully
- **Working guide produced:** Step-by-step Archetype Designer guide written and revised based on actual UI

### 1.3 Blocked

- **Step A4 — Template upload to EHRbase:** Blocked by inability to produce a valid OPT (Operational Template) XML file
  - Archetype Designer's "Export to OPT" hangs indefinitely (suspected tooling bug)
  - Hand-written OPT XML rejected by EHRbase with `NullPointerException` at `OPTParser.parseCARCHETYPEROOT` — even a bare-minimum COMPOSITION-only OPT fails
  - Web template JSON exported successfully but EHRbase's ADL 1.4 endpoint only accepts XML OPTs
  - Multiple OPT structure variations attempted (element ordering, namespace declarations, xsi:type on definition) — all rejected

### 1.4 Not started

- Steps A5 (test EHR + composition commit), B1–B4, C1–C4, D1–D3, E1–E3

---

## 2. Repository State

### 2.1 Repository

- **GitHub:** `ella66gr/gsl-tech-sysmlv2-model`
- **Local path:** `~/Developer/gsl-tech/gsl-sysml-model/`

### 2.2 Files created this session

| File | Purpose |
|---|---|
| `exercises/coffeeshop-demonstrator/docker-compose.ehrbase.yml` | Docker Compose for EHRbase 2.11.0 + PostgreSQL 16.2 |
| `exercises/coffeeshop-demonstrator/ehrbase/archetype-designer-guide.md` | Step-by-step guide for Archetype Designer (revised to match actual UI) |
| `exercises/coffeeshop-demonstrator/ehrbase/coffeeshop-order-composition.v1.opt` | Hand-written OPT XML (not accepted by EHRbase — see findings) |
| `exercises/coffeeshop-demonstrator/ehrbase/coffeeshop-order-composition.v1.json` | Web template JSON exported from Archetype Designer (valid but wrong format for upload) |
| `exercises/coffeeshop-demonstrator/ehrbase/minimal-test.opt` | Bare-minimum OPT for debugging (also rejected) |
| `exercises/coffeeshop-demonstrator/ehrbase/export/` | Full repository export from Archetype Designer (ADL files + web template) |

### 2.3 No SysML model changes

No `.sysml` files were modified. The syntax reference remains at v3.3.

### 2.4 Git commits recommended

1. **CDR exercise Phase A infrastructure** — Docker Compose file, ehrbase directory, archetype designer guide
2. **Session 4 report** — this document

---

## 3. Infrastructure Setup (Step A1)

### 3.1 Docker Compose

File: `exercises/coffeeshop-demonstrator/docker-compose.ehrbase.yml`

Two services:
- **ehrdb:** `ehrbase/ehrbase-v2-postgres:16.2` on port 5433 (offset from default 5432). Named volume `ehrbase-pg-data` for persistence. Healthcheck via `pg_isready`.
- **ehrbase:** `ehrbase/ehrbase:2.11.0` on port 8080. Depends on ehrdb healthcheck. Basic auth (`ehrbase-user` / `SuperSecretPassword`). Server node name `coffeeshop.local`. Healthcheck via curl to `/ehrbase/status` with 30s start period.

### 3.2 Verification

- Both containers start and reach healthy state (ehrbase takes ~5 seconds to initialise after database is ready)
- Swagger UI accessible at `http://localhost:8080/ehrbase/swagger-ui.html`
- REST API responds: `curl -u ehrbase-user:SuperSecretPassword http://localhost:8080/ehrbase/rest/openehr/v1/definition/template/adl1.4` returns `[]`
- Docker healthcheck for ehrbase may show "unhealthy" during Java startup — this is a timing issue, not a real failure. The API responds correctly once the application has initialised.

### 3.3 Resource usage

EHRbase + PostgreSQL together use approximately 2–3GB of memory on the MacBook, as anticipated in the CDR exercise plan.

---

## 4. Archetype Design (Steps A2/A3)

### 4.1 Tool

Better Archetype Designer — https://tools.openehr.org/designer/

Account created, local folder repository `coffeeshop-exercise` created. The tool is web-based and free.

### 4.2 ORDER_RECORD archetype

**Archetype ID:** `openEHR-EHR-OBSERVATION.order_record.v0`
**RM class:** OBSERVATION

| Element | Node ID | Data type | Occurrences | Notes |
|---|---|---|---|---|
| Drink name | at0005 | DV_CODED_TEXT | 0..1 | Internal coded: Coffee (at0010), Tea (at0011) |
| Drink size | at0006 | DV_CODED_TEXT | 0..1 | Internal coded: Small/at0007 (125mL), Medium/at0008 (175mL), Large/at0009 (250mL) |
| Milk choice | at0012 | DV_CODED_TEXT | 0..1 | Internal coded: None/at0013, Whole milk/at0014, Semi-skimmed milk/at0015, Oat milk/at0016, Soy milk/at0017 |
| Extras | at0018 | DV_TEXT (multiple types) | 0..* | Optional, repeatable. Archetype Designer expanded this to support multiple data types since no constraint was set in the archetype |
| Price | at0019 | DV_CODED_TEXT | 0..1 | Internal coded: £1.25/at0020, £1.75/at0021, £2.30/at0022, £2.85/at0023 |

**Design evolution:** The original plan specified Drink name and Price as DV_TEXT (free text). During the archetype design, Ella made both DV_CODED_TEXT with internal coded terms — Drink name as Coffee/Tea, Price as fixed price points. This is a reasonable design choice for a fixed menu. For the clinical analogy, this is equivalent to using coded terms rather than free text for clinical concepts.

### 4.3 COMPOSITION archetype and template

- **COMPOSITION archetype:** `openEHR-EHR-COMPOSITION.order_composition.v0` — created as a minimal wrapper (Archetype Designer requires a COMPOSITION archetype as the root for templates)
- **Template:** `coffeeshop-order-composition.v1` — COMPOSITION containing the ORDER_RECORD OBSERVATION in its content slot

### 4.4 Archetype Designer observations

- The "Add Child Constraint" dialog uses the fields: Text (node name), Description, Rm Type (ELEMENT/CLUSTER), and Type (Constraint/Archetype Slot/Internal reference)
- For DV_CODED_TEXT: select "Internal coded" radio button (not "External Coded") to add local terminology terms
- The tool auto-assigns at-codes
- Template creation requires a Root Archetype Id — a COMPOSITION archetype must be created first
- Various view modes available: Tree, Mindmap, Tabbed, ADL, Terminology, Analytics
- The tree view with NodeId/Metadata/Occurrences columns provides the best overview

---

## 5. OPT Export Findings (Blocking Issue)

### 5.1 Archetype Designer "Export to OPT" hangs

When clicking "Export to OPT" from the template export dialog, the export process appears to hang indefinitely. All other export options (Export native, Export to OET, Export as xmind, Export Fileset, Export to Excel, Export Web Template) complete within seconds. This is suspected to be a bug in the current version of Archetype Designer.

**Workaround attempted:** Use "Export Web Template" instead (produces valid JSON), but EHRbase's template upload endpoint only accepts XML OPTs via `POST /ehrbase/rest/openehr/v1/definition/template/adl1.4` with `Content-Type: application/xml`.

### 5.2 Hand-written OPT rejected by EHRbase

Multiple attempts to hand-write OPT XML, each rejected by EHRbase with HTTP 500:

```
java.lang.NullPointerException: Cannot invoke "org.openehr.schemas.v1.ARCHETYPEID.getValue()" 
because the return value of "org.openehr.schemas.v1.CARCHETYPEROOT.getArchetypeId()" is null
  at org.ehrbase.openehr.sdk.webtemplate.parser.OPTParser.parseCARCHETYPEROOT(OPTParser.java:265)
  at org.ehrbase.openehr.sdk.webtemplate.parser.OPTParser.parse(OPTParser.java:171)
```

Even a **bare-minimum OPT** (COMPOSITION with only category and context, no content/archetype references at all) fails with the same error class. This suggests the hand-written XML does not match the XMLBeans-generated schema that EHRbase's OPT parser expects, at a structural level that is not addressable without a reference OPT to compare against.

**Variations tested:**
1. `archetype_id` at end of `C_ARCHETYPE_ROOT` block — null pointer
2. `archetype_id` immediately after `node_id` — null pointer
3. `xmlns:xsi` on root element + `xsi:type` on definition — null pointer
4. Minimal COMPOSITION with no content — null pointer (different error path but same class)

### 5.3 Conclusion

Hand-writing OPT XML is not viable. The OPT format is an XMLBeans-serialised representation of the openEHR Archetype Object Model, with strict element ordering and type annotation requirements that cannot be reliably reproduced by hand. A tooling-generated OPT is essential.

### 5.4 Recommended resolution for next session

Install the **Ocean Template Designer** (free desktop application, available for macOS). This is the tool the EHRbase documentation recommends for producing OPTs. The ADL files exported from Archetype Designer can be imported into Ocean Template Designer, and the OPT exported from there.

**Alternative:** Investigate whether the Archetype Designer "Export to OPT" hang is browser-specific (try a different browser) or version-specific. The tool is Better-maintained and the OPT export is a core feature — this may be a transient bug.

**Alternative 2:** Use the EHRbase Sandbox (https://sandkiste.ehrbase.org/) to download a known-good example OPT for structural comparison, then adapt the hand-written version.

---

## 6. Syntax Reference Status

**No changes to the syntax reference this session.** The syntax reference remains at v3.3 (6 March 2026). No SysML patterns were tested or verified during this session as the work was focused on openEHR infrastructure.

File: `documentation/gsl-sysml-v2-syntax-reference-v3.3-2026-03-06.md`

---

## 7. Design Decisions

### 7.1 Docker port allocation

EHRbase PostgreSQL on port 5433 (not 5432) to avoid conflict with any local PostgreSQL instance. EHRbase API on port 8080. This coexists with the Temporal dev server (port 7233) and SvelteKit (port 5173).

### 7.2 ehrbase/ directory for CDR artefacts

CDR-related files (OPTs, compositions, guides) are stored in `exercises/coffeeshop-demonstrator/ehrbase/`. This keeps them alongside the demonstrator codebase without polluting the existing package structure.

### 7.3 Archetype Designer local folder repository

Used a local folder repository rather than GitHub-connected repository in Archetype Designer. The archetypes are exercise artefacts — the valuable output is the exported OPT, not the archetype source in the designer. The local folder avoids authentication and sync complexity.

### 7.4 DV_CODED_TEXT for Drink name and Price

The CDR exercise plan specified these as DV_TEXT (free text). During design, Ella used DV_CODED_TEXT with internal coded terms (Coffee/Tea for drink name, fixed prices for price). This is a valid design choice that exercises the coded terminology pattern more thoroughly — and is closer to the clinical analogy where most clinical concepts use coded values rather than free text.

---

## 8. Companion Documents

These documents are current as of this session and should be available to the next session:

1. **`gsl-sysml-v2-syntax-reference-v3.3-2026-03-06.md`** — Living syntax reference, unchanged this session
2. **`gsl-architecture-principles.md`** — Separation principle, openEHR CDR, governance patterns (unchanged from 4 March)
3. **`gsl-sysml-modelling-strategy.md`** — Comprehensive modelling rationale (unchanged from 4 March)
4. **`gsl-package-hierarchy-proposal.md`** — Tree diagram of the package hierarchy (unchanged)
5. **`gsl-hormone-initiation-modelling-plan-2026-03-06.md`** — Modelling plan from session 1; all substantive steps completed
6. **`gsl-coffeeshop-cdr-exercise-plan-2026-03-06.md`** — CDR extension exercise plan (unchanged)
7. **`gsl-repo-consolidation-plan.md`** — Consolidation rationale (unchanged)
8. **`gsl-session-report-2026-03-06-s1.md`** — Session 1 report (hormone therapy pathway)
9. **`gsl-session-report-2026-03-06-s2.md`** — Session 2 report (syntax verification + CDR planning)
10. **`gsl-session-report-2026-03-06-s3.md`** — Session 3 report (syntax verification + repo consolidation)

---

## 9. Recommended Next Steps

### 9.1 Immediate: Resolve OPT generation

Before any further CDR exercise work, obtain a valid OPT file. Options in priority order:

1. **Try Archetype Designer OPT export in a different browser** — the hang may be browser-specific
2. **Install Ocean Template Designer** — import the ADL files and export as OPT
3. **Download a known-good OPT** from EHRbase test resources and use it as a structural reference for hand-writing

### 9.2 Immediate: Complete Phase A

Once a valid OPT is available:
- Upload template to EHRbase (Step A4)
- Create a test EHR and commit a hand-crafted composition (Step A5)
- Verify the round-trip (commit → retrieve)

### 9.3 Near-term: Design remaining archetypes

PREPARATION_EVENT (ACTION) and CUSTOMER_FEEDBACK (EVALUATION) archetypes still need to be designed. Use whichever OPT generation path works for the first archetype.

### 9.4 Near-term: Phases B–D of CDR exercise

The CDR exercise plan Phases B (Temporal integration), C (querying/forms), and D (governance audit) are downstream of Phase A completion. The plan and deliverables are unchanged.

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
- **Monorepo:** All GenderSense development artefacts in `gsl-sysml-model/`
- **Docker commands:** Run from `exercises/coffeeshop-demonstrator/` with `-f docker-compose.ehrbase.yml`

---

*Report generated at end of session 4, 7 March 2026. For use as context in subsequent chat session.*
