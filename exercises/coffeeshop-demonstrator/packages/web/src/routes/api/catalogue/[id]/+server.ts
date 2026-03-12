/**
 * Single Catalogue Entry API — CSW Extension Phase 3
 *
 * GET /api/catalogue/[id]    — Get a single catalogue entry with full details
 * PUT /api/catalogue/[id]    — Update price, availability, status notes
 */

import { json, error } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { getPostgresClient } from '$lib/server/postgres';
import type { UpdateCatalogueEntryInput } from '@coffeeshop/shared';

export const GET: RequestHandler = async ({ params }) => {
  const db = getPostgresClient();
  const entry = await db.getCatalogueEntry(params.id);

  if (!entry) {
    throw error(404, `Catalogue entry not found: ${params.id}`);
  }

  return json(entry);
};

export const PUT: RequestHandler = async ({ params, request }) => {
  let body: UpdateCatalogueEntryInput;

  try {
    body = await request.json();
  } catch {
    throw error(400, 'Invalid JSON body');
  }

  // Validate availability if provided
  if (body.availability !== undefined) {
    const valid = ['active', 'discontinued', 'seasonal', 'temporarily_unavailable'];
    if (!valid.includes(body.availability)) {
      throw error(400, `Invalid availability: must be one of ${valid.join(', ')}`);
    }
  }

  // Validate price if provided
  if (body.pricePence !== undefined && (body.pricePence < 0 || !Number.isInteger(body.pricePence))) {
    throw error(400, 'pricePence must be a non-negative integer');
  }

  const db = getPostgresClient();
  const result = await db.updateCatalogueEntry(params.id, body);

  if (!result) {
    throw error(404, `Catalogue entry not found: ${params.id}`);
  }

  return json(result);
};
