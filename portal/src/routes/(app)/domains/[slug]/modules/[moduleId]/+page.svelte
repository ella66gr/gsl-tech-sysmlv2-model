<script lang="ts">
    import { Badge, Button } from 'flowbite-svelte';
    import {
        TagOutline, UsersOutline, CalendarMonthOutline, UserSettingsOutline,
        ChartOutline, ShieldCheckOutline, ChartMixedOutline,
        CogOutline, TrashBinOutline, CalendarMonthOutline as CalendarOutline
    } from 'flowbite-svelte-icons';
    import { getOperationalStateDisplay, getAvailableActions } from '$lib/modules/lifecycle.js';
    import { findConnectedModules } from '$lib/modules/connections.js';
    import { enhance } from '$app/forms';
    import type { PageData, ActionData } from './$types';

    let { data, form }: { data: PageData; form: ActionData } = $props();

    const connections = $derived(findConnectedModules(data.instance, data.allModules));

    const iconMap: Record<string, any> = {
        TagOutline, UsersOutline, CalendarMonthOutline, UserSettingsOutline,
        ChartOutline, ShieldCheckOutline, ChartMixedOutline
    };

    const Icon = $derived(iconMap[data.instance.definition.icon]);
    const stateDisplay = $derived(getOperationalStateDisplay(data.instance.operationalState));
    const actions = $derived(getAvailableActions(data.instance.operationalState));

    function actionButtonClass(style: string): string {
        switch (style) {
            case 'primary':   return 'bg-primary-600 hover:bg-primary-700 text-white';
            case 'warning':   return 'bg-yellow-400 hover:bg-yellow-500 text-yellow-900';
            case 'danger':    return 'bg-red-600 hover:bg-red-700 text-white';
            case 'secondary': return 'bg-secondary-100 dark:bg-secondary-700 hover:bg-secondary-200 dark:hover:bg-secondary-600 text-secondary-700 dark:text-secondary-300';
            default:          return '';
        }
    }

    function formatDateTime(iso: string) {
        return new Date(iso).toLocaleString('en-GB', { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' });
    }

    function transitionLabel(from: string, to: string, type: string): string {
        if (type === 'installation') {
            if (to === 'installed') return 'Installed';
            if (to === 'trashed') return 'Trashed';
            if (from === 'available') return 'Installed from catalogue';
            if (to === 'installed') return 'Restored';
        }
        const verbs: Record<string, string> = {
            'draft→active': 'Activated',
            'active→paused': 'Paused',
            'paused→active': 'Resumed',
            'active→stopped': 'Stopped',
            'paused→stopped': 'Stopped',
            'stopped→draft': 'Reset to draft'
        };
        return verbs[`${from}→${to}`] ?? `${from} → ${to}`;
    }

    let showTrashConfirm = $state(false);
</script>

<svelte:head>
    <title>{data.instance.displayName || data.instance.definition.name} — Ontara Portal</title>
</svelte:head>

<div class="p-6 max-w-5xl mx-auto">
    <!-- Header -->
    <div class="mb-6">
        <a href="/domains/{data.domain.slug}" class="text-sm text-primary-600 dark:text-primary-400 hover:underline">← Back to dashboard</a>
        <div class="flex items-start justify-between mt-3">
            <div class="flex items-center gap-4">
                <div class="w-12 h-12 rounded-xl bg-primary-100 dark:bg-primary-900/30 flex items-center justify-center">
                    {#if Icon}
                        <Icon class="w-6 h-6 text-primary-600 dark:text-primary-400" />
                    {/if}
                </div>
                <div>
                    <h1 class="text-2xl font-semibold text-secondary-900 dark:text-secondary-100">
                        {data.instance.displayName || data.instance.definition.name}
                    </h1>
                    <p class="text-sm text-secondary-500 dark:text-secondary-400">{data.instance.definition.name}</p>
                </div>
            </div>
            <Badge color={stateDisplay.badgeColor} class="text-sm px-3 py-1">{stateDisplay.label}</Badge>
        </div>
    </div>

    <!-- Lifecycle actions bar -->
    <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 p-5 mb-6">
        <h2 class="text-sm font-semibold text-secondary-700 dark:text-secondary-300 mb-3">Lifecycle Actions</h2>
        <div class="flex flex-wrap gap-2">
            {#each actions as action}
                <form method="POST" action="?/transition" use:enhance>
                    <input type="hidden" name="targetState" value={action.targetState} />
                    <button
                        type="submit"
                        class="px-4 py-2 rounded-lg text-sm font-medium transition-colors {actionButtonClass(action.style)}"
                    >
                        {action.verb}
                    </button>
                </form>
            {/each}
            <a
                href="/domains/{data.domain.slug}/modules/{data.instance.id}/configure"
                class="px-4 py-2 rounded-lg text-sm font-medium bg-secondary-100 dark:bg-secondary-700 hover:bg-secondary-200 dark:hover:bg-secondary-600 text-secondary-700 dark:text-secondary-300 transition-colors flex items-center gap-1.5"
            >
                <CogOutline class="w-4 h-4" />
                Configure
            </a>
        </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Main: connections + config summary + history -->
        <div class="lg:col-span-2 space-y-6">
            <!-- Connections -->
            <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 p-5">
                <h2 class="font-semibold text-secondary-900 dark:text-secondary-100 mb-3">Connections</h2>
                {#if connections.length > 0}
                    <p class="text-sm text-secondary-500 dark:text-secondary-400 mb-4">
                        This module shares BMM concerns with {connections.length} other module{connections.length !== 1 ? 's' : ''}.
                    </p>
                    <div class="space-y-3">
                        {#each connections as conn}
                            {@const connState = getOperationalStateDisplay(conn.module.operationalState)}
                            <a
                                href="/domains/{data.domain.slug}/modules/{conn.module.id}"
                                class="flex items-center justify-between p-3 rounded-xl bg-secondary-50 dark:bg-secondary-900/30 border border-secondary-100 dark:border-secondary-700 hover:border-primary-300 dark:hover:border-primary-600 transition-colors"
                            >
                                <div class="flex items-center gap-2.5">
                                    <span class="w-2 h-2 rounded-full {connState.dotClass} flex-shrink-0"></span>
                                    <span class="text-sm font-medium text-secondary-800 dark:text-secondary-200">
                                        {conn.module.displayName || conn.module.definition.name}
                                    </span>
                                </div>
                                <div class="flex gap-1">
                                    {#each conn.sharedConcerns as concern}
                                        <span class="text-xs px-2 py-0.5 rounded-full bg-primary-100 dark:bg-primary-900/40 text-primary-700 dark:text-primary-300">{concern}</span>
                                    {/each}
                                </div>
                            </a>
                        {/each}
                    </div>
                {:else}
                    <p class="text-sm text-secondary-400">
                        This module operates independently — it does not share BMM concerns with other installed modules.
                    </p>
                {/if}

                <!-- Domain context link -->
                <div class="mt-4 pt-3 border-t border-secondary-100 dark:border-secondary-700">
                    <p class="text-xs text-secondary-400 mb-2">Draws from domain context:</p>
                    <div class="flex flex-wrap gap-1.5">
                        {#each data.instance.definition.bmmConcerns as concern}
                            <a
                                href="/domains/{data.domain.slug}/context#{concern}"
                                class="text-xs px-2.5 py-1 rounded-lg bg-secondary-100 dark:bg-secondary-700 text-secondary-600 dark:text-secondary-400 hover:text-primary-600 dark:hover:text-primary-400 hover:bg-primary-50 dark:hover:bg-primary-900/20 transition-colors"
                            >
                                {concern} →
                            </a>
                        {/each}
                    </div>
                </div>
            </div>

            <!-- Config summary -->
            {#if Object.keys(data.instance.configValues).length > 0}
                <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 p-5">
                    <div class="flex items-center justify-between mb-4">
                        <h2 class="font-semibold text-secondary-900 dark:text-secondary-100">Configuration</h2>
                        <a href="/domains/{data.domain.slug}/modules/{data.instance.id}/configure" class="text-sm text-primary-600 dark:text-primary-400 hover:underline">Edit →</a>
                    </div>
                    <dl class="space-y-2">
                        {#each data.instance.definition.configSchema as field}
                            {@const val = data.instance.configValues[field.key]}
                            {#if val !== undefined && val !== ''}
                                <div class="flex items-start gap-4">
                                    <dt class="text-sm text-secondary-500 dark:text-secondary-400 w-40 flex-shrink-0">{field.label}</dt>
                                    <dd class="text-sm text-secondary-800 dark:text-secondary-200 font-medium">
                                        {field.type === 'boolean' ? (val ? 'Yes' : 'No') : String(val)}
                                    </dd>
                                </div>
                            {/if}
                        {/each}
                    </dl>
                </div>
            {:else}
                <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 p-5">
                    <p class="text-sm text-secondary-400">No configuration saved yet.
                        <a href="/domains/{data.domain.slug}/modules/{data.instance.id}/configure" class="text-primary-600 dark:text-primary-400 hover:underline">Configure now →</a>
                    </p>
                </div>
            {/if}

            <!-- Transition history -->
            <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 p-5">
                <h2 class="font-semibold text-secondary-900 dark:text-secondary-100 mb-4">History</h2>
                {#if data.transitions.length === 0}
                    <p class="text-sm text-secondary-400">No transitions recorded yet.</p>
                {:else}
                    <ol class="relative border-l border-secondary-200 dark:border-secondary-700 ml-3 space-y-4">
                        {#each data.transitions as t}
                            <li class="ml-4">
                                <div class="absolute w-2 h-2 rounded-full -left-1 bg-secondary-300 dark:bg-secondary-600 mt-1.5"></div>
                                <p class="text-sm font-medium text-secondary-800 dark:text-secondary-200">
                                    {transitionLabel(t.fromState, t.toState, t.lifecycleType)}
                                </p>
                                <div class="flex items-center gap-2 mt-0.5">
                                    <Badge color={t.lifecycleType === 'operational' ? 'teal' : 'gray'} class="text-xs">{t.lifecycleType}</Badge>
                                    <span class="text-xs text-secondary-400">{formatDateTime(t.createdAt)}</span>
                                </div>
                                {#if t.note}
                                    <p class="text-xs text-secondary-400 mt-0.5">{t.note}</p>
                                {/if}
                            </li>
                        {/each}
                    </ol>
                {/if}
            </div>
        </div>

        <!-- Sidebar: module info + danger zone -->
        <div class="space-y-4">
            <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 p-5">
                <h3 class="text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-500 mb-4">Module Info</h3>
                <div class="space-y-3">
                    <div>
                        <p class="text-xs text-secondary-400 mb-1">Definition</p>
                        <p class="text-sm text-secondary-800 dark:text-secondary-200">{data.instance.definition.name}</p>
                    </div>
                    <div>
                        <p class="text-xs text-secondary-400 mb-1">Category</p>
                        <Badge color={data.instance.definition.category === 'business' ? 'teal' : 'blue'} class="capitalize text-xs">{data.instance.definition.category}</Badge>
                    </div>
                    <div>
                        <p class="text-xs text-secondary-400 mb-1.5">BMM Concerns</p>
                        <div class="flex flex-wrap gap-1">
                            {#each data.instance.definition.bmmConcerns as concern}
                                <span class="text-xs px-2 py-0.5 rounded-full bg-secondary-100 dark:bg-secondary-700 text-secondary-500 dark:text-secondary-400">{concern}</span>
                            {/each}
                        </div>
                    </div>
                    <div>
                        <p class="text-xs text-secondary-400 mb-1">Installed</p>
                        <p class="text-sm text-secondary-600 dark:text-secondary-400">{formatDateTime(data.instance.installedAt)}</p>
                    </div>
                </div>
            </div>

            <!-- Danger zone -->
            <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-red-200 dark:border-red-900/50 p-5">
                <h3 class="text-xs font-semibold uppercase tracking-wider text-red-400 mb-3">Danger Zone</h3>
                {#if !showTrashConfirm}
                    <button
                        onclick={() => (showTrashConfirm = true)}
                        class="flex items-center gap-2 text-sm text-red-600 dark:text-red-400 hover:text-red-700 dark:hover:text-red-300 transition-colors"
                    >
                        <TrashBinOutline class="w-4 h-4" />
                        Move to trash
                    </button>
                {:else}
                    <p class="text-sm text-secondary-600 dark:text-secondary-400 mb-3">Move this module to trash? It can be restored from domain settings.</p>
                    <div class="flex gap-2">
                        <form method="POST" action="?/trash">
                            <button type="submit" class="px-3 py-1.5 rounded-lg text-sm bg-red-600 hover:bg-red-700 text-white transition-colors">Confirm</button>
                        </form>
                        <button
                            onclick={() => (showTrashConfirm = false)}
                            class="px-3 py-1.5 rounded-lg text-sm bg-secondary-100 dark:bg-secondary-700 text-secondary-700 dark:text-secondary-300 hover:bg-secondary-200 dark:hover:bg-secondary-600 transition-colors"
                        >
                            Cancel
                        </button>
                    </div>
                {/if}
            </div>
        </div>
    </div>
</div>

<!-- Impact warning modal -->
{#if form?.confirmNeeded}
    <div class="fixed inset-0 bg-black/40 z-40"></div>
    <div class="fixed inset-0 z-50 flex items-center justify-center p-4">
        <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 shadow-xl max-w-md w-full p-5">
            <h2 class="text-lg font-semibold text-secondary-900 dark:text-secondary-100 mb-2">Impact Warning</h2>
            <p class="text-sm text-secondary-500 dark:text-secondary-400 mb-4">
                This action may affect connected modules that share BMM concerns.
            </p>
            <div class="space-y-2 mb-5">
                {#each form.affectedModules as aff}
                    <div class="flex items-center justify-between p-3 rounded-lg bg-yellow-50 dark:bg-yellow-900/10 border border-yellow-200 dark:border-yellow-800">
                        <span class="text-sm font-medium text-secondary-800 dark:text-secondary-200">{aff.name}</span>
                        <div class="flex gap-1">
                            {#each aff.sharedConcerns as c}
                                <span class="text-xs px-1.5 py-0.5 rounded bg-yellow-100 dark:bg-yellow-800 text-yellow-700 dark:text-yellow-300">{c}</span>
                            {/each}
                        </div>
                    </div>
                {/each}
            </div>
            <div class="flex gap-3">
                <form method="POST" action="?/transition" use:enhance class="flex-1">
                    <input type="hidden" name="targetState" value={form.targetState} />
                    <input type="hidden" name="confirmed" value="true" />
                    <Button type="submit" color="yellow" class="w-full">Proceed Anyway</Button>
                </form>
                <Button href="/domains/{data.domain.slug}/modules/{data.instance.id}" color="alternative">Cancel</Button>
            </div>
        </div>
    </div>
{/if}
