---
tags:
  - plan
  - portal
  - implementation
date: 2026-04-08
status: active
session: 177
---
# Stage 8 Phase 3 — Domain Context and Module Composition: Detailed Implementation Plan
> `= this.file.path`

**Date:** 8 April 2026 (Session 177)
**Purpose:** Detailed implementation plan for Phase 3 of Stage 8 (Ontara Portal). Resolves the three open design questions from the high-level plan and specifies step-by-step implementation for Claude Code execution.
**Status:** Active. Produced as Session 177 deliverable.
**Depends on:** [[ontara-stage8-plan-high-level-s.174-portal|Stage 8 High-Level Plan (Session 174)]], [[ontara-discussion-portal-state-driven-operator-experience-2026-04-08|Portal Discussion Paper §7]], Phase 2 codebase (Session 176)

---

## Contents

- [[#1. Objective and Scope|§1. Objective and Scope]]
- [[#2. Design Decisions|§2. Design Decisions]]
- [[#3. What Exists After Phase 2|§3. What Exists After Phase 2]]
- [[#4. Implementation Steps|§4. Implementation Steps]]
- [[#5. Database Schema Changes|§5. Database Schema Changes]]
- [[#6. New Types|§6. New Types]]
- [[#7. Success Criteria|§7. Success Criteria]]
- [[#8. OW Items to Check During Implementation|§8. OW Items to Check During Implementation]]
- [[#9. Register Connections|§9. Register Connections]]

---

## 1. Objective and Scope

Phase 3 delivers three capabilities:

1. **Domain context model** — a shared resource layer structured along the six BMM concerns, visible and editable by the operator.
2. **Module wiring** — the ability to see how modules relate to each other through shared BMM concerns, with an explicit connections view.
3. **Composition guidance** — when installing a module, the portal explains what shared context it draws from, what it adds, and which existing modules it connects to. Inter-module lifecycle constraints surface as warnings when lifecycle actions would affect connected modules.

### 1.1 Out of scope for Phase 3

- Visual graph editor for module connections (future enhancement)
- Formal HardConstraint blocking of lifecycle transitions (Phase 5, governance)
- Module nesting or sub-module hierarchy
- Real data flow between modules (modules are still stateful shells)

### 1.2 Prototyping ethos

Build the simplest workable approach for each capability. The domain context model starts as schema-driven forms with concern-keyed storage. Module wiring is derived from BMM concern overlap, not manually drawn. Composition guidance is informational, not blocking. All three can be enriched as understanding grows.

---

## 2. Design Decisions

Three design questions from the [[ontara-stage8-plan-high-level-s.174-portal|high-level plan]] §14 resolved during Session 177:

### S177-D1: Domain context visibility and editability

**Decision:** The domain context is a new page (`/domains/[slug]/context`) showing the six BMM concerns as expandable sections. Each section shows: (a) domain-level shared values that apply across all modules (e.g. operating currency, jurisdiction, business name), and (b) a summary of which installed modules contribute to and draw from that concern.

Domain-level context values are stored in a new `domain_context` table with concern-keyed JSON, using the same schema-driven form pattern as module configuration. Each BMM concern has its own config schema defined in a seed file.

**Rationale:** Reuses the proven schema-driven form pattern from Phase 2. Structured by BMM concerns to maintain the architectural connection. Simple enough to build, structured enough to evolve.

### S177-D2: Module wiring representation

**Decision:** Module wiring is implicit — derived from shared BMM concern overlap — rather than manually drawn. A **connections panel** on each module's detail page shows which other modules share BMM concerns. On the dashboard, a **BMM concern coverage bar** shows which concerns are covered by installed modules and where gaps exist, giving the operator a compositional view.

**Rationale:** Avoids the significant engineering effort of a visual graph editor in Phase 3. The BMM concern overlap is the natural and architecturally grounded way to express module relationships. Manual wiring can be added later if the implicit approach proves insufficient.

### S177-D3: Inter-module lifecycle constraint presentation

**Decision:** When a lifecycle action would affect connected modules (those sharing BMM concerns), the system shows an **impact warning** before the action proceeds. This is a SoftConstraint-style warning: informational, not blocking. The operator sees which modules share context with the one being acted on and can proceed or cancel.

**Rationale:** Starts simple (warnings), avoids premature HardConstraint enforcement (which belongs in Phase 5 with governance). The impact analysis is derived from the BMM concern graph, requiring no additional data model beyond what exists.

---

## 3. What Exists After Phase 2

### 3.1 Database

- `users`, `sessions`, `domains`, `domain_memberships` (Phase 1)
- `module_definitions` — 7 seed definitions (6 business + 1 analytical), each with `bmm_concerns` JSON array and `config_schema` JSON
- `module_instances` — installed modules with `installation_state` and `operational_state`
- `module_state_transitions` — lifecycle transition history

### 3.2 Key files

- `$lib/types.ts` — `ModuleDefinition`, `ModuleInstance`, `ModuleInstanceWithDefinition`, lifecycle types
- `$lib/modules/lifecycle.ts` — shared lifecycle logic (validation, state display, available actions)
- `$lib/server/modules/lifecycle.ts` — server-side lifecycle logic
- `$lib/server/db/modules.ts` — module CRUD and queries
- `$lib/server/db/seed.ts` — 7 module definitions with BMM concern mappings and config schemas
- Routes: `(app)/domains/[slug]/+page.svelte` (dashboard), `catalogue/`, `modules/[moduleId]/`, `modules/[moduleId]/configure/`, `settings/`

### 3.3 BMM concern data already present

Each module definition already declares its `bmmConcerns` array:
- Service Offerings → `['ServiceConcept']`
- Customer Management → `['StakeholderModel', 'ServiceConcept']`
- Scheduling & Workflow → `['ActivityModel']`
- Team & Resources → `['ResourcePlanning']`
- Financial Tracking → `['FinancialPlanning']`
- Compliance & Governance → `['GovernanceMapping']`
- Business Overview → `['Cross-cutting']`

This existing data is the foundation for the concern-derived wiring.

---

## 4. Implementation Steps

### Step 3.1: Domain context data model and seed [Chat + Code]

**Objective:** Add the domain context table, define context schemas per BMM concern, and seed them.

**Chat produces:** This plan (done). Code executes below.

**[Code] Tasks:**

1. **Add `domain_context` table to `schema.sql`:**
   ```sql
   CREATE TABLE IF NOT EXISTS domain_context (
       id TEXT PRIMARY KEY,
       domain_id TEXT NOT NULL REFERENCES domains(id),
       concern TEXT NOT NULL,
       context_values TEXT NOT NULL DEFAULT '{}',
       updated_at TEXT NOT NULL DEFAULT (datetime('now')),
       UNIQUE(domain_id, concern)
   );
   ```

2. **Create `$lib/server/db/context.ts`** with CRUD functions:
   - `getContextForDomain(domainId)` → returns all 6 concern contexts for a domain
   - `getContextByConcern(domainId, concern)` → returns one concern's context
   - `upsertContext(domainId, concern, values)` → create or update a concern context
   - `initializeDomainContext(domainId)` → creates empty context rows for all 6 concerns (called during domain creation)

3. **Create `$lib/context/schemas.ts`** (in `$lib/`, not `$lib/server/` — shared between server and client per OW-19) with context config schemas for each BMM concern. Each schema uses the same `ConfigFieldDefinition[]` type as module config. Initial schemas:

   - **ServiceConcept:** `businessName` (text, required), `valueProposition` (text), `targetMarket` (text), `deliveryMode` (select: in-person / remote / hybrid)
   - **ActivityModel:** `operatingHours` (text), `peakPeriods` (text), `handoverProtocol` (text)
   - **ResourcePlanning:** `primaryPremises` (text), `staffCount` (number), `keyEquipment` (text)
   - **FinancialPlanning:** `currency` (select: GBP/EUR/USD), `vatRegistered` (boolean), `financialYear` (text), `targetRevenue` (number)
   - **GovernanceMapping:** `jurisdiction` (select: England & Wales / Scotland / Northern Ireland / Republic of Ireland), `regulatoryBodies` (text), `dataProtectionApproach` (select: basic / DPO appointed / outsourced)
   - **StakeholderModel:** `keyPartners` (text), `customerSegments` (text), `communityRelationships` (text)

4. **Update domain creation flow** (`$lib/server/db/domains.ts` → `createDomain()`) to call `initializeDomainContext()` after domain creation.

5. **Add types to `$lib/types.ts`:**
   ```typescript
   export type BmmConcern = 'ServiceConcept' | 'ActivityModel' | 'ResourcePlanning' | 'FinancialPlanning' | 'GovernanceMapping' | 'StakeholderModel';

   export interface DomainContext {
       id: string;
       domainId: string;
       concern: BmmConcern;
       contextValues: Record<string, unknown>;
       updatedAt: string;
   }
   ```

**Acceptance criteria:**
- `domain_context` table created on app start
- New domains get 6 empty context rows automatically
- Context CRUD functions work correctly
- Context schemas defined for all 6 concerns

---

### Step 3.2: Domain context page [Code]

**Objective:** Build the context editor page where the operator views and edits domain-level shared context.

**[Code] Tasks:**

1. **Create route `(app)/domains/[slug]/context/`** with `+page.server.ts` and `+page.svelte`.

2. **`+page.server.ts`:** Load all 6 domain contexts. Form actions: `updateContext` (receives concern key + form values, validates, upserts).

3. **`+page.svelte`:** Display the six BMM concerns as expandable card sections (use Flowbite Svelte `AccordionItem` or custom expandable cards). Each section shows:
   - Concern name and icon (reuse the concern-to-icon mapping from the module catalogue)
   - A brief description of what this concern covers (hard-coded prose, one sentence each — this is the comprehension layer seed)
   - The schema-driven config form for domain-level values
   - A "Modules in this concern" summary: list the installed modules whose `bmmConcerns` includes this concern, with their current operational state dot

4. **Add "Domain Context" link** to the sidebar navigation in the domain layout (`(app)/domains/[slug]/+layout.svelte`) and to the Quick Links sidebar on the dashboard.

5. **Visual design:** Each concern section uses a subtle colour accent or icon to distinguish it. The layout should feel like exploring the anatomy of the domain, not filling in a form. Emphasise the concern descriptions — the operator should understand what each dimension means in business terms.

**Acceptance criteria:**
- Context page loads showing all 6 concerns
- Operator can edit and save context values for each concern
- Module membership per concern is visible
- Navigation to context page works from sidebar and dashboard

---

### Step 3.3: Module connections panel [Code]

**Objective:** Add a connections view to each module's detail page showing how it relates to other modules through shared BMM concerns.

**[Code] Tasks:**

1. **Create `$lib/modules/connections.ts`** (shared, not server-only) with:
   - `findConnectedModules(module, allModules)` → returns modules sharing at least one BMM concern, with the shared concerns listed
   - `findConcernGaps(modules)` → returns BMM concerns not covered by any installed module
   - `getConcernCoverage(modules)` → returns a map of concern → modules[] for the dashboard coverage bar

2. **Extend the module detail page** (`(app)/domains/[slug]/modules/[moduleId]/+page.svelte`):
   - Add a **"Connections" section** below the existing content showing:
     - "Shares context with:" — list of connected modules with the shared concern(s) named and each module's state dot
     - "Draws from domain context:" — the BMM concerns this module maps to, with a link to the relevant section of the domain context page
   - If no connections exist: "This module operates independently — it does not share BMM concerns with other installed modules."

3. **Extend the module detail page server** (`+page.server.ts`) to load all domain modules (already available from the domain) so the connections can be computed.

**Acceptance criteria:**
- Module detail page shows connected modules by shared BMM concern
- Domain context concerns linked from the module detail page
- Independent modules correctly shown as having no connections

---

### Step 3.4: Dashboard concern coverage bar [Code]

**Objective:** Add a BMM concern coverage summary to the domain dashboard, giving the operator a compositional view of their installed modules.

**[Code] Tasks:**

1. **Add a concern coverage component** to the dashboard page (`(app)/domains/[slug]/+page.svelte`):
   - A horizontal bar or grid showing the 6 BMM concerns
   - Each concern shows: concern name, number of modules covering it, and a visual indicator (filled/empty/partial)
   - Concerns with no modules are shown as gaps (muted, with a "+" affordance linking to the catalogue filtered by that concern)
   - Concerns with modules are shown as covered, with the module count

2. **Place the coverage bar** between the domain header and the module grid — it is the compositional overview that frames the individual module cards below it.

3. **Make concern labels clickable** — clicking a concern navigates to the domain context page scrolled to that concern section.

**Acceptance criteria:**
- Dashboard shows all 6 BMM concerns with coverage status
- Gaps are visually distinct and link to the catalogue
- Covered concerns show module count
- Concern labels navigate to context page

---

### Step 3.5: Composition guidance on module installation [Code]

**Objective:** When installing a new module from the catalogue, the system explains what shared context it will draw from, what it adds, and which existing modules it connects to.

**[Code] Tasks:**

1. **Extend the catalogue install flow** (`(app)/domains/[slug]/catalogue/+page.svelte` and/or a new install confirmation step):
   - When the operator clicks "Install" on a catalogue module, show a **composition preview** before completing the installation:
     - "This module covers: [list of BMM concerns]"
     - "Shares context with: [list of already-installed modules sharing concerns, if any]"
     - "New to your domain: [BMM concerns not previously covered, if any]"
     - "Domain context it will draw from: [list of domain-level values relevant to its concerns, showing current values or 'not yet configured']"
   - The preview is a modal or an expanded panel on the catalogue page, not a separate route
   - "Install" button proceeds; "Cancel" returns to the catalogue

2. **Comprehension prose:** Each piece of the composition preview uses plain business language, not technical terminology. For example: "Your new Scheduling & Workflow module will use your domain's operating hours and can connect with Team & Resources to match available staff to appointment slots." This prose is hard-coded per module definition for the prototype — the comprehension architecture connection is directional, not automated.

3. **Add a `compositionHints` field to module definitions** (optional JSON in `module_definitions` table, or a new `$lib/modules/composition-hints.ts` file mapping definition IDs to prose). For the prototype, a TypeScript map is simpler than a schema change.

**Acceptance criteria:**
- Installing a module shows a composition preview before completing
- Preview correctly identifies shared concerns, connected modules, and gaps
- Comprehension prose explains connections in business terms
- Installation still works correctly after the preview step

---

### Step 3.6: Lifecycle impact warnings [Code]

**Objective:** When a lifecycle action affects a module that shares BMM concerns with other active modules, show an impact warning.

**[Code] Tasks:**

1. **Create `$lib/modules/impact.ts`** (shared) with:
   - `assessLifecycleImpact(module, action, allModules)` → returns `{ hasImpact: boolean, affectedModules: { module, sharedConcerns, currentState }[] }`
   - Impact is relevant when the action is `stop`, `pause`, or `trash` and other modules sharing concerns are in `active` or `paused` state

2. **Extend the dashboard lifecycle action** (`(app)/domains/[slug]/+page.server.ts` form action `transition`):
   - Before executing the transition, compute the impact
   - If impact exists, return a `confirm` response instead of executing immediately
   - The client shows a confirmation modal: "Stopping [module] may affect [list of connected modules] which share [concern] context. Proceed?"
   - The client resubmits with a `confirmed=true` field to execute

3. **Extend the module detail page lifecycle actions** with the same impact warning pattern.

4. **Visual design:** The impact warning uses a yellow/amber warning panel (Flowbite `Alert` with `color="yellow"`), listing affected modules with their state dots and shared concerns.

**Acceptance criteria:**
- Stopping/pausing/trashing a module with active connected modules shows an impact warning
- Warning lists affected modules and shared concerns
- Operator can proceed or cancel
- Actions on modules with no connections proceed without warning
- Actions that don't affect other modules (activate, resume) proceed without warning

---

### Step 3.7: Integration testing and polish [Code]

**Objective:** End-to-end testing of the composition flow and visual polish.

**[Code] Tasks:**

1. **Test the full composition flow:**
   - Create a new domain → verify 6 empty context rows created
   - Edit domain context values → verify persistence
   - Install Service Offerings → verify composition preview, no connections
   - Install Customer Management → verify composition preview shows connection to Service Offerings via ServiceConcept
   - View dashboard → verify coverage bar shows 2 of 6 concerns covered
   - View module detail → verify connections panel shows the link
   - Stop Service Offerings → verify impact warning mentions Customer Management
   - Install all 7 modules → verify full coverage bar, rich connections

2. **Polish:**
   - Consistent spacing and typography across new pages
   - Dark mode support for all new components
   - Empty states for context page when no modules installed
   - Loading states where appropriate

3. **Commit with descriptive message:** `Session 177+: Phase 3 — Domain Context and Module Composition`

**Acceptance criteria:** All Phase 3 success criteria from the high-level plan (§7) met.

---

## 5. Database Schema Changes

One new table added to `portal/src/lib/server/db/schema.sql`:

```sql
CREATE TABLE IF NOT EXISTS domain_context (
    id TEXT PRIMARY KEY,
    domain_id TEXT NOT NULL REFERENCES domains(id),
    concern TEXT NOT NULL,
    context_values TEXT NOT NULL DEFAULT '{}',
    updated_at TEXT NOT NULL DEFAULT (datetime('now')),
    UNIQUE(domain_id, concern)
);
```

No changes to existing tables. The `module_definitions` table already has `bmm_concerns` — no schema change needed for the concern-derived wiring.

---

## 6. New Types

Added to `$lib/types.ts`:

```typescript
export type BmmConcern = 'ServiceConcept' | 'ActivityModel' | 'ResourcePlanning'
    | 'FinancialPlanning' | 'GovernanceMapping' | 'StakeholderModel';

export interface DomainContext {
    id: string;
    domainId: string;
    concern: BmmConcern;
    contextValues: Record<string, unknown>;
    updatedAt: string;
}

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
```

---

## 7. Success Criteria

From the [[ontara-stage8-plan-high-level-s.174-portal|high-level plan]] §7, Phase 3:

| # | Criterion | How met |
|---|---|---|
| P3-1 | Domains have a shared context structured along BMM concerns | Steps 3.1, 3.2: `domain_context` table + context page with 6 concern sections |
| P3-2 | Modules can be wired together with defined connections | Steps 3.3, 3.4: connections panel on module detail + coverage bar on dashboard |
| P3-3 | Inter-module lifecycle constraints are enforced (with warnings/explanations) | Step 3.6: impact warnings on lifecycle actions affecting connected modules |
| P3-4 | The operator receives comprehensible guidance when composing modules | Step 3.5: composition preview on install with business-language explanations |
| P3-5 | The dashboard shows module relationships, not just individual module states | Step 3.4: BMM concern coverage bar shows compositional structure |

---

## 8. OW Items to Check During Implementation

| ID | Summary | How it applies |
|---|---|---|
| OW-14 | Comprehension untested against compositional complexity | Phase 3 is the first test — composition hints are hard-coded prose, not dynamically generated. Note whether the static approach is sufficient or whether dynamic generation is needed |
| OW-18 | Module taxonomy is empirical | Watch whether composition reveals new module role patterns beyond business/analytical/generative |
| OW-19 | `$lib/server/` boundary | All shared logic (`connections.ts`, `impact.ts`, `schemas.ts`) goes in `$lib/modules/` or `$lib/context/`, NOT `$lib/server/` |
| OW-20 | Svelte 5 SSR guard | Any new client-side state (e.g. modal visibility) uses `$state()` + `$effect` pattern if touching browser APIs |

---

## 9. Register Connections

| Register concept | How exercised |
|---|---|
| [[principle-two-meta-model-distinction\|A4]] | The six BMM concerns structure the domain context — this is BMM made directly visible to the operator |
| [[principle-self-describing-system\|A2]] | Composition guidance explains module relationships in business terms |
| [[principle-intrinsic-self-knowledge\|A10]] | Concern coverage computed from live module state, not stored statically |
| [[concept-co-evolution\|J2]] | Domain context model and its UI built together |
| [[concept-non-constraining\|J3]] | Implicit wiring from BMM concerns does not prevent future manual wiring |
| [[principle-discipline-as-load-bearing-structure\|A9]] | Schema-driven forms maintain structural consistency |
| [[concept-multi-tenancy\|A13]] | Domain context is per-domain — each tenant has its own context |
| [[concept-service-concept\|C1]] | ServiceConcept directly surfaced as a domain context concern |

---

*Phase 3 implementation plan produced Session 177, 8 April 2026. Resolves three design questions (S177-D1 to S177-D3). Steps tagged [Code] for Claude Code execution with explicit instructions, file paths, and acceptance criteria.*
