<script lang="ts">
    import { Badge } from 'flowbite-svelte';
    import { CubesStackedOutline, UsersOutline, CalendarMonthOutline, GridPlusOutline } from 'flowbite-svelte-icons';
    import type { PageData } from './$types';

    let { data }: { data: PageData } = $props();

    function formatDate(iso: string) {
        return new Date(iso).toLocaleDateString('en-GB', { day: 'numeric', month: 'long', year: 'numeric' });
    }
</script>

<svelte:head>
    <title>{data.domain.name} — Ontara Portal</title>
</svelte:head>

<div class="p-6 max-w-6xl mx-auto">
    <!-- Domain header -->
    <div class="mb-8">
        <div class="flex items-start justify-between">
            <div>
                <h1 class="text-2xl font-semibold text-secondary-900 dark:text-secondary-100">{data.domain.name}</h1>
                {#if data.domain.businessType}
                    <p class="text-secondary-500 dark:text-secondary-400 mt-0.5">{data.domain.businessType}</p>
                {/if}
            </div>
            <Badge color="yellow" class="capitalize text-sm px-3 py-1">{data.domain.status}</Badge>
        </div>
        {#if data.domain.description}
            <p class="mt-3 text-secondary-600 dark:text-secondary-400 max-w-2xl">{data.domain.description}</p>
        {/if}
    </div>

    <!-- Two-column layout: content left, info sidebar right -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Main content (left, 2/3) -->
        <div class="lg:col-span-2 space-y-6">
            <!-- Getting started card -->
            <div class="bg-gradient-to-br from-primary-50 to-teal-50 dark:from-primary-900/20 dark:to-teal-900/20 rounded-2xl border border-primary-200 dark:border-primary-800 p-6">
                <div class="flex items-start gap-4">
                    <div class="w-10 h-10 rounded-xl bg-primary-500 flex items-center justify-center flex-shrink-0">
                        <CubesStackedOutline class="w-5 h-5 text-white" />
                    </div>
                    <div>
                        <h2 class="font-semibold text-primary-900 dark:text-primary-100 mb-2">Your domain is ready</h2>
                        <p class="text-sm text-primary-800 dark:text-primary-200 leading-relaxed">
                            Your domain is set up and ready. In a future update, you'll be able to browse the module catalogue,
                            install business modules, and start configuring your service operations from here.
                        </p>
                    </div>
                </div>
            </div>

            <!-- Module grid placeholder -->
            <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 p-6">
                <div class="flex items-center justify-between mb-4">
                    <h2 class="font-semibold text-secondary-900 dark:text-secondary-100">Modules</h2>
                    <Badge color="gray" class="text-xs">Phase 2</Badge>
                </div>
                <div class="border-2 border-dashed border-secondary-200 dark:border-secondary-600 rounded-xl p-10 flex flex-col items-center justify-center text-center">
                    <div class="w-12 h-12 rounded-xl bg-secondary-100 dark:bg-secondary-700 flex items-center justify-center mb-3">
                        <GridPlusOutline class="w-6 h-6 text-secondary-400 dark:text-secondary-500" />
                    </div>
                    <p class="text-sm font-medium text-secondary-500 dark:text-secondary-400">No modules installed yet</p>
                    <p class="text-xs text-secondary-400 dark:text-secondary-500 mt-1 max-w-xs">
                        The module catalogue will be available in the next phase. Modules extend your domain with structured business capabilities.
                    </p>
                </div>
            </div>
        </div>

        <!-- Info sidebar (right, 1/3) -->
        <div class="space-y-4">
            <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 p-5">
                <h3 class="text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-500 mb-4">Domain Info</h3>
                <dl class="space-y-3">
                    <div class="flex items-center justify-between">
                        <dt class="text-sm text-secondary-500 dark:text-secondary-400 flex items-center gap-1.5">
                            <span>Status</span>
                        </dt>
                        <dd><Badge color="yellow" class="capitalize">{data.domain.status}</Badge></dd>
                    </div>
                    <div class="flex items-center justify-between">
                        <dt class="text-sm text-secondary-500 dark:text-secondary-400 flex items-center gap-1.5">
                            <span>Your role</span>
                        </dt>
                        <dd>
                            <Badge color="purple" class="capitalize text-xs">{data.membership.role.replace('_', ' ')}</Badge>
                        </dd>
                    </div>
                    <div class="flex items-center justify-between">
                        <dt class="text-sm text-secondary-500 dark:text-secondary-400 flex items-center gap-1.5">
                            <UsersOutline class="w-3.5 h-3.5" />
                            <span>Members</span>
                        </dt>
                        <dd class="text-sm font-medium text-secondary-900 dark:text-secondary-100">{data.members.length}</dd>
                    </div>
                    <div>
                        <dt class="text-sm text-secondary-500 dark:text-secondary-400 flex items-center gap-1.5 mb-1">
                            <CalendarMonthOutline class="w-3.5 h-3.5" />
                            <span>Created</span>
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

            <!-- Quick links -->
            <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 p-5">
                <h3 class="text-xs font-semibold uppercase tracking-wider text-secondary-400 dark:text-secondary-500 mb-3">Quick Links</h3>
                <div class="space-y-1">
                    <a href="/domains/{data.domain.slug}/settings" class="flex items-center gap-2 text-sm text-secondary-600 dark:text-secondary-400 hover:text-primary-600 dark:hover:text-primary-400 py-1 transition-colors">
                        Domain settings →
                    </a>
                    <a href="/domains" class="flex items-center gap-2 text-sm text-secondary-600 dark:text-secondary-400 hover:text-primary-600 dark:hover:text-primary-400 py-1 transition-colors">
                        All domains →
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>
