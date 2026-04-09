---
tags:
  - plan
  - portal
  - implementation
date: 2026-04-09
status: active
session: 179
---
# Stage 8 Phase 4 — Simulation and Comparison: Detailed Implementation Plan
> `= this.file.path`

**Date:** 9 April 2026 (Session 179)
**Purpose:** Detailed implementation plan for Phase 4 of Stage 8 (Ontara Portal). Resolves the open design questions from the high-level plan §8 and §14 (Phase 4) through analysis of the Phase 3 codebase and the discussion paper's epistemic dimension concept. Specifies step-by-step implementation for Claude Code execution.
**Status:** Active. Produced as Session 179 deliverable.
**Depends on:** [[ontara-stage8-plan-high-level-s.174-portal|Stage 8 High-Level Plan (Session 174)]], [[ontara-discussion-portal-state-driven-operator-experience-2026-04-08|Portal Discussion Paper §8]], [[ontara-stage8-plan-phase3-s.177-domain-context|Phase 3 Plan (Session 177)]], Phase 3 codebase (Session 178)

---

## Contents

- [[#1. Objective and Scope|§1. Objective and Scope]]
- [[#2. Design Decisions|§2. Design Decisions]]
- [[#3. What Exists After Phase 3|§3. What Exists After Phase 3]]
- [[#4. The Simulation Data Architecture|§4. The Simulation Data Architecture]]
- [[#5. Implementation Steps|§5. Implementation Steps]]
- [[#6. Database Schema Changes|§6. Database Schema Changes]]
- [[#7. New Types|§7. New Types]]
- [[#8. New Module Definitions|§8. New Module Definitions]]
- [[#9. Success Criteria|§9. Success Criteria]]
- [[#10. OW Items to Check During Implementation|§10. OW Items to Check During Implementation]]
- [[#11. Session Estimate and Phasing|§11. Session Estimate and Phasing]]
- [[#12. Register Connections|§12. Register Connections]]

---

## 1. Objective and Scope

Phase 4 delivers the epistemic dimension and comparative experimentation. After Phase 4, the operator can:

1. **Create variant module instances** — duplicate a configured business module with different assumptions to create siblings for comparison.
2. **Tag module instances with epistemic character** — distinguish between production-track, hypothesis, and projection instances. The dashboard visually distinguishes these.
3. **Activate generative modules** that produce synthetic business events (customer arrivals, transactions, issues) into a shared simulation event stream.
4. **Wire analytical modules** to business module instances and see comparative metrics across sibling variants.
5. **Adjust simulation fidelity** — choose between simplified and realistic assumptions at the domain level.

### 1.1 Out of scope for Phase 4

- Full governance enforcement during simulation (Phase 5)
- The promotion path from simulation to production (Phase 5)
- Real external data sources — all data is synthetic, produced by generative modules
- Persistent time-series storage — simulation events are ephemeral per simulation run
- Complex probabilistic or agent-based generation — the generator produces simple stochastic events
- Module nesting or sub-module hierarchy

### 1.2 Prototyping ethos

Phase 4 is the most conceptually demanding phase. The epistemic dimension connects to the coordinate framework (A12) and coordinate space snapshots (L8), but the prototype does not need to implement the full theoretical apparatus. We build the simplest thing that lets an operator experience comparative simulation, and learn from what we build. Refinement follows experience.

---

## 2. Design Decisions

### S179-D1: Epistemic character as a module instance property, not a third lifecycle

**Decision:** Add an `epistemic_character` column to `module_instances` with values `production | hypothesis | projection`. This is a **settable property** of a module instance, not an intersecting state machine.

**Rationale:** OW-16 anticipated a third intersecting lifecycle (epistemic). On reflection, the epistemic character is not a lifecycle — it does not have state transitions in the same sense as installation (installed/trashed) or operational (draft/active/paused/stopped). A module doesn't transition *from* hypothesis *to* production through a state machine — it is *promoted*, which is a specific operation with prerequisites (Phase 5). In the prototype, epistemic character is a label the operator sets when creating or duplicating a module instance. It governs dashboard presentation and the consequence boundary, but it doesn't have its own transition rules.

**Default:** `production` for newly installed modules. `hypothesis` for duplicated variants. The operator can change this at any time during draft state.

**OW-16 status:** Partially addressed. The epistemic lifecycle decomposes into a settable property (Phase 4) plus a formal promotion operation (Phase 5). The prediction that it should be a third intersecting lifecycle is revised — it is a property that the promotion operation acts upon.

### S179-D2: Simulation events as a shared domain-level event stream

**Decision:** Introduce a `simulation_events` table holding typed, timestamped events scoped to a domain and a simulation run. Generative modules write events. Business modules are the notional "recipients" (tagged by `target_module_id`). Analytical modules read events to compute metrics.

**Rationale:** The alternatives considered were: (a) per-module internal data stores — too complex for a prototype, creates a synchronisation problem; (b) a message queue — over-engineering for a local SQLite prototype; (c) a shared event log — simple, queryable, appropriate for the prototype's fidelity level. The event stream is conceptually aligned with L5 (operational simulation) — the running system produces a stream of business events.

**Event structure:** Each event has a type (e.g. `customer_arrival`, `transaction`, `issue_raised`, `resource_request`), a JSON payload, a source module (the generative module that produced it), a target module (the business module it pertains to), a timestamp, and a simulation run ID.

### S179-D3: Simulation runs as explicit, bounded episodes

**Decision:** Introduce a `simulation_runs` table. A simulation run is a bounded episode: the operator starts a run, the generative module produces events for a configured duration or count, analytical modules compute metrics over the run's events, and the operator can compare runs.

**Rationale:** Unbounded event streams are hard to reason about and compare. A simulation run gives the operator a discrete unit to name, compare, and discard. It connects to the coordinate framework — each run is a snapshot in the epistemic dimension. Runs can be parameterised differently (different generator settings) to enable controlled comparison.

### S179-D4: Analytical modules use comparison sets

**Decision:** An analytical module is configured with a **comparison set** — a list of module instance IDs it observes. When the analytical module is activated, it computes metrics across the events associated with its comparison set members. The comparison set is stored as part of the analytical module's `config_values`.

**Rationale:** The existing connection mechanism (shared BMM concerns) identifies *potential* connections. The comparison set is an *explicit* wiring decision by the operator: "Compare these specific sibling variants." This keeps the analytical module's scope clear and the comparison meaningful.

### S179-D5: Two generative module definitions in the prototype catalogue

**Decision:** Add two generative module definitions to the seed data:

1. **Customer Traffic Generator** — produces `customer_arrival` and `transaction` events at configurable rates. Parameters: arrival rate (per hour), average transaction value, variance, peak hours flag.
2. **Scenario Driver** — produces `issue_raised` and `resource_request` events. Parameters: issue frequency, severity distribution (low/medium/high), resource pressure level.

**Rationale:** Two generators exercise the generative module concept without over-building. The Customer Traffic Generator provides the commercial lifeblood; the Scenario Driver introduces operational complexity. Together they produce a realistic enough event stream for comparative analysis.

### S179-D6: One additional analytical module definition

**Decision:** Add one analytical module definition:

1. **Comparative Dashboard** — wired to a comparison set of sibling business modules, computes and displays side-by-side metrics: event counts, transaction totals, issue rates, and a simple health score.

**Rationale:** The existing Business Overview module (`07-business-overview`) is a single-module analytical view. The Comparative Dashboard is explicitly multi-module — it exists to compare siblings. This validates the analytical module concept and the comparison set mechanism.

### S179-D7: Domain-level simulation fidelity setting

**Decision:** Add a `simulation_fidelity` field to the `domains` table with values `simplified | realistic`. In the prototype, this governs generator behaviour: simplified mode uses flat distributions and ignores governance; realistic mode introduces peaks, variance, and governance-relevant events (e.g. compliance incidents). Full governance integration is Phase 5.

**Rationale:** Progressive fidelity is a domain-level setting because it governs the environment for all modules within the domain. Making it per-module would be confusing — the operator wants to say "run everything under realistic conditions", not configure fidelity module by module.

---

## 3. What Exists After Phase 3

The portal at the end of Phase 3 (Session 178, commit `d391fa2`):

**Data model:** 7 tables: `users`, `sessions`, `domains`, `domain_memberships`, `module_definitions`, `module_instances`, `module_state_transitions`, `domain_context`. Module instances have `installation_state` (installed/trashed) and `operational_state` (draft/active/paused/stopped).

**Module catalogue:** 7 module definitions (6 business + 1 analytical). Each has `category`, `bmmConcerns`, `configSchema`.

**Shared library (`$lib/modules/`):** `lifecycle.ts` (state machine validation and display), `connections.ts` (BMM concern overlap connections), `composition.ts` (install preview with composition hints), `impact.ts` (lifecycle impact warnings).

**Context layer (`$lib/context/`):** `schemas.ts` (BMM concern metadata and per-concern configuration schemas).

**Routes:** Dashboard (`/domains/[slug]`), catalogue (`/domains/[slug]/catalogue`), module detail (`/domains/[slug]/modules/[moduleId]`), module configure (`/domains/[slug]/modules/[moduleId]/configure`), domain context (`/domains/[slug]/context`), domain settings (`/domains/[slug]/settings`).

**Key patterns:** Module definitions are seeded from `seed.ts`. Server-side functions in `$lib/server/db/modules.ts`. Types in `$lib/types.ts`. Shared logic in `$lib/modules/` (NOT `$lib/server/` — OW-19).

---

## 4. The Simulation Data Architecture

The simulation data architecture introduces three new concepts:

### 4.1 Simulation runs

A simulation run is a bounded episode of synthetic event generation. It belongs to a domain, is started by the operator, and produces a stream of events over a configured period.

```
SimulationRun
  ├── id, domainId, name
  ├── status: pending | running | completed | cancelled
  ├── fidelity: simplified | realistic (copied from domain setting at run start)
  ├── generatorModuleId (which generative module produces events)
  ├── targetModuleIds[] (which business modules receive events)
  ├── config: { durationMinutes, eventsPerMinute, ... }
  ├── startedAt, completedAt
  └── createdBy
```

### 4.2 Simulation events

Events are the atomic unit of simulation. They are produced by a generative module during a simulation run and attributed to a target business module.

```
SimulationEvent
  ├── id, runId, domainId
  ├── eventType: customer_arrival | transaction | issue_raised | resource_request
  ├── sourceModuleId (the generator)
  ├── targetModuleId (the business module)
  ├── payload: JSON (type-specific data)
  ├── simulatedAt (the simulated timestamp within the run)
  └── createdAt (when the event was actually generated)
```

### 4.3 Run metrics (computed)

Analytical modules compute metrics from simulation events. Rather than storing pre-computed metrics, the analytical module queries events at display time. For the prototype, this is performant enough with SQLite. The metrics are:

- **Event count** by type, per target module, per run
- **Transaction total** (sum of `amount` in transaction event payloads)
- **Issue rate** (issues per simulated hour)
- **Simple health score** — a composite: `100 - (issue_rate × 10) + (transactions_per_hour × 2)`, clamped to 0–100

### 4.4 Event generation strategy

The generative module does not run in real-time. When the operator starts a simulation run, the system **generates all events at once** (batch generation) for the configured simulated duration. This is a prototype simplification — real-time streaming is out of scope. The batch approach means:

- Events are generated synchronously in a server action
- The `simulatedAt` timestamps span the configured duration (e.g. a 1-day simulation produces events timestamped across 24 simulated hours)
- The operator sees the completed run's events immediately
- Multiple runs can be compared by querying events from different `runId` values

---

## 5. Implementation Steps

### Step 4.1: Schema migration and types [Code]

**What:** Add new database tables and extend existing ones. Update TypeScript types.

**Database changes:**
- Add `epistemic_character` column to `module_instances` (default `'production'`)
- Add `simulation_fidelity` column to `domains` (default `'simplified'`)
- Create `simulation_runs` table
- Create `simulation_events` table

**Type changes in `$lib/types.ts`:**
- Add `EpistemicCharacter = 'production' | 'hypothesis' | 'projection'`
- Add `SimulationFidelity = 'simplified' | 'realistic'`
- Add `SimulationRunStatus = 'pending' | 'running' | 'completed' | 'cancelled'`
- Add `SimulationEventType = 'customer_arrival' | 'transaction' | 'issue_raised' | 'resource_request'`
- Add interfaces: `SimulationRun`, `SimulationEvent`, `RunMetrics`, `ComparisonResult`
- Extend `ModuleInstance` with `epistemicCharacter: EpistemicCharacter`
- Extend `Domain` with `simulationFidelity: SimulationFidelity`

**Acceptance criteria:**
- Schema migrates cleanly (delete db + WAL files, restart — OW-21)
- Existing module instances default to `production` epistemic character
- Existing domains default to `simplified` fidelity

### Step 4.2: Seed new module definitions [Code]

**What:** Add three new module definitions to `seed.ts`.

**New definitions:**

1. `08-customer-traffic-generator` (category: `generative`)
   - BMM concerns: `['Cross-cutting']` (generates data for any business module)
   - Config schema: `arrivalRate` (number, events per simulated hour, default 10), `avgTransactionValue` (number, default 50), `transactionVariance` (number, 0–1 scale, default 0.3), `peakHoursEnabled` (boolean, default false)
   - Icon: `ArrowsRepeatOutline` or similar
   - Sort order: 8

2. `09-scenario-driver` (category: `generative`)
   - BMM concerns: `['Cross-cutting']`
   - Config schema: `issueFrequency` (number, issues per simulated day, default 2), `severityDistribution` (select: mostly-low / balanced / mostly-high, default balanced), `resourcePressure` (select: low / normal / high, default normal)
   - Icon: `AdjustmentsHorizontalOutline` or similar
   - Sort order: 9

3. `10-comparative-dashboard` (category: `analytical`)
   - BMM concerns: `['Cross-cutting']`
   - Config schema: `comparisonModuleIds` (text — comma-separated IDs for now, will become a proper picker in the UI), `metricsToShow` (select: all / financial / operational, default all)
   - Icon: `ChartOutline` or similar
   - Sort order: 10

**Acceptance criteria:**
- All three definitions appear in the module catalogue
- Category badges distinguish generative (new colour) from business and analytical

### Step 4.3: Epistemic character UI [Code]

**What:** Add epistemic character display and controls to the module instance UI.

**Changes:**
- Dashboard module cards show an epistemic badge: `Production` (teal/default), `Hypothesis` (purple), `Projection` (blue)
- Module detail page shows and allows editing epistemic character (only in draft state)
- Module duplication action: on the module detail page, a "Duplicate as variant" button creates a new instance of the same definition with copied config, `epistemic_character = 'hypothesis'`, and `operational_state = 'draft'`. The display name gets a suffix (e.g. "Service Offerings — Variant A")

**New server functions in `$lib/server/db/modules.ts`:**
- `duplicateInstance(instanceId, userId, variantName)` — creates a copy with hypothesis character
- `updateEpistemicCharacter(instanceId, character)` — only allowed in draft state

**New shared logic in `$lib/modules/epistemic.ts`:**
- `getEpistemicDisplay(character)` — returns label, badge colour, border class (mirroring the lifecycle display pattern)
- `canEditEpistemic(operationalState)` — returns true only for `draft`

**Acceptance criteria:**
- Dashboard visually distinguishes epistemic character
- Operator can duplicate a module as a hypothesis variant
- Epistemic character is editable only in draft state
- Duplicated instance copies config values but starts in draft/installed

### Step 4.4: Simulation fidelity setting [Code]

**What:** Add domain-level simulation fidelity control.

**Changes:**
- Domain settings page (`/domains/[slug]/settings`) gains a "Simulation fidelity" selector: Simplified / Realistic
- The selection is stored in the `domains` table
- The fidelity level is displayed on the domain dashboard (small badge or subtitle)

**New server function in `$lib/server/db/domains.ts`:**
- `updateSimulationFidelity(domainId, fidelity)` — updates the domain's fidelity setting

**Acceptance criteria:**
- Operator can toggle fidelity from domain settings
- Current fidelity is visible on the dashboard

### Step 4.5: Simulation run infrastructure [Code]

**What:** Implement the simulation run lifecycle: create, start (generate events), complete, cancel.

**New file `$lib/server/simulation/runs.ts`:**
- `createRun(domainId, generatorModuleId, targetModuleIds[], name, userId)` — creates a pending run, copying the domain's current fidelity setting
- `startRun(runId)` — generates events (calls the generator), marks run as completed
- `cancelRun(runId)` — marks a pending/running run as cancelled
- `getRunsForDomain(domainId)` — returns all runs for a domain
- `getRunById(runId)` — returns a single run with metadata

**New file `$lib/server/simulation/generator.ts`:**
- `generateEvents(run, generatorConfig, fidelity)` — the core event generation logic
- Produces events based on the generator module's config and the run's fidelity
- For `simplified` fidelity: flat Poisson-distributed arrivals, uniform transaction values
- For `realistic` fidelity: peak-hour weighting, log-normal transaction values, correlated issues

**Event generation detail (Customer Traffic Generator):**
- Simulated duration: configurable (default 7 simulated days)
- For each simulated hour: generate `arrivalRate` ± random variance customer arrivals
- For each arrival: generate a `transaction` event with amount drawn from the configured distribution
- `simplified`: uniform random within ±variance of avgTransactionValue
- `realistic`: log-normal distribution centred on avgTransactionValue, with peak-hour multipliers (1.5× during 10:00–14:00)

**Event generation detail (Scenario Driver):**
- Simulated duration: matches the run duration
- Generates `issue_raised` events at the configured daily rate, distributed randomly
- Severity drawn from the configured distribution
- Generates `resource_request` events based on resource pressure level

**Acceptance criteria:**
- A simulation run can be created, started, and completed
- Events are persisted in `simulation_events` with correct source/target module references
- Simplified and realistic fidelity produce noticeably different event distributions
- Multiple runs can coexist for the same domain

### Step 4.6: Simulation run UI [Code]

**What:** Provide the operator with a way to create, start, and view simulation runs.

**New route: `/domains/[slug]/simulations`**
- Lists all simulation runs for the domain with status, name, event count, created date
- "New simulation run" button opens a creation form:
  - Name (text)
  - Generator module (select from installed generative modules)
  - Target modules (multi-select from installed business modules — these are the modules that "receive" events)
  - Duration (select: 1 day / 7 days / 30 days)
  - Start button
- Run detail view shows: run metadata, event count by type, event timeline summary
- Navigation: add "Simulations" to the domain sidebar

**Changes to dashboard:**
- Add a "Simulations" summary card showing the count of completed runs and a link to the simulations page

**Acceptance criteria:**
- Operator can create and start a simulation run from the UI
- Run appears in the list with status
- Run detail shows event summary
- Simulations page is navigable from the domain sidebar and dashboard

### Step 4.7: Analytical module — Comparative Dashboard [Code]

**What:** Implement the Comparative Dashboard analytical module's display.

**When a Comparative Dashboard module instance is viewed (`/domains/[slug]/modules/[moduleId]`):**
- If the module has a configured comparison set (module IDs in config), show a comparison view
- For each module in the comparison set, query `simulation_events` from the most recent completed run targeting that module
- Compute and display side-by-side:
  - Total events (by type)
  - Total transaction value
  - Average transaction value
  - Issue count and rate
  - Health score (the simple composite from §4.3)
- Visual presentation: a table or card grid, one column per compared module, with colour-coded health scores

**Changes to module detail page:**
- For analytical modules with `comparisonModuleIds` in config: render the comparison view
- For analytical modules without a comparison set: show a prompt to configure one
- The "configure" page for the Comparative Dashboard should include a module picker for the comparison set (list of installed business modules with checkboxes)

**New file `$lib/server/simulation/metrics.ts`:**
- `computeRunMetrics(runId, targetModuleId)` — queries events and computes the metric set
- `getComparisonResults(comparisonModuleIds[], domainId)` — computes metrics for the latest run targeting each module, returns a `ComparisonResult[]`

**New shared file `$lib/modules/metrics.ts`:**
- `computeHealthScore(eventCounts, transactionTotal, issueCounts)` — the simple composite formula
- `formatCurrency(amount, currency)` — uses the domain context's currency

**Acceptance criteria:**
- Comparative Dashboard shows side-by-side metrics for configured modules
- Metrics are computed from simulation events
- Health score provides a quick visual comparison
- The module picker for the comparison set works

### Step 4.8: Dashboard visual integration [Code]

**What:** Update the domain dashboard to reflect the simulation and comparison capabilities.

**Changes:**
- Generative module cards get a distinct visual treatment: a different border or background tint to distinguish them from business and analytical modules
- Module cards for `hypothesis` and `projection` instances show a subtle visual indicator (purple or blue left border, matching the epistemic badge)
- The category filter on the catalogue page includes "Generative" as a filterable category
- The "concern coverage" bar on the dashboard handles `Cross-cutting` gracefully (generative and analytical modules don't count toward BMM concern coverage)

**Acceptance criteria:**
- All three module categories are visually distinguishable on the dashboard
- Epistemic character is visible at a glance on module cards
- Generative/analytical modules don't distort the concern coverage indicator

---

## 6. Database Schema Changes

```sql
-- Add epistemic character to module instances
ALTER TABLE module_instances ADD COLUMN epistemic_character TEXT NOT NULL DEFAULT 'production';

-- Add simulation fidelity to domains
ALTER TABLE domains ADD COLUMN simulation_fidelity TEXT NOT NULL DEFAULT 'simplified';

-- Simulation runs
CREATE TABLE IF NOT EXISTS simulation_runs (
    id TEXT PRIMARY KEY,
    domain_id TEXT NOT NULL REFERENCES domains(id),
    name TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    fidelity TEXT NOT NULL,
    generator_module_id TEXT NOT NULL REFERENCES module_instances(id),
    target_module_ids TEXT NOT NULL,  -- JSON array of module instance IDs
    config TEXT NOT NULL DEFAULT '{}',
    event_count INTEGER NOT NULL DEFAULT 0,
    started_at TEXT,
    completed_at TEXT,
    created_by TEXT NOT NULL REFERENCES users(id),
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Simulation events
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

-- Index for efficient event queries
CREATE INDEX IF NOT EXISTS idx_sim_events_run ON simulation_events(run_id);
CREATE INDEX IF NOT EXISTS idx_sim_events_target ON simulation_events(target_module_id, run_id);
```

**Migration note (OW-21):** These schema changes require: stop dev server, delete `portal.db` + `portal.db-shm` + `portal.db-wal`, restart. The Code instruction set must include this explicitly.

---

## 7. New Types

```typescript
// ── Epistemic types ─────────────────────────────────────────────────
export type EpistemicCharacter = 'production' | 'hypothesis' | 'projection';
export type SimulationFidelity = 'simplified' | 'realistic';

// ── Simulation types ────────────────────────────────────────────────
export type SimulationRunStatus = 'pending' | 'running' | 'completed' | 'cancelled';
export type SimulationEventType = 'customer_arrival' | 'transaction' | 'issue_raised' | 'resource_request';

export interface SimulationRun {
    id: string;
    domainId: string;
    name: string;
    status: SimulationRunStatus;
    fidelity: SimulationFidelity;
    generatorModuleId: string;
    targetModuleIds: string[];
    config: Record<string, unknown>;
    eventCount: number;
    startedAt: string | null;
    completedAt: string | null;
    createdBy: string;
    createdAt: string;
}

export interface SimulationEvent {
    id: string;
    runId: string;
    domainId: string;
    eventType: SimulationEventType;
    sourceModuleId: string;
    targetModuleId: string;
    payload: Record<string, unknown>;
    simulatedAt: string;
    createdAt: string;
}

export interface RunMetrics {
    targetModuleId: string;
    targetModuleName: string;
    totalEvents: number;
    customerArrivals: number;
    transactions: number;
    transactionTotal: number;
    avgTransactionValue: number;
    issuesRaised: number;
    issueRate: number;  // per simulated day
    resourceRequests: number;
    healthScore: number;  // 0–100 composite
}

export interface ComparisonResult {
    modules: RunMetrics[];
    runName: string;
    runId: string;
    fidelity: SimulationFidelity;
}
```

---

## 8. New Module Definitions

### 08-customer-traffic-generator

| Field | Value |
|---|---|
| ID | `08-customer-traffic-generator` |
| Name | Customer Traffic Generator |
| Slug | `customer-traffic-generator` |
| Category | `generative` |
| Description | Generates synthetic customer traffic and transactions for simulation runs. Configure arrival rates, transaction values, and distribution patterns. |
| BMM Concerns | `['Cross-cutting']` |
| Icon | `ArrowsRepeatOutline` |
| Config | `arrivalRate` (number, 10), `avgTransactionValue` (number, 50), `transactionVariance` (number, 0.3), `peakHoursEnabled` (boolean, false) |

### 09-scenario-driver

| Field | Value |
|---|---|
| ID | `09-scenario-driver` |
| Name | Scenario Driver |
| Slug | `scenario-driver` |
| Category | `generative` |
| Description | Generates operational scenarios — issues, resource pressures, and incidents — to stress-test your business configuration. |
| BMM Concerns | `['Cross-cutting']` |
| Icon | `AdjustmentsHorizontalOutline` |
| Config | `issueFrequency` (number, 2), `severityDistribution` (select: mostly-low/balanced/mostly-high), `resourcePressure` (select: low/normal/high) |

### 10-comparative-dashboard

| Field | Value |
|---|---|
| ID | `10-comparative-dashboard` |
| Name | Comparative Dashboard |
| Slug | `comparative-dashboard` |
| Category | `analytical` |
| Description | Compares metrics across sibling business module variants side by side. Shows event volumes, financial performance, issue rates, and health scores. |
| BMM Concerns | `['Cross-cutting']` |
| Icon | `ChartMixedOutline` |
| Config | `comparisonModuleIds` (text, ''), `metricsToShow` (select: all/financial/operational) |

---

## 9. Success Criteria

| ID | Criterion | How to verify |
|---|---|---|
| P4-1 | Operators can duplicate a business module as a hypothesis variant | Duplicate action produces a new instance with copied config, hypothesis character, draft state |
| P4-2 | Dashboard visually distinguishes epistemic character | Production, hypothesis, and projection instances have distinct badges and border colours |
| P4-3 | Generative modules appear in the catalogue and can be installed | All three new definitions visible; generative category has distinct visual treatment |
| P4-4 | A simulation run can be created, started, and completed | Run appears with event count; events are queryable |
| P4-5 | Simplified and realistic fidelity produce different event distributions | Compare two runs under different fidelity — distributions are visibly different |
| P4-6 | Comparative Dashboard shows side-by-side metrics | At least two business modules compared with correct metrics from simulation events |
| P4-7 | Health score provides meaningful comparison | Different module configurations or different generator settings produce different scores |
| P4-8 | Simulation fidelity is configurable at the domain level | Setting persists and affects event generation |

---

## 10. OW Items to Check During Implementation

| OW ID | Summary | How it applies to Phase 4 |
|---|---|---|
| OW-14 | Comprehension vs compositional complexity | Phase 4 introduces simulation runs that span multiple modules. The "explain what's happening" challenge grows. Static composition hints (OW-22) may need extending to simulation context |
| OW-16 | Epistemic lifecycle | S179-D1 resolves this as a settable property, not a third lifecycle. Record whether this decision holds during implementation |
| OW-18 | Module taxonomy empirical | Phase 4 exercises all three roles (business, analytical, generative) for the first time. Watch whether the taxonomy holds or whether additional roles emerge |
| OW-19 | SvelteKit server boundary | New simulation server code goes in `$lib/server/simulation/`. Shared display logic (epistemic display, metrics formatting) goes in `$lib/modules/` |
| OW-20 | SSR guard pattern | Any client-side-only behaviour in the simulation UI must use `$state()` + `$effect` with `browser` guard |
| OW-21 | SQLite WAL pitfall | Schema changes require stopping the server and deleting all three files. Code instructions must be explicit |
| OW-22 | Static composition hints | With 10 module definitions, check whether the hard-coded `COMPOSITION_HINTS` approach remains workable |

---

## 11. Session Estimate and Phasing

**Total estimate: 5–7 sessions.** Proposed session breakdown:

| Session | Steps | Focus |
|---|---|---|
| 1 | 4.1, 4.2 | Schema, types, seed data. Foundation layer. Quick wins |
| 2 | 4.3 | Epistemic character UI + module duplication |
| 3 | 4.4, 4.5 | Simulation fidelity + run infrastructure + event generation |
| 4 | 4.6 | Simulation run UI (new route, creation form, run list, detail view) |
| 5 | 4.7 | Comparative Dashboard analytical module |
| 6 | 4.8 | Dashboard visual integration, polish, testing |
| 7 | Buffer / Phase 4 closure | Address issues, update governance documents, close |

Sessions 1–2 could potentially compress into one session. Sessions 3–4 are the core complexity. The buffer session accounts for the prototyping ethos — we may discover design questions that require discussion before continuing.

Each session's Code instruction set should be self-contained per the workflow guide §4.2 and §5.4. Chat produces the instruction set; Code executes it.

---

## 12. Register Connections

| Register concept | How exercised in Phase 4 |
|---|---|
| [[principle-separation-representation-execution\|A1]] | Simulation configuration (representation) cleanly separated from event generation (execution). Run parameters are data; generation is a function of that data |
| [[principle-self-describing-system\|A2]] | The portal explains simulation runs, metrics, and comparisons to the operator |
| [[principle-model-generates-everything\|A3]] | Directional: prototype generates events from configuration, not from SysML. Architecture supports future model-driven generation |
| [[concept-coordinate-framework\|A12]] | Epistemic character maps to coordinate space snapshot types. Simulation runs are snapshots. Comparative analysis operates across epistemic dimensions |
| [[concept-multi-tenancy\|A13]] | Simulation runs are domain-scoped. Events cannot cross domain boundaries |
| [[concept-co-evolution\|J2]] | Building what we can see: simulation run UI co-evolves with event generation |
| [[concept-non-constraining\|J3]] | Batch event generation does not foreclose future streaming. SQLite does not foreclose future PostgreSQL. Simple metrics do not foreclose future analytical sophistication |
| [[concept-operational-simulation\|L5]] | Simulation runs are the prototype expression of L5 — the business model made live (in simplified form) |
| [[concept-reflective-simulation\|L6]] | Comparative Dashboard is the prototype expression of L6 — observing and reflecting on operational state |
| [[concept-coordinate-space-snapshots\|L8]] | Each simulation run is a coordinate space snapshot. Hypothesis variants occupy different positions in the epistemic dimension |
| [[concept-unity-principle\|A11]] | Metrics computation draws on the same module configuration data that the dashboard, connections, and composition views use. One data model serves multiple views |

---

*Phase 4 plan created Session 179, 9 April 2026. Build to learn — the simulation architecture is a prototype that will be refined by the experience of building and using it.*
