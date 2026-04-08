<script lang="ts">
    import { Badge, Button } from 'flowbite-svelte';
    import {
        TagOutline, UsersOutline, CalendarMonthOutline, UserSettingsOutline,
        ChartOutline, ShieldCheckOutline, ChevronDownOutline, ChevronUpOutline,
        CheckCircleSolid
    } from 'flowbite-svelte-icons';
    import { CONCERN_META } from '$lib/context/schemas.js';
    import { getOperationalStateDisplay } from '$lib/modules/lifecycle.js';
    import { BMM_CONCERNS } from '$lib/types.js';
    import type { BmmConcern, DomainContext, ModuleInstanceWithDefinition } from '$lib/types';
    import type { PageData, ActionData } from './$types';
    import { enhance } from '$app/forms';

    let { data, form }: { data: PageData; form: ActionData } = $props();

    const iconMap: Record<string, any> = {
        TagOutline, UsersOutline, CalendarMonthOutline, UserSettingsOutline,
        ChartOutline, ShieldCheckOutline
    };

    // Track which concern sections are expanded
    let expanded = $state<Record<string, boolean>>(
        Object.fromEntries(BMM_CONCERNS.map(c => [c, false]))
    );

    function toggleConcern(concern: string) {
        expanded[concern] = !expanded[concern];
    }

    function getContextForConcern(concern: BmmConcern): DomainContext | undefined {
        return data.contexts.find((c: DomainContext) => c.concern === concern);
    }

    function getModulesForConcern(concern: BmmConcern): ModuleInstanceWithDefinition[] {
        return data.modules.filter((m: ModuleInstanceWithDefinition) =>
            m.definition.bmmConcerns.includes(concern)
        );
    }

    function hasValues(ctx: DomainContext | undefined): boolean {
        if (!ctx) return false;
        return Object.values(ctx.contextValues).some(v => v !== '' && v !== 0 && v !== false && v !== null && v !== undefined);
    }

    // Concern accent colours (subtle, warm teal palette)
    const concernAccent: Record<string, string> = {
        ServiceConcept: 'border-l-teal-500',
        ActivityModel: 'border-l-cyan-500',
        ResourcePlanning: 'border-l-emerald-500',
        FinancialPlanning: 'border-l-amber-500',
        GovernanceMapping: 'border-l-rose-400',
        StakeholderModel: 'border-l-violet-400'
    };
</script>

<svelte:head>
    <title>Domain Context — {data.domain.name} — Ontara Portal</title>
</svelte:head>

<div class="p-6 max-w-5xl mx-auto">
    <div class="mb-8">
        <a href="/domains/{data.domain.slug}" class="text-sm text-primary-600 dark:text-primary-400 hover:underline">← Back to dashboard</a>
        <h1 class="text-2xl font-semibold text-secondary-900 dark:text-secondary-100 mt-3">Domain Context</h1>
        <p class="text-sm text-secondary-500 dark:text-secondary-400 mt-1">
            The shared context that shapes how modules work together in <strong>{data.domain.name}</strong>. Each section represents a dimension of your service business.
        </p>
    </div>

    <div class="space-y-4">
        {#each BMM_CONCERNS as concern}
            {@const meta = CONCERN_META[concern]}
            {@const ctx = getContextForConcern(concern)}
            {@const modules = getModulesForConcern(concern)}
            {@const Icon = iconMap[meta.icon]}
            {@const isExpanded = expanded[concern]}
            {@const filled = hasValues(ctx)}
            {@const justSaved = form?.success && form?.concern === concern}

            <div
                id={concern}
                class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 border-l-4 {concernAccent[concern]} overflow-hidden"
            >
                <!-- Header (always visible) -->
                <button
                    onclick={() => toggleConcern(concern)}
                    class="w-full flex items-center justify-between p-5 text-left hover:bg-secondary-50 dark:hover:bg-secondary-750 transition-colors"
                >
                    <div class="flex items-center gap-3">
                        <div class="w-9 h-9 rounded-lg bg-primary-100 dark:bg-primary-900/30 flex items-center justify-center flex-shrink-0">
                            {#if Icon}
                                <Icon class="w-4.5 h-4.5 text-primary-600 dark:text-primary-400" />
                            {/if}
                        </div>
                        <div>
                            <h2 class="font-semibold text-secondary-900 dark:text-secondary-100 text-sm">{meta.label}</h2>
                            <p class="text-xs text-secondary-500 dark:text-secondary-400 mt-0.5">{meta.description}</p>
                        </div>
                    </div>
                    <div class="flex items-center gap-3 flex-shrink-0">
                        {#if modules.length > 0}
                            <span class="text-xs text-secondary-400">{modules.length} module{modules.length !== 1 ? 's' : ''}</span>
                        {/if}
                        {#if filled}
                            <CheckCircleSolid class="w-4 h-4 text-green-500" />
                        {/if}
                        {#if justSaved}
                            <Badge color="green" class="text-xs">Saved</Badge>
                        {/if}
                        {#if isExpanded}
                            <ChevronUpOutline class="w-4 h-4 text-secondary-400" />
                        {:else}
                            <ChevronDownOutline class="w-4 h-4 text-secondary-400" />
                        {/if}
                    </div>
                </button>

                <!-- Expanded content -->
                {#if isExpanded}
                    <div class="border-t border-secondary-100 dark:border-secondary-700">
                        <!-- Modules in this concern -->
                        {#if modules.length > 0}
                            <div class="px-5 py-3 bg-secondary-50 dark:bg-secondary-900/30 border-b border-secondary-100 dark:border-secondary-700">
                                <p class="text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-500 mb-2">Modules in this concern</p>
                                <div class="flex flex-wrap gap-2">
                                    {#each modules as mod}
                                        {@const stateDisplay = getOperationalStateDisplay(mod.operationalState)}
                                        <a
                                            href="/domains/{data.domain.slug}/modules/{mod.id}"
                                            class="flex items-center gap-1.5 text-xs bg-white dark:bg-secondary-800 border border-secondary-200 dark:border-secondary-700 rounded-lg px-2.5 py-1.5 hover:border-primary-300 dark:hover:border-primary-600 transition-colors"
                                        >
                                            <span class="w-2 h-2 rounded-full {stateDisplay.dotClass} flex-shrink-0"></span>
                                            <span class="text-secondary-700 dark:text-secondary-300">{mod.displayName || mod.definition.name}</span>
                                        </a>
                                    {/each}
                                </div>
                            </div>
                        {:else}
                            <div class="px-5 py-3 bg-secondary-50 dark:bg-secondary-900/30 border-b border-secondary-100 dark:border-secondary-700">
                                <p class="text-xs text-secondary-400">No modules installed for this concern.
                                    <a href="/domains/{data.domain.slug}/catalogue" class="text-primary-600 dark:text-primary-400 hover:underline">Browse catalogue →</a>
                                </p>
                            </div>
                        {/if}

                        <!-- Context form -->
                        <form method="POST" action="?/updateContext" use:enhance class="p-5 space-y-4">
                            <input type="hidden" name="concern" value={concern} />
                            {#each meta.schema as field}
                                {@const val = ctx?.contextValues[field.key] ?? field.defaultValue}
                                <div>
                                    <label for="{concern}-{field.key}" class="block text-sm font-medium text-secondary-700 dark:text-secondary-300 mb-1">
                                        {field.label}
                                        {#if field.required}<span class="text-red-400">*</span>{/if}
                                    </label>
                                    <p class="text-xs text-secondary-400 mb-1.5">{field.description}</p>
                                    {#if field.type === 'text'}
                                        <input
                                            id="{concern}-{field.key}"
                                            name={field.key}
                                            type="text"
                                            value={val}
                                            class="w-full rounded-lg border border-secondary-300 dark:border-secondary-600 bg-white dark:bg-secondary-900 text-sm text-secondary-900 dark:text-secondary-100 px-3 py-2 focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                                        />
                                    {:else if field.type === 'number'}
                                        <input
                                            id="{concern}-{field.key}"
                                            name={field.key}
                                            type="number"
                                            value={val}
                                            class="w-full rounded-lg border border-secondary-300 dark:border-secondary-600 bg-white dark:bg-secondary-900 text-sm text-secondary-900 dark:text-secondary-100 px-3 py-2 focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                                        />
                                    {:else if field.type === 'boolean'}
                                        <label class="flex items-center gap-2">
                                            <input
                                                id="{concern}-{field.key}"
                                                name={field.key}
                                                type="checkbox"
                                                checked={val === true}
                                                class="rounded border-secondary-300 dark:border-secondary-600 text-primary-600 focus:ring-primary-500"
                                            />
                                            <span class="text-sm text-secondary-600 dark:text-secondary-400">Yes</span>
                                        </label>
                                    {:else if field.type === 'select'}
                                        <select
                                            id="{concern}-{field.key}"
                                            name={field.key}
                                            class="w-full rounded-lg border border-secondary-300 dark:border-secondary-600 bg-white dark:bg-secondary-900 text-sm text-secondary-900 dark:text-secondary-100 px-3 py-2 focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                                        >
                                            {#each field.options ?? [] as opt}
                                                <option value={opt.value} selected={val === opt.value}>{opt.label}</option>
                                            {/each}
                                        </select>
                                    {/if}
                                </div>
                            {/each}
                            <div class="pt-2">
                                <Button type="submit" color="primary" size="sm">Save {meta.label}</Button>
                            </div>
                        </form>
                    </div>
                {/if}
            </div>
        {/each}
    </div>
</div>
