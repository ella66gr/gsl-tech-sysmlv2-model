// Cafe lifecycle guard refusal check (Plan B Stage 0, S0.2, test path 5).
//
// Runs the committed, generated guard (../generated/order-lifecycle-guard.ts)
// with Node's built-in test runner and TypeScript type stripping (Node 23.6+).
// Run from the repository root with `make gen-test`. Hand-written: it is a
// test of the Cafe's generated output, not generated output itself.

import { test } from 'node:test';
import assert from 'node:assert/strict';

import {
  isOrderLifecycleTerminal,
  isOrderLifecycleTransitionLegal,
  nextOrderLifecycleState,
  orderLifecycleEvents,
  orderLifecycleNextActions,
  orderLifecycleTerminalStates,
  orderLifecycleTransitions,
} from '../generated/order-lifecycle-guard.ts';

test('refuses the illegal transition ready -> inPreparation', () => {
  assert.equal(isOrderLifecycleTransitionLegal('ready', 'inPreparation'), false);
  for (const event of orderLifecycleEvents) {
    assert.notEqual(nextOrderLifecycleState('ready', event), 'inPreparation', `event ${event} from ready`);
  }
  assert.equal(nextOrderLifecycleState('ready', 'PreparationStarted'), null);
});

test('refuses every event in a terminal state', () => {
  assert.ok(orderLifecycleTerminalStates.length > 0);
  for (const state of orderLifecycleTerminalStates) {
    assert.equal(isOrderLifecycleTerminal(state), true);
    for (const event of orderLifecycleEvents) {
      assert.equal(nextOrderLifecycleState(state, event), null, `${event} in terminal state ${state}`);
    }
    assert.deepEqual(orderLifecycleNextActions[state], []);
  }
  assert.equal(nextOrderLifecycleState('collected', 'CancellationRequested'), null);
});

test('accepts the modelled path, including cancellation', () => {
  assert.equal(nextOrderLifecycleState('placed', 'PreparationStarted'), 'inPreparation');
  assert.equal(nextOrderLifecycleState('inPreparation', 'PreparationComplete'), 'ready');
  assert.equal(nextOrderLifecycleState('ready', 'OrderCollected'), 'collected');
  assert.equal(nextOrderLifecycleState('placed', 'CancellationRequested'), 'cancelled');
  assert.equal(nextOrderLifecycleState('inPreparation', 'CancellationRequested'), 'cancelled');
  assert.ok(orderLifecycleTransitions.some((t) => t.target === 'cancelled'));
});

test('offers next actions from each state\'s outgoing transitions', () => {
  const placed = orderLifecycleNextActions.placed.map((a) => a.event);
  assert.deepEqual(placed, ['PreparationStarted', 'CancellationRequested']);
  for (const [state, actions] of Object.entries(orderLifecycleNextActions)) {
    for (const action of actions) {
      assert.ok(action.label.length > 0, `label for ${action.event} from ${state}`);
      assert.equal(nextOrderLifecycleState(state, action.event), action.target);
    }
  }
});
