<script lang="ts">
    import { Badge, Button } from 'flowbite-svelte';
    import {
        TagOutline, UsersOutline, CalendarMonthOutline, UserSettingsOutline,
        ChartOutline, ShieldCheckOutline, ChartMixedOutline, CheckCircleOutline,
        CloseOutline
    } from 'flowbite-svelte-icons';
    import { getCompositionPreview, COMPOSITION_HINTS } from '$lib/modules/composition.js';
    import type { PageData } from './$types';
    import type { ModuleDefinition } from '$lib/types';

    let { data }: { data: PageData } = $props();

    const iconMap: Record<string, any> = {
        TagOutline, UsersOutline, CalendarMonthOutline, UserSettingsOutline,
        ChartOutline, ShieldCheckOutline, ChartMixedOutline
    };

    let activeFilter = $state<'all' | 'business' | 'analytical'>('all');

    let filtered = $derived(
        activeFilter === 'all'
            ? data.definitions
            : data.definitions.filter((d: ModuleDefinition) => d.category === activeFilter)
    );

    const installedSet = $derived(new Set(data.installedDefinitionIds));

    function categoryColor(cat: string): 'teal' | 'blue' | 'gray' {
        if (cat === 'business') return 'teal';
        if (cat === 'analytical') return 'blue';
        return 'gray';
    }

    // Composition preview state
    let previewDef = $state<ModuleDefinition | null>(null);

    let preview = $derived(previewDef
        ? getCompositionPreview(
            previewDef,
            data.instances.filter(i => i.installationState === 'installed'),
            data.contexts
        )
        : null
    );

    function showPreview(def: ModuleDefinition) {
        previewDef = def;
    }

    function closePreview() {
        previewDef = null;
    }
</script>

<svelte:head>
    <title>Module Catalogue — {data.domain.name} — Ontara Portal</title>
</svelte:head>

<div class="p-6 max-w-6xl mx-auto">
    <div class="mb-8">
        <h1 class="text-2xl font-semibold text-secondary-900 dark:text-secondary-100">Module Catalogue</h1>
        <p class="text-sm text-secondary-500 dark:text-secondary-400 mt-1">Browse and install modules for {data.domain.name}</p>
    </div>

    <!-- Filter pills -->
    <div class="flex gap-2 mb-6">
        {#each [['all', 'All'], ['business', 'Business'], ['analytical', 'Analytical']] as [val, label]}
            <button
                onclick={() => (activeFilter = val as any)}
                class="px-4 py-1.5 rounded-full text-sm font-medium transition-colors {activeFilter === val
                    ? 'bg-primary-600 text-white'
                    : 'bg-white dark:bg-secondary-800 text-secondary-600 dark:text-secondary-400 border border-secondary-200 dark:border-secondary-700 hover:border-primary-300'}"
            >
                {label}
            </button>
        {/each}
    </div>

    <!-- Module grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {#each filtered as def}
            {@const Icon = iconMap[def.icon]}
            {@const installed = installedSet.has(def.id)}
            <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 p-5 flex flex-col">
                <div class="flex items-start justify-between mb-3">
                    <div class="flex items-center gap-3">
                        <div class="w-10 h-10 rounded-xl bg-primary-100 dark:bg-primary-900/30 flex items-center justify-center flex-shrink-0">
                            {#if Icon}
                                <Icon class="w-5 h-5 text-primary-600 dark:text-primary-400" />
                            {/if}
                        </div>
                        <div>
                            <h3 class="font-semibold text-secondary-900 dark:text-secondary-100 leading-tight">{def.name}</h3>
                            <Badge color={categoryColor(def.category)} class="capitalize text-xs mt-0.5">{def.category}</Badge>
                        </div>
                    </div>
                </div>

                <p class="text-sm text-secondary-500 dark:text-secondary-400 leading-relaxed mb-3 flex-1">{def.description}</p>

                <!-- BMM concerns -->
                <div class="flex flex-wrap gap-1 mb-4">
                    {#each def.bmmConcerns as concern}
                        <span class="text-xs px-2 py-0.5 rounded-full bg-secondary-100 dark:bg-secondary-700 text-secondary-500 dark:text-secondary-400">{concern}</span>
                    {/each}
                </div>

                <!-- Action -->
                {#if installed}
                    <div class="flex items-center gap-2 text-sm text-green-600 dark:text-green-400 font-medium">
                        <CheckCircleOutline class="w-4 h-4" />
                        Installed
                    </div>
                {:else}
                    <Button onclick={() => showPreview(def)} color="primary" size="sm" class="w-full">Install</Button>
                {/if}
            </div>
        {/each}
    </div>
</div>

<!-- Composition preview modal -->
{#if previewDef && preview}
    <!-- Backdrop -->
    <button
        onclick={closePreview}
        class="fixed inset-0 bg-black/40 z-40"
        aria-label="Close preview"
    ></button>

    <!-- Modal -->
    <div class="fixed inset-0 z-50 flex items-center justify-center p-4">
        <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 shadow-xl max-w-lg w-full max-h-[80vh] overflow-y-auto">
            <div class="p-5">
                <!-- Header -->
                <div class="flex items-start justify-between mb-4">
                    <div>
                        <h2 class="text-lg font-semibold text-secondary-900 dark:text-secondary-100">Install {previewDef.name}</h2>
                        <p class="text-sm text-secondary-500 dark:text-secondary-400 mt-0.5">Review how this module fits into your domain</p>
                    </div>
                    <button onclick={closePreview} class="text-secondary-400 hover:text-secondary-600 transition-colors">
                        <CloseOutline class="w-5 h-5" />
                    </button>
                </div>

                <!-- Composition hint -->
                {#if COMPOSITION_HINTS[previewDef.id]}
                    <div class="bg-primary-50 dark:bg-primary-900/20 border border-primary-200 dark:border-primary-800 rounded-xl p-4 mb-4">
                        <p class="text-sm text-primary-800 dark:text-primary-200 leading-relaxed">{COMPOSITION_HINTS[previewDef.id]}</p>
                    </div>
                {/if}

                <!-- Covers -->
                <div class="mb-4">
                    <h3 class="text-xs font-semibold uppercase tracking-wider text-secondary-400 mb-2">This module covers</h3>
                    <div class="flex flex-wrap gap-1.5">
                        {#each preview.covers as cov}
                            <span class="text-xs px-2.5 py-1 rounded-lg bg-secondary-100 dark:bg-secondary-700 text-secondary-600 dark:text-secondary-400">{cov.label}</span>
                        {/each}
                    </div>
                </div>

                <!-- Connected modules -->
                {#if preview.connectedModules.length > 0}
                    <div class="mb-4">
                        <h3 class="text-xs font-semibold uppercase tracking-wider text-secondary-400 mb-2">Connects with</h3>
                        <div class="space-y-2">
                            {#each preview.connectedModules as conn}
                                <div class="flex items-center justify-between p-2.5 rounded-lg bg-secondary-50 dark:bg-secondary-900/30 border border-secondary-100 dark:border-secondary-700">
                                    <span class="text-sm text-secondary-800 dark:text-secondary-200">{conn.name}</span>
                                    <div class="flex gap-1">
                                        {#each conn.sharedConcerns as c}
                                            <span class="text-xs px-2 py-0.5 rounded-full bg-primary-100 dark:bg-primary-900/40 text-primary-700 dark:text-primary-300">{c}</span>
                                        {/each}
                                    </div>
                                </div>
                            {/each}
                        </div>
                    </div>
                {/if}

                <!-- New concerns -->
                {#if preview.newConcerns.length > 0}
                    <div class="mb-4">
                        <h3 class="text-xs font-semibold uppercase tracking-wider text-green-500 mb-2">New to your domain</h3>
                        <div class="flex flex-wrap gap-1.5">
                            {#each preview.newConcerns as nc}
                                <span class="text-xs px-2.5 py-1 rounded-lg bg-green-50 dark:bg-green-900/20 text-green-700 dark:text-green-300 border border-green-200 dark:border-green-800">{nc.label}</span>
                            {/each}
                        </div>
                    </div>
                {/if}

                <!-- Domain context status -->
                <div class="mb-5">
                    <h3 class="text-xs font-semibold uppercase tracking-wider text-secondary-400 mb-2">Domain context</h3>
                    <div class="space-y-1.5">
                        {#each preview.contextSummary as ctx}
                            <div class="flex items-center justify-between text-sm">
                                <span class="text-secondary-600 dark:text-secondary-400">{ctx.label}</span>
                                {#if ctx.hasValues}
                                    <span class="text-xs text-green-600 dark:text-green-400">Configured</span>
                                {:else}
                                    <span class="text-xs text-secondary-400">Not yet configured</span>
                                {/if}
                            </div>
                        {/each}
                    </div>
                </div>

                <!-- Actions -->
                <div class="flex gap-3 pt-3 border-t border-secondary-100 dark:border-secondary-700">
                    <form method="POST" action="?/install" class="flex-1">
                        <input type="hidden" name="definitionId" value={previewDef.id} />
                        <Button type="submit" color="primary" class="w-full">Install {previewDef.name}</Button>
                    </form>
                    <Button onclick={closePreview} color="alternative">Cancel</Button>
                </div>
            </div>
        </div>
    </div>
{/if}
