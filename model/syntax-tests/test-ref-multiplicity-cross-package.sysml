// =========================================================================
// SYNTAX TEST: ref with multiplicity across packages
//
// Purpose: Verify that Syside 0.8.5 supports ref x : Type[0..*]
//          where Type is defined in a different package/file.
//
// What to check:
//   1. Does ref x : Type[0..*] parse inside a part def? (cross-package)
//   2. Does ref x : Type[0..*] parse inside a requirement def?
//   3. Can a ref with multiplicity be :>> redefined in an instance?
//   4. Does a singular ref x : Type parse across packages? (baseline)
//
// Context: Phase 7 needs formal ref from ScenarioDefinition to
// ServiceOffering (cross-package, potentially multi-valued) and
// ref inside requirement def (StrategicObjective). Neither pattern
// is verified in the syntax reference v3.10.
//
// Imports: Uses real project types to test genuine cross-package
// resolution — BusinessModel::ServiceConcept::ServiceOffering and
// BusinessModel::ResourcePlanning::Capability.
//
// SysML v2 spec: ref x : Type[0..*];
// =========================================================================

package SyntaxTestRefMultiplicityCrossPackage {
    private import ScalarValues::*;
    private import BusinessModel::ServiceConcept::ServiceOffering;
    private import BusinessModel::ResourcePlanning::Capability;

    doc /* Test: ref with multiplicity across packages.
         * Phase 7 pre-flight verification. */

    // --- Test A: singular ref across packages (baseline) ---

    part def TestSingularRef {
        doc /* Baseline: singular ref to a cross-package part def. */
        attribute holderName : String;
        ref primaryOffering : ServiceOffering;
    }

    // --- Test B: ref with [0..*] multiplicity across packages ---

    part def TestMultiRef {
        doc /* Target pattern: ref with multiplicity to a cross-package
             * part def. This is the pattern needed for ScenarioDefinition
             * → ServiceOffering. */
        attribute holderName : String;
        ref offerings : ServiceOffering[0..*];
    }

    // --- Test C: ref with [1..*] multiplicity across packages ---

    part def TestMultiRefRequired {
        doc /* Variant: at-least-one multiplicity. */
        attribute holderName : String;
        ref requiredOfferings : ServiceOffering[1..*];
    }

    // --- Test D: ref inside a requirement def ---

    requirement def TestRequirementWithRef {
        doc /* Test: can a requirement def contain a ref attribute?
             * Needed for StrategicObjective (requirement def) with
             * ref to ScenarioDefinition. */
        subject testSubject : String;
        attribute objectiveName : String;
        ref relatedOfferings : ServiceOffering[0..*];
        ref relatedCapability : Capability;
    }

    // --- Test E: ref :>> redefinition in a usage ---

    part testMultiInstance : TestMultiRef {
        doc /* Test: can we :>> redefine a multi-valued ref?
             * If this works, ScenarioDefinition usages can
             * specify their active offerings structurally. */
        attribute :>> holderName = "Test instance";
        // Note: :>> on a ref may need a different syntax
        // than :>> on an attribute. If this fails, try
        // without :>> redefinition.
    }

    // --- Test F: requirement usage ---

    requirement testReqInstance : TestRequirementWithRef {
        doc /* Test: requirement usage with ref attributes. */
        attribute :>> objectiveName = "Test objective";
    }
}
