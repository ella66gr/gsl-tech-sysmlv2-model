// =========================================================================
// PAWS DEMONSTRATOR — Dog Grooming Service Business Model
// =========================================================================
//
// Cross-domain validation: validates that BusinessModel part defs
// generalise from a coffee shop (immediate retail) and laundry
// (batch processing) to a structurally different service business
// — an appointment-based personal service.
//
// Key structural differences from Cafe and Suds:
//   - Scheduling: appointment-based with variable duration (vs immediate
//     or batch turnaround)
//   - Service subject: the animal, not the paying customer (analogous
//     to GSL where the patient is the service subject)
//   - Pricing: per-appointment with breed/size surcharges
//   - Process shape: sequential single-animal workflow, one groomer
//     per appointment (vs parallel batch processing in Suds)
//   - Governance: general professional duty of care (Animal Welfare
//     Act 2006), not specific regulation like COSHH
//
// Session 44 (19 March 2026): initial business model creation.
//   Stage 3 Phase 1 — third demonstrator domain.
// =========================================================================

package PawsBusinessModel {
    private import ScalarValues::*;
    private import BusinessModel::ServiceConcept::*;
    private import BusinessModel::ActivityModel::*;

    doc /* Paws dog grooming service business model. Instantiates the
         * ServiceConcept and ActivityModel part defs from the main
         * BusinessModel package to validate cross-domain generalisation
         * for appointment-based personal services.
         *
         * Same meta model vocabulary as Cafe and Suds, different
         * values — this is the test of whether the abstractions
         * generalise across three structurally different service types.
         *
         * Notable modelling observation (Session 44): the paying
         * customer (pet owner) is not the service recipient (the
         * animal). Resolved Session 55 with two sibling General BMM
         * concepts: ServiceSubject (the dog) and ServiceParticipant
         * (the pet owner). This parallels the GSL domain where the
         * patient is the service subject but booking/payment may
         * involve others. See: Service Participation Model discussion
         * document (Session 55). */

    // -- Service Concept --------------------------------------

    part pawsValueProposition : ValueProposition {
        attribute :>> propositionName = "Expert, gentle pet grooming";
        ref :>> targetSegment = individualPetOwner;
        attribute :>> description = "Professional grooming tailored to your dog's breed, coat type, and temperament — in a calm, low-stress environment";
        attribute :>> evidenceBasis = "Customer feedback, repeat booking rates, breed-specific training credentials";
        attribute :>> differentiator = "Breed-specific expertise with a focus on animal comfort and welfare";
    }

    part fullGroom : ServiceOffering {
        doc /* Full grooming session — the core offering. Includes
             * bath, blow-dry, full coat trim/style, nail trim, ear
             * clean, and finishing. Duration varies by breed and
             * coat condition: 60–120 minutes. */
        attribute :>> offeringName = "Full groom";
        attribute :>> description = "Complete grooming: bath, dry, coat trim and style, nail trim, ear clean, finishing touches";
        attribute :>> scope = "Check-in, assess coat condition, bathe, dry, clip/scissor to breed standard or owner preference, nail trim, ear clean, finishing spray, handover";
        attribute :>> pricingBasis = "per-appointment with breed/size surcharge";
        attribute :>> estimatedDurationWeeks = 0;
        attribute :>> clinicalPathwayRef = "full-groom-process";
    }

    part washAndTidy : ServiceOffering {
        doc /* Wash and tidy — a lighter service for dogs that need
             * cleaning but not a full restyle. Bath, blow-dry,
             * light trim around eyes/paws/sanitary areas.
             * 30–60 minutes depending on size. */
        attribute :>> offeringName = "Wash and tidy";
        attribute :>> description = "Bath, blow-dry, and light trim around eyes, paws, and sanitary areas";
        attribute :>> scope = "Check-in, bathe, dry, tidy trim (face, feet, sanitary), finishing, handover";
        attribute :>> pricingBasis = "per-appointment with size surcharge";
        attribute :>> estimatedDurationWeeks = 0;
        attribute :>> clinicalPathwayRef = "wash-and-tidy-process";
    }

    part nailTrimAddOn : ServiceOffering {
        doc /* Nail trim as a standalone service or add-on. Quick
             * appointment — 15 minutes. Available as walk-in or
             * booked alongside other services. */
        attribute :>> offeringName = "Nail trim";
        attribute :>> description = "Nail clipping and filing — standalone or add-on to any grooming service";
        attribute :>> scope = "Assess nails, clip to safe length, file smooth, check dewclaws";
        attribute :>> pricingBasis = "fixed price";
        attribute :>> estimatedDurationWeeks = 0;
        attribute :>> clinicalPathwayRef = "nail-trim-process";
    }

    part individualPetOwner : CustomerSegment {
        attribute :>> segmentName = "Individual pet owners";
        attribute :>> description = "Dog owners booking grooming appointments for one or two pets";
        attribute :>> needs = "Reliable, gentle grooming at a fair price with convenient booking";
        attribute :>> acquisitionChannel = "Walk-in, word of mouth, local social media, Google search";
        attribute :>> willingnessToPayIndicator = "medium";
    }

    part regularMultiPetOwner : CustomerSegment {
        doc /* Owners with multiple dogs or who book on a regular
             * schedule (e.g. every 6–8 weeks). Higher lifetime
             * value, predictable demand. May benefit from a
             * loyalty or subscription discount. */
        attribute :>> segmentName = "Regular and multi-pet owners";
        attribute :>> description = "Owners who book regularly or have multiple dogs — loyal, repeat customers";
        attribute :>> needs = "Consistency, familiarity with their dogs, flexible scheduling, multi-pet discounts";
        attribute :>> acquisitionChannel = "Repeat booking, referral, loyalty programme";
        attribute :>> willingnessToPayIndicator = "medium-high";
    }

    part shopWalkIn : Channel {
        attribute :>> channelName = "Shop and walk-in";
        attribute :>> description = "In-person booking and drop-off at the grooming salon";
        attribute :>> channelType = "acquisition and delivery";
        attribute :>> estimatedReach = "local — walking distance or short drive";
        attribute :>> estimatedCostLevel = "low";
        attribute :>> conversionNotes = "High — customer has brought their dog, strong intent";
    }

    part onlineBookingChannel : Channel {
        attribute :>> channelName = "Online booking";
        attribute :>> description = "Website or app for appointment booking, service selection, and breed/size information";
        attribute :>> channelType = "acquisition and service";
        attribute :>> estimatedReach = "local area — service radius";
        attribute :>> estimatedCostLevel = "medium";
        attribute :>> conversionNotes = "Moderate — depends on reviews and visibility in local search";
    }

    // -- Differentiation Claims --------------------------------

    part breedExpertise : DifferentiationClaim {
        attribute :>> claimName = "Breed-specific grooming expertise";
        attribute :>> statement = "Every groom is tailored to your dog's breed standard and coat type — not a one-size-fits-all clip";
        attribute :>> basis = "Groomers trained in breed-specific techniques; reference library of breed grooming standards maintained";
        attribute :>> testability = "Customer satisfaction by breed type; before/after photos; groomer certification records";
    }

    part lowStressEnvironment : DifferentiationClaim {
        attribute :>> claimName = "Low-stress, gentle handling";
        attribute :>> statement = "We prioritise your dog's comfort — calm environment, patient handling, breaks when needed";
        attribute :>> basis = "Appointment spacing allows adequate time; no rush; one dog per groomer at a time; quiet salon design";
        attribute :>> testability = "Customer feedback on dog's demeanour post-groom; repeat booking rates; incident log frequency";
    }

    // -- Service Subject and Participants ---------------------
    //
    // The paying customer (pet owner) is not the service
    // subject (the dog). These two concepts capture the
    // structural distinction that the original Paws model
    // observation identified (Session 44, resolved Session 55).

    part dogSubject : ServiceSubject {
        doc /* The dog: service subject. Receives the grooming.
             * Has independent welfare needs under the Animal
             * Welfare Act 2006. The groomer's professional duty
             * of care is to the dog — if the animal shows signs
             * of distress, grooming must be paused or adapted
             * regardless of the owner's preferences.
             *
             * This is the participation that most directly maps
             * to GSL's patient: an entity with independent needs,
             * independent governance obligations, and a status
             * that is tracked through the service workflow. */
        attribute :>> subjectName = "Dog";
        attribute :>> entityDescription = "Animal — the dog being groomed";
        attribute :>> independentNeeds = "Animal welfare: calm environment, patient handling, breaks when needed, no unnecessary suffering. Breed-specific coat care requirements. Health issues (skin conditions, lumps, parasites) must be observed and reported to owner.";
        attribute :>> conditionNotes = "Assessed at check-in: coat condition, matting, skin issues, temperament, any special instructions from owner";
        attribute :>> statusNotes = "";
    }

    part petOwnerParticipant : ServiceParticipant {
        doc /* The pet owner: customer, payer, and decision-maker.
             * Books the appointment, pays for the service, states
             * grooming preferences, and collects the dog afterward.
             * The owner's preferences may be overridden by the
             * groomer's duty of care to the animal. */
        attribute :>> participantName = "Pet owner";
        attribute :>> participantRole = "customer, payer, decision-maker";
        attribute :>> entityDescription = "Person — the dog's owner or carer";
        attribute :>> relationshipToEngagement = "Commissions and pays for the grooming service. States preferences for grooming style. Collects the dog and receives any observations about health or condition.";
        attribute :>> statusNotes = "";
    }

    // -- Catalogue Entries ------------------------------------
    //
    // Service offerings as catalogue items. Uses the generic
    // BMM CatalogueEntry — no domain-typed specialisation.
    // Same pattern as Suds (design decision P3-D1 from Stage 2).

    part fullGroomCatalogue : CatalogueEntry {
        doc /* Full groom offering as a catalogue entry.
             * Per-appointment pricing with breed/size bands. */
        attribute :>> entryName = "Full Groom";
        attribute :>> itemReference = "fullGroom";
        attribute :>> pricingDescription = "From £35 (small breed) to £65 (large/double-coated breed)";
        attribute :>> availabilityStatus = "active";
        attribute :>> provisionType = "service";
        attribute :>> effectiveDate = "2026-03-19";
        attribute :>> statusNotes = "Core offering — by appointment, typically 60-120 min";
    }

    part washAndTidyCatalogue : CatalogueEntry {
        doc /* Wash and tidy — lighter service, lower price point. */
        attribute :>> entryName = "Wash and Tidy";
        attribute :>> itemReference = "washAndTidy";
        attribute :>> pricingDescription = "From £20 (small breed) to £40 (large breed)";
        attribute :>> availabilityStatus = "active";
        attribute :>> provisionType = "service";
        attribute :>> effectiveDate = "2026-03-19";
        attribute :>> statusNotes = "Lighter grooming option — 30-60 min";
    }

    part nailTrimCatalogue : CatalogueEntry {
        doc /* Nail trim — standalone or add-on. Fixed price. */
        attribute :>> entryName = "Nail Trim";
        attribute :>> itemReference = "nailTrimAddOn";
        attribute :>> pricingDescription = "£10 standalone, £5 as add-on";
        attribute :>> availabilityStatus = "active";
        attribute :>> provisionType = "service";
        attribute :>> effectiveDate = "2026-03-19";
        attribute :>> statusNotes = "Quick service — 15 min. Walk-in or booked.";
    }

    // -- Activity Model ---------------------------------------
    //
    // Eight activity types following the five-category taxonomy.
    // The process shape is sequential, one-animal-at-a-time —
    // fundamentally different from Suds (batch) and Cafe (immediate).

    part checkInAndAssess : ActivityType {
        doc /* Service delivery: intake. Owner drops off dog,
             * groomer assesses coat condition, skin issues,
             * matting, temperament. Confirms service and any
             * special instructions. */
        attribute :>> activityTypeName = "Check-in and assess";
        attribute :>> activityCategory = ActivityCategory::serviceDelivery;
        attribute :>> description = "Greet owner and dog, confirm service booked, assess coat condition, note any skin issues or matting, record special instructions";
        attribute :>> expectedDurationMinutes = 10;
        attribute :>> frequencyNotes = "Per appointment";
    }

    part batheAndDry : ActivityType {
        doc /* Service delivery: washing. Shampoo appropriate to
             * coat type, rinse, conditioning if needed. Blow-dry
             * or cage-dry depending on breed and temperament.
             * Significant duration variation by coat type. */
        attribute :>> activityTypeName = "Bathe and dry";
        attribute :>> activityCategory = ActivityCategory::serviceDelivery;
        attribute :>> description = "Bathe with breed-appropriate shampoo, rinse, condition if needed, blow-dry to appropriate finish";
        attribute :>> expectedDurationMinutes = 30;
        attribute :>> frequencyNotes = "Per grooming appointment (full groom and wash-and-tidy)";
    }

    part clipAndStyle : ActivityType {
        doc /* Service delivery: the main grooming work. Clipping,
             * scissoring, hand-stripping (for wire-coated breeds)
             * to breed standard or owner preference. Highly
             * variable duration: 20 min for a simple clip to
             * 60+ min for a show trim on a double-coated breed. */
        attribute :>> activityTypeName = "Clip and style";
        attribute :>> activityCategory = ActivityCategory::serviceDelivery;
        attribute :>> description = "Clip, scissor, or hand-strip coat to breed standard or owner preference. Includes face, feet, ears, and sanitary areas.";
        attribute :>> expectedDurationMinutes = 45;
        attribute :>> frequencyNotes = "Per full groom appointment. Tidy trim only for wash-and-tidy.";
    }

    part nailTrimActivity : ActivityType {
        doc /* Service delivery: nail care. Clip to safe length,
             * file smooth, check dewclaws. Can be standalone
             * or part of a full groom. */
        attribute :>> activityTypeName = "Nail trim";
        attribute :>> activityCategory = ActivityCategory::serviceDelivery;
        attribute :>> description = "Clip nails to safe length, file smooth, check and trim dewclaws if present";
        attribute :>> expectedDurationMinutes = 10;
        attribute :>> frequencyNotes = "Per appointment — standalone or as part of full groom";
    }

    part finishAndHandover : ActivityType {
        doc /* Service delivery: final step. Finishing spray,
             * bandana or bow if requested. Final quality check.
             * Notify owner, handover, discuss any observations
             * (skin issues, matting, lumps noticed). */
        attribute :>> activityTypeName = "Finish and handover";
        attribute :>> activityCategory = ActivityCategory::serviceDelivery;
        attribute :>> description = "Apply finishing spray, attach bandana/bow, final quality check, notify owner, handover dog, discuss any observations";
        attribute :>> expectedDurationMinutes = 10;
        attribute :>> frequencyNotes = "Per appointment";
    }

    part equipmentCleanAndMaintenance : ActivityType {
        doc /* Service enabling: keeping grooming equipment in good
             * order. Clean and disinfect tables, baths, dryers.
             * Sharpen and oil clipper blades. Check dryer filters. */
        attribute :>> activityTypeName = "Equipment cleaning and maintenance";
        attribute :>> activityCategory = ActivityCategory::serviceEnabling;
        attribute :>> description = "Clean and disinfect grooming tables, baths, and tools. Sharpen clipper blades. Check dryer filters and hoses.";
        attribute :>> expectedDurationMinutes = 20;
        attribute :>> frequencyNotes = "Between appointments (quick clean) and end of day (thorough)";
    }

    part welfareAndSafetyChecks : ActivityType {
        doc /* Governance: periodic checks that animal welfare and
             * workplace safety standards are maintained. First aid
             * kit, incident log review, premises hygiene, safe
             * handling practices. */
        attribute :>> activityTypeName = "Welfare and safety checks";
        attribute :>> activityCategory = ActivityCategory::governance;
        attribute :>> description = "Review incident log, check first aid kit stock, inspect premises hygiene, verify safe handling practices observed";
        attribute :>> expectedDurationMinutes = 15;
        attribute :>> frequencyNotes = "Weekly";
    }

    part bookingAndAdministration : ActivityType {
        doc /* Overhead: managing the appointment book, taking
             * payments, responding to enquiries, managing the
             * online booking system. */
        attribute :>> activityTypeName = "Booking and administration";
        attribute :>> activityCategory = ActivityCategory::overhead;
        attribute :>> description = "Manage appointment diary, process payments, respond to enquiries, update online booking system, daily reconciliation";
        attribute :>> expectedDurationMinutes = 30;
        attribute :>> frequencyNotes = "Daily — distributed throughout the day";
    }

    // -- Granularity policy ------------------------------------

    part serviceDeliveryGranularity : ActivityGranularity {
        doc /* Service delivery is tracked — each appointment's
             * journey through check-in → groom → handover generates
             * observable events per step. */
        attribute :>> businessArea = "Service delivery";
        attribute :>> currentLevel = GranularityLevel::tracked;
        attribute :>> targetLevel = GranularityLevel::tracked;
        attribute :>> migrationNotes = "Tracked via appointment workflow events through all grooming stages";
    }

    part enablingGranularity : ActivityGranularity {
        attribute :>> businessArea = "Service enabling";
        attribute :>> currentLevel = GranularityLevel::category;
        attribute :>> targetLevel = GranularityLevel::category;
        attribute :>> migrationNotes = "Equipment maintenance logged as category-level events between appointments and at end of day";
    }

    part governanceGranularity : ActivityGranularity {
        attribute :>> businessArea = "Governance";
        attribute :>> currentLevel = GranularityLevel::category;
        attribute :>> targetLevel = GranularityLevel::category;
        attribute :>> migrationNotes = "Weekly welfare checks — category level adequate for general duty of care (no specific regulatory audit trail required unlike COSHH)";
    }

    part developmentGranularity : ActivityGranularity {
        attribute :>> businessArea = "Development";
        attribute :>> currentLevel = GranularityLevel::envelope;
        attribute :>> targetLevel = GranularityLevel::envelope;
        attribute :>> migrationNotes = "CPD and breed training — envelope adequate";
    }

    part overheadGranularity : ActivityGranularity {
        attribute :>> businessArea = "Overhead";
        attribute :>> currentLevel = GranularityLevel::envelope;
        attribute :>> targetLevel = GranularityLevel::envelope;
        attribute :>> migrationNotes = "Daily admin — envelope adequate";
    }

    // -- Activity cost allocations ----------------------------

    part groomingLabourCostAllocation : ActivityCostAllocation {
        doc /* Cost allocation for grooming labour. The groomer's
             * time is the primary variable cost — allocated per
             * appointment based on expected duration. */
        ref :>> activityType = clipAndStyle;
        attribute :>> allocationMethod = "labour time allocation";
        attribute :>> estimatedCostPerUnit = 12.50;
        attribute :>> costNotes = "45 min average at £16.50/hr = £12.38, rounded to £12.50. Varies significantly by breed/coat type.";
    }

    part consumablesCostAllocation : ActivityCostAllocation {
        doc /* Cost allocation for grooming consumables: shampoo,
             * conditioner, finishing spray, blade oil, ear cleaner.
             * Allocated per appointment as an average. */
        ref :>> activityType = batheAndDry;
        attribute :>> allocationMethod = "per-appointment average";
        attribute :>> estimatedCostPerUnit = 2.50;
        attribute :>> costNotes = "Shampoo £1.20, conditioner £0.60, finishing spray £0.40, sundries £0.30. Average across sizes.";
    }
}

// =========================================================================
// PAWS DEMONSTRATOR — Resource and Financial Planning
// =========================================================================

package PawsResourceFinancial {
    private import ScalarValues::*;
    private import BusinessModel::ResourcePlanning::*;
    private import BusinessModel::FinancialPlanning::*;
    private import PawsBusinessModel::*;

    // -- Resource types ----------------------------------------

    part dogGroomer : ResourceType {
        doc /* Qualified dog groomer — the primary resource.
             * City & Guilds Level 3 in Dog Grooming or
             * equivalent. Breed-specific training preferred. */
        attribute :>> resourceTypeName = "Dog groomer";
        attribute :>> category = "personnel";
        attribute :>> acquisitionMethod = "employed";
        attribute :>> costProfile = "£16.50 per hour";
        attribute :>> capacityUnit = "FTE";
    }

    part groomingEquipment : ResourceType {
        doc /* Grooming tables, professional clippers, scissor
             * sets, blade sets, slicker brushes, combs. One
             * station per groomer. */
        attribute :>> resourceTypeName = "Grooming equipment";
        attribute :>> category = "equipment";
        attribute :>> acquisitionMethod = "purchased";
        attribute :>> costProfile = "£2,000 initial per station, £50/month maintenance and replacement";
        attribute :>> capacityUnit = "stations";
    }

    part bathAndDryingEquipment : ResourceType {
        doc /* Professional dog bath (height-adjustable), high-velocity
             * dryer, stand dryer. Shared across groomers. */
        attribute :>> resourceTypeName = "Bath and drying equipment";
        attribute :>> category = "equipment";
        attribute :>> acquisitionMethod = "purchased";
        attribute :>> costProfile = "£1,500 initial, £30/month maintenance";
        attribute :>> capacityUnit = "stations";
    }

    part salonPremises : ResourceType {
        attribute :>> resourceTypeName = "Salon premises";
        attribute :>> category = "estate";
        attribute :>> acquisitionMethod = "rented";
        attribute :>> costProfile = "£1,200 per month rent";
        attribute :>> capacityUnit = "premises";
    }

    part groomingConsumables : ResourceType {
        doc /* Shampoo, conditioner, finishing sprays, ear cleaner,
             * styptic powder, blade oil, bandanas/bows. Ongoing
             * variable cost scaling with appointment volume. */
        attribute :>> resourceTypeName = "Grooming consumables";
        attribute :>> category = "consumables";
        attribute :>> acquisitionMethod = "purchased";
        attribute :>> costProfile = "£2.50 per appointment average";
        attribute :>> capacityUnit = "units";
    }

    part bookingSystem : ResourceType {
        doc /* Online booking and appointment management software.
             * Handles scheduling, reminders, customer records,
             * and payment processing. */
        attribute :>> resourceTypeName = "Booking and management system";
        attribute :>> category = "technology";
        attribute :>> acquisitionMethod = "subscribed";
        attribute :>> costProfile = "£40 per month subscription";
        attribute :>> capacityUnit = "instances";
    }

    // -- Capability -------------------------------------------

    part deliverGroomingAppointment : Capability {
        attribute :>> capabilityName = "Deliver a grooming appointment";
        attribute :>> description = "Receive a dog, assess condition, perform grooming to breed standard or owner preference, and return the dog in good condition";
        attribute :>> requiredResources = "1 groomer + grooming station + bath/dryer + consumables + premises + booking system";
        attribute :>> enabledOfferingsDescription = "Full groom, Wash and tidy, Nail trim";
    }

    // -- Capacity model ---------------------------------------

    part standardDayCapacity : CapacityModel {
        doc /* Capacity model for a single groomer working a
             * standard day. Appointment duration varies by
             * service type and breed, so capacity is expressed
             * as a range. */
        attribute :>> resourceConfiguration = "1 groomer + 1 grooming station + shared bath/dryer";
        attribute :>> throughputPerPeriod = "5-7 appointments";
        attribute :>> periodUnit = "per day";
        attribute :>> assumptions = "8-hour working day, average 75 min per full groom including turnover, 45 min per wash-and-tidy, 15 min per nail trim. Mix of appointment types.";
        attribute :>> bottleneck = "Groomer time — one dog per groomer at a time";
    }

    // -- Resource constraint ----------------------------------

    part animalWelfareDuty : ResourceConstraint {
        doc /* General duty of care under the Animal Welfare Act
             * 2006. Not a specific regulatory framework like COSHH
             * — rather a general professional obligation to ensure
             * animals are not caused unnecessary suffering.
             *
             * This exercises ResourceConstraint with a general
             * professional governance posture, distinct from Suds'
             * specific regulatory constraint. */
        attribute :>> constraintName = "Animal welfare duty of care";
        attribute :>> constraintType = "regulatory";
        ref :>> affectedResource = dogGroomer;
        attribute :>> limit = "All grooming must be performed with due regard for animal welfare. Dogs showing signs of distress, pain, or health issues must have grooming paused or adapted. Owner to be notified of any concerns.";
        attribute :>> regulatorySourceDescription = "Animal Welfare Act 2006 — duty of care to animals under your control";
    }

    // -- Revenue stream ---------------------------------------

    part groomingRevenue : RevenueStream {
        attribute :>> streamName = "Grooming service revenue";
        attribute :>> sourceSegment = "Individual pet owners and regular customers";
        attribute :>> triggerEvent = "Grooming appointment completed";
        ref :>> pricingModel = perAppointmentPricing;
        attribute :>> projectedVolume = "6 appointments per day average (1 groomer)";
    }

    // -- Cost drivers -----------------------------------------

    part groomerLabourCosts : CostDriver {
        attribute :>> driverName = "Groomer labour";
        ref :>> linkedResource = dogGroomer;
        attribute :>> costBehaviour = "semi-variable — fixed shifts, overtime for busy periods";
        attribute :>> estimatedUnitCost = 16.50;
        attribute :>> scalingFactor = "per hour";
    }

    part consumableCosts : CostDriver {
        attribute :>> driverName = "Grooming consumables";
        ref :>> linkedResource = groomingConsumables;
        attribute :>> costBehaviour = "variable";
        attribute :>> estimatedUnitCost = 2.50;
        attribute :>> scalingFactor = "per appointment";
    }

    part salonRentCosts : CostDriver {
        attribute :>> driverName = "Salon rent";
        ref :>> linkedResource = salonPremises;
        attribute :>> costBehaviour = "fixed";
        attribute :>> estimatedUnitCost = 1200.0;
        attribute :>> scalingFactor = "per month";
    }

    part equipmentMaintenanceCosts : CostDriver {
        attribute :>> driverName = "Equipment maintenance and replacement";
        ref :>> linkedResource = groomingEquipment;
        attribute :>> costBehaviour = "fixed";
        attribute :>> estimatedUnitCost = 80.0;
        attribute :>> scalingFactor = "per month";
    }

    // -- Unit economics ---------------------------------------

    part fullGroomEconomics : UnitEconomics {
        doc /* Per-appointment economics for a full groom.
             * Average across breed sizes. Revenue varies by
             * size band; costs are relatively stable. */
        ref :>> offering = fullGroom;
        attribute :>> revenuePerUnit = 48.0;
        attribute :>> costPerUnit = 22.0;
        attribute :>> marginPerUnit = 26.0;
        attribute :>> breakdownNotes = "Labour £16.50 (avg 60 min), consumables £2.50, equipment wear £1.50, booking system £1.50. Rent excluded (fixed cost). Revenue is weighted average across size bands.";
    }

    part washAndTidyEconomics : UnitEconomics {
        doc /* Per-appointment economics for wash and tidy.
             * Shorter appointment, lower price, but good margin
             * due to reduced labour time. */
        ref :>> offering = washAndTidy;
        attribute :>> revenuePerUnit = 28.0;
        attribute :>> costPerUnit = 13.0;
        attribute :>> marginPerUnit = 15.0;
        attribute :>> breakdownNotes = "Labour £8.25 (avg 30 min), consumables £2.00, equipment wear £1.25, booking system £1.50. Rent excluded.";
    }

    part nailTrimEconomics : UnitEconomics {
        doc /* Per-appointment economics for nail trim.
             * Quick, low-cost service. Good margin as a
             * standalone; excellent as an add-on since the
             * dog is already on the table. */
        ref :>> offering = nailTrimAddOn;
        attribute :>> revenuePerUnit = 10.0;
        attribute :>> costPerUnit = 3.50;
        attribute :>> marginPerUnit = 6.50;
        attribute :>> breakdownNotes = "Labour £4.13 (15 min) as standalone. As add-on: marginal cost near zero (dog already present). Consumables negligible.";
    }

    // -- Pricing model ----------------------------------------

    part perAppointmentPricing : PricingModel {
        doc /* Per-appointment pricing with breed/size bands.
             * Three size categories: small (up to 10kg),
             * medium (10-25kg), large (25kg+). Double-coated
             * breeds attract a surcharge. */
        attribute :>> pricingModelName = "Per-appointment with breed/size bands";
        attribute :>> pricingType = PricingType::perEpisode;
        attribute :>> basePrice = 35.0;
        attribute :>> adjustmentLogic = "Full groom: small £35, medium £48, large £65. Wash and tidy: small £20, medium £28, large £40. Nail trim: £10 standalone, £5 add-on. Double-coated breed surcharge +£10.";
        attribute :>> applicableOfferings = "Full groom, Wash and tidy, Nail trim";
    }
}

// =========================================================================
// PAWS DEMONSTRATOR — Governance: Animal Welfare Duty of Care
// =========================================================================
//
// Exercises the governance vocabulary (A8, J8) with a general
// professional governance posture — distinct from Suds' specific
// COSHH regulatory framework.
//
// No constraint def / satisfy chain here. The Animal Welfare Act
// 2006 imposes a general duty of care, not specific testable
// conditions expressible as Boolean predicates. The governance
// traceability is: requirement → audit evidence (without the
// intermediate constraint formalisation).
//
// This is a valid cross-domain test: not all governance is
// specific-regulation governance. The vocabulary should handle
// both postures.
//
// Session 44 (19 March 2026): initial governance model.
// =========================================================================

package PawsGovernance {
    private import ScalarValues::*;
    private import BusinessModel::ServiceConcept::ExternalReference;
    private import BusinessModel::GovernanceMapping::*;

    doc /* Animal welfare governance for the Paws grooming service.
         * Demonstrates the governance vocabulary under a general
         * professional duty of care — no specific regulation like
         * COSHH, but still requiring auditable evidence of
         * responsible practice.
         *
         * The GovernanceRequirement and AuditEvidenceRecord part
         * defs are General BMM vocabulary from
         * BusinessModel::GovernanceMapping. No domain-specific
         * constraint defs needed — the obligations are general,
         * not formally testable as Boolean predicates. */

    // -- Governance Requirement --------------------------------

    requirement animalWelfareDutyOfCare : GovernanceRequirement {
        doc /* Animal Welfare Act 2006 — duty of care to animals
             * under your control. Applies to any person responsible
             * for an animal, including during grooming. Five welfare
             * needs: suitable environment, suitable diet, ability to
             * exhibit normal behaviour, housing with or apart from
             * other animals, protection from pain, suffering, injury
             * and disease.
             *
             * This is a general duty, not a prescriptive set of
             * testable conditions. Compliance is demonstrated through
             * professional practice, training, and incident-free
             * operation — hence audit evidence records rather than
             * formal constraint satisfaction. */

        attribute :>> requirementId = "PAWS-GOV-001";
        attribute :>> title = "Animal welfare duty of care during grooming";
        attribute :>> regulatorySource = "Animal Welfare Act 2006 — Section 9 (duty of person responsible for animal to ensure welfare)";
        attribute :>> complianceDescription = "All grooming must be performed with due regard for the animal's welfare. Dogs must not be caused unnecessary suffering. Signs of distress must be recognised and acted upon. Health concerns observed during grooming must be communicated to the owner. Equipment must be maintained in safe working order. The grooming environment must be suitable for dogs.";
        attribute :>> evidenceRequired = "Public liability insurance, incident and observation log, first aid kit inspection records, groomer training and CPD records";
    }

    // -- Audit Evidence Records -------------------------------

    part publicLiabilityInsurance : AuditEvidenceRecord {
        doc /* Current public liability insurance certificate.
             * Required for any business handling animals on
             * premises. Covers injury to animals and third parties. */
        attribute :>> evidenceType = "insurance certificate";
        attribute :>> evidenceDescription = "Current public liability insurance policy covering dog grooming services. Must cover injury to animals in care and injury to third parties on premises.";
        attribute :>> retentionPeriod = "Duration of policy plus 6 years";
        attribute :>> responsibleRole = "Business owner";
        attribute :>> frequency = "Annual renewal — certificate held on file";
    }

    part incidentAndObservationLog : AuditEvidenceRecord {
        doc /* Log of any incidents during grooming (nicks, stress
             * reactions, health concerns observed) and actions
             * taken. Demonstrates duty of care through transparent
             * recording and appropriate response. */
        attribute :>> evidenceType = "incident log";
        attribute :>> evidenceDescription = "Dated record of any grooming incidents (cuts, abrasions, stress responses), health observations (lumps, skin conditions, parasites), and actions taken (grooming paused, owner notified, vet referral suggested). Includes near-misses.";
        attribute :>> retentionPeriod = "5 years";
        attribute :>> responsibleRole = "Groomer on duty";
        attribute :>> frequency = "Per incident — reviewed weekly by business owner";
    }

    part firstAidKitInspection : AuditEvidenceRecord {
        doc /* Periodic inspection of the animal first aid kit.
             * Styptic powder, bandages, antiseptic, eye wash,
             * emergency vet contact details. */
        attribute :>> evidenceType = "inspection record";
        attribute :>> evidenceDescription = "Dated record of animal first aid kit inspection: styptic powder stock, bandage supply, antiseptic availability, eye wash expiry check, emergency vet contact details current.";
        attribute :>> retentionPeriod = "3 years";
        attribute :>> responsibleRole = "Business owner or senior groomer";
        attribute :>> frequency = "Monthly";
    }

    // -- External References ----------------------------------

    part animalWelfareActReference : ExternalReference {
        doc /* The Animal Welfare Act 2006 — the primary legislative
             * reference for duty of care obligations. */
        attribute :>> referenceType = "primary legislation";
        attribute :>> referenceId = "AWA-2006";
        attribute :>> referenceSource = "UK Parliament — Animal Welfare Act 2006, Section 9";
        attribute :>> referenceNotes = "Duty of person responsible for animal to ensure welfare. Five welfare needs. Applies to any person responsible for an animal, including during commercial grooming services.";
    }
}
