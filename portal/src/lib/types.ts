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

// ── Module types ────────────────────────────────────────────────────

export type ModuleCategory = 'business' | 'analytical' | 'generative';
export type InstallationState = 'installed' | 'trashed';
export type OperationalState = 'draft' | 'active' | 'paused' | 'stopped';

export interface ConfigFieldDefinition {
    key: string;
    type: 'text' | 'number' | 'boolean' | 'select';
    label: string;
    description: string;
    defaultValue: string | number | boolean;
    required: boolean;
    options?: { value: string; label: string }[];
}

export interface ModuleDefinition {
    id: string;
    name: string;
    slug: string;
    description: string;
    category: ModuleCategory;
    icon: string;
    bmmConcerns: string[];
    configSchema: ConfigFieldDefinition[];
    dependencies: string[] | null;
    sortOrder: number;
}

export interface ModuleInstance {
    id: string;
    domainId: string;
    definitionId: string;
    displayName: string;
    installationState: InstallationState;
    operationalState: OperationalState;
    configValues: Record<string, unknown>;
    installedBy: string;
    installedAt: string;
    updatedAt: string;
}

export interface ModuleInstanceWithDefinition extends ModuleInstance {
    definition: ModuleDefinition;
}

export interface ModuleStateTransition {
    id: string;
    moduleInstanceId: string;
    lifecycleType: 'installation' | 'operational';
    fromState: string;
    toState: string;
    triggeredBy: string;
    note: string | null;
    createdAt: string;
}

// ── Domain context types ─────────────────────────────────────────────

export type BmmConcern = 'ServiceConcept' | 'ActivityModel' | 'ResourcePlanning'
    | 'FinancialPlanning' | 'GovernanceMapping' | 'StakeholderModel';

export const BMM_CONCERNS: BmmConcern[] = [
    'ServiceConcept', 'ActivityModel', 'ResourcePlanning',
    'FinancialPlanning', 'GovernanceMapping', 'StakeholderModel'
];

export interface DomainContext {
    id: string;
    domainId: string;
    concern: BmmConcern;
    contextValues: Record<string, unknown>;
    updatedAt: string;
}

export interface DomainContextRow {
    id: string;
    domain_id: string;
    concern: string;
    context_values: string;
    updated_at: string;
}

// ── Module connection types ──────────────────────────────────────────

export interface ModuleConnection {
    module: ModuleInstanceWithDefinition;
    sharedConcerns: string[];
}

export interface ConcernCoverage {
    concern: BmmConcern;
    label: string;
    description: string;
    modules: ModuleInstanceWithDefinition[];
    covered: boolean;
}

export interface LifecycleImpact {
    hasImpact: boolean;
    affectedModules: {
        module: ModuleInstanceWithDefinition;
        sharedConcerns: string[];
        currentState: string;
    }[];
}
