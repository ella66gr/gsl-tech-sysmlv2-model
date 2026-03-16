# CSW Extension Phase 1: SysML Domain Model Update — Detailed Implementation Plan

**Workstream:** Coffee Shop Extension — Catalogue, Inventory & Frontend
**Phase:** 1 of 10
**Date:** 12 March 2026
**Prerequisites:** Phase 0 complete (conceptual modelling, `catalogue-inventory-spec-v2.md`)
**Source plan:** `gsl-plan-workstream-csw-extension-2026-03-12.md`
**Estimated effort:** 2 stages

---

## 0. Pre-flight: Domain Model Migration to Monorepo

### Problem

The `CoffeeShop` domain model package (containing `MenuItem`, `Drink`, `FoodItem`, `Order`, `OrderLine`, plus supporting packages `OrderLifeCycle`, `DrinkFulfilment`, `BusinessRules`) currently lives in the **archive repo** at:

```
/Users/ellagreen/Developer/gsl-tech/coffeeshop-exercise-archive/model/domain/
```

The monorepo's orchestration file (`exercises/coffeeshop-demonstrator/model/domain/fulfil-drink-orchestration.sysml`) imports `CoffeeShop::*`, which Syside resolves only because the archive directory happens to be in the VS Code workspace folder tree. The demonstrator is not self-contained — it depends silently on an external directory.

This was an inadvertent consequence of the repo consolidation. The domain model files should have been migrated into the monorepo at that time.

### Migration Plan

Copy all four domain model files from the archive into the monorepo:

| Archive file | Monorepo destination |
|---|---|
| `coffeeshop-exercise-archive/model/domain/coffeeshop.sysml` | `exercises/coffeeshop-demonstrator/model/domain/coffeeshop.sysml` |
| `coffeeshop-exercise-archive/model/domain/order-lifecycle.sysml` | `exercises/coffeeshop-demonstrator/model/domain/order-lifecycle.sysml` |
| `coffeeshop-exercise-archive/model/domain/drink-fulfilment.sysml` | `exercises/coffeeshop-demonstrator/model/domain/drink-fulfilment.sysml` |
| `coffeeshop-exercise-archive/model/domain/business-rules.sysml` | `exercises/coffeeshop-demonstrator/model/domain/business-rules.sysml` |

After migration:

1. Verify Syside resolves all imports with zero errors from the monorepo copy
2. Temporarily close the archive directory in the VS Code workspace to confirm the monorepo is self-contained
3. Re-open the archive if desired (it serves as historical reference)

**Current state of `model/domain/` in the monorepo** (pre-migration):

```
exercises/coffeeshop-demonstrator/model/domain/
  └── fulfil-drink-orchestration.sysml   ← only file currently present
```

**Post-migration:**

```
exercises/coffeeshop-demonstrator/model/domain/
  ├── coffeeshop.sysml                   ← migrated, then modified in Stage 1
  ├── order-lifecycle.sysml              ← migrated, unchanged
  ├── drink-fulfilment.sysml             ← migrated, unchanged
  ├── business-rules.sysml              ← migrated, unchanged
  └── fulfil-drink-orchestration.sysml   ← existing, unchanged
```

### Import Chain Verification

The import dependencies are:

- `coffeeshop.sysml` (`CoffeeShop`) imports `OrderLifeCycle::*` and `ScalarValues::*`
- `order-lifecycle.sysml` (`OrderLifeCycle`) imports `ScalarValues::*`
- `drink-fulfilment.sysml` (`DrinkFulfilment`) imports `CoffeeShop::*` and `ScalarValues::*`
- `business-rules.sysml` (`BusinessRules`) imports `CoffeeShop::*` and `ScalarValues::*`
- `fulfil-drink-orchestration.sysml` (`FulfilDrinkOrchestration`) imports `CoffeeShop::*`, `TemporalMetadata::*`, and `ScalarValues::*`
- `coffeeshop-business-model.sysml` (`CoffeeShopBusinessModel`) imports `BusinessModel::ServiceConcept::*` and `BusinessModel::ActivityModel::*`

All cross-project imports should resolve via the VS Code workspace folder tree. The only external dependency is on the main model packages (`BusinessModel`, `TemporalMetadata`, `Foundation`) which live in `/model/` and `/libraries/` — both within the monorepo.

### Commit

```
git add exercises/coffeeshop-demonstrator/model/domain/
git commit -m "CSW: migrate domain model files from archive to monorepo

Copy coffeeshop.sysml, order-lifecycle.sysml, drink-fulfilment.sysml,
and business-rules.sysml from coffeeshop-exercise-archive into the
monorepo at exercises/coffeeshop-demonstrator/model/domain/.

The demonstrator was silently depending on the archive directory being
in the VS Code workspace. This makes the demonstrator self-contained."
```

---

## Stage 1: SysML Domain Model Changes

### 1.1 Read the syntax reference

Read `gsl-sysml-v2-syntax-reference-v3.11-2026-03-11.md` before writing any SysML. Key verified patterns to use:

| Pattern | Syntax reference status |
|---|---|
| `enum def Name { literal1; literal2; }` | Verified, all versions |
| `part def` with `ref x : Type` | Verified v3.11 — works within and across packages |
| `part x : PartDef [0..*]` (contained part with multiplicity) | Verified v3.5 |
| `attribute x : String` / `Integer` / `Real` / `Boolean` | All four scalar types confirmed v3.9 |
| `doc /* ... */` inside part def, enum def, package | Verified, all versions |
| `:>>` with String, Integer, Real, Boolean, enum literals | All confirmed v3.9–v3.11 |
| Cross-project import of enum-typed attributes | Verified v3.8, extended v3.10 |

### 1.2 KerML reserved word check

Every proposed name checked against the KerML 1.0 §8.2.2.6 reserved word list:

| Proposed name | Reserved? | Action |
|---|---|---|
| `ExternalReference` | No | Safe |
| `CatalogueEntry` | No | Safe |
| `InventoryRecord` | No | Safe |
| `AvailabilityStatus` | No | Safe |
| `ProvisionType` | No | Safe |
| `StockStatus` | No | Safe |
| `referenceType` | No — `type` is reserved but compound camelCase names are safe | Safe |
| `referenceId` | No | Safe |
| `referenceSource` | No | Safe |
| `referenceNotes` | No | Safe |
| `pricePence` | No | Safe |
| `priceDisplay` | No | Safe |
| `availability` | No | Safe |
| `provisionType` | No | Safe |
| `effectiveDate` | No | Safe |
| `statusNotes` | No | Safe |
| `quantityOnHand` | No | Safe |
| `stockStatus` | No | Safe |
| `lowStockThreshold` | No | Safe |
| `lastRestocked` | No | Safe |
| `quantityNotes` | No | Safe |
| `description` | No | Safe |
| `isCaffeinated` | No | Safe |
| `active` (enum literal) | No | Safe |
| `discontinued` (enum literal) | No | Safe |
| `seasonal` (enum literal) | No | Safe |
| `temporarilyUnavailable` (enum literal) | No | Safe |
| `prepared` (enum literal) | No | Safe |
| `boughtIn` (enum literal) | No | Safe |
| `hybrid` (enum literal) | No | Safe |
| `inStock` (enum literal) | No — `in` is reserved but `inStock` is a compound camelCase name | Safe |
| `low` (enum literal) | No | Safe |
| `outOfStock` (enum literal) | No | Safe |
| `onOrder` (enum literal) | No | Safe |
| `item` (ref name on CatalogueEntry) | No | Safe |
| **`references`** (proposed contained part name) | **YES — KerML reserved word** | **Rename to `externalRefs`** |

**One collision found.** The spec proposes `references : ExternalReference [0..*]` as a contained part on `MenuItem`. The word `references` appears in the KerML reserved word list. **Rename to `externalRefs`.**

### 1.3 Modifications to `coffeeshop.sysml`

All changes are to the `CoffeeShop` package in `exercises/coffeeshop-demonstrator/model/domain/coffeeshop.sysml` (the freshly migrated file).

#### a) Add new enum defs

Add after the existing `ItemCategory` enum def, before the Core domain definitions section:

```sysml
enum def AvailabilityStatus {
    doc /* Whether a catalogue item is currently available for ordering. */
    active;
    discontinued;
    seasonal;
    temporarilyUnavailable;
}

enum def ProvisionType {
    doc /* How the shop acquires or produces the item. Affects
         * inventory semantics: prepared items track ingredients;
         * bought-in items track finished products. */
    prepared;
    boughtIn;
    hybrid;
}

enum def StockStatus {
    doc /* Current stock level classification for a bought-in item. */
    inStock;
    low;
    outOfStock;
    onOrder;
}
```

#### b) Add `ExternalReference` part def

Add before `MenuItem` (since MenuItem will reference it):

```sysml
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
```

#### c) Modify `MenuItem` — remove `price`, add `description` and `externalRefs`

```sysml
// BEFORE
part def MenuItem {
    doc /* Something the shop sells */
    attribute name : String;
    attribute price : Real;
    attribute category : ItemCategory;
    attribute isVegan : Boolean;
}

// AFTER
part def MenuItem {
    doc /* Something the shop sells. Describes intrinsic product
         * characteristics only. Price and availability are
         * business decisions that live on CatalogueEntry. */
    attribute name : String;
    attribute category : ItemCategory;
    attribute isVegan : Boolean;
    attribute description : String;
    part externalRefs : ExternalReference [0..*];
}
```

**Notes:**

- `price : Real` removed — price moves to `CatalogueEntry` (a business decision, not an intrinsic property)
- `description : String` added — textual description of the item
- `part externalRefs : ExternalReference [0..*]` — contained part (composition), not `ref`, because external references are owned by the item. Multiplicity `[0..*]` allows items with no external references. Name `externalRefs` avoids the KerML reserved word `references`.

#### d) Add `isCaffeinated` to `Drink`

```sysml
// BEFORE
part def Drink :> MenuItem {
    doc /* A drink, extending MenuItem with drink-specific attributes */
    attribute size : DrinkSize;
    attribute milkChoice : MilkOption;
}

// AFTER
part def Drink :> MenuItem {
    doc /* A drink, extending MenuItem with drink-specific attributes */
    attribute size : DrinkSize;
    attribute milkChoice : MilkOption;
    attribute isCaffeinated : Boolean;
}
```

**Design note on `availableSizes`:** The spec mentions `available_sizes` as a PostgreSQL array column, but in the SysML model `size` is a single `DrinkSize` attribute representing the size chosen per order line. The set of *available* sizes for a drink type is a catalogue-level concern. We do not add an `availableSizes` attribute to `Drink` — the PostgreSQL `available_sizes TEXT[]` column captures this at the database level. If needed in the SysML model later, it would belong on `CatalogueEntry` or a drink-specific catalogue specialisation.

#### e) Add `CatalogueEntry` part def

Add after the existing domain definitions (after `FoodItem`, before People section):

```sysml
part def CatalogueEntry {
    doc /* The business decision to offer an item for sale.
         * References an item definition (MenuItem or specialisation)
         * and adds business-context properties: price, availability,
         * provision type. A single item may appear in multiple
         * catalogues at different prices or terms. */
    ref item : MenuItem;
    attribute pricePence : Integer;
    attribute priceDisplay : String;
    attribute availability : AvailabilityStatus;
    attribute provisionType : ProvisionType;
    attribute effectiveDate : String;
    attribute statusNotes : String;
}
```

**Notes:**

- `ref item : MenuItem` — reference (not containment) because the item definition exists independently. Default multiplicity `[1]`.
- `pricePence : Integer` — price in pence avoids floating-point currency issues. `priceDisplay : String` is the human-readable form (e.g. "£2.80").
- `effectiveDate : String` — SysML v2 has no native date/time type. String is pragmatic. The PostgreSQL layer uses `TIMESTAMPTZ`.

#### f) Add `InventoryRecord` part def

Add after `CatalogueEntry`:

```sysml
part def InventoryRecord {
    doc /* A point-in-time record of stock level for a catalogue
         * item. References a catalogue entry (not the item
         * definition directly) because inventory is scoped to
         * what the business currently offers. */
    ref catalogueEntry : CatalogueEntry;
    attribute quantityOnHand : Integer;
    attribute stockStatus : StockStatus;
    attribute lowStockThreshold : Integer;
    attribute lastRestocked : String;
    attribute quantityNotes : String;
}
```

### 1.4 No changes to other domain files

- `order-lifecycle.sysml` — unchanged
- `drink-fulfilment.sysml` — unchanged (references `CoffeeShop::*` which still exports all needed types)
- `business-rules.sysml` — unchanged (existing constraints reference `MenuItem`, `Drink`, `Order`, `StaffMember` which are all still present; the `LoyaltyDiscountConstraint` references a `discount : Real` parameter — this is a constraint parameter, not `MenuItem.price`, so the price removal does not affect it)
- `fulfil-drink-orchestration.sysml` — unchanged (references `OrderLine`, not `MenuItem.price`)

### 1.5 Verify in Syside Modeler

After writing the changes:

1. Open `coffeeshop.sysml` in VS Code with Syside Modeler active
2. Check the Problems panel for: **zero errors, zero warnings**
3. Specific verification points:
   - `part externalRefs : ExternalReference [0..*]` — contained part with multiplicity resolves (verified pattern v3.5)
   - `ref item : MenuItem` on `CatalogueEntry` — within-package ref resolves
   - `ref catalogueEntry : CatalogueEntry` on `InventoryRecord` — within-package ref resolves
   - All new enum literals — no parser errors (no reserved word collisions after the rename)
   - `attribute isCaffeinated : Boolean` on `Drink` — no clash with existing attributes
   - All other files in the model directory continue to resolve with zero errors (check that `CoffeeShopBusinessModel`, `FulfilDrinkOrchestration`, `BusinessRules`, `DrinkFulfilment` all still parse cleanly)
4. Check that the `coffeeshop-business-model.sysml` (which imports `BusinessModel::ServiceConcept::*` etc.) is unaffected — it does not currently import `CoffeeShop::*`

### 1.6 Run TypeScript type generator

Run `gen_typescript_types.py` against the updated model to see the effect:

```bash
cd exercises/coffeeshop-demonstrator
python generators/gen_typescript_types.py
```

**Expected changes to `generated/types.ts`:**

- `MenuItem` interface loses `price: number`
- `MenuItem` interface gains `description: string`
- `Drink` interface gains `isCaffeinated: boolean`
- New interfaces: `ExternalReference`, `CatalogueEntry`, `InventoryRecord`
- New enums: `AvailabilityStatus`, `ProvisionType`, `StockStatus`

**Possible generator limitations:** The generator may not yet handle:
- `part externalRefs : ExternalReference [0..*]` — a contained part on a part def
- `ref item : MenuItem` — a reference on a part def
- New enum defs not previously present

If the generator handles these cleanly, copy the output to `packages/shared/src/generated/types.ts`. If not, note what needs updating — generator fixes are a sub-task of this stage or deferred to Phase 3.

**Note:** Copying the updated `types.ts` will cause TypeScript compilation errors in files that reference `MenuItem.price`. This is expected — the compilation errors serve as a roadmap for the Phase 3 downstream updates. Do not fix them now.

### 1.7 Commit

```
git add exercises/coffeeshop-demonstrator/model/domain/coffeeshop.sysml
git add exercises/coffeeshop-demonstrator/generated/types.ts           # if generator ran
git add exercises/coffeeshop-demonstrator/packages/shared/src/generated/types.ts  # if updated
git commit -m "CSW domain model: catalogue, inventory, external references

- Remove price from MenuItem (moves to CatalogueEntry)
- Add description attribute to MenuItem
- Add part externalRefs : ExternalReference [0..*] to MenuItem
- Add isCaffeinated : Boolean to Drink
- Add ExternalReference part def (external knowledge links)
- Add CatalogueEntry part def (business offering decisions)
- Add InventoryRecord part def (operational stock state)
- Add enums: AvailabilityStatus, ProvisionType, StockStatus
- Rename 'references' to 'externalRefs' (KerML reserved word)

Four-layer model: item definition → catalogue entry →
inventory record → external references.

Breaking change: MenuItem.price removed. Downstream updates
(composition builder, order form, API routes) follow in Phase 3."
```

---

## Stage 2: Coffee Shop Business Model Catalogue Entries

### 2.1 Add import to `coffeeshop-business-model.sysml`

Add a new import to bring in the catalogue and inventory types:

```sysml
private import CoffeeShop::*;
```

This brings `CatalogueEntry`, `AvailabilityStatus`, `ProvisionType`, `ExternalReference`, `InventoryRecord`, `StockStatus`, and all existing types into scope.

### 2.2 Design decision: ref :>> item

The `ref item : MenuItem` on `CatalogueEntry` is a reference to a `MenuItem` instance. In this model, `MenuItem` instances are not explicitly instantiated as named usages — they exist conceptually and are materialised in the database.

**Decision:** Omit the ref redefinition for now. The catalogue entries record business properties only; the item-to-catalogue link is handled at the implementation level (database FK). If we want explicit `MenuItem` usages later (Phase 10 meta model update), we can add them then.

This means catalogue entry usages will not include `ref :>> item = someMenuItemUsage`. They demonstrate the business property layer through their `:>>` attribute redefinitions.

### 2.3 Add catalogue entries for all 11 items

Add a new section to `coffeeshop-business-model.sysml` after the existing Activity Model and Granularity sections:

```sysml
// -- Catalogue Entries ------------------------------------
//
// Business decisions about what to offer and at what price.
// Each entry references a menu item and adds business context.
// Provision type classification determines inventory semantics.
// The item ref is structural — specific MenuItem binding is a
// runtime/database concern, not modelled here.

// -- Hot drinks --

part flatWhiteCatalogue : CatalogueEntry {
    doc /* Flat White — flagship espresso drink. */
    attribute :>> pricePence = 280;
    attribute :>> priceDisplay = "£2.80";
    attribute :>> availability = AvailabilityStatus::active;
    attribute :>> provisionType = ProvisionType::prepared;
    attribute :>> effectiveDate = "2026-03-12";
    attribute :>> statusNotes = "Core menu item";
}

part latteCatalogue : CatalogueEntry {
    attribute :>> pricePence = 280;
    attribute :>> priceDisplay = "£2.80";
    attribute :>> availability = AvailabilityStatus::active;
    attribute :>> provisionType = ProvisionType::prepared;
    attribute :>> effectiveDate = "2026-03-12";
    attribute :>> statusNotes = "Core menu item";
}

part americanoCatalogue : CatalogueEntry {
    attribute :>> pricePence = 250;
    attribute :>> priceDisplay = "£2.50";
    attribute :>> availability = AvailabilityStatus::active;
    attribute :>> provisionType = ProvisionType::prepared;
    attribute :>> effectiveDate = "2026-03-12";
    attribute :>> statusNotes = "Core menu item";
}

part cappuccinoCatalogue : CatalogueEntry {
    attribute :>> pricePence = 280;
    attribute :>> priceDisplay = "£2.80";
    attribute :>> availability = AvailabilityStatus::active;
    attribute :>> provisionType = ProvisionType::prepared;
    attribute :>> effectiveDate = "2026-03-12";
    attribute :>> statusNotes = "Core menu item";
}

part espressoCatalogue : CatalogueEntry {
    attribute :>> pricePence = 200;
    attribute :>> priceDisplay = "£2.00";
    attribute :>> availability = AvailabilityStatus::active;
    attribute :>> provisionType = ProvisionType::prepared;
    attribute :>> effectiveDate = "2026-03-12";
    attribute :>> statusNotes = "Core menu item — single size only";
}

// -- Cold drinks --

part icedLatteCatalogue : CatalogueEntry {
    attribute :>> pricePence = 320;
    attribute :>> priceDisplay = "£3.20";
    attribute :>> availability = AvailabilityStatus::active;
    attribute :>> provisionType = ProvisionType::prepared;
    attribute :>> effectiveDate = "2026-03-12";
    attribute :>> statusNotes = "Seasonal favourite";
}

part coldBrewCatalogue : CatalogueEntry {
    attribute :>> pricePence = 300;
    attribute :>> priceDisplay = "£3.00";
    attribute :>> availability = AvailabilityStatus::active;
    attribute :>> provisionType = ProvisionType::prepared;
    attribute :>> effectiveDate = "2026-03-12";
    attribute :>> statusNotes = "Slow-steeped — 12hr preparation";
}

// -- New drinks --

part mochaLatteCatalogue : CatalogueEntry {
    doc /* Mocha Latte — new addition, March 2026. */
    attribute :>> pricePence = 380;
    attribute :>> priceDisplay = "£3.80";
    attribute :>> availability = AvailabilityStatus::active;
    attribute :>> provisionType = ProvisionType::prepared;
    attribute :>> effectiveDate = "2026-03-12";
    attribute :>> statusNotes = "New menu item — espresso with chocolate and steamed milk";
}

part frappeCatalogue : CatalogueEntry {
    doc /* Frappe — new addition, March 2026. */
    attribute :>> pricePence = 420;
    attribute :>> priceDisplay = "£4.20";
    attribute :>> availability = AvailabilityStatus::active;
    attribute :>> provisionType = ProvisionType::prepared;
    attribute :>> effectiveDate = "2026-03-12";
    attribute :>> statusNotes = "New menu item — blended iced coffee";
}

// -- Food items (bought-in) --

part gingerBiscuitCatalogue : CatalogueEntry {
    doc /* Ginger Biscuit — new addition, March 2026.
         * First bought-in item. Inventory tracking applies. */
    attribute :>> pricePence = 180;
    attribute :>> priceDisplay = "£1.80";
    attribute :>> availability = AvailabilityStatus::active;
    attribute :>> provisionType = ProvisionType::boughtIn;
    attribute :>> effectiveDate = "2026-03-12";
    attribute :>> statusNotes = "New menu item — bought-in, stock tracked";
}

part oatBarCatalogue : CatalogueEntry {
    doc /* Oat Bar — new addition, March 2026.
         * Bought-in, vegan, gluten-free. */
    attribute :>> pricePence = 220;
    attribute :>> priceDisplay = "£2.20";
    attribute :>> availability = AvailabilityStatus::active;
    attribute :>> provisionType = ProvisionType::boughtIn;
    attribute :>> effectiveDate = "2026-03-12";
    attribute :>> statusNotes = "New menu item — bought-in, vegan, GF, stock tracked";
}
```

### 2.4 Add catalogue maintenance activity type

Add to the Activity Model section:

```sysml
part catalogueMaintenance : ActivityType {
    doc /* Administrative data management: maintaining the
         * product catalogue, updating prices, managing
         * availability status and inventory records. */
    attribute :>> activityTypeName = "Catalogue maintenance";
    attribute :>> activityCategory = ActivityCategory::overhead;
    attribute :>> description = "Add, edit, and manage menu items, pricing, and stock levels";
    attribute :>> expectedDurationMinutes = 15;
    attribute :>> frequencyNotes = "As needed — typically weekly or when menu changes";
}
```

### 2.5 Verify in Syside Modeler

1. Check `coffeeshop-business-model.sysml` parses with **zero errors, zero warnings**
2. Verify all 11 `:>>` redefinitions resolve:
   - `Integer` literals (pricePence) — verified pattern v3.6
   - `String` literals (priceDisplay, effectiveDate, statusNotes) — verified pattern v3.5
   - Enum literals (`AvailabilityStatus::active`, `ProvisionType::prepared`, `ProvisionType::boughtIn`) — verify cross-package enum resolution via `CoffeeShop::*` import
3. Verify `ActivityCategory::overhead` still resolves through the existing `BusinessModel::ActivityModel::*` import chain
4. Check that no other files are affected

### 2.6 Commit

```
git add exercises/coffeeshop-demonstrator/model/coffeeshop-business-model.sysml
git commit -m "CSW business model: catalogue entries for all 11 items

- 11 CatalogueEntry usages with pricing and provision type
- 7 existing drinks + 2 new drinks (mocha latte, frappe)
  + 2 new food items (ginger biscuit, oat bar)
- First bought-in items: ginger biscuit and oat bar
  (ProvisionType::boughtIn — inventory tracking applies)
- catalogueMaintenance activity type added (overhead category)
- Demonstrates four-layer model at business decision layer"
```

---

## Impact Analysis: What Changes Downstream

Phase 1 is the SysML model update only. It creates a **breaking change** that ripples through later phases. Documented here for planning:

### Generated `types.ts` — updated in Stage 1

After running `gen_typescript_types.py`:

| Change | Detail |
|---|---|
| `MenuItem.price` removed | Breaking — any code referencing `MenuItem.price` will fail |
| `MenuItem.description` added | New field |
| `Drink.isCaffeinated` added | New field |
| `ExternalReference` interface | New |
| `CatalogueEntry` interface | New |
| `InventoryRecord` interface | New |
| `AvailabilityStatus` enum | New |
| `ProvisionType` enum | New |
| `StockStatus` enum | New |

### Composition builder — Phase 3 concern

`composition-builder.ts` does not reference `MenuItem.price` directly (CDR compositions record drink type, size, and milk — not price). The CDR commit path is **not broken** by the price removal.

However, the `DRINK_NAME_TERMS` mapping needs extending for:
- `mocha latte` → Coffee (at0010)
- `frappe` → Coffee (at0010)

Food items would need a new archetype or extended composition template — this is a Phase 3 decision.

### Order API route (`POST /api/orders`) — Phase 3 concern

Currently receives `{ customerName, drinkType, size }` and starts a Temporal workflow. After Phase 2 (PostgreSQL) and Phase 3 (API routes), this should validate against the catalogue and resolve price from `CatalogueEntry` rather than from `MenuItem`.

### Order form (`+page.svelte`) — Phase 5 concern

Currently hardcodes seven drink options. Will be replaced with catalogue-driven dynamic form in Phase 5.

### Unit economics in `coffeeshop-resource-financial.sysml`

`drinkUnitEconomics` references `revenuePerUnit = 3.50` — this is an average. Not broken, but may need updating once the actual catalogue prices (£2.00–£4.20) are factored in. This is a Phase 10 (meta model update) consideration.

---

## Syntax Reference Update Candidates

If any new patterns are verified during this phase, update `gsl-sysml-v2-syntax-reference-v3.11`:

| Pattern to verify | Expected outcome | Notes |
|---|---|---|
| `part x : PartDef [0..*]` where PartDef has only attributes (no refs/parts) | Should work — simpler case of already-verified v3.5 pattern | `externalRefs` on `MenuItem` |
| Cross-package enum resolution via chained import (`CoffeeShopBusinessModel` imports `CoffeeShop::*` which defines `AvailabilityStatus`, then uses `AvailabilityStatus::active` in `:>>`) | Should work — similar to v3.8/v3.10 pattern with `ActivityCategory` | New enum path |
| Multiple `:>>` with mixed Integer + String + enum in a single usage | Should work — v3.9 verified mixed types | 11 catalogue entries test at scale |

---

## Checklist

### Pre-flight: Migration
- [ ] Copy `coffeeshop.sysml` to `exercises/coffeeshop-demonstrator/model/domain/`
- [ ] Copy `order-lifecycle.sysml` to `exercises/coffeeshop-demonstrator/model/domain/`
- [ ] Copy `drink-fulfilment.sysml` to `exercises/coffeeshop-demonstrator/model/domain/`
- [ ] Copy `business-rules.sysml` to `exercises/coffeeshop-demonstrator/model/domain/`
- [ ] Verify Syside resolves all imports — zero errors, zero warnings
- [ ] Close archive directory in VS Code workspace, verify monorepo is self-contained
- [ ] Commit migration

### Stage 1: Domain model changes
- [ ] Read syntax reference v3.11
- [ ] Add `AvailabilityStatus` enum def
- [ ] Add `ProvisionType` enum def
- [ ] Add `StockStatus` enum def
- [ ] Add `ExternalReference` part def
- [ ] Remove `price : Real` from `MenuItem`
- [ ] Add `description : String` to `MenuItem`
- [ ] Add `part externalRefs : ExternalReference [0..*]` to `MenuItem`
- [ ] Add `isCaffeinated : Boolean` to `Drink`
- [ ] Add `CatalogueEntry` part def
- [ ] Add `InventoryRecord` part def
- [ ] Verify in Syside: zero errors, zero warnings across all model files
- [ ] Run `gen_typescript_types.py` — assess output, note any generator limitations
- [ ] Copy updated `types.ts` to `packages/shared/src/generated/`
- [ ] Commit domain model changes

### Stage 2: Business model catalogue entries
- [ ] Add `private import CoffeeShop::*;` to `coffeeshop-business-model.sysml`
- [ ] Add 11 `CatalogueEntry` usages with `:>>` redefinitions
- [ ] Add `catalogueMaintenance` activity type
- [ ] Verify in Syside: zero errors, zero warnings
- [ ] Commit business model extension

### Post-phase
- [ ] Note any syntax reference updates needed
- [ ] Note any generator limitations encountered
- [ ] Update `gsl-plan-next-steps-and-deferred-items.md` if new deferred items arise

---

*Plan prepared 12 March 2026. Phase 1 of the CSW Extension workstream.*
