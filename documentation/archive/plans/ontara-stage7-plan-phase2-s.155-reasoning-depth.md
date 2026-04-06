---
tags:
  - plan
  - ontology
  - reasoning
date: 2026-04-06
status: active
session: 155
---
# Stage 7 Phase 2 — Detailed Implementation Plan: Reasoning Depth

**Session:** 155
**Date:** 6 April 2026
**Purpose:** Detailed implementation plan for Phase 2 of the reasoning metamodel. Extends the 26-class Phase 1 vocabulary with heuristic packs, decision mode routing, and constraint satisfaction structures.
**Status:** Active plan.
**Depends on:** [[ontara-stage7-plan-high-level-s.148-reasoning-metamodel|Stage 7 Plan §5 (Phase 2 outline)]], [[ontara-discussion-institutionalised-reasoning-2026-04-05|Institutionalised Reasoning (Session 146) §§6–7, 11]], [[ontara-discussion-coordinate-framework-revisited-2026-04-05|The Coordinate Framework Revisited (Session 147) §§6–7]], [[ontara-research-(perplexity) - reasoning-problem-solving-heuristics|Perplexity Research: Reasoning, Problem Solving, and Heuristics]]
**Phase 1 closure:** Session 152. 26 classes, 15 object properties, 4 datatype properties, 3 named individuals. 12-file stack, 43/43 SPARQL, HermiT CONSISTENT. Phase 1 closure note in the Stage 7 plan.
**Work item:** W-026 (Stage 7 implementation — continuing)

---

## Contents

- [[#1. Objective and Scope|§1. Objective and Scope]]
- [[#2. What Phase 1 Leaves Us|§2. What Phase 1 Leaves Us]]
- [[#3. Design Decisions (Agreed Session 155)|§3. Design Decisions (Agreed Session 155)]]
- [[#4. Implementation Steps|§4. Implementation Steps]]
- [[#5. Success Criteria|§5. Success Criteria]]
- [[#6. Session Estimate|§6. Session Estimate]]
- [[#7. Register Connections|§7. Register Connections]]
- [[#8. Coordinate Framework Conformity Check|§8. Coordinate Framework Conformity Check]]

---

## 1. Objective and Scope

Phase 2 extends the reasoning vocabulary (`ontara-reasoning.ttl`) with three depth features that Phase 1 deliberately left as abstract stubs:

1. **Heuristic pack architecture** — elaborate the `Heuristic` class into a typed hierarchy with `HeuristicPack` grouping, override machinery, and applicability conditions.
2. **Decision mode routing** — elaborate the `DecisionMode` class with Cynefin domain individuals, component activation properties, and mode transition conditions.
3. **Constraint satisfaction structures** — extend `SoftConstraint` and `GradedRule` with algebraic combination properties (semiring for costs, convex optimisation for truth values), and constraint composition rules.

Phase 2 does **not** add new top-level classes to the reasoning metamodel. It deepens existing stubs. The class count will grow (new subclasses of Heuristic, new named individuals for DecisionMode and CombinationAlgebra), but the core architecture established in Phase 1 is unchanged.

### What is out of scope

- New domain-specific heuristic *content* (specific Cafe, Suds, or GSL heuristics as OWL individuals). Phase 2 defines the type hierarchy; content population is downstream work.
- Runtime decision mode routing *engines*. Per B29: OWL is authoritative for class structure; runtime engines implement computational semantics.
- Changes to the evidence architecture (Phase 1 Section 5–6). Stable and complete.
- Changes to the governance alignment (Phase 1 Section 9). Stable and complete.

---

## 2. What Phase 1 Leaves Us

Four Phase 1 classes have explicit "Phase 2 will elaborate" markers in their rdfs:comment:

| Class | Phase 1 state | Phase 2 elaboration needed |
|---|---|---|
| `Heuristic` | Single class, subclass of `KnowledgeSource` | Subtype hierarchy (6 families), HeuristicPack container, override properties, applicability conditions |
| `DecisionMode` | Minimal class, subclass of `IAO_0000030` | Cynefin domain individuals, component activation routing, mode transition properties |
| `SoftConstraint` | Subclass of `Constraint` with geometry description | Semiring combination algebra, composition rules |
| `GradedRule` | Subclass of `Constraint` with truth-value description | Truth-value combination semantics, composition with SoftConstraints |

Additionally, `hasDecisionMode` is declared as a functional property linking `ReasoningContext` to `DecisionMode`, ready for the Phase 2 elaboration.

### Phase 1 infrastructure reused by Phase 2

- `ReasoningContext` — gains routing properties connecting it to activated components via DecisionMode
- `ReasoningComponent` — the abstract type that heuristic packs and decision mode routing activate
- `ReasoningActivity` with PROV-O provenance — heuristic overrides are ReasoningActivities
- `InterpretiveFrame` pattern (3 named individuals) — the model for CombinationAlgebra individuals
- `hasConstraint` property — already links ReasoningContext to Constraint; composition rules extend what happens when multiple constraints are present

---

## 3. Design Decisions (Agreed Session 155)

| ID | Decision | Rationale |
|---|---|---|
| S155-D1 | All six heuristic families defined as subclasses | Well-motivated by research paper §Heuristics layer. Cheap to declare, provides a typed palette. Cross-domain validation (Step 2.4) will reveal which need further elaboration. |
| S155-D2 | HeuristicPack is an OWL class | First-class entity with its own provenance (who assembled, when, for what domain). Supports versioning and override tracking. Parallels established patterns. |
| S155-D3 | Combination algebras as named individuals | Follows the InterpretiveFrame pattern from Phase 1 (class + named individuals). CombinationAlgebra class with MinPlusSemiring, MaxTimesSemiring, extensible for future algebras. Consistent with J3. |
| S155-D4 | Steps 2.1–2.3 implemented in a single Code session | The three workstreams are OWL-independent at class level. Combined implementation is more efficient. Step 2.4 (cross-domain validation) follows as a separate Chat analysis. |

---

## 4. Implementation Steps

### Step 2.1: Heuristic Pack Architecture [Code]

**Objective:** Elaborate the abstract `Heuristic` class into a typed hierarchy with HeuristicPack grouping and override machinery.

**Classes to define:**

*Heuristic subtype hierarchy (6 families from reasoning paper §7.3 and research paper §Heuristics layer):*

- `ontara-rsn:GoalOrderingHeuristic` — do prerequisite, high-risk, irreversible, or high-information-gain tasks first. Coordinate-framework interpretation: prioritise movement along axes with highest goal-region proximity gradient.
- `ontara-rsn:ResourceHeuristic` — prefer scarce-resource preservation, continuity-preserving allocations, local-capacity balancing. Coordinate-framework interpretation: minimise rate of change in resource-axis dimensions.
- `ontara-rsn:RiskHeuristic` — escalate on red-flag combinations, uncertainty plus severity, vulnerable-population markers. Coordinate-framework interpretation: increase monitoring density near NormativeRegion boundaries.
- `ontara-rsn:DiagnosticHeuristic` — generate hypotheses broadly, prune using discriminating evidence. Coordinate-framework interpretation: maximise information gain per reasoning step.
- `ontara-rsn:CoordinationHeuristic` — minimise handoff count, maximise accountability continuity, prefer known competent teams. Coordinate-framework interpretation: minimise discontinuity in agent-assignment dimensions.
- `ontara-rsn:GovernanceHeuristic` — require human review when confidence is low, novelty is high, explanation is weak, or downstream risk is material. Coordinate-framework interpretation: escalate when position is near FormalisationFrontier or NormativeRegion boundary.

All six are subclasses of `ontara-rsn:Heuristic`. Each carries rdfs:comment with the coordinate-framework geometric interpretation per §7.4 of the coordinate framework revisited paper.

*HeuristicPack:*

- `ontara-rsn:HeuristicPack` — a collection of heuristics applicable to a domain, service line, or regulatory context. Subclass of `bfo:IAO_0000030` (information content entity — a specification of which heuristics apply). A HeuristicPack is a versionable, provenance-bearing entity: who assembled it, when, for what purpose.

**Properties to define:**

- `ontara-rsn:hasMember` — links HeuristicPack to Heuristic(s). Note: distinct from `ontara-rsn:hasEvidence` which links EvidenceLine to EvidenceItem.
- `ontara-rsn:applicableToDomain` — links Heuristic or HeuristicPack to `ontara-dom:DomainIdentity` (from the domain identity vocabulary, Session 144).
- `ontara-rsn:applicableToContext` — links Heuristic to ReasoningContext (which contexts activate this heuristic).
- `ontara-rsn:overrides` — links a Heuristic to the Heuristic it overrides. An override is itself a provenance-traceable act: the overriding Heuristic exists as a replacement, and the override event is recorded as a ReasoningActivity via PROV-O (the override *prov:wasGeneratedBy* the ReasoningActivity that decided to override).
- `ontara-rsn:hasAuthorityBasis` — links Heuristic to KnowledgeSource (what authority justifies this heuristic). Reuses the KnowledgeSource class from Phase 1.
- `ontara-rsn:hasOrderingLogic` — datatype property (xsd:string) describing the ordering or selection logic of the heuristic in natural language. Structured ordering logic is a candidate for future elaboration.

**Acceptance criteria:**
- 6 Heuristic subclasses declared with labels, comments, parent class, and coordinate-framework interpretation
- HeuristicPack class declared
- All properties declared with domain, range, and comments
- HermiT CONSISTENT with full stack

### Step 2.2: Decision Mode Routing [Code]

**Objective:** Elaborate the `DecisionMode` class with Cynefin domain individuals and component activation properties.

**Named individuals (4 Cynefin domains as DecisionMode instances):**

- `ontara-rsn:ClearMode` — deterministic rules, checklists, eligibility logic. Activates Tier 1 reasoning components. In coordinate-framework terms: the entity's position in the coordinate space is within a well-mapped ClassificationRegion where deterministic paths exist.
- `ontara-rsn:ComplicatedMode` — expert analysis, model-based trade-off, optimisation, simulation. Activates Tier 1 + Tier 2 reasoning components, possibly with structured probabilistic support. Coordinate-framework: the ClassificationRegion requires analysis but admits tractable solutions.
- `ontara-rsn:ComplexMode` — probe-sense-respond, hypothesis portfolios, adaptive monitoring, learning loops. Activates exploratory reasoning with Tier 1 safety constraints as hard guards. Coordinate-framework: the position is near or beyond the FormalisationFrontier.
- `ontara-rsn:ChaoticMode` — emergency stabilisation, hard safety constraints, rapid escalation. Activates only hard constraint enforcement and escalation. Coordinate-framework: the position has crossed a NormativeRegion boundary or is in crisis.

**Properties to define:**

- `ontara-rsn:activatesComponent` — links DecisionMode to ReasoningComponent (which component types are activated in this mode). This is the routing mechanism: the platform queries the DecisionMode, retrieves activated components, and makes them available to the ReasoningActivity.
- `ontara-rsn:transitionsTo` — links DecisionMode to DecisionMode with a condition. Mode transition is itself a ReasoningActivity (recognising that the problem character has changed). The condition is a descriptive string for now; structured transition conditions are a candidate for future elaboration.
- `ontara-rsn:hasTransitionCondition` — datatype property (xsd:string) on a reified transition, or annotation on `transitionsTo`. For simplicity, we will annotate the `transitionsTo` assertions with rdfs:comment describing the condition. If a reified transition class is needed later, J3 preserves that path.

**Acceptance criteria:**
- 4 DecisionMode named individuals declared with labels, comments, and coordinate-framework interpretation
- `activatesComponent` property declared with domain DecisionMode, range ReasoningComponent
- `transitionsTo` property declared with domain DecisionMode, range DecisionMode
- HermiT CONSISTENT with full stack

### Step 2.3: Constraint Satisfaction Structures [Code]

**Objective:** Extend SoftConstraint and GradedRule with algebraic combination properties and constraint composition rules.

**Classes to define:**

- `ontara-rsn:CombinationAlgebra` — the algebraic structure governing how constraint values combine. Subclass of `bfo:IAO_0000030` (information content entity — a specification of combination semantics). Parallels InterpretiveFrame.

**Named individuals (CombinationAlgebra instances):**

- `ontara-rsn:MinPlusSemiring` — cost semiring: combine via addition (total cost), select via minimum (cheapest option). The standard algebra for SoftConstraint cost surfaces. From the probabilistic reasoning research.
- `ontara-rsn:MaxTimesSemiring` — preference semiring: combine via multiplication (joint preference), select via maximum (most preferred option). An alternative algebra for SoftConstraint preference surfaces.
- `ontara-rsn:FuzzyMinMax` — fuzzy logic combination: combine via min (conjunction) or max (disjunction). Standard fuzzy operators for GradedRule truth-value surfaces.
- `ontara-rsn:PSLConvexOptimisation` — Probabilistic Soft Logic combination: graded rules combine via convex optimisation to find the most probable truth-value assignment. The standard algebra for GradedRule composition from the probabilistic reasoning research.

**Properties to define:**

- `ontara-rsn:hasCombinationAlgebra` — links SoftConstraint or GradedRule to CombinationAlgebra (which algebraic structure governs combination). Functional property — each constraint has exactly one combination algebra.
- `ontara-rsn:hasIdentityElement` — datatype property (xsd:decimal) on CombinationAlgebra. For MinPlusSemiring: 0 (adding zero cost changes nothing). For MaxTimesSemiring: 1 (multiplying by 1 changes nothing). For FuzzyMinMax: 1 (min with 1 is identity for conjunction). For PSLConvexOptimisation: not applicable (no scalar identity — annotated as such).
- `ontara-rsn:composedWith` — links Constraint to Constraint, expressing that two constraints interact and should be evaluated together. Symmetric property. When two constraints are composed, their CombinationAlgebras must be compatible (same algebra or declared interoperable). Compatibility checking is a runtime concern; OWL declares the relationship.
- `ontara-rsn:hasPriority` — datatype property (xsd:integer) on Constraint, expressing relative priority when constraints conflict. Higher priority wins. This is a pragmatic property for constraint relaxation — when the constraint space is infeasible, lower-priority SoftConstraints are relaxed first. HardConstraints are never relaxed (their priority is effectively infinite, but this is enforced by B29 and the governance alignment, not by this property).
- `ontara-rsn:hasTruthValueRange` — datatype property (xsd:string) on GradedRule, documenting the truth-value range. Typically "[0,1]" but documented explicitly for clarity. Structured range representation is a candidate for future elaboration.

**Connection to weighted relationships (B14) and the unity principle (A11):**

The coordinate framework revisited paper §7.2 establishes that constraint fields are the weighted relationship model read geometrically. This Phase 2 step makes that connection structural: a SoftConstraint with MinPlusSemiring is a cost reading of the weighted relationships; a GradedRule with PSLConvexOptimisation is a truth-value reading. The CombinationAlgebra determines which mathematical operation is applied to the same underlying weights. A11 is preserved because the weights are shared — only the reading varies.

This connection is documented in rdfs:comments on the relevant classes and properties but is not enforced as an OWL axiom. The connection between `ontara-rsn:` constraint fields and `ontara-bmm-weights:` weighted relationship individuals is a semantic alignment, not a subclass relationship. Making it structural would require the reasoning module to import the BMM weights module, which would create an unnecessary coupling.

**Acceptance criteria:**
- CombinationAlgebra class declared
- 4 CombinationAlgebra named individuals declared with labels and comments
- All properties declared with domain, range, and comments
- hasCombinationAlgebra declared as functional
- composedWith declared as symmetric (owl:SymmetricProperty)
- HermiT CONSISTENT with full stack

### Step 2.4: Cross-Domain Validation (Depth Features) [Chat]

**Objective:** Validate heuristic packs, decision modes, and constraint structures against Cafe and Suds, per A5/J1.

**Cafe validation:**

| Depth feature | Cafe exercise |
|---|---|
| GoalOrderingHeuristic | Prioritise rush orders over standard (high-urgency tasks first) |
| ResourceHeuristic | Prefer same-barista continuity (continuity-preserving allocation) |
| CoordinationHeuristic | Minimise drink handoffs between baristas |
| HeuristicPack | "Cafe Standard Operations" pack grouping the above three |
| ClearMode | Standard order processing — deterministic rules |
| ComplicatedMode | Peak-hour scheduling — trade-off analysis for barista allocation |
| SoftConstraint + MinPlusSemiring | Staff scheduling cost surface (overtime cost, travel cost) |
| GradedRule + FuzzyMinMax | "Customer likely to add items" — graded rule for upselling prompts (degree of applicability) |

**Suds validation:**

| Depth feature | Suds exercise |
|---|---|
| GoalOrderingHeuristic | High-temperature washes first (energy efficiency ordering) |
| RiskHeuristic | Escalate when COSHH chemical combination is flagged (red-flag combination) |
| GovernanceHeuristic | Require human review for unfamiliar fabric types (novelty is high) |
| HeuristicPack | "Suds COSHH-Aware Operations" pack grouping governance and risk heuristics |
| ClearMode | Standard wash programme selection — rule-based eligibility |
| ChaoticMode | Chemical spill response — hard safety constraints only |
| SoftConstraint + MaxTimesSemiring | Wash ordering preference (prefer energy-efficient sequences) |
| GradedRule + PSLConvexOptimisation | "Fabric suitability for programme" — graded truth value based on fabric type, weight, and soiling |

**Deliverable:** Written analysis confirming cross-domain validation. Every depth feature (6 heuristic subtypes, HeuristicPack, 4 DecisionMode individuals, CombinationAlgebra, composedWith, hasPriority) has at least one natural instantiation across Cafe and Suds. The validation does not produce loaded OWL individuals — it is a structured walkthrough confirming the vocabulary's adequacy.

**Acceptance criteria:**
- Every new class, individual, and property has at least one natural instantiation in each of Cafe and Suds
- Any class that cannot find a natural instantiation is flagged for review

### Step 2.5: SPARQL Validation Suite Extension [Code]

**Objective:** Extend `validate_kg.py` with queries covering the Phase 2 additions.

**Queries to add (Reasoning group extension):**

- Heuristic subclass hierarchy (all 6 subtypes present under Heuristic)
- HeuristicPack class exists with hasMember property
- DecisionMode named individuals (4 Cynefin domains exist)
- activatesComponent property declaration (domain DecisionMode, range ReasoningComponent)
- CombinationAlgebra named individuals (4 algebras exist)
- hasCombinationAlgebra property declaration (domain Constraint subtypes, range CombinationAlgebra, functional)
- composedWith property is symmetric
- Phase 2 class count verification (Phase 1: 26 classes + Phase 2 additions)

**Acceptance criteria:**
- All new queries pass
- Full suite (43 existing + new) runs green

---

## 5. Success Criteria

| # | Criterion | Traces to |
|---|---|---|
| P2-1 | 6 Heuristic subclasses declared (GoalOrdering, Resource, Risk, Diagnostic, Coordination, Governance) | Stage 7 plan §5 Step 2.1, S146 §7.3 |
| P2-2 | HeuristicPack class declared with hasMember, applicableToDomain, and provenance properties | Stage 7 plan §5 Step 2.1, S155-D2 |
| P2-3 | Override machinery: overrides property + authority basis | S146 §7.4 |
| P2-4 | 4 DecisionMode named individuals (Clear, Complicated, Complex, Chaotic) | Stage 7 plan §5 Step 2.2, S146-D5 |
| P2-5 | activatesComponent property linking DecisionMode to ReasoningComponent | S146 §6.3 |
| P2-6 | transitionsTo property with transition conditions | S146 §6 |
| P2-7 | CombinationAlgebra class with 4 named individuals (MinPlus, MaxTimes, FuzzyMinMax, PSLConvex) | Stage 7 plan §5 Step 2.3, S155-D3 |
| P2-8 | hasCombinationAlgebra, composedWith, hasPriority properties declared | Stage 7 plan §5 Step 2.3 |
| P2-9 | Cross-domain validation — every depth feature instantiated in Cafe and Suds | A5/J1 |
| P2-10 | SPARQL suite extended and fully green | A9 |
| P2-11 | HermiT CONSISTENT with full 12-file stack | Standing requirement |

---

## 6. Session Estimate

| Step | Sessions | Tool |
|---|---|---|
| 2.1–2.3 combined | 1 | Code |
| 2.4 cross-domain validation | <1 | Chat |
| 2.5 SPARQL extension | <1 | Code (can combine with 2.1–2.3) |

**Total: 1–2 sessions** (at the low end of the Stage 7 plan's 3–5 estimate for Phase 2). This is achievable because: (a) the design decisions are pre-agreed (S155-D1 to D4), (b) the three workstreams are OWL-independent and can be authored in a single pass, (c) the Phase 1 infrastructure (properties, patterns, BFO grounding) is stable and well-understood, and (d) no new architectural decisions are required — only elaboration of established stubs.

---

## 7. Register Connections

### Tier 1 principles engaged

| Principle | How engaged |
|---|---|
| [[principle-deterministic-over-probabilistic\|A6]] (Deterministic/auditable reasoning) | Decision mode routing makes the four-category scheme (S147-D5) structurally selectable |
| [[principle-discipline-as-load-bearing-structure\|A9]] (Discipline) | SPARQL suite extension, cross-domain validation |
| [[principle-unity-principle\|A11]] (Unity principle) | Constraint satisfaction structures explicitly connect to [[concept-weighted-relationships\|weighted relationships]] as geometric readings of the same model |
| [[concept-coordinate-framework\|A12]] (Coordinate framework) | All heuristic subtypes carry coordinate-framework geometric interpretations; DecisionMode individuals reference ClassificationRegions |
| [[concept-multi-tenancy\|A13]] (Multi-tenancy) | HeuristicPack.applicableToDomain links to [[concept-domain-identity\|domain identity (B15)]], supporting per-tenant heuristic configuration |
| [[concept-cross-domain-validation\|J1]] (Cross-domain validation) | Step 2.4 validates in [[domain-cafe\|Cafe]] and [[domain-suds\|Suds]] |
| [[concept-co-evolution\|J2]] (Co-evolution) | OWL depth features co-evolve with future console views (Phase 4) |
| [[concept-non-constraining\|J3]] (Non-constraining) | CombinationAlgebra extensible; DecisionMode transition conditions descriptive; heuristic ordering logic as string |

### Tier 2 concepts exercised

| Concept | How exercised |
|---|---|
| P3 (Decision mode routing) | Fully elaborated — 4 individuals, activation routing, transitions |
| P4 (Heuristic layer) | Fully elaborated — 6 subtypes, HeuristicPack, override machinery |
| [[concept-weighted-relationships\|B14]] (Weighted relationships) | Connected to constraint fields via CombinationAlgebra ([[principle-unity-principle\|A11]] geometric reading) |
| [[concept-domain-identity\|B15]] (Domain identity) | HeuristicPack.applicableToDomain references DomainIdentity vocabulary |
| [[concept-authority-zones\|B29]] (Authority zones) | OWL authoritative for class structure; runtime authoritative for constraint solver execution |

---

## 8. Coordinate Framework Conformity Check

Per the standing instruction (Session 147): every significant piece of Phase 2 work is checked against the coordinate framework revisited paper.

| Phase 2 element | Coordinate framework conformity |
|---|---|
| 6 Heuristic subtypes | Each carries a geometric interpretation per §7.4 (heuristics as navigation strategies in coordinate space). GoalOrderingHeuristic = gradient priority. ResourceHeuristic = rate-of-change minimisation. RiskHeuristic = boundary proximity monitoring. DiagnosticHeuristic = information gain maximisation. CoordinationHeuristic = discontinuity minimisation. GovernanceHeuristic = frontier/boundary proximity escalation. |
| HeuristicPack | A named, provenance-bearing collection of navigation strategies. Consistent with §7.4's description of composable, overrideable heuristics. |
| DecisionMode individuals | Map to ClassificationRegion instances per §6.2. Clear = well-mapped region. Complicated = tractable but analysis-requiring region. Complex = near/beyond FormalisationFrontier. Chaotic = NormativeRegion boundary violation or crisis. |
| CombinationAlgebra | Directly implements §7.1's constraint geometry: MinPlusSemiring for cost surfaces (SoftConstraint), FuzzyMinMax/PSLConvex for truth-value surfaces (GradedRule). The algebra determines the mathematical reading of the same underlying weighted relationship fields (§7.2, A11). |
| composedWith | Implements §7.3's pathfinding over multiple constraint fields simultaneously. Composition is the mechanism by which the system navigates through all constraint fields at once. |

No contradictions or ambiguities identified. The Phase 2 design is consistent with the coordinate framework and the unity principle.

---

*Plan produced Session 155, 6 April 2026. Covers Phase 2 of the Stage 7 reasoning metamodel. Design decisions S155-D1 to D4 agreed in session. Implementation combines Steps 2.1–2.3 into a single Code session for efficiency.*
