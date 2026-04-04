<script lang="ts">
  import { useNavigation } from '$lib/stores/navigation.svelte';

  const navStore = useNavigation();

  // Compute which indices to show, with overflow collapsing to first + … + last 3
  const visibleIndices = $derived.by(() => {
    const total = navStore.currentIndex + 1; // number of entries up to and including current
    if (total <= 5) {
      return Array.from({ length: total }, (_, i) => i);
    }
    // Show first, ellipsis marker (-1), then last 3 before current + current
    return [0, -1, navStore.currentIndex - 2, navStore.currentIndex - 1, navStore.currentIndex];
  });

  let exportLabel = $state('Export');

  async function handleExport() {
    const md = navStore.exportJourneyAsMarkdown();
    try {
      await navigator.clipboard.writeText(md);
      exportLabel = 'Copied!';
      setTimeout(() => { exportLabel = 'Export'; }, 2000);
    } catch {
      exportLabel = 'Failed';
      setTimeout(() => { exportLabel = 'Export'; }, 2000);
    }
  }
</script>

{#if navStore.stack.length > 1}
  <nav
    aria-label="Breadcrumb"
    class="mb-4 flex flex-wrap items-center gap-1 text-sm"
  >
    {#each visibleIndices as idx}
      {#if idx === -1}
        <!-- Ellipsis placeholder -->
        <span class="text-secondary-400 dark:text-secondary-500">…</span>
        <span class="text-secondary-300 dark:text-secondary-600">›</span>
      {:else}
        {#if idx > 0 && visibleIndices[visibleIndices.indexOf(idx) - 1] !== -1}
          <span class="text-secondary-300 dark:text-secondary-600">›</span>
        {/if}

        {#if idx === navStore.currentIndex}
          <!-- Current entry — not a link -->
          <span class="text-primary-700 dark:text-primary-300" aria-current="page">
            {navStore.stack[idx].label}
          </span>
        {:else}
          <!-- Past entry — clickable -->
          <button
            onclick={() => navStore.goToIndex(idx)}
            class="text-secondary-500 hover:text-secondary-700 dark:text-secondary-400 dark:hover:text-secondary-200"
          >
            {navStore.stack[idx].label}
          </button>
        {/if}
      {/if}
    {/each}

    <!-- Export + Reset buttons at the right -->
    <span class="ml-auto flex items-center gap-1">
      <button
        onclick={handleExport}
        class="rounded px-2 py-0.5 text-xs text-secondary-400 hover:bg-secondary-100 hover:text-secondary-600 dark:text-secondary-500 dark:hover:bg-secondary-800 dark:hover:text-secondary-300"
        title="Copy journey to clipboard"
      >
        {exportLabel}
      </button>
      <button
        onclick={() => navStore.reset()}
        class="rounded px-2 py-0.5 text-xs text-secondary-400 hover:bg-secondary-100 hover:text-secondary-600 dark:text-secondary-500 dark:hover:bg-secondary-800 dark:hover:text-secondary-300"
        title="Clear navigation history"
      >
        Reset
      </button>
    </span>
  </nav>
{/if}
