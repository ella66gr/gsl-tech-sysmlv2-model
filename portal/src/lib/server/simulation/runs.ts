import { v4 as uuidv4 } from 'uuid';
import db from '../db/index.js';
import type { SimulationRun, SimulationFidelity, SimulationRunStatus } from '$lib/types.js';

// ── Row type ─────────────────────────────────────────────────────────

interface RunRow {
    id: string;
    domain_id: string;
    name: string;
    status: string;
    fidelity: string;
    generator_module_id: string;
    target_module_ids: string;
    config: string;
    event_count: number;
    started_at: string | null;
    completed_at: string | null;
    created_by: string;
    created_at: string;
}

function mapRun(row: RunRow): SimulationRun {
    return {
        id: row.id,
        domainId: row.domain_id,
        name: row.name,
        status: row.status as SimulationRunStatus,
        fidelity: row.fidelity as SimulationFidelity,
        generatorModuleId: row.generator_module_id,
        targetModuleIds: JSON.parse(row.target_module_ids) as string[],
        config: JSON.parse(row.config) as Record<string, unknown>,
        eventCount: row.event_count,
        startedAt: row.started_at,
        completedAt: row.completed_at,
        createdBy: row.created_by,
        createdAt: row.created_at
    };
}

// ── CRUD ─────────────────────────────────────────────────────────────

export function createRun(
    domainId: string,
    generatorModuleId: string,
    targetModuleIds: string[],
    name: string,
    fidelity: SimulationFidelity,
    config: Record<string, unknown>,
    userId: string
): SimulationRun {
    const id = uuidv4();
    db.prepare(`
        INSERT INTO simulation_runs
            (id, domain_id, name, status, fidelity, generator_module_id, target_module_ids, config, created_by)
        VALUES (?, ?, ?, 'pending', ?, ?, ?, ?, ?)
    `).run(id, domainId, name, fidelity, generatorModuleId, JSON.stringify(targetModuleIds), JSON.stringify(config), userId);
    return mapRun(db.prepare('SELECT * FROM simulation_runs WHERE id = ?').get(id) as RunRow);
}

export function getRunsForDomain(domainId: string): SimulationRun[] {
    const rows = db.prepare(
        'SELECT * FROM simulation_runs WHERE domain_id = ? ORDER BY created_at DESC'
    ).all(domainId) as RunRow[];
    return rows.map(mapRun);
}

export function getRunById(runId: string): SimulationRun | null {
    const row = db.prepare('SELECT * FROM simulation_runs WHERE id = ?').get(runId) as RunRow | undefined;
    return row ? mapRun(row) : null;
}

export function updateRunStatus(runId: string, status: SimulationRunStatus): void {
    const now = new Date().toISOString();
    if (status === 'running') {
        db.prepare('UPDATE simulation_runs SET status = ?, started_at = ? WHERE id = ?').run(status, now, runId);
    } else if (status === 'completed') {
        db.prepare('UPDATE simulation_runs SET status = ?, completed_at = ? WHERE id = ?').run(status, now, runId);
    } else {
        db.prepare('UPDATE simulation_runs SET status = ? WHERE id = ?').run(status, runId);
    }
}

export function updateRunEventCount(runId: string, count: number): void {
    db.prepare('UPDATE simulation_runs SET event_count = ? WHERE id = ?').run(count, runId);
}

export function cancelRun(runId: string): void {
    updateRunStatus(runId, 'cancelled');
}
