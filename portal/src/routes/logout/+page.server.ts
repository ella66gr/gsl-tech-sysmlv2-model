import { redirect } from '@sveltejs/kit';
import type { Actions } from './$types';
import { clearSessionCookie, getSessionToken } from '$lib/server/auth';
import { deleteSession } from '$lib/server/db/sessions';

export const actions: Actions = {
    default: async ({ cookies }) => {
        const token = getSessionToken(cookies);
        if (token) {
            deleteSession(token);
        }
        clearSessionCookie(cookies);
        throw redirect(303, '/login');
    }
};
