---
tags:
  - discussion-paper
  - console
  - architecture
date: 2026-04-04
status: current
session: 132
---
# Global Console Navigation Context — Design Discussion

**Session:** 132
**Date:** 4 April 2026
**Status:** Discussion paper (initial design)
**Addresses:** W-010 / [[ontara-workflow-emergent-ideas-log|E021]]
**Depends on:** [[ontara-discussion-comprehension-architecture-2026-03-19|Comprehension Architecture]] (Session 56), [[ontara-ref-vision-architecture|Vision and Architecture Reference v7]] (Session 127)

---

## Contents

- [[#1. Purpose|§1. Purpose]]
- [[#2. The Problem|§2. The Problem]]
- [[#3. Design Principles|§3. Design Principles]]
- [[#4. Architecture|§4. Architecture]]
- [[#5. The Navigation Store|§5. The Navigation Store]]
- [[#6. State Serialisation Contract|§6. State Serialisation Contract]]
- [[#7. What Constitutes a Navigation Event|§7. What Constitutes a Navigation Event]]
- [[#8. Breadcrumb Trail UI|§8. Breadcrumb Trail UI]]
- [[#9. Journey Capture and Export|§9. Journey Capture and Export]]
- [[#10. Migration Path for Existing Routes|§10. Migration Path]]
- [[#11. Live Journey Graph|§11. Live Journey Graph]]
- [[#12. Phased Implementation|§12. Phased Implementation]]
- [[#13. Design Decisions|§13. Design Decisions]]
- [[#14. Open Questions|§14. Open Questions]]
- [[#15. Register Connections|§15. Register Connections]]

---

## 1. Purpose

The Ontara Console currently has 12 views across three sidebar groups (Model Explorer, Domains, Architecture). As cross-linking between views has grown — glossary entries linking to ontology, catalogue elements linking to coverage, governance linking to glossary — each route has independently implemented navigation state management using URL parameters (`from`, `entry`). This per-page approach does not scale.

[[ontara-workflow-emergent-ideas-log|E021]] proposed a global console navigation context. This paper provides the design.

---

## 2. The Problem

### 2.1 Current state

The console's navigation is currently stateless between routes:

- **Cross-route links** use `?from=ontology` or `?entry=ServiceOffering` URL parameters. Each route implements its own parsing.
- **Page state** (expand/collapse sets, filter selections, search text, active tabs) is held in Svelte `$state()` variables that are destroyed on route change.
- **Back navigation** uses the `from` parameter to render a "← Back to X" link, but this loses the originating page's visual state (which nodes were expanded, what filters were set).
- **No shared infrastructure** exists in `$lib/` — there is no `stores/` directory, no context providers, no state persistence.

### 2.2 What breaks as the console grows

Each new cross-link between views would need to independently implement: state capture before navigation, URL parameter encoding, state restoration on arrival, and back-link rendering. With 12 views and growing, this is O(n²) per-pair work.

Worse, some state is complex. The ontology hierarchy view's expand/collapse state is a `Set<string>` of open node IRIs. The glossary has filters, search text, and per-entry expand states. Encoding these independently into URL parameters per route is fragile and verbose.

### 2.3 What we want instead

A single navigational infrastructure that any route can opt into, providing: semantic back/forward navigation with full state restoration, a persistent breadcrumb trail, and — as a longer-term capability — journey capture for knowledge exploration.

---

## 3. Design Principles

### 3.1 Opt-in, not mandatory

Not every route needs full navigation context. A route can participate by registering with the navigation store, or it can remain a simple page. The infrastructure imposes no overhead on non-participating routes.

### 3.2 State stays in the store, not in URLs

URL parameters are the wrong place for complex page state. The navigation store holds state in memory (backed by `sessionStorage` for tab persistence). URLs remain clean — the store knows what state was active when the user left a page and restores it when they return.

The URL continues to carry lightweight parameters for deep-linking (`?entry=ServiceOffering`) and external sharing. But the full page state (expand sets, filters, scroll position) lives in the store.

### 3.3 Semantic, not mechanical

The navigation stack records *meaningful* navigation events with semantic labels and relationship descriptions ("followed `hasTargetSegment` from ServiceOffering to CustomerSegment"), not raw URL changes. This is what makes the stack useful for journey capture and comprehension, not just back/forward navigation.

### 3.4 Page state is opaque to the store

Each route defines its own state shape. The store does not understand the contents of page state — it stores and restores it as a serialisable object. This means the store API is stable even as individual routes evolve their state shapes.

---

## 4. Architecture

### 4.1 Component overview

```
+layout.svelte
├── NavigationProvider (context)        ← Initialises store, provides to tree
│   ├── Breadcrumb (UI component)       ← Renders trail from store
│   └── [route content]
│       └── useNavigation() hook        ← Route registers + captures state
```

### 4.2 Data flow

```
User clicks cross-link on Page A
  → Page A calls navStore.navigateTo({ target, label, relationship })
  → Store captures Page A's current state (via registered captureState callback)
  → Store pushes new entry onto navigation stack
  → SvelteKit navigation proceeds
  → Page B mounts, calls navStore.register({ captureState, restoreState })
  → If Page B has a stored state snapshot, store calls restoreState(snapshot)
  → Breadcrumb component re-renders with updated stack
```

### 4.3 File structure

```
console/src/lib/
├── stores/
│   └── navigation.svelte.ts          ← Svelte 5 reactive store
├── components/
│   ├── Breadcrumb.svelte              ← Breadcrumb trail UI
│   ├── NavigationProvider.svelte      ← Context wrapper
│   └── NavLink.svelte                 ← Drop-in replacement for <a> cross-links
│   └── ... (existing components)
└── types/
    └── navigation.ts                  ← Type definitions
```

---

## 5. The Navigation Store

### 5.1 Core types

```typescript
// types/navigation.ts

/** A single entry in the navigation stack */
interface NavigationEntry {
  /** Unique ID for this entry */
  id: string;

  /** SvelteKit route path, e.g. '/glossary' */
  route: string;

  /** Human-readable label for breadcrumb, e.g. 'Glossary: ServiceOffering' */
  label: string;

  /** Optional: the semantic relationship traversed to reach this entry */
  relationship?: string;

  /** ISO timestamp */
  timestamp: string;

  /** Route-specific state snapshot, opaque to the store */
  pageState?: Record<string, unknown>;
}

/** Callback contract between a route and the store */
interface PageStateContract {
  /** Called by the store to capture current page state before navigating away */
  captureState: () => Record<string, unknown>;

  /** Called by the store to restore state when navigating back to this page */
  restoreState: (state: Record<string, unknown>) => void;
}
```

### 5.2 Store API

```typescript
// stores/navigation.svelte.ts

class NavigationStore {
  /** The navigation stack — reactive */
  stack: NavigationEntry[];

  /** Index of current position in the stack */
  currentIndex: number;

  /** Whether back navigation is available */
  get canGoBack(): boolean;

  /** Whether forward navigation is available */
  get canGoForward(): boolean;

  /**
   * Register the current route's state contract.
   * Called by each participating route on mount.
   */
  register(contract: PageStateContract): void;

  /**
   * Navigate to a new route, pushing onto the stack.
   * Captures current page state before navigation.
   */
  navigateTo(params: {
    route: string;
    label: string;
    relationship?: string;
    /** URL query parameters for deep-linking */
    query?: Record<string, string>;
  }): void;

  /**
   * Go back one step, restoring previous page state.
   */
  goBack(): void;

  /**
   * Go forward one step (after going back).
   */
  goForward(): void;

  /**
   * Reset the stack and clear all captured state.
   */
  reset(): void;

  /**
   * Export the current journey as structured data.
   */
  exportJourney(): JourneyExport;
}
```

### 5.3 Svelte 5 implementation approach

The store uses Svelte 5's `$state` runes for reactivity. It is instantiated once in `NavigationProvider.svelte` and distributed via `setContext()`. Routes access it via `getContext()` or a convenience `useNavigation()` function.

Session storage backup: on every stack mutation, the store serialises to `sessionStorage` under a namespaced key. On provider mount, it attempts to rehydrate from session storage. This provides tab-level persistence without polluting `localStorage` across tabs.

---

## 6. State Serialisation Contract

### 6.1 What must be serialisable

Page state snapshots must survive `JSON.stringify()` → `JSON.parse()` round-tripping (for session storage). This means:

- **Allowed:** primitives, plain objects, arrays, strings, numbers, booleans, null.
- **Not allowed:** `Set`, `Map`, functions, class instances, DOM references.

Routes using `Set<string>` for expand states (e.g., the ontology hierarchy) must convert to `Array<string>` in their `captureState` callback and reconstruct the `Set` in `restoreState`. This is a one-line conversion in each direction.

### 6.2 State shape examples

**Glossary:**
```typescript
{
  searchText: string;
  concernFilter: string;
  layerFilter: string;
  expandedEntries: string[];  // Array, not Set
  scrollY: number;
}
```

**Ontology hierarchy:**
```typescript
{
  expandedNodes: string[];    // Array of IRIs
  searchText: string;
  selectedClass: string | null;
  scrollY: number;
}
```

**Governance:**
```typescript
{
  activeTab: string;
  expandedFrameworks: string[];
  expandedObligations: string[];
  searchText: string;
}
```

### 6.3 Scroll position

Scroll position is captured as `window.scrollY` (or the scroll container's `scrollTop` if routes use custom scroll containers). Restoration uses `requestAnimationFrame` to ensure the DOM has rendered before scrolling.

---

## 7. What Constitutes a Navigation Event

Not every interaction should be pushed onto the navigation stack. The distinction between **stack-worthy events** and **in-page state changes** is critical for keeping the stack meaningful.

### 7.1 Stack-worthy events (pushed to the navigation stack)

- **Cross-route navigation.** Any click that changes the SvelteKit route path. This is the primary trigger.
- **Semantic element navigation within a route** — e.g., clicking a glossary entry that opens a detail view with its own identity. This is stack-worthy because the user has moved to a semantically distinct location.

### 7.2 In-page state changes (captured but not pushed)

- Expanding/collapsing tree nodes
- Changing filter selections
- Typing in search fields
- Switching tabs within a view
- Scrolling

These are captured in the page state snapshot when the user navigates *away*, but they do not create new stack entries. The distinction: a stack entry represents "I am looking at X"; in-page state is "how I am looking at X."

### 7.3 The heuristic

**Push if the user would describe it as "I went to..."** ("I went to the glossary", "I went to ServiceOffering", "I went to the ontology view"). **Don't push if the user would describe it as "I adjusted..."** ("I filtered by concern", "I expanded the ResourcePlanning node", "I searched for 'cost'").

---

## 8. Breadcrumb Trail UI

### 8.1 Placement

The breadcrumb renders in a horizontal bar between the top navbar and the main content area, within the `md:ml-64` content region (respecting the sidebar offset). It is always visible when the navigation stack has more than one entry.

### 8.2 Rendering

```
Home  ›  Coverage Matrix  ›  Glossary: ServiceOffering  ›  Ontology: BFO Hierarchy
                                                                      ↑ current
```

Each breadcrumb segment is clickable. Clicking navigates to that stack position and restores the page state from when the user was there. Segments beyond the current position (if the user has gone back) are shown muted — clicking them is a forward navigation.

### 8.3 Overflow

If the breadcrumb trail exceeds the available width, it collapses the middle segments into a `...` dropdown, always showing the first and last 2 entries. This keeps the breadcrumb useful at any depth.

### 8.4 Styling

Consistent with the existing Flowbite/Tailwind design language. Uses `text-secondary-500` for visited segments, `text-primary-700` for the current segment, and `text-secondary-300` for future segments (after going back). The `›` separator uses `text-secondary-300`.

---

## 9. Journey Capture and Export

### 9.1 What the journey captures

The navigation stack is already a journey record. Each entry carries: route, label, relationship traversed, timestamp, and (optionally) the page state snapshot. The export function strips page state (which is implementation detail) and returns the semantic journey.

### 9.2 Export format

```typescript
interface JourneyExport {
  /** When the journey started */
  startTime: string;
  /** When the export was created */
  exportTime: string;
  /** Ordered list of steps */
  steps: {
    label: string;
    route: string;
    relationship?: string;
    timestamp: string;
  }[];
}
```

This can be rendered as JSON (for programmatic use) or as a Markdown narrative:

```markdown
## Exploration Journey — 4 April 2026, 10:32

1. **Coverage Matrix** — started here
2. **Glossary: ServiceOffering** — navigated from Coverage Matrix
3. **Ontology: BFO Hierarchy** — followed `hasBfoType` from ServiceOffering
4. **Glossary: CustomerSegment** — followed `hasTargetSegment` from ServiceOffering
```

### 9.3 When this becomes valuable

Journey export is not essential for Phase 1 (§12). It becomes valuable when:

- **Onboarding new users:** "Follow this journey to understand the BMM" — a curated path through the console.
- **Design rationale capture:** "I followed this chain of reasoning to verify the governance model."
- **Comprehension research:** Understanding how users explore a model helps improve the console's information architecture.

---

## 10. Migration Path for Existing Routes

### 10.1 Non-breaking adoption

The navigation system is additive. Existing routes continue to work exactly as they do now without any changes. Adoption is per-route and incremental:

1. **Phase 0 (no change):** Route uses `<a href="/glossary?entry=X">` as today. No store interaction. Back navigation uses browser history. Page state is lost.

2. **Phase 1 (basic participation):** Route imports `useNavigation()` and calls `register()` on mount with a `captureState`/`restoreState` pair. Cross-links switch from `<a>` to `<NavLink>`. The route now participates in the breadcrumb trail and gets state restoration on back-navigation.

3. **Phase 2 (semantic navigation):** Cross-links include a `relationship` label describing the semantic connection traversed. The journey trace becomes meaningful.

### 10.2 Route migration priority

Routes should be migrated in order of cross-linking density:

| Priority | Route | Cross-links to/from | Notes |
|---|---|---|---|
| 1 | `/glossary` | Most other views | Central hub — most cross-linked route |
| 2 | `/ontology` | Glossary, catalogue | The `from=ontology` parameter is the existing workaround |
| 3 | `/catalogue` | Glossary, coverage | |
| 4 | `/governance` | Glossary | New view, can be built with navigation from the start |
| 5 | `/coverage` | Glossary, catalogue | |
| 6 | `/relationships` | Glossary | Graph and table views |
| 7–12 | Remaining views | Various | Lower cross-linking density |

### 10.3 Removing the `from` parameter

Once a route participates in the navigation store, its `from` parameter handling and "← Back to X" link can be removed. The breadcrumb trail and `goBack()` replace them. This is a cleanup task, not a migration prerequisite — both mechanisms can coexist during the transition.

---

## 11. Live Journey Graph

E021's seventh item proposed a live journey graph — a visual rendering of the user's navigation path as a directed graph. This is architecturally straightforward given the existing D3 force-directed graph infrastructure in `RelationshipGraph.svelte`, but it is a significant UX design task.

### 11.1 Data source

The navigation store's stack provides the nodes (visited elements) and edges (navigation steps with relationship labels). This is a direct mapping to the D3 graph's data model.

### 11.2 Integration with the full relationship graph

The most compelling version: overlay the user's journey path onto the full BMM relationship graph at `/relationships/graph`. Visited nodes are highlighted; traversed edges are emphasised; unvisited nodes remain visible but muted. This gives "where I've been" within "what exists" in a single view.

### 11.3 Phasing

This is a Phase 3 feature (§12). The store and breadcrumb trail must be established first — the journey graph consumes the same data.

---

## 12. Phased Implementation

### Phase 1 — Foundation (one session)

**Deliverables:**
- `NavigationStore` class in `$lib/stores/navigation.svelte.ts`
- Type definitions in `$lib/types/navigation.ts`
- `NavigationProvider.svelte` context wrapper in root layout
- `Breadcrumb.svelte` component
- `NavLink.svelte` convenience component
- `sessionStorage` backup/rehydration
- Two routes migrated: `/glossary` and `/ontology` (the pair with the existing `from` parameter workaround)

**Validation:** Navigate from ontology → glossary → ontology. Breadcrumb trail appears. Back navigation restores expand/collapse state on both routes.

### Phase 2 — Full console adoption (one session)

**Deliverables:**
- Remaining routes migrated (starting with the Priority 2–6 routes from §10.2)
- `from` parameter handling removed from migrated routes
- Semantic relationship labels added to cross-links (`NavLink relationship="hasBfoType"`)
- Journey export function implemented
- Reset button in breadcrumb UI

### Phase 3 — Journey graph (one session, dependent on Phase 2)

**Deliverables:**
- Journey graph component (reusing D3 infrastructure from `RelationshipGraph.svelte`)
- Integration with the full relationship graph (overlay mode)
- Journey export to Markdown narrative
- Accessibility: keyboard navigation of breadcrumb trail

---

## 13. Design Decisions

| ID | Decision | Rationale |
|---|---|---|
| S132-D7 | Navigation state in a Svelte 5 reactive store with `sessionStorage` backup, not in URL parameters | Complex page state (expand sets, filters, scroll position) does not belong in URLs. `sessionStorage` provides tab-level persistence without cross-tab pollution. |
| S132-D8 | Page state is opaque to the store — routes define their own state shapes via a `captureState`/`restoreState` contract | Decouples the navigation infrastructure from individual route implementations. The store is stable even as routes evolve. |
| S132-D9 | Stack-worthy events are cross-route navigations and semantic element navigations; in-page state changes are captured but not pushed | Keeps the stack meaningful. The heuristic: "push if the user would say 'I went to...'". |
| S132-D10 | Opt-in adoption — existing routes work unchanged until migrated | Non-breaking. Enables incremental migration starting with the highest-value cross-linking pairs. |
| S132-D11 | Breadcrumb trail in a persistent bar between navbar and content, within the sidebar-offset region | Consistent with the existing layout structure. Always visible when the stack has depth, without consuming space when it doesn't. |

---

## 14. Open Questions

| ID | Question | Implications |
|---|---|---|
| S132-Q4 | Should the navigation store persist across full page reloads (via `sessionStorage`) or only within SvelteKit's client-side navigation? | `sessionStorage` survives reloads within a tab but not across tabs. This is probably the right granularity — a new tab starts a new exploration. But if the user refreshes mid-journey, do they expect the breadcrumb trail to survive? |
| S132-Q5 | How should the breadcrumb trail interact with the browser's native back/forward buttons? | Option A: the store intercepts `popstate` events and keeps the breadcrumb in sync with browser history. Option B: the breadcrumb trail is independent — browser back/forward works as normal (with state loss), and the breadcrumb provides the state-preserving alternative. Option B is simpler and less likely to confuse users. |
| S132-Q6 | Should `NavLink` replace standard `<a>` tags throughout, or should it only be used for cross-route links? | Intra-page anchors and external links should remain as `<a>`. `NavLink` is specifically for console-internal cross-route navigation. This distinction should be clear in the component's API and documentation. |
| S132-Q7 | What is the maximum useful stack depth before the journey becomes noise? | A very long exploration session might push 50+ entries. The breadcrumb overflow (§8.3) handles display, but should the store also trim old entries? Probably not — the full stack is valuable for journey export. But the breadcrumb should make deep stacks navigable. |

---

## 15. Register Connections

### 15.1 Existing concepts exercised

| Concept | How exercised |
|---|---|
| [[principle-intrinsic-self-knowledge\|A10]] (intrinsic self-knowledge) | The console knows the user's exploration context — not just the current page but the path that led there |
| [[principle-unity-principle\|A11]] (unity principle) | The same navigation infrastructure serves comprehension, governance auditing, onboarding, and design rationale capture |
| [[concept-comprehension-layer\|I14]] (comprehension layer) | Navigation context is part of how the console helps the user comprehend the model — context of arrival shapes interpretation |
| [[principle-discipline-as-load-bearing-structure\|A9]] (discipline) | A single well-designed navigation system prevents the proliferation of inconsistent per-page workarounds |
| [[concept-co-evolution\|J2]] (co-evolution) | The navigation infrastructure is built as the console's cross-linking density demands it — not before, not after |
| [[concept-weighted-relationships\|B14]] (weighted relationships) | Journey traces capture which relationships the user followed, making the weight model's navigational value explicit |

### 15.2 New concepts for registration

| Proposed code | Concept | Tier | Description |
|---|---|---|---|
| I18 | Global console navigation context | T3 | Shared reactive store providing semantic navigation history, page state preservation, breadcrumb trail, and journey capture across all console views |

---

*Discussion paper produced 4 April 2026 (Session 132). Initial design for W-010 / E021 (global console navigation context). Implementation planned in three phases.*
