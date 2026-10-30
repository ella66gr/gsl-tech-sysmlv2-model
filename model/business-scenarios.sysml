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
    private import Foundation::CommonTypes::*;
    private import BusinessModel::ServiceConcept::ServiceOffering;

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
