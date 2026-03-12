<script lang="ts">
  import { Button, Alert, Spinner, Badge, Table, TableHead, TableHeadCell, TableBody, TableBodyRow, TableBodyCell } from 'flowbite-svelte';

  let loading = $state(false);
  let errorMessage = $state('');
  let activeView = $state<'all' | 'today' | 'customer'>('all');
  let ehrIdInput = $state('');

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

  let orders = $state<OrderRow[]>([]);
  let viewMeta = $state<Record<string, unknown>>({});

  async function fetchEntityView(view: 'all' | 'today' | 'customer') {
    loading = true;
    errorMessage = '';
    orders = [];
    viewMeta = {};
    activeView = view;

    let url = '/api/entity/orders';
    if (view === 'today') url = '/api/entity/orders/today';
    else if (view === 'customer') {
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

  function formatTime(iso: string): string {
    try { return new Date(iso).toLocaleString(); } catch { return iso; }
  }
</script>

<div class="mb-6">
  <h1 class="text-2xl font-bold text-secondary-800 dark:text-white">Records</h1>
  <p class="text-sm text-secondary-500 dark:text-secondary-400">
    Data from the CDR (EHRbase), organised by type — not by process.
    Compare with <a href="/orders" class="text-primary-600 hover:underline dark:text-primary-400">Orders (process view)</a>.
  </p>
</div>

<div class="mb-4 flex flex-wrap items-end gap-2">
  <Button color="light" onclick={() => fetchEntityView('all')} disabled={loading}>All Orders</Button>
  <Button color="light" onclick={() => fetchEntityView('today')} disabled={loading}>Today's Orders</Button>
  <div class="flex items-end gap-2">
    <div>
      <label for="ehrId" class="mb-1 block text-sm text-secondary-600 dark:text-secondary-400">EHR ID</label>
      <input id="ehrId" type="text" bind:value={ehrIdInput} placeholder="paste EHR UUID"
        class="rounded-lg border border-secondary-300 bg-secondary-50 px-3 py-2 text-sm text-secondary-900 focus:border-primary-500 focus:ring-primary-500 dark:border-secondary-600 dark:bg-secondary-700 dark:text-white dark:placeholder-secondary-400" />
    </div>
    <Button color="light" onclick={() => fetchEntityView('customer')} disabled={loading || !ehrIdInput.trim()}>Customer Orders</Button>
  </div>
</div>

{#if errorMessage}
  <Alert color="red" class="mb-4">{errorMessage}</Alert>
{/if}

{#if loading}
  <div class="flex items-center gap-2 text-secondary-500"><Spinner size="5" /> Loading…</div>
{/if}

{#if Object.keys(viewMeta).length > 0}
  <div class="mb-4 flex flex-wrap gap-3 rounded-lg bg-secondary-50 px-4 py-2 text-xs text-secondary-600 dark:bg-secondary-800 dark:text-secondary-400">
    <span><strong>Source:</strong> {viewMeta.source}</span>
    <span><strong>View:</strong> {viewMeta.view}</span>
    <span><strong>Count:</strong> {viewMeta.count}</span>
    {#if viewMeta.date}<span><strong>Date:</strong> {viewMeta.date}</span>{/if}
    {#if viewMeta.ehrId}<span><strong>EHR:</strong> <code>{viewMeta.ehrId}</code></span>{/if}
  </div>
{/if}

{#if orders.length > 0}
  <Table striped={true}>
    <TableHead>
      {#if activeView !== 'customer'}<TableHeadCell>EHR ID</TableHeadCell>{/if}
      <TableHeadCell>Order Time</TableHeadCell>
      <TableHeadCell>Drink</TableHeadCell>
      <TableHeadCell>Size</TableHeadCell>
      {#if activeView === 'customer'}
        <TableHeadCell>Milk</TableHeadCell>
        <TableHeadCell>Extras</TableHeadCell>
      {/if}
      <TableHeadCell>Price</TableHeadCell>
      <TableHeadCell>Composition UID</TableHeadCell>
    </TableHead>
    <TableBody>
      {#each orders as order}
        <TableBodyRow>
          {#if activeView !== 'customer'}<TableBodyCell><code class="text-xs">{order.ehrId}</code></TableBodyCell>{/if}
          <TableBodyCell class="text-sm">{formatTime(order.orderTime)}</TableBodyCell>
          <TableBodyCell>{order.drinkName}</TableBodyCell>
          <TableBodyCell>{order.drinkSize}</TableBodyCell>
          {#if activeView === 'customer'}
            <TableBodyCell>{order.milkChoice ?? '—'}</TableBodyCell>
            <TableBodyCell>{order.extras ?? '—'}</TableBodyCell>
          {/if}
          <TableBodyCell>{order.price}</TableBodyCell>
          <TableBodyCell><code class="text-xs">{order.compositionUid}</code></TableBodyCell>
        </TableBodyRow>
      {/each}
    </TableBody>
  </Table>
{:else if !loading && Object.keys(viewMeta).length > 0}
  <p class="text-sm text-secondary-500">No orders found.</p>
{/if}
