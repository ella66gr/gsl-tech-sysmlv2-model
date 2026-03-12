/**
 * Inventory API Routes — CSW Extension Phase 3
 *
 * GET /api/inventory           — All inventory records with catalogue item details
 * GET /api/inventory?low=true  — Low-stock items only
 */

import { json } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { getPostgresClient } from '$lib/server/postgres';

export const GET: RequestHandler = async ({ url }) => {
  const db = getPostgresClient();
  const lowOnly = url.searchParams.get('low') === 'true';

  const inventory = lowOnly
    ? await db.getLowStockItems()
    : await db.getInventory();

  return json(inventory);
};
