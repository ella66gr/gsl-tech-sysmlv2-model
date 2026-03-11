// =========================================================================
// COFFEE SHOP SCENARIOS — ScenarioModelling and StrategyAndEvolution
// demonstrator extension
// =========================================================================
//
// Validates: cross-project import of ScenarioModelling and
// StrategyAndEvolution sub-packages, GrowthShape enum :>> from
// exercises directory, ScenarioDefinition structure for a toy domain.
//
// Two scenarios: Small Kiosk vs Full Café.

package CoffeeshopScenarios {
    private import ScalarValues::*;
    private import BusinessModel::ScenarioModelling::*;
    private import BusinessModel::StrategyAndEvolution::*;

    doc /* Coffee shop scenario modelling extension. Two scenarios
         * for the same coffee shop business, demonstrating that the
         * ScenarioModelling and StrategyAndEvolution structures
         * accommodate a simple service business.
         *
         * Phase 3 demonstrator — validates BusinessModel sub-package
         * import and instantiation from exercises directory. */

    // =================================================================
    // SCENARIO DEFINITIONS
    // =================================================================

    part smallKioskScenario : ScenarioDefinition {
        doc /* A small takeaway kiosk: 1 barista, limited menu,
             * low rent, targeting 50 drinks/day growing to 80. */
        attribute :>> scenarioName = "Small Kiosk";
        attribute :>> description = "1 barista, takeaway only, limited menu, low-rent location";
        attribute :>> activeOfferings = "Hot drinks, Cold drinks";
        attribute :>> variantLabel = "K";
        attribute :>> timelineMonths = 12;
        attribute :>> notes = "Illustrative figures for architectural validation";
    }

    part fullCafeScenario : ScenarioDefinition {
        doc /* A full high-street café: 3 baristas, food menu,
             * seating, higher rent, targeting 200 drinks/day. */
        attribute :>> scenarioName = "Full Cafe";
        attribute :>> description = "3 baristas, dine-in seating, full food and drink menu, high street";
        attribute :>> activeOfferings = "Hot drinks, Cold drinks, Food, Pastries";
        attribute :>> variantLabel = "C";
        attribute :>> timelineMonths = 12;
        attribute :>> notes = "Illustrative figures for architectural validation";
    }

    // =================================================================
    // PROJECTION PARAMETERS — Small Kiosk
    // =================================================================

    part kioskDailyDrinks : ProjectionParameter {
        attribute :>> parameterName = "dailyDrinks";
        attribute :>> parameterValue = 50.0;
        attribute :>> unit = "drinks/day";
        attribute :>> sourceRef = "GrowthAssumption";
        attribute :>> temporalVariation = "Starts at 50, grows to 80 over 12 months";
        attribute :>> notes = "";
    }

    part kioskPricePerDrink : ProjectionParameter {
        attribute :>> parameterName = "averagePricePerDrink";
        attribute :>> parameterValue = 3.50;
        attribute :>> unit = "£";
        attribute :>> sourceRef = "";
        attribute :>> temporalVariation = "";
        attribute :>> notes = "";
    }

    part kioskBaristaCost : ProjectionParameter {
        attribute :>> parameterName = "baristaMonthlyCost";
        attribute :>> parameterValue = 2080.0;
        attribute :>> unit = "£/month";
        attribute :>> sourceRef = "";
        attribute :>> temporalVariation = "";
        attribute :>> notes = "1 barista at £12/hr, 40 hrs/week, ~4.3 weeks/month";
    }

    part kioskRent : ProjectionParameter {
        attribute :>> parameterName = "monthlyRent";
        attribute :>> parameterValue = 800.0;
        attribute :>> unit = "£/month";
        attribute :>> sourceRef = "";
        attribute :>> temporalVariation = "";
        attribute :>> notes = "Low-rent kiosk location";
    }

    // =================================================================
    // PROJECTION PARAMETERS — Full Café
    // =================================================================

    part cafeDailyDrinks : ProjectionParameter {
        attribute :>> parameterName = "dailyDrinks";
        attribute :>> parameterValue = 120.0;
        attribute :>> unit = "drinks/day";
        attribute :>> sourceRef = "GrowthAssumption";
        attribute :>> temporalVariation = "Starts at 120, seasonal variation, target 200 by month 12";
        attribute :>> notes = "";
    }

    part cafePricePerDrink : ProjectionParameter {
        attribute :>> parameterName = "averagePricePerDrink";
        attribute :>> parameterValue = 4.20;
        attribute :>> unit = "£";
        attribute :>> sourceRef = "";
        attribute :>> temporalVariation = "";
        attribute :>> notes = "Higher average due to food menu and premium positioning";
    }

    part cafeBaristaCost : ProjectionParameter {
        attribute :>> parameterName = "baristaMonthlyCost";
        attribute :>> parameterValue = 6240.0;
        attribute :>> unit = "£/month";
        attribute :>> sourceRef = "";
        attribute :>> temporalVariation = "";
        attribute :>> notes = "3 baristas at £12/hr";
    }

    part cafeRent : ProjectionParameter {
        attribute :>> parameterName = "monthlyRent";
        attribute :>> parameterValue = 3000.0;
        attribute :>> unit = "£/month";
        attribute :>> sourceRef = "";
        attribute :>> temporalVariation = "";
        attribute :>> notes = "High street location with seating";
    }

    // =================================================================
    // GROWTH ASSUMPTIONS
    // =================================================================

    part kioskGrowth : GrowthAssumption {
        attribute :>> assumptionName = "Kiosk drink volume growth";
        attribute :>> targetVariable = "dailyDrinks";
        attribute :>> growthShape = GrowthShape::linear;
        attribute :>> startValue = 50.0;
        attribute :>> endValue = 80.0;
        attribute :>> inflectionMonth = 0;
        attribute :>> trajectory = "Linear growth from 50 to 80 drinks/day over 12 months";
        attribute :>> notes = "Word of mouth and repeat customers";
    }

    part cafeGrowth : GrowthAssumption {
        attribute :>> assumptionName = "Cafe drink volume growth";
        attribute :>> targetVariable = "dailyDrinks";
        attribute :>> growthShape = GrowthShape::sCurve;
        attribute :>> startValue = 120.0;
        attribute :>> endValue = 200.0;
        attribute :>> inflectionMonth = 6;
        attribute :>> trajectory = "S-curve from 120 to 200 drinks/day, inflection at month 6";
        attribute :>> notes = "Seasonal variation — summer peak, winter dip";
    }

    // =================================================================
    // ILLUSTRATIVE PROJECTION OUTPUTS — Month 6 snapshot
    // =================================================================

    part kioskMonth6 : ProjectionOutput {
        doc /* Kiosk at month 6: ~65 drinks/day (midpoint of growth).
             * Revenue: 65 * £3.50 * 26 trading days = ~£5,915/mo.
             * Cost: barista £2,080 + rent £800 + ingredients
             * (~£0.80/drink = £1,352) + overhead ~£500 = ~£4,732.
             * Margin: ~£1,183/month. Profitable from early on. */
        attribute :>> periodLabel = "Month 6";
        attribute :>> revenue = 5915.0;
        attribute :>> cost = 4732.0;
        attribute :>> margin = 1183.0;
        attribute :>> cumulativeCashFlow = 4200.0;
        attribute :>> activePatientsTotal = 0;     // not applicable — using drinks/day
        attribute :>> clinicianUtilisation = 0.0;  // not applicable
        attribute :>> confidenceProfile = "moderate — seasonal variation not modelled";
    }

    part cafeMonth6 : ProjectionOutput {
        doc /* Cafe at month 6: ~160 drinks/day (inflection point).
             * Revenue: 160 * £4.20 * 26 = ~£17,472/mo.
             * Cost: baristas £6,240 + rent £3,000 + ingredients
             * (~£1.00/drink = £4,160) + overhead ~£2,000 = ~£15,400.
             * Margin: ~£2,072/month. Higher absolute margin but
             * higher capital requirement to reach this point. */
        attribute :>> periodLabel = "Month 6";
        attribute :>> revenue = 17472.0;
        attribute :>> cost = 15400.0;
        attribute :>> margin = 2072.0;
        attribute :>> cumulativeCashFlow = -8500.0;
        attribute :>> activePatientsTotal = 0;
        attribute :>> clinicianUtilisation = 0.0;
        attribute :>> confidenceProfile = "moderate — food revenue and seasonal variation not modelled";
    }

    // =================================================================
    // BUSINESS MODEL VARIANTS
    // =================================================================

    part variantKiosk : BusinessModelVariant {
        attribute :>> variantName = "Small Kiosk";
        attribute :>> variantLabel = "K";
        attribute :>> description = "Low investment, quick profitability, limited growth ceiling";
        attribute :>> activeOfferings = "Hot drinks, Cold drinks";
        attribute :>> keyDifferentiator = "Low capital, fast profitability, capped at ~80 drinks/day";
        attribute :>> investmentLevel = "~£5K";
        attribute :>> riskProfile = "Low risk — low overheads, but revenue ceiling limits growth";
        attribute :>> scenarioRef = "Small Kiosk";
    }

    part variantCafe : BusinessModelVariant {
        attribute :>> variantName = "Full Cafe";
        attribute :>> variantLabel = "C";
        attribute :>> description = "Higher investment, broader offering, higher revenue ceiling";
        attribute :>> activeOfferings = "Hot drinks, Cold drinks, Food, Pastries";
        attribute :>> keyDifferentiator = "Full experience, food revenue, higher margin per customer";
        attribute :>> investmentLevel = "~£40K";
        attribute :>> riskProfile = "Higher capital at risk; rent commitment; staffing complexity";
        attribute :>> scenarioRef = "Full Cafe";
    }

    // =================================================================
    // PIVOT SCENARIO
    // =================================================================

    part pivotKioskToCafe : PivotScenario {
        attribute :>> pivotName = "Kiosk to Full Cafe expansion";
        attribute :>> fromVariant = "Small Kiosk (K)";
        attribute :>> toVariant = "Full Cafe (C)";
        attribute :>> triggerCondition = "Kiosk reaches 90% capacity (72+ drinks/day sustained for 2 months)";
        attribute :>> transitionPlan = "Secure high street premises, hire 2 additional baristas, add food menu, fit out seating area";
        attribute :>> estimatedTransitionMonths = 3;
        attribute :>> riskNotes = "Requires £35K capital for fit-out and 3-month cash buffer during transition";
    }
}
