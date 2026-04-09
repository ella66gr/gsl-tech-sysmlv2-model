import type {
    GovernanceConstraint,
    ConstraintResult,
    GovernanceAssessment,
    Domain,
    ModuleInstanceWithDefinition
} from '$lib/types.js';
import { getEvaluator } from './evaluators.js';

/**
 * Run all governance constraints for a single module instance.
 * Returns a GovernanceAssessment with individual results and summary counts.
 */
export function assessModule(
    instance: ModuleInstanceWithDefinition,
    domain: Domain,
    allModules: ModuleInstanceWithDefinition[]
): GovernanceAssessment {
    const constraints: GovernanceConstraint[] = instance.definition.governanceConstraints ?? [];
    const results: ConstraintResult[] = [];

    for (const constraint of constraints) {
        const evaluator = getEvaluator(constraint.evaluator);
        if (!evaluator) {
            results.push({
                constraint,
                satisfied: false,
                explanation: `Evaluator "${constraint.evaluator}" not found. This is a configuration error.`
            });
            continue;
        }

        try {
            const { satisfied, explanation } = evaluator({
                configValues: instance.configValues,
                domain,
                allModules
            });
            results.push({ constraint, satisfied, explanation });
        } catch (err) {
            results.push({
                constraint,
                satisfied: false,
                explanation: `Evaluator error: ${err instanceof Error ? err.message : 'Unknown error'}`
            });
        }
    }

    const hard = results.filter(r => r.constraint.level === 'hard');
    const soft = results.filter(r => r.constraint.level === 'soft');
    const graded = results.filter(r => r.constraint.level === 'graded');

    return {
        moduleInstanceId: instance.id,
        moduleName: instance.displayName || instance.definition.name,
        results,
        hardCount: hard.length,
        hardSatisfied: hard.filter(r => r.satisfied).length,
        softCount: soft.length,
        softSatisfied: soft.filter(r => r.satisfied).length,
        gradedCount: graded.length,
        gradedSatisfied: graded.filter(r => r.satisfied).length,
        overallPass: hard.every(r => r.satisfied)
    };
}

/**
 * Assess all installed (non-trashed) modules in a domain.
 */
export function assessDomain(
    modules: ModuleInstanceWithDefinition[],
    domain: Domain
): GovernanceAssessment[] {
    const installed = modules.filter(m => m.installationState === 'installed');
    return installed.map(m => assessModule(m, domain, installed));
}
