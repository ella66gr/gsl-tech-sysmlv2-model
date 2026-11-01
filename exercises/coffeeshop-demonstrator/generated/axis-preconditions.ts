// ============================================================
// DO NOT EDIT — Generated from CoffeeShop SysML v2 model
// Source: exercises/coffeeshop-demonstrator/model/domain/coffeeshop.sysml (CoffeeShop::OrderLine)
// Generator: generation/constraint_evaluator.py
// ============================================================

// Cross-axis precondition evaluators (E6), from the AxisPrecondition declarations.
// No imports: usable from any runtime. The guard (axis-guard.ts) decides whether a
// move is permitted at all; these decide whether its preconditions hold.

export type AxisPreconditionOutcome = 'pass' | 'fail' | 'indeterminate';

/**
 * The axis values an evaluator reads: the moving instance's own axis tuple,
 * and each related instance's axis tuple by the name of the reference to it.
 */
export interface AxisPreconditionContext {
  readonly self: Readonly<Record<string, string>>;
  readonly related?: Readonly<Record<string, Readonly<Record<string, string>> | null | undefined>>;
}

export interface AxisPreconditionResult {
  readonly precondition: string;
  readonly type: string;
  readonly axis: string;
  readonly transition: string;
  /** The reference to the related instance; null for the same instance. */
  readonly relatedVia: string | null;
  /** The type whose axis is read. */
  readonly relatedType: string;
  readonly requiredAxis: string;
  readonly requiredValues: readonly string[];
  /** The value found, or null when it was not supplied. */
  readonly actualValue: string | null;
  readonly outcome: AxisPreconditionOutcome;
  /** The model's rejectionReason when the outcome is not pass; null on pass. */
  readonly reason: string | null;
}

export interface AxisPreconditionRejection {
  readonly ok: false;
  readonly code: 'preconditionNotMet';
  readonly type: string;
  readonly axis: string;
  readonly transition: string;
  /** The rejectionReason of every precondition that did not pass. */
  readonly reasons: readonly string[];
  readonly results: readonly AxisPreconditionResult[];
}

export type AxisPreconditionVerdict =
  | { readonly ok: true; readonly type: string; readonly axis: string; readonly transition: string; readonly results: readonly AxisPreconditionResult[] }
  | AxisPreconditionRejection;

interface PreconditionDecl {
  readonly precondition: string;
  readonly type: string;
  readonly axis: string;
  readonly transition: string;
  readonly relatedVia: string | null;
  readonly relatedType: string;
  readonly requiredAxis: string;
  readonly requiredValues: readonly string[];
  readonly rejectionReason: string;
}

function evaluate(d: PreconditionDecl, ctx: AxisPreconditionContext): AxisPreconditionResult {
  const tuple = d.relatedVia === null ? ctx.self : ctx.related?.[d.relatedVia];
  const actual = tuple?.[d.requiredAxis];
  const actualValue = typeof actual === 'string' ? actual : null;
  const outcome: AxisPreconditionOutcome =
    actualValue === null ? 'indeterminate' : d.requiredValues.includes(actualValue) ? 'pass' : 'fail';
  const where = d.relatedVia === null ? d.requiredAxis : `${d.relatedVia}.${d.requiredAxis}`;
  const reason =
    outcome === 'pass'
      ? null
      : outcome === 'fail'
        ? d.rejectionReason
        : `${d.rejectionReason} (${where} was not supplied, so the precondition cannot be shown to hold.)`;
  return {
    precondition: d.precondition, type: d.type, axis: d.axis, transition: d.transition,
    relatedVia: d.relatedVia, relatedType: d.relatedType, requiredAxis: d.requiredAxis,
    requiredValues: d.requiredValues, actualValue, outcome, reason,
  };
}

function verdict(type: string, axis: string, transition: string, results: AxisPreconditionResult[]): AxisPreconditionVerdict {
  const failed = results.filter((r) => r.outcome !== 'pass');
  if (failed.length === 0) return { ok: true, type, axis, transition, results };
  return {
    ok: false, code: 'preconditionNotMet', type, axis, transition,
    reasons: failed.map((r) => r.reason ?? ''), results,
  };
}

/** OrderLine preparation, queuedToInPreparation (queued -> inPreparation): orderPaid. */
export function evaluateOrderLinePreparationQueuedToInPreparationOrderPaid(ctx: AxisPreconditionContext): AxisPreconditionResult {
  return evaluate(
    {
      precondition: 'orderPaid', type: 'OrderLine', axis: 'preparation', transition: 'queuedToInPreparation',
      relatedVia: 'order', relatedType: 'Order', requiredAxis: 'payment',
      requiredValues: ['paid'],
      rejectionReason: 'The order is not paid. A line cannot start preparation until its order is paid.',
    },
    ctx,
  );
}

/** The evaluators of each move that has preconditions, by type, axis and transition. */
export const axisPreconditionEvaluators: Readonly<Record<string, Readonly<Record<string, Readonly<Record<string, readonly ((ctx: AxisPreconditionContext) => AxisPreconditionResult)[]>>>>>> = {
  OrderLine: {
    'preparation': {
      queuedToInPreparation: [evaluateOrderLinePreparationQueuedToInPreparationOrderPaid],
    },
  },
};

/**
 * Every precondition of a move, named as the guard's accepted result names it
 * (type, axis, transition). A move with no preconditions passes.
 */
export function evaluateAxisMovePreconditions(
  type: string,
  axis: string,
  transition: string,
  ctx: AxisPreconditionContext,
): AxisPreconditionVerdict {
  const fns = axisPreconditionEvaluators[type]?.[axis]?.[transition] ?? [];
  return verdict(type, axis, transition, fns.map((fn) => fn(ctx)));
}
