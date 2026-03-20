# Ontara — Strategic Snapshot

**Date:** 20 March 2026 (Session 48)
**Prepared by:** Claude (Opus 4.6), from direct review of the codebase, Obsidian vault, and Sessions 35–47
**Scope:** The Ontara platform in its entirety — model, demonstrators, console, governance, and development state
**Replaces:** `gsl-strategic-snapshot-2026-03-15-s31.md` (Session 31/34)

---

## 1. What Ontara Is

**Ontara** is a service system development and delivery platform, particularly strong in supporting regulated care service delivery. The name evokes ontology and a sense of being and essence, along with a feminine intuition of awareness of self. Ontara encompasses all layers of the system: meta models, business models, system models, the execution platform, the generation pipeline, and the developer/architect tooling (the Ontara Console).

Ontara is not the name of one component. It is the name for the whole.

GenderSense Limited (GSL) — a private gender-affirming healthcare service — is the primary motivating use case and the first production instance of a service business on the platform. Ella Green is the founder of GSL, the sole developer and architect of Ontara, and a GP specialist in transgender health (NHS East of England Gender Service).

The architectural thesis is that a SysML v2 model serves as the single source of truth for what a service business is, how it works, what rules govern it, and how the technology platform supports it. The model generates the execution layer rather than merely documenting it. The model also describes its own architectural patterns, the semantic relationships between them, and — through the comprehension architecture — its own explanations of what it contains and why.

### 1.1 Platform identity

Ontara meets the technical definition of a platform as distinct from a product or framework: modular architecture with standardised interfaces; abstraction and generality through meta models; lifecycle support from design through operation; evolutionary stability through versioning, the non-constraining principle, and the PatternCatalogue; ecosystem enablement through dual-canvas tooling and meta-model-defined palettes; composability, extensibility, and integrated tooling.

The pragmatic test: if Ella stopped building end-user features, would other teams still find Ontara valuable as a base to build their own service businesses?

---

## 2. Scale and Maturity

### 2.1 The SysML model

| Metric | Value |
|---|---|
| Top-level packages | 11 (Enterprise, Foundation, Knowledge, ServiceDelivery, Platform, Operations, BusinessModel, BusinessScenarios, BusinessStrategy, PatternCatalogue, GenderSense root) |
| Total packages | ~73 |
| Core model files | 11 `.sysml` files, 442 KB total |
| Largest file | `knowledge.sysml` — 114 KB |
| PatternCatalogue | 22 patterns, 8 principles, 33 domain instantiations, ~43 typed `ref` relationships |

### 2.2 Demonstrator model files

| Domain | Files | Status |
|---|---|---|
| Cafe (Coffee Shop) | 9 `.sysml` files (4 business model + 5 domain model) | Full demonstrator with running application |
| Suds (Laundry) | 1 `.sysml` file | Business model instance validated |
| Paws (Dog Grooming) | 1 `.sysml` file | Business model instance validated (Stage 3, Phase 1) |

### 2.3 The Ontara Console

| Metric | Value |
|---|---|
| Stack | SvelteKit + Tailwind v4 |
| Console pages | 10 (Home, Coverage Matrix, Package Navigator, Component Catalogue, Glossary, Governance, Meta-Model, Patterns, plus 3 domain views: Cafe, Suds, Paws) |
| Data source | `model-introspection.json` generated from SysML via `gen_model_introspection.py` |

### 2.4 The Coffee Shop demonstrator application

| Metric | Value |
|---|---|
| Frontend pages | 9 (Counter, Order Board, Management/Catalogue, Records, Audit Dashboard, Customer Voice, Pathway, System Status, Order Detail + Audit sub-pages) |
| API routes | 19 |
| Temporal workflows | 1 (FulfilDrink with XState lifecycle) |
| CDR integration | 3 archetypes, AQL queries, governance audit |
| PostgreSQL tables | 4 |
| Stack | SvelteKit + Tailwind v4 + Flowbite Svelte, Temporal, EHRbase, PostgreSQL |

### 2.5 Generation pipeline

| Generator | Status | Output |
|---|---|---|
| `gen_model_introspection.py` | Operational | `model-introspection.json` — console data source |
| `gen_concept_graph.py` | Operational | 6 Mermaid views + Obsidian concept graph |
| `gen_package_hierarchy.py` | Operational | Package structure visualisation |
| `gen_system_manifest.py` | Operational | `system-manifest.json` |
| `gen_constraint_evaluator.py` | Operational | `constraint-evaluators.ts`, `constraint-specs.ts` |
| `gen_decision_table_evaluator.py` | Operational | `decision-table-evaluators.ts` |
| `projection_engine.py` | Operational | Financial scenario comparison |

### 2.6 Concept graph (Obsidian)

| Metric | Value |
|---|---|
| Total concept graph notes | ~47 (17 patterns, 9 principles, 12 concepts, 3 domains, 1 deferred, indices, templates) |
| Master register entries | ~160 concepts across 15 sections (A–O), four tiers |
| Discussion and exploration papers | 15 |
| Session reports | 21 (Sessions 28–47) |

### 2.7 Session history

| Range | Focus |
|---|---|
| 1–4 | Coffee shop demonstrator Phases A–D |
| 8–10 | Hormone therapy initiation clinical pathway |
| 11–15 | Knowledge layer elaboration (5 phases) |
| 16–22 | Business meta model (7 phases, 19 sessions) |
| 23–32 | CSW Extension (10 phases) |
| 33–34 | Concept Graph and Knowledge Graph Enhancement |
| **35** | **Ontara named. Vision, six-layer architecture, console vision, demonstrator strategy established** |
| 36 | Ontara tooling plan. High-level plan and Stage 1 (model introspection) |
| 37 | Stage 1 implementation — `gen_model_introspection.py` and console scaffold |
| 38–42 | Stage 2 — Console build (6 phases: coverage matrix, package navigator, component catalogue, domain views, glossary, governance) |
| 43 | Stage 3, Phase 1 — Paws demonstrator (cross-domain validation) |
| 44 | Stage 3, Phase 2 — Glossary from model (comprehension UX observation) |
| 45 | Comprehension architecture exploration — three-register model, authored vs intrinsic |
| 46 | Intrinsic self-knowledge, unity principle, weighted relationships, inferential comprehension |
| **47** | **Structured project review — tiered register, governance strengthening** |

---

## 3. Architecture Overview

### 3.1 The six-layer architecture

| Layer | Name | Content |
|---|---|---|
| 6 | Meta-meta level | SysML v2 itself — the language and Syside Modeler |
| 5 | Business Meta Model (BMM) | Structural template for what a service business *is*: ServiceConcept, ActivityModel, ResourcePlanning, FinancialPlanning, GovernanceMapping, BusinessScenarios, BusinessStrategy |
| 4 | Business System Meta Model (BSMM) | Structural template for how a business system *works*: Foundation, Knowledge, ServiceDelivery, Platform, Operations, PatternCatalogue |
| 3 | Business model instances | Specific service businesses described using Layer 5 concepts: GSL, Cafe, Suds, Paws |
| 2 | System model instances | Concrete implementation described using Layer 4 concepts |
| 1 | Runtime | The running system — generated and governed by the model, not modelled in SysML |

### 3.2 The two meta model distinction (A4)

The project maintains two distinct meta models:

- **Business Meta Model** — what a service business *is*. Seven packages covering five concerns (ServiceConcept, ActivityModel, ResourcePlanning, FinancialPlanning, GovernanceMapping) plus scenario modelling and strategy.
- **Business System Meta Model** — how a business system *works*. Currently distributed across Foundation, Knowledge, ServiceDelivery, Platform, Operations, PatternCatalogue. A future workstream will promote these into a named, navigable structure.

The two are connected by explicit horizontal mappings at every tier (General BMM ↔ General BSMM, Tailored BMM ↔ Tailored BSMM, Individual business models ↔ Individual system models). Components within each meta model are classified as General (common to most service businesses) or Tailored (sector-specific).

### 3.3 Separation of representation and execution (A1)

The representation layer (SysML v2, archetypes, decision logic) is where knowledge lives. The execution layer (Temporal, XState, EHRbase, SvelteKit, PostgreSQL) is where things happen. Execution consumes representation but does not define it. When anything needs to change, the change happens in representation and propagates to execution via generation or configuration.

### 3.4 Architecture diagram

```
Representation Layer (SysML v2)           Execution Layer
├── Enterprise (org, regulation)          ├── SvelteKit frontend (CSW: 9 pages)
├── Foundation (metadata, types, state)   ├── Ontara Console (10 pages)
├── Knowledge (CDS, self-knowledge)       ├── Temporal workflows (FulfilDrink)
├── ServiceDelivery (pathways, consent)   ├── XState v5 (OrderLifecycle)
├── Platform (portal, EHR, booking)       ├── EHRbase CDR (3 archetypes)
├── Operations (finance, people)          ├── PostgreSQL (4 tables)
├── BusinessModel (concept, activity)     └── Generation pipeline (7 generators)
├── BusinessScenarios (projection)
├── BusinessStrategy (objectives)         Ontara Console
└── PatternCatalogue (22 patterns,        ├── Coverage Matrix
     8 principles, 43 relationships)      ├── Package Navigator
                                          ├── Component Catalogue
Demonstrator Models                       ├── Glossary
├── Cafe (9 .sysml files, full app)       ├── Governance View
├── Suds (1 .sysml file, BMM instance)    ├── Meta-Model View
└── Paws (1 .sysml file, BMM instance)    ├── Patterns View
                                          └── Domain Views (Cafe, Suds, Paws)
```

---

## 4. The Comprehension Architecture

This is the major conceptual advance of Sessions 45–47. The architecture addresses the question: how does the system know what it contains, why it is structured that way, and how to explain itself?

### 4.1 The intrinsic self-knowledge principle (A10)

The system's explanations are dynamically computed from live model state, not stored as static text. Self-knowledge is not painted on or bolted on — it is intrinsic.

The dividing-line test: if the model changes and no human edits a description, does the explanation become wrong? If yes, that content must be intrinsic.

### 4.2 The three-register model

| Register | Content | Source | Status |
|---|---|---|---|
| **Register 1: Authored** | Human-written purposive descriptions — why an element exists and what it does | `@UserFacing` metadata in SysML, maintained by the architect | Designed. 26 draft descriptions produced. Implementation pending (Stage 3, Phase 3). |
| **Register 2: Structural** | Facts the model already knows — type, relationships, containment, patterns, domain instantiations | Dynamically derived from model structure via `@Comprehension` metadata | Designed. Foundation concept and traversal schema defined. |
| **Register 2+: Inferential** | Derived explanations that go beyond what any single element states — analogies, gap analysis, impact propagation | Computed from weighted relationships, cross-domain comparison, structural analysis | Research direction identified. Depends on reasoning formalisms (M7). |

### 4.3 The unity principle (A11)

One weighted relationship model informs comprehension, reasoning, simulation, governance, and assembly guidance. No separate, disconnected knowledge structures. The factors bearing on explanatory descriptions must be the same factors bearing on projections, question-answering, prediction, risk assessment, simulation, and governance activities.

### 4.4 Weighted relationships (B14)

Relationships between elements and concepts are characterised by strength of interaction effect. The approach starts with ordinal classification (strong/moderate/weak), designed for hybrid evolution (structural baseline + human overrides). The weight model supports three interpretive frames: costs/preferences, fuzzy human judgements, and probabilities (the latter for clinical decision support).

### 4.5 Reasoning formalisms research direction (M7)

Sessions 45–46 identified relevant formalisms for the inferential comprehension layer: semiring soft-constraints for multi-criteria optimisation, fuzzy multi-criteria decision-making (MCDM) for preference modelling, and Probabilistic Soft Logic (PSL) for combining logical rules with probabilistic weights. This remains a research direction — the platform is not committed to any specific formalism. Current work must not foreclose any of these options (J3).

### 4.6 Key architectural decision: Option 3

The comprehension structure is modelled in SysML (as `metadata def` with traversal schemas), not in generator logic or in view-layer assembly. This ensures comprehension is governed by A3 (model generates everything) — the model is the single source of truth for what the system explains and how.

---

## 5. The Ontara Console

The console is a web-based frontend providing intuitive, modern, visual access to the layered architecture. It is built with SvelteKit and Tailwind v4, consuming `model-introspection.json` generated from the SysML model.

### 5.1 What is built

| View | Description | Status |
|---|---|---|
| Coverage Matrix | Which meta model concepts are instantiated in which domains. The visual answer to "what have we modelled?" | Built (Stage 2, Phase 1) |
| Package Navigator | Hierarchical exploration of all ~73 packages with doc blocks, part defs, and attributes | Built (Stage 2, Phase 2) |
| Component Catalogue | Four-quadrant classification (General/Tailored × BMM/BSMM) with domain instantiation status | Built (Stage 2, Phase 3) |
| Domain Views | Per-domain detail pages for Cafe, Suds, Paws — what each domain instantiates | Built (Stage 2, Phase 4) |
| Glossary | Every defined term in the model, grouped by package, with definitions from doc blocks | Built (Stage 2, Phase 5; enhanced Stage 3, Phase 2) |
| Governance View | Traceability from requirements through constraints to satisfaction evidence | Built (Stage 2, Phase 6) |
| Patterns View | 22 validated patterns with semantic relationships | Built (reads from PatternCatalogue) |
| Meta-Model View | Structural overview of the meta model layers | Built |

### 5.2 What is planned

The console vision extends to a **dual-canvas construction kit**:

- **Business Canvas** — a drag-and-drop surface for composing a business model from modular pieces (instances of Layer 5 concepts). The meta model defines the palette.
- **System Canvas** — a corresponding workspace for technology and process components (instances of Layer 4 concepts). Connected to the Business Canvas by vertical mappings.

The dual canvas is a future development horizon. Current console work focuses on comprehension capabilities — making the existing model navigable, understandable, and self-explaining.

---

## 6. Demonstrator Domains

### 6.1 Rationale

The architecture claims to generalise. A single domain cannot prove this. Multiple structurally different domains validate the meta models across different business shapes.

### 6.2 The domains

| Domain | Display Label | Character | Key structural difference | Model status |
|---|---|---|---|---|
| Coffee Shop | Cafe | Immediate retail | Per-item pricing, walk-in, 2-minute cycle | Full model + running application (22 validated patterns) |
| Drop-off Laundry | Suds | Batch processing | Weight/type-dependent pricing, batch turnaround, item tracking | Business model instance validated |
| Dog Grooming | Paws | Appointment-based personal service | Per-appointment pricing with breed/size surcharges, scheduled slots, persistent client/animal identity | Business model instance validated (Stage 3, Phase 1) |

### 6.3 Dual purpose

Demonstrator domains serve two purposes:

1. **Cross-domain validation (J1).** Three structurally different businesses validate that the BMM vocabulary generalises.
2. **Pedagogical anchoring.** Concrete illustrations that make abstract concepts tangible for non-technical users. When a colleague doesn't understand "Activity Type", the demonstrators provide worked examples.

### 6.4 GSL's relationship to the demonstrators

GSL is not a demonstrator — it is the production use case. Demonstrators are where concepts are validated before they earn their way into the platform's core vocabulary. The validation sequence: toy domains first, then GSL and health (A5).

---

## 7. Governance and Development Process

### 7.1 The tiered register

The master register (~160 concepts across 15 sections) is structured into four tiers of influence:

| Tier | Name | Count | When checked | Violation standard |
|---|---|---|---|---|
| **T1** | Governing Principles | 10 | Every session start | Violated only with explicit justification |
| **T2** | Structural Commitments | ~35 | When starting workstreams/phases | Ignoring produces structurally unsound work |
| **T3** | Design Decisions and Conventions | ~85 | When working in their domain | Revisable within architectural constraints |
| **T4** | Future Directions and Horizon Items | ~30 | Periodic review | Current work must not foreclose |

The 10 Tier 1 Governing Principles: A1 (separation of representation/execution), A2 (self-describing system), A3 (model generates everything), A4 (two meta model distinction), A6 (deterministic/auditable reasoning), A9 (discipline as load-bearing structure), A10 (intrinsic self-knowledge), A11 (unity principle), J2 (co-evolution), J3 (non-constraining).

### 7.2 Discussion paper pipeline

When a discussion paper introduces concepts that should become binding, the session report explicitly identifies them and the register update adds them at the appropriate tier. Discussion papers remain working documents; their implications are traced into the governance structure before the session closes.

### 7.3 Development methodology

The Ontara development workflow is documented in a standing workflow guide. Key principles:

- **Ella leads, Claude supports.** Ella decides what to build, when, and why.
- **Discuss before building.** "Shall I go ahead?" is a genuine question.
- **Plan before implementing.** High-level plans set stages; detailed implementation plans precede each stage.
- **No silent regression.** Previously established concepts remain in force unless explicitly retired. The tiered register is the guard.
- **Co-evolution (J2).** Model and tooling advance together — no modelling without the view that makes it legible, no tool without model content that exercises it.
- **Non-constraining (J3).** Decisions should not foreclose future development paths.
- **Discipline as load-bearing structure (A9).** Disciplined practices propagate reliability through the platform to the end user.

### 7.4 Tooling and environment

| Tool | Role |
|---|---|
| **Syside Modeler** | SysML v2 authoring and parsing. Ella validates all model changes here. |
| **Visual Paradigm** | UML/BPMN diagramming alongside SysML |
| **Obsidian** | Primary authoring environment for working documents, concept graph, session reports |
| **Git / GitHub** | Version control for crystallised snapshots and all code |
| **Claude (Chat, Code, Cowork)** | Analysis, drafting, implementation, review. Chat for design; Code for Python/TypeScript implementation; Cowork for file management tasks |
| **Hookmark** | Cross-desktop linking between Obsidian notes and SysML files via Finder |

---

## 8. Current Development State

### 8.1 Where we are

The project is in **Stage 3** of the Ontara high-level plan:

| Stage | Focus | Status |
|---|---|---|
| Stage 1 | Model introspection — `gen_model_introspection.py` | Complete |
| Stage 2 | Console build — 6 phases (coverage, packages, catalogue, domains, glossary, governance) | Complete |
| **Stage 3** | **Comprehension and cross-domain validation** | **In progress** |

Within Stage 3:

| Phase | Deliverable | Status |
|---|---|---|
| Phase 1 | Paws demonstrator — cross-domain validation | Complete |
| Phase 2 | Glossary from model — comprehension UX observation | Complete |
| **Phase 3** | **Comprehension metadata — 4 deliverables** | **Designed, not yet implemented** |

### 8.2 Phase 3 deliverables (designed in Session 46)

1. **Register 1:** Apply 26 purposive descriptions to `@UserFacing` metadata in the model
2. **Register 2 foundation:** Design and implement `@Comprehension` metadata with traversal schema
3. **Syntax spike:** Test `ref` inside `metadata def` (SysML v2 construct validation)
4. **Ordinal weight classification:** Design and pilot weighted relationships on Activity Type

### 8.3 Governing documents

| Document | Status |
|---|---|
| Strategic snapshot | This document (Session 48). Replaces Session 31/34 version. |
| Vision and architecture reference | Partially current (Session 35/45). Targeted revision planned for this session. |
| Tiered master register | Current (Session 47). Canonical governance document. |
| Development workflow guide | Current (Session 35). |

---

## 9. Key Risks

| # | Risk | Mitigation |
|---|---|---|
| R1 | **Single developer.** Ella is sole developer, architect, and domain expert. Execution bandwidth is limited. | The model-driven approach ensures knowledge lives in the model, not in someone's head. The comprehension architecture is designed so the model can explain itself to a new reader. Claude (Chat, Code, Cowork) extends development capacity. |
| R2 | **No second clinical pathway.** The architecture claims to generalise clinical processes — a second pathway would prove it. | Three non-clinical demonstrators validate meta model generality. A second clinical pathway is a candidate workstream once the comprehension architecture is in place. |
| R3 | **Generation pipeline partial.** Seven generators operational; additional generation targets designed but not built (TypeScript types, XState machines, Temporal scaffolds from model). | Generators are built as needed following the co-evolution principle (J2). Current generators cover the immediate needs. |
| R4 | **Clinical data layer untouched since CSW Phase E.** CDR integration patterns validated in the coffee shop; clinical archetypes not yet designed for GSL production use. | Patterns are proven. Extension to GSL clinical archetypes is a candidate workstream. |
| R5 | **Reasoning formalisms uncommitted.** The inferential comprehension layer (Register 2+, I18) depends on formalisms (semiring soft-constraints, fuzzy MCDM, PSL) that are identified but not evaluated. | Treated as a research direction (M7). Current architecture must not foreclose any option (J3). Ordinal weight classification provides a working foundation while research proceeds. |
| R6 | **Silent regression risk.** With ~160 concepts and growing complexity, previously established principles can be inadvertently contradicted by new work. | The tiered register with Tier 1 session-start review is the primary guard. The development workflow guide mandates concept register checks at session open and close. Discussion paper pipeline convention ensures new binding concepts are explicitly traced. |
| R7 | *(Reserved — Ella to add)* | |
| R8 | *(Reserved — Ella to add)* | |

---

## 10. Validated Architectural Patterns (22)

### Business meta model patterns (4)

| Pattern | Status | Cafe | Suds | Paws |
|---|---|---|---|---|
| Four-layer item model | Validated | ✓ | ✓ | ✓ |
| Activity taxonomy | Validated | ✓ | ✓ | ✓ |
| Scenario comparison and projection | Validated | — | — | — |
| Persistence policy as queryable reasoning | Validated | ✓ | — | — |

### Business system meta model patterns (16)

| Pattern | Status | Cafe | Suds | Paws |
|---|---|---|---|---|
| SysML v2 as single source of truth | Validated | ✓ | ✓ | ✓ |
| Two-layer pathway modelling | Validated | ✓ | — | — |
| Five-layer self-knowledge | Validated | — | — | — |
| Three-persistence-layer architecture | Validated | ✓ | — | — |
| Metadata-driven generation | Validated | ✓ | ✓ | ✓ |
| XState in Temporal | Validated | ✓ | — | — |
| Catalogue-as-UI-contract | Validated | ✓ | — | — |
| Kanban-as-process-dashboard | Validated | ✓ | — | — |
| Split-view management layout | Validated | ✓ | — | — |
| Category-conditional form fields | Validated | ✓ | — | — |
| Cross-page data consistency | Validated | ✓ | — | — |
| Audit-as-timeline data source | Validated | ✓ | — | — |
| Process + domain + governance unified view | Validated | ✓ | — | — |
| CDR source provenance badges | Validated | ✓ | — | — |
| Auto-loading entity views | Validated | ✓ | — | — |
| Infrastructure health as app concern | Validated | ✓ | — | — |

### Cross-cutting (1)

| Pattern | Status |
|---|---|
| Demonstrator-first validation (A5) | Validated |

### Deferred/conceptual (6+)

| Pattern | Status |
|---|---|
| Composite order / multi-workflow orchestration | Discussion |
| Agency classification on actions | Designed |
| Self-assessment dashboard (KL Increment 3) | Designed |
| OptionEvaluator / Help Me Choose | Designed |
| Data release model (patient-facing) | Discussion |
| Notification triggers on transitions | Discussion |

---

## 11. What Comes Next

### Immediate (current session and next)

1. **Vision reference revision** — targeted update to reflect comprehension architecture, A9, A10, A11, B14, I18, tiered governance. (This session.)
2. **Phase 3 implementation plan** — detailed plan for the four comprehension metadata deliverables identified in Session 46.
3. **Phase 3 implementation** — Register 1 (purposive descriptions), Register 2 foundation (`@Comprehension` metadata), syntax spike, ordinal weight pilot.

### Near-term

4. **Review 26 draft purposive descriptions** — Ella to review and iterate before they are applied to the model.
5. **Concept note expansion** — individual concept notes created organically as sessions reference them (co-evolution).

### Horizon

6. **Register 2+ (inferential comprehension)** — depends on reasoning formalisms research (M7) and the ordinal weight pilot.
7. **Second clinical pathway** — proves generalisation of the clinical process architecture.
8. **BSMM promotion** — current BSMM concepts distributed across packages; future workstream to promote into a named, navigable structure.
9. **Dual-canvas construction kit** — the Business Canvas and System Canvas for visual business/system composition.
10. **Service subject ≠ customer** — queued meta model discussion (carried forward from Session 46).

---

*Strategic snapshot prepared 20 March 2026 (Session 48). Replaces the Session 31/34 snapshot.*
