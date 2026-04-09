import { fail, redirect } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';
import { getDomainBySlug } from '$lib/server/db/domains';
import { getInstanceById, updateConfig, getInstancesForDomain } from '$lib/server/db/modules';

export const load: PageServerLoad = async ({ params, parent }) => {
    const { domain } = await parent();
    const instance = getInstanceById(params.moduleId);
    if (!instance || instance.domainId !== domain.id) throw redirect(303, `/domains/${domain.slug}`);
    const allModules = getInstancesForDomain(domain.id);
    const businessModules = allModules.filter(m => m.definition.category === 'business' && m.id !== instance.id);
    return { instance, businessModules };
};

export const actions: Actions = {
    default: async ({ request, params }) => {
        const domain = getDomainBySlug(params.slug);
        if (!domain) return fail(404, { error: 'Domain not found.' });

        const instance = getInstanceById(params.moduleId);
        if (!instance || instance.domainId !== domain.id) {
            return fail(404, { error: 'Module not found.' });
        }

        const data = await request.formData();
        const configValues: Record<string, unknown> = {};

        for (const field of instance.definition.configSchema) {
            const raw = data.get(field.key);
            if (field.type === 'boolean') {
                configValues[field.key] = raw === 'on' || raw === 'true';
            } else if (field.type === 'number') {
                configValues[field.key] = raw !== null && raw !== '' ? Number(raw) : field.defaultValue;
            } else {
                configValues[field.key] = raw ?? field.defaultValue;
            }
        }

        updateConfig(instance.id, configValues);
        throw redirect(303, `/domains/${domain.slug}/modules/${instance.id}`);
    }
};
