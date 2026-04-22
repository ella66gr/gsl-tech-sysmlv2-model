// =========================================================================
// SYNTAX TEST: nested :>> redefinition inside contained part usages
//
// Purpose: Can a part usage redefine its inherited attributes with :>>
//          AND contain further part usages whose own :>> redefinitions
//          target members inherited into the inner part?
//
//          This is the central syntactic question for the W-094 first
//          implementation (multi-axis status primitive, Session 253).
//          The S253 specification places the platform-provided
//          epistemicAxis inside CanonicalRuntimeType as a nested part
//          usage of StatusAxis, where the outer usage redefines axis
//          metadata (axisName, defaultValue, etc.) AND contains further
//          part usages (the value space, the platform-defined
//          transitions) that themselves redefine their own inherited
//          members.
//
//          If this pattern works, the S253 specification can be
//          modelled directly (composition — owned parts). If it fails,
//          the implementation must flatten: value spaces and transitions
//          become top-level part usages referenced from the axis via
//          ref :>> tuple syntax (the verified v3.13 alternative).
//
// Context: Ontara Session 255, W-094 first implementation. Carries
//          forward the "Not yet tested" entry at the foot of the
//          syntax reference v3.19: "Nested :>> redefinition inside
//          contained parts inside part usages."
//
// Prior art (all from syntax reference, confirmed working):
//   - :>> attribute redefinition on part usage: ✅ verified (§2, v3.5)
//   - :>> redefinition with multi-valued enum tuple: ✅ verified (v3.19)
//   - ref :>> tuple redefinition: ✅ verified (§2, v3.13)
//   - part def specialisation :>: ✅ verified (§2, throughout)
//   - Recursive self-containment via part: ✅ verified (§2, v3.5)
//   - Nested :>> inside contained parts inside part usages: ❓ NOT TESTED
//
// Naming note: `shape` shadows Items::Item::shape (standard library
//   inheritance through part def → Parts::Part → Items::Item) and
//   triggers namespace-distinguishability. Renamed to `valueShape`.
//   `members` and `container` and `label` similarly renamed to
//   compound forms to avoid further standard-library collisions.
//   Attribute and part names that have clean compound forms chosen
//   throughout: valueShape, enumValues, innerContainer, innerMembers,
//   fromValue, toValue, transitionLabel, outerName, outerScope.
//
// What to check in Syside:
//   TEST A: outer :>> on attribute, inner part with own :>> on attribute
//   TEST B: TEST A plus additional inner contained parts redefining
//           their own attributes (tests multiple inner :>> siblings)
//   TEST C: inner :>> with multi-valued tuple syntax (combines nesting
//           with v3.19 multi-valued tuple redefinition)
//
// Expected errors if nested :>> is NOT supported:
//   - "Unexpected token" at the inner part body
//   - "Cannot redefine X in this context"
//   - "feature-chaining-redefinition-uniqueness" or similar
//   - Silent ignore of inner :>> (member not actually redefined);
//     look in Syside Outliner for whether the inner part carries the
//     redefined values
//
// Verification status: PENDING — run in Syside Modeler 0.8.5 and
//   record outcome at foot of file. If VERIFIED, update syntax
//   reference TODO list; drop the "Not yet tested" entry and add
//   `shape` to the reserved/shadowed-name list in §10.
// =========================================================================

package TestNestedRedefinition {
    private import ScalarValues::*;

    // Base vocabulary for the tests

    enum def TestShape {
        shapeAlpha;
        shapeBeta;
        shapeGamma;
    }

    part def TestContainer {
        doc /* Mirrors ValueSpace in the real implementation:
             * holds an enum-typed attribute and a multi-valued
             * String attribute.
             *
             * `valueShape` (not `shape`) to avoid standard-library
             * Items::Item::shape collision. */
        attribute valueShape : TestShape;
        attribute enumValues : String[0..*];
    }

    part def TestMember {
        doc /* Mirrors AxisTransition: a small part def with a few
             * simple attributes that can be redefined at the usage
             * site. */
        attribute fromValue : String;
        attribute toValue : String;
        attribute transitionLabel : String;
    }

    part def TestOuter {
        doc /* Mirrors StatusAxis: has a String attribute (like
             * axisName), an enum-typed attribute (like axisScope),
             * a contained part typed by TestContainer (like
             * valueSpace), and a multi-valued contained part typed
             * by TestMember (like permittedTransitions). */
        attribute outerName : String;
        attribute outerScope : TestShape;
        part innerContainer : TestContainer;
        part innerMembers : TestMember[0..*];
    }

    // =====================================================================
    // TEST A — Outer :>> on attribute, inner part with own :>> on attribute
    // =====================================================================

    part testAOuter : TestOuter {
        :>> outerName = "testA";
        :>> outerScope = TestShape::shapeAlpha;

        // Inner contained part with its own :>> on attributes.
        // This is the UNVERIFIED pattern.
        part :>> innerContainer : TestContainer {
            :>> valueShape = TestShape::shapeAlpha;
            :>> enumValues = ("v1", "v2", "v3");
        }
    }

    // =====================================================================
    // TEST B — Multiple inner contained parts coexisting with own :>>
    // =====================================================================

    part testBOuter : TestOuter {
        :>> outerName = "testB";
        :>> outerScope = TestShape::shapeBeta;

        part :>> innerContainer : TestContainer {
            :>> valueShape = TestShape::shapeBeta;
            :>> enumValues = ("a", "b", "c");
        }

        // Additional inner parts (these populate the multi-valued
        // `innerMembers` slot of TestOuter). Each has its own :>> on
        // its attributes. Mirrors the per-transition pattern in
        // CanonicalRuntimeType.epistemicAxis.
        part memberOne : TestMember {
            :>> fromValue = "a";
            :>> toValue = "b";
            :>> transitionLabel = "a to b";
        }

        part memberTwo : TestMember {
            :>> fromValue = "b";
            :>> toValue = "c";
            :>> transitionLabel = "b to c";
        }

        part memberThree : TestMember {
            :>> fromValue = "c";
            :>> toValue = "a";
            :>> transitionLabel = "c back to a";
        }
    }

    // =====================================================================
    // TEST C — Inner :>> with multi-valued tuple (combines v3.19 + nesting)
    // =====================================================================

    part testCOuter : TestOuter {
        :>> outerName = "testC";
        :>> outerScope = TestShape::shapeGamma;

        // Multi-valued tuple redefinition on the inner contained part.
        // Exercises v3.19 tuple syntax inside the unverified nesting
        // pattern.
        part :>> innerContainer : TestContainer {
            :>> valueShape = TestShape::shapeGamma;
            :>> enumValues = ("one", "two", "three", "four", "five");
        }
    }
}

// =========================================================================
// Verification notes (to be filled in after Syside run):
//
// Date:
// Syside version:
// Outcome for TEST A:
// Outcome for TEST B:
// Outcome for TEST C:
// Errors observed (copied verbatim):
// Action for syntax reference:
// Action for canonical-runtime.sysml:
//
// =========================================================================
