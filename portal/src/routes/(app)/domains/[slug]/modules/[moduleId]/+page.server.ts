import { fail, redirect } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';
import { getDomainBySlug } from '$lib/server/db/domains';
import {
    getInstanceById,
    getInstancesForDomain,
    updateOperationalState,
    updateInstallationState,
    recordTransition,
    getTransitionsForInstance,
    duplicateInstance,
    updateEpistemicCharacter
} from '$lib/server/db/modules';
import {
    validateOperationalTransition,
    getPreTrashStop
} from '$lib/modules/lifecycle';
import type { OperationalState, EpistemicCharacter } from '$lib/types';

export const load: PageServerLoad = async ({ params, parent }) => {
    const { domain } = await parent();
    const instance = getInstanceById(params.moduleId);
    if (!instance || instance.domainId !== domain.id) throw redirect(303, `/domains/${domain.slug}`);
    const transitions = getTransitionsForInstance(instance.id);
    const allModules = getInstancesForDomain(domain.id);
    return { instance, transitions, allModules };
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
        const confirmed = data.get('confirmed') === 'true';

        const result = validateOperationalTransition(instance.operationalState, targetState);
        if (!result.valid) return fail(400, { error: result.reason });

        // Check for impact on connected modules
        if (!confirmed) {
            const allModules = getInstancesForDomain(domain.id);
            const { assessLifecycleImpact } = await import('$lib/modules/impact.js');
            const impact = assessLifecycleImpact(instance, targetState, allModules);
            if (impact.hasImpact) {
                return {
                    confirmNeeded: true,
                    targetState,
                    affectedModules: impact.affectedModules.map(a => ({
                        name: a.module.displayName || a.module.definition.name,
                        sharedConcerns: a.sharedConcerns,
                        currentState: a.currentState
                    }))
                };
            }
        }

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
    },

    duplicate: async ({ request, params, locals }) => {
        const domain = getDomainBySlug(params.slug);
        if (!domain) return fail(404, { error: 'Domain not found.' });

        const instance = getInstanceById(params.moduleId);
        if (!instance || instance.domainId !== domain.id) {
            return fail(404, { error: 'Module not found.' });
        }

        const data = await request.formData();
        const variantName = (data.get('variantName') as string)?.trim();
        if (!variantName) return fail(400, { error: 'Variant name is required.' });

        const newInstance = duplicateInstance(instance.id, locals.user!.id, variantName);

        // Record the duplication as a transition on the new instance
        recordTransition(newInstance.id, 'installation', 'available', 'installed', locals.user!.id, `Duplicated from ${instance.displayName || instance.definition.name}`);

        throw redirect(303, `/domains/${domain.slug}/modules/${newInstance.id}`);
    },

    setEpistemic: async ({ request, params }) => {
        const domain = getDomainBySlug(params.slug);
        if (!domain) return fail(404, { error: 'Domain not found.' });

        const instance = getInstanceById(params.moduleId);
        if (!instance || instance.domainId !== domain.id) {
            return fail(404, { error: 'Module not found.' });
        }

        if (instance.operationalState !== 'draft') {
            return fail(400, { error: 'Epistemic character can only be changed in draft state.' });
        }

        const data = await request.formData();
        const character = data.get('epistemicCharacter') as EpistemicCharacter;
        if (!['production', 'hypothesis', 'projection'].includes(character)) {
            return fail(400, { error: 'Invalid epistemic character.' });
        }

        updateEpistemicCharacter(instance.id, character);
        return {};
    }
};
