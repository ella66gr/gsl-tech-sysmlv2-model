// ============================================================
// DO NOT EDIT — Generated from CoffeeShop SysML v2 model
// Source: exercises/coffeeshop-demonstrator/model/domain/coffeeshop.sysml (CoffeeShop::OrderLine); exercises/coffeeshop-demonstrator/model/domain/coffeeshop.sysml (CoffeeShop::Order); exercises/coffeeshop-demonstrator/model/domain/fulfil-drink-orchestration.sysml (FulfilDrinkOrchestration)
// Generator: generation/state_machine.py
// ============================================================

// Status axis guards and next-action maps, from the StatusAxis declarations.
// No imports: usable from any runtime, including a Temporal workflow sandbox.

// -- The guard's result shape (the same for every axis) --------------

/** Why a move was refused. */
export type AxisMoveRejectionCode =
  | "unknownValue"
  | "fromTerminalValue"
  | "moveNotPermitted"
  | "authorityNotNamed";

/** One permitted move, as the model declares it. */
export interface AxisMoveSpec {
  /** The AxisTransition usage name. */
  readonly name: string;
  readonly from: string;
  readonly to: string;
  /** The move's triggerEvent, or its usage name when the model gives none. */
  readonly event: string;
  /** The model's transitionLabel. */
  readonly label: string;
  /** The authorities that may make the move. */
  readonly authorities: readonly string[];
  /** Names of the move's preconditions, evaluated by the generated E6 evaluator. */
  readonly preconditions: readonly string[];
}

/** One status axis, as the model declares it. */
export interface AxisSpec {
  readonly type: string;
  readonly axis: string;
  readonly values: readonly string[];
  readonly defaultValue: string;
  /** Values no move leaves. */
  readonly terminalValues: readonly string[];
  /** The axis's axisAuthority. */
  readonly authorities: readonly string[];
  readonly moves: readonly AxisMoveSpec[];
}

/** A requested move: name the target value or the event, and the writer's authority. */
export interface AxisMoveRequest {
  readonly from: string;
  readonly to?: string;
  readonly event?: string;
  readonly authority: string;
}

export interface AxisMoveAccepted {
  readonly ok: true;
  readonly type: string;
  readonly axis: string;
  readonly from: string;
  readonly to: string;
  readonly event: string;
  readonly transition: string;
  /** The writer's authority; null for a trace (no write). */
  readonly authority: string | null;
  /** Preconditions still to evaluate before the move is made. */
  readonly preconditions: readonly string[];
}

export interface AxisMoveRejection {
  readonly ok: false;
  readonly code: AxisMoveRejectionCode;
  readonly type: string;
  readonly axis: string;
  readonly from: string;
  readonly to: string | null;
  readonly event: string | null;
  readonly authority: string | null;
  /** A sentence saying why, built from the model's names. */
  readonly reason: string;
  /** The moves the axis permits from `from` (empty when `from` is terminal or unknown). */
  readonly permitted: readonly AxisMoveSpec[];
}

export type AxisMoveResult = AxisMoveAccepted | AxisMoveRejection;

/** One action a surface may offer: a move an operator can make. */
export interface AxisNextAction {
  readonly event: string;
  readonly target: string;
  readonly transition: string;
  /** The model's transitionLabel. */
  readonly label: string;
  /** The workflow signal that raises the event, or null when no workflow step does. */
  readonly signal: string | null;
  readonly preconditions: readonly string[];
}

function reject(
  spec: AxisSpec,
  code: AxisMoveRejectionCode,
  from: string,
  to: string | null,
  event: string | null,
  authority: string | null,
  reason: string,
): AxisMoveRejection {
  const permitted = spec.moves.filter((m) => m.from === from);
  return { ok: false, code, type: spec.type, axis: spec.axis, from, to, event, authority, reason, permitted };
}

function find(spec: AxisSpec, from: string, to: string | null, event: string | null): AxisMoveSpec | AxisMoveRejection {
  const what = `${spec.type} ${spec.axis}`;
  if (!spec.values.includes(from)) {
    return reject(spec, "unknownValue", from, to, event, null, `${what}: "${from}" is not a value of the axis.`);
  }
  if (to !== null && !spec.values.includes(to)) {
    return reject(spec, "unknownValue", from, to, event, null, `${what}: "${to}" is not a value of the axis.`);
  }
  if (to === null && event === null) {
    return reject(spec, "moveNotPermitted", from, to, event, null, `${what}: the request names neither a target value nor an event.`);
  }
  if (spec.terminalValues.includes(from)) {
    return reject(spec, "fromTerminalValue", from, to, event, null, `${what}: "${from}" is terminal; no move leaves it.`);
  }
  const move = spec.moves.find(
    (m) => m.from === from && (to === null || m.to === to) && (event === null || m.event === event),
  );
  if (move === undefined) {
    const asked = to !== null ? `to "${to}"` : `on ${event}`;
    const allowed = spec.moves.filter((m) => m.from === from).map((m) => `${m.to} (${m.event})`).join(", ");
    return reject(
      spec, "moveNotPermitted", from, to, event, null,
      `${what}: no permitted move from "${from}" ${asked}. Permitted from "${from}": ${allowed}.`,
    );
  }
  return move;
}

/** The guard: is this move, by this authority, permitted on the axis? */
export function checkAxisMove(spec: AxisSpec, request: AxisMoveRequest): AxisMoveResult {
  const to = request.to ?? null;
  const event = request.event ?? null;
  const found = find(spec, request.from, to, event);
  if ("ok" in found) return { ...found, authority: request.authority };
  if (!found.authorities.includes(request.authority)) {
    return reject(
      spec, "authorityNotNamed", request.from, to, event, request.authority,
      `${spec.type} ${spec.axis}: the move ${found.from} -> ${found.to} may be made by ` +
        `${found.authorities.join(" or ")}, not ${request.authority}.`,
    );
  }
  return {
    ok: true, type: spec.type, axis: spec.axis, from: found.from, to: found.to, event: found.event,
    transition: found.name, authority: request.authority, preconditions: found.preconditions,
  };
}

/**
 * The move `event` makes from `from`, for a realiser that tracks the axis in
 * its own private storage (it writes nothing, so no authority is checked).
 * Refuses exactly as the guard does for an unknown, terminal or undeclared move.
 */
export function traceAxisMove(spec: AxisSpec, from: string, event: string): AxisMoveResult {
  const found = find(spec, from, null, event);
  if ("ok" in found) return found;
  return {
    ok: true, type: spec.type, axis: spec.axis, from: found.from, to: found.to, event: found.event,
    transition: found.name, authority: null, preconditions: found.preconditions,
  };
}

// -- OrderLine (CoffeeShop::OrderLine) --

type OrderLinePreparationValue = "queued" | "inPreparation" | "ready" | "collected" | "cancelled";

/** OrderLine preparation (preparationAxis): values, default, terminal values and permitted moves. */
export const orderLinePreparationAxis: AxisSpec = {
  type: "OrderLine",
  axis: "preparation",
  values: ["queued", "inPreparation", "ready", "collected", "cancelled"],
  defaultValue: "queued",
  terminalValues: ["collected", "cancelled"],
  authorities: ["operatorSide", "systemSide"],
  moves: [
    { name: "queuedToInPreparation", from: "queued", to: "inPreparation", event: "LinePreparationStarted", label: "Barista: Start Preparation", authorities: ["operatorSide", "systemSide"], preconditions: ["orderPaid"] },
    { name: "inPreparationToReady", from: "inPreparation", to: "ready", event: "LinePreparationComplete", label: "Barista: Mark Ready", authorities: ["operatorSide", "systemSide"], preconditions: [] },
    { name: "readyToCollected", from: "ready", to: "collected", event: "LineCollected", label: "Customer: Collect Drink", authorities: ["operatorSide"], preconditions: [] },
    { name: "queuedToCancelled", from: "queued", to: "cancelled", event: "LineCancelled", label: "line cancelled with its order", authorities: ["systemSide"], preconditions: [] },
    { name: "inPreparationToCancelled", from: "inPreparation", to: "cancelled", event: "LineCancelled", label: "line cancelled with its order", authorities: ["systemSide"], preconditions: [] },
    { name: "readyToCancelled", from: "ready", to: "cancelled", event: "LineCancelled", label: "line cancelled with its order", authorities: ["systemSide"], preconditions: [] },
  ],
};

export const orderLinePreparationDefault: OrderLinePreparationValue = "queued";

/** The guard for OrderLine preparation. */
export function checkOrderLinePreparationMove(request: AxisMoveRequest): AxisMoveResult {
  return checkAxisMove(orderLinePreparationAxis, request);
}

/** The move `event` makes on OrderLine preparation, for a realiser tracking it privately. */
export function traceOrderLinePreparationMove(from: string, event: string): AxisMoveResult {
  return traceAxisMove(orderLinePreparationAxis, from, event);
}

/** For each preparation value, the moves an operator (operatorSide) can make, in model order. */
export const orderLinePreparationNextActions: Readonly<Record<OrderLinePreparationValue, readonly AxisNextAction[]>> = {
  queued: [
    { event: "LinePreparationStarted", target: "inPreparation", transition: "queuedToInPreparation", label: "Barista: Start Preparation", signal: "baristaStarted", preconditions: ["orderPaid"] },
  ],
  inPreparation: [
    { event: "LinePreparationComplete", target: "ready", transition: "inPreparationToReady", label: "Barista: Mark Ready", signal: "drinkReady", preconditions: [] },
  ],
  ready: [
    { event: "LineCollected", target: "collected", transition: "readyToCollected", label: "Customer: Collect Drink", signal: "drinkCollected", preconditions: [] },
  ],
  collected: [],
  cancelled: [],
};

// -- Order (CoffeeShop::Order) --

type OrderLifecycleValue = "placed" | "inPreparation" | "ready" | "collected" | "cancelled";

/** Order lifecycle (lifecycleAxis): values, default, terminal values and permitted moves. */
export const orderLifecycleAxis: AxisSpec = {
  type: "Order",
  axis: "lifecycle",
  values: ["placed", "inPreparation", "ready", "collected", "cancelled"],
  defaultValue: "placed",
  terminalValues: ["collected", "cancelled"],
  authorities: ["operatorSide", "systemSide"],
  moves: [
    { name: "placedToInPreparation", from: "placed", to: "inPreparation", event: "PreparationStarted", label: "first line enters preparation", authorities: ["systemSide"], preconditions: [] },
    { name: "inPreparationToReady", from: "inPreparation", to: "ready", event: "PreparationComplete", label: "every line is ready", authorities: ["systemSide"], preconditions: [] },
    { name: "readyToCollected", from: "ready", to: "collected", event: "OrderCollected", label: "every line is collected", authorities: ["systemSide"], preconditions: [] },
    { name: "placedToCancelled", from: "placed", to: "cancelled", event: "CancellationRequested", label: "Cancel Order", authorities: ["operatorSide"], preconditions: [] },
    { name: "inPreparationToCancelled", from: "inPreparation", to: "cancelled", event: "CancellationRequested", label: "Cancel Order", authorities: ["operatorSide"], preconditions: [] },
  ],
};

export const orderLifecycleDefault: OrderLifecycleValue = "placed";

/** The guard for Order lifecycle. */
export function checkOrderLifecycleMove(request: AxisMoveRequest): AxisMoveResult {
  return checkAxisMove(orderLifecycleAxis, request);
}

/** The move `event` makes on Order lifecycle, for a realiser tracking it privately. */
export function traceOrderLifecycleMove(from: string, event: string): AxisMoveResult {
  return traceAxisMove(orderLifecycleAxis, from, event);
}

/** For each lifecycle value, the moves an operator (operatorSide) can make, in model order. */
export const orderLifecycleNextActions: Readonly<Record<OrderLifecycleValue, readonly AxisNextAction[]>> = {
  placed: [
    { event: "CancellationRequested", target: "cancelled", transition: "placedToCancelled", label: "Cancel Order", signal: null, preconditions: [] },
  ],
  inPreparation: [
    { event: "CancellationRequested", target: "cancelled", transition: "inPreparationToCancelled", label: "Cancel Order", signal: null, preconditions: [] },
  ],
  ready: [],
  collected: [],
  cancelled: [],
};

type OrderPaymentValue = "unpaid" | "paid";

/** Order payment (paymentAxis): values, default, terminal values and permitted moves. */
export const orderPaymentAxis: AxisSpec = {
  type: "Order",
  axis: "payment",
  values: ["unpaid", "paid"],
  defaultValue: "unpaid",
  terminalValues: ["paid"],
  authorities: ["operatorSide"],
  moves: [
    { name: "unpaidToPaid", from: "unpaid", to: "paid", event: "PaymentTaken", label: "Till: Take Payment", authorities: ["operatorSide"], preconditions: [] },
  ],
};

export const orderPaymentDefault: OrderPaymentValue = "unpaid";

/** The guard for Order payment. */
export function checkOrderPaymentMove(request: AxisMoveRequest): AxisMoveResult {
  return checkAxisMove(orderPaymentAxis, request);
}

/** The move `event` makes on Order payment, for a realiser tracking it privately. */
export function traceOrderPaymentMove(from: string, event: string): AxisMoveResult {
  return traceAxisMove(orderPaymentAxis, from, event);
}

/** For each payment value, the moves an operator (operatorSide) can make, in model order. */
export const orderPaymentNextActions: Readonly<Record<OrderPaymentValue, readonly AxisNextAction[]>> = {
  unpaid: [
    { event: "PaymentTaken", target: "paid", transition: "unpaidToPaid", label: "Till: Take Payment", signal: null, preconditions: [] },
  ],
  paid: [],
};

/** Every axis, by type and axis name. */
export const axisSpecs: Readonly<Record<string, Readonly<Record<string, AxisSpec>>>> = {
  OrderLine: {
    "preparation": orderLinePreparationAxis,
  },
  Order: {
    "lifecycle": orderLifecycleAxis,
    "payment": orderPaymentAxis,
  },
};
