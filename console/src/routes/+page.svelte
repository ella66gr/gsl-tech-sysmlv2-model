<script lang="ts">
  import { Badge } from 'flowbite-svelte';
</script>

<div class="space-y-6">
  <div>
    <h1 class="text-2xl font-bold text-secondary-800 dark:text-white">Ontara Console</h1>
    <p class="mt-1 text-secondary-500 dark:text-secondary-300">
      Service system development and delivery platform
    </p>
  </div>

  <div class="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">

    <a href="/coverage" class="rounded-lg border border-secondary-200 bg-white p-5 shadow-sm transition hover:shadow-md dark:border-secondary-700 dark:bg-secondary-800">
      <h2 class="text-lg font-semibold text-secondary-800 dark:text-white">Coverage Matrix</h2>
      <p class="mt-1 text-sm text-secondary-500 dark:text-secondary-300">
        Which meta model concepts are instantiated in which domains. The primary legibility tool.
      </p>
      <Badge color="blue" class="mt-3">Stage 1</Badge>
    </a>

    <a href="/packages" class="rounded-lg border border-secondary-200 bg-white p-5 shadow-sm transition hover:shadow-md dark:border-secondary-700 dark:bg-secondary-800">
      <h2 class="text-lg font-semibold text-secondary-800 dark:text-white">Package Navigator</h2>
      <p class="mt-1 text-sm text-secondary-500 dark:text-secondary-300">
        Browse the SysML package hierarchy. See what each package contains and how elements relate.
      </p>
      <Badge color="blue" class="mt-3">Stage 1</Badge>
    </a>

    <a href="/catalogue" class="rounded-lg border border-secondary-200 bg-white p-5 shadow-sm transition hover:shadow-md dark:border-secondary-700 dark:bg-secondary-800">
      <h2 class="text-lg font-semibold text-secondary-800 dark:text-white">Component Catalogue</h2>
      <p class="mt-1 text-sm text-secondary-500 dark:text-secondary-300">
        Browse, filter, and select meta model components for assembly. Tagged by regulation, sector, and delivery mode.
      </p>
      <Badge color="indigo" class="mt-3">Stage 2</Badge>
    </a>

    <a href="/patterns" class="rounded-lg border border-secondary-200 bg-white p-5 shadow-sm transition hover:shadow-md dark:border-secondary-700 dark:bg-secondary-800">
      <h2 class="text-lg font-semibold text-secondary-800 dark:text-white">Pattern Graph</h2>
      <p class="mt-1 text-sm text-secondary-500 dark:text-secondary-300">
        22 validated patterns, 43 semantic relationships. Visual navigation of how the architecture fits together.
      </p>
      <Badge color="indigo" class="mt-3">Stage 3</Badge>
    </a>

    <a href="/meta-model" class="rounded-lg border border-secondary-200 bg-white p-5 shadow-sm transition hover:shadow-md dark:border-secondary-700 dark:bg-secondary-800">
      <h2 class="text-lg font-semibold text-secondary-800 dark:text-white">Meta Model Map</h2>
      <p class="mt-1 text-sm text-secondary-500 dark:text-secondary-300">
        Dual-canvas view — business meta model and system meta model side by side, with horizontal mappings.
      </p>
      <Badge color="indigo" class="mt-3">Stage 3</Badge>
    </a>

  </div>
</div>
