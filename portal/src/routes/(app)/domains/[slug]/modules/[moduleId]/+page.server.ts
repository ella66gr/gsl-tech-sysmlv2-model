import { fail, redirect } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';
import { getDomainBySlug } from '$lib/server/db/domains';
import {
    getInstanceById,
    updateOperationalState,
    updateInstallationState,
    recordTransition,
    getTransitionsForInstance
} from '$lib/server/db/modules';
import {
    validateOperationalTransition,
    getPreTrashStop
} from '$lib/modules/lifecycle';
import type { OperationalState } from '$lib/types';

export const load: PageServerLoad = async ({ params, parent }) => {
    const { domain } = await parent();
    const instance = getInstanceById(params.moduleId);
    if (!instance || instance.domainId !== domain.id) throw redirect(303, `/domains/${domain.slug}`);
    const transitions = getTransitionsForInstance(instance.id);
    return { instance, transitions };
};

export const actions: Actions = {
    transition: async ({ request, params, locals }) => {
        const domain = getDomainBySlug(params.slug);
        if (!domain) return fail(404, { error: 'Domain not found.' });

        const instance = getInstanceById(params.moduleId);
        if (!instance || instance.domainId !== domain.id) {
            return fail(404, { error: 'Module not found.' });
        }

        const data = await request.formData();
        const targetState = data.get('targetState') as OperationalState;
        const note = (data.get('note') as string) || undefined;

        const result = validateOperationalTransition(instance.operationalState, targetState);
        if (!result.valid) return fail(400, { error: result.reason });

        const fromState = instance.operationalState;
        updateOperationalState(instance.id, targetState);
        recordTransition(instance.id, 'operational', fromState, targetState, locals.user!.id, note);
        return {};
    },

    trash: async ({ params, locals }) => {
        const domain = getDomainBySlug(params.slug);
        if (!domain) return fail(404, { error: 'Domain not found.' });

        const instance = getInstanceById(params.moduleId);
        if (!instance || instance.domainId !== domain.id) {
            return fail(404, { error: 'Module not found.' });
        }

        // Compound: stop first if active/paused
        const preStop = getPreTrashStop(instance.operationalState);
        if (preStop) {
            updateOperationalState(instance.id, preStop);
            recordTransition(instance.id, 'operational', instance.operationalState, preStop, locals.user!.id, 'Auto-stopped before trash');
        }

        updateInstallationState(instance.id, 'trashed');
        recordTransition(instance.id, 'installation', 'installed', 'trashed', locals.user!.id);

        throw redirect(303, `/domains/${domain.slug}`);
    }
};
