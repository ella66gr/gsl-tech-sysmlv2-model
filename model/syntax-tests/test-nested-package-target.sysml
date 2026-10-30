// =========================================================================
// SYNTAX TEST: two-level nested package, target side (OP-132, S515)
//
// Purpose: Verify that Syside resolves a package nested two levels deep
//          when another file imports it with
//          private import Outer::Inner::*;
//
// Pair: test-nested-package-consumer.sysml imports this file. This file
// imports nothing from the consumer (the one-way direction the package
// map's rule R3 requires).
//
// Shape mirrored: BusinessMetamodelGeneral::DomainIdentityTypes holding
// DomainIdentity and its enums (package map, step 10).
//
// What to check:
//   1. Does a package nested inside a top-level package parse?
//   2. Do the part def and enum def inside it parse?
//   3. Does the consumer file resolve them (no errors in either file)?
// =========================================================================

package SyntaxTestNestedOuter {
    private import ScalarValues::*;

    doc /* Outer package standing in for BusinessMetamodelGeneral. */

    package SyntaxTestNestedInner {
        doc /* Inner package standing in for DomainIdentityTypes. */

        enum def NestedKind {
            enum alpha;
            enum beta;
        }

        part def NestedTarget {
            doc /* Stands in for DomainIdentity. It holds no reference
                 * to the consumer's part def. */
            attribute targetName : String;
            attribute kind : NestedKind;
        }
    }
}
