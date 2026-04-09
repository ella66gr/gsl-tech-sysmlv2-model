import { createRun, getRunById, updateRunStatus, updateRunEventCount } from './runs.js';
import { generateEvents } from './generator.js';
import { getInstanceById } from '../db/modules.js';
import type { SimulationFidelity, SimulationRun } from '$lib/types.js';

export { createRun, getRunsForDomain, getRunById, cancelRun } from './runs.js';

interface StartRunParams {
    domainId: string;
    generatorModuleId: string;
    targetModuleIds: string[];
    name: string;
    fidelity: SimulationFidelity;
    durationDays: number;
    userId: string;
}

/**
 * Create and immediately execute a simulation run.
 * Events are generated synchronously in batch.
 * Returns the completed run.
 */
export function startSimulationRun(params: StartRunParams): SimulationRun {
    const { domainId, generatorModuleId, targetModuleIds, name, fidelity, durationDays, userId } = params;

    // Get the generator instance to find its definition ID and config
    const generatorInstance = getInstanceById(generatorModuleId);
    if (!generatorInstance) throw new Error(`Generator module instance ${generatorModuleId} not found`);

    // Create the run record
    const run = createRun(
        domainId,
        generatorModuleId,
        targetModuleIds,
        name,
        fidelity,
        { durationDays },
        userId
    );

    // Mark as running
    updateRunStatus(run.id, 'running');

    try {
        // Generate all events in batch
        const eventCount = generateEvents(
            run.id,
            domainId,
            generatorModuleId,
            targetModuleIds,
            generatorInstance.definitionId,
            generatorInstance.configValues as Record<string, unknown>,
            fidelity,
            durationDays
        );

        // Update run with event count and mark completed
        updateRunEventCount(run.id, eventCount);
        updateRunStatus(run.id, 'completed');
    } catch (err) {
        // On failure, cancel the run
        updateRunStatus(run.id, 'cancelled');
        throw err;
    }

    // Return the fully updated run
    return getRunById(run.id)!;
}
