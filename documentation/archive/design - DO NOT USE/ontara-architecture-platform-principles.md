---
tags:
  - architecture
  - foundations
date: 2026-04-06
status: current
session: 154
---
# Ontara — Architecture Principles
> `= this.file.path`

**Purpose:** The governing architectural principles of the Ontara platform — the commitments that shape every design decision, from meta model structure through generation pipeline to console tooling. This document is one of three foundations papers; the others are [[ontara-architecture-platform-modelling-strategy|Platform Modelling Strategy]] and [[ontara-architecture-business-meta-modelling|Service Business Meta Modelling]].
**Audience:** The project founder, development collaborators, and technically capable readers seeking to understand *why* the architecture is the way it is.
**Status:** Standing reference document. Uses a stable filename — versioning is expressed here, not in the filename.
**Staleness threshold:** 15 sessions or major governing principles change.

### Version History

| Version | Session | Date | Summary of changes |
|---|---|---|---|
| v4 | 154 | 6 April 2026 | Major refresh incorporating 58 sessions of development (S96–S154). Knowledge graph implementation (Stage 5, three phases complete); deontic governance architecture and CQC MVP; domain identity implementation (Stage 6 Block A); reasoning metamodel and coordinate framework consolidation (Stage 7, Phases 0–1); A6 reformulated as T1 amendment; A13 promoted to binding T1; PROV-O platform-level import; comprehension–reasoning convergence; generation pipeline expanded with OWL pipeline and KG tooling; register ~212 concepts across 16 sections (A–P) |
| v3 | 96 | 1 April 2026 | [[concept-stakeholder-model\|StakeholderModel]] sixth concern (34 elements, 96 weights); BSMM→SMM terminology; BFO upgraded to mandatory; [[concept-dual-stack-architecture\|dual-stack architecture]]; simulation architecture (L5–L9); OWL 2 DL and knowledge graph; [[concept-architectural-section\|ArchitecturalSection]] second register of self-knowledge; console 12 views; register ~190 concepts. Archived as [[SUPERSEDED-ontara-architecture-platform-principles-v3-s96\|v3 (Session 96)]] |
| v2 | 64 | 24 March 2026 | Full revision. Archived as [[SUPERSEDED-ontara-platform-architecture-principles-v2-s64\|v2 (Session 64)]] |
| v1 | ~8 | 4 March 2026 | Original. Archived as [[SUPERSEDED-ontara-platform-architecture-principles-v1\|v1]] |

---

## Contents

- [[#1. The Separation Principle|§1. The Separation Principle]]
- [[#2. The Self-Describing System|§2. The Self-Describing System]]
- [[#3. The Two Meta Models|§3. The Two Meta Models]]
- [[#4. Multi-Tenancy|§4. Multi-Tenancy]]
- [[#5. Foundational Architecture|§5. Foundational Architecture]]
- [[#6. The Clinical Data Architecture|§6. The Clinical Data Architecture]]
- [[#7. Governance as a First-Class Concern|§7. Governance as a First-Class Concern]]
- [[#8. External Service Integration|§8. External Service Integration]]
- [[#9. Data Availability and Aggregation|§9. Data Availability and Aggregation]]
- [[#10. Guiding Constraints|§10. Guiding Constraints]]
- [[#Appendix A Technical Architecture Patterns|Appendix A: Technical Architecture Patterns]]

---

## 1. The Separation Principle

The single most important architectural commitment is the [[principle-separation-representation-execution|separation of the representation layer from the execution layer (A1)]].

The **representation layer** is where knowledge lives. It includes the SysML v2 model (business meta model, system meta model, business model instances, system model instances), the OWL 2 DL ontological layers (BFO, mid-level ontologies, platform vocabularies — governance, domain identity, reasoning), clinical data structures (openEHR archetypes and templates), decision logic and clinical rules (SysML constraints), governance requirements (SysML requirements and deontic directives in the knowledge graph), terminology bindings (SNOMED CT via openEHR), and the comprehension metadata that enables the system to explain itself.

The **execution layer** is where things happen. It includes process orchestration (Temporal workflows generated from SysML), state enforcement (XState machines generated from SysML), clinical data persistence (openEHR CDR accessed via REST API), knowledge graph persistence (GraphDB with OWL reasoning), external service integrations (booking, payments, messaging, video, labs), the Ontara Console, and front-end applications (clinician-facing, patient-facing, operational).

Execution components consume the representation layer but do not define it. Process logic lives in the model, not in application code. Clinical data structure lives in archetypes, not in database schemas. Decision rules live in constraints, not in if-statements scattered through a codebase. When any of these need to change, the change happens in the representation layer and propagates to execution via generation or configuration.

This separation is what makes the system adaptable. Business direction can change — new pathways, new service models, new regulatory requirements — and the response is to update the representation layer, not to rewrite application code.

### 1.1 The generation pipeline as bridge

Code and ontology generation is the mechanism that keeps model and execution in sync ([[principle-model-generates-everything|A3]]). The pipeline now spans two complementary domains:

**Model-to-application generators.** Seven operational generators produce artefacts from the SysML model: JSON data for the console (`gen_model_introspection.py`), Mermaid diagrams, TypeScript types, constraint evaluators, decision table evaluators, financial projections, and the system manifest. All SysML-reading generators share `sysml_parser.py` (Session 104) as a common parser module.

**Model-to-ontology pipeline.** The OWL pipeline (`gen_owl_pipeline.py`, Sessions 105–117) translates SysML into OWL 2 DL via declarative mapping rules, producing five outputs: BMM classes (34 OWL classes), BMM object properties (14), reified weighted relationship individuals (96, 702 triples), correspondence triples (1,378), and the mapping intermediate representation. The pipeline is complemented by five knowledge graph tooling scripts for repository management, SPARQL validation (43 queries), OWL 2 DL consistency checking (HermiT via Robot), round-trip diff verification (288 semantic units), and shared KG utilities.

The principle is that process knowledge exists only in the model; generated code and generated ontology are derived artefacts, not sources of truth. Generated layers are freely regenerable; hand-written application code and hand-authored ontology modules are never overwritten by the pipeline.

The pipeline follows a two-phase architecture: Phase 1 generators are model-aware and framework-agnostic; Phase 2 generators are model-agnostic and framework-aware. See the [[ontara-ref-vision-architecture|Vision and Architecture Reference]] §4.

### 1.2 Execution components are replaceable; the representation layer is not

Temporal could theoretically be replaced by another workflow engine. EHRbase could be swapped for another openEHR CDR. GraphDB could be replaced by another OWL 2 DL-capable triple store. The front end could be rebuilt. The SysML models, OWL ontologies, and openEHR archetypes carry the knowledge and are the long-term investment.

---

## 2. The Self-Describing System

The system knows what it is, what it is doing, why, and what rules govern it ([[principle-self-describing-system|A2]]). This is not an aspiration — it is a structural commitment realised through the comprehension architecture.

### 2.1 The comprehension architecture

The comprehension architecture addresses the question: how does the system know what it contains, why it is structured that way, and how to explain itself? Three registers of content provide the answer:

| Register | Content | Source |
|---|---|---|
| **Authored** | Human-written purposive descriptions — why an element exists and what it does | `@PurposiveDescription` metadata in SysML. 34/34 BMM coverage; 20/20 architectural section coverage. |
| **Structural** | Facts the model already knows — type, relationships, containment, patterns, domain instantiations | Dynamically derived via `@Comprehension` metadata traversal schema. 34/34 BMM coverage. |
| **Inferential** | Derived explanations beyond what any single element states — analogies, gap analysis, impact propagation | Converged with the reasoning metamodel's evidence architecture (S147-D7): the inferential register and the SEPIO+PROV-O evidence architecture are the same underlying pattern. The reasoning vocabulary (`ontara-reasoning.ttl`) provides the OWL infrastructure for Claims, EvidenceLines, and ConfidenceAssessments. |

The intrinsic self-knowledge principle ([[principle-intrinsic-self-knowledge|A10]]) governs the boundary between authored and structural content: if the model changes and no human edits a description, does the explanation become wrong? If yes, that content must be intrinsic — dynamically computed from live model state, not stored as static text.

The comprehension architecture operates across two distinct registers of self-knowledge (see [[ontara-ref-vision-architecture|Vision and Architecture Reference]] §7.6). The BMM register (34 elements, three annotation types) describes what a service business *is*. The architectural register (20 sections, `@ArchitecturalLocation` and `@PurposiveDescription`) describes how the platform itself *is structured* — the [[concept-dual-stack-architecture|dual-stack architecture]] made self-describing.

### 2.2 Weighted relationships

96 `@WeightedRelationship` annotations across 33 weighted elements express the strength of interaction between BMM concepts. These relationships are directional and non-commutative: the weight on A → B answers "if A changes, how much does B need reassessment?" The reverse B → A is independently assessed. Weights do not net off, average, or combine — they are structural facts about the model's topology.

The weight model supports three interpretive frames — costs/preferences, fuzzy human judgements, and probabilities — formalised in the reasoning metamodel as named individuals (`ProbabilityFrame`, `FuzzyMembershipFrame`, `PreferenceWeightFrame`), stable since their first identification in Session 46.

The unity principle ([[principle-unity-principle|A11]]) commits the platform to a single weighted relationship model informing comprehension, reasoning, simulation, governance, and assembly guidance. No separate, disconnected knowledge structures. This commitment was empirically validated by the comprehension–reasoning convergence (S147-D7): Session 147 confirmed that the inferential register and the evidence architecture are the same pattern, vindicating A11's original claim.

Weighted relationships now have OWL representation: 96 reified individuals in `ontara-bmm-weights.ttl` (702 triples), pipeline-generated from the SysML annotations and loaded into the knowledge graph alongside the BMM classes and object properties.

### 2.3 Reasoning architecture

The reasoning metamodel (Stage 7, Sessions 146–152) replaces earlier speculative directions with a concrete, implemented vocabulary for institutionalised reasoning as a first-class platform capability. The metamodel is a cross-cutting SMM extension (S146-D1), preserving the two meta model distinction ([[principle-two-meta-model-distinction|A4]]).

The OWL vocabulary (`ontara-reasoning.ttl`, namespace `ontara-rsn:`) provides 26 classes covering reasoning contexts, goals/obstacles/measures, decisions/plans, knowledge sources/heuristics, a three-way constraint hierarchy, an evidence architecture following the SEPIO pattern, and structured probabilistic reasoning types — all BFO-grounded and PROV-O-aligned via dual subclassing (S147-D4).

**The evidence architecture** (S146-D7) follows the SEPIO pattern: Claim → EvidenceLine → EvidenceItem, with ConfidenceAssessment carrying a declared InterpretiveFrame. Three named individuals represent the interpretive frames (probability, fuzzy membership, preference weight). Priors and posteriors in probabilistic components are typed as Claims for full provenance traceability.

**The three-way constraint hierarchy** (S146-D8, S147-D3) formalises the distinction between HardConstraints (NormativeRegion boundaries — violation is failure), SoftConstraints (ScalarField cost surfaces — violation has a measurable cost), and GradedRules (ScalarField truth-value surfaces — assertions hold to a degree). Governance obligations are HardConstraints: Obligation and Prohibition are declared as HardConstraint subclasses, connecting the deontic governance vocabulary to the reasoning metamodel.

**Structured probabilistic reasoning** (S147-D5) is given first-class architectural status through the A6 reformulation (Session 148, T1 amendment) and four specialised types: BayesianUpdater, RiskCalculator, PrognosticModel, and PredictiveAnalytics — each carrying validation metadata and provenance.

**Earlier research directions** — semiring soft-constraints, fuzzy MCDM, and Probabilistic Soft Logic — remain relevant as candidate runtime formalisms. The reasoning metamodel provides the OWL vocabulary for expressing reasoning structures; runtime engines are deployment-time concerns per authority zones ([[concept-authority-zones|B29]]). See [[ontara-discussion-institutionalised-reasoning-2026-04-05|Institutionalised Reasoning (Session 146)]], [[ontara-discussion-coordinate-framework-revisited-2026-04-05|The Coordinate Framework Revisited (Session 147)]], and [[ontara-discussion-intrinsic-self-knowledge-v2-2026-03-20|Intrinsic Self-Knowledge discussion]].

---

## 3. The Two Meta Models

The project maintains two distinct meta models ([[principle-two-meta-model-distinction|A4]]):

**Business Meta Model (BMM)** — what a service business *is*. 36 `part def`s + 2 `requirement def`s across six concerns (ServiceConcept, ActivityModel, ResourcePlanning, FinancialPlanning, GovernanceMapping, [[concept-stakeholder-model|StakeholderModel]]), plus `Foundation::DomainRegistry` sub-package (`DomainIdentity` + `DomainConfiguration`, Session 143). Activity Awareness is the cross-cutting dimension. Components classified as General (sector-agnostic) or Tailored (sector-specific). The BMM is structurally complete at the General level (Session 81).

The six concerns of a service business:

| Concern | What it covers |
|---|---|
| **ServiceConcept** (C1) | What value is delivered, to whom, and why it is worth paying for |
| **ActivityModel** (C2) | How value is produced and delivered — processes, pathways, workflows |
| **ResourcePlanning** (C3) | What resources and capabilities are required |
| **FinancialPlanning** (C4) | How money flows — revenue, costs, pricing, projections |
| **GovernanceMapping** (C5) | Regulatory requirements, governance processes, risk, learning |
| **[[concept-stakeholder-model\|StakeholderModel]]** (C7) | Relationships, partnerships, cooperative delivery, community, participation — the relational boundary. Six General elements: StakeholderRelationship, CooperativeArrangement, ReferralPathway, ExternalDependency, CommunityRelationship, ParticipationModel (proposed Session 76, designed Session 78, implemented Session 81) |

Activity Awareness (C6) is the cross-cutting dimension: every unit of activity is visible across all six concerns.

**System Meta Model (SMM)** — how a business system *works*. Renamed from "Business System Meta Model" (BSMM) in Session 92 for reduced cognitive friction and better parallel with BMM. The dual-stack architecture makes the SMM explicit for the first time as the right-hand stack. SMM-side model content now includes: [[concept-architectural-section|ArchitecturalSection]] (B27, Session 87) — 1 `part def`, 20 `part` usages, 3 enums, 1 `metadata def`; the reasoning metamodel as a cross-cutting SMM extension (S146-D1, Sessions 146–152); and the deontic governance vocabulary as a hand-authored ontology module (Sessions 121–131). The SMM General vocabulary is organised into six capability groups (B25): Persistence & Data Management, Process Orchestration, Evaluation & Reasoning, Observation & Self-Knowledge, Integration & Communication, Identity & Access — with an architectural role axis (B26) as secondary classification. The SysML section name `bsmm-general-vocabulary` is retained as a structural identifier.

The two meta models are connected by explicit horizontal mappings at every tier: General BMM ↔ General SMM, Tailored BMM ↔ Tailored SMM, individual business models ↔ individual system models. These mappings are first-class, visible, navigable objects — not implicit assumptions. The [[concept-dual-stack-architecture|dual-stack architecture]] (B21, Session 73) formalises this relationship as two parallel vertical stacks with horizontal mappings at every level — see §5.5. See also [[ontara-architecture-business-meta-modelling|Service Business Meta Modelling]] and [[ontara-architecture-clarification-two-meta-models|Two Meta Models Clarification]].

---

## 4. Multi-Tenancy

The multi-tenancy principle ([[concept-multi-tenancy|A13]]) — promoted from T1 candidate to **binding Tier 1** in Session 142 — establishes that only the meta model is core. Every domain — including GenderSense Limited, the primary motivating use case — is a tenant instantiation: an exercise of the system's capabilities against a specific service business.

Domain identity is now structurally expressed across all three representations: SysML (`DomainIdentity` + `DomainConfiguration`, Session 143), OWL (`ontara-domain.ttl`, Session 144), and the generation pipeline (`build_domain_registry()`, Sessions 143–144). The dual-stack split places business intent (`DomainIdentity` — regulatory tier, purpose, jurisdiction) on the BMM side and system settings (`DomainConfiguration` — vocabulary scope, governed activities, organisational form) on the SMM side, connected by explicit horizontal mapping. See [[ontara-discussion-domain-identity-dual-stack-2026-04-05|Domain Identity in the Dual-Stack Architecture (Session 142)]].

Four demonstrator domains validate that the BMM vocabulary generalises across structurally different service businesses ([[concept-cross-domain-validation|J1]]):

| Domain | Character | Regulatory tier |
|---|---|---|
| [[domain-cafe\|Cafe]] | Immediate retail | Generally governed |
| [[domain-suds\|Suds]] | Batch processing | Lightly regulated |
| [[domain-paws\|Paws]] | Appointment-based personal service | Lightly regulated |
| [[domain-ears\|Ears]] | Community ear care (outlined) | Sector-regulated |

GSL is the most important tenant, but it is not more structurally privileged than the demonstrators. Its distinction is purpose (production healthcare delivery) and regulatory tier (sector-regulated). The demonstrators also serve a pedagogical role: making abstract meta model concepts tangible through concrete, relatable examples.

---

## 5. Foundational Architecture

The foundational architecture encompasses the Session 59 discussion papers (coordinate framework, domain identity, temporal reference frames, ontological grounding), the major architectural advances of Session 73 (dual-stack architecture, BFO and OWL 2 DL as mandatory, knowledge graph as canonical store, simulation architecture), and subsequent implementation milestones: knowledge graph implementation (Stage 5, Sessions 100–137), domain identity implementation (Stage 6, Sessions 142–144), and the reasoning metamodel with coordinate framework consolidation (Stage 7, Sessions 146–152).

### 5.1 The coordinate framework

The system's representational space is a multi-dimensional coordinate space, not a hierarchy ([[concept-coordinate-framework|A12]], T1 candidate). Every conceptual entity traces a trajectory through this space. Existing architectural features — coverage matrix, component catalogue, glossary, governance traceability — are projections of the same coordinate space.

The coordinate system test: "Can I add a new axis without refactoring?"

This principle is ontologically grounded in BFO (Basic Formal Ontology, ISO/IEC 21838-2:2021), whose continuant/occurrent/spatiotemporal framework is structurally identical to the coordinate framework's spacetime concept. BFO's "history" (sum of processes in a spatiotemporal region) is the coordinate framework's "trajectory". BFO category determines which mathematical operations are meaningful on each axis.

Session 147 significantly enriched the coordinate framework through the [[ontara-discussion-coordinate-framework-revisited-2026-04-05|consolidation paper]], which reconciled four architectural tensions exposed by the reasoning metamodel:

**Region taxonomy.** Seven extensible subtypes — StaticBoundary, GoalRegion, NormativeRegion, ProbabilityDistribution, ScalarField, ClassificationRegion, FormalisationFrontier — all BFO-grounded. Regions are the primary structuring concept for the coordinate space: they define the areas within which entities and trajectories are evaluated.

**Constraint geometry.** Three constraint types mapped to coordinate-space structures: HardConstraints as NormativeRegion boundaries (violation is failure), SoftConstraints as ScalarField cost surfaces (violation has a measurable cost), GradedRules as ScalarField truth-value surfaces (assertions hold to a degree). This formalisation connects the reasoning metamodel's constraint hierarchy to the coordinate framework's spatial vocabulary.

**Goal-seeking computation reinterpreted.** [[concept-goal-seeking-computation|L9]] is pathfinding through constrained coordinate space: HardConstraints define impassable boundaries, SoftConstraints define cost surfaces, and GradedRules define truth-value surfaces. The system reasons about how to move from where it is to where the operator wants it to be — within the boundaries that governance and physics impose.

**Standing instruction:** Per Ella's direction (Session 147), the [[ontara-discussion-coordinate-framework-revisited-2026-04-05|coordinate framework revisited paper]] should be actively considered for its relevance with every significant piece of work undertaken.

See [[ontara-discussion-coordinate-framework-2026-03-22_1|Coordinate Framework discussion (Session 59)]] and [[ontara-discussion-coordinate-framework-revisited-2026-04-05|Coordinate Framework Revisited (Session 147)]].

### 5.2 Domain identity

Domain identity ([[concept-domain-identity|B15]]) is now **implemented** across all three representations (Sessions 142–144). The Session 59 proposal for a single `DomainDefinition` part def was revised into a dual-stack split that honours [[principle-two-meta-model-distinction|A4]]:

`DomainIdentity` (BMM side, IAO plan_specification) carries business intent: regulatory tier, purpose, jurisdiction. `DomainConfiguration` (SMM side, IAO data_item) carries system settings: vocabulary scope, governed activities, organisational form. The two are connected by an explicit horizontal mapping.

SysML implementation (Session 143): 2 part defs, 6 enums, 8 domain instances. OWL implementation (`ontara-domain.ttl`, Session 144): 2 classes, 6 enumeration classes, 8+8 properties, 8 individuals. Pipeline extension: `build_domain_registry()` in `gen_owl_pipeline.py`. This implementation promoted A13 to binding Tier 1 (S142-D3) and registered B36–B39.

See [[ontara-discussion-domain-identity-dual-stack-2026-04-05|Domain Identity in the Dual-Stack Architecture (Session 142)]].

### 5.3 Temporal reference frames

Different parts of the system experience time in different reference frames ([[concept-temporal-reference-frames|B16]]). Eight illustrative frames are identified: clinical episode time, business planning time, regulatory reporting time, pathway step time, system execution time, audit/evidence time, patient biographical time, research/population time. Vague temporal vocabulary ("after stabilisation", "when appropriate") is a first-class concern, not a defect to be eliminated.

Every event carries an epistemic status ([[concept-epistemic-modality|B17]]), reconciled in Session 147 as three orthogonal dimensions: provenance modality (seven values — actual, inferred, expected, predicted, hypothetical, simulated, retrospectively recorded), functional purpose (five values from [[concept-coordinate-space-snapshots|L8]] — current, historical, goal, hypothetical, projected), and evidential confidence (with declared interpretive frame). These three dimensions compose rather than conflict: a coordinate space snapshot carries all three independently. Composition rules and validity constraints ensure coherent epistemic tagging. See [[ontara-discussion-temporality-reference-frames-2026-03-22-v2.1|Temporality and Reference Frames discussion]] and [[ontara-discussion-coordinate-framework-revisited-2026-04-05|Coordinate Framework Revisited (Session 147)]].

### 5.4 Ontological grounding

BFO (Basic Formal Ontology, ISO/IEC 21838-2:2021) is the **mandatory** upper ontology (B18 — upgraded from directional to binding, Session 73). A layered ontology stack sits between BFO and the meta model vocabularies, all BFO-aligned:

**Platform-level (binding):** CCO (enterprise semantics), IAO (information artefacts), PROV-O (provenance, core subset — added Session 148/150 as S146-D2). **Healthcare sector (binding):** OGMS (general medical science). **Directional:** OCE (commercial exchange), GSSO (gender/sex/sexual orientation). **Deferred:** OBI (biomedical investigations).

The BMM is recognised as a de facto BFO-aligned service business mid-level ontology. All 34 BMM elements carry `@BfoType` annotations (Session 99) declaring their BFO 2020 category and mid-level ontology parent, providing the SysML-side input to the OWL pipeline.

PROV-O provides the provenance foundation for the reasoning metamodel. The dual subclassing pattern (S147-D4) allows reasoning classes to inherit from both BFO and PROV-O parents — a ReasoningActivity is simultaneously a BFO process and a PROV-O Activity, without multiple inheritance conflicts.

See [[ontara-discussion-ontological-grounding-2026-03-22|Ontological Grounding discussion (Session 59)]] and [[ontara-discussion-knowledge-graph-architecture-2026-04-01|Knowledge Graph Architecture (Session 97)]].

### 5.5 The dual-stack architecture

Session 73 produced a major architectural advance: the [[concept-dual-stack-architecture|dual-stack architecture (B21)]], formalising the relationship between the BMM and SMM as two parallel vertical stacks. See the [[ontara-discussion-dual-stack-architecture-2026-03-26|Dual-Stack Architecture discussion paper]] (Session 74) and the [[ontara-discussion-architectural-campus-walk-2026-03-28|Ontara Campus discussion paper]] (Sessions 84–85) for the full 20-section description.

**Left stack (business model):** ontology → domain ontologies → BMM vocabulary → business instance → operational domains → business process patterns. **Right stack (system model):** system ontological categories → SMM vocabulary → system instance → system domains → [[concept-operational-simulation|operational simulation]]. Horizontal mappings connect each level. Rules and constraints govern the dynamic layers (bottom two pairs on both sides) within a bounded container. The [[concept-reflective-simulation|reflective simulation]] is cross-cutting on the right side.

The 20 architectural sections are encoded in the SysML model as [[concept-architectural-section|ArchitecturalSection]] `part` usages (B27, Session 87 — first SMM-side model content), each carrying `@ArchitecturalLocation` and `@PurposiveDescription` metadata. The Ontara Console's Architecture view renders these as an interactive spatial map with progressive disclosure (Session 92).

### 5.6 Ontological formalism and the knowledge graph

**OWL 2 DL** is the mandatory ontological formalism (B23, binding, Session 73). The ontological layers (BFO, mid-level ontologies, platform vocabularies) are represented in OWL 2 DL, not SysML; the meta model and instance layers remain in SysML v2. A mapping ontology (B24) bridges the two formalisms, concretely realised as the correspondence graph — the third stratum of the three-stratum graph architecture (E019).

The **[[concept-knowledge-graph|knowledge graph as canonical store (B22)]]** is a directional commitment: OWL 2 DL in a triple store as the eventual canonical representation, with SysML v2 as an engineering projection. Condition: round-trip translation must preserve all aspects of the model without degradation. This does not violate [[principle-separation-representation-execution|A1]] or [[principle-model-generates-everything|A3]] — the representation remains primary; the question is which formalism carries it.

The knowledge graph architecture (Session 97) established the three-stratum graph (E019): metamodel graph (SysML traceability), domain graph (BFO-grounded semantics — the canonical layer), correspondence graph (explicit mapping records with provenance). Authority zones (E020) govern which side is authoritative: SysML-authoritative for structure, OWL-authoritative for ontological semantics, shared-constrained for labels and definitions.

**Implementation status.** The knowledge graph is operational across three completed phases (Stage 5, Sessions 100–137): GraphDB Free 10.x as triple store with BFO/CCO/IAO stack; 12-file ontology stack loaded and HermiT-verified (CONSISTENT); three layers of automated quality assurance — SPARQL validation (43 queries in 11 groups), OWL 2 DL consistency checking (Robot + HermiT), and round-trip diff (288 semantic units, authority-zone-aware). Hand-authored ontology modules: governance vocabulary (`ontara-governance.ttl`, Session 126), CQC Regulation 12 individuals (`cqc-reg12-individuals.ttl`, Session 131), domain identity vocabulary (`ontara-domain.ttl`, Session 144), reasoning metamodel vocabulary (`ontara-reasoning.ttl`, Sessions 150–152), PROV-O core subset (`prov-core.ttl`, Session 150).

See [[ontara-discussion-knowledge-graph-architecture-2026-04-01|Knowledge Graph Architecture (Session 97)]] and the [[ontara-ref-vision-architecture|Vision and Architecture Reference]] §5.

### 5.7 Simulation architecture

The simulation architecture, conceived in Session 73 and described in the [[ontara-discussion-dual-stack-architecture-2026-03-26|dual-stack discussion paper]], establishes four layered capabilities:

The **[[concept-operational-simulation|operational simulation (L5)]]** is the SMM made live: Temporal workflows coordinating business execution per tenant, with human actors and connected applications as participants. This is not a separate simulation engine — it *is* the running system, governed by and traceable to the model.

The **[[concept-reflective-simulation|reflective simulation (L6)]]** is a cross-cutting capability reading from all architectural layers, producing guidance and insight for the operator. It is imbued with **[[concept-valence|valence (L7)]]** — the operator's declared conception of good vs bad business performance, providing the evaluative dimension that transforms observation into guidance.

**[[concept-coordinate-space-snapshots|Coordinate space snapshots (L8)]]** persist five epistemic types (current, historical, goal, hypothetical, projected) in the knowledge graph as named graphs tagged with epistemic status, timestamp, and provenance. The epistemic modality was reconciled in Session 147 as three orthogonal dimensions (§5.3), enabling fine-grained characterisation of each snapshot.

**[[concept-goal-seeking-computation|Goal-seeking computation (L9)]]** searches for action sequences that move the business from its current state to a goal state — both expressed as coordinate space snapshots. The Session 147 coordinate framework consolidation reinterpreted L9 as pathfinding through constrained coordinate space: HardConstraints define impassable boundaries, SoftConstraints define cost surfaces, and GradedRules define truth-value surfaces.

---

## 6. The Clinical Data Architecture

openEHR is the underpinning architecture for the clinical record. The ecosystem provides viable open-source CDR options (EHRbase), an active specification community, a five-year SNOMED CT collaboration for first-class terminology integration, and a data model (archetypes and templates) that cleanly separates clinical semantics from application logic.

### 6.1 How openEHR fits the architecture

openEHR provides the persistent, semantically structured clinical data layer. Data enters the CDR from two paths: workflow-driven (Temporal activities commit compositions as part of pathway execution) and form-driven (clinicians or patients enter data directly via front-end forms, outside any workflow). Both produce the same kind of structured, queryable, semantically typed data. The CDR does not care how data arrived.

### 6.2 Two views onto the same data

The clinical record supports two fundamentally different but equally necessary views:

The **process view** shows where a patient is in their care pathway — what has happened, what happens next, who is responsible, whether the pathway is on track. Driven by Temporal workflow state and history.

The **entity view** shows the patient's record organised by type of information — demographics, blood results, medications, consultations, assessments, communications, safeguarding. Driven by AQL queries against the CDR, filtering by archetype type.

These are not separate systems. They are two views onto the same underlying data. A blood result committed by a pathway activity appears in both the process audit trail and the blood results entity view.

### 6.3 Standing decisions

**CDR:** EHRbase (open-source, Java/PostgreSQL, Docker-based, REST API). Commercial hosted options exist for later. **Archetype design:** Use the Archetype Designer (Better, web-based). Search the Clinical Knowledge Manager for existing archetypes before creating new ones. **SysML-to-openEHR integration:** Runtime integration (activities commit compositions via REST) is the immediate priority. Model-level integration (generating template definitions from SysML) is a future possibility. **SNOMED CT:** Effectively mandated by the NHS context. Design archetypes with terminology binding slots from the outset.

These decisions were validated through the [[ontara-cdr-exercise-summary-2026-03-08|Coffee Shop CDR Extension Exercise]].

---

## 7. Governance as a First-Class Concern

Governance is an architectural concern, not a reporting add-on ([[principle-clinical-governance-first-class|A8]]). Audit, compliance, and clinical governance capabilities are considered at design time for every pathway and data structure.

### 7.1 The satisfy traceability chain

The structural backbone of governance in Ontara is the satisfy traceability chain: requirement → constraint definition → constraint evaluator → audit evidence record. This chain is modelled in SysML, generated into executable evaluators, and surfaced in the Ontara Console's Governance view. The Suds demonstrator validated this chain with a COSHH governance traceability example.

### 7.2 The deontic governance architecture

Sessions 121–137 established a major architectural workstream: a deontic logic-grounded governance vocabulary and compliance framework, exercised with production-quality regulatory content. This extends the SysML-based traceability chain into the knowledge graph with formal semantic grounding.

**The three-tier compliance architecture.** Library tier — the governance vocabulary and pre-formalised governance frameworks, platform-level shared infrastructure. Activation tier — framework activation and obligation binding to specific tenant service models. Operations tier — real-time compliance monitoring, evidence collection, governance-aware simulation. The library tier is implemented; activation and operations tiers are designed but not yet built.

**The deontic vocabulary** (B30) provides four deontic modalities — Obligation, Prohibition, Permission, RegulatoryPower — as subclasses of `DeonticDirective`, grounded in IAO via BFO. The normative instrument taxonomy (B33) represents the source authority hierarchy from primary legislation through to organisational policy. GovernanceFramework (B31) and ObligationGroup provide curated, versioned collections of directives.

**The CQC Governance MVP** (Sessions 130–131) was the first full exercise: CQC Regulation 12 (Safe Care and Treatment) formalised as 21 individuals (4 normative instruments, 10 statutory obligations, 5 guidance-level directives, 1 obligation group, 1 governance framework) — passing OWL 2 DL consistency checking and SPARQL validation.

**Governance–reasoning alignment** (Session 151): Obligation and Prohibition are declared as HardConstraint subclasses in the reasoning metamodel, meaning governance obligations define NormativeRegion boundaries in the [[concept-coordinate-framework|coordinate space (A12)]]. Compliance has temporal depth: it is a trajectory, not a snapshot. The dependency is unidirectional: `ontara-rsn:` → `ontara-gov:` (reasoning knows about governance); the governance module remains independent per [[concept-authority-zones|B29]].

See [[ontara-discussion-deontic-governance-architecture-2026-04-03|Deontic Governance Architecture (Session 121)]], [[ontara-discussion-deontic-owl-class-design-2026-04-03|Deontic Governance OWL Class Design (Session 125)]], and [[stage5-plan-s.130-cqc-governance-mvp|CQC Governance MVP Plan (Session 130)]].

### 7.3 Population-level governance audit

Beyond individual pathway audit, the architecture supports population-level queries: does every patient have height and weight recorded within six months? What is the state of adherence to blood test monitoring schedules? These are AQL queries against the CDR compared against rules derived from the SysML model. Compliance is the comparison between "what has actually been recorded" and "what should have been recorded, and when."

### 7.4 Clinical decision support

Three levels of decision support, all operating on structured CDR data evaluated against model-derived rules ([[principle-deterministic-over-probabilistic|A6]]):

**Rule-based triggers:** Clinical data meeting certain conditions (e.g. hormone level outside therapeutic range) flags for review. SysML constraint evaluation against CDR query results.

**Pathway triggers:** When conditions are met, automatically initiate a new pathway or referral. A Temporal workflow started programmatically in response to CDR data.

**Self-care support:** Patient-facing interfaces present personalised guidance derived from the same data and rules that inform clinical decisions. Patients see their own results, understand therapeutic ranges, know when monitoring is due, and receive prompted self-assessments. This anticipates the patient autonomy and informed choice principle ([[principle-patient-autonomy|A7]]).

The A6 reformulation (Session 148, T1 amendment) provides the architectural framework for clinical decision support: a four-category scheme distinguishing deterministic rules (Tier 1), inspectable logic (Tier 2), structured probabilistic reasoning (new — with validated models, explicit assumptions, and full provenance), and opaque probabilistic reasoning (Tier 3). This gives Bayesian risk assessment, prognostic modelling, and predictive analytics first-class architectural status while maintaining the auditability that clinical governance demands.

### 7.5 Information governance and cybersecurity direction

Information governance (IG) and cybersecurity are foundational modelling concerns, not implementation details (B20). For a sector-regulated healthcare system, the modelling layer must define the IG and security obligations that the execution layer then implements. This is a cross-cutting concern at the level of Activity Awareness (C6), pervading all six BMM concerns.

Key dimensions include data classification and sensitivity, trust boundaries and access control models, consent and data sharing frameworks, audit and accountability, threat modelling at the business level, resilience and continuity, regulatory compliance surface (GDPR, NHS DSPT, DCB0129/DCB0160, Cyber Essentials Plus), and identity/authentication/authorisation. The existing satisfy traceability chain and the deontic governance vocabulary are the natural governance patterns for IG compliance.

This is captured as E011 in the [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]], partially subsumed by the governance workstream (B30–B35 covers regulatory compliance). See the [[ontara-ref-strategic-snapshot|Strategic Reference]] §6.

---

## 8. External Service Integration

Booking, scheduling, payments, messaging, mobile applications, audio/video consultations, and lab ordering are solved problems with mature APIs. Ontara does not build any of these. It orchestrates them as participants in clinical processes and ensures the data they produce flows into the right places.

Each external service is consumed via a Temporal activity whose implementation is a thin wrapper around an API call. The SysML model defines where in the pathway the integration occurs and what data flows to and from it. The workflow orchestrates the sequence, including retry, timeout, and failure handling via Temporal's durable execution model.

Metadata annotations (extending the `@TemporalActivity`, `@TemporalSignal` patterns from the Coffee Shop demonstrator) mark activity steps as external integration points. The generator produces the activity signature; the implementation is hand-written API integration code. The boundary between generated orchestration and hand-written integration stays clean. This is the metadata-driven generation pattern ([[pattern-metadata-driven-generation|D9]]).

---

## 9. Data Availability and Aggregation

Multiple data sources, each authoritative for its own domain: openEHR for clinical data, Temporal for process state and history, the knowledge graph for ontological semantics and governance structures, external services for operational data. Front-end applications assemble what they need by querying the appropriate sources.

Views aggregate from authoritative sources; they do not maintain separate copies. Any decision that duplicates clinical or process data into a separate store for convenience creates synchronisation problems and undermines the single-source-of-truth principle. The authority zones concept (B29, E020) formalises which store is authoritative for which kind of content.

Security follows the same principle. Each service manages its own access control. The aggregation layer presents only what the requesting user is authorised to see. Clinical data follows NHS information governance. Payment data is PCI-scoped. Process data is role-filtered. See §7.5 for the IG/cybersecurity direction.

---

## 10. Guiding Constraints

These constraints govern architectural decisions to preserve the modularity and adaptability the system requires:

1. **Process knowledge lives in the model, not in code.** Any decision that embeds process logic in application code rather than in the SysML model reduces adaptability. Generated code is a derived artefact ([[principle-model-generates-everything|A3]]).

2. **Clinical data structure lives in archetypes, not in schemas.** Any decision that creates bespoke database tables for clinical data instead of using openEHR compositions reduces interoperability and queryability.

3. **External services are behind activity interfaces, not embedded in workflows.** Any decision that couples workflow logic to a specific provider reduces flexibility. The workflow knows an activity signature; the activity implementation knows the specific service.

4. **Execution components are replaceable; the representation layer is not.** The SysML models, OWL ontologies, and openEHR archetypes carry the knowledge and are the long-term investment ([[principle-separation-representation-execution|A1]]).

5. **Views aggregate from authoritative sources; they do not maintain separate copies.** Any decision that duplicates data creates synchronisation problems. Authority zones ([[concept-authority-zones|B29]]) govern which source is definitive for which content.

6. **Terminology bindings are designed in from the start.** Even in demonstrator exercises, archetypes include terminology binding slots. Retrofitting bindings onto unstructured data is far harder than designing them in.

7. **Governance is a first-class architectural concern.** Audit, compliance, and governance capabilities are considered at design time ([[principle-clinical-governance-first-class|A8]]). Governance obligations are HardConstraints in the reasoning metamodel's terms — they define boundaries, not suggestions.

8. **No modelling without the tool that makes it legible ([[concept-co-evolution|J2]]).** Model extensions and console tooling advance together. A model element that cannot be visualised, navigated, or explained is incomplete.

9. **Decisions should not foreclose future development paths ([[concept-non-constraining|J3]]).** Clean abstractions, loose coupling, discoverable structure. The non-constraining principle applies especially to uncommitted research directions and emerging workstreams. Note: BFO (B18), OWL 2 DL (B23), and multi-tenancy (A13) are now binding commitments; the non-constraining principle applies to their *implementation*, not to the decisions themselves.

10. **The comprehension architecture is structural, not cosmetic.** The system's ability to explain itself — through authored descriptions, structural self-knowledge, weighted relationships, and the evidence architecture — is a first-class architectural commitment, not a documentation layer ([[principle-intrinsic-self-knowledge|A10]], [[principle-unity-principle|A11]]). The comprehension–reasoning convergence (S147-D7) confirmed that comprehension and reasoning share the same underlying structure.

---

## Appendix A: Technical Architecture Patterns

### A.1 Temporal Workflow Durability

A Temporal workflow function is an ordinary TypeScript async function. Each `await` is a durability point — if the worker crashes and restarts, Temporal replays the function from its event history and resumes at the exact point of interruption. The developer writes sequential code; Temporal makes it durable transparently.

### A.2 Temporal Signals for Human-in-the-Loop

When a workflow needs to wait for an external event (a lab returning blood results, a patient completing a self-assessment), it uses Temporal signals. The workflow suspends at an `await`, consuming zero resources. When the signal arrives via API, the workflow resumes. Suspensions can last seconds or months.

### A.3 XState Entity Lifecycle Enforcement

An XState state machine defines valid states and transitions for an entity. It acts as a runtime guard: if any code attempts an unpermitted transition, XState silently rejects it. The machine definition is generated from the SysML state definition, ensuring runtime enforcement matches the model exactly.

### A.4 The Two-Layer Action Flow Pattern

Domain models describe clinical processes for governance audiences. Orchestration models describe system execution for runtime generation. Both derive from the same SysML source but serve different purposes and audiences. This separation ensures clinical governance documentation and runtime behaviour stay in sync without either constraining the other ([[pattern-two-layer-action-flow|D3]]).

---

## Related Documents

- [[ontara-ref-vision-architecture|Vision and Architecture Reference (v9)]] — the authoritative architectural summary
- [[ontara-ref-strategic-snapshot|Strategic Reference]] — current project state, architecture overview, what's next
- [[ontara-ref-master-register|Master Concept Register]] — ~212 concepts across 16 sections (A–P), four tiers
- [[ontara-architecture-platform-modelling-strategy|Platform Modelling Strategy (v3)]] — companion foundations paper
- [[ontara-architecture-business-meta-modelling|Service Business Meta Modelling (v2)]] — companion foundations paper
- [[pattern-index|Validated Architectural Patterns]] — 22 patterns, 8 principles
- [[ontara-discussion-dual-stack-architecture-2026-03-26|Dual-Stack Architecture Discussion]] — Session 73/74
- [[ontara-discussion-architectural-campus-walk-2026-03-28|The Ontara Campus]] — Sessions 84–85, all 20 architectural sections
- [[ontara-discussion-knowledge-graph-architecture-2026-04-01|Knowledge Graph Architecture]] — Session 97, three-stratum graph, authority zones
- [[ontara-discussion-deontic-governance-architecture-2026-04-03|Deontic Governance Architecture]] — Session 121, three-tier compliance architecture
- [[ontara-discussion-domain-identity-dual-stack-2026-04-05|Domain Identity in the Dual-Stack Architecture]] — Session 142
- [[ontara-discussion-institutionalised-reasoning-2026-04-05|Institutionalised Reasoning]] — Session 146, reasoning metamodel
- [[ontara-discussion-coordinate-framework-revisited-2026-04-05|The Coordinate Framework Revisited]] — Session 147, coordinate consolidation
- [[stage7-plan-s.148-reasoning-metamodel|Stage 7 Plan — Reasoning Metamodel]] — Session 148
- [[ontara-discussion-coordinate-framework-2026-03-22_1|Coordinate Framework Discussion]] — Session 59
- [[ontara-discussion-domain-identity-architecture-2026-03-22-v2.1|Domain Identity Discussion (original)]] — Session 59
- [[ontara-discussion-temporality-reference-frames-2026-03-22-v2.1|Temporality and Reference Frames Discussion]] — Session 59
- [[ontara-discussion-ontological-grounding-2026-03-22|Ontological Grounding Discussion]] — Session 59
- [[ontara-discussion-comprehension-architecture-2026-03-19|Comprehension Architecture Discussion]]
- [[ontara-discussion-intrinsic-self-knowledge-v2-2026-03-20|Intrinsic Self-Knowledge Discussion]]
- [[ontara-cdr-exercise-summary-2026-03-08|CDR Exercise Summary]]
- [[SUPERSEDED-ontara-architecture-platform-principles-v3-s96|Architecture Principles v3 (Session 96)]] — previous version
- [[SUPERSEDED-ontara-platform-architecture-principles-v2-s64|Architecture Principles v2 (Session 64)]]
- [[SUPERSEDED-ontara-platform-architecture-principles-v1|Architecture Principles v1]] — original

---

*Architecture Principles v4, Session 154, 6 April 2026. Refreshed from v3 (Session 96, 1 April 2026). See Version History at the head of this document for change summary.*
