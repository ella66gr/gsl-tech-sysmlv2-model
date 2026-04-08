import { redirect } from '@sveltejs/kit';
import type { LayoutServerLoad } from './$types';
import { getDomainsForUser } from '$lib/server/db/domains';

export const load: LayoutServerLoad = async ({ locals }) => {
    if (!locals.user) throw redirect(303, '/login');
    const domains = getDomainsForUser(locals.user.id);
    return { user: locals.user, domains };
};
