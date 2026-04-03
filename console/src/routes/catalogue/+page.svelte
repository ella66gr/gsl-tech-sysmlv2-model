<script lang="ts">
  import { Badge } from 'flowbite-svelte';
  import {
    ChevronDownOutline,
    ChevronRightOutline,
    SearchOutline,
  } from 'flowbite-svelte-icons';
  import type {
    CatalogueElement,
    GroupingAxis,
    GroupingOption,
  } from '$lib/types/catalogue';

  let { data } = $props();

  const catalogue = data.catalogue;
  const allElements = catalogue.elements;
  const facets = catalogue.facets;
  const comprehension = catalogue.comprehension;
  const domainMeta = catalogue.domains;
  const domainKeys = Object.keys(domainMeta);

  // --- Grouping axis options ---
  // Built dynamically: all facet dimensions + synthetic axes (package, domainCoverage).
  const groupingOptions: GroupingOption[] = $derived.by(() => {
    const options: GroupingOption[] = [];

    // Facet-derived axes
    for (const key of Object.keys(facets)) {
      options.push({
        key,
        label: facetDimensionLabel(key),
      });
    }

    // Synthetic axes
    options.push({ key: 'package', label: 'Package' });
    options.push({ key: 'domainCoverage', label: 'Domain Coverage' });

    return options;
  });

  function facetDimensionLabel(key: string): string {
    const labels: Record<string, string> = {
      bmmConcern: 'BMM Concern',
      classification: 'Classification',
    };
    return labels[key] || key;
  }

  // --- State ---
  let groupBy: GroupingAxis = $state('bmmConcern');
  let selectedElement = $state<CatalogueElement | null>(null);
  let searchText = $state('');
  let layerFilter = $state('all');
  let collapsedGroups = $state<Set<string>>(new Set());

  // --- Filtered elements (Chunk 4) ---
  const filteredElements = $derived(
    allElements.filter((elem) => {
      // Layer filter
      if (layerFilter !== 'all' && elem.layer !== layerFilter) return false;

      // Text search
      if (searchText) {
        const s = searchText.toLowerCase();
        const searchable = [
          elem.name,
          elem.userFacing?.friendlyName || '',
          elem.userFacing?.shortDescription || '',
          elem.doc || '',
          ...Object.values(elem.catalogueTag),
        ]
          .join(' ')
          .toLowerCase();
        if (!searchable.includes(s)) return false;
      }

      return true;
    })
  );

  // --- Grouping logic ---
  const groupedElements = $derived.by(() => {
    const groups = new Map<string, CatalogueElement[]>();

    for (const elem of filteredElements) {
      let groupKey: string;

      if (groupBy === 'package') {
        groupKey = elem.package || '(ungrouped)';
      } else if (groupBy === 'domainCoverage') {
        const count = Object.keys(elem.domains).length;
        groupKey = `${count} domain${count !== 1 ? 's' : ''}`;
      } else {
        // Facet-based grouping
        groupKey = elem.catalogueTag[groupBy] || '(untagged)';
      }

      if (!groups.has(groupKey)) {
        groups.set(groupKey, []);
      }
      groups.get(groupKey)!.push(elem);
    }

    // Sort groups by key, with special handling for domainCoverage (descending)
    const sorted = new Map(
      [...groups.entries()].sort((a, b) => {
        if (groupBy === 'domainCoverage') {
          // Sort descending by domain count
          return b[0].localeCompare(a[0]);
        }
        return a[0].localeCompare(b[0]);
      })
    );

    // Sort elements within each group alphabetically by display name
    for (const [key, elems] of sorted) {
      elems.sort((a, b) => {
        const aName = a.userFacing?.friendlyName || a.name;
        const bName = b.userFacing?.friendlyName || b.name;
        return aName.localeCompare(bName);
      });
    }

    return sorted;
  });

  // --- Stats ---
  const stats = $derived({
    total: allElements.length,
    filtered: filteredElements.length,
    groupCount: groupedElements.size,
    comprehensionCoverage: comprehension.coveragePercent,
    withDescriptions: comprehension.userFacingCount,
  });

  // --- Helpers ---
  function toggleGroup(key: string) {
    const next = new Set(collapsedGroups);
    if (next.has(key)) {
      next.delete(key);
    } else {
      next.add(key);
    }
    collapsedGroups = next;
  }

  function expandAll() {
    collapsedGroups = new Set();
  }

  function collapseAll() {
    collapsedGroups = new Set(groupedElements.keys());
  }

  const allExpanded = $derived(collapsedGroups.size === 0);
  const allCollapsed = $derived(collapsedGroups.size === groupedElements.size && groupedElements.size > 0);

  function selectElement(elem: CatalogueElement) {
    selectedElement = elem;
  }

  function domainCount(elem: CatalogueElement): number {
    return Object.keys(elem.domains).length;
  }

  function totalInstances(elem: CatalogueElement): number {
    return Object.values(elem.domains).reduce((sum, instances) => sum + instances.length, 0);
  }

  function displayName(elem: CatalogueElement): string {
    return elem.userFacing?.friendlyName || elem.name;
  }

  function concernBadgeColor(concern: string): string {
    const colors: Record<string, string> = {
      ServiceConcept: 'blue',
      ActivityModel: 'green',
      ResourceCapability: 'purple',
      FinancialModel: 'yellow',
      Governance: 'red',
      StakeholderModel: 'indigo',
    };
    return colors[concern] || 'dark';
  }
</script>

<div class="space-y-4">
  <!-- Header -->
  <div>
    <h1 class="text-2xl font-bold text-secondary-800 dark:text-white">Component Catalogue</h1>
    <p class="mt-1 text-secondary-500 dark:text-secondary-300">
      {stats.total} catalogue elements — {stats.withDescriptions} of {stats.total} with descriptions ({stats.comprehensionCoverage}%)
    </p>
  </div>

  <!-- Controls row -->
  <div class="flex flex-wrap items-end gap-3">
    <!-- Group by -->
    <div class="w-48">
      <label for="group-by" class="mb-1 block text-xs font-medium text-secondary-600 dark:text-secondary-400">Group by</label>
      <select
        id="group-by"
        bind:value={groupBy}
        class="block w-full rounded-lg border border-secondary-300 bg-white px-3 py-2 text-sm text-secondary-700 focus:border-primary-500 focus:ring-primary-500 dark:border-secondary-600 dark:bg-secondary-800 dark:text-secondary-200"
      >
        {#each groupingOptions as opt}
          <option value={opt.key}>{opt.label}</option>
        {/each}
      </select>
    </div>

    <!-- Layer filter -->
    <div class="w-48">
      <label for="layer-filter" class="mb-1 block text-xs font-medium text-secondary-600 dark:text-secondary-400">Meta Model Layer</label>
      <select
        id="layer-filter"
        bind:value={layerFilter}
        class="block w-full rounded-lg border border-secondary-300 bg-white px-3 py-2 text-sm text-secondary-700 focus:border-primary-500 focus:ring-primary-500 dark:border-secondary-600 dark:bg-secondary-800 dark:text-secondary-200"
      >
        <option value="all">All layers</option>
        <option value="bmm">Business Meta Model</option>
        <option value="smm">System Meta Model</option>
      </select>
    </div>

    <!-- Search -->
    <div class="w-64">
      <label for="search" class="mb-1 block text-xs font-medium text-secondary-600 dark:text-secondary-400">Search</label>
      <div class="relative">
        <SearchOutline class="absolute left-3 top-2.5 h-4 w-4 text-secondary-400" />
        <input
          id="search"
          type="text"
          bind:value={searchText}
          placeholder="Filter by name, description, tag..."
          class="block w-full rounded-lg border border-secondary-300 bg-white py-2 pl-9 pr-3 text-sm text-secondary-700 focus:border-primary-500 focus:ring-primary-500 dark:border-secondary-600 dark:bg-secondary-800 dark:text-secondary-200 dark:placeholder-secondary-400"
        />
      </div>
    </div>

    <!-- Count -->
    <div class="text-sm text-secondary-500 dark:text-secondary-400">
      Showing {stats.filtered} of {stats.total}
    </div>
  </div>

  <!-- Two-panel layout -->
  <div class="flex gap-4">
    <!-- Left panel: Grouped element list -->
    <div class="w-96 shrink-0 rounded-lg border border-secondary-200 bg-white dark:border-secondary-700 dark:bg-secondary-900" style="max-height: 72vh; display: flex; flex-direction: column;">
      <!-- Expand / Collapse controls (pinned) -->
      <div class="flex shrink-0 items-center justify-between border-b border-secondary-100 px-3 py-1.5 dark:border-secondary-700">
        <span class="text-xs text-secondary-400 dark:text-secondary-500">{stats.groupCount} groups</span>
        <div class="flex gap-1">
          <button
            onclick={expandAll}
            disabled={allExpanded}
            class="rounded px-2 py-0.5 text-xs transition
              {allExpanded
                ? 'text-secondary-300 dark:text-secondary-600'
                : 'text-secondary-500 hover:bg-secondary-100 hover:text-secondary-700 dark:text-secondary-400 dark:hover:bg-secondary-800 dark:hover:text-secondary-200'}"
          >
            Expand all
          </button>
          <span class="text-secondary-200 dark:text-secondary-700">|</span>
          <button
            onclick={collapseAll}
            disabled={allCollapsed}
            class="rounded px-2 py-0.5 text-xs transition
              {allCollapsed
                ? 'text-secondary-300 dark:text-secondary-600'
                : 'text-secondary-500 hover:bg-secondary-100 hover:text-secondary-700 dark:text-secondary-400 dark:hover:bg-secondary-800 dark:hover:text-secondary-200'}"
          >
            Collapse all
          </button>
        </div>
      </div>
      <div class="overflow-y-auto p-2">
        {#each [...groupedElements] as [groupKey, elements] (groupKey)}
          <!-- Group header -->
          <button
            onclick={() => toggleGroup(groupKey)}
            class="mt-1 flex w-full items-center justify-between rounded-md px-3 py-2 text-left text-sm font-semibold transition hover:bg-secondary-100 dark:hover:bg-secondary-800"
          >
            <span class="flex items-center gap-2">
              {#if collapsedGroups.has(groupKey)}
                <ChevronRightOutline class="h-3 w-3 text-secondary-400" />
              {:else}
                <ChevronDownOutline class="h-3 w-3 text-secondary-400" />
              {/if}
              <span class="text-secondary-700 dark:text-secondary-200">{groupKey}</span>
            </span>
            <span class="rounded-full bg-secondary-100 px-2 py-0.5 text-xs font-normal text-secondary-500 dark:bg-secondary-800 dark:text-secondary-400">
              {elements.length}
            </span>
          </button>

          <!-- Elements in group -->
          {#if !collapsedGroups.has(groupKey)}
            <div class="mb-2 ml-2">
              {#each elements as elem (elem.name)}
                <button
                  onclick={() => selectElement(elem)}
                  class="flex w-full items-center justify-between rounded-md px-3 py-2 text-left text-sm transition
                    {selectedElement?.name === elem.name
                      ? 'bg-primary-100 text-primary-800 dark:bg-primary-900/30 dark:text-primary-300'
                      : 'text-secondary-700 hover:bg-secondary-50 dark:text-secondary-300 dark:hover:bg-secondary-800/50'}"
                >
                  <div class="min-w-0 flex-1">
                    <div class="truncate font-medium">
                      {displayName(elem)}
                    </div>
                    {#if elem.userFacing && elem.userFacing.friendlyName !== elem.name}
                      <div class="truncate text-xs text-secondary-400 dark:text-secondary-500">
                        {elem.name}
                      </div>
                    {/if}
                  </div>
                  <!-- Domain count dots -->
                  <div class="ml-2 flex shrink-0 gap-0.5">
                    {#each domainKeys as dk}
                      <span
                        class="inline-block h-2 w-2 rounded-full {elem.domains[dk] && elem.domains[dk].length > 0
                          ? 'bg-green-400 dark:bg-green-500'
                          : 'bg-secondary-200 dark:bg-secondary-700'}"
                        title="{domainMeta[dk]?.label || dk}: {elem.domains[dk]?.length || 0} instances"
                      ></span>
                    {/each}
                  </div>
                </button>
              {/each}
            </div>
          {/if}
        {/each}

        {#if groupedElements.size === 0}
          <div class="px-3 py-8 text-center text-sm text-secondary-400 dark:text-secondary-500">
            No elements match the current filters.
          </div>
        {/if}
      </div>
    </div>

    <!-- Right panel: Element detail -->
    <div class="min-h-96 flex-1 overflow-y-auto rounded-lg border border-secondary-200 bg-white dark:border-secondary-700 dark:bg-secondary-900" style="max-height: 72vh;">
      {#if selectedElement}
        {@const elem = selectedElement}
        <div class="p-5 space-y-5">
          <!-- Name and comprehension -->
          <div>
            {#if elem.userFacing}
              <h2 class="text-xl font-semibold text-secondary-800 dark:text-white">
                {elem.userFacing.friendlyName}
              </h2>
              <p class="mt-0.5 text-sm font-mono text-secondary-400 dark:text-secondary-500">
                {elem.name}
              </p>
            {:else}
              <h2 class="text-xl font-semibold text-secondary-800 dark:text-white">
                {elem.name}
              </h2>
              <p class="mt-1 text-xs italic text-secondary-400 dark:text-secondary-500">
                No description available — add @UserFacing metadata to this element
              </p>
            {/if}
          </div>

          <!-- Short description -->
          {#if elem.userFacing?.shortDescription}
            <p class="text-sm leading-relaxed text-secondary-600 dark:text-secondary-300">
              {elem.userFacing.shortDescription}
            </p>
          {/if}

          <!-- Tags -->
          <div>
            <h3 class="mb-2 text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-500">
              Tags
            </h3>
            <div class="flex flex-wrap gap-2">
              {#each Object.entries(elem.catalogueTag) as [dimension, value]}
                <div class="flex items-center gap-1">
                  <span class="text-xs text-secondary-400 dark:text-secondary-500">{facetDimensionLabel(dimension)}:</span>
                  <Badge color={dimension === 'bmmConcern' ? concernBadgeColor(value) : 'none'} class="text-xs {dimension !== 'bmmConcern' ? 'bg-secondary-200 text-secondary-700 dark:bg-secondary-600 dark:text-secondary-200' : ''}">
                    {value}
                  </Badge>
                </div>
              {/each}
              <div class="flex items-center gap-1">
                <span class="text-xs text-secondary-400 dark:text-secondary-500">Layer:</span>
                <Badge color={elem.layer === 'bmm' ? 'blue' : 'purple'} class="text-xs">
                  {elem.layer === 'bmm' ? 'BMM' : 'SMM'}
                </Badge>
              </div>
            </div>
          </div>

          <!-- BFO ontological grounding -->
          {#if elem.bfoType}
            {@const midLevel = elem.bfoType.midLevelClass || ''}
            {@const midParts = midLevel.includes(':') ? midLevel.split(':') : ['', midLevel]}
            <div>
              <h3 class="mb-2 text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-500">
                Ontological Grounding
              </h3>
              <div class="flex items-baseline gap-2 rounded-md border border-purple-100 bg-purple-50/30 px-3 py-2 dark:border-purple-900/30 dark:bg-purple-900/10">
                <span class="text-sm text-secondary-700 dark:text-secondary-300">
                  BFO: <span class="font-medium">{elem.bfoType.bfoClass}</span>
                  {#if midLevel}
                    <span class="mx-1 text-secondary-300 dark:text-secondary-600">→</span>
                    {#if midParts[0]}<span class="text-secondary-500 dark:text-secondary-400">{midParts[0]}:</span>{/if}<span class="font-medium">{midParts[1] || midLevel}</span>
                  {/if}
                </span>
              </div>
            </div>
          {/if}

          <!-- Cross-domain instantiation -->
          <div>
            <h3 class="mb-2 text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-500">
              Domain Instances ({totalInstances(elem)} across {domainCount(elem)} domain{domainCount(elem) !== 1 ? 's' : ''})
            </h3>
            {#each domainKeys as dk}
              {@const instances = elem.domains[dk]}
              {#if instances && instances.length > 0}
                <div class="mb-2">
                  <div class="mb-1 flex items-center gap-2">
                    <span class="text-xs font-medium text-secondary-600 dark:text-secondary-300">
                      {domainMeta[dk]?.label || dk}
                    </span>
                    <span class="rounded-full bg-green-100 px-1.5 py-0.5 text-xs text-green-700 dark:bg-green-900/30 dark:text-green-400">
                      {instances.length}
                    </span>
                  </div>
                  <div class="ml-3 space-y-0.5">
                    {#each instances as inst}
                      <div class="text-xs text-secondary-500 dark:text-secondary-400">
                        <span class="font-medium text-secondary-700 dark:text-secondary-300">{inst.name}</span>
                        <span class="text-secondary-400 dark:text-secondary-500"> in {inst.package}</span>
                      </div>
                    {/each}
                  </div>
                </div>
              {:else}
                <div class="mb-2">
                  <div class="flex items-center gap-2">
                    <span class="text-xs text-secondary-400 dark:text-secondary-500">
                      {domainMeta[dk]?.label || dk}
                    </span>
                    <span class="text-xs text-secondary-300 dark:text-secondary-600">—</span>
                  </div>
                </div>
              {/if}
            {/each}
          </div>

          <!-- Doc block -->
          {#if elem.doc}
            <div>
              <h3 class="mb-2 text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-500">
                Doc Block
              </h3>
              <div class="rounded-md border border-secondary-100 bg-secondary-50/50 p-3 text-xs leading-relaxed whitespace-pre-line text-secondary-600 dark:border-secondary-700 dark:bg-secondary-800/50 dark:text-secondary-400">
                {elem.doc}
              </div>
            </div>
          {/if}

          <!-- Cross-link to coverage matrix -->
          <div class="pt-2">
            <a
              href="/coverage?search={encodeURIComponent(elem.name)}"
              class="inline-flex items-center gap-1 rounded-md border border-primary-200 bg-primary-50 px-3 py-1.5 text-xs font-medium text-primary-700 transition hover:bg-primary-100 dark:border-primary-800 dark:bg-primary-900/20 dark:text-primary-400 dark:hover:bg-primary-900/40"
            >
              View in Coverage Matrix →
            </a>
          </div>
        </div>
      {:else}
        <div class="flex h-full items-center justify-center p-8 text-secondary-400 dark:text-secondary-500">
          <p>Select an element from the left to see its detail</p>
        </div>
      {/if}
    </div>
  </div>

  <!-- Footer -->
  <p class="text-xs text-secondary-400 dark:text-secondary-500">
    Generated {new Date(catalogue.generatedAt).toLocaleString()} by {catalogue.generator}
  </p>
</div>
