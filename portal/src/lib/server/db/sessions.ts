import { v4 as uuidv4 } from 'uuid';
import db from './index.js';
import type { Session, User, UserRow } from '$lib/types.js';

interface SessionRow {
    id: string;
    user_id: string;
    expires_at: string;
    created_at: string;
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

export function createSession(userId: string): Session {
    const id = uuidv4();
    const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString();
    db.prepare(`
        INSERT INTO sessions (id, user_id, expires_at)
        VALUES (?, ?, ?)
    `).run(id, userId, expiresAt);
    return { id, userId, expiresAt, createdAt: new Date().toISOString() };
}

export function getValidSession(token: string): { session: Session; user: User } | null {
    const row = db.prepare(`
        SELECT s.id, s.user_id, s.expires_at, s.created_at,
               u.id as u_id, u.email, u.display_name, u.password_hash, u.created_at as u_created_at, u.updated_at as u_updated_at
        FROM sessions s
        JOIN users u ON s.user_id = u.id
        WHERE s.id = ? AND s.expires_at > datetime('now')
    `).get(token) as (SessionRow & { u_id: string; email: string; display_name: string; password_hash: string; u_created_at: string; u_updated_at: string }) | undefined;

    if (!row) return null;

    return {
        session: {
            id: row.id,
            userId: row.user_id,
            expiresAt: row.expires_at,
            createdAt: row.created_at
        },
        user: mapUser({
            id: row.u_id,
            email: row.email,
            display_name: row.display_name,
            password_hash: row.password_hash,
            created_at: row.u_created_at,
            updated_at: row.u_updated_at
        })
    };
}

export function deleteSession(token: string): void {
    db.prepare('DELETE FROM sessions WHERE id = ?').run(token);
}

export function deleteExpiredSessions(): void {
    db.prepare("DELETE FROM sessions WHERE expires_at <= datetime('now')").run();
}
