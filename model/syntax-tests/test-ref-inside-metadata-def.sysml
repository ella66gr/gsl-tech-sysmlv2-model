// =========================================================================
// SYNTAX TEST: ref inside metadata def body
//
// Purpose: Can a metadata def contain ref fields? This is the central
//          question for the @Comprehension design (Stage 3 Phase 3,
//          Step 1). If ref works inside metadata def, traversal targets
//          in @Comprehension can be formal typed model references
//          (architecturally preferable — A3). If not, they must use
//          string identifiers.
//
// Context: Stage 3 Phase 3 implementation plan, Step 1 (syntax spike).
//          Session 49.
//
// Prior art:
//   - ref inside part def: ✅ verified (§2, syntax reference v3.11)
//   - ref inside requirement def: ✅ verified (§7, syntax reference v3.11)
//   - ref targeting metadata def type: ✅ verified (§8, syntax reference v3.12)
//   - attribute inside metadata def: ✅ verified (§8, all metadata defs)
//   - enum-typed attribute inside metadata def: ✅ verified (§8, v3.12)
//   - ref inside metadata def: ❓ NOT YET TESTED
//
// What to check in Syside:
//   TEST A: ref to a part def (singular) inside metadata def
//   TEST B: ref to a part def (multi-valued) inside metadata def
//   TEST C: ref to another metadata def inside metadata def
//   TEST D: ref to an enum def inside metadata def
//   TEST E: ref with :>> redefinition in a metadata usage (annotation)
//   TEST F: mixed attributes and refs inside metadata def
//
// Expected errors if ref is NOT supported inside metadata def:
//   - Parse error at the ref keyword
//   - type-error or feature-membership error
//   - Silent failure (no error but ref not resolvable)
//
// For each test, check:
//   1. Does the file parse without errors?
//   2. Does hover on the ref show the correct type?
//   3. Does the metadata def appear correct in the outline view?
//   4. Can the annotation be applied to a part def without errors?
// =========================================================================

package SyntaxTestRefInsideMetadataDef {
    private import ScalarValues::*;

    doc /* Syntax test: ref inside metadata def body.
         * Session 49 — Stage 3 Phase 3, Step 1 (syntax spike). */

    // -- Supporting type definitions for test targets --------

    part def TargetElement {
        doc /* A simple part def to serve as a ref target. */
        attribute targetName : String;
    }

    part def AnotherElement {
        doc /* A second part def for multi-valued ref tests. */
        attribute anotherName : String;
    }

    enum def TraversalDepth {
        doc /* Enum for testing enum-typed ref inside metadata def. */
        shallow;
        deep;
        exhaustive;
    }

    metadata def SimpleAnnotation {
        doc /* A simple metadata def to serve as a ref target
             * for the metadata-to-metadata ref test. */
        attribute annotationName : String;
    }

    // -- TEST A: ref to a part def (singular) ----------------

    metadata def TestRefToPartDefSingular {
        doc /* Can a metadata def hold a ref typed by a part def?
             * This is the core question for @Comprehension:
             * can a traversal instruction point at a specific
             * model element via a typed reference? */
        attribute label : String;
        ref traversalTarget : TargetElement;
    }

    // -- TEST B: ref to a part def (multi-valued) ------------

    metadata def TestRefToPartDefMulti {
        doc /* Can a metadata def hold a multi-valued ref to
             * a part def? Needed for @Comprehension if a single
             * annotation declares multiple traversal targets. */
        attribute label : String;
        ref traversalTargets : TargetElement[0..*];
    }

    // -- TEST C: ref to another metadata def -----------------

    metadata def TestRefToMetadataDef {
        doc /* Can a metadata def hold a ref typed by another
             * metadata def? This would allow @Comprehension
             * to reference @UserFacing or @PurposiveDescription
             * by formal model reference rather than convention. */
        attribute label : String;
        ref relatedAnnotation : SimpleAnnotation;
    }

    // -- TEST D: ref to an enum def --------------------------

    metadata def TestRefToEnumDef {
        doc /* Can a metadata def hold a ref typed by an enum def?
             * Distinct from an enum-typed attribute (which is
             * already verified). A ref to an enum def would
             * reference the definition itself, not a value. */
        attribute label : String;
        ref depthEnum : TraversalDepth;
    }

    // -- TEST E: Annotation application ----------------------
    // If Tests A–D parse, verify that the annotations can
    // actually be applied to part defs.

    @TestRefToPartDefSingular {
        label = "test-singular";
        // Can we assign a ref target in the annotation?
        // If not, what error?
    }
    part def AnnotatedElementA {
        doc /* Test: applying metadata def with singular ref. */
        attribute elementName : String;
    }

    @TestRefToPartDefMulti {
        label = "test-multi";
        // Can we assign multi-valued ref targets?
    }
    part def AnnotatedElementB {
        doc /* Test: applying metadata def with multi-valued ref. */
        attribute elementName : String;
    }

    // -- TEST F: Mixed attributes and refs -------------------

    metadata def TestMixedAttributesAndRefs {
        doc /* Realistic pattern: a metadata def with both
             * String attributes and typed refs, mirroring the
             * likely structure of @Comprehension.
             *
             * If this test passes, it confirms the full pattern
             * needed for Step 3. */
        attribute label : String;
        attribute surfaceEnumValues : Boolean;
        attribute surfaceDomainInstantiations : Boolean;
        ref traversalTarget : TargetElement;
        ref traversalTargets : TargetElement[0..*];
        attribute traversalDepth : TraversalDepth;
    }

    @TestMixedAttributesAndRefs {
        label = "comprehension-pattern-test";
        surfaceEnumValues = true;
        surfaceDomainInstantiations = true;
        // ref assignment — will this work?
    }
    part def AnnotatedElementC {
        doc /* Test: applying mixed metadata def. */
        attribute elementName : String;
    }
}
