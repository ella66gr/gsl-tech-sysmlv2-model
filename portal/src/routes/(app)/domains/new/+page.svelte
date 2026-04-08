<script lang="ts">
    import { Button, Helper, Input, Label, Textarea } from 'flowbite-svelte';
    import type { PageData, ActionData } from './$types';

    let { data, form }: { data: PageData; form: ActionData } = $props();
    const f = $derived(form as any);

    const initialForm = form as any;
    let nameValue = $state(initialForm?.name ?? '');
    let slugValue = $state(initialForm?.slug ?? '');
    let slugEdited = $state(!!initialForm?.slug);

    function generateSlug(name: string): string {
        return name
            .toLowerCase()
            .replace(/\s+/g, '-')
            .replace(/[^a-z0-9-]/g, '')
            .replace(/-+/g, '-')
            .replace(/^-|-$/g, '');
    }

    function onNameInput(e: Event) {
        nameValue = (e.target as HTMLInputElement).value;
        if (!slugEdited) {
            slugValue = generateSlug(nameValue);
        }
    }

    function onSlugInput(e: Event) {
        slugEdited = true;
        slugValue = (e.target as HTMLInputElement).value;
    }
</script>

<svelte:head>
    <title>Create Domain — Ontara Portal</title>
</svelte:head>

<div class="p-6 max-w-xl mx-auto">
    <div class="mb-8">
        <a href="/domains" class="text-sm text-primary-600 dark:text-primary-400 hover:underline">← Back to domains</a>
        <h1 class="text-2xl font-semibold text-secondary-900 dark:text-secondary-100 mt-3">Create a new domain</h1>
        <p class="text-sm text-secondary-500 dark:text-secondary-400 mt-1">Set up a domain for your business or organisation.</p>
    </div>

    <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 p-6">
        <form method="POST" class="space-y-6">
            <div>
                <Label for="name" class="mb-2 text-secondary-700 dark:text-secondary-300">Domain name <span class="text-red-500">*</span></Label>
                <Input
                    id="name"
                    name="name"
                    type="text"
                    value={nameValue}
                    oninput={onNameInput}
                    placeholder="e.g. BrightStar Jewellers"
                    required
                    color={f?.errors?.name ? 'red' : 'default'}
                />
                {#if f?.errors?.name}
                    <Helper color="red" class="mt-1">{f.errors.name}</Helper>
                {/if}
            </div>

            <div>
                <Label for="slug" class="mb-2 text-secondary-700 dark:text-secondary-300">URL slug <span class="text-red-500">*</span></Label>
                <Input
                    id="slug"
                    name="slug"
                    type="text"
                    value={slugValue}
                    oninput={onSlugInput}
                    placeholder="e.g. brightstar"
                    required
                    color={f?.errors?.slug ? 'red' : 'default'}
                />
                <Helper class="mt-1 text-secondary-400 dark:text-secondary-500">
                    Your domain will be at <span class="font-mono">{slugValue || 'your-slug'}.ontara.dev</span>
                </Helper>
                {#if f?.errors?.slug}
                    <Helper color="red" class="mt-1">{f.errors.slug}</Helper>
                {/if}
            </div>

            <div>
                <Label for="businessType" class="mb-2 text-secondary-700 dark:text-secondary-300">Business type</Label>
                <Input
                    id="businessType"
                    name="businessType"
                    type="text"
                    value={f?.businessType ?? ''}
                    placeholder="e.g. Jewellery retail, Healthcare clinic, Coffee shop"
                />
                <Helper class="mt-1 text-secondary-400 dark:text-secondary-500">Optional. Helps categorise your domain.</Helper>
            </div>

            <div>
                <Label for="description" class="mb-2 text-secondary-700 dark:text-secondary-300">Description</Label>
                <Textarea
                    id="description"
                    name="description"
                    value={f?.description ?? ''}
                    placeholder="A brief description of this domain..."
                    rows={3}
                />
            </div>

            <div class="flex gap-3 pt-2">
                <Button type="submit" color="primary">Create Domain</Button>
                <Button href="/domains" color="alternative">Cancel</Button>
            </div>
        </form>
    </div>
</div>
