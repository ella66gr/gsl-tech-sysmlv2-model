import { fail, redirect } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';
import { verifyPassword, setSessionCookie } from '$lib/server/auth';
import { getUserByEmail } from '$lib/server/db/users';
import { createSession } from '$lib/server/db/sessions';

export const load: PageServerLoad = async ({ locals }) => {
    if (locals.user) throw redirect(303, '/domains');
    return {};
};

export const actions: Actions = {
    default: async ({ request, cookies }) => {
        const data = await request.formData();
        const email = (data.get('email') as string)?.trim().toLowerCase();
        const password = data.get('password') as string;

        const user = getUserByEmail(email);
        const valid = user ? await verifyPassword(password, user.password_hash) : false;

        if (!user || !valid) {
            return fail(400, {
                errors: { form: 'Invalid email or password.' },
                email
            });
        }

        const session = createSession(user.id);
        setSessionCookie(cookies, session.id);

        throw redirect(303, '/domains');
    }
};
