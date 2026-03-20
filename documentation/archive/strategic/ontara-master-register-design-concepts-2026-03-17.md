# Ontara — Master Register of Design Concepts, Principles and Commitments

**Date:** 17 March 2026
**Purpose:** Comprehensive, systematically extracted inventory of every design concept, architectural principle, validated pattern, standing commitment, and design decision established across the project. Intended as a **checklist reference** — to be reviewed at intervals during development to guard against regression blindness.
**Method:** Extracted by thorough review of every document in `02 ARCHITECTURE & MODELLING` and the SysML model's PatternCatalogue.
**Status:** Living document. Should be updated when new concepts are introduced or existing ones are modified.

**Note:** This document consolidates two earlier documents (master concept list and master register) that were inadvertently created as duplicates in Session 35. This is the single canonical version.

---

## How to use this document

This is a **checklist**, not a narrative. It should be consulted:
- At the start and end of each working session (see [[ontara-development-workflow-guide-2026-03-17|Workflow Guide]] §6)
- Before starting any new workstream or phase
- During periodic project reviews
- When producing session reports and strategic snapshots
- When making architectural decisions

For each item, ask: "Is this concept still active in our thinking? Has this session's work honoured it, contradicted it, or rendered it obsolete?" Any concept that is no longer relevant should be explicitly retired with a rationale, not silently dropped.

---

## A. Foundational Architectural Principles

These are the highest-level commitments. Every other decision should be consistent with them.

| #   | Principle                                  | Source                                                                                                                                                                    | Summary                                                                                                                                                                                                                                                                                                                                                              |
| --- | ------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| A1  | Separation of representation and execution | [[gsl-platform-architecture-principles\|Architecture Principles paper]]                                                                                                   | The representation layer (SysML, archetypes, decision logic) is where knowledge lives. The execution layer (Temporal, XState, EHRbase, SvelteKit) is where things happen. Execution consumes representation but does not define it. When anything needs to change, the change happens in representation and propagates to execution via generation or configuration. |
| A2  | Self-describing system                     | [[gsl-platform-architecture-principles\|Architecture Principles paper]]; [[gsl-platform-sysml-modelling-strategy\|SysML Modelling Strategy]] §3.1                         | The system knows what it is, what it is doing, why it is doing it, and what rules govern it — because all of this is encoded in the model that generates and drives it. Reporting, audit, and governance are first-class system capabilities, not afterthoughts.                                                                                                     |
| A3  | Model generates everything                 | [[gsl-platform-architecture-principles\|Architecture Principles paper]]                                                                                                   | Corollary of A1. SysML v2 is the single source of truth. The model generates executable code, governance documentation, visual diagrams, constraint evaluators, decision table engines, and the system manifest.                                                                                                                                                     |
| A4  | Two meta model distinction                 | [[gsl-service-business-meta-modelling\|Service Business Meta Modelling]] §1; [[gsl-architecture-clarification-two-meta-models-2026-03-14\|Two Meta Models Clarification]] | The project maintains two distinct meta models: Business Meta Model (what a service business is — service concept, financial model, resources, activities, governance) and Business System Meta Model (how a business system works — processes, platform, data, knowledge, operations). Connected by explicit mappings. Independently iterable.                      |
| A5  | Validate in toy domains first              | PatternCatalogue [[principle-coffeeshop-first\|principle #5]]; [[ontara-discussion-vision-concepts-principles-2026-03-17\|Ontara discussion]] §5.5                        | New concepts should be validated in simple demonstrator domains (CSW, Suds, Paws) before extension to GSL and health. Concepts need to prove their worth with simple uses first.                                                                                                                                                                                     |
| A6  | Deterministic/auditable reasoning          | [[gsl-platform-sysml-modelling-strategy\|SysML Modelling Strategy]] §6; [[gsl-architecture-decision-knowledge-evaluation\|Architecture Decision: Knowledge Evaluation]]   | Clinical decisions use inspectable, deterministic logic — not probabilistic inference. The three-tier reasoning stack: Tier 1 (constraints/safety checks), Tier 2 (decision tables/Prolog), Tier 3 (ML/LLM — advisory only, never authoritative).                                                                                                                    |
| A7  | Patient autonomy and informed choice       | [[gsl-discussion-model-self-service-enabling-architecture-2026-03-14\|Self-Service Enabling Architecture]]                                                                | The platform supports successive generations of patient self-service. The authority model is explicit and versioned. Agency classification on every action. Four-generation roadmap.                                                                                                                                                                                 |
| A8  | Clinical governance as first-class concern | [[gsl-platform-architecture-principles\|Architecture Principles paper]]; [[gsl-validated-architectural-patterns\|Validated Patterns]] §5                                  | Requirements trace to constraints trace to runtime checks trace to audit evidence. Governance is structural, not bolted on. The satisfy traceability chain is the backbone.                                                                                                                                                                                          |
| A9  | Discipline as load-bearing structure | [[ontara-discussion-component-catalogue-model-assembly-2026-03-18|Component Catalogue discussion]] §8; Session 36 discussion | Disciplined working practices, tooling choices, paradigms, and frameworks are load-bearing — like foundations in structural engineering. You cannot build a complex, reliable, navigable system on shaky foundations, and you do not relax your grip partway through. Discipline in the development process propagates through the platform to the end user: what they build inherits the reliability and transparency of the platform itself, despite complexity. LLM-driven probabilistic mechanisms augment usability but do not replace deterministic foundations for mission-critical applications. Regression applies to practices and discipline, not just code. |

---

## B. Structural Architecture Concepts

These define how the system is organised.

| # | Concept | Source | Summary |
|---|---|---|---|
| B1 | Six-layer architecture | [[ontara-discussion-vision-concepts-principles-2026-03-17\|Ontara discussion]] §3.1 | Layer 6: meta-meta (SysML v2 language). Layer 5: Business Meta Model. Layer 4: Business System Meta Model. Layer 3: Business model instances. Layer 2: System model instances. Layer 1: Runtime. |
| B2 | Vertical mappings between layers | [[ontara-discussion-vision-concepts-principles-2026-03-17\|Ontara discussion]] §3.2; [[gsl-architecture-clarification-two-meta-models-2026-03-14\|Two Meta Models Clarification]] §1 | Mappings between layers are first-class, visible, navigable objects. ServiceOffering → pathways, ResourceType → platform components, PersistencePolicy → persistence layer, Pattern → DomainInstantiation, part def → part usages (coverage matrix), requirement → constraint → evaluator → evidence (satisfy chain). |
| B3 | Concentric rings of modelling rigour | [[gsl-platform-sysml-modelling-strategy\|SysML Modelling Strategy]] §8.1 | Inner ring: clinical pathways — maximum rigour, full generation. Middle ring: supporting infrastructure — structural clarity, partial generation. Outer ring: business context — architectural documentation. All in the same model. |
| B4 | Package structure (11 top-level) | [[gsl-platform-sysml-modelling-strategy\|SysML Modelling Strategy]] §7; [[gsl-strategic-snapshot-2026-03-15-s31\|Strategic Snapshot]] §5 | Enterprise, Foundation, Knowledge, ServiceDelivery, Platform, Operations, BusinessModel, BusinessScenarios, BusinessStrategy, PatternCatalogue, GenderSense root. 73 packages total. |
| B5 | ClinicalEntities separation | [[gsl-platform-sysml-modelling-strategy\|SysML Modelling Strategy]] §8.2 | Domain entities (Patient, Episode, Consultation, Prescription, Referral, LabResult) are separated from pathways. Entities are the nouns, pathways are the verbs. Each entity has a lifecycle state machine defined once and referenced by all pathways. |
| B6 | ServiceDelivery/Platform split | [[gsl-platform-sysml-modelling-strategy\|SysML Modelling Strategy]] §8.3 | Mirrors the two-layer action flow pattern. ServiceDelivery is the domain layer (clinical processes). Platform is the orchestration/infrastructure layer (how the system implements them). |
| B7 | Foundation as shared vocabulary | [[gsl-platform-sysml-modelling-strategy\|SysML Modelling Strategy]] §8.6 | MetadataLibrary, CommonTypes, StatePatterns, GenerationPipeline. Cross-cutting infrastructure imported by everything else. |
| B8 | Business System Meta Model — currently implicit | [[gsl-architecture-clarification-two-meta-models-2026-03-14\|Two Meta Models Clarification]] §2 | The BSMM concepts (PersistencePolicy, AgencyClassification, GoalProjection, Deficit, etc.) are distributed across Foundation, Knowledge, ServiceDelivery, Platform, Operations, PatternCatalogue. A future workstream will promote them into a named, navigable structure. |
| B9 | Meta model subsetting / templating | [[ontara-discussion-vision-concepts-principles-2026-03-17\|Ontara discussion]] §3.3 | A specific business instantiates only a subset of the full meta model vocabulary. Open design question: constrained subset meta models vs template/profiling approach (openEHR-style). To be resolved empirically. |
| B10 | Two-layer concept graph architecture | [[gsl-discussion-knowledge-graph-architecture-2026-03-15\|Knowledge Graph Architecture]] §3 | SysML as formal source of truth for patterns, principles, relationships. Obsidian as navigation and discursive layer. Generators between them. No maintained YAML — SysML is the single source. |
| B11 | General / Tailored meta model decomposition | [[ontara-discussion-component-catalogue-model-assembly-2026-03-18|Component Catalogue discussion]] §2.3 | Within each meta model (BMM and BSMM), components are classified as General (common to most service businesses, sector-agnostic) or Tailored (sector-specific, extending or specialising general components). Both tiers exist on both business and system sides. |
| B12 | Horizontal mappings at every tier | [[ontara-discussion-component-catalogue-model-assembly-2026-03-18|Component Catalogue discussion]] §7.2 | Mappings between business and system sides are explicit at every level: General BMM ↔ General BSMM, Tailored BMM ↔ Tailored BSMM, Individual business models ↔ Individual system models. Extends B2 (vertical mappings) to the full matrix. |
| B13 | Services / Goods scope boundary | [[ontara-discussion-component-catalogue-model-assembly-2026-03-18|Component Catalogue discussion]] §2.2 | Both Business and System meta models acknowledge a Services / Goods split. Current scope is Services. The architecture does not foreclose extension to goods-oriented businesses. |

---

## C. Five Concerns of a Service Business

From [[gsl-service-business-meta-modelling|Service Business Meta Modelling]] §2.1. Cross-cutting: Activity Awareness.

| # | Concern | Summary |
|---|---|---|
| C1 | Service Concept | What value is delivered, to whom, and why it is worth paying for. Value proposition, customer segments, differentiation, channels. |
| C2 | Service Delivery System | How value is produced and delivered. Processes, pathways, workflows, entity lifecycles, outcomes, handoff points. |
| C3 | Resource and Capability Model | What resources and capabilities are required. People, estate, equipment, technology, licences. Capabilities are organised combinations of resources. |
| C4 | Financial Model | How money flows. Revenue streams, cost drivers, unit economics, pricing models, financial projections. |
| C5 | Governance and Adaptation | Regulatory requirements, governance processes, risk, learning mechanisms, strategic objectives. |
| C6 | Activity Awareness (cross-cutting) | Every unit of activity is visible. Five categories: service delivery, service-enabling, governance, development, overhead. Progressive elaboration: envelope → category → tracked. The common currency connecting all five concerns. |

---

## D. Validated Architectural Patterns (22 + 6 deferred)

From [[gsl-validated-architectural-patterns|Validated Architectural Patterns]] document and PatternCatalogue (22 patterns, 8 principles, 43 typed relationships).

### Business Meta Model patterns (4)

| # | Pattern | Status | CSW | GSL |
|---|---|---|---|---|
| D1 | [[pattern-four-layer-item-model\|Four-layer item model]] | validated | ✓ | discussion |
| D2 | [[pattern-activity-taxonomy\|Activity taxonomy]] | validated | ✓ | ✓ |
| D3 | [[pattern-scenario-comparison\|Scenario comparison and projection]] | validated | — | ✓ |
| D4 | [[pattern-persistence-policy\|Persistence policy as queryable reasoning]] | validated | ✓ | — |

### Business System Meta Model patterns (16)

| # | Pattern | Status | CSW | GSL |
|---|---|---|---|---|
| D5 | [[pattern-sysml-as-source-of-truth\|SysML v2 as single source of truth]] | validated | ✓ | ✓ |
| D6 | [[pattern-two-layer-action-flow\|Two-layer pathway modelling]] | validated | ✓ | ✓ |
| D7 | [[pattern-five-layer-self-knowledge\|Five-layer self-knowledge]] | validated | — | ✓ |
| D8 | [[pattern-three-layer-persistence\|Three-persistence-layer architecture]] | validated | ✓ | designed |
| D9 | [[pattern-metadata-driven-generation\|Metadata-driven generation]] | validated | ✓ | ✓ |
| D10 | [[pattern-xstate-in-temporal\|XState in Temporal]] | validated | ✓ | — |
| D11 | [[pattern-catalogue-as-ui-contract\|Catalogue-as-UI-contract]] | validated | ✓ | — |
| D12 | [[pattern-kanban-as-process-dashboard\|Kanban-as-process-dashboard]] | validated | ✓ | — |
| D13 | Split-view management layout | validated | ✓ | — |
| D14 | Category-conditional form fields | validated | ✓ | — |
| D15 | Cross-page data consistency | validated | ✓ | — |
| D16 | [[pattern-audit-as-timeline\|Audit-as-timeline data source]] | validated | ✓ | — |
| D17 | Process + domain + governance unified view | validated | ✓ | — |
| D18 | CDR source provenance badges | validated | ✓ | — |
| D19 | Auto-loading entity views | validated | ✓ | — |
| D20 | [[pattern-infrastructure-health\|Infrastructure health as app concern]] | validated | ✓ | — |

### Cross-cutting (1)

| # | Pattern | Status |
|---|---|---|
| D21 | Coffee shop demonstrator as standing practice | validated |

### Deferred / conceptual (6)

| # | Pattern | Status |
|---|---|---|
| D22 | Composite order / multi-workflow orchestration | discussion |
| D23 | Agency classification on actions | designed |
| D24 | Self-assessment dashboard (KL Increment 3) | designed |
| D25 | OptionEvaluator / Help Me Choose | designed |
| D26 | Data release model (patient-facing) | discussion |
| D27 | Notification triggers on transitions | discussion |

---

## E. Generation Pipeline Concepts

| # | Concept | Source | Summary |
|---|---|---|---|
| E1 | Two-phase generation pipeline | [[gsl-discussion-model-two-phase-generation-pipeline-2026-03-13\|Two-Phase Generation Pipeline discussion]] | Phase 1: domain generators (model-aware, framework-agnostic) produce domain artefacts + manifest. Phase 2: integration generators (model-agnostic, framework-aware) produce wiring code from the manifest. |
| E2 | Four-layer generated code architecture | [[gsl-discussion-model-two-phase-generation-pipeline-2026-03-13\|Two-Phase Generation Pipeline]] §5.1 | Layer 1: SysML model. Layer 2: domain artefacts (generated, never hand-edited). Layer 3: integration glue (generated, never hand-edited). Layer 4: application code (hand-written, imports from L2/L3, never overwritten by generators). |
| E3 | Manifest as architectural asset | [[gsl-discussion-model-two-phase-generation-pipeline-2026-03-13\|Two-Phase Generation Pipeline]] §5.3; [[gsl-architecture-decision-knowledge-evaluation\|Architecture Decision: Knowledge Evaluation]] §2 | The generation manifest is the queryable record of what the system contains, what was generated from what, and how things connect. Extends the system manifest with provenance. Foundation for self-knowledge. |
| E4 | Regeneration safety | [[gsl-discussion-model-two-phase-generation-pipeline-2026-03-13\|Two-Phase Generation Pipeline]] §5.2 | Generated layers (2 and 3) are freely regenerable. Application code (layer 4) is never touched. The four-layer separation enforces this. |
| E5 | Generatability spectrum | [[gsl-discussion-model-two-phase-generation-pipeline-2026-03-13\|Two-Phase Generation Pipeline]] §4 | High value (generate fully): types, enums, state machines, schema DDL, barrel exports. Medium value (generate skeleton, hand-finish): workflow stubs, composition builders, API route handlers. Low value (don't generate): UI design, clinical decision content, error messages, tests. |
| E6 | Nine operational generators | [[gsl-strategic-snapshot-2026-03-15-s31\|Strategic Snapshot]] §2; [[gsl-validated-architectural-patterns\|Validated Patterns]] §9 | 4 demonstrator: types, state machines, temporal workflows, mermaid. 5 model-level: package hierarchy, constraint evaluators, decision table evaluators, system manifest, concept graph. |
| E7 | Generators fail loudly, degrade gracefully | [[gsl-validated-architectural-patterns\|Validated Patterns]] §9 | Unparseable expressions emit TODO placeholders, never broken output. |
| E8 | Regex parsers as executable specifications | [[gsl-validated-architectural-patterns\|Validated Patterns]] §9; [[gsl-discussion-model-two-phase-generation-pipeline-2026-03-13\|Two-Phase Generation Pipeline]] §6 | Current text-based parsers are adequate but fragile. They serve as executable specifications for future Syside Automator migration: same input → same output. |

---

## F. Knowledge Layer and Self-Knowledge Concepts

| # | Concept | Source | Summary |
|---|---|---|---|
| F1 | Five-layer SystemStateAssessment | [[gsl-architecture-decision-knowledge-evaluation\|Architecture Decision: Knowledge Evaluation]] §2–6 | Layer 1 (structural): system manifest. Layer 2 (operational): query Temporal, CDR, platform. Layer 3 (goal-state): project from requirements, constraints, outcomes. Layer 4 (gap analysis): compare L2 vs L3, produce Deficits. Layer 5 (remediation): classify as automatic, recommended, or advisory. |
| F2 | Evaluation invocation pattern | [[gsl-architecture-decision-knowledge-evaluation\|Architecture Decision: Knowledge Evaluation]] §1 | Pathway step → metadata annotation → generated activity → evaluation engine → resolve inputs → evaluate constraint → structured EvaluationResult → audit record. Same engine for point-of-care and population governance. |
| F3 | Evaluation spec pattern (:>> redefinition) | [[gsl-validated-architectural-patterns\|Validated Patterns]] §6 | General template (part def) with concrete instances (part usages) that redefine attributes. Separates \"what the rule is\" (ConstraintLibrary) from \"how to evaluate it\" (CDS evaluation specs). |
| F4 | Three remediation categories | [[gsl-architecture-decision-knowledge-evaluation\|Architecture Decision: Knowledge Evaluation]] §5 | Automatic (system acts), Recommended (human required), Advisory (systemic/compound). Default for any new deficit is Recommended — system never takes automatic clinical action unless model explicitly permits it. |
| F5 | Operational steering as self-knowledge extension | [[gsl-service-business-meta-modelling\|Service Business Meta Modelling]] §4.7 | The forecast-actuals-rebaseline cycle is structurally parallel to clinical self-knowledge. GoalProjector → ProjectionFormulas. OperationalStateAggregator → financial actuals. GapAnalyser → VarianceAnalysis. Deficit → Variance. Same machinery, different domain. |
| F6 | Tau Prolog for Tier 2 reasoning | [[gsl-validated-architectural-patterns\|Validated Patterns]] §11 | Compound deficit reasoning, \"why not\" explanation, inference chains. 16/16 tests, <4ms/query. Adoption conditional on complexity growth. |
| F7 | Three assessment invocation patterns | [[gsl-architecture-decision-knowledge-evaluation\|Architecture Decision: Knowledge Evaluation]] §6 | On-demand (API), Scheduled (Temporal cron), Triggered (critical deficit cascades to broader assessment). |

---

## G. CDR and Clinical Data Concepts

| # | Concept | Source | Summary |
|---|---|---|---|
| G1 | openEHR as clinical data architecture | [[gsl-platform-architecture-principles\|Architecture Principles paper]] | EHRbase CDR, archetype-based modelling, AQL queries, SNOMED CT terminology binding. |
| G2 | Two data paths, one CDR | [[gsl-cdr-exercise-summary-2026-03-08\|CDR Exercise summary]]; [[gsl-validated-architectural-patterns\|Validated Patterns]] §10 | Workflow-driven (Temporal activities commit compositions) and form-driven (SvelteKit endpoints commit directly). Same structured, queryable data. |
| G3 | Two views onto the same data | [[gsl-platform-architecture-principles\|Architecture Principles paper]]; [[gsl-cdr-exercise-summary-2026-03-08\|CDR Exercise]] | Process view (Temporal workflow state) and entity view (AQL queries by archetype type). Complementary, no duplication. |
| G4 | Application-level join for governance | [[gsl-validated-architectural-patterns\|Validated Patterns]] §10 | Two AQL queries joined in TypeScript by EHR ID. Necessary because EHRbase 2.11.0 doesn't support complex AQL. |
| G5 | Composition builder per template | [[gsl-validated-architectural-patterns\|Validated Patterns]] §10 | Dedicated builder function per archetype template. Hand-maintained for CSW; should be generated for clinical archetypes. |
| G6 | SysML-to-openEHR traceability via metadata | [[gsl-validated-architectural-patterns\|Validated Patterns]] §4 | @OpenEhrArchetype and @OpenEhrTemplate on part defs. Machine-queryable traceability. Per-element mapping via inline comments (//at0NNN | DV_TYPE). |

---

## H. Self-Service and Patient Autonomy Concepts

| # | Concept | Source | Summary |
|---|---|---|---|
| H1 | Enabling architecture, not fixed model | [[gsl-discussion-model-self-service-enabling-architecture-2026-03-14\|Self-Service Enabling Architecture]] §1 | The platform supports successive generations of self-service. Cannot be fixed today because clinical liability landscape is shifting, regulation constrains delegation, population is heterogeneous, governance framework must evolve. |
| H2 | Agency classification | [[gsl-discussion-model-self-service-enabling-architecture-2026-03-14\|Self-Service Enabling Architecture]] §7 | Every action classified by who performs it: system, clinician, patient, shared. Model-level metadata, not code-level configuration. |
| H3 | Four-generation self-service roadmap | [[gsl-discussion-model-self-service-enabling-architecture-2026-03-14\|Self-Service Enabling Architecture]] | Gen 1: transparent information. Gen 2: guided self-navigation. Gen 3: supervised autonomy. Gen 4: full autonomy with oversight. Each generation introduces new governance requirements. |
| H4 | CoPHR heritage principles | [[gsl-discussion-model-self-service-enabling-architecture-2026-03-14\|Self-Service Enabling Architecture]] §2 | Patient control of access. Irrevocable access to relied-upon data. Mandatory provenance and audit. Medico-legal validity. Data portability. Separation of record from application. |
| H5 | Clinical authority problem | [[gsl-discussion-model-self-service-enabling-architecture-2026-03-14\|Self-Service Enabling Architecture]] §3 | Clinician authority preserved where required. System role transparent. Authority model explicit and versioned. Nothing assumed about future liability model. |
| H6 | Harm reduction principles | [[gsl-discussion-model-self-service-enabling-architecture-2026-03-14\|Self-Service Enabling Architecture]] §3.4 | Meet patients where they are. Record without judgment. System accommodates patients arriving mid-stream with self-administered medication. |

---

## I. Ontara Platform and Console Concepts

| # | Concept | Source | Summary |
|---|---|---|---|
| I1 | Platform characteristics | [[ontara-discussion-vision-concepts-principles-2026-03-17\|Ontara discussion]] §1.1; [[Platforms\|Platforms research]] | Modular architecture, standardised interfaces, abstraction/generality, lifecycle support, evolutionary stability, ecosystem enablement, composability, extensibility, integrated tooling. |
| I2 | Dual canvas (business + system) | [[ontara-discussion-vision-concepts-principles-2026-03-17\|Ontara discussion]] §4.2 | Business canvas: compose business models from Layer 5 pieces. System canvas: map technology components from Layer 4. Linked by vertical traceability. |
| I3 | Meta models as palette grammar | [[ontara-discussion-vision-concepts-principles-2026-03-17\|Ontara discussion]] §4.4 | Business Meta Model defines business palette. Business System Meta Model defines system palette. PatternCatalogue as recommendation engine. |
| I4 | Three levels of completeness tracking | [[ontara-discussion-vision-concepts-principles-2026-03-17\|Ontara discussion]] §4.5 | Level 1: instance coverage (which domains instantiate which defs). Level 2: pattern coverage (which domains exercise which patterns). Level 3: meta model adequacy (vocabulary gaps). |
| I5 | Console vs generated domain applications | [[ontara-discussion-vision-concepts-principles-2026-03-17\|Ontara discussion]] §4.7 | Console is platform development tool (model-aware, architect-facing). Domain application is generated and operator-facing. Different things, shared technology. |
| I6 | Filtered views and field of view control | [[ontara-discussion-vision-concepts-principles-2026-03-17\|Ontara discussion]] §4.6 | By layer, domain, concern, cross-domain comparison, gap analysis, pattern coverage. |
| I7 | Component Catalogue | [[ontara-discussion-component-catalogue-model-assembly-2026-03-18|Component Catalogue discussion]] §3.1 | A browsable, filterable catalogue of individual meta model components (both General and Tailored, both BMM and BSMM). Components are tagged SysML `part def`s with metadata annotations. The catalogue is a view over the SysML model, not a separate data structure. Consistent with A3 and D9. |
| I8 | Model Catalogue | [[ontara-discussion-component-catalogue-model-assembly-2026-03-18|Component Catalogue discussion]] §3.2 | A catalogue of complete or near-complete assembled model configurations — pre-validated starting points. A model catalogue entry is a curated assembly of component catalogue entries, validated as complete and coherent. Users can start from a model catalogue entry and customise, or build from scratch. |
| I9 | Assembly workspace (drag-and-drop) | [[ontara-discussion-component-catalogue-model-assembly-2026-03-18|Component Catalogue discussion]] §4 | A core console interaction where users assemble models by dragging components from the Component Catalogue onto the dual canvas. Real-time completeness feedback. Mappings between business and system sides shown live. |
| I10 | Tagging system for catalogue filtering | [[ontara-discussion-component-catalogue-model-assembly-2026-03-18|Component Catalogue discussion]] §6 | Components are tagged across multiple dimensions (e.g. Regulation, Sector, Delivery Mode). Tags are SysML metadata annotations. Dimensions can be exclusive or inclusive. Tag dimensions and values supplied by Ontara; user-generated tags are a future nice-to-have. |
| I11 | Model validation — progressive status | [[ontara-discussion-component-catalogue-model-assembly-2026-03-18|Component Catalogue discussion]] §5 | Assembled models are validated at three levels: structural completeness (required components present), internal consistency (components fit together), runnability (can drive execution layer). Console surfaces this as a progressive status: Incomplete → Complete but unchecked → Validated → Runnable. |
| I12 | Console as architect’s own tool | [[ontara-discussion-component-catalogue-model-assembly-2026-03-18|Component Catalogue discussion]] §8.2 | The console is built for Ella as first user. It should closely reflect and support her cognitive style: top-down delimitation, rigorous abstraction, filtered views controlling field of view and subject of concern, building generalisable models from specific instances. Development driven by actual needs, not abstract specifications. |
| I14 | Comprehension layer | [[ontara-high-level-plan-2026-03-18|High-Level Plan]]; Session 37 discussion | A distinct architectural concern: making the model *comprehensible* to its users, not just structurally navigable. Navigation answers "can I find the thing?" Comprehension answers "do I understand what I'm looking at?" SysML identifiers are code-friendly (e.g. `ConstraintEvaluationSpec`, `OperationalStateAggregator`) and doc blocks are terse technical descriptions written for someone already immersed in the model — these are a genuine comprehension barrier, not a cosmetic issue, and it worsens as the system grows. The comprehension layer comprises user-facing metadata on elements (I14a), a glossary (I15), and contextual help surfaces in the UI (tooltips, info panels, info buttons). All content is authored in the SysML model and generated into the console, consistent with A3. Future extensions may include worked examples, progressive disclosure (simple explanation first, technical detail on request), concept relationship explanations, and guided tours. |
| I14a | User-facing metadata on SysML elements | [[ontara-high-level-plan-2026-03-18|High-Level Plan]]; Session 37 discussion | SysML metadata annotation (`@UserFacing` or similar in Foundation::MetadataLibrary) providing a `friendlyName` and `shortDescription` (character-limited, lay-language) for any element. The console pulls this content into hover tooltips, info buttons, info panels, and other contextual help surfaces. The same data is presented in multiple ways depending on context. Generated into JSON by the introspection generator, consumed by the console. Consistent with A3 (model generates everything) and D9 (metadata-driven generation). |
| I15 | Glossary of terms in the console UI | Session 37 discussion | A navigable, searchable dictionary of terms used in the system, accessible from the console UI, with links from any displayed entity name to its glossary entry. Generated from the `@UserFacing` metadata — every element with a `friendlyName` and `shortDescription` automatically has a glossary entry. Supports contextual access: clicking a term in the coverage matrix, package navigator, or any other view links to its glossary definition. |
| I13 | Externally validated / endorsed model configurations | [[ontara-discussion-component-catalogue-model-assembly-2026-03-18|Component Catalogue discussion]] §3.2.1 | Model Catalogue entries can carry external validation or endorsement against named regulatory or industry standards (e.g. CQC fundamental standards, Animal Welfare Act, trade body codes of practice). Adopting an endorsed model configuration reduces compliance risk, insurance and indemnity costs, and setup overhead. Future development includes user-published models and components, and externally validated models meeting compliance standards. Connects to governance traceability (A8) — the endorsement is backed by the satisfy chain from requirement through to audit evidence. |

---

## J. Development Methodology and Process Concepts

| # | Concept | Source | Summary |
|---|---|---|---|
| J1 | Cross-domain validation | [[ontara-discussion-vision-concepts-principles-2026-03-17\|Ontara discussion]] §6.1 | Every concept/pattern should validate in at least two domains. CSW/Suds/Paws, with GSL as eventual production target. |
| J2 | Co-evolution of model and tooling | [[ontara-discussion-vision-concepts-principles-2026-03-17\|Ontara discussion]] §6.2 | No modelling without the tool that makes it legible. No tool without model content that exercises it. |
| J3 | Non-constraining architecture | [[ontara-discussion-vision-concepts-principles-2026-03-17\|Ontara discussion]] §6.3; [[gsl-platform-architecture-principles\|Architecture Principles paper]] | Decisions should not foreclose future development paths. Clean abstractions, loose coupling, discoverable structure. |
| J4 | Model should earn its keep | [[gsl-platform-sysml-modelling-strategy\|SysML Modelling Strategy]] §8.6 | If modelling something merely restates the obvious, stop. The model generates something or makes a non-obvious relationship visible. |
| J5 | Periodic project reviews | [[gsl-architecture-clarification-two-meta-models-2026-03-14\|Two Meta Models Clarification]] §4.5; Standing concern | Check for conceptual drift, factual inaccuracies, fuzzy equivalences in generated documents. Catch errors before they forward-propagate. |
| J6 | Standing concern: LLM prose smuggling fuzzy equivalences | Multiple sessions | LLM-generated prose can introduce subtle conceptual inaccuracies that look plausible. Periodic reviews are the countermeasure. Part def (meta model) vs part usage (instance) is a critical distinction. |
| J7 | Working documents in Obsidian, commits to repo | [[ontara-discussion-vision-concepts-principles-2026-03-17\|Ontara discussion]] §10; [[ontara-development-workflow-guide-2026-03-17\|Workflow Guide]] §3 | Working documents created/edited in Obsidian vault. Committed to repo under documentation/archive/ when settled. Repo is a curated versioned record. |
| J8 | Governance requirements for toy domains | [[ontara-discussion-vision-concepts-principles-2026-03-17\|Ontara discussion]] §5.6 | Suds and Paws each include domain-appropriate governance requirements to exercise the satisfy traceability chain in non-health contexts. |
| J9 | Session reports and strategic snapshots | Standing practice | Session reports at session end. Strategic snapshots at workstream boundaries. Both are reviewed for accuracy before being treated as reference. |
| J10 | Retrospective bootstrapping | [[ontara-discussion-component-catalogue-model-assembly-2026-03-18|Component Catalogue discussion]] §8; Session 36 discussion | After each development step, ask: "how could our own tooling or processes have made that easier?" If there is a good answer with an achievable solution, implement it as part of ongoing work. The act of developing reveals friction points; addressing them is not deferred work but part of the development itself. This operationalises J2 (co-evolution) with a retrospective improvement loop, and ensures the tooling progressively makes its own further development easier. Influenced by DHH's Rails philosophy: extract the framework from the application you are actually building, not from abstract specification. |
| J11 | Bottom-up discovery meets top-down framing | [[ontara-discussion-component-catalogue-model-assembly-2026-03-18|Component Catalogue discussion]] §8.6; Session 36 discussion | The development approach intelligently combines bottom-up and top-down thinking. Bottom-up exploration (organic development, demonstrator work, pattern discovery, cross-domain experimentation) generates insight and reveals structure. Top-down framing (the register, the layered architecture, the workflow guide, the meta models) captures and protects that insight so it is not lost or degraded. Neither mode dominates: top-down framing without bottom-up discovery produces rigid, speculative architectures disconnected from reality; bottom-up discovery without top-down framing produces insight that dissipates before it can compound. The combination allows complexity to grow while remaining navigable. The CSW demonstrator exemplifies this: patterns were discovered bottom-up through practical work, then organised top-down into the architecture and register. |
| J12 | Design decision lifecycle | [[ontara-discussion-element-grouping-viewpoints-comprehension-2026-03-19|Element Grouping discussion]] §9.2; Session 38 discussion | Design decisions follow a lifecycle: **freedom → experimentation → discovered convention → opinionated configuration → (revisable)**. Early-stage development deliberately preserves freedom (J3) rather than locking in structure prematurely. Through experimentation and use, conventions are discovered empirically (J11). When the system goes into use, the system designer commits to opinionated configuration — making choices about which options, groupings, tags, and structures to present. These choices remain revisable; opinionated does not mean permanent. This lifecycle is the pragmatic expression of J3 (non-constraining architecture) across time: non-constraining at the beginning does not mean uncommitted forever, and committed does not mean irreversible. |

---

## K. Semantic Relationship Vocabulary

From [[gsl-discussion-knowledge-graph-architecture-2026-03-15|Knowledge Graph Architecture]] §4. Ten typed predicates modelled as `ref` fields on Pattern.

| Predicate | Meaning | Inverse |
|---|---|---|
| dependsOn | X requires Y | enables |
| enables | X makes Y possible | dependsOn |
| motivatedBy | X fulfils principle Y | motivates |
| generalises | X is more abstract than Y | specialises |
| constrains | X limits or governs Y | constrainedBy |
| extends | X adds capability on top of Y | extendedBy |
| validatedBy | X is proven by Y | validates |
| composedWith | X and Y are used together | composedWith |
| analogueTo | X in domain A ≡ Y in domain B | analogueTo |

---

## L. Simulation Concepts

From [[gsl-service-business-meta-modelling|Service Business Meta Modelling]] §9.

| # | Concept | Summary |
|---|---|---|
| L1 | Simulation data generation | Patient generation (configurable arrival, segments, profiles). Event generation (lab results, cancellations, GP responses with realistic timing). Environmental starter sets (initial state for simulation runs). |
| L2 | Workflow execution under simulation | Automated signal resolution. Decision point agents (simple rule-based to sophisticated variation). Resource contention (finite resources, queuing, wait times). |
| L3 | Temporal control | Time compression. Start/stop/pause/save/delete. Variable time intervals. Checkpointing and branching. |
| L4 | Simulation purposes | Learning/intuition-building. Stress-testing. Demonstration. Training. Evaluation of business model variants. |

---

## M. Horizon Items

Captured from various discussions. Not committed workstreams — future possibilities.

| # | Item | Source | Summary |
|---|---|---|---|
| M1 | Hookmark cross-desktop linking | [[gsl-discussion-knowledge-graph-architecture-2026-03-15\|Knowledge Graph Architecture]] §1.1 | Bidirectional links between Obsidian, VS Code, Finder, Mail. Spike planned. |
| M2 | Tom Sawyer SysML v2 Viewer | [[gsl-discussion-knowledge-graph-architecture-2026-03-15\|Knowledge Graph Architecture]] §7.1 | Standalone web viewer for stakeholder-facing graphical model views. Requires SysML v2 API-compliant repository. |
| M3 | Syside Automator for generation | [[gsl-platform-sysml-modelling-strategy\|SysML Modelling Strategy]] §9.2.3; [[gsl-validated-architectural-patterns\|Validated Patterns]] §9 | Semantic model access replacing regex parsers. Targeted for when Automator API stabilises. |
| M4 | Form generation from model | [[gsl-platform-sysml-modelling-strategy\|SysML Modelling Strategy]] §9.3.2 | Clinical form definitions generated from SysML. Major surface area for data capture. |
| M5 | Prolog rule generation | [[gsl-validated-architectural-patterns\|Validated Patterns]] §11 | constraint def → Tau Prolog rules. Contingent on Tier 2 adoption. |
| M6 | Population-level governance | [[gsl-platform-sysml-modelling-strategy\|SysML Modelling Strategy]] §9.3.3 | Scheduled Temporal workflows querying CDR, evaluating rules, producing cohort governance reports. |

---

## N. Standing Conventions and Guard Rails

| # | Convention | Source |
|---|---|---|
| N1 | Every new `part def` or `metadata def` carries a doc block identifying its meta model (\"business meta model concept\" or \"business system meta model concept\"). | [[gsl-architecture-clarification-two-meta-models-2026-03-14\|Two Meta Models Clarification]] §4.1 |
| N2 | Documents use explicit vocabulary: \"the business meta model\" or \"the system meta model\", never \"the GSL meta model\". | [[gsl-architecture-clarification-two-meta-models-2026-03-14\|Two Meta Models Clarification]] §4.2 |
| N3 | The [[gsl-service-business-meta-modelling\|service business meta modelling paper]] is the authoritative source for BMM structure. Contradictions in other documents should be corrected. | [[gsl-architecture-clarification-two-meta-models-2026-03-14\|Two Meta Models Clarification]] §4.3 |
| N4 | Periodic project reviews check for conceptual drift. | [[gsl-architecture-clarification-two-meta-models-2026-03-14\|Two Meta Models Clarification]] §4.5 |
| N5 | Generated files carry `DO NOT EDIT` headers with timestamp and source reference. | [[gsl-validated-architectural-patterns\|Validated Patterns]] §9 |
| N6 | Generators fail loudly and degrade gracefully — unparseable expressions emit TODO placeholders, never broken output. | [[gsl-validated-architectural-patterns\|Validated Patterns]] §9 |
| N7 | Standing concern: LLM-generated prose can smuggle fuzzy conceptual equivalences. Periodic reviews are the countermeasure. Part def (meta model) vs part usage (instance) is a critical distinction. | Standing rule |
| N8 | `part def` (meta model) vs `part` (instance) is a critical distinction. Conceptual precision required. | Standing rule |
| N9 | Paths containing `&` work in MCP but require escaping in bash. `~` prefix causes path failures — use full paths. | Standing rule |
| N10 | SysML syntax reference file should be checked before writing new `.sysml` code. Syside syntax differs from spec in several ways. | Standing rule |
| N11 | Working documents in Obsidian vault. Committed to repo under `documentation/archive/` when settled. Repo is a curated versioned record. | [[ontara-development-workflow-guide-2026-03-17\|Workflow Guide]] §3 |

---

## O. Identified Gaps and Future Work

Concepts that are designed but not yet implemented or exercised.

| # | Gap | Relevant concepts |
|---|---|---|
| O1 | Knowledge Layer Increments 1–3 (constraint evaluation, decision tables, self-assessment) not yet exercised at runtime. | F1, F2, F3, F4 |
| O2 | Business System Meta Model not yet extracted into named package. | A4, B8 |
| O3 | No second clinical pathway. Architecture claims to generalise but only one pathway exists. | D6, D9, A5 |
| O4 | Composite order / multi-workflow orchestration not implemented. | D22 |
| O5 | HandoffPoint not modelled as first-class concept. | [[gsl-service-business-meta-modelling\|Service Business Meta Modelling]] §3.2 |
| O6 | ~~Four~~ ~~Three~~ Two BMM part defs completely uninstantiated (ActivityBudget, ActivityRecord). ~~ActivityCostAllocation~~ now has 2 Suds instances (Session 41). ~~InventoryRecord~~ still uninstantiated but now joined by AuditEvidenceRecord with 4 Suds instances (Session 42, Phase 6). ExternalReference has Cafe + Suds instances. | C1 |
| O7 | Twelve BSMM part defs completely uninstantiated (GapAnalyser, ConstraintEvaluator, AssessmentOrchestrator, etc.). | B8, F1 |
| O8 | Two-phase generation pipeline designed but not implemented. | E1, E2 |
| O9 | Simulation capability conceptualised but not designed in detail. | L1–L4 |
| O10 | Hookmark cross-desktop linking — spike planned but not executed. | M1 |
| O11 | Tom Sawyer SysML v2 Viewer — horizon item. | M2 |
| O12 | Clinical archetypes not yet designed for GSL production use. CDR integration validated with CSW patterns only. | G1–G6 |
| O13 | ~~Suds~~ and ~~Paws~~ domains ~~not yet~~ created. Suds initial business model created Session 37 (3 packages, ~40 elements). Suds expanded to full BMM coverage Session 41 (Phase 3, ~50 elements). Suds design note written. **Paws created Session 44 (Stage 3 Phase 1).** 3 packages (PawsBusinessModel, PawsResourceFinancial, PawsGovernance), 51 elements. All five BMM concerns covered using exclusively General vocabulary. Parses clean. Design note written. Three-domain cross-domain validation threshold (J1) now met for BMM vocabulary. Governance posture: general professional duty of care (Animal Welfare Act) — no constraint def / satisfy chain (lighter than Suds's COSHH). Service subject ≠ customer observation captured (pet owner pays, dog receives service — parallels GSL patient). | I5, J1 |
| O14 | Ontara Console — Stage 1 complete (Session 37). Coverage matrix and package navigator working. Component Catalogue built (Session 40, Phase 4) with multi-axis grouping, element detail, comprehension layer rendering, and coverage matrix cross-linking. Coverage matrix domain filter added (Session 41) — toggle domain columns on/off from control panel. Assembly workspace, dual canvas, and pattern graph remain Stage 3 work. | I2, I4, I6, I7, I12 |
| O15 | Meta model subsetting / templating mechanism not resolved. | B9 |
| O24 | SysML v2 viewpoint/view investigation complete (Session 43, Stage 2 Phase 5). `viewpoint def`, `view def`, `view`, `expose`, `filter` all parse and resolve in Syside 0.8.5. `rendering def`/`render` fail. `frame concern`/`stakeholder` in viewpoints fail. Recommendation: adopt partially in Stage 3 — model views as structured declarations, evaluate via generator and console. Cross-package expose against BMM verified. Findings in `ontara-investigation-sysml-viewpoints-2026-03-19.md`. | A3, J3, J12 |
| O16 | ~~Component Catalogue~~ built (Session 40, Phase 4). Model Catalogue not yet built. Console assembly workspace not yet implemented. | I7, I8, I9 |
| O17 | Tagging system implemented end-to-end. `@CatalogueTag` metadata def defined (Session 38), applied to 24 BMM `part def`s, generator extracts facet summaries (Session 39), Component Catalogue view consumes facet data for dynamic "group by" controls (Session 40). Four grouping axes: BMM Concern, Classification, Package, Domain Coverage. New facet dimensions added to the model will appear automatically in the catalogue. | I10, B11 |
| O18 | SysML mechanism for Model Catalogue entries not yet determined (ModelTemplate part def, composite part usage, or other). | I8 |
| O19 | ~~Component granularity not yet determined.~~ Resolved Session 38: atomic unit is an element (typically `part def`); grouping is a presentation/viewpoint concern, not fixed model granularity. See [[ontara-discussion-element-grouping-viewpoints-comprehension-2026-03-19|Element Grouping discussion]]. | I7 |
| O20 | Comprehension layer partially implemented. `@UserFacing` metadata def defined (Session 38), applied to 12 BMM `part def`s (46.2% coverage), generator extracts and tracks coverage (Session 39). Component Catalogue now renders friendly names prominently where available, shows "No description available" where missing, and displays comprehension coverage stats in header (Session 40). Glossary view built (Session 45, Stage 3 Phase 2) — see O21. **Session 45 discussion paper** identified three registers of comprehension: Register 1 (static authored labels — current state), Register 2 (generated explanations from model structure — tractable near-term), Register 3 (conversational self-knowledge — connects to C6). Demonstrator domains identified as having a dual purpose: cross-domain validation (J1) + pedagogical anchoring (concrete illustrations for non-technical users). Discussion paper: `ontara-discussion-comprehension-architecture-2026-03-19.md`. Remaining `@UserFacing` coverage expansion is Phase 3. | I14, I14a, D9 |
| O21 | ~~Glossary not yet built in the console UI.~~ Glossary built (Session 45, Stage 3 Phase 2). `/glossary` route with alphabetical listing, search, BMM Concern and Layer filtering, inline expand/collapse with short description, doc block excerpt, domain usage summary, and cross-links to Component Catalogue and Coverage Matrix. Sidebar and home page updated. Currently 12 entries (elements with `@UserFacing` annotations). Coverage stat displayed: "12 of 26 catalogue elements have glossary entries (46.2%)". No generator changes required — existing introspection JSON data was sufficient. | I15 |
| O22 | GovernanceMapping sub-package added to BMM (Session 42, Phase 6). Two General definitions: `GovernanceRequirement` (requirement def) and `AuditEvidenceRecord` (part def), both with `@CatalogueTag` and `@UserFacing`. First BMM requirement def. Exercises A8, J8, B2. | A8, J8, B2 |
| O23 | Governance traceability view added to console (`/governance`, Session 42 Phase 6). Traceability chain visualisation, evidence records table, constraint definitions section. Domain and type filtering. Sidebar navigation updated. Exercises J2 (co-evolution). | J2, A8, I12 |

---

*Master register compiled 17 March 2026 from systematic review of all documents in `02 ARCHITECTURE & MODELLING`. Updated 18 March 2026 (Session 36) with Component Catalogue, Model Catalogue, assembly architecture, tagging system, and model validation concepts (B11–B13, I7–I13, O16–O19). Updated 18 March 2026 (Session 37) with gap status changes for O6, O13, O14 following Suds domain creation and Ontara Console Stage 1 completion. Added I14 (user-facing metadata), I15 (glossary), O20, O21. Updated 19 March 2026 (Session 38) with J12 (design decision lifecycle), O17/O19/O20 status updates following Stage 2 Phase 1. Updated 19 March 2026 (Session 39) with O17/O20 status updates following Stage 2 Phase 2 (generator extension). Workflow guide updated with §9 (wikilink enrichment and concept notes). Updated 19 March 2026 (Session 40) with O14/O16/O17/O20 status updates following Stage 2 Phase 4 (Component Catalogue view). Updated 19 March 2026 (Session 41) with O6/O13/O14 status updates following Stage 2 Phase 3 (Suds full BMM coverage). Domain display labels renamed: CSW → Cafe, Suds/Paws labels simplified. Coverage matrix domain filter added. Updated 19 March 2026 (Session 42) with O6 status update, O22 (GovernanceMapping), O23 (governance console view) following Stage 2 Phase 6. Updated 19 March 2026 (Session 43) with O24 (viewpoint/view investigation) following Stage 2 Phase 5. Updated 19 March 2026 (Session 44) with O13 status update following Stage 3 Phase 1 (Paws domain model — 51 elements, 3 packages, all General vocabulary, clean parse). Three-domain cross-domain validation threshold met. Updated 19 March 2026 (Session 45) with O20/O21 status updates following Stage 3 Phase 2 (Glossary view). Three-register comprehension model identified (discussion paper). Demonstrator dual-purpose noted (validation + pedagogy). ~180 individual concepts tracked.*
