<script lang="ts">
    import { Badge, Button } from 'flowbite-svelte';
    import {
        TagOutline, UsersOutline, CalendarMonthOutline, UserSettingsOutline,
        ChartOutline, ShieldCheckOutline, ChartMixedOutline, CheckCircleOutline
    } from 'flowbite-svelte-icons';
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
                    <form method="POST" action="?/install">
                        <input type="hidden" name="definitionId" value={def.id} />
                        <Button type="submit" color="primary" size="sm" class="w-full">Install</Button>
                    </form>
                {/if}
            </div>
        {/each}
    </div>
</div>
