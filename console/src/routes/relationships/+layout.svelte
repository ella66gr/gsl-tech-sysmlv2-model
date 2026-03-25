<script lang="ts">
  import { page } from '$app/stores';
  import { setContext } from 'svelte';
  import { SearchOutline } from 'flowbite-svelte-icons';
  import type { WeightedRelationshipGraph } from '$lib/types/relationships';

  let { data, children } = $props();

  const graph: WeightedRelationshipGraph = data.graph;

  // --- Filter state (shared between graph and table via context) ---
  let concernFilter = $state('all');
  let strengthFilter = $state('all');
  let searchText = $state('');

  // Derive unique concern values from node data
  const concernValues = $derived(
    [...new Set(graph.nodes.map((n) => n.bmmConcern))].sort()
  );

  // Active tab derived from URL
  const currentPath = $derived($page.url.pathname);
  const isGraphTab = $derived(currentPath.endsWith('/graph') || currentPath === '/relationships');
  const isTableTab = $derived(currentPath.endsWith('/table'));

  // Expose filter state to children via context
  setContext('relationships-filters', {
    get concernFilter() { return concernFilter; },
    get strengthFilter() { return strengthFilter; },
    get searchText() { return searchText; },
  });
</script>

<div class="space-y-4">
  <!-- Header -->
  <div>
    <h1 class="text-2xl font-bold text-secondary-800 dark:text-white">Relationships</h1>
    <p class="mt-1 text-secondary-500 dark:text-secondary-300">
      {graph.stats.nodeCount} elements, {graph.stats.edgeCount} weighted relationships
      ({graph.stats.bidirectionalPairCount} bidirectional pairs)
    </p>
  </div>

  <!-- Tab navigation -->
  <div class="flex items-center gap-6 border-b border-secondary-200 dark:border-secondary-700">
    <a
      href="/relationships/graph"
      class="inline-block border-b-2 px-1 pb-3 text-sm font-medium transition
        {isGraphTab
          ? 'border-primary-500 text-primary-600 dark:border-primary-400 dark:text-primary-400'
          : 'border-transparent text-secondary-500 hover:border-secondary-300 hover:text-secondary-700 dark:text-secondary-400 dark:hover:border-secondary-500 dark:hover:text-secondary-300'}"
    >
      Graph
    </a>
    <a
      href="/relationships/table"
      class="inline-block border-b-2 px-1 pb-3 text-sm font-medium transition
        {isTableTab
          ? 'border-primary-500 text-primary-600 dark:border-primary-400 dark:text-primary-400'
          : 'border-transparent text-secondary-500 hover:border-secondary-300 hover:text-secondary-700 dark:text-secondary-400 dark:hover:border-secondary-500 dark:hover:text-secondary-300'}"
    >
      Table
    </a>
  </div>

  <!-- Filter controls -->
  <div class="flex flex-wrap items-end gap-3">
    <!-- Search -->
    <div class="w-64">
      <label for="rel-search" class="mb-1 block text-xs font-medium text-secondary-600 dark:text-secondary-400">Search</label>
      <div class="relative">
        <SearchOutline class="absolute left-3 top-2.5 h-4 w-4 text-secondary-400" />
        <input
          id="rel-search"
          type="text"
          bind:value={searchText}
          placeholder="Filter by name..."
          class="block w-full rounded-lg border border-secondary-300 bg-white py-2 pl-9 pr-3 text-sm text-secondary-700 focus:border-primary-500 focus:ring-primary-500 dark:border-secondary-600 dark:bg-secondary-800 dark:text-secondary-200 dark:placeholder-secondary-400"
        />
      </div>
    </div>

    <!-- BMM Concern filter -->
    <div class="w-48">
      <label for="rel-concern" class="mb-1 block text-xs font-medium text-secondary-600 dark:text-secondary-400">BMM Concern</label>
      <select
        id="rel-concern"
        bind:value={concernFilter}
        class="block w-full rounded-lg border border-secondary-300 bg-white px-3 py-2 text-sm text-secondary-700 focus:border-primary-500 focus:ring-primary-500 dark:border-secondary-600 dark:bg-secondary-800 dark:text-secondary-200"
      >
        <option value="all">All concerns</option>
        {#each concernValues as concern}
          <option value={concern}>{concern}</option>
        {/each}
      </select>
    </div>

    <!-- Strength filter -->
    <div class="w-40">
      <label for="rel-strength" class="mb-1 block text-xs font-medium text-secondary-600 dark:text-secondary-400">Strength</label>
      <select
        id="rel-strength"
        bind:value={strengthFilter}
        class="block w-full rounded-lg border border-secondary-300 bg-white px-3 py-2 text-sm text-secondary-700 focus:border-primary-500 focus:ring-primary-500 dark:border-secondary-600 dark:bg-secondary-800 dark:text-secondary-200"
      >
        <option value="all">All strengths</option>
        <option value="strong">Strong</option>
        <option value="moderate">Moderate</option>
        <option value="weak">Weak</option>
      </select>
    </div>
  </div>

  <!-- Child route content -->
  {@render children()}
</div>
