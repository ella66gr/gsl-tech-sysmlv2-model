# CSW Extension Phase 5: Counter Page (Dynamic Order Form) — Detailed Implementation Plan

**Workstream:** Coffee Shop Extension — Catalogue, Inventory & Frontend
**Phase:** 5 of 10
**Date:** 13 March 2026
**Session:** 24
**Prerequisites:** Phase 4 complete (Frontend Foundation, Session 23)
**Source plan:** `gsl-plan-workstream-csw-extension-2026-03-12.md` §Phase 5
**Design reference:** `gsl-plan-coffeeshop-frontend-reboot-2026-03-12.md` §5.2 (Counter design)
**Estimated effort:** 4 stages

---

## Goal

The Counter page — the coffee shop's landing page — becomes a catalogue-driven, visually rich order form with a live active orders panel. The hardcoded `<Select>` dropdowns are replaced by visual item tiles generated from `GET /api/catalogue`, grouped by category. Size selection uses toggle buttons derived from each item's `availableSizes` property. Dietary badges (vegan, gluten-free), provision type, and pricing are visible on every tile. A right-hand panel shows all currently active orders with live state updates and inline action buttons. The page becomes the barista's operational dashboard: place orders, see what's in progress, advance order state — all from one view.

This phase touches only the Counter page (`+page.svelte`) and creates one new API route for active order state queries. All existing API routes, Temporal workflows, and backend logic are unchanged.

---

## Architecture Overview

### Data Flow

```
                  ┌─────────────────────────┐
                  │  GET /api/catalogue      │
                  │  (Phase 3 — existing)    │
                  └────────┬────────────────┘
                           │ CatalogueItemView[]
                           ▼
┌──────────────────────────────────────────────────────────────┐
│                   Counter Page (+page.svelte)                │
│                                                              │
│  ┌──────────────────────┐    ┌───────────────────────────┐  │
│  │  Left Panel           │    │  Right Panel              │  │
│  │                       │    │                           │  │
│  │  Category tabs/pills  │    │  Active Orders Dashboard  │  │
│  │  Item tiles (from     │    │  - Cards per running wf   │  │
│  │    catalogue)         │    │  - State badge            │  │
│  │  Size toggles (from   │    │  - Time elapsed           │  │
│  │    availableSizes)    │    │  - Next action button     │  │
│  │  Customer name input  │    │  - Auto-refresh (poll)    │  │
│  │  Place Order button   │    │                           │  │
│  │                       │    │  ┌─────────────────────┐  │  │
│  └──────────┬───────────┘    │  │ GET /api/orders/list │  │  │
│             │                 │  │ GET /api/orders/[id] │  │  │
│             ▼                 │  └─────────────────────┘  │  │
│  ┌──────────────────────┐    └───────────────────────────┘  │
│  │ POST /api/orders      │                                   │
│  │ (Phase 3 — existing)  │                                   │
│  └──────────────────────┘                                   │
└──────────────────────────────────────────────────────────────┘
```

### Key Design Decisions

| Decision | Rationale |
|---|---|
| **Visual tiles, not dropdowns** | Makes the menu tangible. A barista glances at tiles; they don't scroll through dropdowns. Same pattern applies to the clinical formulary — visual medication cards rather than search dropdowns. |
| **Category grouping with tabs** | Three natural groups (hot drinks, cold drinks, food) match the catalogue's `category` field. Clinical analogue: medication categories (hormones, blockers, supplements). |
| **Size as toggle buttons** | Each item declares its own `availableSizes` in the catalogue. Toggle buttons make the valid options visible and prevent invalid selections. Espresso shows only "Small"; Iced Latte shows "Medium" and "Large". |
| **Split view (order form + active orders)** | The barista's real workflow is: take an order, check on other orders, advance them when ready. A single-page dashboard replaces the current navigate-away-to-see-orders pattern. Clinical analogue: clinician dashboard with consultation form + patient queue. |
| **Polling for active orders (not SSE/WebSocket)** | Consistent with the existing order detail page's polling pattern. 3-second interval for the active orders panel. Keeps the architecture simple — SSE is a Phase 9 enhancement if needed. |
| **Responsive: stacked on mobile, side-by-side on desktop** | Mobile: order form above, active orders below. Desktop (md+): two-column layout. |

---

## Stage 1: Catalogue Data Loading & Category Tabs

### 1.1 Create a catalogue data loader

The Counter page needs the full active catalogue on load. Two approaches:

**Option A: SvelteKit `+page.ts` load function** — fetches catalogue data server-side (or client-side with `ssr: false`), making it available as a page prop. This is the SvelteKit-idiomatic approach.

**Option B: Client-side `onMount` fetch** — simpler, consistent with how the orders list page works.

**Decision: Option A (load function).** The catalogue is stable reference data that benefits from being available immediately on page render. This avoids a loading spinner for the left panel on every page visit. The active orders panel (right) still uses client-side polling.

Create `src/routes/+page.ts`:

```typescript
import type { PageLoad } from './$types';
import type { CatalogueItemView } from '@coffeeshop/shared';

export const load: PageLoad = async ({ fetch }) => {
  const response = await fetch('/api/catalogue');
  
  if (!response.ok) {
    return { catalogue: [], error: 'Failed to load catalogue' };
  }
  
  const catalogue: CatalogueItemView[] = await response.json();
  return { catalogue };
};
```

**Note:** This uses the SvelteKit `fetch` wrapper which handles relative URLs and SSR correctly. The API route already filters to active items only.

### 1.2 Type definitions for the Counter

Define the view-model types needed by the Counter page. These are UI-specific and don't belong in `@coffeeshop/shared`:

```typescript
// Within +page.svelte <script> block

interface CategoryGroup {
  key: string;           // 'hot_drink' | 'cold_drink' | 'food'
  label: string;         // 'Hot Drinks' | 'Cold Drinks' | 'Food'
  icon: string;          // emoji for the tab label
  items: CatalogueItemView[];
}
```

### 1.3 Group catalogue items by category

Transform the flat catalogue array into grouped categories using `$derived`:

```typescript
const CATEGORY_CONFIG: Record<string, { label: string; icon: string; order: number }> = {
  hot_drink:  { label: 'Hot Drinks',  icon: '☕', order: 1 },
  cold_drink: { label: 'Cold Drinks', icon: '🧊', order: 2 },
  food:       { label: 'Food',        icon: '🍪', order: 3 },
};

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
    .sort((a, b) => (CATEGORY_CONFIG[a.key]?.order ?? 99) - (CATEGORY_CONFIG[b.key]?.order ?? 99));
});
```

### 1.4 Category tab bar

Render category tabs as Flowbite pill-style buttons. The active category determines which item tiles are shown.

```svelte
<div class="flex gap-2 mb-4">
  {#each categories as cat}
    <Button
      color={activeCategory === cat.key ? 'primary' : 'alternative'}
      size="sm"
      pill
      onclick={() => activeCategory = cat.key}
    >
      {cat.icon} {cat.label}
      <Badge color="dark" class="ms-2">{cat.items.length}</Badge>
    </Button>
  {/each}
</div>
```

State variable: `let activeCategory = $state('hot_drink');`

Default to `hot_drink` — the most common order category. If the catalogue is empty, show an `Alert`.

### 1.5 Verification

1. Dev server starts clean
2. Counter page loads without spinner (catalogue data available from load function)
3. Three category tabs render with correct counts (7 hot drinks, 2 cold drinks, 2 food items from seed data)
4. Clicking tabs switches the active category
5. No console errors

### 1.6 Commit point

```bash
git add -A && git commit -m "CSW frontend: Counter page catalogue loading and category tabs"
```

---

## Stage 2: Item Tiles & Size Selection

### 2.1 Item tile component

Each catalogue item renders as a visual tile within the active category group. The tile shows:

- **Item name** — prominent, e.g. "Flat White"
- **Price** — from `priceDisplay`, e.g. "£2.80"
- **Dietary badges** — `isVegan` → green "V" badge; `isGlutenFree` → blue "GF" badge
- **Provision type indicator** — subtle, bottom of tile: "Prepared" or "Bought in" (clinical analogue: "compounded" vs "dispensed")
- **Caffeinated indicator** — for drinks: small coffee bean icon or "Decaf" label for non-caffeinated (currently all are caffeinated, but the UI should handle the distinction)
- **Selected state** — highlighted border/background when this item is selected

Tile layout: Flowbite `Card`-style container using Tailwind classes (not the full `Card` component — too heavy for a grid of tiles). Each tile is a `<button>` for accessibility (keyboard navigation, focus management).

```svelte
<div class="grid grid-cols-2 gap-3 sm:grid-cols-3">
  {#each activeCategoryItems as item}
    <button
      class="rounded-lg border-2 p-3 text-left transition-colors
        {selectedItem?.catalogueEntryId === item.catalogueEntryId
          ? 'border-primary-500 bg-primary-50 dark:border-primary-400 dark:bg-primary-900/20'
          : 'border-secondary-200 bg-white hover:border-primary-300 dark:border-secondary-600 dark:bg-secondary-800 dark:hover:border-primary-600'}"
      onclick={() => selectItem(item)}
    >
      <div class="mb-1 font-semibold text-secondary-800 dark:text-white">{item.name}</div>
      <div class="mb-2 text-lg font-bold text-primary-600 dark:text-primary-400">{item.priceDisplay}</div>
      <div class="flex flex-wrap gap-1">
        {#if item.isVegan}
          <span class="inline-flex items-center rounded-full bg-green-100 px-2 py-0.5 text-xs font-medium text-green-800 dark:bg-green-900/30 dark:text-green-400">V</span>
        {/if}
        {#if item.isGlutenFree}
          <span class="inline-flex items-center rounded-full bg-blue-100 px-2 py-0.5 text-xs font-medium text-blue-800 dark:bg-blue-900/30 dark:text-blue-400">GF</span>
        {/if}
      </div>
      <div class="mt-2 text-xs text-secondary-400 dark:text-secondary-500">
        {item.provisionType === 'bought_in' ? 'Bought in' : 'Prepared'}
      </div>
    </button>
  {/each}
</div>
```

### 2.2 Item selection state

```typescript
let selectedItem = $state<CatalogueItemView | null>(null);
let selectedSize = $state<string>('');

function selectItem(item: CatalogueItemView) {
  selectedItem = item;
  // Auto-select the first available size, or 'medium' if available
  const sizes = item.availableSizes ?? [];
  if (sizes.includes('medium')) {
    selectedSize = 'medium';
  } else if (sizes.length > 0) {
    selectedSize = sizes[0];
  } else {
    selectedSize = '';  // Food items — no size
  }
}
```

### 2.3 Size toggle buttons

When an item is selected and has `availableSizes`, render size options as toggle buttons. This replaces the `<Select>` dropdown.

```svelte
{#if selectedItem?.availableSizes && selectedItem.availableSizes.length > 0}
  <div class="mt-4">
    <label class="mb-2 block text-sm font-medium text-secondary-700 dark:text-secondary-300">Size</label>
    <div class="flex gap-2">
      {#each selectedItem.availableSizes as size}
        <Button
          color={selectedSize === size ? 'primary' : 'alternative'}
          size="sm"
          onclick={() => selectedSize = size}
        >
          {size.charAt(0).toUpperCase() + size.slice(1)}
        </Button>
      {/each}
    </div>
  </div>
{:else if selectedItem}
  <!-- Food items: no size selection needed -->
{/if}
```

**Key behaviour:** The size options are dynamic per item. Espresso shows only "Small". Iced Latte shows "Medium" and "Large". Food items show no size selection at all. This is the catalogue driving the UI — the same pattern the clinical system will use for medication form/route/dose options.

### 2.4 Customer name and submit

Retain the customer name input and submit button, but now the submission payload includes the catalogue entry ID and price:

```typescript
async function placeOrder() {
  if (!selectedItem || !customerName) return;
  
  submitting = true;
  errorMessage = '';
  
  try {
    const response = await fetch('/api/orders', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        customerName,
        drinkType: selectedItem.name,   // POST /api/orders expects drinkType (item name)
        size: selectedSize || 'medium', // Food items default to 'medium' (backend handles gracefully)
      }),
    });
    
    if (!response.ok) {
      const data = await response.json();
      errorMessage = data.message || `Error: ${response.status}`;
      return;
    }
    
    const data = await response.json();
    
    // Success: reset selection, refresh active orders
    selectedItem = null;
    selectedSize = '';
    customerName = '';
    successMessage = `Order placed: ${data.catalogueEntry?.name ?? 'Order'} for ${data.orderId}`;
    
    // Trigger active orders refresh
    await fetchActiveOrders();
    
    // Clear success message after 4 seconds
    setTimeout(() => { successMessage = ''; }, 4000);
    
  } catch (err) {
    errorMessage = err instanceof Error ? err.message : 'Failed to place order';
  } finally {
    submitting = false;
  }
}
```

**Note:** The existing `POST /api/orders` endpoint accepts `{ customerName, drinkType, size }` where `drinkType` is the item name. It validates against the catalogue internally and returns `{ orderId, workflowId, state, catalogueEntry }`. No backend changes needed.

### 2.5 Order summary before submission

Before the Place Order button, show a brief confirmation line:

```svelte
{#if selectedItem && customerName}
  <div class="mt-4 rounded-lg bg-primary-50 p-3 dark:bg-primary-900/20">
    <p class="text-sm text-secondary-700 dark:text-secondary-300">
      <span class="font-semibold">{customerName}</span> —
      {selectedItem.name}
      {#if selectedSize}({selectedSize}){/if}
      — {selectedItem.priceDisplay}
    </p>
  </div>
{/if}
```

### 2.6 Verification

1. Clicking a category tab shows items in that category
2. Clicking an item tile highlights it and shows size options
3. Espresso shows only "Small"; Iced Latte shows "Medium" and "Large"; Ginger Biscuit shows no size selection
4. Dietary badges appear correctly (Americano, Cold Brew, Oat Bar are vegan; Oat Bar is GF)
5. Provision type shows "Bought in" for Ginger Biscuit and Oat Bar, "Prepared" for all drinks
6. Order summary line appears when item and customer name are both set
7. Submitting an order works — Temporal workflow starts, order appears in order list
8. Form resets after successful submission

### 2.7 Commit point

```bash
git add -A && git commit -m "CSW frontend: Counter item tiles with catalogue-driven size selection"
```

---

## Stage 3: Active Orders Dashboard (Right Panel)

### 3.1 New API route: Active orders with state

The existing `GET /api/orders/list` returns all workflows (up to 50) with their Temporal execution status (`RUNNING`, `COMPLETED`, etc.) but not their XState lifecycle state (`placed`, `inPreparation`, `ready`). The active orders panel needs the lifecycle state to show meaningful badges and action buttons.

**Approach: New API route** `GET /api/orders/active` that returns only running workflows with their queried XState state.

Create `src/routes/api/orders/active/+server.ts`:

```typescript
/**
 * GET /api/orders/active — Active orders with lifecycle state
 *
 * Returns running workflows with their current XState state queried from Temporal.
 * Designed for the Counter page active orders panel.
 *
 * Returns: { orders: ActiveOrder[] }
 */

import { json, error } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { getTemporalClient } from '$lib/server/temporal';
import { WORKFLOW_NAME, QUERY_ORDER_STATE } from '@coffeeshop/shared';

interface ActiveOrder {
  orderId: string;
  state: string;
  startTime: string | null;
  // customerName is not stored on the workflow description — it's in the workflow args.
  // We'll extract it from the orderId or query if available.
}

export const GET: RequestHandler = async () => {
  const client = await getTemporalClient();

  try {
    const orders: ActiveOrder[] = [];

    const iterator = client.workflow.list({
      query: `WorkflowType = '${WORKFLOW_NAME}' AND ExecutionStatus = 'Running'`,
    });

    for await (const workflow of iterator) {
      let state = 'unknown';
      try {
        const handle = client.workflow.getHandle(workflow.workflowId);
        state = await handle.query(QUERY_ORDER_STATE);
      } catch {
        // Query may fail if workflow just started — use 'unknown'
      }

      orders.push({
        orderId: workflow.workflowId,
        state,
        startTime: workflow.startTime?.toISOString() ?? null,
      });
    }

    return json({ orders });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : String(err);
    throw error(500, `Failed to list active orders: ${message}`);
  }
};
```

**Why a new route rather than extending the existing one?** The `list` route returns all workflows and doesn't query individual states (which requires a Temporal query per workflow). The active orders route is specifically optimised for the counter dashboard: only running workflows, with state queries. Querying state on all 50 historical workflows would be slow and wasteful.

### 3.2 Active orders panel layout

The right panel occupies `md:w-96 lg:w-[28rem]` on desktop and full width below the order form on mobile.

```svelte
<!-- Page-level split layout -->
<div class="flex flex-col gap-6 md:flex-row">
  <!-- Left panel: order form -->
  <div class="flex-1 min-w-0">
    <!-- Category tabs, tiles, size selection, customer name, submit -->
  </div>
  
  <!-- Right panel: active orders -->
  <div class="w-full md:w-96 lg:w-[28rem] shrink-0">
    <ActiveOrdersPanel />
  </div>
</div>
```

### 3.3 Active order cards

Each active order renders as a card showing:

- **Order ID** — truncated, monospaced
- **Current state** — as a Flowbite `Badge` with semantic colour (same colour scheme as the Order Board page)
- **Time elapsed** — computed from `startTime` to now, updating every second
- **Next action button** — the signal that advances the state (same mapping as the order detail page: `placed` → "Start Preparation", `inPreparation` → "Mark Ready", `ready` → "Collect")

```svelte
{#each activeOrders as order}
  <div class="mb-3 rounded-lg border border-secondary-200 bg-white p-3 dark:border-secondary-700 dark:bg-secondary-800">
    <div class="mb-2 flex items-center justify-between">
      <code class="text-xs text-secondary-500 dark:text-secondary-400">{order.orderId.replace('order-', '#')}</code>
      <Badge color={STATE_COLORS[order.state] ?? 'dark'} class="text-xs">
        {STATE_LABELS[order.state] ?? order.state}
      </Badge>
    </div>
    
    <div class="mb-2 text-xs text-secondary-400 dark:text-secondary-500">
      {formatElapsed(order.startTime)}
    </div>
    
    {#if STATE_ACTIONS[order.state]}
      <Button
        size="xs"
        color="primary"
        outline
        class="w-full"
        onclick={() => sendOrderSignal(order.orderId, STATE_ACTIONS[order.state]!.signal)}
        disabled={sendingSignal === order.orderId}
      >
        {sendingSignal === order.orderId ? 'Sending…' : STATE_ACTIONS[order.state]!.label}
      </Button>
    {/if}
  </div>
{/each}
```

### 3.4 Polling and refresh

```typescript
let activeOrders = $state<ActiveOrder[]>([]);
let activeOrdersLoading = $state(true);
let activeOrdersError = $state('');
let sendingSignal = $state<string | null>(null);

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
    activeOrdersError = err instanceof Error ? err.message : 'Failed to load active orders';
  } finally {
    activeOrdersLoading = false;
  }
}

// Poll every 3 seconds
onMount(() => {
  fetchActiveOrders();
  const interval = setInterval(fetchActiveOrders, 3000);
  return () => clearInterval(interval);
});
```

### 3.5 Inline signal sending

Advancing an order's state from the active orders panel (without navigating away):

```typescript
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
    // Immediately refresh to show updated state
    await fetchActiveOrders();
  } catch (err) {
    activeOrdersError = err instanceof Error ? err.message : 'Signal failed';
  } finally {
    sendingSignal = null;
  }
}
```

### 3.6 Time elapsed helper

```typescript
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
```

**Note:** The elapsed time display updates each time the poll fires (every 3 seconds), which is sufficient granularity for a coffee shop. A per-second tick would add complexity without meaningful benefit.

### 3.7 Empty state

When no orders are active:

```svelte
{#if activeOrders.length === 0 && !activeOrdersLoading}
  <div class="rounded-lg border-2 border-dashed border-secondary-200 p-6 text-center dark:border-secondary-700">
    <p class="text-sm text-secondary-400 dark:text-secondary-500">No active orders</p>
    <p class="mt-1 text-xs text-secondary-300 dark:text-secondary-600">Place an order to get started</p>
  </div>
{/if}
```

### 3.8 Panel header with count

```svelte
<div class="mb-3 flex items-center justify-between">
  <h2 class="text-lg font-semibold text-secondary-800 dark:text-white">
    Active Orders
    {#if activeOrders.length > 0}
      <Badge color="primary" class="ms-2">{activeOrders.length}</Badge>
    {/if}
  </h2>
  <a href="/orders" class="text-xs text-primary-600 hover:underline dark:text-primary-400">View all</a>
</div>
```

### 3.9 Verification

1. Active orders panel loads on the right (desktop) or below (mobile)
2. Running workflows appear as cards with correct state badges
3. Elapsed time displays and updates on each poll cycle
4. Clicking an action button sends the signal and the card updates
5. When an order reaches "collected", it disappears from the active panel on next poll
6. Placing a new order from the left panel causes it to appear in the right panel
7. Empty state message when no orders are running
8. "View all" link navigates to `/orders`

### 3.10 Commit point

```bash
git add -A && git commit -m "CSW frontend: Counter active orders dashboard with inline signals"
```

---

## Stage 4: Polish, Responsiveness & Edge Cases

### 4.1 Loading states

- **Catalogue loading failure:** If the load function returns an error (e.g. PostgreSQL down), show an `Alert` with retry guidance:
  ```svelte
  {#if data.error}
    <Alert color="red">
      <span class="font-medium">Catalogue unavailable:</span> {data.error}.
      Check that PostgreSQL is running. <a href="/" class="font-medium underline">Retry</a>
    </Alert>
  {/if}
  ```
- **Active orders loading:** Show a `Spinner` inside the right panel during initial load only (not on subsequent polls — avoid flicker)
- **Signal sending:** Disable the action button and show "Sending…" text while the signal request is in flight

### 4.2 Success feedback

After placing an order, show a brief success `Alert` that auto-dismisses:

```svelte
{#if successMessage}
  <Alert color="green" class="mb-4" dismissable>
    {successMessage}
  </Alert>
{/if}
```

### 4.3 Form validation

- **Customer name required** — button disabled when empty (existing behaviour, retained)
- **Item selection required** — button disabled when no item selected
- **Size required for drink items** — button disabled when item has `availableSizes` but none selected (should auto-select, but guard against edge cases)
- Visual feedback: the Place Order button text changes to reflect what's being ordered:
  ```svelte
  <Button disabled={!canSubmit || submitting} ...>
    {#if submitting}
      Placing order…
    {:else if selectedItem}
      Place Order — {selectedItem.name} {selectedItem.priceDisplay}
    {:else}
      Select an item
    {/if}
  </Button>
  ```

### 4.4 Responsive layout refinements

Test and adjust:
- **Mobile (< md):** Full-width stacked layout. Order form first, then active orders below. Item tiles as 2-column grid.
- **Tablet (md):** Side-by-side. Order form flex-1, active orders w-96. Item tiles as 2-column grid.
- **Desktop (lg+):** Side-by-side. Active orders slightly wider (w-[28rem]). Item tiles as 3-column grid.
- **Sidebar interaction:** The Counter page content starts at `md:ml-64` (sidebar offset, from layout). The split view needs to work within this constraint.

### 4.5 Keyboard accessibility

- Item tiles are `<button>` elements (already tabbable and enter-activatable)
- Size toggles are `<button>` elements
- Category tabs are `<button>` elements
- The form submit button receives focus after category/item/size selection flow
- `aria-pressed` on toggle buttons for size selection
- `aria-current="true"` on the active category tab

### 4.6 Dark mode verification

All new components must render correctly in both light and dark modes. Specific checks:
- Item tile borders and backgrounds
- Dietary badge colours
- Price text colour
- Active order card backgrounds
- Success/error alerts
- Category tab active/inactive states

### 4.7 Page title and subtitle update

```svelte
<div class="mb-6">
  <h1 class="text-2xl font-bold text-secondary-800 dark:text-white">Counter</h1>
  <p class="text-sm text-secondary-500 dark:text-secondary-400">
    {data.catalogue.length} items on the menu — select an item to place an order
  </p>
</div>
```

### 4.8 Order placed navigation option

After placing an order, in addition to the success message, offer a link to the order detail:

```typescript
let lastOrderId = $state('');

// In placeOrder(), after success:
lastOrderId = data.orderId;
```

```svelte
{#if successMessage && lastOrderId}
  <Alert color="green" class="mb-4" dismissable onclose={() => successMessage = ''}>
    {successMessage}
    <a href="/orders/{lastOrderId}" class="ms-2 font-medium underline">View order →</a>
  </Alert>
{/if}
```

### 4.9 Verification — Full integration test

1. Start with empty order queue. Counter loads, shows catalogue tiles, empty active orders panel.
2. Select "Hot Drinks" → click "Flat White" → sizes show Small/Medium/Large, Medium auto-selected → enter "Alice" → Place Order
3. Success message appears with link to order. Active orders panel shows the new order with "Placed" badge.
4. Click "Start Preparation" on the active order card → badge changes to "In Preparation"
5. Click "Mark Ready" → badge changes to "Ready"
6. Click "Collect" → order disappears from active panel (workflow completed)
7. Switch to "Food" tab → click "Ginger Biscuit" → no size selection shown → enter "Bob" → Place Order
8. Verify the order validates against catalogue (bought-in item, inventory decremented)
9. Switch to "Cold Drinks" → click "Iced Latte" → sizes show Medium/Large only
10. Test mobile layout (browser responsive mode or narrow window)
11. Test dark mode toggle — all elements render correctly
12. Navigate away and back — catalogue data reloads, active orders resume polling

### 4.10 Commit point

```bash
git add -A && git commit -m "CSW frontend: Counter page polish, responsiveness, and edge cases"
```

---

## Files Created / Modified

### New files

| File | Purpose |
|---|---|
| `src/routes/+page.ts` | SvelteKit load function — fetches catalogue data for the Counter page |
| `src/routes/api/orders/active/+server.ts` | API route — returns running orders with XState lifecycle state |

### Modified files

| File | Change |
|---|---|
| `src/routes/+page.svelte` | Complete rewrite: catalogue-driven tiles, size toggles, split layout with active orders panel |

### Unchanged

All other page files, all API routes (catalogue, orders, inventory, entity, etc.), all `$lib/server/` modules, all `packages/shared/` and `packages/temporal/` code.

---

## Risks and Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| **Querying state on many active orders is slow** | Low–Medium | The active orders route only queries running workflows (typically < 10 in a demo). If slow, add a timeout per query (500ms) and return `'unknown'` for timed-out queries. |
| **Polling causes stale state display** | Low | 3-second poll interval is sufficient for demo purposes. After a signal send, an immediate refresh is triggered. |
| **SvelteKit load function + client-side polling interaction** | Low | The load function provides initial catalogue data; polling is purely for active orders. No interaction between the two data flows. |
| **Food items with `size` parameter** | Low | The `POST /api/orders` endpoint already handles this — if the item has no `availableSizes`, it validates against the default `['small', 'medium', 'large']`. Food items will send `'medium'` as a default. This is slightly inelegant but functionally correct; a future refinement could make size optional for food items. |
| **Catalogue changes while page is open** | Very low | The catalogue is loaded once on page visit. If items are added/removed via the Manager GUI (Phase 6), the barista would need to refresh. This is acceptable for a demonstrator; a production system would use SSE or a shorter cache. |

---

## What This Phase Does Not Do

- Does not build the Manager GUI for stock and catalogue (Phase 6)
- Does not build the kanban Order Board (Phase 7)
- Does not add SSE/WebSocket for real-time updates (Phase 9 consideration)
- Does not modify Temporal workflows, XState machines, or EHRbase integration
- Does not change the data model or database schema
- Does not modify any existing API routes (the new `/api/orders/active` route is additive)

---

## Coffee Shop Demonstrator Extension

**Capability demonstrated:** Catalogue-driven dynamic UI — the system's reference data (catalogue) drives the user interface structure, replacing hardcoded options with data-driven tiles.

**Clinical implementation confidence:** High. The pattern — reference data → visual selection tiles → context-sensitive sub-options (sizes/doses) → validated submission — maps directly to:
- Medication selection from formulary → dose/route/frequency options driven by formulary entry → prescribing validation
- Investigation ordering from catalogue → specimen type/timing driven by investigation type → request validation
- The split-view pattern (consultation form + patient queue) is the standard clinical dashboard layout

**What was learned:**
- SvelteKit load functions provide the right boundary for stable reference data (catalogue) vs dynamic operational data (active orders)
- Per-item `availableSizes` driving UI toggles validates the catalogue-as-UI-contract pattern
- Inline signal dispatch from a dashboard card (rather than navigating to a detail page) is a significant UX improvement that should carry into the clinical system

---

## Relationship to Knowledge Layer Increments

Per the CSW Extension workstream plan §5:

> **KL Increment 2:** Decision table for drink/food routing — Counter page, routing logic based on catalogue properties. **Trigger:** When Phase 5 (Counter) is complete.

With Phase 5 complete, the Counter page becomes the landing zone for KL Increment 2. The decision table would determine preparation routing (e.g. hot bar vs cold bar vs food prep) based on catalogue properties (category, provision type, size). The tile selection UI would show the routing decision alongside the order confirmation.

This is not in scope for Phase 5 but is now unblocked.

---

*Plan prepared 13 March 2026. Phase 5 of the CSW Extension workstream.*
