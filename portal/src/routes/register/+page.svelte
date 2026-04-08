<script lang="ts">
    import { Button, Helper, Input, Label } from 'flowbite-svelte';
    import type { PageData, ActionData } from './$types';

    let { data, form }: { data: PageData; form: ActionData } = $props();

    // form is a union of possible fail() returns — use 'any' to access fields safely
    const f = $derived(form as any);
</script>

<svelte:head>
    <title>Create Account — Ontara Portal</title>
</svelte:head>

<div class="min-h-screen flex items-center justify-center bg-secondary-50 dark:bg-secondary-900 px-4 py-12">
    <div class="w-full max-w-md">
        <div class="text-center mb-8">
            <span class="text-3xl font-bold text-primary-600 dark:text-primary-400">Ontara</span>
            <span class="text-3xl font-light text-secondary-700 dark:text-secondary-300"> Portal</span>
            <p class="mt-2 text-secondary-500 dark:text-secondary-400">Create your account</p>
        </div>

        <div class="bg-white dark:bg-secondary-800 rounded-2xl shadow-sm border border-secondary-200 dark:border-secondary-700 p-8">
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
                        color={f?.errors?.email ? 'red' : 'default'}
                    />
                    {#if f?.errors?.email}
                        <Helper color="red" class="mt-1">{f.errors.email}</Helper>
                    {/if}
                </div>

                <div>
                    <Label for="displayName" class="mb-2 text-secondary-700 dark:text-secondary-300">Your name</Label>
                    <Input
                        id="displayName"
                        name="displayName"
                        type="text"
                        value={f?.displayName ?? ''}
                        placeholder="Jane Smith"
                        required
                        color={f?.errors?.displayName ? 'red' : 'default'}
                    />
                    {#if f?.errors?.displayName}
                        <Helper color="red" class="mt-1">{f.errors.displayName}</Helper>
                    {/if}
                </div>

                <div>
                    <Label for="password" class="mb-2 text-secondary-700 dark:text-secondary-300">Password</Label>
                    <Input
                        id="password"
                        name="password"
                        type="password"
                        placeholder="At least 8 characters"
                        required
                        color={f?.errors?.password ? 'red' : 'default'}
                    />
                    {#if f?.errors?.password}
                        <Helper color="red" class="mt-1">{f.errors.password}</Helper>
                    {/if}
                </div>

                <div>
                    <Label for="confirmPassword" class="mb-2 text-secondary-700 dark:text-secondary-300">Confirm password</Label>
                    <Input
                        id="confirmPassword"
                        name="confirmPassword"
                        type="password"
                        placeholder="Repeat your password"
                        required
                        color={f?.errors?.confirmPassword ? 'red' : 'default'}
                    />
                    {#if f?.errors?.confirmPassword}
                        <Helper color="red" class="mt-1">{f.errors.confirmPassword}</Helper>
                    {/if}
                </div>

                <Button type="submit" color="primary" class="w-full mt-2">Create Account</Button>
            </form>

            <p class="text-center text-sm text-secondary-500 dark:text-secondary-400 mt-6">
                Already have an account?
                <a href="/login" class="text-primary-600 dark:text-primary-400 hover:underline font-medium">Sign in</a>
            </p>
        </div>
    </div>
</div>
