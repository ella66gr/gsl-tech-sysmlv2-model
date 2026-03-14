# GenderSense SysML Model — Strategic Snapshot

**Date:** 14 March 2026 (Session 25)
**Prepared by:** Claude (from direct review of the complete codebase and session 25 conversation)
**Scope:** The `gsl-sysml-model` project in its entirety — model, generators, demonstrator, documentation, development practice
**Changes from previous version:** Self-service enabling architecture discussion paper produced — covering informed choice, generational roadmap, clinical authority, harm reduction, CoPHR heritage, and six architecture recommendations for immediate adoption. No code changes in this session.

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
| Architecture documents | 11 | Validated patterns, principles, design rationale, meta-modelling, persistence policy, two-phase generation pipeline, **self-service enabling architecture** |
| Guides | 3 | Repo conventions, editing guide, GitHub setup |
| Syntax reference | v3.11 (12 prior versions archived) | Every verified pattern, reserved word trap, Syside behaviour |

### Development cadence

25 working sessions across 10 days (5–14 March 2026). The project re-engaged after a 7-month break during which studio development was the focus.

---

## 3. Architectural Achievements

### The self-service enabling architecture is specified (new — Session 25)

A comprehensive discussion paper (`gsl-discussion-self-service-enabling-architecture-2026-03-14.md`) captures the architectural thinking for patient self-service. This is not a specification for a self-service system but a description of the **enabling architecture** that the platform needs to support successive generations of patient self-service — from informed transparency through to autonomous navigation with clinical oversight.

Key concepts introduced: the Informed Choice Engine (ICE) as an orchestration pattern combining deterministic clinical reasoning with LLM-assisted adaptive explanation; the OptionEvaluator as a sibling to the ConstraintEvaluator in the self-knowledge architecture; agency classification with authority model versioning on pathway action nodes; notification triggers modelled on state transitions; patient-facing state projections; and the InformedChoiceAttestation governance artefact.

The paper defines a four-generation roadmap (Informed Transparency → Guided Self-Navigation → Informed Choice with Shared Authority → Autonomous Self-Service), with each generation building on the same architecture but configured differently through model-level metadata. The architecture does not change between generations; the configuration changes.

The paper explicitly addresses the clinical authority problem (the practitioner's duty of care is non-negotiable), harm reduction for patients arriving mid-stream from self-medication, and the Apperta CoPHR Blueprint (2018) as foundational prior art for governance principles.

### The catalogue-as-UI-contract pattern is validated (Session 24)

The Counter page proves that reference data (catalogue entries with their properties) can directly drive frontend structure without any hardcoded UI logic. Item tiles are generated from the catalogue API response. Size toggles are generated from each item's `availableSizes` array. Dietary badges derive from `isVegan` and `isGlutenFree` properties. This is the same pattern the clinical system will use: formulary entries drive prescribing form options, investigation catalogues drive ordering forms.

### The split-view operational dashboard pattern works (Session 24)

The Counter page combines an order form (left) with an active orders panel (right) — the barista can place orders and advance existing orders without navigating away. The active orders API queries running Temporal workflows for their XState lifecycle state. Inline signal dispatch (Start Prep → Mark Ready → Collect) completes the full order lifecycle from a single page. Clinical analogue: consultation form + patient queue dashboard.

### The three-tier reasoning stack is modelled and partially generated

Tier 1 (deterministic constraints) is fully modelled in SysML and generates TypeScript evaluators. Eight clinical constraints with formal satisfy traceability to regulatory requirements, evaluation specs with input derivations, and a generated spec registry. Tier 2 (DMN-style decision tables) is modelled as a reusable SysML v2 pattern and generates TypeScript lookup/evaluate functions. Tier 3 (ML/LLM advisory) is architecturally specified as interface-only.

### The five-layer self-knowledge architecture exists in the model

Structural self-knowledge (Layer 1) is generated as the system manifest JSON. Goal-state knowledge (Layer 3) is generated as the constraint spec registry. The LogicEngine package contains 21 part defs. Layers 2, 4, and 5 are structurally defined but not yet generated or runtime-exercised. **The OptionEvaluator is now identified as a natural extension of this architecture (Session 25) and planned as Knowledge Layer Increment 4.**

### Business model instances are quantitative planning instruments

Two fully parameterised business model usages (Lean Clinical, Full Platform) populate the meta model with real values and produce 24-month financial projections.

### Three persistence layers with catalogue-driven ordering (Session 24)

The CDR/database/process engine boundary is running infrastructure with a full API surface and a styled frontend. The Counter page demonstrates all three layers working together: catalogue data from PostgreSQL drives the order form, orders are placed via Temporal workflows, and CDR compositions are committed during workflow execution.

### The two-phase generation pipeline is architecturally specified (Session 24)

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
- That catalogue reference data can directly drive frontend UI structure without hardcoded logic (Session 24).
- That a split-view operational dashboard with inline workflow control is a viable and effective interaction pattern (Session 24).

### What the model doesn't yet prove

- That the architecture generalises across multiple clinical pathways.
- That the Knowledge layer self-knowledge architecture produces useful runtime output.
- That the generation pipeline can be sustained at scale (two-phase pipeline designed, not yet implemented).
- That the projection engine parameters reflect real clinical economics.
- **That the self-service enabling architecture supports patient-facing interactions at each generation (new — Session 25).** The discussion paper specifies the architecture; the coffee shop demonstrator will validate it incrementally.

---

## 5. Technical Debt and Known Limitations

### Temporal sandbox sensitivity to shared package barrel export (Session 24)

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
| **Solo developer bottleneck** | High | High | 28 session reports, 11 architecture docs, syntax reference. |
| **Generator maintenance burden at scale** | Medium | Medium | Two-phase pipeline designed; Automator migration planned. |
| **Shared package barrel export grows toxic to sandbox** | Medium | Low | Direct imports for workflow code; package splitting if needed. |
| **Self-service model adopted without adequate governance** | Low | High | **Generational roadmap with explicit prerequisites per generation. Authority model versioning records governance framework in effect at each decision point. (new — Session 25)** |
| **Clinical liability shift not matched by indemnity framework** | Medium | High | **Generations 3–4 have explicit prerequisites including legal analysis and MDO engagement. Architecture supports all authority models without structural changes. (new — Session 25)** |

---

## 7. Active Workstreams

| Workstream | Status | Next step |
|---|---|---|
| **CSW Extension** (catalogue, inventory, frontend reboot) | Phase 5 complete. 10 phases planned. | Phase 6: Manager GUI — stock & catalogue |
| **Structural Deepening** (ports, use cases, ref formalisation) | Planned — Work Analysis Phase A | Awaiting session allocation |
| **Runtime Validation** (Knowledge Layer Increments 1–3) | Planned — Work Analysis Phase B. KL Increment 2 unblocked by Phase 5. | After CSW Extension Phase 5 (Counter page) — now eligible |
| **Architecture Generalisation** (second clinical pathway) | Planned — Work Analysis Phase C | After Structural Deepening |
| **Two-Phase Generation Pipeline** | Discussion paper complete. Prototype planned. | After CSW Extension Phase 10 |
| **Self-Service Enabling Architecture** | **Discussion paper complete. Six architecture recommendations for near-term adoption. (new — Session 25)** | **Recommendations 1–2 (agency classification, authority model versioning) can be actioned during next model-touching session. Recommendations 3–4 (notification triggers, OptionEvaluator) feed into existing workstream sequencing.** |

---

## 8. Self-Service Architecture Recommendations (new — Session 25)

The self-service enabling architecture discussion paper produced six recommendations for current architecture decisions. These are low-cost investments that establish patterns the platform will need at every generation of self-service, and are harder to retrofit than to build in from the start.

### 8.1 Model Agency Classification Now

Add `AgencyClassification` metadata definition to the Foundation MetadataLibrary. Annotate the existing hormone therapy initiation pathway with agency classifications, even though all nodes are currently clinician-action or system-action. This establishes the pattern before it's needed. **Effort: 1 stage. Can be done on the next model-touching session.**

### 8.2 Model Authority Model Versioning Now

Include an `AuthorityModelVersion` attribute in the agency classification metadata from the outset. Initially a single value ("G1-clinician-authority"). As the service evolves, new versions are added without structural changes. **Effort: included in 8.1.**

### 8.3 Design Notification Triggers on the Next Pathway Modelling Pass

When the second clinical pathway is modelled (Workstream 3, Architecture Generalisation), include `NotificationTrigger` metadata on state transitions as a first-class modelling concern. Notifications are a Generation 1 self-service requirement. **Effort: integrated into Architecture Generalisation workstream.**

### 8.4 Plan the OptionEvaluator as Knowledge Layer Increment 4

Formally add the OptionEvaluator to the Knowledge Layer increment sequence, after KL Increments 1–3. The coffee shop "Help Me Choose" feature is the demonstrator. The OptionEvaluator is the enabling component for Generation 3 (Informed Choice with Shared Authority). **Effort: 2–3 stages. Follows KL Increments 1–3.**

### 8.5 Reference the CoPHR Governance Principles

Document the Apperta CoPHR Blueprint's nine principles as reference requirements in the GSL governance architecture. The principles on provenance, audit, irrevocable access to relied-upon data, and medico-legal validity are directly relevant and should be adopted. **Effort: 1 stage (documentation and model annotation).**

### 8.6 Design Patient-Facing Data Release into the Persistence Architecture

When designing the patient portal data access layer, implement a data release model from the outset: what the patient sees immediately, what the patient sees after clinician review, and what is visible only in consultation. Configuration per data type, not a structural decision. **Effort: integrated into patient portal design work.**

---

## 9. Summary Assessment

This is a serious, disciplined piece of model-driven systems engineering applied to healthcare service design. The project has achieved something unusual: a 72-package SysML v2 model that spans from strategic business planning through clinical service delivery to technology platform design, with a working generation pipeline producing executable code, a running demonstrator application validating every major architectural pattern, and a documentation corpus that makes the entire development history traceable.

Session 25 produced the self-service enabling architecture discussion paper — the most strategically significant document since the project resumed. It establishes that patient self-service is not a feature to be bolted on but a foundational architectural commitment that must be designed for from the start. The generational roadmap provides a structured path from current capability to the aspired-to level of patient empowerment, with explicit governance and regulatory prerequisites at each stage. Six concrete architecture recommendations ensure that the enabling patterns are built in now, at low cost, rather than retrofitted later.

The four areas of highest strategic value are now:

1. **The self-service enabling architecture** — the generational roadmap and its six near-term recommendations provide the strategic direction for the platform's patient-facing capability. Recommendations 8.1–8.2 (agency classification and authority model versioning) should be actioned at the earliest model-touching opportunity.

2. **The Knowledge layer** — KL Increment 2 (decision table routing) is unblocked. The OptionEvaluator is now formally planned as KL Increment 4, connecting the self-knowledge architecture to patient-facing informed choice.

3. **The business model as quantitative planning instrument** — Phase 6 (Manager GUI) closes the operational loop.

4. **The generation pipeline** — the two-phase pipeline discussion paper provides the architectural direction for sustainable scaling.

The most important implementation work ahead remains **Phase 6: Manager GUI** — the stock and catalogue management interface. The most important architectural work ahead is **actioning recommendations 8.1–8.2** to establish agency classification and authority model versioning in the SysML model.

The project is well-positioned, well-documented, and architecturally sound. The self-service enabling architecture paper ensures it is also strategically aligned with its core value proposition: empowering patients within a governed, safe, and transparent clinical framework.

---

*Strategic snapshot updated 14 March 2026 (Session 25). Changes: Self-service enabling architecture discussion paper complete — informed choice engine, generational roadmap, clinical authority, harm reduction, CoPHR heritage. Six architecture recommendations for near-term adoption (§8). Two new risks added (§6). OptionEvaluator planned as KL Increment 4. Documentation count updated.*
