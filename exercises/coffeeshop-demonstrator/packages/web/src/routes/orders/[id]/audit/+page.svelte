<script lang="ts">
  import { page } from '$app/state';
  import { onMount } from 'svelte';
  import { Card, Badge, Alert, Spinner, Table, TableHead, TableHeadCell, TableBody, TableBodyRow, TableBodyCell } from 'flowbite-svelte';

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

  const COMPLIANCE_CONFIG: Record<string, { label: string; color: 'green' | 'yellow' | 'dark' | 'blue' }> = {
    within_target: { label: 'Within target', color: 'green' },
    exceeded: { label: 'Exceeded', color: 'yellow' },
    no_target: { label: '—', color: 'dark' },
    pending: { label: 'Pending', color: 'blue' },
  };

  let orderId = $derived(page.params.id ?? '');
  let report = $state<AuditReport | null>(null);
  let loading = $state(true);
  let errorMessage = $state('');

  function formatTimestamp(iso: string | null): string {
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
    return `${minutes} min`;
  }

  async function fetchAudit() {
    if (!orderId) return;
    try {
      const response = await fetch(`/api/orders/${orderId}/audit`);
      if (!response.ok) {
        const data = await response.json();
        errorMessage = data.message || `Error: ${response.status}`;
        return;
      }
      report = await response.json();
    } catch (err) {
      errorMessage = err instanceof Error ? err.message : 'Failed to fetch audit report';
    } finally {
      loading = false;
    }
  }

  onMount(() => { fetchAudit(); });
</script>

<div class="mb-4">
  <h1 class="text-2xl font-bold text-secondary-800 dark:text-white">Audit Report</h1>
  <div class="flex gap-3 text-sm">
    <a href="/orders/{orderId}" class="text-primary-600 hover:underline dark:text-primary-400">&larr; Order status</a>
    <a href="/orders" class="text-primary-600 hover:underline dark:text-primary-400">All orders</a>
  </div>
</div>

{#if loading}
  <div class="flex items-center gap-2 text-secondary-500">
    <Spinner size="5" /> Loading audit report…
  </div>
{:else if errorMessage}
  <Alert color="red" class="mb-4">
    <span class="font-medium">Error:</span> {errorMessage}
  </Alert>
  <p class="text-sm text-secondary-500">
    The audit report is only available for workflows with execution history.
  </p>
{:else if report}
  <Card class="mb-6 max-w-3xl">
    <div class="grid grid-cols-2 gap-3 text-sm">
      <span class="text-secondary-500 dark:text-secondary-400">Case Reference</span>
      <code>{report.caseRef}</code>
      <span class="text-secondary-500 dark:text-secondary-400">Workflow Status</span>
      <span>{report.workflowStatus}</span>
      <span class="text-secondary-500 dark:text-secondary-400">Process Started</span>
      <span>{formatTimestamp(report.startTime)}</span>
      <span class="text-secondary-500 dark:text-secondary-400">Process Completed</span>
      <span>{formatTimestamp(report.endTime)}</span>
    </div>
  </Card>

  <div class="max-w-5xl">
    <h2 class="mb-2 text-lg font-semibold text-secondary-700 dark:text-secondary-300">Compliance Table</h2>
    <p class="mb-3 text-xs text-secondary-400">
      Expected timings from SysML model annotations. Actual timings from Temporal execution history.
    </p>

    <Table striped={true}>
      <TableHead>
        <TableHeadCell>Step</TableHeadCell>
        <TableHeadCell>Type</TableHeadCell>
        <TableHeadCell>Started</TableHeadCell>
        <TableHeadCell>Completed</TableHeadCell>
        <TableHeadCell>Duration</TableHeadCell>
        <TableHeadCell>Expected</TableHeadCell>
        <TableHeadCell>Compliance</TableHeadCell>
      </TableHead>
      <TableBody>
        {#each report.steps as step}
          <TableBodyRow>
            <TableBodyCell class="font-medium">{step.label}</TableBodyCell>
            <TableBodyCell>
              <Badge color={step.type === 'signal' ? 'blue' : 'dark'}>{step.type === 'signal' ? 'Signal wait' : 'Activity'}</Badge>
            </TableBodyCell>
            <TableBodyCell class="text-xs">{formatTimestamp(step.startTime)}</TableBodyCell>
            <TableBodyCell class="text-xs">{formatTimestamp(step.endTime)}</TableBodyCell>
            <TableBodyCell>{formatDuration(step.durationSeconds)}</TableBodyCell>
            <TableBodyCell>{formatExpected(step.expectedMinutes)}</TableBodyCell>
            <TableBodyCell>
              {@const cfg = COMPLIANCE_CONFIG[step.compliance]}
              {#if cfg}
                <Badge color={cfg.color}>{cfg.label}</Badge>
              {:else}
                <Badge color="dark">{step.compliance}</Badge>
              {/if}
            </TableBodyCell>
          </TableBodyRow>
        {/each}
      </TableBody>
    </Table>
  </div>

  <div class="mt-6 max-w-3xl rounded-lg border border-secondary-200 bg-secondary-50 p-4 text-sm text-secondary-600 dark:border-secondary-700 dark:bg-secondary-800 dark:text-secondary-400">
    <p class="mb-2"><strong>Governance note:</strong> This report is generated from the Temporal workflow execution history for case <code>{report.caseRef}</code>.</p>
    <p>The process definition is generated from the SysML v2 model — see the <a href="/pathway" class="text-primary-600 hover:underline dark:text-primary-400">pathway diagram</a>.</p>
  </div>

  <p class="mt-4 text-xs text-secondary-400">
    Temporal Web UI: <a href="http://localhost:8233/namespaces/default/workflows/{report.workflowId}" target="_blank" class="hover:underline">View raw execution history</a>
  </p>
{/if}
