<script lang="ts">
  import { onMount } from 'svelte';
  import { Badge, Spinner } from 'flowbite-svelte';

  // ── Types ──

  interface ServiceHealth {
    service: string;
    status: 'healthy' | 'degraded' | 'unavailable';
    responseTimeMs: number;
    detail?: string;
  }

  interface HealthResponse {
    overall: string;
    services: ServiceHealth[];
    checkedAt: string;
  }

  interface SystemMetrics {
    orders: {
      totalOrders: number;
      ordersToday: number;
      activeOrders: number;
    };
    catalogue: {
      totalItems: number;
      activeItems: number;
      categories: Record<string, number>;
    };
    inventory: {
      trackedItems: number;
      lowStockItems: number;
      outOfStockItems: number;
    };
    governance: {
      complianceRate: string;
      dataGaps: number;
    };
    collectedAt: string;
  }

  // ── State ──

  let health = $state<HealthResponse | null>(null);
  let metrics = $state<SystemMetrics | null>(null);
  let healthLoading = $state(true);
  let metricsLoading = $state(true);
  let healthError = $state('');
  let metricsError = $state('');

  // ── Derived values for compliance bar ──

  let complianceRate = $derived(
    metrics?.governance.complianceRate
      ? parseFloat(metrics.governance.complianceRate) || 0
      : 0
  );
  let complianceBarColour = $derived(
    complianceRate === 100 ? 'bg-green-500' : complianceRate >= 75 ? 'bg-yellow-500' : 'bg-red-500'
  );

  // ── Data loading ──

  async function loadHealth() {
    healthLoading = true;
    healthError = '';
    try {
      const res = await fetch('/api/system/health');
      if (res.ok) health = await res.json();
      else healthError = `Health check failed: ${res.status}`;
    } catch (err) {
      healthError = err instanceof Error ? err.message : 'Health check failed';
    } finally {
      healthLoading = false;
    }
  }

  async function loadMetrics() {
    metricsLoading = true;
    metricsError = '';
    try {
      const res = await fetch('/api/system/metrics');
      if (res.ok) metrics = await res.json();
      else metricsError = `Metrics fetch failed: ${res.status}`;
    } catch (err) {
      metricsError = err instanceof Error ? err.message : 'Metrics fetch failed';
    } finally {
      metricsLoading = false;
    }
  }

  // ── Helpers ──

  function healthDotColour(status: string): string {
    switch (status) {
      case 'healthy': return 'bg-green-500';
      case 'degraded': return 'bg-yellow-500';
      default: return 'bg-red-500';
    }
  }

  function healthCardBorder(status: string): string {
    switch (status) {
      case 'healthy': return 'border-green-200 bg-green-50 dark:border-green-800 dark:bg-green-900/20';
      case 'degraded': return 'border-yellow-200 bg-yellow-50 dark:border-yellow-800 dark:bg-yellow-900/20';
      default: return 'border-red-200 bg-red-50 dark:border-red-800 dark:bg-red-900/20';
    }
  }

  function formatCategoryName(cat: string): string {
    return cat.replace(/_/g, ' ').replace(/\b\w/g, c => c.toUpperCase());
  }

  function formatTime(iso: string): string {
    return new Date(iso).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' });
  }

  // ── Lifecycle ──

  onMount(() => {
    loadHealth();
    loadMetrics();
  });
</script>

<!-- Page header -->
<div class="mb-6">
  <h1 class="text-2xl font-bold text-secondary-800 dark:text-white">System Status</h1>
  <p class="text-sm text-secondary-500 dark:text-secondary-400">
    Infrastructure health, operational metrics, and self-assessment.
  </p>
</div>

<!-- ═══════════════════════════════════════════════════════════════ -->
<!-- INFRASTRUCTURE HEALTH                                          -->
<!-- ═══════════════════════════════════════════════════════════════ -->

<div class="mb-6">
  <div class="mb-3 flex items-center justify-between">
    <h2 class="text-xs font-semibold uppercase tracking-wider text-secondary-500 dark:text-secondary-400">Infrastructure Health</h2>
    <div class="flex items-center gap-3 text-xs text-secondary-400 dark:text-secondary-500">
      {#if health}
        <span>Checked {formatTime(health.checkedAt)}</span>
      {/if}
      {#if !healthLoading}
        <button
          onclick={loadHealth}
          class="text-secondary-400 hover:text-secondary-600 dark:text-secondary-500 dark:hover:text-secondary-300"
          title="Re-check health"
        >↻ Check</button>
      {/if}
    </div>
  </div>

  {#if healthLoading}
    <div class="flex items-center gap-2 py-4 text-secondary-500">
      <Spinner size="5" /> Checking infrastructure…
    </div>
  {:else if healthError}
    <div class="rounded-lg border border-red-200 bg-red-50 p-4 text-sm text-red-700 dark:border-red-800 dark:bg-red-900/20 dark:text-red-400">
      {healthError}
    </div>
  {:else if health}
    <div class="grid grid-cols-1 gap-3 sm:grid-cols-3">
      {#each health.services as svc}
        <div class="rounded-lg border p-4 {healthCardBorder(svc.status)}">
          <div class="flex items-center gap-2">
            <span class="inline-block h-2.5 w-2.5 rounded-full {healthDotColour(svc.status)}"></span>
            <span class="font-medium text-secondary-800 dark:text-white">{svc.service}</span>
          </div>
          <p class="mt-1 text-sm capitalize text-secondary-500 dark:text-secondary-400">{svc.status}</p>
          <p class="text-xs text-secondary-400 dark:text-secondary-500">{svc.responseTimeMs}ms</p>
          {#if svc.detail}
            <p class="mt-1 text-xs text-red-500 dark:text-red-400">{svc.detail}</p>
          {/if}
        </div>
      {/each}
    </div>
  {/if}
</div>

<!-- ═══════════════════════════════════════════════════════════════ -->
<!-- OPERATIONAL METRICS                                            -->
<!-- ═══════════════════════════════════════════════════════════════ -->

<div class="mb-6">
  <h2 class="mb-3 text-xs font-semibold uppercase tracking-wider text-secondary-500 dark:text-secondary-400">Operational Metrics</h2>

  {#if metricsLoading}
    <div class="flex items-center gap-2 py-4 text-secondary-500">
      <Spinner size="5" /> Loading metrics…
    </div>
  {:else if metricsError}
    <div class="rounded-lg border border-red-200 bg-red-50 p-4 text-sm text-red-700 dark:border-red-800 dark:bg-red-900/20 dark:text-red-400">
      {metricsError}
    </div>
  {:else if metrics}
    <div class="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-5">
      <div class="rounded-lg bg-secondary-50 p-4 text-center dark:bg-secondary-800">
        <div class="text-2xl font-bold text-secondary-800 dark:text-white">{metrics.orders.totalOrders}</div>
        <div class="text-xs text-secondary-500 dark:text-secondary-400">Total Orders</div>
      </div>
      <div class="rounded-lg bg-secondary-50 p-4 text-center dark:bg-secondary-800">
        <div class="text-2xl font-bold text-secondary-800 dark:text-white">{metrics.orders.ordersToday}</div>
        <div class="text-xs text-secondary-500 dark:text-secondary-400">Orders Today</div>
      </div>
      <div class="rounded-lg bg-secondary-50 p-4 text-center dark:bg-secondary-800">
        <div class="text-2xl font-bold text-primary-600 dark:text-primary-400">{metrics.orders.activeOrders}</div>
        <div class="text-xs text-secondary-500 dark:text-secondary-400">Active Orders</div>
      </div>
      <div class="rounded-lg bg-secondary-50 p-4 text-center dark:bg-secondary-800">
        <div class="text-2xl font-bold text-secondary-800 dark:text-white">{metrics.catalogue.activeItems}</div>
        <div class="text-xs text-secondary-500 dark:text-secondary-400">Menu Items</div>
      </div>
      <div class="rounded-lg bg-secondary-50 p-4 text-center dark:bg-secondary-800">
        <div class="text-2xl font-bold text-secondary-800 dark:text-white">{metrics.governance.complianceRate}</div>
        <div class="mb-1 h-2 w-full overflow-hidden rounded-full bg-secondary-200 dark:bg-secondary-700">
          <div class="{complianceBarColour} h-2 rounded-full transition-all duration-500" style="width: {complianceRate}%"></div>
        </div>
        <div class="text-xs text-secondary-500 dark:text-secondary-400">Compliance · {metrics.governance.dataGaps} gaps</div>
      </div>
    </div>
  {/if}
</div>

<!-- ═══════════════════════════════════════════════════════════════ -->
<!-- CATALOGUE & INVENTORY                                          -->
<!-- ═══════════════════════════════════════════════════════════════ -->

{#if metrics}
  <div class="mb-6">
    <h2 class="mb-3 text-xs font-semibold uppercase tracking-wider text-secondary-500 dark:text-secondary-400">Catalogue & Inventory</h2>
    <div class="grid gap-3 lg:grid-cols-2">
      <!-- Categories -->
      <div class="rounded-lg border border-secondary-200 p-4 dark:border-secondary-700">
        <p class="mb-2 text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-500">Categories</p>
        <div class="flex flex-wrap gap-2">
          {#each Object.entries(metrics.catalogue.categories) as [cat, count]}
            <span class="rounded-full bg-primary-100 px-3 py-1 text-sm font-medium text-primary-700 dark:bg-primary-900/30 dark:text-primary-300">
              {formatCategoryName(cat)}: {count}
            </span>
          {/each}
        </div>
        <p class="mt-2 text-xs text-secondary-400 dark:text-secondary-500">
          {metrics.catalogue.totalItems} total items ({metrics.catalogue.activeItems} active)
        </p>
      </div>

      <!-- Stock alerts -->
      <div class="rounded-lg border border-secondary-200 p-4 dark:border-secondary-700">
        <p class="mb-2 text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-500">Stock Alerts</p>
        {#if metrics.inventory.lowStockItems === 0 && metrics.inventory.outOfStockItems === 0}
          <p class="text-sm text-green-600 dark:text-green-400">All stock levels normal</p>
        {:else}
          <div class="flex gap-4">
            {#if metrics.inventory.lowStockItems > 0}
              <span class="text-sm text-yellow-600 dark:text-yellow-400">⚠ {metrics.inventory.lowStockItems} low stock</span>
            {/if}
            {#if metrics.inventory.outOfStockItems > 0}
              <span class="text-sm text-red-600 dark:text-red-400">✗ {metrics.inventory.outOfStockItems} out of stock</span>
            {/if}
          </div>
        {/if}
        <p class="mt-2 text-xs text-secondary-400 dark:text-secondary-500">
          {metrics.inventory.trackedItems} bought-in items tracked ·
          <a href="/management/catalogue" class="text-primary-600 hover:underline dark:text-primary-400">Manage stock</a>
        </p>
      </div>
    </div>
  </div>
{/if}

<!-- ═══════════════════════════════════════════════════════════════ -->
<!-- STRUCTURAL INVENTORY                                           -->
<!-- ═══════════════════════════════════════════════════════════════ -->

<div class="mb-6">
  <h2 class="mb-3 text-xs font-semibold uppercase tracking-wider text-secondary-500 dark:text-secondary-400">Structural Inventory</h2>
  <div class="rounded-lg border border-secondary-200 p-4 dark:border-secondary-700">
    <div class="grid grid-cols-2 gap-x-6 gap-y-2 text-sm sm:grid-cols-3 lg:grid-cols-4">
      <div><span class="text-secondary-400 dark:text-secondary-500">Persistence Layers:</span> <span class="font-medium text-secondary-700 dark:text-secondary-300">3</span></div>
      <div><span class="text-secondary-400 dark:text-secondary-500">SysML Packages:</span> <span class="font-medium text-secondary-700 dark:text-secondary-300">72</span></div>
      <div><span class="text-secondary-400 dark:text-secondary-500">Model Files:</span> <span class="font-medium text-secondary-700 dark:text-secondary-300">10</span></div>
      <div><span class="text-secondary-400 dark:text-secondary-500">API Routes:</span> <span class="font-medium text-secondary-700 dark:text-secondary-300">19</span></div>
      <div><span class="text-secondary-400 dark:text-secondary-500">Frontend Pages:</span> <span class="font-medium text-secondary-700 dark:text-secondary-300">9</span></div>
      <div><span class="text-secondary-400 dark:text-secondary-500">Temporal Workflows:</span> <span class="font-medium text-secondary-700 dark:text-secondary-300">1</span></div>
      <div><span class="text-secondary-400 dark:text-secondary-500">CDR Archetypes:</span> <span class="font-medium text-secondary-700 dark:text-secondary-300">3</span></div>
      <div><span class="text-secondary-400 dark:text-secondary-500">PostgreSQL Tables:</span> <span class="font-medium text-secondary-700 dark:text-secondary-300">4</span></div>
    </div>
    <p class="mt-3 text-xs text-secondary-400 dark:text-secondary-500 italic">
      Static values from the strategic snapshot. Future: populated from the generated System Model Manifest.
    </p>
  </div>
</div>

<!-- ═══════════════════════════════════════════════════════════════ -->
<!-- SELF-ASSESSMENT — KL INCREMENT 3 PLACEHOLDER                   -->
<!-- ═══════════════════════════════════════════════════════════════ -->

<div class="mb-6">
  <h2 class="mb-3 text-xs font-semibold uppercase tracking-wider text-secondary-500 dark:text-secondary-400">Self-Assessment</h2>
  <div class="rounded-lg border-2 border-dashed border-secondary-300 p-6 dark:border-secondary-600">
    <Badge color="dark" class="mb-3 text-xs">Knowledge Layer Increment 3 — Placeholder</Badge>
    <p class="text-sm text-secondary-600 dark:text-secondary-400">
      This panel will be populated when Knowledge Layer Increment 3 is implemented: the five-layer self-knowledge
      architecture running in the coffee shop context.
    </p>
    <div class="mt-4 space-y-1.5 text-xs text-secondary-500 dark:text-secondary-500">
      <p><span class="font-semibold text-secondary-600 dark:text-secondary-400">Layer 1 · ConstraintEvaluator:</span> "Is this order valid against current catalogue rules?"</p>
      <p><span class="font-semibold text-secondary-600 dark:text-secondary-400">Layer 2 · OperationalStateAggregator:</span> "N orders today, N active, preparation rate N%"</p>
      <p><span class="font-semibold text-secondary-600 dark:text-secondary-400">Layer 3 · GoalProjector:</span> "At current throughput, will we meet today's target?"</p>
      <p><span class="font-semibold text-secondary-600 dark:text-secondary-400">Layer 4 · GapAnalyser:</span> "3 orders are waiting longer than the 30-minute threshold"</p>
      <p><span class="font-semibold text-secondary-600 dark:text-secondary-400">Layer 5 · RemediationPlanner:</span> "Consider adding a second barista during peak hours"</p>
    </div>
    <div class="mt-4 rounded-lg bg-secondary-50 p-3 dark:bg-secondary-800/50">
      <p class="text-xs text-secondary-500 dark:text-secondary-400 italic">
        <strong>Clinical analogy:</strong> "Is the service meeting its obligations? Are any patients overdue for monitoring?
        What should the service prioritise next?" — the five-layer architecture answers these questions from model-defined
        constraints and live operational data.
      </p>
    </div>
  </div>
</div>

<!-- ═══════════════════════════════════════════════════════════════ -->
<!-- CROSS-PAGE LINKS                                               -->
<!-- ═══════════════════════════════════════════════════════════════ -->

<div class="text-xs text-secondary-400 dark:text-secondary-500">
  <a href="/governance" class="text-primary-600 hover:underline dark:text-primary-400">Audit Dashboard</a> ·
  <a href="/management/catalogue" class="text-primary-600 hover:underline dark:text-primary-400">Stock & Catalogue</a> ·
  <a href="/pathway" class="text-primary-600 hover:underline dark:text-primary-400">Process Model</a> ·
  <a href="/orders" class="text-primary-600 hover:underline dark:text-primary-400">Order Board</a>
</div>
