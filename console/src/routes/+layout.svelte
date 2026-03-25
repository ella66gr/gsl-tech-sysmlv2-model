<script lang="ts">
  import '../app.css';
  import { page } from '$app/stores';
  import { DarkMode } from 'flowbite-svelte';
  import {
    TableColumnOutline,
    GridPlusOutline,
    ArchiveOutline,
    MugHotOutline,
    CodeBranchOutline,
    LayersOutline,
    BarsOutline,
    ShieldCheckOutline,
    BookOutline,
    ShareNodesOutline,
  } from 'flowbite-svelte-icons';

  let { children } = $props();

  let sidebarOpen = $state(false);

  const currentPath = $derived($page.url.pathname);

  function isActive(href: string): boolean {
    if (href === '/') return currentPath === '/';
    return currentPath.startsWith(href);
  }
</script>

<svelte:head>
  <title>Ontara Console</title>
</svelte:head>

<!-- Top navbar -->
<nav class="fixed top-0 z-50 w-full border-b border-secondary-200 bg-white dark:border-secondary-700 dark:bg-secondary-900">
  <div class="flex items-center justify-between px-3 py-3 lg:px-5 lg:pl-3">
    <div class="flex items-center gap-3">
      <button
        onclick={() => sidebarOpen = !sidebarOpen}
        class="inline-flex items-center rounded-lg p-2 text-sm text-secondary-500 hover:bg-secondary-100 focus:outline-none focus:ring-2 focus:ring-secondary-200 md:hidden dark:text-secondary-400 dark:hover:bg-secondary-700 dark:focus:ring-secondary-600"
        aria-label="Toggle sidebar"
      >
        <BarsOutline class="h-5 w-5" />
      </button>
      <a href="/" class="flex items-center">
        <span class="self-center whitespace-nowrap text-xl font-semibold text-secondary-800 dark:text-white">
          Ontara <span class="text-sm font-normal text-secondary-400 dark:text-secondary-500">Console</span>
        </span>
      </a>
    </div>
    <div class="flex items-center gap-3">
      <DarkMode />
    </div>
  </div>
</nav>

<!-- Sidebar -->
<aside
  class="fixed top-0 left-0 z-40 h-screen w-64 border-r border-secondary-200 bg-white pt-16 transition-transform dark:border-secondary-700 dark:bg-secondary-900 md:translate-x-0"
  class:translate-x-0={sidebarOpen}
  class:-translate-x-full={!sidebarOpen}
>
  <div class="h-full overflow-y-auto px-3 py-4">
    <ul class="space-y-1 font-medium">

      <!-- Model Explorer -->
      <li class="mb-1 px-3 pt-2 text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-400">Model Explorer</li>
      <li>
        <a href="/coverage" class="flex items-center rounded-lg p-2 {isActive('/coverage') ? 'bg-primary-100 text-primary-700 dark:bg-primary-900/30 dark:text-primary-300' : 'text-secondary-600 hover:bg-secondary-100 dark:text-secondary-300 dark:hover:bg-secondary-700'}">
          <TableColumnOutline class="h-5 w-5" />
          <span class="ms-3">Coverage Matrix</span>
        </a>
      </li>
      <li>
        <a href="/packages" class="flex items-center rounded-lg p-2 {isActive('/packages') ? 'bg-primary-100 text-primary-700 dark:bg-primary-900/30 dark:text-primary-300' : 'text-secondary-600 hover:bg-secondary-100 dark:text-secondary-300 dark:hover:bg-secondary-700'}">
          <GridPlusOutline class="h-5 w-5" />
          <span class="ms-3">Package Navigator</span>
        </a>
      </li>
      <li>
        <a href="/catalogue" class="flex items-center rounded-lg p-2 {isActive('/catalogue') ? 'bg-primary-100 text-primary-700 dark:bg-primary-900/30 dark:text-primary-300' : 'text-secondary-600 hover:bg-secondary-100 dark:text-secondary-300 dark:hover:bg-secondary-700'}">
          <ArchiveOutline class="h-5 w-5" />
          <span class="ms-3">Component Catalogue</span>
        </a>
      </li>
      <li>
        <a href="/governance" class="flex items-center rounded-lg p-2 {isActive('/governance') ? 'bg-primary-100 text-primary-700 dark:bg-primary-900/30 dark:text-primary-300' : 'text-secondary-600 hover:bg-secondary-100 dark:text-secondary-300 dark:hover:bg-secondary-700'}">
          <ShieldCheckOutline class="h-5 w-5" />
          <span class="ms-3">Governance</span>
        </a>
      </li>

      <li>
        <a href="/glossary" class="flex items-center rounded-lg p-2 {isActive('/glossary') ? 'bg-primary-100 text-primary-700 dark:bg-primary-900/30 dark:text-primary-300' : 'text-secondary-600 hover:bg-secondary-100 dark:text-secondary-300 dark:hover:bg-secondary-700'}">
          <BookOutline class="h-5 w-5" />
          <span class="ms-3">Glossary</span>
        </a>
      </li>
      <li>
        <a href="/relationships" class="flex items-center rounded-lg p-2 {isActive('/relationships') ? 'bg-primary-100 text-primary-700 dark:bg-primary-900/30 dark:text-primary-300' : 'text-secondary-600 hover:bg-secondary-100 dark:text-secondary-300 dark:hover:bg-secondary-700'}">
          <ShareNodesOutline class="h-5 w-5" />
          <span class="ms-3">Relationships</span>
        </a>
      </li>

      <!-- Domains -->
      <li class="mb-1 px-3 pt-4 text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-400">Domains</li>
      <li>
        <a href="/domains/cafe" class="flex items-center rounded-lg p-2 {isActive('/domains/cafe') ? 'bg-primary-100 text-primary-700 dark:bg-primary-900/30 dark:text-primary-300' : 'text-secondary-600 hover:bg-secondary-100 dark:text-secondary-300 dark:hover:bg-secondary-700'}">
          <MugHotOutline class="h-5 w-5" />
          <span class="ms-3">Cafe</span>
        </a>
      </li>
      <li>
        <a href="/domains/suds" class="flex items-center rounded-lg p-2 {isActive('/domains/suds') ? 'bg-primary-100 text-primary-700 dark:bg-primary-900/30 dark:text-primary-300' : 'text-secondary-600 hover:bg-secondary-100 dark:text-secondary-300 dark:hover:bg-secondary-700'}">
          <span class="inline-flex h-5 w-5 items-center justify-center text-base">🧺</span>
          <span class="ms-3">Suds</span>
        </a>
      </li>
      <li>
        <a href="/domains/paws" class="flex items-center rounded-lg p-2 {isActive('/domains/paws') ? 'bg-primary-100 text-primary-700 dark:bg-primary-900/30 dark:text-primary-300' : 'text-secondary-600 hover:bg-secondary-100 dark:text-secondary-300 dark:hover:bg-secondary-700'}">
          <span class="inline-flex h-5 w-5 items-center justify-center text-base">🐾</span>
          <span class="ms-3">Paws</span>
        </a>
      </li>

      <!-- Architecture -->
      <li class="mb-1 px-3 pt-4 text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-400">Architecture</li>
      <li>
        <a href="/patterns" class="flex items-center rounded-lg p-2 {isActive('/patterns') ? 'bg-primary-100 text-primary-700 dark:bg-primary-900/30 dark:text-primary-300' : 'text-secondary-600 hover:bg-secondary-100 dark:text-secondary-300 dark:hover:bg-secondary-700'}">
          <CodeBranchOutline class="h-5 w-5" />
          <span class="ms-3">Pattern Graph</span>
        </a>
      </li>
      <li>
        <a href="/meta-model" class="flex items-center rounded-lg p-2 {isActive('/meta-model') ? 'bg-primary-100 text-primary-700 dark:bg-primary-900/30 dark:text-primary-300' : 'text-secondary-600 hover:bg-secondary-100 dark:text-secondary-300 dark:hover:bg-secondary-700'}">
          <LayersOutline class="h-5 w-5" />
          <span class="ms-3">Meta Model Map</span>
        </a>
      </li>
    </ul>
  </div>
</aside>

<!-- Backdrop for mobile sidebar -->
{#if sidebarOpen}
  <div
    class="fixed inset-0 z-30 bg-secondary-900/50 md:hidden"
    onclick={() => (sidebarOpen = false)}
    role="presentation"
  ></div>
{/if}

<!-- Main content area -->
<div class="mt-16 p-4 md:ml-64">
  <main class="mx-auto max-w-7xl">
    {@render children()}
  </main>
</div>
