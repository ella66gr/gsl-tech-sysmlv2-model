// =========================================================================
// Coffee Shop Business Model Extension — Phase 1 Demonstrator
// =========================================================================
// Validates that the BusinessModel::ServiceConcept and
// BusinessModel::ActivityModel part defs accommodate a simple service
// business. Tests cross-project import from the main model.
//
// Date: 10 March 2026 (Session 14)
// Companion: gsl-plan-coffeeshop-demonstrator-integration-2026-03-10.md
//   section 5, Phase 1 Extension
// =========================================================================

package CoffeeShopBusinessModel {
    private import ScalarValues::*;
    private import BusinessModel::ServiceConcept::*;
    private import BusinessModel::ActivityModel::*;

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
}
