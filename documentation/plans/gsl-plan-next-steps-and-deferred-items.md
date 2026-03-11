# GSL — Next Steps and Deferred Items

**Last updated:** 11 March 2026 (Session 19 — Business Meta Model Phase 7 complete)

**Purpose:** Living tracker of carried-forward items, deferred decisions, and potential next workstreams. Completed items are removed at each update — completion is recorded in session reports.

---

## 1. Candidate Next Workstreams

These are the natural next directions after completing the Business Meta Model (Phases 1–7) and Knowledge Layer Elaboration (Phases 1–5). Not prioritised — selection depends on what feels most valuable at session planning time.

### Coffee Shop Knowledge Layer Increments

Three increments from the demonstrator integration plan, not yet executed. These exercise the Knowledge layer in a running system (Temporal workflows, generated evaluators, SvelteKit UI).

- **Increment 1 — Constraint evaluation at a pathway step.** Full chain: SysML constraint def → generated evaluator → Temporal activity → structured EvaluationResult. Tests generator domain-agnosticism.
- **Increment 2 — Decision table for drink routing.** Decision table pattern producing explainable recommendations in a non-clinical domain.
- **Increment 3 — System self-assessment.** Five-layer self-knowledge pattern simplified but genuine. Dashboard: "The coffee shop has processed 47 orders today. 3 orders are awaiting preparation beyond the 10-minute target."

Source: `gsl-plan-coffeeshop-demonstrator-integration-2026-03-10.md` section 4.

### Second Clinical Pathway

Model a second clinical pathway (ongoing monitoring, shared care transition, or follow-up assessment). Tests whether the architecture generalises and triggers cross-pathway rule sharing. Would also validate the ServiceOffering→ClinicalPathway mapping that is currently string-referenced.

### Model Consolidation Review

Step back and review the complete model across all packages for naming consistency, doc block gaps, structural simplification opportunities, and package hierarchy clarity. The model has grown substantially through 19 sessions.

### Variant C Elaboration

"Consultancy + Platform Licence" — dual revenue streams (clinical + SaaS). Requires modelling licence pricing, platform deployment for licensees, and support cost structures. Natural extension of Phase 5.

---

## 2. SysML Model — Deferred Structural Items

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

## 3. Knowledge Layer — Deferred Items

- **Prolog implementation** — explored and evaluated, not built until clinical rules demand inference capabilities beyond boolean constraints
- **DMN engine integration** — decision tables modelled in SysML; dedicated DMN engine is an optimisation
- **ML/LLM integration** — Tier 3 is interface-only; advisory capabilities depend on data volume and clinical validation
- **Cross-pathway rule sharing** — hormone therapy constraints are pathway-specific; generalisation when a second pathway is modelled
- **External clinical knowledge sources** — NICE guidelines, BNF, drug interaction databases are integration concerns
- **Full manifest generation** — concept designed; generator is a convenience, not a prerequisite
- **Compound remediation reasoning** — Layer 5 compound/advisory remediation is architecturally specified but deferred until real deficit patterns are observed

---

## 4. Projection Engine — Deferred Items

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

## 5. CDR / openEHR — Deferred Items

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

## 6. Generators — Designed but Not Built

- **Temporal workflow generator extension** — emit `evaluationEngine.evaluate()` calls from `@LogicRule` / `@SafetyConstraint` metadata
- **Composition builder generator** — OPT XML → TypeScript CDR composition builders
- **Outcome evaluator generator** — `OutcomeDefinition` usages → TypeScript outcome evaluation functions
- **Prolog rule generator** — `constraint def` → Tau Prolog rules (contingent on Tier 2 adoption)
- **Projection generator** — `ProjectionFormula` usages → projection engine code

---

## 7. Syntax Reference — Unverified Patterns

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

## 8. Major Completed Workstreams (Reference)

These are complete and documented in session reports. Listed here for orientation only.

| Workstream | Sessions | Status |
|---|---|---|
| Coffee Shop Demonstrator (Phases A–D) | 1–4 | Complete |
| Coffee Shop CDR Exercise (Phases A–E) | 1–6 | Complete |
| Hormone Therapy Initiation Modelling | 5–7 | Complete |
| Knowledge Layer Elaboration (Phases 1–5) | 8–12 | Complete |
| Business Meta Model (Phases 1–7) | 13–19 | Complete |
| Coffee Shop Business Model Extensions | 14–19 | Complete (per-phase parity) |

---

*Restructured 11 March 2026 (Session 19). Previous version was an accumulation of per-session findings; this version is a clean carried-forward tracker.*
