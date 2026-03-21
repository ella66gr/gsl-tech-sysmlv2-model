// =========================================================================
// BUSINESS MODEL — What GenderSense offers, to whom, and how it works
// financially as a business
// =========================================================================

package BusinessModel {
    private import ScalarValues::*;
    private import Foundation::MetadataLibrary::*;

    doc /* The business model package captures the strategic logic of the
         * enterprise: what value is offered, to whom, how revenue is
         * generated, what resources are needed, and how the business
         * evolves over time. This is distinct from the business system
         * model (the other six packages) which describes the operational
         * machinery that implements this logic.
         *
         * The five concerns addressed across this package and the
         * existing model:
         * - Service Concept (here: ServiceConcept)
         * - Financial Model (here: FinancialPlanning)
         * - Resource and Capability Model (here: ResourcePlanning)
         * - Service Delivery System (ServiceDelivery package)
         * - Governance and Adaptation (Enterprise + ServiceDelivery::ClinicalGovernance)
         *
         * Cross-cutting: ActivityModel provides the activity taxonomy
         * and costing foundation that connects all five concerns.
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
        part def ValueProposition {
            doc /* A specific promise of value to a specific customer
                 * segment. Defines what the customer gets, how it
                 * differs from alternatives, and why it matters. */
            attribute propositionName : String;
            attribute description : String;
            attribute targetSegment : String;     // references a CustomerSegment by name
            attribute differentiator : String;
            attribute evidenceBasis : String;
        }

        @CatalogueTag { bmmConcern = "ServiceConcept"; classification = "General"; }
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
        part def DifferentiationClaim {
            doc /* An explicit statement of how this service differs
                 * from available alternatives, from the customer's
                 * perspective. Each claim should be testable. */
            attribute claimName : String;
            attribute statement : String;
            attribute basis : String;
            attribute testability : String;
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
            attribute :>> targetSegment = "Self-referring individuals";
            attribute :>> differentiator = "NHS GIC median wait exceeds 4 years";
            attribute :>> evidenceBasis = "Published NHS waiting time data";
        }

        part integratedDigitalClinical : ValueProposition {
            attribute :>> propositionName = "Integrated digital and clinical care";
            attribute :>> description = "Patient portal with real-time pathway visibility alongside clinical expertise";
            attribute :>> targetSegment = "Self-referring individuals";
            attribute :>> differentiator = "Most private gender services offer clinical-only with no digital integration";
            attribute :>> evidenceBasis = "Platform capability comparison";
        }

        part specialistExpertise : ValueProposition {
            attribute :>> propositionName = "Specialist expertise";
            attribute :>> description = "Care delivered by clinicians with specific gender identity healthcare credentials";
            attribute :>> targetSegment = "GP-referred patients";
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

        // -- Variant B value propositions ----------------------

        part holisticCareModel : ValueProposition {
            attribute :>> propositionName = "Holistic care model";
            attribute :>> description = "Clinical care, coaching, education, and peer community as one integrated package";
            attribute :>> targetSegment = "Self-referring individuals";
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
        part def ActivityRecord {
            doc /* A recorded instance of an activity. At the tracked
                 * level, the system produces these for every observable
                 * activity. At coarser levels, they are estimated
                 * aggregates. */
            attribute activityType : String;
            attribute participants : String;
            attribute durationMinutes : Integer;
            attribute resourcesConsumed : String;
            attribute recordGranularity : GranularityLevel;
        }

        @CatalogueTag { bmmConcern = "ActivityModel"; classification = "General"; }
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
        part def ActivityBudget {
            doc /* A planned allocation of activity volume by type,
                 * period, and resource. The activity-level equivalent
                 * of a financial budget. */
            attribute budgetPeriod : String;
            attribute activityType : String;
            attribute plannedVolume : Integer;
            attribute plannedTotalHours : Real;
            attribute granularity : GranularityLevel;
        }

        @CatalogueTag { bmmConcern = "ActivityModel"; classification = "General"; }
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
        part def ActivityGranularity {
            doc /* Policy declaration: the granularity level at which
                 * activity is tracked for a given business area. */
            attribute businessArea : String;
            attribute currentLevel : GranularityLevel;
            attribute targetLevel : GranularityLevel;
            attribute migrationNotes : String;
        }

        @CatalogueTag { bmmConcern = "ActivityModel"; classification = "General"; }
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
        part def ActivityCostAllocation {
            doc /* The mapping from an activity (or aggregate) to its
                 * financial cost. Makes resource consumption visible
                 * to the financial model. */
            attribute activityType : String;
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
        part def ResourceInstance {
            doc /* A specific resource available to the business at
                 * a defined capacity and cost. Represents planning-
                 * level archetypes ("a prescribing clinician at
                 * 0.5 FTE") rather than named individuals. */
            attribute instanceName : String;
            attribute resourceType : String;       // references a ResourceType by name
            attribute capacity : String;           // e.g. "0.5 FTE", "1 instance"
            attribute availabilityNotes : String;
            attribute costPerUnit : Real;
            attribute costBasis : String;          // per month, per hour, per use
        }

        @CatalogueTag { bmmConcern = "ResourceCapability"; classification = "General"; }
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
            attribute affectedResource : String;   // references a ResourceType by name
            attribute limit : String;
            attribute regulatorySourceDescription : String;   // e.g. "Enterprise::Regulation" or empty
        }

        // -- Inventory tracking abstraction ----------------------
        // Business meta model concept: operational stock tracking
        // for any business that stocks things.
        // Added Session 29: CSW Extension Phase 10 (item 8.2).
        // Source: gsl-spec-catalogue-inventory-v2.1.md §8.2

        @CatalogueTag { bmmConcern = "ResourceCapability"; classification = "General"; }
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
            attribute catalogueEntryReference : String;
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
            attribute :>> resourceType = "Prescribing clinician";
            attribute :>> capacity = "0.5 FTE";
            attribute :>> availabilityNotes = "3 clinical days per fortnight";
            attribute :>> costPerUnit = 2500.0;
            attribute :>> costBasis = "per month";
        }

        part clinicianMonth10to24 : ResourceInstance {
            doc /* Scaled clinician capacity: 0.8 FTE from month 10.
                 * Supports growth to ~40 active patients. */
            attribute :>> instanceName = "Prescribing clinician (months 10-24)";
            attribute :>> resourceType = "Prescribing clinician";
            attribute :>> capacity = "0.8 FTE";
            attribute :>> availabilityNotes = "4 clinical days per week";
            attribute :>> costPerUnit = 4000.0;
            attribute :>> costBasis = "per month";
        }

        part adminInstance : ResourceInstance {
            attribute :>> instanceName = "Administrative support";
            attribute :>> resourceType = "Administrative support";
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
            attribute :>> affectedResource = "Prescribing clinician";
            attribute :>> limit = "40 active patients per FTE clinician";
            attribute :>> regulatorySourceDescription = "";
        }

        part prescribingQualification : ResourceConstraint {
            doc /* Regulatory requirement: the prescribing clinician
                 * must hold appropriate qualification for hormone
                 * prescribing. Maps to Enterprise::Regulation. */
            attribute :>> constraintName = "Prescribing qualification";
            attribute :>> constraintType = "regulatory";
            attribute :>> affectedResource = "Prescribing clinician";
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
            attribute :>> resourceType = "Gender identity coach";
            attribute :>> capacity = "0.5 FTE";
            attribute :>> availabilityNotes = "2.5 days per week";
            attribute :>> costPerUnit = 1500.0;
            attribute :>> costBasis = "per month";
        }

        part moderatorInstance : ResourceInstance {
            attribute :>> instanceName = "Community moderator";
            attribute :>> resourceType = "Community moderator";
            attribute :>> capacity = "0.2 FTE";
            attribute :>> availabilityNotes = "1 day per week";
            attribute :>> costPerUnit = 400.0;
            attribute :>> costBasis = "per month";
        }

        part secondClinicianMonth6to24 : ResourceInstance {
            doc /* Second clinician added at month 6 in Variant B.
                 * Steps from 0.5 to 1.0 FTE at month 12. */
            attribute :>> instanceName = "Second prescribing clinician (months 6-24)";
            attribute :>> resourceType = "Prescribing clinician";
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
        part def ObjectiveCapabilityMapping {
            doc /* Maps a StrategicObjective to the Capability
                 * usages that contribute to achieving it.
                 * Phase 7 traceability pattern. */
            attribute objectiveRef : String;
            ref supportingCapabilities : Capability[1..*];
        }

        part patientCohortMapping : ObjectiveCapabilityMapping {
            doc /* objectivePatientCohort is achieved through
                 * prescribing, assessment, and monitoring. */
            attribute :>> objectiveRef = "objectivePatientCohort";
        }

        part sharedCareMapping : ObjectiveCapabilityMapping {
            doc /* objectiveSharedCare is achieved through
                 * prescribing and monitoring capabilities
                 * extended with GP shared care protocols. */
            attribute :>> objectiveRef = "objectiveSharedCare";
        }

        part platformLaunchMapping : ObjectiveCapabilityMapping {
            doc /* objectivePlatformLaunch is achieved through
                 * assessment and prescribing capabilities
                 * exposed via the patient portal. */
            attribute :>> objectiveRef = "objectivePlatformLaunch";
        }

        part breakEvenMapping : ObjectiveCapabilityMapping {
            doc /* objectiveBreakEven is a financial outcome
                 * achieved through the combined operation of
                 * all clinical capabilities at sufficient
                 * volume. No single capability satisfies it. */
            attribute :>> objectiveRef = "objectiveBreakEven";
        }
    }

    // =================================================================
    // FINANCIAL PLANNING — How money flows through the business
    // =================================================================

    package FinancialPlanning {
        private import ScalarValues::*;

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
        part def RevenueStream {
            doc /* A mechanism by which income is generated. */
            attribute streamName : String;
            attribute sourceSegment : String;
            attribute triggerEvent : String;
            attribute pricingModelRef : String;
            attribute projectedVolume : String;
        }

        @CatalogueTag { bmmConcern = "FinancialModel"; classification = "General"; }
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
        part def CostDriver {
            doc /* A structural factor that generates cost. */
            attribute driverName : String;
            attribute linkedResource : String;
            attribute costBehaviour : String;
            attribute estimatedUnitCost : Real;
            attribute scalingFactor : String;
        }

        @CatalogueTag { bmmConcern = "FinancialModel"; classification = "General"; }
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
        part def UnitEconomics {
            doc /* The financial profile of a single unit of service delivery. */
            attribute offeringRef : String;
            attribute revenuePerUnit : Real;
            attribute costPerUnit : Real;
            attribute marginPerUnit : Real;
            attribute breakdownNotes : String;
        }

        @CatalogueTag { bmmConcern = "FinancialModel"; classification = "General"; }
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
        part def PricingModel {
            doc /* The logic that determines what a customer pays. */
            attribute pricingModelName : String;
            attribute pricingType : PricingType;
            attribute basePrice : Real;
            attribute adjustmentLogic : String;
            attribute applicableOfferings : String;
        }

        @CatalogueTag { bmmConcern = "FinancialModel"; classification = "General"; }
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
        part def FinancialProjection {
            doc /* A named financial projection linked to a scenario.
                 * Lightweight placeholder — full mechanics in
                 * BusinessScenarios. */
            attribute projectionName : String;
            attribute scenarioRef : String;
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
            attribute :>> pricingModelRef = "perEpisodePricing";
            attribute :>> projectedVolume = "4 per month (year 1), 6 per month (year 2)";
        }

        part monitoringRevenue : RevenueStream {
            attribute :>> streamName = "Monitoring fees";
            attribute :>> sourceSegment = "Patients in stable monitoring";
            attribute :>> triggerEvent = "Quarterly monitoring review";
            attribute :>> pricingModelRef = "perEpisodePricing";
            attribute :>> projectedVolume = "grows with stable cohort — see projection";
        }

        part clinicianCost : CostDriver {
            attribute :>> driverName = "Clinician cost";
            attribute :>> linkedResource = "Prescribing clinician";
            attribute :>> costBehaviour = "semi-variable — fixed FTE cost, scaled in steps as caseload grows";
            attribute :>> estimatedUnitCost = 5000.0;
            attribute :>> scalingFactor = "per FTE per month";
        }

        part adminCost : CostDriver {
            attribute :>> driverName = "Administrative support cost";
            attribute :>> linkedResource = "Administrative support";
            attribute :>> costBehaviour = "semi-variable";
            attribute :>> estimatedUnitCost = 1800.0;
            attribute :>> scalingFactor = "per FTE per month";
        }

        part platformCost : CostDriver {
            attribute :>> driverName = "Platform hosting and infrastructure";
            attribute :>> linkedResource = "Technology platform";
            attribute :>> costBehaviour = "fixed";
            attribute :>> estimatedUnitCost = 200.0;
            attribute :>> scalingFactor = "per month";
        }

        part insuranceCost : CostDriver {
            attribute :>> driverName = "Professional indemnity insurance";
            attribute :>> linkedResource = "Professional indemnity insurance";
            attribute :>> costBehaviour = "fixed";
            attribute :>> estimatedUnitCost = 250.0;
            attribute :>> scalingFactor = "per month";
        }

        part labCost : CostDriver {
            attribute :>> driverName = "Laboratory costs";
            attribute :>> linkedResource = "Laboratory services";
            attribute :>> costBehaviour = "variable";
            attribute :>> estimatedUnitCost = 45.0;
            attribute :>> scalingFactor = "per blood panel";
        }

        part overheadCost : CostDriver {
            attribute :>> driverName = "Overhead allocation";
            attribute :>> linkedResource = "";
            attribute :>> costBehaviour = "percentage of direct cost";
            attribute :>> estimatedUnitCost = 25.0;
            attribute :>> scalingFactor = "percentage of direct cost";
        }

        part assessmentUnitEconomics : UnitEconomics {
            attribute :>> offeringRef = "Initial Assessment";
            attribute :>> revenuePerUnit = 600.0;
            attribute :>> costPerUnit = 350.0;
            attribute :>> marginPerUnit = 250.0;
            attribute :>> breakdownNotes = "Clinician 2hrs £125, baseline bloods £90, platform/admin £65, overhead £70";
        }

        part monitoringUnitEconomics : UnitEconomics {
            attribute :>> offeringRef = "Ongoing Monitoring (quarterly)";
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
            attribute :>> scenarioRef = "Lean Clinical (Variant A)";
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
            attribute :>> pricingModelRef = "subscriptionPricing";
            attribute :>> projectedVolume = "grows with active patient cohort";
        }

        part coachCost : CostDriver {
            attribute :>> driverName = "Coach cost";
            attribute :>> linkedResource = "Gender identity coach";
            attribute :>> costBehaviour = "semi-variable — fixed FTE cost, added when coaching offering launches";
            attribute :>> estimatedUnitCost = 3000.0;
            attribute :>> scalingFactor = "per FTE per month";
        }

        part moderatorCost : CostDriver {
            attribute :>> driverName = "Community moderator cost";
            attribute :>> linkedResource = "Community moderator";
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
            attribute :>> offeringRef = "Subscription (monthly)";
            attribute :>> revenuePerUnit = 99.0;
            attribute :>> costPerUnit = 55.0;
            attribute :>> marginPerUnit = 44.0;
            attribute :>> breakdownNotes = "Coach allocation £30, moderator allocation £8, platform £12, overhead £5. All values placeholder.";
        }

        part fullPlatformProjection : FinancialProjection {
            attribute :>> projectionName = "Full Platform 24-month projection";
            attribute :>> scenarioRef = "Full Platform (Variant B)";
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
}
