/**
 * Workflow Constants — shared between Temporal and SvelteKit packages
 *
 * Since S0.2 (Session 517) every model value here comes from the generated
 * files in ../../../generated (imported through ./generated/, whose files
 * are links to them): the workflow name, task queue, signal names, state
 * query, the step table with its expected durations (the audit
 * expectations), and the lifecycle's next-action map. Regenerate with
 * `make gen` from the repository root; never edit the generated files.
 *
 * The audit step display labels below are hand-written: exception A3-001
 * in generation/A3-EXCEPTIONS.md at the repository root. anonymiseCaseRef
 * is application logic, not model content.
 */

import {
  fulfilDrinkSignals,
  fulfilDrinkStateQuery,
  fulfilDrinkSteps,
  fulfilDrinkTaskQueue,
  fulfilDrinkWorkflowName,
  type FulfilDrinkSignal,
  type FulfilDrinkStep,
  type FulfilDrinkStepId,
} from './generated/fulfil-drink-steps.js';

// -- Workflow identity (generated) --

export const TASK_QUEUE = fulfilDrinkTaskQueue;

/** The workflow function name, used with client.workflow.start(). */
export const WORKFLOW_NAME = fulfilDrinkWorkflowName;

/** All valid signal names, for runtime validation in API routes. */
export const VALID_SIGNALS = fulfilDrinkSignals;

export type SignalName = FulfilDrinkSignal;

/** Query the current order lifecycle state. */
export const QUERY_ORDER_STATE = fulfilDrinkStateQuery;

// -- Next actions per lifecycle state (generated) --
// For each state, the actions its outgoing transitions offer, with the
// label from the model and the signal that raises the event (or null).

export {
  orderLifecycleNextActions as STATE_NEXT_ACTIONS,
  type OrderLifecycleNextAction,
} from './generated/order-lifecycle-guard.js';

// -- Workflow step definitions for audit reporting --

export interface WorkflowStepDef extends FulfilDrinkStep {
  /** Human-readable step name for the compliance table (hand-written, A3 exception). */
  readonly label: string;
}

/**
 * Display labels for the audit table. Hand-written: the model has no label
 * annotation for orchestration steps (A3 exception). Typed by the generated
 * step ids, so a step added to or removed from the model fails compilation
 * here until its label is added or removed.
 */
const WORKFLOW_STEP_LABELS: Readonly<Record<FulfilDrinkStepId, string>> = {
  validateOrder: 'Validate Order',
  waitBaristaStart: 'Wait for Barista',
  prepareDrink: 'Prepare Drink',
  waitDrinkReady: 'Wait for Drink Ready',
  waitCollected: 'Wait for Collection',
  completeOrder: 'Complete Order',
};

/**
 * Ordered list of workflow steps as defined in the SysML
 * FulfilDrinkWorkflow action def. expectedMinutes is each signal step's
 * @TemporalSignal timeoutMinutes, the value the workflow's timer uses;
 * activity steps carry null (the model declares no expectation for them).
 */
export const WORKFLOW_STEPS: readonly WorkflowStepDef[] = fulfilDrinkSteps.map((step) => ({
  ...step,
  label: WORKFLOW_STEP_LABELS[step.stepId],
}));

// -- Anonymisation --

/**
 * Produce an anonymised case reference from a workflow/order ID.
 * Uses a simple hash to avoid exposing customer-identifiable data
 * in audit reports.
 *
 * Example: "order-1772576981645" → "CASE-A3F7"
 */
export function anonymiseCaseRef(workflowId: string): string {
  let hash = 0;
  for (let i = 0; i < workflowId.length; i++) {
    const ch = workflowId.charCodeAt(i);
    hash = ((hash << 5) - hash + ch) | 0;
  }
  const hex = Math.abs(hash).toString(16).toUpperCase().slice(0, 4).padStart(4, '0');
  return `CASE-${hex}`;
}
