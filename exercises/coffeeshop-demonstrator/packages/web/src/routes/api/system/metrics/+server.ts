/**
 * System Metrics API — CSW Extension Phase 9
 *
 * GET /api/system/metrics — Aggregate operational data from existing endpoints.
 *
 * Queries are run in parallel via Promise.allSettled so individual
 * failures degrade gracefully rather than blocking the entire response.
 *
 * Returns:
 *   {
 *     orders:     { totalOrders, ordersToday, activeOrders },
 *     catalogue:  { totalItems, activeItems, categories },
 *     inventory:  { trackedItems, lowStockItems, outOfStockItems },
 *     governance: { complianceRate, dataGaps },
 *     collectedAt: ISO timestamp
 *   }
 */

import { json } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { getPostgresClient } from '$lib/server/postgres';

export const GET: RequestHandler = async ({ fetch }) => {
  const db = getPostgresClient();

  // ── Run all queries in parallel ──

  const [
    catalogueAllResult,
    catalogueActiveResult,
    inventoryResult,
    ordersAllResult,
    ordersTodayResult,
    activeOrdersResult,
    governanceResult,
  ] = await Promise.allSettled([
    db.getAllCatalogueEntries(),
    db.getActiveCatalogue(),
    db.getInventory(),
    fetch('/api/entity/orders').then(r => r.ok ? r.json() : []),
    fetch('/api/entity/orders/today').then(r => r.ok ? r.json() : []),
    fetch('/api/orders/active').then(r => r.ok ? r.json() : { orders: [] }),
    fetch('/api/entity/governance').then(r => r.ok ? r.json() : null),
  ]);

  // ── Extract values with safe fallbacks ──

  const allCat = catalogueAllResult.status === 'fulfilled' ? catalogueAllResult.value : [];
  const activeCat = catalogueActiveResult.status === 'fulfilled' ? catalogueActiveResult.value : [];
  const inv = inventoryResult.status === 'fulfilled' ? inventoryResult.value : [];

  // CDR entity endpoints return arrays directly
  const allOrders = ordersAllResult.status === 'fulfilled'
    ? (Array.isArray(ordersAllResult.value) ? ordersAllResult.value : (ordersAllResult.value?.rows ?? []))
    : [];
  const todayOrders = ordersTodayResult.status === 'fulfilled'
    ? (Array.isArray(ordersTodayResult.value) ? ordersTodayResult.value : (ordersTodayResult.value?.rows ?? []))
    : [];
  const activeOrders = activeOrdersResult.status === 'fulfilled'
    ? (activeOrdersResult.value?.orders ?? [])
    : [];
  const governance = governanceResult.status === 'fulfilled'
    ? governanceResult.value
    : null;

  // ── Category breakdown ──

  const categories: Record<string, number> = {};
  for (const item of activeCat) {
    const cat = item.category || 'unknown';
    categories[cat] = (categories[cat] || 0) + 1;
  }

  // ── Inventory alerts ──

  const lowStockItems = inv.filter(
    (i) => i.stockStatus === 'low' || i.stockStatus === 'low_stock',
  ).length;
  const outOfStockItems = inv.filter(
    (i) => i.stockStatus === 'out_of_stock',
  ).length;

  // ── Assemble response ──

  return json({
    orders: {
      totalOrders: Array.isArray(allOrders) ? allOrders.length : 0,
      ordersToday: Array.isArray(todayOrders) ? todayOrders.length : 0,
      activeOrders: activeOrders.length,
    },
    catalogue: {
      totalItems: allCat.length,
      activeItems: activeCat.length,
      categories,
    },
    inventory: {
      trackedItems: inv.length,
      lowStockItems,
      outOfStockItems,
    },
    governance: {
      complianceRate: governance?.summary?.complianceRate ?? 'N/A',
      dataGaps: parseInt(governance?.summary?.dataGaps ?? '0', 10),
    },
    collectedAt: new Date().toISOString(),
  });
};
