// =========================================================================
// BUSINESS MODEL — What GenderSense offers, to whom, and how it works
// financially as a business
// =========================================================================

package BusinessModel {
    private import ScalarValues::*;

    doc /* The business model package captures the strategic logic of the
         * enterprise: what value is offered, to whom, how revenue is
         * generated, what resources are needed, and how the business
         * evolves over time. This is distinct from the business system
         * model (the other six packages) which describes the operational
         * machinery that implements this logic.
         *
         * The five concerns addressed across this package and the
         * existing model:
         * - Service Concept (here: ServiceConcept)
         * - Financial Model (here: FinancialPlanning)
         * - Resource and Capability Model (here: ResourcePlanning)
         * - Service Delivery System (ServiceDelivery package)
         * - Governance and Adaptation (Enterprise + ServiceDelivery::ClinicalGovernance)
         *
         * Cross-cutting: ActivityModel provides the activity taxonomy
         * and costing foundation that connects all five concerns.
         *
         * Source: gsl-service-business-meta-modelling.md
         *
         * Phase 1: ServiceConcept + ActivityModel (complete)
         * Phase 2: ResourcePlanning + FinancialPlanning (complete)
         * Phase 3: ScenarioModelling + StrategyAndEvolution (complete)
         * Phase 5: Full Platform (Variant B) scenario (complete) */

    // =================================================================
    // SERVICE CONCEPT — What value is delivered, to whom, and why
    // =================================================================

    package ServiceConcept {
        private import ScalarValues::*;

        doc /* Defines the value proposition, customer segments, service
             * offerings, channels, and differentiation claims. This is
             * the "why does this business exist, and for whom?" package.
             *
             * Cross-references to ServiceDelivery::ClinicalPathways are
             * via String attributes (clinicalPathwayRef) rather than
             * formal SysML ref relationships. This avoids coupling
             * during the exploratory phase. Formal references will be
             * added once the business model structure stabilises.
             *
             * Source: gsl-service-business-meta-modelling.md section 3.1 */

        // -- Part definitions ----------------------------------

        part def CustomerSegment {
            doc /* A defined group of customers with shared needs,
                 * behaviours, and willingness to pay. Each segment
                 * has distinct needs and may require distinct value
                 * propositions. */
            attribute segmentName : String;
            attribute description : String;
            attribute needs : String;
            attribute acquisitionChannel : String;
            attribute willingnessToPayIndicator : String; // qualitative: high / medium / low
        }

        part def ValueProposition {
            doc /* A specific promise of value to a specific customer
                 * segment. Defines what the customer gets, how it
                 * differs from alternatives, and why it matters. */
            attribute propositionName : String;
            attribute description : String;
            attribute targetSegment : String;     // references a CustomerSegment by name
            attribute differentiator : String;
            attribute evidenceBasis : String;
        }

        part def ServiceOffering {
            doc /* A packaged, deliverable unit of service that realises
                 * one or more value propositions for one or more
                 * segments. This is the unit at which pricing, resource
                 * requirements, and pathway mapping are defined.
                 *
                 * Cross-reference: each ServiceOffering maps to one or
                 * more clinical pathways in
                 * ServiceDelivery::ClinicalPathways. */
            attribute offeringName : String;
            attribute description : String;
            attribute scope : String;
            attribute pricingBasis : String;       // per-episode, subscription, etc.
            attribute estimatedDurationWeeks : Integer;
            attribute clinicalPathwayRef : String; // e.g. "ClinicalPathways::HormoneTherapy::HormoneTherapyInitiation"
        }

        part def Channel {
            doc /* A means by which customers discover, access, and
                 * interact with the service. Channels have reach,
                 * cost, and conversion characteristics. */
            attribute channelName : String;
            attribute description : String;
            attribute channelType : String;        // acquisition, delivery, or both
            attribute estimatedReach : String;
            attribute estimatedCostLevel : String; // qualitative: high / medium / low
            attribute conversionNotes : String;
        }

        part def DifferentiationClaim {
            doc /* An explicit statement of how this service differs
                 * from available alternatives, from the customer's
                 * perspective. Each claim should be testable. */
            attribute claimName : String;
            attribute statement : String;
            attribute basis : String;
            attribute testability : String;
        }

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
            attribute :>> targetSegment = "Self-referring individuals";
            attribute :>> differentiator = "NHS GIC median wait exceeds 4 years";
            attribute :>> evidenceBasis = "Published NHS waiting time data";
        }

        part integratedDigitalClinical : ValueProposition {
            attribute :>> propositionName = "Integrated digital and clinical care";
            attribute :>> description = "Patient portal with real-time pathway visibility alongside clinical expertise";
            attribute :>> targetSegment = "Self-referring individuals";
            attribute :>> differentiator = "Most private gender services offer clinical-only with no digital integration";
            attribute :>> evidenceBasis = "Platform capability comparison";
        }

        part specialistExpertise : ValueProposition {
            attribute :>> propositionName = "Specialist expertise";
            attribute :>> description = "Care delivered by clinicians with specific gender identity healthcare credentials";
            attribute :>> targetSegment = "GP-referred patients";
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

        // -- Variant B value propositions ----------------------

        part holisticCareModel : ValueProposition {
            attribute :>> propositionName = "Holistic care model";
            attribute :>> description = "Clinical care, coaching, education, and peer community as one integrated package";
            attribute :>> targetSegment = "Self-referring individuals";
            attribute :>> differentiator = "No other UK gender service offers clinical + coaching + community as a single subscription";
            attribute :>> evidenceBasis = "Service offering comparison with existing providers";
        }
    }

    // =================================================================
    // ACTIVITY MODEL — Cross-cutting activity taxonomy and costing
    // =================================================================

    package ActivityModel {
        private import ScalarValues::*;

        doc /* Cross-cutting activity taxonomy and costing foundation.
             * Every activity in the business falls into one of five
             * categories. Activity awareness operates at multiple
             * granularity levels, and different parts of the business
             * can operate at different levels simultaneously.
             *
             * At the business model level, ActivityModel is about
             * planning and costing — how much activity of each type
             * does this business model require, and what does it cost?
             * At the system model level, the corresponding concern is
             * activity tracking — the actual recording of activity
             * events as they happen.
             *
             * Source: gsl-service-business-meta-modelling.md section 2.4
             *
             * Progressive elaboration: different parts of the business
             * can operate at different granularity levels at the same
             * time. Clinical service delivery is at tracked level from
             * day one (pathway model produces observable events).
             * Governance may be at category level. Overhead may remain
             * at envelope level until there is a reason to be more
             * precise. */

        // -- Enumerations --------------------------------------

        enum def ActivityCategory {
            doc /* The five categories of business activity. Every
                 * activity belongs to at least one category. The
                 * taxonomy ensures completeness of coverage — nothing
                 * falls through the gaps. */
            serviceDelivery;     // directly produces value for a customer
            serviceEnabling;     // supports delivery but not visible to customer
            governance;          // satisfies compliance, quality, safety requirements
            development;         // builds future capability
            overhead;            // necessary operational activity
        }

        enum def GranularityLevel {
            doc /* The level of detail at which activity is tracked
                 * for a given activity type or business area. */
            envelope;    // total hours per category as a lump estimate
            category;    // broken down by type, approximate proportions
            tracked;     // individual activities recorded as discrete events
        }

        // -- Part definitions ----------------------------------

        part def ActivityType {
            doc /* A defined type of activity within the business.
                 * Every activity has a type, and every type belongs
                 * to one of the five taxonomy categories. */
            attribute activityTypeName : String;
            attribute activityCategory : ActivityCategory;
            attribute description : String;
            attribute expectedDurationMinutes : Integer;
            attribute frequencyNotes : String;
        }

        part def ActivityRecord {
            doc /* A recorded instance of an activity. At the tracked
                 * level, the system produces these for every observable
                 * activity. At coarser levels, they are estimated
                 * aggregates. */
            attribute activityType : String;
            attribute participants : String;
            attribute durationMinutes : Integer;
            attribute resourcesConsumed : String;
            attribute recordGranularity : GranularityLevel;
        }

        part def ActivityBudget {
            doc /* A planned allocation of activity volume by type,
                 * period, and resource. The activity-level equivalent
                 * of a financial budget. */
            attribute budgetPeriod : String;
            attribute activityType : String;
            attribute plannedVolume : Integer;
            attribute plannedTotalHours : Real;
            attribute granularity : GranularityLevel;
        }

        part def ActivityGranularity {
            doc /* Policy declaration: the granularity level at which
                 * activity is tracked for a given business area. */
            attribute businessArea : String;
            attribute currentLevel : GranularityLevel;
            attribute targetLevel : GranularityLevel;
            attribute migrationNotes : String;
        }

        part def ActivityCostAllocation {
            doc /* The mapping from an activity (or aggregate) to its
                 * financial cost. Makes resource consumption visible
                 * to the financial model. */
            attribute activityType : String;
            attribute allocationMethod : String;
            attribute estimatedCostPerUnit : Real;
            attribute costNotes : String;
        }
    }

    // =================================================================
    // RESOURCE PLANNING — What resources and capabilities are needed
    // =================================================================

    package ResourcePlanning {
        private import ScalarValues::*;

        doc /* Defines the resources required to operate the service
             * delivery system: people, technology, estate, licences,
             * and external services. Resources are organised into
             * capabilities (combinations that produce service
             * functions), capacity models (throughput relationships),
             * and constraints (limits on availability and use).
             *
             * Cross-references to Platform capabilities and
             * ServiceDelivery processes are via String attributes
             * and doc blocks — consistent with ServiceConcept
             * approach. Formal ref relationships deferred until
             * shapes stabilise.
             *
             * Source: gsl-service-business-meta-modelling.md section 3.3 */

        // -- Part definitions ----------------------------------

        part def ResourceType {
            doc /* A category of resource required to operate the
                 * service delivery system. Each type has acquisition
                 * characteristics, capacity constraints, and cost
                 * profiles. */
            attribute resourceTypeName : String;
            attribute category : String;           // personnel, technology, estate, insurance, external service
            attribute acquisitionMethod : String;  // employed, contracted, subscribed, purchased, rented
            attribute costProfile : String;        // e.g. "£5,000/FTE/month"
            attribute capacityUnit : String;       // FTE, instances, seats, hours
        }

        part def ResourceInstance {
            doc /* A specific resource available to the business at
                 * a defined capacity and cost. Represents planning-
                 * level archetypes ("a prescribing clinician at
                 * 0.5 FTE") rather than named individuals. */
            attribute instanceName : String;
            attribute resourceType : String;       // references a ResourceType by name
            attribute capacity : String;           // e.g. "0.5 FTE", "1 instance"
            attribute availabilityNotes : String;
            attribute costPerUnit : Real;
            attribute costBasis : String;          // per month, per hour, per use
        }

        part def Capability {
            doc /* An organised combination of resources that produces
                 * a defined service function. Capabilities bridge the
                 * gap between raw resources and service delivery — you
                 * don't deliver care with "a doctor" and "a system";
                 * you deliver it with "the ability to conduct a hormone
                 * therapy monitoring review."
                 *
                 * Cross-reference: enabledOfferings maps to
                 * ServiceConcept::ServiceOffering names. */
            attribute capabilityName : String;
            attribute description : String;
            attribute requiredResources : String;   // descriptive: "1 prescribing clinician + EHRbase CDR + lab interface"
            attribute enabledOfferings : String;    // references ServiceOffering names
        }

        part def CapacityModel {
            doc /* The relationship between resource configuration and
                 * service throughput. A planning assertion, not a
                 * computed formula — the formula representation lives
                 * in ScenarioModelling::ProjectionFormula (Phase 3).
                 *
                 * CapacityModel says "with 1 clinician at 8 sessions/
                 * day we can see 80 patients/week." ProjectionFormula
                 * computes "at month 12 with 0.8 FTE and 55 active
                 * patients, utilisation is 78%." */
            attribute resourceConfiguration : String;
            attribute throughputPerPeriod : String;
            attribute periodUnit : String;         // per day, per week, per month
            attribute assumptions : String;
            attribute bottleneck : String;          // which resource constrains throughput
        }

        part def ResourceConstraint {
            doc /* A constraint on resource availability or use that
                 * affects service delivery. May be regulatory,
                 * financial, temporal, or contractual.
                 *
                 * Cross-reference: regulatory constraints map to
                 * Enterprise::Regulation requirement defs. */
            attribute constraintName : String;
            attribute constraintType : String;     // regulatory, financial, temporal, contractual, practical
            attribute affectedResource : String;   // references a ResourceType by name
            attribute limit : String;
            attribute regulatorySource : String;   // e.g. "Enterprise::Regulation" or empty
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
            attribute :>> resourceType = "Prescribing clinician";
            attribute :>> capacity = "0.5 FTE";
            attribute :>> availabilityNotes = "3 clinical days per fortnight";
            attribute :>> costPerUnit = 2500.0;
            attribute :>> costBasis = "per month";
        }

        part clinicianMonth10to24 : ResourceInstance {
            doc /* Scaled clinician capacity: 0.8 FTE from month 10.
                 * Supports growth to ~40 active patients. */
            attribute :>> instanceName = "Prescribing clinician (months 10-24)";
            attribute :>> resourceType = "Prescribing clinician";
            attribute :>> capacity = "0.8 FTE";
            attribute :>> availabilityNotes = "4 clinical days per week";
            attribute :>> costPerUnit = 4000.0;
            attribute :>> costBasis = "per month";
        }

        part adminInstance : ResourceInstance {
            attribute :>> instanceName = "Administrative support";
            attribute :>> resourceType = "Administrative support";
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
            attribute :>> enabledOfferings = "Hormone Therapy Initiation, Ongoing Monitoring";
        }

        part assessmentCapability : Capability {
            attribute :>> capabilityName = "Clinical assessment";
            attribute :>> description = "Comprehensive new patient assessment with structured clinical record";
            attribute :>> requiredResources = "1 prescribing clinician + video consulting + forms platform + EHRbase CDR";
            attribute :>> enabledOfferings = "Initial Assessment";
        }

        part monitoringCapability : Capability {
            attribute :>> capabilityName = "Blood monitoring";
            attribute :>> description = "Order, receive, and review blood monitoring results";
            attribute :>> requiredResources = "Lab interface + EHRbase CDR + prescribing clinician for review";
            attribute :>> enabledOfferings = "Hormone Therapy Initiation, Ongoing Monitoring";
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
            attribute :>> affectedResource = "Prescribing clinician";
            attribute :>> limit = "40 active patients per FTE clinician";
            attribute :>> regulatorySource = "";
        }

        part prescribingQualification : ResourceConstraint {
            doc /* Regulatory requirement: the prescribing clinician
                 * must hold appropriate qualification for hormone
                 * prescribing. Maps to Enterprise::Regulation. */
            attribute :>> constraintName = "Prescribing qualification";
            attribute :>> constraintType = "regulatory";
            attribute :>> affectedResource = "Prescribing clinician";
            attribute :>> limit = "Must hold prescribing qualification and gender identity healthcare credential";
            attribute :>> regulatorySource = "Enterprise::Regulation";
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
            attribute :>> resourceType = "Gender identity coach";
            attribute :>> capacity = "0.5 FTE";
            attribute :>> availabilityNotes = "2.5 days per week";
            attribute :>> costPerUnit = 1500.0;
            attribute :>> costBasis = "per month";
        }

        part moderatorInstance : ResourceInstance {
            attribute :>> instanceName = "Community moderator";
            attribute :>> resourceType = "Community moderator";
            attribute :>> capacity = "0.2 FTE";
            attribute :>> availabilityNotes = "1 day per week";
            attribute :>> costPerUnit = 400.0;
            attribute :>> costBasis = "per month";
        }

        part secondClinicianMonth6to24 : ResourceInstance {
            doc /* Second clinician added at month 6 in Variant B.
                 * Steps from 0.5 to 1.0 FTE at month 12. */
            attribute :>> instanceName = "Second prescribing clinician (months 6-24)";
            attribute :>> resourceType = "Prescribing clinician";
            attribute :>> capacity = "0.5 FTE stepping to 1.0 FTE at month 12";
            attribute :>> availabilityNotes = "Variant B only — earlier scaling than Variant A";
            attribute :>> costPerUnit = 2500.0;
            attribute :>> costBasis = "per month (at 0.5 FTE)";
        }

        part coachingCapability : Capability {
            attribute :>> capabilityName = "Gender identity coaching";
            attribute :>> description = "Deliver structured coaching sessions supporting social transition and wellbeing";
            attribute :>> requiredResources = "1 gender identity coach + video consulting + scheduling platform";
            attribute :>> enabledOfferings = "Coaching";
        }

        part communityCapability : Capability {
            attribute :>> capabilityName = "Peer community platform";
            attribute :>> description = "Operate moderated peer forums, facilitated groups, and community events";
            attribute :>> requiredResources = "1 community moderator + community platform software + content moderation tools";
            attribute :>> enabledOfferings = "Community";
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
    }

    // =================================================================
    // FINANCIAL PLANNING — How money flows through the business
    // =================================================================

    package FinancialPlanning {
        private import ScalarValues::*;

        doc /* Defines the financial structure of the business: how
             * revenue is generated, what drives cost, what the unit
             * economics look like, and how pricing works. This is
             * the "does this work financially?" package.
             *
             * Distinct from Operations::Finance which handles
             * operational accounting (invoicing, payment processing,
             * Xero integration). FinancialPlanning is structural
             * economics — the bank-manager spreadsheet made explicit.
             *
             * Source: gsl-service-business-meta-modelling.md section 3.4 */

        enum def PricingType {
            doc /* The structural pricing model for a service offering. */
            perEpisode;
            subscription;
            tiered;
            slidingScale;
            flatFee;
        }

        part def RevenueStream {
            doc /* A mechanism by which income is generated. */
            attribute streamName : String;
            attribute sourceSegment : String;
            attribute triggerEvent : String;
            attribute pricingModelRef : String;
            attribute projectedVolume : String;
        }

        part def CostDriver {
            doc /* A structural factor that generates cost. */
            attribute driverName : String;
            attribute linkedResource : String;
            attribute costBehaviour : String;
            attribute estimatedUnitCost : Real;
            attribute scalingFactor : String;
        }

        part def UnitEconomics {
            doc /* The financial profile of a single unit of service delivery. */
            attribute offeringRef : String;
            attribute revenuePerUnit : Real;
            attribute costPerUnit : Real;
            attribute marginPerUnit : Real;
            attribute breakdownNotes : String;
        }

        part def PricingModel {
            doc /* The logic that determines what a customer pays. */
            attribute pricingModelName : String;
            attribute pricingType : PricingType;
            attribute basePrice : Real;
            attribute adjustmentLogic : String;
            attribute applicableOfferings : String;
        }

        part def FinancialProjection {
            doc /* A named financial projection linked to a scenario.
                 * Lightweight placeholder — full mechanics in
                 * ScenarioModelling. */
            attribute projectionName : String;
            attribute scenarioRef : String;
            attribute timelineMonths : Integer;
            attribute revenueFormula : String;
            attribute costFormula : String;
            attribute breakEvenIndicator : String;
        }

        // -- GSL Lean Clinical financial instantiation ----------

        part assessmentRevenue : RevenueStream {
            attribute :>> streamName = "Assessment fees";
            attribute :>> sourceSegment = "Self-referring individuals, GP-referred patients";
            attribute :>> triggerEvent = "Completion of initial assessment episode";
            attribute :>> pricingModelRef = "perEpisodePricing";
            attribute :>> projectedVolume = "4 per month (year 1), 6 per month (year 2)";
        }

        part monitoringRevenue : RevenueStream {
            attribute :>> streamName = "Monitoring fees";
            attribute :>> sourceSegment = "Patients in stable monitoring";
            attribute :>> triggerEvent = "Quarterly monitoring review";
            attribute :>> pricingModelRef = "perEpisodePricing";
            attribute :>> projectedVolume = "grows with stable cohort — see projection";
        }

        part clinicianCost : CostDriver {
            attribute :>> driverName = "Clinician cost";
            attribute :>> linkedResource = "Prescribing clinician";
            attribute :>> costBehaviour = "semi-variable — fixed FTE cost, scaled in steps as caseload grows";
            attribute :>> estimatedUnitCost = 5000.0;
            attribute :>> scalingFactor = "per FTE per month";
        }

        part adminCost : CostDriver {
            attribute :>> driverName = "Administrative support cost";
            attribute :>> linkedResource = "Administrative support";
            attribute :>> costBehaviour = "semi-variable";
            attribute :>> estimatedUnitCost = 1800.0;
            attribute :>> scalingFactor = "per FTE per month";
        }

        part platformCost : CostDriver {
            attribute :>> driverName = "Platform hosting and infrastructure";
            attribute :>> linkedResource = "Technology platform";
            attribute :>> costBehaviour = "fixed";
            attribute :>> estimatedUnitCost = 200.0;
            attribute :>> scalingFactor = "per month";
        }

        part insuranceCost : CostDriver {
            attribute :>> driverName = "Professional indemnity insurance";
            attribute :>> linkedResource = "Professional indemnity insurance";
            attribute :>> costBehaviour = "fixed";
            attribute :>> estimatedUnitCost = 250.0;
            attribute :>> scalingFactor = "per month";
        }

        part labCost : CostDriver {
            attribute :>> driverName = "Laboratory costs";
            attribute :>> linkedResource = "Laboratory services";
            attribute :>> costBehaviour = "variable";
            attribute :>> estimatedUnitCost = 45.0;
            attribute :>> scalingFactor = "per blood panel";
        }

        part overheadCost : CostDriver {
            attribute :>> driverName = "Overhead allocation";
            attribute :>> linkedResource = "";
            attribute :>> costBehaviour = "percentage of direct cost";
            attribute :>> estimatedUnitCost = 25.0;
            attribute :>> scalingFactor = "percentage of direct cost";
        }

        part assessmentUnitEconomics : UnitEconomics {
            attribute :>> offeringRef = "Initial Assessment";
            attribute :>> revenuePerUnit = 600.0;
            attribute :>> costPerUnit = 350.0;
            attribute :>> marginPerUnit = 250.0;
            attribute :>> breakdownNotes = "Clinician 2hrs £125, baseline bloods £90, platform/admin £65, overhead £70";
        }

        part monitoringUnitEconomics : UnitEconomics {
            attribute :>> offeringRef = "Ongoing Monitoring (quarterly)";
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
            attribute :>> scenarioRef = "Lean Clinical (Variant A)";
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
            attribute :>> pricingModelRef = "subscriptionPricing";
            attribute :>> projectedVolume = "grows with active patient cohort";
        }

        part coachCost : CostDriver {
            attribute :>> driverName = "Coach cost";
            attribute :>> linkedResource = "Gender identity coach";
            attribute :>> costBehaviour = "semi-variable — fixed FTE cost, added when coaching offering launches";
            attribute :>> estimatedUnitCost = 3000.0;
            attribute :>> scalingFactor = "per FTE per month";
        }

        part moderatorCost : CostDriver {
            attribute :>> driverName = "Community moderator cost";
            attribute :>> linkedResource = "Community moderator";
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
            attribute :>> offeringRef = "Subscription (monthly)";
            attribute :>> revenuePerUnit = 99.0;
            attribute :>> costPerUnit = 55.0;
            attribute :>> marginPerUnit = 44.0;
            attribute :>> breakdownNotes = "Coach allocation £30, moderator allocation £8, platform £12, overhead £5. All values placeholder.";
        }

        part fullPlatformProjection : FinancialProjection {
            attribute :>> projectionName = "Full Platform 24-month projection";
            attribute :>> scenarioRef = "Full Platform (Variant B)";
            attribute :>> timelineMonths = 24;
            attribute :>> revenueFormula = "assessment fees + monitoring fees + subscription fees (active subscribers x monthly fee)";
            attribute :>> costFormula = "2 clinician FTE + admin FTE + coach FTE + moderator FTE + platform + insurance + lab panels + 25% overhead";
            attribute :>> breakEvenIndicator = "placeholder — to be determined by projection engine";
        }
    }

    // =================================================================
    // SCENARIO MODELLING — Projection mechanics and operational steering
    // =================================================================

    package ScenarioModelling {
        private import ScalarValues::*;

        doc /* Provides the mechanics for driving the business model
             * vocabulary — computing projections, comparing alternatives,
             * and stress-testing assumptions. Without this, the business
             * model is a structured description; with it, it becomes an
             * explorable, quantitative tool.
             *
             * Source: gsl-service-business-meta-modelling.md sections
             * 3.7 and 3.8 */

        // -- Enumerations --------------------------------------

        enum def GrowthShape {
            linear;
            stepped;
            sCurve;
            custom;
        }

        enum def VarianceSource {
            volume;
            price;
            mix;
            timing;
        }

        // -- Part definitions: projection mechanics ------------

        part def ScenarioDefinition {
            attribute scenarioName : String;
            attribute description : String;
            attribute activeOfferings : String;
            attribute variantLabel : String;
            attribute timelineMonths : Integer;
            attribute notes : String;
        }

        part def ProjectionParameter {
            attribute parameterName : String;
            attribute parameterValue : Real;
            attribute unit : String;
            attribute sourceRef : String;
            attribute temporalVariation : String;
            attribute notes : String;
        }

        part def GrowthAssumption {
            attribute assumptionName : String;
            attribute targetVariable : String;
            attribute growthShape : GrowthShape;
            attribute startValue : Real;
            attribute endValue : Real;
            attribute inflectionMonth : Integer;
            attribute trajectory : String;
            attribute notes : String;
        }

        part def ProjectionFormula {
            attribute formulaName : String;
            attribute inputs : String;
            attribute expression : String;
            attribute outputVariable : String;
            attribute outputUnit : String;
            attribute notes : String;
        }

        part def ProjectionTimeline {
            attribute timelineName : String;
            attribute periodMonths : Integer;
            attribute intervalUnit : String;
            attribute startCondition : String;
        }

        part def ProjectionOutput {
            attribute periodLabel : String;
            attribute revenue : Real;
            attribute cost : Real;
            attribute margin : Real;
            attribute cumulativeCashFlow : Real;
            attribute activePatientsTotal : Integer;
            attribute clinicianUtilisation : Real;
            attribute confidenceProfile : String;
        }

        part def SensitivityParameter {
            attribute parameterRef : String;
            attribute baseValue : Real;
            attribute pessimisticValue : Real;
            attribute optimisticValue : Real;
            attribute impactDescription : String;
        }

        part def ScenarioComparison {
            attribute comparisonName : String;
            attribute scenarioRefs : String;
            attribute comparisonDate : String;
            attribute summaryNotes : String;
        }

        // -- Part definitions: operational steering ------------

        part def PeriodActuals {
            attribute periodLabel : String;
            attribute actualRevenue : Real;
            attribute actualCost : Real;
            attribute actualMargin : Real;
            attribute actualPatientCount : Integer;
            attribute recordedDate : String;
            attribute notes : String;
        }

        part def VarianceAnalysis {
            attribute periodLabel : String;
            attribute revenueVariance : Real;
            attribute costVariance : Real;
            attribute marginVariance : Real;
            attribute varianceSource : String;
            attribute decomposition : String;
            attribute rebaselineRecommended : String;
            attribute notes : String;
        }

        part def ForecastBaseline {
            attribute baselineName : String;
            attribute baselineVersion : Integer;
            attribute scenarioRef : String;
            attribute effectiveDate : String;
            attribute parameterSnapshot : String;
            attribute notes : String;
        }

        // -- GSL Lean Clinical scenario instantiation ----------

        part leanClinicalScenario : ScenarioDefinition {
            attribute :>> scenarioName = "Lean Clinical (Variant A)";
            attribute :>> description = "Assessment and hormone therapy only. 1 clinician, per-episode pricing.";
            attribute :>> activeOfferings = "Initial Assessment, Hormone Therapy Initiation, Ongoing Monitoring";
            attribute :>> variantLabel = "A";
            attribute :>> timelineMonths = 24;
            attribute :>> notes = "Figures are illustrative best-estimates per meta-modelling section 7.2";
        }

        // Projection parameters — revenue

        part paramAssessmentFee : ProjectionParameter {
            attribute :>> parameterName = "assessmentFeePerPatient";
            attribute :>> parameterValue = 600.0;
            attribute :>> unit = "£";
            attribute :>> sourceRef = "FinancialPlanning::perEpisodePricing";
            attribute :>> temporalVariation = "";
            attribute :>> notes = "Fixed fee per initial assessment episode";
        }

        part paramMonitoringFee : ProjectionParameter {
            attribute :>> parameterName = "monitoringFeePerQuarter";
            attribute :>> parameterValue = 150.0;
            attribute :>> unit = "£";
            attribute :>> sourceRef = "FinancialPlanning::perEpisodePricing";
            attribute :>> temporalVariation = "";
            attribute :>> notes = "Fixed fee per quarterly monitoring review";
        }

        // Projection parameters — resource cost

        part paramClinicianFTEEarly : ProjectionParameter {
            attribute :>> parameterName = "clinicianFTEMonths1to9";
            attribute :>> parameterValue = 0.5;
            attribute :>> unit = "FTE";
            attribute :>> sourceRef = "ResourcePlanning::clinicianMonth1to9";
            attribute :>> temporalVariation = "Months 1-9 only. Steps to 0.8 FTE at month 10.";
            attribute :>> notes = "3 clinical days per fortnight";
        }

        part paramClinicianFTELater : ProjectionParameter {
            attribute :>> parameterName = "clinicianFTEMonths10to24";
            attribute :>> parameterValue = 0.8;
            attribute :>> unit = "FTE";
            attribute :>> sourceRef = "ResourcePlanning::clinicianMonth10to24";
            attribute :>> temporalVariation = "From month 10 onwards";
            attribute :>> notes = "4 clinical days per week";
        }

        part paramClinicianCost : ProjectionParameter {
            attribute :>> parameterName = "clinicianCostPerFTEPerMonth";
            attribute :>> parameterValue = 5000.0;
            attribute :>> unit = "£/FTE/month";
            attribute :>> sourceRef = "FinancialPlanning::clinicianCost";
            attribute :>> temporalVariation = "";
            attribute :>> notes = "Actual monthly cost = FTE x this rate";
        }

        part paramAdminFTE : ProjectionParameter {
            attribute :>> parameterName = "adminFTE";
            attribute :>> parameterValue = 0.3;
            attribute :>> unit = "FTE";
            attribute :>> sourceRef = "ResourcePlanning::adminInstance";
            attribute :>> temporalVariation = "";
            attribute :>> notes = "1.5 days per week throughout";
        }

        part paramAdminCost : ProjectionParameter {
            attribute :>> parameterName = "adminCostPerFTEPerMonth";
            attribute :>> parameterValue = 1800.0;
            attribute :>> unit = "£/FTE/month";
            attribute :>> sourceRef = "FinancialPlanning::adminCost";
            attribute :>> temporalVariation = "";
            attribute :>> notes = "";
        }

        part paramPlatformCost : ProjectionParameter {
            attribute :>> parameterName = "platformCostPerMonth";
            attribute :>> parameterValue = 200.0;
            attribute :>> unit = "£/month";
            attribute :>> sourceRef = "FinancialPlanning::platformCost";
            attribute :>> temporalVariation = "";
            attribute :>> notes = "Fixed hosting and infrastructure";
        }

        part paramInsuranceCost : ProjectionParameter {
            attribute :>> parameterName = "insurancePerMonth";
            attribute :>> parameterValue = 250.0;
            attribute :>> unit = "£/month";
            attribute :>> sourceRef = "FinancialPlanning::insuranceCost";
            attribute :>> temporalVariation = "";
            attribute :>> notes = "Professional indemnity";
        }

        part paramLabCost : ProjectionParameter {
            attribute :>> parameterName = "labCostPerBloodPanel";
            attribute :>> parameterValue = 45.0;
            attribute :>> unit = "£/panel";
            attribute :>> sourceRef = "FinancialPlanning::labCost";
            attribute :>> temporalVariation = "";
            attribute :>> notes = "";
        }

        // Projection parameters — clinical pathway derived

        part paramBloodPanelsInitiation : ProjectionParameter {
            attribute :>> parameterName = "bloodPanelsPerInitiationEpisode";
            attribute :>> parameterValue = 5.0;
            attribute :>> unit = "panels";
            attribute :>> sourceRef = "ServiceDelivery::ClinicalPathways::HormoneTherapy";
            attribute :>> temporalVariation = "";
            attribute :>> notes = "Baseline + 4 monitoring panels during titration";
        }

        part paramBloodPanelsMonitoring : ProjectionParameter {
            attribute :>> parameterName = "bloodPanelsPerMonitoringQuarter";
            attribute :>> parameterValue = 1.0;
            attribute :>> unit = "panels";
            attribute :>> sourceRef = "ServiceDelivery::ClinicalPathways::HormoneTherapy";
            attribute :>> temporalVariation = "";
            attribute :>> notes = "1 panel per quarterly review once stable";
        }

        part paramOverheadPercentage : ProjectionParameter {
            attribute :>> parameterName = "overheadPercentage";
            attribute :>> parameterValue = 25.0;
            attribute :>> unit = "%";
            attribute :>> sourceRef = "FinancialPlanning::overheadCost";
            attribute :>> temporalVariation = "";
            attribute :>> notes = "Envelope-level overhead as percentage of direct cost";
        }

        // Projection parameters — growth

        part paramNewPatientsYear1 : ProjectionParameter {
            attribute :>> parameterName = "newPatientsPerMonthYear1";
            attribute :>> parameterValue = 4.0;
            attribute :>> unit = "patients/month";
            attribute :>> sourceRef = "GrowthAssumption";
            attribute :>> temporalVariation = "Months 1-12";
            attribute :>> notes = "Linear acquisition assumption";
        }

        part paramNewPatientsYear2 : ProjectionParameter {
            attribute :>> parameterName = "newPatientsPerMonthYear2";
            attribute :>> parameterValue = 6.0;
            attribute :>> unit = "patients/month";
            attribute :>> sourceRef = "GrowthAssumption";
            attribute :>> temporalVariation = "Months 13-24";
            attribute :>> notes = "Increased acquisition via GP network and reputation";
        }

        // Projection parameters — conversion and retention

        part paramAssessmentConversion : ProjectionParameter {
            attribute :>> parameterName = "assessmentToInitiationConversion";
            attribute :>> parameterValue = 85.0;
            attribute :>> unit = "%";
            attribute :>> sourceRef = "Clinical estimate";
            attribute :>> temporalVariation = "";
            attribute :>> notes = "85% of assessed patients proceed to hormone therapy";
        }

        part paramInitiationConversion : ProjectionParameter {
            attribute :>> parameterName = "initiationToStableConversion";
            attribute :>> parameterValue = 90.0;
            attribute :>> unit = "%";
            attribute :>> sourceRef = "Clinical estimate";
            attribute :>> temporalVariation = "";
            attribute :>> notes = "90% complete initiation over ~9 months average";
        }

        part paramChurnRate : ProjectionParameter {
            attribute :>> parameterName = "churnRatePerQuarter";
            attribute :>> parameterValue = 5.0;
            attribute :>> unit = "%";
            attribute :>> sourceRef = "Clinical estimate";
            attribute :>> temporalVariation = "";
            attribute :>> notes = "5% of stable patients disengage per quarter";
        }

        // Growth assumptions

        part growthPatientAcquisitionYear1 : GrowthAssumption {
            attribute :>> assumptionName = "Patient acquisition year 1";
            attribute :>> targetVariable = "newPatientsPerMonth";
            attribute :>> growthShape = GrowthShape::linear;
            attribute :>> startValue = 4.0;
            attribute :>> endValue = 4.0;
            attribute :>> inflectionMonth = 0;
            attribute :>> trajectory = "4 new patients per month, constant through year 1";
            attribute :>> notes = "Conservative linear assumption";
        }

        part growthPatientAcquisitionYear2 : GrowthAssumption {
            attribute :>> assumptionName = "Patient acquisition year 2";
            attribute :>> targetVariable = "newPatientsPerMonth";
            attribute :>> growthShape = GrowthShape::stepped;
            attribute :>> startValue = 4.0;
            attribute :>> endValue = 6.0;
            attribute :>> inflectionMonth = 13;
            attribute :>> trajectory = "Steps from 4 to 6 new patients per month at month 13";
            attribute :>> notes = "Driven by GP network expansion and reputation growth";
        }

        part growthClinicianFTE : GrowthAssumption {
            attribute :>> assumptionName = "Clinician FTE step-up";
            attribute :>> targetVariable = "clinicianFTE";
            attribute :>> growthShape = GrowthShape::stepped;
            attribute :>> startValue = 0.5;
            attribute :>> endValue = 0.8;
            attribute :>> inflectionMonth = 10;
            attribute :>> trajectory = "0.5 FTE months 1-9, steps to 0.8 FTE at month 10";
            attribute :>> notes = "Triggered by caseload reaching ~20 active patients";
        }

        part growthConversionRate : GrowthAssumption {
            attribute :>> assumptionName = "Assessment-to-initiation conversion";
            attribute :>> targetVariable = "assessmentToInitiationConversion";
            attribute :>> growthShape = GrowthShape::linear;
            attribute :>> startValue = 85.0;
            attribute :>> endValue = 85.0;
            attribute :>> inflectionMonth = 0;
            attribute :>> trajectory = "Fixed at 85% throughout projection period";
            attribute :>> notes = "Conservative assumption — may improve with reputation";
        }

        part growthChurnRate : GrowthAssumption {
            attribute :>> assumptionName = "Stable patient churn";
            attribute :>> targetVariable = "churnRatePerQuarter";
            attribute :>> growthShape = GrowthShape::linear;
            attribute :>> startValue = 5.0;
            attribute :>> endValue = 5.0;
            attribute :>> inflectionMonth = 0;
            attribute :>> trajectory = "Fixed at 5% per quarter throughout";
            attribute :>> notes = "Represents patients transferring to GP-only care or disengaging";
        }

        // Projection formulas

        part formulaMonthlyAssessmentRevenue : ProjectionFormula {
            attribute :>> formulaName = "Monthly assessment revenue";
            attribute :>> inputs = "newPatientsPerMonth, assessmentFeePerPatient";
            attribute :>> expression = "newPatientsPerMonth * assessmentFeePerPatient / 2";
            attribute :>> outputVariable = "monthlyAssessmentRevenue";
            attribute :>> outputUnit = "£/month";
            attribute :>> notes = "Divided by 2 because assessment spans ~2 months";
        }

        part formulaMonthlyMonitoringRevenue : ProjectionFormula {
            attribute :>> formulaName = "Monthly monitoring revenue";
            attribute :>> inputs = "stablePatients, monitoringFeePerQuarter";
            attribute :>> expression = "stablePatients * monitoringFeePerQuarter / 3";
            attribute :>> outputVariable = "monthlyMonitoringRevenue";
            attribute :>> outputUnit = "£/month";
            attribute :>> notes = "Quarterly fee spread across 3 months";
        }

        part formulaTotalRevenue : ProjectionFormula {
            attribute :>> formulaName = "Total monthly revenue";
            attribute :>> inputs = "monthlyAssessmentRevenue, monthlyMonitoringRevenue";
            attribute :>> expression = "monthlyAssessmentRevenue + monthlyMonitoringRevenue";
            attribute :>> outputVariable = "totalMonthlyRevenue";
            attribute :>> outputUnit = "£/month";
            attribute :>> notes = "";
        }

        part formulaDirectCost : ProjectionFormula {
            attribute :>> formulaName = "Monthly direct cost";
            attribute :>> inputs = "clinicianFTE, clinicianCostPerFTEPerMonth, adminFTE, adminCostPerFTEPerMonth, platformCostPerMonth, insurancePerMonth, bloodPanelsThisMonth, labCostPerBloodPanel";
            attribute :>> expression = "(clinicianFTE * clinicianCostPerFTEPerMonth) + (adminFTE * adminCostPerFTEPerMonth) + platformCostPerMonth + insurancePerMonth + (bloodPanelsThisMonth * labCostPerBloodPanel)";
            attribute :>> outputVariable = "monthlyDirectCost";
            attribute :>> outputUnit = "£/month";
            attribute :>> notes = "bloodPanelsThisMonth derived from initiation and monitoring patient counts";
        }

        part formulaOverhead : ProjectionFormula {
            attribute :>> formulaName = "Monthly overhead";
            attribute :>> inputs = "monthlyDirectCost, overheadPercentage";
            attribute :>> expression = "monthlyDirectCost * overheadPercentage / 100";
            attribute :>> outputVariable = "monthlyOverhead";
            attribute :>> outputUnit = "£/month";
            attribute :>> notes = "Envelope-level allocation";
        }

        part formulaMargin : ProjectionFormula {
            attribute :>> formulaName = "Monthly margin";
            attribute :>> inputs = "totalMonthlyRevenue, monthlyDirectCost, monthlyOverhead";
            attribute :>> expression = "totalMonthlyRevenue - monthlyDirectCost - monthlyOverhead";
            attribute :>> outputVariable = "monthlyMargin";
            attribute :>> outputUnit = "£/month";
            attribute :>> notes = "";
        }

        part formulaCumulativeCash : ProjectionFormula {
            attribute :>> formulaName = "Cumulative cash flow";
            attribute :>> inputs = "previousCumulativeCashFlow, monthlyMargin";
            attribute :>> expression = "previousCumulativeCashFlow + monthlyMargin";
            attribute :>> outputVariable = "cumulativeCashFlow";
            attribute :>> outputUnit = "£";
            attribute :>> notes = "Running total from month 1";
        }

        part formulaUtilisation : ProjectionFormula {
            attribute :>> formulaName = "Clinician utilisation";
            attribute :>> inputs = "clinicianActivityHours, clinicianFTE, availableHoursPerMonth";
            attribute :>> expression = "clinicianActivityHours / (clinicianFTE * availableHoursPerMonth) * 100";
            attribute :>> outputVariable = "clinicianUtilisation";
            attribute :>> outputUnit = "%";
            attribute :>> notes = "availableHoursPerMonth estimated at 140 (35 hrs/wk * 4 wks)";
        }

        // Projection timeline

        part leanClinicalTimeline : ProjectionTimeline {
            attribute :>> timelineName = "24-month monthly projection";
            attribute :>> periodMonths = 24;
            attribute :>> intervalUnit = "monthly";
            attribute :>> startCondition = "Service launch (month 1 = first patient assessed)";
        }

        // Sensitivity parameters

        part sensitivityPatientGrowth : SensitivityParameter {
            attribute :>> parameterRef = "newPatientsPerMonthYear1";
            attribute :>> baseValue = 4.0;
            attribute :>> pessimisticValue = 2.0;
            attribute :>> optimisticValue = 6.0;
            attribute :>> impactDescription = "Break-even shifts by approximately 6 months in each direction";
        }

        part sensitivityAssessmentFee : SensitivityParameter {
            attribute :>> parameterRef = "assessmentFeePerPatient";
            attribute :>> baseValue = 600.0;
            attribute :>> pessimisticValue = 450.0;
            attribute :>> optimisticValue = 750.0;
            attribute :>> impactDescription = "Break-even shifts by approximately 3 months in each direction";
        }

        part sensitivityClinicianCost : SensitivityParameter {
            attribute :>> parameterRef = "clinicianCostPerFTEPerMonth";
            attribute :>> baseValue = 5000.0;
            attribute :>> pessimisticValue = 6000.0;
            attribute :>> optimisticValue = 4000.0;
            attribute :>> impactDescription = "Break-even shifts by approximately 2 months in each direction";
        }

        part sensitivityOverhead : SensitivityParameter {
            attribute :>> parameterRef = "overheadPercentage";
            attribute :>> baseValue = 25.0;
            attribute :>> pessimisticValue = 35.0;
            attribute :>> optimisticValue = 20.0;
            attribute :>> impactDescription = "Break-even shifts by approximately 2 months in each direction";
        }

        // Illustrative projection outputs

        part outputMonth1 : ProjectionOutput {
            attribute :>> periodLabel = "Month 1";
            attribute :>> revenue = 1200.0;
            attribute :>> cost = 4488.0;
            attribute :>> margin = -3288.0;
            attribute :>> cumulativeCashFlow = -3288.0;
            attribute :>> activePatientsTotal = 4;
            attribute :>> clinicianUtilisation = 15.0;
            attribute :>> confidenceProfile = "low — early month, envelope-level overhead estimate";
        }

        part outputMonth6 : ProjectionOutput {
            attribute :>> periodLabel = "Month 6";
            attribute :>> revenue = 2550.0;
            attribute :>> cost = 4750.0;
            attribute :>> margin = -2200.0;
            attribute :>> cumulativeCashFlow = -15500.0;
            attribute :>> activePatientsTotal = 20;
            attribute :>> clinicianUtilisation = 35.0;
            attribute :>> confidenceProfile = "moderate — growth assumptions dominate";
        }

        part outputMonth12 : ProjectionOutput {
            attribute :>> periodLabel = "Month 12";
            attribute :>> revenue = 4800.0;
            attribute :>> cost = 5050.0;
            attribute :>> margin = -250.0;
            attribute :>> cumulativeCashFlow = -18500.0;
            attribute :>> activePatientsTotal = 38;
            attribute :>> clinicianUtilisation = 55.0;
            attribute :>> confidenceProfile = "moderate — conversion and churn assumptions becoming significant";
        }

        part outputMonth18 : ProjectionOutput {
            attribute :>> periodLabel = "Month 18";
            attribute :>> revenue = 7500.0;
            attribute :>> cost = 6250.0;
            attribute :>> margin = 1250.0;
            attribute :>> cumulativeCashFlow = -12500.0;
            attribute :>> activePatientsTotal = 52;
            attribute :>> clinicianUtilisation = 72.0;
            attribute :>> confidenceProfile = "moderate — churn rate now material to projections";
        }

        part outputMonth24 : ProjectionOutput {
            attribute :>> periodLabel = "Month 24";
            attribute :>> revenue = 10500.0;
            attribute :>> cost = 6650.0;
            attribute :>> margin = 3850.0;
            attribute :>> cumulativeCashFlow = -1200.0;
            attribute :>> activePatientsTotal = 65;
            attribute :>> clinicianUtilisation = 85.0;
            attribute :>> confidenceProfile = "moderate — long-term churn assumption least validated";
        }

        // Initial forecast baseline

        part leanClinicalBaselineV1 : ForecastBaseline {
            attribute :>> baselineName = "Lean Clinical launch baseline";
            attribute :>> baselineVersion = 1;
            attribute :>> scenarioRef = "Lean Clinical (Variant A)";
            attribute :>> effectiveDate = "Pre-launch";
            attribute :>> parameterSnapshot = "All parameters at section 7.2 base values. 4 patients/month year 1, 6 patients/month year 2, 0.5 FTE months 1-9, 0.8 FTE months 10-24, 25% overhead.";
            attribute :>> notes = "Re-baseline when 6+ months of actuals indicate material deviation from assumptions";
        }

        // =============================================================
        // GSL Full Platform scenario instantiation (Variant B)
        // =============================================================
        //
        // Phase 5, Stage 3. Full parameterisation of the Full Platform
        // variant. Shares clinical parameters with Variant A (same
        // assessment fee, monitoring fee, conversion rates, churn).
        // Adds subscription revenue, coach/moderator costs, higher
        // platform cost, and a two-clinician FTE schedule.
        //
        // All values are illustrative placeholders per Phase 5
        // guardrail G1 — set once, not tuned.
        //
        // Key structural finding: subscription revenue requires a
        // new ProjectionFormula (formulaSubscriptionRevenue) because
        // it introduces an additive revenue stream with its own
        // volume driver (activeSubscribers). The existing Variant A
        // formulas handle the clinical revenue component unchanged.

        part fullPlatformScenario : ScenarioDefinition {
            attribute :>> scenarioName = "Full Platform (Variant B)";
            attribute :>> description = "Clinical care plus coaching, education, and community. 2 clinicians, subscription pricing alongside per-episode clinical fees.";
            attribute :>> activeOfferings = "Initial Assessment, Hormone Therapy Initiation, Ongoing Monitoring, Coaching, Education, Community";
            attribute :>> variantLabel = "B";
            attribute :>> timelineMonths = 24;
            attribute :>> notes = "All values are illustrative placeholders. Subscription revenue is additive to clinical episode revenue.";
        }

        // Variant B projection parameters — subscription revenue

        part fpParamSubscriptionFee : ProjectionParameter {
            attribute :>> parameterName = "subscriptionFeePerMonth";
            attribute :>> parameterValue = 99.0;
            attribute :>> unit = "£/month";
            attribute :>> sourceRef = "FinancialPlanning::subscriptionPricing";
            attribute :>> temporalVariation = "";
            attribute :>> notes = "Flat monthly fee for coaching, education, community access. Placeholder.";
        }

        part fpParamSubscriptionUptake : ProjectionParameter {
            doc /* Simplifying assumption: all active patients in the
                 * Full Platform variant are subscribers. This is the
                 * simplest model and can be relaxed in future if a
                 * clinical-only tier is introduced. */
            attribute :>> parameterName = "subscriptionUptakeRate";
            attribute :>> parameterValue = 100.0;
            attribute :>> unit = "%";
            attribute :>> sourceRef = "Design assumption";
            attribute :>> temporalVariation = "";
            attribute :>> notes = "100% — all active patients are subscribers. Simplifying assumption documented per Phase 5 plan.";
        }

        // Variant B projection parameters — resource cost (new)

        part fpParamCoachFTE : ProjectionParameter {
            attribute :>> parameterName = "coachFTE";
            attribute :>> parameterValue = 0.5;
            attribute :>> unit = "FTE";
            attribute :>> sourceRef = "ResourcePlanning::coachInstance";
            attribute :>> temporalVariation = "";
            attribute :>> notes = "0.5 FTE throughout. Constant — does not scale within 24-month projection.";
        }

        part fpParamCoachCost : ProjectionParameter {
            attribute :>> parameterName = "coachCostPerFTEPerMonth";
            attribute :>> parameterValue = 3000.0;
            attribute :>> unit = "£/FTE/month";
            attribute :>> sourceRef = "FinancialPlanning::coachCost";
            attribute :>> temporalVariation = "";
            attribute :>> notes = "Placeholder — below clinician rate";
        }

        part fpParamModeratorFTE : ProjectionParameter {
            attribute :>> parameterName = "moderatorFTE";
            attribute :>> parameterValue = 0.2;
            attribute :>> unit = "FTE";
            attribute :>> sourceRef = "ResourcePlanning::moderatorInstance";
            attribute :>> temporalVariation = "";
            attribute :>> notes = "0.2 FTE throughout. 1 day per week.";
        }

        part fpParamModeratorCost : ProjectionParameter {
            attribute :>> parameterName = "moderatorCostPerFTEPerMonth";
            attribute :>> parameterValue = 2000.0;
            attribute :>> unit = "£/FTE/month";
            attribute :>> sourceRef = "FinancialPlanning::moderatorCost";
            attribute :>> temporalVariation = "";
            attribute :>> notes = "Placeholder";
        }

        part fpParamPlatformCost : ProjectionParameter {
            doc /* Higher than Variant A (£200) due to community
                 * platform infrastructure. */
            attribute :>> parameterName = "platformCostPerMonth";
            attribute :>> parameterValue = 500.0;
            attribute :>> unit = "£/month";
            attribute :>> sourceRef = "FinancialPlanning::platformCost";
            attribute :>> temporalVariation = "";
            attribute :>> notes = "Higher than Variant A due to community platform hosting";
        }

        // Variant B projection parameters — clinician FTE schedule
        //
        // Two clinicians. Clinician 1: 0.5 FTE months 1-5, 0.8 FTE
        // from month 6. Clinician 2: 0.5 FTE from month 6, 1.0 FTE
        // from month 12. Total FTE: 0.5 → 1.3 → 1.8.

        part fpParamClinician1FTEEarly : ProjectionParameter {
            attribute :>> parameterName = "clinician1FTEMonths1to5";
            attribute :>> parameterValue = 0.5;
            attribute :>> unit = "FTE";
            attribute :>> sourceRef = "ResourcePlanning::clinicianMonth1to9";
            attribute :>> temporalVariation = "Months 1-5. Steps to 0.8 FTE at month 6.";
            attribute :>> notes = "Clinician 1 early phase";
        }

        part fpParamClinician1FTELater : ProjectionParameter {
            attribute :>> parameterName = "clinician1FTEMonths6to24";
            attribute :>> parameterValue = 0.8;
            attribute :>> unit = "FTE";
            attribute :>> sourceRef = "ResourcePlanning::clinicianMonth10to24";
            attribute :>> temporalVariation = "From month 6 onwards";
            attribute :>> notes = "Clinician 1 scales earlier than Variant A";
        }

        part fpParamClinician2FTEEarly : ProjectionParameter {
            attribute :>> parameterName = "clinician2FTEMonths6to11";
            attribute :>> parameterValue = 0.5;
            attribute :>> unit = "FTE";
            attribute :>> sourceRef = "ResourcePlanning::secondClinicianMonth6to24";
            attribute :>> temporalVariation = "Months 6-11. Steps to 1.0 FTE at month 12.";
            attribute :>> notes = "Second clinician initial phase";
        }

        part fpParamClinician2FTELater : ProjectionParameter {
            attribute :>> parameterName = "clinician2FTEMonths12to24";
            attribute :>> parameterValue = 1.0;
            attribute :>> unit = "FTE";
            attribute :>> sourceRef = "ResourcePlanning::secondClinicianMonth6to24";
            attribute :>> temporalVariation = "From month 12 onwards";
            attribute :>> notes = "Second clinician full capacity";
        }

        // Variant B projection parameters — shared with Variant A
        //
        // The following parameters are shared between variants:
        // assessmentFeePerPatient, monitoringFeePerQuarter,
        // effectiveMonthlyRevenuePerPatient, clinicianCostPerFTEPerMonth,
        // adminFTE, adminCostPerFTEPerMonth, insurancePerMonth,
        // labCostPerBloodPanel, bloodPanelsPerInitiationEpisode,
        // bloodPanelsPerMonitoringQuarter, overheadPercentage,
        // newPatientsPerMonthYear1, newPatientsPerMonthYear2,
        // assessmentToInitiationConversion, initiationToStableConversion,
        // churnRatePerQuarter.
        //
        // These are not duplicated — the engine inherits Variant A
        // clinical parameters and overrides only the parameters that
        // differ. This is documented as a structural finding: the
        // existing parameter vocabulary handles both variants.

        // Variant B growth assumptions

        part fpGrowthPatientAcquisition : GrowthAssumption {
            doc /* Same patient acquisition rate as Variant A.
                 * Deliberately shared to isolate structural cost/
                 * revenue differences between variants. */
            attribute :>> assumptionName = "Patient acquisition (Full Platform)";
            attribute :>> targetVariable = "newPatientsPerMonth";
            attribute :>> growthShape = GrowthShape::stepped;
            attribute :>> startValue = 4.0;
            attribute :>> endValue = 6.0;
            attribute :>> inflectionMonth = 13;
            attribute :>> trajectory = "4 per month year 1, steps to 6 at month 13";
            attribute :>> notes = "Shared with Variant A to isolate cost/revenue differences";
        }

        part fpGrowthClinicianFTE : GrowthAssumption {
            doc /* Two-clinician schedule. Faster scaling than Variant A
                 * to support the larger service offering. */
            attribute :>> assumptionName = "Total clinician FTE (Full Platform)";
            attribute :>> targetVariable = "totalClinicianFTE";
            attribute :>> growthShape = GrowthShape::stepped;
            attribute :>> startValue = 0.5;
            attribute :>> endValue = 1.8;
            attribute :>> inflectionMonth = 6;
            attribute :>> trajectory = "0.5 FTE months 1-5, 1.3 FTE months 6-11, 1.8 FTE months 12-24";
            attribute :>> notes = "Clinician 1 (0.5→0.8) + Clinician 2 (0→0.5→1.0)";
        }

        part fpGrowthSubscriptionBase : GrowthAssumption {
            doc /* Subscribers grow with the active patient pool.
                 * Simplifying assumption: 100% uptake, so subscriber
                 * count equals active patient count. */
            attribute :>> assumptionName = "Subscription base growth";
            attribute :>> targetVariable = "activeSubscribers";
            attribute :>> growthShape = GrowthShape::linear;
            attribute :>> startValue = 0.0;
            attribute :>> endValue = 65.0;
            attribute :>> inflectionMonth = 0;
            attribute :>> trajectory = "Mirrors active patient pool growth (100% uptake assumption)";
            attribute :>> notes = "End value is illustrative — actual depends on cohort dynamics";
        }

        // Variant B projection formula — subscription revenue
        //
        // Structural finding: subscription revenue IS a new formula.
        // The existing formulaTotalRevenue (assessment + monitoring)
        // remains valid for the clinical component. Subscription
        // revenue is additive. The engine composes:
        //   totalRevenue = clinicalRevenue + subscriptionRevenue

        part formulaSubscriptionRevenue : ProjectionFormula {
            doc /* New formula required for Variant B. Subscription
                 * revenue has its own volume driver (active
                 * subscribers) distinct from assessment volume or
                 * monitoring volume. This answers the Phase 5 plan's
                 * key structural question: yes, subscription revenue
                 * requires a new formula. */
            attribute :>> formulaName = "Monthly subscription revenue";
            attribute :>> inputs = "activeSubscribers, subscriptionFeePerMonth";
            attribute :>> expression = "activeSubscribers * subscriptionFeePerMonth";
            attribute :>> outputVariable = "monthlySubscriptionRevenue";
            attribute :>> outputUnit = "£/month";
            attribute :>> notes = "Additive to clinical revenue. activeSubscribers derived from active patient pool x uptake rate.";
        }

        part formulaFullPlatformTotalRevenue : ProjectionFormula {
            doc /* Extended total revenue for Variant B. Composes
                 * clinical revenue (shared formula) with subscription
                 * revenue (new formula). */
            attribute :>> formulaName = "Total monthly revenue (Full Platform)";
            attribute :>> inputs = "monthlyAssessmentRevenue, monthlyMonitoringRevenue, monthlySubscriptionRevenue";
            attribute :>> expression = "monthlyAssessmentRevenue + monthlyMonitoringRevenue + monthlySubscriptionRevenue";
            attribute :>> outputVariable = "totalMonthlyRevenue";
            attribute :>> outputUnit = "£/month";
            attribute :>> notes = "Extends Variant A formula with subscription term";
        }

        part formulaFullPlatformDirectCost : ProjectionFormula {
            doc /* Extended direct cost for Variant B. Adds coach,
                 * moderator, and higher platform cost to Variant A's
                 * cost structure. */
            attribute :>> formulaName = "Monthly direct cost (Full Platform)";
            attribute :>> inputs = "totalClinicianFTE, clinicianCostPerFTEPerMonth, adminFTE, adminCostPerFTEPerMonth, coachFTE, coachCostPerFTEPerMonth, moderatorFTE, moderatorCostPerFTEPerMonth, platformCostPerMonth, insurancePerMonth, bloodPanelsThisMonth, labCostPerBloodPanel";
            attribute :>> expression = "(totalClinicianFTE * clinicianCostPerFTEPerMonth) + (adminFTE * adminCostPerFTEPerMonth) + (coachFTE * coachCostPerFTEPerMonth) + (moderatorFTE * moderatorCostPerFTEPerMonth) + platformCostPerMonth + insurancePerMonth + (bloodPanelsThisMonth * labCostPerBloodPanel)";
            attribute :>> outputVariable = "monthlyDirectCost";
            attribute :>> outputUnit = "£/month";
            attribute :>> notes = "Extends Variant A formula with coach, moderator, higher platform cost";
        }

        // Variant B illustrative projection outputs
        //
        // Hand-estimated sanity-check targets. The engine will produce
        // precise values. These are set once per guardrail G1.
        //
        // Key structural story: Variant B has substantially higher
        // costs (coach, moderator, second clinician earlier) which
        // subscription revenue only partially offsets, resulting in a
        // much later break-even and deeper cumulative cash deficit.

        part fpOutputMonth1 : ProjectionOutput {
            doc /* Month 1: same patients as Variant A but higher
                 * fixed costs (coach, moderator from day 1). Small
                 * subscription revenue from ~3 active patients. */
            attribute :>> periodLabel = "Month 1";
            attribute :>> revenue = 1900.0;
            attribute :>> cost = 8000.0;
            attribute :>> margin = -6100.0;
            attribute :>> cumulativeCashFlow = -6100.0;
            attribute :>> activePatientsTotal = 4;
            attribute :>> clinicianUtilisation = 15.0;
            attribute :>> confidenceProfile = "low — early month, high fixed cost base, envelope overhead";
        }

        part fpOutputMonth6 : ProjectionOutput {
            doc /* Month 6: second clinician joins. ~18 active
                 * patients generating subscription revenue. Cost
                 * step-up as clinician 2 starts. */
            attribute :>> periodLabel = "Month 6";
            attribute :>> revenue = 5400.0;
            attribute :>> cost = 13000.0;
            attribute :>> margin = -7600.0;
            attribute :>> cumulativeCashFlow = -40000.0;
            attribute :>> activePatientsTotal = 20;
            attribute :>> clinicianUtilisation = 25.0;
            attribute :>> confidenceProfile = "moderate — growth assumptions dominate, clinician step-up uncertainty";
        }

        part fpOutputMonth12 : ProjectionOutput {
            doc /* Month 12: clinician 2 steps to 1.0 FTE. ~35
                 * active patients. Subscription revenue growing
                 * but not yet offsetting the higher cost base. */
            attribute :>> periodLabel = "Month 12";
            attribute :>> revenue = 9400.0;
            attribute :>> cost = 16500.0;
            attribute :>> margin = -7100.0;
            attribute :>> cumulativeCashFlow = -80000.0;
            attribute :>> activePatientsTotal = 38;
            attribute :>> clinicianUtilisation = 30.0;
            attribute :>> confidenceProfile = "moderate — subscription uptake assumption becoming significant";
        }

        part fpOutputMonth18 : ProjectionOutput {
            doc /* Month 18: ~50 active patients. Subscription
                 * revenue ~£5K/month. Deficit narrowing but still
                 * negative margin. */
            attribute :>> periodLabel = "Month 18";
            attribute :>> revenue = 13500.0;
            attribute :>> cost = 16000.0;
            attribute :>> margin = -2500.0;
            attribute :>> cumulativeCashFlow = -100000.0;
            attribute :>> activePatientsTotal = 52;
            attribute :>> clinicianUtilisation = 40.0;
            attribute :>> confidenceProfile = "moderate — churn rate and subscription retention now material";
        }

        part fpOutputMonth24 : ProjectionOutput {
            doc /* Month 24: ~63 active patients. Approaching
                 * break-even but cumulative deficit still deep.
                 * Subscription revenue ~£6.2K/month. */
            attribute :>> periodLabel = "Month 24";
            attribute :>> revenue = 16500.0;
            attribute :>> cost = 16000.0;
            attribute :>> margin = 500.0;
            attribute :>> cumulativeCashFlow = -92000.0;
            attribute :>> activePatientsTotal = 65;
            attribute :>> clinicianUtilisation = 50.0;
            attribute :>> confidenceProfile = "moderate — long-term assumptions dominate, subscription retention least validated";
        }

        // Variant B sensitivity parameters

        part fpSensitivitySubscriptionPrice : SensitivityParameter {
            attribute :>> parameterRef = "subscriptionFeePerMonth";
            attribute :>> baseValue = 99.0;
            attribute :>> pessimisticValue = 59.0;
            attribute :>> optimisticValue = 149.0;
            attribute :>> impactDescription = "Subscription price directly affects revenue diversification benefit. At £59 subscription contributes less than clinical revenue; at £149 it becomes the dominant revenue stream.";
        }

        part fpSensitivitySubscriptionUptake : SensitivityParameter {
            attribute :>> parameterRef = "subscriptionUptakeRate";
            attribute :>> baseValue = 100.0;
            attribute :>> pessimisticValue = 60.0;
            attribute :>> optimisticValue = 100.0;
            attribute :>> impactDescription = "If only 60% of patients subscribe, subscription revenue drops by 40% while coach and moderator costs remain fixed. Tests whether subscription model is viable at partial uptake.";
        }

        // Variant B forecast baseline

        part fullPlatformBaselineV1 : ForecastBaseline {
            attribute :>> baselineName = "Full Platform launch baseline";
            attribute :>> baselineVersion = 1;
            attribute :>> scenarioRef = "Full Platform (Variant B)";
            attribute :>> effectiveDate = "Pre-launch";
            attribute :>> parameterSnapshot = "Shared clinical params with Variant A. Subscription £99/month, 100% uptake. Coach 0.5 FTE, moderator 0.2 FTE. Clinician 1: 0.5→0.8 FTE at month 6. Clinician 2: 0.5→1.0 FTE at months 6→12. Platform £500/month. 25% overhead.";
            attribute :>> notes = "Illustrative placeholders per Phase 5 guardrail G1. All parameter values set once, not tuned.";
        }
    }

    // =================================================================
    // STRATEGY AND EVOLUTION — Where the business is heading
    // =================================================================

    package StrategyAndEvolution {
        private import ScalarValues::*;

        doc /* Strategic direction, business model variants, and
             * pivot scenarios. Captures the intentional direction
             * that the other concerns serve: where is this business
             * heading, what alternatives exist, and what would
             * trigger a change of direction?
             *
             * Connects to Enterprise::Strategy (upgrading the
             * current placeholder) and to ScenarioModelling
             * (each variant has a corresponding ScenarioDefinition
             * with full parameterisation).
             *
             * Variant A and B are fully elaborated with
             * ScenarioDefinitions. Variant C remains a placeholder.
             *
             * Source: gsl-service-business-meta-modelling.md
             * sections 3.5, 7.1 */

        // -- Part definitions ----------------------------------

        part def StrategicObjective {
            doc /* A defined business goal with a timeframe, success
                 * criteria, and relationship to capabilities and
                 * scenarios. Provides the intentional direction that
                 * the other concerns serve.
                 *
                 * Formal satisfy relationships from objectives to
                 * capabilities are deferred to Phase 7. */
            attribute objectiveName : String;
            attribute description : String;
            attribute targetDate : String;          // e.g. "Month 18", "Year 2 Q4"
            attribute successCriteria : String;
            attribute relatedCapabilities : String; // references Capability names
            attribute relatedScenarios : String;    // references ScenarioDefinition names
            attribute status : String;              // planned, in progress, achieved, revised
        }

        part def BusinessModelVariant {
            doc /* A named alternative business model configuration.
                 * Lighter than a full ScenarioDefinition — captures
                 * the strategic essence for comparison at the
                 * boardroom level. The detailed scenario lives in
                 * ScenarioModelling and is referenced via scenarioRef. */
            attribute variantName : String;
            attribute variantLabel : String;        // e.g. "A", "B", "C"
            attribute description : String;
            attribute activeOfferings : String;
            attribute keyDifferentiator : String;
            attribute investmentLevel : String;     // e.g. "~£15K", "~£120K"
            attribute riskProfile : String;
            attribute scenarioRef : String;         // references a ScenarioDefinition name
        }

        part def PivotScenario {
            doc /* A structured what-if analysis for transitioning
                 * between business model variants. Captures the
                 * trigger condition, transition plan, estimated
                 * duration, and risks. */
            attribute pivotName : String;
            attribute fromVariant : String;         // references a BusinessModelVariant name
            attribute toVariant : String;           // references a BusinessModelVariant name
            attribute triggerCondition : String;
            attribute transitionPlan : String;
            attribute estimatedTransitionMonths : Integer;
            attribute riskNotes : String;
        }

        // -- GSL strategic objectives --------------------------

        part objectivePatientCohort : StrategicObjective {
            attribute :>> objectiveName = "Build active patient cohort";
            attribute :>> description = "Reach 200 active patients across assessment, initiation, and monitoring";
            attribute :>> targetDate = "Month 18";
            attribute :>> successCriteria = "200+ patients in active monitoring or initiation by month 18";
            attribute :>> relatedCapabilities = "Prescribing and monitoring, Clinical assessment, Blood monitoring";
            attribute :>> relatedScenarios = "Lean Clinical (Variant A)";
            attribute :>> status = "planned";
        }

        part objectiveSharedCare : StrategicObjective {
            attribute :>> objectiveName = "Establish shared care network";
            attribute :>> description = "Build shared care agreements with GP practices for ongoing monitoring";
            attribute :>> targetDate = "Month 24";
            attribute :>> successCriteria = "50+ signed shared care protocols with GP practices";
            attribute :>> relatedCapabilities = "Prescribing and monitoring";
            attribute :>> relatedScenarios = "Lean Clinical (Variant A), Full Platform (Variant B)";
            attribute :>> status = "planned";
        }

        part objectiveBreakEven : StrategicObjective {
            attribute :>> objectiveName = "Financial break-even";
            attribute :>> description = "Reach the point where cumulative cash flow turns positive";
            attribute :>> targetDate = "Month 24";
            attribute :>> successCriteria = "Cumulative cash flow >= £0";
            attribute :>> relatedCapabilities = "";
            attribute :>> relatedScenarios = "Lean Clinical (Variant A)";
            attribute :>> status = "planned";
        }

        part objectivePlatformLaunch : StrategicObjective {
            attribute :>> objectiveName = "Patient portal operational";
            attribute :>> description = "Launch the patient-facing portal with pathway visibility, journal, and document access";
            attribute :>> targetDate = "Month 6";
            attribute :>> successCriteria = "Portal live with pathway visibility, journal, and document access features";
            attribute :>> relatedCapabilities = "Clinical assessment, Prescribing and monitoring";
            attribute :>> relatedScenarios = "Lean Clinical (Variant A), Full Platform (Variant B)";
            attribute :>> status = "planned";
        }

        // -- Business model variants (summary level) -----------

        part variantLeanClinical : BusinessModelVariant {
            attribute :>> variantName = "Lean Clinical";
            attribute :>> variantLabel = "A";
            attribute :>> description = "Assessment and hormone therapy only. No coaching, no community. Lowest capital, fastest break-even, limited revenue ceiling.";
            attribute :>> activeOfferings = "Initial Assessment, Hormone Therapy Initiation, Ongoing Monitoring";
            attribute :>> keyDifferentiator = "Low capital, fast break-even, limited ceiling";
            attribute :>> investmentLevel = "~£15K";
            attribute :>> riskProfile = "High sensitivity to patient acquisition; single point of failure (1 clinician)";
            attribute :>> scenarioRef = "Lean Clinical (Variant A)";
        }

        part variantFullPlatform : BusinessModelVariant {
            doc /* Full Platform variant with complete ScenarioDefinition
                 * and projection parameters in ScenarioModelling.
                 * Elaborated in Phase 5. */
            attribute :>> variantName = "Full Platform";
            attribute :>> variantLabel = "B";
            attribute :>> description = "Full digital platform with coaching, education, community, patient portal. Subscription model. Higher ceiling, longer break-even.";
            attribute :>> activeOfferings = "Initial Assessment, Hormone Therapy Initiation, Ongoing Monitoring, Coaching, Education, Community";
            attribute :>> keyDifferentiator = "Full digital platform, subscription revenue, higher ceiling";
            attribute :>> investmentLevel = "~£120K";
            attribute :>> riskProfile = "Longer break-even, higher capital requirement; more diversified revenue";
            attribute :>> scenarioRef = "Full Platform (Variant B)";
        }

        part variantConsultancyLicence : BusinessModelVariant {
            doc /* Deferred beyond Phase 5. Requires modelling
                 * licence pricing, platform deployment for licensees,
                 * and support cost structures. */
            attribute :>> variantName = "Consultancy + Platform Licence";
            attribute :>> variantLabel = "C";
            attribute :>> description = "Dual revenue: clinical services AND platform licence/SaaS to other gender services. Highest ceiling, longest break-even.";
            attribute :>> activeOfferings = "Initial Assessment, Hormone Therapy Initiation, Ongoing Monitoring, Platform Licence";
            attribute :>> keyDifferentiator = "Scalable platform revenue independent of clinical capacity";
            attribute :>> investmentLevel = "~£200K";
            attribute :>> riskProfile = "Longest break-even, highest capital; platform revenue scalable independently";
            attribute :>> scenarioRef = "";
        }

        // -- Pivot scenarios -----------------------------------

        part pivotLeanToFull : PivotScenario {
            doc /* The most likely transition path. Variant A
                 * establishes clinical operations and proves the
                 * model; Variant B adds platform capabilities
                 * when demand and resources allow. */
            attribute :>> pivotName = "Lean Clinical to Full Platform transition";
            attribute :>> fromVariant = "Lean Clinical (A)";
            attribute :>> toVariant = "Full Platform (B)";
            attribute :>> triggerCondition = "Break-even achieved and patient demand exceeds single-clinician capacity";
            attribute :>> transitionPlan = "Hire second clinician, add coaching capability, launch subscription model, expand patient portal";
            attribute :>> estimatedTransitionMonths = 6;
            attribute :>> riskNotes = "Requires capital injection or retained earnings sufficient for 6-month transition period";
        }
    }
}
