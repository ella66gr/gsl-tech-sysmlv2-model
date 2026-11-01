/**
 * Barista Activities — Phase B: CDR Integration
 *
 * These are the activity implementations for the FulfilDrink workflow.
 * Activities contain the actual business logic and are the only place
 * where side effects (logging, I/O, etc.) are permitted.
 *
 * Phase B addition: validateOrder now commits an order composition
 * to EHRbase as part of order processing. The CDR commit is a side
 * effect within the activity — Temporal's retry semantics handle
 * transient CDR failures automatically.
 *
 * In later phases, activity function *signatures* will be generated
 * from the SysML model; the *bodies* remain hand-written.
 *
 * S0.4 (Session 518): the workflow input is the model's OrderLine, a
 * canonical runtime type (generated in @coffeeshop/shared's types). The
 * hand-written OrderDetails interface is gone; each activity derives what
 * it needs from the line and its order (lineFacts below).
 */

import { log } from '@temporalio/activity';
import {
  createEhrbaseClient,
  buildOrderComposition,
  ORDER_TEMPLATE_ID,
} from '@coffeeshop/shared';

import type { Drink, MenuItem, OrderCompositionInput, OrderLine } from '@coffeeshop/shared';

// ── Types ──

/** The workflow input type: the model's order line (S0.4). */
export type { OrderLine } from '@coffeeshop/shared';

/** What the activities read from an order line and its order. */
interface LineFacts {
  orderId: string;
  customerName: string;
  drinkType: string;
  size: OrderCompositionInput['size'] | undefined;
  milkChoice: string | undefined;
}

function isDrink(item: MenuItem): item is Drink {
  return 'size' in item;
}

function lineFacts(line: OrderLine): LineFacts {
  const item = line.item;
  const drink = isDrink(item) ? item : undefined;
  return {
    orderId: String(line.order.orderNumber),
    customerName: line.order.orderingParty.participantName,
    drinkType: item.name,
    size: drink ? (`${drink.size}` as OrderCompositionInput['size']) : undefined,
    milkChoice: drink ? `${drink.milkChoice}` : undefined,
  };
}

export interface OrderResult {
  orderId: string;
  status: string;
  timestamp: string;
  /** EHR ID for this customer (set by validateOrder) */
  ehrId?: string;
  /** Composition UID of the committed order record (set by validateOrder) */
  compositionUid?: string;
}

// ── CDR client (singleton for the worker process) ──

const ehrbaseClient = createEhrbaseClient();

// ── Activities ──

/**
 * Validate the incoming order and commit the order composition to the CDR.
 *
 * Phase B changes:
 *   1. Get or create an EHR for the customer
 *   2. Build a canonical JSON composition from order details
 *   3. Commit the composition to EHRbase
 *   4. Return the ehrId and compositionUid alongside the validation result
 *
 * If EHRbase is unavailable, the activity throws and Temporal retries
 * it (up to 3 attempts, per the workflow's retry configuration).
 */
export async function validateOrder(line: OrderLine): Promise<OrderResult> {
  const order = lineFacts(line);
  log.info('Validating order', { orderId: order.orderId, drinkType: order.drinkType });

  // 1. Business logic (existing)
  if (!order.drinkType || !order.customerName || order.size === undefined) {
    throw new Error(`Invalid order ${order.orderId}: missing required fields`);
  }

  // 2. Get or create EHR for this customer
  log.info('Getting or creating EHR for customer', {
    orderId: order.orderId,
    customerName: order.customerName,
  });
  const { ehrId } = await ehrbaseClient.getOrCreateEhr(order.customerName);
  log.info('EHR resolved', { orderId: order.orderId, ehrId });

  // 3. Build the order composition
  // Construct input with only defined optional fields to satisfy
  // exactOptionalPropertyTypes (undefined !== absent).
  const compositionInput: OrderCompositionInput = {
    orderId: order.orderId,
    customerName: order.customerName,
    drinkType: order.drinkType,
    size: order.size,
    composerName: 'Barista System',
    ...(order.milkChoice !== undefined && { milkChoice: order.milkChoice }),
  };
  const composition = buildOrderComposition(compositionInput);

  // 4. Commit to EHRbase
  log.info('Committing order composition to CDR', {
    orderId: order.orderId,
    ehrId,
    templateId: ORDER_TEMPLATE_ID,
  });
  const { compositionUid } = await ehrbaseClient.commitComposition(
    ehrId,
    ORDER_TEMPLATE_ID,
    composition,
  );
  log.info('Order composition committed', {
    orderId: order.orderId,
    compositionUid,
  });

  return {
    orderId: order.orderId,
    status: 'validated',
    timestamp: new Date().toISOString(),
    ehrId,
    compositionUid,
  };
}

/**
 * Prepare the drink.
 * Called after the barista signals that they have started preparation.
 *
 * Phase B note: prepareDrink does not yet commit a composition because
 * the PREPARATION_EVENT archetype and template have not been designed.
 * This will be added once that archetype is available.
 */
export async function prepareDrink(line: OrderLine): Promise<OrderResult> {
  const order = lineFacts(line);
  log.info('Preparing drink', { orderId: order.orderId, drinkType: order.drinkType, size: order.size });

  return {
    orderId: order.orderId,
    status: 'prepared',
    timestamp: new Date().toISOString(),
  };
}

/**
 * Complete the order after customer collection.
 * Final step in the FulfilDrink action flow.
 *
 * No CDR commit — order closure is a state transition, not new data.
 */
export async function completeOrder(line: OrderLine): Promise<OrderResult> {
  const order = lineFacts(line);
  log.info('Completing order', { orderId: order.orderId });

  return {
    orderId: order.orderId,
    status: 'completed',
    timestamp: new Date().toISOString(),
  };
}
