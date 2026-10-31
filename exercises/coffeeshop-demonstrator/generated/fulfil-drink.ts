// ============================================================
// DO NOT EDIT — Generated from CoffeeShop SysML v2 model
// Source: exercises/coffeeshop-demonstrator/model/domain/fulfil-drink-orchestration.sysml (FulfilDrinkOrchestration::FulfilDrinkWorkflow); exercises/coffeeshop-demonstrator/model/domain/order-lifecycle.sysml (OrderLifeCycle::OrderLifecycle); exercises/coffeeshop-demonstrator/model/domain/coffeeshop.sysml (CoffeeShop::Order)
// Generator: generation/temporal_workflow.py
// ============================================================

import {
  ApplicationFailure,
  condition,
  defineQuery,
  defineSignal,
  log,
  proxyActivities,
  setHandler,
  workflowInfo,
} from '@temporalio/workflow';

import type * as activities from '../activities/barista.js';
import { nextOrderLifecycleState, orderLifecycleInitialState, type OrderLifecycleState } from '@coffeeshop/shared/dist/generated/order-lifecycle-guard.js';

// -- Activity proxy (platform defaults: the model sets no activity timeout) --

const {
  validateOrder,
  prepareDrink,
  completeOrder,
} = proxyActivities<typeof activities>({
  startToCloseTimeout: '1 minute',
  retry: {
    maximumAttempts: 3,
  },
});

// -- Signals: one per @TemporalSignal step --

export const baristaStartedSignal = defineSignal('baristaStarted');
export const drinkReadySignal = defineSignal('drinkReady');
export const drinkCollectedSignal = defineSignal('drinkCollected');

// -- Query: the current OrderLifecycle state --

export const orderStateQuery = defineQuery<string>('orderState');

// -- Workflow function --

export async function fulfilDrink(orderDetails: activities.OrderDetails): Promise<string> {
  const ids = { workflowId: workflowInfo().workflowId };
  let state: OrderLifecycleState = orderLifecycleInitialState;

  // Raise a lifecycle event. The guard refuses an event OrderLifecycle has no transition for.
  const raise = (event: string): void => {
    const next = nextOrderLifecycleState(state, event);
    if (next === null) {
      throw ApplicationFailure.nonRetryable(
        `OrderLifecycle refuses ${event} in state ${state}`,
        'IllegalLifecycleTransition',
      );
    }
    log.info('Lifecycle transition', { ...ids, event, from: state, to: next });
    state = next;
  };

  setHandler(orderStateQuery, () => state);

  // Set by the signal handlers.
  let baristaStarted = false;
  let drinkReady = false;
  let drinkCollected = false;

  setHandler(baristaStartedSignal, () => {
    log.info('Signal received: baristaStarted', ids);
    baristaStarted = true;
  });
  setHandler(drinkReadySignal, () => {
    log.info('Signal received: drinkReady', ids);
    drinkReady = true;
  });
  setHandler(drinkCollectedSignal, () => {
    log.info('Signal received: drinkCollected', ids);
    drinkCollected = true;
  });

  log.info('Workflow started: fulfilDrink', ids);

  // -- Step 1: validateOrder (activity validateOrder) --
  await validateOrder(orderDetails);
  log.info('Activity completed: validateOrder', ids);

  // -- Step 2: waitBaristaStart (signal baristaStarted, timer 30 minutes) --
  log.info('Waiting for signal: baristaStarted', ids);
  if (!(await condition(() => baristaStarted, '30 minutes'))) {
    log.warn('Timer expired: waitBaristaStart, 30 minutes without baristaStarted', ids);
    await condition(() => baristaStarted);
  }
  raise('PreparationStarted');

  // -- Step 3: prepareDrink (activity prepareDrink) --
  await prepareDrink(orderDetails);
  log.info('Activity completed: prepareDrink', ids);

  // -- Step 4: waitDrinkReady (signal drinkReady, timer 15 minutes) --
  log.info('Waiting for signal: drinkReady', ids);
  if (!(await condition(() => drinkReady, '15 minutes'))) {
    log.warn('Timer expired: waitDrinkReady, 15 minutes without drinkReady', ids);
    await condition(() => drinkReady);
  }
  raise('PreparationComplete');

  // -- Step 5: waitCollected (signal drinkCollected, timer 60 minutes) --
  log.info('Waiting for signal: drinkCollected', ids);
  if (!(await condition(() => drinkCollected, '60 minutes'))) {
    log.warn('Timer expired: waitCollected, 60 minutes without drinkCollected', ids);
    await condition(() => drinkCollected);
  }
  raise('OrderCollected');

  // -- Step 6: completeOrder (activity completeOrder) --
  await completeOrder(orderDetails);
  log.info('Activity completed: completeOrder', ids);

  return 'fulfilDrink completed';
}
