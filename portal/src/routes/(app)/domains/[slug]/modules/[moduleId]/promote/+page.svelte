<script lang="ts">
    import { Badge, Button } from 'flowbite-svelte';
    import { ShieldCheckOutline, ArrowUpOutline } from 'flowbite-svelte-icons';
    import { getEpistemicDisplay } from '$lib/modules/epistemic.js';
    import { enhance } from '$app/forms';
    import type { PageData, ActionData } from './$types';

    let { data, form }: { data: PageData; form: ActionData } = $props();

    const epDisplay = $derived(getEpistemicDisplay(data.instance.epistemicCharacter));

    let currentStep = $state(1);
</script>

<svelte:head>
    <title>Promote {data.instance.displayName || data.instance.definition.name} — Ontara Portal</title>
</svelte:head>

<div class="p-6 max-w-3xl mx-auto">
    <!-- Header -->
    <div class="flex items-center gap-3 mb-6">
        <a href="/domains/{data.domain.slug}/modules/{data.instance.id}" class="text-secondary-400 hover:text-secondary-600 dark:hover:text-secondary-300 transition-colors text-sm">
            ← Back to module
        </a>
    </div>

    <div class="flex items-center gap-3 mb-8">
        <div class="w-10 h-10 rounded-xl bg-teal-100 dark:bg-teal-900/30 flex items-center justify-center">
            <ArrowUpOutline class="w-5 h-5 text-teal-600 dark:text-teal-400" />
        </div>
        <div>
            <h1 class="text-2xl font-semibold text-secondary-900 dark:text-secondary-100">Promote to Production</h1>
            <p class="text-secondary-500 dark:text-secondary-400 text-sm">{data.instance.displayName || data.instance.definition.name}</p>
        </div>
    </div>

    <!-- Step indicators -->
    <div class="flex items-center gap-2 mb-8">
        {#each [1, 2, 3] as step}
            <div class="flex items-center gap-2">
                <div class="w-8 h-8 rounded-full flex items-center justify-center text-sm font-medium {currentStep >= step ? 'bg-primary-600 text-white' : 'bg-secondary-200 dark:bg-secondary-700 text-secondary-500'}">
                    {step}
                </div>
                <span class="text-xs {currentStep >= step ? 'font-medium text-secondary-700 dark:text-secondary-300' : 'text-secondary-500 dark:text-secondary-400'}">
                    {step === 1 ? 'Readiness' : step === 2 ? 'What changes' : 'Confirm'}
                </span>
            </div>
            {#if step < 3}
                <div class="flex-1 h-px bg-secondary-200 dark:bg-secondary-700"></div>
            {/if}
        {/each}
    </div>

    {#if form?.error}
        <div class="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-xl p-4 mb-6">
            <p class="text-sm text-red-800 dark:text-red-200">{form.error}</p>
        </div>
    {/if}

    <!-- Step 1: Readiness Assessment -->
    {#if currentStep === 1}
        <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 overflow-hidden mb-6">
            <div class="px-5 py-4 border-b border-secondary-100 dark:border-secondary-700">
                <h2 class="font-semibold text-secondary-900 dark:text-secondary-100">Prerequisite Check</h2>
                <p class="text-xs text-secondary-500 dark:text-secondary-400 mt-1">All blocking prerequisites must pass before promotion can proceed.</p>
            </div>
            <div class="divide-y divide-secondary-100 dark:divide-secondary-700">
                {#each data.readiness.prerequisites as prereq}
                    <div class="px-5 py-3 flex items-start gap-3">
                        {#if prereq.passed}
                            <span class="text-lg font-bold text-green-600 dark:text-green-400 w-5 text-center mt-0.5">✓</span>
                        {:else if prereq.blocking}
                            <span class="text-lg font-bold text-red-600 dark:text-red-400 w-5 text-center mt-0.5">✗</span>
                        {:else}
                            <span class="text-lg font-bold text-amber-500 dark:text-amber-400 w-5 text-center mt-0.5">!</span>
                        {/if}
                        <div class="flex-1">
                            <div class="flex items-center gap-2">
                                <span class="text-sm font-medium text-secondary-800 dark:text-secondary-200">{prereq.label}</span>
                                {#if !prereq.blocking}
                                    <Badge color="yellow" class="text-xs">Warning</Badge>
                                {/if}
                            </div>
                            <p class="text-xs text-secondary-500 dark:text-secondary-400 mt-0.5">{prereq.explanation}</p>
                        </div>
                    </div>
                {/each}
            </div>
        </div>

        <div class="flex justify-end gap-3">
            <Button href="/domains/{data.domain.slug}/modules/{data.instance.id}" color="alternative">Cancel</Button>
            {#if data.readiness.canPromote}
                <Button color="primary" onclick={() => currentStep = 2}>Continue →</Button>
            {:else}
                <Button color="primary" disabled class="opacity-50 cursor-not-allowed">Cannot proceed — prerequisites not met</Button>
            {/if}
        </div>
    {/if}

    <!-- Step 2: What Changes -->
    {#if currentStep === 2}
        <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 p-5 mb-6 space-y-4">
            <h2 class="font-semibold text-secondary-900 dark:text-secondary-100">What will change</h2>

            <div class="space-y-3">
                <div class="flex items-start gap-3 p-3 rounded-lg bg-secondary-50 dark:bg-secondary-900/30">
                    <span class="text-primary-600 dark:text-primary-400 font-bold text-lg">→</span>
                    <div>
                        <p class="text-sm font-medium text-secondary-800 dark:text-secondary-200">Epistemic character: <Badge color={epDisplay.badgeColor} class="text-xs">{epDisplay.label}</Badge> → <Badge color="teal" class="text-xs">Production</Badge></p>
                        <p class="text-xs text-secondary-500 dark:text-secondary-400 mt-1">This module's outputs will represent real business activity.</p>
                    </div>
                </div>

                <div class="flex items-start gap-3 p-3 rounded-lg bg-secondary-50 dark:bg-secondary-900/30">
                    <span class="text-primary-600 dark:text-primary-400 font-bold text-lg">→</span>
                    <div>
                        <p class="text-sm font-medium text-secondary-800 dark:text-secondary-200">Governance constraints become binding</p>
                        <p class="text-xs text-secondary-500 dark:text-secondary-400 mt-1">Hard constraints must remain satisfied for this module to stay in production.</p>
                    </div>
                </div>

                <div class="flex items-start gap-3 p-3 rounded-lg bg-secondary-50 dark:bg-secondary-900/30">
                    <span class="text-primary-600 dark:text-primary-400 font-bold text-lg">→</span>
                    <div>
                        <p class="text-sm font-medium text-secondary-800 dark:text-secondary-200">Demotion is available</p>
                        <p class="text-xs text-secondary-500 dark:text-secondary-400 mt-1">You can demote back to Hypothesis if needed.</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="flex justify-between">
            <Button color="alternative" onclick={() => currentStep = 1}>← Back</Button>
            <Button color="primary" onclick={() => currentStep = 3}>Continue →</Button>
        </div>
    {/if}

    <!-- Step 3: Confirm -->
    {#if currentStep === 3}
        <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 p-6 mb-6 text-center">
            <div class="w-16 h-16 rounded-2xl bg-teal-100 dark:bg-teal-900/30 flex items-center justify-center mx-auto mb-4">
                <ArrowUpOutline class="w-8 h-8 text-teal-600 dark:text-teal-400" />
            </div>
            <h2 class="text-lg font-semibold text-secondary-900 dark:text-secondary-100 mb-2">Ready to promote</h2>
            <p class="text-sm text-secondary-500 dark:text-secondary-400 mb-6">
                <strong>{data.instance.displayName || data.instance.definition.name}</strong> will be promoted from
                <Badge color={epDisplay.badgeColor} class="text-xs">{epDisplay.label}</Badge> to
                <Badge color="teal" class="text-xs">Production</Badge>.
            </p>

            <div class="flex justify-center gap-3">
                <Button color="alternative" onclick={() => currentStep = 2}>← Back</Button>
                <form method="POST" action="?/promote" use:enhance>
                    <Button type="submit" color="primary" class="bg-teal-600 hover:bg-teal-700">
                        Promote to Production
                    </Button>
                </form>
            </div>
        </div>
    {/if}
</div>
