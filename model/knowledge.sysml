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
        // Uses constraint usages (not defs) as the 'by' target.
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
