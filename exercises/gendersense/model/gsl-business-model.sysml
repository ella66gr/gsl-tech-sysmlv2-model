// =========================================================================
// GSL BUSINESS MODEL — GenderSense instantiation of the BMM concern vocabulary
// =========================================================================
//
// OP-132 step 5 (S515, ADR-012). The GSL Variant A (Lean Clinical) and
// Variant B (Full Platform) usages that lived at package level inside
// BusinessModel::ServiceConcept, ::ResourcePlanning, ::FinancialPlanning
// and ::StakeholderModel. Flat package, as PawsBusinessModel is. The
// General part defs stay in model/business-model.sysml.
// =========================================================================

package GslBusinessModel {
    private import ScalarValues::*;
    private import BusinessMetamodelGeneral::ServiceConcept::*;
    private import BusinessMetamodelGeneral::ResourcePlanning::*;
    private import BusinessMetamodelGeneral::FinancialPlanning::*;
    private import BusinessMetamodelGeneral::StakeholderModel::*;
    private import GslScenarios::*;  // objective* requirements and *Scenario usages bound by ref

    doc /* GenderSense Limited business model: concrete customer segments,
         * value propositions, service offerings, channels, resources,
         * capabilities, revenue streams, cost drivers, pricing and
         * stakeholder relationships for Variant A (Lean Clinical) and
         * Variant B (Full Platform). Tenant content; the vocabulary it
         * instantiates is BusinessModel (BMG after OP-132 step 9). */

    // -- GSL Service Concept instantiation -----------------
    //
    // Lean Clinical variant (Variant A) service concept.
    // These are the concrete values for the initial business
    // model configuration.

    // Customer segments

    part selfReferringIndividuals : CustomerSegment {
        doc /* Adults seeking gender-affirming care who find GSL
             * directly via web search, social media, or community
             * referral. Typically motivated by long NHS wait times. */
        attribute :>> segmentName = "Self-referring individuals";
        attribute :>> description = "Adults seeking gender-affirming care who self-refer";
        attribute :>> needs = "Timely access to specialist assessment and hormone therapy";
        attribute :>> acquisitionChannel = "Website/SEO, social media, community word of mouth";
        attribute :>> willingnessToPayIndicator = "medium";
    }

    part gpReferredPatients : CustomerSegment {
        doc /* Patients referred by their GP, often with a letter
             * of referral. May be partially funded via shared care
             * arrangements. */
        attribute :>> segmentName = "GP-referred patients";
        attribute :>> description = "Patients referred by their GP for specialist gender care";
        attribute :>> needs = "Specialist assessment with clear communication back to GP";
        attribute :>> acquisitionChannel = "GP referral network";
        attribute :>> willingnessToPayIndicator = "medium-high";
    }

    // Value propositions

    part fasterAccess : ValueProposition {
        attribute :>> propositionName = "Faster access than NHS";
        attribute :>> description = "Assessment within weeks, not years";
        ref :>> targetSegment = selfReferringIndividuals;
        attribute :>> differentiator = "NHS GIC median wait exceeds 4 years";
        attribute :>> evidenceBasis = "Published NHS waiting time data";
    }

    part integratedDigitalClinical : ValueProposition {
        attribute :>> propositionName = "Integrated digital and clinical care";
        attribute :>> description = "Patient portal with real-time pathway visibility alongside clinical expertise";
        ref :>> targetSegment = selfReferringIndividuals;
        attribute :>> differentiator = "Most private gender services offer clinical-only with no digital integration";
        attribute :>> evidenceBasis = "Platform capability comparison";
    }

    part specialistExpertise : ValueProposition {
        attribute :>> propositionName = "Specialist expertise";
        attribute :>> description = "Care delivered by clinicians with specific gender identity healthcare credentials";
        ref :>> targetSegment = gpReferredPatients;
        attribute :>> differentiator = "RCP Certificate in Gender Identity Healthcare";
        attribute :>> evidenceBasis = "Professional qualification and clinical experience";
    }

    // Service offerings

    part initialAssessment : ServiceOffering {
        doc /* Comprehensive new patient assessment. Two sessions
             * over approximately two weeks. Maps to the Assessment
             * clinical pathway. */
        attribute :>> offeringName = "Initial Assessment";
        attribute :>> description = "Comprehensive new patient assessment (2 sessions over 2 weeks)";
        attribute :>> scope = "History taking, mental health screening, physical assessment, treatment planning";
        attribute :>> pricingBasis = "per-episode";
        attribute :>> estimatedDurationWeeks = 2;
        attribute :>> clinicalPathwayRef = "ClinicalPathways::Assessment";
    }

    part hormoneTherapyInitiation : ServiceOffering {
        doc /* From baseline bloods through to stable regimen.
             * Typical duration 6-12 months. Maps to the Hormone
             * Therapy Initiation clinical pathway. */
        attribute :>> offeringName = "Hormone Therapy Initiation";
        attribute :>> description = "From baseline bloods through to stable regimen";
        attribute :>> scope = "Baseline investigations, prescribing, titration, monitoring until stable";
        attribute :>> pricingBasis = "per-episode";
        attribute :>> estimatedDurationWeeks = 36;
        attribute :>> clinicalPathwayRef = "ClinicalPathways::HormoneTherapy::HormoneTherapyInitiation";
    }

    part ongoingMonitoring : ServiceOffering {
        doc /* Quarterly monitoring reviews once stable. Ongoing
             * service with no fixed end date. Maps to the Hormone
             * Therapy monitoring pathway. */
        attribute :>> offeringName = "Ongoing Monitoring";
        attribute :>> description = "Quarterly monitoring reviews once stable";
        attribute :>> scope = "Blood monitoring, clinical review, prescription renewal";
        attribute :>> pricingBasis = "per-episode";
        attribute :>> estimatedDurationWeeks = 0;  // ongoing, no fixed duration
        attribute :>> clinicalPathwayRef = "ClinicalPathways::HormoneTherapy";
    }

    // Channels

    part websiteSeo : Channel {
        attribute :>> channelName = "Website and SEO";
        attribute :>> description = "GenderSense website optimised for search visibility";
        attribute :>> channelType = "acquisition";
        attribute :>> estimatedReach = "moderate — depends on SEO investment and content strategy";
        attribute :>> estimatedCostLevel = "low";
        attribute :>> conversionNotes = "High intent traffic — people searching for gender services are typically ready to act";
    }

    part gpReferralNetwork : Channel {
        attribute :>> channelName = "GP referral network";
        attribute :>> description = "Relationships with GP practices for direct referrals";
        attribute :>> channelType = "acquisition";
        attribute :>> estimatedReach = "growing — depends on shared care agreements established";
        attribute :>> estimatedCostLevel = "medium";
        attribute :>> conversionNotes = "High conversion — GP referral implies clinical readiness";
    }

    // Differentiation claims

    part modelDrivenSafety : DifferentiationClaim {
        attribute :>> claimName = "Model-driven safety";
        attribute :>> statement = "Every clinical decision is checked against explicit, auditable rules";
        attribute :>> basis = "SysML-modelled constraints with generated runtime enforcement";
        attribute :>> testability = "Audit trail showing every constraint evaluation for every patient";
    }

    part patientPortalVisibility : DifferentiationClaim {
        attribute :>> claimName = "Patient portal with real-time pathway visibility";
        attribute :>> statement = "You can see exactly where you are in your care journey and what comes next";
        attribute :>> basis = "Patient portal reading from the same pathway model that drives clinical delivery";
        attribute :>> testability = "Patient satisfaction survey and portal usage metrics";
    }

    // -- Variant B (Full Platform) service offerings -------

    part coachingService : ServiceOffering {
        doc /* Gender identity coaching delivered by a trained
             * coach. Included in the Full Platform subscription.
             * No clinical pathway equivalent — coaching is a
             * non-clinical support offering. */
        attribute :>> offeringName = "Coaching";
        attribute :>> description = "Structured gender identity coaching sessions with a trained coach";
        attribute :>> scope = "Goal setting, self-advocacy skills, navigating social transition, wellbeing support";
        attribute :>> pricingBasis = "subscription";
        attribute :>> estimatedDurationWeeks = 0;  // ongoing, no fixed duration
        attribute :>> clinicalPathwayRef = "";     // non-clinical offering
    }

    part educationService : ServiceOffering {
        doc /* Structured education modules on gender-affirming
             * care topics. Included in subscription. Self-paced
             * digital content with optional live sessions. */
        attribute :>> offeringName = "Education";
        attribute :>> description = "Structured education modules on gender-affirming care and wellbeing";
        attribute :>> scope = "Understanding hormones, managing expectations, health literacy, rights and access";
        attribute :>> pricingBasis = "subscription";
        attribute :>> estimatedDurationWeeks = 0;  // ongoing library, no fixed duration
        attribute :>> clinicalPathwayRef = "";     // non-clinical offering
    }

    part communityAccess : ServiceOffering {
        doc /* Moderated peer community platform. Included in
             * subscription. Provides peer support, shared
             * experience, and community connection. */
        attribute :>> offeringName = "Community";
        attribute :>> description = "Moderated peer community platform for shared experience and support";
        attribute :>> scope = "Peer forums, facilitated groups, community events, resource sharing";
        attribute :>> pricingBasis = "subscription";
        attribute :>> estimatedDurationWeeks = 0;  // ongoing, no fixed duration
        attribute :>> clinicalPathwayRef = "";     // non-clinical offering
    }

    part subscriptionBundle : ServiceOffering {
        doc /* Composite service offering representing the monthly
             * subscription package. Bundles Coaching, Education,
             * and Community into a single offering for pricing
             * and unit economics purposes. Clinical services
             * (assessment, monitoring) are separate. */
        attribute :>> offeringName = "Subscription (monthly)";
        attribute :>> description = "Monthly subscription bundling coaching, education, and peer community access";
        attribute :>> scope = "Coaching sessions, education modules, community platform access";
        attribute :>> pricingBasis = "subscription";
        attribute :>> estimatedDurationWeeks = 0;  // ongoing, no fixed duration
        attribute :>> clinicalPathwayRef = "";     // non-clinical offering
    }

    // -- Variant B value propositions ----------------------

    part holisticCareModel : ValueProposition {
        attribute :>> propositionName = "Holistic care model";
        attribute :>> description = "Clinical care, coaching, education, and peer community as one integrated package";
        ref :>> targetSegment = selfReferringIndividuals;
        attribute :>> differentiator = "No other UK gender service offers clinical + coaching + community as a single subscription";
        attribute :>> evidenceBasis = "Service offering comparison with existing providers";
    }

    // -- GSL Lean Clinical resource instantiation ----------

    part prescribingClinician : ResourceType {
        doc /* Clinician with prescribing qualification and RCP
             * Certificate in Gender Identity Healthcare. The
             * primary clinical resource and capacity bottleneck. */
        attribute :>> resourceTypeName = "Prescribing clinician";
        attribute :>> category = "personnel";
        attribute :>> acquisitionMethod = "employed or contracted";
        attribute :>> costProfile = "£5,000 per FTE per month";
        attribute :>> capacityUnit = "FTE";
    }

    part administrativeSupport : ResourceType {
        attribute :>> resourceTypeName = "Administrative support";
        attribute :>> category = "personnel";
        attribute :>> acquisitionMethod = "employed";
        attribute :>> costProfile = "£1,800 per FTE per month";
        attribute :>> capacityUnit = "FTE";
    }

    part technologyPlatform : ResourceType {
        doc /* The GSL platform: SvelteKit web app, Temporal
             * orchestration, EHRbase CDR, hosting infrastructure. */
        attribute :>> resourceTypeName = "Technology platform";
        attribute :>> category = "technology";
        attribute :>> acquisitionMethod = "self-built and hosted";
        attribute :>> costProfile = "£200 per month fixed";
        attribute :>> capacityUnit = "instances";
    }

    part clinicalPremises : ResourceType {
        attribute :>> resourceTypeName = "Clinical premises";
        attribute :>> category = "estate";
        attribute :>> acquisitionMethod = "rented or shared";
        attribute :>> costProfile = "included in overhead allocation";
        attribute :>> capacityUnit = "rooms";
    }

    part professionalIndemnity : ResourceType {
        attribute :>> resourceTypeName = "Professional indemnity insurance";
        attribute :>> category = "insurance";
        attribute :>> acquisitionMethod = "annual policy";
        attribute :>> costProfile = "£250 per month";
        attribute :>> capacityUnit = "policies";
    }

    part laboratoryServices : ResourceType {
        doc /* External pathology laboratory for blood monitoring.
             * Variable cost — scales with patient volume. */
        attribute :>> resourceTypeName = "Laboratory services";
        attribute :>> category = "external service";
        attribute :>> acquisitionMethod = "contracted";
        attribute :>> costProfile = "£45 per blood panel";
        attribute :>> capacityUnit = "panels";
    }

    part clinicianMonth1to9 : ResourceInstance {
        doc /* Initial clinician capacity: 0.5 FTE for the first
             * 9 months. Sufficient for up to ~20 active patients. */
        attribute :>> instanceName = "Prescribing clinician (months 1-9)";
        ref :>> resourceType = prescribingClinician;
        attribute :>> capacity = "0.5 FTE";
        attribute :>> availabilityNotes = "3 clinical days per fortnight";
        attribute :>> costPerUnit = 2500.0;
        attribute :>> costBasis = "per month";
    }

    part clinicianMonth10to24 : ResourceInstance {
        doc /* Scaled clinician capacity: 0.8 FTE from month 10.
             * Supports growth to ~40 active patients. */
        attribute :>> instanceName = "Prescribing clinician (months 10-24)";
        ref :>> resourceType = prescribingClinician;
        attribute :>> capacity = "0.8 FTE";
        attribute :>> availabilityNotes = "4 clinical days per week";
        attribute :>> costPerUnit = 4000.0;
        attribute :>> costBasis = "per month";
    }

    part adminInstance : ResourceInstance {
        attribute :>> instanceName = "Administrative support";
        ref :>> resourceType = administrativeSupport;
        attribute :>> capacity = "0.3 FTE";
        attribute :>> availabilityNotes = "1.5 days per week";
        attribute :>> costPerUnit = 540.0;
        attribute :>> costBasis = "per month";
    }

    part prescribingCapability : Capability {
        doc /* The ability to prescribe and monitor hormone therapy.
             * The core clinical capability of the Lean Clinical
             * variant. */
        attribute :>> capabilityName = "Prescribing and monitoring";
        attribute :>> description = "Prescribe, titrate, and monitor hormone therapy with full audit trail";
        attribute :>> requiredResources = "1 prescribing clinician + EHRbase CDR + lab interface + prescribing system";
        attribute :>> enabledOfferingsDescription = "Hormone Therapy Initiation, Ongoing Monitoring";
    }

    part assessmentCapability : Capability {
        attribute :>> capabilityName = "Clinical assessment";
        attribute :>> description = "Comprehensive new patient assessment with structured clinical record";
        attribute :>> requiredResources = "1 prescribing clinician + video consulting + forms platform + EHRbase CDR";
        attribute :>> enabledOfferingsDescription = "Initial Assessment";
    }

    part monitoringCapability : Capability {
        attribute :>> capabilityName = "Blood monitoring";
        attribute :>> description = "Order, receive, and review blood monitoring results";
        attribute :>> requiredResources = "Lab interface + EHRbase CDR + prescribing clinician for review";
        attribute :>> enabledOfferingsDescription = "Hormone Therapy Initiation, Ongoing Monitoring";
    }

    part leanClinicalCapacity : CapacityModel {
        doc /* Capacity model for the Lean Clinical variant.
             * Clinician time is the primary bottleneck. */
        attribute :>> resourceConfiguration = "1 prescribing clinician at 0.5-0.8 FTE";
        attribute :>> throughputPerPeriod = "20-40 active patients";
        attribute :>> periodUnit = "concurrent active caseload";
        attribute :>> assumptions = "8 monitoring slots per week at 0.5 FTE, 30 min per review, 2 hours admin per day";
        attribute :>> bottleneck = "Prescribing clinician time";
    }

    part maxPatientsPerClinician : ResourceConstraint {
        attribute :>> constraintName = "Maximum active patients per clinician";
        attribute :>> constraintType = "practical";
        ref :>> affectedResource = prescribingClinician;
        attribute :>> limit = "40 active patients per FTE clinician";
        attribute :>> regulatorySourceDescription = "";
    }

    part prescribingQualification : ResourceConstraint {
        doc /* Regulatory requirement: the prescribing clinician
             * must hold appropriate qualification for hormone
             * prescribing. Maps to Enterprise::Regulation. */
        attribute :>> constraintName = "Prescribing qualification";
        attribute :>> constraintType = "regulatory";
        ref :>> affectedResource = prescribingClinician;
        attribute :>> limit = "Must hold prescribing qualification and gender identity healthcare credential";
        attribute :>> regulatorySourceDescription = "GslEnterprise::Regulation";
    }

    // -- Variant B (Full Platform) resource instantiation --

    part genderCoach : ResourceType {
        doc /* Trained gender identity coach. Non-clinical role
             * delivering structured coaching sessions. */
        attribute :>> resourceTypeName = "Gender identity coach";
        attribute :>> category = "personnel";
        attribute :>> acquisitionMethod = "contracted";
        attribute :>> costProfile = "£3,000 per FTE per month";
        attribute :>> capacityUnit = "FTE";
    }

    part communityModerator : ResourceType {
        doc /* Part-time community management role. Moderates
             * peer forums, facilitates groups, manages content. */
        attribute :>> resourceTypeName = "Community moderator";
        attribute :>> category = "personnel";
        attribute :>> acquisitionMethod = "employed";
        attribute :>> costProfile = "£2,000 per FTE per month";
        attribute :>> capacityUnit = "FTE";
    }

    part coachInstance : ResourceInstance {
        attribute :>> instanceName = "Gender identity coach";
        ref :>> resourceType = genderCoach;
        attribute :>> capacity = "0.5 FTE";
        attribute :>> availabilityNotes = "2.5 days per week";
        attribute :>> costPerUnit = 1500.0;
        attribute :>> costBasis = "per month";
    }

    part moderatorInstance : ResourceInstance {
        attribute :>> instanceName = "Community moderator";
        ref :>> resourceType = communityModerator;
        attribute :>> capacity = "0.2 FTE";
        attribute :>> availabilityNotes = "1 day per week";
        attribute :>> costPerUnit = 400.0;
        attribute :>> costBasis = "per month";
    }

    part secondClinicianMonth6to24 : ResourceInstance {
        doc /* Second clinician added at month 6 in Variant B.
             * Steps from 0.5 to 1.0 FTE at month 12. */
        attribute :>> instanceName = "Second prescribing clinician (months 6-24)";
        ref :>> resourceType = prescribingClinician;
        attribute :>> capacity = "0.5 FTE stepping to 1.0 FTE at month 12";
        attribute :>> availabilityNotes = "Variant B only — earlier scaling than Variant A";
        attribute :>> costPerUnit = 2500.0;
        attribute :>> costBasis = "per month (at 0.5 FTE)";
    }

    part coachingCapability : Capability {
        attribute :>> capabilityName = "Gender identity coaching";
        attribute :>> description = "Deliver structured coaching sessions supporting social transition and wellbeing";
        attribute :>> requiredResources = "1 gender identity coach + video consulting + scheduling platform";
        attribute :>> enabledOfferingsDescription = "Coaching";
    }

    part communityCapability : Capability {
        attribute :>> capabilityName = "Peer community platform";
        attribute :>> description = "Operate moderated peer forums, facilitated groups, and community events";
        attribute :>> requiredResources = "1 community moderator + community platform software + content moderation tools";
        attribute :>> enabledOfferingsDescription = "Community";
    }

    part fullPlatformCapacity : CapacityModel {
        doc /* Capacity model for the Full Platform variant.
             * Multiple resource types with different bottlenecks. */
        attribute :>> resourceConfiguration = "2 prescribing clinicians (1.5-2.0 FTE total) + 0.5 FTE coach + 0.2 FTE moderator";
        attribute :>> throughputPerPeriod = "80-100 active patients";
        attribute :>> periodUnit = "concurrent active caseload";
        attribute :>> assumptions = "Clinical capacity doubled vs Variant A; coaching at 10 sessions/week; community moderation 1 day/week";
        attribute :>> bottleneck = "Prescribing clinician time (clinical); coach availability (coaching)";
    }

    // -- GSL Objective → Capability mappings (formerly BusinessModel::ResourcePlanning) --
    part patientCohortMapping : ObjectiveCapabilityMapping {
        doc /* objectivePatientCohort is achieved through
             * prescribing, assessment, and monitoring. */
        ref :>> strategicObjective = objectivePatientCohort;
    }

    part sharedCareMapping : ObjectiveCapabilityMapping {
        doc /* objectiveSharedCare is achieved through
             * prescribing and monitoring capabilities
             * extended with GP shared care protocols. */
        ref :>> strategicObjective = objectiveSharedCare;
    }

    part platformLaunchMapping : ObjectiveCapabilityMapping {
        doc /* objectivePlatformLaunch is achieved through
             * assessment and prescribing capabilities
             * exposed via the patient portal. */
        ref :>> strategicObjective = objectivePlatformLaunch;
    }

    part breakEvenMapping : ObjectiveCapabilityMapping {
        doc /* objectiveBreakEven is a financial outcome
             * achieved through the combined operation of
             * all clinical capabilities at sufficient
             * volume. No single capability satisfies it. */
        ref :>> strategicObjective = objectiveBreakEven;
    }

    // -- GSL Lean Clinical financial instantiation ----------

    part assessmentRevenue : RevenueStream {
        attribute :>> streamName = "Assessment fees";
        attribute :>> sourceSegment = "Self-referring individuals, GP-referred patients";
        attribute :>> triggerEvent = "Completion of initial assessment episode";
        ref :>> pricingModel = perEpisodePricing;
        attribute :>> projectedVolume = "4 per month (year 1), 6 per month (year 2)";
    }

    part monitoringRevenue : RevenueStream {
        attribute :>> streamName = "Monitoring fees";
        attribute :>> sourceSegment = "Patients in stable monitoring";
        attribute :>> triggerEvent = "Quarterly monitoring review";
        ref :>> pricingModel = perEpisodePricing;
        attribute :>> projectedVolume = "grows with stable cohort — see projection";
    }

    part clinicianCost : CostDriver {
        attribute :>> driverName = "Clinician cost";
        ref :>> linkedResource = prescribingClinician;
        attribute :>> costBehaviour = "semi-variable — fixed FTE cost, scaled in steps as caseload grows";
        attribute :>> estimatedUnitCost = 5000.0;
        attribute :>> scalingFactor = "per FTE per month";
    }

    part adminCost : CostDriver {
        attribute :>> driverName = "Administrative support cost";
        ref :>> linkedResource = administrativeSupport;
        attribute :>> costBehaviour = "semi-variable";
        attribute :>> estimatedUnitCost = 1800.0;
        attribute :>> scalingFactor = "per FTE per month";
    }

    part platformCost : CostDriver {
        attribute :>> driverName = "Platform hosting and infrastructure";
        ref :>> linkedResource = technologyPlatform;
        attribute :>> costBehaviour = "fixed";
        attribute :>> estimatedUnitCost = 200.0;
        attribute :>> scalingFactor = "per month";
    }

    part insuranceCost : CostDriver {
        attribute :>> driverName = "Professional indemnity insurance";
        ref :>> linkedResource = professionalIndemnity;
        attribute :>> costBehaviour = "fixed";
        attribute :>> estimatedUnitCost = 250.0;
        attribute :>> scalingFactor = "per month";
    }

    part labCost : CostDriver {
        attribute :>> driverName = "Laboratory costs";
        ref :>> linkedResource = laboratoryServices;
        attribute :>> costBehaviour = "variable";
        attribute :>> estimatedUnitCost = 45.0;
        attribute :>> scalingFactor = "per blood panel";
    }

    part overheadCost : CostDriver {
        attribute :>> driverName = "Overhead allocation";
        attribute :>> costBehaviour = "percentage of direct cost";
        attribute :>> estimatedUnitCost = 25.0;
        attribute :>> scalingFactor = "percentage of direct cost";
    }

    part assessmentUnitEconomics : UnitEconomics {
        ref :>> offering = initialAssessment;
        attribute :>> revenuePerUnit = 600.0;
        attribute :>> costPerUnit = 350.0;
        attribute :>> marginPerUnit = 250.0;
        attribute :>> breakdownNotes = "Clinician 2hrs £125, baseline bloods £90, platform/admin £65, overhead £70";
    }

    part monitoringUnitEconomics : UnitEconomics {
        ref :>> offering = ongoingMonitoring;
        attribute :>> revenuePerUnit = 150.0;
        attribute :>> costPerUnit = 106.0;
        attribute :>> marginPerUnit = 44.0;
        attribute :>> breakdownNotes = "Clinician 30min £31, blood panel £45, admin/platform £10, overhead £20";
    }

    part perEpisodePricing : PricingModel {
        attribute :>> pricingModelName = "Per-episode pricing";
        attribute :>> pricingType = PricingType::perEpisode;
        attribute :>> basePrice = 0.0;
        attribute :>> adjustmentLogic = "Fixed fee per service offering. Assessment £600, monitoring review £150.";
        attribute :>> applicableOfferings = "Initial Assessment, Hormone Therapy Initiation, Ongoing Monitoring";
    }

    part leanClinicalProjection : FinancialProjection {
        attribute :>> projectionName = "Lean Clinical 24-month projection";
        ref :>> scenario = leanClinicalScenario;
        attribute :>> timelineMonths = 24;
        attribute :>> revenueFormula = "assessment fees (volume x price) + monitoring fees (stable cohort x quarterly fee)";
        attribute :>> costFormula = "clinician FTE + admin FTE + platform + insurance + lab panels + 25% overhead";
        attribute :>> breakEvenIndicator = "estimated month 14 at base assumptions";
    }

    // -- Variant B (Full Platform) financial instantiation --

    part subscriptionRevenue : RevenueStream {
        doc /* Monthly subscription fee from active patients in
             * the Full Platform variant. Additive to clinical
             * episode fees — subscribers also pay per-episode
             * for clinical services. */
        attribute :>> streamName = "Subscription fees";
        attribute :>> sourceSegment = "Active subscribers (Full Platform patients)";
        attribute :>> triggerEvent = "Monthly subscription renewal";
        ref :>> pricingModel = subscriptionPricing;
        attribute :>> projectedVolume = "grows with active patient cohort";
    }

    part coachCost : CostDriver {
        attribute :>> driverName = "Coach cost";
        ref :>> linkedResource = genderCoach;
        attribute :>> costBehaviour = "semi-variable — fixed FTE cost, added when coaching offering launches";
        attribute :>> estimatedUnitCost = 3000.0;
        attribute :>> scalingFactor = "per FTE per month";
    }

    part moderatorCost : CostDriver {
        attribute :>> driverName = "Community moderator cost";
        ref :>> linkedResource = communityModerator;
        attribute :>> costBehaviour = "semi-variable — fixed FTE cost, added when community launches";
        attribute :>> estimatedUnitCost = 2000.0;
        attribute :>> scalingFactor = "per FTE per month";
    }

    part subscriptionPricing : PricingModel {
        doc /* Monthly subscription covering coaching, education,
             * and community access. Clinical services remain
             * per-episode on top of the subscription. */
        attribute :>> pricingModelName = "Monthly subscription";
        attribute :>> pricingType = PricingType::subscription;
        attribute :>> basePrice = 99.0;
        attribute :>> adjustmentLogic = "Flat monthly fee. Clinical episode fees charged separately.";
        attribute :>> applicableOfferings = "Coaching, Education, Community";
    }

    part subscriptionUnitEconomics : UnitEconomics {
        doc /* Per-subscriber economics for the subscription
             * component only. Clinical episode economics are
             * separate (assessmentUnitEconomics,
             * monitoringUnitEconomics). All values are
             * illustrative placeholders. */
        ref :>> offering = subscriptionBundle;
        attribute :>> revenuePerUnit = 99.0;
        attribute :>> costPerUnit = 55.0;
        attribute :>> marginPerUnit = 44.0;
        attribute :>> breakdownNotes = "Coach allocation £30, moderator allocation £8, platform £12, overhead £5. All values placeholder.";
    }

    part fullPlatformProjection : FinancialProjection {
        attribute :>> projectionName = "Full Platform 24-month projection";
        ref :>> scenario = fullPlatformScenario;
        attribute :>> timelineMonths = 24;
        attribute :>> revenueFormula = "assessment fees + monitoring fees + subscription fees (active subscribers x monthly fee)";
        attribute :>> costFormula = "2 clinician FTE + admin FTE + coach FTE + moderator FTE + platform + insurance + lab panels + 25% overhead";
        attribute :>> breakEvenIndicator = "placeholder — to be determined by projection engine";
    }

    // -- GSL StakeholderModel instantiation -----------------

    part cqcRelationship : StakeholderRelationship {
        doc /* Care Quality Commission — the primary regulatory
             * relationship for GSL as a registered healthcare
             * provider. */
        attribute :>> stakeholderName = "Care Quality Commission (CQC)";
        attribute :>> stakeholderDescription = "Independent regulator of health and social care in England. GSL is registered as a healthcare provider.";
        attribute :>> relationshipNature = RelationshipNature::regulatory;
        attribute :>> obligationsInward = "CQC sets and inspects against fundamental standards of care. Provides inspection reports, ratings, and enforcement actions.";
        attribute :>> obligationsOutward = "GSL must maintain registration, comply with fundamental standards, notify CQC of significant events, and cooperate with inspections.";
        attribute :>> informationExchanged = "Registration data, notification of incidents, inspection evidence (outward). Inspection reports, ratings, guidance (inward).";
        attribute :>> governanceArrangements = "Formal registration and periodic inspection cycle. Conditions of registration. Duty of candour.";
        attribute :>> healthIndicators = "Current CQC rating, time since last inspection, open enforcement actions, outstanding conditions.";
        attribute :>> reviewCadence = "Continuous compliance. Formal inspection cycle determined by CQC (typically 1-2 years for new registrations).";
    }

    part icbRelationship : StakeholderRelationship {
        doc /* NHS Integrated Care Board — commissioner relationship
             * for shared care funding. */
        attribute :>> stakeholderName = "NHS Integrated Care Board (ICB)";
        attribute :>> stakeholderDescription = "NHS body that commissions healthcare services. Relevant where shared care arrangements involve NHS funding.";
        attribute :>> relationshipNature = RelationshipNature::commissioning;
        attribute :>> obligationsInward = "ICB defines what services it will commission and fund. Provides commissioning specifications and payment.";
        attribute :>> obligationsOutward = "GSL must meet commissioning specifications, report activity and outcomes, maintain clinical standards.";
        attribute :>> informationExchanged = "Activity reports, outcome data, clinical governance reports (outward). Commissioning specifications, payment, policy updates (inward).";
        attribute :>> governanceArrangements = "Service level agreement or commissioning contract. Regular contract review meetings.";
        attribute :>> healthIndicators = "Contract compliance status, payment timeliness, relationship with commissioning lead.";
        attribute :>> reviewCadence = "Quarterly contract review. Annual recommissioning cycle.";
    }

    part sharedCareProtocol : CooperativeArrangement {
        doc /* NHS shared care protocol for hormone prescribing —
             * the defining cooperative arrangement for GSL. GP
             * monitors, GSL initiates and adjusts. */
        attribute :>> arrangementName = "Shared care hormone prescribing protocol";
        attribute :>> cooperatingEntity = "GP practices (via individual shared care agreements)";
        attribute :>> sharedOutcome = "Safe, monitored hormone therapy with prescribing initiated by GSL and ongoing monitoring shared with the patient's GP";
        attribute :>> responsibilitySplit = "GSL: specialist assessment, treatment initiation, dose adjustment, specialist review. GP: blood monitoring, repeat prescribing per protocol, flagging concerns.";
        attribute :>> protocolReference = "GSL Shared Care Protocol for Gender-Affirming Hormone Therapy (internal document)";
        attribute :>> informationSharing = "GSL sends treatment summaries and monitoring schedules. GP sends blood results and clinical observations. Via secure clinical correspondence.";
        attribute :>> disputeResolution = "Clinical disagreements escalated to GSL clinical lead. Protocol review if pattern of disagreement emerges.";
        attribute :>> performanceIndicators = "GP uptake rate, monitoring compliance rate, time to shared care agreement, adverse event rate under shared care.";
    }

    part gpReferralPathway : ReferralPathway {
        doc /* GP referrals inbound — the primary referral pathway
             * for GSL. Bidirectional: GSL also refers back to GP
             * for shared care monitoring. */
        attribute :>> pathwayName = "GP referral pathway";
        attribute :>> direction = ReferralDirection::bidirectional;
        attribute :>> referringEntity = "GP practices";
        attribute :>> referralCriteria = "Inbound: patient presenting with gender dysphoria or requesting gender-affirming care. Outbound: patient ready for shared care monitoring.";
        attribute :>> referralProtocol = "Inbound: referral letter with clinical history. Outbound: treatment summary with shared care protocol and monitoring schedule.";
        attribute :>> expectedResponseTime = "Inbound: acknowledgement within 5 working days. Outbound: GP response to shared care request within 10 working days.";
        attribute :>> feedbackMechanism = "Inbound: outcome letter to GP after assessment. Outbound: ongoing clinical correspondence per monitoring schedule.";
        attribute :>> volumeTracking = "Referral volumes tracked monthly. Conversion rate (referral to assessment). Shared care uptake rate.";
    }

    part specialistReferralPathway : ReferralPathway {
        doc /* Outbound specialist referrals — endocrinology,
             * surgery, mental health. */
        attribute :>> pathwayName = "Specialist referral pathway";
        attribute :>> direction = ReferralDirection::outbound;
        attribute :>> referringEntity = "Specialist services (endocrinology, surgery, psychiatry/psychology)";
        attribute :>> referralCriteria = "Clinical need for specialist input beyond GSL's scope — complex endocrine management, surgical referral, mental health support.";
        attribute :>> referralProtocol = "Formal referral letter with clinical summary, investigation results, and specific clinical question.";
        attribute :>> expectedResponseTime = "Varies by specialty and urgency. Routine: 2-4 weeks acknowledgement. Urgent: within 48 hours.";
        attribute :>> feedbackMechanism = "Specialist outcome report back to GSL. Integrated into patient's clinical record.";
        attribute :>> volumeTracking = "Referral volumes by specialty tracked quarterly. Waiting times and outcome rates monitored.";
    }

    part pharmaceuticalSupply : ExternalDependency {
        doc /* Hormone medication supply — essential dependency.
             * GSL cannot deliver its core service without
             * reliable pharmaceutical supply. */
        attribute :>> dependencyName = "Pharmaceutical supply (hormones)";
        attribute :>> provider = "Licensed pharmaceutical wholesalers and manufacturers";
        attribute :>> dependencyDescription = "Supply of gender-affirming hormone medications — oestradiol (oral, transdermal, injectable), testosterone (injectable, transdermal). Core to GSL's clinical service.";
        attribute :>> criticality = DependencyCriticality::essential;
        attribute :>> substitutability = "Multiple formulations and suppliers available for most medications. Some specialist preparations have limited suppliers. Brand switching requires clinical review.";
        attribute :>> contingencyPlan = "Maintain relationships with multiple wholesalers. Monitor MHRA drug shortage alerts. Clinical protocol for safe brand switching when required.";
        attribute :>> contractualTerms = "Standard pharmaceutical wholesale terms. No exclusive supply agreements.";
        attribute :>> supplyRisk = "Periodic national shortages of specific formulations (testosterone undecanoate, oestradiol patches). MHRA supply disruption notifications.";
    }

    part laboratoryDependency : ExternalDependency {
        doc /* External pathology laboratory — essential for blood
             * monitoring. */
        attribute :>> dependencyName = "Laboratory services (blood monitoring)";
        attribute :>> provider = "Contracted pathology laboratory";
        attribute :>> dependencyDescription = "Blood test processing for hormone levels, liver function, lipids, haematology. Required for safe prescribing and monitoring.";
        attribute :>> criticality = DependencyCriticality::essential;
        attribute :>> substitutability = "Multiple pathology providers available. Switching requires new account setup and reference range familiarisation. Turnaround times may vary.";
        attribute :>> contingencyPlan = "Secondary laboratory contract in place. Patient can use NHS GP blood monitoring as fallback (slower turnaround).";
        attribute :>> contractualTerms = "Per-panel pricing. Results via electronic interface. Turnaround SLA: routine 48 hours, urgent 24 hours.";
        attribute :>> supplyRisk = "Low — multiple providers. Risk of turnaround delays during high-demand periods. Electronic interface dependency.";
    }

    part transCommunityCommunity : CommunityRelationship {
        doc /* Trans community and advocacy organisations —
             * constitutive relationship. GSL exists to serve
             * this community. */
        attribute :>> communityName = "Trans and non-binary community";
        attribute :>> communityDescription = "People who identify as trans, non-binary, or gender diverse, and the organisations that advocate for and support them.";
        attribute :>> relationshipToService = "Constitutive — GSL exists to serve this community. Community needs define what services GSL offers and how they are delivered.";
        attribute :>> engagementMode = "Community advisory input, patient feedback mechanisms, engagement with trans advocacy organisations, representation at community events.";
        attribute :>> mutualBenefit = "Community gains access to specialist gender-affirming healthcare. GSL gains understanding of community needs, trust, and referral through community networks.";
        attribute :>> communityVoice = "Patient experience feedback, community advisory group (planned), engagement with national advocacy organisations (e.g. Mermaids, Gendered Intelligence, GIRES), social media presence.";
    }

    part sharedDecisionParticipation : ParticipationModel {
        doc /* Shared decision-making in hormone therapy — the
             * defining participation pattern for GSL. Patient
             * as informed co-producer of treatment decisions. */
        attribute :>> participationName = "Shared decision-making in hormone therapy";
        attribute :>> participantRole = "Informed co-producer — patient actively contributes to treatment decisions alongside the clinician";
        attribute :>> participationDescription = "Patient participates in treatment decisions through informed consent, preference expression, self-monitoring, and shared goal setting. Clinician provides clinical expertise; patient provides lived experience and treatment preferences.";
        attribute :>> informationContribution = "Medical history, treatment preferences, self-reported wellbeing, side effect reporting, lifestyle factors affecting treatment. Via consultation and patient portal.";
        attribute :>> decisionInvolvement = "Shared — clinician and patient jointly decide treatment approach, medication choice, dose adjustments. Patient consent required for all treatment changes.";
        attribute :>> selfServiceScope = "Appointment booking, viewing pathway progress, accessing education materials, submitting self-monitoring data, secure messaging with clinical team.";
        attribute :>> supportRequired = "Health literacy support, education on hormone therapy effects and monitoring, digital literacy for portal use, accessibility accommodations as needed.";
    }
}
