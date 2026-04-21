# GenderSense SysML Model — Strategic Snapshot

**Date:** 12 March 2026 (updated from Session 22 version)
**Prepared by:** Claude (from direct review of the complete codebase and session 23 execution)
**Scope:** The `gsl-sysml-model` project in its entirety — model, generators, demonstrator, documentation, development practice
**Changes from previous version:** CSW Extension Phase 4 complete — frontend foundation with Tailwind CSS v4, Flowbite Svelte, sidebar navigation, dark mode, coffee shop visual identity. The demonstrator transitions from an unstyled test harness to a cohesive GUI.

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

**Active extension (Sessions 20–23):** The demonstrator has been extended with catalogue management, inventory tracking, a PostgreSQL business database, and a frontend rewrite with Tailwind v4 + Flowbite Svelte. Phases 1–4 (SysML domain model, PostgreSQL foundation, API routes, frontend foundation) are complete. The three-persistence-layer architecture is operational with a complete CRUD API and a cohesive GUI.

### The three-persistence-layer architecture (operational with full API and GUI — Session 23)

| Layer | Technology | Port | API surface |
|---|---|---|---|
| **Clinical Data Repository** | EHRbase (openEHR on PostgreSQL) | 5433 (DB), 8080 (API) | `/api/entity/*` — AQL-based queries |
| **Business Database** | PostgreSQL 16 | 5434 | `/api/catalogue`, `/api/inventory` — CRUD with validation |
| **Process Engine** | Temporal | 7233 | `/api/orders` — catalogue-validated workflow start |

Each layer has a consistent access pattern: a typed client in `@coffeeshop/shared` (ehrbase-client.ts, postgres-client.ts, @temporalio/client), a server-side singleton in `$lib/server/`, and SvelteKit API routes. The business database now supports both read and write operations with transactional integrity for multi-table mutations.

### The frontend (new — Session 23)

| Technology | Version | Purpose |
|---|---|---|
| Svelte | 5.53.7 | UI framework (Svelte 5 runes) |
| SvelteKit | latest | App framework, routing |
| Tailwind CSS | 4.2.1 | Utility-first CSS (v4 CSS-native config) |
| Flowbite Svelte | 1.31.0 | Component library (Card, Table, Badge, Button, Alert, etc.) |
| Flowbite Svelte Icons | 2.3.0 | SVG icon components |

The frontend uses a sidebar layout with four navigation sections (Operations, Management, Data & Insights, System), dark mode support, connection status indicators, and a warm neutral coffee shop visual identity. All pages are styled with Flowbite components. Placeholder pages for Stock & Catalogue (Phase 6) and System Status (Phase 9) are in place.

### Documentation

| Category | Count | Content |
|---|---|---|
| Session reports | 27 | Complete project journal, every decision recorded |
| Plans | 22 | Phase-by-phase implementation plans, all executed or tracked |
| Architecture documents | 9 | Validated patterns, principles, design rationale, meta-modelling, persistence policy |
| Guides | 3 | Repo conventions, editing guide, GitHub setup |
| Syntax reference | v3.11 (12 prior versions archived) | Every verified pattern, reserved word trap, Syside behaviour |

### Development cadence

23 working sessions across 8 days (5–12 March 2026). The project re-engaged after a 7-month break during which studio development was the focus. The prior engagement established the coffee shop demonstrator (Phases A–D) and initial SysML v2 fluency.

---

## 3. Architectural Achievements

### The three-tier reasoning stack is modelled and partially generated

Tier 1 (deterministic constraints) is fully modelled in SysML and generates TypeScript evaluators. Eight clinical constraints with formal satisfy traceability to regulatory requirements, evaluation specs with input derivations, and a generated spec registry. Tier 2 (DMN-style decision tables) is modelled as a reusable SysML v2 pattern and generates TypeScript lookup/evaluate functions. Two clinical tables (regimenSelection, stabilityAssessment) with 17 rows and nine clinical vocabulary enums. Tier 3 (ML/LLM advisory) is architecturally specified as interface-only — the correct decision at this stage.

### The five-layer self-knowledge architecture exists in the model

Structural self-knowledge (Layer 1) is generated as the system manifest JSON. Goal-state knowledge (Layer 3) is generated as the constraint spec registry. The LogicEngine package contains 21 part defs including ConstraintEvaluator tiers, OperationalStateAggregator, GapAnalyser, GoalProjector, AssessmentOrchestrator, and supporting types. Layers 2 (operational state), 4 (gap analysis), and 5 (remediation) are structurally defined but not yet generated or runtime-exercised.

### The frontend makes the system visible (new — Session 23)

The coffee shop demonstrator now has a cohesive GUI that makes every operational capability accessible through a structured interface. The four-section sidebar (Operations, Management, Data & Insights, System) prefigures the clinician portal structure. Every page uses Flowbite components (Card, Table, Badge, Button, Alert) that map directly to clinical UI patterns (patient cards, record tables, status badges, safety alerts, action buttons). The System section includes placeholder pages that will become landing zones for Knowledge Layer Increments. Dark mode supports accessibility requirements.

### Business model instances are quantitative planning instruments

The business meta model (`BusinessModel` package) is an abstract framework — it defines what a business model consists of: service offerings, activities, resources, financial structures, scenarios, strategies. The concrete instances of that framework are the planning instruments. Two fully parameterised business model usages (Lean Clinical, Full Platform) populate the meta model with real values and produce 24-month financial projections with monthly granularity.

### The four-layer item/catalogue/inventory model — with running API

A generic pattern for any business that offers things: item definition → catalogue entry → inventory record → external references. With Phase 3, this pattern has a complete REST API with transactional mutations, dynamic partial updates, and catalogue-validated ordering.

### Three persistence layers with complete API coverage and GUI (updated — Session 23)

The CDR/database/process engine boundary is running infrastructure with a full API surface and a styled frontend consuming all endpoints. The frontend makes the three-layer architecture visible to users: Records pages query the CDR, the Counter and Stock & Catalogue pages (when built) consume the business database, and the Order Board consumes workflow state from Temporal.

### The two-layer action flow pattern is proven

Domain layer (governance audience, Mermaid diagrams) and orchestration layer (runtime, Temporal workflows) are generated from the same SysML model. Validated in the coffee shop demonstrator with full durable execution including worker crash recovery and XState lifecycle enforcement.

### The coffee shop demonstrator principle is institutionalised

Every new architectural capability is first proven in the coffee shop, then mapped to the clinical domain. The coffee shop carries no clinical cognitive weight, runs on the same infrastructure stack, and exercises the same generation pipeline. It is a standing practice, not a one-off exercise.

---

## 4. What the Project Proves and What It Doesn't

### What the model proves

- That SysML v2 can serve as a single source of truth spanning business strategy, clinical service delivery, technology platform design, and knowledge representation.
- That generation from SysML v2 to executable artefacts (TypeScript, Temporal workflows, XState machines, financial projections) works at practical scale.
- That the two-layer action flow pattern (domain governance + orchestration runtime) produces correct, maintainable generated code.
- That satisfy traceability (requirement → constraint → evaluation → audit) is structurally sound.
- That the business meta model provides a reusable abstract framework, and that its concrete instances function as quantitative planning instruments.
- That the four-layer item/catalogue/inventory model is a generic pattern applicable across domains, and can be operationalised with a complete CRUD API.
- That three persistence layers can be operationalised with consistent access patterns and cleanly separated responsibilities, including transactional mutations and cross-layer validation.
- That a modern frontend stack (Svelte 5, Tailwind v4, Flowbite Svelte) can be integrated into the demonstrator monorepo to make system capabilities visible and navigable.

### What the model doesn't yet prove

- That the architecture generalises across multiple clinical pathways (only one is fully modelled).
- That the Knowledge layer self-knowledge architecture produces useful runtime output (modelled but not executed).
- That the frontend can support dynamic, catalogue-driven interactions (Phase 5 — Counter page with tiles).
- That the generation pipeline can be sustained at scale (currently regex-based; Syside Automator is the intended replacement).
- That the projection engine parameters reflect real clinical economics (currently illustrative).

---

## 5. Technical Debt and Known Limitations

### Deliberate deferrals (correctly deferred)

- **Prolog/Tier 2 implementation** — Tau Prolog feasibility validated. Implementation waits for compound inference demand.
- **ML/LLM/Tier 3** — Interface-only until data volume and regulatory clarity justify implementation.
- **Clinical archetype design** — CDR integration patterns validated; clinical content depends on pathway breadth.

### CDR price mismatch (Session 22)

The order composition builder uses hardcoded coded price terms that don't match catalogue prices. Tagged for Phase 10.

### Food item workflow gap (Session 22)

The `FulfilDrink` Temporal workflow is drink-specific. Food items pass catalogue validation but the workflow fails during drink-specific activities.

### Flowbite Sidebar component (Session 23)

The Flowbite `Sidebar` component's responsive behaviour was unreliable — hand-rolled CSS sidebar using standard Flowbite admin patterns works better. This is a minor note, not technical debt.

### String-typed cross-references (technical debt)

Three cross-domain references remain informal. Medium to low priority.

### Generator fragility

All generators use regex text parsing. Syside Automator migration is the intended fix.

### Projection engine parameters

Revenue, cost, and growth parameters are illustrative placeholders.

---

## 6. Competitive and Regulatory Positioning

### Self-describing system

The architecture's most distinctive property is that the system can explain itself. Reporting on activity, decision logic, structural semantics, constraints, governance, and entity relationships are first-class capabilities.

### CQC and clinical safety

The satisfy traceability chain provides evidence of compliance as a system capability. DCB0129/DCB0160 clinical risk management is materially strengthened when the SysML model that defines the pathway is the same artefact that generates the running code.

### Business planning

The quantitative business model — with scenario comparison, sensitivity analysis, and catalogue/inventory management patterns — means that business planning and system architecture share a common representation.

---

## 7. Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| **Syside Modeler stalls or is abandoned** | Low | High | SysML v2 is an OMG standard; model files are text-based and portable. |
| **Architecture over-investment before clinical validation** | Medium | Medium | Coffee shop demonstrator practice catches abstraction failures early. |
| **Solo developer bottleneck** | High | High | 27 session reports, 9 architecture docs, syntax reference. A competent practitioner could orient. |
| **Generator maintenance burden at scale** | Medium | Medium | Automator migration planned. |
| **CDR/database boundary becomes unclear at scale** | Low | Medium | PersistencePolicy pattern makes boundary decisions explicit. |

---

## 8. Active Workstreams

| Workstream | Status | Next step |
|---|---|---|
| **CSW Extension** (catalogue, inventory, frontend reboot) | Phase 4 complete. 10 phases planned. | Phase 5: Counter page (dynamic catalogue-driven order form) |
| **Structural Deepening** (ports, use cases, ref formalisation) | Planned — Work Analysis Phase A | Awaiting session allocation |
| **Runtime Validation** (Knowledge Layer Increments 1–3) | Planned — Work Analysis Phase B. Landing zones being created by CSW Extension. | After CSW Extension Phase 5 (Counter page) |
| **Architecture Generalisation** (second clinical pathway) | Planned — Work Analysis Phase C | After Structural Deepening |

---

## 9. Summary Assessment

This is a serious, disciplined piece of model-driven systems engineering applied to healthcare service design. The project has achieved something unusual: a 72-package SysML v2 model that spans from strategic business planning through clinical service delivery to technology platform design, with a working generation pipeline producing executable code, a running demonstrator application validating every major architectural pattern, and a documentation corpus that makes the entire development history traceable.

Session 23 completed the frontend foundation. The coffee shop demonstrator now has a cohesive GUI with Tailwind CSS v4, Flowbite Svelte components, a four-section sidebar navigation, dark mode support, and a warm coffee shop visual identity. All 10 pages (8 restyled, 2 placeholder) render within a coherent layout. The app transitions from an unstyled test harness to an interface that can show the system's capabilities to anyone who sits down with it.

The three areas of highest strategic value remain:

1. **The Knowledge layer** — the three-tier reasoning stack and five-layer self-knowledge architecture, with landing zones now visible in the frontend (System Status placeholder, Order Timeline planned).

2. **The business model instances as quantitative planning instruments,** with a running API and now a GUI surface area for the manager to interact with catalogue and inventory (Phase 6).

3. **The generation pipeline as the bridge,** with the CDR/database boundary establishing that different domain concepts generate to different implementation targets — the pipeline is not one-size-fits-all but target-aware.

The most important work ahead is **Phase 5: Counter Page** — the first dynamic, catalogue-driven page where the frontend reads from the business database API and presents visual tiles for ordering. This will prove that the API layer built in Phases 2–3 integrates seamlessly with the frontend foundation built in Phase 4.

The project is well-positioned, well-documented, and architecturally sound.

---

*Strategic snapshot updated 12 March 2026. Changes from previous version: Phase 4 complete — frontend foundation with Tailwind v4 + Flowbite Svelte, sidebar navigation, dark mode, styled pages. Session count updated to 23.*
