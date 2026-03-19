# Ontara — Stage 3 Phase 2: Glossary View — Detailed Implementation Plan

**Date:** 19 March 2026 (Session 45)
**Prepared by:** Claude, in discussion with Ella Green
**Status:** For agreement before implementation
**Parent plan:** Stage 3 Detailed Plan (Session 43)
**Prerequisite:** Stage 3 Phase 1 complete (all exit criteria met)

---

## 1. Objective

Build the Glossary view in the Ontara Console — a searchable, browsable list of all `@UserFacing` elements with friendly names, short descriptions, and cross-references. This operationalises I15 (Glossary) and completes the comprehension layer (I14). The glossary is the tool Sam (non-technical user) needs to look up terms and understand what the meta model vocabulary means in plain language.

---

## 2. Current State

**Data foundation (already exists):**

- 26 BMM `part def`s carry `@CatalogueTag` annotations
- 12 of those 26 also carry `@UserFacing` annotations (46.2% coverage)
- 14 elements are in the `comprehension.missingUserFacing` list — they have catalogue tags but no friendly name/description yet
- The `model-introspection.json` already contains `userFacing` data on `coverageMatrix` entries
- The Component Catalogue already reads and displays `userFacing` data (friendly names, short descriptions) in its detail panel

**What doesn't exist yet:**

- No `/glossary` route in the console
- No sidebar entry for the Glossary
- No dedicated glossary page with alphabetical listing, search, and filtering

---

## 3. Design Decisions (for discussion)

| # | Question | Proposed Answer | Notes |
|---|---|---|---|
| P2-D1 | Scope: what appears in the glossary? | All `coverageMatrix` entries that have a non-empty `userFacing` object (i.e. `friendlyName` is populated) | This means the glossary starts at 12 entries and grows as Phase 3 adds more `@UserFacing` annotations. Elements without `@UserFacing` don't appear — the glossary only shows what has been explicitly described. |
| P2-D2 | Should elements *without* `@UserFacing` appear as "stub" entries? | No — show a coverage stat instead ("12 of 26 elements have glossary entries") | Keeps the glossary clean. Stubs would clutter it. The coverage stat motivates Phase 3. |
| P2-D3 | Filtering axes | BMM Concern (5 values) and Layer (BMM/BSMM) | Same axes as the Component Catalogue. Consistent UI patterns. |
| P2-D4 | Cross-links | Each glossary entry links to its Component Catalogue detail (via element name) and to the Coverage Matrix (via search parameter) | Reuses existing cross-link patterns from the catalogue. |
| P2-D5 | Page layout | Single-panel alphabetical list with inline expansion (click to expand detail), not the two-panel master-detail layout of the catalogue | The glossary is a reference list — Sam scrolls and scans. A two-panel layout is overkill for what is currently 12 entries and will grow to ~26. The inline expansion pattern keeps things compact. |
| P2-D6 | Domain instantiation in glossary entries? | Yes — show a compact summary: "Used in: Cafe (3), Suds (2), Paws (2)" | Gives immediate context for how widely a concept is used. Doesn't need the full instance listing (that's the catalogue's job). |
| P2-D7 | Sidebar placement | Under "Model Explorer", between "Governance" and the "Domains" section header | Logically grouped with the other model navigation tools. |
| P2-D8 | Sidebar icon | `BookOutline` from flowbite-svelte-icons | Book icon is the natural glossary metaphor. |

---

## 4. Scope — What Gets Built

### 4.1 New Route: `/glossary`

**Files created:**
- `console/src/routes/glossary/+page.ts` — data loader
- `console/src/routes/glossary/+page.svelte` — page component

### 4.2 Data Loading (`+page.ts`)

Loads `model-introspection.json` (same as catalogue and coverage). Extracts:

- All `coverageMatrix` entries where `userFacing` is non-empty (has `friendlyName`)
- `comprehension` summary for the coverage stat
- `facets` for filter options
- `domains` metadata for domain labels

No generator changes required — all data already exists in the JSON.

### 4.3 Page Component (`+page.svelte`)

**Header section:**
- Title: "Glossary"
- Subtitle: "Plain-language descriptions of meta model concepts"
- Coverage stat: "12 of 26 catalogue elements have glossary entries (46.2%)" — pulls directly from `comprehension`

**Controls row:**
- Search input (filters by friendly name, SysML name, short description, doc block)
- BMM Concern filter dropdown (ServiceConcept, ActivityModel, ResourceCapability, FinancialModel, Governance)
- Layer filter dropdown (All / BMM / BSMM)
- Count display: "Showing N of M"

**Glossary list:**
- Alphabetical by `friendlyName`
- Each entry is a collapsible card showing:
  - **Collapsed state:** Friendly name (bold), SysML identifier (mono, secondary), BMM concern badge, domain usage dots (same pattern as catalogue list)
  - **Expanded state (on click):** Short description, doc block excerpt (first ~200 chars with "..." truncation), domain usage summary ("Used in: Cafe (3), Suds (2), Paws (2)"), tags, cross-links to catalogue and coverage matrix

**Footer:**
- Generated timestamp (same pattern as other pages)

### 4.4 Sidebar Update (`+layout.svelte`)

Add a "Glossary" entry under "Model Explorer", after "Governance":

```svelte
<li>
  <a href="/glossary" class="...">
    <BookOutline class="h-5 w-5" />
    <span class="ms-3">Glossary</span>
  </a>
</li>
```

Import `BookOutline` from `flowbite-svelte-icons`.

### 4.5 Home Page Update (`+page.svelte`)

Add a Glossary card to the home page grid:

```
Glossary
Plain-language descriptions of meta model concepts. Look up what terms mean.
[Stage 3 badge]
```

### 4.6 Cross-Links

- **Glossary → Catalogue:** Link text "View in Component Catalogue" navigates to `/catalogue?search={elementName}`
- **Glossary → Coverage Matrix:** Link text "View in Coverage Matrix" navigates to `/coverage?search={elementName}`
- **Catalogue → Glossary (future consideration):** Not in scope for this phase, but the catalogue detail panel could gain a "View glossary entry" link later

---

## 5. Implementation Steps

### Step 1: Create data loader (`+page.ts`) — Claude Chat

Write the SvelteKit page load function. Extract glossary-eligible elements from `coverageMatrix` — those with a populated `userFacing.friendlyName`. Reuse the `CatalogueElement` type from `$lib/types/catalogue.ts` (it already has the right shape). Define a `GlossaryPageData` interface.

**Estimated size:** ~40 lines.

### Step 2: Create page component (`+page.svelte`) — Claude Chat

Build the glossary page following the established console patterns:
- Svelte 5 runes (`$state`, `$derived`, `$props`)
- Flowbite Svelte components (`Badge`, icons)
- Tailwind v4 utility classes matching the existing theme
- Dark mode support using the established `dark:` patterns

The page is a single-panel list with inline expansion. This is simpler than the catalogue's two-panel master-detail layout.

**Estimated size:** ~250–300 lines (comparable to or smaller than the catalogue page).

### Step 3: Update sidebar layout — Claude Chat

Add the Glossary nav entry to `+layout.svelte`. Import `BookOutline`.

**Estimated size:** ~10 lines changed.

### Step 4: Update home page — Claude Chat

Add a Glossary card to the `+page.svelte` grid.

**Estimated size:** ~10 lines added.

### Step 5: Ella reviews in browser

Open the console, navigate to `/glossary`, verify:
- All 12 `@UserFacing` elements appear
- Search filters correctly
- BMM Concern and Layer filters work
- Expand/collapse works
- Cross-links navigate correctly
- Dark mode renders correctly
- Mobile sidebar shows the new entry

### Step 6: Commit and push

```bash
cd ~/Developer/gsl-tech/gsl-sysml-model
git add console/src/routes/glossary/ console/src/routes/+layout.svelte console/src/routes/+page.svelte
git commit -m "Session 45: Stage 3 Phase 2 — Glossary view (12 @UserFacing elements, search, filtering, cross-links)"
git push origin main
```

---

## 6. What Is NOT In Scope

- **Expanding `@UserFacing` coverage** — that's Phase 3. The glossary launches with 12 entries and grows later.
- **Generator changes** — no changes to `gen_model_introspection.py`. All data already exists.
- **New type definitions** — the existing `CatalogueElement`, `UserFacing`, `CatalogueTag`, and `ComprehensionSummary` types in `$lib/types/catalogue.ts` already cover the glossary's data needs. We may add a `GlossaryEntry` type alias or a `GlossaryPageData` interface for clarity, but no new structural types are needed.
- **Catalogue → Glossary cross-links** — can be added later once the glossary is established.

---

## 7. Session Allocation

This is a straightforward console implementation with no model changes, no generator changes, and well-established UI patterns to follow. All four implementation steps (data loader, page, sidebar, home page) can be completed in a single session.

| Step | Effort | Tool |
|---|---|---|
| Step 1: Data loader | ~10 minutes | Claude Chat |
| Step 2: Page component | ~30 minutes | Claude Chat |
| Step 3: Sidebar update | ~5 minutes | Claude Chat |
| Step 4: Home page update | ~5 minutes | Claude Chat |
| Step 5: Browser review | Ella | Ella |
| Step 6: Commit | ~2 minutes | Shell |
| **Total** | **~1 session** | |

---

## 8. Register Concepts Exercised

| Concept | How |
|---|---|
| I15 (Glossary) | Directly implemented — the glossary view |
| I14 / I14a (Comprehension layer) | Glossary is part of the comprehension layer; coverage stat makes gaps visible |
| J2 (Co-evolution) | `@UserFacing` metadata (model) + glossary view (tooling) — both exist together |
| D9 (Metadata-driven generation) | Glossary content generated from model metadata via the existing introspection pipeline |
| A3 (Model generates everything) | Glossary data comes from the SysML model, not from a separate data source |

---

## 9. Exit Criteria

Phase 2 is complete when:

- [ ] `/glossary` route exists and renders correctly
- [ ] All `@UserFacing` elements appear in the glossary (currently 12)
- [ ] Search filters by friendly name, SysML name, and description
- [ ] BMM Concern and Layer dropdown filters work
- [ ] Each entry expands to show description, doc excerpt, domain usage, tags, and cross-links
- [ ] Cross-links to Component Catalogue and Coverage Matrix work
- [ ] Coverage stat displays correctly ("12 of 26 catalogue elements have glossary entries")
- [ ] Sidebar navigation includes Glossary entry with book icon
- [ ] Home page includes Glossary card
- [ ] Dark mode renders correctly
- [ ] Master register updated (I15 status)
- [ ] Committed to Git

---

## 10. Claude Code / Cowork Task Summary

| Task | Tool | Notes |
|---|---|---|
| Data loader | Claude Chat | Design judgement on data extraction |
| Page component | Claude Chat | Interactive UI with Svelte 5 patterns |
| Sidebar update | Claude Chat | Small edit to existing layout |
| Home page update | Claude Chat | Small edit to existing page |
| Browser review | Ella | Requires browser |

This phase is entirely Claude Chat work — no mechanical tasks suited to Claude Code, and no model or generator changes.

---

*Plan prepared 19 March 2026 (Session 45). For agreement before implementation.*
