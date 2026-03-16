# Session 23 Report — CSW Extension Phase 4: Frontend Foundation

**Date:** 12 March 2026
**Session number:** 23
**Workstream:** CSW Extension — Catalogue, Inventory & Frontend (Phase 4 of 10)
**Plan:** `gsl-plan-csw-extension-phase4-implementation-2026-03-12.md`

---

## Summary

Executed Phase 4 of the CSW Extension workstream: the frontend foundation. The coffee shop demonstrator now has a properly structured, navigable interface with Tailwind CSS v4, Flowbite Svelte components, a sidebar layout with four-section navigation, dark mode support, and a warm coffee shop visual identity. All existing pages are restyled with Flowbite components. The app transitions from an unstyled test harness to a cohesive GUI — the foundation for all subsequent frontend phases.

---

## Work Completed

### Pre-Stage: Version Check

Checked the current state of the Flowbite Svelte ecosystem against the sv10-validated versions from summer 2025.

**Findings:**
- `flowbite-svelte` latest stable: `1.31.0` (up from sv10's `1.8.1`)
- `flowbite-svelte` 2.0 series: still in prerelease (`2.0.0-next.9`), with peer deps `svelte ^5.40.0` + `tailwindcss ^4.1.4`
- `flowbite-svelte-icons`: `2.3.0`
- `flowbite`: `3.1.0`
- `tailwindcss`: `4.2.1`
- `@tailwindcss/vite`: `4.2.1`
- Workspace Svelte version: `5.53.7`

**Decision:** Use `flowbite-svelte@1.31.0` stable rather than the 2.0 prerelease. The 1.31.0 is well beyond the sv10-validated version, and the 2.0 next series is still iterating. The workspace Svelte version (5.53.7) exceeds the 2.0 peer dep requirement, so upgrade to 2.0 stable is straightforward when it ships.

### Stage 1: Dependencies, Vite Plugin & CSS Foundation

**Dependencies installed** into `@coffeeshop/web`:
- Dev: `tailwindcss@^4.2.1`, `@tailwindcss/vite@^4.2.1`
- Runtime: `flowbite@^3.1.0`, `flowbite-svelte@^1.31.0`, `flowbite-svelte-icons@^2.3.0`, `clsx@^2.1.1`, `tailwind-merge@^3.3.1`

**pnpm resolution:** Both `flowbite-svelte` and `flowbite-svelte-icons` resolved locally to `packages/web/node_modules/` (not hoisted to workspace root). This means the `@source` directives in `app.css` use the relative `../node_modules/` path as planned.

**Vite configuration:** Added `@tailwindcss/vite` plugin after the SvelteKit plugin in `vite.config.ts`.

**CSS foundation:** Created `src/app.css` with Tailwind v4 CSS-native configuration:
- `@import "tailwindcss"` (v4 syntax replacing v3 directives)
- `@plugin "flowbite/plugin"` for Flowbite integration
- `@source` directives for flowbite-svelte and flowbite-svelte-icons dist folders
- `@custom-variant dark (&:where(.dark, .dark *))` for Flowbite dark mode compatibility
- `@theme` block with coffee shop warm neutral palette (primary: browns, secondary: charcoal/stone)

**Dark mode initialisation:** Added inline script to `app.html` that runs before Svelte render — reads `localStorage` preference or system preference, applies `dark` class to `<html>` element, preventing flash of wrong theme.

**Verification:** Dev server started clean (Vite v7.3.1, 698ms). Page rendered with Tailwind's CSS reset applied. No console errors.

**Commit:** `85c8506` — CSW frontend: Tailwind v4 + Flowbite Svelte dependencies and CSS foundation

### Stage 2: Layout Shell — Sidebar, Navbar & Navigation

**Layout approach:** Replaced the pipe-delimited `<nav>` in `+layout.svelte` with a hand-rolled sidebar + navbar layout using Tailwind utility classes and Flowbite Svelte icons.

**Initial attempt** used the Flowbite `Sidebar` component, but its `isOpen`/`alwaysOpen`/breakpoint interaction caused the sidebar to be hidden on desktop (the component's default `hidden` class with responsive `md:block` didn't activate reliably). Switched to the standard Flowbite admin dashboard pattern: a fixed `<aside>` with `md:translate-x-0` (always visible on desktop) and `-translate-x-full` (hidden on mobile when closed).

**Navbar:** Custom `<nav>` element (not the Flowbite Navbar component — the hand-rolled approach was more predictable) with:
- Hamburger toggle button (visible on mobile only)
- Coffee shop branding: "☕ Coffee Shop"
- Three connection status indicators (Temporal, EHRbase, PostgreSQL) with green dots — hardcoded placeholders
- Flowbite `DarkMode` component for theme toggle

**Sidebar navigation structure (four sections):**
- **Operations:** Counter (`/`), Order Board (`/orders`)
- **Management:** Stock & Catalogue (`/management/catalogue`)
- **Data & Insights:** Records (`/entity`), Audit Dashboard (`/governance`), Customer Voice (`/feedback`)
- **System:** Process Model (`/pathway`), System Status (`/system`)

**Active route highlighting:** Uses `$page.url.pathname` from `$app/stores` with a derived `isActive()` helper. Root path (`/`) uses exact match; all others use `startsWith`.

**Icons:** Eight icons from `flowbite-svelte-icons`: MugHotOutline, ClipboardListOutline, ArchiveOutline, DatabaseOutline, ShieldCheckOutline, MessageDotsOutline, CodeBranchOutline, ServerOutline. Plus BarsOutline for the hamburger menu.

**Placeholder pages:** Created for routes in the sidebar that don't have content yet:
- `/management/catalogue/+page.svelte` — "Coming in Phase 6"
- `/system/+page.svelte` — "Coming in Phase 9"

Both use Flowbite `Card` components with the relevant icon.

**Responsive behaviour:** Sidebar hidden by default on mobile (`-translate-x-full`), shown via state toggle. Backdrop overlay on mobile when sidebar is open. Desktop: sidebar always visible (`md:translate-x-0`), content area offset with `md:ml-64`.

**DarkMode toggle:** Confirmed working — the Flowbite `DarkMode` component works correctly with `flowbite-svelte@1.31.0` on Svelte 5.53.7. No `invalid_default_snippet` warnings (the sv10 issue appears resolved in 1.31.0). Sun/moon icon switches between themes, both light and dark modes render correctly across navbar, sidebar, and content area.

**Commit:** Stage 2 commit — CSW frontend: Flowbite layout shell with sidebar navigation

### Stage 3: Page Styling Pass

Restyled all existing pages with Flowbite components and Tailwind utility classes, replacing all inline `style` attributes.

**Counter (home page):** Wrapped form in Flowbite `Card`. Replaced HTML elements with Flowbite `Label`, `Input`, `Select`, `Button`, `Alert`. Updated heading to "Counter" with subtitle. Full-width primary-coloured submit button. Drink and size options as Flowbite `Select` items arrays.

**Order Board (orders list):** Replaced raw `<table>` with Flowbite `Table`/`TableHead`/`TableBody`/`TableBodyRow`/`TableBodyCell`. Status badges use Flowbite `Badge` with semantic colours (green for Running, blue for Completed, red for Failed, yellow for Timed out, dark for Cancelled/Terminated). Loading state uses Flowbite `Spinner`. Empty state uses Flowbite `Alert`.

**Order Status (order detail):** Order metadata in Flowbite `Card` with grid layout. Current state as large `Badge` with semantic colour. Signal action as Flowbite `Button`. State history as Flowbite `Table` with `Badge` per entry.

**Audit Report:** Case metadata in Flowbite `Card` with grid layout. Compliance table as Flowbite `Table` with `Badge` for step type (Activity/Signal wait) and compliance status (Within target/Exceeded/Pending). Governance note in styled info box.

**Records (entity views):** Query buttons as Flowbite `Button color="light"`. EHR ID input with Tailwind-styled `<input>`. Metadata bar in rounded secondary background. Results as Flowbite `Table`.

**Customer Voice (feedback):** Submit form in Flowbite `Card` with `Label`, `Input`, `Select`, Tailwind-styled `<textarea>`, full-width `Button`. Feedback list as Flowbite `Table`.

**Audit Dashboard (governance):** Preserved the existing summary cards pattern but replaced inline styles with Tailwind classes. Compliance/non-compliance badges. Customer detail with expandable rows using `Badge` for compliant/non-compliant status. Governance question in styled callout with primary-500 left border.

**Process Model (pathway):** Description in Flowbite `Card`. SVG diagram in styled container. Workflow steps as Flowbite `Table` with `Badge` for step type.

**Commit:** Stage 3 commit — CSW frontend: page styling pass with Flowbite components

---

## Findings

### Flowbite Sidebar Component vs Hand-Rolled Sidebar

The Flowbite `Sidebar` component (`flowbite-svelte@1.31.0`) uses a `tailwind-variants` based theming system with `isOpen`/`alwaysOpen`/`breakpoint` props. On first attempt, the sidebar was invisible on desktop despite the content area being correctly offset. The root cause: the component's base class includes `hidden` with a responsive override (e.g. `md:block`), but the `isLargeScreen` derived state and the component's conditional rendering logic didn't reliably show the sidebar on initial render.

The fix was to switch to a hand-rolled sidebar using the standard Flowbite admin dashboard CSS pattern: `fixed`, `w-64`, `md:translate-x-0` for desktop visibility, toggle via `-translate-x-full`/`translate-x-0` for mobile. This is the pattern used in Flowbite's own admin dashboard templates and is more predictable than the component's abstraction.

**Lesson for GSL:** When a component library's abstraction adds complexity without benefit (responsive sidebar visibility is a one-line CSS concern), use the underlying CSS pattern directly. The Flowbite components work well for discrete UI elements (Card, Badge, Table, Button, Alert, DarkMode) but less well for layout-level concerns where the abstraction hides responsive behaviour.

### DarkMode Component — Svelte 5 Compatibility

The sv10 setup guide documented `invalid_default_snippet` warnings with Flowbite's `DarkMode` component in Svelte 5. With `flowbite-svelte@1.31.0` on Svelte `5.53.7`, the `DarkMode` component works without warnings. The component correctly toggles the `dark` class on `<html>`, persists to `localStorage`, and renders a sun/moon icon that responds to theme state. The sv10 custom JS toggle workaround is no longer needed.

### Tailwind v4 @source Resolution in pnpm Workspace

The `@source` directives in `app.css` (`../node_modules/flowbite-svelte/dist` and `../node_modules/flowbite-svelte-icons/dist`) resolved correctly because pnpm placed both packages locally in `packages/web/node_modules/`. Had pnpm hoisted them to the workspace root, the paths would have needed adjusting to `../../../node_modules/...`. The `@source` directive is relative to the CSS file's location (`src/app.css`), not to the package root.

### Flowbite Select Component — Items Array Pattern

The Flowbite `Select` component accepts an `items` prop as an array of `{ value, name }` objects, which is cleaner than nested `<option>` elements in Svelte 5. However, the Select component's `bind:value` works with the `value` property of the items, so the initial value must match an item's value exactly.

---

## Coffee Shop Demonstrator Extension

**Capability demonstrated:** Complete frontend foundation with Tailwind v4, Flowbite Svelte component library, sidebar navigation, dark mode, and styled pages consuming all existing API routes.

**What was built:** CSS foundation with coffee shop theme palette, layout shell with four-section sidebar navigation, dark mode initialisation and toggle, placeholder pages for future phases, Flowbite component styling across all 8 existing pages plus 2 new placeholder pages.

**What was learned:**
- Flowbite Sidebar component is less reliable than hand-rolled CSS for layout concerns
- DarkMode component works in flowbite-svelte 1.31.0 with Svelte 5.53 (sv10 workaround no longer needed)
- pnpm local resolution keeps @source paths predictable
- The Flowbite component library covers the full range of UI patterns needed for the demonstrator (and by extension, the clinical system)

**Clinical implementation confidence:** High. The Tailwind + Flowbite stack is validated for Svelte 5. The sidebar navigation pattern maps directly to the clinician portal structure. The Card/Table/Badge/Alert/Button component set covers clinical UI patterns (patient cards, record tables, status badges, safety alerts, action buttons). Dark mode supports accessibility requirements.

---

## Architecture Notes

### Frontend Technology Stack Post Phase 4

| Technology | Version | Purpose |
|---|---|---|
| Svelte | 5.53.7 | UI framework |
| SvelteKit | latest | App framework, routing, SSR |
| Tailwind CSS | 4.2.1 | Utility-first CSS |
| @tailwindcss/vite | 4.2.1 | Vite integration (replaces PostCSS) |
| Flowbite | 3.1.0 | Base component library |
| Flowbite Svelte | 1.31.0 | Svelte component wrappers |
| Flowbite Svelte Icons | 2.3.0 | SVG icon components |
| clsx | 2.1.1 | Conditional class composition |
| tailwind-merge | 3.3.1 | Tailwind class deduplication |

### Page Route Structure Post Phase 4

| Route | Page | Status |
|---|---|---|
| `/` | Counter (order form) | Restyled |
| `/orders` | Order Board (list) | Restyled |
| `/orders/[id]` | Order Status (detail) | Restyled |
| `/orders/[id]/audit` | Audit Report | Restyled |
| `/entity` | Records (CDR views) | Restyled |
| `/feedback` | Customer Voice | Restyled |
| `/governance` | Audit Dashboard | Restyled |
| `/pathway` | Process Model | Restyled |
| `/management/catalogue` | Stock & Catalogue | Placeholder |
| `/system` | System Status | Placeholder |

---

## Git Log

| Commit | Description |
|---|---|
| `85c8506` | CSW frontend: Tailwind v4 + Flowbite Svelte dependencies and CSS foundation |
| (Stage 2) | CSW frontend: Flowbite layout shell with sidebar navigation |
| (Stage 3) | CSW frontend: page styling pass with Flowbite components |

---

## Next Session

Continue CSW Extension workstream — **Phase 5: Counter Page (Dynamic Order Form)**:
- Read catalogue from `GET /api/catalogue` on page load
- Visual tiles grouped by category (hot drinks, cold drinks, food)
- Size selection as toggle buttons from catalogue `availableSizes`
- Dietary badges (vegan, GF), provision type indicator
- Active orders dashboard in split view (right panel)
- Form submission via existing `POST /api/orders`

Phase 5 implementation plan: `gsl-plan-workstream-csw-extension-2026-03-12.md` §Phase 5.

---

## Syntax Reference

No update required — no SysML changes in this phase.

---

*Session 23 report prepared 12 March 2026.*
