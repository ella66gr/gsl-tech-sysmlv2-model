/**
 * CDR Integration Test — Phase B, Step B4
 *
 * Standalone test script that exercises the EHRbase client and
 * composition builder end to end:
 *
 *   1. Create an EHR for a test customer
 *   2. Build an order composition from OrderDetails-like input
 *   3. Commit the composition to EHRbase
 *   4. Retrieve the composition and verify round-trip
 *   5. Query via AQL to confirm entity-view retrieval
 *   6. Test getOrCreateEhr idempotency (same customer → same EHR)
 *
 * Run: npx tsx src/test/test-cdr-integration.ts
 * Requires: EHRbase running on localhost:8080 with template uploaded
 */

import {
  createEhrbaseClient,
  buildOrderComposition,
  ORDER_TEMPLATE_ID,
} from '@coffeeshop/shared';

const client = createEhrbaseClient();

async function run(): Promise<void> {
  console.log('=== CDR Integration Test — Phase B ===\n');

  // Use a unique subject ID to avoid clashes with previous test runs
  const testSubjectId = `test-customer-b4-${Date.now()}`;

  // ── Step 1: Create EHR ──
  console.log('Step 1: Creating EHR for test customer...');
  const { ehrId } = await client.createEhr(testSubjectId);
  console.log(`  ✓ EHR created: ${ehrId}\n`);

  // ── Step 2: Build composition ──
  console.log('Step 2: Building order composition...');
  const composition = buildOrderComposition({
    orderId: 'test-b4-001',
    customerName: 'Test Customer',
    drinkType: 'flat white',
    size: 'medium',
    milkChoice: 'oat',
    extras: 'Extra shot',
    composerName: 'Test Script',
  });
  console.log(`  ✓ Composition built (template: ${ORDER_TEMPLATE_ID})\n`);

  // ── Step 3: Commit composition ──
  console.log('Step 3: Committing composition to EHRbase...');
  const { compositionUid } = await client.commitComposition(
    ehrId,
    ORDER_TEMPLATE_ID,
    composition,
  );
  console.log(`  ✓ Composition committed: ${compositionUid}\n`);

  // ── Step 4: Retrieve and verify ──
  console.log('Step 4: Retrieving composition...');
  const retrieved = await client.getComposition(ehrId, compositionUid);
  // Check the content array has our OBSERVATION
  const content = retrieved['content'] as Array<Record<string, unknown>> | undefined;
  if (!content || content.length === 0) {
    throw new Error('Retrieved composition has no content');
  }
  const observation = content[0]!;
  console.log(`  ✓ Retrieved composition — OBSERVATION type: ${observation['_type']}`);
  console.log(`  ✓ Archetype node ID: ${observation['archetype_node_id']}\n`);

  // ── Step 5: AQL query ──
  console.log('Step 5: Running AQL entity-view query...');
  const aql = `
    SELECT
      c/content[openEHR-EHR-OBSERVATION.order_record.v0]/data[at0001]/events[at0002]/data[at0003]/items[at0005]/value/value as drink_name,
      c/content[openEHR-EHR-OBSERVATION.order_record.v0]/data[at0001]/events[at0002]/data[at0003]/items[at0006]/value/value as drink_size,
      c/content[openEHR-EHR-OBSERVATION.order_record.v0]/data[at0001]/events[at0002]/data[at0003]/items[at0012]/value/value as milk_choice,
      c/content[openEHR-EHR-OBSERVATION.order_record.v0]/data[at0001]/events[at0002]/data[at0003]/items[at0019]/value/value as price
    FROM EHR e
    CONTAINS COMPOSITION c[openEHR-EHR-COMPOSITION.order_composition.v0]
    WHERE e/ehr_id/value = '${ehrId}'
  `;
  const result = await client.executeAql(aql);
  console.log(`  ✓ AQL returned ${result.rows.length} row(s)`);
  if (result.rows.length > 0) {
    const row = result.rows[0]!;
    console.log(`  ✓ Data: drink=${row[0]}, size=${row[1]}, milk=${row[2]}, price=${row[3]}`);
  }
  console.log();

  // ── Step 6: getOrCreateEhr idempotency ──
  console.log('Step 6: Testing getOrCreateEhr idempotency...');
  const { ehrId: sameEhrId } = await client.getOrCreateEhr(testSubjectId);
  if (sameEhrId === ehrId) {
    console.log(`  ✓ Same EHR returned for same subject: ${sameEhrId}`);
  } else {
    console.log(`  ✗ Different EHR returned! Expected ${ehrId}, got ${sameEhrId}`);
  }

  // New customer should get a different EHR
  const { ehrId: differentEhrId } = await client.getOrCreateEhr(`${testSubjectId}-other`);
  if (differentEhrId !== ehrId) {
    console.log(`  ✓ Different customer got different EHR: ${differentEhrId}`);
  } else {
    console.log(`  ✗ Different customer got same EHR!`);
  }

  console.log('\n=== All CDR integration tests passed ===');
}

run().catch((err) => {
  console.error('\n✗ CDR integration test failed:', err);
  process.exit(1);
});
