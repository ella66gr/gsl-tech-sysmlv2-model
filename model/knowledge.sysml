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
             * that binds it to its input derivations. Decision tables
             * in DecisionModels have corresponding
             * DecisionTableEvaluationSpecs following the same pattern.
             *
             * Elaborated Session 8 (Phase 1: constraint specs),
             * Session 10 (Phase 3: decision table specs). */

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
        // Decision table evaluation specifications
        //
        // Parallel to ConstraintEvaluationSpecs, these bind decision
        // tables to their input derivations. The same InputDerivation
        // pattern applies: each table input is derived from an
        // authoritative data source.
        // =============================================================

        part def DecisionTableEvaluationSpec {
            doc /* Binds a decision table to its input derivations
                 * and evaluation metadata, parallel to
                 * ConstraintEvaluationSpec for constraints.
                 *
                 * The tableName matches the @DecisionTable metadata
                 * annotation on pathway steps. The evaluation
                 * infrastructure resolves the name to this spec,
                 * derives inputs, evaluates the table, and returns
                 * the matching row's outputs. */
            attribute tableName : String;
            attribute description : String;
            part inputDerivations : InputDerivation[0..*];
        }

        part regimenSelectionSpec : DecisionTableEvaluationSpec {
            doc /* Evaluation spec for the regimenSelection decision
                 * table. Derives four inputs from CDR and clinical
                 * assessment data: baseline testosterone, baseline
                 * oestradiol, patient therapy preference, and
                 * contraindication category. */
            attribute :>> tableName = "regimenSelection";
            attribute :>> description = "Derives inputs for regimen selection from baseline bloods and assessment";
        }

        part stabilityAssessmentSpec : DecisionTableEvaluationSpec {
            doc /* Evaluation spec for the stabilityAssessment
                 * decision table. Derives inputs from monitoring
                 * bloods, treatment history, and consultation
                 * data: hormone level, weeks on treatment, side
                 * effect severity, and patient satisfaction. */
            attribute :>> tableName = "stabilityAssessment";
            attribute :>> description = "Derives inputs for stability assessment from monitoring data and consultation";
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
             * Component inventory:
             * - ConstraintEvaluator: Tier 1 deterministic evaluation
             *   (InputResolver, ExpressionEvaluator, ExplanationBuilder)
             * - OperationalStateAggregator: Layer 2 operational state
             *   queries across Temporal, CDR, and platform services
             * - GapAnalyser: Layer 4 comparison of operational state
             *   against goal state (GoalProjector)
             * - AssessmentOrchestrator: coordinates five-layer
             *   SystemStateAssessment production
             * - SelfExplanationService: audience-appropriate rendering
             *   of evaluation results and assessments
             * - EvaluationSpecRegistry: runtime lookup of constraint
             *   evaluation specifications
             * - InferenceEvaluator: Tier 2 interface (Prolog boundary)
             * - AdvisoryInterface: Tier 3 interface (ML/LLM boundary)
             *
             * Data structures (Phase 1):
             * - EvaluationResult, ExplanationTrace, EvaluatedInput
             * - Deficit, SystemStateAssessment
             *
             * Additional structures (Phase 2):
             * - OperationalSnapshot, OperationalQuery
             * - GoalProjection, EvaluationContext
             *
             * Three-tier reasoning stack:
             * Tier 1 — TypeScript constraint evaluator (generated from
             *   SysML). Boolean constraints with structured explanation
             *   traces. Handles ConstraintLibrary evaluation and
             *   Layers 1-4 of self-knowledge.
             * Tier 2 — Embedded Prolog for inference chains,
             *   contraindication cascades, compound deficit reasoning.
             *   Layer 5 compound remediation.
             * Tier 3 — ML/LLM advisory interface. Cannot override
             *   Tier 1/2 logic.
             *
             * Elaborated Session 8 (Phase 1: data structures) and
             * Session 9 (Phase 2: component model). */

        // =============================================================
        // Evaluation result structures (Phase 1 — Track A)
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
        // Self-knowledge structures (Phase 1 — Track B)
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

            // Layer 2 — Operational snapshot
            part operationalSnapshot : OperationalSnapshot;

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
        // Phase 2 — Tier 1 evaluator component (Stage 1)
        // =============================================================

        part def InputResolver {
            doc /* Resolves constraint inputs from authoritative data
                 * sources. For each InputDerivation in a
                 * ConstraintEvaluationSpec, the resolver executes the
                 * specified query against the appropriate source (CDR,
                 * Temporal, platform service), applies the computation
                 * to derive a typed value, and handles fallback if the
                 * query fails or returns no data.
                 *
                 * Source-agnostic: the resolver dispatches based on
                 * the InputDerivation's sourceType attribute. The
                 * query format varies by source (AQL for CDR, API
                 * call for Temporal, HTTP for platform services) but
                 * the resolution pattern is identical.
                 *
                 * Produces EvaluatedInput records as output — these
                 * feed both the expression evaluator (for the
                 * constraint check) and the explanation builder (for
                 * the audit trace). */
            attribute resolverId : String;
        }

        part def ExpressionEvaluator {
            doc /* Evaluates a constraint's boolean expression given
                 * resolved input values. For Tier 1, this is
                 * straightforward boolean evaluation: the constraint
                 * def's expression is evaluated with the derived
                 * input values substituted.
                 *
                 * Returns an EvaluationOutcome (pass, fail,
                 * indeterminate). Indeterminate arises when one or
                 * more inputs could not be resolved and the fallback
                 * outcome propagates.
                 *
                 * In a future generated implementation, this component
                 * is replaced by generated TypeScript functions — one
                 * per constraint def. The generated function takes
                 * typed inputs and returns the boolean result directly,
                 * with the expression evaluation compiled rather than
                 * interpreted. */
            attribute evaluatorId : String;
        }

        part def ExplanationBuilder {
            doc /* Assembles ExplanationTrace records from the
                 * evaluation context: the resolved inputs
                 * (EvaluatedInput records), the constraint expression
                 * as evaluated, and a human-readable explanation of
                 * the outcome.
                 *
                 * Supports three audiences:
                 * - Clinicians: technical but accessible explanation
                 *   of why a safety check passed or failed, with
                 *   data values
                 * - Patients: plain-language explanation suitable for
                 *   self-management interfaces
                 * - Auditors: full formal trace with data provenance
                 *
                 * The audience parameter determines explanation depth
                 * and language register. All three are derived from
                 * the same underlying EvaluatedInput and expression
                 * data — the difference is presentation, not
                 * content. */
            attribute builderId : String;
        }

        part def ConstraintEvaluator {
            doc /* The Tier 1 deterministic constraint evaluation
                 * component. Consumes ConstraintEvaluationSpecs from
                 * ClinicalDecisionSupport, derives inputs from
                 * authoritative sources (CDR via AQL, Temporal,
                 * platform services), evaluates constraint boolean
                 * expressions, and produces structured
                 * EvaluationResults with full ExplanationTraces.
                 *
                 * This is a generic runtime component: it does not
                 * contain any specific clinical logic. All rule
                 * knowledge comes from the ConstraintLibrary (what
                 * the rule is) and the ConstraintEvaluationSpec
                 * (how to get the data). The evaluator is the
                 * execution engine that connects the two.
                 *
                 * Invocation: pathway action steps annotated with
                 * @LogicRule or @SafetyConstraint generate Temporal
                 * activities that call this component. See
                 * architecture decision document, Section 1.
                 *
                 * Scope: evaluates one constraint for one context
                 * (typically one patient). Population-level
                 * evaluation (governance audit) wraps this in a
                 * loop over a patient cohort — same component,
                 * iterated. */
            attribute evaluatorId : String;

            // --- Capabilities ---
            part inputResolver : InputResolver;
            part expressionEvaluator : ExpressionEvaluator;
            part explanationBuilder : ExplanationBuilder;
        }

        // =============================================================
        // Phase 2 — Operational state aggregator (Stage 2)
        // =============================================================

        part def OperationalQuery {
            doc /* A single operational state query against an
                 * authoritative source. Structurally parallel to
                 * InputDerivation but scoped to operational rather
                 * than clinical data.
                 *
                 * The query returns a structured result (count,
                 * list, or status) rather than a single typed value.
                 * This is a wider interface than InputDerivation,
                 * which derives a single constraint input.
                 *
                 * At runtime, implemented as a TypeScript function
                 * that calls the appropriate API (Temporal client,
                 * EHRbase REST/AQL, platform health endpoint). */
            attribute queryName : String;
            attribute sourceType : DataSourceType;
            attribute query : String;
            attribute description : String;
        }

        part def OperationalSnapshot {
            doc /* A point-in-time capture of the system's operational
                 * state, produced by the OperationalStateAggregator.
                 * This is the Layer 2 content that feeds into gap
                 * analysis and the SystemStateAssessment.
                 *
                 * Not persisted as a separate data store — computed
                 * on demand. The snapshot captures the query results
                 * at a specific moment for comparison against
                 * goals. */
            attribute capturedAt : String;          // ISO datetime
            attribute scope : AssessmentScope;

            // Process state summary
            attribute activeWorkflows : Integer;
            attribute blockedWorkflows : Integer;
            attribute failedWorkflows : Integer;
            attribute workflowsPastSla : Integer;

            // Clinical data summary
            attribute overdueMonitoringItems : Integer;
            attribute totalActivePatients : Integer;

            // Infrastructure health
            attribute cdrStatus : ServiceHealthStatus;
            attribute temporalStatus : ServiceHealthStatus;
            attribute externalIntegrationsHealthy : Integer;
            attribute externalIntegrationsTotal : Integer;
        }

        part def OperationalStateAggregator {
            doc /* Queries the system's operational state across all
                 * authoritative data sources: Temporal (process
                 * state), CDR (clinical data state), entity
                 * lifecycle state, and platform services
                 * (infrastructure health).
                 *
                 * Uses the same source-agnostic InputDerivation
                 * pattern as the ConstraintEvaluator, but scoped
                 * to operational rather than clinical queries. Each
                 * operational query is an InputDerivation with the
                 * appropriate sourceType.
                 *
                 * Produces a structured OperationalSnapshot — the
                 * Layer 2 content of a SystemStateAssessment.
                 *
                 * Query categories:
                 * - Process state (Temporal): active, blocked,
                 *   failed workflows; workflow step distribution;
                 *   SLA adherence
                 * - Clinical data state (CDR via AQL): composition
                 *   counts by archetype, overdue monitoring items,
                 *   recording completeness
                 * - Entity lifecycle state: counts by entity type
                 *   and state (e.g. 42 active prescriptions,
                 *   7 pending referrals)
                 * - Infrastructure health: CDR reachable, Temporal
                 *   workers running, external integrations
                 *   responding
                 *
                 * See architecture decision document, Section 3
                 * (Operational State Query Pattern). */
            attribute aggregatorId : String;
            part processStateQuery : OperationalQuery;
            part clinicalDataQuery : OperationalQuery;
            part entityStateQuery : OperationalQuery;
            part infrastructureQuery : OperationalQuery;
        }

        // =============================================================
        // Phase 2 — Gap analyser (Stage 3)
        // =============================================================

        part def GoalProjection {
            doc /* A single goal projected from the model into a
                 * shape comparable against operational state. The
                 * unit of comparison for gap analysis.
                 *
                 * Each projection names the goal source
                 * (requirement, constraint, or outcome definition),
                 * the expected condition, and the query needed to
                 * check actual state. The gap analyser evaluates
                 * the query and compares the result against the
                 * expected condition. */
            attribute goalName : String;
            attribute goalSource : String;         // requirement, constraint, or outcome def name
            attribute expectedCondition : String;  // human-readable expected state
            attribute evaluationQuery : String;    // query to check actual state
            attribute scope : AssessmentScope;
        }

        part def GoalProjector {
            doc /* Projects goals from model sources (requirements,
                 * constraints, outcome definitions) into a
                 * comparable shape against operational state.
                 *
                 * Each goal is expressed as a GoalProjection: an
                 * expected condition that can be evaluated against
                 * actual data. The projection mechanism varies by
                 * source:
                 *
                 * - Requirement goals: "every active patient has
                 *   a LabResult within N weeks" -> AQL query
                 *   counting patients without recent LabResults
                 * - Constraint goals: constraint evaluates to pass
                 *   for every active patient -> batch constraint
                 *   evaluation across cohort
                 * - Outcome goals: "hormone levels within
                 *   therapeutic range at 6-month measurement
                 *   point" -> AQL query against outcome
                 *   compositions
                 *
                 * The projector does not evaluate goals — it
                 * transforms them into a shape the gap analyser
                 * can compare against operational data. */
            attribute projectorId : String;
        }

        part def GapAnalyser {
            doc /* Compares the system's operational state (Layer 2,
                 * OperationalSnapshot) against its goal state
                 * (Layer 3, projected from requirements,
                 * constraints, and outcome definitions) and
                 * produces Deficit records for every unmet goal.
                 *
                 * This is the direct generalisation of the Phase D
                 * governance audit: Phase D compared expected
                 * compositions against actual compositions for a
                 * single rule. The gap analyser applies the same
                 * pattern across all defined goals and all
                 * operational dimensions.
                 *
                 * Goal sources:
                 * - Requirements (Enterprise::Regulation) ->
                 *   expected compliance conditions
                 * - Constraints (Knowledge::ConstraintLibrary) ->
                 *   expected evaluation pass outcomes for all
                 *   active patients
                 * - Outcome definitions
                 *   (Knowledge::OutcomeFramework) -> expected
                 *   clinical target achievement
                 *
                 * Each goal is projected as an expected condition.
                 * The analyser evaluates the condition against
                 * operational data and emits a Deficit if the
                 * condition is not met.
                 *
                 * See architecture decision document, Section 4
                 * (Goal State Projection). */
            attribute analyserId : String;
            part goalProjector : GoalProjector;
        }

        // =============================================================
        // Phase 2 — Tier 2 and Tier 3 interfaces (Stage 4)
        // =============================================================

        part def InferenceEvaluator {
            doc /* Tier 2 reasoning interface: inference chains,
                 * contraindication cascades, compound deficit
                 * reasoning, and "why" queries.
                 *
                 * Where Tier 1 (ConstraintEvaluator) evaluates
                 * single boolean constraints, Tier 2 reasons about
                 * relationships between multiple constraints,
                 * deficits, and available actions. This is the
                 * architectural space for Prolog-style logic
                 * programming.
                 *
                 * Key capabilities (interface only, not yet
                 * implemented):
                 *
                 * - Contraindication cascade: given a proposed
                 *   medication, trace through all interaction
                 *   rules, existing medications, and patient
                 *   conditions to produce a compound safety
                 *   assessment with full inference chain
                 * - Compound deficit reasoning: given multiple
                 *   Deficit records, identify interactions
                 *   (e.g. overdue bloods AND missed appointment
                 *   AND expiring prescription), reason about
                 *   priority and sequencing, and produce a
                 *   compound remediation recommendation
                 * - "Why" queries: given an EvaluationResult,
                 *   trace backward through the inference chain
                 *   to explain not just what the result is but
                 *   why the inputs have their current values
                 *
                 * Runtime target: Tau Prolog (pure JS, embeddable
                 * in Temporal activities) or SWI-Prolog WASM.
                 * Decision deferred until clinical rules demand
                 * inference beyond Tier 1 boolean constraints.
                 *
                 * Produces EvaluationResults with the same
                 * structure as Tier 1, but subEvaluations may
                 * form deeper trees reflecting the inference
                 * chain. */
            attribute evaluatorId : String;
            attribute reasoningEngine : String;    // e.g. "tau-prolog", "swi-prolog-wasm"
        }

        part def AdvisoryInterface {
            doc /* Tier 3 advisory interface: ML/LLM-augmented
                 * intelligence. Powerful but probabilistic, always
                 * advisory rather than authoritative. Cannot
                 * override Tier 1 or Tier 2 logic.
                 *
                 * Capabilities (interface boundary only):
                 *
                 * - Pattern recognition across patient cohorts
                 * - Natural language processing of unstructured
                 *   clinical notes
                 * - Predictive analytics (trajectory-based dose
                 *   adjustment suggestions, capacity forecasting)
                 * - Literature synthesis for clinical guideline
                 *   updates
                 * - Advisory remediation for systemic deficits
                 *   where no single deterministic action resolves
                 *   the gap
                 *
                 * Architectural constraints:
                 * - All Tier 3 outputs are labelled as advisory
                 * - Tier 3 cannot modify pathway state or trigger
                 *   automatic actions
                 * - Tier 3 outputs are presented alongside (never
                 *   instead of) Tier 1/2 deterministic results
                 * - Clinical validation is required before any
                 *   Tier 3 capability is surfaced to clinicians
                 *   or patients
                 *
                 * Implementation deferred. The interface exists to
                 * ensure the architecture accommodates ML/LLM
                 * capabilities without compromising the
                 * deterministic foundation. */
            attribute interfaceId : String;
            attribute modelType : String;         // e.g. "llm", "ml-classifier", "predictive"
            attribute confidenceThreshold : Real; // minimum confidence for surfacing
        }

        // =============================================================
        // Phase 2 — Self-explanation and orchestration (Stage 5)
        // =============================================================

        part def SelfExplanationService {
            doc /* The API surface through which consumers access the
                 * system's self-knowledge and evaluation
                 * explanations.
                 *
                 * Four consumer categories, each with different
                 * needs:
                 *
                 * - Clinician UI: point-of-care evaluation results
                 *   with clinical context. "Why did this safety
                 *   check fail?" with data values and rule
                 *   references.
                 * - Patient portal: plain-language explanations
                 *   for self-management. "Why am I eligible / not
                 *   eligible?" with actionable guidance.
                 * - Governance dashboard: population-level
                 *   assessment summaries, deficit inventories,
                 *   compliance rates, trend analysis over
                 *   assessment history.
                 * - Audit endpoint: full formal traces with data
                 *   provenance, constraint references, requirement
                 *   traceability. Exportable for regulatory
                 *   submission.
                 *
                 * All four are views onto the same underlying data
                 * (EvaluationResults, SystemStateAssessments). The
                 * service applies audience-appropriate filtering,
                 * explanation depth, and presentation format.
                 *
                 * Implements the ExplainEvaluationResult use
                 * case. */
            attribute serviceId : String;
        }

        part def AssessmentOrchestrator {
            doc /* Orchestrates the production of
                 * SystemStateAssessments by coordinating the other
                 * LogicEngine components.
                 *
                 * Assessment production sequence:
                 * 1. Read System Model Manifest for Layer 1
                 *    (structural summary — packages, pathways,
                 *    constraints, etc.)
                 * 2. Invoke OperationalStateAggregator for Layer 2
                 *    (operational snapshot)
                 * 3. Invoke GoalProjector for Layer 3 (project all
                 *    in-scope goals)
                 * 4. Invoke GapAnalyser for Layer 4 (compare
                 *    Layers 2 and 3, produce Deficit records)
                 * 5. Classify each Deficit's remediation category
                 *    for Layer 5
                 * 6. For Tier 1 deficits with deterministic
                 *    remediation, identify the specific pathway
                 *    action step
                 * 7. For compound deficits, optionally invoke
                 *    InferenceEvaluator (Tier 2) for reasoning
                 * 8. Assemble the composite SystemStateAssessment
                 *
                 * Invocation patterns (from architecture decision
                 * document, Section 6):
                 * - On-demand: platform API call, scoped by caller
                 * - Scheduled: Temporal cron workflow (daily
                 *   clinical governance, weekly operational health)
                 * - Triggered: critical deficit in point-of-care
                 *   evaluation triggers broader scoped assessment
                 *
                 * Implements the ProduceSystemStateAssessment use
                 * case. The orchestrator itself is a natural
                 * candidate for a Temporal workflow — it
                 * coordinates multiple queries and evaluations
                 * that may take non-trivial time. */
            attribute orchestratorId : String;
            ref constraintEvaluator : ConstraintEvaluator;
            ref operationalAggregator : OperationalStateAggregator;
            ref gapAnalyser : GapAnalyser;
            ref explanationService : SelfExplanationService;
        }

        // =============================================================
        // Phase 2 — Registry and context (Stage 6)
        // =============================================================

        part def EvaluationSpecRegistry {
            doc /* A runtime registry of ConstraintEvaluationSpecs,
                 * loaded from the model (or generated as a
                 * TypeScript module) at system startup.
                 *
                 * The registry resolves constraint names to their
                 * full evaluation specifications: which inputs to
                 * derive, from which sources, with what
                 * computations, and what fallback behaviour. This
                 * is the lookup table that the ConstraintEvaluator
                 * consults when invoked.
                 *
                 * Generation approach (from architecture decision
                 * document, Section 1):
                 * - A generator reads ConstraintEvaluationSpec
                 *   part usages from
                 *   Knowledge::ClinicalDecisionSupport
                 * - It produces a TypeScript module exporting a
                 *   map from constraint name to spec object
                 * - The registry loads this module at startup
                 *
                 * This replaces the need to parse SysML at
                 * runtime. The registry is a static, generated
                 * artefact — it changes only when the model is
                 * updated and the generator re-run. */
            attribute registryId : String;
            attribute specCount : Integer;
            attribute modelVersion : String;
        }

        part def EvaluationContext {
            doc /* The runtime context for a single evaluation
                 * invocation. Captures the scope (which patient,
                 * which pathway step), the trigger (point-of-care,
                 * governance audit, triggered assessment), and any
                 * ambient data already available (to avoid
                 * redundant queries).
                 *
                 * Passed to the ConstraintEvaluator alongside the
                 * ConstraintEvaluationSpec. The evaluator uses the
                 * context to parameterise InputDerivation queries
                 * (e.g. substituting the patient's EHR ID into
                 * AQL). */
            attribute contextId : String;
            attribute patientId : String;
            attribute pathwayStepRef : String;
            attribute triggerType : String;        // point-of-care, governance-audit, triggered
            attribute scope : AssessmentScope;
        }

        // =============================================================
        // Use cases (Phase 1 defs, Phase 2 elaboration)
        // =============================================================

        use case def EvaluateConstraint {
            doc /* Evaluate a single constraint for a specific
                 * patient or context.
                 *
                 * Component allocation:
                 * 1. EvaluationSpecRegistry resolves the constraint
                 *    name to its ConstraintEvaluationSpec
                 * 2. InputResolver derives each input from its
                 *    authoritative source per the spec
                 * 3. ExpressionEvaluator evaluates the constraint
                 *    boolean expression with derived inputs
                 * 4. ExplanationBuilder assembles the
                 *    ExplanationTrace
                 * 5. ConstraintEvaluator composes the
                 *    EvaluationResult
                 *
                 * Invoked by:
                 * - Temporal activities generated from pathway
                 *   steps annotated with @LogicRule or
                 *   @SafetyConstraint
                 * - Governance audit workflows iterating over a
                 *   patient cohort
                 * - Triggered assessment when a deficit is
                 *   detected
                 *
                 * Produces: one EvaluationResult with full
                 * ExplanationTrace per invocation. */
        }

        use case def PerformGapAnalysis {
            doc /* Compare operational state against goal state for
                 * a defined scope (patient, pathway, domain,
                 * system).
                 *
                 * Component allocation:
                 * 1. GoalProjector projects all in-scope goals
                 *    from requirements, constraints, and outcome
                 *    definitions
                 * 2. OperationalStateAggregator captures current
                 *    state (or receives a pre-computed
                 *    OperationalSnapshot)
                 * 3. GapAnalyser compares each GoalProjection
                 *    against operational data
                 * 4. For each unmet goal, a Deficit record is
                 *    produced with severity, remediation category,
                 *    and supporting EvaluationResult evidence
                 *
                 * Scope determines breadth:
                 * - Patient: all goals applicable to one patient
                 * - Pathway: all goals for a specific clinical
                 *   pathway
                 * - Domain: all goals within a domain (clinical,
                 *   operational, infrastructure)
                 * - System: all goals across all domains
                 *
                 * Produces: a set of Deficit records. */
        }

        use case def ProduceSystemStateAssessment {
            doc /* Aggregate structural self-knowledge, operational
                 * state, goal compliance, deficits, and
                 * remediation recommendations into a composite
                 * SystemStateAssessment.
                 *
                 * Component allocation: AssessmentOrchestrator
                 * coordinates the full five-layer assembly:
                 * - Layer 1: reads System Model Manifest
                 *   (structural)
                 * - Layer 2: invokes OperationalStateAggregator
                 * - Layer 3: invokes GoalProjector
                 * - Layer 4: invokes GapAnalyser
                 * - Layer 5: classifies remediation categories
                 *
                 * Three invocation triggers:
                 * - On-demand: API call from clinician or admin UI
                 * - Scheduled: Temporal cron workflow
                 * - Triggered: critical deficit escalation
                 *
                 * Produces: one SystemStateAssessment. */
        }

        use case def ExplainEvaluationResult {
            doc /* Given an EvaluationResult or
                 * SystemStateAssessment, produce an
                 * audience-appropriate explanation.
                 *
                 * Component allocation: SelfExplanationService
                 * renders the underlying data (EvaluatedInputs,
                 * ExplanationTraces, Deficit records) into the
                 * appropriate format for the requesting consumer.
                 *
                 * Audience rendering:
                 * - Clinician: data values, rule references,
                 *   clinical context, recommended actions
                 * - Patient: plain-language explanation, actionable
                 *   guidance, self-management prompts
                 * - Auditor: full trace, data provenance,
                 *   requirement traceability, exportable format
                 * - Dashboard: summary statistics, trend
                 *   indicators, deficit inventory, compliance
                 *   rates */
        }
    }

    package DecisionModels {
        private import ScalarValues::*;
        private import Foundation::CommonTypes::*;

        doc /* DMN-style decision tables modelled as SysML part defs
             * with typed inputs, outputs, and row-level rules.
             * Deterministic and auditable — clinicians can read and
             * validate the tables directly from the model.
             *
             * SysML v2 does not define a decision table as a first-class
             * language element. The v2 spec expects tabular decision
             * logic to be represented using general-purpose constructs
             * (part defs, constraints, views) with domain-specific
             * methodology layered on top. This package implements that
             * approach.
             *
             * Representation pattern:
             * - DecisionTableDef: abstract table interface with
             *   common metadata (name, hit policy, description)
             * - Concrete table part defs specialise DecisionTableDef
             *   and declare typed input and output attributes
             * - Table rows are part usages of a row def, with :>>
             *   attribute redefinitions providing the concrete input
             *   conditions and output values
             *
             * Decision tables are a specialised form of constraint
             * evaluation. The @DecisionTable metadata annotation on
             * pathway steps triggers evaluation via the same
             * ConstraintEvaluator infrastructure in LogicEngine.
             * The table recommends an output; the clinician makes
             * the final decision at a @ClinicalReviewGate.
             *
             * Two decision tables for the hormone therapy pathway:
             * - regimenSelection: baseline data to medication, route,
             *   starting dose
             * - stabilityAssessment: monitoring data to stability
             *   classification, monitoring action
             *
             * Elaborated Session 10: Knowledge Layer Phase 3. */

        // =============================================================
        // Decision table pattern definitions
        // =============================================================

        enum def HitPolicy {
            doc /* How a decision table resolves when evaluating.
                 * Based on DMN hit policy semantics.
                 * unique: exactly one row must match (error otherwise)
                 * firstMatch: rows are ordered, first match wins
                 * collect: all matching rows contribute to output */
            unique;
            firstMatch;
            collect;
        }

        part def DecisionTableDef {
            doc /* Abstract definition for a decision table. Concrete
                 * tables specialise this with their specific input
                 * and output attributes.
                 *
                 * Each table has a name (matching the @DecisionTable
                 * annotation in the pathway), a hit policy, and a
                 * description of its clinical purpose.
                 *
                 * This part def provides common metadata; it is
                 * not intended to be instantiated directly. */
            attribute tableName : String;
            attribute hitPolicy : HitPolicy;
            attribute tableDescription : String;
        }

        // =============================================================
        // Regimen Selection Decision Table
        //
        // Maps baseline investigation results, patient preference,
        // and contraindication status to the recommended hormone
        // therapy regimen (medication, route, starting dose).
        //
        // Referenced by: @DecisionTable { tableName = "regimenSelection"; }
        // on selectRegimen step in HormoneTherapy pathway.
        //
        // Consumed by: ConstraintEvaluator via EvaluationSpecRegistry.
        // Validated against: RegimenWithinProtocolConstraint.
        // =============================================================

        part def RegimenSelectionRow {
            doc /* A single row in the regimen selection decision
                 * table. Each row maps a combination of input
                 * conditions to a recommended regimen.
                 *
                 * Concrete rows redefine all attributes with
                 * specific values using :>> redefinition. */

            // --- Inputs (conditions) ---
            attribute baselineTestosterone : HormoneLevel;
            attribute baselineOestradiol : HormoneLevel;
            attribute therapyPreference : TherapyPreference;
            attribute contraindication : ContraindicationCategory;

            // --- Outputs (recommendations) ---
            attribute medication : HormoneMedication;
            attribute administrationRoute : AdministrationRoute;
            attribute startingDose : DoseCategory;
        }

        part def RegimenSelectionTable :> DecisionTableDef {
            doc /* Regimen selection decision table for hormone
                 * therapy initiation.
                 *
                 * Hit policy: Unique — exactly one row should match
                 * for any valid combination of inputs. If no row
                 * matches, the evaluation returns indeterminate
                 * with a recommendation for clinician judgement.
                 *
                 * Clinical source: GenderSense Prescribing Protocol
                 * (version and date to be recorded when real
                 * protocol data is loaded).
                 *
                 * Note: the rows below use representative,
                 * clinically plausible values for modelling
                 * purposes. Actual prescribing protocol data
                 * will be loaded from the validated clinical
                 * source before any runtime use. */

            attribute :>> tableName = "regimenSelection";
            attribute :>> hitPolicy = HitPolicy::unique;
            attribute :>> tableDescription = "Maps baseline hormones, patient preference, and contraindications to recommended regimen";

            // --- Oestrogen therapy rows ---

            part row01 : RegimenSelectionRow {
                doc /* Oestrogen preference, no contraindications,
                     * low baseline — standard transdermal patch. */
                attribute :>> baselineTestosterone = HormoneLevel::normal;
                attribute :>> baselineOestradiol = HormoneLevel::low;
                attribute :>> therapyPreference = TherapyPreference::oestrogen;
                attribute :>> contraindication = ContraindicationCategory::noContraindication;
                attribute :>> medication = HormoneMedication::estradiolPatch;
                attribute :>> administrationRoute = AdministrationRoute::transdermal;
                attribute :>> startingDose = DoseCategory::standardDose;
            }

            part row02 : RegimenSelectionRow {
                doc /* Oestrogen preference, VTE risk —
                     * transdermal preferred over oral to avoid
                     * first-pass hepatic effects. Reduced dose. */
                attribute :>> baselineTestosterone = HormoneLevel::normal;
                attribute :>> baselineOestradiol = HormoneLevel::low;
                attribute :>> therapyPreference = TherapyPreference::oestrogen;
                attribute :>> contraindication = ContraindicationCategory::vteRisk;
                attribute :>> medication = HormoneMedication::estradiolPatch;
                attribute :>> administrationRoute = AdministrationRoute::transdermal;
                attribute :>> startingDose = DoseCategory::reduced;
            }

            part row03 : RegimenSelectionRow {
                doc /* Oestrogen preference, liver disease —
                     * transdermal to bypass hepatic metabolism. */
                attribute :>> baselineTestosterone = HormoneLevel::normal;
                attribute :>> baselineOestradiol = HormoneLevel::low;
                attribute :>> therapyPreference = TherapyPreference::oestrogen;
                attribute :>> contraindication = ContraindicationCategory::liverDisease;
                attribute :>> medication = HormoneMedication::estradiolGel;
                attribute :>> administrationRoute = AdministrationRoute::transdermal;
                attribute :>> startingDose = DoseCategory::reduced;
            }

            part row04 : RegimenSelectionRow {
                doc /* Oestrogen preference, cardiac risk —
                     * transdermal, low starting dose with close
                     * monitoring. */
                attribute :>> baselineTestosterone = HormoneLevel::normal;
                attribute :>> baselineOestradiol = HormoneLevel::low;
                attribute :>> therapyPreference = TherapyPreference::oestrogen;
                attribute :>> contraindication = ContraindicationCategory::cardiacRisk;
                attribute :>> medication = HormoneMedication::estradiolPatch;
                attribute :>> administrationRoute = AdministrationRoute::transdermal;
                attribute :>> startingDose = DoseCategory::low;
            }

            part row05 : RegimenSelectionRow {
                doc /* Oestrogen preference, multiple contraindications —
                     * requires specialist review. Lowest-risk option
                     * as starting point for discussion. */
                attribute :>> baselineTestosterone = HormoneLevel::normal;
                attribute :>> baselineOestradiol = HormoneLevel::low;
                attribute :>> therapyPreference = TherapyPreference::oestrogen;
                attribute :>> contraindication = ContraindicationCategory::multiple;
                attribute :>> medication = HormoneMedication::estradiolGel;
                attribute :>> administrationRoute = AdministrationRoute::transdermal;
                attribute :>> startingDose = DoseCategory::low;
            }

            // --- Testosterone therapy rows ---

            part row06 : RegimenSelectionRow {
                doc /* Testosterone preference, no contraindications —
                     * standard IM injection. */
                attribute :>> baselineTestosterone = HormoneLevel::low;
                attribute :>> baselineOestradiol = HormoneLevel::normal;
                attribute :>> therapyPreference = TherapyPreference::testosterone;
                attribute :>> contraindication = ContraindicationCategory::noContraindication;
                attribute :>> medication = HormoneMedication::testosteroneUndecanoate;
                attribute :>> administrationRoute = AdministrationRoute::intramuscular;
                attribute :>> startingDose = DoseCategory::standardDose;
            }

            part row07 : RegimenSelectionRow {
                doc /* Testosterone preference, needle aversion or
                     * patient preference for self-administration —
                     * transdermal gel. */
                attribute :>> baselineTestosterone = HormoneLevel::low;
                attribute :>> baselineOestradiol = HormoneLevel::high;
                attribute :>> therapyPreference = TherapyPreference::testosterone;
                attribute :>> contraindication = ContraindicationCategory::noContraindication;
                attribute :>> medication = HormoneMedication::testosteroneGel;
                attribute :>> administrationRoute = AdministrationRoute::transdermal;
                attribute :>> startingDose = DoseCategory::standardDose;
            }

            part row08 : RegimenSelectionRow {
                doc /* Testosterone preference, cardiac risk —
                     * gel preferred over injection for more stable
                     * serum levels. Reduced starting dose. */
                attribute :>> baselineTestosterone = HormoneLevel::low;
                attribute :>> baselineOestradiol = HormoneLevel::normal;
                attribute :>> therapyPreference = TherapyPreference::testosterone;
                attribute :>> contraindication = ContraindicationCategory::cardiacRisk;
                attribute :>> medication = HormoneMedication::testosteroneGel;
                attribute :>> administrationRoute = AdministrationRoute::transdermal;
                attribute :>> startingDose = DoseCategory::reduced;
            }

            part row09 : RegimenSelectionRow {
                doc /* Testosterone preference, liver disease —
                     * transdermal to avoid hepatic first-pass.
                     * Standard dose (testosterone is not primarily
                     * hepatically metabolised at standard doses). */
                attribute :>> baselineTestosterone = HormoneLevel::low;
                attribute :>> baselineOestradiol = HormoneLevel::normal;
                attribute :>> therapyPreference = TherapyPreference::testosterone;
                attribute :>> contraindication = ContraindicationCategory::liverDisease;
                attribute :>> medication = HormoneMedication::testosteroneGel;
                attribute :>> administrationRoute = AdministrationRoute::transdermal;
                attribute :>> startingDose = DoseCategory::standardDose;
            }
        }

        // =============================================================
        // Stability Assessment Decision Table
        //
        // Maps monitoring results, time on treatment, and patient-
        // reported outcomes to a stability classification and
        // recommended monitoring action.
        //
        // Referenced by: @DecisionTable { tableName = "stabilityAssessment"; }
        // on assessStabilityDecision step in HormoneTherapy pathway.
        //
        // Drives the monitoring cycle branch: stable patients proceed
        // to confirmStable; patients needing adjustment loop back
        // to adjustDose -> scheduleMonitoringBloods.
        // =============================================================

        part def StabilityAssessmentRow {
            doc /* A single row in the stability assessment decision
                 * table. Each row maps monitoring indicators to a
                 * stability classification and recommended action. */

            // --- Inputs (conditions) ---
            attribute hormoneLevel : HormoneLevel;
            attribute minimumWeeksOnTreatment : Integer;
            attribute sideEffectSeverity : Severity;
            attribute satisfaction : PatientSatisfaction;

            // --- Outputs (recommendations) ---
            attribute classification : StabilityClassification;
            attribute monitoringAction : MonitoringAction;
        }

        part def StabilityAssessmentTable :> DecisionTableDef {
            doc /* Stability assessment decision table for hormone
                 * therapy monitoring.
                 *
                 * Hit policy: Unique — exactly one classification
                 * should result from any valid input combination.
                 *
                 * The table is evaluated at each monitoring review
                 * point (typically every 3 months during titration,
                 * every 6-12 months once stable).
                 *
                 * Note: minimumWeeksOnTreatment uses integer
                 * comparison rather than enum matching. In the
                 * generated evaluator, rows with integer inputs
                 * use range checks rather than equality. The
                 * values shown in rows represent the minimum
                 * weeks threshold for that row to be eligible. */

            attribute :>> tableName = "stabilityAssessment";
            attribute :>> hitPolicy = HitPolicy::unique;
            attribute :>> tableDescription = "Maps monitoring indicators to stability classification and monitoring action";

            // --- Stable regimen rows ---

            part row01 : StabilityAssessmentRow {
                doc /* Normal hormones, 12+ weeks, no significant
                     * side effects, patient satisfied — stable.
                     * Continue current regimen, standard monitoring. */
                attribute :>> hormoneLevel = HormoneLevel::normal;
                attribute :>> minimumWeeksOnTreatment = 12;
                attribute :>> sideEffectSeverity = Severity::informational;
                attribute :>> satisfaction = PatientSatisfaction::satisfied;
                attribute :>> classification = StabilityClassification::stable;
                attribute :>> monitoringAction = MonitoringAction::continueCurrentRegimen;
            }

            part row02 : StabilityAssessmentRow {
                doc /* Normal hormones, 12+ weeks, no significant
                     * side effects, patient neutral — stable but
                     * explore satisfaction concerns. Continue
                     * regimen with reduced monitoring interval. */
                attribute :>> hormoneLevel = HormoneLevel::normal;
                attribute :>> minimumWeeksOnTreatment = 12;
                attribute :>> sideEffectSeverity = Severity::informational;
                attribute :>> satisfaction = PatientSatisfaction::neutral;
                attribute :>> classification = StabilityClassification::stable;
                attribute :>> monitoringAction = MonitoringAction::reduceMonitoringInterval;
            }

            // --- Improving but not yet stable ---

            part row03 : StabilityAssessmentRow {
                doc /* Normal hormones but less than 12 weeks on
                     * treatment — too early to declare stable.
                     * Continue and recheck. */
                attribute :>> hormoneLevel = HormoneLevel::normal;
                attribute :>> minimumWeeksOnTreatment = 0;
                attribute :>> sideEffectSeverity = Severity::informational;
                attribute :>> satisfaction = PatientSatisfaction::satisfied;
                attribute :>> classification = StabilityClassification::improving;
                attribute :>> monitoringAction = MonitoringAction::continueCurrentRegimen;
            }

            // --- Adjustment needed ---

            part row04 : StabilityAssessmentRow {
                doc /* Low hormone levels — dose likely insufficient.
                     * Adjust dose upward. */
                attribute :>> hormoneLevel = HormoneLevel::low;
                attribute :>> minimumWeeksOnTreatment = 12;
                attribute :>> sideEffectSeverity = Severity::informational;
                attribute :>> satisfaction = PatientSatisfaction::dissatisfied;
                attribute :>> classification = StabilityClassification::adjustmentNeeded;
                attribute :>> monitoringAction = MonitoringAction::adjustDose;
            }

            part row05 : StabilityAssessmentRow {
                doc /* High hormone levels — dose may need reducing.
                     * Adjust dose downward. */
                attribute :>> hormoneLevel = HormoneLevel::high;
                attribute :>> minimumWeeksOnTreatment = 12;
                attribute :>> sideEffectSeverity = Severity::informational;
                attribute :>> satisfaction = PatientSatisfaction::satisfied;
                attribute :>> classification = StabilityClassification::adjustmentNeeded;
                attribute :>> monitoringAction = MonitoringAction::adjustDose;
            }

            part row06 : StabilityAssessmentRow {
                doc /* Normal hormones but warning-level side effects —
                     * may need route or formulation change.
                     * Increase monitoring, clinical review. */
                attribute :>> hormoneLevel = HormoneLevel::normal;
                attribute :>> minimumWeeksOnTreatment = 0;
                attribute :>> sideEffectSeverity = Severity::warning;
                attribute :>> satisfaction = PatientSatisfaction::dissatisfied;
                attribute :>> classification = StabilityClassification::adjustmentNeeded;
                attribute :>> monitoringAction = MonitoringAction::increaseMonitoringInterval;
            }

            // --- Concerning ---

            part row07 : StabilityAssessmentRow {
                doc /* Critical side effects regardless of hormone
                     * levels — urgent clinical review. */
                attribute :>> hormoneLevel = HormoneLevel::normal;
                attribute :>> minimumWeeksOnTreatment = 0;
                attribute :>> sideEffectSeverity = Severity::critical;
                attribute :>> satisfaction = PatientSatisfaction::dissatisfied;
                attribute :>> classification = StabilityClassification::concerning;
                attribute :>> monitoringAction = MonitoringAction::clinicalReviewUrgent;
            }

            part row08 : StabilityAssessmentRow {
                doc /* Suppressed hormone levels — possible over-
                     * suppression. Urgent review to assess dose
                     * and clinical status. */
                attribute :>> hormoneLevel = HormoneLevel::suppressed;
                attribute :>> minimumWeeksOnTreatment = 0;
                attribute :>> sideEffectSeverity = Severity::informational;
                attribute :>> satisfaction = PatientSatisfaction::neutral;
                attribute :>> classification = StabilityClassification::concerning;
                attribute :>> monitoringAction = MonitoringAction::clinicalReviewUrgent;
            }
        }

        // =============================================================
        // Use cases
        // =============================================================

        use case def EvaluateDecisionTable {
            doc /* Evaluate a decision table for a specific patient
                 * and clinical context.
                 *
                 * Invoked when a pathway step annotated with
                 * @DecisionTable is reached. The evaluation:
                 * 1. Resolves the table by name via the registry
                 * 2. Derives input values from authoritative sources
                 * 3. Matches inputs against table rows per hit policy
                 * 4. Returns the matching row's output values as a
                 *    structured recommendation
                 * 5. Produces an EvaluationResult with ExplanationTrace
                 *    showing which row matched and why
                 *
                 * The result is a recommendation, not an automatic
                 * action — the clinician reviews it at a
                 * @ClinicalReviewGate before proceeding.
                 *
                 * Component allocation: ConstraintEvaluator (same
                 * Tier 1 infrastructure as constraint evaluation). */
        }

        use case def ValidateDecisionAgainstTable {
            doc /* After a clinician makes a prescribing decision,
                 * validate that the chosen regimen appears in the
                 * decision table. If the clinician overrides the
                 * table recommendation, the override is logged
                 * as a protocol deviation with clinical justification.
                 *
                 * This is the bridge to RegimenWithinProtocolConstraint
                 * in ConstraintLibrary: the table recommends, the
                 * constraint validates. */
        }
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
