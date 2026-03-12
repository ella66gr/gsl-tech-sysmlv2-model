<script lang="ts">
  import { onMount } from 'svelte';
  import { Badge, Button, Spinner, Alert, Table, TableHead, TableHeadCell, TableBody, TableBodyRow, TableBodyCell } from 'flowbite-svelte';

  interface WorkflowSummary {
    workflowId: string;
    caseRef: string;
    status: string;
    startTime: string | null;
    closeTime: string | null;
  }

  const STATUS_CONFIG: Record<string, { label: string; color: 'green' | 'yellow' | 'red' | 'dark' | 'blue' }> = {
    RUNNING: { label: 'Running', color: 'green' },
    COMPLETED: { label: 'Completed', color: 'blue' },
    FAILED: { label: 'Failed', color: 'red' },
    CANCELLED: { label: 'Cancelled', color: 'dark' },
    TERMINATED: { label: 'Terminated', color: 'red' },
    TIMED_OUT: { label: 'Timed out', color: 'yellow' },
  };

  let workflows = $state<WorkflowSummary[]>([]);
  let loading = $state(true);
  let errorMessage = $state('');

  function formatTimestamp(iso: string | null): string {
    if (!iso) return '—';
    return new Date(iso).toLocaleString();
  }

  async function fetchOrders() {
    try {
      const response = await fetch('/api/orders/list');
      if (!response.ok) {
        const data = await response.json();
        errorMessage = data.message || `Error: ${response.status}`;
        return;
      }
      const data = await response.json();
      workflows = data.workflows;
    } catch (err) {
      errorMessage = err instanceof Error ? err.message : 'Failed to fetch orders';
    } finally {
      loading = false;
    }
  }

  onMount(() => { fetchOrders(); });
</script>

<div class="mb-6">
  <h1 class="text-2xl font-bold text-secondary-800 dark:text-white">Order Board</h1>
  <p class="text-sm text-secondary-500 dark:text-secondary-400">
    All orders from Temporal workflow history.
    <a href="/" class="text-primary-600 hover:underline dark:text-primary-400">Place a new order</a>
  </p>
</div>

{#if loading}
  <div class="flex items-center gap-2 text-secondary-500">
    <Spinner size="5" /> Loading orders…
  </div>
{:else if errorMessage}
  <Alert color="red">
    <span class="font-medium">Error:</span> {errorMessage}
  </Alert>
{:else if workflows.length === 0}
  <Alert color="blue">
    No orders found. <a href="/" class="font-medium underline">Place a new order</a> to get started.
  </Alert>
{:else}
  <p class="mb-3 text-sm text-secondary-500 dark:text-secondary-400">
    {workflows.length} order{workflows.length !== 1 ? 's' : ''} found.
  </p>

  <Table striped={true}>
    <TableHead>
      <TableHeadCell>Case Ref</TableHeadCell>
      <TableHeadCell>Status</TableHeadCell>
      <TableHeadCell>Started</TableHeadCell>
      <TableHeadCell>Completed</TableHeadCell>
      <TableHeadCell>Actions</TableHeadCell>
    </TableHead>
    <TableBody>
      {#each workflows as wf}
        <TableBodyRow>
          <TableBodyCell>
            <code class="text-sm">{wf.caseRef}</code>
          </TableBodyCell>
          <TableBodyCell>
            {@const cfg = STATUS_CONFIG[wf.status]}
            {#if cfg}
              <Badge color={cfg.color}>{cfg.label}</Badge>
            {:else}
              <Badge color="dark">{wf.status}</Badge>
            {/if}
          </TableBodyCell>
          <TableBodyCell class="text-xs">{formatTimestamp(wf.startTime)}</TableBodyCell>
          <TableBodyCell class="text-xs">{formatTimestamp(wf.closeTime)}</TableBodyCell>
          <TableBodyCell>
            <a href="/orders/{wf.workflowId}" class="text-primary-600 hover:underline dark:text-primary-400">Status</a>
            {#if wf.status === 'COMPLETED'}
              <span class="mx-1 text-secondary-300">|</span>
              <a href="/orders/{wf.workflowId}/audit" class="text-primary-600 hover:underline dark:text-primary-400">Audit</a>
            {/if}
          </TableBodyCell>
        </TableBodyRow>
      {/each}
    </TableBody>
  </Table>
{/if}
