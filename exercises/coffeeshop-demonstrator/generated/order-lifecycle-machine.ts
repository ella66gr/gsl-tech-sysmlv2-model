// ============================================================
// DO NOT EDIT — Generated from CoffeeShop SysML v2 model
// Source: exercises/coffeeshop-demonstrator/model/domain/order-lifecycle.sysml (OrderLifeCycle::OrderLifecycle); exercises/coffeeshop-demonstrator/model/domain/coffeeshop.sysml (CoffeeShop::Order); exercises/coffeeshop-demonstrator/model/domain/fulfil-drink-orchestration.sysml (FulfilDrinkOrchestration)
// Generator: generation/state_machine.py
// ============================================================

import { setup } from "xstate";

// Event types: the attribute defs beside OrderLifecycle
export type OrderEvent =
  { type: "OrderPlaced" }
  | { type: "PreparationStarted" }
  | { type: "PreparationComplete" }
  | { type: "OrderCollected" }
  | { type: "CancellationRequested" };

export type OrderState = "placed" | "inPreparation" | "ready" | "collected" | "cancelled";

export const orderLifecycleMachine = setup({
  types: {
    events: {} as OrderEvent,
  },
}).createMachine({
  id: "OrderLifecycle",
  initial: "placed",
  states: {
    placed: {
      on: {
        PreparationStarted: "inPreparation",
        CancellationRequested: "cancelled",
      },
    },
    inPreparation: {
      on: {
        PreparationComplete: "ready",
        CancellationRequested: "cancelled",
      },
    },
    ready: {
      on: {
        OrderCollected: "collected",
      },
    },
    collected: {
      type: "final",
    },
    cancelled: {
      type: "final",
    },
  },
});
