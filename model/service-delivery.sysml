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
            private import ServiceDelivery::ClinicalEntities::*;
            private import Foundation::MetadataLibrary::*;
            private import TemporalMetadata::*;

            doc /* Hormone therapy initiation, titration, monitoring,
                 * and shared care protocols. The recommended first
                 * clinical pathway to model end to end.
                 *
                 * Exercises: long-running waits (lab results, specialist
                 * referrals), multiple participants (patient, GP,
                 * endocrinologist, phlebotomy), governance requirements
                 * (consent, clinical review intervals, monitoring
                 * schedules), full two-layer action flow pattern.
                 *
                 * This package contains the domain-layer action flow
                 * (the clinical process as a clinician would describe
                 * it), the orchestration-layer action flow (Temporal
                 * execution model), and use case definitions. */

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

            // ==========================================================
            // Domain-layer action flow: Hormone Therapy Initiation
            //
            // This is the governance view — the clinical process as a
            // clinician or governance reviewer would understand it.
            // Action nodes represent clinical activities, not system
            // operations.
            //
            // Participants:
            //   - Patient
            //   - Prescribing clinician (GenderSense)
            //   - Phlebotomy service
            //   - Laboratory
            //   - Pharmacy
            //   - Patient's GP (for shared care)
            //
            // The pathway begins after assessment has concluded that
            // hormone therapy is appropriate. It ends when the patient
            // is on a stable regimen with monitoring in place.
            // ==========================================================

            action def InitiateHormoneTherapyProcess {
                doc /* Domain-layer action flow for hormone therapy
                     * initiation. Covers the full clinical process
                     * from eligibility confirmation through to
                     * established stable regimen and transition to
                     * ongoing monitoring or shared care.
                     *
                     * This is a long-running process. Typical duration
                     * is 6-12 months from initiation to stability,
                     * depending on clinical response and monitoring
                     * results. */

                in item patient : Patient;
                in item episode : Episode;

                // --- Phase 1: Eligibility, consent, and baseline ---

                action confirmEligibility {
                    doc /* Verify that the patient meets clinical
                         * eligibility criteria for hormone therapy.
                         * Criteria include completed assessment,
                         * treatment plan in place, no absolute
                         * contraindications, and capacity to consent.
                         *
                         * Evaluates: EligibilityCriteriaMetConstraint
                         * (to be defined in ConstraintLibrary). */
                    @LogicRule { ruleName = "hormoneEligibility"; }
                }
                then providePatientInformation;

                action providePatientInformation {
                    doc /* Provide the patient with comprehensive
                         * information about the proposed treatment:
                         * expected effects and timeline, potential
                         * risks and side effects, alternative options,
                         * monitoring requirements, and implications
                         * for fertility.
                         *
                         * Information provision must be documented in
                         * the clinical record before consent can be
                         * obtained.
                         *
                         * Satisfies: InformedConsentRequiresInformation */
                    @AuditPoint { auditCategory = "patient-information"; }
                }
                then obtainConsent;

                action obtainConsent {
                    doc /* Obtain informed consent for hormone therapy.
                         * Consent must be specific to the proposed
                         * treatment, documented in the clinical record,
                         * and include evidence of capacity.
                         *
                         * Prerequisite: providePatientInformation must
                         * have been completed.
                         *
                         * Satisfies: ConsentBeforeTreatment */
                    @ConsentRequired { consentType = "hormone-therapy-initiation"; }
                    @AuditPoint { auditCategory = "consent"; }
                }
                then orderBaselineBloods;

                action orderBaselineBloods {
                    doc /* Order baseline blood tests. The required panel
                         * includes: FBC, U&Es, LFTs, lipid profile,
                         * fasting glucose, prolactin, and baseline
                         * hormone levels (testosterone, oestradiol).
                         *
                         * Also record baseline observations: weight, BP.
                         *
                         * Creates LabResult entities in 'requested' state. */
                    @AuditPoint { auditCategory = "investigation-order"; }
                }
                then awaitBaselineResults;

                action awaitBaselineResults {
                    doc /* Wait for baseline blood test results to be
                         * returned by the laboratory. This is a long-
                         * running wait — typically 3-7 working days.
                         *
                         * LabResult entities transition through:
                         * requested -> collected -> resulted.
                         *
                         * The pathway does not proceed until all
                         * required tests have resulted. */
                }
                then reviewBaselineResults;

                action reviewBaselineResults {
                    doc /* Clinician reviews the baseline blood test
                         * results and records their clinical
                         * interpretation.
                         *
                         * LabResult entities transition:
                         * resulted -> reviewed.
                         *
                         * This is a clinical review gate — the pathway
                         * must not proceed to prescribing until a
                         * clinician has reviewed all baseline results.
                         *
                         * Satisfies: BaselineInvestigationsBeforePrescribing */
                    @ClinicalReviewGate {
                        reviewerRole = "prescribing-clinician";
                        reviewCriteria = "baseline-bloods-reviewed";
                    }
                }
                then selectRegimen;

                // --- Phase 2: Prescribing ---

                action selectRegimen {
                    doc /* Clinical decision: select the hormone therapy
                         * regimen. Decision factors include patient
                         * preference, clinical assessment, baseline
                         * blood results, contraindications, and the
                         * approved prescribing protocol.
                         *
                         * Determines: medication, route of
                         * administration, starting dose.
                         *
                         * Evaluates: RegimenWithinProtocolConstraint
                         * Satisfies: PrescribingProtocolAdherence */
                    @DecisionTable { tableName = "regimenSelection"; }
                    @ClinicalReviewGate {
                        reviewerRole = "prescribing-clinician";
                        reviewCriteria = "prescribing-decision";
                    }
                }
                then issuePrescription;

                action issuePrescription {
                    doc /* Issue the hormone therapy prescription.
                         * Includes drug interaction screening and
                         * safety constraint evaluation.
                         *
                         * Creates a Prescription entity in 'drafted'
                         * state, then transitions to 'authorised'
                         * upon clinician sign-off.
                         *
                         * Satisfies: ClinicalReviewBeforePrescribing */
                    @SafetyConstraint {
                        constraintName = "prescribing-safety-check";
                        severity = "critical";
                    }
                    @AuditPoint { auditCategory = "prescribing"; }
                }
                then dispenseMedication;

                action dispenseMedication {
                    doc /* Prescription is dispensed by pharmacy.
                         * Patient receives medication and written
                         * information about administration.
                         *
                         * Prescription entity transitions:
                         * authorised -> dispensed -> active
                         * (when patient begins taking medication). */
                }
                then scheduleMonitoringBloods;

                // --- Phase 3: Monitoring cycle ---
                //
                // The following steps (scheduleMonitoringBloods through
                // assessStabilityDecision) form a monitoring cycle that
                // repeats until the patient's regimen is stable.
                // Typical cycle: bloods at 3 months, clinical review,
                // dose adjustment if needed, repeat.

                action scheduleMonitoringBloods {
                    doc /* Schedule follow-up blood tests at the
                         * appropriate monitoring interval. Initial
                         * monitoring is typically at 3 months post-
                         * initiation, then at intervals determined by
                         * clinical response.
                         *
                         * Creates new LabResult entities in 'requested'
                         * state.
                         *
                         * Satisfies: BloodMonitoringRequired */
                    @AuditPoint { auditCategory = "monitoring-schedule"; }
                }
                then awaitMonitoringResults;

                action awaitMonitoringResults {
                    doc /* Wait for monitoring blood test results.
                         * Long-running wait — typically 3-7 working
                         * days for results, but the interval from
                         * scheduling to collection may be weeks.
                         *
                         * LabResult entities transition:
                         * requested -> collected -> resulted. */
                }
                then reviewMonitoringResults;

                action reviewMonitoringResults {
                    doc /* Clinician reviews monitoring blood results
                         * and records clinical interpretation.
                         * Assesses hormone levels against therapeutic
                         * target ranges, safety markers, and any
                         * concerning trends.
                         *
                         * LabResult entities transition:
                         * resulted -> reviewed -> actioned. */
                    @ClinicalReviewGate {
                        reviewerRole = "prescribing-clinician";
                        reviewCriteria = "monitoring-results-review";
                    }
                }
                then assessStabilityDecision;

                action assessStabilityDecision {
                    doc /* Clinical decision point: is the patient's
                         * regimen stable?
                         *
                         * Stable means: hormone levels within
                         * therapeutic range, no significant side
                         * effects, patient satisfied with progress,
                         * safety markers satisfactory.
                         *
                         * If stable -> proceed to transition to
                         *   ongoing care.
                         * If adjustment needed -> adjust dose and
                         *   repeat the monitoring cycle. */
                    @DecisionTable { tableName = "stabilityAssessment"; }
                }
                then adjustDose;
                then confirmStable;

                // --- Branch: dose adjustment (loops back) ---

                action adjustDose {
                    doc /* Adjust the hormone therapy dose based on
                         * monitoring results and clinical review.
                         *
                         * The current Prescription is completed and
                         * a new Prescription is created at the
                         * adjusted dose (immutable prescription
                         * records — see PrescriptionLifecycle).
                         *
                         * Satisfies: ClinicalReviewBeforeDoseAdjustment */
                    @ClinicalReviewGate {
                        reviewerRole = "prescribing-clinician";
                        reviewCriteria = "dose-adjustment-review";
                    }
                    @AuditPoint { auditCategory = "dose-adjustment"; }
                }
                then scheduleMonitoringBloods;

                // --- Branch: stable regimen ---

                action confirmStable {
                    doc /* Confirm that the hormone therapy regimen is
                         * stable. Record the stabilisation date, current
                         * regimen details, and established monitoring
                         * schedule in the clinical record.
                         *
                         * This marks the end of the initiation/titration
                         * phase and the beginning of ongoing maintenance. */
                    @AuditPoint { auditCategory = "regimen-stabilised"; }
                }
                then transitionToOngoingCare;

                // --- Phase 4: Transition ---

                action transitionToOngoingCare {
                    doc /* Establish the ongoing care arrangement.
                         * This may be:
                         *
                         * 1. Continued monitoring by GenderSense
                         *    (ongoing monitoring pathway)
                         * 2. Shared care with the patient's GP
                         *    (shared care protocol sent, GP acceptance
                         *    confirmed, handoff completed)
                         * 3. A combination of both
                         *
                         * If shared care: creates a Referral entity
                         * and initiates the shared care establishment
                         * process.
                         *
                         * Satisfies: SharedCareCommunication (when
                         * shared care path is taken).
                         *
                         * Episode remains active — it transitions to
                         * the ongoing monitoring pathway rather than
                         * completing here. */
                    @AuditPoint { auditCategory = "care-transition"; }
                }
            }

            // ==========================================================
            // Orchestration-layer action flow: Hormone Therapy Initiation
            //
            // This is the execution view — how the Temporal workflow
            // engine manages the clinical process. Each domain-layer
            // clinical activity maps to one or more orchestration steps
            // annotated with @TemporalActivity (system does work),
            // @TemporalSignal (system waits for external event), or
            // @StateTransitionTrigger (entity lifecycle event).
            //
            // The mapping principle: domain-layer human activities
            // ("clinician reviews results") become orchestration-layer
            // signal waits ("workflow suspends until clinician-review-
            // completed signal received from portal"). System activities
            // ("record in CDR", "send lab order") become Temporal
            // activities with retry and timeout semantics.
            //
            // This action def is the generation target for
            // gen_temporal_workflow.py. The generated TypeScript workflow
            // function will contain the activity calls, signal handlers,
            // state transitions, and the monitoring loop.
            // ==========================================================

            action def InitiateHormoneTherapyWorkflow {
                doc /* Orchestration-layer action flow for hormone therapy
                     * initiation. Maps the domain-layer clinical process
                     * to Temporal workflow execution.
                     *
                     * Generated Temporal workflow: initiateHormoneTherapy
                     * Task queue: gendersense-clinical
                     *
                     * This is a long-running workflow. Temporal's durable
                     * execution model handles the months-long duration,
                     * surviving process restarts and infrastructure
                     * failures transparently. */

                @TemporalWorkflow {
                    workflowName = "initiateHormoneTherapy";
                    taskQueue = "gendersense-clinical";
                }

                in item patient : Patient;
                in item episode : Episode;

                // --- Phase 1: Eligibility, consent, and baseline ---

                action evaluateEligibility {
                    doc /* Activity: query CDR for assessment data and
                         * evaluate eligibility constraints. Returns
                         * an eligibility result with pass/fail and
                         * any blocking reasons. */
                    @TemporalActivity { activityName = "evaluateEligibility"; }
                    @StateTransitionTrigger { eventName = "EpisodeOpened"; }
                }
                then recordInformationProvision;

                action recordInformationProvision {
                    doc /* Activity: record in the CDR that patient
                         * information has been provided. Sends the
                         * information pack via the patient portal
                         * or records face-to-face provision. */
                    @TemporalActivity { activityName = "recordInformationProvision"; }
                }
                then waitConsentRecorded;

                action waitConsentRecorded {
                    doc /* Signal wait: the workflow suspends until a
                         * consent event is received from the patient
                         * portal or recorded by a clinician.
                         *
                         * Timeout: 30 days. If consent is not recorded
                         * within this period, the workflow raises an
                         * alert for clinical follow-up. */
                    @TemporalSignal { signalName = "consentRecorded"; timeoutMinutes = 43200; }
                }
                then submitBaselineLabOrder;

                action submitBaselineLabOrder {
                    doc /* Activity: submit the baseline blood test order
                         * to the lab interface. Creates LabResult
                         * entities in the CDR in 'requested' state. */
                    @TemporalActivity { activityName = "submitBaselineLabOrder"; }
                }
                then waitBaselineResultsReceived;

                action waitBaselineResultsReceived {
                    doc /* Signal wait: the workflow suspends until all
                         * baseline lab results have been received.
                         * The lab interface sends a signal when each
                         * result is available; the workflow checks
                         * whether all required tests are complete.
                         *
                         * Timeout: 30 days. Overdue results trigger
                         * a chase activity. */
                    @TemporalSignal { signalName = "baselineResultsReceived"; timeoutMinutes = 43200; }
                }
                then notifyBaselineResultsReady;

                action notifyBaselineResultsReady {
                    doc /* Activity: notify the prescribing clinician
                         * that baseline results are available for
                         * review. Sends a task to the clinician's
                         * worklist. */
                    @TemporalActivity { activityName = "notifyBaselineResultsReady"; }
                }
                then waitBaselineReviewCompleted;

                action waitBaselineReviewCompleted {
                    doc /* Signal wait: the workflow suspends until the
                         * clinician signals that they have reviewed
                         * all baseline results and recorded their
                         * clinical interpretation.
                         *
                         * Timeout: 14 days. Overdue review triggers
                         * an escalation notification. */
                    @TemporalSignal { signalName = "baselineReviewCompleted"; timeoutMinutes = 20160; }
                    @StateTransitionTrigger { eventName = "ResultReviewed"; }
                }
                then waitRegimenSelected;

                // --- Phase 2: Prescribing ---

                action waitRegimenSelected {
                    doc /* Signal wait: the workflow suspends until the
                         * clinician has selected a regimen and recorded
                         * the prescribing decision in the portal.
                         *
                         * The signal payload includes the selected
                         * medication, route, and starting dose.
                         *
                         * Timeout: 14 days. */
                    @TemporalSignal { signalName = "regimenSelected"; timeoutMinutes = 20160; }
                }
                then runSafetyChecks;

                action runSafetyChecks {
                    doc /* Activity: evaluate prescribing safety
                         * constraints — drug interaction screening,
                         * contraindication checks, protocol adherence
                         * validation. Returns pass/fail with any
                         * blocking reasons.
                         *
                         * If safety checks fail, the workflow loops
                         * back to regimen selection (not modelled in
                         * this linear flow; handled by the activity
                         * raising an exception). */
                    @TemporalActivity { activityName = "runSafetyChecks"; }
                }
                then createPrescription;

                action createPrescription {
                    doc /* Activity: create the prescription record in
                         * the CDR. Transitions the Prescription entity
                         * from drafted to authorised. */
                    @TemporalActivity { activityName = "createPrescription"; }
                    @StateTransitionTrigger { eventName = "PrescriptionAuthorised"; }
                }
                then waitPrescriptionDispensed;

                action waitPrescriptionDispensed {
                    doc /* Signal wait: the workflow suspends until the
                         * pharmacy confirms dispensing. In a future
                         * integration this signal comes from the
                         * pharmacy system; initially it may be
                         * manually recorded by a clinician.
                         *
                         * Timeout: 14 days. */
                    @TemporalSignal { signalName = "prescriptionDispensed"; timeoutMinutes = 20160; }
                    @StateTransitionTrigger { eventName = "PrescriptionDispensed"; }
                }
                then recordMedicationStarted;

                action recordMedicationStarted {
                    doc /* Activity: record that the patient has started
                         * taking the medication. Transitions the
                         * Prescription entity to active. */
                    @TemporalActivity { activityName = "recordMedicationStarted"; }
                    @StateTransitionTrigger { eventName = "PrescriptionStarted"; }
                }
                then scheduleMonitoringOrder;

                // --- Phase 3: Monitoring cycle ---
                //
                // Temporal handles the monitoring loop via the backward
                // then reference. Each iteration of the loop is a new
                // cycle of: schedule bloods -> wait for results ->
                // clinician review -> stability assessment.

                action scheduleMonitoringOrder {
                    doc /* Activity: schedule the next monitoring blood
                         * test order. Creates LabResult entities in
                         * the CDR and submits the order to the lab
                         * interface.
                         *
                         * On the first iteration this is typically at
                         * 3 months; subsequent intervals are determined
                         * by the monitoring protocol. */
                    @TemporalActivity { activityName = "scheduleMonitoringOrder"; }
                }
                then waitMonitoringResultsReceived;

                action waitMonitoringResultsReceived {
                    doc /* Signal wait: the workflow suspends until
                         * monitoring lab results are received.
                         *
                         * This is the longest wait in the cycle —
                         * the interval between scheduling and
                         * result receipt may be 3+ months.
                         *
                         * Timeout: 120 days (accounts for scheduling
                         * interval plus lab turnaround). */
                    @TemporalSignal { signalName = "monitoringResultsReceived"; timeoutMinutes = 172800; }
                }
                then notifyMonitoringResultsReady;

                action notifyMonitoringResultsReady {
                    doc /* Activity: notify the prescribing clinician
                         * that monitoring results are available for
                         * review. */
                    @TemporalActivity { activityName = "notifyMonitoringResultsReady"; }
                }
                then waitMonitoringReviewCompleted;

                action waitMonitoringReviewCompleted {
                    doc /* Signal wait: the workflow suspends until the
                         * clinician has reviewed monitoring results.
                         *
                         * Timeout: 14 days. */
                    @TemporalSignal { signalName = "monitoringReviewCompleted"; timeoutMinutes = 20160; }
                    @StateTransitionTrigger { eventName = "ResultReviewed"; }
                }
                then waitStabilityAssessment;

                action waitStabilityAssessment {
                    doc /* Signal wait: the workflow suspends until the
                         * clinician has recorded their stability
                         * assessment decision. The signal payload
                         * includes the outcome: 'stable' or
                         * 'adjust-dose' with new dose details.
                         *
                         * Timeout: 14 days. */
                    @TemporalSignal { signalName = "stabilityAssessed"; timeoutMinutes = 20160; }
                    @StateTransitionTrigger { eventName = "ResultActioned"; }
                }
                then createAdjustedPrescription;
                then recordStabilisation;

                // --- Branch: dose adjustment (loops back) ---

                action createAdjustedPrescription {
                    doc /* Activity: complete the current prescription
                         * and create a new one at the adjusted dose.
                         * Transitions the old Prescription to completed
                         * and the new one through drafted -> authorised.
                         *
                         * The stability assessment signal payload
                         * provides the new dose details. */
                    @TemporalActivity { activityName = "createAdjustedPrescription"; }
                    @StateTransitionTrigger { eventName = "PrescriptionCompleted"; }
                }
                then scheduleMonitoringOrder;

                // --- Branch: stable regimen ---

                action recordStabilisation {
                    doc /* Activity: record the stabilisation milestone
                         * in the CDR. Captures the stabilisation date,
                         * final stable regimen, and established
                         * monitoring schedule. */
                    @TemporalActivity { activityName = "recordStabilisation"; }
                }
                then initiateTransition;

                // --- Phase 4: Transition ---

                action initiateTransition {
                    doc /* Activity: set up the ongoing care arrangement.
                         * Depending on the care model:
                         *
                         * - GenderSense monitoring: creates a new
                         *   monitoring workflow instance
                         * - Shared care: creates a Referral, sends
                         *   the shared care protocol to the GP, and
                         *   waits for acceptance (may be handled by
                         *   a child workflow)
                         * - Combination: does both
                         *
                         * This is the final activity in the initiation
                         * workflow. The ongoing monitoring becomes a
                         * separate workflow instance. */
                    @TemporalActivity { activityName = "initiateTransition"; }
                }
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
