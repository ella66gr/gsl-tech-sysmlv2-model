<script lang="ts">
  import { Badge } from 'flowbite-svelte';
  import { fly } from 'svelte/transition';
  import type { ArchitecturalSection } from '../+layout.ts';

  let { data } = $props();

  const allSections: ArchitecturalSection[] = data.architecture.sections;

  function stripPrefix(value: string): string {
    return value && value.includes('::') ? value.split('::').pop()! : (value ?? '');
  }

  const sections = allSections.map((s) => ({
    ...s,
    group: stripPrefix(s.group),
    primaryFormalism: stripPrefix(s.primaryFormalism),
    implementationStatus: stripPrefix(s.implementationStatus),
  }));

  // SMM rename — override displayName for bsmm-general-vocabulary
  const DISPLAY_OVERRIDES: Record<string, string> = {
    'bsmm-general-vocabulary': 'SMM General Vocabulary',
  };
  function sectionDisplayName(s: ArchitecturalSection): string {
    return DISPLAY_OVERRIDES[s.name] ?? s.displayName;
  }

  function sec(name: string) {
    return sections.find((s) => s.name === name);
  }

  // --- Detail panel ---
  let selectedName = $state<string | null>(null);
  const selectedSection = $derived(selectedName ? sec(selectedName) : null);

  function openSection(name: string) {
    selectedName = name;
    if (typeof window !== 'undefined') {
      const url = new URL(window.location.href);
      url.searchParams.set('section', name);
      history.replaceState(history.state, '', url.toString());
    }
  }

  function closePanel() {
    selectedName = null;
    if (typeof window !== 'undefined') {
      const url = new URL(window.location.href);
      url.searchParams.delete('section');
      history.replaceState(history.state, '', url.toString());
    }
  }

  $effect(() => {
    if (typeof window !== 'undefined') {
      const params = new URLSearchParams(window.location.search);
      const s = params.get('section');
      if (s && sec(s)) selectedName = s;
    }
  });

  function handleKeydown(e: KeyboardEvent) {
    if (e.key === 'Escape') closePanel();
  }

  const HORIZONTAL_MAPPINGS = [
    { left: 'domain-ontologies', right: 'system-ontological-categories', label: 'classifies / constrains' },
    { left: 'bmm-general-vocabulary', right: 'bsmm-general-vocabulary', label: 'maps to' },
    { left: 'business-instance', right: 'system-instance', label: 'realised by' },
    { left: 'operational-domains', right: 'system-domains', label: 'realised by' },
    { left: 'business-process-patterns', right: 'operational-simulation', label: 'executed as' },
  ] as const;

  const REFLECTIVE_CAPABILITIES = [
    'Trajectories', 'Projections', 'Anomaly detection', 'Option analysis',
    'What-if scenarios', 'Valence assessment', 'Gap analysis', 'Guidance generation',
  ] as const;

  const INFRA_SECTIONS = [
    'terminology-and-information-carriers', 'mapping-ontology', 'knowledge-graph',
    'sysml-v2', 'openehr', 'temporal',
  ] as const;

  const FORMALISM_LABELS: Record<string, string> = {
    owl2dl: 'OWL 2 DL', sysmlV2: 'SysML v2', runtime: 'Runtime', mixed: 'Mixed',
  };
  const STATUS_LABELS: Record<string, string> = {
    implemented: 'Implemented', designed: 'Designed', referenced: 'Referenced', notStarted: 'Not Started',
  };

  function formalismBadgeColor(f: string) {
    return ({ owl2dl: 'purple', sysmlV2: 'blue', runtime: 'green', mixed: 'yellow' } as Record<string,string>)[f] ?? 'dark';
  }
  function statusBadgeColor(s: string) {
    return ({ implemented: 'green', designed: 'orange', referenced: 'yellow', notStarted: 'dark' } as Record<string,string>)[s] ?? 'dark';
  }
</script>

<svelte:window onkeydown={handleKeydown} />

<!--
  GRID ROW MAP (main grid)
  Row  1 : BFO (col 1–4)
  Row  2 : Arrow row — stone↓ col 1, stone↓ col 3
  Row  3 : Domain Ontologies (col 1) | Mapping A (col 2) | Sys Onto Cats (col 3) | Reflective Sim (col 4, rows 3–11)
  Row  4 : Arrow row — green↓ col 1 & col 3  (→ formalism boundary)
  Row  5 : Formalism Boundary (col 1–3)
  Row  6 : Arrow row — green↓ col 1 & col 3  (← formalism boundary)
  Row  7 : BMM Gen Vocab (col 1) | Mapping B (col 2) | SMM Gen Vocab (col 3)
  Row  8 : Arrow row — terracotta↓ col 1, blue↓ col 3
  Row  9 : Business Instance (col 1) | Mapping C (col 2) | System Instance (col 3)
  Row 10 : Arrow row — terracotta↓ col 1, blue↓ col 3  (entering rules & constraints container)
  Row 11 : Rules & Constraints Container wrapper (col 1–3)
  Row 12 : Infrastructure (col 1–4)
  Row 13 : Operator (col 1–4)
-->

{#snippet verticalArrow(color: string, opacity: number)}
  <div class="flex items-center justify-center" style="min-height: 0.25rem; margin: -0.15rem 0;">
    <svg width="18" height="20" viewBox="0 0 18 20" fill="none" class="block">
      <!-- Upward arrowhead -->
      <path d="M9 0L3 5h12L9 0z" fill={color} opacity={opacity}/>
      <!-- Vertical line -->
      <rect x="7" y="5" width="4" height="10" rx="2" fill={color} opacity={opacity}/>
      <!-- Downward arrowhead -->
      <path d="M9 20L15 15H3L9 20z" fill={color} opacity={opacity}/>
    </svg>
  </div>
{/snippet}

<div class="relative">
  <div class="arch-grid">

    <!-- ── Row 1: BFO ─────────────────────────────────────────── -->
    {#if sec('bfo')}
      {@const s = sec('bfo')!}
      <div class="arch-card arch-found col-span-full cursor-pointer" style="grid-row: 1;"
        role="button" tabindex="0"
        onclick={() => openSection(s.name)} onkeydown={(e) => e.key === 'Enter' && openSection(s.name)}>
        <div class="arch-card-header arch-found-heading">{sectionDisplayName(s)}</div>
        <div class="arch-card-badges">
          <Badge color={formalismBadgeColor(s.primaryFormalism)} class="text-xs">{FORMALISM_LABELS[s.primaryFormalism] ?? s.primaryFormalism}</Badge>
          <Badge color={statusBadgeColor(s.implementationStatus)} class="text-xs">{STATUS_LABELS[s.implementationStatus] ?? s.implementationStatus}</Badge>
        </div>
        <p class="arch-card-desc">{s.shortDescription}</p>
      </div>
    {/if}

    <!-- ── Row 2: Arrow row — BFO → both stacks (stone) ────────── -->
    <div style="grid-column: 1; grid-row: 2;">{@render verticalArrow('var(--arch-found-heading)', 0.5)}</div>
    <div style="grid-column: 3; grid-row: 2;">{@render verticalArrow('var(--arch-found-heading)', 0.5)}</div>

    <!-- ── Row 3: Domain Ontologies | Mapping A | Sys Onto Cats ── -->
    {#if sec('domain-ontologies')}
      {@const s = sec('domain-ontologies')!}
      <div class="arch-card arch-left cursor-pointer" style="grid-column: 1; grid-row: 3;"
        role="button" tabindex="0"
        onclick={() => openSection(s.name)} onkeydown={(e) => e.key === 'Enter' && openSection(s.name)}>
        <div class="arch-card-header arch-left-heading">{sectionDisplayName(s)}</div>
        <div class="arch-card-badges">
          <Badge color={formalismBadgeColor(s.primaryFormalism)} class="text-xs">{FORMALISM_LABELS[s.primaryFormalism] ?? s.primaryFormalism}</Badge>
          <Badge color={statusBadgeColor(s.implementationStatus)} class="text-xs">{STATUS_LABELS[s.implementationStatus] ?? s.implementationStatus}</Badge>
        </div>
      </div>
    {/if}

    <div class="mapping-col" style="grid-column: 2; grid-row: 3;">
      <div class="mapping-arrow-wrap">
        <div class="mapping-line"></div>
        <span class="mapping-label">{HORIZONTAL_MAPPINGS[0].label}</span>
      </div>
    </div>

    {#if sec('system-ontological-categories')}
      {@const s = sec('system-ontological-categories')!}
      <div class="arch-card arch-right cursor-pointer" style="grid-column: 3; grid-row: 3;"
        role="button" tabindex="0"
        onclick={() => openSection(s.name)} onkeydown={(e) => e.key === 'Enter' && openSection(s.name)}>
        <div class="arch-card-header arch-right-heading">{sectionDisplayName(s)}</div>
        <div class="arch-card-badges">
          <Badge color={formalismBadgeColor(s.primaryFormalism)} class="text-xs">{FORMALISM_LABELS[s.primaryFormalism] ?? s.primaryFormalism}</Badge>
          <Badge color={statusBadgeColor(s.implementationStatus)} class="text-xs">{STATUS_LABELS[s.implementationStatus] ?? s.implementationStatus}</Badge>
        </div>
      </div>
    {/if}

    <!-- Reflective Simulation — spans rows 3–11, col 4 -->
    {#if sec('reflective-simulation')}
      {@const s = sec('reflective-simulation')!}
      <div class="arch-card arch-reflect cursor-pointer reflect-tall" style="grid-column: 4; grid-row: 3 / 12;"
        role="button" tabindex="0"
        onclick={() => openSection(s.name)} onkeydown={(e) => e.key === 'Enter' && openSection(s.name)}>
        <div class="arch-card-header arch-reflect-heading">{sectionDisplayName(s)}</div>
        <div class="arch-card-badges mb-3">
          <Badge color={formalismBadgeColor(s.primaryFormalism)} class="text-xs">{FORMALISM_LABELS[s.primaryFormalism] ?? s.primaryFormalism}</Badge>
          <Badge color={statusBadgeColor(s.implementationStatus)} class="text-xs">{STATUS_LABELS[s.implementationStatus] ?? s.implementationStatus}</Badge>
        </div>
        <div class="flex flex-wrap gap-1.5">
          {#each REFLECTIVE_CAPABILITIES as cap}
            <span class="reflect-chip">{cap}</span>
          {/each}
        </div>
      </div>
    {/if}

    <!-- ── Row 4: Arrow row — crossing into formalism boundary (green) ── -->
    <div style="grid-column: 1; grid-row: 4;">{@render verticalArrow('var(--arch-green-heading)', 0.7)}</div>
    <div style="grid-column: 3; grid-row: 4;">{@render verticalArrow('var(--arch-green-heading)', 0.7)}</div>

    <!-- ── Row 5: Formalism Boundary ─────────────────────────── -->
    <div class="formalism-boundary" style="grid-column: 1 / 4; grid-row: 5;">
      <span class="formalism-boundary-text">Formalism Boundary — OWL 2 DL ↔ SysML v2</span>
    </div>

    <!-- ── Row 6: Arrow row — crossing out of formalism boundary (green) ── -->
    <div style="grid-column: 1; grid-row: 6;">{@render verticalArrow('var(--arch-green-heading)', 0.7)}</div>
    <div style="grid-column: 3; grid-row: 6;">{@render verticalArrow('var(--arch-green-heading)', 0.7)}</div>

    <!-- ── Row 7: BMM General Vocabulary | Mapping B | SMM General Vocabulary ── -->
    {#if sec('bmm-general-vocabulary')}
      {@const s = sec('bmm-general-vocabulary')!}
      <div class="arch-card arch-left cursor-pointer" style="grid-column: 1; grid-row: 7;"
        role="button" tabindex="0"
        onclick={() => openSection(s.name)} onkeydown={(e) => e.key === 'Enter' && openSection(s.name)}>
        <div class="arch-card-header arch-left-heading">{sectionDisplayName(s)}</div>
        <div class="arch-card-badges">
          <Badge color={formalismBadgeColor(s.primaryFormalism)} class="text-xs">{FORMALISM_LABELS[s.primaryFormalism] ?? s.primaryFormalism}</Badge>
          <Badge color={statusBadgeColor(s.implementationStatus)} class="text-xs">{STATUS_LABELS[s.implementationStatus] ?? s.implementationStatus}</Badge>
        </div>
      </div>
    {/if}

    <div class="mapping-col" style="grid-column: 2; grid-row: 7;">
      <div class="mapping-arrow-wrap">
        <div class="mapping-line"></div>
        <span class="mapping-label">{HORIZONTAL_MAPPINGS[1].label}</span>
      </div>
    </div>

    {#if sec('bsmm-general-vocabulary')}
      {@const s = sec('bsmm-general-vocabulary')!}
      <div class="arch-card arch-right cursor-pointer" style="grid-column: 3; grid-row: 7;"
        role="button" tabindex="0"
        onclick={() => openSection(s.name)} onkeydown={(e) => e.key === 'Enter' && openSection(s.name)}>
        <div class="arch-card-header arch-right-heading">{sectionDisplayName(s)}</div>
        <div class="arch-card-badges">
          <Badge color={formalismBadgeColor(s.primaryFormalism)} class="text-xs">{FORMALISM_LABELS[s.primaryFormalism] ?? s.primaryFormalism}</Badge>
          <Badge color={statusBadgeColor(s.implementationStatus)} class="text-xs">{STATUS_LABELS[s.implementationStatus] ?? s.implementationStatus}</Badge>
        </div>
      </div>
    {/if}

    <!-- ── Row 8: Arrow row — terracotta↓ left, blue↓ right ───── -->
    <div style="grid-column: 1; grid-row: 8;">{@render verticalArrow('var(--arch-left-heading)', 0.5)}</div>
    <div style="grid-column: 3; grid-row: 8;">{@render verticalArrow('var(--arch-right-heading)', 0.5)}</div>

    <!-- ── Row 9: Business Instance | Mapping C | System Instance ── -->
    {#if sec('business-instance')}
      {@const s = sec('business-instance')!}
      <div class="arch-card arch-left cursor-pointer" style="grid-column: 1; grid-row: 9;"
        role="button" tabindex="0"
        onclick={() => openSection(s.name)} onkeydown={(e) => e.key === 'Enter' && openSection(s.name)}>
        <div class="arch-card-header arch-left-heading">{sectionDisplayName(s)}</div>
        <div class="arch-card-badges">
          <Badge color={formalismBadgeColor(s.primaryFormalism)} class="text-xs">{FORMALISM_LABELS[s.primaryFormalism] ?? s.primaryFormalism}</Badge>
          <Badge color={statusBadgeColor(s.implementationStatus)} class="text-xs">{STATUS_LABELS[s.implementationStatus] ?? s.implementationStatus}</Badge>
        </div>
      </div>
    {/if}

    <div class="mapping-col" style="grid-column: 2; grid-row: 9;">
      <div class="mapping-arrow-wrap">
        <div class="mapping-line"></div>
        <span class="mapping-label">{HORIZONTAL_MAPPINGS[2].label}</span>
      </div>
    </div>

    {#if sec('system-instance')}
      {@const s = sec('system-instance')!}
      <div class="arch-card arch-right cursor-pointer" style="grid-column: 3; grid-row: 9;"
        role="button" tabindex="0"
        onclick={() => openSection(s.name)} onkeydown={(e) => e.key === 'Enter' && openSection(s.name)}>
        <div class="arch-card-header arch-right-heading">{sectionDisplayName(s)}</div>
        <div class="arch-card-badges">
          <Badge color={formalismBadgeColor(s.primaryFormalism)} class="text-xs">{FORMALISM_LABELS[s.primaryFormalism] ?? s.primaryFormalism}</Badge>
          <Badge color={statusBadgeColor(s.implementationStatus)} class="text-xs">{STATUS_LABELS[s.implementationStatus] ?? s.implementationStatus}</Badge>
        </div>
      </div>
    {/if}

    <!-- ── Row 10: Arrow row — entering rules & constraints container ── -->
    <div style="grid-column: 1; grid-row: 10;">{@render verticalArrow('var(--arch-left-heading)', 0.5)}</div>
    <div style="grid-column: 3; grid-row: 10;">{@render verticalArrow('var(--arch-right-heading)', 0.5)}</div>

    <!-- ── Row 11: Rules & Constraints Container (cols 1–3) ────── -->
    <div class="green-container-wrapper" style="grid-column: 1 / 4; grid-row: 11;">
      <div class="green-label">Rules &amp; Constraints Container</div>
      <div class="green-inner-grid">

        <!-- Sub-row 1: Operational Domains | Mapping D | System Domains -->
        {#if sec('operational-domains')}
          {@const s = sec('operational-domains')!}
          <div class="arch-card arch-left cursor-pointer" style="grid-column: 1; grid-row: 1;"
            role="button" tabindex="0"
            onclick={() => openSection(s.name)} onkeydown={(e) => e.key === 'Enter' && openSection(s.name)}>
            <div class="arch-card-header arch-left-heading">{sectionDisplayName(s)}</div>
            <div class="arch-card-badges">
              <Badge color={formalismBadgeColor(s.primaryFormalism)} class="text-xs">{FORMALISM_LABELS[s.primaryFormalism] ?? s.primaryFormalism}</Badge>
              <Badge color={statusBadgeColor(s.implementationStatus)} class="text-xs">{STATUS_LABELS[s.implementationStatus] ?? s.implementationStatus}</Badge>
            </div>
          </div>
        {/if}

        <div class="mapping-col" style="grid-column: 2; grid-row: 1;">
          <div class="mapping-arrow-wrap">
            <div class="mapping-line"></div>
            <span class="mapping-label">{HORIZONTAL_MAPPINGS[3].label}</span>
          </div>
        </div>

        {#if sec('system-domains')}
          {@const s = sec('system-domains')!}
          <div class="arch-card arch-right cursor-pointer" style="grid-column: 3; grid-row: 1;"
            role="button" tabindex="0"
            onclick={() => openSection(s.name)} onkeydown={(e) => e.key === 'Enter' && openSection(s.name)}>
            <div class="arch-card-header arch-right-heading">{sectionDisplayName(s)}</div>
            <div class="arch-card-badges">
              <Badge color={formalismBadgeColor(s.primaryFormalism)} class="text-xs">{FORMALISM_LABELS[s.primaryFormalism] ?? s.primaryFormalism}</Badge>
              <Badge color={statusBadgeColor(s.implementationStatus)} class="text-xs">{STATUS_LABELS[s.implementationStatus] ?? s.implementationStatus}</Badge>
            </div>
          </div>
        {/if}

        <!-- Sub-row 2: Arrow row inside green container -->
        <div style="grid-column: 1; grid-row: 2;">{@render verticalArrow('var(--arch-left-heading)', 0.5)}</div>
        <div style="grid-column: 3; grid-row: 2;">{@render verticalArrow('var(--arch-right-heading)', 0.5)}</div>

        <!-- Sub-row 3: Business Process Patterns | Mapping E | Operational Simulation -->
        {#if sec('business-process-patterns')}
          {@const s = sec('business-process-patterns')!}
          <div class="arch-card arch-left cursor-pointer" style="grid-column: 1; grid-row: 3;"
            role="button" tabindex="0"
            onclick={() => openSection(s.name)} onkeydown={(e) => e.key === 'Enter' && openSection(s.name)}>
            <div class="arch-card-header arch-left-heading">{sectionDisplayName(s)}</div>
            <div class="arch-card-badges">
              <Badge color={formalismBadgeColor(s.primaryFormalism)} class="text-xs">{FORMALISM_LABELS[s.primaryFormalism] ?? s.primaryFormalism}</Badge>
              <Badge color={statusBadgeColor(s.implementationStatus)} class="text-xs">{STATUS_LABELS[s.implementationStatus] ?? s.implementationStatus}</Badge>
            </div>
          </div>
        {/if}

        <div class="mapping-col" style="grid-column: 2; grid-row: 3;">
          <div class="mapping-arrow-wrap">
            <div class="mapping-line"></div>
            <span class="mapping-label">{HORIZONTAL_MAPPINGS[4].label}</span>
          </div>
        </div>

        {#if sec('operational-simulation')}
          {@const s = sec('operational-simulation')!}
          <div class="arch-card arch-right cursor-pointer" style="grid-column: 3; grid-row: 3;"
            role="button" tabindex="0"
            onclick={() => openSection(s.name)} onkeydown={(e) => e.key === 'Enter' && openSection(s.name)}>
            <div class="arch-card-header arch-right-heading">{sectionDisplayName(s)}</div>
            <div class="arch-card-badges">
              <Badge color={formalismBadgeColor(s.primaryFormalism)} class="text-xs">{FORMALISM_LABELS[s.primaryFormalism] ?? s.primaryFormalism}</Badge>
              <Badge color={statusBadgeColor(s.implementationStatus)} class="text-xs">{STATUS_LABELS[s.implementationStatus] ?? s.implementationStatus}</Badge>
            </div>
          </div>
        {/if}

        <!-- Sub-row 4: Rules and Constraints — spans all inner cols -->
        {#if sec('rules-and-constraints')}
          {@const s = sec('rules-and-constraints')!}
          <div class="arch-card arch-rules cursor-pointer" style="grid-column: 1 / -1; grid-row: 4;"
            role="button" tabindex="0"
            onclick={() => openSection(s.name)} onkeydown={(e) => e.key === 'Enter' && openSection(s.name)}>
            <div class="arch-card-header" style="color: var(--arch-green-heading);">{sectionDisplayName(s)}</div>
            <div class="arch-card-badges">
              <Badge color={formalismBadgeColor(s.primaryFormalism)} class="text-xs">{FORMALISM_LABELS[s.primaryFormalism] ?? s.primaryFormalism}</Badge>
              <Badge color={statusBadgeColor(s.implementationStatus)} class="text-xs">{STATUS_LABELS[s.implementationStatus] ?? s.implementationStatus}</Badge>
            </div>
            <p class="arch-card-desc">{s.shortDescription}</p>
          </div>
        {/if}

      </div><!-- /green-inner-grid -->
    </div><!-- /green-container-wrapper -->

    <!-- ── Row 12: Infrastructure ─────────────────────────────── -->
    <div class="arch-card arch-infra col-span-full" style="grid-row: 12;">
      <div class="arch-card-header arch-infra-heading mb-3">Infrastructure</div>
      <div class="infra-inner-grid">
        {#each INFRA_SECTIONS as name}
          {#if sec(name)}
            {@const s = sec(name)!}
            <div class="arch-card arch-infra-item cursor-pointer"
              role="button" tabindex="0"
              onclick={() => openSection(s.name)} onkeydown={(e) => e.key === 'Enter' && openSection(s.name)}>
              <div class="arch-card-header arch-infra-heading text-sm">{sectionDisplayName(s)}</div>
              <div class="arch-card-badges mt-1">
                <Badge color={formalismBadgeColor(s.primaryFormalism)} class="text-xs">{FORMALISM_LABELS[s.primaryFormalism] ?? s.primaryFormalism}</Badge>
                <Badge color={statusBadgeColor(s.implementationStatus)} class="text-xs">{STATUS_LABELS[s.implementationStatus] ?? s.implementationStatus}</Badge>
              </div>
            </div>
          {/if}
        {/each}
      </div>
    </div>

    <!-- ── Row 13: Operator ───────────────────────────────────── -->
    {#if sec('operator')}
      {@const s = sec('operator')!}
      <div class="arch-card arch-operator col-span-full cursor-pointer text-center" style="grid-row: 13;"
        role="button" tabindex="0"
        onclick={() => openSection(s.name)} onkeydown={(e) => e.key === 'Enter' && openSection(s.name)}>
        <div class="arch-card-header arch-operator-heading">{sectionDisplayName(s)}</div>
        <div class="arch-card-badges justify-center">
          <Badge color={formalismBadgeColor(s.primaryFormalism)} class="text-xs">{FORMALISM_LABELS[s.primaryFormalism] ?? s.primaryFormalism}</Badge>
          <Badge color={statusBadgeColor(s.implementationStatus)} class="text-xs">{STATUS_LABELS[s.implementationStatus] ?? s.implementationStatus}</Badge>
        </div>
        <p class="arch-card-desc">{s.shortDescription}</p>
      </div>
    {/if}

  </div><!-- /arch-grid -->

  <!-- ── Detail side panel ─────────────────────────────────────── -->
  {#if selectedSection}
    <button class="fixed inset-0 z-40 bg-black/5 dark:bg-black/10"
      onclick={closePanel} aria-label="Close detail panel"></button>

    <div class="fixed right-0 top-16 z-50 h-[calc(100dvh-4rem)] w-96 overflow-y-auto shadow-2xl"
      style="background-color: var(--arch-panel-bg); backdrop-filter: blur(16px); -webkit-backdrop-filter: blur(16px);"
      transition:fly={{ x: 100, duration: 200 }}>
      <div class="p-5">
        <div class="mb-4 flex items-center justify-between">
          <h2 class="text-lg font-bold text-secondary-800 dark:text-white">
            {selectedSection ? sectionDisplayName(selectedSection) : ''}
          </h2>
          <button onclick={closePanel}
            class="rounded-lg p-1.5 text-secondary-500 hover:bg-secondary-100/80 dark:text-secondary-400 dark:hover:bg-secondary-800/80"
            aria-label="Close">
            <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        {#if selectedSection}
          <div class="mb-4 flex flex-wrap gap-2">
            <Badge color={formalismBadgeColor(selectedSection.primaryFormalism)}>
              {FORMALISM_LABELS[selectedSection.primaryFormalism] ?? selectedSection.primaryFormalism}
            </Badge>
            <Badge color={statusBadgeColor(selectedSection.implementationStatus)}>
              {STATUS_LABELS[selectedSection.implementationStatus] ?? selectedSection.implementationStatus}
            </Badge>
          </div>

          {#if selectedSection.purposiveDescription}
            <p class="mb-5 text-sm leading-relaxed text-secondary-700 dark:text-secondary-200">
              {selectedSection.purposiveDescription}
            </p>
          {/if}

          <div class="grid grid-cols-1 gap-3 sm:grid-cols-2">
            {#if selectedSection.representationalModalitySummary}
              <div class="rounded border border-secondary-200/80 bg-secondary-50/80 p-3 dark:border-secondary-700/80 dark:bg-secondary-800/80">
                <dt class="mb-1 text-xs font-semibold uppercase tracking-wider text-secondary-500 dark:text-secondary-400">Modality</dt>
                <dd class="text-sm text-secondary-700 dark:text-secondary-200">{selectedSection.representationalModalitySummary}</dd>
              </div>
            {/if}
            {#if selectedSection.persistenceSummary}
              <div class="rounded border border-secondary-200/80 bg-secondary-50/80 p-3 dark:border-secondary-700/80 dark:bg-secondary-800/80">
                <dt class="mb-1 text-xs font-semibold uppercase tracking-wider text-secondary-500 dark:text-secondary-400">Persistence</dt>
                <dd class="text-sm text-secondary-700 dark:text-secondary-200">{selectedSection.persistenceSummary}</dd>
              </div>
            {/if}
            {#if selectedSection.interfacesSummary}
              <div class="rounded border border-secondary-200/80 bg-secondary-50/80 p-3 dark:border-secondary-700/80 dark:bg-secondary-800/80">
                <dt class="mb-1 text-xs font-semibold uppercase tracking-wider text-secondary-500 dark:text-secondary-400">Interfaces</dt>
                <dd class="text-sm text-secondary-700 dark:text-secondary-200">{selectedSection.interfacesSummary}</dd>
              </div>
            {/if}
            {#if selectedSection.domainIllustrationSummary}
              <div class="rounded border border-secondary-200/80 bg-secondary-50/80 p-3 dark:border-secondary-700/80 dark:bg-secondary-800/80">
                <dt class="mb-1 text-xs font-semibold uppercase tracking-wider text-secondary-500 dark:text-secondary-400">Domain (Paws)</dt>
                <dd class="text-sm text-secondary-700 dark:text-secondary-200">{selectedSection.domainIllustrationSummary}</dd>
              </div>
            {/if}
          </div>

          <div class="mt-5 border-t border-secondary-200/80 pt-4 dark:border-secondary-700/80">
            <a href="/architecture/sections"
              class="text-sm font-medium text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300">
              View in Sections tab →
            </a>
          </div>
        {/if}
      </div>
    </div>
  {/if}
</div>

<style>
  :global(html) {
    --arch-panel-bg: rgba(255, 255, 255, 0.18);
    --arch-left-bg: #FFB4A2;
    --arch-left-border: #E5989B;
    --arch-left-heading: #4a2020;
    --arch-right-bg: #E5989B;
    --arch-right-border: #B5838D;
    --arch-right-heading: #3d1a2a;
    --arch-found-bg: #FFCDB2;
    --arch-found-border: #E5989B;
    --arch-found-heading: #3a1a0e;
    --arch-reflect-bg: #B5838D;
    --arch-reflect-border: #917681;
    --arch-reflect-heading: #2a0e18;
    --arch-green-border: #917681;
    --arch-green-bg: #f5ebe8;
    --arch-green-heading: #4a3040;
    --arch-infra-bg: #ebe4e1;
    --arch-infra-border: #917681;
    --arch-infra-heading: #3d2e35;
    --arch-operator-bg: #917681;
    --arch-operator-border: #6D6875;
    --arch-operator-heading: #ffffff;
  }
  :global(html.dark) {
    --arch-panel-bg: rgba(31, 41, 55, 0.22);
    --arch-left-bg: #1F2F22;
    --arch-left-border: #3E563E;
    --arch-left-heading: #CED9DF;
    --arch-right-bg: #3E563E;
    --arch-right-border: #5a7a5a;
    --arch-right-heading: #CED9DF;
    --arch-found-bg: #7993A0;
    --arch-found-border: #93aab5;
    --arch-found-heading: #ffffff;
    --arch-reflect-bg: #93A889;
    --arch-reflect-border: #adbfa5;
    --arch-reflect-heading: #ffffff;
    --arch-green-border: #3E563E;
    --arch-green-bg: #151f16;
    --arch-green-heading: #93A889;
    --arch-infra-bg: #1a2520;
    --arch-infra-border: #3E563E;
    --arch-infra-heading: #CED9DF;
    --arch-operator-bg: #091008;
    --arch-operator-border: #1F2F22;
    --arch-operator-heading: #CED9DF;
  }

  /* Main grid — 1rem gap gives arrow rows room to breathe */
  .arch-grid {
    display: grid;
    grid-template-columns: 1fr 3.5rem 1fr 14rem;
    gap: 0.5rem;
    position: relative;
  }

  .arch-card {
    border-radius: 0.5rem;
    border-width: 1px;
    border-style: solid;
    padding: 0.75rem 1rem;
    position: relative;
    transition: transform 0.15s, box-shadow 0.15s;
  }
  .arch-card:hover {
    transform: scale(1.01);
    box-shadow: 0 4px 16px rgba(0,0,0,0.1);
  }

  .arch-card-header { font-size: 0.875rem; font-weight: 600; margin-bottom: 0.375rem; }
  .arch-card-badges { display: flex; flex-wrap: wrap; gap: 0.375rem; margin-bottom: 0.25rem; }
  .arch-card-desc { font-size: 0.75rem; color: #4a3040; margin-top: 0.375rem; line-height: 1.4; }
  :global(html.dark) .arch-card-desc { color: #dce4e8; }

  .arch-operator .arch-card-desc { color: #2a1520; }
  .arch-reflect .arch-card-desc { color: #2a1520; }

  .arch-left    { background-color: var(--arch-left-bg);     border-color: var(--arch-left-border); }
  .arch-right   { background-color: var(--arch-right-bg);    border-color: var(--arch-right-border); }
  .arch-found   { background-color: var(--arch-found-bg);    border-color: var(--arch-found-border); }
  .arch-reflect { background-color: var(--arch-reflect-bg);  border-color: var(--arch-reflect-border); }
  .arch-rules   { background-color: var(--arch-green-bg);    border-color: var(--arch-green-border); }
  .arch-infra   { background-color: var(--arch-infra-bg);    border-color: var(--arch-infra-border); }
  .arch-operator{ background-color: var(--arch-operator-bg); border-color: var(--arch-operator-border); }

  .arch-left-heading    { color: var(--arch-left-heading); }
  .arch-right-heading   { color: var(--arch-right-heading); }
  .arch-found-heading   { color: var(--arch-found-heading); }
  .arch-reflect-heading { color: var(--arch-reflect-heading); }
  .arch-infra-heading   { color: var(--arch-infra-heading); }
  .arch-operator-heading{ color: var(--arch-operator-heading); }

  .arch-infra-item { background-color: var(--arch-infra-bg); border-color: var(--arch-infra-border); padding: 0.5rem 0.75rem; }

  .reflect-tall { display: flex; flex-direction: column; }
  .reflect-chip {
    font-size: 0.7rem; font-weight: 500; padding: 0.2rem 0.6rem;
    border-radius: 9999px;
    background-color: rgba(255,255,255,0.45);
    color: #2a0e18;
    border: 1px solid var(--arch-reflect-border);
  }
  :global(html.dark) .reflect-chip {
    background-color: rgba(147,168,137,0.25);
  }

  .formalism-boundary {
    border-radius: 0.375rem; padding: 0.375rem 1rem; text-align: center;
    background: linear-gradient(90deg, rgba(99,153,34,0.08) 0%, rgba(99,153,34,0.15) 50%, rgba(99,153,34,0.08) 100%);
    border: 1px dashed var(--arch-green-border);
    background-size: 200% 100%;
    animation: boundary-slide 4s linear infinite;
  }
  @keyframes boundary-slide { 0% { background-position: 0% 0%; } 100% { background-position: 200% 0%; } }
  .formalism-boundary-text {
    font-size: 0.7rem; font-weight: 600; letter-spacing: 0.05em;
    text-transform: uppercase; color: var(--arch-green-heading);
  }

  .mapping-col { display: flex; align-items: center; justify-content: center; position: relative; cursor: default; }
  .mapping-arrow-wrap { display: flex; flex-direction: column; align-items: center; gap: 0.25rem; width: 100%; }
  .mapping-line {
    width: 100%; height: 5px;
    background: #8B7355;
    opacity: 0.5; border-radius: 2px; position: relative;
  }
  :global(html.dark) .mapping-line { background: #D6C8B4; opacity: 0.4; }
  .mapping-line::before, .mapping-line::after {
    content: ''; position: absolute; top: 50%; transform: translateY(-50%); width: 0; height: 0;
  }
  .mapping-line::before {
    left: -10px; border-top: 7px solid transparent; border-bottom: 7px solid transparent;
    border-right: 10px solid #8B7355;
  }
  :global(html.dark) .mapping-line::before { border-right-color: #D6C8B4; }
  .mapping-line::after {
    right: -10px; border-top: 7px solid transparent; border-bottom: 7px solid transparent;
    border-left: 10px solid #8B7355;
  }
  :global(html.dark) .mapping-line::after { border-left-color: #D6C8B4; }
  .mapping-label { font-size: 0.6rem; font-weight: 500; white-space: nowrap; color: #6b7280; text-align: center; }
  :global(html.dark) .mapping-label { color: #9ca3af; }

  .green-container-wrapper {
    border: 2px dashed var(--arch-green-border);
    border-radius: 0.75rem; padding: 0.75rem;
    background-color: var(--arch-green-bg); position: relative;
  }
  .green-label {
    font-size: 0.6rem; font-weight: 700; letter-spacing: 0.08em;
    text-transform: uppercase; color: var(--arch-green-heading); margin-bottom: 0.5rem; opacity: 0.8;
  }
  .green-inner-grid {
    display: grid; grid-template-columns: 1fr 3.5rem 1fr; gap: 0.5rem;
  }

  .infra-inner-grid {
    display: grid; grid-template-columns: repeat(auto-fill, minmax(10rem, 1fr)); gap: 0.5rem;
  }

  /* ============================================================
     Badge colour overrides — light and dark mode.
     More intense than Flowbite defaults for visual clarity.
     Original Designed override agreed Session 92; expanded Session 122.
  ============================================================ */
  /* Purple — OWL 2 DL */
  :global(.relative :is([class*="bg-purple-100"])) {
    background-color: #7c3aed !important;
    color: #ffffff !important;
  }
  /* Blue — SysML v2 */
  :global(.relative :is([class*="bg-blue-100"])) {
    background-color: #2563eb !important;
    color: #ffffff !important;
  }
  /* Green — Implemented / Runtime */
  :global(.relative :is([class*="bg-green-100"])) {
    background-color: #16a34a !important;
    color: #ffffff !important;
  }
  /* Yellow — Mixed / Referenced */
  :global(.relative :is([class*="bg-yellow-100"])) {
    background-color: #ca8a04 !important;
    color: #ffffff !important;
  }
  /* Orange — Designed */
  :global(.relative :is([class*="bg-orange-100"])) {
    background-color: #ea580c !important;
    color: #ffffff !important;
  }
  /* Dark mode overrides */
  :global(html.dark .relative :is([class*="bg-orange-"])) {
    background-color: #5c4033 !important;
    color: #d4b8a0 !important;
  }
  :global(html.dark .relative :is([class*="bg-yellow-"])) {
    background-color: #3d3c1e !important;
    color: #c8c48a !important;
  }
</style>
