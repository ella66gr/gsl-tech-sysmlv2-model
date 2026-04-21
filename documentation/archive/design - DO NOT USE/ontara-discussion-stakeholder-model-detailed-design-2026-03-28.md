# StakeholderModel Detailed Design: Element Attributes, Open Question Resolution, and Weight Design

*Ontara Platform — Discussion Paper*
**Date:** 28 March 2026 (Session 78)
**Status:** Working document — detailed design. Builds on the StakeholderModel discussion paper (Session 76) and resolves the open questions identified there.
**Depends on:** [[ontara-discussion-stakeholder-model-and-bsmm-vocabulary-2026-03-27|StakeholderModel and BSMM Vocabulary discussion paper]] (Session 76)

---

## Contents

- [§1. Purpose and Scope](#1-purpose-and-scope)
- [§2. Open Question Resolution](#2-open-question-resolution)
- [§3. New Enums](#3-new-enums)
- [§4. Element Attribute Design](#4-element-attribute-design)
- [§5. Conceptual Weight Design](#5-conceptual-weight-design)
- [§6. Cross-Domain Validation](#6-cross-domain-validation)
- [§7. Implementation Guidance](#7-implementation-guidance)
- [§8. Decisions Summary](#8-decisions-summary)
- [§9. Register Connections](#9-register-connections)
- [§10. Related Documents](#10-related-documents)

---

## 1. Purpose and Scope

This paper completes the detailed design for the six StakeholderModel General elements proposed in Session 76. It resolves the four open questions from the Session 76 discussion paper §9, defines typed attributes for each element, introduces three new enums, and provides conceptual weight design for the implementation session.

The design follows the established BMM attribute pattern: `String` for qualitative/descriptive attributes, typed enums for structured classification, `ref` for cross-element connections. All six elements are General-level `part def`s — domain-neutral structural patterns that each tenant domain instantiates with its own content ([[concept-multi-tenancy|A13]]).

This paper is the reference document for the SysML implementation session that follows.

---

## 2. Open Question Resolution

Four open questions were identified in the Session 76 discussion paper §9. All four are now resolved.

### 2.1 ParticipationModel distinctness (§9.1)

**Decision: ParticipationModel is a separate sibling element.**

Six independent `part def`s in `BusinessModel::StakeholderModel`, no specialisation hierarchy. No element inherits from any other.

**Conceptual reasoning.** The five externally-oriented elements (StakeholderRelationship, CooperativeArrangement, ReferralPathway, ExternalDependency, CommunityRelationship) describe the business looking outward at entities beyond its boundary. ParticipationModel describes the boundary looking inward at the customer's role as co-producer within the service. This is a genuinely different orientation. ParticipationModel also connects to a different set of architectural concepts — [[principle-patient-autonomy|A7]] (patient autonomy), [[concept-agency-classification|H2]] (agency classification), the [[ontara-discussion-service-participation-model-2026-03-21|service participation framework (O26)]] — than the other five.

**Engineering reasoning.** The specialisation alternative (ParticipationModel as a subtype of StakeholderRelationship) was evaluated and rejected on engineering grounds:

- **Weighted relationships:** Inheritance semantics for `@WeightedRelationship` are undefined — the generator and traversal engine don't handle specialisation hierarchies. See [[ontara-ref-weighted-relationship-directionality-definition|directionality definition]].
- **Coverage matrix:** The console's current rendering doesn't distinguish subtypes from independent types; would require code changes.
- **Comprehension traversal:** The `@Comprehension` traversal engine treats each `part def` independently ([[concept-comprehension-traversal-schema|I16]]); specialisation-aware traversal would add complexity.
- **Generator pipeline:** `gen_model_introspection.py` would need to extract and represent specialisation relationships — currently it does not ([[pattern-metadata-driven-generation|D9]]).
- **Precedent:** No specialisation relationships exist between BMM `part def`s. Introducing one would create pressure to specialise other elements (CooperativeArrangement, ReferralPathway, etc.), fundamentally changing the BMM's architectural pattern.
- **Coupling risk:** Changes to StakeholderRelationship would propagate to ParticipationModel, even when inappropriate for the co-production context.

The sibling approach costs some attribute duplication but works with every existing tool and convention, and preserves future flexibility.

### 2.2 GovernanceMapping boundary (§9.3)

**Decision: Dual classification with typed reference. Rule content in GovernanceMapping, relationship structure in StakeholderModel.**

**Boundary principle:** GovernanceMapping answers *"what must we comply with?"* — the content of obligations, the rules, the standards, the evidence requirements. StakeholderModel answers *"who do we interact with about it, and how?"* — the entity, the dialogue, the relationship health, the review cycle.

**Independence test:** If you removed the StakeholderRelationship but kept the GovernanceRequirement, would you still know what you must comply with? Yes. Would you know who to talk to about compliance or how the relationship is going? No. The converse also holds. This confirms the two elements serve independent purposes.

**Implementation mechanism:** StakeholderRelationship carries a typed `ref relatedGovernanceRequirements : GovernanceRequirement` linking to the applicable governance requirements. This makes the connection explicit and navigable without conflating rule content with relationship structure.

**Design guideline:** *"A regulatory relationship is dual-classified: rule content in GovernanceMapping, relationship structure in StakeholderModel. The StakeholderRelationship carries a typed reference to the applicable GovernanceRequirement(s). Neither subsumes the other. The test: could this information exist independently in one concern without the other? If yes, it belongs in the concern where it naturally sits."*

**Domain validation:** Tested against CQC (GSL), COSHH/environmental health (Suds), food safety (Cafe), and animal welfare/insurance (Paws). The boundary holds cleanly in all cases.

### 2.3 Relationship Awareness (§9.2)

**Decision: No cross-cutting dimension. The concern-level treatment is sufficient.**

Activity Awareness (C6) works as a cross-cutting dimension because activities are the *common currency* — the atomic unit that every concern produces, consumes, or governs. Stakeholder relationships do not play this role. A relationship with a supplier *affects* multiple concerns, but it does so through the existing mechanisms — the supplier appears as a resource source in ResourcePlanning, a cost driver in FinancialPlanning, a dependency in StakeholderModel. The interactions are real but are adequately captured by horizontal connections between concerns and by the weighted relationship model.

Adding a second cross-cutting dimension would change the architectural character of the BMM without a concrete need — no case was identified where something important is invisible without it. If a need for relationship visibility emerges later (e.g. during assembly workspace work), it can be addressed as a console view feature rather than a meta model structural addition. Not foreclosed (J3).

### 2.4 Relationship nature taxonomy (§9.1/§9.4)

**Decision: Closed `RelationshipNature` enum with six values.**

| Value | Meaning |
|---|---|
| `regulatory` | A body that sets or enforces rules the business must follow — asymmetric authority |
| `contractual` | A formal commercial or service agreement — defined by contract terms and mutual obligations |
| `professional` | A relationship with a professional body, standards organisation, or accreditation body |
| `advisory` | A relationship with a body that provides guidance without authority — non-binding influence |
| `commissioning` | A body that commissions or funds the service — defines what it will pay for |
| `peer` | A relationship with a similar or equivalent organisation — mutual learning, benchmarking |

The enum is closed (no `other` value), consistent with existing BMM enum practice (`RelationshipStrength`, `ActivityCategory`, `RegulatoryTier`). Tailored extensions can add domain-specific values via `:>>` redefinition ([[concept-general-tailored-decomposition|B11]]) — e.g. a healthcare Tailored extension might add `clinicalNetwork`.

**Engineering reasoning for closed over open:** A closed enum works with exhaustive matching in generators, enables tailored comprehension descriptions per nature, supports nature-specific constraint checking (e.g. "every regulatory relationship must have a linked GovernanceRequirement"), and avoids the "other" dumping ground that degrades data quality. An `other` value would require default-case handling throughout the pipeline while carrying no semantic information.

---

## 3. New Enums

Three new enums are introduced, all in `Foundation::CommonTypes`. All are closed, consistent with Q4 reasoning.

### 3.1 RelationshipNature

```
enum def RelationshipNature {
    regulatory;
    contractual;
    professional;
    advisory;
    commissioning;
    peer;
}
```

Used by: StakeholderRelationship.

### 3.2 ReferralDirection

```
enum def ReferralDirection {
    inbound;
    outbound;
    bidirectional;
}
```

Used by: ReferralPathway.

### 3.3 DependencyCriticality

```
enum def DependencyCriticality {
    essential;
    important;
    convenient;
}
```

Used by: ExternalDependency.

---

## 4. Element Attribute Design

All six elements follow the established BMM attribute pattern: `String` for qualitative/descriptive attributes, typed enums for structured classification, `ref` for cross-element connections. Metadata annotations (`@CatalogueTag`, `@UserFacing`, `@PurposiveDescription`, `@Comprehension`, `@WeightedRelationship`) to be added during SysML implementation.

### 4.1 StakeholderRelationship (C7a)

The core abstraction. A typed, ongoing, structured relationship between the business and an external entity.

| Attribute | Type | Purpose |
|---|---|---|
| `stakeholderName` | `String` | Identity of the external entity |
| `stakeholderDescription` | `String` | What this entity is and why the relationship exists |
| `relationshipNature` | `RelationshipNature` | Closed enum — regulatory, contractual, professional, advisory, commissioning, peer |
| `obligationsInward` | `String` | What the stakeholder owes or provides to the business |
| `obligationsOutward` | `String` | What the business owes or provides to the stakeholder |
| `informationExchanged` | `String` | What information flows between parties and in which direction |
| `governanceArrangements` | `String` | How the relationship is governed — formal agreements, review processes, escalation routes |
| `healthIndicators` | `String` | How the business assesses whether the relationship is working well |
| `reviewCadence` | `String` | How often the relationship is formally reviewed |
| `ref relatedGovernanceRequirements` | `GovernanceRequirement` | Typed reference to applicable governance requirements (Q2 dual-classification link) |

**Design notes:** The `ref` to GovernanceRequirement implements the Q2 boundary decision — it is the explicit, navigable link connecting relationship structure (StakeholderModel) to rule content (GovernanceMapping). Particularly important for regulatory-natured relationships. The `relationshipNature` enum ensures this element is used only for relationships that don't fit the five specialised siblings.

### 4.2 CooperativeArrangement (C7b)

A formalised agreement to jointly deliver or manage something. Distinguished by shared responsibility for an outcome — neither party can deliver independently.

| Attribute | Type | Purpose |
|---|---|---|
| `arrangementName` | `String` | Identity of the arrangement |
| `cooperatingEntity` | `String` | Who the business cooperates with |
| `sharedOutcome` | `String` | What is jointly delivered — the thing neither party can do alone |
| `responsibilitySplit` | `String` | How responsibility is divided — who does what |
| `protocolReference` | `String` | Reference to the formal protocol or agreement governing the arrangement |
| `informationSharing` | `String` | What information is shared, how, and with what governance |
| `disputeResolution` | `String` | How disagreements or failures in cooperation are handled |
| `performanceIndicators` | `String` | How the arrangement's effectiveness is assessed |

**Design notes:** The distinguishing attribute is `sharedOutcome` — this is what separates CooperativeArrangement from a simple StakeholderRelationship. If neither party can deliver the outcome independently, it's a CooperativeArrangement. If the relationship is important but each party could function without the other, it's a StakeholderRelationship.

### 4.3 ReferralPathway (C7c)

A structured route for directing or receiving work between organisations.

| Attribute | Type | Purpose |
|---|---|---|
| `pathwayName` | `String` | Identity of the referral pathway |
| `direction` | `ReferralDirection` | Enum — inbound, outbound, bidirectional |
| `referringEntity` | `String` | Who refers (inbound) or is referred to (outbound) |
| `referralCriteria` | `String` | What conditions trigger a referral — acceptance criteria, appropriateness |
| `referralProtocol` | `String` | How referrals are made — form, channel, information required |
| `expectedResponseTime` | `String` | How quickly a referral should be acknowledged and actioned |
| `feedbackMechanism` | `String` | How the referring party is kept informed of outcomes |
| `volumeTracking` | `String` | How referral volumes, conversion rates, and outcomes are monitored |

**Design notes:** The `direction` enum is a closed three-value classification. Bidirectional referral pathways exist — e.g. a GP relationship where the GP refers patients to GSL and GSL refers patients back to the GP for shared care monitoring.

### 4.4 ExternalDependency (C7d)

Something the business depends on that it does not control. Characterised by asymmetric reliance.

| Attribute | Type | Purpose |
|---|---|---|
| `dependencyName` | `String` | Identity of the dependency |
| `provider` | `String` | Who provides the thing the business depends on |
| `dependencyDescription` | `String` | What is depended upon and why it matters |
| `criticality` | `DependencyCriticality` | Enum — essential, important, convenient |
| `substitutability` | `String` | How easily the dependency can be replaced — alternative sources, switching costs |
| `contingencyPlan` | `String` | What the business does if the dependency fails or is withdrawn |
| `contractualTerms` | `String` | Key terms governing the supply relationship |
| `supplyRisk` | `String` | Known risks to continuity of supply |

**Design notes:** Distinguished from CooperativeArrangement by asymmetric power — the business depends on the provider, but the provider does not depend on the business (or the dependence is negligible). The `criticality` enum drives contingency planning priority. `contingencyPlan` is a key attribute — a dependency without a contingency plan is a risk that hasn't been addressed.

### 4.5 CommunityRelationship (C7e)

The business's connection to its broader community of interest. Constitutive, not transactional.

| Attribute | Type | Purpose |
|---|---|---|
| `communityName` | `String` | Identity of the community |
| `communityDescription` | `String` | What this community is and what connects its members |
| `relationshipToService` | `String` | How the community relates to the business's purpose — constitutive, advocacy, knowledge-sharing |
| `engagementMode` | `String` | How the business engages — events, platforms, representation, membership |
| `mutualBenefit` | `String` | What the community gains from the relationship, and what the business gains |
| `communityVoice` | `String` | How the community's perspective shapes the service — feedback channels, advisory roles, co-design |

**Design notes:** Deliberately lighter on governance attributes than the other elements. Community relationships are constitutive of the business's identity and social context, not contractual. Over-governing them with SLAs and dispute resolution would misrepresent their character. The `communityVoice` attribute is particularly important — it captures how the community's perspective influences the service, which is the structurally interesting part of the relationship.

### 4.6 ParticipationModel (C7f)

How the customer/patient participates as co-producer, not merely recipient. Connected to [[principle-patient-autonomy|A7]], [[concept-agency-classification|H2]], and the [[ontara-discussion-service-participation-model-2026-03-21|service participation framework (O26)]].

| Attribute | Type | Purpose |
|---|---|---|
| `participationName` | `String` | Identity of this participation pattern |
| `participantRole` | `String` | What role the customer/patient plays — recipient, informed participant, co-producer, self-manager |
| `participationDescription` | `String` | How the participant contributes to the service delivery |
| `informationContribution` | `String` | What information the participant provides and how — history, preferences, self-monitoring data |
| `decisionInvolvement` | `String` | How the participant is involved in decisions — informed, consulted, shared, delegated |
| `selfServiceScope` | `String` | What the participant can do independently — booking, monitoring, information access |
| `supportRequired` | `String` | What support the participant needs to fulfil their role — training, tools, accessibility |
| `ref relatedServiceOffering` | `ServiceOffering` | Typed reference to the service offering(s) this participation pattern applies to |

**Design notes:** The `ref` to ServiceOffering connects ParticipationModel back to ServiceConcept — participation is about how the customer experiences and shapes a specific service. This is the structural link that ties the relational boundary (StakeholderModel) back to the internal logic (ServiceConcept). The `participantRole` and `decisionInvolvement` attributes are where the connection to A7 (self-service architecture) and H2 (agency classification) is most direct — they describe the spectrum from passive recipient to active co-producer.

---

## 5. Conceptual Weight Design

The existing 79 `@WeightedRelationship` annotations cover 28 BMM elements across five concerns. The six new StakeholderModel elements need weight assessments for both outgoing (from StakeholderModel to other concerns) and incoming (from other concerns to StakeholderModel) relationships.

Weight annotations will be applied during the SysML implementation session. This section captures the conceptual design — which elements connect, at what strength, with what rationale — so the reasoning is preserved while it is fresh. The [[ontara-ref-weighted-relationship-heuristics-and-config|heuristics (H1–H5)]] govern all assessments.

### 5.1 StakeholderRelationship

**Outgoing:**

| Target | Strength | Rationale |
|---|---|---|
| GovernanceRequirement | strong | A change to the regulatory relationship (e.g. new regulator, changed inspection regime) directly affects what governance requirements apply. Definitional for regulatory-natured relationships (H1). |
| ServiceOffering | moderate | A change to a stakeholder relationship may affect what services can be offered (e.g. loss of a commissioning relationship), but the offering's identity is defined independently in ServiceConcept (H1, H4). |
| ResourceType | moderate | Some stakeholder relationships involve resource implications (e.g. regulatory requirements for qualified staff), but the link is mediated through GovernanceRequirement and ResourceConstraint (H4). |

**Incoming (from existing elements):**

| Source | Strength | Rationale |
|---|---|---|
| GovernanceRequirement | moderate | A change to a governance requirement may require reviewing the relationship through which it is enforced, but the relationship exists independently of any single requirement (H1, H5). |

### 5.2 CooperativeArrangement

**Outgoing:**

| Target | Strength | Rationale |
|---|---|---|
| ActivityType | strong | A cooperative arrangement defines shared activities. A change to the arrangement directly affects what activities are performed and by whom (H1). |
| ServiceOffering | strong | Some cooperative arrangements define jointly-delivered services. A change to the arrangement may fundamentally alter what can be offered (H1). |
| ResourceType | moderate | Cooperative arrangements may involve shared resources, but the resource types exist independently (H4). |

### 5.3 ReferralPathway

**Outgoing:**

| Target | Strength | Rationale |
|---|---|---|
| ServiceOffering | moderate | Referral pathways channel demand to specific offerings, but the offerings exist independently. A change to a referral pathway affects volume and flow, not the offering's identity (H1, H2). |
| ActivityType | moderate | Referral pathways generate activities (intake, triage, acknowledgement), but these activities are typed independently (H4). |

### 5.4 ExternalDependency

**Outgoing:**

| Target | Strength | Rationale |
|---|---|---|
| ResourceType | strong | An external dependency is something the business depends on — often a resource it cannot provide itself. A change to the dependency (e.g. supplier withdrawal) directly affects resource availability (H1). |
| ServiceOffering | moderate | Loss of a critical dependency may affect what can be offered, but the link is mediated through resources (H4). |
| CostDriver | moderate | Dependencies have cost implications (supplier pricing, contractual terms), but cost drivers are characterising, not definitional (H1, H2). |

### 5.5 CommunityRelationship

**Outgoing:**

| Target | Strength | Rationale |
|---|---|---|
| ServiceOffering | moderate | Community relationships shape what the business offers (community needs influence service design), but the link is characterising, not definitional (H1). |
| CustomerSegment | moderate | Communities overlap with customer segments, but they are not the same thing — a community relationship may serve non-customers (H4). |

### 5.6 ParticipationModel

**Outgoing:**

| Target | Strength | Rationale |
|---|---|---|
| ServiceOffering | strong | Participation patterns are defined for specific service offerings — the `ref` relationship is typed. A change to how customers participate directly affects the offering's delivery model (H1). |
| ActivityType | moderate | Participation generates activities (self-service actions, shared decision-making), but the activity types exist independently (H4). |
| Channel | moderate | Participation mode may affect which channels are used (e.g. self-service requires a digital channel), but channels serve multiple purposes (H4). |

### 5.7 Summary

| Element | Outgoing weights | Strong | Moderate |
|---|---|---|---|
| StakeholderRelationship | 3 | 1 | 2 |
| CooperativeArrangement | 3 | 2 | 1 |
| ReferralPathway | 2 | 0 | 2 |
| ExternalDependency | 3 | 1 | 2 |
| CommunityRelationship | 2 | 0 | 2 |
| ParticipationModel | 3 | 1 | 2 |
| **Total new outgoing** | **16** | **5** | **11** |

Plus ~4 incoming weights from existing elements to new elements.

Estimated total weight count after implementation: ~99 (79 existing + ~20 new). The strong-to-moderate ratio (~31%) is consistent with the existing model (33%).

### 5.8 Cross-element weights within StakeholderModel

The six StakeholderModel elements may also carry weights to each other. These should be assessed during implementation as the attributes crystallise in SysML. Initial observations:

- CooperativeArrangement → StakeholderRelationship: moderate (a cooperative arrangement implies a stakeholder relationship, but the arrangement is the more structured concept).
- ReferralPathway → StakeholderRelationship: moderate (a referral pathway exists within a broader stakeholder relationship).
- ExternalDependency → CooperativeArrangement: moderate (a dependency may escalate to a cooperative arrangement if shared delivery is needed).

These are candidates, not commitments — to be assessed against the heuristics during implementation.

---

## 6. Cross-Domain Validation

Each element was validated across all four demonstrator domains during the design process.

### 6.1 StakeholderRelationship

| Domain | Example instance |
|---|---|
| GSL | CQC (regulatory), ICB (commissioning), RCGP (professional), WPATH (advisory) |
| Cafe | Local authority food safety (regulatory), landlord (contractual) |
| Suds | Environmental health (regulatory), insurance provider (contractual) |
| Paws | Local authority animal welfare (regulatory), insurance (contractual), grooming body (professional) |

### 6.2 CooperativeArrangement

| Domain | Example instance |
|---|---|
| GSL | NHS shared care protocol for hormone prescribing — GP monitors, GSL initiates |
| Cafe | Delivery platform partnership (e.g. Deliveroo/UberEats) — shared order fulfilment |
| Suds | Commercial laundry partnership for overflow capacity |
| Paws | Local vet partnership for pre-grooming health checks |

### 6.3 ReferralPathway

| Domain | Example instance |
|---|---|
| GSL | GP referrals inbound; specialist referrals outbound (endocrinology, surgery) |
| Cafe | Supplier introductions (weak example — referrals less central to this domain) |
| Suds | Estate agent / hotel partnerships for bulk laundry referrals |
| Paws | Vet referrals for grooming of dogs with health conditions |

### 6.4 ExternalDependency

| Domain | Example instance |
|---|---|
| GSL | Pharmaceutical supply (hormones), lab services (blood tests) |
| Cafe | Coffee bean supplier, milk supplier, equipment maintenance |
| Suds | Chemical supplier (detergents, solvents), equipment supplier |
| Paws | Grooming product supplier, equipment supplier |

### 6.5 CommunityRelationship

| Domain | Example instance |
|---|---|
| GSL | Trans community and advocacy organisations — constitutive |
| Cafe | Local neighbourhood — local events, community noticeboard |
| Suds | Local business community — networking, referrals |
| Paws | Local dog owner community — breed groups, social events, social media |

### 6.6 ParticipationModel

| Domain | Example instance |
|---|---|
| GSL | Shared decision-making in hormone therapy; self-monitoring; appointment booking |
| Cafe | Minimal — ordering and receiving (recipient role) |
| Suds | Drop-off instructions, garment care preferences (informed participant) |
| Paws | Communication of breed needs, health history, presence during grooming |

**Observations:** All six elements validate across all four domains. The variation in richness is expected and appropriate — GSL (regulated healthcare) naturally has richer instantiations than Cafe (immediate retail). The elements are General: every domain can instantiate them, but the depth of instantiation reflects the domain's complexity.

---

## 7. Implementation Guidance

### 7.1 SysML package structure

A new package `BusinessModel::StakeholderModel` containing six `part def`s and referencing three new enums in `Foundation::CommonTypes`.

### 7.2 Metadata annotations required (per element)

Each element needs the full annotation set to maintain parity with existing BMM elements:

- `@CatalogueTag` with `bmmConcern = "StakeholderModel"` and `classification = "General"`
- `@UserFacing` with `friendlyName` and `shortDescription`
- `@PurposiveDescription` with authored purposive description
- `@Comprehension` with traversal configuration
- `@WeightedRelationship` annotations per the conceptual weight design (§5)
- Doc block identifying this as a "business meta model concept"

### 7.3 Typed references

Two typed `ref` attributes connect StakeholderModel to other concerns:

- `StakeholderRelationship.relatedGovernanceRequirements : GovernanceRequirement` — links to GovernanceMapping
- `ParticipationModel.relatedServiceOffering : ServiceOffering` — links to ServiceConcept

These are cross-package references and will appear as cross-package weights in the weighted relationship graph.

### 7.4 KerML reserved word check

Before implementation, verify the following names against the [[ontara-ref-kerml-reserved-words|KerML reserved words reference]] and SysML contextual keywords: `stakeholder` is a known SysML contextual keyword — do not use it as a bare attribute name. `StakeholderRelationship` as a `part def` name should be fine (PascalCase compound name). Check all attribute names before committing.

### 7.5 Demonstrator instantiations

Minimum: one domain instantiation per element in at least two domains ([[concept-cross-domain-validation|J1]]). Recommended: Cafe (simplest) and GSL (most complex) as the primary validation pair, with Paws as a third.

### 7.6 BMM element count

Current: 28 elements across 5 concerns (+ 2 `requirement def`s in GovernanceMapping).
After implementation: 34 elements across 6 concerns (+ 2 `requirement def`s).
New comprehension annotations required: 6 `@UserFacing`, 6 `@PurposiveDescription`, 6 `@Comprehension`.
New weight annotations: ~20 (per §5).

---

## 8. Decisions Summary

| # | Decision | Status |
|---|---|---|
| D1 | ParticipationModel is a separate sibling element — no specialisation hierarchy | **Binding** |
| D2 | GovernanceMapping boundary: rule content in GovernanceMapping, relationship structure in StakeholderModel, linked by typed ref | **Binding** |
| D3 | No Relationship Awareness cross-cutting dimension — concern-level treatment sufficient | **Binding** (not foreclosed, J3) |
| D4 | Closed `RelationshipNature` enum: regulatory, contractual, professional, advisory, commissioning, peer | **Binding** |
| D5 | Closed `ReferralDirection` enum: inbound, outbound, bidirectional | **Binding** |
| D6 | Closed `DependencyCriticality` enum: essential, important, convenient | **Binding** |
| D7 | Weighted relationships: conceptual design now, annotation application during SysML implementation | **Process decision** |
| D8 | StakeholderRelationship carries `ref relatedGovernanceRequirements : GovernanceRequirement` | **Binding** |
| D9 | ParticipationModel carries `ref relatedServiceOffering : ServiceOffering` | **Binding** |

---

## 9. Register Connections

### Tier 1 principles engaged

| Principle | How engaged |
|---|---|
| A4 (two meta model distinction) | All six elements are BMM concepts with appropriate doc blocks. BSMM horizontal mappings (§5.4 of the Session 76 paper) inform but don't constrain the design. |
| A9 (discipline) | Systematic resolution of all four open questions before proceeding to attribute design. |
| A11 (unity principle) | New elements will participate in the weighted relationship model (§5). Same weights inform comprehension, simulation, governance. |
| A13 (multi-tenancy) | All elements are General — domain-neutral structural patterns. Tailored extensions for healthcare-specific needs deferred appropriately. |
| J1 (cross-domain validation) | All six elements validated across Cafe, Suds, Paws, GSL (§6). |
| J2 (co-evolution) | Console tooling will pick up new elements automatically via the generator pipeline (D9). Weight graph will render new connections. No console code changes required. |
| J3 (non-constraining) | Closed enums extensible via Tailored `:>>`. Relationship Awareness not foreclosed. Sibling pattern preserves independence. |

### Concepts exercised

C7, C7a–C7f (StakeholderModel and all six General elements) — detailed design completed.
B12 (horizontal mappings) — two typed `ref` connections to other concerns.
B14 (weighted relationships) — conceptual weight design for ~20 new annotations.
B11 (General/Tailored decomposition) — all elements designed at General level; Tailored extension points identified.

### Register updates needed at session close

- C7a–C7f: update summaries with resolved attribute lists
- Note new enums (RelationshipNature, ReferralDirection, DependencyCriticality) — these may warrant register entries or may be covered under the element entries

---

## 10. Related Documents

- [[ontara-discussion-stakeholder-model-and-bsmm-vocabulary-2026-03-27|StakeholderModel and BSMM Vocabulary discussion paper]] (Session 76) — the parent document this paper builds on
- [[ontara-service-business-meta-modelling-v2|Service Business Meta Modelling v2]] — the foundations paper requiring a sixth section
- [[ontara-ref-master-register|Master Concept Register]] — register entries for C7, C7a–C7f
- [[ontara-ref-weighted-relationship-heuristics-and-config|Weighted Relationship Heuristics and Configuration]] — heuristics H1–H5 governing weight assessment
- [[ontara-ref-weighted-relationship-directionality-definition|Directionality Definition]] — directional semantics for weighted edges
- [[ontara-ref-kerml-reserved-words|KerML Reserved Words]] — name checking before SysML implementation
- [[ontara-discussion-service-participation-model-2026-03-21|Service Participation Model]] — the participation framework (O26) that ParticipationModel connects to
- [[ontara-discussion-model-self-service-enabling-architecture-2026-03-14|Self-Service Enabling Architecture]] — A7, H2 concepts connected to ParticipationModel

---

*Discussion paper written Session 78 (28 March 2026). Working document — detailed design reference for the SysML implementation session.*
