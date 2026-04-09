import type {
    ModuleInstanceWithDefinition,
    Domain,
    GovernanceAssessment
} from '$lib/types.js';
import { assessModule } from './assess.js';

export interface PromotionPrerequisite {
    id: string;
    label: string;
    passed: boolean;
    blocking: boolean;
    explanation: string;
}

export interface PromotionReadiness {
    canPromote: boolean;
    prerequisites: PromotionPrerequisite[];
    assessment: GovernanceAssessment;
}

export function evaluatePromotionReadiness(
    instance: ModuleInstanceWithDefinition,
    domain: Domain,
    allModules: ModuleInstanceWithDefinition[]
): PromotionReadiness {
    const prerequisites: PromotionPrerequisite[] = [];

    // P1: Not already production
    const isNonProduction = instance.epistemicCharacter !== 'production';
    prerequisites.push({
        id: 'P1',
        label: 'Module is not already in production',
        passed: isNonProduction,
        blocking: true,
        explanation: isNonProduction
            ? `Current epistemic character: ${instance.epistemicCharacter}.`
            : 'This module is already in production.'
    });

    // P2: Module must be active
    const isActive = instance.operationalState === 'active';
    prerequisites.push({
        id: 'P2',
        label: 'Module is active',
        passed: isActive,
        blocking: true,
        explanation: isActive
            ? 'Module is in active operational state.'
            : `Module operational state is "${instance.operationalState}". Only active modules can be promoted.`
    });

    // P3: Domain governance level must be enforced
    const isEnforced = domain.governanceLevel === 'enforced';
    prerequisites.push({
        id: 'P3',
        label: 'Domain governance level is Enforced',
        passed: isEnforced,
        blocking: true,
        explanation: isEnforced
            ? 'Domain governance is set to Enforced.'
            : `Domain governance level is "${domain.governanceLevel}". Must be set to Enforced before promotion.`
    });

    // P4: All hard constraints satisfied
    const assessment = assessModule(instance, domain, allModules);
    prerequisites.push({
        id: 'P4',
        label: 'All hard constraints satisfied',
        passed: assessment.overallPass,
        blocking: true,
        explanation: assessment.overallPass
            ? `All ${assessment.hardCount} hard constraint${assessment.hardCount !== 1 ? 's' : ''} satisfied.`
            : `${assessment.hardCount - assessment.hardSatisfied} of ${assessment.hardCount} hard constraint${assessment.hardCount !== 1 ? 's' : ''} not satisfied.`
    });

    // P5: Connected modules coherence check (warning, not blocking)
    const sharedConcernModules = allModules.filter(m =>
        m.id !== instance.id &&
        m.installationState === 'installed' &&
        m.operationalState === 'active' &&
        m.epistemicCharacter !== 'production' &&
        m.definition.bmmConcerns.some(c => instance.definition.bmmConcerns.includes(c))
    );

    if (sharedConcernModules.length > 0) {
        const names = sharedConcernModules.map(m => m.displayName || m.definition.name);
        prerequisites.push({
            id: 'P5',
            label: 'Connected modules coherence',
            passed: false,
            blocking: false,
            explanation: `${names.join(', ')} share${names.length === 1 ? 's' : ''} BMM concerns with this module and ${names.length === 1 ? 'is' : 'are'} not yet in production. Consider promoting ${names.length === 1 ? 'it' : 'them'} too.`
        });
    } else {
        prerequisites.push({
            id: 'P5',
            label: 'Connected modules coherence',
            passed: true,
            blocking: false,
            explanation: 'All connected active modules are already in production (or no active connected modules exist).'
        });
    }

    const canPromote = prerequisites.filter(p => p.blocking).every(p => p.passed);

    return { canPromote, prerequisites, assessment };
}
