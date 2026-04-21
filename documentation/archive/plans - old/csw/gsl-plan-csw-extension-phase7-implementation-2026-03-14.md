# CSW Extension Phase 7: Order Board & Order Timeline — Detailed Implementation Plan

**Workstream:** Coffee Shop Extension — Catalogue, Inventory & Frontend
**Phase:** 7 of 10
**Date:** 14 March 2026
**Session:** 26
**Prerequisites:** Phase 6 complete (Manager GUI — Stock & Catalogue, Session 25)
**Source plan:** `gsl-plan-workstream-csw-extension-2026-03-12.md` §Phase 7
**Estimated effort:** 5 stages across 2–3 commits

---

## Goal

The existing `/orders` page (Order Board) and `/orders/[id]` page (Order Detail) are functional but minimal — a flat Temporal workflow list table, and a basic state-and-signal card respectively. Phase 7 replaces both with rich operational views:

1. **Order Board** — Kanban columns by XState lifecycle state (Placed → In Preparation → Ready → Collected), with inline signal actions and a historical orders table below. The operational manager can see at a glance what is in progress, what needs attention, and what has been completed.

2. **Order Timeline** — Visual state machine progression, event timeline with timestamps, CDR record summary, and audit compliance inline. The detail view for a single order that brings together process state (Temporal), domain state (XState), clinical record (CDR), and governance data (audit) in one page.

This phase is **entirely frontend**. No new API routes are needed — all data comes from existing endpoints built in Phases 3 (catalogue/inventory), Phase A–D (orders lifecycle, audit, CDR entity queries), and Phase 5 (active orders).

---

## Architecture Overview

### API Surface (All Existing — No Backend Changes)

| Route | Method | Purpose | Built in |
|---|---|---|---|
| `/api/orders/active` | GET | Running workflows with XState lifecycle state | Phase 5 |
| `/api/orders/list` | GET | All workflows (up to 50) with Temporal status | Phase A |
| `/api/orders/[id]` | GET | Single workflow: XState state + Temporal status | Phase A |
| `/api/orders/[id]/signal` | POST | Send signal to advance lifecycle state | Phase A |
| `/api/orders/[id]/audit` | GET | Full audit trail with compliance assessment | Phase D |
| `/api/entity/orders` | GET | CDR entity view: all order compositions | Phase C |
| `/api/catalogue` | GET | Active catalogue entries (for item enrichment) | Phase 3 |

### New Architectural Requirement: Enriching Orders with Item Details

The Temporal workflow stores the drink name (e.g. "Flat White") as a string in `drinkType`. The CDR stores the drink name and size. Neither source carries the full catalogue data (category, dietary flags, provision type, price).

For the Order Board's kanban cards and the Order Timeline's item summary, we need to enrich the order data with catalogue context. Two approaches:

**Option A — Client-side join:** Fetch the catalogue once on the Order Board page load, and match by drink name. Simple, works for the demonstrator where all items have unique names.

**Option B — API enrichment:** Add an enriched active-orders endpoint that joins Temporal state with catalogue data server-side.

**Decision: Option A.** Client-side join is simpler, avoids a new API route, and the catalogue data is already available. The Counter page uses this same pattern (catalogue loaded once, referenced throughout). For the clinical system, server-side enrichment would be appropriate — but for the demonstrator, client-side join validates the "catalogue as context" pattern.

### Page Structure — Order Board (`/orders`)

```
/orders (+page.svelte)
┌─────────────────────────────────────────────────────────────────────┐
│  Page Header: "Order Board" + summary stats + view toggle           │
├─────────────────────────────────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────────┐  ┌─────────┐  ┌──────────────────┐│
│  │  Placed   │  │ In Prep.     │  │  Ready  │  │  Completed today ││
│  │           │  │              │  │         │  │                  ││
│  │  [card]   │  │  [card]      │  │  [card] │  │  [card]          ││
│  │  [card]   │  │  [card]      │  │         │  │  [card]          ││
│  │           │  │              │  │         │  │  [card]          ││
│  └──────────┘  └──────────────┘  └─────────┘  └──────────────────┘│
├─────────────────────────────────────────────────────────────────────┤
│  Historical Orders (below kanban, collapsed by default)             │
│  Flowbite Table with Temporal status, start/end time, links        │
└─────────────────────────────────────────────────────────────────────┘
```

### Page Structure — Order Timeline (`/orders/[id]`)

```
/orders/[id] (+page.svelte)
┌─────────────────────────────────────────────────────────────────────┐
│  Page Header: "Order #ABC-1234" + status badge + back links         │
├──────────────────────────────────┬──────────────────────────────────┤
│  State Machine Visual            │  Order Summary Card              │
│                                  │  - Item name, size, milk         │
│  ● Placed → ● In Prep →         │  - Price, category, provision    │
│    ● Ready → ○ Collected         │  - Customer name                 │
│                                  │  - Time elapsed                  │
│  [Next Action Button]            │  - CDR composition link          │
├──────────────────────────────────┴──────────────────────────────────┤
│  Event Timeline                                                     │
│  ┌ 14:23:01  Order placed by "Alice"                               │
│  ├ 14:23:01  Validate Order — 0.3s ✓                               │
│  ├ 14:25:17  Barista started preparation                           │
│  ├ 14:25:17  Prepare Drink — 0.2s ✓                                │
│  ├ 14:27:45  Drink ready                                           │
│  └ (waiting for collection)                                         │
├─────────────────────────────────────────────────────────────────────┤
│  Governance Note + Temporal Web UI link                             │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Stage 1: Order Board — Kanban View

### 1.1 Data loading strategy

The Order Board needs two data sources combined:

1. **Active orders with XState state** — `GET /api/orders/active` (returns running workflows with lifecycle state)
2. **All orders with Temporal status** — `GET /api/orders/list` (returns all workflows including completed/failed)
3. **Catalogue** — `GET /api/catalogue` (for item name → category/price/dietary enrichment)

Active orders provide the kanban cards (running workflows with their lifecycle state). The list endpoint provides completed/historical orders for the table below. The catalogue provides enrichment data.

```typescript
interface ActiveOrder {
  orderId: string;
  state: string;         // XState lifecycle state
  startTime: string | null;
}

interface WorkflowSummary {
  workflowId: string;
  caseRef: string;
  status: string;        // Temporal execution status
  startTime: string | null;
  closeTime: string | null;
}

let activeOrders = $state<ActiveOrder[]>([]);
let allWorkflows = $state<WorkflowSummary[]>([]);
let catalogue = $state<CatalogueItemView[]>([]);
let loading = $state(true);
let error = $state('');

async function fetchAll() {
  loading = true;
  error = '';
  try {
    const [activeRes, listRes, catRes] = await Promise.all([
      fetch('/api/orders/active'),
      fetch('/api/orders/list'),
      fetch('/api/catalogue'),
    ]);
    if (!activeRes.ok || !listRes.ok || !catRes.ok) {
      error = 'Failed to load order data';
      return;
    }
    const activeData = await activeRes.json();
    const listData = await listRes.json();
    activeOrders = activeData.orders;
    allWorkflows = listData.workflows;
    catalogue = await catRes.json();
  } catch (err) {
    error = err instanceof Error ? err.message : 'Failed to load data';
  } finally {
    loading = false;
  }
}

onMount(() => {
  fetchAll();
  // Poll active orders every 5 seconds for live updates
  const interval = setInterval(fetchAll, 5000);
  return () => clearInterval(interval);
});
```

### 1.2 Item enrichment helper

Extract the drink name from the workflow ID (the `POST /api/orders` embeds `drinkType` in the workflow args, but we don't have direct access to that from the list/active endpoints). The workflow ID is `order-{timestamp}` which doesn't carry item info.

**Problem:** Neither `/api/orders/active` nor `/api/orders/list` returns the drink name. The active endpoint only returns `orderId`, `state`, `startTime`. The list endpoint returns `workflowId`, `caseRef`, `status`, `startTime`, `closeTime`.

**Solution:** We need to query the individual order for its drink details, or accept that the kanban cards won't show item names from the Temporal data alone. For the demonstrator, we can:

1. Accept that kanban cards show the anonymised case ref and state, without item details — still operationally useful (the barista can see "3 orders waiting, 2 in preparation, 1 ready")
2. Or add a lightweight endpoint that extracts workflow input from Temporal

**Decision:** Option 1 for the initial kanban. The case ref + state + time elapsed is the primary operational information. Item details will be visible when clicking through to the Order Timeline (Stage 3), where the CDR entity query provides full order data. This mirrors the clinical pattern: the operational dashboard shows queue status, not clinical detail.

**Future enhancement note:** A `GET /api/orders/active-enriched` endpoint could query Temporal workflow inputs for drink details, or the order could be enriched from CDR entity data. This is a Phase 8 consideration.

### 1.3 Kanban columns

Define the kanban column configuration matching the XState lifecycle states:

```typescript
const KANBAN_COLUMNS: { key: string; label: string; icon: string; color: string; badgeColor: string }[] = [
  { key: 'placed',        label: 'Placed',         icon: '📝', color: 'border-blue-300 dark:border-blue-700',    badgeColor: 'blue' },
  { key: 'inPreparation', label: 'In Preparation',  icon: '☕', color: 'border-yellow-300 dark:border-yellow-700', badgeColor: 'yellow' },
  { key: 'ready',         label: 'Ready',           icon: '✅', color: 'border-green-300 dark:border-green-700',   badgeColor: 'green' },
];

// Derived: group active orders by state
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
```

Collected and cancelled orders don't appear in kanban columns — they appear in the historical table below. The kanban is a live operational view of in-progress work.

### 1.4 Kanban card component

Each card within a column represents one active order:

```svelte
<!-- Inline within the page — one card per active order -->
{#each ordersByState[col.key] as order}
  <div class="mb-2 rounded-lg border border-secondary-200 bg-white p-3 shadow-sm dark:border-secondary-700 dark:bg-secondary-800">
    <!-- Case ref and time -->
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
      <Badge color={STATE_COLORS[order.state]} small>{STATE_LABELS[order.state]}</Badge>
    </div>

    <!-- Action button (inline) -->
    {#if STATE_ACTIONS[order.state]}
      <Button
        size="xs"
        color="primary"
        outline
        onclick={() => sendSignal(order.orderId, STATE_ACTIONS[order.state]!.signal)}
        disabled={sendingSignal === order.orderId}
      >
        {sendingSignal === order.orderId ? 'Sending…' : STATE_ACTIONS[order.state]!.label}
      </Button>
    {/if}

    <!-- Detail link -->
    <a href="/orders/{order.orderId}" class="mt-2 block text-xs text-primary-600 hover:underline dark:text-primary-400">
      View details →
    </a>
  </div>
{/each}
```

### 1.5 Time elapsed helper

```typescript
function timeElapsed(startTime: string | null): string {
  if (!startTime) return '';
  const start = new Date(startTime).getTime();
  const now = Date.now();
  const diffMs = now - start;
  const diffMins = Math.floor(diffMs / 60000);
  if (diffMins < 1) return 'just now';
  if (diffMins < 60) return `${diffMins}m ago`;
  const diffHours = Math.floor(diffMins / 60);
  return `${diffHours}h ${diffMins % 60}m ago`;
}
```

### 1.6 Inline signal actions from kanban cards

Reuse the signal pattern from the Counter page's active orders panel. Each card with a valid next action shows a button. Clicking sends the signal and triggers a refresh:

```typescript
let sendingSignal = $state<string | null>(null);

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
      error = data.message || `Signal failed: ${response.status}`;
      return;
    }
    // Refresh active orders after signal
    await fetchAll();
  } catch (err) {
    error = err instanceof Error ? err.message : 'Failed to send signal';
  } finally {
    sendingSignal = null;
  }
}
```

### 1.7 Summary statistics

Above the kanban columns, show a summary bar:

```svelte
<div class="mb-4 flex flex-wrap gap-4 text-sm text-secondary-600 dark:text-secondary-400">
  <span>{activeOrders.length} active order{activeOrders.length !== 1 ? 's' : ''}</span>
  <span class="text-secondary-300 dark:text-secondary-600">|</span>
  <span>{ordersByState['placed']?.length ?? 0} waiting</span>
  <span>{ordersByState['inPreparation']?.length ?? 0} in preparation</span>
  <span>{ordersByState['ready']?.length ?? 0} ready for collection</span>
</div>
```

### 1.8 Kanban column layout

```svelte
<div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
  {#each KANBAN_COLUMNS as col}
    <div class="rounded-lg border-t-4 {col.color} bg-secondary-50 p-3 dark:bg-secondary-800/50">
      <!-- Column header -->
      <div class="mb-3 flex items-center justify-between">
        <h3 class="text-sm font-semibold text-secondary-700 dark:text-secondary-300">
          {col.icon} {col.label}
        </h3>
        <Badge color={col.badgeColor} small>{ordersByState[col.key]?.length ?? 0}</Badge>
      </div>

      <!-- Cards -->
      {#if (ordersByState[col.key]?.length ?? 0) === 0}
        <p class="py-4 text-center text-xs text-secondary-400 dark:text-secondary-500 italic">
          No orders
        </p>
      {:else}
        {#each ordersByState[col.key] as order}
          <!-- card as above -->
        {/each}
      {/if}
    </div>
  {/each}
</div>
```

### 1.9 Verification

1. Page loads and shows kanban columns for Placed, In Preparation, Ready
2. Active orders appear in correct columns based on their XState state
3. Inline action buttons work — clicking "Start Prep" moves card from Placed to In Preparation
4. Summary statistics update after signals
5. Time elapsed shows correctly and updates on poll
6. Empty columns show "No orders" placeholder
7. Detail links navigate to `/orders/[id]`
8. Dark mode renders correctly for all column and card styles
9. Mobile layout: columns stack vertically

### 1.10 Commit point

Combined with Stage 2 for a meaningful commit.

---

## Stage 2: Order Board — Historical Orders Table

### 2.1 Historical orders

Below the kanban, show a collapsible section with completed and historical orders. This replaces the existing full-table view but retains the information.

```typescript
let completedWorkflows = $derived(
  allWorkflows.filter(wf =>
    wf.status === 'COMPLETED' || wf.status === 'FAILED' ||
    wf.status === 'CANCELLED' || wf.status === 'TERMINATED'
  )
);

let showHistory = $state(false);
```

### 2.2 History section

```svelte
<div class="mt-8">
  <button
    class="flex items-center gap-2 text-sm font-semibold text-secondary-600 hover:text-secondary-800 dark:text-secondary-400 dark:hover:text-secondary-200"
    onclick={() => showHistory = !showHistory}
  >
    {showHistory ? '▼' : '▶'} Completed Orders
    <Badge color="dark" small>{completedWorkflows.length}</Badge>
  </button>

  {#if showHistory}
    <div class="mt-3">
      {#if completedWorkflows.length === 0}
        <p class="text-sm text-secondary-400 italic">No completed orders yet.</p>
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
                  <Badge color={TEMPORAL_STATUS_COLORS[wf.status] ?? 'dark'} small>
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
```

### 2.3 Temporal status configuration (separate from XState lifecycle)

The Order Board uses two different status vocabularies: XState lifecycle states for the kanban (operational), and Temporal execution statuses for the history table (process). These are distinct:

```typescript
const TEMPORAL_STATUS_LABELS: Record<string, string> = {
  RUNNING:    'Running',
  COMPLETED:  'Completed',
  FAILED:     'Failed',
  CANCELLED:  'Cancelled',
  TERMINATED: 'Terminated',
  TIMED_OUT:  'Timed out',
};

const TEMPORAL_STATUS_COLORS: Record<string, string> = {
  RUNNING:    'green',
  COMPLETED:  'blue',
  FAILED:     'red',
  CANCELLED:  'dark',
  TERMINATED: 'red',
  TIMED_OUT:  'yellow',
};
```

### 2.4 Anonymise case ref (client-side)

Import `anonymiseCaseRef` from `@coffeeshop/shared`. Note the Temporal sandbox issue from Session 24 — the import needs to come from the specific module, not the barrel export. However, since this is a SvelteKit page (not Temporal worker code), the barrel export is safe to use.

```typescript
import { anonymiseCaseRef, type CatalogueItemView } from '@coffeeshop/shared';
```

### 2.5 Page header and navigation

```svelte
<div class="mb-6">
  <h1 class="text-2xl font-bold text-secondary-800 dark:text-white">Order Board</h1>
  <p class="text-sm text-secondary-500 dark:text-secondary-400">
    Live operational view.
    <a href="/" class="text-primary-600 hover:underline dark:text-primary-400">Place a new order</a>
  </p>
</div>
```

### 2.6 Verification

1. Kanban columns show active orders (from Stage 1)
2. "Completed Orders" section is collapsed by default
3. Clicking the toggle expands the historical table
4. Completed orders show COMPLETED badge in blue
5. Failed/Cancelled orders show appropriate badges
6. "Details" and "Audit" links work correctly
7. Page auto-refreshes kanban via polling, history table refreshes on each poll
8. Responsive layout: timestamps hidden on mobile
9. The `anonymiseCaseRef` function produces consistent case refs

### 2.7 Commit point

```bash
git add -A && git commit -m "CSW frontend: Order Board kanban view with inline actions and historical orders"
```

---

## Stage 3: Order Timeline — State Machine Visual and Event Timeline

### 3.1 Page data loading

The Order Timeline page replaces the existing `/orders/[id]/+page.svelte`. It needs three data sources:

1. **Order state** — `GET /api/orders/[id]` (XState state + Temporal status)
2. **Audit trail** — `GET /api/orders/[id]/audit` (step-by-step timeline with compliance)
3. **CDR entity data** — `GET /api/entity/orders` (to find the matching CDR composition for this order's drink details)

The audit endpoint provides the richest data — it includes step-by-step timing, compliance assessment, and workflow start/end times. For running orders, it provides partial data (completed steps have timing; pending steps don't).

```typescript
interface OrderState {
  orderId: string;
  state: string;
  workflowStatus: string;
}

interface AuditStep {
  stepId: string;
  label: string;
  type: 'activity' | 'signal';
  expectedMinutes: number | null;
  startTime: string | null;
  endTime: string | null;
  durationSeconds: number | null;
  durationMinutes: number | null;
  compliance: 'within_target' | 'exceeded' | 'no_target' | 'pending';
}

interface AuditReport {
  caseRef: string;
  workflowId: string;
  workflowStatus: string;
  startTime: string | null;
  endTime: string | null;
  steps: AuditStep[];
}

let orderId = $derived(page.params.id ?? '');
let orderState = $state<OrderState | null>(null);
let auditReport = $state<AuditReport | null>(null);
let auditError = $state(false);
let loading = $state(true);

async function fetchOrderData() {
  if (!orderId) return;
  try {
    const [stateRes, auditRes] = await Promise.all([
      fetch(`/api/orders/${orderId}`),
      fetch(`/api/orders/${orderId}/audit`).catch(() => null),
    ]);

    if (stateRes.ok) {
      orderState = await stateRes.json();
    }

    if (auditRes && auditRes.ok) {
      auditReport = await auditRes.json();
    } else {
      auditError = true;
    }
  } catch (err) {
    // Handle gracefully — order state is primary, audit is supplementary
  } finally {
    loading = false;
  }
}
```

Polling: if the order is still running, poll every 3 seconds for state updates.

### 3.2 State machine visual

A horizontal progress indicator showing the lifecycle states. The current state is highlighted; completed states are filled; future states are outlined:

```typescript
const LIFECYCLE_STEPS = [
  { key: 'placed',        label: 'Placed',        icon: '📝' },
  { key: 'inPreparation', label: 'In Preparation', icon: '☕' },
  { key: 'ready',         label: 'Ready',          icon: '✅' },
  { key: 'collected',     label: 'Collected',      icon: '🎉' },
];

const STATE_ORDER: Record<string, number> = {
  placed: 0,
  inPreparation: 1,
  ready: 2,
  collected: 3,
  cancelled: -1,
};

let currentStateIndex = $derived(STATE_ORDER[orderState?.state ?? 'placed'] ?? 0);
let isCancelled = $derived(orderState?.state === 'cancelled');
```

```svelte
<!-- State machine progression -->
<div class="mb-6 flex items-center justify-between gap-2">
  {#each LIFECYCLE_STEPS as step, i}
    {@const isCompleted = !isCancelled && i < currentStateIndex}
    {@const isCurrent = !isCancelled && i === currentStateIndex}
    {@const isFuture = !isCancelled && i > currentStateIndex}

    <!-- Step node -->
    <div class="flex flex-col items-center gap-1">
      <div class="flex h-10 w-10 items-center justify-center rounded-full text-lg
        {isCompleted ? 'bg-green-500 text-white' : ''}
        {isCurrent ? 'bg-primary-500 text-white ring-4 ring-primary-200 dark:ring-primary-800' : ''}
        {isFuture ? 'bg-secondary-200 text-secondary-400 dark:bg-secondary-700 dark:text-secondary-500' : ''}"
      >
        {isCompleted ? '✓' : step.icon}
      </div>
      <span class="text-xs font-medium
        {isCurrent ? 'text-primary-700 dark:text-primary-300' : 'text-secondary-500 dark:text-secondary-400'}">
        {step.label}
      </span>
    </div>

    <!-- Connector line (between steps) -->
    {#if i < LIFECYCLE_STEPS.length - 1}
      <div class="h-0.5 flex-1
        {i < currentStateIndex ? 'bg-green-500' : 'bg-secondary-200 dark:bg-secondary-700'}">
      </div>
    {/if}
  {/each}
</div>

{#if isCancelled}
  <Alert color="red" class="mb-4">
    This order was cancelled.
  </Alert>
{/if}
```

### 3.3 Order summary card

A split-view layout: state machine visual and action button on the left, order summary on the right.

```svelte
<div class="mb-6 flex flex-col gap-6 lg:flex-row">
  <!-- Left: state machine + action -->
  <div class="flex-1 min-w-0">
    <!-- State machine visual (from 3.2) -->
    <!-- ... -->

    <!-- Next action button -->
    {#if action}
      <Button color="primary" onclick={() => action && handleSignal(action.signal)} disabled={signalSending}>
        {signalSending ? 'Sending…' : action.label}
      </Button>
    {:else if isTerminal}
      <p class="text-sm text-secondary-500 dark:text-secondary-400">
        Order complete. No further actions available.
      </p>
    {/if}
  </div>

  <!-- Right: order summary card -->
  <div class="w-full lg:w-80 shrink-0">
    <div class="rounded-lg border border-secondary-200 bg-white p-4 dark:border-secondary-700 dark:bg-secondary-800">
      <h3 class="mb-3 text-sm font-semibold text-secondary-600 dark:text-secondary-400">Order Summary</h3>
      <div class="space-y-2 text-sm">
        <div class="flex justify-between">
          <span class="text-secondary-500 dark:text-secondary-400">Case Ref</span>
          <code class="text-xs">{auditReport?.caseRef ?? anonymiseCaseRef(orderId)}</code>
        </div>
        <div class="flex justify-between">
          <span class="text-secondary-500 dark:text-secondary-400">Status</span>
          <Badge color={stateColor}>{stateLabel}</Badge>
        </div>
        <div class="flex justify-between">
          <span class="text-secondary-500 dark:text-secondary-400">Started</span>
          <span class="text-xs">{formatTimestamp(auditReport?.startTime ?? null)}</span>
        </div>
        {#if auditReport?.endTime}
          <div class="flex justify-between">
            <span class="text-secondary-500 dark:text-secondary-400">Completed</span>
            <span class="text-xs">{formatTimestamp(auditReport.endTime)}</span>
          </div>
        {:else}
          <div class="flex justify-between">
            <span class="text-secondary-500 dark:text-secondary-400">Elapsed</span>
            <span class="text-xs">{timeElapsed(auditReport?.startTime ?? null)}</span>
          </div>
        {/if}
        <div class="flex justify-between">
          <span class="text-secondary-500 dark:text-secondary-400">Workflow</span>
          <span class="text-xs">{orderState?.workflowStatus ?? '—'}</span>
        </div>
      </div>
    </div>
  </div>
</div>
```

### 3.4 Event timeline

The audit trail's `steps` array provides the timeline data. Render as a vertical timeline with connector lines:

```svelte
{#if auditReport}
  <div class="mb-6">
    <h2 class="mb-4 text-lg font-semibold text-secondary-800 dark:text-white">Event Timeline</h2>

    <div class="relative ml-4 border-l-2 border-secondary-200 pl-6 dark:border-secondary-700">
      {#each auditReport.steps as step, i}
        {@const isComplete = step.startTime && step.endTime}
        {@const isActive = step.startTime && !step.endTime}
        {@const isPending = !step.startTime}

        <div class="relative mb-6">
          <!-- Timeline dot -->
          <div class="absolute -left-[31px] top-0.5 h-4 w-4 rounded-full border-2
            {isComplete ? 'border-green-500 bg-green-500' : ''}
            {isActive ? 'border-primary-500 bg-primary-500 animate-pulse' : ''}
            {isPending ? 'border-secondary-300 bg-white dark:border-secondary-600 dark:bg-secondary-800' : ''}">
          </div>

          <!-- Step content -->
          <div class="flex flex-col gap-1">
            <div class="flex items-center gap-2">
              <span class="font-medium text-secondary-800 dark:text-white">{step.label}</span>
              <Badge color={step.type === 'signal' ? 'blue' : 'dark'} small>
                {step.type === 'signal' ? 'Wait' : 'Activity'}
              </Badge>
              {#if isComplete}
                {@const compCfg = COMPLIANCE_CONFIG[step.compliance]}
                <Badge color={compCfg?.color ?? 'dark'} small>{compCfg?.label ?? step.compliance}</Badge>
              {/if}
            </div>

            <div class="text-xs text-secondary-500 dark:text-secondary-400">
              {#if isComplete}
                {formatTimestamp(step.startTime)} → {formatTimestamp(step.endTime)}
                · {formatDuration(step.durationSeconds)}
                {#if step.expectedMinutes !== null}
                  <span class="text-secondary-400">(target: {formatExpected(step.expectedMinutes)})</span>
                {/if}
              {:else if isActive}
                Started {formatTimestamp(step.startTime)} — <span class="italic">in progress</span>
              {:else}
                <span class="italic">Pending</span>
              {/if}
            </div>
          </div>
        </div>
      {/each}
    </div>
  </div>
{:else if auditError}
  <Alert color="yellow" class="mb-4">
    Audit data is not available for this workflow. The timeline will appear once the order has history events.
  </Alert>
{/if}
```

### 3.5 Compliance configuration (reused from audit page)

```typescript
const COMPLIANCE_CONFIG: Record<string, { label: string; color: string }> = {
  within_target: { label: '✓ On time',  color: 'green' },
  exceeded:      { label: '⚠ Exceeded', color: 'yellow' },
  no_target:     { label: '—',          color: 'dark' },
  pending:       { label: '…',          color: 'blue' },
};
```

### 3.6 Utility functions

```typescript
function formatTimestamp(iso: string | null): string {
  if (!iso) return '—';
  return new Date(iso).toLocaleTimeString();
}

function formatDuration(seconds: number | null): string {
  if (seconds === null) return '—';
  if (seconds < 60) return `${seconds}s`;
  const mins = Math.floor(seconds / 60);
  const secs = seconds % 60;
  return secs > 0 ? `${mins}m ${secs}s` : `${mins}m`;
}

function formatExpected(minutes: number | null): string {
  if (minutes === null) return '—';
  if (minutes < 1) return `${Math.round(minutes * 60)}s`;
  return `${minutes}m`;
}

function timeElapsed(startTime: string | null): string {
  if (!startTime) return '—';
  const diffMs = Date.now() - new Date(startTime).getTime();
  const mins = Math.floor(diffMs / 60000);
  if (mins < 1) return 'just now';
  if (mins < 60) return `${mins}m`;
  return `${Math.floor(mins / 60)}h ${mins % 60}m`;
}
```

### 3.7 Verification

1. State machine shows correct progression for a running order (e.g. "placed" → active dot on first step)
2. Completed steps show green checkmarks
3. Future steps show as outlined/dimmed
4. Action button appears for the correct next action
5. Event timeline shows completed steps with timestamps and compliance badges
6. Active step shows pulsing dot and "in progress" text
7. Pending steps show "Pending"
8. Cancelled orders show cancellation alert and no action button
9. Completed orders show all steps with timing data
10. Dark mode renders correctly

### 3.8 Commit point

Combined with Stage 4 for a meaningful commit.

---

## Stage 4: Order Timeline — Audit Integration and CDR Link

### 4.1 Governance note

Below the event timeline, show the governance note linking to the process model and Temporal:

```svelte
<div class="rounded-lg border border-secondary-200 bg-secondary-50 p-4 text-sm dark:border-secondary-700 dark:bg-secondary-800/50">
  <p class="mb-2 text-secondary-600 dark:text-secondary-400">
    <strong>Governance:</strong> This order follows the
    <a href="/pathway" class="text-primary-600 hover:underline dark:text-primary-400">FulfilDrink process model</a>,
    generated from the SysML v2 model. Timing targets from model annotations.
  </p>
  {#if auditReport?.workflowStatus === 'COMPLETED'}
    <p class="text-secondary-600 dark:text-secondary-400">
      <a href="/orders/{orderId}/audit" class="text-primary-600 hover:underline dark:text-primary-400">
        View full compliance audit report →
      </a>
    </p>
  {/if}
  <p class="mt-2 text-xs text-secondary-400">
    <a href="http://localhost:8233/namespaces/default/workflows/{orderId}" target="_blank" class="hover:underline">
      Temporal Web UI →
    </a>
  </p>
</div>
```

### 4.2 CDR composition link

For completed orders, the CDR entity data can be cross-referenced. The `GET /api/entity/orders` endpoint returns all order compositions with their EHR IDs and composition UIDs. We can link to the Records page or display the composition UID for audit trail completeness.

However, matching a Temporal workflow ID to a CDR composition is not currently straightforward — the composition doesn't store the workflow ID, and the workflow doesn't store the composition UID. This is a known architectural gap (the CDR and Temporal are loosely coupled by time and content, not by ID).

**Decision for Phase 7:** Show a link to the Records page rather than attempting a cross-reference. Add a note that CDR records are available in the entity view. The CDR ↔ Temporal correlation is a Phase 10 consideration.

```svelte
<p class="mt-2 text-secondary-500 dark:text-secondary-400 text-xs">
  CDR records for this order type are available in
  <a href="/entity" class="text-primary-600 hover:underline dark:text-primary-400">Records</a>.
</p>
```

### 4.3 Navigation

```svelte
<div class="mb-4">
  <h1 class="text-2xl font-bold text-secondary-800 dark:text-white">
    Order {auditReport?.caseRef ?? anonymiseCaseRef(orderId)}
  </h1>
  <div class="flex gap-3 text-sm">
    <a href="/orders" class="text-primary-600 hover:underline dark:text-primary-400">&larr; Order Board</a>
    <a href="/" class="text-primary-600 hover:underline dark:text-primary-400">Counter</a>
    {#if auditReport?.workflowStatus === 'COMPLETED'}
      <a href="/orders/{orderId}/audit" class="text-primary-600 hover:underline dark:text-primary-400">Full Audit</a>
    {/if}
  </div>
</div>
```

### 4.4 Verification

1. Governance note appears below the timeline
2. Link to process model (pathway page) works
3. Link to full audit report appears only for completed orders
4. Temporal Web UI link opens correctly
5. CDR records link navigates to Records page
6. All links work in both light and dark mode

### 4.5 Commit point

```bash
git add -A && git commit -m "CSW frontend: Order Timeline with state machine visual, event timeline, and audit integration"
```

---

## Stage 5: Polish, Integration Testing & Audit Page Navigation

### 5.1 Audit page back-navigation update

The existing `/orders/[id]/audit/+page.svelte` has a back link to "Order status". Update it to say "Order Timeline" for consistency with the new page naming.

### 5.2 Sidebar active state refinement

The sidebar currently highlights "Order Board" for any `/orders/*` path. This is correct — both the board and the detail/audit pages fall under the Orders section.

### 5.3 Cross-page integration test

Complete end-to-end scenario:

1. **Place an order** from the Counter page → order appears in Order Board's "Placed" column
2. **Click "Start Prep"** from the kanban card → card moves to "In Preparation" column
3. **Click "View details"** → navigate to Order Timeline page
4. **Verify state machine** shows "In Preparation" as the active step, "Placed" as completed
5. **Verify event timeline** shows "Validate Order" and "Wait for Barista" as completed steps, "Prepare Drink" as active
6. **Click "Mark Ready"** from the Timeline page → state machine advances, timeline updates
7. **Navigate back to Order Board** → card is now in "Ready" column
8. **Click "Collect"** from the kanban card → card disappears from kanban (order is now completed)
9. **Expand "Completed Orders"** → order appears in the history table with "Completed" badge
10. **Click "Details"** → Order Timeline shows all steps completed with green checkmarks
11. **Click "Full Audit"** → Audit Report page shows compliance table
12. **Verify Counter page** active orders panel also reflects the state changes

### 5.4 Edge cases

- **No active orders:** Kanban shows empty columns with "No orders" text
- **No completed orders:** History section shows "No completed orders yet"
- **Failed workflow:** History table shows red "Failed" badge; detail page shows appropriate state
- **Multiple orders simultaneously:** Multiple cards in different columns; each responds to its own signal
- **Page reload during active order:** State is correctly restored from Temporal queries

### 5.5 Dark mode verification

All new components:
- Kanban column backgrounds and borders
- Card backgrounds and hover states
- State machine node colours
- Timeline connector line and dots
- Badge colours in all contexts
- History table row striping
- Governance note panel

### 5.6 Mobile responsiveness

- Kanban columns: stack vertically on mobile (`grid-cols-1`)
- State machine visual: wraps gracefully on narrow screens
- Summary card: stacks below state machine on mobile
- Timeline: full width, no horizontal scrolling
- History table: timestamp columns hidden on mobile

### 5.7 Commit point

```bash
git add -A && git commit -m "CSW frontend: Order Board and Order Timeline polish, integration verified"
```

---

## Files Created / Modified

### Modified files

| File | Change |
|---|---|
| `src/routes/orders/+page.svelte` | **Rewritten** — kanban board replacing flat table |
| `src/routes/orders/[id]/+page.svelte` | **Rewritten** — Order Timeline replacing basic status card |
| `src/routes/orders/[id]/audit/+page.svelte` | **Minor** — back-navigation text update |

### Unchanged

All API routes, all `$lib/server/` modules, all `packages/shared/` and `packages/temporal/` code, the Counter page, the Manager GUI, the layout, `app.css`, and all other pages.

This phase is entirely frontend — no backend changes, no new API routes, no package changes.

---

## Risks and Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| **Audit endpoint returns error for running workflows** | Medium | The audit endpoint parses Temporal event history. For very new workflows (< 1s old), events may be sparse. Fetch audit data with a try/catch and show "Audit data not yet available" gracefully. The order state endpoint is the primary data source; audit is supplementary. |
| **Kanban polling load** | Low | 5-second poll interval for active orders is acceptable for the demonstrator. Each poll is 3 parallel fetches (active, list, catalogue). For production, SSE or WebSocket would replace polling. |
| **XState state "unknown" appearing in kanban** | Low | The active orders endpoint queries Temporal for each running workflow's XState state. Very new workflows may return "unknown" before the query handler registers. Exclude "unknown" state orders from kanban columns; they'll appear on the next poll. |
| **Anonymised case ref collision** | Very low | The `anonymiseCaseRef` hash function produces 4-hex-digit references. With < 50 orders in the demonstrator, collision is extremely unlikely. Not a concern for the demonstrator; production would use a proper sequence. |
| **Flowbite component interactions** | Low | This phase uses Flowbite components that are already proven (Table, Badge, Button, Alert). No new component patterns — lower risk than Phase 6. |

---

## What This Phase Does Not Do

- Does not add new API routes or backend logic (all endpoints exist)
- Does not enrich kanban cards with item details (drink name, size) — this requires either a new API endpoint or CDR cross-reference. Deferred as a Phase 8 or post-workstream enhancement
- Does not implement real-time updates (SSE/WebSocket) — polling is adequate for the demonstrator
- Does not correlate Temporal workflow IDs with CDR composition UIDs — a known architectural gap noted for Phase 10
- Does not implement cancellation from the UI (the "CancellationRequested" event exists in the state machine but no UI trigger has been built)
- Does not modify the SysML model (Phase 10)
- Does not implement Knowledge Layer Increment 1 (constraint evaluation at pathway step) — this phase creates the landing zone for it on the Order Timeline page

---

## Coffee Shop Demonstrator Extension

**Capability demonstrated:** Operational process monitoring — the manager can see the live state of all in-progress orders via a kanban board, advance order states via inline actions, drill into individual orders for a detailed timeline with compliance assessment, and review historical orders. The process state (Temporal), domain state (XState), and governance data (audit with model-derived timing targets) are unified in a single view.

**Clinical implementation confidence:** High. The patterns map directly to:
- **Clinical pathway dashboard:** Kanban columns for pathway stages (Referral → Assessment → Initiation → Monitoring → Stable). Each card represents a patient's pathway instance. Inline actions advance the pathway (e.g. "Complete Assessment", "Start Treatment").
- **Patient timeline:** State machine visual showing pathway progression. Event timeline with clinical audit steps (blood test ordered → results received → clinical review → prescription issued). Compliance against NICE guideline timings.
- **The governance integration** — timing targets from the SysML model appearing as compliance badges in the timeline — directly demonstrates how model-derived clinical governance rules surface in the operational view.

**What will be learned:**
- Whether the kanban pattern works for operational queue management without item-level detail on the cards
- Whether the audit endpoint's data is rich enough for the timeline view (or whether a dedicated timeline endpoint is needed)
- How the state machine visual + event timeline combination works in practice for conveying process state
- Whether polling at 5-second intervals provides an adequate live-update experience

---

## Relationship to Knowledge Layer Increments

Per the CSW Extension workstream plan §5:

> **KL Increment 1:** Constraint evaluation at a pathway step → Order Timeline page — evaluation result appears inline. **Trigger:** When Phase 7 (Order Timeline) is complete.

With Phase 7 complete, the Order Timeline page becomes the landing zone for Increment 1. The timeline's step-by-step view is the natural location for constraint evaluation results: "At step 'Prepare Drink', constraint 'Temperature must be 65–70°C' was evaluated: PASS." The timeline already shows compliance badges from the audit data; adding constraint evaluation results would extend this pattern.

---

*Plan prepared 14 March 2026. Phase 7 of the CSW Extension workstream.*
