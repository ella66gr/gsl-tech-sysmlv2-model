// =========================================================================
// SYNTAX TEST: cross-file nested import and one-way ref (OP-132, S515)
//
// Purpose: Verify that Syside resolves
//   (a) private import Outer::Inner::*; across files, where Inner is a
//       package nested inside another top-level package; and
//   (b) a ref from a part def here to a part def in that other top-level
//       package, which does not import this package back.
//
// Pair: test-nested-package-target.sysml.
//
// Shape mirrored: SystemMetamodelGeneral::DomainConfigurationTypes, whose
// DomainConfiguration keeps ref domainIdentity : DomainIdentity, and a
// tenant DomainRegistration package holding the instance pair
// (package map, step 10).
//
// What to check:
//   1. The import line raises no unresolved-name error.
//   2. ref target : NestedTarget resolves through the import.
//   3. The instance pair below parses, including :>> on the ref.
//   4. Neither file shows an error in Model Validation.
// =========================================================================

package SyntaxTestNestedConsumer {
    private import ScalarValues::*;
    private import SyntaxTestNestedOuter::SyntaxTestNestedInner::*;

    doc /* Consumer package standing in for SystemMetamodelGeneral. */

    package SyntaxTestConsumerInner {
        doc /* Inner package standing in for DomainConfigurationTypes. */

        part def ConsumerHolder {
            doc /* Stands in for DomainConfiguration. One-way ref to a
                 * part def in another top-level package. */
            attribute holderName : String;
            ref target : NestedTarget;
        }
    }

    package SyntaxTestRegistration {
        doc /* Stands in for a tenant DomainRegistration package. */
        private import SyntaxTestNestedConsumer::SyntaxTestConsumerInner::*;

        part testTarget : NestedTarget {
            :>> targetName = "Test target";
            :>> kind = NestedKind::alpha;
        }

        part testHolder : ConsumerHolder {
            :>> holderName = "Test holder";
            :>> target = testTarget;
        }
    }
}
