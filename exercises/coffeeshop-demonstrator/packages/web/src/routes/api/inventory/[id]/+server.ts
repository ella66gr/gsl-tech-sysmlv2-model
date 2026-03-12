/**
 * Single Inventory Record API — CSW Extension Phase 3
 *
 * GET /api/inventory/[id]    — Get a single inventory record
 * PUT /api/inventory/[id]    — Update stock level, threshold, notes
 */

import { json, error } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { getPostgresClient } from '$lib/server/postgres';
import type { UpdateInventoryInput } from '@coffeeshop/shared';

export const GET: RequestHandler = async ({ params }) => {
  const db = getPostgresClient();
  const record = await db.getInventoryRecord(params.id);

  if (!record) {
    throw error(404, `Inventory record not found: ${params.id}`);
  }

  return json(record);
};

export const PUT: RequestHandler = async ({ params, request }) => {
  let body: UpdateInventoryInput;

  try {
    body = await request.json();
  } catch {
    throw error(400, 'Invalid JSON body');
  }

  // Validate stock status if provided
  if (body.stockStatus !== undefined) {
    const valid = ['in_stock', 'low', 'out_of_stock', 'on_order'];
    if (!valid.includes(body.stockStatus)) {
      throw error(400, `Invalid stockStatus: must be one of ${valid.join(', ')}`);
    }
  }

  // Validate quantity if provided
  if (body.quantityOnHand !== undefined && (body.quantityOnHand < 0 || !Number.isInteger(body.quantityOnHand))) {
    throw error(400, 'quantityOnHand must be a non-negative integer');
  }

  const db = getPostgresClient();
  const result = await db.updateInventory(params.id, body);

  if (!result) {
    throw error(404, `Inventory record not found: ${params.id}`);
  }

  return json(result);
};
