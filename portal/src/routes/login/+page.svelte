<script lang="ts">
    import { Alert, Button, Input, Label } from 'flowbite-svelte';
    import type { PageData, ActionData } from './$types';

    let { data, form }: { data: PageData; form: ActionData } = $props();
    const f = $derived(form as any);
</script>

<svelte:head>
    <title>Sign In — Ontara Portal</title>
</svelte:head>

<div class="min-h-screen flex items-center justify-center bg-secondary-50 dark:bg-secondary-900 px-4 py-12">
    <div class="w-full max-w-md">
        <div class="text-center mb-8">
            <span class="text-3xl font-bold text-primary-600 dark:text-primary-400">Ontara</span>
            <span class="text-3xl font-light text-secondary-700 dark:text-secondary-300"> Portal</span>
            <p class="mt-2 text-secondary-500 dark:text-secondary-400">Sign in to your account</p>
        </div>

        <div class="bg-white dark:bg-secondary-800 rounded-2xl shadow-sm border border-secondary-200 dark:border-secondary-700 p-8">
            {#if f?.errors?.form}
                <Alert color="red" class="mb-5">{f.errors.form}</Alert>
            {/if}

            <form method="POST" class="space-y-5">
                <div>
                    <Label for="email" class="mb-2 text-secondary-700 dark:text-secondary-300">Email address</Label>
                    <Input
                        id="email"
                        name="email"
                        type="email"
                        value={f?.email ?? ''}
                        placeholder="you@example.com"
                        required
                    />
                </div>

                <div>
                    <Label for="password" class="mb-2 text-secondary-700 dark:text-secondary-300">Password</Label>
                    <Input
                        id="password"
                        name="password"
                        type="password"
                        placeholder="Your password"
                        required
                    />
                </div>

                <Button type="submit" color="primary" class="w-full mt-2">Sign In</Button>
            </form>

            <p class="text-center text-sm text-secondary-500 dark:text-secondary-400 mt-6">
                Don't have an account?
                <a href="/register" class="text-primary-600 dark:text-primary-400 hover:underline font-medium">Create one</a>
            </p>
        </div>
    </div>
</div>
