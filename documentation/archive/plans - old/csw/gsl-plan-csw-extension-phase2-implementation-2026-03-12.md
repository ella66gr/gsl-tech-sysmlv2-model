# CSW Extension Phase 2: PostgreSQL Foundation — Detailed Implementation Plan

**Workstream:** Coffee Shop Extension — Catalogue, Inventory & Frontend
**Phase:** 2 of 10
**Date:** 12 March 2026
**Prerequisites:** Phase 1 complete (SysML domain model update, Session 20)
**Source plan:** `gsl-plan-workstream-csw-extension-2026-03-12.md`
**Specification:** `catalogue-inventory-spec-v2.md` (§4.1 tables, §5.3 seed data)
**Estimated effort:** 3 stages

---

## Goal

Business database operational with catalogue and inventory tables, seeded with data. TypeScript client in `@coffeeshop/shared` paralleling the `ehrbase-client.ts` pattern. The system has its second persistence layer running alongside the CDR.

---

## Architectural Context

Phase 0 established the three-persistence-layer architecture:

| Layer | Technology | Holds |
|---|---|---|
| Clinical Data Repository | EHRbase (openEHR on PostgreSQL) | Health records (orders, feedback, preparation) |
| **Business Database** | **PostgreSQL** | **Catalogue, inventory, pricing, configuration** |
| Process Engine | Temporal | Workflow state, durable execution |

This phase introduces the business database layer. The CDR already runs on PostgreSQL (EHRbase's backing store on port 5433). The business database is a **separate PostgreSQL instance** — architecturally distinct even though it's the same technology.

### Infrastructure Decision: Separate Container vs Shared Instance

**Decision: Separate PostgreSQL container.**

Rationale:
- **Cleaner boundary.** The CDR's PostgreSQL is managed by EHRbase — its schema, migrations, and configuration are EHRbase's concern. Adding application tables to it conflates responsibilities.
- **Independent lifecycle.** The business database can be stopped, reset, or migrated without affecting the CDR. During development, `docker compose down -v` on the business database doesn't destroy clinical data.
- **Port clarity.** Port 5433 = CDR (EHRbase's PostgreSQL). Port 5434 = business database. No ambiguity.
- **GSL pattern.** In the clinical system, the CDR and business database will absolutely be separate. The coffee shop should model the same separation.
- **Minimal overhead.** PostgreSQL is lightweight; a second container adds negligible resource cost.

---

## Stage 1: Docker Compose and Database Setup

### 1.1 Extend `docker-compose.ehrbase.yml`

Add a new PostgreSQL service for the business database to the existing compose file. This keeps all CSW infrastructure in one compose file for single-command start/stop.

**Add to `services:` section:**

```yaml
  # ── Business Database ──────────────────────────────────────────
  # Separate PostgreSQL instance for business data (catalogue,
  # inventory, pricing). Architecturally distinct from the CDR.
  # Port 5434 to avoid conflict with EHRbase's PostgreSQL (5433)
  # and any local PostgreSQL (5432).
  coffeeshop-db:
    image: postgres:16
    environment:
      POSTGRES_DB: coffeeshop_business
      POSTGRES_USER: coffeeshop
      POSTGRES_PASSWORD: coffeeshop_dev
    ports:
      - "5434:5432"
    volumes:
      - coffeeshop-pg-data:/var/lib/postgresql/data
      - ./sql/init:/docker-entrypoint-initdb.d
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U coffeeshop -d coffeeshop_business"]
      interval: 5s
      timeout: 5s
      retries: 10
```

**Add to `volumes:` section:**

```yaml
  coffeeshop-pg-data:
```

**Design notes:**

- `postgres:16` — matches the EHRbase PostgreSQL version (16.2) for consistency. Official image, not the EHRbase-customised one.
- `POSTGRES_DB: coffeeshop_business` — database created automatically on first start.
- `POSTGRES_USER: coffeeshop` / `POSTGRES_PASSWORD: coffeeshop_dev` — development credentials. Production would use secrets.
- Port `5434` — the third port in the sequence: 5432 (local dev), 5433 (EHRbase CDR), 5434 (business DB).
- `./sql/init` mount to `/docker-entrypoint-initdb.d` — PostgreSQL's official image runs all `.sql` files in this directory on first container creation (alphabetical order). This gives us automatic schema + seed data on `docker compose up`.
- Named volume `coffeeshop-pg-data` — data persists across restarts. `docker compose down -v` removes both volumes (CDR and business DB) for a clean reset.

### 1.2 Create SQL initialisation files

Create `exercises/coffeeshop-demonstrator/sql/init/` directory with two files, executed in alphabetical order by the PostgreSQL entrypoint:

#### `001-schema.sql` — Table definitions

Derived from `catalogue-inventory-spec-v2.md` §4.1. These tables are the PostgreSQL materialisation of the SysML domain model types created in Phase 1.

```sql
-- =============================================================================
-- Coffee Shop Business Database — Schema
-- Derived from SysML domain model (CoffeeShop package)
-- Spec: catalogue-inventory-spec-v2.md §4.1
-- =============================================================================

-- Item definitions: what things intrinsically are
-- Single-table mapping of MenuItem/Drink/FoodItem hierarchy
CREATE TABLE menu_items (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name            TEXT NOT NULL UNIQUE,
    category        TEXT NOT NULL CHECK (category IN ('hot_drink', 'cold_drink', 'food')),
    item_type       TEXT NOT NULL CHECK (item_type IN ('drink', 'food_item')),
    description     TEXT,
    is_vegan        BOOLEAN NOT NULL DEFAULT false,

    -- Drink-specific (NULL for food items)
    default_milk    TEXT CHECK (default_milk IN ('whole', 'semi', 'oat', 'soy', 'almond', 'none')),
    available_sizes TEXT[],
    is_caffeinated  BOOLEAN,

    -- FoodItem-specific (NULL for drinks)
    is_gluten_free  BOOLEAN,
    served_warm     BOOLEAN,

    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- External references: links to knowledge outside the system
CREATE TABLE external_references (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    menu_item_id    UUID NOT NULL REFERENCES menu_items(id) ON DELETE CASCADE,
    reference_type  TEXT NOT NULL,
    reference_id    TEXT NOT NULL,
    reference_source TEXT NOT NULL,
    reference_notes TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Catalogue entries: business decisions about what to offer
CREATE TABLE catalogue_entries (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    menu_item_id    UUID NOT NULL REFERENCES menu_items(id),
    price_pence     INTEGER NOT NULL,
    price_display   TEXT NOT NULL,
    availability    TEXT NOT NULL DEFAULT 'active'
                    CHECK (availability IN ('active', 'discontinued', 'seasonal', 'temporarily_unavailable')),
    provision_type  TEXT NOT NULL CHECK (provision_type IN ('prepared', 'bought_in', 'hybrid')),
    effective_date  TIMESTAMPTZ NOT NULL DEFAULT now(),
    status_notes    TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (menu_item_id, effective_date)
);

-- Inventory records: operational stock state
CREATE TABLE inventory_records (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    catalogue_entry_id  UUID NOT NULL REFERENCES catalogue_entries(id),
    quantity_on_hand    INTEGER NOT NULL DEFAULT 0,
    stock_status        TEXT NOT NULL DEFAULT 'in_stock'
                        CHECK (stock_status IN ('in_stock', 'low', 'out_of_stock', 'on_order')),
    low_stock_threshold INTEGER NOT NULL DEFAULT 5,
    last_restocked      TIMESTAMPTZ,
    quantity_notes      TEXT,
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indices for common query patterns
CREATE INDEX idx_catalogue_entries_item ON catalogue_entries(menu_item_id);
CREATE INDEX idx_catalogue_entries_availability ON catalogue_entries(availability);
CREATE INDEX idx_inventory_records_catalogue ON inventory_records(catalogue_entry_id);
CREATE INDEX idx_inventory_records_status ON inventory_records(stock_status);
```

**Mapping notes (SysML → PostgreSQL):**

| SysML concept | PostgreSQL table | Mapping strategy |
|---|---|---|
| `MenuItem` / `Drink` / `FoodItem` | `menu_items` | Single-table inheritance with `item_type` discriminator |
| `ExternalReference` | `external_references` | Direct 1:1, FK to `menu_items` |
| `CatalogueEntry` | `catalogue_entries` | Direct 1:1, FK to `menu_items` |
| `InventoryRecord` | `inventory_records` | Direct 1:1, FK to `catalogue_entries` |
| SysML camelCase enums | PostgreSQL snake_case CHECK constraints | Convention: `temporarilyUnavailable` → `temporarily_unavailable` |
| SysML `ref item : MenuItem` | FK `menu_item_id UUID REFERENCES menu_items(id)` | Reference becomes foreign key |
| SysML `ref catalogueEntry : CatalogueEntry` | FK `catalogue_entry_id UUID REFERENCES catalogue_entries(id)` | Reference becomes foreign key |

#### `002-seed.sql` — Seed data

From `catalogue-inventory-spec-v2.md` §5.3:

```sql
-- =============================================================================
-- Coffee Shop Business Database — Seed Data
-- 11 items: 7 existing + 4 new (mocha latte, frappe, ginger biscuit, oat bar)
-- Spec: catalogue-inventory-spec-v2.md §5.1, §5.2, §5.3
-- =============================================================================

-- Menu items (intrinsic product definitions)
INSERT INTO menu_items (name, category, item_type, is_vegan, description, default_milk, available_sizes, is_caffeinated) VALUES
  ('Flat White',    'hot_drink',  'drink', false, 'Velvety microfoam espresso', 'whole', ARRAY['small','medium','large'], true),
  ('Latte',         'hot_drink',  'drink', false, 'Espresso with steamed milk', 'whole', ARRAY['small','medium','large'], true),
  ('Americano',     'hot_drink',  'drink', true,  'Espresso with hot water',    'none',  ARRAY['small','medium','large'], true),
  ('Cappuccino',    'hot_drink',  'drink', false, 'Espresso with foamed milk',  'whole', ARRAY['small','medium','large'], true),
  ('Espresso',      'hot_drink',  'drink', true,  'Single or double shot',      'none',  ARRAY['small'],                 true),
  ('Iced Latte',    'cold_drink', 'drink', false, 'Espresso over ice with milk','whole', ARRAY['medium','large'],         true),
  ('Cold Brew',     'cold_drink', 'drink', true,  'Slow-steeped cold coffee',   'none',  ARRAY['medium','large'],         true),
  ('Mocha Latte',   'hot_drink',  'drink', false, 'Espresso with chocolate and steamed milk', 'whole', ARRAY['small','medium','large'], true),
  ('Frappe',        'cold_drink', 'drink', false, 'Blended iced coffee',        'whole', ARRAY['medium','large'],         true);

INSERT INTO menu_items (name, category, item_type, is_vegan, description, is_gluten_free, served_warm) VALUES
  ('Ginger Biscuit', 'food', 'food_item', false, 'Classic ginger snap biscuit',  false, false),
  ('Oat Bar',        'food', 'food_item', true,  'Flapjack-style oat bar',       true,  false);

-- Catalogue entries (business decisions — all active, current prices)
INSERT INTO catalogue_entries (menu_item_id, price_pence, price_display, availability, provision_type)
SELECT id, 280, '£2.80', 'active', 'prepared' FROM menu_items WHERE name = 'Flat White'
UNION ALL
SELECT id, 280, '£2.80', 'active', 'prepared' FROM menu_items WHERE name = 'Latte'
UNION ALL
SELECT id, 250, '£2.50', 'active', 'prepared' FROM menu_items WHERE name = 'Americano'
UNION ALL
SELECT id, 280, '£2.80', 'active', 'prepared' FROM menu_items WHERE name = 'Cappuccino'
UNION ALL
SELECT id, 200, '£2.00', 'active', 'prepared' FROM menu_items WHERE name = 'Espresso'
UNION ALL
SELECT id, 320, '£3.20', 'active', 'prepared' FROM menu_items WHERE name = 'Iced Latte'
UNION ALL
SELECT id, 300, '£3.00', 'active', 'prepared' FROM menu_items WHERE name = 'Cold Brew'
UNION ALL
SELECT id, 380, '£3.80', 'active', 'prepared' FROM menu_items WHERE name = 'Mocha Latte'
UNION ALL
SELECT id, 420, '£4.20', 'active', 'prepared' FROM menu_items WHERE name = 'Frappe'
UNION ALL
SELECT id, 180, '£1.80', 'active', 'bought_in' FROM menu_items WHERE name = 'Ginger Biscuit'
UNION ALL
SELECT id, 220, '£2.20', 'active', 'bought_in' FROM menu_items WHERE name = 'Oat Bar';

-- Inventory records (bought-in items only — prepared items
-- don't have finished-product inventory)
INSERT INTO inventory_records (catalogue_entry_id, quantity_on_hand, stock_status, low_stock_threshold)
SELECT ce.id, 24, 'in_stock', 5
FROM catalogue_entries ce JOIN menu_items mi ON ce.menu_item_id = mi.id
WHERE mi.name = 'Ginger Biscuit'
UNION ALL
SELECT ce.id, 18, 'in_stock', 5
FROM catalogue_entries ce JOIN menu_items mi ON ce.menu_item_id = mi.id
WHERE mi.name = 'Oat Bar';
```

### 1.3 Add `sql/` to `.gitignore` exclusion

Check that `exercises/coffeeshop-demonstrator/.gitignore` does not exclude `.sql` files or the `sql/` directory. If it does, add an exception. (The existing `.gitignore` is SvelteKit's default — unlikely to exclude SQL.)

### 1.4 Start the database and verify

**Start command:**

```bash
cd exercises/coffeeshop-demonstrator
docker compose -f docker-compose.ehrbase.yml up -d coffeeshop-db
```

Note: starting just the `coffeeshop-db` service (not the full stack) for faster iteration. EHRbase services are independent and unaffected.

**Verify container is running and healthy:**

```bash
docker compose -f docker-compose.ehrbase.yml ps coffeeshop-db
```

**Verify database was created with schema and seed data:**

```bash
docker exec -it $(docker compose -f docker-compose.ehrbase.yml ps -q coffeeshop-db) \
  psql -U coffeeshop -d coffeeshop_business -c "\dt"
```

Expected output: four tables (`menu_items`, `external_references`, `catalogue_entries`, `inventory_records`).

**Verify seed data:**

```bash
docker exec -it $(docker compose -f docker-compose.ehrbase.yml ps -q coffeeshop-db) \
  psql -U coffeeshop -d coffeeshop_business -c "SELECT mi.name, ce.price_display, ce.provision_type FROM catalogue_entries ce JOIN menu_items mi ON ce.menu_item_id = mi.id ORDER BY mi.category, mi.name;"
```

Expected: 11 rows, all active, prices matching the spec.

**Verify inventory records:**

```bash
docker exec -it $(docker compose -f docker-compose.ehrbase.yml ps -q coffeeshop-db) \
  psql -U coffeeshop -d coffeeshop_business -c "SELECT mi.name, ir.quantity_on_hand, ir.stock_status FROM inventory_records ir JOIN catalogue_entries ce ON ir.catalogue_entry_id = ce.id JOIN menu_items mi ON ce.menu_item_id = mi.id;"
```

Expected: 2 rows — Ginger Biscuit (24, in_stock), Oat Bar (18, in_stock).

**Verify connectivity from the host (for TypeScript client in Stage 2):**

```bash
psql -h localhost -p 5434 -U coffeeshop -d coffeeshop_business -c "SELECT count(*) FROM menu_items;"
```

Expected: `11`.

### 1.5 Commit

```
git add exercises/coffeeshop-demonstrator/docker-compose.ehrbase.yml
git add exercises/coffeeshop-demonstrator/sql/
git commit -m "CSW: PostgreSQL business database with schema and seed data

- Add coffeeshop-db service to Docker Compose (PostgreSQL 16, port 5434)
- Separate container from EHRbase CDR — clean architectural boundary
- Schema: menu_items, external_references, catalogue_entries, inventory_records
- Seed data: 11 menu items (7 existing + 4 new), 11 catalogue entries, 2 inventory records
- SQL init files run automatically via /docker-entrypoint-initdb.d mount
- Tables derived from SysML domain model (Phase 1)

Three persistence layers now operational:
  CDR (EHRbase, port 5433) — clinical records
  Business DB (PostgreSQL, port 5434) — catalogue, inventory
  Process Engine (Temporal, port 7233) — workflow state"
```

---

## Stage 2: TypeScript Database Client

### 2.1 Add `pg` dependency to `@coffeeshop/shared`

```bash
cd exercises/coffeeshop-demonstrator
pnpm --filter @coffeeshop/shared add pg
pnpm --filter @coffeeshop/shared add -D @types/pg
```

**Why `@coffeeshop/shared`?** The database client is needed by both:
- `@coffeeshop/web` (SvelteKit API routes query the catalogue)
- `@coffeeshop/temporal` (workflow activities may need catalogue lookups in future phases)

The shared package is the correct location, paralleling `ehrbase-client.ts`.

### 2.2 Create `postgres-client.ts`

Create `packages/shared/src/postgres-client.ts`.

The client follows the same architectural pattern as `ehrbase-client.ts`:
- Configuration interface with sensible defaults
- Factory function returning a typed client interface
- Singleton management is the consumer's responsibility (via `$lib/server/postgres.ts` in SvelteKit)
- Clean error handling with a domain-specific error type

```typescript
/**
 * PostgreSQL Business Database Client — CSW Extension Phase 2
 *
 * Thin TypeScript wrapper around the pg Pool for the coffee shop
 * business database. Provides typed query helpers for catalogue
 * and inventory operations.
 *
 * This module parallels ehrbase-client.ts in structure:
 *   - Configuration interface with defaults
 *   - Factory function returning typed client
 *   - Clean separation of connection management from queries
 *
 * Design decisions:
 *   - Pool (not Client) — connection pooling for concurrent requests
 *   - Parameterised queries throughout — SQL injection prevention
 *   - Snake_case ↔ camelCase mapping at query level, not ORM
 *   - Explicit typed result interfaces — no `any`
 */

import pg from 'pg';

const { Pool } = pg;

// ── Configuration ──

export interface PostgresConfig {
  readonly host: string;
  readonly port: number;
  readonly database: string;
  readonly user: string;
  readonly password: string;
  /** Maximum number of connections in the pool */
  readonly maxConnections?: number;
}

/**
 * Default configuration matching docker-compose.ehrbase.yml coffeeshop-db service.
 */
export const DEFAULT_POSTGRES_CONFIG: PostgresConfig = {
  host: 'localhost',
  port: 5434,
  database: 'coffeeshop_business',
  user: 'coffeeshop',
  password: 'coffeeshop_dev',
  maxConnections: 10,
};

// ── Result types ──
// These correspond to the SysML domain model types (Phase 1)
// and the PostgreSQL tables (Stage 1 of this phase).

export interface MenuItemRow {
  readonly id: string;
  readonly name: string;
  readonly category: string;
  readonly itemType: string;
  readonly description: string | null;
  readonly isVegan: boolean;
  // Drink-specific
  readonly defaultMilk: string | null;
  readonly availableSizes: string[] | null;
  readonly isCaffeinated: boolean | null;
  // Food-specific
  readonly isGlutenFree: boolean | null;
  readonly servedWarm: boolean | null;
  readonly createdAt: Date;
  readonly updatedAt: Date;
}

export interface CatalogueEntryRow {
  readonly id: string;
  readonly menuItemId: string;
  readonly pricePence: number;
  readonly priceDisplay: string;
  readonly availability: string;
  readonly provisionType: string;
  readonly effectiveDate: Date;
  readonly statusNotes: string | null;
  readonly createdAt: Date;
  readonly updatedAt: Date;
}

export interface InventoryRecordRow {
  readonly id: string;
  readonly catalogueEntryId: string;
  readonly quantityOnHand: number;
  readonly stockStatus: string;
  readonly lowStockThreshold: number;
  readonly lastRestocked: Date | null;
  readonly quantityNotes: string | null;
  readonly updatedAt: Date;
}

/** Joined view: catalogue entry + menu item details */
export interface CatalogueItemView {
  // From catalogue_entries
  readonly catalogueEntryId: string;
  readonly pricePence: number;
  readonly priceDisplay: string;
  readonly availability: string;
  readonly provisionType: string;
  readonly effectiveDate: Date;
  readonly statusNotes: string | null;
  // From menu_items
  readonly menuItemId: string;
  readonly name: string;
  readonly category: string;
  readonly itemType: string;
  readonly description: string | null;
  readonly isVegan: boolean;
  readonly defaultMilk: string | null;
  readonly availableSizes: string[] | null;
  readonly isCaffeinated: boolean | null;
  readonly isGlutenFree: boolean | null;
  readonly servedWarm: boolean | null;
}

/** Joined view: inventory record + catalogue entry + menu item */
export interface InventoryItemView {
  readonly inventoryRecordId: string;
  readonly quantityOnHand: number;
  readonly stockStatus: string;
  readonly lowStockThreshold: number;
  readonly lastRestocked: Date | null;
  readonly quantityNotes: string | null;
  // From catalogue entry + menu item
  readonly catalogueEntryId: string;
  readonly name: string;
  readonly category: string;
  readonly pricePence: number;
  readonly priceDisplay: string;
  readonly provisionType: string;
  readonly availability: string;
}

// ── Error type ──

export class PostgresClientError extends Error {
  constructor(
    message: string,
    public readonly cause?: unknown,
  ) {
    super(`PostgreSQL client error: ${message}`);
    this.name = 'PostgresClientError';
  }
}

// ── Client interface ──

export interface PostgresClient {
  /**
   * Get all active catalogue entries joined with menu item details.
   * This is the primary query for the order form and catalogue view.
   */
  getActiveCatalogue(): Promise<CatalogueItemView[]>;

  /**
   * Get a single catalogue entry by ID with full menu item details.
   */
  getCatalogueEntry(catalogueEntryId: string): Promise<CatalogueItemView | null>;

  /**
   * Get all catalogue entries (including non-active) for the manager view.
   */
  getAllCatalogueEntries(): Promise<CatalogueItemView[]>;

  /**
   * Get all inventory records with catalogue and menu item details.
   */
  getInventory(): Promise<InventoryItemView[]>;

  /**
   * Get a single inventory record by ID.
   */
  getInventoryRecord(inventoryRecordId: string): Promise<InventoryItemView | null>;

  /**
   * Get low-stock items (quantity_on_hand <= low_stock_threshold).
   */
  getLowStockItems(): Promise<InventoryItemView[]>;

  /**
   * Execute a raw parameterised query. Escape hatch for queries
   * not covered by the typed methods above.
   */
  query<T extends Record<string, unknown> = Record<string, unknown>>(
    sql: string,
    params?: unknown[],
  ): Promise<T[]>;

  /**
   * Gracefully close the connection pool.
   */
  close(): Promise<void>;
}

// ── Row mapping helpers ──

function mapCatalogueItemRow(row: Record<string, unknown>): CatalogueItemView {
  return {
    catalogueEntryId: row.catalogue_entry_id as string,
    pricePence: row.price_pence as number,
    priceDisplay: row.price_display as string,
    availability: row.availability as string,
    provisionType: row.provision_type as string,
    effectiveDate: row.effective_date as Date,
    statusNotes: row.status_notes as string | null,
    menuItemId: row.menu_item_id as string,
    name: row.name as string,
    category: row.category as string,
    itemType: row.item_type as string,
    description: row.description as string | null,
    isVegan: row.is_vegan as boolean,
    defaultMilk: row.default_milk as string | null,
    availableSizes: row.available_sizes as string[] | null,
    isCaffeinated: row.is_caffeinated as boolean | null,
    isGlutenFree: row.is_gluten_free as boolean | null,
    servedWarm: row.served_warm as boolean | null,
  };
}

function mapInventoryItemRow(row: Record<string, unknown>): InventoryItemView {
  return {
    inventoryRecordId: row.inventory_record_id as string,
    quantityOnHand: row.quantity_on_hand as number,
    stockStatus: row.stock_status as string,
    lowStockThreshold: row.low_stock_threshold as number,
    lastRestocked: row.last_restocked as Date | null,
    quantityNotes: row.quantity_notes as string | null,
    catalogueEntryId: row.catalogue_entry_id as string,
    name: row.name as string,
    category: row.category as string,
    pricePence: row.price_pence as number,
    priceDisplay: row.price_display as string,
    provisionType: row.provision_type as string,
    availability: row.availability as string,
  };
}

// ── SQL queries ──

const CATALOGUE_BASE_QUERY = `
  SELECT
    ce.id AS catalogue_entry_id,
    ce.price_pence,
    ce.price_display,
    ce.availability,
    ce.provision_type,
    ce.effective_date,
    ce.status_notes,
    mi.id AS menu_item_id,
    mi.name,
    mi.category,
    mi.item_type,
    mi.description,
    mi.is_vegan,
    mi.default_milk,
    mi.available_sizes,
    mi.is_caffeinated,
    mi.is_gluten_free,
    mi.served_warm
  FROM catalogue_entries ce
  JOIN menu_items mi ON ce.menu_item_id = mi.id
`;

const INVENTORY_BASE_QUERY = `
  SELECT
    ir.id AS inventory_record_id,
    ir.quantity_on_hand,
    ir.stock_status,
    ir.low_stock_threshold,
    ir.last_restocked,
    ir.quantity_notes,
    ce.id AS catalogue_entry_id,
    mi.name,
    mi.category,
    ce.price_pence,
    ce.price_display,
    ce.provision_type,
    ce.availability
  FROM inventory_records ir
  JOIN catalogue_entries ce ON ir.catalogue_entry_id = ce.id
  JOIN menu_items mi ON ce.menu_item_id = mi.id
`;

// ── Client factory ──

export function createPostgresClient(
  config: PostgresConfig = DEFAULT_POSTGRES_CONFIG,
): PostgresClient {
  const pool = new Pool({
    host: config.host,
    port: config.port,
    database: config.database,
    user: config.user,
    password: config.password,
    max: config.maxConnections ?? 10,
  });

  // Log connection errors but don't crash — let individual queries fail
  pool.on('error', (err) => {
    console.error('[PostgresClient] Unexpected pool error:', err.message);
  });

  const client: PostgresClient = {
    async getActiveCatalogue(): Promise<CatalogueItemView[]> {
      try {
        const result = await pool.query(
          `${CATALOGUE_BASE_QUERY} WHERE ce.availability = 'active' ORDER BY mi.category, mi.name`,
        );
        return result.rows.map(mapCatalogueItemRow);
      } catch (err) {
        throw new PostgresClientError('Failed to query active catalogue', err);
      }
    },

    async getCatalogueEntry(catalogueEntryId: string): Promise<CatalogueItemView | null> {
      try {
        const result = await pool.query(
          `${CATALOGUE_BASE_QUERY} WHERE ce.id = $1`,
          [catalogueEntryId],
        );
        return result.rows.length > 0 ? mapCatalogueItemRow(result.rows[0]) : null;
      } catch (err) {
        throw new PostgresClientError(`Failed to query catalogue entry ${catalogueEntryId}`, err);
      }
    },

    async getAllCatalogueEntries(): Promise<CatalogueItemView[]> {
      try {
        const result = await pool.query(
          `${CATALOGUE_BASE_QUERY} ORDER BY mi.category, mi.name`,
        );
        return result.rows.map(mapCatalogueItemRow);
      } catch (err) {
        throw new PostgresClientError('Failed to query all catalogue entries', err);
      }
    },

    async getInventory(): Promise<InventoryItemView[]> {
      try {
        const result = await pool.query(
          `${INVENTORY_BASE_QUERY} ORDER BY mi.name`,
        );
        return result.rows.map(mapInventoryItemRow);
      } catch (err) {
        throw new PostgresClientError('Failed to query inventory', err);
      }
    },

    async getInventoryRecord(inventoryRecordId: string): Promise<InventoryItemView | null> {
      try {
        const result = await pool.query(
          `${INVENTORY_BASE_QUERY} WHERE ir.id = $1`,
          [inventoryRecordId],
        );
        return result.rows.length > 0 ? mapInventoryItemRow(result.rows[0]) : null;
      } catch (err) {
        throw new PostgresClientError(`Failed to query inventory record ${inventoryRecordId}`, err);
      }
    },

    async getLowStockItems(): Promise<InventoryItemView[]> {
      try {
        const result = await pool.query(
          `${INVENTORY_BASE_QUERY} WHERE ir.quantity_on_hand <= ir.low_stock_threshold ORDER BY ir.quantity_on_hand ASC`,
        );
        return result.rows.map(mapInventoryItemRow);
      } catch (err) {
        throw new PostgresClientError('Failed to query low-stock items', err);
      }
    },

    async query<T extends Record<string, unknown>>(
      sql: string,
      params?: unknown[],
    ): Promise<T[]> {
      try {
        const result = await pool.query(sql, params);
        return result.rows as T[];
      } catch (err) {
        throw new PostgresClientError('Query failed', err);
      }
    },

    async close(): Promise<void> {
      await pool.end();
    },
  };

  return client;
}
```

### 2.3 Export from `@coffeeshop/shared`

Add to `packages/shared/src/index.ts`:

```typescript
// PostgreSQL business database client — Phase 2 CSW Extension
export {
  createPostgresClient,
  DEFAULT_POSTGRES_CONFIG,
  PostgresClientError,
  type PostgresClient,
  type PostgresConfig,
  type MenuItemRow,
  type CatalogueEntryRow,
  type InventoryRecordRow,
  type CatalogueItemView,
  type InventoryItemView,
} from './postgres-client.js';
```

### 2.4 Build and verify compilation

```bash
cd exercises/coffeeshop-demonstrator
pnpm --filter @coffeeshop/shared build
```

Expected: clean compilation with no errors. The `pg` import resolves via `@types/pg`. The new types don't conflict with existing exports.

**Possible issue:** The `pg` package uses CommonJS by default. If TypeScript module resolution has issues with `import pg from 'pg'`, the fix is:

```typescript
import pg from 'pg';
const { Pool } = pg;
```

This is the standard pattern for using `pg` in ESM TypeScript projects and is what the code above already uses.

### 2.5 Commit

```
git add exercises/coffeeshop-demonstrator/packages/shared/src/postgres-client.ts
git add exercises/coffeeshop-demonstrator/packages/shared/src/index.ts
git add exercises/coffeeshop-demonstrator/packages/shared/package.json
git add exercises/coffeeshop-demonstrator/pnpm-lock.yaml
git commit -m "CSW: PostgreSQL client in @coffeeshop/shared

- Add postgres-client.ts paralleling ehrbase-client.ts pattern
- Typed interfaces: MenuItemRow, CatalogueEntryRow, InventoryRecordRow
- Joined views: CatalogueItemView, InventoryItemView
- Query methods: getActiveCatalogue, getInventory, getLowStockItems
- Pool-based connection management with parameterised queries
- Snake_case → camelCase mapping at query boundary
- Export from @coffeeshop/shared index"
```

---

## Stage 3: SvelteKit Server Singleton and Verification

### 3.1 Create `$lib/server/postgres.ts`

Create `packages/web/src/lib/server/postgres.ts`, paralleling the existing `$lib/server/ehrbase.ts`:

```typescript
/**
 * PostgreSQL Business Database Client — server-side only
 *
 * Provides a singleton PostgreSQL client for use by SvelteKit API routes.
 * The $lib/server/ directory ensures SvelteKit never bundles this into
 * client-side code.
 *
 * CSW Extension Phase 2: Catalogue and inventory queries.
 */

import { createPostgresClient, type PostgresClient } from '@coffeeshop/shared';

let client: PostgresClient | null = null;

export function getPostgresClient(): PostgresClient {
  if (!client) {
    client = createPostgresClient();
  }
  return client;
}
```

### 3.2 Add `pg` dependency to `@coffeeshop/web`

The SvelteKit app needs `pg` at runtime because `@coffeeshop/shared` imports it and the shared package is consumed as source (workspace link), not pre-bundled.

```bash
cd exercises/coffeeshop-demonstrator
pnpm --filter @coffeeshop/web add pg
pnpm --filter @coffeeshop/web add -D @types/pg
```

**Alternative approach:** If `@coffeeshop/shared` already declares `pg` as a dependency and the pnpm workspace hoists it, the web package may not need its own declaration. Test without adding it first — if `vite dev` resolves `pg` through the workspace, skip this step. If not, add it.

### 3.3 Create verification API routes

Create `packages/web/src/routes/api/catalogue/+server.ts` as a minimal verification endpoint. This endpoint will be fleshed out properly in Phase 3, but a basic version validates the full stack: Docker → PostgreSQL → TypeScript client → SvelteKit API.

```typescript
/**
 * GET /api/catalogue — Active catalogue entries
 *
 * Phase 2: Verification endpoint. Returns all active catalogue
 * entries joined with menu item details.
 *
 * Phase 3 will add POST, PUT, and richer query parameters.
 */

import { json } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { getPostgresClient } from '$lib/server/postgres';

export const GET: RequestHandler = async () => {
  const db = getPostgresClient();
  const catalogue = await db.getActiveCatalogue();
  return json(catalogue);
};
```

And `packages/web/src/routes/api/inventory/+server.ts`:

```typescript
/**
 * GET /api/inventory — Inventory records
 *
 * Phase 2: Verification endpoint. Returns all inventory records
 * joined with catalogue and menu item details.
 */

import { json } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { getPostgresClient } from '$lib/server/postgres';

export const GET: RequestHandler = async () => {
  const db = getPostgresClient();
  const inventory = await db.getInventory();
  return json(inventory);
};
```

### 3.4 Verify the full stack

**Prerequisites:** Both Docker services running:

```bash
cd exercises/coffeeshop-demonstrator
docker compose -f docker-compose.ehrbase.yml up -d
```

**Start the dev server:**

```bash
pnpm dev:web
```

**Test catalogue endpoint:**

```bash
curl -s http://localhost:5173/api/catalogue | jq '.[0]'
```

Expected: JSON object with `catalogueEntryId`, `name`, `pricePence`, `priceDisplay`, `availability`, `provisionType`, and all menu item fields. 11 items total.

**Test inventory endpoint:**

```bash
curl -s http://localhost:5173/api/inventory | jq '.'
```

Expected: 2 items — Ginger Biscuit and Oat Bar with stock levels.

**Verification checklist:**
- [ ] `/api/catalogue` returns 11 items, all with `availability: "active"`
- [ ] Catalogue items include joined menu item fields (name, category, isVegan, etc.)
- [ ] Drink items have `availableSizes` as arrays, not strings
- [ ] Food items have `isGlutenFree`, `servedWarm` populated
- [ ] `/api/inventory` returns 2 items (bought-in only)
- [ ] Inventory items include stock status and threshold
- [ ] No TypeScript compilation errors in dev mode
- [ ] Existing API routes (`/api/orders`, `/api/entity/*`) still work

### 3.5 Commit

```
git add exercises/coffeeshop-demonstrator/packages/web/src/lib/server/postgres.ts
git add exercises/coffeeshop-demonstrator/packages/web/src/routes/api/catalogue/
git add exercises/coffeeshop-demonstrator/packages/web/src/routes/api/inventory/
git add exercises/coffeeshop-demonstrator/packages/web/package.json
git add exercises/coffeeshop-demonstrator/pnpm-lock.yaml
git commit -m "CSW: SvelteKit PostgreSQL integration with verification endpoints

- Add $lib/server/postgres.ts singleton (parallels ehrbase.ts)
- GET /api/catalogue — active catalogue entries with menu item details
- GET /api/inventory — inventory records with stock status
- Full stack verified: Docker → PostgreSQL → pg client → SvelteKit API

Second persistence layer fully integrated alongside CDR."
```

---

## Design Notes

### Naming Convention: snake_case ↔ camelCase Boundary

PostgreSQL uses `snake_case` (convention). TypeScript uses `camelCase` (convention). The boundary mapping happens in the `postgres-client.ts` row mapping functions. This is a deliberate choice:

- **No ORM.** The mapping is explicit, visible, and type-safe. There's no magic layer hiding the translation.
- **SQL stays SQL.** Column aliases in queries use `snake_case` to match the database. The TypeScript interfaces use `camelCase`. The mapping functions bridge the two.
- **Parallel to EHRbase client.** The `ehrbase-client.ts` doesn't use an ORM either — it maps openEHR JSON paths to TypeScript types manually.

### Connection Pool Management

The `pg.Pool` is the standard approach for Node.js PostgreSQL applications:

- Connections are lazily acquired from the pool per query
- Idle connections are returned to the pool automatically
- Pool size (default: 10) is more than sufficient for the coffee shop
- The SvelteKit singleton (`$lib/server/postgres.ts`) ensures one pool per server process
- `pool.end()` is available via `client.close()` for graceful shutdown (e.g. in tests)

### Why Not Drizzle / Prisma / Kysely?

The coffee shop demonstrator deliberately minimises abstraction layers to keep the architecture transparent. Each persistence layer has a thin, hand-written client:

| Layer | Client | Abstraction level |
|---|---|---|
| CDR | `ehrbase-client.ts` | HTTP fetch + JSON mapping |
| Business DB | `postgres-client.ts` | `pg` Pool + row mapping |
| Process Engine | Temporal SDK | SDK-level (no custom wrapper) |

An ORM would add a dependency, a configuration surface, a migration system, and a conceptual layer that obscures the model-to-table mapping. For the coffee shop's four tables, parameterised SQL is clearer and more instructive. If GSL grows to many tables, a query builder like Kysely (which preserves SQL visibility) would be the first step up.

---

## Impact on Subsequent Phases

### Phase 3: Catalogue & Inventory API Routes

Phase 2 creates the foundation that Phase 3 builds on:

- The `getActiveCatalogue()` and `getInventory()` methods are already available
- Phase 3 adds write operations: `POST /api/catalogue` (add item), `PUT /api/catalogue/[id]` (update), `PUT /api/inventory/[id]` (adjust stock)
- The verification API routes created in Stage 3 will be extended, not replaced
- The `postgres-client.ts` will gain mutation methods (insert, update) in Phase 3

### Phase 5: Counter Page

The `getActiveCatalogue()` method returns exactly the data the counter page needs to dynamically populate the order form. The `CatalogueItemView` type already includes category, sizes, dietary flags, and prices.

### Phase 6: Manager GUI

The `getAllCatalogueEntries()` method (including non-active items) and `getInventory()` / `getLowStockItems()` methods support the manager view directly.

---

## Potential Issues and Mitigations

| Issue | Likelihood | Mitigation |
|---|---|---|
| `pg` ESM import issues | Medium | Use `import pg from 'pg'; const { Pool } = pg;` pattern (already in the code) |
| Docker entrypoint SQL not running on re-creation | Low | SQL only runs on first volume creation. If tables are missing after restart, `docker compose down -v && docker compose up -d` resets. |
| pnpm workspace `pg` resolution in web package | Medium | If SvelteKit can't resolve `pg` through workspace hoisting, add it directly to `@coffeeshop/web` |
| Port 5434 conflict with local service | Low | Check with `lsof -i :5434`. Change port in compose and config if needed. |
| TypeScript strict mode issues with `pg` types | Low | `@types/pg` is well-maintained. The `Record<string, unknown>` row type is compatible. |

---

## Checklist

### Stage 1: Docker Compose and Database
- [ ] Add `coffeeshop-db` service to `docker-compose.ehrbase.yml`
- [ ] Add `coffeeshop-pg-data` volume
- [ ] Create `sql/init/001-schema.sql`
- [ ] Create `sql/init/002-seed.sql`
- [ ] Start `coffeeshop-db` container
- [ ] Verify tables exist (`\dt`)
- [ ] Verify seed data (11 menu items, 11 catalogue entries, 2 inventory records)
- [ ] Verify host connectivity on port 5434
- [ ] Commit

### Stage 2: TypeScript Database Client
- [ ] Add `pg` + `@types/pg` to `@coffeeshop/shared`
- [ ] Create `postgres-client.ts` with typed interfaces and query methods
- [ ] Export from `index.ts`
- [ ] Build `@coffeeshop/shared` — verify clean compilation
- [ ] Commit

### Stage 3: SvelteKit Integration and Verification
- [ ] Create `$lib/server/postgres.ts` singleton
- [ ] Resolve `pg` dependency in `@coffeeshop/web` (workspace hoisting or direct add)
- [ ] Create `GET /api/catalogue` verification endpoint
- [ ] Create `GET /api/inventory` verification endpoint
- [ ] Start dev server, test both endpoints
- [ ] Verify existing API routes still work
- [ ] Commit

### Post-phase
- [ ] No syntax reference update expected (no SysML changes)
- [ ] Update `gsl-plan-next-steps-and-deferred-items.md` if new deferred items arise
- [ ] Note any `pg` or Docker findings for the project journal

---

*Plan prepared 12 March 2026. Phase 2 of the CSW Extension workstream.*
</file_text>