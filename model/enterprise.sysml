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
        private import ServiceDelivery::ClinicalEntities::*;

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

        // =============================================================
        // Requirements: Hormone Therapy Initiation Pathway
        //
        // These are the governance obligations that the pathway must
        // satisfy. Each traces to one or more evaluable constraints
        // in Knowledge::ConstraintLibrary via satisfy relationships.
        // =============================================================

        // --- Consent and patient information ---

        requirement def ConsentBeforeTreatment {
            doc /* Informed consent must be obtained and recorded
                 * before any treatment is initiated. Consent must
                 * be specific to the proposed treatment, documented
                 * in the clinical record, and include evidence that
                 * the patient had capacity at the time of consent.
                 *
                 * Regulatory basis: GMC Good Medical Practice,
                 * Montgomery v Lanarkshire (2015), CQC Regulation 11. */
            subject patient : Patient;
        }

        requirement def InformedConsentRequiresInformation {
            doc /* Before consent can be considered informed, the patient
                 * must have received and had opportunity to consider
                 * relevant information about the proposed treatment,
                 * including expected effects, potential risks, alternative
                 * options, and the consequences of not proceeding.
                 *
                 * This is a precondition of ConsentBeforeTreatment:
                 * consent obtained without adequate information provision
                 * is not valid informed consent.
                 *
                 * Regulatory basis: Montgomery v Lanarkshire (2015),
                 * GMC consent guidance. */
            subject patient : Patient;
        }

        // --- Baseline investigations ---

        requirement def BaselineInvestigationsBeforePrescribing {
            doc /* Baseline blood tests must be completed, resulted,
                 * and reviewed by a clinician before a hormone therapy
                 * prescription is authorised. The required baseline
                 * panel includes FBC, U&Es, LFTs, lipid profile,
                 * fasting glucose, prolactin, and baseline hormone
                 * levels (testosterone, oestradiol).
                 *
                 * 'Reviewed' means a clinician has seen the results
                 * and recorded their clinical interpretation, not
                 * merely that results are available in the system.
                 *
                 * Regulatory basis: NICE/Endocrine Society guidelines,
                 * CQC Regulation 12 (safe care and treatment). */
            subject patient : Patient;
        }

        // --- Prescribing governance ---

        requirement def ClinicalReviewBeforePrescribing {
            doc /* A clinician with appropriate competence must conduct
                 * a clinical review before authorising a hormone therapy
                 * prescription. The review must consider baseline
                 * investigations, patient history, contraindications,
                 * and the proposed regimen.
                 *
                 * This applies to both initial prescribing and any
                 * subsequent dose adjustments.
                 *
                 * Regulatory basis: GMC Good Practice in Prescribing,
                 * CQC Regulation 12. */
            subject patient : Patient;
        }

        requirement def PrescribingProtocolAdherence {
            doc /* Prescribing must follow an approved clinical protocol.
                 * The protocol defines eligible medications, routes of
                 * administration, starting doses, titration schedules,
                 * and therapeutic target ranges.
                 *
                 * Deviations from protocol must be clinically justified
                 * and documented in the clinical record.
                 *
                 * Regulatory basis: CQC Regulation 12, clinical
                 * governance best practice. */
            subject patient : Patient;
        }

        // --- Monitoring ---

        requirement def BloodMonitoringRequired {
            doc /* Patients on hormone therapy must have blood tests
                 * performed at defined monitoring intervals. The
                 * monitoring schedule is determined by the prescribing
                 * protocol and the patient's clinical stability.
                 *
                 * Initial monitoring is typically at 3 months post-
                 * initiation, then at intervals determined by clinical
                 * response until stable, then at least annually.
                 *
                 * Regulatory basis: Endocrine Society/NICE guidelines,
                 * CQC Regulation 12. */
            subject patient : Patient;
            attribute monitoringIntervalWeeks : Integer;
        }

        requirement def ClinicalReviewBeforeDoseAdjustment {
            doc /* Any change to hormone therapy dosage must be preceded
                 * by a clinical review that considers current blood
                 * results, symptom assessment, side effect evaluation,
                 * and the patient's overall clinical picture.
                 *
                 * Dose adjustments without clinical review are not
                 * permitted, even when blood results suggest a change
                 * may be appropriate.
                 *
                 * Regulatory basis: GMC Good Practice in Prescribing,
                 * CQC Regulation 12. */
            subject patient : Patient;
        }

        // --- Shared care ---

        requirement def SharedCareCommunication {
            doc /* When hormone therapy monitoring is transitioned to
                 * shared care with the patient's GP, the GP must receive
                 * a shared care protocol document that includes the
                 * current regimen, monitoring schedule, therapeutic
                 * target ranges, action thresholds, and clear guidance
                 * on when to refer back.
                 *
                 * Shared care must not commence until the GP practice
                 * has confirmed acceptance of the shared care arrangement.
                 *
                 * Regulatory basis: BMA/RCGP shared care guidance,
                 * GMC Good Medical Practice (continuity of care). */
            subject patient : Patient;
        }
    }

    package Strategy {
        private import ScalarValues::*;

        doc /* Partnerships, strategic context, ethos and values,
             * CIC/limited company structure, strategic direction.
             *
             * This is the enterprise-level anchor for strategy.
             * Detailed business strategy (objectives, variants,
             * pivot scenarios) lives in the BusinessStrategy
             * package. Detailed scenario modelling lives in
             * BusinessScenarios. This package provides the
             * organisational framing and governance context.
             *
             * Cross-references to BusinessStrategy and
             * BusinessScenarios are via String attributes and
             * doc blocks — Enterprise does not import from
             * Business* packages (outer ring does not depend
             * on inner ring). */

        part def Partnership {
            doc /* A strategic partnership or collaboration.
                 * Cross-references BusinessStrategy::
                 * StrategicObjective by name where the
                 * partnership supports a specific objective. */
            attribute partnerName : String;
            attribute nature : String;
            attribute strategicObjectiveRef : String;
        }

        part def StrategicContext {
            doc /* Connects the enterprise-level strategic context
                 * to the detailed business strategy and scenario
                 * modelling. This is the structural bridge between
                 * the outer ring (Enterprise) and the business
                 * model layer.
                 *
                 * Renamed from BusinessModel (Phase 7) to avoid
                 * collision with the top-level BusinessModel
                 * package and to better reflect its role as the
                 * enterprise-level strategic anchor.
                 *
                 * Cross-references (via String, not import):
                 * - BusinessStrategy::StrategicObjective
                 * - BusinessStrategy::BusinessModelVariant
                 * - BusinessStrategy::PivotScenario
                 * - BusinessScenarios::ScenarioDefinition */
            attribute contextName : String;
            attribute currentVariant : String;
            attribute strategicHorizonMonths : Integer;
            attribute governanceNotes : String;
        }

        // -- GSL strategic context ----------------------------

        part gslStrategicContext : StrategicContext {
            doc /* GenderSense strategic context as of 2026.
                 * Sole founder governance. Lean Clinical variant
                 * is the active business model configuration. */
            attribute :>> contextName = "GenderSense Strategic Context 2026";
            attribute :>> currentVariant = "Lean Clinical (Variant A)";
            attribute :>> strategicHorizonMonths = 24;
            attribute :>> governanceNotes = "Sole founder governance. Clinical governance via CQC registration. Strategic decisions informed by projection comparison and actuals tracking via BusinessScenarios steering cycle.";
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
