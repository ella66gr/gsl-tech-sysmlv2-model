// =========================================================================
// COFFEE SHOP SCENARIOS — ScenarioModelling and StrategyAndEvolution
// demonstrator extension
// =========================================================================
//
// Validates: cross-project import of BusinessScenarios and
// BusinessStrategy packages, GrowthShape enum :>> from
// exercises directory, ScenarioDefinition structure for a toy domain.
//
// Two scenarios: Small Kiosk vs Full Café, plus subscription variant.
//
// Phase 6A: imports updated for promoted packages.
// Phase 6A Stage 3: PeriodActuals and VarianceAnalysis demonstrator.
// Phase 6B Stage 4: VarianceSource enum typing, GoalProjection and
// Deficit instantiations from Knowledge::LogicEngine.

package CoffeeshopScenarios {
    private import ScalarValues::*;
    private import BusinessScenarios::*;
    private import BusinessStrategy::*;
    private import Knowledge::LogicEngine::*;
    private import Foundation::CommonTypes::*;

    doc /* Coffee shop scenario modelling extension. Two scenarios
         * for the same coffee shop business, demonstrating that the
         * ScenarioModelling and StrategyAndEvolution structures
         * accommodate a simple service business.
         *
         * Phase 3 demonstrator — validates BusinessScenarios and
         * BusinessStrategy import and instantiation from exercises
         * directory.
         *
         * Phase 5 demonstrator — subscription scenario validates
         * the subscription revenue formula pattern.
         *
         * Phase 6A — PeriodActuals and VarianceAnalysis validate
         * the operational steering part defs.
         *
         * Phase 6B — VarianceSource enum typing, GoalProjection
         * and Deficit from Knowledge::LogicEngine validate the
         * steering cycle wiring for a non-clinical domain. */

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
        attribute :>> periodLabel = "Month 6";
        attribute :>> revenue = 5915.0;
        attribute :>> cost = 4732.0;
        attribute :>> margin = 1183.0;
        attribute :>> cumulativeCashFlow = 4200.0;
        attribute :>> activePatientsTotal = 0;
        attribute :>> clinicianUtilisation = 0.0;
        attribute :>> confidenceProfile = "moderate — seasonal variation not modelled";
    }

    part cafeMonth6 : ProjectionOutput {
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
    // SUBSCRIPTION SCENARIO — Phase 5 demonstrator parity
    // =================================================================

    part cafeSubscriptionScenario : ScenarioDefinition {
        attribute :>> scenarioName = "Cafe with Subscription";
        attribute :>> description = "Full cafe plus monthly coffee subscription for regular customers";
        attribute :>> activeOfferings = "Hot drinks, Cold drinks, Food, Pastries, Monthly Subscription";
        attribute :>> variantLabel = "S";
        attribute :>> timelineMonths = 12;
        attribute :>> notes = "Phase 5 demonstrator parity — validates subscription revenue formula pattern";
    }

    part subMonthlyFee : ProjectionParameter {
        attribute :>> parameterName = "subscriptionFeePerMonth";
        attribute :>> parameterValue = 25.0;
        attribute :>> unit = "£/month";
        attribute :>> sourceRef = "";
        attribute :>> temporalVariation = "";
        attribute :>> notes = "£25/month for 1 free drink/day. Placeholder.";
    }

    part subMemberCount : ProjectionParameter {
        attribute :>> parameterName = "subscriptionMembers";
        attribute :>> parameterValue = 0.0;
        attribute :>> unit = "members";
        attribute :>> sourceRef = "GrowthAssumption";
        attribute :>> temporalVariation = "Grows from 0 to 40 over 12 months";
        attribute :>> notes = "Members also contribute to daily drink volume";
    }

    part subMemberGrowth : GrowthAssumption {
        attribute :>> assumptionName = "Subscription membership growth";
        attribute :>> targetVariable = "subscriptionMembers";
        attribute :>> growthShape = GrowthShape::linear;
        attribute :>> startValue = 0.0;
        attribute :>> endValue = 40.0;
        attribute :>> inflectionMonth = 0;
        attribute :>> trajectory = "Linear growth from 0 to 40 members over 12 months";
        attribute :>> notes = "Regulars converting to subscription as awareness grows";
    }

    part formulaCafeSubscriptionRevenue : ProjectionFormula {
        attribute :>> formulaName = "Monthly subscription revenue";
        attribute :>> inputs = "subscriptionMembers, subscriptionFeePerMonth";
        attribute :>> expression = "subscriptionMembers * subscriptionFeePerMonth";
        attribute :>> outputVariable = "monthlySubscriptionRevenue";
        attribute :>> outputUnit = "£/month";
        attribute :>> notes = "Additive to drink revenue. Mirrors GSL formulaSubscriptionRevenue.";
    }

    part formulaCafeSubscriptionTotalRevenue : ProjectionFormula {
        attribute :>> formulaName = "Total monthly revenue (with subscription)";
        attribute :>> inputs = "monthlyDrinkRevenue, monthlySubscriptionRevenue";
        attribute :>> expression = "monthlyDrinkRevenue + monthlySubscriptionRevenue";
        attribute :>> outputVariable = "totalMonthlyRevenue";
        attribute :>> outputUnit = "£/month";
        attribute :>> notes = "Extends per-drink formula with subscription term";
    }

    part cafeSubMonth6 : ProjectionOutput {
        attribute :>> periodLabel = "Month 6";
        attribute :>> revenue = 17972.0;
        attribute :>> cost = 15500.0;
        attribute :>> margin = 2472.0;
        attribute :>> cumulativeCashFlow = -7000.0;
        attribute :>> activePatientsTotal = 0;
        attribute :>> clinicianUtilisation = 0.0;
        attribute :>> confidenceProfile = "moderate — subscription uptake assumption unvalidated";
    }

    part variantCafeSubscription : BusinessModelVariant {
        attribute :>> variantName = "Cafe with Subscription";
        attribute :>> variantLabel = "S";
        attribute :>> description = "Full cafe plus monthly coffee subscription for regulars";
        attribute :>> activeOfferings = "Hot drinks, Cold drinks, Food, Pastries, Monthly Subscription";
        attribute :>> keyDifferentiator = "Subscription revenue diversification, customer loyalty";
        attribute :>> investmentLevel = "~£42K";
        attribute :>> riskProfile = "Same as Full Cafe plus subscription churn risk";
        attribute :>> scenarioRef = "Cafe with Subscription";
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

    // =================================================================
    // OPERATIONAL STEERING — Phase 6A + 6B demonstrator
    // =================================================================

    part kioskWeek1Actuals : PeriodActuals {
        doc /* Small Kiosk, week 1 actuals. 240 drinks sold against
             * a projected 250. */
        attribute :>> periodLabel = "Week 1";
        attribute :>> actualRevenue = 840.0;
        attribute :>> actualCost = 610.0;
        attribute :>> actualMargin = 230.0;
        attribute :>> actualPatientCount = 0;      // not applicable — domain mismatch, deferred
        attribute :>> recordedDate = "2026-03-17";
        attribute :>> notes = "240 drinks sold (projected 250). Rain on Wednesday reduced footfall.";
    }

    part kioskWeek1Variance : VarianceAnalysis {
        doc /* Variance analysis for kiosk week 1. Primary cause
             * is volume variance (fewer drinks sold).
             *
             * Phase 6B: varianceSource now typed as VarianceSource
             * enum (was String in Phase 6A). */
        attribute :>> periodLabel = "Week 1";
        attribute :>> revenueVariance = -35.0;
        attribute :>> costVariance = -10.0;
        attribute :>> marginVariance = -45.0;
        attribute :>> varianceSource = VarianceSource::volume;
        attribute :>> decomposition = "Revenue: volume variance -£35 (240 vs 250 drinks at £3.50). Price variance £0. Cost: ingredient waste +£10 unfavourable (new barista over-preparing milk).";
        attribute :>> rebaselineRecommended = "No — single week, within normal variation. Weather-driven, not structural.";
        attribute :>> notes = "First week of trading. Variance is small and explainable.";
    }

    // =================================================================
    // STEERING CYCLE WIRING — Phase 6B demonstrator
    // =================================================================
    //
    // GoalProjection and Deficit from Knowledge::LogicEngine validate
    // the steering cycle pattern for a non-clinical domain.

    part kioskGoalWeek1Revenue : GoalProjection {
        doc /* Financial goal: kiosk week 1 revenue should be £875
             * (250 drinks × £3.50). GoalProjection from LogicEngine
             * handles this without modification — same structure
             * as a clinical goal. */
        attribute :>> goalName = "Week 1 kiosk revenue target";
        attribute :>> goalSource = "CoffeeshopScenarios::smallKioskScenario";
        attribute :>> expectedCondition = "weeklyRevenue >= 875.0";
        attribute :>> evaluationQuery = "Till reconciliation: total revenue for week 1";
        attribute :>> scope = AssessmentScope::system;
    }

    part kioskDeficitWeek1Revenue : Deficit {
        doc /* Illustrative financial deficit: week 1 revenue is
             * £840 vs expected £875. Volume variance from weather.
             *
             * Validates that Deficit (from LogicEngine) handles
             * a coffee shop financial shortfall identically to a
             * clinical governance gap. Same part def, different
             * domain. */
        attribute :>> deficitDomain = DeficitDomain::financial;
        attribute :>> scope = AssessmentScope::system;
        attribute :>> description = "Week 1 revenue shortfall. Volume variance: 240 drinks vs projected 250 (rain on Wednesday).";
        attribute :>> goalReference = "CoffeeshopScenarios::smallKioskScenario";
        attribute :>> actualState = "£840";
        attribute :>> expectedState = "£875";
        attribute :>> severity = Severity::informational;
        attribute :>> detectedAt = "2026-03-17T18:00:00Z";
        attribute :>> remediationCategory = RemediationCategory::advisory;
        attribute :>> remediationDescription = "No action needed — weather-driven, not structural. Monitor next week for pattern.";
    }
}
