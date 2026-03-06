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
             * than being redefined inside each pathway.
             *
             * Entity lifecycles are defined as standalone state defs
             * within this package, with exhibit state on each part def.
             * Events are scoped to each lifecycle to keep naming clear. */

        // =================================================================
        // Patient
        // =================================================================

        part def Patient {
            doc /* A patient registered with GenderSense. */
            attribute nhsNumber : String;
            attribute familyName : String;
            attribute givenName : String;
            attribute dateOfBirth : String;
        }

        // Patient lifecycle deferred — registration and identity
        // management are cross-cutting concerns that span all pathways.
        // Will be elaborated when the PatientJourney top-level flow
        // is modelled.

        // =================================================================
        // Episode
        // =================================================================

        // Episode lifecycle events
        attribute def EpisodeOpened;
        attribute def EpisodeSuspended;
        attribute def EpisodeResumed;
        attribute def EpisodeCompleted;
        attribute def EpisodeCancelled;

        state def EpisodeLifecycle {
            doc /* Lifecycle of a bounded episode of care.
                 *
                 * created: episode record exists, not yet clinically active
                 * active: patient is actively receiving care in this episode
                 * suspended: episode paused (e.g. patient request, awaiting
                 *   external input, temporary clinical hold)
                 * completed: episode clinically concluded with defined outcome
                 * cancelled: episode terminated before clinical activity
                 *
                 * An episode may be suspended and resumed multiple times.
                 * Completed and cancelled are terminal states. */

            initial;
            state created;
            state active;
            state suspended;
            state completed;
            state cancelled;

            transition created_to_active
                first created
                accept EpisodeOpened
                then active;

            transition active_to_suspended
                first active
                accept EpisodeSuspended
                then suspended;

            transition suspended_to_active
                first suspended
                accept EpisodeResumed
                then active;

            transition active_to_completed
                first active
                accept EpisodeCompleted
                then completed;

            transition active_to_cancelled
                first active
                accept EpisodeCancelled
                then cancelled;

            transition created_to_cancelled
                first created
                accept EpisodeCancelled
                then cancelled;
        }

        part def Episode {
            doc /* A bounded episode of care with a defined start, end,
                 * and clinical context. A patient may have multiple
                 * concurrent or sequential episodes. */
            attribute episodeId : String;
            attribute episodeType : String;
            ref patient : Patient;

            exhibit state episodeLifecycle : EpisodeLifecycle;
        }

        // =================================================================
        // Consultation
        // =================================================================

        part def Consultation {
            doc /* A single clinical consultation (face-to-face, video,
                 * telephone, or asynchronous). */
            attribute consultationId : String;
            attribute consultationType : String;
            ref episode : Episode;
        }

        // Consultation lifecycle deferred — relatively simple (scheduled,
        // in-progress, completed, cancelled, did-not-attend). Will be
        // elaborated when booking and appointment management are modelled.

        // =================================================================
        // Prescription
        // =================================================================

        // Prescription lifecycle events
        attribute def PrescriptionAuthorised;
        attribute def PrescriptionDispensed;
        attribute def PrescriptionStarted;
        attribute def PrescriptionAdjusted;
        attribute def PrescriptionCompleted;
        attribute def PrescriptionCancelled;

        state def PrescriptionLifecycle {
            doc /* Lifecycle of a medication prescription.
                 *
                 * drafted: prescription created but not yet clinically
                 *   authorised (safety checks, interaction screening
                 *   pending)
                 * authorised: clinician has signed off; prescription is
                 *   valid and can be dispensed
                 * dispensed: pharmacy has dispensed the medication to
                 *   the patient
                 * active: patient is taking the medication as prescribed
                 * completed: course finished, superseded by new
                 *   prescription, or intentionally stopped
                 * cancelled: prescription voided before dispensing
                 *
                 * Dose adjustments result in the current prescription
                 * being completed and a new prescription being created.
                 * This keeps each prescription as an immutable record
                 * of what was prescribed, at what dose, for what period. */

            initial;
            state drafted;
            state authorised;
            state dispensed;
            state active;
            state completed;
            state cancelled;

            transition drafted_to_authorised
                first drafted
                accept PrescriptionAuthorised
                then authorised;

            transition authorised_to_dispensed
                first authorised
                accept PrescriptionDispensed
                then dispensed;

            transition dispensed_to_active
                first dispensed
                accept PrescriptionStarted
                then active;

            transition active_to_completed
                first active
                accept PrescriptionCompleted
                then completed;

            transition authorised_to_completed
                first authorised
                accept PrescriptionCompleted
                then completed;

            transition drafted_to_cancelled
                first drafted
                accept PrescriptionCancelled
                then cancelled;

            transition authorised_to_cancelled
                first authorised
                accept PrescriptionCancelled
                then cancelled;
        }

        part def Prescription {
            doc /* A medication prescription. Each prescription represents
                 * a single authorised medication at a specific dose. Dose
                 * adjustments create a new prescription; the previous one
                 * is completed. */
            attribute prescriptionId : String;
            attribute medicationName : String;
            attribute dose : String;
            attribute route : String;
            ref patient : Patient;
            ref episode : Episode;

            exhibit state prescriptionLifecycle : PrescriptionLifecycle;
        }

        // =================================================================
        // Lab Result
        // =================================================================

        // Lab result lifecycle events
        attribute def SampleCollected;
        attribute def ResultReceived;
        attribute def ResultReviewed;
        attribute def ResultActioned;
        attribute def LabOrderCancelled;

        state def LabResultLifecycle {
            doc /* Lifecycle of a laboratory test from order to clinical
                 * action.
                 *
                 * requested: lab test requested but sample not yet taken
                 * collected: sample obtained (phlebotomy or patient
                 *   self-collection)
                 * resulted: laboratory has returned values; results
                 *   available in CDR
                 * reviewed: clinician has reviewed the results and
                 *   recorded their clinical interpretation
                 * actioned: a clinical decision has been made based on
                 *   the results (e.g. dose adjustment, onward referral,
                 *   continue current regimen)
                 * cancelled: order cancelled before sample collection
                 *
                 * This is a predominantly linear lifecycle. The key
                 * governance distinction is between resulted (data
                 * available) and reviewed (clinician has seen it) —
                 * the pathway must not proceed past a review gate
                 * until results are in the reviewed state. */

            initial;
            state requested;
            state collected;
            state resulted;
            state reviewed;
            state actioned;
            state cancelled;

            transition requested_to_collected
                first requested
                accept SampleCollected
                then collected;

            transition collected_to_resulted
                first collected
                accept ResultReceived
                then resulted;

            transition resulted_to_reviewed
                first resulted
                accept ResultReviewed
                then reviewed;

            transition reviewed_to_actioned
                first reviewed
                accept ResultActioned
                then actioned;

            transition requested_to_cancelled
                first requested
                accept LabOrderCancelled
                then cancelled;

            transition collected_to_cancelled
                first collected
                accept LabOrderCancelled
                then cancelled;
        }

        part def LabResult {
            doc /* A laboratory test result, tracking the full lifecycle
                 * from order through collection, reporting, clinical
                 * review, and action. */
            attribute resultId : String;
            attribute testName : String;
            attribute value : String;
            attribute units : String;
            attribute referenceRange : String;
            ref patient : Patient;
            ref episode : Episode;

            exhibit state labResultLifecycle : LabResultLifecycle;
        }

        // =================================================================
        // Referral
        // =================================================================

        // Referral lifecycle events
        attribute def ReferralSent;
        attribute def ReferralAcknowledged;
        attribute def ReferralAccepted;
        attribute def ReferralDeclined;
        attribute def ReferralCompleted;
        attribute def ReferralCancelled;

        state def ReferralLifecycle {
            doc /* Lifecycle of a referral to or from an external service.
                 *
                 * drafted: referral prepared but not yet sent
                 * sent: referral transmitted to receiving service
                 * acknowledged: receiving service confirms receipt
                 * referralAccepted: receiving service will act on the referral
                 * declined: receiving service has declined the referral
                 *   (e.g. not meeting criteria, capacity, geography)
                 * completed: referral purpose fulfilled (patient seen,
                 *   shared care established, etc.)
                 * cancelled: referral withdrawn before acceptance
                 *
                 * Declined is a terminal state from the referral's
                 * perspective; the pathway may choose to re-refer
                 * elsewhere, which creates a new Referral entity. */

            initial;
            state drafted;
            state sent;
            state acknowledged;
            state referralAccepted;
            state declined;
            state completed;
            state cancelled;

            transition drafted_to_sent
                first drafted
                accept ReferralSent
                then sent;

            transition sent_to_acknowledged
                first sent
                accept ReferralAcknowledged
                then acknowledged;

            transition acknowledged_to_referralAccepted
                first acknowledged
                accept ReferralAccepted
                then referralAccepted;

            transition acknowledged_to_declined
                first acknowledged
                accept ReferralDeclined
                then declined;

            transition referralAccepted_to_completed
                first referralAccepted
                accept ReferralCompleted
                then completed;

            transition drafted_to_cancelled
                first drafted
                accept ReferralCancelled
                then cancelled;

            transition sent_to_cancelled
                first sent
                accept ReferralCancelled
                then cancelled;

            transition acknowledged_to_cancelled
                first acknowledged
                accept ReferralCancelled
                then cancelled;
        }

        part def Referral {
            doc /* A referral to or from an external service. Each referral
                 * is a distinct entity with its own lifecycle. If a referral
                 * is declined, a new Referral is created for any re-referral
                 * rather than reusing the declined one. */
            attribute referralId : String;
            attribute direction : String;
            attribute destination : String;
            attribute reason : String;
            ref patient : Patient;
            ref episode : Episode;

            exhibit state referralLifecycle : ReferralLifecycle;
        }
    }
}
