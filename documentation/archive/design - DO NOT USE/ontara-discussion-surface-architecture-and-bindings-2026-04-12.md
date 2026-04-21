---
tags:
  - discussion
  - architecture
date: 2026-04-12
status: working
session: 198
---
# The Operator Surface: Workspace, Agents, Modes, and Bindings

> `= this.file.path`

*Ontara Platform — Discussion Paper*

**Date:** 12 April 2026 (Session 198)
**Purpose:** To establish the architectural foundation for the operator surface in light of the Session 197 substrate paper, drawing on the Perplexity research on interface and interaction. This paper does for the surface side what the Session 197 paper did for the substrate side: it sets out the conceptual framing, names the first-class elements, and surfaces the open questions that Stage 9 planning will need to resolve. Together with the Session 197 paper it constitutes the architectural foundation from which the Stage 9 plan can be drawn.
**Status:** Working document — architectural foundation for Stage 9 (surface side).
**Depends on:** [[ontara-discussion-bs-substrate-and-bindings-2026-04-12|BS Substrate and Bindings]] (Session 197); [[ontara-discussion-architectural-clarification-2026-04-12|Architectural Clarification: Layers, Models, and Simulation]] (Session 196); [[ontara-discussion-connecting-the-stacks-2026-04-10|Connecting the Stacks]] (Sessions 192–193); [[ontara-discussion-portal-state-driven-operator-experience-2026-04-08|Portal: State-Driven Operator Experience]] (Session 174); [[ontara-research-(perplexity) - interface-and-interaction|Interface and Interaction (Perplexity research)]]

---

## Contents

- [[#1. Purpose and Scope|§1. Purpose and Scope]]
- [[#2. The Operator's Relationship to the Model|§2. The Operator's Relationship to the Model]]
- [[#3. The Three-Layer Interaction Model|§3. The Three-Layer Interaction Model]]
- [[#4. The Workspace|§4. The Workspace]]
- [[#5. Bounded Agent Roles|§5. Bounded Agent Roles]]
- [[#6. The Capability Matrix|§6. The Capability Matrix]]
- [[#7. Action Class Reframed Through Bindings|§7. Action Class Reframed Through Bindings]]
- [[#8. Ask, Plan, Simulate, Act|§8. Ask, Plan, Simulate, Act]]
- [[#9. Approval as a First-Class Interaction Primitive|§9. Approval as a First-Class Interaction Primitive]]
- [[#10. The Surface Reads the Substrate|§10. The Surface Reads the Substrate]]
- [[#11. The Stage 8 Portal in Light of This Paper|§11. The Stage 8 Portal in Light of This Paper]]
- [[#12. Implications for the Architecture|§12. Implications for the Architecture]]
- [[#13. Open Questions for Stage 9 Planning|§13. Open Questions for Stage 9 Planning]]
- [[#14. Register Connections|§14. Register Connections]]
- [[#15. Critique Observations and Watchpoints|§15. Critique Observations and Watchpoints]]
- [[#Related Documents|Related Documents]]

---

## 1. Purpose and Scope

The [[ontara-discussion-bs-substrate-and-bindings-2026-04-12|Session 197 substrate paper]] established what the BR and BS actually are as architectural constructs, what substrate they live in, and how they connect to the real and simulated components that realise them. It established the conceptual ground on which the dynamic side of the model can be built. What it deliberately did not address was how an operator perceives, interrogates, and acts on any of this — the surface side of the architecture.

This paper is the parallel treatment of the surface. It draws on the [[ontara-research-(perplexity) - interface-and-interaction|Perplexity research on interface and interaction]] (which itself emerged from a well-formed exchange about hybrid and intent-based interfaces, embedded AI agents, capability matrices, and approval-first execution), takes its central proposals as a starting framework, and folds in the Ontara-specific extensions that the substrate paper now makes possible — most importantly the binding-grounded reframing of what it means to "execute" something in an Ontara workspace.

The two papers together — substrate and surface — constitute the architectural foundation from which the Stage 9 plan can be drawn. Neither can stand alone. A substrate without a surface is invisible to the operator; a surface without a substrate is a UI over nothing. Stage 9's central engineering question is how to bring them into operational existence simultaneously.

### 1.1 What this paper is not

It is not a UI design document. It does not specify pixel layouts, Tailwind class choices, component decompositions, or visual hierarchies. The named panels and modes in this paper are architectural elements, not screens. A subsequent design pass — likely the work that immediately precedes Stage 9 Phase 1 implementation — will turn these elements into a concrete visual specification. The point of this paper is to make the architectural commitments explicit so that the visual specification, when it comes, has a foundation to rest on.

It is also not a portal redesign document. Although §11 considers the Stage 8 portal in light of this paper's framing, the purpose of that section is to identify the conceptual gap between the prototype and the architecture, not to issue instructions for portal modification. The portal is malleable prior art and will be reframed, in due course, by what this paper and the Session 197 paper jointly establish.

### 1.2 The relationship to the Perplexity research

The Perplexity research is heavily relied on in §§3–9. Where the source material is well-formed and Ontara-applicable as written, this paper adopts it largely intact and credits the source. Where Ontara's specific architectural commitments require a departure or extension, the departure is called out explicitly. The most significant of these is §7 (action class reframed through bindings), which takes the source material's risk-band classification of actions and grounds it in the binding registry from the Session 197 paper. That extension is the primary Ontara-specific contribution of this paper.

---

## 2. The Operator's Relationship to the Model

Before naming workspace elements, the question to settle is: what *is* the operator doing when they sit at an Ontara workspace? The answer shapes everything downstream.

In a conventional SaaS application the operator is doing data entry and inspection against a system whose model is implicit. They click forms, view dashboards, run reports, approve requests. The "model" of the business — what the business is, what its rules are, how its parts connect — exists in fragments scattered across screens, code, configuration, and the operator's own head. The operator's job is to navigate that fragmentation and produce coherent action.

In Ontara, by architectural commitment, the model is not implicit. It is a single, explicit, queryable, reasoning-tractable representation of what the business is and how its system runs. The BS holds the dynamic state of the system; BR holds the dynamic state of the business; bindings connect both to the components that realise them. The operator is not navigating fragmentation. The operator is sitting in front of a coherent dynamic model and asking it to reveal itself, evaluate itself, and act on its own elements.

This changes the operator's relationship to the surface. The surface is not a collection of forms over hidden tables. It is a workspace that lets the operator interrogate the model directly, propose changes to it, simulate the consequences of those changes, and authorise actions that the model knows how to carry out via its bindings. The surface is a *legible reading and writing surface for the model itself*.

This is the architectural premise of the paper. Everything that follows — the panel structure, the agent roles, the capability matrix, the four interaction modes, the approval primitive — is in service of making that premise operationally true.

### 2.1 Three audiences, one workspace

The operator surface serves three distinct kinds of user, and the architecture must hold all three without fragmenting into three different applications:

- **Ordinary operators** doing routine business work. They should not need to think about BR, BS, or bindings. They should see what is happening in their domain, be told what needs their attention, and have safe controls for the actions that fall within their scope. The model is invisible to them; what they see is the business and the system.
- **Power users — analysts and architects** doing model-grounded analysis. They need direct access to the model: query, inspection, dependency tracing, proposal drafting, simulation. They are interested in the model itself, not just its surface manifestations.
- **Superadmins and tenant administrators** doing operational control across scopes. They need the operator's situational view, the analyst's analytical access, and the additional authority to execute high-impact actions — subject to approval gates that they cannot bypass.

The workspace must let each audience occupy it without making the others' concerns intrusive. The architectural mechanism for this is **role-aware visibility on a shared substrate**: every panel, every agent, every action exists in the same workspace, but role determines which surfaces are visible and which controls are operable. The workspace is one architectural object with role-conditioned manifestations, not three different applications with shared branding.

### 2.2 GSL is a tenant, not a special case

[[concept-multi-tenancy|A13 (multi-tenancy)]] commits Ontara to treating every domain — including GSL — as a tenant instantiation against the platform. This applies to the surface as much as to the substrate. The operator workspace is platform infrastructure, parameterised by tenant context. GSL operators see GSL's BR, GSL's BS, GSL's modules, GSL's governance. Cafe operators see the cafe equivalents. The surface architecture is the same; the content is tenant-scoped.

This matters because it would be tempting, given GSL's role as the production tenant and motivating use case, to treat the GSL operator surface as a bespoke clinical application that happens to be built on Ontara. That would be wrong. GSL gets the same surface every other tenant gets — what makes it the production tenant is the depth of its configured model and the regulatory tier it operates under, not architectural privilege at the surface layer.

---

## 3. The Three-Layer Interaction Model

The cleanest way to organise the surface, drawing directly from the Perplexity research, is as three coordinated layers of interaction over the same underlying capabilities:

- **Operational layer** — graphical, task-focused, role-scoped. The surface most users live in most of the time. Domain navigation, module status, action queues, dashboards, approval flows. Built around direct manipulation of named domain objects (modules, cases, episodes, releases) rather than around model abstractions.
- **Expert layer** — query, inspection, model navigation. Available to roles that need direct access to the model: analysts, architects, tenant admins, superadmins, and (read-only) auditors. Includes the model map, the workflow graph, the query console, the binding registry, and the evidence trail.
- **Intent layer** — conversational, agent-mediated, mode-aware. Cuts across the operational and expert layers. The user expresses an intent in domain language; one or more agents interpret it, propose a structured plan, evaluate consequences, and (if authorised) execute or queue for approval. The intent layer is a *coordination surface*, not a separate UI.

The three layers are not three applications and not three tabs. They are three modes of access to the same substrate. A user doing operational work can drop into the expert layer to inspect why something happened; an analyst working in the expert layer can use the intent layer to draft a proposal; an admin doing approval work in the operational layer can use the intent layer to ask why a proposal exists. The layers describe the *kind* of interaction, not the location.

### 3.1 Why three rather than two or four

Two layers (operational and expert) is the conventional split — most enterprise applications already have it. The reason to recognise three is that the intent layer, mediated by agents, has a fundamentally different interaction shape from either of the other two. It is goal-oriented rather than action-oriented; it produces structured plans rather than immediate effects; it requires its own approval primitives because what it proposes is often outside the user's ordinary direct-control authority. Treating it as a special case of either of the other two layers loses the distinction that makes it valuable.

Four or more layers (e.g. splitting "executive dashboard" or "compliance review" into their own layers) over-fragments the architecture. Compliance review is operational work for auditors; executive dashboards are operational work for senior roles. Role-aware visibility on the operational layer handles them without needing dedicated layers.

### 3.2 The intent layer is grounded by the model

The intent layer is the most architecturally novel of the three, and the one most prone to going wrong if its grounding is left implicit. The grounding commitment is: **agents in the Ontara intent layer are constrained by model truth, not driven by prompt cleverness**. An agent does not improvise actions against unconstrained primitives. It operates over a known set of model-grounded capabilities, with known constraints, against a known scope, observed by the same governance vocabulary that observes human action. The richness of Ontara's existing model — BMM/SMM, governance ontology, reasoning metamodel, PROV-O provenance, binding registry — is what makes this grounding possible and what distinguishes the intent layer from a generic chatbot bolted onto a SaaS application.

This is what the Perplexity research means when it says Ontara is "in a better position than most teams to build an agent that is constrained by model truth". The position is real and should be cashed in deliberately.

---

## 4. The Workspace

The operator workspace is a single coordinated environment with a persistent scope, multiple work surfaces, and an ever-present intent layer. Concretely, it is composed of three regions:

- **A scope rail** — persistent, narrow, on the left. Holds the current tenant, domain, environment, and selected object; the navigation list; the action queue; quick actions.
- **A canvas** — the main work surface in the centre. Hosts the named work surfaces (Overview, Model Map, Workflow Graph, Simulation Lab, Governance Lens, Release Manager, Evidence Trail). All surfaces are bound to the same selected scope; switching surfaces does not change scope.
- **A dock** — on the right, collapsible. Holds Agent Studio (the intent layer's home), Impact & Diff, the Approval Drawer, and Evidence Peek.

The point of this structure is **contextual coherence**: a selection in any region propagates to the others. Picking a module in the scope rail filters the canvas to that module; picking a node in the workflow graph populates Agent Studio with a contextual question and Impact & Diff with the affected elements; opening an approval in the dock highlights the relevant graph node and model elements in the canvas. The workspace is one object whose parts maintain mutual awareness.

### 4.1 Named work surfaces

The canvas hosts seven named work surfaces. These are architectural elements, not just UI tabs — each one corresponds to a distinct kind of work and a distinct projection of the model.

| Surface | What it is | What it shows |
|---|---|---|
| **Overview** | The default landing surface. The state landscape for the selected scope. | Tenant/domain status, active modules and their lifecycle states, recent changes, top governance/risk items, what needs attention now. |
| **Model Map** | The expert-layer surface for model navigation and analysis. | Visual graph of BMM/SMM elements, configured BM/SM content, horizontal mappings, dependencies. Filters by concern, layer, change status. |
| **Workflow Graph** | The DAG/runtime view over Temporal-backed (and other) execution. | Workflow instances, their states, retries, waiting conditions, approval gates, critical path. Each node is bound to a model element and surfaces that binding. |
| **Simulation Lab** | The home for simulated instantiations of the BS. | Scenario builder, fidelity settings, run queue, comparative dashboard, outcome explanation. Simulation runs are the BS in synthetic-binding mode (per S197 §6.2). |
| **Governance Lens** | The policy and compliance surface. | Applicable constraints, obligations and prohibitions, evidence requirements, conflict detection, escalation paths. Hosts the Governance Sentinel agent's structured findings. |
| **Release Manager** | The promotion and rollout surface. | Candidate packages, validation summaries, diff summaries, environment routes, approval chains, rollback plans. Bridges the analyst's proposal to operational execution. |
| **Evidence Trail** | The audit and provenance surface. | Provenance graphs, approval history, agent action ledger, validation artefacts, reasoning traces. Where compliance and audit users live by default. |

These seven surfaces correspond to seven distinct kinds of work the operator might be doing. They are not the seven most important features; they are the seven distinct *modes of engagement* with the model. Adding an eighth would require identifying a new mode that none of these covers.

### 4.2 The binding registry as a sub-surface

The Session 197 paper opens the question (its §10.6 and §11 Q6, captured in OW-40) of whether the binding registry should be its own first-class surface — "which model elements have live infrastructure bound to them, with what freshness?". The position taken here is that the binding registry is a **sub-surface of Model Map**, not a separate top-level surface, for two reasons:

1. The bindings are a property of model elements. Looking at them in isolation from the elements they bind would be like looking at SQL foreign keys without the tables they connect. The natural home is the model surface.
2. Promoting the binding registry to a top-level surface would split the architect's attention between "the model" and "the model's bindings", when the architectural commitment is that bindings *are* model content.

The architect's view of "which model elements have live infrastructure bound" is therefore a Model Map view mode (toggle: show bindings; filter: show only bound elements) rather than a separate tab. The architect's view of "which workflows are running through which bindings" lives naturally in Workflow Graph, which already shows runtime nodes; nodes simply need to surface the binding metadata for the model element they realise.

This keeps the seven-surface structure stable while satisfying the Session 197 paper's requirement that the architect can see the binding registry. The sub-surface decision is open to revision if the binding registry turns out to need its own dedicated visual treatment.

### 4.3 The dock

The right-hand dock is the home of the intent layer and the approval primitive. It contains:

- **Agent Studio** — the conversational workspace where users interact with bounded agents in one of the four explicit modes (§8). Always visible by default; collapsible for users who prefer a wider canvas.
- **Impact & Diff** — the structured rendering of the consequences of a proposed plan or action: which model elements would be affected, which workflows would change, which governance rules apply, which approvals are required, which artefacts would be produced.
- **Approval Drawer** — the surface for approval-gated actions. Opens automatically when an action requires approval. Shows the action in human-readable form, the initiating user and acting agent, the scope, the risk classification, and the approve/reject controls. The drawer is the operational expression of approval as a first-class primitive (§9).
- **Evidence Peek** — a compact view of the most relevant provenance and validation artefacts for the current scope. A jumping-off point into the full Evidence Trail surface.

The dock is where the workspace becomes more than a dashboard. It is where the user moves from observation to authored action — and where the model's governance machinery surfaces to ensure that authored actions are scoped, justified, and inspectable.

---

## 5. Bounded Agent Roles

The single most important architectural commitment about agents in the Ontara workspace is that **there is no general super-agent**. There are several specialised agents, each with a narrow purpose, a defined permission ceiling, and a distinct identity for audit purposes. A user interacts with "an agent" through Agent Studio, but the back end routes the interaction to whichever specialised agent is appropriate for the current mode and intent.

This commitment exists because single-agent designs fail in regulated and multi-tenant contexts for predictable reasons: a single agent that can do anything is hard to audit, hard to scope, hard to delegate, and creates a single failure point both for hallucinations and for permission escalation. The Perplexity research argues this case from current enterprise agent governance practice; the position is adopted here without modification because it aligns directly with Ontara's existing commitments to separation of concerns, governance traceability, and bounded execution.

### 5.1 The agent roster

The initial roster, drawn from the Perplexity research and adapted to Ontara's existing module and governance vocabulary, is:

| Agent | Purpose | Default ceiling |
|---|---|---|
| **Ontara Guide** | General explanation, navigation, summarisation. The "what is this?" agent. Available to all users. | Read only. Cannot draft, simulate, or execute. |
| **Model Analyst** | Semantic and architectural explanation. Traces dependencies, generates impact previews, drafts proposed model edits. Speaks BMM/SMM/binding vocabulary. | Draft and simulate. No direct execution or publication. |
| **Query Copilot** | SQL and SPARQL drafting against safe scopes. Result explanation, follow-on suggestions. The expert-layer power tool. | Read and draft. No writes; no unbounded data export. |
| **Workflow Orchestrator** | Plans and (where authorised) initiates Temporal-backed and binding-realised actions. The agent that turns an approved plan into running infrastructure. | Execute low-risk; escalate high-risk. Cannot self-approve. |
| **Governance Sentinel** | Evaluates proposed actions against the governance vocabulary. Reports findings into the Governance Lens surface. The gatekeeper. | Read, simulate, and gate. Advisory plus blocking authority; no business changes. |
| **Release Steward** | Manages release candidates, environment promotion, rollback plans. The bridge from analyst proposal to operational publication. | Draft, simulate, propose execution. Cannot bypass approval thresholds. |

This roster is initial, not exhaustive. Additional bounded agents may be needed as Ontara's capabilities expand — e.g. a Tenant Operator agent for low-risk tenant-scoped automation, an Auditor Companion for compliance review workflows. The principle is that adding an agent requires identifying a distinct purpose, ceiling, and identity, not adding capabilities to an existing agent.

### 5.2 Why no agent has Approve as a first-class permission

A deliberate omission from the roster: no agent holds Approve as a default permission. The reason is that approval is the operator's exercise of authority. An agent that can approve can collapse separation of duties — the same agent could propose an action, simulate it, and then approve its own proposal. That is exactly the failure mode the bounded-agent design exists to prevent.

There may eventually be edge cases where an agent should be able to apply standing pre-authorisations on behalf of an approver (e.g. "automatically approve low-risk operational actions in the cafe demonstrator that have already been pre-authorised by class"). If those cases arise, they should be designed as **standing rule application**, not as agent approval authority — the rule itself is the approval; the agent applies the rule. This keeps the principle intact: agents do not exercise approval authority; humans do, and humans can encode their authority into rules.

### 5.3 The intersection rule for delegation

When a user invokes an agent to act on their behalf, the effective permission for the action is the **intersection** of:

1. The human user's role permissions for that action class in that scope.
2. The agent's role permissions for that action class.
3. The action's own policy classification (e.g. "high-risk actions always require approval, regardless of who initiates them").
4. The scope constraints (tenant, domain, environment, data sensitivity).

The intersection is restrictive, not permissive. If any one of the four says no, the action is not allowed. This is the standard agent-governance pattern recommended in current enterprise practice and adopted here without modification, because it directly prevents the most dangerous class of agent failure mode: the agent silently inheriting all of the user's authority and acting on it without supervision.

A consequence of the intersection rule: a Platform Superadmin asking the Ontara Guide a question gets only what the Ontara Guide is allowed to reveal — not "everything the superadmin could see by other means". Conversely, an Operator asking the Workflow Orchestrator to retry a failed run only gets execution if both the Operator's role and the Orchestrator's ceiling allow it for that specific scope and risk band. The intersection rule is the load-bearing safety property of the architecture and must not be relaxed for convenience.

---

## 6. The Capability Matrix

The capability matrix is the formal expression of who can do what to which kinds of model element under which conditions. It has four independent dimensions:

- **Human role** — who the user is
- **Agent role** — which specialised agent (if any) is acting
- **Action class** — what category of operation is being performed
- **Scope** — tenant, domain, environment, data sensitivity, lifecycle state

Effective permission is the intersection (per §5.3). The two matrices below — human-role × action-class and agent-role × action-class — are the starting point. They are necessary but not sufficient: scope and policy classification still apply on top of them.

### 6.1 Human roles

| Role | Typical scope | Notes |
|---|---|---|
| **Operator** | Single tenant/domain, routine operations | Inspects and runs low-risk bounded actions only |
| **Supervisor** | Tenant/domain plus team approvals | Adds approval rights for selected operational changes |
| **Analyst / Architect** | Model, query, simulation, design-time analysis | Strong read/draft/simulate; limited live execution |
| **Tenant Admin** | One tenant across environments | Tenant-scoped configuration and release authority subject to policy |
| **Platform Superadmin** | Cross-tenant / platform | Broadest operational scope; still bound by separation-of-duties controls |
| **Compliance / Auditor** | Read-only, evidence-focused | Inspects provenance, approvals, constraints, histories |

### 6.2 Action classes

| Class | Meaning | Examples |
|---|---|---|
| **Read** | Inspect state and artefacts | View model, workflow, evidence, dashboards |
| **Draft** | Propose without applying | Draft a query, change set, release plan, governance note |
| **Simulate** | Dry-run consequences | Workflow preview, validation run, impact preview, comparative simulation |
| **Approve** | Authorise a pending proposal | Release approval, override approval, governance sign-off |
| **Execute** | Apply or run in reality | Retry workflow, publish config, trigger promotion |
| **Override** | Exceptional bypass | Break-glass approval, emergency release, policy override |

### 6.3 Human role × action class

In the cells: **Y** = allowed by default; **C** = conditional, scoped, approval-gated, or environment-limited; **N** = not allowed by default.

| Role | Read | Draft | Simulate | Approve | Execute | Override |
|---|---|---|---|---|---|---|
| Operator | Y | C | C | N | C | N |
| Supervisor | Y | Y | C | C | C | N |
| Analyst / Architect | Y | Y | Y | N | C | N |
| Tenant Admin | Y | Y | Y | C | Y | C |
| Platform Superadmin | Y | Y | Y | Y | Y | C |
| Compliance / Auditor | Y | N | C | C | N | N |

### 6.4 Agent role × action class

| Agent | Read | Draft | Simulate | Approve | Execute | Override |
|---|---|---|---|---|---|---|
| Ontara Guide | Y | N | N | N | N | N |
| Model Analyst | Y | Y | Y | N | N | N |
| Query Copilot | Y | Y | C | N | N | N |
| Workflow Orchestrator | Y | Y | Y | N | C | N |
| Governance Sentinel | Y | Y | Y | N | N | N |
| Release Steward | Y | Y | Y | N | C | N |

No agent holds Approve as a default permission, for the reason in §5.2. No agent holds Override at all — Override is reserved for explicit human action with enhanced audit and justification requirements.

### 6.5 The matrices are not the policy

These matrices express *default ceilings*. The policy classification of any specific action — and especially the gating rules for high-impact actions — sits on top of the matrices, not within them. Policy says things like "any execution that touches a binding marked as production must require approval, regardless of role"; "any execution that crosses tenant boundaries must require Platform Superadmin approval and produce justification"; "any override must be accompanied by a written rationale and is automatically reviewed by compliance within 24 hours". The matrices set the floor; policy sets the ceiling for any specific case.

This is important because the matrices alone do not give Ontara what it needs. A Tenant Admin showing Y for Execute would, on the matrix alone, be permitted to execute anything in their tenant — but the policy layer is what ensures that "executing" a publication of a governance change still requires approval, even from a Tenant Admin. The two layers must always be read together.

---

## 7. Action Class Reframed Through Bindings

This is the principal Ontara-specific extension to the source material. The Perplexity research's action classes (Read / Draft / Simulate / Approve / Execute / Override) are useful as a starting taxonomy but they leave the *risk classification of an action* as an asserted property — "this action is high-risk". That assertion has to come from somewhere, and in the source material it comes from the policy layer making case-by-case judgments.

The Session 197 substrate paper opens a more architecturally honest path: an action's risk classification can be **computed** from the binding through which it would execute and the model element that binding realises.

### 7.1 What an action actually is, in Ontara terms

In a model-grounded system, an action is not an abstract verb. It is a structured operation with the following parts:

- **A target model element** — the part of BR or BS the action would affect
- **A binding** — the connection through which the effect would be realised on a real or simulated component
- **An operation** — what the action would do (start, stop, retry, modify, publish, promote, demote)
- **A scope** — which instantiation stratum (real, simulated, projected, counterfactual), which tenant, which environment

When the Workflow Orchestrator agent proposes "retry this workflow", what it actually proposes in structural terms is: against the BS model element of type `FulfilDrinkWorkflow` with instance ID `w-12345`, via the binding declared as `temporal://cafe-prod/fulfil-drink`, perform the operation `retry-from-failed-state`, in scope `tenant=cafe-demo, environment=staging, instantiation=real`.

Each of these four parts is model content. None of them is opaque. All of them can be inspected, reasoned about, and policy-checked.

### 7.2 Risk classification follows from the binding

Once an action is structured this way, its risk classification follows from properties already present in the binding declaration:

- **Instantiation mode**. An action against a *simulated* instantiation is fundamentally lower-risk than the same action against a *real* instantiation. A retry of a synthetic workflow run in Simulation Lab is routine; a retry of the same workflow against the real cafe Temporal cluster is operationally consequential. The binding declares the instantiation mode; the action class can therefore be computed differently against the same model element depending on which instantiation it targets.
- **Freshness/fidelity profile**. A binding with sub-second freshness against a Temporal subscription is operationally tight; an action against it has well-understood consequences. A binding with weak freshness or inferential observation is loose; actions against it carry higher uncertainty about what is actually happening on the other side. The risk classification can reflect that.
- **Production marker**. The Stage 8 portal already implements the distinction between exploratory, advisory, and enforced governance modes. The binding can carry an analogous production marker — a binding declared as production-bound is one whose actions affect actual operating systems; one declared as design-bound is for development or scenario work. Production markers automatically escalate the risk classification of actions that touch them.
- **Authority zone of the affected element**. From [[concept-authority-zones|B29]]: some model elements are SysML-authoritative, some are OWL-authoritative, some are shared-constrained. An action that proposes to modify an OWL-authoritative element via a SysML edit is structurally suspect and should be flagged regardless of role. An action confined to its element's authority zone is structurally straightforward.

These four properties give a model-grounded basis for the risk classification of any action, computable at the moment the action is structured rather than asserted by case-by-case policy judgment. Policy still has the final word — the matrices in §6 set role ceilings, and policy can always escalate further — but the *default* classification of an action is no longer an arbitrary assertion. It is a property of the binding.

### 7.3 Why this matters

This reframing has three architectural benefits:

1. **It closes the loop with the substrate paper.** The Session 197 paper's binding registry is not just a place where the architect can see what is connected to what. It is the operational substrate from which surface-level risk classifications are computed. Bindings become the load-bearing element for both architectural explanation and governance enforcement.
2. **It makes the surface honest about its grounding.** When a user clicks "Run" and the action is high-risk, the workspace can say *why* — not just "this is high-risk" but "this is high-risk because the binding `temporal://cafe-prod/fulfil-drink` is production-bound and the operation `retry-from-failed-state` modifies live workflow state". The justification is structural, not asserted.
3. **It scales without re-classification work.** Adding a new module or a new domain or a new tenant does not require re-classifying every possible action by hand. New bindings are declared with their properties; risk classifications follow automatically.

The price is that the binding declaration vocabulary (the open question Q1 in the Session 197 paper) must be designed with the four properties above in mind. Risk classification by binding is only as honest as the binding metadata is complete. If a binding is declared without an instantiation mode, or without a freshness profile, the surface cannot compute its risk classification correctly. The vocabulary design is therefore a load-bearing dependency for this approach.

### 7.4 The matrix is unchanged; the policy layer becomes computable

The capability matrices in §6 remain exactly as stated. What changes is how the policy layer turns "Conditional" into a yes-or-no decision for any specific action. Without the binding-grounded reframing, "conditional" means "ask a policy expert"; with it, "conditional" means "compute from the binding metadata, fall back to explicit policy where the metadata is insufficient or the action is exceptional". The matrix is the floor; the binding-grounded computation is the everyday default; explicit policy is the override.

---

## 8. Ask, Plan, Simulate, Act

Agent Studio operates in one of four explicit modes. The mode is always visible in the Agent Studio header, alongside the active human role, active agent, current scope, and risk band. The user knows, at every moment, what kind of interaction they are in.

### 8.1 Ask

**Purpose.** Read-only explanation, navigation, and summarisation.

**What it can do.** Answer questions about the current scope, explain model elements, show dependencies, surface evidence, summarise state, suggest next actions.

**What it cannot do.** Write anything. Modify anything. Initiate any execution. Even drafting is outside Ask mode — drafting requires Plan mode.

**Default agent.** Ontara Guide. Other agents (Model Analyst, Governance Sentinel) may also operate in Ask mode for explanation purposes within their domain.

**Available to.** All users. Ask is the default mode and the safest surface.

### 8.2 Plan

**Purpose.** Create a structured, reviewable proposal without applying it.

**What it can do.** Take a natural-language intent, structure it as a plan, identify the affected model elements, compute the risk classification, identify the required approvals, surface the policy implications, generate the Impact & Diff rendering.

**What it cannot do.** Execute. Simulate (that's the next mode). Apply changes to BR or BS. The plan is a proposal that exists in a draft state until either discarded, sent to simulation, or submitted for execution/approval.

**Default agent.** Model Analyst for model changes; Workflow Orchestrator for operational actions; Release Steward for promotions; Governance Sentinel for governance changes. Multiple agents may collaborate on a single plan.

**Output structure.** Every Plan-mode output is a structured artefact with: intent statement, affected model elements, required operations, binding-grounded risk classification, policy gating, approval requirement, expected artefacts, rollback or compensation note. Plans are first-class entities — they can be saved, refined, compared, and submitted.

**Available to.** Most roles, with scope restrictions. Operators get bounded local plans; analysts and admins get richer scope.

### 8.3 Simulate

**Purpose.** Dry-run a plan or operation against a synthetic instantiation of the BS, observing consequences without affecting reality.

**What it can do.** Take a Plan-mode artefact (or a selected workflow or a selected model delta), instantiate it in the Simulation Lab against synthetic-generator bindings, run the resulting state evolution, and produce comparative outputs against the current real instantiation.

**What it cannot do.** Affect the real instantiation. Modify production state. Generate external side effects. Simulation runs are entirely contained within their own named graph in the KG (per the Session 197 paper's §5.2 point 3 on multiple instantiation modes).

**Default agent.** Workflow Orchestrator running against synthetic bindings; Model Analyst comparing simulated outputs; Governance Sentinel evaluating simulated trajectories against constraints.

**Output structure.** Simulated path, expected state transitions, projected metrics, validation results, policy issues, confidence and uncertainty markers. Simulation results can be packaged into approval artefacts for subsequent execution.

**Available to.** Operators get sanctioned scenario templates; analysts and admins get full simulation authoring; auditors get read-only access to simulation results.

### 8.4 Act

**Purpose.** Effect a real change against a real instantiation of the BS.

**What it can do.** Invoke the operation declared in a reviewed and authorised plan, against the binding declared in that plan, against the model element declared in that plan, in the scope declared in that plan. Stream the resulting state changes back into the workspace (the Workflow Graph surface focuses on the new run; Evidence Trail records the action chain).

**What it cannot do.** Improvise. Act mode does not interpret a fresh natural-language request and execute it directly. Every Act-mode invocation is the execution of an already-structured plan that has cleared its policy gates and (where required) its approval gates. The progression is always Ask → Plan → (optionally Simulate) → Act, with explicit transitions between modes. Skipping Plan is impossible.

**Default agent.** Workflow Orchestrator. Release Steward for promotions.

**Output structure.** Action invocation record, exact tool/binding/operation called, scope, approval reference, execution result or pending state, evidence link.

**Available to.** Strongly role-filtered. Operators see Act only for low-risk pre-classified actions (e.g. retry a failed local run within their tenant). Tenant admins and superadmins see broader Act controls. No role sees an "override" button by default — override is a separate, exceptional path with its own audit and justification requirements.

### 8.5 Why mode visibility is non-negotiable

The user must always know which mode they are in. Confusion between modes is the failure mode that produces "I thought I was just exploring, I didn't know it would actually do that". The architectural commitment is that the mode is always rendered in the Agent Studio header in a way that is impossible to miss; that mode transitions are explicit user actions, not silent state changes; and that any agent response that proposes a transition (e.g. "I can do that — switch to Plan mode?") requires the user's confirmation rather than auto-promoting.

This is the surface-side instance of [[principle-self-describing-system|A2 (self-describing system)]]: the workspace knows what kind of interaction is in progress, and it makes that knowledge available to the user at all times.

---

## 9. Approval as a First-Class Interaction Primitive

In conventional applications, approval is a bolt-on: an email goes out, a manager clicks a link, a database flag flips. The approval and the action it authorises are loosely coupled, often unauditable, and frequently invisible to the system that must enforce them.

In Ontara, approval is a first-class interaction primitive. An approval is a structured artefact in its own right, with its own lifecycle, its own provenance, its own audit trail, and its own surface. The Approval Drawer in the right-hand dock is the operational expression of this commitment.

### 9.1 What an approval artefact contains

Every approval-required action produces an approval artefact with the following fields:

- **Action title** in plain English ("Promote the Cafe domain governance configuration to enforced mode in production")
- **Initiating user** — the human who started the chain
- **Acting agent** — which bounded agent (if any) is mediating
- **Exact structured operation** — target model element, binding, operation, scope (per §7.1)
- **Risk classification** — computed from the binding (per §7.2), with the basis shown
- **Affected elements** — Impact & Diff rendering of what would change
- **Policy classification** — what gating rules apply and why
- **Approval chain** — who must approve, in what order, and on what timescale
- **Justification** — the initiator's stated reason (mandatory for high-impact actions)
- **Expected artefacts** — what will exist after execution
- **Rollback or compensation plan** — what would be done if the action needs to be undone

The artefact is constructed at the moment a Plan-mode plan is submitted for execution (or for approval in advance of execution). It is the unit of approval — not the chat exchange that produced the plan, not the agent's reasoning trace, but the structured object itself. Approvers see the artefact, not the conversation.

### 9.2 The approval lifecycle

An approval artefact moves through a small set of states:

- **Pending** — created and awaiting approver action
- **Approved** — all required approvers have signed off; ready for execution
- **Rejected** — at least one required approver has declined; the artefact is closed and the initiator is informed with the rejection reason
- **Withdrawn** — the initiator has retracted the request before approval completed
- **Executed** — the approved action has been carried out and the result is recorded
- **Expired** — the approval timed out without completing

Lifecycle transitions are events recorded in the BS substrate, with full PROV-O provenance. An auditor reading the Evidence Trail surface six months later can reconstruct exactly what was proposed, who saw it, who approved it, who executed it, and what the result was.

### 9.3 Approval as separation of duties

The approval primitive exists in part to enforce **separation of duties** — the principle that the same actor should not both propose and authorise high-impact actions. The intersection rule for delegation (§5.3) prevents agents from collapsing this separation; the approval primitive prevents humans from collapsing it through tool use. A Tenant Admin who drafts a release plan in Plan mode cannot simply hit Act and execute it for production scope; the action's policy classification (per §6.5) requires an approval, and the Tenant Admin's own approval is not sufficient — the approval chain must include at least one independent reviewer for actions of that classification.

This is consistent with established enterprise agent governance practice and with Ontara's existing commitment to governance traceability ([[principle-clinical-governance-first-class|A8]]). The approval primitive is not a UI feature; it is the operational expression of separation of duties at the surface layer.

### 9.4 The plan/verify pattern

A useful pattern that emerges from putting Plan, Simulate, and Approval together is what can be called **plan/verify**. The flow is:

1. User expresses intent in Plan mode.
2. Agent (typically Model Analyst or Workflow Orchestrator) drafts the structured plan.
3. Governance Sentinel automatically reviews the plan against applicable constraints and reports findings into Governance Lens.
4. If the plan is policy-compliant and within the user's authority, it can move to Act directly (low-risk path).
5. If the plan requires approval, it is packaged as an approval artefact and sent to the Approval Drawer.
6. Optionally, Simulate is run between Plan and Act/Approval to verify expected consequences against the synthetic instantiation. Simulation results can be attached to the approval artefact as supporting evidence.
7. Approval (if required) is granted; Act mode invokes the approved action; Workflow Graph streams the resulting state changes; Evidence Trail records the chain.

The plan/verify pattern is not a single named feature — it is what the workspace naturally produces when Plan, Simulate, Act, and Approval are first-class interaction primitives. It happens to align very well with regulated-care expectations about how operational decisions should be made and recorded.

---

## 10. The Surface Reads the Substrate

The Session 197 substrate paper established BR, BS, bindings, mapping rules, and the substrate boundary between the KG and specialised stores. This section traces how the surface architecture reads from and acts on that substrate.

### 10.1 What the surface reads

The seven canvas surfaces and the four dock panels read from the BS substrate via well-defined query patterns:

- **Overview** reads the current state of BR (business facts: today's revenue, pending cases, alert counts) and BS (system facts: active workflow instances, queue depths, blocked operations). The state landscape is the joint rendering of both, scoped to the selected tenant and domain, in their real instantiation by default.
- **Model Map** reads the static aspect of BM and SM (the configured model) and overlays the dynamic aspect (which elements have live bindings, which elements have pending changes, which elements are flagged by Governance Sentinel). The model map is a rendering of the model in both its static and dynamic aspects simultaneously.
- **Workflow Graph** reads the BS in its real instantiation (workflow instances, states, retries, waiting conditions) and the binding metadata for each node (which Temporal cluster, which freshness profile, which model element this node realises).
- **Simulation Lab** reads BS in synthetic instantiations (named graphs in the [[concept-knowledge-graph|knowledge graph]] containing simulation runs) and presents comparison views against the real instantiation.
- **Governance Lens** reads the governance vocabulary (constraints, obligations, prohibitions) and the current evaluation state of each constraint against BR and BS. Constraint failures and evidence gaps are first-class items here.
- **Release Manager** reads the static aspect of BM and SM (the proposed configurations being released), the validation results, and the routes between environments.
- **Evidence Trail** reads the PROV-O provenance graph in the KG, including the action ledger of every Plan / Simulate / Act / Approval event recorded by the workspace itself.
- **Agent Studio** does not have its own data substrate beyond conversation state; its outputs are structured plans and queries that read from and write proposals against the substrate.
- **Impact & Diff** reads the BM/SM static aspect and the proposed changes from the current Plan-mode artefact, computing differences.
- **Approval Drawer** reads the approval artefact lifecycle from the BS substrate.
- **Evidence Peek** reads a scoped subset of what Evidence Trail shows.

All of these are queries against the same KG-resident substrate. The surface does not maintain its own duplicate state; it reads from BR and BS in their respective KG strata. This is the surface-side application of the Session 197 paper's commitment that BR and BS live in the KG.

### 10.2 What the surface writes

The surface does not write to BR or BS directly — that would violate the observational binding pattern (S197 §7). What the surface writes is:

- **Plans** — structured proposals authored in Plan mode, stored as draft artefacts. Plans are not yet actions; they are designs for actions.
- **Approval artefacts** — generated when a plan is submitted for approval. Live in the BS substrate as first-class entities with their own lifecycle.
- **Action invocations** — when Act mode fires, an action invocation is dispatched through the binding to the realising component. The component then operates and emits events; the BS observes those events and updates accordingly. The surface's write to the substrate is *the action invocation record*, not the resulting state — the resulting state arrives through the binding pipeline like every other observation.
- **Workspace state** — selections, opened panels, scope changes, conversation history. This is workspace metadata, not model content; it lives in the workspace's own session state and does not enter BR or BS.

The architectural commitment is that **the surface initiates, the components execute, the bindings observe, the substrate updates**. The surface never bypasses this loop. When a user clicks "Run", a structured action invocation is recorded, the binding is invoked, the realising component does its work, the observation comes back, BR and BS update, and the surface re-reads. This is the same loop whether the binding is real (Temporal subscription) or synthetic (generator in Simulation Lab) — only the binding type differs.

### 10.3 Freshness propagation into the surface

A consequence of bindings carrying freshness/fidelity profiles (S197 §6.3) is that the surface can — and should — render freshness as a visible property of what it shows. A revenue figure displayed in Overview is not just "£412 today"; it is "£412 today, last updated 3 seconds ago via the Temporal subscription binding". A workflow node is not just "In Progress"; it is "In Progress as of last poll 47 seconds ago". A clinical observation read through an EHR binding is not just "BP 140/85"; it is "BP 140/85, observed 14 minutes ago, polled freshness". The surface tells the user what it knows and how recently it knew it.

This is the surface-side application of [[principle-self-describing-system|A2]] and [[principle-intrinsic-self-knowledge|A10]] at the boundary between the model and the operator's perception. The system knows what it knows; the surface makes that knowledge visible. An operator who is confused about why a number doesn't match what they see on the floor should be able to look at the freshness annotation and understand that the workspace is two minutes behind reality, rather than concluding that the workspace is wrong.

### 10.4 Mode visibility and substrate context

The Agent Studio mode (Ask / Plan / Simulate / Act) is closely tied to the substrate operation it performs:

- **Ask** is read-only against the substrate.
- **Plan** writes draft artefacts to a designated draft area of the substrate but does not affect BR or BS.
- **Simulate** writes to a simulation-named-graph in the substrate, isolated from real instantiation.
- **Act** records action invocations in the substrate and waits for observed effects to flow back.

Making mode visible therefore makes the user's relationship to the substrate visible. The header of Agent Studio is, in effect, an indicator of what part of the substrate is currently being operated on — which is exactly the kind of self-description Ontara's principles commit to.

---

## 11. The Stage 8 Portal in Light of This Paper

The Stage 8 portal (S175–185) is an existing partial prototype of the operator surface. It was built before the substrate paper and before this paper, and it predates several of the architectural commitments now in place. This section identifies the gap between what the portal does and what the surface architecture established here would require, treating the portal as malleable prior art.

### 11.1 What the portal already does that aligns

Several aspects of the portal map directly onto elements of this paper:

- **State-driven dashboard.** The portal's dashboard-as-state-landscape concept anticipates the Overview surface in §4.1. The portal already renders the current operational state of a domain in a way that lets the operator see what is happening at a glance.
- **Module composition with lifecycle states.** The portal's two intersecting lifecycle state machines (installation and operational) and the schema-driven configuration pattern correspond to a partial implementation of the operational layer (§3) over a portal-internal substrate. The architectural shape is right; the substrate is wrong (per §11.2).
- **Progressive governance.** The portal's exploratory / advisory / enforced governance modes correspond conceptually to the production marker on bindings (§7.2). The portal already has the discipline of distinguishing modes where governance is advisory from modes where it is enforcing; this paper generalises that discipline to the binding registry.
- **Promotion path with prerequisite gating.** The portal's promotion wizard, with five prerequisites and re-evaluation on submit, is a partial implementation of the plan/verify pattern in §9.4 and the approval primitive in §9. The architectural intuition is right; what's missing is the structured approval artefact and the binding-grounded risk classification.
- **Comparative simulation.** The portal's comparative dashboard with simulation runs anticipates Simulation Lab (§4.1, §8.3). The architectural shape is right; the substrate is wrong (the simulation events come from random distributions in SQLite, not from synthetic-generator bindings against an instance of the BS).

### 11.2 What the portal does not yet do that this paper would require

The principal gap is **substrate**: the portal's data is in SQLite, hand-seeded, internally consistent but disconnected from the model. The surface architecture in this paper assumes a substrate of BR and BS in the knowledge graph (per the Session 197 paper). The portal as it stands does not read from BR or BS; it reads from its own SQLite tables. This is the foundational change required to make the portal architecturally honest. It is not a small change.

Subsidiary gaps:

- **The module catalogue is hand-seeded.** [[ontara-ref-work-items|OW-32]] flags this; S192-D7 commits to deriving the module catalogue from the SysML model. The portal's modules speak BMM concept names but are not connected to the BMM. Until the connection is made, every portal feature built on the catalogue is built on a foundation that will need to change.
- **There is no Agent Studio.** The portal has no intent-layer surface. All interaction is through forms and direct UI manipulation. This is the largest UI surface area still to be added.
- **There is no Model Map.** The portal has no model-navigation surface. Power-user analysis happens (where it happens at all) in the Ontara Console, which is a separate application. This paper's architecture would require either bringing Model Map into the portal or formally acknowledging that the workspace spans two applications and designing the integration accordingly.
- **There is no Workflow Graph.** The portal has no DAG/runtime view. Workflow execution happens (in the cafe demonstrator) in a separate stack with no portal visibility.
- **There is no binding registry.** Bindings as a first-class concept do not exist in the portal yet. They cannot, until the binding declaration vocabulary (S197 Q1) is designed.
- **The approval primitive is partial.** The promotion wizard is approval-shaped but there is no general approval artefact, no general approval drawer, no approval lifecycle outside the promotion path.
- **There is no Evidence Trail.** PROV-O provenance is in the KG for the BMM/SMM static side, but there is no surface in the portal for reading it.

### 11.3 What this means for the portal

The portal is not a wasted effort. It established several architectural intuitions that this paper validates: state-driven dashboards, lifecycle composition, progressive governance, prerequisite-gated promotion, comparative simulation, schema-driven configuration. These are real contributions and the patterns survive into the architecture this paper sketches.

What the portal needs to become, in light of this paper and the Session 197 substrate paper, is **the [[domain-cafe|cafe demonstrator]] instance of a much larger workspace concept** — not a complete operator surface in itself, but a partial realisation that will be reframed and extended substantially when the surface architecture is implemented. The reframing is not a rebuild from scratch; it is a substrate replacement (SQLite → KG-resident BR/BS), an architectural extension (adding the missing surfaces and the agent layer), and a conceptual generalisation (treating the portal not as the portal but as one tenant's view of a platform-wide workspace).

This reframing is large enough that it should not be undertaken as a single Stage 9 phase. The Stage 9 plan, when it is drawn, should sequence the substrate changes, the workspace extensions, and the agent layer carefully — likely with several concrete proving grounds (the cafe is the obvious first; the binding registry and the substrate connection come next; the agent layer comes after the substrate is real).

### 11.4 The portal is not a constraint on the architecture

Worth restating: the portal is malleable prior art, not a fixed input. Where this paper's architecture and the portal's existing implementation disagree, the architecture wins. The portal will be reframed. This is consistent with Ontara's prototyping-led methodology and with the architectural commitments that the substrate and surface papers jointly establish. Stage 8 was a hugely valuable rapid prototype; Stage 9 is when the prototype meets the architecture, and the architecture is the stable thing.

---

## 12. Implications for the Architecture

The position taken in this paper has several consequences that should be carried forward into Stage 9 planning and into the master register.

### 12.1 The intent layer is a third architectural layer alongside the operational and expert layers

The three-layer interaction model (§3) is not a UI convention. It is an architectural distinction in the kind of interaction the workspace supports. Treating the intent layer as architecturally distinct from the operational and expert layers is necessary because it has different properties (goal-oriented, mode-aware, agent-mediated, approval-gated) from either of the others. Stage 9 design should treat the three layers as separable concerns even when they share visible UI real estate.

### 12.2 Bounded agents are a first-class architectural element

The agent roster in §5 is not a list of features. It is a structural commitment to bounded agency as the design pattern for AI mediation in the workspace. Each agent has a distinct identity, ceiling, and audit profile. Stage 9 design should treat each agent as a separate architectural element with its own permissions, its own access patterns to the substrate, and its own contribution to the action ledger in Evidence Trail.

### 12.3 The capability matrix and the binding-grounded risk classification together replace ad hoc permission logic

The combination of the matrices in §6 and the binding-grounded action class in §7 gives Ontara a model-grounded, computable, inspectable basis for who can do what. This replaces what would otherwise be ad hoc permission logic scattered across the workspace. Stage 9 design should treat the capability matrix as a first-class part of the platform model — not as a configuration file or a hardcoded ruleset, but as model content that the platform itself reasons about.

### 12.4 Approval is a first-class entity in the substrate

Approval artefacts (§9.1) are first-class entities with their own lifecycle, stored in the BS substrate, with full PROV-O provenance. Stage 9 design should add approval to the master register as a structural concept and add the approval lifecycle to the BMM (or to a platform-level vocabulary, if approval is treated as cross-cutting).

### 12.5 The plan/verify pattern is a validated workspace pattern

The plan/verify pattern (§9.4) emerges naturally from the four-mode design and the approval primitive. It should be added to the PatternCatalogue as a validated workspace pattern, distinct from existing patterns like two-layer action flow or XState-in-Temporal because it operates at the human-system interaction level rather than at the workflow execution level.

### 12.6 The Stage 8 portal is reframed

The portal becomes one tenant's partial workspace instance, not the operator surface. Stage 9 design should plan for the substrate change, the workspace extensions, and the agent layer in sequence, not all at once.

### 12.7 The L5–L9 cluster gets a surface-side counterpart

The Session 197 paper sharpened the L5–L9 simulation cluster on the substrate side. This paper adds a surface-side counterpart:

- [[concept-operational-simulation|L5 (operational simulation)]] is rendered in the Workflow Graph and Overview surfaces.
- [[concept-reflective-simulation|L6 (reflective simulation)]] is the source of structured findings displayed across Governance Lens, Impact & Diff, and Agent Studio.
- [[concept-valence|L7 (valence)]] shapes how comparative results are evaluated and displayed in Simulation Lab.
- [[concept-coordinate-space-snapshots|L8 (coordinate space snapshots)]] underpins the comparison between current and projected state.
- [[concept-goal-seeking-computation|L9 (goal-seeking computation)]] is what the Workflow Orchestrator agent invokes when the user asks for a path toward a goal in Plan mode.

The unity is that the surface is not separate from the simulation cluster; it is the cluster's expression to the operator.

---

## 13. Open Questions for Stage 9 Planning

The following questions remain for Stage 9 design and are not resolved by this paper:

**Q1.** What is the schema of an approval artefact? What properties must it carry beyond those listed in §9.1, and how is the approval chain (multi-approver, sequential vs parallel) structured?

**Q2.** Where exactly in the workspace does Model Map live, given that the existing Ontara Console already has model navigation views? Two options: bring model navigation into the portal (single workspace, two applications collapsed); keep the console as the analyst's model surface and define the integration with the portal precisely (two applications, designed coordination). The trade-offs are not yet examined.

**Q3.** How is the workspace integrated with existing applications during transition? The portal is one application, the console is another, the cafe demonstrator is a third. The architecture envisions a single workspace; the reality is several. What is the integration sequence and what does each step prove?

**Q4.** What does the binding registry sub-surface in Model Map look like? §4.2 commits to it being a sub-surface rather than a top-level tab, but the visual treatment, the filter and view modes, and the relationship to the existing model graph are not specified.

**Q5.** What is the agent instantiation model? Is each bounded agent a separate process? A separate model deployment? Different system prompts against the same underlying model? The choice has implications for cost, latency, audit, and the strength of the boundary between agents.

**Q6.** How are the four interaction modes (Ask / Plan / Simulate / Act) presented to roles for whom not all modes are accessible? An Auditor in particular has Ask access but limited or no access to the others. Is the mode switcher hidden, visible-but-disabled, or visible-with-explanation?

**Q7.** What does the approval chain look like for cross-tenant actions? Such actions are rare and should be — but when they happen, who approves and how is the chain structured to prevent any single role from authorising cross-tenant work alone?

**Q8.** How does the surface handle simulation runs that affect the binding registry itself (e.g. "what if we changed the freshness profile of this binding to polling-every-30-seconds?")? These are meta-simulations against the binding metadata; the architectural treatment is not specified here.

**Q9.** What is the relationship between Ontara's bounded agents and the underlying model providers (Anthropic, etc.)? Is each bounded agent a wrapped LLM call with a specific system prompt, or something more elaborate? The architectural answer affects how the agents are versioned, audited, and updated.

**Q10.** How is workspace state (selections, opened panels, conversation history) persisted, scoped, and audited? It is not BR or BS content, but it has provenance value (for understanding what the user was looking at when they made a decision) and privacy implications (for understanding what data the workspace has displayed to whom).

---

## 14. Register Connections

### 14.1 Principles directly engaged

| Principle | Engagement |
|---|---|
| [[principle-separation-representation-execution\|A1]] | The surface initiates and the components execute; the surface never bypasses the binding/substrate loop. Plan/Simulate/Act enforce this separation explicitly at the interaction level. |
| [[principle-self-describing-system\|A2]] | Mode visibility (§8.5), freshness propagation (§10.3), the binding-grounded action class (§7), and the structured approval artefact (§9.1) are all surface-level applications of A2. |
| [[principle-model-generates-everything\|A3]] | The workspace itself, the agent ceilings, the capability matrices, and the binding-grounded action classifications are all model content rather than hardcoded UI logic. The architectural commitment is that the workspace is generated from the model in the same sense that the running system is. |
| [[principle-two-meta-model-distinction\|A4]] | Overview shows BR and BS facts side by side, making the dual stack visible at the operator surface. The surface honours the architectural distinction the substrate paper sharpens. |
| [[principle-clinical-governance-first-class\|A8]] | Approval as a first-class primitive (§9), the Governance Sentinel agent (§5.1), and the Governance Lens surface (§4.1) make governance structural at the surface, not bolted on. |
| [[principle-discipline-as-load-bearing-structure\|A9]] | Bounded agents, the intersection rule for delegation, mode visibility, and approval as a first-class primitive are disciplined working practices propagated to the operator's experience. |
| [[principle-intrinsic-self-knowledge\|A10]] | Freshness annotations (§10.3), action class derivation from binding metadata (§7.2), and the binding registry sub-surface (§4.2) are surface-level applications of A10. |
| [[principle-unity-principle\|A11]] | The same model, the same governance vocabulary, the same bindings, the same provenance graph serve all seven canvas surfaces and all four agent modes. There is no separate knowledge structure for the surface. |
| [[concept-multi-tenancy\|A13]] | The workspace is platform infrastructure parameterised by tenant context (§2.2). GSL gets the same workspace every other tenant gets. |
| [[concept-co-evolution\|J2]] | The surface, the substrate, and the agent layer must co-evolve. Building the surface without the substrate gives forms over nothing; building the substrate without the surface leaves it invisible. |
| [[concept-non-constraining\|J3]] | The seven-surface structure, the four-mode design, and the bounded-agent roster are extensible — additional surfaces, modes, or agents can be added without restructuring the existing ones. |

### 14.2 Concepts to add or revise in the master register

The following changes to the [[ontara-ref-master-register|master register]] should be considered alongside the Session 197 register changes (which are tracked as W-043):

- **Operator workspace** as a structural architectural concept. Section B (Structural Architecture Concepts) or section I (Ontara Platform and Console Concepts).
- **Three-layer interaction model** (operational / expert / intent) as a structural pattern. Section D (Validated Architectural Patterns) once realised, or section B until then.
- **Bounded agency** as a design pattern, distinct from general AI mediation. Section D.
- **Capability matrix** (human role × agent role × action class × scope) as a structural concept governing authority resolution. Section B or section A (depending on whether it is treated as a principle or a structure).
- **Action class as binding-derived** (§7) as a register concept. Section B, alongside the binding entries proposed by the Session 197 paper.
- **Approval artefact** as a first-class structural element. Section B or section C5 (Governance and Adaptation), depending on whether approval is treated platform-wide or as a BMM concern.
- **Plan/verify pattern** as a validated workspace pattern. Section D, once realised in implementation.
- **Mode-aware agent interaction** (Ask / Plan / Simulate / Act) as a register concept. Section D or section J (Development Methodology and Process Concepts), depending on framing.

The Perplexity research's recurring theme — "build an agent guided by model truth, not by prompt cleverness" — may itself warrant a register entry as a guiding principle, possibly in section A or as an extension of [[principle-discipline-as-load-bearing-structure|A9]].

### 14.3 Observations and watchpoints

The following observations from this session's discussion should be deposited in the [[ontara-ref-work-items|OW register]] alongside the existing items:

| Summary | Work type | Notes |
|---|---|---|
| Three-layer interaction model (operational / expert / intent) is the architectural framing for the operator surface. Stage 9 design must treat the three layers as separable concerns even when they share UI real estate | ARC, CON | Surfaced this session; relevant whenever surface design work is in scope |
| Bounded agent roster is the design pattern for AI mediation in the workspace. Adding capabilities to an existing agent rather than creating a new bounded agent should be treated as a design smell | ARC, CON | Standing principle for any agent development |
| Action class risk classification is computable from binding metadata (instantiation mode, freshness profile, production marker, authority zone). Vocabulary design for the binding declaration must include these properties | ARC, KGO | Dependency for the binding-grounded action classification approach to work; ties into S197 Q1 |
| Approval is a first-class entity in the substrate with its own lifecycle and PROV-O provenance, not a UI bolt-on. Approval artefacts must be added to the BMM or platform vocabulary as structural elements | BMM, ARC, GOV | Stage 9 design dependency |
| The Stage 8 portal requires substrate replacement (SQLite → KG-resident BR/BS), not just feature extension. The reframing is large and should be sequenced carefully across Stage 9 phases | CON, ARC | Portal reframing is a Stage 9 concern, not a Stage 8 retrospective |
| Model Map's relationship to the existing Ontara Console is unresolved (Q2). Two options: collapse the console into the workspace, or define the integration precisely between two applications. Decision required during Stage 9 planning | ARC, CON | Has implications for how much Stage 8 portal absorbs vs how much remains in the console |
| The workspace itself should be model-generated rather than hardcoded UI logic. Capability matrices, agent ceilings, action class definitions, and approval lifecycles should be model content that the platform reasons about | ARC, BMM | Long-horizon expression of A3 at the workspace level |
| Bounded agents must have distinct identities for audit purposes. The agent instantiation model (separate processes vs separate prompts vs something else) is open (Q5) and has cost, latency, and boundary-strength implications | CON, GOV | Stage 9 design decision; cross-cutting |
| Freshness propagation from bindings into surface-level rendering is a cross-cutting concern that touches Overview, Workflow Graph, Model Map, and the agent layer. Visual treatment should be consistent across surfaces | CON | Design consistency requirement; relates to OW-42 from S197 |
| Workspace state (selections, opened panels, conversation history) is not BR/BS content but has provenance value and privacy implications. Persistence and audit treatment is open (Q10) | CON, GOV | Design decision; minor for prototype, significant for GSL deployment |

---

## 15. Critique Observations and Watchpoints

This paper underwent a structured critique pass at the end of its drafting (per [[ontara-workflow-guide|workflow guide]] §1 commitment 5 / §2.2). The critique findings are recorded here, embedded in the paper they qualify, and the testable predictions are carried forward as watchpoints in §14.3.

### 15.1 Concerns identified

**1. The paper relies heavily on Perplexity-derived material.** The §3–9 framework comes substantially from the Perplexity research on interface and interaction. This creates a risk that Ontara has adopted a generic enterprise-agent architecture without adequately testing whether it fits Ontara's specific commitments. Mitigation: the binding-grounded reframing in §7 is the principal Ontara-specific contribution and is genuinely architecturally distinctive; the multi-tenancy treatment in §2.2 explicitly tests the Perplexity material against [[concept-multi-tenancy|A13]]; the §11 portal section identifies where the Perplexity-derived framework departs from the existing Stage 8 implementation. The reliance is real but it is not unexamined. A deeper test will come when implementation begins and the framework meets actual user needs.

**2. The seven-surface structure is asserted, not derived.** §4.1 says there are seven canvas surfaces because there are seven distinct kinds of work. But the seven were chosen by adopting the Perplexity-derived list rather than by deriving them from first principles. It is possible that the right number is six (e.g. by collapsing Release Manager into Workflow Graph) or eight (e.g. by separating clinical-evidence work from general evidence work for GSL). Stage 9 implementation will test the seven-surface structure against actual user workflows; the count should not be treated as load-bearing.

**3. The capability matrix in §6 has a subtle weakness.** The matrices are stated at default ceilings; the actual policy resolution requires the binding-grounded computation in §7 plus explicit policy gating. The interaction between the two layers is described in §6.5 but not formally specified. There is a risk that implementation will discover that the two layers cannot in fact be cleanly separated — that some risk classifications can only be made by combining role context with binding metadata in ways that don't decompose into floor + computation + ceiling. If this happens, the architecture should be revised rather than papered over.

**4. The approval lifecycle in §9.2 is sketched, not specified.** The states (Pending / Approved / Rejected / Withdrawn / Executed / Expired) are plausible but not derived from any concrete approval workflow. Real approval workflows often have additional states (e.g. "On hold pending more information", "Conditionally approved", "Approved but execution paused"). The lifecycle should be expected to need refinement once the first concrete approval workflow is implemented.

**5. The intent layer is the most novel and the least tested.** The architectural commitment to bounded agents, mode visibility, intersection-based delegation, and approval-gated execution is intellectually consistent but has not been tested in implementation. The first concrete implementation may surface fundamental issues with the four-mode design — for example, that users find it confusing, or that the mode boundaries are insufficiently sharp, or that the agent roster as proposed does not cover the cases users actually bring. The architecture should be expected to revise after first implementation contact.

**6. The portal reframing in §11 may be larger than acknowledged.** §11.3 says the reframing is "not a rebuild from scratch" but the list of gaps in §11.2 is substantial: substrate replacement, missing surfaces, no agent layer, no binding registry, partial approval primitive, no Evidence Trail. It is possible that the honest answer is that the portal will substantially be rebuilt rather than reframed, with the existing code serving as design reference rather than implementation foundation. The Stage 9 plan should be honest about which parts of the portal survive intact, which are refactored, and which are replaced.

**7. The relationship to the Ontara Console is acknowledged as Q2 but not resolved.** The console exists as a separate application; this paper imagines a single workspace; the integration is open. This is architecturally significant because it determines whether Stage 9 produces one application or two coordinated applications. The decision should not be deferred indefinitely.

### 15.2 What the critique does not find

The critique looked for and did not find:

- A fundamental conceptual error in the bounded-agent commitment. The argument from separation of duties, the intersection rule, and the no-Approve-for-agents principle hold up as a coherent design.
- A hidden assumption about user sophistication. The paper explicitly acknowledges three audiences (operator, power user, admin) and the workspace structure is designed to serve each.
- A conflict with the Session 197 substrate paper. The two papers are mutually consistent; the binding-grounded action classification in §7 strengthens the substrate paper rather than departing from it.
- A conflict with existing Tier 1 principles. The §14.1 cross-check confirms that the architecture engages and honours A1, A2, A3, A4, A8, A9, A10, A11, A13, J2, and J3.

### 15.3 Predictions to carry forward as watchpoints

The following predictions should be checked when the relevant work arrives. They are deposited in the OW register at C2 and are also listed in §14.3 above.

- The seven-surface structure will not survive first implementation unchanged; revisit at the end of Stage 9 Phase 1 (or equivalent first-implementation milestone).
- The four-mode design will require user testing to confirm it is intelligible; revisit when first concrete users (Ella in cafe testing, GSL operators in clinical testing) interact with Agent Studio.
- The capability matrix and binding-grounded computation may not cleanly decompose; revisit when the first non-trivial action policy is implemented.
- The approval lifecycle will need additional states; revisit when the first concrete approval workflow is implemented.
- The portal reframing may be substantial enough to count as a rebuild; the Stage 9 plan should be honest about this rather than under-scoping the reframing work.

---

## Related Documents

- [[ontara-discussion-bs-substrate-and-bindings-2026-04-12|BS Substrate and Bindings]] — Session 197, the parallel substrate paper this paper depends on
- [[ontara-discussion-architectural-clarification-2026-04-12|Architectural Clarification: Layers, Models, and Simulation]] — Session 196, the four-layer model and one-model-multiple-instantiation clarification
- [[ontara-discussion-model-meta-model-distinction-2026-04-11|Model and Meta Model: Clarifying the Architectural Representation]] — Session 195, the terminological clarification both substrate and surface papers build on
- [[ontara-discussion-connecting-the-stacks-2026-04-10|Connecting the Stacks — Toward a Live, Model-Grounded Ontara System]] — Sessions 192–193, the post-Stage-8 direction paper
- [[ontara-discussion-portal-state-driven-operator-experience-2026-04-08|Portal: State-Driven Operator Experience]] — Session 174, the Stage 8 discussion paper whose prototype this paper reframes
- [[ontara-research-(perplexity) - interface-and-interaction|Interface and Interaction (Perplexity research)]] — the source research from which §§3–9 are largely derived
- [[ontara-discussion-dual-stack-architecture-2026-03-26|Dual-Stack Architecture]] — Sessions 73–74, the foundational architecture paper
- [[ontara-discussion-knowledge-graph-architecture-2026-04-01|Knowledge Graph Architecture]] — Session 97, the three-stratum graph and authority zones
- [[ontara-ref-strategic-snapshot|Strategic Reference]] — current project orientation
- [[ontara-ref-master-register|Master Concept Register]] — register entries that will be proposed in light of this paper
- [[ontara-ref-work-items|Work Item Tracker / OW Register]] — W-044 (this paper), OW-43 (the Perplexity research origin), OW-37 / W-045 (Campus Walk II, which depends on both substrate and surface papers being in place)

---

*Discussion paper produced Session 198, 12 April 2026. Provides the architectural foundation for Stage 9 planning on the surface side, parallel to and dependent on the [[ontara-discussion-bs-substrate-and-bindings-2026-04-12|Session 197 substrate paper]]. Together with the substrate paper, constitutes the architectural foundation from which the Stage 9 plan can be drawn. Draws substantially on the [[ontara-research-(perplexity) - interface-and-interaction|Perplexity research on interface and interaction]] for §§3–9 and contributes the binding-grounded action classification (§7) as the principal Ontara-specific extension. The Stage 8 portal is reframed as one tenant's partial workspace instance rather than as the operator surface. GenderSense Limited.*
