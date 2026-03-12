/**
 * PostgreSQL Business Database Client — CSW Extension Phase 2 + Phase 3
 *
 * Thin TypeScript wrapper around the pg Pool for the coffee shop
 * business database. Provides typed query helpers for catalogue
 * and inventory operations, plus mutation methods for CRUD.
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
 *   - Transaction support for multi-table mutations (Phase 3)
 */

import pg from 'pg';

const { Pool } = pg;
type PoolClient = pg.PoolClient;

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
// and the PostgreSQL tables (Stage 1 of Phase 2).

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

// ── Input types (Phase 3) ──

/** Input for creating a new menu item */
export interface CreateMenuItemInput {
  readonly name: string;
  readonly category: 'hot_drink' | 'cold_drink' | 'food';
  readonly itemType: 'drink' | 'food_item';
  readonly description?: string;
  readonly isVegan: boolean;
  // Drink-specific
  readonly defaultMilk?: string;
  readonly availableSizes?: string[];
  readonly isCaffeinated?: boolean;
  // Food-specific
  readonly isGlutenFree?: boolean;
  readonly servedWarm?: boolean;
}

/** Combined input: create menu item + catalogue entry in one transaction */
export interface CreateCatalogueItemInput {
  readonly menuItem: CreateMenuItemInput;
  readonly pricePence: number;
  readonly priceDisplay: string;
  readonly provisionType: 'prepared' | 'bought_in' | 'hybrid';
  readonly statusNotes?: string;
  /** Optional initial inventory for bought-in items */
  readonly initialStock?: {
    readonly quantityOnHand: number;
    readonly lowStockThreshold?: number;  // defaults to 5
  };
}

/** Input for updating a catalogue entry */
export interface UpdateCatalogueEntryInput {
  readonly pricePence?: number;
  readonly priceDisplay?: string;
  readonly availability?: string;
  readonly statusNotes?: string;
}

/** Input for updating an inventory record */
export interface UpdateInventoryInput {
  readonly quantityOnHand?: number;
  readonly stockStatus?: string;
  readonly lowStockThreshold?: number;
  readonly quantityNotes?: string;
}

/** Result of looking up a catalogue entry by item name */
export interface CatalogueLookupResult {
  readonly catalogueEntryId: string;
  readonly menuItemId: string;
  readonly name: string;
  readonly pricePence: number;
  readonly priceDisplay: string;
  readonly availability: string;
  readonly provisionType: string;
  readonly itemType: string;
  readonly category: string;
  readonly availableSizes: string[] | null;
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
  // ── Queries (Phase 2) ──

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

  // ── Mutations (Phase 3) ──

  /**
   * Create a new menu item + catalogue entry in a single transaction.
   * Optionally creates an inventory record for bought-in items.
   * Returns the created CatalogueItemView.
   */
  createCatalogueItem(input: CreateCatalogueItemInput): Promise<CatalogueItemView>;

  /**
   * Update a catalogue entry (price, availability, status notes).
   * Updates the `updated_at` timestamp.
   */
  updateCatalogueEntry(
    catalogueEntryId: string,
    input: UpdateCatalogueEntryInput,
  ): Promise<CatalogueItemView | null>;

  /**
   * Update an inventory record (stock level, status, threshold).
   * Auto-calculates stock_status when quantity changes.
   * Updates the `updated_at` timestamp.
   */
  updateInventory(
    inventoryRecordId: string,
    input: UpdateInventoryInput,
  ): Promise<InventoryItemView | null>;

  /**
   * Look up an active catalogue entry by menu item name.
   * Case-insensitive. Used by the order validation flow to confirm
   * an item is orderable and to retrieve its price and valid sizes.
   */
  lookupActiveItemByName(itemName: string): Promise<CatalogueLookupResult | null>;

  /**
   * Decrement inventory for a bought-in item when ordered.
   * Atomic UPDATE with GREATEST(0, ...) to prevent negative stock.
   * Returns the updated inventory record, or null if no inventory
   * record exists (i.e. prepared items — no-op).
   */
  decrementInventory(catalogueEntryId: string, quantity: number): Promise<InventoryItemView | null>;

  // ── Utility ──

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

  // ── Transaction helper (Phase 3) ──

  async function withTransaction<T>(
    fn: (txClient: PoolClient) => Promise<T>,
  ): Promise<T> {
    const txClient = await pool.connect();
    try {
      await txClient.query('BEGIN');
      const result = await fn(txClient);
      await txClient.query('COMMIT');
      return result;
    } catch (err) {
      await txClient.query('ROLLBACK');
      throw err;
    } finally {
      txClient.release();
    }
  }

  const client: PostgresClient = {

    // ── Queries (Phase 2) ──

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

    // ── Mutations (Phase 3) ──

    async createCatalogueItem(input: CreateCatalogueItemInput): Promise<CatalogueItemView> {
      try {
        return await withTransaction(async (txClient) => {
          // 1. Insert menu item
          const miResult = await txClient.query(
            `INSERT INTO menu_items
               (name, category, item_type, description, is_vegan,
                default_milk, available_sizes, is_caffeinated,
                is_gluten_free, served_warm)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
             RETURNING id`,
            [
              input.menuItem.name,
              input.menuItem.category,
              input.menuItem.itemType,
              input.menuItem.description ?? null,
              input.menuItem.isVegan,
              input.menuItem.defaultMilk ?? null,
              input.menuItem.availableSizes ?? null,
              input.menuItem.isCaffeinated ?? null,
              input.menuItem.isGlutenFree ?? null,
              input.menuItem.servedWarm ?? null,
            ],
          );
          const menuItemId = miResult.rows[0].id;

          // 2. Insert catalogue entry
          const ceResult = await txClient.query(
            `INSERT INTO catalogue_entries
               (menu_item_id, price_pence, price_display, availability, provision_type, status_notes)
             VALUES ($1, $2, $3, $4, $5, $6)
             RETURNING id`,
            [
              menuItemId,
              input.pricePence,
              input.priceDisplay,
              'active',
              input.provisionType,
              input.statusNotes ?? null,
            ],
          );
          const catalogueEntryId = ceResult.rows[0].id;

          // 3. Optionally insert inventory record for bought-in items
          if (input.initialStock && input.provisionType === 'bought_in') {
            const threshold = input.initialStock.lowStockThreshold ?? 5;
            const status = input.initialStock.quantityOnHand > threshold
              ? 'in_stock'
              : input.initialStock.quantityOnHand === 0
                ? 'out_of_stock'
                : 'low';
            await txClient.query(
              `INSERT INTO inventory_records
                 (catalogue_entry_id, quantity_on_hand, stock_status, low_stock_threshold)
               VALUES ($1, $2, $3, $4)`,
              [
                catalogueEntryId,
                input.initialStock.quantityOnHand,
                status,
                threshold,
              ],
            );
          }

          // 4. Return the full joined view
          const viewResult = await txClient.query(
            `${CATALOGUE_BASE_QUERY} WHERE ce.id = $1`,
            [catalogueEntryId],
          );
          return mapCatalogueItemRow(viewResult.rows[0]);
        });
      } catch (err) {
        if (err instanceof PostgresClientError) throw err;
        throw new PostgresClientError('Failed to create catalogue item', err);
      }
    },

    async updateCatalogueEntry(
      catalogueEntryId: string,
      input: UpdateCatalogueEntryInput,
    ): Promise<CatalogueItemView | null> {
      try {
        const setClauses: string[] = [];
        const values: unknown[] = [];
        let paramIndex = 1;

        if (input.pricePence !== undefined) {
          setClauses.push(`price_pence = $${paramIndex++}`);
          values.push(input.pricePence);
        }
        if (input.priceDisplay !== undefined) {
          setClauses.push(`price_display = $${paramIndex++}`);
          values.push(input.priceDisplay);
        }
        if (input.availability !== undefined) {
          setClauses.push(`availability = $${paramIndex++}`);
          values.push(input.availability);
        }
        if (input.statusNotes !== undefined) {
          setClauses.push(`status_notes = $${paramIndex++}`);
          values.push(input.statusNotes);
        }

        if (setClauses.length === 0) {
          return client.getCatalogueEntry(catalogueEntryId);
        }

        setClauses.push(`updated_at = now()`);
        values.push(catalogueEntryId);

        const result = await pool.query(
          `UPDATE catalogue_entries SET ${setClauses.join(', ')} WHERE id = $${paramIndex} RETURNING id`,
          values,
        );

        if (result.rows.length === 0) return null;

        return client.getCatalogueEntry(catalogueEntryId);
      } catch (err) {
        if (err instanceof PostgresClientError) throw err;
        throw new PostgresClientError(`Failed to update catalogue entry ${catalogueEntryId}`, err);
      }
    },

    async updateInventory(
      inventoryRecordId: string,
      input: UpdateInventoryInput,
    ): Promise<InventoryItemView | null> {
      try {
        // Build the update dynamically, but always use a single statement
        // that auto-calculates stock_status when quantity changes
        const setClauses: string[] = [];
        const values: unknown[] = [];
        let paramIndex = 1;

        const newQuantity = input.quantityOnHand;
        const newThreshold = input.lowStockThreshold;
        const explicitStatus = input.stockStatus;

        if (newQuantity !== undefined) {
          setClauses.push(`quantity_on_hand = $${paramIndex++}`);
          values.push(newQuantity);
        }
        if (newThreshold !== undefined) {
          setClauses.push(`low_stock_threshold = $${paramIndex++}`);
          values.push(newThreshold);
        }
        if (input.quantityNotes !== undefined) {
          setClauses.push(`quantity_notes = $${paramIndex++}`);
          values.push(input.quantityNotes);
        }

        // Stock status: use explicit value if provided, otherwise auto-calculate
        // when quantity was changed
        if (explicitStatus !== undefined) {
          setClauses.push(`stock_status = $${paramIndex++}`);
          values.push(explicitStatus);
        } else if (newQuantity !== undefined) {
          // Auto-calculate based on new quantity and threshold
          // Use the new threshold if provided, otherwise the existing one
          if (newThreshold !== undefined) {
            setClauses.push(`stock_status = CASE
              WHEN $${paramIndex} = 0 THEN 'out_of_stock'
              WHEN $${paramIndex} <= $${paramIndex + 1} THEN 'low'
              ELSE 'in_stock'
            END`);
            values.push(newQuantity, newThreshold);
            paramIndex += 2;
          } else {
            setClauses.push(`stock_status = CASE
              WHEN $${paramIndex} = 0 THEN 'out_of_stock'
              WHEN $${paramIndex} <= low_stock_threshold THEN 'low'
              ELSE 'in_stock'
            END`);
            values.push(newQuantity);
            paramIndex++;
          }
        }

        if (setClauses.length === 0) {
          return client.getInventoryRecord(inventoryRecordId);
        }

        // Update last_restocked if quantity increased
        if (newQuantity !== undefined) {
          setClauses.push(`last_restocked = CASE
            WHEN $${paramIndex} > quantity_on_hand THEN now()
            ELSE last_restocked
          END`);
          values.push(newQuantity);
          paramIndex++;
        }

        setClauses.push(`updated_at = now()`);
        values.push(inventoryRecordId);

        const result = await pool.query(
          `UPDATE inventory_records SET ${setClauses.join(', ')} WHERE id = $${paramIndex} RETURNING id`,
          values,
        );

        if (result.rows.length === 0) return null;

        return client.getInventoryRecord(inventoryRecordId);
      } catch (err) {
        if (err instanceof PostgresClientError) throw err;
        throw new PostgresClientError(`Failed to update inventory record ${inventoryRecordId}`, err);
      }
    },

    async lookupActiveItemByName(itemName: string): Promise<CatalogueLookupResult | null> {
      try {
        const result = await pool.query(
          `SELECT
             ce.id AS catalogue_entry_id,
             mi.id AS menu_item_id,
             mi.name,
             ce.price_pence,
             ce.price_display,
             ce.availability,
             ce.provision_type,
             mi.item_type,
             mi.category,
             mi.available_sizes
           FROM catalogue_entries ce
           JOIN menu_items mi ON ce.menu_item_id = mi.id
           WHERE LOWER(mi.name) = LOWER($1) AND ce.availability = 'active'`,
          [itemName],
        );
        if (result.rows.length === 0) return null;
        const row = result.rows[0];
        return {
          catalogueEntryId: row.catalogue_entry_id as string,
          menuItemId: row.menu_item_id as string,
          name: row.name as string,
          pricePence: row.price_pence as number,
          priceDisplay: row.price_display as string,
          availability: row.availability as string,
          provisionType: row.provision_type as string,
          itemType: row.item_type as string,
          category: row.category as string,
          availableSizes: row.available_sizes as string[] | null,
        };
      } catch (err) {
        throw new PostgresClientError(`Failed to look up item: ${itemName}`, err);
      }
    },

    async decrementInventory(
      catalogueEntryId: string,
      quantity: number,
    ): Promise<InventoryItemView | null> {
      try {
        const result = await pool.query(
          `UPDATE inventory_records
           SET quantity_on_hand = GREATEST(0, quantity_on_hand - $1),
               stock_status = CASE
                 WHEN GREATEST(0, quantity_on_hand - $1) = 0 THEN 'out_of_stock'
                 WHEN GREATEST(0, quantity_on_hand - $1) <= low_stock_threshold THEN 'low'
                 ELSE 'in_stock'
               END,
               updated_at = now()
           WHERE catalogue_entry_id = $2
           RETURNING id`,
          [quantity, catalogueEntryId],
        );
        if (result.rows.length === 0) return null; // No inventory record — prepared item
        return client.getInventoryRecord(result.rows[0].id as string);
      } catch (err) {
        throw new PostgresClientError(`Failed to decrement inventory for ${catalogueEntryId}`, err);
      }
    },

    // ── Utility ──

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
