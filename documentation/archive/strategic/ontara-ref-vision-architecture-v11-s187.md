---
tags:
  - reference
  - architecture
date: 2026-04-09
status: current
session: 187
---
# Ontara — Vision and Architecture Reference

> `= this.file.path`

**Date:** 9 April 2026 (Session 187)
**Previous version:** v10 (Session 169), archived as [[SUPERSEDED-ontara-ref-vision-architecture-v10-s169|Vision and Architecture Reference v10 (Session 169)]]
**Status:** Standing reference document. The authoritative summary of what Ontara is, how it is architecturally structured, what the console and portal visions are, and how the platform comprehends itself.

---

## Contents

- [[#1. What Ontara Is|§1. What Ontara Is]]
- [[#2. Architecture|§2. Architecture]]
- [[#3. The Ontara Console Vision|§3. The Ontara Console Vision]]
- [[#4. The Ontara Portal|§4. The Ontara Portal]]
- [[#5. The Generation Pipeline|§5. The Generation Pipeline]]
- [[#6. Ontological Grounding|§6. Ontological Grounding]]
  - [[#6.7 @BfoType annotations|§6.7 @BfoType annotations]]
  - [[#6.8 Knowledge graph implementation status|§6.8 Knowledge graph implementation status]]
  - [[#6.9 The governance ontology module|§6.9 The governance ontology module]]
  - [[#6.10 Stage 5 Phase 3 — consolidation and round-trip foundation|§6.10 Stage 5 Phase 3]]
  - [[#6.11 Domain identity vocabulary|§6.11 Domain identity vocabulary]]
  - [[#6.12 The reasoning metamodel vocabulary|§6.12 The reasoning metamodel vocabulary]]
  - [[#6.13 Ears reasoning instances|§6.13 Ears reasoning instances]]
- [[#7. Simulation Architecture|§7. Simulation Architecture]]
- [[#8. The Comprehension Architecture|§8. The Comprehension Architecture]]
  - [[#8.6 Two registers of self-knowledge: business and platform|§8.6 Two registers of self-knowledge: business and platform]]
- [[#9. Deontic Governance Architecture|§9. Deontic Governance Architecture]]
  - [[#9.6 CQC Governance MVP|§9.6 CQC Governance MVP]]
  - [[#9.7 Current state and next steps|§9.7 Current state and next steps]]
- [[#10. The Reasoning Metamodel|§10. The Reasoning Metamodel]]
  - [[#10.5 Ears clinical domain intake — first vocabulary validation|§10.5 Ears clinical domain intake]]
- [[#11. Foundational Architecture|§11. Foundational Architecture]]
- [[#12. Demonstrator Domains|§12. Demonstrator Domains]]
- [[#13. Governing Principles|§13. Governing Principles]]
- [[#14. Architecture Carried Forward|§14. Architecture Carried Forward]]
- [[#Related Documents|Related Documents]]

---

## 1. What Ontara Is

**Ontara** is a service system development, delivery, and **execution** platform, particularly strong in supporting regulated care service delivery.

The name itself evokes a grounding in ontology, a sense of being and essence, along with an intuition of awareness of self. This reflects the deeper foundational principles and deliberately holistic design ethos of the platform — the basis for a highly sophisticated, self-aware and technically advanced ecosystem.

Ontara encompasses **all layers** of the system: meta models, business models, system models, the execution platform, the generation pipeline, the comprehension architecture, the developer/architect tooling (the [[#3. The Ontara Console Vision|Ontara Console]]), and the operator-facing platform shell (the [[#4. The Ontara Portal|Ontara Portal]]).

Ontara is not the name of one component. It is the name for the whole.

### 1.1 The architectural thesis

A SysML v2 model serves as the single source of truth ([[principle-model-generates-everything|A3]]) for what a service business is, how it works, what rules govern it, and how the technology platform supports it. The model _generates_ the running system rather than merely documenting it. The model also comprehends itself — it can explain what it contains and why.

Ontara is an **execution platform**, not merely a generation tool. This is established, not aspirational — the coffee shop demonstrator is a running system generated from the model, the [[ontara-discussion-paper-process-specification-layer-2026-03-27|process specification layer]] describes the full pipeline from model to deployed Temporal workflows, and [[principle-separation-representation-execution|A1]] has always said representation _propagates to_ execution. The [[ontara-discussion-dual-stack-architecture-2026-03-26|dual-stack architecture]] (Session 73) made the runtime architecture explicit: the model does not generate code and step aside — it generates systems that remain connected to the model at runtime through the [[concept-operational-simulation|operational simulation (L5)]], where the running system's state _is_ the business model made live. The [[ontara-discussion-portal-state-driven-operator-experience-2026-04-08|Ontara Portal]] (Stage 8, Sessions 174–185) provides the first prototype of this operator experience — a state-driven interface where the operator interacts with live module lifecycles, domain context, progressive governance, and simulation.

This contrasts with the typical situation where the model of a business supported by a technical system is implicit, incomplete, and scattered across code, configuration, documentation, and in people's heads. Mapping the system to the business model — or vice versa — is usually a painful, expensive exercise that produces limited benefit. Ontara's thesis is that this problem is solvable: make the model explicit, make it generative, make it self-describing, and make it comprehensible.

### 1.2 Platform identity

Ontara meets the technical definition of a _platform_ as distinct from a product or framework: modular architecture with standardised interfaces; abstraction and generality through meta models; lifecycle support from design through operation; evolutionary stability through versioning, the [[concept-non-constraining|non-constraining principle (J3)]], and the PatternCatalogue; ecosystem enablement through dual-canvas tooling and meta-model-defined palettes; composability, extensibility, and integrated tooling.

The pragmatic test: if Ella stopped building end-user features, would other teams still find Ontara valuable as a base to build their own service businesses?

### 1.3 Multi-tenancy and the relationship to GenderSense

Under the [[concept-multi-tenancy|multi-tenancy principle (A13)]] — promoted to binding Tier 1 in Session 142 — only the dual-stack meta model is core. Every domain — including GenderSense Limited (GSL), the private gender-affirming healthcare service that was the primary motivating use case — is a tenant instantiation: an exercise of the system's capabilities against a specific service business.

GSL is the most important tenant (if for no reason other than its complexity relative to other toy demonstrators), but it is not more structurally privileged than the demonstrator domains. Its distinction is purpose (production healthcare delivery) and regulatory tier (sector-regulated). The system can maintain any number of demonstrator domains that exercise and test the capability, limits and extensibility of the meta models.

This principle sharpens the platform identity: Ontara is the platform; GSL, [[domain-cafe|Cafe]], [[domain-suds|Suds]], [[domain-paws|Paws]], and [[domain-ears|Ears]] are tenants. Domain identity is now structurally expressed across all three representations — SysML (`DomainIdentity` + `DomainConfiguration`, Session 143), OWL (`ontara-domain.ttl`, Session 144), and the generation pipeline (Sessions 143–144).

---

## 2. Architecture

### 2.1 The six-layer architecture

| Layer | Name | Content |
|---|---|---|
| 6 | Meta-meta level | SysML v2 itself: `part def`, `attribute`, `ref`, `enum def`, `constraint def`, etc. Provided by the language and Syside Modeler. |
| 5 | Business Meta Model (BMM) | The structural template for what a service business _is_. 34 elements across six concerns (five internal + [[concept-stakeholder-model\|StakeholderModel]] at the relational boundary): [[#2.4 The six concerns of a service business\|§2.4]]. |
| 4 | System Meta Model (SMM) | The structural template for how a business system _works_. Renamed from BSMM, Session 92. Now made explicit through the [[concept-dual-stack-architecture\|dual-stack architecture (B21)]]. Extended by the [[#10. The Reasoning Metamodel\|reasoning metamodel]] (Stage 7, Sessions 146–158, formally closed Session 159). |
| 3 | Business model instances | A specific service business described using Layer 5 concepts. GSL, [[domain-cafe\|Cafe]], [[domain-suds\|Suds]], [[domain-paws\|Paws]]. |
| 2 | System model instances | The concrete implementation described using Layer 4 concepts. Frontends, workflows, schemas, persistence policies, generation pipeline outputs. |
| 1 | Runtime | The running system, its state, its data. The [[concept-operational-simulation\|operational simulation (L5)]]. The [[#4. The Ontara Portal\|Ontara Portal]] provides the operator's interface to this layer. |

### 2.2 The dual-stack architecture ([[concept-dual-stack-architecture|B21]])

The [[ontara-discussion-dual-stack-architecture-2026-03-26|dual-stack architecture]] (Session 73) is the most significant architectural advance since the platform was named. The BMM and SMM are two parallel vertical stacks connected by [[ontara-ref-master-register|horizontal mappings (B12)]] at each level.

#### Original sketch (18/03/26)

![[original ontara dual stack hand-drawn diagram.png]]

The original sketch, drawn on 18th March 2026 was conceived following a discussion with Claude the day before, while driving home to Essex from Nottingham, following a BLS training session. The dual stack approach evolved rapidly into a well-described architecture and was solidified following the 'campus walk' exercise on 28th March '26. 

**Left stack — Business Model ("what the business is and does")**

| Layer | Content | Formalism |
|---|---|---|
| Ontology | BFO categories (shared with right side) | OWL 2 DL |
| Domain ontologies | OGMS, IAO, OCE, GSSO, OBI — mid-level, BFO-aligned | OWL 2 DL |
| BMM General vocabulary | Domain-neutral structural concepts (`part def`s) | SysML v2 |
| Business instance | Concrete domain data (`part` usages) | SysML v2 |
| Operational domains | How the business operates — business language | SysML v2 |
| Business process patterns | Dynamic behaviour and flows | SysML v2 |

**Right stack — Business System Model ("how the system realises it")**

| Layer | Content | Formalism |
|---|---|---|
| System ontological categories | BFO-typed system constructs: Process, State, Event, Record | OWL 2 DL |
| SMM General vocabulary | Domain-neutral system concepts (`part def`s) | SysML v2 |
| System instance | Concrete system configuration (`part` usages) | SysML v2 |
| System domains | Running system modules | SysML v2 + execution |
| Operational simulation | System-managed execution — Temporal workflows, state management, event streams | Temporal / CLP(FD) |

A critical correction established in Session 73: what was previously labelled the "systems layer" at the bottom of the left-hand stack (booking, scheduling, finance, compliance, etc.) is actually business model content expressed in business language. It describes how the business operates, not how a system implements it. The systems side sits _alongside_ as a parallel stack, not below. The [[concept-reflective-simulation|reflective simulation (L6)]] is cross-cutting on the right side — see [[#7. Simulation Architecture]].

**Horizontal mappings** connect each level:

| Left | Mapping type | Right |
|---|---|---|
| Ontology | classifies / constrains | System ontological categories |
| BMM General vocabulary | maps to | SMM General vocabulary |
| Business instance | realised by | System instance |
| Operational domains | realised by | System domains |
| Business process patterns | executed as | Operational simulation |

**Rules and constraints** govern the dynamic layers (bottom two pairs on both sides) within a bounded container. Constraint _definitions_ live in the instance layers (structural); constraint _enforcement_ happens at runtime (dynamic). This parallels the [[principle-clinical-governance-first-class|governance traceability chain (A8)]].

![[ontara-diagram-dual-stack-architecture-v6.svg]]

### 2.3 The two meta model distinction ([[principle-two-meta-model-distinction|A4]])

**Business Meta Model (BMM)** — what a service business _is_. 36 `part def`s + 2 `requirement def`s across six concerns (five internal + StakeholderModel at the relational boundary), plus `Foundation::DomainRegistry` sub-package (`DomainIdentity` + `DomainConfiguration`, Session 143). Components classified as General (sector-agnostic) or Tailored (sector-specific). The BMM is structurally complete at the General level as of Session 81. See [[ontara-architecture-business-meta-modelling|Service Business Meta Modelling (v3.1)]], [[ontara-discussion-stakeholder-model-and-bsmm-vocabulary-2026-03-27|StakeholderModel discussion paper]] (Session 76), and [[ontara-discussion-stakeholder-model-detailed-design-2026-03-28|StakeholderModel detailed design]] (Session 78).

**System Meta Model (SMM)** — how a business system _works_. Renamed from "Business System Meta Model" (BSMM) in Session 92 for reduced cognitive friction and better parallel with BMM. The rename is substantially complete across codebase (Session 93), vault reference documents (Session 94), and foundations papers (Session 96); some historical discussion papers and the SysML section name `bsmm-general-vocabulary` (structural identifier) retain the old form.

The dual-stack architecture makes the SMM explicit for the first time as the right-hand stack. The first SMM-side model content was implemented in Session 87: [[ontara-ref-master-register|ArchitecturalSection (B27)]] — 1 `part def`, 20 `part` usages, 3 enums, 1 metadata def — representing the 20 sections of the dual-stack architecture as first-class model citizens.

The **reasoning metamodel** (Stage 7, Sessions 146–158, formally closed Session 159) is a cross-cutting SMM extension (S146-D1) — it extends the SMM with institutionalised reasoning capabilities while preserving [[principle-two-meta-model-distinction|A4]]. The reasoning vocabulary (`ontara-reasoning.ttl`) provides 42 OWL classes, 15 named individuals, 40 object properties, and 10 datatype properties covering reasoning contexts, evidence architecture, constraint hierarchy, heuristic packs, decision mode routing, safety and resilience (STAMP/STPA, FRAM-ready slots), and structured probabilistic reasoning.

The **SMM General vocabulary** is organised into *six capability groups* ([[ontara-ref-master-register|B25]]): Persistence & Data Management, Process Orchestration, Evaluation & Reasoning, Observation & Self-Knowledge, Integration & Communication, Identity & Access — with an **architectural role axis** ([[ontara-ref-master-register|B26]]) as *secondary classification* (structural template, execution primitive, governance instrument, comprehension metadata).

Horizontal mappings between BMM concerns and SMM capability groups are many-to-many ([[ontara-ref-master-register|B12]]). See [[ontara-architecture-clarification-two-meta-models|Two Meta Models Clarification]] and [[ontara-discussion-stakeholder-model-and-bsmm-vocabulary-2026-03-27|StakeholderModel and SMM vocabulary discussion paper]] (Session 76).

The two meta models are connected by explicit horizontal mappings at every tier ([[ontara-ref-master-register|B12]]): General BMM ↔ General SMM, Tailored BMM ↔ Tailored SMM, individual business models ↔ individual system models.

### 2.4 The six concerns of a service business

From [[ontara-architecture-business-meta-modelling|Service Business Meta Modelling (v3.1)]] §2.1 and [[ontara-discussion-stakeholder-model-and-bsmm-vocabulary-2026-03-27|StakeholderModel discussion paper]] (Session 76). Six primary concerns plus Activity Awareness (C6) as the cross-cutting dimension connecting them. Concerns 1–5 describe the internal logic of the business; StakeholderModel (C7) describes the relational boundary.

| Concern | What it covers |
|---|---|
| **ServiceConcept** (C1) | What value is delivered, to whom, and why it is worth paying for |
| **ActivityModel** (C2) | How value is produced and delivered — processes, pathways, workflows |
| **ResourcePlanning** (C3) | What resources and capabilities are required |
| **FinancialPlanning** (C4) | How money flows — revenue, costs, pricing, projections |
| **GovernanceMapping** (C5) | Regulatory requirements, governance, risk, learning mechanisms |
| **StakeholderModel** (C7) | Relationships, partnerships, cooperative delivery, community, participation — how the business connects to the world beyond itself |
| **Activity Awareness** (C6) | Cross-cutting: every unit of activity is visible. The common currency connecting all six concerns |

StakeholderModel (Session 76) addresses a structural gap: the five existing concerns are all inward-facing, describing the business's own machinery. StakeholderModel describes the boundary and the structured relationships across it. Six General elements — StakeholderRelationship, CooperativeArrangement, ReferralPathway, ExternalDependency, CommunityRelationship, ParticipationModel — implemented as `part def`s in Session 81 with full metadata parity (34/34 comprehension annotations, 96 `@WeightedRelationship` annotations across 33 weighted elements) and 20 domain instantiations across GSL (7), Cafe (6), and Paws (7). See [[ontara-discussion-stakeholder-model-detailed-design-2026-03-28|StakeholderModel detailed design]] (Session 78).

### 2.5 Vertical and horizontal mappings

Mappings between layers and between the two meta models are first-class, visible, navigable objects:

- **Vertical:** `ServiceOffering` (L3) → pathways (L2); `ResourceType` (L3) → platform components (L2); `part def` (L5/L4) → `part` usages (L3/L2) — the coverage matrix; `requirement def` (L4) → `constraint def` → evaluator → audit evidence — the satisfy traceability chain

- **Horizontal:** The dual-stack mappings (§2.2) — explicit at every level from ontology through to operational execution

- **Pattern mappings:** Pattern (L4) → DomainInstantiation records — 43 typed `ref` relationships across 22 validated patterns

### 2.6 Meta model subsetting and templating

A meta model defines the full vocabulary. A specific tenant instantiates only a subset. This is not a gap — it is a legitimate instance that uses only the vocabulary it needs. Two approaches exist as an open design question: constrained subset meta models, or template/profiling (openEHR-style). To be resolved empirically ([[concept-non-constraining|J3]]).

---

## 3. The Ontara Console Vision

The Ontara Console is a web-based frontend providing visual access to the layered architecture. It is the primary **developer and architect** tooling surface, built on SvelteKit with Svelte 5 runes, Flowbite Svelte, and Tailwind v4. The Console is distinct from the [[#4. The Ontara Portal|Portal]]: the Console provides introspection into the model and its structure; the Portal provides the operator's runtime interface to a configured and running domain.

### 3.1 What is built

The console currently provides thirteen views, all generated from the SysML model via `gen_model_introspection.py` ([[pattern-metadata-driven-generation|D9]]):

| View | Purpose |
|---|---|
| **Coverage Matrix** | Which meta model concepts are instantiated in which domains. Domain filter. |
| **Package Navigator** | Hierarchical exploration of all ~73 packages with doc blocks, part defs, attributes. |
| **Component Catalogue** | Four-quadrant classification (General/Tailored × BMM/SMM) with domain instantiation status, comprehension layer rendering. |
| **Glossary** | Every defined term with authored + intrinsic comprehension content, weight-aware related concepts with warm-to-cool dot bar. BMM Concern/Layer filtering, search, expand/collapse, cross-links. |
| **Governance** | Traceability from requirements through constraints to satisfaction evidence. |
| **Domain Views** | Per-domain detail pages for [[domain-cafe\|Cafe]], [[domain-suds\|Suds]], [[domain-paws\|Paws]]. |
| **Patterns** | 22 validated patterns with semantic relationships. |
| **Meta-Model** | Structural overview of the meta model layers. |
| **Weighted Relationship Graph** | Interactive 3D WebGL graph (`3d-force-graph` + Three.js) of [[concept-weighted-relationships\|96 weighted relationships]]. Multi-select pill filters, focus-node neighbourhood exploration, custom curved tube rendering, URL state preservation, glossary deep linking (Sessions 90–91). |
| **Architecture** | Two tabs. **Map** (default, Session 92): interactive spatial rendering of the [[concept-dual-stack-architecture\|dual-stack architecture]] with formalism boundary panel, reflective simulation column, horizontal/vertical mapping arrows, and slide-out detail panel with frosted glass. **List** (Session 88): all 20 sections grouped by architectural group. |
| **Ontology** | Session 119. BFO→CCO/IAO→BMM collapsible hierarchy tree. Knowledge Graph Status panel: consistency status, ontology stack composition, 14 object properties table, 96 weighted relationships. Extended Session 158 with Reasoning Vocabulary Explorer (42-class hierarchy in 7 colour-coded functional modules, 15 named individuals, 50 properties with Kind badges, 32 cross-module axioms) and KG Status extensions (8 stat cards including named individuals, datatype properties, SPARQL queries, plus vocabulary module summary). 13th console view. |
| **Navigation** | Global console navigation context ([[ontara-ref-master-register\|I19]], Sessions 132–134). Svelte 5 reactive NavigationStore, semantic breadcrumb trail with page state capture/restore, journey export. 6 routes registered (glossary, ontology, catalogue, governance, coverage, relationships). Cross-cutting infrastructure, not a separate view. |

### 3.2 The dual-canvas vision

The longer-term architectural vision is a **dual-canvas construction kit**:

**Business Canvas.** A drag-and-drop surface for composing a business model from modular pieces — instances of Layer 5 concepts. The BMM defines the palette grammar: what component types are available, what attributes they carry, what connections are valid.

**System Canvas.** A corresponding workspace for technology and process components (Layer 4). Shows what has been assigned, what is missing, what is available.

The two canvases are connected by the [[concept-dual-stack-architecture|dual-stack]] horizontal mappings. The PatternCatalogue acts as a recommendation engine, suggesting applicable patterns when components are placed.

### 3.3 Three levels of completeness tracking

| Level | What it tracks |
|---|---|
| 1 — Instance coverage | For each meta model concept, which domains instantiate it? The coverage matrix. |
| 2 — Pattern coverage | For each validated pattern, which domains exercise it? |
| 3 — Meta model adequacy | Vocabulary gaps — when something cannot be expressed. |

### 3.4 Console development stages

**Stage 4 — Structural navigation and construction.** The [[ontara-stage-4-plan-high-level-2026-03-21|Stage 4 plan]] covers five phases. **Phase 1 formally closed (Session 107).** The weighted relationship graph was built initially as a D3.js force-directed graph (Session 72), then rebuilt as an interactive 3D WebGL visualisation using `3d-force-graph` + Three.js (Session 90) with 14 interactive features added in Session 91. The campus walk workstream (Sessions 84–88) ran in parallel: all 20 dual-stack sections described, implemented in SysML, and built as a console Architecture view. The **visual architecture map** (Session 92) added an interactive spatial rendering as the default Architecture tab. Phase 2 (resident elements and deep linking) planned.

**Stage 5 — Knowledge graph implementation.** Opened Session 100. Three phases completed (Sessions 100–137). See [[#6.8 Knowledge graph implementation status]] for detail.

**Stage 6 — Domain Identity and Governance Convergence.** Opened Session 141. **Block A (domain identity) complete (Sessions 141–144).** Discussion paper (Session 142) with dual-stack split: `DomainIdentity` (BMM, IAO plan_specification) + `DomainConfiguration` (SMM, IAO data_item). A13 promoted to binding T1 (S142-D3). SysML implementation: 2 part defs, 6 enums, 8 domain instances (Session 143). OWL implementation: `ontara-domain.ttl` with 11-file stack HermiT CONSISTENT, 35/35 SPARQL (Session 144). Pipeline extension: `build_domain_registry()`. Block B (governance activation tier — connecting domain identity to governance frameworks) remains future work.

**Stage 7 — Reasoning Metamodel.** Opened Session 148. **All five phases complete (Sessions 148–158). Stage 7 formally closed Session 159.** See [[#10. The Reasoning Metamodel]] for full detail. 24 design decisions confirmed across the stage. The [[domain-ears|Ears]] clinical domain intake (Sessions 161–168, [[ontara-ref-work-items|W-015]]) provided the first domain-specific vocabulary validation — see [[#10.5 Ears clinical domain intake — first vocabulary validation]].

**Stage 8 — Ontara Portal.** Opened Session 175. **All five phases complete (Sessions 175–185). Stage 8 formally closed Session 185.** See [[#4. The Ontara Portal]] for full detail. 11 sessions, within the 19–31 estimate. The portal is the first operator-facing application in the Ontara ecosystem.

**Sessions 121–137 — Governance workstream.** The deontic governance vocabulary — the first hand-authored ontology module outside the BMM namespace. See [[#9. Deontic Governance Architecture]].

Remaining Stage 4 phases:

2. **Cross-Package Navigation** — deep linking, breadcrumbs, typed ref navigation
3. **BMM Concern Group Descriptions** ([[ontara-workflow-emergent-ideas-log|E003]]) — package-level purposive descriptions
4. **Structural Completeness Visualisation** — completeness heatmap, gap identification
5. **Assembly Workspace Prototype** — configuration builder, the seed of the dual-canvas vision

---

## 4. The Ontara Portal

Stage 8 (Sessions 174–185, formally closed Session 185) produced the **Ontara Portal** — a separate SvelteKit application providing the operator-facing platform shell. The portal is distinct from the Console: where the Console provides introspection into the model and its architecture for the developer/architect, the Portal provides the operator's interface to a configured, running domain. The [[ontara-discussion-portal-state-driven-operator-experience-2026-04-08|portal discussion paper]] (Session 174) and [[ontara-stage8-plan-high-level-s.174-portal|Stage 8 plan]] established the conceptual foundations.

### 4.1 The state-driven operator paradigm

The portal's organising principle is **state**. The operator's experience is not task-driven ("Step 1: Configure your profile") or feature-menu-driven ("Here are the tools"). It is state-driven: the platform presents a landscape of stateful entities — modules in lifecycle states, domains with governance levels, simulation runs with results — and the operator understands and acts on the states of the things they have configured.

This connects to three foundational concepts: **state** (the actual condition of an entity — its position in the [[concept-coordinate-framework|coordinate space (A12)]]), **state transition** (a change governed by a lifecycle definition specifying which transitions are legal), and **status** (a projection — a dimensionally-reduced view of richer underlying state, computed for a specific purpose via the [[#8. The Comprehension Architecture|comprehension architecture]]).

### 4.2 Architecture and technology

The portal is a standalone SvelteKit application at `portal/` in the repository, sharing the same technology stack as the Console (SvelteKit + Svelte 5 runes + Flowbite Svelte + Tailwind v4) with SQLite (better-sqlite3) for persistence and bcryptjs for authentication. It uses a warm teal theme distinguished from the Console's cooler palette. The portal runs on port 5174 (Console on 5173).

User authentication (registration, login, logout with session cookies), domain management (CRUD with slug-based routing), and multi-domain switching (sidebar selector) provide the platform shell (Phase 1, Session 175).

### 4.3 Module architecture and lifecycle

The portal organises domain functionality as **modules** — discrete functional units that an operator installs, configures, activates, and manages. The module catalogue (Phase 2, Session 176) provides 10 module definitions across three categories:

- **Business modules** (6): Service Menu, Appointment Booking, Client Records, Staff Rota, Invoicing & Payments, Compliance Tracker — corresponding to BMM concern areas
- **Generative modules** (2): Customer Traffic Generator, Scenario Driver — for simulation input (Phase 4, Sessions 179–181)
- **Analytical modules** (2): Performance Analytics, Comparative Dashboard — for simulation analysis (Phase 4)

Each module instance follows **two intersecting lifecycle state machines** (Phase 2): an **installation lifecycle** (available → installed → configured → active, with uninstall/archive/trash) and an **operational lifecycle** (draft → active → paused → stopped, with soft delete). The dashboard presents the module landscape with inline lifecycle action buttons, module state dots in the sidebar, and trash management.

### 4.4 Domain context and module composition

The **domain context model** (Phase 3, Session 178) structures a domain's business information around the six BMM concerns. When an operator creates a domain, context entries are auto-seeded for each concern. Configuration forms are schema-driven from each module definition's `configSchema`, providing structured data entry that maps to the BMM.

**Module wiring** arises implicitly from shared BMM concern overlap — modules that share a concern tag are connected. The connections panel shows which modules share which concerns, and a coverage bar indicates how well the domain's BMM concerns are covered by installed modules.

**Composition guidance** (Phase 3) provides a preview modal with per-module hints and lifecycle impact warnings when module changes could affect connected modules' operational states.

### 4.5 The epistemic dimension

Phase 4 (Sessions 179–181) introduced the **epistemic dimension** — the ability to distinguish between production data and exploratory variants. Three epistemic characters (production, hypothesis, projection) are settable as a property on any domain, not as a lifecycle state (design decision S179-D1). Operators can duplicate a production domain to create a hypothesis variant, modify it freely, run simulations against it, and compare results — without affecting the production configuration.

### 4.6 Simulation

The portal provides a prototype simulation capability (Phase 4): batch event generation using configurable parameters (event count, time span), two fidelity levels (simplified with uniform distributions, realistic with Poisson arrivals and log-normal durations), a simulation run list with status tracking, and a dashboard card showing recent results. The Comparative Dashboard module aggregates metrics across simulation runs and presents health scores, comparison tables, and per-module analysis.

This is the portal's prototype expression of the [[concept-operational-simulation|operational simulation (L5)]] and [[concept-reflective-simulation|reflective simulation (L6)]] concepts from the [[#7. Simulation Architecture|simulation architecture]]. The portal demonstrates the _shape_ of what these concepts become in a user-facing interface — stateful simulation runs with epistemic character, comparative analysis, and health scoring — while the full architectural vision (Temporal workflows, coordinate space snapshots, goal-seeking computation) remains future engineering work.

### 4.7 Progressive governance

Phase 5 (Sessions 182–185) implemented **progressive governance** — a three-level system where governance constraints can operate at increasing levels of enforcement:

- **Exploratory:** Constraints are visible but not evaluated. The operator can see what governance rules exist without being bound by them. For experimentation.
- **Advisory:** Constraints are evaluated and results displayed, but violations do not block actions. The operator sees warnings. For learning.
- **Enforced:** Constraint violations block lifecycle transitions. Hard constraints (8) must pass for activation and promotion. Soft constraints (6) and graded rules (6) produce warnings. For production.

The constraint model comprises 20 typed constraints (8 hard, 6 soft, 6 graded), each with a named evaluator function in a typed evaluator registry. This maps directly onto the reasoning metamodel's three-way constraint distinction (S146-D8/S147-D3): HardConstraints as NormativeRegion boundaries, SoftConstraints as cost surfaces, GradedRules as truth-value surfaces.

### 4.8 Promotion and demotion

The **promotion path** (Phase 5) allows a domain to be promoted from hypothesis to production status via a 5-prerequisite wizard: governance level must be enforced, all hard constraints must pass, at least one module must be active, no modules may be in draft state, and the domain must have a description. Promotion sets the epistemic character to production and applies visual treatment (teal border, PRODUCTION badge, background tint, filter toggle on the domain list).

**Demotion** allows a production domain to be reverted to hypothesis status with a confirmation dialog. **Lifecycle governance guards** (`checkActivationGovernance` in `guards.ts`) gate draft→active transitions: in exploratory mode, no checks; in advisory mode, warnings are shown but not blocking; in enforced mode, hard constraint failures prevent activation.

### 4.9 Visual treatment

The portal uses category-aware visual treatment: purple accents for generative modules, blue for analytical, teal for business modules. Production domains receive a distinctive visual treatment (teal border and badge). A known observation (OW-30) notes that light mode presents visual monotony — white cards on white backgrounds — which is a candidate for a future design polish pass.

### 4.10 Architectural significance

The portal represents a significant shift in the Ontara project's trajectory: the first time the architecture has been expressed as an operator-facing experience rather than solely as internal tooling and model infrastructure. Key architectural connections:

- The module catalogue exercises [[concept-multi-tenancy|A13]] — modules are platform capability that tenants instantiate
- The two intersecting lifecycle state machines are a prototype expression of the state machine paradigm identified in the [[ontara-ref-modelling-paradigms|Modelling Paradigm Reference]] (Session 173) at platform level
- Progressive governance connects the portal to the [[#9. Deontic Governance Architecture|deontic governance architecture]] — the three governance levels map to the three-way constraint distinction
- The domain context model is structured around the six BMM concerns, exercising the BMM as an organising principle for user-facing data
- Simulation and epistemic character are the portal's prototype of [[concept-operational-simulation|L5]], [[concept-reflective-simulation|L6]], and [[concept-coordinate-space-snapshots|L8]] (coordinate space snapshots with epistemic status)

Stage 8 was deliberately a **prototyping** stage — the portal uses SQLite and simple data models rather than the full ontological stack, and was built rapidly (11 sessions vs 19–31 estimate) using the two-artifact Claude Code workflow (vault plan + disposable instruction set). The architectural value lies in proving the _shape_ of the operator experience, not in production-readiness.

---

## 5. The Generation Pipeline

The generation pipeline is the mechanism by which the model produces the execution layer ([[principle-separation-representation-execution|A1]], [[principle-model-generates-everything|A3]]).

### 5.1 Current generators

Eight operational generators produce artefacts from the SysML model, plus five knowledge graph tooling scripts. All SysML-reading generators share `sysml_parser.py` (extracted Session 104) as a common parser module.

| Generator | Output |
|---|---|
| `gen_model_introspection.py` | `model-introspection.json` — the console's data source. Extracts all metadata annotations including `@CatalogueTag`, `@UserFacing`, `@PurposiveDescription`, `@Comprehension`, `@WeightedRelationship`, `@ArchitecturalLocation`, `@BfoType` (added Session 103). Extended Session 88 with `architecturalSections` key (20 entries). |
| `gen_owl_pipeline.py` | SysML → OWL/Turtle via declarative mapping rules (`ontology/config/mapping-rules.yaml`). Five outputs: `ontara-bmm.ttl` (34 OWL classes), `ontara-bmm-properties.ttl` (14 object properties), `ontara-bmm-weights.ttl` (96 reified weighted relationship individuals, 702 triples), `ontara-correspondence.ttl` (1,378 triples), `mapping-ir.json` (classified elements). Sessions 105–117. |
| `gen_concept_graph.py` | 6 Mermaid views + Obsidian concept graph |
| `gen_package_hierarchy.py` | Package structure visualisation |
| `gen_system_manifest.py` | `system-manifest.json` |
| `gen_constraint_evaluator.py` | `constraint-evaluators.ts`, `constraint-specs.ts` |
| `gen_decision_table_evaluator.py` | `decision-table-evaluators.ts` |
| `projection_engine.py` | Financial scenario comparison |

Knowledge graph tooling:

| Script | Purpose |
|---|---|
| `setup_graphdb.py` | GraphDB repository creation and ontology stack loading (BFO 2020, CCO, IAO). Session 101. |
| `validate_kg.py` | SPARQL validation suite — 66 queries in 12 groups (structural, correspondence, inference, graph-level, governance, governance-MVP, governance-vocabulary, governance-extended, domain, domain-extended, reasoning, ears-instances). Sessions 106/126/131/136/144/152/168. |
| `reason_kg.py` | Robot + HermiT full OWL 2 DL consistency checking. `--save-summary` for console JSON with dynamic counts and full `reasoningVocabulary` section (class hierarchy, named individuals, properties, cross-module axioms by functional module), `--test-violation` for deliberate misclassification testing. 13-file ontology stack. Session 115; extended Sessions 152/158. |
| `diff_kg.py` | Round-trip diff engine — compares pipeline-generated OWL against live GraphDB store at semantic unit level (288 semantic units, 4 unit types). Dual output (JSON + stdout), authority-zone-aware. Session 137. |
| `kg_utils.py` | Shared KG utilities — GraphDB connection, SPARQL execution, IRI shortening (including `ontara-rsn:`, `ontara-dom:`, `ontara-dom-ax:`, `prov:`, `ears-rsn:` prefixes). Used by `validate_kg.py` and `diff_kg.py`. Session 137; extended Sessions 152/168. |

### 5.2 The process specification pipeline

The [[ontara-discussion-paper-process-specification-layer-2026-03-27|process specification layer]] describes the full pipeline from static business model to running systems. The pipeline crosses from the left stack (business model) to the right stack (business system model) at the compilation step:

Steps 1–7 (intake, classification, BMM population, instantiation, relation binding, process identification, process sketch generation) are business model work on the left side. Steps 8–10 (compilation to Temporal DSL YAML, code generation, deployment) produce system artefacts on the right side. Process archetypes and patterns are business model content — they describe how the business operates; the compiled output becomes part of the [[concept-operational-simulation|operational simulation (L5)]].

### 5.3 Design principles

The pipeline follows a two-phase architecture (designed, partially implemented): Phase 1 generators are model-aware and framework-agnostic, producing domain artefacts + manifest. Phase 2 generators are model-agnostic and framework-aware, producing integration wiring. The four-layer generated code architecture (SysML model → domain artefacts → integration glue → application code) ensures generated layers are freely regenerable while hand-written application code is never overwritten. See [[ontara-discussion-model-two-phase-generation-pipeline-2026-03-13|Two-Phase Generation Pipeline]].

---

## 6. Ontological Grounding

### 6.1 BFO as upper ontology (mandatory)

[[concept-ontology-stack|BFO]] (Basic Formal Ontology, ISO/IEC 21838-2:2021) is the **mandatory** upper ontology for Ontara. Its continuant/occurrent/spatiotemporal framework is structurally identical to the [[concept-coordinate-framework|coordinate framework (A12)]]'s spacetime concept. BFO's "history" (sum of processes in a spatiotemporal region) = coordinate framework's "trajectory". BFO category determines which mathematical operations are meaningful on each axis.

For a [[concept-multi-tenancy|multi-tenant (A13)]], regulated-services platform, a rigorous upper ontology is not optional — it is what ensures that entities across different tenants and domains are categorised consistently and that cross-domain reasoning is semantically grounded.

### 6.2 Mid-level domain ontologies

Between BFO and the meta model vocabularies sit the mid-level ontologies, all BFO-aligned:

- **IAO** (Information Artifact Ontology) — for information entities across all domains
- **CCO** (Common Core Ontologies) — for common concepts
- **PROV-O** (W3C Provenance Ontology, core subset) — for provenance traceability across all domains. Added at platform level (Session 148, S146-D2; imported Session 150). Dual subclassing pattern (S147-D4): reasoning classes inherit from both BFO and PROV-O parents
- **OGMS** (Ontology for General Medical Science) — for clinical tenants
- **OCE** (Ontology of Commercial Enterprises) — for commercial/business entities
- **GSSO** (Gender, Sex, and Sexual Orientation ontology) — for [[domain-gsl|GSL]]'s domain
- **OBI** (Ontology for Biomedical Investigations) — for clinical investigations

These give Ontara's different tenant types their domain-specific semantic grounding. Healthcare tenants use OGMS+IAO; commercial tenants use OCE. Both trace upward to BFO. The BMM is recognised as a de facto BFO-aligned service business mid-level ontology.

### 6.3 OWL 2 DL as ontological formalism (mandatory)

OWL 2 DL is the **mandatory** formalism for Ontara's ontological layers. It provides capabilities that SysML v2 cannot:

- Open-world reasoning and automatic classification
- Consistency checking against BFO axioms
- Importing existing OBO Foundry ontologies directly (BFO, OGMS, IAO, OBI, GSSO already exist as OWL 2 artefacts)
- Multi-axis compositional classification — this _is_ [[concept-coordinate-framework|A12]]
- SPARQL semantic querying with full semantic awareness
- Formal TBox/ABox separation mapping naturally to the meta model / instance distinction ([[principle-two-meta-model-distinction|A4]])

SysML v2 cannot do these things. It is a system design language, not an ontology language. Each formalism does what it is best at. The ontological layers are represented in OWL 2 DL; the meta model and instance layers remain in SysML v2.

### 6.4 The knowledge graph as canonical store ([[concept-knowledge-graph|B22]])

A directional commitment: the [[concept-knowledge-graph|knowledge graph]] (OWL 2 DL in a triple store) can eventually become the **canonical store**, with SysML v2 as an engineering **projection** — provided round-trip translation preserves all aspects of the model without degradation.

This does not violate [[principle-separation-representation-execution|A1]] or [[principle-model-generates-everything|A3]]. The representation remains primary; it is simply that the primary representation is the knowledge graph rather than the SysML files. SysML v2 becomes the engineering _view_ onto the canonical model.

The condition is explicit: **round-trip fidelity**. If translating from knowledge graph to SysML and back degrades any aspect of the model, the knowledge graph is not yet ready to be canonical. This is a directional commitment, not a binding decision.

The [[ontara-discussion-knowledge-graph-architecture-2026-04-01|knowledge graph architecture]] (Session 97) elaborated this commitment into a comprehensive design with 9 binding decisions, 2 directional, and 2 deferred. Key architectural elements: a **three-stratum graph** ([[ontara-workflow-emergent-ideas-log|E019]]) — metamodel graph (SysML traceability), domain graph (BFO-grounded semantics — the canonical layer), correspondence graph (explicit mapping records with provenance); **authority zones** ([[ontara-workflow-emergent-ideas-log|E020]]) — SysML-authoritative for structure, OWL-authoritative for ontological semantics, shared-constrained for labels/definitions; and a **five-stage Python pipeline** — parse SysML → project to mapping IR → map to OWL/RDF → reason/validate → round-trip diff. IRI scheme: `https://ontara.dev/ontology/` for vocabulary, `https://ontara.dev/data/` for instances.

### 6.5 The mapping ontology ([[ontara-ref-master-register|B24]])

A formal [[ontara-ref-master-register|mapping ontology (B24)]] expressed in OWL declares how SysML v2 elements correspond to ontological classes: SysML blocks/parts ↔ OWL classes; SysML relationships ↔ OWL object properties; SysML value types ↔ OWL datatype properties. This is now concretely realised as the **correspondence graph** — the third stratum of the [[ontara-discussion-knowledge-graph-architecture-2026-04-01|three-stratum graph architecture (E019)]]. The `gen_owl_pipeline.py` generator (Sessions 105–117) produces `ontara-correspondence.ttl` containing 1,378 triples with 34 class mapping records, 14 property mapping records, and 96 weighted relationship mapping records, each linking a SysML element to its OWL counterpart with provenance metadata.

### 6.6 Persistence

The ontological layers persist in **GraphDB Free 10.x** (local, port 7200), selected as the primary triple store (Session 97, operational Session 101). GraphDB provides built-in OWL-Horst (Optimized) reasoning, enabling transitive inference chains without external reasoners. Robot v1.9.8 wrapping HermiT provides full OWL 2 DL consistency checking (operational Session 115). Named graphs provide the infrastructure for [[concept-coordinate-space-snapshots|coordinate space snapshots (L8)]]. Adding a new axis to the coordinate space is adding triples with a new predicate — no schema migration required.

### 6.7 @BfoType annotations

All 34 BMM elements now carry `@BfoType` annotations (Session 98 design, Session 99 applied via Claude Code) declaring their BFO 2020 category and mid-level ontology parent. The `@BfoType` metadata def (in `Foundation::MetadataLibrary`) has three String attributes: `bfoCategory` (the BFO 2020 class), `midLevelParent` (the CCO/IAO/OGMS class), and `bfoJustification` (rationale for the classification). Six mapping principles govern the classification (see [[ontara-discussion-bfo-type-mapping-2026-04-01|@BfoType mapping discussion paper]]). The annotations provide the SysML-side input to the OWL pipeline: `gen_owl_pipeline.py` reads `@BfoType` to generate correctly parented OWL classes in the domain graph.

### 6.8 Knowledge graph implementation status

Stage 5 implemented the knowledge graph architecture across three phases (Sessions 100–137):

- **Phase 1 — Foundation (Sessions 100–107, formally closed Session 107).** GraphDB Free operational with BFO/CCO/IAO stack. BMM ontology pipeline-generated via `gen_owl_pipeline.py` with declarative mapping rules. Shared `sysml_parser.py` extracted. SPARQL validation suite passing 10/10. All 34 BMM classes confirmed as BFO:Continuant via full transitive inference chain.
- **Phase 2 — Ontological Enrichment (Sessions 111–120, formally closed Session 120).** [[ontara-stage-5-plan-s.111-phase2|Ten-step plan]] with 5 design decisions. Disjointness axioms for six BMM concern groups in hand-authored `ontara-bmm-axioms.ttl`. 14 object properties pipeline-generated from SysML typed `ref` attributes with domain, range, and functional characteristics. 9 qualified cardinality restrictions. Robot v1.9.8 wrapping HermiT for full OWL 2 DL consistency checking (`scripts/reason_kg.py`). 96 reified weighted relationship individuals (702 triples). Console integration: BFO category badges in Glossary and Component Catalogue (Session 118), ontological hierarchy view and KG Status panel (Session 119). 9/10 success criteria met.
- **Phase 3 — Consolidation and Round-Trip (Sessions 135–137, formally closed Session 137).** See [[#6.10 Stage 5 Phase 3 — consolidation and round-trip foundation]].
- **Current scale:** 13-file ontology stack (BFO + IAO + CCO + BMM classes + BMM axioms + BMM properties + BMM weights + governance vocabulary + CQC Regulation 12 individuals + domain identity vocabulary + PROV-O core subset + reasoning vocabulary + Ears reasoning instances). 66-query SPARQL validation suite in 12 groups. Three layers of automated quality assurance: SPARQL validation, OWL 2 DL reasoning (HermiT), round-trip diff (288 semantic units). The `validate_kg.py --load` command loads all 11 non-import files into GraphDB for validation (fix applied Session 157, resolving a gap latent since Session 126).

Phase 4 (live SPARQL — console queries against GraphDB at runtime) and Phase 5 ([[domain-ears|Ears]] demonstrator — OGMS adoption) are planned future work.

### 6.9 The governance ontology module

The governance workstream (Sessions 121–137) produced the first hand-authored ontology module outside the BMM namespace: the **deontic governance vocabulary** at `ontology/governance/ontara-governance.ttl`. This module uses a separate IRI namespace (`https://ontara.dev/ontology/governance/`, prefix `ontara-gov:`) and is [[concept-authority-zones|OWL-authoritative (B29)]] for governance class definitions and axioms.

The module contains 19 classes (rooted in `DeonticDirective` and `NormativeInstrument`, both grounded in IAO), 6 enumeration classes, 24 named individuals (enumeration values), 23 object properties (20 original + 3 extended in Session 136), and 17 data properties (16 original + 1 extended in Session 136). Key axioms include 3 disjointness groups, 2 covering axioms, 1 existential restriction (every directive `derivesFrom` at least one instrument), and 5 cardinality restrictions.

The CQC Governance MVP (Sessions 130–131) expanded the initial test individuals into a comprehensive formalisation of CQC Regulation 12 (Safe Care and Treatment): 21 individuals in `ontology/governance/cqc-reg12-individuals.ttl`. See [[#9. Deontic Governance Architecture]] for full detail.

**Governance–reasoning alignment (Session 151):** The reasoning metamodel declares `ontara-gov:Obligation` and `ontara-gov:Prohibition` as subclasses of `ontara-rsn:HardConstraint`. This means governance obligations are hard constraints in the reasoning metamodel's terms — they define NormativeRegion boundaries in the [[concept-coordinate-framework|coordinate space (A12)]]. The dependency direction is unidirectional: `ontara-rsn:` → `ontara-gov:` (reasoning knows about governance). The governance module remains independent per [[concept-authority-zones|B29]].

### 6.10 Stage 5 Phase 3 — consolidation and round-trip foundation

**Phase 3 (Sessions 135–137, formally closed Session 137).** The [[ontara-stage-5-plan-s.135-phase3|Phase 3 plan]] covered two blocks: Block A (consolidation) and Block B (round-trip foundation). Five design decisions (S135-D1 to D5).

**Block A — Consolidation (Sessions 135–136).** Live reasoning summary generated via `reason_kg.py --save-summary` and deployed to the console's Ontology view KG Status panel. SPARQL validation suite extended from 23 to 29 queries in 8 groups, covering the governance vocabulary extensions. Governance vocabulary itself extended with 3 new object properties (`decomposesInto`, `crossReferencesLegislation`, `amendsObligation`) and 1 new data property (`decompositionLevel`).

**Block B — Round-trip foundation (Sessions 136–137).** Round-trip diff engine (`scripts/diff_kg.py`) designed and implemented. The engine compares pipeline-generated OWL against the live GraphDB store at semantic unit level, decomposing the comparison into four unit types (class identity, class axiom, object property, weighted relationship). 288 semantic units compared, 0 discrepancies (CLEAN). Dual output: JSON report (`generated/ontara/diff-report.json`) for programmatic consumption and human-readable stdout summary. Authority-zone-aware: OWL-authoritative content (governance vocabulary) is excluded from comparison. Shared KG utilities module (`scripts/kg_utils.py`) extracted for GraphDB connection, SPARQL execution, and IRI shortening — used by both `validate_kg.py` and `diff_kg.py`.

Phase 3 established **three layers of automated quality assurance**: SPARQL validation (29 queries checking structural and semantic correctness), OWL 2 DL reasoning (HermiT checking logical consistency), and round-trip diff (288 semantic units verifying pipeline-to-store fidelity). All 7 success criteria met. 3 sessions, within the 5–7 session estimate.

### 6.11 Domain identity vocabulary

The domain identity OWL module (`ontology/domain/ontara-domain.ttl`, Session 144) implements the dual-stack domain identity design from [[ontara-discussion-domain-identity-dual-stack-2026-04-05|Session 142]]. The module uses namespace `ontara-dom:` and contains 2 classes (`DomainIdentity`, `DomainConfiguration`), 6 enumeration classes (`RegulatoryTier`, `DomainPurpose`, `Jurisdiction`, `RegulatedActivity`, `OrganisationalForm`, `BmmVocabularyScope`), 8+8 properties (object + datatype), and 8 individuals representing the four demonstrator domains plus GSL. The pipeline extension (`build_domain_registry()` in `gen_owl_pipeline.py`) extracts domain data from SysML for knowledge graph loading.

### 6.12 The reasoning metamodel vocabulary

The reasoning metamodel OWL module (`ontology/reasoning/ontara-reasoning.ttl`, Sessions 150–157) implements the reasoning architecture designed across [[ontara-discussion-institutionalised-reasoning-2026-04-05|Session 146]] and [[ontara-discussion-coordinate-framework-revisited-2026-04-05|Session 147]]. The module uses namespace `ontara-rsn:` and contains 42 classes, 15 named individuals, 40 object properties, and 10 datatype properties, with 7 PROV-O dual-subclassed classes and 2 cross-module governance alignment axioms. PROV-O core subset (`ontology/imports/prov-core.ttl`, 73 triples) provides the provenance foundation. The vocabulary was built across four implementation phases:

- **Phase 1 (Sessions 150–152):** Foundation — 26 classes including 3 dual-subclassed foundation classes, 14 core reasoning classes, evidence architecture (SEPIO pattern), structured probabilistic types. 3 named individuals (interpretive frames). 15 object properties, 4 datatype properties.
- **Phase 2 (Session 155):** Depth — heuristic packs (6 typed families: goal-ordering, resource, risk, diagnostic, coordination, governance), HeuristicPack container, decision mode routing (4 Cynefin-mapped DecisionMode named individuals), constraint satisfaction structures (CombinationAlgebra with 4 named individuals: MinPlusSemiring, MaxTimesSemiring, FuzzyMinMax, PSLConvexOptimisation). +8 classes, +8 named individuals, +9 object properties, +3 datatype properties.
- **Phase 3 (Session 157):** Safety and resilience — STAMP/STPA control structures (SafetyConstraint, ControlStructure, ControlLoop, ControlAction, UnsafeControlAction with 4 STPA type named individuals), FRAM-ready slots (FRAMFunction with 6 coupling-aspect properties, VariabilityProfile). Safety–governance alignment properties. +8 classes, +4 named individuals, +16 object properties, +3 datatype properties.
- **Phase 4 (Session 158):** Console integration — `reason_kg.py` extended with `extract_reasoning_vocabulary()` for dynamic vocabulary extraction via rdflib. Reasoning Vocabulary Explorer in the Ontology console view (7 colour-coded functional modules, class hierarchy, named individuals, properties with Kind badges, 32 cross-module axioms). KG Status extensions (8 stat cards including named individuals, datatype properties, SPARQL queries, plus vocabulary module summary).

See [[#10. The Reasoning Metamodel]] for architectural detail.

### 6.13 Ears reasoning instances

The first domain-specific instance data in the ontology stack: `ontology/reasoning/ears-reasoning-instances.ttl` (Session 166, namespace `ears-rsn:`). Contains ~83 named individuals exercising the reasoning vocabulary with clinical content from the [[domain-ears|Ears]] (Community Ear Care) domain. Five clinical reasoning exercises instantiated: pre-appointment triage, contraindication check (the critical three-way constraint test), procedure selection (HeuristicPack exercise), post-procedure assessment, and Mental Capacity Act capacity assessment (reasoning–governance intersection). Additionally 3 STAMP/STPA safety instances, 3 ReasoningAgent individuals, and 6 KnowledgeSource individuals.

25 of the 42 reasoning classes were exercised at instance level. Of the 17 not exercised, 7 are abstract parent classes, 4 are structured probabilistic types (not relevant to Ears), and 6 are heuristic subtypes or FRAM structures awaiting cross-domain testing. HermiT confirmed CONSISTENT on the 13-file stack (~8 min runtime, 1200s timeout). 66/66 SPARQL queries passed including 10 new Ears Instance queries (Q57–Q66). See [[#10.5 Ears clinical domain intake — first vocabulary validation]].

---

## 7. Simulation Architecture

Session 73 produced a conceptually designed simulation architecture comprising five interrelated concepts. The [[#4. The Ontara Portal|Ontara Portal]] (Stage 8, Sessions 174–185) provides the first prototype expression of these concepts in a user-facing interface.

### 7.1 The operational simulation ([[concept-operational-simulation|L5]])

The [[concept-operational-simulation|operational simulation]] is the SMM made live: a continuously running simulation of the business per tenant, coordinated by Temporal workflows, state management, and event streams. Human actors and connected applications are **participants** — the workflow assigns tasks, waits for completion, and receives outcomes. The human is inside the loop.

All execution maps upward through SysML to the ontology layer, preserving unified semantic coherence. The system can say not just "workflow X completed step 3" but "the resource allocation process for room assignment in a Standard Groom service completed successfully" — because the model lineage is preserved end to end. This is [[principle-model-generates-everything|A3]] made operational at runtime.

**Portal prototype (Stage 8):** The portal's module lifecycle — where operators install, configure, and activate business modules that generate events and maintain state — is a prototype of L5. The simulation infrastructure (batch event generation, run management, dashboard metrics) demonstrates the _shape_ of what the operational simulation becomes in a user-facing context, though the full architecture (Temporal workflow coordination, real-time event streams, knowledge graph persistence) remains future engineering work.

### 7.2 The reflective simulation ([[concept-reflective-simulation|L6]])

The [[concept-reflective-simulation|reflective simulation]] is a cross-cutting meta-knowledge capability on the right side of the [[concept-dual-stack-architecture|dual stack]]. It reads from every layer of the architecture — the knowledge graph (to know what things _are_), the instance layers (to know what exists), the operational simulation (to know what is happening now), the rule/constraint layer (to know the boundaries), and the terminology layer (for clinical tenants). It writes guidance and insight to the business operator, and derived knowledge (trajectories, anomaly records, projections) back to the knowledge graph as persistent self-knowledge.

The reflective simulation does **not** exercise directive control. It is advisory, not authoritative — consistent with [[principle-deterministic-over-probabilistic|A6]].

**Portal prototype (Stage 8):** The portal's Comparative Dashboard, health scoring, and governance constraint evaluation are prototype expressions of L6. The dashboard reads from module state, simulation results, and governance constraints to produce evaluative guidance — the _shape_ of what the reflective simulation provides to the operator, though without the full ontological grounding and knowledge graph persistence of the architectural vision.

### 7.3 Valence ([[concept-valence|L7]])

[[concept-valence|Valence]] is the system's representation of what the business operator considers good vs bad performance. It transforms the reflective simulation from descriptive ("utilisation is at 95%") to evaluative ("utilisation is at 95%, which is in the danger zone for service quality given your stated priorities"). Valence is declared by the operator as goal states and desirability criteria. The representation mechanism is an open design question.

### 7.4 Coordinate space snapshots ([[concept-coordinate-space-snapshots|L8]])

The reflective simulation persists and operates over multiple states of the business model as snapshots in the [[concept-coordinate-framework|coordinate space (A12)]], differentiated by [[concept-epistemic-modality|epistemic status (B17)]]:

| Snapshot type | Epistemic status | What it represents |
|---|---|---|
| **Current state** | Actual | Live, continuously updated by the operational simulation |
| **Historical states** | Past-actual | Timestamped past snapshots enabling trajectory computation |
| **Goal states** | Intentional | Declared targets — the operator's definition of desirable. Valence anchors |
| **Hypothetical states** | Counterfactual | "What if" snapshots under altered conditions |
| **Projected states** | Extrapolated | Best estimate of where the business is heading given current trajectories |

All five types are points or trajectories in the **same coordinate space**. Snapshots persist in the knowledge graph as named graphs tagged with epistemic status, timestamp, and provenance. The epistemic modality was reconciled in Session 147 as three orthogonal dimensions (provenance modality × functional purpose × evidential confidence) — see [[#11. Foundational Architecture]].

**Portal prototype (Stage 8):** The portal's epistemic dimension (production/hypothesis/projection as a settable property on domains, S179-D1) is a simplified expression of L8. Domain duplication for hypothesis variants, simulation runs producing projected metrics, and the Comparative Dashboard comparing across epistemic characters demonstrate the _user interaction pattern_ for coordinate space snapshots, though the portal uses SQLite rather than named graphs in the knowledge graph. The observation that counterfactual analysis ("what would have happened if X?") is a distinct epistemic mode not covered by the prototype's three-character taxonomy ([[ontara-workflow-emergent-ideas-log|E030]]) points to future enrichment.

### 7.5 Goal-seeking computation ([[concept-goal-seeking-computation|L9]])

Given a current state and a goal state (both [[concept-coordinate-space-snapshots|coordinate space snapshots]]), search for an action sequence — drawn from the process archetype library (the [[ontara-discussion-paper-process-specification-layer-2026-03-27|process specification layer]]) — that moves the business from one to the other. The rule and constraint layer governs which paths are permissible; the reflective simulation evaluates which are preferable via [[concept-valence|valence]]. Constraint satisfaction over the coordinate space — where CLP(FD) and the constraint layer intersect with the reflective simulation. The [[ontara-discussion-coordinate-framework-revisited-2026-04-05|coordinate framework revisited paper (Session 147)]] reinterpreted L9 as pathfinding through constrained coordinate space: HardConstraints define impassable boundaries, SoftConstraints define cost surfaces, and GradedRules define truth-value surfaces.

---

## 8. The Comprehension Architecture

The comprehension architecture is the major achievement of Sessions 45–58. It addresses the question: how does the system know what it contains, why it is structured that way, and how to explain itself?

### 8.1 The intrinsic self-knowledge principle ([[principle-intrinsic-self-knowledge|A10]])

The system's explanations are dynamically computed from live model state, not stored as static text. Self-knowledge is not painted on or bolted on — it is intrinsic.

The dividing-line test: if the model changes and no human edits a description, does the explanation become wrong? If yes, that content must be intrinsic.

The [[concept-dual-stack-architecture|dual-stack architecture]] extends A10 from design-time to runtime: the [[concept-reflective-simulation|reflective simulation (L6)]] is A10 applied to the running business, not just to the model.

### 8.2 The three-register model

| Register | Content | Source | Status |
|---|---|---|---|
| **Register 1: Authored** | Human-written purposive descriptions — why an element exists and what it does | `@PurposiveDescription` metadata in SysML | Complete. 34/34 BMM coverage + 20/20 architectural sections. All 34 BMM elements also carry `@BfoType` annotations (Session 99). |
| **Register 2: Structural** | Facts the model already knows — type, relationships, containment, patterns, domain instantiations | Dynamically derived via `@Comprehension` metadata traversal schema | Complete. 34/34 BMM coverage. Generator traversal discovery engine operational. |
| **Register 2+: Inferential** | Derived explanations that go beyond what any single element states — analogies, gap analysis, impact propagation | Computed from [[concept-weighted-relationships\|weighted relationships]], reasoning metamodel evidence architecture | Converged with reasoning metamodel (S147-D7): Register 2+ and the SEPIO+PROV-O evidence architecture are the same underlying pattern. The reasoning vocabulary (`ontara-reasoning.ttl`) provides the OWL infrastructure for Claims, EvidenceLines, and ConfidenceAssessments |

### 8.3 Weighted relationships ([[concept-weighted-relationships|B14]])

96 `@WeightedRelationship` annotations across 33 weighted elements. AuditEvidenceRecord is a pure receiver with zero outgoing weights. The StakeholderModel implementation (Session 81) added 17 new weighted relationships across 6 new elements, bringing coverage from 79/27 to 96/33.

Relationships are directional and non-commutative: the weight on A → B answers "if A changes, how much does B need reassessment?" The reverse B → A is independently assessed. Weights do not net off, average, or combine. Five inductively established heuristics (H1–H5) govern weight assignment. See [[ontara-ref-weighted-relationship-heuristics-and-config|heuristics and configuration reference]] and [[ontara-ref-weighted-relationship-directionality-definition|directionality definition]].

The weight model supports three interpretive frames: costs/preferences, fuzzy human judgements, and probabilities. These three frames are now formalised in the reasoning metamodel as named individuals (`ProbabilityFrame`, `FuzzyMembershipFrame`, `PreferenceWeightFrame`) — stable since their first identification in Session 46.

### 8.4 The unity principle ([[principle-unity-principle|A11]])

One weighted relationship model informs comprehension, reasoning, simulation, governance, and assembly guidance. No separate, disconnected knowledge structures. The factors bearing on explanatory descriptions must be the same factors bearing on projections, question-answering, prediction, risk assessment, simulation, and governance activities. The same [[concept-coordinate-framework|coordinate space]], [[concept-weighted-relationships|weight model]], and [[concept-valence|valence]] definitions inform all capabilities. **Empirically validated by the comprehension–reasoning convergence** (S147-D7): the Session 147 coordinate framework revisited paper confirmed that Register 2+ and the evidence architecture are the same pattern, vindicating A11's original claim.

### 8.5 Reasoning formalisms (M7)

Three formalisms are identified as relevant to Ontara's weighted reasoning needs: semiring soft-constraints (optimisation/trade-offs), fuzzy MCDM (human judgements/stakeholder preferences), and Probabilistic Soft Logic (graded business rules with truth values in [0,1]). Clinical decision support additionally uses Bayesian reasoning — now given first-class architectural status through the [[principle-deterministic-over-probabilistic|A6]] reformulation (Session 148, T1 amendment) and the structured probabilistic reasoning types in `ontara-reasoning.ttl` (BayesianUpdater, RiskCalculator, PrognosticModel, PredictiveAnalytics). The reasoning metamodel (Stage 7) provides the OWL vocabulary for these formalisms; runtime engines are deployment-time concerns per [[concept-authority-zones|B29]]. See [[ontara-discussion-intrinsic-self-knowledge-v2-2026-03-20|Intrinsic Self-Knowledge discussion]] §4.4 and [[ontara-discussion-institutionalised-reasoning-2026-04-05|Institutionalised Reasoning (Session 146)]] §11.

### 8.6 Two registers of self-knowledge: business and platform

The comprehension architecture was conceived and built around the BMM — the 34 business meta model elements describing their own structure, relationships, and purpose. This is _business-level_ self-knowledge: the system explaining what a service business is and how its concepts relate.

The [[ontara-ref-master-register|architectural section]] implementation (Session 87, [[ontara-ref-master-register|B27]]) extends self-knowledge into a second register: _platform-level_ architectural self-knowledge. The model now carries explicit, structured knowledge of its own engineering organisation — the 20 sections of the [[concept-dual-stack-architecture|dual-stack architecture]], their formalisms, persistence mechanisms, interfaces, and implementation status. This is the system describing _how it is built_, not _what it does for its users_.

The end user of a deployed Ontara tenant never sees or needs to know about architectural sections. They see service offerings, pricing rules, stakeholder relationships, guidance from the [[concept-reflective-simulation|reflective simulation]]. The architectural sections are invisible infrastructure from their perspective. This content serves the architect and platform developer.

This distinction sharpens the scope of [[principle-self-describing-system|A2]] and [[principle-intrinsic-self-knowledge|A10]]. The two registers of self-knowledge are appropriately classified under [[principle-two-meta-model-distinction|A4]] (two meta model distinction): business-level self-knowledge is BMM content; platform-level self-knowledge is SMM content.

---

## 9. Deontic Governance Architecture

Sessions 121–137 established a major architectural workstream: a deontic logic-grounded governance vocabulary and compliance framework, exercised with production-quality regulatory content. This is the architectural infrastructure for making governance requirements machine-readable, semantically rich, and computationally active within the [[concept-knowledge-graph|knowledge graph (B22)]].

### 9.1 Motivation

Governance is not an add-on feature. It is one of the primary reasons the platform's architecture has been designed as it has. The self-describing system ([[principle-self-describing-system|A2]]), the governance traceability chain ([[principle-clinical-governance-first-class|A8]]), the knowledge graph with OWL reasoning ([[concept-bfo-ontological-grounding|B23]]), the coordinate framework with projections, the reflective simulation with valence — these are the infrastructure for a governance engine. The [[ontara-discussion-deontic-governance-architecture-2026-04-03|Deontic Governance Architecture paper]] (Session 121) designs the missing piece: the obligation vocabulary.

### 9.2 The three-tier compliance architecture

The governance framework operates at three tiers:

1. **Library tier** — the governance vocabulary and pre-formalised governance frameworks. Platform-level, shared infrastructure maintained by governance experts, versioned with explicit currency claims.
2. **Activation tier** — framework activation and obligation binding. When a tenant activates a governance framework, obligations are bound to specific elements of their service model. Design deferred pending MVP exercise.
3. **Operations tier** — real-time compliance monitoring, evidence collection, audit trail, governance-aware simulation. Design deferred pending activation tier.

The [[#4. The Ontara Portal|Ontara Portal]]'s progressive governance (§4.7) is a prototype of how the activation and operations tiers manifest in an operator-facing interface — the three governance levels (exploratory/advisory/enforced) map onto the transition from unbound constraints (library tier) through advisory evaluation (activation tier) to enforced compliance (operations tier).

### 9.3 The deontic vocabulary

The obligation vocabulary is grounded in deontic logic — the formal study of normative concepts. Four deontic modalities ([[concept-deontic-directive-vocabulary|B30]]): Obligation (what must be done), Prohibition (what must not be done), Permission (what may be done), and RegulatoryPower (the authority to impose or vary obligations). These are subclasses of `DeonticDirective`, itself grounded in IAO via BFO.

Structural properties classify each directive by content modality (state-oriented, action-oriented, achievement-oriented), temporal scope (continuous, triggered, periodic, time-bounded), authority type (statutory, regulatory, contractual, professional, organisational), and normative status (in force, suspended, revoked, proposed, transitional).

The normative instrument taxonomy ([[concept-normative-instrument-taxonomy|B33]]) represents the source authority hierarchy: PrimaryLegislation, SecondaryLegislation, StatutoryGuidance, RegulatoryStandard, ProfessionalStandard, ContractualClause, OrganisationalPolicy, ClinicalGuideline, ApprovedCodesOfPractice, InternationalInstrument, FrameworkAgreement.

### 9.4 Governance frameworks

A `GovernanceFramework` ([[concept-governance-framework-library|B31]]) is a curated, versioned collection of deontic directives derived from a coherent body of normative instruments. `ObligationGroup` provides thematic organisation within a framework.

### 9.5 Integration with the dual-stack

The governance vocabulary sits in the domain graph of the [[concept-three-stratum-knowledge-graph|three-stratum knowledge graph (B28)]], at the ontological layer of the left-hand (business model) stack. It extends the BMM's GovernanceMapping concern (C5) with formal semantic grounding. The future [[concept-framework-activation-obligation-binding|binding mechanism (B32)]] will connect governance frameworks to specific business model elements.

**Governance–reasoning integration (Session 151):** The reasoning metamodel declares governance obligations as hard constraints in coordinate-space terms — Obligation and Prohibition are HardConstraint subclasses, defining NormativeRegion boundaries. This means governance has temporal depth through the coordinate space: compliance is a trajectory, not a snapshot. When the system reasons about what the business can do, governance obligations define the boundaries of the permissible.

### 9.6 CQC Governance MVP

The CQC Governance MVP (Sessions 130–131, [[ontara-stage-5-plan-s.130-cqc-governance-mvp|plan produced Session 130]]) was the first full exercise of the deontic governance vocabulary with production-quality regulatory content. The MVP formalised CQC Regulation 12 (Safe Care and Treatment) in full depth: 21 individuals in `ontology/governance/cqc-reg12-individuals.ttl` comprising 4 normative instruments, 10 statutory obligations, 5 guidance-level directives, 1 obligation group, and 1 governance framework.

### 9.7 Current state and next steps

The vocabulary tier is implemented, validated, exercised with production content, and connected to the reasoning metamodel (Sessions 121–152). The portal's progressive governance (Stage 8, Sessions 182–185) provides a prototype of how governance constraints operate in a user-facing context — the three governance levels and 20 typed constraints exercise the three-way constraint distinction at the interface layer.

Next steps: the **activation tier** would connect the library tier to specific business domains. The **operations tier** (real-time compliance monitoring, evidence collection) depends on the activation tier. Both are candidate workstreams — Stage 6 Block B is the planned vehicle for governance activation.

---

## 10. The Reasoning Metamodel

Stage 7 (Sessions 146–158, formally closed Session 159) implements institutionalised reasoning as a first-class platform capability. Two discussion papers — [[ontara-discussion-institutionalised-reasoning-2026-04-05|Institutionalised Reasoning (Session 146)]] and [[ontara-discussion-coordinate-framework-revisited-2026-04-05|The Coordinate Framework Revisited (Session 147)]] — established the conceptual foundation. Fifteen design decisions (S146-D1 to D8, S147-D1 to D7) were confirmed Session 148. The [[ontara-stage7-plan-high-level-s.148-reasoning-metamodel|Stage 7 plan]] covered five phases (0–4), 15–25 sessions estimated. All phases complete. Stage 7 formally closed Session 159. 24 design decisions confirmed across the stage.

### 10.1 Architectural position

The reasoning metamodel is a **cross-cutting SMM extension** (S146-D1), preserving [[principle-two-meta-model-distinction|A4]]. It provides the OWL vocabulary for reasoning contexts, evidence architecture, constraint hierarchy, and structured probabilistic reasoning. It does **not** implement runtime reasoning engines — those are deployment-time concerns per [[concept-authority-zones|B29]].

### 10.2 The coordinate framework consolidation (Phase 0)

Session 147 identified four contradictions/ambiguities in the architecture that the reasoning metamodel would expose if not resolved first. Phase 0 (Session 148) resolved them:

- **Epistemic vocabulary reconciled** (S147-D1): three orthogonal dimensions — provenance modality (seven values from [[concept-epistemic-modality|B17]]), functional purpose (five values from [[concept-coordinate-space-snapshots|L8]]), and evidential confidence (with declared interpretive frame) — that compose rather than conflict.
- **Region taxonomy enriched** (S147-D2): seven extensible subtypes (StaticBoundary, GoalRegion, NormativeRegion, ProbabilityDistribution, ScalarField, ClassificationRegion, FormalisationFrontier), all BFO-grounded.
- **Constraint geometry formalised** (S147-D3): HardConstraints as NormativeRegion boundaries (violation = failure), SoftConstraints as ScalarField cost surfaces, GradedRules as ScalarField truth-value surfaces. [[concept-goal-seeking-computation|L9]] reinterpreted as pathfinding through constrained coordinate space.
- **A6 reformulated** (S147-D5, T1 amendment): four-category scheme — deterministic rules (Tier 1), inspectable logic (Tier 2), structured probabilistic (new), opaque probabilistic (Tier 3). In coordinate-framework language: deterministic paths through a probabilistically characterised landscape.

The comprehension–reasoning convergence (S147-D7) confirmed that Register 2+ (inferential self-knowledge) and the SEPIO+PROV-O evidence architecture are the same pattern — validating [[principle-unity-principle|A11]].

### 10.3 The reasoning vocabulary (Phases 1–3)

`ontara-reasoning.ttl` (namespace `ontara-rsn:`, Sessions 150–157) contains:

- **42 classes**: 3 dual-subclassed foundation classes (ReasoningActivity, Claim, ReasoningAgent — each with BFO + PROV-O parentage per S147-D4), 14 core reasoning classes, 4 evidence architecture classes, 5 structured probabilistic types, 8 depth classes (6 Heuristic subtypes, HeuristicPack, CombinationAlgebra — Phase 2), 8 safety and resilience classes (SafetyConstraint, ControlStructure, ControlLoop, ControlAction, UnsafeControlAction, UnsafeControlActionType, FRAMFunction, VariabilityProfile — Phase 3)
- **15 named individuals**: 3 interpretive frames (stable since Session 46), 4 Cynefin-mapped DecisionMode individuals, 4 CombinationAlgebra individuals, 4 STPA UnsafeControlAction types
- **40 object properties** with explicit domain, range, and OWL characteristics (including transitive `hierarchicallyControls`, symmetric `composedWith` and `coupledWith`, functional `hasVariabilityProfile` and `hasCombinationAlgebra`)
- **10 datatype properties** (confidence value, 3 validation metadata, ordering logic, truth-value range, internal/external variability, priority)
- **7 PROV-O dual-subclassed classes**
- **2 cross-module governance alignment axioms**: Obligation and Prohibition as HardConstraint subclasses

PROV-O core subset imported (`prov-core.ttl`, 73 triples) with dual subclassing (S147-D4). Key design resolution: constraints are information (GenericallyDependentContinuant via IAO), not dispositions. Priors and posteriors typed as Claims for full provenance traceability.

### 10.4 Validation and console integration

- **HermiT:** CONSISTENT across 13-file ontology stack (verified at each phase boundary and after Ears instance addition)
- **SPARQL:** 66/66 queries passed — 56 vocabulary-level (Phases 1–3) + 10 Ears instance-level (Session 168). 12 groups
- **Cross-domain validation:** All phases validated against [[domain-cafe|Cafe]] and [[domain-suds|Suds]] domains. [[domain-ears|Ears]] provided the first clinical domain validation (Sessions 161–168)
- **Console:** Reasoning Vocabulary Explorer (Session 158) — 42-class hierarchy in 7 functional modules, 15 named individuals, 50 properties with Kind badges, 32 cross-module axioms. KG Status extended with 8 stat cards and vocabulary module summary

### 10.5 Ears clinical domain intake — first vocabulary validation

The [[domain-ears|Ears]] clinical domain intake (Sessions 160–168, [[ontara-ref-work-items|W-015]]) was the first domain-specific exercise of the reasoning and governance vocabularies against real clinical content. The intake followed the [[ontara-discussion-clinical-domain-intake-framework-2026-04-07|Clinical Domain Intake Framework]] (Session 160).

Five artefacts produced: [[ontara-ears-domain-description|domain description]] (S161), [[ontara-ears-vertical-connection-map|vertical connection map]] (S162), [[ontara-ears-coverage-map|coverage map]] (S165, 86.2% Full across 65 fields), reasoning instances (~83 individuals, S166), and [[ontara-ears-design-note|design note]] (S167). Key findings: vocabulary adequate at Ears-level complexity (S167-D1); three-way constraint hierarchy validated (S167-D2); meta-constraints ([[ontara-workflow-emergent-ideas-log|E028]]) accommodated; intake methodology repeatable (S167-D5). The intake drove the [[ontara-ref-work-items|OW Register]] (S167, 12 items) and critique capture convention (S165).

### 10.6 Standing instruction

Per Ella's standing instruction (Session 147): **the [[ontara-discussion-coordinate-framework-revisited-2026-04-05|coordinate framework revisited paper]] should be actively considered for its relevance with every significant piece of work undertaken.**

### 10.7 What comes next

Stage 7 is formally closed. Future reasoning work: governance activation tier (Stage 6 Block B); GSL clinical domain intake; evidence browser and decision trace (P4-2, P4-3); BMM-to-reasoning cross-vocabulary formalisation (OW-07).

---

## 11. Foundational Architecture

Session 59 produced four discussion papers that establish a candidate foundational layer. Sessions 73–74 advanced several of these from directional to binding status. Session 147 significantly enriched the coordinate framework and reconciled the epistemic vocabulary. Sessions 142–144 implemented domain identity.

### 11.1 The coordinate framework ([[concept-coordinate-framework|A12]], T1 candidate)

The system's representational space is a multi-dimensional coordinate space, not a hierarchy. Every conceptual entity traces a trajectory through this space. Vectors describe rate and direction of change along axes. Regions define governance constraints, therapeutic ranges, financial thresholds. Projections and transformations relate different coordinate systems.

The coordinate system test: "Can I add a new axis without refactoring?"

**Session 147 enrichment:** The [[ontara-discussion-coordinate-framework-revisited-2026-04-05|coordinate framework revisited paper]] consolidated A12 in light of the reasoning metamodel: Region taxonomy expanded to seven extensible subtypes (StaticBoundary, GoalRegion, NormativeRegion, ProbabilityDistribution, ScalarField, ClassificationRegion, FormalisationFrontier); constraint geometry formalised (HardConstraints as boundaries, SoftConstraints as cost fields, GradedRules as truth fields); comprehension–reasoning convergence confirmed.

Existing console features — coverage matrix, component catalogue, glossary, governance traceability — are projections of the same coordinate space. The [[concept-coordinate-space-snapshots|coordinate space snapshots (L8)]] make this operational at runtime. See [[ontara-discussion-coordinate-framework-2026-03-22_1|Coordinate Framework discussion]] and [[ontara-discussion-coordinate-framework-revisited-2026-04-05|Coordinate Framework Revisited (Session 147)]].

### 11.2 Domain identity ([[concept-domain-identity|B15]])

**Implemented (Sessions 142–144).** The [[ontara-discussion-domain-identity-dual-stack-2026-04-05|Session 142 paper]] revised the Session 59 design into a dual-stack split: `DomainIdentity` (BMM, IAO plan_specification) carries business intent — regulatory tier, purpose, jurisdiction; `DomainConfiguration` (SMM, IAO data_item) carries system settings — vocabulary scope, governed activities, organisational form. Connected by explicit horizontal mapping. Implemented in SysML (Session 143: 2 part defs, 6 enums, 8 instances), OWL (`ontara-domain.ttl`, Session 144), and the generation pipeline. [[concept-multi-tenancy|A13]] promoted to binding T1 (S142-D3). B36–B39 registered.

### 11.3 Temporal reference frames ([[concept-temporal-reference-frames|B16]])

Different parts of the system experience time in different reference frames. Eight illustrative frames identified: clinical episode time, business planning time, regulatory reporting time, pathway step time, system execution time, audit/evidence time, patient biographical time, research/population time. Vague temporal vocabulary ("after stabilisation", "when appropriate") is a first-class concern, not a defect to be eliminated.

[[concept-epistemic-modality|Epistemic modality (B17)]]: reconciled Session 147 as three orthogonal dimensions (provenance modality × functional purpose × evidential confidence), with composition rules and validity constraints. Operationalised through [[concept-coordinate-space-snapshots|coordinate space snapshots (L8)]]. See [[ontara-discussion-temporality-reference-frames-2026-03-22-v2.1|Temporality discussion]] and [[ontara-discussion-coordinate-framework-revisited-2026-04-05|Coordinate Framework Revisited (Session 147)]].

### 11.4 Ontological grounding

Covered in detail in [[#6. Ontological Grounding]] above. BFO is now mandatory (upgraded from directional, Session 73). OWL 2 DL is mandatory. PROV-O added at platform level (Session 148/150). These represent the most significant status changes in the foundational layer since Session 59.

---

## 12. Demonstrator Domains

### 12.1 Rationale

Demonstrator domains serve two purposes ([[concept-cross-domain-validation|J1]]):

1. **Cross-domain validation.** Three structurally different businesses validate that the BMM vocabulary generalises.
2. **Pedagogical anchoring.** Concrete illustrations that make abstract concepts tangible.

### 12.2 The domains

| Domain | Character | Regulatory tier | BMM coverage |
|---|---|---|---|
| [[domain-cafe\|Cafe]] | Immediate retail — per-item pricing, walk-in, 2-minute cycle | Generally governed | Full model + running application (22 validated patterns). StakeholderModel: 6 instantiations (Session 81) |
| [[domain-suds\|Suds]] | Batch processing — weight/type pricing, batch turnaround, item tracking | Lightly regulated | Full BMM + COSHH governance traceability chain. StakeholderModel: 6 instantiations (Session 108) |
| [[domain-paws\|Paws]] | Appointment-based personal service — per-appointment pricing, breed/size surcharges, persistent client/animal identity | Lightly regulated | General vocabulary + StakeholderModel: 7 instantiations (Session 81). ServiceSubject + ServiceParticipant instantiated |
| [[domain-ears\|Ears]] | Community ear care — clinical pathway, clinical governance | Sector-regulated | Analytical intake complete (Sessions 161–168, W-015). [[ontara-ears-domain-description\|Domain description]], [[ontara-ears-vertical-connection-map\|vertical connection map]], [[ontara-ears-coverage-map\|coverage map]] (86.2% Full), ~83 reasoning instances, [[ontara-ears-design-note\|design note]]. Exercises all six BMM concerns, OGMS primitives, reasoning vocabulary (25/42 classes), governance vocabulary at depth. 13-file stack, 66/66 SPARQL. Fifth demonstrator, second clinical domain |

### 12.3 GSL's relationship to the demonstrators

Under [[concept-multi-tenancy|A13]], GSL is the most important tenant — but still a tenant. Its distinction is purpose (production healthcare delivery) and regulatory tier (sector-regulated). GSL is the eventual production target; the demonstrators validate the meta model generalises before GSL-specific complexity is introduced.

---

## 13. Governing Principles

The [[ontara-ref-master-register|master concept register]] is the comprehensive inventory (~212 concepts across 16 sections, four tiers). The eleven Tier 1 governing principles (plus one T1 candidate) are:

| # | Principle | One-line test |
|---|---|---|
| [[principle-separation-representation-execution\|A1]] | Separation of representation and execution | Changes happen in representation and propagate to execution, never the reverse |
| [[principle-self-describing-system\|A2]] | Self-describing system | The system knows what it is, what it is doing, why, and what rules govern it |
| [[principle-model-generates-everything\|A3]] | Model generates everything | SysML v2 is the single source of truth |
| [[principle-two-meta-model-distinction\|A4]] | Two meta model distinction | BMM and SMM are distinct, connected by explicit mappings |
| [[principle-deterministic-over-probabilistic\|A6]] | Deterministic/auditable reasoning | Authoritative decisions follow deterministic, inspectable paths; structured probabilistic reasoning permitted with validated models, explicit assumptions, and full provenance. Reformulated Session 148 (T1 amendment) |
| [[principle-discipline-as-load-bearing-structure\|A9]] | Discipline as load-bearing structure | Disciplined practices propagate reliability; regression applies to practices, not just code |
| [[principle-intrinsic-self-knowledge\|A10]] | Intrinsic self-knowledge | System explanations are dynamically computed from live model state |
| [[principle-unity-principle\|A11]] | Unity principle | One weighted relationship model informs all subsystems. Empirically validated S147-D7 |
| [[concept-co-evolution\|J2]] | Co-evolution | No modelling without the tool that makes it legible; no tool without model content |
| [[concept-non-constraining\|J3]] | Non-constraining | Decisions should not foreclose future development paths |
| [[concept-multi-tenancy\|A13]] | Multi-tenancy | Only the meta model is core; every domain is a tenant instantiation. Promoted to binding T1, Session 142 |
| [[concept-coordinate-framework\|A12]] | Coordinate framework _(T1 candidate)_ | The representational space is a multi-dimensional coordinate space; can I add a new axis without refactoring? Significantly enriched Session 147 |

### 13.1 Development methodology principles

| Principle | Summary |
|---|---|
| [[concept-cross-domain-validation\|J1]] | Every concept/pattern validates in at least two domains |
| [[concept-co-evolution\|J2]] | Model and tooling advance together |
| [[concept-non-constraining\|J3]] | Decisions should not foreclose future development paths |
| [[concept-retrospective-bootstrapping\|J10]] | After each step, ask: how could our own tooling have made that easier? |
| [[concept-design-decision-lifecycle\|J12]] | Freedom → experimentation → discovered convention → opinionated configuration → revisable |
| [[concept-inception-capture\|J13]] | Ideas captured immediately with full fidelity at the moment of recognition |

---

## 14. Architecture Carried Forward

The following architectural commitments, established in foundational papers, remain in force. They are not restated in full — the authoritative sources are referenced.

- **From [[ontara-architecture-platform-principles|Architecture Principles (v4.1)]]:** Separation of representation and execution ([[principle-separation-representation-execution|A1]]). Self-describing system ([[principle-self-describing-system|A2]]). [openEHR](https://specifications.openehr.org/) as clinical data architecture. Clinical governance as first-class concern ([[principle-clinical-governance-first-class|A8]]). IG and cybersecurity as foundational modelling concern ([[ontara-ref-master-register|B20]]).

- **From [[ontara-architecture-business-meta-modelling|Service Business Meta Modelling (v3.1)]]:** Two distinct meta models ([[principle-two-meta-model-distinction|A4]]). Six concerns (C1–C5, C7 StakeholderModel). Activity awareness (C6). Scenario modelling and operational steering (F5). Simulation capability (L1–L4, now conceptually designed as L5–L9 and prototyped in the [[#4. The Ontara Portal|portal]]).

- **From [[ontara-architecture-platform-modelling-strategy|SysML Modelling Strategy (v4.1)]]:** SysML v2 as single source of truth ([[principle-model-generates-everything|A3]]). Concentric rings of rigour. Three-tier reasoning stack ([[principle-deterministic-over-probabilistic|A6]], now reformulated as four-category scheme).

- **From the PatternCatalogue:** 22 validated patterns, 8 principles, 43 semantic relationships.

- **From [[ontara-discussion-model-self-service-enabling-architecture-2026-03-14|Self-Service Enabling Architecture]]:** Enabling architecture (A7). Agency classification ([[concept-agency-classification|H2]]). CoPHR heritage (H4). Four-generation roadmap (H3). Clinical authority problem (H5).

- **From the Knowledge Layer:** Five-layer SystemStateAssessment (F1). Constraint evaluation pattern (F2). [Tau Prolog](http://tau-prolog.org/) for Tier 2 reasoning (F6). Three remediation categories (F4).

- **From [[ontara-discussion-dual-stack-architecture-2026-03-26|Dual-Stack Architecture]]:** The architectural framework described in §2.2 and §6–7 of this document. Binding decisions on BFO and OWL 2 DL. Directional commitment on knowledge graph as canonical store.

- **From [[ontara-discussion-knowledge-graph-architecture-2026-04-01|Knowledge Graph Architecture]] (Session 97):** Three-stratum graph (E019), authority zones (E020), five-stage Python pipeline, triple store selection, IRI scheme. 9 binding decisions.

- **From [[ontara-discussion-deontic-governance-architecture-2026-04-03|Deontic Governance Architecture]] (Session 121):** Three-tier compliance architecture. Deontic obligation vocabulary. Governance framework library. Seven design decisions.

- **From [[ontara-discussion-deontic-owl-class-design-2026-04-03|Deontic Governance OWL Class Design]] (Session 125):** 19 classes, 6 enumeration classes. Implemented Session 126.

- **From [[ontara-stage-5-plan-s.130-cqc-governance-mvp|CQC Governance MVP Plan]] (Session 130):** CQC Regulation 12 formalised. 21 individuals. Implemented Session 131.

- **From [[ontara-discussion-governance-granularity-and-cross-references-2026-04-04|Decomposition Granularity]] (Session 132):** Three-tier standard decomposition. Five cross-reference patterns.

- **From [[ontara-discussion-console-navigation-context-2026-04-04|Global Console Navigation Context]] (Session 132):** NavigationStore design (I19). Implemented Sessions 133–134.

- **From [[ontara-stage-5-plan-s.135-phase3|Stage 5 Phase 3]] (Session 135):** Three layers of automated QA. Round-trip diff engine. Formally closed Session 137.

- **From [[ontara-discussion-domain-identity-dual-stack-2026-04-05|Domain Identity]] (Session 142):** Dual-stack split. A13 promoted to binding T1. Implemented Sessions 143–144.

- **From [[ontara-discussion-institutionalised-reasoning-2026-04-05|Institutionalised Reasoning]] (Session 146) and [[ontara-discussion-coordinate-framework-revisited-2026-04-05|Coordinate Framework Revisited]] (Session 147):** Reasoning metamodel as SMM extension (S146-D1). PROV-O platform-level import (S146-D2). Dual subclassing (S147-D4). Evidence architecture (SEPIO pattern, S146-D7). Three-way constraint distinction (S146-D8/S147-D3). A6 reformulated as T1 amendment (S147-D5). Comprehension–reasoning convergence (S147-D7). 24 design decisions across Stage 7 (Sessions 148–158). Stage 7 formally closed Session 159.

- **From [[ontara-discussion-clinical-domain-intake-framework-2026-04-07|Clinical Domain Intake Framework]] (Session 160):** Structured methodology for domain characterisation, ingestion, and platform fitness validation. Feature taxonomy, proforma intake schema, coverage map concept. First exercised with [[domain-ears|Ears]] (Sessions 161–168, [[ontara-ref-work-items|W-015]]). Drove the [[ontara-ref-work-items|Observation and Watchpoint Register]] (Session 167) and workflow guide critique capture convention (Session 165).

- **From [[ontara-discussion-portal-state-driven-operator-experience-2026-04-08|Portal: State-Driven Operator Experience]] (Session 174):** State-driven operator paradigm. Module architecture with composable lifecycle. BMM-concern-structured domain context. Progressive governance with three-way constraint mapping. Epistemic dimension and promotion path. [[ontara-stage8-plan-high-level-s.174-portal|Stage 8 plan]] (5 phases). All phases complete (Sessions 175–185). Stage 8 formally closed Session 185.

---

## Related Documents

- [[ontara-ref-strategic-snapshot|Strategic Reference]] — comprehensive orientation: current state, scale, what's next
- [[ontara-ref-master-register|Master Concept Register]] — ~212 concepts across 16 sections (A–P), four tiers
- [[ontara-workflow-guide|Development Workflow Guide (v2)]] — the shared operating agreement
- [[ontara-guide-claude-tooling|Claude Tooling Guide]] — Claude Chat, Code, Cowork allocation
- [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]] — 30 entries (E001–E030)
- [[ontara-ref-modelling-paradigms|Modelling Paradigm Reference]] — 11 modelling paradigms with exploitation status
- [[—— ARCHITECTURE INDEX ——|Architecture Papers Index]] — curated reading order for all architecture documentation
- [[—— CONCEPT GRAPH INDEX ——]] — the navigable concept graph (~97 notes)
- [[ontara-architecture-platform-principles|Architecture Principles (v4.1)]]
- [[ontara-architecture-business-meta-modelling|Service Business Meta Modelling (v3.1)]]
- [[ontara-architecture-platform-modelling-strategy|SysML Modelling Strategy (v4.1)]]
- [[ontara-discussion-dual-stack-architecture-2026-03-26|Dual-Stack Architecture Discussion Paper]]
- [[ontara-discussion-paper-process-specification-layer-2026-03-27|Process Specification Layer Discussion Paper]]
- [[ontara-discussion-intrinsic-self-knowledge-v2-2026-03-20|Intrinsic Self-Knowledge Discussion]]
- [[ontara-discussion-coordinate-framework-2026-03-22_1|Coordinate Framework Discussion]]
- [[ontara-discussion-coordinate-framework-revisited-2026-04-05|Coordinate Framework Revisited Discussion Paper]]
- [[ontara-discussion-domain-identity-dual-stack-2026-04-05|Domain Identity Discussion Paper]]
- [[ontara-discussion-temporality-reference-frames-2026-03-22-v2.1|Temporality and Reference Frames Discussion]]
- [[ontara-discussion-ontological-grounding-2026-03-22|Ontological Grounding Discussion]]
- [[ontara-discussion-knowledge-graph-architecture-2026-04-01|Knowledge Graph Architecture Discussion Paper]]
- [[ontara-discussion-bfo-type-mapping-2026-04-01|@BfoType Mapping Discussion Paper]]
- [[ontara-discussion-deontic-governance-architecture-2026-04-03|Deontic Governance Architecture Discussion Paper]]
- [[ontara-discussion-deontic-owl-class-design-2026-04-03|Deontic Governance OWL Class Design Discussion Paper]]
- [[ontara-discussion-institutionalised-reasoning-2026-04-05|Institutionalised Reasoning Discussion Paper]]
- [[ontara-stage7-plan-high-level-s.148-reasoning-metamodel|Stage 7 Plan — Reasoning Metamodel]]
- [[ontara-stage-5-plan-s.100-kg-implementation|KG Implementation Plan]]
- [[ontara-stage-5-plan-s.111-phase2|Stage 5 Phase 2 Plan]]
- [[ontara-stage-5-plan-s.135-phase3|Stage 5 Phase 3 Plan]]
- [[ontara-stage-5-plan-s.130-cqc-governance-mvp|CQC Governance MVP Plan]]
- [[session-141-domain-governance-convergence-plan|Domain Identity and Governance Convergence Plan]]
- [[ontara-stage-4-plan-high-level-2026-03-21|Stage 4 High-Level Plan]]
- [[ontara-discussion-clinical-domain-intake-framework-2026-04-07|Clinical Domain Intake Framework]]
- [[ontara-ears-domain-description|Ears Domain Description]]
- [[ontara-ears-vertical-connection-map|Ears Vertical Connection Map]]
- [[ontara-ears-coverage-map|Ears Coverage Map]]
- [[ontara-ears-design-note|Ears Design Note]]
- [[ontara-discussion-portal-state-driven-operator-experience-2026-04-08|Portal: State-Driven Operator Experience Discussion Paper]]
- [[ontara-stage8-plan-high-level-s.174-portal|Stage 8 Plan — Ontara Portal]]
- [[ontara-stage8-phase3-plan-s.177-domain-context|Stage 8 Phase 3 Plan — Domain Context]]
- [[ontara-stage8-plan-phase4-s.179-simulation-comparison|Stage 8 Phase 4 Plan — Simulation and Comparison]]
- [[ontara-stage8-phase5-plan-s.182-governance-promotion|Stage 8 Phase 5 Plan — Governance and Promotion]]

---

_Vision and architecture reference v11, written 9 April 2026 (Session 187). Replaces [[SUPERSEDED-ontara-ref-vision-architecture-v10-s169|v10]] (Session 169). v11 refresh incorporates: foundations papers light touch-up to v4.1/v3.1 (Session 170); sixth systematic documentation review (Session 172, 10 findings resolved); Modelling Paradigm Reference created (Session 173); Ontara Portal discussion paper (Session 174, state-driven operator paradigm, module architecture); Stage 8 plan produced (Session 174, 5 phases, 19–31 sessions); Stage 8 Phase 1 (Session 175, portal empty shell — auth, domain CRUD); Phase 2 (Session 176, 10-module catalogue with three categories, two intersecting lifecycle state machines, dashboard as state landscape); Phase 3 (Sessions 177–178, BMM-concern-structured domain context, module wiring from concern overlap, composition guidance with lifecycle impact warnings); Phase 4 (Sessions 179–181, epistemic dimension with production/hypothesis/projection, simulation with batch event generation and comparative analytics, generative and analytical module categories); Phase 5 (Sessions 182–185, progressive governance with three levels and 20 typed constraints, promotion path with 5-prerequisite wizard and demotion, production visual treatment, lifecycle governance guards); Stage 8 formally closed Session 185 — 11 sessions, within 19–31 estimate. New §4 (The Ontara Portal — comprehensive section). Updated §1.1 (portal as prototype expression of operator experience), §2.1 (portal at runtime layer), §3 intro (Console distinguished from Portal), §3.4 (Stage 8 complete), §7.1–7.4 (portal prototype annotations for L5, L6, L8), §9.2 (portal as prototype of governance tiers), §9.7 (portal progressive governance noted), §14 (portal architecture carried forward). Updated Related Documents (EIL 30, concept graph ~97, Portal discussion paper, Stage 8 plan, Phase 3/4/5 plans, Modelling Paradigm Reference, foundations v4.1/v3.1). Staleness threshold: 12 sessions or major architectural decision._
