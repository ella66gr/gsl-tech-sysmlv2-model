/**
 * Reality context of a module instance (ADR-011 §4.2, S514; formerly
 * `epistemic_character`). It describes the declared context the module
 * instance runs in, not a record:
 *   - real:        a live service. Its records are real.
 *   - hypothesis:  a hypothesis instantiation. Its records are simulated.
 *   - simulation:  a simulation run. Its records are simulated.
 * Mode (real or simulated) on a record is set by the platform from the
 * declared context, never by a writer. Promotion behaviour is unchanged.
 * Display labels follow Ella's S514 decision: "Live Service" for real and
 * "Simulation" for simulated; they name the context, not the record type.
 * "Hypothesis" is the Portal's existing label for the hypothesis
 * instantiation, kept so the two simulated contexts stay distinguishable.
 */
import type { RealityContext, OperationalState } from '$lib/types.js';

export interface RealityContextDisplay {
    label: string;
    badgeColor: 'teal' | 'purple' | 'blue';
    dotClass: string;
    borderAccent: string;
    bgTint: string;
}

export function getRealityContextDisplay(character: RealityContext): RealityContextDisplay {
    switch (character) {
        case 'real':
            return {
                label: 'Live Service',
                badgeColor: 'teal',
                dotClass: 'bg-teal-500',
                borderAccent: 'border-l-teal-500',
                bgTint: 'bg-teal-50/30 dark:bg-teal-900/10'
            };
        case 'hypothesis':
            return {
                label: 'Hypothesis',
                badgeColor: 'purple',
                dotClass: 'bg-purple-500',
                borderAccent: 'border-l-purple-400',
                bgTint: 'bg-purple-50/30 dark:bg-purple-900/10'
            };
        case 'simulation':
            return {
                label: 'Simulation',
                badgeColor: 'blue',
                dotClass: 'bg-blue-500',
                borderAccent: 'border-l-blue-400',
                bgTint: 'bg-blue-50/30 dark:bg-blue-900/10'
            };
    }
}

/**
 * Reality context can only be changed while the module is in draft state.
 * Once activated, the context is locked until the module is reset to draft.
 */
export function canEditRealityContext(operationalState: OperationalState): boolean {
    return operationalState === 'draft';
}
