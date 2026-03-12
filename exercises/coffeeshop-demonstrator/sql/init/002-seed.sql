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
