<script lang="ts">
  import { onMount } from 'svelte';
  import { Badge, Button, Alert, Spinner } from 'flowbite-svelte';

  // ── Types ──

  interface OrderRecord {
    ehrId: string; compositionUid: string; orderTime: string;
    drinkName: string; drinkSize: string; milkChoice: string | null; price: string;
  }
  interface PrepRecord {
    ehrId: string; compositionUid: string; prepTime: string;
    prepMethod: string | null; baristaName: string | null;
  }
  interface CustomerAudit {
    ehrId: string; orderCount: number; prepCount: number; gap: number; compliant: boolean;
    orders: OrderRecord[]; preparations: PrepRecord[]; unmatched: OrderRecord[];
  }
  interface GovernanceReport {
    title: string; generatedAt: string; governanceQuestion: string; source: string;
    summary: {
      totalCustomers: number; totalOrders: number; totalPreparations: number;
      totalGaps: number; compliantCustomers: number; nonCompliantCustomers: number; complianceRate: string;
    };
    customers: CustomerAudit[];
  }

  // ── State ──

  let loading = $state(true);
  let errorMessage = $state('');
  let report = $state<GovernanceReport | null>(null);
  let expandedCustomer = $state<string | null>(null);

  // ── Derived ──

  let complianceRate = $derived(report ? parseFloat(report.summary.complianceRate) || 0 : 0);
  let barColor = $derived(complianceRate === 100 ? 'bg-green-500' : complianceRate >= 75 ? 'bg-yellow-500' : 'bg-red-500');
  let rateBg = $derived(complianceRate === 100 ? 'bg-green-50 dark:bg-green-900/20' : complianceRate >= 75 ? 'bg-yellow-50 dark:bg-yellow-900/20' : 'bg-red-50 dark:bg-red-900/20');

  // ── Auto-load on mount ──

  onMount(() => {
    runAudit();
  });

  async function runAudit() {
    loading = true;
    errorMessage = '';
    report = null;
    expandedCustomer = null;
    try {
      const response = await fetch('/api/entity/governance');
      if (!response.ok) {
        const data = await response.json();
        errorMessage = data.message || `Error: ${response.status}`;
        return;
      }
      report = await response.json();
    } catch (err) {
      errorMessage = err instanceof Error ? err.message : 'Failed to run governance audit';
    } finally {
      loading = false;
    }
  }

  // ── Helpers ──

  function formatTime(iso: string): string {
    try { return new Date(iso).toLocaleString(); } catch { return iso; }
  }

  function shortUid(uid: string): string {
    return uid.split('::')[0]?.substring(0, 8) ?? uid;
  }

  function toggleCustomer(ehrId: string) {
    expandedCustomer = expandedCustomer === ehrId ? null : ehrId;
  }

  function getSummaryCards(summary: GovernanceReport['summary']) {
    return [
      { label: 'Customers', value: summary.totalCustomers, bg: 'bg-secondary-50 dark:bg-secondary-800' },
      { label: 'Orders', value: summary.totalOrders, bg: 'bg-secondary-50 dark:bg-secondary-800' },
      { label: 'Preparations', value: summary.totalPreparations, bg: 'bg-secondary-50 dark:bg-secondary-800' },
      { label: 'Data Gaps', value: summary.totalGaps, bg: summary.totalGaps > 0 ? 'bg-red-50 dark:bg-red-900/20' : 'bg-green-50 dark:bg-green-900/20' },
    ];
  }
</script>

<!-- Page header -->
<div class="mb-6">
  <div class="flex items-center gap-3">
    <h1 class="text-2xl font-bold text-secondary-800 dark:text-white">Audit Dashboard</h1>
    <Badge color="indigo">CDR · EHRbase</Badge>
    {#if !loading}
      <button
        onclick={runAudit}
        class="text-xs text-secondary-400 hover:text-secondary-600 dark:text-secondary-500 dark:hover:text-secondary-300"
        title="Re-run audit"
      >↻ Refresh</button>
    {/if}
  </div>
  <p class="text-sm text-secondary-500 dark:text-secondary-400">
    Population-level data completeness check against the CDR.
  </p>
</div>

{#if errorMessage}
  <Alert color="red" class="mb-4">{errorMessage}</Alert>
{/if}

{#if loading}
  <div class="flex items-center gap-2 py-8 text-secondary-500 dark:text-secondary-400">
    <Spinner size="5" /> Running governance audit…
  </div>
{:else if report}
  <!-- Governance question — prominent banner -->
  <div class="mb-6 rounded-lg border-l-4 border-primary-500 bg-primary-50 p-4 dark:bg-primary-900/20">
    <p class="text-xs font-semibold uppercase tracking-wider text-primary-600 dark:text-primary-400">Governance Question</p>
    <p class="mt-1 text-secondary-700 dark:text-secondary-300">{report.governanceQuestion}</p>
    <p class="mt-2 text-xs italic text-secondary-400 dark:text-secondary-500">
      Clinical analogy: "Does every patient on hormone therapy who has passed their 3-month mark have monitoring bloods recorded?"
    </p>
  </div>

  <!-- Summary cards -->
  <div class="mb-6 grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-5">
    {#each getSummaryCards(report.summary) as card}
      <div class="rounded-lg {card.bg} p-4 text-center">
        <div class="text-2xl font-bold text-secondary-800 dark:text-white">{card.value}</div>
        <div class="text-xs text-secondary-500 dark:text-secondary-400">{card.label}</div>
      </div>
    {/each}

    <!-- Compliance rate card with progress bar -->
    <div class="rounded-lg {rateBg} p-4 text-center">
      <div class="text-2xl font-bold text-secondary-800 dark:text-white">{report.summary.complianceRate}</div>
      <div class="mx-auto mb-1 mt-1 h-2 w-full max-w-[120px] overflow-hidden rounded-full bg-secondary-200 dark:bg-secondary-700">
        <div class="{barColor} h-2 rounded-full transition-all duration-500" style="width: {complianceRate}%"></div>
      </div>
      <div class="text-xs text-secondary-500 dark:text-secondary-400">Compliance Rate</div>
    </div>
  </div>

  <!-- Compliant / non-compliant summary -->
  <div class="mb-6 flex gap-4 text-sm">
    <span class="text-green-600 dark:text-green-400">✓ Compliant: {report.summary.compliantCustomers}</span>
    <span class="text-red-600 dark:text-red-400">✗ Non-compliant: {report.summary.nonCompliantCustomers}</span>
  </div>

  <!-- Report metadata -->
  <p class="mb-4 text-xs text-secondary-400 dark:text-secondary-500">
    Generated: {formatTime(report.generatedAt)} · Source: {report.source}
  </p>

  <hr class="mb-4 border-secondary-200 dark:border-secondary-700" />

  <!-- Customer detail -->
  <h3 class="mb-3 text-lg font-semibold text-secondary-700 dark:text-secondary-300">Customer Detail</h3>

  {#each report.customers as customer}
    <div class="mb-2 overflow-hidden rounded-lg border {customer.compliant ? 'border-green-200 dark:border-green-800' : 'border-red-200 dark:border-red-800'}">
      <button
        onclick={() => toggleCustomer(customer.ehrId)}
        class="flex w-full items-center justify-between px-4 py-3 text-left text-sm {customer.compliant ? 'bg-green-50 dark:bg-green-900/20' : 'bg-red-50 dark:bg-red-900/20'}"
      >
        <span class="flex items-center gap-2">
          <Badge color={customer.compliant ? 'green' : 'red'}>{customer.compliant ? 'COMPLIANT' : 'NON-COMPLIANT'}</Badge>
          <code class="text-xs text-secondary-500 dark:text-secondary-400">{customer.ehrId.substring(0, 8)}…</code>
        </span>
        <span class="text-xs text-secondary-500 dark:text-secondary-400">
          Orders: {customer.orderCount} · Preps: {customer.prepCount} ·
          Gap: <strong class="{customer.gap > 0 ? 'text-red-600 dark:text-red-400' : 'text-green-600 dark:text-green-400'}">{customer.gap}</strong>
          <span class="ml-2">{expandedCustomer === customer.ehrId ? '▲' : '▼'}</span>
        </span>
      </button>

      {#if expandedCustomer === customer.ehrId}
        <div class="bg-white p-4 dark:bg-secondary-800">
          {#if customer.unmatched.length > 0}
            <h4 class="mb-2 text-sm font-semibold text-red-600 dark:text-red-400">Unmatched Orders (no preparation event)</h4>
            <table class="mb-4 w-full text-left text-xs">
              <thead>
                <tr class="border-b-2 border-secondary-200 dark:border-secondary-600">
                  <th class="p-1.5">Time</th><th class="p-1.5">Drink</th><th class="p-1.5">Size</th><th class="p-1.5">Price</th><th class="hidden p-1.5 sm:table-cell">Composition</th>
                </tr>
              </thead>
              <tbody>
                {#each customer.unmatched as order}
                  <tr class="border-b border-secondary-100 bg-red-50/50 dark:border-secondary-700 dark:bg-red-900/10">
                    <td class="p-1.5">{formatTime(order.orderTime)}</td>
                    <td class="p-1.5">{order.drinkName}</td>
                    <td class="p-1.5">{order.drinkSize}</td>
                    <td class="p-1.5">{order.price}</td>
                    <td class="hidden p-1.5 sm:table-cell"><code>{shortUid(order.compositionUid)}…</code></td>
                  </tr>
                {/each}
              </tbody>
            </table>
          {/if}

          <h4 class="mb-2 text-sm font-semibold text-secondary-600 dark:text-secondary-400">All Orders</h4>
          <table class="mb-4 w-full text-left text-xs">
            <thead>
              <tr class="border-b-2 border-secondary-200 dark:border-secondary-600">
                <th class="p-1.5">Time</th><th class="p-1.5">Drink</th><th class="p-1.5">Size</th><th class="p-1.5">Milk</th><th class="p-1.5">Price</th><th class="hidden p-1.5 sm:table-cell">Composition</th>
              </tr>
            </thead>
            <tbody>
              {#each customer.orders as order}
                {@const isUnmatched = customer.unmatched.some(u => u.compositionUid === order.compositionUid)}
                <tr class="border-b border-secondary-100 dark:border-secondary-700 {isUnmatched ? 'bg-red-50/50 dark:bg-red-900/10' : ''}">
                  <td class="p-1.5">{formatTime(order.orderTime)}</td>
                  <td class="p-1.5">{order.drinkName} {isUnmatched ? '⚠' : ''}</td>
                  <td class="p-1.5">{order.drinkSize}</td>
                  <td class="p-1.5">{order.milkChoice ?? '—'}</td>
                  <td class="p-1.5">{order.price}</td>
                  <td class="hidden p-1.5 sm:table-cell"><code>{shortUid(order.compositionUid)}…</code></td>
                </tr>
              {/each}
            </tbody>
          </table>

          {#if customer.preparations.length > 0}
            <h4 class="mb-2 text-sm font-semibold text-secondary-600 dark:text-secondary-400">Preparation Events</h4>
            <table class="w-full text-left text-xs">
              <thead>
                <tr class="border-b-2 border-secondary-200 dark:border-secondary-600">
                  <th class="p-1.5">Time</th><th class="p-1.5">Method</th><th class="p-1.5">Barista</th><th class="hidden p-1.5 sm:table-cell">Composition</th>
                </tr>
              </thead>
              <tbody>
                {#each customer.preparations as prep}
                  <tr class="border-b border-secondary-100 dark:border-secondary-700">
                    <td class="p-1.5">{formatTime(prep.prepTime)}</td>
                    <td class="p-1.5">{prep.prepMethod ?? '—'}</td>
                    <td class="p-1.5">{prep.baristaName ?? '—'}</td>
                    <td class="hidden p-1.5 sm:table-cell"><code>{shortUid(prep.compositionUid)}…</code></td>
                  </tr>
                {/each}
              </tbody>
            </table>
          {:else}
            <p class="text-xs text-secondary-400 dark:text-secondary-500">No preparation events recorded.</p>
          {/if}
        </div>
      {/if}
    </div>
  {/each}
{/if}
