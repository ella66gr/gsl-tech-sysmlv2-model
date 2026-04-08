<script lang="ts">
    import { Alert, Badge, Button, Helper, Input, Label } from 'flowbite-svelte';
    import { BuildingOutline } from 'flowbite-svelte-icons';
    import type { PageData, ActionData } from './$types';

    let { data, form }: { data: PageData; form: ActionData } = $props();
    const f = $derived(form as any);

    function roleColor(role: string): 'purple' | 'blue' | 'gray' {
        if (role === 'super_admin') return 'purple';
        if (role === 'admin') return 'blue';
        return 'gray';
    }

    function formatDate(iso: string) {
        return new Date(iso).toLocaleDateString('en-GB', { day: 'numeric', month: 'long', year: 'numeric' });
    }
</script>

<svelte:head>
    <title>Profile — Ontara Portal</title>
</svelte:head>

<div class="p-6 max-w-2xl mx-auto">
    <div class="mb-8">
        <h1 class="text-2xl font-semibold text-secondary-900 dark:text-secondary-100">Your Profile</h1>
        <p class="text-sm text-secondary-500 dark:text-secondary-400 mt-1">Manage your account details</p>
    </div>

    <!-- Profile details -->
    <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 p-6 mb-6">
        <h2 class="font-semibold text-secondary-900 dark:text-secondary-100 mb-5">Account Details</h2>

        {#if f?.profileSuccess}
            <Alert color="green" class="mb-5">Profile updated successfully.</Alert>
        {/if}

        <div class="mb-5">
            <Label class="mb-2 text-secondary-700 dark:text-secondary-300">Email address</Label>
            <Input value={data.user.email} disabled />
            <Helper class="mt-1 text-secondary-400">Email address cannot be changed.</Helper>
        </div>

        <form method="POST" action="?/updateProfile" class="space-y-5">
            <div>
                <Label for="displayName" class="mb-2 text-secondary-700 dark:text-secondary-300">Display name</Label>
                <Input
                    id="displayName"
                    name="displayName"
                    type="text"
                    value={data.user.displayName}
                    color={f?.profileErrors?.displayName ? 'red' : 'default'}
                />
                {#if f?.profileErrors?.displayName}
                    <Helper color="red" class="mt-1">{f.profileErrors.displayName}</Helper>
                {/if}
            </div>
            <div class="text-sm text-secondary-400">
                Member since {formatDate(data.user.createdAt)}
            </div>
            <Button type="submit" color="primary">Save Changes</Button>
        </form>
    </div>

    <!-- Password change -->
    <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 p-6 mb-6">
        <h2 class="font-semibold text-secondary-900 dark:text-secondary-100 mb-5">Change Password</h2>

        {#if f?.passwordSuccess}
            <Alert color="green" class="mb-5">Password changed successfully.</Alert>
        {/if}
        {#if f?.passwordErrors?.form}
            <Alert color="red" class="mb-5">{f.passwordErrors.form}</Alert>
        {/if}

        <form method="POST" action="?/changePassword" class="space-y-5">
            <div>
                <Label for="currentPassword" class="mb-2 text-secondary-700 dark:text-secondary-300">Current password</Label>
                <Input
                    id="currentPassword"
                    name="currentPassword"
                    type="password"
                    placeholder="Your current password"
                    color={f?.passwordErrors?.currentPassword ? 'red' : 'default'}
                />
                {#if f?.passwordErrors?.currentPassword}
                    <Helper color="red" class="mt-1">{f.passwordErrors.currentPassword}</Helper>
                {/if}
            </div>
            <div>
                <Label for="newPassword" class="mb-2 text-secondary-700 dark:text-secondary-300">New password</Label>
                <Input
                    id="newPassword"
                    name="newPassword"
                    type="password"
                    placeholder="At least 8 characters"
                    color={f?.passwordErrors?.newPassword ? 'red' : 'default'}
                />
                {#if f?.passwordErrors?.newPassword}
                    <Helper color="red" class="mt-1">{f.passwordErrors.newPassword}</Helper>
                {/if}
            </div>
            <div>
                <Label for="confirmPassword" class="mb-2 text-secondary-700 dark:text-secondary-300">Confirm new password</Label>
                <Input
                    id="confirmPassword"
                    name="confirmPassword"
                    type="password"
                    placeholder="Repeat new password"
                    color={f?.passwordErrors?.confirmPassword ? 'red' : 'default'}
                />
                {#if f?.passwordErrors?.confirmPassword}
                    <Helper color="red" class="mt-1">{f.passwordErrors.confirmPassword}</Helper>
                {/if}
            </div>
            <Button type="submit" color="primary">Change Password</Button>
        </form>
    </div>

    <!-- Domains -->
    {#if data.domains.length > 0}
        <div class="bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700 p-6">
            <h2 class="font-semibold text-secondary-900 dark:text-secondary-100 mb-4">Your Domains</h2>
            <div class="space-y-2">
                {#each data.domains as domain}
                    <a
                        href="/domains/{domain.slug}"
                        class="flex items-center justify-between p-3 rounded-xl hover:bg-secondary-50 dark:hover:bg-secondary-700 transition-colors group"
                    >
                        <div class="flex items-center gap-3">
                            <div class="w-8 h-8 rounded-lg bg-primary-100 dark:bg-primary-900/30 flex items-center justify-center">
                                <BuildingOutline class="w-4 h-4 text-primary-600 dark:text-primary-400" />
                            </div>
                            <div>
                                <p class="text-sm font-medium text-secondary-900 dark:text-secondary-100 group-hover:text-primary-700 dark:group-hover:text-primary-300 transition-colors">{domain.name}</p>
                                {#if domain.businessType}
                                    <p class="text-xs text-secondary-400">{domain.businessType}</p>
                                {/if}
                            </div>
                        </div>
                        <Badge color={roleColor(domain.role)} class="capitalize text-xs">{domain.role.replace('_', ' ')}</Badge>
                    </a>
                {/each}
            </div>
        </div>
    {/if}
</div>
