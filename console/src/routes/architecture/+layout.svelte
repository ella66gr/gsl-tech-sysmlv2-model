<script lang="ts">
  import { page } from '$app/stores';

  let { children } = $props();

  const currentPath = $derived($page.url.pathname);
  const isMapTab = $derived(currentPath.endsWith('/map') || currentPath === '/architecture');
  const isSectionsTab = $derived(currentPath.endsWith('/sections'));

  const tabClass = (active: boolean) =>
    `inline-block border-b-2 px-1 pb-3 text-sm font-medium transition ${
      active
        ? 'border-primary-500 text-primary-600 dark:border-primary-400 dark:text-primary-400'
        : 'border-transparent text-secondary-500 hover:border-secondary-300 hover:text-secondary-700 dark:text-secondary-400 dark:hover:border-secondary-500 dark:hover:text-secondary-300'
    }`;
</script>

<div class="space-y-0">
  <!-- Header -->
  <div class="mb-4">
    <h1 class="text-2xl font-bold text-secondary-800 dark:text-white">Platform Architecture</h1>
    <p class="mt-1 text-secondary-500 dark:text-secondary-300">
      Structural sections of the dual-stack architecture · 20 sections across 6 groups
    </p>
  </div>

  <!-- Tab bar -->
  <div class="mb-4 flex items-center gap-6 border-b border-secondary-200 dark:border-secondary-700">
    <a href="/architecture/map" class={tabClass(isMapTab)}>Map</a>
    <a href="/architecture/sections" class={tabClass(isSectionsTab)}>Sections</a>
  </div>

  {@render children()}
</div>
