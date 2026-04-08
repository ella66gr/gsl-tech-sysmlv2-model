import { fail } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';
import { getMembersOfDomain } from '$lib/server/db/memberships';
import { getInstancesForDomain, updateOperationalState, recordTransition } from '$lib/server/db/modules';
import { getDomainBySlug } from '$lib/server/db/domains';
import { validateOperationalTransition } from '$lib/modules/lifecycle';
import type { OperationalState } from '$lib/types';

export const load: PageServerLoad = async ({ parent }) => {
    const { domain } = await parent();
    const members = getMembersOfDomain(domain.id);
    const modules = getInstancesForDomain(domain.id);
    return { members, modules };
};

export const actions: Actions = {
    transition: async ({ request, params, locals }) => {
        const domain = getDomainBySlug(params.slug);
        if (!domain) return fail(404, { error: 'Domain not found.' });

        const data = await request.formData();
        const moduleId = data.get('moduleId') as string;
        const targetState = data.get('targetState') as OperationalState;

        const modules = getInstancesForDomain(domain.id);
        const instance = modules.find(m => m.id === moduleId);
        if (!instance) return fail(404, { error: 'Module not found.' });

        const result = validateOperationalTransition(instance.operationalState, targetState);
        if (!result.valid) return fail(400, { error: result.reason });

        const fromState = instance.operationalState;
        updateOperationalState(instance.id, targetState);
        recordTransition(instance.id, 'operational', fromState, targetState, locals.user!.id);
        return {};
    }
};
