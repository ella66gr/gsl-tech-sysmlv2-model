# Session 21 Report — CSW Extension Phase 2: PostgreSQL Foundation

**Date:** 12 March 2026
**Session number:** 21
**Workstream:** CSW Extension — Catalogue, Inventory & Frontend (Phase 2 of 10)
**Plan:** `gsl-plan-csw-extension-phase2-implementation-2026-03-12.md`

---

## Summary

Executed Phase 2 of the CSW Extension workstream: the PostgreSQL business database layer. The coffee shop demonstrator now has three operational persistence layers — CDR (EHRbase), business database (PostgreSQL), and process engine (Temporal). A typed TypeScript database client paralleling the existing EHRbase client was created in `@coffeeshop/shared`, and SvelteKit verification endpoints confirm the full stack from Docker container through to API response.

---

## Work Completed

### Stage 1: Docker Compose and Database Setup

**Docker Compose update:** Added `coffeeshop-db` service to `docker-compose.ehrbase.yml` — PostgreSQL 16 on port 5434, separate from the EHRbase CDR PostgreSQL on port 5433. Named volume `coffeeshop-pg-data` for data persistence. SQL initialisation files mounted to `/docker-entrypoint-initdb.d` for automatic schema and seed data on first container creation.

**Schema (`001-schema.sql`):** Four tables derived from the SysML domain model (Phase 1):
- `menu_items` — single-table inheritance mapping of MenuItem/Drink/FoodItem hierarchy with `item_type` discriminator
- `external_references` — FK to menu_items, CASCADE delete
- `catalogue_entries` — FK to menu_items, UNIQUE on (menu_item_id, effective_date) for price history
- `inventory_records` — FK to catalogue_entries

Four indices on common query patterns (catalogue by item, catalogue by availability, inventory by catalogue entry, inventory by status).

**Seed data (`002-seed.sql`):** 11 menu items (7 existing + 4 new), 11 catalogue entries with prices and provision types, 2 inventory records for bought-in items (Ginger Biscuit: 24 units, Oat Bar: 18 units).

**Verification:** All four tables created, 11 catalogue entries with correct prices, 2 inventory records with correct stock levels. Host connectivity confirmed on port 5434.

**Commit:** `fcda2eb` — CSW: PostgreSQL business database with schema and seed data

### Stage 2: TypeScript Database Client

**Dependencies:** Added `pg` and `@types/pg` to `@coffeeshop/shared`.

**`postgres-client.ts`:** Thin typed wrapper around `pg.Pool`, paralleling `ehrbase-client.ts` in structure:
- `PostgresConfig` interface with defaults matching the Docker Compose service
- `createPostgresClient()` factory function returning a `PostgresClient` interface
- Six typed query methods: `getActiveCatalogue()`, `getCatalogueEntry()`, `getAllCatalogueEntries()`, `getInventory()`, `getInventoryRecord()`, `getLowStockItems()`
- Two joined view types: `CatalogueItemView` (catalogue + menu item), `InventoryItemView` (inventory + catalogue + menu item)
- Three row types: `MenuItemRow`, `CatalogueEntryRow`, `InventoryRecordRow`
- `PostgresClientError` domain-specific error type
- Snake_case → camelCase mapping at the query boundary via explicit row mapping functions
- Parameterised queries throughout (SQL injection prevention)
- Raw `query()` escape hatch for ad-hoc queries
- `close()` for graceful pool shutdown

**Build:** Clean `tsc` compilation with no errors.

**Commit:** `09aa565` — CSW: PostgreSQL client in @coffeeshop/shared

### Stage 3: SvelteKit Integration and Verification

**Server singleton:** `$lib/server/postgres.ts` — lazy singleton paralleling `$lib/server/ehrbase.ts`. The `$lib/server/` directory ensures SvelteKit never bundles the PostgreSQL client into client-side code.

**Verification endpoints:**
- `GET /api/catalogue` — returns all active catalogue entries joined with menu item details
- `GET /api/inventory` — returns all inventory records joined with catalogue and menu item details

**Dependency resolution:** `pg` resolved through pnpm workspace hoisting from `@coffeeshop/shared` — no direct dependency needed in `@coffeeshop/web`.

**Full stack verification:** Vite dev server started cleanly. `/api/catalogue` returned 11 items with correct camelCase field mapping, `availableSizes` as proper arrays, all drink and food type-specific fields populated. `/api/inventory` returned 2 bought-in items with stock levels and thresholds. Existing API routes (`/api/orders`, `/api/entity/*`) unaffected.

**Commit:** `2133887` — CSW: SvelteKit PostgreSQL integration with verification endpoints

---

## Findings

### pg ESM Import Pattern

The `pg` package is CommonJS. In an ESM TypeScript project, the correct import pattern is:

```typescript
import pg from 'pg';
const { Pool } = pg;
```

Not `import { Pool } from 'pg'` (which would fail). This is the standard workaround for CommonJS packages consumed from ESM and worked first time.

### pnpm Workspace Hoisting Resolves Cross-Package Dependencies

`@coffeeshop/web` imports `@coffeeshop/shared` which imports `pg`. The web package did not need `pg` as a direct dependency — pnpm's workspace hoisting made it available at runtime through the workspace link. This means the dependency tree stays clean: `pg` is declared once in `@coffeeshop/shared` and available wherever the shared package is consumed.

### Docker Entrypoint SQL Runs Only on First Volume Creation

The `/docker-entrypoint-initdb.d` mount runs SQL files only when the PostgreSQL data volume is first created. On subsequent `docker compose up`, the existing data is preserved. To reset: `docker compose down -v && docker compose up -d`. This is the correct behaviour for development — data persists across restarts, full reset requires explicit volume removal.

### PGPASSWORD Required for Host psql

The `psql` client on the host requires the password to be supplied. `PGPASSWORD=coffeeshop_dev psql -h localhost -p 5434 ...` works. This is standard PostgreSQL behaviour — the Docker-internal verification (via `docker exec`) doesn't need it because it uses the container's local socket.

---

## Coffee Shop Demonstrator Extension

**Capability demonstrated:** Three-persistence-layer architecture operational — CDR, business database, and process engine running as separate services with distinct responsibilities.

**What was built:** PostgreSQL Docker service, four-table schema derived from SysML model, seed data for 11 items, typed TypeScript database client with joined view queries, SvelteKit server singleton, two verification API endpoints.

**What was learned:**
- The `pg` ESM import pattern (`import pg from 'pg'; const { Pool } = pg;`)
- pnpm workspace hoisting resolves transitive dependencies across workspace packages
- Docker entrypoint SQL is first-run only (volume-creation gated)
- The `ehrbase-client.ts` pattern (config → factory → typed interface → singleton consumer) transfers cleanly to a second persistence layer

**Clinical implementation confidence:** High. The PostgreSQL client pattern is directly reusable for GSL's business database (user accounts, service configuration, billing, appointment scheduling). The typed query interface with joined views demonstrates the approach for more complex clinical business queries.

---

## Architecture Notes

### Persistence Layer Summary

| Layer | Service | Port | Client | Singleton |
|---|---|---|---|---|
| CDR | EHRbase + PostgreSQL | 5433 (DB), 8080 (API) | `ehrbase-client.ts` | `$lib/server/ehrbase.ts` |
| Business DB | PostgreSQL 16 | 5434 | `postgres-client.ts` | `$lib/server/postgres.ts` |
| Process Engine | Temporal | 7233 | `@temporalio/client` | `$lib/server/temporal.ts` |

### No ORM Decision

The coffee shop deliberately uses thin, hand-written clients for each persistence layer. No Drizzle, Prisma, or Kysely. The mapping from database rows to TypeScript types is explicit and visible. For four tables, parameterised SQL is clearer and more instructive than any ORM abstraction. The pattern is consistent across all three persistence layers.

---

## Git Log

| Commit | Description |
|---|---|
| `fcda2eb` | CSW: PostgreSQL business database with schema and seed data |
| `09aa565` | CSW: PostgreSQL client in @coffeeshop/shared |
| `2133887` | CSW: SvelteKit PostgreSQL integration with verification endpoints |

---

## Next Session

Continue CSW Extension workstream — **Phase 3: Catalogue & Inventory API Routes**:
- Add mutation methods to `postgres-client.ts` (insert menu item + catalogue entry, update catalogue entry, update inventory)
- `POST /api/catalogue` — add new menu item + catalogue entry
- `PUT /api/catalogue/[id]` — update price, availability, description
- `PUT /api/inventory/[id]` — update stock level
- Rewire `POST /api/orders` to validate against catalogue (item must be active)

Phase 3 implementation plan: `gsl-plan-workstream-csw-extension-2026-03-12.md` §Phase 3.

---

## Syntax Reference

No update required — no SysML changes in this phase.

---

*Session 21 report prepared 12 March 2026.*
