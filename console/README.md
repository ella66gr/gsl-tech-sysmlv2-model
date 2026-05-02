# Ontara Console

The architect/developer-facing Ontara platform tooling — model introspection, coverage matrix, weighted relationships, ontology browser, governance traceability, reasoning vocabulary explorer, and the dual-canvas vision.

## Quick Start

```bash
pnpm install
pnpm dev
```

The console runs at http://localhost:5173. The console's primary data source is `static/data/model-introspection.json`, refreshed via `pnpm refresh-data` when the SysML projection has been re-introspected.

## Tech Stack

- SvelteKit + Svelte 5
- Tailwind v4 + Flowbite Svelte
- 3d-force-graph + three.js (WebGL graph rendering for weighted relationships)
- d3 (data visualisation)
- TypeScript

## Refreshing the model data

```bash
pnpm refresh-data
```

This copies `../generated/ontara/model-introspection.json` into `static/data/`. Run after any introspection regeneration.

## Auto-start on login (launchd)

A LaunchAgent plist is provided at `dev.ontara.console.plist`. Install with:

```bash
cp dev.ontara.console.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/dev.ontara.console.plist
```

The plist is the canonical copy; copying into `~/Library/LaunchAgents/` is the macOS convention. Update by editing the canonical copy here, then re-copying and reloading:

```bash
launchctl unload ~/Library/LaunchAgents/dev.ontara.console.plist
cp dev.ontara.console.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/dev.ontara.console.plist
```

Force a kick (after deploying changes, or if the service appears stuck):

```bash
launchctl kickstart -k gui/$(id -u)/dev.ontara.console
```

If the kickstart appears not to take, force-kill the worker holding port 5173 and let launchd restart it:

```bash
lsof -ti :5173 | xargs -r kill -9
sleep 2
launchctl kickstart -k gui/$(id -u)/dev.ontara.console
```

Logs:

```
~/Library/Logs/ontara-console.out.log
~/Library/Logs/ontara-console.err.log
```

The LaunchAgent runs `pnpm dev`, so HMR is active just as it would be when run interactively.
