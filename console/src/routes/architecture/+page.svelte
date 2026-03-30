<script lang="ts">
  import { Badge } from 'flowbite-svelte';
  import { ChevronDownOutline, ChevronRightOutline } from 'flowbite-svelte-icons';
  import type { ArchitecturalSection } from './+page.ts';

  let { data } = $props();

  const architecture = data.architecture;
  const allSections: ArchitecturalSection[] = architecture.sections;

  // Strip enum type prefix: "ArchitecturalGroup::leftStack" → "leftStack"
  function stripPrefix(value: string): string {
    return value.includes('::') ? value.split('::').pop()! : value;
  }

  // Normalised sections with stripped enum values
  const sections = allSections.map((s) => ({
    ...s,
    group: stripPrefix(s.group),
    primaryFormalism: stripPrefix(s.primaryFormalism),
    implementationStatus: stripPrefix(s.implementationStatus),
  }));

  // Group ordering and display labels
  const GROUP_ORDER = [
    'sharedFoundation', 'leftStack', 'rightStack',
    'crossCutting', 'greenContainer', 'infrastructure',
  ] as const;

  const GROUP_LABELS: Record<string, string> = {
    sharedFoundation: 'Shared Foundation',
    leftStack: 'Left Stack — Business Model',
    rightStack: 'Right Stack — Business System Model',
    crossCutting: 'Cross-Cutting',
    greenContainer: 'Green Container',
    infrastructure: 'Infrastructure',
  };

  // All possible filter values (from the data, in display order)
  const ALL_FORMALISMS = ['owl2dl', 'sysmlV2', 'runtime', 'mixed'] as const;
  const ALL_STATUSES = ['implemented', 'designed', 'referenced', 'notStarted'] as const;

  const FORMALISM_LABELS: Record<string, string> = {
    owl2dl: 'OWL 2 DL',
    sysmlV2: 'SysML v2',
    runtime: 'Runtime',
    mixed: 'Mixed',
  };

  const STATUS_LABELS: Record<string, string> = {
    implemented: 'Implemented',
    designed: 'Designed',
    referenced: 'Referenced',
    notStarted: 'Not Started',
  };

  // --- Filter state ---
  let activeGroups = $state<Set<string>>(new Set(GROUP_ORDER));
  let activeFormalisms = $state<Set<string>>(new Set(ALL_FORMALISMS));
  let activeStatuses = $state<Set<string>>(new Set(ALL_STATUSES));

  function toggleGroup(g: string) {
    const next = new Set(activeGroups);
    next.has(g) ? next.delete(g) : next.add(g);
    activeGroups = next;
  }
  function toggleFormalism(f: string) {
    const next = new Set(activeFormalisms);
    next.has(f) ? next.delete(f) : next.add(f);
    activeFormalisms = next;
  }
  function toggleStatus(s: string) {
    const next = new Set(activeStatuses);
    next.has(s) ? next.delete(s) : next.add(s);
    activeStatuses = next;
  }

  // --- Filtered sections grouped ---
  const filteredSections = $derived(
    sections.filter(
      (s) =>
        activeGroups.has(s.group) &&
        activeFormalisms.has(s.primaryFormalism) &&
        activeStatuses.has(s.implementationStatus),
    ),
  );

  const groupedSections = $derived(() => {
    const map = new Map<string, ArchitecturalSection[]>();
    for (const g of GROUP_ORDER) {
      map.set(g, []);
    }
    for (const s of filteredSections) {
      const arr = map.get(s.group);
      if (arr) arr.push(s);
    }
    return map;
  });

  const visibleGroups = $derived(
    GROUP_ORDER.filter((g) => (groupedSections().get(g) ?? []).length > 0),
  );

  // --- Stats ---
  const stats = $derived({
    totalSections: filteredSections.length,
    totalGroups: visibleGroups.length,
  });

  // --- Expand/collapse state ---
  // Groups: all expanded by default
  let expandedGroups = $state<Set<string>>(new Set(GROUP_ORDER));
  // Sections: all collapsed by default
  let expandedSections = $state<Set<string>>(new Set());

  function toggleGroupExpand(g: string) {
    const next = new Set(expandedGroups);
    next.has(g) ? next.delete(g) : next.add(g);
    expandedGroups = next;
  }

  function toggleSectionExpand(name: string) {
    const next = new Set(expandedSections);
    next.has(name) ? next.delete(name) : next.add(name);
    expandedSections = next;
  }

  function expandAll() {
    expandedGroups = new Set(GROUP_ORDER);
    expandedSections = new Set(filteredSections.map((s) => s.name));
  }

  function collapseAll() {
    expandedGroups = new Set<string>();
    expandedSections = new Set<string>();
  }

  // --- Badge colour helpers ---
  function formalismBadgeColor(f: string): string {
    const colors: Record<string, string> = {
      owl2dl: 'purple',
      sysmlV2: 'blue',
      runtime: 'green',
      mixed: 'yellow',
    };
    return colors[f] || 'dark';
  }

  function statusBadgeColor(s: string): string {
    const colors: Record<string, string> = {
      implemented: 'green',
      designed: 'blue',
      referenced: 'yellow',
      notStarted: 'dark',
    };
    return colors[s] || 'dark';
  }

  // --- Filter pill helpers ---
  function filterPillClass(active: boolean): string {
    return active
      ? 'rounded-full border border-primary-400 bg-primary-100 px-3 py-1 text-xs font-medium text-primary-700 cursor-pointer select-none dark:border-primary-600 dark:bg-primary-900/30 dark:text-primary-300'
      : 'rounded-full border border-secondary-300 bg-white px-3 py-1 text-xs font-medium text-secondary-500 cursor-pointer select-none hover:border-secondary-400 dark:border-secondary-600 dark:bg-secondary-800 dark:text-secondary-400 dark:hover:border-secondary-500';
  }
</script>

<div class="space-y-4">
  <!-- Header -->
  <div>
    <h1 class="text-2xl font-bold text-secondary-800 dark:text-white">Architecture</h1>
    <p class="mt-1 text-secondary-500 dark:text-secondary-300">
      Structural sections of the dual-stack architecture
    </p>
  </div>

  <!-- Stats bar + expand/collapse -->
  <div class="flex items-center justify-between">
    <div class="text-sm text-secondary-500 dark:text-secondary-400">
      {stats.totalSections} section{stats.totalSections === 1 ? '' : 's'} across {stats.totalGroups} group{stats.totalGroups === 1 ? '' : 's'}
    </div>
    <div class="flex gap-2">
      <button
        onclick={expandAll}
        class="rounded border border-secondary-300 px-2.5 py-1 text-xs font-medium text-secondary-600 transition hover:bg-secondary-100 dark:border-secondary-600 dark:text-secondary-300 dark:hover:bg-secondary-700"
      >
        Expand all
      </button>
      <button
        onclick={collapseAll}
        class="rounded border border-secondary-300 px-2.5 py-1 text-xs font-medium text-secondary-600 transition hover:bg-secondary-100 dark:border-secondary-600 dark:text-secondary-300 dark:hover:bg-secondary-700"
      >
        Collapse all
      </button>
    </div>
  </div>

  <!-- Filters -->
  <div class="space-y-3 rounded-lg border border-secondary-200 bg-secondary-50 p-3 dark:border-secondary-700 dark:bg-secondary-800/50">

    <!-- Group filter -->
    <div>
      <span class="mb-1.5 block text-xs font-semibold uppercase tracking-wider text-secondary-500 dark:text-secondary-400">Group</span>
      <div class="flex flex-wrap gap-1.5">
        {#each GROUP_ORDER as g}
          <button onclick={() => toggleGroup(g)} class={filterPillClass(activeGroups.has(g))}>
            {GROUP_LABELS[g]}
          </button>
        {/each}
      </div>
    </div>

    <!-- Formalism filter -->
    <div>
      <span class="mb-1.5 block text-xs font-semibold uppercase tracking-wider text-secondary-500 dark:text-secondary-400">Formalism</span>
      <div class="flex flex-wrap gap-1.5">
        {#each ALL_FORMALISMS as f}
          <button onclick={() => toggleFormalism(f)} class={filterPillClass(activeFormalisms.has(f))}>
            {FORMALISM_LABELS[f]}
          </button>
        {/each}
      </div>
    </div>

    <!-- Status filter -->
    <div>
      <span class="mb-1.5 block text-xs font-semibold uppercase tracking-wider text-secondary-500 dark:text-secondary-400">Status</span>
      <div class="flex flex-wrap gap-1.5">
        {#each ALL_STATUSES as s}
          <button onclick={() => toggleStatus(s)} class={filterPillClass(activeStatuses.has(s))}>
            {STATUS_LABELS[s]}
          </button>
        {/each}
      </div>
    </div>
  </div>

  <!-- Groups -->
  <div class="space-y-3">
    {#each visibleGroups as groupKey}
      {@const groupSections = groupedSections().get(groupKey) ?? []}
      {@const groupExpanded = expandedGroups.has(groupKey)}

      <div class="rounded-lg border border-secondary-200 bg-white dark:border-secondary-700 dark:bg-secondary-900">

        <!-- Group header -->
        <button
          onclick={() => toggleGroupExpand(groupKey)}
          class="flex w-full items-center gap-2 px-4 py-3 text-left transition hover:bg-secondary-50 dark:hover:bg-secondary-800/50"
        >
          {#if groupExpanded}
            <ChevronDownOutline class="h-4 w-4 shrink-0 text-secondary-500" />
          {:else}
            <ChevronRightOutline class="h-4 w-4 shrink-0 text-secondary-500" />
          {/if}
          <span class="font-semibold text-secondary-800 dark:text-white">
            {GROUP_LABELS[groupKey]}
          </span>
          <span class="ml-1 text-sm font-normal text-secondary-500 dark:text-secondary-400">
            ({groupSections.length})
          </span>
        </button>

        <!-- Sections within group -->
        {#if groupExpanded}
          <div class="border-t border-secondary-100 dark:border-secondary-800">
            {#each groupSections as section (section.name)}
              {@const sectionExpanded = expandedSections.has(section.name)}

              <div class="border-b border-secondary-100 last:border-b-0 dark:border-secondary-800">

                <!-- Section header -->
                <button
                  onclick={() => toggleSectionExpand(section.name)}
                  class="flex w-full items-center gap-3 px-5 py-2.5 text-left transition hover:bg-secondary-50 dark:hover:bg-secondary-800/50"
                >
                  {#if sectionExpanded}
                    <ChevronDownOutline class="h-3.5 w-3.5 shrink-0 text-secondary-400" />
                  {:else}
                    <ChevronRightOutline class="h-3.5 w-3.5 shrink-0 text-secondary-400" />
                  {/if}

                  <span class="min-w-0 flex-1 font-medium text-secondary-800 dark:text-white">
                    {section.displayName}
                  </span>

                  <div class="flex shrink-0 items-center gap-2">
                    <Badge color={formalismBadgeColor(section.primaryFormalism)} class="text-xs">
                      {FORMALISM_LABELS[section.primaryFormalism] ?? section.primaryFormalism}
                    </Badge>
                    <Badge color={statusBadgeColor(section.implementationStatus)} class="text-xs">
                      {STATUS_LABELS[section.implementationStatus] ?? section.implementationStatus}
                    </Badge>
                  </div>
                </button>

                <!-- Expanded detail panel -->
                {#if sectionExpanded}
                  <div class="space-y-4 bg-secondary-50 px-6 py-4 dark:bg-secondary-800/30">

                    <!-- Purposive description -->
                    <p class="text-sm leading-relaxed text-secondary-700 dark:text-secondary-200">
                      {section.purposiveDescription}
                    </p>

                    <!-- ArchitecturalLocation summaries -->
                    <div class="grid gap-3 sm:grid-cols-2">

                      <div class="rounded border border-secondary-200 bg-white p-3 dark:border-secondary-700 dark:bg-secondary-900">
                        <dt class="mb-1 text-xs font-semibold uppercase tracking-wider text-secondary-500 dark:text-secondary-400">
                          Representational modality
                        </dt>
                        <dd class="text-sm text-secondary-700 dark:text-secondary-200">
                          {section.representationalModalitySummary}
                        </dd>
                      </div>

                      <div class="rounded border border-secondary-200 bg-white p-3 dark:border-secondary-700 dark:bg-secondary-900">
                        <dt class="mb-1 text-xs font-semibold uppercase tracking-wider text-secondary-500 dark:text-secondary-400">
                          Persistence
                        </dt>
                        <dd class="text-sm text-secondary-700 dark:text-secondary-200">
                          {section.persistenceSummary}
                        </dd>
                      </div>

                      <div class="rounded border border-secondary-200 bg-white p-3 dark:border-secondary-700 dark:bg-secondary-900">
                        <dt class="mb-1 text-xs font-semibold uppercase tracking-wider text-secondary-500 dark:text-secondary-400">
                          Interfaces
                        </dt>
                        <dd class="text-sm text-secondary-700 dark:text-secondary-200">
                          {section.interfacesSummary}
                        </dd>
                      </div>

                      <div class="rounded border border-secondary-200 bg-white p-3 dark:border-secondary-700 dark:bg-secondary-900">
                        <dt class="mb-1 text-xs font-semibold uppercase tracking-wider text-secondary-500 dark:text-secondary-400">
                          Domain illustration (Paws)
                        </dt>
                        <dd class="text-sm text-secondary-700 dark:text-secondary-200">
                          {section.domainIllustrationSummary}
                        </dd>
                      </div>

                    </div>
                  </div>
                {/if}

              </div>
            {/each}
          </div>
        {/if}

      </div>
    {/each}
  </div>
</div>
