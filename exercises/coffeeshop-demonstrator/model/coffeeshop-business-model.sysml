// =========================================================================
// Coffee Shop Business Model Extension
// =========================================================================
// Validates that the BusinessModel::ServiceConcept and
// BusinessModel::ActivityModel part defs accommodate a simple service
// business. Tests cross-project import from the main model.
//
// Phase 1 demonstrator (Session 14, 10 March 2026):
//   ServiceConcept, ActivityModel, ActivityGranularity usages.
// CSW Extension Phase 1 (Session 20, 12 March 2026):
//   CatalogueEntry usages for all 11 menu items.
//   catalogueMaintenance activity type.
//
// Companion: gsl-plan-workstream-csw-extension-2026-03-12.md
// =========================================================================

package CoffeeShopBusinessModel {
    private import ScalarValues::*;
    private import BusinessModel::ServiceConcept::*;
    private import BusinessModel::ActivityModel::*;
    private import Foundation::CommonTypes::*;
    private import CoffeeShop::*;
    private import BusinessModel::StakeholderModel::*;

    // Import note: Both CoffeeShop and BusinessModel::ServiceConcept
    // export CatalogueEntry and ExternalReference (name collision
    // introduced Session 29 when meta model CatalogueEntry was added).
    // Catalogue entry usages below use fully qualified
    // CoffeeShop::CatalogueEntry to resolve the ambiguity.

    doc /* Coffee shop business model extension. Instantiates the
         * ServiceConcept and ActivityModel part defs from the main
         * BusinessModel package to validate that the abstractions
         * work for a simple service business.
         *
         * If these feel over-engineered for a coffee shop, the
         * abstractions may need simplifying. If they feel natural,
         * the design is sound. */

    // -- Service Concept --------------------------------------

    part walkInCustomers : CustomerSegment {
        attribute :>> segmentName = "Walk-in customers";
        attribute :>> description = "Passers-by and regulars who visit the counter";
        attribute :>> needs = "Quick, good coffee at a fair price";
        attribute :>> acquisitionChannel = "Foot traffic, signage, word of mouth";
        attribute :>> willingnessToPayIndicator = "medium";
    }

    part drinkOrder : ServiceOffering {
        doc /* The core (and only) service offering for the coffee
             * shop. Maps to the existing fulfil-drink pathway. */
        attribute :>> offeringName = "Drink order";
        attribute :>> description = "Customer orders and receives a prepared drink";
        attribute :>> scope = "Order taking, drink preparation, serving";
        attribute :>> pricingBasis = "per-item";
        attribute :>> estimatedDurationWeeks = 0;  // immediate service
        attribute :>> clinicalPathwayRef = "fulfil-drink-orchestration";
    }

    part counterService : Channel {
        attribute :>> channelName = "Counter service";
        attribute :>> description = "In-person ordering at the shop counter";
        attribute :>> channelType = "acquisition and delivery";
        attribute :>> estimatedReach = "local — foot traffic radius";
        attribute :>> estimatedCostLevel = "low";
        attribute :>> conversionNotes = "Very high — customers at the counter are ready to buy";
    }

    // -- Activity Model ---------------------------------------
    //
    // Five activity types, one per category, demonstrating
    // the taxonomy for a simple service business.

    part makeDrink : ActivityType {
        doc /* Service delivery: the core value-producing activity.
             * Already modelled as pathway steps in the fulfil-drink
             * action flow. */
        attribute :>> activityTypeName = "Make drink";
        attribute :>> activityCategory = ActivityCategory::serviceDelivery;
        attribute :>> description = "Prepare and serve a customer drink order";
        attribute :>> expectedDurationMinutes = 4;
        attribute :>> frequencyNotes = "Per customer order";
    }

    part prepAndClean : ActivityType {
        doc /* Service enabling: necessary to support delivery but
             * not directly visible to the customer. */
        attribute :>> activityTypeName = "Prep ingredients and clean equipment";
        attribute :>> activityCategory = ActivityCategory::serviceEnabling;
        attribute :>> description = "Grind beans, prepare milk, clean portafilter and steam wand";
        attribute :>> expectedDurationMinutes = 30;
        attribute :>> frequencyNotes = "Twice daily — opening and mid-shift";
    }

    part healthSafetyChecks : ActivityType {
        attribute :>> activityTypeName = "Health and safety checks";
        attribute :>> activityCategory = ActivityCategory::governance;
        attribute :>> description = "Temperature logs, hygiene checks, stock rotation, equipment inspection";
        attribute :>> expectedDurationMinutes = 15;
        attribute :>> frequencyNotes = "Daily — opening";
    }

    part baristaTraining : ActivityType {
        attribute :>> activityTypeName = "Barista training";
        attribute :>> activityCategory = ActivityCategory::development;
        attribute :>> description = "Skills development, new menu items, latte art practice";
        attribute :>> expectedDurationMinutes = 60;
        attribute :>> frequencyNotes = "Weekly";
    }

    part tillReconciliation : ActivityType {
        attribute :>> activityTypeName = "Till reconciliation";
        attribute :>> activityCategory = ActivityCategory::overhead;
        attribute :>> description = "Cash count, card terminal reconciliation, daily banking";
        attribute :>> expectedDurationMinutes = 15;
        attribute :>> frequencyNotes = "Daily — closing";
    }

    part catalogueMaintenance : ActivityType {
        doc /* Administrative data management: maintaining the
             * product catalogue, updating prices, managing
             * availability status and inventory records. */
        attribute :>> activityTypeName = "Catalogue maintenance";
        attribute :>> activityCategory = ActivityCategory::overhead;
        attribute :>> description = "Add, edit, and manage menu items, pricing, and stock levels";
        attribute :>> expectedDurationMinutes = 15;
        attribute :>> frequencyNotes = "As needed — typically weekly or when menu changes";
    }

    // -- Granularity policy ------------------------------------

    part serviceDeliveryGranularity : ActivityGranularity {
        doc /* Service delivery is at tracked level from day one —
             * the pathway model already produces observable events
             * for every drink order. */
        attribute :>> businessArea = "Service delivery";
        attribute :>> currentLevel = GranularityLevel::tracked;
        attribute :>> targetLevel = GranularityLevel::tracked;
        attribute :>> migrationNotes = "Already tracked via pathway workflow events";
    }

    part enablingGranularity : ActivityGranularity {
        attribute :>> businessArea = "Service enabling";
        attribute :>> currentLevel = GranularityLevel::envelope;
        attribute :>> targetLevel = GranularityLevel::category;
        attribute :>> migrationNotes = "Could track prep sessions as discrete events if costing precision needed";
    }

    part governanceGranularity : ActivityGranularity {
        attribute :>> businessArea = "Governance";
        attribute :>> currentLevel = GranularityLevel::envelope;
        attribute :>> targetLevel = GranularityLevel::envelope;
        attribute :>> migrationNotes = "Low volume — envelope estimate sufficient";
    }

    part developmentGranularity : ActivityGranularity {
        attribute :>> businessArea = "Development";
        attribute :>> currentLevel = GranularityLevel::envelope;
        attribute :>> targetLevel = GranularityLevel::envelope;
        attribute :>> migrationNotes = "Weekly training session — envelope adequate";
    }

    part overheadGranularity : ActivityGranularity {
        attribute :>> businessArea = "Overhead";
        attribute :>> currentLevel = GranularityLevel::envelope;
        attribute :>> targetLevel = GranularityLevel::envelope;
        attribute :>> migrationNotes = "Low volume routine admin — envelope adequate";
    }

    // -- Catalogue Entries ------------------------------------
    //
    // Business decisions about what to offer and at what price.
    // Each entry references a menu item and adds business context.
    // Provision type classification determines inventory semantics.
    // The item ref is structural — specific MenuItem binding is a
    // runtime/database concern, not modelled here.

    // -- Hot drinks --

    part flatWhiteCatalogue : CoffeeShop::CatalogueEntry {
        doc /* Flat White — flagship espresso drink. */
        attribute :>> pricePence = 280;
        attribute :>> priceDisplay = "£2.80";
        attribute :>> availability = AvailabilityStatus::active;
        attribute :>> provisionType = ProvisionType::prepared;
        attribute :>> effectiveDate = "2026-03-12";
        attribute :>> statusNotes = "Core menu item";
    }

    part latteCatalogue : CoffeeShop::CatalogueEntry {
        attribute :>> pricePence = 280;
        attribute :>> priceDisplay = "£2.80";
        attribute :>> availability = AvailabilityStatus::active;
        attribute :>> provisionType = ProvisionType::prepared;
        attribute :>> effectiveDate = "2026-03-12";
        attribute :>> statusNotes = "Core menu item";
    }

    part americanoCatalogue : CoffeeShop::CatalogueEntry {
        attribute :>> pricePence = 250;
        attribute :>> priceDisplay = "£2.50";
        attribute :>> availability = AvailabilityStatus::active;
        attribute :>> provisionType = ProvisionType::prepared;
        attribute :>> effectiveDate = "2026-03-12";
        attribute :>> statusNotes = "Core menu item";
    }

    part cappuccinoCatalogue : CoffeeShop::CatalogueEntry {
        attribute :>> pricePence = 280;
        attribute :>> priceDisplay = "£2.80";
        attribute :>> availability = AvailabilityStatus::active;
        attribute :>> provisionType = ProvisionType::prepared;
        attribute :>> effectiveDate = "2026-03-12";
        attribute :>> statusNotes = "Core menu item";
    }

    part espressoCatalogue : CoffeeShop::CatalogueEntry {
        attribute :>> pricePence = 200;
        attribute :>> priceDisplay = "£2.00";
        attribute :>> availability = AvailabilityStatus::active;
        attribute :>> provisionType = ProvisionType::prepared;
        attribute :>> effectiveDate = "2026-03-12";
        attribute :>> statusNotes = "Core menu item — single size only";
    }

    // -- Cold drinks --

    part icedLatteCatalogue : CoffeeShop::CatalogueEntry {
        attribute :>> pricePence = 320;
        attribute :>> priceDisplay = "£3.20";
        attribute :>> availability = AvailabilityStatus::active;
        attribute :>> provisionType = ProvisionType::prepared;
        attribute :>> effectiveDate = "2026-03-12";
        attribute :>> statusNotes = "Seasonal favourite";
    }

    part coldBrewCatalogue : CoffeeShop::CatalogueEntry {
        attribute :>> pricePence = 300;
        attribute :>> priceDisplay = "£3.00";
        attribute :>> availability = AvailabilityStatus::active;
        attribute :>> provisionType = ProvisionType::prepared;
        attribute :>> effectiveDate = "2026-03-12";
        attribute :>> statusNotes = "Slow-steeped — 12hr preparation";
    }

    // -- New drinks --

    part mochaLatteCatalogue : CoffeeShop::CatalogueEntry {
        doc /* Mocha Latte — new addition, March 2026. */
        attribute :>> pricePence = 380;
        attribute :>> priceDisplay = "£3.80";
        attribute :>> availability = AvailabilityStatus::active;
        attribute :>> provisionType = ProvisionType::prepared;
        attribute :>> effectiveDate = "2026-03-12";
        attribute :>> statusNotes = "New menu item — espresso with chocolate and steamed milk";
    }

    part frappeCatalogue : CoffeeShop::CatalogueEntry {
        doc /* Frappe — new addition, March 2026. */
        attribute :>> pricePence = 420;
        attribute :>> priceDisplay = "£4.20";
        attribute :>> availability = AvailabilityStatus::active;
        attribute :>> provisionType = ProvisionType::prepared;
        attribute :>> effectiveDate = "2026-03-12";
        attribute :>> statusNotes = "New menu item — blended iced coffee";
    }

    // -- Food items (bought-in) --

    part gingerBiscuitCatalogue : CoffeeShop::CatalogueEntry {
        doc /* Ginger Biscuit — new addition, March 2026.
             * First bought-in item. Inventory tracking applies. */
        attribute :>> pricePence = 180;
        attribute :>> priceDisplay = "£1.80";
        attribute :>> availability = AvailabilityStatus::active;
        attribute :>> provisionType = ProvisionType::boughtIn;
        attribute :>> effectiveDate = "2026-03-12";
        attribute :>> statusNotes = "New menu item — bought-in, stock tracked";
    }

    part oatBarCatalogue : CoffeeShop::CatalogueEntry {
        doc /* Oat Bar — new addition, March 2026.
             * Bought-in, vegan, gluten-free. */
        attribute :>> pricePence = 220;
        attribute :>> priceDisplay = "£2.20";
        attribute :>> availability = AvailabilityStatus::active;
        attribute :>> provisionType = ProvisionType::boughtIn;
        attribute :>> effectiveDate = "2026-03-12";
        attribute :>> statusNotes = "New menu item — bought-in, vegan, GF, stock tracked";
    }

    // -- Persistence Policies ---------------------------------
    //
    // Business system meta model instantiation: explicit
    // architectural reasoning for where each CSW domain concept
    // is persisted and why. Makes the three-persistence-layer
    // architecture queryable and auditable.
    //
    // Added Session 29: CSW Extension Phase 10 (item 8.3).
    // Source: gsl-spec-catalogue-inventory-v2.1.md §8.3

    part catalogueEntryPolicy : PersistencePolicy {
        doc /* Business reference data. Simple CRUD, relational
             * joins to menu items and inventory. No clinical
             * significance. */
        attribute :>> domainConcept = "CatalogueEntry";
        attribute :>> targetLayer = PersistenceLayer::businessDatabase;
        attribute :>> rationale = "Business reference data. Simple CRUD, relational joins. No clinical significance.";
    }

    part inventoryRecordPolicy : PersistencePolicy {
        doc /* Operational state. Atomic decrement on sale. No
             * archetype validation needed. */
        attribute :>> domainConcept = "InventoryRecord";
        attribute :>> targetLayer = PersistenceLayer::businessDatabase;
        attribute :>> rationale = "Operational state. Atomic decrement on sale. No archetype validation needed.";
    }

    part orderRecordPolicy : PersistencePolicy {
        doc /* Clinical analogue. Benefits from archetype validation,
             * immutable versioning, audit trail. */
        attribute :>> domainConcept = "OrderRecord";
        attribute :>> targetLayer = PersistenceLayer::clinicalDataRepository;
        attribute :>> rationale = "Clinical analogue. Archetype validation, immutable versioning, audit trail.";
    }

    part feedbackRecordPolicy : PersistencePolicy {
        doc /* Qualitative assessment. Archetype-validated, versioned,
             * queryable via AQL. */
        attribute :>> domainConcept = "FeedbackRecord";
        attribute :>> targetLayer = PersistenceLayer::clinicalDataRepository;
        attribute :>> rationale = "Qualitative assessment. Archetype-validated, versioned, queryable via AQL.";
    }

    part orderWorkflowPolicy : PersistencePolicy {
        doc /* Stateful process. Durable execution, signal handling,
             * activity orchestration. */
        attribute :>> domainConcept = "OrderWorkflow";
        attribute :>> targetLayer = PersistenceLayer::processEngine;
        attribute :>> rationale = "Stateful process. Durable execution, signal handling, activity orchestration.";
    }

    part externalKnowledgePolicy : PersistencePolicy {
        doc /* Knowledge the system links to but does not own.
             * Coffee shop: supplier datasheets.
             * GSL: SPCs, BNF entries, NICE guidance. */
        attribute :>> domainConcept = "ExternalKnowledge";
        attribute :>> targetLayer = PersistenceLayer::externalReference;
        attribute :>> rationale = "Knowledge the system links to but does not own.";
    }

    // -- Stakeholder Model ------------------------------------
    //
    // Cross-domain validation: StakeholderModel instantiations for
    // a simple retail service business. Session 81.

    part localAuthorityRelationship : StakeholderRelationship {
        doc /* Local authority food safety — the primary regulatory
             * relationship for a coffee shop. */
        attribute :>> stakeholderName = "Local authority (food safety)";
        attribute :>> stakeholderDescription = "Environmental health department responsible for food safety inspections and ratings.";
        attribute :>> relationshipNature = RelationshipNature::regulatory;
        attribute :>> obligationsInward = "Sets food hygiene standards, conducts inspections, issues food hygiene ratings.";
        attribute :>> obligationsOutward = "Comply with food hygiene regulations, maintain premises standards, cooperate with inspections.";
        attribute :>> informationExchanged = "Registration details, inspection evidence (outward). Inspection reports, ratings, improvement notices (inward).";
        attribute :>> governanceArrangements = "Food business registration. Periodic unannounced inspections under the Food Hygiene Rating Scheme.";
        attribute :>> healthIndicators = "Current food hygiene rating (target: 5), time since last inspection, any outstanding improvement notices.";
        attribute :>> reviewCadence = "Inspection cycle determined by local authority — typically 6-18 months depending on risk rating.";
    }

    part landlordRelationship : StakeholderRelationship {
        attribute :>> stakeholderName = "Landlord";
        attribute :>> stakeholderDescription = "Property owner — contractual relationship governing premises use.";
        attribute :>> relationshipNature = RelationshipNature::contractual;
        attribute :>> obligationsInward = "Provides and maintains premises. Structural repairs, insurance of building.";
        attribute :>> obligationsOutward = "Pay rent, maintain interior, comply with lease terms, insure contents and liability.";
        attribute :>> informationExchanged = "Maintenance requests (outward). Lease terms, planned works, rent reviews (inward).";
        attribute :>> governanceArrangements = "Commercial lease agreement. Annual rent review.";
        attribute :>> healthIndicators = "Rent payment status, maintenance response times, lease renewal status.";
        attribute :>> reviewCadence = "Quarterly informal. Annual rent review. Lease renewal at term end.";
    }

    part deliveryPlatformPartnership : CooperativeArrangement {
        doc /* Delivery platform partnership — shared order
             * fulfilment. Neither party delivers the full
             * experience independently. */
        attribute :>> arrangementName = "Delivery platform partnership";
        attribute :>> cooperatingEntity = "Delivery platform (e.g. Deliveroo, UberEats)";
        attribute :>> sharedOutcome = "Delivery of coffee shop products to customers who order remotely — the shop prepares, the platform delivers";
        attribute :>> responsibilitySplit = "Shop: order preparation, packaging, quality control. Platform: customer interface, delivery logistics, payment processing.";
        attribute :>> protocolReference = "Platform partner agreement and order integration specification";
        attribute :>> informationSharing = "Order details and preparation status (via platform API). Delivery status and customer feedback (from platform).";
        attribute :>> disputeResolution = "Platform dispute resolution process for order issues. Escalation to account manager for systemic problems.";
        attribute :>> performanceIndicators = "Order accuracy rate, preparation time, delivery rating, customer complaints via platform.";
    }

    part coffeeBeanSupply : ExternalDependency {
        attribute :>> dependencyName = "Coffee bean supply";
        attribute :>> provider = "Specialty coffee roaster/wholesaler";
        attribute :>> dependencyDescription = "Supply of roasted coffee beans — the core input for the business's primary product.";
        attribute :>> criticality = DependencyCriticality::essential;
        attribute :>> substitutability = "Multiple specialty roasters available. Switching may change flavour profile and affect customer expectations. Blend matching possible.";
        attribute :>> contingencyPlan = "Secondary supplier relationship maintained. Emergency stock of standard blend (2 weeks). Customer communication plan for blend changes.";
        attribute :>> contractualTerms = "Monthly order with volume discount. 30-day payment terms.";
        attribute :>> supplyRisk = "Supply chain disruption (shipping, harvest failure), price volatility due to commodity market, quality inconsistency.";
    }

    part localNeighbourhood : CommunityRelationship {
        attribute :>> communityName = "Local neighbourhood";
        attribute :>> communityDescription = "Residents, workers, and visitors in the immediate area around the shop.";
        attribute :>> relationshipToService = "Constitutive — the neighbourhood provides the customer base and the shop contributes to local character and social life.";
        attribute :>> engagementMode = "Community noticeboard, local events participation, loyalty programme, regular customer relationships.";
        attribute :>> mutualBenefit = "Community gains a social gathering place and quality coffee. Shop gains loyal customer base and word-of-mouth referrals.";
        attribute :>> communityVoice = "Customer feedback, informal conversations, social media engagement, local business network meetings.";
    }

    part cafeParticipation : ParticipationModel {
        doc /* Minimal participation — customer as recipient. The
             * coffee shop has the lightest participation model of
             * all demonstrator domains. */
        attribute :>> participationName = "Counter ordering";
        attribute :>> participantRole = "Recipient — customer orders and receives, minimal co-production";
        attribute :>> participationDescription = "Customer selects from menu, places order, pays, and receives prepared drink. Participation is limited to preference expression at point of order.";
        attribute :>> informationContribution = "Order preferences (drink type, milk choice, extras). No ongoing information contribution.";
        attribute :>> decisionInvolvement = "Informed — customer chooses from available options. No shared decision-making.";
        attribute :>> selfServiceScope = "Menu browsing, order placement (counter or app). No self-service preparation.";
        attribute :>> supportRequired = "Clear menu display, allergen information, queue management.";
    }
}
