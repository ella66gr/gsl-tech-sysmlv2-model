import { fail, redirect } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';
import { getDomainBySlug } from '$lib/server/db/domains.js';
import {
    getInstanceById,
    getInstancesForDomain,
    updateEpistemicCharacter,
    recordTransition
} from '$lib/server/db/modules.js';
import { evaluatePromotionReadiness } from '$lib/server/governance/index.js';

export const load: PageServerLoad = async ({ params, parent }) => {
    const { domain } = await parent();
    const instance = getInstanceById(params.moduleId);
    if (!instance || instance.domainId !== domain.id) {
        throw redirect(303, `/domains/${domain.slug}`);
    }

    const allModules = getInstancesForDomain(domain.id);
    const readiness = evaluatePromotionReadiness(instance, domain, allModules);

    return { instance, readiness };
};

export const actions: Actions = {
    promote: async ({ params, locals }) => {
        const domain = getDomainBySlug(params.slug);
        if (!domain) return fail(404, { error: 'Domain not found.' });

        const instance = getInstanceById(params.moduleId);
        if (!instance || instance.domainId !== domain.id) {
            return fail(404, { error: 'Module not found.' });
        }

        // Re-evaluate prerequisites server-side (don't trust client state)
        const allModules = getInstancesForDomain(domain.id);
        const readiness = evaluatePromotionReadiness(instance, domain, allModules);

        if (!readiness.canPromote) {
            const failingPrereqs = readiness.prerequisites
                .filter(p => p.blocking && !p.passed)
                .map(p => p.explanation)
                .join(' ');
            return fail(400, { error: `Cannot promote: ${failingPrereqs}` });
        }

        // Execute promotion
        const fromCharacter = instance.epistemicCharacter;
        updateEpistemicCharacter(instance.id, 'production');
        recordTransition(
            instance.id,
            'epistemic',
            fromCharacter,
            'production',
            locals.user!.id,
            'Promoted to production'
        );

        throw redirect(303, `/domains/${domain.slug}/modules/${instance.id}`);
    }
};
