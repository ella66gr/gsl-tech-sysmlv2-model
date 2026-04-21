# CSW Extension Phase 6: Manager GUI — Stock & Catalogue — Detailed Implementation Plan

**Workstream:** Coffee Shop Extension — Catalogue, Inventory & Frontend
**Phase:** 6 of 10
**Date:** 14 March 2026
**Session:** 25
**Prerequisites:** Phase 5 complete (Counter Page, Session 24)
**Source plan:** `gsl-plan-workstream-csw-extension-2026-03-12.md` §Phase 6
**Catalogue spec:** `gsl-spec-catalogue-inventory-v2.1.md`
**Estimated effort:** 5 stages across 3 commits

---

## Goal

The manager can view, add, edit, and manage catalogue items and inventory from the GUI. The placeholder "Coming in Phase 6" card at `/management/catalogue` is replaced with a fully functional management page containing three interconnected panels: a catalogue table showing all items with filtering and sorting, a modal form for adding new items with category-aware field sets, and an inventory panel for bought-in stock management with low-stock alerting.

This phase consumes the full set of Phase 3 API routes — `GET/POST /api/catalogue`, `GET/PUT /api/catalogue/[id]`, `GET /api/inventory`, `GET/PUT /api/inventory/[id]` — which have been operational since Session 22 but only exercised via curl and the Counter page's read path.

---

## Architecture Overview

### API Surface (All Existing — No Backend Changes)

| Route | Method | Purpose | Built in |
|---|---|---|---|
| `/api/catalogue` | GET | Active catalogue (default) or all entries (`?all=true`) | Phase 3 |
| `/api/catalogue` | POST | Create menu item + catalogue entry (+ optional inventory) | Phase 3 |
| `/api/catalogue/[id]` | GET | Single entry with full detail | Phase 3 |
| `/api/catalogue/[id]` | PUT | Update price, availability, status notes | Phase 3 |
| `/api/inventory` | GET | All inventory records (`?low=true` for low-stock only) | Phase 3 |
| `/api/inventory/[id]` | GET | Single inventory record | Phase 3 |
| `/api/inventory/[id]` | PUT | Update stock level, threshold, notes | Phase 3 |

No new API routes are needed. The backend is complete; this phase is entirely frontend.

### Data Types (From `@coffeeshop/shared`)

| Type | Used for |
|---|---|
| `CatalogueItemView` | Table rows — joined catalogue entry + menu item |
| `InventoryItemView` | Inventory panel rows — joined inventory + catalogue + menu item |
| `CreateCatalogueItemInput` | Add item modal — POST body |
| `UpdateCatalogueEntryInput` | Edit price/availability — PUT body |
| `UpdateInventoryInput` | Stock adjustment — PUT body |

### Page Structure

```
/management/catalogue (+page.svelte)
┌─────────────────────────────────────────────────────────────────┐
│  Low-Stock Alerts (conditional — only when items below threshold)│
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────────────────┐  ┌─────────────────────────────┐ │
│  │  Catalogue Table          │  │  Inventory Panel            │ │
│  │                           │  │                             │ │
│  │  Category filter tabs     │  │  Bought-in items only       │ │
│  │  Flowbite Table           │  │  Stock level + status badge │ │
│  │  - Name, Category, Price  │  │  Low-stock threshold        │ │
│  │  - Status, Provision type │  │  Restock / Adjust controls  │ │
│  │  - Dietary badges         │  │  Last restocked date        │ │
│  │  Click row → inline edit  │  │                             │ │
│  │                           │  │                             │ │
│  │  [+ Add Item] button      │  │                             │ │
│  └──────────────────────────┘  └─────────────────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│  Add Item Modal (triggered by button)                           │
│  - Category selection → conditional field sets                  │
│  - Drink fields: sizes, milk, caffeinated                       │
│  - Food fields: gluten-free, served warm                        │
│  - Common: name, price, description, vegan, provision type      │
│  - Optional initial stock for bought-in items                   │
└─────────────────────────────────────────────────────────────────┘
```

### Layout Decision

**Desktop (md+):** Two-column — catalogue table (flex-1, wider) on the left, inventory panel (w-96 / w-[28rem]) on the right. This mirrors the Counter page's split-view pattern and makes the relationship between catalogue items and their inventory visible side-by-side.

**Mobile (< md):** Stacked — catalogue table above, inventory panel below.

**Clinical analogue:** Formulary management table (medications, prices, formulary status) alongside pharmacy stock panel (inventory levels, reorder triggers). The split-view with a data table and an operational panel is a standard clinical management pattern.

---

## Stage 1: Catalogue Table with Filtering and Status Badges

### 1.1 Page data loading

Replace the placeholder `+page.svelte` with the full management page. Use `onMount` to fetch catalogue and inventory data client-side. Unlike the Counter page (which uses a `+page.ts` load function for the stable active catalogue), the manager page needs `?all=true` to see discontinued/unavailable items and needs the ability to refresh after mutations — client-side fetching is more appropriate here.

```typescript
let catalogue = $state<CatalogueItemView[]>([]);
let inventory = $state<InventoryItemView[]>([]);
let lowStockItems = $state<InventoryItemView[]>([]);
let loading = $state(true);
let error = $state('');

async function fetchAll() {
  loading = true;
  error = '';
  try {
    const [catRes, invRes, lowRes] = await Promise.all([
      fetch('/api/catalogue?all=true'),
      fetch('/api/inventory'),
      fetch('/api/inventory?low=true'),
    ]);
    if (!catRes.ok || !invRes.ok || !lowRes.ok) {
      error = 'Failed to load data';
      return;
    }
    catalogue = await catRes.json();
    inventory = await invRes.json();
    lowStockItems = await lowRes.json();
  } catch (err) {
    error = err instanceof Error ? err.message : 'Failed to load data';
  } finally {
    loading = false;
  }
}

onMount(() => { fetchAll(); });
```

Three parallel fetches on mount: all catalogue entries (including non-active), all inventory records, and low-stock items. The low-stock items drive the alert banner at the top — fetching them separately is cleaner than filtering client-side and ensures the server's threshold logic is authoritative.

### 1.2 Category filter

Reuse the same `CATEGORY_CONFIG` pattern from the Counter page. Add an "All" option for the manager view:

```typescript
const CATEGORY_CONFIG: Record<string, { label: string; icon: string; order: number }> = {
  all:        { label: 'All Items',   icon: '📋', order: 0 },
  hot_drink:  { label: 'Hot Drinks',  icon: '☕', order: 1 },
  cold_drink: { label: 'Cold Drinks', icon: '🧊', order: 2 },
  food:       { label: 'Food',        icon: '🍪', order: 3 },
};

let activeFilter = $state('all');

let filteredCatalogue = $derived(
  activeFilter === 'all'
    ? catalogue
    : catalogue.filter(item => item.category === activeFilter)
);
```

Category filter tabs rendered as pill-style `Button` components, matching the Counter page's visual pattern. The active filter shows a count badge.

### 1.3 Catalogue table

Flowbite `Table` with the following columns:

| Column | Source field | Notes |
|---|---|---|
| **Name** | `name` | Primary identifier, bold |
| **Category** | `category` | Badge with category icon |
| **Price** | `priceDisplay` | Right-aligned |
| **Status** | `availability` | Badge: green = active, yellow = seasonal, orange = temporarily unavailable, red = discontinued |
| **Type** | `provisionType` | "Prepared" / "Bought in" / "Hybrid" |
| **Dietary** | `isVegan`, `isGlutenFree` | V and GF badges (same style as Counter tiles) |

```svelte
<Table striped>
  <TableHead>
    <TableHeadCell>Name</TableHeadCell>
    <TableHeadCell>Category</TableHeadCell>
    <TableHeadCell class="text-right">Price</TableHeadCell>
    <TableHeadCell>Status</TableHeadCell>
    <TableHeadCell>Type</TableHeadCell>
    <TableHeadCell>Dietary</TableHeadCell>
    <TableHeadCell><span class="sr-only">Edit</span></TableHeadCell>
  </TableHead>
  <TableBody>
    {#each filteredCatalogue as item}
      <TableBodyRow class="cursor-pointer hover:bg-primary-50 dark:hover:bg-primary-900/10"
                    onclick={() => startEditItem(item)}>
        <TableBodyCell class="font-medium text-secondary-900 dark:text-white">
          {item.name}
        </TableBodyCell>
        <!-- ... remaining cells ... -->
      </TableBodyRow>
    {/each}
  </TableBody>
</Table>
```

Clicking any row opens the inline edit panel (Stage 3). An explicit "Edit" link in the last column provides a visible affordance.

### 1.4 Availability status badge mapping

```typescript
const AVAILABILITY_CONFIG: Record<string, { label: string; color: string }> = {
  active:                  { label: 'Active',       color: 'green' },
  seasonal:                { label: 'Seasonal',     color: 'yellow' },
  temporarily_unavailable: { label: 'Unavailable',  color: 'orange' },  // Note: Flowbite uses 'yellow' or 'red'; use custom class for orange
  discontinued:            { label: 'Discontinued', color: 'red' },
};
```

For the "temporarily_unavailable" state where Flowbite doesn't have a native orange badge, use a custom Tailwind class: `bg-orange-100 text-orange-800 dark:bg-orange-900/30 dark:text-orange-400`.

### 1.5 Provision type display

```typescript
const PROVISION_LABELS: Record<string, string> = {
  prepared:  'Prepared',
  bought_in: 'Bought in',
  hybrid:    'Hybrid',
};
```

Subtle text styling — not a badge, just `text-secondary-500 dark:text-secondary-400`.

### 1.6 Empty and loading states

- **Loading:** `Spinner` component centred in the content area during initial fetch
- **Error:** `Alert` with red colour and retry link
- **Empty filter:** "No items in this category" message when a filter produces zero results
- **Empty catalogue:** "No items in the catalogue. Add your first item to get started." with prominent Add Item button

### 1.7 "Add Item" button

Positioned above the table, right-aligned:

```svelte
<div class="mb-4 flex items-center justify-between">
  <h2 class="text-lg font-semibold text-secondary-800 dark:text-white">
    Catalogue
    <Badge color="dark" class="ms-2">{filteredCatalogue.length}</Badge>
  </h2>
  <Button color="primary" size="sm" onclick={() => showAddModal = true}>
    + Add Item
  </Button>
</div>
```

### 1.8 Verification

1. Page loads and shows all 11 seed items in the table
2. Category filter tabs work — "All" shows 11, "Hot Drinks" shows 6, "Cold Drinks" shows 3, "Food" shows 2
3. Status badges show green "Active" for all seed items
4. Provision type shows "Prepared" for drinks, "Bought in" for food
5. Dietary badges: V for Americano, Cold Brew, Oat Bar; GF for Oat Bar
6. Table is readable in both light and dark mode
7. Loading spinner appears briefly on page load
8. "Add Item" button is visible and functional (opens modal — built in Stage 2)

### 1.9 Commit point

Combined with Stage 2 (Add Item modal) for a meaningful commit.

---

## Stage 2: Add Item Modal

### 2.1 Modal structure

Flowbite `Modal` component triggered by the "Add Item" button. The modal uses a multi-section form layout with category-aware conditional fields.

```svelte
<Modal title="Add New Item" bind:open={showAddModal} size="lg" autoclose={false}>
  <!-- Form content -->
  <svelte:fragment slot="footer">
    <Button color="primary" onclick={submitNewItem} disabled={!canSubmitNew || submittingNew}>
      {submittingNew ? 'Adding…' : 'Add to Catalogue'}
    </Button>
    <Button color="alternative" onclick={() => showAddModal = false}>Cancel</Button>
  </svelte:fragment>
</Modal>
```

### 2.2 Form state

```typescript
let showAddModal = $state(false);
let submittingNew = $state(false);
let addError = $state('');

// Form fields — reset when modal opens
let newName = $state('');
let newCategory = $state<'hot_drink' | 'cold_drink' | 'food'>('hot_drink');
let newDescription = $state('');
let newPricePence = $state(0);
let newPriceDisplay = $state('');
let newIsVegan = $state(false);
let newProvisionType = $state<'prepared' | 'bought_in' | 'hybrid'>('prepared');

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

function resetAddForm() {
  newName = '';
  newCategory = 'hot_drink';
  newDescription = '';
  newPricePence = 0;
  newPriceDisplay = '';
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
```

### 2.3 Category-aware field rendering

The category selection drives which fields are shown, mirroring the domain model's `Drink` / `FoodItem` specialisation hierarchy:

**Section 1 — Common fields (always shown):**
- Name (`Input`, required)
- Category (`Select`: Hot Drink / Cold Drink / Food)
- Description (`Input`, optional)
- Price in pence (`Input[type=number]`, required) with auto-formatted display preview
- Vegan (`Toggle` or `Checkbox`)
- Provision type (`Select`: Prepared / Bought in / Hybrid)

**Section 2 — Drink fields (shown when category is `hot_drink` or `cold_drink`):**
- Default milk (`Select`: Whole / Semi / Oat / Soy / Almond / None)
- Available sizes (multi-select toggles: Small, Medium, Large — each is a toggle button, multiple can be active)
- Caffeinated (`Toggle` or `Checkbox`)

**Section 3 — Food fields (shown when category is `food`):**
- Gluten-free (`Toggle` or `Checkbox`)
- Served warm (`Toggle` or `Checkbox`)

**Section 4 — Initial inventory (shown when provision type is `bought_in`):**
- Initial stock quantity (`Input[type=number]`)
- Low-stock threshold (`Input[type=number]`, default 5)

```svelte
{#if newCategory !== 'food'}
  <!-- Drink-specific fields -->
  <div class="mt-4 rounded-lg border border-secondary-200 p-4 dark:border-secondary-700">
    <h4 class="mb-3 text-sm font-semibold text-secondary-600 dark:text-secondary-400">
      Drink Options
    </h4>
    <!-- milk, sizes, caffeinated -->
  </div>
{:else}
  <!-- Food-specific fields -->
  <div class="mt-4 rounded-lg border border-secondary-200 p-4 dark:border-secondary-700">
    <h4 class="mb-3 text-sm font-semibold text-secondary-600 dark:text-secondary-400">
      Food Options
    </h4>
    <!-- gluten-free, served warm -->
  </div>
{/if}

{#if newProvisionType === 'bought_in'}
  <div class="mt-4 rounded-lg border border-secondary-200 p-4 dark:border-secondary-700">
    <h4 class="mb-3 text-sm font-semibold text-secondary-600 dark:text-secondary-400">
      Initial Inventory
    </h4>
    <!-- stock quantity, threshold -->
  </div>
{/if}
```

### 2.4 Category change side-effects

When the category changes, update related defaults:

```typescript
function handleCategoryChange(cat: string) {
  newCategory = cat as 'hot_drink' | 'cold_drink' | 'food';

  if (cat === 'food') {
    // Food items are typically bought in
    newProvisionType = 'bought_in';
    // Clear drink-specific fields
    newDefaultMilk = 'whole';
    newAvailableSizes = [];
    newIsCaffeinated = null;
  } else {
    // Drinks are typically prepared
    newProvisionType = 'prepared';
    // Set drink defaults
    newDefaultMilk = 'whole';
    newAvailableSizes = cat === 'hot_drink'
      ? ['small', 'medium', 'large']
      : ['medium', 'large'];
    newIsCaffeinated = true;
    // Clear food-specific fields
    newIsGlutenFree = false;
    newServedWarm = false;
  }
}
```

### 2.5 Price input with preview

The price is stored in pence (integer) for precision. The form takes a pence input and auto-generates the display string:

```typescript
let newPricePreview = $derived(
  newPricePence > 0 ? `£${(newPricePence / 100).toFixed(2)}` : ''
);
```

The `priceDisplay` field sent to the API is this computed preview. The user enters `280` and sees `£2.80` alongside the input.

### 2.6 Size selection as toggle buttons

Available sizes use the same toggle button pattern as the Counter page, but here multiple sizes can be active simultaneously:

```svelte
<div class="flex gap-2">
  {#each ['small', 'medium', 'large'] as size}
    <Button
      color={newAvailableSizes.includes(size) ? 'primary' : 'alternative'}
      size="sm"
      onclick={() => toggleSize(size)}
    >
      {size.charAt(0).toUpperCase() + size.slice(1)}
    </Button>
  {/each}
</div>
```

```typescript
function toggleSize(size: string) {
  if (newAvailableSizes.includes(size)) {
    newAvailableSizes = newAvailableSizes.filter(s => s !== size);
  } else {
    newAvailableSizes = [...newAvailableSizes, size];
  }
}
```

At least one size must be selected for drink items. The form validation enforces this.

### 2.7 Form validation

```typescript
let itemType = $derived(newCategory === 'food' ? 'food_item' : 'drink');

let canSubmitNew = $derived(
  newName.trim() !== '' &&
  newPricePence > 0 &&
  (newCategory === 'food' || newAvailableSizes.length > 0)
);
```

### 2.8 Submit handler

```typescript
async function submitNewItem() {
  if (!canSubmitNew) return;
  submittingNew = true;
  addError = '';

  const input: CreateCatalogueItemInput = {
    menuItem: {
      name: newName.trim(),
      category: newCategory,
      itemType: itemType,
      description: newDescription.trim() || undefined,
      isVegan: newIsVegan,
      ...(itemType === 'drink' ? {
        defaultMilk: newDefaultMilk,
        availableSizes: newAvailableSizes,
        isCaffeinated: newIsCaffeinated,
      } : {
        isGlutenFree: newIsGlutenFree,
        servedWarm: newServedWarm,
      }),
    },
    pricePence: newPricePence,
    priceDisplay: newPricePreview,
    provisionType: newProvisionType,
    ...(newProvisionType === 'bought_in' && newInitialStock > 0 ? {
      initialStock: {
        quantityOnHand: newInitialStock,
        lowStockThreshold: newLowStockThreshold,
      },
    } : {}),
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

    // Success — close modal, refresh data
    showAddModal = false;
    resetAddForm();
    await fetchAll();
    addSuccess = `Added "${newName.trim()}" to the catalogue`;
    setTimeout(() => { addSuccess = ''; }, 4000);
  } catch (err) {
    addError = err instanceof Error ? err.message : 'Failed to add item';
  } finally {
    submittingNew = false;
  }
}
```

### 2.9 Error handling

- **Duplicate name (409):** The API returns 409 for duplicate item names. Show inline: "Item already exists: [name]"
- **Validation error (400):** Display the API's error message
- **Server error (500):** Generic failure message with suggestion to check PostgreSQL

### 2.10 Verification

1. Clicking "Add Item" opens the modal
2. Selecting "Hot Drink" shows drink fields with Small/Medium/Large sizes pre-selected
3. Selecting "Cold Drink" shows drink fields with Medium/Large pre-selected
4. Selecting "Food" shows food fields, hides drink fields, sets provision to "Bought in"
5. Selecting "Bought in" provision type reveals initial inventory fields
6. Price preview updates as pence value changes
7. Size toggle buttons work (click to add/remove sizes)
8. Form validation prevents submission with missing name or zero price
9. Submitting a valid item: modal closes, table refreshes with new item, success alert shown
10. Submitting a duplicate name shows error in modal without closing it
11. Cancel closes the modal without side effects
12. Added item appears in Counter page's catalogue tiles

### 2.11 Commit point

```bash
git add -A && git commit -m "CSW frontend: Manager catalogue table and add item modal"
```

---

## Stage 3: Inline Catalogue Editing

### 3.1 Edit panel approach

Clicking a row in the catalogue table opens an **inline edit panel** below the table (not a modal — the table remains visible for context). The edit panel shows the item's current values with editable fields for the mutable properties.

**Why inline panel, not modal?** The manager is likely comparing items or checking context while editing. An inline panel keeps the table visible. This also leaves the modal pattern reserved for creation (a more deliberate, separate action). Clinical analogue: editing a formulary entry is typically an inline operation within the formulary view, not a popup.

```typescript
let editingItem = $state<CatalogueItemView | null>(null);
let editPricePence = $state(0);
let editPriceDisplay = $state('');
let editAvailability = $state('active');
let editStatusNotes = $state('');
let editSubmitting = $state(false);
let editError = $state('');

function startEditItem(item: CatalogueItemView) {
  editingItem = item;
  editPricePence = item.pricePence;
  editPriceDisplay = item.priceDisplay;
  editAvailability = item.availability;
  editStatusNotes = item.statusNotes ?? '';
  editError = '';
}

function cancelEdit() {
  editingItem = null;
  editError = '';
}
```

### 3.2 Editable fields

The `PUT /api/catalogue/[id]` endpoint accepts `UpdateCatalogueEntryInput` which allows updating:

- **Price** (`pricePence` + `priceDisplay`) — same pence input with preview as the add form
- **Availability** (`availability`) — Select with four options: Active, Seasonal, Temporarily Unavailable, Discontinued
- **Status notes** (`statusNotes`) — free text, e.g. "Seasonal — available Nov–Feb", "Supplier issue, expected back next week"

Fields that are **not editable** from this panel: the menu item's intrinsic properties (name, category, dietary flags, sizes). These are part of the item definition, not the catalogue entry. A future "Edit Menu Item" capability could be added, but for now the conceptual boundary is clear: the manager edits **business decisions** (price, availability, notes), not **product definitions**.

### 3.3 Edit panel layout

```svelte
{#if editingItem}
  <div class="mt-4 rounded-lg border border-primary-200 bg-primary-50/50 p-4 dark:border-primary-800 dark:bg-primary-900/10">
    <div class="mb-3 flex items-center justify-between">
      <h3 class="font-semibold text-secondary-800 dark:text-white">
        Editing: {editingItem.name}
      </h3>
      <Button color="alternative" size="xs" onclick={cancelEdit}>Cancel</Button>
    </div>

    <div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
      <!-- Price -->
      <div>
        <Label for="edit-price" class="mb-1">Price (pence)</Label>
        <Input id="edit-price" type="number" bind:value={editPricePence} min={0} />
        {#if editPricePence > 0}
          <p class="mt-1 text-xs text-secondary-500">
            Display: £{(editPricePence / 100).toFixed(2)}
          </p>
        {/if}
      </div>

      <!-- Availability -->
      <div>
        <Label for="edit-availability" class="mb-1">Availability</Label>
        <Select id="edit-availability" bind:value={editAvailability}>
          <option value="active">Active</option>
          <option value="seasonal">Seasonal</option>
          <option value="temporarily_unavailable">Temporarily Unavailable</option>
          <option value="discontinued">Discontinued</option>
        </Select>
      </div>

      <!-- Status Notes -->
      <div>
        <Label for="edit-notes" class="mb-1">Status Notes</Label>
        <Input id="edit-notes" bind:value={editStatusNotes} placeholder="Optional notes" />
      </div>
    </div>

    {#if editError}
      <Alert color="red" class="mt-3">{editError}</Alert>
    {/if}

    <div class="mt-4 flex gap-2">
      <Button color="primary" size="sm" onclick={submitEdit} disabled={editSubmitting}>
        {editSubmitting ? 'Saving…' : 'Save Changes'}
      </Button>
      <Button color="alternative" size="sm" onclick={cancelEdit}>Cancel</Button>
    </div>
  </div>
{/if}
```

### 3.4 Submit edit handler

```typescript
async function submitEdit() {
  if (!editingItem) return;
  editSubmitting = true;
  editError = '';

  const editedPriceDisplay = `£${(editPricePence / 100).toFixed(2)}`;

  const input: UpdateCatalogueEntryInput = {
    pricePence: editPricePence,
    priceDisplay: editedPriceDisplay,
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

    // Success — close edit panel, refresh data
    editingItem = null;
    await fetchAll();
    editSuccess = 'Changes saved';
    setTimeout(() => { editSuccess = ''; }, 3000);
  } catch (err) {
    editError = err instanceof Error ? err.message : 'Failed to save changes';
  } finally {
    editSubmitting = false;
  }
}
```

### 3.5 Visual feedback for edited row

After saving, the table refreshes. The edited item appears with its updated price/status. If the availability was changed to "discontinued" and the filter is set to a specific category, the item remains visible (the manager view always uses `?all=true`).

### 3.6 Verification

1. Clicking a table row opens the edit panel below the table
2. Edit panel shows the item's current price, availability, and status notes
3. Changing price updates the display preview
4. Changing availability to "Discontinued" and saving → row updates with red "Discontinued" badge
5. Adding status notes and saving → notes are persisted (verify via `GET /api/catalogue/[id]`)
6. Cancel closes the edit panel without saving
7. Saving shows success message, table refreshes
8. Editing a second item replaces the first in the edit panel
9. Changing an item to "Temporarily Unavailable" → item no longer appears on Counter page (which uses the active-only endpoint)

### 3.7 Commit point

```bash
git add -A && git commit -m "CSW frontend: Manager catalogue inline editing and inventory panel"
```

Combined with Stage 4 (inventory panel) since both contribute to the right-hand side of the management page.

---

## Stage 4: Inventory Panel

### 4.1 Panel structure

The inventory panel occupies the right column (desktop) or sits below the catalogue table (mobile). It shows only bought-in items (the items that have inventory records in the database). Prepared items don't appear here — they don't have finished-product inventory.

From the seed data: Ginger Biscuit (24 in stock, threshold 5) and Oat Bar (18 in stock, threshold 5). Any new bought-in items added via the modal will also appear here.

```svelte
<div class="w-full md:w-96 lg:w-[28rem] shrink-0">
  <div class="mb-3 flex items-center justify-between">
    <h2 class="text-lg font-semibold text-secondary-800 dark:text-white">
      Inventory
      <Badge color="dark" class="ms-2">{inventory.length}</Badge>
    </h2>
  </div>

  {#if inventory.length === 0 && !loading}
    <div class="rounded-lg border-2 border-dashed border-secondary-200 p-6 text-center dark:border-secondary-700">
      <p class="text-sm text-secondary-400 dark:text-secondary-500">No bought-in items tracked</p>
    </div>
  {:else}
    {#each inventory as inv}
      <InventoryCard item={inv} onUpdate={handleInventoryUpdate} />
    {/each}
  {/if}
</div>
```

### 4.2 Inventory card layout

Each inventory record renders as a card:

```svelte
<!-- Inline within +page.svelte (no separate component file — keeps the phase to a single page file) -->
{#each inventory as inv}
  <div class="mb-3 rounded-lg border border-secondary-200 bg-white p-4 dark:border-secondary-700 dark:bg-secondary-800">
    <!-- Header: name and stock status badge -->
    <div class="mb-2 flex items-center justify-between">
      <span class="font-medium text-secondary-800 dark:text-white">{inv.name}</span>
      <Badge color={STOCK_STATUS_COLORS[inv.stockStatus]}>{STOCK_STATUS_LABELS[inv.stockStatus]}</Badge>
    </div>

    <!-- Stock level bar -->
    <div class="mb-2">
      <div class="mb-1 flex justify-between text-xs text-secondary-500 dark:text-secondary-400">
        <span>{inv.quantityOnHand} in stock</span>
        <span>Threshold: {inv.lowStockThreshold}</span>
      </div>
      <div class="h-2 w-full rounded-full bg-secondary-200 dark:bg-secondary-700">
        <div
          class="h-2 rounded-full {stockBarColor(inv)}"
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
  </div>
{/each}
```

### 4.3 Stock status configuration

```typescript
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
```

### 4.4 Stock adjustment interaction

Clicking "Restock" or "Adjust" on a card opens a small inline form within that card (expanding the card, not a modal):

```typescript
let adjustingInventoryId = $state<string | null>(null);
let adjustMode = $state<'restock' | 'adjust'>('restock');
let adjustQuantity = $state(0);
let adjustNotes = $state('');
let adjustSubmitting = $state(false);
let adjustError = $state('');

function startStockAdjust(inv: InventoryItemView, mode: 'restock' | 'adjust') {
  adjustingInventoryId = inv.inventoryRecordId;
  adjustMode = mode;
  adjustQuantity = mode === 'restock' ? 24 : inv.quantityOnHand;  // Restock defaults to a full batch; adjust starts at current level
  adjustNotes = '';
  adjustError = '';
}
```

**Restock mode:** Sets the stock to a new total (typically higher). The `PUT /api/inventory/[id]` endpoint auto-calculates `stock_status` and sets `last_restocked` when quantity increases.

**Adjust mode:** Sets the stock to an arbitrary value (for corrections, wastage, stock-takes). Same endpoint, different intent. The notes field captures the reason.

```svelte
{#if adjustingInventoryId === inv.inventoryRecordId}
  <div class="mt-3 rounded border border-secondary-200 bg-secondary-50 p-3 dark:border-secondary-600 dark:bg-secondary-700/50">
    <div class="mb-2 text-sm font-medium text-secondary-700 dark:text-secondary-300">
      {adjustMode === 'restock' ? 'Restock' : 'Adjust Stock'}
    </div>
    <div class="flex gap-2">
      <div class="flex-1">
        <Input type="number" bind:value={adjustQuantity} min={0} size="sm" />
      </div>
      <div class="flex-1">
        <Input bind:value={adjustNotes} placeholder="Notes (optional)" size="sm" />
      </div>
    </div>
    {#if adjustError}
      <p class="mt-1 text-xs text-red-600">{adjustError}</p>
    {/if}
    <div class="mt-2 flex gap-2">
      <Button size="xs" color="primary" onclick={() => submitStockAdjust(inv)} disabled={adjustSubmitting}>
        {adjustSubmitting ? 'Saving…' : 'Save'}
      </Button>
      <Button size="xs" color="alternative" onclick={() => adjustingInventoryId = null}>Cancel</Button>
    </div>
  </div>
{/if}
```

### 4.5 Stock adjustment submit

```typescript
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

    // Success — close adjust form, refresh data
    adjustingInventoryId = null;
    await fetchAll();
  } catch (err) {
    adjustError = err instanceof Error ? err.message : 'Failed to update stock';
  } finally {
    adjustSubmitting = false;
  }
}
```

### 4.6 Verification

1. Inventory panel shows 2 items: Ginger Biscuit (24) and Oat Bar (18)
2. Both show green "In Stock" badges and green progress bars
3. Clicking "Restock" on Ginger Biscuit opens the inline form with quantity 24
4. Changing to 30 and saving → quantity updates, progress bar adjusts, `last_restocked` updates
5. Clicking "Adjust" on Oat Bar opens the inline form with quantity 18
6. Changing to 3 and saving → badge changes to "Low" (below threshold of 5), bar turns yellow
7. Changing to 0 → badge changes to "Out of Stock", bar turns red
8. Low-stock alert banner appears at page top after the adjustment
9. Adding a new bought-in item via the modal (with initial stock) → item appears in inventory panel

### 4.7 Commit point

Combined with Stage 3 (inline editing) — see Stage 3.7 above.

---

## Stage 5: Low-Stock Alerts, Polish & Integration Testing

### 5.1 Low-stock alert banner

At the top of the page, before the main content, show alerts for any items below their low-stock threshold:

```svelte
{#if lowStockItems.length > 0}
  <Alert color="yellow" class="mb-4">
    <span class="font-medium">Low Stock Alert:</span>
    {#each lowStockItems as item, i}
      {item.name} ({item.quantityOnHand} remaining){i < lowStockItems.length - 1 ? ', ' : ''}
    {/each}
  </Alert>
{/if}
```

The alert uses the data from `GET /api/inventory?low=true`, which is refreshed each time `fetchAll()` runs. When the manager restocks an item above its threshold, the alert disappears on next refresh.

### 5.2 Success feedback

Consistent success messages for all operations:

```typescript
let addSuccess = $state('');
let editSuccess = $state('');

// After successful add:
addSuccess = `Added "${name}" to the catalogue`;
setTimeout(() => { addSuccess = ''; }, 4000);

// After successful edit:
editSuccess = 'Changes saved';
setTimeout(() => { editSuccess = ''; }, 3000);
```

Rendered as green `Alert` components below the page heading.

### 5.3 Page heading and summary

```svelte
<div class="mb-6">
  <h1 class="text-2xl font-bold text-secondary-800 dark:text-white">Stock & Catalogue</h1>
  <p class="text-sm text-secondary-500 dark:text-secondary-400">
    {catalogue.length} items in catalogue — {catalogue.filter(i => i.availability === 'active').length} active,
    {inventory.length} tracked in inventory
  </p>
</div>
```

### 5.4 Sort by name/price

Add a simple sort toggle for the table. Default sort: by name (alphabetical). Alternative: by price (ascending).

```typescript
let sortBy = $state<'name' | 'price'>('name');

let sortedCatalogue = $derived(
  [...filteredCatalogue].sort((a, b) =>
    sortBy === 'name'
      ? a.name.localeCompare(b.name)
      : a.pricePence - b.pricePence
  )
);
```

Sort toggle as small text links above the table: "Sort: Name | Price".

### 5.5 Dark mode verification

All new components must render correctly in both modes. Specific checks:
- Table row hover states
- Edit panel border and background
- Modal overlay and background
- Inventory card backgrounds and borders
- Stock status progress bar on dark background
- Badge colours
- Alert colours
- Toggle/checkbox states
- Input field borders and text

### 5.6 Keyboard accessibility

- Table rows are clickable via mouse; add `tabindex="0"` and `onkeydown` handler for Enter to open edit
- Modal focus trap (Flowbite Modal handles this natively)
- Form fields in the edit panel and adjust forms have appropriate `id` and `Label` associations
- Escape key closes modal and edit panel

### 5.7 Counter page integration test

Verify that changes made in the Manager GUI are reflected on the Counter page:

1. **Add a new item:** Add "Hot Chocolate" (hot drink, prepared, £3.00) via the modal → navigate to Counter → "Hot Chocolate" appears in Hot Drinks tiles
2. **Change price:** Edit Flat White price from 280 to 300 (£3.00) via edit panel → Counter tile shows £3.00
3. **Discontinue an item:** Set Espresso to "Discontinued" → Counter no longer shows Espresso tile (active-only filter)
4. **Make temporarily unavailable:** Set Cappuccino to "Temporarily Unavailable" → Counter no longer shows Cappuccino
5. **Reactivate:** Set Cappuccino back to "Active" → Counter shows Cappuccino again
6. **Stock depletion flow:** Set Oat Bar stock to 0 via inventory adjust → place an order for Oat Bar from Counter → inventory shows 0 (already was 0) → note: the order still goes through because the catalogue entry is "active"; stock depletion doesn't automatically block orders in this phase. (The "cannot discontinue item with active orders" constraint is a Knowledge Layer Increment listed in the workstream plan.)

### 5.8 Verification — full integration

1. Page loads with all 11 items in the table and 2 items in inventory
2. Category filter works with correct counts
3. Add a new drink item → appears in table and Counter
4. Add a new food item with initial stock → appears in table, inventory panel, and Counter
5. Edit an item's price → table updates, Counter reflects new price
6. Change availability to discontinued → red badge in table, item disappears from Counter
7. Restock an inventory item → quantity updates, bar adjusts, last restocked date updates
8. Adjust stock below threshold → low-stock alert appears, badge changes to "Low"
9. All operations work in dark mode
10. Mobile layout: stacked, all controls accessible

### 5.9 Commit point

```bash
git add -A && git commit -m "CSW frontend: Manager page polish, low-stock alerts, integration verified"
```

---

## Files Created / Modified

### Modified files

| File | Change |
|---|---|
| `src/routes/management/catalogue/+page.svelte` | **Rewritten** — full Manager GUI replacing placeholder |

### Unchanged

All API routes, all `$lib/server/` modules, all `packages/shared/` and `packages/temporal/` code, the Counter page (`+page.svelte`), layout (`+layout.svelte`), `app.css`, and all other page files.

This phase is entirely frontend — no backend changes, no new API routes, no package changes.

---

## Risks and Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| **Flowbite Modal with Svelte 5 `$state`** | Low | Flowbite Modal has worked correctly in Phase 5's Flowbite components. The `bind:open` pattern should work with `$state`. If not, fall back to manual show/hide via a wrapper function. |
| **Flowbite Table component styling conflicts** | Low–Medium | The Phase 4 experience showed that Flowbite components sometimes apply their own dark mode classes that conflict with the custom palette. CSS overrides in `app.css` may be needed. Fall back to raw HTML table with Tailwind classes if Flowbite Table is problematic. |
| **Large modal on mobile** | Low | Flowbite Modal with `size="lg"` scrolls on mobile. The category-conditional fields keep the form reasonably compact. Test on narrow viewport. |
| **`CreateCatalogueItemInput` type matching** | Low | The input type is well-defined in `@coffeeshop/shared`. The form constructs the object to match. The API's validation will catch mismatches with clear error messages. |
| **Concurrent editing** | Very low | Single-user demonstrator. Last-write-wins is acceptable. No optimistic locking needed. |
| **Price as pence input** | Low | Entering pence is slightly unusual UX. The live preview (`£2.80`) mitigates confusion. A future improvement could use a pounds-and-pence input that converts internally. |

---

## What This Phase Does Not Do

- Does not modify any API routes or backend logic (Phase 3 covered this)
- Does not implement the "cannot discontinue item with active orders" constraint (Knowledge Layer Increment, post-Phase 10)
- Does not implement menu item editing (name, category, dietary flags — these are intrinsic product properties, not business decisions)
- Does not build the Order Board kanban view (Phase 7)
- Does not add real-time updates (SSE/WebSocket — Phase 9 consideration)
- Does not modify the SysML model (Phase 10)
- Does not implement external references management (low priority — no UI yet)

---

## Coffee Shop Demonstrator Extension

**Capability demonstrated:** Reference data management GUI — the system's catalogue and inventory are managed through a structured interface that respects the domain model's four-layer conceptual separation (item definition → catalogue entry → inventory record → external references). Business decisions (price, availability) are editable; product definitions (name, type, dietary properties) are stable.

**Clinical implementation confidence:** High. The pattern maps directly to:
- **Formulary management:** Table of medications with availability status, price, prescribing restrictions. Modal for adding new formulary entries with medication-type-specific fields (hormone vs blocker vs supplement). Inline editing for price, formulary status, prescribing notes.
- **Pharmacy stock management:** Inventory panel for tracked medications with stock levels, low-stock alerts, restock and adjustment controls. Stock status badges driving alert banners.
- **The four-layer separation** (medication definition → formulary entry → stock record → external references like BNF/SPC links) is preserved in the UI's architectural structure, even though the user experiences it as a single management page.

**What will be learned:**
- Whether Flowbite Table + inline edit + inventory side-panel provides a workable management layout (or whether a tab-based approach is needed)
- How the `CreateCatalogueItemInput` transaction pattern (menu item + catalogue entry + optional inventory in one POST) feels in practice
- Whether pence-based price input is adequate or needs a pounds-and-pence UX pattern
- How the category-conditional form fields work in practice (the SysML domain model's `Drink` / `FoodItem` specialisation hierarchy driving form structure)

---

## Relationship to Knowledge Layer Increments

Per the CSW Extension workstream plan §5:

> **Catalogue constraint:** Cannot discontinue item with active orders → Manager GUI — validation on status change. **Trigger:** When Phase 6 (Manager GUI) is complete.

With Phase 6 complete, this constraint becomes implementable. The validation would:
1. When the manager changes availability to "discontinued" or "temporarily_unavailable"
2. Query Temporal for running workflows matching the item name
3. If any are found, block the status change and show: "Cannot discontinue — N active orders in progress"

This is not in scope for Phase 6 but is now unblocked as a Knowledge Layer exercise.

---

*Plan prepared 14 March 2026. Phase 6 of the CSW Extension workstream.*
