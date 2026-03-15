# GSL — Next Steps and Deferred Items

**Last updated:** 14 March 2026 (Session 29 — CSW Extension Phase 10 complete, workstream complete)

**Purpose:** Living tracker of carried-forward items, deferred decisions, and potential next workstreams. Completed items are removed at each update — completion is recorded in session reports.

---

## 1. Active Workstream

### CSW Extension — Complete

**Plan:** `gsl-plan-workstream-csw-extension-2026-03-12.md`
**Status:** All 10 phases complete (Sessions 20–29). Workstream closed.

| Phase | Status |
|---|---|
| 0: Conceptual modelling | ✓ Complete |
| 1: SysML domain model update | ✓ Complete (Session 20) |
| 2: PostgreSQL foundation | ✓ Complete (Session 21) |
| 3: Catalogue & inventory API routes | ✓ Complete (Session 22) |
| 4: Frontend foundation (Tailwind v4 + Flowbite) | ✓ Complete (Session 23) |
| 5: Counter page (dynamic order form) | ✓ Complete (Session 24) |
| 6: Manager GUI — stock & catalogue | ✓ Complete (Session 25) |
| 7: Order Board & Order Timeline | ✓ Complete (Session 26) |
| 8: Data & insights pages | ✓ Complete (Session 27) |
| 9: System pages | ✓ Complete (Session 28) |
| 10: Meta model update | ✓ Complete (Session 29) |

**No active workstream.** Next session should select from candidates below.

---

## 2. Candidate Next Workstreams

### Coffee Shop Knowledge Layer Increments

Three increments from the demonstrator integration plan, not yet executed. All UI landing zones are built.

- **Increment 1 — Constraint evaluation at a pathway step.** Full chain: SysML constraint def → generated evaluator → Temporal activity → structured EvaluationResult. Landing zone: Order Timeline page (Phase 7 ✓). **Unblocked** (Session 26).
- **Increment 2 — Decision table for drink routing.** Decision table pattern producing explainable recommendations. Landing zone: Counter page (Phase 5 ✓). **Unblocked** (Session 24).
- **Increment 3 — System self-assessment.** Five-layer self-knowledge pattern. Landing zone: System Status page (Phase 9 ✓). **Unblocked** (Session 28).

Source: `gsl-plan-coffeeshop-demonstrator-integration-2026-03-10.md` section 4.

### Second Clinical Pathway

Model a second clinical pathway (ongoing monitoring, shared care transition, or follow-up assessment). Tests whether the architecture generalises and triggers cross-pathway rule sharing. Would also validate the ServiceOffering→ClinicalPathway mapping that is currently string-referenced. Should include `NotificationTrigger` metadata (item 9.3) and `AgencyClassification` annotations (item 9.1, now available in MetadataLibrary).

### Pattern Catalogue and Cross-Domain Concept Registry (CSW Phase 10 companion)

The project has reached a scale where the web of relationships between architectural patterns, domain concepts, deferred items, and their cross-domain analogues exceeds working memory. A formal concept registry is needed — primarily in SysML, with Obsidian as the navigation and exploration layer.

**SysML layer:** `Foundation::PatternCatalogue` package defining abstract architectural patterns as `part def`s. The two meta model distinction should be a top-level organising principle — patterns are classified as business meta model patterns or system meta model patterns.

**Obsidian layer:** Vault structure with templates and frontmatter. MCP bridge for Claude access during sessions.

**Scope:** 2 sessions. Source: Session 26 discussion.

### Model Consolidation Review

The model has grown substantially across 29 sessions. Review for naming consistency, doc block gaps, structural simplification opportunities, package hierarchy clarity. Workstream 6 items in the work analysis.

### System Meta Model Extraction

The business system meta model is currently implicit across Foundation, Platform, ServiceDelivery, Knowledge, and Operations. Phase 10 added to it (PersistencePolicy, AgencyClassification) with explicit doc blocks. A future workstream could promote these concepts into a named, navigable meta model structure. This is a longer-term architectural evolution, not an urgent need.

### Variant C Elaboration

"Consultancy + Platform Licence" — dual revenue streams (clinical + SaaS). Requires modelling licence pricing, platform deployment for licensees, and support cost structures.

---

## 3. SysML Model — Deferred Structural Items

### Cross-references not yet formalised

- **`ref` from ServiceOffering to ServiceDelivery::ClinicalPathways** — `clinicalPathwayRef` is currently a String. Medium priority — becomes relevant when a second pathway is modelled.
- **`ref` from ResourceConstraint to Enterprise::Regulation requirement defs** — deferred. Low priority.
- **Formal `ref` from ScenarioComparison to ScenarioDefinition** — `scenarioRefs` is currently String. Low priority.

### Domain-specific naming

- **`activePatientsTotal` / `actualPatientCount`** in ProjectionOutput and PeriodActuals — healthcare-specific. Low priority.

### Syside syntax limitations (documented, not blockers)

- **`satisfy requirement X by partUsage`** fails with type-error. Documented in syntax reference v3.11.
- **`ref` to `requirement def` as a type** — untested.
- **Cross-project specific named imports** — do not work (Session 29 finding). Use wildcards.

---

## 4. Knowledge Layer — Deferred Items

- **Prolog implementation** — deferred until clinical rules demand inference
- **DMN engine integration** — decision tables modelled; dedicated engine is an optimisation
- **ML/LLM integration** — Tier 3 is interface-only
- **Cross-pathway rule sharing** — when second pathway is modelled
- **External clinical knowledge sources** — integration concern
- **Full manifest generation** — concept designed; generator is convenience
- **Compound remediation reasoning** — deferred until real deficit patterns observed

---

## 5. Projection Engine — Deferred Items

### Parameter validation (requires Ella's clinical input)

- **`effectiveMonthlyRevenuePerPatient`** — needs validation against actual clinical pricing intentions.
- **Overhead percentage** — 25% may be too high.

### Engine enhancements

- Clinician utilisation model extension
- Plotting / visualisation
- Manifest integration
- Projection generator
- Coffee shop subscription scenario not wired into engine

---

## 6. CDR / openEHR — Deferred Items

- Clinical archetype design, SNOMED CT binding, CDR hosting, openEHR SDK, FHIR bridge, Folders, versioning/contributions, generator updates — all deferred per previous sessions.

---

## 7. Generators — Designed but Not Built

- Temporal workflow generator extension (evaluation calls)
- Composition builder generator
- Outcome evaluator generator
- Prolog rule generator
- Projection generator

### Generator bugs (Session 20)

- `gen_typescript_types.py` enum doc block parsing — multi-line doc blocks cause literal drop
- `gen_typescript_types.py` space before multiplicity bracket — regex expects `Type[0..*]` not `Type [0..*]`

---

## 8. Deferred Items from Phase 3 (Session 22)

### CDR price mismatch

Order composition builder uses hardcoded price terms that don't match catalogue. Tagged as TODO.

### Composite orders (multi-item baskets)

Currently one order = one workflow = one item. Composite order model deferred.

### Food item workflow limitation

`FulfilDrink` is drink-specific. Food items can be ordered but workflow is drink-centric.

---

## 9. Frontend — Notes from Phases 4–9 (Sessions 23–28)

All frontend findings from previous sessions remain current (Flowbite component compatibility, hand-crafted SVG pathway, direct module imports, Svelte 5 `{@const}`, Temporal sandbox, barrel export SSR failure, dark mode palette, Modal footer slot, layout max-width, CDR "None" milk display, upgrade path to flowbite-svelte 2.0).

---

## 10. Syntax Reference — Findings Requiring Update

**Session 29 findings (new — not yet in syntax reference):**

- [ ] `system` is a KerML reserved word — cannot be used as an enum literal. Silent parse failure.
- [ ] Enum-typed attribute on metadata def — verified ✓
- [ ] Cross-project specific named imports — do not work. Use wildcards.
- [ ] Multi-valued enum attribute on part def (definition level) — verified ✓
- [ ] Multi-valued enum `:>>` redefinition with tuple syntax on instances — untested

**Previous TODO items (unchanged):**

- [ ] Port definitions and connections
- [ ] `metadata def` specialisation (one metadata def extending another)
- [ ] `metadata def` applied to `state def` or `requirement def` elements
- [ ] `use case def` with `include use case`, `extend use case`, `subject`, `actor`
- [ ] SysML v2 `view` and `viewpoint` elements
- [ ] Syside CLI `viz` command for headless diagram export
- [ ] Generator: `gen_temporal_workflow.py` emitting `tryTransition()` from `@StateTransitionTrigger`
- [ ] Generator: `Promise.all()` from SysML `fork`/`join`
- [ ] Nested `:>>` redefinition inside contained parts inside part usages
- [ ] `ref` to a `requirement def` as a type

---

## 11. Major Completed Workstreams (Reference)

| Workstream | Sessions | Status |
|---|---|---|
| Coffee Shop Demonstrator (Phases A–D) | 1–4 | Complete |
| Coffee Shop CDR Exercise (Phases A–E) | 1–6 | Complete |
| Hormone Therapy Initiation Modelling | 5–7 | Complete |
| Knowledge Layer Elaboration (Phases 1–5) | 8–12 | Complete |
| Business Meta Model (Phases 1–7) | 13–19 | Complete |
| Coffee Shop Business Model Extensions | 14–19 | Complete |
| **CSW Extension (Phases 1–10)** | **20–29** | **Complete** |

---

## 12. Two-Phase Generation Pipeline (Session 24)

Discussion paper: `gsl-discussion-two-phase-generation-pipeline-2026-03-13.md`. Not yet a committed workstream.

---

*Updated 14 March 2026 (Session 29). CSW Extension workstream complete. No active workstream — next session selects from candidates.*
