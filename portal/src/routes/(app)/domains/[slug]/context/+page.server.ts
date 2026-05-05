import { fail } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';
import { getContextForDomain, upsertContext } from '$lib/server/db/context';
import { getInstancesForDomain } from '$lib/server/db/modules';
import { getDomainBySlug } from '$lib/server/db/domains';
import type { BmmConcern } from '$lib/types';
import { CONCERN_META } from '$lib/context/schemas';

export const load: PageServerLoad = async ({ parent }) => {
    const { domain } = await parent();
    const contexts = getContextForDomain(domain.id);
    const modules = getInstancesForDomain(domain.id);
    return { contexts, modules };
};

export const actions: Actions = {
    updateContext: async ({ request, params }) => {
        const domain = getDomainBySlug(params.slug);
        if (!domain) {
            return fail(404, { error: 'Domain not found.' });
        }
        const data = await request.formData();
        const concern = data.get('concern') as BmmConcern;

        if (!concern || !CONCERN_META[concern]) {
            return fail(400, { error: 'Invalid concern.' });
        }

        const schema = CONCERN_META[concern].schema;
        const values: Record<string, unknown> = {};

        for (const field of schema) {
            const raw = data.get(field.key);
            if (field.type === 'boolean') {
                values[field.key] = raw === 'on' || raw === 'true';
            } else if (field.type === 'number') {
                values[field.key] = raw ? Number(raw) : field.defaultValue;
            } else {
                values[field.key] = raw ? String(raw) : field.defaultValue;
            }
        }

        upsertContext(domain.id, concern, values);
        return { success: true, concern };
    }
};
