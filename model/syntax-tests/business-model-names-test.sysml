// =========================================================================
// SYNTAX TEST: Business Model attribute name safety check
// Purpose: Verify that proposed attribute names are not reserved/shadowed
// Date: 10 March 2026 (Session 14, Phase 1 pre-flight)
// Action: Delete after verification
// =========================================================================

package BusinessModelNamesTest {
    private import ScalarValues::*;

    part def NameTest {
        // Known safe (used elsewhere in model):
        attribute name : String;
        attribute description : String;
        attribute type : String;              // confirmed safe v3.7

        // Need verification:
        attribute channel : String;           // could be KerML keyword?
        attribute level : String;             // could be KerML keyword?
        attribute source : String;            // likely safe
        attribute target : String;            // likely safe
        attribute scope : String;             // likely safe
        attribute basis : String;             // likely safe
        attribute route : String;             // likely safe (used in Prescription already)
        attribute direction : String;         // safe (used in Referral already)
    }
}
