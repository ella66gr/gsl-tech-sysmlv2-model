<script lang="ts">
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
    if (view === 'today') {
      url = '/api/entity/orders/today';
    } else if (view === 'customer') {
      if (!ehrIdInput.trim()) {
        errorMessage = 'Please enter an EHR ID';
        loading = false;
        return;
      }
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
        view: data.view,
        source: data.source,
        count: data.count,
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
    try {
      return new Date(iso).toLocaleString();
    } catch {
      return iso;
    }
  }
</script>

<h1>Entity Views</h1>
<p>Data from the CDR (EHRbase), organised by <strong>type</strong> — not by process.</p>
<p style="color: #666; font-size: 0.9em;">
  Compare with <a href="/orders">Orders (process view)</a> which shows workflow state from Temporal.
</p>

<hr />

<h2>Query</h2>

<div style="display: flex; gap: 0.5em; flex-wrap: wrap; align-items: end;">
  <button onclick={() => fetchEntityView('all')} disabled={loading}>
    All Orders
  </button>
  <button onclick={() => fetchEntityView('today')} disabled={loading}>
    Today's Orders
  </button>
  <span style="display: inline-flex; gap: 0.3em; align-items: end;">
    <label>
      EHR ID:
      <input type="text" bind:value={ehrIdInput} placeholder="paste EHR UUID" style="width: 20em;" />
    </label>
    <button onclick={() => fetchEntityView('customer')} disabled={loading || !ehrIdInput.trim()}>
      Customer Orders
    </button>
  </span>
</div>

{#if errorMessage}
  <p style="color: red; margin-top: 1em;"><strong>Error:</strong> {errorMessage}</p>
{/if}

{#if loading}
  <p>Loading…</p>
{/if}

{#if Object.keys(viewMeta).length > 0}
  <div style="margin-top: 1em; padding: 0.5em; background: #f5f5f5; border-radius: 4px; font-size: 0.85em;">
    <strong>Source:</strong> {viewMeta.source}
    &nbsp;|&nbsp;
    <strong>View:</strong> {viewMeta.view}
    &nbsp;|&nbsp;
    <strong>Count:</strong> {viewMeta.count}
    {#if viewMeta.date}
      &nbsp;|&nbsp;
      <strong>Date:</strong> {viewMeta.date}
    {/if}
    {#if viewMeta.ehrId}
      &nbsp;|&nbsp;
      <strong>EHR:</strong> <code>{viewMeta.ehrId}</code>
    {/if}
  </div>
{/if}

{#if orders.length > 0}
  <table style="margin-top: 1em; border-collapse: collapse; width: 100%;">
    <thead>
      <tr style="border-bottom: 2px solid #333; text-align: left;">
        {#if activeView !== 'customer'}
          <th style="padding: 0.3em 0.5em;">EHR ID</th>
        {/if}
        <th style="padding: 0.3em 0.5em;">Order Time</th>
        <th style="padding: 0.3em 0.5em;">Drink</th>
        <th style="padding: 0.3em 0.5em;">Size</th>
        {#if activeView === 'customer'}
          <th style="padding: 0.3em 0.5em;">Milk</th>
          <th style="padding: 0.3em 0.5em;">Extras</th>
        {/if}
        <th style="padding: 0.3em 0.5em;">Price</th>
        <th style="padding: 0.3em 0.5em;">Composition UID</th>
      </tr>
    </thead>
    <tbody>
      {#each orders as order}
        <tr style="border-bottom: 1px solid #ddd;">
          {#if activeView !== 'customer'}
            <td style="padding: 0.3em 0.5em;"><code style="font-size: 0.75em;">{order.ehrId}</code></td>
          {/if}
          <td style="padding: 0.3em 0.5em;">{formatTime(order.orderTime)}</td>
          <td style="padding: 0.3em 0.5em;">{order.drinkName}</td>
          <td style="padding: 0.3em 0.5em;">{order.drinkSize}</td>
          {#if activeView === 'customer'}
            <td style="padding: 0.3em 0.5em;">{order.milkChoice ?? '—'}</td>
            <td style="padding: 0.3em 0.5em;">{order.extras ?? '—'}</td>
          {/if}
          <td style="padding: 0.3em 0.5em;">{order.price}</td>
          <td style="padding: 0.3em 0.5em;"><code style="font-size: 0.7em;">{order.compositionUid}</code></td>
        </tr>
      {/each}
    </tbody>
  </table>
{:else if !loading && Object.keys(viewMeta).length > 0}
  <p style="margin-top: 1em; color: #666;">No orders found.</p>
{/if}
