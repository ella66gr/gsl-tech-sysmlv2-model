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
         * - Financial Model (here: FinancialPlanning — Phase 2)
         * - Resource and Capability Model (here: ResourcePlanning — Phase 2)
         * - Service Delivery System (ServiceDelivery package)
         * - Governance and Adaptation (Enterprise + ServiceDelivery::ClinicalGovernance)
         *
         * Cross-cutting: ActivityModel provides the activity taxonomy
         * and costing foundation that connects all five concerns.
         *
         * Source: gsl-service-business-meta-modelling.md
         *
         * Phase 1 (this file): ServiceConcept + ActivityModel
         * Phase 2 (planned): ResourcePlanning + FinancialPlanning
         * Phase 3 (planned): ScenarioModelling + StrategyAndEvolution */

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
}
