import { redirect } from '@sveltejs/kit';
import type { LayoutServerLoad } from './$types';
import { getDomainBySlug } from '$lib/server/db/domains';
import { getMembership } from '$lib/server/db/memberships';

export const load: LayoutServerLoad = async ({ params, locals }) => {
    const domain = getDomainBySlug(params.slug);
    if (!domain) throw redirect(303, '/domains');

    const membership = getMembership(locals.user!.id, domain.id);
    if (!membership) throw redirect(303, '/domains');

    return { domain, membership };
};
