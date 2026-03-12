<script lang="ts">
  import { Card, Badge, Table, TableHead, TableHeadCell, TableBody, TableBodyRow, TableBodyCell } from 'flowbite-svelte';
</script>

<div class="mb-6">
  <h1 class="text-2xl font-bold text-secondary-800 dark:text-white">Process Model</h1>
  <p class="text-sm text-secondary-500 dark:text-secondary-400">
    Drink fulfilment pathway generated from the SysML v2 domain action flow.
  </p>
</div>

<Card class="mb-6">
  <p class="mb-3 text-sm text-secondary-600 dark:text-secondary-400">
    This diagram is generated from the SysML v2 domain action flow (<code class="text-xs">FulfilDrink</code>)
    by <code class="text-xs">gen_mermaid_pathway.py</code>. It shows the process steps a non-technical reviewer
    would inspect to understand the defined pathway.
  </p>
  <p class="text-xs text-secondary-400">
    Source: <code>coffeeshop-exercise/model/domain/drink-fulfilment.sysml</code>
    → <code>generated/fulfil-drink-pathway.svg</code>
  </p>
</Card>

<div class="mb-6 rounded-lg border border-secondary-200 bg-white p-4 dark:border-secondary-700 dark:bg-secondary-800">
  <img
    src="/fulfil-drink-pathway.svg"
    alt="Drink fulfilment pathway diagram generated from SysML v2 model"
    class="h-auto max-w-full"
  />
</div>

<h2 class="mb-3 text-lg font-semibold text-secondary-700 dark:text-secondary-300">Orchestration Workflow Steps</h2>
<p class="mb-4 text-sm text-secondary-500 dark:text-secondary-400">
  Each step maps to the domain pathway above. The orchestration-level workflow defines
  activity boundaries, signal waits, and timeout points.
</p>

<Table striped={true}>
  <TableHead>
    <TableHeadCell>Step</TableHeadCell>
    <TableHeadCell>Type</TableHeadCell>
    <TableHeadCell>Expected Max Duration</TableHeadCell>
    <TableHeadCell>Description</TableHeadCell>
  </TableHead>
  <TableBody>
    {#each [
      { step: 'Validate Order', type: 'Activity', dur: '1 min', desc: 'Validate order details before processing' },
      { step: 'Wait for Barista', type: 'Signal wait', dur: '30 min', desc: 'Suspend until a barista signals they have started' },
      { step: 'Prepare Drink', type: 'Activity', dur: '1 min', desc: 'Record that drink preparation has occurred' },
      { step: 'Wait for Drink Ready', type: 'Signal wait', dur: '15 min', desc: 'Suspend until barista marks drink as ready' },
      { step: 'Wait for Collection', type: 'Signal wait', dur: '60 min', desc: 'Suspend until customer collects their drink' },
      { step: 'Complete Order', type: 'Activity', dur: '1 min', desc: 'Finalise the order after collection' },
    ] as row}
      <TableBodyRow>
        <TableBodyCell class="font-medium">{row.step}</TableBodyCell>
        <TableBodyCell>
          <Badge color={row.type === 'Signal wait' ? 'blue' : 'dark'}>{row.type}</Badge>
        </TableBodyCell>
        <TableBodyCell>{row.dur}</TableBodyCell>
        <TableBodyCell class="text-sm text-secondary-500 dark:text-secondary-400">{row.desc}</TableBodyCell>
      </TableBodyRow>
    {/each}
  </TableBody>
</Table>
