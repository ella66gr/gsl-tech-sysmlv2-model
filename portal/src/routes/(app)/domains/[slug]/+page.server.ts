import { fail } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';
import { getMembersOfDomain } from '$lib/server/db/memberships';
import { getInstancesForDomain, updateOperationalState, recordTransition } from '$lib/server/db/modules';
import { getDomainBySlug } from '$lib/server/db/domains';
import { validateOperationalTransition } from '$lib/modules/lifecycle';
import { getRunsForDomain } from '$lib/server/simulation/index.js';
import { assessDomain } from '$lib/server/governance/index.js';
import type { OperationalState } from '$lib/types';

export const load: PageServerLoad = async ({ parent }) => {
    const { domain } = await parent();
    const members = getMembersOfDomain(domain.id);
    const modules = getInstancesForDomain(domain.id);
    const allRuns = getRunsForDomain(domain.id);
    const runs = allRuns.filter(r => r.status === 'completed');

    // Governance summary for dashboard indicators
    const assessments = assessDomain(modules, domain);
    const governanceSummary = new Map<string, { overallPass: boolean; hardFailing: number }>();
    for (const a of assessments) {
        governanceSummary.set(a.moduleInstanceId, {
            overallPass: a.overallPass,
            hardFailing: a.hardCount - a.hardSatisfied
        });
    }

    return { members, modules, runs, governanceSummary: Object.fromEntries(governanceSummary) };
};

export const actions: Actions = {
    transition: async ({ request, params, locals }) => {
        const domain = getDomainBySlug(params.slug);
        if (!domain) return fail(404, { error: 'Domain not found.' });

        const data = await request.formData();
        const moduleId = data.get('moduleId') as string;
        const targetState = data.get('targetState') as OperationalState;
        const confirmed = data.get('confirmed') === 'true';

        const modules = getInstancesForDomain(domain.id);
        const instance = modules.find(m => m.id === moduleId);
        if (!instance) return fail(404, { error: 'Module not found.' });

        const result = validateOperationalTransition(instance.operationalState, targetState);
        if (!result.valid) return fail(400, { error: result.reason });

        // Check for impact on connected modules
        if (!confirmed) {
            const { assessLifecycleImpact } = await import('$lib/modules/impact.js');
            const impact = assessLifecycleImpact(instance, targetState, modules);
            if (impact.hasImpact) {
                return {
                    confirmNeeded: true,
                    moduleId,
                    moduleName: instance.displayName || instance.definition.name,
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
        recordTransition(instance.id, 'operational', fromState, targetState, locals.user!.id);
        return {};
    }
};
