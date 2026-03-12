# GSL — Next Steps and Deferred Items

**Last updated:** 12 March 2026 (Session 22 — CSW Extension Phase 3 complete)

**Purpose:** Living tracker of carried-forward items, deferred decisions, and potential next workstreams. Completed items are removed at each update — completion is recorded in session reports.

---

## 1. Active Workstream

### CSW Extension — Catalogue, Inventory & Frontend

**Plan:** `gsl-plan-workstream-csw-extension-2026-03-12.md`
**Status:** Phase 3 complete, Phase 4 next

| Phase | Status |
|---|---|
| 0: Conceptual modelling | ✓ Complete |
| 1: SysML domain model update | ✓ Complete (Session 20) |
| 2: PostgreSQL foundation | ✓ Complete (Session 21) |
| 3: Catalogue & inventory API routes | ✓ Complete (Session 22) |
| 4: Frontend foundation (Tailwind v4 + Flowbite) | Next |
| 5: Counter page (dynamic order form) | Planned |
| 6: Manager GUI — stock & catalogue | Planned |
| 7: Remaining operations pages | Planned |
| 8: Data & insights pages | Planned |
| 9: System pages | Planned |
| 10: Meta model update | Planned |

---

## 2. Candidate Next Workstreams (After CSW Extension)

### Coffee Shop Knowledge Layer Increments

Three increments from the demonstrator integration plan, not yet executed. The CSW Extension frontend (Phases 4–9) creates the UI landing zones for these increments.

- **Increment 1 — Constraint evaluation at a pathway step.** Full chain: SysML constraint def → generated evaluator → Temporal activity → structured EvaluationResult. Landing zone: Order Timeline page (Phase 7).
- **Increment 2 — Decision table for drink routing.** Decision table pattern producing explainable recommendations. Landing zone: Counter page (Phase 5).
- **Increment 3 — System self-assessment.** Five-layer self-knowledge pattern. Landing zone: System Status page (Phase 9).

Source: `gsl-plan-coffeeshop-demonstrator-integration-2026-03-10.md` section 4.

### Second Clinical Pathway

Model a second clinical pathway (ongoing monitoring, shared care transition, or follow-up assessment). Tests whether the architecture generalises and triggers cross-pathway rule sharing. Would also validate the ServiceOffering→ClinicalPathway mapping that is currently string-referenced.

### Model Consolidation Review

Step back and review the complete model across all packages for naming consistency, doc block gaps, structural simplification opportunities, and package hierarchy clarity. The model has grown substantially through 22 sessions.

### Variant C Elaboration

"Consultancy + Platform Licence" — dual revenue streams (clinical + SaaS). Requires modelling licence pricing, platform deployment for licensees, and support cost structures. Natural extension of Phase 5.

---

## 3. SysML Model — Deferred Structural Items

### Cross-references not yet formalised

- **`ref` from ResourceConstraint to Enterprise::Regulation requirement defs** — deferred from Phase 7. A `ref` targeting a `requirement def` (as opposed to a `part def`) needs separate syntax investigation. Currently string-referenced via `regulatorySourceDescription`. *(Low priority — doc block cross-reference is adequate.)*
- **`ref` from ServiceOffering to ServiceDelivery::ClinicalPathways** — `clinicalPathwayRef` is currently a String. Formalising this creates a cross-domain coupling (business model → service delivery). Deferred until the coupling implications are understood. *(Medium priority — becomes relevant when a second pathway is modelled.)*
- **Formal `ref` from ScenarioComparison to ScenarioDefinition** — `scenarioRefs` is currently String. Low priority.

### Domain-specific naming

- **`activePatientsTotal` / `actualPatientCount`** in ProjectionOutput and PeriodActuals — healthcare-specific. Set to 0 in coffee shop context. Generalisation to a domain-agnostic name (e.g. `activeCustomersTotal`) is deferred. *(Low priority — cosmetic.)*

### Syside syntax limitations (documented, not blockers)

- **`satisfy requirement X by partUsage`** fails with type-error. `satisfy` is for requirement→constraint traceability only. Objective→Capability traceability uses `ObjectiveCapabilityMapping`. *(Documented in syntax reference v3.11. Not a blocker — mapping pattern is equivalent.)*
- **`ref` to `requirement def` as a type** — untested. Needed for ResourceConstraint→Regulation formalisation. *(Added to syntax reference TODO.)*

---

## 4. Knowledge Layer — Deferred Items

- **Prolog implementation** — explored and evaluated, not built until clinical rules demand inference capabilities beyond boolean constraints
- **DMN engine integration** — decision tables modelled in SysML; dedicated DMN engine is an optimisation
- **ML/LLM integration** — Tier 3 is interface-only; advisory capabilities depend on data volume and clinical validation
- **Cross-pathway rule sharing** — hormone therapy constraints are pathway-specific; generalisation when a second pathway is modelled
- **External clinical knowledge sources** — NICE guidelines, BNF, drug interaction databases are integration concerns
- **Full manifest generation** — concept designed; generator is a convenience, not a prerequisite
- **Compound remediation reasoning** — Layer 5 compound/advisory remediation is architecturally specified but deferred until real deficit patterns are observed

---

## 5. Projection Engine — Deferred Items

### Parameter validation (requires Ella's clinical input)

- **`effectiveMonthlyRevenuePerPatient`** — existing `monitoringFeePerQuarter` (£150) captures only the quarterly blood review fee. The effective blended revenue is ~£134/patient/month (~£400/quarter). Needs validation against actual clinical pricing intentions.
- **Overhead percentage** — 25% may be too high given the granular lab cost model. Needs review.

### Engine enhancements

- Clinician utilisation model extension — include non-patient-facing activities (governance, CPD, admin, documentation)
- Plotting / visualisation (matplotlib or similar) — CSV export to spreadsheet is currently sufficient
- Manifest integration — engine reads parameter values from generated System Model Manifest JSON
- Projection generator — SysML `ProjectionFormula` usages → engine code. Deferred until formula patterns stabilise.
- Sensitivity "dominant" text formatting — minor fix needed when break-even not reached in either scenario
- Coffee shop subscription scenario not wired into projection engine — SysML complete, engine dict missing entry. Low priority.

### SysML model updates (after parameter validation)

- Update illustrative `ProjectionOutput` values to match validated engine output
- Consider splitting monitoring revenue into explicit initiation-period and stable-period fees

---

## 6. CDR / openEHR — Deferred Items

These were identified during the Coffee Shop CDR Exercise (Sessions 1–6) and are relevant when moving to clinical data implementation.

- **Clinical archetype design** — archetype selection from CKM and template design, after the CDR exercise validates integration patterns
- **SNOMED CT terminology binding** — exercise uses local codes; SNOMED binding depends on clinical content
- **CDR hosting and deployment** — local Docker for now; production hosting decision (EHRbase self-hosted vs commercial) is later
- **openEHR SDK / code generation** — raw REST API currently; SDKs and OPT code generation are optional
- **FHIR bridge** — EHRbase supports FHIR-to-openEHR; relevant for NHS interoperability
- **openEHR Folders** — not needed for current simple data model
- **Versioning and contributions** — audit-grade contributions acknowledged but not exercised beyond basic commit
- **Generator updates** — `gen_temporal_workflow.py` emitting CDR commit code is a future concern

---

## 7. Generators — Designed but Not Built

- **Temporal workflow generator extension** — emit `evaluationEngine.evaluate()` calls from `@LogicRule` / `@SafetyConstraint` metadata
- **Composition builder generator** — OPT XML → TypeScript CDR composition builders
- **Outcome evaluator generator** — `OutcomeDefinition` usages → TypeScript outcome evaluation functions
- **Prolog rule generator** — `constraint def` → Tau Prolog rules (contingent on Tier 2 adoption)
- **Projection generator** — `ProjectionFormula` usages → projection engine code

### Generator bugs (found Session 20)

- **`gen_typescript_types.py` — enum doc block parsing:** Multi-line doc blocks inside `enum def` cause the first literal after the doc block to be dropped or concatenated with doc text. Root cause: the regex-based variant filter strips lines starting with `doc` or `/*` but doesn't properly handle multi-line `/* ... */` blocks where continuation lines start with `*`.
- **`gen_typescript_types.py` — space before multiplicity bracket:** The part regex expects `Type[0..*]` (no space) but SysML idiom is `Type [0..*]` (with space). `part externalRefs : ExternalReference [0..*]` was not matched by the generator.

Both bugs were worked around by hand-fixing the generated output. The generator is documented as a lightweight text-based parser; the long-term fix is to replace it with Syside Automator for proper semantic model access.

---

## 8. Deferred Items from Phase 3 (Session 22)

### CDR price mismatch

The order composition builder (`composition-builder.ts`) uses hardcoded coded price terms (`at0020`–`at0023` mapping to £1.25–£2.85) that don't match the catalogue prices (e.g. Flat White is £2.80 in the catalogue). The catalogue (PostgreSQL) is now the authoritative price source. The CDR records an approximate price bracket. Resolution options: update the archetype to accept `DV_QUANTITY` with currency, or add new coded terms matching the full price list. Tagged as TODO for Phase 10 (meta model update).

### Food item workflow limitation

The `FulfilDrink` workflow is drink-specific. Food items (Ginger Biscuit, Oat Bar) can be ordered via the catalogue-validated `POST /api/orders`, and their inventory is correctly decremented, but the Temporal workflow will fail during drink-specific activities. A separate `FulfilFoodOrder` workflow or a generic `FulfilOrder` with item-type-aware routing is a future concern. Not blocking for the current exercise — the catalogue validation and inventory mechanics are the demonstration targets.

---

## 9. Syntax Reference — Unverified Patterns

Carried forward from syntax reference v3.11 TODO section.

- [ ] Port definitions and connections
- [ ] `metadata def` with non-scalar attribute types (e.g. enum-valued metadata attributes)
- [ ] `metadata def` specialisation (one metadata def extending another)
- [ ] `metadata def` applied to `state def` or `requirement def` elements
- [ ] `use case def` with `include use case`, `extend use case`, `subject`, `actor`
- [ ] SysML v2 `view` and `viewpoint` elements — Syside forum confirms rendering is "still a work in progress"
- [ ] Syside CLI `viz` command for headless diagram export
- [ ] Generator: `gen_temporal_workflow.py` emitting `tryTransition()` from `@StateTransitionTrigger`
- [ ] Generator: `Promise.all()` from SysML `fork`/`join`
- [ ] Nested `:>>` redefinition inside contained parts inside part usages
- [ ] `ref` to a `requirement def` as a type (added Phase 7)

---

## 10. Major Completed Workstreams (Reference)

These are complete and documented in session reports. Listed here for orientation only.

| Workstream | Sessions | Status |
|---|---|---|
| Coffee Shop Demonstrator (Phases A–D) | 1–4 | Complete |
| Coffee Shop CDR Exercise (Phases A–E) | 1–6 | Complete |
| Hormone Therapy Initiation Modelling | 5–7 | Complete |
| Knowledge Layer Elaboration (Phases 1–5) | 8–12 | Complete |
| Business Meta Model (Phases 1–7) | 13–19 | Complete |
| Coffee Shop Business Model Extensions | 14–19 | Complete (per-phase parity) |
| CSW Extension Phase 1 (domain model) | 20 | Complete |
| CSW Extension Phase 2 (PostgreSQL foundation) | 21 | Complete |
| CSW Extension Phase 3 (catalogue & inventory API) | 22 | Complete |

---

*Updated 12 March 2026 (Session 22). CSW Extension workstream active — Phase 3 complete, Phase 4 next.*
