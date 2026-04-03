<script lang="ts">
  import { Badge } from 'flowbite-svelte';
  import { ChevronDownOutline, ChevronRightOutline, ArrowRightOutline, CheckCircleOutline, CloseCircleOutline } from 'flowbite-svelte-icons';
  import type { HierarchyNode, ReasoningSummary } from '$lib/types/ontology';

  let { data } = $props();

  const hierarchy = data.ontology.hierarchy;
  const stats = hierarchy.stats;
  const reasoning: ReasoningSummary | null = data.reasoning ?? null;

  function formatBytes(bytes: number): string {
    if (bytes < 1024) return `${bytes} B`;
    if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(0)} KB`;
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
  }

  let ontologyStackExpanded = $state(false);

  // --- Collect all node paths that can be expanded (bfo and midLevel) ---
  function collectExpandablePaths(node: HierarchyNode, path: string): string[] {
    const paths: string[] = [];
    if (node.tier === 'bfo' || node.tier === 'midLevel') {
      paths.push(path);
      for (const child of node.children ?? []) {
        paths.push(...collectExpandablePaths(child, path + '/' + child.name));
      }
    }
    return paths;
  }

  const allExpandablePaths = collectExpandablePaths(hierarchy.tree, hierarchy.tree.name);

  // Initial state: all bfo and midLevel nodes expanded
  let expandedPaths = $state<Set<string>>(new Set(allExpandablePaths));

  function toggleNode(path: string) {
    const next = new Set(expandedPaths);
    if (next.has(path)) {
      next.delete(path);
    } else {
      next.add(path);
    }
    expandedPaths = next;
  }

  function expandAll() {
    expandedPaths = new Set(allExpandablePaths);
  }

  function collapseAll() {
    expandedPaths = new Set();
  }

  const allExpanded = $derived(allExpandablePaths.every((p) => expandedPaths.has(p)));
  const allCollapsed = $derived(expandedPaths.size === 0);

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

  // Count total leaf (bmm) nodes in a subtree — for badges on collapsed nodes
  function countBmmLeaves(node: HierarchyNode): number {
    if (node.tier === 'bmm') return 1;
    return (node.children ?? []).reduce((sum, c) => sum + countBmmLeaves(c), 0);
  }
</script>

{#snippet treeNode(node: HierarchyNode, path: string, depth: number)}
  {@const nodePath = path}
  {@const isExpanded = expandedPaths.has(nodePath)}
  {@const hasChildren = (node.children ?? []).length > 0}
  {@const indent = depth * 20}

  <div style="margin-left: {indent}px;">
    {#if node.tier === 'bfo'}
      <!-- BFO structural node -->
      <button
        onclick={() => toggleNode(nodePath)}
        class="mb-1 flex w-full items-center gap-2 rounded-md px-2 py-1.5 text-left transition hover:bg-violet-50 dark:hover:bg-violet-900/20"
      >
        <span class="shrink-0 text-secondary-400">
          {#if isExpanded}
            <ChevronDownOutline class="h-3 w-3" />
          {:else}
            <ChevronRightOutline class="h-3 w-3" />
          {/if}
        </span>
        <span class="rounded-full bg-violet-100 px-2.5 py-0.5 text-xs font-medium text-violet-700 dark:bg-violet-900/40 dark:text-violet-300">
          {node.name}
        </span>
        {#if !isExpanded}
          <span class="text-xs text-secondary-400 dark:text-secondary-500">
            {countBmmLeaves(node)} element{countBmmLeaves(node) !== 1 ? 's' : ''}
          </span>
        {/if}
      </button>
      {#if isExpanded && hasChildren}
        <div class="mb-1 border-l border-violet-200 dark:border-violet-900/40" style="margin-left: 10px; padding-left: 2px;">
          {#each node.children ?? [] as child (child.name)}
            {@render treeNode(child, nodePath + '/' + child.name, depth + 1)}
          {/each}
        </div>
      {/if}

    {:else if node.tier === 'midLevel'}
      <!-- Mid-level (CCO / IAO) node -->
      <button
        onclick={() => toggleNode(nodePath)}
        class="mb-1 flex w-full items-center gap-2 rounded-md px-2 py-1.5 text-left transition hover:bg-teal-50 dark:hover:bg-teal-900/20"
      >
        <span class="shrink-0 text-secondary-400">
          {#if isExpanded}
            <ChevronDownOutline class="h-3 w-3" />
          {:else}
            <ChevronRightOutline class="h-3 w-3" />
          {/if}
        </span>
        <span class="rounded-full bg-teal-100 px-2.5 py-0.5 text-xs font-medium text-teal-700 dark:bg-teal-900/40 dark:text-teal-300">
          {#if node.prefix}
            <span class="font-normal opacity-70">{node.prefix}:</span>{node.className}
          {:else}
            {node.name}
          {/if}
        </span>
        {#if !isExpanded}
          <span class="text-xs text-secondary-400 dark:text-secondary-500">
            {(node.children ?? []).length} element{(node.children ?? []).length !== 1 ? 's' : ''}
          </span>
        {/if}
      </button>
      {#if isExpanded && hasChildren}
        <div class="mb-1 border-l border-teal-200 dark:border-teal-900/40" style="margin-left: 10px; padding-left: 2px;">
          {#each node.children ?? [] as child (child.name)}
            {@render treeNode(child, nodePath + '/' + child.name, depth + 1)}
          {/each}
        </div>
      {/if}

    {:else}
      <!-- BMM leaf node -->
      {@const isUnmapped = stats.unmappedMidLevel.includes(node.name)}
      <a
        href="/glossary?entry={encodeURIComponent(node.name)}&from=ontology"
        class="mb-1 flex items-center gap-2.5 rounded-md border px-3 py-2 text-left text-sm transition
          {isUnmapped
            ? 'border-dashed border-secondary-300 bg-secondary-50 hover:bg-secondary-100 dark:border-secondary-600 dark:bg-secondary-800/50 dark:hover:bg-secondary-700/50'
            : 'border-secondary-200 bg-white hover:border-primary-200 hover:bg-primary-50/30 dark:border-secondary-700 dark:bg-secondary-900 dark:hover:border-primary-700 dark:hover:bg-primary-900/10'}"
      >
        <div class="min-w-0 flex-1">
          <span class="font-medium text-secondary-800 dark:text-white">
            {node.friendlyName || node.name}
          </span>
          {#if node.friendlyName && node.friendlyName !== node.name}
            <span class="ml-1.5 font-mono text-xs text-secondary-400 dark:text-secondary-500">
              {node.name}
            </span>
          {/if}
        </div>
        <div class="flex shrink-0 items-center gap-1.5">
          {#if node.bmmConcern}
            <Badge color={concernBadgeColor(node.bmmConcern)} class="text-xs">
              {node.bmmConcern}
            </Badge>
          {/if}
          {#if isUnmapped}
            <span class="rounded border border-dashed border-secondary-300 px-1.5 py-0.5 text-xs text-secondary-400 dark:border-secondary-600 dark:text-secondary-500">
              no mid-level
            </span>
          {/if}
          <ArrowRightOutline class="h-3 w-3 text-secondary-300 dark:text-secondary-600" />
        </div>
      </a>
    {/if}
  </div>
{/snippet}

<div class="space-y-4">
  <!-- Header -->
  <div>
    <h1 class="text-2xl font-bold text-secondary-800 dark:text-white">Ontological Hierarchy</h1>
    <p class="mt-1 text-secondary-500 dark:text-secondary-300">
      BFO 2020 → CCO / IAO → BMM class hierarchy ·
      {stats.bmmElementCount} elements across {stats.bfoClassesUsed.length} BFO classes
    </p>
  </div>

  <!-- Stats bar -->
  <div class="flex flex-wrap gap-2">
    {#each stats.bfoClassesUsed as bfoClass}
      <span class="rounded-full bg-violet-100 px-2.5 py-1 text-xs font-medium text-violet-700 dark:bg-violet-900/40 dark:text-violet-300">
        BFO: {bfoClass}
      </span>
    {/each}
    {#each stats.midLevelClassesUsed as ml}
      {@const parts = ml.split(':', 1)}
      <span class="rounded-full bg-teal-100 px-2.5 py-1 text-xs font-medium text-teal-700 dark:bg-teal-900/40 dark:text-teal-300">
        {ml}
      </span>
    {/each}
    {#if stats.unmappedMidLevel.length > 0}
      <span class="rounded-full border border-dashed border-secondary-300 px-2.5 py-1 text-xs text-secondary-500 dark:border-secondary-600 dark:text-secondary-400">
        {stats.unmappedMidLevel.length} without mid-level mapping
      </span>
    {/if}
  </div>

  <!-- Expand / Collapse controls -->
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

  <!-- Tree -->
  <div class="rounded-lg border border-secondary-200 bg-white p-4 dark:border-secondary-700 dark:bg-secondary-900">
    {@render treeNode(hierarchy.tree, hierarchy.tree.name, 0)}
  </div>

  <!-- KG Status separator -->
  <hr class="my-2 border-secondary-200 dark:border-secondary-700" />

  <!-- Knowledge Graph Status -->
  <div class="space-y-6">
    <div>
      <h2 class="text-xl font-bold text-secondary-800 dark:text-white">Knowledge Graph Status</h2>
      <p class="mt-1 text-secondary-500 dark:text-secondary-300">
        OWL 2 DL reasoning results and formal relationship declarations
      </p>
    </div>

    {#if reasoning === null}
      <div class="rounded-lg border border-secondary-200 bg-secondary-50 px-4 py-6 text-sm text-secondary-500 dark:border-secondary-700 dark:bg-secondary-800/50 dark:text-secondary-400">
        No reasoning summary available — run
        <code class="rounded bg-secondary-100 px-1.5 py-0.5 font-mono text-xs dark:bg-secondary-700">python3 scripts/reason_kg.py --save-summary</code>
        to generate.
      </div>
    {:else}
      <!-- Stat cards -->
      <div class="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-5">
        <!-- Consistency -->
        <div class="flex flex-col items-center justify-center gap-1 rounded-lg border p-4 text-center
          {reasoning.consistent
            ? 'border-green-200 bg-green-50 dark:border-green-700/50 dark:bg-green-900/20'
            : 'border-red-200 bg-red-50 dark:border-red-700/50 dark:bg-red-900/20'}">
          {#if reasoning.consistent}
            <CheckCircleOutline class="h-7 w-7 text-green-500 dark:text-green-400" />
            <span class="text-sm font-semibold text-green-700 dark:text-green-300">Consistent</span>
          {:else}
            <CloseCircleOutline class="h-7 w-7 text-red-500 dark:text-red-400" />
            <span class="text-sm font-semibold text-red-700 dark:text-red-300">Inconsistent</span>
          {/if}
          <span class="text-xs text-secondary-500 dark:text-secondary-400">HermiT</span>
        </div>

        <!-- Ontology Stack -->
        <div class="flex flex-col items-center justify-center gap-1 rounded-lg border border-secondary-200 bg-white p-4 text-center dark:border-secondary-700 dark:bg-secondary-900">
          <span class="text-2xl font-bold text-secondary-800 dark:text-white">{reasoning.stats.ontologyFileCount}</span>
          <button
            onclick={() => ontologyStackExpanded = !ontologyStackExpanded}
            class="text-xs text-primary-600 hover:underline dark:text-primary-400"
          >
            {ontologyStackExpanded ? 'hide files' : 'ontology files'}
          </button>
        </div>

        <!-- Object Properties -->
        <div class="flex flex-col items-center justify-center gap-1 rounded-lg border border-secondary-200 bg-white p-4 text-center dark:border-secondary-700 dark:bg-secondary-900">
          <span class="text-2xl font-bold text-secondary-800 dark:text-white">{reasoning.stats.objectPropertyCount}</span>
          <span class="text-xs text-secondary-500 dark:text-secondary-400">typed relationships</span>
        </div>

        <!-- Reified Weights -->
        <div class="flex flex-col items-center justify-center gap-1 rounded-lg border border-secondary-200 bg-white p-4 text-center dark:border-secondary-700 dark:bg-secondary-900">
          <span class="text-2xl font-bold text-secondary-800 dark:text-white">{reasoning.stats.reifiedWeightCount}</span>
          <span class="text-xs text-secondary-500 dark:text-secondary-400">weighted relationships</span>
        </div>

        <!-- Domain Classes -->
        <div class="flex flex-col items-center justify-center gap-1 rounded-lg border border-secondary-200 bg-white p-4 text-center dark:border-secondary-700 dark:bg-secondary-900">
          <span class="text-2xl font-bold text-secondary-800 dark:text-white">{reasoning.stats.domainClassCount}</span>
          <span class="text-xs text-secondary-500 dark:text-secondary-400">OWL classes</span>
        </div>
      </div>

      <!-- Ontology stack detail (expandable) -->
      {#if ontologyStackExpanded}
        <div class="rounded-lg border border-secondary-200 bg-secondary-50 p-3 dark:border-secondary-700 dark:bg-secondary-800/50">
          <table class="w-full text-xs">
            <thead>
              <tr class="border-b border-secondary-200 dark:border-secondary-700">
                <th class="pb-1.5 text-left font-semibold text-secondary-500 dark:text-secondary-400">File</th>
                <th class="pb-1.5 text-left font-semibold text-secondary-500 dark:text-secondary-400">Name</th>
                <th class="pb-1.5 text-right font-semibold text-secondary-500 dark:text-secondary-400">Size</th>
                <th class="pb-1.5 text-center font-semibold text-secondary-500 dark:text-secondary-400">Status</th>
              </tr>
            </thead>
            <tbody>
              {#each reasoning.ontologyStack as entry}
                <tr class="border-b border-secondary-100 last:border-0 dark:border-secondary-700/50">
                  <td class="py-1.5 pr-3 font-mono text-secondary-500 dark:text-secondary-400">{entry.file}</td>
                  <td class="py-1.5 pr-3 text-secondary-700 dark:text-secondary-300">{entry.name}</td>
                  <td class="py-1.5 pr-3 text-right text-secondary-500 dark:text-secondary-400">{formatBytes(entry.sizeBytes)}</td>
                  <td class="py-1.5 text-center">
                    {#if entry.present}
                      <span class="text-green-600 dark:text-green-400">✓</span>
                    {:else}
                      <span class="text-red-500 dark:text-red-400">✗</span>
                    {/if}
                  </td>
                </tr>
              {/each}
            </tbody>
          </table>
        </div>
      {/if}

      <!-- Object properties table -->
      <div>
        <h3 class="mb-3 text-sm font-semibold text-secondary-700 dark:text-secondary-300">
          OWL Object Properties ({reasoning.objectProperties.length})
        </h3>
        <div class="overflow-x-auto rounded-lg border border-secondary-200 dark:border-secondary-700">
          <table class="w-full text-sm">
            <thead>
              <tr class="border-b border-secondary-200 bg-secondary-50 dark:border-secondary-700 dark:bg-secondary-800/50">
                <th class="px-4 py-2.5 text-left text-xs font-semibold uppercase tracking-wider text-secondary-500 dark:text-secondary-400">Property</th>
                <th class="px-4 py-2.5 text-left text-xs font-semibold uppercase tracking-wider text-secondary-500 dark:text-secondary-400">Domain</th>
                <th class="px-2 py-2.5 text-center text-xs text-secondary-300 dark:text-secondary-600">→</th>
                <th class="px-4 py-2.5 text-left text-xs font-semibold uppercase tracking-wider text-secondary-500 dark:text-secondary-400">Range</th>
                <th class="px-4 py-2.5 text-center text-xs font-semibold uppercase tracking-wider text-secondary-500 dark:text-secondary-400">Functional?</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-secondary-100 dark:divide-secondary-700/50">
              {#each reasoning.objectProperties as prop, i}
                <tr class="{i % 2 === 0 ? 'bg-white dark:bg-secondary-900' : 'bg-secondary-50/50 dark:bg-secondary-800/30'}">
                  <td class="px-4 py-2.5">
                    <span class="font-medium text-secondary-800 dark:text-white">{prop.label}</span>
                    <span class="ml-1.5 font-mono text-xs text-secondary-400 dark:text-secondary-500">{prop.name}</span>
                  </td>
                  <td class="px-4 py-2.5">
                    <a
                      href="/glossary?entry={encodeURIComponent(prop.domain)}&from=ontology"
                      class="text-primary-600 hover:underline dark:text-primary-400"
                    >
                      {prop.domain}
                    </a>
                  </td>
                  <td class="px-2 py-2.5 text-center text-secondary-300 dark:text-secondary-600">→</td>
                  <td class="px-4 py-2.5">
                    <a
                      href="/glossary?entry={encodeURIComponent(prop.range)}&from=ontology"
                      class="text-primary-600 hover:underline dark:text-primary-400"
                    >
                      {prop.range}
                    </a>
                  </td>
                  <td class="px-4 py-2.5 text-center">
                    {#if prop.functional}
                      <Badge color="green" class="text-xs">Functional</Badge>
                    {:else}
                      <span class="rounded px-2.5 py-0.5 text-xs font-medium bg-secondary-100 text-secondary-700 dark:bg-secondary-700 dark:text-secondary-200">Non-functional</span>
                    {/if}
                  </td>
                </tr>
              {/each}
            </tbody>
          </table>
        </div>
        <p class="mt-2 text-xs text-secondary-400 dark:text-secondary-500">
          Reasoning summary generated {new Date(reasoning.generatedAt).toLocaleString()} by {reasoning.generator}
        </p>
      </div>
    {/if}
  </div>

  <!-- Footer -->
  <p class="text-xs text-secondary-400 dark:text-secondary-500">
    Hierarchy generated {new Date(data.ontology.generatedAt).toLocaleString()} by {data.ontology.generator}
  </p>
</div>
