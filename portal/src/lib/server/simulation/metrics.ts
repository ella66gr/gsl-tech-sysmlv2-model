import db from '../db/index.js';
import { getInstanceById } from '../db/modules.js';
import type { RunMetrics, SimulationFidelity } from '$lib/types.js';
import { computeHealthScore } from '$lib/modules/metrics.js';

interface EventAggRow {
    event_type: string;
    event_count: number;
    total_amount: number | null;
}

/**
 * Compute metrics for a single target module from a specific simulation run.
 */
export function computeRunMetricsForModule(runId: string, targetModuleId: string, durationDays: number): RunMetrics {
    const instance = getInstanceById(targetModuleId);
    const moduleName = instance
        ? (instance.displayName || instance.definition.name)
        : targetModuleId.slice(0, 8);

    // Aggregate events by type for this target module in this run
    const rows = db.prepare(`
        SELECT
            event_type,
            COUNT(*) as event_count,
            SUM(CASE WHEN event_type = 'transaction' THEN json_extract(payload, '$.amount') ELSE NULL END) as total_amount
        FROM simulation_events
        WHERE run_id = ? AND target_module_id = ?
        GROUP BY event_type
    `).all(runId, targetModuleId) as EventAggRow[];

    let customerArrivals = 0;
    let transactions = 0;
    let transactionTotal = 0;
    let issuesRaised = 0;
    let resourceRequests = 0;

    for (const row of rows) {
        switch (row.event_type) {
            case 'customer_arrival':
                customerArrivals = row.event_count;
                break;
            case 'transaction':
                transactions = row.event_count;
                transactionTotal = row.total_amount ?? 0;
                break;
            case 'issue_raised':
                issuesRaised = row.event_count;
                break;
            case 'resource_request':
                resourceRequests = row.event_count;
                break;
        }
    }

    const totalEvents = customerArrivals + transactions + issuesRaised + resourceRequests;
    const avgTransactionValue = transactions > 0 ? transactionTotal / transactions : 0;
    const issueRate = durationDays > 0 ? issuesRaised / durationDays : 0;

    return {
        targetModuleId,
        targetModuleName: moduleName,
        totalEvents,
        customerArrivals,
        transactions,
        transactionTotal: Math.round(transactionTotal * 100) / 100,
        avgTransactionValue: Math.round(avgTransactionValue * 100) / 100,
        issuesRaised,
        issueRate: Math.round(issueRate * 100) / 100,
        resourceRequests,
        healthScore: computeHealthScore(issueRate, transactions, durationDays)
    };
}

/**
 * Get comparison results for a set of module IDs using the most recent completed run
 * that targets at least one of them.
 */
export function getComparisonResults(
    comparisonModuleIds: string[],
    domainId: string
): { metrics: RunMetrics[]; runName: string; runId: string; fidelity: SimulationFidelity; durationDays: number } | null {
    if (comparisonModuleIds.length === 0) return null;

    // Find the most recent completed run in this domain
    const run = db.prepare(`
        SELECT * FROM simulation_runs
        WHERE domain_id = ? AND status = 'completed'
        ORDER BY completed_at DESC
        LIMIT 1
    `).get(domainId) as any;

    if (!run) return null;

    const durationDays = run.config ? (JSON.parse(run.config).durationDays ?? 7) : 7;
    const fidelity = run.fidelity as SimulationFidelity;

    // Compute metrics for each comparison module
    const metrics = comparisonModuleIds.map(moduleId =>
        computeRunMetricsForModule(run.id, moduleId, durationDays)
    );

    return {
        metrics,
        runName: run.name,
        runId: run.id,
        fidelity,
        durationDays
    };
}
