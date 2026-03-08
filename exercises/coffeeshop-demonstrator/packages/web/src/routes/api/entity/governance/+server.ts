/**
 * GET /api/entity/governance — CDR Governance Audit (Data Completeness)
 *
 * Phase D: Population-level data completeness query.
 * "Does every order also have a preparation event recorded?"
 *
 * Queries the CDR for all order and preparation compositions,
 * joins application-side by EHR ID, identifies gaps, and returns
 * a structured governance report.
 *
 * Clinical analogy: "Does every patient on hormone therapy who has
 * passed their 3-month mark have monitoring bloods recorded?"
 */

import { json } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { getEhrbaseClient } from '$lib/server/ehrbase';

// ── AQL constants ──

const ORDER_OBSERVATION = 'openEHR-EHR-OBSERVATION.order_record.v0';
const ORDER_COMPOSITION = 'openEHR-EHR-COMPOSITION.order_composition.v0';
const PREPARATION_COMPOSITION = 'openEHR-EHR-COMPOSITION.preparation_composition.v0';
const PREPARATION_ACTION = 'openEHR-EHR-ACTION.preparation_event.v0';

const ORDER_DATA_PATH =
  `c/content[${ORDER_OBSERVATION}]/data[at0001]/events[at0002]/data[at0003]`;

const PREP_DATA_PATH =
  `c/content[${PREPARATION_ACTION}]/description[at0001]`;

// ── AQL Queries ──

const ALL_ORDERS_AQL = `
  SELECT
    e/ehr_id/value as ehr_id,
    c/uid/value as composition_uid,
    c/context/start_time/value as order_time,
    ${ORDER_DATA_PATH}/items[at0005]/value/value as drink_name,
    ${ORDER_DATA_PATH}/items[at0006]/value/value as drink_size,
    ${ORDER_DATA_PATH}/items[at0012]/value/value as milk_choice,
    ${ORDER_DATA_PATH}/items[at0019]/value/value as price
  FROM EHR e
  CONTAINS COMPOSITION c[${ORDER_COMPOSITION}]
  ORDER BY e/ehr_id/value, c/context/start_time/value
`;

const ALL_PREPARATIONS_AQL = `
  SELECT
    e/ehr_id/value as ehr_id,
    c/uid/value as composition_uid,
    c/context/start_time/value as prep_time,
    ${PREP_DATA_PATH}/items[at0002]/value/value as prep_method,
    ${PREP_DATA_PATH}/items[at0005]/value/value as barista_name
  FROM EHR e
  CONTAINS COMPOSITION c[${PREPARATION_COMPOSITION}]
  ORDER BY e/ehr_id/value, c/context/start_time/value
`;

// ── Types ──

interface OrderRecord {
  ehrId: string;
  compositionUid: string;
  orderTime: string;
  drinkName: string;
  drinkSize: string;
  milkChoice: string | null;
  price: string;
}

interface PrepRecord {
  ehrId: string;
  compositionUid: string;
  prepTime: string;
  prepMethod: string | null;
  baristaName: string | null;
}

interface CustomerAudit {
  ehrId: string;
  orderCount: number;
  prepCount: number;
  gap: number;
  compliant: boolean;
  orders: OrderRecord[];
  preparations: PrepRecord[];
  unmatched: OrderRecord[];
}

// ── Handler ──

export const GET: RequestHandler = async () => {
  const client = getEhrbaseClient();

  // 1. Query all orders
  const orderResult = await client.executeAql(ALL_ORDERS_AQL);
  const orders: OrderRecord[] = orderResult.rows.map(row => ({
    ehrId: row[0] as string,
    compositionUid: row[1] as string,
    orderTime: row[2] as string,
    drinkName: row[3] as string,
    drinkSize: row[4] as string,
    milkChoice: (row[5] as string) ?? null,
    price: row[6] as string,
  }));

  // 2. Query all preparations
  const prepResult = await client.executeAql(ALL_PREPARATIONS_AQL);
  const preps: PrepRecord[] = prepResult.rows.map(row => ({
    ehrId: row[0] as string,
    compositionUid: row[1] as string,
    prepTime: row[2] as string,
    prepMethod: (row[3] as string) ?? null,
    baristaName: (row[4] as string) ?? null,
  }));

  // 3. Group by EHR ID
  const ordersByEhr = new Map<string, OrderRecord[]>();
  for (const order of orders) {
    const existing = ordersByEhr.get(order.ehrId) ?? [];
    existing.push(order);
    ordersByEhr.set(order.ehrId, existing);
  }

  const prepsByEhr = new Map<string, PrepRecord[]>();
  for (const prep of preps) {
    const existing = prepsByEhr.get(prep.ehrId) ?? [];
    existing.push(prep);
    prepsByEhr.set(prep.ehrId, existing);
  }

  // 4. Join and identify gaps
  const customers: CustomerAudit[] = [];
  let totalGaps = 0;

  for (const [ehrId, customerOrders] of ordersByEhr) {
    const customerPreps = prepsByEhr.get(ehrId) ?? [];
    const gap = Math.max(0, customerOrders.length - customerPreps.length);
    const compliant = gap === 0;
    totalGaps += gap;

    const unmatched = gap > 0 ? customerOrders.slice(customerOrders.length - gap) : [];

    customers.push({
      ehrId,
      orderCount: customerOrders.length,
      prepCount: customerPreps.length,
      gap,
      compliant,
      orders: customerOrders,
      preparations: customerPreps,
      unmatched,
    });
  }

  // Sort: non-compliant first, then by gap size descending
  customers.sort((a, b) => {
    if (a.compliant !== b.compliant) return a.compliant ? 1 : -1;
    return b.gap - a.gap;
  });

  const compliantCount = customers.filter(c => c.compliant).length;
  const totalCustomers = customers.length;
  const complianceRate = totalCustomers > 0
    ? ((compliantCount / totalCustomers) * 100).toFixed(1) + '%'
    : 'N/A';

  return json({
    title: 'CDR Data Completeness Audit — Coffee Shop Orders',
    generatedAt: new Date().toISOString(),
    governanceQuestion: 'Does every order that has been completed also have a preparation event recorded?',
    source: 'EHRbase CDR (entity view)',
    summary: {
      totalCustomers,
      totalOrders: orders.length,
      totalPreparations: preps.length,
      totalGaps,
      compliantCustomers: compliantCount,
      nonCompliantCustomers: totalCustomers - compliantCount,
      complianceRate,
    },
    customers,
  });
};
