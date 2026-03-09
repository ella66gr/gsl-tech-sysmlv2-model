// ============================================================
// DO NOT EDIT — Generated from GenderSense SysML v2 model
// Source: model/knowledge.sysml (Knowledge::ClinicalDecisionSupport)
// Generated: 2026-03-09T22:54:02Z
// Generator: scripts/gen_constraint_evaluator.py
// ============================================================

import type { ConstraintEvaluationSpec, Severity } from './evaluation-types';

// ---------------------------------------------------------------
// Constraint evaluation spec registry
//
// One entry per ConstraintEvaluationSpec part usage in CDS.
// Input derivation detail is in doc blocks — not yet
// machine-parseable. inputDerivations arrays are placeholders.
// ---------------------------------------------------------------

export const constraintSpecs: Record<string, ConstraintEvaluationSpec> = {
  /** Evaluation spec for ConsentRecordedConstraint. Single CDR input: consent composi... */
  'ConsentRecordedConstraint': {
    constraintName: 'ConsentRecordedConstraint',
    requirementName: 'ConsentBeforeTreatment',
    severity: 'critical',
    inputDerivations: [],  // TODO: populate when nested :>> syntax is verified
  },

  /** Evaluation spec for PatientInformationProvidedConstraint. Single CDR input: info... */
  'PatientInformationProvidedConstraint': {
    constraintName: 'PatientInformationProvidedConstraint',
    requirementName: 'InformedConsentRequiresInformation',
    severity: 'critical',
    inputDerivations: [],  // TODO: populate when nested :>> syntax is verified
  },

  /** Evaluation spec for BaselineBloodsReviewedConstraint. Two inputs from CDR/entity... */
  'BaselineBloodsReviewedConstraint': {
    constraintName: 'BaselineBloodsReviewedConstraint',
    requirementName: 'BaselineInvestigationsBeforePrescribing',
    severity: 'critical',
    inputDerivations: [],  // TODO: populate when nested :>> syntax is verified
  },

  /** Evaluation spec for ClinicalReviewCompletedConstraint. Single CDR input: consult... */
  'ClinicalReviewCompletedConstraint': {
    constraintName: 'ClinicalReviewCompletedConstraint',
    requirementName: 'ClinicalReviewBeforePrescribing',
    severity: 'critical',
    inputDerivations: [],  // TODO: populate when nested :>> syntax is verified
  },

  /** Evaluation spec for RegimenWithinProtocolConstraint. Three inputs: medication, r... */
  'RegimenWithinProtocolConstraint': {
    constraintName: 'RegimenWithinProtocolConstraint',
    requirementName: 'PrescribingProtocolAdherence',
    severity: 'critical',
    inputDerivations: [],  // TODO: populate when nested :>> syntax is verified
  },

  /** Evaluation spec for BloodMonitoringIntervalConstraint. Two inputs: weeksSinceLas... */
  'BloodMonitoringIntervalConstraint': {
    constraintName: 'BloodMonitoringIntervalConstraint',
    requirementName: 'BloodMonitoringRequired',
    severity: 'warning',
    inputDerivations: [],  // TODO: populate when nested :>> syntax is verified
  },

  /** Evaluation spec for DoseAdjustmentReviewedConstraint. Two CDR inputs: clinical r... */
  'DoseAdjustmentReviewedConstraint': {
    constraintName: 'DoseAdjustmentReviewedConstraint',
    requirementName: 'ClinicalReviewBeforeDoseAdjustment',
    severity: 'critical',
    inputDerivations: [],  // TODO: populate when nested :>> syntax is verified
  },

  /** Evaluation spec for SharedCareAcceptedConstraint. Two inputs: shared care protoc... */
  'SharedCareAcceptedConstraint': {
    constraintName: 'SharedCareAcceptedConstraint',
    requirementName: 'SharedCareCommunication',
    severity: 'critical',
    inputDerivations: [],  // TODO: populate when nested :>> syntax is verified
  },

};

// ---------------------------------------------------------------
// Decision table evaluation spec registry
// ---------------------------------------------------------------

export interface DecisionTableEvaluationSpec {
  tableName: string;
  description: string;
}

export const decisionTableSpecs: Record<string, DecisionTableEvaluationSpec> = {
  'regimenSelection': {
    tableName: 'regimenSelection',
    description: 'Derives inputs for regimen selection from baseline bloods and assessment',
  },
  'stabilityAssessment': {
    tableName: 'stabilityAssessment',
    description: 'Derives inputs for stability assessment from monitoring data and consultation',
  },
};
