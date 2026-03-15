# CSW Extension Phase 10: Meta Model Update — Detailed Implementation Plan

**Workstream:** Coffee Shop Extension — Catalogue, Inventory & Frontend
**Phase:** 10 of 10 (final phase)
**Date:** 14 March 2026
**Session:** 29
**Prerequisites:** Phases 1–9 complete (Sessions 20–28)
**Source plan:** `gsl-plan-csw-extension-workstream-2026-03-12.md` §Phase 10
**Work analysis items:** 8.1 (CatalogueEntry + ExternalReference), 8.2 (InventoryRecord), 8.3 (PersistencePolicy), 9.1 (AgencyClassification), 9.2 (AuthorityModelVersion)
**Estimated effort:** 6 stages across 3–4 commits

---

## Goal

Phase 10 closes the CSW Extension workstream by identifying which findings from the exercise are generic meta model concepts — applicable to any service business or any business system — and formalising them in the appropriate meta model. Phases 1–9 validated domain concepts, architectural patterns, and implementation approaches in the coffee shop demonstrator. Phase 10 lifts the generic abstractions from those validated instances into the meta models that all domains (GSL clinical services, coffee shop, addictions, others) inherit from.

### The two meta models

The project maintains two distinct meta models (per `gsl-service-business-meta-modelling.md` §1):

- **Business Meta Model** — the structural template for "what a service business is": service concept, financial model, resource and capability model, activity taxonomy, governance and adaptation. Captures the strategic logic of the enterprise. Lives primarily in the `BusinessModel` package (ServiceConcept, ActivityModel, ResourcePlanning, FinancialPlanning) and in `BusinessScenarios` and `BusinessStrategy`.

- **Business System Meta Model** — the structural template for "how a business system works": processes, platform, data architecture, knowledge layer, operations, governance mechanisms. Captures the operational machinery that implements the business model. Currently implicit across Foundation, Platform, ServiceDelivery, Knowledge, and Operations — not yet extracted as a named meta model, but its concepts are real and growing (see `gsl-service-business-meta-modelling.md` §1: "deferred, to be extracted from the maturing GSL system model").

These are two distinct meta models connected by explicit mappings. Maintaining the distinction is essential: a business model change (pricing strategy) may or may not require a system change; a system architecture change (persistence technology) should not alter the business model. The meta model boundary tells you which side of that line a concept lives on.

### What Phase 10 adds, and to which meta model

| Concept | Meta model | Package | Rationale |
|---|---|---|---|
| `CatalogueEntry` | **Business** | BusinessModel::ServiceConcept | Any service business that offers items needs the item→catalogue layering. This is the "what the business offers" concern — a business model structural template. |
| `ExternalReference` | **Business** | BusinessModel::ServiceConcept | Any business links to external knowledge. The system doesn't own this data; it points to it. This is a business model concern about knowledge relationships. |
| `InventoryRecord` | **Business** | BusinessModel::ResourcePlanning | Any business that stocks things tracks inventory at the planning level. Inventory is a resource concern in the business model ("stock tracking is a resource need for this business"). |
| `PersistencePolicy` | **System** | Foundation::CommonTypes | Where data lives and why is a system architecture concern. The business model doesn't care whether data lives in PostgreSQL or a CDR — it cares about service concept and financial viability. PersistencePolicy describes architectural reasoning about implementation. Placed in Foundation for practical reasons (cross-cutting, importable everywhere). |
| `AgencyClassification` | **System** | Foundation::MetadataLibrary | Who performs an action is a system delivery concern — it annotates how the delivery system executes pathway steps. Placed in Foundation as metadata because it annotates action nodes across all packages. |

This phase also incorporates the **Phase 10 companion pieces** identified in the work analysis: `AgencyClassification` metadata (item 9.1) and `AuthorityModelVersion` (item 9.2) from the Self-Service Enabling Architecture discussion paper (Session 25). These are natural companions — all add definitions to Foundation or BusinessModel.

### What does not change

No demonstrator code changes. No frontend or backend modifications. No generator changes. This is a pure model phase.

---

## Architecture Overview

### Files Modified

| File | Changes | Meta model |
|---|---|---|
| `model/foundation.sysml` | New: `PersistencePolicy` part def, `PersistenceLayer` enum, `DataCharacteristic` enum (in CommonTypes). New: `AgencyClassification` metadata def, `AgencyType` enum (in MetadataLibrary). | System |
| `model/business-model.sysml` | New: `CatalogueEntry` part def, `ExternalReference` part def (in ServiceConcept). New: `InventoryRecord` part def (in ResourcePlanning). | Business |
| `exercises/.../coffeeshop-business-model.sysml` | New: `PersistencePolicy` instances for each CSW domain concept (6 policies). | CSW instantiation of system meta model concepts |

### No Files Created

All new content goes into existing packages. No new `.sysml` files are needed.

### Design Principles for Phase 10

1. **Meta model, not domain model.** Phase 1 (Session 20) added `CatalogueEntry`, `InventoryRecord`, `ExternalReference` to the *coffee shop* domain model (`CoffeeShop` package). Phase 10 adds the *generic* abstractions to the *meta models*. These are `part def`s, not usages — they define the shapes that any domain instantiates. The CSW domain model's types are the instances; the meta model types are the definitions.

2. **Respect the business / system boundary.** Concepts that describe what the business offers (catalogue, inventory, external references) go in the business meta model. Concepts that describe how the system implements the business (persistence policy, agency classification) go in the system meta model's current home (Foundation). This distinction must be maintained — it is the architectural guarantee that business model changes and system changes can be iterated independently.

3. **Domain-agnostic naming.** All new part defs and enums use generic terms — `CatalogueEntry` not `FormularyEntry`, `InventoryRecord` not `StockRecord`, `AgencyType` not `ClinicalRole`. Healthcare specifics arise only when GSL instantiates these abstractions.

4. **Consistent with existing patterns.** New part defs follow the established pattern: `doc` block, named attributes with `String`/`Integer`/enum types, cross-references via `ref`. No new SysML language features.

5. **Prepare for the system meta model extraction.** The business system meta model is currently implicit. Phase 10 adds to it (PersistencePolicy, AgencyClassification) with explicit doc blocks noting that these are system meta model concepts placed in Foundation for practical reasons. When the system meta model is eventually extracted as a named concern, these elements will migrate naturally.

---

## Risk Assessment

### R1: Package placement decisions

**Risk:** Where exactly do `CatalogueEntry`, `ExternalReference`, and `InventoryRecord` live within the business meta model?

**Resolution:** Keep it simple. `CatalogueEntry` and `ExternalReference` go into `ServiceConcept` — they are part of the service concept concern (what the business offers). `InventoryRecord` goes into `ResourcePlanning` — it is operational resource tracking. No new sub-packages.

### R2: PersistencePolicy location

**Risk:** Foundation vs Platform.

**Resolution:** Foundation. `PersistencePolicy` is a cross-cutting system meta model concern importable everywhere. Foundation::CommonTypes is the established home for cross-cutting types. The doc block will explicitly note this is a business system meta model concept.

### R3: AgencyClassification as metadata def vs part def

**Risk:** The self-service discussion paper (§7.4) shows `AgencyClassification` as a metadata def applied to action nodes.

**Resolution:** Metadata def. It annotates pathway action nodes — same pattern as `@TemporalActivity`, `@ClinicalReviewGate`. The `AgencyType` enum lives in MetadataLibrary alongside the metadata def.

### R4: Syside validation of new metadata def with enum-typed attribute

**Risk:** Syntax reference TODO notes that `metadata def` with non-scalar attribute types is unverified. `AgencyClassification` needs `agencyType : AgencyType`.

**Resolution:** Proceed and verify. If Syside rejects it, fall back to `String` with documented valid values. Either outcome is a valuable syntax finding.

### R5: Cross-package import for PersistencePolicy instances

**Risk:** Coffee shop business model needs Foundation::CommonTypes imports.

**Resolution:** Pattern already established — the coffee shop business model already imports from BusinessModel packages. Adding Foundation::CommonTypes follows the same mechanism.

---

## Stages

### Stage 1: Foundation — PersistencePolicy and Supporting Types (System Meta Model)

**Goal:** Add the persistence strategy abstraction to Foundation::CommonTypes. These are **business system meta model** concepts — they describe how the system is architected, not what the business offers.

**Work:**

1. Read the syntax reference before writing SysML.

2. Add to `Foundation::CommonTypes`:

```sysml
// -- Persistence architecture types -------------------------
// Business system meta model concepts: describe where domain
// data lives and why. Cross-cutting — importable by any package.
// Source: gsl-spec-catalogue-inventory-v2.1.md §8.3
// Meta model: Business System (placed in Foundation for
// practical cross-cutting access; will migrate when the
// system meta model is extracted as a named package).

enum def PersistenceLayer {
    doc /* The persistence technology layer where a domain
         * concept is stored. Each layer has distinct
         * characteristics. */
    clinicalDataRepository;
    businessDatabase;
    processEngine;
    externalReference;
}

enum def DataCharacteristic {
    doc /* Distinguishing characteristics that determine the
         * natural persistence home for a domain concept. */
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
    doc /* Maps a domain concept to its persistence layer, with
         * explicit rationale expressed as distinguishing
         * characteristics. Makes architectural reasoning
         * queryable and auditable.
         *
         * Business system meta model concept: describes how
         * the system is architected, not what the business
         * offers. Any service business system that uses
         * multiple persistence technologies needs this.
         *
         * Source: gsl-spec-catalogue-inventory-v2.1.md §8.3 */
    attribute domainConcept : String;
    attribute targetLayer : PersistenceLayer;
    attribute rationale : String;
    attribute characteristics : DataCharacteristic [1..*];
}
```

3. Verify in Syside. Check `DataCharacteristic [1..*]` multiplicity.

**Commit point:** Combined with Stage 2.

---

### Stage 2: Foundation — AgencyClassification Metadata (System Meta Model)

**Goal:** Add agency classification metadata. **Business system meta model** concepts — annotate how the delivery system executes steps. Items 9.1 + 9.2.

**Work:**

1. Add to `Foundation::MetadataLibrary`:

```sysml
// -- Agency classification metadata -----------------------
// Business system meta model concepts: annotate pathway
// action nodes with the agent who performs them.
// Source: gsl-discussion-model-self-service-enabling-
//   architecture-2026-03-14.md §7
// Meta model: Business System (placed in Foundation
// MetadataLibrary as cross-cutting metadata).

enum def AgencyType {
    doc /* Who performs an action in a pathway. Domain-agnostic.
         * Coffee shop: customer, staff, system, collaborative.
         * Clinical: patient, clinician, system, collaborative. */
    patient;
    clinician;
    system;
    collaborative;
}

metadata def AgencyClassification {
    doc /* Annotates a pathway action node with the agent who
         * performs it. The authorityModelVersion records which
         * generation's authority rules were in effect.
         *
         * Business system meta model concept. Prerequisite
         * for all four generations of self-service.
         *
         * Initial version: "G1-clinician-authority".
         *
         * Verified: [to be confirmed this session] */
    attribute agencyType : AgencyType;
    attribute authorityModelVersion : String;
    attribute agencyNotes : String;
}
```

2. If `agencyType : AgencyType` fails, fall back to `String`. Document either way.

3. Verify in Syside.

**Commit:** `"Foundation: PersistencePolicy, AgencyClassification — system meta model concepts (CSW Phase 10, Stages 1-2)"`

---

### Stage 3: BusinessModel — CatalogueEntry and ExternalReference (Business Meta Model)

**Goal:** Add catalogue abstractions to the **business meta model**.

**Work:**

1. Add to `BusinessModel::ServiceConcept`:

```sysml
// -- Catalogue and external reference abstractions ----------
// Business meta model concepts: what any service business
// offers and how it links to external knowledge.
// Four-layer model: Item → CatalogueEntry → InventoryRecord
//   → ExternalReference
// Source: gsl-spec-catalogue-inventory-v2.1.md §8.1

part def CatalogueEntry {
    doc /* The business decision to offer an item for sale.
         * Business meta model concept: describes what the
         * business offers, not how the system stores it.
         * Domain-specific types (CoffeeShop::CatalogueEntry
         * with ref item : MenuItem) are typed specialisations.
         *
         * Source: gsl-spec-catalogue-inventory-v2.1.md §8.1 */
    attribute entryName : String;
    attribute itemReference : String;
    attribute pricingDescription : String;
    attribute availabilityStatus : String;
    attribute provisionType : String;
    attribute effectiveDate : String;
    attribute statusNotes : String;
}

part def ExternalReference {
    doc /* A link to knowledge outside the system.
         * Business meta model concept.
         *
         * Source: gsl-spec-catalogue-inventory-v2.1.md §2.3 */
    attribute referenceType : String;
    attribute referenceId : String;
    attribute referenceSource : String;
    attribute referenceNotes : String;
}
```

2. Verify in Syside.

**Commit point:** Combined with Stage 4.

---

### Stage 4: BusinessModel — InventoryRecord (Business Meta Model)

**Goal:** Add inventory tracking to the **business meta model**.

**Work:**

1. Add to `BusinessModel::ResourcePlanning`:

```sysml
// -- Inventory tracking abstraction -------------------------
// Business meta model concept: operational stock tracking.
// Source: gsl-spec-catalogue-inventory-v2.1.md §8.2

part def InventoryRecord {
    doc /* A point-in-time record of stock level for a
         * catalogue item. Business meta model concept.
         *
         * Distinct from ResourceInstance (strategic planning).
         * InventoryRecord is operational tracking.
         *
         * Source: gsl-spec-catalogue-inventory-v2.1.md §8.2 */
    attribute catalogueEntryReference : String;
    attribute quantityOnHand : Integer;
    attribute stockStatus : String;
    attribute lowStockThreshold : Integer;
    attribute lastRestocked : String;
    attribute quantityNotes : String;
}
```

2. **ActivityType consideration:** No new abstract type needed. `ActivityType` is already generic.

3. Update `BusinessModel` package doc block.

4. Verify in Syside.

**Commit:** `"BusinessModel: CatalogueEntry, ExternalReference, InventoryRecord — business meta model (CSW Phase 10, Stages 3-4)"`

---

### Stage 5: Coffee Shop Business Model — PersistencePolicy Instances

**Goal:** Instantiate system meta model persistence policies for CSW domain concepts.

**Work:**

1. Add Foundation imports to `CoffeeShopBusinessModel`.
2. Add six persistence policy instances per spec §8.3.
3. Verify syntax for multi-valued enum attribute tuple literal. Fallback: `String`.
4. Verify in Syside.

**Commit:** `"CoffeeShop: PersistencePolicy instances for all domain concepts (CSW Phase 10, Stage 5)"`

---

### Stage 6: Polish, Verification, and Documentation

**Goal:** Final verification and documentation pass.

**Work:**

1. Full Syside verification across all `.sysml` files.
2. Doc block updates on `BusinessModel`, `Foundation::CommonTypes`, `Foundation::MetadataLibrary`.
3. Cross-reference check: meta model part defs vs coffee shop domain types.
4. Syntax reference update assessment.

**Commit:** `"Documentation: Phase 10 polish, verification, doc block updates (Session 29)"`

---

## Summary of New Model Elements

### Foundation::CommonTypes — Business System Meta Model (new)

| Element | Kind | Purpose |
|---|---|---|
| `PersistenceLayer` | enum def | Persistence technology layers |
| `DataCharacteristic` | enum def | Characteristics determining persistence home |
| `PersistencePolicy` | part def | Domain concept → persistence layer with rationale |

### Foundation::MetadataLibrary — Business System Meta Model (new)

| Element | Kind | Purpose |
|---|---|---|
| `AgencyType` | enum def | Who performs an action |
| `AgencyClassification` | metadata def | Action node annotation with agency + authority version |

### BusinessModel::ServiceConcept — Business Meta Model (new)

| Element | Kind | Purpose |
|---|---|---|
| `CatalogueEntry` | part def | Business decision to offer an item |
| `ExternalReference` | part def | Link to external knowledge |

### BusinessModel::ResourcePlanning — Business Meta Model (new)

| Element | Kind | Purpose |
|---|---|---|
| `InventoryRecord` | part def | Operational stock tracking |

### CoffeeShopBusinessModel — Domain Instantiation (new)

| Element | Kind | Purpose |
|---|---|---|
| 6 × PersistencePolicy | part usages | Architectural reasoning per CSW domain concept |

---

## Syntax Investigations

| Pattern | Stage | Status | Fallback |
|---|---|---|---|
| Enum-typed attribute on `metadata def` | 2 | Unverified | String with documented values |
| Multi-valued enum attribute with tuple literal | 5 | Unverified | String comma-separated |

---

## What This Phase Does Not Do

- **No pathway annotations.** `AgencyClassification` defined but not yet applied.
- **No generator updates.** TypeScript type generator operates on domain model, not meta model.
- **No manifest update.** Manifest enrichment (4.3) is a separate workstream.
- **No new coffee shop domain types.** Typed specialisations already exist in `coffeeshop.sysml`.
- **No system meta model extraction.** Remains implicit with clear doc block annotations.

---

## Estimated Effort

| Stage | Focus | Meta model | Effort | Commit? |
|---|---|---|---|---|
| 1 | Foundation: PersistencePolicy + types | System | 30 min | Combined |
| 2 | Foundation: AgencyClassification | System | 30 min | ✓ |
| 3 | BusinessModel: CatalogueEntry + ExternalReference | Business | 20 min | Combined |
| 4 | BusinessModel: InventoryRecord | Business | 20 min | ✓ |
| 5 | Coffee shop: PersistencePolicy instances | Instantiation | 30 min | ✓ |
| 6 | Polish, verification, documentation | — | 20 min | ✓ |
| **Total** | | | **~2.5 hours** | **4 commits** |

---

## Post-Phase 10

Phase 10 completes the CSW Extension workstream. Candidate next workstreams include Knowledge Layer Increments 1–3, Pattern Catalogue, Model Consolidation Review, Structural Deepening, and System Meta Model Extraction (promoting implicit system meta model concepts into a named, navigable structure).

---

*Phase 10 implementation plan prepared 14 March 2026. Session 29.*
