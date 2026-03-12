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
