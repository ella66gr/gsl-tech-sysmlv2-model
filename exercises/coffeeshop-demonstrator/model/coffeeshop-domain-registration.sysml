// =========================================================================
// COFFEE SHOP DOMAIN REGISTRATION — tenant domain registration
// =========================================================================
//
// OP-132 step 10 (S515, ADR-012 group H). The DomainIdentity (BMG) and
// DomainConfiguration (SMG) instances for this tenant, formerly in
// Foundation's DomainRegistry. The pair is linked one way, from the
// configuration to the identity (Action 2).
// =========================================================================

package CoffeeShopDomainRegistration {
    private import BusinessMetamodelGeneral::DomainIdentityTypes::*;
    private import SystemMetamodelGeneral::DomainConfigurationTypes::*;

    // ============================================================
    // Domain instances
    // ============================================================
    // Each domain has a DomainIdentity (BMM) and a
    // DomainConfiguration (SMM), cross-referenced via
    // bidirectional ref :>> redefinitions.

    // --- Cafe (Coffee Shop) ------------------------------------

    part cafeIdentity : DomainIdentity {
        doc /* Reference validation domain — the original demonstrator
             * against which all meta model patterns were first
             * developed. Immediate retail, walk-in, 2-minute cycle.
             *
             * Shape: generallyGoverned. No sector regulator, no
             * licence or permit that an authority can refuse or
             * withdraw, and no role-binding professional body. The
             * shape follows authorisation, not registration (S518).
             * Food business registration is a notification the local
             * authority cannot refuse (S515), so it leaves
             * authorisationRequiredToTrade false and is recorded, with
             * the HACCP duty, on regulatedActivities.
             *
             * The shape depends on the modelled trading pattern: fixed
             * premises, no hot food or drink sold between 23:00 and
             * 05:00, no alcohol, and no street trading. Any of those
             * would need a licence the authority can refuse, and would
             * move the shape.
             *
             * Vocabulary scope: generalOnly. The Cafe is configured from
             * the General metamodels alone, with no Domain module
             * (S515 D5). */

        attribute :>> regulatoryShape = RegulatoryShape::generallyGoverned;
        attribute :>> bmmVocabularyScope = BmmVocabularyScope::generalOnly;
        attribute :>> domainPurpose = DomainPurpose::referenceValidation;
        attribute :>> jurisdiction = Jurisdiction::england;
        attribute :>> organisationalForm = OrganisationalForm::registeredIndividual;
        attribute :>> authorisationRequiredToTrade = false;
        attribute :>> regulatedActivities = RegulatedActivity::foodBusinessOperation;
        attribute :>> description = "Reference validation domain — original demonstrator. Immediate retail service with walk-in customers and 2-minute fulfilment cycle.";
        attribute :>> introducedSession = 1;
    }

    part cafeConfiguration : DomainConfiguration {
        attribute :>> canonicalKey = "cafe";
        attribute :>> displayLabel = "Cafe";
        attribute :>> fullName = "Cafe (Coffee Shop)";
        attribute :>> packageName = "CoffeeShop";
        attribute :>> modelPath = "exercises/coffeeshop-demonstrator/model";
        attribute :>> isActive = true;
        ref :>> domainIdentity = cafeIdentity;
    }
}
