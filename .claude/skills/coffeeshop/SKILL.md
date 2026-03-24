---
name: coffeeshop
description: Start or manage the Coffee Shop demonstrator application
allowed-tools: Bash
---

# Coffee Shop Demonstrator

The Coffee Shop is the full running demonstrator app: SvelteKit frontend + Temporal workflow engine + EHRbase CDR + PostgreSQL.

## Default action: Start all services

Start services in this order:

1. **EHRbase + PostgreSQL** (Docker):
   ```bash
   cd exercises/coffeeshop-demonstrator
   docker compose -f docker-compose.ehrbase.yml up -d
   ```
   Wait for containers to be healthy before proceeding.

2. **Temporal worker** (in a separate terminal/background):
   ```bash
   cd exercises/coffeeshop-demonstrator
   pnpm dev:temporal
   ```

3. **Web frontend**:
   ```bash
   cd exercises/coffeeshop-demonstrator
   pnpm dev:web
   ```

## Arguments

- `/coffeeshop stop` — Stop Docker services: `cd exercises/coffeeshop-demonstrator && docker compose -f docker-compose.ehrbase.yml down`
- `/coffeeshop generate` — Regenerate from SysML model: `cd exercises/coffeeshop-demonstrator && pnpm generate`
- `/coffeeshop build` — Build all packages: `cd exercises/coffeeshop-demonstrator && pnpm build:all`

## Architecture

- `packages/web/` — SvelteKit frontend (9 pages, 19 API routes)
- `packages/temporal/` — Temporal worker with FulfilDrink workflow
- `packages/shared/` — Shared types and generated code
- `model/` — SysML domain model files
- `generators/` — Python generators for workflows, types, state machines
- `sql/` — PostgreSQL schema
- `ehrbase/` — EHRbase templates and operational templates
