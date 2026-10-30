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
             * Generally governed (no sector-specific regulation,
             * no licensing regime, no role-binding professional
             * body). Subject only to general business law. */

        attribute :>> regulatoryShape = RegulatoryShape::generallyGoverned;
        attribute :>> bmmVocabularyScope = BmmVocabularyScope::full;
        attribute :>> domainPurpose = DomainPurpose::referenceValidation;
        attribute :>> jurisdiction = Jurisdiction::england;
        attribute :>> organisationalForm = OrganisationalForm::registeredIndividual;
        attribute :>> authorisationRequiredToTrade = false;
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
