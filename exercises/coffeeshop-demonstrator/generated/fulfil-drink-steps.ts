// ============================================================
// DO NOT EDIT — Generated from CoffeeShop SysML v2 model
// Source: exercises/coffeeshop-demonstrator/model/domain/fulfil-drink-orchestration.sysml (FulfilDrinkOrchestration::FulfilDrinkWorkflow); exercises/coffeeshop-demonstrator/model/domain/order-lifecycle.sysml (OrderLifeCycle::OrderLifecycle); exercises/coffeeshop-demonstrator/model/domain/coffeeshop.sysml (CoffeeShop::Order)
// Generator: generation/temporal_workflow.py
// ============================================================

// Identity and step table of the fulfilDrink workflow. Each step's expectedMinutes
// is its @TemporalSignal timeoutMinutes, the same value the workflow's timer uses:
// these are the audit expectations. No imports.

export const fulfilDrinkWorkflowName = 'fulfilDrink';
export const fulfilDrinkTaskQueue = 'coffeeshop';
export const fulfilDrinkStateQuery = 'orderState';

export const fulfilDrinkSignals = ['baristaStarted', 'drinkReady', 'drinkCollected'] as const;
export type FulfilDrinkSignal = (typeof fulfilDrinkSignals)[number];

export const fulfilDrinkStepIds = ['validateOrder', 'waitBaristaStart', 'prepareDrink', 'waitDrinkReady', 'waitCollected', 'completeOrder'] as const;
export type FulfilDrinkStepId = (typeof fulfilDrinkStepIds)[number];

export interface FulfilDrinkStep {
  readonly stepId: FulfilDrinkStepId;
  readonly type: 'activity' | 'signal';
  /** The activityName or signalName, as it appears in the Temporal event history. */
  readonly temporalName: string;
  /** @TemporalSignal timeoutMinutes; null where the model declares no timeout. */
  readonly expectedMinutes: number | null;
  /** The lifecycle event the step raises (@StateTransitionTrigger), or null. */
  readonly stateEvent: string | null;
}

export const fulfilDrinkSteps: readonly FulfilDrinkStep[] = [
  { stepId: 'validateOrder', type: 'activity', temporalName: 'validateOrder', expectedMinutes: null, stateEvent: null },
  { stepId: 'waitBaristaStart', type: 'signal', temporalName: 'baristaStarted', expectedMinutes: 30, stateEvent: 'PreparationStarted' },
  { stepId: 'prepareDrink', type: 'activity', temporalName: 'prepareDrink', expectedMinutes: null, stateEvent: null },
  { stepId: 'waitDrinkReady', type: 'signal', temporalName: 'drinkReady', expectedMinutes: 15, stateEvent: 'PreparationComplete' },
  { stepId: 'waitCollected', type: 'signal', temporalName: 'drinkCollected', expectedMinutes: 60, stateEvent: 'OrderCollected' },
  { stepId: 'completeOrder', type: 'activity', temporalName: 'completeOrder', expectedMinutes: null, stateEvent: null },
];
