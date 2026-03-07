/**
 * GET /api/entity/orders — Entity view: all orders
 *
 * Queries the CDR (EHRbase) via AQL for all order compositions
 * across all customers. Returns entity-organised data — the same
 * orders that appear in the Temporal process view, but retrieved
 * by data type rather than by workflow instance.
 *
 * This is the "entity view" counterpart to GET /api/orders/list
 * which returns the "process view" from Temporal.
 *
 * Clinical analogy: "Show me all lab results" vs "Show me all
 * active pathways."
 *
 * Phase C, Step C2.
 */

import { json, error } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { getEhrbaseClient } from '$lib/server/ehrbase';
import { allOrdersAql } from '$lib/server/aql-queries';

export interface OrderEntityView {
  ehrId: string;
  compositionUid: string;
  orderTime: string;
  drinkName: string;
  drinkSize: string;
  milkChoice: string | null;
  price: string;
}

export const GET: RequestHandler = async () => {
  const client = getEhrbaseClient();

  try {
    const aql = allOrdersAql();
    const result = await client.executeAql(aql);

    const orders: OrderEntityView[] = result.rows.map((row) => ({
      ehrId: row[0] as string,
      compositionUid: row[1] as string,
      orderTime: row[2] as string,
      drinkName: row[3] as string,
      drinkSize: row[4] as string,
      milkChoice: (row[5] as string) ?? null,
      price: row[6] as string,
    }));

    return json({
      view: 'entity',
      source: 'CDR (EHRbase)',
      count: orders.length,
      orders,
    });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : String(err);
    throw error(500, `Entity view query failed: ${message}`);
  }
};
