// =========================================================================
// SYNTAX TEST: ref targeting metadata def, enum def, and action def types
//
// Purpose: Can a part def hold `ref x : SomeMetadataDef`?
//          Can a part def hold `ref x : SomeEnumDef`?
//          These patterns are needed for the PatternCatalogue to hold
//          typed references to heterogeneous model elements.
//
// Context: Concept Graph workstream (Session 30).
//          Workstream plan §3.1 — resolving how patterns reference
//          heterogeneous meta model elements.
//
// Imports: Uses real project types from Foundation::MetadataLibrary.
//
// What to check:
//   1. Does `ref x : ClinicalReviewGate;` parse? (ref to metadata def)
//   2. Does `ref x : AgencyType;` parse? (ref to enum def)
//   3. Does `ref x : ClinicalReviewGate[0..*];` parse? (multi-valued)
// =========================================================================

package SyntaxTestRefToMetadataDef {
    private import ScalarValues::*;
    private import Foundation::MetadataLibrary::*;

    doc /* Syntax test: ref targeting metadata def and enum def types.
         * Session 30 — Concept Graph workstream Stage 1. */

    // --- Test A: ref to a metadata def (singular) ---

    part def TestRefToMetadataSingular {
        doc /* Can a part def hold a ref typed by a metadata def? */
        attribute holderName : String;
        ref relatedMetadata : ClinicalReviewGate;
    }

    // --- Test B: ref to a metadata def (multi-valued) ---

    part def TestRefToMetadataMulti {
        doc /* Can a part def hold a multi-valued ref to a metadata def? */
        attribute holderName : String;
        ref relatedMetadataList : ClinicalReviewGate[0..*];
    }

    // --- Test C: ref to an enum def (singular) ---

    part def TestRefToEnumSingular {
        doc /* Can a part def hold a ref typed by an enum def?
             * Note: this is different from `attribute x : EnumDef`
             * which is a value. A ref would be a reference to the
             * enum definition itself — semantically odd but
             * syntactically interesting. */
        attribute holderName : String;
        ref relatedEnum : AgencyType;
    }

    // --- Test D: ref to an enum def (multi-valued) ---

    part def TestRefToEnumMulti {
        doc /* Multi-valued ref to an enum def. */
        attribute holderName : String;
        ref relatedEnumList : AgencyType[0..*];
    }
}
