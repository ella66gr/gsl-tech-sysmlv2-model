---
tags:
  - discussion
  - architecture
  - surface
  - headless
date: 2026-04-13
status: working
session: 199
---
# Surface Families: Headless Composition Across the Sophistication Gradient

> `= this.file.path`

*Ontara Platform — Discussion Paper*

**Date:** 13 April 2026 (Session 199)
**Purpose:** To establish the architectural foundation for the *family of surfaces* through which different audiences encounter the Ontara platform — from a customer at a kiosk, through ordinary front-line and back-office staff, through operational managers and tenant administrators, up to tenant architects and Ontara platform engineers. This paper sits as the third foundation paper for Stage 9 alongside the [[ontara-discussion-bs-substrate-and-bindings-2026-04-12|BS Substrate and Bindings]] paper (S197, the substrate side) and the [[ontara-discussion-surface-architecture-and-bindings-2026-04-12|Surface Architecture and Bindings]] paper (S198, which — as this paper will argue — covers one band of the gradient and not the whole). Where S197 answered *what is the substrate?* and S198 answered *what does the architect-analyst surface look like?*, this paper answers *what does the family of surfaces look like, across the full sophistication gradient, and how do they all sit honestly over the same substrate?*
**Status:** Working document — architectural foundation for Stage 9 (surface family side). Cafe walk-through complete; Paws and Suds walk-throughs deferred to Session 200 and possibly Session 201.
**Depends on:** [[ontara-discussion-bs-substrate-and-bindings-2026-04-12|BS Substrate and Bindings]] (Session 197); [[ontara-discussion-surface-architecture-and-bindings-2026-04-12|Surface Architecture and Bindings]] (Session 198); [[ontara-discussion-portal-state-driven-operator-experience-2026-04-08|Portal: State-Driven Operator Experience]] (Session 174); [[ontara-research-(perplexity) - headless operation and state|Headless Operation and State (Perplexity research)]]

---

## Contents

- [[#1. Purpose and Scope|§1. Purpose and Scope]]
- [[#2. On Terminology — Meta Models, Models, and Runtime Instances|§2. On Terminology — Meta Models, Models, and Runtime Instances]]
- [[#3. The Sophistication Gradient|§3. The Sophistication Gradient]]
- [[#4. Headless Composition — The Five-Layer Architecture|§4. Headless Composition — The Five-Layer Architecture]]
- [[#5. State Placement Discipline|§5. State Placement Discipline]]
- [[#6. The Cafe Walk-Through|§6. The Cafe Walk-Through]]
- [[#7. Paws Cross-Domain Check|§7. Paws Cross-Domain Check]]
- [[#8. Suds Cross-Domain Check|§8. Suds Cross-Domain Check]]
- [[#9. Implications for the Architecture|§9. Implications for the Architecture]]
- [[#10. Open Questions for Stage 9 Planning|§10. Open Questions for Stage 9 Planning]]
- [[#11. Register Connections|§11. Register Connections]]
- [[#12. Critique Observations and Watchpoints|§12. Critique Observations and Watchpoints]]
- [[#Related Documents|Related Documents]]

---

## 1. Purpose and Scope

The Ontara platform has, in its first 198 sessions, accumulated a remarkably sophisticated set of representational and execution capabilities: a dual-stack meta model architecture, an OWL 2 DL knowledge graph as canonical store, a reasoning vocabulary spanning 42 classes, a deontic governance vocabulary, a clinical domain intake methodology, and a substrate paper (S197) that establishes the dynamic side of the model — BR, BS, and bindings — as load-bearing architectural elements. Alongside these has grown a working portal prototype (Stage 8) and a parallel discussion paper on the architect-analyst workspace (S198).

What the project has *not* yet produced is an honest account of how all of this is encountered by the actual people who will interact with an Ontara-supported business. That set of people is large and diverse. It includes the customer who walks up to a coffee shop counter or taps a kiosk, the staff member who takes the order or grooms the dog or operates the washing machines, the manager who watches the day unfold and handles exceptions, the business owner who configures and runs the whole thing, the architect who edits the configured business model in the platform tooling, and — at the top of the gradient — the Ontara platform engineer who develops and maintains the platform itself. None of these people occupy a single workspace. None of them want to. The single biggest weakness in the surface architecture as it currently stands is that it does not acknowledge this.

This paper sets out to fix that. It does so by adopting three structural commitments and walking through their implications with one demonstrator (Cafe) in detail and a planned cross-domain check with two more (Paws and Suds, deferred to Session 200).

The three commitments are:

1. **There is a sophistication gradient.** It is real, observable, and shaped by audience and task — not by role-conditioned visibility on a shared workspace. The gradient breaks empirically into bands, each with its own characteristic interaction shape, audience, and familiar UI/UX patterns. The bands are a working classification, not a fundamental taxonomy: they are open to revision, splitting, merging, or augmentation as new audiences and interactions are recognised. The gradient itself is the architectural fact.
2. **The architecture is headless.** Capabilities, content, and process are exposed through stable, channel-neutral contracts. Each band of the gradient is served by its own surface family, drawing on familiar UI patterns appropriate to that band, and consuming the contracts at the level of detail and shape it needs. The substrate is one; the surfaces are many.
3. **State lives in the right places.** The platform is deeply state-aware in the substrate (BR, BS, bound stores, workflow instances, governance progression, audit trails, simulation runs) and deliberately stateless in many of the layers above (composition, edge APIs, render façades). UI session state is local, ephemeral, and never the home of canonical truth. Treating state placement as a discipline rather than a default avoids two failure modes — the smart-UI / dumb-backend trap, and the everything-is-stateful sprawl.

These three commitments together let the project hold its sophistication on the inside while presenting calm, ordinary, familiar interactions on the outside. They also let the existing artefacts — the Stage 8 portal, the S198 architect-analyst surface, the cafe demonstrator's running application — be located honestly within a larger picture rather than each presenting itself as if it were the whole.

### 1.1 What this paper is not

It is not a UI design document. There are no pixel layouts, no Tailwind class choices, no component decompositions, no visual hierarchies. The bands and surfaces it identifies are architectural categories, not screens. The familiar UI/UX patterns it names are pointers to design conventions that already exist in the wider software world (kiosk apps, EPOS, kanban boards, admin consoles, IDE-style workspaces) — not specifications for how Ontara will eventually render them.

It is not a Stage 9 plan. Plan production is downstream of having the architectural foundation in place. This paper, together with S197 and S198, completes that foundation; the plan can be drawn against it once the foundation is consolidated (W-042, W-043) and the cross-domain check (this paper's §7 and §8, deferred to S200) is done.

It is not a portal redesign document. §9.3 considers the existing Stage 8 portal in light of this paper's framing, but the purpose is to identify where the portal sits within the larger family rather than to issue instructions for portal modification. The portal is malleable prior art; the architecture is the stable thing.

It is not a rejection of the S198 surface architecture paper. S198 produced genuinely useful architectural commitments — the bounded-agent roster, the four-mode interaction model, the binding-grounded action class, the capability matrix — and most of those commitments survive intact within the framing this paper introduces. What this paper does to S198 is *relocate* it: from "the operator surface architecture" (which it is not) to "the architect-analyst-admin band of the surface family" (which it is). That is a non-trivial reframing and is examined in §9.2.

### 1.2 The relationship to the Perplexity research

This paper draws substantially on the [[ontara-research-(perplexity) - headless operation and state|Perplexity research on headless operation and state]] for §§4 and 5. The research independently arrives at almost exactly the framing this paper adopts: capability decomposition first, channel decomposition second; a five-layer mental model that separates canonical model, operational state services, process orchestration, experience composition, and surface; and a state-placement discipline that distinguishes properly stateful, properly stateless, and properly ephemeral concerns. Where the research speaks in general best-practice terms, this paper grounds its commitments in Ontara's existing architecture and walks them through the cafe demonstrator in concrete detail. The reliance is acknowledged and the contributions are credited; the binding of those contributions to Ontara's specific commitments is the work this paper does.

One note on the research: it slips into the malformed phrasing "BMM runtime state / SMM runtime state" that S197 §1.1 already flagged as a category error (see §2 below). This is because it was reading a version of the project README that contained the same drift. The research's substantive content survives the correction; we simply read its references to "BMM runtime state" as "BM runtime instances" and proceed.

---

## 2. On Terminology — Metamodels, Models, and Runtime Instances

This section is short but load-bearing. It exists because the project has been carrying a terminological imprecision that, if not corrected, would actively impede the surface conversation that follows. The imprecision is the conflation of *metamodels* with *configured models* with *runtime instances*. Every band of the sophistication gradient interacts with one or more of these — and getting the band conversation right depends on knowing which.

### 2.1 The four levels

Ontara has, in its proper architectural picture, four distinct levels:

1. **Metamodel.** A *template* defining what a particular kind of model can contain. In Ontara: the [[principle-two-meta-model-distinction|Business Meta Model (BMM)]] and the [[principle-two-meta-model-distinction|System Meta Model (SMM)]]. The BMM defines what a service business model can contain — the 34 `part def` elements across six concerns. The SMM defines what a service system model can contain — components, workflows, bindings, pattern instantiations, governance hooks. Metamodels are static. They do not have customers, orders, appointments, or live workflow instances. A metamodel is to a model what a programming language specification is to a particular program.

2. **Configured model.** A *specific tenant's filled-in instantiation of the templates*. In Ontara: the *cafe BM* and *cafe SM*; the *Paws BM* and *Paws SM*; eventually the *GSL BM* and *GSL SM*. The BM is the cafe's actual menu, its actual stakeholder relationships, its actual financial structure, its actual governance posture. The SM is its actual workflow definitions, its actual Temporal cluster bindings, its actual platform integrations, its actual persistence policies. Configured models change when the architect or the tenant admin alters configuration; they are mostly static between such changes. The cafe BM does not have today's orders in it — it has the *definition* of what orders are and what their lifecycle is.

3. **Runtime instances.** The *individuated, time-stamped, identity-bearing things* that come into existence as the configured business runs. Today's order #1247 placed by the customer at 09:14. The current FulfilDrink workflow execution with workflow ID `w-1247-fulfil`. The thirty-eight customer records added this week. The two governance alerts open right now. The simulation run started yesterday at 16:00 against the comparative dashboard. *These are what BR and BS actually contain.* BR holds the business runtime instances (orders, customers, transactions, alerts, governance evaluations); BS holds the system runtime instances (workflow executions, message queue states, binding observations, action invocation records). Runtime instances are highly dynamic — created, modified, retired continuously.

4. **Realising components.** The *external systems and infrastructure* that bindings connect to and that produce the events the substrate observes. Temporal clusters running workflows. EHRbase CDRs holding clinical compositions. PostgreSQL databases holding catalogue entries. Stripe payment processors. Email gateways. None of these *are* Ontara — they are realisers, the things that do the actual operational work that Ontara coordinates and observes through bindings. Their internal state lives in their own systems; the substrate observes that state via binding pipelines and projects it into BR/BS as runtime instance facts.

### 2.2 The category error to retire

The phrasing "BMM runtime state" or "SMM at runtime" — which has crept into several recent papers including [[ontara-discussion-connecting-the-stacks-2026-04-10|Connecting the Stacks (S192–193)]], [[ontara-discussion-model-meta-model-distinction-2026-04-11|Model and Meta Model (S195)]], and (in the README the Perplexity research was reading) the project README itself — is a category error. The BMM does not have a runtime any more than a programming language has a heap. What has a runtime is the *configured BM* of a specific tenant, *populated with runtime instances*, with the *whole behaviour observed through bindings* into BR. When earlier papers referred to "BMM runtime state" they meant "BR — the substrate of runtime instances of elements defined in a tenant's configured BM, which is itself a population of the BMM templates." The shorter phrasing is convenient but it obscures the level distinction in a way that eventually produces conceptual mistakes.

[[ontara-ref-work-items|W-042]] in the work item tracker is the editorial cleanup of this phrasing in [[ontara-discussion-connecting-the-stacks-2026-04-10|Connecting the Stacks]] §6 and [[ontara-discussion-model-meta-model-distinction-2026-04-11|Model and Meta Model]] §6. This paper observes that the cleanup is broader than W-042 currently scopes — it is a habit of phrasing that needs watching across all subsequent documents. This paper commits to the precise vocabulary throughout.

### 2.3 Why this matters for the surface conversation

Ordinary users — customers, front-line staff, back-office staff, managers — *do not interact with anything meta*. The cafe customer ordering an oat flat white interacts with the cafe BM (its menu definition) and creates a runtime instance (their order) which spawns a system runtime instance (the FulfilDrink workflow execution) which is observed via bindings into BS. The customer is several levels removed from the SMM and the BMM, and they should remain so. The barista taking the order and tapping it through to the kitchen is at the same level — the barista interacts with the cafe BM and the order runtime instance via familiar EPOS-shaped UI. The shift manager watching the order board is observing aggregated runtime instances filtered through projections of BR and BS, again with no exposure to meta concepts.

Where the meta level becomes visible is at the *architect-analyst* and *Ontara platform engineer* bands. The architect editing the cafe BM is doing meta-mediated work: their edit to the menu must conform to the BMM's definition of what menu items can be, and the platform's editor uses BMM constraints to validate the edit. The Ontara platform engineer changing the BMM itself is operating at the meta level proper — adding a new `part def`, extending a concern, modifying a constraint. At the top of the gradient, work is *about* the metamodels; at the bottom of the gradient, the metamodels are entirely invisible.

The gradient is therefore not just a sophistication gradient in interaction shape — it is also a *level gradient* in what the user is touching. Customers touch runtime instances of BM-defined elements. Staff touch runtime instances and occasionally configured-model elements. Managers touch projections over runtime instances and occasionally configured-model views. Tenant admins touch configured models. Architects touch configured models with metamodel-aware tooling. Platform engineers touch the metamodels and the platform itself. The surfaces should reflect this honestly. A customer surface that exposes the BMM is a category error in the same family as "BMM runtime state."

This paper uses the four-level vocabulary throughout. Where convenient shorthand might tempt us to say "the BMM in production," we say instead "the cafe BM as configured against the BMM, populated with runtime instances in BR, observed via bindings." It is more words but it is right.

---

## 3. The Sophistication Gradient

The gradient is the empirical observation that the people who interact with an Ontara-supported service business are not one audience, not three audiences, but a continuum of audiences whose needs differ along several dimensions simultaneously — sophistication, frequency of use, depth of engagement with model concepts, expectation of what good UX looks like, and tolerance for visible complexity. These dimensions move together: the customer who taps a kiosk twice and walks away expects an interaction that looks nothing like the architect who opens the platform tooling to edit the cafe BM, and any attempt to serve both with a single workspace abuses one or the other.

### 3.1 The seven working ‘user bands’

The user bands below are an empirical working classification. (Incidentally, these should distinguished from healthcare staff bands used in Agenda for Change and they are not related). User bands are akin to access-role in role-based access control (RBAC) for security purposes, but are not identical, since they serve a different purpose, even if they were to be incidentally aligned in any given system.

They emerged from walking the cafe, Paws, and Suds demonstrators through realistic concrete scenarios and observing which audiences had structurally distinct interaction shapes. They are not derived from first principles; they are not exhaustive; they are not a fundamental taxonomy. They are working hypotheses about where the natural cuts lie *now*, in the demonstrators we have to hand. The architecture's commitment is to the *gradient* and to *headless composition over a single substrate* — not to the specific band cuts. New bands may be recognised; existing bands may split, merge, or be refined; some interactions may turn out to cut across bands rather than living within them. This non-constraining stance is important: see §3.4.

| #   | User band                          | Audience                                                                              | Characteristic interaction shape                      | Familiar UI patterns drawn on                                                                          |
| --- | ---------------------------------- | ------------------------------------------------------------------------------------- | ----------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| 1   | **Customer / client**              | The person consuming the service                                                      | Single-purpose, transactional, novice, narrow, rare   | Kiosk apps, mobile ordering, web booking forms, email confirmations, simple status pages               |
| 2   | **Front-line operational staff**   | Staff in direct customer contact during service delivery                              | Single-purpose, high-frequency, fluent, narrow, fast  | EPOS, counter terminals, tablet checklists, kanban boards, walk-up call-screens                        |
| 3   | **Back-office / supporting staff** | Staff doing service work *not* in front of the customer                               | Task-focused, queue-driven, fluent, somewhat broader  | Order boards, work queues, inventory screens, kitchen display systems, batch consoles                  |
| 4   | **Operational manager**            | Shift lead, duty manager, person handling exceptions and overseeing flow today        | Oversight-oriented, exception-driven, broader still   | Operational dashboards, alert inboxes, exception queues, shift reports, simple report views            |
| 5   | **Tenant admin / business owner**  | Configuration, composition, governance setup, promotion, longer-horizon control       | Configurational, slower-rhythm, broader scope         | Admin consoles, settings pages, module composition surfaces, governance editors, promotion wizards     |
| 6   | **Tenant architect-analyst**       | Model edits, deep reasoning, impact analysis, scenario design — the S198 surface      | Analytical, sophisticated, deep, deliberate           | IDE-style workspaces, model navigators, query consoles, impact-and-diff tools, agent-mediated planning |
| 7   | **Ontara platform engineer**       | Developing Ontara itself — metamodels, generation pipeline, substrate, platform code  | Engineering, deep, infrastructure-aware, cross-tenant | Source code editors, terminal sessions, KG browsers, build pipelines, the Ontara Console               |

These seven bands are a convenient working cut. They are not load-bearing.

### 3.2 What the user bands have in common

Despite their differences, every band shares three architectural properties. These properties are the load-bearing commitments of this paper's framing:

1. **Every user band sits over the same substrate.** The customer's order runtime instance, the barista's view of the order in their queue, the manager's dashboard count of orders today, the architect's query against the cafe BM definition of what an order is — all of these read from or write to the same BR/BS substrate. There is no separate "customer database" or "staff database" or "manager database." There is BR and BS in the knowledge graph, plus the bound stores the substrate observes. Different surfaces project different views of the same canonical truth.
2. **Every user band consumes capabilities through stable contracts.** No surface family talks directly to BR/BS in raw form. Every surface family consumes from the experience-API / BFF layer (§4.4), which assembles channel-ready, task-shaped view models for that band. The kiosk gets "menu items currently available with prices, allergens, and queue depth"; the staff terminal gets "current orders by station in queue order with elapsed time"; the manager dashboard gets "today's takings versus forecast with anomalies highlighted." Same substrate, three different contracts, three different shapes.
3. **Every user band has its own UI grammar.** The customer surface uses the conventions of kiosk and mobile-ordering apps. The staff terminal uses the conventions of EPOS and counter systems. The manager dashboard uses the conventions of operational dashboards. The architect workspace uses the conventions of pro tools and IDE-style environments. None of these is a degraded version of another. They are *different design targets* with *different first-principle constraints*. Trying to unify them into a single workspace with role-conditioned visibility is a category error.

### 3.3 What varies across the user bands

Several things vary monotonically (or near-monotonically) along the gradient. Recognising these helps explain why the band boundaries fall where they fall:

- **Sophistication.** From novice (customer) to expert (platform engineer). Affects how much explanation, scaffolding, and safety the surface must provide.
- **Frequency of use.** From rare (customer) to constant (platform engineer). Affects how much the user can be expected to learn and remember.
- **Breadth of scope.** From narrow (customer: just my order) to broad (platform engineer: cross-tenant, cross-stage). Affects how much navigation and structure the surface needs.
- **Depth of engagement with model concepts.** From none (customer: invisible) to total (platform engineer: works *on* the metamodels). Affects whether model vocabulary appears in the UI at all.
- **Tolerance for visible complexity.** From zero (customer expects calm and ordinary) to high (engineer expects power and density). Affects which UI patterns are appropriate.
- **Stakes and reversibility of action.** From low (customer can correct an order) to high (platform engineer can break the platform). Affects how much safety, confirmation, and audit each action requires.
- **Level of model touched.** From runtime instances only (customer/staff) through configured models (admin/architect) up to metamodels (platform engineer). The four-level distinction from §2 maps onto the gradient.

These are dimensions, not categories. Real users will sit at slightly different points along several dimensions at once, and the band cuts are simplifying observations about clusters of points. A specialist barista who has used the cafe app every day for two years is more fluent than the gradient strictly anticipates for band 2; a part-time owner who configured their cafe BM by walking through a wizard has less depth of engagement with model concepts than the gradient strictly anticipates for band 5. The bands are useful for thinking, not for rigid assignment.

### 3.4 Non-constraining

It is worth being explicit, in light of [[concept-non-constraining|J3]], about what the user bands *do not* commit Ontara to. They do not commit Ontara to:

- A fixed number of user bands. Seven is a working count. Six and eight are equally plausible if the demonstrators' content is reframed differently.
- The specific cuts between bands. The boundary between back-office staff and operational manager is fuzzy in a small business where the same person does both. The boundary between tenant admin and tenant architect is fuzzy in a sole-trader business where the owner does both. Compression and overlap are normal, not failures.
- A single surface family per band. A single band may turn out to need multiple specialised surfaces — for example, a customer band that splits into walk-in kiosk vs. mobile pre-order. This paper treats those as variants within a band; they could equally be treated as adjacent bands.
- The seven user bands as the only audiences. Third-party developers building modules for the Ontara platform (S174 §11) are a possible eighth band. Auditors and regulators inspecting an Ontara-supported business from the outside are a possible ninth. Both are deferred for now and would be addressed when concrete need arises.
- Any particular implementation order. Stage 9 will need to sequence which surface families to build first, and the answer is not "all seven at once." The cafe walk-through (§6) suggests a natural starting set — customer kiosk, staff terminal, manager dashboard — because those three exercise the substrate end-to-end through the existing cafe Temporal workflow without requiring entirely new architectural elements.

The architectural commitment is to the *fact* of the gradient, to *headless composition over one substrate*, and to *familiar UI grammars at every band*. Within those commitments, the user band cuts are revisable working classifications and should remain so.

### 3.5 User band compression in different business sizes

A useful empirical observation that came out of walking the demonstrators: the gradient's seven user bands are most distinct in larger businesses with role specialisation, and they compress in smaller ones. In the cafe demonstrator at full size, all seven user bands are clearly distinct — there is a customer, a barista, a kitchen prep person, a shift manager, an owner, an architect (whoever set up the cafe model), and a platform engineer. In a one-person Suds operation where the proprietor takes the laundry in, washes it, irons it, prices it, books it out, configures the platform, and (in principle) edits the model, several adjacent bands collapse onto a single physical person. That person needs all the corresponding surfaces, but they will probably want *one composite surface* that lets them switch between modes rather than a full architect workspace plus a full operational manager dashboard plus a full counter terminal as separate applications.

This is not a problem for the architecture — it is a *natural feature* of the headless approach. Because every surface consumes channel-neutral contracts from the experience-API layer, a small-business composite surface can assemble views from several band-level contracts into a single screen. The contracts do not change; the consumer does. Compression is a UI design problem, not an architectural problem. The Stage 9 plan should anticipate this and not assume that every band needs a separate surface in every tenant deployment.

---

## 4. Headless Composition — The Five-Layer Architecture

The structural basis for serving seven (or however many) bands without fragmenting the platform into seven separate stacks is *headlessness*: capabilities, content, and process are exposed through stable, channel-neutral contracts, and surfaces consume those contracts in whatever shape suits them. This section sets out the five-layer architecture that headlessness implies, and locates each existing Ontara element within it.

>**Backend For Frontend (BFF):** The pattern where each client type (kiosk, staff terminal, manager dashboard, architect workspace) gets its own dedicated server-side composition layer shaped for its specific needs, rather than all clients sharing one generic API. Same substrate underneath; per-consumer composition on top.

The five layers, working from canonical to surface:

| #   | Layer                                          | Content                                                                                                                                         | Stateful?                                                         | Ontara expression                                                                                                                                                                                                                       |
| --- | ---------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | **Canonical model**                            | The configured model — BM and SM — for each tenant, defined against the BMM and SMM templates                                                   | Static between edits                                              | The cafe BM and SM in `exercises/coffeeshop-demonstrator/model/`, the Paws and Suds equivalents, eventually the GSL BM and SM. Edits propagate through the generation pipeline                                                          |
| 2   | **Operational state and transaction services** | The substrate — BR, BS, and the bound external stores — holding runtime instances and transactional truth                                       | Yes (this is the home of canonical state)                         | The KG-resident BR and BS (per S197), plus the bound stores: Temporal task queues, EHRbase CDR, PostgreSQL, payment processor state                                                                                                     |
| 3   | **Process orchestration**                      | Workflows, task routing, retries, compensations, governance progression, approvals                                                              | Yes (workflow instance state)                                     | Temporal workflows in `exercises/coffeeshop-demonstrator/packages/temporal/`. The XState-in-Temporal pattern (D10). Eventually a workflow layer for governance approval flows, simulation runs, and promotion paths                     |
| 4   | **Experience API / BFF**                       | Channel-ready, task-shaped view models assembled from layers 1–3 for consumption by surfaces. Stateless composition; minimal session state only | No (or minimal session state only)                                | **Currently absent.** A Stage 9 architectural addition. Each band of the gradient gets its own experience API contract. See §4.4                                                                                                        |
| 5   | **Surface families**                           | The actual UI applications consumed by users at each band. Familiar UI patterns appropriate to the band                                         | Local UI session state only (selections, drafts, wizard progress) | Currently: the cafe demonstrator's SvelteKit frontend (one mixed-band surface), the Stage 8 portal (a tenant-admin band partial), the Ontara Console (an architect-analyst band partial). Each will be reframed and extended in Stage 9 |

The remainder of this section discusses each layer briefly and then makes the case for layer 4 — the experience-API layer — as the missing piece on which the rest of the framing depends.

### 4.1 Layer 1 — Canonical model

The cafe BM and SM are configured models — specific tenant instantiations of the BMM and SMM templates. They define what the cafe *is*: its menu, its workflow definitions, its stakeholder relationships, its governance posture, its bindings to realising components. They are mostly static; they change when the architect edits the model files (or, eventually, when the tenant admin edits configuration through a model-aware UI). They are the canonical design authority for everything downstream.

The model is the source of generation: it generates the SysML→OWL pipeline output, the comprehension JSON consumed by the console, the constraint evaluators, the workflow definitions that Temporal runs. Per S192-D7, the portal's module catalogue should be derived from the model (currently it is hand-seeded, [[ontara-ref-work-items|OW-32]]). Per [[principle-model-generates-everything|A3]], the running system is generated from the model; the surfaces consuming it should therefore reflect the model's structure rather than independently asserting their own.

### 4.2 Layer 2 — Operational state and transaction services (the substrate)

This is what the [[ontara-discussion-bs-substrate-and-bindings-2026-04-12|S197 substrate paper]] established. BR holds business runtime instances; BS holds system runtime instances; bindings connect both to realising components and produce the observations that update the substrate. The substrate is the home of canonical state for everything that happens at runtime. Today's order #1247 lives in BR. The FulfilDrink workflow execution `w-1247-fulfil` lives in BS. The action invocation record that says "the barista tapped Mark Ready at 09:16" lives in BS. The provenance graph that ties them together lives in the KG via PROV-O.

The substrate is rigorously stateful. Its stores must be transactionally consistent, queryable, and reasoning-tractable. They must support the freshness and fidelity profiles the bindings declare. They must support multiple instantiation modes (real, simulated, projected, counterfactual) per S197 §6. They are the load-bearing element of the whole architecture; without the substrate, none of the surfaces have anything coherent to read or write.

### 4.3 Layer 3 — Process orchestration

The process orchestration layer is the home of **durable workflows** — structured sequences of state transitions that must complete (or compensate) as a unit, with recoverability across process crashes, inspectable execution history, retry and timeout semantics, and first-class provenance. In the cafe demonstrator this is Temporal, running the FulfilDrink workflow with an XState v5 state machine for the OrderLifecycle. In Stage 9 it will extend to Temporal-backed governance approval workflows (per S198 §9), Temporal-backed simulation runs (per S198 §8.3), and Temporal-backed promotion paths (per S174 §10).

The orchestration layer is stateful: workflow instance state is canonical for the duration of the workflow. It is *adjacent to* the substrate rather than part of it — workflow events are observed via bindings and projected into BS, but the workflow's own internal execution state is held by Temporal, not by BS. The substrate observes the orchestration; the orchestration realises the workflow definitions in the SM.

#### 4.3.1 Duration is not the criterion

It would be a mistake to characterise this layer as the home of *long-running* workflows. Duration is downstream of the structural properties that make a workflow engine the right tool. A 600-millisecond payment-plus-order-creation sequence — charge the card, create the order runtime instance, signal FulfilDrink, send the confirmation — needs the same durability, compensation, and audit guarantees that a multi-hour clinical pathway needs. A 200-millisecond shift-offer dispatch needs retry-with-backoff, notification-delivery confirmation, and PROV-O provenance. An inventory adjustment with cascading effects on constraint evaluators, alerts, and surface re-reads is milliseconds of wall-clock time but must be atomic from the operator's perspective and recoverable if any step fails. None of these are "long-running" in any meaningful sense; all of them earn their place in the orchestration layer.

The real criteria for putting a sequence of work in the orchestration layer are structural rather than temporal. An operation belongs in the orchestration layer when it meets two or more of the following:

- **Multi-step state transition that must complete as a unit** — more than one thing has to happen, and partial completion is a bug, not a state.
- **Durability across process crashes** — if the host dies mid-sequence, the work resumes from where it stopped, not from scratch and not abandoned.
- **Inspectable execution history** — the sequence's progress, inputs, and outputs are first-class audit material, not incidental log entries.
- **Retry, timeout, and compensation semantics** — failure handling is declared and handled by the engine rather than scattered through application code.
- **Human tasks mixed with system tasks** — waiting for an approval, a confirmation, or an external event is natural in the workflow engine and painful outside it.
- **Signals and queries from outside** — the workflow can be signalled to change course, queried for its current state, paused and resumed.
- **Provenance-first execution** — where audit or regulatory requirements demand that every step be recorded with provenance, a workflow engine that writes PROV-O-shaped history naturally is the right home.

#### 4.3.2 Three distinct execution mechanisms

Ontara therefore has (or will have) three structurally different execution mechanisms, and the choice between them is about structural fit, not duration:

1. **Transactions.** Single atomic actions against a single store, with no multi-step state machine and no need for durability beyond the store's own. Served by experience-API handlers talking directly to the substrate or to a bound store. Most read operations and many simple writes fall here — a menu lookup for the kiosk, a user profile edit, a dashboard filter change.

2. **Event publication and subscription.** Broadcast facts that downstream components may react to, without the publisher caring how. The event itself is not a workflow; subscribers may each spawn their own workflows if they need to. Useful for cross-module notification, projection building, and loose coupling between capabilities that do not need to co-ordinate in a single orchestrated flow.

3. **Durable workflows.** Anything meeting two or more of the structural criteria above. Served by Temporal. Whether the workflow takes 50 milliseconds or 50 hours is incidental — what matters is that the sequence is structurally unsuitable for a single transaction and structurally unsuitable for fire-and-forget event publication.

The Stage 9 plan and the experience-API design should be explicit about which mechanism each operation uses. Getting the choice wrong in either direction produces predictable failures: treating a multi-step transactional sequence as a single transaction drops integrity guarantees; putting a pure lookup behind a durable workflow wastes the engine's guarantees on a problem that does not need them; hiding what should be a visible orchestrated flow behind fire-and-forget events makes the flow opaque and hard to govern.

#### 4.3.3 One engine, not several

There is no strong case for a second workflow engine in Ontara alongside Temporal as a "short-running" alternative. Temporal handles short workflows perfectly well — its costs are not wall-clock duration but operational overhead (a cluster to run), the programming model's learning curve, and the fact that every workflow becomes an auditable first-class thing whether or not the application wanted that. The first two are fixed costs already paid by Ontara's existing commitment to Temporal. The third is usually a feature for Ontara rather than a cost, given [[principle-self-describing-system|A2]], [[principle-clinical-governance-first-class|A8]], and the PROV-O-first audit commitments. Where the overhead of a full durable workflow is not wanted, the right answer is almost always that the operation does not belong in the orchestration layer at all — it belongs in a transaction or an event.

### 4.4 Layer 4 — Experience API / BFF (the missing piece)

(Backend for Frontend: BFF) This is the layer Ontara does not yet have, and it is the reason this paper had to be written. Without it, every surface family would be forced into one of two failure modes:

- **The smart-UI / dumb-backend trap.** The surface assembles its view by querying BR/BS and the bound stores directly, applying business logic in the UI layer. Different surfaces independently re-implement the same logic. Surfaces become inconsistent because each one's interpretation of the substrate is slightly different. Business rules end up scattered across kiosk, staff terminal, manager dashboard, and admin console. Every change to a rule requires editing N surfaces.

- **The thin-UI / overloaded-backend trap.** The surface displays raw substrate query results. Every screen becomes a slow KG query. Users see data, not task-shaped views. Customers get "here is the menu items table; please pick one" instead of "here are the drinks you can have right now." The substrate is asked to do composition work it should not be doing.

The experience-API layer prevents both traps by providing an *intermediate stateless composition tier*. Each band of the gradient gets one or more experience-API contracts shaped for its needs. The contracts assemble from the substrate, the orchestration layer, and (where useful) the canonical model, producing channel-ready view models that the surface consumes directly.

For the cafe demonstrator, the experience APIs would include (illustratively):

- **A customer kiosk contract**: `GET /experience/cafe/kiosk/menu` returns the currently available menu items, with prices in the customer's currency, allergens flagged, queue depth as an estimated wait, and a session ID to attach a forthcoming order to. `POST /experience/cafe/kiosk/order` accepts an order intent and returns a confirmation with order number and estimated ready time. The kiosk surface displays exactly what it gets, with no interpretation. The contract's job is to know that "currently available" means filtering the menu by inventory and station readiness, that "queue depth" is computed from BS workflow instance counts at the relevant station, and that submitting an order is a structured action invocation that starts a FulfilDrink workflow via the bound Temporal cluster.

- **A staff counter contract**: `GET /experience/cafe/counter/queue` returns the current order queue for the staff member's station, ordered by submission time with elapsed seconds, expected ready time, and the next allowed action for each order. `POST /experience/cafe/counter/order/{id}/transition` accepts a state transition intent (`mark-in-progress`, `mark-ready`, `mark-collected`) and returns the updated order state. The counter UI shows a kanban-shaped column of order cards with chunky tap-to-advance buttons. The contract knows about the OrderLifecycle XState definition and translates UI intents into legal transitions.

- **A manager dashboard contract**: `GET /experience/cafe/manager/today` returns aggregate stats (orders, takings, average prep time, exception count), highlighted anomalies (orders waiting longer than threshold, governance alerts open, station performance outliers), and a small set of next-best actions. The dashboard surface displays summary cards with a familiar dashboard grammar; the contract knows how to compute the aggregates against BR and BS and how to detect the anomalies.

These three contracts together exercise the substrate end-to-end — every cafe surface band activity reads from or writes to the same BR/BS, mediated by the contracts. Adding a fourth surface (a tenant admin configuration screen, say) means adding a new contract; the existing three are unchanged.

The contracts are *stateless*. They do not hold session state beyond what is necessary for a single request. They do not own any business truth. They are pure composition layers that translate between the substrate's canonical form and the surface's task-shaped form. This makes them horizontally scalable, individually replaceable, and testable in isolation.

The contracts are also *channel-aware* but *band-shaped*. The kiosk contract is shaped for kiosks specifically, but it serves any kiosk implementation (touch, web kiosk, mobile-ordering app variant). The staff counter contract serves the cafe counter terminal but could equally serve a tablet variant or a hands-free voice-driven variant. The shape of the contract is determined by the band's needs, not by the specific device.

### 4.5 Layer 5 — Surface families

Each band of the gradient has its own surface family — a set of one or more applications drawing on the familiar UI patterns appropriate to that band, consuming the relevant experience-API contracts. The surfaces are where the gradient's diversity lives. Their internal implementation is up to them: SvelteKit, native apps, terminal interfaces, voice surfaces, anything that can speak HTTP (or its equivalents) to the experience-API layer.

The surfaces hold *only ephemeral session state*: the user's current selections, draft form contents, wizard progress, optimistic UI updates. They never hold canonical truth. When the user closes the surface and reopens it, anything that should persist is in the substrate; anything that was only in the surface is gone, and that is correct.

The current Ontara artefacts each correspond to one or more bands' surface families:

- The cafe demonstrator's SvelteKit frontend (`exercises/coffeeshop-demonstrator/packages/web/`) is a *mixed-band surface*: its Counter page is roughly band 2 (front-line staff), its Order Board is roughly band 3 (back-office), its Management page is roughly band 4–5 (manager / tenant admin), its Audit Dashboard is roughly band 4. It was built before the band framing existed and so it does not cleanly separate the bands. Stage 9 will reframe it as several distinct surfaces.
- The Stage 8 portal (`portal/`) is a *tenant-admin band partial*: it covers band 5 (tenant admin / business owner) reasonably well, with some band 4 (operational manager) features in its dashboard view. It does not cover bands 1–3 at all and only gestures at band 6.
- The Ontara Console (`console/`) is an *architect-analyst band partial*: it covers parts of band 6 (model navigation, weighted relationship graph, glossary, governance view, KG status, reasoning vocabulary explorer). It does not cover band 7 (platform engineering) and does not cover bands 1–5 at all.
- The S198 surface architecture paper describes a full *band 6 surface* (the seven-canvas workspace with Agent Studio, the four interaction modes, the bounded agent roster, the capability matrix, the binding-grounded action class). This is a sophisticated and largely correct treatment of band 6 — and §9.2 of this paper argues that it should be retitled and rescoped accordingly.

Stage 9 will need to: (a) introduce the experience-API layer; (b) reframe the existing surfaces so that each one's band membership is clean rather than mixed; (c) add the missing surface families, particularly bands 1–3 for the cafe demonstrator; and (d) extend the architect-analyst surface (band 6) toward what S198 describes.

---

## 5. State Placement Discipline

State is a virtue *in the right places*. The temptation in a state-aware platform like Ontara is to make everything stateful as a default. The Perplexity research is clear that this is wrong: stateless components scale, stateful components remember, and a well-designed system needs both. This section sets out where state belongs in the Ontara architecture and why.

### 5.1 Properly stateful

The following are properly stateful and should be designed as first-class managed state:

- **The substrate (layer 2).** BR and BS hold canonical runtime truth. They must be transactionally consistent, queryable, and reasoning-tractable. Their state lives in the KG and (for high-frequency or specialised data) in bound stores observed by the substrate.
- **Workflow instance state (layer 3).** Long-running Temporal workflows hold their own internal state for the duration of the workflow. This is properly stateful and is one of the things Temporal exists for.
- **Configured model (layer 1).** The cafe BM and SM are static but they are stateful in the sense that they have a current version and a history. Edits change the configured model; the model has identity over time.
- **Audit and provenance.** PROV-O records of who did what, when, and why are inherently stateful — they accumulate. They live in the substrate.
- **Lifecycle and governance progression.** A module's lifecycle state, a governance promotion's progress through prerequisites, a clinical pathway's stage — these are properly stateful and should not be ephemeral.
- **Simulation runs.** Each simulation run is a stateful entity with a beginning, a progression, and a result. Simulation runs live in named graphs in the substrate per S197 §5.2.

### 5.2 Properly stateless

The following should be deliberately stateless wherever possible:

- **Experience APIs / BFFs (layer 4).** Composition contracts should not hold session state beyond what a single request requires. They should be horizontally scalable and individually replaceable. Their job is translation, not memory.
- **Edge APIs and render façades.** Anywhere a request comes in, gets transformed, and goes out — these should be stateless for elasticity.
- **Read-side projections and query façades.** The substrate may project runtime instances into specialised query-optimised stores for fast read access; these projections are derived state, recomputable from the canonical, and should not be treated as authoritative.

### 5.3 Properly ephemeral

The following are state, but local and short-lived:

- **UI session state.** The user's current selections, opened panels, wizard progress, draft form contents, optimistic UI updates. Lives in the surface itself. Lost on browser close, and that is correct.
- **Conversation history in agent interfaces.** What the user typed and what the agent replied during the current session. Has provenance value for audit purposes (per S198 §13 Q10, [[ontara-ref-work-items|OW-53]]) but is not BR/BS content.
- **Filter and sort state in dashboards.** The current selection of "show only orders from the last hour, sorted by elapsed time" is the user's current view, not part of the canonical model.

### 5.4 The discipline

The discipline is to know which category each piece of state falls into and to put it in the corresponding home. Two failure modes to actively prevent:

- **Canonical state leaking into ephemeral homes.** A draft order that exists only in the kiosk's session state is a lost order if the kiosk crashes. Canonical state must be in the substrate before the surface can claim the work is done.
- **Ephemeral state being treated as canonical.** A user's current selection on a manager dashboard is not part of the cafe BM. It does not belong in BR. Persisting it across sessions may be useful for UX but it is not a substrate concern.

Getting this wrong in either direction produces predictable failures. Getting it right is mostly a matter of being explicit about the discipline rather than letting state placement happen by accident. This paper commits the surface family work to the discipline; the eventual Stage 9 plan should make state placement decisions explicit for every new surface and contract.

---

## 6. The Cafe Walk-Through

This is the meat of the paper. The cafe demonstrator is walked across all seven user bands, with each band given a concrete scenario at three levels: (a) what the user sees and does, in familiar UI/UX terms; (b) what the surface reads from and writes to via the experience-API layer; (c) what happens in the substrate and the orchestration layer. The point is to show that the same canonical truth supports every user band, that the substrate and orchestration layers do the work, and that the surfaces themselves can be calm and ordinary while the platform underneath is sophisticated.

A note on the cafe demonstrator's actual current state (a hybrid toy example UI): the cafe app exists at `exercises/coffeeshop-demonstrator/` and runs end-to-end. It has a SvelteKit frontend with nine pages (Counter, Order Board, Management, Records, Audit Dashboard, Customer Voice, Pathway, System Status, Order Detail), 19 API routes, a Temporal cluster running the FulfilDrink workflow, an EHRbase CDR with three archetypes, and a PostgreSQL database with four tables. What it does *not* yet have is the experience-API layer, separate band-clean surfaces, or any customer-facing kiosk or mobile front. The walk-through below describes what each band's surface *would* look like in the headless framing, using the existing cafe back-end as the substrate.

For each band, the scenario is realistic and small — one customer ordering one drink, one shift in the cafe — so that the band-by-band view shows the same event from many angles.

### 6.1 User Band 1 — Customer at a kiosk

**Scenario.** Sara walks into the cafe at 09:14 on a Tuesday morning. She wants an oat-milk flat white. She has never used this specific kiosk before. She wants to order, pay, and walk away.

**(a) What Sara sees and does.** A simple touch-screen kiosk by the door. Large, calm typography. Two options on the first screen: "Order a drink," "Order food," Both are clearly selectable. She taps "Order a drink." then”Next”. The next screen shows a grid of drink categories with photos: Espresso-based, Filter, Cold, Speciality. She taps Espresso-based. The next screen shows the drinks in that category with prices and a small "milk options" button under each. She taps Flat White, then taps oat milk from the modal that opens, then taps Add to Order. The screen now shows her order summary: 1× Flat White (oat), £3.80, estimated ready in 4 minutes. She taps Pay, taps her contactless card on the reader, and gets a confirmation: order number 1247, ready at the collection counter when number 1247 lights up. She walks away. The whole interaction takes 35 seconds.

The familiar UI grammar here is *kiosk app* — kiosk apps are a well-established design idiom and Sara has used dozens of them in the wider world (airport check-in, fast-food ordering, transport ticket machines, library self-service). The kiosk surface obeys the conventions of the idiom: very large touch targets, no scrolling unless absolutely necessary, no hidden menus, calm and forgiving error states, immediate visual feedback for every tap, an obvious "back" affordance at every step, and an aggressive timeout that resets to the start if the user walks away mid-flow.

**(b) What the surface reads and writes via the experience-API layer.** The kiosk consumes a small set of contracts:

- `GET /experience/cafe/kiosk/menu/categories` — returns the drink categories currently available with their photos and a label. The surface caches this for the duration of the customer session.
- `GET /experience/cafe/kiosk/menu/category/{id}/items` — returns the items in the chosen category with prices, available customisations (milk options, syrups, sizes), allergen flags, and an `available` boolean. Items not currently available are not returned. This is computed by the experience API from BR (current inventory) and BS (current station readiness).
- `POST /experience/cafe/kiosk/order` — accepts an order intent (item + customisations + payment confirmation reference). Returns the order number, the estimated ready time, and the collection instructions.
- `GET /experience/cafe/kiosk/queue/depth` — optional, polled periodically by the kiosk to update the estimated wait shown on the order screen. Returns a single number: estimated minutes until a new order would be ready, computed from BS workflow queue depth.

The kiosk surface knows nothing about BMM, SMM, BR, BS, bindings, FulfilDrink workflows, or Temporal. It knows about contracts and view models. Everything model-aware happens in the experience-API layer.

**(c) What happens in the substrate and orchestration.** When Sara taps Pay and the payment is confirmed, the experience API receives the `POST /order` request and does the following:

1. Validates the order intent against the cafe BM definition of legal menu items (available items, valid customisations, current pricing). The cafe BM is the canonical authority for what an order *can* be.
2. Creates a new runtime instance: an Order in BR with a fresh ID (1247), customer reference (anonymous walk-in), items, total, timestamp, payment reference. This is a write to the substrate. The runtime instance is canonical immediately.
3. Initiates a FulfilDrink workflow execution in Temporal via the binding declared in the cafe SM. The binding declaration includes the binding metadata that S198 §7 makes load-bearing for action classification — but for this case, the action is a customer ordering a drink, which is the lowest-risk action class possible (band 1, low-stakes, well-bounded).
4. The Temporal workflow execution `w-1247-fulfil` is now alive in the orchestration layer. Its state is held by Temporal; the substrate observes it via the binding pipeline and records it in BS as a runtime instance of FulfilDrinkWorkflow.
5. The experience API returns to the kiosk: order number 1247, estimated ready time 09:18, collection instructions "Watch for your number on the collection display."
6. PROV-O provenance records are written linking Sara's anonymous session, the order runtime instance, the workflow execution, and the payment reference. These will be the audit trail if anything subsequently goes wrong.

Sara never sees any of this. She sees a confirmation and walks away. The substrate, the orchestration, and the experience API have all done their work without troubling her.

### 6.2 User Band 2 — Front-line operational staff at the counter

**Scenario.** Marcus is the barista on shift at 09:14 when Sara's order arrives. He is making drinks and serving in-person customers in parallel. He has used the cafe counter system every shift for six months and is fluent.

**(a) What Marcus sees and does.** A tablet mounted on the counter facing him, near the espresso machine. The screen shows a vertical column of order cards in submission order, each card showing the order number, the drink, customisations in bold, the elapsed time since submission, and a single big button at the bottom whose label depends on the order's current state. Sara's order appears as a new card at the top of the column the instant the kiosk submits it: "1247 — Flat White — OAT — 0:00 — Start." Below it are three other orders in various states ("1244 — Cappuccino — DAIRY — 1:32 — Mark Ready", "1245 — Americano — 0:48 — Start," "1246 — Latte — DAIRY — 0:21 — Start"). Marcus is mid-pour on 1244. He finishes pouring, places the cup on the collection rail, taps the big "Mark Ready" button on 1244's card. The card moves to a "Ready" section at the bottom of the screen. He taps "Start" on 1245 and begins pulling the espresso shot. Twenty seconds later he glances up, sees 1247 has appeared, and notes mentally that it's an oat milk one — he'll need to switch jugs. He doesn't tap anything yet; the workflow knows it's still in queue.

The familiar UI grammar here is *EPOS / kanban kitchen display system*. Counter-staff terminals in cafes, fast food outlets, and similar businesses have converged on this idiom: vertical stack of work cards, large single-action buttons, colour coding for elapsed time (white → amber → red as orders age), audible alerts for new orders, no general-purpose navigation, no settings, no other modes. The surface is a *single-purpose work tool*. Marcus has internalised it completely and it does not interrupt his actual work, which is making coffee.

**(b) What the surface reads and writes via the experience-API layer.** The counter terminal consumes:

- `GET /experience/cafe/counter/queue` (or a server-sent-events stream equivalent) — returns the current order queue for Marcus's station, ordered by submission time. Each entry has the order number, items, customisations, elapsed seconds, current lifecycle state, and the next legal action label. The contract knows the OrderLifecycle XState definition and translates BS state into the appropriate UI label.
- `POST /experience/cafe/counter/order/{id}/transition` — accepts a transition intent (`start`, `mark-ready`, `mark-collected`) and returns the updated order state. The contract validates the transition against the OrderLifecycle definition and rejects illegal transitions.
- `GET /experience/cafe/counter/alerts` — returns any operational alerts (machine warning, low milk, stuck order). The counter surface shows these as a compact strip at the top.

The counter terminal knows nothing about BMM, BS, Temporal, or workflow IDs. It knows about orders, transitions, and labels.

**(c) What happens in the substrate and orchestration.** When Marcus taps "Mark Ready" on order 1244:

1. The counter terminal `POST`s the transition intent to the experience API.
2. The experience API validates the transition against the OrderLifecycle XState definition (`InProgress` → `Ready` is legal; `Pending` → `Ready` would not be).
3. The experience API records the action invocation in BS — an action invocation runtime instance with: actor (Marcus, authenticated by the counter terminal session), action (`mark-ready`), target (order 1244 runtime instance), timestamp, scope (cafe-prod / counter-station-1).
4. The experience API signals the FulfilDrink workflow execution `w-1244-fulfil` in Temporal via the binding. Temporal's workflow advances its XState machine from `InProgress` to `Ready`.
5. Temporal emits a workflow event. The binding pipeline observes this and projects the new state into BS as an update to the workflow runtime instance.
6. The change in BS triggers a re-read by any surface currently watching this order: Marcus's counter terminal updates the card; the customer collection display (band 1, a different surface) lights up with "1244 ready"; the manager dashboard (band 4, yet another surface) updates its "in-progress count."
7. PROV-O records the action invocation, the workflow transition, and the surface notifications. The audit trail accumulates.

The same canonical fact — order 1244 is now ready — propagates through the substrate to every surface that cares, in the right shape for each. None of the surfaces holds its own state about this; they all read from BS and they all see the same truth.

### 6.3 User Band 3 — Back-office / supporting staff

**Scenario.** Elena is the kitchen prep person. She does food, not drinks. At 09:30 she is preparing a batch of breakfast pastries to replenish the front display. She also handles inventory checks at the start of her shift and during slack periods. Right now an alert is showing that oat milk is running low.

**(a) What Elena sees and does.** Her terminal is a tablet on the prep counter, mounted higher than the customer-facing kiosks but lower than the wall displays. Its UI is a simple two-pane layout: a list of current alerts on the left (today three: "Oat milk: 1.5 L remaining, projected to last 25 minutes," "Pastry case: 4 items remaining, replenish recommended," "Espresso machine: descale due in 2 hours"), and on the right whatever pane is currently active. Right now Elena has the inventory pane open, showing a list of items grouped by category with current stock levels and a "log change" button next to each. She just brought in two cartons of oat milk from the back storeroom and is logging the change: she taps "log change" next to "Oat milk," enters "+4 L," taps confirm. The alert disappears. She moves on to "Pastry case: 4 items remaining" — taps it, sees the recommended replenishment quantity, walks to the prep oven to pull out the next tray.

The familiar UI grammar here is *back-of-house operations console* — work queue + alert inbox + simple data entry, with a strong bias toward *one task at a time, completed quickly*. Elena does not need a dashboard, a calendar, a search bar, or settings. She needs to see what's wrong and fix it. Inventory adjustments are common enough that the friction must be very low: tap the item, type the change, confirm. Done. The aesthetic is closer to a warehouse handheld scanner than a manager dashboard.

**(b) What the surface reads and writes via the experience-API layer.** The back-office terminal consumes:

- `GET /experience/cafe/back-office/alerts` — returns currently open operational alerts for the cafe. Each alert has a type, a level (info/warning/critical), a recommended action, and a "snooze" / "acknowledge" / "fix" affordance set.
- `GET /experience/cafe/back-office/inventory` — returns current inventory state across categories. Each item has a current quantity, unit, threshold, and projected runout time computed from recent consumption rate.
- `POST /experience/cafe/back-office/inventory/{item}/adjustment` — accepts an inventory adjustment (delta + reason) and returns the new state.
- `POST /experience/cafe/back-office/alert/{id}/acknowledge` — acknowledges an alert.

**(c) What happens in the substrate and orchestration.** Elena's "log +4 L oat milk" action:

1. The back-office terminal `POST`s the adjustment intent.
2. The experience API records an InventoryAdjustment runtime instance in BR (actor Elena, item OatMilk, delta +4, reason "delivery from storeroom," timestamp).
3. The experience API updates the OatMilk inventory runtime instance in BR (current quantity now 5.5 L instead of 1.5 L).
4. A constraint evaluator (one of the cafe SM's `@ConstraintEvaluator` definitions, generated from the model) runs against the new inventory state. The "low oat milk" condition (threshold 2 L) is no longer met. The constraint evaluator's output updates BR's representation of the alert — the alert is now closed.
5. Any surface currently watching the alerts list (Elena's own terminal, the manager dashboard, the front-of-house barista terminal which had been showing the alert in its compact strip) re-reads and the alert disappears.
6. PROV-O records the action invocation, the inventory adjustment, the constraint re-evaluation, and the alert closure as a chain. If a future audit asks "why was the oat milk alert closed at 09:30?" the answer is "because Elena logged a +4 L delivery and the constraint evaluator re-ran and the threshold was no longer met." Every step is inspectable.

The substrate did the work. The surface displayed the alert and accepted the input. The orchestration layer ran the constraint evaluator. The experience API translated between them.

### 6.4 User Band 4 — Operational manager

**Scenario.** Jamie is the duty manager on shift. At 10:15 they are watching the morning rush wind down and starting to think about the lunch shift. They want to know how the morning has gone and whether anything needs attention before lunch starts. They are not making drinks or serving customers; they are *watching* the whole operation.

**(a) What Jamie sees and does.** A laptop in the small office at the back, plus their phone for floor-walk checks. The laptop shows a dashboard split into four regions: a header strip with today's headline metrics (orders served, takings, average prep time, exception count), a left column with current state at a glance (queue depth at each station, staff on shift, open alerts, governance compliance status), a centre region with a small set of charts (orders per hour today vs forecast, prep time distribution, takings vs target), and a right column with an action queue (anything Jamie is expected to handle: approval requests, escalated alerts, end-of-shift handover items). Right now the morning rush is over, takings are about 8% under forecast, and there are no open alerts. Jamie clicks on the "orders per hour" chart to see the breakdown — a hover reveals the morning had a slow start (cold weather, fewer walk-ins) and recovered after 09:30. They click on the staff column to check who is on the lunch shift and notice that one of the booked staff has called in sick. The dashboard surfaces a suggested replacement (the cafe has a small pool of casual staff with availability in BR) and offers a "send shift offer" button. Jamie reviews and taps send.

The familiar UI grammar here is *operational dashboard* — KPI strip, status panels, drill-down charts, action queue. Manager dashboards across hospitality, healthcare, and retail have converged on this idiom and managers expect it. The aesthetic is *calm, dense but not crowded, scannable from across the room, and tappable for any item that warrants action*. It is not an analytical tool — analytical tools live in band 6. It is an *operational awareness tool* with action affordances for the things the manager is actually expected to act on today.

**(b) What the surface reads and writes via the experience-API layer.** The manager dashboard consumes:

- `GET /experience/cafe/manager/today` — returns the headline metrics, current state, and computed anomalies. This is a substantial composition: aggregating order counts and takings from BR, queue depths and station readiness from BS, alerts from the constraint evaluator outputs, governance status from the governance vocabulary state, projection vs forecast from the cafe BM's financial planning content.
- `GET /experience/cafe/manager/charts/{period}/{metric}` — returns chart-ready data for a requested metric and period. The contract knows how to compute the data from the substrate.
- `GET /experience/cafe/manager/staff/today` — returns staff on shift, sick calls, lunch-shift booking, available casual replacements with their availability and historical performance summary.
- `POST /experience/cafe/manager/shift-offer` — sends a shift offer to a casual staff member via whatever notification binding the cafe SM declares for staff communications.
- `GET /experience/cafe/manager/actions` — returns the action queue: items awaiting Jamie's handling.

**(c) What happens in the substrate and orchestration.** When Jamie sends the shift offer:

1. The manager dashboard `POST`s the shift-offer intent.
2. The experience API validates the intent against the cafe SM's StaffShift definitions (legal staff member, legal time slot, legal offer expiry).
3. The experience API creates a ShiftOffer runtime instance in BR with the offer details and an expiry timestamp.
4. A notification workflow is initiated in Temporal via the bound notification service (SMS or push, whichever the cafe SM declares). The workflow is responsible for sending the notification, waiting for response, recording acceptance or decline, and notifying Jamie of the outcome.
5. The action invocation is recorded in BS. PROV-O links Jamie, the shift offer, and the workflow execution.
6. Jamie's dashboard updates to show "shift offer sent, awaiting response."
7. When the casual staff member responds (perhaps 2 minutes later, perhaps 20), the workflow updates BS, the dashboard re-reads, and Jamie sees the outcome.

Notice that this scenario — sending a shift offer — touches the same architectural elements as Sara ordering a drink (an action invocation, a workflow execution, a runtime instance creation, a binding-mediated effect on a real-world system, a substrate update, a surface re-read). The shape is identical. What differs is the band-level surface and the experience-API contract. The substrate is doing the same kind of work in both cases.

### 6.5 User Band 5 — Tenant admin / business owner

**Scenario.** Helen is the cafe's owner. She is at home on Wednesday evening reviewing the week so far and considering whether to introduce a new winter menu starting next Monday. She has no day-to-day operational role; she handles configuration, financial oversight, governance compliance, and longer-horizon decisions. She uses the platform once or twice a week for substantive work and occasionally for spot checks.

**(a) What Helen sees and does.** A laptop with the Ontara portal open. The portal shows her cafe domain in a familiar admin-console layout: a left sidebar with sections (Dashboard, Modules, Governance, Simulation, Settings), a main pane with the currently active section. She is in the Modules section looking at the cafe's installed modules (drink-ordering, food-ordering, customer-feedback, governance-monitoring, financial-reporting). Each module has a state indicator and a summary card. She wants to add a Seasonal Menu module from the catalogue. She clicks "Browse catalogue," sees a list of available modules including "Seasonal Menu," reads its description and prerequisites (depends on Drink Ordering, requires governance level Advisory or higher), clicks Install. The portal walks her through a configuration wizard: the season name (Winter 2026), the start and end dates, the menu items being added, the customisations being added or retired. She fills in the wizard and clicks Save Draft. The portal places the new Seasonal Menu module in the dashboard in Edit Mode (not yet activated). She wants to test it before going live — she clicks Simulate. The portal opens the Simulation Lab, lets her choose a generative module to feed it (Customer Traffic Generator with a "winter" assumption profile), and runs a comparative simulation against the current production menu over a synthetic week. She watches the comparative dashboard, sees the projected uptake on the new winter drinks, sees the projected impact on takings and prep times, and decides she's satisfied. She clicks Promote to advance the Seasonal Menu module from Edit Mode toward Production. The portal walks her through the promotion wizard's prerequisites (governance check, financial check, staff training acknowledgment, supplier confirmation, soft-launch period). She satisfies the first three, schedules the staff training for Friday, and saves the promotion as pending. She closes the laptop.

The familiar UI grammar here is *admin console / SaaS configuration portal* — sidebar navigation, settings sections, configuration wizards, dashboards, action histories. Tenant admins across thousands of SaaS products have converged on this idiom and Helen expects it. The Stage 8 portal as built sits roughly in this space already; what it lacks is the substrate connection (S198 §11.2) and the model-derived module catalogue (W-032).

**(b) What the surface reads and writes via the experience-API layer.** The tenant admin portal consumes:

- `GET /experience/cafe/admin/modules` — returns installed modules with their states, configurations, and dependencies.
- `GET /experience/cafe/admin/catalogue` — returns the available module catalogue (which, per S192-D7, should be derived from the SysML model rather than hand-seeded).
- `POST /experience/cafe/admin/module/{id}/install` — installs a module from the catalogue.
- `PUT /experience/cafe/admin/module/{id}/config` — updates module configuration.
- `POST /experience/cafe/admin/simulate` — initiates a simulation run with specified parameters.
- `GET /experience/cafe/admin/simulation/{id}/results` — returns comparative simulation outputs.
- `POST /experience/cafe/admin/promote/{id}` — initiates the promotion path for a module from a draft/edit state to production.

**(c) What happens in the substrate and orchestration.** When Helen installs the Seasonal Menu module and configures it:

1. The portal `POST`s the install intent.
2. The experience API validates against the cafe SM's module composition rules (the new module's dependencies are met, its concern overlap is compatible with existing modules, the cafe BM is in a state that allows new module installation).
3. The experience API creates a new module runtime instance in BR with state `Installed → Edit Mode` and the configuration draft Helen provides.
4. The portal returns Helen to the dashboard with the new module visible.

When Helen runs the simulation:

5. The experience API initiates a simulation run via Temporal in synthetic-binding mode. The simulation creates a named graph in the substrate per S197 §6.2 and runs the Customer Traffic Generator module against the new and current menu configurations in parallel, aggregating outputs into the comparative dashboard.
6. The simulation is a stateful runtime instance with a beginning, a progress trace, and a result. It lives in the substrate.
7. The comparative outputs are computed by the experience API from the simulation's projected events.

When Helen promotes:

8. The promotion intent is recorded as an action invocation in BS.
9. The promotion workflow runs in Temporal. It evaluates the prerequisites, gates on those that are not yet met (staff training is scheduled but not complete), and holds the promotion in a `Pending` state until the gates clear.
10. The action invocation, the prerequisite evaluations, the wizard inputs, and the eventual completion (or failure) are all recorded in BS via PROV-O. Helen's promotion is auditable end-to-end.

This is the band where S198's first-class approval primitive (§9 of that paper) becomes important. The promotion is not a state toggle — it is a structured action that requires approval gates, evidence of prerequisite satisfaction, and a clear lifecycle. The Stage 8 portal partially implements this and Stage 9 will extend it.

### 6.6 User Band 6 — Tenant architect-analyst

**Scenario.** Dev is the cafe's contracted architect. They visit the cafe model once or twice a month, mostly to add new products, adjust the workflow definitions when the cafe changes its operations, and respond to questions from Helen. Today (Thursday) Helen has asked Dev to look at whether the Seasonal Menu module she configured yesterday is using the right structure for the discount on bundled drink-and-pastry purchases. Dev opens the architect workspace.

**(a) What Dev sees and does.** A laptop with the architect workspace open. The workspace looks much like S198 describes: a scope rail on the left showing tenant (cafe-prod), domain (cafe), environment (staging), selected scope (Seasonal Menu module); a centre canvas hosting whichever surface Dev has open (currently Model Map); a right-hand dock with Agent Studio, Impact & Diff, the approval drawer, and Evidence Peek. Dev is looking at the Seasonal Menu module's representation in the cafe BM and SM. They navigate to the discount definition and see that Helen's wizard has placed it as a `BundleDiscount` of type `PercentageOff` with a flat 10% rate. Dev knows from previous conversations that the cafe's existing pastry discounts use `FixedAmountOff` for accounting reasons — the percentage form would create a small reconciliation mismatch with the cafe's POS reporting. Dev opens Agent Studio in Plan mode, types: "Convert this BundleDiscount from PercentageOff to FixedAmountOff equivalent at the current menu prices, preserving the customer-facing discount value." The Model Analyst agent drafts a structured plan: change the discount type, compute the equivalent fixed amount for each bundle combination, update the constraint evaluator that calculates the discount at order time, surface the impact on the cafe BM's financial planning content. Dev reviews the Impact & Diff in the dock — three model elements affected, no governance constraints triggered, no approval required for a draft change in staging. Dev runs Simulate to verify the change produces the same customer-facing prices, sees the comparison check come back clean, and clicks Act to apply the change in staging. The change is now live in the staging environment of the cafe SM. Dev sends Helen a message: "Looked at the discount, converted it to fixed-amount form to keep the POS reconciliation clean. Try it in staging — it should look identical to customers."

The familiar UI grammar here is the S198 paper's architect workspace — model navigation, agent-mediated planning, structured action invocation, approval-gated execution where required. This is user band 6 territory and S198 covers it well. What this paper adds is the *band locality* of S198's framing: this is one band of seven, not the whole surface. Dev is doing something that is genuinely architectural — editing the cafe SM in a meta-aware way — and the workspace is appropriate for that. Helen the owner does not need this workspace; Marcus the barista certainly doesn't.

**(b) What the surface reads and writes via the experience-API layer.** The architect workspace consumes a much richer set of contracts than the lower bands, because it deals directly with model content and needs flexible querying:

- `GET /experience/cafe/architect/model/element/{path}` — returns a model element (BM or SM) with its full structure, its annotations, its cross-references, its current configuration.
- `POST /experience/cafe/architect/agent/plan` — submits a Plan-mode intent to the appropriate agent and returns a structured plan artefact.
- `POST /experience/cafe/architect/agent/simulate` — runs Simulate on a draft plan.
- `POST /experience/cafe/architect/agent/act` — applies an approved plan to the staging or production environment.
- `GET /experience/cafe/architect/diff` — computes Impact & Diff for a draft plan.
- `GET /experience/cafe/architect/binding/{id}` — returns a binding's metadata and current state.
- `POST /experience/cafe/architect/query/sparql` — executes a SPARQL query against the substrate (with safety scopes).

These contracts are substantially more powerful than the lower bands' contracts and they expose model concepts directly in the response shapes. That is appropriate for band 6 — Dev knows what a model element is, what a binding is, what an action invocation is. The contracts are not hidden behind task-shaped views the way the lower bands' contracts are.

**(c) What happens in the substrate and orchestration.** Dev's discount change touches the cafe SM (the constraint evaluator definition and the bundle pricing rules) and the cafe BM (the financial planning content that references the bundles). The change is a *configured-model edit*, not a runtime instance creation. It propagates through the generation pipeline (which regenerates the constraint evaluator), is validated against the BMM/SMM constraints (the meta level becomes visible at this band — the change must produce a legal SM under the SMM template), and is recorded as an action invocation in BS with PROV-O provenance. The simulation runs against staging in synthetic-binding mode and verifies the customer-facing outcome. The Act invocation applies the change to the staging environment of the cafe SM, which means the staging deployment now has the new constraint evaluator. A subsequent promotion to production would need approval per the cafe's governance configuration.

This band's contracts do touch the meta level. Dev's plan validation includes checking that the new discount type is a legal `BundleDiscount` subtype under the SMM. The agent's plan generation uses BMM/SMM-aware reasoning. The Impact & Diff rendering shows model-element-level changes. None of this would be appropriate for any of the lower user bands.

### 6.7 User Band 7 — Ontara platform engineer

**Scenario.** It is Friday morning. The Ontara platform engineering team (in practice, today, Ella) is working on extending the SMM with a new pattern for *bundle discounts as first-class structural elements* — because the discussion with Dev yesterday (band 6) surfaced that the current discount handling in the cafe SM is bolted on rather than properly modelled, and the same issue will recur in Paws (multi-dog discount) and Suds (bulk-laundry discount). The right fix is at the meta level.

**(a) What the engineer sees and does.** Several windows open: VS Code with the SysML model files for the SMM, a terminal session for the generation pipeline and tests, Claude Code in another terminal for instruction-set work, the Ontara Console open in a browser tab to inspect the metamodel state visually, the GraphDB Workbench in another tab for direct SPARQL exploration, the Obsidian vault for design notes and the master register, the Architecture Papers Index for cross-reference. The work is *engineering on the platform itself*: editing `.sysml` files in the SMM, regenerating the OWL output via the pipeline, running the SPARQL validation suite, checking HermiT consistency, updating the master register, writing a new pattern note in the concept graph, and updating the cafe SM to use the new pattern instead of the old bolted-on discount handling.

The familiar UI grammar here is *software engineering* — IDE, terminal, source control, test runners, design notebooks. There is no special "platform engineer surface" because the platform engineer is using the same tools software engineers everywhere use. What is different is the *substrate* they are working against: the SysML model, the OWL pipeline, the KG, the SPARQL suite, the comprehension architecture, the workflow guide, the master register. The Ontara Console is the closest thing to a band-7-specific surface, and it serves as a model navigation and inspection tool *alongside* the engineering work, not as a replacement for it.

**(b) What the surface reads and writes via the experience-API layer.** Largely *not via the experience-API layer at all*. Band 7 work mostly happens at the substrate and canonical-model layers directly, mediated by the generation pipeline and the development tooling. The Ontara Console (which is a band-7-adjacent surface) does consume some experience-API-shaped contracts to render its views — but in current Ontara those contracts are served by the comprehension JSON generated by `gen_model_introspection.py` and read by the console as static data, rather than by a live API layer. Stage 9 will likely add proper experience APIs for the console as well, at which point the console becomes a more conventional band-6 / band-7 consumer.

Where band 7 *does* consume experience APIs is when it is *testing* the platform — running cross-tenant queries, validating that a meta-model change doesn't break any existing tenant's configured model, checking that the generation pipeline produces correct output. Those are read-side operations against the substrate and they benefit from stable contracts.

**(c) What happens in the substrate and orchestration.** When Ella adds the new BundleDiscount pattern to the SMM:

1. The SysML files are edited directly (the meta-model files in `model/`).
2. The generation pipeline runs, producing updated OWL output, updated comprehension JSON, updated constraint evaluators, updated console data sources.
3. The SPARQL validation suite runs, confirming HermiT consistency and the new pattern's well-formedness.
4. The cafe SM is updated to use the new pattern: the bolted-on discount handling is removed, replaced with a proper `BundleDiscount` instance.
5. The cafe SM regeneration produces new constraint evaluators in the cafe demonstrator's generated code.
6. The cafe demonstrator's Temporal workflow definitions are updated to call the new evaluator.
7. The cafe demonstrator is redeployed to staging.
8. Dev (band 6) is notified that the meta-model change is in staging and that the cafe SM has been migrated to use it; Dev verifies in the architect workspace that the staging behaviour is correct.
9. Helen (band 5) is eventually notified that there is a configuration update available; she promotes it to production through her governance flow.
10. Marcus, Elena, Jamie, and Sara (bands 1–4) experience no visible change — bundles still discount the same way they always did, just now from a properly modelled construct rather than a bolted-on rule.

This is the load-bearing observation about the gradient: a change at the top propagates through every band underneath it, but the change is *only visible* at the bands where it matters. The platform engineer sees the meta-model edit. The architect sees the cafe SM change. The owner sees a configuration update. The manager and staff see nothing different. The customer sees nothing different. The whole gradient is doing its job — concentrating sophistication at the top, ordinary-business-software calm at the bottom.

### 6.8 What the cafe walk-through shows

Walking the cafe through all seven bands at the same level of substrate detail surfaces several observations:

- **The substrate is genuinely shared.** Every band reads from and writes to the same BR/BS. There are no parallel data structures, no shadow truth, no per-band databases. Sara's order, Marcus's transition, Elena's inventory adjustment, Jamie's shift offer, Helen's module installation, Dev's model edit, and Ella's meta-model edit all live in the same canonical store. This validates the S197 substrate paper at the surface-family level.
- **The experience-API layer is essential.** Every band's surface needs a different shape of view model. Without the layer, each surface would either re-implement business logic or display raw substrate facts. With the layer, surfaces are calm and substrate is canonical and there is no leakage in either direction.
- **The familiar UI grammars are wildly different.** A kiosk app, a counter terminal, a back-office console, a manager dashboard, an admin portal, an architect workspace, and an IDE-plus-terminal are seven different design idioms. They share nothing visually. They share everything substratively.
- **The four levels of model are touched at different bands.** Customers and staff (bands 1–3) touch only runtime instances, mediated by the experience-API layer. Managers (band 4) touch projections over runtime instances. Tenant admins (band 5) touch configured models via wizard-style configuration. Architects (band 6) touch configured models with meta-model-aware tooling. Platform engineers (band 7) touch the meta models themselves. The terminological discipline from §2 is observable in the walk-through; if any band were given access at the wrong level, the surface would be wrong for that band.
- **The S198 architect surface is one of seven.** Walking band 6 in detail confirms that S198's framing is correct *for that band* — the four-mode interaction model, the bounded agent roster, the binding-grounded action class all work and are appropriate. They are simply not appropriate (and never were) for the bands below. S198's mistake was not its content; it was its scope claim.
- **The portal and the console are partial surfaces.** The Stage 8 portal is a band-5 partial; the Ontara Console is a band-6/7 partial. Stage 9 will need to extend both and add the missing surface families for bands 1–4.

The walk-through is also a test of S197 and S198. The substrate paper holds up: every action in the walk-through is expressible as a query or action invocation against BR/BS via a binding. The surface architecture paper holds up *at band 6* and is silent (correctly, on this paper's reading) about the other bands. Both papers' commitments survive into the larger framing.

---

## 7. Paws Cross-Domain Check

*This section is deferred to Session 200. The intent of the Paws walk-through is to test the seven-band framing against an appointment-based service business with a different interaction shape from the cafe's walk-in immediacy. Key questions to be addressed:*

- *How does band 1 (customer) shift when the customer-facing interaction is a booking flow rather than a kiosk transaction? The customer interacts with Paws through a booking surface days or weeks before the service is rendered, not in the moment.*
- *How does band 2 (front-line staff) shift when the front-line staff person is a groomer working with a dog rather than a barista taking an order? The interaction is longer, more variable, less standardised.*
- *How does the [[concept-service-subject|ServiceSubject]] / [[concept-service-participant|ServiceParticipant]] distinction surface in the experience-API contracts? The dog is the subject; the owner is the participant who pays. The contracts must keep these distinct.*
- *Does the band compression (§3.5) become more pronounced for a single-groomer business that has no separate manager or owner role?*

*Paws will test that the seven-band framing is not Cafe-specific.*

---

## 8. Suds Cross-Domain Check

*Also deferred to Session 200 (or to Session 201 if Paws fills S200). The intent of the Suds walk-through is to test the framing against a batch-processing service business with a longer-cycle interaction shape and meaningful regulatory governance (COSHH). Key questions:*

- *How does band 3 (back-office staff) become more prominent when the work is batch processing rather than per-customer service? The Suds operator running washing machines is the load-bearing operational role; the customer-facing roles are smaller.*
- *How does the COSHH governance content surface in the manager (band 4) and tenant admin (band 5) views? These bands need to see governance compliance state in a familiar dashboard idiom, not as model content.*
- *Does the constraint hierarchy (HardConstraint / SoftConstraint / GradedRule) translate cleanly into surface-level UI affordances at the manager and admin bands?*

*Suds will test that the framing handles regulatory governance at the surface without breaking the calm-and-ordinary commitment for the lower bands.*

---

## 9. Implications for the Architecture

This section sets out what this paper does to the rest of the architecture. The implications are substantial but not destabilising — most existing artefacts survive in place with their scope sharpened or their location within the larger picture made explicit.

### 9.1 The substrate paper (S197) is reinforced

Walking the cafe through all seven bands tests the S197 substrate paper against a much wider range of interactions than the substrate paper itself examined, and the substrate framing holds up cleanly. Every action in the walk-through is expressible as a query or action invocation against BR/BS via bindings. The substrate is genuinely the load-bearing element. The S197 paper's framing is unchanged by this paper; this paper depends on it and validates it through use.

### 9.2 The S198 surface architecture paper is relocated

S198 is *not* the operator surface architecture for the platform. It is the architect-analyst-admin band (band 6) surface architecture, and it is mostly correct in that scope. The four interaction modes (Ask / Plan / Simulate / Act), the bounded agent roster, the binding-grounded action class, the capability matrix, the structured approval primitive — all of these are appropriate and load-bearing for band 6 and survive intact within this paper's framing.

What needs to change about S198 is its *titling and scope claim*. The current title — *The Operator Surface: Workspace, Agents, Modes, and Bindings* — implies it covers the operator surface in general, which it does not. A more accurate title would be *The Architect-Analyst Workspace: Surfaces, Agents, Modes, and Bindings*. The body of the paper would then be self-consistent with its title and the larger surface architecture conversation would not be obscured by S198's scope overreach.

This paper does *not* directly rewrite or supersede S198. The recommended treatment is:

1. Add an OW item recording that S198 should be retitled and rescoped when next revised.
2. Treat S198 as authoritative for band 6 and reference it explicitly as such in this paper and in subsequent surface conversations.
3. When the Stage 9 plan references the "operator surface," it should distinguish the band — band 6 references can point to S198, band 1–5 references must point to this paper.
4. S198's own §2.1 ("three audiences, one workspace") becomes the section that most needs updating: the three audiences are not audiences for the workspace, they are audiences for *different surface families*, and the workspace is band 6's surface family alone.

This is a material reframing of S198 and should be acknowledged honestly. It is not a rejection — it is a relocation. S198's actual content survives and is strengthened by being placed in the right scope.

### 9.3 The Stage 8 portal is located within user band 5

The Stage 8 portal is an existing partial implementation of user band 5 (tenant admin / business owner). Its dashboard view leans into band 4 (operational manager) territory; its module composition view is unambiguously band 5; its governance and promotion features are band 5. It does not cover bands 1–3 at all and only gestures at user band 6. The substrate gap S198 §11 already identifies (SQLite → KG-resident BR/BS) is a real problem that Stage 9 must address.

The portal as built sits roughly in the right band but consumes from its own SQLite store rather than from a proper experience-API layer over the substrate. The Stage 9 plan should:

1. Introduce the experience-API layer as a Stage 9 architectural element.
2. Reframe the portal's data layer to consume from band-5 experience-API contracts rather than directly from SQLite.
3. Derive the portal's module catalogue from the SysML model (S192-D7, [[ontara-ref-work-items|OW-32]]) rather than hand-seeding it.
4. Sharpen the portal's band 5 focus by trimming or relocating the dashboard's band 4 features into a separate manager surface.
5. Connect the portal's promotion path to S198's structured approval primitive when the latter is implemented.

The portal's existing visual aesthetic (warm teal theme, Flowbite Svelte, schema-driven configuration forms, lifecycle state machines, progressive governance) is band 5 appropriate and largely survives.

### 9.4 The Ontara Console is located within user bands 6–7

The Ontara Console is an existing partial implementation of user bands 6 and 7. Its model navigation, weighted relationship graph, glossary, governance view, KG status, and reasoning vocabulary explorer are all band 6 / band 7 features. It is not a band 5 portal (it does not have configuration wizards or composition flows) and it is not a band 1–4 surface (it does not have customer or staff or manager views).

The console's relationship to S198's architect workspace is the substantive open question. S198 §13 Q2 ([[ontara-ref-work-items|OW-49]]) records the unresolved choice: collapse the console into the workspace, or keep them as two coordinated applications. This paper does not resolve the choice but observes that:

- If the choice is collapse, the console's existing views become surfaces within the architect workspace.
- If the choice is two coordinated applications, the console remains as the model navigation and inspection surface for band 6/7 use that does not require the agent-mediated Plan/Simulate/Act flow.

Either way, the console is a surface family member at bands 6–7 and is not the operator surface in any larger sense.

### 9.5 The cafe demonstrator's frontend is a mixed-band legacy surface

The cafe demonstrator's existing SvelteKit frontend (`exercises/coffeeshop-demonstrator/packages/web/`) is a *single mixed-band surface* toy hybrid that combines elements of bands 2, 3, 4, and 5 in one application. Its Counter page is band 2, its Order Board page is band 3, its Management page is band 4–5, its Audit Dashboard is band 4, its Customer Voice page is band 1-adjacent (a feedback collection surface), its System Status page is band 4–7, and its Pathway page is band 6.

This mixing was appropriate for a demonstrator built before the user band framing existed. It is not a model for real life or how surfaces should be structured going forward. Stage 9 should reframe the cafe frontend as several distinct surfaces — a kiosk surface, a counter terminal, a back-office terminal, a manager dashboard, and (already partly elsewhere) the portal for band 5 — each consuming the appropriate experience-API contracts. The existing pages serve as design references for what each surface needs to do, but they are not the right structural decomposition.

### 9.6 The experience-API layer is a new architectural element

The most consequential addition this paper makes to the architecture is the experience-API / BFF layer. It is currently absent. Stage 9 must introduce it. Several design decisions follow:

- **Deployment topology.** Stateless services, horizontally scalable, deployed alongside or behind the substrate. Likely co-deployed with the surface families they serve, at least initially.
- **Contract definition language.** The contracts should be defined declaratively, ideally generated from the SysML model where possible (per S192-D7 generalised), and versioned independently of the substrate.
- **Composition style.** Each contract is a thin composition over substrate queries and action invocations. No business logic in the experience API beyond what is necessary to translate between substrate shape and surface shape.
- **Observability.** Every experience-API request is recorded as an observation on the substrate side (which surface, which contract, which user, which scope, what view model returned). This supports the audit and provenance commitments.

These decisions are open and should be addressed in Stage 9 planning. The architectural commitment this paper makes is that the layer exists and that its role is composition, not business logic.

### 9.7 The master register additions

Several concepts from this paper should be added to the master register, alongside the additions already proposed by S197 and S198 (W-043). The relevant additions:

- **Sophistication gradient** as an empirical structural concept. Section B (Structural Architecture Concepts) or section J (Development Methodology and Process Concepts).
- **Surface family** as a structural concept. Section B.
- **Headless composition** as a validated platform pattern. Section D, once realised in implementation.
- **Experience API / BFF layer** as a structural architectural element. Section B.
- **State placement discipline** as a guiding principle. Section A or as a methodology entry in section J.
- **Band locality** (the principle that a surface belongs to a band and should not span bands without strong reason) as a design pattern. Section D.
- **The four-level distinction** (metamodel / configured model / runtime instance / realising component) as a foundational concept. Section A or section B. Possibly an amendment to [[principle-two-meta-model-distinction|A4]] that makes the four levels explicit rather than only the two-metamodel commitment.
- **Non-constraining bands** as a guiding stance — the commitment to treating empirical band cuts as revisable working hypotheses rather than fundamental taxonomy. Section J.

These should be considered as part of W-043 when that work item is taken on, alongside the S197 and S198 additions.

### 9.8 W-042 is broader than originally scoped

The terminological cleanup tracked as W-042 (BMM/SMM runtime state phrasing) is broader than its current scope of "two paragraphs in two papers." It is a habit of phrasing that needs watching across all subsequent documents. The new paper produced by S199 (this paper) commits to the precise vocabulary throughout, and §2 makes the discipline explicit. W-042's scope should be expanded at next update to include: a pass over all currently active reference documents to retire the malformed phrasing where it occurs, plus a standing convention that future documents use the precise four-level vocabulary.

---

## 10. Open Questions for Stage 9 Planning

The following questions remain open and should be resolved during Stage 9 planning:

**Q1.** What is the contract definition language for experience APIs? OpenAPI, GraphQL, gRPC, hand-rolled JSON contracts, or model-derived from SysML? Each has trade-offs for clarity, tooling, and integration with the generation pipeline.

**Q2.** What is the deployment topology of the experience-API layer? Co-deployed with each surface family, centralised, or per-tenant? The choice affects scaling, latency, and fault isolation.

**Q3.** Which surface families should Stage 9 build first? The cafe walk-through suggests bands 1, 2, and 4 (customer kiosk, staff counter terminal, manager dashboard) as the natural first set because they exercise the substrate end-to-end and have clear value. Band 5 already exists in partial form (the portal); band 6 already exists in partial form (the console plus the S198 design).

**Q4.** How are surface families authenticated and authorised? The customer kiosk is anonymous; the staff terminal is per-station; the manager dashboard is per-user; the architect workspace is per-architect with strong audit. Different bands have different authentication needs and the experience-API layer must accommodate them.

**Q5.** What is the relationship between the experience-API layer and the existing SvelteKit API routes in the cafe demonstrator? The 19 API routes are essentially band-mixed experience-API contracts in disguise. Are they the prototype of the proper layer, or are they replaced when the proper layer arrives?

**Q6.** How does the gradient handle the small-business compression case (§3.5) in implementation? Is there a "small business composite surface" that consumes from multiple band contracts, and if so, how is it structured?

**Q7.** What is the testing strategy for surfaces over a shared substrate? Each surface family will need its own test approach, but the contracts they consume are the same — should there be a contract-level test suite that every surface implementation can rely on?

**Q8.** How do the band 1 (customer) surfaces handle offline operation? A kiosk with intermittent connectivity, a mobile pre-order app on a slow connection, an in-store tablet with no signal — these need degradation strategies that the substrate-first architecture must accommodate.

**Q9.** How does the band 7 (platform engineer) work feed back into the existing development workflow (workflow guide, Claude Tooling Guide, Stage progression)? Band 7 is partly already organised by the workflow guide; this paper observes that and does not duplicate it.

**Q10.** What is the right approach for surface-family discovery and onboarding? When a new tenant is created, how do they discover which surface families are available to them and how do they install or activate the ones they need? This is partly a portal feature and partly a platform feature.

---

## 11. Register Connections

### 11.1 Principles directly engaged

| Principle | Engagement |
|---|---|
| [[principle-separation-representation-execution\|A1]] | The surface initiates and the substrate observes; the surface never bypasses the binding/observation loop. Every band's writes go through structured action invocations; every band's reads come from the substrate via experience APIs. |
| [[principle-self-describing-system\|A2]] | Each band's surface presents the system's state in the shape appropriate for that band. The system describes itself differently to different audiences without changing what it is. |
| [[principle-model-generates-everything\|A3]] | The configured model generates the substrate's structure; the substrate (plus the orchestration layer) is consumed by experience APIs which serve the surfaces. The whole stack is generated rather than independently authored. The experience-API contracts themselves should eventually be model-derived. |
| [[principle-two-meta-model-distinction\|A4]] | The four-level distinction (§2) makes the meta / model / instance separation explicit. This may warrant an amendment to A4 to record the four-level structure explicitly. |
| [[principle-validate-in-toy-domains-first\|A5]] | The cafe walk-through is the first validation of the seven-band framing in a toy domain. Paws and Suds will provide the cross-domain validation. |
| [[principle-clinical-governance-first-class\|A8]] | Governance content surfaces in the manager (band 4) and tenant admin (band 5) views in the form of dashboards, alerts, and approval flows — first-class but in the appropriate UI grammar. |
| [[principle-discipline-as-load-bearing-structure\|A9]] | The state placement discipline (§5), the terminological discipline (§2), the band-locality discipline (every surface belongs to a band) are all disciplined working practices that propagate reliability through the surface family architecture. |
| [[principle-intrinsic-self-knowledge\|A10]] | Surfaces present what they know and how they know it — freshness annotations on data displays, audit trails accessible from any band's relevant view. |
| [[principle-unity-principle\|A11]] | One substrate, one set of canonical truths, many surfaces. The unity principle is the load-bearing commitment that makes headless composition possible. |
| [[concept-multi-tenancy\|A13]] | Every surface family is platform infrastructure parameterised by tenant context. The cafe surfaces and the Paws surfaces and the Suds surfaces are not bespoke applications — they are tenant-scoped manifestations of common surface families. |
| [[concept-co-evolution\|J2]] | The substrate, the orchestration layer, the experience APIs, and the surface families must co-evolve. Building any one without the others is incomplete. |
| [[concept-non-constraining\|J3]] | The seven-band cut is a working empirical classification, not a fundamental taxonomy. The architecture is committed to the gradient and to headless composition, not to the specific bands. |

### 11.2 Concepts to add to the master register

(See §9.7 for the full list. Repeated here as a stable reference.)

- Sophistication gradient (B or J)
- Surface family (B)
- Headless composition (D, when realised)
- Experience API / BFF layer (B)
- State placement discipline (A or J)
- Band locality (D)
- Four-level distinction — metamodel / configured model / runtime instance / realising component (A or B; possibly A4 amendment)
- Non-constraining bands (J)

These additions should be considered alongside the S197 and S198 register changes already tracked as W-043.

### 11.3 Observations and watchpoints to deposit

The following observations should be deposited in the [[ontara-ref-work-items|OW register]] at C2:

| Summary | Work type | Notes |
|---|---|---|
| The seven-band cut is empirical and revisable; subsequent surface design work should test whether the cuts hold up under concrete content and revise them where they do not | ARC, CON | Standing observation; relevant whenever surface design work is in scope |
| The S198 paper should be retitled and rescoped to "The Architect-Analyst Workspace" when next revised; its content survives but its scope claim is wrong | ARC, GOV | Editorial; do at next S198 revision opportunity |
| The experience-API layer is a Stage 9 architectural addition; its design is open and important | ARC, CON | Stage 9 design dependency |
| The cafe demonstrator's mixed-band frontend should be reframed as several band-clean surfaces during Stage 9 | CON | Implementation work for Stage 9 |
| The terminological discipline (BMM / BM / runtime instance) should be enforced in every new document; W-042's scope is broader than originally tracked | GOV | Standing convention |
| Band compression in small businesses (§3.5) is a feature, not a bug; the experience-API layer's stability is what makes composite small-business surfaces tractable | ARC, CON | Design observation; relevant for Stage 9 sequencing |
| Paws and Suds cross-domain checks remain to be done (§7, §8); deferred to S200 (Paws) and S200/S201 (Suds) | ARC, XDV | Next-session work |
| The four-level distinction may warrant a register entry of its own or an amendment to [[principle-two-meta-model-distinction\|A4]] | ARC, GOV | Address as part of W-043 |

---

## 12. Critique Observations and Watchpoints

This paper underwent a structured critique pass at the end of its drafting (per [[ontara-workflow-guide|workflow guide]] §1 commitment 5 / §2.2). The critique findings are recorded here.

### 12.1 Concerns identified

**1. The seven-band cut is asserted, not derived.** §3.1 sets out seven user bands and says they are empirical, but the paper does not show its working — it does not demonstrate that the cuts emerged from concrete observation. This is partly a presentation problem (the cuts did emerge from walking the cafe scenarios, but the walk-through in §6 is presented after the cuts are stated rather than as their justification) and partly an epistemic risk (someone reading the paper might take the seven bands as authoritative when they are working hypotheses). Mitigation: §3.4 makes the non-constraining stance explicit, and §6.8 confirms that the cafe walk-through validated the cuts in the cafe domain. Paws and Suds are still to come and may produce revisions.

**2. The experience-API layer is a substantial new architectural element introduced in passing.** §4.4 makes the case for it but the design is open and the paper does not work through the open questions in detail. Stage 9 planning will need to address it carefully. Mitigation: §10 lists the open questions explicitly so they are not lost.

**3. The relocation of S198 is a material change to a paper that was written four days ago.** This is a non-trivial walk-back and it needs to be done honestly. S198 was a substantial piece of work and saying "actually, this is one band of seven, not the operator surface" is a significant scope change. Mitigation: §9.2 is explicit about what changes (the title and scope claim) and what does not change (the actual content of S198 is correct for band 6). The OW register entry is a pointer to do the editorial work cleanly when next opportunity arises.

**4. The Cafe walk-through is long and detailed; the paper as a whole runs long.** The walk-through is the meat of the paper but it is repetitive in shape (every band's scenario follows the same a/b/c structure) and that repetition is necessary for the comparison to work. Mitigation: this is a feature of the structure and should not be trimmed; the deferred Paws and Suds walk-throughs will not need to repeat the framing material and can be terser.

**5. The paper depends on the headless framing being correct, and the headless framing is largely imported from the Perplexity research.** The same risk identified for S198 (§15.1 of that paper) applies here: significant material is adopted from external research without being independently derived. Mitigation: the headless framing is well-established in the wider software industry and is not Ontara-specific; what this paper contributes is the *binding of the headless framing to Ontara's specific substrate and gradient*. The gradient is Ontara-specific and is not in the research; the binding is therefore the Ontara contribution. The reliance on the research for the headless layer model is acknowledged in §1.2 and §4.

**6. The cafe walk-through assumes some experience APIs that do not yet exist.** Sections 6.1–6.7 describe contracts like `GET /experience/cafe/kiosk/menu/categories` that are illustrative. The cafe demonstrator's existing 19 SvelteKit API routes do not map onto the proposed contracts directly; they are mixed-band and need restructuring. Mitigation: §9.5 acknowledges that the cafe frontend will need reframing in Stage 9 and the existing routes are not the right structural decomposition.

**7. The paper does not address the small-business composite surface in detail.** §3.5 raises the issue and §10 Q6 notes it as open. The pattern by which several user band contracts get assembled into a single small-business surface is a real design problem and is not worked through. Mitigation: it is identified and deferred; Paws (which has small-business cases) will provide concrete material.

**8. The four-level distinction in §2 may warrant its own dedicated paper or register section.** §2 is short but the distinction is fundamental and could justify deeper treatment. Mitigation: §9.7 and §11.2 propose register additions for the four-level structure; deeper treatment can be a future paper if Stage 9 work surfaces the need.

### 12.2 What the critique does not find

- A fundamental conceptual error in the gradient framing. The seven user bands may not be the right cut, but the existence of a gradient (rather than three audiences for one workspace) is empirically supported by the demonstrator scenarios.
- A conflict with the S197 substrate paper. The two papers are mutually consistent; this paper validates the substrate paper through use.
- A conflict with the existing portal or console at the structural level. Both are partial surfaces in the right bands; reframing them within the gradient does not invalidate the work done.
- A category error in the four-level distinction. The terminological discipline is internally consistent and aligns with the S196 and S197 clarifications.
- A conflict with existing Tier 1 principles. The §11.1 cross-check confirms engagement with A1, A2, A3, A4, A5, A8, A9, A10, A11, A13, J2, and J3.

### 12.3 Predictions to carry forward as watchpoints

- The seven-band cut will be revised by the Paws and Suds walk-throughs in S200 / S201. The revisions should be incorporated into a refresh of this paper rather than papered over.
- The experience-API layer's design will surface decisions (contract language, deployment topology, model-derivation strategy) that this paper does not address. The Stage 9 plan should treat the design of the experience-API layer as a substantial workstream, not an afterthought.
- The relocation of S198 will be tested when the architect workspace is implemented in Stage 9. If the implementation comfortably fits within band 6, the relocation is correct. If band 6 turns out to be too narrow for what S198 describes, the band cuts may need revision (perhaps splitting band 6 into architect and analyst sub-bands).
- The cafe demonstrator's existing SvelteKit frontend will be a significant reframing project in Stage 9, larger than the term "reframing" suggests. The 19 API routes and 9 pages embed band-mixed assumptions that will need to be untangled rather than refactored in place.
- The state placement discipline will surface mistakes during implementation; some surfaces will initially put state in the wrong place and need correction. Treat this as normal and expected; the discipline is the corrective.

---

## Related Documents

- [[ontara-discussion-bs-substrate-and-bindings-2026-04-12|BS Substrate and Bindings]] — Session 197, the substrate paper this paper depends on
- [[ontara-discussion-surface-architecture-and-bindings-2026-04-12|Surface Architecture and Bindings]] — Session 198, the band-6 surface paper this paper relocates
- [[ontara-discussion-architectural-clarification-2026-04-12|Architectural Clarification: Layers, Models, and Simulation]] — Session 196, the four-layer model and simulation clarification
- [[ontara-discussion-model-meta-model-distinction-2026-04-11|Model and Meta Model: Clarifying the Architectural Representation]] — Session 195, the terminological clarification
- [[ontara-discussion-connecting-the-stacks-2026-04-10|Connecting the Stacks — Toward a Live, Model-Grounded Ontara System]] — Sessions 192–193, the post-Stage-8 direction paper
- [[ontara-discussion-portal-state-driven-operator-experience-2026-04-08|Portal: State-Driven Operator Experience]] — Session 174, the Stage 8 discussion paper whose prototype this paper locates within band 5
- [[ontara-research-(perplexity) - headless operation and state|Headless Operation and State (Perplexity research)]] — the source research from which the five-layer framing in §4 and the state placement discipline in §5 are largely derived
- [[ontara-research-(perplexity) - interface-and-interaction|Interface and Interaction (Perplexity research)]] — the source research for S198's band 6 framing
- [[ontara-discussion-dual-stack-architecture-2026-03-26|Dual-Stack Architecture]] — Sessions 73–74, the foundational architecture paper
- [[ontara-discussion-knowledge-graph-architecture-2026-04-01|Knowledge Graph Architecture]] — Session 97, the three-stratum graph and authority zones
- [[ontara-ref-modelling-paradigms|Modelling Paradigm Reference]] — Session 173, paradigms relevant to the layered architecture
- [[domain-cafe|Cafe domain]] — the demonstrator walked through in §6
- [[domain-paws|Paws domain]] — the demonstrator deferred to §7 (Session 200)
- [[domain-suds|Suds domain]] — the demonstrator deferred to §8 (Session 200/201)
- [[ontara-ref-strategic-snapshot|Strategic Reference]] — current project orientation
- [[ontara-ref-master-register|Master Concept Register]] — register additions proposed in §9.7 and §11.2
- [[ontara-ref-work-items|Work Item Tracker / OW Register]] — W-042 (terminology cleanup, scope expansion noted), W-043 (register additions, expansion noted), W-046 (this paper, to be added)

---

*Discussion paper produced Session 199, 13 April 2026. Establishes the architectural foundation for the family of surfaces that span the sophistication gradient, sitting alongside the [[ontara-discussion-bs-substrate-and-bindings-2026-04-12|S197 substrate paper]] and the [[ontara-discussion-surface-architecture-and-bindings-2026-04-12|S198 surface architecture paper]] (here relocated to band 6) as the third foundation paper for Stage 9. Covers the seven-band working classification of audiences, the headless five-layer architecture (with the experience-API layer as a Stage 9 addition), the state placement discipline, and a complete walk-through of all seven bands against the Cafe demonstrator. Paws and Suds cross-domain checks are deferred to Session 200. The most consequential reframing is of S198, which this paper relocates from "the operator surface architecture" to "the band-6 architect-analyst workspace architecture" — a relocation that strengthens rather than rejects the S198 commitments. GenderSense Limited.*
