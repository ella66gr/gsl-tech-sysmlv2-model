---
tags:
  - discussion
  - architecture
date: 2026-04-05
status: working
session: 142
---
# Domain Identity in the Dual-Stack Architecture

*Ontara Platform — Discussion Paper*

**Date:** 5 April 2026 (Session 142)
**Purpose:** Revision and extension of the Session 59 domain identity paper (B15) to resolve five design questions arising from the dual-stack architecture, knowledge graph, and governance workstream. This paper establishes how domain identity operates in both meta model stacks, how it is represented in OWL, and how it supports the governance activation tier.
**Status:** Working document — detailed design. Block A Step 1 of the Domain Identity and Governance Convergence plan (Session 141).
**Depends on:** [[ontara-discussion-domain-identity-architecture-2026-03-22-v2.1|Domain Identity paper (Session 59, B15)]], [[ontara-discussion-dual-stack-architecture-2026-03-26|Dual-Stack Architecture (Sessions 73–74, B21)]], [[ontara-discussion-deontic-governance-architecture-2026-04-03|Deontic Governance Architecture (Session 121)]], [[ontara-discussion-deontic-owl-class-design-2026-04-03|Deontic Governance OWL Class Design (Session 125)]]

---

## Contents

- [[#1. Context: What Has Changed Since Session 59|§1. Context: What Has Changed Since Session 59]]
- [[#2. What Remains Sound|§2. What Remains Sound]]
- [[#3. The Dual-Stack Placement (Q1)|§3. The Dual-Stack Placement (Q1)]]
- [[#4. OWL Representation and BFO Grounding (Q2)|§4. OWL Representation and BFO Grounding (Q2)]]
- [[#5. The Multi-Tenancy Promotion Decision (Q3)|§5. The Multi-Tenancy Promotion Decision (Q3)]]
- [[#6. Interaction with Governance Activation (Q4)|§6. Interaction with Governance Activation (Q4)]]
- [[#7. The Revised Attribute Set (Q5)|§7. The Revised Attribute Set (Q5)]]
- [[#8. The Revised Propagation Chain|§8. The Revised Propagation Chain]]
- [[#9. OWL Class Design|§9. OWL Class Design]]
- [[#10. Resolving the Session 59 Open Questions|§10. Resolving the Session 59 Open Questions]]
- [[#11. Design Decisions|§11. Design Decisions]]
- [[#12. Implementation Implications|§12. Implementation Implications]]
- [[#13. Register Connections|§13. Register Connections]]

---

## 1. Context: What Has Changed Since Session 59

The Session 59 domain identity paper was produced during a housekeeping session when a naming inconsistency (CSW/Cafe/CoffeeShop) surfaced a structural gap: domain is not a first-class concept in the Ontara architecture. The paper proposed `DomainDefinition` in Foundation with three enums (`RegulatoryTier`, `BmmVocabularyScope`, `DomainPurpose`), domain instances, and a propagation chain from model to generator to console.

That paper was written 83 sessions ago. Three major architectural developments have since occurred:

**The dual-stack architecture (Sessions 73–74, B21).** The project now has a two-column structure — BMM (what the business is) on the left, SMM (how the system works) on the right — connected by [[concept-horizontal-mappings|horizontal mappings (B12)]] at every tier. Every concept must be placed within this structure. Session 59 predates this; its placement of `DomainDefinition` in Foundation as "BMM" is correct in spirit but now requires refinement. Foundation is shared infrastructure imported by both stacks — not inherently BMM or SMM.

**The knowledge graph (Sessions 97–136, B22).** The project now has a three-stratum knowledge graph (B28) — foundational, domain, and correspondence — with [[concept-bfo-ontological-grounding|BFO as the upper ontology]] and OWL 2 DL as the mandatory formalism ([[concept-bfo-ontological-grounding|B23]]). Every first-class concept needs an OWL representation. The Session 59 paper designed only SysML; domain identity needs OWL classes, properties, and individuals.

**The governance vocabulary (Sessions 121–136, B30–B35).** The deontic governance architecture introduced a three-tier compliance model: library (formalised obligations), activation (binding obligations to a specific domain), and operations (compliance monitoring). The activation tier cannot function without domain identity infrastructure — there is nothing formal for obligations to bind *to*. Session 124 resolved S121-Q1 by splitting `GovernanceFramework` (SMM) from `GovernanceFrameworkActivation` (BMM) with a horizontal mapping. This established the precedent for how concepts that span both stacks should be handled.

These three developments do not invalidate the Session 59 paper. Its core insight — that domain identity belongs in the model as a first-class concept, not scattered across Python dicts and YAML keys — is confirmed and strengthened by everything that followed. But the design needs extending to operate within the architecture that now exists.

---

## 2. What Remains Sound

Before proposing changes, it is important to identify what the Session 59 paper got right and should be preserved:

**The three enums.** `RegulatoryTier` (four-tier classification from generallyGoverned to sectorRegulated), `BmmVocabularyScope` (generalOnly, full, production), and `DomainPurpose` (referenceValidation, crossDomainValidation, pedagogicalAnchoring, production) are well-designed, validated against all four domains, and have the right granularity. They need minor extension (§7) but not redesign.

**The multi-tenancy principle.** "Only the meta model is core; every domain is a tenant instantiation" — this framing has been consistently validated across 83 subsequent sessions. It has grown stronger, not weaker.

**The propagation chain concept.** The idea that domain properties should propagate from model → generator → JSON → console → vault is architecturally correct per [[principle-model-generates-everything|A3]] (model generates everything). The chain needs extending for OWL, but the principle holds.

**`DomainDefinition` as a `part def` in Foundation.** The decision to make domain identity a first-class model concept with instances defined alongside it in Foundation is correct. Foundation is the right home for cross-cutting infrastructure that both stacks need to reference.

**The domain instance catalogue.** The four domain instances (cafe, suds, paws, gsl) with their property assignments are concrete, testable, and correct. They will gain additional properties (§7) but the existing ones are retained.

---

## 3. The Dual-Stack Placement (Q1)

### 3.1 The problem

The Session 59 paper described `DomainDefinition` as a BMM concept: "describes what a domain *is* (a specific service business with specific characteristics), not how the system implements it." In the dual-stack architecture, every concept must be placed in the left stack (BMM), the right stack (SMM), or identified as cross-cutting infrastructure. Where does domain identity sit?

The difficulty is that `DomainDefinition` genuinely carries both kinds of information:

| Property | Character | Stack |
|---|---|---|
| `regulatoryTier` | What kind of regulatory environment the business operates in | BMM |
| `bmmVocabularyScope` | Which meta model vocabulary the domain exercises | BMM |
| `domainPurpose` | Why this domain exists in the platform | BMM |
| `displayLabel` | How the system presents the domain to users | SMM |
| `canonicalKey` | How the system identifies the domain internally | SMM |
| `packageName` | How the SysML model organises domain files | SMM |
| `modelPath` | Where domain model files live in the repository | SMM |
| `isActive` | Whether the system currently manages this domain | SMM |
| `description` | A human-readable account of what the domain is | Cross-cutting |

This is not an accident. Domain identity is inherently a concept that describes *what* (a service business with certain characteristics) and *how the platform manages what* (package structure, lifecycle, presentation). The dual-stack architecture demands that we acknowledge this rather than forcing the concept into one side.

### 3.2 The precedent: GovernanceFramework / GovernanceFrameworkActivation

Session 124 resolved an analogous problem for governance frameworks (S121-Q1). The governance framework library is platform infrastructure (SMM) — it exists at the system level, independent of any particular tenant. The activation of a framework against a specific tenant's service model is a business-model-level decision (BMM) — it says "this business operates under CQC regulation." The resolution: `GovernanceFramework` is SMM-side; `GovernanceFrameworkActivation` is BMM-side; a horizontal mapping connects them.

### 3.3 The resolution: DomainIdentity (BMM) and DomainConfiguration (SMM)

Following this precedent, domain identity should be split across the stacks:

**`DomainIdentity` (BMM-side)** — describes what the service business *is*: its regulatory environment, its relationship to the meta model vocabulary, its purpose in the platform, its jurisdiction, its regulated activities. This is the concept that the governance activation tier needs to reference when determining which frameworks are relevant and which obligations apply.

**`DomainConfiguration` (SMM-side)** — describes how the platform *manages* this domain: its canonical key, display name, package structure, model path, lifecycle state, active status. This is the concept that generators, the console, and the file system reference when discovering and presenting domains.

**The horizontal mapping** connects the two: every `DomainConfiguration` is the system realisation of a `DomainIdentity`. Every `DomainIdentity` is realised by a `DomainConfiguration`. The mapping is one-to-one and bidirectional — a domain identity without a configuration is not yet onboarded; a configuration without an identity has no business meaning.

### 3.4 Why split rather than keep unified?

Three reasons:

**Architectural consistency.** The dual-stack architecture's value is in making the BMM/SMM distinction explicit. A `DomainDefinition` that mixes business properties with system properties would be the only concept in the architecture that straddles both stacks in a single `part def`. This makes it harder to reason about, harder to validate, and sets a precedent that undermines the dual-stack discipline.

**Governance activation needs.** The activation tier (Block B of the convergence plan) needs to reference domain identity in OWL. The activation process evaluates obligations against a domain's *business characteristics* — regulatory tier, jurisdiction, regulated activities. It does not need to know the domain's package path or canonical key. A clean BMM-side concept gives the activation tier a focused interface.

**Independent evolution.** System configuration changes (renaming a package, moving model files, adding console features) should not require changes to the business identity. Business identity changes (new regulated activity, jurisdictional expansion) should not require changes to system configuration. The split enables independent iteration — precisely what [[principle-two-meta-model-distinction|A4]] promises.

### 3.5 Where in Foundation?

Both `DomainIdentity` and `DomainConfiguration` live in Foundation — but they are tagged with appropriate doc blocks marking their stack allegiance:

```
part def DomainIdentity {
    doc /* Business Meta Model concept.
         * The business identity of a domain: what kind of service business
         * it is, what regulatory environment it operates in, and why it
         * exists in the platform.
         *
         * In the dual-stack architecture, DomainIdentity is the BMM-side
         * of domain identity. The SMM-side is DomainConfiguration,
         * connected by a horizontal mapping.
         *
         * In the multi-tenancy architecture (A13), only the meta model
         * is core. Every DomainIdentity represents a tenant instantiation. */
    ...
}

part def DomainConfiguration {
    doc /* System Meta Model concept.
         * The system configuration for a domain: how the platform discovers,
         * organises, presents, and manages this domain.
         *
         * Connected to DomainIdentity via horizontal mapping. */
    ...
}
```

Foundation is shared infrastructure that both stacks import. It is the correct home for concepts that are fundamental to the platform's operation regardless of stack — as it already is for base types, shared enums, and metadata annotations.

### 3.6 The SysML relationship

The horizontal mapping is expressed in Foundation as a typed reference:

```
part def DomainIdentity {
    ...
    ref domainConfiguration : DomainConfiguration;
}

part def DomainConfiguration {
    ...
    ref domainIdentity : DomainIdentity;
}
```

This bidirectional reference follows the established pattern for horizontal mappings. At the instance level, `cafe` would have both a `DomainIdentity` instance and a `DomainConfiguration` instance cross-referencing each other. Whether these are two separate `part` usages or two nested `part` usages within a containing `DomainDefinition` is an implementation detail to resolve during the SysML authoring step (Block A Steps 2–3). The semantic design is clear regardless.

### 3.7 Alternative considered: keep unified

The alternative is to retain a single `DomainDefinition` as in Session 59, with a doc block acknowledging it spans both stacks. This is simpler. The argument for it: domain identity is a bridge concept by nature; splitting it introduces complexity without a clear consumer that needs only one half. The argument against: it sets a precedent for "bridge" exceptions to the dual-stack discipline, and the governance activation tier is a concrete consumer that needs only the BMM half. On balance, the split is more architecturally rigorous.

**Decision (S142-D1).** Domain identity is split into `DomainIdentity` (BMM) and `DomainConfiguration` (SMM), connected by a horizontal mapping. Both live in Foundation.

---

## 4. OWL Representation and BFO Grounding (Q2)

### 4.1 The ontological challenge

The most challenging design question identified in the Stage 6 plan (R2): a domain is simultaneously a real-world entity (the coffee shop, the healthcare service) and a model artefact (the SysML/OWL representation of that business). BFO is strict about this distinction — `material entity` and `information content entity` are disjoint categories under BFO's top-level `continuant`.

But here is the key insight: **`DomainIdentity` is not the coffee shop.** It is the platform's formal description of a domain — a structured specification of what the service business is and what its characteristics are. The real-world coffee shop exists independently of Ontara. What Ontara holds is *information about* that business, organised as a first-class model concept.

This resolves the apparent BFO conflict cleanly. We are not trying to represent a material entity in the knowledge graph. We are representing a specification — an information content entity that describes the domain's business characteristics.

### 4.2 BFO grounding for DomainIdentity

`DomainIdentity` is an information content entity that specifies the business characteristics of a domain. In the BFO/IAO hierarchy:

```
BFO:entity
  → BFO:continuant (BFO_0000002)
    → BFO:generically_dependent_continuant (BFO_0000031)
      → IAO:information_content_entity (IAO_0000030)
        → IAO:plan_specification (IAO_0000104)
          → ontara-domain:DomainIdentity
```

**Why `plan_specification`?** An IAO plan specification is an information content entity that, when concretized, is realised by a process in which the bearer attempts to achieve some objectives. A domain identity specifies: this is a service business of this type, operating under these regulations, for this purpose. When a tenant activates a domain, the plan specification is realised by the operational activity of that service. This captures the prescriptive nature of domain identity — it is not merely a description but a specification that shapes what the business does and how it is governed.

**Alternative considered:** `IAO:objective_specification` (IAO_0000005) — this is what the BMM's `GovernanceRequirement` is mapped to. However, an objective specification specifies a desired endpoint; a domain identity specifies the *nature* of the service business, which is broader than a single objective. `plan_specification` is a better fit.

**Alternative considered:** Direct subclass of `information_content_entity` without an IAO intermediate. This would work but misses the opportunity to use IAO's rich mid-level vocabulary, which is already in the ontology stack.

### 4.3 BFO grounding for DomainConfiguration

`DomainConfiguration` is an information content entity that specifies how the platform manages a domain:

```
BFO:entity
  → BFO:continuant (BFO_0000002)
    → BFO:generically_dependent_continuant (BFO_0000031)
      → IAO:information_content_entity (IAO_0000030)
        → IAO:data_item (IAO_0000027)
          → ontara-domain:DomainConfiguration
```

**Why `data_item`?** An IAO data item is an information content entity that is intended to be a truthful statement about something and is constructed in a process of data generation. `DomainConfiguration` contains platform-generated configuration data — canonical keys, package paths, display labels — that the system uses to manage the domain. This is configuration data, not a plan or specification.

### 4.4 The `is about` relationship

Following standard IAO practice, both `DomainIdentity` and `DomainConfiguration` bear an `IAO:is_about` relationship to the real-world service business they describe. This is the ontological bridge: the OWL entities are *about* something in the world, but they are not that thing.

We do not need to represent the real-world service business as an OWL individual (although we could, using BFO's `organization` class, if future work required it). For the governance activation tier, what matters is the *specification* of the domain's characteristics, not a model of the real-world entity.

### 4.5 The horizontal mapping in OWL

The horizontal mapping between `DomainIdentity` and `DomainConfiguration` is represented as an object property:

```turtle
ontara-domain:hasConfiguration a owl:ObjectProperty ;
    rdfs:domain ontara-domain:DomainIdentity ;
    rdfs:range ontara-domain:DomainConfiguration ;
    a owl:FunctionalProperty .

ontara-domain:hasIdentity a owl:ObjectProperty ;
    rdfs:domain ontara-domain:DomainConfiguration ;
    rdfs:range ontara-domain:DomainIdentity ;
    a owl:FunctionalProperty ;
    owl:inverseOf ontara-domain:hasConfiguration .
```

Both are functional (one-to-one) and inverse of each other.

**Decision (S142-D2).** `DomainIdentity` is grounded as a subclass of `IAO:plan_specification`. `DomainConfiguration` is grounded as a subclass of `IAO:data_item`. Both are information content entities — neither represents the real-world service business directly.

---

## 5. The Multi-Tenancy Promotion Decision (Q3)

### 5.1 The case for promotion

A13 was registered as a T1 candidate in Session 59. Its statement: "Only the meta model is core; every domain (including GSL) is a tenant instantiation — an exercise of the system's capabilities against a specific service business."

The evidence for promotion to binding T1 has strengthened considerably across 83 sessions:

**Structural validation.** The [[concept-dual-stack-architecture|dual-stack architecture (B21)]] is built on the premise that BMM `part def`s are platform vocabulary and `part` usages are tenant content. The entire left stack from General vocabulary down to business process patterns is a single-tenant instantiation. The [[ontara-discussion-deontic-governance-architecture-2026-04-03|governance framework library (B31)]] is explicitly "platform-level shared infrastructure — not per-tenant." The distinction between platform and tenant is architecturally load-bearing.

**Cross-domain validation.** Every demonstrator domain (Cafe, Suds, Paws) exercises the meta model as a tenant instantiation. The pattern has been validated in three domains with different regulatory tiers, vocabulary scopes, and purposes. This is exactly the kind of cross-domain validation ([[concept-co-evolution|J2]]) that qualifies a concept for promotion.

**Governance integration.** The governance activation tier's entire design depends on the multi-tenancy principle: governance frameworks exist at platform level; tenants activate them against their specific service models. Without multi-tenancy as a governing principle, the activation tier has no conceptual foundation.

**This workstream.** Block A's first act is to make domain identity first-class — which is the structural expression of "the platform knows about its tenants as formally defined entities." If multi-tenancy is not a governing principle, this workstream has no clear architectural motivation beyond solving a naming inconsistency.

### 5.2 What promotion means in practice

Promoting A13 to binding T1 means:

- Every session start includes A13 in the Tier 1 check.
- Violations require explicit justification and documentation.
- New design decisions are tested against A13: "Does this treat GSL as structurally privileged over other tenants?"
- The strategic snapshot records A13 as a governing principle.
- The one-line test: "Only the meta model is core — does this design work for any tenant, not just the one we're building for?"

### 5.3 Risks of promotion

**Premature generalisation.** The platform has not yet served an external tenant. Promoting a principle to T1 before it has been tested under production conditions carries a risk of over-commitment. However: the principle as stated does not commit to a specific multi-tenancy *implementation* (shared database, isolated instances, etc.). It commits to a *conceptual model* — that every domain is a tenant instantiation of the meta model. This is already demonstrated fact, not speculation.

**Constraining GSL-specific work.** If A13 is T1, any GSL-specific design decision requires justifying why the same capability is not available to other tenants. This is a feature, not a bug — it prevents structural privilege from accruing silently. But it could slow down GSL-specific clinical work if taken too rigidly. The mitigation: A13 governs architectural structure, not clinical content. GSL's clinical pathways, OGMS adoption, and domain-specific vocabulary are tenant content — they are *expressions* of multi-tenancy, not violations of it.

**Decision (S142-D3).** Promote A13 (multi-tenancy) from T1 candidate to binding Tier 1 principle. The principle governs architectural structure; clinical and domain-specific content is tenant content that expresses, rather than violates, multi-tenancy.

---

## 6. Interaction with Governance Activation (Q4)

### 6.1 What the activation tier needs

The governance activation process (Session 121 paper §8.1) performs four steps when a tenant activates a governance framework: (1) applicability assessment, (2) obligation binding, (3) gap identification, (4) cross-framework reconciliation. Each step places demands on domain identity.

**Applicability assessment** evaluates each deontic directive's applicability conditions against the tenant's service model. The directive's conditions reference properties like: regulated activities, service types, organisational form, jurisdictional scope. Domain identity must carry enough information to resolve these conditions without the assessor needing to inspect the full service model for every directive.

**Obligation binding** connects applicable directives to specific service model elements. The binding needs to reference what the domain *contains* — which BMM elements are instantiated, what roles exist, what processes are defined. Domain identity does not need to carry this detail itself, but it must provide a path to it: "this domain's service model elements are reachable from here."

**Gap identification** discovers service model elements required by bound obligations but not yet defined. This needs the same reachability — given a domain identity, the system must be able to enumerate the domain's existing service model content.

**Cross-framework reconciliation** compares obligations across multiple activated frameworks. This needs the domain's full list of activated frameworks, which is a property of the activation state rather than of domain identity itself.

### 6.2 Properties DomainIdentity needs for activation

Drawing from the above:

| Property | Type | Why needed |
|---|---|---|
| `regulatoryTier` | Enum (`RegulatoryTier`) | Determines which governance frameworks are *potentially* relevant. A `generallyGoverned` domain need not evaluate CQC frameworks. |
| `jurisdiction` | Enum or structured value | Determines territorial applicability. A CQC framework applies in England, not Scotland. |
| `regulatedActivities` | Collection (enum or structured) | Determines which specific directives within a framework are applicable. CQC applicability conditions frequently reference regulated activities. |
| `organisationalForm` | Enum | Some directives apply only to organisations, others only to individuals. |
| `bmmVocabularyScope` | Enum (`BmmVocabularyScope`) | Determines which meta model vocabulary is available as binding targets. |

The first three (`regulatoryTier`, `jurisdiction`, `regulatedActivities`) are the critical ones — they are the properties the applicability assessment evaluates first, before inspecting the service model itself.

### 6.3 The reachability question

The activation tier also needs to reach the domain's service model content — the BMM `part` usages that serve as obligation binding targets. How does it get from `DomainIdentity` to the service model?

Two options:

**Option A: DomainIdentity carries a manifest.** A reference or collection listing the domain's top-level BMM instantiations (its ServiceConcept part, its ActivityModel part, etc.). This makes discovery explicit but creates a maintenance burden — the manifest must be updated whenever service model elements are added.

**Option B: DomainConfiguration provides the path.** The system-side `DomainConfiguration` knows the package structure and model path. The activation process traverses from `DomainIdentity` → (horizontal mapping) → `DomainConfiguration` → package contents. This is more indirect but avoids redundant manifests.

**Option C: The knowledge graph provides the path.** In OWL, domain identity individuals are connected to BMM individuals via object properties (e.g., `hasBmmInstantiation` or domain-scoped queries). SPARQL queries can enumerate all BMM individuals that belong to a given domain without a manifest — the graph *is* the manifest.

Option C is most consistent with the knowledge graph architecture. In the OWL representation, the domain identity individual has relationships to the BMM individuals that constitute its service model. SPARQL queries enumerate binding targets on demand. In SysML, the domain instance contains its `part` usages within its package scope, so the generator can enumerate them during extraction.

**Decision (S142-D4).** Domain identity does not carry an explicit manifest of service model elements. Service model content is reachable through the knowledge graph (OWL: object properties and SPARQL queries) and through the package structure (SysML: generator extraction). The graph is the manifest.

### 6.4 The activation state relationship

When a governance framework is activated against a domain, the result is a `GovernanceFrameworkActivation` (BMM-side, per S121-Q1 resolution). This activation references the domain identity:

```
GovernanceFrameworkActivation
  ├── activatedFramework → GovernanceFramework (SMM, via horizontal mapping)
  ├── activatedForDomain → DomainIdentity (BMM)
  ├── activationDate
  ├── activatedBy (operator reference)
  └── boundObligations → BoundObligation[0..*]
```

The `activatedForDomain` property is the key connection. It links the activation tier to domain identity, enabling the system to answer: "What governance frameworks are activated for this domain?" and "What domains have this governance framework activated?"

---

## 7. The Revised Attribute Set (Q5)

### 7.1 DomainIdentity attributes (BMM-side)

These describe what the service business is:

| Attribute | Type | Session 59 origin | New/Modified | Notes |
|---|---|---|---|---|
| `regulatoryTier` | `RegulatoryTier` | Yes — unchanged | — | Four-tier classification. Determines governance framework relevance. |
| `bmmVocabularyScope` | `BmmVocabularyScope` | Yes — unchanged | — | Which meta model subset the domain instantiates. |
| `domainPurpose` | `DomainPurpose[1..*]` | Yes — **modified** | Multiplicity changed | Now supports multiple values (resolves S59-Q4: Paws is both pedagogicalAnchoring and crossDomainValidation). |
| `jurisdiction` | `Jurisdiction` | No | **New** | Territorial scope. Needed for governance activation applicability. New enum. |
| `regulatedActivities` | `RegulatedActivity[0..*]` | No | **New** | CQC and other sectoral regulated activities. Needed for directive applicability. New enum. |
| `organisationalForm` | `OrganisationalForm` | No | **New** | Individual, partnership, organisation, body corporate. Some directives are form-specific. New enum. |
| `description` | `String` | Yes — moved from unified | — | Human-readable description of what this domain is. |
| `introducedSession` | `Integer` | Yes — moved from unified | — | Session when this domain was first introduced to the project. |
| `ref domainConfiguration` | `DomainConfiguration` | No | **New** | Horizontal mapping to SMM-side. |

### 7.2 DomainConfiguration attributes (SMM-side)

These describe how the platform manages the domain:

| Attribute | Type | Session 59 origin | Notes |
|---|---|---|---|
| `canonicalKey` | `String` | Yes — moved from unified | Internal system identifier. |
| `displayLabel` | `String` | Yes — moved from unified | User-facing label. |
| `fullName` | `String` | Yes — moved from unified | Full descriptive name. |
| `packageName` | `String` | Yes — moved from unified | SysML package name. |
| `modelPath` | `String` | Yes — moved from unified | Repository path to domain model files. |
| `isActive` | `Boolean` | Yes — moved from unified | Whether the platform currently manages this domain. |
| `ref domainIdentity` | `DomainIdentity` | No — new | Horizontal mapping to BMM-side. |

### 7.3 New enums

**`Jurisdiction`** — territorial scope for governance applicability:

```
enum def Jurisdiction {
    doc /* Territorial jurisdiction for governance framework applicability.
         * Based on UK devolution structure — the primary governance
         * frameworks Ontara supports have jurisdiction-specific scope.
         * Extensible as the platform supports non-UK jurisdictions. */
    england;
    scotland;
    wales;
    northernIreland;
    unitedKingdom;  // UK-wide (e.g. GDPR as retained EU law, employment law)
}
```

**`RegulatedActivity`** — CQC-defined regulated activities (Health and Social Care Act 2008):

```
enum def RegulatedActivity {
    doc /* Activities regulated by CQC under the Health and Social Care
         * Act 2008. A service providing any of these must be registered
         * with CQC. Used during governance framework activation to
         * determine directive applicability.
         *
         * Source: HSCA 2008 (Regulated Activities) Regulations 2014,
         * Schedule 1. */
    personalCare;
    accommodationForPersonsRequiringNursingOrPersonalCare;
    accommodationForPersonsRequiringTreatmentForSubstanceMisuse;
    treatment;
    assessmentOrMedicalTreatmentForPersonsDetainedUnderMentalHealthAct;
    surgicalProcedures;
    diagnosticAndScreeningProcedures;
    managementOfSupplyOfBloodAndBloodDerivedProducts;
    transportServicesTimedAndUntimed;
    maternity;
    terminationOfPregnancies;
    familyPlanning;
    nursingCare;
}
```

**`OrganisationalForm`** — legal/organisational structure of the service provider:

```
enum def OrganisationalForm {
    doc /* The legal/organisational form of a service provider.
         * Some governance directives apply only to specific forms
         * (e.g. "body corporate" provisions in CQC regulations).
         * Source: CQC registration requirements; Companies Act 2006. */
    individual;
    partnership;
    organisation;  // Generic — includes charities, NHS bodies, etc.
    bodyCorporate; // Specific Companies Act entity
}
```

### 7.4 Session 59 enum extensions

**`DomainPurpose`** — now supports multiple values per domain (multiplicity `[1..*]` on the attribute). No new enum values needed at this stage, but the multiplicity change resolves Session 59 open question §9.4 (Paws dual purpose). Paws has both `pedagogicalAnchoring` and `crossDomainValidation`.

---

## 8. The Revised Propagation Chain

The Session 59 propagation chain remains correct but needs extending for OWL and the split structure:

```
SysML DomainIdentity + DomainConfiguration (in Foundation)
    │
    ├── gen_model_introspection.py reads both
    │       └── model-introspection.json carries merged domain metadata
    │               └── Ontara Console renders domain info
    │
    ├── gen_owl_pipeline.py generates OWL individuals
    │       └── ontara-domain.ttl (or section of ontara-bmm.ttl)
    │               ├── DomainIdentity OWL individuals
    │               ├── DomainConfiguration OWL individuals
    │               └── Horizontal mapping object properties
    │
    ├── PatternCatalogue DomainInstantiation references domain by typed ref
    │       └── (replaces free-text "CSW" / "GSL" strings — as per S59)
    │
    ├── Governance activation references DomainIdentity OWL individuals
    │       └── GovernanceFrameworkActivation.activatedForDomain
    │
    └── Concept Graph domain-*.md notes derive from model
            └── Frontmatter uses canonicalKey as the YAML key
```

The critical new branch is the OWL pipeline. Domain identity OWL individuals participate in the same knowledge graph as governance individuals. This means SPARQL queries can traverse from a governance directive through its activation to the domain it is activated for, and from there to the domain's regulatory characteristics — enabling the applicability assessment to be expressed as queries over the graph.

---

## 9. OWL Class Design

### 9.1 Namespace

Following the governance vocabulary's approach (Session 125), domain identity uses a separate namespace:

| Namespace | Prefix | Purpose |
|---|---|---|
| `https://ontara.dev/ontology/domain/` | `ontara-domain:` | Domain identity classes |
| `https://ontara.dev/ontology/domain/axioms#` | `ontara-domain-ax:` | Domain identity object and data properties |

**Rationale (S142-D5).** Domain identity is a distinct ontological module from the BMM and from governance. It addresses a specific conceptual domain — the identity, characteristics, and configuration of service business domains. The namespace separation follows the same reasoning as S125-D1 (governance vocabulary namespace separation).

### 9.2 Class hierarchy

| Class | Parent | BFO Path | Description |
|---|---|---|---|
| `DomainIdentity` | `IAO:plan_specification` | GDC → ICE → plan_specification | The business identity of a domain: what kind of service business it is, its regulatory characteristics, and its purpose in the platform. |
| `DomainConfiguration` | `IAO:data_item` | GDC → ICE → data_item | The platform configuration for a domain: how the system discovers, organises, and presents the domain. |

Two classes only — deliberately minimal. The richness is in the properties and the enum classes, not in a deep class hierarchy.

### 9.3 Enumeration classes

Each enum maps to an OWL class with individuals:

| OWL Class | Individuals | SysML source |
|---|---|---|
| `ontara-domain:RegulatoryTier` | `generallyGoverned`, `lightlyRegulated`, `partiallyRegulated`, `sectorRegulated` | `RegulatoryTier` enum |
| `ontara-domain:BmmVocabularyScope` | `generalOnly`, `full`, `production` | `BmmVocabularyScope` enum |
| `ontara-domain:DomainPurpose` | `referenceValidation`, `crossDomainValidation`, `pedagogicalAnchoring`, `production` | `DomainPurpose` enum |
| `ontara-domain:Jurisdiction` | `england`, `scotland`, `wales`, `northernIreland`, `unitedKingdom` | `Jurisdiction` enum |
| `ontara-domain:RegulatedActivity` | 13 individuals (from HSCA 2008) | `RegulatedActivity` enum |
| `ontara-domain:OrganisationalForm` | `individual`, `partnership`, `organisation`, `bodyCorporate` | `OrganisationalForm` enum |

Each enumeration class has `owl:oneOf` closure — these are closed enumerations with no unnamed members.

### 9.4 Object properties

| Property | Domain | Range | Characteristics | Description |
|---|---|---|---|---|
| `hasConfiguration` | `DomainIdentity` | `DomainConfiguration` | Functional, InverseFunctional | Horizontal mapping: identity → configuration |
| `hasIdentity` | `DomainConfiguration` | `DomainIdentity` | Functional, InverseFunctional | Horizontal mapping: configuration → identity (inverse of above) |
| `hasRegulatoryTier` | `DomainIdentity` | `RegulatoryTier` | Functional | The domain's regulatory tier |
| `hasBmmVocabularyScope` | `DomainIdentity` | `BmmVocabularyScope` | Functional | Which meta model vocabulary subset the domain exercises |
| `hasDomainPurpose` | `DomainIdentity` | `DomainPurpose` | — (not functional: multi-valued) | Why this domain exists in the platform. Multi-valued. |
| `hasJurisdiction` | `DomainIdentity` | `Jurisdiction` | Functional | Territorial jurisdiction for governance applicability |
| `hasRegulatedActivity` | `DomainIdentity` | `RegulatedActivity` | — (not functional: multi-valued) | CQC-defined regulated activities this domain provides |
| `hasOrganisationalForm` | `DomainIdentity` | `OrganisationalForm` | Functional | Legal/organisational structure of the service provider |

### 9.5 Data properties

| Property | Domain | Range | Description |
|---|---|---|---|
| `domainDescription` | `DomainIdentity` | `xsd:string` | Human-readable description of the domain |
| `introducedAtSession` | `DomainIdentity` | `xsd:integer` | Project session when this domain was introduced |
| `canonicalKey` | `DomainConfiguration` | `xsd:string` | Internal system identifier |
| `displayLabel` | `DomainConfiguration` | `xsd:string` | User-facing label |
| `fullName` | `DomainConfiguration` | `xsd:string` | Full descriptive name |
| `packageName` | `DomainConfiguration` | `xsd:string` | SysML package name |
| `modelPath` | `DomainConfiguration` | `xsd:string` | Repository path to domain model files |
| `isActive` | `DomainConfiguration` | `xsd:boolean` | Whether the platform currently manages this domain |

### 9.6 Axioms

**Disjointness.** `DomainIdentity` and `DomainConfiguration` are disjoint — no individual can be both.

**Enumeration closure.** All six enumeration classes are closed with `owl:oneOf`.

**Enumeration member disjointness.** Within each enumeration, members are pairwise `owl:differentFrom`.

**Functional property axioms.** `hasConfiguration` and `hasIdentity` are both functional and inversefunctional, ensuring the one-to-one horizontal mapping.

**Minimum cardinality.** Every `DomainIdentity` has at least one `hasDomainPurpose` value:
```turtle
ontara-domain:DomainIdentity rdfs:subClassOf [
    a owl:Restriction ;
    owl:onProperty ontara-domain-ax:hasDomainPurpose ;
    owl:minCardinality "1"^^xsd:nonNegativeInteger
] .
```

### 9.7 Example individual (Cafe)

```turtle
ontara-domain:cafe-identity a ontara-domain:DomainIdentity ;
    ontara-domain-ax:hasRegulatoryTier ontara-domain:generallyGoverned ;
    ontara-domain-ax:hasBmmVocabularyScope ontara-domain:full ;
    ontara-domain-ax:hasDomainPurpose ontara-domain:referenceValidation ;
    ontara-domain-ax:hasJurisdiction ontara-domain:england ;
    ontara-domain-ax:hasOrganisationalForm ontara-domain:individual ;
    ontara-domain-ax:domainDescription "Reference validation domain — original demonstrator"^^xsd:string ;
    ontara-domain-ax:introducedAtSession "1"^^xsd:integer ;
    ontara-domain-ax:hasConfiguration ontara-domain:cafe-configuration .

ontara-domain:cafe-configuration a ontara-domain:DomainConfiguration ;
    ontara-domain-ax:canonicalKey "cafe"^^xsd:string ;
    ontara-domain-ax:displayLabel "Cafe"^^xsd:string ;
    ontara-domain-ax:fullName "Cafe (Coffee Shop)"^^xsd:string ;
    ontara-domain-ax:packageName "CoffeeShop"^^xsd:string ;
    ontara-domain-ax:modelPath "exercises/coffeeshop-demonstrator/model"^^xsd:string ;
    ontara-domain-ax:isActive "true"^^xsd:boolean ;
    ontara-domain-ax:hasIdentity ontara-domain:cafe-identity .
```

Note: Cafe has no `hasRegulatedActivity` values — it is `generallyGoverned` and provides no CQC-regulated activities. GSL would have `treatment` and `diagnosticAndScreeningProcedures`.

---

## 10. Resolving the Session 59 Open Questions

### 10.1 Q1: Should DomainDefinition carry @UserFacing and @Comprehension metadata?

**Resolution: Yes, but on DomainIdentity, not DomainConfiguration.** The [[concept-comprehension-layer|comprehension architecture (I14, I18)]] is designed for BMM concepts — explaining what things are and why they matter. `DomainIdentity` is a BMM concept that users need to understand: "What is this domain? Why does it exist? What regulatory environment does it operate in?" The `@UserFacing` and `@Comprehension` annotations should be applied to `DomainIdentity` and its enum types. `DomainConfiguration` is system internals — it does not need user-facing comprehension metadata.

This can be implemented during the SysML authoring step (Block A Step 2). It is not urgent for the current design phase.

### 10.2 Q2: Should multi-tenancy be formalised as T1?

**Resolution: Yes.** See §5 above. Decision S142-D3.

### 10.3 Q3: How does modelPath interact with future package reorganisation?

**Resolution: modelPath is a DomainConfiguration property.** It is system-side, mutable, and does not affect the domain's business identity. If GSL's package structure changes, only the `DomainConfiguration` instance is updated. The `DomainIdentity` — and therefore all governance activations, all applicability assessments, all bound obligations — remains unchanged. The split to dual-stack placement (S142-D1) directly resolves this concern.

### 10.4 Q4: Should Paws have dual purpose?

**Resolution: Yes.** `DomainPurpose` on `DomainIdentity` is now multi-valued (`[1..*]`). Paws has both `pedagogicalAnchoring` and `crossDomainValidation`. In OWL, this is naturally expressed as multiple `hasDomainPurpose` property assertions on the same individual. In SysML, the attribute is typed as `DomainPurpose[1..*]`.

---

## 11. Design Decisions

| ID | Decision | Rationale |
|---|---|---|
| S142-D1 | Domain identity is split into `DomainIdentity` (BMM) and `DomainConfiguration` (SMM) with horizontal mapping | Follows the S121-Q1 precedent. Enables governance activation to reference business characteristics without coupling to system configuration. Maintains dual-stack discipline. |
| S142-D2 | `DomainIdentity` → `IAO:plan_specification`; `DomainConfiguration` → `IAO:data_item` | Avoids the BFO material entity confusion. Both are information content entities describing the domain, not the domain itself. Uses existing IAO mid-level vocabulary. |
| S142-D3 | Promote A13 (multi-tenancy) from T1 candidate to binding T1 principle | Cross-domain validation across 83 sessions. The governance activation tier depends on multi-tenancy conceptually. Governs architectural structure, not clinical content. |
| S142-D4 | No explicit service model manifest on DomainIdentity | Service model content is reachable via the knowledge graph (SPARQL) and package structure (generator). The graph is the manifest. Avoids maintenance burden of redundant manifests. |
| S142-D5 | Domain identity uses separate OWL namespace (`ontara-domain:`) | Follows governance vocabulary precedent (S125-D1). Domain identity is a distinct ontological module from BMM and governance. |
| S142-D6 | `DomainPurpose` is multi-valued (`[1..*]`) | Resolves Session 59 open question §9.4. Paws has both pedagogical and cross-domain validation purposes. |
| S142-D7 | Three new enums: `Jurisdiction`, `RegulatedActivity`, `OrganisationalForm` | Required for governance activation applicability assessment. Source: UK regulatory structure, CQC regulated activities, Companies Act. |

---

## 12. Implementation Implications

This paper is the design foundation for Block A Steps 2–8 of the convergence plan. Key implementation notes:

### 12.1 SysML (Steps 2–3)

- Two new `part def`s in Foundation: `DomainIdentity`, `DomainConfiguration`
- Six enums: three existing (unchanged), three new
- Domain instances: each domain has both an identity and a configuration part, cross-referenced
- The Session 59 unified `DomainDefinition` is superseded by the split design but its content is preserved across the two new `part def`s

### 12.2 OWL (Steps 3–4)

- New ontology module: `ontara-domain.ttl` (hand-authored, OWL-authoritative per B29)
- 2 classes, 6 enumeration classes, 8 object properties, 8 data properties
- 4 domain identity individuals + 4 domain configuration individuals (Cafe, Suds, Paws, GSL)
- Imports: IAO (for `plan_specification`, `data_item`), governance ontology (for cross-references)

### 12.3 Pipeline (Steps 5–6)

- `gen_model_introspection.py` extended to extract both `DomainIdentity` and `DomainConfiguration` from SysML
- `gen_owl_pipeline.py` extended to generate domain OWL individuals (or hand-authored if simpler)
- Correspondence graph extended with domain ↔ OWL mappings

### 12.4 Validation (Step 7)

- Syside parse of new Foundation content
- HermiT consistency check with domain ontology loaded
- SPARQL queries: enumerate domains by regulatory tier, enumerate regulated activities for a domain, traverse from domain identity to configuration

### 12.5 PatternCatalogue migration (Step 8)

- `DomainInstantiation.domain` from `String` to `ref domain : DomainIdentity`
- Follows the [[deferred-string-to-typed-ref-migration|O25]] string-to-typed-ref pattern established in Session 58

---

## 13. Register Connections

### 13.1 Concepts exercised

| Concept | How exercised |
|---|---|
| [[principle-separation-representation-execution\|A1]] | Domain properties move from execution-layer config (Python dict) to representation layer (SysML + OWL) |
| [[principle-self-describing-system\|A2]] | The system can describe its own domains and their characteristics |
| [[principle-model-generates-everything\|A3]] | Generator derives domain configuration from model; OWL pipeline derives domain individuals |
| [[principle-two-meta-model-distinction\|A4]] | Domain identity explicitly placed across BMM (identity) and SMM (configuration) with horizontal mapping |
| [[principle-discipline-as-load-bearing-structure\|A9]] | Rigorous dual-stack placement discipline maintained for domain identity |
| [[principle-intrinsic-self-knowledge\|A10]] | System knows its domains from model state, not static configuration |
| [[principle-unity-principle\|A11]] | Single domain identity model serves comprehension, governance, generation, and console |
| [[concept-multi-tenancy\|A13]] | Promoted to binding T1. First structural expression through formal domain identity. |
| [[concept-horizontal-mappings\|B12]] | DomainIdentity ↔ DomainConfiguration horizontal mapping |
| [[ontara-discussion-domain-identity-architecture-2026-03-22-v2.1\|B15]] | Direct extension of this concept into dual-stack and OWL |
| [[concept-dual-stack-architecture\|B21]] | Domain identity placed explicitly within both stacks |
| [[concept-knowledge-graph\|B22]] | Domain identity represented as OWL individuals in the knowledge graph |
| [[concept-bfo-ontological-grounding\|B23]] | BFO/IAO grounding for both domain classes |
| [[concept-three-stratum-knowledge-graph\|B28]] | Domain individuals in the domain graph stratum |
| [[concept-authority-zones\|B29]] | Hand-authored domain ontology is OWL-authoritative |
| [[concept-co-evolution\|J2]] | Model (SysML), ontology (OWL), generator, and console evolve together |
| [[concept-non-constraining\|J3]] | Design supports future domains, jurisdictions, and regulated activities without structural changes |

### 13.2 Potential new register entries

| Candidate | Description | Tier |
|---|---|---|
| Domain identity dual-stack split | DomainIdentity (BMM) + DomainConfiguration (SMM) with horizontal mapping | T2, B section |
| Jurisdiction enum | Territorial scope for governance applicability | T3, B section |
| Regulated activities vocabulary | CQC-defined regulated activities for activation applicability | T3, B section |
| Domain ontology module | `ontara-domain.ttl` — the OWL module for domain identity | T3, B section |

---

*Discussion paper produced Session 142, 5 April 2026. Extends the Session 59 domain identity paper (B15) into the dual-stack architecture (B21), OWL knowledge graph (B22), and governance activation tier (B30–B35). Seven design decisions (S142-D1 to S142-D7).*
