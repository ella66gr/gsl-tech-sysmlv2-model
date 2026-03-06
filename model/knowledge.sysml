// =========================================================================
// KNOWLEDGE — Decision logic, constraints, reasoning, and learning
// =========================================================================

package Knowledge {
    private import ScalarValues::*;

    doc /* Explicit treatment of knowledge, decision logic, and adaptive
         * behaviour as first-class architectural concerns. Cross-cutting:
         * imported by clinical pathways, referenced by governance, and
         * consuming outcome data.
         *
         * Three-tier reasoning stack:
         * Tier 1 — Deterministic logic (constraints, safety rules)
         * Tier 2 — Structured decision support (DMN-style tables)
         * Tier 3 — ML/LLM-augmented intelligence (advisory only) */

    package ClinicalDecisionSupport {
        private import ScalarValues::*;

        doc /* Decision rules, eligibility criteria, monitoring protocols,
             * and clinical guidelines modelled as evaluable constraints.
             * Consumes CDR data via AQL queries, evaluates against
             * model-derived rules, and surfaces results to pathways
             * and clinician/patient interfaces. */

        use case def EvaluateEligibility {
            doc /* Determine whether a patient meets eligibility criteria
                 * for a specific pathway or intervention. */
        }

        use case def TriggerMonitoringAlert {
            doc /* Flag when clinical data (e.g. hormone levels, blood
                 * results) falls outside defined therapeutic ranges. */
        }

        use case def ProvidePathwayGuidance {
            doc /* Surface personalised clinical guidance to patients and
                 * clinicians derived from structured data and rules. */
        }
    }

    package ConstraintLibrary {
        private import ScalarValues::*;
        private import Enterprise::Regulation::*;

        doc /* Composable clinical constraints, safety rules, drug
             * interaction checks, contraindication screening. Constraints
             * are reusable and testable in isolation: each takes typed
             * inputs and returns a boolean evaluation.
             *
             * Each constraint def has a corresponding constraint usage
             * and a satisfy relationship linking it to the requirement
             * it fulfils in Enterprise::Regulation. */

        // =============================================================
        // Constraint definitions
        // =============================================================

        // --- Consent and patient information ---

        constraint def ConsentRecordedConstraint {
            doc /* Evaluable rule: a valid consent record must exist
                 * for the specified treatment before it can proceed.
                 *
                 * At runtime, consentRecorded is derived from the
                 * CDR: a consent composition exists for this patient
                 * and treatment type with status 'given'. */
            in consentRecorded : Boolean;

            consentRecorded
        }

        constraint def PatientInformationProvidedConstraint {
            doc /* Evaluable rule: the patient must have been provided
                 * with treatment information before consent is obtained.
                 *
                 * At runtime, informationProvided is derived from the
                 * CDR: an information-provision event is recorded for
                 * this patient and treatment type, with a timestamp
                 * before the consent timestamp. */
            in informationProvided : Boolean;

            informationProvided
        }

        // --- Baseline investigations ---

        constraint def BaselineBloodsReviewedConstraint {
            doc /* Evaluable rule: all required baseline blood tests
                 * must have reached the 'reviewed' state before a
                 * hormone therapy prescription can be authorised.
                 *
                 * This checks two conditions:
                 * 1. All required tests have been performed (no
                 *    outstanding orders)
                 * 2. All results have been clinically reviewed (not
                 *    just resulted — a clinician must have seen them)
                 *
                 * At runtime, both inputs are derived from LabResult
                 * lifecycle state queries against the CDR. */
            in allBaselineTestsResulted : Boolean;
            in allBaselineResultsReviewed : Boolean;

            allBaselineTestsResulted and allBaselineResultsReviewed
        }

        // --- Prescribing governance ---

        constraint def ClinicalReviewCompletedConstraint {
            doc /* Evaluable rule: a clinical review must have been
                 * completed and documented before a prescribing
                 * decision can proceed.
                 *
                 * At runtime, reviewCompleted is derived from the
                 * CDR: a consultation composition exists for this
                 * episode with a review outcome recorded. */
            in reviewCompleted : Boolean;

            reviewCompleted
        }

        constraint def RegimenWithinProtocolConstraint {
            doc /* Evaluable rule: the proposed medication, route, and
                 * dose must fall within the bounds of an approved
                 * prescribing protocol.
                 *
                 * At runtime, this evaluates the proposed regimen
                 * against the protocol decision table in
                 * Knowledge::DecisionModels. A regimen is within
                 * protocol if all three components match an approved
                 * combination. */
            in medicationApproved : Boolean;
            in routeApproved : Boolean;
            in doseWithinRange : Boolean;

            medicationApproved and routeApproved and doseWithinRange
        }

        // --- Monitoring ---

        constraint def BloodMonitoringIntervalConstraint {
            doc /* Evaluable rule: the number of weeks since the last
                 * blood test must not exceed the required monitoring
                 * interval.
                 *
                 * At runtime, weeksSinceLastTest is derived from the
                 * CDR: the most recent LabResult for this patient
                 * with the relevant test name. requiredIntervalWeeks
                 * comes from the prescribing protocol. */
            in weeksSinceLastTest : Integer;
            in requiredIntervalWeeks : Integer;

            weeksSinceLastTest <= requiredIntervalWeeks
        }

        constraint def DoseAdjustmentReviewedConstraint {
            doc /* Evaluable rule: a clinical review must have been
                 * completed, with current blood results reviewed,
                 * before a dose adjustment can be authorised.
                 *
                 * This is a compound check: both the clinical review
                 * and the blood result review must be complete. */
            in clinicalReviewCompleted : Boolean;
            in currentResultsReviewed : Boolean;

            clinicalReviewCompleted and currentResultsReviewed
        }

        // --- Shared care ---

        constraint def SharedCareAcceptedConstraint {
            doc /* Evaluable rule: shared care must not commence until
                 * the GP practice has confirmed acceptance of the
                 * shared care arrangement and the shared care protocol
                 * document has been sent.
                 *
                 * At runtime, both inputs are derived from the
                 * Referral lifecycle state (referralAccepted) and
                 * a document-sent event in the CDR. */
            in sharedCareProtocolSent : Boolean;
            in gpPracticeAccepted : Boolean;

            sharedCareProtocolSent and gpPracticeAccepted
        }

        // =============================================================
        // Constraint usages and satisfy relationships
        //
        // Each constraint def needs a usage (feature) to serve as
        // the 'by' target in a satisfy relationship. The satisfy
        // links provide formal traceability from evaluable runtime
        // checks back to governance requirements.
        // =============================================================

        constraint consentCheck : ConsentRecordedConstraint;
        constraint informationCheck : PatientInformationProvidedConstraint;
        constraint baselineBloodsCheck : BaselineBloodsReviewedConstraint;
        constraint clinicalReviewCheck : ClinicalReviewCompletedConstraint;
        constraint regimenProtocolCheck : RegimenWithinProtocolConstraint;
        constraint bloodMonitoringCheck : BloodMonitoringIntervalConstraint;
        constraint doseAdjustmentReviewCheck : DoseAdjustmentReviewedConstraint;
        constraint sharedCareCheck : SharedCareAcceptedConstraint;

        satisfy requirement ConsentBeforeTreatment
            by consentCheck;

        satisfy requirement InformedConsentRequiresInformation
            by informationCheck;

        satisfy requirement BaselineInvestigationsBeforePrescribing
            by baselineBloodsCheck;

        satisfy requirement ClinicalReviewBeforePrescribing
            by clinicalReviewCheck;

        satisfy requirement PrescribingProtocolAdherence
            by regimenProtocolCheck;

        satisfy requirement BloodMonitoringRequired
            by bloodMonitoringCheck;

        satisfy requirement ClinicalReviewBeforeDoseAdjustment
            by doseAdjustmentReviewCheck;

        satisfy requirement SharedCareCommunication
            by sharedCareCheck;
    }

    package LogicEngine {
        private import ScalarValues::*;

        doc /* Inference rules, Prolog-style reasoning, deterministic
             * constraint evaluation. Explicit architectural space for
             * logic programming.
             *
             * Runtime target TBD: embedded Prolog (e.g. Tau Prolog),
             * TypeScript constraint evaluator, DMN engine, or combination.
             * Decision deferred until clinical rules are better understood
             * from first pathway modelling. */
    }

    package DecisionModels {
        private import ScalarValues::*;

        doc /* DMN-style decision tables, decision requirement graphs,
             * multi-criteria clinical protocol decisions. Deterministic
             * and auditable. Decision tables map to SysML v2 constraints
             * and can be read and validated by clinicians.
             *
             * Examples: prescribing protocol selection, referral routing,
             * risk stratification. */
    }

    package OutcomeFramework {
        private import ScalarValues::*;

        doc /* Outcome definitions, measurement points, structured outcome
             * capture, outcome-to-pathway feedback.
             *
             * Records not just that a patient was treated, but the specific
             * regimen, monitoring results at defined intervals, whether
             * clinical targets were achieved, and any adverse events. */

        part def OutcomeDefinition {
            doc /* A defined clinical outcome with measurement criteria. */
            attribute outcomeName : String;
            attribute description : String;
            attribute measurementInterval : String;
        }
    }

    package LearningCycles {
        private import ScalarValues::*;

        doc /* Pathway refinement process, evidence review, change control
             * governance. Itself modelled as an action flow.
             *
             * Cycle: capture structured outcomes -> analyse patterns ->
             * propose pathway refinement -> clinical governance review ->
             * update model -> regenerate. The model is the mechanism for
             * both capturing and enacting the learning. */

        use case def ProposePathwayRefinement {
            doc /* Initiate a pathway change proposal based on outcome
                 * data or new clinical evidence. */
        }

        use case def ReviewAndApproveChange {
            doc /* Clinical governance review and approval of a proposed
                 * pathway or protocol change. */
        }
    }

    package Analytics {
        private import ScalarValues::*;

        doc /* Data contracts for BI and predictive analytics, event stream
             * definitions, ML/LLM integration points, advisory layer
             * interface definitions.
             *
             * Tier 3 reasoning: powerful but probabilistic, always advisory
             * rather than authoritative. Cannot override Tier 1/2 logic. */

        part def DataContract {
            doc /* Defines the schema and semantics of a data stream
                 * consumed by analytics or ML pipelines. */
            attribute contractName : String;
            attribute description : String;
        }
    }
}
