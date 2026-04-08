import { v4 as uuidv4 } from 'uuid';
import db from './index.js';
import type { DomainMembership, User, UserRow } from '$lib/types.js';

interface MembershipRow {
    id: string;
    user_id: string;
    domain_id: string;
    role: string;
    created_at: string;
}

function mapMembership(row: MembershipRow): DomainMembership {
    return {
        id: row.id,
        userId: row.user_id,
        domainId: row.domain_id,
        role: row.role as DomainMembership['role'],
        createdAt: row.created_at
    };
}

function mapUser(row: UserRow): User {
    return {
        id: row.id,
        email: row.email,
        displayName: row.display_name,
        createdAt: row.created_at,
        updatedAt: row.updated_at
    };
}

export function addMember(userId: string, domainId: string, role: string): DomainMembership {
    const id = uuidv4();
    db.prepare(`
        INSERT INTO domain_memberships (id, user_id, domain_id, role)
        VALUES (?, ?, ?, ?)
    `).run(id, userId, domainId, role);
    return mapMembership(db.prepare('SELECT * FROM domain_memberships WHERE id = ?').get(id) as MembershipRow);
}

export function getMembership(userId: string, domainId: string): DomainMembership | null {
    const row = db.prepare(`
        SELECT * FROM domain_memberships WHERE user_id = ? AND domain_id = ?
    `).get(userId, domainId) as MembershipRow | undefined;
    return row ? mapMembership(row) : null;
}

export function getMembersOfDomain(domainId: string): (User & { role: string })[] {
    const rows = db.prepare(`
        SELECT u.*, dm.role
        FROM users u
        JOIN domain_memberships dm ON u.id = dm.user_id
        WHERE dm.domain_id = ?
        ORDER BY dm.created_at ASC
    `).all(domainId) as (UserRow & { role: string })[];
    return rows.map(row => ({ ...mapUser(row), role: row.role }));
}

export function updateRole(userId: string, domainId: string, role: string): void {
    db.prepare(`
        UPDATE domain_memberships SET role = ? WHERE user_id = ? AND domain_id = ?
    `).run(role, userId, domainId);
}

export function removeMember(userId: string, domainId: string): void {
    db.prepare(`
        DELETE FROM domain_memberships WHERE user_id = ? AND domain_id = ?
    `).run(userId, domainId);
}
