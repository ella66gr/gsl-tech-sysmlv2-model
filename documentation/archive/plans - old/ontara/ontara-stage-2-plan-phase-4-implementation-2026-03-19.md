# Ontara — Stage 2 Phase 4 Detailed Implementation Plan
# Component Catalogue View

**Date:** 19 March 2026 (Session 40)
**Prepared by:** Claude, in discussion with Ella Green
**Status:** For review and agreement before implementation
**Parent plan:** [[ontara-stage-2-plan-2026-03-19|Stage 2 Plan]]
**Depends on:** Phase 2 complete (commit `f59ed59` — generator produces facets, `@UserFacing`, comprehension tracking)

---

## 1. Objective

Build the `/catalogue` page in the Ontara Console — a browsable, filterable Component Catalogue with multi-axis "group by" as the core interaction pattern. This is the primary Stage 2 console deliverable.

The catalogue presents the 24 BMM `part def`s that have `@CatalogueTag` metadata, grouped dynamically by any available facet dimension, with element detail including friendly names from `@UserFacing` metadata, doc blocks, cross-domain instantiation, and tag data. The design follows the two-panel layout pattern already established in the Package Navigator, adapted for the catalogue's grouping-centric interaction model.

**What it is not (this phase):** The catalogue does not yet present BSMM elements (O2 prerequisite), does not include a standalone glossary view (I15 — Stage 3), and does not support user-defined groupings or assembly workspace interactions (I9 — Stage 3).

---

## 2. Data Available

From the generated `model-introspection.json` (Phase 2 output):

**Top-level structures consumed by the catalogue:**

| JSON key | Content | Used for |
|---|---|---|
| `facets` | Facet dimension index — `bmmConcern` (4 values) and `classification` (1 value) — with per-value element counts | Populating "group by" dropdown dynamically |
| `comprehension` | Coverage stats: 24 tagged, 10 with `@UserFacing`, 41.7% coverage, 14 elements missing `@UserFacing` | Comprehension coverage indicator |
| `coverageMatrix` | Per-`part def` entries with `catalogueTag`, `userFacing`, and `domains` (cross-domain instances) | Main catalogue data source |
| `elements` | Full element list with `parentPackage`, `metaModelLayer`, `kind`, `doc`, `attributes` | Package-based grouping axis; supplementary element metadata |

**Per-element data shape in `coverageMatrix` (example: `CustomerSegment`):**

```json
{
  "name": "CustomerSegment",
  "layer": "bmm",
  "package": "ServiceConcept",
  "doc": "A defined group of customers...",
  "catalogueTag": {
    "bmmConcern": "ServiceConcept",
    "classification": "General"
  },
  "userFacing": {
    "friendlyName": "Customer Segment",
    "shortDescription": "A defined group of customers with shared needs..."
  },
  "domains": {
    "core": [{ "name": "selfReferringIndividuals", "package": "ServiceConcept" }],
    "csw": [{ "name": "walkInCustomers", "package": "CoffeeShopBusinessModel" }],
    "suds": [{ "name": "walkInCustomer", "package": "SudsBusinessModel" }, ...]
  }
}
```

**Current data volumes:** 24 catalogue-tagged elements across 4 BMM concern groups (ServiceConcept: 7, ResourceCapability: 7, ActivityModel: 5, FinancialModel: 5). 10 elements with `@UserFacing` metadata. 3 domains (core, CSW, Suds).

---

## 3. Design Decisions

These decisions are proposed based on the Stage 2 plan and the existing codebase patterns. To be confirmed before implementation.

| # | Decision | Rationale |
|---|---|---|
| D1 | **Two-panel layout** matching Package Navigator: left panel for grouping controls + grouped list, right panel for element detail. | Established console pattern (I12). Consistency. |
| D2 | **Data source: `coverageMatrix`**, filtered to entries that have `catalogueTag`. Not the `elements` array. | `coverageMatrix` has the richest per-element data: tags, user-facing metadata, cross-domain instances. Only catalogue-tagged elements belong in the catalogue. |
| D3 | **"Group by" as a dropdown** (not tabs), dynamically populated from `facets` keys plus "Package" as a synthetic axis. | Dynamic — new facet dimensions added to the model automatically appear. Dropdown scales to more axes than tabs. |
| D4 | **Grouping axes available:** `bmmConcern` (from facets), `classification` (from facets), `package` (from element `package` field), `domainCoverage` (synthetic: group by number of domains instantiating). Future facet dimensions appear automatically. | Covers the meaningful grouping perspectives with current data. `domainCoverage` is a useful cross-domain comparison lens. |
| D5 | **Default grouping: `bmmConcern`**. This is the most natural initial view — groups elements by their business concern (ServiceConcept, ActivityModel, ResourceCapability, FinancialModel). | Aligns with the Five Concerns (C1–C5). Most meaningful for a first encounter with the catalogue. |
| D6 | **Element cards in left panel** show: friendly name (if available) / SysML name, brief tag summary, domain count indicator. | Enough to scan and select; detail is in the right panel. |
| D7 | **Right panel detail** shows: friendly name + SysML identifier, short description, doc block, all tags, cross-domain instances (grouped by domain with instance names), and a link to the coverage matrix filtered to this element. | Comprehensive element view. The coverage matrix link exercises the cross-link requirement from the Stage 2 plan. |
| D8 | **Comprehension indicator**: elements without `@UserFacing` show a subtle "No description available" note, not an error. Global comprehension coverage stat in header. | Inviting, not punitive. Consistent with the Stage 2 plan guidance. |
| D9 | **Text search** across friendly names, SysML names, descriptions, doc blocks, and tag values. Narrows within current grouping. | Standard filtering pattern, consistent with coverage matrix search. |
| D10 | **No sub-grouping in this phase.** With 24 elements and group sizes of 5–7, sub-grouping is not yet essential. Current group sizes sit at or slightly above the 3–5 chunk working memory bound (Cowan 2001, 2010 — superseding Miller's earlier 7±2 estimate). This is acceptable here because items within each group share strong semantic relationships (same BMM concern), reducing cognitive load compared to arbitrary unrelated chunks. Sub-grouping should be added as the catalogue grows beyond this range, particularly when BSMM elements and additional tagged elements enter the catalogue. | Pragmatic — current data volumes are manageable. The 3–5 principle informs design and should be monitored as content grows. |
| D11 | **SvelteKit data loading via `+page.ts`**, same pattern as coverage and packages pages. | Consistency with existing codebase. |

---

## 4. Implementation Chunks

The work is divided into five chunks, each producing a testable increment. Chunks are designed to be reviewable independently.

### Chunk 1: Data Loading and Catalogue Data Extraction

**What:** Create `+page.ts` for the catalogue route that loads the JSON and extracts the catalogue-eligible elements. Create TypeScript types for the catalogue data structures.

**Deliverables:**
- `console/src/routes/catalogue/+page.ts` — loads JSON, extracts catalogue entries from `coverageMatrix` (entries with `catalogueTag`), passes through `facets` and `comprehension` data
- `console/src/lib/types/catalogue.ts` — TypeScript interfaces: `CatalogueElement`, `FacetSummary`, `ComprehensionSummary`, `CatalogueData`

**Approach:**
1. Define TypeScript interfaces matching the JSON shape for catalogue-relevant data
2. In the `load` function, filter `coverageMatrix` entries to those with a `catalogueTag` property
3. Pass the filtered elements, facets, comprehension summary, and domain metadata to the page

**Estimated tool calls:** 3–5

**Best suited to:** Claude Chat — straightforward TypeScript, follows established pattern from coverage `+page.ts`.

---

### Chunk 2: Left Panel — Grouping Controls and Grouped Element List

**What:** Build the left panel with a "group by" dropdown and a grouped, collapsible element list. This is the core catalogue interaction.

**Deliverables:**
- "Group by" dropdown populated dynamically from facet keys + synthetic axes (package, domainCoverage)
- Grouped element list with collapsible group headers showing group name + element count
- Element cards within each group showing friendly name / SysML name, brief tag summary, domain count dot indicator
- Selection state: clicking an element sets it as the active selection for the right panel

**Approach:**
1. Build a reactive `groupBy` state variable (default: `bmmConcern`)
2. Implement `groupElements(elements, axis)` as a `$derived` computation that returns a `Map<string, CatalogueElement[]>`:
   - For facet-based axes (`bmmConcern`, `classification`): group by the corresponding `catalogueTag` value
   - For `package`: group by the element's `package` field
   - For `domainCoverage`: group by domain count bucket ("3 domains", "2 domains", "1 domain", "0 domains")
3. Render groups as collapsible sections (reusing the chevron toggle pattern from coverage matrix)
4. Each element card is a clickable button that sets `selectedElement`

**Axis label mapping:** The dropdown should show human-readable labels, not raw facet keys:
- `bmmConcern` → "BMM Concern"
- `classification` → "Classification"
- `package` → "Package"
- `domainCoverage` → "Domain Coverage"

**Group value labels for `bmmConcern`:** Use the facet values directly (ServiceConcept, ActivityModel, ResourceCapability, FinancialModel) — these are readable enough for Ella as the primary user (I12).

**Estimated tool calls:** 8–12

**Best suited to:** Claude Chat — interactive UI work requiring Svelte 5 reactive patterns, design judgement on element card layout and grouping UX.

---

### Chunk 3: Right Panel — Element Detail View

**What:** Build the right panel that shows full detail for the selected element.

**Deliverables:**
- Friendly name displayed prominently (large, primary text) when `@UserFacing` exists; SysML identifier in secondary text below
- When `@UserFacing` is absent: SysML identifier displayed prominently with a subtle "No description available" note
- Short description (from `@UserFacing`)
- Doc block (from SysML, in a distinct section — technical detail, not user-facing)
- Tags section: all tag dimensions and values shown as badges
- Cross-domain instantiation section: grouped by domain, showing instance names and packages. Each domain is a sub-section with the domain label and instance count.
- Coverage matrix link: a button/link that navigates to `/coverage?search={elementName}` (leveraging the existing text search on the coverage page)
- Empty state when no element is selected: "Select an element from the left to see its detail"

**Approach:**
1. Render conditionally based on `selectedElement` state
2. Comprehension-first layout: friendly name → short description → tags → cross-domain instances → doc block (technical detail last)
3. Cross-domain instance rendering: iterate over `domains` object, use `domains` metadata from the top-level JSON for labels
4. Coverage matrix link: simple `<a href="/coverage?search={name}">View in coverage matrix</a>` — note this requires the coverage page to read URL query params for initial search text (Chunk 5 handles this)

**Estimated tool calls:** 6–10

**Best suited to:** Claude Chat — layout and presentation decisions, comprehension layer rendering logic.

---

### Chunk 4: Filtering and Search

**What:** Add text search and a meta model layer filter to narrow elements within the current grouping.

**Deliverables:**
- Text search input (matching coverage matrix pattern) filtering across: friendly name, SysML name, short description, doc block, tag values
- Layer filter dropdown: "All" / "BMM" — currently only BMM elements are tagged, so this is future-proofing for when BSMM elements enter the catalogue
- Filter results update the grouped list reactively (groups with no matching elements are hidden; group counts reflect filtered totals)
- Header stats: "Showing X of Y catalogue elements" + comprehension coverage indicator ("10 of 24 with descriptions — 41.7%")

**Approach:**
1. Add `searchText` and `layerFilter` state variables
2. Insert a `$derived` filtering step between the raw catalogue elements and the grouping computation: raw elements → filtered elements → grouped elements
3. Search is case-insensitive, matches against concatenated searchable text per element
4. Comprehension stats rendered in the page header, drawn from `comprehension` JSON data

**Estimated tool calls:** 4–6

**Best suited to:** Claude Chat — reactive filtering logic follows the established pattern from the coverage page.

---

### Chunk 5: Cross-Links and Polish

**What:** Wire up the cross-link between catalogue and coverage matrix. Visual polish and consistency pass.

**Deliverables:**
- Coverage matrix page reads `?search=` query parameter to pre-populate search field on load (enables deep-linking from catalogue)
- Catalogue page: verify all Flowbite-svelte components used consistently with coverage and packages pages
- Dark mode verification: all new elements respect the existing dark mode theme
- Responsive behaviour: left panel collapses on mobile (consistent with sidebar pattern)
- Empty state and loading state handling
- Generator footer ("Generated {date} by {generator}")

**Approach:**
1. In coverage `+page.ts` or `+page.svelte`: read `$page.url.searchParams.get('search')` and initialise `searchText` from it
2. In catalogue element detail: link to `/coverage?search={elementName}`
3. Visual review pass: spacing, colour consistency, badge colours match coverage matrix conventions
4. Test dark mode rendering of all new components

**Estimated tool calls:** 4–6

**Best suited to:** Claude Chat for the cross-linking logic and visual review. The coverage page query param change is a small targeted edit.

---

## 5. Implementation Sequence and Dependencies

```
Chunk 1 (data loading + types)
    │
    ├─► Chunk 2 (left panel — grouping)
    │       │
    │       └─► Chunk 4 (filtering — inserts between data and grouping)
    │
    └─► Chunk 3 (right panel — detail view)
            │
            └─► Chunk 5 (cross-links + polish)
```

**Recommended execution order:** 1 → 2 → 3 → 4 → 5

Chunks 2 and 3 could be built in parallel in principle, but since they share state (`selectedElement`), building them sequentially in one file avoids coordination overhead. Chunk 4 retrofits filtering into the data flow established in Chunk 2. Chunk 5 is a polish pass that touches both the catalogue and coverage pages.

---

## 6. Estimated Effort

| Chunk | Tool calls | Notes |
|---|---|---|
| 1. Data loading + types | 3–5 | Straightforward, follows existing pattern |
| 2. Left panel — grouping | 8–12 | Core interaction, most design judgement needed |
| 3. Right panel — detail | 6–10 | Comprehension layer rendering, cross-domain display |
| 4. Filtering + search | 4–6 | Follows established pattern |
| 5. Cross-links + polish | 4–6 | Targeted edits to two pages |
| **Total** | **25–39** | **Target: 1 session** |

This should fit within a single session. If the session runs long, Chunks 1–3 are the priority — they deliver a working catalogue. Chunks 4 and 5 can be deferred to the next session if needed without breaking the deliverable.

---

## 7. Claude Code / Cowork Suitability

| Chunk | Claude Chat | Claude Code | Rationale |
|---|---|---|---|
| 1 | ✓ | Possible | Simple enough for either. Chat preferred for context continuity. |
| 2 | ✓ | ✗ | Interactive UI design requiring judgement, Svelte 5 reactivity. Not batch-suitable. |
| 3 | ✓ | ✗ | Layout and comprehension rendering require design decisions. Not batch-suitable. |
| 4 | ✓ | Possible | Filtering is mechanical but integrates with Chunk 2 reactive flow. Chat preferred. |
| 5 | ✓ | Possible for query param edit | The coverage page edit is a small, well-specified change suitable for Code. Chat handles the polish pass. |

**Recommendation:** All chunks in Claude Chat for this phase. The work is UI-centric, requires design judgement throughout, and benefits from iterative review within one session. Claude Code tasks become more relevant in Phase 3 (Suds expansion — mechanical model file writing) and Phase 6 (governance traceability).

**Claude Code instruction (if Chunk 5 cross-link is delegated):** "In `console/src/routes/coverage/+page.svelte`, read the URL search parameter `search` on page load and use it to initialise the `searchText` state variable. Use `$page.url.searchParams.get('search')` from `$app/stores`. The existing `searchText` variable is declared with `let searchText = $state('')` — change the initial value to read from the URL parameter. Import `page` from `$app/stores` if not already imported."

---

## 8. Files Created or Modified

| File | Action | Chunk |
|---|---|---|
| `console/src/lib/types/catalogue.ts` | **New** | 1 |
| `console/src/routes/catalogue/+page.ts` | **New** (replaces placeholder load) | 1 |
| `console/src/routes/catalogue/+page.svelte` | **Replace** (placeholder → full implementation) | 2, 3, 4 |
| `console/src/routes/coverage/+page.svelte` | **Edit** (add query param reading) | 5 |

---

## 9. Register Concepts Exercised

| Concept | How |
|---|---|
| A3 (model generates everything) | All catalogue content comes from generated JSON |
| D9 (metadata-driven generation) | `@CatalogueTag` and `@UserFacing` metadata drive the UI |
| D11 (catalogue-as-UI-contract) | Generated JSON is the contract between model and catalogue |
| I7 (Component Catalogue) | This is the Component Catalogue implementation |
| I6 (filtered views) | Multi-axis grouping + text search + layer filter |
| I10 (tagging system) | Facet data from `@CatalogueTag` populates grouping controls |
| I12 (architect's tool) | Top-down delimitation via grouping, progressive detail on selection |
| I14 / I14a (comprehension layer) | Friendly names and descriptions rendered; coverage stats shown |
| J2 (co-evolution) | Console view built against existing model content |
| J12 (design decision lifecycle) | Grouping axes system-defined; mechanism remains flexible |

**Monitored (not addressed this phase):**
- I4 Levels 2/3 — pattern and meta model adequacy tracking remain unaddressed
- I15 — glossary not built (Stage 3)
- B12 — horizontal mappings not surfaced
- O2 — BSMM elements not yet in the catalogue

---

## 10. Verification Checklist

At the end of Phase 4 implementation, verify:

- [ ] `/catalogue` page loads and displays all 24 tagged elements
- [ ] "Group by" dropdown shows: BMM Concern, Classification, Package, Domain Coverage
- [ ] Default grouping (BMM Concern) shows 4 groups with correct element counts (7, 5, 7, 5)
- [ ] Switching grouping axis regroups elements reactively
- [ ] Clicking an element shows detail in right panel
- [ ] Elements with `@UserFacing`: friendly name shown prominently, short description visible
- [ ] Elements without `@UserFacing`: SysML name shown, "No description available" note
- [ ] Cross-domain instances show correct domain labels and instance names
- [ ] Text search narrows elements within current grouping
- [ ] Coverage matrix link from element detail navigates to `/coverage?search={name}` and pre-populates search
- [ ] Comprehension coverage indicator shows in header (10/24, 41.7%)
- [ ] Dark mode renders correctly
- [ ] Generator footer shows generation timestamp

---

*Phase 4 implementation plan prepared 19 March 2026 (Session 40). For review and agreement before implementation begins.*
