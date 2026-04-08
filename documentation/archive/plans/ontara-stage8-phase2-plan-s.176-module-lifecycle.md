---
tags:
  - plan
  - portal
  - implementation
date: 2026-04-08
status: active
session: 176
---
# Stage 8 Phase 2 — Module Lifecycle: Detailed Implementation Plan
> `= this.file.path`

**Session:** 176
**Date:** 8 April 2026
**Purpose:** Detailed implementation plan for Phase 2 of the Ontara Portal — module catalogue, installation, lifecycle management, and the dashboard as state landscape. Specifies every step with tool allocation and acceptance criteria, suitable for handing off to Claude Code.
**Status:** Complete. Implemented Session 176.
**Depends on:** [[ontara-stage8-plan-high-level-s.174-portal|Stage 8 High-Level Plan]] (§6), [[ontara-discussion-portal-state-driven-operator-experience-2026-04-08|Portal Discussion Paper]] (§5–§6), [[ontara-stage8-phase1-plan-s.175-empty-shell|Phase 1 Plan]] (complete)
**Work item:** [[ontara-ref-work-items|W-037]]

---

## Contents

- [[#1. Objective and Scope|§1. Objective and Scope]]
- [[#2. Prerequisite Reading|§2. Prerequisite Reading]]
- [[#3. Design Decisions|§3. Design Decisions]]
- [[#4. Database Schema Design|§4. Database Schema Design]]
- [[#5. Module Catalogue Definitions|§5. Module Catalogue Definitions]]
- [[#6. Lifecycle State Machines|§6. Lifecycle State Machines]]
- [[#7. Implementation Steps|§7. Implementation Steps]]
- [[#8. Route and Navigation Design|§8. Route and Navigation Design]]
- [[#9. Design Direction|§9. Design Direction]]
- [[#10. Acceptance Criteria|§10. Acceptance Criteria]]
- [[#11. Register Connections|§11. Register Connections]]
- [[#12. OW Items Addressed|§12. OW Items Addressed]]

---

## 1. Objective and Scope

Build the module lifecycle layer into the Ontara Portal:

1. **Module data model** — database tables for module definitions (catalogue) and module instances (installed), with lifecycle state tracking and transition history.
2. **Module catalogue** — 7 prototype module definitions representing business aspects mapped to BMM concerns. Browseable catalogue page with install action.
3. **Module installation and configuration** — install a module from catalogue into a domain; configure it through a dynamic schema-driven form.
4. **Module lifecycle management** — two intersecting state machines (installation and operational) with enforced legal transitions, status indicators, and transition history.
5. **Dashboard as state landscape** — the domain dashboard transforms from the Phase 1 empty shell into a living state landscape showing installed modules with their operational states, status badges, and available actions.

**Out of scope for Phase 2:** Module composition/wiring (Phase 3), simulation/comparison (Phase 4), governance integration (Phase 5), generative or analytical module *behaviour* (shell modules only — they have state but no internal business logic), real data generation, SSO/OAuth.

---

## 2. Prerequisite Reading

Code should read these files before starting implementation:

- `CLAUDE.md` at repo root — project context, portal tech stack, commands
- `portal/src/lib/types.ts` — existing TypeScript types
- `portal/src/lib/server/db/schema.sql` — existing database schema
- `portal/src/lib/server/db/domains.ts` — existing domain data access pattern (model for new module data access)
- `portal/src/routes/(app)/domains/[slug]/+page.svelte` — the current domain dashboard (will be substantially rewritten)
- `portal/src/routes/(app)/+layout.svelte` — the app shell layout (sidebar will gain new entries)
- `portal/src/app.css` — theme configuration (warm teal primary, warm gray secondary)

---

## 3. Design Decisions

### D1: Two intersecting lifecycles (resolves [[ontara-ref-work-items|OW-16]] for Phase 2)

Modules have **two independent state dimensions** tracked as separate columns:

- **Installation state:** `available` → `installed` → `trashed` (with restore). Governs whether the module exists in the operator's domain.
- **Operational state:** `draft` → `active` → `paused` → `stopped`. Governs what the module is doing. Only meaningful for installed modules.

The two lifecycles are independent but constrained: operational transitions are only legal when installation state is `installed`. Trashing an active module first stops it, then trashes it (compound transition). Restoring from trash returns to `stopped` state.

This is the simplest decomposition that captures the real distinction. A third lifecycle (epistemic — production/hypothesis/projection) is deferred to Phase 4.

Terminology note: the discussion paper uses "Edit mode" for the initial operational state. We use `draft` in the data model and display "Draft" in the UI — cleaner and more natural as a state name than "Edit."

### D2: Module taxonomy — 7 prototype definitions (addresses [[ontara-ref-work-items|OW-18]])

Seven hand-coded module definitions, deliberately spanning the BMM concern structure and including one analytical module to demonstrate the role taxonomy:

| # | Name | Role | Primary BMM Concern(s) | Icon |
|---|---|---|---|---|
| 1 | Service Offerings | Business | ServiceConcept | `TagOutline` |
| 2 | Customer Management | Business | StakeholderModel, ServiceConcept | `UsersOutline` |
| 3 | Scheduling & Workflow | Business | ActivityModel | `CalendarMonthOutline` |
| 4 | Team & Resources | Business | ResourcePlanning | `UserSettingsOutline` |
| 5 | Financial Tracking | Business | FinancialPlanning | `ChartOutline` |
| 6 | Compliance & Governance | Business | GovernanceMapping | `ShieldCheckOutline` |
| 7 | Business Overview | Analytical | Cross-cutting | `ChartMixedOutline` |

These are treated as empirical prototypes ([[ontara-ref-work-items|OW-18]]). The taxonomy will evolve. Generative modules are Phase 4 scope.

### D3: Configuration surface — schema-driven dynamic forms

Each module definition includes a `configSchema`: an array of field definitions. Each field has: `key` (string identifier), `type` (`text` | `number` | `boolean` | `select`), `label`, `description`, `defaultValue`, `required` (boolean), and for selects, `options` (array of `{value, label}`).

The configuration page renders this schema dynamically using standard Flowbite Svelte form components. Configuration values are stored as a JSON blob in the `module_instances` table.

This is simple, extensible, and non-constraining. A richer configuration surface (e.g. nested sections, conditional fields, validation rules) can replace it later by evolving the schema format — the storage and rendering pattern remain the same.

### D4: Dashboard transformation

The Phase 1 dashboard has a placeholder "No modules installed yet" card. Phase 2 replaces this with:

- **Module grid:** installed modules displayed as cards in a responsive grid. Each card shows: module name, icon, operational state badge (colour-coded), a brief status line, and available transition actions as buttons.
- **Quick actions:** "Browse Catalogue" button prominent when few modules installed; "Install Module" in the sidebar navigation.
- **Empty state preserved:** when no modules are installed, the current Phase 1 empty state card remains with a link to the catalogue.

The sidebar gains two new entries under the domain: **Catalogue** and (optionally) **Modules** as a dedicated list view distinct from the dashboard. For simplicity in Phase 2, the dashboard *is* the module view — no separate modules page. The sidebar gains only **Catalogue**.

### D5: Lifecycle transition history

Every state transition is recorded in a `module_state_transitions` table: module instance ID, from-state, to-state, lifecycle type (installation or operational), timestamp, and optional note. This provides full audit trail. The module detail panel shows the transition history as a timeline.

---

## 4. Database Schema Design

Three new tables added to `schema.sql`. Existing tables untouched.

### 4.1 `module_definitions` — the catalogue

```sql
CREATE TABLE IF NOT EXISTS module_definitions (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    description TEXT NOT NULL,
    category TEXT NOT NULL,           -- 'business' | 'analytical' | 'generative'
    icon TEXT NOT NULL,               -- Flowbite icon component name
    bmm_concerns TEXT NOT NULL,       -- JSON array of BMM concern names
    config_schema TEXT NOT NULL,      -- JSON array of field definitions
    dependencies TEXT,                -- JSON array of module definition slugs (nullable)
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
```

### 4.2 `module_instances` — installed modules

```sql
CREATE TABLE IF NOT EXISTS module_instances (
    id TEXT PRIMARY KEY,
    domain_id TEXT NOT NULL REFERENCES domains(id),
    definition_id TEXT NOT NULL REFERENCES module_definitions(id),
    display_name TEXT NOT NULL,       -- defaults to definition name, operator can rename
    installation_state TEXT NOT NULL DEFAULT 'installed',  -- installed | trashed
    operational_state TEXT NOT NULL DEFAULT 'draft',       -- draft | active | paused | stopped
    config_values TEXT NOT NULL DEFAULT '{}',              -- JSON object
    installed_by TEXT NOT NULL REFERENCES users(id),
    installed_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);
```

### 4.3 `module_state_transitions` — lifecycle history

```sql
CREATE TABLE IF NOT EXISTS module_state_transitions (
    id TEXT PRIMARY KEY,
    module_instance_id TEXT NOT NULL REFERENCES module_instances(id),
    lifecycle_type TEXT NOT NULL,     -- 'installation' | 'operational'
    from_state TEXT NOT NULL,
    to_state TEXT NOT NULL,
    triggered_by TEXT NOT NULL REFERENCES users(id),
    note TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
```

### 4.4 Seeding

Module definitions are seeded on database initialisation. A `seed.ts` file provides the 7 prototype definitions with their config schemas. The seed runs idempotently (INSERT OR IGNORE) at DB init time.

---

## 5. Module Catalogue Definitions

Each definition includes a config schema tailored to its business aspect. These are illustrative prototypes — enough to demonstrate the pattern, not production configurations.

### 5.1 Service Offerings
- **Config fields:** `serviceName` (text, required), `serviceType` (select: "Retail" / "Appointment" / "Subscription" / "Project"), `pricingModel` (select: "Fixed" / "Hourly" / "Tiered" / "Custom"), `description` (text)
- **BMM concerns:** ServiceConcept

### 5.2 Customer Management
- **Config fields:** `registrationType` (select: "Walk-in" / "Registered" / "Both"), `communicationPreference` (select: "Email" / "SMS" / "Both" / "None"), `retentionPolicy` (text)
- **BMM concerns:** StakeholderModel, ServiceConcept

### 5.3 Scheduling & Workflow
- **Config fields:** `schedulingMode` (select: "Appointment" / "Walk-in" / "Queue" / "Batch"), `defaultSlotMinutes` (number), `operatingHours` (text), `allowOverbooking` (boolean)
- **BMM concerns:** ActivityModel

### 5.4 Team & Resources
- **Config fields:** `teamSize` (number), `premisesType` (select: "Fixed" / "Mobile" / "Home-based" / "Shared"), `keyEquipment` (text), `skillTracking` (boolean)
- **BMM concerns:** ResourcePlanning

### 5.5 Financial Tracking
- **Config fields:** `currency` (select: "GBP" / "EUR" / "USD"), `vatRegistered` (boolean), `invoicingFrequency` (select: "Per-service" / "Weekly" / "Monthly"), `paymentMethods` (text)
- **BMM concerns:** FinancialPlanning

### 5.6 Compliance & Governance
- **Config fields:** `regulatoryBody` (text), `complianceLevel` (select: "Light" / "Standard" / "Sector-regulated"), `auditFrequency` (select: "Annual" / "Quarterly" / "Monthly" / "Continuous"), `dataProtectionOfficer` (boolean)
- **BMM concerns:** GovernanceMapping

### 5.7 Business Overview (Analytical)
- **Config fields:** `refreshInterval` (select: "Real-time" / "Hourly" / "Daily"), `metricsScope` (select: "All modules" / "Selected modules"), `comparisonMode` (boolean)
- **BMM concerns:** Cross-cutting

---

## 6. Lifecycle State Machines

### 6.1 Installation lifecycle

```
available ──[install]──▶ installed ──[trash]──▶ trashed
                              ◀──[restore]──
```

- `available`: exists only in the catalogue (not a row in `module_instances`)
- `installed`: a `module_instances` row exists
- `trashed`: soft-deleted, recoverable. `installation_state = 'trashed'`
- Restoring from trash sets `operational_state` to `stopped`

### 6.2 Operational lifecycle (when installation_state = 'installed')

```
draft ──[activate]──▶ active ──[pause]──▶ paused
  ▲                     │                    │
  │                     │     [resume]       │
  │                     │◀───────────────────┘
  │                     │
  │               [stop]│
  │                     ▼
  └──[reset]────── stopped
```

Legal transitions:

| From | To | Action verb | Description |
|---|---|---|---|
| draft | active | Activate | Start the module |
| active | paused | Pause | Suspend execution, preserve state |
| paused | active | Resume | Continue from paused state |
| active | stopped | Stop | Halt execution, retain state |
| paused | stopped | Stop | Halt from paused state |
| stopped | draft | Reset | Clear operational state, return to configuration |

Illegal transitions (enforced): draft→paused, draft→stopped, stopped→active (must reset to draft first, then activate), stopped→paused.

### 6.3 Compound transitions

- **Trash an active/paused module:** automatically stops first (records two transitions: operational stop, then installation trash)
- **Trash a draft module:** directly trashes (records installation trash only)

### 6.4 Transition validation

A `validateTransition(currentState, targetState, lifecycleType)` function enforces legality. Returns `{valid: boolean, reason?: string}`. Called in the API route before any state change. Invalid transitions return 400 with explanation.

---

## 7. Implementation Steps

### Step 2.0: Database schema extension + seed data [Code]

**What:** Extend `schema.sql` with the three new tables (§4). Create `portal/src/lib/server/db/seed.ts` with the 7 module definitions (§5). Modify `portal/src/lib/server/db/index.ts` to call the seed function after schema execution. Delete `portal/data/portal.db` so it re-creates with the new schema on next start.

**Acceptance criteria:**
- `pnpm dev` starts cleanly
- SQLite database contains all three new tables
- `module_definitions` table has 7 rows
- Existing auth and domain functionality unaffected

**Files to create:** `portal/src/lib/server/db/seed.ts`
**Files to modify:** `portal/src/lib/server/db/schema.sql`, `portal/src/lib/server/db/index.ts`
**Files to delete:** `portal/data/portal.db` (auto-recreated)

---

### Step 2.1: Types and lifecycle logic [Code]

**What:** Extend `portal/src/lib/types.ts` with module-related TypeScript types. Create `portal/src/lib/server/modules/lifecycle.ts` with the transition validation logic and state machine definitions.

**New types in `types.ts`:**

```typescript
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
```

**`lifecycle.ts` contents:** Legal transition maps for both lifecycles, `validateOperationalTransition()`, `validateInstallationTransition()`, display metadata per state (label, colour, available actions), the compound trash logic.

**Acceptance criteria:**
- All types compile with no errors
- `validateOperationalTransition('draft', 'active')` returns `{valid: true}`
- `validateOperationalTransition('stopped', 'active')` returns `{valid: false, reason: '...'}`
- Legal transition map is complete per §6.2

**Note (post-implementation):** Step 2.1 specified `$lib/server/modules/lifecycle.ts`. During implementation, this was discovered to cause a SvelteKit boundary violation ([[ontara-ref-work-items|OW-19]]) — the file was relocated to `$lib/modules/lifecycle.ts` (shared, accessible by both server and client code). Future portal plans should place shared pure logic in `$lib/` not `$lib/server/`.

**Files to create:** `portal/src/lib/server/modules/lifecycle.ts`
**Files to modify:** `portal/src/lib/types.ts`

---

### Step 2.2: Module data access layer [Code]

**What:** Create `portal/src/lib/server/db/modules.ts` — data access functions for module definitions and instances, following the same pattern as `domains.ts`.

**Functions required:**

```
// Definitions (catalogue)
getAllDefinitions(): ModuleDefinition[]
getDefinitionBySlug(slug: string): ModuleDefinition | null
getDefinitionById(id: string): ModuleDefinition | null

// Instances
getInstancesForDomain(domainId: string, includeTrash?: boolean): ModuleInstanceWithDefinition[]
getInstanceById(id: string): ModuleInstanceWithDefinition | null
installModule(domainId: string, definitionId: string, displayName: string, userId: string): ModuleInstance
updateConfig(instanceId: string, configValues: Record<string, unknown>): ModuleInstance
updateOperationalState(instanceId: string, newState: OperationalState): ModuleInstance
updateInstallationState(instanceId: string, newState: InstallationState): ModuleInstance

// Transitions
recordTransition(instanceId: string, lifecycleType: string, fromState: string, toState: string, userId: string, note?: string): void
getTransitionsForInstance(instanceId: string): ModuleStateTransition[]
```

Row mapping functions convert snake_case DB rows to camelCase TypeScript objects, JSON fields parsed.

**Acceptance criteria:**
- All functions work against the seeded database
- `getAllDefinitions()` returns 7 definitions
- `installModule()` creates a row with `installation_state = 'installed'`, `operational_state = 'draft'`
- `getInstancesForDomain()` excludes trashed by default, includes with flag

**Files to create:** `portal/src/lib/server/db/modules.ts`

---

### Step 2.3: Catalogue page [Code]

**What:** Create the module catalogue browsing page at `/domains/[slug]/catalogue`.

**Route:** `portal/src/routes/(app)/domains/[slug]/catalogue/+page.server.ts` and `+page.svelte`

**Page design:**
- Header: "Module Catalogue" with subtitle "Browse and install modules for your domain"
- Filter pills: "All", "Business", "Analytical" (filter by `category`)
- Module cards in a responsive grid (2 columns on md, 3 on lg). Each card shows:
  - Icon (from definition) + module name
  - Category badge (teal for Business, blue for Analytical)
  - BMM concern tags (small, muted)
  - Description text (2–3 lines)
  - "Install" button (primary teal) — or "Installed" badge if already installed in this domain
- Cards use `bg-white dark:bg-secondary-800` with `rounded-2xl border` matching the Phase 1 card style

**Server load:** Fetch all definitions + existing instances for this domain (to show installed status).

**Install action:** POST to `/domains/[slug]/catalogue` with `definitionId`. Server creates instance (via `installModule()`), records transition, redirects to the module's configure page.

**Sidebar update:** Add "Catalogue" entry to the sidebar in `(app)/+layout.svelte`, below Dashboard and above Settings. Icon: `GridPlusOutline`.

**Acceptance criteria:**
- Catalogue page shows 7 module cards
- Filter pills work (All / Business / Analytical)
- "Install" button creates a module instance and redirects to configure page
- Already-installed modules show "Installed" instead of "Install"
- Sidebar shows Catalogue link with active state highlighting

**Files to create:** `portal/src/routes/(app)/domains/[slug]/catalogue/+page.server.ts`, `+page.svelte`
**Files to modify:** `portal/src/routes/(app)/+layout.svelte` (sidebar entry)

---

### Step 2.4: Module configure page [Code]

**What:** Create the module configuration page at `/domains/[slug]/modules/[moduleId]/configure`.

**Route:** `portal/src/routes/(app)/domains/[slug]/modules/[moduleId]/configure/+page.server.ts` and `+page.svelte`

**Page design:**
- Header: module display name + definition name subtitle + operational state badge ("Draft")
- Config form rendered dynamically from the definition's `configSchema`:
  - `text` → Flowbite `Input`
  - `number` → Flowbite `Input` with `type="number"`
  - `boolean` → Flowbite `Toggle`
  - `select` → Flowbite `Select`
  - Each field shows label, description (as helper text), and required indicator
- "Save Configuration" button (primary) — POSTs config values
- "Back to Dashboard" link
- Side panel or section showing: module icon, category, BMM concerns, description from definition

**Server load:** Fetch the module instance (with definition) and current config values.

**Save action:** POST updates `config_values` in `module_instances`. Redirects back to the dashboard.

The configure page is accessible at any time for installed modules (not just draft). Configuration changes to active modules could be gated in future, but for the prototype they are always allowed.

**Acceptance criteria:**
- Config form renders correctly for all 7 module types
- Each field type renders with appropriate Flowbite component
- Save persists values to database
- Reloading shows saved values
- Page accessible for modules in any operational state

**Files to create:** `portal/src/routes/(app)/domains/[slug]/modules/[moduleId]/configure/+page.server.ts`, `+page.svelte`

---

### Step 2.5: Module detail panel / page [Code]

**What:** Create a module detail page at `/domains/[slug]/modules/[moduleId]` — the home for a specific module instance.

**Route:** `portal/src/routes/(app)/domains/[slug]/modules/[moduleId]/+page.server.ts` and `+page.svelte`

**Page design:**
- Header: module display name, definition name, operational state badge (colour-coded: teal for active, yellow for draft, orange for paused, red for stopped)
- **Lifecycle actions bar:** buttons for all legal transitions from current state. Each button shows the action verb and has an appropriate style:
  - Activate → primary teal button
  - Pause → yellow/warning button
  - Resume → primary teal button
  - Stop → red/danger button
  - Reset → outline/secondary button
  - Trash → red outline button (in a separate "danger zone" section)
- **Configuration summary:** key-value display of current config. "Edit Configuration" link → configure page
- **Lifecycle history timeline:** chronological list of all state transitions for this module, showing: timestamp, transition description ("Activated by Ella"), lifecycle type badge
- **Module info sidebar:** definition details, BMM concerns, category, installed date, installed by

**Lifecycle action handling:** Each action button POSTs to `/domains/[slug]/modules/[moduleId]` with `action` field. Server validates transition, updates state, records transition, returns updated page data.

**Acceptance criteria:**
- Detail page shows correct current state and available actions
- Clicking a legal transition changes the state and appears in history
- Clicking an illegal transition is not possible (button not rendered)
- Transition history shows all past transitions with timestamps
- Trash action redirects to dashboard; trashed modules not visible on dashboard
- Configure link works from detail page

**Files to create:** `portal/src/routes/(app)/domains/[slug]/modules/[moduleId]/+page.server.ts`, `+page.svelte`

---

### Step 2.6: Dashboard transformation — state landscape [Code]

**What:** Rewrite the domain dashboard page (`/domains/[slug]/+page.svelte`) to show installed modules as a state landscape.

**Server load update:** Fetch module instances for the domain (excluding trashed), with definitions.

**Page design — with modules installed:**
- **Module grid:** responsive grid of module cards (1 col sm, 2 cols md, 3 cols lg). Each card:
  - Top row: icon + display name + operational state badge
  - State badge colours: Draft = `yellow`, Active = `green`, Paused = `amber/orange`, Stopped = `red`
  - Middle: brief description from definition (1 line, truncated)
  - Bottom row: primary action button (the most natural next transition — "Activate" for draft, "Pause" for active, "Resume" for paused, "Reset" for stopped) + "•••" overflow for other actions
  - Click the card body (not the action button) → navigate to module detail page
  - Card border: subtle left border colour matching state (4px, uses state colour)
- **Summary bar** above the grid: "X modules · Y active · Z draft" — compact status counts
- **"Browse Catalogue" button** in the summary bar area, secondary style

**Page design — no modules installed (empty state):**
- Keep the existing Phase 1 "Your domain is ready" card
- Add a prominent "Browse Module Catalogue →" CTA button
- The sidebar Catalogue link is the persistent entry point

**Quick lifecycle actions on dashboard cards:** The primary action button on each card performs the most natural transition via a POST to the dashboard route itself (not navigating away). The dashboard re-renders with updated state. This gives the operator a fast feedback loop — they can activate, pause, and stop modules directly from the dashboard without visiting detail pages.

**Acceptance criteria:**
- Dashboard shows all installed (non-trashed) modules as cards
- Each card shows correct state with appropriate colour coding
- Primary action button on each card performs a lifecycle transition
- Card click navigates to module detail page
- Summary bar shows correct counts
- Empty state shows catalogue CTA
- Domain info sidebar (right column) preserved from Phase 1

**Files to modify:** `portal/src/routes/(app)/domains/[slug]/+page.server.ts`, `+page.svelte`

---

### Step 2.7: Trash management [Code]

**What:** Add a "Trash" section to the domain settings page, showing trashed modules with restore/permanent-delete options. Add trash count indicator.

**Route extension:** Add a section to `portal/src/routes/(app)/domains/[slug]/settings/+page.svelte` (or a sub-page).

**Design:**
- Section header "Trashed Modules" with count badge
- List of trashed modules: name, definition, trashed date, "Restore" button, "Delete Permanently" button (with confirmation)
- Restore sets `installation_state = 'installed'`, `operational_state = 'stopped'`, records transition
- Permanent delete removes the row from `module_instances` and its transitions (actual DELETE — this is prototype, not production data)

**Acceptance criteria:**
- Trashed modules appear in settings trash section
- Restore returns module to dashboard in stopped state
- Permanent delete removes all traces
- Trash count updates correctly

**Files to modify:** Domain settings page (server + svelte)

---

### Step 2.8: Sidebar navigation for modules [Code]

**What:** When the domain has installed modules, add a compact module list to the sidebar — below Dashboard, above Catalogue, above Settings. Each module shows as a small sidebar item with a state dot indicator.

**Design:**
- Under a "Modules" label (small caps, muted)
- Each module: 4px coloured dot (matching state) + display name (truncated)
- Click → module detail page
- Max ~8 items visible; if more, "+N more" link → dashboard
- Only shows when modules exist; hidden when domain is empty

This gives the operator fast navigation to any module from any page within the domain.

**Acceptance criteria:**
- Sidebar shows installed modules with state dots
- Dots match operational state colours
- Click navigates to module detail page
- Works correctly with 0, 1, 7 modules

**Files to modify:** `portal/src/routes/(app)/+layout.svelte`, `portal/src/routes/(app)/+layout.server.ts` (load modules for sidebar)

---

## 8. Route and Navigation Design

### 8.1 New routes

| Route | Purpose |
|---|---|
| `/domains/[slug]/catalogue` | Browse and install modules |
| `/domains/[slug]/modules/[moduleId]` | Module detail + lifecycle actions |
| `/domains/[slug]/modules/[moduleId]/configure` | Module configuration form |

### 8.2 Sidebar structure (within a domain)

1. **Dashboard** (`/domains/[slug]`) — GridOutline icon
2. **Modules section** — list of installed modules with state dots (when modules exist)
3. **Catalogue** (`/domains/[slug]/catalogue`) — GridPlusOutline icon
4. **Settings** (`/domains/[slug]/settings`) — CogOutline icon

### 8.3 Navigation flows

- **Install flow:** Dashboard → "Browse Catalogue" → Catalogue page → "Install" → Configure page → "Save" → Dashboard (module appears in grid)
- **Lifecycle flow:** Dashboard → click action button (state changes inline) or click card → Detail page → lifecycle actions
- **Configure flow:** Dashboard → click card → Detail page → "Edit Configuration" → Configure page → "Save" → Detail page

---

## 9. Design Direction

### 9.1 Visual language

Continue the Phase 1 warm teal theme. Module state is the primary visual variable:

| State | Badge colour | Dot colour | Border accent | Semantic |
|---|---|---|---|---|
| Draft | `yellow` | `bg-yellow-400` | `border-l-yellow-400` | Configuring, not yet live |
| Active | `green` | `bg-green-500` | `border-l-green-500` | Running |
| Paused | `orange` / `yellow` | `bg-orange-400` | `border-l-orange-400` | Suspended, state preserved |
| Stopped | `red` | `bg-red-400` | `border-l-red-400` | Halted |

BMM concern badges use muted teal tones to distinguish from state colours.

### 9.2 Component patterns

- Cards: `bg-white dark:bg-secondary-800 rounded-2xl border border-secondary-200 dark:border-secondary-700` (established Phase 1)
- Badges: Flowbite `Badge` component with colour coding
- Action buttons: primary teal for positive actions (activate, resume), yellow for caution (pause), red for destructive (stop, trash)
- Form fields: Flowbite Svelte form components (`Input`, `Select`, `Toggle`) — already styled for dark mode in `app.css`

### 9.3 Responsive behaviour

- Module grid: 1 column on small screens, 2 on md, 3 on lg
- Sidebar collapses on mobile (existing Phase 1 behaviour)
- Module cards stack naturally on narrow viewports

---

## 10. Acceptance Criteria

### Phase 2 overall criteria (from Stage 8 plan §6)

1. ✅ A module catalogue exists with prototype module definitions
2. ✅ An operator can install a module from the catalogue into a domain
3. ✅ An installed module can be configured through a configuration surface
4. ✅ Module lifecycle transitions work correctly: draft → activate → pause → stop → reset
5. ✅ The dashboard shows all installed modules with their current lifecycle state
6. ✅ Lifecycle transition history is recorded and visible
7. ✅ The module lifecycle state machines enforce legal transitions

### Additional Phase 2 criteria

8. Two intersecting lifecycles (installation + operational) are implemented and enforced
9. Trash management works with restore capability
10. Sidebar navigation shows modules with state indicators
11. The catalogue shows installed status for modules already in the domain
12. Module configuration is schema-driven and persists correctly

---

## 11. Register Connections

| Register concept | How exercised |
|---|---|
| [[principle-separation-representation-execution\|A1]] | Module configuration (representation) stored separately from lifecycle state (execution concern) |
| [[principle-self-describing-system\|A2]] | Module definitions carry descriptions; state badges convey meaning; transition history explains how modules reached current state |
| [[principle-model-generates-everything\|A3]] | Directional: module definitions are hand-coded prototypes; architecture (definition + instance pattern, config schema) supports future generation from SysML |
| [[principle-discipline-as-load-bearing-structure\|A9]] | Clean separation of concerns: types, lifecycle logic, data access, presentation |
| [[concept-co-evolution\|J2]] | Module data model + visible UI surfaces built together — no invisible infrastructure |
| [[concept-non-constraining\|J3]] | Config schema pattern is extensible; module taxonomy is additive; lifecycle state machine can be enriched without breaking existing states |
| [[concept-multi-tenancy\|A13]] | Modules are domain-scoped; catalogue is shared across all domains; multi-tenant from the start |

---

## 12. OW Items Addressed

| OW Item | How addressed |
|---|---|
| [[ontara-ref-work-items\|OW-16]] | Two intersecting lifecycles implemented (installation + operational). Further decomposition (epistemic) deferred to Phase 4 as planned |
| [[ontara-ref-work-items\|OW-18]] | Module taxonomy treated as empirical: 7 prototype definitions across 2 of 3 role types. Taxonomy designed to be extended, not locked |

---

*Phase 2 implementation plan produced Session 176, 8 April 2026.*
