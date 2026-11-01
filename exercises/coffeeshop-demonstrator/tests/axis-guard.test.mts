// Cafe axis guard refusal check (Plan B Stage 0, S0.4, test path 4).
//
// Runs the committed, generated guard (../generated/axis-guard.ts) with
// Node's built-in test runner and TypeScript type stripping (Node 23.6+).
// Run from the repository root with `make gen-test-guard` or `make gen-test`.
// Hand-written: a test of the Cafe's generated output (A3-002). Replaces
// order-lifecycle-guard.test.mts, which tested the retired state definition.

import { test } from 'node:test';
import assert from 'node:assert/strict';

import {
  axisSpecs,
  checkOrderLifecycleMove,
  checkOrderLinePreparationMove,
  checkOrderPaymentMove,
  orderLifecycleAxis,
  orderLifecycleNextActions,
  orderLinePreparationAxis,
  orderLinePreparationNextActions,
  traceOrderLinePreparationMove,
  type AxisMoveResult,
} from '../generated/axis-guard.ts';

function assertRejected(r: AxisMoveResult, code: string): void {
  assert.equal(r.ok, false, JSON.stringify(r));
  if (r.ok) return;
  assert.equal(r.code, code);
  assert.ok(r.reason.length > 0, 'a rejection carries a reason');
  assert.ok(!('value' in r), 'a rejection is not an unchanged value');
}

test('refuses a forbidden lifecycle move: ready -> inPreparation', () => {
  for (const authority of ['operatorSide', 'systemSide']) {
    const r = checkOrderLifecycleMove({ from: 'ready', to: 'inPreparation', authority });
    assertRejected(r, 'moveNotPermitted');
    if (!r.ok) assert.deepEqual(r.permitted.map((m) => m.to), ['collected']);
  }
  // No cancellation from ready (H-0498).
  assertRejected(checkOrderLifecycleMove({ from: 'ready', to: 'cancelled', authority: 'operatorSide' }), 'moveNotPermitted');
});

test('refuses a move from a terminal value, including a line moving out of cancelled', () => {
  for (const to of orderLinePreparationAxis.values) {
    for (const authority of ['operatorSide', 'systemSide']) {
      assertRejected(checkOrderLinePreparationMove({ from: 'cancelled', to, authority }), 'fromTerminalValue');
      assertRejected(checkOrderLinePreparationMove({ from: 'collected', to, authority }), 'fromTerminalValue');
    }
  }
  assertRejected(traceOrderLinePreparationMove('cancelled', 'LinePreparationStarted'), 'fromTerminalValue');
  for (const from of orderLifecycleAxis.terminalValues) {
    assertRejected(checkOrderLifecycleMove({ from, to: 'placed', authority: 'systemSide' }), 'fromTerminalValue');
  }
  assert.deepEqual(orderLinePreparationAxis.terminalValues, ['collected', 'cancelled']);
  assertRejected(checkOrderPaymentMove({ from: 'paid', to: 'unpaid', authority: 'operatorSide' }), 'fromTerminalValue');
});

test('refuses a move by an authority the axis does not name', () => {
  // The order's ready move is MRB's (systemSide), never written directly at the counter.
  assertRejected(checkOrderLifecycleMove({ from: 'inPreparation', to: 'ready', authority: 'operatorSide' }), 'authorityNotNamed');
  // Payment is taken at the till (operatorSide), not by the customer or the system.
  assertRejected(checkOrderPaymentMove({ from: 'unpaid', to: 'paid', authority: 'customerSide' }), 'authorityNotNamed');
  assertRejected(checkOrderPaymentMove({ from: 'unpaid', to: 'paid', authority: 'systemSide' }), 'authorityNotNamed');
  // A line is cancelled only with its order, by MRB.
  assertRejected(checkOrderLinePreparationMove({ from: 'queued', to: 'cancelled', authority: 'operatorSide' }), 'authorityNotNamed');
});

test('accepts the declared moves, with their events and preconditions', () => {
  const start = checkOrderLinePreparationMove({ from: 'queued', event: 'LinePreparationStarted', authority: 'operatorSide' });
  assert.equal(start.ok, true);
  if (start.ok) {
    assert.equal(start.to, 'inPreparation');
    assert.deepEqual(start.preconditions, ['orderPaid']);
  }
  const cancel = checkOrderLifecycleMove({ from: 'inPreparation', event: 'CancellationRequested', authority: 'operatorSide' });
  assert.equal(cancel.ok, true);
  assert.equal(checkOrderPaymentMove({ from: 'unpaid', to: 'paid', authority: 'operatorSide' }).ok, true);
  assert.deepEqual(Object.keys(axisSpecs), ['OrderLine', 'Order']);
  assert.deepEqual(Object.keys(axisSpecs.Order ?? {}), ['lifecycle', 'payment']);
});

test('next actions offer only operator moves, labelled from the model', () => {
  assert.deepEqual(
    orderLinePreparationNextActions.queued.map((a) => [a.event, a.label, a.signal]),
    [['LinePreparationStarted', 'Barista: Start Preparation', 'baristaStarted']],
  );
  assert.deepEqual(orderLinePreparationNextActions.ready.map((a) => a.event), ['LineCollected']);
  assert.deepEqual(orderLinePreparationNextActions.cancelled, []);
  // The order's derived moves (MRB) are never offered; only the counter's cancel is.
  assert.deepEqual(orderLifecycleNextActions.placed.map((a) => [a.event, a.label]), [['CancellationRequested', 'Cancel Order']]);
  assert.deepEqual(orderLifecycleNextActions.ready, []);
});
