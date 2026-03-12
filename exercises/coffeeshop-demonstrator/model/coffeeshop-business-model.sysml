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
    private import CoffeeShop::*;

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

    part flatWhiteCatalogue : CatalogueEntry {
        doc /* Flat White — flagship espresso drink. */
        attribute :>> pricePence = 280;
        attribute :>> priceDisplay = "£2.80";
        attribute :>> availability = AvailabilityStatus::active;
        attribute :>> provisionType = ProvisionType::prepared;
        attribute :>> effectiveDate = "2026-03-12";
        attribute :>> statusNotes = "Core menu item";
    }

    part latteCatalogue : CatalogueEntry {
        attribute :>> pricePence = 280;
        attribute :>> priceDisplay = "£2.80";
        attribute :>> availability = AvailabilityStatus::active;
        attribute :>> provisionType = ProvisionType::prepared;
        attribute :>> effectiveDate = "2026-03-12";
        attribute :>> statusNotes = "Core menu item";
    }

    part americanoCatalogue : CatalogueEntry {
        attribute :>> pricePence = 250;
        attribute :>> priceDisplay = "£2.50";
        attribute :>> availability = AvailabilityStatus::active;
        attribute :>> provisionType = ProvisionType::prepared;
        attribute :>> effectiveDate = "2026-03-12";
        attribute :>> statusNotes = "Core menu item";
    }

    part cappuccinoCatalogue : CatalogueEntry {
        attribute :>> pricePence = 280;
        attribute :>> priceDisplay = "£2.80";
        attribute :>> availability = AvailabilityStatus::active;
        attribute :>> provisionType = ProvisionType::prepared;
        attribute :>> effectiveDate = "2026-03-12";
        attribute :>> statusNotes = "Core menu item";
    }

    part espressoCatalogue : CatalogueEntry {
        attribute :>> pricePence = 200;
        attribute :>> priceDisplay = "£2.00";
        attribute :>> availability = AvailabilityStatus::active;
        attribute :>> provisionType = ProvisionType::prepared;
        attribute :>> effectiveDate = "2026-03-12";
        attribute :>> statusNotes = "Core menu item — single size only";
    }

    // -- Cold drinks --

    part icedLatteCatalogue : CatalogueEntry {
        attribute :>> pricePence = 320;
        attribute :>> priceDisplay = "£3.20";
        attribute :>> availability = AvailabilityStatus::active;
        attribute :>> provisionType = ProvisionType::prepared;
        attribute :>> effectiveDate = "2026-03-12";
        attribute :>> statusNotes = "Seasonal favourite";
    }

    part coldBrewCatalogue : CatalogueEntry {
        attribute :>> pricePence = 300;
        attribute :>> priceDisplay = "£3.00";
        attribute :>> availability = AvailabilityStatus::active;
        attribute :>> provisionType = ProvisionType::prepared;
        attribute :>> effectiveDate = "2026-03-12";
        attribute :>> statusNotes = "Slow-steeped — 12hr preparation";
    }

    // -- New drinks --

    part mochaLatteCatalogue : CatalogueEntry {
        doc /* Mocha Latte — new addition, March 2026. */
        attribute :>> pricePence = 380;
        attribute :>> priceDisplay = "£3.80";
        attribute :>> availability = AvailabilityStatus::active;
        attribute :>> provisionType = ProvisionType::prepared;
        attribute :>> effectiveDate = "2026-03-12";
        attribute :>> statusNotes = "New menu item — espresso with chocolate and steamed milk";
    }

    part frappeCatalogue : CatalogueEntry {
        doc /* Frappe — new addition, March 2026. */
        attribute :>> pricePence = 420;
        attribute :>> priceDisplay = "£4.20";
        attribute :>> availability = AvailabilityStatus::active;
        attribute :>> provisionType = ProvisionType::prepared;
        attribute :>> effectiveDate = "2026-03-12";
        attribute :>> statusNotes = "New menu item — blended iced coffee";
    }

    // -- Food items (bought-in) --

    part gingerBiscuitCatalogue : CatalogueEntry {
        doc /* Ginger Biscuit — new addition, March 2026.
             * First bought-in item. Inventory tracking applies. */
        attribute :>> pricePence = 180;
        attribute :>> priceDisplay = "£1.80";
        attribute :>> availability = AvailabilityStatus::active;
        attribute :>> provisionType = ProvisionType::boughtIn;
        attribute :>> effectiveDate = "2026-03-12";
        attribute :>> statusNotes = "New menu item — bought-in, stock tracked";
    }

    part oatBarCatalogue : CatalogueEntry {
        doc /* Oat Bar — new addition, March 2026.
             * Bought-in, vegan, gluten-free. */
        attribute :>> pricePence = 220;
        attribute :>> priceDisplay = "£2.20";
        attribute :>> availability = AvailabilityStatus::active;
        attribute :>> provisionType = ProvisionType::boughtIn;
        attribute :>> effectiveDate = "2026-03-12";
        attribute :>> statusNotes = "New menu item — bought-in, vegan, GF, stock tracked";
    }
}
