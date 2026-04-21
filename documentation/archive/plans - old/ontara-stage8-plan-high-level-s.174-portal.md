---
tags:
  - plan
  - portal
  - state
date: 2026-04-08
status: active
session: 174
---
# Stage 8 Plan — Ontara Portal: State-Driven Operator Experience
> `= this.file.path`

**Session:** 174
**Date:** 8 April 2026
**Purpose:** High-level plan for building the Ontara Portal — a user-facing platform shell organised around a state-driven interaction paradigm with a composable module architecture. This is a prototyping-led stage: we build to learn, evolve towards production, and refactor as understanding grows.
**Status:** Active. Phase 1 not yet started.
**Depends on:** [[ontara-discussion-portal-state-driven-operator-experience-2026-04-08|Portal Discussion Paper (Session 174)]], [[ontara-discussion-dual-stack-architecture-2026-03-26|Dual-Stack Architecture]], [[ontara-discussion-comprehension-architecture-2026-03-19|Comprehension Architecture]]
**Work item:** *To be assigned at C2.*

---

## Contents

- [[#1. Scope and Objectives|§1. Scope and Objectives]]
- [[#2. What Stage 8 Is Not|§2. What Stage 8 Is Not]]
- [[#3. Guiding Principles|§3. Guiding Principles]]
- [[#4. Technology Decisions|§4. Technology Decisions]]
- [[#5. Phase 1 — The Empty Shell|§5. Phase 1 — The Empty Shell]]
- [[#6. Phase 2 — Module Lifecycle|§6. Phase 2 — Module Lifecycle]]
- [[#7. Phase 3 — Domain Context and Module Composition|§7. Phase 3 — Domain Context and Module Composition]]
- [[#8. Phase 4 — Simulation and Comparison|§8. Phase 4 — Simulation and Comparison]]
- [[#9. Phase 5 — Governance and Promotion|§9. Phase 5 — Governance and Promotion]]
- [[#10. Phase Summary|§10. Phase Summary]]
- [[#11. Success Criteria|§11. Success Criteria]]
- [[#12. Session Estimate|§12. Session Estimate]]
- [[#13. Risks and Mitigations|§13. Risks and Mitigations]]
- [[#14. Open Design Questions by Phase|§14. Open Design Questions by Phase]]
- [[#15. Register Connections|§15. Register Connections]]

---

## 1. Scope and Objectives

Stage 8 builds the **Ontara Portal** — a new, separate web application that provides the user-facing operator experience for the Ontara platform. It is distinct from the Ontara Console (the architect/developer view).

The stage has five objectives:

1. **Build a working portal shell** with user accounts, domain creation, and a dashboard — the empty but structured environment that greets an operator.
2. **Implement the module lifecycle** so that operators can install, configure, activate, pause, stop, and reset modules from a catalogue.
3. **Implement domain-level shared context and module composition** so that modules within a domain share resources and connect through the BMM concern structure.
4. **Enable simulation and comparison** so that operators can create variant business modules, feed them with generated data, and compare results through analytical modules.
5. **Implement progressive governance and the promotion path** so that operators can progressively engage governance and promote tested configurations to production status.

The five phases are designed to be independently valuable — each produces a working, usable increment. If we stop after Phase 2, we have a portal with lifecycle-managed modules. If we stop after Phase 3, we have composable business configuration. Each phase builds on the last but delivers standalone value.

### 1.1 Prototyping ethos

This stage is prototyping-led. The goal is to learn by building, not to produce production-perfect code on the first pass. Decisions should be made quickly and revisited when experience reveals a better path. Refactoring is expected and welcome. The discussion paper's ideas are hypotheses to be tested by building, not specifications to be implemented blindly.

This does not mean careless work — the prototype should be well-structured enough to evolve into production. But it does mean prioritising working software over comprehensive design, and accepting that some early decisions will be revised.

---

## 2. What Stage 8 Is Not

The following are explicitly **out of scope** for Stage 8:

- **Production deployment infrastructure.** The portal will run locally in development mode. Cloud deployment, CI/CD, container orchestration, and production hosting are not addressed.
- **Real payment processing or billing.** The billing centre and free-tier concepts are modelled as data structures. No payment gateway integration.
- **Real SSO integration.** Authentication is prototyped with local accounts. SSO/OAuth integration is deferred to production hardening.
- **Full SysML model integration.** The portal's module catalogue and configuration surfaces will initially be hand-coded prototypes. The generation pipeline from SysML model to portal content (the A3 connection) is a significant piece of work that will be designed during Stage 8 but may not be fully implemented. The discussion paper's position that modules are modelled in SysML stands as a directional commitment; the prototype may use simplified representations while that modelling work is developed.
- **The Ontara Console rework.** The Console remains as-is. The relationship between Console and Portal is a design question to be explored, not a Stage 8 deliverable.
- **Runtime business execution.** Actual Temporal workflow execution, XState state machines, database operations for business entities — the L5 operational simulation — is not built in Stage 8. Module "activation" will initially mean the module's lifecycle state transitions to "activated" and the dashboard reflects this. Connecting activated modules to real execution substrates is future work.

### 2.1 What the prototype *does* deliver

Despite the above exclusions, the prototype delivers something real: a working web application where a user can create an account, set up a domain, browse a module catalogue, install and configure modules, manage module lifecycles from the dashboard, and see the state-driven paradigm in action. The modules themselves will be shells — but they will be *stateful* shells with real lifecycle management, real dashboard status indicators, and real composition wiring. The value is in experiencing the state-driven paradigm, not in the modules' internal business logic.

---

## 3. Guiding Principles

| Principle | Application in Stage 8 |
|---|---|
| [[principle-separation-representation-execution\|A1]] | Module configuration is representation. Keep configuration data cleanly separated from any execution machinery, even in the prototype |
| [[principle-self-describing-system\|A2]] | The portal explains itself. From Phase 1, the shell includes contextual help and state explanations, however simple |
| [[principle-model-generates-everything\|A3]] | Directional commitment. The prototype may use hand-coded module definitions, but the architecture must not prevent future generation from SysML |
| [[concept-co-evolution\|J2]] | Build what we can see and use. Don't build infrastructure without a visible surface. Don't build UI without data to populate it |
| [[concept-non-constraining\|J3]] | The prototype architecture must not foreclose production evolution, third-party extensibility, or SysML model integration |
| [[principle-discipline-as-load-bearing-structure\|A9]] | Prototype does not mean sloppy. Clean code, clear boundaries, meaningful commits |

---

## 4. Technology Decisions

### 4.1 Application framework

**Decision: SvelteKit + Svelte 5 runes + Tailwind v4 + Flowbite Svelte.**

Same stack as the Ontara Console. Rationale:
- Proven in the project (13 console views built and maintained)
- Ella has working knowledge and paid licences (Tailwind UI, Flowbite Pro)
- SvelteKit's file-based routing and server-side capabilities are well-suited to a multi-page portal application
- Consistency across Ontara applications reduces cognitive load

### 4.2 Data persistence

**Decision: SQLite via better-sqlite3 (local development), with migration path to PostgreSQL.**

The portal needs user accounts, domains, modules, configurations, and lifecycle state. A relational database is the natural fit. SQLite keeps the prototype simple (no database server, single-file store, zero configuration) while the schema design targets PostgreSQL compatibility for production.

Alternative considered: JSON files. Rejected — lifecycle state, module relationships, and multi-user access need relational integrity even in a prototype.

### 4.3 Authentication

**Decision: Local username/password with session cookies for the prototype. Architecture supports future SSO/OAuth.**

The prototype needs user identity (to support multiple users and domains) but doesn't need production authentication. A simple local auth system with bcrypt password hashing and HTTP-only session cookies is sufficient. The auth boundary is cleanly separated so that SSO can replace it without touching the portal logic.

### 4.4 Repository location

**Decision: New directory `portal/` at the repo root, alongside `console/`.**

The portal is a separate application with its own `package.json`, dependencies, and dev server. It lives in the same repo as the console for ease of development, but is independently deployable.

### 4.5 Design approach

**Decision: Use the [[/mnt/skills/public/frontend-design/SKILL.md|frontend-design skill]] guidance and Flowbite Svelte components for a professional, polished UI from the outset.**

The portal is the first thing a user sees. Even in prototype, it should feel like a real product. Flowbite Svelte provides the component library; Tailwind provides the design system; the frontend-design skill provides the quality bar.

---

## 5. Phase 1 — The Empty Shell

**Objective:** A working portal application with user registration, login, domain creation, and an empty dashboard. The user can create an account, log in, create a domain, and see an empty dashboard for that domain. This is the portal shell — structured, stateful, and ready to receive modules.

**Estimated sessions:** 3–5

### Step 1.1: Project scaffold [Code]

- Initialise SvelteKit project in `portal/`
- Configure Tailwind v4, Flowbite Svelte, TypeScript
- Set up SQLite database with initial schema: `users`, `sessions`, `domains`, `domain_memberships`
- Create basic layout with navigation shell, header, sidebar placeholder

### Step 1.2: Authentication [Chat + Code]

- Design the auth flow: register, login, logout, session management
- Implement registration page with email, password, display name
- Implement login page with session cookie
- Implement auth middleware (protected routes)
- Implement user profile page (view and edit basic details)

### Step 1.3: Domain creation and management [Chat + Code]

- Design the domain creation flow: name, subdomain slug, domain type (business category)
- Implement domain creation wizard (simple, 2–3 steps)
- Implement domain listing for the user (their domains)
- Implement domain dashboard — empty but structured, with the domain name, type, creation date, and status ("Setup")
- Implement domain role: creator becomes super admin

### Step 1.4: Multi-domain, multi-user foundation [Chat + Code]

- Support a user having multiple domains
- Implement domain switching in the portal navigation
- Design the invitation/access model: super admin can invite users to a domain with a role
- Implement basic role assignment (super admin, member) — the role model will be extended later

### Phase 1 success criteria

1. A user can register, log in, and log out
2. A logged-in user can create one or more domains
3. Each domain has a dashboard page showing the domain in "Setup" status
4. A user can switch between their domains
5. The portal has a professional, polished appearance
6. The shell architecture is clean enough to receive modules (Phase 2) without restructuring

---

## 6. Phase 2 — Module Lifecycle

**Objective:** Implement the module catalogue and the full module lifecycle. The operator can browse available modules, install them into a domain, configure them, activate them, and manage their lifecycle states from the dashboard. Modules are shells — they have identity, configuration, and lifecycle state, but no internal business logic yet.

**Estimated sessions:** 4–7

### Step 2.1: Module data model [Chat + Code]

- Design the database schema for modules: `module_definitions` (catalogue), `module_instances` (installed in a domain), `module_state_history` (lifecycle transitions)
- Design the module lifecycle as intersecting state machines: installation lifecycle (available → installed → deleted/trashed) and operational lifecycle (edit → activated → paused → stopped → reset)
- Implement lifecycle transition validation — which transitions are legal from which state?

### Step 2.2: Module catalogue [Chat + Code]

- Create a set of prototype module definitions — 5–8 modules representing different business aspects (e.g. "Service Offerings", "Customer Management", "Scheduling", "Financial Tracking", "Governance Dashboard", "Analytics")
- These are hand-coded for the prototype; the catalogue will eventually be generated from the SysML model
- Each module definition has: name, description, category, icon, dependencies (other modules), BMM concern mapping
- Implement the catalogue browse page: filterable grid of available modules

### Step 2.3: Module installation and configuration [Chat + Code]

- Implement "Install" action from the catalogue → creates a module instance in the domain
- Implement module configuration page — a form or wizard specific to the module type (initially simple key-value configuration; the configuration surface will become richer as understanding grows)
- Module instance appears on the domain dashboard with status "Installed — Configuring"

### Step 2.4: Module lifecycle management [Chat + Code]

- Implement lifecycle state transitions from the dashboard: activate, pause, stop, reset
- Implement status indicators on the dashboard — each module shows its current lifecycle state with appropriate visual treatment (colour, icon, label)
- Implement lifecycle transition history — the module remembers its state transitions
- Implement the "trash" mechanism for deletion with recovery

### Step 2.5: Dashboard as state landscape [Chat + Code]

- Design and implement the domain dashboard as a state landscape: modules arrayed with their status indicators, grouped logically
- Implement module detail panel — click a module to see its configuration, lifecycle history, and available transitions
- The dashboard should feel like looking at a living system, not a static configuration page

### Phase 2 success criteria

1. A module catalogue exists with prototype module definitions
2. An operator can install a module from the catalogue into a domain
3. An installed module can be configured through a configuration surface
4. Module lifecycle transitions work correctly: edit → activate → pause → stop → reset
5. The dashboard shows all installed modules with their current lifecycle state
6. Lifecycle transition history is recorded and visible
7. The module lifecycle state machines enforce legal transitions

---

## 7. Phase 3 — Domain Context and Module Composition

**Objective:** Implement the shared domain context (structured along BMM concerns) and module wiring. Modules within a domain can share resources and connect to each other. The operator can see how modules relate and what they share.

**Estimated sessions:** 4–6

### Step 3.1: Domain context model [Chat + Code]

- Design and implement the shared domain context: a set of domain-level resources structured along the six BMM concerns (ServiceConcept, ActivityModel, ResourcePlanning, FinancialPlanning, GovernanceMapping, StakeholderModel)
- Each domain has a context that modules draw from and contribute to
- Implement a domain context page showing the current state of shared resources

### Step 3.2: Module wiring [Chat + Code]

- Implement the ability to connect modules to each other
- Design the wiring interface: which modules can connect, what the connection means, what data flows between them
- Implement a visual or structured representation of module connections on the dashboard
- Implement inter-module lifecycle constraints — if module A depends on module B, stopping B should warn about impact on A

### Step 3.3: Constructor-set composition [Chat + Code]

- Implement guided module composition: when the operator installs a new module, the system shows what shared context it will draw from, what new elements it adds, and which existing modules it naturally connects to
- Implement comprehension layer for composition: the portal explains what connecting modules means in business terms
- This is where the BMM-to-business-language translation becomes visible

### Phase 3 success criteria

1. Domains have a shared context structured along BMM concerns
2. Modules can be wired together with defined connections
3. Inter-module lifecycle constraints are enforced (with warnings/explanations)
4. The operator receives comprehensible guidance when composing modules
5. The dashboard shows module relationships, not just individual module states

---

## 8. Phase 4 — Simulation and Comparison

**Objective:** Enable comparative experimentation. The operator can create variant business module assemblies, feed them with generated data via generative modules, and compare results through analytical modules.

**Estimated sessions:** 5–8

### Step 4.1: Epistemic dimension [Chat + Code]

- Implement epistemic character for module instances: production, hypothesis, projection
- Implement the visual distinction on the dashboard between production and experimental instances
- Implement sibling module creation — "duplicate this module with different assumptions"

### Step 4.2: Generative modules [Chat + Code]

- Implement at least one generative module type that produces synthetic business activity (customers, transactions, events)
- The generative module has configurable parameters: rate, scenario distribution, environmental assumptions
- Generative modules wire to business modules and feed them data

### Step 4.3: Analytical modules [Chat + Code]

- Implement at least one analytical module type that consumes data from business modules and produces comparisons
- Basic metrics: activity volume, financial summary, constraint violation count
- Side-by-side comparison view for sibling business modules

### Step 4.4: Progressive fidelity [Chat + Code]

- Implement the ability to adjust simulation fidelity: simplified vs realistic assumptions
- Implement governance engagement dial — the operator can choose how much governance applies to a simulation
- The system explains what each fidelity level means

### Phase 4 success criteria

1. Operators can create sibling module variants for comparison
2. Generative modules produce synthetic data that feeds business modules
3. Analytical modules consume business module data and present comparisons
4. The dashboard visually distinguishes experimental from production instances
5. The operator can adjust simulation fidelity and governance engagement

---

## 9. Phase 5 — Governance and Promotion

**Objective:** Implement the promotion path from simulation to production, with progressive governance enforcement. This is where the three-way constraint hierarchy becomes user-facing.

**Estimated sessions:** 3–5

### Step 5.1: Governance integration [Chat + Code]

- Implement governance constraint display for modules: what constraints apply, which are satisfied, which are violated
- Implement the progressive governance experience: constraints are visible and informative in simulation, blocking in production
- Connect to the existing governance vocabulary where possible (HardConstraint, SoftConstraint, GradedRule)

### Step 5.2: Promotion path [Chat + Code]

- Implement the promotion operation: transition a module assembly from simulation to production status
- Implement promotion prerequisites: what must be true before promotion is allowed?
- Implement the promotion wizard: guide the operator through what changes (governance activation, data source transition, consequence boundary)

### Step 5.3: Production monitoring [Chat + Code]

- Implement basic production status monitoring: the dashboard shows production modules with live status indicators
- Implement governance compliance monitoring for production modules
- Implement the ability to revert a production module to simulation status (with appropriate warnings)

### Phase 5 success criteria

1. Governance constraints are visible and explained for all modules
2. The promotion path guides the operator through the simulation-to-production transition
3. Promotion enforces that required governance constraints are met
4. Production modules show live status and governance compliance
5. The operator can demote a production module back to simulation with appropriate safeguards

---

## 10. Phase Summary

| Phase | Focus | Key deliverable | Est. sessions |
|---|---|---|---|
| 1 | The Empty Shell | Working portal with auth, domains, and empty dashboard | 3–5 |
| 2 | Module Lifecycle | Module catalogue, installation, lifecycle management, status dashboard | 4–7 |
| 3 | Domain Context and Composition | Shared BMM context, module wiring, guided composition | 4–6 |
| 4 | Simulation and Comparison | Variant creation, generative/analytical modules, comparative dashboard | 5–8 |
| 5 | Governance and Promotion | Progressive governance, promotion path, production monitoring | 3–5 |
| **Total** | | | **19–31** |

---

## 11. Success Criteria

### Stage-level criteria

1. A working Ontara Portal application exists at `portal/` in the repo
2. Multiple users can create accounts, manage domains, and operate modules
3. The state-driven paradigm is the organising principle of the operator experience
4. Modules have lifecycle management with enforced state transitions
5. Modules compose within a domain through shared context and wiring
6. Comparative simulation is possible through sibling variants and analytical modules
7. The promotion path from simulation to production works with governance enforcement
8. The prototype is well-structured enough to evolve towards production
9. The experience of building the portal has generated architectural insights that feed back into the discussion paper and the broader Ontara architecture

### The learning criterion

Criterion 9 is the most important. This stage exists to learn. If we discover that the state-driven paradigm needs revision, that module composition works differently than expected, or that the relationship between the portal and the SysML model requires rethinking — those discoveries are successes, not failures.

---

## 12. Session Estimate

**Total: 19–31 sessions.** This is a wide range because the prototyping ethos means phases may expand or contract based on what we learn. Phase 1 is the most predictable (scaffolding). Phase 4 is the least predictable (simulation involves design questions that can only be resolved by building).

The stage could reasonably pause after any phase boundary and deliver standalone value. If the stage runs long, the learning from earlier phases justifies the investment even if later phases are deferred.

---

## 13. Risks and Mitigations

| # | Risk | Mitigation |
|---|---|---|
| R1 | **Scope creep.** The portal concept is rich and could expand indefinitely | Each phase has defined success criteria. Prototype ethos means "good enough for now" is a valid stopping point. Defer gracefully |
| R2 | **A3 connection unclear.** The relationship between SysML model and portal modules is directional but not implemented | Phase 2 uses hand-coded module definitions. The A3 connection is a design question explored throughout, not a Phase 1 prerequisite |
| R3 | **Two applications to maintain.** Portal and Console are separate SvelteKit apps with potential code duplication | Shared concerns (Tailwind config, component patterns, types) can be extracted if duplication becomes painful. Premature sharing is worse than some duplication |
| R4 | **Lifecycle complexity.** Multiple intersecting lifecycles (S174-CQ-3) may be harder to implement and present than anticipated | Start with the simplest workable lifecycle model in Phase 2. Decompose into intersecting lifecycles when experience shows the need |
| R5 | **Module composition is too abstract without real business logic.** Shell modules with no internal behaviour may not generate enough insight | The shell modules have *state* and *relationships* — enough to exercise the paradigm. Real business logic can be added incrementally once the shell is working |
| R6 | **Learning that the approach is fundamentally flawed.** The state-driven paradigm may not work as envisioned | This is explicitly an acceptable outcome (§11, learning criterion). Early discovery of fundamental issues is cheaper than late discovery. The architectural back-end (meta models, ontologies, console) remains valuable regardless |

---

## 14. Open Design Questions by Phase

These questions are expected to be resolved during the phase they are assigned to, through the process of building. They do not need to be answered before building begins.

### Phase 1

- What does the domain creation wizard look like? How does the operator specify their business type?
- What is the domain dashboard layout? How does it convey "empty but structured"?
- How does multi-domain navigation work in the portal shell?

### Phase 2

- What prototype module definitions should be in the catalogue? Which business aspects do they represent?
- What does the module configuration surface look like for different module types?
- How are the installation and operational lifecycles visually distinguished on the dashboard?

### Phase 3

- How is the shared domain context made visible and editable?
- What does module wiring look like in the UI? Drag-and-drop? Configuration form? Visual graph?
- How do inter-module lifecycle constraints present themselves? Blocking dialogs? Warnings? Dashboard indicators?

### Phase 4

- What synthetic data do generative modules produce? What parameters are meaningful?
- What metrics do analytical modules compute? What makes a useful comparison?
- How does progressive governance engagement work in the UI? A slider? Checkboxes? Presets?

### Phase 5

- What are the promotion prerequisites? What must be true?
- How does the promotion wizard guide the operator through the transition?
- What does production monitoring look like for the prototype?

---

## 15. Register Connections

| Register concept | Phase(s) | How exercised |
|---|---|---|
| [[principle-separation-representation-execution\|A1]] | All | Module configuration (representation) cleanly separated from lifecycle execution |
| [[principle-self-describing-system\|A2]] | All | Portal explains itself through contextual help and state explanations |
| [[principle-model-generates-everything\|A3]] | 2+ | Directional: prototype uses hand-coded modules; architecture supports future generation |
| [[principle-two-meta-model-distinction\|A4]] | 3+ | Shared domain context (BMM) distinct from module operational state (SMM) |
| [[principle-deterministic-over-probabilistic\|A6]] | 5 | Governance constraints follow deterministic evaluation in production mode |
| [[principle-discipline-as-load-bearing-structure\|A9]] | All | Clean code and meaningful structure even in prototype |
| [[principle-intrinsic-self-knowledge\|A10]] | 2+ | Status projections computed from live module state |
| [[concept-coordinate-framework\|A12]] | 4 | Epistemic dimension of module instances; variant comparison |
| [[concept-multi-tenancy\|A13]] | 1+ | Domain as operational expression of tenancy; multi-tenant from the start |
| [[concept-co-evolution\|J2]] | All | Build what we can see; no invisible infrastructure |
| [[concept-non-constraining\|J3]] | All | Prototype architecture must not foreclose production evolution |
| [[concept-operational-simulation\|L5]] | 4 | Module activation conceptually invokes L5 (initially simulated) |
| [[concept-coordinate-space-snapshots\|L8]] | 4 | Module epistemic character maps to snapshot types |

---

*Stage 8 plan created Session 174, 8 April 2026. Prototyping-led stage — build to learn, evolve towards production, refactor as understanding grows.*
