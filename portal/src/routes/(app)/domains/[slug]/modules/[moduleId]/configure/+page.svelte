<script lang="ts">
    import { Badge, Button, Helper, Input, Label, Select, Toggle, Textarea } from 'flowbite-svelte';
    import {
        TagOutline, UsersOutline, CalendarMonthOutline, UserSettingsOutline,
        ChartOutline, ShieldCheckOutline, ChartMixedOutline
    } from 'flowbite-svelte-icons';
    import { getOperationalStateDisplay } from '$lib/modules/lifecycle.js';
    import type { PageData } from './$types';
    import type { ConfigFieldDefinition } from '$lib/types';

    let { data }: { data: PageData } = $props();

    const iconMap: Record<string, any> = {
        TagOutline, UsersOutline, CalendarMonthOutline, UserSettingsOutline,
        ChartOutline, ShieldCheckOutline, ChartMixedOutline
    };

    const Icon = $derived(iconMap[data.instance.definition.icon]);
    const stateDisplay = $derived(getOperationalStateDisplay(data.instance.operationalState));

    function currentValue(field: ConfigFieldDefinition): string | number | boolean {
        const stored = data.instance.configValues[field.key];
        return stored !== undefined ? stored as string | number | boolean : field.defaultValue;
    }

    // Parse the existing comparison module IDs for the picker
    let selectedComparisonIds = $state<Set<string>>(new Set(
        ((data.instance.configValues?.comparisonModuleIds as string) ?? '')
            .split(',')
            .map(s => s.trim())
            .filter(Boolean)
    ));

    function toggleComparison(id: string) {
        const next = new Set(selectedComparisonIds);
        if (next.has(id)) {
            next.delete(id);
        } else {
            next.add(id);
        }
        selectedComparisonIds = next;
    }

    let comparisonIdsString = $derived(Array.from(selectedComparisonIds).join(','));
</script>

<svelte:head>
    <title>Configure {data.instance.definition.name} — Ontara Portal</title>
</svelte:head>

<div class="p-6 max-w-4xl mx-auto">
    <div class="mb-6">
        <a href="/domains/{data.domain.slug}/modules/{data.instance.id}" class="text-sm text-primary-600 dark:text-primary-400 hover:underline">← Back to module</a>
        <div class="flex items-center gap-3 mt-3">
            <div class="w-10 h-10 rounded-xl bg-primary-100 dark:bg-primary-900/30 flex items-center justify-center">
                {#if Icon}
                    <Icon class="w-5 h-5 text-primary-600 dark:text-primary-400" />
                {/if}
            </div>
            <div>
                <h1 class="text-xl font-semibold text-secondary-900 dark:text-secondary-100">
                    {data.instance.displayName || data.instance.definition.name}
                </h1>
                <div class="flex items-center gap-2 mt-0.5">
                    <span class="text-sm text-secondary-500 dark:text-secondary-400">{data.instance.definition.name}</span>
                    <Badge color={stateDisplay.badgeColor}>{stateDisplay.label}</Badge>
                </div>
            </div>
        </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Config form -->
        <div class="lg:col-span-2">
            <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 p-6">
                <h2 class="font-semibold text-secondary-900 dark:text-secondary-100 mb-6">Configuration</h2>
                <form method="POST" class="space-y-6">
                    {#each data.instance.definition.configSchema as field}
                        <div>
                            <Label for={field.key} class="mb-1.5 text-secondary-700 dark:text-secondary-300">
                                {field.label}{field.required ? ' *' : ''}
                            </Label>
                            {#if field.key === 'comparisonModuleIds' && data.businessModules.length > 0}
                                <!-- Module picker for comparison set -->
                                <input type="hidden" name={field.key} value={comparisonIdsString} />
                                <div class="space-y-2 max-h-56 overflow-y-auto p-3 rounded-xl border border-secondary-200 dark:border-secondary-700 bg-secondary-50 dark:bg-secondary-900/30">
                                    {#each data.businessModules as bm}
                                        {@const isSelected = selectedComparisonIds.has(bm.id)}
                                        <label class="flex items-center gap-2.5 py-1.5 cursor-pointer">
                                            <input
                                                type="checkbox"
                                                checked={isSelected}
                                                onchange={() => toggleComparison(bm.id)}
                                                class="rounded border-secondary-300 dark:border-secondary-600 text-primary-600 focus:ring-primary-500"
                                            />
                                            <span class="text-sm text-secondary-700 dark:text-secondary-300">{bm.displayName || bm.definition.name}</span>
                                            <Badge color={bm.epistemicCharacter === 'hypothesis' ? 'purple' : bm.epistemicCharacter === 'projection' ? 'blue' : 'teal'} class="text-xs ml-auto">{bm.epistemicCharacter}</Badge>
                                        </label>
                                    {/each}
                                </div>
                                <p class="text-xs text-secondary-400 mt-1">
                                    {selectedComparisonIds.size} module{selectedComparisonIds.size !== 1 ? 's' : ''} selected for comparison.
                                </p>
                            {:else if field.type === 'text'}
                                <Input
                                    id={field.key}
                                    name={field.key}
                                    type="text"
                                    value={String(currentValue(field))}
                                    placeholder={String(field.defaultValue)}
                                />
                            {:else if field.type === 'number'}
                                <Input
                                    id={field.key}
                                    name={field.key}
                                    type="number"
                                    value={String(currentValue(field))}
                                />
                            {:else if field.type === 'boolean'}
                                <div class="flex items-center gap-3 mt-1">
                                    <Toggle
                                        id={field.key}
                                        name={field.key}
                                        checked={Boolean(currentValue(field))}
                                    />
                                    <span class="text-sm text-secondary-600 dark:text-secondary-400">{field.label}</span>
                                </div>
                            {:else if field.type === 'select' && field.options}
                                <Select
                                    id={field.key}
                                    name={field.key}
                                    value={String(currentValue(field))}
                                    items={field.options.map(o => ({ value: o.value, name: o.label }))}
                                />
                            {/if}
                            {#if field.description}
                                <Helper class="mt-1 text-secondary-400 dark:text-secondary-500">{field.description}</Helper>
                            {/if}
                        </div>
                    {/each}

                    <div class="flex gap-3 pt-2">
                        <Button type="submit" color="primary">Save Configuration</Button>
                        <Button href="/domains/{data.domain.slug}/modules/{data.instance.id}" color="alternative">Cancel</Button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Module info sidebar -->
        <div class="space-y-4">
            <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 p-5">
                <h3 class="text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-500 mb-4">About this module</h3>
                <p class="text-sm text-secondary-600 dark:text-secondary-400 leading-relaxed mb-4">{data.instance.definition.description}</p>
                <div class="space-y-3">
                    <div>
                        <p class="text-xs text-secondary-400 mb-1">Category</p>
                        <Badge color={data.instance.definition.category === 'business' ? 'teal' : 'blue'} class="capitalize">{data.instance.definition.category}</Badge>
                    </div>
                    <div>
                        <p class="text-xs text-secondary-400 mb-1.5">BMM Concerns</p>
                        <div class="flex flex-wrap gap-1">
                            {#each data.instance.definition.bmmConcerns as concern}
                                <span class="text-xs px-2 py-0.5 rounded-full bg-secondary-100 dark:bg-secondary-700 text-secondary-500 dark:text-secondary-400">{concern}</span>
                            {/each}
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
