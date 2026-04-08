<script lang="ts">
    import { Badge, Button } from 'flowbite-svelte';
    import {
        TagOutline, UsersOutline, CalendarMonthOutline, UserSettingsOutline,
        ChartOutline, ShieldCheckOutline, ChartMixedOutline,
        GridPlusOutline, UsersOutline as UsersIcon, CalendarMonthOutline as CalIcon
    } from 'flowbite-svelte-icons';
    import { getOperationalStateDisplay, getPrimaryAction } from '$lib/modules/lifecycle.js';
    import type { PageData } from './$types';
    import type { ModuleInstanceWithDefinition } from '$lib/types';

    let { data }: { data: PageData } = $props();

    const iconMap: Record<string, any> = {
        TagOutline, UsersOutline, CalendarMonthOutline, UserSettingsOutline,
        ChartOutline, ShieldCheckOutline, ChartMixedOutline
    };

    function formatDate(iso: string) {
        return new Date(iso).toLocaleDateString('en-GB', { day: 'numeric', month: 'long', year: 'numeric' });
    }

    // Summary counts
    let activeCount = $derived(data.modules.filter((m: ModuleInstanceWithDefinition) => m.operationalState === 'active').length);
    let draftCount  = $derived(data.modules.filter((m: ModuleInstanceWithDefinition) => m.operationalState === 'draft').length);

    function primaryActionButtonClass(style: string): string {
        switch (style) {
            case 'primary':   return 'bg-primary-600 hover:bg-primary-700 text-white text-xs px-3 py-1.5 rounded-lg transition-colors';
            case 'warning':   return 'bg-yellow-400 hover:bg-yellow-500 text-yellow-900 text-xs px-3 py-1.5 rounded-lg transition-colors';
            case 'danger':    return 'bg-red-600 hover:bg-red-700 text-white text-xs px-3 py-1.5 rounded-lg transition-colors';
            case 'secondary': return 'bg-secondary-100 dark:bg-secondary-700 hover:bg-secondary-200 dark:hover:bg-secondary-600 text-secondary-700 dark:text-secondary-300 text-xs px-3 py-1.5 rounded-lg transition-colors';
            default:          return '';
        }
    }
</script>

<svelte:head>
    <title>{data.domain.name} — Ontara Portal</title>
</svelte:head>

<div class="p-6 max-w-6xl mx-auto">
    <!-- Domain header -->
    <div class="mb-6">
        <div class="flex items-start justify-between">
            <div>
                <h1 class="text-2xl font-semibold text-secondary-900 dark:text-secondary-100">{data.domain.name}</h1>
                {#if data.domain.businessType}
                    <p class="text-secondary-500 dark:text-secondary-400 mt-0.5">{data.domain.businessType}</p>
                {/if}
            </div>
            <Badge color="yellow" class="capitalize text-sm px-3 py-1">{data.domain.status}</Badge>
        </div>
        {#if data.domain.description}
            <p class="mt-3 text-secondary-600 dark:text-secondary-400 max-w-2xl">{data.domain.description}</p>
        {/if}
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Main content -->
        <div class="lg:col-span-2 space-y-6">
            {#if data.modules.length === 0}
                <!-- Empty state -->
                <div class="bg-gradient-to-br from-primary-50 to-teal-50 dark:from-primary-900/20 dark:to-teal-900/20 rounded-2xl border border-primary-200 dark:border-primary-800 p-6">
                    <div class="flex items-start gap-4">
                        <div class="w-10 h-10 rounded-xl bg-primary-500 flex items-center justify-center flex-shrink-0">
                            <GridPlusOutline class="w-5 h-5 text-white" />
                        </div>
                        <div>
                            <h2 class="font-semibold text-primary-900 dark:text-primary-100 mb-2">Your domain is ready</h2>
                            <p class="text-sm text-primary-800 dark:text-primary-200 leading-relaxed mb-4">
                                Install your first module to start building your service. Browse the catalogue to see what's available.
                            </p>
                            <Button href="/domains/{data.domain.slug}/catalogue" color="primary" size="sm">
                                Browse Module Catalogue →
                            </Button>
                        </div>
                    </div>
                </div>
            {:else}
                <!-- Summary bar -->
                <div class="flex items-center justify-between">
                    <p class="text-sm text-secondary-500 dark:text-secondary-400">
                        <span class="font-medium text-secondary-800 dark:text-secondary-200">{data.modules.length}</span> module{data.modules.length !== 1 ? 's' : ''}
                        {#if activeCount > 0}·  <span class="text-green-600 dark:text-green-400 font-medium">{activeCount} active</span>{/if}
                        {#if draftCount > 0}·  <span class="text-yellow-600 dark:text-yellow-400 font-medium">{draftCount} draft</span>{/if}
                    </p>
                    <Button href="/domains/{data.domain.slug}/catalogue" color="alternative" size="xs">Browse Catalogue</Button>
                </div>

                <!-- Module grid -->
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    {#each data.modules as mod}
                        {@const Icon = iconMap[mod.definition.icon]}
                        {@const stateDisplay = getOperationalStateDisplay(mod.operationalState)}
                        {@const primaryAction = getPrimaryAction(mod.operationalState)}
                        <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 border-l-4 {stateDisplay.borderClass} overflow-hidden hover:shadow-sm transition-shadow">
                            <a href="/domains/{data.domain.slug}/modules/{mod.id}" class="block p-4">
                                <div class="flex items-start justify-between mb-2">
                                    <div class="flex items-center gap-2.5">
                                        <div class="w-8 h-8 rounded-lg bg-primary-100 dark:bg-primary-900/30 flex items-center justify-center flex-shrink-0">
                                            {#if Icon}
                                                <Icon class="w-4 h-4 text-primary-600 dark:text-primary-400" />
                                            {/if}
                                        </div>
                                        <span class="font-medium text-secondary-900 dark:text-secondary-100 text-sm">{mod.displayName || mod.definition.name}</span>
                                    </div>
                                    <Badge color={stateDisplay.badgeColor} class="text-xs">{stateDisplay.label}</Badge>
                                </div>
                                <p class="text-xs text-secondary-500 dark:text-secondary-400 truncate">{mod.definition.description}</p>
                            </a>
                            <div class="px-4 pb-3 flex items-center justify-between border-t border-secondary-100 dark:border-secondary-700 pt-3">
                                <form method="POST" action="?/transition">
                                    <input type="hidden" name="moduleId" value={mod.id} />
                                    <input type="hidden" name="targetState" value={primaryAction.targetState} />
                                    <button type="submit" class={primaryActionButtonClass(primaryAction.style)}>
                                        {primaryAction.verb}
                                    </button>
                                </form>
                                <a href="/domains/{data.domain.slug}/modules/{mod.id}" class="text-xs text-secondary-400 hover:text-primary-600 dark:hover:text-primary-400 transition-colors">Details →</a>
                            </div>
                        </div>
                    {/each}
                </div>
            {/if}
        </div>

        <!-- Info sidebar -->
        <div class="space-y-4">
            <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 p-5">
                <h3 class="text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-500 mb-4">Domain Info</h3>
                <dl class="space-y-3">
                    <div class="flex items-center justify-between">
                        <dt class="text-sm text-secondary-500 dark:text-secondary-400">Status</dt>
                        <dd><Badge color="yellow" class="capitalize">{data.domain.status}</Badge></dd>
                    </div>
                    <div class="flex items-center justify-between">
                        <dt class="text-sm text-secondary-500 dark:text-secondary-400">Your role</dt>
                        <dd><Badge color="purple" class="capitalize text-xs">{data.membership.role.replace('_', ' ')}</Badge></dd>
                    </div>
                    <div class="flex items-center justify-between">
                        <dt class="text-sm text-secondary-500 dark:text-secondary-400 flex items-center gap-1.5">
                            <UsersIcon class="w-3.5 h-3.5" />
                            Members
                        </dt>
                        <dd class="text-sm font-medium text-secondary-900 dark:text-secondary-100">{data.members.length}</dd>
                    </div>
                    <div class="flex items-center justify-between">
                        <dt class="text-sm text-secondary-500 dark:text-secondary-400 flex items-center gap-1.5">
                            <GridPlusOutline class="w-3.5 h-3.5" />
                            Modules
                        </dt>
                        <dd class="text-sm font-medium text-secondary-900 dark:text-secondary-100">{data.modules.length}</dd>
                    </div>
                    <div>
                        <dt class="text-sm text-secondary-500 dark:text-secondary-400 flex items-center gap-1.5 mb-1">
                            <CalIcon class="w-3.5 h-3.5" />
                            Created
                        </dt>
                        <dd class="text-sm text-secondary-700 dark:text-secondary-300">{formatDate(data.domain.createdAt)}</dd>
                    </div>
                    {#if data.domain.businessType}
                        <div>
                            <dt class="text-sm text-secondary-500 dark:text-secondary-400 mb-1">Business type</dt>
                            <dd class="text-sm text-secondary-700 dark:text-secondary-300">{data.domain.businessType}</dd>
                        </div>
                    {/if}
                </dl>
            </div>

            <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 p-5">
                <h3 class="text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-500 mb-3">Quick Links</h3>
                <div class="space-y-1">
                    <a href="/domains/{data.domain.slug}/catalogue" class="block text-sm text-secondary-600 dark:text-secondary-400 hover:text-primary-600 dark:hover:text-primary-400 py-1 transition-colors">Module catalogue →</a>
                    <a href="/domains/{data.domain.slug}/settings" class="block text-sm text-secondary-600 dark:text-secondary-400 hover:text-primary-600 dark:hover:text-primary-400 py-1 transition-colors">Domain settings →</a>
                    <a href="/domains" class="block text-sm text-secondary-600 dark:text-secondary-400 hover:text-primary-600 dark:hover:text-primary-400 py-1 transition-colors">All domains →</a>
                </div>
            </div>
        </div>
    </div>
</div>
