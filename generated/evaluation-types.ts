// ============================================================
// DO NOT EDIT — Generated from GenderSense SysML v2 model
// Source: model/knowledge.sysml, model/foundation.sysml
// Generated: 2026-03-09T22:54:02Z
// Generator: scripts/gen_constraint_evaluator.py
// ============================================================

// ---------------------------------------------------------------
// Enum types (from Foundation::CommonTypes)
// ---------------------------------------------------------------

export type EvaluationOutcome = 'pass' | 'fail' | 'indeterminate';
export type Severity = 'critical' | 'warning' | 'informational';
export type DataSourceType = 'cdr' | 'temporal' | 'platformService' | 'entityLifecycle';
export type AssessmentScope = 'patient' | 'pathway' | 'domain' | 'system';

// ---------------------------------------------------------------
// Evaluation result structures (from Knowledge::LogicEngine)
// ---------------------------------------------------------------

export interface EvaluatedInput {
  /** Name of the input parameter. */
  name: string;
  /** The value used in evaluation (serialised). */
  value: unknown;
  /** Description of where this value came from. */
  source: string;
  /** ISO datetime when the value was derived. */
  derivedAt: string;
}

export interface ExplanationTrace {
  /** The rule expression as evaluated. */
  ruleExpression: string;
  /** Human-readable explanation of the outcome. */
  humanExplanation: string;
  /** All inputs used in the evaluation. */
  evaluatedInputs: EvaluatedInput[];
}

export interface EvaluationResult {
  /** Name of the constraint that was evaluated. */
  constraintName: string;
  /** Evaluation outcome. */
  outcome: EvaluationOutcome;
  /** Severity level of this constraint. */
  severity: Severity;
  /** Name of the requirement this constraint satisfies. */
  satisfies: string;
  /** Full explanation trace. */
  explanation: ExplanationTrace;
  /** ISO datetime when the evaluation was performed. */
  evaluatedAt: string;
  /** Sub-evaluations for compound constraints. */
  subEvaluations: EvaluationResult[];
}

// ---------------------------------------------------------------
// Evaluation specification structures (from Knowledge::CDS)
// ---------------------------------------------------------------

export interface InputDerivation {
  /** Name of the input to derive. */
  inputName: string;
  /** Type of data source (cdr, temporal, platformService, entityLifecycle). */
  sourceType: DataSourceType;
  /** Query to execute against the source (AQL, API call, etc.). */
  query: string;
  /** Computation to derive the typed input value from query results. */
  computation: string;
  /** Outcome if the query fails or returns no data. */
  fallbackOutcome: EvaluationOutcome;
  /** Reason for the fallback. */
  fallbackReason: string;
}

export interface ConstraintEvaluationSpec {
  /** Name of the constraint this spec binds to. */
  constraintName: string;
  /** Name of the requirement this constraint satisfies. */
  requirementName: string;
  /** Severity level. */
  severity: Severity;
  /** How to derive each input from authoritative sources. */
  inputDerivations: InputDerivation[];
}
