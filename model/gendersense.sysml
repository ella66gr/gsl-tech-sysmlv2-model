package GenderSense {
    private import ScalarValues::*;
    private import Enterprise::*;
    private import Knowledge::*;
    private import ServiceDelivery::*;
    private import Platform::*;
    private import Operations::*;
    private import Foundation::*;
    private import BusinessModel::*;

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
         * Verified clean in Syside Modeler 0.8.5 (5 March 2026).
         *
         * File structure:
         *   gendersense.sysml       — This root package (imports all domains)
         *   enterprise.sysml        — Organisation, Regulation, Strategy, Risk
         *   knowledge.sysml         — CDS, Constraints, Logic, Decisions, Outcomes, Learning, Analytics
         *   service-delivery.sysml  — PatientJourney, ClinicalPathways, Consent, Coaching, Governance, Entities
         *   platform.sysml          — Portal, Booking, EHR, Forms, Messaging, Video, Labs, Prescribing, Payments, Docs, Identity, Orchestration, Integration
         *   operations.sysml        — Finance, People, Marketing, CRM, Reporting
         *   foundation.sysml        — MetadataLibrary, CommonTypes, StatePatterns, GenerationPipeline
         *   business-model.sysml    — ServiceConcept, ActivityModel, ResourcePlanning, FinancialPlanning, ScenarioModelling
         */
}
