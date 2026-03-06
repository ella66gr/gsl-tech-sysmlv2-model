# GenderSense — SysML v2 High-Level Package Model

## Purpose

This project contains the top-level SysML v2 package hierarchy for the GenderSense clinical service management platform. It defines the complete namespace structure and scope for the business system, from enterprise context through clinical service delivery, platform infrastructure, operations, knowledge/decision support, and cross-cutting foundation services.

## Status

**Package skeleton established and split into per-domain files:** 5 March 2026. All packages declared with doc comments and placeholder `use case def` / `part def` / `enum def` / `state def` / `metadata def` content. `satisfy` traceability from requirements to constraints verified. All files parse clean in Syside Modeler 0.8.5.

## Project Structure

```
gsl-sysml-model/
├── model/
│   ├── gendersense.sysml       — Root package (imports all domains)
│   ├── enterprise.sysml        — Organisation, Regulation, Strategy, Risk
│   ├── knowledge.sysml         — CDS, Constraints, Logic, Decisions, Outcomes, Learning, Analytics
│   ├── service-delivery.sysml  — PatientJourney, ClinicalPathways, Consent, Coaching, Governance, Entities
│   ├── platform.sysml          — Portal, Booking, EHR, Forms, Messaging, Video, Labs, Rx, Payments, Docs, Identity, Orchestration, Integration
│   ├── operations.sysml        — Finance, People, Marketing, CRM, Reporting
│   └── foundation.sysml        — MetadataLibrary, CommonTypes, StatePatterns, GenerationPipeline
├── documentation/
│   └── gendersense-package-hierarchy.sysml.archive  — Original single-file version (for reference)
└── README.md
```

Each domain file declares a standalone top-level package (e.g. `package Enterprise { }`). The root `gendersense.sysml` declares `package GenderSense` and imports all domain packages. Cross-file imports (e.g. `private import Enterprise::Regulation::*;`) resolve across the workspace.

## Workspace Dependencies

This project should be in the same VS Code workspace as:

- **`sysml-metadata-lib/`** — Shared metadata definitions (`@TemporalWorkflow`, `@TemporalActivity`, etc.) validated in the coffee shop demonstrator. Foundation::MetadataLibrary will import from this.
- **`coffeeshop-demonstrator/`** — Reference implementation and syntax reference (`documentation/sysml-v2-syntax-reference-v3.1-2026-03-05.md`).

Syside resolves `private import PackageName::*;` across all `.sysml` files in the VS Code workspace folder tree.

## Verified Patterns

- `use case def` with `doc` blocks (50+ instances)
- `requirement def` with `subject` and cross-package type references
- `constraint def` with evaluable boolean bodies
- `satisfy requirement X by Y;` traceability (constraint usage satisfying requirement)
- `metadata def` with typed attributes
- `state def` with transitions and events
- Multi-file split with cross-file imports
- Deep package nesting (3 levels)

## Companion Documents

- **Architecture Principles** (`gendersense-architecture-principles.md`)
- **Modelling Strategy** (`gendersense-sysml-modelling-strategy.md`)
- **Package Hierarchy Proposal** (`gendersense-package-hierarchy-proposal.md`)
- **SysML v2 Syntax Reference** (`sysml-v2-syntax-reference-v3.1-2026-03-05.md`)

## Tooling

- **Syside Modeler** 0.8.5 (VS Code extension, 1 March 2026)
- **SysML v2.0** (OMG ratified July 2025)
- **KerML 1.0**

## Next Steps

1. Begin first clinical pathway model (Hormone Therapy Initiation) in `service-delivery.sysml`
2. Test `verify` relationship syntax
3. Evaluate Syside Automator for generator migration
4. Test use case diagram and other visualisations on the split files
5. Validate openEHR integration patterns via coffee shop CDR extension
