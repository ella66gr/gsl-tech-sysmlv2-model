<script lang="ts">
  import { onMount } from 'svelte';
  import { page } from '$app/stores';
  import { setContext } from 'svelte';
  import { SearchOutline } from 'flowbite-svelte-icons';
  import type { WeightedRelationshipGraph } from '$lib/types/relationships';
  import { getConcernColour } from '$lib/utils/colours';
  import { useNavigation } from '$lib/stores/navigation.svelte';

  let { data, children } = $props();

  const graph: WeightedRelationshipGraph = data.graph;

  const navStore = useNavigation();

  // --- Filter state (shared between graph and table via context) ---
  // Initialise from URL search params (restored after browser Back navigation)
  function initFromUrl() {
    const params = new URLSearchParams(window.location.search);
    const concerns = params.get('concerns');
    const strengths = params.get('strengths');
    const search = params.get('q');
    return {
      concerns: concerns ? new Set(concerns.split(',')) : new Set<string>(),
      strengths: strengths ? new Set(strengths.split(',')) : new Set<string>(),
      search: search || '',
    };
  }

  const initial = typeof window !== 'undefined' ? initFromUrl() : { concerns: new Set<string>(), strengths: new Set<string>(), search: '' };
  let selectedConcerns = $state<Set<string>>(initial.concerns);
  let selectedStrengths = $state<Set<string>>(initial.strengths);
  let searchText = $state(initial.search);

  function syncToUrl() {
    if (typeof window === 'undefined') return;
    const params = new URLSearchParams(window.location.search);

    if (selectedConcerns.size > 0) {
      params.set('concerns', [...selectedConcerns].sort().join(','));
    } else {
      params.delete('concerns');
    }

    if (selectedStrengths.size > 0) {
      params.set('strengths', [...selectedStrengths].sort().join(','));
    } else {
      params.delete('strengths');
    }

    if (searchText) {
      params.set('q', searchText);
    } else {
      params.delete('q');
    }

    const qs = params.toString();
    const newUrl = `${window.location.pathname}${qs ? '?' + qs : ''}`;
    history.replaceState(history.state, '', newUrl);
  }

  // Derive unique concern values from node data
  const concernValues = $derived(
    [...new Set(graph.nodes.map((n) => n.bmmConcern))].sort()
  );

  const strengthValues: { value: string; label: string }[] = [
    { value: 'strong', label: 'Strong' },
    { value: 'moderate', label: 'Moderate' },
    { value: 'weak', label: 'Weak' },
  ];

  // Active tab derived from URL
  const currentPath = $derived($page.url.pathname);
  const isGraphTab = $derived(currentPath.endsWith('/graph') || currentPath === '/relationships');
  const isTableTab = $derived(currentPath.endsWith('/table'));

  function toggleConcern(concern: string) {
    const next = new Set(selectedConcerns);
    if (next.has(concern)) {
      next.delete(concern);
    } else {
      next.add(concern);
    }
    selectedConcerns = next;
  }

  function toggleStrength(strength: string) {
    const next = new Set(selectedStrengths);
    if (next.has(strength)) {
      next.delete(strength);
    } else {
      next.add(strength);
    }
    selectedStrengths = next;
  }

  function clearFilters() {
    selectedConcerns = new Set();
    selectedStrengths = new Set();
    searchText = '';
  }

  const hasActiveFilters = $derived(
    selectedConcerns.size > 0 || selectedStrengths.size > 0 || searchText.length > 0
  );

  // Sync filter state to URL whenever it changes
  $effect(() => {
    selectedConcerns;
    selectedStrengths;
    searchText;
    syncToUrl();
  });

  // Expose filter state and syncToUrl to children via context
  setContext('relationships-filters', {
    get selectedConcerns() { return selectedConcerns; },
    get selectedStrengths() { return selectedStrengths; },
    get searchText() { return searchText; },
    syncToUrl,
  });

  onMount(() => {
    navStore.register({
      captureState: () => ({
        selectedConcerns: [...selectedConcerns],
        selectedStrengths: [...selectedStrengths],
        searchText,
        currentTab: currentPath.endsWith('/table') ? 'table' : 'graph',
        scrollY: window.scrollY,
      }),
      restoreState: (state) => {
        selectedConcerns = new Set(state.selectedConcerns as string[]);
        selectedStrengths = new Set(state.selectedStrengths as string[]);
        searchText = state.searchText as string;
        requestAnimationFrame(() => window.scrollTo(0, state.scrollY as number));
      },
    });

    navStore.refineCurrentLabel('Relationships');
  });
</script>

<div class="flex h-[calc(100dvh-6rem)] flex-col gap-3 overflow-hidden">
  <!-- Header -->
  <div>
    <h1 class="text-2xl font-bold text-secondary-800 dark:text-white">Business Model Concept Relationships</h1>
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
  <div class="space-y-3">
    <!-- Top row: search + clear -->
    <div class="flex items-end gap-3">
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

      {#if hasActiveFilters}
        <button
          onclick={clearFilters}
          class="rounded-lg border border-secondary-300 px-3 py-2 text-xs font-medium text-secondary-600 transition hover:bg-secondary-100 dark:border-secondary-600 dark:text-secondary-400 dark:hover:bg-secondary-800"
        >
          Clear all
        </button>
      {/if}
    </div>

    <!-- BMM Concern pills -->
    <div class="flex flex-wrap items-center gap-2">
      <span class="text-xs font-medium text-secondary-500 dark:text-secondary-400">Concern</span>
      {#each concernValues as concern}
        {@const isActive = selectedConcerns.has(concern)}
        <button
          onclick={() => toggleConcern(concern)}
          class="rounded-full px-3 py-1 text-xs font-medium transition"
          style={isActive
            ? `background-color: ${getConcernColour(concern)}; color: white;`
            : `background-color: transparent; color: ${getConcernColour(concern)}; border: 1px solid ${getConcernColour(concern)}40;`}
        >
          {concern}
        </button>
      {/each}
    </div>

    <!-- Strength pills -->
    <div class="flex flex-wrap items-center gap-2">
      <span class="text-xs font-medium text-secondary-500 dark:text-secondary-400">Strength</span>
      {#each strengthValues as { value, label }}
        {@const isActive = selectedStrengths.has(value)}
        <button
          onclick={() => toggleStrength(value)}
          class="rounded-full border px-3 py-1 text-xs font-medium transition
            {isActive
              ? 'border-secondary-500 bg-secondary-600 text-white dark:border-secondary-400 dark:bg-secondary-500'
              : 'border-secondary-300 text-secondary-500 hover:border-secondary-400 dark:border-secondary-600 dark:text-secondary-400 dark:hover:border-secondary-500'}"
        >
          {label}
        </button>
      {/each}
    </div>
  </div>

  <!-- Child route content -->
  {@render children()}
</div>
