# Ontara — Strategic Snapshot

**Date:** 23 March 2026 (Session 60)
**Prepared by:** Claude (Opus 4.6), from direct review of the codebase, Obsidian vault, and Sessions 35–60
**Scope:** The Ontara platform in its entirety — model, demonstrators, console, governance, and development state
**Replaces:** [[ontara-ref-strategic-snapshot-2026-03-20-s48|Session 48 snapshot]] (20 March 2026)

---

## 1. What Ontara Is

**Ontara** is a service system development and delivery platform, particularly strong in supporting regulated care service delivery.

The name itself evokes a grounding in ontology, a sense of being and essence, along with a feminine intuition of awareness of self. This reflects some of the deeper foundational principles and deliberately holistic design ethos of the platform, which is the basis for a highly sophisticated, 'self-aware' and technically advanced ecosystem.

Ontara encompasses **all layers** of the system: meta models, business models, system models, the execution platform, the generation pipeline, and the developer/architect tooling (the [[ontara-ref-vision-architecture|Ontara Console]]).

Ontara is not the name of one component. It is the name for the whole.

GenderSense Limited (GSL) — a private gender-affirming healthcare service — is the primary motivating use case and the first production tenant of a service business on the platform. Ella Green is the founder of GSL, the sole developer and architect of Ontara, and a GP specialist in transgender health (NHS East of England Gender Service).

The architectural thesis is that a SysML v2 model serves as the single source of truth for what a service business is, how it works, what rules govern it, and how the technology platform supports it. The model generates the execution layer rather than merely documenting it. The model also describes its own architectural patterns, the semantic relationships between them, and — through the [[concept-comprehension-layer|comprehension architecture]] — its own explanations of what it contains and why.

This contrasts markedly with the more typical and classical situation where the *model* of business or activity supported by a technical system is implicit rather than clearly explicit and usually highly incomplete. Usually, detail and missing parts of the business model are held variously in the minds of the designer, the user, third parties, loosely and partially documented sources, such as early use-case patterns, undocumented assumptions, ad hoc business process conventions, etc. or frequently not represented at all, leading to risks of miscommunication and lack of shared assumptions.

Classically, trying to map the functions of a business system to a business model and vice versa has been a highly time-consuming, fraught and challenging exercise, usually producing limited benefit to the business or organisation. Stakeholder disengagement is the norm and business process re-engineering remains something that people with hard hats and fluorescent jackets do while walking around industrial sites.

### 1.1 Platform identity

Ontara meets the technical definition of a platform as distinct from a product or framework: modular architecture with standardised interfaces; abstraction and generality through meta models; lifecycle support from design through operation; evolutionary stability through versioning, the [[concept-non-constraining|non-constraining principle (J3)]], and the PatternCatalogue; ecosystem enablement through dual-canvas tooling and meta-model-defined palettes; composability, extensibility, and integrated tooling.

The [[ontara-discussion-domain-identity-architecture-2026-03-22-v2.1|multi-tenancy principle (A13, T1 candidate)]] sharpens this identity: only the meta model is core. Every domain — including GSL — is a tenant instantiation, an exercise of the system's capabilities against a specific service business.

---

## 2. Scale and Maturity

### 2.1 The SysML model

| Metric | Value |
|---|---|
| Top-level packages | 11 (Enterprise, Foundation, Knowledge, ServiceDelivery, Platform, Operations, BusinessModel, BusinessScenarios, BusinessStrategy, PatternCatalogue, GenderSense root) |
| Total packages | ~73 |
| Core model files | 11 `.sysml` files |
| PatternCatalogue | 22 patterns, 8 principles, 33 domain instantiations, ~43 typed `ref` relationships |
| BMM elements | 28 `part def`s + `requirement def`s across 5 concern packages + GovernanceMapping |
| Comprehension annotations | 28/28 `@UserFacing`, 28/28 `@PurposiveDescription`, 28/28 `@Comprehension`, 79 `@WeightedRelationship` |
| Typed cross-references | 12 BMM attributes migrated from String to typed `ref` (Session 58, [[deferred-string-to-typed-ref-migration|O25]]) |

### 2.2 Demonstrator model files

| Domain | Files | Status |
|---|---|---|
| [[domain-cafe|Cafe]] (Coffee Shop) | 9 `.sysml` files (4 business model + 5 domain model) | Full demonstrator with running application |
| [[domain-suds|Suds]] (Laundry) | 1 `.sysml` file | Business model instance validated; full BMM coverage including COSHH governance chain |
| [[domain-paws|Paws]] (Dog Grooming) | 1 `.sysml` file | Business model instance validated; General vocabulary only; ServiceSubject/ServiceParticipant instantiated |

### 2.3 The Ontara Console

| Metric | Value |
|---|---|
| Stack | SvelteKit + Svelte 5 runes + Flowbite Svelte + Tailwind v4 |
| Console pages | 10 (Home, Coverage Matrix, Package Navigator, Component Catalogue, Glossary, Governance, Meta-Model, Patterns, plus domain views) |
| Data source | `model-introspection.json` generated from SysML via `gen_model_introspection.py` |
| Glossary features | Alphabetical listing, search, BMM Concern/Layer filtering, inline expand/collapse, cross-links to Component Catalogue and Coverage Matrix, purposive descriptions ("What this means for your service"), intrinsic comprehension content ("How this element works in the model"), weight-aware related concepts with warm-to-cool dot bar indicator |

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
| `gen_model_introspection.py` | Operational | `model-introspection.json` — console data source. Extracts `@CatalogueTag`, `@UserFacing`, `@PurposiveDescription`, `@Comprehension`, `@WeightedRelationship` metadata. Traversal discovery engine for intrinsic comprehension content. |
| `gen_concept_graph.py` | Operational | 6 Mermaid views + Obsidian concept graph |
| `gen_package_hierarchy.py` | Operational | Package structure visualisation |
| `gen_system_manifest.py` | Operational | `system-manifest.json` |
| `gen_constraint_evaluator.py` | Operational | `constraint-evaluators.ts`, `constraint-specs.ts` |
| `gen_decision_table_evaluator.py` | Operational | `decision-table-evaluators.ts` |
| `projection_engine.py` | Operational | Financial scenario comparison |

### 2.6 Knowledge base (Obsidian vault)

| Metric | Value |
|---|---|
| Concept graph notes | ~54 (17 patterns, 11 principles, 17 concepts, 5 domains, 3 deferred, indices, templates) |
| [[ontara-ref-master-register-design-concepts-tiered-2026-03-20|Master register]] entries | ~171 concepts across 15 sections (A–O), four tiers |
| Discussion and exploration papers | 16 |
| Session reports | 32 (Sessions 28–59) |
| [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]] entries | 9 (E001–E009) |
| Vault structure | Seven top-level folders under `02 ONTARA ARCHITECTURE & MODELLING/`, fully wikilinked |

### 2.7 Session history

| Range | Focus |
|---|---|
| 1–4 | Coffee shop demonstrator Phases A–D |
| 8–10 | Hormone therapy initiation clinical pathway |
| 11–15 | Knowledge layer elaboration (5 phases) |
| 16–22 | Business meta model (7 phases, 19 sessions) |
| 23–32 | CSW Extension (10 phases) |
| 33–34 | Concept Graph and Knowledge Graph Enhancement |
| **35** | **Ontara named. Vision, six-layer architecture, console vision, demonstrator strategy** |
| 36 | Ontara tooling plan. High-level plan and Stage 1 |
| 37 | Stage 1 — `gen_model_introspection.py` and console scaffold |
| 38–42 | Stage 2 — Console build (6 phases: coverage matrix, package navigator, component catalogue, domain views, glossary, governance) |
| 43–45 | Stage 3, Phases 1–2 — Paws demonstrator; Glossary from model; comprehension architecture exploration |
| 46 | Intrinsic self-knowledge, unity principle, weighted relationships, inferential comprehension |
| 47 | Structured project review — tiered register, governance strengthening |
| 48 | Strategic snapshot (Session 48 version) |
| 49–51 | **Stage 3, Phase 3** — Comprehension metadata: syntax spike, `@PurposiveDescription` (26/26), `@Comprehension` metadata def, ordinal weight pilot |
| 52–55 | **Stage 3, Phase 4** — Comprehension population: bulk `@Comprehension` (28/28), weight population (79 weights, 4 batches), ServiceSubject + ServiceParticipant, directionality definition, heuristics |
| 56 | Knowledge base enrichment — 48 wikilinks, vault reorganisation, 7 concept/domain notes, binding wikilink rule |
| 57 | Planning — Phase 5, E003, Stage 4 high-level plan |
| 58 | **Stage 3, Phase 5** — String-to-typed-ref migration ([[deferred-string-to-typed-ref-migration|O25]] closed); E003 syntax spike verified. **Stage 3 closed.** |
| 59 | Vault review → foundational architecture: domain identity, temporality, coordinate framework, ontological grounding (4 discussion papers) |
| **60** | **Housekeeping, register update, strategic snapshot refresh (this document)** |

---

## 3. Architecture Overview

### 3.1 The six-layer architecture

| Layer | Name | Content |
|---|---|---|
| 6 | Meta-meta level | SysML v2 itself — the language and Syside Modeler |
| 5 | Business Meta Model (BMM) | Structural template for what a service business *is*: ServiceConcept, ActivityModel, ResourcePlanning, FinancialPlanning, GovernanceMapping |
| 4 | Business System Meta Model (BSMM) | Structural template for how a business system *works*: Foundation, Knowledge, ServiceDelivery, Platform, Operations, PatternCatalogue |
| 3 | Business model instances | Specific service businesses described using Layer 5 concepts: GSL, Cafe, Suds, Paws |
| 2 | System model instances | Concrete implementation described using Layer 4 concepts |
| 1 | Runtime | The running system — generated and governed by the model, not modelled in SysML |

### 3.2 The two meta model distinction ([[principle-two-meta-model-distinction|A4]])

The project maintains two distinct meta models:

- **Business Meta Model** — what a service business *is*. 28 elements across five concerns (ServiceConcept, ActivityModel, ResourcePlanning, FinancialPlanning, GovernanceMapping). Components classified as General (common to most service businesses) or Tailored (sector-specific).
- **Business System Meta Model** — how a business system *works*. Currently distributed across Foundation, Knowledge, ServiceDelivery, Platform, Operations, PatternCatalogue. A future workstream will promote these into a named, navigable structure.

Connected by explicit horizontal mappings at every tier (General BMM ↔ General BSMM, Tailored BMM ↔ Tailored BSMM, Individual business models ↔ Individual system models).

### 3.3 The coordinate framework (A12, T1 candidate — Session 59)

A foundational reconceptualisation: the system's representational space is a **multi-dimensional coordinate space**, not a hierarchy. Every conceptual entity traces a trajectory through this space. Existing architectural features — coverage matrix, component catalogue, glossary, governance traceability — are projections of the same coordinate space.

The coordinate system test: *"Can I add a new axis without refactoring?"*

Ontologically grounded in BFO (Basic Formal Ontology, ISO/IEC 21838-2:2021), whose continuant/occurrent/spatiotemporal framework is structurally identical to the coordinate framework's spacetime concept. BFO's "history" = sum of processes in a spatiotemporal region = coordinate framework's "trajectory".

The proposed ontology stack: BFO → CCO (enterprise semantics) / OGMS (clinical) / IAO (information artefacts) → domain-specific extensions. Directional commitment — not yet implemented.

### 3.4 Architecture diagram

```
Representation Layer (SysML v2)           Execution Layer
├── Enterprise (org, regulation)          ├── SvelteKit frontend (CSW: 9 pages)
├── Foundation (metadata, types, state)   ├── Ontara Console (10 pages)
├── Knowledge (CDS, self-knowledge)       ├── Temporal workflows (FulfilDrink)
├── ServiceDelivery (pathways, consent)   ├── XState v5 (OrderLifecycle)
├── Platform (portal, EHR, booking)       ├── EHRbase CDR (3 archetypes)
├── Operations (finance, people)          ├── PostgreSQL (4 tables)
├── BusinessModel (28 elements, 5 pkgs)   └── Generation pipeline (7 generators)
├── BusinessScenarios (projection)
├── BusinessStrategy (objectives)         Ontara Console
└── PatternCatalogue (22 patterns,        ├── Coverage Matrix
     8 principles, 43 relationships)      ├── Package Navigator
                                          ├── Component Catalogue (4-quadrant)
Comprehension Architecture                ├── Glossary (28/28, weight-aware)
├── @UserFacing (28/28)                   ├── Governance View
├── @PurposiveDescription (28/28)         ├── Meta-Model View
├── @Comprehension (28/28, 4 flags)       ├── Patterns View
├── @WeightedRelationship (79 weights)    └── Domain Views (Cafe, Suds, Paws)
└── 12 typed cross-refs (O25 complete)
                                          Demonstrator Models
                                          ├── Cafe (9 .sysml, full app)
                                          ├── Suds (1 .sysml, BMM + COSHH)
                                          └── Paws (1 .sysml, General vocab)
```

---

## 4. The Comprehension Architecture

The major achievement of Sessions 45–58. The architecture addresses the question: how does the system know what it contains, why it is structured that way, and how to explain itself?

### 4.1 The intrinsic self-knowledge principle ([[principle-intrinsic-self-knowledge|A10]])

The system's explanations are dynamically computed from live model state, not stored as static text. Self-knowledge is not painted on or bolted on — it is intrinsic.

The dividing-line test: if the model changes and no human edits a description, does the explanation become wrong? If yes, that content must be intrinsic.

### 4.2 The three-register model

| Register | Content | Source | Status |
|---|---|---|---|
| **Register 1: Authored** | Human-written purposive descriptions — why an element exists and what it does | `@PurposiveDescription` metadata in SysML | **Complete.** 28/28 coverage (Sessions 49, 55). |
| **Register 2: Structural** | Facts the model already knows — type, relationships, containment, patterns, domain instantiations | Dynamically derived via `@Comprehension` metadata traversal schema | **Complete.** 28/28 coverage. Four boolean flags per element. Generator traversal discovery engine operational (Sessions 50, 52). |
| **Register 2+: Inferential** | Derived explanations that go beyond what any single element states — analogies, gap analysis, impact propagation | Computed from [[concept-weighted-relationships|weighted relationships]], cross-domain comparison, structural analysis | Research direction. Depends on reasoning formalisms (M7). |

### 4.3 The unity principle ([[principle-unity-principle|A11]])

One weighted relationship model informs comprehension, reasoning, simulation, governance, and assembly guidance. No separate, disconnected knowledge structures.

### 4.4 Weighted relationships ([[concept-weighted-relationships|B14]])

**79 `@WeightedRelationship` annotations** across 27 weighted elements (27 strong, 50 moderate, 2 weak). AuditEvidenceRecord is a pure receiver with zero outgoing weights.

Key properties: directional ("if A changes, how much does B need reassessment?"), non-commutative (A → B and B → A are independently assessed), with five inductively established heuristics (H1–H5) documented in [[ontara-ref-weighted-relationship-heuristics-and-config-2026-03-21|the heuristics and configuration reference]].

The weight model supports three interpretive frames: costs/preferences, fuzzy human judgements, and probabilities (the latter for clinical decision support). Connected to [[principle-unity-principle|A11]] — the same weights inform all subsystems.

### 4.5 Reasoning formalisms research direction (M7)

Three formalisms identified as relevant: semiring soft-constraints, fuzzy multi-criteria decision-making (MCDM), and Probabilistic Soft Logic (PSL). This remains a research direction — current work must not foreclose any option ([[concept-non-constraining|J3]]).

---

## 5. The Ontara Console

### 5.1 What is built

| View | Description | Status |
|---|---|---|
| Coverage Matrix | Which meta model concepts are instantiated in which domains | Built (Stage 2, Phase 1). Domain filter. |
| Package Navigator | Hierarchical exploration of all ~73 packages with doc blocks, part defs, attributes | Built (Stage 2, Phase 2) |
| Component Catalogue | Four-quadrant classification (General/Tailored × BMM/BSMM) with domain instantiation status | Built (Stage 2, Phase 3). Multi-axis grouping, comprehension layer rendering. |
| Domain Views | Per-domain detail pages for Cafe, Suds, Paws | Built (Stage 2, Phase 4) |
| Glossary | Every defined term in the model, with authored + intrinsic comprehension content, weight-aware related concepts | Built (Stage 2/3). BMM Concern/Layer filtering, search, expand/collapse, cross-links, warm-to-cool dot bar. |
| Governance View | Traceability from requirements through constraints to satisfaction evidence | Built (Stage 2, Phase 6) |
| Patterns View | 22 validated patterns with semantic relationships | Built |
| Meta-Model View | Structural overview of the meta model layers | Built |

### 5.2 What is planned (Stage 4)

The [[ontara-stage-4-high-level-plan-2026-03-21|Stage 4 high-level plan]] covers structural navigation and construction in five phases:

1. **Weighted Relationship Graph** (E001) — D3.js force-directed graph in the console
2. **Cross-Package Navigation** — deep linking, breadcrumbs, typed ref navigation
3. **BMM Concern Group Descriptions** (E003) — package-level purposive descriptions
4. **Structural Completeness Visualisation** — completeness heatmap, gap identification
5. **Assembly Workspace Prototype** — configuration builder, the seed of the dual-canvas vision

The longer-term vision extends to a **dual-canvas construction kit**: a Business Canvas for composing business models from modular pieces, and a System Canvas for technology components, connected by vertical mappings.

---

## 6. Demonstrator Domains

### 6.1 Rationale

Demonstrator domains serve two purposes ([[concept-cross-domain-validation|J1]]):

1. **Cross-domain validation.** Three structurally different businesses validate that the BMM vocabulary generalises.
2. **Pedagogical anchoring.** Concrete illustrations that make abstract concepts tangible for non-technical users.

### 6.2 The domains

| Domain | Character | Key structural difference | Regulatory tier | BMM coverage |
|---|---|---|---|---|
| [[domain-cafe|Cafe]] | Immediate retail | Per-item pricing, walk-in, 2-minute cycle | Generally governed | Full model + running application (22 validated patterns) |
| [[domain-suds|Suds]] | Batch processing | Weight/type-dependent pricing, batch turnaround, item tracking | Lightly regulated | Full BMM + COSHH governance traceability chain |
| [[domain-paws|Paws]] | Appointment-based personal service | Per-appointment pricing, breed/size surcharges, persistent client/animal identity | Lightly regulated | General vocabulary only; ServiceSubject + ServiceParticipant instantiated |

### 6.3 GSL's relationship to the demonstrators

Under the [[ontara-discussion-domain-identity-architecture-2026-03-22-v2.1|multi-tenancy principle (A13)]], GSL is the most important tenant — but still a tenant. It is not more structurally privileged than the demonstrators; its distinction is purpose (production healthcare delivery) and regulatory tier (sector-regulated).

---

## 7. Foundational Architecture (Session 59)

Session 59 produced four discussion papers that establish a candidate foundational layer beneath the existing architecture. These are working documents — not yet implemented — but they reframe how the platform's representational space is understood.

### 7.1 Domain identity ([[ontara-discussion-domain-identity-architecture-2026-03-22-v2.1|B15]])

Domain is not currently a first-class concept in the architecture — identity is distributed across five ungoverned representations. Proposed: `DomainDefinition` part def in Foundation with canonical properties. Four-tier `RegulatoryTier` enum (generallyGoverned, lightlyRegulated, partiallyRegulated, sectorRegulated).

### 7.2 Temporal reference frames ([[ontara-discussion-temporality-reference-frames-2026-03-22-v2.1|B16]])

Different parts of the system experience time in different reference frames. Eight illustrative frames identified. Vague temporal vocabulary is a first-class concern. [[concept-weighted-relationships|Epistemic modality (B17)]] — every event carries an epistemic status (actual, inferred, expected, predicted, hypothetical, simulated, retrospectively recorded) that determines reasoning and governance obligations.

### 7.3 Ontological grounding ([[ontara-discussion-ontological-grounding-2026-03-22|B18, B19]])

BFO (ISO/IEC 21838-2:2021) as candidate upper ontology. Three-layer ontology stack: BFO → CCO/OGMS/IAO → domain. Mapping discipline: SysML v2 → BFO types → openEHR archetypes. BMM recognised as a de facto BFO-aligned service business mid-level ontology.

---

## 8. Governance and Development Process

### 8.1 The tiered register

The [[ontara-ref-master-register-design-concepts-tiered-2026-03-20|master register]] (~171 concepts across 15 sections) is structured into four tiers:

| Tier | Name | Count | When checked |
|---|---|---|---|
| **T1** | Governing Principles | 10 (+ 2 candidates) | Every session start |
| **T2** | Structural Commitments | ~40 | When starting workstreams/phases |
| **T3** | Design Decisions and Conventions | ~85 | When working in their domain |
| **T4** | Future Directions and Horizon Items | ~30 | Periodic review |

**Tier 1 Governing Principles:**

| # | Principle | One-line test |
|---|---|---|
| [[principle-separation-representation-execution|A1]] | Separation of representation and execution | Changes happen in representation and propagate to execution, never the reverse |
| [[principle-self-describing-system|A2]] | Self-describing system | The system knows what it is, what it is doing, why, and what rules govern it |
| [[principle-model-generates-everything|A3]] | Model generates everything | SysML v2 is the single source of truth |
| [[principle-two-meta-model-distinction|A4]] | Two meta model distinction | BMM and BSMM are distinct, connected by explicit mappings |
| [[principle-deterministic-over-probabilistic|A6]] | Deterministic/auditable reasoning | Clinical decisions use inspectable logic |
| [[principle-discipline-as-load-bearing-structure|A9]] | Discipline as load-bearing structure | Disciplined practices propagate reliability; regression applies to practices, not just code |
| [[principle-intrinsic-self-knowledge|A10]] | Intrinsic self-knowledge | System explanations are dynamically computed from live model state |
| [[principle-unity-principle|A11]] | Unity principle | One weighted relationship model informs all subsystems |
| [[concept-co-evolution|J2]] | Co-evolution | No modelling without the tool that makes it legible; no tool without model content |
| [[concept-non-constraining|J3]] | Non-constraining | Decisions should not foreclose future development paths |

**T1 Candidates (Session 59):**

| # | Principle | One-line test |
|---|---|---|
| A12 | Coordinate framework | The representational space is a multi-dimensional coordinate space; can I add a new axis without refactoring? |
| A13 | Multi-tenancy | Only the meta model is core; every domain is a tenant instantiation |

### 8.2 Methodology highlights

- **[[concept-inception-capture|J13]] — Inception capture as first-class activity** (Session 53). Ideas captured immediately with full fidelity via the [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]]. Nine entries (E001–E009) captured to date.
- **[[concept-design-decision-lifecycle|J12]] — Design decision lifecycle.** Freedom → experimentation → discovered convention → opinionated configuration → revisable.
- **Five weight assignment heuristics** (H1–H5) inductively established through Session 53–54 batch discussions.
- **Binding wikilink rule** (Session 56). All vault references must be wikilinks — no exceptions.
- **[[ontara-workflow-development-guide-2026-03-21|Development workflow guide]]** — living document covering session structure, document workflow, planning discipline, model development, the register protocol, and the wikilink enrichment process.

---

## 9. Current Development State

### 9.1 Where we are

**Stage 3 is closed** (Session 58). **Stage 4 has not started.** Session 59 produced foundational architectural discussion papers. Session 60 executed vault housekeeping, register update, and this snapshot.

| Stage | Focus | Status |
|---|---|---|
| Stage 1 | Model introspection — `gen_model_introspection.py` | Complete (S37) |
| Stage 2 | Console build — 6 phases | Complete (S38–42) |
| **Stage 3** | **Comprehension and cross-domain validation — 5 phases** | **Complete (S43–58)** |
| Stage 4 | Structural navigation and construction — 5 phases | Planned, not started |

Stage 3 breakdown:

| Phase | Deliverable | Sessions |
|---|---|---|
| Phase 1 | [[domain-paws|Paws]] demonstrator | S43–44 |
| Phase 2 | Glossary view | S45 |
| Phase 3 | [[concept-comprehension-layer|Comprehension]] metadata (4 steps: syntax spike, `@PurposiveDescription`, `@Comprehension`, weight pilot) | S49–51 |
| Phase 4 | Comprehension population (3 steps: bulk `@Comprehension`, weight population, ServiceSubject/Participant) | S52–55 |
| Phase 5 | Typed-ref migration ([[deferred-string-to-typed-ref-migration|O25]]) | S57–58 |

### 9.2 Governing documents

| Document | Status |
|---|---|
| Strategic snapshot | **This document** (Session 60). Replaces Session 48 version. |
| [[ontara-ref-vision-architecture|Vision and architecture reference]] | Partially current (Session 35/45). Targeted revision still needed. |
| [[ontara-ref-master-register-design-concepts-tiered-2026-03-20|Tiered master register]] | Current (Session 60). ~171 concepts. |
| [[ontara-workflow-development-guide-2026-03-21|Development workflow guide]] | Current (Session 56 update). |
| [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]] | Current. 9 entries (E001–E009). E002 fully routed; E004/E005/E006 routed to Session 59 papers. |

---

## 10. Key Risks

| # | Risk | Mitigation |
|---|---|---|
| R1 | **Single developer.** Ella is sole developer, architect, and domain expert. | The model-driven approach ensures knowledge lives in the model, not in someone's head. The comprehension architecture means the model can explain itself. Claude (Chat, Code, Cowork) extends development capacity. |
| R2 | **No second clinical pathway.** The architecture claims to generalise clinical processes. | Three non-clinical demonstrators validate meta model generality. A second clinical pathway is a candidate workstream once Stage 4 is underway. |
| R3 | **Generation pipeline partial.** Seven generators operational; additional generation targets designed but not built. | Generators built as needed following [[concept-co-evolution|J2]]. Current generators cover immediate needs. |
| R4 | **Clinical data layer untouched since CSW Phase E.** CDR patterns validated in coffee shop; clinical archetypes not yet designed for GSL production. | Patterns are proven. Extension is a candidate workstream. |
| R5 | **Reasoning formalisms uncommitted.** Inferential comprehension (Register 2+, I18) depends on formalisms not yet evaluated. | Treated as research direction (M7). Current architecture must not foreclose any option ([[concept-non-constraining|J3]]). |
| R6 | **Silent regression risk.** ~171 concepts and growing complexity. | Tiered register with T1 session-start review. [[ontara-workflow-development-guide-2026-03-21|Workflow guide]] mandates register checks. Discussion paper pipeline convention traces new binding concepts. |
| R7 | **Emergence of unwitting conceptual constraints.** Formal project structure may impose a chilling effect on Ella's freedom to ideate, explore and revise. | [[concept-inception-capture|J13]] (inception capture) and the [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]] provide a low-friction path from free ideation to captured knowledge. [[concept-design-decision-lifecycle|J12]] (design decision lifecycle) preserves freedom at early stages. |
| R8 | **Foundational architecture uncommitted.** The coordinate framework, BFO stack, domain identity, and temporality papers are working documents, not binding commitments. | A12 and A13 are registered as T1 candidates. B15–B19 are T2 structural commitments with "directional commitment — not yet implemented" status. The gap between aspiration and implementation needs to be managed through Stage 4 planning. |

---

## 11. What Comes Next

### Immediate

1. **Begin Stage 4.** The [[ontara-stage-4-high-level-plan-2026-03-21|high-level plan]] is ready. Phase 1 (weighted relationship graph) and Phase 3 (E003 BMM concern descriptions) can run in parallel.
2. **Vision reference revision.** The vision and architecture reference is still partially stale. Targeted update needed.

### Near-term

3. **E003 execution.** The syntax spike is verified (Session 58). Small, self-contained — BMM package-level `@PurposiveDescription` annotations, generator extension, glossary enhancement.
4. **E009 execution.** `CostDriver.linkedResource` multiplicity change from `[0..1]` to `[0..*]`. Low-risk post-migration refinement.
5. **Stage 4 Phase 1** — D3.js force-directed graph of weighted relationships in the console.

### Horizon

6. **Second clinical pathway** — proves generalisation of the clinical process architecture.
7. **BSMM promotion** — extract into a named, navigable package structure.
8. **Dual-canvas construction kit** — Business Canvas and System Canvas.
9. **BFO/ontology stack implementation** — move from directional commitment to model changes.
10. **Domain identity implementation** — `DomainDefinition` in Foundation, generator integration.

---

*Strategic snapshot prepared 23 March 2026 (Session 60). Replaces the [[ontara-ref-strategic-snapshot-2026-03-20-s48|Session 48 snapshot]].*
