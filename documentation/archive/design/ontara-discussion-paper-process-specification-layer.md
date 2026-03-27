# From Static Model to Running Systems: The Process Specification Layer

*Ontara Platform — Discussion Paper*
**Date:** 25 March 2026 (Session 72)
**Revised:** 27 March 2026 (Session 75) — updated to reflect the [[ontara-discussion-dual-stack-architecture-2026-03-26|dual-stack architecture]] (Session 73/74)
**Status:** Working document

---

## Context

This paper addresses the architectural question: once Ontara has a validated static business model (typed entities with typed relations), how does it bridge from that inert structure to generated, executable systems?

The discussion arose during the [[domain-paws|Paws]] demonstrator work (Stage 4, March 2026) and builds on the vertical connection map. The original framing assumed a single vertical stack descending from Ontology → BMM General → Business Instance → Systems. The [[ontara-discussion-dual-stack-architecture-2026-03-26|dual-stack architecture]] (Session 73) corrected this: what was labelled the "systems layer" is actually business model content — operational domains and business process patterns — still on the left (business model) side. The actual systems side sits *alongside* as a parallel stack connected by [[ontara-ref-master-register|horizontal mappings (B12)]], not below.

This paper proposes a **process specification layer** that extends the business model downward from static structure into dynamic behaviour, and describes the full pipeline from user intake to running systems. The pipeline crosses from the left stack (business model) to the right stack (business system model) at the compilation stage — see [[#The Full Pipeline]].

---
### Paws Domain Example
![[ontara_vertical_architecture_paws.svg]]

## The Problem

After the intake and structuring phases, Ontara holds a static business model — a graph of typed nodes (business entities) and typed edges (confirmed relations). For Paws, this includes ServiceOfferings, Rooms, StaffMembers, PricingRules, CostCategories, and so on, all correctly classified against the ontology and instantiated from the BMM General vocabulary.

This model is complete but inert. It describes what exists, who does what, where things happen, and what costs what. It does not describe what happens *when* — the dynamic behaviour of the business. The entities are ready to interact but cannot yet, because no processes or interactive functions are in place.

The static model needs to be wired up.

---

## Two Phases of Construction

The path from raw business information to a wired-up model involves two distinct phases with a critical boundary between them.

### Phase 1: Classification and Population

Take the raw business information (the "what the user walks in with"), classify each piece against the ontology, assign it to a BMM General concept, and instantiate it as a domain-specific entity. At the end of this phase there is a structured inventory: five ServiceOfferings, three StaffMembers, six Rooms, a set of PricingRules, and so on. Each entity knows *what it is* but not *how it relates to anything else*.

### Phase 2: Relation Binding

Stitch the entities together by confirming typed relations between them. Many relations are inferrable from the intake data — if the Standard Groom includes a bath, Ontara can propose that ServiceOffering:StandardGroom *requires* Room:WetGroomingRoom. The user validates, corrects, or extends the proposed bindings.

The relation types form a finite vocabulary at the BMM level: *requires*, *produces*, *fulfils*, *constrains*, *modifies*, *includes*, *serves*, *consumes*, and so on. Each relation type is itself classifiable by the ontological categories of the things it connects, providing a two-dimensional validation: not just "is this the right relation?" but "is this relation type-compatible given the ontological categories of the entities it connects?"

The boundary between Phase 1 and Phase 2 is a useful checkpoint. The unstitched inventory lets the user see everything organised by category and check for completeness before wiring begins.

### Convention Over Configuration

At the relation-binding level, most connections are structurally determined by the types of the things being connected. If there is a ServiceOffering and a Room, the question is not *whether* they relate but *which* rooms *which* services use. The BMM type system dramatically narrows the space of valid connections. The experience for the user is largely "confirm or correct" rather than "design from scratch" — convention over configuration, where the conventions are supplied by the BMM.

### Iterative Opportunity

Both phases should support iteration. The user sees the result, evaluates it (does it match a pattern I recognise? does it make sense? does it break when I check it?), and has another go. Iteration at every stage is essential while the platform and its users are learning together.

---

## The Process Specification Layer

### Process Identification from the Relation Graph

Every typed relation in the static model implies at least one process that *activates* that relation at runtime:

- ServiceOffering *requires* Room → there must be a **room allocation** process
- StaffMember *fulfils* Role *constrained by* WorkingPattern → there must be a **coverage management** process
- Customer *initiates* Exchange for ServiceOffering → there must be a **booking** process
- Consumable *consumed by* ServiceOffering → there must be a **replenishment** process
- PricingRule *modifies* Exchange → there must be a **price calculation** process

Ontara can walk the relation graph, identify every relation that implies a process, and generate a process inventory. This is systematic, not creative — the static model *determines* the process landscape.

### Three Levels of Abstraction

The process specification operates at three levels:

#### Level 1: Process Archetypes

The most abstract level, generated directly from the ontological categories of the entities involved.

| Archetype | Ontological pattern | Description |
|---|---|---|
| **Resource allocation** | Activity *requires* Resource | Find candidates, check constraints, allocate or fail with alternatives |
| **Task assignment** | Agent *performs* Activity | Match agent to task based on capability, availability, and workload |
| **Transaction** | Exchange between Agents | Initiate, validate, execute, confirm or compensate |
| **Validation** | Rule *constrains* Activity | Check preconditions, evaluate constraints, gate or redirect |
| **Scheduling** | Activity *bounded by* Temporal | Check availability, reserve slot, confirm or propose alternatives |
| **Notification** | Activity *produces* information for Agent | Determine recipients, compose message, deliver, confirm receipt |
| **State transition** | Entity *changes* Quality | Validate transition, update state, trigger consequent processes |
| **Assessment** | Agent *evaluates* Quality of entity | Gather inputs, apply criteria, record outcome |
| **Fulfilment** | Activity *completes* Exchange | Deliver service/product, record completion, trigger payment |
| **Escalation** | Activity *fails* or *exceeds* constraint | Detect exception, notify, reassign or defer |
| **Replenishment** | Resource *falls below* threshold | Monitor level, trigger reorder, receive and restock |
| **Reporting** | Aggregation of Measures over Temporal | Collect data, compute metrics, present to Agent |

These are universal — the same set applies to any business on Ontara. The library is expected to be relatively small (perhaps 12–20 archetypes) and stable.

#### Level 2: Process Patterns

The BMM-level expression of archetypes, parameterised by the specific concept types involved.

| Archetype | BMM parameterisation | Paws pattern |
|---|---|---|
| Resource allocation | ServiceOffering + Room | Room booking for groom type |
| Task assignment | ServiceOffering + StaffMember | Groomer assignment |
| Scheduling | ServiceOffering + Temporal + DogSizeClassification | Appointment slot calculation |
| Transaction | Customer + ServiceOffering + PricingRule | Booking and payment |
| Validation | PricingRule + DogProfile (size, coat, behaviour) | Price calculation with surcharges |
| Assessment | BehaviourAssessment + ServiceSubject | Dog temperament assessment on arrival |
| Replenishment | Consumable + threshold | Shampoo/towel reorder |
| Reporting | CostCategory + Temporal | Monthly P&L |

Patterns carry structure: they know they need a trigger, inputs, constraints to check, an outcome, and a failure path. They do not yet know the specific Paws details.

#### Level 3: Process Instances (Process Sketches)

The domain-specific wiring. Each pattern is instantiated with concrete Paws entities and business rules. This is where the user's domain knowledge fills in the detail — but the *shape* was already determined by the archetype and pattern.

Example process sketch:

```
process: book_appointment
  archetype: resource_allocation + scheduling
  trigger: customer_request(service, dog)
  inputs: service_offering, dog_profile → [size, coat, behaviour]
  allocate: groomer ∈ {sam, sue} where available(groomer, timeslot)
  allocate: room_sequence from service.room_requirements
  check: no_conflict(rooms, timeslot, duration)
  check: duration = lookup(service, dog.size)
  output: confirmed_booking | proposed_alternatives
  on_failure: suggest_next_available
```

This sketch is typed against the BMM — every entity referenced must exist in the static model. It is human-readable: the user can validate "yes, that's how booking works" or correct it. It is also mechanically compilable to an executable intermediate representation.

---

## The Compilation Pipeline

### Process Sketch DSL → Temporal DSL YAML

The process sketch DSL compiles down to Temporal DSL YAML (CNCF Serverless Workflow flavour). This is a mechanical translation:

- The **archetype** expands into a standard sequence of activity calls
- Each **allocate** and **check** step becomes a Temporal activity with typed inputs/outputs
- The **trigger** becomes a workflow input or Temporal signal
- **output** and **on_failure** become terminal branches or `onError` handlers
- **Entity references** are resolved against the static model to generate typed data structures

Example compilation target:

```yaml
document:
  dsl: 1.0.0
  namespace: paws
  name: book-appointment
  version: 0.1.0
  metadata:
    archetype: resource_allocation+scheduling
    bmm_refs: [ServiceOffering, Room, StaffMember, DogSizeClassification]

do:
  - loadProfiles:
      call: activity
      with:
        name: getDogAndServiceProfiles
      result: profiles
  - allocateGroomer:
      call: activity
      with:
        name: allocateGroomer
        args:
          service: "{{ .service }}"
          dog: "{{ .dog }}"
      result: groomer
  - allocateRooms:
      call: activity
      with:
        name: allocateRooms
        args:
          service: "{{ .service }}"
      result: room_sequence
  - checkConstraints:
      call: activity
      with:
        name: checkConstraints
        args:
          groomer: "{{ .groomer }}"
          rooms: "{{ .room_sequence }}"
          dog: "{{ .dog }}"
      onError:
        - suggestAlternatives:
            call: activity
            with:
              name: suggestNextAvailable
            end: true
  - confirmBooking:
      call: activity
      with:
        name: confirmBooking
      end: true
```

The user never sees this layer. It is the executable IR.

### Temporal DSL YAML → Execution

The YAML is interpreted by a generic Temporal DSL worker, or used to generate typed workflow and activity stubs in the target language (Python, in Ontara's case). Each activity stub has a typed signature derived from the BMM entities it references, and an implementation body that either calls domain logic directly or delegates to further services.

---

## The Full Pipeline

Summarising the complete path from user intake to running systems. In the [[ontara-discussion-dual-stack-architecture-2026-03-26|dual-stack architecture]], this pipeline crosses from the left stack (business model) to the right stack (business system model). Steps 1–7 are business model work on the left side; Steps 8–10 produce system artefacts that land on the right side. The crossing point is the compilation step, where business process patterns map across to system-mediated execution via the [[ontara-ref-master-register|horizontal mappings (B12)]].

| Step | Description | User involvement | Stack |
|---|---|---|---|
| 1. **Intake** | User provides business information (narrative, lists, financials) | Active — provides information | Left |
| 2. **Classification** | Ontara classifies each piece against the ontology | Validates assignments | Left |
| 3. **BMM population** | Each classified piece is assigned to a BMM General concept | Validates or corrects | Left |
| 4. **Instantiation** | BMM concepts are populated with domain-specific entities | Confirms entities, adds missing ones | Left |
| 5. **Relation binding** | Typed relations between entities are proposed and confirmed | Validates, corrects, extends | Left |
| 6. **Process identification** | Ontara walks the relation graph to identify required processes | Reviews process inventory | Left |
| 7. **Process sketch generation** | Archetypes expand into process sketches parameterised by Paws entities | Validates sketches, adjusts business rules | Left |
| 8. **Compilation** | Sketches compile to Temporal DSL YAML | Not involved | **Left → Right** |
| 9. **Code generation** | Activity stubs generated with typed signatures from BMM | Not involved | Right |
| 10. **Deployment** | Workflows deployed to Temporal, systems scaffolded | Sees working systems | Right |

Steps 1–7 are iterative at each stage. Steps 8–10 are mechanical.

The critical insight is that the user's involvement is front-loaded and domain-focused. The user is never asked to be a systems architect. They confirm or correct a structured representation of things they already know about their own business. The architecture is Ontara's job; the user's job is domain truth.

---

## Relationship to Existing Architecture

### Dual-stack architecture

The [[ontara-discussion-dual-stack-architecture-2026-03-26|dual-stack architecture]] (Session 73) places the process specification layer firmly on the **left (business model) side**. Process archetypes, process patterns, and process sketches are all business model content — they describe how the business operates, not how a system implements it. In the corrected left-hand stack (§2 of the dual-stack paper), they occupy the bottom two layers: operational domains and business process patterns.

The pipeline described in this paper crosses from the left stack to the right stack at the compilation step. Business process patterns on the left map across to system-mediated execution on the right via [[ontara-ref-master-register|horizontal mappings (B12)]]. The compilation target (Temporal DSL YAML) and the generated activity stubs are right-stack (BSMM) artefacts. At runtime, the compiled processes become part of the [[concept-operational-simulation|operational simulation (L5)]] — the BSMM made live.

### Six-layer architecture

The process specification layer extends the business model side of the [[ontara-ref-master-register|six-layer architecture (B1)]] downward from static structure into dynamic behaviour. It sits within Layer 3 (business model instances), not between layers. The [[ontara-ref-master-register|rules and constraints]] that govern dynamic behaviour operate within the green container that wraps the bottom two pairs on both sides of the dual stack.

### SysML v2

The process sketch DSL has a natural mapping to SysML v2 action flows. The archetype library could be expressed as abstract action defs with the sketch instances as concrete action usages. This would keep the process specifications within the SysML model alongside the structural definitions, maintaining the [[principle-model-generates-everything|single-source principle (A3)]].

### Temporal

Already in the Ontara stack from the Coffee Shop CDR work. The Temporal DSL (Serverless Workflow flavour) provides the executable IR without requiring Ontara to invent one. The compilation from sketch DSL to Temporal YAML is a well-defined translation problem. At runtime, this lands in the [[concept-operational-simulation|operational simulation (L5)]] on the right side of the dual stack.

### CLP(FD) Scheduling

The `allocate` and `check` steps in the process sketches are where constraint logic programming enters. When a process sketch says `allocate: groomer ∈ {sam, sue} where available(groomer, timeslot)`, the runtime implementation delegates to the CLP(FD) solver (SWI-Prolog `library(clpfd)`) with the constrainable resource attributes from the static model. The process sketch specifies *what* needs to be allocated and *what constraints* apply; the solver determines *how*. The [[ontara-discussion-dual-stack-architecture-2026-03-26|dual-stack paper]] (§8.4) connects this to [[concept-goal-seeking-computation|goal-seeking computation (L9)]] — constraint satisfaction over the [[concept-coordinate-framework|coordinate space (A12)]].

---

## Next Steps

1. **Define the archetype library** — enumerate the full set of process archetypes with their expansion patterns. Validate against Cafe, Suds, and Paws.
2. **Formalise the sketch DSL grammar** — define the syntax and typing rules for process sketches. Ensure every entity reference resolves against the BMM.
3. **Build a prototype compiler** — sketch DSL → Temporal DSL YAML for one or two Paws processes (booking, price calculation).
4. **Cross-domain validation** — confirm that the same archetypes and patterns generate sensible process inventories for Cafe and Suds.
5. **Explore SysML v2 representation** — determine whether process sketches should live as SysML action defs/usages in the model or as a separate DSL that references the model.

---

*From Static Model to Running Systems — Ontara Discussion Paper*
*Prepared: 25 March 2026 | GenderSense Limited*
*Revised: 27 March 2026 (Session 75) — framing updated for [[ontara-discussion-dual-stack-architecture-2026-03-26|dual-stack architecture]] consistency*
