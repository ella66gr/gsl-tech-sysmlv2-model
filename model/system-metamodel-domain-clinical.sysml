// =========================================================================
// SYSTEM METAMODEL DOMAIN — CLINICAL
// =========================================================================
//
// OP-132 step 7 (S515, ADR-012 §4.2, group B). The clinical-sector Domain
// package on the system side. Holds @ClinicalReviewGate, formerly in
// Foundation's MetadataLibrary (clinical by meaning, ADR-011 §4.7). Imports
// are limited by rule R2: General, apparatus, and Domain packages of the
// clinical sector only.
// =========================================================================

package SystemMetamodelDomainClinical {
    private import ScalarValues::*;

    doc /* System-side metamodel vocabulary that is clinical by meaning
         * but not specific to one tenant. First member: the
         * @ClinicalReviewGate pathway-step annotation. Consumers are
         * clinical tenants (GSL pathways and constraints). */

    metadata def ClinicalReviewGate {
        doc /* Marks a pathway step as requiring clinical review
             * before proceeding. Generates a human-task wait point
             * in the orchestration layer. */
        attribute reviewerRole : String;
        attribute reviewCriteria : String;
    }
}
