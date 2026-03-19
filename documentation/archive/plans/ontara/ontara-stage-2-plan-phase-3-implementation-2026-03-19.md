# Ontara — Stage 2 Phase 3 Implementation Plan: Suds Full BMM Coverage

**Date:** 19 March 2026 (Session 41)
**Prepared by:** Claude, in discussion with Ella Green
**Status:** For review and agreement before implementation
**Parent plan:** [[ontara-stage-2-plan-2026-03-19|Stage 2 Detailed Implementation Plan]]
**Scope:** Phase 3 — Expand Suds model to full BMM coverage, write Suds design note

---

## 1. Objective

Expand the Suds demonstrator model to cover all BMM `part def`s at comparable depth to CSW, applying `@CatalogueTag` to any new Suds-specific `part def`s (if any emerge). Write the Suds design note documenting which BMM elements are General and which needed domain-specific adaptation. Re-run the generator and verify the expanded content appears correctly in the console.

This phase directly exercises [[concept-cross-domain-validation|J1]] (cross-domain validation), [[concept-co-evolution|J2]] (co-evolution), [[principle-coffeeshop-first|A5]] (validate in toy domains), and is the primary evidence for whether the BMM vocabulary generalises.

---

## 2. Coverage Audit — What Exists and What's Missing

### Current Suds State (Session 37, 39 elements)

Three packages: `SudsBusinessModel`, `SudsResourceFinancial`, `SudsGovernance`. Coverage is strong across ServiceConcept (value proposition, 3 offerings, 2 segments, 2 channels), ActivityModel (10 activity types across all 5 categories, 5 granularity policies), ResourcePlanning (6 resource types, 1 capability, 1 capacity model, 1 constraint), and FinancialPlanning (1 revenue stream, 4 cost drivers, 1 unit economics, 1 pricing model).

### Gaps Against CSW (by BMM `part def`)

| `part def` | CSW instances | Suds instances | Gap | Action |
|---|---|---|---|---|
| **DifferentiationClaim** | 2 (GSL-level) | 0 | ❌ | Add 2 Suds claims |
| **CatalogueEntry** | 11 (typed CoffeeShop::CatalogueEntry) | 0 | ❌ | Add 3 Suds entries using generic BMM CatalogueEntry |
| **ExternalReference** | 1 (CSW domain-level) | 0 | ❌ | Add 2 Suds references |
| **ActivityCostAllocation** | 0 | 0 | Both missing (O6) | Add 2 Suds instances — new ground |
| **ActivityRecord** | 0 | 0 | Both missing (O6) | Defer — runtime concern, not planning-level |
| **ActivityBudget** | 0 | 0 | Both missing (O6) | Defer — requires operational data to be meaningful |
| **InventoryRecord** | 0 | 0 | Both missing (O6) | Defer — operational tracking, not business model planning |
| **ResourceInstance** | 0 (CSW) | 0 | Neither has | Defer — planning-level archetypes less relevant to toy domains |
| **ObjectiveCapabilityMapping** | 4 (GSL-level) | 0 | GSL-specific | Skip — strategic objectives pattern doesn't apply to toy demonstrators |
| **FinancialProjection** | 0 (CSW) | 0 | Neither has at domain level | Skip — projections are GSL-level |

### Also in Scope

- **ValueProposition:** Suds has 1 (adequate but thin). Consider whether a second strengthens the model.
- **UnitEconomics:** Suds has 1 (standard wash). Add delicates and express for completeness.

---

## 3. Design Decisions

| # | Decision | Rationale |
|---|---|---|
| **P3-D1** | Use generic `BusinessModel::ServiceConcept::CatalogueEntry` for Suds, not a domain-typed specialisation | CSW uses `CoffeeShop::CatalogueEntry` (which has `ref item : MenuItem`). Suds has no domain model package with item definitions. Using the generic `part def` directly is a stronger generalisation test — it validates that `CatalogueEntry` works without domain-specific typing. |
| **P3-D2** | Add `ExternalReference` instances in `SudsGovernance` package | COSHH safety data sheets and HSE guidance are governance-adjacent references. Placing them in `SudsGovernance` keeps the governance story coherent. |
| **P3-D3** | Add `ActivityCostAllocation` instances in `SudsBusinessModel` alongside existing activity types | These link activity types to financial costs — the missing bridge between ActivityModel and FinancialPlanning. Suds will be the first domain to exercise this `part def`. |
| **P3-D4** | Add 2 more `UnitEconomics` instances (delicates, express) | CSW has only 1 service offering so only needs 1. Suds has 3 offerings with meaningfully different economics — exercising the `part def` with variant pricing/cost profiles. |
| **P3-D5** | No new `part def`s expected — all additions are `part` usages of existing BMM `part def`s | Suds is exercising the General vocabulary. If anything doesn't fit, that's a General/Tailored observation for the design note, not a reason to create Suds-specific `part def`s. |
| **P3-D6** | Import `Foundation::MetadataLibrary::*` in each Suds package that needs it | Required for any `@CatalogueTag` or `@UserFacing` usage. Currently neither Suds package imports it — but since we're adding `part` usages (not `part def`s), and tags go on `part def`s, this import may not be needed. Confirm during implementation. |
| **P3-D7** | `SudsBusinessModel` needs `import BusinessModel::ServiceConcept::CatalogueEntry` and `BusinessModel::ServiceConcept::ExternalReference` | New imports required for the CatalogueEntry and ExternalReference usages. Note the name collision issue from CSW — Suds doesn't have a domain package so no collision, but use fully qualified names defensively in import comments. |

---

## 4. Implementation Chunks

### Chunk 1: DifferentiationClaim Instances (SudsBusinessModel)

Add 2 `DifferentiationClaim` instances to `SudsBusinessModel`.

**New imports required:** `BusinessModel::ServiceConcept::DifferentiationClaim` — but this is already covered by the existing `private import BusinessModel::ServiceConcept::*`.

**Content:**

```sysml
part reliableTurnaround : DifferentiationClaim {
    attribute :>> claimName = "Reliable turnaround times";
    attribute :>> statement = "We guarantee same-day for express and next-day for standard — or the service is free";
    attribute :>> basis = "Process design with batch scheduling and capacity management ensures predictable turnaround";
    attribute :>> testability = "Track turnaround times per order; measure percentage meeting SLA; refund rate";
}

part transparentPricing : DifferentiationClaim {
    attribute :>> claimName = "Transparent per-kg pricing";
    attribute :>> statement = "Simple, clear pricing with no hidden charges — weighed in front of you at drop-off";
    attribute :>> basis = "Per-kg model with published surcharge schedule; weight recorded at intake";
    attribute :>> testability = "Customer pricing complaints; price clarity in customer feedback surveys";
}
```

**Placement:** After the existing `onlineBooking` Channel instance, before the Activity Model section comment.

---

### Chunk 2: CatalogueEntry Instances (SudsBusinessModel)

Add 3 `CatalogueEntry` instances for the three service offerings. These use the generic BMM `CatalogueEntry` — no domain-typed specialisation.

**New imports required:** `BusinessModel::ServiceConcept::CatalogueEntry` is already covered by the wildcard import.

**Content:**

```sysml
// -- Catalogue Entries ------------------------------------
//
// Service offerings as catalogue items. Uses the generic
// BMM CatalogueEntry directly — no domain-typed specialisation.
// This tests whether CatalogueEntry generalises beyond
// product menus to service catalogues.

part standardWashCatalogue : CatalogueEntry {
    doc /* Standard wash offering as a catalogue entry.
         * Per-kg pricing, no minimum for walk-in. */
    attribute :>> entryName = "Standard Wash";
    attribute :>> itemReference = "standardWash";
    attribute :>> pricingDescription = "£2.50 per kg";
    attribute :>> availabilityStatus = "active";
    attribute :>> provisionType = "service";
    attribute :>> effectiveDate = "2026-03-19";
    attribute :>> statusNotes = "Core offering — available daily";
}

part delicatesWashCatalogue : CatalogueEntry {
    doc /* Delicates wash — specialist handling, higher price. */
    attribute :>> entryName = "Delicates Wash";
    attribute :>> itemReference = "delicatesWash";
    attribute :>> pricingDescription = "£3.75 per kg (+50% surcharge)";
    attribute :>> availabilityStatus = "active";
    attribute :>> provisionType = "service";
    attribute :>> effectiveDate = "2026-03-19";
    attribute :>> statusNotes = "Specialist handling — lower temperature, gentle cycle";
}

part expressWashCatalogue : CatalogueEntry {
    doc /* Express wash — same-day premium service. */
    attribute :>> entryName = "Express Wash";
    attribute :>> itemReference = "expressWash";
    attribute :>> pricingDescription = "£5.00 per kg (+100% surcharge)";
    attribute :>> availabilityStatus = "active";
    attribute :>> provisionType = "service";
    attribute :>> effectiveDate = "2026-03-19";
    attribute :>> statusNotes = "Same-day 4-hour turnaround guarantee";
}
```

**Placement:** After the Differentiation Claims, before the Activity Model section.

**Design note observation:** The generic `CatalogueEntry` has `provisionType : String` (free text), while the CSW domain specialisation uses `provisionType : ProvisionType` (a typed enum: prepared, boughtIn, hybrid). For Suds, "service" is a natural value — services are neither "prepared" nor "boughtIn" in the CSW sense. This is a **General/Tailored observation**: the `provisionType` attribute works across domains, but the values are domain-specific. A future tag dimension could capture provision type taxonomy.

---

### Chunk 3: ExternalReference Instances (SudsGovernance)

Add 2 `ExternalReference` instances in `SudsGovernance`.

**New import required:** `BusinessModel::ServiceConcept::ExternalReference` — add to `SudsGovernance` package.

**Content:**

```sysml
part coshhGuidance : ExternalReference {
    doc /* HSE COSHH guidance — the primary regulatory reference
         * for handling cleaning chemicals in a workplace. */
    attribute :>> referenceType = "regulatory guidance";
    attribute :>> referenceId = "HSE-COSHH-2002";
    attribute :>> referenceSource = "Health and Safety Executive — www.hse.gov.uk/coshh";
    attribute :>> referenceNotes = "COSHH Regulations 2002. Employer duties for substances hazardous to health. Risk assessment, safe storage, training, PPE.";
}

part detergentSafetyDataSheet : ExternalReference {
    doc /* Safety Data Sheet (SDS) for commercial laundry
         * detergent — specific to supplier and product.
         * COSHH requires current SDS for every chemical used. */
    attribute :>> referenceType = "safety data sheet";
    attribute :>> referenceId = "SDS-DETERGENT-001";
    attribute :>> referenceSource = "Supplier-provided — updated annually";
    attribute :>> referenceNotes = "Mandatory under COSHH. Covers composition, hazards, first aid, handling, storage, exposure controls, disposal.";
}
```

**Placement:** After the existing `coshhCompliance` requirement, before the closing `}` of `SudsGovernance`.

---

### Chunk 4: ActivityCostAllocation Instances (SudsBusinessModel)

Add 2 `ActivityCostAllocation` instances — Suds will be the **first domain** to exercise this `part def`. This is new ground (contributes to resolving O6).

**New import required:** `BusinessModel::ActivityModel::ActivityCostAllocation` is already covered by the existing wildcard import.

**Content:**

```sysml
// -- Activity cost allocations ----------------------------
//
// The bridge between ActivityModel and FinancialPlanning.
// Suds is the first domain to exercise ActivityCostAllocation.

part washCycleCostAllocation : ActivityCostAllocation {
    doc /* Cost allocation for the wash cycle activity. Variable
         * costs: utilities (water, electricity) and chemicals
         * per kg of laundry processed. */
    attribute :>> activityType = "Wash cycle";
    attribute :>> allocationMethod = "per-kg variable cost";
    attribute :>> estimatedCostPerUnit = 1.00;
    attribute :>> costNotes = "Utilities £0.60/kg + chemicals £0.40/kg. Machine lease costs allocated separately as fixed overhead.";
}

part receiveAndTagCostAllocation : ActivityCostAllocation {
    doc /* Cost allocation for receive-and-tag. Pure labour cost
         * at operator hourly rate, prorated per order. */
    attribute :>> activityType = "Receive and tag items";
    attribute :>> allocationMethod = "labour time allocation";
    attribute :>> estimatedCostPerUnit = 1.92;
    attribute :>> costNotes = "10 min at £11.50/hr = £1.92 per order. Direct labour, no materials.";
}
```

**Placement:** After the granularity policies, before the closing `}` of `SudsBusinessModel`.

---

### Chunk 5: Additional UnitEconomics Instances (SudsResourceFinancial)

Add 2 more `UnitEconomics` instances for delicates and express services.

**Content:**

```sysml
part delicatesWashEconomics : UnitEconomics {
    doc /* Per-kg economics for delicates wash. Higher revenue
         * (£3.75/kg) but also higher cost due to specialist
         * handling and longer cycle times. */
    attribute :>> offeringRef = "Delicates wash";
    attribute :>> revenuePerUnit = 3.75;
    attribute :>> costPerUnit = 2.20;
    attribute :>> marginPerUnit = 1.55;
    attribute :>> breakdownNotes = "Labour £0.80/kg (slower handling), utilities £0.60/kg, specialist chemicals £0.50/kg, pressing £0.30/kg. Rent and lease excluded.";
}

part expressWashEconomics : UnitEconomics {
    doc /* Per-kg economics for express wash. Double the standard
         * price, but same direct costs — the premium covers
         * opportunity cost of priority scheduling. */
    attribute :>> offeringRef = "Express wash";
    attribute :>> revenuePerUnit = 5.00;
    attribute :>> costPerUnit = 1.70;
    attribute :>> marginPerUnit = 3.30;
    attribute :>> breakdownNotes = "Same direct costs as standard (£1.50/kg) + priority scheduling overhead £0.20/kg. Premium pricing covers scheduling disruption.";
}
```

**Placement:** After the existing `standardWashEconomics`, before the pricing model section.

---

### Chunk 6: Re-run Generator, Verify in Console

1. Run `gen_model_introspection.py` from repo root.
2. Copy output to `console/static/data/`.
3. Verify in console:
   - Coverage matrix: Suds column should show new green cells for DifferentiationClaim, CatalogueEntry, ExternalReference, ActivityCostAllocation.
   - Component Catalogue: new Suds instances should appear in element detail panels.
4. Check element counts: Suds should go from ~39 to ~50+ elements.
5. Verify no regressions in CSW or core model data.

---

### Chunk 7: Suds Design Note

Write the Suds design note at `Demonstrators/Suds (Laundry)/suds-domain-design.md` in the Obsidian vault. Content:

1. **Domain description** — what Suds is and why it was chosen as a demonstrator.
2. **Structural differences from CSW** — pricing model, process shape, item tracking, scheduling.
3. **BMM coverage summary** — which `part def`s are instantiated, which are not and why.
4. **General/Tailored observations** — the key Phase 3 finding:
   - Which BMM elements transferred directly (General)?
   - Which needed adaptation or exposed vocabulary gaps (Tailored potential)?
   - Specific observations on CatalogueEntry generalisation (product vs service catalogue), provisionType values, ActivityCostAllocation as new ground.
5. **Meta model gaps exposed** — anything Suds needs that the BMM doesn't express.
6. **Cross-domain comparison methodology** — what worked, what to improve for Paws.

---

## 5. Estimated Element Additions

| Chunk | New elements | Type |
|---|---|---|
| Chunk 1: DifferentiationClaim | 2 | `part` usages |
| Chunk 2: CatalogueEntry | 3 | `part` usages |
| Chunk 3: ExternalReference | 2 | `part` usages |
| Chunk 4: ActivityCostAllocation | 2 | `part` usages |
| Chunk 5: UnitEconomics | 2 | `part` usages |
| **Total** | **11** | All `part` usages |

Suds element count: ~39 → ~50. No new `part def`s — all additions are instances of existing General BMM vocabulary.

---

## 6. Files Modified

| File | Changes |
|---|---|
| `exercises/suds-demonstrator/model/suds.sysml` | Chunks 1–5: new `part` usages in `SudsBusinessModel`, `SudsResourceFinancial`, `SudsGovernance` |
| `generated/ontara/model-introspection.json` | Chunk 6: regenerated |
| `console/static/data/model-introspection.json` | Chunk 6: updated copy |

**Files created:**
| File | Location |
|---|---|
| Suds design note | Obsidian: `Demonstrators/Suds (Laundry)/suds-domain-design.md` |

---

## 7. Claude Chat / Code / Cowork Suitability

| Chunk | Best suited to | Rationale |
|---|---|---|
| Chunk 1: DifferentiationClaim | **Claude Chat** | Content requires design judgement — what differentiates a laundry? |
| Chunk 2: CatalogueEntry | **Claude Chat** | Design decision P3-D1 needs careful handling; content is straightforward but placement and import considerations need attention |
| Chunk 3: ExternalReference | **Claude Chat** | Small, requires governance context understanding |
| Chunk 4: ActivityCostAllocation | **Claude Chat** | New ground — first domain to exercise this `part def`; cost calculations need to be internally consistent with existing Suds financial data |
| Chunk 5: UnitEconomics | **Claude Chat** | Financial consistency with existing pricing and cost data |
| Chunk 6: Generator + verify | **Claude Code** | Mechanical: run script, copy output, verify counts. Claude Code instruction: "cd to repo root. Run `python scripts/gen_model_introspection.py`. Copy `generated/ontara/model-introspection.json` to `console/static/data/model-introspection.json`. Report element counts by domain and verify Suds count has increased." |
| Chunk 7: Suds design note | **Claude Chat** | Analytical writing requiring synthesis of observations from Chunks 1–5 |

---

## 8. Verification Checklist

- [ ] `suds.sysml` parses in Syside with no errors (Ella)
- [ ] All 11 new `part` usages correctly instantiate their BMM `part def`s
- [ ] No new imports cause name collisions
- [ ] Generator runs without errors and produces updated JSON
- [ ] Suds element count in JSON ≥ 50
- [ ] Coverage matrix shows new green cells for DifferentiationClaim, CatalogueEntry, ExternalReference, ActivityCostAllocation
- [ ] Component Catalogue shows Suds instances in element detail panels
- [ ] No regressions in CSW or core model data
- [ ] Financial figures internally consistent (cost allocations align with cost drivers and unit economics)
- [ ] Suds design note written with General/Tailored observations
- [ ] Master register updated (O6 partial, O13 updated)

---

## 9. Register Concepts Exercised

| Concept | How |
|---|---|
| [[concept-cross-domain-validation|J1]] (cross-domain validation) | Full BMM coverage comparison CSW ↔ Suds |
| [[concept-co-evolution|J2]] (co-evolution) | Model expansion + generator re-run + console verification |
| [[principle-coffeeshop-first|A5]] (validate in toy domains) | Suds as second validation domain |
| B11 (General/Tailored) | Discovered through CatalogueEntry and provisionType observations |
| [[concept-tagging-system|I10]] (tagging system) | No new tags needed — all additions are `part` usages, not `part def`s |
| [[concept-governance-in-toy-domains|J8]] (governance in toy domains) | ExternalReference instances strengthen governance story |
| A8 (governance first-class) | ExternalReference for COSHH adds audit evidence references |

**O6 update:** ActivityCostAllocation now has 2 Suds instances — first domain to exercise this `part def`. ActivityRecord, ActivityBudget, InventoryRecord remain uninstantiated.

---

## 10. What This Chunk Defers

- **Phase 6 (governance traceability):** The `satisfy` chain (requirement → constraint → audit evidence) is a separate phase. Chunk 3 adds ExternalReference instances that will become evidence targets in Phase 6.
- **ActivityRecord / ActivityBudget / InventoryRecord:** Remain uninstantiated (O6). These are runtime/operational concepts less natural for a planning-level demonstrator.
- **ResourceInstance:** Neither domain exercises this. Would require more operational detail than the demonstrator scope warrants.
- **PersistencePolicy for Suds:** BSMM concept — out of Phase 3 BMM scope.
- **Second ValueProposition:** Current single VP is adequate; Suds's differentiation is captured in DifferentiationClaim instead.

---

*Phase 3 implementation plan prepared 19 March 2026 (Session 41). For review and agreement before implementation begins.*
