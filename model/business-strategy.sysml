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
// =========================================================================

package BusinessStrategy {
    private import ScalarValues::*;

    doc /* Strategic direction, business model variants, and
         * pivot scenarios. Captures the intentional direction
         * that the other concerns serve: where is this business
         * heading, what alternatives exist, and what would
         * trigger a change of direction?
         *
         * Formerly BusinessModel::StrategyAndEvolution. Promoted
         * to top-level package in Phase 6A for file size management.
         * All content is unchanged; only the package namespace has
         * moved.
         *
         * Connects to Enterprise::Strategy (upgrading the
         * current placeholder) and to BusinessScenarios
         * (each variant has a corresponding ScenarioDefinition
         * with full parameterisation).
         *
         * Variant A and B are fully elaborated with
         * ScenarioDefinitions. Variant C remains a placeholder.
         *
         * Source: gsl-service-business-meta-modelling.md
         * sections 3.5, 7.1 */

    // -- Part definitions ----------------------------------

    part def StrategicObjective {
        doc /* A defined business goal with a timeframe, success
             * criteria, and relationship to capabilities and
             * scenarios. Provides the intentional direction that
             * the other concerns serve.
             *
             * Formal satisfy relationships from objectives to
             * capabilities are deferred to Phase 7. */
        attribute objectiveName : String;
        attribute description : String;
        attribute targetDate : String;          // e.g. "Month 18", "Year 2 Q4"
        attribute successCriteria : String;
        attribute relatedCapabilities : String; // references Capability names
        attribute relatedScenarios : String;    // references ScenarioDefinition names
        attribute status : String;              // planned, in progress, achieved, revised
    }

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

    // -- GSL strategic objectives --------------------------

    part objectivePatientCohort : StrategicObjective {
        attribute :>> objectiveName = "Build active patient cohort";
        attribute :>> description = "Reach 200 active patients across assessment, initiation, and monitoring";
        attribute :>> targetDate = "Month 18";
        attribute :>> successCriteria = "200+ patients in active monitoring or initiation by month 18";
        attribute :>> relatedCapabilities = "Prescribing and monitoring, Clinical assessment, Blood monitoring";
        attribute :>> relatedScenarios = "Lean Clinical (Variant A)";
        attribute :>> status = "planned";
    }

    part objectiveSharedCare : StrategicObjective {
        attribute :>> objectiveName = "Establish shared care network";
        attribute :>> description = "Build shared care agreements with GP practices for ongoing monitoring";
        attribute :>> targetDate = "Month 24";
        attribute :>> successCriteria = "50+ signed shared care protocols with GP practices";
        attribute :>> relatedCapabilities = "Prescribing and monitoring";
        attribute :>> relatedScenarios = "Lean Clinical (Variant A), Full Platform (Variant B)";
        attribute :>> status = "planned";
    }

    part objectiveBreakEven : StrategicObjective {
        attribute :>> objectiveName = "Financial break-even";
        attribute :>> description = "Reach the point where cumulative cash flow turns positive";
        attribute :>> targetDate = "Month 24";
        attribute :>> successCriteria = "Cumulative cash flow >= £0";
        attribute :>> relatedCapabilities = "";
        attribute :>> relatedScenarios = "Lean Clinical (Variant A)";
        attribute :>> status = "planned";
    }

    part objectivePlatformLaunch : StrategicObjective {
        attribute :>> objectiveName = "Patient portal operational";
        attribute :>> description = "Launch the patient-facing portal with pathway visibility, journal, and document access";
        attribute :>> targetDate = "Month 6";
        attribute :>> successCriteria = "Portal live with pathway visibility, journal, and document access features";
        attribute :>> relatedCapabilities = "Clinical assessment, Prescribing and monitoring";
        attribute :>> relatedScenarios = "Lean Clinical (Variant A), Full Platform (Variant B)";
        attribute :>> status = "planned";
    }

    // -- Business model variants (summary level) -----------

    part variantLeanClinical : BusinessModelVariant {
        attribute :>> variantName = "Lean Clinical";
        attribute :>> variantLabel = "A";
        attribute :>> description = "Assessment and hormone therapy only. No coaching, no community. Lowest capital, fastest break-even, limited revenue ceiling.";
        attribute :>> activeOfferings = "Initial Assessment, Hormone Therapy Initiation, Ongoing Monitoring";
        attribute :>> keyDifferentiator = "Low capital, fast break-even, limited ceiling";
        attribute :>> investmentLevel = "~£15K";
        attribute :>> riskProfile = "High sensitivity to patient acquisition; single point of failure (1 clinician)";
        attribute :>> scenarioRef = "Lean Clinical (Variant A)";
    }

    part variantFullPlatform : BusinessModelVariant {
        doc /* Full Platform variant with complete ScenarioDefinition
             * and projection parameters in BusinessScenarios.
             * Elaborated in Phase 5. */
        attribute :>> variantName = "Full Platform";
        attribute :>> variantLabel = "B";
        attribute :>> description = "Full digital platform with coaching, education, community, patient portal. Subscription model. Higher ceiling, longer break-even.";
        attribute :>> activeOfferings = "Initial Assessment, Hormone Therapy Initiation, Ongoing Monitoring, Coaching, Education, Community";
        attribute :>> keyDifferentiator = "Full digital platform, subscription revenue, higher ceiling";
        attribute :>> investmentLevel = "~£120K";
        attribute :>> riskProfile = "Longer break-even, higher capital requirement; more diversified revenue";
        attribute :>> scenarioRef = "Full Platform (Variant B)";
    }

    part variantConsultancyLicence : BusinessModelVariant {
        doc /* Deferred beyond Phase 5. Requires modelling
             * licence pricing, platform deployment for licensees,
             * and support cost structures. */
        attribute :>> variantName = "Consultancy + Platform Licence";
        attribute :>> variantLabel = "C";
        attribute :>> description = "Dual revenue: clinical services AND platform licence/SaaS to other gender services. Highest ceiling, longest break-even.";
        attribute :>> activeOfferings = "Initial Assessment, Hormone Therapy Initiation, Ongoing Monitoring, Platform Licence";
        attribute :>> keyDifferentiator = "Scalable platform revenue independent of clinical capacity";
        attribute :>> investmentLevel = "~£200K";
        attribute :>> riskProfile = "Longest break-even, highest capital; platform revenue scalable independently";
        attribute :>> scenarioRef = "";
    }

    // -- Pivot scenarios -----------------------------------

    part pivotLeanToFull : PivotScenario {
        doc /* The most likely transition path. Variant A
             * establishes clinical operations and proves the
             * model; Variant B adds platform capabilities
             * when demand and resources allow. */
        attribute :>> pivotName = "Lean Clinical to Full Platform transition";
        attribute :>> fromVariant = "Lean Clinical (A)";
        attribute :>> toVariant = "Full Platform (B)";
        attribute :>> triggerCondition = "Break-even achieved and patient demand exceeds single-clinician capacity";
        attribute :>> transitionPlan = "Hire second clinician, add coaching capability, launch subscription model, expand patient portal";
        attribute :>> estimatedTransitionMonths = 6;
        attribute :>> riskNotes = "Requires capital injection or retained earnings sufficient for 6-month transition period";
    }
}
