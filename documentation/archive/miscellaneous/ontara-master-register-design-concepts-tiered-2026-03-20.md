# Ontara — Master Register of Design Concepts, Principles and Commitments (Tiered)

**Date:** 20 March 2026 (Session 47 — structured project review)
**Restructured from:** `ontara-master-register-design-concepts-2026-03-17.md` (with updates through Session 46)
**Purpose:** Comprehensive, systematically extracted inventory of every design concept, architectural principle, validated pattern, standing commitment, and design decision established across the project. Tiered by influence level to ensure governing principles are visible and checked, structural commitments are honoured when starting workstreams, and future directions are not foreclosed.
**Status:** Living document. Should be updated when new concepts are introduced or existing ones are modified.

---

## Tier Structure

| Tier | Name | Count | When to check | Violation standard |
|---|---|---|---|---|
| **Tier 1** | Governing Principles | 10 | Every session start | Violated only with explicit justification and documentation |
| **Tier 2** | Structural Commitments | ~35 | When starting workstreams or phases | Ignoring produces structurally unsound work |
| **Tier 3** | Design Decisions and Conventions | ~85 | When working in their domain | Revisable within architectural constraints |
| **Tier 4** | Future Directions and Horizon Items | ~30 | Periodic review | Current work must not foreclose |

---

## Tier 1 — Governing Principles (Quick Reference)

These 10 principles govern everything. Check at every session start. Violate only with explicit justification.

| #       | Principle                                  | One-line test                                                                                                                                                                                                                        |
| ------- | ------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **A1**  | Separation of representation and execution | Changes happen in representation and propagate to execution, never the reverse                                                                                                                                                       |
| **A2**  | Self-describing system                     | The system knows what it is, what it is doing, why, and what rules govern it                                                                                                                                                         |
| **A3**  | Model generates everything                 | SysML v2 is the single source of truth for all generated artefacts and canonical structure / function / semantics                                                                                                                    |
| **A4**  | Two meta model distinction                 | Business Meta Model (what a business is) and Business System Meta Model (how a system works) are distinct, connected by explicit mappings                                                                                            |
| **A6**  | Deterministic/auditable reasoning          | Clinical decisions use inspectable, deterministic logic — never probabilistic inference for authoritative decisions                                                                                                                  |
| **A9**  | Discipline as load-bearing structure       | Disciplined practices propagate reliability through the platform to the end user; regression applies to practices, not just code                                                                                                     |
| **A10** | Intrinsic self-knowledge                   | System explanations are dynamically computed from live model state, not stored as static text. Test: if the model changes and no human edits a description, does the explanation become wrong? If yes, the content must be intrinsic |
| **A11** | Unity principle                            | One weighted relationship model informs comprehension, reasoning, simulation, governance, and assembly guidance. No separate, disconnected knowledge structures                                                                      |
| **J2**  | Co-evolution of model and tooling          | No modelling without the tool that makes it legible. No tool without model content that exercises it                                                                                                                                 |
| **J3**  | Non-constraining architecture              | Decisions should not foreclose future development paths. Clean abstractions, loose coupling, discoverable structure                                                                                                                  |

### Tier 1 cross-cutting touchpoints

| Principle | Active touchpoints (current and planned) |
|---|---|
| A1 | All generation pipeline work (E1–E8), console development (I), model development (B), runtime architecture |
| A2 | Comprehension layer (I14, I18), five-layer self-knowledge (F1, D7), manifest (E3), governance traceability (O23) |
| A3 | Every generator (E6), every metadata annotation, comprehension structure (Option 3 decision), glossary (I15), component catalogue (I7), coverage matrix |
| A4 | All BMM work (C1–C6), all BSMM work (B8), doc blocks on every `part def` (N1), horizontal mappings (B12) |
| A6 | Knowledge layer (F1–F7), clinical pathways, Tier 2/3 reasoning stack, constraint evaluation |
| A9 | Workflow guide compliance, session structure, register reviews, concept graph maintenance |
| A10 | Comprehension layer (I14), `@Comprehension` metadata design (I16), Register 2+ (I18), glossary content, component catalogue descriptions |
| A11 | Weighted relationships (B14), comprehension traversal, simulation (L), governance (A8), assembly workspace guidance (I9), reasoning formalisms (M7) |
| J2 | Every stage/phase plan must address both model and tooling. Comprehension architecture deepened this — glossary UX observation → three-register model → intrinsic self-knowledge principle |
| J3 | Weight classification approach (ordinal → hybrid, S46-D2), meta model subsetting (B9), reasoning formalisms (M7), all architectural decisions |

---

## How to use this document

This is a **checklist**, not a narrative. It should be consulted:
- **Every session start:** Review the Tier 1 quick reference above. Identify which Tier 2 items are relevant to the planned work.
- **Before starting any new workstream or phase:** Full review of Tier 1 and Tier 2. Check Tier 4 to ensure the workstream doesn't foreclose future directions.
- **During implementation:** Check relevant Tier 3 items for the domain being worked in.
- **During periodic project reviews (~every 5 sessions):** Full review of all tiers for conceptual drift.
- **When producing session reports and strategic snapshots:** Review Tier 1 and Tier 2 for completeness.

For each item, ask: "Is this concept still active in our thinking? Has this session's work honoured it, contradicted it, or rendered it obsolete?" Any concept that is no longer relevant should be explicitly retired with a rationale, not silently dropped.

### Discussion paper pipeline convention

When a discussion paper introduces concepts that should become binding, the session report explicitly identifies them and the register update adds them at the appropriate tier. Discussion papers remain working documents; their *implications* are traced into the governance structure before the session closes.

---

## A. Foundational Architectural Principles

These are the highest-level commitments. Every other decision should be consistent with them.

| # | Principle | Tier | Source | Summary |
|---|---|---|---|---|
| A1 | Separation of representation and execution | **T1** | Architecture Principles paper | The representation layer (SysML, archetypes, decision logic) is where knowledge lives. The execution layer (Temporal, XState, EHRbase, SvelteKit) is where things happen. Execution consumes representation but does not define it. When anything needs to change, the change happens in representation and propagates to execution via generation or configuration. |
| A2 | Self-describing system | **T1** | Architecture Principles paper; SysML Modelling Strategy §3.1 | The system knows what it is, what it is doing, why it is doing it, and what rules govern it — because all of this is encoded in the model that generates and drives it. Reporting, audit, and governance are first-class system capabilities, not afterthoughts. |
| A3 | Model generates everything | **T1** | Architecture Principles paper | Corollary of A1. SysML v2 is the single source of truth. The model generates executable code, governance documentation, visual diagrams, constraint evaluators, decision table engines, and the system manifest. |
| A4 | Two meta model distinction | **T1** | Service Business Meta Modelling §1; Two Meta Models Clarification | The project maintains two distinct meta models: Business Meta Model (what a service business is — service concept, financial model, resources, activities, governance) and Business System Meta Model (how a business system works — processes, platform, data, knowledge, operations). Connected by explicit mappings. Independently iterable. |
| A5 | Validate in toy domains first | **T2** | PatternCatalogue principle #5; Ontara discussion §5.5 | New concepts should be validated in simple demonstrator domains (Cafe, Suds, Paws) before extension to GSL and health. Concepts need to prove their worth with simple uses first. |
| A6 | Deterministic/auditable reasoning | **T1** | SysML Modelling Strategy §6; Architecture Decision: Knowledge Evaluation | Clinical decisions use inspectable, deterministic logic — not probabilistic inference. The three-tier reasoning stack: Tier 1 (constraints/safety checks), Tier 2 (decision tables/Prolog), Tier 3 (ML/LLM — advisory only, never authoritative). Clinical *decision support* may use Bayesian and other probabilistic methods to assist pathway selection; the clinician retains authority. |
| A7 | Patient autonomy and informed choice | **T2** | Self-Service Enabling Architecture | The platform supports successive generations of patient self-service. The authority model is explicit and versioned. Agency classification on every action. Four-generation roadmap. |
| A8 | Clinical governance as first-class concern | **T2** | Architecture Principles paper; Validated Patterns §5 | Requirements trace to constraints trace to runtime checks trace to audit evidence. Governance is structural, not bolted on. The satisfy traceability chain is the backbone. |
| A9 | Discipline as load-bearing structure | **T1** | Component Catalogue discussion §8; Session 36 | Disciplined working practices, tooling choices, paradigms, and frameworks are load-bearing — like foundations in structural engineering. Discipline in the development process propagates through the platform to the end user: what they build inherits the reliability and transparency of the platform itself, despite complexity. LLM-driven probabilistic mechanisms augment usability but do not replace deterministic foundations for mission-critical applications. Regression applies to practices and discipline, not just code. |
| A10 | Intrinsic self-knowledge | **T1** | Intrinsic Self-Knowledge discussion paper (Session 46); Session 46 report S46-D1 | **New — Session 46.** The system's explanations are dynamically computed from live model state, not stored as static text. Self-knowledge is not painted on or bolted on; it is intrinsic. The dividing-line test: if the model changes and no human edits a description, does the explanation become wrong? If yes, that content must be intrinsic. Purposive descriptions arise because the system is dynamically responsive to its own structure, function, flow, relations and content. Extends and deepens A2. |
| A11 | Unity principle | **T1** | Intrinsic Self-Knowledge discussion paper §4.2 (Session 46); Session 46 report S46-D5 | **New — Session 46.** The same weighted relationship model must inform comprehension, reasoning, simulation, governance, and assembly guidance. One knowledge model, multiple applications. No separate, disconnected knowledge structures. The factors bearing on explanatory descriptions must be the same factors bearing on projections, question-answering, self-knowledge, prediction, risk assessment, simulation, and governance activities. |

---

## B. Structural Architecture Concepts

These define how the system is organised.

| # | Concept | Tier | Source | Summary |
|---|---|---|---|---|
| B1 | Six-layer architecture | **T2** | Ontara discussion §3.1 | Layer 6: meta-meta (SysML v2 language). Layer 5: Business Meta Model. Layer 4: Business System Meta Model. Layer 3: Business model instances. Layer 2: System model instances. Layer 1: Runtime. |
| B2 | Vertical mappings between layers | **T2** | Ontara discussion §3.2; Two Meta Models Clarification §1 | Mappings between layers are first-class, visible, navigable objects. ServiceOffering → pathways, ResourceType → platform components, PersistencePolicy → persistence layer, Pattern → DomainInstantiation, part def → part usages (coverage matrix), requirement → constraint → evaluator → evidence (satisfy chain). |
| B3 | Concentric rings of modelling rigour | **T2** | SysML Modelling Strategy §8.1 | Inner ring: clinical pathways — maximum rigour, full generation. Middle ring: supporting infrastructure — structural clarity, partial generation. Outer ring: business context — architectural documentation. All in the same model. |
| B4 | Package structure (11 top-level) | **T3** | SysML Modelling Strategy §7; Strategic Snapshot §5 | Enterprise, Foundation, Knowledge, ServiceDelivery, Platform, Operations, BusinessModel, BusinessScenarios, BusinessStrategy, PatternCatalogue, GenderSense root. 73 packages total. |
| B5 | ClinicalEntities separation | **T3** | SysML Modelling Strategy §8.2 | Domain entities (Patient, Episode, Consultation, Prescription, Referral, LabResult) are separated from pathways. Entities are the nouns, pathways are the verbs. Each entity has a lifecycle state machine defined once and referenced by all pathways. |
| B6 | ServiceDelivery/Platform split | **T2** | SysML Modelling Strategy §8.3 | Mirrors the two-layer action flow pattern. ServiceDelivery is the domain layer (clinical processes). Platform is the orchestration/infrastructure layer (how the system implements them). |
| B7 | Foundation as shared vocabulary | **T3** | SysML Modelling Strategy §8.6 | MetadataLibrary, CommonTypes, StatePatterns, GenerationPipeline. Cross-cutting infrastructure imported by everything else. |
| B8 | Business System Meta Model — currently implicit | **T3** | Two Meta Models Clarification §2 | The BSMM concepts (PersistencePolicy, AgencyClassification, GoalProjection, Deficit, etc.) are distributed across Foundation, Knowledge, ServiceDelivery, Platform, Operations, PatternCatalogue. A future workstream will promote them into a named, navigable structure. |
| B9 | Meta model subsetting / templating | **T4** | Ontara discussion §3.3 | A specific business instantiates only a subset of the full meta model vocabulary. Open design question: constrained subset meta models vs template/profiling approach (openEHR-style). To be resolved empirically. |
| B10 | Two-layer concept graph architecture | **T2** | Knowledge Graph Architecture §3 | SysML as formal source of truth for patterns, principles, relationships. Obsidian as navigation and discursive layer. Generators between them. No maintained YAML — SysML is the single source. |
| B11 | General / Tailored meta model decomposition | **T2** | Component Catalogue discussion §2.3 | Within each meta model (BMM and BSMM), components are classified as General (common to most service businesses, sector-agnostic) or Tailored (sector-specific, extending or specialising general components). Both tiers exist on both business and system sides. |
| B12 | Horizontal mappings at every tier | **T2** | Component Catalogue discussion §7.2 | Mappings between business and system sides are explicit at every level: General BMM ↔ General BSMM, Tailored BMM ↔ Tailored BSMM, Individual business models ↔ Individual system models. Extends B2 (vertical mappings) to the full matrix. |
| B13 | Services / Goods scope boundary | **T3** | Component Catalogue discussion §2.2 | Both Business and System meta models acknowledge a Services / Goods split. Current scope is Services. The architecture does not foreclose extension to goods-oriented businesses. |
| B14 | Weighted relationships | **T2** | Intrinsic Self-Knowledge discussion paper §4 (Session 46); Session 46 report S46-D2 | **New — Session 46.** Relationships between elements and concepts are characterised by strength of interaction effect. Starting with ordinal classification (strong/moderate/weak), designing for hybrid (structural baseline + human overrides), following J12. The weight model supports three interpretive frames: costs/preferences, fuzzy human judgements, and probabilities (the latter for clinical decision support). Connected to A11 (unity principle) — the same weights inform all subsystems. Research into semiring soft-constraints, fuzzy MCDM, and Probabilistic Soft Logic identified relevant formalisms (see M7). |

---

## C. Five Concerns of a Service Business

From Service Business Meta Modelling §2.1. Cross-cutting: Activity Awareness.

| # | Concern | Tier | Summary |
|---|---|---|---|
| C1 | Service Concept | **T2** | What value is delivered, to whom, and why it is worth paying for. Value proposition, customer segments, differentiation, channels. |
| C2 | Service Delivery System | **T2** | How value is produced and delivered. Processes, pathways, workflows, entity lifecycles, outcomes, handoff points. |
| C3 | Resource and Capability Model | **T2** | What resources and capabilities are required. People, estate, equipment, technology, licences. Capabilities are organised combinations of resources. |
| C4 | Financial Model | **T2** | How money flows. Revenue streams, cost drivers, unit economics, pricing models, financial projections. |
| C5 | Governance and Adaptation | **T2** | Regulatory requirements, governance processes, risk, learning mechanisms, strategic objectives. |
| C6 | Activity Awareness (cross-cutting) | **T2** | Every unit of activity is visible. Five categories: service delivery, service-enabling, governance, development, overhead. Progressive elaboration: envelope → category → tracked. The common currency connecting all five concerns. |

---

## D. Validated Architectural Patterns (22 + 6 deferred)

From Validated Architectural Patterns document and PatternCatalogue (22 patterns, 8 principles, 43 typed relationships).

### Business Meta Model patterns (4)

| # | Pattern | Tier | Status | Cafe | GSL |
|---|---|---|---|---|---|
| D1 | Four-layer item model | **T3** | validated | ✓ | discussion |
| D2 | Activity taxonomy | **T3** | validated | ✓ | ✓ |
| D3 | Scenario comparison and projection | **T3** | validated | — | ✓ |
| D4 | Persistence policy as queryable reasoning | **T3** | validated | ✓ | — |

### Business System Meta Model patterns (16)

| # | Pattern | Tier | Status | Cafe | GSL |
|---|---|---|---|---|---|
| D5 | SysML v2 as single source of truth | **T2** | validated | ✓ | ✓ |
| D6 | Two-layer pathway modelling | **T2** | validated | ✓ | ✓ |
| D7 | Five-layer self-knowledge | **T2** | validated | — | ✓ |
| D8 | Three-persistence-layer architecture | **T3** | validated | ✓ | designed |
| D9 | Metadata-driven generation | **T2** | validated | ✓ | ✓ |
| D10 | XState in Temporal | **T3** | validated | ✓ | — |
| D11 | Catalogue-as-UI-contract | **T3** | validated | ✓ | — |
| D12 | Kanban-as-process-dashboard | **T3** | validated | ✓ | — |
| D13 | Split-view management layout | **T3** | validated | ✓ | — |
| D14 | Category-conditional form fields | **T3** | validated | ✓ | — |
| D15 | Cross-page data consistency | **T3** | validated | ✓ | — |
| D16 | Audit-as-timeline data source | **T3** | validated | ✓ | — |
| D17 | Process + domain + governance unified view | **T3** | validated | ✓ | — |
| D18 | CDR source provenance badges | **T3** | validated | ✓ | — |
| D19 | Auto-loading entity views | **T3** | validated | ✓ | — |
| D20 | Infrastructure health as app concern | **T3** | validated | ✓ | — |

### Cross-cutting (1)

| # | Pattern | Tier | Status |
|---|---|---|---|
| D21 | Coffee shop demonstrator as standing practice | **T3** | validated |

### Deferred / conceptual (6)

| # | Pattern | Tier | Status |
|---|---|---|---|
| D22 | Composite order / multi-workflow orchestration | **T4** | discussion |
| D23 | Agency classification on actions | **T4** | designed |
| D24 | Self-assessment dashboard (KL Increment 3) | **T4** | designed |
| D25 | OptionEvaluator / Help Me Choose | **T4** | designed |
| D26 | Data release model (patient-facing) | **T4** | discussion |
| D27 | Notification triggers on transitions | **T4** | discussion |

---

## E. Generation Pipeline Concepts

| # | Concept | Tier | Source | Summary |
|---|---|---|---|---|
| E1 | Two-phase generation pipeline | **T2** | Two-Phase Generation Pipeline discussion | Phase 1: domain generators (model-aware, framework-agnostic) produce domain artefacts + manifest. Phase 2: integration generators (model-agnostic, framework-aware) produce wiring code from the manifest. |
| E2 | Four-layer generated code architecture | **T2** | Two-Phase Generation Pipeline §5.1 | Layer 1: SysML model. Layer 2: domain artefacts (generated, never hand-edited). Layer 3: integration glue (generated, never hand-edited). Layer 4: application code (hand-written, imports from L2/L3, never overwritten by generators). |
| E3 | Manifest as architectural asset | **T2** | Two-Phase Generation Pipeline §5.3; Architecture Decision: Knowledge Evaluation §2 | The generation manifest is the queryable record of what the system contains, what was generated from what, and how things connect. Extends the system manifest with provenance. Foundation for self-knowledge. |
| E4 | Regeneration safety | **T3** | Two-Phase Generation Pipeline §5.2 | Generated layers (2 and 3) are freely regenerable. Application code (layer 4) is never touched. The four-layer separation enforces this. |
| E5 | Generatability spectrum | **T3** | Two-Phase Generation Pipeline §4 | High value (generate fully): types, enums, state machines, schema DDL, barrel exports. Medium value (generate skeleton, hand-finish): workflow stubs, composition builders, API route handlers. Low value (don't generate): UI design, clinical decision content, error messages, tests. |
| E6 | Nine operational generators | **T3** | Strategic Snapshot §2; Validated Patterns §9 | 4 demonstrator: types, state machines, temporal workflows, mermaid. 5 model-level: package hierarchy, constraint evaluators, decision table evaluators, system manifest, concept graph. |
| E7 | Generators fail loudly, degrade gracefully | **T3** | Validated Patterns §9 | Unparseable expressions emit TODO placeholders, never broken output. |
| E8 | Regex parsers as executable specifications | **T3** | Validated Patterns §9; Two-Phase Generation Pipeline §6 | Current text-based parsers are adequate but fragile. They serve as executable specifications for future Syside Automator migration: same input → same output. |

---

## F. Knowledge Layer and Self-Knowledge Concepts

| # | Concept | Tier | Source | Summary |
|---|---|---|---|---|
| F1 | Five-layer SystemStateAssessment | **T2** | Architecture Decision: Knowledge Evaluation §2–6 | Layer 1 (structural): system manifest. Layer 2 (operational): query Temporal, CDR, platform. Layer 3 (goal-state): project from requirements, constraints, outcomes. Layer 4 (gap analysis): compare L2 vs L3, produce Deficits. Layer 5 (remediation): classify as automatic, recommended, or advisory. |
| F2 | Evaluation invocation pattern | **T3** | Architecture Decision: Knowledge Evaluation §1 | Pathway step → metadata annotation → generated activity → evaluation engine → resolve inputs → evaluate constraint → structured EvaluationResult → audit record. Same engine for point-of-care and population governance. |
| F3 | Evaluation spec pattern (:>> redefinition) | **T3** | Validated Patterns §6 | General template (part def) with concrete instances (part usages) that redefine attributes. Separates "what the rule is" (ConstraintLibrary) from "how to evaluate it" (CDS evaluation specs). |
| F4 | Three remediation categories | **T3** | Architecture Decision: Knowledge Evaluation §5 | Automatic (system acts), Recommended (human required), Advisory (systemic/compound). Default for any new deficit is Recommended — system never takes automatic clinical action unless model explicitly permits it. |
| F5 | Operational steering as self-knowledge extension | **T2** | Service Business Meta Modelling §4.7 | The forecast-actuals-rebaseline cycle is structurally parallel to clinical self-knowledge. GoalProjector → ProjectionFormulas. OperationalStateAggregator → financial actuals. GapAnalyser → VarianceAnalysis. Deficit → Variance. Same machinery, different domain. |
| F6 | Tau Prolog for Tier 2 reasoning | **T3** | Validated Patterns §11 | Compound deficit reasoning, "why not" explanation, inference chains. 16/16 tests, <4ms/query. Adoption conditional on complexity growth. |
| F7 | Three assessment invocation patterns | **T3** | Architecture Decision: Knowledge Evaluation §6 | On-demand (API), Scheduled (Temporal cron), Triggered (critical deficit cascades to broader assessment). |

---

## G. CDR and Clinical Data Concepts

| # | Concept | Tier | Source | Summary |
|---|---|---|---|---|
| G1 | openEHR as clinical data architecture | **T3** | Architecture Principles paper | EHRbase CDR, archetype-based modelling, AQL queries, SNOMED CT terminology binding. |
| G2 | Two data paths, one CDR | **T3** | CDR Exercise summary; Validated Patterns §10 | Workflow-driven (Temporal activities commit compositions) and form-driven (SvelteKit endpoints commit directly). Same structured, queryable data. |
| G3 | Two views onto the same data | **T3** | Architecture Principles paper; CDR Exercise | Process view (Temporal workflow state) and entity view (AQL queries by archetype type). Complementary, no duplication. |
| G4 | Application-level join for governance | **T3** | Validated Patterns §10 | Two AQL queries joined in TypeScript by EHR ID. Necessary because EHRbase 2.11.0 doesn't support complex AQL. |
| G5 | Composition builder per template | **T3** | Validated Patterns §10 | Dedicated builder function per archetype template. Hand-maintained for CSW; should be generated for clinical archetypes. |
| G6 | SysML-to-openEHR traceability via metadata | **T3** | Validated Patterns §4 | @OpenEhrArchetype and @OpenEhrTemplate on part defs. Machine-queryable traceability. Per-element mapping via inline comments (//at0NNN | DV_TYPE). |

---

## H. Self-Service and Patient Autonomy Concepts

| # | Concept | Tier | Source | Summary |
|---|---|---|---|---|
| H1 | Enabling architecture, not fixed model | **T2** | Self-Service Enabling Architecture §1 | The platform supports successive generations of self-service. Cannot be fixed today because clinical liability landscape is shifting, regulation constrains delegation, population is heterogeneous, governance framework must evolve. |
| H2 | Agency classification | **T3** | Self-Service Enabling Architecture §7 | Every action classified by who performs it: system, clinician, patient, shared. Model-level metadata, not code-level configuration. |
| H3 | Four-generation self-service roadmap | **T4** | Self-Service Enabling Architecture | Gen 1: transparent information. Gen 2: guided self-navigation. Gen 3: supervised autonomy. Gen 4: full autonomy with oversight. Each generation introduces new governance requirements. |
| H4 | CoPHR heritage principles | **T3** | Self-Service Enabling Architecture §2 | Patient control of access. Irrevocable access to relied-upon data. Mandatory provenance and audit. Medico-legal validity. Data portability. Separation of record from application. |
| H5 | Clinical authority problem | **T2** | Self-Service Enabling Architecture §3 | Clinician authority preserved where required. System role transparent. Authority model explicit and versioned. Nothing assumed about future liability model. |
| H6 | Harm reduction principles | **T3** | Self-Service Enabling Architecture §3.4 | Meet patients where they are. Record without judgment. System accommodates patients arriving mid-stream with self-administered medication. |

---

## I. Ontara Platform and Console Concepts

| # | Concept | Tier | Source | Summary |
|---|---|---|---|---|
| I1 | Platform characteristics | **T2** | Ontara discussion §1.1; Platforms research | Modular architecture, standardised interfaces, abstraction/generality, lifecycle support, evolutionary stability, ecosystem enablement, composability, extensibility, integrated tooling. |
| I2 | Dual canvas (business + system) | **T2** | Ontara discussion §4.2 | Business canvas: compose business models from Layer 5 pieces. System canvas: map technology components from Layer 4. Linked by vertical traceability. |
| I3 | Meta models as palette grammar | **T2** | Ontara discussion §4.4 | Business Meta Model defines business palette. Business System Meta Model defines system palette. PatternCatalogue as recommendation engine. |
| I4 | Three levels of completeness tracking | **T3** | Ontara discussion §4.5 | Level 1: instance coverage (which domains instantiate which defs). Level 2: pattern coverage (which domains exercise which patterns). Level 3: meta model adequacy (vocabulary gaps). |
| I5 | Console vs generated domain applications | **T2** | Ontara discussion §4.7 | Console is platform development tool (model-aware, architect-facing). Domain application is generated and operator-facing. Different things, shared technology. |
| I6 | Filtered views and field of view control | **T3** | Ontara discussion §4.6 | By layer, domain, concern, cross-domain comparison, gap analysis, pattern coverage. |
| I7 | Component Catalogue | **T3** | Component Catalogue discussion §3.1 | A browsable, filterable catalogue of individual meta model components (both General and Tailored, both BMM and BSMM). Components are tagged SysML `part def`s with metadata annotations. The catalogue is a view over the SysML model, not a separate data structure. Consistent with A3 and D9. |
| I8 | Model Catalogue | **T4** | Component Catalogue discussion §3.2 | A catalogue of complete or near-complete assembled model configurations — pre-validated starting points. A model catalogue entry is a curated assembly of component catalogue entries, validated as complete and coherent. Users can start from a model catalogue entry and customise, or build from scratch. |
| I9 | Assembly workspace (drag-and-drop) | **T4** | Component Catalogue discussion §4 | A core console interaction where users assemble models by dragging components from the Component Catalogue onto the dual canvas. Real-time completeness feedback. Mappings between business and system sides shown live. |
| I10 | Tagging system for catalogue filtering | **T3** | Component Catalogue discussion §6 | Components are tagged across multiple dimensions (e.g. Regulation, Sector, Delivery Mode). Tags are SysML metadata annotations. Dimensions can be exclusive or inclusive. Tag dimensions and values supplied by Ontara; user-generated tags are a future nice-to-have. |
| I11 | Model validation — progressive status | **T3** | Component Catalogue discussion §5 | Assembled models are validated at three levels: structural completeness (required components present), internal consistency (components fit together), runnability (can drive execution layer). Console surfaces this as a progressive status: Incomplete → Complete but unchecked → Validated → Runnable. |
| I12 | Console as architect's own tool | **T2** | Component Catalogue discussion §8.2 | The console is built for Ella as first user. It should closely reflect and support her cognitive style: top-down delimitation, rigorous abstraction, filtered views controlling field of view and subject of concern, building generalisable models from specific instances. Development driven by actual needs, not abstract specifications. |
| I13 | Externally validated / endorsed model configurations | **T4** | Component Catalogue discussion §3.2.1 | Model Catalogue entries can carry external validation or endorsement against named regulatory or industry standards. Future development. |
| I14 | Comprehension layer | **T2** | High-Level Plan; Session 37; Comprehension Architecture discussion (Session 45); Intrinsic Self-Knowledge discussion (Session 46) | A distinct architectural concern: making the model *comprehensible* to its users, not just structurally navigable. Three registers identified (Session 45): Register 1 (static authored labels), Register 2 (generated explanations from model structure), Register 3 (conversational self-knowledge — connects to C6). Session 46 deepened this with the intrinsic self-knowledge principle (A10), Option 3 (comprehension structure modelled in SysML), and the unity principle (A11). |
| I14a | User-facing metadata on SysML elements | **T3** | High-Level Plan; Session 37 | SysML metadata annotation (`@UserFacing` in Foundation::MetadataLibrary) providing a `friendlyName` and `shortDescription` for any element. Generated into JSON by the introspection generator, consumed by the console. |
| I15 | Glossary of terms in the console UI | **T3** | Session 37 | A navigable, searchable dictionary of terms used in the system. Generated from `@UserFacing` metadata. Built in Session 45 (Stage 3 Phase 2). |
| I16 | Comprehension traversal schema | **T3** | Intrinsic Self-Knowledge discussion paper §2.3 (Session 46) | **New — Session 46.** `@Comprehension` metadata declares *how to construct* an explanation for each element, not *what it says*. A recipe for traversing relationships, surfacing structural features, and selecting domain instances as illustrations. The metadata is a traversal schema, not a content template. Consistent with A10 (intrinsic self-knowledge). |
| I17 | Authored/intrinsic content distinction | **T3** | Intrinsic Self-Knowledge discussion paper §2.2 (Session 46) | **New — Session 46.** Clear dividing line for what goes in `@UserFacing` (authored purposive framing — "why should I care?") vs `@Comprehension` (traversal instructions for dynamically generated structural self-knowledge). The A10 test determines which category content belongs to. |
| I18 | Inferential comprehension (Register 2+) | **T2** | Intrinsic Self-Knowledge discussion paper §3 (Session 46); Comprehension Architecture discussion (Session 45) | **New — Sessions 45–46.** The comprehension layer reasons about *implications*, not just structure. "If you have defined this and that, then this follows." Connects to C6 (five-layer self-knowledge), F1 (SystemStateAssessment), and the logic engine (F6). Uses the same weighted relationship model (B14) via A11 (unity principle). |

---

## J. Development Methodology and Process Concepts

| # | Concept | Tier | Source | Summary |
|---|---|---|---|---|
| J1 | Cross-domain validation | **T2** | Ontara discussion §6.1 | Every concept/pattern should validate in at least two domains. Cafe/Suds/Paws, with GSL as eventual production target. |
| J2 | Co-evolution of model and tooling | **T1** | Ontara discussion §6.2 | No modelling without the tool that makes it legible. No tool without model content that exercises it. |
| J3 | Non-constraining architecture | **T1** | Ontara discussion §6.3; Architecture Principles paper | Decisions should not foreclose future development paths. Clean abstractions, loose coupling, discoverable structure. |
| J4 | Model should earn its keep | **T3** | SysML Modelling Strategy §8.6 | If modelling something merely restates the obvious, stop. The model generates something or makes a non-obvious relationship visible. |
| J5 | Periodic project reviews | **T3** | Two Meta Models Clarification §4.5; Standing concern | Check for conceptual drift, factual inaccuracies, fuzzy equivalences in generated documents. Catch errors before they forward-propagate. |
| J6 | Standing concern: LLM prose smuggling fuzzy equivalences | **T3** | Multiple sessions | LLM-generated prose can introduce subtle conceptual inaccuracies that look plausible. Periodic reviews are the countermeasure. Part def (meta model) vs part usage (instance) is a critical distinction. |
| J7 | Working documents in Obsidian, commits to repo | **T3** | Ontara discussion §10; Workflow Guide §3 | Working documents created/edited in Obsidian vault. Committed to repo under documentation/archive/ when settled. Repo is a curated versioned record. |
| J8 | Governance requirements for toy domains | **T3** | Ontara discussion §5.6 | Suds and Paws each include domain-appropriate governance requirements to exercise the satisfy traceability chain in non-health contexts. |
| J9 | Session reports and strategic snapshots | **T3** | Standing practice | Session reports at session end. Strategic snapshots at workstream boundaries. Both are reviewed for accuracy before being treated as reference. |
| J10 | Retrospective bootstrapping | **T2** | Component Catalogue discussion §8; Session 36 | After each development step, ask: "how could our own tooling or processes have made that easier?" If there is a good answer with an achievable solution, implement it as part of ongoing work. Operationalises J2 (co-evolution) with a retrospective improvement loop. Influenced by DHH's Rails philosophy: extract the framework from the application you are actually building. |
| J11 | Bottom-up discovery meets top-down framing | **T2** | Component Catalogue discussion §8.6; Session 36 | The development approach intelligently combines bottom-up and top-down thinking. Bottom-up exploration generates insight and reveals structure. Top-down framing captures and protects that insight. Neither mode dominates. The CSW demonstrator exemplifies this: patterns were discovered bottom-up through practical work, then organised top-down into the architecture and register. The Session 47 project review is the top-down framing catching up with what bottom-up development has revealed. |
| J12 | Design decision lifecycle | **T2** | Element Grouping discussion §9.2; Session 38 | Design decisions follow a lifecycle: freedom → experimentation → discovered convention → opinionated configuration → (revisable). Early-stage development deliberately preserves freedom (J3) rather than locking in structure prematurely. Through experimentation and use, conventions are discovered empirically (J11). Non-constraining at the beginning does not mean uncommitted forever, and committed does not mean irreversible. |

---

## K. Semantic Relationship Vocabulary

From Knowledge Graph Architecture §4. Ten typed predicates modelled as `ref` fields on Pattern.

| Predicate | Tier | Meaning | Inverse |
|---|---|---|---|
| dependsOn | **T3** | X requires Y | enables |
| enables | **T3** | X makes Y possible | dependsOn |
| motivatedBy | **T3** | X fulfils principle Y | motivates |
| generalises | **T3** | X is more abstract than Y | specialises |
| constrains | **T3** | X limits or governs Y | constrainedBy |
| extends | **T3** | X adds capability on top of Y | extendedBy |
| validatedBy | **T3** | X is proven by Y | validates |
| composedWith | **T3** | X and Y are used together | composedWith |
| analogueTo | **T3** | X in domain A ≡ Y in domain B | analogueTo |

---

## L. Simulation Concepts

From Service Business Meta Modelling §9.

| # | Concept | Tier | Summary |
|---|---|---|---|
| L1 | Simulation data generation | **T4** | Patient generation (configurable arrival, segments, profiles). Event generation (lab results, cancellations, GP responses with realistic timing). Environmental starter sets (initial state for simulation runs). |
| L2 | Workflow execution under simulation | **T4** | Automated signal resolution. Decision point agents (simple rule-based to sophisticated variation). Resource contention (finite resources, queuing, wait times). |
| L3 | Temporal control | **T4** | Time compression. Start/stop/pause/save/delete. Variable time intervals. Checkpointing and branching. |
| L4 | Simulation purposes | **T4** | Learning/intuition-building. Stress-testing. Demonstration. Training. Evaluation of business model variants. |

---

## M. Horizon Items

Captured from various discussions. Not committed workstreams — future possibilities.

| # | Item | Tier | Source | Summary |
|---|---|---|---|---|
| M1 | Hookmark cross-desktop linking | **T4** | Knowledge Graph Architecture §1.1 | Bidirectional links between Obsidian, VS Code, Finder, Mail. Spike planned. |
| M2 | Tom Sawyer SysML v2 Viewer | **T4** | Knowledge Graph Architecture §7.1 | Standalone web viewer for stakeholder-facing graphical model views. Requires SysML v2 API-compliant repository. |
| M3 | Syside Automator for generation | **T4** | SysML Modelling Strategy §9.2.3; Validated Patterns §9 | Semantic model access replacing regex parsers. Targeted for when Automator API stabilises. |
| M4 | Form generation from model | **T4** | SysML Modelling Strategy §9.3.2 | Clinical form definitions generated from SysML. Major surface area for data capture. |
| M5 | Prolog rule generation | **T4** | Validated Patterns §11 | constraint def → Tau Prolog rules. Contingent on Tier 2 adoption. |
| M6 | Population-level governance | **T4** | SysML Modelling Strategy §9.3.3 | Scheduled Temporal workflows querying CDR, evaluating rules, producing cohort governance reports. |
| M7 | Reasoning formalisms research | **T4** | Intrinsic Self-Knowledge discussion paper §4.4 (Session 46); Ella's Perplexity research | **New — Session 46.** Three formalisms identified as relevant to Ontara's weighted reasoning needs: semiring soft-constraints (optimisation/trade-offs), fuzzy MCDM (human judgements/stakeholder preferences), Probabilistic Soft Logic (graded business rules with truth values in [0,1]). Clinical decision support may additionally use Bayesian reasoning. These inform the design of B14 (weighted relationships) when the time comes. |

---

## N. Standing Conventions and Guard Rails

| # | Convention | Tier | Source |
|---|---|---|---|
| N1 | Every new `part def` or `metadata def` carries a doc block identifying its meta model ("business meta model concept" or "business system meta model concept"). | **T3** | Two Meta Models Clarification §4.1 |
| N2 | Documents use explicit vocabulary: "the business meta model" or "the system meta model", never "the GSL meta model". | **T3** | Two Meta Models Clarification §4.2 |
| N3 | The service business meta modelling paper is the authoritative source for BMM structure. Contradictions in other documents should be corrected. | **T3** | Two Meta Models Clarification §4.3 |
| N4 | Periodic project reviews check for conceptual drift. | **T3** | Two Meta Models Clarification §4.5 |
| N5 | Generated files carry `DO NOT EDIT` headers with timestamp and source reference. | **T3** | Validated Patterns §9 |
| N6 | Generators fail loudly and degrade gracefully — unparseable expressions emit TODO placeholders, never broken output. | **T3** | Validated Patterns §9 |
| N7 | Standing concern: LLM-generated prose can smuggle fuzzy conceptual equivalences. Periodic reviews are the countermeasure. Part def (meta model) vs part usage (instance) is a critical distinction. | **T3** | Standing rule |
| N8 | `part def` (meta model) vs `part` (instance) is a critical distinction. Conceptual precision required. | **T3** | Standing rule |
| N9 | Paths containing `&` work in MCP but require escaping in bash. `~` prefix causes path failures — use full paths. | **T3** | Standing rule |
| N10 | SysML syntax reference file should be checked before writing new `.sysml` code. Syside syntax differs from spec in several ways. | **T3** | Standing rule |
| N11 | Working documents in Obsidian vault. Committed to repo under `documentation/archive/` when settled. Repo is a curated versioned record. | **T3** | Workflow Guide §3 |

---

## O. Identified Gaps and Future Work

Concepts that are designed but not yet implemented or exercised. All Tier 4 — these track what remains to be done.

| # | Gap | Tier | Relevant concepts |
|---|---|---|---|
| O1 | Knowledge Layer Increments 1–3 (constraint evaluation, decision tables, self-assessment) not yet exercised at runtime. | **T4** | F1, F2, F3, F4 |
| O2 | Business System Meta Model not yet extracted into named package. | **T4** | A4, B8 |
| O3 | No second clinical pathway. Architecture claims to generalise but only one pathway exists. | **T4** | D6, D9, A5 |
| O4 | Composite order / multi-workflow orchestration not implemented. | **T4** | D22 |
| O5 | HandoffPoint not modelled as first-class concept. | **T4** | Service Business Meta Modelling §3.2 |
| O6 | Two BMM part defs completely uninstantiated (ActivityBudget, ActivityRecord). ActivityCostAllocation now has 2 Suds instances (Session 41). InventoryRecord still uninstantiated but now joined by AuditEvidenceRecord with 4 Suds instances (Session 42, Phase 6). ExternalReference has Cafe + Suds instances. | **T4** | C1 |
| O7 | Twelve BSMM part defs completely uninstantiated (GapAnalyser, ConstraintEvaluator, AssessmentOrchestrator, etc.). | **T4** | B8, F1 |
| O8 | Two-phase generation pipeline designed but not implemented. | **T4** | E1, E2 |
| O9 | Simulation capability conceptualised but not designed in detail. | **T4** | L1–L4 |
| O10 | Hookmark cross-desktop linking — spike planned but not executed. | **T4** | M1 |
| O11 | Tom Sawyer SysML v2 Viewer — horizon item. | **T4** | M2 |
| O12 | Clinical archetypes not yet designed for GSL production use. CDR integration validated with CSW patterns only. | **T4** | G1–G6 |
| O13 | Suds and Paws domains created. Suds initial business model created Session 37. Suds expanded to full BMM coverage Session 41. Paws created Session 44 (51 elements, 3 packages, all General vocabulary). Three-domain cross-domain validation threshold (J1) now met for BMM vocabulary. Service subject ≠ customer observation captured. | **T4** | I5, J1 |
| O14 | Ontara Console — Stage 1 complete (Session 37). Component Catalogue built (Session 40). Coverage matrix domain filter added (Session 41). Assembly workspace, dual canvas, and pattern graph remain Stage 3 work. | **T4** | I2, I4, I6, I7, I12 |
| O15 | Meta model subsetting / templating mechanism not resolved. | **T4** | B9 |
| O16 | Component Catalogue built (Session 40). Model Catalogue not yet built. Console assembly workspace not yet implemented. | **T4** | I7, I8, I9 |
| O17 | Tagging system implemented end-to-end. `@CatalogueTag` metadata def defined (Session 38), applied to 24 BMM `part def`s, generator extracts facet summaries (Session 39), Component Catalogue view consumes facet data (Session 40). Four grouping axes. New facet dimensions added to the model will appear automatically in the catalogue. | **T4** | I10, B11 |
| O18 | SysML mechanism for Model Catalogue entries not yet determined. | **T4** | I8 |
| O19 | Component granularity resolved Session 38: atomic unit is an element (typically `part def`); grouping is a presentation/viewpoint concern. | **T4** | I7 |
| O20 | Comprehension layer partially implemented. `@UserFacing` metadata def defined (Session 38), applied to 12 BMM `part def`s (46.2% coverage). Glossary view built (Session 45). Session 45 discussion paper identified three registers. Session 46 identified intrinsic self-knowledge principle, unity principle, Option 3 (comprehension structure in SysML), and weighted relationships. 26 draft purposive descriptions produced (Session 46) awaiting application. Remaining `@UserFacing` coverage expansion is Phase 3. | **T4** | I14, I14a, D9 |
| O21 | Glossary built (Session 45). Currently 12 entries. Coverage stat: "12 of 26 catalogue elements have glossary entries (46.2%)". | **T4** | I15 |
| O22 | GovernanceMapping sub-package added to BMM (Session 42). Two General definitions: GovernanceRequirement and AuditEvidenceRecord. First BMM requirement def. | **T4** | A8, J8, B2 |
| O23 | Governance traceability view added to console (Session 42). Traceability chain visualisation, evidence records table, constraint definitions section. | **T4** | J2, A8, I12 |
| O24 | SysML v2 viewpoint/view investigation complete (Session 43). Recommendation: adopt partially in Stage 3. | **T4** | A3, J3, J12 |

---

## Register History

*Master register compiled 17 March 2026 from systematic review of all documents in `02 ARCHITECTURE & MODELLING`. Updated through Sessions 36–46. Tiered restructure performed 20 March 2026 (Session 47 — structured project review). New concepts A10, A11, B14, I16, I17, I18, M7 added from Sessions 45–46. Cross-cutting concern touchpoints added for Tier 1 principles. Discussion paper pipeline convention formalised. ~160 individual concepts tracked across 4 tiers.*
