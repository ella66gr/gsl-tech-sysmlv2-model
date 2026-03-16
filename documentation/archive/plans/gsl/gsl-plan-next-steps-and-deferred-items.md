# GSL — Next Steps and Deferred Items

**Last updated:** 15 March 2026 (Session 31 — Knowledge Graph Enhancement complete. Concept Graph workstream fully closed.)

**Purpose:** Living tracker of carried-forward items, deferred decisions, and potential next workstreams. Completed items are removed at each update — completion is recorded in session reports.

---

## 1. Active Workstream

**No active workstream.** Next session should select from candidates below. A periodic model review is recommended at this workstream boundary.

### Recently Completed

| Workstream | Sessions | Closed |
|---|---|---|
| CSW Extension (Phases 1–10) | 20–29 | Session 29 |
| Concept Graph (Stages 1–8) | 30–31 | Session 31 |
| Knowledge Graph Enhancement (Stages 1–6) | 31 | Session 31 |

---

## 2. Standing Practice: Periodic Code and Model Reviews

**Convention (established Session 30):** The project conducts proactive code and model reviews at suitable pauses — typically after completing a workstream, before starting a new one, or when the model has grown significantly. Reviews cover:

- **Type safety:** Wildcard import collisions, enum-vs-String mismatches, unqualified ambiguous types.
- **Naming consistency:** Reserved word traps, domain-agnostic naming in meta model, compound naming convention.
- **Structural integrity:** Doc block gaps, cross-reference formalisation status, package hierarchy clarity.
- **Silent failure detection:** Syside parse anomalies, cascading reference-errors from upstream issues, unused imports.
- **Convention compliance:** Import collision convention, two meta model classification in doc blocks, commit message format.

**Last review:** Partial — Session 30 (wildcard import collision audit across all `.sysml` files).
**Next recommended review:** Now — workstream boundary after Knowledge Graph Enhancement. Full model review covering 11 `.sysml` files.

---

## 3. Candidate Next Workstreams

### Coffee Shop Knowledge Layer Increments

Three increments from the demonstrator integration plan, not yet executed. All UI landing zones are built.

- **Increment 1 — Constraint evaluation at a pathway step.** Full chain: SysML constraint def → generated evaluator → Temporal activity → structured EvaluationResult. Landing zone: Order Timeline page (Phase 7 ✓). **Unblocked** (Session 26).
- **Increment 2 — Decision table for drink routing.** Decision table pattern producing explainable recommendations. Landing zone: Counter page (Phase 5 ✓). **Unblocked** (Session 24).
- **Increment 3 — System self-assessment.** Five-layer self-knowledge pattern. Landing zone: System Status page (Phase 9 ✓). **Unblocked** (Session 28).

Source: `gsl-plan-coffeeshop-demonstrator-integration-2026-03-10.md` section 4.

### Second Clinical Pathway

Model a second clinical pathway (ongoing monitoring, shared care transition, or follow-up assessment). Tests whether the architecture generalises and triggers cross-pathway rule sharing. Would also validate the ServiceOffering→ClinicalPathway mapping that is currently string-referenced. Should include `NotificationTrigger` metadata and `AgencyClassification` annotations (now available in MetadataLibrary).

### Model Consolidation Review

The model has grown substantially across 31 sessions. Review for naming consistency, doc block gaps, structural simplification opportunities, package hierarchy clarity.

### System Meta Model Extraction

The business system meta model is currently implicit across Foundation, Platform, ServiceDelivery, Knowledge, and Operations. Phase 10 added to it (PersistencePolicy, AgencyClassification) with explicit doc blocks. A future workstream could promote these concepts into a named, navigable meta model structure.

### Variant C Elaboration

"Consultancy + Platform Licence" — dual revenue streams (clinical + SaaS). Requires modelling licence pricing, platform deployment for licensees, and support cost structures.

### Hookmark Cross-Desktop Linking Spike

Hookmark is installed and licensed. Spike: hook key artefacts together (pattern notes ↔ `.sysml` files, session reports ↔ discussion papers), evaluate navigation payoff. Configure `hook://file/` URI scheme for Obsidian. Cannot be programmatically controlled — manual practice only.

**Effort:** 1 hour spike.

### Visualisation: Tom Sawyer SysML v2 Viewer (Horizon)

Investigate the standalone Tom Sawyer SysML v2 Viewer for stakeholder-facing interactive model views. Requires a SysML v2 API-compliant repository. 

**When:** When stakeholder communication becomes a priority.

### Visualisation: Alternative Diagramming (Horizon)

D2, Graphviz/DOT, Structurizr as complementary diagramming alongside Mermaid.

### Tooling Evolution: Claude Code, Cowork, Obsidian Integrations

**Claude Code** — validated for implementation-heavy tasks (Session 31 Stage 4 handoff successful). Explore `CLAUDE.md` project file encoding architecture rules. Custom `/commands` for recurring workflows. Not urgent — current hybrid workflow (Chat for SysML + Code for Python) is productive.

**Claude Cowork** — explore for batch cross-file operations when needed.

**Obsidian integrations** — explore when broader Obsidian use develops. See Perplexity landscape survey.

---

## 4. SysML Model — Deferred Structural Items

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

## 5. Knowledge Layer — Deferred Items

- **Prolog implementation** — deferred until clinical rules demand inference
- **DMN engine integration** — decision tables modelled; dedicated engine is an optimisation
- **ML/LLM integration** — Tier 3 is interface-only
- **Cross-pathway rule sharing** — when second pathway is modelled
- **External clinical knowledge sources** — integration concern
- **Full manifest generation** — concept designed; generator is convenience
- **Compound remediation reasoning** — deferred until real deficit patterns observed

---

## 6. Projection Engine — Deferred Items

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

## 7. CDR / openEHR — Deferred Items

- Clinical archetype design, SNOMED CT binding, CDR hosting, openEHR SDK, FHIR bridge, Folders, versioning/contributions, generator updates — all deferred per previous sessions.

---

## 8. Generators — Designed but Not Built

- Temporal workflow generator extension (evaluation calls)
- Composition builder generator
- Outcome evaluator generator
- Prolog rule generator
- Projection generator

### Generator bugs (Session 20)

- `gen_typescript_types.py` enum doc block parsing — multi-line doc blocks cause literal drop
- `gen_typescript_types.py` space before multiplicity bracket — regex expects `Type[0..*]` not `Type [0..*]`

---

## 9. Deferred Items from Phase 3 (Session 22)

### CDR price mismatch

Order composition builder uses hardcoded price terms that don't match catalogue. Tagged as TODO.

### Composite orders (multi-item baskets)

Currently one order = one workflow = one item. Composite order model deferred.

### Food item workflow limitation

`FulfilDrink` is drink-specific. Food items can be ordered but workflow is drink-centric.

---

## 10. Frontend — Notes from Phases 4–9 (Sessions 23–28)

All frontend findings from previous sessions remain current (Flowbite component compatibility, hand-crafted SVG pathway, direct module imports, Svelte 5 `{@const}`, Temporal sandbox, barrel export SSR failure, dark mode palette, Modal footer slot, layout max-width, CDR "None" milk display, upgrade path to flowbite-svelte 2.0).

---

## 11. Syntax Reference — Findings Requiring Update

**Session 31 findings (for v3.13):**

- [x] `ref :>> fieldName = (target);` — single-target tuple redefinition ✅
- [x] `ref :>> fieldName = (targetA, targetB);` — multi-valued tuple redefinition ✅
- [x] Circular `ref :>>` between peer part usages ✅
- [x] Cross-type `ref :>>` (Pattern instance referencing ArchitecturalPrinciple peer parts) ✅
- [x] Forward reference in `ref :>>` ✅

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
- [ ] Multi-valued enum `:>>` redefinition with tuple syntax on instances

---

## 12. Major Completed Workstreams (Reference)

| Workstream | Sessions | Status |
|---|---|---|
| Coffee Shop Demonstrator (Phases A–D) | 1–4 | Complete |
| Coffee Shop CDR Exercise (Phases A–E) | 1–6 | Complete |
| Hormone Therapy Initiation Modelling | 5–7 | Complete |
| Knowledge Layer Elaboration (Phases 1–5) | 8–12 | Complete |
| Business Meta Model (Phases 1–7) | 13–19 | Complete |
| Coffee Shop Business Model Extensions | 14–19 | Complete |
| CSW Extension (Phases 1–10) | 20–29 | Complete |
| **Concept Graph + Knowledge Graph Enhancement** | **30–31** | **Complete** |

---

## 13. Two-Phase Generation Pipeline (Session 24)

Discussion paper: `gsl-discussion-two-phase-generation-pipeline-2026-03-13.md`. Not yet a committed workstream.

---

*Updated 15 March 2026 (Session 31). Knowledge Graph Enhancement complete. No active workstream.*
