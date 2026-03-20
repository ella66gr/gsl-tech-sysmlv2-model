# Ontara — Vision and Architecture Reference

**Date:** 17 March 2026 (Session 35). Extracted 19 March 2026 (Session 45).
**Origin:** Extracted from [[ontara-discussion-vision-concepts-principles-2026-03-17|Ontara Vision, Concepts and Principles Discussion]] — the original exploratory session that named the platform, established the layered architecture, and defined the console vision.
**Status:** Standing reference document. The authoritative summary of what Ontara is, how it is layered, and what the console vision is.

---

## 1. What Ontara Is

**Ontara** is the name for the entire system. The name evokes *ontology* and a sense of *being* and *essence*, along with a feminine intuition of *awareness of self*. Ontara is a **service system development and delivery platform**, particularly strong in supporting regulated care service delivery. It encompasses all layers: meta models, business models, system models, the execution platform, the generation pipeline, and the developer/architect tooling.

Ontara is not the name for one component. It is the name for the whole.

### 1.1 Platform characteristics

Ontara meets the technical definition of a *platform* as distinct from a product or framework:

- **Modular architecture.** Clear separation into components with low coupling and high cohesion. Embodied in the package structure, the two-meta-model distinction, and the separation of representation from execution.
- **Standardised interfaces.** Stable, documented APIs, events, and contracts. The SysML model defines interface contracts; metadata annotations drive generation.
- **Abstraction and generality.** Components expose capabilities at a domain-oriented rather than use-case-specific level. The meta models are the primary abstraction mechanism.
- **Lifecycle support.** The platform provides the environment to build, deploy, run, observe, and evolve services. The self-knowledge architecture, forecast-actuals-rebaseline cycle, and simulation capability all contribute.
- **Evolutionary stability.** Backward compatibility, versioning, and deprecation policies. The ForecastBaseline versioning pattern, PatternCatalogue maturity tracking, and non-constraining architecture principle serve this.
- **Ecosystem enablement.** Designed for others to build on. The dual-canvas construction kit, meta-model-defined palettes, and cross-domain validation principle are all oriented towards enabling others to model and operate their own service businesses.
- **Composability.** Users assemble higher-level services by combining platform capabilities rather than requesting bespoke features.
- **Extensibility mechanisms.** Meta model subsetting/templating, and the PatternCatalogue vocabulary for registering and sharing new patterns.
- **Integrated tooling.** The [[ontara-vision-architecture-reference|Ontara Console]] is the primary tooling surface.

The pragmatic test: if Ella stopped building end-user features, would other teams still find Ontara valuable as a base to build their own service businesses?

### 1.2 Relationship to GenderSense

GenderSense Limited (GSL) is a specific business — a private gender-affirming healthcare service. GSL is an *instance* of a service business modelled and operated on Ontara. The platform's architecture is designed to support any service business.

---

## 2. The Six-Layer Architecture

### 2.1 The layers

| Layer | Name | Content |
|---|---|---|
| 6 | Meta-meta level | SysML v2 itself: `part def`, `attribute`, `ref`, `enum def`, `constraint def`, etc. Provided by the language and Syside Modeler. |
| 5 | Business Meta Model | The structural template for what a service business *is*. ServiceConcept, ActivityModel, ResourcePlanning, FinancialPlanning, GovernanceMapping, BusinessScenarios, BusinessStrategy. |
| 4 | Business System Meta Model | The structural template for how a business system *works*. Currently distributed across Foundation, Knowledge, ServiceDelivery, Platform, Operations, PatternCatalogue. |
| 3 | Business model instances | A specific service business described using Layer 5 concepts. GSL, Cafe, Suds, Paws. `part` usages instantiating `part def` types. |
| 2 | System model instances | The concrete implementation described using Layer 4 concepts. Frontends, workflows, schemas, persistence policies, generation pipeline outputs. |
| 1 | Runtime | The running system, its state, its data. Not modelled in SysML — the execution environment that the model generates and governs. |

### 2.2 Vertical mappings between layers

Mappings between layers are first-class, visible, navigable objects:

- `ServiceOffering` (L3) → clinical pathways or process models (L2)
- `ResourceType` (L3) → platform components (L2)
- `PersistencePolicy` (L2) → domain concept and persistence layer
- `Pattern` (L4) → `DomainInstantiation` records (L3/L2) — 43 typed `ref` relationships
- `part def` (L5/L4) → `part` usages (L3/L2) — the coverage matrix
- `requirement def` (L4) → `constraint def` (L4) → evaluation spec (L2) → generated evaluator (L1) — the satisfy traceability chain

### 2.3 Meta model subsetting and templating

A meta model defines the *full vocabulary*. A specific business instantiates only a subset. This is not a gap — it is a legitimate instance that does not use certain vocabulary. Two approaches exist (open design question — to be resolved empirically):

- **Constrained subset meta models.** Explicitly define a reduced meta model for a particular class of business.
- **Template/profiling approach (openEHR-style).** The full meta model is always the reference, but a template selects which parts apply, which are mandatory, and what constraints hold.

### 2.4 Relationship to the concentric rings model

The six layers are compatible with the concentric rings of modelling rigour ([[gsl-platform-sysml-modelling-strategy|SysML Modelling Strategy]] §8.1): inner ring (clinical pathways, maximum rigour) at Layers 2 and 1; middle ring (supporting infrastructure) at Layers 2 and 4; outer ring (business context) at Layers 3 and 5. The meta model layers (5 and 4) cut across all three rings.

---

## 3. The Ontara Console Vision

The Ontara Console is a web-based frontend providing intuitive, modern, visual access to the layered architecture. It is the primary tooling surface.

### 3.1 Two audiences

1. **Ella (now)** — the architect/developer who needs to navigate, understand, visualise, develop, and validate the model
2. **Business owners and developers (later)** — people who want to model, build, and operate service businesses using Ontara

### 3.2 The dual canvas

**Business Canvas.** A drag-and-drop surface for composing a business model from modular pieces — instances of Layer 5 concepts. The meta model defines what kinds of pieces exist and what connections are valid.

**System Canvas.** A corresponding workspace for the technology and process components that support the business model — instances of Layer 4 concepts. Shows what has been assigned, what is missing, and what is available.

The two canvases are connected by vertical mappings. When a component is placed on one canvas, the other responds: highlighting relevant counterparts, surfacing gaps, showing coverage.

### 3.3 Meta models as palette grammar

- The Business Meta Model defines the **business palette** — what component types are available, what attributes they carry, what connections are valid.
- The Business System Meta Model defines the **system palette** — and the mapping rules between business and system components.
- The PatternCatalogue acts as a **recommendation engine** — suggesting applicable patterns when components are placed, using the 43 typed semantic relationships.

### 3.4 Three levels of completeness tracking

| Level | What it tracks | Example |
|---|---|---|
| 1 | Instance coverage | For each meta model concept, which domains instantiate it? The coverage matrix. |
| 2 | Pattern coverage | For each validated pattern, which domains exercise it? |
| 3 | Meta model adequacy | Vocabulary gaps — when something cannot be expressed. Backlog for meta model evolution. |

### 3.5 Filtered views and field of view control

The console allows control over what is visible: by layer, domain, concern, cross-domain comparison, gap analysis, and pattern coverage. This is the visual realisation of the "large sheet of paper" metaphor from [[gsl-platform-sysml-modelling-strategy|SysML Modelling Strategy]] §2.4 — interactive, filterable, always current.

---

## 4. Demonstrator Domains

### 4.1 Rationale

The architecture claims to generalise. A single domain cannot prove this. Multiple non-health domains validate the meta models across structurally different businesses.

### 4.2 The chosen domains

| Domain | Display Label | Character | Key structural difference |
|---|---|---|---|
| Coffee Shop | Cafe | Immediate retail | Per-item pricing, walk-in, 2-minute cycle |
| Drop-off Laundry | Suds | Batch processing | Weight/type-dependent pricing, batch-and-turnaround, item tracking |
| Dog Grooming | Paws | Appointment-based personal service | Per-appointment pricing with add-ons, scheduled slots, persistent client/animal identity |

### 4.3 Dual purpose

Demonstrator domains serve two purposes (identified Session 45):

1. **Cross-domain validation ([[concept-cross-domain-validation|J1]]).** Three structurally different businesses validate that the BMM vocabulary generalises.
2. **Pedagogical anchoring.** Concrete illustrations that make abstract concepts tangible for non-technical users. When Sam doesn't understand "Activity Type", the demonstrators provide worked examples.

### 4.4 The continuing role of **Cafe**

Cafe remains the **reference validation domain** — where patterns were first proven. The 22 validated patterns and all BMM instantiations are the baseline.

### 4.5 Validation sequence

New concepts should first be validated in toy domains (Cafe, Suds, Paws) before extension to GSL and health. This generalises the "coffeeshop first" principle ([[principle-coffeeshop-first|A5]]).

---

## 5. Development Methodology Principles

| Principle | Summary |
|---|---|
| [[concept-cross-domain-validation|J1]] Cross-domain validation | Every concept/pattern validates in at least two domains |
| [[concept-co-evolution|J2]] Co-evolution | Model and tooling advance together. No modelling without the view that makes it legible. |
| [[concept-non-constraining|J3]] Non-constraining architecture | Decisions should not foreclose future development paths |

---

## 6. Architectural Principles Carried Forward

The following principles, established in prior documents, remain in force. They are not restated in full — the authoritative sources are referenced.

- **From [[gsl-platform-architecture-principles|Architecture Principles]]:** Separation of representation and execution (A1). Self-describing system (A2). openEHR as clinical data architecture. Clinical governance as first-class concern (A8).
- **From [[gsl-service-business-meta-modelling|Service Business Meta Modelling]]:** Two distinct meta models (A4). Five concerns (C1–C5). Activity awareness (C6). Scenario modelling and operational steering. Simulation capability (L1–L4). Modularity principle.
- **From [[gsl-platform-sysml-modelling-strategy|SysML Modelling Strategy]]:** SysML v2 as single source of truth (A3). Concentric rings of rigour. Model should earn its keep (J4). Three-tier reasoning stack (A6).
- **From [[gsl-validated-architectural-patterns|Validated Patterns]]:** 22 validated patterns, 43 semantic relationships.
- **From [[gsl-discussion-model-self-service-enabling-architecture-2026-03-14|Self-Service Enabling Architecture]]:** Enabling architecture (A7). Agency classification (H2). CoPHR heritage (H4). Four-generation roadmap (H3).
- **From the Knowledge Layer:** Self-knowledge architecture (C6 / F1). Constraint evaluation pattern (F2). Tau Prolog for Tier 2 (F6).

---

## Related Documents

- [[ontara-discussion-vision-concepts-principles-2026-03-17|Ontara Vision Discussion (original Session 35 exploration)]]
- [[ontara-master-register-design-concepts-2026-03-17|Master Concept Register]]
- [[ontara-development-workflow-guide-2026-03-17|Development Workflow Guide]]
- [[gsl-strategic-snapshot-2026-03-15-s31|Strategic Snapshot]]
- [[gsl-platform-architecture-principles|Architecture Principles]]
- [[gsl-service-business-meta-modelling|Service Business Meta Modelling]]
- [[gsl-platform-sysml-modelling-strategy|SysML Modelling Strategy]]
- [[gsl-validated-architectural-patterns|Validated Architectural Patterns]]

---

*Reference document extracted 19 March 2026 (Session 45) from the original Session 35 discussion paper. Standing reference for what Ontara is, how it is layered, and the console vision.*
