package ExposeTests {
    private import ScalarValues::*;

    doc /* VERIFIED — Session 43, 19 March 2026. All sub-tests pass.
         *
         * Test Case 3: View with expose.
         * Session 43, Stage 2 Phase 5 investigation.
         *
         * Question: Does expose work to select elements from other packages?
         * From BNF: expose follows MembershipImport | NamespaceImport syntax.
         *
         * Test 3a: expose with wildcard (namespace import form).
         * Test 3b: expose with named element (membership import form).
         * Test 3c: expose from a sibling package.
         */

    // Local packages to expose from
    package SampleDomain {
        part def Widget {
            doc /* A sample widget for testing expose. */
            attribute widgetName : String;
        }
        part def Gadget {
            doc /* A sample gadget for testing expose. */
            attribute gadgetName : String;
        }
    }

    package AnotherDomain {
        part def Sprocket {
            doc /* A sample sprocket in a second package. */
            attribute sprocketSize : Integer;
        }
    }

    // --- Test 3a: wildcard expose ---
    view allDomainView {
        doc /* View exposing all members of SampleDomain. */
        expose SampleDomain::*;
    }

    // --- Test 3b: named expose ---
    // (comment out if 3a fails)
    view widgetOnlyView {
        doc /* View exposing only Widget from SampleDomain. */
        expose SampleDomain::Widget;
    }

    // --- Test 3c: expose from multiple packages ---
    // (comment out if 3a or 3b fail)
    view crossPackageView {
        doc /* View exposing elements from two sibling packages. */
        expose SampleDomain::*;
        expose AnotherDomain::*;
    }
}
