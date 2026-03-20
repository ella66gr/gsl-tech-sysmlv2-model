# Discussion Paper: Intrinsic Self-Knowledge and the Comprehension Architecture

**Date:** 20 March 2026 (Session 46)
**Extends:** [[ontara-discussion-comprehension-architecture-2026-03-19|Comprehension Architecture Discussion (Session 45)]]
**Arising from:** Session 46 discussion on the nature of system self-knowledge
**Type:** Architectural refinement — sharpens foundational concepts
**Status:** Working discussion document
**Related concepts:** [[concept-comprehension-layer|I14]], [[concept-five-layer-self-knowledge|C6]], F1–F6, [[principle-model-generates-everything|A3]], K (semantic vocabulary), L1–L4 (simulation)

---

## 1. What This Paper Adds

The Session 45 discussion paper identified three registers of comprehension and proposed that the system should generate explanations from its own model structure (Register 2), not just display authored labels (Register 1). This paper sharpens that insight into a stronger architectural principle and extends it in three new directions:

1. **Intrinsic self-knowledge.** The system's ability to explain itself is not a bolted-on presentation feature — it is an intrinsic property that arises from and varies dynamically with the system's own structure, function, relationships, and content.

2. **Connection to the inference/logic engine.** The comprehension layer should not only describe what exists but reason about what follows — implications, requirements, gaps, and conditional dependencies.

3. **Weighted relationships and a unified knowledge model.** Relationships between elements are characterised by strength of interaction effect. The weighted relationship model is not a comprehension-specific feature — it is foundational infrastructure shared by comprehension, reasoning, simulation, governance, and assembly guidance. One knowledge model, multiple applications.

---

## 2. Intrinsic Self-Knowledge: The Core Principle

### 2.1 The distinction

There is a fundamental difference between:

- **(a) Authored descriptions** — a human writes a text explanation of what something is, and the system stores and displays it. If the system changes, the description remains unchanged until someone notices and edits it.

- **(b) Intrinsic self-knowledge** — the system dynamically composes its own explanation from its live understanding of its own structure, function, relationships, and content. If the system changes, the explanation changes automatically and immediately, because it is a direct computation over the system's current state.

Both have value. There are things only a human can author well — purposive framing ("why should I care about this concept?"), design rationale ("why was this modelled this way?"), and strategic context ("how does this fit the bigger picture?"). These are Register 1 concerns and they are appropriately static and human-authored.

But the structural, factual, relational content of a comprehension response — what this element connects to, how many instances exist, what categories are available, what domains use it, what is implied by its presence — should be intrinsic. It should be a live computation, not a stored string.

### 2.2 The test

A simple test distinguishes authored from intrinsic content:

> *If the model changes and no human edits any description, does the explanation become wrong?*

If yes, that content should be intrinsic — generated dynamically from the model's current state. If no (because the content is purposive framing or design rationale that doesn't depend on structural specifics), it can be authored.

**Example — Activity Type:**

| Content | Authored or intrinsic? | Why |
|---|---|---|
| "Something your business does — an identifiable unit of work that the system holds, tracks, and uses." | Authored | Purposive framing. Doesn't depend on model structure. |
| "Every activity is an activity of one of the following types: service delivery, enabling, governance, development, or overhead." | **Intrinsic** | Depends on the current enum values of ActivityCategory. If a sixth category is added, this must change. |
| "The system uses activity types to plan resources, allocate costs, and verify governance requirements." | Authored | Design rationale. Describes the intended purpose, not the current state. |
| "Activity Type is used in all three demonstrator domains: Cafe (6 types), Suds (10 types), Paws (8 types)." | **Intrinsic** | Depends on the current domain instantiation counts. If Paws adds a new activity type, this must change. |
| "Related concepts: Activity Granularity, Activity Cost Allocation, Activity Budget." | **Intrinsic** | Depends on the current model relationships. If a new related concept is added, this must change. |

The authored content provides the frame. The intrinsic content fills it with live data. Together they produce a comprehension response that is both meaningful and accurate.

### 2.3 Implications for the metadata design

This distinction reshapes what the `@Comprehension` metadata should contain. It does not contain *explanations* — it contains *traversal instructions*: a schema that tells the comprehension engine how to assemble an explanation from the system's live knowledge.

For Activity Type, the comprehension metadata might declare:

- **Surface these enum values:** the values of the ActivityCategory enum
- **Count and list these domain instances:** all `part` usages typed by `ActivityType`, grouped by domain
- **Traverse these relationships:** ActivityGranularity, ActivityCostAllocation, ActivityBudget, ActivityRecord (the elements in the same package or that reference this element)
- **Show these attributes:** the attribute names and types on the `part def`

The generator reads the traversal instructions and the live model, and composes the explanation dynamically. The `@Comprehension` metadata is a recipe, not a script.

---

## 3. Connection to the Inference/Logic Engine

### 3.1 Beyond describing structure — reasoning about implications

Register 2 as described in the Session 45 paper was about *structural* self-knowledge: traversing the model graph to assemble descriptions. This session's discussion extends it to *inferential* self-knowledge: reasoning about what follows from the current model state.

The comprehension layer should be able to answer not just:

- "What is Activity Type?" (structural description)
- "What activity types exist in the Cafe domain?" (structural enumeration)

but also:

- "If I define a governance activity type, what else do I need?" (conditional implication)
- "I have defined activity types but no activity cost allocations — is that a gap?" (gap analysis)
- "If I change the granularity policy for governance activities from envelope to tracked, what else is affected?" (impact reasoning)

These are inferential questions. They require the comprehension engine to reason about the model, not just traverse it. This connects directly to the existing architecture:

| Layer | Connection |
|---|---|
| F1 (SystemStateAssessment) | The comprehension engine uses the same five-layer assessment machinery to evaluate the model's current state |
| F2 (Evaluation invocation pattern) | Comprehension queries invoke the same evaluation pipeline: identify relevant constraints, resolve inputs, evaluate, produce structured result |
| F4 (Three remediation categories) | Comprehension responses can classify implications as: automatic (the system will handle this), recommended (you should do this), advisory (consider this) |
| F6 (Tau Prolog / Tier 2 reasoning) | Compound reasoning — "if A and B then C" — uses the logic engine. Comprehension queries that involve conditional implications are Tier 2 queries |

### 3.2 The comprehension engine is the self-knowledge architecture applied

The comprehension engine is not a separate system — it is the self-knowledge architecture ([[concept-five-layer-self-knowledge|C6]]) applied to the user-facing surface. The five layers of C6 map directly:

| C6 Layer | Comprehension application |
|---|---|
| GoalProjector | What should a complete, well-formed model look like? What are the expected elements? |
| OperationalStateAggregator | What does the model currently contain? What is the coverage, the instantiation status, the relationship graph? |
| GapAnalyser | What is missing? What is incomplete? What is implied but not yet defined? |
| ExplanationTrace | Why is this gap identified? What relationships and rules led to this conclusion? |
| Remediation | What should the user do about it? Define this element, add this relationship, consider this option. |

This is the same machinery, applied to a different question. C6 was designed for operational self-assessment ("is my system healthy?"). The comprehension layer applies it to model-building self-assessment ("is my model complete and coherent?").

---

## 4. Weighted Relationships and the Unified Knowledge Model

### 4.1 Not all connections are equal

The current model expresses relationships as binary: either two elements are related or they are not. The PatternCatalogue uses typed predicates (dependsOn, enables, motivatedBy, etc.) which distinguish the *kind* of relationship but not its *strength*.

In reality, relationships between elements vary in strength of interaction effect:

- **Strong coupling:** Activity Type → Activity Cost Allocation. Every costing decision depends on knowing the activity type. A change to activity types directly and significantly affects cost allocation.
- **Moderate coupling:** Activity Type → Resource Type. Activities consume resources, and resource planning depends on the activity mix. But the relationship is mediated — a change to activity types affects resource planning, but indirectly.
- **Weak coupling:** Activity Type → Channel. There is a real but distant relationship — the activities your business performs may influence which channels are appropriate. But a change to activity types rarely affects channel strategy directly.

### 4.2 The unity principle: one knowledge model, multiple applications

A critical architectural commitment arising from this session's discussion: **the same weighted relationship model that informs comprehension must also inform projection, simulation, reasoning, governance, and assembly guidance.** There cannot be a separate "comprehension knowledge base" maintained independently of the "reasoning knowledge base."

If the system knows that Activity Type is strongly coupled to Activity Cost Allocation, that single fact simultaneously:

- **Shapes comprehension:** When explaining Activity Type, Activity Cost Allocation is surfaced prominently as a strongly-related concept.
- **Informs gap analysis:** If activity types are defined but no cost allocations exist, the gap is flagged as high-severity because the coupling is strong.
- **Weights impact propagation:** When a change to activity types ripples through the model, the system knows the effect on cost allocation is significant.
- **Drives simulation sensitivity:** In scenario modelling, the system knows which variables are tightly coupled and which are loosely coupled.
- **Guides assembly:** When Sam drags Activity Type onto the canvas, the system recommends Activity Cost Allocation as "you probably also need this" (strong coupling), not just "you might want to consider this" (weak coupling).
- **Shapes governance severity:** A governance finding about missing cost allocations is more serious if the coupling to activity types is strong.

One set of weighted relationships. One knowledge model. Multiple applications. No separate, disconnected set of knowledge terms that need to be manually or independently maintained.

### 4.3 Research context: existing formalisms

Research into weighted and probabilistic reasoning identifies several mature formalisms relevant to Ontara's needs. The three most applicable families:

#### 4.3.1 Semiring soft-constraints (for optimisation and trade-offs)

Semiring-based Constraint Logic Programming replaces Boolean satisfaction with values from an abstract semiring (costs, probabilities, preferences) and uses semiring operations to combine and compare constraint values. A single framework can express classical constraint satisfaction problems, weighted CSPs, fuzzy CSPs, and optimisation over costs or preferences.

**Relevance to Ontara:** Design choices (orchestration patterns, staffing models, automation levels) are modelled as variables with soft constraints expressing costs, preferences, and priorities. The same constraint model that helps the system reason about optimal configurations also informs comprehension: "this element is strongly constrained by these factors" is both a reasoning input and an explanation. Semiring soft-constraints support scenario comparison ("what-if" design exploration) and incremental re-optimisation when the user revises priorities.

#### 4.3.2 Fuzzy multi-criteria decision-making (for human judgements)

Fuzzy MCDM represents stakeholder judgements ("low risk", "high automation", "acceptable delay") as fuzzy sets with membership in [0,1] rather than hard thresholds. Methods such as fuzzy AHP, fuzzy TOPSIS, and fuzzy VIKOR aggregate ratings across multiple criteria with weights and fuzzy operators to produce overall suitability scores.

**Relevance to Ontara:** Business users like Sam express needs linguistically, not numerically. Fuzzy MCDM captures this naturally. The same fuzzy scores that drive multi-criteria ranking in simulation also inform comprehension: "this element is rated as high-importance by stakeholders because..." Sensitivity analysis (a standard part of fuzzy MCDM) supports the inferential self-knowledge layer: "which preferences and constraints are most influential?"

#### 4.3.3 Probabilistic Soft Logic (for graded business rules)

PSL combines first-order logical templates with soft truth values in [0,1] and solves for a most-probable assignment via convex optimisation. Rules are expressed in logic-programming style but are graded and learnable rather than Boolean.

**Relevance to Ontara:** Where the system needs explicit, graded business rules — "if process is highly automated then staff load is low, unless exceptions are high" — PSL provides a principled way to express and reason with them. The same graded rules that drive inference also inform comprehension and gap analysis. PSL scales well and weights can be learned from data.

### 4.4 Mapping to Ontara's architecture

The three-layer architecture suggested by this research maps directly onto Ontara's existing structure:

| Research layer | Ontara equivalent | New element needed |
|---|---|---|
| Knowledge & preference model (soft-CSP + fuzzy MCDM) | SysML model + PatternCatalogue + stakeholder preferences | **Weighted relationship model** — interaction strengths on relationships, fuzzy preference scores on design choices |
| Projection and simulation | L1–L4 simulation concepts + BusinessScenarios projection engine | Soft-constraint evaluation feeding simulation; simulation outputs feeding MCDM ranking |
| Inferential self-knowledge | C6 five-layer self-knowledge + comprehension architecture | Comprehension queries use the same weighted model; sensitivity analysis exposes influential factors |

The missing piece — the weighted relationship model — is the connective tissue that makes all three layers use the same knowledge. This is foundational infrastructure, not a comprehension-specific feature.

### 4.5 How to model weights: design options

Four options, ranging from simplest to most sophisticated:

**(a) Numeric weights on typed refs.** Each semantic relationship carries a numeric weight (0.0–1.0). Most flexible; requires defining and calibrating the scale.

**(b) Ordinal strength classification.** A small enum (e.g. `strong`, `moderate`, `weak`, `contextual`) applied to each relationship. Simpler; potentially sufficient for near-term needs.

**(c) Derived from structural proximity.** The system infers relationship strength from structural properties (same-package adjacency, shared attribute types, explicit `ref` connections). Intrinsic but may not capture domain-level coupling accurately.

**(d) Hybrid: structural baseline with human-authored overrides.** The system computes a baseline strength from structural proximity; the model author overrides with explicit weights where the structural inference is misleading. Combines intrinsic computation with human domain knowledge.

**Recommendation: Start with (b) ordinal classification, design for (d) hybrid.** Ordinal classification (strong/moderate/weak) is immediately usable, lightweight, and sufficient to shape comprehension prioritisation, gap severity, and assembly guidance. The architecture should accommodate numeric weights and structural derivation as future extensions — but we should not over-engineer the weight model before we have experience using it. This follows [[concept-design-decision-lifecycle|J12]] (design decision lifecycle): experimentation before convention.

### 4.6 The weight question for Ontara

The research identifies three interpretive frames for weights:

- **Costs/preferences:** weights represent how much something matters for optimisation
- **Fuzzy judgements:** weights represent degrees of membership or expert opinion
- **Probabilities:** weights represent likelihood or uncertainty

Ontara's needs span each of these. Costs/preferences are relevant for scenario comparison, resource optimisation, and design trade-offs. Fuzzy judgements are relevant for stakeholder preference capture and multi-criteria evaluation. While a certain amount of Ontara's clinical reasoning is deterministic by design (A6), and business-model reasoning is more about preferences and trade-offs than about probabilistic inference, it is also the case that clinical decision tools are used to aid diagnosis. Some healthcare service models will need to be able to apply Bayesian and other logics to weigh up treatment pathway choices and to give the clinician assistance in selecting a treatment pathway.

This suggests the weight model should be interpretable as costs/preferences, as fuzzy judgements, *and* as weighted probabilities depending on context. The semiring framework naturally supports this flexibility — the same algebraic structure can express costs (min+), preferences (max×), or fuzzy values (max-min), depending on which semiring is chosen.

---

## 5. Revised Comprehension Architecture

Combining all three extensions, the comprehension architecture now looks like this:

### Register 1: Authored Purposive Framing (static, human-authored)

**Content:** Why should I care about this concept? What is it for? What role does it play in my business?

**Source:** `@UserFacing` metadata — `friendlyName`, `shortDescription`, `purposiveDescription`.

**Characteristics:** Does not change when the model changes. Requires human editorial judgement. Provides the frame into which intrinsic content is placed.

### Register 2: Intrinsic Structural Self-Knowledge (dynamic, generated)

**Content:** What is this element's current state? What are its values, instances, relationships, and coverage? What do the demonstrator domains show?

**Source:** `@Comprehension` metadata (traversal instructions) + live model introspection + **weighted relationship model** (shapes prioritisation of what is surfaced).

**Characteristics:** Changes automatically when the model changes. Composed dynamically from the system's knowledge of its own structure. Uses weighted relationships to prioritise what is surfaced and to determine the prominence of related concepts.

### Register 2+: Inferential Self-Knowledge (dynamic, reasoned)

**Content:** What follows from the current model state? What is implied? What is missing? What are the consequences of a change?

**Source:** Comprehension engine + logic/inference engine (Tier 2 reasoning) + **weighted relationship model** (weights determine impact propagation and gap severity).

**Characteristics:** Goes beyond description to reasoning. Can answer conditional questions ("if I do X, what happens?"). Uses the same five-layer self-knowledge machinery ([[concept-five-layer-self-knowledge|C6]]) that drives operational assessment. Classifies implications by strength and by action category (automatic/recommended/advisory). The same weights that shape comprehension also shape inference — no separate knowledge base.

### Register 3: Conversational Self-Knowledge (future)

**Content:** Interactive dialogue about the system's structure, purpose, and state. Sam asks questions, the system answers drawing on all three lower registers.

**Source:** LLM with structured access to model introspection data, traversal results, inference outputs, and weighted relationship model.

**Characteristics:** Adapts to the user's level of understanding. Can explain rationale and purpose. Grounded in the model to avoid confabulation.

---

## 6. Implications for Phase 3

### 6.1 What we build now

Phase 3 should deliver:

1. **Improved `@UserFacing` descriptions (Register 1).** The 26 purposive descriptions drafted earlier in this session. These provide the authored frame. Extend the `@UserFacing` metadata def with a `purposiveDescription` attribute.

2. **`@Comprehension` metadata design and initial implementation (Register 2 foundation).** Design the comprehension traversal schema as a new metadata def in `Foundation::MetadataLibrary`. Apply it to a pilot element (Activity Type) and verify in Syside. Extend the generator to read comprehension metadata and produce dynamically-assembled explanations. Extend the glossary view to display combined authored + intrinsic content.

3. **Syntax spike: `ref` inside `metadata def`.** Test whether typed references work inside metadata defs. This determines whether comprehension traversal targets can be expressed as formal model references or must use string-based identifiers.

4. **Ordinal weight classification: initial design.** Design the weight enum (strong/moderate/weak/contextual) and the mechanism for applying weights to relationships. Apply to the Activity Type pilot to demonstrate the concept. Document the design for future extension to numeric weights and structural derivation.

### 6.2 What we design now but build later

1. **Numeric/hybrid weight model.** Design how structural proximity baseline + human overrides would work. Implementation is Phase 4+ work.

2. **Inference engine connection.** Design how comprehension queries invoke the logic engine for conditional reasoning. Implementation depends on Tier 2 (Tau Prolog) readiness. This is Stage 4+ work but the architecture should accommodate it from Phase 3.

3. **Soft-constraint and fuzzy MCDM integration.** The research identifies semiring soft-constraints and fuzzy MCDM as the appropriate formalisms. Technology selection and integration design is Stage 4+ work. The weighted relationship model we build in Phase 3 should be compatible with these formalisms — ordinal weights can be mapped to semiring values or fuzzy membership functions when the time comes.

### 6.3 What this defers

1. **Register 3 (conversational self-knowledge).** Remains a future concern.

2. **Full weighted relationship application.** Phase 3 establishes the mechanism with the Activity Type pilot; later phases populate it systematically.

3. **Simulation integration.** Feeding weighted relationship data into the projection engine and simulation framework (L1–L4) is a natural extension but requires simulation infrastructure that doesn't yet exist.

---

## 7. New Concepts Introduced

| Concept | Description | Register reference |
|---|---|---|
| **Intrinsic self-knowledge principle** | System explanations are dynamically computed from live model state, not stored as static text. The test: if the model changes and no human edits a description, does the explanation become wrong? If yes, the content must be intrinsic. | Sharpens I14, C6 |
| **Comprehension traversal schema** | `@Comprehension` metadata declares *how* to construct an explanation, not *what* the explanation says. It is a recipe of traversal instructions executed against the current model. | New — extends I14 |
| **Weighted relationships** | Relationships between elements are characterised by strength of interaction effect. Weights shape comprehension prioritisation, impact analysis, gap severity, simulation sensitivity, and assembly guidance. | New — extends K (semantic vocabulary) |
| **Unity principle** | The same weighted relationship model informs comprehension, reasoning, simulation, governance, and assembly guidance. No separate, disconnected knowledge structures. One model, multiple applications. | New — foundational commitment |
| **Inferential comprehension (Register 2+)** | The comprehension layer reasons about implications, requirements, and gaps — not just structure. Uses the same five-layer self-knowledge machinery as operational assessment. | Sharpens C6, connects F1–F6 to I14 |

---

## 8. Open Questions

1. **What is the right granularity for comprehension traversal instructions?** Per-element (every `part def` gets a `@Comprehension` annotation) or per-concern (one traversal schema per BMM concern, applied to all elements in that concern)?

2. **Can the generator compute structural proximity weights automatically?** If so, what heuristics? Same-package adjacency, shared attribute types, explicit `ref` connections, import dependency chains?

3. **How does weighted relationship data feed the assembly workspace?** When a user drags Activity Type onto the canvas, should the system show strongly-coupled elements as "you probably also need these" and weakly-coupled elements as "you might want to consider these"?

4. **Should Register 2+ reasoning be synchronous or pre-computed?** Synchronous is always current but may be slow. Pre-computed is fast but may be stale. The answer may depend on model size and reasoning complexity.

5. **What is the right semiring for Ontara's soft-constraint layer?** The research suggests min+ for cost optimisation and max-min for fuzzy reasoning. Ontara may need both, applied in different contexts. This is a Stage 4 design question.

6. **How do weights interact with the concentric rings of rigour (B3)?** Inner-ring clinical concepts presumably have strong, formally verified relationships. Outer-ring business context concepts have weaker, more advisory relationships. Should the ring assignment inform a default weight, with explicit overrides where needed?

---

## 9. Connections to Existing Concepts

| Concept | Connection |
|---|---|
| [[concept-comprehension-layer\|I14]] | Fundamentally sharpened: not labels or even generated descriptions, but intrinsic self-knowledge |
| [[concept-five-layer-self-knowledge\|C6]] | Extended: self-knowledge machinery applied to user-facing comprehension and model-building assessment |
| [[principle-model-generates-everything\|A3]] | Deepened: the model generates not just artefacts but explanations of itself |
| [[concept-cross-domain-validation\|J1]] | Reinforced: demonstrator domains as pedagogical anchors, now with weighted relationships shaping which illustrations are surfaced |
| K (Semantic vocabulary) | Extended: predicates gain a weight/strength dimension |
| B3 (Concentric rings of rigour) | Connected: weights encode the rigour gradient — inner ring = strong coupling, outer ring = weak coupling |
| F1–F6 (Knowledge layer) | Connected: comprehension engine uses the same assessment and reasoning machinery |
| I11 (Progressive validation) | Enriched: validation severity shaped by relationship weights |
| I2/I9 (Assembly workspace) | Informed: comprehension + weights = intelligent guidance during model assembly |
| L1–L4 (Simulation) | Connected: weighted relationships inform simulation sensitivity and scenario comparison |
| A6 (Deterministic reasoning) | Clarified: weights are costs/preferences and fuzzy judgements, not probabilities. Clinical reasoning remains deterministic. |

---

## 10. Technical Research References

The following formalisms were identified through research as relevant to Ontara's weighted reasoning needs:

- **Semiring-based Constraint Logic Programming** — replaces Boolean satisfaction with values from an abstract semiring (costs, probabilities, preferences). A single framework for weighted CSPs, fuzzy CSPs, and optimisation. Applicable to scenario comparison and design-space exploration.
- **Fuzzy multi-criteria decision-making (fuzzy AHP, fuzzy TOPSIS, fuzzy VIKOR)** — represents stakeholder judgements as fuzzy membership values. Supports multi-criteria ranking, sensitivity analysis, and linguistic preference capture. Applicable to stakeholder preference modelling and comprehension prioritisation.
- **Probabilistic Soft Logic (PSL)** — first-order templates with soft truth values in [0,1], solved via convex optimisation. Applicable to graded business rules and learnable relationship strengths.
- **Tau Prolog** — already identified (F6) for Tier 2 reasoning. Potential integration point for soft-constraint evaluation if extended with semiring operations.

Full research notes: `probabilistic_reasoning_research.md`.

---

*Discussion paper written 20 March 2026 (Session 46). Extends the Session 45 comprehension architecture with four new contributions: intrinsic self-knowledge principle, inference engine connection, weighted relationships, and the unity principle (one knowledge model, multiple applications). Informed by research into semiring soft-constraints, fuzzy MCDM, and Probabilistic Soft Logic.*
