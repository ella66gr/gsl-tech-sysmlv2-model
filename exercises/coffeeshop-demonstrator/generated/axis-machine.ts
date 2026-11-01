// ============================================================
// DO NOT EDIT — Generated from CoffeeShop SysML v2 model
// Source: exercises/coffeeshop-demonstrator/model/domain/coffeeshop.sysml (CoffeeShop::OrderLine); exercises/coffeeshop-demonstrator/model/domain/coffeeshop.sysml (CoffeeShop::Order)
// Generator: generation/state_machine.py
// ============================================================

import { setup } from "xstate";

// One XState machine per type, with one parallel region per status axis.
// The guard (axis-guard.ts) is the check; these machines are its picture.

export type OrderLineAxisEvent =
  { type: "LinePreparationStarted" }
  | { type: "LinePreparationComplete" }
  | { type: "LineCollected" }
  | { type: "LineCancelled" };

export const orderLineAxesMachine = setup({
  types: {
    events: {} as OrderLineAxisEvent,
  },
}).createMachine({
  id: "OrderLine",
  type: "parallel",
  states: {
    "preparation": {
      initial: "queued",
      states: {
        queued: {
          on: {
            "LinePreparationStarted": "inPreparation",
            "LineCancelled": "cancelled",
          },
        },
        inPreparation: {
          on: {
            "LinePreparationComplete": "ready",
            "LineCancelled": "cancelled",
          },
        },
        ready: {
          on: {
            "LineCollected": "collected",
            "LineCancelled": "cancelled",
          },
        },
        collected: {
          type: "final",
        },
        cancelled: {
          type: "final",
        },
      },
    },
  },
});

export type OrderAxisEvent =
  { type: "PreparationStarted" }
  | { type: "PreparationComplete" }
  | { type: "OrderCollected" }
  | { type: "CancellationRequested" }
  | { type: "PaymentTaken" };

export const orderAxesMachine = setup({
  types: {
    events: {} as OrderAxisEvent,
  },
}).createMachine({
  id: "Order",
  type: "parallel",
  states: {
    "lifecycle": {
      initial: "placed",
      states: {
        placed: {
          on: {
            "PreparationStarted": "inPreparation",
            "CancellationRequested": "cancelled",
          },
        },
        inPreparation: {
          on: {
            "PreparationComplete": "ready",
            "CancellationRequested": "cancelled",
          },
        },
        ready: {
          on: {
            "OrderCollected": "collected",
          },
        },
        collected: {
          type: "final",
        },
        cancelled: {
          type: "final",
        },
      },
    },
    "payment": {
      initial: "unpaid",
      states: {
        unpaid: {
          on: {
            "PaymentTaken": "paid",
          },
        },
        paid: {
          type: "final",
        },
      },
    },
  },
});
