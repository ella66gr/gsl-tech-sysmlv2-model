import type { ModuleInstanceWithDefinition, Domain, GovernanceLevel } from '$lib/types.js';
import { assessModule } from './assess.js';

export interface ActivationGuardResult {
    allowed: boolean;
    level: GovernanceLevel;
    warning: boolean;
    hardFailing: number;
    hardTotal: number;
    explanation: string;
}

/**
 * Check whether a draft→active transition is permitted under the current
 * governance level. Returns the guard result with enough information for
 * the UI to show appropriate feedback.
 *
 * - exploratory: always allowed, no check
 * - advisory: always allowed, but warns if hard constraints fail
 * - enforced: blocked if any hard constraint fails
 */
export function checkActivationGovernance(
    instance: ModuleInstanceWithDefinition,
    domain: Domain,
    allModules: ModuleInstanceWithDefinition[]
): ActivationGuardResult {
    if (domain.governanceLevel === 'exploratory') {
        return {
            allowed: true,
            level: 'exploratory',
            warning: false,
            hardFailing: 0,
            hardTotal: 0,
            explanation: 'Governance is exploratory — no constraints checked.'
        };
    }

    const assessment = assessModule(instance, domain, allModules);
    const hardFailing = assessment.hardCount - assessment.hardSatisfied;

    if (domain.governanceLevel === 'advisory') {
        return {
            allowed: true,
            level: 'advisory',
            warning: hardFailing > 0,
            hardFailing,
            hardTotal: assessment.hardCount,
            explanation: hardFailing > 0
                ? `${hardFailing} hard constraint${hardFailing !== 1 ? 's' : ''} not satisfied. Proceeding with caution.`
                : `All ${assessment.hardCount} hard constraint${assessment.hardCount !== 1 ? 's' : ''} satisfied.`
        };
    }

    // enforced
    return {
        allowed: assessment.overallPass,
        level: 'enforced',
        warning: false,
        hardFailing,
        hardTotal: assessment.hardCount,
        explanation: assessment.overallPass
            ? `All ${assessment.hardCount} hard constraint${assessment.hardCount !== 1 ? 's' : ''} satisfied.`
            : `Cannot activate: ${hardFailing} hard constraint${hardFailing !== 1 ? 's' : ''} not satisfied.`
    };
}
