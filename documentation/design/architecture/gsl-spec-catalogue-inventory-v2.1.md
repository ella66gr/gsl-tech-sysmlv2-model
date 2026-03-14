# Catalogue & Inventory — Domain Model and Implementation Specification

**Project:** GenderSense (GSL) — Coffee Shop Demonstrator
**Date:** 12 March 2026
**Version:** 2 (supersedes v1 archetype-only spec)
**Status:** Design specification — ready for SysML model update and implementation
**Context:** Extending the CSW system with catalogue and inventory management, establishing patterns for GSL. Driven by the exercise of adding four new items (mocha latte, frappe, ginger biscuit, oat bar) and building a manager GUI.

---

## 1. Architectural Decisions

### 1.1 Three-persistence-layer architecture

| Layer | Technology | Holds | Rationale |
|---|---|---|---|
| **Clinical Data Repository** | EHRbase (openEHR on PostgreSQL) | Health records: patient assessments, prescribing, monitoring, clinical evaluations, governance audit | Archetype-validated, terminology-bound, fully versioned, AQL-queryable. The *health record*. |
| **Business Database** | PostgreSQL | Everything that runs the business but isn't a health record: catalogue, inventory, pricing, financial transactions, user accounts, configuration | Standard relational CRUD, transactional integrity, conventional indexing. The *business system*. |
| **Process Engine** | Temporal | Workflow state: durable execution, signal handling, activity orchestration, event history | The *process engine*. |

### 1.2 Why not the CDR for catalogue and inventory?

openEHR is designed for long-term, vendor-neutral, semantically rich storage of health records. Its strengths (archetype validation, clinical terminology binding, immutable versioning) become overhead for business data that needs simple CRUD, transactional updates, relational joins, and high-frequency read-write. Specific limitations:

- **No native currency support.** DV_QUANTITY uses UCUM units; currency is a workaround at best.
- **Immutable composition versioning** is wrong for inventory. Stock levels need atomic decrement-on-sale, not "commit a new version of the stock level composition."
- **AQL query performance** is optimised for clinical data retrieval patterns, not for the kind of frequent, simple lookups a catalogue API needs.
- **Archetype/template overhead** (design, OPT compilation, composition building) is justified for clinical data; disproportionate for "ginger biscuits cost £1.80."

The CDR remains the right home for clinical data in GSL. The archetype designs from v1 of this spec remain valid as *patterns* — when GSL needs a formulary represented in the CDR (for clinical decision support, terminology binding, or audit), the ADMIN_ENTRY catalogue archetype pattern applies. But the business catalogue, pricing, and inventory live in PostgreSQL.

### 1.3 Model-first discipline

The PostgreSQL decision is an *implementation choice*. It does not change the domain model. The SysML model describes catalogue items, inventory records, and their relationships as domain concepts, independent of persistence mechanism. The generation pipeline produces implementation artefacts for the appropriate target:

- SysML structural model → TypeScript interfaces (existing generator)
- SysML structural model → PostgreSQL DDL (new generator, or hand-derived initially)
- SysML structural model → data access layer scaffolding (future)
- SysML structural model → openEHR archetype definitions (future, for clinical data)

The model is the single source of truth. Tables are derived from the model, not designed independently.

---

## 2. Four-Layer Conceptual Model

### 2.1 Overview

| Layer | What it represents | Mutability | CSW example | GSL example |
|---|---|---|---|---|
| **Item definition** | What something intrinsically *is* | Rarely changes | Flat White: a hot coffee drink | Estradiol Valerate: an estrogen medication |
| **Catalogue entry** | The business decision to offer it | Changes when business decides | Flat White offered at £3.20, active | Estradiol on formulary, NHS price £X |
| **Inventory record** | Operational stock state | Changes with every transaction | 2kg coffee beans in stock | 200 tablets in pharmacy |
| **External references** | Links to knowledge outside the system | System doesn't own this data | Supplier product datasheet | SPC, BNF entry, NICE TA |

### 2.2 Why four layers, not two?

The existing SysML model conflates layers 1 and 2: `MenuItem` has both intrinsic properties (`name`, `category`, `isVegan`) and business properties (`price`). This conflation prevents:

- The same item appearing in multiple catalogues at different prices (staff vs customer)
- Price changes without modifying the item definition
- An item existing as a concept without being actively offered for sale
- Tracking the history of business decisions separately from product definitions

The clean separation: `MenuItem` describes *what something is*; `CatalogueEntry` describes *how the business offers it*. Price moves from `MenuItem` to `CatalogueEntry`.

### 2.3 External references

Items in the real world connect to vast external knowledge. A medication connects to SPCs, BNF entries, NICE technology appraisals, interaction databases, contraindication lists, generic/branded equivalences, marketing authorisation status, controlled drug scheduling. A coffee bean connects to supplier datasheets, origin certifications, roast profiles.

The model doesn't contain this knowledge — it provides *attachment points*. Each item definition can reference zero or more external sources via a generic `ExternalReference` structure. The system links to external knowledge; it doesn't reproduce it.

---

## 3. SysML Domain Model Extension

### 3.1 Changes to existing types

**`MenuItem`** — remove `price` attribute. Price is a business decision, not an intrinsic property. All other attributes remain (name, category, isVegan, description).

**`Drink :> MenuItem`** — no changes. Size, milkChoice remain as intrinsic product characteristics.

**`FoodItem :> MenuItem`** — no changes. isGlutenFree, servedWarm remain as intrinsic product characteristics.

### 3.2 New type definitions

```
part def ExternalReference {
    doc /* A link to knowledge that lives outside the system.
         * The system does not own this data; it points to it.
         * Examples: SPC, BNF entry, NICE guidance, supplier
         * datasheet, origin certification. */
    attribute referenceType : String;
    attribute referenceId : String;
    attribute referenceSource : String;
    attribute referenceNotes : String;
}

enum def AvailabilityStatus {
    active;
    discontinued;
    seasonal;
    temporarilyUnavailable;
}

enum def ProvisionType {
    prepared;
    boughtIn;
    hybrid;
}

enum def StockStatus {
    inStock;
    low;
    outOfStock;
    onOrder;
}

part def CatalogueEntry {
    doc /* The business decision to offer an item for sale.
         * References an item definition (MenuItem or specialisation)
         * and adds business-context properties: price, availability,
         * provision type. A single item may appear in multiple
         * catalogues at different prices or terms. */
    ref item : MenuItem [1];
    attribute pricePence : Integer;
    attribute priceDisplay : String;
    attribute availability : AvailabilityStatus;
    attribute provisionType : ProvisionType;
    attribute effectiveDate : String;
    attribute statusNotes : String;
}

part def InventoryRecord {
    doc /* A point-in-time record of stock level for a catalogue
         * item. References a catalogue entry (not the item
         * definition directly) because inventory is scoped to
         * what the business currently offers. */
    ref catalogueEntry : CatalogueEntry [1];
    attribute quantityOnHand : Integer;
    attribute stockStatus : StockStatus;
    attribute lowStockThreshold : Integer;
    attribute lastRestocked : String;
    attribute quantityNotes : String;
}
```

### 3.3 Updated MenuItem (showing removal of price)

```
part def MenuItem {
    doc /* Something the shop sells. Describes intrinsic product
         * characteristics only. Price and availability are
         * business decisions that live on CatalogueEntry. */
    attribute name : String;
    attribute category : ItemCategory;
    attribute isVegan : Boolean;
    attribute description : String;
    attribute references : ExternalReference [0..*];
}
```

### 3.4 Relationship diagram (conceptual)

```
ExternalReference [0..*] ←── MenuItem
                                │
                           ┌────┴────┐
                         Drink    FoodItem
                                │
                    CatalogueEntry ──ref──→ MenuItem
                         │
              InventoryRecord ──ref──→ CatalogueEntry
```

---

## 4. PostgreSQL Table Design

Derived from the SysML model. The mapping strategy for this exercise is **single table with type discriminator** for the MenuItem hierarchy (simple, sufficient for the coffee shop; GSL may use table-per-type when subtypes diverge significantly).

### 4.1 Tables

```sql
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
    available_sizes TEXT[],       -- array of: 'small', 'medium', 'large'
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
    reference_type  TEXT NOT NULL,      -- e.g. 'supplier_datasheet', 'SPC', 'BNF'
    reference_id    TEXT NOT NULL,      -- the external identifier
    reference_source TEXT NOT NULL,     -- e.g. 'bnf.nice.org.uk'
    reference_notes TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Catalogue entries: business decisions about what to offer
CREATE TABLE catalogue_entries (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    menu_item_id    UUID NOT NULL REFERENCES menu_items(id),
    price_pence     INTEGER NOT NULL,
    price_display   TEXT NOT NULL,      -- e.g. '£3.20'
    availability    TEXT NOT NULL DEFAULT 'active'
                    CHECK (availability IN ('active', 'discontinued', 'seasonal', 'temporarily_unavailable')),
    provision_type  TEXT NOT NULL CHECK (provision_type IN ('prepared', 'bought_in', 'hybrid')),
    effective_date  TIMESTAMPTZ NOT NULL DEFAULT now(),
    status_notes    TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),

    -- A menu item can appear in multiple catalogues, but for CSW
    -- we expect one active entry per item. This constraint can be
    -- relaxed for GSL (e.g. NHS vs private pricing).
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

### 4.2 Design notes

**UUID primary keys** — consistent with EHRbase's use of UUIDs for EHR and composition IDs. Avoids integer sequence leakage and supports distributed ID generation if needed.

**Single-table inheritance for menu_items** — the `item_type` discriminator column (`drink` or `food_item`) determines which nullable columns apply. Drink-specific columns (default_milk, available_sizes, is_caffeinated) are NULL for food items; food-specific columns (is_gluten_free, served_warm) are NULL for drinks. This is the simplest mapping and sufficient for the coffee shop. For GSL, where `Medication` and `AssessmentInstrument` will have very different attribute sets, table-per-type (with a shared base table and type-specific extension tables joined by FK) would be more appropriate.

**available_sizes as TEXT[]** — PostgreSQL array type. Stores the set of sizes a drink is available in. Alternative: a separate `drink_sizes` join table. Array is simpler for read-heavy, rarely-updated reference data.

**Catalogue entry references menu_item** — not the other way around. A menu item can exist without being in any catalogue (it's been defined but not yet offered). A catalogue entry always references exactly one menu item.

**Inventory references catalogue_entry** — not menu_item directly. You don't stock something you're not offering. If the same item appears in two catalogues (e.g. NHS and private pricing), each catalogue entry could have its own inventory record — or they could share one. The FK to catalogue_entry supports both patterns.

**Effective date + menu_item_id uniqueness** — allows price history. A new catalogue entry with a new effective date supersedes the previous one. The application queries for the most recent active entry.

---

## 5. CSW Seed Data

### 5.1 Existing items to migrate from hardcoded list

These currently exist only as `<option>` values in the order form `<select>`. They need to be entered as menu items with catalogue entries.

| Item | Category | Type | Vegan | Caffeinated | Default milk | Sizes | Price | Provision |
|---|---|---|---|---|---|---|---|---|
| Flat White | hot_drink | drink | No | Yes | whole | S, M, L | £2.80 | prepared |
| Latte | hot_drink | drink | No | Yes | whole | S, M, L | £2.80 | prepared |
| Americano | hot_drink | drink | Yes | Yes | none | S, M, L | £2.50 | prepared |
| Cappuccino | hot_drink | drink | No | Yes | whole | S, M, L | £2.80 | prepared |
| Espresso | hot_drink | drink | Yes | Yes | none | S | £2.00 | prepared |
| Iced Latte | cold_drink | drink | No | Yes | whole | M, L | £3.20 | prepared |
| Cold Brew | cold_drink | drink | Yes | Yes | none | M, L | £3.00 | prepared |

### 5.2 New items

| Item | Category | Type | Vegan | GF | Caffeinated | Default milk | Sizes | Warm | Price | Provision |
|---|---|---|---|---|---|---|---|---|---|---|
| Mocha Latte | hot_drink | drink | No | — | Yes | whole | S, M, L | — | £3.80 | prepared |
| Frappe | cold_drink | drink | No | — | Yes | whole | M, L | — | £4.20 | prepared |
| Ginger Biscuit | food | food_item | No | No | — | — | — | No | £1.80 | bought_in |
| Oat Bar | food | food_item | Yes | Yes | — | — | — | No | £2.20 | bought_in |

### 5.3 Seed data SQL

```sql
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

---

## 6. Integration Points

### 6.1 Catalogue → Order form

The SvelteKit order form currently hardcodes drink options in a `<select>`. After this exercise:

- `GET /api/catalogue` returns all active catalogue entries (joined with menu item details)
- The order form populates dynamically from the catalogue
- Food items appear alongside drinks (the form expands from drink-only to all items)

### 6.2 Catalogue → CDR (order composition)

When an order is placed, the Temporal workflow commits an order composition to EHRbase. The composition builder currently uses hardcoded drink name mappings. After this exercise:

- The composition builder resolves drink/food details from the catalogue
- The archetype term mappings may need extending for new item types (food items are not currently represented in the order archetype)
- This is an integration point between PostgreSQL (catalogue lookup) and EHRbase (composition commit)

### 6.3 Inventory → Order workflow

For bought-in items, placing an order should decrement inventory. This is a new activity in the Temporal workflow (or a side effect of an existing activity). For prepared items, inventory is at the ingredient level and deferred for now.

### 6.4 Manager GUI → Catalogue and Inventory

New API routes and UI pages for catalogue and inventory management. The manager can:

- View all catalogue entries with current stock levels
- Add a new menu item + catalogue entry
- Edit price, availability, description
- View and adjust inventory for bought-in items
- See low-stock alerts

---

## 7. Archetype Patterns (Reference)

The openEHR archetype designs from v1 of this spec remain valid as *patterns* for clinical data that genuinely belongs in the CDR. When GSL needs:

- A **formulary** in the CDR → use the `ADMIN_ENTRY.catalogue_item` archetype pattern
- **Clinical stock records** (e.g. controlled drug registers) → use the `OBSERVATION.inventory_record` archetype pattern
- **Quality assessments** of products or services → use `EVALUATION`

The coffee shop's business catalogue lives in PostgreSQL. The archetype patterns apply when the same conceptual structures need to be represented in the clinical record.

See v1 of this spec (catalogue-inventory-archetype-spec.md) for the full maximal archetype designs and CSW template subsets.

---

## 8. Meta Model Implications

> **Clarification (Session 29, 14 March 2026):** The meta model implications below span two distinct meta models. Items in §8.1 (CatalogueEntry, ExternalReference, InventoryRecord, ActivityType) are **business meta model** concepts — they describe what the business offers and what resources it needs. Items in §8.3 (PersistencePolicy) are **business system meta model** concepts — they describe how the system is architected. See `gsl-architecture-clarification-two-meta-models-2026-03-14.md` for the authoritative statement of this distinction.

### 8.1 New concepts needed in BusinessModel

| Gap | Current state | Proposed addition |
|---|---|---|
| Individual orderable items | `ServiceOffering` is at package level only | `CatalogueEntry` part def — items within a service offering |
| Stock management | `ResourceType` is planning-level only | `InventoryRecord` part def — operational stock tracking |
| Reference data management | No activity type for catalogue maintenance | `ActivityType` instance or sub-type for administrative data management |
| External knowledge links | No mechanism for referencing external sources | `ExternalReference` part def — generic attachment point |

### 8.2 The item / catalogue / inventory separation as a meta pattern

The four-layer model (item definition → catalogue entry → inventory record → external references) is not specific to the coffee shop. It is a generic pattern for any business that offers things:

- **Healthcare:** Medication → Formulary entry → Stock record → SPC/BNF/NICE
- **Education:** Course → Prospectus entry → Available places → Accreditation body
- **Retail:** Product → Listing → Warehouse stock → Supplier catalogue
- **Professional services:** Service type → Engagement terms → Capacity → Regulatory requirements

This pattern may warrant explicit representation in the business meta model as a reusable structural template.

### 8.3 Persistence strategy as a meta model concern

The decision about where data lives (CDR vs relational database vs process engine) is itself a pattern that should be captured explicitly in the meta model, carrying both the decision and its rationale.

**Proposed SysML structures:**

```
enum def PersistenceLayer {
    clinicalDataRepository;
    businessDatabase;
    processEngine;
    externalReference;
}

enum def DataCharacteristic {
    doc /* Distinguishing characteristics that determine the
         * natural persistence home for a domain concept.
         * A concept's characteristic profile maps to a
         * persistence layer. */
    clinicalSignificance;
    terminologyBound;
    requiresVersioning;
    highFrequencyUpdate;
    transactionalIntegrity;
    relationalJoins;
    archetypeValidated;
    durableExecution;
    eventDriven;
    referenceData;
    regulatoryAudit;
}

part def PersistencePolicy {
    doc /* Maps a domain concept to its persistence layer,
         * with explicit rationale expressed as distinguishing
         * characteristics. Makes the architectural reasoning
         * queryable and auditable — the system can explain
         * why each concept lives where it does. */
    attribute domainConcept : String;
    attribute targetLayer : PersistenceLayer;
    attribute rationale : String;
    attribute characteristics : DataCharacteristic [1..*];
}
```

**CSW persistence policies (illustrative):**

| Domain concept | Target layer | Key characteristics | Rationale |
|---|---|---|---|
| CatalogueEntry | businessDatabase | referenceData, relationalJoins, transactionalIntegrity | Business reference data. Simple CRUD, relational joins to menu items and inventory. No clinical significance. |
| InventoryRecord | businessDatabase | highFrequencyUpdate, transactionalIntegrity | Operational state. Atomic decrement on sale. No archetype validation needed. |
| OrderRecord | clinicalDataRepository | archetypeValidated, terminologyBound, requiresVersioning, regulatoryAudit | Clinical analogue. Benefits from archetype validation, immutable versioning, audit trail. |
| FeedbackRecord | clinicalDataRepository | archetypeValidated, requiresVersioning | Qualitative assessment. Archetype-validated, versioned, queryable via AQL. |
| OrderWorkflow | processEngine | durableExecution, eventDriven | Stateful process. Durable execution, signal handling, activity orchestration. |
| SPC / BNF entry | externalReference | terminologyBound | Knowledge the system links to but does not own. |

### 8.4 System self-knowledge as an architectural principle

The persistence policy is one instance of a broader principle: **the system carries an explicit, queryable model of its own structure, decisions, and reasoning.** This is not documentation that sits alongside the system — it is part of the model that drives the system. The same model that generates code also explains why things are the way they are.

This principle has practical consequences:

- When an AI assistant (or a human developer) needs to extend the system with a new domain concept, the persistence policies provide a decision framework: assess the concept's data characteristics, match to a persistence layer, record the policy.
- When someone asks "why is the catalogue in PostgreSQL and not the CDR?", the answer is in the model, not in someone's head or a stale wiki page.
- When the system evolves — for example, if a clinical regulator requires that catalogue/formulary data be held in the CDR for audit purposes — the persistence policy for that concept changes, the rationale is updated, and the implementation follows from the revised model.

This is what makes AI-driven system development stay relatable and productive: the AI works with the same explicit reasoning structures the human designer works with. There is no hidden layer of interpretation. The system's self-knowledge is transparent, inspectable, and challengeable at every level of abstraction.

---

## 9. Implementation Phases (Revised)

| Phase | Focus | Deliverables |
|---|---|---|
| **0** | Conceptual modelling | ✓ This specification |
| **1** | SysML model update | Updated `coffeeshop.sysml` with ExternalReference, CatalogueEntry, InventoryRecord, new enums. Price removed from MenuItem. |
| **2** | PostgreSQL foundation | Docker Compose updated. Database created. Tables created. Seed data loaded. TypeScript database client in `@coffeeshop/shared`. |
| **3** | API routes | Catalogue CRUD endpoints. Inventory query/update endpoints. Order form rewired to read from catalogue. |
| **4** | Frontend foundation | Tailwind v4 + Flowbite installed. Layout shell. Dynamic order form. |
| **5** | Manager GUI | Stock management page. Catalogue editing. Inventory view with low-stock alerts. |
| **6** | Meta model update | BusinessModel SysML updated with CatalogueEntry, InventoryRecord, ExternalReference patterns. CSW business model updated. |

---

*Specification v2 prepared 12 March 2026. Supersedes v1 (archetype-only). Incorporates architectural decisions about CDR/database boundary, four-layer conceptual model, model-first discipline, and external reference patterns.*
