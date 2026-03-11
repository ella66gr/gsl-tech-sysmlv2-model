// =========================================================================
// OPERATIONS — Back office and growth functions
// =========================================================================

package Operations {
    private import ScalarValues::*;

    doc /* Back office and growth functions. The day-to-day operational
         * machinery that keeps the business running: invoicing, HR,
         * marketing, CRM, reporting, estates, and procurement.
         *
         * Distinct from BusinessModel which captures the structural
         * logic (what are our revenue streams, what resources do we
         * need). Operations captures the processes that execute that
         * logic (how do we actually send invoices, recruit staff,
         * manage premises).
         *
         * Modelled at a lightweight level: enough structure to show
         * data flows between operations and clinical service delivery,
         * and to provide the operational anchor points that the
         * steering cycle (Phase 6B) will connect to the Knowledge
         * layer's self-knowledge infrastructure.
         *
         * Outer ring.
         *
         * Phase 6A: Expanded Finance, People, Reporting. Added
         * EstatesAndFacilities. Per meta-modelling document section 6. */

    // =================================================================
    // FINANCE — Operational accounting and financial processes
    // =================================================================

    package Finance {
        private import ScalarValues::*;

        doc /* Operational accounting: invoice processing, payment
             * reconciliation, accounting system integration, and
             * financial reporting. This is the day-to-day financial
             * machinery.
             *
             * Distinct from BusinessModel::FinancialPlanning which
             * captures structural economics (revenue streams, cost
             * drivers, unit economics). Finance handles the
             * transactional reality: sending invoices, chasing
             * payments, producing management accounts.
             *
             * Primary integration: Xero for accounting, bank feeds
             * for reconciliation. */

        part def AccountingIntegration {
            doc /* Describes an integration point with an external
                 * accounting system. Currently Xero; the part def
                 * is system-agnostic. */
            attribute integrationName : String;
            attribute targetSystem : String;
            attribute syncFrequency : String;
            attribute dataFlows : String;
            attribute notes : String;
        }

        // -- Use cases -----------------------------------------

        use case def ProcessInvoice {
            doc /* Generate, issue, and track an invoice. Integrates
                 * with Xero for accounting. Triggered by service
                 * delivery events (assessment completion, monitoring
                 * review, subscription renewal). */
        }

        use case def ReconcilePayments {
            doc /* Reconcile payments received against invoices issued.
                 * Bank feed data matched against invoice records.
                 * Flags overdue and unmatched payments. */
        }

        use case def ProduceManagementAccounts {
            doc /* Generate monthly management accounts from Xero
                 * data. Revenue by stream, cost by driver, margin,
                 * cash position. The operational data source that
                 * feeds PeriodActuals in the steering cycle. */
        }

        use case def GenerateCashFlowForecast {
            doc /* Produce a cash flow forecast from current actuals
                 * and projection parameters. Combines the operational
                 * position (what has happened) with the scenario
                 * projection (what we expect to happen). This is
                 * the operational bridge between Finance and
                 * BusinessScenarios. */
        }

        // -- GSL instantiation ---------------------------------

        part xeroIntegration : AccountingIntegration {
            attribute :>> integrationName = "Xero accounting integration";
            attribute :>> targetSystem = "Xero";
            attribute :>> syncFrequency = "Daily automatic sync via bank feed; manual reconciliation weekly";
            attribute :>> dataFlows = "Invoices (out), payments (in), bank transactions (in), chart of accounts (bidirectional)";
            attribute :>> notes = "Xero is the primary financial record. Management accounts derived from Xero data.";
        }
    }

    // =================================================================
    // PEOPLE — Workforce management and HR
    // =================================================================

    package People {
        private import ScalarValues::*;

        doc /* Workforce management: roles, contracts, recruitment,
             * professional development, appraisal, revalidation,
             * and indemnity insurance.
             *
             * Distinct from BusinessModel::ResourcePlanning which
             * captures structural resource needs (how many clinicians
             * for N patients). People handles the operational reality:
             * contracts, CPD tracking, insurance renewal.
             *
             * For a small clinical service, People processes are
             * largely manual with light system support. The model
             * captures the processes at use case level — enough to
             * show what must happen, not how to automate it. */

        part def WorkforceRole {
            doc /* A defined role within the operational workforce.
                 * Captures the contract and qualification view of
                 * a role, complementing the planning view in
                 * BusinessModel::ResourcePlanning::ResourceType.
                 *
                 * WorkforceRole says "this person needs these
                 * qualifications and this contract type."
                 * ResourceType says "this category of resource
                 * costs this much and has this capacity." */
            attribute roleName : String;
            attribute contractType : String;       // employed, contracted, sessional, volunteer
            attribute requiredQualifications : String;
            attribute regulatoryRequirements : String;  // GMC, NMC, DBS, etc.
            attribute fteAllocation : String;      // e.g. "0.5 FTE", "sessional as needed"
            attribute appraisalCycle : String;     // e.g. "annual", "N/A for contracted"
            attribute resourceTypeRef : String;    // references ResourcePlanning::ResourceType by name
        }

        // -- Use cases -----------------------------------------

        use case def ManageRecruitment {
            doc /* Hiring pipeline from need identification through to
                 * onboarding. Includes: role specification, advertising,
                 * shortlisting, interview, offer, pre-employment checks
                 * (DBS, references, qualification verification),
                 * onboarding. */
        }

        use case def ConductAppraisal {
            doc /* Annual appraisal process. For clinical staff, this
                 * feeds into GMC revalidation. Includes: self-assessment,
                 * CPD portfolio review, objective setting, performance
                 * discussion, development plan. */
        }

        use case def ManageProfessionalDevelopment {
            doc /* CPD tracking and planning. Maintains a record of
                 * professional development activities, maps them to
                 * regulatory requirements (GMC CPD domains), and
                 * identifies development needs.
                 *
                 * For a solo clinician practice, this is primarily
                 * self-managed with the system providing tracking
                 * and reminders. */
        }

        use case def RenewIndemnityInsurance {
            doc /* Annual insurance renewal cycle. Professional
                 * indemnity (MPS or equivalent) and employer liability.
                 * Triggered by renewal date, requires updated scope
                 * of practice declaration. */
        }

        // -- GSL instantiation ---------------------------------

        part clinicianRole : WorkforceRole {
            attribute :>> roleName = "Prescribing clinician";
            attribute :>> contractType = "employed or contracted";
            attribute :>> requiredQualifications = "GMC registration, prescribing qualification, RCP Certificate in Gender Identity Healthcare";
            attribute :>> regulatoryRequirements = "GMC registration, annual appraisal, revalidation cycle, DBS enhanced check";
            attribute :>> fteAllocation = "0.5-0.8 FTE (Variant A); stepping schedule per scenario";
            attribute :>> appraisalCycle = "annual (feeds GMC revalidation)";
            attribute :>> resourceTypeRef = "Prescribing clinician";
        }

        part adminRole : WorkforceRole {
            attribute :>> roleName = "Administrative support";
            attribute :>> contractType = "employed";
            attribute :>> requiredQualifications = "None specific — administrative and organisational competence";
            attribute :>> regulatoryRequirements = "DBS basic check";
            attribute :>> fteAllocation = "0.3 FTE";
            attribute :>> appraisalCycle = "annual";
            attribute :>> resourceTypeRef = "Administrative support";
        }
    }

    // =================================================================
    // ESTATES AND FACILITIES — Premises, equipment, procurement
    // =================================================================

    package EstatesAndFacilities {
        private import ScalarValues::*;

        doc /* Premises, equipment, and procurement. Manages the
             * physical infrastructure that supports service delivery.
             *
             * For a primarily digital service with sessional clinical
             * premises, this is lightweight. The model captures enough
             * structure to show that estates concerns exist and have
             * cost implications, without modelling facilities
             * management in detail.
             *
             * New in Phase 6A. Per meta-modelling document section 6. */

        part def PremisesArrangement {
            doc /* Describes a premises arrangement — the physical
                 * space used for clinical or administrative work.
                 * May be rented, shared, or virtual. */
            attribute premisesName : String;
            attribute locationType : String;       // clinic room, office, coworking, home, virtual
            attribute tenureType : String;         // rented, shared, owned, sessional, none
            attribute monthlyCost : Real;
            attribute capacityNotes : String;      // e.g. "1 consultation room, seats 2"
            attribute availabilityNotes : String;  // e.g. "3 days/week", "as booked"
        }

        part def EquipmentInventory {
            doc /* A category of equipment used in service delivery
                 * or operations. Tracks what exists, not individual
                 * asset management. */
            attribute equipmentCategory : String;  // clinical, IT, office, communications
            attribute items : String;              // descriptive inventory
            attribute maintenanceSchedule : String;
            attribute replacementCycle : String;
            attribute notes : String;
        }

        // -- Use cases -----------------------------------------

        use case def ManageProcurement {
            doc /* Purchasing workflow from need identification to
                 * delivery. Covers clinical supplies, IT equipment,
                 * software licences, and professional services.
                 * Lightweight: no formal tendering for a small
                 * practice. */
        }

        // -- GSL instantiation ---------------------------------

        part clinicRoom : PremisesArrangement {
            doc /* Sessional clinic room for face-to-face consultations.
                 * Most consultations are via video; face-to-face is
                 * available for assessment and complex reviews. */
            attribute :>> premisesName = "Sessional clinic room";
            attribute :>> locationType = "clinic room";
            attribute :>> tenureType = "sessional";
            attribute :>> monthlyCost = 0.0;       // included in overhead allocation
            attribute :>> capacityNotes = "1 consultation room, seats 2-3";
            attribute :>> availabilityNotes = "Booked as needed — 1-2 days per month initially";
        }

        part homeOffice : PremisesArrangement {
            doc /* Home office for administrative work, video
                 * consultations, and platform development. Primary
                 * working location for the sole clinician model. */
            attribute :>> premisesName = "Home office";
            attribute :>> locationType = "home";
            attribute :>> tenureType = "none";
            attribute :>> monthlyCost = 0.0;       // no additional cost
            attribute :>> capacityNotes = "Desk, video setup, dual monitors";
            attribute :>> availabilityNotes = "Full availability";
        }

        part itEquipment : EquipmentInventory {
            attribute :>> equipmentCategory = "IT";
            attribute :>> items = "MacBook Pro (development and clinical), external displays, webcam, headset, backup storage";
            attribute :>> maintenanceSchedule = "Continuous — OS and software updates";
            attribute :>> replacementCycle = "3-4 years";
            attribute :>> notes = "Development machine doubles as clinical workstation in Variant A";
        }

        part clinicalEquipment : EquipmentInventory {
            attribute :>> equipmentCategory = "clinical";
            attribute :>> items = "Blood pressure monitor, weighing scales, height measure, phlebotomy kit (if in-house blood draws)";
            attribute :>> maintenanceSchedule = "Annual calibration for BP monitor and scales";
            attribute :>> replacementCycle = "5 years";
            attribute :>> notes = "Minimal equipment for a primarily digital service with external lab";
        }
    }

    // =================================================================
    // MARKETING — Acquisition and growth
    // =================================================================

    package Marketing {
        private import ScalarValues::*;

        doc /* Acquisition funnel, content production, community
             * development (Mighty Networks, Kit), advertising, SEO.
             *
             * Much of this domain is inherently creative and ad-hoc.
             * The model defines touchpoints and data flows rather than
             * generating execution. */

        use case def ManageAcquisitionFunnel {
            doc /* Track patient acquisition from initial awareness
                 * through to registration. Maps to the growth
                 * assumptions in BusinessScenarios — the acquisition
                 * funnel is where the newPatientsPerMonth parameter
                 * becomes operational reality. */
        }
    }

    // =================================================================
    // CRM — Relationship management
    // =================================================================

    package CRM {
        private import ScalarValues::*;

        doc /* Prospect and patient relationship management,
             * communication preferences, segmentation. */
    }

    // =================================================================
    // REPORTING — Dashboards, regulatory, and business metrics
    // =================================================================

    package Reporting {
        private import ScalarValues::*;

        doc /* Business intelligence, operational dashboards, regulatory
             * reporting, KPI tracking.
             *
             * If every process, decision, state transition, and constraint
             * evaluation is modelled and tracked, then operational
             * questions are queries over existing event history rather
             * than separate analytics pipelines.
             *
             * Phase 6A: added ProduceBusinessModelMetrics — the
             * operational bridge to the steering cycle. */

        use case def GenerateOperationalDashboard {
            doc /* Produce operational dashboard: referral-to-appointment
                 * times, pathway bottlenecks, capacity utilisation. */
        }

        use case def ProduceRegulatoryReport {
            doc /* Generate regulatory reports for CQC, NHS England, or
                 * other bodies from system data. */
        }

        use case def ProduceBusinessModelMetrics {
            doc /* Generate KPI report mapped to BusinessModel and
                 * BusinessScenarios components. Key metrics:
                 *
                 * - Patient acquisition rate vs projection
                 * - Revenue by stream vs forecast
                 * - Clinician utilisation vs capacity model
                 * - Churn rate vs assumption
                 * - Cumulative cash flow vs projection
                 *
                 * This is the operational data source that feeds
                 * PeriodActuals in the steering cycle. The metrics
                 * are derived from the same authoritative sources
                 * (Xero for financials, Temporal for workflow state,
                 * CDR for clinical data) that the Knowledge layer's
                 * OperationalStateAggregator already queries.
                 *
                 * Phase 6B will wire this to the Knowledge layer's
                 * five-layer SystemStateAssessment. */
        }
    }
}
