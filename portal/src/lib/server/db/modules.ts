import { v4 as uuidv4 } from 'uuid';
import db from './index.js';
import type {
    ModuleDefinition,
    ModuleInstance,
    ModuleInstanceWithDefinition,
    ModuleStateTransition,
    OperationalState,
    InstallationState,
    ConfigFieldDefinition
} from '$lib/types.js';

// ── Row types ────────────────────────────────────────────────────────

interface DefinitionRow {
    id: string;
    name: string;
    slug: string;
    description: string;
    category: string;
    icon: string;
    bmm_concerns: string;
    config_schema: string;
    dependencies: string | null;
    sort_order: number;
}

interface InstanceRow {
    id: string;
    domain_id: string;
    definition_id: string;
    display_name: string;
    installation_state: string;
    operational_state: string;
    config_values: string;
    installed_by: string;
    installed_at: string;
    updated_at: string;
}

interface TransitionRow {
    id: string;
    module_instance_id: string;
    lifecycle_type: string;
    from_state: string;
    to_state: string;
    triggered_by: string;
    note: string | null;
    created_at: string;
}

// ── Mappers ──────────────────────────────────────────────────────────

function mapDefinition(row: DefinitionRow): ModuleDefinition {
    return {
        id: row.id,
        name: row.name,
        slug: row.slug,
        description: row.description,
        category: row.category as ModuleDefinition['category'],
        icon: row.icon,
        bmmConcerns: JSON.parse(row.bmm_concerns) as string[],
        configSchema: JSON.parse(row.config_schema) as ConfigFieldDefinition[],
        dependencies: row.dependencies ? JSON.parse(row.dependencies) as string[] : null,
        sortOrder: row.sort_order
    };
}

function mapInstance(row: InstanceRow): ModuleInstance {
    return {
        id: row.id,
        domainId: row.domain_id,
        definitionId: row.definition_id,
        displayName: row.display_name,
        installationState: row.installation_state as InstallationState,
        operationalState: row.operational_state as OperationalState,
        configValues: JSON.parse(row.config_values) as Record<string, unknown>,
        installedBy: row.installed_by,
        installedAt: row.installed_at,
        updatedAt: row.updated_at
    };
}

function mapTransition(row: TransitionRow): ModuleStateTransition {
    return {
        id: row.id,
        moduleInstanceId: row.module_instance_id,
        lifecycleType: row.lifecycle_type as ModuleStateTransition['lifecycleType'],
        fromState: row.from_state,
        toState: row.to_state,
        triggeredBy: row.triggered_by,
        note: row.note,
        createdAt: row.created_at
    };
}

// ── Definitions ──────────────────────────────────────────────────────

export function getAllDefinitions(): ModuleDefinition[] {
    const rows = db.prepare('SELECT * FROM module_definitions ORDER BY sort_order').all() as DefinitionRow[];
    return rows.map(mapDefinition);
}

export function getDefinitionBySlug(slug: string): ModuleDefinition | null {
    const row = db.prepare('SELECT * FROM module_definitions WHERE slug = ?').get(slug) as DefinitionRow | undefined;
    return row ? mapDefinition(row) : null;
}

export function getDefinitionById(id: string): ModuleDefinition | null {
    const row = db.prepare('SELECT * FROM module_definitions WHERE id = ?').get(id) as DefinitionRow | undefined;
    return row ? mapDefinition(row) : null;
}

// ── Instances ────────────────────────────────────────────────────────

export function getInstancesForDomain(domainId: string, includeTrash = false): ModuleInstanceWithDefinition[] {
    const query = includeTrash
        ? 'SELECT mi.*, md.name as def_name, md.slug as def_slug, md.description as def_desc, md.category as def_cat, md.icon as def_icon, md.bmm_concerns as def_bmm, md.config_schema as def_schema, md.dependencies as def_deps, md.sort_order as def_sort FROM module_instances mi JOIN module_definitions md ON mi.definition_id = md.id WHERE mi.domain_id = ? ORDER BY mi.installed_at ASC'
        : "SELECT mi.*, md.name as def_name, md.slug as def_slug, md.description as def_desc, md.category as def_cat, md.icon as def_icon, md.bmm_concerns as def_bmm, md.config_schema as def_schema, md.dependencies as def_deps, md.sort_order as def_sort FROM module_instances mi JOIN module_definitions md ON mi.definition_id = md.id WHERE mi.domain_id = ? AND mi.installation_state != 'trashed' ORDER BY mi.installed_at ASC";

    const rows = db.prepare(query).all(domainId) as (InstanceRow & {
        def_name: string; def_slug: string; def_desc: string; def_cat: string;
        def_icon: string; def_bmm: string; def_schema: string; def_deps: string | null; def_sort: number;
    })[];

    return rows.map(row => ({
        ...mapInstance(row),
        definition: mapDefinition({
            id: row.definition_id,
            name: row.def_name,
            slug: row.def_slug,
            description: row.def_desc,
            category: row.def_cat,
            icon: row.def_icon,
            bmm_concerns: row.def_bmm,
            config_schema: row.def_schema,
            dependencies: row.def_deps,
            sort_order: row.def_sort
        })
    }));
}

export function getInstanceById(id: string): ModuleInstanceWithDefinition | null {
    const row = db.prepare(`
        SELECT mi.*, md.name as def_name, md.slug as def_slug, md.description as def_desc, md.category as def_cat,
               md.icon as def_icon, md.bmm_concerns as def_bmm, md.config_schema as def_schema,
               md.dependencies as def_deps, md.sort_order as def_sort
        FROM module_instances mi
        JOIN module_definitions md ON mi.definition_id = md.id
        WHERE mi.id = ?
    `).get(id) as (InstanceRow & {
        def_name: string; def_slug: string; def_desc: string; def_cat: string;
        def_icon: string; def_bmm: string; def_schema: string; def_deps: string | null; def_sort: number;
    }) | undefined;

    if (!row) return null;

    return {
        ...mapInstance(row),
        definition: mapDefinition({
            id: row.definition_id,
            name: row.def_name,
            slug: row.def_slug,
            description: row.def_desc,
            category: row.def_cat,
            icon: row.def_icon,
            bmm_concerns: row.def_bmm,
            config_schema: row.def_schema,
            dependencies: row.def_deps,
            sort_order: row.def_sort
        })
    };
}

export function installModule(
    domainId: string,
    definitionId: string,
    displayName: string,
    userId: string
): ModuleInstance {
    const id = uuidv4();
    db.prepare(`
        INSERT INTO module_instances (id, domain_id, definition_id, display_name, installed_by)
        VALUES (?, ?, ?, ?, ?)
    `).run(id, domainId, definitionId, displayName, userId);
    return mapInstance(db.prepare('SELECT * FROM module_instances WHERE id = ?').get(id) as InstanceRow);
}

export function updateConfig(instanceId: string, configValues: Record<string, unknown>): ModuleInstance {
    db.prepare(`
        UPDATE module_instances SET config_values = ?, updated_at = datetime('now') WHERE id = ?
    `).run(JSON.stringify(configValues), instanceId);
    return mapInstance(db.prepare('SELECT * FROM module_instances WHERE id = ?').get(instanceId) as InstanceRow);
}

export function updateOperationalState(instanceId: string, newState: OperationalState): ModuleInstance {
    db.prepare(`
        UPDATE module_instances SET operational_state = ?, updated_at = datetime('now') WHERE id = ?
    `).run(newState, instanceId);
    return mapInstance(db.prepare('SELECT * FROM module_instances WHERE id = ?').get(instanceId) as InstanceRow);
}

export function updateInstallationState(instanceId: string, newState: InstallationState): ModuleInstance {
    db.prepare(`
        UPDATE module_instances SET installation_state = ?, updated_at = datetime('now') WHERE id = ?
    `).run(newState, instanceId);
    return mapInstance(db.prepare('SELECT * FROM module_instances WHERE id = ?').get(instanceId) as InstanceRow);
}

export function deleteInstance(instanceId: string): void {
    db.prepare('DELETE FROM module_state_transitions WHERE module_instance_id = ?').run(instanceId);
    db.prepare('DELETE FROM module_instances WHERE id = ?').run(instanceId);
}

// ── Transitions ──────────────────────────────────────────────────────

export function recordTransition(
    instanceId: string,
    lifecycleType: string,
    fromState: string,
    toState: string,
    userId: string,
    note?: string
): void {
    db.prepare(`
        INSERT INTO module_state_transitions (id, module_instance_id, lifecycle_type, from_state, to_state, triggered_by, note)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    `).run(uuidv4(), instanceId, lifecycleType, fromState, toState, userId, note ?? null);
}

export function getTransitionsForInstance(instanceId: string): ModuleStateTransition[] {
    const rows = db.prepare(`
        SELECT * FROM module_state_transitions WHERE module_instance_id = ? ORDER BY created_at ASC
    `).all(instanceId) as TransitionRow[];
    return rows.map(mapTransition);
}
