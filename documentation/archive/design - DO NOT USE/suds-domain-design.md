# Suds Domain Design Note — Laundry Service Demonstrator

**Date:** 19 March 2026 (Session 41)
**Author:** Claude, in discussion with Ella Green
**Status:** Working document
**Scope:** Design observations from building the Suds demonstrator and expanding it to full BMM coverage (Stage 2 Phase 3)

---

## 1. Purpose

Suds is a drop-off laundry service demonstrator chosen to validate that the [[gsl-service-business-meta-modelling|Business Meta Model]] vocabulary generalises beyond the Coffee Shop (CSW) domain. The two domains are structurally different in ways that test the abstractions: CSW is immediate, per-item, walk-in; Suds is batch, per-kg, turnaround-based. If the same `part def`s accommodate both with only value changes, the BMM vocabulary is genuinely General.

This note documents what was discovered through the cross-domain comparison — which elements transferred directly, which required adaptation, and where the vocabulary showed gaps or friction.

---

## 2. Domain Description

**What Suds is:** A small independent drop-off laundry service. Customers bring bags of clothing and household textiles. The service washes, dries, presses, and returns them — standard next-day, delicates two-day, or express same-day.

**Why it was chosen:** Suds was selected alongside Paws (dog grooming) in Session 35 as a cross-domain validation pair for CSW. The selection criteria emphasised structural differences from a coffee shop:

- **Pricing model:** per-kg with surcharges (vs per-item fixed prices in CSW)
- **Process shape:** batch processing over hours, with items from multiple customers combined in machine loads (vs immediate 2-minute per-customer preparation in CSW)
- **Item tracking:** bag → individual items → batch grouping → return (vs order → single drink in CSW)
- **Scheduling:** turnaround-time promises and SLAs (vs walk-in, no scheduling in CSW)
- **Governance:** COSHH regulations for cleaning chemicals (vs food hygiene in CSW)

---

## 3. BMM Coverage Summary

### 3.1 Final Coverage (Post-Phase 3)

| BMM `part def` | Suds instances | CSW instances | Both covered? |
|---|---|---|---|
| **ServiceConcept** | | | |
| ValueProposition | 1 | 4 (incl. GSL) | ✅ |
| ServiceOffering | 3 | 1 (+ 5 GSL) | ✅ |
| CustomerSegment | 2 | 1 | ✅ |
| Channel | 2 | 1 | ✅ |
| DifferentiationClaim | 2 | 2 (GSL) | ✅ (Session 41) |
| CatalogueEntry | 3 | 11 | ✅ (Session 41) |
| ExternalReference | 2 | 1 (domain) | ✅ (Session 41) |
| **ActivityModel** | | | |
| ActivityType | 10 | 6 | ✅ |
| ActivityGranularity | 5 | 5 | ✅ |
| ActivityCostAllocation | 2 | 0 | Suds only (Session 41) |
| ActivityRecord | 0 | 0 | Both missing |
| ActivityBudget | 0 | 0 | Both missing |
| **ResourcePlanning** | | | |
| ResourceType | 6 | 4 | ✅ |
| Capability | 1 | 1 | ✅ |
| CapacityModel | 1 | 1 | ✅ |
| ResourceConstraint | 1 | 1 | ✅ |
| ResourceInstance | 0 | 0 (CSW) | Neither at domain level |
| InventoryRecord | 0 | 0 | Both missing |
| ObjectiveCapabilityMapping | 0 | 0 (CSW) | GSL-level concept |
| **FinancialPlanning** | | | |
| RevenueStream | 1 | 1 | ✅ |
| CostDriver | 4 | 3 | ✅ |
| UnitEconomics | 3 | 1 | ✅ (expanded Session 41) |
| PricingModel | 1 | 1 | ✅ |
| FinancialProjection | 0 | 0 (CSW) | Neither at domain level |

**Total Suds elements:** ~50 `part` usages across 3 packages (up from ~39 before Phase 3).

### 3.2 Elements Not Instantiated in Either Domain

ActivityRecord, ActivityBudget, and InventoryRecord remain uninstantiated in both CSW and Suds (O6). These are operational/runtime concepts — a planning-level demonstrator naturally exercises the planning vocabulary (what the business *is*) rather than the tracking vocabulary (what the business *records at runtime*). ResourceInstance and FinancialProjection are exercised at the GSL level but not at the toy domain level — they require more strategic depth than a demonstrator warrants.

---

## 4. General/Tailored Observations

This is the core Phase 3 finding: what the cross-domain comparison reveals about the BMM vocabulary.

### 4.1 Unambiguously General — Transferred Directly

The following `part def`s transferred from CSW to Suds with only value changes and no structural friction. These are confidently **General**:

- **ServiceOffering** — offeringName, description, scope, pricingBasis, estimatedDurationWeeks, clinicalPathwayRef all accommodate both domains. The attribute names remain meaningful (even `clinicalPathwayRef` — which in a non-clinical context simply references the domain process, though the name carries clinical heritage).
- **CustomerSegment** — segmentName, description, needs, acquisitionChannel, willingnessToPayIndicator. Completely domain-neutral.
- **Channel** — channelName, channelType, estimatedReach, estimatedCostLevel, conversionNotes. Clean transfer.
- **DifferentiationClaim** — claimName, statement, basis, testability. Designed to work for any business's competitive positioning.
- **ActivityType** — activityTypeName, activityCategory, description, expectedDurationMinutes, frequencyNotes. The five-category taxonomy (C6) works identically in both domains.
- **ActivityGranularity** — businessArea, currentLevel, targetLevel, migrationNotes. Same progressive elaboration principle, same granularity levels, different calibration per domain.
- **ResourceType** — resourceTypeName, category, acquisitionMethod, costProfile, capacityUnit. The category vocabulary (personnel, equipment, estate, consumables) accommodates both domains naturally.
- **Capability** — capabilityName, description, requiredResources, enabledOfferingsDescription. Clean.
- **CapacityModel** — resourceConfiguration, throughputPerPeriod, periodUnit, assumptions, bottleneck. Different numbers, same structure.
- **ResourceConstraint** — constraintName, constraintType, affectedResource, limit, regulatorySourceDescription. COSHH (Suds) and food hygiene (CSW) both fit identically.
- **RevenueStream** — streamName, sourceSegment, triggerEvent, pricingModelRef, projectedVolume. Clean.
- **CostDriver** — driverName, linkedResource, costBehaviour, estimatedUnitCost, scalingFactor. Clean.
- **UnitEconomics** — offeringRef, revenuePerUnit, costPerUnit, marginPerUnit, breakdownNotes. The three Suds unit economics instances (standard, delicates, express) demonstrate that the `part def` accommodates variant pricing within a single domain.
- **PricingModel** — pricingModelName, pricingType, basePrice, adjustmentLogic, applicableOfferings. The per-kg with surcharges model is structurally different from CSW's per-drink model but both fit `PricingModel` without strain.
- **ExternalReference** — referenceType, referenceId, referenceSource, referenceNotes. Governance documents (Suds) and supplier datasheets (CSW) both fit.
- **ActivityCostAllocation** — activityType, allocationMethod, estimatedCostPerUnit, costNotes. Suds is the first domain to exercise this. The structure accommodates both per-kg variable costing and labour-time allocation.

### 4.2 Observations on Specific Elements

**CatalogueEntry — product catalogue vs service catalogue (P3-D1):**

CSW uses a domain-typed specialisation (`CoffeeShop::CatalogueEntry` with `ref item : MenuItem`) because the coffee shop has a product model — drinks are things with intrinsic properties, and the catalogue adds business decisions (pricing, availability) on top. Suds has no product model — its "items" are service offerings, not physical products.

Suds therefore uses the generic BMM `CatalogueEntry` directly. This works, but reveals a design tension: the generic `CatalogueEntry` has `provisionType : String`, and Suds uses the value `"service"` — which is outside the CSW enum vocabulary (prepared, boughtIn, hybrid). The attribute generalises (String is unconstrained), but the *values* are domain-specific.

**Observation:** If `CatalogueEntry` is to be a truly General `part def`, the `provisionType` taxonomy needs to accommodate services as well as physical goods. This connects to B13 (Services/Goods scope boundary). A future tag dimension for provision type categories could capture this.

**ValueProposition — attribute mismatch (pre-existing):**

The Suds `sudsValueProposition` uses `promiseStatement` as an attribute name, but the BMM `ValueProposition` `part def` defines `description` (not `promiseStatement`). It also omits `evidenceBasis`. This is a pre-existing issue from Session 37 — the `:>>` redefinition of `promiseStatement` will fail because no such attribute exists on the `part def`. This needs correction: either rename to `description` or add an `evidenceBasis` attribute. Flagged for Syside validation.

**`clinicalPathwayRef` attribute naming:**

The `ServiceOffering` attribute `clinicalPathwayRef` carries clinical heritage in its name. In Suds, the values are `"standard-wash-process"`, `"delicates-wash-process"`, etc. — not clinical pathways at all. The attribute *works* (it's just a String reference to a process), but the name creates a minor comprehension friction for non-health domains. This is a cosmetic issue, not a structural one — a future rename to `processRef` or `pathwayRef` would improve clarity, but would require updating all existing usages.

### 4.3 Nothing Required Tailoring

No Suds-specific `part def`s were needed. All 11 new elements are `part` usages of existing General BMM vocabulary. This is a strong validation signal — the BMM accommodates a structurally different service business without vocabulary extension.

The only friction points are naming conventions inherited from the clinical heritage (clinicalPathwayRef) and the CatalogueEntry provision type taxonomy, neither of which required creating new `part def`s.

---

## 5. Meta Model Gaps Exposed

### 5.1 Confirmed Gaps (O6)

ActivityRecord, ActivityBudget, and InventoryRecord remain uninstantiated in both domains. These are runtime/operational concepts that planning-level demonstrators don't naturally exercise. They may need a different kind of validation — an execution-level demonstrator that tracks actual operations rather than modelling business structure.

### 5.2 Potential Future Needs

- **Batch/order tracking:** Suds has a fundamentally different order structure from CSW — multiple customer orders combined into machine batches, then separated back. The BMM doesn't currently express batch grouping as a concept. This might emerge as a Tailored BSMM concern when the Suds process model is built (currently out of scope).
- **SLA/turnaround commitment:** Suds's turnaround promises (next-day, same-day) are a structural part of the service offering, but `ServiceOffering` has no dedicated SLA attribute — it's captured in `description` and `scope` as free text. A future `ServiceLevelAgreement` `part def` might be warranted if SLA modelling becomes important.
- **Subscription management:** Suds has a subscription customer segment but no subscription-specific infrastructure (billing cycle, renewal, collection scheduling). This connects to the GSL subscription model in Variant B. Not a gap in the BMM per se, but a reminder that subscription mechanics sit at the BSMM level.

---

## 6. Cross-Domain Comparison Methodology — What Worked

### 6.1 Effective Approach

The coverage audit method — systematically listing every BMM `part def` and checking CSW vs Suds instantiation — was effective at finding gaps. The coverage matrix in the Ontara Console made this visual and immediate.

Working through each gap in order (DifferentiationClaim → CatalogueEntry → ExternalReference → ActivityCostAllocation → UnitEconomics) allowed focused attention on each `part def`'s generalisation properties.

### 6.2 Recommendations for Paws

When the Paws (dog grooming) domain is built in Stage 3:

1. **Start with the same audit method.** List all BMM `part def`s, check CSW and Suds instantiation, identify what Paws adds.
2. **Paws should exercise different structural tensions.** Dog grooming has appointment-based scheduling (neither walk-in like CSW nor batch like Suds), animal welfare governance (different regulatory framework from COSHH and food hygiene), and potentially a tipping/gratuity revenue model. These should test different parts of the vocabulary.
3. **Look for the second Tailored signal.** If Paws also needs no domain-specific `part def`s, the General vocabulary is robust. If Paws exposes a genuine need for a Tailored extension, that's a valuable data point for the General/Tailored boundary.

---

## 7. Related Documents

- [[ontara-stage-2-plan-2026-03-19|Stage 2 Plan]] — Phase 3 specification
- [[gsl-service-business-meta-modelling|Service Business Meta Modelling]] — BMM source
- [[ontara-master-register-design-concepts-2026-03-17|Master Concept Register]] — tracked concepts
- [[gsl-validated-architectural-patterns|Validated Architectural Patterns]] — patterns exercised
- [[ontara-discussion-component-catalogue-model-assembly-2026-03-18|Component Catalogue Discussion]] — B11 General/Tailored concept
- Session 41 Report — implementation details

---

*Suds domain design note prepared 19 March 2026 (Session 41). Stage 2 Phase 3.*
