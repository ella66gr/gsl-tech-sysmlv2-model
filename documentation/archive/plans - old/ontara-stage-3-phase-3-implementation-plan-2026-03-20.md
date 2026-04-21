# Ontara — Stage 3 Phase 3: Comprehension Metadata — Detailed Implementation Plan

**Date:** 20 March 2026 (Session 48)
**Parent plan:** [[ontara-stage-3-plan-2026-03-19|Stage 3 Detailed Plan]] Phase 3 (revised scope from Session 46)
**Design source:** [[ontara-discussion-intrinsic-self-knowledge-v2-2026-03-20|Intrinsic Self-Knowledge Discussion]] §6.1
**Prerequisites:** Phase 1 (Paws) complete. Phase 2 (Glossary) complete. Tiered register and governing documents current (Session 47–48).
**26 draft descriptions:** [[phase-3-draft-descriptions-2026-03-20|Draft purposive descriptions]] — Ella to review before Step 2 execution.

---

## 1. Objective

Phase 3 implements the foundational comprehension metadata layer. It bridges the gap between the current labelling system (`@UserFacing` with `friendlyName` and `shortDescription`) and genuine intrinsic self-knowledge ([[principle-intrinsic-self-knowledge|A10]]). By the end of Phase 3, the model will carry purposive descriptions (Register 1), a comprehension traversal schema (Register 2 foundation), and a pilot ordinal weight classification (B14 foundation).

---

## 2. Scope — Four Deliverables

From the [[ontara-discussion-intrinsic-self-knowledge-v2-2026-03-20|Session 46 discussion paper]] §6.1:

| # | Deliverable | Register | Exercises |
|---|---|---|---|
| D1 | Apply 26 purposive descriptions to `@UserFacing` metadata | Register 1 (authored) | A3, A10, I14, J2 |
| D2 | Design and implement `@Comprehension` metadata with traversal schema | Register 2 (structural) | A3, A10, A11, I16 |
| D3 | Syntax spike: `ref` inside `metadata def` | Technical validation | A3, J12 |
| D4 | Ordinal weight classification: design and pilot on Activity Type | B14 foundation | A11, B14, J12 |

---

## 3. Tier 1 Relevance Check

| T1 Principle | How Phase 3 honours it |
|---|---|
| A1 (representation/execution separation) | Comprehension metadata is representation-layer; console reads generated JSON |
| A2 (self-describing system) | The system gains purposive and structural self-descriptions |
| A3 (model generates everything) | Comprehension structure modelled in SysML (Option 3), not generator logic |
| A4 (two meta model distinction) | Metadata defs are BSMM concepts in Foundation::MetadataLibrary; descriptions cover BMM part defs |
| A6 (deterministic reasoning) | Not directly exercised — monitor only |
| A9 (discipline) | Following the plan; checking register at open/close |
| **A10 (intrinsic self-knowledge)** | **Primary principle.** D2 implements the mechanism; D1 provides the authored frame |
| **A11 (unity principle)** | **Primary principle.** D4 establishes the weight model that A11 requires to be shared across subsystems |
| J2 (co-evolution) | Each model change (D1–D4) has a corresponding generator/console extension |
| J3 (non-constraining) | Ordinal weights (D4) designed for hybrid evolution; `@Comprehension` schema designed for extension |

---

## 4. Detailed Steps

### Step 1: Syntax Spike — `ref` inside `metadata def` (D3)

**Purpose:** Determine whether typed references work inside metadata defs. This gates the design of `@Comprehension` — if `ref` works inside `metadata def`, traversal targets can be formal model references; if not, they must use string identifiers.

**Work:**
1. Read the [[gsl-sysml-v2-syntax-reference|SysML syntax reference]] for any existing findings on `ref` inside `metadata def`.
2. Create a test file in `model/syntax-tests/` with:
   - A `metadata def` containing a `ref` to a `part def`
   - A `metadata def` containing a `ref` to another `metadata def`
   - A `metadata def` containing a `ref :>>` redefinition
3. Ella validates in Syside.
4. Document findings in the syntax reference.

**Exit criteria:** Clear yes/no on `ref` inside `metadata def`, with syntax reference updated.

**Suited to:** Claude Chat drafts the test file. Ella validates in Syside. Claude Chat updates the syntax reference.

**Claude Code instructions:** Not needed — this is a small, design-sensitive task.

---

### Step 2: Apply 26 Purposive Descriptions (D1)

**Prerequisites:** Ella has reviewed the [[phase-3-draft-descriptions-2026-03-20|26 draft descriptions]] and confirmed or revised them.

**Work:**
1. Extend the `@UserFacing` metadata def in `Foundation::MetadataLibrary` to add a `purposiveDescription` attribute (String).
2. For each of the 26 BMM `part def`s, update the existing `@UserFacing` annotation to include the agreed `purposiveDescription` value.
3. For elements that currently have no `@UserFacing` annotation (marked ✦ in the draft), add the full annotation (friendlyName + shortDescription + purposiveDescription).
4. Re-run `gen_model_introspection.py` to produce updated JSON.
5. Verify the glossary view displays purposive descriptions (may need a minor console update to render the new field).

**Exit criteria:** All 26 BMM `part def`s carry `@UserFacing` with `purposiveDescription`. Generator produces JSON with the new field. Glossary displays it.

**Suited to:** Claude Chat designs the metadata def extension and drafts one or two exemplar annotations for Ella's review. **Claude Code** then applies the remaining 24 annotations mechanically.

**Claude Code instructions:**
```
In model/business-model.sysml, for each part def listed below, update the existing 
@UserFacing annotation to add a purposiveDescription attribute. Use Position A (prefix 
position, before the part def). If no @UserFacing annotation exists, add one with all 
three attributes (friendlyName, shortDescription, purposiveDescription).

The purposiveDescription values are in the file [path to confirmed descriptions].

Before starting: read documentation/reference/gsl-sysml-v2-syntax-reference.md for 
metadata annotation syntax. The pattern is:

@UserFacing {
    attribute friendlyName = "...";
    attribute shortDescription = "...";
    attribute purposiveDescription = "...";
}
part def ExampleConcept { ... }

Do NOT modify any content inside the part def body. Only add/update the @UserFacing 
annotation in prefix position. Verify that each annotation parses correctly by checking 
bracket matching and semicolons.
```

---

### Step 3: Design and Implement `@Comprehension` Metadata (D2)

**Prerequisites:** Step 1 (syntax spike) complete — informs whether traversal targets use `ref` or string identifiers.

**Work:**

**3a. Design the `@Comprehension` metadata def:**

The `@Comprehension` metadata def declares traversal instructions — a recipe for how the comprehension engine assembles an explanation from live model state. It does NOT contain explanations.

Proposed structure (subject to syntax spike results):

```sysml
metadata def Comprehension {
    doc /* Comprehension traversal schema. Declares how the
         * comprehension engine assembles a dynamic explanation
         * for this element from live model state.
         *
         * The metadata is a recipe, not a script. The generator
         * reads traversal instructions and composes explanations
         * from the current model at generation time.
         *
         * Business system meta model concept. Intrinsic
         * self-knowledge principle (A10). Option 3: modelled
         * in SysML, not in generator logic. */

    // What enum values to surface (if this element has an associated enum)
    attribute surfaceEnumValues : String;

    // What domain instantiations to count and list
    attribute surfaceDomainInstantiations : Boolean;

    // What related elements to traverse (by package proximity or explicit ref)
    attribute traverseRelated : String;

    // What attributes to surface in the explanation
    attribute surfaceAttributes : Boolean;

    // Traversal depth (how many levels of related elements to follow)
    attribute traversalDepth : String;
}
```

If `ref` works inside `metadata def` (Step 1), `traverseRelated` can become a typed `ref` to `Part[0..*]` rather than a string. This is architecturally preferable (A3 — model references, not strings).

**3b. Apply `@Comprehension` to Activity Type as pilot:**

Activity Type is the canonical pilot element (chosen in Session 46 because it has enum values, domain instantiations across all three domains, related concepts, and a rich purposive description).

**3c. Extend the generator:**

Update `gen_model_introspection.py` to:
- Parse `@Comprehension` annotations
- For each annotated element, execute the traversal instructions against the current model
- Produce a `comprehension` section in the JSON output containing the dynamically assembled explanation

**3d. Extend the glossary view:**

Update the glossary to display combined authored (`@UserFacing`) + intrinsic (`@Comprehension`-derived) content for annotated elements. For the pilot (Activity Type), the glossary entry should show:
- The purposive description (authored, from D1)
- The enum values (intrinsic — "Every activity is an activity of one of these types: service delivery, enabling, governance, development, overhead")
- The domain instantiation counts (intrinsic — "Cafe: 6 types, Suds: 10 types, Paws: 8 types")
- Related concepts (intrinsic — traversed from model structure)

**Exit criteria:** `@Comprehension` metadata def exists in Foundation::MetadataLibrary. Activity Type carries a `@Comprehension` annotation. Generator produces dynamically assembled content. Glossary displays combined authored + intrinsic content for Activity Type.

**Suited to:** Claude Chat for the full design, generator extension, and console implementation. This is architecturally sensitive work requiring design judgement throughout.

**Claude Code instructions:** Not suited to Code — this step requires iterative design.

---

### Step 4: Ordinal Weight Classification — Design and Pilot (D4)

**Prerequisites:** Step 3 complete (so the `@Comprehension` traversal has related elements to weight).

**Work:**

**4a. Design the weight enum:**

```sysml
enum def RelationshipStrength {
    doc /* Ordinal classification of interaction effect strength
         * between related elements. Starting point for the
         * weighted relationship model (B14).
         *
         * Designed for hybrid evolution: ordinal now, numeric
         * weights later, structural derivation baseline with
         * human overrides (J12 — experimentation before convention).
         *
         * Business system meta model concept. Unity principle (A11):
         * same weights inform comprehension, reasoning, simulation,
         * governance, and assembly guidance. */
    enum strong;
    enum moderate;
    enum weak;
    enum contextual;
}
```

**4b. Design the weight annotation mechanism:**

Two options to evaluate:
- **Option A:** A new `metadata def WeightedRelationship` with attributes for `target` (string or ref), `strength` (RelationshipStrength), and `rationale` (String). Applied to the element that has the relationship.
- **Option B:** Extend the existing typed `ref` fields on Pattern with a weight attribute. This would require a structural change to the PatternCatalogue.

Recommend Option A for Phase 3 — it's non-constraining (J3) and can be applied to any element, not just patterns.

**4c. Apply to Activity Type pilot:**

For the Activity Type pilot, declare weighted relationships to its known related concepts:
- Activity Type → Activity Cost Allocation: **strong**
- Activity Type → Activity Granularity: **strong**
- Activity Type → Activity Budget: **moderate**
- Activity Type → Activity Record: **moderate**
- Activity Type → Resource Type: **moderate**
- Activity Type → Channel: **weak**

**4d. Extend the generator and comprehension display:**

Update the generator to read weight annotations and include them in the JSON. Update the glossary/comprehension display to use weights for prioritisation — strongly related concepts are surfaced first and more prominently than weakly related ones.

**Exit criteria:** `RelationshipStrength` enum exists. Weight annotation mechanism defined and applied to Activity Type. Generator reads weights. Glossary display uses weights for prioritisation.

**Suited to:** Claude Chat for the design discussion and initial implementation. **Claude Code** for bulk weight annotation application once the pattern and initial weights are agreed.

**Claude Code instructions:**
```
In model/foundation.sysml (or the appropriate model file), apply @WeightedRelationship 
annotations to the elements listed in [file]. Each annotation has three attributes:
target (String), strength (String — one of "strong", "moderate", "weak", "contextual"), 
and rationale (String).

Use Position A (prefix). Read the syntax reference first.
```

---

## 5. Execution Order and Dependencies

```
Step 1 (Syntax Spike) ──→ Step 3 (Design @Comprehension)
                              │
Step 2 (Apply Descriptions) ──┤──→ Step 3d (Glossary combined view)
                              │
                         Step 4 (Weight Design + Pilot)
```

- **Step 1 must come first** — its result gates Step 3's design.
- **Step 2 can run in parallel with Step 1** — it doesn't depend on the spike result.
- **Step 3 depends on Step 1** (for the ref question) and benefits from Step 2 (purposive descriptions provide the authored frame that intrinsic content fills).
- **Step 4 depends on Step 3** (needs the `@Comprehension` traversal to have related elements to weight).

---

## 6. Estimated Effort

| Step | Sessions | Notes |
|---|---|---|
| Step 1 (Syntax Spike) | 0.5 | Quick — write test, Ella validates, update reference |
| Step 2 (Apply Descriptions) | 1 | Claude Chat designs extension + exemplars; Claude Code applies 24 more |
| Step 3 (@Comprehension) | 2–3 | Design, generator extension, console update, pilot verification |
| Step 4 (Weight Pilot) | 1–2 | Design enum + mechanism, apply to pilot, generator + display |
| **Total** | **4.5–6.5** | |

---

## 7. Commit Strategy

| After step | Commit |
|---|---|
| Step 1 | Commit syntax test file + syntax reference update |
| Step 2 | Commit `@UserFacing` extension + all 26 annotations + regenerated JSON |
| Step 3 | Commit `@Comprehension` metadata def + Activity Type annotation + generator + console |
| Step 4 | Commit `RelationshipStrength` enum + weight mechanism + pilot annotations + generator + console |

---

## 8. Register Concepts Exercised

| Concept | How |
|---|---|
| **A10 (intrinsic self-knowledge)** | D2 implements the mechanism; D1 provides the frame |
| **A11 (unity principle)** | D4 establishes the shared weight model |
| A3 (model generates everything) | Comprehension structure in SysML (Option 3) |
| B14 (weighted relationships) | D4 introduces ordinal weights |
| I14 (comprehension layer) | D1 + D2 together constitute the comprehension layer implementation |
| I16 (traversal schema) | D2 defines the traversal schema |
| I17 (authored/intrinsic distinction) | D1 = authored; D2 = intrinsic |
| J2 (co-evolution) | Every model change has a generator/console counterpart |
| J3 (non-constraining) | Ordinal weights designed for hybrid evolution |
| J12 (design decision lifecycle) | Weights enter at "experimentation" stage |

---

## 9. What Phase 3 Does NOT Do

- **Register 2+ (inferential comprehension)** — requires reasoning formalisms (M7). Deferred.
- **Systematic weight population** — Phase 3 pilots on Activity Type only. Systematic population is Phase 4+ work.
- **Numeric/hybrid weight model** — designed for but not implemented. Ordinal is sufficient for Phase 3.
- **Register 3 (conversational self-knowledge)** — future concern.
- **Soft-constraint or fuzzy MCDM integration** — research direction (M7), not Phase 3 scope.

---

## 10. Open Questions for Discussion Before Starting

1. **Has Ella reviewed and confirmed the 26 draft descriptions?** Step 2 cannot execute without confirmed descriptions.
2. **Metadata def extension approach:** Add `purposiveDescription` to the existing `@UserFacing`, or create a separate `@PurposiveDescription` metadata def? Recommendation: extend `@UserFacing` — keeps all authored content in one annotation.
3. **`@Comprehension` placement:** Same file as the element it annotates (Position A prefix), or in a separate comprehension-specific section of the file? Recommendation: Position A prefix, consistent with `@UserFacing` and `@CatalogueTag`.

---

*Implementation plan prepared 20 March 2026 (Session 48).*
