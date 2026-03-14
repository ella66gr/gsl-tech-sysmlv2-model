# GenderSense SysML Model — Strategic Snapshot

**Date:** 12 March 2026 (updated from Session 21 version)
**Prepared by:** Claude (from direct review of the complete codebase and session 22 execution)
**Scope:** The `gsl-sysml-model` project in its entirety — model, generators, demonstrator, documentation, development practice
**Changes from previous version:** CSW Extension Phase 3 complete — full CRUD API for catalogue and inventory management. Order submission now validates against the catalogue. Five mutation methods with transaction support. The coffee shop demonstrator has a complete business API layer.

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

A running pnpm monorepo application: SvelteKit web frontend, Temporal workflow engine, XState lifecycle enforcement, EHRbase openEHR CDR, PostgreSQL business database. Six model files in the exercise directory including business model, resource/financial, and scenario extensions that prove every major architectural pattern generalises to a non-clinical domain. Four generators produce executable artefacts from the SysML model.

**Active extension (Sessions 20–22):** The demonstrator is being extended with catalogue management, inventory tracking, a PostgreSQL business database, and a frontend reboot with Tailwind v4 + Flowbite Svelte. Phases 1–3 (SysML domain model, PostgreSQL foundation, API routes) are complete. The three-persistence-layer architecture is operational with a complete CRUD API.

### The three-persistence-layer architecture (operational with full API — Session 22)

| Layer | Technology | Port | API surface |
|---|---|---|---|
| **Clinical Data Repository** | EHRbase (openEHR on PostgreSQL) | 5433 (DB), 8080 (API) | `/api/entity/*` — AQL-based queries |
| **Business Database** | PostgreSQL 16 | 5434 | `/api/catalogue`, `/api/inventory` — CRUD with validation |
| **Process Engine** | Temporal | 7233 | `/api/orders` — catalogue-validated workflow start |

Each layer has a consistent access pattern: a typed client in `@coffeeshop/shared` (ehrbase-client.ts, postgres-client.ts, @temporalio/client), a server-side singleton in `$lib/server/`, and SvelteKit API routes. The business database now supports both read and write operations with transactional integrity for multi-table mutations.

### Documentation

| Category | Count | Content |
|---|---|---|
| Session reports | 26 | Complete project journal, every decision recorded |
| Plans | 21 | Phase-by-phase implementation plans, all executed or tracked |
| Architecture documents | 9 | Validated patterns, principles, design rationale, meta-modelling, persistence policy |
| Guides | 3 | Repo conventions, editing guide, GitHub setup |
| Syntax reference | v3.11 (12 prior versions archived) | Every verified pattern, reserved word trap, Syside behaviour |

### Development cadence

22 working sessions across 8 days (5–12 March 2026). The project re-engaged after a 7-month break during which studio development was the focus. The prior engagement established the coffee shop demonstrator (Phases A–D) and initial SysML v2 fluency.

---

## 3. Architectural Achievements

### The three-tier reasoning stack is modelled and partially generated

Tier 1 (deterministic constraints) is fully modelled in SysML and generates TypeScript evaluators. Eight clinical constraints with formal satisfy traceability to regulatory requirements, evaluation specs with input derivations, and a generated spec registry. Tier 2 (DMN-style decision tables) is modelled as a reusable SysML v2 pattern and generates TypeScript lookup/evaluate functions. Two clinical tables (regimenSelection, stabilityAssessment) with 17 rows and nine clinical vocabulary enums. Tier 3 (ML/LLM advisory) is architecturally specified as interface-only — the correct decision at this stage.

### The five-layer self-knowledge architecture exists in the model

Structural self-knowledge (Layer 1) is generated as the system manifest JSON. Goal-state knowledge (Layer 3) is generated as the constraint spec registry. The LogicEngine package contains 21 part defs including ConstraintEvaluator tiers, OperationalStateAggregator, GapAnalyser, GoalProjector, AssessmentOrchestrator, and supporting types. Layers 2 (operational state), 4 (gap analysis), and 5 (remediation) are structurally defined but not yet generated or runtime-exercised.

### System self-knowledge as an architectural principle

The system carries an explicit, queryable model of its own structure, decisions, and reasoning. This is not documentation that sits alongside the system — it is part of the model that drives the system. The `PersistencePolicy` pattern is the first concrete instance: the model explains where each domain concept is persisted and why, with distinguishing characteristics that support both human and AI-assisted decision-making about system evolution.

### Business model instances are quantitative planning instruments

The business meta model (`BusinessModel` package) is an abstract framework — it defines what a business model consists of: service offerings, activities, resources, financial structures, scenarios, strategies. The concrete instances of that framework are the planning instruments. Two fully parameterised business model usages (Lean Clinical, Full Platform) populate the meta model with real values and produce 24-month financial projections with monthly granularity: patient acquisition, clinical and subscription revenue, multi-category costs, margin, cumulative cash flow, clinician utilisation. Sensitivity analysis varies key parameters ±20%. Scenario comparison produces an investment estimate differential (£22K vs £90K capital requirement). The projection engine reads parameters from the instances, not from the meta model — the distinction between `part def` and `part` applies here as everywhere else in the architecture.

### The four-layer item/catalogue/inventory model — now with a running API

A generic pattern for any business that offers things: item definition (what it is) → catalogue entry (how it's offered) → inventory record (what's in stock) → external references (links to external knowledge). This pattern separates intrinsic product properties from business decisions from operational state, and generalises from coffee shop products to clinical formulary items. With Phase 3, this pattern is no longer just a model — it has a complete REST API with transactional mutations, dynamic partial updates, and catalogue-validated ordering.

### Three persistence layers with complete API coverage (new — Session 22)

The CDR/database/process engine boundary is running infrastructure with a full API surface. The business database layer now supports CRUD operations: create items transactionally (menu item + catalogue entry + optional inventory in a single transaction), update prices and availability, adjust stock levels with auto-calculated status, and look up items for order validation. Order submission validates against the catalogue before starting a workflow, and bought-in items have inventory decremented atomically. The API layer demonstrates the pattern for GSL: formulary validation before prescribing, stock management for pharmacy, and audit-grade transactional integrity.

### The two-layer action flow pattern is proven

Domain layer (governance audience, Mermaid diagrams) and orchestration layer (runtime, Temporal workflows) are generated from the same SysML model. Validated in the coffee shop demonstrator with full durable execution including worker crash recovery and XState lifecycle enforcement.

### The CDR/database boundary is explicitly reasoned

The architectural decision about where data lives (CDR vs relational database vs process engine) is made explicit through the PersistencePolicy pattern. Each domain concept is assessed against DataCharacteristic criteria and mapped to a persistence layer. The openEHR archetype designs for catalogue and inventory remain as reference patterns for when the same concepts need clinical-record representation.

### The coffee shop demonstrator principle is institutionalised

Every new architectural capability is first proven in the coffee shop, then mapped to the clinical domain. The coffee shop carries no clinical cognitive weight, runs on the same infrastructure stack, and exercises the same generation pipeline. It is a standing practice, not a one-off exercise.

---

## 4. What the Project Proves and What It Doesn't

### What the model proves

- That SysML v2 can serve as a single source of truth spanning business strategy, clinical service delivery, technology platform design, and knowledge representation.
- That generation from SysML v2 to executable artefacts (TypeScript, Temporal workflows, XState machines, financial projections) works at practical scale.
- That the two-layer action flow pattern (domain governance + orchestration runtime) produces correct, maintainable generated code.
- That satisfy traceability (requirement → constraint → evaluation → audit) is structurally sound.
- That the business meta model can function as both a structural description and a quantitative planning instrument.
- That the four-layer item/catalogue/inventory model is a generic pattern applicable across domains, and can be operationalised with a complete CRUD API.
- That three persistence layers can be operationalised with consistent access patterns and cleanly separated responsibilities, including transactional mutations and cross-layer validation (catalogue lookup before workflow start).
- That a SysML domain model can be mapped to PostgreSQL tables and API operations with explicit, documented correspondence.

### What the model doesn't yet prove

- That the architecture generalises across multiple clinical pathways (only one is fully modelled).
- That the Knowledge layer self-knowledge architecture produces useful runtime output (modelled but not executed).
- That the frontend can make the system's capabilities visible and usable (Phase 4 is next).
- That the generation pipeline can be sustained at scale (currently regex-based; Syside Automator is the intended replacement).
- That the projection engine parameters reflect real clinical economics (currently illustrative).

---

## 5. Technical Debt and Known Limitations

### Deliberate deferrals (correctly deferred)

- **Prolog/Tier 2 implementation** — Tau Prolog feasibility validated. Implementation waits for compound inference demand.
- **ML/LLM/Tier 3** — Interface-only until data volume and regulatory clarity justify implementation.
- **Clinical archetype design** — CDR integration patterns validated; clinical content depends on pathway breadth.

### CDR price mismatch (new — Session 22)

The order composition builder uses hardcoded coded price terms (£1.25–£2.85 based on size) that don't match catalogue prices (£2.00–£4.20 based on item). The catalogue is now the authoritative price source; the CDR records an approximate price bracket. Tagged for resolution in Phase 10 (archetype update or DV_QUANTITY with currency).

### Food item workflow gap (new — Session 22)

The `FulfilDrink` Temporal workflow is drink-specific. Food items pass catalogue validation and have inventory decremented, but the workflow fails during drink-specific activities. A generic `FulfilOrder` workflow with item-type-aware routing is a future concern.

### String-typed cross-references (technical debt)

Three cross-domain references remain informal. Medium to low priority.

### Generator fragility

All generators use regex text parsing. Syside Automator migration is the intended fix.

### Projection engine parameters

Revenue, cost, and growth parameters are illustrative placeholders.

---

## 6. Competitive and Regulatory Positioning

### Self-describing system

The architecture's most distinctive property is that the system can explain itself. Reporting on activity, decision logic, structural semantics, constraints, governance, and entity relationships are first-class capabilities. The PersistencePolicy pattern extends this to architectural decisions.

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
| **Solo developer bottleneck** | High | High | 26 session reports, 9 architecture docs, syntax reference. A competent practitioner could orient. |
| **Generator maintenance burden at scale** | Medium | Medium | Automator migration planned. |
| **CDR/database boundary becomes unclear at scale** | Low | Medium | PersistencePolicy pattern makes boundary decisions explicit. Three-layer architecture proven operational with full API. |

---

## 8. Active Workstreams

| Workstream | Status | Next step |
|---|---|---|
| **CSW Extension** (catalogue, inventory, frontend reboot) | Phase 3 complete. 10 phases planned. | Phase 4: Frontend foundation (Tailwind v4 + Flowbite) |
| **Structural Deepening** (ports, use cases, ref formalisation) | Planned — Work Analysis Phase A | Awaiting session allocation |
| **Runtime Validation** (Knowledge Layer Increments 1–3) | Planned — Work Analysis Phase B. Landing zones being created by CSW Extension. | After CSW Extension Phase 5 (Counter page) |
| **Architecture Generalisation** (second clinical pathway) | Planned — Work Analysis Phase C | After Structural Deepening |

---

## 9. Summary Assessment

This is a serious, disciplined piece of model-driven systems engineering applied to healthcare service design. The project has achieved something unusual: a 72-package SysML v2 model that spans from strategic business planning through clinical service delivery to technology platform design, with a working generation pipeline producing executable code, a running demonstrator application validating every major architectural pattern, and a documentation corpus that makes the entire development history traceable.

Session 22 completed the business API layer. The coffee shop demonstrator now has full CRUD operations for catalogue and inventory management, transactional multi-table mutations, dynamic partial updates with auto-calculated stock status, and catalogue-validated order submission with inventory decrement. The API surface is complete and ready for the frontend to consume in Phase 4.

The three areas of highest strategic value remain:

1. **The Knowledge layer** — the three-tier reasoning stack and five-layer self-knowledge architecture, with landing zones being created by the frontend reboot.

2. **The business model instances as quantitative planning instruments,** now with a running API that demonstrates how model-derived business operations work in practice. The meta model provides the abstract framework; the parameterised usages are the instruments.

3. **The generation pipeline as the bridge,** with the CDR/database boundary establishing that different domain concepts generate to different implementation targets — the pipeline is not one-size-fits-all but target-aware.

The most important work ahead is the frontend reboot (Phase 4: Tailwind v4 + Flowbite foundation), which will make the system's capabilities visible through a cohesive GUI for the first time. The API layer built in Phases 2–3 provides the complete backend for the counter page, manager GUI, and system status pages.

The project is well-positioned, well-documented, and architecturally sound.

---

*Strategic snapshot updated 12 March 2026. Changes from previous version: Phase 3 complete — full CRUD API for catalogue and inventory, catalogue-validated ordering with inventory decrement, two new deferred items (CDR price mismatch, food item workflow gap), session count updated to 22.*
