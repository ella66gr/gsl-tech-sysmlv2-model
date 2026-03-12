-- =============================================================================
-- Coffee Shop Business Database — Schema
-- Derived from SysML domain model (CoffeeShop package, Phase 1)
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
