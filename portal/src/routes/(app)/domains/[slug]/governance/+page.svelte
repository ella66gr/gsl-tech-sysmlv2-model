<script lang="ts">
    import { Badge } from 'flowbite-svelte';
    import { ShieldCheckOutline } from 'flowbite-svelte-icons';
    import { getEpistemicDisplay } from '$lib/modules/epistemic.js';
    import { enhance } from '$app/forms';
    import type { PageData, ActionData } from './$types';
    import type { ConstraintResult, GovernanceLevel } from '$lib/types';

    let { data, form }: { data: PageData; form: ActionData } = $props();

    const levelDescriptions: Record<GovernanceLevel, string> = {
        exploratory: 'Constraints are visible but non-blocking. Ideal for experimentation and initial setup.',
        advisory: 'Constraints are evaluated and warnings are shown. Hard constraint violations are flagged but do not block actions.',
        enforced: 'Hard constraints block promotion to production. Required before any module can be promoted.'
    };

    const levelColors: Record<GovernanceLevel, 'blue' | 'yellow' | 'green'> = {
        exploratory: 'blue',
        advisory: 'yellow',
        enforced: 'green'
    };

    function constraintIcon(result: ConstraintResult, governanceLevel: GovernanceLevel): { color: string; symbol: string } {
        if (result.satisfied) {
            return { color: 'text-green-600 dark:text-green-400', symbol: '✓' };
        }
        if (result.constraint.level === 'hard') {
            return governanceLevel === 'enforced'
                ? { color: 'text-red-600 dark:text-red-400', symbol: '✗' }
                : { color: 'text-red-500 dark:text-red-400', symbol: '!' };
        }
        if (result.constraint.level === 'soft') {
            return { color: 'text-amber-500 dark:text-amber-400', symbol: '~' };
        }
        // graded
        return { color: 'text-amber-400 dark:text-amber-500', symbol: '~' };
    }

    function levelBadgeColor(level: string): 'red' | 'yellow' | 'green' {
        if (level === 'hard') return 'red';
        if (level === 'soft') return 'yellow';
        return 'green';
    }
</script>

<svelte:head>
    <title>Governance — {data.domain.name} — Ontara Portal</title>
</svelte:head>

<div class="p-6 max-w-5xl mx-auto">
    <!-- Header -->
    <div class="flex items-start justify-between mb-6">
        <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-xl bg-teal-100 dark:bg-teal-900/30 flex items-center justify-center">
                <ShieldCheckOutline class="w-5 h-5 text-teal-600 dark:text-teal-400" />
            </div>
            <div>
                <h1 class="text-2xl font-semibold text-secondary-900 dark:text-secondary-100">Governance</h1>
                <p class="text-secondary-500 dark:text-secondary-400 text-sm">{data.domain.name}</p>
            </div>
        </div>
    </div>

    <!-- Governance level selector -->
    <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 p-5 mb-6">
        <h2 class="text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-500 mb-3">Governance Level</h2>
        <form method="POST" action="?/updateGovernanceLevel" use:enhance>
            <div class="grid grid-cols-1 sm:grid-cols-3 gap-3">
                {#each (['exploratory', 'advisory', 'enforced'] as const) as level}
                    <label class="relative flex flex-col p-4 rounded-xl border-2 cursor-pointer transition-all {data.domain.governanceLevel === level ? 'border-primary-400 dark:border-primary-500 bg-primary-50/50 dark:bg-primary-900/20' : 'border-secondary-200 dark:border-secondary-700 hover:border-secondary-300 dark:hover:border-secondary-600'}">
                        <input
                            type="radio"
                            name="governanceLevel"
                            value={level}
                            checked={data.domain.governanceLevel === level}
                            onchange={(e) => e.currentTarget.form?.requestSubmit()}
                            class="sr-only"
                        />
                        <div class="flex items-center gap-2 mb-1">
                            <Badge color={levelColors[level]} class="text-xs capitalize">{level}</Badge>
                            {#if data.domain.governanceLevel === level}
                                <span class="text-xs text-primary-600 dark:text-primary-400 font-medium">Current</span>
                            {/if}
                        </div>
                        <p class="text-xs text-secondary-500 dark:text-secondary-400 leading-relaxed">{levelDescriptions[level]}</p>
                    </label>
                {/each}
            </div>
        </form>
    </div>

    <!-- Summary panel -->
    <div class="grid grid-cols-3 gap-4 mb-6">
        <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 p-4 text-center">
            <p class="text-2xl font-bold {data.summary.totalHard === data.summary.totalHardSatisfied ? 'text-green-600 dark:text-green-400' : 'text-red-600 dark:text-red-400'}">{data.summary.totalHardSatisfied}/{data.summary.totalHard}</p>
            <p class="text-xs text-secondary-500 dark:text-secondary-400 mt-1">Hard constraints</p>
        </div>
        <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 p-4 text-center">
            <p class="text-2xl font-bold text-amber-600 dark:text-amber-400">{data.summary.totalSoftSatisfied}/{data.summary.totalSoft}</p>
            <p class="text-xs text-secondary-500 dark:text-secondary-400 mt-1">Soft constraints</p>
        </div>
        <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 p-4 text-center">
            <p class="text-2xl font-bold text-secondary-600 dark:text-secondary-400">{data.summary.totalGradedSatisfied}/{data.summary.totalGraded}</p>
            <p class="text-xs text-secondary-500 dark:text-secondary-400 mt-1">Graded constraints</p>
        </div>
    </div>

    <!-- Production modules section -->
    {#if data.assessments.some(a => {
        const m = data.modules.find(mod => mod.id === a.moduleInstanceId);
        return m && m.epistemicCharacter === 'production';
    })}
        <div class="mb-6">
            <h2 class="text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-500 mb-3">Production Modules</h2>
            <div class="space-y-4">
                {#each data.assessments.filter(a => {
                    const m = data.modules.find(mod => mod.id === a.moduleInstanceId);
                    return m && m.epistemicCharacter === 'production';
                }) as assessment}
                    {@const moduleInstance = data.modules.find(m => m.id === assessment.moduleInstanceId)}
                    <div class="bg-white dark:bg-secondary-800 rounded-2xl border-2 border-teal-200 dark:border-teal-800 overflow-hidden">
                        <div class="px-5 py-4 border-b border-teal-100 dark:border-teal-800 flex items-center justify-between bg-teal-50/50 dark:bg-teal-900/20">
                            <div class="flex items-center gap-3">
                                <span class="font-medium text-secondary-900 dark:text-secondary-100">{assessment.moduleName}</span>
                                <span class="text-xs px-2 py-0.5 rounded bg-teal-100 dark:bg-teal-900/50 text-teal-800 dark:text-teal-200 font-semibold uppercase tracking-wider">Production</span>
                            </div>
                            <div class="flex items-center gap-2">
                                {#if assessment.overallPass}
                                    <Badge color="green" class="text-xs">All hard constraints met</Badge>
                                {:else}
                                    <Badge color="red" class="text-xs">{assessment.hardCount - assessment.hardSatisfied} hard failing</Badge>
                                {/if}
                            </div>
                        </div>
                        <div class="divide-y divide-secondary-100 dark:divide-secondary-700">
                            {#each assessment.results as result}
                                {@const icon = constraintIcon(result, data.domain.governanceLevel)}
                                <div class="px-5 py-3 flex items-start gap-3">
                                    <span class="text-lg font-bold mt-0.5 w-5 text-center {icon.color}">{icon.symbol}</span>
                                    <div class="flex-1 min-w-0">
                                        <div class="flex items-center gap-2 mb-0.5">
                                            <span class="text-sm text-secondary-800 dark:text-secondary-200">{result.constraint.description}</span>
                                            <Badge color={levelBadgeColor(result.constraint.level)} class="text-xs">{result.constraint.level}</Badge>
                                        </div>
                                        <p class="text-xs text-secondary-500 dark:text-secondary-400">{result.explanation}</p>
                                    </div>
                                </div>
                            {/each}
                        </div>
                    </div>
                {/each}
            </div>
        </div>
    {/if}

    <!-- All module assessments -->
    <h2 class="text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-500 mb-3">All Modules</h2>
    {#if data.assessments.length === 0}
        <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 p-8 text-center">
            <p class="text-secondary-400 dark:text-secondary-500">No installed modules to assess.</p>
        </div>
    {:else}
        <div class="space-y-4">
            {#each data.assessments as assessment}
                {@const moduleInstance = data.modules.find(m => m.id === assessment.moduleInstanceId)}
                {@const epDisplay = moduleInstance ? getEpistemicDisplay(moduleInstance.epistemicCharacter) : null}
                <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 overflow-hidden">
                    <!-- Module header -->
                    <div class="px-5 py-4 border-b border-secondary-100 dark:border-secondary-700 flex items-center justify-between">
                        <div class="flex items-center gap-3">
                            <span class="font-medium text-secondary-900 dark:text-secondary-100">{assessment.moduleName}</span>
                            {#if epDisplay}
                                <Badge color={epDisplay.badgeColor} class="text-xs">{epDisplay.label}</Badge>
                            {/if}
                            {#if moduleInstance && moduleInstance.definition.category !== 'business'}
                                <Badge color={moduleInstance.definition.category === 'generative' ? 'purple' : 'blue'} class="text-xs">{moduleInstance.definition.category}</Badge>
                            {/if}
                        </div>
                        <div class="flex items-center gap-2">
                            {#if assessment.overallPass}
                                <Badge color="green" class="text-xs">All hard constraints met</Badge>
                            {:else}
                                <Badge color="red" class="text-xs">{assessment.hardCount - assessment.hardSatisfied} hard constraint{assessment.hardCount - assessment.hardSatisfied !== 1 ? 's' : ''} failing</Badge>
                            {/if}
                        </div>
                    </div>
                    <!-- Constraint list -->
                    <div class="divide-y divide-secondary-100 dark:divide-secondary-700">
                        {#each assessment.results as result}
                            {@const icon = constraintIcon(result, data.domain.governanceLevel)}
                            <div class="px-5 py-3 flex items-start gap-3">
                                <span class="text-lg font-bold mt-0.5 w-5 text-center {icon.color}">{icon.symbol}</span>
                                <div class="flex-1 min-w-0">
                                    <div class="flex items-center gap-2 mb-0.5">
                                        <span class="text-sm text-secondary-800 dark:text-secondary-200">{result.constraint.description}</span>
                                        <Badge color={levelBadgeColor(result.constraint.level)} class="text-xs">{result.constraint.level}</Badge>
                                        <span class="text-xs text-secondary-400">{result.constraint.concern}</span>
                                    </div>
                                    <p class="text-xs text-secondary-500 dark:text-secondary-400">{result.explanation}</p>
                                </div>
                            </div>
                        {/each}
                        {#if assessment.results.length === 0}
                            <div class="px-5 py-3 text-sm text-secondary-400">No constraints defined for this module.</div>
                        {/if}
                    </div>
                </div>
            {/each}
        </div>
    {/if}
</div>
