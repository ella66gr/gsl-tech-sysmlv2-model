# Session 20 Report — CSW Extension Phase 1: SysML Domain Model Update

**Date:** 12 March 2026
**Session number:** 20
**Workstream:** CSW Extension — Catalogue, Inventory & Frontend (Phase 1 of 10)
**Plan:** `gsl-plan-workstream-csw-extension-2026-03-12.md`

---

## Summary

Executed Phase 1 of the CSW Extension workstream: the SysML domain model update introducing the four-layer conceptual model (item definition → catalogue entry → inventory record → external references) established in the Phase 0 specification. Included a pre-flight migration to make the coffee shop demonstrator self-contained within the monorepo.

---

## Work Completed

### Pre-flight: Domain Model Migration to Monorepo

**Problem found:** The `CoffeeShop` domain model (containing `MenuItem`, `Drink`, `FoodItem`, `Order`, `OrderLine`, plus `OrderLifeCycle`, `DrinkFulfilment`, `BusinessRules` packages) was still in the archive repo at `coffeeshop-exercise-archive/model/domain/`. The monorepo's orchestration file imported `CoffeeShop::*` and Syside was silently resolving it from the archive directory in the VS Code workspace. The demonstrator was not self-contained.

**Resolution:** Copied all four domain model files into the monorepo at `exercises/coffeeshop-demonstrator/model/domain/`. Verified Syside resolved all imports from the monorepo alone by temporarily removing the archive from the VS Code workspace — `global-namespace-distinguishability` errors appeared while both were present (as expected), cleared once the archive was removed.

**Commit:** `CSW: migrate domain model files from archive to monorepo`

### Stage 1: SysML Domain Model Changes

Modified `exercises/coffeeshop-demonstrator/model/domain/coffeeshop.sysml`:

**New enumerations (3):**
- `AvailabilityStatus` — active, discontinued, seasonal, temporarilyUnavailable
- `ProvisionType` — prepared, boughtIn, hybrid
- `StockStatus` — inStock, low, outOfStock, onOrder

**New part definitions (3):**
- `ExternalReference` — links to knowledge outside the system (referenceType, referenceId, referenceSource, referenceNotes)
- `CatalogueEntry` — business decision to offer an item (ref item : MenuItem, pricePence, priceDisplay, availability, provisionType, effectiveDate, statusNotes)
- `InventoryRecord` — operational stock state (ref catalogueEntry : CatalogueEntry, quantityOnHand, stockStatus, lowStockThreshold, lastRestocked, quantityNotes)

**Modified part definitions:**
- `MenuItem` — removed `price : Real` (moves to CatalogueEntry), added `description : String`, added `part externalRefs : ExternalReference [0..*]`
- `Drink` — added `isCaffeinated : Boolean`

**KerML reserved word finding:** `references` is a KerML reserved word (§8.2.2.6). The spec's proposed `references : ExternalReference [0..*]` was renamed to `externalRefs`.

**Syside verification:** Zero errors, zero warnings across all model files.

**Type generator:** Ran `gen_typescript_types.py` — produced 8 enums, 11 interfaces. Two generator bugs found and hand-fixed in the output (see Findings below). Updated both `generated/types.ts` and `packages/shared/src/generated/types.ts`.

**Commit:** `CSW domain model: catalogue, inventory, external references`

### Stage 2: Business Model Catalogue Entries

Modified `exercises/coffeeshop-demonstrator/model/coffeeshop-business-model.sysml`:

- Added `private import CoffeeShop::*` to bring in new types
- Added 11 `CatalogueEntry` usages with `:>>` redefinitions for all menu items:
  - 5 hot drinks: Flat White (£2.80), Latte (£2.80), Americano (£2.50), Cappuccino (£2.80), Espresso (£2.00)
  - 2 cold drinks: Iced Latte (£3.20), Cold Brew (£3.00)
  - 2 new drinks: Mocha Latte (£3.80), Frappe (£4.20)
  - 2 new food items: Ginger Biscuit (£1.80, boughtIn), Oat Bar (£2.20, boughtIn)
- Added `catalogueMaintenance` activity type (overhead category)
- Cross-package enum resolution verified: `AvailabilityStatus::active` and `ProvisionType::prepared`/`boughtIn` resolved correctly through the `CoffeeShop::*` import chain

**Syside verification:** Zero errors, zero warnings.

**Commit:** `CSW business model: catalogue entries for all 11 items`

---

## Findings

### KerML Reserved Word: `references`

The word `references` appears in the KerML 1.0 §8.2.2.6 reserved word list. This would have caused a Syside parser error if used as an attribute or part name. Caught during the implementation planning reserved-word check. Renamed to `externalRefs`.

### Generator Bugs in `gen_typescript_types.py`

Two bugs found in the lightweight regex-based type generator:

1. **Enum doc block parsing:** Multi-line `doc /* ... */` blocks inside `enum def` cause the first literal after the doc block to be dropped or concatenated with doc text. Affected `AvailabilityStatus` (missing `active`), `ProvisionType` (garbage text in `prepared` value), and `StockStatus` (missing `inStock`).

2. **Space before multiplicity bracket:** The part regex expects `Type[0..*]` with no space before the bracket, but SysML idiom is `Type [0..*]` with a space. `part externalRefs : ExternalReference [0..*]` was not matched, so `externalRefs` was missing from the generated `MenuItem` interface.

Both bugs were worked around by hand-fixing the generated output. The fixes are noted in the file header comment. The generator is documented as a lightweight text-based parser for the coffee shop exercise; the long-term replacement is Syside Automator for proper semantic model access.

### Domain Model Was Not Self-Contained

The coffee shop demonstrator's domain model files (`coffeeshop.sysml`, `order-lifecycle.sysml`, `drink-fulfilment.sysml`, `business-rules.sysml`) were inadvertently left in the archive repo during the earlier repo consolidation. Syside resolved imports silently from the archive directory being in the VS Code workspace. This was a latent configuration dependency — the demonstrator appeared to work but would have broken if the archive were removed from the workspace. Fixed by migrating the files into the monorepo.

---

## Coffee Shop Demonstrator Extension

**Capability demonstrated:** Four-layer domain model (item definition → catalogue entry → inventory record → external references) with model-first discipline.

**What was built:** Three new part defs, three new enums, modifications to two existing part defs, 11 catalogue entry usages with business properties, one new activity type. The SysML model now cleanly separates intrinsic product properties from business decisions from operational state from external knowledge links.

**What was learned:**
- The `references` KerML reserved word trap — adds to the known list alongside `ordered`, `accepted`, `comment`, `standard`, `action`, `default`
- The regex-based type generator has limits with doc blocks inside enums and spaces in multiplicity syntax — Syside Automator is the correct long-term solution
- The four-layer model feels natural for the coffee shop domain and maps cleanly to the healthcare analogue (medication → formulary → stock → SPC/BNF)

**Clinical implementation confidence:** High. The CatalogueEntry/InventoryRecord/ExternalReference pattern is domain-agnostic and maps directly to medication formulary management in the clinical system.

---

## Git Log

| Commit | Description |
|---|---|
| `551fc6f` | CSW: migrate domain model files from archive to monorepo |
| `c46e4c7` | CSW domain model: catalogue, inventory, external references (SysML changes) |
| `baeb813` | CSW domain model: catalogue, inventory, external references (generated types, hand-fixed) |
| *(pending)* | CSW business model: catalogue entries for all 11 items |

---

## Next Session

Continue CSW Extension workstream — **Phase 2: PostgreSQL Foundation**:
- Add PostgreSQL service to Docker Compose
- Create `coffeeshop_business` database
- Create tables from the specification (§4.1 of `catalogue-inventory-spec-v2.md`)
- Run seed data SQL (§5.3)
- Write `postgres-client.ts` in `@coffeeshop/shared`

Phase 2 implementation plan: `gsl-plan-workstream-csw-extension-2026-03-12.md` §Phase 2.

---

## Syntax Reference

No update required — no new patterns verified that aren't already covered in v3.11. The patterns exercised (cross-package enum `:>>`, mixed-type `:>>`, contained part with multiplicity) were already documented.

---

*Session 20 report prepared 12 March 2026.*
