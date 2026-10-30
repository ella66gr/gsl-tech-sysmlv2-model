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
    private import BusinessScenarios::ScenarioDefinition;

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
