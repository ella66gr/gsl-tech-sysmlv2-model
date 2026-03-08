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
        private import Foundation::CommonTypes::*;
        private import Knowledge::LogicEngine::*;

        doc /* Decision rules, eligibility criteria, monitoring protocols,
             * and clinical guidelines modelled as evaluable constraints.
             * Consumes CDR data via AQL queries, evaluates against
             * model-derived rules, and surfaces results to pathways
             * and clinician/patient interfaces.
             *
             * Separates "what the rule is" (ConstraintLibrary) from
             * "how to get the data for the rule" (here). Each
             * constraint def has a corresponding ConstraintEvaluationSpec
             * that binds it to its input derivations.
             *
             * Elaborated Session 8: Knowledge Layer Phase 1. */

        // =============================================================
        // Input derivation pattern
        // =============================================================

        part def InputDerivation {
            doc /* Defines how a single constraint input is derived
                 * from an authoritative data source. The pattern is
                 * source-agnostic: the same structure describes AQL
                 * queries against the CDR, Temporal workflow state
                 * queries, and platform service API calls.
                 *
                 * Each input in a constraint def has a corresponding
                 * InputDerivation that specifies the query,
                 * computation, and fallback behaviour. This formalises
                 * what the ConstraintLibrary doc blocks describe
                 * narratively. */
            attribute inputName : String;
            attribute sourceType : DataSourceType;
            attribute query : String;
            attribute computation : String;
            attribute fallbackOutcome : EvaluationOutcome;
            attribute fallbackReason : String;
        }

        part def ConstraintEvaluationSpec {
            doc /* Binds a constraint definition to its input
                 * derivations, forming a complete evaluation
                 * specification. This is the unit that the evaluation
                 * engine consumes: it knows which constraint to
                 * evaluate and how to get every input.
                 *
                 * Separates "what the rule is" (ConstraintLibrary)
                 * from "how to get the data" (here). */
            attribute constraintName : String;
            attribute requirementName : String;
            attribute severity : Severity;
            part inputDerivations : InputDerivation[0..*];
        }

        // =============================================================
        // Constraint evaluation specifications
        //
        // One spec per ConstraintLibrary constraint. Each spec names
        // the constraint, the requirement it satisfies, its severity,
        // and the input derivations needed to evaluate it.
        // =============================================================

        // --- Consent and patient information ---

        part consentSpec : ConstraintEvaluationSpec {
            doc /* Evaluation spec for ConsentRecordedConstraint.
                 * Single CDR input: consent composition exists. */
            attribute :>> constraintName = "ConsentRecordedConstraint";
            attribute :>> requirementName = "ConsentBeforeTreatment";
            attribute :>> severity = Severity::critical;
        }

        part informationSpec : ConstraintEvaluationSpec {
            doc /* Evaluation spec for PatientInformationProvidedConstraint.
                 * Single CDR input: information-provision event. */
            attribute :>> constraintName = "PatientInformationProvidedConstraint";
            attribute :>> requirementName = "InformedConsentRequiresInformation";
            attribute :>> severity = Severity::critical;
        }

        // --- Baseline investigations ---

        part baselineBloodsSpec : ConstraintEvaluationSpec {
            doc /* Evaluation spec for BaselineBloodsReviewedConstraint.
                 * Two inputs from CDR/entity: all tests resulted,
                 * all results reviewed. */
            attribute :>> constraintName = "BaselineBloodsReviewedConstraint";
            attribute :>> requirementName = "BaselineInvestigationsBeforePrescribing";
            attribute :>> severity = Severity::critical;
        }

        // --- Prescribing governance ---

        part clinicalReviewSpec : ConstraintEvaluationSpec {
            doc /* Evaluation spec for ClinicalReviewCompletedConstraint.
                 * Single CDR input: consultation composition with
                 * review outcome. */
            attribute :>> constraintName = "ClinicalReviewCompletedConstraint";
            attribute :>> requirementName = "ClinicalReviewBeforePrescribing";
            attribute :>> severity = Severity::critical;
        }

        part regimenProtocolSpec : ConstraintEvaluationSpec {
            doc /* Evaluation spec for RegimenWithinProtocolConstraint.
                 * Three inputs: medication, route, dose checked against
                 * the prescribing protocol decision table. */
            attribute :>> constraintName = "RegimenWithinProtocolConstraint";
            attribute :>> requirementName = "PrescribingProtocolAdherence";
            attribute :>> severity = Severity::critical;
        }

        // --- Monitoring ---

        part bloodMonitoringSpec : ConstraintEvaluationSpec {
            doc /* Evaluation spec for BloodMonitoringIntervalConstraint.
                 * Two inputs: weeksSinceLastTest from CDR (most recent
                 * LabResult), requiredIntervalWeeks from entity
                 * (active prescription monitoring interval). */
            attribute :>> constraintName = "BloodMonitoringIntervalConstraint";
            attribute :>> requirementName = "BloodMonitoringRequired";
            attribute :>> severity = Severity::warning;
        }

        part doseAdjustmentSpec : ConstraintEvaluationSpec {
            doc /* Evaluation spec for DoseAdjustmentReviewedConstraint.
                 * Two CDR inputs: clinical review completed,
                 * current results reviewed. */
            attribute :>> constraintName = "DoseAdjustmentReviewedConstraint";
            attribute :>> requirementName = "ClinicalReviewBeforeDoseAdjustment";
            attribute :>> severity = Severity::critical;
        }

        // --- Shared care ---

        part sharedCareSpec : ConstraintEvaluationSpec {
            doc /* Evaluation spec for SharedCareAcceptedConstraint.
                 * Two inputs: shared care protocol sent (CDR),
                 * GP practice accepted (entity lifecycle state). */
            attribute :>> constraintName = "SharedCareAcceptedConstraint";
            attribute :>> requirementName = "SharedCareCommunication";
            attribute :>> severity = Severity::critical;
        }

        // =============================================================
        // Use cases
        // =============================================================

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
        private import Foundation::CommonTypes::*;

        doc /* Inference rules, Prolog-style reasoning, deterministic
             * constraint evaluation, and system self-knowledge
             * infrastructure. Explicit architectural space for logic
             * programming.
             *
             * Three-tier reasoning stack:
             * Tier 1 — TypeScript constraint evaluator (generated from
             *   SysML). Boolean constraints with structured explanation
             *   traces. Handles ConstraintLibrary evaluation and
             *   Layers 1-4 of self-knowledge.
             * Tier 2 — Embedded Prolog (Tau Prolog or SWI-Prolog WASM)
             *   for inference chains, contraindication cascades, compound
             *   deficit reasoning, and "why" queries. Layer 5 compound
             *   remediation.
             * Tier 3 — ML/LLM advisory interface (interface only, no
             *   implementation). Cannot override Tier 1/2 logic.
             *
             * Runtime target: Tier 1 (TypeScript) is the starting point.
             * Tier 2 (Prolog) explored when clinical rules demand
             * inference beyond boolean constraints. Tier 3 deferred.
             *
             * Self-knowledge infrastructure lives here alongside rule
             * evaluation because the foundational patterns (structured
             * results, input derivation, explanation traces) are shared.
             * Extract to a dedicated package later if warranted.
             *
             * Elaborated Session 8: Knowledge Layer Phase 1. */

        // =============================================================
        // Evaluation result structures (Track A)
        // =============================================================

        part def EvaluatedInput {
            doc /* A single input value used in a rule evaluation.
                 * Records what data was used, where it came from,
                 * and how it was derived — supporting the
                 * self-explanation requirement for clinical governance
                 * and patient safety. */
            attribute inputName : String;
            attribute inputValue : String;     // serialised value
            attribute sourceType : DataSourceType;
            attribute sourceQuery : String;    // AQL, Temporal query, or API call
            attribute derivedAt : String;      // ISO datetime
        }

        part def ExplanationTrace {
            doc /* A structured explanation of how a rule evaluation
                 * reached its conclusion. Supports three audiences:
                 * - Clinicians: why did this safety check pass/fail?
                 * - Patients: why am I eligible or not?
                 * - Auditors: trace from outcome through every decision.
                 *
                 * The trace is the clinical governance artefact that
                 * makes the self-explaining requirement concrete. */
            attribute ruleExpression : String;     // the rule as evaluated
            attribute humanExplanation : String;   // plain-language explanation
            part evaluatedInputs : EvaluatedInput[0..*];
        }

        part def EvaluationResult {
            doc /* The atomic unit of knowledge evaluation. Every rule,
                 * at every point in the system, produces one of these.
                 *
                 * EvaluationResults are persisted (CDR or audit log),
                 * queryable, and presentable to clinicians, patients,
                 * and auditors. They are the structured output of
                 * Tier 1 deterministic evaluation.
                 *
                 * The same structure is produced whether the evaluation
                 * is invoked at point-of-care (single patient, single
                 * rule) or in a governance audit (population, multiple
                 * rules). */
            attribute ruleName : String;
            attribute outcome : EvaluationOutcome;
            attribute evaluatedAt : String;          // ISO datetime
            attribute constraintRef : String;        // ConstraintLibrary def name
            attribute requirementRef : String;       // satisfied requirement name
            part explanation : ExplanationTrace;
            part subEvaluations : EvaluationResult[0..*];
        }

        // =============================================================
        // Self-knowledge structures (Track B)
        // =============================================================

        part def Deficit {
            doc /* A structured record of a gap between the system's
                 * actual operational state and its goal state.
                 * Generalises the Phase D governance audit pattern
                 * from a single rule to any operational dimension.
                 *
                 * Each deficit references the goal it falls short of
                 * (requirement, constraint, or outcome definition),
                 * the actual state found, and the expected state.
                 * Supporting EvaluationResult records provide the
                 * evidence chain.
                 *
                 * Deficits are computed, not stored — they are the
                 * output of comparing Layer 2 (operational state)
                 * against Layer 3 (goal state). */
            attribute deficitDomain : DeficitDomain;
            attribute scope : AssessmentScope;
            attribute description : String;
            attribute goalReference : String;
            attribute actualState : String;
            attribute expectedState : String;
            attribute severity : Severity;
            attribute detectedAt : String;          // ISO datetime
            attribute remediationCategory : RemediationCategory;
            attribute remediationDescription : String;
            part supportingEvaluations : EvaluationResult[0..*];
        }

        part def SystemStateAssessment {
            doc /* The composite output of the self-knowledge
                 * infrastructure. Aggregates across all five layers
                 * to produce a whole-system picture.
                 *
                 * Not a new data store — computed on demand by
                 * querying existing authoritative sources (Temporal,
                 * CDR, platform services) and running existing
                 * evaluation logic.
                 *
                 * Can be scoped: single patient, clinical pathway,
                 * domain, or entire system. Scheduled Temporal cron
                 * workflows produce periodic assessments; on-demand
                 * requests produce point-in-time assessments.
                 *
                 * This is the primary artefact of the self-describing
                 * property: the system's own structured report on
                 * itself. */
            attribute assessmentId : String;
            attribute assessedAt : String;          // ISO datetime
            attribute scope : AssessmentScope;
            attribute scopeFilter : String;
            attribute modelVersion : String;

            // Layer 1 — Structural summary
            attribute packagesCount : Integer;
            attribute pathwaysCount : Integer;
            attribute constraintsCount : Integer;
            attribute requirementsCount : Integer;
            attribute entityLifecyclesCount : Integer;

            // Layer 3 vs Layer 2 — Goal compliance summary
            attribute totalGoals : Integer;
            attribute goalsMet : Integer;
            attribute goalsUnmet : Integer;
            attribute goalsIndeterminate : Integer;

            // Layer 4 — Deficits
            part deficits : Deficit[0..*];

            // Layer 5 — Evaluation evidence
            part evaluationResults : EvaluationResult[0..*];
        }

        // =============================================================
        // Use cases
        // =============================================================

        use case def EvaluateConstraint {
            doc /* Evaluate a single constraint for a specific patient
                 * or context. Derives inputs from authoritative sources,
                 * evaluates the constraint expression, and produces a
                 * structured EvaluationResult with explanation trace. */
        }

        use case def PerformGapAnalysis {
            doc /* Compare operational state against goal state for a
                 * defined scope (patient, pathway, domain, system).
                 * Produces Deficit records identifying where actual
                 * state falls short of expected state. */
        }

        use case def ProduceSystemStateAssessment {
            doc /* Aggregate structural self-knowledge, operational
                 * state, goal compliance, deficits, and remediation
                 * recommendations into a composite
                 * SystemStateAssessment. The primary output of the
                 * self-describing property. */
        }

        use case def ExplainEvaluationResult {
            doc /* Given an EvaluationResult, produce a human-readable
                 * explanation suitable for the requesting audience
                 * (clinician, patient, auditor). */
        }
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
