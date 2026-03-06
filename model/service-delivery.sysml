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
