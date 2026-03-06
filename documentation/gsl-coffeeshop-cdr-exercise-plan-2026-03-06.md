# Coffee Shop CDR Extension Exercise — Planning Document

**Date:** 6 March 2026
**Context:** Validating openEHR integration patterns via the coffee shop domain before applying them to clinical data
**Prerequisite:** Coffee Shop Demonstrator complete (all four phases), GenderSense model with hormone therapy initiation pathway modelled end to end, architecture principles established

---

## 1. Purpose and Rationale

The architecture principles document identifies the openEHR Clinical Data Repository as the persistent, semantically structured clinical data layer for GenderSense. Before applying openEHR patterns to real clinical data — where mistakes are expensive and domain complexity can obscure integration issues — we validate the integration patterns using the coffee shop domain that is already well understood.

This exercise extends the Coffee Shop Demonstrator. The demonstrator validated the process orchestration layer (Temporal workflows, XState state machines, SvelteKit UI, governance audit). This exercise validates the data persistence layer (openEHR CDR) and its integration with the existing process layer. Together, they prove the complete architecture: model → orchestrate → persist → query → audit.

### What this exercise proves

1. **We can stand up an openEHR CDR locally** and interact with it programmatically
2. **We can design archetypes and templates** that model structured data for a known domain
3. **Temporal workflow activities can commit compositions** to the CDR as part of process execution
4. **AQL queries can retrieve data** organised by entity type (the "entity view")
5. **Form-driven data entry** outside any workflow produces the same queryable, structured data
6. **Population-level governance queries** can evaluate CDR data against rules (the clinical audit pattern)

### Why the coffee shop domain

The coffee shop domain is deliberately trivial. This is the point. We want to exercise the openEHR machinery — archetype design, template construction, composition commit, AQL querying — without the cognitive overhead of clinical semantics. If something doesn't work, we know it's an integration issue, not a clinical modelling issue. The hormone therapy pathway has already defined *what* clinical data is captured and *when*; the CDR exercise validates *how* that data flows into and out of the repository.

The coffee shop also provides a natural analogy mapping that helps build intuition:

| Coffee shop concept | Clinical analogy | openEHR concept |
|---|---|---|
| Customer | Patient | EHR (one per customer) |
| Order | Episode of care | Composition (order record) |
| Drink preparation record | Clinical observation | Composition (preparation event) |
| Customer feedback | Patient-reported outcome | Composition (feedback form) |
| Daily sales report | Population audit | AQL aggregate query |

---

## 2. Technical Stack

### EHRbase CDR

EHRbase is the open-source openEHR CDR. It provides the openEHR REST API (EHR, Composition, Template, Query endpoints) and AQL query execution against PostgreSQL.

**Local deployment:** Docker Compose with two containers — `ehrbase/ehrbase-v2-postgres:16.2` (preconfigured PostgreSQL) and `ehrbase/ehrbase:2.11.0` (the CDR application). Basic auth for development. This runs entirely on the MacBook alongside the existing Temporal dev server.

**Docker Compose outline:**
```yaml
services:
  ehrdb:
    image: ehrbase/ehrbase-v2-postgres:16.2
    environment:
      POSTGRES_PASSWORD: postgres
      EHRBASE_USER_ADMIN: ehrbase
      EHRBASE_PASSWORD_ADMIN: ehrbase
      EHRBASE_USER: ehrbase_restricted
      EHRBASE_PASSWORD: ehrbase_restricted
    ports:
      - "5433:5432"         # offset to avoid conflict with any local PG
  ehrbase:
    image: ehrbase/ehrbase:2.11.0
    depends_on:
      - ehrdb
    environment:
      DB_URL: jdbc:postgresql://ehrdb:5432/ehrbase
      DB_USER_ADMIN: ehrbase
      DB_PASS_ADMIN: ehrbase
      DB_USER: ehrbase_restricted
      DB_PASS: ehrbase_restricted
      SECURITY_AUTHTYPE: BASIC
      SECURITY_AUTHUSER: ehrbase-user
      SECURITY_AUTHPASSWORD: SuperSecretPassword
      SERVER_NODENAME: coffeeshop.local
    ports:
      - "8080:8080"
```

**Swagger UI:** Available at `http://localhost:8080/ehrbase/swagger-ui.html` for interactive API exploration.

### Archetype Designer

Better's web-based Archetype Designer (https://tools.openehr.org/designer/) for visual archetype and template modelling. Free to use. Exports Operational Templates (OPT) in XML format for upload to EHRbase.

### Existing demonstrator infrastructure

The exercise builds on the existing `coffeeshop-demonstrator` monorepo:
- **Temporal worker and workflows** — already running and tested
- **SvelteKit web UI** — for form-driven data entry
- **XState state machines** — order lifecycle enforcement
- **Generated artefacts** — types, workflow, pathway diagram

### Integration language

TypeScript, matching the existing demonstrator codebase. The EHRbase REST API is called via `fetch` from Temporal activity implementations and SvelteKit server endpoints. No Java SDK required — the REST API is the integration point.

---

## 3. Archetype and Template Design

This is the core domain modelling work of the exercise. The openEHR two-level modelling approach separates reusable clinical concepts (archetypes) from use-case-specific data sets (templates). For the coffee shop, we apply the same principle to order data.

### 3.1 Archetypes to design

openEHR archetypes map to Reference Model classes. For the coffee shop domain, we use a small subset of the RM:

| Archetype | RM class | Purpose | Key data elements |
|---|---|---|---|
| `coffeeshop-ORDER_RECORD` | `OBSERVATION` | Records what was ordered | drink name, size, milk choice, extras, price |
| `coffeeshop-PREPARATION_EVENT` | `ACTION` | Records what happened during preparation | preparation method (hot/cold path), barista, start time, end time, preparation notes |
| `coffeeshop-CUSTOMER_FEEDBACK` | `EVALUATION` | Records customer satisfaction | rating (1–5), free-text comment, feedback timestamp |

**Design principle:** Search the Clinical Knowledge Manager (CKM) first. For the coffee shop exercise we obviously won't find existing coffee archetypes, but the practice of searching first and adapting existing patterns is important to establish. For GenderSense, many clinical archetypes already exist (lab results, medications, vital signs) and the discipline of reuse-first is essential.

**RM class selection rationale:**
- `OBSERVATION` for the order record because it captures data about a point-in-time event (what was ordered)
- `ACTION` for preparation because it tracks an intervention with a state machine (ordered → preparing → ready → collected)
- `EVALUATION` for feedback because it captures a clinical (or in this case customer) judgement about an outcome

### 3.2 Templates to design

Templates compose archetypes into use-case-specific data sets. Each template corresponds to a type of "document" (composition) that gets committed to the CDR.

| Template | Container archetype | Included archetypes | Use case |
|---|---|---|---|
| `coffeeshop-order-composition` | `COMPOSITION` (encounter) | ORDER_RECORD | Committed when order is placed (by workflow) |
| `coffeeshop-preparation-composition` | `COMPOSITION` (encounter) | PREPARATION_EVENT | Committed when drink is prepared (by workflow) |
| `coffeeshop-feedback-composition` | `COMPOSITION` (report) | CUSTOMER_FEEDBACK | Committed directly from a form (outside workflow) |

**Design principle:** Each template maps to one Temporal activity or one form submission. This keeps compositions focused and queryable. In clinical terms: a blood result composition, a consultation composition, and a patient questionnaire composition are separate templates, not one giant "everything that happened today" template.

### 3.3 Terminology binding

Even in the coffee shop domain, we establish terminology binding patterns. Coffee shop "terminology" is trivial (drink sizes, milk options), but the pattern of binding data elements to coded values is identical to SNOMED CT binding in clinical archetypes.

For the coffee shop we use local codes (defined in the archetype's internal terminology). For GenderSense, these would be SNOMED CT concept IDs. The archetype structure is the same either way — only the terminology binding source changes.

Example binding pattern:
```
Drink size:
  at0010: small   (clinical: SNOMED CT |dose low|)
  at0011: medium  (clinical: SNOMED CT |dose medium|)
  at0012: large   (clinical: SNOMED CT |dose high|)
```

### 3.4 Deliverables for this step

1. Three archetype definitions (ADL format, exported from Archetype Designer)
2. Three template definitions (OPT format, exported from Archetype Designer)
3. Templates uploaded to EHRbase via the Definition API
4. A brief mapping document recording which coffee shop data elements map to which archetype nodes, and what the clinical analogy would be

---

## 4. Temporal Activity Patterns for Committing Compositions

This step integrates the CDR with the existing workflow. Temporal activities become the bridge: the workflow orchestrates the process; activities commit data to the CDR as a side effect of process execution.

### 4.1 Activity pattern

Each Temporal activity that produces persistent data gains a CDR commit step. The pattern:

```typescript
// Activity implementation pattern
async function validateOrder(orderDetails: OrderLine): Promise<OrderValidationResult> {
  // 1. Business logic (existing)
  const validation = performValidation(orderDetails);

  // 2. Commit composition to CDR (new)
  const composition = buildOrderComposition(orderDetails, validation);
  const compositionUid = await commitComposition(ehrId, composition);

  // 3. Return result (existing — now includes compositionUid)
  return { ...validation, compositionUid };
}
```

### 4.2 CDR client module

A thin TypeScript module wrapping the EHRbase REST API. This is reusable infrastructure that transfers directly to GenderSense.

```typescript
// packages/shared/src/ehrbase-client.ts (outline)

interface EhrbaseClient {
  // EHR management
  createEhr(subjectId: string): Promise<string>;         // returns ehrId
  getEhrBySubject(subjectId: string): Promise<string>;    // returns ehrId

  // Composition management
  commitComposition(ehrId: string, templateId: string, composition: object): Promise<string>;
  getComposition(ehrId: string, compositionUid: string): Promise<object>;

  // Query
  executeAql(aql: string, parameters?: Record<string, unknown>): Promise<AqlResultSet>;
}
```

**Key design decisions:**
- Use the **canonical JSON** format for compositions (not flat/structured — canonical is the standard format, universally supported, and most explicitly typed)
- **Create one EHR per customer** when the customer first places an order. In clinical terms: one EHR per patient, created at registration
- **Template ID in every commit** — the CDR validates the composition against the template. Invalid data is rejected at the API level, not in application code

### 4.3 Activities to modify

| Existing activity | CDR integration | Template used |
|---|---|---|
| `validateOrder` | Commit order composition after validation | `coffeeshop-order-composition` |
| `prepareDrink` | Commit preparation event after preparation | `coffeeshop-preparation-composition` |
| `completeOrder` | No new composition — order closure is a state transition, not new data |

### 4.4 EHR creation strategy

The workflow needs an EHR ID for the customer before committing compositions. Two approaches:

**Option A (recommended for exercise):** Create the EHR in the `validateOrder` activity if one doesn't already exist. Use the customer name/ID as the external subject reference. This mirrors the clinical pattern where a patient EHR is created at registration.

**Option B (production pattern):** Separate EHR creation into a registration workflow. This is what GenderSense would do — patient registration is a distinct process from clinical pathway execution. For the exercise, Option A is sufficient.

### 4.5 Deliverables for this step

1. `ehrbase-client.ts` — reusable CDR client module
2. Modified `validateOrder` activity with composition commit
3. Modified `prepareDrink` activity with composition commit
4. Integration test: start an order workflow, verify compositions appear in EHRbase
5. Error handling pattern: what happens when CDR commit fails mid-workflow? (Temporal retry semantics handle this naturally)

---

## 5. AQL Query Patterns for Entity Views

This step validates the "entity view" — querying the CDR by data type rather than by process. In clinical terms: "show me all blood results for this patient" regardless of which pathway produced them.

### 5.1 Query patterns to implement

| Query | AQL pattern | Clinical analogy |
|---|---|---|
| All orders for a customer | `SELECT c FROM EHR e CONTAINS COMPOSITION c[coffeeshop-order-composition] WHERE e/ehr_id/value = :ehrId` | All lab results for a patient |
| Order details with drink info | `SELECT o/data[at0001]/items[at0002]/value as drinkName, o/data[at0001]/items[at0003]/value as size FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o[coffeeshop-ORDER_RECORD]` | Lab result values with test names |
| All preparation events today | `SELECT c FROM EHR e CONTAINS COMPOSITION c[coffeeshop-preparation-composition] WHERE c/context/start_time > :todayStart` | All consultations today |
| Customer feedback scores | `SELECT e/data[at0001]/items[at0010]/value as rating FROM EHR e CONTAINS COMPOSITION c CONTAINS EVALUATION e[coffeeshop-CUSTOMER_FEEDBACK]` | Patient satisfaction scores |

### 5.2 Entity view endpoints

New SvelteKit API endpoints that query the CDR and return entity-organised data:

| Endpoint | Query target | Returns |
|---|---|---|
| `GET /api/customers/:id/orders` | Order compositions for a customer | List of orders with drink details |
| `GET /api/customers/:id/feedback` | Feedback compositions for a customer | List of feedback entries |
| `GET /api/preparations/today` | Today's preparation events | List of all drinks prepared today |

These complement the existing process-view endpoints (which query Temporal for workflow state). The two views together — process state from Temporal, entity data from CDR — demonstrate the "two views onto the same data" principle from the architecture document.

### 5.3 Deliverables for this step

1. AQL queries for each entity view, tested against EHRbase
2. SvelteKit API endpoints wrapping the queries
3. Brief comparison: process view (Temporal) vs entity view (CDR) for the same order, showing how both are valid perspectives on the same underlying events

---

## 6. Form-Driven Data Entry Outside Workflows

This step validates that data can enter the CDR from paths other than workflow activities. In clinical terms: a clinician records a note directly, outside any active pathway. The data must still be structured, validated, and queryable in the same way.

### 6.1 Customer feedback form

A simple SvelteKit page where a "customer" submits feedback about their order. This is not part of the order fulfilment workflow — it's a standalone form that commits a feedback composition directly to the CDR.

**Why this matters:** In GenderSense, not all clinical data enters via pathway execution. A clinician might record an ad hoc observation, a patient might complete a self-assessment questionnaire at any time, or administrative data might be entered independently of any clinical workflow. All of this must produce the same kind of structured, queryable data in the CDR. The form-driven path validates this.

### 6.2 Implementation

```
User fills form → SvelteKit endpoint → build composition → commit to CDR
```

No Temporal involvement. The composition is committed directly via the EHRbase REST API from the SvelteKit server endpoint. The composition conforms to the same template (`coffeeshop-feedback-composition`) and is indistinguishable from one committed by a workflow activity.

### 6.3 Deliverables for this step

1. SvelteKit feedback form page (`/feedback`)
2. SvelteKit API endpoint for form submission
3. Verification: feedback appears in entity view queries alongside workflow-committed data

---

## 7. Population-Level Governance Query

This step extends the Phase D governance pattern from individual workflow audit to population-level data audit. It's the CDR equivalent of the compliance table.

### 7.1 Governance question

For the coffee shop, a simple governance question: **"Does every order that has been completed also have a preparation event recorded?"**

This is a data completeness audit. It compares what *should* exist (every completed order should have a matching preparation record) against what *does* exist (compositions in the CDR).

The clinical analogy: "Does every patient on hormone therapy who has passed their 3-month mark have monitoring bloods recorded?" Same pattern — compare expected data (derived from pathway rules) against actual data (queried from CDR).

### 7.2 Implementation approach

A Temporal workflow (or standalone script for the exercise) that:

1. **Queries the CDR** for all order compositions
2. **Queries the CDR** for all preparation compositions
3. **Joins** the two result sets by order ID / customer
4. **Identifies gaps** — orders without matching preparation records
5. **Produces a governance report** — list of compliant and non-compliant records

This mirrors the GenderSense audit pattern: scheduled Temporal workflows that query the CDR, evaluate rules derived from the SysML model, and produce governance reports.

### 7.3 AQL for the audit

```sql
-- Orders without preparation events
SELECT
  c/uid/value as orderUid,
  c/context/start_time/value as orderTime
FROM EHR e
CONTAINS COMPOSITION c[coffeeshop-order-composition]
WHERE NOT EXISTS (
  SELECT p
  FROM EHR e2
  CONTAINS COMPOSITION p[coffeeshop-preparation-composition]
  WHERE e2/ehr_id/value = e/ehr_id/value
)
```

**Note:** AQL `NOT EXISTS` subquery support varies by CDR implementation. If EHRbase doesn't support this pattern, the fallback is two separate queries joined in application code — which is actually the more practical pattern for complex governance queries anyway.

### 7.4 Deliverables for this step

1. Governance audit query (AQL or application-level join)
2. Audit report output (JSON or rendered HTML, matching Phase D report style)
3. Documented pattern for extending to clinical governance queries

---

## 8. SysML Model Updates

The CDR exercise should produce corresponding updates to the GenderSense SysML model, establishing the pattern for how CDR integration is represented in the model.

### 8.1 Coffee shop domain model (optional, lightweight)

If useful for learning, create a small `.sysml` file in the demonstrator repo modelling the coffee shop archetypes as SysML part defs with archetype metadata annotations. This would exercise a potential `@OpenEhrArchetype` metadata def pattern:

```sysml
metadata def OpenEhrArchetype {
    attribute archetypeId : String;
    attribute rmClass : String;
}

part def OrderRecord {
    @OpenEhrArchetype {
        archetypeId = "coffeeshop-ORDER_RECORD.v1";
        rmClass = "OBSERVATION";
    }
    attribute drinkName : String;
    attribute drinkSize : DrinkSize;
    attribute milkChoice : MilkOption;
    attribute price : Real;
}
```

This is exploratory — determining whether this pattern is useful for GenderSense's model-to-archetype mapping. If it is, an `@OpenEhrArchetype` metadata def would be added to the shared metadata library.

### 8.2 GenderSense model: Platform::EHR package

Update `platform.sysml` with concrete CDR integration elements informed by the exercise findings:

- EHR part def with CDR connection details
- Archetype registry concept
- Composition commit activity interface
- AQL query interface

This is structural documentation — recording what was learned about the CDR integration pattern in the model. The depth of modelling should match the "middle ring" described in the modelling strategy: structural design and interface definition, not full executable generation.

### 8.3 Deliverables for this step

1. Optional: coffee shop archetype `.sysml` file with `@OpenEhrArchetype` metadata
2. Platform::EHR package elaboration (if time permits)
3. Notes on which SysML patterns are useful for representing CDR integration and which are over-engineering

---

## 9. Work Breakdown and Proposed Order

### Phase A — Infrastructure (EHRbase + archetype tooling)

**Goal:** Get EHRbase running locally and design the coffee shop archetypes/templates.

| Step | Activity | Deliverable | Verification |
|---|---|---|---|
| A1 | Create Docker Compose file in demonstrator repo | `docker-compose.ehrbase.yml` | EHRbase starts, Swagger UI accessible |
| A2 | Design archetypes in Archetype Designer | 3 archetype definitions (ADL) | Archetypes validate in designer |
| A3 | Design templates in Archetype Designer | 3 template definitions (OPT) | Templates validate in designer |
| A4 | Upload templates to EHRbase | Templates registered | Templates listed via Definition API |
| A5 | Create a test EHR and commit a hand-crafted composition | Composition stored | Composition retrievable via EHR API |

**Exit criteria:** EHRbase running, templates uploaded, a composition successfully committed and retrieved.

### Phase B — Temporal integration (workflow activities commit to CDR)

**Goal:** Modify existing workflow activities to commit compositions as part of process execution.

| Step | Activity | Deliverable | Verification |
|---|---|---|---|
| B1 | Implement `ehrbase-client.ts` | CDR client module | Unit tests pass (create EHR, commit, query) |
| B2 | Modify `validateOrder` activity | Order composition committed on validation | Composition appears in EHRbase after workflow start |
| B3 | Modify `prepareDrink` activity | Preparation composition committed | Composition appears after barista signal |
| B4 | End-to-end workflow test | Full workflow run with CDR commits | All expected compositions present in EHRbase |

**Exit criteria:** Running a complete order workflow produces the correct compositions in EHRbase, retrievable via both EHR API and AQL.

### Phase C — Querying and entity views (AQL + SvelteKit endpoints)

**Goal:** Demonstrate entity-view querying of CDR data alongside process-view querying of Temporal state.

| Step | Activity | Deliverable | Verification |
|---|---|---|---|
| C1 | Write and test AQL queries | 4 AQL queries | Queries return expected results in Swagger UI |
| C2 | Implement entity view API endpoints | 3 SvelteKit endpoints | Endpoints return correct data |
| C3 | Implement feedback form | Form page + submission endpoint | Feedback compositions appear in entity views |
| C4 | Compare process view and entity view | Documented comparison | Both views show consistent data for same order |

**Exit criteria:** Entity views return correct data, feedback form works outside workflow, both views consistent.

### Phase D — Governance audit (population-level query)

**Goal:** Run a population-level data completeness audit across the CDR.

| Step | Activity | Deliverable | Verification |
|---|---|---|---|
| D1 | Populate CDR with test data | Multiple orders, some with gaps | Data visible in entity views |
| D2 | Implement governance audit query | AQL or application-level join | Gaps correctly identified |
| D3 | Produce governance report | JSON/HTML report | Report shows compliant/non-compliant records |

**Exit criteria:** Governance audit identifies data gaps correctly, report is produced.

### Phase E — Model updates and documentation (optional, time-permitting)

**Goal:** Record CDR integration patterns in the SysML model.

| Step | Activity | Deliverable | Verification |
|---|---|---|---|
| E1 | Explore `@OpenEhrArchetype` metadata pattern | Test `.sysml` file | Parses in Syside |
| E2 | Update Platform::EHR package | Structural CDR elements | Parses in Syside |
| E3 | Write exercise summary document | Summary with findings and recommendations | — |

**Exit criteria:** Findings documented, recommendations for clinical CDR integration captured.

---

## 10. What This Intentionally Defers

- **Clinical archetype design** — the hormone pathway identifies what data to capture; actual clinical archetype selection (from CKM) and template design happens after this exercise validates the integration patterns
- **SNOMED CT terminology binding** — the exercise uses local codes; SNOMED binding is a GenderSense concern that depends on specific clinical content
- **CDR hosting and deployment** — this exercise uses local Docker; production CDR hosting decisions (EHRbase self-hosted vs commercial openEHR CDR) are a later concern
- **openEHR SDK / code generation** — we use raw REST API calls; the openEHR Java/TypeScript SDKs and code generation from OPTs are optional optimisations
- **FHIR bridge** — EHRbase supports a FHIR-to-openEHR bridge; this is relevant for NHS interoperability but not for the CDR validation exercise
- **Folder organisation** — openEHR Folders can organise compositions within an EHR; not needed for the exercise's simple data model
- **Versioning and contributions** — openEHR supports composition versioning and audit-grade contributions; acknowledged but not exercised beyond basic commit
- **Generator updates** — modifying `gen_temporal_workflow.py` to emit CDR commit code is a Phase E / future concern

---

## 11. Risk and Complexity Notes

### EHRbase version compatibility
EHRbase 2.x has seen significant API changes from 1.x and earlier 2.x versions. Pin to a specific Docker image tag (2.11.0) and don't upgrade mid-exercise.

### Canonical JSON composition format
Building canonical JSON compositions by hand is verbose and error-prone. The composition structure mirrors the RM hierarchy (COMPOSITION → CONTENT → ENTRY → ELEMENT). For the exercise, hand-crafting a few compositions is manageable. For GenderSense production, a composition builder library or code generation from OPTs would be advisable.

### AQL query complexity
AQL is powerful but has a learning curve, and CDR implementations vary in their support for advanced features (subqueries, aggregations, complex joins). Start with simple queries and increase complexity incrementally. The governance audit query (Section 7.3) may need to fall back to application-level joins if EHRbase's AQL doesn't support `NOT EXISTS`.

### Docker resource usage
Running EHRbase (Java) + PostgreSQL + Temporal + SvelteKit simultaneously on a MacBook is feasible but will use significant memory. Expect ~2-3GB for the EHRbase stack alone.

---

## 12. Success Criteria

The exercise is successful if:

1. **EHRbase runs locally** and is accessible via its REST API
2. **Archetypes and templates** are designed, exported, and uploaded
3. **Workflow activities commit compositions** as part of normal order processing
4. **AQL queries return structured data** organised by entity type
5. **Form-driven data entry** works independently of workflows and produces the same queryable data
6. **A governance audit query** identifies data completeness gaps across the population
7. **The integration patterns are documented** with clear recommendations for applying them to GenderSense clinical data

The exercise fails if we discover a fundamental incompatibility between the openEHR CDR model and the Temporal workflow architecture. Given Ella's prior Operon experience with openEHR and the well-established REST API, this is considered very unlikely — but the exercise provides concrete evidence rather than assumption.

---

*Plan prepared 6 March 2026. Companion to the Architecture Principles document (4 March 2026) and the Hormone Therapy Initiation Modelling Plan (6 March 2026).*
