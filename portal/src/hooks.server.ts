import type { Handle } from '@sveltejs/kit';
import { redirect } from '@sveltejs/kit';
import { getSessionToken } from '$lib/server/auth';
import { getValidSession } from '$lib/server/db/sessions';

const PUBLIC_PATHS = ['/', '/login', '/register'];

export const handle: Handle = async ({ event, resolve }) => {
    const token = getSessionToken(event.cookies);

    if (token) {
        const result = getValidSession(token);
        event.locals.user = result?.user ?? null;
    } else {
        event.locals.user = null;
    }

    // Protect non-public routes
    const path = event.url.pathname;
    const isPublic = PUBLIC_PATHS.includes(path) || path.startsWith('/logout');
    if (!isPublic && !event.locals.user) {
        throw redirect(303, '/login');
    }

    return resolve(event);
};
