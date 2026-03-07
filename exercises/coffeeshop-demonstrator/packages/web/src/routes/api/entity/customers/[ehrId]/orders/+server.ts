/**
 * GET /api/entity/customers/[ehrId]/orders — Entity view: orders for one customer
 *
 * Queries the CDR for all order compositions belonging to a specific
 * customer (identified by EHR ID). This is the per-patient entity view.
 *
 * Clinical analogy: "Show me all lab results for this patient."
 *
 * Phase C, Step C2.
 */

import { json, error } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { getEhrbaseClient } from '$lib/server/ehrbase';
import { allOrdersForCustomerAql } from '$lib/server/aql-queries';

export interface CustomerOrderEntityView {
  compositionUid: string;
  orderTime: string;
  drinkName: string;
  drinkSize: string;
  milkChoice: string | null;
  extras: string | null;
  price: string;
}

export const GET: RequestHandler = async ({ params }) => {
  const ehrId = params.ehrId;

  if (!ehrId) {
    throw error(400, 'Missing EHR ID');
  }

  const client = getEhrbaseClient();

  try {
    const aql = allOrdersForCustomerAql(ehrId);
    const result = await client.executeAql(aql);

    const orders: CustomerOrderEntityView[] = result.rows.map((row) => ({
      compositionUid: row[0] as string,
      orderTime: row[1] as string,
      drinkName: row[2] as string,
      drinkSize: row[3] as string,
      milkChoice: (row[4] as string) ?? null,
      extras: (row[5] as string) ?? null,
      price: row[6] as string,
    }));

    return json({
      view: 'entity',
      source: 'CDR (EHRbase)',
      ehrId,
      count: orders.length,
      orders,
    });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : String(err);
    throw error(500, `Entity view query failed: ${message}`);
  }
};
