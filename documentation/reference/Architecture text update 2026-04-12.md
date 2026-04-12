Ontara maintains an architecture with two distinct 'stacks' broadly modelling both the business (service) itself, and the systems of the business,  connected by explicit horizontal mappings:

- **Business Model (BM) and Meta Model(s) (BMM)** — what a service business *is*. 34 elements across six concerns (ServiceConcept, ActivityModel, ResourcePlanning, FinancialPlanning, GovernanceMapping, StakeholderModel).
- **System Model (SM) and Meta Model(s) (SMM)** — how a business system *works*. ArchitecturalSection (section instances describing the dual-stack architecture), plus the reasoning metamodel as a cross-cutting SMM extension.

The **dual-stack architecture** (Session 73) pairs these as two parallel vertical stacks with horizontal mappings at each tier. The knowledge graph (OWL 2 DL in GraphDB) serves as the eventual canonical store, with SysML v2 as an engineering projection. BFO 2020 is the mandatory upper ontology; PROV-O provides provenance tracking at the platform level.