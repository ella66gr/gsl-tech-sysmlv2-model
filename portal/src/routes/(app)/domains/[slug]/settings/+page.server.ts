import { fail } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';
import { getDomainBySlug, updateDomain } from '$lib/server/db/domains';
import { getMembership, getMembersOfDomain } from '$lib/server/db/memberships';

export const load: PageServerLoad = async ({ parent }) => {
    const { domain, membership } = await parent();
    const members = getMembersOfDomain(domain.id);
    return { members, isSuperAdmin: membership.role === 'super_admin' };
};

export const actions: Actions = {
    update: async ({ request, locals, params }) => {
        const domain = getDomainBySlug(params.slug);
        if (!domain) return fail(404, { errors: { form: 'Domain not found.' } });

        const membership = getMembership(locals.user!.id, domain.id);
        if (!membership || membership.role !== 'super_admin') {
            return fail(403, { errors: { form: 'Only the domain owner can edit settings.' } });
        }

        const data = await request.formData();
        const name = (data.get('name') as string)?.trim();
        const businessType = (data.get('businessType') as string)?.trim() || null;
        const description = (data.get('description') as string)?.trim() || null;

        if (!name) {
            return fail(400, { errors: { name: 'Domain name is required.' } });
        }

        updateDomain(domain.id, { name, businessType, description });
        return { success: true };
    }
};
