/**
 * AQL Query Test — Phase C, Step C1
 *
 * Standalone test script that exercises the AQL queries against
 * EHRbase. This verifies the queries work before integrating them
 * into SvelteKit endpoints.
 *
 * Prerequisites:
 *   - EHRbase running on localhost:8080 with order template uploaded
 *   - At least one order composition committed (from Phase B test or workflow)
 *
 * Run: npx tsx src/test/test-aql-queries.ts
 */

import { createEhrbaseClient } from '@coffeeshop/shared';

const client = createEhrbaseClient();

// ── AQL constants (mirroring aql-queries.ts in the web package) ──

const ORDER_OBSERVATION = 'openEHR-EHR-OBSERVATION.order_record.v0';
const ORDER_COMPOSITION = 'openEHR-EHR-COMPOSITION.order_composition.v0';
const ORDER_DATA_PATH =
  `c/content[${ORDER_OBSERVATION}]/data[at0001]/events[at0002]/data[at0003]`;

async function run(): Promise<void> {
  console.log('=== AQL Query Tests — Phase C ===\n');

  // ── Query 1: All orders (all customers) ──
  console.log('Query 1: All orders across all customers...');
  const q1 = `
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
    ORDER BY c/context/start_time/value DESC
  `;
  const r1 = await client.executeAql(q1);
  console.log(`  ✓ Returned ${r1.rows.length} row(s)`);
  console.log(`  Columns: ${r1.columns.map((c) => c.name).join(', ')}`);
  for (const row of r1.rows) {
    console.log(`  → EHR=${String(row[0]).slice(0, 8)}… drink=${row[2]} size=${row[3]} milk=${row[4]} price=${row[5]}`);
  }
  console.log();

  // ── Query 2: Orders for a specific customer ──
  if (r1.rows.length > 0) {
    const firstEhrId = r1.rows[0]![0] as string;
    console.log(`Query 2: Orders for customer EHR ${firstEhrId.slice(0, 8)}…`);
    const q2 = `
      SELECT
        c/uid/value as composition_uid,
        c/context/start_time/value as order_time,
        ${ORDER_DATA_PATH}/items[at0005]/value/value as drink_name,
        ${ORDER_DATA_PATH}/items[at0006]/value/value as drink_size,
        ${ORDER_DATA_PATH}/items[at0012]/value/value as milk_choice,
        ${ORDER_DATA_PATH}/items[at0018]/value/value as extras,
        ${ORDER_DATA_PATH}/items[at0019]/value/value as price
      FROM EHR e
      CONTAINS COMPOSITION c[${ORDER_COMPOSITION}]
      WHERE e/ehr_id/value = '${firstEhrId}'
      ORDER BY c/context/start_time/value DESC
    `;
    const r2 = await client.executeAql(q2);
    console.log(`  ✓ Returned ${r2.rows.length} row(s)`);
    for (const row of r2.rows) {
      console.log(`  → drink=${row[2]} size=${row[3]} milk=${row[4]} extras=${row[5] ?? '—'} price=${row[6]}`);
    }
    console.log();
  }

  // ── Query 3: Orders placed today ──
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const todayIso = today.toISOString();
  console.log(`Query 3: Orders placed today (since ${todayIso})...`);
  const q3 = `
    SELECT
      e/ehr_id/value as ehr_id,
      c/uid/value as composition_uid,
      c/context/start_time/value as order_time,
      ${ORDER_DATA_PATH}/items[at0005]/value/value as drink_name,
      ${ORDER_DATA_PATH}/items[at0006]/value/value as drink_size,
      ${ORDER_DATA_PATH}/items[at0019]/value/value as price
    FROM EHR e
    CONTAINS COMPOSITION c[${ORDER_COMPOSITION}]
    WHERE c/context/start_time/value >= '${todayIso}'
    ORDER BY c/context/start_time/value DESC
  `;
  const r3 = await client.executeAql(q3);
  console.log(`  ✓ Returned ${r3.rows.length} row(s)`);
  for (const row of r3.rows) {
    console.log(`  → time=${row[2]} drink=${row[3]} size=${row[4]} price=${row[5]}`);
  }
  console.log();

  // ── Query 4: Aggregate — order summary by drink/size ──
  console.log('Query 4: Aggregate order summary (drink × size)...');
  const q4 = `
    SELECT
      ${ORDER_DATA_PATH}/items[at0005]/value/value as drink_name,
      ${ORDER_DATA_PATH}/items[at0006]/value/value as drink_size,
      COUNT(c/uid/value) as order_count
    FROM EHR e
    CONTAINS COMPOSITION c[${ORDER_COMPOSITION}]
    GROUP BY
      ${ORDER_DATA_PATH}/items[at0005]/value/value,
      ${ORDER_DATA_PATH}/items[at0006]/value/value
  `;
  try {
    const r4 = await client.executeAql(q4);
    console.log(`  ✓ Returned ${r4.rows.length} row(s)`);
    for (const row of r4.rows) {
      console.log(`  → ${row[0]} ${row[1]}: ${row[2]} order(s)`);
    }
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    console.log(`  ⚠ Aggregate query failed (may not be supported): ${message}`);
    console.log('  → Fallback: use application-level aggregation');
  }

  console.log('\n=== AQL query tests complete ===');
}

run().catch((err) => {
  console.error('\n✗ AQL query test failed:', err);
  process.exit(1);
});
