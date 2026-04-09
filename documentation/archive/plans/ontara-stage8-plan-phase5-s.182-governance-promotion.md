---
tags:
  - plan
  - portal
  - governance
date: 2026-04-09
status: active
session: 182
---
# Stage 8 Phase 5 Plan — Governance and Promotion
> `= this.file.path`

**Session:** 182
**Date:** 9 April 2026
**Purpose:** Detailed implementation plan for Phase 5 (Governance and Promotion) of Stage 8 — the final phase. Covers progressive governance, the promotion path from simulation to production, production monitoring, and demotion.
**Status:** Active.
**Depends on:** [[ontara-stage8-plan-high-level-s.174-portal|Stage 8 High-Level Plan]] §9/§15, [[ontara-discussion-portal-state-driven-operator-experience-2026-04-08|Portal Discussion Paper]] §9–§10, Phase 4 complete (S181)

---

## Contents

- [[#1. Scope and Objectives|§1. Scope and Objectives]]
- [[#2. Design Decisions|§2. Design Decisions]]
- [[#3. Current State|§3. Current State]]
- [[#4. Implementation Steps|§4. Implementation Steps]]
- [[#5. Schema Changes|§5. Schema Changes]]
- [[#6. Success Criteria|§6. Success Criteria]]
- [[#7. Register Connections|§7. Register Connections]]
- [[#8. OW Items to Check|§8. OW Items to Check]]

---

## 1. Scope and Objectives

Phase 5 delivers three capabilities:

1. **Progressive governance.** Governance constraints become visible, evaluable, and — at the right governance level — blocking. The operator sees what constraints apply, which are satisfied, and what would happen if governance were tightened.
2. **The promotion path.** An operator can promote a module from simulation (hypothesis/projection) to production status, guided through what changes: epistemic transition, governance activation, consequence boundary. The platform enforces that promotion prerequisites are met.
3. **Production monitoring and demotion.** Production modules receive distinct visual treatment, a governance compliance panel, and the ability to demote back to simulation with appropriate warnings.

### 1.1 What Phase 5 is not

- **Not real governance enforcement.** Constraints are prototype data objects evaluated against module configuration — not connected to the OWL governance ontology (`ontara-gov:`) or the reasoning metamodel (`ontara-rsn:`). The architectural consistency is preserved (same three-way classification: [[concept-hard-constraint|HardConstraint]]/[[concept-soft-constraint|SoftConstraint]]/[[concept-graded-rule|GradedRule]]), but the implementation is self-contained within the portal's SQLite world.
- **Not runtime monitoring.** There is no live execution substrate ([[concept-operational-simulation|L5]] is out of Stage 8 scope). "Production monitoring" means the dashboard shows governance compliance status for production-epistemic modules, not real-time operational metrics.
- **Not multi-user governance roles.** The governance level is a domain-wide setting managed by the super admin. Role-based governance permissions are future work.

---

## 2. Design Decisions

Six design questions were raised and resolved during Session 182 planning:

**S182-D1: Governance constraints are typed data objects within the portal.** Each module definition carries a set of governance constraints — typed objects with `level` (hard | soft | graded), `description`, `concern` (BMM concern), and an evaluation function that checks satisfaction against the module's config values and domain state. These are hand-coded per module definition in the seed data for the prototype. Architecturally consistent with the three-way constraint hierarchy (HardConstraint / SoftConstraint / GradedRule) from the reasoning metamodel, but decoupled from the OWL vocabulary.

**S182-D2: Governance level is a separate domain-wide setting.** Three levels: `exploratory` (constraints visible but non-blocking), `advisory` (constraints evaluated, warnings shown on dashboard and before lifecycle transitions), `enforced` (HardConstraints block promotion; HardConstraint violations shown as errors). This is independent of simulation fidelity — the operator can combine any fidelity with any governance level. Default for new domains: `exploratory`.

**S182-D3: Promotion applies to individual modules with domain-wide coherence checks.** An operator promotes a single module instance from hypothesis/projection to production. The promotion operation checks: (a) the module's own HardConstraints are satisfied, (b) the domain governance level is `enforced`, (c) any module this module depends on (via shared BMM concerns with active wiring) is already at production epistemic character or is being promoted simultaneously. Promotion of a group of modules is sequential individual promotions with the coherence check applied at each step.

**S182-D4: Promotion is a multi-step server action with a confirmation wizard.** Step 1: evaluate prerequisites and present results (pass/fail with explanations). Step 2: show what changes — epistemic transition, governance activation, consequence boundary shift. Step 3: require explicit confirmation. Step 4: execute the transition atomically. The promotion wizard is a dedicated page/modal, not a single button press.

**S182-D5: Demotion (production → hypothesis) is the reverse path with its own guards.** The operator can demote a production module back to hypothesis. Guards: warn that governance will relax (unless domain governance level remains enforced), warn about consequence boundary change (production data implications — in the prototype this is conceptual, not real data loss). Demotion resets epistemic character to `hypothesis` and records the transition. The module's operational state is unchanged — a running production module that is demoted continues running but is now a hypothesis.

**S182-D6: Constraint evaluation is server-side, results cached per module instance.** Governance constraints are evaluated on the server when: (a) the governance page is loaded, (b) a lifecycle transition is attempted, (c) promotion is initiated. Results are returned as a typed array of `ConstraintResult` objects (constraint definition + satisfied boolean + explanation). No separate database table for constraint results — they are computed on demand from the current module config and domain state.

---

## 3. Current State

The portal at end of Phase 4:

- **10 module definitions** (6 business + 2 generative + 2 analytical), each with `configSchema` and `bmmConcerns`
- **[[concept-epistemic-modality|Epistemic character]]** (production / hypothesis / projection) as a settable property on module instances, editable in draft state
- **Two intersecting lifecycle state machines** (installation: installed/trashed; operational: draft/active/paused/stopped)
- **Domain context** structured by 6 BMM concerns, module wiring via shared concern overlap
- **Simulation runs** with batch event generation, comparative metrics, health scores
- **Dashboard** with category-aware visual treatment, inline lifecycle actions, state dots
- **Domain-level `simulationFidelity`** setting (simplified/realistic)

What Phase 5 adds:
- Governance constraint definitions per module definition (seed data extension)
- Governance level per domain (schema + UI)
- Governance constraint evaluation engine (`$lib/server/governance/`)
- Governance page per domain showing constraint status
- Promotion operation with prerequisite checking and confirmation wizard
- Demotion operation with guards
- Production-specific dashboard visual treatment
- Governance compliance indicators on dashboard module cards

---

## 4. Implementation Steps

### Step 5.1: Governance data model and constraint definitions [Chat + Code]

**Objective:** Define the governance constraint type system, add governance constraints to module definitions, extend the domain schema with governance level.

**Types to add** (in `$lib/types.ts`):

```typescript
export type GovernanceLevel = 'exploratory' | 'advisory' | 'enforced';
export type ConstraintLevel = 'hard' | 'soft' | 'graded';

export interface GovernanceConstraint {
    id: string;
    level: ConstraintLevel;
    description: string;
    concern: BmmConcern | 'Cross-cutting';
    evaluator: string; // key into a registry of evaluator functions
}

export interface ConstraintResult {
    constraint: GovernanceConstraint;
    satisfied: boolean;
    explanation: string;
}

export interface GovernanceAssessment {
    moduleInstanceId: string;
    moduleName: string;
    results: ConstraintResult[];
    hardCount: number;
    hardSatisfied: number;
    softCount: number;
    softSatisfied: number;
    gradedCount: number;
    gradedSatisfied: number;
    overallPass: boolean; // true if all hard constraints satisfied
}
```

**Schema changes:**
- Add `governance_level TEXT NOT NULL DEFAULT 'exploratory'` to `domains` table
- Add `governance_constraints TEXT NOT NULL DEFAULT '[]'` to `module_definitions` table

**Seed data extension:** Each of the 6 business module definitions gains 2–4 governance constraints. The 2 generative and 2 analytical modules gain 1 constraint each (lightweight — they are tooling, not business-critical). Examples:

- **Service Offerings** (hard): "Service description must be provided" — evaluates `configValues.description !== ''`
- **Service Offerings** (soft): "Pricing model should match sector norms" — advisory only
- **Compliance & Governance** (hard): "Regulatory body must be specified for sector-regulated businesses" — evaluates against `complianceLevel` config + `regulatoryBody` not empty
- **Financial Tracking** (hard): "VAT registration must be confirmed for UK businesses" — evaluates `vatRegistered` against domain business type
- **Team & Resources** (soft): "Skill tracking recommended for teams larger than 5" — evaluates `teamSize > 5 && !skillTracking`
- **Customer Traffic Generator** (graded): "Arrival rate above 50/hour may produce unrealistic results" — evaluates `arrivalRate > 50`

**Evaluator implementation:** `$lib/server/governance/evaluators.ts` — a registry of named evaluator functions. Each function receives the module's config values, the domain context, and the domain settings, and returns `{ satisfied: boolean; explanation: string }`. This keeps evaluation logic server-side and testable.

**Deliverables:**
- Extended types in `$lib/types.ts`
- Extended schema in `schema.sql`
- Extended seed data in `seed.ts` with governance constraints per definition
- `$lib/server/governance/` directory: `evaluators.ts` (evaluator registry), `assess.ts` (runs all constraints for a module instance, returns `GovernanceAssessment`), `index.ts` (exports)
- Domain `governanceLevel` exposed in domain settings page

**Tool allocation:** `[Code]` — multi-file changes across types, schema, seed, new server directory. Iterative testing needed (delete DB, restart, verify seed).

### Step 5.2: Governance page and dashboard integration [Chat + Code]

**Objective:** Build a domain-level governance page showing constraint status for all installed modules. Integrate governance indicators into the existing dashboard module cards.

**Governance page** (`/domains/[slug]/governance`):
- Header: domain name, current governance level with explanation, link to change level in settings
- For each installed (non-trashed) module: module name, epistemic badge, operational state badge, list of constraints with satisfaction status (green check / amber warning / red cross depending on level + satisfaction)
- Summary panel: total constraints, hard satisfied/total, soft satisfied/total, graded score
- Visual hierarchy: hard constraint violations are prominent (red), soft unsatisfied are amber, graded show a progress indicator
- Governance level selector: if changed, the page re-evaluates all constraints and shows the effect

**Dashboard integration:**
- Each module card on the existing dashboard gains a small governance indicator: a coloured dot or badge showing governance health
  - Green: all hard constraints satisfied, or governance level is `exploratory`
  - Amber: soft/graded constraints unsatisfied (advisory/enforced level)
  - Red: hard constraint violated (advisory/enforced level)
- The indicator is only shown when governance level is `advisory` or `enforced` — in `exploratory` mode, governance is invisible on the dashboard (available on the governance page for those who look)

**Server-side:**
- Governance page `+page.server.ts` loads all module instances with definitions, runs `assess()` for each, returns the assessments
- Dashboard `+page.server.ts` extended to include a lightweight governance summary (hard constraint pass/fail per module) — not the full assessment, just enough for the indicator dot

**Deliverables:**
- New route: `/domains/[slug]/governance` (page.server.ts + page.svelte)
- Dashboard module cards extended with governance indicator
- Domain settings page extended with governance level selector (3 radio buttons with descriptions)
- Sidebar navigation extended with "Governance" link

**Tool allocation:** `[Code]` — new route, UI components, server-side assessment integration. `[Chat]` — design review of governance page layout before implementation.

### Step 5.3: Promotion operation [Chat + Code]

**Objective:** Implement the promotion path — transitioning a module from hypothesis/projection to production epistemic character, with prerequisite checking, a confirmation wizard, and atomic execution.

**Prerequisite checks** (server-side, `$lib/server/governance/promotion.ts`):

| # | Check | Blocking? | Explanation if failed |
|---|---|---|---|
| P1 | Module epistemic character is `hypothesis` or `projection` | Yes | "This module is already in production." |
| P2 | Module operational state is `active` | Yes | "Only active modules can be promoted. Current state: [state]." |
| P3 | Domain governance level is `enforced` | Yes | "Governance must be set to Enforced before promotion. Current level: [level]." |
| P4 | All hard constraints for this module are satisfied | Yes | "N hard constraint(s) not satisfied: [list]." |
| P5 | All modules this module shares BMM concerns with that are also active have production epistemic character, or are being promoted in this session | Warning | "Module [name] shares [concerns] and is still in [character] mode. Consider promoting it too." |

P1–P4 are blocking (promotion cannot proceed). P5 is a warning (promotion can proceed but the operator is informed).

**Promotion wizard** (`/domains/[slug]/modules/[id]/promote`):

Step 1 — **Readiness assessment.** Show all prerequisite results: green checks for passed, red crosses for failed, amber warnings for P5. If any blocking prerequisite fails, the "Proceed" button is disabled with explanation.

Step 2 — **What changes.** A summary panel explaining:
- "Epistemic character will change from [current] to Production"
- "This module's outputs will now represent real business activity"
- "Governance constraints are binding — hard constraints must remain satisfied"
- "Demotion back to Hypothesis is available if needed"

Step 3 — **Confirm.** A confirmation button with clear language: "Promote [module name] to Production". The button is styled as a significant action (not casual).

**Server action:** A POST endpoint on the module's route that:
1. Re-evaluates all prerequisites (server-side — don't trust client state)
2. If all blocking prerequisites pass: update `epistemic_character` to `production`, record a state transition in `module_state_transitions` with lifecycle_type `epistemic` and note "Promoted to production"
3. Return success or failure with explanation

**Deliverables:**
- `$lib/server/governance/promotion.ts` — prerequisite evaluation logic
- New route: `/domains/[slug]/modules/[id]/promote` (page.server.ts + page.svelte) — the promotion wizard
- POST action on the module route for executing promotion
- Lifecycle transition type extended to include `epistemic` alongside `installation` and `operational`

**Tool allocation:** `[Code]` — new route, server logic, form actions. `[Chat]` — design review of wizard flow.

### Step 5.4: Demotion operation [Chat + Code]

**Objective:** Implement the reverse path — demoting a production module back to hypothesis.

**Demotion guards:**
- Module must currently be `production` epistemic character
- Module can be in any operational state (active, paused, stopped, draft)
- Warnings shown: "Governance constraints will continue to be evaluated at the current domain governance level. If you change governance level to exploratory after demotion, constraints will no longer be enforced." / "This module's outputs will be reclassified as hypothesis — no longer representing real business activity."

**Implementation:** Simpler than promotion — a confirmation modal (not a full wizard) on the module detail page. Available as a button when the module's epistemic character is `production`. On confirmation: update `epistemic_character` to `hypothesis`, record a state transition with lifecycle_type `epistemic` and note "Demoted from production".

**Deliverables:**
- Demotion action on the existing module detail/settings page (or as a form action on the dashboard)
- Confirmation modal with demotion warnings
- Server-side POST handler

**Tool allocation:** `[Code]` — simpler than promotion, additions to existing routes.

### Step 5.5: Production visual treatment and monitoring [Chat + Code]

**Objective:** Production modules receive distinct visual treatment on the dashboard. A production monitoring section shows governance compliance for all production modules.

**Dashboard changes:**
- Production-epistemic modules get a distinct card style: solid teal left border (matching the existing epistemic display system), a "PRODUCTION" badge, and slightly more prominent placement
- The dashboard gains an optional "Production" filter toggle — when active, shows only production modules
- If any production module has a hard constraint violation, a banner appears at the top of the dashboard: "⚠ Governance alert: [N] production module(s) have constraint violations"

**Governance page enhancement:**
- A "Production modules" section at the top of the governance page shows only production-epistemic modules with their full constraint assessment
- This section is always visible regardless of governance level — production modules always show governance status

**Deliverables:**
- Dashboard card visual treatment for production modules
- Dashboard filter toggle (all / production only)
- Governance alert banner on dashboard
- Production section on governance page

**Tool allocation:** `[Code]` — UI changes to existing components.

### Step 5.6: Lifecycle guards for governance [Chat + Code]

**Objective:** When governance level is `enforced`, certain lifecycle transitions check governance constraints before proceeding.

**Where governance intersects lifecycle:**
- **Activation (draft → active):** At `enforced` level, check all hard constraints. If any fail, block the transition with explanation. At `advisory` level, show a warning but allow. At `exploratory`, no check.
- **Promotion:** Already handled in Step 5.3.
- **Other transitions (pause, stop, reset):** No governance gating — these are operational decisions. The operator can always pause or stop a module regardless of governance.

**Implementation:** Extend the existing lifecycle transition handler in the module actions server code. Before executing `draft → active`, call `assess()` and check governance level. Return an error response if blocked, or a warning response if advisory.

**UI:** The "Activate" button on draft modules shows the constraint check result:
- `exploratory`: button works as before, no governance mention
- `advisory`: if hard constraints unsatisfied, button shows amber warning icon and a tooltip "N hard constraints not satisfied — proceed with caution"
- `enforced`: if hard constraints unsatisfied, button is disabled with red indicator and tooltip "Cannot activate: N hard constraints not satisfied. View governance page for details."

**Deliverables:**
- Extended lifecycle transition server logic with governance checks
- Conditional UI on the Activate button based on governance level and constraint status

**Tool allocation:** `[Code]` — additions to existing transition handlers and dashboard components.

---

## 5. Schema Changes

Summary of all database schema changes for Phase 5:

```sql
-- Add governance level to domains
ALTER TABLE domains ADD COLUMN governance_level TEXT NOT NULL DEFAULT 'exploratory';

-- Add governance constraints to module definitions
ALTER TABLE module_definitions ADD COLUMN governance_constraints TEXT NOT NULL DEFAULT '[]';
```

**Note:** Because the prototype uses SQLite with the WAL pitfall (OW-21), and we are adding columns with defaults, `ALTER TABLE ADD COLUMN` should work without needing to recreate the database. However, if the seed data changes (it will — constraints added to definitions), the safest approach is: stop server, delete all three DB files, restart. The Code instruction set should be explicit about this.

The `module_state_transitions` table already supports arbitrary `lifecycle_type` values (TEXT column), so adding `'epistemic'` as a new lifecycle type requires no schema change.

---

## 6. Success Criteria

| # | Criterion | Step |
|---|---|---|
| SC-1 | Governance constraints are defined for all 10 module definitions | 5.1 |
| SC-2 | Domain governance level can be set to exploratory / advisory / enforced | 5.1, 5.2 |
| SC-3 | A governance page shows constraint status for all installed modules | 5.2 |
| SC-4 | Dashboard module cards show governance indicators at advisory/enforced level | 5.2 |
| SC-5 | An operator can promote a hypothesis/projection module to production | 5.3 |
| SC-6 | Promotion enforces prerequisites: active state, enforced governance, hard constraints satisfied | 5.3 |
| SC-7 | The promotion wizard shows what changes and requires explicit confirmation | 5.3 |
| SC-8 | An operator can demote a production module back to hypothesis | 5.4 |
| SC-9 | Production modules have distinct visual treatment on the dashboard | 5.5 |
| SC-10 | Activation (draft → active) is gated by governance at enforced level | 5.6 |

---

## 7. Register Connections

| Register concept | How exercised |
|---|---|
| [[principle-separation-representation-execution\|A1]] | Governance constraints are representation (definitions); evaluation is execution. Promotion is the boundary where representation becomes consequential |
| [[principle-self-describing-system\|A2]] | The governance page and promotion wizard explain what constraints mean and why they matter |
| [[principle-deterministic-over-probabilistic\|A6]] | Governance constraint evaluation follows deterministic, inspectable logic — each result has an explanation |
| [[principle-discipline-as-load-bearing-structure\|A9]] | The three-level governance progression (exploratory → advisory → enforced) is a discipline structure for the operator |
| [[principle-intrinsic-self-knowledge\|A10]] | Governance compliance is computed from live module state, not stored as static assessment |
| [[concept-coordinate-framework\|A12]] | The promotion operation is an epistemic transition within the coordinate framework |
| [[concept-non-constraining\|J3]] | Constraint definitions are data, not code — the system can accommodate new constraint types without restructuring |

---

## 8. OW Items to Check

| OW ID | Summary | Relevance | Disposition |
|---|---|---|---|
| OW-16 | Epistemic character as settable property; promotion operation is Phase 5 | Directly addressed | Steps 5.3/5.4 implement promotion and demotion — completing the Phase 5 portion of OW-16 |
| OW-17 | Promotion path is safety-critical; enforcement at promotion, not experimentation | Directly addressed | S182-D2 establishes exploratory mode for experimentation; S182-D3/Step 5.3 enforce prerequisites at promotion. Three-way constraint hierarchy is the mechanism (S182-D1) |
| OW-14 | Comprehension untested against runtime compositional complexity | Partially exercised | The governance page and promotion wizard explain constraint and module relationships — first test of explaining inter-module consequences to the operator |
| OW-19 | Shared portal logic in `$lib/modules/` not `$lib/server/` | Standing constraint | New shared types go in `$lib/types.ts`. Governance evaluation is server-only → `$lib/server/governance/`. Display utilities (if needed) → `$lib/modules/governance.ts` |
| OW-25 | `{@const}` Svelte 5 constraint | Standing constraint | Code instruction set must be explicit |

---

## 9. Session Estimate

**3–4 sessions.** Step 5.1 (data model + constraints + evaluators) is the heaviest lift — likely 1 full session. Steps 5.2–5.3 (governance page + promotion wizard) are another session. Steps 5.4–5.6 (demotion + production UI + lifecycle guards) can likely be combined into a third session. A fourth session may be needed if the governance page design requires iteration.

This is within the 3–5 session estimate from the high-level plan.

---

## 10. Code Instruction Set Structure

Phase 5 is best delivered as **three Code instruction sets**:

1. **Instruction Set A (Step 5.1):** Schema changes, types, seed data extension, governance evaluator engine, domain governance level in settings. End state: governance infrastructure exists and evaluators can be called.

2. **Instruction Set B (Steps 5.2 + 5.3):** Governance page, dashboard governance indicators, promotion route with prerequisite checking and confirmation wizard. End state: operator can view governance status and promote modules.

3. **Instruction Set C (Steps 5.4 + 5.5 + 5.6):** Demotion operation, production visual treatment, lifecycle governance guards. End state: full Phase 5 capability.

Each instruction set is self-contained with acceptance criteria. Chat produces the instruction set; Code executes it; Ella verifies.

---

*Phase 5 plan created Session 182, 9 April 2026. Final phase of Stage 8 — governance and promotion.*
