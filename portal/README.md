# Ontara Portal

The user-facing Ontara platform shell — Phase 1 prototype.

## Quick Start

```bash
pnpm install
pnpm rebuild better-sqlite3  # required on first install — compiles the native SQLite binary
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

## Auto-start on login (launchd)

A LaunchAgent plist is provided at `dev.ontara.portal.plist`. Install with:

```bash
cp dev.ontara.portal.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/dev.ontara.portal.plist
```

The plist is the canonical copy; copying into `~/Library/LaunchAgents/` is the macOS convention. Update by editing the canonical copy here, then re-copying and reloading:

```bash
launchctl unload ~/Library/LaunchAgents/dev.ontara.portal.plist
cp dev.ontara.portal.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/dev.ontara.portal.plist
```

Force a kick (after deploying changes, or if the service appears stuck):

```bash
launchctl kickstart -k gui/$(id -u)/dev.ontara.portal
```

If the kickstart appears not to take, force-kill the worker holding port 5174 and let launchd restart it:

```bash
lsof -ti :5174 | xargs -r kill -9
sleep 2
launchctl kickstart -k gui/$(id -u)/dev.ontara.portal
```

Logs:

```
~/Library/Logs/ontara-portal.out.log
~/Library/Logs/ontara-portal.err.log
```

The LaunchAgent runs `pnpm dev`, so HMR is active just as it would be when run interactively.
