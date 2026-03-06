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

        // --- satisfy/verify syntax verification (v3.1) ---

        requirement def BloodMonitoringRequired {
            doc /* Patients on hormone therapy must have blood tests
                 * performed at defined monitoring intervals. This is
                 * a CQC and clinical governance requirement. */
            subject patient : Patient;
            attribute monitoringIntervalWeeks : Integer;
        }

        requirement def ConsentBeforeTreatment {
            doc /* Informed consent must be obtained and recorded
                 * before any treatment is initiated. */
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
