CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    display_name TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS sessions (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL REFERENCES users(id),
    expires_at TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS domains (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    description TEXT,
    business_type TEXT,
    status TEXT NOT NULL DEFAULT 'setup',
    simulation_fidelity TEXT NOT NULL DEFAULT 'simplified',
    governance_level TEXT NOT NULL DEFAULT 'exploratory',
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS domain_memberships (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL REFERENCES users(id),
    domain_id TEXT NOT NULL REFERENCES domains(id),
    role TEXT NOT NULL DEFAULT 'member',
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    UNIQUE(user_id, domain_id)
);

CREATE TABLE IF NOT EXISTS module_definitions (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    description TEXT NOT NULL,
    category TEXT NOT NULL,
    icon TEXT NOT NULL,
    bmm_concerns TEXT NOT NULL,
    config_schema TEXT NOT NULL,
    governance_constraints TEXT NOT NULL DEFAULT '[]',
    dependencies TEXT,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS module_instances (
    id TEXT PRIMARY KEY,
    domain_id TEXT NOT NULL REFERENCES domains(id),
    definition_id TEXT NOT NULL REFERENCES module_definitions(id),
    display_name TEXT NOT NULL,
    installation_state TEXT NOT NULL DEFAULT 'installed',
    operational_state TEXT NOT NULL DEFAULT 'draft',
    epistemic_character TEXT NOT NULL DEFAULT 'production',
    config_values TEXT NOT NULL DEFAULT '{}',
    installed_by TEXT NOT NULL REFERENCES users(id),
    installed_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS module_state_transitions (
    id TEXT PRIMARY KEY,
    module_instance_id TEXT NOT NULL REFERENCES module_instances(id),
    lifecycle_type TEXT NOT NULL,
    from_state TEXT NOT NULL,
    to_state TEXT NOT NULL,
    triggered_by TEXT NOT NULL REFERENCES users(id),
    note TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS domain_context (
    id TEXT PRIMARY KEY,
    domain_id TEXT NOT NULL REFERENCES domains(id),
    concern TEXT NOT NULL,
    context_values TEXT NOT NULL DEFAULT '{}',
    updated_at TEXT NOT NULL DEFAULT (datetime('now')),
    UNIQUE(domain_id, concern)
);

-- Phase 4: Simulation and comparison

CREATE TABLE IF NOT EXISTS simulation_runs (
    id TEXT PRIMARY KEY,
    domain_id TEXT NOT NULL REFERENCES domains(id),
    name TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    fidelity TEXT NOT NULL,
    generator_module_id TEXT NOT NULL REFERENCES module_instances(id),
    target_module_ids TEXT NOT NULL,
    config TEXT NOT NULL DEFAULT '{}',
    event_count INTEGER NOT NULL DEFAULT 0,
    started_at TEXT,
    completed_at TEXT,
    created_by TEXT NOT NULL REFERENCES users(id),
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS simulation_events (
    id TEXT PRIMARY KEY,
    run_id TEXT NOT NULL REFERENCES simulation_runs(id),
    domain_id TEXT NOT NULL REFERENCES domains(id),
    event_type TEXT NOT NULL,
    source_module_id TEXT NOT NULL,
    target_module_id TEXT NOT NULL,
    payload TEXT NOT NULL DEFAULT '{}',
    simulated_at TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_sim_events_run ON simulation_events(run_id);
CREATE INDEX IF NOT EXISTS idx_sim_events_target ON simulation_events(target_module_id, run_id);
