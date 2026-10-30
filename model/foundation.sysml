// =========================================================================
// FOUNDATION — Cross-cutting infrastructure imported by everything else
// =========================================================================

package Foundation {
    private import ScalarValues::*;

    doc /* RESIDUAL PACKAGE — being dissolved by meaning (ADR-011 §4.7,
         * decision 7; OP-125 canon pass Step 2, S514).
         *
         * The name reads as the Ontology Foundation Layer, which holds
         * only published ontologies, and the package put tenant-specific
         * vocabulary in a folder every tenant imports (against A13). So
         * every item is to move to where its meaning puts it. At S514:
         *
         *   - the generators' annotation schema (@CatalogueTag, @UserFacing,
         *     @PurposiveDescription, @Comprehension, @WeightedRelationship,
         *     RelationshipStrength, @BfoType) moved to the new top-level
         *     package ProjectionMetadata (model/projection-metadata.sysml);
         *   - the four OutcomeFramework enumerations (OutcomeCategory,
         *     OutcomeStatus, MeasurementFrequency, ComparisonOperator)
         *     moved into Knowledge::OutcomeFramework, their only user;
         *   - the empty GenerationPipeline package was deleted.
         *
         * Everything still here is an item whose home is genuinely
         * doubtful under Ella's S514 rule (move only where the meaning
         * gives a clear home; never guess). Each is listed, with the
         * reason, in session-514-op-125-canon-pass-step2-reese.md and
         * awaits her allocation. Nothing here should be read as "shared
         * vocabulary of the entire model" any longer. */

    package CommonTypes {
        private import ScalarValues::*;

        doc /* Shared data types, enumerations, units of measure, and
             * value types used across the model. */

        enum def Gender {
            doc /* Gender identity as recorded for clinical purposes. */
            male;
            female;
            nonBinary;
            other;
            notStated;
        }

        enum def ContactMethod {
            doc /* Preferred method of contact. */
            email;
            phone;
            sms;
            secureMessage;
            post;
        }

        enum def AppointmentType {
            doc /* Type of clinical appointment. */
            faceToFace;
            video;
            telephone;
            asynchronous;
        }

        // Added Session 81: StakeholderModel enums

        enum def ConsentStatus {
            doc /* Status of a consent record. */
            given;
            withdrawn;
            notYetObtained;
            declined;
        }

        part def Address {
            doc /* A postal address. */
            attribute line1 : String;
            attribute line2 : String;
            attribute city : String;
            attribute postcode : String;
            attribute country : String;
        }

        part def ContactDetails {
            doc /* Contact information for a person or organisation. */
            attribute email : String;
            attribute phone : String;
            attribute preferredMethod : ContactMethod;
        }

    }

}
