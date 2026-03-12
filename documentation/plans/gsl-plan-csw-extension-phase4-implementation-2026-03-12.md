# CSW Extension Phase 4: Frontend Foundation — Detailed Implementation Plan

**Workstream:** Coffee Shop Extension — Catalogue, Inventory & Frontend
**Phase:** 4 of 10
**Date:** 12 March 2026
**Prerequisites:** Phase 3 complete (Catalogue & Inventory API routes, Session 22)
**Source plan:** `gsl-plan-workstream-csw-extension-2026-03-12.md` §Phase 4
**Design reference:** `gsl-plan-coffeeshop-frontend-reboot-2026-03-12.md` §4 (technology), §4.5 (theme), §5.1 (global shell), §9 (reference material)
**Estimated effort:** 3 stages

---

## Goal

Tailwind CSS v4 + Flowbite Svelte installed and working in `@coffeeshop/web`. Layout shell with sidebar navigation replacing the pipe-delimited nav. Coffee shop visual identity via a warm neutral `@theme` palette. Dark mode toggle. All existing API routes unaffected. The app transitions from an unstyled test harness to a properly structured, navigable interface — the foundation for all subsequent frontend phases.

---

## Pre-Stage: Version Check (done interactively before Stage 1)

Before committing to dependency versions, check the current state of the Flowbite Svelte ecosystem. The frontend reboot plan documents known-good versions from sv10 (summer 2025), but nine months have passed.

**Checks to perform (Ella runs; Claude reviews output):**

1. `npm view flowbite-svelte versions --json | tail -5` — current latest version
2. `npm view flowbite-svelte-icons versions --json | tail -5` — current latest version
3. `npm view flowbite versions --json | tail -5` — current latest version
4. `npm view tailwindcss versions --json | tail -5` — current latest Tailwind v4 version
5. `npm view @tailwindcss/vite versions --json | tail -5` — current latest vite plugin version
6. Check Flowbite Svelte changelog/release notes for Svelte 5 native support status — specifically whether `flowbite-svelte-next` has merged to main, and whether `$app/state` is supported
7. `pnpm --filter @coffeeshop/web exec svelte -v` or check `node_modules/svelte/package.json` — current Svelte version in the workspace

**Decision point:** If Flowbite Svelte has released a Svelte 5 native version (likely 1.x or 2.x), prefer it. If still on the Svelte 4 compatibility layer, use the sv10-validated versions (flowbite-svelte@^1.8.1) with documented workarounds. The implementation plan below handles both scenarios — the Flowbite component API is stable across versions; only import paths and dark mode mechanics may differ.

---

## Stage 1: Dependencies, Vite Plugin & CSS Foundation

### 1.1 Install dependencies

Run from the `packages/web/` directory:

```bash
pnpm add -D tailwindcss @tailwindcss/vite
pnpm add flowbite flowbite-svelte flowbite-svelte-icons clsx tailwind-merge
```

Note: `tailwindcss` and `@tailwindcss/vite` are dev dependencies (build tooling). `flowbite`, `flowbite-svelte`, and `flowbite-svelte-icons` are runtime dependencies (component library). `clsx` and `tailwind-merge` are utility dependencies for conditional class composition.

### 1.2 Update vite.config.ts

Add the `@tailwindcss/vite` plugin **after** the SvelteKit plugin:

```typescript
import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  plugins: [sveltekit(), tailwindcss()]
});
```

This is the validated pattern from sv10. The Tailwind v4 Vite plugin replaces the PostCSS-based approach from Tailwind v3.

### 1.3 Create src/app.css

This is the critical integration point. Tailwind v4 uses CSS-native configuration rather than `tailwind.config.js`.

```css
@import "tailwindcss";

/* Flowbite plugin and component scanning */
@plugin "flowbite/plugin";
@source "../node_modules/flowbite-svelte/dist";
@source "../node_modules/flowbite-svelte-icons/dist";

/* Dark mode variant for Flowbite compatibility */
@custom-variant dark (&:where(.dark, .dark *));

/* Coffee shop theme palette */
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

**Key notes:**
- `@import "tailwindcss"` replaces the Tailwind v3 `@tailwind base/components/utilities` directives. Using v3 syntax with v4 causes silent failures.
- `@custom-variant dark` with the exact `(&:where(.dark, .dark *))` syntax is required for Flowbite's class-based dark mode to work with Tailwind v4.
- The `@source` directives tell Tailwind v4 to scan Flowbite's dist folders for utility classes used by the component library. In a pnpm workspace, these resolve relative to `packages/web/`. If pnpm has hoisted the packages to the workspace root, the paths may need adjusting — see verification step below.
- The `@theme` palette values are from the frontend reboot plan §4.5. They can be refined later; the point is to establish the coffee shop's visual identity from the outset.

### 1.4 Update src/app.html

Add the dark mode initialisation script (runs before Svelte renders, preventing flash of wrong theme) and the `dark` class infrastructure:

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
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
    %sveltekit.head%
  </head>
  <body data-sveltekit-preload-data="hover">
    <div style="display: contents">%sveltekit.body%</div>
  </body>
</html>
```

### 1.5 Import app.css in +layout.svelte

The root layout must import `app.css` for Tailwind to take effect. This is a minimal change at this stage — the layout shell is built in Stage 2.

Add to the top of `src/routes/+layout.svelte`:

```svelte
<script lang="ts">
  import '../app.css';
  // ... existing imports
</script>
```

### 1.6 Verification

1. `pnpm --filter @coffeeshop/web dev` — dev server starts without errors
2. Open `localhost:5173` — page renders (styling will be different due to Tailwind's reset, but content should appear)
3. Check browser console for warnings about missing `@source` paths or unresolved Flowbite classes
4. If `@source` paths don't resolve (Flowbite classes not applied): check whether pnpm has hoisted to workspace root and adjust paths, e.g. `@source "../../../node_modules/flowbite-svelte/dist"`
5. Confirm existing API routes still respond (curl `GET /api/catalogue`, `GET /api/orders/list`)

### 1.7 Commit point

```bash
git add -A && git commit -m "CSW frontend: Tailwind v4 + Flowbite Svelte dependencies and CSS foundation"
```

---

## Stage 2: Layout Shell — Sidebar, Navbar & Navigation

### 2.1 Create the layout component

Replace the existing pipe-delimited nav in `+layout.svelte` with a Flowbite Sidebar + Navbar layout. The navigation structure groups pages into four sections matching the workstream plan:

**Operations:**
- Counter (home) — `/` — the barista's landing page
- Order Board — `/orders` — all orders by lifecycle state
- Order History — `/orders/history` — historical/completed orders (future: Phase 7)

**Management:**
- Stock & Catalogue — `/management/catalogue` — NEW (Phase 6 landing zone)

**Data & Insights:**
- Records — `/entity` — CDR entity views
- Audit Dashboard — `/governance` — governance audit
- Customer Voice — `/feedback` — feedback records

**System:**
- Process Model — `/pathway` — pathway diagram
- System Status — `/system` — NEW (Phase 9 landing zone)

### 2.2 Layout structure

The layout uses a two-column pattern: fixed sidebar on the left, scrollable content area on the right, with a top navbar spanning the full width.

```
┌─────────────────────────────────────────────────┐
│  Navbar: brand / title / connection status / DM  │
├──────────┬──────────────────────────────────────┤
│          │                                      │
│ Sidebar  │  Main content area                   │
│          │  (routed pages)                      │
│ Ops      │                                      │
│ Mgmt     │                                      │
│ Data     │                                      │
│ System   │                                      │
│          │                                      │
└──────────┴──────────────────────────────────────┘
```

**Flowbite components used:**
- `Sidebar`, `SidebarWrapper`, `SidebarGroup`, `SidebarItem` — left navigation
- `Navbar`, `NavBrand` — top bar
- `DarkMode` — theme toggle (if working in current Flowbite version; custom toggle fallback otherwise)

**Flowbite Svelte Icons used (from `flowbite-svelte-icons`):**
- `CoffeeOutline` or `HomeSolid` — Counter
- `ClipboardListOutline` — Order Board
- `ArchiveOutline` — Stock & Catalogue
- `DatabaseOutline` — Records
- `ShieldCheckOutline` — Audit Dashboard
- `ChatBubbleLeftEllipsisOutline` — Customer Voice
- `MapOutline` or `GitBranchOutline` — Process Model
- `ServerOutline` — System Status

Exact icon names will be confirmed against the installed version of `flowbite-svelte-icons`. Use `import { IconName } from 'flowbite-svelte-icons'` pattern.

### 2.3 Active route highlighting

Use SvelteKit's `$page.url.pathname` (from `$app/state` if supported, otherwise `$app/stores`) to highlight the active sidebar item. Each `SidebarItem` gets an `active` prop or a conditional class based on the current route.

### 2.4 Sidebar section labels

Each group gets a label (Operations, Management, Data & Insights, System) using either `SidebarGroup` label props or a styled `<span>` above the group. These labels orient the user within the system's capability domains.

### 2.5 Placeholder pages for new routes

Create minimal placeholder pages for routes that don't exist yet but are in the sidebar:

- `src/routes/management/catalogue/+page.svelte` — "Stock & Catalogue — Coming in Phase 6"
- `src/routes/system/+page.svelte` — "System Status — Coming in Phase 9"
- `src/routes/orders/history/+page.svelte` — "Order History — Coming in Phase 7"

These prevent 404s from sidebar navigation and signal what's coming.

### 2.6 Responsive behaviour

The sidebar should be collapsible on smaller screens. Flowbite's `Sidebar` component supports a `hidden` state toggled by a hamburger button in the Navbar. The implementation should handle:
- Desktop: sidebar always visible
- Tablet/mobile: sidebar hidden by default, toggled by Navbar button

### 2.7 Remove old styling

Delete all inline `style` attributes from the existing `+layout.svelte`. The `<nav>` element, its pipe delimiters, and the `<main style="...">` wrapper are all replaced by the Flowbite layout.

### 2.8 Verification

1. Dev server starts clean — no console errors
2. Sidebar renders with all four sections and correct icons
3. Clicking each sidebar item navigates to the correct route
4. Active route is visually highlighted in the sidebar
5. Dark mode toggle switches theme (Navbar and Sidebar both respond)
6. Placeholder pages render for `/management/catalogue`, `/system`, `/orders/history`
7. Existing pages (`/`, `/orders`, `/entity`, `/feedback`, `/governance`, `/pathway`) still render their content (unstyled but functional)
8. API routes still work (`GET /api/catalogue` returns 200)

### 2.9 Commit point

```bash
git add -A && git commit -m "CSW frontend: Flowbite layout shell with sidebar navigation"
```

---

## Stage 3: Page Styling Pass & Visual Polish

### 3.1 Restyle the home page (+page.svelte)

The current home page is an unstyled HTML form with hardcoded drink options. In this stage we restyle it with Flowbite components while keeping the same form logic — the dynamic catalogue-driven counter is Phase 5. The goal is to make the existing page look coherent within the new layout.

**Changes:**
- Wrap the form in a Flowbite `Card` component
- Replace `<input>` with Flowbite `Input` (or Tailwind-styled `<input>`)
- Replace `<select>` elements with Flowbite `Select` (or Tailwind-styled `<select>`)
- Replace `<button>` with Flowbite `Button` (primary colour from the theme palette)
- Error message uses Flowbite `Alert` with `color="red"`
- Page heading and subtitle use Tailwind typography classes
- Add a brief introductory text explaining the demonstrator context

### 3.2 Restyle the orders list page

- Replace raw table with Flowbite `Table`, `TableHead`, `TableBody`, `TableBodyRow`, `TableBodyCell`
- Status badges use Flowbite `Badge` with semantic colours (blue for placed, yellow for in preparation, green for ready, gray for collected, red for cancelled)
- Row click navigates to order detail (preserving existing behaviour)

### 3.3 Restyle the order detail page

- Order metadata in a Flowbite `Card` header
- State label as a `Badge`
- Signal button as a Flowbite `Button`
- Event history as a styled timeline or `Table`

### 3.4 Light touch on remaining pages

The entity, feedback, governance, and pathway pages get minimal restyling — enough to look coherent in the layout but not full redesigns (those are Phases 7–9):

- Headings use Tailwind typography
- Buttons use Flowbite `Button`
- Tables use Flowbite `Table` components
- Raw `<p>` text gets Tailwind prose spacing

### 3.5 Navbar connection status indicators

Add lightweight connection status to the Navbar — visual indicators (coloured dots or Flowbite `Badge` elements) for:
- Temporal (hardcoded to "connected" for now — actual health check is Phase 9)
- EHRbase (hardcoded to "connected")
- PostgreSQL (hardcoded to "connected")

These are placeholders that signal the three-layer persistence architecture. Wiring to actual health checks is Phase 9.

### 3.6 Verification

1. All pages render with coherent styling in both light and dark modes
2. Form submission on the home page still works (places order, navigates to order detail)
3. Orders list loads and displays with styled table
4. Order detail shows state and allows signal sending
5. Sidebar active states work across all navigated pages
6. No regressions in API behaviour

### 3.7 Commit point

```bash
git add -A && git commit -m "CSW frontend: page styling pass with Flowbite components"
```

---

## Files Created / Modified

### New files
| File | Purpose |
|---|---|
| `src/app.css` | Tailwind v4 + Flowbite integration + coffee shop theme |
| `src/routes/management/catalogue/+page.svelte` | Placeholder for Phase 6 |
| `src/routes/system/+page.svelte` | Placeholder for Phase 9 |
| `src/routes/orders/history/+page.svelte` | Placeholder for Phase 7 |

### Modified files
| File | Change |
|---|---|
| `package.json` | New dependencies (tailwindcss, @tailwindcss/vite, flowbite, flowbite-svelte, flowbite-svelte-icons, clsx, tailwind-merge) |
| `vite.config.ts` | Add `@tailwindcss/vite` plugin |
| `src/app.html` | Add dark mode init script |
| `src/routes/+layout.svelte` | Replace pipe-nav with Flowbite Sidebar + Navbar layout, import app.css |
| `src/routes/+page.svelte` | Restyle with Flowbite Card, Input, Select, Button, Alert |
| `src/routes/orders/+page.svelte` | Restyle with Flowbite Table, Badge |
| `src/routes/orders/[id]/+page.svelte` | Restyle with Flowbite Card, Badge, Button |
| `src/routes/orders/[id]/audit/+page.svelte` | Light restyle |
| `src/routes/entity/+page.svelte` | Light restyle |
| `src/routes/feedback/+page.svelte` | Light restyle |
| `src/routes/governance/+page.svelte` | Light restyle |
| `src/routes/pathway/+page.svelte` | Light restyle |

### Unchanged
All files under `src/routes/api/` — API routes are untouched.
All files under `src/lib/server/` — server-side clients are untouched.
All files under `packages/shared/` and `packages/temporal/` — no changes.

---

## Risks and Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| **pnpm hoisting breaks `@source` paths** | Medium | Check `node_modules` resolution first. Adjust `@source` paths if hoisted to workspace root. Can verify with `ls packages/web/node_modules/flowbite-svelte/dist` vs `ls node_modules/flowbite-svelte/dist`. |
| **Flowbite Svelte version incompatibility with current Svelte** | Low–Medium | Pre-stage version check. If latest Flowbite requires Svelte 5.x features not in current workspace Svelte, pin to sv10-validated versions. |
| **DarkMode component broken in Svelte 5** | Medium | sv10 documented `invalid_default_snippet` warnings. If current version still has issues, use a custom JS toggle (3-line function: toggle `dark` class on `<html>`, persist to localStorage). Flowbite's DarkMode is a convenience, not a necessity. |
| **Tailwind reset breaks existing page rendering** | Expected | This is expected and handled in Stage 3 — the styling pass applies Tailwind/Flowbite classes to restore and improve rendering. Content is preserved; only presentation changes. |
| **`$app/stores` deprecation** | Low | Check whether current SvelteKit version emits deprecation warnings for `$app/stores`. If `$app/state` is available and Flowbite supports it, prefer it. If not, `$app/stores` still works. |

---

## What This Phase Does Not Do

- Does not change any API routes or backend logic
- Does not make the order form dynamic (catalogue-driven tiles are Phase 5)
- Does not build the manager GUI (Phase 6)
- Does not build new pages (Order Board, Order Timeline, Records redesign, etc. — Phases 7–9)
- Does not add runtime infrastructure health checks (Phase 9)
- Does not modify Temporal workflows, EHRbase integration, or generated code
- Does not touch `packages/shared/` or `packages/temporal/`

---

## Clinical Implementation Confidence

The Tailwind v4 + Flowbite Svelte stack is validated from the newsletter control panel project (sv01–sv10). The sidebar navigation pattern maps directly to clinical system dashboards — the four-section grouping (Operations, Management, Data & Insights, System) prefigures the clinician portal structure. The dark mode infrastructure supports accessibility requirements. The component library (Card, Table, Badge, Alert, Modal) covers the full range of clinical UI patterns needed for the GenderSense patient portal and clinician dashboard.

---

*Plan prepared 12 March 2026. Phase 4 of the CSW Extension workstream.*
