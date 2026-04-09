import type { EpistemicCharacter, OperationalState } from '$lib/types.js';

export interface EpistemicDisplay {
    label: string;
    badgeColor: 'teal' | 'purple' | 'blue';
    dotClass: string;
    borderAccent: string;
    bgTint: string;
}

export function getEpistemicDisplay(character: EpistemicCharacter): EpistemicDisplay {
    switch (character) {
        case 'production':
            return {
                label: 'Production',
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
        case 'projection':
            return {
                label: 'Projection',
                badgeColor: 'blue',
                dotClass: 'bg-blue-500',
                borderAccent: 'border-l-blue-400',
                bgTint: 'bg-blue-50/30 dark:bg-blue-900/10'
            };
    }
}

/**
 * Epistemic character can only be changed while the module is in draft state.
 * Once activated, the character is locked until the module is reset to draft.
 */
export function canEditEpistemic(operationalState: OperationalState): boolean {
    return operationalState === 'draft';
}
