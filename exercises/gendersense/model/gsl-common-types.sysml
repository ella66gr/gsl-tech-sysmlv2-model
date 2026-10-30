// =========================================================================
// GSL COMMON TYPES — GenderSense value types with no consumer yet
// =========================================================================
//
// OP-132 step 11 (S515, ADR-012 group J4). The six items left in Foundation's
// CommonTypes after every other group found its home: Gender,
// ContactMethod, AppointmentType, ConsentStatus, Address, ContactDetails.
// Nothing in any model consumes them today; they stay with GSL, where they
// came from, and are listed as SMG candidates (ADR-012 §8). ConsentStatus
// is for Saskia to see before any promotion. foundation.sysml is deleted.
// =========================================================================

package GslCommonTypes {
    private import ScalarValues::*;

    doc /* GenderSense value types: clinical (Gender, AppointmentType),
         * governance (ConsentStatus) and generic (ContactMethod, Address,
         * ContactDetails). Candidates for promotion once a second tenant
         * consumes them; none does yet. */

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
