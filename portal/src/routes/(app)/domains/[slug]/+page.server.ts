import type { PageServerLoad } from './$types';
import { getMembersOfDomain } from '$lib/server/db/memberships';

export const load: PageServerLoad = async ({ parent }) => {
    const { domain } = await parent();
    const members = getMembersOfDomain(domain.id);
    return { members };
};
