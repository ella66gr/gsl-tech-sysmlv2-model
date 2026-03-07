/**
 * GET /api/entity/orders/today — Entity view: today's orders
 *
 * Queries the CDR for all order compositions with a context start_time
 * from today. This demonstrates date-filtered entity queries.
 *
 * Clinical analogy: "Show me all consultations today."
 *
 * Phase C, Step C2.
 */

import { json, error } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { getEhrbaseClient } from '$lib/server/ehrbase';
import { ordersPlacedTodayAql } from '$lib/server/aql-queries';

export const GET: RequestHandler = async () => {
  const client = getEhrbaseClient();

  // Start of today in ISO 8601 format
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const todayIso = today.toISOString();

  try {
    const aql = ordersPlacedTodayAql(todayIso);
    const result = await client.executeAql(aql);

    const orders = result.rows.map((row) => ({
      ehrId: row[0] as string,
      compositionUid: row[1] as string,
      orderTime: row[2] as string,
      drinkName: row[3] as string,
      drinkSize: row[4] as string,
      price: row[5] as string,
    }));

    return json({
      view: 'entity',
      source: 'CDR (EHRbase)',
      date: todayIso.split('T')[0],
      count: orders.length,
      orders,
    });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : String(err);
    throw error(500, `Entity view query failed: ${message}`);
  }
};
