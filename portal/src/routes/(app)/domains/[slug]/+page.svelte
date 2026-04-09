<script lang="ts">
    import { Badge, Button } from 'flowbite-svelte';
    import {
        TagOutline, UsersOutline, CalendarMonthOutline, UserSettingsOutline,
        ChartOutline, ShieldCheckOutline, ChartMixedOutline,
        GridPlusOutline, UsersOutline as UsersIcon, CalendarMonthOutline as CalIcon,
        ArrowsRepeatOutline, AdjustmentsHorizontalOutline, PlayOutline
    } from 'flowbite-svelte-icons';
    import { getOperationalStateDisplay, getPrimaryAction } from '$lib/modules/lifecycle.js';
    import { getConcernCoverage } from '$lib/modules/connections.js';
    import { CONCERN_META } from '$lib/context/schemas.js';
    import { getEpistemicDisplay } from '$lib/modules/epistemic.js';
    import { enhance } from '$app/forms';
    import type { PageData, ActionData } from './$types';
    import type { ModuleInstanceWithDefinition, ConcernCoverage } from '$lib/types';

    let { data, form }: { data: PageData; form: ActionData } = $props();

    let concernCoverage = $derived(getConcernCoverage(data.modules));

    const coverageAccent: Record<string, string> = {
        ServiceConcept: 'bg-teal-500',
        ActivityModel: 'bg-cyan-500',
        ResourcePlanning: 'bg-emerald-500',
        FinancialPlanning: 'bg-amber-500',
        GovernanceMapping: 'bg-rose-400',
        StakeholderModel: 'bg-violet-400'
    };

    const iconMap: Record<string, any> = {
        TagOutline, UsersOutline, CalendarMonthOutline, UserSettingsOutline,
        ChartOutline, ShieldCheckOutline, ChartMixedOutline,
        ArrowsRepeatOutline, AdjustmentsHorizontalOutline
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
            <div class="flex items-center gap-2">
                <Badge color="yellow" class="capitalize text-sm px-3 py-1">{data.domain.status}</Badge>
                <Badge color="dark" class="text-xs px-2 py-0.5">
                    {data.domain.simulationFidelity === 'realistic' ? '⚡ Realistic' : '○ Simplified'}
                </Badge>
            </div>
        </div>
        {#if data.domain.description}
            <p class="mt-3 text-secondary-600 dark:text-secondary-400 max-w-2xl">{data.domain.description}</p>
        {/if}
    </div>

    <!-- BMM Concern Coverage Bar -->
    {#if data.modules.length > 0}
        <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 p-5 mb-6">
            <div class="flex items-center justify-between mb-3">
                <h2 class="text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-500">Business Concern Coverage</h2>
                <a href="/domains/{data.domain.slug}/context" class="text-xs text-primary-600 dark:text-primary-400 hover:underline">Edit context →</a>
            </div>
            <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-2">
                {#each concernCoverage as cov}
                    <a
                        href={cov.covered ? `/domains/${data.domain.slug}/context#${cov.concern}` : `/domains/${data.domain.slug}/catalogue`}
                        class="group flex flex-col items-center p-3 rounded-xl border transition-colors {cov.covered
                            ? 'border-secondary-200 dark:border-secondary-700 hover:border-primary-300 dark:hover:border-primary-600'
                            : 'border-dashed border-secondary-300 dark:border-secondary-600 hover:border-primary-400 dark:hover:border-primary-500 bg-secondary-50 dark:bg-secondary-900/20'
                        }"
                    >
                        <div class="w-3 h-3 rounded-full mb-2 {cov.covered ? coverageAccent[cov.concern] : 'bg-secondary-200 dark:bg-secondary-700'}"></div>
                        <span class="text-xs font-medium text-center leading-tight {cov.covered ? 'text-secondary-700 dark:text-secondary-300' : 'text-secondary-400 dark:text-secondary-500'}">
                            {cov.label}
                        </span>
                        {#if cov.covered}
                            <span class="text-xs text-secondary-400 mt-0.5">{cov.modules.length}</span>
                        {:else}
                            <span class="text-xs text-secondary-300 dark:text-secondary-600 mt-0.5 group-hover:text-primary-400">+</span>
                        {/if}
                    </a>
                {/each}
            </div>
        </div>
    {/if}

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
                        {@const epDisplay = getEpistemicDisplay(mod.epistemicCharacter)}
                        <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 border-l-4 {stateDisplay.borderClass} overflow-hidden hover:shadow-sm transition-shadow {epDisplay.bgTint}">
                            <a href="/domains/{data.domain.slug}/modules/{mod.id}" class="block p-4">
                                <div class="flex items-start justify-between mb-2">
                                    <div class="flex items-center gap-2.5">
                                        <div class="w-8 h-8 rounded-lg bg-primary-100 dark:bg-primary-900/30 flex items-center justify-center flex-shrink-0">
                                            {#if Icon}
                                                <Icon class="w-4 h-4 text-primary-600 dark:text-primary-400" />
                                            {/if}
                                        </div>
                                        <div>
                                            <span class="font-medium text-secondary-900 dark:text-secondary-100 text-sm">{mod.displayName || mod.definition.name}</span>
                                            {#if mod.epistemicCharacter !== 'production'}
                                                <Badge color={epDisplay.badgeColor} class="text-xs ml-1.5">{epDisplay.label}</Badge>
                                            {/if}
                                        </div>
                                    </div>
                                    <Badge color={stateDisplay.badgeColor} class="text-xs">{stateDisplay.label}</Badge>
                                </div>
                                <p class="text-xs text-secondary-500 dark:text-secondary-400 truncate">{mod.definition.description}</p>
                            </a>
                            <div class="px-4 pb-3 flex items-center justify-between border-t border-secondary-100 dark:border-secondary-700 pt-3">
                                <form method="POST" action="?/transition" use:enhance>
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

        <!-- Sidebar -->
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
                    <a href="/domains/{data.domain.slug}/context" class="block text-sm text-secondary-600 dark:text-secondary-400 hover:text-primary-600 dark:hover:text-primary-400 py-1 transition-colors">Domain context →</a>
                    <a href="/domains/{data.domain.slug}/catalogue" class="block text-sm text-secondary-600 dark:text-secondary-400 hover:text-primary-600 dark:hover:text-primary-400 py-1 transition-colors">Module catalogue →</a>
                    <a href="/domains/{data.domain.slug}/simulations" class="block text-sm text-secondary-600 dark:text-secondary-400 hover:text-primary-600 dark:hover:text-primary-400 py-1 transition-colors">Simulations →</a>
                    <a href="/domains/{data.domain.slug}/settings" class="block text-sm text-secondary-600 dark:text-secondary-400 hover:text-primary-600 dark:hover:text-primary-400 py-1 transition-colors">Domain settings →</a>
                    <a href="/domains" class="block text-sm text-secondary-600 dark:text-secondary-400 hover:text-primary-600 dark:hover:text-primary-400 py-1 transition-colors">All domains →</a>
                </div>
            </div>

            <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 p-5">
                <div class="flex items-center justify-between mb-3">
                    <h3 class="text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-500">Simulations</h3>
                    <a href="/domains/{data.domain.slug}/simulations" class="text-xs text-primary-600 dark:text-primary-400 hover:underline">View all →</a>
                </div>
                {#if data.runs.length === 0}
                    <p class="text-sm text-secondary-400">No completed runs yet.</p>
                {:else}
                    <div class="space-y-2">
                        <div class="flex items-center justify-between">
                            <span class="text-sm text-secondary-500 dark:text-secondary-400">Completed runs</span>
                            <span class="text-sm font-medium text-secondary-900 dark:text-secondary-100">{data.runs.length}</span>
                        </div>
                        {@const totalEvents = data.runs.reduce((sum, r) => sum + r.eventCount, 0)}
                        <div class="flex items-center justify-between">
                            <span class="text-sm text-secondary-500 dark:text-secondary-400">Total events</span>
                            <span class="text-sm font-medium text-secondary-900 dark:text-secondary-100">{totalEvents.toLocaleString()}</span>
                        </div>
                    </div>
                {/if}
            </div>
        </div>
    </div>
</div>

<!-- Impact warning modal -->
{#if form?.confirmNeeded}
    <!-- Backdrop -->
    <div class="fixed inset-0 bg-black/40 z-40"></div>

    <!-- Modal -->
    <div class="fixed inset-0 z-50 flex items-center justify-center p-4">
        <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 shadow-xl max-w-md w-full">
            <div class="p-5">
                <div class="flex items-start gap-3 mb-4">
                    <div class="w-10 h-10 rounded-xl bg-yellow-100 dark:bg-yellow-900/30 flex items-center justify-center flex-shrink-0">
                        <svg class="w-5 h-5 text-yellow-600 dark:text-yellow-400" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.07 16.5c-.77.833.192 2.5 1.732 2.5z" /></svg>
                    </div>
                    <div>
                        <h2 class="text-lg font-semibold text-secondary-900 dark:text-secondary-100">Impact Warning</h2>
                        <p class="text-sm text-secondary-500 dark:text-secondary-400 mt-1">
                            Changing <strong>{form.moduleName}</strong> to <strong>{form.targetState}</strong> may affect connected modules.
                        </p>
                    </div>
                </div>

                <div class="space-y-2 mb-5">
                    {#each form.affectedModules as aff}
                        <div class="flex items-center justify-between p-3 rounded-lg bg-yellow-50 dark:bg-yellow-900/10 border border-yellow-200 dark:border-yellow-800">
                            <span class="text-sm font-medium text-secondary-800 dark:text-secondary-200">{aff.name}</span>
                            <div class="flex items-center gap-2">
                                <Badge color="yellow" class="text-xs capitalize">{aff.currentState}</Badge>
                                <div class="flex gap-1">
                                    {#each aff.sharedConcerns as c}
                                        <span class="text-xs px-1.5 py-0.5 rounded bg-yellow-100 dark:bg-yellow-800 text-yellow-700 dark:text-yellow-300">{c}</span>
                                    {/each}
                                </div>
                            </div>
                        </div>
                    {/each}
                </div>

                <div class="flex gap-3 pt-3 border-t border-secondary-100 dark:border-secondary-700">
                    <form method="POST" action="?/transition" use:enhance class="flex-1">
                        <input type="hidden" name="moduleId" value={form.moduleId} />
                        <input type="hidden" name="targetState" value={form.targetState} />
                        <input type="hidden" name="confirmed" value="true" />
                        <Button type="submit" color="yellow" class="w-full">Proceed Anyway</Button>
                    </form>
                    <Button href="/domains/{data.domain.slug}" color="alternative">Cancel</Button>
                </div>
            </div>
        </div>
    </div>
{/if}
