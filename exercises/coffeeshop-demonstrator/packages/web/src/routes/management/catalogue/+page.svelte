<script lang="ts">
  import { onMount } from 'svelte';
  import {
    Button, Badge, Alert, Input, Label, Spinner, Select,
    Table, TableHead, TableHeadCell, TableBody, TableBodyRow, TableBodyCell,
    Modal,
  } from 'flowbite-svelte';
  import type {
    CatalogueItemView,
    InventoryItemView,
    CreateCatalogueItemInput,
    UpdateCatalogueEntryInput,
    UpdateInventoryInput,
  } from '@coffeeshop/shared';

  // ── Configuration ──

  const CATEGORY_CONFIG: Record<string, { label: string; icon: string; order: number }> = {
    all:        { label: 'All Items',   icon: '📋', order: 0 },
    hot_drink:  { label: 'Hot Drinks',  icon: '☕', order: 1 },
    cold_drink: { label: 'Cold Drinks', icon: '🧊', order: 2 },
    food:       { label: 'Food',        icon: '🍪', order: 3 },
  };

  const AVAILABILITY_CONFIG: Record<string, { label: string; color: string }> = {
    active:                  { label: 'Active',       color: 'green' },
    seasonal:                { label: 'Seasonal',     color: 'yellow' },
    temporarily_unavailable: { label: 'Unavailable',  color: 'red' },
    discontinued:            { label: 'Discontinued', color: 'dark' },
  };

  const PROVISION_LABELS: Record<string, string> = {
    prepared:  'Prepared',
    bought_in: 'Bought in',
    hybrid:    'Hybrid',
  };

  const STOCK_STATUS_LABELS: Record<string, string> = {
    in_stock:     'In Stock',
    low:          'Low',
    out_of_stock: 'Out of Stock',
    on_order:     'On Order',
  };

  const STOCK_STATUS_COLORS: Record<string, string> = {
    in_stock:     'green',
    low:          'yellow',
    out_of_stock: 'red',
    on_order:     'blue',
  };

  function stockBarColor(inv: InventoryItemView): string {
    if (inv.quantityOnHand === 0) return 'bg-red-500';
    if (inv.quantityOnHand <= inv.lowStockThreshold) return 'bg-yellow-400';
    return 'bg-green-500';
  }

  function formatDate(d: Date | string | null): string {
    if (!d) return '';
    const date = typeof d === 'string' ? new Date(d) : d;
    return date.toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' });
  }

  // ── Page data state ──

  let catalogue = $state<CatalogueItemView[]>([]);
  let inventory = $state<InventoryItemView[]>([]);
  let lowStockItems = $state<InventoryItemView[]>([]);
  let loading = $state(true);
  let fetchError = $state('');

  async function fetchAll() {
    fetchError = '';
    try {
      const [catRes, invRes, lowRes] = await Promise.all([
        fetch('/api/catalogue?all=true'),
        fetch('/api/inventory'),
        fetch('/api/inventory?low=true'),
      ]);
      if (!catRes.ok || !invRes.ok || !lowRes.ok) {
        fetchError = 'Failed to load data — check that PostgreSQL is running';
        return;
      }
      catalogue = await catRes.json();
      inventory = await invRes.json();
      lowStockItems = await lowRes.json();
    } catch (err) {
      fetchError = err instanceof Error ? err.message : 'Failed to load data';
    } finally {
      loading = false;
    }
  }

  onMount(() => { fetchAll(); });

  // ── Category filter ──

  let activeFilter = $state('all');

  let filteredCatalogue = $derived(
    activeFilter === 'all'
      ? catalogue
      : catalogue.filter(item => item.category === activeFilter)
  );

  // ── Sort ──

  let sortBy = $state<'name' | 'price'>('name');

  let sortedCatalogue = $derived(
    [...filteredCatalogue].sort((a, b) =>
      sortBy === 'name'
        ? a.name.localeCompare(b.name)
        : a.pricePence - b.pricePence
    )
  );

  // ── Success messages ──

  let successMessage = $state('');

  function showSuccess(msg: string) {
    successMessage = msg;
    setTimeout(() => { successMessage = ''; }, 4000);
  }

  // ════════════════════════════════════════════════════
  // ADD ITEM MODAL
  // ════════════════════════════════════════════════════

  let showAddModal = $state(false);
  let submittingNew = $state(false);
  let addError = $state('');

  // Form fields
  let newName = $state('');
  let newCategory = $state('hot_drink');
  let newDescription = $state('');
  let newPricePence = $state(0);
  let newIsVegan = $state(false);
  let newProvisionType = $state('prepared');

  // Drink-specific
  let newDefaultMilk = $state('whole');
  let newAvailableSizes = $state<string[]>(['small', 'medium', 'large']);
  let newIsCaffeinated = $state(true);

  // Food-specific
  let newIsGlutenFree = $state(false);
  let newServedWarm = $state(false);

  // Inventory (for bought-in items)
  let newInitialStock = $state(0);
  let newLowStockThreshold = $state(5);

  let newItemType = $derived(newCategory === 'food' ? 'food_item' : 'drink');
  let newPricePreview = $derived(newPricePence > 0 ? `£${(newPricePence / 100).toFixed(2)}` : '');

  let canSubmitNew = $derived(
    newName.trim() !== '' &&
    newPricePence > 0 &&
    (newCategory === 'food' || newAvailableSizes.length > 0)
  );

  function resetAddForm() {
    newName = '';
    newCategory = 'hot_drink';
    newDescription = '';
    newPricePence = 0;
    newIsVegan = false;
    newProvisionType = 'prepared';
    newDefaultMilk = 'whole';
    newAvailableSizes = ['small', 'medium', 'large'];
    newIsCaffeinated = true;
    newIsGlutenFree = false;
    newServedWarm = false;
    newInitialStock = 0;
    newLowStockThreshold = 5;
    addError = '';
  }

  function openAddModal() {
    resetAddForm();
    showAddModal = true;
  }

  function handleCategoryChange(event: Event) {
    const cat = (event.target as HTMLSelectElement).value;
    newCategory = cat;

    if (cat === 'food') {
      newProvisionType = 'bought_in';
      newAvailableSizes = [];
    } else {
      newProvisionType = 'prepared';
      newAvailableSizes = cat === 'hot_drink'
        ? ['small', 'medium', 'large']
        : ['medium', 'large'];
      newIsCaffeinated = true;
      newDefaultMilk = 'whole';
      newIsGlutenFree = false;
      newServedWarm = false;
    }
  }

  function toggleSize(size: string) {
    if (newAvailableSizes.includes(size)) {
      newAvailableSizes = newAvailableSizes.filter(s => s !== size);
    } else {
      newAvailableSizes = [...newAvailableSizes, size];
    }
  }

  async function submitNewItem() {
    if (!canSubmitNew) return;
    submittingNew = true;
    addError = '';

    const drinkFields = newItemType === 'drink' ? {
      defaultMilk: newDefaultMilk,
      availableSizes: newAvailableSizes,
      isCaffeinated: newIsCaffeinated,
    } : {};

    const foodFields = newItemType === 'food_item' ? {
      isGlutenFree: newIsGlutenFree,
      servedWarm: newServedWarm,
    } : {};

    const stockFields = newProvisionType === 'bought_in' && newInitialStock > 0 ? {
      initialStock: {
        quantityOnHand: newInitialStock,
        lowStockThreshold: newLowStockThreshold,
      },
    } : {};

    const input: CreateCatalogueItemInput = {
      menuItem: {
        name: newName.trim(),
        category: newCategory as 'hot_drink' | 'cold_drink' | 'food',
        itemType: newItemType as 'drink' | 'food_item',
        description: newDescription.trim() || undefined,
        isVegan: newIsVegan,
        ...drinkFields,
        ...foodFields,
      },
      pricePence: newPricePence,
      priceDisplay: newPricePreview,
      provisionType: newProvisionType as 'prepared' | 'bought_in' | 'hybrid',
      ...stockFields,
    };

    try {
      const response = await fetch('/api/catalogue', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(input),
      });

      if (!response.ok) {
        const data = await response.json();
        addError = data.message || `Error: ${response.status}`;
        return;
      }

      const itemName = newName.trim();
      showAddModal = false;
      resetAddForm();
      await fetchAll();
      showSuccess(`Added "${itemName}" to the catalogue`);
    } catch (err) {
      addError = err instanceof Error ? err.message : 'Failed to add item';
    } finally {
      submittingNew = false;
    }
  }

  // ════════════════════════════════════════════════════
  // INLINE EDIT PANEL
  // ════════════════════════════════════════════════════

  let editingItem = $state<CatalogueItemView | null>(null);
  let editPricePence = $state(0);
  let editAvailability = $state('active');
  let editStatusNotes = $state('');
  let editSubmitting = $state(false);
  let editError = $state('');

  function startEditItem(item: CatalogueItemView) {
    editingItem = item;
    editPricePence = item.pricePence;
    editAvailability = item.availability;
    editStatusNotes = item.statusNotes ?? '';
    editError = '';
  }

  function cancelEdit() {
    editingItem = null;
    editError = '';
  }

  let editPricePreview = $derived(
    editPricePence > 0 ? `£${(editPricePence / 100).toFixed(2)}` : ''
  );

  async function submitEdit() {
    if (!editingItem) return;
    editSubmitting = true;
    editError = '';

    const input: UpdateCatalogueEntryInput = {
      pricePence: editPricePence,
      priceDisplay: editPricePreview,
      availability: editAvailability,
      statusNotes: editStatusNotes || undefined,
    };

    try {
      const response = await fetch(`/api/catalogue/${editingItem.catalogueEntryId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(input),
      });

      if (!response.ok) {
        const data = await response.json();
        editError = data.message || `Error: ${response.status}`;
        return;
      }

      editingItem = null;
      await fetchAll();
      showSuccess('Changes saved');
    } catch (err) {
      editError = err instanceof Error ? err.message : 'Failed to save changes';
    } finally {
      editSubmitting = false;
    }
  }

  // ════════════════════════════════════════════════════
  // INVENTORY PANEL
  // ════════════════════════════════════════════════════

  let adjustingInventoryId = $state<string | null>(null);
  let adjustMode = $state<'restock' | 'adjust'>('restock');
  let adjustQuantity = $state(0);
  let adjustNotes = $state('');
  let adjustSubmitting = $state(false);
  let adjustError = $state('');

  function startStockAdjust(inv: InventoryItemView, mode: 'restock' | 'adjust') {
    adjustingInventoryId = inv.inventoryRecordId;
    adjustMode = mode;
    adjustQuantity = mode === 'restock' ? 24 : inv.quantityOnHand;
    adjustNotes = '';
    adjustError = '';
  }

  function cancelAdjust() {
    adjustingInventoryId = null;
    adjustError = '';
  }

  async function submitStockAdjust(inv: InventoryItemView) {
    adjustSubmitting = true;
    adjustError = '';

    const input: UpdateInventoryInput = {
      quantityOnHand: adjustQuantity,
      quantityNotes: adjustNotes || undefined,
    };

    try {
      const response = await fetch(`/api/inventory/${inv.inventoryRecordId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(input),
      });

      if (!response.ok) {
        const data = await response.json();
        adjustError = data.message || `Error: ${response.status}`;
        return;
      }

      adjustingInventoryId = null;
      await fetchAll();
      showSuccess(`Stock updated for ${inv.name}`);
    } catch (err) {
      adjustError = err instanceof Error ? err.message : 'Failed to update stock';
    } finally {
      adjustSubmitting = false;
    }
  }
</script>

<!-- ═══════════════════════════════════════════════════ -->
<!-- PAGE HEADER                                        -->
<!-- ═══════════════════════════════════════════════════ -->

<div class="mb-6">
  <h1 class="text-2xl font-bold text-secondary-800 dark:text-white">Stock & Catalogue</h1>
  {#if !loading && catalogue.length > 0}
    <p class="text-sm text-secondary-500 dark:text-secondary-300">
      {catalogue.length} items in catalogue —
      {catalogue.filter(i => i.availability === 'active').length} active,
      {inventory.length} tracked in inventory
    </p>
  {/if}
</div>

<!-- Low-stock alerts -->
{#if lowStockItems.length > 0}
  <Alert color="yellow" class="mb-4">
    <span class="font-medium">Low Stock:</span>
    {#each lowStockItems as item, i}
      {item.name} ({item.quantityOnHand} remaining){i < lowStockItems.length - 1 ? ', ' : ''}
    {/each}
  </Alert>
{/if}

<!-- Success message -->
{#if successMessage}
  <Alert color="green" class="mb-4" dismissable onclose={() => (successMessage = '')}>
    {successMessage}
  </Alert>
{/if}

<!-- Fetch error -->
{#if fetchError}
  <Alert color="red" class="mb-4">
    <span class="font-medium">Error:</span> {fetchError}
    <button class="ms-2 font-medium underline" onclick={() => fetchAll()}>Retry</button>
  </Alert>
{/if}

<!-- Loading -->
{#if loading}
  <div class="flex items-center justify-center gap-2 py-12 text-secondary-500">
    <Spinner size="6" /> Loading catalogue…
  </div>
{:else}

<!-- ═══════════════════════════════════════════════════ -->
<!-- SPLIT LAYOUT: catalogue (left) + inventory (right) -->
<!-- ═══════════════════════════════════════════════════ -->
<div class="flex flex-col gap-6 lg:flex-row">

  <!-- ═════════════════════════════════════════════════ -->
  <!-- LEFT PANEL: Catalogue table                      -->
  <!-- ═════════════════════════════════════════════════ -->
  <div class="min-w-0 flex-1">

    <!-- Header row: title + add button -->
    <div class="mb-4 flex items-center justify-between">
      <h2 class="text-lg font-semibold text-secondary-800 dark:text-white">
        Catalogue
        <Badge color="dark" class="ms-2">{filteredCatalogue.length}</Badge>
      </h2>
      <Button color="primary" size="sm" onclick={openAddModal}>+ Add Item</Button>
    </div>

    <!-- Category filter tabs -->
    <div class="mb-4 flex flex-wrap gap-2">
      {#each Object.entries(CATEGORY_CONFIG).sort(([,a], [,b]) => a.order - b.order) as [key, config]}
        {@const count = key === 'all' ? catalogue.length : catalogue.filter(i => i.category === key).length}
        <button
          class="inline-flex items-center gap-1.5 rounded-full px-4 py-1.5 text-sm font-medium transition-colors
            {activeFilter === key
              ? 'bg-primary-600 text-white dark:bg-primary-500'
              : 'bg-secondary-100 text-secondary-600 hover:bg-secondary-200 dark:bg-secondary-700 dark:text-secondary-300 dark:hover:bg-secondary-600'}"
          onclick={() => (activeFilter = key)}
        >
          {config.icon} {config.label}
          <span class="inline-flex h-5 min-w-5 items-center justify-center rounded-full text-xs
            {activeFilter === key
              ? 'bg-primary-700 text-primary-100 dark:bg-primary-600'
              : 'bg-secondary-200 text-secondary-500 dark:bg-secondary-600 dark:text-secondary-400'}">
            {count}
          </span>
        </button>
      {/each}
    </div>

    <!-- Sort toggle -->
    <div class="mb-3 flex items-center gap-2 text-xs text-secondary-400 dark:text-secondary-500">
      <span>Sort:</span>
      <button
        class="hover:text-primary-600 dark:hover:text-primary-400 {sortBy === 'name' ? 'font-semibold text-secondary-700 dark:text-secondary-200' : ''}"
        onclick={() => (sortBy = 'name')}
      >Name</button>
      <span>|</span>
      <button
        class="hover:text-primary-600 dark:hover:text-primary-400 {sortBy === 'price' ? 'font-semibold text-secondary-700 dark:text-secondary-200' : ''}"
        onclick={() => (sortBy = 'price')}
      >Price</button>
    </div>

    <!-- Catalogue table -->
    {#if sortedCatalogue.length === 0}
      <div class="rounded-lg border-2 border-dashed border-secondary-200 p-8 text-center dark:border-secondary-700">
        <p class="text-sm text-secondary-400 dark:text-secondary-500">
          {activeFilter === 'all' ? 'No items in the catalogue' : 'No items in this category'}
        </p>
      </div>
    {:else}
      <Table striped>
        <TableHead>
          <TableHeadCell>Name</TableHeadCell>
          <TableHeadCell class="hidden sm:table-cell">Category</TableHeadCell>
          <TableHeadCell class="text-right">Price</TableHeadCell>
          <TableHeadCell>Status</TableHeadCell>
          <TableHeadCell class="hidden md:table-cell">Type</TableHeadCell>
          <TableHeadCell class="hidden md:table-cell">Dietary</TableHeadCell>
          <TableHeadCell><span class="sr-only">Edit</span></TableHeadCell>
        </TableHead>
        <TableBody>
          {#each sortedCatalogue as item}
            <TableBodyRow
              class="cursor-pointer hover:bg-primary-50 dark:hover:bg-primary-900/10
                {editingItem?.catalogueEntryId === item.catalogueEntryId ? 'bg-primary-50 dark:bg-primary-900/10' : ''}"
              onclick={() => startEditItem(item)}
            >
              <TableBodyCell class="font-medium text-secondary-900 dark:text-white">
                {item.name}
              </TableBodyCell>
              <TableBodyCell class="hidden sm:table-cell">
                <span class="text-sm text-secondary-500 dark:text-secondary-400">
                  {CATEGORY_CONFIG[item.category]?.icon ?? ''} {CATEGORY_CONFIG[item.category]?.label ?? item.category}
                </span>
              </TableBodyCell>
              <TableBodyCell class="text-right font-mono text-sm">
                {item.priceDisplay}
              </TableBodyCell>
              <TableBodyCell>
                <Badge color={AVAILABILITY_CONFIG[item.availability]?.color ?? 'dark'}>
                  {AVAILABILITY_CONFIG[item.availability]?.label ?? item.availability}
                </Badge>
              </TableBodyCell>
              <TableBodyCell class="hidden text-sm text-secondary-500 dark:text-secondary-400 md:table-cell">
                {PROVISION_LABELS[item.provisionType] ?? item.provisionType}
              </TableBodyCell>
              <TableBodyCell class="hidden md:table-cell">
                <div class="flex gap-1">
                  {#if item.isVegan}
                    <span class="inline-flex items-center rounded-full bg-green-100 px-2 py-0.5 text-xs font-medium text-green-800 dark:bg-green-900/30 dark:text-green-400">V</span>
                  {/if}
                  {#if item.isGlutenFree}
                    <span class="inline-flex items-center rounded-full bg-blue-100 px-2 py-0.5 text-xs font-medium text-blue-800 dark:bg-blue-900/30 dark:text-blue-400">GF</span>
                  {/if}
                </div>
              </TableBodyCell>
              <TableBodyCell>
                <button class="text-xs text-primary-600 hover:underline dark:text-primary-400">Edit</button>
              </TableBodyCell>
            </TableBodyRow>
          {/each}
        </TableBody>
      </Table>
    {/if}

    <!-- ═════════════════════════════════════════════════ -->
    <!-- INLINE EDIT PANEL (below table)                  -->
    <!-- ═════════════════════════════════════════════════ -->
    {#if editingItem}
      <div class="mt-4 rounded-lg border border-primary-200 bg-primary-50/50 p-4 dark:border-primary-800 dark:bg-primary-900/10">
        <div class="mb-3 flex items-center justify-between">
          <h3 class="font-semibold text-secondary-800 dark:text-white">
            Editing: {editingItem.name}
          </h3>
          <Button color="alternative" size="xs" onclick={cancelEdit}>Cancel</Button>
        </div>

        <!-- Item summary (read-only) -->
        <div class="mb-4 text-sm text-secondary-500 dark:text-secondary-400">
          {CATEGORY_CONFIG[editingItem.category]?.icon ?? ''} {CATEGORY_CONFIG[editingItem.category]?.label ?? editingItem.category}
          · {PROVISION_LABELS[editingItem.provisionType] ?? editingItem.provisionType}
          {#if editingItem.description}
            · {editingItem.description}
          {/if}
        </div>

        <!-- Editable fields -->
        <div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
          <!-- Price -->
          <div>
            <Label for="edit-price" class="mb-1 dark:text-secondary-200">Price (pence)</Label>
            <Input id="edit-price" type="number" bind:value={editPricePence} min={0}
              class="dark:bg-secondary-800 dark:border-secondary-500 dark:text-secondary-100" />
            {#if editPricePreview}
              <p class="mt-1 text-xs text-secondary-500 dark:text-secondary-400">Display: {editPricePreview}</p>
            {/if}
          </div>

          <!-- Availability -->
          <div>
            <Label for="edit-availability" class="mb-1 dark:text-secondary-200">Availability</Label>
            <Select id="edit-availability" bind:value={editAvailability}
              class="dark:bg-secondary-800 dark:border-secondary-500 dark:text-secondary-100">
              <option value="active">Active</option>
              <option value="seasonal">Seasonal</option>
              <option value="temporarily_unavailable">Temporarily Unavailable</option>
              <option value="discontinued">Discontinued</option>
            </Select>
          </div>

          <!-- Status Notes -->
          <div>
            <Label for="edit-notes" class="mb-1 dark:text-secondary-200">Status Notes</Label>
            <Input id="edit-notes" bind:value={editStatusNotes} placeholder="Optional notes"
              class="dark:bg-secondary-800 dark:border-secondary-500 dark:text-secondary-100" />
          </div>
        </div>

        {#if editError}
          <Alert color="red" class="mt-3">
            <span class="text-sm">{editError}</span>
          </Alert>
        {/if}

        <div class="mt-4 flex gap-2">
          <Button color="primary" size="sm" onclick={submitEdit} disabled={editSubmitting || editPricePence <= 0}>
            {editSubmitting ? 'Saving…' : 'Save Changes'}
          </Button>
          <Button color="alternative" size="sm" onclick={cancelEdit}>Cancel</Button>
        </div>
      </div>
    {/if}

  </div>

  <!-- ═════════════════════════════════════════════════ -->
  <!-- RIGHT PANEL: Inventory                           -->
  <!-- ═════════════════════════════════════════════════ -->
  <div class="w-full shrink-0 lg:w-96">
    <div class="mb-3 flex items-center justify-between">
      <h2 class="text-lg font-semibold text-secondary-800 dark:text-white">
        Inventory
        {#if inventory.length > 0}
          <Badge color="dark" class="ms-2">{inventory.length}</Badge>
        {/if}
      </h2>
    </div>

    {#if inventory.length === 0}
      <div class="rounded-lg border-2 border-dashed border-secondary-200 p-6 text-center dark:border-secondary-700">
        <p class="text-sm text-secondary-400 dark:text-secondary-500">No bought-in items tracked</p>
        <p class="mt-1 text-xs text-secondary-300 dark:text-secondary-500">
          Inventory records are created for bought-in items
        </p>
      </div>
    {:else}
      <div class="space-y-3">
        {#each inventory as inv}
          <div class="rounded-lg border border-secondary-200 bg-white p-4 dark:border-secondary-600 dark:bg-secondary-800">
            <!-- Header: name + stock status badge -->
            <div class="mb-2 flex items-center justify-between">
              <span class="font-medium text-secondary-800 dark:text-white">{inv.name}</span>
              <Badge color={STOCK_STATUS_COLORS[inv.stockStatus] ?? 'dark'}>
                {STOCK_STATUS_LABELS[inv.stockStatus] ?? inv.stockStatus}
              </Badge>
            </div>

            <!-- Stock level bar -->
            <div class="mb-2">
              <div class="mb-1 flex justify-between text-xs text-secondary-500 dark:text-secondary-400">
                <span>{inv.quantityOnHand} in stock</span>
                <span>Threshold: {inv.lowStockThreshold}</span>
              </div>
              <div class="h-2 w-full rounded-full bg-secondary-200 dark:bg-secondary-600">
                <div
                  class="h-2 rounded-full transition-all {stockBarColor(inv)}"
                  style="width: {Math.min(100, (inv.quantityOnHand / Math.max(inv.lowStockThreshold * 4, 1)) * 100)}%"
                ></div>
              </div>
            </div>

            <!-- Price and last restocked -->
            <div class="mb-3 flex justify-between text-xs text-secondary-400 dark:text-secondary-500">
              <span>{inv.priceDisplay}</span>
              <span>{inv.lastRestocked ? `Restocked: ${formatDate(inv.lastRestocked)}` : 'Never restocked'}</span>
            </div>

            <!-- Action buttons -->
            <div class="flex gap-2">
              <Button size="xs" color="primary" outline onclick={() => startStockAdjust(inv, 'restock')}>
                Restock
              </Button>
              <Button size="xs" color="alternative" onclick={() => startStockAdjust(inv, 'adjust')}>
                Adjust
              </Button>
            </div>

            <!-- Inline stock adjustment form -->
            {#if adjustingInventoryId === inv.inventoryRecordId}
              <div class="mt-3 rounded border border-secondary-200 bg-secondary-50 p-3 dark:border-secondary-600 dark:bg-secondary-700/50">
                <div class="mb-2 text-sm font-medium text-secondary-700 dark:text-secondary-300">
                  {adjustMode === 'restock' ? 'Restock' : 'Adjust Stock'}
                </div>
                <div class="flex gap-2">
                  <div class="flex-1">
                    <Input type="number" bind:value={adjustQuantity} min={0} size="sm"
                      class="dark:bg-secondary-800 dark:border-secondary-500 dark:text-secondary-100" />
                  </div>
                  <div class="flex-1">
                    <Input bind:value={adjustNotes} placeholder="Notes" size="sm"
                      class="dark:bg-secondary-800 dark:border-secondary-500 dark:text-secondary-100" />
                  </div>
                </div>
                {#if adjustError}
                  <p class="mt-1 text-xs text-red-600 dark:text-red-400">{adjustError}</p>
                {/if}
                <div class="mt-2 flex gap-2">
                  <Button size="xs" color="primary" onclick={() => submitStockAdjust(inv)} disabled={adjustSubmitting}>
                    {adjustSubmitting ? 'Saving…' : 'Save'}
                  </Button>
                  <Button size="xs" color="alternative" onclick={cancelAdjust}>Cancel</Button>
                </div>
              </div>
            {/if}
          </div>
        {/each}
      </div>
    {/if}
  </div>

</div>
{/if}

<!-- ═══════════════════════════════════════════════════ -->
<!-- ADD ITEM MODAL                                     -->
<!-- ═══════════════════════════════════════════════════ -->
<Modal title="Add New Item" bind:open={showAddModal} size="lg" autoclose={false}>
  <div class="space-y-4">

    <!-- Section 1: Common fields -->
    <div class="grid grid-cols-1 gap-4 sm:grid-cols-2">
      <div>
        <Label for="new-name" class="mb-1 dark:text-secondary-200">Name *</Label>
        <Input id="new-name" bind:value={newName} placeholder="e.g. Hot Chocolate"
          class="dark:bg-secondary-800 dark:border-secondary-500 dark:text-secondary-100" />
      </div>
      <div>
        <Label for="new-category" class="mb-1 dark:text-secondary-200">Category *</Label>
        <Select id="new-category" value={newCategory} onchange={handleCategoryChange}
          class="dark:bg-secondary-800 dark:border-secondary-500 dark:text-secondary-100">
          <option value="hot_drink">Hot Drink</option>
          <option value="cold_drink">Cold Drink</option>
          <option value="food">Food</option>
        </Select>
      </div>
    </div>

    <div>
      <Label for="new-description" class="mb-1 dark:text-secondary-200">Description</Label>
      <Input id="new-description" bind:value={newDescription} placeholder="Optional description"
        class="dark:bg-secondary-800 dark:border-secondary-500 dark:text-secondary-100" />
    </div>

    <div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
      <div>
        <Label for="new-price" class="mb-1 dark:text-secondary-200">Price (pence) *</Label>
        <Input id="new-price" type="number" bind:value={newPricePence} min={0} placeholder="280"
          class="dark:bg-secondary-800 dark:border-secondary-500 dark:text-secondary-100" />
        {#if newPricePreview}
          <p class="mt-1 text-xs text-secondary-500 dark:text-secondary-400">Display: {newPricePreview}</p>
        {/if}
      </div>
      <div>
        <Label for="new-provision" class="mb-1 dark:text-secondary-200">Provision Type *</Label>
        <Select id="new-provision" bind:value={newProvisionType}
          class="dark:bg-secondary-800 dark:border-secondary-500 dark:text-secondary-100">
          <option value="prepared">Prepared</option>
          <option value="bought_in">Bought in</option>
          <option value="hybrid">Hybrid</option>
        </Select>
      </div>
      <div class="flex items-end pb-1">
        <label class="flex items-center gap-2 text-sm text-secondary-700 dark:text-secondary-300">
          <input type="checkbox" bind:checked={newIsVegan}
            class="h-4 w-4 rounded border-secondary-300 text-primary-600 focus:ring-primary-500" />
          Vegan
        </label>
      </div>
    </div>

    <!-- Section 2: Drink-specific fields -->
    {#if newCategory !== 'food'}
      <div class="rounded-lg border border-secondary-200 p-4 dark:border-secondary-600">
        <h4 class="mb-3 text-sm font-semibold text-secondary-600 dark:text-secondary-400">Drink Options</h4>
        <div class="space-y-3">
          <div>
            <Label class="mb-1 dark:text-secondary-200">Available Sizes *</Label>
            <div class="flex gap-2">
              {#each ['small', 'medium', 'large'] as size}
                <button
                  class="rounded-lg border-2 px-4 py-1.5 text-sm font-medium transition-colors
                    {newAvailableSizes.includes(size)
                      ? 'border-primary-500 bg-primary-50 text-primary-700 dark:border-primary-400 dark:bg-primary-900/20 dark:text-primary-300'
                      : 'border-secondary-200 bg-white text-secondary-600 hover:border-primary-300 dark:border-secondary-500 dark:bg-secondary-800 dark:text-secondary-300 dark:hover:border-primary-500'}"
                  onclick={() => toggleSize(size)}
                >
                  {size.charAt(0).toUpperCase() + size.slice(1)}
                </button>
              {/each}
            </div>
            {#if newAvailableSizes.length === 0}
              <p class="mt-1 text-xs text-red-500">At least one size is required</p>
            {/if}
          </div>
          <div class="grid grid-cols-2 gap-4">
            <div>
              <Label for="new-milk" class="mb-1 dark:text-secondary-200">Default Milk</Label>
              <Select id="new-milk" bind:value={newDefaultMilk}
                class="dark:bg-secondary-800 dark:border-secondary-500 dark:text-secondary-100">
                <option value="whole">Whole</option>
                <option value="semi">Semi-Skimmed</option>
                <option value="oat">Oat</option>
                <option value="soy">Soy</option>
                <option value="almond">Almond</option>
                <option value="none">None</option>
              </Select>
            </div>
            <div class="flex items-end pb-1">
              <label class="flex items-center gap-2 text-sm text-secondary-700 dark:text-secondary-300">
                <input type="checkbox" bind:checked={newIsCaffeinated}
                  class="h-4 w-4 rounded border-secondary-300 text-primary-600 focus:ring-primary-500" />
                Caffeinated
              </label>
            </div>
          </div>
        </div>
      </div>
    {/if}

    <!-- Section 3: Food-specific fields -->
    {#if newCategory === 'food'}
      <div class="rounded-lg border border-secondary-200 p-4 dark:border-secondary-600">
        <h4 class="mb-3 text-sm font-semibold text-secondary-600 dark:text-secondary-400">Food Options</h4>
        <div class="flex gap-6">
          <label class="flex items-center gap-2 text-sm text-secondary-700 dark:text-secondary-300">
            <input type="checkbox" bind:checked={newIsGlutenFree}
              class="h-4 w-4 rounded border-secondary-300 text-primary-600 focus:ring-primary-500" />
            Gluten-free
          </label>
          <label class="flex items-center gap-2 text-sm text-secondary-700 dark:text-secondary-300">
            <input type="checkbox" bind:checked={newServedWarm}
              class="h-4 w-4 rounded border-secondary-300 text-primary-600 focus:ring-primary-500" />
            Served warm
          </label>
        </div>
      </div>
    {/if}

    <!-- Section 4: Initial inventory (bought-in items) -->
    {#if newProvisionType === 'bought_in'}
      <div class="rounded-lg border border-secondary-200 p-4 dark:border-secondary-600">
        <h4 class="mb-3 text-sm font-semibold text-secondary-600 dark:text-secondary-400">Initial Inventory</h4>
        <div class="grid grid-cols-2 gap-4">
          <div>
            <Label for="new-stock" class="mb-1 dark:text-secondary-200">Initial Stock</Label>
            <Input id="new-stock" type="number" bind:value={newInitialStock} min={0}
              class="dark:bg-secondary-800 dark:border-secondary-500 dark:text-secondary-100" />
          </div>
          <div>
            <Label for="new-threshold" class="mb-1 dark:text-secondary-200">Low-Stock Threshold</Label>
            <Input id="new-threshold" type="number" bind:value={newLowStockThreshold} min={1}
              class="dark:bg-secondary-800 dark:border-secondary-500 dark:text-secondary-100" />
          </div>
        </div>
      </div>
    {/if}

    <!-- Error -->
    {#if addError}
      <Alert color="red">
        <span class="text-sm">{addError}</span>
      </Alert>
    {/if}

    <!-- Action buttons -->
    <div class="flex gap-3 border-t border-secondary-200 pt-4 dark:border-secondary-600">
      <Button color="primary" onclick={submitNewItem} disabled={!canSubmitNew || submittingNew}>
        {submittingNew ? 'Adding…' : 'Add to Catalogue'}
      </Button>
      <Button color="alternative" onclick={() => (showAddModal = false)}>Cancel</Button>
    </div>
  </div>
</Modal>
