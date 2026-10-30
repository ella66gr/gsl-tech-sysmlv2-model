// =========================================================================
// GSL DOMAIN REGISTRATION — tenant domain registration
// =========================================================================
//
// OP-132 step 10 (S515, ADR-012 group H). The DomainIdentity (BMG) and
// DomainConfiguration (SMG) instances for this tenant, formerly in
// Foundation's DomainRegistry. The pair is linked one way, from the
// configuration to the identity (Action 2).
// =========================================================================

package GslDomainRegistration {
    private import BusinessMetamodelGeneral::DomainIdentityTypes::*;
    private import SystemMetamodelGeneral::DomainConfigurationTypes::*;

    // --- GSL (GenderSense Limited) ------------------------------

    part gslIdentity : DomainIdentity {
        doc /* Production domain — GenderSense Limited, a private
             * gender-affirming healthcare service. The primary
             * motivating use case and first production tenant.
             * Sector-regulated (CQC). Practitioners hold statutory
             * professional registrations (GMC, NMC). Authorisation
             * required to trade (CQC registration is a precondition
             * to lawful provision). Under A13, GSL is the most
             * important tenant but still a tenant — not structurally
             * privileged over demonstrator domains. */

        attribute :>> regulatoryShape = RegulatoryShape::sectorRegulated;
        attribute :>> bmmVocabularyScope = BmmVocabularyScope::production;
        attribute :>> domainPurpose = DomainPurpose::production;
        attribute :>> jurisdiction = Jurisdiction::england;
        attribute :>> regulatedActivities = (RegulatedActivity::treatment, RegulatedActivity::diagnosticAndScreeningProcedures);
        attribute :>> professionalRegistrations = (ProfessionalBody::gmc, ProfessionalBody::nmc);
        attribute :>> organisationalForm = OrganisationalForm::registeredIndividual;
        attribute :>> authorisationRequiredToTrade = true;
        attribute :>> description = "Production domain — GenderSense Limited. Private gender-affirming healthcare service. First production tenant.";
        attribute :>> introducedSession = 8;
    }

    part gslConfiguration : DomainConfiguration {
        attribute :>> canonicalKey = "gsl";
        attribute :>> displayLabel = "GSL";
        attribute :>> fullName = "GenderSense Limited";
        attribute :>> packageName = "GenderSense";
        attribute :>> modelPath = "exercises/gendersense/model";
        attribute :>> isActive = true;
        ref :>> domainIdentity = gslIdentity;
    }
}
