# Architectural Clarification: The Two Meta Models

**Project:** GenderSense (GSL)
**Date:** 14 March 2026 (Session 29)
**Status:** Architectural principle — established, not aspirational
**Authority:** This document clarifies and reinforces the distinction first articulated in `gsl-service-business-meta-modelling.md` §1 (10 March 2026). It does not introduce new concepts — it ensures the distinction is explicit, consistently applied, and resistant to dilution.

---

## 1. The Principle

The GSL project maintains **two distinct meta models**, not one:

**Business Meta Model** — the structural template for what a service business *is*. Its concerns are: service concept (what value is delivered, to whom), financial model (how money flows), resource and capability model (what is needed to operate), activity taxonomy (what work happens), governance and adaptation (how the business evolves). This meta model answers: *what does this business do, and does it work?*

**Business System Meta Model** — the structural template for how a business system *works*. Its concerns are: processes and pathways, platform architecture, data architecture (including persistence strategy), knowledge and decision support, operations, and governance mechanisms. This meta model answers: *how does the system implement what the business needs?*

These are two distinct meta models connected by explicit mappings. A ServiceOffering in the business model maps to one or more service processes in the system model. A ResourceType maps to platform elements. A PersistencePolicy (system) explains *where* the data lives; a CatalogueEntry (business) describes *what* the business offers regardless of where the data lives.

### Why the distinction matters

The distinction is not academic. It is the architectural guarantee that:

- **Business model changes and system changes can be iterated independently.** A pricing strategy change is a business meta model concern that may or may not require system changes. A persistence technology migration is a system meta model concern that should not alter the business model.

- **Multiple businesses can share meta model structure.** GSL (gender-affirming healthcare) and CSW (coffee shop) instantiate the same business meta model (both have service concepts, activity taxonomies, resources, financial models) and the same system meta model (both have persistence policies, pathway orchestration, delivery mechanisms) — but with different domain-specific types.

- **The system can explain itself at two levels.** "Why do we offer this service?" is a business meta model question. "Why is this data stored in PostgreSQL rather than the CDR?" is a system meta model question. Both answers should be in the model — but in different parts of it.

- **Future commonality and modularity are preserved.** When additional service domains are added (addictions, other clinical specialities), they inherit from the same pair of meta models. Shared components (catalogue management, persistence policy, agency classification) are defined once in the meta model and instantiated per domain. Domain-specific components are added as extensions.

---

## 2. Current State in the SysML Model

### Business Meta Model — explicit, named

The business meta model is implemented as the `BusinessModel` package with four sub-packages:

| Sub-package | Concern | Key part defs |
|---|---|---|
| `ServiceConcept` | What value is delivered, to whom | `CustomerSegment`, `ValueProposition`, `ServiceOffering`, `Channel`, `DifferentiationClaim`, **`CatalogueEntry`**, **`ExternalReference`** |
| `ActivityModel` | What work happens | `ActivityType`, `ActivityRecord`, `ActivityBudget`, `ActivityGranularity`, `ActivityCostAllocation` |
| `ResourcePlanning` | What is needed to operate | `ResourceType`, `ResourceInstance`, `Capability`, `CapacityModel`, `ResourceConstraint`, **`InventoryRecord`** |
| `FinancialPlanning` | How money flows | `RevenueStream`, `CostCategory`, `UnitEconomics`, `BreakEvenAnalysis` |

Plus `BusinessScenarios` and `BusinessStrategy` as promoted packages.

GSL and CSW each instantiate these part defs with their own domain-specific values.

### Business System Meta Model — implicit, distributed

The business system meta model is not yet a named package. Its concepts are distributed across:

| Current location | System meta model concepts |
|---|---|
| `Foundation::CommonTypes` | **`PersistencePolicy`**, **`PersistenceLayer`**, **`DataCharacteristic`**, `EvaluationOutcome`, `Severity`, `AssessmentScope`, `DataSourceType` |
| `Foundation::MetadataLibrary` | **`AgencyClassification`**, **`AgencyType`**, `ClinicalReviewGate`, `ConsentRequired`, `AuditPoint`, `LogicRule`, `DecisionTable`, `SafetyConstraint`, `OpenEhrArchetype`, `OpenEhrTemplate` |
| `ServiceDelivery` | Clinical pathways, two-layer action flow architecture |
| `Platform` | (placeholder — technology subsystem definitions) |
| `Knowledge` | Self-knowledge architecture, evaluation framework, logic engine |
| `Operations` | (placeholder — operational processes) |

The system meta model is real — these are all system-level concerns — but it is not yet surfaced as a named, navigable structure. Phase 10 adds to it (PersistencePolicy, AgencyClassification) with doc blocks explicitly labelling them as system meta model concepts. A future workstream (System Meta Model Extraction) will promote the implicit structure into a named meta model.

---

## 3. Classification Guide

When adding a new concept to the model, ask:

| Question | If yes → | Meta model |
|---|---|---|
| Does this describe what the business offers or how it makes money? | ServiceConcept, FinancialPlanning | **Business** |
| Does this describe what resources or capabilities the business needs? | ResourcePlanning, ActivityModel | **Business** |
| Does this describe how the system is built or architected? | Foundation, Platform | **System** |
| Does this annotate how the delivery system executes steps? | Foundation::MetadataLibrary | **System** |
| Does this describe clinical or operational processes? | ServiceDelivery | **System** |
| Does this describe knowledge, reasoning, or decision support? | Knowledge | **System** |

Some concepts straddle: inventory tracking is a business concern at the planning level ("we need stock management") and a system concern at the operational level ("here's how stock is tracked in the database"). The meta model captures both perspectives — `InventoryRecord` in the business meta model describes the *what*, while `PersistencePolicy` in the system meta model describes the *how*.

---

## 4. Guard Rails

To prevent the distinction from being diluted, distorted, or forgotten:

1. **Every new part def or metadata def must carry a doc block identifying its meta model.** The phrases "business meta model concept" or "business system meta model concept" must appear in the doc block. This is a standing convention from Session 29 onwards.

2. **The Phase 10 plan, session reports, strategic snapshots, and work analysis must use the explicit vocabulary.** Not "the GSL meta model" (ambiguous) but "the business meta model" or "the system meta model" (precise).

3. **The service business meta modelling discussion paper (`gsl-service-business-meta-modelling.md` §1) is the authoritative source.** If any other document appears to contradict the two meta model distinction, the discussion paper takes precedence and the contradicting document should be updated.

4. **The Pattern Catalogue (when built) should include the two meta model distinction as a top-level organising principle.** Patterns that are business meta model patterns (four-layer item model, activity taxonomy, scenario modelling) are distinguished from patterns that are system meta model patterns (two-layer action flow, metadata-driven generation, persistence policy, agency classification).

5. **Periodic project reviews should check for conceptual drift.** The two meta model distinction is a structural commitment, not a suggestion. If a session report or plan conflates business and system concerns, that is a conceptual error to be corrected.

---

## 5. Relationship to Other Documents

| Document | Relationship to this clarification |
|---|---|
| `gsl-service-business-meta-modelling.md` | **Authoritative source.** §1 establishes the two meta model distinction. This clarification reinforces and operationalises it. |
| `gsl-platform-sysml-modelling-strategy.md` | Predates the meta modelling paper. The package structure (§7) implicitly describes what will become the system meta model. A bridging note has been added (Session 29). |
| `gsl-platform-architecture-principles.md` | Focuses on representation/execution separation — a different (compatible) architectural axis. The representation layer contains both meta models. |
| `gsl-discussion-model-self-service-enabling-architecture-2026-03-14.md` | §7 (AgencyClassification) and §14 (component summary) describe system meta model concepts. Correctly positioned but predates the explicit labelling convention. |
| `gsl-spec-catalogue-inventory-v2.1.md` | §8 (Meta Model Implications) is conceptually correct — CatalogueEntry/ExternalReference/InventoryRecord in BusinessModel (business), PersistencePolicy in Foundation (system). Uses informal vocabulary; a clarifying note has been added (Session 29). |
| `gsl-validated-architectural-patterns.md` | Pattern catalogue. The two meta model distinction is itself a pattern to be catalogued when the Pattern Catalogue workstream begins. |

---

*Architectural clarification prepared 14 March 2026 (Session 29). Reinforces the two meta model distinction from `gsl-service-business-meta-modelling.md` §1 and establishes standing conventions for maintaining conceptual precision.*
