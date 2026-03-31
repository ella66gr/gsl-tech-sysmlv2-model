package ViewpointTests {
    private import ScalarValues::*;

    doc /* MIXED — Session 43, 19 March 2026.
         * Test 1a: VERIFIED (bare viewpoint def parses cleanly).
         * Test 1b: FAILED (frame concern triggers subject parameter error).
         * Test 1c: FAILED (stakeholder cascades from 1b; needs isolation test).
         * Tests 1b and 1c commented out to keep file parseable.
         * Syside visualizer renders viewpoint def correctly (ViewpointCheck).
         *
         * Test Case 1: Minimal viewpoint def.
         * Session 43, Stage 2 Phase 5 investigation.
         *
         * Question: Does Syside 0.8.5 parse a basic viewpoint def?
         * Viewpoints are structurally requirement defs (BNF Clause 8.2.2.26.3).
         *
         * Test 1a: bare viewpoint def with doc block only.
         * Test 1b: viewpoint def with frame concern.
         * Test 1c: viewpoint def with stakeholder.
         */

    // --- Test 1a: bare viewpoint def with doc only ---
    viewpoint def GovernanceViewpoint {
        doc /* Viewpoint for stakeholders concerned with
             * regulatory compliance and audit evidence.
             *
             * System meta model concept. */
    }

    // --- Test 1b: viewpoint def with frame concern ---
    // FAILED — frame concern triggers subject parameter error.
    // Commented out to keep file parseable.
    //
    // viewpoint def ComprehensionViewpoint {
    //     doc /* Viewpoint for non-specialist users who need
    //          * to understand the system in lay terms. */
    //
    //     frame concern comprehensionConcern {
    //         doc /* Can a non-specialist understand what each
    //              * component does and why it exists? */
    //     }
    // }

    // --- Test 1c: viewpoint def with stakeholder ---
    // FAILED — stakeholder cascades from 1b; needs isolation test.
    // Commented out to keep file parseable.
    //
    // viewpoint def ArchitectViewpoint {
    //     doc /* Viewpoint for the system architect who needs
    //          * to see structural relationships and coverage. */
    //
    //     stakeholder architectRole {
    //         doc /* The system architect responsible for
    //              * meta model coherence and coverage. */
    //     }
    // }
}
