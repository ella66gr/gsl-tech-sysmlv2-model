// =========================================================================
// BUSINESS METAMODEL GENERAL — the business-side General package
// =========================================================================
//
// OP-132 step 9 (S515, ADR-012 §4.1–4.2, option N1). The six concern
// packages formerly under BusinessModel sit directly under this package,
// with BusinessScenarios, BusinessStrategy and CanonicalRuntime as their
// siblings (BMM main §4). The three stakeholder-relationship enums joined
// StakeholderModel from Foundation (group J1). Imports are limited by
// rule R1 (General and apparatus) and R3 (never the system side).
// DomainIdentityTypes joins at step 10.
// =========================================================================

package BusinessMetamodelGeneral {
    private import ScalarValues::*;
    private import ProjectionMetadata::*;

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
         *   AgencyClassification) remain in Foundation pending their
         *   allocation (S514, ADR-011 §4.7). */

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
        private import BusinessMetamodelGeneral::ServiceConcept::*;
        private import BusinessMetamodelGeneral::BusinessStrategy::*;

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
    }

    // =================================================================
    // FINANCIAL PLANNING — How money flows through the business
    // =================================================================

    package FinancialPlanning {
        private import ScalarValues::*;
        private import BusinessMetamodelGeneral::ResourcePlanning::*;
        private import BusinessMetamodelGeneral::ServiceConcept::*;
        private import BusinessMetamodelGeneral::BusinessScenarios::*;

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
        @WeightedRelationship {
            target = "GovernanceRequirement";
            strength = RelationshipStrength::strong;
            rationale = "An evidence record exists to demonstrate compliance with a governance requirement — the requirement defines what evidence must be produced. A change to the requirement (its compliance description, its evidence specification, its frequency expectations) requires reassessing the evidence records that demonstrate it.";
        }
        @WeightedRelationship {
            target = "ActivityType";
            strength = RelationshipStrength::moderate;
            rationale = "Evidence records are produced by activities — typically governance-category activities such as inspections, reviews, or assessments. A change to the evidence specification (format, retention, frequency) may require reassessing which activities produce it, but activities exist independently of any single evidence specification.";
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
        private import BusinessMetamodelGeneral::ServiceConcept::*;
        private import BusinessMetamodelGeneral::GovernanceMapping::*;

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

        // -- Stakeholder relationship enumerations ----------------
        // Formerly in Foundation's CommonTypes (group J1, ADR-011 §4.7);
        // attribute types of the StakeholderModel defs, used by every tenant.

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

        enum def ReferralDirection {
            doc /* Direction of a referral or referral pathway.
                 * Extended Session 81: bidirectional added for
                 * referral pathways where both directions operate
                 * (e.g. GP refers to GSL, GSL refers back to GP). */
            inbound;
            outbound;
            bidirectional;
        }

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
    }

    // =========================================================================
    // BUSINESS SCENARIOS — Projection mechanics and operational steering
    // =========================================================================
    //
    // Promoted from BusinessModel::ScenarioModelling to a top-level package
    // in Phase 6A to manage file size. BusinessModel was ~1,900 lines;
    // this extraction brings both files under 900 lines.
    //
    // Syside constraint: same-named packages across files trigger
    // global-namespace-distinguishability errors. This package is therefore
    // named BusinessScenarios (not BusinessModel::ScenarioModelling).
    //
    // Phase 6A (Session 18). See gsl-plan-business-meta-model-phase6a.md.
    // Phase 6B (Session 18). Steering cycle wiring: VarianceSource enum
    // typing, cross-package imports to Knowledge::LogicEngine, illustrative
    // GoalProjection and Deficit instantiations.
    // Phase 7 (Session 19). Formal ref from ScenarioDefinition to
    // ServiceOffering. Import added from BusinessModel::ServiceConcept.
    // =========================================================================

    package BusinessScenarios {
        private import ScalarValues::*;
        private import BusinessMetamodelGeneral::ServiceConcept::ServiceOffering;

        doc /* Provides the mechanics for driving the business model
             * vocabulary — computing projections, comparing alternatives,
             * and stress-testing assumptions. Without this, the business
             * model is a structured description; with it, it becomes an
             * explorable, quantitative tool.
             *
             * Formerly BusinessModel::ScenarioModelling. Promoted to
             * top-level package in Phase 6A for file size management.
             *
             * Phase 6B: imports from Knowledge::LogicEngine and
             * Foundation::CommonTypes establish the structural wiring
             * between the business model and the self-knowledge
             * architecture. GoalProjection and Deficit part defs from
             * LogicEngine are used to express financial goals and
             * variances, validating the architecture as domain-agnostic.
             *
             * Source: gsl-service-business-meta-modelling.md sections
             * 3.7, 3.8, and 4.7
             *
             * OP-132 step 5 (S515): the GSL scenario, steering (GoalProjection,
             * Deficit) and strategy usages moved to GslScenarios in
             * exercises/gendersense/model/gsl-scenarios.sysml, and the
             * Knowledge::LogicEngine import went with them. This package now
             * holds General vocabulary only. */

        // -- Enumerations --------------------------------------

        enum def GrowthShape {
            linear;
            stepped;
            sCurve;
            custom;
        }

        enum def VarianceSource {
            volume;
            price;
            mix;
            timing;
        }

        // -- Part definitions: projection mechanics ------------

        part def ScenarioDefinition {
            doc /* A named, self-contained configuration of a business
                 * model variant. Selects which ServiceOfferings are
                 * active, sets all parameters, specifies growth
                 * assumptions, and configures resource levels.
                 *
                 * Phase 7: activeServiceOfferings is a typed ref to
                 * ServiceOffering[0..*] (cross-package). The string
                 * attribute activeOfferingsDescription provides the
                 * human-readable summary. */
            attribute scenarioName : String;
            attribute description : String;
            ref activeServiceOfferings : ServiceOffering[0..*];
            attribute activeOfferingsDescription : String;
            attribute variantLabel : String;
            attribute timelineMonths : Integer;
            attribute notes : String;
        }

        part def ProjectionParameter {
            attribute parameterName : String;
            attribute parameterValue : Real;
            attribute unit : String;
            attribute sourceRef : String;
            attribute temporalVariation : String;
            attribute notes : String;
        }

        part def GrowthAssumption {
            attribute assumptionName : String;
            attribute targetVariable : String;
            attribute growthShape : GrowthShape;
            attribute startValue : Real;
            attribute endValue : Real;
            attribute inflectionMonth : Integer;
            attribute trajectory : String;
            attribute notes : String;
        }

        part def ProjectionFormula {
            attribute formulaName : String;
            attribute inputs : String;
            attribute expression : String;
            attribute outputVariable : String;
            attribute outputUnit : String;
            attribute notes : String;
        }

        part def ProjectionTimeline {
            attribute timelineName : String;
            attribute periodMonths : Integer;
            attribute intervalUnit : String;
            attribute startCondition : String;
        }

        part def ProjectionOutput {
            attribute periodLabel : String;
            attribute revenue : Real;
            attribute cost : Real;
            attribute margin : Real;
            attribute cumulativeCashFlow : Real;
            attribute activePatientsTotal : Integer;
            attribute clinicianUtilisation : Real;
            attribute confidenceProfile : String;
        }

        part def SensitivityParameter {
            attribute parameterRef : String;
            attribute baseValue : Real;
            attribute pessimisticValue : Real;
            attribute optimisticValue : Real;
            attribute impactDescription : String;
        }

        part def ScenarioComparison {
            attribute comparisonName : String;
            attribute scenarioRefs : String;
            attribute comparisonDate : String;
            attribute summaryNotes : String;
        }

        // -- Part definitions: operational steering ------------

        part def PeriodActuals {
            attribute periodLabel : String;
            attribute actualRevenue : Real;
            attribute actualCost : Real;
            attribute actualMargin : Real;
            attribute actualPatientCount : Integer;
            attribute recordedDate : String;
            attribute notes : String;
        }

        part def VarianceAnalysis {
            doc /* Phase 6B: varianceSource typed as VarianceSource enum
                 * (was String). Resolves deferred item from Phase 3. */
            attribute periodLabel : String;
            attribute revenueVariance : Real;
            attribute costVariance : Real;
            attribute marginVariance : Real;
            attribute varianceSource : VarianceSource;
            attribute decomposition : String;
            attribute rebaselineRecommended : String;
            attribute notes : String;
        }

        part def ForecastBaseline {
            attribute baselineName : String;
            attribute baselineVersion : Integer;
            attribute scenarioRef : String;
            attribute effectiveDate : String;
            attribute parameterSnapshot : String;
            attribute notes : String;
        }
    }

    // =========================================================================
    // BUSINESS STRATEGY — Where the business is heading
    // =========================================================================
    //
    // Promoted from BusinessModel::StrategyAndEvolution to a top-level
    // package in Phase 6A to manage file size.
    //
    // Syside constraint: same-named packages across files trigger
    // global-namespace-distinguishability errors. This package is therefore
    // named BusinessStrategy (not BusinessModel::StrategyAndEvolution).
    //
    // Phase 6A (Session 18). See gsl-plan-business-meta-model-phase6a.md.
    // Phase 7 (Session 19). StrategicObjective restructured from part def
    // to requirement def to enable formal satisfy relationships to
    // Capability usages. relatedCapabilities attribute removed — replaced
    // by satisfy in BusinessModel::ResourcePlanning. relatedScenarios
    // upgraded from String to ref. Import added from BusinessScenarios.
    // =========================================================================


    package BusinessStrategy {
        private import ScalarValues::*;
        private import BusinessMetamodelGeneral::BusinessScenarios::ScenarioDefinition;

        doc /* Strategic direction, business model variants, and
             * pivot scenarios. Captures the intentional direction
             * that the other concerns serve: where is this business
             * heading, what alternatives exist, and what would
             * trigger a change of direction?
             *
             * Formerly BusinessModel::StrategyAndEvolution. Promoted
             * to top-level package in Phase 6A for file size management.
             *
             * Connects to Enterprise::Strategy (upgrading the
             * current placeholder) and to BusinessScenarios
             * (each variant has a corresponding ScenarioDefinition
             * with full parameterisation).
             *
             * Phase 7: StrategicObjective is a requirement def.
             * satisfy relationships are in BusinessModel::
             * ResourcePlanning (different package from the def,
             * per Syside constraint). relatedScenarios is a typed
             * ref to ScenarioDefinition[0..*].
             *
             * Variant A and B are fully elaborated with
             * ScenarioDefinitions. Variant C remains a placeholder.
             *
             * Source: gsl-service-business-meta-modelling.md
             * sections 3.5, 7.1 */

        // -- Requirement definitions ---------------------------

        requirement def StrategicObjective {
            doc /* A defined business goal with a timeframe, success
                 * criteria, and traceability to capabilities that
                 * satisfy it and scenarios that parameterise it.
                 *
                 * Modelled as requirement def (not part def) to enable
                 * formal satisfy relationships from objectives to
                 * Capability usages in ResourcePlanning. This preserves
                 * structural traceability for future tooling —
                 * generators, validators, and traceability reports can
                 * follow the satisfy chain rather than parsing string
                 * conventions.
                 *
                 * subject: the GenderSense service system that must
                 * achieve this objective.
                 *
                 * satisfy relationships are in BusinessModel::
                 * ResourcePlanning (different package, per Syside
                 * constraint on satisfy in same package as req def).
                 *
                 * Phase 7 restructuring from part def. */
            subject genderSenseService;
            attribute objectiveName : String;
            attribute description : String;
            attribute targetDate : String;          // e.g. "Month 18", "Year 2 Q4"
            attribute successCriteria : String;
            attribute status : String;              // planned, in progress, achieved, revised
            ref relatedScenarios : ScenarioDefinition[0..*];
        }

        // -- Part definitions ----------------------------------

        part def BusinessModelVariant {
            doc /* A named alternative business model configuration.
                 * Lighter than a full ScenarioDefinition — captures
                 * the strategic essence for comparison at the
                 * boardroom level. The detailed scenario lives in
                 * BusinessScenarios and is referenced via scenarioRef. */
            attribute variantName : String;
            attribute variantLabel : String;        // e.g. "A", "B", "C"
            attribute description : String;
            attribute activeOfferings : String;
            attribute keyDifferentiator : String;
            attribute investmentLevel : String;     // e.g. "~£15K", "~£120K"
            attribute riskProfile : String;
            attribute scenarioRef : String;         // references a ScenarioDefinition name
        }

        part def PivotScenario {
            doc /* A structured what-if analysis for transitioning
                 * between business model variants. Captures the
                 * trigger condition, transition plan, estimated
                 * duration, and risks. */
            attribute pivotName : String;
            attribute fromVariant : String;         // references a BusinessModelVariant name
            attribute toVariant : String;           // references a BusinessModelVariant name
            attribute triggerCondition : String;
            attribute transitionPlan : String;
            attribute estimatedTransitionMonths : Integer;
            attribute riskNotes : String;
        }
    }

    // =========================================================================
    // CANONICAL RUNTIME — BMM General vocabulary for multi-axis status primitive
    // =========================================================================
    //
    // Session 255 — First implementation of W-094 (multi-axis status primitive).
    // Session 277 — W-116 annotation completion; annotation placement
    //   standardised on prefix (Position A) per workflow guide §9.4.
    //   Existing inline @UserFacing and @BfoType annotations migrated to
    //   prefix; four missing annotation types added (@CatalogueTag,
    //   @PurposiveDescription, @Comprehension, @WeightedRelationship) for
    //   all four part defs. Inline placement was verified to parse via
    //   syntax-tests/test-inline-vs-prefix-annotation.sysml — the migration
    //   is for consistency with the rest of the BMM, not for parser
    //   correctness.
    //
    // Source specification: ontara-model-multi-axis-status-primitive-2026-04-22
    // (Session 253 paper). Stratum-and-side locus: Metamodel stratum, business
    // side (BMM General). Per the strengthened A4 (business metamodel concept).
    //
    // Scope of this file:
    //   - CanonicalRuntimeType: base part def for every canonical runtime type.
    //     It declares the status axes its instances carry; it carries no
    //     built-in axis (the epistemic axis was retired at S514, ADR-011).
    //   - StatusAxis: BMM General part def naming a single dimension of status
    //     on a canonical runtime type (S253 §3).
    //   - Supporting types: ValueSpace, AxisTransition, AxisAuthority, AxisScope,
    //     ValueSpaceShape.
    //
    // Session 514 — OP-125 canon pass, Step 2 (ADR-011, decision 1). The
    //   epistemic axis is retired: `enum def EpistemicModality`, the
    //   `epistemicAxis` part usage and its four AxisTransitions are deleted,
    //   and `AxisScope::platformBuiltIn` is removed because no built-in axis
    //   remains. Whether a record is real or simulated (mode), and how it was
    //   produced (method), are carried by the platform's record of the write,
    //   in the platform record module (OWL, `ontara-rec:`), not by the entity.
    //   CanonicalRuntimeType is re-anchored at bfo:entity (BFO_0000001), with
    //   the @BfoType annotation kept (Ella, S514; Cyril's reason below).
    //
    // Out of scope for this session:
    //   - E6 generator extension for axis-aware semantics (S253 §6).
    //   - OWL axiomatisation (S253 §3.7) — second pass after parse confirmed.
    //   - Cross-axis consequence rule vocabulary (S253 §6).
    //   - Tenant declarations beyond Paws Booking (carried in paws.sysml).
    //
    // Verified syntax patterns used:
    //   - :>> attribute redefinition (v3.5).
    //   - :>> multi-valued tuple (v3.13, v3.19).
    //   - Nested :>> inside contained part usages (verified S255 via
    //     test-nested-redefinition.sysml, Tests A/B/C).
    //   - Part def specialisation :> (throughout).
    //   - Metadata annotations alongside :>> (v3.7).
    //   - Prefix placement of all six BMM annotation types on a single
    //     part def, including multi-@WeightedRelationship stacking
    //     (verified S277 via test-inline-vs-prefix-annotation.sysml).
    //
    // Naming: `valueShape` (not `shape`) per S255 finding that `shape` shadows
    //   Items::Item::shape through the standard library inheritance chain.
    //
    // Annotation note (S277): Every BMM General part def in this file now
    // carries the full six-annotation block as prefix:
    //   @CatalogueTag → @BfoType → @UserFacing → @PurposiveDescription →
    //   @Comprehension → @WeightedRelationship (multiple).
    // `bmmConcern = "CanonicalRuntime"` is used throughout, naming the
    // platform-infrastructure character of these elements as cross-cutting
    // metamodel content rather than concern-level content.
    //
    // =========================================================================


    package CanonicalRuntime {
        private import ScalarValues::*;
        private import ProjectionMetadata::*;

        doc /* BMM General canonical-runtime vocabulary. Defines
             * CanonicalRuntimeType (the base for every type whose runtime
             * instances live in DBR or DSR), StatusAxis (a single named
             * dimension of status on a canonical runtime type), and the
             * supporting vocabulary (ValueSpace, AxisTransition,
             * AxisAuthority, AxisScope, ValueSpaceShape).
             *
             * No axis is built in. Every StatusAxis is tenant-declared on a
             * specific canonical type. Mode (real or simulated) and method
             * (direct, inferred or predicted) are labels on the platform's
             * record of each write, from the platform record module at PML
             * (ADR-011, S514); they are not an axis on the entity.
             *
             * Stratum-and-side locus: Metamodel stratum, business side.
             * These are business meta model concepts — structural vocabulary
             * for what canonical runtime types look like, not tenant
             * configuration. Tenant declarations of specific axes (Paws
             * Booking lifecycle axis, Cafe Order lifecycle axis, etc.) are
             * Configured-Model stratum content and live with the tenant.
             *
             * Source: S253 specification paper (ontara-model-multi-axis-
             * status-primitive-2026-04-22). This file is the first
             * implementation landing of W-094. */

        // =====================================================================
        // ENUMS — Axis scope, authority classes, value space shapes
        // =====================================================================

        enum def AxisScope {
            doc /* The scope of an axis declaration.
                 *
                 * tenantDeclared: the axis is declared by a specific tenant
                 *   on a specific canonical type. This is the only scope.
                 *   `platformBuiltIn` was removed at S514 (ADR-011): no
                 *   built-in axis remains, and a future one would be
                 *   re-added by decision, not by default. */
            tenantDeclared;
        }

        enum def AxisAuthority {
            doc /* Declares which party or component may write to an axis.
                 * Mirrors the binding-class vocabulary at B60 (BRL).
                 *
                 * A write through the wrong binding class is a constraint
                 * violation; the canonical-edge contract (B61) enforces
                 * the declaration uniformly. Multi-valued attributes of
                 * this type are used where more than one party may
                 * legitimately write (e.g. both customer-side and
                 * operator-side for a confirmation axis).
                 *
                 * Values:
                 * - operatorSide: HMB with an operator role.
                 * - customerSide: HMB with customer identity.
                 * - systemSide: MRB (substrate-internal mapping) or ESB
                 *     (foreign-system events).
                 * - inferenceSide: IGB writes under declared assumptions.
                 * - syntheticSide: SGB writes during a simulation run.
                 * - platformSide: platform machinery writes at the
                 *     substrate seam. */
            operatorSide;
            customerSide;
            systemSide;
            inferenceSide;
            syntheticSide;
            platformSide;
        }


        enum def ValueSpaceShape {
            doc /* The three shapes a StatusAxis value space may take.
                 * Selected when the axis is declared (S253 §3.2).
                 *
                 * - unorderedEnum: a set of named values with no implicit
                 *     ordering. Cancellation axis is a typical case.
                 * - orderedEnum: a totally-ordered sequence. Lifecycle axes
                 *     use this. Admits unordered branches (a "returned for
                 *     rework" value sits outside the ordering).
                 * - structuredValue: a typed compound (numeric with unit,
                 *     timestamp, tagged union). Retained for v1+1
                 *     extensions — v1 axes are all enumerations. */
            unorderedEnum;
            orderedEnum;
            structuredValue;
        }

        // =====================================================================
        // SUPPORTING PART DEFS — ValueSpace, AxisTransition
        // =====================================================================

        @CatalogueTag {
            bmmConcern = "CanonicalRuntime";
            classification = "General";
        }
        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "IAO:InformationContentEntity";
            mappingNotes = "A ValueSpace specifies the permitted values and ordering shape of a single status axis. Information content — a specification depending on the StatusAxis it describes; not the values themselves but the description of what values are permitted.";
        }
        @UserFacing {
            friendlyName = "Value Space";
            shortDescription = "The permitted values for a status axis, plus the shape (ordered, unordered, or structured) that determines how the values relate.";
        }
        @PurposiveDescription {
            description = "The permitted values for a single status axis, and how those values relate to one another. For ordered axes (like a lifecycle), the values progress in a sequence. For unordered axes (like a cancellation reason), the values are a set with no implicit order. The system uses the value space to decide which transitions are permitted and how to display the axis to readers.";
        }
        @Comprehension {
            surfaceEnumValues = false;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "StatusAxis";
            strength = RelationshipStrength::strong;
            rationale = "Every ValueSpace exists to describe a StatusAxis. A change to the value space (its shape, its permitted values) requires reassessing the axis it belongs to — the axis's permitted transitions and authority interpretation may need adjustment.";
        }
        @WeightedRelationship {
            target = "AxisTransition";
            strength = RelationshipStrength::strong;
            rationale = "Permitted transitions reference values from the value space. A change to the value space (e.g. removing a value, adding a value, changing the shape from unordered to ordered) directly affects which transitions are well-formed.";
        }
        part def ValueSpace {
            doc /* The permitted values for a StatusAxis, plus the shape
                 * (ordered / unordered / structured) that determines how
                 * the values relate to one another.
                 *
                 * For enumeration shapes, the `enumValues` multi-valued
                 * attribute holds the permitted value strings. For the
                 * structured shape, a tenant-authored spec describes the
                 * compound type; not exercised at v1.
                 *
                 * `valueShape` not `shape` — `shape` is shadowed by
                 * Items::Item::shape through standard library inheritance.
                 *
                 * Business meta model concept. */
            attribute valueShape : ValueSpaceShape;
            attribute enumValues : String[0..*];
            attribute structuredSpec : String;
        }

        @CatalogueTag {
            bmmConcern = "CanonicalRuntime";
            classification = "General";
        }
        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "IAO:InformationContentEntity";
            mappingNotes = "An AxisTransition specifies a permitted from-value to-value pair on a single axis, with the authority required to write it. Information content — a rule, not the act of transitioning. The transitioning itself, when it occurs, is a Process.";
        }
        @UserFacing {
            friendlyName = "Axis Transition";
            shortDescription = "A permitted value-to-value transition on a status axis, with the authority required to perform it.";
        }
        @PurposiveDescription {
            description = "A permitted move from one value to another on a single status axis. Declared transitions are exhaustive — any value-to-value pair not represented by an axis transition is a prohibited transition, and the system rejects attempts to make it. Each transition records what authority is required to perform it (which binding class), so the canonical-edge contract can enforce the rule uniformly.";
        }
        @Comprehension {
            surfaceEnumValues = false;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "StatusAxis";
            strength = RelationshipStrength::strong;
            rationale = "Every AxisTransition is declared on a specific StatusAxis. A change to a transition (its endpoints, its required authority) requires reassessing the axis whose transition rules it defines — the axis's runtime behaviour changes when its transitions change.";
        }
        @WeightedRelationship {
            target = "ValueSpace";
            strength = RelationshipStrength::strong;
            rationale = "A transition's from-value and to-value must be drawn from the axis's value space. A change to the transition (especially endpoint changes) requires reassessing the value space — and conversely a change to the value space may invalidate existing transitions.";
        }
        part def AxisTransition {
            doc /* A permitted value-to-value transition on a single axis.
                 *
                 * Declared transitions are exhaustive for the axis — any
                 * (fromValue, toValue) pair not represented by an
                 * AxisTransition in the permitted set is a prohibited
                 * transition. Attempts at prohibited transitions are
                 * rejected at write time by the canonical-edge contract
                 * with a category-error explanation.
                 *
                 * Cross-axis preconditions and consequences are specified
                 * in S253 §6 and will be added in a subsequent session
                 * (not in scope for S255 first implementation).
                 *
                 * Business meta model concept. */
            attribute fromValue : String;
            attribute toValue : String;
            attribute transitionLabel : String;
            attribute requiredAuthority : AxisAuthority[0..*];
        }

        // =====================================================================
        // STATUS AXIS — B71 primitive
        // =====================================================================

        @CatalogueTag {
            bmmConcern = "CanonicalRuntime";
            classification = "General";
        }
        @BfoType {
            bfoClass = "GenericallyDependentContinuant";
            midLevelClass = "IAO:InformationContentEntity";
            mappingNotes = "A StatusAxis is a structural information artefact specifying a dimension of runtime status; it is generically dependent on the canonical runtime type that declares it.";
        }
        @UserFacing {
            friendlyName = "Status Axis";
            shortDescription = "A single named dimension of status on a canonical runtime type — its values, transitions, default, authority, and scope.";
        }
        @PurposiveDescription {
            description = "A single named dimension of status that a canonical runtime instance carries. A canonical runtime type can declare several status axes — for example a booking might have a lifecycle axis, a confirmation axis, a payment axis, a cancellation axis. Each axis advances independently, with its own value space, permitted transitions, default value, and authority. The system tracks each axis as a separate triple in the substrate, so axes can be queried and reasoned over individually.";
        }
        @Comprehension {
            surfaceEnumValues = false;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "CanonicalRuntimeType";
            strength = RelationshipStrength::strong;
            rationale = "A StatusAxis is declared on a CanonicalRuntimeType — it has no independent existence. A change to an axis (its value space, its transitions, its authority) requires reassessing the canonical type whose runtime instances carry it.";
        }
        @WeightedRelationship {
            target = "ValueSpace";
            strength = RelationshipStrength::strong;
            rationale = "Every StatusAxis has a ValueSpace. A change to the axis (its meaning, its purpose) typically requires reassessing the value space that defines its permitted values.";
        }
        @WeightedRelationship {
            target = "AxisTransition";
            strength = RelationshipStrength::strong;
            rationale = "A StatusAxis declares its set of permitted AxisTransitions. A change to the axis (especially to its value space or authority) requires reassessing the transitions — they may need to be added, removed, or have their required authority adjusted.";
        }
        part def StatusAxis {
            doc /* B71 — StatusAxis as a BMM General part def.
                 *
                 * A StatusAxis instance declares WHAT A SINGLE DIMENSION
                 * OF STATUS LOOKS LIKE: its value space, its permitted
                 * transitions, its default, its authority, its scope.
                 *
                 * A canonical runtime type declares N StatusAxis part
                 * usages (one per dimension of status it carries). Runtime
                 * instances of that canonical type carry a value for each
                 * declared axis; the tuple is persisted in the SRS as one
                 * triple per axis (S253 §4.2).
                 *
                 * Source: S253 §3.1 (internal structure), §3.2 (value-space
                 * shapes), §3.3 (permitted transitions), §3.4 (authority),
                 * §3.5 (default value), §3.6 (SysML projection).
                 *
                 * Business meta model concept. */

            attribute axisName : String;
            attribute axisDescription : String;
            attribute axisScope : AxisScope;
            attribute axisAuthority : AxisAuthority[1..*];
            attribute defaultValue : String;

            part valueSpace : ValueSpace;
            part permittedTransitions : AxisTransition[0..*];
        }

        // =====================================================================
        // CANONICAL RUNTIME TYPE — Base for every canonical type
        // =====================================================================

        @CatalogueTag {
            bmmConcern = "CanonicalRuntime";
            classification = "General";
        }
        // Anchor re-set S514 (OP-125 Step 2, Ella's decision, Cyril's reason):
        // bfo:entity (BFO_0000001). CanonicalRuntimeType defines a shape — the
        // status axes a runtime type carries — whose concrete types have
        // different BFO kinds (an event is a process, a booking is an
        // information content entity, an order may be a material entity).
        // The former IndependentContinuant anchor contradicted them: HermiT
        // found the process-anchored and information-anchored subtypes
        // unsatisfiable; under Entity all were satisfiable. The annotation is
        // kept so AC-08 (grounding mandatory) stays literally satisfied.
        // midLevelClass is empty on purpose: resolve_parent_iri in
        // gen_owl_pipeline.py reads it first and looks it up only in the IAO
        // and CCO tables, so a BFO value there would come out unresolved; left
        // empty, the generator falls back to bfoClass and resolves BFO_0000001.
        @BfoType {
            bfoClass = "Entity";
            midLevelClass = "";
            mappingNotes = "CanonicalRuntimeType is the structural parent for types whose runtime instances live in DBR (business-side continuant trajectories) or DSR (system-side occurrent log). Anchored at BFO entity (S514, ADR-011): it defines a shape, not a kind of thing, and its concrete types have different BFO kinds. The BFO classification of a concrete canonical type is carried by its own @BfoType annotation; this parent establishes only the platform-level shape.";
        }
        @UserFacing {
            friendlyName = "Canonical Runtime Type";
            shortDescription = "The base type for every canonical runtime type — the things whose runtime instances live in DBR or DSR.";
        }
        @PurposiveDescription {
            description = "The structural parent for every canonical runtime type — the things whose runtime instances are persisted in the substrate as model-grounded content. A booking, a clinical encounter, a laundry batch, an order: each is a canonical runtime type, and each runtime instance carries a tuple of status axes describing where it is along each independent dimension of progress. No axis is built in: every axis is declared by the tenant on the canonical type. Whether a record of an instance is real or simulated, and whether it was direct, inferred or predicted, is carried by the platform's record of the write (the platform record module, ADR-011), not by the instance.";
        }
        @Comprehension {
            surfaceEnumValues = false;
            surfaceDomainInstantiations = true;
            surfaceRelatedConcepts = true;
            surfaceAttributes = true;
        }
        @WeightedRelationship {
            target = "StatusAxis";
            strength = RelationshipStrength::strong;
            rationale = "A CanonicalRuntimeType declares the set of StatusAxes its runtime instances carry. A change to the canonical type's structural definition (especially to its declared axes) directly affects every instance — runtime tuple shape, substrate triple structure, and comprehension all flow from the axis declarations.";
        }
        part def CanonicalRuntimeType {
            doc /* Base part def for every canonical runtime type — types
                 * whose runtime instances live in DBR (business-side
                 * continuant trajectories) or DSR (system-side occurrent
                 * log).
                 *
                 * Carries no built-in axis. Tenant-declared axes are added
                 * by the specialising canonical type. (The platform-provided
                 * epistemic axis of S253 §4.5 was retired at S514, ADR-011
                 * decision 1: the label sits on the platform's record of a
                 * write, not on the thing recorded.)
                 *
                 * Under B69 (indistinguishability), real and simulated
                 * activity produce structurally identical SRS content
                 * modulo mode. Mode is set by the platform from the declared
                 * context the record was written in; it is never supplied by
                 * a writer or by a binding class. Everything in the axis
                 * tuple is identical in shape and handling.
                 *
                 * Types that declare no axes are still first-class
                 * (S253 §4.6) and degrade gracefully: substrate queries
                 * return an empty axis tuple; comprehension shows the
                 * record's mode and method beside it; no axis-gated
                 * transitions.
                 *
                 * Business meta model concept. */

        }
    }

    package DomainIdentityTypes {
        private import ScalarValues::*;

        doc /* Domain identity: what kind of service business a tenant is,
             * what regulatory environment it operates in, and why it exists
             * in the platform (B15, S142-D1). The seven classification enums
             * and the DomainIdentity part def, formerly in Foundation's
             * CommonTypes and DomainRegistry (OP-132 step 10, groups G and H).
             * Tenant instances live in each tenant's DomainRegistration
             * package. The system-side counterpart is
             * SystemMetamodelGeneral::DomainConfigurationTypes. */

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
                 * old partiallyRegulated tier).
                 *
                 * authorisationRequiredToTrade (canon definition, S515):
                 * True where the business cannot lawfully offer its core
                 * service without a prior authorisation or licence that
                 * the authority can refuse or withdraw (for example CQC
                 * registration, or a premises licence); false otherwise. A
                 * prior registration that the authority cannot refuse,
                 * such as UK food business registration, is a notification
                 * duty, not an authorisation: it sets the attribute false
                 * and is recorded among the tenant's regulatedActivities.
                 *
                 * The pairing with DomainConfiguration is held on the
                 * system side only (DomainConfiguration.domainIdentity);
                 * this def no longer refers back (OP-132 Action 2, S515). */

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
        }
    }
}
