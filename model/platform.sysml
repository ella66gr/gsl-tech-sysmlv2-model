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
