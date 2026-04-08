export interface User {
    id: string;
    email: string;
    displayName: string;
    createdAt: string;
    updatedAt: string;
}

export interface UserRow {
    id: string;
    email: string;
    display_name: string;
    password_hash: string;
    created_at: string;
    updated_at: string;
}

export interface Session {
    id: string;
    userId: string;
    expiresAt: string;
    createdAt: string;
}

export interface Domain {
    id: string;
    name: string;
    slug: string;
    description: string | null;
    businessType: string | null;
    status: 'setup' | 'active' | 'suspended' | 'archived';
    createdAt: string;
    updatedAt: string;
}

export interface DomainRow {
    id: string;
    name: string;
    slug: string;
    description: string | null;
    business_type: string | null;
    status: string;
    created_at: string;
    updated_at: string;
}

export interface DomainMembership {
    id: string;
    userId: string;
    domainId: string;
    role: 'super_admin' | 'admin' | 'member';
    createdAt: string;
}

export type DomainWithRole = Domain & { role: string };
