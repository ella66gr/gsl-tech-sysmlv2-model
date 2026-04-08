# Ontara Portal

The user-facing Ontara platform shell — Phase 1 prototype.

## Quick Start

```bash
pnpm install
pnpm dev
```

The portal runs at http://localhost:5174. The SQLite database is created automatically in `data/portal.db` on first run (gitignored).

## Tech Stack

- SvelteKit + Svelte 5 (runes)
- Tailwind v4 + Flowbite Svelte
- SQLite via better-sqlite3
- TypeScript

## Phase 1 Features

- User registration and authentication (local accounts, bcrypt + session cookies)
- Domain creation and management (name, slug, business type, description)
- Multi-domain support with role-based access (super_admin, admin, member)
- Domain dashboard (empty shell, ready for Phase 2 modules)
- Domain settings and user profile management
- Full dark mode support
- Warm teal theme distinct from the console's cool slate
