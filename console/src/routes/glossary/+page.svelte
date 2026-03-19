<script lang="ts">
  import { Badge } from 'flowbite-svelte';
  import {
    ChevronDownOutline,
    ChevronRightOutline,
    SearchOutline,
    ArrowRightOutline,
  } from 'flowbite-svelte-icons';
  import type { CatalogueElement } from '$lib/types/catalogue';

  let { data } = $props();

  const glossary = data.glossary;
  const allEntries = glossary.entries;
  const comprehension = glossary.comprehension;
  const facets = glossary.facets;
  const domainMeta = glossary.domains;
  const domainKeys = Object.keys(domainMeta);

  // --- State ---
  let searchText = $state('');
  let concernFilter = $state('all');
  let layerFilter = $state('all');
  let expandedEntries = $state<Set<string>>(new Set());

  // --- Concern values from facets ---
  const concernValues = $derived(facets.bmmConcern?.values || []);

  // --- Filtered and sorted entries ---
  const filteredEntries = $derived.by(() => {
    let result = allEntries.filter((entry) => {
      // Layer filter
      if (layerFilter !== 'all' && entry.layer !== layerFilter) return false;

      // Concern filter
      if (concernFilter !== 'all' && entry.catalogueTag.bmmConcern !== concernFilter) return false;

      // Text search
      if (searchText) {
        const s = searchText.toLowerCase();
        const searchable = [
          entry.name,
          entry.userFacing?.friendlyName || '',
          entry.userFacing?.shortDescription || '',
          entry.doc || '',
        ]
          .join(' ')
          .toLowerCase();
        if (!searchable.includes(s)) return false;
      }

      return true;
    });

    // Sort alphabetically by friendly name
    result.sort((a, b) => {
      const aName = a.userFacing?.friendlyName || a.name;
      const bName = b.userFacing?.friendlyName || b.name;
      return aName.localeCompare(bName);
    });

    return result;
  });

  // --- Stats ---
  const stats = $derived({
    showing: filteredEntries.length,
    total: allEntries.length,
    catalogueTotal: comprehension.catalogueTaggedCount,
    coveragePercent: comprehension.coveragePercent,
  });

  // --- Helpers ---
  function toggleEntry(name: string) {
    const next = new Set(expandedEntries);
    if (next.has(name)) {
      next.delete(name);
    } else {
      next.add(name);
    }
    expandedEntries = next;
  }

  function expandAll() {
    expandedEntries = new Set(filteredEntries.map((e) => e.name));
  }

  function collapseAll() {
    expandedEntries = new Set();
  }

  const allExpanded = $derived(
    filteredEntries.length > 0 && expandedEntries.size >= filteredEntries.length
  );
  const allCollapsed = $derived(expandedEntries.size === 0);

  function domainUsageSummary(entry: CatalogueElement): string {
    const parts: string[] = [];
    for (const dk of domainKeys) {
      const instances = entry.domains[dk];
      if (instances && instances.length > 0) {
        const label = domainMeta[dk]?.label || dk;
        parts.push(`${label} (${instances.length})`);
      }
    }
    return parts.length > 0 ? parts.join(', ') : 'No domain instances';
  }

  function domainCount(entry: CatalogueElement): number {
    return Object.values(entry.domains).filter((d) => d && d.length > 0).length;
  }

  function truncateDoc(doc: string, maxLen = 200): string {
    if (!doc) return '';
    const clean = doc.replace(/\n/g, ' ').replace(/\s+/g, ' ').trim();
    if (clean.length <= maxLen) return clean;
    return clean.slice(0, maxLen).trimEnd() + '…';
  }

  function concernBadgeColor(concern: string): string {
    const colors: Record<string, string> = {
      ServiceConcept: 'blue',
      ActivityModel: 'green',
      ResourceCapability: 'purple',
      FinancialModel: 'yellow',
      Governance: 'red',
    };
    return colors[concern] || 'dark';
  }
</script>

<div class="space-y-4">
  <!-- Header -->
  <div>
    <h1 class="text-2xl font-bold text-secondary-800 dark:text-white">Glossary</h1>
    <p class="mt-1 text-secondary-500 dark:text-secondary-300">
      Plain-language descriptions of meta model concepts —
      {stats.total} of {stats.catalogueTotal} catalogue elements have glossary entries ({stats.coveragePercent}%)
    </p>
  </div>

  <!-- Controls row -->
  <div class="flex flex-wrap items-end gap-3">
    <!-- Search -->
    <div class="w-64">
      <label for="search" class="mb-1 block text-xs font-medium text-secondary-600 dark:text-secondary-400">Search</label>
      <div class="relative">
        <SearchOutline class="absolute left-3 top-2.5 h-4 w-4 text-secondary-400" />
        <input
          id="search"
          type="text"
          bind:value={searchText}
          placeholder="Filter by name or description…"
          class="block w-full rounded-lg border border-secondary-300 bg-white py-2 pl-9 pr-3 text-sm text-secondary-700 focus:border-primary-500 focus:ring-primary-500 dark:border-secondary-600 dark:bg-secondary-800 dark:text-secondary-200 dark:placeholder-secondary-400"
        />
      </div>
    </div>

    <!-- BMM Concern filter -->
    <div class="w-48">
      <label for="concern-filter" class="mb-1 block text-xs font-medium text-secondary-600 dark:text-secondary-400">BMM Concern</label>
      <select
        id="concern-filter"
        bind:value={concernFilter}
        class="block w-full rounded-lg border border-secondary-300 bg-white px-3 py-2 text-sm text-secondary-700 focus:border-primary-500 focus:ring-primary-500 dark:border-secondary-600 dark:bg-secondary-800 dark:text-secondary-200"
      >
        <option value="all">All concerns</option>
        {#each concernValues as concern}
          <option value={concern}>{concern}</option>
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
        <option value="bsmm">System Meta Model</option>
      </select>
    </div>

    <!-- Count -->
    <div class="text-sm text-secondary-500 dark:text-secondary-400">
      Showing {stats.showing} of {stats.total}
    </div>
  </div>

  <!-- Expand/collapse controls -->
  <div class="flex items-center gap-1">
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
    <span class="text-secondary-200 dark:text-secondary-700">·</span>
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

  <!-- Glossary list -->
  <div class="space-y-2">
    {#each filteredEntries as entry (entry.name)}
      {@const isExpanded = expandedEntries.has(entry.name)}
      <div class="rounded-lg border border-secondary-200 bg-white transition dark:border-secondary-700 dark:bg-secondary-900">
        <!-- Collapsed header — always visible -->
        <button
          onclick={() => toggleEntry(entry.name)}
          class="flex w-full items-center gap-3 px-4 py-3 text-left transition hover:bg-secondary-50 dark:hover:bg-secondary-800/50"
        >
          <!-- Chevron -->
          {#if isExpanded}
            <ChevronDownOutline class="h-3.5 w-3.5 shrink-0 text-secondary-400" />
          {:else}
            <ChevronRightOutline class="h-3.5 w-3.5 shrink-0 text-secondary-400" />
          {/if}

          <!-- Name block -->
          <div class="min-w-0 flex-1">
            <span class="font-medium text-secondary-800 dark:text-white">
              {entry.userFacing?.friendlyName || entry.name}
            </span>
            {#if entry.userFacing && entry.userFacing.friendlyName !== entry.name}
              <span class="ml-2 font-mono text-xs text-secondary-400 dark:text-secondary-500">
                {entry.name}
              </span>
            {/if}
          </div>

          <!-- Badges and dots -->
          <div class="flex shrink-0 items-center gap-2">
            <Badge color={concernBadgeColor(entry.catalogueTag.bmmConcern || '')} class="text-xs">
              {entry.catalogueTag.bmmConcern || ''}
            </Badge>
            <Badge color={entry.layer === 'bmm' ? 'blue' : 'purple'} class="text-xs">
              {entry.layer === 'bmm' ? 'BMM' : 'BSMM'}
            </Badge>
            <!-- Domain dots -->
            <div class="flex gap-0.5">
              {#each domainKeys as dk}
                <span
                  class="inline-block h-2 w-2 rounded-full {entry.domains[dk] && entry.domains[dk].length > 0
                    ? 'bg-green-400 dark:bg-green-500'
                    : 'bg-secondary-200 dark:bg-secondary-700'}"
                  title="{domainMeta[dk]?.label || dk}: {entry.domains[dk]?.length || 0} instances"
                ></span>
              {/each}
            </div>
          </div>
        </button>

        <!-- Expanded detail -->
        {#if isExpanded}
          <div class="border-t border-secondary-100 px-4 py-4 dark:border-secondary-700">
            <div class="space-y-4 pl-6">
              <!-- Short description -->
              {#if entry.userFacing?.shortDescription}
                <p class="text-sm leading-relaxed text-secondary-700 dark:text-secondary-300">
                  {entry.userFacing.shortDescription}
                </p>
              {/if}

              <!-- Doc block excerpt -->
              {#if entry.doc}
                <div>
                  <h4 class="mb-1 text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-500">
                    From model documentation
                  </h4>
                  <p class="text-xs leading-relaxed text-secondary-500 dark:text-secondary-400">
                    {truncateDoc(entry.doc)}
                  </p>
                </div>
              {/if}

              <!-- Domain usage -->
              <div>
                <h4 class="mb-1 text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-500">
                  Domain usage ({domainCount(entry)} domain{domainCount(entry) !== 1 ? 's' : ''})
                </h4>
                <p class="text-xs text-secondary-600 dark:text-secondary-400">
                  {domainUsageSummary(entry)}
                </p>
              </div>

              <!-- Cross-links -->
              <div class="flex flex-wrap gap-2 pt-1">
                <a
                  href="/catalogue?search={encodeURIComponent(entry.name)}"
                  class="inline-flex items-center gap-1 rounded-md border border-primary-200 bg-primary-50 px-3 py-1.5 text-xs font-medium text-primary-700 transition hover:bg-primary-100 dark:border-primary-800 dark:bg-primary-900/20 dark:text-primary-400 dark:hover:bg-primary-900/40"
                >
                  Component Catalogue <ArrowRightOutline class="h-3 w-3" />
                </a>
                <a
                  href="/coverage?search={encodeURIComponent(entry.name)}"
                  class="inline-flex items-center gap-1 rounded-md border border-secondary-200 bg-secondary-50 px-3 py-1.5 text-xs font-medium text-secondary-600 transition hover:bg-secondary-100 dark:border-secondary-700 dark:bg-secondary-800 dark:text-secondary-400 dark:hover:bg-secondary-700"
                >
                  Coverage Matrix <ArrowRightOutline class="h-3 w-3" />
                </a>
              </div>
            </div>
          </div>
        {/if}
      </div>
    {/each}

    {#if filteredEntries.length === 0}
      <div class="rounded-lg border border-secondary-200 bg-white px-4 py-12 text-center text-sm text-secondary-400 dark:border-secondary-700 dark:bg-secondary-900 dark:text-secondary-500">
        No glossary entries match the current filters.
      </div>
    {/if}
  </div>

  <!-- Footer -->
  <p class="text-xs text-secondary-400 dark:text-secondary-500">
    Generated {new Date(glossary.generatedAt).toLocaleString()} by {glossary.generator}
  </p>
</div>
