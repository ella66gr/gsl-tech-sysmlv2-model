// =========================================================================
// COFFEE SHOP DEMONSTRATOR — Resource and Financial Planning Extension
// =========================================================================
//
// Validates ResourcePlanning and FinancialPlanning abstractions against
// the coffee shop domain. Companion to coffeeshop-business-model.sysml
// (Phase 1 demonstrator extension).
//
// Per gsl-plan-coffeeshop-demonstrator-integration-2026-03-10.md
// section 5 Phase 2 Extension.

package CoffeeshopResourceFinancial {
    private import ScalarValues::*;
    private import BusinessModel::ResourcePlanning::*;
    private import BusinessModel::FinancialPlanning::*;

    // -- Resource types ----------------------------------------

    part barista : ResourceType {
        attribute :>> resourceTypeName = "Barista";
        attribute :>> category = "personnel";
        attribute :>> acquisitionMethod = "employed";
        attribute :>> costProfile = "£12 per hour";
        attribute :>> capacityUnit = "FTE";
    }

    part espressoMachine : ResourceType {
        attribute :>> resourceTypeName = "Espresso machine";
        attribute :>> category = "equipment";
        attribute :>> acquisitionMethod = "purchased or leased";
        attribute :>> costProfile = "£50 per month lease or £3,000 purchase";
        attribute :>> capacityUnit = "machines";
    }

    part counterSpace : ResourceType {
        attribute :>> resourceTypeName = "Counter service space";
        attribute :>> category = "estate";
        attribute :>> acquisitionMethod = "rented";
        attribute :>> costProfile = "£2,000 per month rent";
        attribute :>> capacityUnit = "counters";
    }

    part ingredientStock : ResourceType {
        attribute :>> resourceTypeName = "Ingredient stock";
        attribute :>> category = "consumables";
        attribute :>> acquisitionMethod = "purchased";
        attribute :>> costProfile = "£0.80 per drink average";
        attribute :>> capacityUnit = "servings";
    }

    // -- Capability -------------------------------------------

    part serveDrink : Capability {
        attribute :>> capabilityName = "Serve a drink";
        attribute :>> description = "Prepare and serve a hot or cold drink to a customer at the counter";
        attribute :>> requiredResources = "1 barista + 1 espresso machine + ingredients + counter space";
        attribute :>> enabledOfferingsDescription = "Drink order";
    }

    // -- Capacity model ---------------------------------------

    part singleBaristaCapacity : CapacityModel {
        attribute :>> resourceConfiguration = "1 barista + 1 espresso machine";
        attribute :>> throughputPerPeriod = "30 drinks";
        attribute :>> periodUnit = "per hour";
        attribute :>> assumptions = "Average 2 minutes per drink including payment";
        attribute :>> bottleneck = "Barista speed";
    }

    // -- Resource constraint ----------------------------------

    part foodHygiene : ResourceConstraint {
        attribute :>> constraintName = "Food hygiene certificate";
        attribute :>> constraintType = "regulatory";
        attribute :>> affectedResource = "Barista";
        attribute :>> limit = "All food handlers must hold Level 2 Food Hygiene certificate";
        attribute :>> regulatorySourceDescription = "Environmental Health / Food Standards Agency";
    }

    // -- Revenue stream ---------------------------------------

    part drinkSales : RevenueStream {
        attribute :>> streamName = "Drink sales";
        attribute :>> sourceSegment = "Walk-in customers";
        attribute :>> triggerEvent = "Drink served and paid for";
        attribute :>> pricingModelRef = "perDrinkPricing";
        attribute :>> projectedVolume = "150 drinks per day";
    }

    // -- Cost drivers -----------------------------------------

    part baristaCost : CostDriver {
        attribute :>> driverName = "Barista labour";
        attribute :>> linkedResource = "Barista";
        attribute :>> costBehaviour = "semi-variable — shifts scheduled to demand";
        attribute :>> estimatedUnitCost = 12.0;    // £ per hour
        attribute :>> scalingFactor = "per hour";
    }

    part ingredientCost : CostDriver {
        attribute :>> driverName = "Ingredient cost per drink";
        attribute :>> linkedResource = "Ingredient stock";
        attribute :>> costBehaviour = "variable";
        attribute :>> estimatedUnitCost = 0.80;
        attribute :>> scalingFactor = "per drink";
    }

    part rentCost : CostDriver {
        attribute :>> driverName = "Premises rent";
        attribute :>> linkedResource = "Counter service space";
        attribute :>> costBehaviour = "fixed";
        attribute :>> estimatedUnitCost = 2000.0;
        attribute :>> scalingFactor = "per month";
    }

    // -- Unit economics ---------------------------------------

    part drinkUnitEconomics : UnitEconomics {
        doc /* Per-drink economics. Revenue £3.50, cost £1.90
             * (ingredients £0.80 + labour £0.80 + overhead £0.30),
             * margin £1.60. Hand-verifiable. */
        attribute :>> offeringRef = "Drink order";
        attribute :>> revenuePerUnit = 3.50;
        attribute :>> costPerUnit = 1.90;
        attribute :>> marginPerUnit = 1.60;
        attribute :>> breakdownNotes = "Ingredients £0.80, labour £0.80 (2min at £12/hr), overhead allocation £0.30";
    }

    // -- Pricing model ----------------------------------------

    part perDrinkPricing : PricingModel {
        attribute :>> pricingModelName = "Per-drink pricing";
        attribute :>> pricingType = PricingType::perEpisode;
        attribute :>> basePrice = 3.50;
        attribute :>> adjustmentLogic = "Fixed price per drink. Varies by drink type in practice.";
        attribute :>> applicableOfferings = "Drink order";
    }
}
