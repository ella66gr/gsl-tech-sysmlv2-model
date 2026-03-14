# GenderSense SysML Model — Strategic Snapshot

**Date:** 13 March 2026 (Session 24)
**Prepared by:** Claude (from direct review of the complete codebase and session 24 execution)
**Scope:** The `gsl-sysml-model` project in its entirety — model, generators, demonstrator, documentation, development practice
**Changes from previous version:** CSW Extension Phase 5 complete — Counter page with catalogue-driven item tiles, per-item size selection, active orders dashboard with inline workflow control. Temporal sandbox fix for shared package barrel export. Dark mode palette refined. Two-phase generation pipeline discussion paper produced.

---

## 1. What This Project Is

GenderSense Limited is building a model-driven clinical service management platform for gender-affirming healthcare. The `gsl-sysml-model` project is the representation layer: a SysML v2 model that serves as the single source of truth for what the business is, how its clinical services work, what rules govern them, and how the technology platform supports them.

The architectural thesis — validated through a running coffee shop demonstrator application and now extended across the full business system — is that the model generates the execution layer rather than merely documenting it. Process knowledge lives in the model. Clinical data structure lives in openEHR archetypes. Decision rules live in constraints. Business data lives in a relational database. When anything changes, the change happens in the representation layer and propagates to execution via generation or configuration.

This is not a paper exercise. The model produces running code.

---

## 2. Scale and Maturity

### The model

| Metric | Value |
|---|---|
| Top-level packages | 10 (Enterprise, Foundation, Knowledge, ServiceDelivery, Platform, Operations, BusinessModel, BusinessScenarios, BusinessStrategy, GenderSense root) |
| Total packages | 72 |
| Model files | 10 `.sysml` files, 364 KB total |
| Largest file | `knowledge.sysml` — 114 KB |
| Use case definitions | 100+ |
| Constraint definitions | 8 (evaluable, with formal satisfy traceability to requirements) |
| Decision tables | 2 (17 rows total, clinical vocabulary) |
| Entity lifecycle state machines | 4 (Episode, Prescription, LabResult, Referral) |
| Requirement definitions | 8 (regulatory, with satisfy chain to constraints) |
| Outcome definitions | 10 |
| Metadata definitions | 13 (9 Foundation + 4 Temporal) |
| Enum definitions | 25+ in CommonTypes, 9 clinical vocabulary, business model enums |

### The generation pipeline

| Generator | Input | Output | Status |
|---|---|---|---|
| Package hierarchy | All `.sysml` files | Terminal view, Markdown, OPML, HTML mindmap, OmniOutliner | Production — `gsl` CLI |
| Constraint evaluator | Constraint defs + evaluation specs | 3 TypeScript files: types, evaluators, spec registry | Production — 8 constraints |
| Decision table evaluator | Decision table defs + rows | TypeScript lookup + evaluate functions | Production — 2 tables, 17 rows |
| System manifest | All `.sysml` files | JSON structural manifest (8 inventory sections) | Production |
| Projection engine | Scenario parameters | 24-month financial projections, sensitivity, comparison | Production — 2 scenarios |
| Temporal workflow | Orchestration action defs with metadata | Temporal async workflow TypeScript | Demonstrator |
| State machine | State defs | XState v5 machine definitions | Demonstrator |
| TypeScript types | Structural model | TypeScript interfaces + enums | Demonstrator |
| Mermaid pathway | Domain action defs | Mermaid diagrams | Demonstrator |

### The coffee shop demonstrator

A running pnpm monorepo application: SvelteKit web frontend (Tailwind v4 + Flowbite Svelte), Temporal workflow engine, XState lifecycle enforcement, EHRbase openEHR CDR, PostgreSQL business database. Six model files in the exercise directory including business model, resource/financial, and scenario extensions that prove every major architectural pattern generalises to a non-clinical domain. Four generators produce executable artefacts from the SysML model.

**Active extension (Sessions 20–24):** The demonstrator has been extended with catalogue management, inventory tracking, a PostgreSQL business database, a frontend rewrite with Tailwind v4 + Flowbite Svelte, and a catalogue-driven dynamic Counter page. Phases 1–5 (SysML domain model, PostgreSQL foundation, API routes, frontend foundation, Counter page) are complete. The Counter page is the first page where the frontend reads from the business database API and presents visual, data-driven UI — catalogue tiles, per-item size toggles, and an active orders dashboard with inline workflow control.

### The three-persistence-layer architecture (operational with full API, GUI, and catalogue-driven ordering — Session 24)

| Layer | Technology | Port | API surface |
|---|---|---|---|
| **Clinical Data Repository** | EHRbase (openEHR on PostgreSQL) | 5433 (DB), 8080 (API) | `/api/entity/*` — AQL-based queries |
| **Business Database** | PostgreSQL 16 | 5434 | `/api/catalogue`, `/api/inventory` — CRUD with validation |
| **Process Engine** | Temporal | 7233 | `/api/orders`, `/api/orders/active` — catalogue-validated workflow start + active order state |

### The frontend (updated — Session 24)

| Technology | Version | Purpose |
|---|---|---|
| Svelte | 5.53.7 | UI framework (Svelte 5 runes) |
| SvelteKit | latest | App framework, routing, universal load functions |
| Tailwind CSS | 4.2.1 | Utility-first CSS (v4 CSS-native config) |
| Flowbite Svelte | 1.31.0 | Component library (Card, Table, Badge, Button, Alert, etc.) |
| Flowbite Svelte Icons | 2.3.0 | SVG icon components |

The Counter page demonstrates the catalogue-as-UI-contract pattern: the catalogue API response directly drives the tile grid, category grouping, size selection options, dietary badges, and pricing display. No hardcoded item data in the frontend. The active orders panel polls `GET /api/orders/active` every 3 seconds, showing running workflows with their XState lifecycle state and inline action buttons.

### Documentation

| Category | Count | Content |
|---|---|---|
| Session reports | 28 | Complete project journal, every decision recorded |
| Plans | 23 | Phase-by-phase implementation plans, all executed or tracked |
| Architecture documents | 10 | Validated patterns, principles, design rationale, meta-modelling, persistence policy, two-phase generation pipeline |
| Guides | 3 | Repo conventions, editing guide, GitHub setup |
| Syntax reference | v3.11 (12 prior versions archived) | Every verified pattern, reserved word trap, Syside behaviour |

### Development cadence

24 working sessions across 9 days (5–13 March 2026). The project re-engaged after a 7-month break during which studio development was the focus.

---

## 3. Architectural Achievements

### The catalogue-as-UI-contract pattern is validated (new — Session 24)

The Counter page proves that reference data (catalogue entries with their properties) can directly drive frontend structure without any hardcoded UI logic. Item tiles are generated from the catalogue API response. Size toggles are generated from each item's `availableSizes` array. Dietary badges derive from `isVegan` and `isGlutenFree` properties. This is the same pattern the clinical system will use: formulary entries drive prescribing form options, investigation catalogues drive ordering forms.

### The split-view operational dashboard pattern works (new — Session 24)

The Counter page combines an order form (left) with an active orders panel (right) — the barista can place orders and advance existing orders without navigating away. The active orders API queries running Temporal workflows for their XState lifecycle state. Inline signal dispatch (Start Prep → Mark Ready → Collect) completes the full order lifecycle from a single page. Clinical analogue: consultation form + patient queue dashboard.

### The three-tier reasoning stack is modelled and partially generated

Tier 1 (deterministic constraints) is fully modelled in SysML and generates TypeScript evaluators. Eight clinical constraints with formal satisfy traceability to regulatory requirements, evaluation specs with input derivations, and a generated spec registry. Tier 2 (DMN-style decision tables) is modelled as a reusable SysML v2 pattern and generates TypeScript lookup/evaluate functions. Tier 3 (ML/LLM advisory) is architecturally specified as interface-only.

### The five-layer self-knowledge architecture exists in the model

Structural self-knowledge (Layer 1) is generated as the system manifest JSON. Goal-state knowledge (Layer 3) is generated as the constraint spec registry. The LogicEngine package contains 21 part defs. Layers 2, 4, and 5 are structurally defined but not yet generated or runtime-exercised.

### Business model instances are quantitative planning instruments

Two fully parameterised business model usages (Lean Clinical, Full Platform) populate the meta model with real values and produce 24-month financial projections.

### Three persistence layers with catalogue-driven ordering (updated — Session 24)

The CDR/database/process engine boundary is running infrastructure with a full API surface and a styled frontend. The Counter page demonstrates all three layers working together: catalogue data from PostgreSQL drives the order form, orders are placed via Temporal workflows, and CDR compositions are committed during workflow execution.

### The two-phase generation pipeline is architecturally specified (new — Session 24)

A discussion paper captures the design for separating generation into Phase 1 (domain generators, model-aware, framework-agnostic) and Phase 2 (integration generators, framework-aware, model-agnostic). The manifest as interface contract, four integration patterns, the generatability spectrum, and a prototyping strategy are documented. This positions the project for sustainable generator scaling before clinical pathway work begins.

---

## 4. What the Project Proves and What It Doesn't

### What the model proves

- That SysML v2 can serve as a single source of truth spanning business strategy, clinical service delivery, technology platform design, and knowledge representation.
- That generation from SysML v2 to executable artefacts works at practical scale.
- That the two-layer action flow pattern produces correct, maintainable generated code.
- That satisfy traceability is structurally sound.
- That the business meta model provides a reusable abstract framework with functioning quantitative instances.
- That the four-layer item/catalogue/inventory model is a generic pattern operationalised with complete CRUD API.
- That three persistence layers can work together with catalogue-validated ordering flowing across all three.
- **That catalogue reference data can directly drive frontend UI structure without hardcoded logic (new — Session 24).**
- **That a split-view operational dashboard with inline workflow control is a viable and effective interaction pattern (new — Session 24).**

### What the model doesn't yet prove

- That the architecture generalises across multiple clinical pathways.
- That the Knowledge layer self-knowledge architecture produces useful runtime output.
- That the generation pipeline can be sustained at scale (two-phase pipeline designed, not yet implemented).
- That the projection engine parameters reflect real clinical economics.

---

## 5. Technical Debt and Known Limitations

### Temporal sandbox sensitivity to shared package barrel export (new — Session 24)

Adding the PostgreSQL client to `@coffeeshop/shared` caused Temporal's V8 sandbox to reject workflow imports via the barrel export (transitive Node.js module pull-in). Fixed with direct imports. Future mitigation: package splitting or the two-phase generation pipeline's manifest-driven selective imports.

### CDR price mismatch (Session 22)

The order composition builder uses hardcoded coded price terms that don't match catalogue prices. Tagged for Phase 10.

### Food item workflow gap (Session 22)

The `FulfilDrink` Temporal workflow is drink-specific. Food items pass catalogue validation but the workflow fails during drink-specific activities.

### String-typed cross-references (technical debt)

Three cross-domain references remain informal. Medium to low priority.

### Generator fragility

All generators use regex text parsing. Syside Automator migration is the intended fix.

### Projection engine parameters

Revenue, cost, and growth parameters are illustrative placeholders.

---

## 6. Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| **Syside Modeler stalls or is abandoned** | Low | High | SysML v2 is an OMG standard; model files are text-based and portable. |
| **Architecture over-investment before clinical validation** | Medium | Medium | Coffee shop demonstrator practice catches abstraction failures early. |
| **Solo developer bottleneck** | High | High | 28 session reports, 10 architecture docs, syntax reference. |
| **Generator maintenance burden at scale** | Medium | Medium | Two-phase pipeline designed; Automator migration planned. |
| **Shared package barrel export grows toxic to sandbox** | Medium | Low | Direct imports for workflow code; package splitting if needed. |

---

## 7. Active Workstreams

| Workstream | Status | Next step |
|---|---|---|
| **CSW Extension** (catalogue, inventory, frontend reboot) | Phase 5 complete. 10 phases planned. | Phase 6: Manager GUI — stock & catalogue |
| **Structural Deepening** (ports, use cases, ref formalisation) | Planned — Work Analysis Phase A | Awaiting session allocation |
| **Runtime Validation** (Knowledge Layer Increments 1–3) | Planned — Work Analysis Phase B. KL Increment 2 unblocked by Phase 5. | After CSW Extension Phase 5 (Counter page) — now eligible |
| **Architecture Generalisation** (second clinical pathway) | Planned — Work Analysis Phase C | After Structural Deepening |
| **Two-Phase Generation Pipeline** | Discussion paper complete. Prototype planned. | After CSW Extension Phase 10 |

---

## 8. Summary Assessment

This is a serious, disciplined piece of model-driven systems engineering applied to healthcare service design. The project has achieved something unusual: a 72-package SysML v2 model that spans from strategic business planning through clinical service delivery to technology platform design, with a working generation pipeline producing executable code, a running demonstrator application validating every major architectural pattern, and a documentation corpus that makes the entire development history traceable.

Session 24 completed the Counter page — the first page where business database reference data directly drives the frontend UI. The catalogue-as-UI-contract pattern is validated: item tiles, size toggles, dietary badges, and pricing all derive from the API response. The split-view dashboard lets the barista place orders and manage active orders from a single page. The end-to-end flow (select tile → place order → advance through lifecycle → order completes) was validated against a clean Temporal instance.

The three areas of highest strategic value remain:

1. **The Knowledge layer** — KL Increment 2 (decision table routing on the Counter page) is now unblocked.

2. **The business model as quantitative planning instrument** — Phase 6 (Manager GUI) will give the manager direct access to catalogue and inventory management.

3. **The generation pipeline** — the two-phase pipeline discussion paper provides the architectural direction for sustainable scaling before clinical pathway work begins.

The most important work ahead is **Phase 6: Manager GUI** — the stock and catalogue management interface that closes the operational loop: the manager can add items, adjust prices, update availability, and manage inventory. This completes the "run a coffee shop from the system" capability.

The project is well-positioned, well-documented, and architecturally sound.

---

*Strategic snapshot updated 13 March 2026 (Session 24). Changes: Phase 5 complete — Counter page with catalogue-driven tiles, active orders dashboard, Temporal sandbox fix, dark mode refinement. Two-phase generation pipeline discussion paper. KL Increment 2 unblocked.*
