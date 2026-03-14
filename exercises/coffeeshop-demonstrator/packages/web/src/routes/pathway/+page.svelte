<script lang="ts">
  import { onMount } from 'svelte';
  import { Badge, Button, Modal, Spinner } from 'flowbite-svelte';

  // ── Pathway step definitions from SysML model ──

  interface PathwayStep {
    id: string;
    label: string;
    type: 'start' | 'action' | 'decision' | 'end';
    domainDoc: string;
    orchestrationStep?: string;
    orchestrationDoc?: string;
    signalName?: string;
    timeoutMinutes?: number;
    clinicalAnalogy?: string;
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
      orchestrationDoc: 'Record that drink preparation has occurred. The domain-level detail (hot/cold path, milk choice) is modelled in the FulfilDrink domain action flow.',
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
      domainDoc: 'Determine if milk is needed based on the order.',
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
      domainDoc: 'Combine the base and milk (if needed), add any extras (lid, sleeve, straw), and finish the drink.',
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

  // ── Edge definitions ──

  interface PathwayEdge {
    from: string;
    to: string;
    label?: string;
  }

  const PATHWAY_EDGES: PathwayEdge[] = [
    { from: 'receiveOrder', to: 'checkDrinkType' },
    { from: 'checkDrinkType', to: 'prepareHotBase', label: 'Hot' },
    { from: 'checkDrinkType', to: 'prepareColdBase', label: 'Cold' },
    { from: 'prepareHotBase', to: 'assembleDrink' },
    { from: 'prepareColdBase', to: 'checkMilk' },
    { from: 'checkMilk', to: 'addMilk', label: 'Yes' },
    { from: 'checkMilk', to: 'assembleDrink', label: 'No' },
    { from: 'addMilk', to: 'assembleDrink' },
    { from: 'assembleDrink', to: 'markReady' },
  ];

  // ── SVG node positions (hand-laid-out) ──

  interface NodePosition {
    x: number;
    y: number;
    w: number;
    h: number;
  }

  const NODE_POSITIONS: Record<string, NodePosition> = {
    receiveOrder:   { x: 220, y: 30,  w: 160, h: 44 },
    checkDrinkType: { x: 220, y: 120, w: 170, h: 44 },
    prepareHotBase: { x: 100, y: 220, w: 160, h: 44 },
    prepareColdBase:{ x: 340, y: 220, w: 170, h: 44 },
    checkMilk:      { x: 340, y: 320, w: 140, h: 44 },
    addMilk:        { x: 400, y: 420, w: 130, h: 44 },
    assembleDrink:  { x: 220, y: 520, w: 160, h: 44 },
    markReady:      { x: 220, y: 620, w: 160, h: 44 },
  };

  // ── Node styling by type ──

  function nodeColour(type: PathwayStep['type']): { fill: string; stroke: string; text: string } {
    switch (type) {
      case 'start':    return { fill: '#4a7c59', stroke: '#3d6b4a', text: '#ffffff' };
      case 'end':      return { fill: '#5b7fa5', stroke: '#4a6d8c', text: '#ffffff' };
      case 'decision': return { fill: '#c4883a', stroke: '#a8712e', text: '#ffffff' };
      case 'action':   return { fill: '#f5f0eb', stroke: '#c4b5a0', text: '#3d3530' };
    }
  }

  // ── Edge path calculation ──

  function edgePath(from: string, to: string): string {
    const f = NODE_POSITIONS[from];
    const t = NODE_POSITIONS[to];
    if (!f || !t) return '';

    const startX = f.x + f.w / 2;
    const startY = f.y + f.h;
    const endX = t.x + t.w / 2;
    const endY = t.y;

    // Straight vertical or simple curve
    if (Math.abs(startX - endX) < 10) {
      return `M ${startX} ${startY} L ${endX} ${endY}`;
    }

    // Curved path for non-vertical edges
    const midY = startY + (endY - startY) / 2;
    return `M ${startX} ${startY} C ${startX} ${midY}, ${endX} ${midY}, ${endX} ${endY}`;
  }

  // ── Edge label position ──

  function edgeLabelPos(from: string, to: string): { x: number; y: number } {
    const f = NODE_POSITIONS[from];
    const t = NODE_POSITIONS[to];
    if (!f || !t) return { x: 0, y: 0 };

    const startX = f.x + f.w / 2;
    const startY = f.y + f.h;
    const endX = t.x + t.w / 2;
    const endY = t.y;

    return {
      x: (startX + endX) / 2 + (startX === endX ? 12 : 0),
      y: (startY + endY) / 2,
    };
  }

  // ── Active orders ──

  interface ActiveOrder {
    orderId: string;
    state: string;
    startTime: string | null;
  }

  let activeOrders = $state<ActiveOrder[]>([]);
  let ordersLoading = $state(true);

  // Map XState lifecycle state to orchestration step label
  const STATE_TO_LABEL: Record<string, string> = {
    placed: 'Validate Order',
    preparing: 'Prepare Drink',
    ready: 'Wait for Collection',
    collected: 'Complete',
    cancelled: 'Cancelled',
  };

  function stateLabel(state: string): string {
    return STATE_TO_LABEL[state] ?? state;
  }

  function stateBadgeColour(state: string): 'green' | 'blue' | 'yellow' | 'red' | 'dark' {
    switch (state) {
      case 'placed': return 'blue';
      case 'preparing': return 'yellow';
      case 'ready': return 'green';
      case 'collected': return 'dark';
      case 'cancelled': return 'red';
      default: return 'dark';
    }
  }

  function formatElapsed(iso: string | null): string {
    if (!iso) return '';
    const ms = Date.now() - new Date(iso).getTime();
    const mins = Math.floor(ms / 60000);
    if (mins < 1) return 'just now';
    if (mins < 60) return `${mins}m ago`;
    const hrs = Math.floor(mins / 60);
    return `${hrs}h ${mins % 60}m ago`;
  }

  // ── Step modal ──

  let stepModalOpen = $state(false);
  let selectedStep = $state<PathwayStep | null>(null);

  function openStepModal(step: PathwayStep) {
    selectedStep = step;
    stepModalOpen = true;
  }

  // ── Lifecycle ──

  onMount(async () => {
    try {
      const res = await fetch('/api/orders/active');
      if (res.ok) {
        const data = await res.json();
        activeOrders = data.orders;
      }
    } catch {
      // Non-critical — active orders panel is informational
    } finally {
      ordersLoading = false;
    }
  });
</script>

<!-- Page header -->
<div class="mb-6">
  <h1 class="text-2xl font-bold text-secondary-800 dark:text-white">Process Model</h1>
  <p class="text-sm text-secondary-500 dark:text-secondary-400">
    Drink fulfilment pathway — domain action flow and orchestration workflow.
    Click any step for two-layer detail.
  </p>
</div>

<!-- SVG Pathway Diagram -->
<div class="mb-6 overflow-x-auto rounded-lg border border-secondary-200 bg-white p-4 dark:border-secondary-700 dark:bg-secondary-800">
  <svg viewBox="0 0 560 690" xmlns="http://www.w3.org/2000/svg" class="mx-auto" style="max-width: 560px;">
    <!-- Edges (drawn first, behind nodes) -->
    {#each PATHWAY_EDGES as edge}
      <path
        d={edgePath(edge.from, edge.to)}
        fill="none"
        stroke="#9c8b7a"
        stroke-width="2"
        class="dark:stroke-secondary-500"
        marker-end="url(#arrowhead)"
      />
      {#if edge.label}
        {@const pos = edgeLabelPos(edge.from, edge.to)}
        <text
          x={pos.x}
          y={pos.y}
          text-anchor="middle"
          font-size="11"
          fill="#8b7d6e"
          class="dark:fill-secondary-400"
        >{edge.label}</text>
      {/if}
    {/each}

    <!-- Arrowhead marker -->
    <defs>
      <marker id="arrowhead" markerWidth="8" markerHeight="6" refX="7" refY="3" orient="auto">
        <polygon points="0 0, 8 3, 0 6" fill="#9c8b7a" />
      </marker>
    </defs>

    <!-- Nodes -->
    {#each PATHWAY_STEPS as step}
      {@const pos = NODE_POSITIONS[step.id]}
      {@const colours = nodeColour(step.type)}
      <g
        class="cursor-pointer"
        role="button"
        tabindex="0"
        onclick={() => openStepModal(step)}
        onkeydown={(e) => { if (e.key === 'Enter' || e.key === ' ') openStepModal(step); }}
      >
        {#if step.type === 'start' || step.type === 'end'}
          <!-- Stadium shape for start/end -->
          <rect
            x={pos.x} y={pos.y} width={pos.w} height={pos.h}
            rx="22" ry="22"
            fill={colours.fill} stroke={colours.stroke} stroke-width="2"
          />
        {:else if step.type === 'decision'}
          <!-- Rectangle with heavier border for decisions -->
          <rect
            x={pos.x} y={pos.y} width={pos.w} height={pos.h}
            rx="6" ry="6"
            fill={colours.fill} stroke={colours.stroke} stroke-width="2.5"
          />
        {:else}
          <!-- Standard rounded rectangle for actions -->
          <rect
            x={pos.x} y={pos.y} width={pos.w} height={pos.h}
            rx="6" ry="6"
            fill={colours.fill} stroke={colours.stroke} stroke-width="1.5"
          />
        {/if}
        <text
          x={pos.x + pos.w / 2}
          y={pos.y + pos.h / 2 + 5}
          text-anchor="middle"
          font-size="13"
          font-weight="500"
          fill={colours.text}
        >{step.label}</text>
      </g>
    {/each}
  </svg>
</div>

<!-- Active Orders Pathway State -->
<div class="mb-6">
  <div class="mb-3 flex items-center gap-2">
    <h2 class="text-lg font-semibold text-secondary-700 dark:text-secondary-300">Active Orders</h2>
    {#if !ordersLoading}
      <Badge color="dark" class="text-xs">{activeOrders.length}</Badge>
    {/if}
  </div>

  {#if ordersLoading}
    <div class="flex items-center gap-2 py-4 text-secondary-500">
      <Spinner size="5" /> Loading active orders…
    </div>
  {:else if activeOrders.length === 0}
    <div class="rounded-lg border-2 border-dashed border-secondary-200 p-6 text-center text-sm text-secondary-400 dark:border-secondary-700 dark:text-secondary-500">
      No active orders. Place an order from the <a href="/" class="text-primary-600 hover:underline dark:text-primary-400">Counter</a> to see orders tracked here.
    </div>
  {:else}
    <div class="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
      {#each activeOrders as order}
        <div class="rounded-lg border border-secondary-200 bg-white p-4 dark:border-secondary-700 dark:bg-secondary-800">
          <div class="mb-1 flex items-center justify-between">
            <code class="text-xs text-secondary-500 dark:text-secondary-400">#{order.orderId.substring(0, 13)}…</code>
            <Badge color={stateBadgeColour(order.state)}>{order.state}</Badge>
          </div>
          <p class="text-sm font-medium text-secondary-700 dark:text-secondary-300">{stateLabel(order.state)}</p>
          {#if order.startTime}
            <p class="text-xs text-secondary-400 dark:text-secondary-500">{formatElapsed(order.startTime)}</p>
          {/if}
        </div>
      {/each}
    </div>
  {/if}
</div>

<!-- Two-layer model reference -->
<details class="mb-6">
  <summary class="cursor-pointer text-sm font-medium text-secondary-600 hover:text-secondary-800 dark:text-secondary-400 dark:hover:text-secondary-200">
    Two-layer model reference
  </summary>
  <div class="mt-3 grid gap-4 lg:grid-cols-2">
    <!-- Domain layer -->
    <div class="rounded-lg border-l-4 border-green-600 bg-green-50 p-4 dark:border-green-500 dark:bg-green-900/20">
      <p class="text-xs font-semibold uppercase tracking-wider text-green-700 dark:text-green-400">Domain Layer — What the Barista Does</p>
      <p class="mt-2 text-sm text-secondary-600 dark:text-secondary-400">
        Receive Order → Check Drink Type → Prepare Hot/Cold Base → Check Milk → Add Milk → Assemble Drink → Mark Ready
      </p>
      <p class="mt-2 text-xs text-secondary-400 dark:text-secondary-500">
        Source: <code>model/domain/drink-fulfilment.sysml</code>
      </p>
    </div>
    <!-- Orchestration layer -->
    <div class="rounded-lg border-l-4 border-blue-600 bg-blue-50 p-4 dark:border-blue-500 dark:bg-blue-900/20">
      <p class="text-xs font-semibold uppercase tracking-wider text-blue-700 dark:text-blue-400">Orchestration Layer — What the System Manages</p>
      <p class="mt-2 text-sm text-secondary-600 dark:text-secondary-400">
        Validate Order → Wait for Barista → Prepare Drink → Wait Drink Ready → Wait for Collection → Complete Order
      </p>
      <p class="mt-2 text-xs text-secondary-400 dark:text-secondary-500">
        Source: <code>model/domain/fulfil-drink-orchestration.sysml</code>
      </p>
    </div>
  </div>
</details>

<!-- Orchestration workflow steps table -->
<details>
  <summary class="cursor-pointer text-sm font-medium text-secondary-600 hover:text-secondary-800 dark:text-secondary-400 dark:hover:text-secondary-200">
    Orchestration workflow steps
  </summary>
  <div class="mt-3 overflow-x-auto">
    <table class="w-full text-left text-sm text-secondary-500 dark:text-secondary-400">
      <thead class="bg-secondary-50 text-xs uppercase text-secondary-700 dark:bg-secondary-700 dark:text-secondary-400">
        <tr>
          <th class="px-4 py-2">Step</th>
          <th class="px-4 py-2">Type</th>
          <th class="px-4 py-2">Timeout</th>
          <th class="px-4 py-2">Description</th>
        </tr>
      </thead>
      <tbody>
        {#each [
          { step: 'Validate Order', type: 'Activity', dur: '1 min', desc: 'Validate order details before processing' },
          { step: 'Wait for Barista', type: 'Signal wait', dur: '30 min', desc: 'Suspend until a barista signals they have started' },
          { step: 'Prepare Drink', type: 'Activity', dur: '1 min', desc: 'Record that drink preparation has occurred' },
          { step: 'Wait for Drink Ready', type: 'Signal wait', dur: '15 min', desc: 'Suspend until barista marks drink as ready' },
          { step: 'Wait for Collection', type: 'Signal wait', dur: '60 min', desc: 'Suspend until customer collects their drink' },
          { step: 'Complete Order', type: 'Activity', dur: '1 min', desc: 'Finalise the order after collection' },
        ] as row}
          <tr class="border-b border-secondary-200 dark:border-secondary-700">
            <td class="px-4 py-2 font-medium text-secondary-800 dark:text-white">{row.step}</td>
            <td class="px-4 py-2">
              <Badge color={row.type === 'Signal wait' ? 'blue' : 'dark'} class="text-xs">{row.type}</Badge>
            </td>
            <td class="px-4 py-2">{row.dur}</td>
            <td class="px-4 py-2">{row.desc}</td>
          </tr>
        {/each}
      </tbody>
    </table>
  </div>
</details>

<!-- Step metadata modal -->
<Modal bind:open={stepModalOpen} title={selectedStep?.label ?? ''} size="md">
  {#if selectedStep}
    <div class="space-y-4">
      <!-- Domain layer -->
      <div class="rounded-lg bg-green-50 p-3 dark:bg-green-900/20">
        <p class="text-xs font-semibold uppercase tracking-wider text-green-700 dark:text-green-400">Domain Layer</p>
        <p class="mt-1 text-sm text-secondary-700 dark:text-secondary-300">{selectedStep.domainDoc}</p>
        <p class="mt-1 text-xs text-secondary-400 dark:text-secondary-500">Source: <code>drink-fulfilment.sysml</code></p>
      </div>

      <!-- Orchestration layer (if mapped) -->
      {#if selectedStep.orchestrationStep}
        <div class="rounded-lg bg-blue-50 p-3 dark:bg-blue-900/20">
          <p class="text-xs font-semibold uppercase tracking-wider text-blue-700 dark:text-blue-400">Orchestration Layer</p>
          <p class="mt-1 text-sm font-medium text-secondary-700 dark:text-secondary-300">{selectedStep.orchestrationStep}</p>
          <p class="text-sm text-secondary-600 dark:text-secondary-400">{selectedStep.orchestrationDoc}</p>
          {#if selectedStep.signalName}
            <p class="mt-1 text-xs text-secondary-400 dark:text-secondary-500">
              Signal: <code>{selectedStep.signalName}</code> · Timeout: {selectedStep.timeoutMinutes} min
            </p>
          {/if}
          <p class="mt-1 text-xs text-secondary-400 dark:text-secondary-500">Source: <code>fulfil-drink-orchestration.sysml</code></p>
        </div>
      {/if}

      <!-- Clinical analogy -->
      {#if selectedStep.clinicalAnalogy}
        <div class="rounded-lg bg-secondary-50 p-3 dark:bg-secondary-800/50">
          <p class="text-xs font-semibold uppercase tracking-wider text-secondary-500 dark:text-secondary-400">Clinical Analogy</p>
          <p class="mt-1 text-sm text-secondary-600 dark:text-secondary-400 italic">{selectedStep.clinicalAnalogy}</p>
        </div>
      {/if}
    </div>

    <!-- Modal actions — in-body pattern (Flowbite Modal slot="footer" doesn't render) -->
    <div class="mt-4 border-t border-secondary-200 pt-4 dark:border-secondary-700">
      <Button color="alternative" size="sm" onclick={() => stepModalOpen = false}>Close</Button>
    </div>
  {/if}
</Modal>
