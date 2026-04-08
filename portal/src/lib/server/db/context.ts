import { v4 as uuidv4 } from 'uuid';
import db from './index.js';
import type { DomainContext, DomainContextRow, BmmConcern } from '$lib/types.js';
import { BMM_CONCERNS } from '$lib/types.js';

function mapContext(row: DomainContextRow): DomainContext {
    return {
        id: row.id,
        domainId: row.domain_id,
        concern: row.concern as BmmConcern,
        contextValues: JSON.parse(row.context_values) as Record<string, unknown>,
        updatedAt: row.updated_at
    };
}

export function getContextForDomain(domainId: string): DomainContext[] {
    const rows = db.prepare(
        'SELECT * FROM domain_context WHERE domain_id = ? ORDER BY concern'
    ).all(domainId) as DomainContextRow[];
    return rows.map(mapContext);
}

export function getContextByConcern(domainId: string, concern: BmmConcern): DomainContext | null {
    const row = db.prepare(
        'SELECT * FROM domain_context WHERE domain_id = ? AND concern = ?'
    ).get(domainId, concern) as DomainContextRow | undefined;
    return row ? mapContext(row) : null;
}

export function upsertContext(domainId: string, concern: BmmConcern, values: Record<string, unknown>): DomainContext {
    const existing = db.prepare(
        'SELECT id FROM domain_context WHERE domain_id = ? AND concern = ?'
    ).get(domainId, concern) as { id: string } | undefined;

    if (existing) {
        db.prepare(`
            UPDATE domain_context SET context_values = ?, updated_at = datetime('now')
            WHERE domain_id = ? AND concern = ?
        `).run(JSON.stringify(values), domainId, concern);
    } else {
        db.prepare(`
            INSERT INTO domain_context (id, domain_id, concern, context_values)
            VALUES (?, ?, ?, ?)
        `).run(uuidv4(), domainId, concern, JSON.stringify(values));
    }

    return mapContext(
        db.prepare('SELECT * FROM domain_context WHERE domain_id = ? AND concern = ?')
            .get(domainId, concern) as DomainContextRow
    );
}

export function initializeDomainContext(domainId: string): void {
    const insert = db.prepare(`
        INSERT OR IGNORE INTO domain_context (id, domain_id, concern, context_values)
        VALUES (?, ?, ?, '{}')
    `);
    const initAll = db.transaction(() => {
        for (const concern of BMM_CONCERNS) {
            insert.run(uuidv4(), domainId, concern);
        }
    });
    initAll();
}
