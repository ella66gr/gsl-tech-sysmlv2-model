<script lang="ts">
  import { onMount } from 'svelte';
  import { Button, Badge, Alert, Input, Label, Spinner } from 'flowbite-svelte';
  import type { CatalogueItemView } from '@coffeeshop/shared';

  // ── Page data from +page.ts load function ──

  let { data } = $props();

  // ── Category configuration ──

  const CATEGORY_CONFIG: Record<string, { label: string; icon: string; order: number }> = {
    hot_drink:  { label: 'Hot Drinks',  icon: '☕', order: 1 },
    cold_drink: { label: 'Cold Drinks', icon: '🧊', order: 2 },
    food:       { label: 'Food',        icon: '🍪', order: 3 },
  };

  // ── State machine action mapping (same as order detail page) ──

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

  // ── Order form state ──

  let activeCategory = $state('hot_drink');
  let selectedItem = $state<CatalogueItemView | null>(null);
  let selectedSize = $state('');
  let customerName = $state('');
  let submitting = $state(false);
  let errorMessage = $state('');
  let successMessage = $state('');
  let lastOrderId = $state('');

  // ── Active orders state ──

  interface ActiveOrder {
    orderId: string;
    state: string;
    startTime: string | null;
  }

  let activeOrders = $state<ActiveOrder[]>([]);
  let activeOrdersLoading = $state(true);
  let activeOrdersError = $state('');
  let sendingSignal = $state<string | null>(null);

  // ── Derived values ──

  let categories = $derived.by(() => {
    const grouped = new Map<string, CatalogueItemView[]>();
    for (const item of data.catalogue) {
      const existing = grouped.get(item.category) ?? [];
      existing.push(item);
      grouped.set(item.category, existing);
    }

    return Array.from(grouped.entries())
      .map(([key, items]) => ({
        key,
        label: CATEGORY_CONFIG[key]?.label ?? key,
        icon: CATEGORY_CONFIG[key]?.icon ?? '📦',
        items: items.sort((a, b) => a.name.localeCompare(b.name)),
      }))
      .sort((a, b) =>
        (CATEGORY_CONFIG[a.key]?.order ?? 99) - (CATEGORY_CONFIG[b.key]?.order ?? 99)
      );
  });

  let activeCategoryItems = $derived(
    categories.find((c) => c.key === activeCategory)?.items ?? []
  );

  let canSubmit = $derived(
    !!selectedItem &&
    !!customerName.trim() &&
    (selectedItem.availableSizes && selectedItem.availableSizes.length > 0
      ? !!selectedSize
      : true)
  );

  // ── Item selection ──

  function selectItem(item: CatalogueItemView) {
    selectedItem = item;
    // Auto-select size: prefer 'medium' if available, else first option
    const sizes = item.availableSizes ?? [];
    if (sizes.includes('medium')) {
      selectedSize = 'medium';
    } else if (sizes.length > 0) {
      selectedSize = sizes[0];
    } else {
      selectedSize = ''; // Food items — no size
    }
  }

  // ── Place order ──

  async function placeOrder() {
    if (!selectedItem || !customerName.trim()) return;

    submitting = true;
    errorMessage = '';
    successMessage = '';

    try {
      const response = await fetch('/api/orders', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          customerName: customerName.trim(),
          drinkType: selectedItem.name,
          size: selectedSize || 'medium',
        }),
      });

      if (!response.ok) {
        const data = await response.json();
        errorMessage = data.message || `Error: ${response.status}`;
        return;
      }

      const result = await response.json();

      // Success — reset form and show confirmation
      const orderedName = selectedItem.name;
      const orderedPrice = selectedItem.priceDisplay;
      lastOrderId = result.orderId;
      selectedItem = null;
      selectedSize = '';
      customerName = '';
      successMessage = `${orderedName} (${orderedPrice}) — order placed`;

      // Refresh active orders
      await fetchActiveOrders();

      // Clear success message after 5 seconds
      setTimeout(() => {
        successMessage = '';
      }, 5000);
    } catch (err) {
      errorMessage = err instanceof Error ? err.message : 'Failed to place order';
    } finally {
      submitting = false;
    }
  }

  // ── Active orders polling ──

  async function fetchActiveOrders() {
    try {
      const response = await fetch('/api/orders/active');
      if (!response.ok) {
        activeOrdersError = 'Failed to load active orders';
        return;
      }
      const data = await response.json();
      activeOrders = data.orders;
      activeOrdersError = '';
    } catch (err) {
      activeOrdersError = err instanceof Error ? err.message : 'Failed to load';
    } finally {
      activeOrdersLoading = false;
    }
  }

  async function sendOrderSignal(orderId: string, signalName: string) {
    sendingSignal = orderId;
    try {
      const response = await fetch(`/api/orders/${orderId}/signal`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ signal: signalName }),
      });
      if (!response.ok) {
        const data = await response.json();
        activeOrdersError = data.message || 'Signal failed';
        return;
      }
      await fetchActiveOrders();
    } catch (err) {
      activeOrdersError = err instanceof Error ? err.message : 'Signal failed';
    } finally {
      sendingSignal = null;
    }
  }

  function formatElapsed(isoString: string | null): string {
    if (!isoString) return '';
    const start = new Date(isoString).getTime();
    const now = Date.now();
    const diffSec = Math.floor((now - start) / 1000);

    if (diffSec < 60) return `${diffSec}s ago`;
    const mins = Math.floor(diffSec / 60);
    const secs = diffSec % 60;
    if (mins < 60) return `${mins}m ${secs}s ago`;
    const hrs = Math.floor(mins / 60);
    return `${hrs}h ${mins % 60}m ago`;
  }

  onMount(() => {
    fetchActiveOrders();
    const interval = setInterval(fetchActiveOrders, 3000);
    return () => clearInterval(interval);
  });
</script>

<!-- Page header -->
<div class="mb-6">
  <h1 class="text-2xl font-bold text-secondary-800 dark:text-white">Counter</h1>
  <p class="text-sm text-secondary-500 dark:text-secondary-300">
    {data.catalogue.length} items on the menu — select an item to place an order
  </p>
</div>

<!-- Catalogue error -->
{#if data.catalogueError}
  <Alert color="red" class="mb-4">
    <span class="font-medium">Catalogue unavailable:</span> {data.catalogueError}.
    Check that PostgreSQL is running. <a href="/" class="font-medium underline">Retry</a>
  </Alert>
{/if}

<!-- Success message -->
{#if successMessage}
  <Alert color="green" class="mb-4" dismissable onclose={() => (successMessage = '')}>
    {successMessage}
    {#if lastOrderId}
      <a href="/orders/{lastOrderId}" class="ms-2 font-medium underline">View order →</a>
    {/if}
  </Alert>
{/if}

<!-- Error message -->
{#if errorMessage}
  <Alert color="red" class="mb-4" dismissable onclose={() => (errorMessage = '')}>
    <span class="font-medium">Error:</span> {errorMessage}
  </Alert>
{/if}

<!-- Split layout: order form (left) + active orders (right) -->
<div class="flex flex-col gap-6 lg:flex-row">

  <!-- ══════════════════════════════════════════════════ -->
  <!-- LEFT PANEL: Order form                            -->
  <!-- ══════════════════════════════════════════════════ -->
  <div class="min-w-0 flex-1">

    <!-- Category tabs -->
    <div class="mb-4 flex flex-wrap gap-2">
      {#each categories as cat}
        <button
          class="inline-flex items-center gap-1.5 rounded-full px-4 py-1.5 text-sm font-medium transition-colors
            {activeCategory === cat.key
              ? 'bg-primary-600 text-white dark:bg-primary-500'
              : 'bg-secondary-100 text-secondary-600 hover:bg-secondary-200 dark:bg-secondary-700 dark:text-secondary-300 dark:hover:bg-secondary-600'}"
          onclick={() => (activeCategory = cat.key)}
        >
          {cat.icon} {cat.label}
          <span class="inline-flex h-5 min-w-5 items-center justify-center rounded-full text-xs
            {activeCategory === cat.key
              ? 'bg-primary-700 text-primary-100 dark:bg-primary-600'
              : 'bg-secondary-200 text-secondary-500 dark:bg-secondary-600 dark:text-secondary-400'}">
            {cat.items.length}
          </span>
        </button>
      {/each}
    </div>

    <!-- Item tiles -->
    {#if activeCategoryItems.length === 0}
      <p class="text-sm text-secondary-400 dark:text-secondary-500">No items in this category.</p>
    {:else}
      <div class="mb-4 grid grid-cols-2 gap-3 sm:grid-cols-3">
        {#each activeCategoryItems as item}
          <button
            class="rounded-lg border-2 p-3 text-left transition-colors
              {selectedItem?.catalogueEntryId === item.catalogueEntryId
                ? 'border-primary-500 bg-primary-50 dark:border-primary-400 dark:bg-primary-900/20'
                : 'border-secondary-200 bg-primary-50/30 hover:border-primary-300 dark:border-secondary-500 dark:bg-secondary-800 dark:hover:border-primary-500'}"
            onclick={() => selectItem(item)}
          >
            <div class="mb-1 font-semibold text-secondary-800 dark:text-secondary-100">{item.name}</div>
            <div class="mb-2 text-lg font-bold text-primary-600 dark:text-primary-400">{item.priceDisplay}</div>
            <div class="flex min-h-6 flex-wrap gap-1">
              {#if item.isVegan}
                <span class="inline-flex items-center rounded-full bg-green-100 px-2 py-0.5 text-xs font-medium text-green-800 dark:bg-green-900/30 dark:text-green-400">V</span>
              {/if}
              {#if item.isGlutenFree}
                <span class="inline-flex items-center rounded-full bg-blue-100 px-2 py-0.5 text-xs font-medium text-blue-800 dark:bg-blue-900/30 dark:text-blue-400">GF</span>
              {/if}
              {#if item.isCaffeinated === false && item.itemType === 'drink'}
                <span class="inline-flex items-center rounded-full bg-secondary-100 px-2 py-0.5 text-xs font-medium text-secondary-600 dark:bg-secondary-700 dark:text-secondary-400">Decaf</span>
              {/if}
            </div>
            <div class="mt-2 text-xs text-secondary-400 dark:text-secondary-300">
              {item.provisionType === 'bought_in' ? 'Bought in' : 'Prepared'}
            </div>
          </button>
        {/each}
      </div>
    {/if}

    <!-- Size selection (when item selected and has sizes) -->
    {#if selectedItem?.availableSizes && selectedItem.availableSizes.length > 0}
      <div class="mb-4">
        <label class="mb-2 block text-sm font-medium text-secondary-700 dark:text-secondary-200">Size</label>
        <div class="flex gap-2">
          {#each selectedItem.availableSizes as sizeOption}
            <button
              class="rounded-lg border-2 px-4 py-2 text-sm font-medium transition-colors
                {selectedSize === sizeOption
                  ? 'border-primary-500 bg-primary-50 text-primary-700 dark:border-primary-400 dark:bg-primary-900/20 dark:text-primary-300'
                  : 'border-secondary-200 bg-white text-secondary-600 hover:border-primary-300 dark:border-secondary-500 dark:bg-secondary-800 dark:text-secondary-300 dark:hover:border-primary-500'}"
              aria-pressed={selectedSize === sizeOption}
              onclick={() => (selectedSize = sizeOption)}
            >
              {sizeOption.charAt(0).toUpperCase() + sizeOption.slice(1)}
            </button>
          {/each}
        </div>
      </div>
    {/if}

    <!-- Customer name -->
    <div class="mb-4 max-w-sm">
      <Label for="customerName" class="mb-2 dark:text-secondary-100">Customer Name</Label>
      <Input id="customerName" bind:value={customerName} placeholder="Enter name" class="dark:bg-secondary-800 dark:border-secondary-500 dark:text-secondary-100 dark:placeholder-secondary-400" />
    </div>

    <!-- Order summary -->
    {#if selectedItem && customerName.trim()}
      <div class="mb-4 max-w-sm rounded-lg bg-primary-50 p-3 dark:bg-primary-900/20">
        <p class="text-sm text-secondary-700 dark:text-secondary-300">
          <span class="font-semibold">{customerName.trim()}</span> —
          {selectedItem.name}
          {#if selectedSize}
            ({selectedSize})
          {/if}
          — {selectedItem.priceDisplay}
        </p>
      </div>
    {/if}

    <!-- Submit button -->
    <div class="max-w-sm">
      <Button
        color="primary"
        class="w-full {!canSubmit && !submitting ? 'opacity-60 border-2 border-secondary-300 dark:border-secondary-500' : ''}"
        onclick={placeOrder}
        disabled={!canSubmit || submitting}
      >
        {#if submitting}
          Placing order…
        {:else if selectedItem}
          Place Order — {selectedItem.name} {selectedItem.priceDisplay}
        {:else}
          Select an item
        {/if}
      </Button>
    </div>
  </div>

  <!-- ══════════════════════════════════════════════════ -->
  <!-- RIGHT PANEL: Active orders                        -->
  <!-- ══════════════════════════════════════════════════ -->
  <div class="w-full shrink-0 lg:w-96">
    <div class="mb-3 flex items-center justify-between">
      <h2 class="text-lg font-semibold text-secondary-800 dark:text-white">
        Active Orders
        {#if activeOrders.length > 0}
          <Badge color="primary" class="ms-2">{activeOrders.length}</Badge>
        {/if}
      </h2>
      <a href="/orders" class="text-xs text-primary-600 hover:underline dark:text-primary-400">View all →</a>
    </div>

    {#if activeOrdersLoading}
      <div class="flex items-center gap-2 text-secondary-500">
        <Spinner size="4" /> Loading…
      </div>
    {:else if activeOrdersError}
      <Alert color="red" class="mb-3">
        <span class="text-sm">{activeOrdersError}</span>
      </Alert>
    {:else if activeOrders.length === 0}
      <div class="rounded-lg border-2 border-dashed border-secondary-200 p-6 text-center dark:border-secondary-700">
        <p class="text-sm text-secondary-400 dark:text-secondary-400">No active orders</p>
        <p class="mt-1 text-xs text-secondary-300 dark:text-secondary-500">Orders appear here when placed</p>
      </div>
    {:else}
      <div class="space-y-3">
        {#each activeOrders as order}
          <div class="rounded-lg border border-secondary-200 bg-white p-3 dark:border-secondary-600 dark:bg-secondary-800">
            <div class="mb-2 flex items-center justify-between">
              <code class="text-xs text-secondary-500 dark:text-secondary-400">
                {order.orderId.replace('order-', '#')}
              </code>
              <Badge color={STATE_COLORS[order.state] ?? 'dark'}>
                {STATE_LABELS[order.state] ?? order.state}
              </Badge>
            </div>

            <div class="mb-2 text-xs text-secondary-400 dark:text-secondary-400">
              {formatElapsed(order.startTime)}
            </div>

            {#if STATE_ACTIONS[order.state]}
              <Button
                size="xs"
                color="primary"
                outline
                class="w-full"
                onclick={() => {
                  const action = STATE_ACTIONS[order.state];
                  if (action) sendOrderSignal(order.orderId, action.signal);
                }}
                disabled={sendingSignal === order.orderId}
              >
                {sendingSignal === order.orderId
                  ? 'Sending…'
                  : STATE_ACTIONS[order.state]?.label ?? ''}
              </Button>
            {/if}
          </div>
        {/each}
      </div>
    {/if}
  </div>
</div>
