# Plan: Coffee Shop Frontend — Bringing the System to Life

**Project:** GenderSense (GSL) — Coffee Shop Demonstrator
**Date:** 12 March 2026
**Status:** Proposal for review
**Context:** Post Business Meta Model Phase 7 (Session 19). All backend infrastructure operational: Temporal workflows, XState lifecycle, EHRbase CDR, composition builders, AQL entity views, governance audit, generated pathway diagram, generated types and state machines.

---

## 1. Purpose and Rationale

The coffee shop demonstrator currently has a functional but utilitarian frontend — unstyled HTML forms, raw tables, pipe-delimited navigation. It was built as a test harness for validating architectural patterns, and it served that purpose well. But it doesn't invite the kind of exploratory, creative, *empowered* thinking that has driven some of the project's most forward-looking features.

The goal is not a polished product. It's a **tangible, interactive proxy for the real system** — something you can sit down with, click through, watch the state machine work, trigger a governance audit, see an evaluation result, and have ideas about what the clinical system should feel like. It should be attractive enough that it's pleasant to use and clear enough that it communicates the architectural concepts to anyone who sees it — Sam, a colleague, an investor, or future-you after a break.

### What this is not

- Not a redesign of the backend (all existing API routes, Temporal workflows, EHRbase integration, and generated code remain untouched)
- Not a new application (same SvelteKit app, same package structure, same dev workflow)
- Not indulgent — clean, purposeful design that makes the system's capabilities visible, not decorative polish

### What this is

A frontend rewrite of the existing SvelteKit pages to create a cohesive, well-designed interface that puts every operational capability of the coffee shop system at your fingertips — and, where possible, runs ahead of the backend to sketch capabilities that the real system will need.

---

## 2. Current State Assessment

### What exists and works (backend — untouched)

| Capability | Backend | API Route | Status |
|---|---|---|---|
| Place an order | Temporal workflow start | `POST /api/orders` | Working |
| View order state | Temporal query (XState) | `GET /api/orders/[id]` | Working |
| Send signal (advance state) | Temporal signal | `POST /api/orders/[id]/signal` | Working |
| List all orders | Temporal workflow list | `GET /api/orders/list` | Working |
| Audit report (per order) | Temporal event history | `GET /api/orders/[id]/audit` | Working |
| Entity view: all orders | AQL → EHRbase | `GET /api/entity/orders` | Working |
| Entity view: today's orders | AQL → EHRbase (date filter) | `GET /api/entity/orders/today` | Working |
| Entity view: customer orders | AQL → EHRbase (EHR filter) | `GET /api/entity/customers/[ehr]/orders` | Working |
| Governance audit | AQL comparison (orders vs preps) | `GET /api/entity/governance` | Working |
| Submit feedback | Direct CDR commit | `POST /api/entity/feedback` | Working |
| List feedback | AQL → EHRbase | `GET /api/entity/feedback` | Working |
| Pathway diagram | Static SVG from gen_mermaid | `/fulfil-drink-pathway.svg` | Working |

### What exists but is minimal (frontend — to be rewritten)

| Page | Current state | Issues |
|---|---|---|
| Home / New Order | Unstyled form, 3 fields, no context | No sense of "the coffee shop" |
| Orders list | Raw table, emoji status badges | Functional but flat |
| Order detail | State label, signal button, raw history table | Doesn't visualise the lifecycle |
| Audit report | Step compliance table | Good data, poor presentation |
| Entity views | Three buttons, raw table | No visual distinction from process view |
| Feedback | Form + list table | Disconnected from the order flow |
| Governance | Summary cards + expandable customer detail | Best-designed current page — good pattern to follow |
| Pathway | Static SVG + HTML step table | Static, no interactivity |
| Layout | Pipe-delimited nav bar, no global styling | No visual identity |

---

## 3. Design Principles

### 3.1 Visual identity: warm, confident, minimal

A coffee shop. Not a clinical system, not a SaaS dashboard. Warm neutral palette (cream, brown, charcoal), a hint of personality in the typography and iconography, generous whitespace. The design should say "this is a real place that runs well" — which is exactly the feeling the clinical system should eventually evoke.

### 3.2 System concepts made visible

Every architectural concept should be *visible* in the UI, not hidden behind API calls:

- The **state machine** should be a visual element you can see transitioning, not a text label
- The **two-layer architecture** should be apparent — process view vs entity view, clearly navigable
- **Governance** should feel like a first-class capability, not a debug tool
- **CDR data** should be visually distinct from **workflow state** — two views onto the same reality

### 3.3 Operational, not decorative

Every screen should let you *do* something or *understand* something. No empty states without guidance. No data without context. Every table row should invite the next action.

---

## 4. Technology: Tailwind CSS v4 + Flowbite Svelte

### 4.1 Rationale

The styling infrastructure draws on proven work from the GSL Newsletter Control Panel project (sv01–sv10 iterations, June–August 2025). That project systematically worked through Tailwind CSS v4 integration with Flowbite Svelte in SvelteKit, resolving compatibility issues with Svelte 5 rune syntax, dark mode initialisation, and component library interop. The result was a documented, repeatable setup captured in the SV6 Setup Guide.

Using this stack for the coffee shop frontend:
- **Carries forward tested knowledge** — the Tailwind v4 + Flowbite configuration was hard-won and is well-documented
- **Provides production-ready components** — Card, Badge, Button, Alert, Table, Modal, Sidebar, Navbar, DarkMode, Spinner, and others, all with dark mode support and accessibility
- **Establishes the visual language for the clinical system** — whatever works for the coffee shop frontend will directly inform the GenderSense patient portal, clinician dashboard, and governance interfaces
- **Avoids reinventing styling** — the existing inline styles in the coffee shop app don't scale; Tailwind utilities + Flowbite components do

### 4.2 Known-good configuration (from sv10)

The following configuration was validated as working in the most recent newsletter control panel iteration (sv10, `flowbite-svelte@^1.8.1`, Svelte 5, Tailwind v4):

**Vite configuration** (`vite.config.ts`):
```typescript
import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  plugins: [sveltekit(), tailwindcss()]
});
```

**CSS configuration** (`src/app.css`) — the critical integration point:
```css
@import "tailwindcss";
@plugin "flowbite/plugin";
@source "../node_modules/flowbite-svelte/dist";
@source "../node_modules/flowbite-svelte-icons/dist";
@custom-variant dark (&:where(.dark, .dark *));
```

**Dark mode initialisation** (`src/app.html`) — inline script before render:
```html
<script>
  (function () {
    try {
      const stored = localStorage.getItem("color-theme");
      const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
      const shouldBeDark = stored === "dark" || (!stored && prefersDark);
      if (shouldBeDark) {
        document.documentElement.classList.add("dark");
      } else {
        document.documentElement.classList.remove("dark");
      }
    } catch (e) {}
  })();
</script>
```

**Key dependencies** (known-good versions from sv10):
```
tailwindcss@^4.1.10
@tailwindcss/vite@^4.1.10
flowbite@^3.1.2
flowbite-svelte@^1.8.1
flowbite-svelte-icons@^2.2.1
clsx@^2.1.1
tailwind-merge@^3.3.1
```

### 4.3 Integration considerations for the coffee shop

**pnpm monorepo.** The coffee shop uses a pnpm workspace (`packages/web`, `packages/temporal`, `packages/shared`). The Tailwind `@source` directive resolves `flowbite-svelte` from `node_modules`, which in a pnpm workspace may be hoisted to the workspace root. This needs verification during setup — the `@source` path may need adjustment.

**No Supabase.** The coffee shop's data layer is EHRbase (openEHR CDR) and Temporal. The Supabase client and environment variables from the newsletter control panel are not needed.

**Svelte 5 compatibility.** The coffee shop codebase already uses Svelte 5 runes (`$state`, `$derived`, `$props`). The sv10 layout uses Flowbite's `Navbar`, `NavBrand`, `NavUl`, `NavLi`, and `DarkMode` components successfully with `flowbite-svelte@^1.8.1`. However, sv10 still uses `import { page } from '$app/stores'` (Svelte 4 pattern) rather than `$app/state`. During setup, we should check whether the current Flowbite Svelte version now supports `$app/state`, and whether the library has progressed further since last summer (the `flowbite-svelte-next` branch for native Svelte 5 support was in development).

**Version check required.** Before locking dependency versions, check the current state of `flowbite-svelte` on npm — versions, Svelte 5 support status, and any breaking changes since 1.8.1. The SV6 guide documented workarounds that may no longer be necessary.

### 4.4 Flowbite components planned for use

| Component | Coffee shop use | Clinical system analogue |
|---|---|---|
| `Navbar`, `NavBrand`, `NavUl`, `NavLi` | Top navigation bar | Clinician/patient portal navigation |
| `Sidebar`, `SidebarItem`, `SidebarGroup` | Section navigation (Operations / Data / System) | Dashboard navigation |
| `Card` | Order cards, dashboard panels, audit sections | Patient cards, pathway panels |
| `Badge` | State labels, status indicators | Pathway state, compliance status |
| `Button` | Actions, signal sending, form submission | Clinical actions, workflow steps |
| `Alert` | Evaluation results, compliance status, feedback | Clinical alerts, safety notifications |
| `Table`, `TableHead`, `TableBody`, `TableBodyRow` | Entity views, audit tables, order history | Clinical record tables, governance reports |
| `Modal` | Order detail, pathway step info | Consultation detail, decision support |
| `DarkMode` | Theme toggle | Theme toggle |
| `Spinner` | Loading states | Loading states |
| `Breadcrumb` | Page hierarchy | Navigation breadcrumbs |
| `Toggle` | Settings, view switches | Feature toggles |

### 4.5 Coffee shop theme

The `@theme` block in `app.css` will define a coffee shop palette rather than the newsletter control panel's orange/sky-blue:

```css
@theme {
  /* Warm neutrals — coffee shop feel */
  --color-primary-50:  #faf6f1;
  --color-primary-100: #f0e6d6;
  --color-primary-200: #e0ccad;
  --color-primary-300: #cba87a;
  --color-primary-400: #b88a52;
  --color-primary-500: #a67639;
  --color-primary-600: #8c5f2c;
  --color-primary-700: #724b24;
  --color-primary-800: #5e3d22;
  --color-primary-900: #4e331f;

  /* Accent — espresso/charcoal */
  --color-secondary-50:  #f5f5f4;
  --color-secondary-100: #e7e5e4;
  --color-secondary-200: #d6d3d1;
  --color-secondary-300: #a8a29e;
  --color-secondary-400: #78716c;
  --color-secondary-500: #57534e;
  --color-secondary-600: #44403c;
  --color-secondary-700: #373330;
  --color-secondary-800: #292524;
  --color-secondary-900: #1c1917;
}
```

These are indicative — the exact palette will be refined during implementation. The key point is that the coffee shop should have its own visual identity, not reuse the newsletter control panel's branding.

---

## 5. Proposed Page Architecture

### 5.1 Global shell

Replace the pipe-delimited nav with a proper Flowbite layout:

- **Left sidebar** (collapsible, using Flowbite `Sidebar`): navigation grouped into three sections:
  - **Operations** — New Order, Active Orders, Order History
  - **Data & Insights** — Entity Views, Governance Audit, Feedback
  - **System** — Pathway Model, System Status (new)
- **Top bar** (using Flowbite `Navbar`): coffee shop name, current time, connection status indicators (Temporal, EHRbase), `DarkMode` toggle
- **Main content area**: routed pages
- **Global CSS**: `app.css` with Tailwind v4 + Flowbite integration and coffee shop `@theme` palette

### 5.2 Page designs

#### Home → "Counter" (new order + active orders dashboard)

The landing page is the counter — what a barista sees. Split view:

- **Left panel**: New order form (same fields, but styled as a point-of-sale card using Flowbite `Card`, `Input`, `Select`, `Button`). Drink selection with visual tiles rather than a dropdown. Size as toggle buttons.
- **Right panel**: Active orders — live-updating cards (Flowbite `Card` + `Badge` for state) showing each in-progress order with its current state, time elapsed, and the next action button. This replaces the separate "order detail" flow for active orders — you can advance the state right from the dashboard.

This is a significant UX improvement: currently you place an order, get redirected to a detail page, do one action, and can't see other orders. The counter view shows everything at once.

#### Order Detail → "Order Timeline"

When you click into a specific order (from the counter or from history), you see:

- A **visual state machine** — the five states as connected nodes, with the current state highlighted (Flowbite `Badge` for state labels), completed states checked, and the next transition available as a button *on the diagram itself*
- A **timeline** below the diagram — each event (signal received, activity completed, state transition) as a timestamped entry with the XState event name
- **CDR record** — if the order has a composition in EHRbase, show it (composition UID, archetype, key data fields) alongside the workflow state in a Flowbite `Card`. This makes the two-data-path architecture visible: "workflow says *in preparation*, CDR says *order record committed at 10:34*"
- **Audit compliance** — inline, not on a separate page. Each step shows expected vs actual timing with a visual indicator (Flowbite `Alert` for compliance status)

#### Orders → "Order Board"

A kanban-style board with columns for each lifecycle state: Placed, In Preparation, Ready, Collected, Cancelled. Orders as Flowbite `Card` elements move between columns as signals are sent. This is the visual expression of the XState state machine at population level.

For historical orders, a filterable Flowbite `Table` below the board (or a toggle between board and table view).

#### Entity Views → "Records" (CDR explorer)

Redesigned to make the two-view-onto-same-data concept clear:

- **Header**: explanation of what entity views are and how they differ from the process view
- **Tabbed interface**: All Records, Today, By Customer — replacing the three separate buttons
- **Visual query indicator**: show the AQL query source and the archetype being queried (making the openEHR layer visible)
- **Record cards** (Flowbite `Card`) rather than raw table rows — each order record shows key fields in a structured card, with a link to the corresponding workflow (if one exists) and the composition UID for CDR traceability

#### Governance → "Audit Dashboard"

The current governance page is already the best-designed page. Refinements:

- **Summary visualisation**: compliance rate as a gauge or progress ring, not just a number
- **Customer detail**: keep the expandable pattern but style with Flowbite `Card` and `Alert` components
- **Governance question**: make it more prominent — this is the clinical analogy anchor
- **Trend line** (future/placeholder): compliance over time, even if it's just showing the last N audit runs

#### Feedback → "Customer Voice"

Integrate feedback more closely with the order flow:

- After an order reaches "collected" state, surface a feedback prompt on the order timeline
- Feedback list shows star ratings visually, links back to the order it references
- CDR source indicator (Flowbite `Badge`): "This feedback was committed directly to the CDR — no workflow involved"

#### Pathway → "Process Model"

Make the static SVG interactive:

- Highlight the current step for any selected active order
- Click a step to see its metadata annotations (`@TemporalActivity`, `@TemporalSignal`, timeout values) in a Flowbite `Modal`
- Show the two-layer relationship: "Domain step: *Prepare the drink* → Orchestration step: *prepareDrink activity + drinkReady signal wait*"

#### System Status → new page

This is the page that runs ahead of the backend. Even before the self-assessment architecture is wired up at runtime, this page can show:

- **Structural inventory** from the system manifest (if it's accessible): packages, constraints, pathways, entities
- **Temporal health**: worker status, active/completed/failed workflow counts
- **EHRbase health**: CDR reachable, template list, composition count
- **Connection indicators**: green/red for each infrastructure dependency (Flowbite `Badge` with semantic colours)
- A **placeholder self-assessment panel** (Flowbite `Card` + `Alert`): "The coffee shop has processed N orders today. N are in progress. N were completed in the last hour. The preparation completion rate is N%." — computed from the existing API data, foreshadowing the five-layer self-knowledge dashboard

---

## 6. Implementation Approach

### Phase 1: Foundation (1–2 stages)

- **Check current Flowbite Svelte version and Svelte 5 compatibility status** — npm registry, changelog, `flowbite-svelte-next` status
- Install Tailwind CSS v4 + Flowbite Svelte dependencies into `packages/web/`
- Add `@tailwindcss/vite` plugin to `vite.config.ts`
- Create `src/app.css` with Tailwind v4 + Flowbite integration and coffee shop `@theme` palette
- Update `src/app.html` with dark mode initialisation script and body classes
- Build the layout shell: Flowbite `Sidebar` + `Navbar`, content area, `DarkMode` toggle
- Restyle the existing home page as the "Counter" view with the new visual language but the same form logic
- **Verify**: pnpm workspace `@source` path resolution, dark mode toggle, all existing API routes still work
- Commit: `git commit -m "Coffee shop frontend: Tailwind v4 + Flowbite foundation"`

### Phase 2: Operations Pages (2–3 stages)

- Build the **Counter** split view (new order + active orders dashboard)
- Build the **Order Board** (kanban columns by lifecycle state)
- Build the **Order Timeline** (visual state machine + event timeline + CDR record + inline audit)
- All three pages use the same API routes — no backend changes

### Phase 3: Data & Insights Pages (2–3 stages)

- Restyle **Records** (entity views) with tabbed interface, record cards, query indicators
- Restyle **Audit Dashboard** (governance) — refine the existing good design, add visualisation
- Restyle **Customer Voice** (feedback) with visual ratings and order linkage

### Phase 4: System Pages (1–2 stages)

- Build the **Process Model** page with step-highlighting for active orders
- Build the **System Status** page with infrastructure health and placeholder self-assessment
- These two pages are the "runs ahead" element — they sketch capabilities the backend doesn't yet provide, stimulating thinking about what the clinical system dashboard should show

### Estimated total: 6–10 stages across 2–4 sessions

This is design-intensive work that benefits from iteration — do a page, look at it, refine. Not a single large batch.

---

## 7. What This Enables

### Immediate

- A coffee shop system you can sit down with and *use* — place orders, watch them flow through the state machine, run a governance audit, browse CDR records, see the pathway model
- A visual language that communicates the architectural concepts to anyone who sees it
- A development environment that *invites* interaction and creative thinking

### For the clinical system

- Every design pattern explored here (state machine visualisation, timeline views, two-data-path presentation, governance dashboards, self-assessment panels) directly informs the clinical UI design
- The System Status page is a prototype for the Knowledge layer self-assessment dashboard
- The Order Timeline pattern is a prototype for the patient pathway view
- The Entity Views pattern is a prototype for the clinical record browser
- The Tailwind + Flowbite configuration and component patterns transfer directly to the clinical frontend

### For the demonstrator practice

- The coffee shop demonstrator becomes something you can *show* people — not just tell them about
- Future increments (Knowledge Layer Increments 1–3 from the integration plan) have a UI ready to receive them: constraint evaluation results appear on the order timeline, decision table routing appears on the counter, self-assessment appears on the system status page

---

## 8. What This Does Not Do

- Does not change any API routes, Temporal workflows, or EHRbase integration
- Does not add new backend capabilities (the System Status page aggregates existing data)
- Does not require any hosting or deployment — runs entirely locally (`localhost:5173`)
- Does not need Supabase, Render, or any external service beyond the existing local Temporal and EHRbase infrastructure

---

## 9. Reference Material

### From the GSL Newsletter Control Panel project

| Document | Location | Relevance |
|---|---|---|
| SV6 Setup Guide | `gsl-newsletter-control-panel/dev_notes_&_guides/SV6 SETUP GUIDE (LATEST).md` | Complete step-by-step Tailwind v4 + Flowbite setup, known pitfalls, Svelte 5 workarounds |
| SV Apps Summary | `gsl-newsletter-control-panel/dev_notes_&_guides/SV APPS SUMMARY.md` | Iteration history sv01–sv10, what each version added |
| Flowbite Workflow | `gsl-newsletter-control-panel/dev_notes_&_guides/SV FLOWBITE - WORKFLOW.md` | Component usage patterns |
| Flowbite Buttons Guide | `gsl-newsletter-control-panel/dev_notes_&_guides/HOW TO USE BUTTONS IN FLOWBITE SVELTE.md` | Button component specifics |
| Theme Configuration | `gsl-newsletter-control-panel/dev_notes_&_guides/SV THEME CONFIGURATION.md` | `@theme` block patterns |
| SvelteKit-Flowbite Summary | `gsl-newsletter-control-panel/dev_notes_&_guides/sveltekit-flowbite-summary-25.06.25.md` | Strategic summary of stack decisions |
| sv10 (latest iteration) | `gsl-newsletter-control-panel/sv10/` | Most recent working codebase with Flowbite Svelte 1.8.1, Navbar components working |

### Key lessons from the newsletter project

1. **`@import "tailwindcss"` replaces the old `@tailwind base/components/utilities` directives** — using v3 syntax with v4 causes silent failures
2. **`@custom-variant dark (&:where(.dark, .dark *))` is critical** — without this exact syntax, Flowbite's dark mode classes don't work in Tailwind v4
3. **`@source` directives must resolve to the actual `node_modules` path** — in a pnpm workspace this may differ from a standard npm project
4. **Flowbite Svelte's `DarkMode` component had `invalid_default_snippet` issues in Svelte 5** — the SV6 guide documents a custom JS toggle workaround, but this may be resolved in newer Flowbite versions
5. **`$app/stores` vs `$app/state`** — Flowbite Svelte internally used `$app/stores`; check whether current versions support `$app/state`
6. **The dark mode init script must run before render** — placing it in `app.html` or `<svelte:head>` prevents the flash of wrong theme

---

*Plan prepared 12 March 2026. Updated to include Tailwind CSS v4 + Flowbite Svelte integration details from the GSL Newsletter Control Panel project (sv01–sv10, June–August 2025). Builds on the existing coffee shop demonstrator infrastructure (Phases A–D, CDR Exercise Phases A–E, Business Model Extensions Phases 1–7).*
