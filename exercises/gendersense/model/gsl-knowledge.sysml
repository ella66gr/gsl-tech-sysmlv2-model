// =========================================================================
// GSL KNOWLEDGE — GenderSense hormone-therapy constraints, specs, tables and outcome targets
// =========================================================================
//
// OP-132 step 6 (S515, ADR-012). The GSL side of the former Knowledge
// package: ConstraintLibrary (whole), the constraint and decision-table
// evaluation spec instances and use cases, the regimen-selection and
// stability-assessment decision tables, the outcome targets, measurement
// points and schedule, and the hormone-therapy enums from
// Foundation::CommonTypes (group F). The General pattern types stay in
// model/knowledge.sysml until OP-132 step 8 (SystemMetamodelGeneral).
// =========================================================================

package GslKnowledge {
    private import ScalarValues::*;

    doc /* GenderSense Limited clinical knowledge: the hormone-therapy
         * constraints, their evaluation specifications, the two
         * prescribing decision tables, the outcome targets and the
         * measurement schedule. Tenant content; the patterns it
         * instantiates (InputDerivation, ConstraintEvaluationSpec,
         * DecisionTableEvaluationSpec, HitPolicy, DecisionTableDef,
         * OutcomeDefinition, MeasurementPoint, MeasurementSchedule) are
         * General. */

    package HormoneTherapyTypes {
        private import ScalarValues::*;

        doc /* Enumerations for the hormone-therapy decision tables.
             * Formerly Foundation::CommonTypes (group F, ADR-011 §4.7);
             * their only consumers are the GSL decision tables. */


        enum def HormoneLevel {
            doc /* Categorised hormone level from blood test results.
                 * Used in decision tables for regimen selection and
                 * stability assessment. */
            low;
            normal;
            high;
            suppressed;
        }

        enum def TherapyPreference {
            doc /* Patient's preference for hormone therapy type.
                 * Captures the direction of therapy as expressed
                 * by the patient during assessment. */
            oestrogen;
            testosterone;
            combined;
        }

        enum def ContraindicationCategory {
            doc /* Categorised contraindication status for prescribing
                 * decisions. Simplification of the full clinical
                 * assessment into categories that drive protocol
                 * selection. */
            noContraindication;
            vteRisk;
            liverDisease;
            cardiacRisk;
            multiple;
        }

        enum def HormoneMedication {
            doc /* Hormone therapy medications in the prescribing
                 * protocol. Each entry represents a specific
                 * pharmaceutical product. */
            estradiolValerate;
            estradiolGel;
            estradiolPatch;
            testosteroneUndecanoate;
            testosteroneEnantate;
            testosteroneGel;
        }

        enum def AdministrationRoute {
            doc /* Route of medication administration. */
            oral;
            transdermal;
            intramuscular;
            subcutaneous;
        }

        enum def DoseCategory {
            doc /* Categorised starting dose level. Maps to specific
                 * dose values per medication in the prescribing
                 * protocol. The dose category determines the actual
                 * dose based on medication-specific tables. */
            low;
            standardDose;
            reduced;
            high;
        }

        enum def PatientSatisfaction {
            doc /* Patient-reported satisfaction with treatment
                 * progress. Captured during monitoring consultations. */
            satisfied;
            neutral;
            dissatisfied;
        }

        enum def StabilityClassification {
            doc /* Clinical classification of regimen stability.
                 * Output of the stabilityAssessment decision table. */
            stable;
            improving;
            adjustmentNeeded;
            concerning;
        }

        enum def MonitoringAction {
            doc /* Recommended monitoring action based on stability
                 * assessment. Output of the stabilityAssessment
                 * decision table. */
            continueCurrentRegimen;
            adjustDose;
            reduceMonitoringInterval;
            increaseMonitoringInterval;
            clinicalReviewUrgent;
        }
    }

    package ConstraintLibrary {
        private import ScalarValues::*;
        private import GslEnterprise::Regulation::*;

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

    package ClinicalDecisionSupport {
        private import ScalarValues::*;
        private import SystemMetamodelGeneral::LogicEngine::*;       // Severity
        private import SystemMetamodelGeneral::EvaluationSpecs::*;   // InputDerivation, ConstraintEvaluationSpec, DecisionTableEvaluationSpec

        doc /* The GSL evaluation specifications: one per ConstraintLibrary
             * constraint, one per decision table, and the clinical
             * decision-support use cases. */

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

    package DecisionTables {
        private import ScalarValues::*;
        private import SystemMetamodelGeneral::LogicEngine::*;       // Severity
        private import SystemMetamodelGeneral::DecisionModels::*;    // HitPolicy, DecisionTableDef
        private import GslKnowledge::HormoneTherapyTypes::*;

        doc /* The two hormone-therapy decision tables — regimen selection
             * and stability assessment — as row defs, table defs that
             * specialise DecisionTableDef, and row usages; plus the
             * evaluation use cases. */

        // =============================================================
        // Regimen Selection Decision Table
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

    package OutcomeTargets {
        private import ScalarValues::*;
        private import SystemMetamodelGeneral::LogicEngine::*;       // Severity
        private import SystemMetamodelGeneral::OutcomeFramework::*;  // OutcomeDefinition, MeasurementPoint, MeasurementSchedule and the outcome enums

        doc /* The GSL hormone-therapy outcome targets, measurement points,
             * the initiation-pathway measurement schedule, and the
             * outcome-reporting use cases. */

        // =============================================================
        // Concrete outcome definitions — Hormone Therapy
        // =============================================================

        // --- Clinical outcomes ---

        part oestradiolTarget : OutcomeDefinition {
            doc /* Target oestradiol level for feminising hormone
                 * therapy. Measured at each monitoring blood test.
                 * Target range is trough level (measured immediately
                 * before next dose or at a standardised time point).
                 *
                 * Representative target: 400–600 pmol/L.
                 * Source: Endocrine Society guidelines / local protocol. */
            attribute :>> outcomeName = "OestradiolTherapeuticRange";
            attribute :>> description = "Serum oestradiol within therapeutic target range at trough";
            attribute :>> category = OutcomeCategory::clinical;
            attribute :>> frequency = MeasurementFrequency::threeMonthly;
            attribute :>> targetOperator = ComparisonOperator::within;
            attribute :>> targetValue = "400";
            attribute :>> targetUpperBound = "600";
            attribute :>> targetUnit = "pmol/L";
            attribute :>> evaluationQuery = "AQL: LabResult where testName='oestradiol' for patient within measurement window";
            attribute :>> severity = Severity::warning;
        }

        part testosteroneMascTarget : OutcomeDefinition {
            doc /* Target testosterone level for masculinising
                 * hormone therapy. Measured at each monitoring
                 * blood test.
                 *
                 * Representative target: 10–30 nmol/L.
                 * Source: Endocrine Society guidelines / local protocol. */
            attribute :>> outcomeName = "TestosteroneTherapeuticRange";
            attribute :>> description = "Serum testosterone within therapeutic target range";
            attribute :>> category = OutcomeCategory::clinical;
            attribute :>> frequency = MeasurementFrequency::threeMonthly;
            attribute :>> targetOperator = ComparisonOperator::within;
            attribute :>> targetValue = "10";
            attribute :>> targetUpperBound = "30";
            attribute :>> targetUnit = "nmol/L";
            attribute :>> evaluationQuery = "AQL: LabResult where testName='testosterone' for patient within measurement window";
            attribute :>> severity = Severity::warning;
        }

        part testosteroneSuppressionTarget : OutcomeDefinition {
            doc /* Target testosterone suppression for feminising
                 * hormone therapy. Testosterone should be suppressed
                 * below the threshold once oestradiol is at target.
                 *
                 * Representative target: < 2 nmol/L.
                 * Source: Endocrine Society guidelines / local protocol. */
            attribute :>> outcomeName = "TestosteroneSuppression";
            attribute :>> description = "Serum testosterone suppressed below threshold on feminising therapy";
            attribute :>> category = OutcomeCategory::clinical;
            attribute :>> frequency = MeasurementFrequency::threeMonthly;
            attribute :>> targetOperator = ComparisonOperator::lessThan;
            attribute :>> targetValue = "2";
            attribute :>> targetUpperBound = "";
            attribute :>> targetUnit = "nmol/L";
            attribute :>> evaluationQuery = "AQL: LabResult where testName='testosterone' for patient on feminising therapy";
            attribute :>> severity = Severity::warning;
        }

        part haematologySafety : OutcomeDefinition {
            doc /* Haematological safety monitoring. For masculinising
                 * therapy: haemoglobin and haematocrit must remain
                 * within safe limits (polycythaemia risk). For
                 * feminising therapy: VTE risk markers monitored.
                 *
                 * Representative target: haematocrit < 0.54.
                 * Source: Local protocol / Endocrine Society. */
            attribute :>> outcomeName = "HaematologySafety";
            attribute :>> description = "Haematological safety markers within safe limits";
            attribute :>> category = OutcomeCategory::safety;
            attribute :>> frequency = MeasurementFrequency::threeMonthly;
            attribute :>> targetOperator = ComparisonOperator::lessThan;
            attribute :>> targetValue = "0.54";
            attribute :>> targetUpperBound = "";
            attribute :>> targetUnit = "L/L";
            attribute :>> evaluationQuery = "AQL: LabResult where testName='haematocrit' for patient within measurement window";
            attribute :>> severity = Severity::critical;
        }

        part metabolicSafety : OutcomeDefinition {
            doc /* Metabolic safety monitoring: liver function tests
                 * and lipid profile within acceptable limits.
                 *
                 * Representative: LFTs within 3x upper limit of normal. */
            attribute :>> outcomeName = "MetabolicSafety";
            attribute :>> description = "Liver function and lipid profile within acceptable limits";
            attribute :>> category = OutcomeCategory::safety;
            attribute :>> frequency = MeasurementFrequency::sixMonthly;
            attribute :>> targetOperator = ComparisonOperator::lessThan;
            attribute :>> targetValue = "3";
            attribute :>> targetUpperBound = "";
            attribute :>> targetUnit = "xULN";
            attribute :>> evaluationQuery = "AQL: LabResult where testName in ('ALT','GGT') for patient within measurement window";
            attribute :>> severity = Severity::warning;
        }

        // --- Adherence outcomes ---

        part monitoringAdherence : OutcomeDefinition {
            doc /* Whether monitoring bloods are completed within
                 * the defined schedule. Target: 100% of scheduled
                 * monitoring bloods completed within the allowed
                 * window. */
            attribute :>> outcomeName = "MonitoringAdherence";
            attribute :>> description = "Monitoring blood tests completed at all scheduled measurement points";
            attribute :>> category = OutcomeCategory::adherence;
            attribute :>> frequency = MeasurementFrequency::threeMonthly;
            attribute :>> targetOperator = ComparisonOperator::equalTo;
            attribute :>> targetValue = "complete";
            attribute :>> targetUpperBound = "";
            attribute :>> targetUnit = "";
            attribute :>> evaluationQuery = "AQL: count of LabResult compositions vs count of due measurement points";
            attribute :>> severity = Severity::warning;
        }

        part appointmentAdherence : OutcomeDefinition {
            doc /* Whether scheduled clinical appointments are
                 * attended. Missed appointments may indicate
                 * disengagement, access barriers, or dissatisfaction. */
            attribute :>> outcomeName = "AppointmentAdherence";
            attribute :>> description = "Scheduled clinical appointments attended or rescheduled within window";
            attribute :>> category = OutcomeCategory::adherence;
            attribute :>> frequency = MeasurementFrequency::threeMonthly;
            attribute :>> targetOperator = ComparisonOperator::equalTo;
            attribute :>> targetValue = "complete";
            attribute :>> targetUpperBound = "";
            attribute :>> targetUnit = "";
            attribute :>> evaluationQuery = "AQL: appointment attendance record for patient within measurement window";
            attribute :>> severity = Severity::informational;
        }

        // --- Safety outcomes ---

        part adverseEventTracking : OutcomeDefinition {
            doc /* Tracking of adverse events during treatment.
                 * Target: no critical adverse events. Warning-level
                 * events are expected to be managed. */
            attribute :>> outcomeName = "AdverseEventTracking";
            attribute :>> description = "No critical adverse events; warning-level events managed and documented";
            attribute :>> category = OutcomeCategory::safety;
            attribute :>> frequency = MeasurementFrequency::threeMonthly;
            attribute :>> targetOperator = ComparisonOperator::equalTo;
            attribute :>> targetValue = "none-critical";
            attribute :>> targetUpperBound = "";
            attribute :>> targetUnit = "";
            attribute :>> evaluationQuery = "AQL: adverse event compositions for patient with severity >= critical";
            attribute :>> severity = Severity::critical;
        }

        // --- Patient-reported outcomes ---

        part treatmentSatisfaction : OutcomeDefinition {
            doc /* Patient-reported treatment satisfaction, captured
                 * during monitoring consultations. Also an input to
                 * the stabilityAssessment decision table. */
            attribute :>> outcomeName = "TreatmentSatisfaction";
            attribute :>> description = "Patient-reported satisfaction with treatment progress";
            attribute :>> category = OutcomeCategory::patientReported;
            attribute :>> frequency = MeasurementFrequency::sixMonthly;
            attribute :>> targetOperator = ComparisonOperator::within;
            attribute :>> targetValue = "satisfied";
            attribute :>> targetUpperBound = "neutral";
            attribute :>> targetUnit = "";
            attribute :>> evaluationQuery = "AQL: consultation composition with satisfaction assessment for patient";
            attribute :>> severity = Severity::informational;
        }

        part goalAttainment : OutcomeDefinition {
            doc /* Patient-reported goal attainment — whether the
                 * patient feels their personal treatment goals are
                 * being met. Captured via structured self-assessment
                 * at 6-month and 12-month points. */
            attribute :>> outcomeName = "GoalAttainment";
            attribute :>> description = "Patient-reported progress toward personal treatment goals";
            attribute :>> category = OutcomeCategory::patientReported;
            attribute :>> frequency = MeasurementFrequency::sixMonthly;
            attribute :>> targetOperator = ComparisonOperator::within;
            attribute :>> targetValue = "met";
            attribute :>> targetUpperBound = "progressing";
            attribute :>> targetUnit = "";
            attribute :>> evaluationQuery = "AQL: self-assessment composition with goal attainment for patient";
            attribute :>> severity = Severity::informational;
        }

        // =============================================================
        // Hormone Therapy Measurement Schedule
        // =============================================================

        part baselinePoint : MeasurementPoint {
            doc /* Baseline measurements before treatment initiation. */
            attribute :>> pointName = "Baseline";
            attribute :>> timingWeeksFromInitiation = 0;
            attribute :>> description = "Pre-treatment baseline assessment. All clinical and safety bloods, initial PROs.";
            attribute :>> isRepeating = false;
            attribute :>> repeatIntervalWeeks = 0;
        }

        part threeMonthPoint : MeasurementPoint {
            doc /* First monitoring assessment at approximately
                 * 12 weeks post-initiation. */
            attribute :>> pointName = "ThreeMonth";
            attribute :>> timingWeeksFromInitiation = 12;
            attribute :>> description = "First monitoring assessment. Initial hormone response, early safety review.";
            attribute :>> isRepeating = false;
            attribute :>> repeatIntervalWeeks = 0;
        }

        part sixMonthPoint : MeasurementPoint {
            doc /* Mid-term assessment at approximately 26 weeks.
                 * First point at which the stabilityAssessment
                 * decision table may declare a patient stable. */
            attribute :>> pointName = "SixMonth";
            attribute :>> timingWeeksFromInitiation = 26;
            attribute :>> description = "Mid-term assessment. Target achievement, stability, full safety panel, PROs.";
            attribute :>> isRepeating = false;
            attribute :>> repeatIntervalWeeks = 0;
        }

        part twelveMonthPoint : MeasurementPoint {
            doc /* Long-term assessment at approximately 52 weeks.
                 * Transition readiness. */
            attribute :>> pointName = "TwelveMonth";
            attribute :>> timingWeeksFromInitiation = 52;
            attribute :>> description = "Long-term assessment. Sustained targets, safety, transition readiness.";
            attribute :>> isRepeating = false;
            attribute :>> repeatIntervalWeeks = 0;
        }

        part annualMonitoringPoint : MeasurementPoint {
            doc /* Annual ongoing monitoring after stabilisation.
                 * Repeats every 52 weeks from the 12-month point. */
            attribute :>> pointName = "AnnualMonitoring";
            attribute :>> timingWeeksFromInitiation = 104;
            attribute :>> description = "Annual ongoing monitoring. Continued targets, long-term safety, satisfaction.";
            attribute :>> isRepeating = true;
            attribute :>> repeatIntervalWeeks = 52;
        }

        part hormoneTherapySchedule : MeasurementSchedule {
            doc /* Measurement schedule for the hormone therapy
                 * initiation pathway. */
            attribute :>> scheduleName = "HormoneTherapyInitiationSchedule";
            attribute :>> pathwayRef = "GslServiceDelivery::ClinicalPathways::HormoneTherapy";
            attribute :>> description = "Standard measurement schedule for hormone therapy from baseline through annual monitoring";
        }

        // =============================================================
        // Use cases
        // =============================================================

        use case def RecordOutcomeMeasurement {
            doc /* Capture an outcome measurement for a patient at
                 * a specific measurement point. Data may enter via
                 * the workflow (Temporal activity commits composition)
                 * or via form entry (clinician or patient records
                 * directly). */
        }

        use case def EvaluateOutcomeAgainstTarget {
            doc /* Evaluate a recorded outcome measurement against
                 * its defined target. Produces an
                 * OutcomeEvaluationResult. */
        }

        use case def ProduceOutcomeReport {
            doc /* Generate an outcome report for a patient, cohort,
                 * or pathway. Aggregates OutcomeEvaluationResults
                 * across measurement points. */
        }

        use case def FeedOutcomeToLearningCycle {
            doc /* When outcome patterns indicate a potential
                 * pathway issue, package the evidence as an
                 * OutcomeFeedbackRecord and feed it into
                 * LearningCycles::ProposePathwayRefinement. */
        }
    }
}
