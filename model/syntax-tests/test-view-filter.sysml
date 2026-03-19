package FilterTests {
    private import ScalarValues::*;

    doc /* VERIFIED — Session 43, 19 March 2026. All sub-tests pass.
         *
         * Test Case 4: View with filter expression.
         * Session 43, Stage 2 Phase 5 investigation.
         *
         * Question: Does filter work within a view body?
         * From BNF: filter takes an OwnedExpression (ElementFilterMember).
         *
         * Test 4a: trivial filter (true).
         * Test 4b: filter with metadata annotation check.
         *
         * Note: The exact expression language for filter is not well
         * documented. We test increasingly specific forms to find
         * what the parser accepts.
         */

    // Local elements to filter
    package SampleElements {
        metadata def SampleTag {
            doc /* A tag for testing filter expressions. */
            attribute tagLabel : String;
        }

        part def AlphaComponent {
            @SampleTag { tagLabel = "governance"; }
            doc /* Tagged component. */
            attribute componentName : String;
        }

        part def BetaComponent {
            doc /* Untagged component. */
            attribute componentName : String;
        }
    }

    // --- Test 4a: trivial filter ---
    view trivialFilterView {
        doc /* View with a trivially true filter. */
        expose SampleElements::*;
        filter true;
    }

    // --- Test 4b: filter by metadata presence ---
    // (comment out if 4a fails)
    // NOTE: The exact syntax for metadata-based filtering is uncertain.
    // This is our best guess from the spec. If it fails, that is a
    // useful finding in itself.
    view metadataFilterView {
        doc /* View filtering by metadata annotation. */
        expose SampleElements::*;
        filter @SampleElements::SampleTag;
    }
}
