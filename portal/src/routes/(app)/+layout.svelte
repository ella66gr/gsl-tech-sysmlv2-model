<script lang="ts">
    import { page } from '$app/stores';
    import {
        Avatar,
        Dropdown,
        DropdownItem,
        DropdownDivider,
        Badge,
        Sidebar,
        SidebarGroup,
        SidebarItem,
        SidebarWrapper
    } from 'flowbite-svelte';
    import {
        ChevronDownOutline,
        GridOutline,
        CogOutline,
        UserOutline,
        ArrowRightToBracketOutline,
        SunOutline,
        MoonOutline,
        PlusOutline
    } from 'flowbite-svelte-icons';
    import type { LayoutData } from './$types';
    import type { DomainWithRole } from '$lib/types';

    let { data, children }: { data: LayoutData; children: any } = $props();

    let darkMode = $state(
        typeof localStorage !== 'undefined'
            ? localStorage.getItem('darkMode') !== 'false'
            : true
    );

    $effect(() => {
        if (darkMode) {
            document.documentElement.classList.add('dark');
        } else {
            document.documentElement.classList.remove('dark');
        }
        if (typeof localStorage !== 'undefined') {
            localStorage.setItem('darkMode', String(darkMode));
        }
    });

    function toggleDark() {
        darkMode = !darkMode;
    }

    // Determine current domain from URL
    let currentSlug = $derived($page.params.slug ?? null);
    let currentDomain = $derived(
        currentSlug ? data.domains.find((d: DomainWithRole) => d.slug === currentSlug) ?? null : null
    );

    let userInitials = $derived(
        data.user.displayName
            .split(' ')
            .map((n: string) => n[0])
            .join('')
            .toUpperCase()
            .slice(0, 2)
    );

    let domainDropdownOpen = $state(false);
    let userDropdownOpen = $state(false);
    let sidebarHidden = $state(false);
</script>

<div class="min-h-screen flex flex-col bg-secondary-50 dark:bg-secondary-900">
    <!-- Top navbar -->
    <nav class="bg-white dark:bg-secondary-800 border-b border-secondary-200 dark:border-secondary-700 h-14 flex items-center px-4 gap-4 flex-shrink-0">
        <!-- Branding -->
        <a href="/domains" class="flex items-center gap-1 flex-shrink-0">
            <span class="text-lg font-bold text-primary-600 dark:text-primary-400">Ontara</span>
            <span class="text-lg font-light text-secondary-500 dark:text-secondary-400">Portal</span>
        </a>

        <div class="w-px h-6 bg-secondary-200 dark:bg-secondary-600"></div>

        <!-- Domain switcher -->
        <div class="relative">
            <button
                onclick={() => (domainDropdownOpen = !domainDropdownOpen)}
                class="flex items-center gap-2 px-3 py-1.5 rounded-lg text-sm text-secondary-700 dark:text-secondary-300 hover:bg-secondary-100 dark:hover:bg-secondary-700 transition-colors"
            >
                {#if currentDomain}
                    <span class="font-medium">{currentDomain.name}</span>
                    <Badge color="yellow" class="text-xs">{currentDomain.role.replace('_', ' ')}</Badge>
                {:else}
                    <span class="text-secondary-400">Select a domain</span>
                {/if}
                <ChevronDownOutline class="w-4 h-4 text-secondary-400" />
            </button>

            {#if domainDropdownOpen}
                <div
                    class="absolute top-full left-0 mt-1 w-64 bg-white dark:bg-secondary-800 border border-secondary-200 dark:border-secondary-700 rounded-xl shadow-lg z-50 py-1"
                    role="menu"
                >
                    {#if data.domains.length === 0}
                        <div class="px-4 py-3 text-sm text-secondary-400">No domains yet</div>
                    {:else}
                        {#each data.domains as domain}
                            <a
                                href="/domains/{domain.slug}"
                                class="flex items-center justify-between px-4 py-2.5 text-sm hover:bg-secondary-50 dark:hover:bg-secondary-700 transition-colors {currentSlug === domain.slug ? 'bg-primary-50 dark:bg-primary-900/20 text-primary-700 dark:text-primary-300' : 'text-secondary-700 dark:text-secondary-300'}"
                                onclick={() => (domainDropdownOpen = false)}
                            >
                                <span class="font-medium">{domain.name}</span>
                                <Badge color="blue" class="text-xs">{domain.role.replace('_', ' ')}</Badge>
                            </a>
                        {/each}
                    {/if}
                    <div class="border-t border-secondary-100 dark:border-secondary-700 mt-1 pt-1">
                        <a
                            href="/domains/new"
                            class="flex items-center gap-2 px-4 py-2.5 text-sm text-primary-600 dark:text-primary-400 hover:bg-secondary-50 dark:hover:bg-secondary-700 transition-colors"
                            onclick={() => (domainDropdownOpen = false)}
                        >
                            <PlusOutline class="w-4 h-4" />
                            Create new domain
                        </a>
                    </div>
                </div>
            {/if}
        </div>

        <!-- Spacer -->
        <div class="flex-1"></div>

        <!-- User menu -->
        <div class="relative">
            <button
                onclick={() => (userDropdownOpen = !userDropdownOpen)}
                class="flex items-center gap-2 px-2 py-1 rounded-lg hover:bg-secondary-100 dark:hover:bg-secondary-700 transition-colors"
            >
                <div class="w-8 h-8 rounded-full bg-primary-500 flex items-center justify-center text-white text-xs font-semibold">
                    {userInitials}
                </div>
                <span class="text-sm text-secondary-700 dark:text-secondary-300 hidden sm:block">{data.user.displayName}</span>
                <ChevronDownOutline class="w-4 h-4 text-secondary-400" />
            </button>

            {#if userDropdownOpen}
                <div
                    class="absolute top-full right-0 mt-1 w-56 bg-white dark:bg-secondary-800 border border-secondary-200 dark:border-secondary-700 rounded-xl shadow-lg z-50 py-1"
                    role="menu"
                >
                    <div class="px-4 py-3 border-b border-secondary-100 dark:border-secondary-700">
                        <p class="text-sm font-medium text-secondary-900 dark:text-secondary-100">{data.user.displayName}</p>
                        <p class="text-xs text-secondary-500 dark:text-secondary-400 truncate">{data.user.email}</p>
                    </div>
                    <a
                        href="/profile"
                        class="flex items-center gap-2 px-4 py-2.5 text-sm text-secondary-700 dark:text-secondary-300 hover:bg-secondary-50 dark:hover:bg-secondary-700 transition-colors"
                        onclick={() => (userDropdownOpen = false)}
                    >
                        <UserOutline class="w-4 h-4" />
                        Profile
                    </a>
                    <button
                        onclick={() => { toggleDark(); userDropdownOpen = false; }}
                        class="w-full flex items-center gap-2 px-4 py-2.5 text-sm text-secondary-700 dark:text-secondary-300 hover:bg-secondary-50 dark:hover:bg-secondary-700 transition-colors"
                    >
                        {#if darkMode}
                            <SunOutline class="w-4 h-4" />
                            Light mode
                        {:else}
                            <MoonOutline class="w-4 h-4" />
                            Dark mode
                        {/if}
                    </button>
                    <div class="border-t border-secondary-100 dark:border-secondary-700 mt-1 pt-1">
                        <form method="POST" action="/logout">
                            <button
                                type="submit"
                                class="w-full flex items-center gap-2 px-4 py-2.5 text-sm text-red-600 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20 transition-colors"
                            >
                                <ArrowRightToBracketOutline class="w-4 h-4" />
                                Sign out
                            </button>
                        </form>
                    </div>
                </div>
            {/if}
        </div>
    </nav>

    <!-- Body: sidebar + content -->
    <div class="flex flex-1 overflow-hidden">
        <!-- Sidebar (only when on a domain route) -->
        {#if currentDomain}
            <aside class="w-52 flex-shrink-0 bg-white dark:bg-secondary-800 border-r border-secondary-200 dark:border-secondary-700 flex flex-col">
                <div class="px-4 py-4 border-b border-secondary-100 dark:border-secondary-700">
                    <p class="text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-500 mb-1">Domain</p>
                    <p class="text-sm font-semibold text-secondary-800 dark:text-secondary-200 truncate">{currentDomain.name}</p>
                </div>
                <nav class="flex-1 px-3 py-4 space-y-1">
                    <a
                        href="/domains/{currentSlug}"
                        class="flex items-center gap-3 px-3 py-2 rounded-lg text-sm transition-colors {$page.url.pathname === `/domains/${currentSlug}` ? 'bg-primary-50 dark:bg-primary-900/20 text-primary-700 dark:text-primary-300 font-medium' : 'text-secondary-600 dark:text-secondary-400 hover:bg-secondary-50 dark:hover:bg-secondary-700'}"
                    >
                        <GridOutline class="w-4 h-4" />
                        Dashboard
                    </a>
                    <a
                        href="/domains/{currentSlug}/settings"
                        class="flex items-center gap-3 px-3 py-2 rounded-lg text-sm transition-colors {$page.url.pathname.startsWith(`/domains/${currentSlug}/settings`) ? 'bg-primary-50 dark:bg-primary-900/20 text-primary-700 dark:text-primary-300 font-medium' : 'text-secondary-600 dark:text-secondary-400 hover:bg-secondary-50 dark:hover:bg-secondary-700'}"
                    >
                        <CogOutline class="w-4 h-4" />
                        Settings
                    </a>
                </nav>
            </aside>
        {/if}

        <!-- Main content -->
        <main class="flex-1 overflow-auto">
            {@render children()}
        </main>
    </div>
</div>

<!-- Click-outside dismissal -->
{#if domainDropdownOpen || userDropdownOpen}
    <!-- svelte-ignore a11y_click_events_have_key_events -->
    <!-- svelte-ignore a11y_no_static_element_interactions -->
    <div
        class="fixed inset-0 z-40"
        onclick={() => { domainDropdownOpen = false; userDropdownOpen = false; }}
    ></div>
{/if}
