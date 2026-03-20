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

        // -- Catalogue and comprehension metadata -----------------
        // Added Session 38: Ontara Stage 2 Phase 1.
        // Source: ontara-discussion-element-grouping-viewpoints-
        //   comprehension-2026-03-19.md §9.1
        // Meta model: Business System (placed in Foundation
        // MetadataLibrary as cross-cutting metadata).

        metadata def CatalogueTag {
            doc /* Catalogue classification metadata for dynamic
                 * grouping and filtering. Applied to any element
                 * that should appear in the Component Catalogue.
                 *
                 * Each attribute represents a classification
                 * dimension. New dimensions are added as new
                 * attributes when needed.
                 *
                 * bmmConcern: which BMM concern this element belongs
                 *   to (ServiceConcept, ActivityModel,
                 *   ResourceCapability, FinancialModel, Governance).
                 *   Named 'bmmConcern' because 'concern' triggers a
                 *   Syside parsing error (not a KerML reserved word
                 *   but treated as one by the parser).
                 * classification: General (domain-agnostic) or
                 *   Tailored (domain-specific). May evolve to a
                 *   multi-tiered scheme.
                 *
                 * One @CatalogueTag per element. The generator
                 * reads all attributes and produces a faceted
                 * structure in JSON.
                 *
                 * Business system meta model concept. */
            attribute bmmConcern : String;
            attribute classification : String;
        }

        metadata def UserFacing {
            doc /* Human-readable metadata for the comprehension layer.
                 * Applied to any element that should be comprehensible
                 * to non-specialist users of the Ontara Console.
                 *
                 * friendlyName: a short, lay-language name
                 *   (e.g. "Pricing Model" for PricingModel).
                 * shortDescription: a brief explanation (1-2 sentences)
                 *   in plain language.
                 *
                 * Generated into the console as tooltips, glossary
                 * entries, and info panel content. Consistent with
                 * I14 (comprehension layer) and A3 (model generates
                 * everything).
                 *
                 * Business system meta model concept. */
            attribute friendlyName : String;
            attribute shortDescription : String;
        }

        metadata def PurposiveDescription {
            doc /* Authored purposive description for the comprehension
                 * layer. Explains what this element means for a service
                 * business and what the system does with it — the
                 * "why should I care?" and "what happens when I define
                 * one of these?" explanation.
                 *
                 * Register 1 (authored comprehension content). Distinct
                 * from @UserFacing (labels and short tooltips) and
                 * @Comprehension (traversal instructions for dynamically
                 * assembled content).
                 *
                 * Style: purposive, systemic, second-person, contract
                 * language. See phase-3-draft-descriptions for the
                 * style guide.
                 *
                 * Business system meta model concept.
                 * Intrinsic self-knowledge principle (A10).
                 * Session 49 — Stage 3 Phase 3, Step 2. */
            attribute description : String;
        }

        // -- Agency classification metadata -----------------------
        // Business system meta model concepts: annotate pathway
        // action nodes with the agent who performs them.
        // Prerequisite for all four generations of self-service.
        // Added Session 29: CSW Extension Phase 10 (items 9.1, 9.2).
        // Source: gsl-discussion-model-self-service-enabling-
        //   architecture-2026-03-14.md §7
        // Meta model: Business System (placed in Foundation
        // MetadataLibrary as cross-cutting metadata).

        enum def AgencyType {
            doc /* Who performs an action in a pathway. Applies to
                 * both clinical and non-clinical contexts.
                 *
                 * Coffee shop: customer (self-service kiosk), staff
                 * (barista makes drink), automated (order routing),
                 * collaborative (customer and barista discuss).
                 *
                 * Clinical: patientAgent, clinicianAgent, automated,
                 * collaborative (e.g. ICE-supported shared decision).
                 *
                 * Business system meta model concept.
                 *
                 * NOTE: 'system' is a KerML reserved word and cannot
                 * be used as an enum literal. 'automated' is used
                 * instead. 'patient' and 'clinician' are suffixed
                 * with 'Agent' to avoid potential conflicts. */
            patientAgent;
            clinicianAgent;
            automated;
            collaborative;
        }

        metadata def AgencyClassification {
            doc /* Annotates a pathway action node with the agent who
                 * performs it. Applied via @AgencyClassification on
                 * action usages within action defs.
                 *
                 * The authorityModelVersion attribute records which
                 * generation's authority rules were in effect when
                 * this classification was assigned. Supports
                 * governance traceability as the self-service model
                 * evolves through generations.
                 *
                 * Initial version: "G1-clinician-authority" — all
                 * clinical decisions made by clinician, patient role
                 * is to provide information and give consent.
                 *
                 * Business system meta model concept.
                 *
                 * Source: gsl-discussion-model-self-service-enabling-
                 *   architecture-2026-03-14.md §7
                 *
                 * SYNTAX NOTE (Session 29): enum-typed attribute on
                 * metadata def. If agencyType : AgencyType fails in
                 * Syside, fall back to agencyType : String. */
            attribute agencyType : AgencyType;
            attribute authorityModelVersion : String;
            attribute agencyNotes : String;
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
                 * works regardless of where data comes from.
                 *
                 * Phase 6B: added accounting for financial actuals
                 * from Xero via Operations::Finance. */
            cdr;         // openEHR CDR via AQL
            temporal;    // Temporal workflow state and history
            platform;    // Platform services (infrastructure, identity)
            entity;      // Entity lifecycle state (XState / Temporal)
            accounting;  // Accounting system (Xero) via Operations::Finance
        }

        enum def DeficitDomain {
            doc /* Domain classification for a deficit.
                 *
                 * Phase 6B: added financial for deficits arising
                 * from financial variance (revenue shortfall, cost
                 * overrun, margin below forecast). Distinct from
                 * operational (process state) because financial
                 * deficits are about the money flowing through
                 * processes, not the processes themselves. */
            clinical;
            operational;
            infrastructure;
            governance;
            financial;
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
        // -- Persistence architecture types -------------------------
        // Business system meta model concepts: describe where domain
        // data lives and why. Cross-cutting — importable by any package.
        // Added Session 29: CSW Extension Phase 10.
        // Source: gsl-spec-catalogue-inventory-v2.1.md §8.3
        // Meta model: Business System (placed in Foundation for
        // practical cross-cutting access; will migrate when the
        // system meta model is extracted as a named package).

        enum def PersistenceLayer {
            doc /* The persistence technology layer where a domain
                 * concept is stored. Each layer has distinct
                 * characteristics:
                 * - clinicalDataRepository: archetype-validated,
                 *   terminology-bound, versioned (openEHR)
                 * - businessDatabase: relational CRUD, transactional
                 *   integrity (PostgreSQL)
                 * - processEngine: durable execution, signal handling
                 *   (Temporal)
                 * - externalReference: knowledge the system links to
                 *   but does not own
                 *
                 * Business system meta model concept. */
            clinicalDataRepository;
            businessDatabase;
            processEngine;
            externalReference;
        }

        enum def DataCharacteristic {
            doc /* Distinguishing characteristics that determine the
                 * natural persistence home for a domain concept.
                 * A concept's characteristic profile maps to a
                 * persistence layer.
                 *
                 * Business system meta model concept. */
            clinicalSignificance;
            terminologyBound;
            requiresVersioning;
            highFrequencyUpdate;
            transactionalIntegrity;
            relationalJoins;
            archetypeValidated;
            durableExecution;
            eventDriven;
            referenceData;
            regulatoryAudit;
        }

        part def PersistencePolicy {
            doc /* Maps a domain concept to its persistence layer,
                 * with explicit rationale expressed as distinguishing
                 * characteristics. Makes architectural reasoning
                 * queryable and auditable — the system can explain
                 * why each concept lives where it does.
                 *
                 * Business system meta model concept: describes how
                 * the system is architected, not what the business
                 * offers. Any service business system that uses
                 * multiple persistence technologies needs this.
                 *
                 * Instantiated per domain concept in each domain's
                 * business model (e.g. CoffeeShopBusinessModel).
                 *
                 * Source: gsl-spec-catalogue-inventory-v2.1.md §8.3 */
            attribute domainConcept : String;
            attribute targetLayer : PersistenceLayer;
            attribute rationale : String;
            attribute characteristics : DataCharacteristic [1..*];
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
