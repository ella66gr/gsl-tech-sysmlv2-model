// ============================================================
// DO NOT EDIT — Generated from GenderSense SysML v2 model
// Source: model/knowledge.sysml (Knowledge::ConstraintLibrary)
// Generated: 2026-03-09T22:54:02Z
// Generator: scripts/gen_constraint_evaluator.py
// ============================================================

import type { EvaluationResult, EvaluationOutcome, Severity } from './evaluation-types';

/**
 * ConsentRecordedConstraint
 *
 * Evaluable rule: a valid consent record must exist for the specified
 * treatment before it can proceed. At runtime, consentRecorded is derived
 * from the CDR: a consent composition exists for this patient and
 * treatment type with status 'given'.
 *
 * Satisfies: ConsentBeforeTreatment
 * Severity: critical
 */
export function evaluateConsentRecorded(
  inputs: {
    consentRecorded: boolean;
  }
): EvaluationResult {
  const outcome: EvaluationOutcome =
    (inputs.consentRecorded)
      ? 'pass'
      : 'fail';

  return {
    constraintName: 'ConsentRecordedConstraint',
    outcome,
    severity: 'critical',
    satisfies: 'ConsentBeforeTreatment',
    explanation: {
      ruleExpression: `consentRecorded`,
      humanExplanation: outcome === 'pass'
        ? 'ConsentRecordedConstraint check passed.'
        : 'ConsentRecordedConstraint check failed.',
      evaluatedInputs: [
        {
          name: 'consentRecorded',
          value: inputs.consentRecorded,
          source: 'derived',  // populated by evaluation engine at runtime
          derivedAt: new Date().toISOString(),
        },
      ],
    },
    evaluatedAt: new Date().toISOString(),
    subEvaluations: [],
  };
}

/**
 * PatientInformationProvidedConstraint
 *
 * Evaluable rule: the patient must have been provided with treatment
 * information before consent is obtained. At runtime, informationProvided
 * is derived from the CDR: an information-provision event is recorded for
 * this patient and treatment type, with a timestamp before the consent
 * timestamp.
 *
 * Satisfies: InformedConsentRequiresInformation
 * Severity: critical
 */
export function evaluatePatientInformationProvided(
  inputs: {
    informationProvided: boolean;
  }
): EvaluationResult {
  const outcome: EvaluationOutcome =
    (inputs.informationProvided)
      ? 'pass'
      : 'fail';

  return {
    constraintName: 'PatientInformationProvidedConstraint',
    outcome,
    severity: 'critical',
    satisfies: 'InformedConsentRequiresInformation',
    explanation: {
      ruleExpression: `informationProvided`,
      humanExplanation: outcome === 'pass'
        ? 'PatientInformationProvidedConstraint check passed.'
        : 'PatientInformationProvidedConstraint check failed.',
      evaluatedInputs: [
        {
          name: 'informationProvided',
          value: inputs.informationProvided,
          source: 'derived',  // populated by evaluation engine at runtime
          derivedAt: new Date().toISOString(),
        },
      ],
    },
    evaluatedAt: new Date().toISOString(),
    subEvaluations: [],
  };
}

/**
 * BaselineBloodsReviewedConstraint
 *
 * Evaluable rule: all required baseline blood tests must have reached the
 * 'reviewed' state before a hormone therapy prescription can be
 * authorised. This checks two conditions: 1. All required tests have been
 * performed (no outstanding orders) 2. All results have been clinically
 * reviewed (not just resulted — a clinician must have seen them) At
 * runtime, both inputs are derived from LabResult lifecycle state queries
 * against the CDR.
 *
 * Satisfies: BaselineInvestigationsBeforePrescribing
 * Severity: critical
 */
export function evaluateBaselineBloodsReviewed(
  inputs: {
    allBaselineTestsResulted: boolean;
    allBaselineResultsReviewed: boolean;
  }
): EvaluationResult {
  const outcome: EvaluationOutcome =
    (inputs.allBaselineTestsResulted && inputs.allBaselineResultsReviewed)
      ? 'pass'
      : 'fail';

  return {
    constraintName: 'BaselineBloodsReviewedConstraint',
    outcome,
    severity: 'critical',
    satisfies: 'BaselineInvestigationsBeforePrescribing',
    explanation: {
      ruleExpression: `allBaselineTestsResulted and allBaselineResultsReviewed`,
      humanExplanation: outcome === 'pass'
        ? 'BaselineBloodsReviewedConstraint check passed.'
        : 'BaselineBloodsReviewedConstraint check failed.',
      evaluatedInputs: [
        {
          name: 'allBaselineTestsResulted',
          value: inputs.allBaselineTestsResulted,
          source: 'derived',  // populated by evaluation engine at runtime
          derivedAt: new Date().toISOString(),
        },
        {
          name: 'allBaselineResultsReviewed',
          value: inputs.allBaselineResultsReviewed,
          source: 'derived',  // populated by evaluation engine at runtime
          derivedAt: new Date().toISOString(),
        },
      ],
    },
    evaluatedAt: new Date().toISOString(),
    subEvaluations: [],
  };
}

/**
 * ClinicalReviewCompletedConstraint
 *
 * Evaluable rule: a clinical review must have been completed and
 * documented before a prescribing decision can proceed. At runtime,
 * reviewCompleted is derived from the CDR: a consultation composition
 * exists for this episode with a review outcome recorded.
 *
 * Satisfies: ClinicalReviewBeforePrescribing
 * Severity: critical
 */
export function evaluateClinicalReviewCompleted(
  inputs: {
    reviewCompleted: boolean;
  }
): EvaluationResult {
  const outcome: EvaluationOutcome =
    (inputs.reviewCompleted)
      ? 'pass'
      : 'fail';

  return {
    constraintName: 'ClinicalReviewCompletedConstraint',
    outcome,
    severity: 'critical',
    satisfies: 'ClinicalReviewBeforePrescribing',
    explanation: {
      ruleExpression: `reviewCompleted`,
      humanExplanation: outcome === 'pass'
        ? 'ClinicalReviewCompletedConstraint check passed.'
        : 'ClinicalReviewCompletedConstraint check failed.',
      evaluatedInputs: [
        {
          name: 'reviewCompleted',
          value: inputs.reviewCompleted,
          source: 'derived',  // populated by evaluation engine at runtime
          derivedAt: new Date().toISOString(),
        },
      ],
    },
    evaluatedAt: new Date().toISOString(),
    subEvaluations: [],
  };
}

/**
 * RegimenWithinProtocolConstraint
 *
 * Evaluable rule: the proposed medication, route, and dose must fall
 * within the bounds of an approved prescribing protocol. At runtime, this
 * evaluates the proposed regimen against the protocol decision table in
 * Knowledge::DecisionModels. A regimen is within protocol if all three
 * components match an approved combination.
 *
 * Satisfies: PrescribingProtocolAdherence
 * Severity: critical
 */
export function evaluateRegimenWithinProtocol(
  inputs: {
    medicationApproved: boolean;
    routeApproved: boolean;
    doseWithinRange: boolean;
  }
): EvaluationResult {
  const outcome: EvaluationOutcome =
    (inputs.medicationApproved && inputs.routeApproved && inputs.doseWithinRange)
      ? 'pass'
      : 'fail';

  return {
    constraintName: 'RegimenWithinProtocolConstraint',
    outcome,
    severity: 'critical',
    satisfies: 'PrescribingProtocolAdherence',
    explanation: {
      ruleExpression: `medicationApproved and routeApproved and doseWithinRange`,
      humanExplanation: outcome === 'pass'
        ? 'RegimenWithinProtocolConstraint check passed.'
        : 'RegimenWithinProtocolConstraint check failed.',
      evaluatedInputs: [
        {
          name: 'medicationApproved',
          value: inputs.medicationApproved,
          source: 'derived',  // populated by evaluation engine at runtime
          derivedAt: new Date().toISOString(),
        },
        {
          name: 'routeApproved',
          value: inputs.routeApproved,
          source: 'derived',  // populated by evaluation engine at runtime
          derivedAt: new Date().toISOString(),
        },
        {
          name: 'doseWithinRange',
          value: inputs.doseWithinRange,
          source: 'derived',  // populated by evaluation engine at runtime
          derivedAt: new Date().toISOString(),
        },
      ],
    },
    evaluatedAt: new Date().toISOString(),
    subEvaluations: [],
  };
}

/**
 * BloodMonitoringIntervalConstraint
 *
 * Evaluable rule: the number of weeks since the last blood test must not
 * exceed the required monitoring interval. At runtime, weeksSinceLastTest
 * is derived from the CDR: the most recent LabResult for this patient with
 * the relevant test name. requiredIntervalWeeks comes from the prescribing
 * protocol.
 *
 * Satisfies: BloodMonitoringRequired
 * Severity: warning
 */
export function evaluateBloodMonitoringInterval(
  inputs: {
    weeksSinceLastTest: number;
    requiredIntervalWeeks: number;
  }
): EvaluationResult {
  const outcome: EvaluationOutcome =
    (inputs.weeksSinceLastTest <= inputs.requiredIntervalWeeks)
      ? 'pass'
      : 'fail';

  return {
    constraintName: 'BloodMonitoringIntervalConstraint',
    outcome,
    severity: 'warning',
    satisfies: 'BloodMonitoringRequired',
    explanation: {
      ruleExpression: `weeksSinceLastTest <= requiredIntervalWeeks`,
      humanExplanation: outcome === 'pass'
        ? 'BloodMonitoringIntervalConstraint check passed.'
        : 'BloodMonitoringIntervalConstraint check failed.',
      evaluatedInputs: [
        {
          name: 'weeksSinceLastTest',
          value: inputs.weeksSinceLastTest,
          source: 'derived',  // populated by evaluation engine at runtime
          derivedAt: new Date().toISOString(),
        },
        {
          name: 'requiredIntervalWeeks',
          value: inputs.requiredIntervalWeeks,
          source: 'derived',  // populated by evaluation engine at runtime
          derivedAt: new Date().toISOString(),
        },
      ],
    },
    evaluatedAt: new Date().toISOString(),
    subEvaluations: [],
  };
}

/**
 * DoseAdjustmentReviewedConstraint
 *
 * Evaluable rule: a clinical review must have been completed, with current
 * blood results reviewed, before a dose adjustment can be authorised. This
 * is a compound check: both the clinical review and the blood result
 * review must be complete.
 *
 * Satisfies: ClinicalReviewBeforeDoseAdjustment
 * Severity: critical
 */
export function evaluateDoseAdjustmentReviewed(
  inputs: {
    clinicalReviewCompleted: boolean;
    currentResultsReviewed: boolean;
  }
): EvaluationResult {
  const outcome: EvaluationOutcome =
    (inputs.clinicalReviewCompleted && inputs.currentResultsReviewed)
      ? 'pass'
      : 'fail';

  return {
    constraintName: 'DoseAdjustmentReviewedConstraint',
    outcome,
    severity: 'critical',
    satisfies: 'ClinicalReviewBeforeDoseAdjustment',
    explanation: {
      ruleExpression: `clinicalReviewCompleted and currentResultsReviewed`,
      humanExplanation: outcome === 'pass'
        ? 'DoseAdjustmentReviewedConstraint check passed.'
        : 'DoseAdjustmentReviewedConstraint check failed.',
      evaluatedInputs: [
        {
          name: 'clinicalReviewCompleted',
          value: inputs.clinicalReviewCompleted,
          source: 'derived',  // populated by evaluation engine at runtime
          derivedAt: new Date().toISOString(),
        },
        {
          name: 'currentResultsReviewed',
          value: inputs.currentResultsReviewed,
          source: 'derived',  // populated by evaluation engine at runtime
          derivedAt: new Date().toISOString(),
        },
      ],
    },
    evaluatedAt: new Date().toISOString(),
    subEvaluations: [],
  };
}

/**
 * SharedCareAcceptedConstraint
 *
 * Evaluable rule: shared care must not commence until the GP practice has
 * confirmed acceptance of the shared care arrangement and the shared care
 * protocol document has been sent. At runtime, both inputs are derived
 * from the Referral lifecycle state (referralAccepted) and a document-sent
 * event in the CDR.
 *
 * Satisfies: SharedCareCommunication
 * Severity: critical
 */
export function evaluateSharedCareAccepted(
  inputs: {
    sharedCareProtocolSent: boolean;
    gpPracticeAccepted: boolean;
  }
): EvaluationResult {
  const outcome: EvaluationOutcome =
    (inputs.sharedCareProtocolSent && inputs.gpPracticeAccepted)
      ? 'pass'
      : 'fail';

  return {
    constraintName: 'SharedCareAcceptedConstraint',
    outcome,
    severity: 'critical',
    satisfies: 'SharedCareCommunication',
    explanation: {
      ruleExpression: `sharedCareProtocolSent and gpPracticeAccepted`,
      humanExplanation: outcome === 'pass'
        ? 'SharedCareAcceptedConstraint check passed.'
        : 'SharedCareAcceptedConstraint check failed.',
      evaluatedInputs: [
        {
          name: 'sharedCareProtocolSent',
          value: inputs.sharedCareProtocolSent,
          source: 'derived',  // populated by evaluation engine at runtime
          derivedAt: new Date().toISOString(),
        },
        {
          name: 'gpPracticeAccepted',
          value: inputs.gpPracticeAccepted,
          source: 'derived',  // populated by evaluation engine at runtime
          derivedAt: new Date().toISOString(),
        },
      ],
    },
    evaluatedAt: new Date().toISOString(),
    subEvaluations: [],
  };
}

// ---------------------------------------------------------------
// Evaluator function registry
// ---------------------------------------------------------------

export const constraintEvaluators: Record<string, (inputs: any) => EvaluationResult> = {
  'ConsentRecordedConstraint': evaluateConsentRecorded,
  'PatientInformationProvidedConstraint': evaluatePatientInformationProvided,
  'BaselineBloodsReviewedConstraint': evaluateBaselineBloodsReviewed,
  'ClinicalReviewCompletedConstraint': evaluateClinicalReviewCompleted,
  'RegimenWithinProtocolConstraint': evaluateRegimenWithinProtocol,
  'BloodMonitoringIntervalConstraint': evaluateBloodMonitoringInterval,
  'DoseAdjustmentReviewedConstraint': evaluateDoseAdjustmentReviewed,
  'SharedCareAcceptedConstraint': evaluateSharedCareAccepted,
};
