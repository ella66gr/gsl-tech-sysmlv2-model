<script lang="ts">
    import type { PageData } from './$types';

    let { data }: { data: PageData } = $props();

    function formatDate(iso: string | null): string {
        if (!iso) return '—';
        const d = new Date(iso);
        return d.toLocaleDateString('en-GB', {
            day: 'numeric',
            month: 'short',
            year: 'numeric'
        });
    }
</script>

<svelte:head>
    <title>Substrate — Ontara Portal</title>
</svelte:head>

<div class="px-6 py-6 max-w-5xl">
    <header class="mb-6">
        <h1 class="text-xl font-semibold text-secondary-900 dark:text-secondary-100">Substrate</h1>
        <p class="text-sm text-secondary-500 dark:text-secondary-400 mt-1">
            Block-composable knowledge substrate documents (W-120 Phase 1).
        </p>
    </header>

    {#if data.error}
        <div
            class="rounded-lg border border-red-200 dark:border-red-900 bg-red-50 dark:bg-red-900/20 px-4 py-3 mb-4"
        >
            <p class="text-sm font-medium text-red-700 dark:text-red-300">
                Could not reach the resolver
            </p>
            <p class="text-xs text-red-600 dark:text-red-400 mt-1 font-mono whitespace-pre-wrap">
                {data.error}
            </p>
            <p class="text-xs text-red-600 dark:text-red-400 mt-2">
                Check that the resolver is running at <code>localhost:7300</code> and that
                <code>RESOLVER_TOKEN</code> is set in the Portal's environment.
            </p>
        </div>
    {:else if data.documents.length === 0}
        <div class="text-sm text-secondary-500 dark:text-secondary-400 py-8 text-center border border-dashed border-secondary-200 dark:border-secondary-700 rounded-lg">
            No substrate documents yet.
        </div>
    {:else}
        <div class="bg-white dark:bg-secondary-800 border border-secondary-200 dark:border-secondary-700 rounded-lg overflow-hidden">
            <table class="w-full text-sm">
                <thead class="bg-secondary-50 dark:bg-secondary-900/50 text-xs uppercase tracking-wider text-secondary-500 dark:text-secondary-400">
                    <tr>
                        <th class="text-left px-4 py-2.5 font-semibold">Title</th>
                        <th class="text-left px-4 py-2.5 font-semibold">Slug</th>
                        <th class="text-right px-4 py-2.5 font-semibold">Blocks</th>
                        <th class="text-right px-4 py-2.5 font-semibold">Updated</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-secondary-100 dark:divide-secondary-700">
                    {#each data.documents as doc}
                        <tr class="hover:bg-secondary-50 dark:hover:bg-secondary-700/40 transition-colors">
                            <td class="px-4 py-2.5">
                                <a
                                    href="/substrate/{doc.slug}"
                                    class="font-medium text-primary-600 dark:text-primary-400 hover:underline"
                                >
                                    {doc.title}
                                </a>
                            </td>
                            <td class="px-4 py-2.5 font-mono text-xs text-secondary-500 dark:text-secondary-400">
                                {doc.slug}
                            </td>
                            <td class="px-4 py-2.5 text-right tabular-nums text-secondary-700 dark:text-secondary-300">
                                {doc.block_count}
                            </td>
                            <td class="px-4 py-2.5 text-right text-xs text-secondary-500 dark:text-secondary-400">
                                {formatDate(doc.updated_at)}
                            </td>
                        </tr>
                    {/each}
                </tbody>
            </table>
        </div>
    {/if}
</div>
