// =========================================================================
// PATTERN CATALOGUE — Cross-domain concept registry
//
// The model describes its own architectural patterns.
//
// Business system meta model concept — this package describes how the
// system is structured, not what the business offers. Placed as a
// top-level package (Syside does not merge same-named packages across
// files, so nesting inside Foundation is not possible). Conceptually
// part of Foundation; structurally a sibling.
//
// Source: Session 26 discussion, Session 29 workstream plan,
//         Session 30 implementation.
// =========================================================================

package PatternCatalogue {
    private import ScalarValues::*;

    doc /* Cross-domain concept registry and architectural pattern
         * catalogue. The model describes its own patterns.
         *
         * Business system meta model concept — this package is
         * itself part of the system meta model (it describes how
         * the system is structured, not what the business offers).
         * Placed as a top-level sibling to Foundation because Syside
         * does not merge same-named packages across files.
         *
         * Two kinds of entries:
         * - Patterns: reusable architectural or business model
         *   templates (e.g. "catalogue-as-UI-contract")
         * - Domain instantiations: where a pattern has been
         *   implemented in a specific domain (e.g. CSW Counter
         *   page, GSL formulary)
         *
         * Source: Session 26 discussion, Sessions 29-30. */

    // -- Classification enums -----------------------------------

    enum def PatternMaturity {
        doc /* Lifecycle stage of a pattern or instantiation. */
        discussion;
        designed;
        implemented;
        validated;
    }

    enum def MetaModelHome {
        doc /* Which meta model a pattern primarily belongs to.
             * Per gsl-architecture-clarification-two-meta-models. */
        business;
        businessSystem;
        crossCutting;
    }

    enum def PatternKind {
        doc /* Whether a pattern has been formalised into a meta
             * model element or exists as architectural guidance. */
        formalised;
        guidance;
    }

    // -- Core type definitions ----------------------------------

    part def Pattern {
        doc /* A reusable architectural or business model template.
             * Domain-agnostic — describes a structural or behavioural
             * approach that applies across domains.
             *
             * The relatedElements attribute uses String references
             * to meta model elements (package paths). If future syntax
             * investigation confirms typed cross-element refs work,
             * these can be upgraded to typed ref links.
             *
             * Source: Session 26 discussion, Session 29 workstream plan. */
        attribute patternName : String;
        attribute description : String;
        attribute maturity : PatternMaturity;
        attribute metaModelClassification : MetaModelHome;
        attribute kind : PatternKind;
        attribute relatedElements : String;
        attribute sourceSession : String;
        attribute validatedIn : String;
    }

    part def DomainInstantiation {
        doc /* A specific implementation of a pattern in a domain.
             * Tracks where a pattern has been built and at what
             * maturity level. Each domain instantiation is separate
             * so maturity can vary per domain. */
        attribute domain : String;
        attribute maturity : PatternMaturity;
        attribute implementationRef : String;
        attribute sessionRef : String;
        attribute notes : String;
    }

    // ================================================================
    // BUSINESS META MODEL PATTERNS
    // ================================================================

    part fourLayerItemModel : Pattern {
        doc /* Item definition, catalogue entry, inventory record,
             * external references. Separates intrinsic properties
             * from business decisions from operational state from
             * external knowledge. */
        attribute :>> patternName = "Four-layer item model";
        attribute :>> description = "Item def to catalogue entry to inventory record to external references. Separates intrinsic properties from business decisions from operational state from external knowledge.";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> metaModelClassification = MetaModelHome::business;
        attribute :>> kind = PatternKind::formalised;
        attribute :>> relatedElements = "BusinessModel::ServiceConcept::CatalogueEntry, BusinessModel::ServiceConcept::ExternalReference, BusinessModel::ResourcePlanning::InventoryRecord";
        attribute :>> sourceSession = "Session 20 (CSW Phase 1)";
        attribute :>> validatedIn = "CSW";
    }

    part activityTaxonomy : Pattern {
        doc /* Five activity categories as a generic classification
             * for any service business. */
        attribute :>> patternName = "Activity taxonomy";
        attribute :>> description = "Five activity categories (clinical, operational, administrative, technical, governance) as a generic classification for any service business.";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> metaModelClassification = MetaModelHome::business;
        attribute :>> kind = PatternKind::formalised;
        attribute :>> relatedElements = "BusinessModel::ActivityModel::ActivityCategory";
        attribute :>> sourceSession = "Session 15 (Business Meta Model Phase 3)";
        attribute :>> validatedIn = "CSW, GSL";
    }

    part scenarioComparisonProjection : Pattern {
        doc /* Two-variant scenario modelling with projection engine
             * and sensitivity analysis. */
        attribute :>> patternName = "Scenario comparison and projection";
        attribute :>> description = "Two-variant scenario modelling with Python projection engine and sensitivity analysis. Compares strategic alternatives quantitatively.";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> metaModelClassification = MetaModelHome::business;
        attribute :>> kind = PatternKind::formalised;
        attribute :>> relatedElements = "BusinessScenarios::ScenarioModelling::ScenarioDefinition, BusinessScenarios::ScenarioModelling::ScenarioComparison";
        attribute :>> sourceSession = "Session 17 (Business Meta Model Phase 5)";
        attribute :>> validatedIn = "GSL";
    }

    part persistencePolicyAsReasoning : Pattern {
        doc /* System carries explicit, auditable rationale for where
             * each domain concept is persisted and why. */
        attribute :>> patternName = "Persistence policy as queryable reasoning";
        attribute :>> description = "System carries explicit, auditable rationale for where each domain concept is persisted. Maps domain concepts to persistence layers with characteristics and justification.";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> metaModelClassification = MetaModelHome::business;
        attribute :>> kind = PatternKind::formalised;
        attribute :>> relatedElements = "Foundation::CommonTypes::PersistencePolicy, Foundation::CommonTypes::PersistenceLayer, Foundation::CommonTypes::DataCharacteristic";
        attribute :>> sourceSession = "Session 20 (CSW Phase 1), formalised Session 29 (Phase 10)";
        attribute :>> validatedIn = "CSW";
    }

    // ================================================================
    // BUSINESS SYSTEM META MODEL PATTERNS
    // ================================================================

    part sysmlAsSingleSourceOfTruth : Pattern {
        doc /* Model generates execution layer. Knowledge lives in
             * the representation layer. */
        attribute :>> patternName = "SysML v2 as single source of truth";
        attribute :>> description = "Model generates execution layer: TypeScript types, XState machines, Temporal workflows, Mermaid diagrams. Knowledge lives in the representation layer.";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> metaModelClassification = MetaModelHome::businessSystem;
        attribute :>> kind = PatternKind::guidance;
        attribute :>> relatedElements = "Foundation::GenerationPipeline";
        attribute :>> sourceSession = "Session 1";
        attribute :>> validatedIn = "CSW, GSL";
    }

    part twoLayerActionFlow : Pattern {
        doc /* Domain-level process description separated from
             * orchestration-level execution detail. */
        attribute :>> patternName = "Two-layer pathway modelling";
        attribute :>> description = "Domain-level process description separated from orchestration-level execution detail. Domain layer for clinical governance; orchestration layer for system execution.";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> metaModelClassification = MetaModelHome::businessSystem;
        attribute :>> kind = PatternKind::formalised;
        attribute :>> relatedElements = "ServiceDelivery::ClinicalPathways, Foundation::MetadataLibrary::TemporalWorkflow";
        attribute :>> sourceSession = "Session 1";
        attribute :>> validatedIn = "CSW, GSL";
    }

    part fiveLayerSelfKnowledge : Pattern {
        doc /* ConstraintEvaluator, OperationalStateAggregator,
             * GoalProjector, GapAnalyser, RemediationPlanner.
             * Domain-agnostic self-assessment architecture. */
        attribute :>> patternName = "Five-layer self-knowledge architecture";
        attribute :>> description = "ConstraintEvaluator, OperationalStateAggregator, GoalProjector, GapAnalyser, RemediationPlanner. Domain-agnostic self-assessment architecture validated as applicable beyond healthcare.";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> metaModelClassification = MetaModelHome::businessSystem;
        attribute :>> kind = PatternKind::formalised;
        attribute :>> relatedElements = "Knowledge::SelfKnowledge";
        attribute :>> sourceSession = "Session 10 (Knowledge Layer Phase 3)";
        attribute :>> validatedIn = "GSL";
    }

    part coffeeshopDemonstratorAsPractice : Pattern {
        doc /* Every new architectural capability gets a coffee shop
             * equivalent before clinical implementation. */
        attribute :>> patternName = "Coffee shop demonstrator as standing validation practice";
        attribute :>> description = "Every new architectural capability gets a coffee shop equivalent before clinical implementation. The demonstrator validates patterns in a simpler domain before committing to clinical complexity.";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> metaModelClassification = MetaModelHome::crossCutting;
        attribute :>> kind = PatternKind::guidance;
        attribute :>> relatedElements = "CoffeeShop (exercises directory)";
        attribute :>> sourceSession = "Session 1";
        attribute :>> validatedIn = "CSW";
    }

    part threeLayerPersistence : Pattern {
        doc /* CDR for clinical data, PostgreSQL for business data,
             * Temporal for process state. */
        attribute :>> patternName = "Three-persistence-layer architecture";
        attribute :>> description = "CDR for clinical data (archetype-validated, versioned), PostgreSQL for business data (CRUD, transactions, joins), Temporal for process state (durable execution). Each layer has distinct characteristics.";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> metaModelClassification = MetaModelHome::businessSystem;
        attribute :>> kind = PatternKind::formalised;
        attribute :>> relatedElements = "Foundation::CommonTypes::PersistenceLayer";
        attribute :>> sourceSession = "Session 20 (CSW Phase 1)";
        attribute :>> validatedIn = "CSW";
    }

    part metadataDrivenGeneration : Pattern {
        doc /* Metadata annotations on model elements drive code
             * generation. The model is the source; generators
             * read metadata. */
        attribute :>> patternName = "Metadata-driven generation";
        attribute :>> description = "Metadata annotations (@TemporalWorkflow, @TemporalActivity, @StateTransitionTrigger, etc.) on model elements drive code generation. Generators read SysML metadata to produce TypeScript, XState, Temporal scaffolds.";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> metaModelClassification = MetaModelHome::businessSystem;
        attribute :>> kind = PatternKind::formalised;
        attribute :>> relatedElements = "Foundation::MetadataLibrary, Foundation::GenerationPipeline";
        attribute :>> sourceSession = "Session 2";
        attribute :>> validatedIn = "CSW, GSL";
    }

    part xstateInTemporal : Pattern {
        doc /* Pure state machine enforcement inside durable
             * workflow execution. */
        attribute :>> patternName = "XState in Temporal";
        attribute :>> description = "Pure state machine enforcement (XState v5) inside durable workflow execution (Temporal). State machine guards clinical/operational transitions; Temporal provides durability and observability.";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> metaModelClassification = MetaModelHome::businessSystem;
        attribute :>> kind = PatternKind::formalised;
        attribute :>> relatedElements = "Foundation::MetadataLibrary::StateTransitionTrigger, Foundation::StatePatterns::EntityLifecycle";
        attribute :>> sourceSession = "Session 3 (CSW Phase C)";
        attribute :>> validatedIn = "CSW";
    }

    part catalogueAsUiContract : Pattern {
        doc /* Domain model attributes drive UI structure directly. */
        attribute :>> patternName = "Catalogue-as-UI-contract";
        attribute :>> description = "Domain model attributes (available sizes, dietary flags, provision type) drive UI structure directly. The catalogue is the contract between the model and the frontend.";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> metaModelClassification = MetaModelHome::businessSystem;
        attribute :>> kind = PatternKind::guidance;
        attribute :>> relatedElements = "CoffeeShop::CatalogueEntry, BusinessModel::ServiceConcept::CatalogueEntry";
        attribute :>> sourceSession = "Session 24 (CSW Phase 5)";
        attribute :>> validatedIn = "CSW";
    }

    part kanbanAsProcessDashboard : Pattern {
        doc /* XState lifecycle states map to kanban columns. */
        attribute :>> patternName = "Kanban-as-process-dashboard";
        attribute :>> description = "XState lifecycle states map to kanban columns. Process state drives operational queue visualisation. Applicable to any entity with a lifecycle.";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> metaModelClassification = MetaModelHome::businessSystem;
        attribute :>> kind = PatternKind::guidance;
        attribute :>> relatedElements = "Foundation::StatePatterns::EntityLifecycle";
        attribute :>> sourceSession = "Session 26 (CSW Phase 7)";
        attribute :>> validatedIn = "CSW";
    }

    part splitViewManagementLayout : Pattern {
        doc /* Main panel plus side panel for operational and
             * management pages. */
        attribute :>> patternName = "Split-view management layout";
        attribute :>> description = "Main panel plus side panel pattern for operational and management pages. Consistent layout across the application.";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> metaModelClassification = MetaModelHome::businessSystem;
        attribute :>> kind = PatternKind::guidance;
        attribute :>> relatedElements = "";
        attribute :>> sourceSession = "Session 25 (CSW Phase 6)";
        attribute :>> validatedIn = "CSW";
    }

    part categoryConditionalFormFields : Pattern {
        doc /* SysML domain model hierarchy drives form structure. */
        attribute :>> patternName = "Category-conditional form fields";
        attribute :>> description = "SysML domain model hierarchy (Drink vs Food specialisations) drives form structure. Category selection determines which fields are shown.";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> metaModelClassification = MetaModelHome::businessSystem;
        attribute :>> kind = PatternKind::guidance;
        attribute :>> relatedElements = "CoffeeShop::Drink, CoffeeShop::FoodItem";
        attribute :>> sourceSession = "Session 24 (CSW Phase 5)";
        attribute :>> validatedIn = "CSW";
    }

    part crossPageDataConsistency : Pattern {
        doc /* Single-source-of-truth via shared API layer. */
        attribute :>> patternName = "Cross-page data consistency";
        attribute :>> description = "Single-source-of-truth via shared API layer. All pages read from the same endpoints, ensuring consistency without client-side state synchronisation.";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> metaModelClassification = MetaModelHome::businessSystem;
        attribute :>> kind = PatternKind::guidance;
        attribute :>> relatedElements = "";
        attribute :>> sourceSession = "Session 24 (CSW Phase 5)";
        attribute :>> validatedIn = "CSW";
    }

    part auditAsTimelineDataSource : Pattern {
        doc /* Audit endpoint provides step-by-step timing for
             * event timeline visualisation. */
        attribute :>> patternName = "Audit-as-timeline data source";
        attribute :>> description = "Governance audit endpoint serves dual purpose: compliance reporting and event timeline for individual entity tracking. Single data source, two presentation modes.";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> metaModelClassification = MetaModelHome::businessSystem;
        attribute :>> kind = PatternKind::guidance;
        attribute :>> relatedElements = "ServiceDelivery::Governance";
        attribute :>> sourceSession = "Session 26 (CSW Phase 7)";
        attribute :>> validatedIn = "CSW";
    }

    part processDomainGovernanceUnifiedView : Pattern {
        doc /* Temporal, XState, and SysML annotations in one page. */
        attribute :>> patternName = "Process + domain + governance unified view";
        attribute :>> description = "Temporal workflow state, XState lifecycle, and SysML domain annotations visible in a single page. Three concerns unified for operational visibility.";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> metaModelClassification = MetaModelHome::businessSystem;
        attribute :>> kind = PatternKind::guidance;
        attribute :>> relatedElements = "ServiceDelivery::ClinicalPathways, Foundation::MetadataLibrary";
        attribute :>> sourceSession = "Session 26 (CSW Phase 7)";
        attribute :>> validatedIn = "CSW";
    }

    part cdrSourceProvenanceBadges : Pattern {
        doc /* Visual badges distinguish CDR entity-view pages
             * from operational pages. */
        attribute :>> patternName = "CDR source provenance badges";
        attribute :>> description = "Indigo badges distinguish CDR entity-view pages from operational/management pages. Data provenance is visually communicated.";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> metaModelClassification = MetaModelHome::businessSystem;
        attribute :>> kind = PatternKind::guidance;
        attribute :>> relatedElements = "";
        attribute :>> sourceSession = "Session 27 (CSW Phase 8)";
        attribute :>> validatedIn = "CSW";
    }

    part autoLoadingEntityViews : Pattern {
        doc /* CDR data loads on page mount, shifting from query
             * tool to operational view. */
        attribute :>> patternName = "Auto-loading entity views";
        attribute :>> description = "CDR data loads on page mount, shifting from query tool to operational view. Entity views are live dashboards, not search interfaces.";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> metaModelClassification = MetaModelHome::businessSystem;
        attribute :>> kind = PatternKind::guidance;
        attribute :>> relatedElements = "";
        attribute :>> sourceSession = "Session 27 (CSW Phase 8)";
        attribute :>> validatedIn = "CSW";
    }

    part infrastructureHealthAsAppConcern : Pattern {
        doc /* System monitors its own persistence layers via a
             * dedicated health endpoint. */
        attribute :>> patternName = "Infrastructure health as application-level concern";
        attribute :>> description = "System monitors its own persistence layers via a dedicated health endpoint. Each service checked independently with response time tracking, using the same client interfaces as data access.";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> metaModelClassification = MetaModelHome::businessSystem;
        attribute :>> kind = PatternKind::guidance;
        attribute :>> relatedElements = "";
        attribute :>> sourceSession = "Session 28 (CSW Phase 9)";
        attribute :>> validatedIn = "CSW";
    }

    part multiSourceMetricsAggregation : Pattern {
        doc /* Aggregation from multiple data sources across
             * persistence layers with graceful degradation. */
        attribute :>> patternName = "Multi-source metrics aggregation with graceful degradation";
        attribute :>> description = "Metrics endpoint aggregates from multiple data sources across persistence layers using Promise.allSettled. Individual source failures do not block the response.";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> metaModelClassification = MetaModelHome::businessSystem;
        attribute :>> kind = PatternKind::guidance;
        attribute :>> relatedElements = "";
        attribute :>> sourceSession = "Session 28 (CSW Phase 9)";
        attribute :>> validatedIn = "CSW";
    }

    part twoLayerModelVisualisation : Pattern {
        doc /* UI makes domain/orchestration distinction visible
             * and interactive. */
        attribute :>> patternName = "Two-layer model visualisation in the UI";
        attribute :>> description = "Process Model page makes the domain/orchestration distinction visible and interactive. Each pathway step links to both its SysML domain action and its Temporal orchestration step.";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> metaModelClassification = MetaModelHome::businessSystem;
        attribute :>> kind = PatternKind::guidance;
        attribute :>> relatedElements = "ServiceDelivery::ClinicalPathways";
        attribute :>> sourceSession = "Session 28 (CSW Phase 9)";
        attribute :>> validatedIn = "CSW";
    }

    part handCraftedSvgForStablePathways : Pattern {
        doc /* When the pathway is stable, a hand-crafted SVG gives
             * better results than generated Mermaid output. */
        attribute :>> patternName = "Hand-crafted SVG for stable pathway diagrams";
        attribute :>> description = "When the pathway is stable (as defined by the SysML model), a hand-crafted SVG themed to the application palette with click handlers gives better results than manipulating generated Mermaid output.";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> metaModelClassification = MetaModelHome::businessSystem;
        attribute :>> kind = PatternKind::guidance;
        attribute :>> relatedElements = "";
        attribute :>> sourceSession = "Session 28 (CSW Phase 9)";
        attribute :>> validatedIn = "CSW";
    }

    // ================================================================
    // DEFERRED / CONCEPTUAL PATTERNS
    // ================================================================

    part compositeOrderOrchestration : Pattern {
        doc /* Single decision triggers concurrent workflows.
             * Deferred in CSW (Session 22). Relates to clinical
             * plan multi-pathway and addictions concurrent referrals. */
        attribute :>> patternName = "Composite order / multi-workflow orchestration";
        attribute :>> description = "Single decision triggers concurrent workflows. One order contains multiple items, each with its own fulfilment workflow. Relates to clinical plan multi-pathway and addictions concurrent referrals.";
        attribute :>> maturity = PatternMaturity::discussion;
        attribute :>> metaModelClassification = MetaModelHome::businessSystem;
        attribute :>> kind = PatternKind::guidance;
        attribute :>> relatedElements = "ServiceDelivery::ClinicalPathways (future multi-pathway)";
        attribute :>> sourceSession = "Session 22 (deferred)";
        attribute :>> validatedIn = "";
    }

    part agencyClassificationOnActions : Pattern {
        doc /* Annotating pathway action nodes with who performs
             * them and at what authority model version. */
        attribute :>> patternName = "Agency classification on pathway actions";
        attribute :>> description = "Annotating pathway action nodes with who performs them (patient, clinician, automated, collaborative) and at what authority model version. Supports generational self-service roadmap.";
        attribute :>> maturity = PatternMaturity::designed;
        attribute :>> metaModelClassification = MetaModelHome::businessSystem;
        attribute :>> kind = PatternKind::formalised;
        attribute :>> relatedElements = "Foundation::MetadataLibrary::AgencyClassification, Foundation::MetadataLibrary::AgencyType";
        attribute :>> sourceSession = "Session 25 (self-service paper), formalised Session 29";
        attribute :>> validatedIn = "";
    }

    part selfAssessmentDashboard : Pattern {
        doc /* Five-layer self-knowledge pattern applied to a
             * system status dashboard. Landing zone built. */
        attribute :>> patternName = "Self-assessment dashboard (KL Increment 3)";
        attribute :>> description = "Five-layer self-knowledge architecture applied to a system status dashboard. Landing zone built in CSW System Status page. Implementation not started.";
        attribute :>> maturity = PatternMaturity::designed;
        attribute :>> metaModelClassification = MetaModelHome::businessSystem;
        attribute :>> kind = PatternKind::formalised;
        attribute :>> relatedElements = "Knowledge::SelfKnowledge";
        attribute :>> sourceSession = "Session 10 (KL Phase 3), landing zone Session 28";
        attribute :>> validatedIn = "";
    }

    part optionEvaluatorHelpMeChoose : Pattern {
        doc /* Informed Choice Engine — OptionEvaluator presenting
             * personalised recommendations with reasoning. */
        attribute :>> patternName = "OptionEvaluator / Help Me Choose";
        attribute :>> description = "Informed Choice Engine presenting personalised recommendations with reasoning. Supports Generation 3 self-service. Designed but not implemented.";
        attribute :>> maturity = PatternMaturity::designed;
        attribute :>> metaModelClassification = MetaModelHome::businessSystem;
        attribute :>> kind = PatternKind::guidance;
        attribute :>> relatedElements = "Knowledge::DecisionModels";
        attribute :>> sourceSession = "Session 25 (self-service paper)";
        attribute :>> validatedIn = "";
    }

    part dataReleaseModel : Pattern {
        doc /* Patient-facing data release model for CoPHR and
             * self-service access. Discussion stage. */
        attribute :>> patternName = "Data release model (patient-facing)";
        attribute :>> description = "Patient-facing data release model for CoPHR and self-service access. How the system decides what data to share with patients, at what level of detail, with what explanation.";
        attribute :>> maturity = PatternMaturity::discussion;
        attribute :>> metaModelClassification = MetaModelHome::businessSystem;
        attribute :>> kind = PatternKind::guidance;
        attribute :>> relatedElements = "";
        attribute :>> sourceSession = "Session 25 (self-service paper section 12.2)";
        attribute :>> validatedIn = "";
    }

    part notificationTriggersOnTransitions : Pattern {
        doc /* State transitions fire notification events.
             * Discussion stage. */
        attribute :>> patternName = "Notification triggers on state transitions";
        attribute :>> description = "State transitions in entity lifecycles fire notification events. Patients, clinicians, or systems can subscribe to relevant transitions.";
        attribute :>> maturity = PatternMaturity::discussion;
        attribute :>> metaModelClassification = MetaModelHome::businessSystem;
        attribute :>> kind = PatternKind::guidance;
        attribute :>> relatedElements = "Foundation::StatePatterns::EntityLifecycle, Foundation::MetadataLibrary::StateTransitionTrigger";
        attribute :>> sourceSession = "Identified across sessions";
        attribute :>> validatedIn = "";
    }

    // ================================================================
    // DOMAIN INSTANTIATIONS
    // ================================================================

    // -- Four-layer item model instantiations -------------------

    part cswFourLayerItemModel : DomainInstantiation {
        attribute :>> domain = "CSW";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> implementationRef = "CoffeeShop::MenuItem, CoffeeShop::CatalogueEntry, CoffeeShop::InventoryRecord, CoffeeShop::ExternalReference. Counter page, Manager GUI, Records page.";
        attribute :>> sessionRef = "Sessions 20-25";
        attribute :>> notes = "Full four-layer model implemented. 11 menu items, 4 PostgreSQL tables, CRUD API.";
    }

    part gslFourLayerItemModel : DomainInstantiation {
        attribute :>> domain = "GSL";
        attribute :>> maturity = PatternMaturity::discussion;
        attribute :>> implementationRef = "";
        attribute :>> sessionRef = "Identified Session 20";
        attribute :>> notes = "Clinical analogue: Medication to FormularyEntry to ClinicalStock to BNF/SPC references. Not yet modelled.";
    }

    // -- Two-layer action flow instantiations -------------------

    part cswTwoLayerActionFlow : DomainInstantiation {
        attribute :>> domain = "CSW";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> implementationRef = "drink-fulfilment.sysml (domain), fulfil-drink-orchestration.sysml (orchestration). FulfilDrink Temporal workflow.";
        attribute :>> sessionRef = "Sessions 1-3";
        attribute :>> notes = "Domain flow: 8 action nodes. Orchestration flow: XState lifecycle with signal/timeout metadata.";
    }

    part gslTwoLayerActionFlow : DomainInstantiation {
        attribute :>> domain = "GSL";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> implementationRef = "ServiceDelivery::ClinicalPathways::HormoneTherapyInitiation (domain). Orchestration layer designed but not generated.";
        attribute :>> sessionRef = "Sessions 5-7";
        attribute :>> notes = "Clinical pathway: assessment, consent, prescribing, monitoring. Orchestration designed but not yet implemented as a Temporal workflow.";
    }

    // -- Catalogue-as-UI-contract instantiations ----------------

    part cswCatalogueAsUiContract : DomainInstantiation {
        attribute :>> domain = "CSW";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> implementationRef = "Counter page — dynamic form driven by catalogue attributes (availableSizes, dietaryFlags, provisionType).";
        attribute :>> sessionRef = "Session 24 (CSW Phase 5)";
        attribute :>> notes = "Category-conditional form fields. Domain model hierarchy drives form structure.";
    }

    part gslCatalogueAsUiContract : DomainInstantiation {
        attribute :>> domain = "GSL";
        attribute :>> maturity = PatternMaturity::discussion;
        attribute :>> implementationRef = "";
        attribute :>> sessionRef = "";
        attribute :>> notes = "Clinical analogue: Patient portal order screen driven by formulary attributes (eligible medications, dosage options, monitoring requirements).";
    }

    // -- Three-layer persistence instantiations -----------------

    part cswThreeLayerPersistence : DomainInstantiation {
        attribute :>> domain = "CSW";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> implementationRef = "EHRbase (orders, prep, feedback), PostgreSQL (menu items, catalogue, inventory, external refs), Temporal (FulfilDrink workflow).";
        attribute :>> sessionRef = "Sessions 1-4, 21-22";
        attribute :>> notes = "All three layers operational. 6 PersistencePolicy instances document the rationale.";
    }

    part gslThreeLayerPersistence : DomainInstantiation {
        attribute :>> domain = "GSL";
        attribute :>> maturity = PatternMaturity::designed;
        attribute :>> implementationRef = "Architecture designed. CDR for patient records, PostgreSQL for service management, Temporal for clinical pathways.";
        attribute :>> sessionRef = "Sessions 5-7 (clinical), Sessions 13-19 (business model)";
        attribute :>> notes = "Pattern validated in CSW. GSL will use the same three-layer architecture with clinical-specific content.";
    }

    // -- Five-layer self-knowledge instantiations ---------------

    part gslFiveLayerSelfKnowledge : DomainInstantiation {
        attribute :>> domain = "GSL";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> implementationRef = "Knowledge::SelfKnowledge — GoalProjector, OperationalStateAggregator, GapAnalyser, ExplanationTrace. Python projection engine.";
        attribute :>> sessionRef = "Sessions 8-12 (Knowledge Layer Elaboration)";
        attribute :>> notes = "Five-layer architecture validated as domain-agnostic. Knowledge layer generators designed.";
    }

    part cswFiveLayerSelfKnowledge : DomainInstantiation {
        attribute :>> domain = "CSW";
        attribute :>> maturity = PatternMaturity::designed;
        attribute :>> implementationRef = "System Status page — placeholder panel for KL Increment 3.";
        attribute :>> sessionRef = "Session 28 (CSW Phase 9)";
        attribute :>> notes = "Landing zone built. Implementation (KL Increment 3) is a candidate next workstream.";
    }

    // -- Kanban-as-process-dashboard instantiation ---------------

    part cswKanbanAsProcessDashboard : DomainInstantiation {
        attribute :>> domain = "CSW";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> implementationRef = "Order Board page — kanban columns by XState lifecycle state (Placed, In Preparation, Ready, Collected, Cancelled).";
        attribute :>> sessionRef = "Session 26 (CSW Phase 7)";
        attribute :>> notes = "Historical orders in filterable table below kanban.";
    }

    // -- SysML as single source of truth instantiations ----------

    part cswSysmlAsSingleSourceOfTruth : DomainInstantiation {
        attribute :>> domain = "CSW";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> implementationRef = "4 generators: TypeScript types, XState machines, Temporal workflows, Mermaid diagrams. All derived from coffeeshop.sysml domain model.";
        attribute :>> sessionRef = "Sessions 1-4";
        attribute :>> notes = "Full generation pipeline operational. Model changes propagate to running code.";
    }

    part gslSysmlAsSingleSourceOfTruth : DomainInstantiation {
        attribute :>> domain = "GSL";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> implementationRef = "Same 4 generators applicable. Clinical pathway model generates Mermaid diagrams. Projection engine reads model parameters.";
        attribute :>> sessionRef = "Sessions 5-12";
        attribute :>> notes = "Generators validated on clinical domain model. Full pipeline not yet exercised end-to-end for GSL.";
    }

    // -- Metadata-driven generation instantiations --------------

    part cswMetadataDrivenGeneration : DomainInstantiation {
        attribute :>> domain = "CSW";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> implementationRef = "@TemporalWorkflow, @TemporalActivity, @TemporalSignal, @StateTransitionTrigger on orchestration actions. gen_temporal_workflow.py and gen_state_machines.py read these.";
        attribute :>> sessionRef = "Sessions 2-3";
        attribute :>> notes = "Metadata annotations drive TypeScript workflow scaffold and XState machine generation.";
    }

    // -- XState in Temporal instantiation ------------------------

    part cswXstateInTemporal : DomainInstantiation {
        attribute :>> domain = "CSW";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> implementationRef = "FulfilDrink Temporal workflow with XState v5 OrderLifecycle state machine. State machine guards transitions; Temporal provides durability.";
        attribute :>> sessionRef = "Session 3 (CSW Phase C)";
        attribute :>> notes = "Single workflow operational. State machine generated from SysML state def.";
    }

    // -- Split-view management layout instantiation --------------

    part cswSplitViewManagementLayout : DomainInstantiation {
        attribute :>> domain = "CSW";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> implementationRef = "Manager GUI (Phase 6), Order Board (Phase 7), Records (Phase 8). Main panel + side panel layout.";
        attribute :>> sessionRef = "Sessions 25-27";
        attribute :>> notes = "Consistent layout pattern across operational and management pages.";
    }

    // -- Category-conditional form fields instantiation ----------

    part cswCategoryConditionalFormFields : DomainInstantiation {
        attribute :>> domain = "CSW";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> implementationRef = "Counter page — Drink vs Food category determines visible form fields (sizes/milk/caffeinated vs gluten-free/served-warm).";
        attribute :>> sessionRef = "Session 24 (CSW Phase 5)";
        attribute :>> notes = "Domain model hierarchy (Drink :> MenuItem, FoodItem :> MenuItem) drives form structure.";
    }

    // -- Cross-page data consistency instantiation ---------------

    part cswCrossPageDataConsistency : DomainInstantiation {
        attribute :>> domain = "CSW";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> implementationRef = "All 9 pages read from shared API layer. Counter, Manager GUI, Order Board, Records all show consistent catalogue/order data.";
        attribute :>> sessionRef = "Sessions 24-28";
        attribute :>> notes = "No client-side state synchronisation. Single source of truth via API.";
    }

    // -- Audit-as-timeline instantiation -------------------------

    part cswAuditAsTimeline : DomainInstantiation {
        attribute :>> domain = "CSW";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> implementationRef = "Order Timeline page — governance audit endpoint provides step-by-step timing for event timeline. Same endpoint serves Audit Dashboard for compliance reporting.";
        attribute :>> sessionRef = "Session 26 (CSW Phase 7)";
        attribute :>> notes = "Single data source, two presentation modes: individual timeline and population compliance.";
    }

    // -- Process + domain + governance unified view instantiation -

    part cswProcessDomainGovernanceUnified : DomainInstantiation {
        attribute :>> domain = "CSW";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> implementationRef = "Order Timeline page — Temporal workflow state, XState lifecycle, SysML domain annotations visible in a single page.";
        attribute :>> sessionRef = "Session 26 (CSW Phase 7)";
        attribute :>> notes = "Three concerns unified for operational visibility.";
    }

    // -- CDR source provenance badges instantiation --------------

    part cswCdrProvenanceBadges : DomainInstantiation {
        attribute :>> domain = "CSW";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> implementationRef = "Records page, Order Detail page — indigo badges distinguish CDR entity-view data from operational/management data.";
        attribute :>> sessionRef = "Session 27 (CSW Phase 8)";
        attribute :>> notes = "Data provenance visually communicated.";
    }

    // -- Auto-loading entity views instantiation -----------------

    part cswAutoLoadingEntityViews : DomainInstantiation {
        attribute :>> domain = "CSW";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> implementationRef = "Records page — CDR data loads on page mount. Entity views are live dashboards, not search interfaces.";
        attribute :>> sessionRef = "Session 27 (CSW Phase 8)";
        attribute :>> notes = "Shift from query tool to operational view pattern.";
    }

    // -- Infrastructure health instantiation ---------------------

    part cswInfrastructureHealth : DomainInstantiation {
        attribute :>> domain = "CSW";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> implementationRef = "System Status page + GET /api/system/health. Pings EHRbase (AQL), PostgreSQL (SELECT 1), Temporal (workflow.list) independently.";
        attribute :>> sessionRef = "Session 28 (CSW Phase 9)";
        attribute :>> notes = "Each service checked independently with response time tracking.";
    }

    // -- Multi-source metrics instantiation ----------------------

    part cswMultiSourceMetrics : DomainInstantiation {
        attribute :>> domain = "CSW";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> implementationRef = "System Status page + GET /api/system/metrics. Aggregates from 7 data sources across 3 persistence layers via Promise.allSettled.";
        attribute :>> sessionRef = "Session 28 (CSW Phase 9)";
        attribute :>> notes = "Individual source failures do not block the response.";
    }

    // -- Two-layer model visualisation instantiation -------------

    part cswTwoLayerModelVisualisation : DomainInstantiation {
        attribute :>> domain = "CSW";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> implementationRef = "Process Model page — interactive SVG with click-to-modal showing domain layer, orchestration layer, and clinical analogy per step.";
        attribute :>> sessionRef = "Session 28 (CSW Phase 9)";
        attribute :>> notes = "Makes the domain/orchestration distinction visible and interactive in the UI.";
    }

    // -- Hand-crafted SVG instantiation --------------------------

    part cswHandCraftedSvg : DomainInstantiation {
        attribute :>> domain = "CSW";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> implementationRef = "Process Model page — 8 nodes, 9 edges, themed to coffee shop palette. Click handlers per node. Replaced generated Mermaid.";
        attribute :>> sessionRef = "Session 28 (CSW Phase 9)";
        attribute :>> notes = "Better interactivity and theming control than Mermaid for stable pathways.";
    }

    // -- Activity taxonomy instantiations -----------------------

    part cswActivityTaxonomy : DomainInstantiation {
        attribute :>> domain = "CSW";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> implementationRef = "CoffeeShopBusinessModel — 6 ActivityType usages across all 5 categories. ActivityGranularity policy per business area.";
        attribute :>> sessionRef = "Session 14, extended Session 20";
        attribute :>> notes = "Full five-category taxonomy instantiated for a simple service business.";
    }

    part gslActivityTaxonomy : DomainInstantiation {
        attribute :>> domain = "GSL";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> implementationRef = "BusinessModel::ActivityModel — ActivityCategory enum, ActivityType part def. Clinical activity types.";
        attribute :>> sessionRef = "Session 15 (Business Meta Model Phase 3)";
        attribute :>> notes = "Activity taxonomy designed as domain-agnostic from the start.";
    }

    // -- Scenario comparison instantiation -----------------------

    part gslScenarioComparison : DomainInstantiation {
        attribute :>> domain = "GSL";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> implementationRef = "BusinessScenarios package — Lean Clinical vs Full Platform. Python projection engine with sensitivity analysis.";
        attribute :>> sessionRef = "Sessions 17-18 (Business Meta Model Phases 5-6)";
        attribute :>> notes = "Two-variant comparison with 24-month projections and break-even analysis.";
    }

    part cswScenarioComparison : DomainInstantiation {
        attribute :>> domain = "CSW";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> implementationRef = "CoffeeshopScenarios package — Small Kiosk vs Full Cafe vs Subscription. Growth assumptions, variance analysis, steering cycle.";
        attribute :>> sessionRef = "Sessions 16-19";
        attribute :>> notes = "Full scenario modelling including PeriodActuals, VarianceAnalysis, and GoalProjection.";
    }

    // -- Persistence policy instantiation ------------------------

    part cswPersistencePolicy : DomainInstantiation {
        attribute :>> domain = "CSW";
        attribute :>> maturity = PatternMaturity::validated;
        attribute :>> implementationRef = "CoffeeShopBusinessModel — 6 PersistencePolicy instances mapping domain concepts to persistence layers with rationale.";
        attribute :>> sessionRef = "Session 29 (CSW Phase 10)";
        attribute :>> notes = "Architectural reasoning queryable and auditable.";
    }
}
