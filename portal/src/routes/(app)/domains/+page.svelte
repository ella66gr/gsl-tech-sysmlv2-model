<script lang="ts">
    import { Badge, Button, Card } from 'flowbite-svelte';
    import { PlusOutline, BuildingOutline } from 'flowbite-svelte-icons';
    import type { PageData } from './$types';

    let { data }: { data: PageData } = $props();

    function statusColor(status: string): 'green' | 'yellow' | 'red' | 'gray' {
        switch (status) {
            case 'active': return 'green';
            case 'setup': return 'yellow';
            case 'suspended': return 'red';
            default: return 'gray';
        }
    }

    function roleColor(role: string): 'purple' | 'blue' | 'gray' {
        switch (role) {
            case 'super_admin': return 'purple';
            case 'admin': return 'blue';
            default: return 'gray';
        }
    }

    function formatDate(iso: string) {
        return new Date(iso).toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' });
    }
</script>

<svelte:head>
    <title>Domains — Ontara Portal</title>
</svelte:head>

<div class="p-6 max-w-5xl mx-auto">
    <div class="flex items-center justify-between mb-8">
        <div>
            <h1 class="text-2xl font-semibold text-secondary-900 dark:text-secondary-100">Your Domains</h1>
            <p class="text-sm text-secondary-500 dark:text-secondary-400 mt-1">Manage your service domains</p>
        </div>
        <Button href="/domains/new" color="primary">
            <PlusOutline class="w-4 h-4 me-2" />
            New Domain
        </Button>
    </div>

    {#if data.domains.length === 0}
        <div class="flex flex-col items-center justify-center py-20 text-center">
            <div class="w-16 h-16 rounded-2xl bg-primary-100 dark:bg-primary-900/30 flex items-center justify-center mb-4">
                <BuildingOutline class="w-8 h-8 text-primary-500" />
            </div>
            <h2 class="text-lg font-semibold text-secondary-900 dark:text-secondary-100 mb-2">Create your first domain</h2>
            <p class="text-secondary-500 dark:text-secondary-400 max-w-sm mb-6">
                A domain represents your business or organisation. Each domain gets its own dashboard, modules, and settings.
            </p>
            <Button href="/domains/new" color="primary" size="lg">
                <PlusOutline class="w-4 h-4 me-2" />
                Create Domain
            </Button>
        </div>
    {:else}
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            {#each data.domains as domain}
                <a
                    href="/domains/{domain.slug}"
                    class="block bg-white dark:bg-secondary-800 border border-secondary-200 dark:border-secondary-700 rounded-2xl p-5 hover:border-primary-300 dark:hover:border-primary-600 hover:shadow-sm transition-all group"
                >
                    <div class="flex items-start justify-between mb-3">
                        <div class="w-10 h-10 rounded-xl bg-primary-100 dark:bg-primary-900/30 flex items-center justify-center">
                            <BuildingOutline class="w-5 h-5 text-primary-600 dark:text-primary-400" />
                        </div>
                        <Badge color={statusColor(domain.status)} class="capitalize">{domain.status}</Badge>
                    </div>
                    <h3 class="font-semibold text-secondary-900 dark:text-secondary-100 group-hover:text-primary-700 dark:group-hover:text-primary-300 transition-colors">{domain.name}</h3>
                    {#if domain.businessType}
                        <p class="text-sm text-secondary-500 dark:text-secondary-400 mt-0.5 truncate">{domain.businessType}</p>
                    {/if}
                    <div class="flex items-center justify-between mt-4 pt-4 border-t border-secondary-100 dark:border-secondary-700">
                        <Badge color={roleColor(domain.role)} class="text-xs capitalize">{domain.role.replace('_', ' ')}</Badge>
                        <span class="text-xs text-secondary-400">{formatDate(domain.createdAt)}</span>
                    </div>
                </a>
            {/each}
        </div>
    {/if}
</div>
