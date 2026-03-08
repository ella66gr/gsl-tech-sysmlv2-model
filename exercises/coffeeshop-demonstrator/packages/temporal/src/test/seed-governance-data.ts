/**
 * Phase D — Test Data Seeder
 *
 * Populates EHRbase with test data for the governance audit exercise.
 * Creates multiple customers with orders, some with matching preparation
 * events and some deliberately without — creating the data gaps that
 * the governance audit query will identify.
 *
 * Test data scenario:
 *   Customer 1 (Alice):   2 orders, 2 preparations — fully compliant
 *   Customer 2 (Bob):     2 orders, 1 preparation  — 1 gap (order without prep)
 *   Customer 3 (Charlie): 1 order,  0 preparations — 1 gap (no prep at all)
 *   Customer 4 (Diana):   1 order,  1 preparation  — fully compliant
 *   Customer 5 (Eve):     3 orders, 1 preparation  — 2 gaps
 *
 * Total: 9 orders, 5 preparations, 4 gaps
 *
 * Usage:
 *   npx tsx src/test/seed-governance-data.ts
 *
 * Prerequisites:
 *   - EHRbase running (docker compose -f docker-compose.ehrbase.yml up -d)
 *   - All three templates uploaded (order, feedback, preparation)
 */

import {
  createEhrbaseClient,
  buildOrderComposition,
  ORDER_TEMPLATE_ID,
  PREPARATION_TEMPLATE_ID,
} from '@coffeeshop/shared';
import { buildPreparationComposition } from '@coffeeshop/shared';
import type { OrderCompositionInput, PreparationCompositionInput } from '@coffeeshop/shared';

const client = createEhrbaseClient();

// ── Test data definitions ──

interface TestOrder {
  readonly drinkType: string;
  readonly size: 'small' | 'medium' | 'large';
  readonly milkChoice?: string;
  readonly extras?: string;
  /** If true, a matching preparation event will be committed */
  readonly hasPrepEvent: boolean;
  /** Preparation method for the prep event (if hasPrepEvent) */
  readonly prepMethod?: 'hot' | 'cold';
}

interface TestCustomer {
  readonly name: string;
  readonly orders: readonly TestOrder[];
}

const TEST_CUSTOMERS: readonly TestCustomer[] = [
  {
    name: 'Alice',
    orders: [
      { drinkType: 'latte', size: 'large', milkChoice: 'oat', hasPrepEvent: true, prepMethod: 'hot' },
      { drinkType: 'tea', size: 'medium', milkChoice: 'none', hasPrepEvent: true, prepMethod: 'hot' },
    ],
  },
  {
    name: 'Bob',
    orders: [
      { drinkType: 'espresso', size: 'small', milkChoice: 'none', hasPrepEvent: true, prepMethod: 'hot' },
      { drinkType: 'cappuccino', size: 'medium', milkChoice: 'whole', hasPrepEvent: false }, // GAP
    ],
  },
  {
    name: 'Charlie',
    orders: [
      { drinkType: 'americano', size: 'large', milkChoice: 'semi', extras: 'Extra shot', hasPrepEvent: false }, // GAP
    ],
  },
  {
    name: 'Diana',
    orders: [
      { drinkType: 'flat white', size: 'medium', milkChoice: 'oat', hasPrepEvent: true, prepMethod: 'hot' },
    ],
  },
  {
    name: 'Eve',
    orders: [
      { drinkType: 'coffee', size: 'small', milkChoice: 'soy', hasPrepEvent: false }, // GAP
      { drinkType: 'tea', size: 'large', milkChoice: 'none', hasPrepEvent: true, prepMethod: 'hot' },
      { drinkType: 'latte', size: 'medium', milkChoice: 'whole', hasPrepEvent: false }, // GAP
    ],
  },
];

// ── Seeding logic ──

interface SeededRecord {
  readonly customerName: string;
  readonly ehrId: string;
  readonly orderCompositionUid: string;
  readonly preparationCompositionUid: string | null;
  readonly drinkType: string;
  readonly size: string;
  readonly hasGap: boolean;
}

async function seedData(): Promise<void> {
  console.log('=== Phase D — Governance Audit Test Data Seeder ===\n');

  const allRecords: SeededRecord[] = [];
  let totalOrders = 0;
  let totalPreps = 0;
  let totalGaps = 0;

  for (const customer of TEST_CUSTOMERS) {
    console.log(`--- Customer: ${customer.name} ---`);

    // Get or create EHR for this customer
    const { ehrId } = await client.getOrCreateEhr(customer.name);
    console.log(`  EHR: ${ehrId}`);

    for (let i = 0; i < customer.orders.length; i++) {
      const order = customer.orders[i]!;
      const orderId = `seed-${customer.name.toLowerCase()}-${i + 1}`;

      // 1. Commit order composition
      const orderInput: OrderCompositionInput = {
        orderId,
        customerName: customer.name,
        drinkType: order.drinkType,
        size: order.size,
        composerName: 'Seed Script',
        ...(order.milkChoice !== undefined && { milkChoice: order.milkChoice }),
        ...(order.extras !== undefined && { extras: order.extras }),
      };
      const orderComposition = buildOrderComposition(orderInput);
      const { compositionUid: orderUid } = await client.commitComposition(
        ehrId,
        ORDER_TEMPLATE_ID,
        orderComposition,
      );
      totalOrders++;
      console.log(`  Order ${i + 1}: ${order.drinkType} (${order.size}) → ${orderUid.split('::')[0]}`);

      // 2. Optionally commit preparation composition
      let prepUid: string | null = null;
      if (order.hasPrepEvent) {
        const now = new Date();
        const startTime = new Date(now.getTime() - 5 * 60 * 1000).toISOString(); // 5 min ago
        const endTime = now.toISOString();

        const prepInput: PreparationCompositionInput = {
          method: order.prepMethod ?? 'hot',
          baristaName: `Barista ${customer.name}`,
          startTime,
          endTime,
          composerName: 'Seed Script',
        };
        const prepComposition = buildPreparationComposition(prepInput);
        const { compositionUid } = await client.commitComposition(
          ehrId,
          PREPARATION_TEMPLATE_ID,
          prepComposition,
        );
        prepUid = compositionUid;
        totalPreps++;
        console.log(`    Prep:  ${order.prepMethod} path → ${compositionUid.split('::')[0]}`);
      } else {
        totalGaps++;
        console.log(`    Prep:  *** NO PREPARATION EVENT (gap) ***`);
      }

      allRecords.push({
        customerName: customer.name,
        ehrId,
        orderCompositionUid: orderUid,
        preparationCompositionUid: prepUid,
        drinkType: order.drinkType,
        size: order.size,
        hasGap: !order.hasPrepEvent,
      });

      // Small delay between commits to get distinct timestamps
      await new Promise(resolve => setTimeout(resolve, 100));
    }

    console.log();
  }

  // Summary
  console.log('=== Seeding Complete ===');
  console.log(`  Customers: ${TEST_CUSTOMERS.length}`);
  console.log(`  Orders:    ${totalOrders}`);
  console.log(`  Preps:     ${totalPreps}`);
  console.log(`  Gaps:      ${totalGaps}`);
  console.log();

  // Print gap summary for governance audit verification
  console.log('=== Expected Gaps (for governance audit verification) ===');
  for (const record of allRecords) {
    if (record.hasGap) {
      console.log(`  ${record.customerName}: ${record.drinkType} (${record.size}) — order ${record.orderCompositionUid.split('::')[0]}`);
    }
  }
  console.log();
}

// ── Main ──

seedData()
  .then(() => {
    console.log('Done.');
    process.exit(0);
  })
  .catch((err) => {
    console.error('Seeding failed:', err);
    process.exit(1);
  });
