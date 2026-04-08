import { redirect } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';
import { getDomainBySlug } from '$lib/server/db/domains';
import { getAllDefinitions, getInstancesForDomain, installModule, recordTransition } from '$lib/server/db/modules';
import { getContextForDomain } from '$lib/server/db/context';

export const load: PageServerLoad = async ({ parent }) => {
    const { domain } = await parent();
    const definitions = getAllDefinitions();
    const instances = getInstancesForDomain(domain.id, true);
    const installedDefinitionIds = instances
        .filter(i => i.installationState === 'installed')
        .map(i => i.definitionId);
    const contexts = getContextForDomain(domain.id);
    return { definitions, installedDefinitionIds, instances, contexts };
};

export const actions: Actions = {
    install: async ({ request, params, locals }) => {
        const domain = getDomainBySlug(params.slug);
        if (!domain) return;

        const data = await request.formData();
        const definitionId = data.get('definitionId') as string;
        if (!definitionId) return;

        const instance = installModule(domain.id, definitionId, '', locals.user!.id);
        recordTransition(instance.id, 'installation', 'available', 'installed', locals.user!.id);

        throw redirect(303, `/domains/${domain.slug}/modules/${instance.id}/configure`);
    }
};
