<script lang="ts">
  import '../app.css';
  import { page } from '$app/stores';
  import favicon from '$lib/assets/favicon.svg';
  import { Sidebar, SidebarWrapper, SidebarGroup, SidebarItem } from 'flowbite-svelte';
  import { Navbar, NavBrand } from 'flowbite-svelte';
  import { DarkMode } from 'flowbite-svelte';
  import {
    MugHotOutline,
    ClipboardListOutline,
    ArchiveOutline,
    DatabaseOutline,
    ShieldCheckOutline,
    MessageDotsOutline,
    CodeBranchOutline,
    ServerOutline,
    BarsOutline,
  } from 'flowbite-svelte-icons';

  let { children } = $props();

  let sidebarOpen = $state(false);

  const currentPath = $derived($page.url.pathname);

  function isActive(href: string): boolean {
    if (href === '/') return currentPath === '/';
    return currentPath.startsWith(href);
  }

  function toggleSidebar() {
    sidebarOpen = !sidebarOpen;
  }
</script>

<svelte:head>
  <link rel="icon" href={favicon} />
  <title>Coffee Shop Demonstrator</title>
</svelte:head>

<!-- Top navbar -->
<nav class="fixed top-0 z-50 w-full border-b border-secondary-200 bg-white dark:border-secondary-600 dark:bg-secondary-900">
  <div class="flex items-center justify-between px-3 py-3 lg:px-5 lg:pl-3">
    <div class="flex items-center gap-3">
      <button
        onclick={toggleSidebar}
        class="inline-flex items-center rounded-lg p-2 text-sm text-secondary-500 hover:bg-secondary-100 focus:outline-none focus:ring-2 focus:ring-secondary-200 md:hidden dark:text-secondary-400 dark:hover:bg-secondary-700 dark:focus:ring-secondary-600"
        aria-label="Toggle sidebar"
      >
        <BarsOutline class="h-5 w-5" />
      </button>
      <a href="/" class="flex items-center">
        <span class="self-center whitespace-nowrap text-xl font-semibold text-secondary-800 dark:text-white">
          ☕ Coffee Shop
        </span>
      </a>
    </div>
    <div class="flex items-center gap-3">
      <!-- Connection status indicators
           TODO Phase 9: These are static green dots. The System Status page
           (/system) provides live health checks via /api/system/health.
           To make these live: poll the health endpoint every 60s and update
           dot colours. Deferred because the health check pings three services,
           which is heavyweight for every page navigation. -->
      <div class="hidden items-center gap-2 text-xs sm:flex">
        <span class="flex items-center gap-1 text-secondary-500 dark:text-secondary-400">
          <span class="inline-block h-2 w-2 rounded-full bg-green-500"></span>
          Temporal
        </span>
        <span class="flex items-center gap-1 text-secondary-500 dark:text-secondary-400">
          <span class="inline-block h-2 w-2 rounded-full bg-green-500"></span>
          EHRbase
        </span>
        <span class="flex items-center gap-1 text-secondary-500 dark:text-secondary-400">
          <span class="inline-block h-2 w-2 rounded-full bg-green-500"></span>
          PostgreSQL
        </span>
      </div>
      <DarkMode />
    </div>
  </div>
</nav>

<!-- Sidebar -->
<aside class="fixed top-0 left-0 z-40 h-screen w-64 border-r border-secondary-200 bg-white pt-16 transition-transform dark:border-secondary-600 dark:bg-secondary-900 md:translate-x-0" class:translate-x-0={sidebarOpen} class:-translate-x-full={!sidebarOpen}>
  <div class="h-full overflow-y-auto px-3 py-4">
    <ul class="space-y-1 font-medium">
      <!-- Operations -->
      <li class="mb-1 px-3 pt-2 text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-400">Operations</li>
      <li>
        <a href="/" class="flex items-center rounded-lg p-2 {isActive('/') ? 'bg-primary-100 text-primary-700 dark:bg-primary-900/30 dark:text-primary-300' : 'text-secondary-600 hover:bg-secondary-100 dark:text-secondary-300 dark:hover:bg-secondary-700'}">
          <MugHotOutline class="h-5 w-5" />
          <span class="ms-3">Counter</span>
        </a>
      </li>
      <li>
        <a href="/orders" class="flex items-center rounded-lg p-2 {isActive('/orders') ? 'bg-primary-100 text-primary-700 dark:bg-primary-900/30 dark:text-primary-300' : 'text-secondary-600 hover:bg-secondary-100 dark:text-secondary-300 dark:hover:bg-secondary-700'}">
          <ClipboardListOutline class="h-5 w-5" />
          <span class="ms-3">Order Board</span>
        </a>
      </li>

      <!-- Management -->
      <li class="mb-1 px-3 pt-4 text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-400">Management</li>
      <li>
        <a href="/management/catalogue" class="flex items-center rounded-lg p-2 {isActive('/management') ? 'bg-primary-100 text-primary-700 dark:bg-primary-900/30 dark:text-primary-300' : 'text-secondary-600 hover:bg-secondary-100 dark:text-secondary-300 dark:hover:bg-secondary-700'}">
          <ArchiveOutline class="h-5 w-5" />
          <span class="ms-3">Stock & Catalogue</span>
        </a>
      </li>

      <!-- Data & Insights -->
      <li class="mb-1 px-3 pt-4 text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-400">Data & Insights</li>
      <li>
        <a href="/entity" class="flex items-center rounded-lg p-2 {isActive('/entity') ? 'bg-primary-100 text-primary-700 dark:bg-primary-900/30 dark:text-primary-300' : 'text-secondary-600 hover:bg-secondary-100 dark:text-secondary-300 dark:hover:bg-secondary-700'}">
          <DatabaseOutline class="h-5 w-5" />
          <span class="ms-3">Records</span>
        </a>
      </li>
      <li>
        <a href="/governance" class="flex items-center rounded-lg p-2 {isActive('/governance') ? 'bg-primary-100 text-primary-700 dark:bg-primary-900/30 dark:text-primary-300' : 'text-secondary-600 hover:bg-secondary-100 dark:text-secondary-300 dark:hover:bg-secondary-700'}">
          <ShieldCheckOutline class="h-5 w-5" />
          <span class="ms-3">Audit Dashboard</span>
        </a>
      </li>
      <li>
        <a href="/feedback" class="flex items-center rounded-lg p-2 {isActive('/feedback') ? 'bg-primary-100 text-primary-700 dark:bg-primary-900/30 dark:text-primary-300' : 'text-secondary-600 hover:bg-secondary-100 dark:text-secondary-300 dark:hover:bg-secondary-700'}">
          <MessageDotsOutline class="h-5 w-5" />
          <span class="ms-3">Customer Voice</span>
        </a>
      </li>

      <!-- System -->
      <li class="mb-1 px-3 pt-4 text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-400">System</li>
      <li>
        <a href="/pathway" class="flex items-center rounded-lg p-2 {isActive('/pathway') ? 'bg-primary-100 text-primary-700 dark:bg-primary-900/30 dark:text-primary-300' : 'text-secondary-600 hover:bg-secondary-100 dark:text-secondary-300 dark:hover:bg-secondary-700'}">
          <CodeBranchOutline class="h-5 w-5" />
          <span class="ms-3">Process Model</span>
        </a>
      </li>
      <li>
        <a href="/system" class="flex items-center rounded-lg p-2 {isActive('/system') ? 'bg-primary-100 text-primary-700 dark:bg-primary-900/30 dark:text-primary-300' : 'text-secondary-600 hover:bg-secondary-100 dark:text-secondary-300 dark:hover:bg-secondary-700'}">
          <ServerOutline class="h-5 w-5" />
          <span class="ms-3">System Status</span>
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
