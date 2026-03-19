package CrossPackageViewTests {
    private import ScalarValues::*;
    private import BusinessModel::GovernanceMapping::*;

    doc /* VERIFIED — Session 43, 19 March 2026. All sub-tests pass.
         *
         * Test Case 6: Cross-package view exposing real model elements.
         * Session 43, Stage 2 Phase 5 investigation.
         *
         * Question: Can a view expose elements from a separate model
         * package? This simulates the real Ontara use case: a view
         * selecting BMM elements for presentation in the console.
         *
         * Test 6a: expose from BusinessModel::GovernanceMapping.
         * Test 6b: expose from multiple BMM sub-packages.
         *
         * Depends on: Tests 2 and 3 passing (view def and expose).
         */

    // --- Test 6a: expose from a single real model package ---
    view governanceElementsView {
        doc /* View exposing governance elements from the BMM. */
        expose BusinessModel::GovernanceMapping::*;
    }

    // --- Test 6b: expose from multiple real model packages ---
    // (comment out if 6a fails)
    view financialAndGovernanceView {
        doc /* View combining elements from two BMM sub-packages. */
        expose BusinessModel::GovernanceMapping::*;
        expose BusinessModel::FinancialPlanning::*;
    }
}
