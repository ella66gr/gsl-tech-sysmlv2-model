# Ontara — Vision and Architecture Reference

**Date:** 27 March 2026 (Session 75) **Replaces:** v2 (Session 62), archived as [[SUPERSEDED-ontara-ref-vision-architecture-v2-s62|Vision and Architecture Reference (Session 62)]] **Status:** Standing reference document. The authoritative summary of what Ontara is, how it is architecturally structured, what the console vision is, and how the platform comprehends itself.

---

## 1. What Ontara Is

**Ontara** is a service system development, delivery, and **execution** platform, particularly strong in supporting regulated care service delivery.

The name evokes a grounding in ontology, a sense of being and essence, along with a feminine intuition of awareness of self. This reflects the deeper foundational principles and deliberately holistic design ethos of the platform — the basis for a highly sophisticated, self-aware and technically advanced ecosystem.

Ontara encompasses **all layers** of the system: meta models, business models, system models, the execution platform, the generation pipeline, the comprehension architecture, and the developer/architect tooling (the [[#3. The Ontara Console Vision|Ontara Console]]).

Ontara is not the name of one component. It is the name for the whole.

### 1.1 The architectural thesis

A SysML v2 model serves as the single source of truth ([[principle-model-generates-everything|A3]]) for what a service business is, how it works, what rules govern it, and how the technology platform supports it. The model _generates_ the running system rather than merely documenting it. The model also comprehends itself — it can explain what it contains and why.

Ontara is an **execution platform**, not merely a generation tool. This is established, not aspirational — the coffee shop demonstrator is a running system generated from the model, the [[ontara-discussion-paper-process-specification-layer|process specification layer]] describes the full pipeline from model to deployed Temporal workflows, and [[principle-separation-representation-execution|A1]] has always said representation _propagates to_ execution. The [[ontara-discussion-dual-stack-architecture-2026-03-26|dual-stack architecture]] (Session 73) made the runtime architecture explicit: the model does not generate code and step aside — it generates systems that remain connected to the model at runtime through the [[concept-operational-simulation|operational simulation (L5)]], where the running system's state _is_ the business model made live.

This contrasts with the typical situation where the model of a business supported by a technical system is implicit, incomplete, and scattered across code, configuration, documentation, and people's heads. Mapping the system to the business model — or vice versa — is usually a painful, expensive exercise that produces limited benefit. Ontara's thesis is that this problem is solvable: make the model explicit, make it generative, make it self-describing, and make it comprehensible.

### 1.2 Platform identity

Ontara meets the technical definition of a _platform_ as distinct from a product or framework: modular architecture with standardised interfaces; abstraction and generality through meta models; lifecycle support from design through operation; evolutionary stability through versioning, the [[concept-non-constraining|non-constraining principle (J3)]], and the PatternCatalogue; ecosystem enablement through dual-canvas tooling and meta-model-defined palettes; composability, extensibility, and integrated tooling.

The pragmatic test: if Ella stopped building end-user features, would other teams still find Ontara valuable as a base to build their own service businesses?

### 1.3 Multi-tenancy and the relationship to GenderSense

Under the [[concept-multi-tenancy|multi-tenancy principle (A13)]], only the meta model is core. Every domain — including GenderSense Limited (GSL), the private gender-affirming healthcare service that is the primary motivating use case — is a tenant instantiation: an exercise of the system's capabilities against a specific service business.

GSL is the most important tenant, but it is not more structurally privileged than the demonstrator domains. Its distinction is purpose (production healthcare delivery) and regulatory tier (sector-regulated). The system can maintain any number of demonstrator domains that exercise and test the capability, limits and extensibility of the meta models.

This principle sharpens the platform identity: Ontara is the platform; GSL, [[domain-cafe|Cafe]], [[domain-suds|Suds]], and [[domain-paws|Paws]] are tenants.

---

## 2. Architecture

### 2.1 The six-layer architecture

|Layer|Name|Content|
|---|---|---|
|6|Meta-meta level|SysML v2 itself: `part def`, `attribute`, `ref`, `enum def`, `constraint def`, etc. Provided by the language and Syside Modeler.|
|5|Business Meta Model (BMM)|The structural template for what a service business _is_. 28 elements across five concerns: [[#2.4 The five concerns|
|4|Business System Meta Model (BSMM)|The structural template for how a business system _works_. Now made explicit through the [[concept-dual-stack-architecture|
|3|Business model instances|A specific service business described using Layer 5 concepts. GSL, [[domain-cafe|
|2|System model instances|The concrete implementation described using Layer 4 concepts. Frontends, workflows, schemas, persistence policies, generation pipeline outputs.|
|1|Runtime|The running system, its state, its data. The [[concept-operational-simulation|

### 2.2 The dual-stack architecture ([[concept-dual-stack-architecture|B21]])

The [[ontara-discussion-dual-stack-architecture-2026-03-26|dual-stack architecture]] (Session 73) is the most significant architectural advance since the platform was named. The BMM and BSMM are two parallel vertical stacks connected by [[ontara-ref-master-register|horizontal mappings (B12)]] at each level.

**Left stack — Business Model ("what the business is and does")**

|Layer|Content|Formalism|
|---|---|---|
|Ontology|BFO categories (shared with right side)|OWL 2 DL|
|Domain ontologies|OGMS, IAO, OCE, GSSO, OBI — mid-level, BFO-aligned|OWL 2 DL|
|BMM General vocabulary|Domain-neutral structural concepts (`part def`s)|SysML v2|
|Business instance|Concrete domain data (`part` usages)|SysML v2|
|Operational domains|How the business operates — business language|SysML v2|
|Business process patterns|Dynamic behaviour and flows|SysML v2|

**Right stack — Business System Model ("how the system realises it")**

|Layer|Content|Formalism|
|---|---|---|
|System ontological categories|BFO-typed system constructs: Process, State, Event, Record|OWL 2 DL|
|BSMM General vocabulary|Domain-neutral system concepts (`part def`s)|SysML v2|
|System instance|Concrete system configuration (`part` usages)|SysML v2|
|System domains|Running system modules|SysML v2 + execution|
|Operational simulation|System-managed execution — Temporal workflows, state management, event streams|Temporal / CLP(FD)|

A critical correction established in Session 73: what was previously labelled the "systems layer" at the bottom of the left-hand stack (booking, scheduling, finance, compliance, etc.) is actually business model content expressed in business language. It describes how the business operates, not how a system implements it. The systems side sits _alongside_ as a parallel stack, not below. The [[concept-reflective-simulation|reflective simulation (L6)]] is cross-cutting on the right side — see [[#6. Simulation Architecture]].

**Horizontal mappings** connect each level:

|Left|Mapping type|Right|
|---|---|---|
|Ontology|classifies / constrains|System ontological categories|
|BMM General vocabulary|maps to|BSMM General vocabulary|
|Business instance|realised by|System instance|
|Operational domains|realised by|System domains|
|Business process patterns|executed as|Operational simulation|

**Rules and constraints** govern the dynamic layers (bottom two pairs on both sides) within a bounded container. Constraint _definitions_ live in the instance layers (structural); constraint _enforcement_ happens at runtime (dynamic). This parallels the [[principle-clinical-governance-first-class|governance traceability chain (A8)]].

![[ontara-dual-stack-architecture.svg]]

### 2.3 The two meta model distinction ([[principle-two-meta-model-distinction|A4]])

**Business Meta Model (BMM)** — what a service business _is_. 28 elements across five concerns. Components classified as General (sector-agnostic) or Tailored (sector-specific). See [[ontara-service-business-meta-modelling-v2|Service Business Meta Modelling (v2)]].

**Business System Meta Model (BSMM)** — how a business system _works_. The dual-stack architecture makes the BSMM explicit for the first time as the right-hand stack. Previously the BSMM was implicit, distributed across Foundation, Knowledge, ServiceDelivery, Platform, Operations, and PatternCatalogue. See [[ontara-architecture-clarification-two-meta-models-2026-03-14|Two Meta Models Clarification]].

The two meta models are connected by explicit horizontal mappings at every tier ([[ontara-ref-master-register|B12]]): General BMM ↔ General BSMM, Tailored BMM ↔ Tailored BSMM, individual business models ↔ individual system models.

### 2.4 The five concerns of a service business

From [[ontara-service-business-meta-modelling-v2|Service Business Meta Modelling (v2)]] §2.1. Five primary concerns plus Activity Awareness (C6) as the cross-cutting dimension connecting them.

|Concern|What it covers|
|---|---|
|**ServiceConcept** (C1)|What value is delivered, to whom, and why it is worth paying for|
|**ActivityModel** (C2)|How value is produced and delivered — processes, pathways, workflows|
|**ResourcePlanning** (C3)|What resources and capabilities are required|
|**FinancialPlanning** (C4)|How money flows — revenue, costs, pricing, projections|
|**GovernanceMapping** (C5)|Regulatory requirements, governance, risk, learning mechanisms|
|**Activity Awareness** (C6)|Cross-cutting: every unit of activity is visible. The common currency connecting all five concerns|

### 2.5 Vertical and horizontal mappings

Mappings between layers and between the two meta models are first-class, visible, navigable objects:

- **Vertical:** `ServiceOffering` (L3) → pathways (L2); `ResourceType` (L3) → platform components (L2); `part def` (L5/L4) → `part` usages (L3/L2) — the coverage matrix; `requirement def` (L4) → `constraint def` → evaluator → audit evidence — the satisfy traceability chain
    
- **Horizontal:** The dual-stack mappings (§2.2) — explicit at every level from ontology through to operational execution
    
- **Pattern mappings:** Pattern (L4) → DomainInstantiation records — 43 typed `ref` relationships across 22 validated patterns
    

### 2.6 Meta model subsetting and templating

A meta model defines the full vocabulary. A specific tenant instantiates only a subset. This is not a gap — it is a legitimate instance that uses only the vocabulary it needs. Two approaches exist as an open design question: constrained subset meta models, or template/profiling (openEHR-style). To be resolved empirically ([[concept-non-constraining|J3]]).

---

## 3. The Ontara Console Vision

The Ontara Console is a web-based frontend providing visual access to the layered architecture. It is the primary tooling surface, built on SvelteKit with Svelte 5 runes, Flowbite Svelte, and Tailwind v4.

### 3.1 What is built

The console currently provides eleven views, all generated from the SysML model via `gen_model_introspection.py` ([[pattern-metadata-driven-generation|D9]]):

|View|Purpose|
|---|---|
|**Coverage Matrix**|Which meta model concepts are instantiated in which domains. Domain filter.|
|**Package Navigator**|Hierarchical exploration of all ~73 packages with doc blocks, part defs, attributes.|
|**Component Catalogue**|Four-quadrant classification (General/Tailored × BMM/BSMM) with domain instantiation status, comprehension layer rendering.|
|**Glossary**|Every defined term with authored + intrinsic comprehension content, weight-aware related concepts with warm-to-cool dot bar. BMM Concern/Layer filtering, search, expand/collapse, cross-links.|
|**Governance**|Traceability from requirements through constraints to satisfaction evidence.|
|**Domain Views**|Per-domain detail pages for [[domain-cafe|
|**Patterns**|22 validated patterns with semantic relationships.|
|**Meta-Model**|Structural overview of the meta model layers.|
|**Weighted Relationship Graph**|D3.js force-directed graph of [[concept-weighted-relationships|

### 3.2 The dual-canvas vision

The longer-term architectural vision is a **dual-canvas construction kit**:

**Business Canvas.** A drag-and-drop surface for composing a business model from modular pieces — instances of Layer 5 concepts. The BMM defines the palette grammar: what component types are available, what attributes they carry, what connections are valid.

**System Canvas.** A corresponding workspace for technology and process components (Layer 4). Shows what has been assigned, what is missing, what is available.

The two canvases are connected by the [[concept-dual-stack-architecture|dual-stack]] horizontal mappings. The PatternCatalogue acts as a recommendation engine, suggesting applicable patterns when components are placed.

### 3.3 Three levels of completeness tracking

|Level|What it tracks|
|---|---|
|1 — Instance coverage|For each meta model concept, which domains instantiate it? The coverage matrix.|
|2 — Pattern coverage|For each validated pattern, which domains exercise it?|
|3 — Meta model adequacy|Vocabulary gaps — when something cannot be expressed.|

### 3.4 Stage 4 and beyond

The [[ontara-stage-4-high-level-plan-2026-03-21|Stage 4 plan]] covers structural navigation and construction in five phases. Phase 1 (weighted relationship graph) is built — D3.js force-directed graph and configuration table operational (Session 72). Graph rendering refinements outstanding. Remaining phases:

2. **Cross-Package Navigation** — deep linking, breadcrumbs, typed ref navigation
    
3. **BMM Concern Group Descriptions** ([[ontara-workflow-emergent-ideas-log|E003]]) — package-level purposive descriptions
    
4. **Structural Completeness Visualisation** — completeness heatmap, gap identification
    
5. **Assembly Workspace Prototype** — configuration builder, the seed of the dual-canvas vision
    

---

## 4. The Generation Pipeline

The generation pipeline is the mechanism by which the model produces the execution layer ([[principle-separation-representation-execution|A1]], [[principle-model-generates-everything|A3]]).

### 4.1 Current generators

Seven operational generators produce artefacts from the SysML model:

|Generator|Output|
|---|---|
|`gen_model_introspection.py`|`model-introspection.json` — the console's data source. Extracts all metadata annotations including `@CatalogueTag`, `@UserFacing`, `@PurposiveDescription`, `@Comprehension`, `@WeightedRelationship`.|
|`gen_concept_graph.py`|6 Mermaid views + Obsidian concept graph|
|`gen_package_hierarchy.py`|Package structure visualisation|
|`gen_system_manifest.py`|`system-manifest.json`|
|`gen_constraint_evaluator.py`|`constraint-evaluators.ts`, `constraint-specs.ts`|
|`gen_decision_table_evaluator.py`|`decision-table-evaluators.ts`|
|`projection_engine.py`|Financial scenario comparison|

### 4.2 The process specification pipeline

The [[ontara-discussion-paper-process-specification-layer|process specification layer]] describes the full pipeline from static business model to running systems. The pipeline crosses from the left stack (business model) to the right stack (business system model) at the compilation step:

Steps 1–7 (intake, classification, BMM population, instantiation, relation binding, process identification, process sketch generation) are business model work on the left side. Steps 8–10 (compilation to Temporal DSL YAML, code generation, deployment) produce system artefacts on the right side. Process archetypes and patterns are business model content — they describe how the business operates; the compiled output becomes part of the [[concept-operational-simulation|operational simulation (L5)]].

### 4.3 Design principles

The pipeline follows a two-phase architecture (designed, partially implemented): Phase 1 generators are model-aware and framework-agnostic, producing domain artefacts + manifest. Phase 2 generators are model-agnostic and framework-aware, producing integration wiring. The four-layer generated code architecture (SysML model → domain artefacts → integration glue → application code) ensures generated layers are freely regenerable while hand-written application code is never overwritten. See [[ontara-discussion-model-two-phase-generation-pipeline-2026-03-13|Two-Phase Generation Pipeline]].

---

## 5. Ontological Grounding

### 5.1 BFO as upper ontology (mandatory)

[[concept-ontology-stack|BFO]] (Basic Formal Ontology, ISO/IEC 21838-2:2021) is the **mandatory** upper ontology for Ontara. Its continuant/occurrent/spatiotemporal framework is structurally identical to the [[concept-coordinate-framework|coordinate framework (A12)]]'s spacetime concept. BFO's "history" (sum of processes in a spatiotemporal region) = coordinate framework's "trajectory". BFO category determines which mathematical operations are meaningful on each axis.

For a [[concept-multi-tenancy|multi-tenant (A13)]], regulated-services platform, a rigorous upper ontology is not optional — it is what ensures that entities across different tenants and domains are categorised consistently and that cross-domain reasoning is semantically grounded.

### 5.2 Mid-level domain ontologies

Between BFO and the meta model vocabularies sit the mid-level ontologies, all BFO-aligned:

- **OGMS** (Ontology for General Medical Science) — for clinical tenants
    
- **IAO** (Information Artifact Ontology) — for information entities across all domains
    
- **OCE** (Ontology of Commercial Enterprises) — for commercial/business entities
    
- **GSSO** (Gender, Sex, and Sexual Orientation ontology) — for [[domain-gsl|GSL]]'s domain
    
- **OBI** (Ontology for Biomedical Investigations) — for clinical investigations
    

These give Ontara's different tenant types their domain-specific semantic grounding. Healthcare tenants use OGMS+IAO; commercial tenants use OCE. Both trace upward to BFO. The BMM is recognised as a de facto BFO-aligned service business mid-level ontology.

### 5.3 OWL 2 DL as ontological formalism (mandatory)

OWL 2 DL is the **mandatory** formalism for Ontara's ontological layers. It provides capabilities that SysML v2 cannot:

- Open-world reasoning and automatic classification
    
- Consistency checking against BFO axioms
    
- Importing existing OBO Foundry ontologies directly (BFO, OGMS, IAO, OBI, GSSO already exist as OWL 2 artefacts)
    
- Multi-axis compositional classification — this _is_ [[concept-coordinate-framework|A12]]
    
- SPARQL semantic querying with full semantic awareness
    
- Formal TBox/ABox separation mapping naturally to the meta model / instance distinction ([[principle-two-meta-model-distinction|A4]])
    

SysML v2 cannot do these things. It is a system design language, not an ontology language. Each formalism does what it is best at. The ontological layers are represented in OWL 2 DL; the meta model and instance layers remain in SysML v2.

### 5.4 The knowledge graph as canonical store ([[concept-knowledge-graph|B22]])

A directional commitment: the [[concept-knowledge-graph|knowledge graph]] (OWL 2 DL in a triple store) can eventually become the **canonical store**, with SysML v2 as an engineering **projection** — provided round-trip translation preserves all aspects of the model without degradation.

This does not violate [[principle-separation-representation-execution|A1]] or [[principle-model-generates-everything|A3]]. The representation remains primary; it is simply that the primary representation is the knowledge graph rather than the SysML files. SysML v2 becomes the engineering _view_ onto the canonical model.

The condition is explicit: **round-trip fidelity**. If translating from knowledge graph to SysML and back degrades any aspect of the model, the knowledge graph is not yet ready to be canonical. This is a directional commitment, not a binding decision.

### 5.5 The mapping ontology ([[ontara-ref-master-register|B24]])

A formal [[ontara-ref-master-register|mapping ontology (B24)]] expressed in OWL declares how SysML v2 elements correspond to ontological classes: SysML blocks/parts ↔ OWL classes; SysML relationships ↔ OWL object properties; SysML value types ↔ OWL datatype properties. The openCAESAR project's OWL 2 DL ontology for SysML v2 may provide bridge infrastructure. Design deferred but existence committed.

### 5.6 Persistence

The ontological layers persist in a **triple store / graph database** (candidates: Blazegraph, GraphDB, Stardog, Jena/Fuseki). Named graphs provide the infrastructure for [[concept-coordinate-space-snapshots|coordinate space snapshots (L8)]]. Adding a new axis to the coordinate space is adding triples with a new predicate — no schema migration required.

---

## 6. Simulation Architecture

Session 73 produced a conceptually designed simulation architecture comprising five interrelated concepts.

### 6.1 The operational simulation ([[concept-operational-simulation|L5]])

The [[concept-operational-simulation|operational simulation]] is the BSMM made live: a continuously running simulation of the business per tenant, coordinated by Temporal workflows, state management, and event streams. Human actors and connected applications are **participants** — the workflow assigns tasks, waits for completion, and receives outcomes. The human is inside the loop.

All execution maps upward through SysML to the ontology layer, preserving unified semantic coherence. The system can say not just "workflow X completed step 3" but "the resource allocation process for room assignment in a Standard Groom service completed successfully" — because the model lineage is preserved end to end. This is [[principle-model-generates-everything|A3]] made operational at runtime.

### 6.2 The reflective simulation ([[concept-reflective-simulation|L6]])

The [[concept-reflective-simulation|reflective simulation]] is a cross-cutting meta-knowledge capability on the right side of the [[concept-dual-stack-architecture|dual stack]]. It reads from every layer of the architecture — the knowledge graph (to know what things _are_), the instance layers (to know what exists), the operational simulation (to know what is happening now), the rule/constraint layer (to know the boundaries), and the terminology layer (for clinical tenants). It writes guidance and insight to the business operator, and derived knowledge (trajectories, anomaly records, projections) back to the knowledge graph as persistent self-knowledge.

The reflective simulation does **not** exercise directive control. It is advisory, not authoritative — consistent with [[principle-deterministic-over-probabilistic|A6]].

### 6.3 Valence ([[concept-valence|L7]])

[[concept-valence|Valence]] is the system's representation of what the business operator considers good vs bad performance. It transforms the reflective simulation from descriptive ("utilisation is at 95%") to evaluative ("utilisation is at 95%, which is in the danger zone for service quality given your stated priorities"). Valence is declared by the operator as goal states and desirability criteria. The representation mechanism is an open design question.

### 6.4 Coordinate space snapshots ([[concept-coordinate-space-snapshots|L8]])

The reflective simulation persists and operates over multiple states of the business model as snapshots in the [[concept-coordinate-framework|coordinate space (A12)]], differentiated by [[concept-epistemic-modality|epistemic status (B17)]]:

|Snapshot type|Epistemic status|What it represents|
|---|---|---|
|**Current state**|Actual|Live, continuously updated by the operational simulation|
|**Historical states**|Past-actual|Timestamped past snapshots enabling trajectory computation|
|**Goal states**|Intentional|Declared targets — the operator's definition of desirable. Valence anchors|
|**Hypothetical states**|Counterfactual|"What if" snapshots under altered conditions|
|**Projected states**|Extrapolated|Best estimate of where the business is heading given current trajectories|

All five types are points or trajectories in the **same coordinate space**. Snapshots persist in the knowledge graph as named graphs tagged with epistemic status, timestamp, and provenance.

### 6.5 Goal-seeking computation ([[concept-goal-seeking-computation|L9]])

Given a current state and a goal state (both [[concept-coordinate-space-snapshots|coordinate space snapshots]]), search for an action sequence — drawn from the process archetype library (the [[ontara-discussion-paper-process-specification-layer|process specification layer]]) — that moves the business from one to the other. The rule and constraint layer governs which paths are permissible; the reflective simulation evaluates which are preferable via [[concept-valence|valence]]. Constraint satisfaction over the coordinate space — where CLP(FD) and the constraint layer intersect with the reflective simulation.

---

## 7. The Comprehension Architecture

The comprehension architecture is the major achievement of Sessions 45–58. It addresses the question: how does the system know what it contains, why it is structured that way, and how to explain itself?

### 7.1 The intrinsic self-knowledge principle ([[principle-intrinsic-self-knowledge|A10]])

The system's explanations are dynamically computed from live model state, not stored as static text. Self-knowledge is not painted on or bolted on — it is intrinsic.

The dividing-line test: if the model changes and no human edits a description, does the explanation become wrong? If yes, that content must be intrinsic.

The [[concept-dual-stack-architecture|dual-stack architecture]] extends A10 from design-time to runtime: the [[concept-reflective-simulation|reflective simulation (L6)]] is A10 applied to the running business, not just to the model.

### 7.2 The three-register model

|Register|Content|Source|Status|
|---|---|---|---|
|**Register 1: Authored**|Human-written purposive descriptions — why an element exists and what it does|`@PurposiveDescription` metadata in SysML|Complete. 28/28 coverage.|
|**Register 2: Structural**|Facts the model already knows — type, relationships, containment, patterns, domain instantiations|Dynamically derived via `@Comprehension` metadata traversal schema|Complete. 28/28 coverage. Generator traversal discovery engine operational.|
|**Register 2+: Inferential**|Derived explanations that go beyond what any single element states — analogies, gap analysis, impact propagation|Computed from [[concept-weighted-relationships|weighted relationships]], cross-domain comparison, structural analysis|

### 7.3 Weighted relationships ([[concept-weighted-relationships|B14]])

79 `@WeightedRelationship` annotations across 27 weighted elements (27 strong, 50 moderate, 2 weak). AuditEvidenceRecord is a pure receiver with zero outgoing weights.

Relationships are directional and non-commutative: the weight on A → B answers "if A changes, how much does B need reassessment?" The reverse B → A is independently assessed. Weights do not net off, average, or combine. Five inductively established heuristics (H1–H5) govern weight assignment. See [[ontara-ref-weighted-relationship-heuristics-and-config|heuristics and configuration reference]] and [[ontara-ref-weighted-relationship-directionality-definition|directionality definition]].

The weight model supports three interpretive frames: costs/preferences, fuzzy human judgements, and probabilities (the latter for clinical decision support).

### 7.4 The unity principle ([[principle-unity-principle|A11]])

One weighted relationship model informs comprehension, reasoning, simulation, governance, and assembly guidance. No separate, disconnected knowledge structures. The factors bearing on explanatory descriptions must be the same factors bearing on projections, question-answering, prediction, risk assessment, simulation, and governance activities. The same [[concept-coordinate-framework|coordinate space]], [[concept-weighted-relationships|weight model]], and [[concept-valence|valence]] definitions inform all capabilities.

### 7.5 Reasoning formalisms (M7)

Three formalisms are identified as relevant to Ontara's weighted reasoning needs: semiring soft-constraints (optimisation/trade-offs), fuzzy MCDM (human judgements/stakeholder preferences), and Probabilistic Soft Logic (graded business rules with truth values in [0,1]). Clinical decision support may additionally use Bayesian reasoning. These are research directions — current work must not foreclose any option ([[concept-non-constraining|J3]]). See [[ontara-discussion-intrinsic-self-knowledge-v2-2026-03-20|Intrinsic Self-Knowledge discussion]] §4.4.

---

## 8. Foundational Architecture

Session 59 produced four discussion papers that establish a candidate foundational layer. Sessions 73–74 advanced several of these from directional to binding status.

### 8.1 The coordinate framework ([[concept-coordinate-framework|A12]], T1 candidate)

The system's representational space is a multi-dimensional coordinate space, not a hierarchy. Every conceptual entity traces a trajectory through this space. Vectors describe rate and direction of change along axes. Regions define governance constraints, therapeutic ranges, financial thresholds. Projections and transformations relate different coordinate systems.

The coordinate system test: "Can I add a new axis without refactoring?"

Existing console features — coverage matrix, component catalogue, glossary, governance traceability — are projections of the same coordinate space. The [[concept-coordinate-space-snapshots|coordinate space snapshots (L8)]] make this operational at runtime. See [[ontara-discussion-coordinate-framework-2026-03-22_1|Coordinate Framework discussion]].

### 8.2 Domain identity ([[concept-domain-identity|B15]])

Domain is not currently a first-class concept in the architecture — identity is distributed across five ungoverned representations. Proposed: `DomainDefinition` part def in Foundation with canonical properties. Includes four-tier `RegulatoryTier` enum (generallyGoverned, lightlyRegulated, partiallyRegulated, sectorRegulated). See [[ontara-discussion-domain-identity-architecture-2026-03-22-v2.1|Domain Identity discussion]].

### 8.3 Temporal reference frames ([[concept-temporal-reference-frames|B16]])

Different parts of the system experience time in different reference frames. Eight illustrative frames identified: clinical episode time, business planning time, regulatory reporting time, pathway step time, system execution time, audit/evidence time, patient biographical time, research/population time. Vague temporal vocabulary ("after stabilisation", "when appropriate") is a first-class concern, not a defect to be eliminated.

[[concept-epistemic-modality|Epistemic modality (B17)]]: every event carries an epistemic status (actual, inferred, expected, predicted, hypothetical, simulated, retrospectively recorded) that determines reasoning and governance obligations. Now operationalised through [[concept-coordinate-space-snapshots|coordinate space snapshots (L8)]]. See [[ontara-discussion-temporality-reference-frames-2026-03-22-v2.1|Temporality discussion]].

### 8.4 Ontological grounding

Covered in detail in [[#5. Ontological Grounding]] above. BFO is now mandatory (upgraded from directional, Session 73). OWL 2 DL is mandatory. These represent the most significant status changes in the foundational layer since Session 59.

---

## 9. Demonstrator Domains

### 9.1 Rationale

Demonstrator domains serve two purposes ([[concept-cross-domain-validation|J1]]):

1. **Cross-domain validation.** Three structurally different businesses validate that the BMM vocabulary generalises.
    
2. **Pedagogical anchoring.** Concrete illustrations that make abstract concepts tangible.
    

### 9.2 The domains

|Domain|Character|Regulatory tier|BMM coverage|
|---|---|---|---|
|[[domain-cafe\|Cafe]]|Immediate retail — per-item pricing, walk-in, 2-minute cycle|Generally governed|Full model + running application (22 validated patterns)|
|[[domain-suds\|Suds]]|Batch processing — weight/type pricing, batch turnaround, item tracking|Lightly regulated|Full BMM + COSHH governance traceability chain|
|[[domain-paws\|Paws]]|Appointment-based personal service — per-appointment pricing, breed/size surcharges, persistent client/animal identity|Lightly regulated|General vocabulary only; ServiceSubject + ServiceParticipant instantiated|

### 9.3 GSL's relationship to the demonstrators

Under [[concept-multi-tenancy|A13]], GSL is the most important tenant — but still a tenant. Its distinction is purpose (production healthcare delivery) and regulatory tier (sector-regulated). GSL is the eventual production target; the demonstrators validate the meta model generalises before GSL-specific complexity is introduced.

---

## 10. Governing Principles

The [[ontara-ref-master-register|master concept register]] is the comprehensive inventory (~180 concepts across four tiers). The ten Tier 1 governing principles (plus two T1 candidates) are:

|#|Principle|One-line test|
|---|---|---|
|[[principle-separation-representation-execution\|A1]]|Separation of representation and execution|Changes happen in representation and propagate to execution, never the reverse|
|[[principle-self-describing-system\|A2]]|Self-describing system|The system knows what it is, what it is doing, why, and what rules govern it|
|[[principle-model-generates-everything\|A3]]|Model generates everything|SysML v2 is the single source of truth|
|[[principle-two-meta-model-distinction\|A4]]|Two meta model distinction|BMM and BSMM are distinct, connected by explicit mappings|
|[[principle-deterministic-over-probabilistic\|A6]]|Deterministic/auditable reasoning|Clinical decisions use inspectable logic|
|[[principle-discipline-as-load-bearing-structure\|A9]]|Discipline as load-bearing structure|Disciplined practices propagate reliability; regression applies to practices, not just code|
|[[principle-intrinsic-self-knowledge\|A10]]|Intrinsic self-knowledge|System explanations are dynamically computed from live model state|
|[[principle-unity-principle\|A11]]|Unity principle|One weighted relationship model informs all subsystems|
|[[concept-co-evolution\|J2]]|Co-evolution|No modelling without the tool that makes it legible; no tool without model content|
|[[concept-non-constraining\|J3]]|Non-constraining|Decisions should not foreclose future development paths|
|[[concept-coordinate-framework\|A12]]|Coordinate framework _(T1 candidate)_|The representational space is a multi-dimensional coordinate space; can I add a new axis without refactoring?|
|[[concept-multi-tenancy\|A13]]|Multi-tenancy _(T1 candidate)_|Only the meta model is core; every domain is a tenant instantiation|

### 10.1 Development methodology principles

|Principle|Summary|
|---|---|
|[[concept-cross-domain-validation\|J1]]|Every concept/pattern validates in at least two domains|
|[[concept-co-evolution\|J2]]|Model and tooling advance together|
|[[concept-non-constraining\|J3]]|Decisions should not foreclose future development paths|
|[[concept-retrospective-bootstrapping\|J10]]|After each step, ask: how could our own tooling have made that easier?|
|[[concept-design-decision-lifecycle\|J12]]|Freedom → experimentation → discovered convention → opinionated configuration → revisable|
|[[concept-inception-capture\|J13]]|Ideas captured immediately with full fidelity at the moment of recognition|

---

## 11. Architecture Carried Forward

The following architectural commitments, established in foundational papers, remain in force. They are not restated in full — the authoritative sources are referenced.

- **From [[ontara-platform-architecture-principles-v2|Architecture Principles (v2)]]:** Separation of representation and execution ([[principle-separation-representation-execution|A1]]). Self-describing system ([[principle-self-describing-system|A2]]). openEHR as clinical data architecture. Clinical governance as first-class concern ([[principle-clinical-governance-first-class|A8]]). IG and cybersecurity as foundational modelling concern ([[ontara-ref-master-register|B20]]).
    
- **From [[ontara-service-business-meta-modelling-v2|Service Business Meta Modelling (v2)]]:** Two distinct meta models ([[principle-two-meta-model-distinction|A4]]). Five concerns (C1–C5). Activity awareness (C6). Scenario modelling and operational steering (F5). Simulation capability (L1–L4, now conceptually designed as L5–L9).
    
- **From [[ontara-platform-sysml-modelling-strategy-v2|SysML Modelling Strategy (v2)]]:** SysML v2 as single source of truth ([[principle-model-generates-everything|A3]]). Concentric rings of rigour. Model should earn its keep (J4). Three-tier reasoning stack ([[principle-deterministic-over-probabilistic|A6]]).
    
- **From the PatternCatalogue:** 22 validated patterns, 8 principles, 43 semantic relationships.
    
- **From [[ontara-discussion-model-self-service-enabling-architecture-2026-03-14|Self-Service Enabling Architecture]]:** Enabling architecture (A7). Agency classification ([[concept-agency-classification|H2]]). CoPHR heritage (H4). Four-generation roadmap (H3). Clinical authority problem (H5).
    
- **From the Knowledge Layer:** Five-layer SystemStateAssessment (F1). Constraint evaluation pattern (F2). Tau Prolog for Tier 2 reasoning (F6). Three remediation categories (F4).
    
- **From [[ontara-discussion-service-participation-model-2026-03-21|Service Participation Model]]:** ServiceSubject and ServiceParticipant as sibling General BMM concepts. Participation as a framework with open roles.
    
- **From [[ontara-discussion-dual-stack-architecture-2026-03-26|Dual-Stack Architecture]]:** The architectural framework described in §2.2 and §5–6 of this document. Binding decisions on BFO and OWL 2 DL. Directional commitment on knowledge graph as canonical store.
    

---

## Related Documents

- [[ontara-ref-strategic-snapshot|Strategic Reference]] — comprehensive orientation: current state, scale, what's next
    
- [[ontara-ref-master-register|Master Concept Register]] — ~180 concepts across four tiers
    
- [[ontara-workflow-development-guide|Development Workflow Guide (v2)]] — the shared operating agreement
    
- [[ontara-guide-claude-tooling-2026-03-23|Claude Tooling Guide]] — Claude Chat, Code, Cowork allocation
    
- [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]] — 14 entries (E001–E014)
    
- [[Ontara Architecture Papers Index|Architecture Papers Index]] — curated reading order for all architecture documentation
    
- [[Concept Graph Index]] — the navigable concept graph
    
- [[ontara-platform-architecture-principles-v2|Architecture Principles (v2)]]
    
- [[ontara-service-business-meta-modelling-v2|Service Business Meta Modelling (v2)]]
    
- [[ontara-platform-sysml-modelling-strategy-v2|SysML Modelling Strategy (v2)]]
    
- [[ontara-discussion-dual-stack-architecture-2026-03-26|Dual-Stack Architecture Discussion Paper]]
    
- [[ontara-discussion-paper-process-specification-layer|Process Specification Layer Discussion Paper]]
    
- [[ontara-discussion-intrinsic-self-knowledge-v2-2026-03-20|Intrinsic Self-Knowledge Discussion]]
    
- [[ontara-discussion-coordinate-framework-2026-03-22_1|Coordinate Framework Discussion]]
    
- [[ontara-discussion-domain-identity-architecture-2026-03-22-v2.1|Domain Identity Discussion]]
    
- [[ontara-discussion-temporality-reference-frames-2026-03-22-v2.1|Temporality and Reference Frames Discussion]]
    
- [[ontara-discussion-ontological-grounding-2026-03-22|Ontological Grounding Discussion]]
    
- [[ontara-stage-4-high-level-plan-2026-03-21|Stage 4 High-Level Plan]]
    

---

_Vision and architecture reference v3, written 27 March 2026 (Session 75). Replaces [[SUPERSEDED-ontara-ref-vision-architecture-v2-s62|v2]] (Session 62). Staleness threshold: 10 sessions or major architectural decision._