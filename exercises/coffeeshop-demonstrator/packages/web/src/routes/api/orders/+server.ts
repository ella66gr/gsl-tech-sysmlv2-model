/**
 * POST /api/orders — Start a new order workflow
 *
 * Phase 3: Validates the ordered item against the catalogue before
 * starting the workflow. The catalogue provides pricing, valid sizes,
 * and item availability. Bought-in items have inventory decremented.
 *
 * Accepts: { customerName, drinkType, size }
 * Returns: { orderId, workflowId, state, catalogueEntry? }
 */

import { json, error } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { getTemporalClient } from '$lib/server/temporal';
import { getPostgresClient } from '$lib/server/postgres';
import {
  TASK_QUEUE,
  WORKFLOW_NAME,
  QUERY_ORDER_STATE,
} from '@coffeeshop/shared';

export const POST: RequestHandler = async ({ request }) => {
  let body: { customerName?: string; drinkType?: string; size?: string };

  try {
    body = await request.json();
  } catch {
    throw error(400, 'Invalid JSON body');
  }

  const { customerName, drinkType, size } = body;

  if (!customerName || !drinkType || !size) {
    throw error(400, 'Missing required fields: customerName, drinkType, size');
  }

  // ── Catalogue validation ──

  const db = getPostgresClient();
  const catalogueEntry = await db.lookupActiveItemByName(drinkType);

  if (!catalogueEntry) {
    throw error(400, `Item not found or not active: ${drinkType}`);
  }

  // Validate size against the catalogue's available sizes for this item
  if (catalogueEntry.availableSizes && catalogueEntry.availableSizes.length > 0) {
    if (!catalogueEntry.availableSizes.includes(size)) {
      throw error(400,
        `Invalid size '${size}' for ${catalogueEntry.name}. ` +
        `Available: ${catalogueEntry.availableSizes.join(', ')}`
      );
    }
  } else {
    // Food items or items without size constraints — validate basic sizes
    if (!['small', 'medium', 'large'].includes(size)) {
      throw error(400, 'Invalid size: must be small, medium, or large');
    }
  }

  // ── Inventory decrement for bought-in items ──

  if (catalogueEntry.provisionType === 'bought_in') {
    const inventoryResult = await db.decrementInventory(catalogueEntry.catalogueEntryId, 1);
    if (inventoryResult && inventoryResult.stockStatus === 'out_of_stock') {
      console.warn(
        `[Orders] ${catalogueEntry.name} is now out of stock after this order`
      );
    }
  }

  // ── Start workflow ──

  const orderId = `order-${Date.now()}`;

  const client = await getTemporalClient();

  const handle = await client.workflow.start(WORKFLOW_NAME, {
    taskQueue: TASK_QUEUE,
    workflowId: orderId,
    args: [
      {
        orderId,
        customerName,
        drinkType: catalogueEntry.name, // Use canonical name from catalogue
        size,
        catalogueEntryId: catalogueEntry.catalogueEntryId,
        pricePence: catalogueEntry.pricePence,
        priceDisplay: catalogueEntry.priceDisplay,
        provisionType: catalogueEntry.provisionType,
      },
    ],
  });

  // Brief pause to let the workflow initialise and register the query handler.
  await new Promise((resolve) => setTimeout(resolve, 500));

  let state = 'unknown';
  try {
    state = await handle.query(QUERY_ORDER_STATE);
  } catch {
    // Query handler may not be registered yet — that's fine for the response.
  }

  return json({
    orderId,
    workflowId: handle.workflowId,
    state,
    catalogueEntry: {
      name: catalogueEntry.name,
      priceDisplay: catalogueEntry.priceDisplay,
      provisionType: catalogueEntry.provisionType,
    },
  });
};
