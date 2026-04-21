---
tags:
  - plan
  - architecture
date: 2026-04-05
status: current
session: 141
---
# Domain Identity and Governance Convergence — High-Level Plan

**Date:** 5 April 2026 (Session 141)
**Purpose:** High-level plan for the workstream that establishes domain identity as first-class infrastructure, implements the governance activation tier, and uses the Ears demonstrator to exercise and validate the convergence.
**Status:** Working plan — scope and sequencing agreed; detailed implementation plans produced per block.
**Depends on:** [[ontara-discussion-domain-identity-architecture-2026-03-22-v2.1|Domain Identity paper (Session 59, B15)]], [[ontara-discussion-deontic-governance-architecture-2026-04-03|Deontic Governance Architecture paper (Session 121)]], [[ontara-discussion-deontic-owl-class-design-2026-04-03|OWL Class Design paper (Session 125)]], [[stage5-plan-s.130-cqc-governance-mvp|CQC Governance MVP (Sessions 130–131)]], [[ontara-discussion-governance-granularity-and-cross-references-2026-04-04|Decomposition Granularity paper (Session 132)]]

---

## Contents

- [[#1. Strategic Context|§1. Strategic Context]]
- [[#2. Workstream Structure|§2. Workstream Structure]]
- [[#3. Block A — Domain Identity and Multi-Tenancy Infrastructure|§3. Block A]]
- [[#4. Block B — Governance Activation Tier|§4. Block B]]
- [[#5. Block C — Ears as Exercise Vehicle|§5. Block C]]
- [[#6. Sequencing and Dependencies|§6. Sequencing and Dependencies]]
- [[#7. Register Connections|§7. Register Connections]]
- [[#8. Risks and Open Questions|§8. Risks and Open Questions]]

---

## 1. Strategic Context

The project has reached a point where two architectural threads — domain management and platform governance — need to converge. Each has been developed independently to a significant level of maturity:

**Domain management.** The Session 59 foundational paper ([[ontara-discussion-domain-identity-architecture-2026-03-22-v2.1|B15]]) designed `DomainDefinition` as a first-class model concept, with `RegulatoryTier`, `BmmVocabularyScope`, and `DomainPurpose` enums, and a propagation chain from model to generator to console. The design is sound but was produced before the [[concept-dual-stack-architecture|dual-stack architecture]], the [[concept-knowledge-graph|knowledge graph]], and the governance vocabulary existed. It has a SysML representation but no OWL representation and no connection to governance activation.

**Platform governance.** The library tier is fully operational: the deontic vocabulary is in OWL (`ontara-governance.ttl`), CQC Regulation 12 is formalised as 21 individuals, the ontology stack passes HermiT consistency checking and 29 SPARQL queries. The activation tier (`BoundObligation`, `GovernanceFrameworkActivation`, `ComplianceAssessment`) is designed in the [[ontara-discussion-deontic-governance-architecture-2026-04-03|Session 121 paper]] §8–9 but not built. The activation tier cannot work without domain identity infrastructure — there is nothing formal for obligations to bind *to*.

**The convergence.** A domain's regulatory tier determines which governance frameworks are relevant. Governance activation binds framework obligations to a specific domain's service model. Domain identity provides the anchor; governance activation provides the mechanism. Neither is complete without the other.

## 2. Workstream Structure

Three blocks, each building on the previous:

| Block | Focus | Character | Estimated sessions |
|---|---|---|---|
| A | Domain identity and multi-tenancy infrastructure | Discussion + implementation | 3–5 |
| B | Governance activation tier | Discussion + implementation | 3–5 |
| C | Ears as exercise vehicle | Implementation + validation | 3–5 |

Total estimated span: 9–15 sessions.

Each block begins with a discussion paper (or revision of an existing paper) that resolves design questions specific to that block, followed by implementation. The Block A discussion paper is the first deliverable.

## 3. Block A — Domain Identity and Multi-Tenancy Infrastructure

### 3.1 Objective

Establish domain identity as a first-class concept in both the SysML model and the OWL knowledge graph, with a clear dual-stack placement and a propagation chain from model to generator to console.

### 3.2 Key questions to resolve (discussion paper)

1. **Dual-stack placement.** The Session 59 paper placed `DomainDefinition` in Foundation (BMM side). In the [[concept-dual-stack-architecture|dual-stack architecture (B21)]], where does domain identity sit? It has properties of both: it describes *what* a service business *is* (BMM — regulatory tier, service type, purpose) and *how* the platform *manages* it (SMM — package paths, configuration, lifecycle). The [[principle-two-meta-model-distinction|A4]] question: is `DomainDefinition` a BMM concept, an SMM concept, or a bridge that spans both? The resolution here affects whether the governance activation tier (Block B) can reference domains via BMM horizontal mappings or needs a separate mechanism.

2. **OWL representation.** The Session 59 paper designed only the SysML representation. The [[concept-knowledge-graph|knowledge graph]] needs domain identity too — the governance ontology's activation tier will reference domains as OWL individuals. What is the OWL class structure for `DomainDefinition`? Where does it sit in the BFO hierarchy? (Candidate: BFO `organization` or `material entity` for the domain-as-business, with an IAO `information content entity` for the domain-as-model-artefact. This may need careful separation.) How does the OWL representation relate to the SysML representation via the correspondence graph?

3. **Relationship to [[concept-multi-tenancy|multi-tenancy (A13)]].** The Session 59 paper articulated the principle clearly: "only the meta model is core; every domain is a tenant instantiation." Should A13 be promoted from T1 candidate to binding T1 principle as part of this work? What are the concrete implications for package structure, file organisation, and the `model/` vs `exercises/` distinction?

4. **Interaction with governance activation.** The [[ontara-discussion-deontic-governance-architecture-2026-04-03|Session 121 paper's]] §8.1 (applicability assessment) evaluates deontic directives against "the tenant's service model." What properties of `DomainDefinition` does the activation process need? At minimum: regulatory tier (to determine framework relevance), regulated activities (to determine directive applicability), and references to the service model elements that serve as obligation binding targets. Does `DomainDefinition` need to carry or reference a manifest of its BMM instantiations?

5. **Revisiting the Session 59 design.** The enums (`RegulatoryTier`, `BmmVocabularyScope`, `DomainPurpose`) and the propagation chain are likely still sound. But the attribute set may need extending — particularly for governance-relevant properties (jurisdiction, regulated activities, organisational form) that the activation tier needs. Are there any Session 59 open questions (§9) that should be resolved now?

### 3.3 Implementation steps (after discussion paper)

1. Define enums and `DomainDefinition` part def in SysML Foundation [Code]
2. Create domain instances (Cafe, Suds, Paws, GSL) [Code]
3. Define `DomainDefinition` OWL class and properties in a new or extended ontology module [Chat/Code]
4. Create domain OWL individuals [Chat/Code]
5. Extend `gen_model_introspection.py` to extract domain definitions [Code]
6. Update correspondence graph for domain ↔ OWL mapping [Code]
7. Validate: Syside parse, HermiT consistency, SPARQL queries for domain content [Code + Ella]
8. PatternCatalogue string-to-typed-ref migration for domain references [Code]

### 3.4 Deliverables

- Discussion paper: "Domain Identity in the Dual-Stack Architecture" (revision/extension of Session 59 paper, incorporating dual-stack, OWL, and governance activation requirements)
- SysML: enums, `DomainDefinition` part def, 4+ domain instances
- OWL: domain class, properties, individuals
- Generator: domain definition extraction
- Updated correspondence graph and SPARQL validation queries

## 4. Block B — Governance Activation Tier

### 4.1 Objective

Implement the activation tier from the Session 121 governance architecture paper — the mechanism that connects the library of formalised obligations to a specific domain's service model.

### 4.2 Prerequisites

Block A must be complete — domain identity must exist as both SysML and OWL infrastructure before obligations can bind to domains.

### 4.3 Key questions to resolve (discussion paper or design within the block)

1. **OWL class design for activation classes.** `GovernanceFrameworkActivation`, `BoundObligation`, `ComplianceAssessment` need concrete OWL 2 DL class definitions, following the same approach as the [[ontara-discussion-deontic-owl-class-design-2026-04-03|Session 125 OWL class design paper]]. What are their BFO groundings? `GovernanceFrameworkActivation` is likely a BFO `process` (the act of adopting a framework) or a `generically dependent continuant` (the ongoing state of having adopted it). `BoundObligation` may be an `information content entity` that relates a directive to a service model element. These need careful design.

2. **Binding target vocabulary.** What can an obligation bind to? The Session 121 paper lists "a role in ResourcePlanning, a process in ActivityModel, a location in ResourcePlanning." In OWL terms, this means `BoundObligation` needs object properties that range over BMM classes. Which BMM classes are valid binding targets? All 34? A subset? This determines the object property declarations.

3. **Applicability assessment logic.** The Session 121 paper describes four assessment outcomes: `applicable`, `not applicable`, `conditionally applicable`, `indeterminate`. How is this represented in OWL? As data properties on `BoundObligation`? As an enumeration class? As SPARQL query results? The choice affects whether applicability assessment is a reasoning task (OWL classification) or a query task (SPARQL).

4. **Relationship between `GovernanceFramework` (SMM) and `GovernanceFrameworkActivation` (BMM).** Session 124 resolved S121-Q1: the framework itself is SMM-side (platform infrastructure), the activation is BMM-side (tenant's adoption). The horizontal mapping ([[concept-horizontal-mappings|B12]]) between them needs concrete implementation.

### 4.4 Implementation steps

1. Design OWL classes for activation tier (discussion paper or design section) [Chat]
2. Author activation tier Turtle (`ontara-governance-activation.ttl` or extend `ontara-governance.ttl`) [Chat/Code]
3. Create test activation: CQC framework activated against a demonstrator domain [Chat/Code]
4. Create test bound obligations: CQC Regulation 12 obligations bound to domain service model elements [Chat/Code]
5. Extend SPARQL validation suite for activation tier content [Code]
6. Validate: HermiT consistency, SPARQL queries [Code]
7. Extend Ontara Console governance view to display activation state (if time permits) [Code]

### 4.5 Deliverables

- OWL: activation tier classes, properties, test individuals
- Validation: extended SPARQL suite, HermiT consistency with activation tier content
- Possibly: console governance view extension

## 5. Block C — Ears as Exercise Vehicle

### 5.1 Objective

Introduce Ears as a formally defined domain (using Block A infrastructure), activate CQC governance against it (using Block B infrastructure), and use the combination to validate and refine both domain handling and governance activation.

### 5.2 Prerequisites

Blocks A and B must be substantially complete. Ears does not need to wait for *every* detail to be finalised — it can serve as the driver that surfaces remaining gaps.

### 5.3 Scope

1. **Define [[domain-ears|Ears]] as a `DomainDefinition`.** Regulatory tier: `sectorRegulated`. Jurisdiction: England. Regulated activities: treatment, diagnostic and screening procedures. This exercises the Block A infrastructure with a sector-regulated domain for the first time (beyond GSL).

2. **Author initial Ears service model elements.** Enough BMM instantiation to serve as binding targets for governance obligations — at minimum: a service concept, key activity types, resource requirements, and governance mapping entries. This is lightweight domain modelling, not full Ears build-out.

3. **Activate CQC governance framework against [[domain-ears|Ears]].** Exercise the full activation process from Block B: applicability assessment, obligation binding, gap identification. The existing CQC Regulation 12 individuals provide the content; Ears provides the target.

4. **Assess convergence quality.** Does the activation process produce sensible results? Are the right obligations binding to the right service model elements? Are gaps identified correctly? Does the domain identity infrastructure carry enough information for the activation process to work?

5. **Health-domain specifics (deferred).** OGMS adoption, clinical pathway modelling, archetype design — these are Ears-specific concerns that add domain depth but are not needed to validate the infrastructure. They remain for future sessions.

### 5.4 Deliverables

- SysML + OWL: Ears domain definition (both representations)
- SysML: initial Ears service model elements (lightweight)
- OWL: CQC framework activation against Ears, with bound obligations
- Validation findings: what worked, what needs refinement
- Refinement items fed back to Block A/B infrastructure

## 6. Sequencing and Dependencies

```
Block A: Domain Identity Infrastructure
  ├── Discussion paper (1 session)
  ├── SysML implementation (1–2 sessions)
  ├── OWL implementation + pipeline (1–2 sessions)
  │
  ▼
Block B: Governance Activation Tier
  ├── OWL class design (1 session — may be part of Block A paper or separate)
  ├── Activation tier implementation (1–2 sessions)
  ├── Test activation against existing domain (1 session)
  │
  ▼
Block C: Ears Exercise
  ├── Ears domain definition + initial model (1 session)
  ├── CQC activation against Ears (1–2 sessions)
  ├── Assessment and refinement (1 session)
```

Blocks are sequential but not rigidly so — if design questions for Block B arise during Block A, they can be addressed in the Block A discussion paper to avoid a separate design phase later. Similarly, the Ears domain definition (Block C, step 1) could be prepared during Block B if the infrastructure is ready.

## 7. Register Connections

### 7.1 Existing concepts exercised

| Concept | How exercised |
|---|---|
| [[principle-separation-representation-execution|A1]] (separation of representation and execution) | Domain identity moves from configuration to representation layer |
| [[principle-model-generates-everything|A3]] (model generates everything) | Domain properties derive from model, not hardcoded config |
| [[principle-two-meta-model-distinction|A4]] (two meta model distinction) | Domain identity's dual-stack placement is an A4 question |
| [[principle-intrinsic-self-knowledge|A10]] (intrinsic self-knowledge) | System knows its own domains from model state |
| [[concept-multi-tenancy|A13]] (multi-tenancy, T1 candidate) | First concrete implementation of "every domain is a tenant" |
| [[concept-horizontal-mappings|B12]] (horizontal mappings) | GovernanceFramework (SMM) ↔ GovernanceFrameworkActivation (BMM) |
| [[ontara-discussion-domain-identity-architecture-2026-03-22-v2.1|B15]] (domain identity) | Direct implementation of this concept |
| [[concept-dual-stack-architecture|B21]] (dual-stack architecture) | Domain identity must be placed within the dual stack |
| [[concept-knowledge-graph|B22]] (knowledge graph) | Domain identity represented in OWL alongside governance |
| [[concept-bfo-ontological-grounding|B23]] (OWL 2 DL) | Activation tier classes are OWL 2 DL |
| B30–B35 ([[ontara-discussion-deontic-governance-architecture-2026-04-03|governance vocabulary]]) | Activation tier builds directly on the library tier |
| [[concept-co-evolution|J2]] (co-evolution) | Model, OWL, generator, and console evolve together |
| [[concept-non-constraining|J3]] (non-constraining) | Architecture supports future domains and frameworks |

### 7.2 Potential new concepts

| Candidate | Description | Tier |
|---|---|---|
| Governance framework activation | The mechanism connecting library-tier obligations to specific domains | T2 |
| Bound obligation | Instance-level binding of a directive to a service model element | T3 |
| Domain lifecycle | Creation, activation, modification, retirement of domains | T3 (future) |

### 7.3 A13 promotion decision

This workstream is the natural point to decide whether A13 (multi-tenancy) should be promoted from T1 candidate to binding T1 principle. The Block A discussion paper should address this explicitly.

## 8. Risks and Open Questions

| # | Risk/Question | Mitigation |
|---|---|---|
| R1 | B15 design is 80+ sessions old — may need substantial revision | Block A discussion paper explicitly revisits B15 in light of dual-stack, KG, and governance. Retain what still works; redesign what doesn't. |
| R2 | OWL representation of domain identity may be complex (BFO grounding of "a service business" vs "a model of a service business") | Address in Block A discussion paper. May need careful ontological separation — the domain-as-real-entity vs the domain-as-model-artefact. |
| R3 | Activation tier OWL design may expose tensions between the S121 paper's design and OWL 2 DL constraints | Follow the same approach as [[ontara-discussion-deontic-owl-class-design-2026-04-03|Session 125]] (OWL class design paper): systematic translation of conceptual design to OWL-expressible form. |
| R4 | [[domain-ears|Ears]] service model requires health-domain knowledge that may distract from infrastructure goals | Keep Ears deliberately lightweight in Block C — enough to exercise the machinery, not a full clinical domain. Health-domain depth is for later. |
| R5 | Scope creep — the convergence naturally touches many parts of the architecture | Each block has a clear deliverable set. Work that doesn't directly serve the block's objective goes in the emergent ideas log or work item tracker, not into the current session. |

---

*Plan produced Session 141, 5 April 2026. Addresses the convergence of domain management ([[ontara-discussion-domain-identity-architecture-2026-03-22-v2.1|B15]], [[concept-multi-tenancy|A13]]) and platform governance (B30–B35) identified as the project's next major direction.*
