// =========================================================================
// ARCHITECTURAL STRUCTURE — Sections of the dual-stack architecture
// =========================================================================
//
// PROVISIONAL PACKAGE PLACEMENT. This package describes the structural
// regions of the Ontara dual-stack architecture. It is SMM content
// (A4 — two meta model distinction: architectural sections describe
// the system architecture, not the business). Placed as a top-level
// package provisionally, pending SMM vocabulary elaboration (B8).
// When the SMM package structure is designed, this content moves
// to its proper home.
//
// Source: ontara-discussion-architectural-section-implementation-
//   design-2026-03-29.md (Session 86)
// Content: ontara-discussion-architectural-campus-walk-2026-03-28.md
//   (Sessions 84–85)
// Register concept: B27 (architectural section)
// Session: 87
// =========================================================================

package ArchitecturalStructure {
    private import ScalarValues::*;
    private import Foundation::MetadataLibrary::*;
    private import Foundation::CommonTypes::*;

    doc /* Architectural sections of the dual-stack architecture (B27).
         * Each section is a bounded region with a characteristic
         * purpose, representational formalism, persistence mechanism,
         * and set of interfaces to neighbouring sections.
         *
         * 20 sections across six architectural groups: shared
         * foundation, left stack (business model), right stack
         * (business system model), cross-cutting, rules and
         * constraints container, and infrastructure.
         *
         * Single part def, 20 instances — the sections share the
         * same structural shape (I9: part def / part distinction).
         * Name-based identity; ordering is a presentation concern.
         *
         * System meta model concept.
         * Provisional package placement pending SMM elaboration (B8).
         * Session 87. */

    // -----------------------------------------------------------------
    // Enumerations
    // -----------------------------------------------------------------

    enum def ArchitecturalGroup {
        doc /* Position of a section within the dual-stack architecture.
             * Six groups reflecting structural role.
             *
             * System meta model concept.
             * Architectural section (B27). Session 87. */
        sharedFoundation;
        leftStack;
        rightStack;
        crossCutting;
        rulesAndConstraintsContainer;
        infrastructure;
    }

    enum def Formalism {
        doc /* Primary representational formalism used in a section.
             *
             * System meta model concept.
             * Architectural section (B27). Session 87. */
        owl2dl;
        sysmlV2;
        runtime;
        mixed;
    }

    enum def ImplementationStatus {
        doc /* Current implementation status of a section.
             * implemented: built and operational.
             * designed: architecturally specified, not yet built.
             * referenced: acknowledged in the architecture, no
             *   detailed design yet.
             * notStarted: identified but no work done.
             *
             * System meta model concept.
             * Architectural section (B27). Session 87. */
        implemented;
        designed;
        referenced;
        notStarted;
    }

    // -----------------------------------------------------------------
    // Metadata definition
    // -----------------------------------------------------------------

    metadata def ArchitecturalLocation {
        doc /* Architectural characterisation metadata for sections
             * of the dual-stack architecture. Carries the four
             * additional facets beyond purpose (which is carried
             * by @PurposiveDescription).
             *
             * Each attribute is a short summary (one to two
             * sentences). Full prose lives in the Obsidian vault,
             * linked via the docKey attribute on the part def.
             * Model-as-index / vault-as-body pattern (E017).
             *
             * Complements @PurposiveDescription (purpose facet),
             * @UserFacing (friendly name and tooltip), and
             * @Comprehension (traversal instructions).
             *
             * System meta model concept.
             * Intrinsic self-knowledge (A10). Unity principle (A11).
             * Architectural section (B27). E016.
             * Session 87. */
        attribute representationalModalitySummary : String;
        attribute persistenceSummary : String;
        attribute interfacesSummary : String;
        attribute domainIllustrationSummary : String;
    }

    // -----------------------------------------------------------------
    // Part definition
    // -----------------------------------------------------------------

    part def ArchitecturalSection {
        doc /* A bounded region of the dual-stack architecture with
             * a characteristic purpose, representational formalism,
             * persistence mechanism, and set of interfaces to
             * neighbouring sections.
             *
             * 20 sections identified across the architecture.
             * Name-based identity (kebab-case identifiers stored
             * in the name attribute); ordering is a presentation
             * concern (presentationOrder attribute).
             *
             * Descriptive metadata carried by @PurposiveDescription
             * (purpose facet) and @ArchitecturalLocation (four
             * additional facets). Full prose in the vault linked
             * via docKey (model-as-index pattern, E017).
             *
             * System meta model concept.
             * Register: B27 (architectural section).
             * Design: ontara-discussion-architectural-section-
             *   implementation-design-2026-03-29.md
             * Content: ontara-discussion-architectural-campus-
             *   walk-2026-03-28.md
             * Session 87. */
        attribute name : String;
        attribute displayName : String;
        attribute group : ArchitecturalGroup;
        attribute presentationOrder : Integer;
        attribute primaryFormalism : Formalism;
        attribute persistenceMechanism : String;
        attribute implementationStatus : ImplementationStatus;
        attribute docKey : String;
    }

    // =================================================================
    // SHARED FOUNDATION
    // =================================================================

    // Section 1: BFO (Basic Formal Ontology)

    @UserFacing {
        friendlyName = "BFO (Basic Formal Ontology)";
        shortDescription = "The shared upper ontology spanning both stacks, providing the categorical framework for everything in the architecture.";
    }
    @PurposiveDescription {
        description = "The shared foundation spanning both stacks. BFO is an ISO standard upper ontology providing the categorical framework — Continuant, Occurrent, Role, Disposition, Quality, Function — that classifies everything in the architecture. Every entity in every layer traces upward to a BFO category. BFO determines valid reasoning patterns: what can bear a Role, what can participate in a Process, what is a Quality of what.";
    }
    @ArchitecturalLocation {
        representationalModalitySummary = "OWL 2 DL. Imported directly from the OBO Foundry as a maintained external ontology.";
        persistenceSummary = "Triple store (knowledge graph). BFO 2020 loaded into GraphDB (Session 101) as the foundational upper ontology.";
        interfacesSummary = "Vertical downward to both domain ontologies (left stack) and system ontological categories (right stack). Spans both stacks as a shared foundation; does not connect horizontally.";
        domainIllustrationSummary = "For Paws: Sam is a BFO Continuant bearing a Role; a ServiceOffering is an Occurrent; a Room is an Independent Continuant; a PricingRule is a Generically Dependent Continuant.";
    }
    part bfo : ArchitecturalSection {
        attribute :>> name = "bfo";
        attribute :>> displayName = "BFO (Basic Formal Ontology)";
        attribute :>> group = ArchitecturalGroup::sharedFoundation;
        attribute :>> presentationOrder = 1;
        attribute :>> primaryFormalism = Formalism::owl2dl;
        attribute :>> persistenceMechanism = "triple-store";
        attribute :>> implementationStatus = ImplementationStatus::implemented;
        attribute :>> docKey = "bfo";
    }

    // =================================================================
    // LEFT STACK — BUSINESS MODEL
    // =================================================================

    // Section 2: Domain Ontologies

    @UserFacing {
        friendlyName = "Domain Ontologies";
        shortDescription = "Mid-level BFO-aligned ontologies providing tenant-specific semantic grounding between BFO and the BMM vocabulary.";
    }
    @PurposiveDescription {
        description = "Mid-level BFO-aligned ontologies providing domain-specific semantic grounding between BFO's abstract categories and the BMM's structural vocabulary. The selection of domain ontologies during tenant onboarding gives each tenant its semantic character — healthcare tenants use OGMS and GSSO; commercial tenants use OCE. All use IAO for information entities.";
    }
    @ArchitecturalLocation {
        representationalModalitySummary = "OWL 2 DL. Existing OBO Foundry ontologies, imported directly.";
        persistenceSummary = "Triple store (knowledge graph), alongside BFO. CCO and IAO loaded into GraphDB (Session 101).";
        interfacesSummary = "Vertical downward to BMM General vocabulary. Vertical upward to BFO. Horizontal rightward to system ontological categories — the topmost horizontal mapping.";
        domainIllustrationSummary = "For Paws: OCE (Ontology of Commercial Enterprises) as primary domain ontology. For GSL: OGMS+GSSO+IAO — same BMM structure, fundamentally different semantic grounding.";
    }
    part domainOntologies : ArchitecturalSection {
        attribute :>> name = "domain-ontologies";
        attribute :>> displayName = "Domain Ontologies";
        attribute :>> group = ArchitecturalGroup::leftStack;
        attribute :>> presentationOrder = 2;
        attribute :>> primaryFormalism = Formalism::owl2dl;
        attribute :>> persistenceMechanism = "triple-store";
        attribute :>> implementationStatus = ImplementationStatus::implemented;
        attribute :>> docKey = "domain-ontologies";
    }

    // Section 3: BMM General Vocabulary

    @UserFacing {
        friendlyName = "BMM General Vocabulary";
        shortDescription = "The 34 domain-neutral structural templates defining what a service business is, across six concerns.";
    }
    @PurposiveDescription {
        description = "The classification engine for the business side. 34 part defs across six concerns defining the structural templates for what a service business is. Raw business information is mapped to these templates. The BMM General vocabulary is domain-neutral — the same part defs apply to a dog grooming salon, a coffee shop, and a gender identity clinic. This is the level at which cross-domain validation operates.";
    }
    @ArchitecturalLocation {
        representationalModalitySummary = "SysML v2 part defs. The most mature section — 34 part defs with full comprehension metadata (34/34 UserFacing, PurposiveDescription, Comprehension; 96 WeightedRelationship).";
        persistenceSummary = "Currently: .sysml files in the git repository. Target: knowledge graph (canonical) with SysML v2 files as projection.";
        interfacesSummary = "Vertical downward: instantiated by the business instance layer. Vertical upward: traces through domain ontologies to BFO. Horizontal rightward: many-to-many mapping to SMM General vocabulary.";
        domainIllustrationSummary = "For Paws: exclusively General vocabulary — 34 part defs provide the structural skeleton for all service offerings, staff, facilities, pricing, and stakeholder relationships.";
    }
    part bmmGeneralVocabulary : ArchitecturalSection {
        attribute :>> name = "bmm-general-vocabulary";
        attribute :>> displayName = "BMM General Vocabulary";
        attribute :>> group = ArchitecturalGroup::leftStack;
        attribute :>> presentationOrder = 3;
        attribute :>> primaryFormalism = Formalism::sysmlV2;
        attribute :>> persistenceMechanism = "sysml-files";
        attribute :>> implementationStatus = ImplementationStatus::implemented;
        attribute :>> docKey = "bmm-general-vocabulary";
    }

    // Section 4: Business Instance

    @UserFacing {
        friendlyName = "Business Instance";
        shortDescription = "The concrete populated data for a specific tenant — part usages instantiating BMM part defs.";
    }
    @PurposiveDescription {
        description = "The concrete populated data for a specific tenant. Where the BMM General vocabulary provides structural templates (part defs), the business instance provides the actual content (part usages). Relation binding happens here: entities are stitched together by confirming typed relations. The user has the most agency at this layer — convention-over-configuration narrows the space of valid connections.";
    }
    @ArchitecturalLocation {
        representationalModalitySummary = "SysML v2 part usages instantiating BMM part defs. Per-domain .sysml files in the exercises directory.";
        persistenceSummary = "Currently: .sysml files. Target: knowledge graph (canonical) — business instance data as OWL individuals.";
        interfacesSummary = "Vertical downward to operational domains. Vertical upward: every instance is an instantiation of a BMM General concept. Horizontal rightward to system instance — the realised-by relationship.";
        domainIllustrationSummary = "For Paws: 5 ServiceOfferings, 3 StaffMembers, 6 Rooms, PricingRule matrix, 10 CostCategories, 7 StakeholderModel instantiations, and all typed relations binding them together.";
    }
    part businessInstance : ArchitecturalSection {
        attribute :>> name = "business-instance";
        attribute :>> displayName = "Business Instance";
        attribute :>> group = ArchitecturalGroup::leftStack;
        attribute :>> presentationOrder = 4;
        attribute :>> primaryFormalism = Formalism::sysmlV2;
        attribute :>> persistenceMechanism = "sysml-files";
        attribute :>> implementationStatus = ImplementationStatus::implemented;
        attribute :>> docKey = "business-instance";
    }

    // Section 5: Operational Domains

    @UserFacing {
        friendlyName = "Operational Domains";
        shortDescription = "How the business actually operates, in business language — the operational areas that emerge from the business instance.";
    }
    @PurposiveDescription {
        description = "How the business actually operates — in business language, not system language. The Session 73 correction: these are business model content, not system descriptions. They describe how the business operates and inform what systems are needed, but they remain squarely on the business model side. Currently partially implicit — they emerge from walking the relation graph in the instance layer.";
    }
    @ArchitecturalLocation {
        representationalModalitySummary = "SysML v2. Currently partially implicit — operational domains emerge from the instance layer but are not explicitly modelled as distinct packages.";
        persistenceSummary = "Currently: implicit in the instance layer structure. Target: explicit in the knowledge graph and/or SysML model.";
        interfacesSummary = "Vertical downward to business process patterns. Vertical upward: emerges from the business instance. Horizontal rightward to system domains. Inside the rules and constraints container.";
        domainIllustrationSummary = "For Paws: nine operational domains — Booking, Scheduling, Finance, Customer Management, Inventory, Compliance, Reporting, Marketing, and Document Management — each in Sam's language.";
    }
    part operationalDomains : ArchitecturalSection {
        attribute :>> name = "operational-domains";
        attribute :>> displayName = "Operational Domains";
        attribute :>> group = ArchitecturalGroup::leftStack;
        attribute :>> presentationOrder = 5;
        attribute :>> primaryFormalism = Formalism::sysmlV2;
        attribute :>> persistenceMechanism = "implicit";
        attribute :>> implementationStatus = ImplementationStatus::designed;
        attribute :>> docKey = "operational-domains";
    }

    // Section 6: Business Process Patterns

    @UserFacing {
        friendlyName = "Business Process Patterns";
        shortDescription = "Dynamic behaviour and flows at three abstraction levels — archetypes, BMM-parameterised patterns, and domain-specific instances.";
    }
    @PurposiveDescription {
        description = "The most dynamic layer of the left stack. Process patterns operate at three abstraction levels: universal archetypes (Resource Allocation, Scheduling, Fulfilment, etc.), BMM-parameterised patterns, and domain-specific instances. This is the crossing point — business process patterns compile to executable artefacts on the right stack through the process specification layer pipeline.";
    }
    @ArchitecturalLocation {
        representationalModalitySummary = "SysML v2 for archetype and pattern definitions. Process sketch DSL (proposed) for human-readable instances. Currently: described in discussion papers; not yet formally modelled.";
        persistenceSummary = "Currently: discussion papers only. Target: knowledge graph (canonical) with SysML v2 as projection.";
        interfacesSummary = "Vertical upward: parameterised by BMM vocabulary. Horizontal rightward: the pipeline crossing — executed as operational simulation workflows. Inside the rules and constraints container.";
        domainIllustrationSummary = "For Paws: Resource Allocation (room to groom), Scheduling (appointment booking), Transaction (payment), Fulfilment (deliver groom), Replenishment (reorder shampoo) — each determined by typed relations in the instance.";
    }
    part businessProcessPatterns : ArchitecturalSection {
        attribute :>> name = "business-process-patterns";
        attribute :>> displayName = "Business Process Patterns";
        attribute :>> group = ArchitecturalGroup::leftStack;
        attribute :>> presentationOrder = 6;
        attribute :>> primaryFormalism = Formalism::sysmlV2;
        attribute :>> persistenceMechanism = "discussion-papers";
        attribute :>> implementationStatus = ImplementationStatus::designed;
        attribute :>> docKey = "business-process-patterns";
    }

    // =================================================================
    // RIGHT STACK — BUSINESS SYSTEM MODEL
    // =================================================================

    // Section 7: System Ontological Categories

    @UserFacing {
        friendlyName = "System Ontological Categories";
        shortDescription = "BFO-typed categories classifying what kinds of things can exist in a business system — the right-stack counterpart of domain ontologies.";
    }
    @PurposiveDescription {
        description = "The right-stack counterpart of the domain ontologies. Classifies system entities using BFO: a workflow is a Process (Occurrent), a data record is an Information Content Entity (Continuant via IAO), an event is an Occurrent with instantaneous temporal extent, a system state is a Quality. These are not arbitrary labels — they are BFO-typed, enabling ontological consistency checking between system and business entities.";
    }
    @ArchitecturalLocation {
        representationalModalitySummary = "OWL 2 DL — ontological categories above the formalism boundary. Not yet implemented.";
        persistenceSummary = "Target: triple store (knowledge graph) as named classes and axioms. Currently: exists only in discussion papers.";
        interfacesSummary = "Vertical downward: classifies everything in the SMM General vocabulary. Vertical upward to BFO. Horizontal leftward: mapping to domain ontologies — the topmost horizontal mapping constraining what system entities can realise which business entities.";
        domainIllustrationSummary = "For Paws: a BookingWorkflow is a Process; a GroomingRecord is an Information Content Entity; a PaymentReceivedEvent is a Process Boundary; a RoomAvailabilityState is a Quality.";
    }
    part systemOntologicalCategories : ArchitecturalSection {
        attribute :>> name = "system-ontological-categories";
        attribute :>> displayName = "System Ontological Categories";
        attribute :>> group = ArchitecturalGroup::rightStack;
        attribute :>> presentationOrder = 7;
        attribute :>> primaryFormalism = Formalism::owl2dl;
        attribute :>> persistenceMechanism = "triple-store";
        attribute :>> implementationStatus = ImplementationStatus::referenced;
        attribute :>> docKey = "system-ontological-categories";
    }

    // Section 8: SMM General Vocabulary

    @UserFacing {
        friendlyName = "SMM General Vocabulary";
        shortDescription = "Domain-neutral system concepts organised into six capability groups — the right-stack counterpart of the BMM vocabulary.";
    }
    @PurposiveDescription {
        description = "The right-stack counterpart of the BMM General vocabulary. Defines what a business system is — the domain-neutral system concepts any Ontara tenant would need. Organised into six capability groups (B25): Persistence and Data Management, Process Orchestration, Evaluation and Reasoning, Observation and Self-Knowledge, Integration and Communication, Identity and Access. Horizontal mappings to the BMM are many-to-many.";
    }
    @ArchitecturalLocation {
        representationalModalitySummary = "SysML v2 part defs. Designed (Session 76 discussion paper) but not yet implemented. Individual concepts exist scattered across Foundation, Knowledge, ServiceDelivery, Platform, and Operations.";
        persistenceSummary = "Target: knowledge graph (canonical) with SysML v2 as projection. Currently: distributed across existing SysML packages without explicit SMM organisation.";
        interfacesSummary = "Vertical downward: instantiated by the system instance. Vertical upward: traces to system ontological categories. Horizontal leftward: explicit many-to-many mappings to BMM General vocabulary.";
        domainIllustrationSummary = "For Paws: PersistencePolicy for data storage, ProcessSpecification for workflow shapes, ConstraintEvaluationSpec for scheduling rules, ExternalServiceBinding for payment integration, CommunicationChannel for notifications.";
    }
    part bsmmGeneralVocabulary : ArchitecturalSection {
        attribute :>> name = "bsmm-general-vocabulary";
        attribute :>> displayName = "SMM General Vocabulary";
        attribute :>> group = ArchitecturalGroup::rightStack;
        attribute :>> presentationOrder = 8;
        attribute :>> primaryFormalism = Formalism::sysmlV2;
        attribute :>> persistenceMechanism = "sysml-files-scattered";
        attribute :>> implementationStatus = ImplementationStatus::designed;
        attribute :>> docKey = "bsmm-general-vocabulary";
    }

    // Section 9: System Instance

    @UserFacing {
        friendlyName = "System Instance";
        shortDescription = "The concrete system configuration for a specific tenant — which database, workflow engine, integration endpoints, and access control policies.";
    }
    @PurposiveDescription {
        description = "The right-stack counterpart of the business instance. Where the business instance holds the concrete populated data for a specific tenant, the system instance holds the concrete system configuration: which database, which workflow engine configuration, which integration endpoints, which access control policies. The system instance makes the generic SMM vocabulary into this tenant's system.";
    }
    @ArchitecturalLocation {
        representationalModalitySummary = "SysML v2 part usages instantiating SMM part defs. Currently partially implicit in the coffee shop demonstrator — the running application embodies choices not explicitly modelled.";
        persistenceSummary = "Target: knowledge graph (canonical) with SysML v2 as projection. Currently: embodied in application code and configuration.";
        interfacesSummary = "Vertical downward to system domains. Vertical upward: every element instantiates an SMM General concept. Horizontal leftward to business instance — the realised-by relationship.";
        domainIllustrationSummary = "For Paws: PostgreSQL for transactional data, Temporal for workflows, appointment-based scheduling config, base-price-plus-surcharge pricing engine, payment processor integration, notification templates, role-based access control.";
    }
    part systemInstance : ArchitecturalSection {
        attribute :>> name = "system-instance";
        attribute :>> displayName = "System Instance";
        attribute :>> group = ArchitecturalGroup::rightStack;
        attribute :>> presentationOrder = 9;
        attribute :>> primaryFormalism = Formalism::sysmlV2;
        attribute :>> persistenceMechanism = "application-config";
        attribute :>> implementationStatus = ImplementationStatus::designed;
        attribute :>> docKey = "system-instance";
    }

    // Section 10: System Domains

    @UserFacing {
        friendlyName = "System Domains";
        shortDescription = "The running software modules that realise business operations — the right-stack counterpart of operational domains.";
    }
    @PurposiveDescription {
        description = "The right-stack counterpart of operational domains. Where the left stack's operational domains describe how the business operates in business language, system domains describe the same reality in system language — the running software modules. The model remains connected at runtime: the system does not generate and step aside. The coffee shop demonstrator has system domains as implemented modules.";
    }
    @ArchitecturalLocation {
        representationalModalitySummary = "SysML v2 for model descriptions; the system domains also have an execution dimension as running code. Dual nature: model content and operational modules.";
        persistenceSummary = "Dual: model descriptions in SysML v2 / knowledge graph; running instances in their own operational stores (PostgreSQL, workflow state, CDR).";
        interfacesSummary = "Vertical downward to operational simulation. Vertical upward: instantiates system instance configurations. Horizontal leftward to operational domains — realised-by. Inside the rules and constraints container.";
        domainIllustrationSummary = "For Paws: Booking Service, Grooming Workflow Manager, Financial Module, Customer Management, Inventory Tracker, Compliance Module — each mapping horizontally to a business operational domain.";
    }
    part systemDomains : ArchitecturalSection {
        attribute :>> name = "system-domains";
        attribute :>> displayName = "System Domains";
        attribute :>> group = ArchitecturalGroup::rightStack;
        attribute :>> presentationOrder = 10;
        attribute :>> primaryFormalism = Formalism::sysmlV2;
        attribute :>> persistenceMechanism = "sysml-files-and-operational-stores";
        attribute :>> implementationStatus = ImplementationStatus::designed;
        attribute :>> docKey = "system-domains";
    }

    // Section 11: Operational Simulation

    @UserFacing {
        friendlyName = "Operational Simulation";
        shortDescription = "The bottom of the right stack — where the business system is live, with Temporal workflows coordinating execution per tenant.";
    }
    @PurposiveDescription {
        description = "The SMM made operational: Temporal workflows coordinating business execution per tenant, with human actors and connected applications as participants. This is where business operations happen in system terms. The groomer, the receptionist, the payment processor are all participants inside the simulation. Every workflow, activity, and state transition traces through SMM to BMM to ontology to BFO, preserving semantic lineage end-to-end.";
    }
    @ArchitecturalLocation {
        representationalModalitySummary = "Temporal workflows, event streams, and durable state management — execution formalisms generated from the SysML model (A3). The coffee shop FulfilDrink workflow is a working example.";
        persistenceSummary = "Temporal workflow state (durable, resumable), event logs, and operational databases. The simulation state is the business's current operational state — the most ephemeral section, changing continuously.";
        interfacesSummary = "Upward from system domains. Cross-cutting: the reflective simulation reads continuously. Inside the rules and constraints container. Horizontal leftward to business process patterns — the pipeline crossing.";
        domainIllustrationSummary = "For Paws: the living business — a StandardGroom workflow assigns groomer Pol to a Medium Labrador, moves through bath/dry/style stages, calculates price with surcharges, and processes payment, all with full semantic lineage.";
    }
    part operationalSimulation : ArchitecturalSection {
        attribute :>> name = "operational-simulation";
        attribute :>> displayName = "Operational Simulation";
        attribute :>> group = ArchitecturalGroup::rightStack;
        attribute :>> presentationOrder = 11;
        attribute :>> primaryFormalism = Formalism::runtime;
        attribute :>> persistenceMechanism = "temporal-workflow-state";
        attribute :>> implementationStatus = ImplementationStatus::designed;
        attribute :>> docKey = "operational-simulation";
    }

    // =================================================================
    // CROSS-CUTTING
    // =================================================================

    // Section 12: Reflective Simulation

    @UserFacing {
        friendlyName = "Reflective Simulation";
        shortDescription = "A cross-cutting meta-knowledge capability reading from all architectural layers, producing guidance and insight for the operator.";
    }
    @PurposiveDescription {
        description = "A cross-cutting vertical capability on the right side, reading from every layer and writing in two directions: to the operator (guidance, insight, projections) and to the knowledge graph (derived knowledge as persistent self-knowledge). Maintains trajectories, projections, anomaly detection, option analysis, what-if scenarios, and evaluative assessment imbued with valence. Does not exercise directive control — it offers guidance; the operator decides.";
    }
    @ArchitecturalLocation {
        representationalModalitySummary = "Mixed — consumes OWL 2 DL, SysML v2, runtime state, and clinical terminologies. Produces natural-language explanations and OWL 2 DL assertions. Internal processing formalism is an open design question.";
        persistenceSummary = "Derived knowledge persists in the knowledge graph as coordinate space snapshots — named graphs tagged with epistemic status (current, historical, goal, hypothetical, projected). Transient working state does not persist.";
        interfacesSummary = "Reads from: knowledge graph, instance layers, operational simulation, rules and constraints, terminology. Writes to: operator (guidance) and knowledge graph (derived knowledge). Cross-cutting — not positioned in either stack.";
        domainIllustrationSummary = "For Paws: answers questions like groomer utilisation trends, what-if for adding Teeth Cleaning, revenue vs goal gap analysis with valence, shampoo consumption anomaly detection, and April revenue projection.";
    }
    part reflectiveSimulation : ArchitecturalSection {
        attribute :>> name = "reflective-simulation";
        attribute :>> displayName = "Reflective Simulation";
        attribute :>> group = ArchitecturalGroup::crossCutting;
        attribute :>> presentationOrder = 12;
        attribute :>> primaryFormalism = Formalism::mixed;
        attribute :>> persistenceMechanism = "knowledge-graph-snapshots";
        attribute :>> implementationStatus = ImplementationStatus::designed;
        attribute :>> docKey = "reflective-simulation";
    }

    // =================================================================
    // RULES AND CONSTRAINTS CONTAINER
    // =================================================================

    // Section 13: Rules and Constraints

    @UserFacing {
        friendlyName = "Rules and Constraints";
        shortDescription = "The rules and constraints container governing what is permissible in dynamic behaviour, wrapping the bottom two pairs on both stacks.";
    }
    @PurposiveDescription {
        description = "Rules and constraints govern what is permissible in dynamic behaviour — not what structures can exist (that is the ontological layers' job). The rules and constraints container wraps the bottom two pairs on both stacks. Critical distinction: constraint definitions live in the instance layers above (structural); constraint enforcement happens inside the container at runtime (dynamic). This parallels the governance traceability chain (A8).";
    }
    @ArchitecturalLocation {
        representationalModalitySummary = "Mixed. Definitions: SysML v2 (requirement defs, constraint defs, decision tables). Enforcement: CLP(FD), Temporal guards, XState validation, business rule evaluation. Spans eligibility, scheduling, safety, governance, and probabilistic rule types.";
        persistenceSummary = "Constraint definitions persist in the model (SysML v2 / knowledge graph). Enforcement results persist as evidence (audit trail, evaluation records).";
        interfacesSummary = "Inward: governs both business process patterns and operational simulation. Upward: definitions trace to instance layers and regulatory requirements. The reflective simulation reads from this layer to know acceptable operation boundaries.";
        domainIllustrationSummary = "For Paws: one room per groom at a time (scheduling), groomer must be qualified (capability), correct surcharge order (business rule), second handler for aggressive dogs (safety), current insurance required (compliance).";
    }
    part rulesAndConstraints : ArchitecturalSection {
        attribute :>> name = "rules-and-constraints";
        attribute :>> displayName = "Rules and Constraints";
        attribute :>> group = ArchitecturalGroup::rulesAndConstraintsContainer;
        attribute :>> presentationOrder = 13;
        attribute :>> primaryFormalism = Formalism::mixed;
        attribute :>> persistenceMechanism = "model-and-evidence";
        attribute :>> implementationStatus = ImplementationStatus::designed;
        attribute :>> docKey = "rules-and-constraints";
    }

    // =================================================================
    // INFRASTRUCTURE
    // =================================================================

    // Section 14: Terminology and Information Carriers

    @UserFacing {
        friendlyName = "Terminology and Information Carriers";
        shortDescription = "Semantic grounding for domain-specific terminology and structured information exchange standards.";
    }
    @PurposiveDescription {
        description = "Semantic grounding for domain-specific terminology and structured information exchange. For clinical tenants: SNOMED CT, openEHR, ICD, FHIR, AQL. For non-clinical tenants: industry-standard codes, service taxonomies, regulatory classification schemes. Distinct from ontological categories (what kinds of things exist) and meta model vocabularies (structural patterns) — this section provides the vocabulary for domain-specific content.";
    }
    @ArchitecturalLocation {
        representationalModalitySummary = "Native formalisms of the standards: SNOMED CT concept hierarchy, openEHR archetypes (ADL), FHIR resource profiles, ICD classification. Imported, not invented.";
        persistenceSummary = "Terminology servers, CDR instances, FHIR servers — external infrastructure Ontara connects to. Mappings to Ontara's ontological categories persist in the knowledge graph.";
        interfacesSummary = "The reflective simulation reads terminology for precise explanations. The operational simulation uses it for coded data capture. The mapping ontology bridges internal vocabulary and external standards.";
        domainIllustrationSummary = "For Paws: thin — possibly breed classification standards. For GSL: dense — SNOMED CT, openEHR archetypes, ICD-11 gender incongruence codes, FHIR for GP communication. Density varies by regulatory tier.";
    }
    part terminologyAndInformationCarriers : ArchitecturalSection {
        attribute :>> name = "terminology-and-information-carriers";
        attribute :>> displayName = "Terminology and Information Carriers";
        attribute :>> group = ArchitecturalGroup::infrastructure;
        attribute :>> presentationOrder = 14;
        attribute :>> primaryFormalism = Formalism::mixed;
        attribute :>> persistenceMechanism = "external-servers";
        attribute :>> implementationStatus = ImplementationStatus::designed;
        attribute :>> docKey = "terminology-and-information-carriers";
    }

    // Section 15: Mapping Ontology

    @UserFacing {
        friendlyName = "Mapping Ontology";
        shortDescription = "The OWL bridge between the two formalisms — formally declaring how SysML v2 elements correspond to ontological classes.";
    }
    @PurposiveDescription {
        description = "The bridge between the two formalisms. Everything above the formalism boundary is OWL 2 DL; everything below is SysML v2. The mapping ontology (B24), itself expressed in OWL, formally declares correspondences: SysML blocks/parts to OWL classes, SysML relationships to OWL object properties, SysML value types to OWL datatype properties. Implemented as the correspondence graph (Sessions 105–117) with class, property, and weight mapping records generated from SysML annotations via the OWL pipeline.";
    }
    @ArchitecturalLocation {
        representationalModalitySummary = "OWL 2 DL — the mapping ontology is itself an ontology, living on the OWL side but describing the SysML side. openCAESAR may provide bridge infrastructure.";
        persistenceSummary = "Triple store (knowledge graph), alongside the domain ontologies and system ontological categories. Correspondence graph operational (Session 105, extended Session 117) with class, property, and weight mapping records linking SysML BMM elements to OWL via @BfoType annotations. Extended Session 126 with governance module correspondence records from the ontara-gov: namespace.";
        interfacesSummary = "Interfaces with everything: connects ontological layers on both stacks, enables SysML content to be represented in and retrieved from the knowledge graph. Makes the knowledge-graph-as-canonical commitment (B22) technically feasible.";
        domainIllustrationSummary = "For Paws: SysML part def ServiceOffering maps to OWL class ontara:ServiceOffering classified under BFO via OCE. Part usage standardGroom maps to OWL individual paws:StandardGroom. Attribute basePrice maps to datatype property ontara:hasBasePrice.";
    }
    part mappingOntology : ArchitecturalSection {
        attribute :>> name = "mapping-ontology";
        attribute :>> displayName = "Mapping Ontology";
        attribute :>> group = ArchitecturalGroup::infrastructure;
        attribute :>> presentationOrder = 15;
        attribute :>> primaryFormalism = Formalism::owl2dl;
        attribute :>> persistenceMechanism = "triple-store";
        attribute :>> implementationStatus = ImplementationStatus::implemented;
        attribute :>> docKey = "mapping-ontology";
    }

    // Section 16: Knowledge Graph

    @UserFacing {
        friendlyName = "Knowledge Graph";
        shortDescription = "The OWL 2 DL triple store as the eventual canonical store for the entire Ontara model.";
    }
    @PurposiveDescription {
        description = "The eventual canonical store for the entire Ontara model (B22). Provides capabilities SysML alone cannot: open-world reasoning, automatic classification, consistency checking against BFO axioms, SPARQL semantic querying, formal TBox/ABox separation mapping to the meta model/instance distinction, and named-graph infrastructure for coordinate space snapshots. Adding a new axis to the coordinate space is adding triples with a new predicate — no schema migration required.";
    }
    @ArchitecturalLocation {
        representationalModalitySummary = "OWL 2 DL — the native formalism. Target home for everything above the formalism boundary and, via the mapping ontology, a canonical representation of everything below it.";
        persistenceSummary = "Triple store / graph database — this is a persistence section. GraphDB operational with 9-file ontology stack (BFO, IAO, CCO, BMM classes, BMM axioms, BMM properties, BMM weights, governance vocabulary, CQC Regulation 12 individuals) and 29-query SPARQL validation suite. Persists: ontological axioms, meta model vocabulary, instance data, weighted relationships, comprehension metadata, governance directives and normative instruments, coordinate space snapshots, reflective simulation derived knowledge, mapping ontology.";
        interfacesSummary = "Everything feeds into or reads from the knowledge graph. SPARQL is the query interface. The SysML v2 model is a projection maintained in bidirectional sync.";
        domainIllustrationSummary = "For Paws: BFO axioms, OCE ontology, BMM vocabulary as OWL classes, all Paws entities as OWL individuals, weighted relationships, coordinate space snapshots for current state, goals, and what-if scenarios.";
    }
    part knowledgeGraph : ArchitecturalSection {
        attribute :>> name = "knowledge-graph";
        attribute :>> displayName = "Knowledge Graph";
        attribute :>> group = ArchitecturalGroup::infrastructure;
        attribute :>> presentationOrder = 16;
        attribute :>> primaryFormalism = Formalism::owl2dl;
        attribute :>> persistenceMechanism = "triple-store";
        attribute :>> implementationStatus = ImplementationStatus::implemented;
        attribute :>> docKey = "knowledge-graph";
    }

    // Section 17: SysML v2

    @UserFacing {
        friendlyName = "SysML v2";
        shortDescription = "The engineering projection — the view of the canonical model that the architect works with directly in Syside Modeler.";
    }
    @PurposiveDescription {
        description = "The engineering projection — the view of the canonical model that the architect and developer work with directly. Currently the primary representation; will remain the primary working representation even when the knowledge graph becomes canonical. Holds meta model vocabularies, instances, comprehension metadata, constraint definitions, PatternCatalogue entries, and structural relationships. The entire generation pipeline reads from SysML v2.";
    }
    @ArchitecturalLocation {
        representationalModalitySummary = "SysML v2 — the native formalism. 11 core .sysml files, approximately 73 packages. Target: engineering projection from the knowledge graph, maintained in bidirectional sync via the mapping ontology.";
        persistenceSummary = ".sysml files in the git repository (model/ and exercises/ directories). Git provides version control.";
        interfacesSummary = "The generation pipeline reads from SysML v2 and produces JSON, Mermaid, TypeScript, constraint evaluators. The knowledge graph will maintain bidirectional sync. Syside Modeler is the authoring environment.";
        domainIllustrationSummary = "For Paws: one .sysml file (PawsGroomingDomain.sysml) with part usages instantiating BMM part defs plus 7 StakeholderModel instantiations. Source for gen_model_introspection.py.";
    }
    part sysmlV2Section : ArchitecturalSection {
        attribute :>> name = "sysml-v2";
        attribute :>> displayName = "SysML v2";
        attribute :>> group = ArchitecturalGroup::infrastructure;
        attribute :>> presentationOrder = 17;
        attribute :>> primaryFormalism = Formalism::sysmlV2;
        attribute :>> persistenceMechanism = "sysml-files";
        attribute :>> implementationStatus = ImplementationStatus::implemented;
        attribute :>> docKey = "sysml-v2";
    }

    // Section 18: openEHR

    @UserFacing {
        friendlyName = "openEHR";
        shortDescription = "The clinical data architecture for healthcare tenants — archetypes, templates, and a Clinical Data Repository.";
    }
    @PurposiveDescription {
        description = "The clinical data architecture for healthcare tenants. openEHR provides archetypes (reusable clinical data building blocks), templates, and a CDR storing archetype-structured clinical data with AQL semantic querying. For clinical tenants like GSL, openEHR is the persistence and data architecture for clinical content. Non-clinical tenants do not use this section — tenant variation made architectural.";
    }
    @ArchitecturalLocation {
        representationalModalitySummary = "ADL for archetype definitions, openEHR reference model for data structures, AQL for queries. The coffee shop demonstrator has a working EHRbase integration with three archetypes.";
        persistenceSummary = "EHRbase CDR — a dedicated clinical data repository, separate from the operational database and knowledge graph. Clinical data has specific regulatory requirements best served by a purpose-built CDR.";
        interfacesSummary = "The operational simulation interacts with the CDR for clinical data. Terminology layer provides SNOMED CT coding. The reflective simulation reads clinical data within access control bounds. The mapping ontology bridges archetypes and Ontara's ontological model.";
        domainIllustrationSummary = "For Paws: empty — non-clinical tenant. For GSL: central — archetypes for hormone monitoring, referral compositions, mental health assessments, and the CDR as authoritative clinical record.";
    }
    part openehrSection : ArchitecturalSection {
        attribute :>> name = "openehr";
        attribute :>> displayName = "openEHR";
        attribute :>> group = ArchitecturalGroup::infrastructure;
        attribute :>> presentationOrder = 18;
        attribute :>> primaryFormalism = Formalism::mixed;
        attribute :>> persistenceMechanism = "clinical-data-repository";
        attribute :>> implementationStatus = ImplementationStatus::implemented;
        attribute :>> docKey = "openehr";
    }

    // Section 19: Temporal

    @UserFacing {
        friendlyName = "Temporal";
        shortDescription = "The execution infrastructure for the operational simulation — durable workflow orchestration surviving process restarts.";
    }
    @PurposiveDescription {
        description = "The execution infrastructure for the operational simulation (L5). Temporal provides durable workflow orchestration: sequences of work that survive process restarts, handle retries and timeouts, manage compensation, and maintain explicit state. Temporal is the infrastructure the simulation runs on — not the simulation itself — just as the triple store is the infrastructure the knowledge graph runs on.";
    }
    @ArchitecturalLocation {
        representationalModalitySummary = "Temporal workflow definitions, activity definitions, state management — execution-level primitives, the most concrete content in the architecture. Generated from the model via the compilation pipeline.";
        persistenceSummary = "Temporal's own persistence layer (typically PostgreSQL-backed) stores workflow state, execution history, and task queues — operational persistence, durable relative to individual requests.";
        interfacesSummary = "The operational simulation runs on Temporal. The generation pipeline produces Temporal workflow code. Human actors and connected applications participate as activity executors. System domains are implemented as workers, activities, and child workflows.";
        domainIllustrationSummary = "For Paws: orchestrates the end-to-end grooming workflow (book through pay and record), scheduling engine, inventory monitoring, and financial processing — each generated from business process patterns with semantic identity preserved.";
    }
    part temporalSection : ArchitecturalSection {
        attribute :>> name = "temporal";
        attribute :>> displayName = "Temporal";
        attribute :>> group = ArchitecturalGroup::infrastructure;
        attribute :>> presentationOrder = 19;
        attribute :>> primaryFormalism = Formalism::runtime;
        attribute :>> persistenceMechanism = "temporal-persistence";
        attribute :>> implementationStatus = ImplementationStatus::implemented;
        attribute :>> docKey = "temporal";
    }

    // Section 20: Operator

    @UserFacing {
        friendlyName = "Operator";
        shortDescription = "The human business operator — the guidance target for the entire architecture; every other section exists to serve their understanding and agency.";
    }
    @PurposiveDescription {
        description = "The human business operator — the guidance target for the entire architecture. Every other section exists to serve the operator's understanding and agency. The reflective simulation produces guidance for the operator. The console presents the model to the operator. Valence (L7) is the operator's declared conception of good performance. Goal states in the coordinate space are the operator's aspirations made formal. The architecture is invisible to the operator; what they see is a system that understands the business.";
    }
    @ArchitecturalLocation {
        representationalModalitySummary = "Not a representational section in the usual sense. The operator's inputs (valence declarations, goals, configuration, instance content) are model content. The system's outputs (explanations, guidance, projections) are the reflective simulation's products rendered for human consumption.";
        persistenceSummary = "Operator preferences, goal state declarations, and valence definitions persist in the model (knowledge graph / SysML v2). Interaction history may persist for trajectory analysis.";
        interfacesSummary = "Interacts with the console (navigation, comprehension, relationship graph). The reflective simulation writes guidance. The operator writes business instance content, valence declarations, and goal states. The ultimate audience for A2 (self-describing system).";
        domainIllustrationSummary = "For Paws: Sam uses the console to understand business structure, see performance against goals, explore what-if scenarios, and receive guidance — without needing to understand SysML, OWL, BFO, or Temporal.";
    }
    part operatorSection : ArchitecturalSection {
        attribute :>> name = "operator";
        attribute :>> displayName = "Operator";
        attribute :>> group = ArchitecturalGroup::infrastructure;
        attribute :>> presentationOrder = 20;
        attribute :>> primaryFormalism = Formalism::mixed;
        attribute :>> persistenceMechanism = "model-preferences";
        attribute :>> implementationStatus = ImplementationStatus::designed;
        attribute :>> docKey = "operator";
    }
}
