import { fail } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';
import { hashPassword, verifyPassword } from '$lib/server/auth';
import { getUserById, updateUser, getUserByEmail } from '$lib/server/db/users';
import { getDomainsForUser } from '$lib/server/db/domains';

export const load: PageServerLoad = async ({ locals }) => {
    const domains = getDomainsForUser(locals.user!.id);
    return { domains };
};

export const actions: Actions = {
    updateProfile: async ({ request, locals }) => {
        const data = await request.formData();
        const displayName = (data.get('displayName') as string)?.trim();

        if (!displayName) {
            return fail(400, { profileErrors: { displayName: 'Name cannot be empty.' } });
        }

        updateUser(locals.user!.id, { displayName });
        return { profileSuccess: true };
    },

    changePassword: async ({ request, locals }) => {
        const data = await request.formData();
        const currentPassword = data.get('currentPassword') as string;
        const newPassword = data.get('newPassword') as string;
        const confirmPassword = data.get('confirmPassword') as string;

        const userRow = getUserByEmail(locals.user!.email);
        if (!userRow) {
            return fail(400, { passwordErrors: { form: 'User not found.' } });
        }

        const valid = await verifyPassword(currentPassword, userRow.password_hash);
        if (!valid) {
            return fail(400, { passwordErrors: { currentPassword: 'Current password is incorrect.' } });
        }

        const errors: Record<string, string> = {};
        if (!newPassword || newPassword.length < 8) {
            errors.newPassword = 'New password must be at least 8 characters.';
        }
        if (newPassword !== confirmPassword) {
            errors.confirmPassword = 'Passwords do not match.';
        }

        if (Object.keys(errors).length > 0) {
            return fail(400, { passwordErrors: errors });
        }

        const passwordHash = await hashPassword(newPassword);
        updateUser(locals.user!.id, { passwordHash });
        return { passwordSuccess: true };
    }
};
