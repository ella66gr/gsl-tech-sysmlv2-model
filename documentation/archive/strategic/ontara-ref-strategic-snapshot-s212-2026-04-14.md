---
tags:
  - reference
date: 2026-04-14
status: current
session: 212
---
# Ontara — Strategic Reference
> `= this.file.path`

**Date:** 14 April 2026 (Session 212 refresh)
**Previous version:** Session 203 (13 April 2026), archived as [[SUPERSEDED-ontara-ref-strategic-snapshot-2026-04-14|Strategic Reference (Session 203)]]
**Purpose:** The single orientation and reference document for the Ontara project. Serves at least three audiences:
1. Claude at session open — current state, scale, what's next;
2. Ella after a break or needing orientation or overview — project shape, active workstreams, governance state;
3. Any external reader — what Ontara is and why it matters.
**Status:** Standing reference document. Uses a stable filename — versioning is expressed in the header, not the filename.

---

## Contents

- [[#1. What Ontara Is|§1. What Ontara Is]]
- [[#2. Architecture Overview|§2. Architecture Overview]]
- [[#3. What Is Built|§3. What Is Built]]
- [[#4. Development History and State|§4. Development History and State]]
- [[#5. Key Documents|§5. Key Documents]]
- [[#6. Risks|§6. Risks]]
- [[#7. Where Things Live|§7. Where Things Live]]
- [[#8. Technology Stack|§8. Technology Stack]]

---

## 1. What Ontara Is

**Ontara** is a service system development, delivery, and **execution** platform, particularly strong in supporting regulated care service delivery.

The name evokes a grounding in ontology, a sense of being and essence, along with an intuition of awareness of self. This reflects the deeper foundational principles and deliberately holistic design ethos of the platform — the basis for a highly sophisticated, self-aware, and technically advanced ecosystem.

Ontara encompasses all layers of the system: metamodels, configured business and system models, the State Representation Stratum that holds runtime instance content, the Platform Realisation Stratum that enacts configured models through realising components, the generation pipeline, the comprehension architecture, and the developer and architect tooling (the Ontara Console and the Ontara Portal). Ontara is not the name of one component. It is the name for the whole.

### 1.1 The architectural thesis

A model — held canonically in OWL 2 DL in the Knowledge Graph, with a SysML v2 engineering projection for selected content — serves as the single source of truth for what a service business is, how it works, what rules govern it, and how the technology platform supports it. The model *generates* the running system rather than merely documenting it. The model also comprehends itself — it can explain what it contains and why.

Ontara is an **execution platform**, not merely a generation tool. This is established, not aspirational. The coffee shop demonstrator is a running system generated from the model; the Stage 8 portal is a state-driven operator surface running against the platform; the Stage 9 foundation papers established how the currently separate islands — SysML model, console, portal, execution layer, customer-facing UI — connect into a coherent, model-grounded system through bindings at the boundary between the State Representation Stratum and the Platform Realisation Stratum.

This contrasts with the typical situation where the model of a business supported by a technical system is implicit, incomplete, and scattered across code, configuration, documentation, and in people's heads. Mapping the system to the business model — or vice versa — is usually a painful, incomplete, expensive exercise that produces limited benefit. Ontara's thesis is that this problem is solvable: make the model explicit, make it generative, make it self-describing, and make it comprehensible.

### 1.2 GenderSense Limited

**GenderSense Limited (GSL)**, a private gender-affirming healthcare service, is the primary motivating use case and the first production tenant. Ella Green is the founder of GSL, the sole developer and architect of Ontara, and a GP specialist in gender identity healthcare (NHS East of England Gender Service and private practice).

Under the [[concept-multi-tenancy|multi-tenancy principle (A13)]], GSL is the most important tenant — but still a tenant. It is not structurally privileged over the demonstrator domains; its distinction is purpose (production healthcare delivery) and regulatory tier (sector-regulated).

### 1.3 Platform identity

Ontara meets the technical definition of a platform as distinct from a product or framework: modular architecture with standardised interfaces; abstraction and generality through metamodels; lifecycle support from design through operation; evolutionary stability through versioning, the [[concept-non-constraining|non-constraining principle (J3)]], and the PatternCatalogue; ecosystem enablement through dual-canvas tooling and metamodel-defined palettes; composability, extensibility, and integrated tooling.

---

## 2. Architecture Overview

### 2.1 The stratified two-side architecture

The Ontara platform architecture is organised by two orthogonal compositional commitments: **six ontological strata** running vertically, and **two sides** running through the strata where the strata are divided. Together these two commitments form the **stratified two-side architecture** — the strengthened formulation of [[principle-two-meta-model-distinction|A4]] committed to in [[ontara-architecture-platform-principles|Architecture Principles v5]] §3. Every architectural entity in the platform has a determinable locus in the resulting grid. A4 was originally formulated as the claim that the project maintains two distinct meta models; that claim is preserved, but it is now visible as one consequence of a deeper structural commitment rather than as a freestanding fact.

**The six strata** (from top to bottom):

| # | Stratum | Content |
|---|---|---|
| 1 | **Foundation** | Upper and mid-level ontologies: BFO 2020, CCO, IAO, PROV-O, OGMS. Shared across both sides. Expressed exclusively in OWL 2 DL. |
| 2 | **Formalism Boundary** | The architectural locus where canonical OWL meets the SysML v2 projection: mapping ontology, correspondence graph, `@BfoType` annotations, OWL pipeline mapping rules, [[concept-authority-zones\|authority zone declarations]]. Shared, bilingual. |
| 3 | **Metamodel** | The structural vocabulary: BMM on the business side, [[concept-smm-general-vocabulary\|SMM]] on the system side. Both General (sector-agnostic) and Tailored (sector-specific) content live at this stratum. |
| 4 | **Configured Model** | Tenant-specific configurations: **Business Model (BM)** on the business side, **System Model (SM)** on the system side, one each per tenant. Produced by configuration from the metamodels. |
| 5 | **State Representation (SRS)** | All runtime model-grounded instance content: snapshots tagged by epistemic character, instances of reasoning and governance metamodel classes, guidance reports, workflow execution records, binding observation records. Persisted as Knowledge Graph triples. Internally split by epistemic character (`current/actual`, `historical`, `goal`, `hypothetical`, `projected`, `counterfactual`), not by structure. |
| 6 | **Platform Realisation (PRS)** | The running infrastructure: GraphDB, Temporal, EHRbase, the Customer Portal, the Developer Console, terminology services, the Syside Modeler. Realising components *realise* configured models through the verb sense of realisation — they enact them at runtime. Interacts with the SRS through **bindings**: typed contracts carrying metadata for instantiation mode, freshness profile, production marker, and authority zone. |

**The activity flows are not a stratum.** Real-world business activity and simulated activity flows sit below the PRS as the world the architecture engages with — represented by the SRS and driven through PRS bindings, but not themselves a level of the architecture.

**The two sides** run through the strata where the strata are divided. The Foundation and Formalism Boundary strata are shared across both sides; the Metamodel, Configured Model, State Representation, and Platform Realisation strata are each split into a business-side content and a system-side content. The only connection between the two sides is through explicit [[concept-horizontal-mappings|horizontal mappings]] at each stratum where the sides are distinct.

**The compositional structure.** Two orthogonal commitments — six strata, two sides — define **ten distinct architectural loci**: one shared Foundation, one shared Formalism Boundary, and four further strata each split into two sides, yielding 2 + (4 × 2) = 10. Any architectural entity can be located unambiguously in this grid.

The strengthened A4 rules out five category errors (see [[ontara-architecture-platform-principles|Architecture Principles v5]] §3.4): cross-stratum conflation, cross-side identification, Foundation duplication, projection mistaken for canonicity, and metamodel runtime confusion. The last of these retires phrasings such as "BMM runtime state" and "SMM runtime state" — metamodels and configured models are static structural vocabularies and have no runtime state; only SRS instance content has runtime state.

Two renamings were committed in the v5 refresh. The runtime-state acronym on the system side is **SR (System Runtime state)** — renamed from BS for symmetry with BR (Business Representation, the business-side current-tagged SRS content). The dual-stack ([[concept-dual-stack-architecture|B21]]) is now understood as a consequence of the strengthened A4 rather than a freestanding commitment — it is what the strengthened A4 looks like at the Metamodel and Configured Model strata when drawn as parallel vertical structures.

### 2.2 The six concerns of a service business

| Concern | What it covers |
|---|---|
| **ServiceConcept** (C1) | What value is delivered, to whom, and why it is worth paying for |
| **ActivityModel** (C2) | How value is produced and delivered — processes, pathways, workflows |
| **ResourcePlanning** (C3) | What resources and capabilities are required |
| **FinancialPlanning** (C4) | How money flows — revenue, costs, pricing, projections |
| **GovernanceMapping** (C5) | Regulatory requirements, governance processes, risk, learning |
| **[[concept-stakeholder-model\|StakeholderModel]]** (C7) | Relationships, partnerships, cooperative delivery, community, participation — the relational boundary. Six General elements (proposed Session 76, detailed design Session 78, implemented Session 81) |

Plus **Activity Awareness** (C6) as the cross-cutting dimension — every unit of activity is visible across all six concerns.

### 2.3 Governing principles

| # | Principle | One-line test |
|---|---|---|
| [[principle-separation-representation-execution\|A1]] | Separation of representation and execution | Under the strengthened A4, the structural boundary between the upper strata and the Platform Realisation Stratum, mediated by bindings |
| [[principle-self-describing-system\|A2]] | Self-describing system | The SRS is queryable in the same vocabulary as the configured model it instantiates |
| [[principle-model-generates-everything\|A3]] | Model generates everything | The Knowledge Graph is canonical; SysML v2 is an engineering projection of selected content |
| [[principle-two-meta-model-distinction\|A4]] | Stratified two-side architecture | Six strata, two sides, ten architectural loci. Every entity has a determinable locus. Strengthened in v5 §3 |
| [[principle-deterministic-over-probabilistic\|A6]] | Deterministic/auditable reasoning | Authoritative decisions follow deterministic, inspectable paths; structured probabilistic reasoning permitted with validated models, explicit assumptions, and full provenance. Reformulated Session 148 (T1 amendment) |
| [[principle-discipline-as-load-bearing-structure\|A9]] | Discipline as load-bearing structure | Disciplined practices propagate reliability; regression applies to practices, not just code. Extended in v5 §1.3 to cover bounded agents — an agent is guided by model truth, not by prompt cleverness |
| [[principle-intrinsic-self-knowledge\|A10]] | Intrinsic self-knowledge | System explanations are dynamically computed from live SRS content |
| [[principle-unity-principle\|A11]] | Unity principle | One weighted relationship model, one canonical SRS, one query vocabulary — every subsystem reads the same content through the same vocabulary. Empirically validated at two levels: comprehension–reasoning convergence (S147-D7) at the reasoning level; constraint hierarchy as architectural spine (S207 D28) at the surface level |
| [[concept-coordinate-framework\|A12]] | Coordinate framework | The SRS *is* the coordinate space made queryable. **Promoted from T1 candidate to binding T1 in v5** (S211) on the strength of the operational realisation provided by the SRS |
| [[concept-multi-tenancy\|A13]] | Multi-tenancy | Only the metamodel is core; every domain is a tenant instantiation. Promoted from T1 candidate to binding T1 Session 142 |
| [[concept-co-evolution\|J2]] | Co-evolution | No modelling without the tool that makes it legible; no tool without model content |
| [[concept-non-constraining\|J3]] | Non-constraining | Decisions should not foreclose future development paths |

**Five-principle unification hypothesis (OW-77).** Architecture Principles v5 §2.4 tested whether A2, A10, A11, A12, and [[concept-coordinate-space-snapshots|L8]] are five independent commitments or five facets of one underlying architectural fact — the SRS as the homogeneous queryable stratum. **Test 1 passed for Architecture Principles v5**: all five principles can be stated as consequences of the strengthened A4 without introducing new content. Tests 2 and 3 remain to be run for [[ontara-architecture-platform-modelling-strategy|Platform Modelling Strategy]] v5 and [[ontara-architecture-business-meta-modelling|SBMM]] v4. The register is not reduced — the principles survive as separately named commitments because they are useful as separate names for aspects of the one underlying fact.

### 2.4 The comprehension architecture

The system explains itself through three registers of content, now located structurally under the strengthened A4:

| Register | Content | Locus |
|---|---|---|
| **Authored** | Human-written purposive descriptions | `@PurposiveDescription` metadata at the Metamodel and Configured Model strata. 34/34 BMM coverage; 20/20 architectural section coverage |
| **Structural** | Facts the model already knows — type, relationships, containment | Dynamically computed from SRS queries via `@Comprehension` metadata traversal |
| **Inferential** | Derived explanations — analogies, gap analysis, impact propagation, evidence-backed claims | Produced by reasoning-metamodel-grounded realising components reading and writing SRS content (Claims, EvidenceLines, ConfidenceAssessments) via PROV-O provenance |

96 [[concept-weighted-relationships|weighted relationships]] across 33 weighted elements, directional and non-commutative. The comprehension architecture is, under the strengthened A4, the operator-facing surface of the State Representation Stratum.

### 2.5 Foundational architecture

The foundational architecture comprises the structural commitments the strengthened A4 sits on: the coordinate framework, domain identity, temporal reference frames, the ontological grounding stack, and the surface architecture vocabulary.

**The coordinate framework ([[concept-coordinate-framework|A12]])** is now binding Tier 1 (promoted in v5 §5.1). The SRS is the coordinate space made queryable: each snapshot is a position in the space, each trajectory is a sequence of snapshots, the [[ontara-discussion-coordinate-framework-revisited-2026-04-05|Region taxonomy from Session 147]] (seven BFO-grounded subtypes) is the catalogue of kinds of region expressible as queries, and the constraint geometry maps the three-way constraint hierarchy onto coordinate-space structures. A12's standing instruction holds: the [[ontara-discussion-coordinate-framework-revisited-2026-04-05|coordinate framework revisited paper]] should be actively considered for its relevance with every significant piece of work undertaken.

**Domain identity ([[concept-domain-identity|B15]])** is implemented across all three representations: SysML (`DomainIdentity` + `DomainConfiguration`, Session 143), OWL (`ontara-domain.ttl`, Session 144), and the generation pipeline. The dual-stack split places business intent on the business side and system settings on the system side, connected by explicit horizontal mapping at the Configured Model stratum.

**Temporal reference frames ([[concept-temporal-reference-frames|B16]])** identifies eight illustrative frames. **[[concept-epistemic-modality|Epistemic modality (B17)]]** is reconciled as three orthogonal dimensions (provenance modality × functional purpose × evidential confidence) per the Session 147 consolidation.

**The ontological grounding stack** is mandatory at the Foundation stratum: BFO 2020 as upper ontology; CCO + IAO + PROV-O platform-level (binding); OGMS healthcare-sector (binding); OCE and GSSO directional; OBI deferred. All 36 BMM `part def` elements carry `@BfoType` annotations. The PROV-O dual subclassing pattern (S147-D4) allows reasoning classes to inherit from both BFO and PROV-O parents — seven dual-subclassed classes.

**Ontological formalism and the knowledge graph.** OWL 2 DL is mandatory ([[ontara-ref-master-register|B23]]). **The Knowledge Graph as canonical store ([[concept-knowledge-graph|B22]]) is promoted from directional to binding in v5 §5.6** — the condition (round-trip fidelity) was satisfied by Session 137 and the architectural reality had been understated by continuing to call it directional. Under KG-canonical, the architecture is one canonical formalism (OWL in the KG) with a secondary engineering projection (SysML) used for human authoring of selected content. Hand-authored OWL modules (`ontara-governance.ttl`, `ontara-domain.ttl`, `ontara-reasoning.ttl`, `prov-core.ttl`, `ears-reasoning-instances.ttl`) are first-class canonical content with no SysML projection. The SysML model is not a complete view of the platform — it is a complete view only of the parts that are projectable.

**The Domain Portability Architecture (DPA)** is a named structural concern that v5 holds writing discipline against without designing. Per-tenant content portability is the question of whether a tenant's slice of Configured Model and SRS content, together with its binding configuration, can be exported in a structured, bounded, self-contained form and reciprocally imported without loss. Tracked as [[ontara-ref-work-item-tracker|W-053]]. KG-canonical makes the DPA's natural format space clear: any portable format must be RDF-based or RDF-derivable (TriG, N-Quads, JSON-LD). The DPA-informed writing discipline (OW-83) is held throughout v5.

### 2.6 The State Representation Stratum

The SRS contains seven kinds of content: snapshots tagged by epistemic character (the primary content); instances of [[concept-reasoning-metamodel|reasoning metamodel]] content (Claims, EvidenceLines, EvidenceItems, ConfidenceAssessments, Decisions, Plans, control loop evaluations, safety constraint assessments); instances of governance metamodel content (obligation bindings, audit evidence records, compliance assessment outcomes); guidance reports (first-class SRS content, not transient UI outputs); workflow execution records on the system side; binding observation records; and platform-global content (subject to the DPA being designed). All seven share four defining properties: instance content of model concepts, persisted as KG triples, queryable in the same vocabulary as the model concepts they instantiate, and carrying PROV-O provenance.

**The simulation architecture as expressions of the SRS.** [[concept-operational-simulation|L5]], [[concept-reflective-simulation|L6]], [[concept-valence|L7]], [[concept-coordinate-space-snapshots|L8]], and [[concept-goal-seeking-computation|L9]] are, under the strengthened A4, natural consequences of the SRS being homogeneous, queryable, and epistemically tagged, rather than five independent capabilities. L5 (operational simulation) is the system-side runtime: SR is the machinery that produces system-side runtime instances from inputs, real or synthetic. L6 (reflective simulation) reads SRS content across both sides and produces further SRS content (guidance reports, gap analyses, counterfactual reconstructions). L8 (coordinate space snapshots) is the SRS's epistemic tagging mechanism. L9 (goal-seeking computation) is a search over SRS content — pathfinding through constrained coordinate space.

**Real-world and synthetic activity are indistinguishable at the SRS level.** This is one of the most substantive findings the strengthened A4 forces (v5 §5.7.5, registered as [[ontara-ref-work-item-tracker|OW-76]]). When real-world activity flows in through interface endpoints and synthetic activity is produced by simulation generators, the SRS records produced are structurally identical, distinguished only by three things: the source of the activity, the epistemic tag, and which realising components are bound to the run at the SRS/PRS boundary. The consequence boundary that matters for governance and safety is not in the SRS content — it is in the binding configuration. The Stage 8 promotion path (hypothesis → production) is a rebinding of realising components, not a change to the modules, snapshots, or machinery. The platform has one architecture, not two.

### 2.7 The Platform Realisation Stratum and bindings

The PRS contains the running infrastructure — the realising components that enact the configured models. **Bindings** live at the boundary between the SRS and the PRS: typed contracts declaring which realising components read and write which SRS content, carrying metadata for instantiation mode, freshness profile, production marker, and authority zone. Every interaction between a realising component and SRS content is mediated by a binding.

**Action class is a deterministic computation from binding metadata.** The principal Ontara-specific contribution of the [[ontara-discussion-surface-architecture-and-bindings-2026-04-12|S198 architect-analyst workspace paper]] is the insight that risk classification of an action falls out of the binding metadata rather than being asserted by hand. An agent proposing an action proposes a binding-mediated SRS write; the action class is computed from the binding; the agent's capability matrix determines whether it is permitted. This is the operational expression of the [[principle-discipline-as-load-bearing-structure|A9]] extension: the agent is guided by model truth (binding metadata), not by prompt cleverness.

### 2.8 Surface architecture

Surface architecture is the family of structural commitments about how the platform connects to its users. The core vocabulary was established in Sessions 198–207 and absorbed into [[ontara-architecture-platform-principles|Architecture Principles v5]] §5.9.

**Seven working user bands** capture how a user relates to the platform's substrate, from band 1 (the consuming customer) to band 7 (the platform developer). The bands are non-constraining per [[concept-non-constraining|J3]] — a working hypothesis validated against three structurally different demonstrators (Cafe, Paws, Suds) and revisable as new domains are intaken. Registered as [[ontara-ref-master-register|B41]].

**Surface families** ([[ontara-ref-master-register|B42]]) are the unit of cross-band consistency: a set of band-specific surfaces sharing canonical truth through shared experience-API contracts. A surface family is not necessarily a single screen-based application — S207's Suds walk-through established that a band 1 deployment is often a cluster of artefacts (mobile app, printed receipt, SMS) unified by shared contracts.

**The experience-API / BFF layer** ([[ontara-ref-master-register|B43]]) is a Stage 9 architectural addition sitting between the SRS and band-specific surfaces. It is the locus where SRS content is shaped into band-appropriate contracts. Currently absent from Ontara; its design is a principal Stage 9 concern.

**The headless five-layer architecture** ([[ontara-ref-master-register|B44]]) names the vertical slice: substrate (SRS), domain logic (configured model content), experience-API, band-specific surfaces, infrastructure.

**State placement discipline** ([[ontara-ref-master-register|J15]]) — the surface-side application of the unity principle. Canonical state lives once in the SRS; band-appropriate content is assembled from it through band-appropriate experience-API contracts.

**The constraint hierarchy as architectural spine (S207 D28).** Stage 7 established the three-way constraint hierarchy (HardConstraint, SoftConstraint, GradedRule) at the reasoning metamodel level. Session 207's Suds walk-through established that the same hierarchy maps to three distinct UI affordance types at multiple bands: prevention / suggestion / ranking at band 3; gates / warnings / scoring at band 5. The same canonical state surfaces consistently without per-surface re-implementation. This is empirical confirmation of A11 at the surface level — the second empirical anchor for A11 alongside the Session 147 comprehension–reasoning convergence at the reasoning level. Both findings are the same claim: one canonical model, surfacing consistently through every realising component that reads it. Registered as [[ontara-ref-master-register|D28]] and treated in [[ontara-architecture-platform-principles|Architecture Principles v5]] §7.3.

**The Stage 8 portal as a band 5 surface.** The Stage 8 Customer Portal, originally framed as "the operator surface", is now understood as a band 5 surface within a larger surface family. The reframing is a re-positioning, not a rebuild — the portal continues to exist and work as-is.

---

## 3. What Is Built

### 3.1 The SysML model

| Metric | Value |
|---|---|
| Top-level packages | 12 (including provisional `ArchitecturalStructure`) |
| Total packages | ~74 |
| Core model files | 12 `.sysml` files |
| PatternCatalogue | 22 patterns, 8 principles, 33 domain instantiations, ~43 typed `ref` relationships |
| BMM elements | 36 `part def`s + 2 `requirement def`s across 6 concern packages + `Foundation::DomainRegistry` sub-package (`DomainIdentity` + `DomainConfiguration`) |
| SMM elements | 1 `part def` ([[ontara-ref-master-register\|ArchitecturalSection (B27)]]), 20 `part` usages, 3 enums, 2 metadata defs (`@ArchitecturalLocation`, `@BfoType`). OWL axioms: 6 concern-group disjointness declarations, 14 object properties, 9 cardinality restrictions, 96 reified weighted relationship individuals |
| Comprehension annotations | 34/34 `@UserFacing`, 34/34 `@PurposiveDescription`, 34/34 `@Comprehension`, 34/34 `@BfoType`, 96 `@WeightedRelationship` (BMM). 20/20 architectural section coverage |
| Typed cross-references | 12 BMM attributes migrated from String to typed `ref` |

### 3.2 Demonstrator domains

| Domain | Character | Regulatory tier | Status |
|---|---|---|---|
| [[domain-cafe\|Cafe]] | Immediate retail, walk-in, 2-minute cycle | Generally governed | Full BMM + running application |
| [[domain-suds\|Suds]] | Batch processing, weight/type pricing | Lightly regulated | Full BMM (6 concerns) + COSHH governance chain. Cross-domain walk-through S207 |
| [[domain-paws\|Paws]] | Appointment-based, breed/size surcharges | Lightly regulated | General vocabulary + StakeholderModel. Cross-domain walk-through S206 |
| [[domain-ears\|Ears]] | Community ear care, clinical pathway | Sector-regulated | Analytical intake complete (S161–168, W-015). 86.2% Full coverage; ~83 reasoning instances; 25/42 reasoning classes exercised |

### 3.3 The Ontara Console

| Metric | Value |
|---|---|
| Stack | SvelteKit + Svelte 5 runes + Flowbite Svelte + Tailwind v4 |
| Views | 13 (Home, Coverage Matrix, Package Navigator, Component Catalogue, Glossary, Governance, Meta-Model, Patterns, Domain Views, Weighted Relationship Graph, Architecture, Ontology). Reasoning Vocabulary Explorer added S158 (42 classes in 7 modules, 15 named individuals, 50 properties, 32 cross-module axioms) |
| Navigation | Global console navigation context ([[ontara-ref-master-register\|I19]]): Svelte 5 reactive NavigationStore, semantic breadcrumb trail, page state capture/restore, journey export. 6 routes registered |
| Data source | `model-introspection.json` generated from SysML via `gen_model_introspection.py` |
| Role (under strengthened A4) | Band 6/7 architect-analyst surface (partial) |

### 3.4 The Ontara Portal

| Metric | Value |
|---|---|
| Stack | SvelteKit + Svelte 5 runes + Flowbite Svelte + Tailwind v4 + SQLite (better-sqlite3) + bcryptjs |
| Role (under strengthened A4) | Band 5 surface (operations and governance) |
| Features | 10-module catalogue (6 business + 2 generative + 2 analytical); two intersecting lifecycle state machines (installation + operational); state-landscape dashboard with inline lifecycle actions; BMM-concern-structured domain context with schema-driven configuration; module composition guidance with lifecycle impact warnings; simulation with batch event generation and comparative analytics; progressive governance (exploratory/advisory/enforced) with 20 typed constraints (8 hard, 6 soft, 6 graded); promotion path with 5-prerequisite wizard and demotion; production visual treatment; lifecycle governance guards |
| Status | Stage 8 formally closed S185 (11 sessions, within 19–31 estimate). Stage 9 portal reframing ([[ontara-ref-work-item-tracker\|OW-48]]) pending — substrate replacement SQLite → KG-resident BR/SR through bindings |

### 3.5 The Coffee Shop demonstrator application

Full-stack reference implementation: 9 frontend pages, 19 API routes, Temporal workflow (FulfilDrink with XState lifecycle), EHRbase CDR (3 archetypes, AQL queries), PostgreSQL (4 tables). The cafe demonstrator frontend is, under the strengthened A4, a mixed-band legacy surface across bands 2–4 that will be reframed as several band-clean surfaces during Stage 9 ([[ontara-ref-work-item-tracker|OW-57]]).

### 3.6 Generation pipeline and knowledge graph tooling

**Seven operational Python generators:** `gen_model_introspection.py`, `gen_concept_graph.py`, `gen_package_hierarchy.py`, `gen_system_manifest.py`, `gen_constraint_evaluator.py`, `gen_decision_table_evaluator.py`, `projection_engine.py`. Shared SysML parser module: `sysml_parser.py` (Session 104).

**Knowledge graph pipeline (Stage 5):** `gen_owl_pipeline.py` (SysML → OWL/Turtle via declarative mapping rules), `setup_graphdb.py`, `validate_kg.py` (SPARQL validation suite, 66 queries in 12 groups), `reason_kg.py` (Robot + HermiT full OWL 2 DL consistency checking), `diff_kg.py` (round-trip diff engine, 288 semantic units, authority-zone-aware). Shared KG utilities: `kg_utils.py` (8 IRI prefixes).

**13-file ontology stack, HermiT CONSISTENT.** Platform-level imports: BFO 2020, CCO, IAO, PROV-O core subset (`prov-core.ttl`, 73 triples, S150). Hand-authored canonical modules: `ontara-bmm.ttl` (34 OWL classes), `ontara-bmm-properties.ttl` (14 object properties), `ontara-bmm-weights.ttl` (96 reified individuals, 702 triples), `ontara-bmm-axioms.ttl`, `ontara-correspondence.ttl` (1,378 triples), `ontara-governance.ttl` (deontic vocabulary + CQC Regulation 12 individuals, 9-file stack S126), `ontara-domain.ttl` (domain identity, 2 classes, 6 enums, 8 individuals, S144), `ontara-reasoning.ttl` (reasoning metamodel, 42 classes, 15 named individuals, 40 object properties, 10 datatype properties, 7 PROV-O dual-subclassed classes, 2 cross-module governance alignment axioms), `ears-reasoning-instances.ttl` (~83 named individuals, `ears-rsn:` namespace, S166). Robot v1.9.8 JAR in `tools/`.

Under KG-canonical, the pipeline's role is sharpened: it materialises the canonical OWL form of SysML-projectable content. Hand-authored OWL modules are canonical content with no SysML projection.

### 3.7 Knowledge base (Obsidian vault)

| Metric | Value |
|---|---|
| Concept graph notes | ~97 (16 patterns, 11 principles, 70 concepts, 6 domains, 3 deferred, + 2 indices). Concept count 60→70 at W-039/W-040 (S189–S191) |
| [[ontara-ref-master-register\|Master register]] entries | ~220+ concepts across 16 sections (A–P), four tiers. B40–B44 (four-level distinction, sophistication gradient, surface family, experience-API, headless architecture), J15 (state placement discipline), D28 (constraint hierarchy → UI affordance mapping), D29 (governance dashboard pattern) added at S207 (partial W-043) |
| Discussion papers | 42 (flat structure with External/ subfolder). Most recent: the Stage 9 foundation papers (S192, S195, S196, S197, S198/S200, S199) |
| Session reports | ~212 (Sessions 28–S211) |
| [[ontara-workflow-emergent-ideas-log\|Emergent Ideas Log]] entries | 30 (E001–E030). E030 (counterfactual analysis as epistemic mode, S179) most recent |

---

## 4. Development History and State

### 4.1 Session history

| Range | Focus |
|---|---|
| 1–4 | Coffee shop demonstrator Phases A–D |
| 8–10 | Hormone therapy initiation clinical pathway |
| 11–15 | Knowledge layer elaboration |
| 16–22 | Business meta model (7 phases, 19 sessions) |
| 23–32 | CSW Extension (10 phases) |
| 33–34 | Concept Graph and Knowledge Graph Enhancement |
| **35** | **Ontara named.** Vision, six-layer architecture, console vision, demonstrator strategy |
| 36–55 | Stage 1–3 (Phases 1–4): introspection, console build, comprehension metadata (28/28, 79 weights) |
| 56–58 | Knowledge base enrichment, Stage 3 Phase 5 (typed-ref migration). **Stage 3 closed S58** |
| 59 | Foundational architecture — coordinate framework, domain identity, temporality, ontological grounding |
| 61–68 | Workflow guide v2, rebaselining workstream, foundations papers v2, vault reorganisation. **Closed S68** |
| 72 | Stage 4 Phase 1 begun — weighted relationship graph |
| **73–74** | **Dual-stack architecture.** BFO/OWL 2 DL mandatory. Knowledge graph as canonical store (directional). Simulation architecture (L5–L9) |
| 76–81 | StakeholderModel (sixth BMM concern) — proposed, designed, implemented. **BMM structurally complete at General level** |
| 84–88 | Campus walk, ArchitecturalSection SysML implementation (first SMM-side model content), visual architecture map |
| 92–93 | BSMM→SMM rename decision and implementation |
| 95 | First systematic documentation review |
| 97 | Knowledge graph architecture (9 binding decisions, three-stratum graph E019, authority zones E020) |
| 98–99 | `@BfoType` mapping designed and applied (34/34) |
| 100–107 | **Stage 5 Phase 1 — KG implementation.** GraphDB, BFO/CCO/IAO loaded, ontara BMM ontology authored, OWL pipeline. **Phase 1 closed S107** |
| 111–120 | **Stage 5 Phase 2** — ontological enrichment, disjointness axioms, object properties, cardinality restrictions, Robot + HermiT integration, typed ref extraction, weighted relationship mapping. **Phase 2 closed S120** |
| 121–137 | Deontic governance workstream. CQC Governance MVP (S130–131). Stage 5 Phase 3 (round-trip diff engine). **Phase 3 closed S137** |
| 138 | Fourth systematic documentation review |
| 141–144 | **Stage 6 Block A — Domain Identity.** A13 promoted to binding T1. `ontara-domain.ttl`. 11-file stack |
| 146–159 | **Stage 7 — Reasoning metamodel.** Institutionalised reasoning and coordinate framework revisited papers (S146, S147). A6 T1 amendment. `ontara-reasoning.ttl` with 42 classes, PROV-O dual subclassing, evidence architecture, constraint hierarchy, structured probabilistic types, STAMP/STPA, FRAM-ready slots. **Stage 7 closed S159** |
| 160–168 | **Clinical Domain Intake Framework** + **[[domain-ears\|Ears]] analytical intake** (W-015). Domain description, vertical connection map, coverage map (86.2% Full), reasoning instances (~83), design note. [[ontara-ref-work-item-tracker\|OW register]] established S167 |
| 172 | Sixth systematic documentation review. Downstream concept note source drift identified (OW-13) |
| 173 | Modelling Paradigm Reference created. Downstream concept note check convention |
| **174–185** | **Stage 8 — Ontara Portal.** Discussion paper, plan (5 phases, 19–31 sessions estimate). Portal delivered in 11 sessions: auth, domain CRUD, 10-module catalogue, two intersecting lifecycle state machines, BMM-concern-structured domain context, module wiring, composition guidance, epistemic dimension, simulation, comparative analytics, progressive governance, promotion/demotion, production visual treatment, lifecycle governance guards. **Stage 8 closed S185** |
| 187 | Vision & Architecture Reference v11 refresh |
| 188 | Seventh systematic documentation review |
| 189–191 | Concept graph note content currency (W-039/W-040) — 6 principle rewrites, 9 new + 27 rewrites. Concept count 60→70 |
| **192–193** | **Connecting the Stacks discussion paper** — Stage 9 framing. 8 design decisions, 7 open questions |
| **195** | **Model and Meta Model Distinction discussion paper.** Four-level model established (Foundation → Metamodel → Configured model → Runtime instance). BM and SM named as configured models distinct from BMM and SMM |
| **196** | **Architectural Clarification note.** Four-layer model resolved, operational simulation terminology tightened, reflective simulation clarified |
| **197** | **BS Substrate and Bindings paper.** BR/BS as dynamic aspects of BM/SM; KG as substrate for runtime state; observational binding pattern; horizontal mapping rule vocabulary; binding registry. First Stage 9 foundation paper |
| **198** | **The Architect-Analyst Workspace (surface architecture).** Three-layer interaction model, bounded agent roster, capability matrix, Ask/Plan/Simulate/Act modes, binding-grounded action class risk classification. Second Stage 9 foundation paper. Fully revised S200 (W-048) |
| **199** | **Surface Families: Headless Composition.** Seven working user bands, headless five-layer architecture, experience-API/BFF layer, state placement discipline, Cafe walk-through. Four-level vocabulary (metamodel/configured model/runtime instance/realising component) given its own section. Third Stage 9 foundation paper |
| 200 | S198 full revision (W-048) — retitled *The Architect-Analyst Workspace*, rescoped to user band 6, dual-dated S198/S200 |
| 201 | Vision & Architecture Reference refreshed to v12 (W-038) — new §15 Stage 9 architectural foundation |
| 201–202 | Governance housekeeping block (partial): W-047 metamodel terminology normalisation, W-042 BMM/SMM runtime state cleanup, README.md rewrite to S202 |
| 203 | Strategic snapshot refreshed (S194→S203). OW-31 concept graph content currency convention. OW-36 discoverability scan satisfied |
| 204 | Foundations papers currency assessment. W-049 scoped (initially as targeted §12 updates). W-050/W-051 deposited |
| 205 | **Seventh systematic documentation review** (W-051): 7 findings (F1, F3, F4, F5 fixed in-session; F2/F6/F7 awareness). R&B Index currency check (W-050) |
| 206 | Paws cross-domain walk-through. OW-66 through OW-70 deposited (ServiceSubject/ServiceParticipant propagation, band 1 temporal split, band 6 domain-insensitivity, governance dashboard pattern domain-posture-independence, sole-trader band compression). Console data source currency check (no action) |
| **207** | **Suds cross-domain walk-through.** **Constraint-hierarchy-as-architectural-spine finding (D28)** — the S207 empirical confirmation of A11 at the surface level. Governance dashboard pattern promoted (D29 candidate, OW-69 satisfied, OW-75). Hardware peripheral integration concern (OW-74). Band 1 as cluster of artefacts (OW-71). Concurrent band 2–3 sharing (OW-72). Partial W-043 update: B40–B44, J15, D28, D29 registered |
| **208** | **Strengthened A4 reformulation workshop.** KG-canonical raised from directional to binding. A12 candidate for T1 promotion. BS → SR rename proposed. Six-stratum frame named (Foundation, Formalism Boundary, Metamodel, Configured Model, State Representation, Platform Realisation). DPA named (W-053). W-049 reframed from targeted to full conceptual rewrite. W-052 glossary build deposited. OW-76 through OW-85 deposited |
| 209 | Integrated workshop document produced. Ten-loci count correction (OW-86) |
| **210** | **Architecture Principles v5 partial draft.** §3 (stratified two-side architecture — six strata, two sides, ten loci), §5 (nine subsections), §2 (self-describing system with five-principle unification Test 1 passed). ~11,000 words. A12 promoted to binding T1. B22 promoted to binding. BS → SR rename committed. v4.1 archived by Ella before drafting. Container artifact held in WORKSHOP folder |
| **211** | **Architecture Principles v5 completed.** §1 (separation principle with A9 extension on bounded agents), §4 (multi-tenancy with §4.1 DPA-informed writing discipline), §6 (openEHR as SRS via bindings to EHRbase), §7 (governance with new §7.3 constraint hierarchy as architectural spine — S207 D28 finding landing as empirical confirmation of A11 at the surface level, the second empirical anchor for A11 alongside S147), §8 (external service integration as binding pattern generalisation), §9 (data availability with KG-canonical locus of canonicity), §10 (expanded to twelve constraints with J15 state placement discipline as constraint 11 and prohibition 5 metamodel runtime confusion as constraint 12), Appendix A, Related Documents. v5 replaced v4.1 at canonical filename at C6. OW-211-1 through OW-211-7 deposited. **Strategic snapshot refresh deferred to S212 (compounded governance breach acknowledged and recorded)** |

### 4.2 Current state

| Workstream | Focus | Status |
|---|---|---|
| Stages 1–3 | Foundations, console, comprehension | Closed S107 (Stage 4 Phase 1), S58 (Stage 3) |
| Stage 4 Phase 1 | Structural navigation — weighted relationship graph, configuration table | Closed S107 |
| Dual-stack architecture (as B21) | Session 73 foundational advance | Preserved as a consequence of the strengthened A4 in v5 §5.5 |
| StakeholderModel | Sixth BMM concern | Complete S76–S81. BMM structurally complete at General level |
| Stage 5 Knowledge graph implementation | Phases 1–3 | All closed (S107, S120, S137). No active Stage 5 work items |
| Stage 6 Domain Identity | Block A | Complete S141–S144. Block B (governance activation tier) future work |
| Deontic governance | Vocabulary, CQC MVP, S151 governance–reasoning alignment | Library tier implemented; activation and operations tiers designed but not yet built |
| Stage 7 Reasoning metamodel | 5 phases | **Closed S159.** 42 classes, 15 named individuals, 40 object properties, 10 datatype properties, 7 PROV-O dual-subclassed, 2 governance alignment axioms. Cross-domain validated. Deferred: P4-2 evidence browser, P4-3 decision trace (require instance data) |
| Clinical domain intake | Ears analytical intake (W-015) | **Complete S160–S168.** 86.2% Full coverage. Vocabulary adequate at Ears-level complexity. GSL will test at production complexity |
| Stage 8 Ontara Portal | 5 phases | **Closed S185.** 11 sessions. 35 OW items tracked. Portal is a band 5 surface under the strengthened A4 framing |
| Concept graph note content currency | W-039/W-040 | Complete S189–S191. Concept count 60→70. Currency convention established (20-session cadence); next content currency due ~S211 (one session overdue at S212 open) |
| **Stage 9 architectural foundation (S192–S207)** | Four foundation papers + strengthened A4 work + cross-domain walk-throughs | **Complete.** Connecting the Stacks (S192–193), Model and Meta Model Distinction (S195), Architectural Clarification (S196), BS Substrate and Bindings (S197), The Architect-Analyst Workspace (S198/S200), Surface Families (S199). Paws and Suds cross-domain walk-throughs (S206, S207). Constraint-hierarchy-as-architectural-spine finding (S207 D28) — second empirical anchor for A11 |
| **Strengthened A4 and Architecture Principles v5** | W-049 partial (v5 complete) | **Architecture Principles v5 complete S211.** Absorbs the S208/S209 strengthened A4 work (six strata, two sides, ten loci). B22 promoted to binding. A12 promoted to binding T1. BS → SR rename committed. SRS and PRS strata named. Surface architecture vocabulary absorbed into §5.9. §7.3 constraint hierarchy as architectural spine. Five-principle unification hypothesis Test 1 passed. Platform Modelling Strategy v5 and SBMM v4 pending in dedicated future sessions |
| **Foundations papers refresh (W-049)** | Architecture Principles + Platform Modelling Strategy + SBMM | **Architecture Principles v5 complete S211.** Platform Modelling Strategy v5 and SBMM v4 remain to draft. Previous versions: Architecture Principles v4.1 (S170), Platform Modelling Strategy v4.1 (S170), SBMM v3.1 (S170) |
| Systematic documentation review | Every ~15 sessions | **Seventh review complete S205** (W-051, 7 findings). Next due ~S220 |
| Vision & Architecture Reference | Authoritative architectural summary | v12 (S201). Next due ~S213 |
| Work item tracker | Authoritative work item status | Established S128. Document Currency Register added S141. Observation and Watchpoint Register added S167; currently ~96 items |

### 4.3 What comes next

**Current position (Session 212 close).** Architecture Principles v5 is complete and replaces v4.1 at the canonical filename. The strengthened A4 (six strata, two sides, ten architectural loci) is committed as the structural ground of the platform. The Knowledge Graph is now binding-canonical ([[concept-knowledge-graph|B22]]). The coordinate framework ([[concept-coordinate-framework|A12]]) is promoted to binding Tier 1. The State Representation Stratum and Platform Realisation Stratum are named. The BS → SR rename is committed. The surface architecture vocabulary (seven user bands, surface families, experience-API layer, headless five-layer architecture, state placement discipline) is absorbed into the foundations paper layer. The constraint hierarchy as architectural spine is the second empirical anchor for A11. The strategic snapshot is refreshed to S212 (breaking the compounded governance breach from the S210/S211 deferrals).

The ontology stack, SPARQL suite, and knowledge graph tooling remain stable (13 files, 66 queries, HermiT CONSISTENT). The Stage 8 portal continues to run as a band 5 surface. The Ears intake remains the most recent cross-domain validation of the reasoning vocabulary.

**Immediate priorities (production work resuming):**

- **W-049 remainder.** [[ontara-architecture-platform-modelling-strategy|Platform Modelling Strategy]] v5 and [[ontara-architecture-business-meta-modelling|SBMM]] v4 in dedicated future sessions per the S208 foundations refresh plan §6 sequence. Test 2 and Test 3 of the five-principle unification hypothesis run as each paper is drafted.
- **Concept graph source drift scan for Architecture Principles v5** (workflow guide §7.1 downstream concept note check). Targeted scan covering notes referencing v4.1 or earlier, notes for reframed principles (A1, A2, A4, A8, A9, A10, A11, A12), notes for promoted concepts (B22, A12), notes for renamed content (BS → SR), and notes for v5-introduced content (SRS, PRS, Formalism Boundary stratum, six strata, ten loci, constraint hierarchy as architectural spine).
- **W-043.** Master register additions for the S197/S198 substrate and surface concepts, plus the v5 strengthened A4 register treatment (the five-principle unification consequence — register entries should reference the strengthened A4 as structural ground rather than stating each principle as an independent claim). Best done after all three foundations papers are complete so the full picture is in view.
- **W-045.** Campus Walk II and architecture diagram revision — deferred until the v5 strata framing settles across all three foundations papers.
- **W-052.** Ontara glossary build as a standing reference document.
- **W-053.** Domain Portability Architecture design — substantive workstream in its own right; required before cross-tenant and platform-global content can be realised in the SRS.
- **Stage 9 plan production.** Once W-043 and Campus Walk II are complete and the three foundations papers are in place, full Stage 9 scoping can begin. The seven open questions from [[ontara-discussion-connecting-the-stacks-2026-04-10|Connecting the Stacks]] (Q1–Q7) remain the core outstanding design questions.

**Stage 9 open questions (Q1–Q7 from Connecting the Stacks, still current).** These are framed precisely by the strengthened A4 but not resolved by it.

1. **Q1 — BMM runtime state store.** Under the strengthened A4, this is answered at the level of principle: runtime state lives in the SRS, persisted as KG triples. What remains is the engineering question of the knowledge graph's role expansion to runtime instance substrate — write throughput, transaction semantics, named graph organisation, query load, round-trip diff relationship ([[ontara-ref-work-item-tracker|OW-39]]).
2. **Q2 — Horizontal mapping implementation.** The rules and machinery that keep both sides synchronised as state changes propagate. The strengthened A4 frames the problem precisely; Stage 9 resolves the implementation ([[ontara-ref-work-item-tracker|OW-33]]).
3. **Q3 — Module-derived-from-model boundary.** What does S192-D7 mean at the data level? Which aspects of a portal module are generated from the model, which are portal-native, and which come from the OWL vocabulary ([[ontara-ref-work-item-tracker|OW-32]]).
4. **Q4 — Customer kiosk scope.** What exactly does the kiosk SvelteKit application (S192-D8) involve? Under the strengthened A4, a kiosk is a band 1 surface in a band 1 surface family.
5. **Q5 — Connection sequence and acceptance criteria.** In what order should the connections be established, and what does each step prove ([[ontara-ref-work-item-tracker|OW-35]]).
6. **Q6 — Console integration.** What does the console show about running infrastructure? The binding registry surfaces a new console view candidate — "which model elements have live infrastructure bound to them, with what freshness" ([[ontara-ref-work-item-tracker|OW-40]]).
7. **Q7 — Portal-to-console traceability.** How tight should the traceability be between portal configuration and console model view? Under the strengthened A4, this is about how band 5 and band 6 surfaces coordinate across their shared substrate ([[ontara-ref-work-item-tracker|OW-49]]).

**Incremental governance currency (as of S212 close).**

| Document | Current as of | Next due |
|---|---|---|
| Strategic snapshot | **S212 (this refresh)** | ~S219 |
| Vision & Architecture Reference v12 | S201 | ~S213 |
| Architecture Papers Index | S200 | ~S212 — due for currency check |
| Architecture Principles v5 | S211 | ~S226 |
| Platform Modelling Strategy | S204 assessment; v4.1 from S170 | v5 drafting pending (W-049) |
| SBMM | S204 assessment; v3.1 from S170 | v4 drafting pending (W-049) |
| R&B Index | S205 | ~S212 — due for currency check |
| Claude Tooling Guide | S192 | ~S212 — due for currency check |
| README.md | S202 | ~S214 |
| Console data source currency | S206 | ~S218 |
| Modelling Paradigm Reference | S194 | ~S214 |
| Concept graph note content currency | S191 (W-040) | ~S211 — one session overdue |
| Systematic documentation review | S205 (W-051, seventh review) | ~S220 |
| OW register | Active | ~96 items; several satisfied or incorporated during Stage 9 foundation work |

**Horizon.** GSL-specific clinical domain work (connecting portal to real clinical content). Simulation architecture prototyping. Governance ontology editing tooling (E022). Portal substrate replacement (SQLite → KG-resident BR/SR through bindings, [[ontara-ref-work-item-tracker|OW-48]]). Experience-API / BFF layer design ([[ontara-ref-work-item-tracker|OW-56]]). Bounded agent implementation. Counterfactual analysis (E030) as a first-class epistemic mode. Hardware peripheral integration for bands 1 and 2 ([[ontara-ref-work-item-tracker|OW-74]]). Cafe demonstrator frontend reframing as band-clean surfaces ([[ontara-ref-work-item-tracker|OW-57]]). Ella's architectural diagram revision to reflect the strengthened A4 (W-045, Campus Walk II).

---

## 5. Key Documents

### Orientation

| Document | Purpose |
|---|---|
| **This document** | Strategic reference — orientation, state, what's next |
| [[ontara-ref-vision-architecture\|Vision and Architecture Reference (v12)]] | Authoritative architectural summary (Session 201) |
| [[ontara-ref-master-register\|Master Concept Register]] | ~220+ concepts across 16 sections (A–P), four tiers — the governance backbone |

### Foundations

| Document | Purpose |
|---|---|
| [[ontara-architecture-platform-principles\|Architecture Principles (v5)]] | **Governing principles, stratified two-side architecture, foundational architecture, clinical data, governance, external services, data availability, guiding constraints (Sessions 210–211 full conceptual rewrite).** Absorbs the S208/S209 strengthened A4 work |
| [[ontara-architecture-platform-modelling-strategy\|SysML Modelling Strategy (v4.1)]] | Package architecture, reasoning stack, concentric rings of rigour (Session 65; refreshed Session 170). **v5 pending** (W-049) |
| [[ontara-architecture-business-meta-modelling\|Service Business Meta Modelling (v3.1)]] | The BMM comprehensive reference (Session 67; refreshed Session 170). **v4 pending** (W-049) |
| [[—— ARCHITECTURE INDEX ——\|Architecture Papers Index]] | Curated reading order for all architecture papers |

### Development

| Document | Purpose |
|---|---|
| [[ontara-workflow-guide\|Development Workflow Guide (v2)]] | Shared operating agreement — session lifecycle, document handling, model development |
| [[ontara-ref-work-item-tracker\|Work Item Tracker]] | Authoritative work item status, Document Currency Register, Observation and Watchpoint Register |
| [[ontara-guide-claude-tooling\|Claude Tooling Guide]] | Chat / Code / Cowork allocation |
| [[ontara-workflow-emergent-ideas-log\|Emergent Ideas Log]] | Ideas captured at inception (30 entries, E001–E030) |
| [[ontara-ref-modelling-paradigms\|Modelling Paradigm Reference]] | 11 modelling paradigms with exploitation status (Session 173) |

### Stage 9 architectural foundation papers

| Document | Purpose |
|---|---|
| [[ontara-discussion-connecting-the-stacks-2026-04-10\|Connecting the Stacks]] | Sessions 192–193. Stage 9 framing. 8 design decisions, 7 open questions |
| [[ontara-discussion-model-meta-model-distinction-2026-04-11\|Model and Meta Model Distinction]] | Session 195. Four-layer model. BM and SM as configured models distinct from BMM and SMM |
| [[ontara-discussion-architectural-clarification-2026-04-12\|Architectural Clarification Note]] | Session 196. Reflective simulation clarified; operational simulation terminology tightened |
| [[ontara-discussion-bs-substrate-and-bindings-2026-04-12\|BS Substrate and Bindings]] | Session 197. BR/BS as dynamic aspects of BM/SM; KG as substrate; observational binding. First Stage 9 foundation paper |
| [[ontara-discussion-surface-architecture-and-bindings-2026-04-12\|The Architect-Analyst Workspace]] | Sessions 198/S200. Band 6 surface architecture; bounded agents; binding-grounded action classes |
| [[ontara-discussion-surface-families-headless-composition-2026-04-13\|Surface Families: Headless Composition]] | Session 199. Seven user bands; headless five-layer architecture; four-level vocabulary; Cafe walk-through |
| [[WORKSHOP-s208-a4-reformulation-INTEGRATED\|S208/S209 Integrated Workshop Document]] | Sessions 208–209. The strengthened A4 canonical source material; DPA section; five-principle unification hypothesis. The source for v5 §3, §5.7, §5.8, §5.9, and §2 unification treatment |

### Earlier discussion papers (selected)

| Document | Purpose |
|---|---|
| [[ontara-discussion-dual-stack-architecture-2026-03-26\|Dual-Stack Architecture]] | Session 73/74. Historical foundation paper. B21 now a consequence of the strengthened A4 |
| [[ontara-discussion-knowledge-graph-architecture-2026-04-01\|Knowledge Graph Architecture]] | Session 97. Three-stratum graph, authority zones |
| [[ontara-discussion-deontic-governance-architecture-2026-04-03\|Deontic Governance Architecture]] | Session 121. Obligation vocabulary, three-tier compliance architecture |
| [[ontara-discussion-institutionalised-reasoning-2026-04-05\|Institutionalised Reasoning]] | Session 146. Reasoning metamodel, PROV-O, evidence architecture |
| [[ontara-discussion-coordinate-framework-revisited-2026-04-05\|The Coordinate Framework Revisited]] | Session 147. Epistemic reconciliation; constraint geometry; comprehension–reasoning convergence. **Standing instruction: actively consider for relevance with every significant piece of work** |
| [[ontara-discussion-portal-state-driven-operator-experience-2026-04-08\|Portal: State-Driven Operator Experience]] | Session 174. Stage 8 foundation paper |
| [[ontara-discussion-clinical-domain-intake-framework-2026-04-07\|Clinical Domain Intake Framework]] | Session 160. Domain intake methodology |

### Technical reference

| Document | Purpose |
|---|---|
| [[ontara-ref-weighted-relationship-heuristics-and-config\|Weighted Relationship Heuristics and Configuration]] | Weight assignment heuristics (H1–H5) and full weight table |
| [[ontara-ref-weighted-relationship-directionality-definition\|Directionality Definition]] | Directional semantics for weighted relationships |
| [[ontara-ref-shell-commands\|Shell Command Reference]] | Generator and console commands |
| [[ontara-ref-kerml-reserved-words\|KerML Reserved Words]] | Names to avoid in SysML part defs |

---

## 6. Risks

| # | Risk | Mitigation |
|---|---|---|
| R1 | **Single developer.** Ella is sole developer, architect, and domain expert | Model-driven approach ensures knowledge lives in the model. Comprehension architecture means the model explains itself. Claude (Chat, Code, Cowork) extends capacity |
| R2 | **Clinical pathway validation.** Architecture claims to generalise clinical processes | Three non-clinical demonstrators validate metamodel generality. [[domain-ears\|Ears]] analytical intake complete as second clinical domain (Sessions 161–168, W-015). Vocabulary assessed as adequate at Ears-level complexity. GSL will test at production complexity |
| R3 | **Generation pipeline partial.** Seven generators operational; additional targets designed but not built | Built as needed following [[concept-co-evolution\|J2]] |
| R4 | **Clinical data layer untouched since CSW Phase E.** CDR patterns validated in coffee shop; clinical archetypes not designed for GSL | Patterns proven. Extension is a candidate workstream |
| R5 | **Reasoning formalisms.** Inferential comprehension depends on reasoning architecture | **Fully addressed by Stage 7 and validated by Ears intake.** The reasoning metamodel (Sessions 146–158) provides the complete OWL vocabulary: 42 classes, 15 individuals, 40 properties, 7 PROV-O dual-subclassed, 2 cross-module governance alignment axioms. Comprehension–reasoning convergence (S147-D7) now joined by the S207 constraint-hierarchy-as-architectural-spine finding as a second empirical anchor for A11. Structured probabilistic types await GSL validation (OW-05) |
| R6 | **Silent regression risk.** ~220+ concepts and growing complexity | Tiered register with T1 session-start review. [[ontara-workflow-guide\|Workflow guide]] mandates register checks. 66-query SPARQL validation suite. [[ontara-ref-work-item-tracker\|OW register]] surfaces observations at the right time via work type taxonomy. The strengthened A4 makes architectural locus determinable for every entity, forcing rather than permitting conceptual precision |
| R7 | **Foundational architecture progressively committed.** Session 59 papers were working documents; Session 73 made BFO and OWL 2 DL mandatory; Session 208 promoted KG-canonical to binding and A12 to binding T1 (committed S211) | BFO (B18), OWL 2 DL (B23), KG-canonical (B22), multi-tenancy (A13), and the coordinate framework (A12) are now binding. The strengthened A4 (§3 of Architecture Principles v5) is the principle-level frame within which Stage 9 implementation proceeds. B16–B17 remain directional; B17 reconciled as three orthogonal dimensions (Session 147) |
| R8 | **Two-formalism complexity.** OWL 2 DL + SysML v2 introduces a mapping boundary | Under KG-canonical, the architecture is one canonical formalism (OWL in the KG) with a secondary engineering projection (SysML). The mapping ontology (B24) is concretely realised as the correspondence graph (E019). Authority zones (E020) govern which side is authoritative. The round-trip diff engine verifies projection fidelity. Hand-authored OWL modules are canonical content with no SysML projection |
| R9 | **DPA not yet designed.** Per-tenant content portability is a structural concern that the strengthened A4 makes visible. Cross-tenant and platform-global content cannot be realised until the DPA exists | DPA-informed writing discipline held throughout Architecture Principles v5 (OW-83). No v5 commitment forecloses portability. Any portable format must be RDF-based or RDF-derivable. Tracked as W-053 for future design work |

---

## 7. Where Things Live

### Obsidian vault

`/Users/ellagreen/Obsidian/GenderSense` under `02 ONTARA/`:

| Folder | Contents |
|---|---|
| [[—— START HERE ——\|01 —— START HERE ——]] | Strategic reference, vision & architecture reference, master register, work item tracker, workflow guide, non-technical overview, emergent ideas log, modelling paradigm reference |
| [[—— DEVELOPMENT INDEX ——\|02 Ontara Development]] | Reference & guides, plans (by stage), session reports & prep notes (by decade), WORKSHOP folder |
| [[SUPERSEDED—— CONCEPT GRAPH INDEX ——2026-04-10\|03 Ontara Concept Graph]] | Concept, pattern, principle, domain, deferred notes — wikilink targets |
| [[—— ARCHITECTURE INDEX ——\|04 Ontara Architecture]] | All architecture papers — foundations, discussion papers, design decisions. Flat, single subfolder (External/) for reference PDFs |
| [[—— DEMONSTRATORS INDEX ——\|05 Ontara Demonstrators]] | Per-domain material for Cafe, Suds, Paws, Ears |
| [[—— RESEARCH & BACKGROUND INDEX ——\|06 Ontara Research & Background]] | External research and investigation notes |
| [[—— HISTORY & ARCHIVE INDEX ——\|07 Ontara History & Archive]] | Superseded documents, old snapshots, pre-Ontara analysis |

### Code repository

`~/Developer/gsl-tech/gsl-sysml-model` (GitHub: `ella66gr/gsl-tech-sysmlv2-model`):

| Folder | Contents |
|---|---|
| `model/` | SysML v2 model files (SysML projection of canonical KG content) |
| `exercises/` | Demonstrator domains |
| `scripts/` | Generation pipeline (7 Python generators), shared `sysml_parser.py`, KG tooling (`gen_owl_pipeline.py`, `setup_graphdb.py`, `validate_kg.py`, `reason_kg.py`, `diff_kg.py`), shared `kg_utils.py`, `scripts/archive/` for superseded generators |
| `console/` | Ontara Console (SvelteKit) — band 6/7 architect-analyst surface (partial) |
| `portal/` | Ontara Portal (SvelteKit + SQLite) — band 5 surface |
| `generated/` | Generated artefacts: `generated/ontara/` (JSON, diff report), `generated/ontology/` (OWL/Turtle, correspondence, mapping IR) |
| `ontology/` | KG configuration and hand-authored canonical vocabularies: `ontology/config/` (mapping rules YAML, CCO IRI lookup JSON), `ontology/imports/` (BFO 2020, CCO, IAO, PROV-O core subset), `ontology/governance/` (governance vocabulary, CQC Regulation 12 individuals), `ontology/domain/` (domain identity vocabulary), `ontology/reasoning/` (reasoning metamodel vocabulary), `ontology/catalog-v001.xml` (Robot IRI resolution) |
| `tools/` | External tooling: Robot v1.9.8 JAR (HermiT reasoner wrapper) |
| `documentation/` | Reference documents and archived vault snapshots |

### Archive paths

| Document type | Repo location |
|---|---|
| Strategic/governance | `documentation/archive/strategic/` |
| Plans | `documentation/archive/plans/` |
| Session reports | `documentation/archive/session-reports/` |
| Design documents | `documentation/archive/design/` |

Preparation notes are vault-only — not archived to repo.

---

## 8. Technology Stack

| Component | Technology |
|---|---|
| Modelling language | SysML v2 (engineering projection of canonical KG content) |
| Modelling tool | Syside Modeler (VS Code extension) |
| Canonical ontological formalism | OWL 2 DL (binding, Session 73). Triple store: GraphDB Free 10.x (local, port 7200, OWL-Horst Optimized ruleset). Reasoner: Robot v1.9.8 wrapping HermiT for full OWL 2 DL consistency checking. Ontology authoring: Protégé 5.6+. IRI scheme: `https://ontara.dev/ontology/` (vocabulary), `https://ontara.dev/data/` (instances). Platform-level imports: BFO 2020, CCO, IAO, PROV-O (core subset). The Knowledge Graph as canonical store ([[concept-knowledge-graph\|B22]]) is now **binding** (promoted in Architecture Principles v5 §5.6) |
| Ontara Console | SvelteKit + Svelte 5 runes + Flowbite Svelte + Tailwind v4. 3D relationship graph: `3d-force-graph` + Three.js r183 + `three-spritetext`. Role under strengthened A4: band 6/7 architect-analyst surface (partial) |
| Ontara Portal | SvelteKit + Svelte 5 runes + Flowbite Svelte + Tailwind v4 + SQLite (better-sqlite3) + bcryptjs. Warm teal theme. Stage 8 complete (S175–S185). Role under strengthened A4: band 5 surface. Stage 9 portal reframing pending — substrate replacement SQLite → KG-resident BR/SR through bindings |
| Coffee Shop app | SvelteKit + Temporal + XState v5 + EHRbase CDR + PostgreSQL. A mixed-band legacy surface to be reframed as band-clean surfaces in Stage 9 |
| Generation pipeline | Python 3 (7 generators + OWL pipeline). Dependencies: `rdflib`, `PyYAML`. Shared parser: `sysml_parser.py` |
| Knowledge base | Obsidian |
| Version control | Git / GitHub (both repo and vault) |
| AI collaboration | Claude Chat (MCP filesystem), Claude Code (terminal + Obsidian CLI), Claude Cowork |
| Development environment | macOS, VS Code |

---

*Strategic reference created Session 69 (24 March 2026). Refreshed at Sessions 74, 82, 88, 93, 99, 106, 111, 120, 127, 138, 145, 153, 159, 169, 177, 186, 194, 203, and 212. This Session 212 refresh incorporates Sessions 194–211: the Stage 9 architectural foundation (S192–S200 four papers; S206–S207 cross-domain walk-throughs at Paws and Suds; S207 constraint-hierarchy-as-architectural-spine finding); the S208/S209 strengthened A4 reformulation workshop and the DPA as a named structural concern; the S210/S211 Architecture Principles v5 full conceptual rewrite (six strata, two sides, ten architectural loci; SRS and PRS strata named; Formalism Boundary as its own stratum; BS → SR rename; B22 promoted to binding; A12 promoted to binding T1; five-principle unification hypothesis Test 1 passed; new §7.3 on the constraint hierarchy as architectural spine; twelve guiding constraints including J15 state placement discipline and prohibition 5 metamodel runtime confusion); the seventh systematic documentation review (S205); the W-047 metamodel terminology normalisation and W-042 BMM/SMM runtime state cleanup; the V&A Reference v12 refresh (S201); the README.md rewrite (S202); the Ears intake completion (S160–S168); and the partial W-043 master register updates at S207 (B40–B44, J15, D28, D29). Stable filename — versioning expressed in the header.*

GenderSense Limited.
