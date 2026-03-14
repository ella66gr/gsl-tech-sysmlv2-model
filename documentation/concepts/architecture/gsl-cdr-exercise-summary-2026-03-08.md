# Coffee Shop CDR Extension Exercise — Summary and Recommendations

**Date:** 8 March 2026
**Author:** Ella Green / Claude (Session 6)
**Context:** Completion of CDR Exercise Phases A–E. Summary of findings and recommendations for applying validated patterns to GenderSense clinical data.

---

## 1. What the Exercise Proved

The Coffee Shop CDR Extension Exercise ran across six chat sessions (Sessions 1–6, 7–8 March 2026), extending the original Coffee Shop Demonstrator with an openEHR Clinical Data Repository layer. Five phases were completed:

- **Phase A — Infrastructure:** EHRbase stood up locally (Docker), ORDER_RECORD archetype designed in Archetype Designer, OPT exported, template uploaded, test EHR created, composition committed and queried via AQL.
- **Phase B — Temporal integration:** TypeScript EHRbase client module, canonical JSON composition builder, `validateOrder` activity modified to commit compositions as part of workflow execution, end-to-end integration test.
- **Phase C — Querying and entity views:** AQL queries for entity views, SvelteKit API endpoints, CUSTOMER_FEEDBACK archetype and form-driven data entry (outside any workflow), process-view vs entity-view comparison demonstrating the "two views onto the same data" principle.
- **Phase D — Governance audit:** PREPARATION_EVENT archetype (ACTION class), test data seeder with deliberate gaps, population-level governance audit query with application-level join, SvelteKit governance report page with summary cards and expandable detail.
- **Phase E — Model updates:** `@OpenEhrArchetype` and `@OpenEhrTemplate` metadata defs in Foundation::MetadataLibrary, coffee shop archetype mappings as annotated SysML part defs, Platform::EHR package elaborated with structural elements informed by exercise findings, syntax reference updated.

### What was validated

1. **An openEHR CDR runs locally** alongside Temporal and SvelteKit with acceptable resource usage.
2. **Archetypes and templates can be designed and deployed** using free, web-based tooling (Archetype Designer) — with documented workarounds for tooling quirks.
3. **Temporal workflow activities commit compositions** to the CDR as a natural part of process execution. The CDR validates data against the template on commit.
4. **Form-driven data entry outside workflows** produces the same structured, queryable data. The CDR does not distinguish how data arrived.
5. **AQL queries provide entity views** — data organised by type (all orders, all feedback) regardless of the process that produced it.
6. **Population-level governance audits** work by querying the CDR for expected and actual compositions, joining in application code, and identifying gaps.
7. **All three openEHR RM entry classes** (OBSERVATION, EVALUATION, ACTION) have been exercised end-to-end.
8. **SysML metadata annotations on part defs** provide machine-queryable traceability between the model and the CDR archetype layer.

### What was NOT validated

- SNOMED CT terminology binding (exercise used local codes only)
- CDR hosting and deployment at production scale
- openEHR SDKs or code generation from OPTs
- FHIR bridge / NHS interoperability
- Composition versioning and audit-grade contributions
- Folder organisation within EHRs
- Generator updates to emit CDR commit code from SysML

These are all deferred to the GenderSense clinical implementation phase and are noted in the original exercise plan.

---

## 2. Tooling Lessons

### 2.1 EHRbase 2.11.0

EHRbase works well as a development CDR. The REST API is clean and well-documented. Key lessons:

- **Pin the version.** EHRbase 2.x has seen significant API changes. Docker image tag `ehrbase/ehrbase:2.11.0` used throughout.
- **Composition commit returns 204** with `Prefer: return=minimal`. UID is in the ETag header (quoted). Accept 200, 201, and 204 as success.
- **Namespace validation:** `[a-zA-Z][a-zA-Z0-9-_:/&+?]*` — dots are not allowed. Use hyphens as separators.
- **DV_CODED_TEXT validation:** EHRbase enforces exact text match between composition values and archetype term definitions. Composition builders must derive display text from the template.
- **Template re-deployment:** HTTP 409 on duplicate template_id. For development: `docker compose down -v` and restart. For production: `ehrbase.template.allow-overwrite=true`.
- **AQL limitations in 2.11.0:** COUNT/GROUP BY not supported. NOT EXISTS subqueries not supported. Both require application-level logic.

### 2.2 Archetype Designer

Free, web-based, adequate for the exercise. Key traps:

- **OPT export is broken in Chrome.** Hangs indefinitely. Use Firefox for all OPT exports.
- **Unassigned elements default to BOOLEAN** — the first type alphabetically. Always explicitly set every element's data type.
- **Term definitions are edited in the archetype, not the template.** Templates inherit from archetypes and constrain further. This is the two-level modelling principle.
- **Hand-written OPT XML is not viable.** The tooling-generated OPT for a simple archetype is 677 lines of XML with structural details that are difficult to produce correctly by hand.

### 2.3 Syside Modeler 0.8.5

Relevant findings from Phase E SysML work:

- **`@metadata` on part defs works.** Cross-project import resolves correctly. Hover tooltip shows doc string and source location. Queryable via Syside Automator metadata filtering.
- **`@metadata` on attributes fails.** Parser does not accept `@` annotations inside attribute bodies.
- **`doc /* */` after `attribute ... ;` fails.** `doc` blocks require attachment to an element with a body `{ }`. Use inline `//` comments for per-attribute documentation.
- **`comment` is a reserved word.** Cannot be used as an attribute name. Same class of trap as `ordered` and `accepted` in state machines.

---

## 3. Architectural Patterns Validated

### 3.1 Two data paths, one CDR

Both workflow-driven (Temporal activities commit compositions) and form-driven (SvelteKit endpoints commit directly) paths produce the same structured, queryable data. The CDR validates against the template regardless of the source. This is the foundation for GenderSense: clinical pathways and ad hoc clinical recording use the same data infrastructure.

### 3.2 Two views onto the same data

The process view (Temporal workflow state and history) and the entity view (AQL queries against the CDR by archetype type) are complementary perspectives on the same events. A blood result committed by a pathway activity appears in both the workflow audit trail and the blood results entity view. No data duplication.

### 3.3 Application-level join for governance

Two AQL queries (one per composition type), joined in TypeScript by EHR ID. This is the practical pattern for governance audits because: EHRbase doesn't support complex AQL (NOT EXISTS, aggregation), application code can apply arbitrary matching logic, and the pattern scales to clinical governance queries where the rules may exceed what AQL can express.

### 3.4 Composition builder per template

Each template has a dedicated builder function that maps application-level values to canonical JSON. The builder handles the RM hierarchy, coded term lookups, and structural differences between RM classes (OBSERVATION/EVALUATION/ACTION). For the coffee shop, hand-maintained lookup tables work. For GenderSense, builders should be generated from OPTs or archetypes.

### 3.5 EHRbase client as shared infrastructure

The TypeScript EHRbase client module (`ehrbase-client.ts`) lives in the shared package and is consumed by both Temporal activities (workflow path) and SvelteKit endpoints (form path). The `getOrCreateEhr` pattern makes EHR resolution idempotent. This transfers directly to GenderSense.

### 3.6 `@OpenEhrArchetype` metadata for model-CDR traceability

SysML part defs annotated with `@OpenEhrArchetype { archetypeId = "..."; rmClass = "..."; }` provide machine-queryable traceability between the model and the CDR archetype layer. Per-element mapping uses inline comments. Template-level traceability via `@OpenEhrTemplate`. This is adequate for current needs; a future generator could consume the archetype-level metadata to produce composition builder code.

---

## 4. Recommendations for GenderSense Clinical Data

### 4.1 Immediate: select clinical archetypes from CKM

Begin selecting existing archetypes from the openEHR Clinical Knowledge Manager for the hormone therapy initiation pathway. Many clinical concepts already have well-designed archetypes: laboratory results, medication orders and administration, vital signs, clinical assessments, patient questionnaires. The discipline of reuse-first is essential — the coffee shop exercise required custom archetypes because no coffee archetypes exist, but clinical archetypes are mature.

### 4.2 Immediate: design GenderSense-specific templates

Templates compose existing archetypes into use-case-specific data sets. A "hormone monitoring bloods" template might compose existing lab result archetypes with GenderSense-specific constraints (which tests, which ranges). Design templates in Archetype Designer, export OPTs via Firefox.

### 4.3 Near-term: generate composition builders from OPTs

Hand-maintained composition builders don't scale to clinical archetypes with hundreds of terms. Write a generator that reads the OPT XML and produces TypeScript builder functions with correct term mappings, RM hierarchy, and ISM transition handling for ACTION archetypes. This is the next generation pipeline extension after the existing SysML-to-Temporal generators.

### 4.4 Near-term: SNOMED CT terminology binding

Design archetypes with SNOMED CT terminology binding from the outset. The binding pattern is the same as the local-code pattern used in the exercise — only the terminology source changes. The openEHR/SNOMED CT collaboration means binding patterns are increasingly well-documented.

### 4.5 Near-term: modify `prepareDrink` to commit compositions

The preparation composition builder and EHRbase template are in place. Modifying the `prepareDrink` activity to commit preparation compositions (mirroring `validateOrder`) would bring workflow orders into governance compliance and complete the CDR integration for the coffee shop domain.

### 4.6 Medium-term: scheduled governance audits as Temporal workflows

The on-demand governance audit (Phase D) should evolve into scheduled Temporal cron workflows for GenderSense. The pattern: query CDR for expected compositions (derived from pathway model constraints), query for actual compositions, join in application code, produce governance reports, and optionally trigger contingency workflows for identified gaps.

### 4.7 Medium-term: evaluate EHRbase vs commercial CDR

EHRbase is excellent for development. For production, evaluate operational burden against commercial openEHR CDR options (Better, EHRbase commercial support). The REST API is standardised, so the application code is CDR-implementation-agnostic.

### 4.8 Deferred: FHIR bridge for NHS interoperability

EHRbase supports a FHIR-to-openEHR bridge. This is relevant for NHS interoperability (GP Connect, NHS Spine) but not needed until GenderSense integrates with external NHS systems. Design the CDR layer correctly now; the FHIR bridge adds a translation layer later.

---

## 5. Files Produced by Phase E

| File | Purpose |
|---|---|
| `model/foundation.sysml` | **Modified.** Three openEHR metadata defs added to MetadataLibrary: `@OpenEhrArchetype`, `@OpenEhrElement` (limited — see findings), `@OpenEhrTemplate` |
| `exercises/coffeeshop-demonstrator/model/coffeeshop-archetypes.sysml` | **New.** Coffee shop archetype/template mappings as SysML part defs with metadata annotations |
| `model/platform.sysml` | **Modified.** Platform::EHR package elaborated with CdrConnection, EhrRecord, RegisteredTemplate, Composition, AqlQuery part defs and updated use cases |
| `documentation/gsl-cdr-exercise-summary-2026-03-08.md` | **New.** This document |

---

## 6. Syntax Reference Updates (v3.4)

The following findings from Phase E should be incorporated into the syntax reference:

- **`@metadata` on `part def` — verified working.** Ticks off the TODO item.
- **`@metadata` on `attribute` — fails.** Parser does not accept metadata annotations inside attribute bodies.
- **`doc /* */` after `attribute ... ;` — fails.** `doc` blocks cannot follow a semicolon-terminated attribute.
- **`comment` is a reserved word.** Added to the reserved/shadowed name list alongside `ordered` and `accepted`.
- **Inline `//` comments after attributes — works.** Lexer-level, always legal. Recommended for per-attribute documentation.

---

## 7. CDR Exercise Phase Summary

| Phase | Sessions | Key deliverable | Clinical analogy validated |
|---|---|---|---|
| A — Infrastructure | 1–2 | EHRbase running, ORDER_RECORD archetype, template uploaded, round-trip composition | Standing up a CDR and designing clinical archetypes |
| B — Temporal integration | 3 | EHRbase client, composition builder, workflow activity commits to CDR | Pathway activities recording clinical data |
| C — Entity views | 4 | AQL queries, SvelteKit endpoints, feedback form, process-vs-entity comparison | Entity views, ad hoc clinical recording, dual-perspective architecture |
| D — Governance audit | 5 | PREPARATION_EVENT, test data seeder, population-level audit, SvelteKit report | Population-level clinical governance |
| E — Model updates | 6 | `@OpenEhrArchetype` metadata, Platform::EHR elaboration, this summary | Model-CDR traceability, architectural documentation |

---

## 8. Conclusion

The CDR exercise has validated every integration pattern identified in the architecture principles document. The openEHR CDR fits cleanly alongside Temporal workflow orchestration and XState state machine enforcement. The separation principle holds: clinical data structure lives in archetypes (representation layer), the CDR stores and validates compositions (execution layer), and the SysML model provides traceability to both.

The coffee shop domain served its purpose exactly as intended — exercising the openEHR machinery without the cognitive overhead of clinical semantics. The patterns are now proven and documented. The next step is to apply them to real clinical data, starting with archetype selection from CKM for the hormone therapy initiation pathway.

---

*Summary prepared 8 March 2026 (Session 6). Companion to the Architecture Principles document, the CDR Exercise Plan, and Session Reports 1–6.*
