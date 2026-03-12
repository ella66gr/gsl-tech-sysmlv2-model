/**
 * GET /api/inventory — Inventory records
 *
 * Phase 2: Verification endpoint. Returns all inventory records
 * joined with catalogue and menu item details.
 *
 * Phase 3 will add PUT for stock adjustments.
 */

import { json } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { getPostgresClient } from '$lib/server/postgres';

export const GET: RequestHandler = async () => {
  const db = getPostgresClient();
  const inventory = await db.getInventory();
  return json(inventory);
};
