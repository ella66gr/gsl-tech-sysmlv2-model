---
tags:
  - reference
date: 2026-04-04
status: current
session: 138
---
# Ontara — Strategic Reference
> `= this.file.path`

**Date:** 4 April 2026 (Session 138 refresh)
**Previous version:** Session 127 (4 April 2026), archived as [[SUPERSEDED-ontara-ref-strategic-snapshot-S120|Strategic Reference (Session 120)]]
**Purpose:** The single orientation and reference document for the Ontara project. Serves at least three audiences:
1. Claude at session open — current state, scale, what's next;
2. Ella after a break — project shape, active workstreams, governance state;
3. any external reader — what Ontara is and why it matters.
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

The name evokes a grounding in ontology, a sense of being and essence, along with a feminine intuition of awareness of self. This reflects the deeper foundational principles and deliberately holistic design ethos of the platform — the basis for a highly sophisticated, self-aware and technically advanced ecosystem.

Ontara encompasses all layers of the system: meta models, business models, system models, the execution platform, the generation pipeline, the comprehension architecture, and the developer/architect tooling (the Ontara Console). Ontara is not the name of one component. It is the name for the whole.

### 1.1 The architectural thesis

A model (conceived originally as residing in canonical form within SysML.v2, but in any event held as the **primary source** wherever it lives) serves as the single source of truth for what a service business is, how it works, what rules govern it, and how the technology platform supports it. The model *generates* the running system rather than merely documenting it. The model also comprehends itself — it can explain what it contains and why.

Ontara is an **execution platform**, not merely a generation tool. This is established, not aspirational — the coffee shop demonstrator is a running system generated from the model, the [[ontara-discussion-paper-process-specification-layer-2026-03-27|process specification layer]] describes the full pipeline from model to deployed Temporal workflows, and [[principle-separation-representation-execution|A1]] has always said representation *propagates to* execution. Session 73 made the runtime architecture explicit: the model does not generate code and step aside — it generates systems that remain connected to the model at runtime through the [[concept-operational-simulation|operational simulation (L5)]], where the running system's state *is* the business model made live (§2.7).

This contrasts with the typical situation where the model of a business supported by a technical system is implicit, incomplete, and scattered across code, configuration, documentation, and in people's heads. Mapping the system to the business model — or vice versa — is usually a painful, incomplete, expensive exercise that produces limited benefit. Ontara's thesis is that this problem is solvable: make the model explicit, make it generative, make it self-describing, and make it comprehensible.

### 1.2 GenderSense Limited

**GenderSense Limited (GSL)**, a private gender-affirming healthcare service, is the primary motivating use case and the first production tenant. Ella Green is the founder of GSL, the sole developer and architect of Ontara, and a GP specialist in transgender healthcare (NHS East of England Gender Service and private practice).

Under the [[concept-multi-tenancy|multi-tenancy principle (A13)]], GSL is the most important tenant — but still a tenant. It is not structurally privileged over the demonstrator domains; its distinction is purpose (production healthcare delivery) and regulatory tier (sector-regulated).

### 1.3 Platform identity

Ontara meets the technical definition of a platform as distinct from a product or framework: modular architecture with standardised interfaces; abstraction and generality through meta models; lifecycle support from design through operation; evolutionary stability through versioning, the [[concept-non-constraining|non-constraining principle (J3)]], and the PatternCatalogue; ecosystem enablement through dual-canvas tooling and meta-model-defined palettes; composability, extensibility, and integrated tooling.

---

## 2. Architecture Overview

### 2.1 The six-layer architecture

| Layer | Name | Content |
|---|---|---|
| 6 | Meta-meta level | SysML v2 itself — the language and Syside Modeler |
| 5 | Business Meta Model (BMM) | Structural template for what a service business *is*: 34 elements across 6 concerns |
| 4 | System Meta Model (SMM) | Structural template for how a business system *works*. Renamed from BSMM, Session 92 |
| 3 | Business model instances | Specific service businesses: GSL, Cafe, Suds, Paws |
| 2 | System model instances | Concrete implementations |
| 1 | Runtime | The running system — generated and governed by the model |

### 2.2 The two meta model distinction ([[principle-two-meta-model-distinction|A4]])

- **Business Meta Model (BMM)** — what a service business *is*. 34 elements across six concerns. Components classified as General (common to most service businesses) or Tailored (sector-specific).
- **System Meta Model (SMM)** — how a business system *works*. Renamed from "Business System Meta Model" (BSMM) to "System Meta Model" (SMM) in Session 92 for reduced cognitive friction and better parallel with BMM. Currently distributed across Foundation, Knowledge, ServiceDelivery, Platform, Operations, PatternCatalogue. Session 73 began making the SMM explicit through the [[concept-dual-stack-architecture|dual-stack architecture (B21)]] — the right-hand stack of a two-column structure with horizontal mappings to the BMM at every level. Note: model files, generators, and console code were renamed Session 93; vault reference documents updated Session 94. Some historical discussion papers and `@ArchitecturalLocation`/`@PurposiveDescription` SysML annotation strings still use "BSMM". The SysML section name `bsmm-general-vocabulary` is retained as a structural identifier.

Connected by explicit horizontal mappings at every tier (General BMM ↔ General SMM, Tailored BMM ↔ Tailored SMM, Individual business models ↔ Individual system models).

### 2.3 The six concerns of a service business

| Concern               | What it covers                                                                                                                                                                                                                                                                                                                                                   |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **ServiceConcept**    | What value is delivered, to whom, and why it is worth paying for                                                                                                                                                                                                                                                                                                 |
| **ActivityModel**     | How value is produced and delivered — processes, pathways, workflows                                                                                                                                                                                                                                                                                             |
| **ResourcePlanning**  | What resources and capabilities are required                                                                                                                                                                                                                                                                                                                     |
| **FinancialPlanning** | How money flows — revenue, costs, pricing, projections                                                                                                                                                                                                                                                                                                           |
| **GovernanceMapping** | Regulatory requirements, governance processes, risk, learning                                                                                                                                                                                                                                                                                                    |
| **StakeholderModel**  | Relationships, partnerships, cooperative delivery, community, participation — the relational boundary.<br><br>Six general stakeholder elements:<br><br>StakeholderRelationship, CooperativeArrangement, ReferralPathway, ExternalDependency, CommunityRelationship, ParticipationModel (proposed Session 76, detailed design Session 78, implemented Session 81) |

Plus **Activity Awareness** (C6) as the cross-cutting dimension — every unit of activity is visible across all six concerns.

### 2.4 Governing principles

| #                                                      | Principle                                  | One-line test                                                                               |
| ------------------------------------------------------ | ------------------------------------------ | ------------------------------------------------------------------------------------------- |
| [[principle-separation-representation-execution\|A1]]  | Separation of representation and execution | Changes happen in representation and propagate to execution, never the reverse              |
| [[principle-self-describing-system\|A2]]               | Self-describing system                     | The system knows what it is, what it is doing, why, and what rules govern it                |
| [[principle-model-generates-everything\|A3]]           | Model generates everything                 | SysML v2 is the single source of truth                                                      |
| [[principle-two-meta-model-distinction\|A4]]           | Two meta model distinction                 | BMM and SMM are distinct, connected by explicit mappings                                    |
| [[principle-deterministic-over-probabilistic\|A6]]     | Deterministic/auditable reasoning          | Clinical decisions use inspectable logic                                                    |
| [[principle-discipline-as-load-bearing-structure\|A9]] | Discipline as load-bearing structure       | Disciplined practices propagate reliability; regression applies to practices, not just code |
| [[principle-intrinsic-self-knowledge\|A10]]            | Intrinsic self-knowledge                   | System explanations are dynamically computed from live model state                          |
| [[principle-unity-principle\|A11]]                     | Unity principle                            | One weighted relationship model informs all subsystems                                      |
| [[concept-co-evolution\|J2]]                           | Co-evolution                               | No modelling without the tool that makes it legible; no tool without model content          |
| [[concept-non-constraining\|J3]]                       | Non-constraining                           | Decisions should not foreclose future development paths                                     |

**T1 Candidates (Session 59):** A12 (coordinate framework — the representational space is a multi-dimensional coordinate space) and A13 (multi-tenancy — only the meta model is core; every domain is a tenant instantiation).

### 2.5 The comprehension architecture

The system explains itself through three registers:

| Register | Content | Source | Status |
|---|---|---|---|
| **Authored** | Human-written purposive descriptions — "why does this exist?" | `@PurposiveDescription` metadata | Complete (34/34) |
| **Structural** | Facts the model already knows — dynamically derived | `@Comprehension` metadata traversal | Complete (34/34) |
| **Inferential** | Derived explanations beyond what any single element states | Weighted relationships, cross-domain comparison | Research direction (M7) |

96 [[concept-weighted-relationships|weighted relationships]] across 33 weighted elements. Directional and non-commutative — "if A changes, how much does B need reassessment?" Five heuristics govern assignment (H1–H5). The [[principle-unity-principle|unity principle (A11)]] ensures the same weights inform comprehension, reasoning, simulation, governance, and assembly guidance.

### 2.6 Foundational architecture (Session 59)

Four discussion papers establish a candidate foundational layer — working documents, not yet implemented:

- **[[ontara-discussion-coordinate-framework-2026-03-22_1|Coordinate framework (A12)]]** — the system's representational space is a multi-dimensional coordinate space; every entity traces a trajectory. Ontologically grounded in BFO.
- **[[ontara-discussion-domain-identity-architecture-2026-03-22-v2.1|Domain identity (B15)]]** — proposed `DomainDefinition` part def with four-tier `RegulatoryTier` enum.
- **[[ontara-discussion-temporality-reference-frames-2026-03-22-v2.1|Temporal reference frames (B16)]]** — eight illustrative frames; [[concept-epistemic-modality|epistemic modality (B17)]].
- **[[ontara-discussion-ontological-grounding-2026-03-22|Ontological grounding (B18/B19)]]** — BFO → CCO/OGMS/IAO → domain ontology stack.

### 2.7 Dual-stack architecture and ontological grounding (Session 73)

Session 73 produced a major architectural advance: the **[[concept-dual-stack-architecture|dual-stack architecture (B21)]]** and a set of binding decisions about ontological grounding. This is captured in the [[ontara-discussion-dual-stack-architecture-2026-03-26|Dual-Stack Architecture discussion paper]] (Session 74).

**The dual stack.** The BMM and SMM are two parallel vertical stacks. Left (business model): ontology → domain ontologies → BMM vocabulary → business instance → operational domains → business process patterns. Right (business system model): system ontological categories → SMM vocabulary → system instance → system domains → [[concept-operational-simulation|operational simulation]]. Horizontal mappings connect each level. Rules and constraints govern the dynamic layers (bottom two pairs on both sides) within a bounded container. The [[concept-reflective-simulation|reflective simulation]] is cross-cutting on the right side.

**Ontological decisions (binding).** BFO as upper ontology — **mandatory** (B18 status upgraded from directional to binding). OWL 2 DL as the ontological formalism — **mandatory** ([[ontara-ref-master-register|B23]]). Mid-level domain ontologies sit between BFO and the meta model vocabularies, all BFO-aligned: **platform-level (binding):** CCO + IAO; **healthcare sector (binding):** OGMS; **directional:** OCE (commercial exchange), GSSO (gender/sex/sexual orientation); **deferred:** OBI (biomedical investigations). The ontological layers are represented in OWL 2 DL, not SysML; the meta model and instance layers remain in SysML v2. A [[ontara-ref-master-register|mapping ontology (B24)]] bridges the two formalisms. All 34 BMM elements now have `@BfoType` annotations declaring their BFO 2020 category and mid-level ontology parent (Session 98 design, Session 99 applied).

**The [[concept-knowledge-graph|knowledge graph as canonical store (B22)]].** Directional commitment: OWL 2 DL in a triple store as the eventual canonical representation, with SysML v2 as an engineering projection. Condition: round-trip translation must preserve all aspects of the model without degradation. Does not violate A1 or A3 — the representation remains primary. Session 97 produced a comprehensive [[ontara-discussion-knowledge-graph-architecture-2026-04-01|knowledge graph architecture]] with 9 binding decisions, 2 directional, and 2 deferred. Key architectural elements: **three-stratum graph** ([[ontara-workflow-emergent-ideas-log|E019]]) — metamodel graph (SysML traceability), domain graph (BFO-grounded semantics — the canonical layer), correspondence graph (explicit mapping records with provenance); **authority zones** ([[ontara-workflow-emergent-ideas-log|E020]]) — SysML-authoritative for structure, OWL-authoritative for ontological semantics, shared-constrained for labels/definitions; **five-stage Python pipeline** — parse SysML → project to mapping IR → map to OWL/RDF → reason/validate → round-trip diff. **Triple store:** GraphDB Free as primary (built-in OWL-Horst reasoning), HermiT/Pellet for full OWL 2 DL consistency checking. **IRI scheme:** `https://ontara.dev/ontology/` for vocabulary, `https://ontara.dev/data/` for instances.

**Simulation architecture.** The [[concept-operational-simulation|operational simulation (L5)]] is the SMM made live: Temporal workflows coordinating business execution per tenant, with human actors and connected applications as participants. The [[concept-reflective-simulation|reflective simulation (L6)]] is a cross-cutting capability reading from all architectural layers, producing guidance and insight for the operator, imbued with [[concept-valence|valence (L7)]] — the operator’s declared conception of good vs bad business performance. [[concept-coordinate-space-snapshots|Coordinate space snapshots (L8)]] persist five epistemic types (current, historical, goal, hypothetical, projected) in the knowledge graph, enabling [[concept-goal-seeking-computation|goal-seeking computation (L9)]] over the [[concept-coordinate-framework|coordinate space (A12)]].

---

## 3. What Is Built

### 3.1 The SysML model

| Metric                             | Value                                                                                                                                                                                                                                                  |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Top-level packages                 | 12 (including provisional `ArchitecturalStructure`)                                                                                                                                                                                                    |
| Total packages                     | ~74                                                                                                                                                                                                                                                    |
| Core model files                   | 12 `.sysml` files (including `architectural-structure.sysml`, Session 87)                                                                                                                                                                              |
| PatternCatalogue                   | 22 patterns, 8 principles, 33 domain instantiations, ~43 typed `ref` relationships                                                                                                                                                                     |
| BMM elements                       | 34 `part def`s + 2 `requirement def`s across 6 concern packages (5 original + StakeholderModel). StakeholderModel: proposed Session 76, detailed design Session 78, implemented Session 81                                                             |
| SMM elements                       | 1 `part def` ([[ontara-ref-master-register\|ArchitecturalSection (B27)]]), 20 `part` usages, 3 enums (`ArchitecturalGroup`, `Formalism`, `ImplementationStatus`), 2 metadata defs (`@ArchitecturalLocation`, `@BfoType`). First SMM-side model content (Session 87); `@BfoType` added Session 99. OWL axioms (Phase 2): 6 concern-group disjointness declarations, 14 object properties (pipeline-generated), 9 cardinality restrictions, 96 reified weighted relationship individuals |
| Comprehension annotations          | 34/34 `@UserFacing`, 34/34 `@PurposiveDescription`, 34/34 `@Comprehension`, 34/34 `@BfoType` (Session 99), 96 `@WeightedRelationship` (BMM). 20/20 `@UserFacing`, 20/20 `@PurposiveDescription`, 20/20 `@ArchitecturalLocation` (architectural sections) |
| Enums in `Foundation::CommonTypes` | Including `RelationshipNature` (6 values), `DependencyCriticality` (3 values), `ReferralDirection` (3 values, extended Session 81)                                                                                                                     |
| Typed cross-references             | 12 BMM attributes migrated from String to typed `ref` (O25, closed Session 58)                                                                                                                                                                         |

### 3.2 Demonstrator domains

| Domain | Character | Regulatory tier | BMM coverage | Files |
|---|---|---|---|---|
| [[domain-cafe\|Cafe]] | Immediate retail, walk-in, 2-minute cycle | Generally governed | Full model + running application. StakeholderModel: 6 instantiations (Session 81) | 9 `.sysml` (4 business + 5 domain) |
| [[domain-suds\|Suds]] | Batch processing, weight/type pricing | Lightly regulated | Full BMM (6 concerns) + COSHH governance chain. StakeholderModel: 6 instantiations (Session 108) | 1 `.sysml` |
| [[domain-paws\|Paws]] | Appointment-based, breed/size surcharges | Lightly regulated | General vocabulary + StakeholderModel: 7 instantiations (Session 81) | 1 `.sysml` |
| [[domain-ears\|Ears]] | Community ear care, simple procedural pathway | Sector-regulated | Outlined (Session 97) — exercises all six BMM concerns and OGMS clinical primitives | — |

### 3.3 The Ontara Console

| Metric | Value |
|---|---|
| Stack | SvelteKit + Svelte 5 runes + Flowbite Svelte + Tailwind v4 |
| Views | 13 (Home, Coverage Matrix, Package Navigator, Component Catalogue, Glossary, Governance, Meta-Model, Patterns, Domain Views, Weighted Relationship Graph, Architecture, Ontology). Architecture view added Session 88; upgraded to interactive visual architecture map with spatial dual-stack layout (Session 92). Weighted Relationship Graph upgraded from 2D D3.js to interactive 3D WebGL (Session 90) with multi-select pill filters, focus-node neighbourhood exploration, custom curved tube rendering, URL state preservation, and glossary deep linking (Session 91). Ontology view added Session 119: BFO→CCO/IAO→BMM collapsible hierarchy tree + Knowledge Graph Status panel (consistency, ontology stack, 14 object properties, 96 weighted relationships) |
| Navigation | Global console navigation context ([[ontara-ref-master-register\|I19]]): Svelte 5 reactive NavigationStore, semantic breadcrumb trail, page state capture/restore, journey export. 6 routes registered (glossary, ontology, catalogue, governance, coverage, relationships). Sessions 132–134 |
| Data source | `model-introspection.json` generated from SysML via `gen_model_introspection.py` |
| Glossary features | Alphabetical listing, search, BMM Concern/Layer filtering, expand/collapse, cross-links, weight-aware related concepts with dot bar indicator |

### 3.4 The Coffee Shop demonstrator application

Full-stack reference implementation: 9 frontend pages, 19 API routes, Temporal workflow (FulfilDrink with XState lifecycle), EHRbase CDR (3 archetypes, AQL queries), PostgreSQL (4 tables). Stack: SvelteKit + Tailwind v4 + Flowbite Svelte.

### 3.5 Generation pipeline and knowledge graph tooling

Seven operational Python generators: `gen_model_introspection.py` (console data — extracts `@PurposiveDescription`, `@Comprehension`, `@WeightedRelationship`, `@ArchitecturalLocation`, and `@BfoType` annotations; `@BfoType` extraction added Session 103), `gen_concept_graph.py` (Mermaid + Obsidian), `gen_package_hierarchy.py`, `gen_system_manifest.py`, `gen_constraint_evaluator.py`, `gen_decision_table_evaluator.py`, `projection_engine.py`. Shared SysML parser module: `sysml_parser.py` (Session 104, used by introspection and OWL pipeline generators).

Knowledge graph pipeline (Stage 5): `gen_owl_pipeline.py` (SysML → OWL/Turtle via declarative mapping rules in `ontology/config/mapping-rules.yaml`; Phase 2 extensions: Stage 3c object property generation from typed refs, Stage 3e weighted relationship reification), `setup_graphdb.py` (repository creation and ontology stack loading), `validate_kg.py` (SPARQL validation suite, 29 queries in 8 groups), `reason_kg.py` (Robot + HermiT full OWL 2 DL consistency checking, `--save-summary` for console JSON, `--test-violation` for deliberate misclassification testing), `diff_kg.py` (round-trip diff engine — compares pipeline-generated OWL against live GraphDB store at semantic unit level, 288 semantic units, authority-zone-aware). Shared KG utilities: `kg_utils.py` (GraphDB connection, SPARQL execution, IRI shortening — shared by `validate_kg.py` and `diff_kg.py`). Generated outputs in `generated/ontology/`: `ontara-bmm.ttl` (34 OWL classes), `ontara-bmm-properties.ttl` (14 object properties), `ontara-bmm-weights.ttl` (96 reified weighted relationship individuals, 702 triples), `ontara-correspondence.ttl` (1,378 triples — 34 class + 14 property + 96 weight mapping records), `mapping-ir.json` (classified elements). Generated report in `generated/ontara/`: `diff-report.json` (round-trip comparison). Hand-authored axioms: `ontara-bmm-axioms.ttl` (disjointness declarations, cardinality restrictions). Robot v1.9.8 JAR in `tools/`.

### 3.6 Knowledge base (Obsidian vault)

| Metric | Value |
|---|---|
| Concept graph notes | ~85 (16 patterns, 11 principles, 48 concepts, 6 domains, 3 deferred, + 2 indices) |
| [[ontara-ref-master-register\|Master register]] entries | ~201 concepts across 15 sections (A–O), four tiers |
| Discussion papers | 30 (in 5 thematic subfolders, Session 79 reorganisation). Most recent: [[ontara-discussion-console-navigation-context-2026-04-04\|Console Navigation Context]] (Session 132) |
| Session reports | 110 (Sessions 28–137) |
| [[ontara-workflow-emergent-ideas-log\|Emergent Ideas Log]] entries | 22 (E001–E022). E021 (global console navigation context) captured Session 119. E022 (governance ontology editing tooling) captured Session 131 |

---

## 4. Development History and State

### 4.1 Session history

| Range     | Focus                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| --------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1–4       | Coffee shop demonstrator Phases A–D                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| 8–10      | Hormone therapy initiation clinical pathway                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| 11–15     | Knowledge layer elaboration (5 phases)                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| 16–22     | Business meta model (7 phases, 19 sessions)                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| 23–32     | CSW Extension (10 phases)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| 33–34     | Concept Graph and Knowledge Graph Enhancement                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| **35**    | **Ontara named. Vision, six-layer architecture, console vision, demonstrator strategy**                                                                                                                                                                                                                                                                                                                                                                                                                           |
| 36        | Ontara tooling plan                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| 37        | Stage 1 — `gen_model_introspection.py` and console scaffold                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| 38–42     | Stage 2 — Console build (6 phases)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| 43–45     | Stage 3, Phases 1–2 — Paws demonstrator; Glossary; comprehension architecture                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| 46        | Intrinsic self-knowledge, unity principle, weighted relationships                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| 47–48     | Structured project review, tiered register, strategic snapshot                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| 49–55     | Stage 3, Phases 3–4 — Comprehension metadata and population (28/28, 79 weights)                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| 56        | Knowledge base enrichment, binding wikilink rule                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| 57        | Planning — Stage 4 high-level plan                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| 58        | Stage 3, Phase 5 — Typed-ref migration (O25 closed). **Stage 3 closed.**                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| 59        | Foundational architecture — coordinate framework, domain identity, temporality, ontological grounding                                                                                                                                                                                                                                                                                                                                                                                                             |
| 60        | Housekeeping, register update, strategic snapshot refresh                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| 61        | Workflow guide v2, Claude tooling guide, Claude Code setup                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| 62–68     | **Rebaselining workstream** — vision reference v2, architecture principles v2, SysML modelling strategy v2, service business meta modelling v2, vault reorganisation, stable filename convention. **Closed Session 68.**                                                                                                                                                                                                                                                                                          |
| **69**    | **Governance consolidation.** Strategic reference consolidated. Stale links fixed.                                                                                                                                                                                                                                                                                                                                                                                                                                |
| 70        | Register fitness review (B1). Structural improvements to register. 11 new concept notes.                                                                                                                                                                                                                                                                                                                                                                                                                          |
| 71        | Short discussion session — overview document for non-technical reader                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| **72**    | **Stage 4 Phase 1 begun.** Weighted relationship graph (E001) and configuration table (E008) implemented in console. D3.js force-directed graph.                                                                                                                                                                                                                                                                                                                                                                  |
| **73**    | **Dual-stack architecture.** BFO/OWL 2 DL mandatory. Knowledge graph as canonical store. Operational and reflective simulation. Coordinate space snapshots. Major architectural discussion.                                                                                                                                                                                                                                                                                                                       |
| **74**    | Dual-stack discussion paper produced, 7 concept notes (B21, B22, L5–L9), strategic reference refresh.                                                                                                                                                                                                                                                                                                                                                                                                             |
| **75**    | **Architectural consolidation.** Process specification layer paper updated for dual-stack. [[ontara-ref-vision-architecture\|Vision reference]] revised to v3. Concept graph and architecture papers indices refreshed.                                                                                                                                                                                                                                                                                           |
| **76**    | **SMM vocabulary + StakeholderModel.** SMM General vocabulary design (6 capability groups + architectural role axis). [[concept-stakeholder-model\|StakeholderModel]] proposed as sixth BMM concern. Vault git version control established.                                                                                                                                                                                                                                                                       |
| **77**    | **Register update + governance consolidation.** C7/C7a–C7f, B25, B26 registered. [[ontara-ref-vision-architecture\|Vision reference]] v4. Wikilink pipe-escaping fixes. Archive-before-refresh procedure documented.                                                                                                                                                                                                                                                                                              |
| **78**    | **StakeholderModel detailed design.** Four open questions resolved (ParticipationModel distinctness, GovernanceMapping boundary, Relationship Awareness, relationship nature taxonomy). Attribute design and conceptual weight design for all six elements. Contents index convention established.                                                                                                                                                                                                                |
| 79        | Housekeeping — vault navigability. 32 contents indices added. Discussion papers reorganised into 5 subfolders. Multiple index files rewritten. Research & Background maintenance convention.                                                                                                                                                                                                                                                                                                                      |
| 80        | Housekeeping — contents index fix. 19 documents converted from GFM anchors to Obsidian-native format. Document header convention established.                                                                                                                                                                                                                                                                                                                                                                     |
| **81**    | **StakeholderModel SysML implementation.** 6 `part def`s, 3 enums, 2 cross-package typed refs, 20 domain instantiations (GSL 7, Cafe 6, Paws 7). Full metadata parity (34/34, 96 weights). Generator and Syside verified. **BMM structurally complete at General level.**                                                                                                                                                                                                                                         |
| **82**    | **Governance refresh.** [[ontara-ref-strategic-snapshot\|Strategic reference]] refreshed. [[ontara-architecture-business-meta-modelling\|Service Business Meta Modelling]] revised with StakeholderModel sixth section. Both via archive-before-refresh.                                                                                                                                                                                                                                                               |
| 83        | Governance session — YAML frontmatter standardisation pass across ~27 vault documents.                                                                                                                                                                                                                                                                                                                                                                                                                            |
| **84–85** | **Campus walk workstream.** All 20 sections of the [[concept-dual-stack-architecture\|dual-stack architecture]] systematically described using a five-facet template (purpose, representational modality, persistence, interfaces, Paws illustration). [[ontara-ref-master-register\|B27]] (architectural section) registered. [[ontara-discussion-architectural-campus-walk-2026-03-28\|"The Ontara Campus" discussion paper]] produced. [[ontara-workflow-emergent-ideas-log\|E016]] captured.                  |
| **86**    | **Architectural section implementation design.** Five design decisions resolved: name-based identity, single part def / 20 instances, `@ArchitecturalLocation` metadata def, model-as-index pattern ([[ontara-workflow-emergent-ideas-log\|E017]]), dedicated Architecture console view. [[ontara-discussion-architectural-section-implementation-design-2026-03-29\|Design paper]] produced.                                                                                                                     |
| **87**    | **ArchitecturalSection SysML implementation.** New `model/architectural-structure.sysml`: 1 part def, 20 part usages, 3 enums, 1 metadata def. Two-phase Syside validation clean. **First SMM-side model content.** E016 realised, E017 applied.                                                                                                                                                                                                                                                                 |
| **88**    | **Generator extension + Architecture console view.** `gen_model_introspection.py` extended with `architecturalSections` key (20 entries). New `/architecture` console route — 12th view. [[ontara-ref-vision-architecture\|Vision reference]] updated with §7.6 (two registers of self-knowledge). Strategic reference refreshed.                                                                                                                                                                                 |
| **89**    | **Governance refresh.** [[ontara-ref-vision-architecture\|Vision reference]] refreshed to v5 (12 sessions stale, 16 edits). Vault-path frontmatter attempted then reversed — static metadata replaced by dynamic Dataview expressions (`this.file.path`) across 397 files. Anti-pattern recognised: static copies of dynamic data.                                                                                                                                                                                |
| **90**    | **SBMM verification + 3D relationship graph.** [[ontara-architecture-business-meta-modelling\|Service Business Meta Modelling]] StakeholderModel revision verified complete (item closed). 2D D3.js weighted relationship graph replaced with interactive 3D WebGL (`3d-force-graph` + Three.js). 34 lit Phong-material nodes, 96 curved edges with directional arrow cones, bidirectional separation, flowing particles by strength.                                                                                  |
| **91**    | **Relationship graph interactive exploration.** 14 console features: multi-select pill filters, ad-hoc node selection (⌘+click), focus-node neighbourhood exploration (F+click with breadcrumbs and direction toggles), custom curved tube link rendering with arrowheads, URL state preservation, glossary deep linking, adjustable panel transparency. [[ontara-workflow-emergent-ideas-log\|E018]] captured (MCP edits don’t trigger Vite HMR).                                                                |
| **92**    | **Visual architecture map.** [[ontara-discussion-visual-architecture-page-2026-03-31\|Discussion paper]] and Phase 1 implementation: interactive spatial rendering of 20 [[concept-dual-stack-architecture\|dual-stack]] sections as default Architecture tab. Formalism boundary panel, reflective simulation column, horizontal/vertical mapping arrows, slide-out detail panel with frosted glass. BSMM→SMM rename decided (display override applied; full rename pending). Three governance tasks identified. |
| **93**    | **BSMM→SMM codebase rename + strategic snapshot refresh.** Model files, generator, console code renamed. Strategic reference refreshed. Systematic documentation review convention added to [[ontara-workflow-development-guide\|workflow guide]] §7.3. |
| **94**    | **BSMM→SMM vault documents + concept graph refresh.** Four major reference documents updated with SMM terminology. [[ontara - concept-graph-index\|Concept Graph Index]] refreshed (18 sessions overdue). Two new concept notes ([[concept-stakeholder-model\|C7]], [[concept-architectural-section\|B27]]). Console dark mode refinement. |
| **95**    | **Systematic documentation review.** First review under §7.3 convention. 22 findings across 10 categories. Two foundations papers flagged as 30+ sessions stale. Five targeted fixes applied directly. [[session-95-systematic-documentation-review-findings\|Findings document]] produced. |
| **96**    | **Foundations papers refresh.** [[ontara-architecture-platform-principles\|Architecture Principles]] and [[ontara-architecture-platform-modelling-strategy\|Platform Modelling Strategy]] both updated from v2 to v3 via archive-before-refresh. BSMM→SMM throughout, [[concept-dual-stack-architecture\|dual-stack]], [[concept-stakeholder-model\|StakeholderModel]], simulation architecture, updated metrics. Version history tables convention adopted. |
| **97**    | **Knowledge graph architecture.** Major architectural discussion: 9 binding decisions, 2 directional, 2 deferred. [[ontara-discussion-knowledge-graph-architecture-2026-04-01\|Discussion paper]] produced. Three-stratum graph ([[ontara-workflow-emergent-ideas-log\|E019]]), authority zones ([[ontara-workflow-emergent-ideas-log\|E020]]). [[domain-ears\|Ears]] demonstrator (5th domain, 2nd clinical). GraphDB Free, HermiT/Pellet, Protégé selected. |
| **98**    | **`@BfoType` mapping.** [[ontara-discussion-bfo-type-mapping-2026-04-01\|Discussion paper]] with complete BFO mapping table for all 34 BMM elements. `@BfoType` metadata def designed (three String attributes). Six mapping principles. Code instruction document produced. |
| **99**    | **`@BfoType` annotations applied + strategic snapshot refresh.** 34 `@BfoType` annotations applied to `business-model.sysml` via Claude Code. `metadata def BfoType` added to `Foundation::MetadataLibrary`. Paws demonstrator import fix (missing `Foundation::CommonTypes`). This strategic reference refreshed. |
| **100**   | **Stage 5 opened — KG implementation plan.** [[session-100-kg-implementation-plan|Six-step plan]] for Phase 1 (Foundation). Stage 5 designation established. Five design decisions (S100-D1 to D5). Session allocation estimate: 6–9 sessions. |
| **101**   | **Step 1 — GraphDB setup.** `scripts/setup_graphdb.py` created. GraphDB Free repository `ontara-dev` configured with OWL-Horst (Optimized). BFO 2020, CCO, IAO loaded into domain graph. 80,127 statements. Six SPARQL verification queries passing. |
| **102**   | **Step 2 — Ontara BMM ontology authored.** `ontara-bmm.ttl` hand-authored with 34 OWL classes, BFO/CCO parents, labels, comments, SKOS definitions. Loaded into GraphDB. CCO IRI lookup JSON produced. |
| **103**   | **Step 3 — SysML parser extension.** `@BfoType` extraction added to `gen_model_introspection.py`. Contents index GFM→Obsidian regression corrected. |
| **104**   | **Step 3 continued — shared parser extraction.** `scripts/sysml_parser.py` extracted as shared module. Both introspection and OWL pipeline generators import from it. `CLAUDE.md` gap flagged for next session. Repo README currency check performed (next: Session 114). |
| **105**   | **Step 4 — OWL pipeline generator.** `scripts/gen_owl_pipeline.py` operational with declarative mapping rules (`ontology/config/mapping-rules.yaml`). 34 DomainClass elements via `rdflib`. Three outputs: `ontara-bmm.ttl` (175 triples), `ontara-correspondence.ttl` (306 triples), `mapping-ir.json` (723 elements). Hardcoded `gen_ontara_bmm.py` archived with provenance. `CLAUDE.md` substantial update. Console build verified clean. |
| **106**   | **Step 5 — Load, reason, and validate.** `scripts/validate_kg.py` created with 10 SPARQL validation queries in 4 groups (structural, correspondence, inference, graph-level). Pipeline-generated Turtle reloaded into GraphDB (replacing Session 102 hardcoded version). 10/10 queries passed. All 34 BMM classes confirmed as BFO:Continuant via full transitive inference chain. Domain graph: 24,663 triples; correspondence graph: 306 triples. This strategic reference refreshed. |
| **107**   | **Stage 5 Phase 1 closure + Stage 4 Phase 1 closure.** Step 6 (documentation and governance): [[ontara-discussion-knowledge-graph-architecture-2026-04-01\|KG architecture paper]] updated with §13 implementation findings, [[ontara-discussion-bfo-type-mapping-2026-04-01\|@BfoType mapping paper]] updated with §9 implementation notes, [[stage5-plan-s.100-kg-implementation\|KG implementation plan]] closure note appended. **Stage 5 Phase 1 formally closed** (7 sessions, within estimate). BSMM→SMM discussion paper annotation pass completed. [[ontara-guide-claude-tooling\|Claude Tooling Guide]] §7 added (E018 resolution). **Stage 4 Phase 1 formally closed.** |
| **108**   | **Systematic documentation review + E009 + Suds StakeholderModel.** Second review under §7.3: 18 findings across 7 categories. [[session-108-systematic-documentation-review-findings\|Findings document]] produced. [[ontara-workflow-emergent-ideas-log\|E009]] resolved: `CostDriver.linkedResource` multiplicity widened `[0..1]` → `[0..*]`. [[domain-suds\|Suds]] [[concept-stakeholder-model\|StakeholderModel]] gap closed (6 instantiations). Cross-domain validation now complete for all six BMM concerns across all three demonstrator domains. |
| **109**   | **[[ontara-ref-vision-architecture\|Vision and Architecture Reference]] v6 refresh.** 20 sessions of accumulated development incorporated (Sessions 89–108). Archive-before-refresh procedure streamlined. |
| **110**   | **Governance remediation.** Seven Session 108 findings resolved: [[ontara-workflow-development-guide\|workflow guide]] §7.1 console data source currency check convention (F18), four `implementationStatus` updates in `architectural-structure.sysml` (F18), [[ontara-architecture-business-meta-modelling\|SBMM paper]] BSMM→SMM terminology pass + version history table + §11.4 correction (F5/F6/F11), four [[ontara-workflow-emergent-ideas-log\|emergent ideas log]] entries resolved (E007 retired, E010 routed, E011/E013 deferred). Console commit confirmed clean. |
| **111**   | **Stage 5 Phase 2 planning.** Scoping discussion: deep KG work (Block A) then console integration (Block B). [[stage5-plan-s.111-phase2\|Ten-step plan]] with 5 design decisions (S111-D1 to D5), 10–14 session estimate. |
| **112–113** | **Steps 1–2 — Disjointness axioms and object properties.** Six concern-group disjointness declarations in `ontara-bmm-axioms.ttl`. 12 object properties hand-authored in Protégé with domain, range, and functional characteristics. |
| **114**   | **Step 3 — Cardinality restrictions.** S111-D1 resolved: faithful SysML multiplicity mapping. 9 qualified cardinality restrictions added. Deliberate violation test confirmed. Repo README.md currency check. |
| **115**   | **Step 4 — Robot + HermiT integration.** S111-D5 confirmed. `scripts/reason_kg.py` written. Full OWL 2 DL consistency checking operational. Violation testing: cross-concern, cardinality, domain/range. R2 (performance risk) confirmed non-issue. |
| **116**   | **Step 5 — Pipeline extension: typed ref extraction.** 14 object properties pipeline-generated from SysML. All 13 hand-authored match exactly. 1 new (`hasSupportingCapability`). Correspondence graph: 306 → 418 triples. |
| **117**   | **Step 6 — Weighted relationship mapping.** 96 reified `WeightedRelationship` individuals (702 triples). Correspondence graph: 418 → 1,378 triples. `ontology/catalog-v001.xml` for Robot import resolution. 7-file ontology stack. HermiT consistency PASS. |
| **118**   | **Console data source currency check + Block B Step 8.** 9 residual BSMM→SMM annotation fixes. BFO category display added to Glossary and Component Catalogue. |
| **119**   | **Block B Steps 9–10 complete.** Ontological hierarchy view (`/ontology` route): BFO→CCO/IAO→BMM collapsible tree. KG Status panel: consistency, ontology stack, 14 object properties table, weighted relationships. Cross-route back-navigation. [[ontara-workflow-emergent-ideas-log\|E021]] captured (global console navigation context). [[ontara-workflow-development-guide\|Workflow guide]] updated (C9b vault commit step). |
| **120**   | **Stage 5 Phase 2 closure (Block A Step 7).** [[ontara-discussion-knowledge-graph-architecture-2026-04-01\|KG architecture paper]] updated with §14 (Phase 2 findings). [[stage5-plan-s.111-phase2\|Phase 2 plan]] closure note (9/10 success criteria). Console dark mode fix. Register reviewed. Strategic snapshot refreshed. **Stage 5 Phase 2 formally closed.** |
| **121**   | **Deontic governance architecture.** Major [[ontara-discussion-deontic-governance-architecture-2026-04-03|discussion paper]]: obligation vocabulary grounded in deontic logic, three-tier compliance architecture (library, activation, operations), normative instrument taxonomy, governance framework library, integration with dual-stack/coordinate space/simulation. Seven design decisions (S121-D1 to D7), seven open questions. Concepts registered: B30–B34. |
| 122       | Implementation session. |
| **123**   | **Third systematic documentation review.** 19 findings across 8 categories. [[session-123-systematic-documentation-review-findings|Findings document]] produced. F2 (vision reference 14 sessions stale) and F12 (workflow guide §6.2 old folder names) identified as priorities. |
| 124       | Discussion/implementation. |
| **125**   | **Deontic governance OWL class design.** [[ontara-discussion-deontic-owl-class-design-2026-04-03|Discussion paper]]: concrete OWL 2 DL class hierarchy for the governance vocabulary. 19 classes, 6 enumeration classes, 20 object properties, 16 data properties, full Turtle specification. Seven design decisions (S125-D1 to D7). B35 (governance ontology module) registered. |
| **126**   | **Governance ontology Turtle implementation.** `ontology/governance/ontara-governance.ttl` authored from §10 spec. Loaded into GraphDB, Robot + HermiT CONSISTENT (9-file stack). 6 new SPARQL governance queries (16/16 total). Test individuals modelled on CQC Regulation 12. First hand-authored ontology module outside BMM namespace. |
| **127**   | **Governance housekeeping.** [[ontara-ref-vision-architecture|Vision reference]] refreshed to v7 (F2 resolved). [[ontara-workflow-development-guide|Workflow guide]] §6.2 updated (F12 resolved). Strategic snapshot refreshed. |
| **128**   | **Housekeeping: currency check, findings remediation, work item tracker.** Console data source currency check completed (10-session cadence from S118): all 20 `implementationStatus` values correct, hardcoded console constants current, `model-introspection.json` copies in sync, two minor `@ArchitecturalLocation` summary findings logged. [[ontara - concept-graph-index|Concept Graph Index]] refreshed (S123-F1): concept count 45→47 (B28, B29 notes confirmed), register count ~193→~200, Suds StakeholderModel coverage updated. Most S123 findings confirmed already resolved (S123–S127). **[[ontara-ref-work-items|Work item tracker]] established** — single authoritative source for outstanding work items, integrated into [[ontara-workflow-development-guide|workflow guide]] at O1, O3, C2, §5.2, §7.3. Known pitfall added §12. Populated with 17 active items and 11 completed items. |
| **129**   | **Priority C work item remediation.** Seven work items completed: W-002 (`@ArchitecturalLocation` summaries), W-003 (Claude Tooling Guide header), W-004 ([[ontara-non-technical-overview|non-technical overview]] full rewrite via archive-before-refresh), W-005/W-006 (superseded annotations on two legacy papers), W-007 (Research & Background Index verified), W-008/W-016 ([[ontara-workflow-emergent-ideas-log|E011]] routing status consolidated). Workflow guide convention added: Ella duplicates long documents. |
| **130**   | **CQC Governance MVP plan (W-009).** [[stage5-plan-s.130-cqc-governance-mvp|Implementation plan]] for CQC Regulation 12: six phases (A–F), 3–4 session estimate. Three design decisions (S130-D1 to D3). Single regulation in full depth rather than many at surface level. |
| **131**   | **CQC Governance MVP implementation (Phases A–E).** 21 individuals authored in `ontology/governance/cqc-reg12-individuals.ttl`: 4 normative instruments, 10 statutory obligations (Regulation 12(1) + 12(2)(a)–(i)), 5 guidance-level directives (GSL-specific), 1 obligation group, 1 governance framework. Robot + HermiT CONSISTENT (10-file ontology stack). 23/23 SPARQL queries passed (7 new governance-MVP queries). First real exercise of the deontic governance vocabulary (B30, B31, B33, B35). [[ontara-workflow-emergent-ideas-log|E022]] captured (governance ontology editing tooling). |
| **132**   | **Governance granularity + navigation context design.** W-019 (Phase F paper annotations) completed. W-013/W-014 resolved jointly: [[ontara-discussion-governance-granularity-and-cross-references-2026-04-04|discussion paper]] with three-tier standard decomposition and five cross-reference patterns. W-010 initial design: [[ontara-discussion-console-navigation-context-2026-04-04|global console navigation context]] design paper. I18 proposed (later corrected to I19). |
| **133**   | **I19 registered + W-010 Phase 1.** Global console navigation context registered as I19 (numbering collision with I18 caught and corrected). Phase 1 implementation via Claude Code: NavigationStore, NavLink, Breadcrumb, glossary and ontology route migrations. CLAUDE.md updated for 10-file ontology stack and navigation infrastructure. |
| **134**   | **W-010 Phase 2 complete + README check.** Six routes registered (glossary, ontology, catalogue, governance, coverage, relationships). Legacy `from` parameter removed. Semantic labels on all NavLink cross-links. Journey export to clipboard. Reset button. W-018 README.md currency check completed (Session 124 → 134). **W-010 fully complete.** |
| **135**   | **Stage 5 Phase 3 planning + Step 1.** [[stage5-plan-s.135-phase3|Phase 3 plan]]: Block A (consolidation, 3 steps) + Block B (round-trip foundation, 3 steps). Five design decisions (S135-D1 to D5). Step 1 completed: live reasoning summary generated (`reason_kg.py --save-summary`), deployed to console. [[ontara-workflow-emergent-ideas-log|EIL]] relocated. |
| **136**   | **Phase 3 Block A complete + Block B design.** SPARQL validation suite extended 23→29 queries (8 groups). Governance vocabulary extended with 3 new object properties + 1 data property. Live reasoning summary deployed. Round-trip diff engine design completed: four semantic unit types, dual output (JSON + stdout), authority-zone-aware. Two design decisions (S136-D1, D2). |
| **137**   | **Phase 3 complete.** Round-trip diff engine (`scripts/diff_kg.py`) implemented: 288 semantic units compared, 0 discrepancies (CLEAN). Shared KG utilities module (`scripts/kg_utils.py`) extracted. Documentation updated: [[ontara-discussion-knowledge-graph-architecture-2026-04-01|KG Architecture Paper]] §15, [[ontara-ref-shell-commands|Shell Command Reference]] §15, CLAUDE.md. **Stage 5 Phase 3 formally closed** (3 sessions, within 5–7 estimate). All seven success criteria met. Three layers of automated quality assurance: SPARQL validation (29 queries), OWL 2 DL reasoning (HermiT), round-trip diff (288 semantic units). |

### 4.2 Current state

| Stage | Focus | Status |
|---|---|---|
| Stage 1 | Model introspection — `gen_model_introspection.py` | Complete (S37) |
| Stage 2 | Console build — 6 phases | Complete (S38–42) |
| Stage 3 | Comprehension and cross-domain validation — 5 phases | Complete (S43–58) |
| Rebaselining | Foundations papers v2, vault organisation, workflow maturation | Closed (S62–68) |
| Governance consolidation | Document rationalisation, stale link cleanup | Closed (S69–70) |
| Stage 4 | Structural navigation and construction — 5 phases | **Phase 1 closed (S107).** Weighted relationship graph rebuilt as 3D WebGL with full interactive exploration (Sessions 90–91). Configuration table delivered (Session 72). Console committed and pushed. |
| Dual-stack architecture | Session 73 exploratory architecture | **Discussion paper produced (S74).** Working document status. First SMM-side model content (S87). Visual architecture map Phase 1 built (S92). |
| StakeholderModel | Sixth BMM concern — the relational boundary | **Complete (S76–S81).** Proposed S76, detailed design S78, SysML implementation S81. 6 `part def`s, full metadata parity, 20 domain instantiations. BMM structurally complete at General level. |
| Vault governance | Contents indices, Obsidian-native navigation, document header conventions | **Conventions established (S78–S80).** 32 contents indices added, 19 documents fixed, document header format standardised. Discussion papers reorganised into 5 subfolders (S79). |
| Campus walk + architectural sections | Systematic description and SysML encoding of dual-stack sections | **Complete (S84–S88).** 20 sections described (S84–85), implementation designed (S86), SysML implemented (S87), generator extended and Architecture console view built (S88). First SMM-side model content. B27 registered, E016 realised, E017 captured. |
| Visual architecture map | Interactive spatial rendering of dual-stack in the console | **Phase 1 complete (S92).** Spatial layout, formalism boundary panel, reflective simulation column, mapping arrows, slide-out detail panel. Phase 2 (resident elements and deep linking) planned. [[ontara-discussion-visual-architecture-page-2026-03-31\|Discussion paper]] produced. |
| BSMM→SMM rename | Terminology alignment across all project artefacts | **Complete (S92–S110).** Codebase (S93), vault reference documents (S94), foundations papers (S96), discussion paper annotation pass (S107), SBMM paper terminology pass (S110). Remaining only: `bsmm-general-vocabulary` SysML section name (retained as structural identifier, standing convention). |
| Systematic documentation review | Intellectual health of vault documentation | **Fourth review completed (S138).** 9 findings, 6 categories. F3 (Architecture Papers Index) resolved S138. F4 (Concept Graph Index) resolved S138. F7 (Shell Commands YAML) resolved S138. F1 (strategic snapshot) resolved S138. Next review due ~Session 153. |
| Foundations papers refresh | Architecture Principles + Modelling Strategy | **Both refreshed to v3 (S96).** 30–32 sessions of governance debt cleared. Version history tables convention adopted. |
| Knowledge graph implementation | Stage 5 — ontological grounding | **Phase 1 closed (S100–S107). Phase 2 closed (S111–S120).** Phase 1: Architecture designed (S97–S98). [[stage5-plan-s.100-kg-implementation\|Six-step plan]] (S100). GraphDB running with BFO/CCO/IAO stack (S101). BMM ontology pipeline-generated (S102–S105). Shared `sysml_parser.py` (S104). SPARQL validation 10/10 (S106). **Phase 1 formally closed S107** (7 sessions, within 6–9 estimate). Phase 2: [[stage5-plan-s.111-phase2\|Ten-step plan]] (S111). Disjointness axioms, 14 object properties, 9 cardinality restrictions (S112–S114). Robot + HermiT full OWL 2 DL reasoning (S115). Pipeline extension: typed refs and weighted relationships (S116–S117). Console integration: BFO badges, ontological hierarchy, KG status panel (S118–S119). 7-file ontology stack. Correspondence graph: 1,378 triples. 96 reified weighted relationships. 9/10 success criteria met. **Phase 2 formally closed S120** (9 sessions, within 10–14 estimate). Phase 3: [[stage5-plan-s.135-phase3\|Six-step plan]] (S135). Block A consolidation: live reasoning summary, SPARQL suite 23→29 queries (8 groups), governance vocabulary extensions (3 object properties + 1 data property). Block B round-trip foundation: diff engine design and implementation (`diff_kg.py`, 288 semantic units), shared `kg_utils.py`. 7/7 success criteria. **Phase 3 formally closed S137** (3 sessions, within 5–7 estimate). Three layers of automated QA: SPARQL validation (29 queries), OWL 2 DL reasoning (HermiT), round-trip diff (288 semantic units). No active Stage 5 work items remain. |
| Deontic governance workstream | Sessions 121–132 — obligation vocabulary, compliance framework, and CQC MVP | **Vocabulary tier implemented, validated, and exercised with production content.** Governance architecture paper (S121): three-tier compliance architecture. OWL class design paper (S125): 19 classes, 6 enums, 20 object + 16 data properties. Governance ontology implemented (S126). **CQC Governance MVP (S130–131):** 21 individuals formalising CQC Regulation 12 in full depth (4 normative instruments, 10 statutory obligations, 5 guidance directives, 1 obligation group, 1 framework). 10-file ontology stack. 23/23 SPARQL. Granularity and cross-references paper (S132): three-tier standard decomposition. Governance vocabulary extended S136 (3 new object properties + 1 data property). 29-query SPARQL suite. Concepts registered: B30–B35. Activation and operations tiers designed but not yet built. |
| Work item tracker | Authoritative work item status | **Established S128.** [[ontara-ref-work-items\|Single source]] for all outstanding items. Integrated into [[ontara-workflow-development-guide\|workflow guide]] at O1, O3, C2, §5.2, §7.3. |
| Global console navigation context | Shared navigation infrastructure (I19) | **Complete (S132–134).** Design paper (S132). Phase 1 foundation (S133). Phase 2 full adoption (S134). Svelte 5 reactive NavigationStore, semantic breadcrumb, journey export. 6 routes registered. |

### 4.3 What comes next

**Current position (Session 138):** The project is at a natural inflection point. Stage 5 Phase 3 is closed (Session 137), completing the round-trip diff engine and bringing the KG pipeline to three layers of automated quality assurance. The CQC Governance MVP (Sessions 130–131) exercised the deontic governance vocabulary with production-quality regulatory content. The global console navigation context (I19, Sessions 132–134) is complete. The work item tracker (Session 128) has reduced governance overhead. No active Stage 5 work items remain. The next major work direction needs to be chosen.

**Immediate priorities:**

1. **Forward planning.** With Phase 3 closed and no active Stage 5 items, the next work direction is open. Candidates include:
   - **Stage 5 Phase 4** — live SPARQL console integration (querying GraphDB at runtime, replacing pre-generated JSON). The diff engine's SPARQL patterns provide a foundation.
   - **[[domain-ears\|Ears]] demonstrator (W-015)** — designing how Ears exercises the governance framework. Open since Session 121.
   - **Governance content work** — formalising additional CQC regulations using the vocabulary extensions built in Phase 3. Domain modelling, not infrastructure.
   - **Governance activation tier** — implementing BoundObligation and GovernanceFrameworkActivation (designed in S121 paper, §8–9). This would connect the library tier to specific business domains.
2. **Vision and Architecture Reference refresh** — 11 sessions stale (Session 127). Schedule within ~4–7 sessions, earlier if architectural work opens.
3. **Console data source currency check** — next due ~Session 140.

**Stage 4 continuation:** Phase 1 (weighted relationship graph) closed (Session 107). Remaining phases:

2. **Cross-Package Navigation** — deep linking, breadcrumbs, typed ref navigation
3. **BMM Concern Group Descriptions** ([[ontara-workflow-emergent-ideas-log|E003]]) — package-level purposive descriptions
4. **Structural Completeness Visualisation** — completeness heatmap, gap identification
5. **Assembly Workspace Prototype** — configuration builder, the seed of the dual-canvas vision

**Incremental governance:** Dynamic Dataview path expressions (`` > `= this.file.path` ``) now standard on all vault documents (Session 89 — 397 files). YAML frontmatter standardisation applied as documents are next touched. Fourth systematic documentation review completed Session 138 (9 findings). Next review due ~Session 153. Console data source currency check next due ~Session 140. Repo README.md currency check next due ~Session 146.

**Horizon:** Key future workstreams include: Stage 5 Phase 4 (live SPARQL — console queries against GraphDB at runtime), Phase 5 ([[domain-ears|Ears]] demonstrator — OGMS adoption, clinical validation in the KG), and governance activation tier (BoundObligation, GovernanceFrameworkActivation — connecting library to business domains). SMM General vocabulary elaboration (design decision made Session 76: six capability groups with architectural role axis). Simulation architecture prototyping (operational simulation in Paws, reflective simulation design). Valence representation mechanism. [[domain-ears|Ears]] demonstrator build-out (second clinical pathway, OGMS adoption driver). Domain identity implementation (B15). IG/cybersecurity scoping (B20, E011). Governance ontology editing tooling (E022 — domain-aware UI for reviewing/editing governance content without Turtle syntax knowledge). The simulation workstream (L5–L9) has moved from horizon item to conceptually designed architecture. StakeholderModel cross-element weights (three candidates, §5.8 of the [[ontara-discussion-stakeholder-model-detailed-design-2026-03-28|detailed design paper]]) to be assessed when elements are exercised in practice.

---

## 5. Key Documents

### Orientation

| Document | Purpose |
|---|---|
| **This document** | Strategic reference — orientation, state, what's next |
| [[ontara-ref-vision-architecture\|Vision and Architecture Reference]] | Authoritative architectural summary (v7, Session 127) |
| [[ontara-ref-master-register\|Master Concept Register]] | ~201 concepts across four tiers — the governance backbone |

### Foundations

| Document | Purpose |
|---|---|
| [[ontara-architecture-platform-principles\|Architecture Principles (v3)]] | Governing principles, foundational architecture, guiding constraints (Session 64; refreshed Session 96) |
| [[ontara-architecture-platform-modelling-strategy\|SysML Modelling Strategy (v3)]] | Package architecture, reasoning stack, concentric rings of rigour (Session 65; refreshed Session 96) |
| [[ontara-architecture-business-meta-modelling\|Service Business Meta Modelling (v2)]] | The BMM — comprehensive reference (Session 67, StakeholderModel incorporated Session 82, verified Session 90) |
| [[ontara--architecture-papers-index-READ-ORDER--]] | Curated reading order for all architecture papers |

### Development

| Document | Purpose |
|---|---|
| [[ontara-workflow-development-guide\|Development Workflow Guide (v2)]] | Shared operating agreement — session lifecycle, document handling, model development |
| [[ontara-guide-claude-tooling\|Claude Tooling Guide]] | Chat / Code / Cowork allocation |
| [[ontara-workflow-emergent-ideas-log\|Emergent Ideas Log]] | Ideas captured at inception (22 entries, E001–E022) |
| [[ontara - concept-graph-index]] | Navigable concept graph with wikilink targets |
| [[ontara-stage-4-high-level-plan-2026-03-21\|Stage 4 High-Level Plan]] | Next development stage — structural navigation and construction |
| [[ontara-discussion-dual-stack-architecture-2026-03-26\|Dual-Stack Architecture]] | Session 73/74 — the dual-stack architecture, BFO/OWL, knowledge graph, simulation |
| [[ontara-discussion-stakeholder-model-detailed-design-2026-03-28\|StakeholderModel Detailed Design]] | Session 78 — all six General elements, attribute design, open question resolution, conceptual weight design |
| [[ontara-discussion-architectural-campus-walk-2026-03-28\|The Ontara Campus]] | Sessions 84–85 — all 20 architectural sections of the dual-stack, five-facet descriptions, [[domain-paws\|Paws]] illustrations |
| [[ontara-discussion-architectural-section-implementation-design-2026-03-29\|Architectural Section Implementation Design]] | Session 86 — five design decisions, model-as-index pattern ([[ontara-workflow-emergent-ideas-log\|E017]]) |
| [[ontara-discussion-visual-architecture-page-2026-03-31\|Visual Architecture Page]] | Session 92 — spatial architecture map design, progressive disclosure, deep linking strategy |
| [[ontara-discussion-knowledge-graph-architecture-2026-04-01\|Knowledge Graph Architecture]] | Session 97 — three-stratum graph, authority zones, five-stage pipeline, triple store selection, IRI scheme |
| [[ontara-discussion-bfo-type-mapping-2026-04-01\|@BfoType Mapping]] | Session 98 — BFO mapping table for all 34 BMM elements, six mapping principles, `@BfoType` metadata def design |
| [[stage5-plan-s.100-kg-implementation\|KG Implementation Plan]] | Session 100 — six-step plan for Stage 5 Phase 1, session allocation, validation subset, register connections |
| [[stage5-plan-s.111-phase2\|Stage 5 Phase 2 Plan]] | Session 111 — ten-step plan for ontological enrichment, reasoning, and console integration. Closed Session 120 |
| [[ontara-discussion-deontic-governance-architecture-2026-04-03|Deontic Governance Architecture]] | Session 121 — obligation vocabulary, three-tier compliance architecture, normative instrument taxonomy, governance framework library |
| [[ontara-discussion-deontic-owl-class-design-2026-04-03|Deontic Governance OWL Class Design]] | Session 125 — 19 classes, 6 enums, 20 object properties, 16 data properties. Implemented Session 126 |
| [[ontara-discussion-governance-granularity-and-cross-references-2026-04-04|Decomposition Granularity and Cross-References]] | Session 132 — three-tier standard decomposition, five cross-reference patterns. Resolves S121-Q2 and Q4 |
| [[ontara-discussion-console-navigation-context-2026-04-04|Global Console Navigation Context]] | Session 132 — NavigationStore design, semantic navigation stack, journey capture. I19 registered. Implemented Sessions 133–134 |
| [[stage5-plan-s.130-cqc-governance-mvp|CQC Governance MVP Plan]] | Session 130 — CQC Regulation 12 formalisation plan. Implemented Session 131 |
| [[stage5-plan-s.135-phase3|Stage 5 Phase 3 Plan]] | Session 135 — KG consolidation and round-trip foundation. Closed Session 137 |

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
| R1 | **Single developer.** Ella is sole developer, architect, and domain expert. | Model-driven approach ensures knowledge lives in the model. Comprehension architecture means the model explains itself. Claude (Chat, Code, Cowork) extends capacity. |
| R2 | **No second clinical pathway.** Architecture claims to generalise clinical processes. | Three non-clinical demonstrators validate meta model generality. [[domain-ears\|Ears]] (community ear care) outlined as fifth demonstrator and second clinical domain (Session 97), driven by OGMS adoption. Build-out is a candidate workstream. |
| R3 | **Generation pipeline partial.** Seven generators operational; additional targets designed but not built. | Built as needed following [[concept-co-evolution\|J2]]. |
| R4 | **Clinical data layer untouched since CSW Phase E.** CDR patterns validated in coffee shop; clinical archetypes not designed for GSL. | Patterns proven. Extension is a candidate workstream. |
| R5 | **Reasoning formalisms uncommitted.** Inferential comprehension depends on formalisms not yet evaluated. | Research direction (M7). Current architecture must not foreclose any option ([[concept-non-constraining\|J3]]). |
| R6 | **Silent regression risk.** ~201 concepts and growing complexity. | Tiered register with T1 session-start review. [[ontara-workflow-development-guide\|Workflow guide]] mandates register checks. Visual architecture map (Session 92) makes the architecture permanently visible and navigable, reducing the risk of losing sight of established commitments. |
| R7 | **Foundational architecture partially committed.** Session 59 papers were working documents; Session 73 made BFO and OWL 2 DL mandatory. Other foundational concepts remain directional. | BFO (B18) and OWL 2 DL (B23) are now binding. Knowledge graph as canonical store (B22) is a directional commitment with a stated condition. A12/A13 remain T1 candidates. B15–B17 remain directional. |
| R8 | **Two-formalism complexity.** OWL 2 DL + SysML v2 introduces a mapping boundary and synchronisation challenge. | Mapping ontology (B24) committed as the bridge, now concretely realised as the correspondence graph (E019). Authority zones (E020) govern which side is authoritative for what. Five-stage Python pipeline designed (Session 97). `@BfoType` annotations (34/34) provide the SysML-side input to the mapping. [[concept-non-constraining\|J3]] preserved — round-trip fidelity is the condition for KG-as-canonical. |

---

## 7. Where Things Live

### Obsidian vault

`/Users/ellagreen/Obsidian/GenderSense` under `02 ONTARA ARCHITECTURE & MODELLING/`:

| Folder | Contents |
|---|---|
| [[ontara -- START HERE --\|01 Ontara START HERE]] | Strategic reference, vision & architecture reference, non-technical overview |
| [[ontara -- index-platform-development --\|02 Ontara Development]] | Reference & guides, plans (by stage), session reports & prep notes (by decade), [[ontara-workflow-emergent-ideas-log\|Emergent Ideas Log]] |
| [[ontara - concept-graph-index\|03 Ontara Concept Graph]] | Concept, pattern, principle, domain, deferred notes — wikilink targets |
| [[ontara--architecture-papers-index-READ-ORDER--\|04 Ontara Architecture]] | All architecture papers — foundations, discussion papers, design decisions. Flat, single subfolder (External/) for reference PDFs |
| [[ontara - index-demonstrators\|05 Ontara Demonstrators]] | Per-domain material for Cafe, Suds, Paws |
| [[ontara - index-research-background\|06 Ontara Research & Background]] | External research and investigation notes |
| [[ontara -- index-history-archive --\|07 Ontara History & Archive]] | Superseded documents, old snapshots, pre-Ontara analysis |

### Code repository

`~/Developer/gsl-tech/gsl-sysml-model` (GitHub: `ella66gr/gsl-tech-sysmlv2-model`):

| Folder | Contents |
|---|---|
| `model/` | SysML v2 model files (source of truth) |
| `exercises/` | Demonstrator domains |
| `scripts/` | Generation pipeline (7 Python generators), shared `sysml_parser.py`, KG tooling (`gen_owl_pipeline.py`, `setup_graphdb.py`, `validate_kg.py`, `reason_kg.py`, `diff_kg.py`), shared `kg_utils.py`, `scripts/archive/` for superseded generators |
| `console/` | Ontara Console (SvelteKit) |
| `generated/` | Generated artefacts: `generated/ontara/` (JSON, diff report), `generated/ontology/` (OWL/Turtle, correspondence, mapping IR) |
| `ontology/` | KG configuration: `ontology/config/` (mapping rules YAML, CCO IRI lookup JSON), `ontology/imports/` (BFO 2020, CCO, IAO ontology files), `ontology/governance/` (hand-authored governance vocabulary, CQC Regulation 12 individuals), `ontology/catalog-v001.xml` (Robot IRI resolution) |
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
| Modelling language | SysML v2 |
| Modelling tool | Syside Modeler (VS Code extension) |
| Console | SvelteKit + Svelte 5 runes + Flowbite Svelte + Tailwind v4. 3D relationship graph: `3d-force-graph` + Three.js r183 + `three-spritetext` |
| Coffee Shop app | SvelteKit + Temporal + XState v5 + EHRbase CDR + PostgreSQL |
| Generation pipeline | Python 3 (7 generators + OWL pipeline reading `.sysml`, producing JSON/TS/Mermaid/OWL). OWL pipeline dependencies: `rdflib`, `PyYAML`. Shared parser: `sysml_parser.py` |
| Ontological formalism | OWL 2 DL (mandatory, Session 73). Triple store: GraphDB Free 10.x (local, port 7200, OWL-Horst Optimized ruleset) — **operational** (Session 101). Reasoner: Robot v1.9.8 wrapping HermiT for full OWL 2 DL consistency checking — **operational** (Session 115). Ontology authoring: Protégé 5.6+. IRI scheme: `https://ontara.dev/ontology/` (vocabulary), `https://ontara.dev/data/` (instances) |
| Knowledge base | Obsidian |
| Version control | Git / GitHub |
| AI collaboration | Claude Chat (MCP filesystem), Claude Code (terminal + Obsidian CLI), Claude Cowork |
| Development environment | macOS, VS Code |

---

*Strategic reference created Session 69 (24 March 2026). Refreshed Session 74 (26 March 2026) to incorporate the dual-stack architecture, BFO/OWL 2 DL decisions, knowledge graph as canonical store, simulation architecture (L5–L9), and Sessions 70–74 history. Refreshed Session 82 (28 March 2026) to incorporate StakeholderModel implementation (Sessions 76–81), updated metrics (34 BMM elements, 96 weighted relationships, 34/34 comprehension coverage), vault governance conventions (Sessions 78–80), architectural consolidation (vision reference v4, process specification layer update), and Sessions 75–81 history. Refreshed Session 88 (30 March 2026) to incorporate the campus walk workstream (Sessions 84–85), architectural section implementation (B27, Session 87 — first BSMM-side model content), generator extension and Architecture console view (Session 88 — 12th console view), model-as-index pattern (E017), vision reference §7.6 (two registers of self-knowledge), and Sessions 82–88 history. Refreshed Session 93 (31 March 2026) to incorporate vision reference v5 (Session 89), dynamic Dataview path expressions (Session 89), SBMM verification closed (Session 90), 3D WebGL weighted relationship graph with full interactive exploration (Sessions 90–91, 14 features), visual architecture map Phase 1 (Session 92), BSMM→SMM rename decision (Session 92), E018 captured, and Sessions 89–92 history. Refreshed Session 99 (1 April 2026) to incorporate BSMM→SMM vault rename pass (Session 94), first systematic documentation review (Session 95), foundations papers refresh to v3 (Session 96), knowledge graph architecture with 9 binding decisions, three-stratum graph (E019), authority zones (E020), Ears demonstrator (Session 97), @BfoType mapping design (Session 98), @BfoType annotations applied to all 34 BMM elements (Session 99), and Sessions 93–99 history. Refreshed Session 106 (2 April 2026) to incorporate Stage 5 Phase 1 Steps 1–5 (Sessions 100–106): KG implementation plan (Session 100), GraphDB setup with BFO/CCO/IAO (Session 101), BMM ontology authoring and pipeline generation (Sessions 102–105), shared SysML parser extraction (Session 104), OWL pipeline with declarative mapping rules (Session 105), SPARQL validation suite passing 10/10 (Session 106). Updated §3.5 (pipeline and KG tooling), §4.1–4.3 (history, current state, what comes next), §7 (repo structure), §8 (technology stack). Refreshed Session 111 (2 April 2026) to incorporate Sessions 107–110: Stage 5 Phase 1 formally closed (Session 107), Stage 4 Phase 1 formally closed (Session 107), BSMM→SMM annotation pass completed (Session 107), second systematic documentation review with 18 findings (Session 108), E009 CostDriver multiplicity fix and Suds StakeholderModel gap closed (Session 108), Vision Reference v6 refresh (Session 109), seven Session 108 findings resolved including console data source currency check convention, four `implementationStatus` corrections, SBMM paper terminology/version history/§11.4 fixes, and four emergent ideas log entries resolved (Session 110). Updated §3.2 (Suds BMM coverage), §3.5 (@BfoType extraction, F8), §3.6 (session/domain counts), §4.1–4.3 (history, current state, what comes next), §5 (vision reference v6). Refreshed Session 120 (3 April 2026) to incorporate Sessions 111–120: Stage 5 Phase 2 planning (Session 111), disjointness axioms, object properties, and cardinality restrictions (Sessions 112–114), Robot + HermiT full OWL 2 DL reasoning (Session 115), pipeline extension for typed refs and weighted relationship reification (Sessions 116–117), console data source currency check and BFO category display (Session 118), ontological hierarchy view and KG status panel (Session 119), Phase 2 formal closure with documentation and governance (Session 120). Updated §3.1 (OWL axiom metrics), §3.3 (13 console views, ontology route), §3.5 (reason_kg.py, Phase 2 pipeline outputs, correspondence graph 1,378 triples), §3.6 (92 session reports, E021), §4.1–4.3 (Sessions 111–120 history, Phase 2 closed, updated priorities and horizon), §5 (Phase 2 plan, E021 count), §7 (tools/ directory, catalog, reason_kg.py), §8 (Robot operational). Refreshed Session 127 (4 April 2026) to incorporate Sessions 121–127: deontic governance architecture paper (Session 121, B30–B34 registered), third systematic documentation review with 19 findings (Session 123), deontic governance OWL class design paper (Session 125, B35 registered), governance ontology Turtle implementation and validation (Session 126, 9-file ontology stack, 16-query SPARQL suite, first hand-authored ontology module outside BMM namespace), Vision Reference refreshed to v7 (Session 127, F2 resolved), workflow guide §6.2 vault structure updated (Session 127, F12 resolved). Updated §3.6 (26 discussion papers, 99 session reports), §4.1 (Sessions 121–127 history), §4.2 (governance workstream row, systematic review row updated), §4.3 (current position, priorities), §5 (vision reference v7, governance papers added), §7 (ontology/governance/ directory). Refreshed Session 138 (4 April 2026) to incorporate Sessions 128–137: work item tracker established (Session 128), seven Priority C items remediated and non-technical overview rewritten (Session 129), CQC Governance MVP planned (Session 130) and implemented with 21 individuals (Session 131), governance granularity/cross-references paper and console navigation context design paper (Session 132), I19 registered and W-010 Phase 1 implemented (Session 133), W-010 Phase 2 completed with 6 routes registered (Session 134), Stage 5 Phase 3 planned and Step 1 completed (Session 135), Block A completed with SPARQL suite 23→29 queries and governance vocabulary extended (Session 136), Phase 3 closed with round-trip diff engine and shared kg_utils.py (Session 137), fourth systematic documentation review (Session 138). Updated §3.3 (navigation context row), §3.5 (diff_kg.py, kg_utils.py, 29 queries, diff-report.json), §3.6 (30 papers, 110 reports, 48 concepts, ~201 register, E022), §4.1 (Sessions 128–137 history), §4.2 (Phase 3 closed, governance row expanded with CQC MVP, work item tracker row, navigation context row, systematic review row), §4.3 (current position, priorities, horizon updated), §5 (5 papers + 2 plans added, register and EIL counts), §6 (R6 concept count), §7 (scripts, generated, ontology descriptions updated). Stable filename — versioning expressed in the header.*
