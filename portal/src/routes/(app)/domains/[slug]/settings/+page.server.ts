import { fail } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';
import { getDomainBySlug, updateDomain } from '$lib/server/db/domains';
import { getMembership, getMembersOfDomain } from '$lib/server/db/memberships';
import {
    getInstancesForDomain,
    updateInstallationState,
    updateOperationalState,
    recordTransition,
    deleteInstance
} from '$lib/server/db/modules';

export const load: PageServerLoad = async ({ parent }) => {
    const { domain, membership } = await parent();
    const members = getMembersOfDomain(domain.id);
    const trashedModules = getInstancesForDomain(domain.id, true).filter(m => m.installationState === 'trashed');
    return { members, isSuperAdmin: membership.role === 'super_admin', trashedModules };
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
    },

    restore: async ({ request, params, locals }) => {
        const domain = getDomainBySlug(params.slug);
        if (!domain) return fail(404, { trashError: 'Domain not found.' });

        const data = await request.formData();
        const moduleId = data.get('moduleId') as string;

        const modules = getInstancesForDomain(domain.id, true);
        const instance = modules.find(m => m.id === moduleId);
        if (!instance || instance.installationState !== 'trashed') {
            return fail(404, { trashError: 'Module not found in trash.' });
        }

        updateInstallationState(instance.id, 'installed');
        updateOperationalState(instance.id, 'stopped');
        recordTransition(instance.id, 'installation', 'trashed', 'installed', locals.user!.id, 'Restored from trash');
        return { restoreSuccess: true };
    },

    permanentDelete: async ({ request, params }) => {
        const domain = getDomainBySlug(params.slug);
        if (!domain) return fail(404, { trashError: 'Domain not found.' });

        const data = await request.formData();
        const moduleId = data.get('moduleId') as string;

        const modules = getInstancesForDomain(domain.id, true);
        const instance = modules.find(m => m.id === moduleId);
        if (!instance || instance.installationState !== 'trashed') {
            return fail(404, { trashError: 'Module not found in trash.' });
        }

        deleteInstance(instance.id);
        return { deleteSuccess: true };
    }
};
