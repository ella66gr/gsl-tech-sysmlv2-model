package GenderSense {
    private import ScalarValues::*;

    doc /* GenderSense: Model-driven clinical service management platform
         * for gender-affirming healthcare.
         *
         * This package hierarchy defines the complete business system scope.
         * Modelling rigour varies by area: maximum for clinical pathways and
         * entity lifecycles (inner ring), moderate for platform interfaces and
         * decision support (middle ring), lightweight for business context and
         * organisational structure (outer ring).
         *
         * Representation layer (this model) is the source of truth.
         * Execution layer consumes it via generation or configuration.
         *
         * Verified clean in Syside Modeler 0.8.5 (5 March 2026).
         * use case def, requirement def with subject, satisfy relationships,
         * and constraint def with evaluable bodies all parse correctly.
         */

    // =========================================================================
    // ENTERPRISE — What GenderSense is and how it is governed
    // =========================================================================

    package Enterprise {
        private import ScalarValues::*;

        doc /* Defines the organisational, regulatory, strategic, and risk context.
             * Primarily architectural documentation (outer ring). Provides the
             * anchoring context that everything else traces to. */

        package Organisation {
            private import ScalarValues::*;

            doc /* Roles, teams, governance structure, board, leadership,
                 * and responsibility allocations. */

            part def Role {
                doc /* A named role within the organisation. */
                attribute roleName : String;
                attribute description : String;
            }

            part def Team {
                doc /* An organisational unit composed of roles. */
                attribute teamName : String;
                ref roles : Role[1..*];
            }

            part def GovernanceBody {
                doc /* A governance or oversight body (e.g. clinical governance
                     * committee, board, advisory group). */
                attribute bodyName : String;
                attribute remit : String;
            }
        }

        package Regulation {
            private import ScalarValues::*;

            doc /* CQC fundamental standards, ICO/GDPR obligations,
                 * DCB0129/DCB0160 clinical safety, GMC professional standards,
                 * Equality Act requirements. Modelled as requirements with
                 * satisfy relationships to system elements. */

            use case def MeetCQCFundamentalStandards {
                doc /* Demonstrate compliance with CQC fundamental standards
                     * for a regulated healthcare provider. */
            }

            use case def MeetDataProtectionObligations {
                doc /* Demonstrate compliance with UK GDPR / Data Protection
                     * Act 2018 including DPIA, lawful basis, subject rights. */
            }

            use case def MeetClinicalSafetyRequirements {
                doc /* Demonstrate compliance with DCB0129 (manufacturer) and
                     * DCB0160 (deployer) clinical risk management standards. */
            }

            use case def MeetProfessionalStandards {
                doc /* GMC Good Medical Practice, specialist standards,
                     * appraisal and revalidation requirements. */
            }

            // --- satisfy/verify syntax verification (v3.1) ---

            requirement def BloodMonitoringRequired {
                doc /* Patients on hormone therapy must have blood tests
                     * performed at defined monitoring intervals. This is
                     * a CQC and clinical governance requirement. */
                subject patient : GenderSense::ServiceDelivery::ClinicalEntities::Patient;
                attribute monitoringIntervalWeeks : Integer;
            }

            requirement def ConsentBeforeTreatment {
                doc /* Informed consent must be obtained and recorded
                     * before any treatment is initiated. */
                subject patient : GenderSense::ServiceDelivery::ClinicalEntities::Patient;
            }
        }

        package Strategy {
            private import ScalarValues::*;

            doc /* Partnerships, business model, ethos and values,
                 * CIC/limited company structure, strategic direction.
                 * Lightweight documentation of strategic context. */

            part def Partnership {
                doc /* A strategic partnership or collaboration. */
                attribute partnerName : String;
                attribute nature : String;
            }

            part def BusinessModel {
                doc /* Revenue model, pricing, service tiers. */
                attribute modelName : String;
                attribute description : String;
            }
        }

        package Risk {
            private import ScalarValues::*;

            doc /* Clinical risk management, business continuity, safeguarding
                 * framework, information governance risk. */

            use case def ManageClinicalRisk {
                doc /* Identify, assess, mitigate, and monitor clinical risks
                     * across all service delivery pathways. */
            }

            use case def MaintainBusinessContinuity {
                doc /* Ensure service continuity under adverse conditions
                     * including system failure, staff absence, and external
                     * disruption. */
            }

            use case def ManageSafeguarding {
                doc /* Safeguarding framework for vulnerable adults and
                     * children, including referral pathways and reporting. */
            }
        }
    }

    // =========================================================================
    // KNOWLEDGE — Decision logic, constraints, reasoning, and learning
    // =========================================================================

    package Knowledge {
        private import ScalarValues::*;

        doc /* Explicit treatment of knowledge, decision logic, and adaptive
             * behaviour as first-class architectural concerns. Cross-cutting:
             * imported by clinical pathways, referenced by governance, and
             * consuming outcome data.
             *
             * Three-tier reasoning stack:
             * Tier 1 — Deterministic logic (constraints, safety rules)
             * Tier 2 — Structured decision support (DMN-style tables)
             * Tier 3 — ML/LLM-augmented intelligence (advisory only) */

        package ClinicalDecisionSupport {
            private import ScalarValues::*;

            doc /* Decision rules, eligibility criteria, monitoring protocols,
                 * and clinical guidelines modelled as evaluable constraints.
                 * Consumes CDR data via AQL queries, evaluates against
                 * model-derived rules, and surfaces results to pathways
                 * and clinician/patient interfaces. */

            use case def EvaluateEligibility {
                doc /* Determine whether a patient meets eligibility criteria
                     * for a specific pathway or intervention. */
            }

            use case def TriggerMonitoringAlert {
                doc /* Flag when clinical data (e.g. hormone levels, blood
                     * results) falls outside defined therapeutic ranges. */
            }

            use case def ProvidePathwayGuidance {
                doc /* Surface personalised clinical guidance to patients and
                     * clinicians derived from structured data and rules. */
            }
        }

        package ConstraintLibrary {
            private import ScalarValues::*;
            private import Enterprise::Regulation::*;

            doc /* Composable clinical constraints, safety rules, drug
                 * interaction checks, contraindication screening. Constraints
                 * are reusable and testable in isolation: each takes typed
                 * inputs and returns a boolean evaluation. */

            // --- satisfy/verify syntax verification (v3.1) ---

            constraint def BloodMonitoringIntervalConstraint {
                doc /* Evaluable rule: the number of weeks since the last
                     * blood test must not exceed the required monitoring
                     * interval. */
                in weeksSinceLastTest : Integer;
                in requiredIntervalWeeks : Integer;

                weeksSinceLastTest <= requiredIntervalWeeks
            }

            constraint def ConsentRecordedConstraint {
                doc /* Evaluable rule: a valid consent record must exist
                     * for the specified treatment before it can proceed. */
                in consentRecorded : Boolean;

                consentRecorded
            }

            // Traceability: constraint satisfies requirement
            // Uses constraint usages (not defs) as the 'by' target,
            // and relative paths to avoid namespace shadowing.
            constraint bloodMonitoringCheck : BloodMonitoringIntervalConstraint;
            constraint consentCheck : ConsentRecordedConstraint;

            satisfy requirement BloodMonitoringRequired
                by bloodMonitoringCheck;

            satisfy requirement ConsentBeforeTreatment
                by consentCheck;
        }

        package LogicEngine {
            private import ScalarValues::*;

            doc /* Inference rules, Prolog-style reasoning, deterministic
                 * constraint evaluation. Explicit architectural space for
                 * logic programming.
                 *
                 * Runtime target TBD: embedded Prolog (e.g. Tau Prolog),
                 * TypeScript constraint evaluator, DMN engine, or combination.
                 * Decision deferred until clinical rules are better understood
                 * from first pathway modelling. */
        }

        package DecisionModels {
            private import ScalarValues::*;

            doc /* DMN-style decision tables, decision requirement graphs,
                 * multi-criteria clinical protocol decisions. Deterministic
                 * and auditable. Decision tables map to SysML v2 constraints
                 * and can be read and validated by clinicians.
                 *
                 * Examples: prescribing protocol selection, referral routing,
                 * risk stratification. */
        }

        package OutcomeFramework {
            private import ScalarValues::*;

            doc /* Outcome definitions, measurement points, structured outcome
                 * capture, outcome-to-pathway feedback.
                 *
                 * Records not just that a patient was treated, but the specific
                 * regimen, monitoring results at defined intervals, whether
                 * clinical targets were achieved, and any adverse events. */

            part def OutcomeDefinition {
                doc /* A defined clinical outcome with measurement criteria. */
                attribute outcomeName : String;
                attribute description : String;
                attribute measurementInterval : String;
            }
        }

        package LearningCycles {
            private import ScalarValues::*;

            doc /* Pathway refinement process, evidence review, change control
                 * governance. Itself modelled as an action flow.
                 *
                 * Cycle: capture structured outcomes -> analyse patterns ->
                 * propose pathway refinement -> clinical governance review ->
                 * update model -> regenerate. The model is the mechanism for
                 * both capturing and enacting the learning. */

            use case def ProposePathwayRefinement {
                doc /* Initiate a pathway change proposal based on outcome
                     * data or new clinical evidence. */
            }

            use case def ReviewAndApproveChange {
                doc /* Clinical governance review and approval of a proposed
                     * pathway or protocol change. */
            }
        }

        package Analytics {
            private import ScalarValues::*;

            doc /* Data contracts for BI and predictive analytics, event stream
                 * definitions, ML/LLM integration points, advisory layer
                 * interface definitions.
                 *
                 * Tier 3 reasoning: powerful but probabilistic, always advisory
                 * rather than authoritative. Cannot override Tier 1/2 logic. */

            part def DataContract {
                doc /* Defines the schema and semantics of a data stream
                     * consumed by analytics or ML pipelines. */
                attribute contractName : String;
                attribute description : String;
            }
        }
    }

    // =========================================================================
    // SERVICE DELIVERY — Clinical and operational heart of the system
    // =========================================================================

    package ServiceDelivery {
        private import ScalarValues::*;

        doc /* The clinical and operational heart of GenderSense. Inner ring:
             * model-driven execution with full generation pipeline. Maximum
             * modelling rigour. Coffee shop demonstrator patterns apply
             * directly here. */

        package PatientJourney {
            private import ScalarValues::*;

            doc /* Top-level lifecycle from acquisition through to discharge
                 * and follow-up. The five-phase arc provides the structural
                 * skeleton for all detailed pathways.
                 *
                 * Phases: Acquisition -> Registration -> Assessment ->
                 * Treatment -> Follow Up
                 *
                 * This is the highest-level action flow in ServiceDelivery.
                 * Detailed pathways elaborate specific segments. */

            use case def AcquirePatient {
                doc /* Patient discovers and engages with GenderSense.
                     * Covers marketing touchpoints, initial enquiry,
                     * and conversion to registered patient. */
            }

            use case def RegisterPatient {
                doc /* Patient registration, identity verification,
                     * demographic capture, consent collection, account
                     * creation. */
            }

            use case def AssessPatient {
                doc /* Comprehensive assessment: self-assessment instruments,
                     * clinician assessment, formulation, and treatment
                     * planning. */
            }

            use case def TreatPatient {
                doc /* Active treatment phase: pathway-specific interventions,
                     * monitoring, adjustments, shared care. */
            }

            use case def FollowUpPatient {
                doc /* Ongoing follow-up, outcome capture, discharge planning,
                     * or transition to long-term shared care. */
            }
        }

        package ClinicalPathways {
            private import ScalarValues::*;

            doc /* Detailed clinical pathway models. Each pathway has a
                 * domain-layer action flow (for governance) and an
                 * orchestration-layer action flow (for runtime generation).
                 * Two-layer pattern validated in the coffee shop demonstrator. */

            package HormoneTherapy {
                private import ScalarValues::*;

                doc /* Hormone therapy initiation, titration, monitoring,
                     * and shared care protocols. The recommended first
                     * clinical pathway to model end to end.
                     *
                     * Exercises: long-running waits (lab results, specialist
                     * referrals), multiple participants (patient, GP,
                     * endocrinologist, phlebotomy), governance requirements
                     * (consent, clinical review intervals, monitoring
                     * schedules), full two-layer action flow pattern. */

                use case def InitiateHormoneTherapy {
                    doc /* End-to-end hormone therapy initiation from clinical
                         * decision through to established stable regimen. */
                }

                use case def MonitorHormoneTherapy {
                    doc /* Ongoing monitoring: scheduled blood tests, clinical
                         * review, dose adjustment, safety checks. */
                }

                use case def TransitionToSharedCare {
                    doc /* Establish shared care arrangement with the patient's
                         * GP for ongoing prescribing and monitoring. */
                }
            }

            package Assessment {
                private import ScalarValues::*;

                doc /* New patient assessment, self-assessment instruments,
                     * clinician assessment, formulation and treatment
                     * planning. */

                use case def ConductNewPatientAssessment {
                    doc /* Full new patient assessment process from initial
                         * self-assessment through clinician evaluation to
                         * formulation and treatment plan. */
                }

                use case def AdministorSelfAssessment {
                    doc /* Patient completes validated self-assessment
                         * instruments (e.g. PHQ-9, GAD-7, gender-specific
                         * measures). Structured data captured to CDR. */
                }

                use case def ConductClinicianAssessment {
                    doc /* Clinician-led assessment including history taking,
                         * examination where indicated, risk assessment,
                         * and clinical formulation. */
                }
            }

            package Referrals {
                private import ScalarValues::*;

                doc /* Inbound referral processing, outbound specialist
                     * referrals, shared care arrangements with GPs. */

                use case def ProcessInboundReferral {
                    doc /* Receive, triage, and action an inbound referral
                         * from a GP, self-referral, or other source. */
                }

                use case def MakeOutboundReferral {
                    doc /* Refer a patient to an external specialist service
                         * (endocrinology, surgery, mental health, etc). */
                }

                use case def EstablishSharedCare {
                    doc /* Set up a shared care agreement with a GP practice
                         * for ongoing prescribing and monitoring. */
                }
            }

            package Prescribing {
                private import ScalarValues::*;

                doc /* Prescribing protocols, dispensing, medication monitoring,
                     * repeat prescriptions, dose adjustments. */

                use case def PrescribeMedication {
                    doc /* Issue a prescription following clinical decision,
                         * safety checks, and interaction screening. */
                }

                use case def MonitorMedication {
                    doc /* Ongoing medication monitoring including blood tests,
                         * side effect assessment, and dose adjustment. */
                }

                use case def ManageRepeatPrescription {
                    doc /* Repeat prescription workflow including review
                         * intervals, blood test requirements, and renewal. */
                }
            }
        }

        package Consent {
            private import ScalarValues::*;

            doc /* Consent models: informed consent for treatment, consent
                 * for data processing, capacity assessment, consent
                 * withdrawal, ongoing consent management.
                 *
                 * Consent is a cross-cutting concern referenced by all
                 * clinical pathways. Modelled separately to define once,
                 * reference everywhere. */

            use case def ObtainInformedConsent {
                doc /* Obtain and record informed consent for a specific
                     * treatment or intervention. Includes capacity
                     * assessment where indicated. */
            }

            use case def WithdrawConsent {
                doc /* Process a patient's withdrawal of consent, including
                     * downstream effects on active pathways. */
            }

            use case def AssessCapacity {
                doc /* Formal capacity assessment where there is doubt
                     * about a patient's ability to consent. */
            }
        }

        package CoachingSupport {
            private import ScalarValues::*;

            doc /* Transition coaching services, group work, peer support
                 * programmes. Non-clinical but clinically adjacent support
                 * services integrated with the patient journey. */

            use case def ProvideTransitionCoaching {
                doc /* One-to-one coaching support for patients navigating
                     * gender transition. */
            }

            use case def FacilitateGroupWork {
                doc /* Facilitated group sessions: peer support, psycho-
                     * education, shared experience. */
            }
        }

        package ClinicalGovernance {
            private import ScalarValues::*;

            doc /* Policies, protocols, procedures, clinical audit, outcome
                 * tracking, significant event analysis.
                 *
                 * Governance is a first-class architectural concern, not a
                 * reporting add-on. Audit, compliance, and clinical governance
                 * capabilities are considered at design time for every pathway
                 * and data structure. */

            use case def ConductClinicalAudit {
                doc /* Population-level clinical audit: does every patient have
                     * required measurements recorded? Are monitoring schedules
                     * being followed? Are outcomes within expected ranges? */
            }

            use case def AnalyseSignificantEvent {
                doc /* Structured significant event analysis following an
                     * adverse event, near-miss, or complaint. */
            }

            use case def ReviewClinicalProtocol {
                doc /* Periodic review and update of clinical protocols and
                     * guidelines. Feeds into LearningCycles. */
            }
        }

        package ClinicalEntities {
            private import ScalarValues::*;

            doc /* Core domain entities: the nouns of the clinical domain.
                 * Each has a lifecycle state machine. Pathways are the verbs.
                 *
                 * Separated from pathways so that (e.g.) the Patient lifecycle
                 * is defined once and referenced from every pathway, rather
                 * than being redefined inside each pathway. */

            part def Patient {
                doc /* A patient registered with GenderSense. */
                attribute nhsNumber : String;
                attribute familyName : String;
                attribute givenName : String;
                attribute dateOfBirth : String;
            }

            part def Episode {
                doc /* A bounded episode of care with a defined start, end,
                     * and clinical context. A patient may have multiple
                     * concurrent or sequential episodes. */
                attribute episodeId : String;
                ref patient : Patient;
            }

            part def Consultation {
                doc /* A single clinical consultation (face-to-face, video,
                     * telephone, or asynchronous). */
                attribute consultationId : String;
                attribute consultationType : String;
                ref episode : Episode;
            }

            part def Prescription {
                doc /* A medication prescription. */
                attribute prescriptionId : String;
                attribute medicationName : String;
                attribute dose : String;
                ref patient : Patient;
            }

            part def Referral {
                doc /* A referral to or from an external service. */
                attribute referralId : String;
                attribute direction : String;
                attribute destination : String;
                ref patient : Patient;
            }

            part def LabResult {
                doc /* A laboratory test result. */
                attribute resultId : String;
                attribute testName : String;
                attribute value : String;
                attribute units : String;
                ref patient : Patient;
            }
        }
    }

    // =========================================================================
    // PLATFORM — Technology systems supporting service delivery
    // =========================================================================

    package Platform {
        private import ScalarValues::*;

        doc /* The technology systems that support service delivery. Each
             * subsystem is modelled as a part definition with ports defining
             * its interfaces. Build-vs-buy decisions are independent of the
             * model; the model captures what each subsystem does and how it
             * connects.
             *
             * Middle ring: modelled for structural clarity and interface
             * generation, with varying degrees of code generation. */

        package PatientPortal {
            private import ScalarValues::*;

            doc /* Web platform, secure patient access, self-service dashboard.
                 * Patients see: next appointment, latest results, triggered
                 * self-assessments, message threads, personalised guidance.
                 * Aggregates from CDR, Temporal, Booking, Messaging. */

            use case def ViewPatientDashboard {
                doc /* Patient views their personalised dashboard with
                     * upcoming appointments, recent results, and
                     * pending actions. */
            }

            use case def CompleteSelfServiceTask {
                doc /* Patient completes a self-service task: form, consent,
                     * payment, questionnaire, booking change. */
            }
        }

        package Booking {
            private import ScalarValues::*;

            doc /* Appointment scheduling, availability management, reminders,
                 * cancellation handling. External service consumed via
                 * Temporal activity wrappers. */

            use case def BookAppointment {
                doc /* Schedule an appointment: check availability, confirm
                     * with patient, send reminders. */
            }

            use case def CancelAppointment {
                doc /* Process an appointment cancellation from patient or
                     * clinician, including downstream pathway effects. */
            }
        }

        package EHR {
            private import ScalarValues::*;

            doc /* Clinical record layer: openEHR CDR (EHRbase).
                 * Demographics, clinical compositions, document storage.
                 * AQL queries for entity views. Archetype and template
                 * management.
                 *
                 * Two data paths: workflow-driven (Temporal activities commit
                 * compositions) and form-driven (direct entry outside
                 * workflows). Both produce the same structured, queryable,
                 * semantically typed data. */

            use case def CommitComposition {
                doc /* Store a clinical composition in the CDR conforming to
                     * a defined template built from archetypes. */
            }

            use case def QueryByArchetype {
                doc /* Retrieve clinical data via AQL query filtered by
                     * archetype type (e.g. all blood results, all
                     * consultations). Entity view pattern. */
            }

            use case def ManageArchetypes {
                doc /* Design, version, and deploy archetypes and templates
                     * using Archetype Designer. */
            }
        }

        package Forms {
            private import ScalarValues::*;

            doc /* Questionnaires, clinical assessment forms, validation rules,
                 * conditional logic, data mappings to CDR compositions.
                 *
                 * Forms are a major surface area for clinical data capture
                 * and a natural candidate for model-driven generation. */

            use case def RenderClinicalForm {
                doc /* Present a clinical form to a clinician or patient with
                     * validation, conditional logic, and CDR mapping. */
            }

            use case def SubmitFormData {
                doc /* Validate and submit form data, mapping to an openEHR
                     * composition for CDR storage. */
            }
        }

        package Messaging {
            private import ScalarValues::*;

            doc /* Patient communications, secure messaging, notifications,
                 * email, SMS. Consumed as external services via Temporal
                 * activity wrappers. */

            use case def SendNotification {
                doc /* Send a notification to a patient or clinician via
                     * the appropriate channel (email, SMS, in-app). */
            }

            use case def ConductSecureMessaging {
                doc /* Secure asynchronous messaging between patient and
                     * clinical team. */
            }
        }

        package VideoConsulting {
            private import ScalarValues::*;

            doc /* Telehealth platform integration, session management.
                 * External service consumed via Temporal activity wrappers. */

            use case def HostVideoConsultation {
                doc /* Set up and manage a video consultation session between
                     * patient and clinician. */
            }
        }

        package LabInterface {
            private import ScalarValues::*;

            doc /* Laboratory orders, results receipt, pathology integration,
                 * SNOMED-coded results. External service integration.
                 *
                 * Results flow into CDR as compositions; pathway activities
                 * may wait on lab results via Temporal signals. */

            use case def OrderLabTests {
                doc /* Submit a lab order for a patient: test panel selection,
                     * patient details, clinical context. */
            }

            use case def ReceiveLabResults {
                doc /* Receive and process inbound lab results, commit to
                     * CDR, and signal waiting pathways. */
            }
        }

        package PrescribingSystem {
            private import ScalarValues::*;

            doc /* Electronic prescribing system integration, medication
                 * databases, interaction checking. Distinct from the
                 * ServiceDelivery::ClinicalPathways::Prescribing package
                 * which models the clinical process; this package models
                 * the platform integration. */

            use case def IssuePrescription {
                doc /* Transmit a prescription to a dispensing pharmacy via
                     * electronic prescribing integration. */
            }

            use case def CheckInteractions {
                doc /* Screen a proposed prescription against the patient's
                     * current medications for interactions and
                     * contraindications. */
            }
        }

        package Payments {
            private import ScalarValues::*;

            doc /* Payment processing, invoicing, receipts, subscription
                 * management. PCI-scoped. External service integration. */

            use case def ProcessPayment {
                doc /* Take a payment from a patient for a service, issuing
                     * a receipt. */
            }

            use case def ManageSubscription {
                doc /* Manage recurring payment subscriptions for ongoing
                     * service packages. */
            }
        }

        package Documents {
            private import ScalarValues::*;

            doc /* Document generation, templates, electronic signing,
                 * document storage. Covers clinical letters, referral
                 * letters, consent forms, reports. */

            use case def GenerateDocument {
                doc /* Generate a document from a template populated with
                     * clinical and administrative data. */
            }

            use case def ObtainElectronicSignature {
                doc /* Obtain an electronic signature on a document (e.g.
                     * consent form, shared care agreement). */
            }
        }

        package Identity {
            private import ScalarValues::*;

            doc /* User accounts, authentication, authorisation, role-based
                 * access control. Security follows the principle that each
                 * service enforces its own access rules; this package
                 * provides the shared identity layer. */

            part def UserAccount {
                doc /* A user account for authentication and authorisation. */
                attribute accountId : String;
                attribute email : String;
                attribute accountType : String;
            }

            use case def AuthenticateUser {
                doc /* Authenticate a user and establish a session. */
            }

            use case def AuthoriseAccess {
                doc /* Determine whether an authenticated user is authorised
                     * to access a specific resource or perform an action. */
            }
        }

        package Orchestration {
            private import ScalarValues::*;

            doc /* Temporal infrastructure, workflow engine, worker deployment,
                 * workflow versioning. This is the execution engine that
                 * consumes generated workflows from the SysML model.
                 *
                 * Architecture validated in the coffee shop demonstrator:
                 * Temporal for durable process execution, XState for entity
                 * lifecycle enforcement within Temporal's V8 isolate. */
        }

        package Integration {
            private import ScalarValues::*;

            doc /* API gateway, third-party connectors, webhook management,
                 * event routing. Each external service is consumed via a
                 * Temporal activity whose implementation is a thin wrapper
                 * around an API call.
                 *
                 * The SysML model defines where in the pathway the
                 * integration occurs and what data flows to and from it.
                 * The workflow orchestrates the sequence; Temporal handles
                 * durability and recovery. */
        }
    }

    // =========================================================================
    // OPERATIONS — Back office and growth functions
    // =========================================================================

    package Operations {
        private import ScalarValues::*;

        doc /* Back office and growth functions. Modelled at the lightest level:
             * enough structure to show data flows between operations and
             * clinical service delivery, but not attempting to model the
             * internal workings of accounting or newsletter production.
             * Outer ring. */

        package Finance {
            private import ScalarValues::*;

            doc /* Billing, accounts, Xero integration, financial reporting,
                 * payroll interfaces. */

            use case def ProcessInvoice {
                doc /* Generate, issue, and track an invoice. Integrates
                     * with Xero for accounting. */
            }

            use case def ReconcilePayments {
                doc /* Reconcile payments received against invoices issued. */
            }
        }

        package People {
            private import ScalarValues::*;

            doc /* HR, contracts, indemnity arrangements, personnel
                 * management. */
        }

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
                     * through to registration. */
            }
        }

        package CRM {
            private import ScalarValues::*;

            doc /* Prospect and patient relationship management,
                 * communication preferences, segmentation. */
        }

        package Reporting {
            private import ScalarValues::*;

            doc /* Business intelligence, operational dashboards, regulatory
                 * reporting, KPI tracking.
                 *
                 * If every process, decision, state transition, and constraint
                 * evaluation is modelled and tracked, then operational
                 * questions are queries over existing event history rather
                 * than separate analytics pipelines. */

            use case def GenerateOperationalDashboard {
                doc /* Produce operational dashboard: referral-to-appointment
                     * times, pathway bottlenecks, capacity utilisation. */
            }

            use case def ProduceRegulatoryReport {
                doc /* Generate regulatory reports for CQC, NHS England, or
                     * other bodies from system data. */
            }
        }
    }

    // =========================================================================
    // FOUNDATION — Cross-cutting infrastructure imported by everything else
    // =========================================================================

    package Foundation {
        private import ScalarValues::*;

        doc /* Cross-cutting infrastructure that everything else imports.
             * The shared vocabulary of the entire model. */

        package MetadataLibrary {
            private import ScalarValues::*;

            doc /* Metadata definitions for generator configuration and
                 * cross-cutting annotations.
                 *
                 * Validated in demonstrator: @TemporalWorkflow,
                 * @TemporalActivity, @TemporalSignal, @StateTransitionTrigger.
                 *
                 * Clinical extensions (to be verified):
                 * @ClinicalReviewGate, @ConsentRequired, @AuditPoint,
                 * @LogicRule, @DecisionTable, @SafetyConstraint.
                 *
                 * NOTE: The existing TemporalMetadata package in the shared
                 * metadata library (sysml-metadata-lib/) is the current
                 * verified implementation. Clinical metadata defs will be
                 * added here as they are verified in Syside. */

            // Demonstrator-validated metadata defs are in the shared library.
            // Clinical extensions will be defined here as pathways are modelled.

            metadata def ClinicalReviewGate {
                doc /* Marks a pathway step as requiring clinical review
                     * before proceeding. Generates a human-task wait point
                     * in the orchestration layer. */
                attribute reviewerRole : String;
                attribute reviewCriteria : String;
            }

            metadata def ConsentRequired {
                doc /* Marks a pathway step as requiring patient consent
                     * before proceeding. */
                attribute consentType : String;
            }

            metadata def AuditPoint {
                doc /* Marks a step that must produce a governance audit
                     * record. */
                attribute auditCategory : String;
            }

            metadata def LogicRule {
                doc /* Marks an element as containing or referencing a
                     * deterministic logic rule for Tier 1 evaluation. */
                attribute ruleName : String;
            }

            metadata def DecisionTable {
                doc /* Marks an element as containing or referencing a
                     * DMN-style decision table for Tier 2 evaluation. */
                attribute tableName : String;
            }

            metadata def SafetyConstraint {
                doc /* Marks a constraint as safety-critical: must be
                     * evaluated and must not be overridden. */
                attribute constraintName : String;
                attribute severity : String;
            }
        }

        package CommonTypes {
            private import ScalarValues::*;

            doc /* Shared data types, enumerations, units of measure, and
                 * value types used across the model. */

            enum def Gender {
                doc /* Gender identity as recorded for clinical purposes. */
                male;
                female;
                nonBinary;
                other;
                notStated;
            }

            enum def ContactMethod {
                doc /* Preferred method of contact. */
                email;
                phone;
                sms;
                secureMessage;
                post;
            }

            enum def AppointmentType {
                doc /* Type of clinical appointment. */
                faceToFace;
                video;
                telephone;
                asynchronous;
            }

            enum def ReferralDirection {
                doc /* Direction of a referral. */
                inbound;
                outbound;
            }

            enum def ConsentStatus {
                doc /* Status of a consent record. */
                given;
                withdrawn;
                notYetObtained;
                declined;
            }

            part def Address {
                doc /* A postal address. */
                attribute line1 : String;
                attribute line2 : String;
                attribute city : String;
                attribute postcode : String;
                attribute country : String;
            }

            part def ContactDetails {
                doc /* Contact information for a person or organisation. */
                attribute email : String;
                attribute phone : String;
                attribute preferredMethod : ContactMethod;
            }
        }

        package StatePatterns {
            private import ScalarValues::*;

            doc /* Reusable lifecycle state machine patterns. Many entities
                 * share similar lifecycle shapes (e.g. created -> active ->
                 * suspended -> completed -> cancelled). Define once here,
                 * specialise in ClinicalEntities and elsewhere.
                 *
                 * Pattern: define a generic state def, then specialise it
                 * for specific entity types with additional states or
                 * transitions as needed. */

            // Standard lifecycle events
            attribute def Activated;
            attribute def Suspended;
            attribute def Resumed;
            attribute def Completed;
            attribute def Cancelled;

            state def StandardLifecycle {
                doc /* A generic lifecycle pattern applicable to many entities.
                     * States: created, active, suspended, completed, cancelled.
                     * Specialise for entity-specific variations. */

                initial;
                state created;
                state active;
                state suspended;
                state completed;
                state cancelled;

                transition created_to_active
                    first created
                    accept Activated
                    then active;

                transition active_to_suspended
                    first active
                    accept Suspended
                    then suspended;

                transition suspended_to_active
                    first suspended
                    accept Resumed
                    then active;

                transition active_to_completed
                    first active
                    accept Completed
                    then completed;

                transition active_to_cancelled
                    first active
                    accept Cancelled
                    then cancelled;

                transition created_to_cancelled
                    first created
                    accept Cancelled
                    then cancelled;
            }
        }

        package GenerationPipeline {
            private import ScalarValues::*;

            doc /* Generator configurations, template definitions, generation
                 * conventions, output format specifications.
                 *
                 * Validated generators from demonstrator:
                 * - gen_typescript_types.py (SysML -> TypeScript interfaces)
                 * - gen_state_machines.py (SysML -> XState v5 machines)
                 * - gen_temporal_workflow.py (SysML -> Temporal workflows)
                 * - gen_mermaid_pathway.py (SysML -> Mermaid diagrams)
                 *
                 * Future: Syside Automator for semantic model access,
                 * replacing regex-based parsing. */
        }
    }
}
