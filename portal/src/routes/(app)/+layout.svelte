<script lang="ts">
    import { page } from '$app/stores';
    import { browser } from '$app/environment';
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
        GridPlusOutline,
        CogOutline,
        UserOutline,
        ArrowRightToBracketOutline,
        SunOutline,
        MoonOutline,
        PlusOutline,
        PlayOutline,
        ShieldCheckOutline,
        LayersOutline
    } from 'flowbite-svelte-icons';
    import type { LayoutData } from './$types';
    import type { DomainWithRole } from '$lib/types';

    let { data, children }: { data: LayoutData; children: any } = $props();

    let darkMode = $state(true);

    // Read localStorage only on the client (SSR has no localStorage)
    $effect(() => {
        if (browser) {
            darkMode = localStorage.getItem('darkMode') !== 'false';
        }
    });

    $effect(() => {
        if (browser) {
            if (darkMode) {
                document.documentElement.classList.add('dark');
            } else {
                document.documentElement.classList.remove('dark');
            }
            localStorage.setItem('darkMode', String(darkMode));
        }
    });

    function toggleDark() {
        darkMode = !darkMode;
    }

    // Determine current domain from URL — only when on a /domains/[slug]
    // route. The slug param is also set on /substrate/[slug] (different
    // route), so we read URL pathname rather than $page.params.slug to
    // avoid mis-classifying substrate routes as domain routes.
    let currentSlug = $derived(
        $page.url.pathname.startsWith('/domains/')
            ? $page.url.pathname.split('/')[2] ?? null
            : null
    );
    let currentDomain = $derived(
        currentSlug ? data.domains.find((d: DomainWithRole) => d.slug === currentSlug) ?? null : null
    );

    let onSubstrateRoute = $derived($page.url.pathname.startsWith('/substrate'));

    let userInitials = $derived(
        data.user.displayName
            .split(' ')
            .map((n: string) => n[0])
            .join('')
            .toUpperCase()
            .slice(0, 2)
    );

    let domainDropdownOpen = $state(false);
    let platformDropdownOpen = $state(false);
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

        <!-- Platform menu — platform-level surfaces (peer to the domain switcher). -->
        <div class="relative">
            <button
                onclick={() => (platformDropdownOpen = !platformDropdownOpen)}
                class="flex items-center gap-2 px-3 py-1.5 rounded-lg text-sm transition-colors {onSubstrateRoute ? 'text-primary-700 dark:text-primary-300 bg-primary-50 dark:bg-primary-900/20' : 'text-secondary-700 dark:text-secondary-300 hover:bg-secondary-100 dark:hover:bg-secondary-700'}"
            >
                <span class="font-medium">Platform</span>
                <ChevronDownOutline class="w-4 h-4 text-secondary-400" />
            </button>

            {#if platformDropdownOpen}
                <div
                    class="absolute top-full left-0 mt-1 w-56 bg-white dark:bg-secondary-800 border border-secondary-200 dark:border-secondary-700 rounded-xl shadow-lg z-50 py-1"
                    role="menu"
                >
                    <a
                        href="/substrate"
                        class="flex items-center gap-3 px-4 py-2.5 text-sm hover:bg-secondary-50 dark:hover:bg-secondary-700 transition-colors {onSubstrateRoute ? 'bg-primary-50 dark:bg-primary-900/20 text-primary-700 dark:text-primary-300' : 'text-secondary-700 dark:text-secondary-300'}"
                        onclick={() => (platformDropdownOpen = false)}
                    >
                        <LayersOutline class="w-4 h-4" />
                        <div class="flex flex-col">
                            <span class="font-medium">Substrate</span>
                            <span class="text-xs text-secondary-500 dark:text-secondary-400">Block-composable knowledge documents</span>
                        </div>
                    </a>
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
            <aside class="w-52 flex-shrink-0 bg-white dark:bg-secondary-800 border-r border-secondary-200 dark:border-secondary-700 flex flex-col overflow-y-auto">
                <div class="px-4 py-4 border-b border-secondary-100 dark:border-secondary-700">
                    <p class="text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-500 mb-1">Domain</p>
                    <p class="text-sm font-semibold text-secondary-800 dark:text-secondary-200 truncate">{currentDomain.name}</p>
                </div>
                <nav class="flex-1 px-3 py-4 space-y-1">
                    <!-- Dashboard -->
                    <a
                        href="/domains/{currentSlug}"
                        class="flex items-center gap-3 px-3 py-2 rounded-lg text-sm transition-colors {$page.url.pathname === `/domains/${currentSlug}` ? 'bg-primary-50 dark:bg-primary-900/20 text-primary-700 dark:text-primary-300 font-medium' : 'text-secondary-600 dark:text-secondary-400 hover:bg-secondary-50 dark:hover:bg-secondary-700'}"
                    >
                        <GridOutline class="w-4 h-4" />
                        Dashboard
                    </a>

                    <!-- Modules section -->
                    {#if data.sidebarModules.length > 0}
                        <div class="pt-3 pb-1">
                            <p class="text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-500 px-3 mb-1">Modules</p>
                        </div>
                        {#each data.sidebarModules.slice(0, 8) as mod}
                            <a
                                href="/domains/{currentSlug}/modules/{mod.id}"
                                class="flex items-center gap-2.5 px-3 py-1.5 rounded-lg text-sm transition-colors {$page.url.pathname === `/domains/${currentSlug}/modules/${mod.id}` ? 'bg-primary-50 dark:bg-primary-900/20 text-primary-700 dark:text-primary-300 font-medium' : 'text-secondary-600 dark:text-secondary-400 hover:bg-secondary-50 dark:hover:bg-secondary-700'}"
                            >
                                <span class="w-2 h-2 rounded-full flex-shrink-0 {mod.operationalState === 'active' ? 'bg-green-500' : mod.operationalState === 'paused' ? 'bg-orange-400' : mod.operationalState === 'stopped' ? 'bg-red-400' : 'bg-yellow-400'}"></span>
                                <span class="truncate">{mod.displayName}</span>
                            </a>
                        {/each}
                        {#if data.sidebarModules.length > 8}
                            <a href="/domains/{currentSlug}" class="flex items-center gap-3 px-3 py-1.5 rounded-lg text-xs text-secondary-400 hover:text-primary-600 dark:hover:text-primary-400 transition-colors">
                                +{data.sidebarModules.length - 8} more →
                            </a>
                        {/if}
                        <div class="pt-1"></div>
                    {/if}

                    <!-- Catalogue -->
                    <a
                        href="/domains/{currentSlug}/catalogue"
                        class="flex items-center gap-3 px-3 py-2 rounded-lg text-sm transition-colors {$page.url.pathname.startsWith(`/domains/${currentSlug}/catalogue`) ? 'bg-primary-50 dark:bg-primary-900/20 text-primary-700 dark:text-primary-300 font-medium' : 'text-secondary-600 dark:text-secondary-400 hover:bg-secondary-50 dark:hover:bg-secondary-700'}"
                    >
                        <GridPlusOutline class="w-4 h-4" />
                        Catalogue
                    </a>

                    <!-- Simulations -->
                    <a
                        href="/domains/{currentSlug}/simulations"
                        class="flex items-center gap-3 px-3 py-2 rounded-lg text-sm transition-colors {$page.url.pathname.startsWith(`/domains/${currentSlug}/simulations`) ? 'bg-primary-50 dark:bg-primary-900/20 text-primary-700 dark:text-primary-300 font-medium' : 'text-secondary-600 dark:text-secondary-400 hover:bg-secondary-50 dark:hover:bg-secondary-700'}"
                    >
                        <PlayOutline class="w-4 h-4" />
                        Simulations
                    </a>

                    <!-- Governance -->
                    <a
                        href="/domains/{currentSlug}/governance"
                        class="flex items-center gap-3 px-3 py-2 rounded-lg text-sm transition-colors {$page.url.pathname.startsWith(`/domains/${currentSlug}/governance`) ? 'bg-primary-50 dark:bg-primary-900/20 text-primary-700 dark:text-primary-300 font-medium' : 'text-secondary-600 dark:text-secondary-400 hover:bg-secondary-50 dark:hover:bg-secondary-700'}"
                    >
                        <ShieldCheckOutline class="w-4 h-4" />
                        Governance
                    </a>

                    <!-- Settings -->
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
{#if domainDropdownOpen || platformDropdownOpen || userDropdownOpen}
    <!-- svelte-ignore a11y_click_events_have_key_events -->
    <!-- svelte-ignore a11y_no_static_element_interactions -->
    <div
        class="fixed inset-0 z-40"
        onclick={() => { domainDropdownOpen = false; platformDropdownOpen = false; userDropdownOpen = false; }}
    ></div>
{/if}
