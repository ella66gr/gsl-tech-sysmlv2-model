# CSW Extension Phase 3: Catalogue & Inventory API Routes — Detailed Implementation Plan

**Workstream:** Coffee Shop Extension — Catalogue, Inventory & Frontend
**Phase:** 3 of 10
**Date:** 12 March 2026
**Prerequisites:** Phase 2 complete (PostgreSQL foundation, Session 21)
**Source plan:** `gsl-plan-workstream-csw-extension-2026-03-12.md` §Phase 3
**Specification:** `gsl-spec-catalogue-inventory-v2.1.md`
**Status:** ✓ Complete (Session 22)
**Estimated effort:** 3 stages (actual: 3 stages)

---

*This plan was executed in Session 22. See `gsl-session-report-2026-03-12-s22.md` for execution details and findings. The plan below is preserved as-written for the project journal.*

---

## Goal

SvelteKit API endpoints for catalogue and inventory CRUD. Mutation methods added to the PostgreSQL client. Order submission rewired to validate against the catalogue (item must be active, size must be valid for that item). The system moves from read-only verification endpoints to a fully operational catalogue and inventory API.

---

## Stages Executed

### Stage 1: Mutation Methods in postgres-client.ts
- Transaction support via `withTransaction` helper
- Five new methods: `createCatalogueItem`, `updateCatalogueEntry`, `updateInventory`, `lookupActiveItemByName`, `decrementInventory`
- Five new input/result types
- Commit: `8b90a68`

### Stage 2: Catalogue & Inventory CRUD API Routes
- GET/POST `/api/catalogue`, GET/PUT `/api/catalogue/[id]`
- GET `/api/inventory` with `?low=true`, GET/PUT `/api/inventory/[id]`
- Full verification: create, update, stock adjustment, low-stock filter
- Commit: `c7488c3`

### Stage 3: Order Validation Against Catalogue
- `POST /api/orders` validates item against active catalogue
- Size validation against catalogue's `availableSizes`
- Inventory decrement for bought-in items
- Catalogue-sourced data passed to workflow args
- Commit: `f9d481d`

---

*Plan prepared and executed 12 March 2026. Phase 3 of the CSW Extension workstream.*
