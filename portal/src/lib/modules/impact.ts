import type { ModuleInstanceWithDefinition, LifecycleImpact, OperationalState } from '$lib/types.js';

/**
 * Actions that could affect connected modules.
 */
const IMPACTFUL_ACTIONS: OperationalState[] = ['stopped', 'paused'];

/**
 * Assess whether a lifecycle action on a module would affect connected modules.
 * An impact exists when:
 * - The target action is 'stop' or 'pause' (or trash, which auto-stops)
 * - Other modules sharing BMM concerns are in 'active' or 'paused' state
 */
export function assessLifecycleImpact(
    module: ModuleInstanceWithDefinition,
    targetState: OperationalState,
    allModules: ModuleInstanceWithDefinition[]
): LifecycleImpact {
    // Only warn for disruptive actions
    if (!IMPACTFUL_ACTIONS.includes(targetState)) {
        return { hasImpact: false, affectedModules: [] };
    }

    const myConcerns = new Set(module.definition.bmmConcerns);
    const affected: LifecycleImpact['affectedModules'] = [];

    for (const other of allModules) {
        if (other.id === module.id) continue;
        if (other.installationState === 'trashed') continue;
        // Only count modules that are currently active or paused
        if (other.operationalState !== 'active' && other.operationalState !== 'paused') continue;

        const shared = other.definition.bmmConcerns.filter(c => myConcerns.has(c));
        if (shared.length > 0) {
            affected.push({
                module: other,
                sharedConcerns: shared,
                currentState: other.operationalState
            });
        }
    }

    return {
        hasImpact: affected.length > 0,
        affectedModules: affected
    };
}
