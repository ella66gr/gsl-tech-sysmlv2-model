<script lang="ts">
  import { Badge, Tooltip } from 'flowbite-svelte';
  import { EditOutline, ChevronSortOutline } from 'flowbite-svelte-icons';
  import type { WeightedRelationshipGraph, GraphEdge } from '$lib/types/relationships';
  import { getConcernBadgeColour, getStrengthBadgeColour } from '$lib/utils/colours';

  interface Props {
    graph: WeightedRelationshipGraph;
    selectedConcerns: Set<string>;
    selectedStrengths: Set<string>;
    searchText: string;
  }

  let { graph, selectedConcerns, selectedStrengths, searchText }: Props = $props();

  // Build a node lookup for friendly names and concerns
  const nodeMap = $derived(new Map(graph.nodes.map((n) => [n.id, n])));

  // Enriched rows
  interface TableRow {
    source: string;
    sourceName: string;
    target: string;
    targetName: string;
    strength: GraphEdge['strength'];
    rationale: string;
    sourceConcern: string;
  }

  const allRows: TableRow[] = $derived(
    graph.edges.map((e) => ({
      source: e.source,
      sourceName: nodeMap.get(e.source)?.friendlyName || e.source,
      target: e.target,
      targetName: nodeMap.get(e.target)?.friendlyName || e.target,
      strength: e.strength,
      rationale: e.rationale,
      sourceConcern: nodeMap.get(e.source)?.bmmConcern || '',
    }))
  );

  // Sorting
  type SortKey = 'sourceName' | 'targetName' | 'strength' | 'sourceConcern';
  let sortKey = $state<SortKey | null>(null);
  let sortDir = $state<'asc' | 'desc'>('asc');

  function toggleSort(key: SortKey) {
    if (sortKey === key) {
      if (sortDir === 'asc') {
        sortDir = 'desc';
      } else {
        sortKey = null;
        sortDir = 'asc';
      }
    } else {
      sortKey = key;
      sortDir = 'asc';
    }
  }

  const strengthOrder: Record<string, number> = { strong: 0, moderate: 1, weak: 2, contextual: 3 };

  // Filtered and sorted rows
  const filteredRows = $derived.by(() => {
    let rows = allRows;

    // Concern filter — empty set means show all
    if (selectedConcerns.size > 0) {
      rows = rows.filter((r) => selectedConcerns.has(r.sourceConcern));
    }

    // Strength filter — empty set means show all
    if (selectedStrengths.size > 0) {
      rows = rows.filter((r) => selectedStrengths.has(r.strength));
    }

    // Text search
    if (searchText) {
      const s = searchText.toLowerCase();
      rows = rows.filter((r) =>
        r.sourceName.toLowerCase().includes(s) ||
        r.targetName.toLowerCase().includes(s) ||
        r.rationale.toLowerCase().includes(s)
      );
    }

    // Sort
    if (sortKey) {
      const key = sortKey;
      const dir = sortDir === 'asc' ? 1 : -1;
      rows = [...rows].sort((a, b) => {
        if (key === 'strength') {
          return dir * ((strengthOrder[a.strength] || 99) - (strengthOrder[b.strength] || 99));
        }
        return dir * a[key].localeCompare(b[key]);
      });
    }

    return rows;
  });

  // Rationale expansion
  let expandedRows = $state<Set<number>>(new Set());
  function toggleRationale(idx: number) {
    const next = new Set(expandedRows);
    if (next.has(idx)) { next.delete(idx); } else { next.add(idx); }
    expandedRows = next;
  }

  function truncate(text: string, maxLen = 80): string {
    if (text.length <= maxLen) return text;
    return text.slice(0, maxLen).trimEnd() + '...';
  }

  function sortIndicator(key: SortKey): string {
    if (sortKey !== key) return '';
    return sortDir === 'asc' ? ' \u25B2' : ' \u25BC';
  }
</script>

<div class="space-y-3">
  <!-- Header with config mode toggle -->
  <div class="flex items-center justify-between">
    <p class="text-sm text-secondary-500 dark:text-secondary-400">
      Showing {filteredRows.length} of {allRows.length} relationships
    </p>
    <div class="relative">
      <button
        disabled
        class="inline-flex cursor-not-allowed items-center gap-1.5 rounded-lg border border-secondary-300 bg-secondary-100 px-3 py-1.5 text-xs font-medium text-secondary-400 dark:border-secondary-600 dark:bg-secondary-800 dark:text-secondary-500"
        id="config-mode-btn"
      >
        <EditOutline class="h-3.5 w-3.5" />
        Configuration Mode
      </button>
      <Tooltip triggeredBy="#config-mode-btn" placement="top">Coming soon</Tooltip>
    </div>
  </div>

  <!-- Table -->
  <div class="overflow-x-auto rounded-lg border border-secondary-200 dark:border-secondary-700">
    <table class="w-full text-left text-sm">
      <thead class="bg-secondary-50 text-xs uppercase text-secondary-600 dark:bg-secondary-800 dark:text-secondary-400">
        <tr>
          <th class="cursor-pointer select-none px-4 py-3 hover:text-secondary-800 dark:hover:text-secondary-200" onclick={() => toggleSort('sourceName')}>
            <span class="inline-flex items-center gap-1">Source <ChevronSortOutline class="h-3 w-3" />{sortIndicator('sourceName')}</span>
          </th>
          <th class="cursor-pointer select-none px-4 py-3 hover:text-secondary-800 dark:hover:text-secondary-200" onclick={() => toggleSort('targetName')}>
            <span class="inline-flex items-center gap-1">Target <ChevronSortOutline class="h-3 w-3" />{sortIndicator('targetName')}</span>
          </th>
          <th class="cursor-pointer select-none px-4 py-3 hover:text-secondary-800 dark:hover:text-secondary-200" onclick={() => toggleSort('strength')}>
            <span class="inline-flex items-center gap-1">Strength <ChevronSortOutline class="h-3 w-3" />{sortIndicator('strength')}</span>
          </th>
          <th class="cursor-pointer select-none px-4 py-3 hover:text-secondary-800 dark:hover:text-secondary-200" onclick={() => toggleSort('sourceConcern')}>
            <span class="inline-flex items-center gap-1">BMM Concern <ChevronSortOutline class="h-3 w-3" />{sortIndicator('sourceConcern')}</span>
          </th>
          <th class="px-4 py-3">Rationale</th>
        </tr>
      </thead>
      <tbody class="divide-y divide-secondary-200 dark:divide-secondary-700">
        {#each filteredRows as row, idx (idx)}
          <tr class="bg-white transition hover:bg-secondary-50 dark:bg-secondary-900 dark:hover:bg-secondary-800/50">
            <td class="px-4 py-3 font-medium text-secondary-800 dark:text-secondary-200">
              {row.sourceName}
            </td>
            <td class="px-4 py-3 text-secondary-700 dark:text-secondary-300">
              {row.targetName}
            </td>
            <td class="group relative px-4 py-3">
              <div class="inline-flex items-center gap-1.5">
                <Badge color={getStrengthBadgeColour(row.strength)} class="text-xs">
                  {row.strength}
                </Badge>
                <span class="hidden text-secondary-300 group-hover:inline dark:text-secondary-600">
                  <EditOutline class="h-3 w-3" />
                </span>
              </div>
            </td>
            <td class="px-4 py-3">
              <Badge color={getConcernBadgeColour(row.sourceConcern)} class="text-xs">
                {row.sourceConcern}
              </Badge>
            </td>
            <td class="max-w-xs px-4 py-3 text-secondary-600 dark:text-secondary-400">
              {#if row.rationale.length > 80}
                {#if expandedRows.has(idx)}
                  <span>{row.rationale}</span>
                  <button onclick={() => toggleRationale(idx)} class="ml-1 text-primary-500 hover:underline">less</button>
                {:else}
                  <span>{truncate(row.rationale)}</span>
                  <button onclick={() => toggleRationale(idx)} class="ml-1 text-primary-500 hover:underline">more</button>
                {/if}
              {:else}
                {row.rationale}
              {/if}
            </td>
          </tr>
        {/each}
      </tbody>
    </table>
  </div>
</div>
