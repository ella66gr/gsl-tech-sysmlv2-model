---
tags:
  - plan
  - ontology
  - reasoning
  - safety
date: 2026-04-06
status: active
session: 156
---
# Stage 7 Phase 3 — Safety and Resilience: Detailed Implementation Plan
> `= this.file.path`

**Session:** 156
**Date:** 6 April 2026
**Purpose:** Detailed implementation plan for Phase 3 of the reasoning metamodel. Provides STAMP/STPA and FRAM-ready architectural slots in `ontara-reasoning.ttl` without committing to specific implementations (S146-Q7 resolution).
**Status:** Active plan.
**Depends on:** [[stage7-plan-s.148-reasoning-metamodel|Stage 7 plan]] §6, [[ontara-discussion-institutionalised-reasoning-2026-04-05|Institutionalised Reasoning (Session 146)]] §8, [[ontara-discussion-coordinate-framework-revisited-2026-04-05|The Coordinate Framework Revisited (Session 147)]]
**Inherits from:** Phase 2 closure (Session 155) — 34 classes, 11 named individuals, 24 object properties, 7 datatype properties, 50/50 SPARQL, HermiT CONSISTENT, 12-file ontology stack.

---

## Contents

- [[#1. Scope and Objectives|§1. Scope and Objectives]]
- [[#2. What Phase 3 Inherits|§2. What Phase 3 Inherits]]
- [[#3. Design Decisions|§3. Design Decisions]]
- [[#4. Implementation Steps|§4. Implementation Steps]]
- [[#5. Success Criteria|§5. Success Criteria]]
- [[#6. Session Estimate|§6. Session Estimate]]
- [[#7. Register Connections|§7. Register Connections]]
- [[#8. Coordinate Framework Conformity Check|§8. Coordinate Framework Conformity Check]]

---

## 1. Scope and Objectives

Phase 3 provides **architectural slots** for safety and resilience reasoning. The guiding principle is S146-Q7's resolution: FRAM-ready slots, no implementation commitment. The same principle applies to STAMP/STPA — enough structure to ground cross-domain validation and to give future safety work a typed home in the knowledge graph, without over-engineering a framework that will be elaborated when production safety requirements (particularly GSL clinical safety) demand it.

Three objectives:

1. **STAMP/STPA structures** — model the safety control loop (controller → controlled process → actuator → sensor), control action types, and unsafe control action classification. These describe the hierarchical control relationships through which safety constraints are enforced, and the ways those controls can fail.
2. **FRAM-ready slots** — model the six-aspect function abstraction (input, output, control, precondition, resource, time) and variability profiles. These describe the gap between work-as-imagined and work-as-done, which is where most quality and safety issues live.
3. **Safety–governance alignment** — connect safety constraints to the governance vocabulary and the existing HardConstraint hierarchy. Safety reporting as Claims with evidence trails.

### What Phase 3 is not

- Not a full STAMP/STPA implementation. No specific causal factor modelling, no STPA analysis tooling, no safety case generation.
- Not a FRAM execution engine. No resonance analysis, no variability propagation calculations.
- Not GSL-specific clinical safety content. The slots are domain-neutral; populating them with clinical safety structures is future domain content work.

---

## 2. What Phase 3 Inherits

### Vocabulary state (post-Phase 2)

| Metric | Value |
|---|---|
| Classes | 34 |
| Named individuals | 11 |
| Object properties | 24 |
| Datatype properties | 7 |
| SPARQL queries | 50 (11 groups) |
| Ontology stack | 12 files |
| HermiT | CONSISTENT |

### Directly relevant existing structures

- **HardConstraint** — already defined as a NormativeRegion boundary. SafetyConstraint will be a direct subclass.
- **Obligation, Prohibition** — already declared as HardConstraint subclasses (Phase 1 governance alignment). SafetyConstraint is a sibling, not a child of these.
- **ReasoningContext** — safety analysis is a type of reasoning activity with its own context.
- **Claim + EvidenceLine + EvidenceItem** — safety reporting uses the existing [[concept-evidence-architecture|evidence architecture]].
- **DecisionMode individuals** — ChaoticMode maps to emergency stabilisation; ComplexMode maps to adaptive monitoring where FRAM-style analysis is relevant.
- **NormativeRegion** (from the [[concept-coordinate-framework|coordinate framework]] Region taxonomy) — safety constraints define NormativeRegion boundaries. Unsafe control actions are trajectories that approach or cross those boundaries.

---

## 3. Design Decisions

| ID | Decision | Rationale |
|---|---|---|
| S156-D1 | STAMP/STPA modelled at control loop level (4–5 classes) plus UnsafeControlAction classification (4 STPA types), without specific causal factor modelling | Middle ground: enough structure for cross-domain validation and future elaboration, without overcommitting. Consistent with the "slots, not implementations" principle (S146-Q7) |
| S156-D2 | FRAM modelled as a FRAMFunction class with six coupling-aspect properties, plus a VariabilityProfile class with internal/external variability properties | Properties rather than classes for the six FRAM aspects — more natural OWL modelling since the aspects are attributes of a function, not independent entities. Keeps the FRAM vocabulary lightweight |
| S156-D3 | SafetyConstraint as direct HardConstraint subclass, independent of governance subclasses (Obligation, Prohibition) | A safety constraint is not necessarily a governance obligation (some are engineering constraints), though many governance obligations are safety constraints. The intersection is already captured by the existing Obligation → HardConstraint subclassing. Independence preserves modular clarity |
| S156-D4 | BFO grounding: ControlStructure and FRAMFunction as GDC (information via IAO), UnsafeControlAction as BFO Process | ControlStructure is information about control relationships (not the relationships themselves). FRAMFunction is a description of a function. UnsafeControlAction is something that happens (or fails to happen) — a process. Consistent with the Phase 1 constraint grounding decision (constraints are information, not dispositions) |
| S156-D5 | Cross-domain validation included for Phase 3 (Suds STAMP control hierarchy, Cafe basic safety structures) | Suds is particularly well-suited — operator/machine/COSHH/HSE is a natural STAMP control hierarchy (already identified in S146 §13.2). Without validation, the slots risk being too abstract for practical use |

---

## 4. Implementation Steps

### Step 3.1: STAMP/STPA structures [Code]

**Objective:** Define the safety control structure loop and unsafe control action classification.

**Classes to define:**

- `ontara-rsn:SafetyConstraint` — subclass of `ontara-rsn:HardConstraint`. A constraint whose violation constitutes a safety hazard. BFO parent: `iao:InformationContentEntity` (inherited from HardConstraint via Constraint → GDC chain).
- `ontara-rsn:ControlStructure` — a hierarchical arrangement of controllers, controlled processes, and feedback loops through which safety constraints are enforced. BFO parent: `iao:InformationContentEntity` (information about control relationships). Dual-subclassed with `prov:Entity` (following the Phase 1 pattern for information entities with provenance).
- `ontara-rsn:ControlAction` — an action taken by a controller to enforce a safety constraint on a controlled process. BFO parent: `bfo:Process`.
- `ontara-rsn:UnsafeControlAction` — a control action that leads to a hazard. Subclass of `ControlAction`. Four STPA subtypes modelled as a `UnsafeControlActionType` enumeration (named individuals): `NotProvided` (required action not taken), `ProvidedWhenNotNeeded` (action taken when it should not be), `WrongTiming` (action taken too early or too late), `WrongDuration` (action applied too long or stopped too soon).
- `ontara-rsn:ControlLoop` — a specific instance of the controller → actuator → controlled process → sensor → controller feedback cycle. Subclass of `ControlStructure` (a specific structural arrangement within the broader control structure).

**Properties to define:**

- `ontara-rsn:hasController` — links ControlLoop to the controlling entity (domain: ControlLoop, range: owl:Thing — deliberately broad since controllers can be human agents, software systems, or governance bodies)
- `ontara-rsn:hasControlledProcess` — links ControlLoop to the process being controlled (domain: ControlLoop, range: owl:Thing)
- `ontara-rsn:enforces` — links ControlAction to the SafetyConstraint it enforces (domain: ControlAction, range: SafetyConstraint)
- `ontara-rsn:hasUnsafeActionType` — links UnsafeControlAction to its STPA classification (domain: UnsafeControlAction, range: UnsafeControlActionType individual)
- `ontara-rsn:hasControlLoop` — links ControlStructure to its constituent ControlLoops (domain: ControlStructure, range: ControlLoop)
- `ontara-rsn:hierarchicallyControls` — transitive property linking controllers in a hierarchy (domain: owl:Thing, range: owl:Thing). Enables modelling of HSE → COSHH → operator → machine hierarchies.

**Datatype properties:**

- `ontara-rsn:hasHazardDescription` — string describing the hazard associated with a SafetyConstraint or UnsafeControlAction (domain: union of SafetyConstraint, UnsafeControlAction, range: xsd:string)

**Named individuals:**

- 4 UnsafeControlActionType individuals: `NotProvided`, `ProvidedWhenNotNeeded`, `WrongTiming`, `WrongDuration`

### Step 3.2: FRAM-ready slots [Code]

**Objective:** Define function abstraction and variability modelling slots.

**Classes to define:**

- `ontara-rsn:FRAMFunction` — a function description in the FRAM sense: a unit of activity with six coupling aspects. BFO parent: `iao:InformationContentEntity` (a description of a function, not the function itself). Dual-subclassed with `prov:Entity`.
- `ontara-rsn:VariabilityProfile` — a description of how a FRAMFunction's performance varies from its specification. BFO parent: `iao:InformationContentEntity`.

**Properties to define (six FRAM coupling aspects on FRAMFunction):**

- `ontara-rsn:hasFunctionInput` — what the function receives (domain: FRAMFunction, range: owl:Thing)
- `ontara-rsn:hasFunctionOutput` — what the function produces (domain: FRAMFunction, range: owl:Thing)
- `ontara-rsn:hasFunctionControl` — what governs how the function operates (domain: FRAMFunction, range: owl:Thing)
- `ontara-rsn:hasFunctionPrecondition` — what must be true before the function can operate (domain: FRAMFunction, range: owl:Thing)
- `ontara-rsn:hasFunctionResource` — what the function consumes during operation (domain: FRAMFunction, range: owl:Thing)
- `ontara-rsn:hasFunctionTime` — temporal constraints or dependencies (domain: FRAMFunction, range: owl:Thing)

**Properties for variability:**

- `ontara-rsn:hasVariabilityProfile` — links FRAMFunction to its VariabilityProfile (domain: FRAMFunction, range: VariabilityProfile, functional)
- `ontara-rsn:hasInternalVariability` — variability arising from within the function itself (domain: VariabilityProfile, range: xsd:string)
- `ontara-rsn:hasExternalVariability` — variability arising from upstream functions or environmental conditions (domain: VariabilityProfile, range: xsd:string)
- `ontara-rsn:coupledWith` — links FRAMFunctions whose variabilities interact (domain: FRAMFunction, range: FRAMFunction, symmetric)

### Step 3.3: Safety–governance alignment [Code]

**Objective:** Connect safety structures to the governance vocabulary.

**Axioms and properties to add:**

- `ontara-rsn:SafetyConstraint` declaration confirms it as a HardConstraint subclass (established in Step 3.1). No additional governance subclassing needed — the governance–reasoning alignment from Phase 1 (Obligation and Prohibition as HardConstraint subclasses) already means that safety-relevant governance obligations share the same HardConstraint parent. The key structural insight: a SafetyConstraint may or may not correspond to a governance Obligation, but both are HardConstraints in the coordinate space.
- `ontara-rsn:hasSafetyEvidence` — links a SafetyConstraint to a Claim providing evidence of satisfaction or violation (domain: SafetyConstraint, range: ontara-rsn:Claim). This reuses the evidence architecture from Phase 1 — safety reporting is Claims with EvidenceLines.
- `ontara-rsn:monitoredBy` — links a SafetyConstraint to the ControlLoop responsible for monitoring and enforcing it (domain: SafetyConstraint, range: ControlLoop).

**Cross-module alignment check:** Verify that the combined `ontara-rsn:` and `ontara-gov:` vocabulary remains HermiT CONSISTENT after adding safety structures. The safety vocabulary imports from `ontara-rsn:` (which already imports `ontara-gov:` unidirectionally). No new cross-module imports should be needed.

### Step 3.4: Cross-domain validation [Chat]

**Objective:** Validate all safety structures against Cafe and Suds.

**Suds validation (primary — richer safety domain):**

| Structure | [[domain-suds\|Suds]] exercise |
|---|---|
| SafetyConstraint | COSHH chemical handling limits; maximum wash temperature for fabric types |
| ControlStructure | HSE → COSHH authority → operator → washing machine: four-level hierarchy |
| ControlLoop | Operator checks chemical concentration → adjusts dosing → machine cycle → sensor readings → operator review |
| ControlAction | Operator selects wash programme; operator verifies chemical levels |
| UnsafeControlAction | NotProvided: operator skips COSHH check. ProvidedWhenNotNeeded: operator adds chemical to already-dosed load. WrongTiming: chemical added after cycle starts. WrongDuration: reduced rinse cycle for hazardous chemical load |
| FRAMFunction | "Prepare wash load" function with six aspects: input (dirty laundry), output (loaded machine), control (COSHH protocol), precondition (machine available and clean), resource (chemicals, water), time (within shift schedule) |
| VariabilityProfile | Internal: operator experience varies. External: chemical supplier consistency, machine age |
| coupledWith | "Prepare wash load" coupled with "Run wash cycle" — variability in preparation propagates to cycle outcomes |

**[[domain-cafe|Cafe]] validation (lighter):**

| Structure | Cafe exercise |
|---|---|
| SafetyConstraint | Food hygiene temperature requirements; allergen handling protocols |
| ControlStructure | Health authority → cafe management → barista: three-level hierarchy |
| ControlLoop | Barista checks milk temperature → serves drink → customer feedback → management review |
| UnsafeControlAction | NotProvided: barista doesn't check milk temperature. WrongTiming: allergen check after drink is made |
| FRAMFunction | "Prepare drink" with six aspects |
| VariabilityProfile | Internal: barista skill. External: rush hour volume, equipment reliability |

**Acceptance criteria:** Written analysis confirming every Phase 3 class has at least one natural instantiation in each domain. Every new property exercised. The four UnsafeControlActionType individuals each demonstrated in at least one domain.

### Step 3.5: SPARQL validation suite extension [Code]

**Objective:** Extend `validate_kg.py` with safety-specific queries in the Reasoning group (or a new Safety subgroup).

**Queries to add:**

- Safety class hierarchy (SafetyConstraint, ControlStructure, ControlLoop, ControlAction, UnsafeControlAction, FRAMFunction, VariabilityProfile all exist under declared parents)
- Safety property declarations (all new object and datatype properties have correct domain/range)
- STAMP completeness (4 UnsafeControlActionType named individuals present)
- SafetyConstraint as HardConstraint subclass confirmed
- FRAM coupling aspects (6 function aspect properties declared on FRAMFunction)
- VariabilityProfile linking (functional property from FRAMFunction to VariabilityProfile)

**Acceptance criteria:**

- All new queries pass
- Full suite (50 existing + new) runs green
- HermiT CONSISTENT with full 12-file stack

---

## 5. Success Criteria

| # | Criterion | Traces to |
|---|---|---|
| P3-1 | SafetyConstraint declared as HardConstraint subclass | Stage 7 plan §6 Step 3.3, S156-D3 |
| P3-2 | ControlStructure, ControlLoop, ControlAction, UnsafeControlAction classes declared with BFO grounding | Stage 7 plan §6 Step 3.1, S156-D1, S156-D4 |
| P3-3 | 4 UnsafeControlActionType named individuals (NotProvided, ProvidedWhenNotNeeded, WrongTiming, WrongDuration) | S156-D1 |
| P3-4 | FRAMFunction class with 6 coupling-aspect properties | Stage 7 plan §6 Step 3.2, S156-D2 |
| P3-5 | VariabilityProfile class with internal/external variability and coupledWith property | S156-D2 |
| P3-6 | Safety–governance alignment: hasSafetyEvidence and monitoredBy properties connecting safety to evidence architecture and control loops | Stage 7 plan §6 Step 3.3 |
| P3-7 | Cross-domain validation — every safety class instantiated in Cafe and Suds | A5/J1, S156-D5 |
| P3-8 | SPARQL suite extended and fully green | A9 |
| P3-9 | HermiT CONSISTENT with full ontology stack | Standing requirement |

---

## 6. Session Estimate

| Step | Sessions | Tool |
|---|---|---|
| 3.1–3.3 combined | 1 | Code |
| 3.4 cross-domain validation | <1 | Chat |
| 3.5 SPARQL extension | <1 | Code (can combine with 3.1–3.3) |

**Total: 1–2 sessions** (at the low end of the Stage 7 plan's 2–4 estimate for Phase 3). This is achievable because: (a) design decisions are pre-agreed (S156-D1 to D5), (b) the scope is deliberately bounded to slots not implementations, (c) the Phase 1/2 patterns for BFO grounding, dual subclassing, and property declaration are well-established, and (d) the existing HardConstraint hierarchy provides a ready-made anchor for SafetyConstraint.

**Efficiency decision:** Steps 3.1–3.3 should be combined into a single Code session, following the S155-D4 precedent (Phase 2 combined Steps 2.1–2.3). The three steps are OWL-independent at the section level and can be authored in a single pass through `ontara-reasoning.ttl`.

---

## 7. Register Connections

### Tier 1 principles engaged

| Principle | How engaged |
|---|---|
| [[principle-deterministic-over-probabilistic\|A6]] (Deterministic/auditable reasoning) | Safety constraints are the hardest of hard constraints — the structural floor beneath the four-category scheme. UnsafeControlAction classification makes safety failure modes explicit and inspectable |
| [[principle-clinical-governance-first-class\|A8]] (Governance as first-class concern) | Safety–governance alignment connects safety structures to the governance vocabulary. SafetyConstraint as HardConstraint means safety is architecturally within the governance hierarchy |
| [[principle-discipline-as-load-bearing-structure\|A9]] (Discipline) | SPARQL suite extension, cross-domain validation, systematic close sequence |
| [[principle-unity-principle\|A11]] (Unity principle) | Safety constraints are NormativeRegion boundaries in the same coordinate space that comprehension, reasoning, and governance operate within. One model, not a separate safety silo |
| [[concept-coordinate-framework\|A12]] (Coordinate framework) | SafetyConstraint as NormativeRegion boundary. UnsafeControlAction as trajectory approaching or crossing that boundary. FRAM variability as perturbation of trajectories. All interpretable in coordinate-framework geometry |
| [[concept-multi-tenancy\|A13]] (Multi-tenancy) | Safety structures are platform-level vocabulary; their deployment is per-tenant. A cafe's safety constraints and a hospital's safety constraints use the same typed vocabulary but different content |
| [[concept-cross-domain-validation\|J1]] (Cross-domain validation) | Step 3.4 validates in Cafe and Suds |
| [[concept-co-evolution\|J2]] (Co-evolution) | OWL safety vocabulary co-evolves with future Phase 4 console views |
| [[concept-non-constraining\|J3]] (Non-constraining) | Slots, not implementations. FRAMFunction six-aspect properties are owl:Thing range — deliberately unconstrained for future elaboration. ControlStructure hierarchy supports arbitrary depth without commitment |

### Tier 2 concepts exercised

| Concept | How exercised |
|---|---|
| [[concept-safety-resilience-structures\|P6]] (Safety and resilience structures) | Fully elaborated — STAMP/STPA classes, FRAM slots, safety–governance alignment |
| [[concept-reasoning-metamodel\|P1]] (Reasoning metamodel) | Extended with safety reasoning capability |
| [[concept-evidence-architecture\|P2]] (Evidence architecture) | Safety reporting as Claims with evidence trails (hasSafetyEvidence) |
| [[concept-authority-zones\|B29]] (Authority zones) | OWL authoritative for safety class structure; runtime authoritative for actual safety enforcement |
| B30–B35 (Governance vocabulary) | SafetyConstraint as HardConstraint sibling to Obligation/Prohibition |

---

## 8. Coordinate Framework Conformity Check

Per the standing instruction (Session 147): every significant piece of Phase 3 work is checked against the [[ontara-discussion-coordinate-framework-revisited-2026-04-05|coordinate framework revisited paper]].

| Phase 3 element | Coordinate framework conformity |
|---|---|
| SafetyConstraint | A HardConstraint — therefore a NormativeRegion boundary per §7.1 of the coordinate framework revisited paper. Safety constraints define regions that must not be entered (or must not be exited). Consistent with the constraint geometry interpretation (S147-D3) |
| ControlStructure / ControlLoop | Describes the mechanisms that maintain trajectories within safe NormativeRegions. The hierarchical control relationship (HSE → COSHH → operator → machine) is a chain of boundary enforcement at successively finer granularity |
| UnsafeControlAction | A trajectory event that causes approach to or crossing of a NormativeRegion boundary. The four STPA types are four failure modes of boundary maintenance: not maintaining (NotProvided), over-maintaining (ProvidedWhenNotNeeded), temporal misalignment (WrongTiming), duration misalignment (WrongDuration) |
| FRAMFunction | Describes a function in coordinate-framework terms: the function transforms a region of coordinate space (inputs) into another region (outputs), governed by control parameters and subject to preconditions, resource availability, and temporal constraints. The six coupling aspects are projections of the function onto different coordinate axes |
| VariabilityProfile | Describes the spread of actual trajectories around the specified trajectory. Internal variability is intrinsic perturbation; external variability is perturbation from coupled functions. Resonance (not modelled in Phase 3 — future work) would be when perturbations from multiple coupled functions combine to push trajectories toward NormativeRegion boundaries |
| coupledWith | Describes functions whose trajectory perturbations interact — a structural relationship in coordinate space. Symmetric because coupling is bidirectional (A affects B's variability, B affects A's). Connects to [[principle-unity-principle\|A11]] — the same coordinate space hosts both the constraint geometry and the variability analysis |

No contradictions or ambiguities identified. The Phase 3 design is consistent with the coordinate framework and the unity principle.

---

*Plan produced Session 156, 6 April 2026. Covers Phase 3 of the Stage 7 reasoning metamodel. Design decisions S156-D1 to D5 agreed in session.*
