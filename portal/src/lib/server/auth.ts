import bcrypt from 'bcryptjs';
import type { Cookies } from '@sveltejs/kit';

const SALT_ROUNDS = 12;
const SESSION_COOKIE = 'portal_session';
const SESSION_MAX_AGE = 60 * 60 * 24 * 7; // 7 days in seconds

export async function hashPassword(password: string): Promise<string> {
    return bcrypt.hash(password, SALT_ROUNDS);
}

export async function verifyPassword(password: string, hash: string): Promise<boolean> {
    return bcrypt.compare(password, hash);
}

export function setSessionCookie(cookies: Cookies, token: string): void {
    cookies.set(SESSION_COOKIE, token, {
        path: '/',
        httpOnly: true,
        sameSite: 'lax',
        secure: false, // Set to true in production
        maxAge: SESSION_MAX_AGE
    });
}

export function getSessionToken(cookies: Cookies): string | undefined {
    return cookies.get(SESSION_COOKIE);
}

export function clearSessionCookie(cookies: Cookies): void {
    cookies.delete(SESSION_COOKIE, { path: '/' });
}
