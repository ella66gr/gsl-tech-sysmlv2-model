---
tags:
  - discussion
  - architecture
  - portal
  - state
date: 2026-04-08
status: working
session: 174
---
# Discussion Paper: The Ontara Portal — State-Driven Operator Experience and Module Architecture
> `= this.file.path`

*Ontara Platform — Discussion Paper*

**Date:** 8 April 2026 (Session 174)
**Purpose:** Captures the exploratory discussion in Session 174 on the Ontara Portal concept — a user-facing platform shell organised around a state-driven interaction paradigm with a composable module architecture. This paper establishes the conceptual foundations for the Portal workstream.
**Status:** Working document — captures thinking as it emerged. Ideas are exploratory, not proposals.
**Depends on:** [[ontara-ref-modelling-paradigms|Modelling Paradigm Reference]], [[ontara-discussion-comprehension-architecture-2026-03-19|Comprehension Architecture]], [[ontara-discussion-dual-stack-architecture-2026-03-26|Dual-Stack Architecture]]

---

## Contents

- [[#1. Motivation|§1. Motivation]]
- [[#2. Three Concepts: State, State Transition, and Status|§2. Three Concepts: State, State Transition, and Status]]
- [[#3. The State-Driven Operator Paradigm|§3. The State-Driven Operator Paradigm]]
- [[#4. The Ontara Portal|§4. The Ontara Portal]]
- [[#5. Modules as Lifecycle Containers|§5. Modules as Lifecycle Containers]]
- [[#6. Module Taxonomy|§6. Module Taxonomy]]
- [[#7. Module Composition and Shared Context|§7. Module Composition and Shared Context]]
- [[#8. The Epistemic Dimension|§8. The Epistemic Dimension]]
- [[#9. Progressive Governance|§9. Progressive Governance]]
- [[#10. The Promotion Path|§10. The Promotion Path]]
- [[#11. Platform Extensibility|§11. Platform Extensibility]]
- [[#12. Architectural Connections|§12. Architectural Connections]]
- [[#13. Design Milestone Critique and Response|§13. Design Milestone Critique and Response]]
- [[#14. Open Questions|§14. Open Questions]]
- [[#15. Register Connections|§15. Register Connections]]
- [[#16. Critique Observations and Watchpoints|§16. Critique Observations and Watchpoints]]

---

## 1. Motivation

Ontara's architecture has been built from the back to the front: ontological grounding, meta models, reasoning vocabulary, governance framework, generation pipeline, comprehension architecture, and developer tooling (the Ontara Console). This work has produced a sophisticated representational and engineering foundation. What it has not yet produced is an account of what Ontara *feels like* to the person who walks up to it.

This discussion paper begins from the other direction — the front end. What does a user find when they arrive at the Ontara platform? How do they interact with it? What is the organising principle of their experience?

The answer that emerged from Session 174's exploratory discussion is: **the user's experience is organised around state**. The platform greets the operator with a landscape of stateful entities — things that are in states, that have legal transitions, that can be activated, paused, stopped, compared, and promoted. The operator's relationship with the platform is one of understanding and acting on the states of the things they have configured and instantiated.

This is distinct from a task-driven onboarding model ("Step 1: Configure your profile. Step 2: Set up your first project.") and from a feature-menu model ("Here are the tools available to you."). It is closer to how a command centre works, or how a clinician relates to a patient panel: you are looking at the *state of things* and deciding what to do.

### 1.1 The developer experience mirrors the user experience

The state-driven paradigm applies to the developer/architect as well as the end user. When developing the next piece of the Ontara platform, the question becomes: "What states exist now, what's missing, what transitions need to be built?" — framed in terms of what the user can see and do. The front-end state landscape serves as a design tool as well as a delivery mechanism.

### 1.2 Relationship to the Modelling Paradigm Reference

The [[ontara-ref-modelling-paradigms|Modelling Paradigm Reference]] (Session 173) identifies the state machine paradigm as "substantially" exploited through the XState-in-Temporal pattern and SysML v2 `state def`/`exhibit` constructs. What this discussion paper describes is a *platform-level* application of the state paradigm — not state machines for individual business entities (which already exist), but a state-driven organising principle for the entire operator experience, from account creation through to production deployment.

---

## 2. Three Concepts: State, State Transition, and Status

The platform needs to distinguish three related but distinct concepts:

**State** — the actual condition of an entity at a point in time. In BFO terms, close to a quality or disposition — something that inheres in the entity. In the [[concept-coordinate-framework|coordinate framework (A12)]], the entity's position in the representational space at a given moment. State can be rich and multi-dimensional.

**State transition** — a change from one state to another, governed by a lifecycle definition that specifies which transitions are legal. State transitions may be triggered by operator action, by system events, or by conditions in connected entities. Not all transitions are reversible; some are one-way (promotion to production, deletion).

**Status** — a *classification* or *assessment* of an entity's condition, typically from the perspective of a particular concern or stakeholder. Status is a **projection** — a dimensionally-reduced view of a richer underlying state, computed for a specific purpose.

The distinction between state and status matters because a single entity may have many simultaneous status projections. A business module might be in the *state* of "running, 47 active customer records, 3 unresolved governance alerts, 12 transactions in the last hour" — but its *status* from the operator's dashboard perspective is "LIVE — PLAY", its governance status is "3 Alerts", and its financial status is "On Track." Each status is a comprehension operation that takes the underlying state and renders it into something actionable for a particular audience.

This connects directly to the [[ontara-discussion-comprehension-architecture-2026-03-19|comprehension architecture]]: status is the comprehension layer's gift to the operator. The three registers of comprehension (authored, structural, inferential) all contribute to producing meaningful status projections from raw state.

---

## 3. The State-Driven Operator Paradigm

The central design principle for the Ontara Portal:

> **The operator's primary view is a composition of stateful entities with their status projections. Everything the operator sees is something with a state. Everything the operator does is a state transition or a configuration that prepares for one.**

This principle has several implications:

1. **The dashboard is a state landscape**, not a feature menu or a task list. It shows the operator what things exist and what states they are in.

2. **Available actions are derived from current state.** What Jo can do at any moment is determined by the lifecycle definitions of the entities she's looking at, given their current states. The platform doesn't present a flat menu of all possible actions — it presents the transitions available *from here*.

3. **The system explains its own state.** Through the comprehension architecture, the platform can tell the operator what a state means, why an entity is in that state, what transitions are available and what their consequences would be. The self-describing system principle ([[principle-self-describing-system|A2]]) is given direct expression in the operator experience.

4. **Concurrent states are the norm.** The operator is always looking at multiple entities in multiple states simultaneously. The dashboard makes the composition of states legible — not just individual statuses, but the relationships and dependencies between them.

---

## 4. The Ontara Portal

The Ontara Portal is the user-facing platform, distinguished from the Ontara Console (the architect/developer's view on the back end). The Portal is the environment through which operators create, configure, simulate, compare, and deploy service businesses on the Ontara platform.

### 4.1 Platform identity

Ontara is a service platform delivered over the web — analogous to "a Heroku for service businesses." Operators come to Ontara to build and run service businesses without building the underlying platform infrastructure.

### 4.2 User accounts and domains

The platform maintains an independent registry of Ontara platform users, each with their own SSO platform user account. A user account can operate multiple top-level domains (e.g. `brightstar.ontara.co.uk`).

Each domain has a **super admin** role by default. Ordinary user accounts may be granted access to zero or more domains by the super admin, with access handled independently according to role. The relationship between platform users and domains is many-to-many: a user may have access to multiple domains; a domain may have multiple users.

User portal accounts include standard account administration: profile, billing admin (with a free tier assumed for now). A user is distinguished by having zero or more billing centres that they are responsible for.

### 4.3 Domain coherence constraint

Everything under a single top-level domain shares a common ontological frame. A domain is associated with a particular kind of business, and this association shapes the high-level ontology and modelling context for everything beneath it. A user cannot combine unrelated service types (e.g. therapy counselling and handbag restoration) under the same domain. This connects to the [[ontara-discussion-domain-identity-dual-stack-2026-04-05|domain identity architecture (B15)]] — the domain identity is a governing constraint that filters the module catalogue and shapes the ontological context for all modules within the domain.

### 4.4 The portal shell

In its base state — a newly created account with no modules instantiated — the Portal presents an initialised shell. The housekeeping at this level (profile, billing, domain setup) is standard platform administration. The shell has structure and can receive the operator's input, but it doesn't presuppose what the operator will build. It is the same shell regardless of whether the operator is running a café or a gender clinic; what changes is the content that populates it and the domain-specific states that emerge as modules are configured.

---

## 5. Modules as Lifecycle Containers

### 5.1 What a module is

A **module** is the primary unit of lifecycle management on the Ontara Portal. It is the thing that can be activated, paused, stopped, and reset. It is the thing with a status indicator on the dashboard. It is the thing the operator acts on.

Modules are not hard-bordered boxes. They are **composable, connectable, and nestable**. A module may contain sub-modules; modules may be wired together; what's inside a module and how it connects to other modules is flexible. The key property of a module is that it provides a **discrete container for a lifecycle** — a boundary within which state is managed as a unit.

Crucially, **a viable running business is itself a composed assembly of modules** — not a single monolithic entity. There is no privileged "business module" that is architecturally distinct from any other module. A business might consist of a single module or a group of many, and the composition is the operator's design decision. The constraints on composition come from the logic of the features involved, not from any limit on hierarchy or combination. A minimal viable business might be a small set of tightly integrated modules; a mature business might be a large, deeply nested assembly with specialised sub-groups.

The module boundary is an *operational* decision, not just an architectural one. The question "where do I draw the module boundary?" is answered by "what do I want to be able to activate, pause, and reset as a unit?" This may coincide with functional boundaries, but need not — the operator might want to manage a whole business instance as one module, or manage its scheduling independently of its billing.

### 5.2 Module lifecycle

A module has a defined lifecycle with the following states:

| State | Meaning |
|---|---|
| **Available** | Listed in the catalogue; not yet installed in this domain |
| **Installed** | Selected and placed in the domain; ready for configuration |
| **Edit mode** | Being configured by the operator; not running |
| **Activated** | Running — the module's business model is live (in simulation or production) |
| **Paused** | Execution suspended; state preserved; can be resumed |
| **Stopped** | Execution halted; state retained but not active |
| **Reset** | Returned to an initialised state; configuration preserved but operational state cleared |
| **Deleted** | In trash; recoverable with history unless trash is emptied |

These states decompose into two interleaved concerns:

- **Installation lifecycle:** Available → Installed → Deleted (with trash/restore). This is about whether the module exists in the operator's domain at all.
- **Operational lifecycle:** Edit mode → Activated → Paused → Stopped → Reset. This applies only to installed modules and governs what they are doing at any moment.

### 5.3 Status indicators

Each module has a status indicator panel on the dashboard, showing the module name and its current status. The status indicator conveys both the operational state and (for activated modules) relevant status projections — governance compliance, activity level, alerts. The dashboard arrays these indicators for the operator, providing an at-a-glance state landscape.

---

## 6. Module Taxonomy

Three distinct module **roles** emerged from the discussion. This taxonomy is empirical and emergent — it reflects the roles that surfaced from thinking through concrete scenarios, not a fundamental classification derived from first principles. The taxonomy will evolve as understanding and insight grow; new roles may emerge and the boundaries between existing roles may shift.

These describe functional roles within a composed assembly, not rigid types — a given module might serve more than one role, and the roles help the operator understand what each piece of their assembly is *for*:

### 6.1 Business instance modules

These *are* the business. They contain the service configuration, they run the business model, they have customers, transactions, and activity. They can exist in simulation or production mode, and multiple variants can coexist for comparison.

Examples: JewelClean-A, JewelClean-B, JewelClean-HomeDelivery, InitialAssessmentClinic.

### 6.2 Analytical modules

These observe business modules and produce insight. They consume data from the business modules they are connected to and present the operator with comparisons, projections, metrics, and recommendations. They have their own lifecycle but are parasitic — they feed on the state of other modules.

Examples: a comparative analysis module wired to two business variants, a financial projection module, a governance compliance dashboard.

### 6.3 Generative modules

These feed business modules with synthetic activity. They generate customers, transactions, issues, and events — the lifeblood that a business module needs in order to simulate. They have their own lifecycle and configuration (parameters for data generation rate, scenario distribution, environmental assumptions).

Examples: a test data generator, a simulated customer behaviour module, an environmental scenario driver (optimistic/pessimistic economic conditions).

### 6.4 The three-role pattern

These three types form a natural pipeline: **generators feed business instances, which feed analysers.** The operator composes this pipeline on the dashboard: wire up a generator to two business variants, wire both variants to a comparator, activate the whole assembly, and observe the results.

The taxonomy is not exhaustive or rigid — it captures the roles that emerged from discussion. Other module types may emerge (infrastructure modules, integration modules, reporting modules). The principle is that each module type serves a distinct purpose in the operator's workflow while sharing the common lifecycle framework.

---

## 7. Module Composition and Shared Context

### 7.1 Domain-level shared context

All modules under the same domain share a common context. This shared context is structured along the BMM concern lines:

- **[[concept-service-concept|ServiceConcept]]** — what the domain's business offers and to whom
- **[[concept-resource-planning|ResourcePlanning]]** — shared resources (premises, equipment, staff)
- **[[concept-financial-planning|FinancialPlanning]]** — shared financial structure (billing, cost base)
- **[[concept-governance-mapping|GovernanceMapping]]** — shared regulatory context
- **[[concept-stakeholder-model|StakeholderModel]]** — shared relationships (partners, customers, regulators)
- **[[concept-activity-model|ActivityModel]]** — shared activity types where they cross module boundaries

The BMM concerns are not abstract categories for the architect — they are the *dimensions along which modules share and compose*. The shared context is the "bloodstream" that connects modules within a domain.

### 7.2 Module wiring

Modules connect to each other through defined interfaces. When Jo activates a jewellery repair module alongside her existing cleaning module, the repair module inherits the domain context (customers, premises, brand) and connects to the shared resources. The comprehension architecture should explain this to the operator: "Your repair module shares these with cleaning: customer registry, premises, brand identity. It adds these new elements: partner jeweller (StakeholderModel), repair skills (ResourcePlanning), different pricing model (FinancialPlanning)."

### 7.3 Inter-module lifecycle constraints

The lifecycles of connected modules interact. If module A depends on module B and B is stopped, what happens to A? These interactions are governed by the constraint hierarchy:

- **HardConstraints** — you *cannot* activate a module in a suspended domain; you *cannot* delete a module that other active modules depend on.
- **SoftConstraints** — you *can* activate module A without module B, but the system warns you they are designed to work together.

The comprehension layer explains these constraints to the operator as they make lifecycle decisions.

### 7.4 The constructor-set paradigm

The modular approach provides a "constructor set" mentality. New service capabilities plug into the existing business model core. The platform determines how additional services connect through the shared context. A minimally-viable core might consist of one or several modules providing the essential feature set, with additional modules extending the business as it grows.

For example: Jo starts with a jewellery cleaning module (the core). Later, she adds a jewellery repair module by engaging a partner jeweller. The repair module plugs into the existing shared context (customers, premises, brand) while adding repair-specific elements (the partner's skills, different pricing, potentially new governance requirements for repair work). The platform guides this composition through the BMM concern structure.

---

## 8. The Epistemic Dimension

### 8.1 Module instances carry epistemic character

A module's lifecycle state (activated, paused, etc.) tells the operator what it is *doing*. But modules also have an **epistemic character** — what *kind of knowledge* does this instance represent?

This connects to the [[concept-coordinate-framework|coordinate framework (A12)]] and specifically to the five epistemic types established for [[concept-coordinate-space-snapshots|coordinate space snapshots (L8)]]:

- **Current** — the live production state
- **Historical** — a preserved past state
- **Goal** — a target state the operator is working towards
- **Hypothetical** — an alternative configuration being explored
- **Projected** — the expected future state under stated assumptions

When Jo creates two versions of her cleaning business for comparison, she is creating two hypothetical instances. When she runs them under different economic assumptions, the results are projections. The epistemic character is not a label — it determines the *consequence boundary* of the module (simulation results versus real business outcomes) and the *evidential weight* of its outputs.

### 8.2 Comparative simulation

The platform actively supports parallel experimentation. The operator can instantiate sibling modules — variants that share structural configuration but differ in controlled ways — for comparison:

- **Same structure, different assumptions.** The business model is held constant; the environment varies. This tests robustness: "Does my service design work under both optimistic and pessimistic conditions?"
- **Same assumptions, different structure.** The environment is held constant; the service configuration varies. This tests design alternatives: "Is home collection better or retail premises better, given these market conditions?"

In both cases, a comparative analysis module (§6.2) is wired to the sibling business modules, and a generative module (§6.3) feeds them with synthetic activity. The operator's dashboard becomes a *comparative state landscape* — she can see at a glance which variant is in which state and how their results differ.

### 8.3 Progressive fidelity

The operator can iterate through levels of simulation fidelity:

1. **Simplified assumptions, no governance** — test whether the basic business model is economically viable.
2. **Simplified assumptions, basic governance** — see what regulatory constraints introduce.
3. **Realistic assumptions, full governance** — test the business under production-like conditions.
4. **Production** — the business model is live with real data and full regulatory force.

This progression is not a fixed staircase — the operator can engage any combination at any time. The platform makes the full range of utility available when helpful, but keeps it out of the way when not needed. Governance is experienced as progressive engagement, not as a wall.

---

## 9. Progressive Governance

The governance vocabulary already provides the formal machinery for graduated governance engagement:

- **HardConstraints** (obligations, prohibitions) — these are non-negotiable in production mode but can be relaxed or deferred in simulation modes.
- **SoftConstraints** (cost surfaces) — these influence but don't prevent; they apply at all levels but with different weight depending on the fidelity setting.
- **GradedRules** (truth-value surfaces) — these evaluate gradually; their thresholds may be adjusted for exploratory versus production contexts.

When a module is in simulation mode with governance relaxed, the system still *knows* which constraints exist — it just doesn't enforce them as blocking. The comprehension layer can tell the operator: "In production, this configuration would trigger 3 governance alerts. You've chosen to suppress governance for this simulation — here's what would happen if you turned it on."

This makes governance explorable rather than punitive. The operator learns what governance requires by engaging with it progressively, rather than being confronted with a wall of compliance requirements at the moment of production deployment.

---

## 10. The Promotion Path

The transition from simulation to production is a defined lifecycle operation — a **promotion**. The operator takes a business module that has been tested and validated in simulation and promotes it to production status.

Promotion is not a simple state toggle. It involves:

1. **Epistemic transition** — the module's character changes from hypothetical/projected to current. Its outputs now represent real business activity.
2. **Consequence boundary change** — real customers, real transactions, real financial and legal consequences.
3. **Governance activation** — governance constraints that were optional in simulation become binding. HardConstraints enforce. Audit trails activate. Compliance monitoring begins.
4. **Data source transition** — generative modules (synthetic data) disconnect; real data sources connect.
5. **Operational requirements** — monitoring, backup, disaster recovery, service-level commitments.

The platform guides the operator through this transition, using the comprehension architecture to explain what changes: "When you promote this to production, these governance requirements will apply: [list]. These data sources will need to be connected: [list]. These operational requirements will activate: [list]. Are you ready?"

---

## 11. Platform Extensibility

The module architecture is inherently extensible to third-party contributions. If modules are composable, lifecycle-managed, and wire together through defined interfaces, then there is nothing architecturally special about whether a module was built by the Ontara platform, by the operator, or by a third-party developer. The plug-in architecture is a natural consequence of the module design, not an additional feature.

This is noted here to anchor the design — nothing built in the near term should foreclose third-party extensibility ([[concept-non-constraining|J3]]). Detailed plug-in architecture design is deferred.

---

## 12. Architectural Connections

### 12.1 Coordinate framework (A12)

The operator's entire deployment traces a trajectory through a multi-dimensional state space. The nested lifecycle levels (platform → domain → instance → module → business entity) are different axes or subspaces within the coordinate framework. Module epistemic character maps to the five coordinate space snapshot types (L8).

### 12.2 Multi-tenancy (A13)

The domain lifecycle is the *operational* expression of tenancy. A13 is not just a structural classification — it is a living thing with its own state transitions, resource boundaries, and governance scope.

### 12.3 Operational simulation (L5)

When a module is activated in simulation mode, the [[concept-operational-simulation|operational simulation]] is what runs underneath. The business model is made live in a sandboxed execution context. "LIVE — PLAY" means L5 is executing the model.

### 12.4 Reflective simulation (L6) and valence (L7)

Analytical modules consume the output of [[concept-operational-simulation|L5]] and present it through [[concept-reflective-simulation|L6]]. The operator's declared conception of good versus bad business performance ([[concept-valence|valence, L7]]) shapes how comparisons and recommendations are framed.

### 12.5 Comprehension architecture

The comprehension layer is the portal's nervous system. It produces the status projections that populate the dashboard, explains state transitions to the operator, surfaces inter-module dependencies, and guides the promotion path. All three registers of comprehension (authored, structural, inferential) contribute.

### 12.6 BMM/SMM distinction (A4)

The portal presents states from both meta models coherently. Module selection and configuration are primarily BMM concerns (what is this business?). Module operational state is primarily an SMM concern (what is the system doing?). The shared domain context is structured along BMM concern lines. The dashboard unifies both through the state-driven paradigm.

### 12.7 Self-describing system (A2)

The portal is the most direct expression of A2 yet conceived. The system doesn't just run — it knows it's running, and it tells the operator what it's doing and why.

### 12.8 Governance vocabulary

The three-way constraint hierarchy provides the machinery for progressive governance. The promotion path activates governance constraints that were optional in simulation.

### 12.9 Modelling paradigm reference

The portal workstream exercises paradigms identified as underexploited: state machines (now applied at platform level), contract/interaction (module wiring, inter-module agreements, operator authority), and event-driven (module state change propagation, alerts). It substantially deepens the state machine paradigm beyond individual entity lifecycles.

---

## 13. Design Milestone Critique and Response

The following structured critique was performed at Session 174 as a design milestone review per [[ontara-workflow-guide|workflow guide]] §1 commitment 5 and §2.2. Ella's responses are included as part of the design record, as they clarify architectural positions.

### 13.1 Concerns raised

**Concern 1: Composition complexity.** The arbitrarily composable, nestable, wireable module architecture produces a combinatorial space that is genuinely hard to make legible. The [[ontara-discussion-comprehension-architecture-2026-03-19|comprehension architecture]] is nominated as the solution, but it has only been tested against static model structure (the three registers, the glossary, the coverage matrix), not against runtime compositional complexity. Explaining "Activity Type has five categories" is categorically different from explaining "if you stop module B, modules A and C will lose their data feed, module D's comparison will become invalid, and module E's governance monitoring will report incomplete data." The dynamic, graph-structured, state-dependent nature of module composition is a harder comprehension problem than anything the architecture has faced so far.

**Response:** The engineering flexibility under the hood can be vast without the user being exposed to that vastness. Design patterns, guided composition, and user-appropriate presentation all sit between the raw combinatorial space and what the operator actually sees. The [[concept-dual-stack-architecture|dual-stack architecture]] already provides the mapping from engineering concepts to business purposes — the portal is the surface where that mapping becomes visible. In a well-designed system, engineering effort is deployed into making the system fit for the user and their purposes. The comprehension layer will be adapted and purposed to suit the needs of a given user, rather than a one-size-fits-all. The language of "modules" is architectural/engineering vocabulary for things that will in all likelihood be presented to a user in a friendly and comprehensible way. The mapping of function to business purpose is key, and is already addressed inherently in the dual-stack architecture model.

**Concern 2: The gap between "module" and "SysML model".** [[principle-model-generates-everything|A3]] says the model generates everything. The portal introduces modules as the primary unit of operator interaction. But what *is* a module in model terms? If a module's configuration is a SysML model fragment, then composing modules means composing model fragments, and the platform needs formal composition semantics at the SysML level. If a module is a runtime concept that consumes model-generated artefacts but isn't itself modelled in SysML, then the relationship between A3 and the portal needs careful articulation. Either answer is viable, but the choice has deep implications.

**Response:** Modules are modelled in SysML — the composition semantics live in the model, not bolted on at the front end. This is fundamentally consistent with A3. A module is a model concept, not a runtime presentation concept. The SysML model needs to express: this is a module, it contains these elements, it has this lifecycle definition, it connects to these other modules through these interfaces. SysML v2 package and part composition constructs should be able to carry this, but the detailed modelling decisions will need working through. The architectural hinge is on the model side, which is where it should be.

**Concern 3: Lifecycle conflation.** The eight-state lifecycle mixes installation states (available, installed, deleted) with operational states (edit, activated, paused, stopped, reset). The transitions between these states have very different characters: "Available → Installed" is a catalogue operation; "Edit → Activated" invokes A3 and L5; "Activated → Paused" is a runtime suspension. These involve different platform subsystems, different failure modes, and different user expectations. A single linear lifecycle may not be the right formal structure.

**Response:** Agreed. Multiple lifecycles will intersect and interact. The platform's own state-machine paradigm provides the tools to model intersecting lifecycles cleanly. This is a modelling question that should be addressed through the architecture, not papered over.

**Concern 4: The "module" metaphor for non-technical operators.** "Module" carries strong connotations from software engineering — plug-in, component, package. For a non-technical operator, it might feel technical and imposed.

**Response:** "Module" is engineering vocabulary, not user-facing language. Surface language for the user is a separate design concern. The operator will interact with concepts presented in terms that make sense for their business. The BMM-to-SMM horizontal mapping provides exactly this translation. "Module" is not metaphor — it is engineering paradigm (plug-in architecture). What the user sees is a different question.

**Concern 5: Progressive governance is operationally tricky.** Governance constraints in regulated sectors are legal requirements, not optional features. The platform needs to be clear about the boundary between "simulating without governance for learning" and "running without governance in violation of compliance." The epistemic dimension helps, but the platform must prevent accidental promotion to production with governance still relaxed.

**Response:** The user can compose and simulate as they wish — the platform is a tool and people use tools for their own purposes. Governance is available, not imposed during experimentation. The platform's role is to make governance *available* when helpful and *out of the way* when not. However, obtaining sign-off — howsoever that occurs and from whomever — for production deployment is a different matter. The enforcement boundary is at the promotion path, not during experimentation. The three-way constraint hierarchy ([[concept-hard-constraint|HardConstraint]], [[concept-soft-constraint|SoftConstraint]], [[concept-graded-rule|GradedRule]]) already supports this: HardConstraints become blocking only when the module's epistemic status demands it.

### 13.2 Positive observations

**The approach makes the abstract architecture tangible for the first time.** After 173 sessions of building representational infrastructure — meta models, ontologies, reasoning vocabularies, governance frameworks — this is the first time the question "what does this *do* for someone?" has been addressed directly. The portal concept gives every piece of the back-end architecture a reason to exist from the operator's perspective. The BMM concerns are the dimensions of shared context. The [[concept-operational-simulation|operational simulation]] is what happens when the operator hits "activate." The comprehension architecture is how the platform explains itself. This grounding effect is genuinely valuable.

**The state-driven paradigm unifies BMM and SMM at the experience layer.** This is architecturally significant. The operator doesn't need to know about the [[principle-two-meta-model-distinction|two-meta-model distinction]] — they experience a single coherent landscape of stateful things. But the architecture behind it cleanly separates business configuration (BMM) from system operation (SMM). The portal is the first concrete expression of the horizontal mappings between BMM and SMM that have been part of the architecture since Session 73.

**The epistemic dimension gives the [[concept-coordinate-framework|coordinate framework]] its first practical application.** The five coordinate space snapshot types (current, historical, goal, hypothetical, projected) were established in Session 73 and enriched in Session 147, but have remained theoretical. An operator creating two hypothetical business variants and running projections under different assumptions is the coordinate framework in use — validating [[concept-coordinate-framework|A12]] at the operator experience level.

**The approach naturally exercises the contract/interaction paradigm.** The [[ontara-ref-modelling-paradigms|Modelling Paradigm Reference]] identified this as the most architecturally interesting underexploited paradigm. Module wiring — agreements about data flow, lifecycle interactions, promotion commitments — is inherently contractual. The portal workstream exercises this paradigm without forcing it.

### 13.3 Alternative approaches and precedent

**Salesforce's metadata-driven platform.** Probably the closest industry precedent — a multi-tenant platform where operators configure and compose business functionality without writing code, backed by a metadata-driven architecture. Their "custom objects, fields, and workflows" model is less formally grounded than Ontara's BMM/SysML approach, but proven at enormous scale. Key lesson: *guided composition* matters enormously — their App Builder and Flow Builder provide structured environments rather than leaving operators to wire things freehand. Ontara's constructor-set paradigm heads in this direction.

**Kubernetes and declarative desired-state.** The operator declares a desired state (configuration), the platform continuously reconciles actual state with desired state, and the operator monitors the result through status projections. The controller-loop pattern (observe → compare → reconcile) is proven engineering for state-driven platforms. Kubernetes operates at infrastructure level; Ontara applies the same pattern at the *business model* level — a novel and interesting extension.

**Simulation platforms (AnyLogic, Simul8, Arena).** The comparative simulation capability — instantiate variants, feed with generated data, compare results — has strong precedent. These platforms distinguish between model (what you design), experiment (what you run), and results (what you analyse), mapping loosely to business/generative/analytical module roles. What they *don't* do is provide a promotion path from simulation to production — Ontara's A1/A3 architecture goes further.

**PaaS platforms (Heroku, Railway, Render).** The "Heroku for service businesses" analogy is apt. These platforms provide shell environments with lifecycle management (deploy, scale, stop, rollback), environment separation (staging, production), and dashboards showing service state. What Ontara adds is that the thing being deployed is a *business model*, and the platform understands business semantics, not just infrastructure.

**No-code/low-code platforms (Bubble, Retool, Appsmith).** Component catalogue, composition, and preview/publish lifecycle are conceptually similar. Their limitation is being *application* builders, not *business model* builders — they don't understand what a business *is*. Ontara's BMM-grounded approach provides genuine business domain understanding.

**Digital twins in manufacturing.** A live, stateful model that the operator monitors and acts on — conceptually close. GE Predix and Siemens MindSphere are organised around this principle. The difference is that their twin mirrors something physical; Ontara's model is the *primary* representation ([[principle-separation-representation-execution|A1]]), with the running business being its execution.

**Clinical dashboards and patient panels.** Ella's own professional context provides precedent. The way a clinician relates to a patient panel — seeing state, understanding what needs attention, deciding based on current state and available transitions — is the state-driven paradigm applied to clinical care. The Ontara Portal applies the same cognitive pattern to business operation.

### 13.4 Assessment

The approach is sound and has scattered precedent across several industries. The specific combination — a state-driven operator experience over a formally grounded, ontologically rigorous, model-generates-everything business platform — is genuinely novel. The risks are real (composition complexity addressed by guided user experience, the SysML/module modelling resolved in favour of model-side composition, lifecycle formalism to be worked through as intersecting lifecycles, governance safety handled at the promotion boundary) but they are engineering challenges, not conceptual flaws. The concept holds together.

---

## 14. Open Questions

1. **Module catalogue structure.** How is the module catalogue organised? By BMM concern? By service entity type? By functional role (business, analytical, generative)? What determines which modules are available for a given domain type?

2. **Module granularity.** Where are the natural module boundaries? Is "appointment scheduling" a module, or is it a component within a larger "clinical operations" module? How does the operator decide, and does the platform guide this decision?

3. **Inter-module communication protocol.** How do modules communicate state and data to each other? What is the interface contract between a generative module and a business module, or between a business module and an analytical module?

4. **Lifecycle constraint formalism.** How are inter-module lifecycle constraints expressed? Are they modelled in the same vocabulary as business-level constraints (HardConstraint/SoftConstraint), or do they need a platform-level constraint vocabulary?

5. **Promotion prerequisites.** What must be true before a module can be promoted from simulation to production? Is there a formal readiness assessment? How does the platform verify that governance requirements can be met?

6. **Dashboard design.** What does the state landscape actually look like? How does the operator navigate between the domain overview, individual module detail, and cross-module comparisons?

7. **Relationship to the Ontara Console.** The Console is the architect/developer view; the Portal is the operator view. What is their relationship? Are they different views on the same data? Does the Console inform the Portal's module catalogue?

8. **Multi-user collaboration within a domain.** How do multiple users interact with the same domain's modules? Can two users be editing the same module? How is concurrent access managed?

9. **The SysML connection.** How do modules relate to SysML model content? Is a module's configuration stored as SysML? Is there a generation step between model and running module? How does A3 (model generates everything) apply at the Portal level?

10. **Naming and terminology.** "Module" is a working term. Is it the right word for the user-facing concept? Does it convey the right mental model to a non-technical operator?

---

## 15. Register Connections

| Register concept | Relevance to this paper |
|---|---|
| [[principle-separation-representation-execution\|A1]] | Module configuration is representation; module activation is execution. The promotion path is where A1 is most directly experienced by the operator |
| [[principle-self-describing-system\|A2]] | The portal is the primary surface where the system describes itself to its users |
| [[principle-model-generates-everything\|A3]] | Module activation involves generating running systems from model configuration |
| [[principle-two-meta-model-distinction\|A4]] | The portal presents BMM (what is this business?) and SMM (what is the system doing?) coherently through the state-driven paradigm |
| [[principle-deterministic-over-probabilistic\|A6]] | Progressive governance engagement makes the deterministic/auditable reasoning principle explorable rather than confrontational |
| [[principle-discipline-as-load-bearing-structure\|A9]] | The lifecycle definitions are disciplined structures that propagate reliability |
| [[principle-intrinsic-self-knowledge\|A10]] | Status projections are dynamically computed from live module state |
| [[principle-unity-principle\|A11]] | Weighted relationships inform which modules should be connected and how tightly |
| [[concept-coordinate-framework\|A12]] | Module state trajectories; epistemic character; multi-dimensional state space |
| [[concept-multi-tenancy\|A13]] | Domain lifecycle as the operational expression of tenancy |
| [[concept-co-evolution\|J2]] | Portal development co-evolves with module vocabulary and lifecycle definitions |
| [[concept-non-constraining\|J3]] | Module architecture must not foreclose third-party extensibility |
| [[concept-stakeholder-model\|StakeholderModel]] | Shared domain context; module wiring at the relational boundary |
| [[concept-operational-simulation\|L5]] | Module activation runs L5 underneath |
| [[concept-reflective-simulation\|L6]] | Analytical modules are the user-facing expression of L6 |
| [[concept-valence\|L7]] | Operator's declared value framework shapes analytical module outputs |
| [[concept-coordinate-space-snapshots\|L8]] | Module epistemic character maps to five snapshot types |
| [[concept-goal-seeking-computation\|L9]] | Goal-region navigation applied to business model optimisation |

---

## 16. Critique Observations and Watchpoints

| ID | Observation | Category | Proposed work type |
|---|---|---|---|
| S174-CQ-1 | The comprehension architecture has not been tested against runtime compositional complexity (dynamic module graphs). The jump from static model explanation to explaining inter-module lifecycle consequences is a significant engineering challenge | Qualifying | CON, RGV |
| S174-CQ-2 | The SysML/module relationship is resolved in principle (modules are model concepts, not runtime-only) but the specific SysML v2 constructs for expressing module identity, lifecycle definitions, and composition interfaces have not been identified | Testable prediction: SysML v2 package/part composition can carry it | BMM, KGO |
| S174-CQ-3 | The single eight-state lifecycle should be decomposed into multiple intersecting lifecycles (installation, operational, and potentially epistemic). The platform's own state-machine paradigm should model these formally | Actionable: address in next design iteration | BMM, CON |
| S174-CQ-4 | The promotion path from simulation to production is a safety-critical interface — the platform must prevent accidental promotion with governance relaxed. The enforcement boundary is at promotion, not during experimentation | Testable prediction: three-way constraint hierarchy is sufficient | GSL, GOV |
| S174-CQ-5 | The module taxonomy (business, analytical, generative) is empirical and emergent, not fundamental. It will evolve and should be treated as a working classification, not a governing one | Qualifying | BMM, CON |

---

*Discussion paper written 8 April 2026 (Session 174). Arising from exploratory discussion on the state-driven operator experience, module architecture, and the Ontara Portal concept. Ideas are exploratory — not proposals. No observation too basic.*
