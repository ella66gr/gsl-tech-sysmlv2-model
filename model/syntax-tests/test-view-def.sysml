package ViewDefTests {
    private import ScalarValues::*;

    doc /* VERIFIED — Session 43, 19 March 2026. All sub-tests pass.
         *
         * Test Case 2: Minimal view def and view usage.
         * Session 43, Stage 2 Phase 5 investigation.
         *
         * Question: Does Syside 0.8.5 parse view def and view usage?
         *
         * Test 2a: bare view def with doc block only.
         * Test 2b: view usage typed by a view def.
         * Test 2c: view usage without a typing view def.
         */

    // --- Test 2a: bare view def ---
    view def GovernanceView {
        doc /* A view definition for presenting governance-related
             * model elements to compliance stakeholders.
             *
             * System meta model concept. */
    }

    // --- Test 2b: view usage typed by view def ---
    // (comment out if 2a fails)
    view governanceOverview : GovernanceView {
        doc /* Concrete governance overview for the Ontara system. */
    }

    // --- Test 2c: untyped view usage ---
    // (comment out if 2a fails)
    view simpleView {
        doc /* A standalone view without a typing view def. */
    }
}
