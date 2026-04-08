<script lang="ts">
    import { Button } from 'flowbite-svelte';
    import type { PageData } from './$types';

    let { data }: { data: PageData } = $props();
</script>

<svelte:head>
    <title>Ontara Portal</title>
</svelte:head>

<div class="min-h-screen flex items-center justify-center bg-secondary-50 dark:bg-secondary-900 px-4">
    <div class="text-center max-w-lg">
        <div class="mb-6">
            <span class="text-5xl font-bold text-primary-600 dark:text-primary-400">Ontara</span>
            <span class="text-5xl font-light text-secondary-700 dark:text-secondary-300"> Portal</span>
        </div>
        <p class="text-lg text-secondary-500 dark:text-secondary-400 mb-10">
            Your service business, structured and ready to grow.
        </p>
        <div class="flex gap-4 justify-center">
            <Button href="/login" color="primary" size="lg">Sign In</Button>
            <Button href="/register" color="alternative" size="lg">Create Account</Button>
        </div>
    </div>
</div>
