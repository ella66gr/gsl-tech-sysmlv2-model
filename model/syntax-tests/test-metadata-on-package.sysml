// =========================================================================
// E003 Syntax Spike — @PurposiveDescription on package declarations
// =========================================================================
//
// Question: Can a SysML package carry a @PurposiveDescription annotation
// in Syside 0.8.5?
//
// If this parses: E003 implementation proceeds with package-level
// annotations. The generator extends to extract them, and the console
// glossary displays concern-level explanatory text.
//
// If this fails: fallback to doc-block marker approach (see E003 plan).
//
// Session 58 (22 March 2026). Source: Emergent Ideas Log E003.
//
// RESULT: VERIFIED — both tests parse cleanly in Syside 0.8.5.
// @PurposiveDescription on package declarations works at top level
// and nested. E003 implementation proceeds with annotation approach.
// =========================================================================

package TestPackageAnnotation {
    private import ScalarValues::*;
    private import Foundation::MetadataLibrary::*;

    // --- Test 1: annotation on a top-level package ---

    @PurposiveDescription {
        description = "Test: can a top-level package carry a purposive description annotation?";
    }
    package TestTopLevelPackage {
        private import ScalarValues::*;

        part def TestElementA {
            attribute name : String;
        }
    }

    // --- Test 2: annotation on a nested sub-package ---

    package TestOuterPackage {
        private import ScalarValues::*;

        @PurposiveDescription {
            description = "Test: can a nested sub-package carry a purposive description annotation?";
        }
        package TestNestedPackage {
            private import ScalarValues::*;

            part def TestElementB {
                attribute name : String;
            }
        }
    }
}
