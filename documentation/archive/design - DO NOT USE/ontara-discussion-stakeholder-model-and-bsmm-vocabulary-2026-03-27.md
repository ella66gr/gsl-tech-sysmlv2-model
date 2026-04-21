# StakeholderModel: A Sixth BMM Concern and the BSMM General Vocabulary

*Ontara Platform — Discussion Paper*
**Date:** 27 March 2026 (Session 76)
**Status:** Working document — proposed architectural change. Binding status per [[ontara-workflow-development-guide|discussion paper pipeline convention]] (§10.3 of the workflow guide).

---

## 1. Context and Stimulus

This paper captures two connected architectural decisions from Session 76. The session began with the BSMM vocabulary elaboration question identified in the Session 75 preparation note: the dual-stack architecture makes the Business System Meta Model explicit, but its General vocabulary — the domain-neutral system concepts any Ontara tenant would need — has not been articulated.

During the discussion, Ella questioned the solidity of the BMM's five concerns. This question, initially an aside, led to the recognition of a structural gap: the BMM's five concerns are all inward-facing. A sixth concern — **StakeholderModel** — is needed to model the relational dimension of a service business.

The two decisions are captured together because they are causally connected: the StakeholderModel decision must be made *before* the BSMM vocabulary is built, since the BSMM maps horizontally to the BMM at every level. Building the BSMM vocabulary against five concerns when there should be six would embed the gap structurally — a violation of J3 (non-constraining).

### 1.1 Epistemological note

Ontara's meta model reflects a considered, experience-informed view of what a service business *is*. The conceptual structure originates from Ella's professional and intellectual judgement, spanning clinical medicine, business leadership, and systems architecture. Empirical validation across demonstrator domains tests whether the model is internally consistent and practically applicable, but the foundational commitments themselves are authorial — as is true of all foundational modelling. BFO reflects Barry Smith's philosophical commitments about the structure of reality; the Business Model Canvas reflects Osterwalder's view of value creation. Ontara's BMM reflects Ella's view of what constitutes a complete description of a service business.

The important properties of these commitments are that they are explicit, defensible, and open to revision — not that they are empirically derived from first principles.

---

## 2. The Gap: Five Inward-Facing Concerns

### 2.1 The existing five

| Concern | What it covers | Orientation |
|---|---|---|
| ServiceConcept | What value is delivered, to whom, why it's worth paying for | Inward: what *we* offer |
| ActivityModel | How value is produced and delivered | Inward: how *we* work |
| ResourcePlanning | What resources and capabilities are required | Inward: what *we* need |
| FinancialPlanning | How money flows | Inward: how money moves *through us* |
| GovernanceMapping | Regulatory requirements, governance processes, risk | Inward: what rules *we* follow |

Plus Activity Awareness (C6) as a cross-cutting dimension.

### 2.2 The observation

Every BMM concern describes the internal logic of the service business. Where external entities appear, they appear as inputs to or constraints on the business's own operations: customers as the *target* of value delivery (ServiceConcept), regulators as the *source* of rules (GovernanceMapping), suppliers as a *type of resource* (ResourcePlanning). The **relationship itself** — the ongoing, structured, two-way interaction between the business and another entity — is not modelled as a first-class concern.

### 2.3 Why this matters

A service business does not operate in isolation. It operates within a web of structured relationships with other entities — and the nature, health, and governance of those relationships are as fundamental to the business as its internal logic. For a regulated care service like GenderSense, this is especially stark:

- NHS shared care arrangements define shared responsibility for patient care between GSL and the patient's GP. Neither party can deliver the service alone; the cooperative arrangement *is* the service model.
- Referral pathways are not merely "how patients arrive" — they are structured, bidirectional relationships with protocols, expectations, and feedback loops.
- The regulatory relationship with CQC is not just "rules we follow" — it is an ongoing, two-way interaction with inspection cycles, improvement requirements, and dialogue.
- The patient's own role as co-producer of their care — not merely a recipient — is a relational structure, not an activity classification.

These are not edge cases. They are central to how the business operates.

### 2.4 The J3 argument

The question arose during BSMM vocabulary elaboration. The BSMM maps horizontally to the BMM at every level. If the BMM has a structural gap, the BSMM inherits it. Building the BSMM vocabulary now — against five BMM concerns — would embed the assumption that five concerns are sufficient. Correcting this later would require re-engineering the BSMM horizontal mappings, revising the foundations papers, and updating the demonstrator domains.

The non-constraining principle (J3) requires that current decisions do not foreclose future development paths. Making this change now, before the BSMM vocabulary is built, is the least costly and most architecturally responsible time to do it.

---

## 3. StakeholderModel: The Sixth Concern

### 3.1 Definition

**StakeholderModel** is the BMM concern that covers the relational dimension of a service business: how it connects to, cooperates with, and jointly delivers value with entities beyond its own boundary.

The five existing concerns describe the internal logic of the business. StakeholderModel describes the **boundary** of the business and how it relates to the world beyond itself.

A stakeholder, in this context, is any entity with a structured, ongoing relationship with the business — not merely any entity that is affected by the business (the broader stakeholder theory definition). The emphasis is on *structured* relationships that the business actively manages, participates in, or depends on.

### 3.2 What it is not

StakeholderModel is not a catch-all for "everything external." Specific distinctions:

- **Customer demand** remains in ServiceConcept. StakeholderModel covers the *relationship structure* with customers (how they participate, how engagement evolves), not the value proposition itself.
- **Regulatory rules** remain in GovernanceMapping. StakeholderModel covers the *relationship* with the regulator (inspection cycles, dialogue, improvement requirements), not the rules themselves.
- **Supplier costs** remain in FinancialPlanning. StakeholderModel covers the *relationship* with the supplier (reliability, SLAs, cooperative obligations), not the cost line.
- **Staff as resources** remain in ResourcePlanning. StakeholderModel would cover partnerships with external workforce providers or clinical networks, not internal staffing.

The boundary is: if it's about the business's internal logic (what, how, with what, at what cost, under what rules), it belongs in the existing five. If it's about the structured relationship between the business and an external entity, it belongs in StakeholderModel.

### 3.3 Proposed General vocabulary

These are the domain-neutral `part def`s that any service business would instantiate:

**StakeholderRelationship** — the core abstraction. A typed, ongoing, structured relationship between the business and an external entity. Attributes: stakeholder identity (typed), relationship nature (enum), obligations flowing in each direction, information exchanged, governance arrangements, health indicators, review cadence.

**CooperativeArrangement** — a formalised agreement to jointly deliver or jointly manage something. Shared care protocols, referral agreements with SLAs, platform partnerships. Distinguished from a simple stakeholder relationship by *shared responsibility for an outcome*. Neither party can deliver independently; the arrangement itself is load-bearing.

**ReferralPathway** — a structured route for directing or receiving work between organisations. Inbound and outbound. With protocols, expectations, acceptance criteria, feedback mechanisms, and volume tracking. In healthcare: GP referrals, specialist referrals, cross-service pathways. In commercial domains: lead referrals, supplier introductions, partnership channels.

**ExternalDependency** — something the business depends on that it does not control. A supplier, a regulatory body, an infrastructure provider, a platform. Characterised by asymmetric reliance and the need for contingency planning. Distinct from a CooperativeArrangement because the power relationship is asymmetric — the business depends on the external entity more than the reverse (or at least differently).

**CommunityRelationship** — the business's connection to its broader community of interest. For GSL: the trans community, peer support networks, advocacy organisations, professional communities. For Paws: local dog owners, breed clubs, the vet network. For Cafe: neighbourhood regulars, local food culture. This is where "commonality of endeavour" and shared purpose live — relationships that are not transactional but constitutive of the business's identity and social context.

**ParticipationModel** — how the customer/patient participates in the service as a co-producer, not merely a recipient. The nature of their engagement, their role in shaping the service, their contribution to shared knowledge. This is where the self-service architecture ([[ontara-ref-master-register|A7]]) connects to the relational dimension. In healthcare: the patient as active participant in their own care, contributing to decision-making, managing aspects of their treatment, engaging with peer support. In commercial domains: the customer's role in co-creating the service experience (customisation, feedback loops, loyalty, community contribution).

### 3.4 Relationship nature taxonomy

A preliminary enum for classifying relationship types:

| Type | Character | Example |
|---|---|---|
| **regulatory** | Oversight, compliance, inspection | CQC, NHSE, HMRC |
| **cooperative** | Shared delivery, joint responsibility | NHS shared care, delivery platform partnership |
| **referral** | Structured work routing | GP referral pathway, specialist referral |
| **supply** | Goods or services procurement | Chemical supplier, coffee bean supplier |
| **community** | Shared identity, mutual support | Trans community, local business network |
| **participatory** | Customer/patient as co-producer | Patient in care pathway, customer in loyalty programme |
| **professional** | Peer network, professional body | RCP, GMC, professional associations |
| **contractual** | Formal service agreement | Equipment maintenance, IT support |

This is illustrative, not final. The taxonomy should be validated across demonstrator domains before becoming binding.

---

## 4. Cross-Domain Validation

### 4.1 GenderSense (GSL)

| Element | GSL instantiation |
|---|---|
| StakeholderRelationship | CQC (regulatory), NHSE commissioning (regulatory), professional indemnity insurer (contractual) |
| CooperativeArrangement | NHS shared care protocol with patient's GP (joint clinical responsibility), East of England Gender Service partnership |
| ReferralPathway | Inbound: GP referrals, self-referrals. Outbound: surgical referrals, endocrinology, speech therapy, mental health |
| ExternalDependency | Pharmaceutical suppliers, lab services, EHRbase CDR infrastructure, Temporal platform |
| CommunityRelationship | Trans community, peer support networks, advocacy organisations (Mermaids, Gendered Intelligence), professional networks (BAGIS) |
| ParticipationModel | Patient as active co-producer of care: informed consent, shared decision-making, self-monitoring, journal/reflection, peer support participation |

### 4.2 Paws (dog grooming)

| Element | Paws instantiation |
|---|---|
| StakeholderRelationship | Local authority (business licensing — regulatory), insurance provider (contractual) |
| CooperativeArrangement | Vet partnership for skin condition referrals (bidirectional), dog walker partnership for client referrals |
| ReferralPathway | Inbound: vet recommendations, walker referrals. Outbound: vet referrals for skin/health concerns noticed during grooming |
| ExternalDependency | Grooming product suppliers, equipment maintenance provider |
| CommunityRelationship | Local dog owners' community, breed-specific groups, the neighbourhood |
| ParticipationModel | Dog owner as participant: describes dog's temperament, preferences, health needs; provides feedback on groom quality; regular engagement builds trust and service continuity |

### 4.3 Cafe (coffee shop / CSW)

| Element | Cafe instantiation |
|---|---|
| StakeholderRelationship | Local authority (food hygiene — regulatory), landlord (contractual) |
| CooperativeArrangement | Delivery platform partnerships (Deliveroo, UberEats — shared order fulfilment), local bakery supply arrangement |
| ReferralPathway | Limited formal referral; word-of-mouth and platform-mediated discovery |
| ExternalDependency | Coffee bean supplier, milk supplier, equipment maintenance, POS system provider |
| CommunityRelationship | Neighbourhood regulars, local food culture, community events hosting |
| ParticipationModel | Customer as participant: customisation requests, loyalty engagement, feedback, community atmosphere contribution |

### 4.4 Suds (laundry)

| Element | Suds instantiation |
|---|---|
| StakeholderRelationship | HSE / local authority (COSHH compliance — regulatory), insurance provider (contractual) |
| CooperativeArrangement | Commercial linen clients (cooperative scheduling — they deliver dirty, Suds returns clean, on agreed cadence and quality standards) |
| ReferralPathway | Limited formal referral; commercial client introductions |
| ExternalDependency | Chemical supplier (with COSHH compliance obligations on both sides), equipment supplier, water/utilities |
| CommunityRelationship | Local business network, commercial district relationships |
| ParticipationModel | Customer as participant: specifies fabric care requirements, stain information, delivery preferences |

### 4.5 Validation assessment

Every proposed General element has concrete content in all four demonstrator domains. No element is forced or empty in any domain. The elements are domain-neutral in character — they describe *structural patterns* that each domain instantiates with its own content.

The CommunityRelationship and ParticipationModel elements show the most variation across domains — community means something very different for a healthcare service than for a coffee shop. This is expected and healthy: the General vocabulary defines the structural pattern; the Tailored layer and domain instantiation supply the specific character.

---

## 5. BSMM General Vocabulary: Capability Groups with Architectural Role Axis

### 5.1 Design decision

The BSMM General vocabulary is organised by **system capability** (what the system does), with **architectural role** as a secondary classification axis.

The capability-based organisation was chosen over alternatives after structured evaluation against four engineering purposes:

1. **Guide instantiation** — capability groups serve as a natural checklist when modelling a new tenant domain. "What persistence does this business need? What orchestration? What evaluation?"
2. **Enable generation** — individual `part def`s are what generators consume; grouping is for human comprehension.
3. **Support horizontal mapping** — BMM concerns map to BSMM capabilities in a many-to-many pattern. This is the correct representation; forcing one-to-one symmetry would lose information.
4. **Ground the reflective simulation** — the architectural role axis preserves the meta-level typing the reflective simulation will need, without requiring it to be the primary organising structure.

A purely role-based organisation (Approach C) was considered but rejected on engineering grounds: it imposes a higher cognitive load on the domain modeller, is harder to validate empirically across demonstrators, and optimises for the reflective simulation (which is horizon work) at the expense of practical usability now.

The hybrid — capability groups as primary structure, architectural role as secondary axis — preserves the option to surface role-based views later without paying the cost of role-based organisation now.

### 5.2 The six capability groups

**1. Persistence & Data Management**
What it covers: where data lives, why, what characteristics govern the decision.
Existing concepts: `PersistencePolicy`, `PersistenceLayer`, `DataCharacteristic`.
Status: Already well-articulated at the General level.

**2. Process Orchestration**
What it covers: how sequences of work are coordinated, durable state management, participant roles in workflows.
Existing concepts: `AgencyClassification`, `AgencyType`. The Orchestration package in Platform has the right shape but lacks General-level `part def`s.
Needed: General abstractions for workflow types, activity types, state machine patterns — e.g. `ProcessSpecification`, `ActivityDefinition`, `ParticipantRole`.

**3. Evaluation & Reasoning**
What it covers: constraint evaluation, decision support, deficit detection, goal-state computation.
Existing concepts: `ConstraintEvaluationSpec`, `InputDerivation`, `EvaluationOutcome`, `Severity`, `DeficitDomain`, `RemediationCategory`, `DataSourceType`, `AssessmentScope`. The three-tier reasoning stack.
Status: Mature but clinically framed. General vocabulary needs domain-neutral versions. The reasoning stack *pattern* is General; specific rules are Tailored.

**4. Observation & Self-Knowledge**
What it covers: system self-description, information surfacing, state tracking and reporting.
Existing concepts: `@Comprehension`, `@UserFacing`, `@PurposiveDescription`, `@WeightedRelationship`, `RelationshipStrength`, `@CatalogueTag`. Reporting use cases in Operations.
Future: `ObservationPoint`, `MetricDefinition`, and eventually valence and snapshot concepts (L7, L8) — but these are exploratory and should not be promoted to General vocabulary until validated.

**5. Integration & Communication**
What it covers: connections to external services, communication with participants.
Existing concepts: Platform packages (Booking, Messaging, LabInterface, etc.) modelled as use cases.
Needed: General abstractions for integration patterns — `ExternalServiceBinding`, `CommunicationChannel`, `EventRoute`.

**6. Identity & Access**
What it covers: user identity, authorisation, access control, consent-based data access.
Existing concepts: `UserAccount`, authentication and authorisation use cases.
Needed: General abstractions for role-based access, consent-governed data access, participant visibility boundaries.

### 5.3 The architectural role axis

Each BSMM General concept carries a secondary classification — its role in the dual-stack architecture:

| Role | Meaning | Examples |
|---|---|---|
| **Structural template** | Defines what kinds of system elements can exist — instantiated per domain | `PersistencePolicy`, `ExternalServiceBinding`, `ProcessSpecification` |
| **Execution primitive** | Makes the system run — consumed by the generation pipeline and operational simulation | `ActivityDefinition`, `EventRoute`, state machine patterns |
| **Governance instrument** | Constrains dynamic behaviour inside the green container | `ConstraintEvaluationSpec`, `SafetyConstraint`, access control rules |
| **Comprehension metadata** | Describes and comprehends the system — cross-cutting, read by the reflective simulation | `@Comprehension`, `@WeightedRelationship`, `ObservationPoint` |

Implementation options: (a) an enum `ArchitecturalRole` with metadata annotation on each BSMM `part def`, or (b) classification recorded in doc blocks and the register, with formal annotation deferred until the reflective simulation needs programmatic access. Option (b) is sufficient for now; option (a) is a straightforward promotion when needed.

### 5.4 Horizontal mappings: StakeholderModel to BSMM

The new sixth concern maps to the BSMM capability groups in the expected many-to-many pattern:

| StakeholderModel element | Primary BSMM capability mappings |
|---|---|
| StakeholderRelationship | Persistence (relationship data), Identity & Access (stakeholder authentication) |
| CooperativeArrangement | Process Orchestration (cross-organisation workflows), Integration & Communication (system-to-system connections), Evaluation & Reasoning (SLA compliance checking) |
| ReferralPathway | Process Orchestration (referral workflow), Integration & Communication (referral messaging), Persistence (referral records) |
| ExternalDependency | Integration & Communication (service bindings), Observation & Self-Knowledge (dependency health monitoring) |
| CommunityRelationship | Integration & Communication (community platforms), Persistence (community engagement data) |
| ParticipationModel | Identity & Access (participant roles and permissions), Process Orchestration (participant activities in workflows), Observation & Self-Knowledge (engagement metrics) |

---

## 6. The Revised BMM: Six Concerns

### 6.1 The complete concern set

| # | Concern | What it covers | Orientation |
|---|---|---|---|
| 1 | **ServiceConcept** | What value is delivered, to whom, why it's worth paying for | Internal: what we offer |
| 2 | **ActivityModel** | How value is produced and delivered | Internal: how we work |
| 3 | **ResourcePlanning** | What resources and capabilities are required | Internal: what we need |
| 4 | **FinancialPlanning** | How money flows | Internal: how money moves through us |
| 5 | **GovernanceMapping** | Regulatory requirements, governance processes, risk, learning | Internal: what rules we follow |
| 6 | **StakeholderModel** | Relationships, partnerships, external stakeholders, cooperative delivery, community, participation | Boundary: how we connect to the world beyond ourselves |

Plus Activity Awareness (C6) as a cross-cutting dimension.

### 6.2 Architectural character

The six concerns now span two orientations:

- **Concerns 1–5** describe the **internal logic** of the service business — its value proposition, delivery mechanism, resource base, financial structure, and governance framework.
- **Concern 6** describes the **relational boundary** — how the business connects to, cooperates with, and jointly operates with external entities.

This is not a mere addition of another internal concern. StakeholderModel has a fundamentally different character from the other five: it faces outward. It models the *interface* between the business and its environment, not the business's own machinery.

### 6.3 Interaction with existing concerns

StakeholderModel interacts with every existing concern but does not subsume any of them:

| Existing concern | Interaction with StakeholderModel |
|---|---|
| ServiceConcept | StakeholderModel's ParticipationModel shapes how value is experienced; CooperativeArrangements may define jointly-delivered services. But the value proposition itself remains in ServiceConcept. |
| ActivityModel | CooperativeArrangements and ReferralPathways generate cross-boundary activities. But the internal delivery processes remain in ActivityModel. |
| ResourcePlanning | ExternalDependencies are resources the business doesn't own. But internally-held resources remain in ResourcePlanning. |
| FinancialPlanning | Stakeholder relationships have financial dimensions (costs, revenue sharing, contractual payments). But the financial structure remains in FinancialPlanning. |
| GovernanceMapping | Regulatory relationships are stakeholder relationships. GovernanceMapping holds the *rules*; StakeholderModel holds the *relationship* through which rules are communicated, inspected, and enforced. |

The GovernanceMapping interaction deserves particular attention. There is a legitimate debate about whether regulatory relationships belong in GovernanceMapping (as they do now) or in StakeholderModel (as the relational framing suggests). The answer is: both, but different aspects. The rule content (what must we comply with?) stays in GovernanceMapping. The relationship structure (who inspects us, how often, what the dialogue looks like) moves to StakeholderModel. This dual classification is natural — it mirrors the real-world distinction between the regulatory framework and the regulatory relationship.

---

## 7. Implications and Dependencies

### 7.1 Documents requiring revision

| Document | Change needed | Priority |
|---|---|---|
| Service Business Meta Modelling v2 | Add §6 (or equivalent) for StakeholderModel; revise §1 overview and concern summary | High — foundations paper |
| Strategic reference | §2.3: five-concern table → six; §3.1 BMM element count | Medium — next refresh |
| Vision and architecture reference v3 | §3 concern table; element counts | Medium — next refresh |
| Master register | New T2 entry for StakeholderModel; new entries for General elements | This session (close) |
| Concept Graph Index | New concept notes for StakeholderModel elements | When notes are created |
| Stage 4 high-level plan | Assess impact on Phase 5 (assembly workspace) — StakeholderModel elements need to be navigable | Low — not yet in scope |

### 7.2 Model changes required

- New SysML package: `BusinessModel::StakeholderModel` with General-level `part def`s
- `@CatalogueTag` annotations on all new elements (bmmConcern = "StakeholderModel")
- `@UserFacing`, `@PurposiveDescription`, `@Comprehension`, `@WeightedRelationship` annotations — maintaining parity with existing BMM elements
- Demonstrator domain instantiations in Cafe, Suds, Paws (at minimum)
- Generator update: `gen_model_introspection.py` will pick up new elements automatically; console views (glossary, component catalogue, coverage matrix) should display them without code changes if the generator output is correct

### 7.3 BMM element count

Current: 28 elements across 5 concerns.
Proposed: ~34 elements across 6 concerns (~6 new General elements in StakeholderModel).
The exact count depends on whether all six proposed elements survive detailed design.

---

## 8. Key Decisions

| # | Decision | Status | Implication |
|---|---|---|---|
| 1 | The BMM moves from five concerns to six | **Proposed — from this session** | StakeholderModel as the sixth concern |
| 2 | StakeholderModel covers the relational boundary | **Proposed** | Relationships, partnerships, cooperative delivery, community, participation |
| 3 | Six General-level elements proposed | **Proposed — subject to design refinement** | StakeholderRelationship, CooperativeArrangement, ReferralPathway, ExternalDependency, CommunityRelationship, ParticipationModel |
| 4 | BSMM vocabulary organised by capability with role axis | **Proposed — from this session** | Six capability groups; four architectural roles as secondary classification |
| 5 | BSMM horizontal mappings are many-to-many | **Confirmed** | No forced one-to-one symmetry between BMM concerns and BSMM groups |

### Binding status (discussion paper pipeline convention)

Decision 1 is proposed as **binding** — it addresses a structural gap identified through analysis, validated across all four demonstrator domains, and grounded in established business modelling frameworks. It should be made before the BSMM vocabulary is built.

Decisions 2 and 3 are **proposed and subject to refinement** — the specific elements and their attributes need detailed design work and may evolve during implementation.

Decisions 4 and 5 are **directional commitments** — they set the organising approach for the BSMM vocabulary, which will be validated through implementation.

---

## 9. Open Questions

1. **Exact element vocabulary.** The six proposed StakeholderModel elements are a starting point. Detailed design may merge, split, or rename them. In particular: is `ParticipationModel` distinct enough from `StakeholderRelationship`, or is participation a *type* of stakeholder relationship?
2. **Relationship to Activity Awareness (C6).** Activity Awareness is the existing cross-cutting dimension. Should StakeholderModel have its own cross-cutting aspect — "Relationship Awareness" — or is the concern-level treatment sufficient?
3. **GovernanceMapping boundary.** The dual-classification of regulatory relationships (rules in GovernanceMapping, relationship in StakeholderModel) needs careful articulation to avoid confusion. Design guidelines needed.
4. **Weighted relationships.** The existing 79 weighted relationships were designed for 28 BMM elements across 5 concerns. Adding ~6 elements in a new concern will require new weight annotations. What is the right phasing?
5. **Tailored StakeholderModel elements.** The proposed elements are all General. Healthcare tenants will need Tailored extensions — `SharedCareProtocol`, `ClinicalReferralPathway`, `PatientAdvocacyRelationship`, etc. These should be designed when GSL instantiation is scoped.

---

## 10. Register Connections

### Tier 1 principles engaged

| Principle | How engaged |
|---|---|
| A2 (self-describing system) | The system should know its stakeholder landscape and relationship structures |
| A4 (two meta model distinction) | StakeholderModel is a BMM concern with many-to-many BSMM mappings |
| A9 (discipline as load-bearing structure) | Identifying and addressing the gap now, before building on top of it |
| A11 (unity principle) | Stakeholder relationships will participate in the weighted relationship model |
| A12 (coordinate framework) | Relationship health, engagement depth, and cooperation intensity are coordinate axes |
| A13 (multi-tenancy) | Each tenant has its own stakeholder landscape; the General vocabulary captures structural patterns |
| J2 (co-evolution) | The new concern will need console representation alongside model content |
| J3 (non-constraining) | The change is made before the BSMM vocabulary embeds the five-concern assumption |

### New concepts introduced

- StakeholderModel (BMM concern) — needs T2 register entry
- StakeholderRelationship, CooperativeArrangement, ReferralPathway, ExternalDependency, CommunityRelationship, ParticipationModel — need T3 register entries (BMM General elements)
- BSMM capability groups (6) — need T2 register entry
- Architectural role axis (4 roles) — needs T3 register entry

### Emergent Ideas Log

E015 captured during Session 76 with full context and connections.

---

## Related Documents

- [[ontara-discussion-dual-stack-architecture-2026-03-26|Dual-stack architecture discussion paper (Session 73/74)]] — the stimulus for BSMM vocabulary elaboration
- [[ontara-service-business-meta-modelling-v2|Service Business Meta Modelling v2]] — the foundations paper that will need revision
- [[ontara-ref-strategic-snapshot|Strategic reference (Session 74)]] — five-concern table that becomes six
- [[ontara-ref-vision-architecture|Vision and architecture reference v3 (Session 75)]] — concern summary needing update
- [[ontara-ref-master-register|Master register]] — register entries for new concepts
- [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log (E015)]] — the inception capture for StakeholderModel

---

*Discussion paper written Session 76 (27 March 2026). Working document — proposed, not yet binding. The StakeholderModel decision is proposed as binding per the reasoning in §8.*
