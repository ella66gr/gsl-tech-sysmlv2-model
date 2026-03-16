# Session 22 Report — CSW Extension Phase 3: Catalogue & Inventory API Routes

**Date:** 12 March 2026
**Session number:** 22
**Workstream:** CSW Extension — Catalogue, Inventory & Frontend (Phase 3 of 10)
**Plan:** `gsl-plan-csw-extension-phase3-implementation-2026-03-12.md`

---

## Summary

Executed Phase 3 of the CSW Extension workstream: the catalogue and inventory API layer with order validation. The coffee shop demonstrator now has a complete CRUD API for catalogue and inventory management, and order submission validates against the catalogue before starting a Temporal workflow. This is the transition from read-only verification endpoints (Phase 2) to a fully operational business API.

---

## Work Completed

### Stage 1: Mutation Methods in postgres-client.ts

**Transaction support:** Added `withTransaction` helper inside `createPostgresClient` — acquires a `PoolClient`, runs `BEGIN`/`COMMIT`/`ROLLBACK`, releases the client in a `finally` block. Used by `createCatalogueItem` for multi-table atomic inserts.

**Input types:** Five new interfaces for mutation operations:
- `CreateMenuItemInput` — fields for a new menu item (name, category, itemType, dietary flags, drink/food-specific fields)
- `CreateCatalogueItemInput` — combined: menu item + catalogue entry + optional initial inventory
- `UpdateCatalogueEntryInput` — partial update for price, availability, status notes
- `UpdateInventoryInput` — partial update for stock level, status, threshold, notes
- `CatalogueLookupResult` — lightweight result for order validation (name, price, sizes, provision type)

**Five new methods on `PostgresClient`:**
- `createCatalogueItem()` — transactional insert across menu_items + catalogue_entries + optionally inventory_records. Stock status auto-calculated from quantity vs threshold.
- `updateCatalogueEntry()` — dynamic SET clause from provided fields, `updated_at` timestamp, returns full joined view via `getCatalogueEntry()`.
- `updateInventory()` — stock adjustment with auto-calculated `stock_status` (in_stock/low/out_of_stock). Auto-updates `last_restocked` when quantity increases. Threshold-aware: uses new threshold if provided, existing if not.
- `lookupActiveItemByName()` — case-insensitive name match against active catalogue entries. Returns a lightweight result with the fields needed for order validation.
- `decrementInventory()` — atomic `UPDATE` with `GREATEST(0, quantity_on_hand - $1)` to prevent negative stock. Auto-recalculates status. Returns null for prepared items (no inventory record — correct no-op).

**Build:** Clean `tsc` compilation with no errors.

**Commit:** `8b90a68` — CSW: mutation methods and order validation in postgres-client

### Stage 2: Catalogue & Inventory CRUD API Routes

**Catalogue routes extended:**
- `GET /api/catalogue` — gains `?all=true` query parameter for manager view (includes non-active entries)
- `POST /api/catalogue` — creates menu item + catalogue entry transactionally. Validates: required fields, category/itemType consistency (food category requires food_item type, drink categories require drink type), provision type. Returns 201 on success, 409 on duplicate name.
- `GET /api/catalogue/[id]` — single entry with full joined view. Returns 404 if not found.
- `PUT /api/catalogue/[id]` — partial update. Validates availability enum and pricePence (non-negative integer). Returns 404 if not found.

**Inventory routes extended:**
- `GET /api/inventory` — gains `?low=true` query parameter for low-stock items only
- `GET /api/inventory/[id]` — single inventory record. Returns 404 if not found.
- `PUT /api/inventory/[id]` — stock adjustment. Validates stockStatus enum and quantityOnHand (non-negative integer). Returns 404 if not found.

**Full stack verification:**
- POST created "Hot Chocolate" — returned with UUID, price £3.00, catalogue grew to 12 items
- GET single entry by UUID — returned correct item
- PUT catalogue — updated Hot Chocolate price from £3.00 to £3.50
- PUT inventory — reduced Ginger Biscuit stock to 3, status auto-calculated to "low"
- GET `?low=true` — returned 1 item (Ginger Biscuit)
- Database reset via volume removal restored canonical 11-item seed data

**Commit:** `c7488c3` — CSW: catalogue and inventory CRUD API routes

### Stage 3: Order Validation Against Catalogue

**`POST /api/orders` rewired:** The endpoint now validates against the catalogue before starting the Temporal workflow:

1. Looks up the ordered item by name (case-insensitive) via `lookupActiveItemByName()`
2. Rejects with 400 if item not found or not active
3. Validates the requested size against the catalogue's `availableSizes` for that specific item
4. Rejects with 400 if size is invalid (includes available sizes in error message)
5. Decrements inventory for bought-in items
6. Passes catalogue-sourced data (canonical name, price, entry ID, provision type) to the workflow
7. Returns `catalogueEntry` summary in the response

**OrderDetails interface extended:** Four optional fields added to `barista.ts` — `catalogueEntryId`, `pricePence`, `priceDisplay`, `provisionType`. Backward-compatible (all optional).

**Composition builder TODO:** Added comment documenting the CDR price mismatch — archetype coded terms (£1.25–£2.85 size-based) don't match catalogue prices (£2.80 Flat White, etc.). Tagged for Phase 10.

**Verification:**
- "Flat White", medium — passed validation, reached Temporal (Internal Error because Temporal not running — correct)
- "Matcha Latte", medium — 400 "Item not found or not active: Matcha Latte"
- "Espresso", large — 400 "Invalid size 'large' for Espresso. Available: small"

**Commit:** `f9d481d` — CSW: order validation against catalogue

---

## Findings

### Docker Volume Lifecycle for Database Reset

To reset the business database seed data (e.g. after testing mutations), the correct sequence is: stop the container, **remove the container** (`docker compose rm -f`), remove the volume, then recreate. `docker compose stop` + `docker volume rm` fails because the stopped container still references the volume. The `rm -f` step removes the container reference, allowing the volume to be deleted.

```bash
docker compose -f docker-compose.ehrbase.yml rm -f coffeeshop-db \
  && docker volume rm coffeeshop-demonstrator_coffeeshop-pg-data \
  && docker compose -f docker-compose.ehrbase.yml up -d coffeeshop-db
```

### Dynamic SET Clause for Partial Updates

The `updateCatalogueEntry` and `updateInventory` methods build SQL SET clauses dynamically from the provided input fields. Each field present in the input adds a `field = $N` clause and pushes the value to the params array. The paramIndex counter ensures placeholders are sequential. This avoids updating fields that weren't specified (no null-overwrite of omitted fields).

The stock status auto-calculation in `updateInventory` has three cases: explicit status provided (use it), quantity changed without explicit status (auto-calculate from quantity vs threshold), neither (no-op). The auto-calculation considers both the new threshold (if provided) and the existing threshold (if not).

### Catalogue as Authoritative Price Source

With Phase 3, the catalogue is now the authoritative source of pricing truth. The order flow reads price from the catalogue lookup, and the Temporal workflow receives the catalogue-sourced price in its args. The CDR composition builder still uses its original coded terms (which are size-based, not item-based), creating a known mismatch. This is an intentional architectural decision: resolving the mismatch requires archetype redesign, which is out of scope. The mismatch is documented and tracked for Phase 10.

---

## Coffee Shop Demonstrator Extension

**Capability demonstrated:** Complete CRUD API for catalogue and inventory management with catalogue-validated order submission.

**What was built:** Five mutation methods in the database client, seven API route handlers across four URL patterns, order validation against the catalogue with size checking and inventory decrement.

**What was learned:**
- Docker container removal is required before volume deletion (stopped containers still hold volume references)
- Dynamic parameterised SET clauses work cleanly for partial updates
- Case-insensitive `LOWER()` SQL comparison handles user input normalisation at the database layer
- The `GREATEST(0, ...)` pattern prevents negative inventory from concurrent decrements

**Clinical implementation confidence:** High. The catalogue validation pattern maps directly to formulary validation in clinical ordering — confirming that a prescribed medication is on the formulary, available in the requested form/strength, and has stock. The inventory decrement pattern maps to pharmacy stock management.

---

## Architecture Notes

### API Surface Post Phase 3

| Method | Route | Purpose |
|---|---|---|
| GET | `/api/catalogue` | Active catalogue entries (default) or all (`?all=true`) |
| POST | `/api/catalogue` | Create item + catalogue entry (transactional) |
| GET | `/api/catalogue/[id]` | Single entry with full details |
| PUT | `/api/catalogue/[id]` | Update price, availability, status |
| GET | `/api/inventory` | All records, or low-stock only (`?low=true`) |
| GET | `/api/inventory/[id]` | Single inventory record |
| PUT | `/api/inventory/[id]` | Stock adjustment with auto-calculated status |
| POST | `/api/orders` | Place order (catalogue-validated, inventory-aware) |

### Breaking Change

`POST /api/orders` now rejects items not in the active catalogue. Previously any string was accepted for `drinkType`. This is intentional — the catalogue is the source of truth.

### Known Limitations

**CDR price mismatch:** Composition builder uses coded terms (£1.25–£2.85) that don't match catalogue prices (£2.00–£4.20). Tagged for Phase 10.

**Food item workflow:** `FulfilDrink` is drink-specific. Food items pass catalogue validation and have inventory decremented, but the Temporal workflow will fail during drink-specific activities. A generic `FulfilOrder` workflow is a future concern.

**Partial transactional coverage:** The order flow (catalogue lookup → inventory decrement → Temporal start) is not fully transactional across persistence layers. If the workflow start fails after inventory decrement, stock is decremented without a corresponding order. Acceptable for the demonstrator; saga pattern or compensating transaction for GSL.

---

## Git Log

| Commit | Description |
|---|---|
| `8b90a68` | CSW: mutation methods and order validation in postgres-client |
| `c7488c3` | CSW: catalogue and inventory CRUD API routes |
| `f9d481d` | CSW: order validation against catalogue |

---

## Next Session

Continue CSW Extension workstream — **Phase 4: Frontend Foundation**:
- Install Tailwind v4 + Flowbite Svelte into `@coffeeshop/web`
- Create `app.css` with Tailwind v4 + coffee shop theme palette
- Build layout shell: Flowbite Sidebar + Navbar replacing pipe-delimited nav
- Navigation: Operations, Management, Data & Insights, System sections
- Verify dark mode toggle, existing API routes unaffected

Phase 4 implementation plan: `gsl-plan-workstream-csw-extension-2026-03-12.md` §Phase 4.

---

## Syntax Reference

No update required — no SysML changes in this phase.

---

*Session 22 report prepared 12 March 2026.*
