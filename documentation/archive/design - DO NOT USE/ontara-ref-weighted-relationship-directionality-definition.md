# Ontara — Weighted Relationship Directionality Definition

**Date:** 21 March 2026 (Session 53)
**Status:** Agreed definition. Governs interpretation of all `@WeightedRelationship` annotations.
**Register concept:** [[concept-weighted-relationships|B14]] (weighted relationships)
**Related principles:** [[concept-unity-principle|A11]] (unity principle), [[concept-intrinsic-self-knowledge|A10]] (intrinsic self-knowledge), [[concept-non-constraining|J3]] (non-constraining)

---

## 1. What a Weighted Edge Asserts

A `@WeightedRelationship` annotation on element A with `target = "B"` and `strength = S` asserts:

> **"If A changes, B needs to be reassessed with urgency S."**

This is a **forward propagation of change** assertion. It answers: "Given a change to A, how much pressure does that change place on B to be reconsidered?"

The annotation is directional. It radiates outward from the element on which it is declared. The `target` is the element that receives the effect of change.

---

## 2. Strength Definitions

| Strength | Meaning |
|---|---|
| **strong** | A change to A almost certainly requires reassessing B. The concepts are structurally coupled. |
| **moderate** | A change to A may require reassessing B. The concepts are connected but the coupling is not definitional. |
| **weak** | A change to A has a distant or indirect effect on B. The connection exists but is mediated through other concepts. |
| **contextual** | The relationship between A and B depends on domain-specific factors. In some instantiations it may be strong; in others it may not exist at all. |

---

## 3. Non-Commutativity

The edge A → B and the edge B → A are independently assessed. They are two separate structural facts about the model.

- A strong A → B and a weak B → A do not net off, average, or combine into a single "moderate" assessment.
- The user may form their own interpretive judgement about the combined real-world effect, but that is their reasoning — not a property of the model.
- Symmetry (where A → B and B → A have the same strength) is a substantive judgement, not an automatic consequence. It must be independently justified for each direction.

**Example:**
- ServiceOffering → CustomerSegment (**strong**): if you change what you offer, you must reassess who it's for.
- CustomerSegment → ServiceOffering (**strong**): if you change who you're targeting, you must reassess what you offer.
- These happen to be symmetric, but each was independently assessed. Neither follows automatically from the other.

---

## 4. Temporal Propagation and Simulation

The static weight model captures the **structural potential** for change propagation. In a running business, propagation unfolds over time:

1. **A changes at time T₁.** The outgoing edges from A identify which concepts are affected, and at what urgency.
2. **B responds at time T₂.** B is reassessed and potentially changed in response to A's change. There is a lag between T₁ and T₂ — the magnitude of this lag depends on the nature of the concepts and the operational context.
3. **Reverse propagation at T₃.** B's change may now propagate back along B's outgoing edges, including potentially back to A. This is not "netting off" — it is a distinct, time-separated event. A's outgoing edge to B was the forward effect; B's outgoing edge to A (if one exists) carries the reverse effect at a later time.

Multiple concepts may change simultaneously or in overlapping time windows, producing complex interaction patterns where forward and reverse effects interleave. The static weight model does not attempt to resolve these dynamics — that is the province of simulation ([[concept-scenario-definition|L1–L4]]). What the weight model provides is the **structural graph** over which simulation propagates effects.

**Key distinction:** The static weights say "these things are connected with this urgency." Simulation says "given these initial changes and this timeline, here is what happens." The weights are the map; simulation is the journey.

**Design implication:** When the simulation capability is built, it must treat each directed edge independently, with its own propagation timing. A forward effect from A → B at T₁ and a reverse effect from B → A at T₃ are two distinct simulation events, not a single bidirectional interaction. The temporal separation is what prevents the false inference that a strong + weak pair "averages to moderate."

---

## 5. Implications for Console Visualisation

- **Graph view:** Edges are directed. Each direction carries its own weight and may be rendered with its own colour or thickness. A bidirectional relationship appears as two directed edges (or a single edge with two weight indicators), not as one averaged edge.
- **Change-impact analysis:** When propagating "what if we change X?", the system follows outgoing edges from X, weighted by strength. Reverse edges are not consulted for that propagation — they represent the independent question "what if the target changes, how much does X need reassessment?"
- **Tabular view:** The glossary's related-concepts display shows outgoing weights from the element being viewed. The reverse direction is visible when the user navigates to the target element and sees its own outgoing weights.

---

## 6. SysML Annotation Semantics

In the model:

```sysml
@WeightedRelationship {
    target = "B";
    strength = RelationshipStrength::strong;
    rationale = "...";
}
part def A { ... }
```

This declares: **A → B, strong.** The reverse (B → A) must be independently declared on B's definition, if it exists. Absence of a reverse annotation means the reverse relationship has not been assessed, not that it is zero.

The `rationale` attribute should state the directionality explicitly, e.g. "A change to A's pricing basis directly affects B's revenue projection" — not a symmetric statement like "A and B are related."

---

*Definition agreed 21 March 2026, Session 53. Governs all `@WeightedRelationship` annotations from Batch 1 onward.*
