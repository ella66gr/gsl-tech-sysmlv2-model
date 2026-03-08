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
         * generation, with varying degrees of code generation.
         *
         * Updated 8 March 2026: PatientPortal sub-packages, Education,
         * and Community added to align model with package hierarchy
         * proposal. These are patient-facing platform capabilities. */

    package PatientPortal {
        private import ScalarValues::*;

        doc /* Patient-facing web platform, self-management hub.
             * Patients see: next appointment, latest results, triggered
             * self-assessments, message threads, personalised guidance.
             * Aggregates from CDR, Temporal, Booking, Messaging.
             *
             * Sub-packages represent distinct functional areas of the
             * patient experience, each with its own data, privacy, and
             * interaction patterns. */

        use case def ViewPatientDashboard {
            doc /* Patient views their personalised dashboard with
                 * upcoming appointments, recent results, and
                 * pending actions. */
        }

        use case def CompleteSelfServiceTask {
            doc /* Patient completes a self-service task: form, consent,
                 * payment, questionnaire, booking change. */
        }

        package SelfManagement {
            private import ScalarValues::*;

            doc /* Personal dashboard, progress tracking, alerts and
                 * notifications, access to individual clinical records
                 * including blood results, self-assessment tools,
                 * decision aids, progress sharing.
                 *
                 * This is the patient's primary interface with their
                 * own clinical data. Consumes CDR entity views (blood
                 * results, prescriptions, consultations) and Temporal
                 * workflow state (pathway progress, pending actions).
                 * The same rules that drive clinician alerts drive
                 * patient-facing guidance here — single source of
                 * truth via Knowledge layer evaluation results. */

            use case def ViewClinicalRecord {
                doc /* Patient views their own clinical data: blood
                     * results, prescriptions, consultation summaries.
                     * Data sourced from CDR entity views. */
            }

            use case def TrackProgress {
                doc /* Patient tracks their progress through a pathway
                     * or towards clinical targets. Combines CDR data
                     * with pathway state from Temporal. */
            }

            use case def CompleteSelfAssessment {
                doc /* Patient completes a triggered or scheduled self-
                     * assessment instrument. Results committed to CDR
                     * and may signal a waiting pathway. */
            }
        }

        package IdentityAndAvatar {
            private import ScalarValues::*;

            doc /* Personal evolving avatar: self-representation, identity
                 * exploration, gender expression, presentation preferences,
                 * aptitudes, values, concerns and vulnerabilities.
                 *
                 * Versioned history — earlier selves are meaningful, not
                 * obsolete. The patient's identity record evolves over
                 * time and previous versions are preserved as part of the
                 * narrative of their journey.
                 *
                 * Selective sharing controls: clinician, peer group,
                 * private. The patient controls which aspects of their
                 * identity representation are visible to which audiences.
                 *
                 * Connects to: Journal (reflective identity work),
                 * Community (presentation in group spaces),
                 * Education::TherapyPathways (guided identity exercises),
                 * SelfManagement (milestone integration),
                 * Knowledge::OutcomeFramework (progress as lived
                 * experience, not just clinical measures).
                 *
                 * This is NOT gamification. It is externalised identity
                 * work with therapeutic value: articulation, development,
                 * confidence-building, sense of agency and control.
                 * The distinction matters — this is a clinical tool for
                 * self-understanding, not a reward mechanism. */

            use case def EditIdentityProfile {
                doc /* Patient creates or updates their identity
                     * representation — gender expression, presentation
                     * preferences, values, concerns, aspirations. */
            }

            use case def ReviewIdentityHistory {
                doc /* Patient reviews the versioned history of their
                     * identity profile, reflecting on their journey
                     * and development over time. */
            }

            use case def ManageSharingControls {
                doc /* Patient configures which aspects of their identity
                     * profile are visible to clinicians, peer groups,
                     * or kept private. */
            }
        }

        package Journal {
            private import ScalarValues::*;

            doc /* Personal journal for reflective practice. Entries may
                 * be private, shared with the clinical team, or shared
                 * with specific peer groups. Supports free text, prompted
                 * reflections (linked to therapy pathway exercises), and
                 * structured entries.
                 *
                 * Clinician-shared entries become part of the clinical
                 * record (committed to CDR). Private entries remain
                 * outside the CDR and are not accessible to clinicians
                 * — the patient controls this boundary. */

            use case def WriteJournalEntry {
                doc /* Patient writes a journal entry — free text,
                     * prompted reflection, or structured format.
                     * Chooses sharing level: private, clinician,
                     * or peer group. */
            }

            use case def ReviewJournalHistory {
                doc /* Patient reviews their journal entries over time,
                     * with filtering by date, sharing level, or
                     * linked therapy exercise. */
            }
        }

        package SessionPlanning {
            private import ScalarValues::*;

            doc /* Consultation session sequence planning, appointment
                 * preparation, agenda setting, post-session actions.
                 *
                 * Helps patients prepare for clinical consultations
                 * (what to raise, questions to ask, information to
                 * bring) and captures post-session actions and
                 * reflections. Bridges the gap between clinical
                 * encounters. */

            use case def PrepareForSession {
                doc /* Patient prepares for an upcoming consultation:
                     * sets agenda items, notes questions, reviews
                     * relevant clinical data. */
            }

            use case def RecordPostSessionActions {
                doc /* Patient records their understanding of what was
                     * discussed and agreed, and any actions they need
                     * to take before the next session. */
            }
        }

        package DocumentAccess {
            private import ScalarValues::*;

            doc /* Secure document portal for patient access to their
                 * documents: clinical letters, referral letters, consent
                 * forms, shared care protocols, reports.
                 *
                 * Includes e-signing for consent and contracts, and
                 * controlled document sharing with clinicians and
                 * third parties (e.g. employers, other healthcare
                 * providers — always patient-initiated). */

            use case def ViewDocuments {
                doc /* Patient views documents associated with their
                     * care: letters, reports, consent records. */
            }

            use case def SignDocument {
                doc /* Patient electronically signs a document — consent
                     * form, shared care agreement, or similar. */
            }

            use case def ShareDocument {
                doc /* Patient shares a document with a third party
                     * (GP, employer, other provider). Patient-initiated,
                     * patient-controlled. */
            }
        }
    }

    package Education {
        private import ScalarValues::*;

        doc /* Patient-facing knowledge and learning platform. Provides
             * structured educational content, self-directed learning,
             * and guided therapeutic exercises.
             *
             * Distinct from clinical pathway activities (which are
             * clinician-directed) — this is patient-directed learning
             * and development that complements clinical care.
             *
             * Content delivery is personalised based on pathway stage,
             * clinical context, and patient preferences. The same
             * Knowledge layer that drives clinical decision support
             * informs content recommendations. */

        package KnowledgeBase {
            private import ScalarValues::*;

            doc /* FAQs, reference materials, answerbase, curated
                 * information, decision aids, terminology guides.
                 *
                 * Static or slowly-changing reference content that
                 * patients can access at any time. Curated by the
                 * clinical team. Structured for searchability and
                 * cross-referencing. */

            use case def SearchKnowledgeBase {
                doc /* Patient searches for information on a topic —
                     * medication, procedure, terminology, rights,
                     * practical guidance. */
            }

            use case def ViewDecisionAid {
                doc /* Patient accesses a structured decision aid to
                     * help them understand options and make informed
                     * choices about their care. */
            }
        }

        package LearningContent {
            private import ScalarValues::*;

            doc /* Structured courses, self-directed learning modules,
                 * instructional video and audio, educational pathways.
                 *
                 * Longer-form educational content with defined learning
                 * objectives and sequenced delivery. May include
                 * assessments or reflective exercises. */

            use case def FollowLearningModule {
                doc /* Patient works through a structured learning module
                     * at their own pace — video, reading, exercises,
                     * self-check questions. */
            }
        }

        package TherapyPathways {
            private import ScalarValues::*;

            doc /* Structured therapy journeys, guided self-development,
                 * coaching exercises, psychoeducation sequences.
                 *
                 * These are not clinical pathways in the ServiceDelivery
                 * sense — they are patient-directed therapeutic exercises
                 * that support identity development, emotional wellbeing,
                 * and transition readiness. They may be recommended by
                 * clinicians or coaches but are completed by the patient
                 * independently.
                 *
                 * Connects to: IdentityAndAvatar (identity exercises
                 * feed into the evolving identity profile), Journal
                 * (reflective exercises may produce journal entries),
                 * CoachingSupport (coaches may facilitate or review
                 * therapy pathway progress). */

            use case def FollowTherapyExercise {
                doc /* Patient works through a guided therapeutic exercise
                     * — identity exploration, values clarification,
                     * confidence building, social skills practice. */
            }

            use case def ReviewTherapyProgress {
                doc /* Patient reviews their progress through a therapy
                     * pathway, with summaries of completed exercises
                     * and insights captured. */
            }
        }

        package ContentDelivery {
            private import ScalarValues::*;

            doc /* Content management, personalised recommendations,
                 * progress-aware delivery, accessibility.
                 *
                 * The infrastructure behind Education: how content is
                 * stored, tagged, recommended, and delivered. Includes
                 * accessibility considerations (screen reader support,
                 * alternative formats, language/reading level). Content
                 * recommendations are informed by the patient's pathway
                 * stage and clinical context via the Knowledge layer. */

            use case def RecommendContent {
                doc /* System recommends educational content to a patient
                     * based on their pathway stage, recent clinical
                     * events, and learning history. */
            }

            use case def ManageContent {
                doc /* Clinical or editorial team creates, updates, tags,
                     * and publishes educational content. */
            }
        }
    }

    package Community {
        private import ScalarValues::*;

        doc /* Patient-to-patient and group interaction platform.
             * Provides spaces for peer support, shared experience,
             * and facilitated group work.
             *
             * Distinct from clinical messaging (which is in Messaging)
             * — this is peer-to-peer and group interaction with
             * appropriate moderation and safeguarding. Privacy controls
             * are essential: patients choose what they share in
             * community spaces, and community activity is not part of
             * the clinical record unless explicitly shared by the
             * patient. */

        package GroupSpaces {
            private import ScalarValues::*;

            doc /* Group spaces with privacy controls, shared resources,
                 * moderation, community guidelines enforcement.
                 *
                 * Spaces may be topic-based (e.g. hormone therapy
                 * experiences, workplace transition), stage-based
                 * (e.g. early in journey, post-surgery), or open.
                 * Each space has its own moderation settings and
                 * membership criteria. */

            use case def ParticipateInGroupSpace {
                doc /* Patient joins and participates in a community
                     * group space — posting, reading, responding,
                     * sharing resources. */
            }

            use case def ModerateGroupSpace {
                doc /* Moderator manages a group space: reviewing flagged
                     * content, enforcing community guidelines, managing
                     * membership. */
            }
        }

        package GroupSessions {
            private import ScalarValues::*;

            doc /* Group video sessions, facilitated workshops, peer
                 * support circles, scheduled group events.
                 *
                 * These are live, synchronous group interactions —
                 * distinct from the asynchronous group spaces. May be
                 * clinician-facilitated, coach-facilitated, or peer-led.
                 * Connects to VideoConsulting for the technical
                 * infrastructure and to CoachingSupport for facilitated
                 * sessions. */

            use case def HostGroupSession {
                doc /* Facilitate a live group session: peer support
                     * circle, workshop, or group therapy exercise.
                     * Scheduled, with invitations, reminders, and
                     * post-session follow-up. */
            }

            use case def JoinGroupSession {
                doc /* Patient joins a scheduled group session. */
            }
        }

        package PeerMessaging {
            private import ScalarValues::*;

            doc /* Patient-to-patient messaging, group chat, peer
                 * support channels.
                 *
                 * Distinct from clinical messaging (Messaging package):
                 * peer messages are between patients, not between
                 * patients and clinicians. Subject to community
                 * guidelines and moderation. Not part of the clinical
                 * record. Safeguarding monitoring applies. */

            use case def SendPeerMessage {
                doc /* Patient sends a message to another patient or
                     * to a peer support channel. */
            }
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
             *
             * The CDR is the persistent, semantically structured clinical
             * data layer. It stores compositions conforming to templates
             * built from archetypes. The CDR does not care how data
             * arrived — it validates against the template on commit.
             *
             * Two data paths, both producing the same structured,
             * queryable, semantically typed data:
             *   - Workflow-driven: Temporal activities commit compositions
             *     as part of pathway execution (validated Phase B)
             *   - Form-driven: direct entry outside workflows via
             *     SvelteKit endpoints (validated Phase C)
             *
             * Entity views query the CDR by archetype type (e.g. all
             * blood results, all consultations) regardless of which
             * pathway or form produced the data.
             *
             * Population-level governance queries compare CDR contents
             * against model-derived rules to identify data completeness
             * gaps (validated Phase D).
             *
             * Elaborated 8 March 2026 (CDR Exercise Phase E) with
             * structural elements informed by Phases A-D findings.
             * See also: Foundation::MetadataLibrary for @OpenEhrArchetype
             * and @OpenEhrTemplate metadata defs used to annotate
             * archetype-mapped part defs elsewhere in the model. */

        // -- CDR infrastructure ---------------------------------

        part def CdrConnection {
            doc /* Connection configuration for an openEHR CDR instance.
                 *
                 * Validated against EHRbase 2.11.0 (Docker).
                 * REST API base path: /ehrbase/rest/openehr/v1/
                 * Auth: basic auth for development; production TBD.
                 *
                 * The nodeName appears in composition UIDs as the
                 * second segment: {uuid}::{nodeName}::{version}.
                 * Must match SERVER_NODENAME in EHRbase config. */
            attribute baseUrl : String;
            attribute authType : String;     // basic | oauth2
            attribute nodeName : String;     // e.g. "gendersense.local"
        }

        part def EhrRecord {
            doc /* An openEHR Electronic Health Record for one patient.
                 *
                 * One EHR per patient, created at registration. The
                 * subjectId + subjectNamespace pair enables idempotent
                 * lookup via GET /ehr?subject_id=X&subject_namespace=Y.
                 * The getOrCreateEhr pattern (validated Phase B) makes
                 * EHR resolution safe to call from any activity.
                 *
                 * Namespace must match pattern [a-zA-Z][a-zA-Z0-9-_:/&+?]*
                 * — dots are NOT allowed (EHRbase validation, Phase B
                 * finding). Use hyphens as separators. */
            attribute ehrId : String;              // UUID assigned by CDR
            attribute subjectId : String;          // external patient ID
            attribute subjectNamespace : String;   // e.g. "gendersense-patient"
            attribute systemId : String;           // matches nodeName
        }

        part def RegisteredTemplate {
            doc /* An Operational Template (OPT) registered in the CDR.
                 *
                 * Templates compose archetypes into use-case-specific
                 * data sets. Each template defines one composition type.
                 * Uploaded via the Definition API (POST /definition/template/adl1.4).
                 *
                 * EHRbase rejects duplicate template_id uploads (HTTP 409).
                 * For development: database reset (docker compose down -v).
                 * For production: ehrbase.template.allow-overwrite=true.
                 *
                 * OPTs are exported from Archetype Designer (Firefox only —
                 * Chrome export hangs, Phase A finding). */
            attribute templateId : String;         // e.g. "coffeeshop-order-composition.v1"
            attribute archetypeIds : String;        // comma-separated archetype IDs in this template
        }

        part def Composition {
            doc /* A composition committed to the CDR.
                 *
                 * Compositions are the unit of clinical data committed
                 * and retrieved. Each conforms to a registered template.
                 * Canonical JSON format maps directly to the openEHR
                 * Reference Model hierarchy:
                 *   COMPOSITION > content > ENTRY > data/description > items
                 *
                 * Commit returns 204 with Prefer: return=minimal.
                 * UID in ETag header (quoted): "uid::nodeName::version".
                 *
                 * EHRbase validates DV_CODED_TEXT values against archetype
                 * term definitions — exact text match required (Phase A
                 * finding). Composition builders must derive display text
                 * from the template, not from developer input.
                 *
                 * Entry RM classes have different structures:
                 *   OBSERVATION: data (HISTORY > POINT_EVENT > ITEM_TREE)
                 *   EVALUATION: data (ITEM_TREE)
                 *   ACTION: description (ITEM_TREE) + time + ism_transition
                 * All three validated in CDR Exercise Phases A-D. */
            attribute compositionUid : String;     // uuid::nodeName::version
            attribute templateId : String;         // template this conforms to
            attribute ehrId : String;              // owning EHR
            attribute composerName : String;       // who committed
        }

        part def AqlQuery {
            doc /* A named AQL (Archetype Query Language) query.
                 *
                 * AQL queries the CDR by archetype type, providing
                 * entity views independent of the process that produced
                 * the data. Paths mirror the RM hierarchy using archetype
                 * node IDs (at-codes).
                 *
                 * EHRbase 2.11.0 limitations:
                 *   - COUNT / GROUP BY not supported (use application-
                 *     level aggregation, Phase C finding)
                 *   - NOT EXISTS subqueries not supported (use
                 *     application-level join, Phase D finding)
                 *
                 * Governance audit pattern (validated Phase D): two AQL
                 * queries (one per composition type), joined in
                 * application code by EHR ID, applying rules derived
                 * from the SysML model to identify gaps. */
            attribute queryName : String;          // human-readable name
            attribute aql : String;                // AQL query string
        }

        // -- Use cases ------------------------------------------

        use case def CommitComposition {
            doc /* Store a clinical composition in the CDR conforming to
                 * a registered template. The CDR validates the composition
                 * structure and coded terms against the template.
                 *
                 * Called from: Temporal activity implementations (workflow
                 * path) or SvelteKit server endpoints (form path). Both
                 * use the same EHRbase client module and canonical JSON
                 * composition format. */
        }

        use case def QueryByArchetype {
            doc /* Retrieve clinical data via AQL query filtered by
                 * archetype type. Entity view pattern: "show me all
                 * blood results for this patient" regardless of which
                 * pathway produced them.
                 *
                 * Results are returned as row sets. Application code
                 * maps result columns to typed objects for front-end
                 * rendering. */
        }

        use case def RunGovernanceAudit {
            doc /* Execute a population-level data completeness audit.
                 *
                 * Pattern: query CDR for expected compositions (e.g.
                 * all orders), query for matching compositions (e.g.
                 * all preparations), join by EHR ID in application
                 * code, identify gaps. Produces a governance report
                 * with summary statistics and per-patient detail.
                 *
                 * Can run as scheduled Temporal workflow (cron) or
                 * on-demand from a SvelteKit endpoint. Validated in
                 * CDR Exercise Phase D. */
        }

        use case def ManageArchetypes {
            doc /* Design, version, and deploy archetypes and templates.
                 *
                 * Workflow: design in Archetype Designer (web tool) →
                 * export OPT via Firefox → upload to EHRbase via
                 * Definition API. Term definitions edited in archetype,
                 * not template (two-level modelling principle).
                 *
                 * Archetype Designer traps:
                 *   - OPT export hangs in Chrome (use Firefox)
                 *   - Unassigned elements default to BOOLEAN
                 *   - Always explicitly set every element's data type */
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
