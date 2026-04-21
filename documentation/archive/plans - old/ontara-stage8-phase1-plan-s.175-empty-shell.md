---
tags:
  - plan
  - portal
  - implementation
date: 2026-04-08
status: complete
session: 175
---
# Stage 8 Phase 1 — The Empty Shell: Detailed Implementation Plan
> `= this.file.path`

**Session:** 175
**Date:** 8 April 2026
**Purpose:** Detailed implementation plan for Phase 1 of the Ontara Portal — the empty shell with user accounts, domain creation, and structured dashboard. This plan specifies every step with tool allocation and acceptance criteria, suitable for handing off to Claude Code.
**Status:** Complete. Implemented Session 175.
**Depends on:** [[ontara-stage8-plan-high-level-s.174-portal|Stage 8 High-Level Plan]], [[ontara-discussion-portal-state-driven-operator-experience-2026-04-08|Portal Discussion Paper]]
**Work item:** [[ontara-ref-work-items|W-037]]

---

## Contents

- [[#1. Objective and Scope|§1. Objective and Scope]]
- [[#2. Prerequisite Reading|§2. Prerequisite Reading]]
- [[#3. Technology Decisions|§3. Technology Decisions]]
- [[#4. Database Schema Design|§4. Database Schema Design]]
- [[#5. Implementation Steps|§5. Implementation Steps]]
- [[#6. Portal Information Architecture|§6. Portal Information Architecture]]
- [[#7. Design Direction|§7. Design Direction]]
- [[#8. Acceptance Criteria|§8. Acceptance Criteria]]
- [[#9. Register Connections|§9. Register Connections]]
- [[#10. Open Questions Resolved for Phase 1|§10. Open Questions Resolved for Phase 1]]

---

## 1. Objective and Scope

Build a working Ontara Portal application with:

1. **User registration and authentication** — register, log in, log out, session management
2. **Domain creation and management** — create a domain, view domains, switch between domains
3. **Empty but structured dashboard** — a domain dashboard that conveys "ready to receive modules" without presupposing content
4. **Multi-domain, multi-user foundation** — a user can have multiple domains; a domain can have multiple users with roles

**Out of scope for Phase 1:** Module catalogue, module lifecycle, module composition, simulation, governance, SSO/OAuth, payment processing, deployment infrastructure.

---

## 2. Prerequisite Reading

For Claude Code:

- `CLAUDE.md` at repo root — project context, conventions, commit rules
- This plan (the authoritative specification for Phase 1)
- Console `package.json`, `svelte.config.js`, `vite.config.ts`, `app.css` — reference for stack setup patterns

---

## 3. Technology Decisions

All decisions confirmed from the [[ontara-stage8-plan-high-level-s.174-portal|Stage 8 plan]] §4:

| Component | Decision | Notes |
|---|---|---|
| Framework | SvelteKit + Svelte 5 (runes) | Same as console |
| CSS | Tailwind v4 via `@tailwindcss/vite` plugin | Same as console |
| Components | Flowbite Svelte + Flowbite Svelte Icons | Same as console |
| Language | TypeScript | Strict mode |
| Package manager | pnpm | Same as console |
| Database | SQLite via `better-sqlite3` | Synchronous API, no ORM — direct SQL. Migration-ready schema targeting PostgreSQL compatibility |
| Auth | Local accounts with bcrypt + HTTP-only session cookies | `bcrypt` (via `bcryptjs` for pure JS) for password hashing. Session tokens in SQLite |
| Location | `portal/` at repo root | Separate SvelteKit app alongside `console/` |
| Dev port | 5174 | Avoids conflict with console on 5173 |

---

## 4. Database Schema Design

SQLite database file: `portal/data/portal.db` (gitignored). Schema defined in `portal/src/lib/server/db/schema.sql` and applied via a migration script.

### 4.1 Tables

```sql
-- Users
CREATE TABLE users (
    id TEXT PRIMARY KEY,           -- UUID
    email TEXT UNIQUE NOT NULL,
    display_name TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Sessions (auth)
CREATE TABLE sessions (
    id TEXT PRIMARY KEY,           -- UUID token
    user_id TEXT NOT NULL REFERENCES users(id),
    expires_at TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Domains
CREATE TABLE domains (
    id TEXT PRIMARY KEY,           -- UUID
    name TEXT NOT NULL,            -- Display name, e.g. "BrightStar Jewellers"
    slug TEXT UNIQUE NOT NULL,     -- URL-safe identifier, e.g. "brightstar"
    description TEXT,
    business_type TEXT,            -- Freeform for now, e.g. "Jewellery retail and repair"
    status TEXT NOT NULL DEFAULT 'setup',  -- setup | active | suspended | archived
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Domain memberships (many-to-many: users ↔ domains)
CREATE TABLE domain_memberships (
    id TEXT PRIMARY KEY,           -- UUID
    user_id TEXT NOT NULL REFERENCES users(id),
    domain_id TEXT NOT NULL REFERENCES domains(id),
    role TEXT NOT NULL DEFAULT 'member',  -- super_admin | admin | member
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    UNIQUE(user_id, domain_id)
);
```

### 4.2 Design notes

- **UUIDs as text:** SQLite has no native UUID type. Using TEXT with UUID v4 values generated in application code. PostgreSQL migration: switch to `UUID` type.
- **Timestamps as TEXT:** ISO 8601 strings. SQLite's `datetime()` function produces these natively. PostgreSQL migration: switch to `TIMESTAMPTZ`.
- **No foreign key cascades yet:** Keep deletion logic explicit in application code for Phase 1. Add cascades when deletion semantics are clearer.
- **Domain status:** The four-value enum (`setup`, `active`, `suspended`, `archived`) covers Phase 1 needs. The `setup` state is what a newly created domain enters. Transition to `active` will happen in Phase 2 when modules can be activated.
- **Role model:** Three roles for Phase 1 (`super_admin`, `admin`, `member`). `super_admin` is the domain creator and can invite others. Permissions are enforced in application code, not database constraints.

---

## 5. Implementation Steps

### Step 1: Project scaffold [Code]

**What:** Initialise a clean SvelteKit project in `portal/` with the full stack configured.

**Instructions for Code:**

1. From repo root, create `portal/` directory
2. Initialise SvelteKit:
   ```bash
   cd portal
   pnpm create svelte@latest . --template skeleton --typescript --no-playwright --no-vitest
   ```
   If the interactive prompt doesn't support flags, answer: Skeleton project, TypeScript, no additional options.
3. Install dependencies:
   ```bash
   pnpm add flowbite flowbite-svelte flowbite-svelte-icons better-sqlite3 bcryptjs uuid
   pnpm add -D tailwindcss @tailwindcss/vite @types/better-sqlite3 @types/bcryptjs @types/uuid
   ```
4. Configure `vite.config.ts`:
   ```typescript
   import { sveltekit } from '@sveltejs/kit/vite';
   import tailwindcss from '@tailwindcss/vite';
   import { defineConfig } from 'vite';

   export default defineConfig({
       plugins: [tailwindcss(), sveltekit()],
       server: { port: 5174 }
   });
   ```
5. Create `src/app.css` — use the console's pattern but with a **distinct Portal colour theme** (warm, approachable tones rather than the console's cool slate):
   ```css
   @import "tailwindcss";
   @plugin "flowbite/plugin";
   @source "../node_modules/flowbite-svelte/dist";
   @source "../node_modules/flowbite-svelte-icons/dist";
   @custom-variant dark (&:where(.dark, .dark *));

   @theme {
     /* Primary — warm teal */
     --color-primary-50:  #f0fdfa;
     --color-primary-100: #ccfbf1;
     --color-primary-200: #99f6e4;
     --color-primary-300: #5eead4;
     --color-primary-400: #2dd4bf;
     --color-primary-500: #14b8a6;
     --color-primary-600: #0d9488;
     --color-primary-700: #0f766e;
     --color-primary-800: #115e59;
     --color-primary-900: #134e4a;

     /* Secondary — warm gray */
     --color-secondary-50:  #fafaf9;
     --color-secondary-100: #f5f5f4;
     --color-secondary-200: #e7e5e4;
     --color-secondary-300: #d6d3d1;
     --color-secondary-400: #a8a29e;
     --color-secondary-500: #78716c;
     --color-secondary-600: #57534e;
     --color-secondary-700: #44403c;
     --color-secondary-800: #292524;
     --color-secondary-900: #1c1917;
   }

   .dark body {
     background-color: #231f1e;
   }
   ```
6. Create `src/app.html` matching the console pattern (charset, viewport, dark class hook).
7. Add `portal/data/` to `.gitignore` (SQLite database files).
8. Verify `pnpm dev` starts cleanly on port 5174.

**Acceptance criteria:**
- `portal/` exists with clean SvelteKit + Tailwind v4 + Flowbite Svelte setup
- `pnpm dev` runs without errors on port 5174
- A basic page renders with Tailwind styling applied
- Colour theme is distinct from the console (warm teal vs cool slate)

---

### Step 2: Database layer [Code]

**What:** Set up SQLite database, schema, and a thin data access layer.

**Instructions for Code:**

1. Create `portal/src/lib/server/db/schema.sql` with the schema from §4.1 above.
2. Create `portal/src/lib/server/db/index.ts` — database initialisation module:
   - Opens (or creates) `portal/data/portal.db`
   - Enables WAL mode and foreign keys
   - Reads and executes `schema.sql` on first run (use `CREATE TABLE IF NOT EXISTS`)
   - Exports a singleton `db` instance
3. Create `portal/src/lib/server/db/users.ts` — user data access:
   - `createUser(email, displayName, passwordHash): User`
   - `getUserByEmail(email): User | null`
   - `getUserById(id): User | null`
   - `updateUser(id, fields): User`
4. Create `portal/src/lib/server/db/sessions.ts` — session data access:
   - `createSession(userId): Session` (generates UUID token, sets 7-day expiry)
   - `getSession(token): Session & User | null` (joins with users, checks expiry)
   - `deleteSession(token): void`
   - `deleteExpiredSessions(): void`
5. Create `portal/src/lib/server/db/domains.ts` — domain data access:
   - `createDomain(name, slug, description, businessType): Domain`
   - `getDomainBySlug(slug): Domain | null`
   - `getDomainById(id): Domain | null`
   - `getDomainsForUser(userId): (Domain & { role: string })[]`
   - `updateDomain(id, fields): Domain`
6. Create `portal/src/lib/server/db/memberships.ts` — membership data access:
   - `addMember(userId, domainId, role): Membership`
   - `getMembership(userId, domainId): Membership | null`
   - `getMembersOfDomain(domainId): (User & { role: string })[]`
   - `updateRole(userId, domainId, role): void`
   - `removeMember(userId, domainId): void`
7. Create `portal/src/lib/types.ts` — shared TypeScript types:
   ```typescript
   export interface User {
       id: string;
       email: string;
       displayName: string;
       createdAt: string;
       updatedAt: string;
   }

   export interface Domain {
       id: string;
       name: string;
       slug: string;
       description: string | null;
       businessType: string | null;
       status: 'setup' | 'active' | 'suspended' | 'archived';
       createdAt: string;
       updatedAt: string;
   }

   export interface DomainMembership {
       id: string;
       userId: string;
       domainId: string;
       role: 'super_admin' | 'admin' | 'member';
       createdAt: string;
   }

   export type DomainWithRole = Domain & { role: string };
   ```

**Acceptance criteria:**
- Database creates automatically on first access
- All CRUD operations work via the data access functions
- Types are clean and shared across server and client where appropriate

---

### Step 3: Authentication [Code]

**What:** Implement register, login, logout with session cookie management.

**Instructions for Code:**

1. Create `portal/src/lib/server/auth.ts` — auth utilities:
   - `hashPassword(password): string` — bcryptjs, 12 rounds
   - `verifyPassword(password, hash): boolean`
   - `setSessionCookie(cookies, token): void` — HTTP-only, secure (in production), SameSite=Lax, path=/, 7-day max-age
   - `clearSessionCookie(cookies): void`
2. Create `portal/src/hooks.server.ts` — SvelteKit server hook:
   - On every request, read the session cookie
   - If valid session exists, populate `event.locals.user` with the user object
   - If no valid session or expired, `event.locals.user = null`
   - Protected routes (everything except `/login`, `/register`, `/`) redirect to `/login` if no user
3. Create `portal/src/app.d.ts` — extend SvelteKit types:
   ```typescript
   declare global {
       namespace App {
           interface Locals {
               user: import('$lib/types').User | null;
           }
       }
   }
   export {};
   ```
4. Create registration page at `portal/src/routes/register/+page.svelte` and `+page.server.ts`:
   - Form with: email, display name, password, confirm password
   - Server-side validation: email format, password length (≥8), passwords match, email not already registered
   - On success: create user, create session, set cookie, redirect to `/domains`
   - Use Flowbite Svelte form components (Input, Label, Button, Alert for errors)
   - Clean, centred card layout
5. Create login page at `portal/src/routes/login/+page.svelte` and `+page.server.ts`:
   - Form with: email, password
   - Server-side validation: check credentials, create session, set cookie, redirect to `/domains`
   - On failure: generic "Invalid email or password" (no information leakage)
   - Link to registration page
6. Create logout action at `portal/src/routes/logout/+page.server.ts`:
   - Delete session from database
   - Clear session cookie
   - Redirect to `/login`
7. Create landing page at `portal/src/routes/+page.svelte`:
   - If logged in: redirect to `/domains`
   - If not logged in: a simple welcome page with links to login and register
   - Branded with "Ontara Portal" identity

**Acceptance criteria:**
- A new user can register with email, name, and password
- A registered user can log in and receives a session cookie
- Protected routes redirect to login when not authenticated
- Logout clears the session
- Password is stored as bcrypt hash, never in plain text
- Session expiry works (7-day sessions)

---

### Step 4: Portal layout shell [Code]

**What:** Create the shared layout with navigation, header, sidebar, and user menu.

**Instructions for Code:**

1. Create `portal/src/routes/(app)/+layout.svelte` — the authenticated layout:
   - Top navigation bar with: "Ontara Portal" branding (left), domain switcher dropdown (centre/left), user menu (right)
   - Sidebar: collapsible, with navigation links. Phase 1 links: Dashboard, Settings (domain), Profile
   - Main content area with breadcrumb trail
   - Use Flowbite Svelte components: Navbar, Sidebar, Dropdown, Avatar, Breadcrumb
   - Dark mode toggle in the user menu
   - Footer with "Ontara Platform" and version placeholder
2. Create `portal/src/routes/(app)/+layout.server.ts`:
   - Load user data and the user's domains list for the domain switcher
   - Determine the "current domain" from URL or cookie/preference
3. The `(app)` route group wraps all authenticated pages. The `(auth)` group (or root-level `/login`, `/register`) uses a minimal layout without sidebar.
4. Design the domain switcher:
   - Dropdown showing all domains the user belongs to, with their role
   - "Create new domain" option at the bottom
   - Current domain highlighted
   - Selecting a domain navigates to `/domains/[slug]`

**Acceptance criteria:**
- Authenticated pages share a consistent layout with nav, sidebar, and content area
- Domain switcher shows the user's domains and allows switching
- The layout is responsive and looks professional
- Dark mode works via toggle

---

### Step 5: Domain creation and management [Code]

**What:** Implement creating domains, listing domains, and the domain dashboard.

**Instructions for Code:**

1. Create domains list page at `portal/src/routes/(app)/domains/+page.svelte` and `+page.server.ts`:
   - Shows all domains the user belongs to, as cards
   - Each card: domain name, business type, status badge, role badge, creation date
   - "Create new domain" button (prominent)
   - If no domains: friendly empty state with "Create your first domain" CTA
2. Create domain creation page at `portal/src/routes/(app)/domains/new/+page.svelte` and `+page.server.ts`:
   - Multi-step form or single-page form with sections:
     - Domain name (required)
     - URL slug (auto-generated from name, editable, validated for uniqueness)
     - Business type (freeform text input with placeholder suggestions)
     - Description (optional textarea)
   - On success: create domain, create super_admin membership for current user, redirect to `/domains/[slug]`
3. Create domain dashboard at `portal/src/routes/(app)/domains/[slug]/+page.svelte` and `+page.server.ts`:
   - The **empty shell dashboard** — this is the key Phase 1 deliverable
   - Layout: domain header (name, type, status badge), then a structured but empty content area
   - The content area should convey "ready to receive modules" with:
     - A "Getting Started" section or card explaining that modules will be available (future work)
     - Placeholder module grid area (empty, with a dashed border or ghost cards)
     - Domain info sidebar: creation date, members count, status
   - The dashboard should feel like a space that will be filled, not a barren error state
4. Create domain settings page at `portal/src/routes/(app)/domains/[slug]/settings/+page.svelte` and `+page.server.ts`:
   - Edit domain name, description, business type
   - View members list (with roles)
   - Only super_admin can edit settings
5. Add slug-based route parameter validation: if the slug doesn't match a domain the user has access to, redirect to `/domains`.

**Acceptance criteria:**
- A user can create a domain with name, slug, type, and description
- The domain appears in the domains list and domain switcher
- The domain dashboard shows the domain in "Setup" status with structured empty space
- Domain settings allow editing (super_admin only)
- URL slugs are validated for uniqueness and URL-safety

---

### Step 6: User profile [Code]

**What:** Basic profile page for account management.

**Instructions for Code:**

1. Create profile page at `portal/src/routes/(app)/profile/+page.svelte` and `+page.server.ts`:
   - Display: email, display name, member since date
   - Edit: display name (email change deferred)
   - Password change: current password, new password, confirm new password
   - Domains list: all domains with roles (links to each domain)

**Acceptance criteria:**
- User can view their profile
- User can update their display name
- User can change their password

---

### Step 7: Polish and integration [Code]

**What:** Final polish pass across the application.

**Instructions for Code:**

1. Ensure consistent error handling across all pages (form validation errors, not-found states, unauthorized access)
2. Add loading states where appropriate (Flowbite Spinner)
3. Verify all Flowbite Svelte components render correctly in both light and dark modes
4. Ensure the portal runs cleanly from cold start: `cd portal && pnpm install && pnpm dev`
5. Add `portal/README.md` with:
   - What this is (Ontara Portal — Phase 1 prototype)
   - How to run (`pnpm install`, `pnpm dev`)
   - Database location (`data/portal.db`, gitignored, created automatically)
   - Tech stack summary
6. Update repo root `.gitignore` if needed for `portal/data/`
7. Commit with message: `Session 175: Stage 8 Phase 1 — Ontara Portal empty shell`

**Acceptance criteria:**
- The full Phase 1 flow works end-to-end: register → log in → create domain → view dashboard → switch domains → edit profile → log out → log back in
- No console errors in browser
- Professional appearance in both light and dark modes
- Cold start works with no manual setup beyond `pnpm install && pnpm dev`

---

## 6. Portal Information Architecture

### Route structure

```
/                           Landing (redirects to /domains if logged in)
/register                   Registration
/login                      Login
/logout                     Logout (POST action)
/domains                    Domain list (authenticated)
/domains/new                Create domain (authenticated)
/domains/[slug]             Domain dashboard (authenticated, role-checked)
/domains/[slug]/settings    Domain settings (authenticated, super_admin)
/profile                    User profile (authenticated)
```

### File structure (within `portal/src/`)

```
lib/
  server/
    db/
      index.ts              Database singleton
      schema.sql            Schema definition
      users.ts              User data access
      sessions.ts           Session data access
      domains.ts            Domain data access
      memberships.ts        Membership data access
    auth.ts                 Auth utilities
  types.ts                  Shared TypeScript types
routes/
  +page.svelte              Landing page
  +layout.svelte            Root layout (minimal)
  login/
    +page.svelte            Login form
    +page.server.ts         Login action
  register/
    +page.svelte            Registration form
    +page.server.ts         Registration action
  logout/
    +page.server.ts         Logout action
  (app)/
    +layout.svelte          Authenticated layout (nav, sidebar, domain switcher)
    +layout.server.ts       Load user + domains
    domains/
      +page.svelte          Domain list
      +page.server.ts       Load domains
      new/
        +page.svelte        Create domain form
        +page.server.ts     Create domain action
      [slug]/
        +page.svelte        Domain dashboard
        +page.server.ts     Load domain
        +layout.server.ts   Validate domain access
        settings/
          +page.svelte      Domain settings
          +page.server.ts   Settings actions
    profile/
      +page.svelte          User profile
      +page.server.ts       Profile actions
app.css                     Tailwind + Flowbite + Portal theme
app.html                    HTML shell
app.d.ts                    SvelteKit type extensions
hooks.server.ts             Auth middleware
```

---

## 7. Design Direction

The portal should feel like a **real product**, not a prototype. Visual principles:

- **Warm and approachable.** The teal primary colour and warm grays distinguish the portal from the console's cool, analytical palette. The portal is for operators, not architects.
- **Spacious and structured.** Generous whitespace. Clear visual hierarchy. The empty dashboard should feel like a well-designed empty room — ready for furniture, not desolate.
- **State is visible.** Status badges on every entity (domain status, user role). Consistent colour coding: green for active/ready, amber for setup/pending, red for issues.
- **Flowbite Svelte as the foundation.** Use Flowbite components consistently rather than custom-building equivalents. Card, Badge, Button, Input, Sidebar, Navbar, Dropdown, Avatar, Breadcrumb, Alert, Spinner — these cover Phase 1 needs.

---

## 8. Acceptance Criteria

Phase 1 is complete when all of the following are true:

1. **Registration:** A new user can register with email, display name, and password
2. **Login/logout:** Authentication works with session cookies; logout clears the session
3. **Domain creation:** A logged-in user can create one or more domains with name, slug, type, and description
4. **Domain dashboard:** Each domain has a dashboard page showing the domain in "Setup" status with a structured empty space ready for modules
5. **Domain switching:** A user can switch between their domains via the domain switcher
6. **Professional appearance:** The portal has a polished, product-quality appearance with warm teal theme, dark mode support, and consistent Flowbite Svelte components
7. **Clean architecture:** The shell is clean enough to receive modules (Phase 2) without structural rework — the database schema, route structure, layout, and types are extensible
8. **Cold start:** A developer can clone the repo, run `cd portal && pnpm install && pnpm dev`, and have the portal running with no additional setup
9. **Committed:** All code committed with `Session 175` in the message

---

## 9. Register Connections

| Register concept | How exercised in Phase 1 |
|---|---|
| [[principle-separation-representation-execution\|A1]] | Domain configuration (name, type, description) is cleanly separated from any future execution machinery. The schema is a representation layer |
| [[principle-self-describing-system\|A2]] | The empty dashboard explains what it is and what will come — the system describes its own state even when that state is "empty" |
| [[concept-multi-tenancy\|A13]] | Domains are tenants from the start. Multi-domain, multi-user, role-based access |
| [[concept-co-evolution\|J2]] | We build the visible shell first. No invisible infrastructure without a surface. The database schema exists to serve the UI |
| [[concept-non-constraining\|J3]] | Schema and route structure designed to accommodate Phase 2 modules without restructuring. SQLite chosen with PostgreSQL migration path |
| [[principle-discipline-as-load-bearing-structure\|A9]] | Clean code, TypeScript strict mode, proper auth, session management — prototype with production discipline |

---

## 10. Open Questions Resolved for Phase 1

| Question (from Stage 8 plan §14) | Resolution |
|---|---|
| Domain creation wizard — how does the operator specify business type? | Freeform text input with placeholder suggestions. Structured domain type selection is Phase 2+ (when the module catalogue filters by domain type) |
| Domain dashboard layout — how to convey "empty but structured"? | Structured card layout with placeholder module grid, getting-started guidance, and domain info sidebar |
| Multi-domain navigation? | Domain switcher dropdown in the top nav bar, plus a domains list page |

---

*Phase 1 plan produced Session 175, 8 April 2026.*
