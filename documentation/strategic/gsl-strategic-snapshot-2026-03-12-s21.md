# GenderSense SysML Model — Strategic Snapshot

**Date:** 12 March 2026 (updated from earlier 12 March version)
**Prepared by:** Claude (from direct review of the complete codebase and session 21 execution)
**Scope:** The `gsl-sysml-model` project in its entirety — model, generators, demonstrator, documentation, development practice
**Changes from previous version:** CSW Extension Phase 2 complete — three persistence layers now operational. PostgreSQL business database running alongside CDR. Typed database client and SvelteKit integration verified.

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

**Active extension (Sessions 20–21):** The demonstrator is being extended with catalogue management, inventory tracking, a PostgreSQL business database, and a frontend reboot with Tailwind v4 + Flowbite Svelte. Phase 1 (SysML domain model update) and Phase 2 (PostgreSQL foundation) are complete. The three-persistence-layer architecture is now operational.

### The three-persistence-layer architecture (operational — Session 21)

| Layer | Technology | Port | Purpose |
|---|---|---|---|
| **Clinical Data Repository** | EHRbase (openEHR on PostgreSQL) | 5433 (DB), 8080 (API) | Health records: archetype-validated, terminology-bound, versioned |
| **Business Database** | PostgreSQL 16 | 5434 | Business operations: catalogue, inventory, pricing, financial transactions |
| **Process Engine** | Temporal | 7233 | Workflow state: durable execution, signals, activity orchestration |

This architecture was established through the CSW catalogue exercise, which forced the question of where non-clinical business data belongs. The decision is captured as an explicit `PersistencePolicy` pattern in the meta model, with distinguishing `DataCharacteristic` enums that map domain concepts to their natural persistence home.

Each layer has a consistent access pattern: a typed client in `@coffeeshop/shared` (ehrbase-client.ts, postgres-client.ts, @temporalio/client) and a server-side singleton in `$lib/server/` for SvelteKit consumption.

### Documentation

| Category | Count | Content |
|---|---|---|
| Session reports | 25 | Complete project journal, every decision recorded |
| Plans | 20 | Phase-by-phase implementation plans, all executed or tracked |
| Architecture documents | 9 | Validated patterns, principles, design rationale, meta-modelling, persistence policy |
| Guides | 3 | Repo conventions, editing guide, GitHub setup |
| Syntax reference | v3.11 (12 prior versions archived) | Every verified pattern, reserved word trap, Syside behaviour |

### Development cadence

21 working sessions across 8 days (5–12 March 2026). The project re-engaged after a 7-month break during which studio development was the focus. The prior engagement established the coffee shop demonstrator (Phases A–D) and initial SysML v2 fluency.

---

## 3. Architectural Achievements

### The three-tier reasoning stack is modelled and partially generated

Tier 1 (deterministic constraints) is fully modelled in SysML and generates TypeScript evaluators. Eight clinical constraints with formal satisfy traceability to regulatory requirements, evaluation specs with input derivations, and a generated spec registry. Tier 2 (DMN-style decision tables) is modelled as a reusable SysML v2 pattern and generates TypeScript lookup/evaluate functions. Two clinical tables (regimenSelection, stabilityAssessment) with 17 rows and nine clinical vocabulary enums. Tier 3 (ML/LLM advisory) is architecturally specified as interface-only — the correct decision at this stage.

### The five-layer self-knowledge architecture exists in the model

Structural self-knowledge (Layer 1) is generated as the system manifest JSON. Goal-state knowledge (Layer 3) is generated as the constraint spec registry. The LogicEngine package contains 21 part defs including ConstraintEvaluator tiers, OperationalStateAggregator, GapAnalyser, GoalProjector, AssessmentOrchestrator, and supporting types. Layers 2 (operational state), 4 (gap analysis), and 5 (remediation) are structurally defined but not yet generated or runtime-exercised.

### System self-knowledge as an architectural principle

The system carries an explicit, queryable model of its own structure, decisions, and reasoning. This is not documentation that sits alongside the system — it is part of the model that drives the system. The `PersistencePolicy` pattern is the first concrete instance: the model explains where each domain concept is persisted and why, with distinguishing characteristics that support both human and AI-assisted decision-making about system evolution. This principle extends to the five-layer self-knowledge architecture and to the meta model itself.

### The business meta model is a quantitative planning instrument

Not merely a structural description. Two fully parameterised business model variants (Lean Clinical, Full Platform) produce 24-month financial projections with monthly granularity: patient acquisition, clinical and subscription revenue, multi-category costs, margin, cumulative cash flow, clinician utilisation. Sensitivity analysis varies key parameters ±20%. Scenario comparison produces an investment estimate differential (£22K vs £90K capital requirement). The projection engine reads parameters from the SysML model — the model is the source of truth for business planning as well as clinical service design.

### The four-layer item/catalogue/inventory model

A generic pattern for any business that offers things: item definition (what it is) → catalogue entry (how it's offered) → inventory record (what's in stock) → external references (links to external knowledge). This pattern separates intrinsic product properties from business decisions from operational state, and generalises from coffee shop products to clinical formulary items, assessment instruments, and service definitions. The pattern includes the prepared/bought-in/hybrid provision type distinction, which maps to clinical service design (assembled pathways vs licensed tools).

### Three persistence layers operational (new — Session 21)

The CDR/database/process engine boundary is no longer just a design decision — it is running infrastructure. The coffee shop demonstrator has all three layers operational with typed clients, server-side singletons, and API endpoints. The PostgreSQL schema is derived from the SysML domain model; the mapping from model types to database tables is explicit and documented. The SvelteKit application can query both the CDR (via AQL) and the business database (via SQL) from the same request handler, with each layer serving its architectural purpose.

### The two-layer action flow pattern is proven

Domain layer (governance audience, Mermaid diagrams) and orchestration layer (runtime, Temporal workflows) are generated from the same SysML model. Validated in the coffee shop demonstrator with full durable execution including worker crash recovery and XState lifecycle enforcement. The hormone therapy initiation pathway has both layers modelled with metadata annotations marking generation targets.

### The CDR/database boundary is explicitly reasoned

The architectural decision about where data lives (CDR vs relational database vs process engine) is made explicit through the PersistencePolicy pattern. Each domain concept is assessed against DataCharacteristic criteria (clinicalSignificance, terminologyBound, requiresVersioning, highFrequencyUpdate, transactionalIntegrity, etc.) and mapped to a persistence layer. The openEHR archetype designs for catalogue and inventory remain as reference patterns for when the same concepts need clinical-record representation.

### Satisfy traceability works (with discovered boundaries)

The chain from regulatory requirement → constraint → evaluation spec → generated evaluator is structural and machine-navigable. The significant finding in Phase 7 that `satisfy requirement X by partUsage` fails (the `by` target must be a constraint, not a part) is precisely documented, and a clean workaround pattern (ObjectiveCapabilityMapping) maintains equivalent traceability for objective→capability links.

### The coffee shop demonstrator principle is institutionalised

Every new architectural capability (business meta model, knowledge layer, CDR integration, catalogue/inventory management, persistence policy, PostgreSQL business database) is first proven in the coffee shop, then mapped to the clinical domain. The coffee shop carries no clinical cognitive weight, runs on the same infrastructure stack, and exercises the same generation pipeline. It is a standing practice, not a one-off exercise.

---

## 4. What the Project Proves and What It Doesn't

### What the model proves

- That SysML v2 can serve as a single source of truth spanning business strategy, clinical service delivery, technology platform design, and knowledge representation.
- That generation from SysML v2 to executable artefacts (TypeScript, Temporal workflows, XState machines, financial projections) works at practical scale.
- That the two-layer action flow pattern (domain governance + orchestration runtime) produces correct, maintainable generated code.
- That satisfy traceability (requirement → constraint → evaluation → audit) is structurally sound, even within Syside's current limitations.
- That the business meta model can function as both a structural description and a quantitative planning instrument.
- That the coffee shop demonstrator practice is an effective de-risking mechanism for architectural development.
- That the CDR/database boundary can be reasoned about explicitly and the reasoning captured in the model itself.
- That the four-layer item/catalogue/inventory model is a generic pattern applicable across domains.
- That three persistence layers can be operationalised with consistent access patterns (typed client → server singleton → API endpoint) and cleanly separated responsibilities.
- That a SysML domain model can be mapped to PostgreSQL tables with explicit, documented correspondence between model types and database schema.

### What the model doesn't yet prove

- That the architecture generalises across multiple clinical pathways (only one is fully modelled).
- That the Knowledge layer self-knowledge architecture produces useful runtime output (modelled but not executed).
- That SysML v2 port definitions and connections work in Syside for platform interface modelling.
- That the generation pipeline can be sustained at scale (currently regex-based; Syside Automator is the intended replacement).
- That the projection engine parameters reflect real clinical economics (currently illustrative).
- That the PostgreSQL/CDR boundary holds cleanly at GSL scale (coffee shop exercise validates the pattern; clinical complexity may surface edge cases).

---

## 5. Technical Debt and Known Limitations

### Deliberate deferrals (correctly deferred)

- **Prolog/Tier 2 implementation** — Tau Prolog feasibility validated (spike passed 16/16 tests, 2.4ms/query). Implementation waits for compound inference demand from a second pathway.
- **ML/LLM/Tier 3** — Interface-only until data volume and regulatory clarity justify implementation.
- **Clinical archetype design** — CDR integration patterns validated; clinical content depends on pathway breadth.
- **FHIR bridge, SNOMED CT binding** — NHS interoperability concerns that follow clinical data implementation.

### String-typed cross-references (technical debt)

Three cross-domain references remain informal: ServiceOffering→ClinicalPathways, ScenarioComparison→ScenarioDefinition, ResourceConstraint→Regulation requirement defs. Each is a string attribute where a typed `ref` would provide structural traceability. The first is medium priority (becomes relevant with a second pathway); the others are low priority.

### Generator fragility

All generators use regex text parsing. This works because formatting is controlled, but it's inherently brittle. The Syside Automator API (semantic model access) passed all 10 evaluation tests in the Phase 5 spike and is the intended migration path. Automator stability (currently 0.8.5, approaching 1.0) gates the migration.

### SysML v2 constructs not yet exercised

Port definitions and connections (major structural construct for platform interfaces), use case composition (`include`, `extend`, `actor`), metadata def specialisation, and nested `:>>` redefinition are all unverified in Syside. These represent untapped expressive power in the language.

### Projection engine parameters

Revenue, cost, and growth parameters are illustrative placeholders. The engine demonstrates structural capability but does not yet reflect validated clinical pricing. This is an Ella-input dependency, not a technical blocker.

### Generated types need updating

The `MenuItem` TypeScript interface currently includes `price`. The domain model update (removing price to CatalogueEntry) will require regenerating types and updating the order composition builder to read price from the catalogue rather than the item. The Phase 2 PostgreSQL client already uses the correct schema (price on catalogue_entries, not menu_items).

---

## 6. Competitive and Regulatory Positioning

### Self-describing system

The architecture's most distinctive property is that the system can explain itself. Reporting on activity, decision logic, structural semantics, constraints, governance, and entity relationships are first-class capabilities — not afterthoughts layered on after implementation. A clinical governance query ("show me every patient whose monitoring bloods are overdue, why each one is overdue, and what the pathway says should happen next") is a structured evaluation against the same model that generates the running system.

The PersistencePolicy pattern extends this to architectural decisions: the system can explain not just what it does but why its data architecture is structured the way it is.

### CQC and clinical safety

The satisfy traceability chain (regulatory requirement → constraint → evaluation spec → generated evaluator → audit record) provides evidence of compliance as a system capability rather than a manual documentation exercise. DCB0129/DCB0160 clinical risk management is materially strengthened when the SysML model that defines the pathway is the same artefact that generates the running code.

### Indemnity profile

A practice that can demonstrate formally defined clinical processes, system enforcement of those processes, and complete audit trails showing conformance presents a stronger risk profile to indemnifiers than one relying on conventional documentation.

### Business planning

The quantitative business model — with scenario comparison, sensitivity analysis, and the operational steering cycle wired to the Knowledge layer's deficit tracking — means that business planning and system architecture share a common representation. A change to the pricing model, a new service offering, or a capacity constraint is modelled in the same language as the clinical pathways it affects.

---

## 7. Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| **Syside Modeler stalls or is abandoned** | Low | High | SysML v2 is an OMG standard; alternative tooling (Eclipse Papyrus, PlantSysML) exists. Model files are text-based and portable. |
| **Architecture over-investment before clinical validation** | Medium | Medium | Coffee shop demonstrator practice catches abstraction failures early. Second clinical pathway is the key generalisation test. |
| **Solo developer bottleneck** | High | High | The model is thoroughly documented (25 session reports, 9 architecture docs, syntax reference). A competent SysML practitioner could orient within the repo. |
| **Generator maintenance burden at scale** | Medium | Medium | Automator migration replaces fragile regex parsing. Generated files carry source references. |
| **Regulatory landscape change** | Low | Medium | The model separates regulatory requirements from their satisfaction — a new requirement adds a new requirement def and satisfy chain, not a system redesign. |
| **Clinical content complexity exceeds model capacity** | Low | Low | The three-tier reasoning stack and five-layer self-knowledge architecture are designed for complexity growth. Compound deficit reasoning (Prolog) is architecturally reserved. |
| **CDR/database boundary becomes unclear at scale** | Low | Medium | PersistencePolicy pattern makes boundary decisions explicit and auditable. Three-layer architecture now proven operational in demonstrator. |

---

## 8. Active Workstreams

| Workstream | Status | Next step |
|---|---|---|
| **CSW Extension** (catalogue, inventory, frontend reboot) | Phase 2 complete. 10 phases planned. | Phase 3: Catalogue & inventory API routes |
| **Structural Deepening** (ports, use cases, ref formalisation) | Planned — Work Analysis Phase A | Awaiting session allocation |
| **Runtime Validation** (Knowledge Layer Increments 1–3) | Planned — Work Analysis Phase B. Landing zones being created by CSW Extension. | After CSW Extension Phase 5 (Counter page) |
| **Architecture Generalisation** (second clinical pathway) | Planned — Work Analysis Phase C | After Structural Deepening |

---

## 9. Summary Assessment

This is a serious, disciplined piece of model-driven systems engineering applied to healthcare service design. The project has achieved something unusual: a 72-package SysML v2 model that spans from strategic business planning through clinical service delivery to technology platform design, with a working generation pipeline producing executable code, a running demonstrator application validating every major architectural pattern, and a documentation corpus that makes the entire development history traceable.

The architectural thesis — that a single SysML v2 model can serve as the source of truth for a complete business system, generating both runtime execution and governance documentation — is validated. The model is not theoretical; it produces TypeScript evaluators, Temporal workflows, XState state machines, financial projections, and structural manifests.

Session 21 made the three-persistence-layer architecture operational. The coffee shop demonstrator now runs three distinct persistence services (CDR on port 5433, business DB on port 5434, process engine on port 7233), each with a typed TypeScript client, a SvelteKit server singleton, and API endpoints. The PostgreSQL schema is derived from the SysML domain model with explicit, documented correspondence between model types and database tables. The full stack — from Docker container through `pg` Pool to SvelteKit JSON response — is verified and committed.

The three areas of highest strategic value remain:

1. **The Knowledge layer** — the three-tier reasoning stack and five-layer self-knowledge architecture, now extended with the principle that the system carries queryable self-knowledge about its own architectural decisions.

2. **The business meta model as a quantitative planning instrument,** now with explicit catalogue, inventory, and persistence policy patterns that complete the operational picture, and a running PostgreSQL implementation demonstrating the model-to-database derivation.

3. **The generation pipeline as the bridge,** with the CDR/database boundary establishing that different domain concepts generate to different implementation targets — the pipeline is not one-size-fits-all but target-aware.

The most important work ahead is completing the CSW Extension frontend (Phases 3–9 of the workstream), exercising the Knowledge layer at runtime (coffee shop increments, landing in the frontend reboot), modelling a second clinical pathway to prove generalisation, and deepening the use of SysML v2's structural constructs (ports, use case composition, metadata specialisation) to increase the model's formal rigour and generator expressiveness.

The project is well-positioned, well-documented, and architecturally sound.

---

*Strategic snapshot updated 12 March 2026. Changes from previous version: three persistence layers now operational (not just designed), PostgreSQL business database running with typed client and SvelteKit integration, session count updated to 25 reports across 21 sessions, active workstreams updated to reflect Phase 2 completion.*
