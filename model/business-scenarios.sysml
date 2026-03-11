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
// =========================================================================

package BusinessScenarios {
    private import ScalarValues::*;
    private import Knowledge::LogicEngine::*;
    private import Foundation::CommonTypes::*;

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
         * 3.7, 3.8, and 4.7 */

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
        attribute scenarioName : String;
        attribute description : String;
        attribute activeOfferings : String;
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

    // -- GSL Lean Clinical scenario instantiation ----------

    part leanClinicalScenario : ScenarioDefinition {
        attribute :>> scenarioName = "Lean Clinical (Variant A)";
        attribute :>> description = "Assessment and hormone therapy only. 1 clinician, per-episode pricing.";
        attribute :>> activeOfferings = "Initial Assessment, Hormone Therapy Initiation, Ongoing Monitoring";
        attribute :>> variantLabel = "A";
        attribute :>> timelineMonths = 24;
        attribute :>> notes = "Figures are illustrative best-estimates per meta-modelling section 7.2";
    }

    // Projection parameters — revenue

    part paramAssessmentFee : ProjectionParameter {
        attribute :>> parameterName = "assessmentFeePerPatient";
        attribute :>> parameterValue = 600.0;
        attribute :>> unit = "£";
        attribute :>> sourceRef = "FinancialPlanning::perEpisodePricing";
        attribute :>> temporalVariation = "";
        attribute :>> notes = "Fixed fee per initial assessment episode";
    }

    part paramMonitoringFee : ProjectionParameter {
        attribute :>> parameterName = "monitoringFeePerQuarter";
        attribute :>> parameterValue = 150.0;
        attribute :>> unit = "£";
        attribute :>> sourceRef = "FinancialPlanning::perEpisodePricing";
        attribute :>> temporalVariation = "";
        attribute :>> notes = "Fixed fee per quarterly monitoring review";
    }

    // Projection parameters — resource cost

    part paramClinicianFTEEarly : ProjectionParameter {
        attribute :>> parameterName = "clinicianFTEMonths1to9";
        attribute :>> parameterValue = 0.5;
        attribute :>> unit = "FTE";
        attribute :>> sourceRef = "ResourcePlanning::clinicianMonth1to9";
        attribute :>> temporalVariation = "Months 1-9 only. Steps to 0.8 FTE at month 10.";
        attribute :>> notes = "3 clinical days per fortnight";
    }

    part paramClinicianFTELater : ProjectionParameter {
        attribute :>> parameterName = "clinicianFTEMonths10to24";
        attribute :>> parameterValue = 0.8;
        attribute :>> unit = "FTE";
        attribute :>> sourceRef = "ResourcePlanning::clinicianMonth10to24";
        attribute :>> temporalVariation = "From month 10 onwards";
        attribute :>> notes = "4 clinical days per week";
    }

    part paramClinicianCost : ProjectionParameter {
        attribute :>> parameterName = "clinicianCostPerFTEPerMonth";
        attribute :>> parameterValue = 5000.0;
        attribute :>> unit = "£/FTE/month";
        attribute :>> sourceRef = "FinancialPlanning::clinicianCost";
        attribute :>> temporalVariation = "";
        attribute :>> notes = "Actual monthly cost = FTE x this rate";
    }

    part paramAdminFTE : ProjectionParameter {
        attribute :>> parameterName = "adminFTE";
        attribute :>> parameterValue = 0.3;
        attribute :>> unit = "FTE";
        attribute :>> sourceRef = "ResourcePlanning::adminInstance";
        attribute :>> temporalVariation = "";
        attribute :>> notes = "1.5 days per week throughout";
    }

    part paramAdminCost : ProjectionParameter {
        attribute :>> parameterName = "adminCostPerFTEPerMonth";
        attribute :>> parameterValue = 1800.0;
        attribute :>> unit = "£/FTE/month";
        attribute :>> sourceRef = "FinancialPlanning::adminCost";
        attribute :>> temporalVariation = "";
        attribute :>> notes = "";
    }

    part paramPlatformCost : ProjectionParameter {
        attribute :>> parameterName = "platformCostPerMonth";
        attribute :>> parameterValue = 200.0;
        attribute :>> unit = "£/month";
        attribute :>> sourceRef = "FinancialPlanning::platformCost";
        attribute :>> temporalVariation = "";
        attribute :>> notes = "Fixed hosting and infrastructure";
    }

    part paramInsuranceCost : ProjectionParameter {
        attribute :>> parameterName = "insurancePerMonth";
        attribute :>> parameterValue = 250.0;
        attribute :>> unit = "£/month";
        attribute :>> sourceRef = "FinancialPlanning::insuranceCost";
        attribute :>> temporalVariation = "";
        attribute :>> notes = "Professional indemnity";
    }

    part paramLabCost : ProjectionParameter {
        attribute :>> parameterName = "labCostPerBloodPanel";
        attribute :>> parameterValue = 45.0;
        attribute :>> unit = "£/panel";
        attribute :>> sourceRef = "FinancialPlanning::labCost";
        attribute :>> temporalVariation = "";
        attribute :>> notes = "";
    }

    // Projection parameters — clinical pathway derived

    part paramBloodPanelsInitiation : ProjectionParameter {
        attribute :>> parameterName = "bloodPanelsPerInitiationEpisode";
        attribute :>> parameterValue = 5.0;
        attribute :>> unit = "panels";
        attribute :>> sourceRef = "ServiceDelivery::ClinicalPathways::HormoneTherapy";
        attribute :>> temporalVariation = "";
        attribute :>> notes = "Baseline + 4 monitoring panels during titration";
    }

    part paramBloodPanelsMonitoring : ProjectionParameter {
        attribute :>> parameterName = "bloodPanelsPerMonitoringQuarter";
        attribute :>> parameterValue = 1.0;
        attribute :>> unit = "panels";
        attribute :>> sourceRef = "ServiceDelivery::ClinicalPathways::HormoneTherapy";
        attribute :>> temporalVariation = "";
        attribute :>> notes = "1 panel per quarterly review once stable";
    }

    part paramOverheadPercentage : ProjectionParameter {
        attribute :>> parameterName = "overheadPercentage";
        attribute :>> parameterValue = 25.0;
        attribute :>> unit = "%";
        attribute :>> sourceRef = "FinancialPlanning::overheadCost";
        attribute :>> temporalVariation = "";
        attribute :>> notes = "Envelope-level overhead as percentage of direct cost";
    }

    // Projection parameters — growth

    part paramNewPatientsYear1 : ProjectionParameter {
        attribute :>> parameterName = "newPatientsPerMonthYear1";
        attribute :>> parameterValue = 4.0;
        attribute :>> unit = "patients/month";
        attribute :>> sourceRef = "GrowthAssumption";
        attribute :>> temporalVariation = "Months 1-12";
        attribute :>> notes = "Linear acquisition assumption";
    }

    part paramNewPatientsYear2 : ProjectionParameter {
        attribute :>> parameterName = "newPatientsPerMonthYear2";
        attribute :>> parameterValue = 6.0;
        attribute :>> unit = "patients/month";
        attribute :>> sourceRef = "GrowthAssumption";
        attribute :>> temporalVariation = "Months 13-24";
        attribute :>> notes = "Increased acquisition via GP network and reputation";
    }

    // Projection parameters — conversion and retention

    part paramAssessmentConversion : ProjectionParameter {
        attribute :>> parameterName = "assessmentToInitiationConversion";
        attribute :>> parameterValue = 85.0;
        attribute :>> unit = "%";
        attribute :>> sourceRef = "Clinical estimate";
        attribute :>> temporalVariation = "";
        attribute :>> notes = "85% of assessed patients proceed to hormone therapy";
    }

    part paramInitiationConversion : ProjectionParameter {
        attribute :>> parameterName = "initiationToStableConversion";
        attribute :>> parameterValue = 90.0;
        attribute :>> unit = "%";
        attribute :>> sourceRef = "Clinical estimate";
        attribute :>> temporalVariation = "";
        attribute :>> notes = "90% complete initiation over ~9 months average";
    }

    part paramChurnRate : ProjectionParameter {
        attribute :>> parameterName = "churnRatePerQuarter";
        attribute :>> parameterValue = 5.0;
        attribute :>> unit = "%";
        attribute :>> sourceRef = "Clinical estimate";
        attribute :>> temporalVariation = "";
        attribute :>> notes = "5% of stable patients disengage per quarter";
    }

    // Growth assumptions

    part growthPatientAcquisitionYear1 : GrowthAssumption {
        attribute :>> assumptionName = "Patient acquisition year 1";
        attribute :>> targetVariable = "newPatientsPerMonth";
        attribute :>> growthShape = GrowthShape::linear;
        attribute :>> startValue = 4.0;
        attribute :>> endValue = 4.0;
        attribute :>> inflectionMonth = 0;
        attribute :>> trajectory = "4 new patients per month, constant through year 1";
        attribute :>> notes = "Conservative linear assumption";
    }

    part growthPatientAcquisitionYear2 : GrowthAssumption {
        attribute :>> assumptionName = "Patient acquisition year 2";
        attribute :>> targetVariable = "newPatientsPerMonth";
        attribute :>> growthShape = GrowthShape::stepped;
        attribute :>> startValue = 4.0;
        attribute :>> endValue = 6.0;
        attribute :>> inflectionMonth = 13;
        attribute :>> trajectory = "Steps from 4 to 6 new patients per month at month 13";
        attribute :>> notes = "Driven by GP network expansion and reputation growth";
    }

    part growthClinicianFTE : GrowthAssumption {
        attribute :>> assumptionName = "Clinician FTE step-up";
        attribute :>> targetVariable = "clinicianFTE";
        attribute :>> growthShape = GrowthShape::stepped;
        attribute :>> startValue = 0.5;
        attribute :>> endValue = 0.8;
        attribute :>> inflectionMonth = 10;
        attribute :>> trajectory = "0.5 FTE months 1-9, steps to 0.8 FTE at month 10";
        attribute :>> notes = "Triggered by caseload reaching ~20 active patients";
    }

    part growthConversionRate : GrowthAssumption {
        attribute :>> assumptionName = "Assessment-to-initiation conversion";
        attribute :>> targetVariable = "assessmentToInitiationConversion";
        attribute :>> growthShape = GrowthShape::linear;
        attribute :>> startValue = 85.0;
        attribute :>> endValue = 85.0;
        attribute :>> inflectionMonth = 0;
        attribute :>> trajectory = "Fixed at 85% throughout projection period";
        attribute :>> notes = "Conservative assumption — may improve with reputation";
    }

    part growthChurnRate : GrowthAssumption {
        attribute :>> assumptionName = "Stable patient churn";
        attribute :>> targetVariable = "churnRatePerQuarter";
        attribute :>> growthShape = GrowthShape::linear;
        attribute :>> startValue = 5.0;
        attribute :>> endValue = 5.0;
        attribute :>> inflectionMonth = 0;
        attribute :>> trajectory = "Fixed at 5% per quarter throughout";
        attribute :>> notes = "Represents patients transferring to GP-only care or disengaging";
    }

    // Projection formulas

    part formulaMonthlyAssessmentRevenue : ProjectionFormula {
        attribute :>> formulaName = "Monthly assessment revenue";
        attribute :>> inputs = "newPatientsPerMonth, assessmentFeePerPatient";
        attribute :>> expression = "newPatientsPerMonth * assessmentFeePerPatient / 2";
        attribute :>> outputVariable = "monthlyAssessmentRevenue";
        attribute :>> outputUnit = "£/month";
        attribute :>> notes = "Divided by 2 because assessment spans ~2 months";
    }

    part formulaMonthlyMonitoringRevenue : ProjectionFormula {
        attribute :>> formulaName = "Monthly monitoring revenue";
        attribute :>> inputs = "stablePatients, monitoringFeePerQuarter";
        attribute :>> expression = "stablePatients * monitoringFeePerQuarter / 3";
        attribute :>> outputVariable = "monthlyMonitoringRevenue";
        attribute :>> outputUnit = "£/month";
        attribute :>> notes = "Quarterly fee spread across 3 months";
    }

    part formulaTotalRevenue : ProjectionFormula {
        attribute :>> formulaName = "Total monthly revenue";
        attribute :>> inputs = "monthlyAssessmentRevenue, monthlyMonitoringRevenue";
        attribute :>> expression = "monthlyAssessmentRevenue + monthlyMonitoringRevenue";
        attribute :>> outputVariable = "totalMonthlyRevenue";
        attribute :>> outputUnit = "£/month";
        attribute :>> notes = "";
    }

    part formulaDirectCost : ProjectionFormula {
        attribute :>> formulaName = "Monthly direct cost";
        attribute :>> inputs = "clinicianFTE, clinicianCostPerFTEPerMonth, adminFTE, adminCostPerFTEPerMonth, platformCostPerMonth, insurancePerMonth, bloodPanelsThisMonth, labCostPerBloodPanel";
        attribute :>> expression = "(clinicianFTE * clinicianCostPerFTEPerMonth) + (adminFTE * adminCostPerFTEPerMonth) + platformCostPerMonth + insurancePerMonth + (bloodPanelsThisMonth * labCostPerBloodPanel)";
        attribute :>> outputVariable = "monthlyDirectCost";
        attribute :>> outputUnit = "£/month";
        attribute :>> notes = "bloodPanelsThisMonth derived from initiation and monitoring patient counts";
    }

    part formulaOverhead : ProjectionFormula {
        attribute :>> formulaName = "Monthly overhead";
        attribute :>> inputs = "monthlyDirectCost, overheadPercentage";
        attribute :>> expression = "monthlyDirectCost * overheadPercentage / 100";
        attribute :>> outputVariable = "monthlyOverhead";
        attribute :>> outputUnit = "£/month";
        attribute :>> notes = "Envelope-level allocation";
    }

    part formulaMargin : ProjectionFormula {
        attribute :>> formulaName = "Monthly margin";
        attribute :>> inputs = "totalMonthlyRevenue, monthlyDirectCost, monthlyOverhead";
        attribute :>> expression = "totalMonthlyRevenue - monthlyDirectCost - monthlyOverhead";
        attribute :>> outputVariable = "monthlyMargin";
        attribute :>> outputUnit = "£/month";
        attribute :>> notes = "";
    }

    part formulaCumulativeCash : ProjectionFormula {
        attribute :>> formulaName = "Cumulative cash flow";
        attribute :>> inputs = "previousCumulativeCashFlow, monthlyMargin";
        attribute :>> expression = "previousCumulativeCashFlow + monthlyMargin";
        attribute :>> outputVariable = "cumulativeCashFlow";
        attribute :>> outputUnit = "£";
        attribute :>> notes = "Running total from month 1";
    }

    part formulaUtilisation : ProjectionFormula {
        attribute :>> formulaName = "Clinician utilisation";
        attribute :>> inputs = "clinicianActivityHours, clinicianFTE, availableHoursPerMonth";
        attribute :>> expression = "clinicianActivityHours / (clinicianFTE * availableHoursPerMonth) * 100";
        attribute :>> outputVariable = "clinicianUtilisation";
        attribute :>> outputUnit = "%";
        attribute :>> notes = "availableHoursPerMonth estimated at 140 (35 hrs/wk * 4 wks)";
    }

    // Projection timeline

    part leanClinicalTimeline : ProjectionTimeline {
        attribute :>> timelineName = "24-month monthly projection";
        attribute :>> periodMonths = 24;
        attribute :>> intervalUnit = "monthly";
        attribute :>> startCondition = "Service launch (month 1 = first patient assessed)";
    }

    // Sensitivity parameters

    part sensitivityPatientGrowth : SensitivityParameter {
        attribute :>> parameterRef = "newPatientsPerMonthYear1";
        attribute :>> baseValue = 4.0;
        attribute :>> pessimisticValue = 2.0;
        attribute :>> optimisticValue = 6.0;
        attribute :>> impactDescription = "Break-even shifts by approximately 6 months in each direction";
    }

    part sensitivityAssessmentFee : SensitivityParameter {
        attribute :>> parameterRef = "assessmentFeePerPatient";
        attribute :>> baseValue = 600.0;
        attribute :>> pessimisticValue = 450.0;
        attribute :>> optimisticValue = 750.0;
        attribute :>> impactDescription = "Break-even shifts by approximately 3 months in each direction";
    }

    part sensitivityClinicianCost : SensitivityParameter {
        attribute :>> parameterRef = "clinicianCostPerFTEPerMonth";
        attribute :>> baseValue = 5000.0;
        attribute :>> pessimisticValue = 6000.0;
        attribute :>> optimisticValue = 4000.0;
        attribute :>> impactDescription = "Break-even shifts by approximately 2 months in each direction";
    }

    part sensitivityOverhead : SensitivityParameter {
        attribute :>> parameterRef = "overheadPercentage";
        attribute :>> baseValue = 25.0;
        attribute :>> pessimisticValue = 35.0;
        attribute :>> optimisticValue = 20.0;
        attribute :>> impactDescription = "Break-even shifts by approximately 2 months in each direction";
    }

    // Illustrative projection outputs

    part outputMonth1 : ProjectionOutput {
        attribute :>> periodLabel = "Month 1";
        attribute :>> revenue = 1200.0;
        attribute :>> cost = 4488.0;
        attribute :>> margin = -3288.0;
        attribute :>> cumulativeCashFlow = -3288.0;
        attribute :>> activePatientsTotal = 4;
        attribute :>> clinicianUtilisation = 15.0;
        attribute :>> confidenceProfile = "low — early month, envelope-level overhead estimate";
    }

    part outputMonth6 : ProjectionOutput {
        attribute :>> periodLabel = "Month 6";
        attribute :>> revenue = 2550.0;
        attribute :>> cost = 4750.0;
        attribute :>> margin = -2200.0;
        attribute :>> cumulativeCashFlow = -15500.0;
        attribute :>> activePatientsTotal = 20;
        attribute :>> clinicianUtilisation = 35.0;
        attribute :>> confidenceProfile = "moderate — growth assumptions dominate";
    }

    part outputMonth12 : ProjectionOutput {
        attribute :>> periodLabel = "Month 12";
        attribute :>> revenue = 4800.0;
        attribute :>> cost = 5050.0;
        attribute :>> margin = -250.0;
        attribute :>> cumulativeCashFlow = -18500.0;
        attribute :>> activePatientsTotal = 38;
        attribute :>> clinicianUtilisation = 55.0;
        attribute :>> confidenceProfile = "moderate — conversion and churn assumptions becoming significant";
    }

    part outputMonth18 : ProjectionOutput {
        attribute :>> periodLabel = "Month 18";
        attribute :>> revenue = 7500.0;
        attribute :>> cost = 6250.0;
        attribute :>> margin = 1250.0;
        attribute :>> cumulativeCashFlow = -12500.0;
        attribute :>> activePatientsTotal = 52;
        attribute :>> clinicianUtilisation = 72.0;
        attribute :>> confidenceProfile = "moderate — churn rate now material to projections";
    }

    part outputMonth24 : ProjectionOutput {
        attribute :>> periodLabel = "Month 24";
        attribute :>> revenue = 10500.0;
        attribute :>> cost = 6650.0;
        attribute :>> margin = 3850.0;
        attribute :>> cumulativeCashFlow = -1200.0;
        attribute :>> activePatientsTotal = 65;
        attribute :>> clinicianUtilisation = 85.0;
        attribute :>> confidenceProfile = "moderate — long-term churn assumption least validated";
    }

    // Initial forecast baseline

    part leanClinicalBaselineV1 : ForecastBaseline {
        attribute :>> baselineName = "Lean Clinical launch baseline";
        attribute :>> baselineVersion = 1;
        attribute :>> scenarioRef = "Lean Clinical (Variant A)";
        attribute :>> effectiveDate = "Pre-launch";
        attribute :>> parameterSnapshot = "All parameters at section 7.2 base values. 4 patients/month year 1, 6 patients/month year 2, 0.5 FTE months 1-9, 0.8 FTE months 10-24, 25% overhead.";
        attribute :>> notes = "Re-baseline when 6+ months of actuals indicate material deviation from assumptions";
    }

    // =================================================================
    // GSL Full Platform scenario instantiation (Variant B)
    // =================================================================
    //
    // Phase 5, Stage 3. Full parameterisation of the Full Platform
    // variant. Shares clinical parameters with Variant A (same
    // assessment fee, monitoring fee, conversion rates, churn).
    // Adds subscription revenue, coach/moderator costs, higher
    // platform cost, and a two-clinician FTE schedule.
    //
    // All values are illustrative placeholders per Phase 5
    // guardrail G1 — set once, not tuned.
    //
    // Key structural finding: subscription revenue requires a
    // new ProjectionFormula (formulaSubscriptionRevenue) because
    // it introduces an additive revenue stream with its own
    // volume driver (activeSubscribers). The existing Variant A
    // formulas handle the clinical revenue component unchanged.

    part fullPlatformScenario : ScenarioDefinition {
        attribute :>> scenarioName = "Full Platform (Variant B)";
        attribute :>> description = "Clinical care plus coaching, education, and community. 2 clinicians, subscription pricing alongside per-episode clinical fees.";
        attribute :>> activeOfferings = "Initial Assessment, Hormone Therapy Initiation, Ongoing Monitoring, Coaching, Education, Community";
        attribute :>> variantLabel = "B";
        attribute :>> timelineMonths = 24;
        attribute :>> notes = "All values are illustrative placeholders. Subscription revenue is additive to clinical episode revenue.";
    }

    // Variant B projection parameters — subscription revenue

    part fpParamSubscriptionFee : ProjectionParameter {
        attribute :>> parameterName = "subscriptionFeePerMonth";
        attribute :>> parameterValue = 99.0;
        attribute :>> unit = "£/month";
        attribute :>> sourceRef = "FinancialPlanning::subscriptionPricing";
        attribute :>> temporalVariation = "";
        attribute :>> notes = "Flat monthly fee for coaching, education, community access. Placeholder.";
    }

    part fpParamSubscriptionUptake : ProjectionParameter {
        doc /* Simplifying assumption: all active patients in the
             * Full Platform variant are subscribers. This is the
             * simplest model and can be relaxed in future if a
             * clinical-only tier is introduced. */
        attribute :>> parameterName = "subscriptionUptakeRate";
        attribute :>> parameterValue = 100.0;
        attribute :>> unit = "%";
        attribute :>> sourceRef = "Design assumption";
        attribute :>> temporalVariation = "";
        attribute :>> notes = "100% — all active patients are subscribers. Simplifying assumption documented per Phase 5 plan.";
    }

    // Variant B projection parameters — resource cost (new)

    part fpParamCoachFTE : ProjectionParameter {
        attribute :>> parameterName = "coachFTE";
        attribute :>> parameterValue = 0.5;
        attribute :>> unit = "FTE";
        attribute :>> sourceRef = "ResourcePlanning::coachInstance";
        attribute :>> temporalVariation = "";
        attribute :>> notes = "0.5 FTE throughout. Constant — does not scale within 24-month projection.";
    }

    part fpParamCoachCost : ProjectionParameter {
        attribute :>> parameterName = "coachCostPerFTEPerMonth";
        attribute :>> parameterValue = 3000.0;
        attribute :>> unit = "£/FTE/month";
        attribute :>> sourceRef = "FinancialPlanning::coachCost";
        attribute :>> temporalVariation = "";
        attribute :>> notes = "Placeholder — below clinician rate";
    }

    part fpParamModeratorFTE : ProjectionParameter {
        attribute :>> parameterName = "moderatorFTE";
        attribute :>> parameterValue = 0.2;
        attribute :>> unit = "FTE";
        attribute :>> sourceRef = "ResourcePlanning::moderatorInstance";
        attribute :>> temporalVariation = "";
        attribute :>> notes = "0.2 FTE throughout. 1 day per week.";
    }

    part fpParamModeratorCost : ProjectionParameter {
        attribute :>> parameterName = "moderatorCostPerFTEPerMonth";
        attribute :>> parameterValue = 2000.0;
        attribute :>> unit = "£/FTE/month";
        attribute :>> sourceRef = "FinancialPlanning::moderatorCost";
        attribute :>> temporalVariation = "";
        attribute :>> notes = "Placeholder";
    }

    part fpParamPlatformCost : ProjectionParameter {
        doc /* Higher than Variant A (£200) due to community
             * platform infrastructure. */
        attribute :>> parameterName = "platformCostPerMonth";
        attribute :>> parameterValue = 500.0;
        attribute :>> unit = "£/month";
        attribute :>> sourceRef = "FinancialPlanning::platformCost";
        attribute :>> temporalVariation = "";
        attribute :>> notes = "Higher than Variant A due to community platform hosting";
    }

    // Variant B projection parameters — clinician FTE schedule
    //
    // Two clinicians. Clinician 1: 0.5 FTE months 1-5, 0.8 FTE
    // from month 6. Clinician 2: 0.5 FTE from month 6, 1.0 FTE
    // from month 12. Total FTE: 0.5 → 1.3 → 1.8.

    part fpParamClinician1FTEEarly : ProjectionParameter {
        attribute :>> parameterName = "clinician1FTEMonths1to5";
        attribute :>> parameterValue = 0.5;
        attribute :>> unit = "FTE";
        attribute :>> sourceRef = "ResourcePlanning::clinicianMonth1to9";
        attribute :>> temporalVariation = "Months 1-5. Steps to 0.8 FTE at month 6.";
        attribute :>> notes = "Clinician 1 early phase";
    }

    part fpParamClinician1FTELater : ProjectionParameter {
        attribute :>> parameterName = "clinician1FTEMonths6to24";
        attribute :>> parameterValue = 0.8;
        attribute :>> unit = "FTE";
        attribute :>> sourceRef = "ResourcePlanning::clinicianMonth10to24";
        attribute :>> temporalVariation = "From month 6 onwards";
        attribute :>> notes = "Clinician 1 scales earlier than Variant A";
    }

    part fpParamClinician2FTEEarly : ProjectionParameter {
        attribute :>> parameterName = "clinician2FTEMonths6to11";
        attribute :>> parameterValue = 0.5;
        attribute :>> unit = "FTE";
        attribute :>> sourceRef = "ResourcePlanning::secondClinicianMonth6to24";
        attribute :>> temporalVariation = "Months 6-11. Steps to 1.0 FTE at month 12.";
        attribute :>> notes = "Second clinician initial phase";
    }

    part fpParamClinician2FTELater : ProjectionParameter {
        attribute :>> parameterName = "clinician2FTEMonths12to24";
        attribute :>> parameterValue = 1.0;
        attribute :>> unit = "FTE";
        attribute :>> sourceRef = "ResourcePlanning::secondClinicianMonth6to24";
        attribute :>> temporalVariation = "From month 12 onwards";
        attribute :>> notes = "Second clinician full capacity";
    }

    // Variant B projection parameters — shared with Variant A
    //
    // The following parameters are shared between variants:
    // assessmentFeePerPatient, monitoringFeePerQuarter,
    // effectiveMonthlyRevenuePerPatient, clinicianCostPerFTEPerMonth,
    // adminFTE, adminCostPerFTEPerMonth, insurancePerMonth,
    // labCostPerBloodPanel, bloodPanelsPerInitiationEpisode,
    // bloodPanelsPerMonitoringQuarter, overheadPercentage,
    // newPatientsPerMonthYear1, newPatientsPerMonthYear2,
    // assessmentToInitiationConversion, initiationToStableConversion,
    // churnRatePerQuarter.
    //
    // These are not duplicated — the engine inherits Variant A
    // clinical parameters and overrides only the parameters that
    // differ. This is documented as a structural finding: the
    // existing parameter vocabulary handles both variants.

    // Variant B growth assumptions

    part fpGrowthPatientAcquisition : GrowthAssumption {
        doc /* Same patient acquisition rate as Variant A.
             * Deliberately shared to isolate structural cost/
             * revenue differences between variants. */
        attribute :>> assumptionName = "Patient acquisition (Full Platform)";
        attribute :>> targetVariable = "newPatientsPerMonth";
        attribute :>> growthShape = GrowthShape::stepped;
        attribute :>> startValue = 4.0;
        attribute :>> endValue = 6.0;
        attribute :>> inflectionMonth = 13;
        attribute :>> trajectory = "4 per month year 1, steps to 6 at month 13";
        attribute :>> notes = "Shared with Variant A to isolate cost/revenue differences";
    }

    part fpGrowthClinicianFTE : GrowthAssumption {
        doc /* Two-clinician schedule. Faster scaling than Variant A
             * to support the larger service offering. */
        attribute :>> assumptionName = "Total clinician FTE (Full Platform)";
        attribute :>> targetVariable = "totalClinicianFTE";
        attribute :>> growthShape = GrowthShape::stepped;
        attribute :>> startValue = 0.5;
        attribute :>> endValue = 1.8;
        attribute :>> inflectionMonth = 6;
        attribute :>> trajectory = "0.5 FTE months 1-5, 1.3 FTE months 6-11, 1.8 FTE months 12-24";
        attribute :>> notes = "Clinician 1 (0.5→0.8) + Clinician 2 (0→0.5→1.0)";
    }

    part fpGrowthSubscriptionBase : GrowthAssumption {
        doc /* Subscribers grow with the active patient pool.
             * Simplifying assumption: 100% uptake, so subscriber
             * count equals active patient count. */
        attribute :>> assumptionName = "Subscription base growth";
        attribute :>> targetVariable = "activeSubscribers";
        attribute :>> growthShape = GrowthShape::linear;
        attribute :>> startValue = 0.0;
        attribute :>> endValue = 65.0;
        attribute :>> inflectionMonth = 0;
        attribute :>> trajectory = "Mirrors active patient pool growth (100% uptake assumption)";
        attribute :>> notes = "End value is illustrative — actual depends on cohort dynamics";
    }

    // Variant B projection formula — subscription revenue

    part formulaSubscriptionRevenue : ProjectionFormula {
        doc /* New formula required for Variant B. Subscription
             * revenue has its own volume driver (active
             * subscribers) distinct from assessment volume or
             * monitoring volume. */
        attribute :>> formulaName = "Monthly subscription revenue";
        attribute :>> inputs = "activeSubscribers, subscriptionFeePerMonth";
        attribute :>> expression = "activeSubscribers * subscriptionFeePerMonth";
        attribute :>> outputVariable = "monthlySubscriptionRevenue";
        attribute :>> outputUnit = "£/month";
        attribute :>> notes = "Additive to clinical revenue. activeSubscribers derived from active patient pool x uptake rate.";
    }

    part formulaFullPlatformTotalRevenue : ProjectionFormula {
        doc /* Extended total revenue for Variant B. Composes
             * clinical revenue (shared formula) with subscription
             * revenue (new formula). */
        attribute :>> formulaName = "Total monthly revenue (Full Platform)";
        attribute :>> inputs = "monthlyAssessmentRevenue, monthlyMonitoringRevenue, monthlySubscriptionRevenue";
        attribute :>> expression = "monthlyAssessmentRevenue + monthlyMonitoringRevenue + monthlySubscriptionRevenue";
        attribute :>> outputVariable = "totalMonthlyRevenue";
        attribute :>> outputUnit = "£/month";
        attribute :>> notes = "Extends Variant A formula with subscription term";
    }

    part formulaFullPlatformDirectCost : ProjectionFormula {
        doc /* Extended direct cost for Variant B. Adds coach,
             * moderator, and higher platform cost to Variant A's
             * cost structure. */
        attribute :>> formulaName = "Monthly direct cost (Full Platform)";
        attribute :>> inputs = "totalClinicianFTE, clinicianCostPerFTEPerMonth, adminFTE, adminCostPerFTEPerMonth, coachFTE, coachCostPerFTEPerMonth, moderatorFTE, moderatorCostPerFTEPerMonth, platformCostPerMonth, insurancePerMonth, bloodPanelsThisMonth, labCostPerBloodPanel";
        attribute :>> expression = "(totalClinicianFTE * clinicianCostPerFTEPerMonth) + (adminFTE * adminCostPerFTEPerMonth) + (coachFTE * coachCostPerFTEPerMonth) + (moderatorFTE * moderatorCostPerFTEPerMonth) + platformCostPerMonth + insurancePerMonth + (bloodPanelsThisMonth * labCostPerBloodPanel)";
        attribute :>> outputVariable = "monthlyDirectCost";
        attribute :>> outputUnit = "£/month";
        attribute :>> notes = "Extends Variant A formula with coach, moderator, higher platform cost";
    }

    // Variant B illustrative projection outputs

    part fpOutputMonth1 : ProjectionOutput {
        attribute :>> periodLabel = "Month 1";
        attribute :>> revenue = 1900.0;
        attribute :>> cost = 8000.0;
        attribute :>> margin = -6100.0;
        attribute :>> cumulativeCashFlow = -6100.0;
        attribute :>> activePatientsTotal = 4;
        attribute :>> clinicianUtilisation = 15.0;
        attribute :>> confidenceProfile = "low — early month, high fixed cost base, envelope overhead";
    }

    part fpOutputMonth6 : ProjectionOutput {
        attribute :>> periodLabel = "Month 6";
        attribute :>> revenue = 5400.0;
        attribute :>> cost = 13000.0;
        attribute :>> margin = -7600.0;
        attribute :>> cumulativeCashFlow = -40000.0;
        attribute :>> activePatientsTotal = 20;
        attribute :>> clinicianUtilisation = 25.0;
        attribute :>> confidenceProfile = "moderate — growth assumptions dominate, clinician step-up uncertainty";
    }

    part fpOutputMonth12 : ProjectionOutput {
        attribute :>> periodLabel = "Month 12";
        attribute :>> revenue = 9400.0;
        attribute :>> cost = 16500.0;
        attribute :>> margin = -7100.0;
        attribute :>> cumulativeCashFlow = -80000.0;
        attribute :>> activePatientsTotal = 38;
        attribute :>> clinicianUtilisation = 30.0;
        attribute :>> confidenceProfile = "moderate — subscription uptake assumption becoming significant";
    }

    part fpOutputMonth18 : ProjectionOutput {
        attribute :>> periodLabel = "Month 18";
        attribute :>> revenue = 13500.0;
        attribute :>> cost = 16000.0;
        attribute :>> margin = -2500.0;
        attribute :>> cumulativeCashFlow = -100000.0;
        attribute :>> activePatientsTotal = 52;
        attribute :>> clinicianUtilisation = 40.0;
        attribute :>> confidenceProfile = "moderate — churn rate and subscription retention now material";
    }

    part fpOutputMonth24 : ProjectionOutput {
        attribute :>> periodLabel = "Month 24";
        attribute :>> revenue = 16500.0;
        attribute :>> cost = 16000.0;
        attribute :>> margin = 500.0;
        attribute :>> cumulativeCashFlow = -92000.0;
        attribute :>> activePatientsTotal = 65;
        attribute :>> clinicianUtilisation = 50.0;
        attribute :>> confidenceProfile = "moderate — long-term assumptions dominate, subscription retention least validated";
    }

    // Variant B sensitivity parameters

    part fpSensitivitySubscriptionPrice : SensitivityParameter {
        attribute :>> parameterRef = "subscriptionFeePerMonth";
        attribute :>> baseValue = 99.0;
        attribute :>> pessimisticValue = 59.0;
        attribute :>> optimisticValue = 149.0;
        attribute :>> impactDescription = "Subscription price directly affects revenue diversification benefit. At £59 subscription contributes less than clinical revenue; at £149 it becomes the dominant revenue stream.";
    }

    part fpSensitivitySubscriptionUptake : SensitivityParameter {
        attribute :>> parameterRef = "subscriptionUptakeRate";
        attribute :>> baseValue = 100.0;
        attribute :>> pessimisticValue = 60.0;
        attribute :>> optimisticValue = 100.0;
        attribute :>> impactDescription = "If only 60% of patients subscribe, subscription revenue drops by 40% while coach and moderator costs remain fixed. Tests whether subscription model is viable at partial uptake.";
    }

    // Variant B forecast baseline

    part fullPlatformBaselineV1 : ForecastBaseline {
        attribute :>> baselineName = "Full Platform launch baseline";
        attribute :>> baselineVersion = 1;
        attribute :>> scenarioRef = "Full Platform (Variant B)";
        attribute :>> effectiveDate = "Pre-launch";
        attribute :>> parameterSnapshot = "Shared clinical params with Variant A. Subscription £99/month, 100% uptake. Coach 0.5 FTE, moderator 0.2 FTE. Clinician 1: 0.5→0.8 FTE at month 6. Clinician 2: 0.5→1.0 FTE at months 6→12. Platform £500/month. 25% overhead.";
        attribute :>> notes = "Illustrative placeholders per Phase 5 guardrail G1. All parameter values set once, not tuned.";
    }

    // =================================================================
    // SCENARIO COMPARISON — Variant A vs Variant B
    // =================================================================

    part leanVsFullComparison : ScenarioComparison {
        doc /* Side-by-side comparison of Lean Clinical (Variant A)
             * and Full Platform (Variant B). Produced by the
             * projection engine --compare mode.
             *
             * Key findings (engine-derived, illustrative values):
             * - Variant A: max deficit ~£22K, margin £3.8K/mo at M24
             * - Variant B: max deficit ~£90K, margin £2.4K/mo at M24
             * - Variant B requires ~4.1x the capital of Variant A
             * - Variant B has 3 revenue streams vs 2
             * - Both variants: patient acquisition is the dominant
             *   sensitivity parameter
             * - Variant B clinician utilisation is low (15%) at
             *   current growth — over-resourced for 76 patients
             *   with 1.8 FTE clinicians
             *
             * All values are illustrative placeholders. This
             * comparison tests structural capability, not validated
             * business projections. */
        attribute :>> comparisonName = "Lean Clinical vs Full Platform";
        attribute :>> scenarioRefs = "Lean Clinical (Variant A), Full Platform (Variant B)";
        attribute :>> comparisonDate = "2026-03-11";
        attribute :>> summaryNotes = "Variant B requires ~4.1x capital (£90K vs £22K), has 3 revenue streams vs 2, but lower margin at month 24 (£2.4K vs £3.8K). Subscription contributes ~39% of Variant B revenue by month 24. Both variants sensitive to patient acquisition rate. Variant B over-resourced at projected growth (15% clinician utilisation with 1.8 FTE). Break-even not reached for either variant within 24 months at base assumptions.";
    }

    // =================================================================
    // STEERING CYCLE WIRING — Phase 6B
    // =================================================================
    //
    // Illustrative GoalProjection and Deficit instantiations using
    // part defs from Knowledge::LogicEngine. These demonstrate that
    // the self-knowledge architecture handles financial goals and
    // variances without modification — a financial forecast is a
    // goal, a revenue shortfall is a deficit.
    //
    // This section establishes the structural connection between
    // BusinessScenarios and Knowledge::LogicEngine via cross-package
    // import and part usage. The import at the top of this file
    // (private import Knowledge::LogicEngine::*) is the visible
    // manifestation of this architectural wiring.

    part goalMonth6Revenue : GoalProjection {
        doc /* Financial goal: Lean Clinical month 6 revenue should
             * be at least £2,550 (from the Variant A projection
             * output). This is structurally identical to a clinical
             * goal — "revenue should be £X" is the same pattern as
             * "monitoring bloods should be within 12 weeks."
             *
             * The GoalProjection part def (from LogicEngine) handles
             * this without modification. goalSource references a
             * ProjectionFormula, expectedCondition states the target,
             * evaluationQuery describes how to check actuals. */
        attribute :>> goalName = "Month 6 revenue target (Lean Clinical)";
        attribute :>> goalSource = "BusinessScenarios::formulaTotalRevenue";
        attribute :>> expectedCondition = "totalMonthlyRevenue >= 2550.0";
        attribute :>> evaluationQuery = "Xero management accounts: total revenue for month 6";
        attribute :>> scope = AssessmentScope::system;
    }

    part goalMonth6PatientCount : GoalProjection {
        doc /* Activity goal: Lean Clinical month 6 should have 20
             * active patients (from the projection output). Patient
             * acquisition is the dominant sensitivity parameter —
             * tracking it as an explicit goal makes the most
             * important assumption visible in the assessment. */
        attribute :>> goalName = "Month 6 active patient target (Lean Clinical)";
        attribute :>> goalSource = "BusinessScenarios::leanClinicalScenario";
        attribute :>> expectedCondition = "activePatientsTotal >= 20";
        attribute :>> evaluationQuery = "Temporal workflow query: count of active patient episodes";
        attribute :>> scope = AssessmentScope::system;
    }

    part deficitMonth6Revenue : Deficit {
        doc /* Illustrative financial deficit: month 6 revenue is
             * £2,100 vs expected £2,550. This is structurally
             * identical to a clinical deficit — the Deficit part
             * def handles it without modification.
             *
             * deficitDomain = financial (new enum literal, Phase 6B).
             * goalReference points to the ProjectionFormula.
             * actualState and expectedState carry the figures.
             * description carries the variance decomposition.
             * remediationCategory = recommended (re-examine
             * marketing spend, not an automatic system action).
             *
             * All values are illustrative — this instantiation
             * validates the structural pattern, not real data. */
        attribute :>> deficitDomain = DeficitDomain::financial;
        attribute :>> scope = AssessmentScope::system;
        attribute :>> description = "Month 6 revenue shortfall. Volume variance: 3 new patients vs projected 4 (acquisition below plan). Price variance: £0 (fees unchanged).";
        attribute :>> goalReference = "BusinessScenarios::formulaTotalRevenue";
        attribute :>> actualState = "£2,100";
        attribute :>> expectedState = "£2,550";
        attribute :>> severity = Severity::warning;
        attribute :>> detectedAt = "2026-09-01T00:00:00Z";
        attribute :>> remediationCategory = RemediationCategory::recommended;
        attribute :>> remediationDescription = "Review patient acquisition channels. Consider: increase SEO investment, accelerate GP network outreach, or re-baseline growth assumption from 4/month to 3/month.";
    }
}
