<script lang="ts">
  import { onMount } from 'svelte';
  import { Badge, Button, Spinner, Alert, Table, TableHead, TableHeadCell, TableBody, TableBodyRow, TableBodyCell } from 'flowbite-svelte';
  import { anonymiseCaseRef } from '@coffeeshop/shared/dist/workflow-constants.js';

  // ── Types ──

  interface ActiveOrder {
    orderId: string;
    state: string;
    startTime: string | null;
  }

  interface WorkflowSummary {
    workflowId: string;
    caseRef: string;
    status: string;
    startTime: string | null;
    closeTime: string | null;
  }

  // ── Kanban column configuration ──

  const KANBAN_COLUMNS: { key: string; label: string; icon: string; borderColor: string; badgeColor: 'blue' | 'yellow' | 'green' }[] = [
    { key: 'placed',        label: 'Placed',          icon: '📝', borderColor: 'border-blue-300 dark:border-blue-700',    badgeColor: 'blue' },
    { key: 'inPreparation', label: 'In Preparation',   icon: '☕', borderColor: 'border-yellow-300 dark:border-yellow-700', badgeColor: 'yellow' },
    { key: 'ready',         label: 'Ready',            icon: '✅', borderColor: 'border-green-300 dark:border-green-700',   badgeColor: 'green' },
  ];

  // ── XState lifecycle state config (for kanban cards) ──

  const STATE_ACTIONS: Record<string, { signal: string; label: string } | null> = {
    placed:        { signal: 'baristaStarted', label: 'Start Prep' },
    inPreparation: { signal: 'drinkReady',     label: 'Mark Ready' },
    ready:         { signal: 'drinkCollected',  label: 'Collect' },
    collected:     null,
    cancelled:     null,
  };

  const STATE_LABELS: Record<string, string> = {
    placed:        'Placed',
    inPreparation: 'In Preparation',
    ready:         'Ready',
    collected:     'Collected',
    cancelled:     'Cancelled',
    unknown:       'Starting…',
  };

  const STATE_COLORS: Record<string, 'blue' | 'yellow' | 'green' | 'dark' | 'red'> = {
    placed:        'blue',
    inPreparation: 'yellow',
    ready:         'green',
    collected:     'dark',
    cancelled:     'red',
    unknown:       'dark',
  };

  // ── Temporal execution status config (for history table) ──

  const TEMPORAL_STATUS_LABELS: Record<string, string> = {
    RUNNING:    'Running',
    COMPLETED:  'Completed',
    FAILED:     'Failed',
    CANCELLED:  'Cancelled',
    TERMINATED: 'Terminated',
    TIMED_OUT:  'Timed out',
  };

  const TEMPORAL_STATUS_COLORS: Record<string, 'green' | 'blue' | 'red' | 'dark' | 'yellow'> = {
    RUNNING:    'green',
    COMPLETED:  'blue',
    FAILED:     'red',
    CANCELLED:  'dark',
    TERMINATED: 'red',
    TIMED_OUT:  'yellow',
  };

  // ── State ──

  let activeOrders = $state<ActiveOrder[]>([]);
  let allWorkflows = $state<WorkflowSummary[]>([]);
  let loading = $state(true);
  let errorMessage = $state('');
  let sendingSignal = $state<string | null>(null);
  let showHistory = $state(false);

  // ── Derived ──

  let ordersByState = $derived.by(() => {
    const groups: Record<string, ActiveOrder[]> = {};
    for (const col of KANBAN_COLUMNS) {
      groups[col.key] = [];
    }
    for (const order of activeOrders) {
      if (groups[order.state]) {
        groups[order.state].push(order);
      }
    }
    return groups;
  });

  let completedWorkflows = $derived(
    allWorkflows.filter(wf =>
      wf.status === 'COMPLETED' || wf.status === 'FAILED' ||
      wf.status === 'CANCELLED' || wf.status === 'TERMINATED' ||
      wf.status === 'TIMED_OUT'
    )
  );

  // ── Data fetching ──

  async function fetchAll() {
    try {
      const [activeRes, listRes] = await Promise.all([
        fetch('/api/orders/active'),
        fetch('/api/orders/list'),
      ]);

      if (!activeRes.ok || !listRes.ok) {
        errorMessage = 'Failed to load order data';
        return;
      }

      const activeData = await activeRes.json();
      const listData = await listRes.json();
      activeOrders = activeData.orders;
      allWorkflows = listData.workflows;
      errorMessage = '';
    } catch (err) {
      errorMessage = err instanceof Error ? err.message : 'Failed to load data';
    } finally {
      loading = false;
    }
  }

  // ── Signal actions ──

  async function sendSignal(orderId: string, signalName: string) {
    sendingSignal = orderId;
    try {
      const response = await fetch(`/api/orders/${orderId}/signal`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ signal: signalName }),
      });
      if (!response.ok) {
        const data = await response.json();
        errorMessage = data.message || `Signal failed: ${response.status}`;
        return;
      }
      await fetchAll();
    } catch (err) {
      errorMessage = err instanceof Error ? err.message : 'Failed to send signal';
    } finally {
      sendingSignal = null;
    }
  }

  // ── Helpers ──

  function timeElapsed(startTime: string | null): string {
    if (!startTime) return '';
    const diffMs = Date.now() - new Date(startTime).getTime();
    const diffMins = Math.floor(diffMs / 60000);
    if (diffMins < 1) return 'just now';
    if (diffMins < 60) return `${diffMins}m ago`;
    const diffHours = Math.floor(diffMins / 60);
    return `${diffHours}h ${diffMins % 60}m ago`;
  }

  function formatTimestamp(iso: string | null): string {
    if (!iso) return '—';
    return new Date(iso).toLocaleString();
  }

  // ── Lifecycle ──

  let pollInterval: ReturnType<typeof setInterval> | null = null;

  onMount(() => {
    fetchAll();
    pollInterval = setInterval(fetchAll, 5000);
    return () => { if (pollInterval) clearInterval(pollInterval); };
  });
</script>

<!-- Page Header -->
<div class="mb-6">
  <h1 class="text-2xl font-bold text-secondary-800 dark:text-white">Order Board</h1>
  <p class="text-sm text-secondary-500 dark:text-secondary-400">
    Live operational view.
    <a href="/" class="text-primary-600 hover:underline dark:text-primary-400">Place a new order</a>
  </p>
</div>

{#if loading}
  <div class="flex items-center gap-2 text-secondary-500">
    <Spinner size="5" /> Loading orders…
  </div>
{:else if errorMessage}
  <Alert color="red" class="mb-4">
    <span class="font-medium">Error:</span> {errorMessage}
  </Alert>
{:else}

  <!-- Summary stats -->
  <div class="mb-4 flex flex-wrap gap-4 text-sm text-secondary-600 dark:text-secondary-400">
    <span>{activeOrders.length} active order{activeOrders.length !== 1 ? 's' : ''}</span>
    <span class="text-secondary-300 dark:text-secondary-600">|</span>
    <span>{ordersByState['placed']?.length ?? 0} waiting</span>
    <span>{ordersByState['inPreparation']?.length ?? 0} in preparation</span>
    <span>{ordersByState['ready']?.length ?? 0} ready for collection</span>
  </div>

  <!-- Kanban columns -->
  {#if activeOrders.length === 0}
    <div class="mb-8 rounded-lg border-2 border-dashed border-secondary-200 p-8 text-center dark:border-secondary-700">
      <p class="text-secondary-500 dark:text-secondary-400">
        No active orders. <a href="/" class="text-primary-600 hover:underline dark:text-primary-400">Place a new order</a> to see it here.
      </p>
    </div>
  {:else}
    <div class="mb-8 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
      {#each KANBAN_COLUMNS as col}
        <div class="rounded-lg border-t-4 {col.borderColor} bg-secondary-50 p-3 dark:bg-secondary-800/50">
          <!-- Column header -->
          <div class="mb-3 flex items-center justify-between">
            <h3 class="text-sm font-semibold text-secondary-700 dark:text-secondary-300">
              {col.icon} {col.label}
            </h3>
            <Badge color={col.badgeColor} class="text-xs">{ordersByState[col.key]?.length ?? 0}</Badge>
          </div>

          <!-- Cards -->
          {#if (ordersByState[col.key]?.length ?? 0) === 0}
            <p class="py-4 text-center text-xs italic text-secondary-400 dark:text-secondary-500">
              No orders
            </p>
          {:else}
            {#each ordersByState[col.key] as order}
              <div class="mb-2 rounded-lg border border-secondary-200 bg-white p-3 shadow-sm dark:border-secondary-700 dark:bg-secondary-800">
                <!-- Case ref and time elapsed -->
                <div class="mb-2 flex items-center justify-between">
                  <code class="text-xs font-medium text-secondary-700 dark:text-secondary-300">
                    {anonymiseCaseRef(order.orderId)}
                  </code>
                  <span class="text-xs text-secondary-400 dark:text-secondary-500">
                    {timeElapsed(order.startTime)}
                  </span>
                </div>

                <!-- State badge -->
                <div class="mb-2">
                  <Badge color={STATE_COLORS[order.state] ?? 'dark'} class="text-xs">
                    {STATE_LABELS[order.state] ?? order.state}
                  </Badge>
                </div>

                <!-- Action button -->
                {#if STATE_ACTIONS[order.state]}
                  {@const act = STATE_ACTIONS[order.state]!}
                  <Button
                    size="xs"
                    color="primary"
                    outline
                    onclick={() => sendSignal(order.orderId, act.signal)}
                    disabled={sendingSignal === order.orderId}
                  >
                    {sendingSignal === order.orderId ? 'Sending…' : act.label}
                  </Button>
                {/if}

                <!-- Detail link -->
                <a href="/orders/{order.orderId}" class="mt-2 block text-xs text-primary-600 hover:underline dark:text-primary-400">
                  View details →
                </a>
              </div>
            {/each}
          {/if}
        </div>
      {/each}
    </div>
  {/if}

  <!-- Historical orders (collapsible) -->
  <div class="mt-4">
    <button
      class="flex items-center gap-2 text-sm font-semibold text-secondary-600 hover:text-secondary-800 dark:text-secondary-400 dark:hover:text-secondary-200"
      onclick={() => showHistory = !showHistory}
    >
      <span class="text-xs">{showHistory ? '▼' : '▶'}</span>
      Completed Orders
      <Badge color="dark" class="text-xs">{completedWorkflows.length}</Badge>
    </button>

    {#if showHistory}
      <div class="mt-3">
        {#if completedWorkflows.length === 0}
          <p class="text-sm italic text-secondary-400 dark:text-secondary-500">No completed orders yet.</p>
        {:else}
          <Table striped>
            <TableHead>
              <TableHeadCell>Case Ref</TableHeadCell>
              <TableHeadCell>Status</TableHeadCell>
              <TableHeadCell class="hidden sm:table-cell">Started</TableHeadCell>
              <TableHeadCell class="hidden sm:table-cell">Completed</TableHeadCell>
              <TableHeadCell>Actions</TableHeadCell>
            </TableHead>
            <TableBody>
              {#each completedWorkflows as wf}
                <TableBodyRow>
                  <TableBodyCell>
                    <code class="text-xs">{wf.caseRef}</code>
                  </TableBodyCell>
                  <TableBodyCell>
                    {@const cfg = TEMPORAL_STATUS_COLORS[wf.status]}
                    <Badge color={cfg ?? 'dark'} class="text-xs">
                      {TEMPORAL_STATUS_LABELS[wf.status] ?? wf.status}
                    </Badge>
                  </TableBodyCell>
                  <TableBodyCell class="hidden text-xs sm:table-cell">
                    {formatTimestamp(wf.startTime)}
                  </TableBodyCell>
                  <TableBodyCell class="hidden text-xs sm:table-cell">
                    {formatTimestamp(wf.closeTime)}
                  </TableBodyCell>
                  <TableBodyCell>
                    <a href="/orders/{wf.workflowId}" class="text-xs text-primary-600 hover:underline dark:text-primary-400">
                      Details
                    </a>
                    {#if wf.status === 'COMPLETED'}
                      <span class="mx-1 text-secondary-300">|</span>
                      <a href="/orders/{wf.workflowId}/audit" class="text-xs text-primary-600 hover:underline dark:text-primary-400">
                        Audit
                      </a>
                    {/if}
                  </TableBodyCell>
                </TableBodyRow>
              {/each}
            </TableBody>
          </Table>
        {/if}
      </div>
    {/if}
  </div>

{/if}
