---
tags:
  - architecture
  - foundations
date: 2026-04-06
status: current
session: 154
---
# Ontara — Platform Modelling Strategy
> `= this.file.path`

**Purpose:** The modelling strategy for the Ontara platform — why SysML v2, how the model is structured, what it generates, how the ontological formalism complements it, and the principles that govern modelling decisions. This document is one of three foundations papers; the others are [[ontara-architecture-platform-principles|Architecture Principles]] and [[ontara-architecture-business-meta-modelling|Service Business Meta Modelling]].
**Audience:** The project founder, development collaborators, and technically capable readers seeking to understand the modelling approach and its rationale.
**Status:** Standing reference document. Uses a stable filename — versioning is expressed here, not in the filename.
**Staleness threshold:** 15 sessions or major architectural changes.

### Version History

| Version | Session | Date | Summary of changes |
|---|---|---|---|
| v4 | 154 | 6 April 2026 | Major refresh incorporating 58 sessions of development (S96–S154). OWL 2 DL knowledge graph implemented (12-file stack, 43-query SPARQL suite, HermiT consistency, round-trip diff); `@BfoType` annotation (34/34); OWL pipeline and KG tooling in generation pipeline; deontic governance vocabulary and CQC MVP; domain identity implemented (dual-stack split); reasoning metamodel (26 OWL classes, evidence architecture, three-way constraint hierarchy); A6 reformulated as four-category scheme; A13 promoted to binding T1; PROV-O platform-level import; comprehension–reasoning convergence; console 13 views; Ears outlined; register ~212 concepts across 16 sections (A–P) |
| v3 | 96 | 1 April 2026 | BSMM→SMM terminology; [[concept-stakeholder-model\|StakeholderModel]] sixth concern (34 elements, 96 weights); package count 11→12 (ArchitecturalStructure); `@ArchitecturalLocation` annotation; console 12 views; dual-stack and simulation in forward direction; stale wikilinks fixed. Archived as [[SUPERSEDED-ontara-architecture-platform-modelling-strategy-v3-s96\|v3 (Session 96)]] |
| v2 | 65 | 24 March 2026 | Full revision. Archived as [[SUPERSEDED-ontara-platform-modelling-strategy-v2-s65\|v2 (Session 65)]] |
| v1 | ~8 | 4 March 2026 | Original. Archived as [[SUPERSEDED-ontara-platform-sysml-modelling-strategy-v1\|v1]] |

---

## Contents

- [[#1. Executive Summary|§1. Executive Summary]]
- [[#2. Background and Context|§2. Background and Context]]
- [[#3. The Case for Comprehensive Modelling|§3. The Case for Comprehensive Modelling]]
- [[#4. Modelling Value Across the Business|§4. Modelling Value Across the Business]]
- [[#5. Mapping Legacy Artefacts to SysML v2|§5. Mapping Legacy Artefacts to SysML v2]]
- [[#6. Knowledge, Decision Support, and Reasoning|§6. Knowledge, Decision Support, and Reasoning]]
- [[#7. The Two Meta Models and Package Architecture|§7. The Two Meta Models and Package Architecture]]
- [[#8. The Annotation and Metadata System|§8. The Annotation and Metadata System]]
- [[#9. Structural Principles for the Model|§9. Structural Principles for the Model]]
- [[#10. The Generation Pipeline|§10. The Generation Pipeline]]
- [[#11. The Two Formalisms|§11. The Two Formalisms]]
- [[#12. Current State and Forward Direction|§12. Current State and Forward Direction]]
- [[#13. Summary|§13. Summary]]

---

## 1. Executive Summary

SysML v2 and OWL 2 DL serve as the complementary modelling foundations for the [[ontara-project-map|Ontara]] platform. SysML v2 is the [[principle-model-generates-everything|single source of truth (A3)]] for structural and behavioural content — what a service business is, how it works, what rules govern it. OWL 2 DL is the mandatory formalism for the ontological layers — formal classification, consistency checking, semantic querying, and the knowledge graph that provides the platform's reasoning and governance infrastructure.

This dual-formalism approach was not the starting point. The strategy was first articulated in March 2026, immediately after the [[domain-cafe|Coffee Shop Demonstrator]] validated the core thesis: that a SysML v2 model can generate both executable workflows (Temporal) and governance documentation from a single source. Session 73 introduced the binding commitment to OWL 2 DL alongside SysML v2, recognising that each formalism does what the other cannot. Since then the modelling approach has matured substantially:

- Two distinct meta models are explicit ([[principle-two-meta-model-distinction|A4]]): a **Business Meta Model** (what a service business *is* — 36 `part def`s + 2 `requirement def`s across six concerns, plus `DomainIdentity` and `DomainConfiguration` in Foundation::DomainRegistry) and a **System Meta Model** (how a business system *works* — renamed from BSMM, Session 92; first SMM-side model content via [[concept-architectural-section|ArchitecturalSection]], Session 87; extended by the [[ontara-discussion-institutionalised-reasoning-2026-04-05|reasoning metamodel]], Stage 7).
- Four demonstrator domains ([[concept-cross-domain-validation|J1]]) validate that the BMM vocabulary generalises: Cafe (immediate retail), [[domain-suds|Suds]] (batch processing), [[domain-paws|Paws]] (appointment-based personal service), and [[domain-ears|Ears]] (community ear care — outlined, sector-regulated).
- A **comprehension architecture** enables the system to explain itself — authored purposive descriptions, dynamically derived structural self-knowledge, and weighted relationships expressing interaction strength between concepts ([[principle-intrinsic-self-knowledge|A10]], [[principle-unity-principle|A11]]). The inferential register has converged with the reasoning metamodel's evidence architecture (S147-D7).
- An **annotation system** (`@CatalogueTag`, `@UserFacing`, `@PurposiveDescription`, `@Comprehension`, `@WeightedRelationship`, `@ArchitecturalLocation`, `@BfoType`) makes every model element self-describing, ontologically classified, and machine-queryable.
- The **OWL 2 DL knowledge graph** is operational: 12-file ontology stack, 43-query SPARQL validation suite, HermiT consistency checking, round-trip diff engine (288 semantic units). Hand-authored vocabulary modules for governance, domain identity, and reasoning complement the pipeline-generated BMM ontology.
- The [[ontara-ref-vision-architecture|Ontara Console]] provides 13 navigable views over the model, including the interactive 3D WebGL weighted relationship graph, the spatial visual architecture map, and the Ontology view with BFO hierarchy and KG Status panel.
- The **[[ontara-discussion-institutionalised-reasoning-2026-04-05|reasoning metamodel]]** (Stage 7, Sessions 146–152) provides 26 OWL classes covering reasoning contexts, evidence architecture (SEPIO pattern), a three-way constraint hierarchy, and structured probabilistic reasoning — formalising what was previously a research direction.

The package structure contains 12 top-level packages (~74 packages total), with ~212 concepts tracked across 16 register sections (A–P). The [[concept-multi-tenancy|multi-tenancy principle (A13)]] — promoted to binding Tier 1 in Session 142 — establishes that every domain is a tenant instantiation, with domain identity now structurally expressed across SysML, OWL, and the generation pipeline.

The modelling philosophy remains unchanged: the model is a large sheet of paper on which areas of key relationships and concepts are pencilled in at varying levels of detail. Clinical pathways occupy the inner ring of maximum rigour and full generation. Supporting infrastructure occupies a middle ring of structural clarity. Business context occupies an outer ring of architectural documentation. The model earns its keep ([[concept-model-earns-its-keep|J4]]) by generating something or making a non-obvious relationship visible — if modelling something merely restates the obvious, that is a signal to stop.

---

## 2. Background and Context

### 2.1 The Coffee Shop Demonstrator

The Coffee Shop Action Flow Demonstrator was completed in early March 2026. It validated the core thesis that a SysML v2 model can generate both Temporal workflows (for durable process execution) and visual pathway diagrams (for governance documentation) from a single source of truth. Four phases were completed: Temporal foundation (hand-coded workflow), generation (SysML-to-code pipeline), integration (XState lifecycle enforcement with a SvelteKit web UI), and governance outputs (pathway diagrams and compliance audit tables). All exit criteria were met.

The demonstrator has since matured into a full-stack reference application (9 frontend pages, 19 API routes, Temporal workflows, XState v5 lifecycle enforcement, EHRbase CDR integration with 3 archetypes, PostgreSQL persistence) and the reference domain for the [[ontara-validated-architectural-patterns|22 validated architectural patterns]] in the PatternCatalogue. It remains the standing practice ([[pattern-coffee-shop-demonstrator|D21]]) for validating new architectural capabilities in a simple domain before clinical application.

Key architectural decisions validated by the demonstrator include Temporal for process orchestration, XState for entity lifecycle enforcement, a [[pattern-two-layer-action-flow|two-layer action flow (D6)]] architecture separating domain-level process description from orchestration-level execution detail, and [[pattern-metadata-driven-generation|metadata-driven generation (D9)]] using SysML v2 metadata definitions as first-class annotation mechanisms.

### 2.2 Prior Analytical Work

Significant business analysis and systems design work was undertaken across multiple projects prior to the current programme, most notably the SHC/MedMind online private GP-led mental health service (2018). This work produced detailed artefacts including UML use case diagrams, BPMN 2.0 process maps, a top-level five-phase patient journey model (Acquisition, Registration, Assessment, Treatment, Follow Up), UML class diagrams mapping technology components, and detailed data object catalogues.

While the clinical domain has shifted from general mental health to gender-affirming healthcare, and the technology choices have evolved significantly, the structural thinking transfers directly. The five-phase patient journey arc, the use case decomposition approach, the identification of data objects within process flows, and the technology capability mapping all provide valuable input to the SysML v2 model. §5 describes how each legacy artefact type maps to SysML v2.

### 2.3 The Architecture Principles

The [[ontara-architecture-platform-principles|Architecture Principles (v4)]] paper establishes the foundational commitments. The most important is the [[principle-separation-representation-execution|separation of the representation layer from the execution layer (A1)]]: the representation layer (SysML model, OWL ontologies, openEHR archetypes, decision logic, governance requirements, comprehension metadata) is where knowledge lives; the execution layer (Temporal workflows, XState machines, EHRbase CDR, GraphDB, front-end applications, the Ontara Console) is where things happen. Execution consumes representation but does not define it. When anything needs to change, the change happens in the representation layer and propagates to execution via the generation pipeline.

### 2.4 Modelling Philosophy

The approach to comprehensive modelling is informed by several factors. There is a strong preference, rooted in long experience and reinforced by the designer's cognitive style, for delimiting the working space from the top down to avoid the psychological concern that something unconsidered lies off the map. This brings the acknowledged risk of mission creep and over-complication, but this risk is managed by adopting suitable levels of abstraction from the top down. Not every area requires the same depth of modelling; the discipline is in choosing the right level for each area and resisting the urge to elaborate prematurely.

The analogy is a large sheet of paper on which areas of key relationships and concepts are pencilled in. More or less detail can be added at different abstraction layers as appropriate. The sheet is not a blueprint for building everything from scratch; it is a map that makes assumptions and scope explicit, identifies relationships and dependencies, and ensures that when detailed work begins in any area, its context within the whole is understood.

This philosophy connects directly to [[concept-non-constraining|J3 (non-constraining architecture)]]: the model structure permits elaboration without requiring it. Packages can remain lightweight placeholders for years. The architecture does not force premature commitment.

---

## 3. The Case for Comprehensive Modelling

### 3.1 A Self-Describing System

The conventional framing of system modelling is to model the system so it can be built. The Ontara framing is subtly different and more powerful: model the system so it can explain itself ([[principle-self-describing-system|A2]]). This means that reporting on activity, decision logic, structural semantics, constraints, governance, entity and relationship ontologies, and similar features are all first-class citizens of the environment, not afterthoughts added later.

A system designed from the ground up with these properties is intrinsically self-describing. It knows what it is, what it is doing, why it is doing it, and what rules govern it, because all of that is encoded in the model that generates and drives it. Meeting business needs, including regulatory and governance requirements, becomes much more straightforward when the system can produce its own evidence rather than requiring manual documentation and audit processes.

### 3.2 The Comprehension Architecture

The [[ontara-discussion-comprehension-architecture-2026-03-19|comprehension architecture]] (Sessions 45–58) extends the self-describing principle into a full architectural concern ([[concept-comprehension-layer|I14]]). Three registers of content provide the answer to how the system knows what it contains:

| Register | Content | Source | Status |
|---|---|---|---|
| **Authored** | Human-written purposive descriptions — why an element exists and what it does | `@PurposiveDescription` metadata in SysML | Complete. 34/34 BMM coverage; 20/20 architectural section coverage. |
| **Structural** | Facts the model already knows — type, relationships, containment, patterns, domain instantiations | Dynamically derived via `@Comprehension` metadata traversal schema | Complete. 34/34 BMM coverage. |
| **Inferential** | Derived explanations beyond what any single element states — analogies, gap analysis, impact propagation | Converged with the reasoning metamodel's evidence architecture (S147-D7): the SEPIO+PROV-O evidence architecture in `ontara-reasoning.ttl` provides the OWL infrastructure for Claims, EvidenceLines, and ConfidenceAssessments | Vocabulary implemented. Runtime engines are future work. |

The [[principle-intrinsic-self-knowledge|intrinsic self-knowledge principle (A10)]] governs the boundary: if the model changes and no human edits a description, does the explanation become wrong? If yes, that content must be intrinsic — dynamically computed from live model state, not stored as static text.

96 `@WeightedRelationship` annotations across 33 weighted elements express the strength of interaction between BMM concepts. These relationships are directional and non-commutative. Weighted relationships now have OWL representation: 96 reified individuals in `ontara-bmm-weights.ttl` (702 triples). The [[principle-unity-principle|unity principle (A11)]] commits the platform to a single weighted relationship model informing comprehension, reasoning, simulation, governance, and assembly guidance — empirically validated by the comprehension–reasoning convergence (S147-D7).

### 3.3 Regulatory and Governance Implications

For a regulated clinical service, the self-describing property has concrete and significant implications:

**CQC and clinical governance.** The system can answer questions such as "show me the defined pathway for hormone therapy initiation, show me every instance where a patient deviated from that pathway, and show me the decision logic applied at each deviation point" with full traceability to the model. The deontic governance vocabulary (Sessions 121–131) extends this: governance obligations are formally represented in OWL with deontic modalities (Obligation, Prohibition, Permission, RegulatoryPower), traced to normative instruments, and connected to the reasoning metamodel's constraint hierarchy. The CQC Governance MVP (Session 131) demonstrated this with 21 individuals formalising CQC Regulation 12 (Safe Care and Treatment).

**Clinical risk management.** DCB0129/DCB0160 require demonstration that clinical systems behave as specified and that hazards can be traced through the system. When the SysML model that defines the pathway is the same artefact that generates the running code, the traceability gap that plagues most clinical software largely disappears.

**Indemnity and defensibility.** A practice that can demonstrate formally defined clinical processes, system enforcement of those processes, and complete audit trails showing conformance presents a materially stronger risk profile to indemnifiers.

**Business intelligence.** If every process, decision, entity state transition, and constraint evaluation is modelled and tracked, then operational questions (average referral-to-appointment time, pathway bottlenecks, patients awaiting lab results) are queries over existing event history rather than separate analytics pipelines.

**Information governance and cybersecurity.** IG and cybersecurity are foundational modelling concerns (B20) that start at the representation layer, not implementation details bolted on afterwards. Data classification, trust boundaries, consent frameworks, and audit requirements are modelled alongside the business processes they govern.

### 3.4 Why SysML v2 Specifically

SysML v2 is preferred over alternative modelling approaches (separate UML, BPMN, and diagramming tools) because it provides a single semantically typed model. A dependency in a diagram is just a line. A `satisfy` relationship in SysML v2 means something specific: this element satisfies that requirement, and a tool can trace, validate, and report on it.

The 2018 SHC work used three separate formalisms (use case diagrams for purpose, BPMN for process, UML class diagrams for technology structure) that could not reference each other formally. SysML v2 closes all of these gaps by providing a unified model where structural elements, behavioural elements, requirements, constraints, and metadata all participate in a single queryable, generatable knowledge structure.

Critically, SysML v2 also supports the metadata annotation mechanism that underpins the entire comprehension architecture and generation pipeline: `metadata def` and metadata usage (`@`) provide a typed, model-native way to attach generation hints, comprehension schemas, user-facing descriptions, catalogue tags, BFO classifications, and weighted relationships to any model element.

### 3.5 Why OWL 2 DL Alongside SysML v2

Session 73 established OWL 2 DL as the mandatory ontological formalism (B23), recognising capabilities that SysML v2 cannot provide: open-world reasoning and automatic classification; consistency checking against BFO axioms; importing existing OBO Foundry ontologies directly (BFO, OGMS, IAO, PROV-O already exist as OWL artefacts); multi-axis compositional classification — this *is* the [[concept-coordinate-framework|coordinate framework (A12)]]; SPARQL semantic querying with full semantic awareness; and formal TBox/ABox separation mapping naturally to the meta model/instance distinction ([[principle-two-meta-model-distinction|A4]]).

Each formalism does what it is best at. The ontological layers (BFO, mid-level ontologies, platform vocabularies) are represented in OWL 2 DL; the meta model and instance layers remain in SysML v2. A mapping ontology (B24) bridges the two formalisms, concretely realised as the correspondence graph. Authority zones ([[concept-authority-zones|B29]]) govern which formalism is authoritative for which content. See §11 for detail on the two-formalism architecture.

---

## 4. Modelling Value Across the Business

The value proposition of SysML v2 modelling varies across different parts of the business. This section categorises areas by the strength of the model-to-execution pipeline.

### 4.1 Strong Model-to-Execution Value

These are areas where the Coffee Shop Demonstrator patterns apply directly and the modelling investment generates executable code, governance documentation, or both.

**Clinical pathway orchestration.** Each clinical pathway maps to a SysML v2 action flow at the domain layer, generates a Temporal workflow at the orchestration layer, and produces visual pathway diagrams and compliance audit tables for governance.

**Entity lifecycle management.** Every entity with state (patient, episode, consultation, prescription, referral, lab result, booking, payment, support ticket) can be modelled as a SysML state machine, enforced by XState at runtime, and audited. Invalid transitions are rejected regardless of what application code requests.

**Service contracts and interfaces.** The interfaces between platform subsystems can be modelled as SysML v2 ports and generate TypeScript types or API schemas.

**Requirements and constraints traceability.** Clinical governance requirements, CQC obligations, data protection constraints, and safeguarding policies are modelled as SysML requirements with `satisfy`/`verify` relationships to system elements, enabling cross-cutting compliance queries. This is the [[principle-clinical-governance-first-class|satisfy traceability chain (A8)]].

**Ontological classification.** The `@BfoType` annotations on all 34 BMM elements (Session 99) feed the OWL pipeline, producing correctly parented OWL classes in the knowledge graph. This enables semantic querying, consistency checking, and cross-domain reasoning that SysML alone cannot provide.

**Business meta model coverage.** The 34+ BMM elements describe the structural anatomy of any service business. The generation pipeline extracts these into both the Ontara Console (Coverage Matrix, Component Catalogue, Glossary) and the knowledge graph (34 OWL classes, 14 object properties, 96 reified weighted relationship individuals).

**Comprehension metadata.** The annotation system is generated into both the console and the knowledge graph, providing self-describing content for every model element across both representations.

### 4.2 Valuable Modelling with Partial Execution

These are areas where the model provides significant structural design value and some generation is feasible, but the model does not generate complete implementations.

**Business operations processes.** Processes such as contract approval, invoice lifecycle, and complaint handling are structurally identical to clinical pathways and could drive Temporal workflows. The model defines the process; some execution can be generated; but the complete implementation includes integrations with tools like Xero that the model does not replace.

**Forms and questionnaires.** The structure of clinical forms (fields, validation rules, conditional logic, data mappings) is highly amenable to SysML modelling. Generation of form definitions from the model is feasible and worth pursuing.

**Clinical decision support and logic programming.** Decision rules, eligibility criteria, monitoring protocols, and constraint evaluation can be modelled as SysML constraints and decision tables, with generation targeting a logic engine runtime for [[principle-deterministic-over-probabilistic|deterministic, auditable reasoning (A6)]]. Two generators already produce TypeScript evaluators from the model.

**Governance framework formalisation.** The deontic governance vocabulary demonstrates that regulatory requirements can be formalised in OWL with rich semantic structure. The CQC Regulation 12 MVP (21 individuals, Session 131) is a concrete example. Additional governance frameworks can be formalised incrementally.

### 4.3 Architectural Documentation Value

These are areas where the model primarily serves as structural design documentation, providing the connective tissue for cross-cutting queries.

**Organisational structure.** Roles, teams, governance structures, and responsibility allocations are modelled as parts with allocated responsibilities, but do not generate executable code.

**Third-party integrations.** The model defines the boundary contract for each external service, regardless of whether the integration is built or bought.

**Marketing, community, and content.** Processes such as content approval or community onboarding can be modelled, but much of this domain is inherently creative and ad-hoc. The model defines touchpoints and data flows.

**Brand, design, and tone of voice.** Not system-modellable in any meaningful sense. The model can define where brand assets are used and what content types exist, but not what they look like.

---

## 5. Mapping Legacy Artefacts to SysML v2

The 2018 SHC/MedMind work and other legacy projects provide a significant head start. Each diagram type maps to SysML v2 as follows.

### 5.1 Use Case Diagrams

SysML v2 has `use case` as a language element with `include` and `extend` relationships. The semantic content maps directly. The recommended approach is to model use cases in SysML v2 for semantic traceability while accepting that presentation-quality use case diagrams may be produced separately for communication purposes.

### 5.2 BPMN Processes

This is the most significant and most valuable transition. BPMN process maps map almost directly to SysML v2 action flows at the domain layer. Activities become action nodes. Swim lanes become partitions or allocations to structural parts. Data objects become typed items flowing through the action flow, each with its own lifecycle state machine.

What SysML v2 gains over BPMN is integration: data objects are typed and traceable, preconditions reference constraints on entity state, constraints trace to requirements, and requirements are verifiable by runtime checks. What is lost is the richness of the BPMN event model. The Coffee Shop Demonstrator handles this pragmatically through orchestration-layer Temporal metadata annotations.

### 5.3 Top-Level Process Maps

The five-phase patient journey model (Acquisition, Registration, Assessment, Treatment, Follow Up) maps to a top-level SysML v2 action flow in the PatientJourney package. This provides the structural skeleton that detailed pathways elaborate.

### 5.4 Technology Component Diagrams

The UML class diagram mapping technology components maps to a SysML v2 structural model using part definitions with metadata annotations. Crucially, these structural parts can be formally allocated to action flow steps, enabling impact analysis.

### 5.5 Gathering and Synthesising Legacy Material

There is a fair amount of legacy business analytics material from prior projects and businesses beyond MedMind. Similarities and evolution across these projects suggest value in gathering the various artefacts and synthesising structural patterns, entity catalogues, process inventories, and recurring architectural themes.

---

## 6. Knowledge, Decision Support, and Reasoning

A distinctive feature of the Ontara system design is the explicit treatment of knowledge, decision logic, and reasoning as first-class architectural concerns rather than afterthoughts. The Knowledge layer is cross-cutting: imported by clinical pathways, referenced by governance, and consuming outcome data. The reasoning metamodel (Stage 7, Sessions 146–152) has transformed this from a design direction into concrete, implemented vocabulary.

### 6.1 The Reasoning Architecture

The system's reasoning capabilities are organised through two complementary structures: a tiered reasoning stack in SysML governing deterministic and structured decision support, and the reasoning metamodel in OWL providing the vocabulary for institutionalised reasoning.

**The four-category reasoning scheme** ([[principle-deterministic-over-probabilistic|A6]], reformulated Session 148 as a T1 amendment):

**Category 1 — Deterministic rules.** Constraint evaluation, eligibility rules, safety checks. Implemented via constraint evaluators generated from the SysML model. Fully traceable, always auditable. When the system says a patient is not eligible, the exact chain of inference is available.

**Category 2 — Inspectable logic.** DMN-style decision tables for clinical protocol decisions. Deterministic and auditable, but more expressive for multi-factor evaluation. Decision tables are generated from the model and can be read and validated by clinicians. Tau Prolog has been validated for compound deficit reasoning (16/16 tests, <4ms/query).

**Category 3 — Structured probabilistic.** Bayesian risk assessment, prognostic modelling, predictive analytics — with validated models, explicit assumptions, and full provenance. Given first-class architectural status through the A6 reformulation (Session 148). The reasoning metamodel provides four specialised types: BayesianUpdater, RiskCalculator, PrognosticModel, PredictiveAnalytics — each carrying validation metadata and priors/posteriors typed as Claims for provenance traceability.

**Category 4 — Opaque probabilistic.** ML/LLM-augmented intelligence. Pattern recognition, natural language processing, predictive analytics without full provenance. Powerful but probabilistic, and always advisory rather than authoritative.

The crucial principle is that authoritative clinical decisions follow deterministic, inspectable paths (Categories 1–2); structured probabilistic reasoning (Category 3) is permitted with explicit validation and provenance; opaque probabilistic reasoning (Category 4) informs but never overrides. In coordinate-framework language: deterministic paths through a probabilistically characterised landscape.

### 6.2 The Reasoning Metamodel

The [[ontara-discussion-institutionalised-reasoning-2026-04-05|reasoning metamodel]] (Stage 7, Sessions 146–152) is a cross-cutting SMM extension (S146-D1) that provides the OWL vocabulary for institutionalised reasoning, preserving the [[principle-two-meta-model-distinction|two meta model distinction (A4)]].

`ontara-reasoning.ttl` (namespace `ontara-rsn:`) contains 26 classes covering: reasoning contexts (ReasoningContext, ReasoningComponent), goals/obstacles/measures (Goal, Obstacle, Measure), decisions/plans (Decision, Plan, DecisionMode), a three-way constraint hierarchy (HardConstraint, SoftConstraint, GradedRule), knowledge sources/heuristics (KnowledgeSource, Heuristic), the SEPIO evidence architecture (Claim, EvidenceLine, EvidenceItem, ConfidenceAssessment, InterpretiveFrame), and structured probabilistic types (BayesianUpdater, RiskCalculator, PrognosticModel, PredictiveAnalytics). Three named individuals represent the interpretive frames (ProbabilityFrame, FuzzyMembershipFrame, PreferenceWeightFrame), stable since Session 46.

All classes are BFO-grounded and PROV-O-aligned via the dual subclassing pattern (S147-D4): reasoning classes inherit from both BFO and PROV-O parents without multiple inheritance conflicts. The reasoning metamodel does not implement runtime reasoning engines — those are deployment-time concerns per authority zones ([[concept-authority-zones|B29]]).

**Three-way constraint hierarchy** (S146-D8, S147-D3): HardConstraints are NormativeRegion boundaries (violation is failure — governance obligations are HardConstraints). SoftConstraints are ScalarField cost surfaces (violation has a measurable cost). GradedRules are ScalarField truth-value surfaces (assertions hold to a degree). This connects to the [[concept-coordinate-framework|coordinate framework (A12)]]: [[concept-goal-seeking-computation|goal-seeking computation (L9)]] is pathfinding through constrained coordinate space.

**Earlier research directions** — semiring soft-constraints, fuzzy MCDM, and Probabilistic Soft Logic — remain relevant as candidate runtime formalisms for the weight model. See [[ontara-discussion-intrinsic-self-knowledge-v2-2026-03-20|Intrinsic Self-Knowledge discussion]].

### 6.3 Logic Programming

There is a deliberate decision to preserve an explicit architectural space for logic programming. Logic programming (Prolog-style inference, DMN, constraint solving) provides deterministic, auditable, reproducible reasoning with a complete explanation trace. This is fundamentally different from what LLMs provide and is essential for regulated clinical decision support.

The SysML model defines logic rules as constraints and decision tables as structured value types. The generation pipeline targets constraint evaluators and decision table evaluators. The metadata library in Foundation provides annotations that the generators use to route each piece of reasoning to the appropriate evaluation tier.

### 6.4 The Five-Layer SystemStateAssessment

The Knowledge layer architecture defines a five-layer assessment pattern:

| Layer | Content |
|---|---|
| 1. Structural | System manifest — what the system contains |
| 2. Operational | Query runtime state — Temporal, CDR, platform |
| 3. Goal-state | Project from requirements, constraints, defined outcomes |
| 4. Gap analysis | Compare operational vs goal-state, produce Deficits |
| 5. Remediation | Classify as automatic, recommended, or advisory |

The default for any new deficit is "Recommended" — the system never takes automatic clinical action unless the model explicitly permits it.

### 6.5 Outcome Tracking and Learning Cycles

The system records structured outcomes: not just that a patient was treated, but the specific regimen, monitoring results at defined intervals, whether clinical targets were achieved, and any adverse events. Over time this builds a dataset that informs pathway refinement. The learning cycle is: capture structured outcomes → analyse patterns → propose pathway refinement → clinical governance review → update model → regenerate. The model is the mechanism for both capturing and enacting the learning.

### 6.6 Predictive and Adaptive Behaviour

Predictive capabilities (trajectory-based dose adjustment suggestions, capacity pressure forecasting) sit at the outer edge of what the model directly generates. The model's contribution is defining the data structures and event streams that feed predictive analytics, and defining the action points where predictions are surfaced to clinicians or operations. The crucial architectural principle is that adaptive features suggest and inform; they do not autonomously alter pathways or override gates. Any pathway change goes through the learning cycle's governance process and results in a model update.

---

## 7. The Two Meta Models and Package Architecture

The package structure is organised around the [[principle-two-meta-model-distinction|two meta model distinction (A4)]]: the project maintains a Business Meta Model (BMM — what a service business *is*) and a System Meta Model (SMM — how a business system *works*; renamed from BSMM, Session 92), connected by explicit horizontal mappings at every tier ([[concept-horizontal-mappings|B12]]).

### 7.1 The Business Meta Model (BMM)

The BMM defines the structural template for any service business, independent of technology. It contains 36 `part def`s + 2 `requirement def`s across six concern packages, plus `Foundation::DomainRegistry` (Session 143), classified as either General (sector-agnostic) or Tailored (sector-specific) per the [[concept-general-tailored-decomposition|General/Tailored decomposition (B11)]]. The BMM is structurally complete at the General level (Session 81).

The six concerns of a service business (C1–C5, C7, from the [[ontara-architecture-business-meta-modelling|Service Business Meta Modelling]] paper):

| Package | Concern | What it covers |
|---|---|---|
| **ServiceConcept** | C1 | What value is delivered, to whom, and why it is worth paying for |
| **ActivityModel** | C2 | How value is produced and delivered — processes, workflows, outcomes |
| **ResourcePlanning** | C3 | What resources and capabilities are required |
| **FinancialPlanning** | C4 | How money flows — revenue, costs, pricing, projections |
| **GovernanceMapping** | C5 | Regulatory requirements, governance, risk, learning |
| **[[concept-stakeholder-model\|StakeholderModel]]** | C7 | Relationships, partnerships, cooperative delivery, community, participation — the relational boundary. Six General elements (proposed Session 76, designed Session 78, implemented Session 81) |

Activity Awareness (C6) is the cross-cutting dimension.

The BMM packages live under the `BusinessModel` top-level package, with companion packages `BusinessScenarios` and `BusinessStrategy`.

All 34 BMM elements carry full annotation stacks: `@CatalogueTag`, `@UserFacing`, `@PurposiveDescription`, `@Comprehension`, `@WeightedRelationship`, and `@BfoType` (Session 99 — declaring BFO 2020 category and mid-level ontology parent). 96 weighted relationships across 33 weighted elements. 12 BMM attributes have been migrated from String to typed `ref` (Session 58), enabling cross-package weight traversal and semantic navigation.

### 7.2 The System Meta Model (SMM)

The SMM defines the structural template for how a business system works. Its concepts are distributed across the Foundation, Knowledge, ServiceDelivery, Platform, Operations, and PatternCatalogue packages. The SMM General vocabulary is organised into six capability groups (B25): Persistence & Data Management, Process Orchestration, Evaluation & Reasoning, Observation & Self-Knowledge, Integration & Communication, Identity & Access — with an architectural role axis (B26) as secondary classification.

SMM-side model content in SysML:

**ArchitecturalSection** (B27, Session 87): 1 `part def`, 20 `part` usages encoding the [[concept-dual-stack-architecture|dual-stack architecture]], 3 enums (`ArchitecturalGroup`, `Formalism`, `ImplementationStatus`), 1 `metadata def` (`@ArchitecturalLocation`). First SMM-side model content. Lives in the `ArchitecturalStructure` top-level package.

**DomainIdentity and DomainConfiguration** (Sessions 142–144): 2 `part def`s in `Foundation::DomainRegistry`, 6 enums in `Foundation::CommonTypes`, 8 domain instances. Dual-stack split: `DomainIdentity` (BMM, IAO plan_specification) carries business intent; `DomainConfiguration` (SMM, IAO data_item) carries system settings.

SMM-side content in OWL (extending the SMM beyond SysML):

**Deontic governance vocabulary** (`ontara-governance.ttl`, Sessions 121–131): 19 classes, 6 enumeration classes, 24 named individuals, 23 object properties, 17 data properties. The first hand-authored ontology module outside the BMM namespace. CQC Regulation 12 formalised as 21 individuals.

**Domain identity vocabulary** (`ontara-domain.ttl`, Session 144): 2 classes, 6 enumeration classes, 8+8 properties, 8 individuals.

**Reasoning metamodel vocabulary** (`ontara-reasoning.ttl`, Sessions 150–152): 26 classes, 3 named individuals, 15 object properties, 4 datatype properties, 2 cross-module governance alignment axioms.

The SysML section name `bsmm-general-vocabulary` is retained as a structural identifier. A future workstream will promote the implicit SMM concepts distributed across Foundation, Knowledge, ServiceDelivery, Platform, and Operations into a named, navigable package structure (gap O2 in the [[ontara-ref-master-register|master register]]).

### 7.3 Top-Level Package Structure

The model contains 12 top-level packages (~74 packages total):

| Package | Meta model | Purpose | Current state |
|---|---|---|---|
| **Enterprise** | SMM | Organisation, regulation, strategy, risk | Structural placeholders |
| **Foundation** | SMM (cross-cutting) | MetadataLibrary, CommonTypes, StatePatterns, GenerationPipeline, DomainRegistry (Session 143) | Active. MetadataLibrary is the home of all annotation `metadata def`s |
| **Knowledge** | SMM | ClinicalDecisionSupport, ConstraintLibrary, LogicEngine, DecisionModels, OutcomeFramework, LearningCycles, Analytics | Architectural documentation; evaluation patterns designed |
| **ServiceDelivery** | SMM | PatientJourney, ClinicalPathways, Consent, CoachingSupport, ClinicalGovernance, ClinicalEntities | Structural skeleton; Cafe demonstrates pathway and lifecycle patterns |
| **Platform** | SMM | PatientPortal, Booking, EHR, Forms, Messaging, VideoConsulting, LabInterface, Prescribing, Payments, Documents, Identity, Orchestration, Integration | Structural design; Cafe demonstrates EHR, Orchestration, Payments |
| **Operations** | SMM | Finance, People, Marketing, CRM, Reporting | Structural placeholders |
| **ArchitecturalStructure** | **SMM** | [[concept-architectural-section\|ArchitecturalSection]] (B27): 20 `part` usages encoding the dual-stack | Active. First SMM-side model content (Session 87) |
| **BusinessModel** | **BMM** | 34 elements across six concerns with full annotation stacks. Domain identity (DomainRegistry sub-package, Session 143). BMM structurally complete at General level | Active |
| **BusinessScenarios** | **BMM** | Scenario comparison and financial projection | Active. Cafe and GSL scenarios modelled |
| **BusinessStrategy** | **BMM** | Strategic objectives, business direction | Active. GSL strategic objectives modelled |
| **PatternCatalogue** | Cross-cutting | 22 validated patterns, 8 principles, 43 typed `ref` relationships, 33 domain instantiations | Active |
| **GenderSense** (root) | Instance | GSL-specific business model instance, clinical pathway models, tenant-level configuration | Active. The first production tenant |

### 7.4 Demonstrator Domain Files

Four demonstrator domains validate the BMM vocabulary:

| Domain | Files | Character | BMM coverage |
|---|---|---|---|
| [[domain-cafe\|Cafe]] | 9 `.sysml` (4 business model + 5 domain model) | Immediate retail, walk-in, 2-minute cycle | Full model + running application. StakeholderModel: 6 instantiations |
| [[domain-suds\|Suds]] | 1 `.sysml` | Batch processing, turnaround promises, item tracking | Full BMM + COSHH governance traceability chain. StakeholderModel: 6 instantiations (Session 108) |
| [[domain-paws\|Paws]] | 1 `.sysml` | Appointment-based, customer ≠ service recipient | General vocabulary + StakeholderModel: 7 instantiations |
| [[domain-ears\|Ears]] | — | Community ear care, simple procedural pathway | Outlined (Session 97). Exercises all six BMM concerns and OGMS clinical primitives |

Under the [[concept-multi-tenancy|multi-tenancy principle (A13)]] — promoted to binding Tier 1, Session 142 — every domain is a tenant instantiation. Domain identity is now structurally expressed across SysML, OWL, and the generation pipeline (Sessions 142–144).

### 7.5 Package Design Principles

Several principles govern the package architecture:

**Foundation as shared vocabulary.** The Foundation package is imported by everything else. Metadata definitions, common types, reusable state machine patterns, generation pipeline configuration, and domain identity infrastructure live here.

**ClinicalEntities separation.** Core domain entities are separated from the pathways that operate on them. Entities are the nouns with lifecycle state machines; pathways are the verbs.

**ServiceDelivery/Platform split.** Mirrors the [[pattern-two-layer-action-flow|two-layer action flow (D6)]]. ServiceDelivery is the domain layer. Platform is the orchestration/infrastructure layer. Connected through allocation relationships.

**Regulation as a first-class package.** Regulatory requirements have their own home in Enterprise::Regulation, with `satisfy` relationships enabling cross-cutting traceability ([[principle-clinical-governance-first-class|A8]]).

---

## 8. The Annotation and Metadata System

SysML v2's `metadata def` mechanism is the backbone of both the generation pipeline and the comprehension architecture. The annotations are defined in `Foundation::MetadataLibrary` and applied to model elements using `@` syntax. The generation pipeline extracts them; the Ontara Console renders them; the OWL pipeline uses them for ontological classification.

### 8.1 Generation Annotations

| Annotation | Purpose | Used by |
|---|---|---|
| `@CatalogueTag` | Multi-axis classification — BMM concern, meta model layer, General/Tailored status, domain applicability | Component Catalogue grouping; Coverage Matrix |
| `@UserFacing` | `friendlyName` and `shortDescription` for any element | Glossary; all console views |

### 8.2 Comprehension Annotations

| Annotation | Purpose | Coverage |
|---|---|---|
| `@PurposiveDescription` | Authored purposive description — "why does this exist and what does it do for your service?" | 34/34 BMM elements; 20/20 architectural sections |
| `@Comprehension` | Traversal schema for dynamically derived structural self-knowledge — four boolean flags controlling which structural features to surface | 34/34 BMM elements |
| `@WeightedRelationship` | Directed, non-commutative strength of interaction between elements — strong, moderate, or weak | 96 relationships across 33 weighted elements |
| `@ArchitecturalLocation` | Locates an element within the [[concept-dual-stack-architecture\|dual-stack architecture]] — stack, group, position, formalism, implementation status | 20/20 architectural sections (Session 87) |
| `@BfoType` | BFO 2020 category, mid-level ontology parent, and classification justification — the SysML-side input to the OWL pipeline | 34/34 BMM elements (Session 99) |

### 8.3 Design Principles for Annotations

**Model-native.** All annotations are SysML v2 metadata definitions, not external configuration. They participate in the model's type system.

**Dual-pipeline friendly.** Each annotation has clear consumers: `gen_model_introspection.py` extracts all annotation types and produces `model-introspection.json` for the console; `gen_owl_pipeline.py` reads `@BfoType` and `@WeightedRelationship` to produce correctly classified OWL classes and reified relationship individuals.

**Authored vs intrinsic.** `@PurposiveDescription` is human-authored content (Register 1). `@Comprehension` is a traversal schema for dynamically derived content (Register 2). The [[principle-intrinsic-self-knowledge|A10]] test determines which category any given content belongs to.

**Extensible.** New metadata definitions can be added to the MetadataLibrary as new architectural needs emerge. The generation pipelines discover annotations by type; new types are automatically picked up.

### 8.4 The Doc Block Convention

Every `part def` or `metadata def` in the model carries a doc block identifying its meta model affiliation: `/* business meta model concept */` or `/* system meta model concept */`. This is a standing convention (N1 in the [[ontara-ref-master-register|master register]]) that ensures the [[principle-two-meta-model-distinction|two meta model distinction (A4)]] is maintained at the source level.

---

## 9. Structural Principles for the Model

### 9.1 Concentric Rings of Modelling Rigour

The model is organised in concentric rings of decreasing modelling rigour:

**Inner ring — Clinical pathway system.** Pathway models, entity lifecycles, governance outputs. Full model-driven execution with generation pipeline. Maximum rigour.

**Middle ring — Supporting infrastructure.** Service interfaces, data models, forms, booking, patient portal, messaging. Modelled for structural clarity and interface generation, with varying degrees of code generation.

**Outer ring — Business context.** Organisational structure, back office processes, marketing, partnerships. Modelled at a higher level of abstraction for traceability and architectural documentation.

All three rings live in the same model and can reference each other. The inner ring receives the most modelling investment; the outer ring accepts that the model is a useful map rather than the territory itself.

### 9.2 Co-Evolution of Model and Tooling

The [[concept-co-evolution|co-evolution principle (J2)]] is Tier 1 governing: no modelling without the tool that makes it legible; no tool without model content that exercises it. In practice this means that model extensions and Ontara Console features are built together. When the comprehension annotations were added to the model, the Glossary view was extended to render them. When the weighted relationships were populated, the 3D WebGL graph was built to visualise them. When the BFO classifications were applied, BFO category badges appeared in the Glossary and Component Catalogue, and the Ontology view was built to render the hierarchy.

This principle prevents two failure modes: a model that grows richer but remains invisible (no tooling to surface it), and tooling that grows more sophisticated but has nothing to show (no model content to exercise it).

### 9.3 General and Tailored Decomposition

Within each meta model (BMM and SMM), components are classified as General (sector-agnostic) or Tailored (sector-specific) per [[concept-general-tailored-decomposition|B11]]. The Paws demonstrator was deliberately built using exclusively General BMM vocabulary to validate that the General tier is sufficient for a simple service business. The Suds demonstrator exercises both General vocabulary and Tailored governance (COSHH requirements). GSL, as a sector-regulated healthcare service, will exercise the full Tailored vocabulary.

### 9.4 Cross-Domain Validation

Every meta model concept and pattern should validate in at least two domains ([[concept-cross-domain-validation|J1]]). Four demonstrator domains validate across structurally different businesses. The three-domain validation threshold has been met for BMM vocabulary. The reasoning metamodel (Stage 7 Phase 1) achieved cross-domain validation at 24/24 PASS against Cafe and Suds. SMM validation beyond the reasoning metamodel currently relies primarily on the Cafe demonstrator.

### 9.5 Avoiding Over-Modelling

Not every area benefits from formal modelling to the same depth. The guiding principle is that the model should earn its keep ([[concept-model-earns-its-keep|J4]]) by either generating something (code, documentation, ontology, diagrams) or by making a non-obvious structural relationship visible. If modelling something merely restates the obvious, that is a signal to stop. The package structure permits elaboration but does not require it.

### 9.6 Non-Constraining Architecture

Architectural decisions should not foreclose future development paths ([[concept-non-constraining|J3]]). Clean abstractions, loose coupling, and discoverable structure mean that a decision made today can be revisited without cascading refactoring. The [[concept-design-decision-lifecycle|design decision lifecycle (J12)]] — freedom → experimentation → discovered convention → opinionated configuration → revisable — deliberately preserves freedom at early stages.

---

## 10. The Generation Pipeline

### 10.1 Model-to-Application Generators

Eight operational generators produce artefacts from the SysML model. All SysML-reading generators share `sysml_parser.py` (Session 104) as a common parser module:

| Generator | Output | Consumer |
|---|---|---|
| `gen_model_introspection.py` | `model-introspection.json` — extracts all metadata annotations including `@BfoType` (Session 103) and `architecturalSections` (20 entries) | Ontara Console (all 13 views) |
| `gen_owl_pipeline.py` | SysML → OWL/Turtle via declarative mapping rules. Five outputs: `ontara-bmm.ttl` (34 classes), `ontara-bmm-properties.ttl` (14 object properties), `ontara-bmm-weights.ttl` (96 reified individuals, 702 triples), `ontara-correspondence.ttl` (1,378 triples), `mapping-ir.json` | Knowledge graph |
| `gen_concept_graph.py` | 6 Mermaid views + Obsidian concept graph notes | Knowledge base navigation |
| `gen_package_hierarchy.py` | Package structure visualisation | Console Package Navigator |
| `gen_system_manifest.py` | `system-manifest.json` | Self-knowledge (F1 Layer 1) |
| `gen_constraint_evaluator.py` | `constraint-evaluators.ts`, `constraint-specs.ts` | Runtime constraint evaluation (A6 Category 1) |
| `gen_decision_table_evaluator.py` | `decision-table-evaluators.ts` | Runtime decision tables (A6 Category 2) |
| `projection_engine.py` | Financial scenario comparison | Business planning |

### 10.2 Knowledge Graph Tooling

Five scripts manage the knowledge graph infrastructure:

| Script | Purpose |
|---|---|
| `setup_graphdb.py` | GraphDB repository creation and ontology stack loading (BFO 2020, CCO, IAO) |
| `validate_kg.py` | SPARQL validation suite — 43 queries in 11 groups |
| `reason_kg.py` | Robot + HermiT full OWL 2 DL consistency checking. 12-file ontology stack |
| `diff_kg.py` | Round-trip diff engine — 288 semantic units, authority-zone-aware |
| `kg_utils.py` | Shared KG utilities — GraphDB connection, SPARQL execution, IRI shortening |

### 10.3 Two-Phase Architecture

The generation pipeline follows a two-phase design: Phase 1 generators are model-aware and framework-agnostic (read SysML, produce domain artefacts and manifest). Phase 2 generators are model-agnostic and framework-aware (read manifest and domain artefacts, produce wiring for the target framework). The phase separation means the choice of execution framework can change without rewriting the domain generators.

### 10.4 The Four-Layer Generated Code Architecture

| Layer | Content | Editability |
|---|---|---|
| 1. SysML model | Source of truth | Hand-maintained |
| 2. Domain artefacts | Generated types, state machines, constraints | Never hand-edited; freely regenerable |
| 3. Integration glue | Generated wiring for target framework | Never hand-edited; freely regenerable |
| 4. Application code | Hand-written, imports from L2/L3 | Never overwritten by generators |

The strict layering ensures regeneration safety. Generated files carry `DO NOT EDIT` headers with timestamp and source reference (N5).

### 10.5 Generators Fail Loudly, Degrade Gracefully

Unparseable SysML expressions emit TODO placeholders in the generated output, never broken code (N6). This means a partial model produces partial but valid output. The generators serve as executable specifications for future migration to the Syside Automator API, which will provide semantic model access replacing the current regex-based parsers.

---

## 11. The Two Formalisms

Ontara uses two complementary modelling formalisms. Each does what the other cannot. This section describes their relationship, the boundary between them, and the mechanisms that keep them in sync.

### 11.1 SysML v2 — Structure and Behaviour

SysML v2 is the source of truth for: structural definitions (`part def`, `attribute`, `ref`), behavioural models (action flows, state machines), requirements and constraints (`requirement def`, `constraint def`), metadata annotations (the comprehension and generation annotation system), domain instances (`part` usages in demonstrator files), and the PatternCatalogue.

SysML v2 cannot do: open-world reasoning, automatic classification, consistency checking against ontological axioms, SPARQL semantic querying, or direct import of OBO Foundry ontologies.

### 11.2 OWL 2 DL — Ontological Semantics

OWL 2 DL is the mandatory formalism for the ontological layers (B23, binding, Session 73). It is represented in: BFO 2020 and mid-level ontologies (CCO, IAO, PROV-O core, OGMS), pipeline-generated vocabularies (BMM classes, object properties, weighted relationship individuals, correspondence triples), and hand-authored platform vocabularies (governance, domain identity, reasoning metamodel).

OWL 2 DL cannot do: structural system modelling, behavioural specification, code generation for runtime execution, or the metadata annotation system that drives the console.

### 11.3 The Boundary

The `@BfoType` annotation (§8.2) is the primary bridge from SysML to OWL. It declares, for each SysML `part def`, the BFO 2020 category and mid-level ontology parent that the OWL pipeline uses to generate correctly classified OWL classes. The mapping ontology (B24), concretely realised as the correspondence graph, provides explicit provenance-tracked records linking each SysML element to its OWL counterpart.

Authority zones ([[concept-authority-zones|B29]], E020) govern which formalism is definitive for which content: SysML-authoritative for structure and behaviour, OWL-authoritative for ontological semantics and axioms, shared-constrained for labels and definitions.

### 11.4 The Knowledge Graph as Canonical Store

A directional commitment (B22): the knowledge graph (OWL 2 DL in GraphDB) can eventually become the canonical store, with SysML v2 as an engineering projection — provided round-trip translation preserves all aspects of the model without degradation. The round-trip diff engine (Session 137) provides the mechanism for verifying this condition: 288 semantic units compared, 0 discrepancies. This does not violate [[principle-separation-representation-execution|A1]] or [[principle-model-generates-everything|A3]] — the representation remains primary; the question is which formalism carries it.

### 11.5 Three-Stratum Graph

The knowledge graph architecture (Session 97, E019) organises content into three strata: the metamodel graph (SysML traceability), the domain graph (BFO-grounded semantics — the canonical layer), and the correspondence graph (explicit mapping records with provenance). The IRI scheme uses `https://ontara.dev/ontology/` for vocabulary and `https://ontara.dev/data/` for instances.

### 11.6 Quality Assurance

Three layers of automated quality assurance keep the two formalisms in sync: SPARQL validation (43 queries in 11 groups checking structural and semantic correctness), OWL 2 DL reasoning (HermiT checking logical consistency across the 12-file stack), and round-trip diff (288 semantic units verifying pipeline-to-store fidelity).

---

## 12. Current State and Forward Direction

### 12.1 What Has Been Built

| Area | Status |
|---|---|
| SysML model | 12 top-level packages, ~74 packages total, 12 core `.sysml` files. 36 BMM `part def`s + 2 `requirement def`s + `DomainIdentity`/`DomainConfiguration` with full annotation stacks including `@BfoType`. 1 SMM `part def` ([[concept-architectural-section\|ArchitecturalSection]]), 20 `part` usages, 3 enums, 1 `metadata def` |
| PatternCatalogue | 22 validated patterns, 8 principles, 43 typed `ref` relationships, 33 domain instantiations |
| Comprehension metadata | 34/34 `@UserFacing`, 34/34 `@PurposiveDescription`, 34/34 `@Comprehension`, 34/34 `@BfoType`, 96 `@WeightedRelationship` (BMM). 20/20 `@UserFacing`, 20/20 `@PurposiveDescription`, 20/20 `@ArchitecturalLocation` (architectural sections). 12 typed cross-refs |
| Knowledge graph | 12-file ontology stack. 43-query SPARQL suite (11 groups). HermiT CONSISTENT. Round-trip diff: 288 semantic units, 0 discrepancies. Three layers of automated QA |
| Hand-authored OWL modules | Governance vocabulary (19 classes, Sessions 121–126), CQC Reg 12 (21 individuals, Session 131), domain identity (2 classes, Session 144), reasoning metamodel (26 classes, Sessions 150–152), PROV-O core subset (73 triples, Session 150) |
| Pipeline-generated OWL | BMM classes (34), object properties (14), weighted relationship individuals (96, 702 triples), correspondence triples (1,378) |
| Ontara Console | 13 views: Home, Coverage Matrix, Package Navigator, Component Catalogue, Glossary, Governance, Meta-Model, Patterns, Domain Views, Weighted Relationship Graph (3D WebGL), Architecture (visual spatial map), Ontology (BFO hierarchy + KG Status). Global navigation context (I19, 6 routes) |
| Coffee Shop application | 9 pages, 19 API routes, Temporal workflows, XState v5, EHRbase CDR, PostgreSQL |
| Generation pipeline | 8 model-to-application generators + 5 KG tooling scripts. Shared `sysml_parser.py` and `kg_utils.py` |
| Demonstrator domains | Cafe (full + running app), Suds (BMM + COSHH), Paws (General vocabulary), Ears (outlined) |
| Master register | ~212 concepts across 16 sections (A–P), four tiers |

### 12.2 Forward Direction

The following areas represent planned or anticipated development, subject to the [[concept-non-constraining|non-constraining principle (J3)]]:

**Stage 7 Phase 2 — Reasoning depth.** Heuristic packs (typed hierarchy, HeuristicPack collections, override machinery), decision mode routing (Cynefin domain mapping as ClassificationRegion instances), constraint satisfaction structures (semiring properties, composition rules). 3–5 sessions estimated.

**Stage 7 Phases 3–4 — Safety/resilience and console integration.** STAMP/STPA and FRAM-ready architectural slots. Reasoning explorer, evidence browser, decision trace visualisation.

**Foundations papers refresh (W-023).** [[ontara-architecture-business-meta-modelling|Service Business Meta Modelling]] v2→v3 to incorporate reasoning metamodel and domain identity implications.

**Stage 4 continuation.** Cross-package navigation, BMM concern group descriptions ([[ontara-workflow-emergent-ideas-log|E003]]), structural completeness visualisation, assembly workspace prototype.

**Stage 6 Block B — Governance activation tier.** Connecting domain identity to governance frameworks. Obligation binding to specific tenant service models.

**Ears demonstrator (W-015).** Build-out of the sector-regulated clinical demonstrator, exercising OGMS clinical primitives and the governance framework.

**SMM elaboration.** Promoting implicit SMM concepts into a named, navigable package structure (gap O2).

**Simulation architecture prototyping.** [[concept-operational-simulation|Operational simulation (L5)]] in a demonstrator domain, [[concept-reflective-simulation|reflective simulation (L6)]] design, [[concept-valence|valence (L7)]] representation mechanism.

**Dual-canvas construction kit.** Business Canvas for composing business models; System Canvas for technology components; connected by horizontal mappings.

**Syside Automator migration.** Semantic model access replacing regex parsers. Targeted for when the Automator API stabilises.

**Stage 5 Phase 4 — Live SPARQL.** Console queries against GraphDB at runtime.

**GraphRAG as KG consumption pattern (E026).** Exploiting the knowledge graph through retrieval-augmented generation.

---

## 13. Summary

SysML v2 and OWL 2 DL serve as the complementary modelling foundations for Ontara. The model is not merely documentation — it generates the running system, governs its own compliance, classifies its own content ontologically, checks its own consistency, and explains itself through a comprehension architecture that is unique in its depth and ambition.

The modelling strategy rests on several interlocking commitments: the [[principle-separation-representation-execution|separation of representation and execution (A1)]] ensures knowledge lives in the model; the [[principle-model-generates-everything|generation pipeline (A3)]] keeps model and system in sync; the [[principle-two-meta-model-distinction|two meta model distinction (A4)]] separates what a business *is* from how a system *works*; the [[principle-deterministic-over-probabilistic|four-category reasoning scheme (A6)]] ensures clinical decisions are inspectable while giving structured probabilistic reasoning first-class status; the [[principle-intrinsic-self-knowledge|comprehension architecture (A10)]] enables the system to explain itself; and the [[principle-unity-principle|unity principle (A11)]] ensures that the same knowledge model informs every subsystem — empirically validated by the comprehension–reasoning convergence (S147-D7).

The concentric rings of rigour provide a principled gradient from maximum modelling investment (clinical pathways) through structural design (platform infrastructure) to architectural documentation (business context). The model earns its keep by generating something or making a non-obvious relationship visible — and the [[concept-co-evolution|co-evolution principle (J2)]] ensures that modelling and tooling advance together.

The two-formalism architecture — SysML v2 for structure and behaviour, OWL 2 DL for ontological semantics — gives each formalism its natural role, bridged by the `@BfoType` annotation, the correspondence graph, and authority zones. The knowledge graph (12-file stack, 43-query SPARQL suite, HermiT consistency, round-trip diff) provides three layers of automated quality assurance that the Coffee Shop-era SysML-only approach could not achieve.

The forward direction includes reasoning metamodel depth (Phase 2), governance activation, simulation prototyping, the Ears demonstrator, and the dual-canvas construction kit. The [[concept-non-constraining|non-constraining principle (J3)]] ensures these paths remain open while current work proceeds with discipline and precision.

---

## Related Documents

- [[ontara-architecture-platform-principles|Architecture Principles (v4)]] — the governing architectural commitments (companion foundations paper)
- [[ontara-architecture-business-meta-modelling|Service Business Meta Modelling (v2)]] — the authoritative BMM structure reference (companion foundations paper)
- [[ontara-validated-architectural-patterns|Validated Architectural Patterns]] — 22 patterns with domain instantiation status
- [[ontara-ref-vision-architecture|Vision and Architecture Reference (v9)]] — the comprehensive architectural summary
- [[ontara-ref-strategic-snapshot|Strategic Reference]] — current development state and metrics
- [[ontara-ref-master-register|Master Concept Register]] — ~212 concepts across 16 sections (A–P), four tiers
- [[ontara-architecture-decision-knowledge-evaluation|Knowledge Layer Evaluation]] — the five-layer assessment architecture
- [[ontara-discussion-dual-stack-architecture-2026-03-26|Dual-Stack Architecture Discussion]] — Session 73/74
- [[ontara-discussion-knowledge-graph-architecture-2026-04-01|Knowledge Graph Architecture]] — Session 97, three-stratum graph, authority zones
- [[ontara-discussion-deontic-governance-architecture-2026-04-03|Deontic Governance Architecture]] — Session 121
- [[ontara-discussion-domain-identity-dual-stack-2026-04-05|Domain Identity in the Dual-Stack Architecture]] — Session 142
- [[ontara-discussion-institutionalised-reasoning-2026-04-05|Institutionalised Reasoning]] — Session 146
- [[ontara-discussion-coordinate-framework-revisited-2026-04-05|The Coordinate Framework Revisited]] — Session 147
- [[stage7-plan-s.148-reasoning-metamodel|Stage 7 Plan — Reasoning Metamodel]] — Session 148
- [[ontara-discussion-bfo-type-mapping-2026-04-01|@BfoType Mapping]] — Session 98
- [[ontara-stage-4-high-level-plan-2026-03-21|Stage 4 High-Level Plan]]
- [[SUPERSEDED-ontara-architecture-platform-modelling-strategy-v3-s96\|Platform Modelling Strategy v3 (Session 96)]] — previous version
- [[SUPERSEDED-ontara-platform-modelling-strategy-v2-s65\|Platform Modelling Strategy v2 (Session 65)]]
- [[SUPERSEDED-ontara-platform-sysml-modelling-strategy-v1\|SysML Modelling Strategy v1]] — original

---

*Platform Modelling Strategy v4, Session 154, 6 April 2026. Refreshed from v3 (Session 96, 1 April 2026). See Version History at the head of this document for change summary.*
