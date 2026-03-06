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
