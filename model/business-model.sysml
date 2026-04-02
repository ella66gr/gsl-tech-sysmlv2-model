// =========================================================================
// BUSINESS MODEL — What GenderSense offers, to whom, and how it works
// financially as a business
// =========================================================================

package BusinessModel {
    private import ScalarValues::*;
    private import Foundation::MetadataLibrary::*;
    private import Foundation::CommonTypes::*;

    doc /* The business model package captures the strategic logic of the
         * enterprise: what value is offered, to whom, how revenue is
         * generated, what resources are needed, and how the business
         * evolves over time. This is distinct from the business system
         * model (the other six packages) which describes the operational
         * machinery that implements this logic.
         *
         * The six concerns addressed across this package and the
         * existing model:
         * - Service Concept (here: ServiceConcept)
         * - Activity Model (here: ActivityModel)
         * - Financial Model (here: FinancialPlanning)
         * - Resource and Capability Model (here: ResourcePlanning)
         * - Governance Mapping (here: GovernanceMapping)
         * - Stakeholder Model (here: StakeholderModel) — Session 81
         *
         * Cross-cutting: ActivityModel provides the activity taxonomy
         * and costing foundation that connects all six concerns.
         *
         * Source: gsl-service-business-meta-modelling.md
         *
         * Phase 1: ServiceConcept + ActivityModel (complete)
         * Phase 2: ResourcePlanning + FinancialPlanning (complete)
         * Phase 3: ScenarioModelling + StrategyAndEvolution (complete)
         * Phase 5: Full Platform (Variant B) scenario (complete)
         * Phase 6A: File split — ScenarioModelling promoted to
         *   BusinessScenarios (business-scenarios.sysml),
         *   StrategyAndEvolution promoted to BusinessStrategy
         *   (business-strategy.sysml). This file retains
         *   ServiceConcept, ActivityModel, ResourcePlanning,
         *   and FinancialPlanning.
         * Phase 10: CatalogueEntry, ExternalReference (ServiceConcept),
         *   InventoryRecord (ResourcePlanning) from CSW Extension.
         *   These are business meta model concepts — they describe
         *   what any service business offers and what resources it
         *   needs. System meta model concepts (PersistencePolicy,
         *   AgencyClassification) are in Foundation. */

    // =================================================================
    // SERVICE CONCEPT — What value is delivered, to whom, and why
    // =================================================================

    package ServiceConcept {
        private import ScalarValues::*;

        doc /* Defines the value proposition, customer segments, service
             * offerings, channels, and differentiation claims. This is
             * the "why does this business exist, and for whom?" package.
             *
             * Cross-references to ServiceDelivery::ClinicalPathways are
             * via String attributes (clinicalPathwayRef) rather than
             * formal SysML ref relationships. This avoids coupling
             * during the exploratory phase. Formal references will be
             * added once the business model structure stabilises.
             *
             * Source: gsl-service-business-meta-modelling.md section 3.1 */

        // -- Part definitions ----------------------------------

        @CatalogueTag { bmmConcern = "ServiceConcept"; classification = "General"; }
        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "CCO:GroupOfAgents";
            mappingNotes = "A segment characterises a class of agents. GDC because the grouping pattern migrates between populations.";
        }
        @UserFacing {
            friendlyName = "Customer Segment";
            shortDescription = "A defined group of customers with shared needs and willingness to pay.";
        }
        @PurposiveDescription {
            description = "A group of people your service is designed for — people who share similar needs and reasons for choosing you. When you define your customer segments, the system uses them to connect your value propositions, pricing, and channels to the right audiences.";
        }
        @Comprehension {
            surfaceEnumValues = false;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "ValueProposition";
            strength = RelationshipStrength::strong;
            rationale = "Each segment has one or more propositions designed for it. A change to the target segment requires reassessing the value promises made to it.";
        }
        @WeightedRelationship {
            target = "ServiceOffering";
            strength = RelationshipStrength::strong;
            rationale = "Offerings are what the segment actually receives. A change to the target audience requires reassessing what is offered to them.";
        }
        @WeightedRelationship {
            target = "Channel";
            strength = RelationshipStrength::moderate;
            rationale = "Channels are how segments are reached. A change to the target segment may require reviewing acquisition and delivery channels, but the relationship is many-to-many.";
        }
        part def CustomerSegment {
            doc /* A defined group of customers with shared needs,
                 * behaviours, and willingness to pay. Each segment
                 * has distinct needs and may require distinct value
                 * propositions. */
            attribute segmentName : String;
            attribute description : String;
            attribute needs : String;
            attribute acquisitionChannel : String;
            attribute willingnessToPayIndicator : String; // qualitative: high / medium / low
        }

        @CatalogueTag { bmmConcern = "ServiceConcept"; classification = "General"; }
        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "IAO:PlanSpecification";
            mappingNotes = "A specification of promised value. Migrates between bearers (documents, conversations).";
        }
        @UserFacing {
            friendlyName = "Value Proposition";
            shortDescription = "A promise of value to a customer segment — what they get and why it matters.";
        }
        @PurposiveDescription {
            description = "The core promise your service makes to a particular group of customers — what they get from you and why they'd choose you over the alternatives. When you define a value proposition, the system holds it as the anchor that your activities, resources, and pricing all exist to deliver.";
        }
        @Comprehension {
            surfaceEnumValues = false;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "ServiceOffering";
            strength = RelationshipStrength::strong;
            rationale = "The offering is the concrete realisation of the proposition. A change to the value promise requires reassessing what is offered to deliver it.";
        }
        @WeightedRelationship {
            target = "CustomerSegment";
            strength = RelationshipStrength::strong;
            rationale = "Every value proposition is made to a specific segment. A change to the promise of value requires reassessing the audience it addresses.";
        }
        @WeightedRelationship {
            target = "DifferentiationClaim";
            strength = RelationshipStrength::moderate;
            rationale = "Claims articulate how the proposition differs from alternatives. A change to the proposition may require reviewing its supporting claims, but a proposition can exist before claims are formalised.";
        }
        part def ValueProposition {
            doc /* A specific promise of value to a specific customer
                 * segment. Defines what the customer gets, how it
                 * differs from alternatives, and why it matters. */
            attribute propositionName : String;
            attribute description : String;
            ref targetSegment : CustomerSegment;
            attribute differentiator : String;
            attribute evidenceBasis : String;
        }

        @CatalogueTag { bmmConcern = "ServiceConcept"; classification = "General"; }
        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "IAO:PlanSpecification";
            mappingNotes = "A packaged specification of what can be delivered — the plan/template, not the delivery itself.";
        }
        @UserFacing {
            friendlyName = "Service Offering";
            shortDescription = "A packaged unit of service that can be priced, resourced, and delivered to customers.";
        }
        @PurposiveDescription {
            description = "A distinct service that your business offers — something a customer can choose, pay for, and receive. When you define a service offering, the system connects it to the activities required to deliver it, the resources it consumes, and the price the customer pays.";
        }
        @Comprehension {
            surfaceEnumValues = false;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "ValueProposition";
            strength = RelationshipStrength::strong;
            rationale = "A service offering is the concrete realisation of a value proposition. A change to what is offered requires reassessing the promise of value it delivers.";
        }
        @WeightedRelationship {
            target = "CustomerSegment";
            strength = RelationshipStrength::strong;
            rationale = "Every service offering exists for defined customer segments. A change to what is offered requires reassessing who it is for.";
        }
        @WeightedRelationship {
            target = "PricingModel";
            strength = RelationshipStrength::strong;
            rationale = "Each offering has a pricing basis. A change to the offering directly affects how it is priced.";
        }
        @WeightedRelationship {
            target = "ActivityType";
            strength = RelationshipStrength::strong;
            rationale = "Every service offering requires activities to deliver it. A change to the offering requires reassessing the activity types involved.";
        }
        @WeightedRelationship {
            target = "Channel";
            strength = RelationshipStrength::moderate;
            rationale = "Channels deliver service offerings to customers. A change to the offering may require reviewing delivery channels, but the coupling is not definitional.";
        }
        @WeightedRelationship {
            target = "CatalogueEntry";
            strength = RelationshipStrength::moderate;
            rationale = "The catalogue records the business decision to offer something. A change to the offering may require updating catalogue entries, but the catalogue is operational, not definitional.";
        }
        @WeightedRelationship {
            target = "DifferentiationClaim";
            strength = RelationshipStrength::moderate;
            rationale = "Claims support the value proposition which the offering delivers. A change to the offering may require reviewing claims, but the link is mediated through the value proposition.";
        }
        @WeightedRelationship {
            target = "ResourceType";
            strength = RelationshipStrength::moderate;
            rationale = "Resources are consumed by activities which deliver offerings. A change to the offering may affect resource requirements, but the relationship is indirect — mediated through activity types and capabilities.";
        }
        part def ServiceOffering {
            doc /* A packaged, deliverable unit of service that realises
                 * one or more value propositions for one or more
                 * segments. This is the unit at which pricing, resource
                 * requirements, and pathway mapping are defined.
                 *
                 * Cross-reference: each ServiceOffering maps to one or
                 * more clinical pathways in
                 * ServiceDelivery::ClinicalPathways. */
            attribute offeringName : String;
            attribute description : String;
            attribute scope : String;
            attribute pricingBasis : String;       // per-episode, subscription, etc.
            attribute estimatedDurationWeeks : Integer;
            attribute clinicalPathwayRef : String; // e.g. "ClinicalPathways::HormoneTherapy::HormoneTherapyInitiation"
        }

        @CatalogueTag { bmmConcern = "ServiceConcept"; classification = "General"; }
        @BfoType {
            bfoClass = "Role";
            midLevelClass = "CCO:ArtifactFunction";
            mappingNotes = "A role played by a medium/platform in connecting business to customers. Extrinsic — same entity can be different channels.";
        }
        @UserFacing {
            friendlyName = "Channel";
            shortDescription = "A way that customers find, reach, or receive your service.";
        }
        @PurposiveDescription {
            description = "A way that customers find you, reach you, or receive your service — your website, a referral network, a walk-in counter, an app. When you define your channels, the system tracks which customer segments each channel serves and how your service offerings are delivered through them.";
        }
        @Comprehension {
            surfaceEnumValues = false;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "CustomerSegment";
            strength = RelationshipStrength::moderate;
            rationale = "Channels serve customer segments. A change to a channel may require reviewing which segments it reaches, but the coupling is operational and many-to-many.";
        }
        @WeightedRelationship {
            target = "ServiceOffering";
            strength = RelationshipStrength::moderate;
            rationale = "Channels deliver service offerings. A change to a channel may require reviewing which offerings flow through it, but the coupling is loose.";
        }
        part def Channel {
            doc /* A means by which customers discover, access, and
                 * interact with the service. Channels have reach,
                 * cost, and conversion characteristics. */
            attribute channelName : String;
            attribute description : String;
            attribute channelType : String;        // acquisition, delivery, or both
            attribute estimatedReach : String;
            attribute estimatedCostLevel : String; // qualitative: high / medium / low
            attribute conversionNotes : String;
        }

        @CatalogueTag { bmmConcern = "ServiceConcept"; classification = "General"; }
        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "IAO:InformationContentEntity";
            mappingNotes = "An assertion with truth conditions and evidence basis.";
        }
        @UserFacing {
            friendlyName = "Differentiation Claim";
            shortDescription = "An explicit, testable statement of how your service differs from alternatives.";
        }
        @PurposiveDescription {
            description = "An explicit statement of how your service differs from the alternatives, from the customer's perspective. Each claim should be testable — something you can back up with evidence. When you define differentiation claims, the system records them as commitments your service is designed to fulfil.";
        }
        @Comprehension {
            surfaceEnumValues = false;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "ValueProposition";
            strength = RelationshipStrength::strong;
            rationale = "Claims exist to substantiate a value proposition. A change to a claim requires reassessing the proposition it supports — a claim without a proposition is orphaned.";
        }
        @WeightedRelationship {
            target = "ServiceOffering";
            strength = RelationshipStrength::weak;
            rationale = "Claims relate to offerings indirectly, via the value proposition. A change to a claim has a distant effect on offerings — mediated through the proposition.";
        }
        part def DifferentiationClaim {
            doc /* An explicit statement of how this service differs
                 * from available alternatives, from the customer's
                 * perspective. Each claim should be testable. */
            attribute claimName : String;
            attribute statement : String;
            attribute basis : String;
            attribute testability : String;
        }

        // -- Service subject and participation ------------------
        // Session 55: resolves the service-subject-≠-customer
        // observation from Paws (Session 44). Two sibling concepts:
        // ServiceSubject (what the service acts on) and
        // ServiceParticipant (who else is involved, in what role).
        // See: ontara-discussion-service-participation-model-2026-03-21.md

        @CatalogueTag { bmmConcern = "ServiceConcept"; classification = "General"; }
        @BfoType {
            bfoClass = "Role";
            midLevelClass = "";
            mappingNotes = "The entity upon which a service is performed. Role because subject status is extrinsic and context-dependent. Candidate: ontara:ServiceSubjectRole.";
        }
        @UserFacing {
            friendlyName = "Service Subject";
            shortDescription = "The entity upon which a service is performed — a person, animal, object, or organisation that receives the service.";
        }
        @PurposiveDescription {
            description = "The thing your service acts on — the dog being groomed, the patient receiving care, the garment being cleaned, the item being repaired. A service subject may have needs independent of whoever commissioned the service, and governance obligations may attach to the subject directly. When you identify your service subjects, the system tracks what is being served, in what condition, and with what independent requirements — separately from who is paying or making decisions.";
        }
        @Comprehension {
            surfaceEnumValues = false;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "ServiceOffering";
            strength = RelationshipStrength::strong;
            rationale = "What is offered depends directly on the nature of the subject. A different breed, clinical condition, or item type requires reassessing the offering.";
        }
        @WeightedRelationship {
            target = "GovernanceRequirement";
            strength = RelationshipStrength::strong;
            rationale = "Governance obligations attach to the subject independently of the customer. Duty of care is to the dog, the patient, the object in custody.";
        }
        @WeightedRelationship {
            target = "ActivityType";
            strength = RelationshipStrength::strong;
            rationale = "The subject's characteristics directly determine the activities required — breed-specific grooming, patient-specific procedures, item-specific repair.";
        }
        @WeightedRelationship {
            target = "ServiceParticipant";
            strength = RelationshipStrength::moderate;
            rationale = "Subject and participants are related — participants commission, fund, or authorise services on or for the subject — but they are independently defined.";
        }
        @WeightedRelationship {
            target = "CustomerSegment";
            strength = RelationshipStrength::moderate;
            rationale = "Different customer segments may involve different subject types, but the segment is defined by its needs and willingness to pay, not by the subject.";
        }
        part def ServiceSubject {
            doc /* The entity upon which a service is performed. The dog
                 * being groomed, the patient receiving care, the garment
                 * being laundered, the item being repaired.
                 *
                 * A service subject is structurally distinct from a
                 * service participant: the service acts *on* the subject,
                 * while participants influence, commission, fund, or
                 * authorise the service. Either can independently trigger
                 * workflow. They are sibling concepts, not a hierarchy.
                 *
                 * The subject may have independent needs (animal welfare,
                 * clinical requirements, handling constraints) that
                 * override the customer's stated preferences. Governance
                 * obligations bind to the subject.
                 *
                 * Multiple subjects per engagement are expected: two
                 * items for repair, a patient with concurrent clinical
                 * problems. Each may trigger independent workflow
                 * pathways with different timescales.
                 *
                 * Cross-domain validation: Paws (dog), GSL (patient),
                 * Suds (garments), repair shop (items). Cafe: customer
                 * is also the subject — a valid trivial case.
                 *
                 * See the Service Participation Model discussion
                 * document (Session 55) for the full architectural
                 * direction. */
            attribute subjectName : String;
            attribute entityDescription : String;
            attribute independentNeeds : String;
            attribute conditionNotes : String;
            attribute statusNotes : String;
        }

        @CatalogueTag { bmmConcern = "ServiceConcept"; classification = "General"; }
        @BfoType {
            bfoClass = "Role";
            midLevelClass = "";
            mappingNotes = "An entity involved in a service in a defined role. Same person can hold multiple roles simultaneously. Candidate: ontara:ServiceParticipantRole.";
        }
        @UserFacing {
            friendlyName = "Service Participant";
            shortDescription = "An entity involved in a service engagement in a defined role — customer, payer, commissioner, decision-maker, or any other role.";
        }
        @PurposiveDescription {
            description = "Any person or organisation involved in a service engagement in a defined role. The person who pays, the organisation that commissions, the carer who makes decisions, the expert called in for assessment — any entity with influence on how the service proceeds. When you identify your service participants, the system tracks who is involved, in what capacity, and how their status affects the service workflow. The set of possible roles is open — the model does not constrain what kinds of participation your service may involve.";
        }
        @Comprehension {
            surfaceEnumValues = false;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "ServiceSubject";
            strength = RelationshipStrength::strong;
            rationale = "The participant's role is defined in relation to the subject — they commission, fund, authorise, or contribute to the service on or for the subject.";
        }
        @WeightedRelationship {
            target = "ServiceOffering";
            strength = RelationshipStrength::moderate;
            rationale = "The participant influences the offering — a commissioner may constrain scope, a payer may limit options — but the offering is primarily shaped by the subject's needs.";
        }
        @WeightedRelationship {
            target = "CustomerSegment";
            strength = RelationshipStrength::moderate;
            rationale = "Participants often belong to or represent a customer segment, but the mapping is characterising — a segment is not defined by its participants.";
        }
        @WeightedRelationship {
            target = "GovernanceRequirement";
            strength = RelationshipStrength::moderate;
            rationale = "Governance requirements may apply to participants (commissioner must approve, payer must authorise), but the primary governance binding is to the subject.";
        }
        part def ServiceParticipant {
            doc /* An entity involved in a service engagement in a
                 * defined role. The person who pays, the organisation
                 * that commissions, the carer who makes decisions,
                 * the expert called in for assessment.
                 *
                 * A service participant is structurally distinct from
                 * a service subject: the service acts *on* the subject,
                 * while participants influence, commission, fund, or
                 * authorise the service. Either can independently
                 * trigger workflow. They are sibling concepts, not a
                 * hierarchy.
                 *
                 * The set of participation roles is open: customer,
                 * payer, commissioner, decision-maker, referrer, and
                 * others not yet identified. A single entity may hold
                 * multiple roles simultaneously. Multiple entities may
                 * share a role (e.g. joint and several liability).
                 *
                 * Cross-domain validation: Paws (pet owner as customer/
                 * payer/decision-maker), GSL (NHS as commissioner,
                 * carer as decision-maker, GP as referrer). Cafe:
                 * customer is also the subject — trivial but valid.
                 *
                 * See the Service Participation Model discussion
                 * document (Session 55) for the full architectural
                 * direction. */
            attribute participantName : String;
            attribute participantRole : String;
            attribute entityDescription : String;
            attribute relationshipToEngagement : String;
            attribute statusNotes : String;
        }

        // -- Catalogue and external reference abstractions ------
        // Business meta model concepts: what any service business
        // offers and how it links to external knowledge.
        // Added Session 29: CSW Extension Phase 10 (items 8.1).
        // Source: gsl-spec-catalogue-inventory-v2.1.md §8.1
        // The four-layer model:
        //   Item definition → CatalogueEntry → InventoryRecord →
        //   ExternalReference
        // Domain-specific types (e.g. CoffeeShop::CatalogueEntry
        // with ref item : MenuItem) are typed specialisations of
        // these generic shapes.

        @CatalogueTag { bmmConcern = "ServiceConcept"; classification = "General"; }
        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "IAO:InformationContentEntity";
            mappingNotes = "A record linking item definition to business-context properties (price, availability, status).";
        }
        @UserFacing {
            friendlyName = "Catalogue Entry";
            shortDescription = "A record of something your business has decided to offer, with its price and status.";
        }
        @PurposiveDescription {
            description = "A record of something your business has decided to offer — whether that's a menu item, a treatment, a course, or any other unit you sell or provide. The catalogue entry connects what the thing intrinsically is to how your business offers it: its price, availability, and status. When you add a catalogue entry, the system tracks it as part of your active offering.";
        }
        @Comprehension {
            surfaceEnumValues = false;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "ServiceOffering";
            strength = RelationshipStrength::moderate;
            rationale = "The catalogue records what is offered. A change to a catalogue entry may require reviewing the offering it represents, but the catalogue is the operational wrapper, not the strategic definition.";
        }
        @WeightedRelationship {
            target = "ExternalReference";
            strength = RelationshipStrength::moderate;
            rationale = "Catalogue entries link to external knowledge sources. A change to a catalogue entry may require reviewing its external references — the four-layer item model connects them.";
        }
        @WeightedRelationship {
            target = "InventoryRecord";
            strength = RelationshipStrength::moderate;
            rationale = "Inventory tracks stock of catalogue items. A change to a catalogue entry may require updating its associated inventory records.";
        }
        part def CatalogueEntry {
            doc /* The business decision to offer an item for sale or
                 * use within a service. References an item definition
                 * and adds business-context properties.
                 *
                 * The four-layer model separates what something
                 * intrinsically is (item definition) from how the
                 * business offers it (catalogue entry) from its
                 * operational stock state (inventory record) from
                 * links to external knowledge (external reference).
                 *
                 * Business meta model concept. Domain-agnostic:
                 * works for coffee shop menus, clinical formularies,
                 * course catalogues, service engagements.
                 *
                 * Source: gsl-spec-catalogue-inventory-v2.1.md §8.1 */
            attribute entryName : String;
            attribute itemReference : String;
            attribute pricingDescription : String;
            attribute availabilityStatus : String;
            attribute provisionType : String;
            attribute effectiveDate : String;
            attribute statusNotes : String;
        }

        @CatalogueTag { bmmConcern = "ServiceConcept"; classification = "General"; }
        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "IAO:InformationContentEntity";
            mappingNotes = "A referential pointer to external knowledge. Information content whose purpose is denotation.";
        }
        @UserFacing {
            friendlyName = "External Reference";
            shortDescription = "A link to authoritative knowledge that lives outside your system.";
        }
        @PurposiveDescription {
            description = "A link to knowledge that lives outside your system — a supplier datasheet, a regulatory standard, a clinical guideline, an accreditation body. The system doesn't own this information; it points to it, so you always know where authoritative external knowledge sits in relation to your service.";
        }
        @Comprehension {
            surfaceEnumValues = false;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "CatalogueEntry";
            strength = RelationshipStrength::moderate;
            rationale = "External references attach to catalogue items. A change to an external reference may require reviewing the catalogue entries that depend on it.";
        }
        part def ExternalReference {
            doc /* A link to knowledge that lives outside the system.
                 * The system does not own this data; it points to it.
                 *
                 * Business meta model concept. Domain-agnostic:
                 *   Coffee shop: supplier datasheet, origin cert
                 *   Healthcare: SPC, BNF, NICE guidance
                 *   Education: accreditation body, curriculum standard
                 *
                 * Source: gsl-spec-catalogue-inventory-v2.1.md §2.3 */
            attribute referenceType : String;
            attribute referenceId : String;
            attribute referenceSource : String;
            attribute referenceNotes : String;
        }

        // -- GSL Service Concept instantiation -----------------
        //
        // Lean Clinical variant (Variant A) service concept.
        // These are the concrete values for the initial business
        // model configuration.

        // Customer segments

        part selfReferringIndividuals : CustomerSegment {
            doc /* Adults seeking gender-affirming care who find GSL
                 * directly via web search, social media, or community
                 * referral. Typically motivated by long NHS wait times. */
            attribute :>> segmentName = "Self-referring individuals";
            attribute :>> description = "Adults seeking gender-affirming care who self-refer";
            attribute :>> needs = "Timely access to specialist assessment and hormone therapy";
            attribute :>> acquisitionChannel = "Website/SEO, social media, community word of mouth";
            attribute :>> willingnessToPayIndicator = "medium";
        }

        part gpReferredPatients : CustomerSegment {
            doc /* Patients referred by their GP, often with a letter
                 * of referral. May be partially funded via shared care
                 * arrangements. */
            attribute :>> segmentName = "GP-referred patients";
            attribute :>> description = "Patients referred by their GP for specialist gender care";
            attribute :>> needs = "Specialist assessment with clear communication back to GP";
            attribute :>> acquisitionChannel = "GP referral network";
            attribute :>> willingnessToPayIndicator = "medium-high";
        }

        // Value propositions

        part fasterAccess : ValueProposition {
            attribute :>> propositionName = "Faster access than NHS";
            attribute :>> description = "Assessment within weeks, not years";
            ref :>> targetSegment = selfReferringIndividuals;
            attribute :>> differentiator = "NHS GIC median wait exceeds 4 years";
            attribute :>> evidenceBasis = "Published NHS waiting time data";
        }

        part integratedDigitalClinical : ValueProposition {
            attribute :>> propositionName = "Integrated digital and clinical care";
            attribute :>> description = "Patient portal with real-time pathway visibility alongside clinical expertise";
            ref :>> targetSegment = selfReferringIndividuals;
            attribute :>> differentiator = "Most private gender services offer clinical-only with no digital integration";
            attribute :>> evidenceBasis = "Platform capability comparison";
        }

        part specialistExpertise : ValueProposition {
            attribute :>> propositionName = "Specialist expertise";
            attribute :>> description = "Care delivered by clinicians with specific gender identity healthcare credentials";
            ref :>> targetSegment = gpReferredPatients;
            attribute :>> differentiator = "RCP Certificate in Gender Identity Healthcare";
            attribute :>> evidenceBasis = "Professional qualification and clinical experience";
        }

        // Service offerings

        part initialAssessment : ServiceOffering {
            doc /* Comprehensive new patient assessment. Two sessions
                 * over approximately two weeks. Maps to the Assessment
                 * clinical pathway. */
            attribute :>> offeringName = "Initial Assessment";
            attribute :>> description = "Comprehensive new patient assessment (2 sessions over 2 weeks)";
            attribute :>> scope = "History taking, mental health screening, physical assessment, treatment planning";
            attribute :>> pricingBasis = "per-episode";
            attribute :>> estimatedDurationWeeks = 2;
            attribute :>> clinicalPathwayRef = "ClinicalPathways::Assessment";
        }

        part hormoneTherapyInitiation : ServiceOffering {
            doc /* From baseline bloods through to stable regimen.
                 * Typical duration 6-12 months. Maps to the Hormone
                 * Therapy Initiation clinical pathway. */
            attribute :>> offeringName = "Hormone Therapy Initiation";
            attribute :>> description = "From baseline bloods through to stable regimen";
            attribute :>> scope = "Baseline investigations, prescribing, titration, monitoring until stable";
            attribute :>> pricingBasis = "per-episode";
            attribute :>> estimatedDurationWeeks = 36;
            attribute :>> clinicalPathwayRef = "ClinicalPathways::HormoneTherapy::HormoneTherapyInitiation";
        }

        part ongoingMonitoring : ServiceOffering {
            doc /* Quarterly monitoring reviews once stable. Ongoing
                 * service with no fixed end date. Maps to the Hormone
                 * Therapy monitoring pathway. */
            attribute :>> offeringName = "Ongoing Monitoring";
            attribute :>> description = "Quarterly monitoring reviews once stable";
            attribute :>> scope = "Blood monitoring, clinical review, prescription renewal";
            attribute :>> pricingBasis = "per-episode";
            attribute :>> estimatedDurationWeeks = 0;  // ongoing, no fixed duration
            attribute :>> clinicalPathwayRef = "ClinicalPathways::HormoneTherapy";
        }

        // Channels

        part websiteSeo : Channel {
            attribute :>> channelName = "Website and SEO";
            attribute :>> description = "GenderSense website optimised for search visibility";
            attribute :>> channelType = "acquisition";
            attribute :>> estimatedReach = "moderate — depends on SEO investment and content strategy";
            attribute :>> estimatedCostLevel = "low";
            attribute :>> conversionNotes = "High intent traffic — people searching for gender services are typically ready to act";
        }

        part gpReferralNetwork : Channel {
            attribute :>> channelName = "GP referral network";
            attribute :>> description = "Relationships with GP practices for direct referrals";
            attribute :>> channelType = "acquisition";
            attribute :>> estimatedReach = "growing — depends on shared care agreements established";
            attribute :>> estimatedCostLevel = "medium";
            attribute :>> conversionNotes = "High conversion — GP referral implies clinical readiness";
        }

        // Differentiation claims

        part modelDrivenSafety : DifferentiationClaim {
            attribute :>> claimName = "Model-driven safety";
            attribute :>> statement = "Every clinical decision is checked against explicit, auditable rules";
            attribute :>> basis = "SysML-modelled constraints with generated runtime enforcement";
            attribute :>> testability = "Audit trail showing every constraint evaluation for every patient";
        }

        part patientPortalVisibility : DifferentiationClaim {
            attribute :>> claimName = "Patient portal with real-time pathway visibility";
            attribute :>> statement = "You can see exactly where you are in your care journey and what comes next";
            attribute :>> basis = "Patient portal reading from the same pathway model that drives clinical delivery";
            attribute :>> testability = "Patient satisfaction survey and portal usage metrics";
        }

        // -- Variant B (Full Platform) service offerings -------

        part coachingService : ServiceOffering {
            doc /* Gender identity coaching delivered by a trained
                 * coach. Included in the Full Platform subscription.
                 * No clinical pathway equivalent — coaching is a
                 * non-clinical support offering. */
            attribute :>> offeringName = "Coaching";
            attribute :>> description = "Structured gender identity coaching sessions with a trained coach";
            attribute :>> scope = "Goal setting, self-advocacy skills, navigating social transition, wellbeing support";
            attribute :>> pricingBasis = "subscription";
            attribute :>> estimatedDurationWeeks = 0;  // ongoing, no fixed duration
            attribute :>> clinicalPathwayRef = "";     // non-clinical offering
        }

        part educationService : ServiceOffering {
            doc /* Structured education modules on gender-affirming
                 * care topics. Included in subscription. Self-paced
                 * digital content with optional live sessions. */
            attribute :>> offeringName = "Education";
            attribute :>> description = "Structured education modules on gender-affirming care and wellbeing";
            attribute :>> scope = "Understanding hormones, managing expectations, health literacy, rights and access";
            attribute :>> pricingBasis = "subscription";
            attribute :>> estimatedDurationWeeks = 0;  // ongoing library, no fixed duration
            attribute :>> clinicalPathwayRef = "";     // non-clinical offering
        }

        part communityAccess : ServiceOffering {
            doc /* Moderated peer community platform. Included in
                 * subscription. Provides peer support, shared
                 * experience, and community connection. */
            attribute :>> offeringName = "Community";
            attribute :>> description = "Moderated peer community platform for shared experience and support";
            attribute :>> scope = "Peer forums, facilitated groups, community events, resource sharing";
            attribute :>> pricingBasis = "subscription";
            attribute :>> estimatedDurationWeeks = 0;  // ongoing, no fixed duration
            attribute :>> clinicalPathwayRef = "";     // non-clinical offering
        }

        part subscriptionBundle : ServiceOffering {
            doc /* Composite service offering representing the monthly
                 * subscription package. Bundles Coaching, Education,
                 * and Community into a single offering for pricing
                 * and unit economics purposes. Clinical services
                 * (assessment, monitoring) are separate. */
            attribute :>> offeringName = "Subscription (monthly)";
            attribute :>> description = "Monthly subscription bundling coaching, education, and peer community access";
            attribute :>> scope = "Coaching sessions, education modules, community platform access";
            attribute :>> pricingBasis = "subscription";
            attribute :>> estimatedDurationWeeks = 0;  // ongoing, no fixed duration
            attribute :>> clinicalPathwayRef = "";     // non-clinical offering
        }

        // -- Variant B value propositions ----------------------

        part holisticCareModel : ValueProposition {
            attribute :>> propositionName = "Holistic care model";
            attribute :>> description = "Clinical care, coaching, education, and peer community as one integrated package";
            ref :>> targetSegment = selfReferringIndividuals;
            attribute :>> differentiator = "No other UK gender service offers clinical + coaching + community as a single subscription";
            attribute :>> evidenceBasis = "Service offering comparison with existing providers";
        }
    }

    // =================================================================
    // ACTIVITY MODEL — Cross-cutting activity taxonomy and costing
    // =================================================================

    package ActivityModel {
        private import ScalarValues::*;

        doc /* Cross-cutting activity taxonomy and costing foundation.
             * Every activity in the business falls into one of five
             * categories. Activity awareness operates at multiple
             * granularity levels, and different parts of the business
             * can operate at different levels simultaneously.
             *
             * At the business model level, ActivityModel is about
             * planning and costing — how much activity of each type
             * does this business model require, and what does it cost?
             * At the system model level, the corresponding concern is
             * activity tracking — the actual recording of activity
             * events as they happen.
             *
             * Source: gsl-service-business-meta-modelling.md section 2.4
             *
             * Progressive elaboration: different parts of the business
             * can operate at different granularity levels at the same
             * time. Clinical service delivery is at tracked level from
             * day one (pathway model produces observable events).
             * Governance may be at category level. Overhead may remain
             * at envelope level until there is a reason to be more
             * precise. */

        // -- Enumerations --------------------------------------

        enum def ActivityCategory {
            doc /* The five categories of business activity. Every
                 * activity belongs to at least one category. The
                 * taxonomy ensures completeness of coverage — nothing
                 * falls through the gaps. */
            serviceDelivery;     // directly produces value for a customer
            serviceEnabling;     // supports delivery but not visible to customer
            governance;          // satisfies compliance, quality, safety requirements
            development;         // builds future capability
            overhead;            // necessary operational activity
        }

        enum def GranularityLevel {
            doc /* The level of detail at which activity is tracked
                 * for a given activity type or business area. */
            envelope;    // total hours per category as a lump estimate
            category;    // broken down by type, approximate proportions
            tracked;     // individual activities recorded as discrete events
        }

        // -- Part definitions ----------------------------------

        @CatalogueTag { bmmConcern = "ActivityModel"; classification = "General"; }
        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "IAO:PlanSpecification";
            mappingNotes = "A template for a kind of activity — the specification, not the doing. Actual activities are Processes.";
        }
        @UserFacing {
            friendlyName = "Activity Type";
            shortDescription = "A defined kind of business activity, classified into one of five categories.";
        }
        @PurposiveDescription {
            description = "Something your business does — an identifiable unit of work that the system holds, tracks, and uses. In this system, every activity is an activity of one of the following types: service delivery, enabling, governance, development, or overhead. When you assign one of these types to an activity, the system will use that information to plan resources, allocate costs, and verify that governance requirements are being met for each kind of work.";
        }
        @Comprehension {
            surfaceEnumValues = true;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "ActivityCostAllocation";
            strength = RelationshipStrength::strong;
            rationale = "Cost allocation is structurally determined by activity type — every cost line traces back to an activity category.";
        }
        @WeightedRelationship {
            target = "ActivityGranularity";
            strength = RelationshipStrength::strong;
            rationale = "Granularity level directly governs how an activity type is tracked and costed — envelope vs category vs tracked.";
        }
        @WeightedRelationship {
            target = "ActivityBudget";
            strength = RelationshipStrength::moderate;
            rationale = "Budgets aggregate by activity type but the relationship is indirect — mediated through cost allocation.";
        }
        @WeightedRelationship {
            target = "ActivityRecord";
            strength = RelationshipStrength::moderate;
            rationale = "Activity records are typed by activity type but the record is an operational artefact, not a structural dependency.";
        }
        @WeightedRelationship {
            target = "ResourceType";
            strength = RelationshipStrength::moderate;
            rationale = "Resources are consumed by activities but the mapping is many-to-many and context-dependent.";
        }
        @WeightedRelationship {
            target = "Channel";
            strength = RelationshipStrength::weak;
            rationale = "Channels deliver services which contain activities, but the relationship is distant — mediated through service offerings.";
        }
        part def ActivityType {
            doc /* A defined type of activity within the business.
                 * Every activity has a type, and every type belongs
                 * to one of the five taxonomy categories. */
            attribute activityTypeName : String;
            attribute activityCategory : ActivityCategory;
            attribute description : String;
            attribute expectedDurationMinutes : Integer;
            attribute frequencyNotes : String;
        }

        @CatalogueTag { bmmConcern = "ActivityModel"; classification = "General"; }
        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "IAO:InformationContentEntity";
            mappingNotes = "A record documenting what happened. The activity was a Process; the record is information about it.";
        }
        @UserFacing {
            friendlyName = "Activity Record";
            shortDescription = "A recorded instance of an activity that actually happened.";
        }
        @PurposiveDescription {
            description = "A recorded instance of an activity that actually happened — the system's record that a specific piece of work was done, by whom, for how long, and using what resources. At the most detailed tracking level, the system creates one of these for every observable activity. At coarser levels, they are estimated aggregates.";
        }
        @Comprehension {
            surfaceEnumValues = true;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "ActivityType";
            strength = RelationshipStrength::moderate;
            rationale = "Every record is typed by an activity type. If the record format or granularity changes, the activity type may need reviewing — but an operational change to how records are produced does not redefine what the activity type is.";
        }
        part def ActivityRecord {
            doc /* A recorded instance of an activity. At the tracked
                 * level, the system produces these for every observable
                 * activity. At coarser levels, they are estimated
                 * aggregates. */
            ref activityType : ActivityType;
            attribute participants : String;
            attribute durationMinutes : Integer;
            attribute resourcesConsumed : String;
            attribute recordGranularity : GranularityLevel;
        }

        @CatalogueTag { bmmConcern = "ActivityModel"; classification = "General"; }
        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "IAO:PlanSpecification";
            mappingNotes = "A forward-looking allocation of activity volume. Specifies desired future states.";
        }
        @UserFacing {
            friendlyName = "Activity Budget";
            shortDescription = "A planned allocation of activity volume by type and period.";
        }
        @PurposiveDescription {
            description = "A planned allocation of how much activity of each type your business expects in a given period — the activity-level equivalent of a financial budget. When you define an activity budget, the system can compare what actually happened against what was planned, and surface gaps.";
        }
        @Comprehension {
            surfaceEnumValues = true;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "ActivityType";
            strength = RelationshipStrength::moderate;
            rationale = "Budgets are structured by activity type. If the budget changes (e.g. planned volumes revised), the activity type may need reviewing — but a quantitative change to volume does not redefine what the activity type is.";
        }
        @WeightedRelationship {
            target = "FinancialProjection";
            strength = RelationshipStrength::moderate;
            rationale = "Activity budgets feed into financial projections as volume inputs. If the budget changes, the projection may need updating — but the projection aggregates many inputs beyond activity volumes.";
        }
        part def ActivityBudget {
            doc /* A planned allocation of activity volume by type,
                 * period, and resource. The activity-level equivalent
                 * of a financial budget. */
            attribute budgetPeriod : String;
            ref activityType : ActivityType;
            attribute plannedVolume : Integer;
            attribute plannedTotalHours : Real;
            attribute granularity : GranularityLevel;
        }

        @CatalogueTag { bmmConcern = "ActivityModel"; classification = "General"; }
        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "IAO:PlanSpecification";
            mappingNotes = "A policy declaration about tracking precision — governs how the system observes and records.";
        }
        @UserFacing {
            friendlyName = "Activity Granularity";
            shortDescription = "A policy declaration of how precisely activity is tracked in a given area.";
        }
        @PurposiveDescription {
            description = "A policy declaration: how precisely does your business track activity in a given area? The system supports three levels — envelope (a rough total), category (broken down by type), and tracked (every individual activity recorded). Different parts of your business can operate at different levels at the same time, and you can refine the level as your needs evolve.";
        }
        @Comprehension {
            surfaceEnumValues = true;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "ActivityType";
            strength = RelationshipStrength::moderate;
            rationale = "Granularity governs how activity types are tracked. If the granularity policy changes, the activity types in that area may need reviewing — but a policy change about tracking precision does not redefine what the activity type is.";
        }
        @WeightedRelationship {
            target = "ActivityRecord";
            strength = RelationshipStrength::moderate;
            rationale = "Granularity determines the detail level of records. If the granularity changes, the record format may need adjustment — but records are produced by the tracking system, not directly defined by the policy declaration.";
        }
        part def ActivityGranularity {
            doc /* Policy declaration: the granularity level at which
                 * activity is tracked for a given business area. */
            attribute businessArea : String;
            attribute currentLevel : GranularityLevel;
            attribute targetLevel : GranularityLevel;
            attribute migrationNotes : String;
        }

        @CatalogueTag { bmmConcern = "ActivityModel"; classification = "General"; }
        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "IAO:InformationContentEntity";
            mappingNotes = "A mapping from activity to financial cost. Characterising, not process-like.";
        }
        @UserFacing {
            friendlyName = "Activity Cost Allocation";
            shortDescription = "The mapping from an activity type to its financial cost.";
        }
        @PurposiveDescription {
            description = "The mapping from an activity to its financial cost — how much does it cost each time this kind of work is done? When you define cost allocations, the system can connect your activity model to your financial model, making resource consumption visible in financial terms.";
        }
        @Comprehension {
            surfaceEnumValues = false;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "ActivityType";
            strength = RelationshipStrength::moderate;
            rationale = "Cost allocations are defined per activity type. If the allocation changes (method, estimated cost), the activity type may need reviewing — but a financial change to how the activity is costed does not redefine what the activity type is.";
        }
        @WeightedRelationship {
            target = "CostDriver";
            strength = RelationshipStrength::moderate;
            rationale = "Cost allocations use cost driver rates to compute per-activity costs. If the allocation method changes, the cost driver may need reviewing — but the driver describes the resource's cost behaviour independently of how individual activities are costed against it.";
        }
        @WeightedRelationship {
            target = "UnitEconomics";
            strength = RelationshipStrength::moderate;
            rationale = "Cost allocations ultimately feed unit economics through cost drivers. If an allocation changes, unit economics may need updating — but the relationship is mediated through cost drivers, not direct.";
        }
        part def ActivityCostAllocation {
            doc /* The mapping from an activity (or aggregate) to its
                 * financial cost. Makes resource consumption visible
                 * to the financial model. */
            ref activityType : ActivityType;
            attribute allocationMethod : String;
            attribute estimatedCostPerUnit : Real;
            attribute costNotes : String;
        }
    }

    // =================================================================
    // RESOURCE PLANNING — What resources and capabilities are needed
    // =================================================================

    package ResourcePlanning {
        private import ScalarValues::*;
        private import BusinessModel::ServiceConcept::*;
        private import BusinessStrategy::*;

        doc /* Defines the resources required to operate the service
             * delivery system: people, technology, estate, licences,
             * and external services. Resources are organised into
             * capabilities (combinations that produce service
             * functions), capacity models (throughput relationships),
             * and constraints (limits on availability and use).
             *
             * Phase 7: satisfy relationships from StrategicObjective
             * requirements (in BusinessStrategy) to Capability usages
             * here. These must be in a different package from the
             * requirement defs per Syside constraint.
             *
             * Source: gsl-service-business-meta-modelling.md section 3.3 */

        // -- Part definitions ----------------------------------

        @CatalogueTag { bmmConcern = "ResourceCapability"; classification = "General"; }
        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "IAO:PlanSpecification";
            mappingNotes = "A category specification defining what a kind of resource is. The actual resource is an IndependentContinuant; the type is the specification.";
        }
        @UserFacing {
            friendlyName = "Resource Type";
            shortDescription = "A category of resource needed to run the service — people, equipment, premises, or external services.";
        }
        @PurposiveDescription {
            description = "A kind of thing your business needs in order to operate — staff, equipment, premises, technology, or external services such as a laboratory or a contractor. The system holds each resource type as a tracked concept. When you define your resource types, the system uses them to plan capacity, understand your cost base, and identify where you might be constrained.";
        }
        @Comprehension {
            surfaceEnumValues = false;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "ResourceInstance";
            strength = RelationshipStrength::strong;
            rationale = "Instances are typed by ResourceType. If the type definition changes (category, cost profile, capacity unit), every instance of that type needs reassessment.";
        }
        @WeightedRelationship {
            target = "ResourceConstraint";
            strength = RelationshipStrength::strong;
            rationale = "Constraints are scoped to specific resource types. If the resource type changes, the constraints that limit its availability need reassessment — a constraint on a specific resource assumes specific properties of that type.";
        }
        @WeightedRelationship {
            target = "Capability";
            strength = RelationshipStrength::moderate;
            rationale = "Capabilities combine resources into service functions. A change to a resource type may require reviewing the capabilities that use it, but capabilities are resilient to substitution within a resource category.";
        }
        @WeightedRelationship {
            target = "CapacityModel";
            strength = RelationshipStrength::moderate;
            rationale = "Capacity models describe throughput given a resource configuration. A change to a resource type may affect throughput calculations, but the relationship is mediated through the specific configuration.";
        }
        @WeightedRelationship {
            target = "CostDriver";
            strength = RelationshipStrength::moderate;
            rationale = "Cost drivers are linked to resources. A change to a resource type (especially its cost profile) may require reviewing the associated cost driver, but the link is structural rather than definitional.";
        }
        @WeightedRelationship {
            target = "ActivityType";
            strength = RelationshipStrength::moderate;
            rationale = "Activities consume resources. A change to a resource type may affect which activities can be performed, but the coupling is many-to-many and context-dependent.";
        }
        part def ResourceType {
            doc /* A category of resource required to operate the
                 * service delivery system. Each type has acquisition
                 * characteristics, capacity constraints, and cost
                 * profiles. */
            attribute resourceTypeName : String;
            attribute category : String;           // personnel, technology, estate, insurance, external service
            attribute acquisitionMethod : String;  // employed, contracted, subscribed, purchased, rented
            attribute costProfile : String;        // e.g. "£5,000/FTE/month"
            attribute capacityUnit : String;       // FTE, instances, seats, hours
        }

        @CatalogueTag { bmmConcern = "ResourceCapability"; classification = "General"; }
        @BfoType {
            bfoClass = "Role";
            midLevelClass = "CCO:Agent";
            mappingNotes = "A planning-level archetype — a role. Same person can be different ResourceInstances. CCO:Agent for personnel; pipeline specialises by category attribute.";
        }
        @UserFacing {
            friendlyName = "Resource Instance";
            shortDescription = "A specific resource available at a defined capacity and cost.";
        }
        @PurposiveDescription {
            description = "A specific resource available to your business at a defined capacity and cost — not a named individual, but a planning-level description like 'a prescribing clinician at 0.5 FTE' or 'one licensed copy of the booking system'. When you define resource instances, the system uses them to model your actual operating capacity.";
        }
        @Comprehension {
            surfaceEnumValues = false;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "ResourceType";
            strength = RelationshipStrength::moderate;
            rationale = "An instance is a concrete realisation of its type. If the instance changes (capacity, cost, availability), the type may need reviewing — but an operational change to one instance does not redefine the resource type's category, acquisition method, or capacity unit.";
        }
        @WeightedRelationship {
            target = "CapacityModel";
            strength = RelationshipStrength::moderate;
            rationale = "Capacity models are built from resource configurations. A change to an instance (e.g. clinician drops from 0.8 to 0.5 FTE) may require reviewing the throughput calculation, but the capacity model aggregates across instances.";
        }
        part def ResourceInstance {
            doc /* A specific resource available to the business at
                 * a defined capacity and cost. Represents planning-
                 * level archetypes ("a prescribing clinician at
                 * 0.5 FTE") rather than named individuals. */
            attribute instanceName : String;
            ref resourceType : ResourceType;
            attribute capacity : String;           // e.g. "0.5 FTE", "1 instance"
            attribute availabilityNotes : String;
            attribute costPerUnit : Real;
            attribute costBasis : String;          // per month, per hour, per use
        }

        @CatalogueTag { bmmConcern = "ResourceCapability"; classification = "General"; }
        @BfoType {
            bfoClass = "Disposition";
            midLevelClass = "CCO:ArtifactFunction";
            mappingNotes = "An organised ability — what the business can do given resources. Disposition because it describes potential, not actuality. CCO:ArtifactFunction because designed.";
        }
        @UserFacing {
            friendlyName = "Capability";
            shortDescription = "An organised combination of resources that produces a defined service function.";
        }
        @PurposiveDescription {
            description = "An organised combination of resources that together produce a defined service function — like 'the ability to conduct a monitoring review' (which requires a clinician, a lab interface, and a clinical record system). You don't deliver services with individual resources; you deliver them with capabilities. When you define capabilities, the system connects your resources to the service offerings they enable.";
        }
        @Comprehension {
            surfaceEnumValues = false;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "ServiceOffering";
            strength = RelationshipStrength::strong;
            rationale = "Capabilities enable service offerings. If a capability changes, the offerings it enables need reassessment — you can't offer what you can't deliver.";
        }
        @WeightedRelationship {
            target = "ResourceType";
            strength = RelationshipStrength::strong;
            rationale = "Capabilities are defined by the resources they combine. If a capability changes (e.g. a new resource requirement is added), the resource types involved need reassessment.";
        }
        @WeightedRelationship {
            target = "ObjectiveCapabilityMapping";
            strength = RelationshipStrength::moderate;
            rationale = "Capabilities are the downstream end of strategy-to-operations traceability. If a capability changes, the mapping from strategic objectives to that capability may need reviewing, but the mapping is a declared connection, not a definitional dependency.";
        }
        @WeightedRelationship {
            target = "CapacityModel";
            strength = RelationshipStrength::moderate;
            rationale = "Capacity models describe throughput for a resource configuration that delivers a capability. If the capability changes, the throughput model may need recalibrating, but the relationship is indirect.";
        }
        part def Capability {
            doc /* An organised combination of resources that produces
                 * a defined service function. Capabilities bridge the
                 * gap between raw resources and service delivery — you
                 * don't deliver care with "a doctor" and "a system";
                 * you deliver it with "the ability to conduct a hormone
                 * therapy monitoring review."
                 *
                 * Phase 7: enabledServiceOfferings is a typed ref to
                 * ServiceOffering[0..*] (same-file cross-package ref).
                 * enabledOfferingsDescription retains the human-readable
                 * summary. */
            attribute capabilityName : String;
            attribute description : String;
            attribute requiredResources : String;   // descriptive: "1 prescribing clinician + EHRbase CDR + lab interface"
            ref enabledServiceOfferings : ServiceConcept::ServiceOffering[0..*];
            attribute enabledOfferingsDescription : String;
        }

        @CatalogueTag { bmmConcern = "ResourceCapability"; classification = "General"; }
        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "IAO:InformationContentEntity";
            mappingNotes = "A planning assertion relating resource configuration to throughput. A claim about the system.";
        }
        @UserFacing {
            friendlyName = "Capacity Model";
            shortDescription = "The relationship between your resource configuration and service throughput.";
        }
        @PurposiveDescription {
            description = "The relationship between your resource configuration and how much service you can deliver — for example, 'with one clinician at 0.5 FTE, we can support 20 active patients.' This is a planning assertion that the system holds, not a computed formula. When you define a capacity model, the system knows your throughput limits and can surface when you're approaching them.";
        }
        @Comprehension {
            surfaceEnumValues = false;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "ResourceType";
            strength = RelationshipStrength::moderate;
            rationale = "A capacity model makes claims about throughput given a resource configuration. If the capacity model changes, the resource types it references may need reassessment — but the resource type exists independently of any one capacity model.";
        }
        @WeightedRelationship {
            target = "ResourceConstraint";
            strength = RelationshipStrength::moderate;
            rationale = "Capacity models and constraints are complementary planning concepts. If the capacity model changes (e.g. higher throughput targets), the constraints that limit resource availability may need reviewing.";
        }
        part def CapacityModel {
            doc /* The relationship between resource configuration and
                 * service throughput. A planning assertion, not a
                 * computed formula — the formula representation lives
                 * in BusinessScenarios::ProjectionFormula.
                 *
                 * CapacityModel says "with 1 clinician at 8 sessions/
                 * day we can see 80 patients/week." ProjectionFormula
                 * computes "at month 12 with 0.8 FTE and 55 active
                 * patients, utilisation is 78%." */
            attribute resourceConfiguration : String;
            attribute throughputPerPeriod : String;
            attribute periodUnit : String;         // per day, per week, per month
            attribute assumptions : String;
            attribute bottleneck : String;          // which resource constrains throughput
        }

        @CatalogueTag { bmmConcern = "ResourceCapability"; classification = "General"; }
        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "IAO:InformationContentEntity";
            mappingNotes = "A recorded limit on resource availability. The constraint is information; its effect is felt through processes.";
        }
        @UserFacing {
            friendlyName = "Resource Constraint";
            shortDescription = "A limit on resource availability that affects service delivery.";
        }
        @PurposiveDescription {
            description = "A limit on the availability or use of a resource that affects your ability to deliver services — regulatory, financial, temporal, or contractual. When you define resource constraints, the system tracks them alongside your resources so that capacity planning reflects real-world limits, not just theoretical availability.";
        }
        @Comprehension {
            surfaceEnumValues = false;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "ResourceType";
            strength = RelationshipStrength::strong;
            rationale = "Constraints are defined against specific resource types. If a constraint changes (e.g. a regulatory limit is tightened or lifted), the resource type it governs needs reassessment — the type's effective availability and cost profile may have changed.";
        }
        @WeightedRelationship {
            target = "CapacityModel";
            strength = RelationshipStrength::moderate;
            rationale = "Constraints limit what a resource configuration can deliver. If a constraint changes, the throughput assumptions in the capacity model may need reviewing.";
        }
        part def ResourceConstraint {
            doc /* A constraint on resource availability or use that
                 * affects service delivery. May be regulatory,
                 * financial, temporal, or contractual.
                 *
                 * Phase 7: regulatorySourceDescription retains the
                 * human-readable reference. Formal ref to
                 * Enterprise::Regulation requirement defs is deferred
                 * — ref to a requirement def (as opposed to a part
                 * def) requires further investigation of the target
                 * syntax. */
            attribute constraintName : String;
            attribute constraintType : String;     // regulatory, financial, temporal, contractual, practical
            ref affectedResource : ResourceType;
            attribute limit : String;
            attribute regulatorySourceDescription : String;   // e.g. "Enterprise::Regulation" or empty
        }

        // -- Inventory tracking abstraction ----------------------
        // Business meta model concept: operational stock tracking
        // for any business that stocks things.
        // Added Session 29: CSW Extension Phase 10 (item 8.2).
        // Source: gsl-spec-catalogue-inventory-v2.1.md §8.2

        @CatalogueTag { bmmConcern = "ResourceCapability"; classification = "General"; }
        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "IAO:MeasurementDatum";
            mappingNotes = "A point-in-time stock measurement. IAO:MeasurementDatum because it captures a quantity at a specific time.";
        }
        @UserFacing {
            friendlyName = "Inventory Record";
            shortDescription = "A point-in-time record of stock level for a catalogue item.";
        }
        @PurposiveDescription {
            description = "A point-in-time record of how much stock you have of something in your catalogue — how many tablets, how many bags of coffee beans, how many bottles of cleaning product. This is operational tracking: it tells the system what you have right now, so it can flag when you're running low. Distinct from resource planning, which is about strategic capacity.";
        }
        @Comprehension {
            surfaceEnumValues = false;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "CatalogueEntry";
            strength = RelationshipStrength::strong;
            rationale = "Inventory tracks stock of catalogue items. If the inventory record changes (e.g. stock level drops below threshold), the catalogue entry's availability status needs reassessment — the catalogue promises what inventory must deliver.";
        }
        part def InventoryRecord {
            doc /* A point-in-time record of stock level for an item
                 * in the catalogue. References a catalogue entry
                 * because inventory is scoped to what the business
                 * currently offers.
                 *
                 * Distinct from ResourceInstance (planning-level):
                 * ResourceInstance models "we have 0.5 FTE of
                 * clinician capacity." InventoryRecord models "we
                 * have 47 tablets of Estradiol Valerate in stock."
                 *
                 * ResourceInstance is strategic planning.
                 * InventoryRecord is operational tracking.
                 *
                 * Business meta model concept.
                 *
                 * Source: gsl-spec-catalogue-inventory-v2.1.md §8.2 */
            ref catalogueEntry : CatalogueEntry;
            attribute quantityOnHand : Integer;
            attribute stockStatus : String;
            attribute lowStockThreshold : Integer;
            attribute lastRestocked : String;
            attribute quantityNotes : String;
        }

        // -- GSL Lean Clinical resource instantiation ----------

        part prescribingClinician : ResourceType {
            doc /* Clinician with prescribing qualification and RCP
                 * Certificate in Gender Identity Healthcare. The
                 * primary clinical resource and capacity bottleneck. */
            attribute :>> resourceTypeName = "Prescribing clinician";
            attribute :>> category = "personnel";
            attribute :>> acquisitionMethod = "employed or contracted";
            attribute :>> costProfile = "£5,000 per FTE per month";
            attribute :>> capacityUnit = "FTE";
        }

        part administrativeSupport : ResourceType {
            attribute :>> resourceTypeName = "Administrative support";
            attribute :>> category = "personnel";
            attribute :>> acquisitionMethod = "employed";
            attribute :>> costProfile = "£1,800 per FTE per month";
            attribute :>> capacityUnit = "FTE";
        }

        part technologyPlatform : ResourceType {
            doc /* The GSL platform: SvelteKit web app, Temporal
                 * orchestration, EHRbase CDR, hosting infrastructure. */
            attribute :>> resourceTypeName = "Technology platform";
            attribute :>> category = "technology";
            attribute :>> acquisitionMethod = "self-built and hosted";
            attribute :>> costProfile = "£200 per month fixed";
            attribute :>> capacityUnit = "instances";
        }

        part clinicalPremises : ResourceType {
            attribute :>> resourceTypeName = "Clinical premises";
            attribute :>> category = "estate";
            attribute :>> acquisitionMethod = "rented or shared";
            attribute :>> costProfile = "included in overhead allocation";
            attribute :>> capacityUnit = "rooms";
        }

        part professionalIndemnity : ResourceType {
            attribute :>> resourceTypeName = "Professional indemnity insurance";
            attribute :>> category = "insurance";
            attribute :>> acquisitionMethod = "annual policy";
            attribute :>> costProfile = "£250 per month";
            attribute :>> capacityUnit = "policies";
        }

        part laboratoryServices : ResourceType {
            doc /* External pathology laboratory for blood monitoring.
                 * Variable cost — scales with patient volume. */
            attribute :>> resourceTypeName = "Laboratory services";
            attribute :>> category = "external service";
            attribute :>> acquisitionMethod = "contracted";
            attribute :>> costProfile = "£45 per blood panel";
            attribute :>> capacityUnit = "panels";
        }

        part clinicianMonth1to9 : ResourceInstance {
            doc /* Initial clinician capacity: 0.5 FTE for the first
                 * 9 months. Sufficient for up to ~20 active patients. */
            attribute :>> instanceName = "Prescribing clinician (months 1-9)";
            ref :>> resourceType = prescribingClinician;
            attribute :>> capacity = "0.5 FTE";
            attribute :>> availabilityNotes = "3 clinical days per fortnight";
            attribute :>> costPerUnit = 2500.0;
            attribute :>> costBasis = "per month";
        }

        part clinicianMonth10to24 : ResourceInstance {
            doc /* Scaled clinician capacity: 0.8 FTE from month 10.
                 * Supports growth to ~40 active patients. */
            attribute :>> instanceName = "Prescribing clinician (months 10-24)";
            ref :>> resourceType = prescribingClinician;
            attribute :>> capacity = "0.8 FTE";
            attribute :>> availabilityNotes = "4 clinical days per week";
            attribute :>> costPerUnit = 4000.0;
            attribute :>> costBasis = "per month";
        }

        part adminInstance : ResourceInstance {
            attribute :>> instanceName = "Administrative support";
            ref :>> resourceType = administrativeSupport;
            attribute :>> capacity = "0.3 FTE";
            attribute :>> availabilityNotes = "1.5 days per week";
            attribute :>> costPerUnit = 540.0;
            attribute :>> costBasis = "per month";
        }

        part prescribingCapability : Capability {
            doc /* The ability to prescribe and monitor hormone therapy.
                 * The core clinical capability of the Lean Clinical
                 * variant. */
            attribute :>> capabilityName = "Prescribing and monitoring";
            attribute :>> description = "Prescribe, titrate, and monitor hormone therapy with full audit trail";
            attribute :>> requiredResources = "1 prescribing clinician + EHRbase CDR + lab interface + prescribing system";
            attribute :>> enabledOfferingsDescription = "Hormone Therapy Initiation, Ongoing Monitoring";
        }

        part assessmentCapability : Capability {
            attribute :>> capabilityName = "Clinical assessment";
            attribute :>> description = "Comprehensive new patient assessment with structured clinical record";
            attribute :>> requiredResources = "1 prescribing clinician + video consulting + forms platform + EHRbase CDR";
            attribute :>> enabledOfferingsDescription = "Initial Assessment";
        }

        part monitoringCapability : Capability {
            attribute :>> capabilityName = "Blood monitoring";
            attribute :>> description = "Order, receive, and review blood monitoring results";
            attribute :>> requiredResources = "Lab interface + EHRbase CDR + prescribing clinician for review";
            attribute :>> enabledOfferingsDescription = "Hormone Therapy Initiation, Ongoing Monitoring";
        }

        part leanClinicalCapacity : CapacityModel {
            doc /* Capacity model for the Lean Clinical variant.
                 * Clinician time is the primary bottleneck. */
            attribute :>> resourceConfiguration = "1 prescribing clinician at 0.5-0.8 FTE";
            attribute :>> throughputPerPeriod = "20-40 active patients";
            attribute :>> periodUnit = "concurrent active caseload";
            attribute :>> assumptions = "8 monitoring slots per week at 0.5 FTE, 30 min per review, 2 hours admin per day";
            attribute :>> bottleneck = "Prescribing clinician time";
        }

        part maxPatientsPerClinician : ResourceConstraint {
            attribute :>> constraintName = "Maximum active patients per clinician";
            attribute :>> constraintType = "practical";
            ref :>> affectedResource = prescribingClinician;
            attribute :>> limit = "40 active patients per FTE clinician";
            attribute :>> regulatorySourceDescription = "";
        }

        part prescribingQualification : ResourceConstraint {
            doc /* Regulatory requirement: the prescribing clinician
                 * must hold appropriate qualification for hormone
                 * prescribing. Maps to Enterprise::Regulation. */
            attribute :>> constraintName = "Prescribing qualification";
            attribute :>> constraintType = "regulatory";
            ref :>> affectedResource = prescribingClinician;
            attribute :>> limit = "Must hold prescribing qualification and gender identity healthcare credential";
            attribute :>> regulatorySourceDescription = "Enterprise::Regulation";
        }

        // -- Variant B (Full Platform) resource instantiation --

        part genderCoach : ResourceType {
            doc /* Trained gender identity coach. Non-clinical role
                 * delivering structured coaching sessions. */
            attribute :>> resourceTypeName = "Gender identity coach";
            attribute :>> category = "personnel";
            attribute :>> acquisitionMethod = "contracted";
            attribute :>> costProfile = "£3,000 per FTE per month";
            attribute :>> capacityUnit = "FTE";
        }

        part communityModerator : ResourceType {
            doc /* Part-time community management role. Moderates
                 * peer forums, facilitates groups, manages content. */
            attribute :>> resourceTypeName = "Community moderator";
            attribute :>> category = "personnel";
            attribute :>> acquisitionMethod = "employed";
            attribute :>> costProfile = "£2,000 per FTE per month";
            attribute :>> capacityUnit = "FTE";
        }

        part coachInstance : ResourceInstance {
            attribute :>> instanceName = "Gender identity coach";
            ref :>> resourceType = genderCoach;
            attribute :>> capacity = "0.5 FTE";
            attribute :>> availabilityNotes = "2.5 days per week";
            attribute :>> costPerUnit = 1500.0;
            attribute :>> costBasis = "per month";
        }

        part moderatorInstance : ResourceInstance {
            attribute :>> instanceName = "Community moderator";
            ref :>> resourceType = communityModerator;
            attribute :>> capacity = "0.2 FTE";
            attribute :>> availabilityNotes = "1 day per week";
            attribute :>> costPerUnit = 400.0;
            attribute :>> costBasis = "per month";
        }

        part secondClinicianMonth6to24 : ResourceInstance {
            doc /* Second clinician added at month 6 in Variant B.
                 * Steps from 0.5 to 1.0 FTE at month 12. */
            attribute :>> instanceName = "Second prescribing clinician (months 6-24)";
            ref :>> resourceType = prescribingClinician;
            attribute :>> capacity = "0.5 FTE stepping to 1.0 FTE at month 12";
            attribute :>> availabilityNotes = "Variant B only — earlier scaling than Variant A";
            attribute :>> costPerUnit = 2500.0;
            attribute :>> costBasis = "per month (at 0.5 FTE)";
        }

        part coachingCapability : Capability {
            attribute :>> capabilityName = "Gender identity coaching";
            attribute :>> description = "Deliver structured coaching sessions supporting social transition and wellbeing";
            attribute :>> requiredResources = "1 gender identity coach + video consulting + scheduling platform";
            attribute :>> enabledOfferingsDescription = "Coaching";
        }

        part communityCapability : Capability {
            attribute :>> capabilityName = "Peer community platform";
            attribute :>> description = "Operate moderated peer forums, facilitated groups, and community events";
            attribute :>> requiredResources = "1 community moderator + community platform software + content moderation tools";
            attribute :>> enabledOfferingsDescription = "Community";
        }

        part fullPlatformCapacity : CapacityModel {
            doc /* Capacity model for the Full Platform variant.
                 * Multiple resource types with different bottlenecks. */
            attribute :>> resourceConfiguration = "2 prescribing clinicians (1.5-2.0 FTE total) + 0.5 FTE coach + 0.2 FTE moderator";
            attribute :>> throughputPerPeriod = "80-100 active patients";
            attribute :>> periodUnit = "concurrent active caseload";
            attribute :>> assumptions = "Clinical capacity doubled vs Variant A; coaching at 10 sessions/week; community moderation 1 day/week";
            attribute :>> bottleneck = "Prescribing clinician time (clinical); coach availability (coaching)";
        }

        // -- Objective → Capability traceability ----------------
        //
        // Phase 7. Structural traceability from strategic
        // objectives to the capabilities that achieve them.
        //
        // Design note: SysML v2 satisfy requires the by-target
        // to be a constraint or requirement usage (not a part
        // usage). Capability usages are parts. Therefore the
        // traceability is expressed via a dedicated mapping
        // part def with typed refs, rather than satisfy.
        //
        // The StrategicObjective remains a requirement def
        // (preserving formal correctness for future satisfy
        // relationships to constraint usages if needed).

        @CatalogueTag { bmmConcern = "ResourceCapability"; classification = "General"; }
        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "IAO:InformationContentEntity";
            mappingNotes = "A declared traceability connection — an assertion linking strategy to operations.";
        }
        @UserFacing {
            friendlyName = "Objective–Capability Mapping";
            shortDescription = "A declared connection between a strategic objective and the capabilities that support it.";
        }
        @PurposiveDescription {
            description = "A declared connection between a strategic objective and the capabilities that contribute to achieving it. When you map objectives to capabilities, the system can trace from 'what are we trying to achieve?' down to 'what resources and service functions make that possible?' — closing the loop between strategy and operations.";
        }
        @Comprehension {
            surfaceEnumValues = false;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "Capability";
            strength = RelationshipStrength::strong;
            rationale = "The mapping declares which capabilities support a strategic objective. If the mapping changes, the capabilities involved need reassessment — they may gain or lose strategic justification.";
        }
        part def ObjectiveCapabilityMapping {
            doc /* Maps a StrategicObjective to the Capability
                 * usages that contribute to achieving it.
                 * Phase 7 traceability pattern. */
            ref strategicObjective : StrategicObjective;
            ref supportingCapabilities : Capability[1..*];
        }

        part patientCohortMapping : ObjectiveCapabilityMapping {
            doc /* objectivePatientCohort is achieved through
                 * prescribing, assessment, and monitoring. */
            ref :>> strategicObjective = objectivePatientCohort;
        }

        part sharedCareMapping : ObjectiveCapabilityMapping {
            doc /* objectiveSharedCare is achieved through
                 * prescribing and monitoring capabilities
                 * extended with GP shared care protocols. */
            ref :>> strategicObjective = objectiveSharedCare;
        }

        part platformLaunchMapping : ObjectiveCapabilityMapping {
            doc /* objectivePlatformLaunch is achieved through
                 * assessment and prescribing capabilities
                 * exposed via the patient portal. */
            ref :>> strategicObjective = objectivePlatformLaunch;
        }

        part breakEvenMapping : ObjectiveCapabilityMapping {
            doc /* objectiveBreakEven is a financial outcome
                 * achieved through the combined operation of
                 * all clinical capabilities at sufficient
                 * volume. No single capability satisfies it. */
            ref :>> strategicObjective = objectiveBreakEven;
        }
    }

    // =================================================================
    // FINANCIAL PLANNING — How money flows through the business
    // =================================================================

    package FinancialPlanning {
        private import ScalarValues::*;
        private import BusinessModel::ResourcePlanning::*;
        private import BusinessModel::ServiceConcept::*;
        private import BusinessScenarios::*;

        doc /* Defines the financial structure of the business: how
             * revenue is generated, what drives cost, what the unit
             * economics look like, and how pricing works. This is
             * the "does this work financially?" package.
             *
             * Distinct from Operations::Finance which handles
             * operational accounting (invoicing, payment processing,
             * Xero integration). FinancialPlanning is structural
             * economics — the bank-manager spreadsheet made explicit.
             *
             * Source: gsl-service-business-meta-modelling.md section 3.4 */

        enum def PricingType {
            doc /* The structural pricing model for a service offering. */
            perEpisode;
            subscription;
            tiered;
            slidingScale;
            flatFee;
        }

        @CatalogueTag { bmmConcern = "FinancialModel"; classification = "General"; }
        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "IAO:PlanSpecification";
            mappingNotes = "A specification of how money flows in. The stream is the structural specification; actual transactions are Processes.";
        }
        @UserFacing {
            friendlyName = "Revenue Stream";
            shortDescription = "A mechanism by which the business generates income from its services.";
        }
        @PurposiveDescription {
            description = "A way your business earns money — each revenue stream connects a customer segment, a triggering event (like completing an assessment or renewing a subscription), and a pricing model. When you define your revenue streams, the system can project income and connect it to the services that generate it.";
        }
        @Comprehension {
            surfaceEnumValues = false;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "PricingModel";
            strength = RelationshipStrength::strong;
            rationale = "Each revenue stream references a pricing model. If the revenue stream changes (e.g. new trigger event, different source segment), the pricing model may need reassessment to match.";
        }
        @WeightedRelationship {
            target = "FinancialProjection";
            strength = RelationshipStrength::strong;
            rationale = "Financial projections aggregate revenue streams. If a revenue stream changes, the projection that depends on it needs reassessment.";
        }
        @WeightedRelationship {
            target = "UnitEconomics";
            strength = RelationshipStrength::moderate;
            rationale = "Revenue streams inform the revenue side of unit economics. If a stream changes, revenue-per-unit may need reviewing — but unit economics are per-offering, not per-stream.";
        }
        part def RevenueStream {
            doc /* A mechanism by which income is generated. */
            attribute streamName : String;
            attribute sourceSegment : String;
            attribute triggerEvent : String;
            ref pricingModel : PricingModel;
            attribute projectedVolume : String;
        }

        @CatalogueTag { bmmConcern = "FinancialModel"; classification = "General"; }
        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "IAO:InformationContentEntity";
            mappingNotes = "A characterisation of a resource's cost behaviour. About the resource, not the resource itself.";
        }
        @UserFacing {
            friendlyName = "Cost Driver";
            shortDescription = "A structural factor that generates cost in the business — linked to a resource or activity.";
        }
        @PurposiveDescription {
            description = "A structural factor that generates cost in your business — something that, as it scales or recurs, drives your expenditure. Each cost driver is linked to a resource or an activity. When you define your cost drivers, the system connects your cost structure to the resources and activities that produce it, so you can see where money goes and why.";
        }
        @Comprehension {
            surfaceEnumValues = false;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "ResourceType";
            strength = RelationshipStrength::moderate;
            rationale = "Cost drivers characterise resources financially. If a cost driver changes (e.g. unit cost revised), the resource type's cost profile may need updating — but the resource type's category, acquisition method, and structural definition are independent of its cost behaviour.";
        }
        @WeightedRelationship {
            target = "UnitEconomics";
            strength = RelationshipStrength::strong;
            rationale = "Unit economics aggregate costs per service unit. If a cost driver changes, the cost-per-unit calculation needs reassessment — cost drivers are the input to that calculation.";
        }
        @WeightedRelationship {
            target = "ActivityCostAllocation";
            strength = RelationshipStrength::moderate;
            rationale = "Cost allocations map activities to costs. If a cost driver changes, the allocation method may need reviewing — but the allocation is a mapping mechanism, not directly defined by the cost driver.";
        }
        @WeightedRelationship {
            target = "RevenueStream";
            strength = RelationshipStrength::moderate;
            rationale = "Revenue streams and cost drivers together determine profitability. If a cost driver changes significantly, revenue assumptions may need reviewing — but the relationship is indirect, mediated through unit economics and financial projections.";
        }
        part def CostDriver {
            doc /* A structural factor that generates cost. */
            attribute driverName : String;
            ref linkedResource : ResourceType[0..*];
            attribute costBehaviour : String;
            attribute estimatedUnitCost : Real;
            attribute scalingFactor : String;
        }

        @CatalogueTag { bmmConcern = "FinancialModel"; classification = "General"; }
        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "IAO:InformationContentEntity";
            mappingNotes = "Computed/declared financial profile per service unit. Revenue, cost, and margin figures.";
        }
        @UserFacing {
            friendlyName = "Unit Economics";
            shortDescription = "The revenue, cost, and margin for a single unit of service delivery.";
        }
        @PurposiveDescription {
            description = "The financial profile of delivering one unit of a service — what you earn, what it costs, and the margin between them. When you define unit economics for each service offering, the system can assess whether individual services are financially viable and how changes to pricing or costs would affect the picture.";
        }
        @Comprehension {
            surfaceEnumValues = false;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "ServiceOffering";
            strength = RelationshipStrength::moderate;
            rationale = "Unit economics characterise an offering's financial viability. If the unit economics change (e.g. margin drops below zero), the offering itself needs reassessment — but the offering's definition doesn't depend on its economics.";
        }
        @WeightedRelationship {
            target = "FinancialProjection";
            strength = RelationshipStrength::moderate;
            rationale = "Financial projections aggregate unit-level economics. If unit economics change, the projection may need updating — but the projection also depends on volume assumptions and other inputs.";
        }
        part def UnitEconomics {
            doc /* The financial profile of a single unit of service delivery. */
            ref offering : ServiceOffering;
            attribute revenuePerUnit : Real;
            attribute costPerUnit : Real;
            attribute marginPerUnit : Real;
            attribute breakdownNotes : String;
        }

        @CatalogueTag { bmmConcern = "FinancialModel"; classification = "General"; }
        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "IAO:PlanSpecification";
            mappingNotes = "Pricing rules governing future commercial exchanges.";
        }
        @UserFacing {
            friendlyName = "Pricing Model";
            shortDescription = "How prices are set for services — per-episode, subscription, tiered, or other basis.";
        }
        @PurposiveDescription {
            description = "The logic that determines what a customer pays for a service — per-episode, subscription, tiered, sliding scale, or flat fee. When you define a pricing model, the system applies it to the relevant service offerings and uses it in revenue projections and unit economics calculations.";
        }
        @Comprehension {
            surfaceEnumValues = true;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "RevenueStream";
            strength = RelationshipStrength::strong;
            rationale = "Revenue streams reference a pricing model as their revenue mechanism. If the pricing model changes, the revenue projections that depend on it need reassessment.";
        }
        @WeightedRelationship {
            target = "ServiceOffering";
            strength = RelationshipStrength::moderate;
            rationale = "Pricing models define how offerings are charged for. If the pricing logic changes, the offering's commercial packaging may need reviewing — but the offering itself (what is delivered, to whom, using what resources) is defined independently of how it is priced.";
        }
        @WeightedRelationship {
            target = "UnitEconomics";
            strength = RelationshipStrength::moderate;
            rationale = "Unit economics calculate margin per unit of service. If the pricing model changes, the revenue-per-unit figure needs reviewing — but unit economics also depend on cost factors that are independent of pricing.";
        }
        part def PricingModel {
            doc /* The logic that determines what a customer pays. */
            attribute pricingModelName : String;
            attribute pricingType : PricingType;
            attribute basePrice : Real;
            attribute adjustmentLogic : String;
            attribute applicableOfferings : String;
        }

        @CatalogueTag { bmmConcern = "FinancialModel"; classification = "General"; }
        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "IAO:PlanSpecification";
            mappingNotes = "A forward-looking financial picture. Explicitly a planning instrument combining assumptions.";
        }
        @UserFacing {
            friendlyName = "Financial Projection";
            shortDescription = "A forward-looking financial picture combining revenues, costs, and growth assumptions.";
        }
        @PurposiveDescription {
            description = "A named projection of your business's financial future over a defined period — combining your revenue streams, cost drivers, and growth assumptions into a forward-looking picture. When you define a financial projection, the system links it to a scenario so you can compare different versions of the future side by side.";
        }
        @Comprehension {
            surfaceEnumValues = false;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "RevenueStream";
            strength = RelationshipStrength::moderate;
            rationale = "A projection aggregates revenue streams. If the projection changes (e.g. revised timeline, different scenario), the revenue streams feeding it may need reviewing — but revenue streams exist independently of any one projection.";
        }
        @WeightedRelationship {
            target = "CostDriver";
            strength = RelationshipStrength::moderate;
            rationale = "A projection aggregates cost drivers. If the projection changes, the cost assumptions may need reviewing — but cost drivers exist independently of any one projection.";
        }
        part def FinancialProjection {
            doc /* A named financial projection linked to a scenario.
                 * Lightweight placeholder — full mechanics in
                 * BusinessScenarios. */
            attribute projectionName : String;
            ref scenario : ScenarioDefinition;
            attribute timelineMonths : Integer;
            attribute revenueFormula : String;
            attribute costFormula : String;
            attribute breakEvenIndicator : String;
        }

        // -- GSL Lean Clinical financial instantiation ----------

        part assessmentRevenue : RevenueStream {
            attribute :>> streamName = "Assessment fees";
            attribute :>> sourceSegment = "Self-referring individuals, GP-referred patients";
            attribute :>> triggerEvent = "Completion of initial assessment episode";
            ref :>> pricingModel = perEpisodePricing;
            attribute :>> projectedVolume = "4 per month (year 1), 6 per month (year 2)";
        }

        part monitoringRevenue : RevenueStream {
            attribute :>> streamName = "Monitoring fees";
            attribute :>> sourceSegment = "Patients in stable monitoring";
            attribute :>> triggerEvent = "Quarterly monitoring review";
            ref :>> pricingModel = perEpisodePricing;
            attribute :>> projectedVolume = "grows with stable cohort — see projection";
        }

        part clinicianCost : CostDriver {
            attribute :>> driverName = "Clinician cost";
            ref :>> linkedResource = prescribingClinician;
            attribute :>> costBehaviour = "semi-variable — fixed FTE cost, scaled in steps as caseload grows";
            attribute :>> estimatedUnitCost = 5000.0;
            attribute :>> scalingFactor = "per FTE per month";
        }

        part adminCost : CostDriver {
            attribute :>> driverName = "Administrative support cost";
            ref :>> linkedResource = administrativeSupport;
            attribute :>> costBehaviour = "semi-variable";
            attribute :>> estimatedUnitCost = 1800.0;
            attribute :>> scalingFactor = "per FTE per month";
        }

        part platformCost : CostDriver {
            attribute :>> driverName = "Platform hosting and infrastructure";
            ref :>> linkedResource = technologyPlatform;
            attribute :>> costBehaviour = "fixed";
            attribute :>> estimatedUnitCost = 200.0;
            attribute :>> scalingFactor = "per month";
        }

        part insuranceCost : CostDriver {
            attribute :>> driverName = "Professional indemnity insurance";
            ref :>> linkedResource = professionalIndemnity;
            attribute :>> costBehaviour = "fixed";
            attribute :>> estimatedUnitCost = 250.0;
            attribute :>> scalingFactor = "per month";
        }

        part labCost : CostDriver {
            attribute :>> driverName = "Laboratory costs";
            ref :>> linkedResource = laboratoryServices;
            attribute :>> costBehaviour = "variable";
            attribute :>> estimatedUnitCost = 45.0;
            attribute :>> scalingFactor = "per blood panel";
        }

        part overheadCost : CostDriver {
            attribute :>> driverName = "Overhead allocation";
            attribute :>> costBehaviour = "percentage of direct cost";
            attribute :>> estimatedUnitCost = 25.0;
            attribute :>> scalingFactor = "percentage of direct cost";
        }

        part assessmentUnitEconomics : UnitEconomics {
            ref :>> offering = initialAssessment;
            attribute :>> revenuePerUnit = 600.0;
            attribute :>> costPerUnit = 350.0;
            attribute :>> marginPerUnit = 250.0;
            attribute :>> breakdownNotes = "Clinician 2hrs £125, baseline bloods £90, platform/admin £65, overhead £70";
        }

        part monitoringUnitEconomics : UnitEconomics {
            ref :>> offering = ongoingMonitoring;
            attribute :>> revenuePerUnit = 150.0;
            attribute :>> costPerUnit = 106.0;
            attribute :>> marginPerUnit = 44.0;
            attribute :>> breakdownNotes = "Clinician 30min £31, blood panel £45, admin/platform £10, overhead £20";
        }

        part perEpisodePricing : PricingModel {
            attribute :>> pricingModelName = "Per-episode pricing";
            attribute :>> pricingType = PricingType::perEpisode;
            attribute :>> basePrice = 0.0;
            attribute :>> adjustmentLogic = "Fixed fee per service offering. Assessment £600, monitoring review £150.";
            attribute :>> applicableOfferings = "Initial Assessment, Hormone Therapy Initiation, Ongoing Monitoring";
        }

        part leanClinicalProjection : FinancialProjection {
            attribute :>> projectionName = "Lean Clinical 24-month projection";
            ref :>> scenario = leanClinicalScenario;
            attribute :>> timelineMonths = 24;
            attribute :>> revenueFormula = "assessment fees (volume x price) + monitoring fees (stable cohort x quarterly fee)";
            attribute :>> costFormula = "clinician FTE + admin FTE + platform + insurance + lab panels + 25% overhead";
            attribute :>> breakEvenIndicator = "estimated month 14 at base assumptions";
        }

        // -- Variant B (Full Platform) financial instantiation --

        part subscriptionRevenue : RevenueStream {
            doc /* Monthly subscription fee from active patients in
                 * the Full Platform variant. Additive to clinical
                 * episode fees — subscribers also pay per-episode
                 * for clinical services. */
            attribute :>> streamName = "Subscription fees";
            attribute :>> sourceSegment = "Active subscribers (Full Platform patients)";
            attribute :>> triggerEvent = "Monthly subscription renewal";
            ref :>> pricingModel = subscriptionPricing;
            attribute :>> projectedVolume = "grows with active patient cohort";
        }

        part coachCost : CostDriver {
            attribute :>> driverName = "Coach cost";
            ref :>> linkedResource = genderCoach;
            attribute :>> costBehaviour = "semi-variable — fixed FTE cost, added when coaching offering launches";
            attribute :>> estimatedUnitCost = 3000.0;
            attribute :>> scalingFactor = "per FTE per month";
        }

        part moderatorCost : CostDriver {
            attribute :>> driverName = "Community moderator cost";
            ref :>> linkedResource = communityModerator;
            attribute :>> costBehaviour = "semi-variable — fixed FTE cost, added when community launches";
            attribute :>> estimatedUnitCost = 2000.0;
            attribute :>> scalingFactor = "per FTE per month";
        }

        part subscriptionPricing : PricingModel {
            doc /* Monthly subscription covering coaching, education,
                 * and community access. Clinical services remain
                 * per-episode on top of the subscription. */
            attribute :>> pricingModelName = "Monthly subscription";
            attribute :>> pricingType = PricingType::subscription;
            attribute :>> basePrice = 99.0;
            attribute :>> adjustmentLogic = "Flat monthly fee. Clinical episode fees charged separately.";
            attribute :>> applicableOfferings = "Coaching, Education, Community";
        }

        part subscriptionUnitEconomics : UnitEconomics {
            doc /* Per-subscriber economics for the subscription
                 * component only. Clinical episode economics are
                 * separate (assessmentUnitEconomics,
                 * monitoringUnitEconomics). All values are
                 * illustrative placeholders. */
            ref :>> offering = subscriptionBundle;
            attribute :>> revenuePerUnit = 99.0;
            attribute :>> costPerUnit = 55.0;
            attribute :>> marginPerUnit = 44.0;
            attribute :>> breakdownNotes = "Coach allocation £30, moderator allocation £8, platform £12, overhead £5. All values placeholder.";
        }

        part fullPlatformProjection : FinancialProjection {
            attribute :>> projectionName = "Full Platform 24-month projection";
            ref :>> scenario = fullPlatformScenario;
            attribute :>> timelineMonths = 24;
            attribute :>> revenueFormula = "assessment fees + monitoring fees + subscription fees (active subscribers x monthly fee)";
            attribute :>> costFormula = "2 clinician FTE + admin FTE + coach FTE + moderator FTE + platform + insurance + lab panels + 25% overhead";
            attribute :>> breakEvenIndicator = "placeholder — to be determined by projection engine";
        }
    }

    // =================================================================
    // GOVERNANCE MAPPING — How governance obligations are tracked
    // =================================================================

    package GovernanceMapping {
        private import ScalarValues::*;

        doc /* General vocabulary for governance traceability. Defines
             * the structural concepts that any regulated service
             * business needs to track compliance: what the obligations
             * are (GovernanceRequirement) and what records demonstrate
             * compliance (AuditEvidenceRecord).
             *
             * Domain-specific constraint defs and satisfy relationships
             * live in the domain packages (e.g. SudsGovernance), not
             * here — testable conditions are regulation-specific.
             *
             * The traceability chain:
             *   GovernanceRequirement (what must be satisfied)
             *     → constraint def (testable condition, domain-specific)
             *       → satisfy (formal link)
             *         → AuditEvidenceRecord (proof of compliance)
             *
             * Exercises A8 (governance as first-class concern),
             * J8 (governance in toy domains), B2 (vertical mappings).
             *
             * Business meta model concept.
             * Phase 6, Session 42 (19 March 2026). */

        // -- Governance Requirement --------------------------------

        @CatalogueTag { bmmConcern = "Governance"; classification = "General"; }
        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "IAO:ObjectiveSpecification";
            mappingNotes = "A governance obligation — specifies a required state of affairs. The requirement is about the obligation; compliance is a Process.";
        }
        @UserFacing {
            friendlyName = "Governance Requirement";
            shortDescription = "A regulatory or standards obligation that the business must satisfy, with defined evidence.";
        }
        @PurposiveDescription {
            description = "A regulatory, legal, or standards obligation that your business must satisfy — and the system tracks it as a concrete, testable commitment, not just a policy statement. Each governance requirement is connected to the evidence that demonstrates compliance and, where formalised, to the constraint rules that the system can check. When you define governance requirements, the system builds a traceability chain from obligation through to proof.";
        }
        @Comprehension {
            surfaceEnumValues = false;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "AuditEvidenceRecord";
            strength = RelationshipStrength::strong;
            rationale = "Each governance requirement defines what evidence must be produced. If the requirement changes, the evidence records need reassessment — you may need different proof, different frequency, or different responsible roles.";
        }
        @WeightedRelationship {
            target = "ResourceConstraint";
            strength = RelationshipStrength::moderate;
            rationale = "Governance requirements often impose resource constraints (regulatory qualification requirements, capacity limits). If a requirement changes, associated resource constraints may need reviewing — but not all requirements produce resource constraints.";
        }
        @WeightedRelationship {
            target = "StakeholderRelationship";
            strength = RelationshipStrength::moderate;
            rationale = "A change to a governance requirement may require reviewing the relationship through which it is enforced, but the relationship exists independently of any single requirement (H1, H5).";
        }
        requirement def GovernanceRequirement {
            doc /* A regulatory, legal, or standards obligation that
                 * the business must satisfy. General vocabulary —
                 * applicable to COSHH, CQC, GDPR, food hygiene,
                 * professional standards, or any regulatory context.
                 *
                 * Domain-specific requirement usages redefine these
                 * attributes with concrete values. The satisfy chain
                 * connects each requirement to constraint usages
                 * that formalise the testable conditions.
                 *
                 * Business meta model concept. */
            attribute requirementId : String;
            attribute title : String;
            attribute regulatorySource : String;
            attribute complianceDescription : String;
            attribute evidenceRequired : String;
        }

        // -- Audit Evidence Record ---------------------------------

        @CatalogueTag { bmmConcern = "Governance"; classification = "General"; }
        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "IAO:InformationContentEntity";
            mappingNotes = "A record demonstrating compliance. Evidence about a process, not the process itself.";
        }
        @UserFacing {
            friendlyName = "Audit Evidence Record";
            shortDescription = "A record that demonstrates compliance with a governance requirement — the proof that obligations are met.";
        }
        @PurposiveDescription {
            description = "A record that proves your business is meeting a governance requirement — what was checked, when, by whom, and how often. The system tracks these as concrete evidence items tied to specific obligations. When you define audit evidence records, the system knows what proof exists and can surface gaps where evidence is missing or overdue.";
        }
        @Comprehension {
            surfaceEnumValues = false;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        part def AuditEvidenceRecord {
            doc /* A record or document that provides evidence of
                 * compliance with a governance requirement. The
                 * audit trail: what was checked, when, by whom,
                 * and how often.
                 *
                 * General vocabulary — applicable to any regulated
                 * business. COSHH risk assessments, CQC inspection
                 * records, GDPR processing logs, staff training
                 * records, and food hygiene inspection logs are all
                 * instances of this concept.
                 *
                 * Business meta model concept. */
            attribute evidenceType : String;
            attribute evidenceDescription : String;
            attribute retentionPeriod : String;
            attribute responsibleRole : String;
            attribute frequency : String;
        }
    }

    // =================================================================
    // STAKEHOLDER MODEL — Relationships, partnerships, and participation
    // =================================================================

    package StakeholderModel {
        private import ScalarValues::*;
        private import BusinessModel::ServiceConcept::*;
        private import BusinessModel::GovernanceMapping::*;

        doc /* The relational boundary of the business: how it
             * interacts with entities beyond its operational
             * boundary — regulators, partners, suppliers,
             * communities, and the customers themselves as
             * co-producers.
             *
             * Six General elements, each a distinct structural
             * pattern. No specialisation hierarchy — all are
             * independent sibling part defs. ParticipationModel
             * looks inward (customer as co-producer); the other
             * five look outward.
             *
             * Boundary with GovernanceMapping: rule content in
             * GovernanceMapping, relationship structure here.
             * StakeholderRelationship carries a typed ref to
             * GovernanceRequirement for dual classification.
             *
             * Session 76: StakeholderModel identified and validated.
             * Session 78: detailed design (open question resolution,
             *   attribute design, weight design).
             * Session 81: SysML implementation.
             *
             * Business meta model concept. BMM concern 6 of 6.
             * Source: ontara-discussion-stakeholder-model-detailed-
             *   design-2026-03-28.md */

        // -- Part definitions ----------------------------------

        @CatalogueTag { bmmConcern = "StakeholderModel"; classification = "General"; }
        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "";
            mappingNotes = "A relational entity depending on both parties. GDC because the pattern migrates. Not Role (between entities, not played by one). Candidate: ontara:StakeholderRelation.";
        }
        @UserFacing {
            friendlyName = "Stakeholder Relationship";
            shortDescription = "A typed, ongoing, structured relationship between the business and an external entity.";
        }
        @PurposiveDescription {
            description = "A relationship your business has with an external entity — a regulator, a commissioning body, a professional organisation, a contractual partner, an advisory body, or a peer. Each relationship has a defined nature, mutual obligations, and a health profile. When you define stakeholder relationships, the system tracks who you interact with, what you owe each other, and whether the relationship is working well.";
        }
        @Comprehension {
            surfaceEnumValues = true;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "GovernanceRequirement";
            strength = RelationshipStrength::strong;
            rationale = "A change to the regulatory relationship (e.g. new regulator, changed inspection regime) directly affects what governance requirements apply. Definitional for regulatory-natured relationships (H1).";
        }
        @WeightedRelationship {
            target = "ServiceOffering";
            strength = RelationshipStrength::moderate;
            rationale = "A change to a stakeholder relationship may affect what services can be offered (e.g. loss of a commissioning relationship), but the offering's identity is defined independently in ServiceConcept (H1, H4).";
        }
        @WeightedRelationship {
            target = "ResourceType";
            strength = RelationshipStrength::moderate;
            rationale = "Some stakeholder relationships involve resource implications (e.g. regulatory requirements for qualified staff), but the link is mediated through GovernanceRequirement and ResourceConstraint (H4).";
        }
        part def StakeholderRelationship {
            doc /* A typed, ongoing, structured relationship between
                 * the business and an external entity. The core
                 * abstraction of the StakeholderModel concern.
                 *
                 * The relationshipNature enum classifies the
                 * relationship. The ref to GovernanceRequirement
                 * implements the GovernanceMapping boundary decision
                 * (Session 78 Q2): rule content in GovernanceMapping,
                 * relationship structure here.
                 *
                 * Business meta model concept. */
            attribute stakeholderName : String;
            attribute stakeholderDescription : String;
            attribute relationshipNature : RelationshipNature;
            attribute obligationsInward : String;
            attribute obligationsOutward : String;
            attribute informationExchanged : String;
            attribute governanceArrangements : String;
            attribute healthIndicators : String;
            attribute reviewCadence : String;
            ref relatedGovernanceRequirements : GovernanceRequirement[0..*];
        }

        @CatalogueTag { bmmConcern = "StakeholderModel"; classification = "General"; }
        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "IAO:PlanSpecification";
            mappingNotes = "A formalised agreement specifying shared responsibilities and protocols. The arrangement is informational; joint delivery is a Process.";
        }
        @UserFacing {
            friendlyName = "Cooperative Arrangement";
            shortDescription = "A formalised agreement to jointly deliver or manage something — neither party can deliver independently.";
        }
        @PurposiveDescription {
            description = "A formalised arrangement where your business and another entity jointly deliver or manage something that neither could do alone — a shared care protocol, a delivery partnership, a joint training programme. When you define cooperative arrangements, the system tracks what is jointly produced, how responsibility is divided, and how the arrangement's effectiveness is assessed.";
        }
        @Comprehension {
            surfaceEnumValues = false;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "ActivityType";
            strength = RelationshipStrength::strong;
            rationale = "A cooperative arrangement defines shared activities. A change to the arrangement directly affects what activities are performed and by whom (H1).";
        }
        @WeightedRelationship {
            target = "ServiceOffering";
            strength = RelationshipStrength::strong;
            rationale = "Some cooperative arrangements define jointly-delivered services. A change to the arrangement may fundamentally alter what can be offered (H1).";
        }
        @WeightedRelationship {
            target = "ResourceType";
            strength = RelationshipStrength::moderate;
            rationale = "Cooperative arrangements may involve shared resources, but the resource types exist independently (H4).";
        }
        part def CooperativeArrangement {
            doc /* A formalised agreement to jointly deliver or manage
                 * something. Distinguished by shared responsibility
                 * for an outcome — neither party can deliver
                 * independently.
                 *
                 * Distinct from StakeholderRelationship: if neither
                 * party can deliver the outcome independently, it's
                 * a CooperativeArrangement. If the relationship is
                 * important but each party could function without
                 * the other, it's a StakeholderRelationship.
                 *
                 * Business meta model concept. */
            attribute arrangementName : String;
            attribute cooperatingEntity : String;
            attribute sharedOutcome : String;
            attribute responsibilitySplit : String;
            attribute protocolReference : String;
            attribute informationSharing : String;
            attribute disputeResolution : String;
            attribute performanceIndicators : String;
        }

        @CatalogueTag { bmmConcern = "StakeholderModel"; classification = "General"; }
        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "IAO:PlanSpecification";
            mappingNotes = "A structured route specification. The pathway as concept is a plan; actual referrals are Processes.";
        }
        @UserFacing {
            friendlyName = "Referral Pathway";
            shortDescription = "A structured route for directing or receiving work between organisations.";
        }
        @PurposiveDescription {
            description = "A structured route for directing or receiving work between your business and another organisation — GP referrals coming in, specialist referrals going out, or bidirectional pathways where both directions operate. When you define referral pathways, the system tracks where work comes from and goes to, what criteria trigger referrals, and how volumes and outcomes are monitored.";
        }
        @Comprehension {
            surfaceEnumValues = true;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "ServiceOffering";
            strength = RelationshipStrength::moderate;
            rationale = "Referral pathways channel demand to specific offerings, but the offerings exist independently. A change to a referral pathway affects volume and flow, not the offering's identity (H1, H2).";
        }
        @WeightedRelationship {
            target = "ActivityType";
            strength = RelationshipStrength::moderate;
            rationale = "Referral pathways generate activities (intake, triage, acknowledgement), but these activities are typed independently (H4).";
        }
        part def ReferralPathway {
            doc /* A structured route for directing or receiving work
                 * between organisations. Characterised by direction
                 * (inbound, outbound, bidirectional), criteria,
                 * protocol, and outcome tracking.
                 *
                 * Business meta model concept. */
            attribute pathwayName : String;
            attribute direction : ReferralDirection;
            attribute referringEntity : String;
            attribute referralCriteria : String;
            attribute referralProtocol : String;
            attribute expectedResponseTime : String;
            attribute feedbackMechanism : String;
            attribute volumeTracking : String;
        }

        @CatalogueTag { bmmConcern = "StakeholderModel"; classification = "General"; }
        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "IAO:InformationContentEntity";
            mappingNotes = "A record of asymmetric reliance. The dependency is informational; consequences are felt through resource availability.";
        }
        @UserFacing {
            friendlyName = "External Dependency";
            shortDescription = "Something the business depends on that it does not control — characterised by asymmetric reliance.";
        }
        @PurposiveDescription {
            description = "Something your business depends on that you do not control — a pharmaceutical supplier, a laboratory service, an equipment provider, a software platform. When you define external dependencies, the system tracks what you depend on, how critical each dependency is, what contingency plans exist, and what risks threaten continuity of supply.";
        }
        @Comprehension {
            surfaceEnumValues = true;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "ResourceType";
            strength = RelationshipStrength::strong;
            rationale = "An external dependency is something the business depends on — often a resource it cannot provide itself. A change to the dependency (e.g. supplier withdrawal) directly affects resource availability (H1).";
        }
        @WeightedRelationship {
            target = "ServiceOffering";
            strength = RelationshipStrength::moderate;
            rationale = "Loss of a critical dependency may affect what can be offered, but the link is mediated through resources (H4).";
        }
        @WeightedRelationship {
            target = "CostDriver";
            strength = RelationshipStrength::moderate;
            rationale = "Dependencies have cost implications (supplier pricing, contractual terms), but cost drivers are characterising, not definitional (H1, H2).";
        }
        part def ExternalDependency {
            doc /* Something the business depends on that it does not
                 * control. Characterised by asymmetric reliance — the
                 * business depends on the provider, but the provider
                 * does not depend on the business (or the dependence
                 * is negligible).
                 *
                 * Distinguished from CooperativeArrangement by
                 * asymmetric power. The criticality enum drives
                 * contingency planning priority.
                 *
                 * NOTE: 'dependency' is a KerML reserved word.
                 * The compound attribute name 'dependencyName' is
                 * used here — verify in Syside that this parses.
                 * Fallback: 'externalDependencyName'.
                 *
                 * Business meta model concept. */
            attribute dependencyName : String;
            attribute provider : String;
            attribute dependencyDescription : String;
            attribute criticality : DependencyCriticality;
            attribute substitutability : String;
            attribute contingencyPlan : String;
            attribute contractualTerms : String;
            attribute supplyRisk : String;
        }

        @CatalogueTag { bmmConcern = "StakeholderModel"; classification = "General"; }
        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "";
            mappingNotes = "Constitutive connection to community. GDC — relational, depends on both parties. Candidate: ontara:CommunityRelation.";
        }
        @UserFacing {
            friendlyName = "Community Relationship";
            shortDescription = "The business's connection to its broader community of interest — constitutive, not transactional.";
        }
        @PurposiveDescription {
            description = "Your business's connection to its broader community of interest — the people, organisations, and networks that share your purpose or are affected by your work. Community relationships are constitutive of your identity, not transactional. When you define community relationships, the system tracks how communities shape your service and how you engage with them.";
        }
        @Comprehension {
            surfaceEnumValues = false;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "ServiceOffering";
            strength = RelationshipStrength::moderate;
            rationale = "Community relationships shape what the business offers (community needs influence service design), but the link is characterising, not definitional (H1).";
        }
        @WeightedRelationship {
            target = "CustomerSegment";
            strength = RelationshipStrength::moderate;
            rationale = "Communities overlap with customer segments, but they are not the same thing — a community relationship may serve non-customers (H4).";
        }
        part def CommunityRelationship {
            doc /* The business's connection to its broader community
                 * of interest. Constitutive, not transactional —
                 * deliberately lighter on governance attributes than
                 * the other StakeholderModel elements.
                 *
                 * Business meta model concept. */
            attribute communityName : String;
            attribute communityDescription : String;
            attribute relationshipToService : String;
            attribute engagementMode : String;
            attribute mutualBenefit : String;
            attribute communityVoice : String;
        }

        @CatalogueTag { bmmConcern = "StakeholderModel"; classification = "General"; }
        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "IAO:PlanSpecification";
            mappingNotes = "A specification of how customers/patients participate. The model is a plan; actual participation is a Process.";
        }
        @UserFacing {
            friendlyName = "Participation Model";
            shortDescription = "How the customer or patient participates as co-producer, not merely recipient, of the service.";
        }
        @PurposiveDescription {
            description = "How your customer or patient participates in the service as a co-producer, not merely a recipient — the spectrum from passive recipient to active self-manager. When you define participation models, the system tracks what role participants play, how they contribute information and decisions, what they can do independently, and what support they need.";
        }
        @Comprehension {
            surfaceEnumValues = false;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "ServiceOffering";
            strength = RelationshipStrength::strong;
            rationale = "Participation patterns are defined for specific service offerings — the ref relationship is typed. A change to how customers participate directly affects the offering's delivery model (H1).";
        }
        @WeightedRelationship {
            target = "ActivityType";
            strength = RelationshipStrength::moderate;
            rationale = "Participation generates activities (self-service actions, shared decision-making), but the activity types exist independently (H4).";
        }
        @WeightedRelationship {
            target = "Channel";
            strength = RelationshipStrength::moderate;
            rationale = "Participation mode may affect which channels are used (e.g. self-service requires a digital channel), but channels serve multiple purposes (H4).";
        }
        part def ParticipationModel {
            doc /* How the customer/patient participates as co-producer,
                 * not merely recipient. Connected to A7 (patient
                 * autonomy), H2 (agency classification), and the
                 * service participation framework (O26).
                 *
                 * Structurally distinct from the five outward-looking
                 * elements — ParticipationModel describes the boundary
                 * looking inward at the customer's role within the
                 * service.
                 *
                 * Business meta model concept. */
            attribute participationName : String;
            attribute participantRole : String;
            attribute participationDescription : String;
            attribute informationContribution : String;
            attribute decisionInvolvement : String;
            attribute selfServiceScope : String;
            attribute supportRequired : String;
            ref relatedServiceOffering : ServiceOffering[0..*];
        }

        // -- GSL StakeholderModel instantiation -----------------

        part cqcRelationship : StakeholderRelationship {
            doc /* Care Quality Commission — the primary regulatory
                 * relationship for GSL as a registered healthcare
                 * provider. */
            attribute :>> stakeholderName = "Care Quality Commission (CQC)";
            attribute :>> stakeholderDescription = "Independent regulator of health and social care in England. GSL is registered as a healthcare provider.";
            attribute :>> relationshipNature = RelationshipNature::regulatory;
            attribute :>> obligationsInward = "CQC sets and inspects against fundamental standards of care. Provides inspection reports, ratings, and enforcement actions.";
            attribute :>> obligationsOutward = "GSL must maintain registration, comply with fundamental standards, notify CQC of significant events, and cooperate with inspections.";
            attribute :>> informationExchanged = "Registration data, notification of incidents, inspection evidence (outward). Inspection reports, ratings, guidance (inward).";
            attribute :>> governanceArrangements = "Formal registration and periodic inspection cycle. Conditions of registration. Duty of candour.";
            attribute :>> healthIndicators = "Current CQC rating, time since last inspection, open enforcement actions, outstanding conditions.";
            attribute :>> reviewCadence = "Continuous compliance. Formal inspection cycle determined by CQC (typically 1-2 years for new registrations).";
        }

        part icbRelationship : StakeholderRelationship {
            doc /* NHS Integrated Care Board — commissioner relationship
                 * for shared care funding. */
            attribute :>> stakeholderName = "NHS Integrated Care Board (ICB)";
            attribute :>> stakeholderDescription = "NHS body that commissions healthcare services. Relevant where shared care arrangements involve NHS funding.";
            attribute :>> relationshipNature = RelationshipNature::commissioning;
            attribute :>> obligationsInward = "ICB defines what services it will commission and fund. Provides commissioning specifications and payment.";
            attribute :>> obligationsOutward = "GSL must meet commissioning specifications, report activity and outcomes, maintain clinical standards.";
            attribute :>> informationExchanged = "Activity reports, outcome data, clinical governance reports (outward). Commissioning specifications, payment, policy updates (inward).";
            attribute :>> governanceArrangements = "Service level agreement or commissioning contract. Regular contract review meetings.";
            attribute :>> healthIndicators = "Contract compliance status, payment timeliness, relationship with commissioning lead.";
            attribute :>> reviewCadence = "Quarterly contract review. Annual recommissioning cycle.";
        }

        part sharedCareProtocol : CooperativeArrangement {
            doc /* NHS shared care protocol for hormone prescribing —
                 * the defining cooperative arrangement for GSL. GP
                 * monitors, GSL initiates and adjusts. */
            attribute :>> arrangementName = "Shared care hormone prescribing protocol";
            attribute :>> cooperatingEntity = "GP practices (via individual shared care agreements)";
            attribute :>> sharedOutcome = "Safe, monitored hormone therapy with prescribing initiated by GSL and ongoing monitoring shared with the patient's GP";
            attribute :>> responsibilitySplit = "GSL: specialist assessment, treatment initiation, dose adjustment, specialist review. GP: blood monitoring, repeat prescribing per protocol, flagging concerns.";
            attribute :>> protocolReference = "GSL Shared Care Protocol for Gender-Affirming Hormone Therapy (internal document)";
            attribute :>> informationSharing = "GSL sends treatment summaries and monitoring schedules. GP sends blood results and clinical observations. Via secure clinical correspondence.";
            attribute :>> disputeResolution = "Clinical disagreements escalated to GSL clinical lead. Protocol review if pattern of disagreement emerges.";
            attribute :>> performanceIndicators = "GP uptake rate, monitoring compliance rate, time to shared care agreement, adverse event rate under shared care.";
        }

        part gpReferralPathway : ReferralPathway {
            doc /* GP referrals inbound — the primary referral pathway
                 * for GSL. Bidirectional: GSL also refers back to GP
                 * for shared care monitoring. */
            attribute :>> pathwayName = "GP referral pathway";
            attribute :>> direction = ReferralDirection::bidirectional;
            attribute :>> referringEntity = "GP practices";
            attribute :>> referralCriteria = "Inbound: patient presenting with gender dysphoria or requesting gender-affirming care. Outbound: patient ready for shared care monitoring.";
            attribute :>> referralProtocol = "Inbound: referral letter with clinical history. Outbound: treatment summary with shared care protocol and monitoring schedule.";
            attribute :>> expectedResponseTime = "Inbound: acknowledgement within 5 working days. Outbound: GP response to shared care request within 10 working days.";
            attribute :>> feedbackMechanism = "Inbound: outcome letter to GP after assessment. Outbound: ongoing clinical correspondence per monitoring schedule.";
            attribute :>> volumeTracking = "Referral volumes tracked monthly. Conversion rate (referral to assessment). Shared care uptake rate.";
        }

        part specialistReferralPathway : ReferralPathway {
            doc /* Outbound specialist referrals — endocrinology,
                 * surgery, mental health. */
            attribute :>> pathwayName = "Specialist referral pathway";
            attribute :>> direction = ReferralDirection::outbound;
            attribute :>> referringEntity = "Specialist services (endocrinology, surgery, psychiatry/psychology)";
            attribute :>> referralCriteria = "Clinical need for specialist input beyond GSL's scope — complex endocrine management, surgical referral, mental health support.";
            attribute :>> referralProtocol = "Formal referral letter with clinical summary, investigation results, and specific clinical question.";
            attribute :>> expectedResponseTime = "Varies by specialty and urgency. Routine: 2-4 weeks acknowledgement. Urgent: within 48 hours.";
            attribute :>> feedbackMechanism = "Specialist outcome report back to GSL. Integrated into patient's clinical record.";
            attribute :>> volumeTracking = "Referral volumes by specialty tracked quarterly. Waiting times and outcome rates monitored.";
        }

        part pharmaceuticalSupply : ExternalDependency {
            doc /* Hormone medication supply — essential dependency.
                 * GSL cannot deliver its core service without
                 * reliable pharmaceutical supply. */
            attribute :>> dependencyName = "Pharmaceutical supply (hormones)";
            attribute :>> provider = "Licensed pharmaceutical wholesalers and manufacturers";
            attribute :>> dependencyDescription = "Supply of gender-affirming hormone medications — oestradiol (oral, transdermal, injectable), testosterone (injectable, transdermal). Core to GSL's clinical service.";
            attribute :>> criticality = DependencyCriticality::essential;
            attribute :>> substitutability = "Multiple formulations and suppliers available for most medications. Some specialist preparations have limited suppliers. Brand switching requires clinical review.";
            attribute :>> contingencyPlan = "Maintain relationships with multiple wholesalers. Monitor MHRA drug shortage alerts. Clinical protocol for safe brand switching when required.";
            attribute :>> contractualTerms = "Standard pharmaceutical wholesale terms. No exclusive supply agreements.";
            attribute :>> supplyRisk = "Periodic national shortages of specific formulations (testosterone undecanoate, oestradiol patches). MHRA supply disruption notifications.";
        }

        part laboratoryDependency : ExternalDependency {
            doc /* External pathology laboratory — essential for blood
                 * monitoring. */
            attribute :>> dependencyName = "Laboratory services (blood monitoring)";
            attribute :>> provider = "Contracted pathology laboratory";
            attribute :>> dependencyDescription = "Blood test processing for hormone levels, liver function, lipids, haematology. Required for safe prescribing and monitoring.";
            attribute :>> criticality = DependencyCriticality::essential;
            attribute :>> substitutability = "Multiple pathology providers available. Switching requires new account setup and reference range familiarisation. Turnaround times may vary.";
            attribute :>> contingencyPlan = "Secondary laboratory contract in place. Patient can use NHS GP blood monitoring as fallback (slower turnaround).";
            attribute :>> contractualTerms = "Per-panel pricing. Results via electronic interface. Turnaround SLA: routine 48 hours, urgent 24 hours.";
            attribute :>> supplyRisk = "Low — multiple providers. Risk of turnaround delays during high-demand periods. Electronic interface dependency.";
        }

        part transCommunityCommunity : CommunityRelationship {
            doc /* Trans community and advocacy organisations —
                 * constitutive relationship. GSL exists to serve
                 * this community. */
            attribute :>> communityName = "Trans and non-binary community";
            attribute :>> communityDescription = "People who identify as trans, non-binary, or gender diverse, and the organisations that advocate for and support them.";
            attribute :>> relationshipToService = "Constitutive — GSL exists to serve this community. Community needs define what services GSL offers and how they are delivered.";
            attribute :>> engagementMode = "Community advisory input, patient feedback mechanisms, engagement with trans advocacy organisations, representation at community events.";
            attribute :>> mutualBenefit = "Community gains access to specialist gender-affirming healthcare. GSL gains understanding of community needs, trust, and referral through community networks.";
            attribute :>> communityVoice = "Patient experience feedback, community advisory group (planned), engagement with national advocacy organisations (e.g. Mermaids, Gendered Intelligence, GIRES), social media presence.";
        }

        part sharedDecisionParticipation : ParticipationModel {
            doc /* Shared decision-making in hormone therapy — the
                 * defining participation pattern for GSL. Patient
                 * as informed co-producer of treatment decisions. */
            attribute :>> participationName = "Shared decision-making in hormone therapy";
            attribute :>> participantRole = "Informed co-producer — patient actively contributes to treatment decisions alongside the clinician";
            attribute :>> participationDescription = "Patient participates in treatment decisions through informed consent, preference expression, self-monitoring, and shared goal setting. Clinician provides clinical expertise; patient provides lived experience and treatment preferences.";
            attribute :>> informationContribution = "Medical history, treatment preferences, self-reported wellbeing, side effect reporting, lifestyle factors affecting treatment. Via consultation and patient portal.";
            attribute :>> decisionInvolvement = "Shared — clinician and patient jointly decide treatment approach, medication choice, dose adjustments. Patient consent required for all treatment changes.";
            attribute :>> selfServiceScope = "Appointment booking, viewing pathway progress, accessing education materials, submitting self-monitoring data, secure messaging with clinical team.";
            attribute :>> supportRequired = "Health literacy support, education on hormone therapy effects and monitoring, digital literacy for portal use, accessibility accommodations as needed.";
        }
    }
}
