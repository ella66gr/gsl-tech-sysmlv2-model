---
tags:
  - plan
  - ontology
  - reasoning
date: 2026-04-05
status: active
session: 148
---
# Stage 7 Plan — Reasoning Metamodel Implementation
> `= this.file.path`

**Session:** 148
**Date:** 5 April 2026
**Purpose:** Implementation plan for the reasoning metamodel. Covers coordinate framework consolidation (Phase 0), OWL vocabulary authoring (Phase 1), depth features (Phase 2), safety/resilience structures (Phase 3), and console integration (Phase 4).
**Status:** Active plan.
**Depends on:** [[ontara-discussion-coordinate-framework-revisited-2026-04-05|The Coordinate Framework Revisited (Session 147)]], [[ontara-discussion-institutionalised-reasoning-2026-04-05|Institutionalised Reasoning (Session 146)]], [[ontara-discussion-coordinate-framework-2026-03-22_1|The Coordinate Framework (Session 59)]], [[ontara-discussion-ontological-grounding-2026-03-22|Ontological Grounding (Session 59)]]
**Design decisions resolved:** S147-D1 to D7, S146-D1 to D8 — all confirmed Session 148.
**Work item:** [[ontara-ref-work-items|W-026]]

---

## Contents

- [[#1. Scope and Objectives|§1. Scope and Objectives]]
- [[#2. What Stage 7 Is Not|§2. What Stage 7 Is Not]]
- [[#3. Phase 0 — Coordinate Consolidation|§3. Phase 0 — Coordinate Consolidation]]
- [[#4. Phase 1 — Reasoning Foundation|§4. Phase 1 — Reasoning Foundation]]
- [[#5. Phase 2 — Depth|§5. Phase 2 — Depth]]
- [[#6. Phase 3 — Safety and Resilience|§6. Phase 3 — Safety and Resilience]]
- [[#7. Phase 4 — Console Integration|§7. Phase 4 — Console Integration]]
- [[#8. Step Summary|§8. Step Summary]]
- [[#9. Design Decisions Implemented|§9. Design Decisions Implemented]]
- [[#10. Success Criteria|§10. Success Criteria]]
- [[#11. Session Estimate|§11. Session Estimate]]
- [[#12. Register Connections|§12. Register Connections]]
- [[#13. Risks and Mitigations|§13. Risks and Mitigations]]
- [[#14. Coordinate Framework Standing Instruction|§14. Coordinate Framework Standing Instruction]]

---

## 1. Scope and Objectives

Stage 7 implements the reasoning metamodel as a first-class platform capability. The reasoning metamodel was designed across two discussion papers — the [[ontara-discussion-institutionalised-reasoning-2026-04-05|Institutionalised Reasoning paper (Session 146)]] and the [[ontara-discussion-coordinate-framework-revisited-2026-04-05|Coordinate Framework Revisited paper (Session 147)]] — and its fifteen design decisions (S146-D1 to D8, S147-D1 to D7) were all confirmed in Session 148.

The stage has five objectives:

1. **Consolidate the coordinate framework** so that the reasoning metamodel's foundational vocabulary (epistemic dimensions, Region taxonomy, constraint geometry) is coherent and registered before OWL authoring begins.
2. **Author the reasoning OWL vocabulary** (`ontara-reasoning.ttl`) as a hand-authored module following the `ontara-governance.ttl` pattern, with PROV-O import and SEPIO-pattern evidence architecture.
3. **Extend the reasoning vocabulary with depth features** — heuristic packs, decision mode routing, constraint satisfaction structures.
4. **Provide architectural slots for safety and resilience** — STAMP/STPA and FRAM-ready structures without committing to specific implementations.
5. **Integrate reasoning into the Ontara Console** — reasoning explorer, evidence browser, and decision trace views.

Stage 7 follows the same sequential phasing that worked in Stage 5: each phase depends on the previous one, and no OWL code is authored until the conceptual foundations are solid.

---

## 2. What Stage 7 Is Not

The following are explicitly **out of scope** for Stage 7:

- **Runtime reasoning engine implementation.** Stage 7 produces the OWL vocabulary and SysML structures that *describe* reasoning components. It does not implement Bayesian updaters, constraint solvers, or PSL engines. Runtime engines are deployment-time concerns. Per [[concept-authority-zones|B29]]: OWL is authoritative for class structure; runtime engines implement computational semantics.
- **GSL-specific clinical reasoning content.** Stage 7 provides the vocabulary for clinical reasoning (ReasoningContext, Claim, EvidenceLine, RiskCalculator, etc.). Populating that vocabulary with GSL-specific clinical pathways, risk calculators, and treatment protocols is domain content work, not metamodel work. Same boundary as Stage 5 Phase 3 (governance vocabulary schema without Regulation 17 content).
- **Tau Prolog integration.** F6 (Tau Prolog engine) is already validated and operational. Stage 7's reasoning metamodel provides the *typed slots* that Prolog-based reasoning occupies (Tier 2 inspectable logic), but does not redesign the Prolog integration.
- **Full PROV-O import.** Phase 1 imports the core PROV-O subset (S146-Q3/S147-Q5): `prov:Entity`, `prov:Activity`, `prov:Agent`, plus core properties. The PROV-O Qualifications module is deferred unless Phase 1 reveals a need.
- **Overdue foundations paper refreshes** ([[ontara-ref-work-items|W-021, W-022, W-023]]). These remain deliberately deferred — they will need updating once Stage 7's implications are clear, but doing them now would mean doing them twice.

---

## 3. Phase 0 — Coordinate Consolidation

**Objective:** Ensure the coordinate framework can bear the weight the reasoning metamodel places on it. Reconcile epistemic vocabulary, enrich the Region taxonomy, formalise constraint geometry, state BFO/PROV-O alignment, and reformulate A6. This phase produces concept note updates and register entries, not code.

**Rationale (S147-D6):** The coordinate framework is foundational *to* the reasoning metamodel. Building reasoning OWL classes on an underspecified coordinate foundation risks structural rework.

### Step 0.1: Update the A12 concept note [Chat]

Update [[concept-coordinate-framework|A12]] to reflect:
- The enriched Region taxonomy (S147-D2): seven subtypes (StaticBoundary, GoalRegion, NormativeRegion, ProbabilityDistribution, ScalarField, ClassificationRegion, FormalisationFrontier), declared extensible
- The constraint geometry interpretation (S147-D3): HardConstraints as boundaries, SoftConstraints as cost fields, GradedRules as truth-value fields
- The connection to L9 (goal-seeking computation as pathfinding)
- The convergence of comprehension and reasoning (S147-D7)

**Acceptance criteria:** Concept note reflects the Session 147 consolidation. Region subtypes documented. Constraint geometry documented. Cross-references to the coordinate framework revisited paper.

### Step 0.2: Update the B17 concept note [Chat]

Update [[concept-epistemic-modality|B17]] to reflect the three-dimensional epistemic vocabulary (S147-D1):
- Provenance modality (seven values, existing)
- Functional purpose (five values from L8)
- Evidential confidence (with declared interpretive frame)
- Composition rules and validity constraints between dimensions

**Acceptance criteria:** Three dimensions documented. Composition examples given. Invalid combinations noted.

### Step 0.3: Reformulate the A6 principle note [Chat]

Rewrite [[principle-deterministic-over-probabilistic|A6]] per S147-D5. This is a confirmed T1 amendment. The principle note must reflect the four-category scheme: deterministic rules (Tier 1), inspectable logic (Tier 2), structured probabilistic (new), opaque probabilistic (Tier 3). In coordinate-framework language: deterministic paths through a probabilistically characterised landscape.

**Acceptance criteria:** Principle note rewritten. Four-category scheme documented. Coordinate-framework interpretation stated. Governance provenance recorded (Session 148, T1 amendment, Ella's decision).

### Step 0.4: Register new concepts (B40–B46) and section P [Chat]

Register the seven candidate concepts from the reasoning metamodel paper §16.2, now in section P (Reasoning and Problem-Solving Concepts):

| Code | Concept | Tier |
|---|---|---|
| B40 | Reasoning metamodel | T2 |
| B41 | Evidence architecture (SEPIO + PROV-O) | T2 |
| B42 | Decision mode routing | T2 |
| B43 | Heuristic layer | T2 |
| B44 | Intentional structure (Goals/Obstacles) | T2 |
| B45 | Safety and resilience structures | T3 |
| B46 | Structured probabilistic reasoning | T2 |

**Note:** These are currently coded B40–B46 in the discussion paper. The actual register codes will be P-prefixed when section P is created. The B-series codes in the discussion paper were provisional.

**Acceptance criteria:** Section P created in master register. Seven concepts registered with concept notes. Cross-references to source papers. B19 ([[concept-ontology-stack|Ontology stack]]) updated to note PROV-O addition (S146-D2/S147-D4).

### Step 0.5: Record design decisions [Chat]

Record all fifteen confirmed design decisions (S147-D1–D7, S146-D1–D8) in a consolidated design decision log within this plan or as annotations on the source papers.

**Acceptance criteria:** All decisions recorded with confirmation session number.

### Phase 0 deliverables

1. Updated A12 concept note (Region taxonomy, constraint geometry)
2. Updated B17 concept note (three-dimensional epistemic vocabulary)
3. Rewritten A6 principle note (T1 amendment)
4. Seven new register concepts in section P
5. Updated B19 concept note (PROV-O in ontology stack)
6. All design decisions recorded

**Estimated effort:** 2–3 sessions. Concept note updates are text work but require precision — each note must be internally consistent and cross-referenced correctly.

---

## 4. Phase 1 — Reasoning Foundation

**Objective:** Author the core reasoning OWL vocabulary (`ontara-reasoning.ttl`) with PROV-O import, evidence architecture, and cross-domain validation in at least two demonstrator domains. This is the primary code-producing phase.

**Prerequisite:** Phase 0 complete — all concept notes updated, register entries in place, A6 reformulated.

### Step 1.1: PROV-O import and alignment [Code]

**Objective:** Import the PROV-O core subset into the ontology stack and verify consistency.

**What to do:**
1. Obtain PROV-O Turtle file from W3C and place in `ontology/imports/`.
2. Create `ontara-reasoning.ttl` in `ontology/reasoning/` with namespace `ontara-rsn:`.
3. Declare `owl:imports` for PROV-O, BFO, CCO, IAO (as needed).
4. Implement dual subclassing (S147-D4): `ontara-rsn:ReasoningActivity rdfs:subClassOf bfo:Process, prov:Activity`. `ontara-rsn:Claim rdfs:subClassOf iao:InformationContentEntity, prov:Entity`.
5. Run HermiT — confirm CONSISTENT with PROV-O in the stack.
6. Add SPARQL validation queries for PROV-O alignment.

**Acceptance criteria:** PROV-O core imported. Dual subclassing declared. HermiT CONSISTENT. SPARQL queries confirm PROV-O classes and properties are accessible.

**Design decisions implemented:** S146-D2 (PROV-O import), S147-D4 (dual subclassing), S146-D3 (separate OWL module).

### Step 1.2: Core reasoning classes [Code]

**Objective:** Author the abstract reasoning class hierarchy.

**Classes to define (starting with abstract types per S146-Q5):**

*Reasoning context and episodes:*
- `ontara-rsn:ReasoningContext` — the context within which reasoning occurs (domain position, decision mode, available knowledge sources)
- `ontara-rsn:ReasoningActivity` (subclass of `bfo:Process`, `prov:Activity`) — a single reasoning episode
- `ontara-rsn:ReasoningComponent` — abstract type for typed reasoning capabilities

*Intentional structure (S146-D4, grounded in coordinate framework by S147-D2):*
- `ontara-rsn:Goal` — intentional target referencing a GoalRegion in coordinate space
- `ontara-rsn:Obstacle` — constraint on trajectories toward a goal
- `ontara-rsn:Measure` — projection onto a coordinate axis for evaluation

*Decisions and plans:*
- `ontara-rsn:Decision` — a choice among alternatives, produced by a ReasoningActivity
- `ontara-rsn:Plan` — a sequence of intended actions toward a Goal

*Constraints (S146-D8, grounded by S147-D3):*
- `ontara-rsn:Constraint` — abstract constraint type
- `ontara-rsn:HardConstraint` — NormativeRegion boundary (violation = failure)
- `ontara-rsn:SoftConstraint` — ScalarField cost/preference surface
- `ontara-rsn:GradedRule` — ScalarField truth-value surface

*Knowledge sources:*
- `ontara-rsn:KnowledgeSource` — abstract type for knowledge inputs to reasoning
- `ontara-rsn:Heuristic` — declarative heuristic (S146-D6), abstract type for Phase 2 elaboration

**Properties to define:**
- PROV-O provenance properties on `ReasoningActivity` (`prov:used`, `prov:wasAssociatedWith`, etc.)
- `ontara-rsn:hasContext` — links ReasoningActivity to ReasoningContext
- `ontara-rsn:hasGoal` — links ReasoningContext to Goal
- `ontara-rsn:hasConstraint` — links ReasoningContext to Constraint
- `ontara-rsn:producedDecision` — links ReasoningActivity to Decision
- `ontara-rsn:hasDecisionMode` — links ReasoningContext to decision mode classification (S146-D5)
- Domain/range declarations and OWL characteristics for all properties

**Acceptance criteria:** All classes declared with labels, comments, and parent classes. All properties declared with domain, range, and characteristics. HermiT CONSISTENT with full stack. SPARQL validation queries for reasoning class hierarchy and properties.

### Step 1.3: Evidence architecture (SEPIO pattern) [Code]

**Objective:** Implement the evidence architecture per S146-D7.

**Classes to define:**
- `ontara-rsn:Claim` (subclass of `iao:InformationContentEntity`, `prov:Entity`) — an assertion produced by reasoning
- `ontara-rsn:EvidenceLine` — a line of evidence supporting a Claim
- `ontara-rsn:EvidenceItem` — a specific piece of evidence within an EvidenceLine
- `ontara-rsn:ConfidenceAssessment` — evidential confidence with declared interpretive frame (probability, fuzzy membership, preference weight) per S147-D1

**Properties to define:**
- `ontara-rsn:supportedBy` — links Claim to EvidenceLine
- `ontara-rsn:hasEvidence` — links EvidenceLine to EvidenceItem
- `ontara-rsn:hasConfidence` — links Claim to ConfidenceAssessment
- `ontara-rsn:hasInterpretiveFrame` — links ConfidenceAssessment to its frame type
- `ontara-rsn:wasProducedBy` — links Claim to the ReasoningActivity that produced it (aligns with `prov:wasGeneratedBy`)
- Provenance chain properties connecting evidence to sources

**Acceptance criteria:** SEPIO-pattern classes declared. Properties with domain/range. HermiT CONSISTENT. SPARQL queries validate evidence chain structure.

### Step 1.4: Structured probabilistic reasoning types [Code]

**Objective:** Implement the new category between Tier 2 and Tier 3 per S147-D5 and the reasoning metamodel §11.6.

**Classes to define (abstract types):**
- `ontara-rsn:StructuredProbabilisticComponent` (subclass of `ReasoningComponent`) — abstract type for validated probabilistic models
- `ontara-rsn:BayesianUpdater` — takes prior + evidence, produces posterior
- `ontara-rsn:RiskCalculator` — validated population-level risk model (subtype of BayesianUpdater with validation metadata)
- `ontara-rsn:PrognosticModel` — time-to-event or trajectory model
- `ontara-rsn:PredictiveAnalytics` — population-level probabilistic analysis

**Properties to define:**
- `ontara-rsn:hasPrior`, `ontara-rsn:hasPosterior` — probability distributions
- `ontara-rsn:hasValidationPopulation`, `ontara-rsn:hasPerformanceMetric` — validation metadata
- `ontara-rsn:hasConfidenceInterval` — bounds on probabilistic output

**Acceptance criteria:** Four typed components declared. Validation metadata properties defined. HermiT CONSISTENT. SPARQL queries validate the component hierarchy.

### Step 1.5: Cross-domain validation [Chat + Code]

**Objective:** Validate the core reasoning vocabulary against at least two demonstrator domains, per [[concept-cross-domain-validation|A5/J1]].

**Cafe validation (from reasoning metamodel §13.1):**
- Decision: Order priority determination (TriageDecision instance)
- Constraint: Barista availability, equipment capacity (HardConstraint instances)
- Goal: Fulfil all orders within SLA (Goal referencing GoalRegion)
- Heuristic: Prefer continuity — same barista completes the drink (Heuristic instance)
- Evidence/Claim: "Order fulfilled within SLA" — Claim with EvidenceLine (timestamps)

**Suds validation (from reasoning metamodel §13.2):**
- Decision: Fabric type determines wash programme (EligibilityDecision)
- Constraint: COSHH chemical handling (HardConstraint — NormativeRegion)
- Safety: Control structure — operator/machine/COSHH/HSE hierarchy
- Heuristic: High-temperature washes first (ordering Heuristic)
- Evidence/Claim: "COSHH requirements satisfied" — Claim with EvidenceLine (inventory, training)

**Deliverable:** Validation exercised as SPARQL-testable individuals or as a structured walkthrough document. The validation does not need to produce loaded OWL individuals for both domains — a structured analysis confirming that every reasoning class has a natural instantiation in both domains is sufficient. If time permits, create a small set of test individuals for one domain.

**Acceptance criteria:** Written analysis confirming cross-domain validation for Cafe and Suds. Every core reasoning class (ReasoningContext, Goal, Decision, Claim, Constraint, Heuristic) has at least one natural instantiation in each domain.

### Step 1.6: SPARQL validation suite extension [Code]

**Objective:** Extend `validate_kg.py` with a `Reasoning` query group covering the new ontology module.

**Queries to add:**
- Reasoning class hierarchy (all classes exist under declared parents)
- Reasoning property declarations (domain, range, characteristics)
- PROV-O alignment (dual subclassing verified)
- Evidence architecture chain (Claim → EvidenceLine → EvidenceItem structure)
- Constraint subtype completeness (Hard, Soft, Graded all present)
- Probabilistic component hierarchy

**Acceptance criteria:** All new queries pass. Full suite (existing + new) runs green.

### Step 1.7: Integration with governance vocabulary [Code]

**Objective:** Connect the reasoning vocabulary to the existing governance vocabulary (`ontara-gov:` namespace).

**Connections to establish:**
- `ontara-gov:DeonticObligation` as a subclass of (or aligned with) `ontara-rsn:HardConstraint` — governance obligations are hard constraints in the reasoning metamodel's terms
- Cross-reference between `ontara-gov:ComplianceStatus` and `ontara-rsn:Claim` — a compliance assessment is a Claim with evidence
- Governance cross-reference properties (from Stage 5 Phase 3) as constraints on governance-space trajectories

**Design question for this step:** Should `DeonticObligation` literally subclass `HardConstraint`, or should the alignment be via an object property (`isConstrainedBy`)? Subclassing is cleaner semantically but creates a cross-module dependency; property linking preserves module independence. Recommend discussing at implementation time.

**Acceptance criteria:** Governance–reasoning connection declared. HermiT CONSISTENT with combined stack. SPARQL query confirms the alignment.

### Phase 1 deliverables

1. `ontara-reasoning.ttl` — hand-authored OWL module with `ontara-rsn:` namespace
2. PROV-O core imported and aligned
3. Core reasoning class hierarchy (15–20 classes)
4. Evidence architecture (SEPIO pattern)
5. Structured probabilistic reasoning types
6. Cross-domain validation analysis (Cafe + Suds)
7. SPARQL validation queries (Reasoning group)
8. Governance vocabulary alignment

**Estimated effort:** 5–8 sessions. This is the largest phase — comparable to Stage 5 Phase 2 (ontology authoring + SPARQL validation + cross-domain validation). Step 1.2 (core classes) and Step 1.3 (evidence architecture) are the heaviest. Steps 1.1 and 1.6 are infrastructure. Step 1.5 is analysis. Steps 1.4 and 1.7 are extensions.

---

## 5. Phase 2 — Depth

**Objective:** Extend the reasoning vocabulary with heuristic packs, decision mode routing, and constraint satisfaction structures. Build on the abstract types from Phase 1.

**Prerequisite:** Phase 1 complete — core vocabulary authored, validated, cross-domain tested.

### Step 2.1: Heuristic pack architecture [Chat + Code]

Elaborate the abstract `Heuristic` type from Phase 1 into a typed hierarchy:
- Heuristic subtypes (ordering, resource allocation, risk prioritisation, escalation)
- HeuristicPack — collection of heuristics attachable to a domain, service line, or regulatory context
- Override machinery — overriding a heuristic is a ReasoningActivity with provenance
- Applicability conditions as OWL property restrictions

Heuristics as OWL individuals (S146-D6) with typed properties declaring applicability, ordering logic, and authority basis.

### Step 2.2: Decision mode routing [Chat + Code]

Elaborate ReasoningContext classification (S146-D5):
- Cynefin domain mapping (clear/complicated/complex/chaotic) as ClassificationRegion instances (S147-D2)
- Routing rules — which ReasoningComponents are activated for each domain
- Mode transition conditions — what causes a problem to be reclassified

### Step 2.3: Constraint satisfaction structures [Chat + Code]

Extend the three-way constraint distinction (S146-D8/S147-D3) with:
- Semiring properties for SoftConstraints (combination operators)
- Truth-value range for GradedRules
- Constraint composition rules (how multiple constraints interact)
- Connection to the weighted relationship model (B14) — constraint fields as weighted relationships read geometrically

### Step 2.4: Cross-domain validation (depth features) [Chat]

Validate heuristic packs, decision modes, and constraint structures against Cafe and Suds.

### Phase 2 deliverables

1. Heuristic type hierarchy and HeuristicPack structure in `ontara-reasoning.ttl`
2. Decision mode classification and routing in `ontara-reasoning.ttl`
3. Constraint satisfaction extensions in `ontara-reasoning.ttl`
4. Updated SPARQL queries
5. Cross-domain validation for depth features

**Estimated effort:** 3–5 sessions.

---

## 6. Phase 3 — Safety and Resilience

**Objective:** Provide STAMP/STPA and FRAM-ready architectural slots without committing to specific implementations (S146-Q7 resolved — FRAM-ready slots, no implementation commitment).

**Prerequisite:** Phase 2 complete.

### Step 3.1: STAMP/STPA structures [Chat + Code]

- Safety control structure (controller → controlled process → actuator → sensor loop)
- Control action types, unsafe control action classification
- Causal scenario modelling as coordinate-space trajectories near NormativeRegion boundaries (safety constraints)

### Step 3.2: FRAM-ready slots [Chat + Code]

- Function abstraction (input → output → control → precondition → resource → time)
- Variability modelling slots (internal/external, couplings)
- No FRAM execution engine — slots only, to be elaborated when needed

### Step 3.3: Safety–governance alignment [Chat + Code]

- Connect safety constraints to the governance vocabulary (DeonticObligation, SafetyConstraint as HardConstraint subtypes)
- Safety reporting as Claims with evidence trails

### Phase 3 deliverables

1. STAMP/STPA class hierarchy in `ontara-reasoning.ttl`
2. FRAM slot definitions
3. Safety–governance alignment
4. Updated SPARQL queries

**Estimated effort:** 2–4 sessions. This phase is deliberately bounded — slots, not implementations.

---

## 7. Phase 4 — Console Integration

**Objective:** Make reasoning vocabulary visible and navigable in the Ontara Console.

**Prerequisite:** Phase 3 complete (or at least Phase 1 — console work could begin once the core vocabulary is stable).

### Step 4.1: Reasoning explorer view [Chat + Code]

Console view showing the reasoning class hierarchy, relationships, and instances. Follows the existing pattern of KG Status, Governance, and Coverage views.

### Step 4.2: Evidence browser [Chat + Code]

Navigate Claim → EvidenceLine → EvidenceItem chains. Show provenance (which ReasoningActivity produced each Claim). Display confidence assessments with interpretive frames.

### Step 4.3: Decision trace visualisation [Chat + Code]

Visualise the reasoning path for a specific decision — the sequence of ReasoningActivities, knowledge sources consulted, constraints applied, and the resulting Decision with its evidence basis.

### Phase 4 deliverables

1. Reasoning explorer console view
2. Evidence browser console view
3. Decision trace visualisation

**Estimated effort:** 3–5 sessions. Console work is well-patterned from existing views.

---

## 8. Step Summary

| Step | Phase | Summary | Tool | Est. sessions |
|---|---|---|---|---|
| 0.1 | 0 | Update A12 concept note (Region taxonomy, constraint geometry) | Chat | <1 |
| 0.2 | 0 | Update B17 concept note (three-dimensional epistemic vocabulary) | Chat | <1 |
| 0.3 | 0 | Reformulate A6 principle note (T1 amendment) | Chat | <1 |
| 0.4 | 0 | Register new concepts (section P, B40–B46 → P-series) | Chat | 1 |
| 0.5 | 0 | Record all design decisions | Chat | <1 |
| 1.1 | 1 | PROV-O import and alignment | Code | 1 |
| 1.2 | 1 | Core reasoning classes | Code | 2 |
| 1.3 | 1 | Evidence architecture (SEPIO pattern) | Code | 1–2 |
| 1.4 | 1 | Structured probabilistic reasoning types | Code | 1 |
| 1.5 | 1 | Cross-domain validation (Cafe + Suds) | Chat + Code | 1 |
| 1.6 | 1 | SPARQL validation suite extension | Code | <1 |
| 1.7 | 1 | Integration with governance vocabulary | Code | 1 |
| 2.1 | 2 | Heuristic pack architecture | Chat + Code | 1–2 |
| 2.2 | 2 | Decision mode routing | Chat + Code | 1 |
| 2.3 | 2 | Constraint satisfaction structures | Chat + Code | 1 |
| 2.4 | 2 | Cross-domain validation (depth features) | Chat | <1 |
| 3.1 | 3 | STAMP/STPA structures | Chat + Code | 1–2 |
| 3.2 | 3 | FRAM-ready slots | Chat + Code | 1 |
| 3.3 | 3 | Safety–governance alignment | Chat + Code | <1 |
| 4.1 | 4 | Reasoning explorer view | Chat + Code | 1–2 |
| 4.2 | 4 | Evidence browser | Chat + Code | 1–2 |
| 4.3 | 4 | Decision trace visualisation | Chat + Code | 1–2 |

---

## 9. Design Decisions Implemented

### Session 147 decisions (Coordinate Framework Revisited)

| ID | Decision | Phase |
|---|---|---|
| S147-D1 | Three-dimensional epistemic vocabulary (provenance × purpose × confidence) | 0 (concept note), 1 (OWL) |
| S147-D2 | Region taxonomy (7 subtypes, extensible) | 0 (concept note), 1 (OWL) |
| S147-D3 | Constraint geometry (Hard = boundary, Soft = cost field, Graded = truth field; L9 = pathfinding) | 0 (concept note), 1 (OWL) |
| S147-D4 | BFO/PROV-O dual subclassing | 1 |
| S147-D5 | A6 reformulation (T1 amendment — structured probabilistic reasoning as new category) | 0 (principle note) |
| S147-D6 | Phase 0 before Phase 1 | Plan structure |
| S147-D7 | Comprehension–reasoning convergence (shared infrastructure) | 1 (architectural principle, not separate OWL) |

### Session 146 decisions (Institutionalised Reasoning)

| ID | Decision | Phase |
|---|---|---|
| S146-D1 | Reasoning metamodel as SMM extension (not third meta model) | 1 |
| S146-D2 | PROV-O as platform-level ontology import | 1 |
| S146-D3 | Separate OWL module `ontara-reasoning.ttl` with namespace `ontara-rsn:` | 1 |
| S146-D4 | Goal/Obstacle model uses coordinate space references (GoalRegion from S147-D2) | 1 |
| S146-D5 | Decision mode routing via ReasoningContext classification | 2 |
| S146-D6 | Heuristics as OWL individuals with typed properties | 2 |
| S146-D7 | Evidence architecture adopts SEPIO pattern (adapted, not imported) | 1 |
| S146-D8 | Three-way constraint distinction (hard, soft, graded) | 1 (types), 2 (depth) |

### Additional resolution

| ID | Resolution |
|---|---|
| S146-Q4 | Namespace: `ontara-rsn:`. Register section: P. |
| S146-Q5 | Start with abstract types; hierarchy emerges through use (J12). |
| S146-Q7 | FRAM-ready slots, no implementation commitment. Phase 3 concern. |
| S147-Q1 | Region taxonomy declared extensible from the outset. |
| S147-Q3 | A6 reformulation is a genuine T1 amendment — Ella's decision. |

---

## 10. Success Criteria

### Phase 0

| # | Criterion |
|---|---|
| P0-1 | A12 concept note updated with Region taxonomy and constraint geometry |
| P0-2 | B17 concept note updated with three-dimensional epistemic vocabulary |
| P0-3 | A6 principle note rewritten (T1 amendment) with four-category scheme |
| P0-4 | Section P created in master register with seven concepts registered |
| P0-5 | B19 updated to note PROV-O addition |
| P0-6 | All fifteen design decisions recorded |

### Phase 1

| # | Criterion |
|---|---|
| P1-1 | `ontara-reasoning.ttl` exists in `ontology/reasoning/` with `ontara-rsn:` namespace |
| P1-2 | PROV-O core imported; dual subclassing declared (S147-D4) |
| P1-3 | Core reasoning class hierarchy declared (≥15 classes); HermiT CONSISTENT |
| P1-4 | Evidence architecture (Claim → EvidenceLine → EvidenceItem) with ConfidenceAssessment |
| P1-5 | Structured probabilistic types (BayesianUpdater, RiskCalculator, PrognosticModel, PredictiveAnalytics) |
| P1-6 | Cross-domain validation analysis for Cafe and Suds — every core class has natural instantiation |
| P1-7 | SPARQL validation queries for Reasoning group; full suite green |
| P1-8 | Governance vocabulary alignment established |

### Phase 2

| # | Criterion |
|---|---|
| P2-1 | Heuristic type hierarchy and HeuristicPack structure declared |
| P2-2 | Decision mode classification and routing declared |
| P2-3 | Constraint satisfaction extensions (semiring, truth-value, composition) |
| P2-4 | Cross-domain validation for depth features |

### Phase 3

| # | Criterion |
|---|---|
| P3-1 | STAMP/STPA class hierarchy declared |
| P3-2 | FRAM slot definitions present |
| P3-3 | Safety–governance alignment established |

### Phase 4

| # | Criterion |
|---|---|
| P4-1 | Reasoning explorer console view operational |
| P4-2 | Evidence browser console view operational |
| P4-3 | Decision trace visualisation operational |

---

## 11. Session Estimate

| Phase | Sessions | Cumulative |
|---|---|---|
| Phase 0 — Coordinate consolidation | 2–3 | 2–3 |
| Phase 1 — Reasoning foundation | 5–8 | 7–11 |
| Phase 2 — Depth | 3–5 | 10–16 |
| Phase 3 — Safety and resilience | 2–4 | 12–20 |
| Phase 4 — Console integration | 3–5 | 15–25 |

**Total: 15–25 sessions.**

This is substantially larger than Stage 5 (~15 sessions total across four phases) and Stage 6 (~8 sessions across two phases), reflecting the architectural significance of the reasoning metamodel. The estimate follows the pattern of Phase 2 being the heaviest in Stage 5, with Phase 1 being the heaviest here.

The range is wide because Phases 2–4 depend on design decisions that will emerge during Phase 1. The coordinate framework revisited paper and the reasoning metamodel paper together represent the most architecturally ambitious work the project has attempted — two independent lines of inquiry converging into a single implementation. Discovery during Phase 1 may contract or expand the later phases.

---

## 12. Register Connections

### Tier 1 principles engaged

| Principle | How engaged |
|---|---|
| [[principle-deterministic-over-probabilistic\|A6]] | Reformulated as T1 amendment (Phase 0). Four-category scheme implemented (Phase 1). |
| [[principle-self-describing-system\|A2]] | Evidence/explanation architecture makes reasoning self-describing |
| [[principle-clinical-governance-first-class\|A8]] | Governance vocabulary connected to reasoning metamodel |
| [[principle-discipline-as-load-bearing-structure\|A9]] | SPARQL suite extension, cross-domain validation |
| [[principle-intrinsic-self-knowledge\|A10]] | Extended to reasoning system itself via evidence trajectories |
| [[principle-unity-principle\|A11]] | Empirically validated by comprehension–reasoning convergence (S147-D7) |
| [[concept-coordinate-framework\|A12]] | Enriched with Region taxonomy, constraint geometry, epistemic vocabulary |
| [[concept-cross-domain-validation\|J1]] | Cafe and Suds cross-domain validation |
| [[concept-co-evolution\|J2]] | OWL vocabulary + console views co-evolve |
| [[concept-non-constraining\|J3]] | Abstract types, extensible taxonomy, FRAM-ready slots without commitment |

### Tier 2 concepts exercised

| Concept | How exercised |
|---|---|
| [[concept-epistemic-modality\|B17]] | Three-dimensional reconciliation |
| [[concept-weighted-relationships\|B14]] | Reinterpretation as constraint geometry fields |
| [[concept-ontology-stack\|B19]] | PROV-O addition |
| [[concept-authority-zones\|B29]] | OWL authority for class structure; runtime authority for computational semantics |
| [[concept-dual-stack-architecture\|B21]] | Reasoning as SMM extension with horizontal mappings to BMM goals |
| [[concept-goal-seeking-computation\|L9]] | Becomes pathfinding through constrained coordinate space |
| [[concept-coordinate-space-snapshots\|L8]] | Confirmed as functional-purpose dimension of epistemic vocabulary |
| [[concept-five-layer-self-knowledge\|C6]] | Recognised as first implementation of coordinate-space reasoning |
| B30–B35 | Governance obligations as HardConstraints defining NormativeRegions |

### New concepts (section P)

B40–B46 (provisional codes) → P-series codes assigned at Phase 0 Step 0.4.

---

## 13. Risks and Mitigations

| # | Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| R1 | PROV-O import introduces OWL 2 DL expressivity conflicts with existing stack | Low | High | PROV-O is OWL 2 DL compatible. Test with HermiT immediately at Step 1.1. If issues arise, use a reduced PROV-O import (core classes only, no complex axioms). |
| R2 | Reasoning class hierarchy grows beyond maintainability | Medium | Medium | S146-Q5 resolution: start with abstract types. J12 (design decision lifecycle) governs elaboration. Phase 2 depth features should be added only where cross-domain validation demonstrates need. |
| R3 | Governance–reasoning alignment creates circular imports between `ontara-gov:` and `ontara-rsn:` modules | Medium | Medium | Design the alignment as unidirectional: `ontara-rsn:` imports `ontara-gov:` (reasoning knows about governance), not vice versa. If bidirectional references are needed, use a shared upper module or indirect alignment via BFO superclasses. |
| R4 | Phase 0 concept note updates propagate inconsistencies to other documents | Low | Medium | Phase 0 updates are limited to A12, B17, A6, B19, and new section P. Each update is self-contained. The strategic snapshot refresh (due ~S152) will propagate changes more broadly. |
| R5 | Cross-domain validation reveals that the reasoning vocabulary is too abstract for natural instantiation | Medium | High | This is exactly what cross-domain validation is designed to catch. If Cafe and Suds cannot naturally instantiate reasoning classes, the classes need revision before proceeding. Phase 1 Step 1.5 is explicitly positioned to be a gate — proceed only if validation succeeds. |
| R6 | Stage 7 scope creep — temptation to implement runtime reasoning engines | Medium | High | Explicit scope boundary (§2): Stage 7 produces OWL vocabulary and SysML structures. Runtime engines are deployment-time concerns. The authority zones distinction (B29) is the architectural firewall. |
| R7 | A6 reformulation creates confusion about what clinical decisions the platform will support | Low | High | The reformulation is precisely worded (§10 of the coordinate framework revisited paper). The four-category scheme is explicit about boundaries. The principle note rewrite (Phase 0 Step 0.3) must be clear and self-contained. |

---

## 14. Coordinate Framework Standing Instruction

Per Ella's standing instruction (Session 147): **the [[ontara-discussion-coordinate-framework-revisited-2026-04-05|coordinate framework revisited paper]] should be actively considered for its relevance with every significant piece of work undertaken during Stage 7.**

This instruction is architecturally load-bearing. The coordinate framework revisited paper is not background reading — it is the consolidation document that establishes the coherence of the coordinate framework, reasoning metamodel, comprehension architecture, governance vocabulary, and ontological grounding. Every Phase 1 OWL class should be checkable against this paper: does the class respect the Region taxonomy? Does it use the three-dimensional epistemic vocabulary correctly? Does it maintain the constraint geometry interpretation? Is the BFO/PROV-O alignment consistent?

---

*Plan produced Session 148, 5 April 2026. Covers the full Stage 7 implementation of the reasoning metamodel across five phases (0–4). All fifteen design decisions from Sessions 146–147 confirmed. Work item W-026.*
