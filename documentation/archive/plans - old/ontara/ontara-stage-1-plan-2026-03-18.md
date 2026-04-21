# Ontara — Stage 1 Detailed Implementation Plan

**Date:** 18 March 2026 (Session 37)
**Prepared by:** Claude, in discussion with Ella Green
**Status:** Working document — for review and agreement before implementation
**Parent plan:** [[ontara-high-level-plan-2026-03-18|Ontara High-Level Development Plan]]
**Scope:** Stage 1 — Skeleton and First Content

---

## 1. Objective

Establish the Ontara Console application, produce the first working views (coverage matrix and package navigator), begin the Suds domain model, and set up the model infrastructure that connects the SysML model to the console.

By the end of Stage 1, Ella should be able to open the console in a browser and see the full coverage matrix — which meta model `part def`s exist, which domains instantiate them, and where the gaps are — with a navigable package tree alongside it. This directly addresses the architect's legibility problem.

---

## 2. Phasing

Stage 1 is divided into five phases, ordered by dependency. Each phase has a clear deliverable and should be reviewable before the next begins.

### Phase 1: Generator Foundation — Model Introspection JSON

**What:** Review, validate and extend `gen_model_introspection.py` so it produces reliable, console-ready JSON.

**Why first:** The console has nothing to display without data. The generator is the bridge between the SysML model and the frontend. It was written in Session 35 and has not yet been reviewed by Ella — this phase includes that review.

**Tasks:**

1. **Ella reviews `gen_model_introspection.py`.** Run it locally (`python scripts/gen_model_introspection.py --save --pretty`), inspect the output JSON at `generated/ontara/model-introspection.json`, and verify:
   - Are the element counts plausible? (Session 35 reported 503 elements, 64 meta model defs)
   - Is the meta model classification (BMM vs BSMM vs domain) correct for elements Ella can spot-check?
   - Are doc blocks being extracted sensibly?
   - Are any elements missing that should be present?

2. **Fix any issues found in the review.** The parser uses regex, which is inherently fragile (E8 — regex parsers as executable specifications). Known limitations to check: nested packages with `::` qualifiers, elements inside deeply nested blocks, elements whose doc block is separated by blank lines.

3. **Extend the output JSON to include package hierarchy data.** The existing `gen_package_hierarchy.py` produces a package tree. Either integrate its output into the introspection JSON, or produce a second JSON file (`package-hierarchy.json`). The console needs both — element data and structural navigation.

4. **Ensure the output JSON includes enough data for the coverage matrix view:**
   - Every BMM and BSMM `part def` as a row
   - Every domain (core, csw, and later suds) as a column
   - Per cell: list of `part` usages that instantiate the def, or empty
   - Meta model layer classification (bmm/bsmm) per def
   - Parent package per def (for filtering/grouping)

**Deliverable:** Reviewed, corrected `gen_model_introspection.py` and a reliable JSON file at `generated/ontara/model-introspection.json` that the console can consume. Ella has confidence in the data.

**Effort estimate:** 1–2 sessions (review may surface issues that need fixing).

**Register concepts exercised:** A3 (model generates everything), D9 (metadata-driven generation), E6–E8 (generator pipeline).

---

### Phase 2: Console Application Skeleton

**What:** Create the SvelteKit application at `console/` with sidebar navigation, dark mode, and the structural shell for views.

**Why:** Establishes the application skeleton that all subsequent views are built into. Borrowing heavily from the CSW layout pattern means this should be fast.

**Tasks:**

1. **Initialise the SvelteKit project.** Create `console/` at the repo root with:
   - `package.json` (dependencies: `flowbite`, `flowbite-svelte`, `flowbite-svelte-icons`, `tailwindcss` v4, `@tailwindcss/vite`)
   - `svelte.config.js` (adapter-auto, same pattern as CSW)
   - `vite.config.ts`
   - `tsconfig.json`
   - `src/app.html`, `src/app.css` (Ontara-themed colour palette — see §3)

2. **Create the root layout** (`src/routes/+layout.svelte`). Same structural pattern as CSW:
   - Fixed top navbar with "Ontara Console" branding and DarkMode toggle
   - Fixed sidebar with navigation groups
   - Main content area with `{@render children()}`
   - Mobile sidebar toggle

3. **Define the initial navigation structure.** Sidebar groups and pages:

   **Model Explorer**
   - Coverage Matrix (`/coverage`) — Stage 1, Phase 4
   - Package Navigator (`/packages`) — Stage 1, Phase 5
   - Component Catalogue (`/catalogue`) — Stage 2

   **Domains**
   - CSW Overview (`/domains/csw`) — placeholder
   - Suds Overview (`/domains/suds`) — placeholder
   - Paws Overview (`/domains/paws`) — placeholder

   **Architecture**
   - Pattern Graph (`/patterns`) — Stage 3
   - Meta Model Map (`/meta-model`) — Stage 3

   Pages not yet built get a simple placeholder: "This view will be built in Stage N."

4. **Create the data loading pattern.** The console consumes static JSON generated from the SysML model. Establish the convention:
   - Generator output goes to `generated/ontara/*.json`
   - The console reads these files. For the development server, configure Vite to serve from the `generated/` directory (or symlink/copy into `console/static/`). The simplest approach: a `console/static/data/` directory with a build script that copies from `generated/ontara/`.
   - A `+page.ts` (or `+page.server.ts`) `load` function fetches the JSON and passes it as page data.

5. **Verify it runs.** `cd console && pnpm install && pnpm dev` should produce a working app at `localhost:5173` (or similar) with the sidebar, dark mode, and placeholder pages.

**Deliverable:** A running SvelteKit application at `console/` with sidebar navigation, Ontara branding, dark mode, and placeholder pages.

**Effort estimate:** 1 session.

**Register concepts exercised:** I5 (console vs generated apps), I12 (console as architect's tool).

---

### Phase 3: Suds Domain Model — Initial Business Model

**What:** Create the Suds demonstrator SysML model with initial business model content.

**Why:** The coverage matrix needs a second domain column to be useful. Co-evolution (J2) requires model content alongside console development.

**Tasks:**

1. **Create the directory structure:**
   - `exercises/suds-demonstrator/model/suds.sysml`
   - Obsidian note: `02 ARCHITECTURE & MODELLING/Demonstrators/Suds (Laundry)/suds-domain-design.md`

2. **Check the SysML syntax reference** before writing any model content. Verify the patterns for package definition, part def, part usage, attribute redefinition, and doc blocks.

3. **Model the Suds business model.** Import relevant BMM `part def`s from the core model and instantiate them for a drop-off laundry service:

   **ServiceConcept package:**
   - `sudsValueProposition : ValueProposition` — convenience, quality care of fabrics, time saving
   - `sudsStandardWash : ServiceOffering` — standard wash-dry-fold
   - `sudsDelicates : ServiceOffering` — delicates/hand-wash
   - `sudsExpress : ServiceOffering` — express turnaround (same-day)
   - `walkInCustomer : CustomerSegment`, `subscriptionCustomer : CustomerSegment`
   - `shopCounter : Channel`, `onlineBooking : Channel`

   **ActivityModel package:**
   - `receiveItems : ActivityType` — intake, inspection, tagging
   - `sortAndLoad : ActivityType` — sorting by wash type, loading machines
   - `washCycle : ActivityType` — the wash itself
   - `dryAndFinish : ActivityType` — drying, pressing/folding
   - `qualityCheck : ActivityType` — inspection before return
   - `returnToCustomer : ActivityType` — notification, collection/delivery

   **ResourcePlanning package:**
   - `washingMachine : ResourceType`, `dryer : ResourceType`, `pressingEquipment : ResourceType`
   - `laundryOperator : ResourceType` — staff
   - `detergentsAndChemicals : ResourceType` — consumables (connects to COSHH governance)

   **FinancialPlanning package:**
   - `sudsStandardPricing : PricingModel` — per-kg or per-bag, with type surcharges
   - `laundryRevenue : RevenueStream`
   - `staffCosts : CostDriver`, `utilityCosts : CostDriver`, `chemicalCosts : CostDriver`
   - `sudsUnitEconomics : UnitEconomics` — cost per wash cycle, margin per bag

4. **Include a governance requirement from the start** (J8):
   - `coshh : requirement COSHHCompliance` — COSHH regulations for handling cleaning chemicals. Even if minimal, this exercises the `requirement def` → `satisfy` pattern in a non-health context.

5. **As each concept is modelled, mentally classify it:**
   - Which BMM `part def`s transferred directly from CSW? → General
   - Which needed Suds-specific adaptation? → Tailored (or note as a meta model gap)
   - Record these observations in the Obsidian design note for later Track 3 work.

6. **Update `gen_model_introspection.py`** to include the Suds domain source:
   ```python
   "suds": {
       "label": "Laundry (Suds)",
       "model_dirs": [EXERCISES_DIR / "suds-demonstrator" / "model"],
       "description": "Laundry service demonstrator — cross-domain validation",
   },
   ```

7. **Re-run the generator** and verify the Suds elements appear in the JSON with correct classification.

**Deliverable:** `exercises/suds-demonstrator/model/suds.sysml` with 15–20 BMM instantiations. Updated generator producing a three-column (core, csw, suds) coverage matrix. Obsidian design note with General/Tailored classification observations.

**Effort estimate:** 2–3 sessions.

**Register concepts exercised:** A5 (validate in toy domains), J1 (cross-domain validation), J8 (governance in toy domains), B11 (General/Tailored classification).

---

### Phase 4: Coverage Matrix View

**What:** Build the first interactive view in the console — a table showing meta model `part def`s vs domains, with filtering and grouping.

**Why:** This is the single most immediately useful view for the architect. It makes the layered architecture visible at a glance and highlights gaps.

**Tasks:**

1. **Create the data loader** (`src/routes/coverage/+page.ts`). Load the introspection JSON and extract the coverage matrix data.

2. **Build the Coverage Matrix component** (`src/routes/coverage/+page.svelte`):
   - **Rows:** One per BMM or BSMM `part def`. Grouped by parent package (collapsible groups).
   - **Columns:** One per domain (core/GSL, CSW, Suds). Additional domains added as they are created.
   - **Cells:** Show instantiation count or checkmark if instances exist; empty if not instantiated. Click a cell to see the list of `part` usages.
   - **Row styling:** Visual distinction between BMM defs (e.g. warm tone) and BSMM defs (e.g. cool tone).
   - **Header:** Summary stats — total defs, total instantiated, coverage percentage per domain.

3. **Add filtering controls:**
   - Filter by meta model layer: BMM only, BSMM only, both
   - Filter by coverage status: all, instantiated in at least N domains, uninstantiated
   - Text search on def name
   - These filters use Svelte 5 reactivity — `$state` for filter values, `$derived` for the filtered list.

4. **Keep it lightweight.** Flowbite Svelte provides `Table`, `TableHead`, `TableBody`, `TableRow`, `TableCell` components. Use those. The goal is functional and clear, not visually elaborate. Iterate later.

**Deliverable:** A working `/coverage` page showing the full coverage matrix with filtering. Ella can see at a glance which concepts are instantiated where.

**Effort estimate:** 1–2 sessions.

**Register concepts exercised:** I4 (Level 1 completeness tracking), I6 (filtered views), I12 (architect's tool).

---

### Phase 5: Package Navigator View

**What:** A collapsible tree showing the SysML package hierarchy, with element counts and clickable navigation.

**Why:** The package tree is the other axis of navigation — structural rather than coverage-based. Together with the coverage matrix, it gives two complementary ways to explore the model.

**Tasks:**

1. **Ensure package hierarchy data is available** in the JSON (from Phase 1, Task 3).

2. **Build the Package Navigator component** (`src/routes/packages/+page.svelte`):
   - **Collapsible tree:** Packages as tree nodes, expandable to show child packages and contained elements.
   - **Element counts:** Each package node shows the count of contained elements (part defs, part usages, enum defs, etc.).
   - **Meta model indicators:** Visual badges showing whether a package belongs to BMM, BSMM, or domain.
   - **Click-to-detail:** Clicking a package shows its contained elements in a detail panel (right side or below the tree).

3. **Link to coverage matrix.** Clicking a `part def` in the package navigator could navigate to the coverage matrix filtered to that def (or vice versa). This cross-linking is a lightweight start toward the "filtered views" vision (I6).

4. **Keep it simple.** A recursive Svelte component for the tree. Flowbite doesn't have a tree component, so this is a custom component — but the pattern is straightforward (recursive `{#each}` with indent levels and expand/collapse state).

**Deliverable:** A working `/packages` page showing the full package hierarchy with element counts and meta model classification.

**Effort estimate:** 1 session.

**Register concepts exercised:** I6 (filtered views), B4 (package structure).

---

## 3. Ontara Console Theme

The CSW demonstrator uses a warm coffee-shop palette. The Ontara Console needs its own identity — something that signals "platform development tool" rather than "coffee shop."

**Proposed palette direction:** Cool, professional tones — slate blue or teal as the primary, neutral greys for secondary. This distinguishes it visually from the CSW warm browns. The exact values can be tuned, but the structural pattern is the same as CSW: `--color-primary-*` and `--color-secondary-*` custom properties in `app.css`, consumed by Flowbite and Tailwind.

This is a minor decision — if Ella has a preference, we use it. If not, I'll propose specific hex values when building Phase 2.

---

## 4. Data Flow Summary

```
SysML model files (.sysml)
    │
    ▼
gen_model_introspection.py (Python, in scripts/)
    │
    ▼
generated/ontara/model-introspection.json
    │
    ▼ (copied or served to console/static/data/)
    │
    ▼
Console SvelteKit app (loads JSON in +page.ts)
    │
    ▼
Coverage Matrix, Package Navigator, etc.
```

The generator runs manually (Ella runs `python scripts/gen_model_introspection.py --save` after model changes). The console reads the latest JSON. No live connection to the SysML model — the JSON is a snapshot. This is consistent with the existing generation pipeline pattern (E1–E8) and keeps the console dependency-free at runtime.

A convenience script (`console/scripts/refresh-data.sh` or a `pnpm` script) can automate the copy step.

---

## 5. Dependencies and Prerequisites

| Phase | Depends on | Notes |
|---|---|---|
| Phase 1 (Generator) | Nothing — can start immediately | Ella's review is the critical path |
| Phase 2 (Console skeleton) | Nothing — can run in parallel with Phase 1 | Does not need real data to establish the skeleton |
| Phase 3 (Suds model) | SysML syntax reference check | Phase 1 generator extension needed to see Suds in the JSON |
| Phase 4 (Coverage matrix) | Phase 1 (data) + Phase 2 (skeleton) | First view that requires both |
| Phase 5 (Package navigator) | Phase 1 (data) + Phase 2 (skeleton) | Can run in parallel with Phase 4 |

Phases 1, 2 and 3 can advance in parallel. Phases 4 and 5 depend on 1 and 2 being complete but are independent of each other.

---

## 6. Estimated Total Effort

| Phase | Estimate |
|---|---|
| Phase 1: Generator foundation | 1–2 sessions |
| Phase 2: Console skeleton | 1 session |
| Phase 3: Suds initial model | 2–3 sessions |
| Phase 4: Coverage matrix view | 1–2 sessions |
| Phase 5: Package navigator | 1 session |
| **Total** | **6–9 sessions** |

This is a rough guide, not a commitment. Some phases may go faster (Phase 2 borrows heavily from CSW), some may surface issues that take longer (Phase 1 review, Phase 3 syntax questions).

---

## 7. Stage 1 Exit Criteria

Stage 1 is complete when:

- [ ] The Ontara Console runs locally and displays the coverage matrix and package navigator
- [ ] The coverage matrix shows three domains (core/GSL, CSW, Suds) with accurate instantiation data
- [ ] The Suds domain model has 15–20 BMM concept instantiations with at least one governance requirement
- [ ] General/Tailored classification observations have been captured in the Suds design note
- [ ] The generator pipeline produces reliable JSON consumed by the console
- [ ] A session report for Stage 1 has been written and the master register reviewed

At that point, we produce the Stage 2 detailed plan.

---

## 8. What This Plan Defers

- **General/Tailored metadata annotations in SysML** (Track 3 proper). Phase 3 captures the classification observations in an Obsidian note, but the actual SysML metadata annotations (`@CatalogueTag` etc.) are Stage 2 work. Stage 1 is about getting the data flowing and the first views working.
- **Component Catalogue view** — Stage 2.
- **Dual-canvas / assembly workspace** — Stage 3.
- **Graphical interaction libraries** (Svelvet, svelte-dnd-action) — not needed in Stage 1. The coverage matrix and package navigator are table/tree views, not canvas interactions.
- **AgencyClassification metadata** (9.1) — natural companion to the tagging work in Stage 2.

---

*Stage 1 implementation plan prepared 18 March 2026 (Session 37). For review and agreement before implementation begins.*
