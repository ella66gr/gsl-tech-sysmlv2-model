package GenderSense {
    private import ScalarValues::*;
    private import GslEnterprise::*;
    private import SystemMetamodelGeneral::*;
    private import GslServiceDelivery::*;
    private import GslPlatform::*;
    private import GslOperations::*;
    private import GslCommonTypes::*;
    private import ProjectionMetadata::*;
    private import SystemMetamodelDomainClinical::*;
    private import BusinessMetamodelGeneral::*;
    private import GslBusinessModel::*;
    private import GslScenarios::*;
    private import GslKnowledge::*;
    private import GslDomainRegistration::*;

    doc /* GenderSense: Model-driven clinical service management platform
         * for gender-affirming healthcare.
         *
         * This is the root package that assembles the complete system model
         * from per-domain packages defined in separate files.
         *
         * Modelling rigour varies by area: maximum for clinical pathways and
         * entity lifecycles (inner ring), moderate for platform interfaces and
         * decision support (middle ring), lightweight for business context and
         * organisational structure (outer ring).
         *
         * Representation layer (this model) is the source of truth.
         * Execution layer consumes it via generation or configuration.
         *
         * File structure (GSL tenant model, exercises/gendersense/model/; ADR-012):
         *   gendersense.sysml              — This root package (imports the GSL packages and the metamodel packages)
         *   gsl-enterprise.sysml           — GslEnterprise: Organisation, Regulation, Strategy, Risk
         *   gsl-knowledge.sysml            — GslKnowledge: HormoneTherapyTypes, ConstraintLibrary, ClinicalDecisionSupport, DecisionTables, OutcomeTargets
         *   gsl-service-delivery.sysml     — GslServiceDelivery: PatientJourney, ClinicalPathways, Consent, CoachingSupport, ClinicalGovernance, ClinicalEntities
         *   gsl-platform.sysml             — GslPlatform: PatientPortal, Education, Community, Booking, Forms, Messaging, VideoConsulting, LabInterface, PrescribingSystem, Payments, Documents, Identity, Orchestration, Integration
         *   gsl-operations.sysml           — GslOperations: Finance, People, EstatesAndFacilities, Marketing, CRM, Reporting
         *   gsl-business-model.sysml       — GslBusinessModel: GSL usages of the six BMM concerns (Variant A and Variant B)
         *   gsl-scenarios.sysml            — GslScenarios: scenarios, projections, steering usages, objectives, variants, pivot
         *   gsl-common-types.sysml         — GslCommonTypes: six unconsumed common types (candidates)
         *   gsl-domain-registration.sysml  — GslDomainRegistration: gslIdentity, gslConfiguration
         *
         * Metamodel packages imported from model/: BusinessMetamodelGeneral,
         * SystemMetamodelGeneral, SystemMetamodelDomainClinical, and the
         * ProjectionMetadata apparatus.
         *
         * Phase 6A split: BusinessModel was ~1,900 lines. ScenarioModelling
         * promoted to BusinessScenarios, StrategyAndEvolution promoted to
         * BusinessStrategy. Each file now under 900 lines. */
}
