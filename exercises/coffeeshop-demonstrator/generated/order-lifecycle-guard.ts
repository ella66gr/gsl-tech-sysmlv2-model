// ============================================================
// DO NOT EDIT — Generated from CoffeeShop SysML v2 model
// Source: exercises/coffeeshop-demonstrator/model/domain/order-lifecycle.sysml (OrderLifeCycle::OrderLifecycle); exercises/coffeeshop-demonstrator/model/domain/coffeeshop.sysml (CoffeeShop::Order); exercises/coffeeshop-demonstrator/model/domain/fulfil-drink-orchestration.sysml (FulfilDrinkOrchestration)
// Generator: generation/state_machine.py
// ============================================================

// Lifecycle guard and next-action map for OrderLifecycle.
// No imports: usable from any runtime, including a Temporal workflow sandbox.

/** States of OrderLifecycle, in model order. */
export const orderLifecycleStates = ["placed", "inPreparation", "ready", "collected", "cancelled"] as const;
export type OrderLifecycleState = (typeof orderLifecycleStates)[number];

/** Events declared beside OrderLifecycle, in model order. */
export const orderLifecycleEvents = ["OrderPlaced", "PreparationStarted", "PreparationComplete", "OrderCollected", "CancellationRequested"] as const;
export type OrderLifecycleEvent = (typeof orderLifecycleEvents)[number];

export const orderLifecycleInitialState: OrderLifecycleState = "placed";
export const orderLifecycleTerminalStates: readonly OrderLifecycleState[] = ["collected", "cancelled"];

export interface OrderLifecycleTransition {
  readonly name: string;
  readonly source: OrderLifecycleState;
  readonly event: OrderLifecycleEvent;
  readonly target: OrderLifecycleState;
}

/** Every transition of OrderLifecycle, in model order. */
export const orderLifecycleTransitions: readonly OrderLifecycleTransition[] = [
  { name: "placed_to_inPreparation", source: "placed", event: "PreparationStarted", target: "inPreparation" },
  { name: "inPreparation_to_ready", source: "inPreparation", event: "PreparationComplete", target: "ready" },
  { name: "ready_to_collected", source: "ready", event: "OrderCollected", target: "collected" },
  { name: "placed_to_cancelled", source: "placed", event: "CancellationRequested", target: "cancelled" },
  { name: "inPreparation_to_cancelled", source: "inPreparation", event: "CancellationRequested", target: "cancelled" },
];

/**
 * The state that `event` moves `state` to, or null when OrderLifecycle refuses it:
 * no transition from that state accepts that event (terminal states accept none).
 */
export function nextOrderLifecycleState(state: string, event: string): OrderLifecycleState | null {
  for (const t of orderLifecycleTransitions) {
    if (t.source === state && t.event === event) return t.target;
  }
  return null;
}

/** True when OrderLifecycle has a transition from `source` to `target`. */
export function isOrderLifecycleTransitionLegal(source: string, target: string): boolean {
  return orderLifecycleTransitions.some((t) => t.source === source && t.target === target);
}

/** True when `state` is a terminal state of OrderLifecycle. */
export function isOrderLifecycleTerminal(state: string): boolean {
  return orderLifecycleTerminalStates.some((s) => s === state);
}

export interface OrderLifecycleNextAction {
  /** The event the action raises. */
  readonly event: OrderLifecycleEvent;
  /** The state the action leads to. */
  readonly target: OrderLifecycleState;
  /** The model transition behind the action. */
  readonly transition: string;
  /** The event's @UserFacing friendlyName in the model. */
  readonly label: string;
  /** The workflow signal that raises the event, or null when no workflow step does. */
  readonly signal: string | null;
}

/** For each state, the actions its outgoing transitions offer, in model order. */
export const orderLifecycleNextActions: Readonly<Record<OrderLifecycleState, readonly OrderLifecycleNextAction[]>> = {
  placed: [
    { event: "PreparationStarted", target: "inPreparation", transition: "placed_to_inPreparation", label: "Barista: Start Preparation", signal: "baristaStarted" },
    { event: "CancellationRequested", target: "cancelled", transition: "placed_to_cancelled", label: "Cancel Order", signal: null },
  ],
  inPreparation: [
    { event: "PreparationComplete", target: "ready", transition: "inPreparation_to_ready", label: "Barista: Mark Ready", signal: "drinkReady" },
    { event: "CancellationRequested", target: "cancelled", transition: "inPreparation_to_cancelled", label: "Cancel Order", signal: null },
  ],
  ready: [
    { event: "OrderCollected", target: "collected", transition: "ready_to_collected", label: "Customer: Collect Drink", signal: "drinkCollected" },
  ],
  collected: [],
  cancelled: [],
};
