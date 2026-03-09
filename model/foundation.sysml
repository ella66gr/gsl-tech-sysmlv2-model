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
             * These live in the shared metadata library
             * (sysml-metadata-lib/temporal/) and are imported by
             * orchestration-layer action flows.
             *
             * Clinical extensions defined here:
             * @ClinicalReviewGate, @ConsentRequired, @AuditPoint,
             * @LogicRule, @DecisionTable, @SafetyConstraint.
             *
             * These were defined during the package hierarchy session
             * (5 March 2026) and parse correctly as metadata defs.
             * Reviewed 6 March 2026 against the hormone therapy
             * initiation pathway requirements: the existing set covers
             * all domain-layer annotation needs.
             *
             * openEHR CDR integration metadata added 8 March 2026
             * (CDR Exercise Phase E): @OpenEhrArchetype, @OpenEhrTemplate.
             * Verified on part defs in Syside 0.8.5. Cross-project import
             * from Foundation::MetadataLibrary resolves correctly.
             *
             * @OpenEhrElement also defined but NOT applicable to
             * attributes — Syside does not accept @ annotations inside
             * attribute bodies, and doc blocks after semicolon-terminated
             * attributes also fail. Retained for potential use on
             * sub-part defs if a future pattern models archetype elements
             * as parts rather than attributes. Per-element mapping uses
             * inline comments (// at0NNN | DV_TYPE) instead. */

        // -- Clinical pathway metadata --------------------------

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

        // -- openEHR CDR integration metadata -------------------

        metadata def OpenEhrArchetype {
            doc /* Maps a SysML part def to an openEHR archetype.
                 *
                 * Provides traceability between the structural model
                 * and the CDR archetype layer. The archetypeId is the
                 * full openEHR archetype identifier (e.g.
                 * "openEHR-EHR-OBSERVATION.order_record.v0").
                 * The rmClass identifies the Reference Model entry
                 * class (OBSERVATION, ACTION, EVALUATION, etc.).
                 *
                 * Verified on part defs in Syside 0.8.5 (8 March 2026).
                 * Cross-project import resolves correctly. Hover tooltip
                 * shows doc string and source location.
                 *
                 * Does not generate code (yet) — purpose is traceability
                 * and model self-description. A future generator could
                 * use this to produce composition builder code from the
                 * model. Queryable via Syside Automator metadata
                 * filtering (evaluate_filter). */
            attribute archetypeId : String;
            attribute rmClass : String;
        }

        metadata def OpenEhrElement {
            doc /* Maps a SysML element to an openEHR archetype data
                 * element (at-code).
                 *
                 * The nodeId is the at-code within the archetype
                 * (e.g. "at0005"). The rmType is the openEHR data
                 * type (e.g. "DV_CODED_TEXT", "DV_TEXT",
                 * "DV_DATE_TIME", "DV_QUANTITY").
                 *
                 * LIMITATION (verified 8 March 2026): Syside does NOT
                 * accept @ annotations inside attribute bodies, and
                 * doc blocks after semicolon-terminated attributes also
                 * fail. This metadata def cannot be applied to attributes.
                 * Retained for potential use on sub-part defs if a future
                 * modelling pattern represents archetype data elements as
                 * contained parts rather than attributes.
                 *
                 * Current recommendation: use inline comments for
                 * per-element mapping. Format:
                 *   attribute name : Type; // at0NNN | DV_CODED_TEXT */
            attribute nodeId : String;
            attribute rmType : String;
        }

        metadata def OpenEhrTemplate {
            doc /* Maps a SysML part def to an openEHR template
                 * (OPT / operational template).
                 *
                 * Templates compose archetypes into use-case-specific
                 * data sets. Each template corresponds to a composition
                 * type committed to the CDR. The templateId matches
                 * the template_id used in EHRbase API calls.
                 *
                 * Applied to part defs that represent composition
                 * types (containers of archetype-mapped data).
                 * Verified on part defs in Syside 0.8.5 (8 March 2026). */
            attribute templateId : String;
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

        // --- Evaluation and self-knowledge types ---------------
        // Added Session 8: Knowledge Layer Phase 1

        enum def EvaluationOutcome {
            doc /* Result of evaluating a constraint, rule, or goal.
                 * Three-valued: pass (condition met), fail (condition
                 * not met), indeterminate (insufficient data). */
            pass;
            fail;
            indeterminate;
        }

        enum def Severity {
            doc /* Severity classification for deficits, constraints,
                 * and audit findings. */
            critical;
            warning;
            informational;
        }

        enum def AssessmentScope {
            doc /* Scope at which an evaluation or assessment is
                 * performed. */
            patient;
            cohort;
            pathway;
            domain;
            system;
        }

        enum def DataSourceType {
            doc /* Authoritative data source for input derivation.
                 * Source-agnostic: same InputDerivation structure
                 * works regardless of where data comes from. */
            cdr;         // openEHR CDR via AQL
            temporal;    // Temporal workflow state and history
            platform;    // Platform services (infrastructure, identity)
            entity;      // Entity lifecycle state (XState / Temporal)
        }

        enum def DeficitDomain {
            doc /* Domain classification for a deficit. */
            clinical;
            operational;
            infrastructure;
            governance;
        }

        enum def RemediationCategory {
            doc /* How a deficit can be addressed. Defines the boundary
                 * between deterministic system action and advisory
                 * output.
                 * automatic: pathway model defines next step, system
                 *   can trigger it.
                 * recommended: specific action identified but requires
                 *   human decision.
                 * advisory: deficit is systemic or compound, system
                 *   surfaces it with supporting data. */
            automatic;
            recommended;
            advisory;
        }

        enum def ServiceHealthStatus {
            doc /* Health status of an infrastructure service. */
            healthy;
            degraded;
            unreachable;
        }

        // Added Session 10: Knowledge Layer Phase 3 (DecisionModels)

        enum def HormoneLevel {
            doc /* Categorised hormone level from blood test results.
                 * Used in decision tables for regimen selection and
                 * stability assessment. */
            low;
            normal;
            high;
            suppressed;
        }

        enum def TherapyPreference {
            doc /* Patient's preference for hormone therapy type.
                 * Captures the direction of therapy as expressed
                 * by the patient during assessment. */
            oestrogen;
            testosterone;
            combined;
        }

        enum def ContraindicationCategory {
            doc /* Categorised contraindication status for prescribing
                 * decisions. Simplification of the full clinical
                 * assessment into categories that drive protocol
                 * selection. */
            noContraindication;
            vteRisk;
            liverDisease;
            cardiacRisk;
            multiple;
        }

        enum def HormoneMedication {
            doc /* Hormone therapy medications in the prescribing
                 * protocol. Each entry represents a specific
                 * pharmaceutical product. */
            estradiolValerate;
            estradiolGel;
            estradiolPatch;
            testosteroneUndecanoate;
            testosteroneEnantate;
            testosteroneGel;
        }

        enum def AdministrationRoute {
            doc /* Route of medication administration. */
            oral;
            transdermal;
            intramuscular;
            subcutaneous;
        }

        enum def DoseCategory {
            doc /* Categorised starting dose level. Maps to specific
                 * dose values per medication in the prescribing
                 * protocol. The dose category determines the actual
                 * dose based on medication-specific tables. */
            low;
            standardDose;
            reduced;
            high;
        }

        enum def PatientSatisfaction {
            doc /* Patient-reported satisfaction with treatment
                 * progress. Captured during monitoring consultations. */
            satisfied;
            neutral;
            dissatisfied;
        }

        enum def StabilityClassification {
            doc /* Clinical classification of regimen stability.
                 * Output of the stabilityAssessment decision table. */
            stable;
            improving;
            adjustmentNeeded;
            concerning;
        }

        enum def MonitoringAction {
            doc /* Recommended monitoring action based on stability
                 * assessment. Output of the stabilityAssessment
                 * decision table. */
            continueCurrentRegimen;
            adjustDose;
            reduceMonitoringInterval;
            increaseMonitoringInterval;
            clinicalReviewUrgent;
        }

        // Added Session 11: Knowledge Layer Phase 4 (OutcomeFramework)

        enum def OutcomeCategory {
            doc /* Category of a clinical outcome measure.
                 * Determines which outcomes are collected at
                 * each measurement point and how they are
                 * reported. */
            clinical;
            adherence;
            safety;
            patientReported;
        }

        enum def OutcomeStatus {
            doc /* Status of an individual outcome measurement
                 * against its defined target.
                 * pending: measurement due but not yet taken
                 * measured: data collected, not yet evaluated
                 * targetMet: evaluated and within target
                 * targetNotMet: evaluated and outside target
                 * indeterminate: data insufficient for evaluation */
            pending;
            measured;
            targetMet;
            targetNotMet;
            indeterminate;
        }

        enum def MeasurementFrequency {
            doc /* How often an outcome is measured. Determines
                 * which measurement points include this outcome. */
            baseline;
            threeMonthly;
            sixMonthly;
            annually;
            adHoc;
        }

        enum def ComparisonOperator {
            doc /* How a target value is compared against an actual
                 * measurement. Used in OutcomeDefinition to specify
                 * the target condition.
                 * within: actual falls within a range (uses
                 *   targetValue and targetUpperBound)
                 * greaterThan: actual exceeds a threshold
                 * lessThan: actual is below a threshold
                 * equalTo: actual matches exactly */
            within;
            greaterThan;
            lessThan;
            equalTo;
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
