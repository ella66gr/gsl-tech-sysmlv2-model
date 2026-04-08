import type { ModuleInstanceWithDefinition, ModuleConnection, ConcernCoverage, BmmConcern } from '$lib/types.js';
import { BMM_CONCERNS } from '$lib/types.js';
import { CONCERN_META } from '$lib/context/schemas.js';

/**
 * Find modules that share at least one BMM concern with the given module.
 * Only considers installed (non-trashed) modules.
 */
export function findConnectedModules(
    module: ModuleInstanceWithDefinition,
    allModules: ModuleInstanceWithDefinition[]
): ModuleConnection[] {
    const myConcerns = new Set(module.definition.bmmConcerns);
    const connections: ModuleConnection[] = [];

    for (const other of allModules) {
        if (other.id === module.id) continue;
        if (other.installationState === 'trashed') continue;

        const shared = other.definition.bmmConcerns.filter(c => myConcerns.has(c));
        if (shared.length > 0) {
            connections.push({ module: other, sharedConcerns: shared });
        }
    }

    return connections;
}

/**
 * Get BMM concern coverage for all installed modules in a domain.
 */
export function getConcernCoverage(
    modules: ModuleInstanceWithDefinition[]
): ConcernCoverage[] {
    const installed = modules.filter(m => m.installationState !== 'trashed');

    return BMM_CONCERNS.map(concern => {
        const meta = CONCERN_META[concern];
        const covered = installed.filter(m => m.definition.bmmConcerns.includes(concern));
        return {
            concern,
            label: meta.label,
            description: meta.description,
            modules: covered,
            covered: covered.length > 0
        };
    });
}

/**
 * Find BMM concerns not covered by any installed module.
 */
export function findConcernGaps(
    modules: ModuleInstanceWithDefinition[]
): BmmConcern[] {
    const coverage = getConcernCoverage(modules);
    return coverage.filter(c => !c.covered).map(c => c.concern);
}
