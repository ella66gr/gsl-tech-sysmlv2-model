# CSW Extension Phase 9: System Pages — Detailed Implementation Plan

**Workstream:** Coffee Shop Extension — Catalogue, Inventory & Frontend
**Phase:** 9 of 10
**Date:** 14 March 2026
**Session:** 28
**Prerequisites:** Phase 8 complete (Data & Insights pages, Session 27)
**Source plan:** `gsl-plan-csw-extension-workstream-2026-03-12.md` §Phase 9
**Estimated effort:** 5 stages across 2–3 commits

---

## Goal

Phase 9 completes the frontend build of the CSW Extension workstream. The two pages under "System" in the sidebar — Process Model (`/pathway`) and System Status (`/system`) — are the least developed in the application. The Process Model page shows the generated SVG and a static orchestration step table but has no interactivity or connection to live system state. The System Status page is a placeholder card.

Phase 9 transforms these into the system-awareness layer of the application:

- **Process Model** becomes an interactive pathway view: the generated SVG is augmented with step highlighting based on active orders, clickable steps that open metadata modals showing the two-layer model relationship (domain action ↔ orchestration workflow), and SysML source annotations.
- **System Status** becomes a live operational dashboard: real infrastructure health checks (Temporal, EHRbase, PostgreSQL), structural inventory from the generated types and catalogue, operational metrics (orders today, active orders, preparation completion rate), and a placeholder self-assessment panel that serves as the landing zone for Knowledge Layer Increment 3.

This phase introduces **two new API routes** for infrastructure health and operational metrics. All other data comes from existing endpoints.

---

## Architecture Overview

### New API Routes

| Route | Method | Purpose |
|---|---|---|
| `/api/system/health` | GET | Infrastructure health — ping Temporal, EHRbase, PostgreSQL |
| `/api/system/metrics` | GET | Operational metrics — order counts, active orders, catalogue stats |

### Existing API Routes Consumed

| Route | Method | Purpose | Used by |
|---|---|---|---|
| `/api/orders/active` | GET | Active orders with XState lifecycle state | Process Model (step highlighting) |
| `/api/catalogue` | GET | Active catalogue entries | System Status (catalogue stats) |
| `/api/catalogue?all=true` | GET | All catalogue entries including discontinued | System Status (full inventory) |
| `/api/inventory` | GET | Inventory records | System Status (stock alerts) |
| `/api/entity/orders` | GET | All orders from CDR | System Status (order metrics) |
| `/api/entity/orders/today` | GET | Today's orders from CDR | System Status (daily metrics) |
| `/api/entity/governance` | GET | Governance audit | System Status (compliance summary) |

### Design Principles for Phase 9

1. **Live infrastructure awareness.** The navbar already shows green dots for Temporal, EHRbase, and PostgreSQL — but these are static placeholders. Phase 9 makes them real by pinging each service and reporting actual status. The System Status page shows detailed health, while the navbar indicators become live.

2. **Two-layer model visualisation.** The Process Model page should make the domain/orchestration distinction visible — this is a core architectural concept. Each pathway step maps to both a domain action (what the barista does) and an orchestration step (what the system manages). Clicking a step reveals both layers.

3. **Operational self-awareness.** The System Status page sketches what the clinical platform's self-knowledge dashboard will look like: "How many patients are in active pathways? What is the completion rate for monitoring milestones? Are all infrastructure services healthy?" The coffee shop equivalent: "How many orders are active? What is the preparation completion rate? Are all services connected?"

4. **Landing zone for KL Increment 3.** The System Status page includes a placeholder self-assessment panel that will later be populated by the five-layer self-knowledge architecture (ConstraintEvaluator → OperationalStateAggregator → GoalProjector → GapAnalyser → RemediationPlanner).

5. **No changes to existing pages.** All work is confined to the two System pages plus two new API routes plus the navbar health indicators.

---

## Stage 1: Health Check API Route

### 1.1 Design

Create `GET /api/system/health` that pings all three infrastructure services and returns their status:

```typescript
interface ServiceHealth {
  service: string;
  status: 'healthy' | 'degraded' | 'unavailable';
  responseTimeMs: number;
  detail?: string;
}

interface HealthResponse {
  overall: 'healthy' | 'degraded' | 'unavailable';
  services: ServiceHealth[];
  checkedAt: string;
}
```

**EHRbase:** `GET /ehrbase/status` — returns 200 if the CDR is operational.

**PostgreSQL:** Execute `SELECT 1` on the business database connection.

**Temporal:** List workflows with a limit of 1 — if the connection works, Temporal is reachable. The existing `getTemporalClient()` from `$lib/server/temporal.ts` handles connection.

### 1.2 Implementation

Create `src/routes/api/system/health/+server.ts`:

```typescript
import { json } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { getEhrbaseClient } from '$lib/server/ehrbase';
import { getPostgresClient } from '$lib/server/postgres';
import { getTemporalClient } from '$lib/server/temporal';

interface ServiceHealth {
  service: string;
  status: 'healthy' | 'degraded' | 'unavailable';
  responseTimeMs: number;
  detail?: string;
}

async function checkEhrbase(): Promise<ServiceHealth> {
  const start = Date.now();
  try {
    const client = getEhrbaseClient();
    const response = await fetch(`${client.baseUrl}/ehrbase/status`);
    const ms = Date.now() - start;
    if (response.ok) {
      return { service: 'EHRbase', status: 'healthy', responseTimeMs: ms };
    }
    return { service: 'EHRbase', status: 'degraded', responseTimeMs: ms, detail: `HTTP ${response.status}` };
  } catch (err) {
    return { service: 'EHRbase', status: 'unavailable', responseTimeMs: Date.now() - start, detail: err instanceof Error ? err.message : 'Connection failed' };
  }
}

async function checkPostgres(): Promise<ServiceHealth> {
  const start = Date.now();
  try {
    const db = getPostgresClient();
    await db.query('SELECT 1');
    return { service: 'PostgreSQL', status: 'healthy', responseTimeMs: Date.now() - start };
  } catch (err) {
    return { service: 'PostgreSQL', status: 'unavailable', responseTimeMs: Date.now() - start, detail: err instanceof Error ? err.message : 'Connection failed' };
  }
}

async function checkTemporal(): Promise<ServiceHealth> {
  const start = Date.now();
  try {
    const client = await getTemporalClient();
    // Attempt a minimal list operation to verify connectivity
    const iterator = client.workflow.list({ query: "ExecutionStatus = 'Running'", pageSize: 1 });
    // Consume just the first page to verify the connection works
    await iterator[Symbol.asyncIterator]().next();
    return { service: 'Temporal', status: 'healthy', responseTimeMs: Date.now() - start };
  } catch (err) {
    return { service: 'Temporal', status: 'unavailable', responseTimeMs: Date.now() - start, detail: err instanceof Error ? err.message : 'Connection failed' };
  }
}

export const GET: RequestHandler = async () => {
  const services = await Promise.all([
    checkEhrbase(),
    checkPostgres(),
    checkTemporal(),
  ]);

  const overall = services.every(s => s.status === 'healthy')
    ? 'healthy'
    : services.some(s => s.status === 'unavailable')
      ? 'unavailable'
      : 'degraded';

  return json({
    overall,
    services,
    checkedAt: new Date().toISOString(),
  });
};
```

### 1.3 EHRbase client `baseUrl` access

The `checkEhrbase()` function needs to reach the EHRbase status endpoint. The `EhrbaseClient` from `@coffeeshop/shared` may not expose `baseUrl` directly. Check the client interface and, if needed, use the known URL (`http://localhost:8080`) or add a `getBaseUrl()` method. If `baseUrl` isn't exposed, hardcode the known dev URL with a TODO for configuration.

**Fallback approach:** If the EHRbase client doesn't expose a raw fetch-compatible URL, use the client's own query mechanism — execute a simple AQL like `SELECT e/ehr_id/value FROM EHR e LIMIT 1`. If it succeeds, EHRbase is healthy.

### 1.4 PostgreSQL `query` access

The `PostgresClient` in `@coffeeshop/shared` may not expose a raw `query()` method. Check the interface. If not available, use an existing query like `getActiveCatalogue()` as a proxy health check — if it returns without error, PostgreSQL is healthy. This is slightly heavier but reliable.

### 1.5 Verification

1. All three services healthy: returns `{ overall: "healthy", services: [...] }`
2. One service down: returns `{ overall: "degraded" }` or `{ overall: "unavailable" }` with the failed service's error detail
3. Response times are reasonable (< 1s each for the demonstrator)
4. The health endpoint itself doesn't fail if a service is unreachable

### 1.6 Commit point

Combined with Stage 2 for a meaningful commit.

---

## Stage 2: Metrics API Route

### 2.1 Design

Create `GET /api/system/metrics` that aggregates operational data from existing endpoints:

```typescript
interface SystemMetrics {
  orders: {
    totalOrders: number;       // from /api/entity/orders
    ordersToday: number;       // from /api/entity/orders/today
    activeOrders: number;      // from /api/orders/active
  };
  catalogue: {
    totalItems: number;        // from /api/catalogue?all=true
    activeItems: number;       // from /api/catalogue
    categories: Record<string, number>;  // items per category
  };
  inventory: {
    trackedItems: number;      // from /api/inventory
    lowStockItems: number;     // items below threshold
    outOfStockItems: number;   // items with 0 stock
  };
  governance: {
    complianceRate: string;    // from /api/entity/governance
    dataGaps: number;
  };
  collectedAt: string;
}
```

### 2.2 Implementation

Create `src/routes/api/system/metrics/+server.ts`. This is a server-side aggregation route — it calls existing internal endpoints via `fetch` (using the SvelteKit internal fetch) or directly via the database/Temporal clients:

```typescript
import { json } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { getPostgresClient } from '$lib/server/postgres';
import { getEhrbaseClient } from '$lib/server/ehrbase';
import { getTemporalClient } from '$lib/server/temporal';
import { WORKFLOW_NAME } from '@coffeeshop/shared';

export const GET: RequestHandler = async ({ fetch }) => {
  // Use internal fetch for routes that have complex logic (CDR queries, governance)
  // Use direct DB access for simple counts

  const [
    catalogueAll,
    catalogueActive,
    inventory,
    ordersAllRes,
    ordersTodayRes,
    activeOrdersRes,
    governanceRes,
  ] = await Promise.allSettled([
    getPostgresClient().getAllCatalogueEntries(),
    getPostgresClient().getActiveCatalogue(),
    getPostgresClient().getAllInventory(),
    fetch('/api/entity/orders').then(r => r.json()),
    fetch('/api/entity/orders/today').then(r => r.json()),
    fetch('/api/orders/active').then(r => r.json()),
    fetch('/api/entity/governance').then(r => r.json()),
  ]);

  // Extract values with safe fallbacks
  const allCat = catalogueAll.status === 'fulfilled' ? catalogueAll.value : [];
  const activeCat = catalogueActive.status === 'fulfilled' ? catalogueActive.value : [];
  const inv = inventory.status === 'fulfilled' ? inventory.value : [];
  const allOrders = ordersAllRes.status === 'fulfilled' ? (ordersAllRes.value?.rows ?? ordersAllRes.value ?? []) : [];
  const todayOrders = ordersTodayRes.status === 'fulfilled' ? (ordersTodayRes.value?.rows ?? ordersTodayRes.value ?? []) : [];
  const activeOrders = activeOrdersRes.status === 'fulfilled' ? (activeOrdersRes.value?.orders ?? []) : [];
  const governance = governanceRes.status === 'fulfilled' ? governanceRes.value : null;

  // Category breakdown
  const categories: Record<string, number> = {};
  for (const item of activeCat) {
    const cat = item.category || 'unknown';
    categories[cat] = (categories[cat] || 0) + 1;
  }

  // Inventory alerts
  const lowStock = inv.filter((i: any) => i.stock_status === 'low_stock').length;
  const outOfStock = inv.filter((i: any) => i.stock_status === 'out_of_stock').length;

  return json({
    orders: {
      totalOrders: Array.isArray(allOrders) ? allOrders.length : 0,
      ordersToday: Array.isArray(todayOrders) ? todayOrders.length : 0,
      activeOrders: activeOrders.length,
    },
    catalogue: {
      totalItems: allCat.length,
      activeItems: activeCat.length,
      categories,
    },
    inventory: {
      trackedItems: inv.length,
      lowStockItems: lowStock,
      outOfStockItems: outOfStock,
    },
    governance: {
      complianceRate: governance?.summary?.complianceRate ?? 'N/A',
      dataGaps: parseInt(governance?.summary?.dataGaps ?? '0', 10),
    },
    collectedAt: new Date().toISOString(),
  });
};
```

### 2.3 Response shape considerations

The CDR entity endpoints return different shapes depending on the query. The `/api/entity/orders` response is an array of order objects. The `/api/entity/governance` response has a `summary` object with `complianceRate` and `dataGaps` fields. The `/api/orders/active` response wraps in `{ orders: [...] }`. The metrics aggregator normalises these into a consistent shape.

### 2.4 Verification

1. Metrics endpoint returns all sections populated
2. Category breakdown is accurate (hot_drink, cold_drink, food counts)
3. Inventory alerts match actual stock levels
4. Governance metrics match the Audit Dashboard
5. Graceful degradation if any sub-query fails (other sections still populated)

### 2.5 Commit point

```bash
git add -A && git commit -m "CSW backend: system health and metrics API routes"
```

---

## Stage 3: Process Model Page — Interactive Pathway

### 3.1 Current state

The existing `/pathway` page displays the generated SVG inline and a hardcoded orchestration steps table. It's static — no connection to live order state and no interactivity.

### 3.2 Design

Transform the Process Model page into an interactive two-layer pathway view:

```
/pathway (+page.svelte)
┌─────────────────────────────────────────────────────────────────────┐
│  Page Header: "Process Model"                                       │
│  "Drink fulfilment pathway — domain action flow and orchestration"  │
├─────────────────────────────────────────────────────────────────────┤
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │                                                               │  │
│  │  ┌─────────────────┐                                          │  │
│  │  │  Receive Order  │ ← green start node (clickable)          │  │
│  │  └────────┬────────┘                                          │  │
│  │           │                                                    │  │
│  │  ┌────────▼────────┐                                          │  │
│  │  │ Check Drink Type│ ← orange decision (clickable)            │  │
│  │  └─────┬──────┬────┘                                          │  │
│  │        │      │                                                │  │
│  │  ... (full SVG with step metadata on click) ...               │  │
│  │                                                               │  │
│  └───────────────────────────────────────────────────────────────┘  │
├─────────────────────────────────────────────────────────────────────┤
│  Active Orders Pathway State     [N active orders]                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │
│  │ #17734…      │  │ #17734…      │  │ #17734…      │             │
│  │ waitBarista   │  │ prepareDrink │  │ waitCollected│             │
│  │ 2m ago       │  │ 5m ago       │  │ 1m ago       │             │
│  └──────────────┘  └──────────────┘  └──────────────┘             │
├─────────────────────────────────────────────────────────────────────┤
│  Two-Layer Model Reference                                          │
│                                                                     │
│  Domain Layer (what the barista does):                              │
│  Receive Order → Check Drink Type → Prepare Base → ...              │
│                                                                     │
│  Orchestration Layer (what the system manages):                     │
│  Validate Order → Wait Barista → Prepare Drink → Wait Ready → ...  │
│                                                                     │
│  Source: coffeeshop-exercise/model/domain/drink-fulfilment.sysml   │
│          coffeeshop-exercise/model/domain/fulfil-drink-orch…sysml  │
└─────────────────────────────────────────────────────────────────────┘
```

### 3.3 Interactive SVG approach

Rather than manipulating the generated Mermaid SVG (which has opaque internal IDs and styling), build a **hand-crafted SVG pathway** in the Svelte component. This gives full control over clickability, highlighting, and theming.

The pathway steps come from the SysML model. Since the pathway is stable (not dynamically generated per session), the step definitions are declared in the component:

```typescript
interface PathwayStep {
  id: string;
  label: string;
  type: 'action' | 'decision' | 'start' | 'end';
  domainDoc: string;          // from drink-fulfilment.sysml doc blocks
  orchestrationStep?: string; // maps to FulfilDrinkOrchestration step
  orchestrationDoc?: string;  // from fulfil-drink-orchestration.sysml doc blocks
  signalName?: string;        // Temporal signal, if applicable
  timeoutMinutes?: number;    // Temporal timeout, if applicable
  clinicalAnalogy?: string;   // clinical context note
}

const PATHWAY_STEPS: PathwayStep[] = [
  {
    id: 'receiveOrder',
    label: 'Receive Order',
    type: 'start',
    domainDoc: 'Customer places order. The fulfilment process begins.',
    orchestrationStep: 'validateOrder',
    orchestrationDoc: 'Validate order details before processing.',
    clinicalAnalogy: 'Referral received and triaged.',
  },
  {
    id: 'checkDrinkType',
    label: 'Check Drink Type',
    type: 'decision',
    domainDoc: 'Route to hot or cold preparation path based on drink type.',
    clinicalAnalogy: 'Clinical decision point — route to appropriate pathway.',
  },
  {
    id: 'prepareHotBase',
    label: 'Prepare Hot Base',
    type: 'action',
    domainDoc: 'Pull espresso shot or brew tea.',
    orchestrationStep: 'prepareDrink',
    orchestrationDoc: 'Record that drink preparation has occurred.',
  },
  {
    id: 'prepareColdBase',
    label: 'Prepare Cold Base',
    type: 'action',
    domainDoc: 'Blend or mix iced drink base.',
    orchestrationStep: 'prepareDrink',
    orchestrationDoc: 'Record that drink preparation has occurred.',
  },
  {
    id: 'checkMilk',
    label: 'Check Milk',
    type: 'decision',
    domainDoc: 'Determine if milk is needed based on order.',
    clinicalAnalogy: 'Secondary decision — adjust treatment based on specifics.',
  },
  {
    id: 'addMilk',
    label: 'Add Milk',
    type: 'action',
    domainDoc: 'Steam or pour milk according to milkChoice.',
  },
  {
    id: 'assembleDrink',
    label: 'Assemble Drink',
    type: 'action',
    domainDoc: 'Combine base, milk, extras. Finish the drink.',
    orchestrationStep: 'waitDrinkReady',
    orchestrationDoc: 'Suspend until barista marks drink as ready.',
    signalName: 'drinkReady',
    timeoutMinutes: 15,
    clinicalAnalogy: 'Lab results returned.',
  },
  {
    id: 'markReady',
    label: 'Mark Ready',
    type: 'end',
    domainDoc: 'Drink is ready for customer collection.',
    orchestrationStep: 'waitCollected',
    orchestrationDoc: 'Suspend until customer collects their drink.',
    signalName: 'drinkCollected',
    timeoutMinutes: 60,
    clinicalAnalogy: 'Patient attends appointment.',
  },
];
```

### 3.4 Step metadata modal

Clicking a step opens a Flowbite Modal showing the two-layer detail:

```svelte
<Modal bind:open={stepModalOpen} title={selectedStep?.label ?? ''} size="md">
  <div class="space-y-4">
    <!-- Domain layer -->
    <div class="rounded-lg bg-green-50 p-3 dark:bg-green-900/20">
      <p class="text-xs font-semibold uppercase tracking-wider text-green-600 dark:text-green-400">Domain Layer</p>
      <p class="text-sm text-secondary-700 dark:text-secondary-300">{selectedStep?.domainDoc}</p>
      <p class="mt-1 text-xs text-secondary-400">Source: <code>drink-fulfilment.sysml</code></p>
    </div>

    <!-- Orchestration layer (if mapped) -->
    {#if selectedStep?.orchestrationStep}
      <div class="rounded-lg bg-blue-50 p-3 dark:bg-blue-900/20">
        <p class="text-xs font-semibold uppercase tracking-wider text-blue-600 dark:text-blue-400">Orchestration Layer</p>
        <p class="text-sm font-medium text-secondary-700 dark:text-secondary-300">{selectedStep.orchestrationStep}</p>
        <p class="text-sm text-secondary-600 dark:text-secondary-400">{selectedStep.orchestrationDoc}</p>
        {#if selectedStep.signalName}
          <p class="mt-1 text-xs text-secondary-400">
            Signal: <code>{selectedStep.signalName}</code> · Timeout: {selectedStep.timeoutMinutes} min
          </p>
        {/if}
        <p class="mt-1 text-xs text-secondary-400">Source: <code>fulfil-drink-orchestration.sysml</code></p>
      </div>
    {/if}

    <!-- Clinical analogy (if present) -->
    {#if selectedStep?.clinicalAnalogy}
      <div class="rounded-lg bg-secondary-50 p-3 dark:bg-secondary-800/50">
        <p class="text-xs font-semibold uppercase tracking-wider text-secondary-500 dark:text-secondary-400">Clinical Analogy</p>
        <p class="text-sm text-secondary-600 dark:text-secondary-400 italic">{selectedStep.clinicalAnalogy}</p>
      </div>
    {/if}
  </div>
  <!-- Modal actions — in-body, not using slot="footer" (known Flowbite issue) -->
  <div class="mt-4 border-t border-secondary-200 pt-4 dark:border-secondary-700">
    <Button color="alternative" size="sm" onclick={() => stepModalOpen = false}>Close</Button>
  </div>
</Modal>
```

### 3.5 Active orders pathway state

Below the SVG, show active orders with their current orchestration step. This connects the static model to live system state:

```typescript
// Fetch active orders on mount
let activeOrders = $state<{ orderId: string; state: string; startTime: string | null }[]>([]);

onMount(async () => {
  try {
    const res = await fetch('/api/orders/active');
    if (res.ok) {
      const data = await res.json();
      activeOrders = data.orders;
    }
  } catch { /* non-critical */ }
});
```

Each active order maps its XState lifecycle state to the orchestration step:

```typescript
const STATE_TO_STEP: Record<string, string> = {
  placed: 'validateOrder',
  preparing: 'prepareDrink',
  ready: 'waitCollected',
  // 'collected' and 'cancelled' are terminal — no active step
};

function getActiveStep(state: string): string {
  return STATE_TO_STEP[state] ?? state;
}
```

### 3.6 SVG pathway rendering approach

Two options:

**Option A: Retain the generated Mermaid SVG, add clickable overlay.** Load the SVG via `<img>` or inline, and overlay transparent clickable regions. Fragile — Mermaid node positions vary.

**Option B: Hand-craft a styled SVG in the component.** Full control over layout, theming, and interactivity. The pathway is stable (8 nodes, 9 edges) so this is a one-time effort.

**Recommendation: Option B.** The Mermaid SVG has hardcoded colours that conflict with the coffee shop theme, and its node IDs are Mermaid-internal. A hand-crafted SVG themed to the application palette, with `on:click` handlers per node, gives a better result and is maintainable.

The SVG will render nodes as rounded rectangles (actions), diamonds or rectangles (decisions), and stadium shapes (start/end), following the Mermaid structure but with coffee shop palette colours. CSS variables ensure dark mode compatibility.

### 3.7 Two-layer reference section

Below the active orders, a collapsible reference section explains the two-layer model:

```svelte
<details class="mt-6">
  <summary class="cursor-pointer text-sm font-medium text-secondary-600 hover:text-secondary-800 dark:text-secondary-400 dark:hover:text-secondary-200">
    Two-layer model reference
  </summary>
  <div class="mt-3 grid gap-4 lg:grid-cols-2">
    <!-- Domain layer -->
    <div class="rounded-lg border-l-4 border-green-500 bg-green-50 p-4 dark:bg-green-900/20">
      <p class="text-xs font-semibold uppercase tracking-wider text-green-600 dark:text-green-400">Domain Layer — What the Barista Does</p>
      <p class="mt-1 text-sm text-secondary-600 dark:text-secondary-400">
        Receive Order → Check Drink Type → Prepare Hot/Cold Base → Check Milk → Add Milk → Assemble Drink → Mark Ready
      </p>
      <p class="mt-2 text-xs text-secondary-400">Source: <code>model/domain/drink-fulfilment.sysml</code></p>
    </div>
    <!-- Orchestration layer -->
    <div class="rounded-lg border-l-4 border-blue-500 bg-blue-50 p-4 dark:bg-blue-900/20">
      <p class="text-xs font-semibold uppercase tracking-wider text-blue-600 dark:text-blue-400">Orchestration Layer — What the System Manages</p>
      <p class="mt-1 text-sm text-secondary-600 dark:text-secondary-400">
        Validate Order → Wait for Barista → Prepare Drink → Wait Drink Ready → Wait for Collection → Complete Order
      </p>
      <p class="mt-2 text-xs text-secondary-400">Source: <code>model/domain/fulfil-drink-orchestration.sysml</code></p>
    </div>
  </div>
</details>
```

### 3.8 Existing orchestration table

The existing table of orchestration steps is retained but moved into the two-layer reference section (or a separate collapsible). It's useful reference material but shouldn't dominate the page now that there's interactive content.

### 3.9 Verification

1. SVG pathway renders with coffee shop theme colours
2. Clicking any step opens the metadata modal
3. Modal shows domain layer, orchestration layer (if mapped), and clinical analogy
4. Active orders section loads and displays current orders with their pathway step
5. State-to-step mapping is correct for all lifecycle states
6. Two-layer reference section is collapsible and shows both SysML sources
7. Empty state when no active orders
8. Dark mode for SVG nodes, modal, and reference section
9. Mobile layout: SVG scrolls horizontally if needed, modal is full-width

### 3.10 Commit point

```bash
git add -A && git commit -m "CSW frontend: interactive Process Model with step metadata and active order state"
```

---

## Stage 4: System Status Page — Operational Dashboard

### 4.1 Current state

The existing `/system` page is a single placeholder Card. It needs to become the system-awareness hub.

### 4.2 Design

```
/system (+page.svelte)
┌─────────────────────────────────────────────────────────────────────┐
│  Page Header: "System Status"                                       │
│  "Infrastructure health, operational metrics, and self-assessment"   │
├─────────────────────────────────────────────────────────────────────┤
│  INFRASTRUCTURE HEALTH                               Last checked:  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  [↻ Check]  │
│  │  ● Temporal   │  │  ● EHRbase   │  │  ● PostgreSQL│             │
│  │  Healthy      │  │  Healthy     │  │  Healthy     │             │
│  │  12ms         │  │  45ms        │  │  3ms         │             │
│  └──────────────┘  └──────────────┘  └──────────────┘             │
├─────────────────────────────────────────────────────────────────────┤
│  OPERATIONAL METRICS                                                │
│  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────────────────┐    │
│  │  19  │  │   3  │  │   3  │  │  12  │  │  100% Compliance │    │
│  │Total │  │Today │  │Active│  │ Menu │  │  ██████████████  │    │
│  │Orders│  │      │  │      │  │Items │  │  0 data gaps     │    │
│  └──────┘  └──────┘  └──────┘  └──────┘  └──────────────────┘    │
├─────────────────────────────────────────────────────────────────────┤
│  CATALOGUE & INVENTORY                                              │
│  ┌─ Categories ────────────────────────────────────────────────┐   │
│  │  Hot Drinks: 6 · Cold Drinks: 4 · Food: 2                  │   │
│  └─────────────────────────────────────────────────────────────┘   │
│  ┌─ Stock Alerts ──────────────────────────────────────────────┐   │
│  │  ⚠ 0 low stock · 0 out of stock                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────────────┤
│  STRUCTURAL INVENTORY                                               │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  Persistence Layers: 3 (CDR, PostgreSQL, Temporal)          │   │
│  │  SysML Packages: 72 · Model Files: 10                      │   │
│  │  API Routes: 19 · Frontend Pages: 9                         │   │
│  │  Temporal Workflows: 1 · CDR Archetypes: 3                  │   │
│  │  PostgreSQL Tables: 4 · Generated Artefacts: 4+             │   │
│  └─────────────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────────────┤
│  SELF-ASSESSMENT (Knowledge Layer Increment 3 — Placeholder)       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  This panel will be populated when Knowledge Layer           │   │
│  │  Increment 3 is implemented: the five-layer self-knowledge  │   │
│  │  architecture (ConstraintEvaluator → OperationalState →     │   │
│  │  GoalProjector → GapAnalyser → RemediationPlanner).         │   │
│  │                                                              │   │
│  │  Clinical analogy: "Is the service meeting its obligations?  │   │
│  │  Are any patients overdue for monitoring? What should the   │   │
│  │  service prioritise next?"                                   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

### 4.3 Data loading

Auto-load both health and metrics on mount:

```typescript
let health = $state<HealthResponse | null>(null);
let metrics = $state<SystemMetrics | null>(null);
let healthLoading = $state(true);
let metricsLoading = $state(true);
let healthError = $state('');
let metricsError = $state('');

onMount(() => {
  loadHealth();
  loadMetrics();
});

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
```

### 4.4 Infrastructure health section

Three cards, one per service, with status indicator, service name, and response time:

```svelte
<div class="grid grid-cols-1 gap-3 sm:grid-cols-3">
  {#each (health?.services ?? []) as svc}
    <div class="rounded-lg border p-4 {svc.status === 'healthy' ? 'border-green-200 bg-green-50 dark:border-green-800 dark:bg-green-900/20' : svc.status === 'degraded' ? 'border-yellow-200 bg-yellow-50 dark:border-yellow-800 dark:bg-yellow-900/20' : 'border-red-200 bg-red-50 dark:border-red-800 dark:bg-red-900/20'}">
      <div class="flex items-center gap-2">
        <span class="inline-block h-2.5 w-2.5 rounded-full {svc.status === 'healthy' ? 'bg-green-500' : svc.status === 'degraded' ? 'bg-yellow-500' : 'bg-red-500'}"></span>
        <span class="font-medium text-secondary-800 dark:text-white">{svc.service}</span>
      </div>
      <p class="mt-1 text-sm text-secondary-500 dark:text-secondary-400 capitalize">{svc.status}</p>
      <p class="text-xs text-secondary-400 dark:text-secondary-500">{svc.responseTimeMs}ms</p>
      {#if svc.detail}
        <p class="mt-1 text-xs text-red-500 dark:text-red-400">{svc.detail}</p>
      {/if}
    </div>
  {/each}
</div>
```

### 4.5 Navbar health indicator integration

The navbar currently shows static green dots. Upgrade these to reflect real health status. Two approaches:

**Option A: Fetch health from the System Status page and propagate via a store.** Requires a shared store — adds complexity.

**Option B: The layout itself fetches `/api/system/health` periodically.** Simpler but adds load to every page.

**Option C: Keep the navbar dots static but update their colour when the user visits `/system`.** Pragmatic — the health check is intensive (three service pings) and shouldn't run on every page load.

**Recommendation: Option C for now.** The navbar dots remain as static indicators. The System Status page is the authoritative health view. A future enhancement can add periodic health polling if needed. Add a TODO comment in the layout.

### 4.6 Operational metrics section

Five summary cards in a responsive grid, mirroring the Audit Dashboard pattern:

```svelte
<div class="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-5">
  <div class="rounded-lg bg-secondary-50 p-4 text-center dark:bg-secondary-800">
    <div class="text-2xl font-bold text-secondary-800 dark:text-white">{metrics?.orders.totalOrders ?? '—'}</div>
    <div class="text-xs text-secondary-500 dark:text-secondary-400">Total Orders</div>
  </div>
  <div class="rounded-lg bg-secondary-50 p-4 text-center dark:bg-secondary-800">
    <div class="text-2xl font-bold text-secondary-800 dark:text-white">{metrics?.orders.ordersToday ?? '—'}</div>
    <div class="text-xs text-secondary-500 dark:text-secondary-400">Orders Today</div>
  </div>
  <div class="rounded-lg bg-secondary-50 p-4 text-center dark:bg-secondary-800">
    <div class="text-2xl font-bold text-primary-600 dark:text-primary-400">{metrics?.orders.activeOrders ?? '—'}</div>
    <div class="text-xs text-secondary-500 dark:text-secondary-400">Active Orders</div>
  </div>
  <div class="rounded-lg bg-secondary-50 p-4 text-center dark:bg-secondary-800">
    <div class="text-2xl font-bold text-secondary-800 dark:text-white">{metrics?.catalogue.activeItems ?? '—'}</div>
    <div class="text-xs text-secondary-500 dark:text-secondary-400">Menu Items</div>
  </div>
  <!-- Compliance rate card with progress bar (same pattern as Audit Dashboard) -->
  <div class="rounded-lg bg-secondary-50 p-4 text-center dark:bg-secondary-800">
    <div class="text-2xl font-bold text-secondary-800 dark:text-white">{metrics?.governance.complianceRate ?? '—'}</div>
    <div class="mb-1 h-2 w-full overflow-hidden rounded-full bg-secondary-200 dark:bg-secondary-700">
      {#if metrics?.governance.complianceRate}
        {@const rate = parseFloat(metrics.governance.complianceRate) || 0}
        <div class="{rate === 100 ? 'bg-green-500' : rate >= 75 ? 'bg-yellow-500' : 'bg-red-500'} h-2 rounded-full transition-all" style="width: {rate}%"></div>
      {/if}
    </div>
    <div class="text-xs text-secondary-500 dark:text-secondary-400">Compliance · {metrics?.governance.dataGaps ?? 0} gaps</div>
  </div>
</div>
```

### 4.7 Catalogue & inventory section

Category breakdown and stock alerts:

```svelte
<div class="grid gap-3 lg:grid-cols-2">
  <!-- Categories -->
  <div class="rounded-lg border border-secondary-200 p-4 dark:border-secondary-700">
    <p class="mb-2 text-xs font-semibold uppercase tracking-wider text-secondary-500 dark:text-secondary-400">Categories</p>
    <div class="flex flex-wrap gap-2">
      {#each Object.entries(metrics?.catalogue.categories ?? {}) as [cat, count]}
        <span class="rounded-full bg-primary-100 px-3 py-1 text-sm font-medium text-primary-700 dark:bg-primary-900/30 dark:text-primary-300">
          {formatCategoryName(cat)}: {count}
        </span>
      {/each}
    </div>
  </div>

  <!-- Stock alerts -->
  <div class="rounded-lg border border-secondary-200 p-4 dark:border-secondary-700">
    <p class="mb-2 text-xs font-semibold uppercase tracking-wider text-secondary-500 dark:text-secondary-400">Stock Alerts</p>
    {#if (metrics?.inventory.lowStockItems ?? 0) === 0 && (metrics?.inventory.outOfStockItems ?? 0) === 0}
      <p class="text-sm text-green-600 dark:text-green-400">All stock levels normal</p>
    {:else}
      <div class="flex gap-4">
        {#if (metrics?.inventory.lowStockItems ?? 0) > 0}
          <span class="text-sm text-yellow-600 dark:text-yellow-400">⚠ {metrics?.inventory.lowStockItems} low stock</span>
        {/if}
        {#if (metrics?.inventory.outOfStockItems ?? 0) > 0}
          <span class="text-sm text-red-600 dark:text-red-400">✗ {metrics?.inventory.outOfStockItems} out of stock</span>
        {/if}
      </div>
    {/if}
    <p class="mt-1 text-xs text-secondary-400 dark:text-secondary-500">{metrics?.inventory.trackedItems ?? 0} items tracked</p>
  </div>
</div>
```

### 4.8 Structural inventory section

Static metadata about the system — this is the "system manifest" in human-readable form. Values are from the strategic snapshot and will eventually be read from the generated System Model Manifest (when that generator is built):

```svelte
<div class="rounded-lg border border-secondary-200 p-4 dark:border-secondary-700">
  <p class="mb-3 text-xs font-semibold uppercase tracking-wider text-secondary-500 dark:text-secondary-400">Structural Inventory</p>
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
```

### 4.9 Self-assessment placeholder

The KL Increment 3 landing zone — a prominent but clearly labelled placeholder:

```svelte
<div class="rounded-lg border-2 border-dashed border-secondary-300 p-6 dark:border-secondary-600">
  <p class="mb-2 text-xs font-semibold uppercase tracking-wider text-secondary-500 dark:text-secondary-400">Self-Assessment — Knowledge Layer Increment 3</p>
  <p class="text-sm text-secondary-600 dark:text-secondary-400">
    This panel will be populated when Knowledge Layer Increment 3 is implemented: the five-layer self-knowledge
    architecture running in the coffee shop context.
  </p>
  <div class="mt-3 space-y-1 text-xs text-secondary-400 dark:text-secondary-500">
    <p><strong>Layer 1:</strong> ConstraintEvaluator — "Is this order valid against current catalogue rules?"</p>
    <p><strong>Layer 2:</strong> OperationalStateAggregator — "N orders today, N active, preparation rate N%"</p>
    <p><strong>Layer 3:</strong> GoalProjector — "At current throughput, will we meet today's target?"</p>
    <p><strong>Layer 4:</strong> GapAnalyser — "3 orders are waiting longer than the expected 30-minute threshold"</p>
    <p><strong>Layer 5:</strong> RemediationPlanner — "Consider adding a second barista during peak hours"</p>
  </div>
  <div class="mt-4 rounded-lg bg-secondary-50 p-3 dark:bg-secondary-800/50">
    <p class="text-xs text-secondary-500 dark:text-secondary-400 italic">
      <strong>Clinical analogy:</strong> "Is the service meeting its obligations? Are any patients overdue for monitoring?
      What should the service prioritise next?" — the five-layer architecture answers these questions from model-defined
      constraints and live operational data.
    </p>
  </div>
</div>
```

### 4.10 Verification

1. Health check runs on mount, shows all three services with status/response time
2. Refresh button re-runs health check
3. Metrics load and display correctly
4. Category breakdown matches catalogue data
5. Stock alerts reflect inventory state
6. Structural inventory shows correct static values
7. Self-assessment placeholder is clearly labelled
8. Loading spinners during data fetch
9. Error states for health/metrics failures
10. Dark mode correct throughout
11. Mobile layout: cards stack, grid adjusts

### 4.11 Commit point

```bash
git add -A && git commit -m "CSW frontend: System Status dashboard with live health checks, operational metrics, and KL3 placeholder"
```

---

## Stage 5: Polish, Cross-Page Consistency, and Integration Testing

### 5.1 Update API route count

With the two new API routes (`/api/system/health`, `/api/system/metrics`), the total API route count increases from 17 to 19. Update the structural inventory on the System Status page accordingly.

### 5.2 Cross-page links

Add/verify navigation links:

- System Status → Audit Dashboard (for detailed governance view)
- System Status → Stock & Catalogue (for detailed inventory management)
- Process Model → Order Board (to see active orders in kanban view)
- Process Model → Order Timeline (for individual order detail)

### 5.3 Navbar TODO comment

Add a comment in `+layout.svelte` noting that the health indicators are static and could be made live via `/api/system/health` polling:

```svelte
<!-- TODO: Replace static green dots with live health indicators.
     Option: poll /api/system/health every 60s and update dot colours.
     Deferred: health check pings three services, which is heavyweight
     for every page load. System Status page is the authoritative view. -->
```

### 5.4 End-to-end integration test

Complete scenario exercising both Phase 9 pages:

1. **Navigate to Process Model** — SVG pathway renders, active orders section shows current orders (if any)
2. **Click a pathway step** — metadata modal opens showing domain layer, orchestration layer, clinical analogy
3. **Close modal** — modal dismisses
4. **Place an order** from the Counter — return to Process Model → active orders section shows the new order at "placed" / "validateOrder" step
5. **Navigate to System Status** — health check runs, metrics load
6. **Verify health cards** — all three services show as healthy with response times
7. **Verify metrics** — order count reflects the new order, catalogue stats match the manager view
8. **Check stock alerts** — if any items are low stock, alert appears
9. **Scroll to self-assessment** — placeholder is visible and clearly labelled
10. **Dark mode** — verify both pages in dark mode

### 5.5 Dark mode verification

All new components:

- SVG pathway: node fills use CSS variables for light/dark
- Step metadata modal: domain (green), orchestration (blue), analogy (secondary) backgrounds
- Health cards: green/yellow/red conditional backgrounds
- Metrics cards: secondary-50/800 backgrounds
- Structural inventory: secondary-200/700 borders
- Self-assessment placeholder: dashed border, secondary tones

### 5.6 Final commit

```bash
git add -A && git commit -m "CSW frontend: System pages polish and integration verification"
```

---

## Files Created / Modified

### New files

| File | Purpose |
|---|---|
| `src/routes/api/system/health/+server.ts` | Infrastructure health check endpoint |
| `src/routes/api/system/metrics/+server.ts` | Operational metrics aggregation endpoint |

### Modified files

| File | Change |
|---|---|
| `src/routes/pathway/+page.svelte` | **Rewritten** — interactive SVG pathway with step modals and active order state |
| `src/routes/system/+page.svelte` | **Rewritten** — operational dashboard with health, metrics, inventory, KL3 placeholder |
| `src/routes/+layout.svelte` | TODO comment on navbar health indicators |

### Unchanged

All existing API routes (17 routes from Phases A–D and Phase 3), all existing page components (Counter, Order Board, Order Timeline, Manager GUI, Records, Audit Dashboard, Customer Voice), all `$lib/server/` modules, all `packages/shared/` and `packages/temporal/` code, the layout structure, and `app.css`.

---

## Risks and Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| **EHRbase client doesn't expose `baseUrl`** | Medium | Fallback: use a known dev URL or AQL health query instead of the `/ehrbase/status` endpoint. Both approaches verify CDR connectivity. |
| **PostgreSQL client doesn't expose raw `query()`** | Medium | Fallback: use `getActiveCatalogue()` as a proxy health check. Any successful query confirms connectivity. |
| **Temporal health check slow if many workflows** | Low | The list query uses `pageSize: 1` and only consumes the first result. Even with many workflows, the operation should be fast. |
| **Metrics endpoint slow (7 sub-queries)** | Medium | `Promise.allSettled` runs all queries in parallel. Individual failures don't block others. Show loading state while metrics collect. |
| **Hand-crafted SVG maintenance burden** | Low | The pathway is stable — only changes if the SysML action flow changes, which is rare. The SVG is simpler than the Mermaid output and fully themed. |
| **Flowbite Modal in-body buttons** | Already mitigated | Known issue from Phase 6 — use `border-t` separator pattern instead of `slot="footer"`. |
| **Svelte 5 `{@const}` placement** | Already mitigated | Known issue from Phase 8 — use `$derived` for top-level computed values. |

---

## What This Phase Does Not Do

- Does not make the navbar health indicators live (static green dots remain — see §5.3 for the TODO and rationale)
- Does not implement Knowledge Layer Increment 3 (the self-assessment panel is a clearly labelled placeholder)
- Does not add a system manifest generator (structural inventory uses static values)
- Does not add periodic health polling or auto-refresh (manual refresh button provided)
- Does not modify the SysML model (Phase 10)
- Does not add real-time WebSocket updates for active order state (client-side polling on mount is sufficient for the demonstrator)

---

## Coffee Shop Demonstrator Extension

**Capability demonstrated:** System self-awareness — live infrastructure health monitoring across all three persistence layers, operational metrics aggregation, interactive process model visualisation with two-layer domain/orchestration annotation, and a structured landing zone for the five-layer self-knowledge architecture.

**Clinical implementation confidence:** High. The patterns map directly to:

- **Infrastructure health:** In production, the System Status dashboard monitors EHRbase CDR uptime, Temporal workflow engine health, and the business database — all critical for a clinical service where system availability directly affects patient care.
- **Operational metrics:** "N patients in active pathways, N awaiting monitoring bloods, compliance rate for 3-month milestone" — the same aggregation pattern, different domain data.
- **Process Model:** The interactive pathway becomes the clinical pathway visualisation. Clicking "Initial Assessment" shows the domain-level clinical actions (history, examination, consent) and the orchestration-level workflow steps (schedule appointment, await results, update record). The two-layer distinction is architecturally important: clinicians read the domain layer; the system executes the orchestration layer.
- **Self-assessment:** The KL Increment 3 landing zone becomes the clinical service's self-knowledge dashboard: "Are all patients receiving timely monitoring? Are any pathways stalled? What should the service prioritise?"

**What will be learned:**

- Whether infrastructure health checks at the application level provide useful operational visibility
- Whether the hand-crafted SVG pathway is maintainable and visually effective
- Whether the two-layer model presentation (domain + orchestration) is clear to non-technical reviewers
- How the metrics aggregation pattern scales with data volume
- Whether the self-assessment placeholder communicates the KL Increment 3 vision effectively

---

## Relationship to Subsequent Phases

### Phase 10 — Meta Model Update

Phase 9 introduces no new domain concepts, but the infrastructure health and metrics patterns may inform meta model concepts around "system health", "operational metric", and "self-assessment". These are natural extensions of the existing `Platform::SystemModel` package.

The structural inventory (persistence layers, model packages, API routes, etc.) will eventually be populated from the generated System Model Manifest — connecting the Phase 10 meta model work directly to the System Status page.

### Knowledge Layer Increment 3

The self-assessment placeholder on the System Status page is explicitly designed as the Increment 3 landing zone. The five layers are labelled with their coffee shop equivalents. When Increment 3 is implemented, this placeholder is replaced with live self-assessment results — the same data structure, populated by the constraint evaluation chain rather than static text.

---

*Plan prepared 14 March 2026. Phase 9 of the CSW Extension workstream.*
