/**
 * Phase D — Governance Audit: Data Completeness
 *
 * Population-level governance query: "Does every order that has been
 * completed also have a preparation event recorded?"
 *
 * This is the CDR equivalent of the Phase D compliance table from the
 * original Coffee Shop Demonstrator — but operating on entity-view data
 * (CDR compositions) rather than process-view data (Temporal history).
 *
 * Implementation approach:
 *   1. Query CDR for all order compositions (by EHR + composition UID)
 *   2. Query CDR for all preparation compositions (by EHR)
 *   3. Join application-side by EHR ID (customer)
 *   4. Identify orders without matching preparation events
 *   5. Produce a structured governance report
 *
 * Why application-level join:
 *   EHRbase 2.11.0 does not support AQL NOT EXISTS subqueries or
 *   aggregate functions (COUNT/GROUP BY). The CDR exercise plan
 *   anticipated this — "the fallback is two separate queries joined
 *   in application code — which is actually the more practical pattern
 *   for complex governance queries anyway."
 *
 * Clinical analogy:
 *   "Does every patient on hormone therapy who has passed their
 *   3-month mark have monitoring bloods recorded?"
 *   Same pattern — expected data vs actual data, queried from CDR.
 *
 * Usage:
 *   npx tsx src/test/run-governance-audit.ts
 *
 * Prerequisites:
 *   - EHRbase running with test data seeded (seed-governance-data.ts)
 *   - All three templates uploaded
 */

import { createEhrbaseClient } from '@coffeeshop/shared';

const client = createEhrbaseClient();

// ── AQL Queries ──

const ORDER_OBSERVATION = 'openEHR-EHR-OBSERVATION.order_record.v0';
const ORDER_COMPOSITION = 'openEHR-EHR-COMPOSITION.order_composition.v0';
const PREPARATION_COMPOSITION = 'openEHR-EHR-COMPOSITION.preparation_composition.v0';

const ORDER_DATA_PATH =
  `c/content[${ORDER_OBSERVATION}]/data[at0001]/events[at0002]/data[at0003]`;

/**
 * All order compositions with drink details, grouped by EHR.
 */
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

/**
 * All preparation compositions, grouped by EHR.
 * We just need the count per EHR for the completeness check.
 */
const ALL_PREPARATIONS_AQL = `
  SELECT
    e/ehr_id/value as ehr_id,
    c/uid/value as composition_uid,
    c/context/start_time/value as prep_time
  FROM EHR e
  CONTAINS COMPOSITION c[${PREPARATION_COMPOSITION}]
  ORDER BY e/ehr_id/value, c/context/start_time/value
`;

// ── Data types ──

interface OrderRecord {
  readonly ehrId: string;
  readonly compositionUid: string;
  readonly orderTime: string;
  readonly drinkName: string;
  readonly drinkSize: string;
  readonly milkChoice: string | null;
  readonly price: string;
}

interface PrepRecord {
  readonly ehrId: string;
  readonly compositionUid: string;
  readonly prepTime: string;
}

interface CustomerAudit {
  readonly ehrId: string;
  readonly orderCount: number;
  readonly prepCount: number;
  readonly gap: number;
  readonly compliant: boolean;
  readonly orders: OrderRecord[];
  readonly unmatched: OrderRecord[];
}

interface GovernanceReport {
  readonly title: string;
  readonly generatedAt: string;
  readonly governanceQuestion: string;
  readonly summary: {
    readonly totalCustomers: number;
    readonly totalOrders: number;
    readonly totalPreparations: number;
    readonly totalGaps: number;
    readonly compliantCustomers: number;
    readonly nonCompliantCustomers: number;
    readonly complianceRate: string;
  };
  readonly customers: CustomerAudit[];
}

// ── Audit logic ──

async function runGovernanceAudit(): Promise<GovernanceReport> {
  console.log('=== Phase D — Governance Audit: Data Completeness ===\n');

  // 1. Query all orders
  console.log('Querying CDR for all order compositions...');
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
  console.log(`  Found ${orders.length} order compositions\n`);

  // 2. Query all preparations
  console.log('Querying CDR for all preparation compositions...');
  const prepResult = await client.executeAql(ALL_PREPARATIONS_AQL);
  const preps: PrepRecord[] = prepResult.rows.map(row => ({
    ehrId: row[0] as string,
    compositionUid: row[1] as string,
    prepTime: row[2] as string,
  }));
  console.log(`  Found ${preps.length} preparation compositions\n`);

  // 3. Group by EHR ID (customer)
  const ordersByEhr = new Map<string, OrderRecord[]>();
  for (const order of orders) {
    const existing = ordersByEhr.get(order.ehrId) ?? [];
    existing.push(order);
    ordersByEhr.set(order.ehrId, existing);
  }

  const prepCountByEhr = new Map<string, number>();
  for (const prep of preps) {
    prepCountByEhr.set(prep.ehrId, (prepCountByEhr.get(prep.ehrId) ?? 0) + 1);
  }

  // 4. Join and identify gaps
  const customers: CustomerAudit[] = [];
  let totalGaps = 0;

  for (const [ehrId, customerOrders] of ordersByEhr) {
    const prepCount = prepCountByEhr.get(ehrId) ?? 0;
    const gap = Math.max(0, customerOrders.length - prepCount);
    const compliant = gap === 0;
    totalGaps += gap;

    // Identify unmatched orders (the last N orders where N = gap)
    // This is a simplification — in a real system you'd match by
    // order reference or timestamp. For the exercise, we flag the
    // excess orders as unmatched.
    const unmatched = gap > 0 ? customerOrders.slice(customerOrders.length - gap) : [];

    customers.push({
      ehrId,
      orderCount: customerOrders.length,
      prepCount,
      gap,
      compliant,
      orders: customerOrders,
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

  // 5. Build report
  const report: GovernanceReport = {
    title: 'CDR Data Completeness Audit — Coffee Shop Orders',
    generatedAt: new Date().toISOString(),
    governanceQuestion: 'Does every order that has been completed also have a preparation event recorded?',
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
  };

  return report;
}

// ── Report output ──

function printReport(report: GovernanceReport): void {
  console.log('\n' + '='.repeat(70));
  console.log(report.title);
  console.log('Generated: ' + report.generatedAt);
  console.log('='.repeat(70));
  console.log();
  console.log(`Question: ${report.governanceQuestion}`);
  console.log();

  // Summary table
  console.log('--- Summary ---');
  console.log(`  Customers:          ${report.summary.totalCustomers}`);
  console.log(`  Total orders:       ${report.summary.totalOrders}`);
  console.log(`  Total preparations: ${report.summary.totalPreparations}`);
  console.log(`  Data gaps:          ${report.summary.totalGaps}`);
  console.log(`  Compliant:          ${report.summary.compliantCustomers} / ${report.summary.totalCustomers} (${report.summary.complianceRate})`);
  console.log(`  Non-compliant:      ${report.summary.nonCompliantCustomers}`);
  console.log();

  // Per-customer detail
  console.log('--- Customer Detail ---');
  for (const customer of report.customers) {
    const status = customer.compliant ? '✓ COMPLIANT' : '✗ NON-COMPLIANT';
    const ehrShort = customer.ehrId.split('-')[0];
    console.log();
    console.log(`  ${status}  [EHR ${ehrShort}...]`);
    console.log(`    Orders: ${customer.orderCount}  |  Preparations: ${customer.prepCount}  |  Gap: ${customer.gap}`);

    if (!customer.compliant && customer.unmatched.length > 0) {
      console.log('    Unmatched orders:');
      for (const order of customer.unmatched) {
        const uidShort = order.compositionUid.split('::')[0]!.split('-')[0];
        console.log(`      - ${order.drinkName} (${order.drinkSize}) at ${order.orderTime.substring(0, 19)}  [${uidShort}...]`);
      }
    }
  }

  console.log();
  console.log('='.repeat(70));
  console.log();
}

// ── Main ──

runGovernanceAudit()
  .then((report) => {
    printReport(report);

    // Also write JSON report to stdout for piping
    console.log('--- JSON Report ---');
    console.log(JSON.stringify(report, null, 2));

    process.exit(0);
  })
  .catch((err) => {
    console.error('Governance audit failed:', err);
    process.exit(1);
  });
