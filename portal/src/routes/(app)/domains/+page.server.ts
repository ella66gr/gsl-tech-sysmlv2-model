import type { PageServerLoad } from './$types';
import { getDomainsForUser } from '$lib/server/db/domains';

export const load: PageServerLoad = async ({ locals }) => {
    const domains = getDomainsForUser(locals.user!.id);
    return { domains };
};
