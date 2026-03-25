# Ontara — Stage 4 Phase 1: Detailed Implementation Plan

**Date:** 25 March 2026 (Session 72)
**Prepared by:** Claude, in discussion with Ella Green
**Builds on:** [[ontara-stage-4-high-level-plan-2026-03-21|Stage 4 high-level plan]] (Session 57), [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]] E001 and E008, Session 72 exploratory discussion
**Session type:** Planning → Implementation
**Status:** For review and agreement

---

## 1. Objective

Build a new console view — **Relationships** — with two tabs implemented as separate routes:

- **`/relationships/graph`** — Interactive D3.js force-directed graph displaying BMM elements as nodes and weighted relationships as directed edges. The visual face of the relationship structure currently encoded in `@WeightedRelationship` annotations.
- **`/relationships/table`** — Tabular view of all relationships, filterable and sortable. Designed from the outset as the beginning of an editable surface.

The view must be **fully data-driven**: it renders whatever `model-introspection.json` contains. Adding, removing, or modifying BMM elements and their weighted relationships requires only regenerating the JSON — no console code changes.

---

## 2. Scope

### In scope

- New console route group `/relationships` with shared layout and two child routes (`/graph`, `/table`)
- D3.js force-directed graph with:
  - Nodes coloured by BMM concern, sized by connectivity (total incoming + outgoing edges)
  - Directed edges styled by strength (strong/moderate/weak), rendered as curved parallel arcs for bidirectional pairs (Option D from Session 72 discussion) with visual grouping
  - Force simulation runs to equilibrium on load (optimal starting layout)
  - Pan, zoom, drag-to-rearrange interaction
  - Click-to-focus: selecting a node highlights its direct connections, dims everything else, opens a side panel with glossary entry content, panel includes a link to the full glossary page
- Configuration table with:
  - Columns: source element (friendly name), target element (friendly name), strength, rationale, BMM concern of source
  - Sortable by any column
  - Filterable by concern, strength, source/target element
  - Visual affordances that anticipate editability (interactive cell hover states, edit icon or mode toggle — disabled but present)
- Sidebar navigation entry under "Model Explorer"
- Generator extension to produce a dedicated `weightedRelationshipGraph` section in the JSON
- D3.js added as a project dependency

### Out of scope

- Editing weights through the console (future iteration)
- Cross-package navigation / deep linking from other views to this view (future)
- BMM concern group descriptions (E003 — separate future phase)
- Assembly workspace / construction capabilities
- Changes to the SysML model itself

### Design constraint: data-driven rendering

The view must handle any number of nodes and edges as determined by the generated JSON. The current data (28 nodes, 79 edges) is the starting point, not a fixed ceiling. Node positions, edge routing, colour assignments, and table rows are all computed from data, not hardcoded.

---

## 3. Pre-requisite Reading for Code

Before implementation, Code should read:

- This plan (the primary instruction document)
- `console/package.json` — current dependencies
- `console/src/routes/+layout.svelte` — sidebar navigation structure
- `console/src/routes/glossary/+page.ts` — data loading pattern (fetch from `/data/model-introspection.json`)
- `console/src/routes/glossary/+page.svelte` — component patterns, Svelte 5 runes, Flowbite Svelte usage
- `console/src/lib/types/catalogue.ts` — existing type definitions (especially `RelatedConceptSurface`, `ComprehensionContent`)
- `scripts/gen_model_introspection.py` — generator structure, specifically `build_comprehension_content()` and how `weighted_relationships` are already extracted per element
- `generated/ontara/model-introspection.json` — current JSON structure (head 100 lines for structure, then search for `weightedRelationships` in the elements array)

---

## 4. Implementation Steps

### Step 1 — Generator extension [Code]

**What:** Add a new function `build_weighted_relationship_graph()` to `gen_model_introspection.py` that assembles a dedicated graph data structure from all `@WeightedRelationship` annotations.

**Why the current data isn't sufficient:** The `comprehensionContent` section only surfaces related concepts that are siblings in the same SysML package. Weighted relationships cross package boundaries — the graph needs the complete edge set.

**Output structure (new top-level key in the JSON):**

```json
"weightedRelationshipGraph": {
  "nodes": [
    {
      "id": "ServiceOffering",
      "friendlyName": "Service Offering",
      "bmmConcern": "ServiceConcept",
      "classification": "General",
      "package": "ServiceConcept",
      "shortDescription": "A defined service that the business offers..."
    }
  ],
  "edges": [
    {
      "source": "ServiceOffering",
      "target": "PricingModel",
      "strength": "strong",
      "rationale": "A change to the service offering almost certainly requires..."
    }
  ],
  "stats": {
    "nodeCount": 28,
    "edgeCount": 79,
    "strongCount": 27,
    "moderateCount": 50,
    "weakCount": 2,
    "bidirectionalPairCount": 35
  }
}
```

**Implementation notes:**
- Iterate all elements in `all_elements` that have `weighted_relationships` and `catalogue_tag` (i.e. are BMM elements)
- Build the node list from elements that have `catalogue_tag` AND (`weighted_relationships` OR are targets of another element's weighted relationships)
- Build the edge list from all `weighted_relationships` entries across all elements
- Compute `bidirectionalPairCount` by counting source-target pairs where both directions exist
- Include in the `output` dict under `"weightedRelationshipGraph"` key
- The stats are convenience data for the console — avoids client-side recomputation

**Acceptance criteria:**
- Running `python scripts/gen_model_introspection.py --save --pretty` produces a JSON with a `weightedRelationshipGraph` key
- All 79 relationships appear as edges
- All 28 BMM elements with `@CatalogueTag` appear as nodes (27 elements have outgoing weights; 1 element — `AuditEvidenceRecord` — has zero outgoing but is the target of incoming weights)
- Stats are accurate
- Existing JSON structure is unchanged — this is purely additive

**After generation:** Copy the refreshed JSON to the console:
```bash
cp generated/ontara/model-introspection.json console/static/data/model-introspection.json
```

---

### Step 2 — Add D3.js dependency [Code]

```bash
cd console
npm install d3 @types/d3
```

Verify the installation succeeds and the console still builds (`npm run build`).

---

### Step 3 — TypeScript types for the graph data [Code]

**What:** Create `console/src/lib/types/relationships.ts` with types for the graph data.

```typescript
export interface GraphNode {
  id: string;
  friendlyName: string;
  bmmConcern: string;
  classification: string;
  package: string;
  shortDescription: string;
}

export interface GraphEdge {
  source: string;
  target: string;
  strength: 'strong' | 'moderate' | 'weak' | 'contextual';
  rationale: string;
}

export interface GraphStats {
  nodeCount: number;
  edgeCount: number;
  strongCount: number;
  moderateCount: number;
  weakCount: number;
  bidirectionalPairCount: number;
}

export interface WeightedRelationshipGraph {
  nodes: GraphNode[];
  edges: GraphEdge[];
  stats: GraphStats;
}

// D3 simulation types (extended from GraphNode for force layout)
export interface SimNode extends GraphNode, d3.SimulationNodeDatum {
  degree: number;  // total edges (in + out) for sizing
}

export interface SimEdge extends d3.SimulationLinkDatum<SimNode> {
  strength: GraphEdge['strength'];
  rationale: string;
  // Computed by layout logic:
  isBidirectional?: boolean;  // true if a reverse edge exists
  curveDirection?: 1 | -1;   // which side to curve toward
}
```

Note: the `d3.SimulationNodeDatum` and `d3.SimulationLinkDatum` types come from `@types/d3`. Code should check the exact import path.

---

### Step 4 — Console routes and shared layout [Code]

**What:** Create a SvelteKit route group with shared layout:

```
console/src/routes/relationships/
  +layout.ts          ← shared data loader (fetches once for both tabs)
  +layout.svelte      ← shared layout: tab navigation + filter controls
  +page.ts            ← redirect to /relationships/graph (default tab)
  +page.svelte        ← minimal (redirect handled in +page.ts)
  graph/
    +page.svelte      ← graph view
  table/
    +page.svelte      ← configuration table view
```

This gives two linkable URLs — `/relationships/graph` and `/relationships/table` — while the shared layout renders a single tabbed interface. The data loads once at the layout level and is available to both child routes.

**Shared data loader (`+layout.ts`):**

```typescript
import type { LayoutLoad } from './$types';
import type { WeightedRelationshipGraph } from '$lib/types/relationships';
import type { ComprehensionContent, CatalogueElement } from '$lib/types/catalogue';

export interface RelationshipsLayoutData {
  graph: WeightedRelationshipGraph;
  comprehensionContent: Record<string, ComprehensionContent>;
  glossaryEntries: CatalogueElement[];
  generatedAt: string;
}

export const load: LayoutLoad = async ({ fetch }) => {
  const response = await fetch('/data/model-introspection.json');
  const data = await response.json();

  // Extract glossary entries for the side panel
  const glossaryEntries: CatalogueElement[] = Object.values(data.coverageMatrix)
    .filter((entry: any) => entry.catalogueTag && entry.userFacing?.friendlyName)
    .map((entry: any) => ({
      name: entry.name,
      layer: entry.layer,
      package: entry.package,
      doc: entry.doc || '',
      catalogueTag: entry.catalogueTag,
      userFacing: entry.userFacing,
      purposiveDescription: entry.purposiveDescription || undefined,
      domains: entry.domains || {},
    }));

  return {
    graph: data.weightedRelationshipGraph,
    comprehensionContent: data.comprehensionContent || {},
    glossaryEntries,
    generatedAt: data.generatedAt,
  };
};
```

**Shared layout (`+layout.svelte`):**

Renders tab navigation (Graph / Table) as links to the child routes — the "active" tab is determined by the current URL path, not component state. Also renders the shared filter controls.

Tab navigation should use `<a>` elements styled to match Flowbite's tab visual language using Tailwind classes, with active state derived from `$page.url.pathname`. Not Flowbite Svelte's Tabs component (which manages its own state and would conflict with URL-driven routing).

Filter controls (shared between both tabs, state managed in the layout):
- BMM Concern dropdown (values from the node data, plus "All")
- Strength dropdown (Strong / Moderate / Weak / All)
- Text search (filters nodes by name/friendlyName, filters table rows by any column)
- Filter state is passed to child routes via Svelte context or layout data.

**Root page redirect (`+page.ts`):**

```typescript
import { redirect } from '@sveltejs/kit';
import type { PageLoad } from './$types';

export const load: PageLoad = async () => {
  throw redirect(307, '/relationships/graph');
};
```

**Graph page (`graph/+page.svelte`):**

Renders the `RelationshipGraph` component and the side panel.

Side panel (graph tab only):
- Slides in from the right when a node is clicked
- Shows: friendly name, short description, purposive description, related concepts (from comprehensionContent), link to glossary page (`/glossary` — the glossary currently doesn't support anchor links per element, so link to the page)
- Close button to dismiss

**Table page (`table/+page.svelte`):**

Renders the `RelationshipTable` component.

---

### Step 5 — Force-directed graph component [Code]

**What:** Create `console/src/lib/components/RelationshipGraph.svelte`.

This is the largest piece of work. Key design decisions:

**Layout:**
- Use `d3-force` simulation with `forceLink`, `forceCharge`, `forceCenter`, `forceCollide`
- On mount: run simulation to equilibrium (use `simulation.tick(300)` or similar to pre-compute positions, then render — avoid the "spaghetti settling" animation on load)
- After initial layout, the simulation remains active for drag interaction but in a low-energy "cooling" state
- SVG rendered via Svelte (not D3 DOM manipulation) — D3 handles the physics, Svelte handles the rendering. This is the idiomatic Svelte+D3 pattern.

**Node rendering:**
- Circles sized by degree (total edges in + out). Use `d3.scaleSqrt` mapping degree to radius, with a minimum and maximum radius to prevent extremes.
- Coloured by BMM concern. Use a fixed colour palette mapped to concern names. Suggested palette (Tailwind-adjacent, dark-mode-friendly):
  - ServiceConcept: blue-500
  - ActivityModel: emerald-500
  - ResourceCapability: amber-500
  - FinancialModel: purple-500
  - Governance: rose-500
  - (Any new concern: assign from a reserve palette)
- **The colour palette must be derived from the data, not hardcoded to five values.** Map concern names to colours dynamically using `d3.scaleOrdinal` with a chosen colour range.
- Label: friendly name, positioned below the node. Font size scaled with node size but with a floor for readability.

**Edge rendering (Option D — curved parallel edges with visual grouping):**
- For each edge, determine if a reverse edge exists (same source-target pair, opposite direction)
- **Unidirectional edges:** Straight line with arrowhead at the target end
- **Bidirectional pairs:** Two curved arcs — one curving clockwise, one counter-clockwise — between the same node pair. Each arc has its own arrowhead and its own strength-based styling. The pair is visually grouped by a subtle shared offset (small gap between the two arcs rather than them overlapping)
- **Strength styling:**
  - Strong: thick line (stroke-width ~3), high opacity
  - Moderate: medium line (stroke-width ~2), medium opacity
  - Weak: thin line (stroke-width ~1), lower opacity
  - Use the source node's concern colour for the edge, at the appropriate opacity
- **Arrowheads:** SVG `<marker>` elements, sized proportionally to the edge thickness. Coloured to match the edge.

**Interaction:**
- **Click node:** Set node as "focused". Highlight the node and all directly connected nodes + edges. Dim everything else (reduce opacity). Open the side panel with the clicked node's glossary content. Clicking the same node again or clicking empty space deselects.
- **Hover node:** Light highlight effect (subtle border/glow). Tooltip with friendly name and degree count.
- **Hover edge:** Tooltip with "Source → Target: strength" and rationale text.
- **Drag node:** D3 drag behaviour — node follows cursor, simulation reheats locally to settle neighbours.
- **Pan:** SVG `<g>` transform via D3 zoom behaviour.
- **Zoom:** D3 zoom behaviour with scroll wheel. Set reasonable min/max zoom bounds.

**Filtering:**
- When concern or strength filters are applied, non-matching nodes and edges fade (low opacity) rather than disappearing entirely — this preserves spatial context.
- Text search highlights matching nodes.

**Responsiveness:**
- SVG viewBox should be computed from the node positions after initial layout
- The SVG container should fill the available space (flex-grow within the main content area)

---

### Step 6 — Configuration table component [Code]

**What:** Create `console/src/lib/components/RelationshipTable.svelte`.

**Columns:**
| Column | Content | Sortable | Notes |
|---|---|---|---|
| Source | Friendly name of source element | Yes | Clicking could highlight the element in the graph tab (future) |
| Target | Friendly name of target element | Yes | Same |
| Strength | strong / moderate / weak | Yes | Rendered as a badge (colour-coded to match graph edge colours) |
| BMM Concern | Concern of the source element | Yes | Rendered as a badge (colour-coded to match graph node colours) |
| Rationale | The rationale text from the annotation | No | May be long — truncate with expand-on-click or tooltip |

**Interaction:**
- Column header click toggles sort (ascending → descending → none)
- Filters (shared with graph tab via layout) apply to the table: concern filter restricts to rows where source concern matches; strength filter restricts to matching strengths; text search filters across source name, target name, and rationale
- Row hover highlights the row

**Editable surface affordances (visual only — not wired up):**
- Strength cells have a subtle interactive appearance (cursor: pointer, hover border)
- A small edit icon appears on hover next to the strength value
- A "Configuration Mode" toggle in the view header (disabled, with a "Coming soon" tooltip)
- These affordances signal the direction of travel without creating broken expectations

**Styling:** Use Tailwind classes consistent with the rest of the console. No Flowbite Svelte Table component unless it fits cleanly — a custom table may be simpler given the sorting and filtering requirements.

---

### Step 7 — Sidebar navigation entry [Code]

**What:** Add the Relationships view to the sidebar in `console/src/routes/+layout.svelte`.

- Position: under "Model Explorer", after "Glossary"
- Icon: Use a suitable Flowbite Svelte icon — `ShareNodesOutline` or `ChartOutline` would be appropriate. Code should check what's available in `flowbite-svelte-icons` and choose the best fit.
- Label: "Relationships"
- `href`: `/relationships` (which redirects to `/relationships/graph`)
- `isActive` check: `currentPath.startsWith('/relationships')`

---

### Step 8 — Colour palette consistency [Code]

**What:** Extract the BMM concern colour mapping into a shared utility (`console/src/lib/utils/colours.ts`) so that the graph, table, and any future views use consistent colours for concern groups.

```typescript
export function getConcernColour(concern: string): string {
  // Returns a hex colour for the given concern name.
  // Uses a deterministic mapping — same concern always gets same colour.
  // Falls back to a neutral grey for unknown concerns.
}
```

This utility should be used by both the graph component (node fill colours, edge colours) and the table component (concern and strength badges).

---

### Step 9 — Build and visual verification [Code]

- Run `npm run build` in the console directory to verify the build succeeds
- Run `npm run dev` and verify:
  - The Relationships view appears in the sidebar
  - Navigating to `/relationships` redirects to `/relationships/graph`
  - The graph renders with all 28 nodes and 79 edges
  - The tab navigation shows "Graph" and "Table" tabs, with the active tab highlighted based on the current URL
  - Bidirectional pairs show as curved parallel arcs
  - Click-to-focus works (node highlights, side panel opens)
  - Filters work on both tabs (shared state from layout)
  - Switching tabs preserves filter state
  - The table shows all 79 rows with correct data
  - `/relationships/graph` and `/relationships/table` are independently linkable
  - Dark mode works (colours adapt appropriately)

---

## 5. File Inventory

### New files

| File | Purpose |
|---|---|
| `console/src/routes/relationships/+layout.ts` | Shared data loader |
| `console/src/routes/relationships/+layout.svelte` | Shared layout with tab navigation and filters |
| `console/src/routes/relationships/+page.ts` | Redirect to /relationships/graph |
| `console/src/routes/relationships/graph/+page.svelte` | Graph view with side panel |
| `console/src/routes/relationships/table/+page.svelte` | Configuration table view |
| `console/src/lib/components/RelationshipGraph.svelte` | D3 force-directed graph component |
| `console/src/lib/components/RelationshipTable.svelte` | Configuration table component |
| `console/src/lib/types/relationships.ts` | TypeScript types |
| `console/src/lib/utils/colours.ts` | Shared concern colour mapping |

### Modified files

| File | Change |
|---|---|
| `scripts/gen_model_introspection.py` | Add `build_weighted_relationship_graph()` function; add to output dict |
| `console/src/routes/+layout.svelte` | Add sidebar nav entry for Relationships |
| `console/package.json` | Add `d3` and `@types/d3` dependencies |
| `generated/ontara/model-introspection.json` | Regenerated with new `weightedRelationshipGraph` key |
| `console/static/data/model-introspection.json` | Copy of regenerated JSON |

---

## 6. Acceptance Criteria

1. **Generator produces graph data.** `weightedRelationshipGraph` key present in JSON with correct node count (28), edge count (79), and stats.
2. **Graph renders all nodes and edges.** Visual inspection: 28 labelled nodes, 79 directed edges, correct concern colouring, strength-based edge styling.
3. **Bidirectional pairs are visually distinct.** Curved parallel arcs clearly show both directions independently. A bidirectional pair is immediately distinguishable from a unidirectional edge.
4. **Click-to-focus works.** Clicking a node highlights connections, dims the rest, opens the side panel with glossary content, and provides a link to the glossary page.
5. **Filters work on both tabs.** Concern filter, strength filter, and text search all function correctly on both the graph and the table. Filter state is preserved when switching between tabs.
6. **Table shows all relationships.** 79 rows with correct source, target, strength, rationale, and concern data. Sorting works on all sortable columns.
7. **Editable surface affordances are present.** Strength cells appear interactive, edit icon visible on hover, Configuration Mode toggle present (disabled).
8. **Separate routes are linkable.** `/relationships/graph` and `/relationships/table` each load their respective tab directly. `/relationships` redirects to `/relationships/graph`.
9. **Data-driven.** No hardcoded element names, concern names, or edge data in the console code. Everything derives from the JSON. Test: if we hypothetically removed a BMM element and its weights from the model, regenerated, and refreshed — the view would render correctly with fewer nodes/edges.
10. **Dark mode.** The view works correctly in both light and dark modes.
11. **Console builds cleanly.** `npm run build` succeeds without errors or warnings.

---

## 7. Register Concepts Exercised

| Concept | How |
|---|---|
| [[principle-model-generates-everything|A3]] (model generates everything) | Graph data generated from SysML annotations via the introspection generator |
| [[principle-intrinsic-self-knowledge|A10]] (intrinsic self-knowledge) | The view displays what the model knows about its own relationship structure |
| [[principle-unity-principle|A11]] (unity principle) | The same weight data that informs comprehension (glossary) now informs spatial navigation (graph) and systematic review (table) |
| [[concept-weighted-relationships|B14]] (weighted relationships) | The primary data source — 79 relationships rendered visually |
| [[pattern-metadata-driven-generation|D9]] (metadata-driven generation) | `@WeightedRelationship` → generator → JSON → console view |
| [[concept-co-evolution|J2]] (co-evolution) | Generator and console extended together |
| I12 (console as architect's own tool) | A new view giving Ella a fresh angle on the [[ontara-service-business-meta-modelling-v2|meta model]] |
| [[ontara-workflow-emergent-ideas-log|E001]] (graph visualisation) | Directly addressed |
| [[ontara-workflow-emergent-ideas-log|E008]] (configuration table) | Directly addressed |

---

## 8. Chat / Code / Cowork Allocation

| Step | Tool | Rationale |
|---|---|---|
| 1. Generator extension | **Code** | Python code change + run + verify output |
| 2. Add D3 dependency | **Code** | npm install + build verification |
| 3. TypeScript types | **Code** | New file creation |
| 4. Console routes + shared layout | **Code** | Multi-file SvelteKit route group implementation |
| 5. Graph component | **Code** | Largest piece — D3 + Svelte integration, iterative development |
| 6. Table component | **Code** | Svelte component with sorting/filtering logic |
| 7. Sidebar nav entry | **Code** | Small edit to layout.svelte |
| 8. Colour utility | **Code** | Small shared utility |
| 9. Build + verify | **Code** | Build, run dev, visual check |

This is entirely a **Code session**. Chat (this session) produces the plan; Code executes it. Chat is available for mid-implementation questions if Code encounters design decisions not covered by this plan.

---

## 9. Dependencies and Open Questions

### Dependencies

- D3.js must be available as an npm package compatible with the SvelteKit/Vite build (it is — `d3` is standard ESM)
- The generator must be runnable from the repo root (`python scripts/gen_model_introspection.py --save --pretty`)

### Open questions resolved during Session 72 discussion

| Question | Resolution |
|---|---|
| Bidirectionality rendering | Option D — curved parallel edges with visual grouping |
| Graph interaction model | Pan, zoom, drag. Click → highlight + side panel + glossary link |
| Table as read-only or editable? | Heading toward editable — include visual affordances now |
| Configuration table placement | Second tab within the same view, implemented as a separate route |
| Route structure | Separate routes (`/relationships/graph`, `/relationships/table`) with shared layout — gives linkable URLs while maintaining a single tabbed interface |
| Sidebar label | "Relationships" |
| Scope of Stage 4 | Relationship-first only — graph + table. No cross-package navigation, completeness visualisation, or assembly workspace in this stage. |

### No open questions remaining

If Code encounters an ambiguous design decision during implementation, it should make the simplest reasonable choice and document it in the session notes. Ella can refine on review.

---

## 10. Estimated Effort

- Generator extension: ~30 minutes
- D3 dependency + types: ~15 minutes
- Route group + shared layout: ~45 minutes
- Graph component: 2–3 hours (largest piece — D3 force layout, bidirectional edge rendering, click-to-focus, side panel)
- Table component: ~1 hour
- Sidebar nav, colours: ~30 minutes
- Build verification and polish: ~30 minutes

Total: approximately 1 Code session (5–6 hours), possibly extending into a second session for visual polish and edge cases.

---

*Implementation plan prepared 25 March 2026, Session 72. For review and agreement by Ella Green.*
