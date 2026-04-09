import { fail } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';
import { getDomainBySlug } from '$lib/server/db/domains.js';
import { getInstancesForDomain } from '$lib/server/db/modules.js';
import { assessDomain } from '$lib/server/governance/index.js';
import { getMembership } from '$lib/server/db/memberships.js';
import type { GovernanceLevel } from '$lib/types.js';

export const load: PageServerLoad = async ({ parent }) => {
    const { domain } = await parent();
    const modules = getInstancesForDomain(domain.id);
    const assessments = assessDomain(modules, domain);

    // Summary counts
    const totalHard = assessments.reduce((s, a) => s + a.hardCount, 0);
    const totalHardSatisfied = assessments.reduce((s, a) => s + a.hardSatisfied, 0);
    const totalSoft = assessments.reduce((s, a) => s + a.softCount, 0);
    const totalSoftSatisfied = assessments.reduce((s, a) => s + a.softSatisfied, 0);
    const totalGraded = assessments.reduce((s, a) => s + a.gradedCount, 0);
    const totalGradedSatisfied = assessments.reduce((s, a) => s + a.gradedSatisfied, 0);

    return {
        assessments,
        modules,
        summary: {
            totalHard, totalHardSatisfied,
            totalSoft, totalSoftSatisfied,
            totalGraded, totalGradedSatisfied,
            allHardPassing: totalHard === totalHardSatisfied
        }
    };
};

export const actions: Actions = {
    updateGovernanceLevel: async ({ request, params, locals }) => {
        const domain = getDomainBySlug(params.slug);
        if (!domain) return fail(404, { error: 'Domain not found.' });

        const membership = getMembership(locals.user!.id, domain.id);
        if (!membership || membership.role !== 'super_admin') {
            return fail(403, { error: 'Only the domain owner can change governance settings.' });
        }

        const data = await request.formData();
        const level = data.get('governanceLevel') as string;
        if (level !== 'exploratory' && level !== 'advisory' && level !== 'enforced') {
            return fail(400, { error: 'Invalid governance level.' });
        }

        const { updateGovernanceLevel } = await import('$lib/server/db/domains.js');
        updateGovernanceLevel(domain.id, level as GovernanceLevel);
        return { success: true };
    }
};
