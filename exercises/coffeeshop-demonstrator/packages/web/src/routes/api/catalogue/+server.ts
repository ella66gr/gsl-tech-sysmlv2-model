/**
 * Catalogue API Routes — CSW Extension Phase 3
 *
 * GET  /api/catalogue         — List catalogue entries (active by default, ?all=true for manager view)
 * POST /api/catalogue         — Create new menu item + catalogue entry (manager action)
 */

import { json, error } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { getPostgresClient } from '$lib/server/postgres';
import type { CreateCatalogueItemInput } from '@coffeeshop/shared';

export const GET: RequestHandler = async ({ url }) => {
  const db = getPostgresClient();
  const showAll = url.searchParams.get('all') === 'true';

  const catalogue = showAll
    ? await db.getAllCatalogueEntries()
    : await db.getActiveCatalogue();

  return json(catalogue);
};

export const POST: RequestHandler = async ({ request }) => {
  let body: CreateCatalogueItemInput;

  try {
    body = await request.json();
  } catch {
    throw error(400, 'Invalid JSON body');
  }

  // Validate required fields
  if (!body.menuItem?.name || !body.menuItem?.category || !body.menuItem?.itemType) {
    throw error(400, 'Missing required fields: menuItem.name, menuItem.category, menuItem.itemType');
  }
  if (!body.pricePence || !body.priceDisplay || !body.provisionType) {
    throw error(400, 'Missing required fields: pricePence, priceDisplay, provisionType');
  }

  // Validate category
  if (!['hot_drink', 'cold_drink', 'food'].includes(body.menuItem.category)) {
    throw error(400, 'Invalid category: must be hot_drink, cold_drink, or food');
  }

  // Validate item type matches category
  if (body.menuItem.category === 'food' && body.menuItem.itemType !== 'food_item') {
    throw error(400, 'Food category requires itemType food_item');
  }
  if (body.menuItem.category !== 'food' && body.menuItem.itemType !== 'drink') {
    throw error(400, 'Drink categories require itemType drink');
  }

  // Validate provision type
  if (!['prepared', 'bought_in', 'hybrid'].includes(body.provisionType)) {
    throw error(400, 'Invalid provisionType: must be prepared, bought_in, or hybrid');
  }

  const db = getPostgresClient();

  try {
    const result = await db.createCatalogueItem(body);
    return json(result, { status: 201 });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : String(err);
    if (message.includes('duplicate key') || message.includes('unique')) {
      throw error(409, `Item already exists: ${body.menuItem.name}`);
    }
    throw error(500, `Failed to create catalogue item: ${message}`);
  }
};
