/**
 * GET /api/orders/active — Active orders with lifecycle state
 *
 * CSW Extension Phase 5 — Counter page active orders panel.
 *
 * Returns only running workflows with their current XState lifecycle
 * state queried from Temporal. Optimised for the counter dashboard:
 * typically < 10 running orders, each queried individually.
 *
 * The existing GET /api/orders/list returns all workflows (up to 50)
 * with Temporal execution status but NOT the XState lifecycle state.
 * This route fills that gap for the active orders panel.
 *
 * Returns: { orders: ActiveOrder[] }
 */

import { json, error } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { getTemporalClient } from '$lib/server/temporal';
import { WORKFLOW_NAME, QUERY_ORDER_STATE } from '@coffeeshop/shared';

interface ActiveOrder {
  orderId: string;
  state: string;
  startTime: string | null;
}

export const GET: RequestHandler = async () => {
  const client = await getTemporalClient();

  try {
    const orders: ActiveOrder[] = [];

    const iterator = client.workflow.list({
      query: `WorkflowType = '${WORKFLOW_NAME}' AND ExecutionStatus = 'Running'`,
    });

    for await (const workflow of iterator) {
      let state = 'unknown';
      try {
        const handle = client.workflow.getHandle(workflow.workflowId);
        state = await handle.query(QUERY_ORDER_STATE);
      } catch {
        // Query may fail if workflow just started — use 'unknown'
      }

      orders.push({
        orderId: workflow.workflowId,
        state,
        startTime: workflow.startTime?.toISOString() ?? null,
      });
    }

    // Sort by start time, newest first
    orders.sort((a, b) => {
      if (!a.startTime || !b.startTime) return 0;
      return new Date(b.startTime).getTime() - new Date(a.startTime).getTime();
    });

    return json({ orders });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : String(err);
    throw error(500, `Failed to list active orders: ${message}`);
  }
};
