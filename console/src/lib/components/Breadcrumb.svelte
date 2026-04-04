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
  </nav>
{/if}
