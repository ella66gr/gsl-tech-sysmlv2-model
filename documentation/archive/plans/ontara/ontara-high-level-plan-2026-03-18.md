# Ontara — High-Level Development Plan

**Date:** 18 March 2026 (Session 37)
**Prepared by:** Claude, in discussion with Ella Green
**Status:** Working document — for review, discussion and refinement
**Builds on:** [[ontara-discussion-vision-concepts-principles-2026-03-17|Ontara Vision]], [[ontara-discussion-component-catalogue-model-assembly-2026-03-18|Component Catalogue discussion]], [[ontara-master-register-design-concepts-2026-03-17|Master Concept Register]], [[gsl-work-analysis-and-priorities-2026-03-14|Work Analysis and Priorities]], [[session-36-preparation-note|Session 36 Preparation Note]]

---

## 1. Purpose and Scope

This plan sets out the high-level structure for the next phase of Ontara development. It addresses the three questions framed in the Session 36 preparation note — console tooling, cross-domain validation (Suds/Paws), and meta model infrastructure — as a single interleaved programme of work.

The co-evolution principle (J2) requires that model development and tooling advance together. This plan therefore organises work into three parallel tracks that advance in lockstep, rather than sequential workstreams.

---

## 2. Three Parallel Tracks

### Track 1 — Ontara Console

**Purpose:** Build the architect's development environment — a web-based tool for navigating, visualising, and working with the layered Ontara architecture (I2, I5, I6, I12).

**Technology decisions (proposed):**

- **Framework:** SvelteKit. Consistent with CSW demonstrator, Svelte 5 reactivity suits filtered views and interactive canvases, Flowbite Svelte provides component library, Tailwind CSS v4 for styling. Ella has working familiarity from CSW Extension Phases 3–9.
- **Data pipeline:** Python generators producing static JSON projections from the SysML model. Consistent with the existing generation pipeline (E1–E8, D9). The console consumes generated JSON, not raw `.sysml` files. New generators are added alongside existing ones in `scripts/`.
- **Repo structure:** Top-level `console/` directory in the existing repo (peer of `model/`, `scripts/`, `exercises/`). Own `package.json`, own SvelteKit app. This reflects the console's status as a first-class platform development tool (I5), not a demonstrator — it sits alongside the model and generators as a peer concern, not nested under `exercises/`. Co-located in the same repo for single `git log`, generator access, and zero cross-repo coordination.
- **Graphical interaction:** Canvas-style drag-and-drop for the assembly workspace (I9) using **Svelvet** or **Svelte Flow** — node-graph/diagram-editor libraries that support draggable nodes, zoom/pan, custom Svelte components as nodes, and edge connections. List-style drag-and-drop (catalogue browsing, filtering) using **svelte-dnd-action**. Library selection to be confirmed when the assembly workspace is built (Stage 3); the Stage 1 coverage matrix and package navigator do not require canvas DnD.

**What the console is NOT:** It is not a generated domain application. It is a platform development tool — model-aware, architect/developer-facing (I5). The CSW frontend is generated *from* the model; the console shows *the model itself*.

**Tooling philosophy:** The console should be lightweight and sufficient — good enough to help get the job done, iterable, informed by experience. We do not over-invest in tooling sophistication ahead of need, but we stay ready to produce new tooling or refine existing tooling any time it would make a useful difference. This operationalises J10 (retrospective bootstrapping): every development step is an opportunity to ask whether better tooling would have made it easier, and to act on the answer.

### Track 2 — Suds Domain Modelling

**Purpose:** First cross-domain validation exercise (J1). Populate a second domain column in the coverage matrix. Classify meta model components as General or Tailored (B11). Surface meta model gaps. Prove the meta model generalises beyond CSW.

**Why Suds first:** Structurally closer to CSW (item-based, process-oriented). Validates pricing model flexibility (weight/type-dependent vs per-item fixed), batch processing patterns (hours vs minutes), and multi-item order topology (bag → items → batch grouping → return) without introducing appointment scheduling or persistent entity identity — those come with Paws.

**Where it lives:**
- SysML model: `exercises/suds-demonstrator/model/` (following CSW pattern)
- Obsidian notes: `02 ARCHITECTURE & MODELLING/Demonstrators/Suds (Laundry)/`

**What we're modelling (business model first):** ServiceOffering, CustomerSegment, Channel, ActivityTypes, PricingModel, ResourceTypes, CostDrivers, UnitEconomics. Target: comparable BMM coverage to CSW's business model instantiation. Governance requirement included from the start (J8) — Textile Services Association code of practice or COSHH as the structurally realistic example.

### Track 3 — Model Infrastructure

**Purpose:** Build the SysML-level mechanisms that support the Component Catalogue (I7), tagging system (I10), and General/Tailored classification (B11). This is the bridge between the SysML model and the console — without it, the console has nothing to display beyond raw introspection data.

**What this involves:**
- Metadata annotations in SysML for tagging (`@ComponentTag` or similar in Foundation::MetadataLibrary)
- General/Tailored classification metadata on existing CSW `part def`s and new Suds `part def`s
- A new generator (`gen_component_catalogue.py`) that reads the model, extracts tagged components, and produces the JSON the console consumes
- Extension of the existing `gen_model_introspection.py` (from Session 35, pending Ella's review) to produce coverage matrix data in a console-consumable format

---

## 3. Staged Development

Work is organised into three stages. Each stage advances all three tracks in parallel, with clear deliverables per track.

### Stage 1 — Skeleton and First Content

**Objective:** Establish the console application, produce the first working view, and begin Suds modelling.

**Track 1 deliverables:**
- Console application skeleton: SvelteKit app with sidebar navigation, dark mode, Tailwind v4, Flowbite Svelte
- Coverage Matrix view as the first feature — a table showing meta model `part def`s (rows) against domains (columns), with instantiation status per cell. This provides immediate navigational value and directly addresses the architect's legibility problem (§2.1 of the vision document)
- Package Tree Navigator — a collapsible tree showing the SysML package hierarchy (73 packages), clickable to filter the coverage matrix

**Track 2 deliverables:**
- Suds business model: initial SysML file with ServiceOffering, 3–4 ActivityTypes, PricingModel (weight/type-dependent), 2–3 ResourceTypes
- Enough content to populate a meaningful second column in the coverage matrix (target: 10–15 instantiated BMM concepts)

**Track 3 deliverables:**
- General/Tailored classification metadata added to existing CSW BMM `part def`s (annotation pass)
- Extended `gen_model_introspection.py` producing JSON suitable for the coverage matrix view
- Initial `gen_component_catalogue.py` producing a component list with classification metadata

**Co-evolution check:** The coverage matrix view (Track 1) needs model data (Track 3) and a second domain column (Track 2). Building them together satisfies J2.

### Stage 2 — Catalogue and Classification

**Objective:** Build the Component Catalogue view, expand Suds to full BMM coverage, and establish the tagging system.

**Track 1 deliverables:**
- Component Catalogue view: browsable list of meta model components, filterable by tag dimensions (Regulation, Sector, Delivery Mode, General/Tailored, BMM/BSMM)
- Catalogue detail view: selecting a component shows its definition, instantiations across domains, related patterns, and dependencies
- Coverage matrix enhanced: cells distinguish "not yet modelled" from "not applicable" (connects to B9, the template/profiling question)

**Track 2 deliverables:**
- Suds business model expanded to full BMM coverage (target: comparable to CSW's 24 instantiated BMM concepts)
- At least one governance requirement modelled with the satisfy traceability chain (J8)
- Domain-specific concepts identified and classified as Tailored (e.g. batch processing, textile care categories)
- Cross-domain comparison: which CSW concepts transferred directly (General) and which needed adaptation

**Track 3 deliverables:**
- Tagging metadata annotations modelled in SysML (`@CatalogueTag` or similar)
- Tag dimensions and values defined (initially: Regulation, Sector, Delivery Mode — illustrative, not exhaustive)
- `gen_component_catalogue.py` extended to include tags and cross-domain instantiation data
- Component dependency relationships expressed in SysML (which components require which others — informs structural completeness validation, I11)

**Co-evolution check:** The catalogue view (Track 1) exercises the tagging system (Track 3) and is populated by the classification work (Track 2). Each track's deliverables feed the others.

### Stage 3 — Assembly, Traceability and Paws

**Objective:** Prototype the assembly workspace, add horizontal mapping views, introduce the third validation domain.

**Track 1 deliverables:**
- Dual-canvas prototype (I2): business canvas showing BMM components, system canvas showing BSMM components, with horizontal mapping indicators (B12)
- Pattern Graph view: visual representation of the PatternCatalogue's 43 semantic relationships, filterable by relationship type and domain
- Progressive validation indicators on assembled models (I11): Incomplete → Complete → Validated → Runnable
- Model Catalogue view: browsable list of pre-validated model configurations (I8) — initially populated with the CSW and Suds configurations as reference entries

**Track 2 deliverables:**
- Paws business model: ServiceOffering, appointment-based ActivityTypes, per-appointment PricingModel with add-ons, entity-with-persistent-identity (dog across visits — new pattern)
- Paws governance requirement (Animal Welfare Act or similar)
- Three-domain comparison across CSW, Suds, Paws — the full cross-domain validation picture
- Meta model gaps formally identified and logged (Level 3 completeness tracking, I4)

**Track 3 deliverables:**
- Horizontal mapping mechanism in SysML (how BMM components relate to BSMM components at the meta model level)
- Model Catalogue entries represented in SysML (the mechanism for I8 — open design question O18 to be resolved by this point)
- `gen_component_catalogue.py` extended with dependency graph and mapping data
- Assessment of the composite order / multi-workflow orchestration gap (D22) — Suds's multi-item orders will have surfaced this

**Co-evolution check:** The dual canvas (Track 1) needs horizontal mappings (Track 3) and content from multiple domains (Track 2). The pattern graph needs the existing PatternCatalogue plus new domain instantiations. Assembly validation needs the dependency and mapping data.

---

## 4. Relationship to Existing Work Analysis

The [[gsl-work-analysis-and-priorities-2026-03-14|Work Analysis and Priorities]] document identified 9 workstreams and a phased sequencing (Phases A, B, C). This plan does not invalidate that analysis — it reinterprets and incorporates it in the light of the Ontara vision, the console, and the cross-domain validation direction.

### Items absorbed into the three tracks

| Work Analysis Item | Absorbed Into | Notes |
|---|---|---|
| 8.1–8.3 (CatalogueEntry, InventoryRecord, PersistencePolicy in SysML) | Track 3, Stage 1 | These meta model concepts are exercised directly through the Suds domain modelling and the component catalogue infrastructure |
| 1.4 (Domain-agnostic naming) | Track 2 | Cross-domain work inherently tests domain-agnosticism — every concept that transfers from CSW to Suds validates the naming |
| 6.1–6.3 (Naming review, doc block audit, package hierarchy review) | Track 3, ongoing | The coverage matrix and component catalogue surface naming and documentation gaps naturally — consolidation becomes a continuous concern rather than a separate workstream |
| 4.6 (TypeScript type generator update) | Track 3, as needed | Updated as the Suds domain model is created, if generation is relevant |

### Items that shift in priority

| Work Analysis Item | Shift | Rationale |
|---|---|---|
| 3.1 (Second clinical pathway) | Deferred, not cancelled | Remains important for GSL specifically, but the cross-domain validation (Suds/Paws) is a richer test of meta model generalisation. The second pathway is best addressed after the console provides the tooling to visualise it |
| 4.5 (Knowledge Layer Increments 1–4) | Deferred to post-Stage 2 | The KL increments depend on CSW landing zones (built in CSW Extension). They remain high-value but are downstream of the console and cross-domain work — the console will make KL work more visible and navigable |
| 2.1–2.4 (SysML language depth) | Pull in as needed | Port definitions, use case elaboration, and advanced metadata patterns will be explored when the model infrastructure work (Track 3) encounters them naturally |
| 9.1–9.2 (AgencyClassification metadata) | Pull into Track 3, Stage 1 or 2 | Natural companion to the tagging metadata work — all are Foundation::MetadataLibrary additions |

### Items that remain independent

| Work Analysis Item | Status | Notes |
|---|---|---|
| 1.1 (ServiceOffering → ClinicalPathways ref formalisation) | Unchanged | Still needed, but GSL-specific. Not part of the cross-domain tracks |
| 5.1–5.3 (Business model / projection refinement) | Unchanged | Ella-dependent, clinical content. Independent of console work |
| 7.1–7.4 (Runtime / CDR / Prolog / external knowledge) | Correctly deferred | As per original analysis |
| 9.3–9.6 (NotificationTrigger, OptionEvaluator, CoPHR, data release) | Timing unchanged | Tied to clinical pathway work and patient-facing features — downstream of the current plan |

### The overall resequencing

The original Phase A (Structural Deepening) → Phase B (Runtime Validation) → Phase C (Architecture Generalisation) sequence assumed that the next work would be SysML model refinement followed by Knowledge Layer implementation followed by a second clinical pathway. The Ontara vision has shifted the priority: the console and cross-domain validation now come first because they address the architect's legibility problem and prove meta model generalisation simultaneously. The original phases become resources to draw from as items become relevant, rather than a fixed schedule.

---

## 5. Decision Points

At the boundary of each stage, we should pause and assess:

1. **Does the coverage matrix tell us something we didn't know?** If it reveals significant meta model gaps (Level 3, I4), those may need addressing before proceeding.
2. **Is the co-evolution working?** Are model and tooling advancing together, or has one outrun the other?
3. **Are the technology choices holding up?** If SvelteKit, the JSON pipeline, or the repo structure are causing friction, address early.
4. **Which items from the work analysis should be pulled in next?** The decision is made at each stage boundary based on what the current work has surfaced, not predetermined.

---

## 6. What This Plan Does Not Cover

- **Detailed implementation plans** for each stage. Per the workflow guide (§4.2), these are produced before each stage begins, not in advance of the whole programme.
- **Session-level scheduling.** Each stage may take 3–6 sessions depending on scope and what emerges. The plan sets direction and deliverables, not a calendar.
- **The Business System Meta Model extraction** (O2). This is important and will become urgent as the console needs to present both meta models. It should be considered for inclusion in Stage 2 or 3, but the scope is not yet determined.
- **The GSL business model.** GSL remains the production target but is downstream of the cross-domain validation work. Concepts validated in CSW/Suds/Paws will be applied to GSL when the meta model is proven.

---

## 7. Relevant Master Register Concepts

The following register entries are directly exercised by this plan:

**Foundational:** A1 (separation of representation/execution), A3 (model generates everything), A4 (two meta model distinction), A5 (validate in toy domains first), A9 (discipline as load-bearing structure)

**Structural:** B1 (six-layer architecture), B2 (vertical mappings), B11 (General/Tailored decomposition), B12 (horizontal mappings)

**Platform/Console:** I2 (dual canvas), I4 (three levels of completeness), I5 (console vs generated apps), I6 (filtered views), I7 (Component Catalogue), I8 (Model Catalogue), I9 (assembly workspace), I10 (tagging system), I11 (progressive validation), I12 (console as architect's own tool)

**Methodology:** J1 (cross-domain validation), J2 (co-evolution), J3 (non-constraining), J4 (model earns its keep), J10 (retrospective bootstrapping), J11 (bottom-up meets top-down)

**Patterns:** D1 (four-layer item model), D4 (persistence policy), D5 (SysML as source of truth), D9 (metadata-driven generation)

---

## 8. Immediate Next Steps

1. **Ella reviews this plan.** Discussion and refinement before proceeding.
2. **Technology decisions confirmed.** SvelteKit, JSON pipeline, repo structure at `exercises/ontara-console/`.
3. **Ella reviews `gen_model_introspection.py`** from Session 35. This is the foundation for Track 3's coverage matrix data.
4. **Detailed implementation plan for Stage 1.** Produced as a separate document before implementation begins.

---

*High-level plan prepared 18 March 2026 (Session 37). For review and refinement by Ella Green.*
