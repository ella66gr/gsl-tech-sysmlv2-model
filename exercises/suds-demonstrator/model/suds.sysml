// =========================================================================
// SUDS DEMONSTRATOR — Laundry Service Business Model
// =========================================================================
//
// Cross-domain validation: validates that BusinessModel part defs
// generalise from a coffee shop to a structurally different service
// business — a drop-off laundry service.
//
// Key structural differences from CSW:
//   - Pricing: per-kg / per-bag with type surcharges (vs per-item fixed)
//   - Process shape: batch-and-turnaround over hours (vs immediate 2 min)
//   - Item tracking: bag → items → batch grouping → return (vs order → drink)
//   - Scheduling: turnaround-time promises (vs walk-in, no scheduling)
//
// Governance: COSHH regulations for handling cleaning chemicals.
//
// Session 37 (18 March 2026): initial business model creation.
// Session 41 (19 March 2026): Phase 3 — full BMM coverage expansion.
//   Added: DifferentiationClaim (2), CatalogueEntry (3),
//   ExternalReference (2), ActivityCostAllocation (2),
//   UnitEconomics (2). Total: +11 part usages.
// =========================================================================

package SudsBusinessModel {
    private import ScalarValues::*;
    private import BusinessModel::ServiceConcept::*;
    private import BusinessModel::ActivityModel::*;

    doc /* Suds laundry service business model. Instantiates the
         * ServiceConcept and ActivityModel part defs from the main
         * BusinessModel package to validate cross-domain generalisation.
         *
         * Same meta model vocabulary as CSW, different values — this
         * is the test of whether the abstractions generalise. */

    // -- Service Concept --------------------------------------

    part sudsValueProposition : ValueProposition {
        attribute :>> propositionName = "Convenient, quality fabric care";
        attribute :>> targetSegment = "Time-poor professionals and families";
        attribute :>> description = "Drop off your laundry and collect it clean, pressed, and ready — same-day express or next-day standard";
        attribute :>> evidenceBasis = "Customer satisfaction surveys, turnaround time tracking, repeat booking rates";
        attribute :>> differentiator = "Reliable turnaround times, careful handling of delicates, transparent per-kg pricing";
    }

    part standardWash : ServiceOffering {
        doc /* Standard wash-dry-fold — the core offering. Everyday
             * clothing and household textiles. Next-day turnaround. */
        attribute :>> offeringName = "Standard wash";
        attribute :>> description = "Wash, dry, and fold everyday laundry items. Next-day collection.";
        attribute :>> scope = "Receive, sort, wash, dry, fold, return";
        attribute :>> pricingBasis = "per-kg";
        attribute :>> estimatedDurationWeeks = 0;
        attribute :>> clinicalPathwayRef = "standard-wash-process";
    }

    part delicatesWash : ServiceOffering {
        doc /* Delicates and hand-wash items. Requires specialist
             * handling — lower temperatures, hand-wash cycles,
             * careful pressing. Higher price point. */
        attribute :>> offeringName = "Delicates wash";
        attribute :>> description = "Specialist handling for delicate fabrics. Hand-wash or gentle cycle. Two-day turnaround.";
        attribute :>> scope = "Receive, inspect, hand-wash or gentle cycle, air dry, press, return";
        attribute :>> pricingBasis = "per-kg with type surcharge";
        attribute :>> estimatedDurationWeeks = 0;
        attribute :>> clinicalPathwayRef = "delicates-wash-process";
    }

    part expressWash : ServiceOffering {
        doc /* Express turnaround — same-day service. Premium price
             * for guaranteed 4-hour turnaround on standard items. */
        attribute :>> offeringName = "Express wash";
        attribute :>> description = "Same-day standard wash with guaranteed 4-hour turnaround.";
        attribute :>> scope = "Priority receive, wash, dry, fold, return within 4 hours";
        attribute :>> pricingBasis = "per-kg with express surcharge";
        attribute :>> estimatedDurationWeeks = 0;
        attribute :>> clinicalPathwayRef = "express-wash-process";
    }

    part walkInCustomer : CustomerSegment {
        attribute :>> segmentName = "Walk-in customers";
        attribute :>> description = "Individuals who drop off laundry at the shop counter";
        attribute :>> needs = "Convenient, affordable laundry service with reliable turnaround";
        attribute :>> acquisitionChannel = "Foot traffic, local advertising, word of mouth";
        attribute :>> willingnessToPayIndicator = "medium";
    }

    part subscriptionCustomer : CustomerSegment {
        doc /* Regular customers on a subscription plan — weekly
             * or fortnightly collection and delivery. Higher lifetime
             * value, predictable demand. */
        attribute :>> segmentName = "Subscription customers";
        attribute :>> description = "Regular customers with scheduled collection and delivery";
        attribute :>> needs = "Hassle-free laundry, no need to visit the shop";
        attribute :>> acquisitionChannel = "Website, referral, local marketing";
        attribute :>> willingnessToPayIndicator = "medium-high";
    }

    part shopCounter : Channel {
        attribute :>> channelName = "Shop counter";
        attribute :>> description = "In-person drop-off and collection at the laundry premises";
        attribute :>> channelType = "acquisition and delivery";
        attribute :>> estimatedReach = "local — walking distance or short drive";
        attribute :>> estimatedCostLevel = "low";
        attribute :>> conversionNotes = "High — customer has brought their laundry, strong intent";
    }

    part onlineBooking : Channel {
        attribute :>> channelName = "Online booking";
        attribute :>> description = "Website for subscription sign-up, collection booking, and order tracking";
        attribute :>> channelType = "acquisition and service";
        attribute :>> estimatedReach = "local area — delivery radius";
        attribute :>> estimatedCostLevel = "medium";
        attribute :>> conversionNotes = "Moderate — subscription model needs trust-building";
    }

    // -- Differentiation Claims --------------------------------

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

    // -- Catalogue Entries ------------------------------------
    //
    // Service offerings as catalogue items. Uses the generic
    // BMM CatalogueEntry directly — no domain-typed specialisation.
    // This tests whether CatalogueEntry generalises beyond
    // product menus to service catalogues (design decision P3-D1).

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

    // -- Activity Model ---------------------------------------
    //
    // Six activity types following the five-category taxonomy.
    // The process shape is fundamentally different from CSW:
    // batch processing over hours rather than immediate preparation.

    part receiveAndTag : ActivityType {
        doc /* Service delivery: intake. Customer drops off bag,
             * items are inspected, counted, weighed, and tagged.
             * This is the first customer touchpoint in the process. */
        attribute :>> activityTypeName = "Receive and tag items";
        attribute :>> activityCategory = ActivityCategory::serviceDelivery;
        attribute :>> description = "Accept laundry bag, inspect contents, weigh, tag each item, record order";
        attribute :>> expectedDurationMinutes = 10;
        attribute :>> frequencyNotes = "Per customer drop-off";
    }

    part sortAndLoad : ActivityType {
        doc /* Service delivery: sorting by wash type, colour, and
             * temperature. Loading machines in batches — items from
             * multiple orders may be washed together. */
        attribute :>> activityTypeName = "Sort and load";
        attribute :>> activityCategory = ActivityCategory::serviceDelivery;
        attribute :>> description = "Sort items by wash type, colour, and temperature requirements. Load machines in optimal batches.";
        attribute :>> expectedDurationMinutes = 15;
        attribute :>> frequencyNotes = "Per batch — multiple orders combined";
    }

    part washCycle : ActivityType {
        doc /* Service delivery: the wash itself. Machine time —
             * operator monitors but is largely free for other tasks.
             * Duration varies by programme: 30 min quick wash to
             * 90 min delicates cycle. */
        attribute :>> activityTypeName = "Wash cycle";
        attribute :>> activityCategory = ActivityCategory::serviceDelivery;
        attribute :>> description = "Run wash programme. Monitor machine. Duration varies by programme type.";
        attribute :>> expectedDurationMinutes = 60;
        attribute :>> frequencyNotes = "Per machine load";
    }

    part dryAndFinish : ActivityType {
        doc /* Service delivery: drying, pressing, and folding.
             * Tumble dry or air dry depending on fabric type.
             * Pressing for items that require it. */
        attribute :>> activityTypeName = "Dry and finish";
        attribute :>> activityCategory = ActivityCategory::serviceDelivery;
        attribute :>> description = "Dry items (tumble or air), press where required, fold and package for collection";
        attribute :>> expectedDurationMinutes = 30;
        attribute :>> frequencyNotes = "Per batch";
    }

    part qualityCheck : ActivityType {
        doc /* Service delivery: inspection before return. Check
             * stain removal, damage, correct item count, packaging. */
        attribute :>> activityTypeName = "Quality check";
        attribute :>> activityCategory = ActivityCategory::serviceDelivery;
        attribute :>> description = "Inspect finished items for quality, verify item count matches intake, package for collection";
        attribute :>> expectedDurationMinutes = 5;
        attribute :>> frequencyNotes = "Per order";
    }

    part returnToCustomer : ActivityType {
        doc /* Service delivery: the final step. Notify customer,
             * hand over at counter or arrange delivery. */
        attribute :>> activityTypeName = "Return to customer";
        attribute :>> activityCategory = ActivityCategory::serviceDelivery;
        attribute :>> description = "Notify customer of completion, hand over at counter or dispatch for delivery";
        attribute :>> expectedDurationMinutes = 5;
        attribute :>> frequencyNotes = "Per order";
    }

    part machineMaintenanceAndClean : ActivityType {
        doc /* Service enabling: keeping the machines running.
             * Daily cleaning, descaling, filter maintenance. */
        attribute :>> activityTypeName = "Machine maintenance and cleaning";
        attribute :>> activityCategory = ActivityCategory::serviceEnabling;
        attribute :>> description = "Clean machines, descale, replace filters, check drainage, test programmes";
        attribute :>> expectedDurationMinutes = 30;
        attribute :>> frequencyNotes = "Daily — end of day";
    }

    part coshhComplianceChecks : ActivityType {
        doc /* Governance: COSHH regulations require documented
             * risk assessment, safe storage, labelling, and
             * staff training for cleaning chemicals. */
        attribute :>> activityTypeName = "COSHH compliance checks";
        attribute :>> activityCategory = ActivityCategory::governance;
        attribute :>> description = "Chemical storage audit, COSHH data sheet review, staff competency check, risk assessment update";
        attribute :>> expectedDurationMinutes = 20;
        attribute :>> frequencyNotes = "Weekly";
    }

    part staffTraining : ActivityType {
        attribute :>> activityTypeName = "Staff training";
        attribute :>> activityCategory = ActivityCategory::development;
        attribute :>> description = "Fabric care training, new equipment operation, customer service, COSHH awareness";
        attribute :>> expectedDurationMinutes = 60;
        attribute :>> frequencyNotes = "Monthly";
    }

    part tillAndOrderReconciliation : ActivityType {
        attribute :>> activityTypeName = "Till and order reconciliation";
        attribute :>> activityCategory = ActivityCategory::overhead;
        attribute :>> description = "Cash count, card reconciliation, order completion audit, daily revenue summary";
        attribute :>> expectedDurationMinutes = 15;
        attribute :>> frequencyNotes = "Daily — closing";
    }

    // -- Granularity policy ------------------------------------

    part serviceDeliveryGranularity : ActivityGranularity {
        doc /* Service delivery is tracked — each order's journey
             * through receive → sort → wash → dry → check → return
             * generates observable events for every step. */
        attribute :>> businessArea = "Service delivery";
        attribute :>> currentLevel = GranularityLevel::tracked;
        attribute :>> targetLevel = GranularityLevel::tracked;
        attribute :>> migrationNotes = "Tracked via order workflow events through all process stages";
    }

    part enablingGranularity : ActivityGranularity {
        attribute :>> businessArea = "Service enabling";
        attribute :>> currentLevel = GranularityLevel::category;
        attribute :>> targetLevel = GranularityLevel::category;
        attribute :>> migrationNotes = "Machine maintenance logged as daily category-level events";
    }

    part governanceGranularity : ActivityGranularity {
        attribute :>> businessArea = "Governance";
        attribute :>> currentLevel = GranularityLevel::tracked;
        attribute :>> targetLevel = GranularityLevel::tracked;
        attribute :>> migrationNotes = "COSHH compliance requires auditable records of every check";
    }

    part developmentGranularity : ActivityGranularity {
        attribute :>> businessArea = "Development";
        attribute :>> currentLevel = GranularityLevel::envelope;
        attribute :>> targetLevel = GranularityLevel::envelope;
        attribute :>> migrationNotes = "Monthly training — envelope adequate";
    }

    part overheadGranularity : ActivityGranularity {
        attribute :>> businessArea = "Overhead";
        attribute :>> currentLevel = GranularityLevel::envelope;
        attribute :>> targetLevel = GranularityLevel::envelope;
        attribute :>> migrationNotes = "Daily admin — envelope adequate";
    }

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
}

// =========================================================================
// SUDS DEMONSTRATOR — Resource and Financial Planning
// =========================================================================

package SudsResourceFinancial {
    private import ScalarValues::*;
    private import BusinessModel::ResourcePlanning::*;
    private import BusinessModel::FinancialPlanning::*;

    // -- Resource types ----------------------------------------

    part laundryOperator : ResourceType {
        attribute :>> resourceTypeName = "Laundry operator";
        attribute :>> category = "personnel";
        attribute :>> acquisitionMethod = "employed";
        attribute :>> costProfile = "£11.50 per hour";
        attribute :>> capacityUnit = "FTE";
    }

    part washingMachine : ResourceType {
        doc /* Commercial washing machines — typically 3-4 machines
             * for a small service. High-spin commercial models. */
        attribute :>> resourceTypeName = "Washing machine";
        attribute :>> category = "equipment";
        attribute :>> acquisitionMethod = "leased";
        attribute :>> costProfile = "£80 per month per machine lease";
        attribute :>> capacityUnit = "machines";
    }

    part tumbleDryer : ResourceType {
        attribute :>> resourceTypeName = "Tumble dryer";
        attribute :>> category = "equipment";
        attribute :>> acquisitionMethod = "leased";
        attribute :>> costProfile = "£60 per month per dryer lease";
        attribute :>> capacityUnit = "machines";
    }

    part pressingEquipment : ResourceType {
        attribute :>> resourceTypeName = "Pressing and ironing equipment";
        attribute :>> category = "equipment";
        attribute :>> acquisitionMethod = "purchased";
        attribute :>> costProfile = "£500 one-off per station";
        attribute :>> capacityUnit = "stations";
    }

    part shopPremises : ResourceType {
        attribute :>> resourceTypeName = "Shop premises";
        attribute :>> category = "estate";
        attribute :>> acquisitionMethod = "rented";
        attribute :>> costProfile = "£1,800 per month rent";
        attribute :>> capacityUnit = "premises";
    }

    part detergentsAndChemicals : ResourceType {
        doc /* Cleaning chemicals — detergent, fabric softener,
             * stain remover, specialist products. Subject to COSHH
             * regulations for storage and handling. */
        attribute :>> resourceTypeName = "Detergents and chemicals";
        attribute :>> category = "consumables";
        attribute :>> acquisitionMethod = "purchased";
        attribute :>> costProfile = "£0.40 per kg of laundry processed";
        attribute :>> capacityUnit = "litres";
    }

    // -- Capability -------------------------------------------

    part processLaundry : Capability {
        attribute :>> capabilityName = "Process a laundry order";
        attribute :>> description = "Receive, sort, wash, dry, finish, and return a customer's laundry";
        attribute :>> requiredResources = "1 operator + washing machines + dryers + pressing station + chemicals + premises";
        attribute :>> enabledOfferingsDescription = "Standard wash, Delicates wash, Express wash";
    }

    // -- Capacity model ---------------------------------------

    part standardDayCapacity : CapacityModel {
        attribute :>> resourceConfiguration = "2 operators + 4 washing machines + 3 dryers + 1 pressing station";
        attribute :>> throughputPerPeriod = "120 kg of laundry";
        attribute :>> periodUnit = "per day";
        attribute :>> assumptions = "Average wash cycle 60 min, 8 kg per load, 8-hour working day, machines running continuously";
        attribute :>> bottleneck = "Washing machine capacity and cycle time";
    }

    // -- Resource constraint ----------------------------------

    part coshhRegulations : ResourceConstraint {
        doc /* COSHH — Control of Substances Hazardous to Health.
             * Legal requirement for handling cleaning chemicals.
             * Requires risk assessment, safe storage, COSHH data
             * sheets, staff training, and PPE provision. */
        attribute :>> constraintName = "COSHH compliance";
        attribute :>> constraintType = "regulatory";
        attribute :>> affectedResource = "Detergents and chemicals";
        attribute :>> limit = "All cleaning chemicals must have current COSHH data sheets. Staff must be trained in safe handling. Chemicals stored in ventilated, locked area.";
        attribute :>> regulatorySourceDescription = "Health and Safety Executive — Control of Substances Hazardous to Health Regulations 2002";
    }

    // -- Revenue stream ---------------------------------------

    part laundryRevenue : RevenueStream {
        attribute :>> streamName = "Laundry service revenue";
        attribute :>> sourceSegment = "Walk-in and subscription customers";
        attribute :>> triggerEvent = "Laundry processed and collected or delivered";
        attribute :>> pricingModelRef = "perKgPricing";
        attribute :>> projectedVolume = "100 kg per day average";
    }

    // -- Cost drivers -----------------------------------------

    part staffCosts : CostDriver {
        attribute :>> driverName = "Operator labour";
        attribute :>> linkedResource = "Laundry operator";
        attribute :>> costBehaviour = "semi-variable — shifts scheduled to demand";
        attribute :>> estimatedUnitCost = 11.50;
        attribute :>> scalingFactor = "per hour";
    }

    part utilityCosts : CostDriver {
        doc /* Water, electricity, and gas — significant for a
             * laundry service. Partially variable with volume. */
        attribute :>> driverName = "Utility costs";
        attribute :>> linkedResource = "Washing machines and dryers";
        attribute :>> costBehaviour = "semi-variable";
        attribute :>> estimatedUnitCost = 0.60;
        attribute :>> scalingFactor = "per kg of laundry";
    }

    part chemicalCosts : CostDriver {
        attribute :>> driverName = "Detergent and chemical costs";
        attribute :>> linkedResource = "Detergents and chemicals";
        attribute :>> costBehaviour = "variable";
        attribute :>> estimatedUnitCost = 0.40;
        attribute :>> scalingFactor = "per kg of laundry";
    }

    part rentCosts : CostDriver {
        attribute :>> driverName = "Premises rent";
        attribute :>> linkedResource = "Shop premises";
        attribute :>> costBehaviour = "fixed";
        attribute :>> estimatedUnitCost = 1800.0;
        attribute :>> scalingFactor = "per month";
    }

    // -- Unit economics ---------------------------------------

    part standardWashEconomics : UnitEconomics {
        doc /* Per-kg economics for standard wash. Revenue £2.50/kg,
             * cost £1.50/kg (labour £0.50, utilities £0.60,
             * chemicals £0.40), margin £1.00/kg. */
        attribute :>> offeringRef = "Standard wash";
        attribute :>> revenuePerUnit = 2.50;
        attribute :>> costPerUnit = 1.50;
        attribute :>> marginPerUnit = 1.00;
        attribute :>> breakdownNotes = "Labour £0.50/kg, utilities £0.60/kg, chemicals £0.40/kg. Rent and equipment lease excluded (fixed costs).";
    }

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

    // -- Pricing model ----------------------------------------

    part perKgPricing : PricingModel {
        doc /* Per-kg pricing with surcharges. Standard wash £2.50/kg.
             * Delicates +50% surcharge. Express +100% surcharge.
             * Minimum order 3 kg. */
        attribute :>> pricingModelName = "Per-kg pricing with surcharges";
        attribute :>> pricingType = PricingType::perEpisode;
        attribute :>> basePrice = 2.50;
        attribute :>> adjustmentLogic = "Standard: £2.50/kg. Delicates: £3.75/kg (+50%). Express: £5.00/kg (+100%). Minimum order 3 kg.";
        attribute :>> applicableOfferings = "Standard wash, Delicates wash, Express wash";
    }
}

// =========================================================================
// SUDS DEMONSTRATOR — Governance: COSHH Traceability Chain
// =========================================================================
//
// Exercises the full governance traceability architecture (A8, J8)
// in a non-health context. COSHH compliance for a laundry service.
//
// Traceability chain:
//   GovernanceRequirement (coshhCompliance)
//     → constraint def (CoshhStorageConstraint, CoshhTrainingConstraint)
//       → satisfy (coshhStorageSatisfied, coshhTrainingSatisfied)
//         → AuditEvidenceRecord (risk assessment, SDS register,
//                                training record, inspection log)
//
// External references (regulatory source documents) are separate
// from audit evidence records (proof of compliance).
//
// Session 37 (18 March 2026): initial governance requirement.
// Session 41 (19 March 2026): ExternalReference instances added.
// Session 42 (19 March 2026): Phase 6 — full satisfy chain,
//   constraint defs, audit evidence records. Requirement refactored
//   to use General GovernanceRequirement from BMM.
// =========================================================================

package SudsGovernance {
    private import ScalarValues::*;
    private import BusinessModel::ServiceConcept::ExternalReference;
    private import BusinessModel::GovernanceMapping::*;

    doc /* COSHH governance traceability for the Suds laundry service.
         * Demonstrates the full satisfy chain in a non-health context:
         * requirement → constraint → satisfy → audit evidence.
         *
         * The GovernanceRequirement and AuditEvidenceRecord part defs
         * are General BMM vocabulary from BusinessModel::GovernanceMapping.
         * The constraint defs are domain-specific — COSHH testable
         * conditions that would not apply to a coffee shop or
         * dog grooming service. */

    // -- Governance Requirement --------------------------------
    //
    // Typed by the General GovernanceRequirement from the BMM.
    // Attributes redefined with COSHH-specific values.

    requirement coshhCompliance : GovernanceRequirement {
        doc /* Control of Substances Hazardous to Health Regulations 2002.
             * Requires employers to control substances that are hazardous
             * to health. For a laundry service: cleaning chemicals,
             * detergents, stain removers, and specialist products.
             *
             * This exercises the governance traceability architecture
             * (A8) in a non-health context. The satisfy chain:
             * requirement → constraint → satisfy → audit evidence
             * should work identically to CQC requirements in GSL. */

        attribute :>> requirementId = "SUDS-GOV-001";
        attribute :>> title = "COSHH compliance for cleaning chemicals";
        attribute :>> regulatorySource = "Health and Safety Executive — COSHH Regulations 2002";
        attribute :>> complianceDescription = "All cleaning chemicals used in the laundry service must be subject to COSHH risk assessment. Current safety data sheets must be maintained for all substances. Staff must receive COSHH awareness training before handling chemicals. Chemicals must be stored in a ventilated, locked area with appropriate PPE available.";
        attribute :>> evidenceRequired = "COSHH risk assessment document, safety data sheet register, staff training records, storage inspection log";
    }

    // -- Constraint Definitions --------------------------------
    //
    // Domain-specific testable conditions for COSHH compliance.
    // These are Suds-specific — different regulations would have
    // different constraints.

    constraint def CoshhStorageConstraint {
        doc /* Testable condition: all cleaning chemicals are stored
             * in compliance with COSHH requirements. Requires:
             * all substances have current safety data sheets, and
             * the storage area meets ventilation and security
             * standards. */
        in allSubstancesHaveSds : Boolean;
        in storageAreaCompliant : Boolean;

        allSubstancesHaveSds and storageAreaCompliant
    }

    constraint def CoshhTrainingConstraint {
        doc /* Testable condition: all staff who handle chemicals
             * have completed COSHH awareness training within the
             * required interval. Training must be refreshed
             * annually. */
        in monthsSinceTraining : Integer;
        in requiredMaxMonths : Integer;

        monthsSinceTraining <= requiredMaxMonths
    }

    // -- Constraint Usages ------------------------------------

    constraint coshhStorageCheck : CoshhStorageConstraint;
    constraint coshhTrainingCheck : CoshhTrainingConstraint;

    // -- Satisfy Relationships --------------------------------
    //
    // Formal traceability: requirement → constraint.
    // Named-and-typed form per syntax reference §7.
    // GovernanceRequirement def is in BusinessModel::GovernanceMapping
    // (different package from this satisfy — required by Syside).

    satisfy requirement coshhStorageSatisfied : GovernanceRequirement
        by coshhStorageCheck;

    satisfy requirement coshhTrainingSatisfied : GovernanceRequirement
        by coshhTrainingCheck;

    // -- Audit Evidence Records -------------------------------
    //
    // Proof of compliance. Each record type demonstrates that
    // a specific aspect of the COSHH requirement is being met.
    // Typed by the General AuditEvidenceRecord from the BMM.

    part coshhRiskAssessment : AuditEvidenceRecord {
        doc /* Documented COSHH risk assessment for all chemicals
             * used in the laundry service. Must be reviewed
             * annually and whenever a new chemical is introduced. */
        attribute :>> evidenceType = "risk assessment";
        attribute :>> evidenceDescription = "COSHH risk assessment covering all cleaning chemicals, detergents, and specialist products used in the laundry. Identifies hazards, exposure routes, control measures, and emergency procedures.";
        attribute :>> retentionPeriod = "5 years from date of assessment";
        attribute :>> responsibleRole = "Shop manager";
        attribute :>> frequency = "Annually and on introduction of new chemicals";
    }

    part sdsRegister : AuditEvidenceRecord {
        doc /* Register of current Safety Data Sheets for every
             * chemical substance used. COSHH requires SDS to be
             * available at the point of use and kept current. */
        attribute :>> evidenceType = "document register";
        attribute :>> evidenceDescription = "Index of all Safety Data Sheets held, with product name, supplier, date of issue, and location of physical/digital copy. Cross-referenced to chemical inventory.";
        attribute :>> retentionPeriod = "Duration of use plus 3 years";
        attribute :>> responsibleRole = "Shop manager";
        attribute :>> frequency = "Updated on receipt of new SDS or change of supplier";
    }

    part staffTrainingRecord : AuditEvidenceRecord {
        doc /* Individual training records for each staff member
             * who handles cleaning chemicals. COSHH requires
             * documented evidence of training and competency. */
        attribute :>> evidenceType = "training record";
        attribute :>> evidenceDescription = "Per-employee record of COSHH awareness training: date completed, trainer, topics covered, competency assessment outcome. Refresher training tracked separately.";
        attribute :>> retentionPeriod = "Duration of employment plus 6 years";
        attribute :>> responsibleRole = "Shop manager";
        attribute :>> frequency = "On induction and annually thereafter";
    }

    part storageInspectionLog : AuditEvidenceRecord {
        doc /* Log of periodic inspections of the chemical storage
             * area. Checks ventilation, locked access, labelling,
             * PPE availability, and spill containment. */
        attribute :>> evidenceType = "inspection log";
        attribute :>> evidenceDescription = "Dated record of chemical storage area inspection: ventilation status, lock integrity, labelling compliance, PPE stock check, spill kit presence, any corrective actions required.";
        attribute :>> retentionPeriod = "5 years";
        attribute :>> responsibleRole = "Shop manager or designated safety officer";
        attribute :>> frequency = "Monthly";
    }

    // -- External References ----------------------------------
    //
    // Knowledge the system links to but does not own.
    // Regulatory source documents — distinct from audit evidence
    // (which is proof of compliance, not the rules themselves).

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
}
