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

        enum def ReferralDirection {
            doc /* Direction of a referral or referral pathway.
                 * Extended Session 81: bidirectional added for
                 * referral pathways where both directions operate
                 * (e.g. GP refers to GSL, GSL refers back to GP). */
            inbound;
            outbound;
            bidirectional;
        }

        // Added Session 81: StakeholderModel enums

        enum def RelationshipNature {
            doc /* Classification of the nature of a stakeholder
                 * relationship. Closed enum — tailored extensions
                 * can add domain-specific values via :>> redefinition
                 * (e.g. clinicalNetwork for healthcare).
                 *
                 * Business meta model concept. StakeholderModel (C7).
                 * Session 81. */
            regulatory;
            contractual;
            professional;
            advisory;
            commissioning;
            peer;
        }

        enum def DependencyCriticality {
            doc /* Classification of how critical an external
                 * dependency is to the business's operation.
                 * Drives contingency planning priority.
                 *
                 * Business meta model concept. StakeholderModel (C7).
                 * Session 81. */
            essential;
            important;
            convenient;
        }

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

        // -- Domain identity enums (Session 59 design, Session 142 extension,
        //                            Session 278 RegulatoryShape rebuild) --
        // Three original enums from Session 59 domain identity paper (B15).
        // Three new enums from Session 142 dual-stack extension (S142-D7).
        // RegulatoryTier renamed to RegulatoryShape and rebuilt from an
        // intensity scale to a kind-based classification at Session 278.
        // ProfessionalBody enum added Session 278.
        // All placed in CommonTypes for independent importability by
        // governance, generators, and other subsystems.

        enum def RegulatoryShape {
            doc /* Five-value kind-based classification of the principal
                 * governance frame applicable to a service business.
                 * Names what governs the business, not how much.
                 * Mutually exclusive and exhaustive for the principal
                 * regulatory frame; nuance carried on orthogonal
                 * supporting attributes (authorisationRequiredToTrade,
                 * professionalRegistrations, regulatedActivities).
                 *
                 * generallyGoverned: only general business law (consumer,
                 *   contract, H&S, employment, GDPR). No sector regulator,
                 *   no licensing regime, no role-binding professional body.
                 *   Example: Cafe.
                 * locallyLicensed: no sector regulator, but provision
                 *   requires a local-authority licence, environmental
                 *   permit, or sector-specific statutory duty (animal
                 *   welfare, COSHH, premises licence) beyond general law.
                 *   Example: Suds, Paws.
                 * professionalBodyRegulated: no sector regulator, but
                 *   practitioners are bound by membership-based
                 *   professional bodies (BACP, UKCP, ICF, BPS) whose
                 *   codes of ethics and complaint routes are the principal
                 *   governance frame. Example: Minds.
                 * statutoryProfessionRegulated: practitioners hold
                 *   statutory professional registration (GMC, NMC, HCPC,
                 *   GPhC) that the regulator can suspend or remove, but
                 *   the business itself is not within a sector-regulator
                 *   perimeter. Example: an independent advisory clinic
                 *   below CQC threshold.
                 * sectorRegulated: the business itself sits within a
                 *   sector regulator's perimeter (CQC, FCA, Ofsted, SRA,
                 *   Ofcom, EA). Authorisation/registration is required
                 *   to lawfully provide the core service.
                 *   Example: Ears, GSL.
                 *
                 * Renamed from RegulatoryTier and rebuilt at S278:
                 * the previous four-value intensity scale
                 * {generallyGoverned, lightlyRegulated, partiallyRegulated,
                 * sectorRegulated} muddled kind and intensity. The new
                 * vocabulary captures kind explicitly. partiallyRegulated
                 * is removed; mixed-services-with-regulated-components
                 * cases are now expressed by a non-empty regulatedActivities
                 * list on a tenant whose principal shape is one of the
                 * other values. lightlyRegulated → locallyLicensed for
                 * vocabulary precision. moderatelyRegulated — used in
                 * documentation but never in the SysML enum — is replaced
                 * by sectorRegulated for the Ears-shaped case.
                 *
                 * Business meta model concept. Domain identity (B15).
                 * Session 59, confirmed Session 142, rebuilt Session 278. */
            generallyGoverned;
            locallyLicensed;
            professionalBodyRegulated;
            statutoryProfessionRegulated;
            sectorRegulated;
        }

        enum def ProfessionalBody {
            doc /* Closed enum of recognised professional bodies whose
                 * registration or membership constitutes part of a
                 * tenant's regulatory shape. Used on the
                 * DomainIdentity.professionalRegistrations multi-valued
                 * attribute. Each entry carries an implicit category
                 * (statutory or membership-based) — see the value
                 * descriptions below; surfaced as documentation rather
                 * than a separate axis enum to keep one queryable list.
                 *
                 * Statutory bodies (registration that the regulator can
                 * suspend or remove, with statutory power):
                 *   gmc — General Medical Council (doctors, UK).
                 *   nmc — Nursing and Midwifery Council.
                 *   hcpc — Health and Care Professions Council.
                 *   gphc — General Pharmaceutical Council.
                 *   gdc — General Dental Council.
                 *   gosc — General Osteopathic Council.
                 *   gcc — General Chiropractic Council.
                 *   goc — General Optical Council.
                 *
                 * Membership-based bodies (membership of a body whose
                 * code of ethics binds the member by contract, with
                 * complaint routes and possible expulsion but no
                 * statutory removal of the right to practise):
                 *   bacp — British Association for Counselling and
                 *     Psychotherapy.
                 *   ukcp — UK Council for Psychotherapy.
                 *   icf — International Coaching Federation.
                 *   bps — British Psychological Society.
                 *   bcsh — British Council of Self-Hypnosis (placeholder
                 *     for analogous bodies — extend as encountered).
                 *
                 * Extension policy: add new values when first encountered
                 * by a tenant being modelled. Do not pre-populate.
                 *
                 * Business meta model concept. Domain identity (B15).
                 * Session 278. */
            gmc;
            nmc;
            hcpc;
            gphc;
            gdc;
            gosc;
            gcc;
            goc;
            bacp;
            ukcp;
            icf;
            bps;
            bcsh;
        }

        enum def BmmVocabularyScope {
            doc /* Which subset of the Business Meta Model vocabulary
                 * a domain instantiates.
                 * generalOnly: uses only General-level BMM elements.
                 * full: uses both General and Tailored elements.
                 * production: full vocabulary plus production-grade
                 *   governance, audit, and operational requirements.
                 *
                 * Business meta model concept. Domain identity (B15).
                 * Session 59, confirmed Session 142. */
            generalOnly;
            full;
            production;
        }

        enum def DomainPurpose {
            doc /* Why a domain exists in the Ontara platform.
                 * A domain may have multiple purposes (e.g. Paws is
                 * both pedagogicalAnchoring and crossDomainValidation).
                 *
                 * referenceValidation: the original demonstrator domain
                 *   against which patterns are first developed.
                 * crossDomainValidation: validates that meta model
                 *   concepts generalise beyond the reference domain.
                 * pedagogicalAnchoring: simple domain used to introduce
                 *   concepts and verify understanding.
                 * production: a real service business using the platform
                 *   for actual service delivery.
                 *
                 * Business meta model concept. Domain identity (B15).
                 * Session 59, confirmed Session 142 (S142-D6: multi-valued). */
            referenceValidation;
            crossDomainValidation;
            pedagogicalAnchoring;
            production;
        }

        enum def Jurisdiction {
            doc /* Territorial jurisdiction for governance framework
                 * applicability. Based on UK devolution structure — the
                 * primary governance frameworks Ontara supports have
                 * jurisdiction-specific scope. Extensible as the platform
                 * supports non-UK jurisdictions.
                 *
                 * Business meta model concept. Domain identity (B15).
                 * Session 142 (S142-D7). */
            england;
            scotland;
            wales;
            northernIreland;
            unitedKingdom;
        }

        enum def RegulatedActivity {
            doc /* Activities regulated by CQC under the Health and Social
                 * Care Act 2008. A service providing any of these must be
                 * registered with CQC. Used during governance framework
                 * activation to determine directive applicability.
                 *
                 * Source: HSCA 2008 (Regulated Activities) Regulations 2014,
                 * Schedule 1.
                 *
                 * Business meta model concept. Domain identity (B15).
                 * Session 142 (S142-D7). */
            personalCare;
            accommodationForPersonsRequiringNursingOrPersonalCare;
            accommodationForPersonsRequiringTreatmentForSubstanceMisuse;
            treatment;
            assessmentOrMedicalTreatmentForPersonsDetainedUnderMentalHealthAct;
            surgicalProcedures;
            diagnosticAndScreeningProcedures;
            managementOfSupplyOfBloodAndBloodDerivedProducts;
            transportServicesTimedAndUntimed;
            maternity;
            terminationOfPregnancies;
            familyPlanning;
            nursingCare;
        }

        enum def OrganisationalForm {
            doc /* The legal/organisational form of a service provider.
                 * Some governance directives apply only to specific forms
                 * (e.g. "body corporate" provisions in CQC regulations).
                 *
                 * Source: CQC registration requirements; Companies Act 2006.
                 *
                 * Business meta model concept. Domain identity (B15).
                 * Session 142 (S142-D7). */
            registeredIndividual;
            partnership;
            organisation;
            bodyCorporate;
        }
    }

    package DomainRegistry {
        private import ScalarValues::*;
        private import Foundation::CommonTypes::*;

        doc /* Domain identity infrastructure: the formal representation
             * of each service business domain in the Ontara platform.
             *
             * Contains two part defs (DomainIdentity, DomainConfiguration)
             * implementing the dual-stack split (S142-D1), plus concrete
             * domain instances for all four domains.
             *
             * DomainIdentity is the BMM-side concept — what the service
             * business is. DomainConfiguration is the SMM-side concept —
             * how the platform manages it. Connected by a horizontal
             * mapping (bidirectional ref).
             *
             * Multi-tenancy principle (A13): only the meta model is core;
             * every domain is a tenant instantiation.
             *
             * Session 59 (original design, B15).
             * Session 142 (dual-stack extension, S142-D1 to D7).
             * Session 143 (SysML implementation). */

        // ============================================================
        // Part definitions
        // ============================================================

        part def DomainIdentity {
            doc /* Business Meta Model concept.
                 * The business identity of a domain: what kind of service
                 * business it is, what regulatory environment it operates
                 * in, and why it exists in the platform.
                 *
                 * In the dual-stack architecture, DomainIdentity is the
                 * BMM-side of domain identity. The SMM-side is
                 * DomainConfiguration, connected by a horizontal mapping.
                 *
                 * In the multi-tenancy architecture (A13), only the meta
                 * model is core. Every DomainIdentity represents a tenant
                 * instantiation.
                 *
                 * BFO grounding: IAO:plan_specification (S142-D2).
                 * Domain identity (B15). Dual-stack (B21).
                 * Multi-tenancy (A13). Session 142 design, Session 143.
                 * Session 278: regulatoryTier renamed to regulatoryShape
                 * (kind-based, not intensity-based); two orthogonal
                 * supporting attributes added
                 * (authorisationRequiredToTrade,
                 * professionalRegistrations). regulatedActivities
                 * is now also the carrier of the
                 * mixed-services-with-regulated-components case (the
                 * old partiallyRegulated tier). */

            attribute regulatoryShape : RegulatoryShape;
            attribute bmmVocabularyScope : BmmVocabularyScope;
            attribute domainPurpose : DomainPurpose[1..*];
            attribute jurisdiction : Jurisdiction;
            attribute regulatedActivities : RegulatedActivity[0..*];
            attribute professionalRegistrations : ProfessionalBody[0..*];
            attribute organisationalForm : OrganisationalForm;
            attribute authorisationRequiredToTrade : Boolean;
            attribute description : String;
            attribute introducedSession : Integer;
            ref domainConfiguration : DomainConfiguration;
        }

        part def DomainConfiguration {
            doc /* System Meta Model concept.
                 * The system configuration for a domain: how the platform
                 * discovers, organises, presents, and manages this domain.
                 *
                 * Connected to DomainIdentity via horizontal mapping.
                 * Changes to configuration (package paths, display names)
                 * do not affect business identity or governance bindings.
                 *
                 * BFO grounding: IAO:data_item (S142-D2).
                 * Domain identity (B15). Dual-stack (B21).
                 * Session 142 design, Session 143. */

            attribute canonicalKey : String;
            attribute displayLabel : String;
            attribute fullName : String;
            attribute packageName : String;
            attribute modelPath : String;
            attribute isActive : Boolean;
            ref domainIdentity : DomainIdentity;
        }

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
            ref :>> domainConfiguration = cafeConfiguration;
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

        // --- Suds (Laundry Service) ---------------------------------

        part sudsIdentity : DomainIdentity {
            doc /* Cross-domain validation domain — batch processing
                 * laundry service. Validates meta model generality
                 * beyond immediate retail. Weight/type pricing,
                 * COSHH governance chain. Locally licensed (subject to
                 * COSHH and other operator-controlled statutory duties
                 * beyond general business law; no sector regulator). */

            attribute :>> regulatoryShape = RegulatoryShape::locallyLicensed;
            attribute :>> bmmVocabularyScope = BmmVocabularyScope::full;
            attribute :>> domainPurpose = DomainPurpose::crossDomainValidation;
            attribute :>> jurisdiction = Jurisdiction::england;
            attribute :>> organisationalForm = OrganisationalForm::registeredIndividual;
            attribute :>> authorisationRequiredToTrade = false;
            attribute :>> description = "Cross-domain validation domain — batch processing laundry service. Weight/type pricing, COSHH governance chain.";
            attribute :>> introducedSession = 16;
            ref :>> domainConfiguration = sudsConfiguration;
        }

        part sudsConfiguration : DomainConfiguration {
            attribute :>> canonicalKey = "suds";
            attribute :>> displayLabel = "Suds";
            attribute :>> fullName = "Suds (Laundry Service)";
            attribute :>> packageName = "SudsLaundry";
            attribute :>> modelPath = "exercises/suds-demonstrator";
            attribute :>> isActive = true;
            ref :>> domainIdentity = sudsIdentity;
        }

        // --- Paws (Dog Grooming) ------------------------------------

        part pawsIdentity : DomainIdentity {
            doc /* Pedagogical anchoring and cross-domain validation
                 * domain — appointment-based dog grooming service.
                 * Dual purpose (S142-D6): simple enough to introduce
                 * concepts, different enough to validate generalisation.
                 * Breed/size surcharges. Locally licensed (Animal
                 * Welfare Act duties; some local authorities require
                 * grooming-specific licences). */

            attribute :>> regulatoryShape = RegulatoryShape::locallyLicensed;
            attribute :>> bmmVocabularyScope = BmmVocabularyScope::generalOnly;
            attribute :>> domainPurpose = (DomainPurpose::pedagogicalAnchoring, DomainPurpose::crossDomainValidation);
            attribute :>> jurisdiction = Jurisdiction::england;
            attribute :>> organisationalForm = OrganisationalForm::registeredIndividual;
            attribute :>> authorisationRequiredToTrade = false;
            attribute :>> description = "Pedagogical anchoring and cross-domain validation domain — appointment-based dog grooming. Breed/size surcharges.";
            attribute :>> introducedSession = 43;
            ref :>> domainConfiguration = pawsConfiguration;
        }

        part pawsConfiguration : DomainConfiguration {
            attribute :>> canonicalKey = "paws";
            attribute :>> displayLabel = "Paws";
            attribute :>> fullName = "Paws (Dog Grooming)";
            attribute :>> packageName = "PawsGrooming";
            attribute :>> modelPath = "exercises/paws-demonstrator";
            attribute :>> isActive = true;
            ref :>> domainIdentity = pawsIdentity;
        }

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
            ref :>> domainConfiguration = gslConfiguration;
        }

        part gslConfiguration : DomainConfiguration {
            attribute :>> canonicalKey = "gsl";
            attribute :>> displayLabel = "GSL";
            attribute :>> fullName = "GenderSense Limited";
            attribute :>> packageName = "GenderSense";
            attribute :>> modelPath = "exercises/gendersense";
            attribute :>> isActive = true;
            ref :>> domainIdentity = gslIdentity;
        }
    }

}
