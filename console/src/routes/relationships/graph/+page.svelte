<script lang="ts">
  import { getContext } from 'svelte';
  import RelationshipGraph3D from '$lib/components/RelationshipGraph3D.svelte';
  import type { WeightedRelationshipGraph } from '$lib/types/relationships';
  import type { ComprehensionContent, CatalogueElement } from '$lib/types/catalogue';
  import { getConcernColour } from '$lib/utils/colours';
  import { ArrowRightOutline, CloseOutline, InfoCircleOutline } from 'flowbite-svelte-icons';

  let { data } = $props();

  const graph: WeightedRelationshipGraph = data.graph;
  const comprehensionContent: Record<string, ComprehensionContent> = data.comprehensionContent;
  const glossaryEntries: CatalogueElement[] = data.glossaryEntries;

  const filters: {
    selectedConcerns: Set<string>;
    selectedStrengths: Set<string>;
    searchText: string;
    syncToUrl: () => void;
  } = getContext('relationships-filters');

  // Side panel state — restore from URL if present (survives browser Back)
  function initGraphState() {
    if (typeof window === 'undefined') return { nodeId: null as string | null, panelVisible: false };
    const params = new URLSearchParams(window.location.search);
    const nodeId = params.get('node') || null;
    return { nodeId, panelVisible: !!nodeId };
  }

  const initialGraph = initGraphState();
  let selectedNodeId = $state<string | null>(initialGraph.nodeId);
  let panelVisible = $state(initialGraph.panelVisible);

  function syncGraphToUrl() {
    if (typeof window === 'undefined') return;
    const params = new URLSearchParams(window.location.search);
    if (selectedNodeId) {
      params.set('node', selectedNodeId);
    } else {
      params.delete('node');
    }
    const qs = params.toString();
    const newUrl = `${window.location.pathname}${qs ? '?' + qs : ''}`;
    history.replaceState(history.state, '', newUrl);
  }

  $effect(() => {
    selectedNodeId;
    syncGraphToUrl();
  });

  const selectedEntry = $derived(
    selectedNodeId ? glossaryEntries.find((e) => e.name === selectedNodeId) : null
  );
  const selectedComprehension = $derived(
    selectedNodeId ? comprehensionContent[selectedNodeId] : null
  );
  const selectedNode = $derived(
    selectedNodeId ? graph.nodes.find((n) => n.id === selectedNodeId) : null
  );

  function onNodeClick(nodeId: string) {
    if (selectedNodeId === nodeId) {
      // Toggle off: deselect and hide
      selectedNodeId = null;
      panelVisible = false;
    } else {
      // Select and auto-open
      selectedNodeId = nodeId;
      panelVisible = true;
    }
  }

  function closePanel() {
    panelVisible = false;
  }

  function togglePanel() {
    if (selectedNodeId) {
      panelVisible = !panelVisible;
    }
  }

  // Panel transparency (20–100%, default 85)
  let panelOpacity = $state(85);

  const isDark = $derived(
    typeof document !== 'undefined' && document.documentElement.classList.contains('dark')
  );
  const panelBgStyle = $derived(
    isDark
      ? `background-color: rgba(15, 23, 42, ${panelOpacity / 100})`
      : `background-color: rgba(255, 255, 255, ${panelOpacity / 100})`
  );
</script>

<div class="relative min-h-0 flex-1">
  <!-- Graph area — full width, panel overlays on top -->
  <div class="h-full">
    <RelationshipGraph3D
      {graph}
      selectedConcerns={filters.selectedConcerns}
      selectedStrengths={filters.selectedStrengths}
      searchText={filters.searchText}
      {selectedNodeId}
      onNodeSelect={onNodeClick}
      {panelOpacity}
    />
  </div>

  <!-- Info panel toggle button — always visible when a node is selected -->
  <!-- Panel opacity slider -->
  <div
    class="absolute right-3 z-20 flex items-center gap-1.5 rounded-md bg-white/80 px-2 py-1.5 shadow-sm ring-1 ring-secondary-200 backdrop-blur-sm dark:bg-secondary-800/80 dark:ring-secondary-700"
    style="top: {selectedNodeId ? '6.5rem' : '3.5rem'};"
  >
    <svg class="h-3 w-3 text-secondary-400" viewBox="0 0 16 16" fill="currentColor">
      <rect x="1" y="1" width="14" height="14" rx="2" opacity="0.3"/>
    </svg>
    <input
      type="range"
      min="5"
      max="100"
      bind:value={panelOpacity}
      class="h-1 w-16 cursor-pointer appearance-none rounded-full bg-secondary-300 accent-secondary-500 dark:bg-secondary-600 dark:accent-secondary-400"
      title="Panel transparency: {panelOpacity}%"
    />
    <svg class="h-3 w-3 text-secondary-400" viewBox="0 0 16 16" fill="currentColor">
      <rect x="1" y="1" width="14" height="14" rx="2"/>
    </svg>
  </div>

  {#if selectedNodeId}
    <button
      onclick={togglePanel}
      class="absolute right-3 top-14 z-20 rounded-md bg-white/80 p-2 text-secondary-600 shadow-sm ring-1 ring-secondary-200 backdrop-blur-sm transition hover:bg-white hover:text-secondary-800 dark:bg-secondary-800/80 dark:text-secondary-300 dark:ring-secondary-700 dark:hover:bg-secondary-800 dark:hover:text-white"
      title={panelVisible ? 'Hide info panel' : 'Show info panel'}
    >
      <InfoCircleOutline class="h-4 w-4" />
      {#if !panelVisible}
        <span class="absolute -right-0.5 -top-0.5 h-2.5 w-2.5 rounded-full bg-primary-500 ring-2 ring-white dark:ring-secondary-900"></span>
      {/if}
    </button>
  {/if}

  <!-- Side panel overlay -->
  {#if panelVisible && selectedEntry && selectedNode}
    <div class="side-panel-scroll absolute right-3 top-36 z-20 w-80 max-h-[calc(100%-10rem)] overflow-y-auto rounded-lg border border-secondary-200 p-4 shadow-lg backdrop-blur-sm dark:border-secondary-700"
      style={panelBgStyle}>
      <!-- Header -->
      <div class="mb-3 flex items-start justify-between">
        <div>
          <h3 class="text-lg font-semibold text-secondary-800 dark:text-white">
            {selectedEntry.userFacing?.friendlyName || selectedEntry.name}
          </h3>
          <span
            class="mt-1 inline-block rounded px-2 py-0.5 text-xs font-medium text-white"
            style="background-color: {getConcernColour(selectedNode.bmmConcern)}"
          >
            {selectedNode.bmmConcern}
          </span>
        </div>
        <button
          onclick={closePanel}
          class="rounded p-1 text-secondary-400 hover:bg-secondary-100 hover:text-secondary-600 dark:hover:bg-secondary-800 dark:hover:text-secondary-300"
          aria-label="Close panel"
        >
          <CloseOutline class="h-4 w-4" />
        </button>
      </div>

      <div class="space-y-3">
        <!-- Short description -->
        {#if selectedEntry.userFacing?.shortDescription}
          <p class="text-sm leading-relaxed text-secondary-700 dark:text-secondary-300">
            {selectedEntry.userFacing.shortDescription}
          </p>
        {/if}

        <!-- Purposive description -->
        {#if selectedEntry.purposiveDescription?.description}
          <div>
            <h4 class="mb-1 text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-500">
              What this means for your service
            </h4>
            <p class="text-sm leading-relaxed text-secondary-600 dark:text-secondary-400">
              {selectedEntry.purposiveDescription.description}
            </p>
          </div>
        {/if}

        <!-- Related concepts from comprehension -->
        {#if selectedComprehension?.relatedConcepts && selectedComprehension.relatedConcepts.length > 0}
          <div>
            <h4 class="mb-1 text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-500">
              Related concepts
            </h4>
            <div class="space-y-1">
              {#each selectedComprehension.relatedConcepts as rc}
                <div class="flex items-center gap-2 text-sm">
                  {#if rc.strength}
                    <span class="text-xs text-secondary-400">{rc.strength}</span>
                  {/if}
                  <span class="text-secondary-700 dark:text-secondary-300">
                    {rc.friendlyName || rc.name}
                  </span>
                </div>
              {/each}
            </div>
          </div>
        {/if}

        <!-- Glossary link -->
        <div class="pt-2">
          <a
            href="/glossary?entry={encodeURIComponent(selectedNodeId || '')}"
            class="inline-flex items-center gap-1 rounded-md border border-primary-200 bg-primary-50 px-3 py-1.5 text-xs font-medium text-primary-700 transition hover:bg-primary-100 dark:border-primary-800 dark:bg-primary-900/20 dark:text-primary-400 dark:hover:bg-primary-900/40"
          >
            View in Glossary <ArrowRightOutline class="h-3 w-3" />
          </a>
        </div>
      </div>
    </div>
  {/if}
</div>

<style>
  /* Custom scrollbar for the side panel */
  :global(.side-panel-scroll::-webkit-scrollbar) {
    width: 6px;
  }
  :global(.side-panel-scroll::-webkit-scrollbar-track) {
    background: rgba(148, 163, 184, 0.15);
    border-radius: 3px;
  }
  :global(.side-panel-scroll::-webkit-scrollbar-thumb) {
    background: rgba(148, 163, 184, 0.4);
    border-radius: 3px;
  }
  :global(.side-panel-scroll::-webkit-scrollbar-thumb:hover) {
    background: rgba(148, 163, 184, 0.6);
  }
</style>
