// ============================================================
// DO NOT EDIT — Generated from CoffeeShop SysML v2 model
// Source: exercises/coffeeshop-demonstrator/model/domain/fulfil-drink-orchestration.sysml (FulfilDrinkOrchestration::FulfilDrinkWorkflow); exercises/coffeeshop-demonstrator/model/domain/coffeeshop.sysml (CoffeeShop::OrderLine)
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
import { traceOrderLinePreparationMove, orderLinePreparationDefault } from '@coffeeshop/shared/dist/generated/axis-guard.js';

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

// -- Query: the OrderLine preparation value the workflow has reached --

export const orderLinePreparationStateQuery = defineQuery<string>('orderLinePreparationState');

// -- Workflow function --

export async function fulfilDrink(orderLine: activities.OrderLine): Promise<string> {
  const ids = { workflowId: workflowInfo().workflowId };
  let state: string = orderLinePreparationDefault;

  // Raise an event on OrderLine preparation. The guard refuses a move the axis does not permit.
  const raise = (event: string): void => {
    const r = traceOrderLinePreparationMove(state, event);
    if (!r.ok) {
      throw ApplicationFailure.nonRetryable(r.reason, 'AxisMoveRejected', r);
    }
    log.info('Axis move', { ...ids, axis: r.axis, event, from: r.from, to: r.to });
    state = r.to;
  };

  setHandler(orderLinePreparationStateQuery, () => state);

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
  await validateOrder(orderLine);
  log.info('Activity completed: validateOrder', ids);

  // -- Step 2: waitBaristaStart (signal baristaStarted, timer 30 minutes) --
  log.info('Waiting for signal: baristaStarted', ids);
  if (!(await condition(() => baristaStarted, '30 minutes'))) {
    log.warn('Timer expired: waitBaristaStart, 30 minutes without baristaStarted', ids);
    await condition(() => baristaStarted);
  }
  raise('LinePreparationStarted');

  // -- Step 3: prepareDrink (activity prepareDrink) --
  await prepareDrink(orderLine);
  log.info('Activity completed: prepareDrink', ids);

  // -- Step 4: waitDrinkReady (signal drinkReady, timer 15 minutes) --
  log.info('Waiting for signal: drinkReady', ids);
  if (!(await condition(() => drinkReady, '15 minutes'))) {
    log.warn('Timer expired: waitDrinkReady, 15 minutes without drinkReady', ids);
    await condition(() => drinkReady);
  }
  raise('LinePreparationComplete');

  // -- Step 5: waitCollected (signal drinkCollected, timer 60 minutes) --
  log.info('Waiting for signal: drinkCollected', ids);
  if (!(await condition(() => drinkCollected, '60 minutes'))) {
    log.warn('Timer expired: waitCollected, 60 minutes without drinkCollected', ids);
    await condition(() => drinkCollected);
  }
  raise('LineCollected');

  // -- Step 6: completeOrder (activity completeOrder) --
  await completeOrder(orderLine);
  log.info('Activity completed: completeOrder', ids);

  return 'fulfilDrink completed';
}
