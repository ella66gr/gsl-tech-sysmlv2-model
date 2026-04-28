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
                 * System meta model concept. */
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
                 * System meta model concept. */
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
                 * System meta model concept.
                 * Intrinsic self-knowledge principle (A10).
                 * Session 49 — Stage 3 Phase 3, Step 2. */
            attribute description : String;
        }

        metadata def Comprehension {
            doc /* Comprehension traversal schema. Declares which
                 * categories of dynamically assembled content the
                 * comprehension engine should surface for this
                 * element.
                 *
                 * The annotation is a recipe — it declares what to
                 * show, not what to say. The generator reads these
                 * flags and discovers structural facts from the live
                 * model at generation time.
                 *
                 * 3b approach (Session 49, S49-D4): declarative
                 * flags with smart generator. The annotation is
                 * lightweight; the intelligence is in the
                 * generator's traversal logic.
                 *
                 * surfaceEnumValues: show associated enum values
                 *   discovered via attribute type matching.
                 * surfaceDomainInstantiations: show cross-domain
                 *   usage counts and instance names.
                 * surfaceRelatedConcepts: show structurally related
                 *   elements (same-package siblings for pilot;
                 *   typed refs in future per O25).
                 * surfaceAttributes: show the element's own
                 *   attributes with their types.
                 *
                 * System meta model concept.
                 * Intrinsic self-knowledge principle (A10).
                 * Unity principle (A11).
                 * Session 50 — Stage 3 Phase 3, Step 3. */
            attribute surfaceEnumValues : Boolean;
            attribute surfaceDomainInstantiations : Boolean;
            attribute surfaceRelatedConcepts : Boolean;
            attribute surfaceAttributes : Boolean;
        }

        // -- Weighted relationship metadata -----------------------
        // Added Session 51: Ontara Stage 3 Phase 3, Step 4.
        // Source: ontara-stage-3-plan-phase-3-implementation-2026-03-20.md §4 (Step 4)
        // Design: Option B — one annotation per relationship,
        //   multiple same-metaclass annotations per element.
        //   Verified v3.17: stacking up to 6 annotations works.
        // Meta model: Business System (cross-cutting metadata).

        enum def RelationshipStrength {
            doc /* Ordinal classification of interaction effect strength
                 * between related elements. Starting point for the
                 * weighted relationship model (B14).
                 *
                 * Designed for hybrid evolution: ordinal now, numeric
                 * weights later, structural derivation baseline with
                 * human overrides (J12 — experimentation before
                 * convention).
                 *
                 * System meta model concept. Unity principle
                 * (A11): same weights inform comprehension, reasoning,
                 * simulation, governance, and assembly guidance. */
            strong;
            moderate;
            weak;
            contextual;
        }

        metadata def WeightedRelationship {
            doc /* Declares a weighted relationship from the annotated
                 * element to a named target element. Each annotation
                 * declares one relationship. Multiple annotations of
                 * this metaclass may be applied to a single element
                 * (verified v3.17, Session 51).
                 *
                 * target: name of the related element (String for now;
                 *   migration to typed ref per O25 is the architectural
                 *   direction).
                 * strength: ordinal classification of the interaction
                 *   effect. Typed as RelationshipStrength enum.
                 * rationale: brief explanation of why this weight was
                 *   assigned.
                 *
                 * Annotation ordering convention (Position A, prefix):
                 *   @CatalogueTag → @UserFacing → @PurposiveDescription
                 *   → @Comprehension → @WeightedRelationship (multiple)
                 *
                 * System meta model concept.
                 * Unity principle (A11). Weighted relationships (B14).
                 * Non-constraining (J3): ordinal weights designed for
                 * hybrid evolution to numeric/structural derivation.
                 * Session 51 — Stage 3 Phase 3, Step 4. */
            attribute target : String;
            attribute strength : RelationshipStrength;
            attribute rationale : String;
        }

        // -- BFO ontological grounding metadata ---------------
        // Added Session 98: Knowledge graph architecture (Session 97).
        // Source: ontara-discussion-bfo-type-mapping-2026-04-01.md
        // Meta model: Business System (cross-cutting metadata).

        metadata def BfoType {
            doc /* BFO ontological grounding annotation. Declares the
                 * BFO 2020 category and mid-level ontology parent for
                 * a BMM or SMM element.
                 *
                 * This annotation is the input to Stage 2 of the
                 * OWL mapping pipeline — the classification step that
                 * determines how each SysML element projects into the
                 * knowledge graph's domain graph stratum.
                 *
                 * bfoClass: the BFO 2020 class name. Uses the standard
                 *   BFO label (e.g. "Role", "Process", "Quality",
                 *   "GenericallyDependentContinuant"). Validated against
                 *   the loaded BFO OWL file at pipeline Stage 4.
                 * midLevelClass: the CCO, IAO, OGMS, or other mid-level
                 *   ontology class that this element maps to. Uses
                 *   prefix:ClassName format (e.g. "CCO:ActOfServiceProvision",
                 *   "IAO:InformationContentEntity"). Empty string if no
                 *   mid-level mapping is identified yet.
                 * mappingNotes: brief rationale for the classification,
                 *   especially where the mapping is non-obvious or where
                 *   alternatives were considered.
                 *
                 * Annotation ordering convention (Position A, prefix):
                 *   @CatalogueTag → @BfoType → @UserFacing →
                 *   @PurposiveDescription → @Comprehension →
                 *   @WeightedRelationship (multiple)
                 *
                 * Ontological grounding (B18, B19). OWL 2 DL (B23).
                 * Knowledge graph (B22). Mapping ontology (B24).
                 * Domain-semantic mapping (Session 97 D6).
                 * System meta model concept.
                 * Session 98. */
            attribute bfoClass : String;
            attribute midLevelClass : String;
            attribute mappingNotes : String;
        }

        // -- Agency classification metadata -----------------------
        // System meta model concepts: annotate pathway
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
                 * System meta model concept.
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
                 * System meta model concept.
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
            doc /* Direction of a referral or referral pathway.
                 * Extended Session 81: bidirectional added for
                 * referral pathways where both directions operate
                 * (e.g. GP refers to GSL, GSL refers back to GP). */
            inbound;
            outbound;
            bidirectional;
        }

        // Added Session 81: StakeholderModel enums

        enum def RelationshipNature {
            doc /* Classification of the nature of a stakeholder
                 * relationship. Closed enum — tailored extensions
                 * can add domain-specific values via :>> redefinition
                 * (e.g. clinicalNetwork for healthcare).
                 *
                 * Business meta model concept. StakeholderModel (C7).
                 * Session 81. */
            regulatory;
            contractual;
            professional;
            advisory;
            commissioning;
            peer;
        }

        enum def DependencyCriticality {
            doc /* Classification of how critical an external
                 * dependency is to the business's operation.
                 * Drives contingency planning priority.
                 *
                 * Business meta model concept. StakeholderModel (C7).
                 * Session 81. */
            essential;
            important;
            convenient;
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
        // System meta model concepts: describe where domain
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
                 * System meta model concept. */
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
                 * System meta model concept. */
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
                 * System meta model concept: describes how
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

        // -- Domain identity enums (Session 59 design, Session 142 extension,
        //                            Session 278 RegulatoryShape rebuild) --
        // Three original enums from Session 59 domain identity paper (B15).
        // Three new enums from Session 142 dual-stack extension (S142-D7).
        // RegulatoryTier renamed to RegulatoryShape and rebuilt from an
        // intensity scale to a kind-based classification at Session 278.
        // ProfessionalBody enum added Session 278.
        // All placed in CommonTypes for independent importability by
        // governance, generators, and other subsystems.

        enum def RegulatoryShape {
            doc /* Five-value kind-based classification of the principal
                 * governance frame applicable to a service business.
                 * Names what governs the business, not how much.
                 * Mutually exclusive and exhaustive for the principal
                 * regulatory frame; nuance carried on orthogonal
                 * supporting attributes (authorisationRequiredToTrade,
                 * professionalRegistrations, regulatedActivities).
                 *
                 * generallyGoverned: only general business law (consumer,
                 *   contract, H&S, employment, GDPR). No sector regulator,
                 *   no licensing regime, no role-binding professional body.
                 *   Example: Cafe.
                 * locallyLicensed: no sector regulator, but provision
                 *   requires a local-authority licence, environmental
                 *   permit, or sector-specific statutory duty (animal
                 *   welfare, COSHH, premises licence) beyond general law.
                 *   Example: Suds, Paws.
                 * professionalBodyRegulated: no sector regulator, but
                 *   practitioners are bound by membership-based
                 *   professional bodies (BACP, UKCP, ICF, BPS) whose
                 *   codes of ethics and complaint routes are the principal
                 *   governance frame. Example: Minds.
                 * statutoryProfessionRegulated: practitioners hold
                 *   statutory professional registration (GMC, NMC, HCPC,
                 *   GPhC) that the regulator can suspend or remove, but
                 *   the business itself is not within a sector-regulator
                 *   perimeter. Example: an independent advisory clinic
                 *   below CQC threshold.
                 * sectorRegulated: the business itself sits within a
                 *   sector regulator's perimeter (CQC, FCA, Ofsted, SRA,
                 *   Ofcom, EA). Authorisation/registration is required
                 *   to lawfully provide the core service.
                 *   Example: Ears, GSL.
                 *
                 * Renamed from RegulatoryTier and rebuilt at S278:
                 * the previous four-value intensity scale
                 * {generallyGoverned, lightlyRegulated, partiallyRegulated,
                 * sectorRegulated} muddled kind and intensity. The new
                 * vocabulary captures kind explicitly. partiallyRegulated
                 * is removed; mixed-services-with-regulated-components
                 * cases are now expressed by a non-empty regulatedActivities
                 * list on a tenant whose principal shape is one of the
                 * other values. lightlyRegulated → locallyLicensed for
                 * vocabulary precision. moderatelyRegulated — used in
                 * documentation but never in the SysML enum — is replaced
                 * by sectorRegulated for the Ears-shaped case.
                 *
                 * Business meta model concept. Domain identity (B15).
                 * Session 59, confirmed Session 142, rebuilt Session 278. */
            generallyGoverned;
            locallyLicensed;
            professionalBodyRegulated;
            statutoryProfessionRegulated;
            sectorRegulated;
        }

        enum def ProfessionalBody {
            doc /* Closed enum of recognised professional bodies whose
                 * registration or membership constitutes part of a
                 * tenant's regulatory shape. Used on the
                 * DomainIdentity.professionalRegistrations multi-valued
                 * attribute. Each entry carries an implicit category
                 * (statutory or membership-based) — see the value
                 * descriptions below; surfaced as documentation rather
                 * than a separate axis enum to keep one queryable list.
                 *
                 * Statutory bodies (registration that the regulator can
                 * suspend or remove, with statutory power):
                 *   gmc — General Medical Council (doctors, UK).
                 *   nmc — Nursing and Midwifery Council.
                 *   hcpc — Health and Care Professions Council.
                 *   gphc — General Pharmaceutical Council.
                 *   gdc — General Dental Council.
                 *   gosc — General Osteopathic Council.
                 *   gcc — General Chiropractic Council.
                 *   goc — General Optical Council.
                 *
                 * Membership-based bodies (membership of a body whose
                 * code of ethics binds the member by contract, with
                 * complaint routes and possible expulsion but no
                 * statutory removal of the right to practise):
                 *   bacp — British Association for Counselling and
                 *     Psychotherapy.
                 *   ukcp — UK Council for Psychotherapy.
                 *   icf — International Coaching Federation.
                 *   bps — British Psychological Society.
                 *   bcsh — British Council of Self-Hypnosis (placeholder
                 *     for analogous bodies — extend as encountered).
                 *
                 * Extension policy: add new values when first encountered
                 * by a tenant being modelled. Do not pre-populate.
                 *
                 * Business meta model concept. Domain identity (B15).
                 * Session 278. */
            gmc;
            nmc;
            hcpc;
            gphc;
            gdc;
            gosc;
            gcc;
            goc;
            bacp;
            ukcp;
            icf;
            bps;
            bcsh;
        }

        enum def BmmVocabularyScope {
            doc /* Which subset of the Business Meta Model vocabulary
                 * a domain instantiates.
                 * generalOnly: uses only General-level BMM elements.
                 * full: uses both General and Tailored elements.
                 * production: full vocabulary plus production-grade
                 *   governance, audit, and operational requirements.
                 *
                 * Business meta model concept. Domain identity (B15).
                 * Session 59, confirmed Session 142. */
            generalOnly;
            full;
            production;
        }

        enum def DomainPurpose {
            doc /* Why a domain exists in the Ontara platform.
                 * A domain may have multiple purposes (e.g. Paws is
                 * both pedagogicalAnchoring and crossDomainValidation).
                 *
                 * referenceValidation: the original demonstrator domain
                 *   against which patterns are first developed.
                 * crossDomainValidation: validates that meta model
                 *   concepts generalise beyond the reference domain.
                 * pedagogicalAnchoring: simple domain used to introduce
                 *   concepts and verify understanding.
                 * production: a real service business using the platform
                 *   for actual service delivery.
                 *
                 * Business meta model concept. Domain identity (B15).
                 * Session 59, confirmed Session 142 (S142-D6: multi-valued). */
            referenceValidation;
            crossDomainValidation;
            pedagogicalAnchoring;
            production;
        }

        enum def Jurisdiction {
            doc /* Territorial jurisdiction for governance framework
                 * applicability. Based on UK devolution structure — the
                 * primary governance frameworks Ontara supports have
                 * jurisdiction-specific scope. Extensible as the platform
                 * supports non-UK jurisdictions.
                 *
                 * Business meta model concept. Domain identity (B15).
                 * Session 142 (S142-D7). */
            england;
            scotland;
            wales;
            northernIreland;
            unitedKingdom;
        }

        enum def RegulatedActivity {
            doc /* Activities regulated by CQC under the Health and Social
                 * Care Act 2008. A service providing any of these must be
                 * registered with CQC. Used during governance framework
                 * activation to determine directive applicability.
                 *
                 * Source: HSCA 2008 (Regulated Activities) Regulations 2014,
                 * Schedule 1.
                 *
                 * Business meta model concept. Domain identity (B15).
                 * Session 142 (S142-D7). */
            personalCare;
            accommodationForPersonsRequiringNursingOrPersonalCare;
            accommodationForPersonsRequiringTreatmentForSubstanceMisuse;
            treatment;
            assessmentOrMedicalTreatmentForPersonsDetainedUnderMentalHealthAct;
            surgicalProcedures;
            diagnosticAndScreeningProcedures;
            managementOfSupplyOfBloodAndBloodDerivedProducts;
            transportServicesTimedAndUntimed;
            maternity;
            terminationOfPregnancies;
            familyPlanning;
            nursingCare;
        }

        enum def OrganisationalForm {
            doc /* The legal/organisational form of a service provider.
                 * Some governance directives apply only to specific forms
                 * (e.g. "body corporate" provisions in CQC regulations).
                 *
                 * Source: CQC registration requirements; Companies Act 2006.
                 *
                 * Business meta model concept. Domain identity (B15).
                 * Session 142 (S142-D7). */
            registeredIndividual;
            partnership;
            organisation;
            bodyCorporate;
        }
    }

    package DomainRegistry {
        private import ScalarValues::*;
        private import Foundation::CommonTypes::*;

        doc /* Domain identity infrastructure: the formal representation
             * of each service business domain in the Ontara platform.
             *
             * Contains two part defs (DomainIdentity, DomainConfiguration)
             * implementing the dual-stack split (S142-D1), plus concrete
             * domain instances for all four domains.
             *
             * DomainIdentity is the BMM-side concept — what the service
             * business is. DomainConfiguration is the SMM-side concept —
             * how the platform manages it. Connected by a horizontal
             * mapping (bidirectional ref).
             *
             * Multi-tenancy principle (A13): only the meta model is core;
             * every domain is a tenant instantiation.
             *
             * Session 59 (original design, B15).
             * Session 142 (dual-stack extension, S142-D1 to D7).
             * Session 143 (SysML implementation). */

        // ============================================================
        // Part definitions
        // ============================================================

        part def DomainIdentity {
            doc /* Business Meta Model concept.
                 * The business identity of a domain: what kind of service
                 * business it is, what regulatory environment it operates
                 * in, and why it exists in the platform.
                 *
                 * In the dual-stack architecture, DomainIdentity is the
                 * BMM-side of domain identity. The SMM-side is
                 * DomainConfiguration, connected by a horizontal mapping.
                 *
                 * In the multi-tenancy architecture (A13), only the meta
                 * model is core. Every DomainIdentity represents a tenant
                 * instantiation.
                 *
                 * BFO grounding: IAO:plan_specification (S142-D2).
                 * Domain identity (B15). Dual-stack (B21).
                 * Multi-tenancy (A13). Session 142 design, Session 143.
                 * Session 278: regulatoryTier renamed to regulatoryShape
                 * (kind-based, not intensity-based); two orthogonal
                 * supporting attributes added
                 * (authorisationRequiredToTrade,
                 * professionalRegistrations). regulatedActivities
                 * is now also the carrier of the
                 * mixed-services-with-regulated-components case (the
                 * old partiallyRegulated tier). */

            attribute regulatoryShape : RegulatoryShape;
            attribute bmmVocabularyScope : BmmVocabularyScope;
            attribute domainPurpose : DomainPurpose[1..*];
            attribute jurisdiction : Jurisdiction;
            attribute regulatedActivities : RegulatedActivity[0..*];
            attribute professionalRegistrations : ProfessionalBody[0..*];
            attribute organisationalForm : OrganisationalForm;
            attribute authorisationRequiredToTrade : Boolean;
            attribute description : String;
            attribute introducedSession : Integer;
            ref domainConfiguration : DomainConfiguration;
        }

        part def DomainConfiguration {
            doc /* System Meta Model concept.
                 * The system configuration for a domain: how the platform
                 * discovers, organises, presents, and manages this domain.
                 *
                 * Connected to DomainIdentity via horizontal mapping.
                 * Changes to configuration (package paths, display names)
                 * do not affect business identity or governance bindings.
                 *
                 * BFO grounding: IAO:data_item (S142-D2).
                 * Domain identity (B15). Dual-stack (B21).
                 * Session 142 design, Session 143. */

            attribute canonicalKey : String;
            attribute displayLabel : String;
            attribute fullName : String;
            attribute packageName : String;
            attribute modelPath : String;
            attribute isActive : Boolean;
            ref domainIdentity : DomainIdentity;
        }

        // ============================================================
        // Domain instances
        // ============================================================
        // Each domain has a DomainIdentity (BMM) and a
        // DomainConfiguration (SMM), cross-referenced via
        // bidirectional ref :>> redefinitions.

        // --- Cafe (Coffee Shop) ------------------------------------

        part cafeIdentity : DomainIdentity {
            doc /* Reference validation domain — the original demonstrator
                 * against which all meta model patterns were first
                 * developed. Immediate retail, walk-in, 2-minute cycle.
                 * Generally governed (no sector-specific regulation,
                 * no licensing regime, no role-binding professional
                 * body). Subject only to general business law. */

            attribute :>> regulatoryShape = RegulatoryShape::generallyGoverned;
            attribute :>> bmmVocabularyScope = BmmVocabularyScope::full;
            attribute :>> domainPurpose = DomainPurpose::referenceValidation;
            attribute :>> jurisdiction = Jurisdiction::england;
            attribute :>> organisationalForm = OrganisationalForm::registeredIndividual;
            attribute :>> authorisationRequiredToTrade = false;
            attribute :>> description = "Reference validation domain — original demonstrator. Immediate retail service with walk-in customers and 2-minute fulfilment cycle.";
            attribute :>> introducedSession = 1;
            ref :>> domainConfiguration = cafeConfiguration;
        }

        part cafeConfiguration : DomainConfiguration {
            attribute :>> canonicalKey = "cafe";
            attribute :>> displayLabel = "Cafe";
            attribute :>> fullName = "Cafe (Coffee Shop)";
            attribute :>> packageName = "CoffeeShop";
            attribute :>> modelPath = "exercises/coffeeshop-demonstrator/model";
            attribute :>> isActive = true;
            ref :>> domainIdentity = cafeIdentity;
        }

        // --- Suds (Laundry Service) ---------------------------------

        part sudsIdentity : DomainIdentity {
            doc /* Cross-domain validation domain — batch processing
                 * laundry service. Validates meta model generality
                 * beyond immediate retail. Weight/type pricing,
                 * COSHH governance chain. Locally licensed (subject to
                 * COSHH and other operator-controlled statutory duties
                 * beyond general business law; no sector regulator). */

            attribute :>> regulatoryShape = RegulatoryShape::locallyLicensed;
            attribute :>> bmmVocabularyScope = BmmVocabularyScope::full;
            attribute :>> domainPurpose = DomainPurpose::crossDomainValidation;
            attribute :>> jurisdiction = Jurisdiction::england;
            attribute :>> organisationalForm = OrganisationalForm::registeredIndividual;
            attribute :>> authorisationRequiredToTrade = false;
            attribute :>> description = "Cross-domain validation domain — batch processing laundry service. Weight/type pricing, COSHH governance chain.";
            attribute :>> introducedSession = 16;
            ref :>> domainConfiguration = sudsConfiguration;
        }

        part sudsConfiguration : DomainConfiguration {
            attribute :>> canonicalKey = "suds";
            attribute :>> displayLabel = "Suds";
            attribute :>> fullName = "Suds (Laundry Service)";
            attribute :>> packageName = "SudsLaundry";
            attribute :>> modelPath = "exercises/suds-demonstrator";
            attribute :>> isActive = true;
            ref :>> domainIdentity = sudsIdentity;
        }

        // --- Paws (Dog Grooming) ------------------------------------

        part pawsIdentity : DomainIdentity {
            doc /* Pedagogical anchoring and cross-domain validation
                 * domain — appointment-based dog grooming service.
                 * Dual purpose (S142-D6): simple enough to introduce
                 * concepts, different enough to validate generalisation.
                 * Breed/size surcharges. Locally licensed (Animal
                 * Welfare Act duties; some local authorities require
                 * grooming-specific licences). */

            attribute :>> regulatoryShape = RegulatoryShape::locallyLicensed;
            attribute :>> bmmVocabularyScope = BmmVocabularyScope::generalOnly;
            attribute :>> domainPurpose = (DomainPurpose::pedagogicalAnchoring, DomainPurpose::crossDomainValidation);
            attribute :>> jurisdiction = Jurisdiction::england;
            attribute :>> organisationalForm = OrganisationalForm::registeredIndividual;
            attribute :>> authorisationRequiredToTrade = false;
            attribute :>> description = "Pedagogical anchoring and cross-domain validation domain — appointment-based dog grooming. Breed/size surcharges.";
            attribute :>> introducedSession = 43;
            ref :>> domainConfiguration = pawsConfiguration;
        }

        part pawsConfiguration : DomainConfiguration {
            attribute :>> canonicalKey = "paws";
            attribute :>> displayLabel = "Paws";
            attribute :>> fullName = "Paws (Dog Grooming)";
            attribute :>> packageName = "PawsGrooming";
            attribute :>> modelPath = "exercises/paws-demonstrator";
            attribute :>> isActive = true;
            ref :>> domainIdentity = pawsIdentity;
        }

        // --- GSL (GenderSense Limited) ------------------------------

        part gslIdentity : DomainIdentity {
            doc /* Production domain — GenderSense Limited, a private
                 * gender-affirming healthcare service. The primary
                 * motivating use case and first production tenant.
                 * Sector-regulated (CQC). Practitioners hold statutory
                 * professional registrations (GMC, NMC). Authorisation
                 * required to trade (CQC registration is a precondition
                 * to lawful provision). Under A13, GSL is the most
                 * important tenant but still a tenant — not structurally
                 * privileged over demonstrator domains. */

            attribute :>> regulatoryShape = RegulatoryShape::sectorRegulated;
            attribute :>> bmmVocabularyScope = BmmVocabularyScope::production;
            attribute :>> domainPurpose = DomainPurpose::production;
            attribute :>> jurisdiction = Jurisdiction::england;
            attribute :>> regulatedActivities = (RegulatedActivity::treatment, RegulatedActivity::diagnosticAndScreeningProcedures);
            attribute :>> professionalRegistrations = (ProfessionalBody::gmc, ProfessionalBody::nmc);
            attribute :>> organisationalForm = OrganisationalForm::registeredIndividual;
            attribute :>> authorisationRequiredToTrade = true;
            attribute :>> description = "Production domain — GenderSense Limited. Private gender-affirming healthcare service. First production tenant.";
            attribute :>> introducedSession = 8;
            ref :>> domainConfiguration = gslConfiguration;
        }

        part gslConfiguration : DomainConfiguration {
            attribute :>> canonicalKey = "gsl";
            attribute :>> displayLabel = "GSL";
            attribute :>> fullName = "GenderSense Limited";
            attribute :>> packageName = "GenderSense";
            attribute :>> modelPath = "exercises/gendersense";
            attribute :>> isActive = true;
            ref :>> domainIdentity = gslIdentity;
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
