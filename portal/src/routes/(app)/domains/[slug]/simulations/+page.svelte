<script lang="ts">
    import { Badge, Button, Input, Label, Select, Alert } from 'flowbite-svelte';
    import { PlayOutline } from 'flowbite-svelte-icons';
    import type { PageData, ActionData } from './$types';

    let { data, form }: { data: PageData; form: ActionData } = $props();

    let showCreateForm = $state(false);

    function formatDateTime(iso: string) {
        return new Date(iso).toLocaleDateString('en-GB', {
            day: 'numeric', month: 'short', year: 'numeric',
            hour: '2-digit', minute: '2-digit'
        });
    }

    function statusColor(status: string): 'green' | 'yellow' | 'red' | 'blue' {
        switch (status) {
            case 'completed': return 'green';
            case 'running': return 'blue';
            case 'pending': return 'yellow';
            case 'cancelled': return 'red';
            default: return 'yellow';
        }
    }

    function fidelityLabel(f: string): string {
        return f === 'realistic' ? '⚡ Realistic' : '○ Simplified';
    }
</script>

<svelte:head>
    <title>Simulations — {data.domain.name} — Ontara Portal</title>
</svelte:head>

<div class="p-6 max-w-4xl mx-auto">
    <div class="mb-6">
        <a href="/domains/{data.domain.slug}" class="text-sm text-primary-600 dark:text-primary-400 hover:underline">← Back to dashboard</a>
        <div class="flex items-center justify-between mt-3">
            <div>
                <h1 class="text-2xl font-semibold text-secondary-900 dark:text-secondary-100">Simulations</h1>
                <p class="text-sm text-secondary-500 dark:text-secondary-400 mt-1">
                    Run simulations to compare business module configurations.
                    Current fidelity: <span class="font-medium">{fidelityLabel(data.domain.simulationFidelity)}</span>
                </p>
            </div>
            <Button
                color="primary"
                size="sm"
                onclick={() => (showCreateForm = !showCreateForm)}
                disabled={data.generativeModules.length === 0 || data.businessModules.length === 0}
            >
                <PlayOutline class="w-4 h-4 mr-1.5" />
                New Simulation Run
            </Button>
        </div>
    </div>

    <!-- Alerts -->
    {#if form?.success}
        <Alert color="green" class="mb-6">
            Simulation completed — {form.eventCount} events generated.
        </Alert>
    {/if}
    {#if form?.error}
        <Alert color="red" class="mb-6">{form.error}</Alert>
    {/if}

    <!-- Prerequisites warning -->
    {#if data.generativeModules.length === 0 || data.businessModules.length === 0}
        <Alert color="yellow" class="mb-6">
            {#if data.generativeModules.length === 0}
                No generative modules installed. <a href="/domains/{data.domain.slug}/catalogue" class="underline">Install a generator</a> from the catalogue to run simulations.
            {:else}
                No business modules installed. <a href="/domains/{data.domain.slug}/catalogue" class="underline">Install business modules</a> to use as simulation targets.
            {/if}
        </Alert>
    {/if}

    <!-- Create form -->
    {#if showCreateForm}
        <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 p-6 mb-6">
            <h2 class="font-semibold text-secondary-900 dark:text-secondary-100 mb-5">New Simulation Run</h2>
            <form method="POST" action="?/createRun" class="space-y-5">
                <div>
                    <Label for="name" class="mb-2 text-secondary-700 dark:text-secondary-300">Run name</Label>
                    <Input
                        id="name"
                        name="name"
                        type="text"
                        placeholder="e.g. Baseline 7-day, High traffic test"
                        required
                    />
                </div>

                <div>
                    <Label for="generatorModuleId" class="mb-2 text-secondary-700 dark:text-secondary-300">Generator module</Label>
                    <Select id="generatorModuleId" name="generatorModuleId" required>
                        <option value="">Select a generator...</option>
                        {#each data.generativeModules as gen}
                            <option value={gen.id}>{gen.displayName || gen.definition.name}</option>
                        {/each}
                    </Select>
                    <p class="text-xs text-secondary-400 mt-1">The generative module that will produce events for this run.</p>
                </div>

                <div>
                    <Label class="mb-2 text-secondary-700 dark:text-secondary-300">Target business modules</Label>
                    <p class="text-xs text-secondary-400 mb-2">Select which business modules receive simulated events.</p>
                    <div class="space-y-2 max-h-48 overflow-y-auto p-3 rounded-xl border border-secondary-200 dark:border-secondary-700 bg-secondary-50 dark:bg-secondary-900/30">
                        {#each data.businessModules as bm}
                            <label class="flex items-center gap-2.5 py-1 cursor-pointer">
                                <input
                                    type="checkbox"
                                    name="targetModuleIds"
                                    value={bm.id}
                                    class="rounded border-secondary-300 dark:border-secondary-600 text-primary-600 focus:ring-primary-500"
                                />
                                <span class="text-sm text-secondary-700 dark:text-secondary-300">{bm.displayName || bm.definition.name}</span>
                                <Badge color="blue" class="text-xs capitalize ml-auto">{bm.operationalState}</Badge>
                            </label>
                        {/each}
                    </div>
                </div>

                <div>
                    <Label for="durationDays" class="mb-2 text-secondary-700 dark:text-secondary-300">Simulation duration</Label>
                    <Select id="durationDays" name="durationDays" required>
                        <option value="1">1 day</option>
                        <option value="7" selected>7 days</option>
                        <option value="14">14 days</option>
                        <option value="30">30 days</option>
                    </Select>
                    <p class="text-xs text-secondary-400 mt-1">
                        Events will be generated for this simulated period at <span class="font-medium">{fidelityLabel(data.domain.simulationFidelity)}</span> fidelity.
                        Change fidelity in <a href="/domains/{data.domain.slug}/settings" class="text-primary-600 dark:text-primary-400 hover:underline">domain settings</a>.
                    </p>
                </div>

                <div class="flex gap-3 pt-2">
                    <Button type="submit" color="primary">
                        <PlayOutline class="w-4 h-4 mr-1.5" />
                        Start Simulation
                    </Button>
                    <Button color="alternative" onclick={() => (showCreateForm = false)}>Cancel</Button>
                </div>
            </form>
        </div>
    {/if}

    <!-- Runs list -->
    {#if data.runs.length === 0 && !showCreateForm}
        <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 p-8 text-center">
            <div class="w-12 h-12 rounded-full bg-secondary-100 dark:bg-secondary-700 flex items-center justify-center mx-auto mb-4">
                <PlayOutline class="w-6 h-6 text-secondary-400" />
            </div>
            <h2 class="font-semibold text-secondary-900 dark:text-secondary-100 mb-2">No simulation runs yet</h2>
            <p class="text-sm text-secondary-500 dark:text-secondary-400 max-w-md mx-auto">
                Create a simulation run to generate synthetic business events and compare how different module configurations perform.
            </p>
        </div>
    {:else if data.runs.length > 0}
        <div class="space-y-3">
            {#each data.runs as run}
                <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 p-5 hover:shadow-sm transition-shadow">
                    <div class="flex items-start justify-between mb-3">
                        <div>
                            <h3 class="font-medium text-secondary-900 dark:text-secondary-100">{run.name}</h3>
                            <p class="text-xs text-secondary-400 mt-0.5">
                                Created {formatDateTime(run.createdAt)}
                                {#if run.completedAt}
                                    · Completed {formatDateTime(run.completedAt)}
                                {/if}
                            </p>
                        </div>
                        <div class="flex items-center gap-2">
                            <Badge color={statusColor(run.status)} class="text-xs capitalize">{run.status}</Badge>
                            <Badge color="gray" class="text-xs">{fidelityLabel(run.fidelity)}</Badge>
                        </div>
                    </div>
                    <div class="flex items-center gap-4 text-sm text-secondary-600 dark:text-secondary-400">
                        <span>{run.eventCount.toLocaleString()} events</span>
                        <span>·</span>
                        <span>{run.targetModuleIds.length} target module{run.targetModuleIds.length !== 1 ? 's' : ''}</span>
                        <span>·</span>
                        <span>{run.config?.durationDays ?? '?'} day{(run.config?.durationDays ?? 0) !== 1 ? 's' : ''} simulated</span>
                    </div>

                    <!-- Target module names for completed runs -->
                    {#if run.status === 'completed' && run.eventCount > 0}
                        {@const targetNames = run.targetModuleIds.map(tid => {
                            const mod = data.modules.find(m => m.id === tid);
                            return mod ? (mod.displayName || mod.definition.name) : tid.slice(0, 8);
                        })}
                        <div class="mt-3 pt-3 border-t border-secondary-100 dark:border-secondary-700">
                            <div class="text-xs">
                                <span class="text-secondary-400">Targets:</span>
                                <span class="text-secondary-700 dark:text-secondary-300 ml-1">{targetNames.join(', ')}</span>
                            </div>
                        </div>
                    {/if}
                </div>
            {/each}
        </div>
    {/if}
</div>
