import { v4 as uuidv4 } from 'uuid';
import db from './index.js';
import type { User, UserRow } from '$lib/types.js';

function mapUser(row: UserRow): User {
    return {
        id: row.id,
        email: row.email,
        displayName: row.display_name,
        createdAt: row.created_at,
        updatedAt: row.updated_at
    };
}

export function createUser(email: string, displayName: string, passwordHash: string): User {
    const id = uuidv4();
    db.prepare(`
        INSERT INTO users (id, email, display_name, password_hash)
        VALUES (?, ?, ?, ?)
    `).run(id, email, displayName, passwordHash);
    return mapUser(db.prepare('SELECT * FROM users WHERE id = ?').get(id) as UserRow);
}

export function getUserByEmail(email: string): UserRow | null {
    return (db.prepare('SELECT * FROM users WHERE email = ?').get(email) as UserRow) ?? null;
}

export function getUserById(id: string): User | null {
    const row = db.prepare('SELECT * FROM users WHERE id = ?').get(id) as UserRow | undefined;
    return row ? mapUser(row) : null;
}

export function updateUser(id: string, fields: { displayName?: string; passwordHash?: string }): User {
    if (fields.displayName !== undefined) {
        db.prepare(`
            UPDATE users SET display_name = ?, updated_at = datetime('now') WHERE id = ?
        `).run(fields.displayName, id);
    }
    if (fields.passwordHash !== undefined) {
        db.prepare(`
            UPDATE users SET password_hash = ?, updated_at = datetime('now') WHERE id = ?
        `).run(fields.passwordHash, id);
    }
    return mapUser(db.prepare('SELECT * FROM users WHERE id = ?').get(id) as UserRow);
}
