// =========================================================================
// SYNTAX TEST: Multiple annotations of the same metaclass on one element
//
// Purpose: Can a single part def carry multiple @WeightedRelationship
//          annotations? This gates the design of the ordinal weight
//          classification mechanism (Stage 3 Phase 3, Step 4).
//
// Context: Stage 3 Phase 3 implementation plan, Step 4 (B14 foundation).
//          Session 51.
//
// Prior art:
//   - Multiple annotations of DIFFERENT metaclasses: ✅ verified (v3.14)
//     e.g. @CatalogueTag + @UserFacing on one part def
//   - One annotation per metaclass per element: documented as failing
//     for @CatalogueTag (v3.14, Session 38) — "stacking two @Tag fails"
//   - This test checks whether the v3.14 finding generalises to all
//     metadata defs or was specific to @CatalogueTag
//
// What to check in Syside:
//   TEST A: Two annotations of the same metaclass on one part def
//   TEST B: Three annotations of the same metaclass on one part def
//   TEST C: Six annotations of the same metaclass on one part def
//           (the Activity Type use case)
//   TEST D: Two same-metaclass + one different-metaclass (mixed)
//
// For each test, check:
//   1. Does the file parse without errors?
//   2. Do ALL annotations show correct types on hover?
//   3. Are all annotation attribute values accessible (not shadowed)?
//   4. Does the outline view show all annotations?
//
// Expected failure mode (if it fails):
//   - Second annotation silently shadows/replaces the first
//   - Parse error on the second annotation
//   - type-membership or feature-membership error
//   - File parses but only last annotation is resolvable
// =========================================================================

package SyntaxTestMultipleSameMetaclassAnnotations {
    private import ScalarValues::*;

    doc /* Syntax test: multiple annotations of the same metadata def
         * on a single element. Session 51 — Stage 3 Phase 3, Step 4
         * (ordinal weight classification). */

    // -- Supporting definitions ----------------------------------

    enum def RelationshipStrength {
        doc /* Ordinal classification of interaction effect strength.
             * Test version — mirrors the planned production enum. */
        strong;
        moderate;
        weak;
        contextual;
    }

    metadata def WeightedRelationship {
        doc /* Declares a weighted relationship from the annotated
             * element to a target element. Test version — mirrors
             * the planned production metadata def.
             *
             * If multiple annotations of this metaclass can coexist
             * on one element, each annotation declares one relationship
             * with its own target, strength, and rationale. */
        attribute target : String;
        attribute strength : RelationshipStrength;
        attribute rationale : String;
    }

    metadata def SomeOtherAnnotation {
        doc /* A different metaclass, for the mixed test (Test D). */
        attribute label : String;
    }

    // -- Supporting part defs (targets) --------------------------

    part def Alpha {
        doc /* Target element for relationship tests. */
        attribute alphaName : String;
    }

    part def Beta {
        doc /* Target element for relationship tests. */
        attribute betaName : String;
    }

    part def Gamma {
        doc /* Target element for relationship tests. */
        attribute gammaName : String;
    }

    // -- TEST A: Two same-metaclass annotations ------------------

    @WeightedRelationship {
        target = "Alpha";
        strength = RelationshipStrength::strong;
        rationale = "Test A — first annotation";
    }
    @WeightedRelationship {
        target = "Beta";
        strength = RelationshipStrength::moderate;
        rationale = "Test A — second annotation";
    }
    part def TestTwoAnnotations {
        doc /* Can a part def carry two @WeightedRelationship
             * annotations? Check: do both parse? Are both
             * visible on hover / in outline? Or does the second
             * shadow the first? */
        attribute testName : String;
    }

    // -- TEST B: Three same-metaclass annotations ----------------

    @WeightedRelationship {
        target = "Alpha";
        strength = RelationshipStrength::strong;
        rationale = "Test B — first";
    }
    @WeightedRelationship {
        target = "Beta";
        strength = RelationshipStrength::moderate;
        rationale = "Test B — second";
    }
    @WeightedRelationship {
        target = "Gamma";
        strength = RelationshipStrength::weak;
        rationale = "Test B — third";
    }
    part def TestThreeAnnotations {
        doc /* Three @WeightedRelationship on one part def.
             * If Test A passes, does it scale? */
        attribute testName : String;
    }

    // -- TEST C: Six same-metaclass annotations ------------------
    // This is the real use case: Activity Type has six related
    // concepts, each needing its own weight annotation.

    @WeightedRelationship {
        target = "Alpha";
        strength = RelationshipStrength::strong;
        rationale = "Test C — first of six";
    }
    @WeightedRelationship {
        target = "Beta";
        strength = RelationshipStrength::strong;
        rationale = "Test C — second of six";
    }
    @WeightedRelationship {
        target = "Gamma";
        strength = RelationshipStrength::moderate;
        rationale = "Test C — third of six";
    }
    @WeightedRelationship {
        target = "Alpha";
        strength = RelationshipStrength::moderate;
        rationale = "Test C — fourth of six (duplicate target, different weight)";
    }
    @WeightedRelationship {
        target = "Beta";
        strength = RelationshipStrength::moderate;
        rationale = "Test C — fifth of six";
    }
    @WeightedRelationship {
        target = "Gamma";
        strength = RelationshipStrength::weak;
        rationale = "Test C — sixth of six";
    }
    part def TestSixAnnotations {
        doc /* Six @WeightedRelationship on one part def.
             * Mirrors the Activity Type use case:
             * ActivityCostAllocation (strong), ActivityGranularity (strong),
             * ActivityBudget (moderate), ActivityRecord (moderate),
             * ResourceType (moderate), Channel (weak). */
        attribute testName : String;
    }

    // -- TEST D: Mixed — two same-metaclass + one different ------

    @SomeOtherAnnotation {
        label = "Test D — different metaclass";
    }
    @WeightedRelationship {
        target = "Alpha";
        strength = RelationshipStrength::strong;
        rationale = "Test D — first WeightedRelationship";
    }
    @WeightedRelationship {
        target = "Beta";
        strength = RelationshipStrength::weak;
        rationale = "Test D — second WeightedRelationship";
    }
    part def TestMixedAnnotations {
        doc /* One @SomeOtherAnnotation + two @WeightedRelationship.
             * Confirms that the mixed-metaclass pattern (already
             * verified) still works when combined with same-metaclass
             * stacking. */
        attribute testName : String;
    }
}
