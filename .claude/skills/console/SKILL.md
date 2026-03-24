---
name: console
description: Start the Ontara Console dev server or run console commands
allowed-tools: Bash
---

# Ontara Console

Manage the Ontara Console (SvelteKit + Svelte 5 + Flowbite Svelte + Tailwind v4).

## Default action (no arguments): Start dev server

```bash
cd console
pnpm dev
```

The console runs at http://localhost:5173.

## Arguments

- `/console build` — Run production build: `cd console && pnpm build`
- `/console refresh` — Sync latest generated data: `cd console && pnpm run refresh-data`
- `/console check` — Run Svelte type check: `cd console && pnpm check`

## Notes

- The console reads its data from `console/static/data/model-introspection.json`
- If the data looks stale, run `/generate` first to regenerate from the SysML model, then `/console refresh`
- The console uses Svelte 5 runes syntax (not Svelte 4 stores). Use `$state()`, `$derived()`, `$effect()` — not `writable()` or `$:`.
- UI components come from Flowbite Svelte. Check their docs before creating custom components.
