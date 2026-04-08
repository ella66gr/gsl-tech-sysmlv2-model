import { v4 as uuidv4 } from 'uuid';
import db from './index.js';
import type { Domain, DomainRow, DomainWithRole } from '$lib/types.js';
import { initializeDomainContext } from './context.js';

function mapDomain(row: DomainRow): Domain {
    return {
        id: row.id,
        name: row.name,
        slug: row.slug,
        description: row.description,
        businessType: row.business_type,
        status: row.status as Domain['status'],
        createdAt: row.created_at,
        updatedAt: row.updated_at
    };
}

export function createDomain(
    name: string,
    slug: string,
    description: string | null,
    businessType: string | null
): Domain {
    const id = uuidv4();
    db.prepare(`
        INSERT INTO domains (id, name, slug, description, business_type)
        VALUES (?, ?, ?, ?, ?)
    `).run(id, name, slug, description, businessType);
    initializeDomainContext(id);
    return mapDomain(db.prepare('SELECT * FROM domains WHERE id = ?').get(id) as DomainRow);
}

export function getDomainBySlug(slug: string): Domain | null {
    const row = db.prepare('SELECT * FROM domains WHERE slug = ?').get(slug) as DomainRow | undefined;
    return row ? mapDomain(row) : null;
}

export function getDomainById(id: string): Domain | null {
    const row = db.prepare('SELECT * FROM domains WHERE id = ?').get(id) as DomainRow | undefined;
    return row ? mapDomain(row) : null;
}

export function getDomainsForUser(userId: string): DomainWithRole[] {
    const rows = db.prepare(`
        SELECT d.*, dm.role
        FROM domains d
        JOIN domain_memberships dm ON d.id = dm.domain_id
        WHERE dm.user_id = ?
        ORDER BY d.created_at DESC
    `).all(userId) as (DomainRow & { role: string })[];
    return rows.map(row => ({ ...mapDomain(row), role: row.role }));
}

export function updateDomain(
    id: string,
    fields: { name?: string; description?: string | null; businessType?: string | null }
): Domain {
    if (fields.name !== undefined) {
        db.prepare(`UPDATE domains SET name = ?, updated_at = datetime('now') WHERE id = ?`).run(fields.name, id);
    }
    if ('description' in fields) {
        db.prepare(`UPDATE domains SET description = ?, updated_at = datetime('now') WHERE id = ?`).run(fields.description ?? null, id);
    }
    if ('businessType' in fields) {
        db.prepare(`UPDATE domains SET business_type = ?, updated_at = datetime('now') WHERE id = ?`).run(fields.businessType ?? null, id);
    }
    return mapDomain(db.prepare('SELECT * FROM domains WHERE id = ?').get(id) as DomainRow);
}

export function isSlugAvailable(slug: string): boolean {
    const row = db.prepare('SELECT id FROM domains WHERE slug = ?').get(slug);
    return !row;
}
