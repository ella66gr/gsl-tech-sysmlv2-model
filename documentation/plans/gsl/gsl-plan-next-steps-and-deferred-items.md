# GSL — Next Steps and Deferred Items

**Last updated:** 14 March 2026 (Session 28 — CSW Extension Phase 9 complete)

**Purpose:** Living tracker of carried-forward items, deferred decisions, and potential next workstreams. Completed items are removed at each update — completion is recorded in session reports.

---

## 1. Active Workstream

### CSW Extension — Catalogue, Inventory & Frontend

**Plan:** `gsl-plan-workstream-csw-extension-2026-03-12.md`
**Status:** Phase 9 complete, Phase 10 next

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
| 10: Meta model update | **Next** |

---

## 2. Candidate Next Workstreams (After CSW Extension)

### Coffee Shop Knowledge Layer Increments

Three increments from the demonstrator integration plan, not yet executed. The CSW Extension frontend (Phases 4–9) creates the UI landing zones for these increments.

- **Increment 1 — Constraint evaluation at a pathway step.** Full chain: SysML constraint def → generated evaluator → Temporal activity → structured EvaluationResult. Landing zone: Order Timeline page (Phase 7). **Now unblocked** — Order Timeline complete (Session 26).
- **Increment 2 — Decision table for drink routing.** Decision table pattern producing explainable recommendations. Landing zone: Counter page (Phase 5). **Now unblocked** — Counter page complete (Session 24).
- **Increment 3 — System self-assessment.** Five-layer self-knowledge pattern. Landing zone: System Status page (Phase 9). **Now unblocked** — System Status page complete with KL3 placeholder panel (Session 28).

Source: `gsl-plan-coffeeshop-demonstrator-integration-2026-03-10.md` section 4.

### Second Clinical Pathway

Model a second clinical pathway (ongoing monitoring, shared care transition, or follow-up assessment). Tests whether the architecture generalises and triggers cross-pathway rule sharing. Would also validate the ServiceOffering→ClinicalPathway mapping that is currently string-referenced.

### Pattern Catalogue and Cross-Domain Concept Registry (Phase 10 companion)

The project has reached a scale where the web of relationships between architectural patterns, domain concepts, deferred items, and their cross-domain analogues exceeds working memory. A formal concept registry is needed — primarily in SysML, with Obsidian as the navigation and exploration layer.

**SysML layer (formal):** A `Foundation::PatternCatalogue` package defining abstract architectural patterns as `part def`s. Each pattern carries metadata: maturity level (discussion / designed / implemented / validated), which domains it's been instantiated in, what it relates to. Domain-specific instantiations (CSW's kanban, GSL's clinical pathway dashboard) are usages of or references to these pattern defs. The meta model models its own patterns.

**Obsidian layer (exploratory):** Vault structure with templates and frontmatter for patterns, discussion papers, deferred decisions. Linked to model elements by naming convention. MCP bridge (obsidian-mcp-tools plugin) to allow Claude to read vault contents during sessions.

**Multi-service motivation:** The architecture must accommodate multiple service offerings (gender-affirming care, addictions/drug and alcohol, others) without duplicating the meta model. Patterns are domain-agnostic; instantiations are domain-specific. The pattern catalogue makes this explicit and navigable.

**Scope:** 2 sessions. Deliverables: PatternCatalogue SysML package, Obsidian vault structure, MCP bridge setup, design rationale discussion paper. Positioned as a Phase 10 companion workstream.

Source: Session 26 discussion.

### Model Consolidation Review

Step back and review the complete model across all packages for naming consistency, doc block gaps, structural simplification opportunities, and package hierarchy clarity. The model has grown substantially through 27 sessions.

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

### Composite orders (multi-item baskets)

Currently one order = one workflow = one item. The `POST /api/orders` takes a single item, starts a single `fulfilDrink` workflow, and the XState machine tracks that single item through its lifecycle. A customer ordering multiple items places multiple independent orders.

A composite order model would introduce an `Order` containing multiple `OrderLineItem`s, each spawning its own fulfilment workflow but grouped under a shared order reference. This requires:

- **CSW domain model:** `Order` part def containing `OrderLineItem [1..*]`, with a shared `orderRef` linking the group
- **Workflow orchestration:** A parent workflow or saga that spawns child fulfilment workflows per item and tracks group completion
- **UI:** Basket/cart pattern on the Counter page; grouped display on the Order Board

**Clinical analogue:** A clinical plan (e.g. hormone therapy initiation) that triggers multiple concurrent workflows — blood test request, prescription, monitoring schedule — linked by the concept that they are part of the same plan. The plan is the composite; the individual workflows are the line items. This is architecturally important for GSL: a single clinical decision can kickstart several linked pathways or sub-workflows that need to be tracked both individually and as a group.

Not blocking for the current demonstrator exercise (independent orders are realistic for a coffee shop), but important for the clinical platform architecture. Candidate for the Phase 10 meta model update or a post-CSW-Extension workstream.

### Food item workflow limitation

The `FulfilDrink` workflow is drink-specific. Food items (Ginger Biscuit, Oat Bar) can be ordered via the catalogue-validated `POST /api/orders`, and their inventory is correctly decremented, but the Temporal workflow will fail during drink-specific activities. A separate `FulfilFoodOrder` workflow or a generic `FulfilOrder` with item-type-aware routing is a future concern. Not blocking for the current exercise — the catalogue validation and inventory mechanics are the demonstration targets.

---

## 9. Frontend — Notes from Phases 4–8 (Sessions 23–27)

### Flowbite Svelte component compatibility

- `flowbite-svelte@1.31.0` works well with Svelte `5.53.7` and Tailwind `4.2.1`
- `DarkMode` component works without the `invalid_default_snippet` warnings documented in sv10
- `Sidebar` component's responsive behaviour is unreliable — hand-rolled CSS sidebar using standard Flowbite admin patterns is more predictable
- `Card`, `Table`, `Badge`, `Button`, `Alert`, `Select`, `Input`, `Label`, `Spinner` all work correctly
- `$app/stores` used for `$page` (not yet migrated to `$app/state` — Flowbite Svelte still uses stores internally)

### Hand-crafted SVG pathway (Session 28)

The Process Model page uses a hand-crafted SVG pathway rather than the Mermaid-generated SVG. The Mermaid SVG has hardcoded colours, opaque internal node IDs, and no click handlers. A hand-crafted SVG themed to the coffee shop palette with `onclick` handlers per node gives full control over interactivity and dark mode. The pathway is stable (8 nodes, 9 edges from the SysML `FulfilDrink` action def) so this is a one-time effort. Node positions are declared as a `Record<string, NodePosition>` and edge paths are computed as cubic Bézier curves.

### Direct module imports for new API routes (Session 28)

The health check API route imports `WORKFLOW_NAME` from `@coffeeshop/shared/dist/workflow-constants.js` (direct path) rather than the barrel export, continuing the pattern established in Sessions 24 and 26 to avoid the transitive `pg` dependency issue.

### Svelte 5 `{@const}` placement constraint (Session 27)

`{@const}` must be the immediate child of `{#if}`, `{#each}`, `{:else}`, `{:then}`, `{:catch}`, `<svelte:fragment>` or `<Component>`. Cannot be placed at the top level of a template block outside these control flow structures. Workaround: use `$derived` reactive declarations in the script block instead. This was encountered when placing `{@const}` for compliance rate calculations directly inside the summary cards grid on the Audit Dashboard page.

### Temporal sandbox sensitivity to barrel export (Session 24)

Adding the PostgreSQL client to `@coffeeshop/shared` caused Temporal's V8 sandbox to reject workflow imports via the barrel export (transitive Node.js module pull-in from `pg`). Fixed by changing `fulfil-drink.ts` to import `orderLifecycleMachine` directly from `@coffeeshop/shared/dist/generated/order-lifecycle-machine.js`. Future mitigation options: package splitting (`shared-types` vs `shared-clients`) or the two-phase generation pipeline's manifest-driven selective imports.

### Barrel export SSR failure (Session 26)

Importing `anonymiseCaseRef` from the `@coffeeshop/shared` barrel export on page components causes a 500 during SSR — the transitive `pg` import fails in the server-side render context (same root cause as the Temporal sandbox issue from Session 24, different manifestation). Fix: import directly from `@coffeeshop/shared/dist/workflow-constants.js`. This reinforces the case for the two-phase generation pipeline's package splitting approach.

### Dark mode palette (Session 24)

The default secondary palette (charcoal/stone) was too dark at the 800/900 end for dark mode. Shifted to warmer, lighter tones: `secondary-800` from `#292524` to `#3d3835`, `secondary-900` from `#1c1917` to `#342f2c`. CSS overrides with `!important` needed for Flowbite Input/Select components that apply their own dark classes internally.

### Flowbite Modal footer slot (Session 25)

The `<svelte:fragment slot="footer">` pattern for Flowbite Modal does not render in the current setup (flowbite-svelte 1.31.0, Svelte 5.53.7). The footer content is silently swallowed. Workaround: place the action buttons inside the modal body with a `border-t` separator div, rather than using the named `footer` slot. This applies to any Flowbite component that uses named slots — test each one before relying on it.

### Layout max-width (Session 25)

Increased the main content area `max-w` from `6xl` (1152px) to `7xl` (1280px) in `+layout.svelte`. The split-view pages (Counter, Manager) with table + side panel need the extra 128px to avoid column clipping. All pages benefit without being overly wide.

### CDR "None" milk choice display (Session 27)

The CDR stores the milk choice as a coded term, including "None" as a valid value for orders placed without a milk preference. This renders as "Large · None" in the entity view. Fix: a `displayMilk()` helper filters out "None" values before display. The underlying data is correct — this is a display-layer concern.

### Upgrade path to flowbite-svelte 2.0

When `flowbite-svelte@2.0.0` ships as stable (currently at `next.9`), upgrade should be straightforward:
- Peer deps: `svelte ^5.40.0` + `tailwindcss ^4.1.4` — both satisfied by current workspace
- Component API is expected to be stable (same props/slots)
- May support `$app/state` natively, allowing migration from `$app/stores`

---

## 10. Syntax Reference — Unverified Patterns

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

## 11. Major Completed Workstreams (Reference)

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
| CSW Extension Phase 4 (frontend foundation) | 23 | Complete |
| CSW Extension Phase 5 (Counter page) | 24 | Complete |
| CSW Extension Phase 6 (Manager GUI) | 25 | Complete |
| CSW Extension Phase 7 (Order Board & Timeline) | 26 | Complete |
| CSW Extension Phase 8 (Data & Insights pages) | 27 | Complete |
| CSW Extension Phase 9 (System pages) | 28 | Complete |

---

## 12. Two-Phase Generation Pipeline (Session 24)

Discussion paper produced: `gsl-discussion-two-phase-generation-pipeline-2026-03-13.md` (in `documentation/architecture/`). Captures architectural thinking about separating generation into domain generators (model-aware, framework-agnostic) and integration generators (framework-aware, model-agnostic) with a manifest contract between them. Positioned as a workstream after CSW Extension Phase 10, before clinical pathway work begins. Not yet a committed workstream.

---

*Updated 14 March 2026 (Session 28). CSW Extension workstream active — Phase 9 complete, Phase 10 next.*
