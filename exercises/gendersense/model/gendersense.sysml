package GenderSense {
    private import ScalarValues::*;
    private import GslEnterprise::*;
    private import SystemMetamodelGeneral::*;
    private import GslServiceDelivery::*;
    private import GslPlatform::*;
    private import GslOperations::*;
    private import Foundation::*;
    private import ProjectionMetadata::*;
    private import SystemMetamodelDomainClinical::*;
    private import BusinessMetamodelGeneral::*;
    private import GslBusinessModel::*;
    private import GslScenarios::*;
    private import GslKnowledge::*;
    private import PatternCatalogue::*;

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
         * File structure:
         *   gendersense.sysml          — This root package (imports all domains)
         *   enterprise.sysml           — Organisation, Regulation, Strategy, Risk
         *   knowledge.sysml            — CDS, Constraints, Logic, Decisions, Outcomes, Learning, Analytics
         *   service-delivery.sysml     — PatientJourney, ClinicalPathways, Consent, Coaching, Governance, Entities
         *   platform.sysml             — Portal, Booking, EHR, Forms, Messaging, Video, Labs, Prescribing, Payments, Docs, Identity, Orchestration, Integration
         *   operations.sysml           — Finance, People, Marketing, CRM, Reporting, EstatesAndFacilities
         *   foundation.sysml           — Residual: MetadataLibrary (clinical, governance, openEHR, agency annotations), CommonTypes, DomainRegistry, StatePatterns. Being dissolved by meaning (ADR-011 §4.7, S514)
         *   projection-metadata.sysml  — ProjectionMetadata: the generators' annotation schema (formerly Foundation::MetadataLibrary)
         *   business-model.sysml       — ServiceConcept, ActivityModel, ResourcePlanning, FinancialPlanning
         *   business-scenarios.sysml   — ScenarioDefinitions, ProjectionParameters, Formulas, Outputs, Comparisons, Steering
         *   business-strategy.sysml    — StrategicObjectives, BusinessModelVariants, PivotScenarios
         *   pattern-catalogue.sysml    — PatternCatalogue: cross-domain concept registry and pattern catalogue
         *
         * Phase 6A split: BusinessModel was ~1,900 lines. ScenarioModelling
         * promoted to BusinessScenarios, StrategyAndEvolution promoted to
         * BusinessStrategy. Each file now under 900 lines. */
}
