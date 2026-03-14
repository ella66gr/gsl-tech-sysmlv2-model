<script lang="ts">
  import { onMount } from 'svelte';
  import { Badge, Button, Alert, Spinner, Input, Label, Table, TableHead, TableHeadCell, TableBody, TableBodyRow, TableBodyCell } from 'flowbite-svelte';

  // ── Types ──

  interface OrderRow {
    ehrId?: string;
    compositionUid: string;
    orderTime: string;
    drinkName: string;
    drinkSize: string;
    milkChoice?: string | null;
    extras?: string | null;
    price: string;
  }

  // ── State ──

  type ViewTab = 'all' | 'today' | 'customer';
  type ViewMode = 'cards' | 'table';

  let activeTab = $state<ViewTab>('all');
  let viewMode = $state<ViewMode>('cards');
  let ehrIdInput = $state('');
  let orders = $state<OrderRow[]>([]);
  let loading = $state(true);
  let errorMessage = $state('');
  let viewMeta = $state<Record<string, unknown>>({});

  // ── Tab configuration ──

  const TABS: { key: ViewTab; label: string }[] = [
    { key: 'all',      label: 'All Orders' },
    { key: 'today',    label: 'Today' },
    { key: 'customer', label: 'By Customer' },
  ];

  const AQL_DESCRIPTIONS: Record<ViewTab, { type: string; analogy: string }> = {
    all:      { type: 'All compositions by type',    analogy: '"Show me all lab results across all patients"' },
    today:    { type: 'Date-filtered compositions',   analogy: '"Show me all consultations today"' },
    customer: { type: 'Patient-scoped compositions',  analogy: '"Show me all lab results for this patient"' },
  };

  // ── Data fetching ──

  async function fetchOrders(tab: ViewTab) {
    loading = true;
    errorMessage = '';
    orders = [];
    viewMeta = {};

    let url = '/api/entity/orders';
    if (tab === 'today') url = '/api/entity/orders/today';
    else if (tab === 'customer') {
      if (!ehrIdInput.trim()) { errorMessage = 'Please enter an EHR ID'; loading = false; return; }
      url = `/api/entity/customers/${encodeURIComponent(ehrIdInput.trim())}/orders`;
    }

    try {
      const response = await fetch(url);
      if (!response.ok) {
        const data = await response.json();
        errorMessage = data.message || `Error: ${response.status}`;
        return;
      }
      const data = await response.json();
      orders = data.orders ?? [];
      viewMeta = {
        view: data.view, source: data.source, count: data.count,
        ...(data.date ? { date: data.date } : {}),
        ...(data.ehrId ? { ehrId: data.ehrId } : {}),
      };
    } catch (err) {
      errorMessage = err instanceof Error ? err.message : 'Failed to fetch entity view';
    } finally {
      loading = false;
    }
  }

  function switchTab(tab: ViewTab) {
    activeTab = tab;
    if (tab !== 'customer') {
      fetchOrders(tab);
    } else {
      // Clear results when switching to customer tab — user needs to enter EHR ID
      orders = [];
      viewMeta = {};
      loading = false;
    }
  }

  // ── Auto-load on mount ──

  onMount(() => {
    fetchOrders('all');
  });

  // ── Helpers ──

  function formatOrderTime(iso: string): string {
    try {
      const date = new Date(iso);
      const now = new Date();
      const isToday = date.toDateString() === now.toDateString();
      const yesterday = new Date(now);
      yesterday.setDate(yesterday.getDate() - 1);
      const isYesterday = date.toDateString() === yesterday.toDateString();

      const time = date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
      if (isToday) return `${time} today`;
      if (isYesterday) return `Yesterday ${time}`;
      return date.toLocaleDateString([], { day: 'numeric', month: 'short' }) + ` ${time}`;
    } catch {
      return iso;
    }
  }

  function formatTimestamp(iso: string): string {
    try { return new Date(iso).toLocaleString(); } catch { return iso; }
  }
</script>

<!-- Page header -->
<div class="mb-6">
  <div class="flex items-center gap-3">
    <h1 class="text-2xl font-bold text-secondary-800 dark:text-white">Records</h1>
    <Badge color="indigo">CDR · EHRbase</Badge>
  </div>
  <p class="text-sm text-secondary-500 dark:text-secondary-400">
    Entity view — data organised by type, not by process.
    Compare with <a href="/orders" class="text-primary-600 hover:underline dark:text-primary-400">Order Board</a> (process view).
  </p>
</div>

<!-- Tabs -->
<div class="mb-4 border-b border-secondary-200 dark:border-secondary-700">
  <ul class="-mb-px flex flex-wrap text-sm font-medium">
    {#each TABS as tab}
      <li>
        <button
          onclick={() => switchTab(tab.key)}
          class="inline-block rounded-t-lg border-b-2 px-4 py-2.5 {activeTab === tab.key
            ? 'border-primary-600 text-primary-600 dark:border-primary-400 dark:text-primary-400'
            : 'border-transparent text-secondary-500 hover:border-secondary-300 hover:text-secondary-600 dark:text-secondary-400 dark:hover:border-secondary-600 dark:hover:text-secondary-300'}"
        >{tab.label}</button>
      </li>
    {/each}
  </ul>
</div>

<!-- Customer EHR ID input (shown only for customer tab) -->
{#if activeTab === 'customer'}
  <div class="mb-4 flex items-end gap-2">
    <div class="max-w-sm flex-1">
      <Label for="ehrId" class="mb-1 text-xs">EHR ID</Label>
      <Input id="ehrId" size="sm" bind:value={ehrIdInput} placeholder="Paste EHR UUID" />
    </div>
    <Button size="sm" color="primary" onclick={() => fetchOrders('customer')} disabled={loading || !ehrIdInput.trim()}>
      Load
    </Button>
  </div>
{/if}

{#if errorMessage}
  <Alert color="red" class="mb-4">{errorMessage}</Alert>
{/if}

<!-- Metadata bar and view toggle -->
{#if !loading}
  <div class="mb-4 flex items-center justify-between">
    <div class="flex flex-wrap items-center gap-3 text-sm text-secondary-500 dark:text-secondary-400">
      <span>{orders.length} record{orders.length !== 1 ? 's' : ''}</span>
      {#if viewMeta.date}
        <span>· {viewMeta.date}</span>
      {/if}
      {#if viewMeta.ehrId}
        <span>· Customer <code class="text-xs">{String(viewMeta.ehrId).substring(0, 8)}…</code></span>
      {/if}
      <span class="text-xs text-secondary-400 dark:text-secondary-500">Source: AQL → EHRbase</span>
    </div>

    {#if orders.length > 0}
      <div class="flex overflow-hidden rounded-lg border border-secondary-200 dark:border-secondary-700">
        <button
          class="px-3 py-1.5 text-xs font-medium {viewMode === 'cards'
            ? 'bg-primary-100 text-primary-700 dark:bg-primary-900/30 dark:text-primary-300'
            : 'text-secondary-500 hover:bg-secondary-50 dark:text-secondary-400 dark:hover:bg-secondary-800'}"
          onclick={() => viewMode = 'cards'}
        >Cards</button>
        <button
          class="px-3 py-1.5 text-xs font-medium {viewMode === 'table'
            ? 'bg-primary-100 text-primary-700 dark:bg-primary-900/30 dark:text-primary-300'
            : 'text-secondary-500 hover:bg-secondary-50 dark:text-secondary-400 dark:hover:bg-secondary-800'}"
          onclick={() => viewMode = 'table'}
        >Table</button>
      </div>
    {/if}
  </div>
{/if}

<!-- AQL query details (collapsible) -->
{#if !loading && orders.length > 0}
  <details class="mb-4">
    <summary class="cursor-pointer text-xs text-secondary-400 hover:text-secondary-600 dark:text-secondary-500 dark:hover:text-secondary-300">
      AQL query details
    </summary>
    <div class="mt-2 rounded-lg bg-secondary-50 p-3 text-xs dark:bg-secondary-800/50">
      <p class="mb-1 text-secondary-600 dark:text-secondary-400">
        <strong>Query type:</strong> {AQL_DESCRIPTIONS[activeTab].type}
      </p>
      <p class="mb-1 text-secondary-600 dark:text-secondary-400">
        <strong>Clinical analogy:</strong> {AQL_DESCRIPTIONS[activeTab].analogy}
      </p>
      <p class="text-secondary-500 dark:text-secondary-400">
        <strong>Archetype:</strong> <code>openEHR-EHR-OBSERVATION.order_record.v0</code>
      </p>
    </div>
  </details>
{/if}

<!-- Loading state -->
{#if loading}
  <div class="flex items-center gap-2 py-8 text-secondary-500 dark:text-secondary-400">
    <Spinner size="5" /> Loading records from CDR…
  </div>
{:else if orders.length === 0 && Object.keys(viewMeta).length > 0}
  <!-- Empty state (after a query returned 0 results) -->
  <div class="rounded-lg border-2 border-dashed border-secondary-200 p-8 text-center text-sm text-secondary-400 dark:border-secondary-700 dark:text-secondary-500">
    {#if activeTab === 'today'}
      No orders placed today.
    {:else if activeTab === 'customer'}
      No orders found for this customer. Check the EHR ID and try again.
    {:else}
      No records found. Place an order from the <a href="/" class="text-primary-600 hover:underline dark:text-primary-400">Counter</a> to see records here.
    {/if}
  </div>
{:else if orders.length === 0 && activeTab === 'customer'}
  <!-- Waiting for customer input -->
  <div class="rounded-lg border-2 border-dashed border-secondary-200 p-8 text-center text-sm text-secondary-400 dark:border-secondary-700 dark:text-secondary-500">
    Enter an EHR ID above to view customer records.
  </div>
{:else if viewMode === 'cards'}
  <!-- Card view -->
  <div class="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
    {#each orders as order}
      <div class="rounded-lg border border-secondary-200 bg-white p-4 dark:border-secondary-700 dark:bg-secondary-800">
        <!-- Header: drink name + price -->
        <div class="mb-2 flex items-start justify-between">
          <div>
            <h3 class="font-semibold text-secondary-800 dark:text-white">{order.drinkName}</h3>
            <p class="text-sm text-secondary-500 dark:text-secondary-400">
              {order.drinkSize}{#if order.milkChoice} · {order.milkChoice}{/if}
            </p>
          </div>
          <span class="text-lg font-bold text-primary-700 dark:text-primary-300">{order.price}</span>
        </div>

        <!-- Metadata -->
        <div class="flex flex-wrap gap-x-2 gap-y-1 text-xs text-secondary-400 dark:text-secondary-500">
          <span>{formatOrderTime(order.orderTime)}</span>
          {#if order.ehrId}
            <span>· EHR: <code>{order.ehrId.substring(0, 8)}…</code></span>
          {/if}
        </div>
      </div>
    {/each}
  </div>
{:else}
  <!-- Table view -->
  <Table striped={true}>
    <TableHead>
      {#if activeTab !== 'customer'}<TableHeadCell>EHR ID</TableHeadCell>{/if}
      <TableHeadCell>Order Time</TableHeadCell>
      <TableHeadCell>Drink</TableHeadCell>
      <TableHeadCell>Size</TableHeadCell>
      {#if activeTab === 'customer'}
        <TableHeadCell>Milk</TableHeadCell>
      {/if}
      <TableHeadCell>Price</TableHeadCell>
      <TableHeadCell class="hidden sm:table-cell">Composition UID</TableHeadCell>
    </TableHead>
    <TableBody>
      {#each orders as order}
        <TableBodyRow>
          {#if activeTab !== 'customer'}
            <TableBodyCell><code class="text-xs">{(order.ehrId ?? '').substring(0, 8)}…</code></TableBodyCell>
          {/if}
          <TableBodyCell class="text-sm">{formatOrderTime(order.orderTime)}</TableBodyCell>
          <TableBodyCell>{order.drinkName}</TableBodyCell>
          <TableBodyCell>{order.drinkSize}</TableBodyCell>
          {#if activeTab === 'customer'}
            <TableBodyCell>{order.milkChoice ?? '—'}</TableBodyCell>
          {/if}
          <TableBodyCell>{order.price}</TableBodyCell>
          <TableBodyCell class="hidden sm:table-cell"><code class="text-xs">{order.compositionUid.substring(0, 12)}…</code></TableBodyCell>
        </TableBodyRow>
      {/each}
    </TableBody>
  </Table>
{/if}
