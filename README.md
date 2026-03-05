# GenderSense — SysML v2 High-Level Package Model

## Purpose

This project contains the top-level SysML v2 package hierarchy for the GenderSense clinical service management platform. It defines the complete namespace structure and scope for the business system, from enterprise context through clinical service delivery, platform infrastructure, operations, knowledge/decision support, and cross-cutting foundation services.

## Status

**Package skeleton established:** 5 March 2026. All packages declared with doc comments and placeholder `use case def` / `part def` / `enum def` / `state def` / `metadata def` content. Verified clean in Syside Modeler 0.8.5.

## Project Structure

```
gsl-sysml-high-level-package/
├── model/
│   └── gendersense-package-hierarchy.sysml   # Complete package hierarchy
├── documentation/
│   └── (companion documents as needed)
└── README.md
```

## Workspace Dependencies

This project should be in the same VS Code workspace as:

- **`sysml-metadata-lib/`** — Shared metadata definitions (`@TemporalWorkflow`, `@TemporalActivity`, etc.) validated in the coffee shop demonstrator. Foundation::MetadataLibrary will import from this.
- **`coffeeshop-demonstrator/`** — Reference implementation and syntax reference (`documentation/sysml-v2-syntax-reference-v3.1-2026-03-05.md`).

Syside resolves `private import PackageName::*;` across all `.sysml` files in the VS Code workspace folder tree.

## Companion Documents

- **Architecture Principles** (`gendersense-architecture-principles.md`) — Separation principle, openEHR integration, governance audit patterns.
- **Modelling Strategy** (`gendersense-sysml-modelling-strategy.md`) — Comprehensive modelling rationale, three-tier reasoning stack, concentric rings of modelling rigour.
- **Package Hierarchy Proposal** (`gendersense-package-hierarchy-proposal.md`) — The tree diagram this model implements.
- **SysML v2 Syntax Reference** (`sysml-v2-syntax-reference-v3.1-2026-03-05.md`) — Verified patterns for Syside Modeler 0.8.5.

## Tooling

- **Syside Modeler** 0.8.5 (VS Code extension)
- **SysML v2.0** (OMG ratified July 2025)
- **KerML 1.0**

## Next Steps

1. Verify `satisfy`/`verify` traceability syntax in Syside 0.8.5
2. Test use case diagram visualisation via Tom Sawyer v1.3
3. Begin first clinical pathway model (Hormone Therapy Initiation)
4. Split hierarchy file into per-package files as elaboration grows
5. Evaluate Syside Automator for generator migration
