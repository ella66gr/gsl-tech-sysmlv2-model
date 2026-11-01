// Cafe cross-axis rule check (Plan B Stage 0, S0.4, test path 5).
//
// Runs the committed, generated E6 evaluator (../generated/axis-preconditions.ts)
// on a line moving into preparation: rejected while its order is unpaid,
// accepted once it is paid. Run from the repository root with
// `make gen-test-preconditions` or `make gen-test`. Hand-written (A3-002).

import { test } from 'node:test';
import assert from 'node:assert/strict';

import { checkOrderLinePreparationMove } from '../generated/axis-guard.ts';
import {
  evaluateAxisMovePreconditions,
  evaluateOrderLinePreparationQueuedToInPreparationOrderPaid,
} from '../generated/axis-preconditions.ts';

function startLine(payment: string | null) {
  const move = checkOrderLinePreparationMove({ from: 'queued', event: 'LinePreparationStarted', authority: 'operatorSide' });
  assert.equal(move.ok, true);
  if (!move.ok) throw new Error('guard refused a declared move');
  const order = payment === null ? undefined : { lifecycle: 'placed', payment };
  return evaluateAxisMovePreconditions(move.type, move.axis, move.transition, {
    self: { preparation: 'queued' },
    related: { order },
  });
}

test('a line cannot start preparation while its order is unpaid', () => {
  const v = startLine('unpaid');
  assert.equal(v.ok, false);
  if (v.ok) return;
  assert.equal(v.code, 'preconditionNotMet');
  assert.deepEqual(v.reasons, ['The order is not paid. A line cannot start preparation until its order is paid.']);
  assert.equal(v.results[0]?.actualValue, 'unpaid');
  assert.equal(v.results[0]?.relatedType, 'Order');
});

test('a line can start preparation once its order is paid', () => {
  const v = startLine('paid');
  assert.equal(v.ok, true);
  assert.equal(evaluateOrderLinePreparationQueuedToInPreparationOrderPaid({ self: {}, related: { order: { payment: 'paid' } } }).outcome, 'pass');
});

test('an order whose payment is not known is refused, not passed', () => {
  const v = startLine(null);
  assert.equal(v.ok, false);
  if (!v.ok) assert.equal(v.results[0]?.outcome, 'indeterminate');
});

test('moves without preconditions pass', () => {
  const v = evaluateAxisMovePreconditions('OrderLine', 'preparation', 'inPreparationToReady', { self: { preparation: 'inPreparation' } });
  assert.equal(v.ok, true);
});
