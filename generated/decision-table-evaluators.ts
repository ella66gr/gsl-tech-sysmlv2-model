// ============================================================
// DO NOT EDIT — Generated from GenderSense SysML v2 model
// Source: model/knowledge.sysml (Knowledge::DecisionModels)
// Generated: 2026-03-09T23:02:59Z
// Generator: scripts/gen_decision_table_evaluator.py
// ============================================================

import type { EvaluationResult, EvaluationOutcome } from './evaluation-types';

// ---------------------------------------------------------------
// RegimenSelection Decision Table
//
// Maps baseline hormones, patient preference, and contraindications to recommended regimen
// Hit policy: unique
// Rows: 9
// ---------------------------------------------------------------

export interface RegimenSelectionInput {
  baselineTestosterone: HormoneLevel;
  baselineOestradiol: HormoneLevel;
  therapyPreference: TherapyPreference;
  contraindication: ContraindicationCategory;
}

export interface RegimenSelectionOutput {
  medication: HormoneMedication;
  administrationRoute: AdministrationRoute;
  startingDose: DoseCategory;
}

export type RegimenSelectionRow = RegimenSelectionInput & RegimenSelectionOutput;

const regimenSelectionRows: RegimenSelectionRow[] = [
  // row01: Oestrogen preference, no contraindications, low baseline — standard transdermal ...
  {
    baselineTestosterone: 'normal',
    baselineOestradiol: 'low',
    therapyPreference: 'oestrogen',
    contraindication: 'noContraindication',
    medication: 'estradiolPatch',
    administrationRoute: 'transdermal',
    startingDose: 'standardDose',
  },
  // row02: Oestrogen preference, VTE risk — transdermal preferred over oral to avoid first-...
  {
    baselineTestosterone: 'normal',
    baselineOestradiol: 'low',
    therapyPreference: 'oestrogen',
    contraindication: 'vteRisk',
    medication: 'estradiolPatch',
    administrationRoute: 'transdermal',
    startingDose: 'reduced',
  },
  // row03: Oestrogen preference, liver disease — transdermal to bypass hepatic metabolism.
  {
    baselineTestosterone: 'normal',
    baselineOestradiol: 'low',
    therapyPreference: 'oestrogen',
    contraindication: 'liverDisease',
    medication: 'estradiolGel',
    administrationRoute: 'transdermal',
    startingDose: 'reduced',
  },
  // row04: Oestrogen preference, cardiac risk — transdermal, low starting dose with close m...
  {
    baselineTestosterone: 'normal',
    baselineOestradiol: 'low',
    therapyPreference: 'oestrogen',
    contraindication: 'cardiacRisk',
    medication: 'estradiolPatch',
    administrationRoute: 'transdermal',
    startingDose: 'low',
  },
  // row05: Oestrogen preference, multiple contraindications — requires specialist review. L...
  {
    baselineTestosterone: 'normal',
    baselineOestradiol: 'low',
    therapyPreference: 'oestrogen',
    contraindication: 'multiple',
    medication: 'estradiolGel',
    administrationRoute: 'transdermal',
    startingDose: 'low',
  },
  // row06: Testosterone preference, no contraindications — standard IM injection.
  {
    baselineTestosterone: 'low',
    baselineOestradiol: 'normal',
    therapyPreference: 'testosterone',
    contraindication: 'noContraindication',
    medication: 'testosteroneUndecanoate',
    administrationRoute: 'intramuscular',
    startingDose: 'standardDose',
  },
  // row07: Testosterone preference, needle aversion or patient preference for self-administ...
  {
    baselineTestosterone: 'low',
    baselineOestradiol: 'high',
    therapyPreference: 'testosterone',
    contraindication: 'noContraindication',
    medication: 'testosteroneGel',
    administrationRoute: 'transdermal',
    startingDose: 'standardDose',
  },
  // row08: Testosterone preference, cardiac risk — gel preferred over injection for more st...
  {
    baselineTestosterone: 'low',
    baselineOestradiol: 'normal',
    therapyPreference: 'testosterone',
    contraindication: 'cardiacRisk',
    medication: 'testosteroneGel',
    administrationRoute: 'transdermal',
    startingDose: 'reduced',
  },
  // row09: Testosterone preference, liver disease — transdermal to avoid hepatic first-pass...
  {
    baselineTestosterone: 'low',
    baselineOestradiol: 'normal',
    therapyPreference: 'testosterone',
    contraindication: 'liverDisease',
    medication: 'testosteroneGel',
    administrationRoute: 'transdermal',
    startingDose: 'standardDose',
  },
];

/**
 * Look up the regimenSelection decision table.
 *
 * Hit policy: unique.
 * Returns the single matching row's outputs, or null if no match.
 */
export function lookupRegimenSelection(
  input: RegimenSelectionInput
): RegimenSelectionOutput | null {
  const match = regimenSelectionRows.find(
    row =>
      row.baselineTestosterone === input.baselineTestosterone &&
      row.baselineOestradiol === input.baselineOestradiol &&
      row.therapyPreference === input.therapyPreference &&
      row.contraindication === input.contraindication
  );

  if (!match) return null;

  return {
    medication: match.medication,
    administrationRoute: match.administrationRoute,
    startingDose: match.startingDose,
  };
}

/**
 * Evaluate the regimenSelection decision table and produce an EvaluationResult.
 */
export function evaluateRegimenSelection(
  input: RegimenSelectionInput
): EvaluationResult {
  const result = lookupRegimenSelection(input);
  const outcome: EvaluationOutcome = result ? 'pass' : 'indeterminate';

  return {
    constraintName: 'regimenSelection',
    outcome,
    severity: 'informational',
    satisfies: '',
    explanation: {
      ruleExpression: 'regimenSelection table lookup',
      humanExplanation: result
        ? `Matched regimenSelection table row.`
        : `No matching row found in regimenSelection table.`,
      evaluatedInputs: [
        {
          name: 'baselineTestosterone',
          value: input.baselineTestosterone,
          source: 'derived',
          derivedAt: new Date().toISOString(),
        },
        {
          name: 'baselineOestradiol',
          value: input.baselineOestradiol,
          source: 'derived',
          derivedAt: new Date().toISOString(),
        },
        {
          name: 'therapyPreference',
          value: input.therapyPreference,
          source: 'derived',
          derivedAt: new Date().toISOString(),
        },
        {
          name: 'contraindication',
          value: input.contraindication,
          source: 'derived',
          derivedAt: new Date().toISOString(),
        },
      ],
    },
    evaluatedAt: new Date().toISOString(),
    subEvaluations: [],
  };
}

// ---------------------------------------------------------------
// StabilityAssessment Decision Table
//
// Maps monitoring indicators to stability classification and monitoring action
// Hit policy: unique
// Rows: 8
// ---------------------------------------------------------------

export interface StabilityAssessmentInput {
  hormoneLevel: HormoneLevel;
  minimumWeeksOnTreatment: number;
  sideEffectSeverity: Severity;
  satisfaction: PatientSatisfaction;
}

export interface StabilityAssessmentOutput {
  classification: StabilityClassification;
  monitoringAction: MonitoringAction;
}

export type StabilityAssessmentRow = StabilityAssessmentInput & StabilityAssessmentOutput;

const stabilityAssessmentRows: StabilityAssessmentRow[] = [
  // row01: Normal hormones, 12+ weeks, no significant side effects, patient satisfied — sta...
  {
    hormoneLevel: 'normal',
    minimumWeeksOnTreatment: 12,
    sideEffectSeverity: 'informational',
    satisfaction: 'satisfied',
    classification: 'stable',
    monitoringAction: 'continueCurrentRegimen',
  },
  // row02: Normal hormones, 12+ weeks, no significant side effects, patient neutral — stabl...
  {
    hormoneLevel: 'normal',
    minimumWeeksOnTreatment: 12,
    sideEffectSeverity: 'informational',
    satisfaction: 'neutral',
    classification: 'stable',
    monitoringAction: 'reduceMonitoringInterval',
  },
  // row03: Normal hormones but less than 12 weeks on treatment — too early to declare stabl...
  {
    hormoneLevel: 'normal',
    minimumWeeksOnTreatment: 0,
    sideEffectSeverity: 'informational',
    satisfaction: 'satisfied',
    classification: 'improving',
    monitoringAction: 'continueCurrentRegimen',
  },
  // row04: Low hormone levels — dose likely insufficient. Adjust dose upward.
  {
    hormoneLevel: 'low',
    minimumWeeksOnTreatment: 12,
    sideEffectSeverity: 'informational',
    satisfaction: 'dissatisfied',
    classification: 'adjustmentNeeded',
    monitoringAction: 'adjustDose',
  },
  // row05: High hormone levels — dose may need reducing. Adjust dose downward.
  {
    hormoneLevel: 'high',
    minimumWeeksOnTreatment: 12,
    sideEffectSeverity: 'informational',
    satisfaction: 'satisfied',
    classification: 'adjustmentNeeded',
    monitoringAction: 'adjustDose',
  },
  // row06: Normal hormones but warning-level side effects — may need route or formulation c...
  {
    hormoneLevel: 'normal',
    minimumWeeksOnTreatment: 0,
    sideEffectSeverity: 'warning',
    satisfaction: 'dissatisfied',
    classification: 'adjustmentNeeded',
    monitoringAction: 'increaseMonitoringInterval',
  },
  // row07: Critical side effects regardless of hormone levels — urgent clinical review.
  {
    hormoneLevel: 'normal',
    minimumWeeksOnTreatment: 0,
    sideEffectSeverity: 'critical',
    satisfaction: 'dissatisfied',
    classification: 'concerning',
    monitoringAction: 'clinicalReviewUrgent',
  },
  // row08: Suppressed hormone levels — possible over- suppression. Urgent review to assess ...
  {
    hormoneLevel: 'suppressed',
    minimumWeeksOnTreatment: 0,
    sideEffectSeverity: 'informational',
    satisfaction: 'neutral',
    classification: 'concerning',
    monitoringAction: 'clinicalReviewUrgent',
  },
];

/**
 * Look up the stabilityAssessment decision table.
 *
 * Hit policy: unique.
 * Returns the single matching row's outputs, or null if no match.
 */
export function lookupStabilityAssessment(
  input: StabilityAssessmentInput
): StabilityAssessmentOutput | null {
  const match = stabilityAssessmentRows.find(
    row =>
      row.hormoneLevel === input.hormoneLevel &&
      input.minimumWeeksOnTreatment >= row.minimumWeeksOnTreatment &&
      row.sideEffectSeverity === input.sideEffectSeverity &&
      row.satisfaction === input.satisfaction
  );

  if (!match) return null;

  return {
    classification: match.classification,
    monitoringAction: match.monitoringAction,
  };
}

/**
 * Evaluate the stabilityAssessment decision table and produce an EvaluationResult.
 */
export function evaluateStabilityAssessment(
  input: StabilityAssessmentInput
): EvaluationResult {
  const result = lookupStabilityAssessment(input);
  const outcome: EvaluationOutcome = result ? 'pass' : 'indeterminate';

  return {
    constraintName: 'stabilityAssessment',
    outcome,
    severity: 'informational',
    satisfies: '',
    explanation: {
      ruleExpression: 'stabilityAssessment table lookup',
      humanExplanation: result
        ? `Matched stabilityAssessment table row.`
        : `No matching row found in stabilityAssessment table.`,
      evaluatedInputs: [
        {
          name: 'hormoneLevel',
          value: input.hormoneLevel,
          source: 'derived',
          derivedAt: new Date().toISOString(),
        },
        {
          name: 'minimumWeeksOnTreatment',
          value: input.minimumWeeksOnTreatment,
          source: 'derived',
          derivedAt: new Date().toISOString(),
        },
        {
          name: 'sideEffectSeverity',
          value: input.sideEffectSeverity,
          source: 'derived',
          derivedAt: new Date().toISOString(),
        },
        {
          name: 'satisfaction',
          value: input.satisfaction,
          source: 'derived',
          derivedAt: new Date().toISOString(),
        },
      ],
    },
    evaluatedAt: new Date().toISOString(),
    subEvaluations: [],
  };
}

// ---------------------------------------------------------------
// Decision table evaluator registry
// ---------------------------------------------------------------

export const decisionTableEvaluators: Record<string, (input: any) => EvaluationResult> = {
  'regimenSelection': evaluateRegimenSelection,
  'stabilityAssessment': evaluateStabilityAssessment,
};
