<script lang="ts">
  import { Badge } from 'flowbite-svelte';
  import {
    ChevronDownOutline,
    ChevronRightOutline,
    SearchOutline,
  } from 'flowbite-svelte-icons';

  let { data } = $props();

  const elements = data.introspection.elements;

  // --- Build the package tree from elements ---
  interface TreeNode {
    name: string;
    fullPath: string;
    children: Map<string, TreeNode>;
    elements: Array<{
      kind: string;
      name: string;
      metaModelLayer: string;
      doc: string;
      specialises?: string;
      attributes?: any[];
    }>;
  }

  function buildTree(): TreeNode {
    const root: TreeNode = { name: 'root', fullPath: '', children: new Map(), elements: [] };

    for (const elem of elements) {
      const pkg = elem.parentPackage || '(ungrouped)';

      // Ensure package node exists
      if (!root.children.has(pkg)) {
        root.children.set(pkg, {
          name: pkg,
          fullPath: pkg,
          children: new Map(),
          elements: [],
        });
      }
      root.children.get(pkg)!.elements.push(elem);
    }

    return root;
  }

  const tree = buildTree();

  // Sort packages alphabetically
  const sortedPackages = $derived(
    [...tree.children.entries()].sort((a, b) => a[0].localeCompare(b[0]))
  );

  // --- State ---
  let expandedPackages = $state<Set<string>>(new Set());
  let selectedPackage = $state<string | null>(null);
  let searchText = $state('');

  // --- Filtered packages ---
  const filteredPackages = $derived(
    searchText
      ? sortedPackages.filter(([name, node]) => {
          const s = searchText.toLowerCase();
          if (name.toLowerCase().includes(s)) return true;
          return node.elements.some(
            (e) =>
              e.name.toLowerCase().includes(s) ||
              (e.doc && e.doc.toLowerCase().includes(s))
          );
        })
      : sortedPackages
  );

  // --- Selected package detail ---
  const selectedNode = $derived(
    selectedPackage ? tree.children.get(selectedPackage) : null
  );

  const selectedGroups = $derived.by(() => {
    if (!selectedNode) return { part_defs: [], parts: [], enum_defs: [], metadata_defs: [], requirements: [] };
    const groups: Record<string, any[]> = {
      part_defs: [],
      parts: [],
      enum_defs: [],
      metadata_defs: [],
      requirements: [],
    };
    for (const elem of selectedNode.elements) {
      if (elem.kind === 'part_def') groups.part_defs.push(elem);
      else if (elem.kind === 'part') groups.parts.push(elem);
      else if (elem.kind === 'enum_def') groups.enum_defs.push(elem);
      else if (elem.kind === 'metadata_def') groups.metadata_defs.push(elem);
      else if (elem.kind === 'requirement') groups.requirements.push(elem);
    }
    // Sort each group
    for (const key of Object.keys(groups)) {
      groups[key].sort((a: any, b: any) => a.name.localeCompare(b.name));
    }
    return groups;
  });

  function togglePackage(pkg: string) {
    if (selectedPackage === pkg) {
      selectedPackage = null;
    } else {
      selectedPackage = pkg;
    }
  }

  function kindIcon(kind: string): string {
    switch (kind) {
      case 'part_def': return '◆';
      case 'part': return '◇';
      case 'enum_def': return '▤';
      case 'metadata_def': return '◎';
      case 'requirement': return '✓';
      default: return '•';
    }
  }

  function layerBadgeColor(layer: string): string {
    if (layer === 'bmm') return 'blue';
    if (layer === 'smm') return 'purple';
    if (layer === 'domain') return 'green';
    if (layer.includes('instance')) return 'yellow';
    return 'dark';
  }

  function layerLabel(layer: string): string {
    if (layer === 'bmm') return 'BMM';
    if (layer === 'smm') return 'SMM';
    if (layer === 'bmm_instance') return 'BMM inst';
    if (layer === 'smm_instance') return 'SMM inst';
    if (layer === 'domain') return 'Domain';
    return layer;
  }

  // Summary stats
  const stats = $derived({
    totalPackages: sortedPackages.length,
    totalElements: elements.length,
    filteredPackages: filteredPackages.length,
  });
</script>

<div class="space-y-4">
  <!-- Header -->
  <div>
    <h1 class="text-2xl font-bold text-secondary-800 dark:text-white">Package Navigator</h1>
    <p class="mt-1 text-secondary-500 dark:text-secondary-300">
      {stats.totalPackages} packages, {stats.totalElements} elements — click a package to see its contents
    </p>
  </div>

  <!-- Search -->
  <div class="w-72">
    <div class="relative">
      <SearchOutline class="absolute left-3 top-2.5 h-4 w-4 text-secondary-400" />
      <input
        type="text"
        bind:value={searchText}
        placeholder="Filter packages and elements..."
        class="block w-full rounded-lg border border-secondary-300 bg-white py-2 pl-9 pr-3 text-sm text-secondary-700 focus:border-primary-500 focus:ring-primary-500 dark:border-secondary-600 dark:bg-secondary-800 dark:text-secondary-200 dark:placeholder-secondary-400"
      />
    </div>
  </div>

  <!-- Two-panel layout -->
  <div class="flex gap-4">

    <!-- Left panel: Package list -->
    <div class="w-80 shrink-0 overflow-y-auto rounded-lg border border-secondary-200 bg-white dark:border-secondary-700 dark:bg-secondary-900" style="max-height: 70vh;">
      <div class="p-2">
        {#each filteredPackages as [name, node] (name)}
          <button
            onclick={() => togglePackage(name)}
            class="flex w-full items-center justify-between rounded-md px-3 py-2 text-left text-sm transition
              {selectedPackage === name
                ? 'bg-primary-100 text-primary-800 dark:bg-primary-900/30 dark:text-primary-300'
                : 'text-secondary-700 hover:bg-secondary-100 dark:text-secondary-300 dark:hover:bg-secondary-800'}"
          >
            <span class="font-medium">{name}</span>
            <span class="ml-2 rounded-full bg-secondary-100 px-2 py-0.5 text-xs text-secondary-500 dark:bg-secondary-800 dark:text-secondary-400">
              {node.elements.length}
            </span>
          </button>
        {/each}
      </div>
    </div>

    <!-- Right panel: Package detail -->
    <div class="min-h-96 flex-1 overflow-y-auto rounded-lg border border-secondary-200 bg-white dark:border-secondary-700 dark:bg-secondary-900" style="max-height: 70vh;">
      {#if selectedNode}
        <div class="p-4">
          <h2 class="text-lg font-semibold text-secondary-800 dark:text-white">{selectedPackage}</h2>
          <p class="mt-1 text-sm text-secondary-500 dark:text-secondary-400">
            {selectedNode.elements.length} elements
          </p>

          {#if selectedGroups.part_defs.length > 0}
            <div class="mt-4">
              <h3 class="mb-2 text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-500">
                Part Definitions ({selectedGroups.part_defs.length})
              </h3>
              {#each selectedGroups.part_defs as elem}
                <div class="mb-2 rounded-md border border-secondary-100 bg-secondary-50/50 px-3 py-2 dark:border-secondary-700 dark:bg-secondary-800/50">
                  <div class="flex items-center gap-2">
                    <span class="text-xs text-primary-500">{kindIcon(elem.kind)}</span>
                    <span class="font-medium text-secondary-800 dark:text-secondary-100">{elem.name}</span>
                    {#if elem.specialises}
                      <span class="text-xs text-secondary-400 dark:text-secondary-500">:&gt; {elem.specialises}</span>
                    {/if}
                    <Badge color={layerBadgeColor(elem.metaModelLayer)} class="ml-auto text-xs">
                      {layerLabel(elem.metaModelLayer)}
                    </Badge>
                  </div>
                  {#if elem.doc}
                    <p class="mt-1 text-xs text-secondary-500 dark:text-secondary-400">{elem.doc}</p>
                  {/if}
                  {#if elem.attributes && elem.attributes.length > 0}
                    <div class="mt-1 flex flex-wrap gap-1">
                      {#each elem.attributes as attr}
                        <span class="rounded bg-secondary-100 px-1.5 py-0.5 text-xs text-secondary-500 dark:bg-secondary-700 dark:text-secondary-400">
                          {attr.name}{attr.type ? `: ${attr.type}` : ''}{attr.value ? ` = ${attr.value}` : ''}
                        </span>
                      {/each}
                    </div>
                  {/if}
                </div>
              {/each}
            </div>
          {/if}

          {#if selectedGroups.parts.length > 0}
            <div class="mt-4">
              <h3 class="mb-2 text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-500">
                Part Usages ({selectedGroups.parts.length})
              </h3>
              {#each selectedGroups.parts as elem}
                <div class="mb-2 rounded-md border border-secondary-100 bg-secondary-50/50 px-3 py-2 dark:border-secondary-700 dark:bg-secondary-800/50">
                  <div class="flex items-center gap-2">
                    <span class="text-xs text-secondary-400">{kindIcon(elem.kind)}</span>
                    <span class="font-medium text-secondary-800 dark:text-secondary-100">{elem.name}</span>
                    {#if elem.specialises}
                      <span class="text-xs text-secondary-400 dark:text-secondary-500">: {elem.specialises}</span>
                    {/if}
                    <Badge color={layerBadgeColor(elem.metaModelLayer)} class="ml-auto text-xs">
                      {layerLabel(elem.metaModelLayer)}
                    </Badge>
                  </div>
                  {#if elem.doc}
                    <p class="mt-1 text-xs text-secondary-500 dark:text-secondary-400">{elem.doc}</p>
                  {/if}
                  {#if elem.attributes && elem.attributes.length > 0}
                    <div class="mt-1 flex flex-wrap gap-1">
                      {#each elem.attributes as attr}
                        <span class="rounded bg-secondary-100 px-1.5 py-0.5 text-xs text-secondary-500 dark:bg-secondary-700 dark:text-secondary-400">
                          {attr.name}{attr.type ? `: ${attr.type}` : ''}{attr.value ? ` = "${attr.value}"` : ''}
                        </span>
                      {/each}
                    </div>
                  {/if}
                </div>
              {/each}
            </div>
          {/if}

          {#if selectedGroups.enum_defs.length > 0}
            <div class="mt-4">
              <h3 class="mb-2 text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-500">
                Enum Definitions ({selectedGroups.enum_defs.length})
              </h3>
              {#each selectedGroups.enum_defs as elem}
                <div class="mb-2 rounded-md border border-secondary-100 bg-secondary-50/50 px-3 py-2 dark:border-secondary-700 dark:bg-secondary-800/50">
                  <div class="flex items-center gap-2">
                    <span class="text-xs text-yellow-500">{kindIcon(elem.kind)}</span>
                    <span class="font-medium text-secondary-800 dark:text-secondary-100">{elem.name}</span>
                  </div>
                  {#if elem.attributes && elem.attributes.length > 0}
                    <div class="mt-1 flex flex-wrap gap-1">
                      {#each elem.attributes as val}
                        <span class="rounded bg-secondary-100 px-1.5 py-0.5 text-xs text-secondary-500 dark:bg-secondary-700 dark:text-secondary-400">
                          {val.name}
                        </span>
                      {/each}
                    </div>
                  {/if}
                </div>
              {/each}
            </div>
          {/if}

          {#if selectedGroups.metadata_defs.length > 0}
            <div class="mt-4">
              <h3 class="mb-2 text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-500">
                Metadata Definitions ({selectedGroups.metadata_defs.length})
              </h3>
              {#each selectedGroups.metadata_defs as elem}
                <div class="mb-2 rounded-md border border-secondary-100 bg-secondary-50/50 px-3 py-2 dark:border-secondary-700 dark:bg-secondary-800/50">
                  <div class="flex items-center gap-2">
                    <span class="text-xs text-orange-500">{kindIcon(elem.kind)}</span>
                    <span class="font-medium text-secondary-800 dark:text-secondary-100">{elem.name}</span>
                  </div>
                  {#if elem.attributes && elem.attributes.length > 0}
                    <div class="mt-1 flex flex-wrap gap-1">
                      {#each elem.attributes as attr}
                        <span class="rounded bg-secondary-100 px-1.5 py-0.5 text-xs text-secondary-500 dark:bg-secondary-700 dark:text-secondary-400">
                          {attr.name}{attr.type ? `: ${attr.type}` : ''}
                        </span>
                      {/each}
                    </div>
                  {/if}
                </div>
              {/each}
            </div>
          {/if}

          {#if selectedGroups.requirements.length > 0}
            <div class="mt-4">
              <h3 class="mb-2 text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-500">
                Requirements ({selectedGroups.requirements.length})
              </h3>
              {#each selectedGroups.requirements as elem}
                <div class="mb-2 rounded-md border border-secondary-100 bg-secondary-50/50 px-3 py-2 dark:border-secondary-700 dark:bg-secondary-800/50">
                  <div class="flex items-center gap-2">
                    <span class="text-xs text-green-500">{kindIcon(elem.kind)}</span>
                    <span class="font-medium text-secondary-800 dark:text-secondary-100">{elem.name}</span>
                    {#if elem.specialises}
                      <span class="text-xs text-secondary-400 dark:text-secondary-500">: {elem.specialises}</span>
                    {/if}
                  </div>
                  {#if elem.doc}
                    <p class="mt-1 text-xs text-secondary-500 dark:text-secondary-400">{elem.doc}</p>
                  {/if}
                </div>
              {/each}
            </div>
          {/if}
        </div>
      {:else}
        <div class="flex h-full items-center justify-center p-8 text-secondary-400 dark:text-secondary-500">
          <p>Select a package from the left to see its contents</p>
        </div>
      {/if}
    </div>
  </div>

  <!-- Footer -->
  <p class="text-xs text-secondary-400 dark:text-secondary-500">
    Showing {stats.filteredPackages} of {stats.totalPackages} packages
  </p>
</div>
