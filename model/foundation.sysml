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
