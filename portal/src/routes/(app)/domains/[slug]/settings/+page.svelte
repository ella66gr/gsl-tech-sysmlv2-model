<script lang="ts">
    import { Alert, Badge, Button, Helper, Input, Label, Textarea } from 'flowbite-svelte';
    import { TrashBinOutline } from 'flowbite-svelte-icons';
    import type { PageData, ActionData } from './$types';

    let { data, form }: { data: PageData; form: ActionData } = $props();
    const f = $derived(form as any);

    let confirmDeleteId = $state<string | null>(null);

    function formatDateTime(iso: string) {
        return new Date(iso).toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' });
    }

    function roleColor(role: string): 'purple' | 'blue' | 'gray' {
        if (role === 'super_admin') return 'purple';
        if (role === 'admin') return 'blue';
        return 'gray';
    }

    function formatDate(iso: string) {
        return new Date(iso).toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' });
    }
</script>

<svelte:head>
    <title>Settings — {data.domain.name} — Ontara Portal</title>
</svelte:head>

<div class="p-6 max-w-3xl mx-auto">
    <div class="mb-8">
        <a href="/domains/{data.domain.slug}" class="text-sm text-primary-600 dark:text-primary-400 hover:underline">← Back to dashboard</a>
        <h1 class="text-2xl font-semibold text-secondary-900 dark:text-secondary-100 mt-3">
            {data.isSuperAdmin ? 'Domain Settings' : 'Domain Information'}
        </h1>
    </div>

    {#if f?.success}
        <Alert color="green" class="mb-6">Settings saved successfully.</Alert>
    {/if}
    {#if f?.errors?.form}
        <Alert color="red" class="mb-6">{f.errors.form}</Alert>
    {/if}

    <!-- Domain details -->
    <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 p-6 mb-6">
        <h2 class="font-semibold text-secondary-900 dark:text-secondary-100 mb-5">Details</h2>
        <form method="POST" action="?/update" class="space-y-5">
            <div>
                <Label for="name" class="mb-2 text-secondary-700 dark:text-secondary-300">Domain name</Label>
                <Input
                    id="name"
                    name="name"
                    type="text"
                    value={data.domain.name}
                    disabled={!data.isSuperAdmin}
                    color={f?.errors?.name ? 'red' : 'default'}
                />
                {#if f?.errors?.name}
                    <Helper color="red" class="mt-1">{f.errors.name}</Helper>
                {/if}
            </div>
            <div>
                <Label class="mb-2 text-secondary-700 dark:text-secondary-300">URL slug</Label>
                <Input value={data.domain.slug} disabled />
                <Helper class="mt-1 text-secondary-400">Slug cannot be changed after creation.</Helper>
            </div>
            <div>
                <Label for="businessType" class="mb-2 text-secondary-700 dark:text-secondary-300">Business type</Label>
                <Input
                    id="businessType"
                    name="businessType"
                    type="text"
                    value={data.domain.businessType ?? ''}
                    placeholder="e.g. Jewellery retail, Healthcare clinic"
                    disabled={!data.isSuperAdmin}
                />
            </div>
            <div>
                <Label for="description" class="mb-2 text-secondary-700 dark:text-secondary-300">Description</Label>
                <Textarea
                    id="description"
                    name="description"
                    value={data.domain.description ?? ''}
                    placeholder="A brief description of this domain..."
                    rows={3}
                    disabled={!data.isSuperAdmin}
                />
            </div>
            {#if data.isSuperAdmin}
                <Button type="submit" color="primary">Save Changes</Button>
            {/if}
        </form>
    </div>

    <!-- Members -->
    <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 p-6">
        <h2 class="font-semibold text-secondary-900 dark:text-secondary-100 mb-5">Members ({data.members.length})</h2>
        <div class="divide-y divide-secondary-100 dark:divide-secondary-700">
            {#each data.members as member}
                <div class="flex items-center justify-between py-3">
                    <div>
                        <p class="text-sm font-medium text-secondary-900 dark:text-secondary-100">{member.displayName}</p>
                        <p class="text-xs text-secondary-400">{member.email}</p>
                    </div>
                    <div class="flex items-center gap-3">
                        <Badge color={roleColor(member.role)} class="capitalize text-xs">{member.role.replace('_', ' ')}</Badge>
                        <span class="text-xs text-secondary-400 hidden sm:block">Joined {formatDate(member.createdAt)}</span>
                    </div>
                </div>
            {/each}
        </div>
    </div>

    <!-- Trashed modules -->
    {#if data.trashedModules.length > 0}
        <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 p-6">
            <div class="flex items-center gap-2 mb-5">
                <h2 class="font-semibold text-secondary-900 dark:text-secondary-100">Trashed Modules</h2>
                <Badge color="red">{data.trashedModules.length}</Badge>
            </div>

            {#if f?.restoreSuccess}
                <Alert color="green" class="mb-4">Module restored successfully.</Alert>
            {/if}
            {#if f?.deleteSuccess}
                <Alert color="green" class="mb-4">Module permanently deleted.</Alert>
            {/if}
            {#if f?.trashError}
                <Alert color="red" class="mb-4">{f.trashError}</Alert>
            {/if}

            <div class="divide-y divide-secondary-100 dark:divide-secondary-700">
                {#each data.trashedModules as mod}
                    <div class="py-4">
                        <div class="flex items-start justify-between">
                            <div>
                                <p class="text-sm font-medium text-secondary-900 dark:text-secondary-100">{mod.displayName || mod.definition.name}</p>
                                <p class="text-xs text-secondary-400 mt-0.5">{mod.definition.name} · Trashed {formatDateTime(mod.updatedAt)}</p>
                            </div>
                            <div class="flex items-center gap-2 flex-shrink-0">
                                <form method="POST" action="?/restore">
                                    <input type="hidden" name="moduleId" value={mod.id} />
                                    <button type="submit" class="text-xs px-3 py-1.5 rounded-lg bg-secondary-100 dark:bg-secondary-700 hover:bg-secondary-200 dark:hover:bg-secondary-600 text-secondary-700 dark:text-secondary-300 transition-colors">
                                        Restore
                                    </button>
                                </form>
                                {#if confirmDeleteId === mod.id}
                                    <div class="flex items-center gap-1.5">
                                        <form method="POST" action="?/permanentDelete">
                                            <input type="hidden" name="moduleId" value={mod.id} />
                                            <button type="submit" class="text-xs px-3 py-1.5 rounded-lg bg-red-600 hover:bg-red-700 text-white transition-colors">Confirm delete</button>
                                        </form>
                                        <button onclick={() => (confirmDeleteId = null)} class="text-xs text-secondary-400 hover:text-secondary-600 px-2">Cancel</button>
                                    </div>
                                {:else}
                                    <button
                                        onclick={() => (confirmDeleteId = mod.id)}
                                        class="text-xs px-3 py-1.5 rounded-lg border border-red-200 dark:border-red-900 text-red-600 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20 transition-colors"
                                    >
                                        Delete permanently
                                    </button>
                                {/if}
                            </div>
                        </div>
                    </div>
                {/each}
            </div>
        </div>
    {/if}
</div>
