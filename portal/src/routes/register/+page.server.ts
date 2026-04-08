import { fail, redirect } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';
import { hashPassword } from '$lib/server/auth';
import { setSessionCookie } from '$lib/server/auth';
import { createUser, getUserByEmail } from '$lib/server/db/users';
import { createSession } from '$lib/server/db/sessions';

export const load: PageServerLoad = async ({ locals }) => {
    if (locals.user) throw redirect(303, '/domains');
    return {};
};

export const actions: Actions = {
    default: async ({ request, cookies }) => {
        const data = await request.formData();
        const email = (data.get('email') as string)?.trim().toLowerCase();
        const displayName = (data.get('displayName') as string)?.trim();
        const password = data.get('password') as string;
        const confirmPassword = data.get('confirmPassword') as string;

        const errors: Record<string, string> = {};

        if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
            errors.email = 'Please enter a valid email address.';
        }
        if (!displayName) {
            errors.displayName = 'Display name is required.';
        }
        if (!password || password.length < 8) {
            errors.password = 'Password must be at least 8 characters.';
        }
        if (password !== confirmPassword) {
            errors.confirmPassword = 'Passwords do not match.';
        }

        if (Object.keys(errors).length > 0) {
            return fail(400, { errors, email, displayName });
        }

        const existing = getUserByEmail(email);
        if (existing) {
            return fail(400, {
                errors: { email: 'An account with this email already exists.' },
                email,
                displayName
            });
        }

        const passwordHash = await hashPassword(password);
        const user = createUser(email, displayName, passwordHash);
        const session = createSession(user.id);
        setSessionCookie(cookies, session.id);

        throw redirect(303, '/domains');
    }
};
