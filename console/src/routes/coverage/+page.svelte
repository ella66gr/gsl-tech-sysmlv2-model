<script lang="ts">
  import { Badge, Input, Select, Tooltip } from 'flowbite-svelte';
  import {
    CheckCircleOutline,
    CloseCircleOutline,
    ChevronDownOutline,
    ChevronRightOutline,
    SearchOutline,
  } from 'flowbite-svelte-icons';

  let { data } = $props();

  const matrix = data.introspection.coverageMatrix;
  const domains = data.introspection.domains;
  const domainKeys = Object.keys(domains);

  // --- Filter state ---
  let layerFilter = $state('all');
  let coverageFilter = $state('all');
  let searchText = $state('');
  let collapsedPackages = $state<Set<string>>(new Set());

  // --- Expanded cell state ---
  let expandedCell = $state<string | null>(null);

  // --- Derived data ---
  const allDefs = $derived(
    Object.values(matrix).sort((a, b) => {
      // Sort by package then name
      const pkgCmp = a.package.localeCompare(b.package);
      if (pkgCmp !== 0) return pkgCmp;
      return a.name.localeCompare(b.name);
    })
  );

  const filteredDefs = $derived(
    allDefs.filter((def) => {
      // Layer filter
      if (layerFilter !== 'all' && def.layer !== layerFilter) return false;

      // Coverage filter
      const domainCount = Object.keys(def.domains).length;
      if (coverageFilter === 'instantiated' && domainCount === 0) return false;
      if (coverageFilter === 'uninstantiated' && domainCount > 0) return false;
      if (coverageFilter === 'multi' && domainCount < 2) return false;

      // Text search
      if (searchText) {
        const s = searchText.toLowerCase();
        if (
          !def.name.toLowerCase().includes(s) &&
          !def.package.toLowerCase().includes(s) &&
          !(def.doc && def.doc.toLowerCase().includes(s))
        )
          return false;
      }

      return true;
    })
  );

  // Group by package
  const groupedDefs = $derived(() => {
    const groups: Record<string, typeof filteredDefs> = {};
    for (const def of filteredDefs) {
      const pkg = def.package || '(ungrouped)';
      if (!groups[pkg]) groups[pkg] = [];
      groups[pkg].push(def);
    }
    return groups;
  });

  // Summary stats
  const stats = $derived({
    totalDefs: allDefs.length,
    bmmDefs: allDefs.filter((d) => d.layer === 'bmm').length,
    bsmmDefs: allDefs.filter((d) => d.layer === 'bsmm').length,
    uninstantiated: allDefs.filter((d) => Object.keys(d.domains).length === 0).length,
    filteredCount: filteredDefs.length,
  });

  function togglePackage(pkg: string) {
    const next = new Set(collapsedPackages);
    if (next.has(pkg)) {
      next.delete(pkg);
    } else {
      next.add(pkg);
    }
    collapsedPackages = next;
  }

  function toggleCell(defName: string, domainKey: string) {
    const key = `${defName}:${domainKey}`;
    expandedCell = expandedCell === key ? null : key;
  }

  function instanceCount(def: any, domainKey: string): number {
    return def.domains[domainKey]?.length ?? 0;
  }

  function layerColor(layer: string): string {
    return layer === 'bmm' ? 'blue' : 'purple';
  }
</script>

<div class="space-y-4">
  <!-- Header -->
  <div>
    <h1 class="text-2xl font-bold text-secondary-800 dark:text-white">Coverage Matrix</h1>
    <p class="mt-1 text-secondary-500 dark:text-secondary-300">
      Meta model concept coverage across domains — {stats.totalDefs} defs ({stats.bmmDefs} BMM, {stats.bsmmDefs} BSMM), {stats.uninstantiated} uninstantiated
    </p>
  </div>

  <!-- Filters -->
  <div class="flex flex-wrap items-end gap-3">
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

    <div class="w-48">
      <label for="coverage-filter" class="mb-1 block text-xs font-medium text-secondary-600 dark:text-secondary-400">Coverage Status</label>
      <select
        id="coverage-filter"
        bind:value={coverageFilter}
        class="block w-full rounded-lg border border-secondary-300 bg-white px-3 py-2 text-sm text-secondary-700 focus:border-primary-500 focus:ring-primary-500 dark:border-secondary-600 dark:bg-secondary-800 dark:text-secondary-200"
      >
        <option value="all">All ({stats.totalDefs})</option>
        <option value="instantiated">Instantiated ({stats.totalDefs - stats.uninstantiated})</option>
        <option value="uninstantiated">Uninstantiated ({stats.uninstantiated})</option>
        <option value="multi">Multi-domain (2+)</option>
      </select>
    </div>

    <div class="w-64">
      <label for="search" class="mb-1 block text-xs font-medium text-secondary-600 dark:text-secondary-400">Search</label>
      <div class="relative">
        <SearchOutline class="absolute left-3 top-2.5 h-4 w-4 text-secondary-400" />
        <input
          id="search"
          type="text"
          bind:value={searchText}
          placeholder="Filter by name, package, or doc..."
          class="block w-full rounded-lg border border-secondary-300 bg-white py-2 pl-9 pr-3 text-sm text-secondary-700 focus:border-primary-500 focus:ring-primary-500 dark:border-secondary-600 dark:bg-secondary-800 dark:text-secondary-200 dark:placeholder-secondary-400"
        />
      </div>
    </div>

    <div class="text-sm text-secondary-500 dark:text-secondary-400">
      Showing {stats.filteredCount} of {stats.totalDefs}
    </div>
  </div>

  <!-- Matrix table -->
  <div class="overflow-x-auto rounded-lg border border-secondary-200 dark:border-secondary-700">
    <table class="w-full text-left text-sm">
      <thead>
        <tr class="border-b border-secondary-200 bg-secondary-50 dark:border-secondary-700 dark:bg-secondary-800">
          <th class="px-4 py-3 font-semibold text-secondary-700 dark:text-secondary-300">Part Def</th>
          <th class="px-3 py-3 text-center font-semibold text-secondary-700 dark:text-secondary-300">Layer</th>
          {#each domainKeys as dk}
            <th class="px-3 py-3 text-center font-semibold text-secondary-700 dark:text-secondary-300">
              {domains[dk].label}
            </th>
          {/each}
        </tr>
      </thead>
      <tbody>
        {#each Object.entries(groupedDefs()) as [pkg, defs] (pkg)}
          <!-- Package group header -->
          <tr class="border-b border-secondary-100 bg-secondary-50/50 dark:border-secondary-700 dark:bg-secondary-800/50">
            <td
              colspan={2 + domainKeys.length}
              class="px-4 py-2"
            >
              <button
                onclick={() => togglePackage(pkg)}
                class="flex items-center gap-1 text-xs font-semibold uppercase tracking-wider text-secondary-500 hover:text-secondary-700 dark:text-secondary-400 dark:hover:text-secondary-200"
              >
                {#if collapsedPackages.has(pkg)}
                  <ChevronRightOutline class="h-3 w-3" />
                {:else}
                  <ChevronDownOutline class="h-3 w-3" />
                {/if}
                {pkg}
                <span class="ml-1 font-normal normal-case">({defs.length})</span>
              </button>
            </td>
          </tr>

          {#if !collapsedPackages.has(pkg)}
            {#each defs as def (def.name)}
              <tr class="border-b border-secondary-100 transition hover:bg-secondary-50 dark:border-secondary-700 dark:hover:bg-secondary-800/30">
                <!-- Name + doc tooltip -->
                <td class="px-4 py-2">
                  <span class="font-medium text-secondary-800 dark:text-secondary-100">{def.name}</span>
                  {#if def.doc}
                    <p class="mt-0.5 line-clamp-1 text-xs text-secondary-400 dark:text-secondary-500">{def.doc}</p>
                  {/if}
                </td>

                <!-- Layer badge -->
                <td class="px-3 py-2 text-center">
                  <Badge color={layerColor(def.layer)} class="text-xs">
                    {def.layer === 'bmm' ? 'BMM' : 'BSMM'}
                  </Badge>
                </td>

                <!-- Domain cells -->
                {#each domainKeys as dk}
                  {@const count = instanceCount(def, dk)}
                  {@const cellKey = `${def.name}:${dk}`}
                  <td class="px-3 py-2 text-center">
                    {#if count > 0}
                      <button
                        onclick={() => toggleCell(def.name, dk)}
                        class="inline-flex items-center gap-1 rounded px-2 py-0.5 text-xs font-medium text-green-700 transition hover:bg-green-50 dark:text-green-400 dark:hover:bg-green-900/20"
                      >
                        <CheckCircleOutline class="h-4 w-4" />
                        {count}
                      </button>

                      {#if expandedCell === cellKey}
                        <div class="mt-1 rounded border border-secondary-200 bg-white p-2 text-left text-xs dark:border-secondary-600 dark:bg-secondary-800">
                          {#each def.domains[dk] as inst}
                            <div class="text-secondary-600 dark:text-secondary-300">
                              <span class="font-medium">{inst.name}</span>
                              <span class="text-secondary-400 dark:text-secondary-500"> in {inst.package}</span>
                            </div>
                          {/each}
                        </div>
                      {/if}
                    {:else}
                      <span class="text-secondary-300 dark:text-secondary-600">—</span>
                    {/if}
                  </td>
                {/each}
              </tr>
            {/each}
          {/if}
        {/each}
      </tbody>
    </table>
  </div>

  <!-- Footer -->
  <p class="text-xs text-secondary-400 dark:text-secondary-500">
    Generated {new Date(data.introspection.generatedAt).toLocaleString()} by {data.introspection.generator}
  </p>
</div>
