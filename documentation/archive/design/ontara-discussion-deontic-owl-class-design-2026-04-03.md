---
tags:
  - architecture
  - discussion
  - governance
  - ontology
date: 2026-04-03
status: working
session: 125
---
# Deontic Governance Vocabulary: OWL Class Design

*Ontara Platform — Discussion Paper*

**Date:** 3 April 2026 (Session 125)
**Purpose:** Concrete OWL 2 DL class hierarchy, object properties, data properties, enumeration classes, and axioms for the deontic governance vocabulary described in §5–§7 of the [[ontara-discussion-deontic-governance-architecture-2026-04-03|Deontic Governance Architecture paper (Session 121)]]. This paper is the implementation specification for the governance ontology module.
**Status:** Working document — detailed design. Resolves S121-Q3.
**Depends on:** [[ontara-discussion-deontic-governance-architecture-2026-04-03|Deontic Governance Architecture (Session 121)]], [[ontara-discussion-knowledge-graph-architecture-2026-04-01|Knowledge Graph Architecture (Session 97)]], [[ontara-discussion-bfo-type-mapping-2026-04-01|@BfoType Mapping (Session 98)]]

---

## Contents

- [[#1. Scope and Approach|§1. Scope and Approach]]
- [[#2. IRI Namespace and Ontology Module Structure|§2. IRI Namespace and Ontology Module Structure]]
- [[#3. BFO and IAO Grounding|§3. BFO and IAO Grounding]]
- [[#4. Class Hierarchy|§4. Class Hierarchy]]
- [[#5. Enumeration Classes|§5. Enumeration Classes]]
- [[#6. Object Properties|§6. Object Properties]]
- [[#7. Data Properties|§7. Data Properties]]
- [[#8. Axioms|§8. Axioms]]
- [[#9. Relationship to Existing BMM Ontology|§9. Relationship to Existing BMM Ontology]]
- [[#10. Turtle Specification|§10. Turtle Specification]]
- [[#11. Design Decisions|§11. Design Decisions]]
- [[#12. Implementation Notes|§12. Implementation Notes]]
- [[#13. Register Connections|§13. Register Connections]]

---

## 1. Scope and Approach

This paper designs the OWL 2 DL class structure for the **obligation vocabulary** — the representational primitives that make governance requirements machine-readable in the [[concept-knowledge-graph|knowledge graph (B22)]]. The scope covers:

- The four deontic directive types and their root class (§5.1 of the governance paper)
- Structural properties of deontic directives (§5.2) — as object and data properties
- Obligation composition patterns (§5.3) — as object properties
- The normative instrument taxonomy (§6) — as a class hierarchy
- Obligation groups and governance frameworks (§7) — as classes

**Explicitly deferred:** The activation tier (`GovernanceFrameworkActivation`, `BoundObligation`) and the operational tier (`ComplianceAssessment`, compliance states, evidence management). These depend on the vocabulary existing first and are instance-level patterns that will be designed once the vocabulary is exercised against a real governance framework (S121-Q5, MVP implementation path).

This follows the same approach as [[session-100-kg-implementation-plan|Stage 5 Phase 1]]: define classes and properties first, populate instances later.

## 2. IRI Namespace and Ontology Module Structure

The governance vocabulary uses a **separate IRI namespace** from the BMM ontology:

| Namespace | Prefix | Purpose |
|---|---|---|
| `https://ontara.dev/ontology/governance/` | `ontara-gov:` | Governance vocabulary classes |
| `https://ontara.dev/ontology/governance/axioms#` | `ontara-gov-ax:` | Governance vocabulary object and data properties |
| `https://ontara.dev/ontology/bmm/` | `ontara-bmm:` | Existing BMM classes (referenced, not modified) |

**Rationale (S125-D1).** The governance vocabulary is a distinct ontology module, not an extension of the BMM. It lives in the same [[concept-three-stratum-knowledge-graph|domain graph (B28)]] but addresses a different conceptual domain — deontic norms, normative instruments, and framework structures. The BMM describes *what a service business is*; the governance vocabulary describes *what obligations govern it*. They connect via the binding mechanism (deferred) and via the existing `GovernanceRequirement` BMM class, but they are ontologically separate.

**File convention.** The Turtle file will be `ontara-governance.ttl`, placed in `generated/ontology/` (if pipeline-generated) or `ontology/` (if hand-authored). Given the absence of a SysML source for these classes, this will be a **hand-authored ontology** following the same pattern as `ontara-bmm-axioms.ttl` — OWL-authoritative per [[concept-authority-zones|B29]].

**Ontology imports.** The governance ontology imports:
- The IAO ontology (for `directive_information_entity` and `document`)
- The BMM ontology (for cross-references to `GovernanceRequirement`)

## 3. BFO and IAO Grounding

### 3.1 Deontic directives

Following Donohue (2017) and the analysis in §4 of the [[ontara-discussion-deontic-governance-architecture-2026-04-03|governance paper]], deontic directives are grounded as directive information entities:

```
BFO:entity
  → BFO:continuant (BFO_0000002)
    → BFO:generically_dependent_continuant (BFO_0000031)
      → IAO:information_content_entity (IAO_0000030)
        → IAO:directive_information_entity (IAO_0000033)
          → ontara-gov:DeonticDirective
            ├── ontara-gov:Obligation
            ├── ontara-gov:Permission
            ├── ontara-gov:Prohibition
            └── ontara-gov:RegulatoryPower
```

This grounding captures the essential nature of deontic directives:

- **Generic dependence.** A directive can be concretized in multiple bearers — the same CQC regulation applies to every registered provider. This underpins the governance framework library concept ([[ontara-ref-master-register|B31]]).
- **Directiveness.** A directive information entity is not merely descriptive — it directs its bearer toward or away from states of affairs. This is the defining character of obligations, permissions, and prohibitions.
- **IAO alignment.** The existing ontology stack already loads IAO. The governance vocabulary extends IAO rather than introducing a new mid-level ontology.

### 3.2 Normative instruments

Normative instruments — the source documents from which directives are derived — are grounded as IAO documents:

```
BFO:entity
  → BFO:continuant (BFO_0000002)
    → BFO:generically_dependent_continuant (BFO_0000031)
      → IAO:information_content_entity (IAO_0000030)
        → IAO:document (IAO_0000310)
          → ontara-gov:NormativeInstrument
            ├── ontara-gov:PrimaryLegislation
            ├── ontara-gov:SecondaryLegislation
            ├── ... (11 subtypes)
            └── ontara-gov:CaseLaw
```

A normative instrument *contains* deontic directives but is not itself a directive. The Health and Social Care Act 2008 is a document; the specific obligations it imposes are directive information entities. The `isSourceOf` / `derivesFrom` properties connect them.

### 3.3 Grouping and framework constructs

Obligation groups and governance frameworks are information content entities — structured collections that organise deontic directives for administrative and assessment purposes:

```
IAO:information_content_entity (IAO_0000030)
  → ontara-gov:ObligationGroup
  → ontara-gov:GovernanceFramework
```

They are not directive information entities — they do not themselves direct behaviour. They organise and curate directives.

### 3.4 Relationship to GovernanceRequirement

The existing BMM class `ontara-bmm:GovernanceRequirement` is mapped to `IAO_0000005` (objective specification), which is a sibling of `directive_information_entity` under `information_content_entity`:

```
IAO:information_content_entity (IAO_0000030)
  ├── IAO:directive_information_entity (IAO_0000033)
  │     └── ontara-gov:DeonticDirective
  └── IAO:objective_specification (IAO_0000005)
        └── ontara-bmm:GovernanceRequirement
```

**Decision (S125-D4).** `GovernanceRequirement` and `DeonticDirective` remain siblings, not in a subclass relationship. They serve different abstraction levels: `GovernanceRequirement` is the BMM meta model's representation of what the business must comply with; `DeonticDirective` is the formally decomposed obligation in the knowledge graph. The `BoundObligation` (deferred) connects them at instance level.

## 4. Class Hierarchy

### 4.1 Complete class listing

| Class | Parent | BFO Path | Description |
|---|---|---|---|
| `DeonticDirective` | `IAO_0000033` | GDC → ICE → DIE | Root class for all formally represented normative requirements. Every deontic directive has a modality, content, subject, applicability scope, and provenance to a normative instrument. |
| `Obligation` | `DeonticDirective` | as above | A directive requiring a state of affairs to obtain or an action to be performed by the bearer. |
| `Permission` | `DeonticDirective` | as above | A directive allowing a state of affairs to obtain or an action to be performed. Not merely the absence of prohibition — a positive authorisation with its own conditions. |
| `Prohibition` | `DeonticDirective` | as above | A directive requiring a state of affairs not to obtain or an action not to be performed. |
| `RegulatoryPower` | `DeonticDirective` | as above | A directive conferring capacity to create, modify, or extinguish deontic relations. Second-order: operates on the obligation landscape itself. |
| `NormativeInstrument` | `IAO_0000310` | GDC → ICE → Document | A source document from which deontic directives are derived. Carries identity, authority type, jurisdiction, effective date, currency status. |
| `PrimaryLegislation` | `NormativeInstrument` | as above | Statute enacted by Parliament; highest domestic authority. |
| `SecondaryLegislation` | `NormativeInstrument` | as above | Regulations made under statutory powers. |
| `StatutoryGuidance` | `NormativeInstrument` | as above | Guidance issued under statutory authority. |
| `RegulatoryStandard` | `NormativeInstrument` | as above | Standards set by a regulator as conditions of registration or licensing. |
| `ProfessionalStandard` | `NormativeInstrument` | as above | Standards set by a professional body governing individual practitioners. |
| `CodeOfPractice` | `NormativeInstrument` | as above | Non-statutory but influential guidance. |
| `TechnicalStandard` | `NormativeInstrument` | as above | Specifications for technical compliance. |
| `CommissioningFramework` | `NormativeInstrument` | as above | Requirements set by commissioners as conditions of service contracts. |
| `ContractualObligation` | `NormativeInstrument` | as above | Requirements arising from contracts. |
| `InternalStandard` | `NormativeInstrument` | as above | Self-imposed quality or governance standards. |
| `CaseLaw` | `NormativeInstrument` | as above | Judicial interpretation of statutory or common law obligations. |
| `ObligationGroup` | `IAO_0000030` | GDC → ICE | A high-level organising category collecting related directives. CQC's five key questions are obligation groups. Compliance state derived from constituent directives. |
| `GovernanceFramework` | `IAO_0000030` | GDC → ICE | A curated, versioned, machine-readable collection of deontic directives from one or more normative sources, maintained at platform level ([[ontara-ref-master-register\|B31]]). |

**Total: 19 classes** (4 deontic directive types + 1 root + 11 normative instrument types + 1 normative instrument root + obligation group + governance framework).

### 4.2 Class hierarchy diagram

```
IAO:information_content_entity (IAO_0000030)
│
├── IAO:directive_information_entity (IAO_0000033)
│     └── ontara-gov:DeonticDirective
│           ├── ontara-gov:Obligation
│           ├── ontara-gov:Permission
│           ├── ontara-gov:Prohibition
│           └── ontara-gov:RegulatoryPower
│
├── IAO:document (IAO_0000310)
│     └── ontara-gov:NormativeInstrument
│           ├── ontara-gov:PrimaryLegislation
│           ├── ontara-gov:SecondaryLegislation
│           ├── ontara-gov:StatutoryGuidance
│           ├── ontara-gov:RegulatoryStandard
│           ├── ontara-gov:ProfessionalStandard
│           ├── ontara-gov:CodeOfPractice
│           ├── ontara-gov:TechnicalStandard
│           ├── ontara-gov:CommissioningFramework
│           ├── ontara-gov:ContractualObligation
│           ├── ontara-gov:InternalStandard
│           └── ontara-gov:CaseLaw
│
├── ontara-gov:ObligationGroup
│
└── ontara-gov:GovernanceFramework
```

## 5. Enumeration Classes

Enumeration classes are modelled as OWL classes with named individuals as members, following the OWL enumeration pattern (`owl:oneOf`). This allows reasoner classification and SPARQL querying.

### 5.1 ContentModality

Describes the character of what a deontic directive governs (§5.2 of the governance paper).

| Individual | Description |
|---|---|
| `StateOriented` | A condition that must (or must not) obtain — "premises are suitable" |
| `ActionOriented` | An action that must (or must not) be performed — "conduct a risk assessment" |
| `AchievementOriented` | An outcome that must be reached — "ensure effective governance" |

### 5.2 TemporalScopeType

Describes when and how a directive applies over time (§5.2).

| Individual | Description |
|---|---|
| `Continuous` | Must be satisfied at all times — "premises must be safe" |
| `Periodic` | Must be satisfied at regular intervals — "annual fire risk assessment" |
| `Triggered` | Activated by an event — "notify CQC within 28 days of a change" |
| `DeadlineBounded` | Must be satisfied by a specific date |
| `Transitional` | Applies during a defined transition period |

### 5.3 SanctionSeverity

Severity classification for non-compliance consequences (§5.2).

| Individual | Description |
|---|---|
| `Administrative` | Warning, condition on registration, improvement notice |
| `Enforcement` | Suspension, cancellation of registration, fixed penalty |
| `Criminal` | Prosecution, criminal liability |

### 5.4 AuthorityType

Classification of the authority from which a normative instrument derives (§6.2).

| Individual | Description |
|---|---|
| `Statutory` | Authority derived from legislation |
| `QuasiStatutory` | Regulatory or quasi-judicial authority |
| `Professional` | Authority of a professional body |
| `Contractual` | Authority derived from contract |
| `Voluntary` | Voluntarily adopted standards |
| `Internal` | Self-imposed by the organisation |

### 5.5 EndorsementStatus

The review status of a governance framework's formalisation (§7.2).

| Individual | Description |
|---|---|
| `Unreviewed` | Machine-generated draft, not yet reviewed |
| `ExpertReviewed` | Reviewed by a domain expert |
| `AuthorityEndorsed` | Endorsed by the relevant regulatory body |
| `CommunityValidated` | Reviewed and validated by a community of practitioners |

### 5.6 CurrencyStatus

The currency status of a normative instrument (§6.2).

| Individual | Description |
|---|---|
| `Current` | The instrument is in force and reflects the current legal/regulatory position |
| `Amended` | The instrument has been amended; the amended version is current |
| `Superseded` | The instrument has been replaced by a newer version |
| `Repealed` | The instrument has been formally withdrawn or revoked |

**Total: 6 enumeration classes, 24 named individuals.**

## 6. Object Properties

Object properties capture the structural relationships between governance vocabulary classes.

### 6.1 Deontic directive properties

| Property | Domain | Range | Characteristics | Description |
|---|---|---|---|---|
| `hasContentModality` | `DeonticDirective` | `ContentModality` | Functional | Whether the directive governs a state, an action, or an achievement. |
| `hasTemporalScope` | `DeonticDirective` | `TemporalScopeType` | Functional | How the directive applies over time. |
| `hasSanctionSeverity` | `DeonticDirective` | `SanctionSeverity` | Functional | The severity classification for non-compliance. |
| `derivesFrom` | `DeonticDirective` | `NormativeInstrument` | — | Provenance: the normative instrument(s) from which this directive is derived. |
| `hasException` | `DeonticDirective` | `DeonticDirective` | — | Defeasibility: the directive that overrides this one under specified conditions. Models exception relationships explicitly, preserving OWL 2 DL monotonicity (S121-D4). |
| `belongsToGroup` | `DeonticDirective` | `ObligationGroup` | — | Group membership. A directive may belong to multiple groups. |
| `hasComponentDirective` | `DeonticDirective` | `DeonticDirective` | — | Composite obligation decomposition: all components must be satisfied for the composite to be satisfied. |
| `hasAlternativeSatisfaction` | `DeonticDirective` | `DeonticDirective` | — | Alternative satisfaction: any one of the linked directives suffices. |
| `triggersObligation` | `DeonticDirective` | `DeonticDirective` | — | Cascading obligations: activation of this directive triggers further directives. |

### 6.2 Normative instrument properties

| Property | Domain | Range | Characteristics | Description |
|---|---|---|---|---|
| `isSourceOf` | `NormativeInstrument` | `DeonticDirective` | InverseOf `derivesFrom` | The directives that this instrument yields. |
| `hasAuthorityType` | `NormativeInstrument` | `AuthorityType` | Functional | The type of authority from which the instrument derives. |
| `hasCurrencyStatus` | `NormativeInstrument` | `CurrencyStatus` | Functional | Whether the instrument is current, amended, superseded, or repealed. |
| `supersedesInstrument` | `NormativeInstrument` | `NormativeInstrument` | — | Version lineage: this instrument replaces the target. |
| `implementsInstrument` | `NormativeInstrument` | `NormativeInstrument` | — | Secondary legislation implements primary legislation. |
| `interpretsInstrument` | `NormativeInstrument` | `NormativeInstrument` | — | Case law or guidance interprets statute or regulation. |
| `crossReferencesInstrument` | `NormativeInstrument` | `NormativeInstrument` | — | Instruments that reference each other. Symmetric. |

### 6.3 Framework properties

| Property | Domain | Range | Characteristics | Description |
|---|---|---|---|---|
| `containsDirective` | `GovernanceFramework` | `DeonticDirective` | — | Framework membership: the directives in this framework. |
| `hasSourceInstrument` | `GovernanceFramework` | `NormativeInstrument` | — | The normative instruments from which this framework's directives are derived. |
| `hasEndorsementStatus` | `GovernanceFramework` | `EndorsementStatus` | Functional | The review status of the framework's formalisation. |
| `containsGroup` | `GovernanceFramework` | `ObligationGroup` | — | The obligation groups defined within this framework. |

**Total: 20 object properties.**

## 7. Data Properties

Data properties capture textual and scalar attributes. Several of these are deliberately `xsd:string` rather than structured object references — a pragmatic choice for the first iteration, with the option to promote to structured classes as the representation matures (S125-D5).

### 7.1 Deontic directive data properties

| Property | Domain | Range | Description |
|---|---|---|---|
| `directiveContent` | `DeonticDirective` | `xsd:string` | Textual description of what is required, permitted, or prohibited. |
| `applicabilityCondition` | `DeonticDirective` | `xsd:string` | Textual description of the circumstances under which the directive is active. |
| `exceptionCondition` | `DeonticDirective` | `xsd:string` | Textual description of the circumstances under which the directive is overridden. Complements the `hasException` object property. |
| `evidentialSpecification` | `DeonticDirective` | `xsd:string` | What constitutes evidence of compliance — document types, records, processes, qualifications. |
| `freshnessRequirement` | `DeonticDirective` | `xsd:string` | How recently evidence must have been produced or reviewed. |
| `sourceReference` | `DeonticDirective` | `xsd:string` | Specific clause, section, or regulation reference in the source instrument. |

### 7.2 Normative instrument data properties

| Property | Domain | Range | Description |
|---|---|---|---|
| `instrumentTitle` | `NormativeInstrument` | `xsd:string` | Full title of the instrument. |
| `instrumentReference` | `NormativeInstrument` | `xsd:string` | Formal reference number or citation. |
| `issuingAuthority` | `NormativeInstrument` | `xsd:string` | The body responsible for the instrument. |
| `jurisdiction` | `NormativeInstrument` | `xsd:string` | Territorial and sectoral scope. |
| `effectiveDate` | `NormativeInstrument` | `xsd:date` | When the instrument came into force. |
| `amendedDate` | `NormativeInstrument` | `xsd:date` | When the instrument was last amended (if applicable). |

### 7.3 Framework data properties

| Property | Domain | Range | Description |
|---|---|---|---|
| `frameworkVersion` | `GovernanceFramework` | `xsd:string` | Version identifier. |
| `currencyDate` | `GovernanceFramework` | `xsd:date` | The date up to which the framework reflects the current state of its source instruments. |
| `formalisationProvenance` | `GovernanceFramework` | `xsd:string` | Who formalised this framework, when, and through what process. |

### 7.4 Obligation group data properties

| Property | Domain | Range | Description |
|---|---|---|---|
| `groupLabel` | `ObligationGroup` | `xsd:string` | Display name for the group (e.g. "Safe", "Effective"). |

**Total: 16 data properties.**

## 8. Axioms

### 8.1 Disjointness axioms

**Deontic directive modalities.** The four subclasses of `DeonticDirective` are pairwise disjoint — a directive has exactly one modality:

```
DisjointClasses: Obligation, Permission, Prohibition, RegulatoryPower
```

**Normative instrument types.** The eleven subclasses of `NormativeInstrument` are pairwise disjoint — a document is exactly one type:

```
DisjointClasses: PrimaryLegislation, SecondaryLegislation, StatutoryGuidance,
  RegulatoryStandard, ProfessionalStandard, CodeOfPractice, TechnicalStandard,
  CommissioningFramework, ContractualObligation, InternalStandard, CaseLaw
```

**Top-level classes.** `DeonticDirective`, `NormativeInstrument`, `ObligationGroup`, and `GovernanceFramework` are pairwise disjoint — they are ontologically distinct categories:

```
DisjointClasses: DeonticDirective, NormativeInstrument, ObligationGroup,
  GovernanceFramework
```

### 8.2 Existential restrictions

**Every deontic directive derives from at least one normative instrument.** This is a structural completeness requirement — no directive exists without provenance:

```
DeonticDirective ⊑ ∃derivesFrom.NormativeInstrument
```

In OWL:
```turtle
ontara-gov:DeonticDirective rdfs:subClassOf [
    a owl:Restriction ;
    owl:onProperty ontara-gov-ax:derivesFrom ;
    owl:someValuesFrom ontara-gov:NormativeInstrument
] .
```

### 8.3 Cardinality restrictions

**Every deontic directive has exactly one content modality:**

```
DeonticDirective ⊑ =1 hasContentModality.ContentModality
```

**Every deontic directive has exactly one temporal scope:**

```
DeonticDirective ⊑ =1 hasTemporalScope.TemporalScopeType
```

**Every normative instrument has exactly one authority type:**

```
NormativeInstrument ⊑ =1 hasAuthorityType.AuthorityType
```

**Every normative instrument has exactly one currency status:**

```
NormativeInstrument ⊑ =1 hasCurrencyStatus.CurrencyStatus
```

**Every governance framework has exactly one endorsement status:**

```
GovernanceFramework ⊑ =1 hasEndorsementStatus.EndorsementStatus
```

### 8.4 Property axioms

**Inverse property declaration:**

```
isSourceOf owl:inverseOf derivesFrom
```

**Symmetric property:**

```
crossReferencesInstrument rdf:type owl:SymmetricProperty
```

### 8.5 Covering axiom (optional, for discussion)

A covering axiom would assert that every `DeonticDirective` is either an `Obligation`, `Permission`, `Prohibition`, or `RegulatoryPower`:

```
DeonticDirective ≡ Obligation ⊔ Permission ⊔ Prohibition ⊔ RegulatoryPower
```

This is stronger than mere subclassing — it says the four subtypes *exhaust* the directive space. Combined with the disjointness axiom, it gives a complete partition. The equivalent OWL pattern is used for the BMM concern group union classes in [[ontara-ref-master-register|ontara-bmm-axioms.ttl]] (e.g. `ActivityModelElement ≡ ActivityBudget ⊔ ... ⊔ ActivityType`).

**Recommendation:** Include it. The four modalities are a closed set from deontic logic; if a fifth is ever needed, it's a deliberate extension, not something that should slip in unnoticed.

Similarly for `NormativeInstrument`:

```
NormativeInstrument ≡ PrimaryLegislation ⊔ ... ⊔ CaseLaw
```

**Recommendation:** Include it for the same reason — the taxonomy is intentionally closed and versioned.

## 9. Relationship to Existing BMM Ontology

### 9.1 No modification to existing classes

This design **does not modify** any existing BMM class. `GovernanceRequirement` retains its current BFO mapping (`IAO_0000005`), its current properties, and its position in the concern group disjointness axioms. The governance vocabulary is a new, separate ontology module.

### 9.2 Connection points (for future activation tier)

When the activation tier is designed, the connection points will be:

- `BoundObligation` (a new BMM class in GovernanceMapping) will reference both a `DeonticDirective` from the governance vocabulary and a target element from the BMM.
- `GovernanceFrameworkActivation` (a new BMM class in GovernanceMapping) will reference a `GovernanceFramework` from the governance vocabulary.
- `GovernanceRequirement` may gain a new object property linking it to the `DeonticDirective` that formally represents the same obligation, once the [[ontara-ref-master-register|binding mechanism (B32)]] is built.

### 9.3 Authority zones

Per [[concept-authority-zones|B29]]:

- The governance vocabulary (class definitions, property characteristics, axioms) is **OWL-authoritative** — it is hand-authored in OWL, not generated from SysML.
- Labels and definitions are **shared-constrained** — they must be consistent across OWL and any future SysML representation.
- Structural integration with the BMM (the activation tier) will be **SysML-authoritative** for the structural relationships, with OWL correspondence records in the [[concept-three-stratum-knowledge-graph|correspondence graph (B28)]].

## 10. Turtle Specification

The following is the complete Turtle representation of the governance vocabulary. This is the authoritative specification — it can be loaded directly into [[concept-knowledge-graph|GraphDB]] and validated with [[concept-bfo-ontological-grounding|Robot + HermiT]].

```turtle
@prefix bfo: <http://purl.obolibrary.org/obo/> .
@prefix dcterms: <http://purl.org/dc/terms/> .
@prefix ontara-bmm: <https://ontara.dev/ontology/bmm/> .
@prefix ontara-gov: <https://ontara.dev/ontology/governance/> .
@prefix ontara-gov-ax: <https://ontara.dev/ontology/governance/axioms#> .
@prefix owl: <http://www.w3.org/2002/07/owl#> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix skos: <http://www.w3.org/2004/02/skos/core#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .


# =============================================================================
# Ontology declaration
# =============================================================================

ontara-gov: a owl:Ontology ;
    rdfs:label "Ontara Governance Vocabulary"@en ;
    dcterms:created "2026-04-03"^^xsd:date ;
    rdfs:comment "OWL 2 DL representation of the deontic governance vocabulary for the Ontara platform. Grounded in BFO 2020 via IAO. Designed Session 125, following the Deontic Governance Architecture paper (Session 121)."@en ;
    owl:versionInfo "Session 125 — initial design"@en .


# =============================================================================
# Classes — Deontic Directives
# =============================================================================

ontara-gov:DeonticDirective a owl:Class ;
    rdfs:label "Deontic Directive"@en ;
    rdfs:subClassOf bfo:IAO_0000033 ;
    rdfs:comment "A formally represented normative requirement. Every deontic directive has a modality (obligation, permission, prohibition, or power), content, a subject, an applicability scope, and provenance to a normative instrument."@en ;
    skos:definition "The root class for all formally represented normative requirements in the Ontara governance vocabulary. Subclass of IAO directive information entity, following Donohue (2017)."@en .

ontara-gov:Obligation a owl:Class ;
    rdfs:label "Obligation"@en ;
    rdfs:subClassOf ontara-gov:DeonticDirective ;
    rdfs:comment "A deontic directive requiring a state of affairs to obtain or an action to be performed by the bearer."@en ;
    skos:definition "A deontic directive requiring a state of affairs to obtain or an action to be performed by the bearer. The core normative modality — what the bearer must do or ensure."@en .

ontara-gov:Permission a owl:Class ;
    rdfs:label "Permission"@en ;
    rdfs:subClassOf ontara-gov:DeonticDirective ;
    rdfs:comment "A deontic directive allowing a state of affairs to obtain or an action to be performed. Not merely the absence of prohibition — a positive authorisation that may carry its own conditions."@en ;
    skos:definition "A deontic directive allowing a state of affairs to obtain or an action to be performed. A positive authorisation, not merely the absence of prohibition."@en .

ontara-gov:Prohibition a owl:Class ;
    rdfs:label "Prohibition"@en ;
    rdfs:subClassOf ontara-gov:DeonticDirective ;
    rdfs:comment "A deontic directive requiring a state of affairs not to obtain or an action not to be performed."@en ;
    skos:definition "A deontic directive requiring a state of affairs not to obtain or an action not to be performed. The negative modality — what the bearer must not do."@en .

ontara-gov:RegulatoryPower a owl:Class ;
    rdfs:label "Regulatory Power"@en ;
    rdfs:subClassOf ontara-gov:DeonticDirective ;
    rdfs:comment "A deontic directive conferring capacity to create, modify, or extinguish deontic relations. Second-order: operates on the obligation landscape itself."@en ;
    skos:definition "A deontic directive conferring capacity to create, modify, or extinguish deontic relations. Second-order: it operates on the obligation landscape itself, not directly on service operations."@en .


# =============================================================================
# Classes — Normative Instruments
# =============================================================================

ontara-gov:NormativeInstrument a owl:Class ;
    rdfs:label "Normative Instrument"@en ;
    rdfs:subClassOf bfo:IAO_0000310 ;
    rdfs:comment "A source document from which deontic directives are derived. Carries identity, authority type, jurisdiction, effective date, and currency status."@en ;
    skos:definition "A document that is the source of one or more deontic directives — legislation, regulation, guidance, standard, or other normative source. The instrument contains directives but is not itself a directive."@en .

ontara-gov:PrimaryLegislation a owl:Class ;
    rdfs:label "Primary Legislation"@en ;
    rdfs:subClassOf ontara-gov:NormativeInstrument ;
    rdfs:comment "Statute enacted by Parliament; highest domestic authority."@en .

ontara-gov:SecondaryLegislation a owl:Class ;
    rdfs:label "Secondary Legislation"@en ;
    rdfs:subClassOf ontara-gov:NormativeInstrument ;
    rdfs:comment "Regulations made under statutory powers."@en .

ontara-gov:StatutoryGuidance a owl:Class ;
    rdfs:label "Statutory Guidance"@en ;
    rdfs:subClassOf ontara-gov:NormativeInstrument ;
    rdfs:comment "Guidance issued under statutory authority; regulators must 'have regard to' it."@en .

ontara-gov:RegulatoryStandard a owl:Class ;
    rdfs:label "Regulatory Standard"@en ;
    rdfs:subClassOf ontara-gov:NormativeInstrument ;
    rdfs:comment "Standards set by a regulator as conditions of registration or licensing."@en .

ontara-gov:ProfessionalStandard a owl:Class ;
    rdfs:label "Professional Standard"@en ;
    rdfs:subClassOf ontara-gov:NormativeInstrument ;
    rdfs:comment "Standards set by a professional body governing individual practitioners."@en .

ontara-gov:CodeOfPractice a owl:Class ;
    rdfs:label "Code of Practice"@en ;
    rdfs:subClassOf ontara-gov:NormativeInstrument ;
    rdfs:comment "Non-statutory but influential guidance."@en .

ontara-gov:TechnicalStandard a owl:Class ;
    rdfs:label "Technical Standard"@en ;
    rdfs:subClassOf ontara-gov:NormativeInstrument ;
    rdfs:comment "Specifications for technical compliance."@en .

ontara-gov:CommissioningFramework a owl:Class ;
    rdfs:label "Commissioning Framework"@en ;
    rdfs:subClassOf ontara-gov:NormativeInstrument ;
    rdfs:comment "Requirements set by commissioners as conditions of service contracts."@en .

ontara-gov:ContractualObligation a owl:Class ;
    rdfs:label "Contractual Obligation"@en ;
    rdfs:subClassOf ontara-gov:NormativeInstrument ;
    rdfs:comment "Requirements arising from contracts."@en .

ontara-gov:InternalStandard a owl:Class ;
    rdfs:label "Internal Standard"@en ;
    rdfs:subClassOf ontara-gov:NormativeInstrument ;
    rdfs:comment "Self-imposed quality or governance standards."@en .

ontara-gov:CaseLaw a owl:Class ;
    rdfs:label "Case Law"@en ;
    rdfs:subClassOf ontara-gov:NormativeInstrument ;
    rdfs:comment "Judicial interpretation of statutory or common law obligations."@en .


# =============================================================================
# Classes — Grouping and Framework
# =============================================================================

ontara-gov:ObligationGroup a owl:Class ;
    rdfs:label "Obligation Group"@en ;
    rdfs:subClassOf bfo:IAO_0000030 ;
    rdfs:comment "A high-level organising category collecting related deontic directives. CQC's five key questions (Safe, Effective, Caring, Responsive, Well-led) are obligation groups."@en ;
    skos:definition "A high-level organising category that collects related deontic directives for administrative and assessment purposes. An obligation group has a compliance state derived from its constituent directives."@en .

ontara-gov:GovernanceFramework a owl:Class ;
    rdfs:label "Governance Framework"@en ;
    rdfs:subClassOf bfo:IAO_0000030 ;
    rdfs:comment "A curated, versioned, machine-readable collection of deontic directives drawn from one or more normative sources, maintained at platform level and activatable by tenants."@en ;
    skos:definition "Ontara's formalisation of a coherent set of governance obligations from one or more normative instruments. Maintained as platform-level shared infrastructure (B31); activated by tenants."@en .


# =============================================================================
# Enumeration Classes
# =============================================================================

ontara-gov:ContentModality a owl:Class ;
    rdfs:label "Content Modality"@en ;
    owl:equivalentClass [ a owl:Class ;
        owl:oneOf ( ontara-gov:StateOriented
                    ontara-gov:ActionOriented
                    ontara-gov:AchievementOriented ) ] ;
    rdfs:comment "The character of what a deontic directive governs: a state, an action, or an achievement."@en .

ontara-gov:StateOriented a owl:NamedIndividual, ontara-gov:ContentModality ;
    rdfs:label "State-oriented"@en .
ontara-gov:ActionOriented a owl:NamedIndividual, ontara-gov:ContentModality ;
    rdfs:label "Action-oriented"@en .
ontara-gov:AchievementOriented a owl:NamedIndividual, ontara-gov:ContentModality ;
    rdfs:label "Achievement-oriented"@en .

ontara-gov:TemporalScopeType a owl:Class ;
    rdfs:label "Temporal Scope Type"@en ;
    owl:equivalentClass [ a owl:Class ;
        owl:oneOf ( ontara-gov:Continuous
                    ontara-gov:Periodic
                    ontara-gov:Triggered
                    ontara-gov:DeadlineBounded
                    ontara-gov:Transitional ) ] ;
    rdfs:comment "How a deontic directive applies over time."@en .

ontara-gov:Continuous a owl:NamedIndividual, ontara-gov:TemporalScopeType ;
    rdfs:label "Continuous"@en .
ontara-gov:Periodic a owl:NamedIndividual, ontara-gov:TemporalScopeType ;
    rdfs:label "Periodic"@en .
ontara-gov:Triggered a owl:NamedIndividual, ontara-gov:TemporalScopeType ;
    rdfs:label "Triggered"@en .
ontara-gov:DeadlineBounded a owl:NamedIndividual, ontara-gov:TemporalScopeType ;
    rdfs:label "Deadline-bounded"@en .
ontara-gov:Transitional a owl:NamedIndividual, ontara-gov:TemporalScopeType ;
    rdfs:label "Transitional"@en .

ontara-gov:SanctionSeverity a owl:Class ;
    rdfs:label "Sanction Severity"@en ;
    owl:equivalentClass [ a owl:Class ;
        owl:oneOf ( ontara-gov:Administrative
                    ontara-gov:Enforcement
                    ontara-gov:Criminal ) ] ;
    rdfs:comment "Severity classification for non-compliance consequences."@en .

ontara-gov:Administrative a owl:NamedIndividual, ontara-gov:SanctionSeverity ;
    rdfs:label "Administrative"@en .
ontara-gov:Enforcement a owl:NamedIndividual, ontara-gov:SanctionSeverity ;
    rdfs:label "Enforcement"@en .
ontara-gov:Criminal a owl:NamedIndividual, ontara-gov:SanctionSeverity ;
    rdfs:label "Criminal"@en .

ontara-gov:AuthorityType a owl:Class ;
    rdfs:label "Authority Type"@en ;
    owl:equivalentClass [ a owl:Class ;
        owl:oneOf ( ontara-gov:StatutoryAuthority
                    ontara-gov:QuasiStatutoryAuthority
                    ontara-gov:ProfessionalAuthority
                    ontara-gov:ContractualAuthority
                    ontara-gov:VoluntaryAuthority
                    ontara-gov:InternalAuthority ) ] ;
    rdfs:comment "The type of authority from which a normative instrument derives."@en .

ontara-gov:StatutoryAuthority a owl:NamedIndividual, ontara-gov:AuthorityType ;
    rdfs:label "Statutory"@en .
ontara-gov:QuasiStatutoryAuthority a owl:NamedIndividual, ontara-gov:AuthorityType ;
    rdfs:label "Quasi-statutory"@en .
ontara-gov:ProfessionalAuthority a owl:NamedIndividual, ontara-gov:AuthorityType ;
    rdfs:label "Professional"@en .
ontara-gov:ContractualAuthority a owl:NamedIndividual, ontara-gov:AuthorityType ;
    rdfs:label "Contractual"@en .
ontara-gov:VoluntaryAuthority a owl:NamedIndividual, ontara-gov:AuthorityType ;
    rdfs:label "Voluntary"@en .
ontara-gov:InternalAuthority a owl:NamedIndividual, ontara-gov:AuthorityType ;
    rdfs:label "Internal"@en .

ontara-gov:EndorsementStatus a owl:Class ;
    rdfs:label "Endorsement Status"@en ;
    owl:equivalentClass [ a owl:Class ;
        owl:oneOf ( ontara-gov:Unreviewed
                    ontara-gov:ExpertReviewed
                    ontara-gov:AuthorityEndorsed
                    ontara-gov:CommunityValidated ) ] ;
    rdfs:comment "The review status of a governance framework's formalisation."@en .

ontara-gov:Unreviewed a owl:NamedIndividual, ontara-gov:EndorsementStatus ;
    rdfs:label "Unreviewed"@en .
ontara-gov:ExpertReviewed a owl:NamedIndividual, ontara-gov:EndorsementStatus ;
    rdfs:label "Expert-reviewed"@en .
ontara-gov:AuthorityEndorsed a owl:NamedIndividual, ontara-gov:EndorsementStatus ;
    rdfs:label "Authority-endorsed"@en .
ontara-gov:CommunityValidated a owl:NamedIndividual, ontara-gov:EndorsementStatus ;
    rdfs:label "Community-validated"@en .

ontara-gov:CurrencyStatus a owl:Class ;
    rdfs:label "Currency Status"@en ;
    owl:equivalentClass [ a owl:Class ;
        owl:oneOf ( ontara-gov:CurrentStatus
                    ontara-gov:AmendedStatus
                    ontara-gov:SupersededStatus
                    ontara-gov:RepealedStatus ) ] ;
    rdfs:comment "The currency status of a normative instrument."@en .

ontara-gov:CurrentStatus a owl:NamedIndividual, ontara-gov:CurrencyStatus ;
    rdfs:label "Current"@en .
ontara-gov:AmendedStatus a owl:NamedIndividual, ontara-gov:CurrencyStatus ;
    rdfs:label "Amended"@en .
ontara-gov:SupersededStatus a owl:NamedIndividual, ontara-gov:CurrencyStatus ;
    rdfs:label "Superseded"@en .
ontara-gov:RepealedStatus a owl:NamedIndividual, ontara-gov:CurrencyStatus ;
    rdfs:label "Repealed"@en .


# =============================================================================
# Object Properties
# =============================================================================

# --- Deontic directive properties ---

ontara-gov-ax:hasContentModality a owl:ObjectProperty, owl:FunctionalProperty ;
    rdfs:label "has content modality"@en ;
    rdfs:domain ontara-gov:DeonticDirective ;
    rdfs:range ontara-gov:ContentModality ;
    rdfs:comment "Whether this directive governs a state, an action, or an achievement."@en .

ontara-gov-ax:hasTemporalScope a owl:ObjectProperty, owl:FunctionalProperty ;
    rdfs:label "has temporal scope"@en ;
    rdfs:domain ontara-gov:DeonticDirective ;
    rdfs:range ontara-gov:TemporalScopeType ;
    rdfs:comment "How this directive applies over time: continuous, periodic, triggered, deadline-bounded, or transitional."@en .

ontara-gov-ax:hasSanctionSeverity a owl:ObjectProperty, owl:FunctionalProperty ;
    rdfs:label "has sanction severity"@en ;
    rdfs:domain ontara-gov:DeonticDirective ;
    rdfs:range ontara-gov:SanctionSeverity ;
    rdfs:comment "The severity classification for non-compliance with this directive."@en .

ontara-gov-ax:derivesFrom a owl:ObjectProperty ;
    rdfs:label "derives from"@en ;
    rdfs:domain ontara-gov:DeonticDirective ;
    rdfs:range ontara-gov:NormativeInstrument ;
    rdfs:comment "The normative instrument(s) from which this directive is derived. Provenance relationship."@en .

ontara-gov-ax:hasException a owl:ObjectProperty ;
    rdfs:label "has exception"@en ;
    rdfs:domain ontara-gov:DeonticDirective ;
    rdfs:range ontara-gov:DeonticDirective ;
    rdfs:comment "The directive that overrides this one under specified conditions. Models defeasibility explicitly within OWL 2 DL monotonicity (S121-D4)."@en .

ontara-gov-ax:belongsToGroup a owl:ObjectProperty ;
    rdfs:label "belongs to group"@en ;
    rdfs:domain ontara-gov:DeonticDirective ;
    rdfs:range ontara-gov:ObligationGroup ;
    rdfs:comment "The obligation group(s) to which this directive belongs."@en .

ontara-gov-ax:hasComponentDirective a owl:ObjectProperty ;
    rdfs:label "has component directive"@en ;
    rdfs:domain ontara-gov:DeonticDirective ;
    rdfs:range ontara-gov:DeonticDirective ;
    rdfs:comment "Composite obligation decomposition: all components must be satisfied for the composite to be satisfied."@en .

ontara-gov-ax:hasAlternativeSatisfaction a owl:ObjectProperty ;
    rdfs:label "has alternative satisfaction"@en ;
    rdfs:domain ontara-gov:DeonticDirective ;
    rdfs:range ontara-gov:DeonticDirective ;
    rdfs:comment "Alternative satisfaction: any one of the linked directives suffices for compliance."@en .

ontara-gov-ax:triggersObligation a owl:ObjectProperty ;
    rdfs:label "triggers obligation"@en ;
    rdfs:domain ontara-gov:DeonticDirective ;
    rdfs:range ontara-gov:DeonticDirective ;
    rdfs:comment "Cascading obligations: activation of this directive triggers further directives."@en .

# --- Normative instrument properties ---

ontara-gov-ax:isSourceOf a owl:ObjectProperty ;
    rdfs:label "is source of"@en ;
    owl:inverseOf ontara-gov-ax:derivesFrom ;
    rdfs:domain ontara-gov:NormativeInstrument ;
    rdfs:range ontara-gov:DeonticDirective ;
    rdfs:comment "The deontic directives that this normative instrument yields. Inverse of derivesFrom."@en .

ontara-gov-ax:hasAuthorityType a owl:ObjectProperty, owl:FunctionalProperty ;
    rdfs:label "has authority type"@en ;
    rdfs:domain ontara-gov:NormativeInstrument ;
    rdfs:range ontara-gov:AuthorityType ;
    rdfs:comment "The type of authority from which this instrument derives."@en .

ontara-gov-ax:hasCurrencyStatus a owl:ObjectProperty, owl:FunctionalProperty ;
    rdfs:label "has currency status"@en ;
    rdfs:domain ontara-gov:NormativeInstrument ;
    rdfs:range ontara-gov:CurrencyStatus ;
    rdfs:comment "Whether this instrument is current, amended, superseded, or repealed."@en .

ontara-gov-ax:supersedesInstrument a owl:ObjectProperty ;
    rdfs:label "supersedes instrument"@en ;
    rdfs:domain ontara-gov:NormativeInstrument ;
    rdfs:range ontara-gov:NormativeInstrument ;
    rdfs:comment "Version lineage: this instrument replaces the target instrument."@en .

ontara-gov-ax:implementsInstrument a owl:ObjectProperty ;
    rdfs:label "implements instrument"@en ;
    rdfs:domain ontara-gov:NormativeInstrument ;
    rdfs:range ontara-gov:NormativeInstrument ;
    rdfs:comment "This instrument implements the target — e.g. secondary legislation implements primary legislation."@en .

ontara-gov-ax:interpretsInstrument a owl:ObjectProperty ;
    rdfs:label "interprets instrument"@en ;
    rdfs:domain ontara-gov:NormativeInstrument ;
    rdfs:range ontara-gov:NormativeInstrument ;
    rdfs:comment "This instrument interprets the target — e.g. case law interprets statute, guidance interprets regulation."@en .

ontara-gov-ax:crossReferencesInstrument a owl:ObjectProperty, owl:SymmetricProperty ;
    rdfs:label "cross-references instrument"@en ;
    rdfs:domain ontara-gov:NormativeInstrument ;
    rdfs:range ontara-gov:NormativeInstrument ;
    rdfs:comment "Instruments that reference each other. Symmetric relationship."@en .

# --- Framework properties ---

ontara-gov-ax:containsDirective a owl:ObjectProperty ;
    rdfs:label "contains directive"@en ;
    rdfs:domain ontara-gov:GovernanceFramework ;
    rdfs:range ontara-gov:DeonticDirective ;
    rdfs:comment "The deontic directives contained in this governance framework."@en .

ontara-gov-ax:hasSourceInstrument a owl:ObjectProperty ;
    rdfs:label "has source instrument"@en ;
    rdfs:domain ontara-gov:GovernanceFramework ;
    rdfs:range ontara-gov:NormativeInstrument ;
    rdfs:comment "The normative instruments from which this framework's directives are derived."@en .

ontara-gov-ax:hasEndorsementStatus a owl:ObjectProperty, owl:FunctionalProperty ;
    rdfs:label "has endorsement status"@en ;
    rdfs:domain ontara-gov:GovernanceFramework ;
    rdfs:range ontara-gov:EndorsementStatus ;
    rdfs:comment "The review status of this framework's formalisation."@en .

ontara-gov-ax:containsGroup a owl:ObjectProperty ;
    rdfs:label "contains group"@en ;
    rdfs:domain ontara-gov:GovernanceFramework ;
    rdfs:range ontara-gov:ObligationGroup ;
    rdfs:comment "The obligation groups defined within this framework."@en .


# =============================================================================
# Data Properties
# =============================================================================

# --- Deontic directive data properties ---

ontara-gov-ax:directiveContent a owl:DatatypeProperty ;
    rdfs:label "directive content"@en ;
    rdfs:domain ontara-gov:DeonticDirective ;
    rdfs:range xsd:string ;
    rdfs:comment "Textual description of what is required, permitted, or prohibited."@en .

ontara-gov-ax:applicabilityCondition a owl:DatatypeProperty ;
    rdfs:label "applicability condition"@en ;
    rdfs:domain ontara-gov:DeonticDirective ;
    rdfs:range xsd:string ;
    rdfs:comment "Textual description of the circumstances under which this directive is active."@en .

ontara-gov-ax:exceptionCondition a owl:DatatypeProperty ;
    rdfs:label "exception condition"@en ;
    rdfs:domain ontara-gov:DeonticDirective ;
    rdfs:range xsd:string ;
    rdfs:comment "Textual description of the circumstances under which this directive is overridden."@en .

ontara-gov-ax:evidentialSpecification a owl:DatatypeProperty ;
    rdfs:label "evidential specification"@en ;
    rdfs:domain ontara-gov:DeonticDirective ;
    rdfs:range xsd:string ;
    rdfs:comment "What constitutes evidence of compliance — document types, records, processes, qualifications."@en .

ontara-gov-ax:freshnessRequirement a owl:DatatypeProperty ;
    rdfs:label "freshness requirement"@en ;
    rdfs:domain ontara-gov:DeonticDirective ;
    rdfs:range xsd:string ;
    rdfs:comment "How recently evidence must have been produced or reviewed."@en .

ontara-gov-ax:sourceReference a owl:DatatypeProperty ;
    rdfs:label "source reference"@en ;
    rdfs:domain ontara-gov:DeonticDirective ;
    rdfs:range xsd:string ;
    rdfs:comment "Specific clause, section, or regulation reference in the source instrument."@en .

# --- Normative instrument data properties ---

ontara-gov-ax:instrumentTitle a owl:DatatypeProperty ;
    rdfs:label "instrument title"@en ;
    rdfs:domain ontara-gov:NormativeInstrument ;
    rdfs:range xsd:string ;
    rdfs:comment "Full title of the normative instrument."@en .

ontara-gov-ax:instrumentReference a owl:DatatypeProperty ;
    rdfs:label "instrument reference"@en ;
    rdfs:domain ontara-gov:NormativeInstrument ;
    rdfs:range xsd:string ;
    rdfs:comment "Formal reference number or citation."@en .

ontara-gov-ax:issuingAuthority a owl:DatatypeProperty ;
    rdfs:label "issuing authority"@en ;
    rdfs:domain ontara-gov:NormativeInstrument ;
    rdfs:range xsd:string ;
    rdfs:comment "The body responsible for the instrument."@en .

ontara-gov-ax:jurisdiction a owl:DatatypeProperty ;
    rdfs:label "jurisdiction"@en ;
    rdfs:domain ontara-gov:NormativeInstrument ;
    rdfs:range xsd:string ;
    rdfs:comment "Territorial and sectoral scope of the instrument."@en .

ontara-gov-ax:effectiveDate a owl:DatatypeProperty ;
    rdfs:label "effective date"@en ;
    rdfs:domain ontara-gov:NormativeInstrument ;
    rdfs:range xsd:date ;
    rdfs:comment "When the instrument came into force."@en .

ontara-gov-ax:amendedDate a owl:DatatypeProperty ;
    rdfs:label "amended date"@en ;
    rdfs:domain ontara-gov:NormativeInstrument ;
    rdfs:range xsd:date ;
    rdfs:comment "When the instrument was last amended."@en .

# --- Framework data properties ---

ontara-gov-ax:frameworkVersion a owl:DatatypeProperty ;
    rdfs:label "framework version"@en ;
    rdfs:domain ontara-gov:GovernanceFramework ;
    rdfs:range xsd:string ;
    rdfs:comment "Version identifier for this governance framework."@en .

ontara-gov-ax:currencyDate a owl:DatatypeProperty ;
    rdfs:label "currency date"@en ;
    rdfs:domain ontara-gov:GovernanceFramework ;
    rdfs:range xsd:date ;
    rdfs:comment "The date up to which this framework reflects the current state of its source instruments."@en .

ontara-gov-ax:formalisationProvenance a owl:DatatypeProperty ;
    rdfs:label "formalisation provenance"@en ;
    rdfs:domain ontara-gov:GovernanceFramework ;
    rdfs:range xsd:string ;
    rdfs:comment "Who formalised this framework, when, and through what process."@en .

# --- Obligation group data properties ---

ontara-gov-ax:groupLabel a owl:DatatypeProperty ;
    rdfs:label "group label"@en ;
    rdfs:domain ontara-gov:ObligationGroup ;
    rdfs:range xsd:string ;
    rdfs:comment "Display name for the obligation group."@en .


# =============================================================================
# Axioms — Disjointness
# =============================================================================

# Deontic modalities are pairwise disjoint
[ a owl:AllDisjointClasses ;
  owl:members ( ontara-gov:Obligation
                ontara-gov:Permission
                ontara-gov:Prohibition
                ontara-gov:RegulatoryPower ) ] .

# Normative instrument types are pairwise disjoint
[ a owl:AllDisjointClasses ;
  owl:members ( ontara-gov:PrimaryLegislation
                ontara-gov:SecondaryLegislation
                ontara-gov:StatutoryGuidance
                ontara-gov:RegulatoryStandard
                ontara-gov:ProfessionalStandard
                ontara-gov:CodeOfPractice
                ontara-gov:TechnicalStandard
                ontara-gov:CommissioningFramework
                ontara-gov:ContractualObligation
                ontara-gov:InternalStandard
                ontara-gov:CaseLaw ) ] .

# Top-level governance classes are pairwise disjoint
[ a owl:AllDisjointClasses ;
  owl:members ( ontara-gov:DeonticDirective
                ontara-gov:NormativeInstrument
                ontara-gov:ObligationGroup
                ontara-gov:GovernanceFramework ) ] .


# =============================================================================
# Axioms — Covering (complete partitions)
# =============================================================================

# DeonticDirective is exactly the union of its four subtypes
ontara-gov:DeonticDirective owl:equivalentClass [
    a owl:Class ;
    owl:unionOf ( ontara-gov:Obligation
                  ontara-gov:Permission
                  ontara-gov:Prohibition
                  ontara-gov:RegulatoryPower )
] .

# NormativeInstrument is exactly the union of its eleven subtypes
ontara-gov:NormativeInstrument owl:equivalentClass [
    a owl:Class ;
    owl:unionOf ( ontara-gov:PrimaryLegislation
                  ontara-gov:SecondaryLegislation
                  ontara-gov:StatutoryGuidance
                  ontara-gov:RegulatoryStandard
                  ontara-gov:ProfessionalStandard
                  ontara-gov:CodeOfPractice
                  ontara-gov:TechnicalStandard
                  ontara-gov:CommissioningFramework
                  ontara-gov:ContractualObligation
                  ontara-gov:InternalStandard
                  ontara-gov:CaseLaw )
] .


# =============================================================================
# Axioms — Existential and Cardinality Restrictions
# =============================================================================

# Every deontic directive derives from at least one normative instrument
ontara-gov:DeonticDirective rdfs:subClassOf [
    a owl:Restriction ;
    owl:onProperty ontara-gov-ax:derivesFrom ;
    owl:someValuesFrom ontara-gov:NormativeInstrument
] .

# Every deontic directive has exactly one content modality
ontara-gov:DeonticDirective rdfs:subClassOf [
    a owl:Restriction ;
    owl:onProperty ontara-gov-ax:hasContentModality ;
    owl:qualifiedCardinality "1"^^xsd:nonNegativeInteger ;
    owl:onClass ontara-gov:ContentModality
] .

# Every deontic directive has exactly one temporal scope
ontara-gov:DeonticDirective rdfs:subClassOf [
    a owl:Restriction ;
    owl:onProperty ontara-gov-ax:hasTemporalScope ;
    owl:qualifiedCardinality "1"^^xsd:nonNegativeInteger ;
    owl:onClass ontara-gov:TemporalScopeType
] .

# Every normative instrument has exactly one authority type
ontara-gov:NormativeInstrument rdfs:subClassOf [
    a owl:Restriction ;
    owl:onProperty ontara-gov-ax:hasAuthorityType ;
    owl:qualifiedCardinality "1"^^xsd:nonNegativeInteger ;
    owl:onClass ontara-gov:AuthorityType
] .

# Every normative instrument has exactly one currency status
ontara-gov:NormativeInstrument rdfs:subClassOf [
    a owl:Restriction ;
    owl:onProperty ontara-gov-ax:hasCurrencyStatus ;
    owl:qualifiedCardinality "1"^^xsd:nonNegativeInteger ;
    owl:onClass ontara-gov:CurrencyStatus
] .

# Every governance framework has exactly one endorsement status
ontara-gov:GovernanceFramework rdfs:subClassOf [
    a owl:Restriction ;
    owl:onProperty ontara-gov-ax:hasEndorsementStatus ;
    owl:qualifiedCardinality "1"^^xsd:nonNegativeInteger ;
    owl:onClass ontara-gov:EndorsementStatus
] .
```

## 11. Design Decisions

| ID | Decision | Rationale |
|---|---|---|
| S125-D1 | Separate IRI namespace `ontara-gov:` for governance vocabulary | Distinct conceptual domain from the BMM. Separate ontology module, same domain graph stratum. |
| S125-D2 | `DeonticDirective` subclass of `IAO_0000033` (directive information entity) | Donohue (2017) analysis confirmed in S121-D1. Aligns with existing ontology stack. |
| S125-D3 | `NormativeInstrument` subclass of `IAO_0000310` (document) | Source documents are IAO documents, not directives. The instrument *contains* directives. |
| S125-D4 | `GovernanceRequirement` (BMM) and `DeonticDirective` (governance vocabulary) remain siblings | Different abstraction levels. BMM meta model element vs KG deontic entity. Connected via future binding mechanism. |
| S125-D5 | Structural properties as `xsd:string` data properties | Pragmatic first iteration. Content, applicability, evidential specs, freshness requirements are textual. Promotable to structured object references as the representation matures. Respects [[concept-non-constraining\|J3]]. |
| S125-D6 | Covering axioms for `DeonticDirective` and `NormativeInstrument` | Both taxonomies are intentionally closed sets. Four deontic modalities from deontic logic; eleven instrument types from regulatory analysis. Extending either is a deliberate design act. |
| S125-D7 | Hand-authored ontology, OWL-authoritative | No SysML source for governance vocabulary. Follows the same pattern as `ontara-bmm-axioms.ttl`. Authority zones ([[concept-authority-zones\|B29]]) apply. |

## 12. Implementation Notes

### 12.1 Metrics summary

| Metric | Count |
|---|---|
| Classes | 19 |
| Enumeration classes | 6 |
| Named individuals (enum members) | 24 |
| Object properties | 20 |
| Data properties | 16 |
| Disjointness axiom groups | 3 |
| Covering axioms | 2 |
| Existential restrictions | 1 |
| Cardinality restrictions | 5 |

### 12.2 File placement

The Turtle file will be placed at `ontology/governance/ontara-governance.ttl` in the repo. A corresponding `catalog-v001.xml` for Robot import resolution will be needed if the governance ontology imports other Ontara ontology modules.

### 12.3 Validation plan

Once authored as a `.ttl` file:

1. Load into Protégé for manual inspection and structural verification.
2. Load into GraphDB alongside the existing ontology stack (BFO, CCO, IAO, BMM).
3. Run Robot + HermiT consistency check.
4. Write SPARQL validation queries (following the `validate_kg.py` pattern) to verify structural completeness: every class has rdfs:label, every directive subclass is covered by the partition, every property has domain and range.
5. Create at least one test individual per class to verify the axioms fire correctly — a CQC obligation individual with all required properties, a normative instrument individual, an obligation group.

### 12.4 Deferred work

- **Activation tier classes:** `BoundObligation`, `GovernanceFrameworkActivation`, `ComplianceAssessment`, compliance state vocabulary — S121-Q5.
- **Pipeline integration:** If governance vocabulary concepts are ever represented in SysML, the [[ontara-ref-master-register|gen_owl_pipeline.py]] mapping rules will need extension. For now, hand-authored.
- **Console integration:** A governance view in the [[ontara-ref-master-register|Ontara Console]] would surface the governance vocabulary alongside the BMM. Design TBD.
- **CQC archetype:** The first real exercise of this vocabulary — formalising a subset of CQC obligations. This is the natural next step after authoring the Turtle file (S121-Q5, S121-Q6). See §15 of the [[ontara-discussion-deontic-governance-architecture-2026-04-03|governance paper]].

## 13. Register Connections

### 13.1 Existing concepts exercised

| Concept | How exercised |
|---|---|
| [[principle-model-generates-everything\|A3]] | OWL is part of the canonical representation; the governance vocabulary extends it |
| [[principle-two-meta-model-distinction\|A4]] | Governance vocabulary spans both stacks per S121-Q1 resolution; this design honours the split |
| [[principle-deterministic-over-probabilistic\|A6]] | Deontic vocabulary supports inspectable, deterministic compliance logic |
| [[concept-non-constraining\|J3]] | Data properties as `xsd:string` (S125-D5) — promotable without refactoring; covering axioms are explicitly closed, making extension deliberate |
| [[concept-knowledge-graph\|B22]] | Governance vocabulary lives in the knowledge graph domain stratum |
| [[concept-bfo-ontological-grounding\|B23]] | All classes grounded in BFO via IAO |
| [[concept-three-stratum-knowledge-graph\|B28]] | Domain graph placement |
| [[concept-authority-zones\|B29]] | OWL-authoritative for class definitions and axioms |
| [[ontara-ref-master-register\|B30]] | Deontic directive vocabulary — this design specifies it |
| [[ontara-ref-master-register\|B31]] | Governance framework library — GovernanceFramework class defined |
| [[ontara-ref-master-register\|B33]] | Normative instrument taxonomy — 11 types with complete partition |

### 13.2 New concepts for registration

| Proposed code | Concept | Tier | Description |
|---|---|---|---|
| B35 | Governance ontology module (`ontara-gov:` namespace) | T3 | Separate OWL ontology module for governance vocabulary, distinct from BMM namespace |

### 13.3 Open questions resolved

| ID | Resolution |
|---|---|
| S121-Q3 | **Resolved.** This paper provides the complete OWL class hierarchy with 19 classes, 6 enumeration classes, 20 object properties, 16 data properties, and axioms. Ready for Turtle authoring and validation. |

---

*Discussion paper produced 3 April 2026 (Session 125). Resolves S121-Q3 (OWL class structure for the deontic vocabulary).*
