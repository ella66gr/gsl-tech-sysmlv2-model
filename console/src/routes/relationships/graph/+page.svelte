<script lang="ts">
  import { getContext } from 'svelte';
  import RelationshipGraph3D from '$lib/components/RelationshipGraph3D.svelte';
  import type { WeightedRelationshipGraph } from '$lib/types/relationships';
  import type { ComprehensionContent, CatalogueElement } from '$lib/types/catalogue';
  import { getConcernColour } from '$lib/utils/colours';
  import { ArrowRightOutline, CloseOutline } from 'flowbite-svelte-icons';

  let { data } = $props();

  const graph: WeightedRelationshipGraph = data.graph;
  const comprehensionContent: Record<string, ComprehensionContent> = data.comprehensionContent;
  const glossaryEntries: CatalogueElement[] = data.glossaryEntries;

  const filters: { concernFilter: string; strengthFilter: string; searchText: string } =
    getContext('relationships-filters');

  // Side panel state
  let selectedNodeId = $state<string | null>(null);

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
    selectedNodeId = selectedNodeId === nodeId ? null : nodeId;
  }

  function closePanel() {
    selectedNodeId = null;
  }
</script>

<div class="relative flex gap-4">
  <!-- Graph area -->
  <div class="min-h-[600px] flex-1">
    <RelationshipGraph3D
      {graph}
      concernFilter={filters.concernFilter}
      strengthFilter={filters.strengthFilter}
      searchText={filters.searchText}
      {selectedNodeId}
      onNodeSelect={onNodeClick}
    />
  </div>

  <!-- Side panel -->
  {#if selectedEntry && selectedNode}
    <div class="w-80 shrink-0 overflow-y-auto rounded-lg border border-secondary-200 bg-white p-4 shadow-lg dark:border-secondary-700 dark:bg-secondary-900">
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
            href="/glossary"
            class="inline-flex items-center gap-1 rounded-md border border-primary-200 bg-primary-50 px-3 py-1.5 text-xs font-medium text-primary-700 transition hover:bg-primary-100 dark:border-primary-800 dark:bg-primary-900/20 dark:text-primary-400 dark:hover:bg-primary-900/40"
          >
            View in Glossary <ArrowRightOutline class="h-3 w-3" />
          </a>
        </div>
      </div>
    </div>
  {/if}
</div>
