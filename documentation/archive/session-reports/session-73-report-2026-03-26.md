# Session 73 Report — 26 March 2026

**Session type:** Discussion (exploratory architecture)
**Date:** 26 March 2026
**Style prompt:** Exploratory Discussion

---

## Summary

Session 73 was one of the most architecturally significant sessions in the Ontara project. Starting from Ella's observation that the Paws vertical connection map only describes the business model side of the A4 distinction, the session developed a comprehensive dual-stack architecture for Ontara — business model on the left, business system model on the right — grounded in BFO, persisted in an OWL 2 DL knowledge graph, and featuring a cross-cutting reflective simulation that provides the system's runtime self-knowledge.

The session was pure discussion — no implementation. The primary deliverables are this report, a discussion paper capturing the architecture, diagram iterations (v1–v6), and an emergent ideas log entry (E014).

---

## Progression of Ideas

### 1. The incomplete vertical stack

The session began with the Paws vertical connection map (Ontology → BMM General → Business Instance → Systems Layer) and the weighted relationship graph from Session 72. Ella's observation: this diagram shows only the business model side of the A4 two-meta-model distinction. The business system meta model (BSMM, B8 — acknowledged as implicit since the structured project review) is absent from the picture. The right-hand side of the architecture needs to be drawn.

### 2. The simulation insight

Ella's core insight, stimulated by a physics podcast discussing a relativistic model of consciousness (Nir Lahav et al., Frontiers in Psychology 2021): on the systems side, Ontara needs to construct and maintain a **continuously running explicit simulation of the business**, in its own business domain, for each tenant. This is not a monitoring or analytics layer — it is the system's operational state made live and self-aware.

### 3. The two-simulation pattern

Borrowing a structural pattern from the relativistic consciousness theory (not proposing a conscious system): the theory proposes that subjective experience arises from a system modelling itself modelling — an inner simulation conducted by an outer simulation, where the inner one adds a qualitative dimension. Translated to Ontara:

- An **operational simulation** runs the business — processes events, coordinates workflows, manages state through Temporal, hands off tasks to human actors and connected applications, receives results back as changed state.
- A **reflective simulation** maintains meta-knowledge about the operational simulation's past, present, and projected future behaviour. It is imbued with **valence** — the operator's conception of what constitutes good vs bad business performance — enabling it to produce evaluative, not merely descriptive, outputs.

The reflective simulation does not exercise directive control. It offers guidance, insight, and understanding.

### 4. Correcting the layers diagram

A significant correction to the original Paws vertical connection map: the bottom layer (blue boxes: Booking, Scheduling, Finance, Customer, Inventory, etc.) was labelled "Systems layer — what Ontara generates for the business." Ella corrected this: these are not system descriptions. They are **business model content** expressed in business language. Examples:

- "We book appointments, we don't have walk-ins."
- "Our business model includes watching the monthly P&L."
- "We operate a just-in-time stock ordering system."

These describe how the business operates, not how a system implements it. They *inform* what systems are needed but remain on the business model side. This pushed the left-hand stack to five layers with a gradient from structural to dynamic, all still business model content.

### 5. The pipeline crosses from left to right

The process specification layer paper's pipeline (classification → population → relation binding → process identification → sketches → compilation → code generation → deployment) extends across from the business model side to the system model side. Business process patterns on the left map to system-mediated execution on the right.

### 6. The dual-stack architecture

Through six diagram iterations, the architecture crystallised:

**Left stack (business model — "what the business is and does"):**
- Ontology layer (BFO categories — shared with right side)
- Domain ontologies (OGMS, IAO, OCE, GSSO, OBI — mid-level, BFO-aligned)
- BMM General vocabulary (part defs — SysML v2)
- Business instance (part usages — SysML v2)
- Operational domains (how the business operates — still business model content)
- Business process patterns (dynamic behaviour and flows)

**Right stack (business system model — "how the system realises it"):**
- System ontological categories (BFO-typed: Process, State, Event, Record)
- BSMM General vocabulary (part defs — SysML v2)
- System instance (part usages — SysML v2)
- System domains (running system modules)
- Operational simulation (system-managed execution — Temporal workflows, state management, event streams)

**Horizontal mappings** connect each level across the two stacks.

**The green container** wraps the bottom two pairs on both sides (operational domains + process patterns, system domains + operational simulation). Rules and constraints operate within this container, governing dynamic behaviour: process entry validation, outcome permissibility, quality gates, satisfaction evaluation, likelihood assessment. Constraint *definitions* live in the instance layers above; constraint *enforcement* happens inside the green container.

**The reflective simulation** is a cross-cutting vertical capability on the right side, reading from every layer of the architecture and writing to the operator (guidance, insight, understanding) and back to the knowledge graph (derived knowledge).

### 7. Ontological grounding — BFO and OWL 2 DL

Revisiting the Perplexity ontology research established:

- **BFO as upper ontology** — mandatory for a multi-tenant, regulated-services platform. Provides the continuant/occurrent/role/disposition/quality/function categories that classify everything below.
- **Mid-level domain ontologies** (OGMS for clinical, IAO for information artefacts, OCE for commercial exchange) sit between BFO and the BMM, BFO-aligned.
- **Separation of reference ontology from application logic** — the rule/constraint layer references the ontology but is not embedded in it.
- **Multi-axis compositional models** — this is A12 implemented. Clinical and business states as points in a high-dimensional coordinate space.

### 8. OWL 2 DL is mandatory

OWL 2 provides capabilities SysML v2 cannot: open-world reasoning and automatic classification, consistency checking against BFO axioms, importing existing OBO Foundry ontologies, multi-axis compositional classification with description logic, SPARQL semantic querying, and formal TBox/ABox separation. SysML v2 is a system design language, not an ontology language. Each formalism does what it's best at.

### 9. The knowledge graph as canonical store

The Perplexity research on OWL/SysML integration established the pattern: OWL 2 DL in a triple store as the ontological layer, with a mapping ontology bridging bidirectionally to SysML v2.

Ella made a significant architectural decision: the knowledge graph can eventually become the **canonical store**, with SysML v2 as an engineering **projection** — provided round-trip translation preserves all aspects of the model without degradation. This does not violate A1 or A3: the representation is still primary; the primary representation is the knowledge graph. SysML v2 becomes the engineering view onto the canonical model, analogous to how the Ontara Console is the visual view.

### 10. The operational simulation described

Convergence on what the operational simulation *is*: the system's runtime execution engine for the business, coordinated by Temporal workflows, state management, and event streams. Human actors and connected applications are participants in the simulation — tasks are handed off and results flow back as changed state. Everything maps upward through SysML to the ontology layer, preserving unified semantic coherence. The model lineage is maintained end to end — the system can say not just "workflow X completed step 3" but "the resource allocation process for room assignment in a Standard Groom completed successfully."

### 11. The reflective simulation is cross-cutting

The reflective simulation reads from every layer: the knowledge graph (to know what things *are*), the instances (to know what exists), the operational simulation (to know what's happening), the rule layer (to know the boundaries), and the terminology layer (for clinical grounding). It writes in two directions: to the operator (guidance, insight, explanations) and back to the knowledge graph (derived knowledge — trajectories, anomaly records, projections become persistent self-knowledge).

### 12. Coordinate space snapshots and goal-seeking

The culminating insight: the reflective simulation needs to persist and operate over **multiple states of the business model as snapshots in the coordinate space**. Five snapshot types, differentiated by epistemic status (B17):

1. **Current state** — live, continuously updated
2. **Historical states** — timestamped past snapshots enabling trajectory computation
3. **Goal states** — declared targets representing operator intentions (valence anchors)
4. **Hypothetical states** — "what if" snapshots under altered conditions
5. **Projected states** — extrapolations from current trajectories

Goal-seeking computation: given current state + goal state, search for an action sequence (from the process archetype library) that moves the business from one to the other, subject to constraint satisfaction and valence evaluation. Snapshots persist in the knowledge graph as named graphs, queryable via SPARQL across snapshot types.

Captured as E014 in the emergent ideas log.

---

## Key Architectural Decisions Made or Confirmed

| # | Decision | Status |
|---|---|---|
| 1 | Ontara is an execution platform | Confirmed (not new — but needs clearer expression in strategic reference) |
| 2 | The BSMM must become explicit and structured | B8 gap acknowledged; work begun this session |
| 3 | BFO as upper ontology | Mandatory — decided |
| 4 | OWL 2 DL as the ontological formalism | Mandatory — decided |
| 5 | Knowledge graph (triple store) as eventual canonical store | Directional commitment — SysML v2 as engineering projection with round-trip fidelity |
| 6 | Rule/constraint layer governs dynamic behaviour | Confirmed — inside the green container, separate from ontology |
| 7 | Reflective simulation is cross-cutting | Confirmed — reads from all levels, writes to KG and operator |
| 8 | Coordinate space snapshots with epistemic status | New concept — captured as E014 |

---

## New Concepts Introduced (Needing Register Entries)

- The dual-stack architecture (BMM side + BSMM side with horizontal mappings)
- The operational simulation as the BSMM made live
- The reflective simulation as a cross-cutting meta-knowledge capability
- Valence as the system's representation of operator-defined good/bad
- Coordinate space snapshots (five epistemic types)
- Goal-seeking computation over the coordinate space
- The knowledge graph as canonical store (with SysML as projection)
- The mapping ontology as the OWL ↔ SysML bridge

---

## Register Concepts Exercised

| Concept | How |
|---|---|
| A1 (separation of representation and execution) | The knowledge graph as canonical representation; execution systems as projections |
| A2 (self-describing system) | Extended from design-time to runtime through the reflective simulation |
| A3 (model generates everything) | Preserved — the canonical representation (now KG) generates everything |
| A4 (two meta model distinction) | The dual-stack architecture makes the BSMM explicit for the first time |
| A9 (discipline as load-bearing structure) | Session structure, register review, emergent capture |
| A10 (intrinsic self-knowledge) | Extended from design-time to runtime through the operational and reflective simulations |
| A11 (unity principle) | Same coordinate space, weight model, and valence definitions inform all capabilities |
| [[concept-coordinate-framework|A12]] (coordinate framework) | Made operational as the runtime coordinate space with snapshots and trajectories |
| A13 (multi-tenancy) | Each tenant gets its own simulation instance |
| B8 (BSMM currently implicit) | Directly addressed — the right-hand stack is the BSMM made visible |
| B14 (weighted relationships) | Change propagation through the relationship graph drives simulation behaviour |
| B16 (temporal reference frames) | Historical and projected snapshots are temporal constructs |
| [[concept-epistemic-modality|B17]] (epistemic modality) | Five snapshot types are epistemic modes |
| B18/B19 (BFO / ontology stack) | BFO confirmed as upper ontology; mid-level ontologies specified |
| J2 (co-evolution) | Architecture and tooling concepts advanced together |
| J3 (non-constraining) | Decisions preserve future development paths |
| L1–L4 (simulation capability) | Directly activated — simulation as first-class platform capability. L5–L9 added. |

---

## Emergent Ideas Captured

- **E014** — Coordinate space snapshots and goal-seeking computation (captured in [[ontara-workflow-emergent-ideas-log|emergent ideas log]])

---

## Tier 1 Principles and This Session

| Principle | How honoured |
|---|---|
| A1 | Knowledge graph as canonical representation preserves and strengthens separation |
| A2 | Reflective simulation extends self-description from design-time to runtime |
| A3 | Model generates everything — the canonical model (now KG) is the single source |
| A4 | Dual-stack architecture makes the two meta models visible and explicit |
| A6 | Operational simulation uses deterministic Temporal workflows; reflective layer is advisory |
| A9 | Session followed workflow guide, close sequence in progress |
| A10 | Intrinsic self-knowledge extended to runtime through the reflective simulation |
| A11 | Unity principle — same model informs comprehension, simulation, projection, governance |
| J2 | Architecture and tooling vision advanced together |
| J3 | All decisions preserve future development paths; knowledge graph as canonical store explicitly does not foreclose SysML-primary working |

---

## Diagram Iterations

Six versions of the dual-stack architecture diagram were produced during the session:
- v1: Initial two-column layout
- v2: BFO and mid-level ontologies added, Perplexity research integrated
- v3: Rule/constraint layer moved inside green container per Ella's correction
- v4: SysML v2 made explicit as representational medium; constraint definition/enforcement distinction
- v5: OWL 2 DL and knowledge graph as canonical store
- v6: Reflective simulation repositioned as cross-cutting vertical column

The v6 diagram (saved as `ontara_dual_stack_architecture_v1.svg` in the vault — filename does not reflect iteration count) represents the current state of the architecture.

---

## Open Questions

1. **BSMM General vocabulary content** — the specific domain-neutral system concepts (ProcessType, DataStore, AuditPolicy as placeholders) need proper elaboration
2. **System ontological categories** — are Process, State, Event, Record sufficient? Do they need BFO-specific typing beyond these labels?
3. **Mapping ontology design** — the OWL ↔ SysML bridge is acknowledged as needed but design is deferred
4. **Triple store selection** — which graph database/triple store for the knowledge graph
5. **openCAESAR/OML path** — the existing OWL 2 DL ontology for SysML v2 from the openCAESAR project may provide bridge infrastructure
6. **Reflective simulation's relationship to the knowledge graph** — does it operate *on* the KG directly, or maintain its own working state and write back?
7. **Valence representation** — how does the operator declare goal states and desirability criteria? Configuration UI? Model-level declarations?

---

*Session 73 report written 26 March 2026.*
