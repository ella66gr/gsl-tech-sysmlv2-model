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

    // -- GSL strategic objectives --------------------------
    //
    // Note: relatedCapabilities is no longer an attribute here.
    // Traceability from objectives to capabilities is expressed
    // via satisfy relationships in BusinessModel::ResourcePlanning.

    requirement objectivePatientCohort : StrategicObjective {
        attribute :>> objectiveName = "Build active patient cohort";
        attribute :>> description = "Reach 200 active patients across assessment, initiation, and monitoring";
        attribute :>> targetDate = "Month 18";
        attribute :>> successCriteria = "200+ patients in active monitoring or initiation by month 18";
        attribute :>> status = "planned";
    }

    requirement objectiveSharedCare : StrategicObjective {
        attribute :>> objectiveName = "Establish shared care network";
        attribute :>> description = "Build shared care agreements with GP practices for ongoing monitoring";
        attribute :>> targetDate = "Month 24";
        attribute :>> successCriteria = "50+ signed shared care protocols with GP practices";
        attribute :>> status = "planned";
    }

    requirement objectiveBreakEven : StrategicObjective {
        attribute :>> objectiveName = "Financial break-even";
        attribute :>> description = "Reach the point where cumulative cash flow turns positive";
        attribute :>> targetDate = "Month 24";
        attribute :>> successCriteria = "Cumulative cash flow >= £0";
        attribute :>> status = "planned";
    }

    requirement objectivePlatformLaunch : StrategicObjective {
        attribute :>> objectiveName = "Patient portal operational";
        attribute :>> description = "Launch the patient-facing portal with pathway visibility, journal, and document access";
        attribute :>> targetDate = "Month 6";
        attribute :>> successCriteria = "Portal live with pathway visibility, journal, and document access features";
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
        doc /* Deferred beyond Phase 7. Requires modelling
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
