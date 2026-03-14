<script lang="ts">
  import { page } from '$app/state';
  import { onMount } from 'svelte';
  import { Badge, Button, Alert, Spinner } from 'flowbite-svelte';
  import { anonymiseCaseRef } from '@coffeeshop/shared/dist/workflow-constants.js';

  // ── Types ──

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

  // ── Lifecycle step configuration ──

  const LIFECYCLE_STEPS = [
    { key: 'placed',        label: 'Placed',          icon: '📝' },
    { key: 'inPreparation', label: 'In Preparation',   icon: '☕' },
    { key: 'ready',         label: 'Ready',            icon: '✅' },
    { key: 'collected',     label: 'Collected',        icon: '🎉' },
  ];

  const STATE_ORDER: Record<string, number> = {
    placed: 0,
    inPreparation: 1,
    ready: 2,
    collected: 3,
    cancelled: -1,
  };

  const STATE_ACTIONS: Record<string, { signal: string; label: string } | null> = {
    placed:        { signal: 'baristaStarted', label: 'Barista: Start Preparation' },
    inPreparation: { signal: 'drinkReady',     label: 'Barista: Mark Ready' },
    ready:         { signal: 'drinkCollected',  label: 'Customer: Collect Drink' },
    collected:     null,
    cancelled:     null,
  };

  const STATE_LABELS: Record<string, string> = {
    placed:        'Placed',
    inPreparation: 'In Preparation',
    ready:         'Ready for Collection',
    collected:     'Collected',
    cancelled:     'Cancelled',
    unknown:       'Unknown',
  };

  const STATE_COLORS: Record<string, 'blue' | 'yellow' | 'green' | 'dark' | 'red'> = {
    placed:        'blue',
    inPreparation: 'yellow',
    ready:         'green',
    collected:     'dark',
    cancelled:     'red',
    unknown:       'dark',
  };

  const COMPLIANCE_CONFIG: Record<string, { label: string; color: 'green' | 'yellow' | 'dark' | 'blue' }> = {
    within_target: { label: '✓ On time',  color: 'green' },
    exceeded:      { label: '⚠ Exceeded', color: 'yellow' },
    no_target:     { label: '—',          color: 'dark' },
    pending:       { label: '…',          color: 'blue' },
  };

  // ── State ──

  let orderId = $derived(page.params.id ?? '');
  let orderState = $state<OrderState | null>(null);
  let auditReport = $state<AuditReport | null>(null);
  let auditError = $state(false);
  let loading = $state(true);
  let errorMessage = $state('');
  let signalSending = $state(false);
  let pollInterval: ReturnType<typeof setInterval> | null = null;

  // ── Derived ──

  let currentState = $derived(orderState?.state ?? 'unknown');
  let currentStateIndex = $derived(STATE_ORDER[currentState] ?? -1);
  let isCancelled = $derived(currentState === 'cancelled');
  let isTerminal = $derived(
    currentState === 'collected' ||
    currentState === 'cancelled' ||
    orderState?.workflowStatus === 'COMPLETED'
  );
  let action = $derived(STATE_ACTIONS[currentState] ?? null);
  let stateLabel = $derived(STATE_LABELS[currentState] ?? currentState);
  let stateColor = $derived(STATE_COLORS[currentState] ?? 'dark');
  let caseRef = $derived(auditReport?.caseRef ?? anonymiseCaseRef(orderId));

  // ── Data fetching ──

  async function fetchOrderData() {
    if (!orderId) return;
    try {
      const [stateRes, auditRes] = await Promise.all([
        fetch(`/api/orders/${orderId}`),
        fetch(`/api/orders/${orderId}/audit`).catch(() => null),
      ]);

      if (stateRes.ok) {
        orderState = await stateRes.json();
      } else {
        const data = await stateRes.json().catch(() => ({}));
        errorMessage = data.message || `Error: ${stateRes.status}`;
      }

      if (auditRes && auditRes.ok) {
        auditReport = await auditRes.json();
        auditError = false;
      } else {
        auditError = true;
      }

      // Stop polling if terminal
      if (isTerminal && pollInterval) {
        clearInterval(pollInterval);
        pollInterval = null;
      }
    } catch (err) {
      errorMessage = err instanceof Error ? err.message : 'Failed to load order data';
    } finally {
      loading = false;
    }
  }

  // ── Signal action ──

  async function handleSignal(signalName: string) {
    signalSending = true;
    errorMessage = '';
    try {
      const response = await fetch(`/api/orders/${orderId}/signal`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ signal: signalName }),
      });
      if (!response.ok) {
        const data = await response.json();
        errorMessage = data.message || `Signal failed: ${response.status}`;
        return;
      }
      // Refresh data after signal
      await fetchOrderData();
    } catch (err) {
      errorMessage = err instanceof Error ? err.message : 'Failed to send signal';
    } finally {
      signalSending = false;
    }
  }

  // ── Helpers ──

  function formatTimestamp(iso: string | null): string {
    if (!iso) return '—';
    return new Date(iso).toLocaleTimeString();
  }

  function formatTimestampFull(iso: string | null): string {
    if (!iso) return '—';
    return new Date(iso).toLocaleString();
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

  // ── Lifecycle ──

  onMount(() => {
    fetchOrderData();
    pollInterval = setInterval(fetchOrderData, 3000);
    return () => { if (pollInterval) clearInterval(pollInterval); };
  });
</script>

<!-- Page Header -->
<div class="mb-6">
  <h1 class="text-2xl font-bold text-secondary-800 dark:text-white">
    Order {caseRef}
  </h1>
  <div class="flex gap-3 text-sm">
    <a href="/orders" class="text-primary-600 hover:underline dark:text-primary-400">&larr; Order Board</a>
    <a href="/" class="text-primary-600 hover:underline dark:text-primary-400">Counter</a>
    {#if orderState?.workflowStatus === 'COMPLETED'}
      <a href="/orders/{orderId}/audit" class="text-primary-600 hover:underline dark:text-primary-400">Full Audit</a>
    {/if}
  </div>
</div>

{#if loading}
  <div class="flex items-center gap-2 text-secondary-500">
    <Spinner size="5" /> Loading order…
  </div>
{:else if errorMessage && !orderState}
  <Alert color="red" class="mb-4">
    <span class="font-medium">Error:</span> {errorMessage}
  </Alert>
{:else if orderState}

  {#if errorMessage}
    <Alert color="red" class="mb-4">
      <span class="font-medium">Error:</span> {errorMessage}
    </Alert>
  {/if}

  <!-- Main layout: state machine + summary card -->
  <div class="mb-6 flex flex-col gap-6 lg:flex-row">

    <!-- Left panel: state machine visual + action button -->
    <div class="min-w-0 flex-1">

      <!-- Cancelled alert -->
      {#if isCancelled}
        <Alert color="red" class="mb-4">
          This order was cancelled.
        </Alert>
      {/if}

      <!-- State machine visual -->
      <div class="mb-6 rounded-lg border border-secondary-200 bg-white p-4 dark:border-secondary-700 dark:bg-secondary-800">
        <h2 class="mb-4 text-sm font-semibold text-secondary-600 dark:text-secondary-400">Order Lifecycle</h2>

        <div class="flex items-center justify-between gap-1 sm:gap-2">
          {#each LIFECYCLE_STEPS as step, i}
            {@const isCompleted = !isCancelled && i < currentStateIndex}
            {@const isCurrent = !isCancelled && i === currentStateIndex}
            {@const isFuture = !isCancelled && i > currentStateIndex}

            <!-- Step node -->
            <div class="flex flex-col items-center gap-1">
              <div class="flex h-10 w-10 items-center justify-center rounded-full text-lg
                {isCompleted ? 'bg-green-500 text-white' : ''}
                {isCurrent ? 'bg-primary-500 text-white ring-4 ring-primary-200 dark:ring-primary-800' : ''}
                {isFuture ? 'bg-secondary-200 text-secondary-400 dark:bg-secondary-700 dark:text-secondary-500' : ''}
                {isCancelled ? 'bg-secondary-200 text-secondary-400 dark:bg-secondary-700 dark:text-secondary-500' : ''}"
              >
                {isCompleted ? '✓' : step.icon}
              </div>
              <span class="text-center text-xs font-medium
                {isCurrent ? 'text-primary-700 dark:text-primary-300' : 'text-secondary-500 dark:text-secondary-400'}">
                {step.label}
              </span>
            </div>

            <!-- Connector line -->
            {#if i < LIFECYCLE_STEPS.length - 1}
              <div class="h-0.5 flex-1
                {!isCancelled && i < currentStateIndex ? 'bg-green-500' : 'bg-secondary-200 dark:bg-secondary-700'}">
              </div>
            {/if}
          {/each}
        </div>
      </div>

      <!-- Action button -->
      <div class="mb-6">
        {#if action}
          <Button color="primary" onclick={() => action && handleSignal(action.signal)} disabled={signalSending}>
            {signalSending ? 'Sending…' : action.label}
          </Button>
        {:else if isTerminal}
          <p class="text-sm text-secondary-500 dark:text-secondary-400">
            Order complete. No further actions available.
          </p>
        {:else}
          <p class="text-sm italic text-secondary-400">Waiting for state update…</p>
        {/if}
      </div>
    </div>

    <!-- Right panel: order summary card -->
    <div class="w-full shrink-0 lg:w-80">
      <div class="rounded-lg border border-secondary-200 bg-white p-4 dark:border-secondary-700 dark:bg-secondary-800">
        <h3 class="mb-3 text-sm font-semibold text-secondary-600 dark:text-secondary-400">Order Summary</h3>
        <div class="space-y-2 text-sm">
          <div class="flex justify-between">
            <span class="text-secondary-500 dark:text-secondary-400">Case Ref</span>
            <code class="text-xs">{caseRef}</code>
          </div>
          <div class="flex justify-between">
            <span class="text-secondary-500 dark:text-secondary-400">Status</span>
            <Badge color={stateColor}>{stateLabel}</Badge>
          </div>
          <div class="flex justify-between">
            <span class="text-secondary-500 dark:text-secondary-400">Workflow</span>
            <span class="text-xs">{orderState.workflowStatus}</span>
          </div>
          <div class="flex justify-between">
            <span class="text-secondary-500 dark:text-secondary-400">Started</span>
            <span class="text-xs">{formatTimestampFull(auditReport?.startTime ?? null)}</span>
          </div>
          {#if auditReport?.endTime}
            <div class="flex justify-between">
              <span class="text-secondary-500 dark:text-secondary-400">Completed</span>
              <span class="text-xs">{formatTimestampFull(auditReport.endTime)}</span>
            </div>
          {:else if !isTerminal}
            <div class="flex justify-between">
              <span class="text-secondary-500 dark:text-secondary-400">Elapsed</span>
              <span class="text-xs">{timeElapsed(auditReport?.startTime ?? null)}</span>
            </div>
          {/if}
        </div>
      </div>
    </div>
  </div>

  <!-- Event Timeline -->
  {#if auditReport}
    <div class="mb-6">
      <h2 class="mb-4 text-lg font-semibold text-secondary-800 dark:text-white">Event Timeline</h2>

      <div class="relative ml-4 border-l-2 border-secondary-200 pl-6 dark:border-secondary-700">
        {#each auditReport.steps as step}
          {@const isComplete = step.startTime && step.endTime}
          {@const isActive = step.startTime && !step.endTime}
          {@const isPending = !step.startTime}

          <div class="relative mb-6 last:mb-0">
            <!-- Timeline dot -->
            <div class="absolute -left-[31px] top-0.5 h-4 w-4 rounded-full border-2
              {isComplete ? 'border-green-500 bg-green-500' : ''}
              {isActive ? 'border-primary-500 bg-primary-500 animate-pulse' : ''}
              {isPending ? 'border-secondary-300 bg-white dark:border-secondary-600 dark:bg-secondary-800' : ''}">
            </div>

            <!-- Step content -->
            <div class="flex flex-col gap-1">
              <div class="flex flex-wrap items-center gap-2">
                <span class="font-medium text-secondary-800 dark:text-white">{step.label}</span>
                <Badge color={step.type === 'signal' ? 'blue' : 'dark'} class="text-xs">
                  {step.type === 'signal' ? 'Wait' : 'Activity'}
                </Badge>
                {#if isComplete}
                  {@const compCfg = COMPLIANCE_CONFIG[step.compliance]}
                  {#if compCfg}
                    <Badge color={compCfg.color} class="text-xs">{compCfg.label}</Badge>
                  {/if}
                {/if}
              </div>

              <div class="text-xs text-secondary-500 dark:text-secondary-400">
                {#if isComplete}
                  {formatTimestamp(step.startTime)} → {formatTimestamp(step.endTime)}
                  · {formatDuration(step.durationSeconds)}
                  {#if step.expectedMinutes !== null}
                    <span class="text-secondary-400 dark:text-secondary-500">(target: {formatExpected(step.expectedMinutes)})</span>
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
  {:else if auditError && !loading}
    <Alert color="yellow" class="mb-4">
      Audit timeline not yet available. It will appear once the order has history events.
    </Alert>
  {/if}

  <!-- Governance note -->
  <div class="rounded-lg border border-secondary-200 bg-secondary-50 p-4 text-sm dark:border-secondary-700 dark:bg-secondary-800/50">
    <p class="mb-2 text-secondary-600 dark:text-secondary-400">
      <strong>Governance:</strong> This order follows the
      <a href="/pathway" class="text-primary-600 hover:underline dark:text-primary-400">FulfilDrink process model</a>,
      generated from the SysML v2 model. Timing targets from model annotations.
    </p>
    {#if orderState.workflowStatus === 'COMPLETED'}
      <p class="text-secondary-600 dark:text-secondary-400">
        <a href="/orders/{orderId}/audit" class="text-primary-600 hover:underline dark:text-primary-400">
          View full compliance audit report →
        </a>
      </p>
    {/if}
    <p class="mt-2 text-xs text-secondary-400 dark:text-secondary-500">
      CDR records for this order type are available in
      <a href="/entity" class="text-primary-600 hover:underline dark:text-primary-400">Records</a>.
      ·
      <a href="http://localhost:8233/namespaces/default/workflows/{orderId}" target="_blank" class="hover:underline">
        Temporal Web UI →
      </a>
    </p>
  </div>

{/if}
