import { fail } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';
import { getRunsForDomain, startSimulationRun } from '$lib/server/simulation/index.js';
import { getInstancesForDomain } from '$lib/server/db/modules.js';

export const load: PageServerLoad = async ({ parent }) => {
    const { domain } = await parent();
    const runs = getRunsForDomain(domain.id);
    const modules = getInstancesForDomain(domain.id);

    // Separate modules by category for the creation form
    const generativeModules = modules.filter(m => m.definition.category === 'generative');
    const businessModules = modules.filter(m => m.definition.category === 'business');

    return { runs, generativeModules, businessModules, modules };
};

export const actions: Actions = {
    createRun: async ({ request, parent, locals }) => {
        const { domain } = await parent();
        const data = await request.formData();

        const name = (data.get('name') as string)?.trim();
        const generatorModuleId = data.get('generatorModuleId') as string;
        const targetModuleIdsRaw = data.getAll('targetModuleIds') as string[];
        const durationDays = parseInt(data.get('durationDays') as string, 10);

        // Validation
        if (!name) return fail(400, { error: 'Run name is required.' });
        if (!generatorModuleId) return fail(400, { error: 'Select a generator module.' });
        if (targetModuleIdsRaw.length === 0) return fail(400, { error: 'Select at least one target business module.' });
        if (!durationDays || durationDays < 1 || durationDays > 30) return fail(400, { error: 'Duration must be between 1 and 30 days.' });

        try {
            const run = startSimulationRun({
                domainId: domain.id,
                generatorModuleId,
                targetModuleIds: targetModuleIdsRaw,
                name,
                fidelity: domain.simulationFidelity,
                durationDays,
                userId: locals.user!.id
            });
            return { success: true, runId: run.id, eventCount: run.eventCount };
        } catch (err: any) {
            return fail(500, { error: `Simulation failed: ${err.message}` });
        }
    }
};
