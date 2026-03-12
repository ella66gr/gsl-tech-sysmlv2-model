<script lang="ts">
  import { page } from '$app/state';
  import { onMount } from 'svelte';
  import { Card, Badge, Button, Alert, Spinner, Table, TableHead, TableHeadCell, TableBody, TableBodyRow, TableBodyCell } from 'flowbite-svelte';

  const STATE_ACTIONS: Record<string, { signal: string; label: string } | null> = {
    placed: { signal: 'baristaStarted', label: 'Barista: Start Preparation' },
    inPreparation: { signal: 'drinkReady', label: 'Barista: Mark Ready' },
    ready: { signal: 'drinkCollected', label: 'Customer: Collect Drink' },
    collected: null,
    cancelled: null,
  };

  const STATE_LABELS: Record<string, string> = {
    placed: 'Placed',
    inPreparation: 'In Preparation',
    ready: 'Ready for Collection',
    collected: 'Collected',
    cancelled: 'Cancelled',
    unknown: 'Unknown',
  };

  const STATE_COLORS: Record<string, 'blue' | 'yellow' | 'green' | 'dark' | 'red'> = {
    placed: 'blue',
    inPreparation: 'yellow',
    ready: 'green',
    collected: 'dark',
    cancelled: 'red',
    unknown: 'dark',
  };

  let orderId = $derived(page.params.id ?? '');
  let currentState = $state('unknown');
  let workflowStatus = $state('unknown');
  let loading = $state(true);
  let signalSending = $state(false);
  let errorMessage = $state('');
  let stateHistory = $state<Array<{ state: string; timestamp: string }>>([]);
  let pollInterval: ReturnType<typeof setInterval> | null = null;

  let action = $derived(STATE_ACTIONS[currentState] ?? null);
  let stateLabel = $derived(STATE_LABELS[currentState] ?? currentState);
  let stateColor = $derived(STATE_COLORS[currentState] ?? 'dark');
  let isTerminal = $derived(
    currentState === 'collected' ||
    currentState === 'cancelled' ||
    workflowStatus === 'COMPLETED'
  );

  async function fetchState() {
    if (!orderId) return;
    try {
      const response = await fetch(`/api/orders/${orderId}`);
      if (!response.ok) {
        const data = await response.json();
        errorMessage = data.message || `Error: ${response.status}`;
        return;
      }
      const data = await response.json();
      const previousState = currentState;
      currentState = data.state;
      workflowStatus = data.workflowStatus;
      if (currentState !== previousState && currentState !== 'unknown' && !stateHistory.some((h) => h.state === currentState)) {
        stateHistory = [...stateHistory, { state: currentState, timestamp: new Date().toLocaleTimeString() }];
      }
      if (isTerminal && pollInterval) { clearInterval(pollInterval); pollInterval = null; }
    } catch (err) {
      errorMessage = err instanceof Error ? err.message : 'Failed to fetch state';
    } finally {
      loading = false;
    }
  }

  async function sendSignal(signalName: string) {
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
        errorMessage = data.message || `Error: ${response.status}`;
        return;
      }
      const data = await response.json();
      currentState = data.state;
      workflowStatus = data.workflowStatus;
      if (!stateHistory.some((h) => h.state === currentState)) {
        stateHistory = [...stateHistory, { state: currentState, timestamp: new Date().toLocaleTimeString() }];
      }
      if (isTerminal) {
        await new Promise((r) => setTimeout(r, 500));
        await fetchState();
        if (pollInterval) { clearInterval(pollInterval); pollInterval = null; }
      }
    } catch (err) {
      errorMessage = err instanceof Error ? err.message : 'Failed to send signal';
    } finally {
      signalSending = false;
    }
  }

  onMount(() => {
    fetchState();
    pollInterval = setInterval(fetchState, 2000);
    return () => { if (pollInterval) clearInterval(pollInterval); };
  });
</script>

<div class="mb-4">
  <h1 class="text-2xl font-bold text-secondary-800 dark:text-white">Order Status</h1>
  <div class="flex gap-3 text-sm">
    <a href="/" class="text-primary-600 hover:underline dark:text-primary-400">&larr; Counter</a>
    <a href="/orders" class="text-primary-600 hover:underline dark:text-primary-400">All orders</a>
  </div>
</div>

{#if loading}
  <div class="flex items-center gap-2 text-secondary-500">
    <Spinner size="5" /> Loading order state…
  </div>
{:else}
  <Card class="mb-4 max-w-2xl">
    <div class="space-y-3">
      <div class="flex items-center justify-between">
        <span class="text-sm text-secondary-500 dark:text-secondary-400">Order ID</span>
        <code class="text-sm">{orderId}</code>
      </div>
      <div class="flex items-center justify-between">
        <span class="text-sm text-secondary-500 dark:text-secondary-400">Current State</span>
        <Badge color={stateColor} large>{stateLabel}</Badge>
      </div>
      <div class="flex items-center justify-between">
        <span class="text-sm text-secondary-500 dark:text-secondary-400">Workflow Status</span>
        <span class="text-sm">{workflowStatus}</span>
      </div>
    </div>
  </Card>

  {#if errorMessage}
    <Alert color="red" class="mb-4 max-w-2xl">
      <span class="font-medium">Error:</span> {errorMessage}
    </Alert>
  {/if}

  <div class="mb-6 max-w-2xl">
    {#if action}
      <Button color="primary" onclick={() => action && sendSignal(action.signal)} disabled={signalSending}>
        {signalSending ? 'Sending…' : action.label}
      </Button>
    {:else if isTerminal}
      <p class="text-sm text-secondary-500 dark:text-secondary-400">
        Order complete. No further actions available.
      </p>
      <a href="/orders/{orderId}/audit" class="mt-2 inline-block text-primary-600 font-medium hover:underline dark:text-primary-400">
        View Audit Report &rarr;
      </a>
    {:else}
      <p class="text-sm text-secondary-400 italic">Waiting for state update…</p>
    {/if}
  </div>

  {#if stateHistory.length > 0}
    <div class="max-w-2xl">
      <h3 class="mb-2 text-lg font-semibold text-secondary-700 dark:text-secondary-300">State History</h3>
      <Table>
        <TableHead>
          <TableHeadCell>Time</TableHeadCell>
          <TableHeadCell>State</TableHeadCell>
        </TableHead>
        <TableBody>
          {#each stateHistory as entry}
            <TableBodyRow>
              <TableBodyCell class="text-sm">{entry.timestamp}</TableBodyCell>
              <TableBodyCell>
                <Badge color={STATE_COLORS[entry.state] ?? 'dark'}>{STATE_LABELS[entry.state] ?? entry.state}</Badge>
              </TableBodyCell>
            </TableBodyRow>
          {/each}
        </TableBody>
      </Table>
    </div>
  {/if}

  <p class="mt-6 text-xs text-secondary-400">
    Temporal Web UI: <a href="http://localhost:8233/namespaces/default/workflows/{orderId}" target="_blank" class="hover:underline">
      View workflow execution
    </a>
  </p>
{/if}
