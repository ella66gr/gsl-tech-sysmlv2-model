/**
 * GET /api/catalogue — Active catalogue entries
 *
 * Phase 2: Verification endpoint. Returns all active catalogue
 * entries joined with menu item details.
 *
 * Phase 3 will add POST, PUT, and richer query parameters.
 */

import { json } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { getPostgresClient } from '$lib/server/postgres';

export const GET: RequestHandler = async () => {
  const db = getPostgresClient();
  const catalogue = await db.getActiveCatalogue();
  return json(catalogue);
};
