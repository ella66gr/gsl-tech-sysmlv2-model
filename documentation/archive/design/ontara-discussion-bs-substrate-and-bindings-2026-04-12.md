---
tags:
  - discussion
  - architecture
date: 2026-04-12
status: working
session: 197
---
# The Business System: Substrate, Bindings, and the Dynamic Aspect of Models

> `= this.file.path`

*Ontara Platform — Discussion Paper*

**Date:** 12 April 2026 (Session 197)
**Purpose:** To consolidate the architectural clarifications reached during Session 197 regarding the dynamic aspect of models, the nature of the Business System (BS) and Business Representation (BR), the substrate on which the BS is constructed, and the binding pattern by which the BS connects to real and simulated components. This paper supersedes earlier formulations that referred to "metamodel runtime state" and provides the architectural foundation for Stage 9 planning.
**Status:** Working document — architectural foundation for Stage 9.
**Depends on:** [[ontara-discussion-architectural-clarification-2026-04-12|Architectural Clarification: Layers, Models, and Simulation]] (Session 196); [[ontara-discussion-model-meta-model-distinction-2026-04-11|Model and Meta Model: Clarifying the Architectural Representation]] (Session 195); [[ontara-discussion-connecting-the-stacks-2026-04-10|Connecting the Stacks]] (Sessions 192–193); [[ontara-discussion-dual-stack-architecture-2026-03-26|Dual-Stack Architecture]] (Sessions 73–74)

---

## Contents

- [[#1. Purpose and Scope|§1. Purpose and Scope]]
- [[#2. The Dynamic Aspect of Models|§2. The Dynamic Aspect of Models]]
- [[#3. BR and BS as the Dynamic Aspects of BM and SM|§3. BR and BS as the Dynamic Aspects of BM and SM]]
- [[#4. The Unity of the Model Across Instantiation Modes|§4. The Unity of the Model Across Instantiation Modes]]
- [[#5. The Representational Substrate of the BS|§5. The Representational Substrate of the BS]]
- [[#6. Bindings: How the Model Connects to Real and Simulated Components|§6. Bindings: How the Model Connects to Real and Simulated Components]]
- [[#7. Why This Is Not Digital Twinning|§7. Why This Is Not Digital Twinning]]
- [[#8. The Substrate Boundary: KG and Specialised Stores|§8. The Substrate Boundary: KG and Specialised Stores]]
- [[#9. Horizontal Mapping Rules as Model Content|§9. Horizontal Mapping Rules as Model Content]]
- [[#10. Implications for the Architecture|§10. Implications for the Architecture]]
- [[#11. Open Questions for Stage 9 Planning|§11. Open Questions for Stage 9 Planning]]
- [[#12. Register Connections|§12. Register Connections]]
- [[#Related Documents|Related Documents]]

---

## 1. Purpose and Scope

The [[ontara-discussion-connecting-the-stacks-2026-04-10|Connecting the Stacks]] paper (Sessions 192–193) established that Stage 9 must address the connection between the model layers and operational reality. Two subsequent discussions — [[ontara-discussion-model-meta-model-distinction-2026-04-11|the model/meta-model clarification]] (Session 195) and [[ontara-discussion-architectural-clarification-2026-04-12|the four-layer architectural clarification]] (Session 196) — surfaced terminological imprecision that was preventing the connection question from being well-formed. This paper takes the next step: it establishes what the Business System (BS) actually is as an architectural construct, what substrate it lives in, and how it relates to the real and simulated components that realise it.

The paper is intended as the architectural foundation from which the Stage 9 plan can be drawn. It does not propose an implementation; it establishes the conceptual ground on which an implementation can be designed.

### 1.1 What this paper supersedes

Earlier formulations — including the original Connecting the Stacks paper and parts of the Session 195 discussion — referred to "BMM runtime state" and "SMM runtime state" as the two distinct things that change when a service episode occurs. Those phrases are category errors and should be retired. Meta models do not have runtime state. A vocabulary is the same set of templates and structural rules whether or not any specific business is currently doing anything. The terms that should be used in their place are introduced in §2 and §3.

## 1a. Architectural Diagram (12/04/2026)

![[Ontara Architecture.png]]
---

## 2. The Dynamic Aspect of Models

A model is not necessarily a static structural artefact. A model can be dynamic — it can carry state that changes over time, transitions between configurations, an event history, accumulated facts. When a model is dynamic *and* explicitly intended to represent something else for some useful purpose, it is a simulation in the standard meaning of the term. This is the meaning that L5 (operational simulation) and L6 (reflective simulation) have always carried in the [[ontara-ref-master-register|master register]].

The distinction between a model's static aspect and its dynamic aspect is therefore not a distinction between two layers but between two faces of the same thing. A fully realised model has both:

- A **static aspect** — its configurational structure: what elements it contains, how they are typed, how they are connected, what constraints govern their composition. This is what gets edited at design time and changes when a deliberate decision is made.
- A **dynamic aspect** — its evolving state: the current values of its variables, the current positions in its state machines, the events it has observed, the facts it has accumulated. This changes continuously at runtime in response to events.

Both belong to the model. A model that has only a static aspect is an impoverished model — a structural description without the capacity to represent how the modelled thing is actually behaving. A model that has only a dynamic aspect is incoherent — state without structure to give it meaning. The two aspects are inseparable in any model that is doing real representational work.

### 2.1 Why this matters terminologically

Recognising the static/dynamic duality of models removes the need to invent terms like "BMM runtime state" or to treat runtime state as a separate architectural layer below the model layer. The runtime aspect of a model is part of the model. What needs naming is not a new layer but the dynamic-aspect *manifestation* of the relevant model — and that is what BR and BS are.

---

## 3. BR and BS as the Dynamic Aspects of BM and SM

The Business Model (BM) is the actual configured model of a specific business — what GSL is, what Paws is, what the cafe is, in modelling terms. It is an instantiation of BMM vocabulary for a particular tenant. The BM has both a static aspect (the configurational structure: service offerings, pricing rules, staff roster, governance rules) and a dynamic aspect (the evolving state: today's revenue, current inventory, customer relationships, accumulated activity facts).

**Business Representation (BR)** is the name for the dynamic aspect of the BM. It is the BM representing the actual state of the business in the world, in real time, in a form that can be queried, reasoned over, and presented to the operator. BR is not a separate thing the BM points at; it is the BM doing its representational work as a dynamic model. The earlier formulation "BM Configuration + BM Runtime State = BM" was directionally right but slightly misleading; the better formulation is that BR is the BM in its dynamic mode of operation.

The System Model (SM) is the actual configured model of a specific business's system — the workflows, integrations, data stores, access policies, infrastructure bindings that realise the BM operationally. Like the BM, the SM has a static aspect (the configured assembly of system capabilities) and a dynamic aspect (which workflow instances are running, what state they are in, what events have fired, what is queued).

**Business System (BS)** is the name for the dynamic aspect of the SM. It is the SM representing the live state of the system that runs the business. As with BR, the BS is not a separate thing below the SM; it is the SM in its dynamic mode of operation.

### 3.1 The four-layer model, restated

Read through this lens, the [[ontara-discussion-architectural-clarification-2026-04-12|four-layer model from Session 196]] resolves into something cleaner than four genuinely independent layers:

| Layer | Left stack | Right stack | Nature |
|---|---|---|---|
| 1. Foundation | BFO + Business Domain Ontologies | BFO + System Ontological Categories | Upper ontology + domain extensions (OWL 2 DL) |
| 2. Meta model vocabulary | BMM (General + Domain-Specific) | SMM (General + Domain-Specific) | Reusable templates (SysML v2) |
| 3. Model | BM (static aspect + dynamic aspect = BR) | SM (static aspect + dynamic aspect = BS) | The configured model for THIS business and THIS system |

What was previously distinguished as "Layer 3 — Configured model" and "Layer 4 — Generated output" is more accurately understood as the static and dynamic aspects of a single model layer. BR and BS are not below the model; they *are* the model in its dynamic mode. The visual stacking in the architecture diagram reflects this — BM and BR (and SM and BS) belong to the same enclosing structure, not to separate layers.

### 3.2 What BR and BS are not

To avoid the confusions that have surfaced in earlier discussions, several things should be stated negatively:

- BR is not "the data layer". It is a dynamic model that happens to be persisted.
- BS is not "the running infrastructure". The infrastructure (Temporal, the customer portal, the EHR, the databases) realises components that the BS observes and coordinates; the BS is the model of the system, not the infrastructure itself.
- Neither BR nor BS is "below" the model layer. They are aspects of the model.
- "BMM runtime state" and "SMM runtime state" do not exist. Meta models are vocabularies and have no runtime state. The dynamic things are BR and BS.

---

## 4. The Unity of the Model Across Instantiation Modes

A central clarification from Session 196 is that the BS is one model, not many. The same BS — the same dynamic model of the system that runs this business — can be instantiated in different modes:

- **Real instantiation.** The BS is bound to actual infrastructure: Temporal workflows running against real Temporal, the customer portal being interacted with by real users, the EHR holding real clinical compositions, the databases storing real transactional data. In this mode, the BS represents the actually-running system.
- **Simulated instantiation.** The BS is bound to computational proxies: synthetic event generators producing events that look like the events real components would produce; scripted behaviours; counterfactual or projected scenarios. In this mode, the BS represents a hypothetical, projected, or counterfactual version of the system.

There can be exactly one real instantiation of the BS at any time (the actually-running system) and any number of simulated instantiations alongside it (concurrent what-if explorations, projections, scenario analyses, retrospective counterfactuals).

The unity of the model across these modes is architecturally significant. The BS's structure is invariant: the same model elements, the same state machines, the same horizontal mapping rules apply whether the instantiation is bound to reality or to computation. What varies is only the *binding* — which §6 develops in detail. This invariance is what makes simulation results meaningful: a projection produced by the BS in simulated instantiation can be compared with the BS in real instantiation because both are operating on the same model under the same rules.

This dissolves the question of whether real execution and simulation are "the same thing" or "different things". They are the same thing as model and different things as instantiation, and the architecture should hold both truths simultaneously. The operator surface needs to make the instantiation mode visually unmistakable — an operator must never be confused about whether they are looking at the real business or a projection — while preserving the fact that what is being shown is the same BS in either case.

---

## 5. The Representational Substrate of the BS

The BS is a model, not code, not a database schema, not a workflow engine. Like the rest of Ontara's models, it requires a substrate that supports typed structure, declared semantics, reasoning, queryability, and continuous evolution under event flow. The natural substrate for the BS is the **knowledge graph**, extended to hold dynamic instance data alongside the vocabulary and structural content it already holds.

### 5.1 What the BS substrate must hold

The BS substrate must accommodate, at minimum:

- **Typed model elements** drawn from the SMM vocabulary — workflow instances, integration points, task instances, state machine positions, resource assignments — each carrying a type, an identity, current state, and event history.
- **Bindings** declaring how each model element connects to a real or simulated component, with observation and control mechanisms and freshness/fidelity profiles (developed in §6).
- **Events** flowing in from observed bindings or synthetic generators, recorded against the model elements they affect.
- **Horizontal mapping rule firings** that update BR in response to BS events (developed in §9).
- **Provenance** linking every fact in BR back to the BS event that produced it and the binding through which that event was observed.
- **Multiple instantiation strata** so that real and simulated instantiations of the same BS can coexist without confusion.

Triples are an excellent fit for this content. Almost all of it is typed, relational, and semantically governed. The relationship between an instance and its type is a graph traversal. The reasoning machinery the platform already operates ([[principle-self-describing-system|A2]], [[principle-intrinsic-self-knowledge|A10]], the reasoning metamodel, the SPARQL validation suite) can apply directly. Named graphs provide the natural mechanism for separating instantiation strata while sharing vocabulary and rules.

### 5.2 Why the knowledge graph

The choice of the knowledge graph as the BS substrate follows from several converging considerations:

1. **Reasoning.** L6 (reflective simulation) reads from the BS to detect anomalies, compute trajectories, evaluate options, and produce guidance. Reasoning over typed instances against an ontologically-grounded vocabulary is what OWL-on-a-triple-store is built to do. Holding the BS in a separate operational store would either require replication into the KG for reasoning or duplication of reasoning machinery against the operational store. Both are worse than holding the BS in the KG to begin with.

2. **Structural alignment with the SM.** The SM's static aspect is already in the KG (or projected into it from SysML via the existing OWL pipeline). Holding the BS in the same store means the relationship between an instance (BS) and its type definition (SM) is a single graph traversal, not a cross-store join. This matches the established pattern from `ontara-reasoning.ttl`, where 42 reasoning classes coexist with the named individuals from the [[domain-ears|Ears]] intake in the same graph, governed by the same axioms.

3. **Multiple instantiation modes.** Each instantiation of the BS — real or simulated — is itself a graph of typed elements with state. Named graph machinery is the natural way to keep these separate while letting them share vocabulary, structure, and rules. A real instantiation lives in one named graph; each simulation run lives in another; comparison between them is a SPARQL query across the graphs.

4. **Bindings as model content.** A binding declaration is a graph fragment with typed properties and references to other model elements. Bindings naturally live where the rest of the model lives.

5. **Mapping rules as model content.** Horizontal mapping rules — the things that fire when a BS event occurs and update BR — are declarative content that needs to be reasoned about, queried, and validated. SPARQL, SHACL, and OWL are the right substrate for that kind of content.

### 5.3 BR sits in the same substrate by the same logic

BR is the dynamic aspect of the BM, just as BS is the dynamic aspect of the SM. The same arguments apply: BR needs to be reasoned over, it needs structural alignment with the BMM that types it, it needs named graph separation across epistemic types ([[concept-coordinate-space-snapshots|coordinate space snapshots, L8]]), and its content (typed business facts) is naturally expressed as triples. The architectural default should be that BR lives in the knowledge graph in a dedicated stratum, alongside BS, sharing the same governance and reasoning machinery.

PostgreSQL or an equivalent relational store may have a role to play if specific throughput, transactional, or volumetric requirements emerge that the KG genuinely cannot meet. But this should be a derogation justified by a concrete requirement, not the architectural default. The default is: BR and BS both live in the KG.

### 5.4 The expansion of the KG's role

This is a material expansion of the KG's role and is acknowledged as such. The KG is currently a vocabulary and structural store with some reasoning instances from the Ears intake. Treating it as the substrate for continuously-updating runtime models has real engineering consequences — write throughput, transaction semantics, query load under concurrent updates, the relationship between the round-trip diff engine and a continuously-mutating store, the scaling profile of a triple store under operational load. [[ontara-ref-work-items|OW-34]] flagged this expansion as a significant decision warranting careful design, and that flag remains valid.

The position taken here is that the expansion is the architecturally honest answer. The alternatives — fragmenting model content across stores, building a parallel runtime substrate that re-implements what the KG already does, or maintaining two sources of truth that need continuous reconciliation — are each worse along the dimensions that matter (semantic coherence, reasoning integration, governance alignment, comprehension architecture). The engineering challenges of operating the KG at runtime scale are real and must be addressed; they are not a reason to choose a less coherent architecture.

---

## 6. Bindings: How the Model Connects to Real and Simulated Components

A binding is a first-class model element that connects a BS model element to the real-world or simulated component that realises it. Bindings are how the BS, while remaining a model, becomes operationally connected to the things it represents.

### 6.1 What a binding declares

Each binding answers four questions:

1. **What model element does this binding correspond to?** The binding refers to a specific BS element (a workflow instance type, an integration point, a task type, a state machine) and declares that this real-world component is the realisation of that element.
2. **How does state change in the component become an event in the BS?** Push (webhook, message queue subscription, Temporal subscription), pull (polling at a declared interval), or human-mediated (an action on the operator surface translates a real-world event into a BS event).
3. **How does an instruction from the BS become an action in the component?** Direct API call, queued message, scheduled task invocation, or human action prompted via the operator surface ("please call this patient").
4. **What freshness and fidelity guarantee does this binding provide?** Sub-second for Temporal subscriptions; minutes for polled APIs; hours for human-entered data; potentially days for components observed only by inference from other signals.

### 6.2 The variety of binding types

Bindings come in several characteristic shapes, each appropriate to different kinds of components:

- **Rich event-stream bindings** for components like Temporal that natively emit state-change events. The BS subscribes; the events flow in; the BS records them; mapping rules fire; BR updates. Sub-second freshness.
- **API-polled bindings** for components on the end of an API that do not push events. The BS polls at a declared interval; observed state changes generate events; the rest of the pipeline is identical. Freshness equals the polling interval.
- **Webhook-receiving bindings** for components that push events when configured to do so. The BS receives the webhook, normalises it, generates the corresponding BS event. Freshness equals the webhook latency.
- **Human-mediated bindings** for components that have no automated observation surface — a phone call, a paper form, a delivery, a face-to-face conversation. The operator surface presents the model element with controls that translate human input into BS events ("mark consultation complete", "record consent given", "log delivery received"). Freshness equals operator promptness.
- **Inferential bindings** for components that have no observable surface at all. The model declares the component's expected steady-state behaviour and the conditions under which inference can update the BS's representation of it. Freshness is weak and uncertainty is high; the BS should know this and propagate it.
- **Synthetic-generator bindings** for simulated instantiations. Instead of observing a real component, the BS instantiates a generator that produces events according to a declared distribution or scripted scenario. The downstream pipeline is identical to a real binding — the events look the same, the mapping rules fire the same way, BR updates the same way. The only difference is that the events are produced rather than observed.

### 6.3 The freshness/fidelity profile is part of the model

A binding's freshness/fidelity profile is not implementation metadata; it is model content. The BS should know, at runtime, how stale each part of its representation is and how that staleness should propagate into BR and into the operator's view. An operator looking at BR should be able to ask "how fresh is this number?" and receive an answer grounded in the binding metadata.

This makes the bindings the operational expression of [[principle-self-describing-system|A2]] (self-describing system) and [[principle-intrinsic-self-knowledge|A10]] (intrinsic self-knowledge) at the boundary between the model and reality. The system must know what it knows and what it doesn't. A binding with weak freshness is an explicit declaration that "this part of my representation may lag reality"; an inferential binding is an explicit declaration that "this part of my representation is computed indirectly and should be treated with appropriate uncertainty". L6 reading from BR should always know the provenance and freshness of what it is reading.

### 6.4 Bindings bridge the partially- and the unboundable

A clinical consultation that is partly captured in the EHR (timing, notes, prescriptions) and partly captured nowhere (the actual conversation, the clinician's judgement, the patient's emotional state) is a partially-bound model element. The model can know what was prescribed but not what was discussed. That gap is real and the binding must represent it honestly: the BS should know there are aspects of the consultation it cannot observe, and BR should reflect the bounded scope of what it knows rather than papering over the gap.

The same applies to genuinely unobservable components: the binding can declare "no observation possible; assumed in steady state until manually contradicted", and the BS treats the corresponding model element accordingly. The operator can update it through a human-mediated binding when reality demands it. The architecture is honest about the limits of its own knowledge.

---

## 7. Why This Is Not Digital Twinning

The term "digital twin" carries baggage that can mislead. The classical digital twin pattern involves a parallel running model that maintains its own autonomous dynamic state, derived from its own internal logic, which is then continuously reconciled against the real component. The autonomy is the source of the difficulty: it produces two sources of truth that drift apart and must be re-synced. Building a digital twin in this sense requires every component to be re-implemented as a model element, with all the duplication and synchronisation cost that implies.

The pattern described in this paper is materially different. The BS does not run an autonomous parallel implementation of any component. The BS holds the *model* of each component (its type, its state machine, its events, its actions) but the *execution* happens in the real component (Temporal, the customer portal, the EHR, the human interaction). The BS observes; the components run; the bindings carry the observations.

There is therefore no parallel autonomous state to drift. The BS's dynamic state is, by construction, derived from observations of real components (in real instantiation) or from synthetic generators (in simulated instantiation). The single source of truth for any model element is the component to which it is bound.

This pattern can be called **observational binding** to distinguish it cleanly from classical twinning. Its essential properties are:

- The BS contains the model, not the implementation.
- Each model element is connected to its realising component by a binding.
- The BS's dynamic state is derived from observed events, not generated by parallel execution.
- For simulated instantiations, the binding is to a synthetic generator instead of to a real component, but the model is unchanged.
- There is no reconciliation problem because there is no parallel state to reconcile.

The unfortunate fact that "digital twin" has become the dominant term for any model that knows what its corresponding real-world thing is doing makes the avoidance of the term sound like a denial of the underlying capability. It is not. The capability — a model that maintains a faithful, queryable, reasoning-tractable representation of what its real components are doing — is exactly what the BS provides. The architectural shape by which it provides that capability is just different from, and cleaner than, classical twinning.

---

## 8. The Substrate Boundary: KG and Specialised Stores

The knowledge graph is the substrate for the BS, but it is not the only store the platform uses, and it should not try to be. Some content is fundamentally not a fit for triples and has well-established homes in stores designed for it. The architectural pattern is to keep the BS substrate in the KG and to use **references and bindings** to reach into specialised stores for content that lives there naturally.

### 8.1 OpenEHR for clinical narrative and templated clinical content

OpenEHR exists because clinical content has its own modelling discipline (archetypes, templates, AQL) and its own persistence requirements (temporal versioning, contribution semantics, demographic separation). Reproducing this in triples would be both wrong and pointless. The CDR is the right home for clinical compositions and remains so.

The clean separation is:

- The BS substrate in the KG holds **typed model elements** representing clinical workflows, consultations, prescriptions, referrals — each as an instance with state, events, and bindings.
- Each such model element holds a **reference** into OpenEHR (a composition UID, an EHR ID, an AQL handle) that locates the corresponding clinical content.
- The OpenEHR CDR holds the **content** itself: the consultation notes, the structured observations, the prescription details, the templated archetyped data.
- When the BS needs to surface clinical content to the operator or to L6, it follows the reference; the content is fetched from OpenEHR; the BS does not duplicate it.

This is the same shape as the model-as-index pattern established in [[ontara-discussion-architectural-section-implementation-design-2026-03-29|Session 86]] for architectural sections: the model holds the structural index and the metadata, the long-form prose lives elsewhere, a stable reference connects them. Here it is the same pattern applied to clinical content. The KG indexes; the CDR holds the narrative; the binding is the reference.

### 8.2 The pattern generalises beyond OpenEHR

The same pattern extends to any content that does not naturally fit triples:

- Documents, attached files, scanned forms — object storage or document store, referenced from the BS by URI and content hash.
- Images, scans, diagnostic imagery — medical imaging stores or object storage, referenced from the BS by study and series identifiers.
- Free-text correspondence, voice recordings, transcripts — appropriate stores, referenced from the BS by identifier.
- Time-series telemetry from connected devices — time-series databases, referenced from the BS by stream identifier.

In every case the architectural pattern is the same: **the BS substrate is the typed semantic layer; long-form, large, or unstructured content lives in stores appropriate to its nature; bindings carry the references that let the BS know where everything lives**.

### 8.3 Reasoning operates on what's in the KG, by design

L6 reflective simulation reasons over the typed structural and relational graph. It does not need to read the body of a clinical note to know that a consultation has been completed and to update BR accordingly — that is what the typed model element and its state machine are for. If reasoning ever needs access to the *content* of an OpenEHR composition (e.g. to extract a structured observation as a typed fact), the extraction is an explicit, declared operation: an event fires when a composition is committed; an extraction step pulls the relevant structured fields; those fields are asserted as triples in the KG as new typed model elements. The body of the note remains in OpenEHR; the *facts derived from it* enter the KG as proper typed content with full provenance back to the source composition.

This boundary is the right one. It keeps reasoning tractable, it keeps clinical content in its proper home, and it makes the relationship between the two stores explicit and inspectable. PROV-O — already part of the platform's ontology stack — provides the mechanism for tracking provenance across the boundary.

### 8.4 Freshness is heterogeneous across the substrate

Triples in the KG and content in OpenEHR have different freshness profiles. Triples representing BS state are as fresh as the binding through which they were observed. OpenEHR compositions have their own contribution timing. When the BS reads a derived fact from the KG that originated in an OpenEHR composition, it should know the provenance chain back to the composition and the freshness characteristics of both layers. The operator should be able to see this; L6 should reason about it.

---

## 9. Horizontal Mapping Rules as Model Content

The horizontal mapping rules are the things that update BR in response to BS events. They are as much a part of the architecture as the dual-stack description itself, and they are model content — not glue code, not implementation detail, not a separate runtime layer.

### 9.1 What a mapping rule declares

A mapping rule has the shape: **when the BS observes that event E occurs against model element X (or a model element of type T), apply update U to BR field F (or BR elements of type S)**.

For the cafe demonstrator, an example rule is: when the FulfilDrink workflow instance reaches the Delivered state, increment the BR field "daily order count" and add the order total to the BR field "daily revenue". The event (`Delivered` against an instance of `FulfilDrinkWorkflow`) is BS content; the update (increment / add) is a structured operation; the target (`daily order count`, `daily revenue` in the cafe BR) is BM content.

### 9.2 Where mapping rules live

Mapping rules are part of the configured model — they belong to the BM↔SM correspondence at the configured-model level. They are not part of the BMM or SMM (they are tenant-specific, not part of the General vocabulary). They are not part of BR alone or BS alone (they cross the boundary). They are first-class artefacts in the model, declared by the architect or the tenant administrator, validated against the BMM/SMM types, and reasoned about.

Architecturally, mapping rules live in the same substrate as everything else — the knowledge graph — as declarative content expressed in a form the platform can execute. The exact form (SHACL, SPARQL Update, a domain-specific rule vocabulary expressed in OWL, or a combination) is a Stage 9 design question. What matters here is that mapping rules are model content, not code.

### 9.3 Mapping rules execute identically across instantiation modes

A mapping rule does not know whether the BS event that triggered it came from an observed Temporal workflow (real instantiation) or from a synthetic generator (simulated instantiation). It fires on the event. This is what makes simulation results meaningful as projections of what the real system would do under hypothetical conditions: the same rules govern both modes, so the only thing that varies is the input.

### 9.4 Mapping rules are reasoning-tractable

Because mapping rules are model content and live in the KG, they are themselves subject to reasoning, validation, and governance. The platform can ask: which rules apply when this event type fires? Are there rules that conflict? Are there events that no rule handles (a gap)? What are the consequences of changing this rule? Which BR fields depend on which BS event types? The reasoning machinery already in place for the rest of the model applies to the mapping rules without modification.

---

## 10. Implications for the Architecture

The clarifications in this paper have several consequences that should be carried forward into Stage 9 planning and into the broader architectural picture.

### 10.1 The Knowledge Graph is the substrate for running models

[[concept-knowledge-graph|B22]] established the knowledge graph as the canonical store for the model. This paper extends that role: the knowledge graph is the canonical substrate not only for vocabulary and structural content but for the dynamic aspects of models — BR and BS — as they evolve under real and simulated instantiations. This is a material expansion of the KG's role and was anticipated by [[ontara-ref-work-items|OW-34]]. The expansion is the architecturally honest answer; the engineering challenges it raises are real and must be addressed in Stage 9 design.

### 10.2 Bindings are a new first-class model element

Bindings should be added to the master register as a structural concept. They are how the model connects to reality. They are model content, not implementation glue. They carry their own type, their own freshness/fidelity profile, their own observation and control mechanisms, and their own provenance contribution. A binding is a graph fragment in the KG that points at a real or simulated component and declares everything the model needs to know about that connection.

### 10.3 The horizontal mapping rules are a new first-class model element

Mapping rules should be added to the master register alongside bindings. They are the operational expression of the dual-stack architecture's connecting layer at the configured-model level. They are declarative, model-resident, reasoning-tractable, and execute identically across real and simulated instantiations.

### 10.4 The substrate boundary pattern generalises the model-as-index principle

The principle that the BS substrate holds typed semantic content while specialised stores hold long-form or unstructured content, connected by references, generalises the model-as-index pattern from architectural sections to all content types. This should be recognised as a platform-wide architectural pattern.

### 10.5 The L5–L9 cluster gets sharper

The simulation cluster in the master register can now be read with greater precision:

- **[[concept-operational-simulation|L5 (operational simulation)]]** is the BS in its real instantiation: the SM made dynamic, bound to live infrastructure, representing the actually-running system.
- **[[concept-reflective-simulation|L6 (reflective simulation)]]** is the cross-cutting capacity that observes both real and simulated instantiations of the BS and reads from BR, producing guidance and analytical output for the operator.
- **[[concept-valence|L7 (valence)]]** gives L6 the basis for evaluating the trajectories it observes in BR and BS as good or bad relative to the operator's declared conception of business performance.
- **[[concept-coordinate-space-snapshots|L8 (coordinate space snapshots)]]** persists the dynamic state of BR and BS across epistemic types, enabling comparison across time and across instantiation modes.
- **[[concept-goal-seeking-computation|L9 (goal-seeking computation)]]** is what L6 does when it instantiates the BS in projection mode and searches for trajectories that move BR toward goal regions in the coordinate space.

The unity across the cluster is that all of these operate on the same model — the BS — under different framings (live vs reflective vs goal-seeking) and different instantiation modes (real vs simulated vs projected vs counterfactual).

### 10.6 The Stage 9 connection question is now well-formed

The "connection of the islands" question, which was not fully tractable while terminology was imprecise, now has a clean shape. Stage 9 must:

- Establish the BS as a runtime KG stratum with the necessary substrate engineering (write throughput, transaction semantics, named graph organisation, query performance).
- Establish BR as a parallel KG stratum on the BM side with the same substrate.
- Define the binding declaration vocabulary and add it to the model.
- Define the horizontal mapping rule vocabulary and add it to the model.
- Build the first concrete instantiation: the cafe demonstrator's existing Temporal workflows bound to a BS instance, with mapping rules that update a cafe BR, exposed through the portal as the operator surface.
- Build a customer kiosk that drives real-world activity into the cafe BS, completing the round trip from customer action to BR update.
- Surface the binding registry in the console as the architect's view of "which model elements have live infrastructure bound to them, with what freshness and fidelity".

These are tractable engineering questions with concrete deliverables, in contrast to the previously open question of how to "connect the islands".

---

## 11. Open Questions for Stage 9 Planning

The following questions remain for Stage 9 design and are not resolved by this paper:

**Q1.** What is the schema of a binding declaration? What properties must it carry? What types of binding should the vocabulary support natively, and which should be extension points?

**Q2.** What is the language in which horizontal mapping rules are expressed? SHACL? SPARQL Update? A domain-specific rule vocabulary in OWL? A combination? What are the trade-offs?

**Q3.** What does the dispatch direction look like? When the BS determines that an action should be taken on a bound component (a workflow should be started, a notification should be sent, an operator should be prompted), what is the contract between the BS's "this should happen" and the binding's "here is how to make it happen"?

**Q4.** For human-mediated bindings, what does the operator surface translation look like? How is the mapping from "operator clicks 'mark consultation complete'" to "BS records `ConsultationCompleted` event against model element X" declared in the model?

**Q5.** How is uncertainty represented in BR for facts derived from weak-freshness or inferential bindings? How does L6 read freshness and propagate it into its analytical output?

**Q6.** What does the binding registry look like in the console? How does an architect see which model elements have live bindings, of what type, with what freshness?

**Q7.** What is the named graph organisation for instantiation strata? How are real and simulated instantiations kept separate while sharing vocabulary, structure, and mapping rules? What are the rules for cross-stratum querying (e.g. comparing a simulated BR projection against the real BR)?

**Q8.** What are the operational characteristics of the KG under continuous runtime updates? Write throughput, concurrent query load, transactional semantics, indexing strategy, the relationship between the round-trip diff engine and a continuously-mutating store. This is the OW-34 engineering question made concrete.

**Q9.** Where exactly does PostgreSQL fit, if at all? Is it a derogation for specific high-throughput or transactional content that the KG cannot accommodate? What concrete requirement would justify it?

**Q10.** What is the connection sequence and its acceptance criteria (OW-35)? Which connection is built first, what does it prove, how is the demonstration verified?

---

## 12. Register Connections

### 12.1 Principles directly engaged

| Principle | Engagement |
|---|---|
| [[principle-separation-representation-execution\|A1]] | The observational binding pattern is A1 made operational at the boundary between the model and reality. The BS observes; the components execute; the model representation propagates the observations into BR via mapping rules. There is no reverse flow from execution to representation that bypasses the model. |
| [[principle-self-describing-system\|A2]] | Bindings are the operational expression of A2 at the model–reality boundary. The system knows what it observes, what freshness it observes it with, and what it cannot observe. |
| [[principle-model-generates-everything\|A3]] | Bindings and mapping rules are model content. The binding registry should ultimately be generable from the model. The discipline that "every piece of running infrastructure declares its model binding" is A3 at the deployment level. |
| [[principle-two-meta-model-distinction\|A4]] | The BR/BS distinction is the dual stack made dynamic. The horizontal mapping rules are the dual stack's connecting layer at the configured-model level. |
| [[principle-intrinsic-self-knowledge\|A10]] | Freshness and fidelity profiles in bindings are intrinsic self-knowledge: the system computes its own confidence in its representation from declared binding metadata, not from human-edited descriptions. |
| [[principle-unity-principle\|A11]] | The unity of the model across instantiation modes is A11 made concrete: the same BS, the same mapping rules, the same reasoning machinery serves real and simulated instantiations alike. |

### 12.2 Concepts that need to be added or revised in the master register

The following changes to the [[ontara-ref-master-register|master register]] should be considered as part of the C2 update for this session and any subsequent registration session:

- **BR (Business Representation)** and **BS (Business System)** as named architectural concepts representing the dynamic aspects of BM and SM respectively. Section B (Structural Architecture Concepts).
- **The static/dynamic duality of models** as a register concept. Section B or A — possibly a clarification or amendment to [[principle-two-meta-model-distinction|A4]] or [[concept-dual-stack-architecture|B21]].
- **Binding** as a first-class structural model element. Section B.
- **Horizontal mapping rule** as a first-class structural model element. Section B.
- **The substrate boundary pattern** (KG for typed semantic content, specialised stores for long-form or unstructured content, references via bindings) as a validated platform pattern. Section D.
- **Observational binding** as a named pattern distinguishing the architecture from classical digital twinning. Section D.
- **The expansion of the KG's role to runtime instance substrate**: amendment to [[concept-knowledge-graph|B22]] reflecting the position taken in §5.

The retirement of "BMM runtime state" and "SMM runtime state" as terms used in any current document. References in [[ontara-discussion-connecting-the-stacks-2026-04-10|Connecting the Stacks]] §6 and [[ontara-discussion-model-meta-model-distinction-2026-04-11|the model/meta-model paper]] §6 should be revisited and rephrased in light of this paper.

### 12.3 Observations and watchpoints

The following observations from this session's discussion should be deposited in the [[ontara-ref-work-items|OW register]]:

| Summary | Work type | Notes |
|---|---|---|
| The static/dynamic duality of models is a structural insight that may warrant a register entry of its own; check whether existing [[principle-two-meta-model-distinction\|A4]] or [[concept-dual-stack-architecture\|B21]] formulations need amendment | ARC, GOV | Surfaced this session; relevant whenever architectural foundations are revised |
| The KG's role expansion to runtime instance substrate has engineering consequences (write throughput, transactions, named graph organisation, query load, round-trip diff relationship) that must be designed before commitment | KGO, ARC | OW-34 reframed and sharpened by this paper |
| The binding registry surfaces a new console view ("which model elements have live infrastructure bound to them, with what freshness") that connects to Connecting the Stacks Q6 | CON, ARC | New console view candidate; depends on binding vocabulary being defined |
| The horizontal mapping rule vocabulary is a new generation target — the pipeline will need to handle declarative rule content and the console will need to display it | KGO, CON | New work area opened by this paper |
| Freshness/fidelity propagation from bindings into BR and into L6's analytical output is a cross-cutting design question that touches comprehension architecture and operator surface design alike | RGV, CON | Surfaced this session |
| The retirement of "BMM/SMM runtime state" terminology requires updates to [[ontara-discussion-connecting-the-stacks-2026-04-10\|Connecting the Stacks]] and [[ontara-discussion-model-meta-model-distinction-2026-04-11\|the model/meta-model paper]] | GOV | Editorial; should be done before Stage 9 plan production |

---

## Related Documents

- [[ontara-discussion-architectural-clarification-2026-04-12|Architectural Clarification: Layers, Models, and Simulation]] — Session 196, the four-layer model and one-model-multiple-instantiation clarification
- [[ontara-discussion-model-meta-model-distinction-2026-04-11|Model and Meta Model: Clarifying the Architectural Representation]] — Session 195, the terminological clarification this paper builds on
- [[ontara-discussion-connecting-the-stacks-2026-04-10|Connecting the Stacks — Toward a Live, Model-Grounded Ontara System]] — Sessions 192–193, the post-Stage-8 direction paper whose Q1 and Q2 this paper now answers in principle
- [[ontara-discussion-dual-stack-architecture-2026-03-26|Dual-Stack Architecture]] — Sessions 73–74, the foundational architecture paper
- [[ontara-discussion-knowledge-graph-architecture-2026-04-01|Knowledge Graph Architecture]] — Session 97, the three-stratum graph and authority zones
- [[ontara-discussion-architectural-section-implementation-design-2026-03-29|Architectural Section Implementation Design]] — Session 86, the model-as-index pattern this paper generalises
- [[ontara-discussion-portal-state-driven-operator-experience-2026-04-08|Portal: State-Driven Operator Experience]] — Session 174, the Stage 8 discussion paper
- [[ontara-ref-strategic-snapshot|Strategic Reference]] — current project orientation
- [[ontara-ref-master-register|Master Concept Register]] — register entries that will be revised in light of this paper
- [[ontara-ref-work-items|Work Item Tracker / OW Register]] — OW-32, OW-33, OW-34, OW-35 are all reframed by this paper

---

*Discussion paper produced Session 197, 12 April 2026. Provides the architectural foundation for Stage 9 planning by establishing the dynamic-aspect framing of models, the BR/BS distinction, the knowledge graph as the BS substrate, the observational binding pattern, and the substrate boundary between the KG and specialised stores. Supersedes the "BMM runtime state" / "SMM runtime state" formulations used in earlier discussions. GenderSense Limited.*
