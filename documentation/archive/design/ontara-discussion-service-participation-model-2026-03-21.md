# Ontara — Discussion Document: The Service Participation Model

**Date:** 21 March 2026 (Session 55)
**Participants:** Ella Green, Claude (Opus 4.6)
**Status:** Architectural direction established. Two foundational concepts introduced. Full framework for future development.
**Origin:** Phase 4 Step 3 — resolution of the "service subject ≠ customer" meta model question (carried forward from Session 44, Paws demonstrator)
**Informed by:** [[ontara-stage-3-plan-phase-4-implementation-2026-03-21|Phase 4 Implementation Plan]] §3 Step 3, [[ontara-ref-master-register-design-concepts-tiered-2026-03-20|Tiered Master Register]], [[ontara-workflow-development-guide-2026-03-17|Workflow Guide]]

---

## 1. The Original Observation

The Paws demonstrator (Session 44) surfaced a structural observation: the paying customer (pet owner) is not the entity upon which the service is performed (the dog). The BMM's `CustomerSegment` `part def` describes who commissions and pays for a service. No concept exists for the entity that receives the service — the **service subject**. The observation was noted in the Paws model doc block and logged in the [[ontara-ref-master-register-design-concepts-tiered-2026-03-20|master register]] at O13.

This was logged as a deferred item in the Paws model doc block: *"The BMM does not currently distinguish between customer and service subject."*

---

## 2. From Single Distinction to Participation Framework

### 2.1 Initial analysis

The initial analysis (early in Session 55) framed this as a choice between three options: (a) no structural change, (b) a new `ServiceSubject` concept, or (c) attribute-level refinement. The recommendation was Option (b), with `ServiceSubject` designed as a lightweight General BMM concept, following the [[principle-coffeeshop-first|validate in toy domains first (A5)]] principle.

### 2.2 Ella's first correction: this is a family of roles

Ella's response reframed the question fundamentally. The customer/service-subject distinction is not a single separation — it is one instance of a general structural pattern, consistent with the [[gsl-service-business-meta-modelling|Service Business Meta Modelling]] paper's treatment of service concept structure: **a service engagement involves multiple participants, each with independently identifiable roles, each capable of influencing workflow pathways, each with their own status that must be tracked**.

The examples given:

- **Repair shop.** One customer brings two items for repair and one for a quote. Three service subjects, one customer, triggering distinct workflow pathways with different timescales and stakeholder impacts. The quote item requires an external expert to schedule an inspection before the quotation can be finalised — introducing a new participant. Meanwhile one repair item is collected and paid for, while the other is still in progress pending parts availability.

- **Healthcare.** A patient may have more than one concurrent medical problem, each triggering a panel of workflow items tracked separately. Different independent clinicians may be involved with follow-up care for each problem. The patient is one service subject with multiple concurrent engagement threads.

- **Financial advice.** Two customers, jointly and severally liable, receiving a service. Multiple customers, one engagement, shared liability.

- **Healthcare commissioning.** The patient receives the service. The NHS commissions it. The GP referred the patient. A carer makes decisions on behalf of a patient lacking capacity. Each is a distinct participation role with distinct effects on workflow, governance, consent, and communication. This connects directly to [[principle-clinical-governance-first-class|clinical governance as a first-class concern (A8)]] — governance obligations attach to participants differently depending on their role.

### 2.3 Ella's second correction: the framework is General

Claude's initial response attempted to classify which participation roles were "general" versus "tailored," referencing the General/Tailored decomposition (B11) from the [[ontara-discussion-component-catalogue-model-assembly-2026-03-18|Component Catalogue discussion]]. Ella rejected this: whether a particular role feels general or domain-specific on a Saturday afternoon in March is irrelevant to whether the framework should accommodate it. The meta model must not foreclose future development or thinking. This is a direct application of [[concept-non-constraining|J3 (non-constraining architecture)]].

The correct design: **the General BMM provides the structural framework for expressing participation roles, their multiplicity, and their relationships. Which roles a particular business chooses to instantiate is the business's decision, not the meta model's.**

### 2.4 The structural properties

From Ella's examples, the following structural properties emerge:

1. **Multiple participation roles.** A service engagement may involve: customers, service subjects, commissioners, payers, decision-makers, referrers, external experts, and others not yet identified. The set of roles is **open** — not a fixed enumeration.

2. **Many-to-many relationships at every level.** Multiple service subjects per customer. Multiple customers per engagement. Multiple payers per engagement. Multiple engagements per service subject. These form a web, not a hierarchy.

3. **Independent status tracking per participation.** Each service subject may be at a different stage. Each workflow pathway triggered by a participation may have its own timescale and stakeholder impacts. Status is a property of the participation, not just of the engagement.

4. **Independent influence on workflow.** Each participation role can trigger, modify, or block workflow pathways. A commissioner's approval may gate service delivery. A decision-maker's consent may be required before a clinical intervention. An external expert's availability may determine timescale. Either a service subject or a participant can trigger a workflow due to status or other determinant factors.

5. **Relationships between participants.** Participants have relationships to each other (owner-of, responsible-for, referred-by, acting-on-behalf-of, jointly-liable-with). These relationships are themselves meaningful — they influence governance obligations, consent chains, communication routing, and liability.

---

## 3. Two Foundational Concepts: ServiceSubject and ServiceParticipant

### 3.1 The decision: two sibling concepts

The discussion converged on introducing **two** concepts, not one: `ServiceSubject` and `ServiceParticipant`. These are **siblings**, not a hierarchy — neither specialises the other.

The reasoning: the service subject is structurally distinct from other participants. It is the entity the service *acts on*. But this distinction does not make it a "special kind of participant" in a hierarchical sense — both concepts have independent structural roles, either can trigger workflows, and both bring benefits that the other does not.

### 3.2 ServiceSubject — what the service acts on

`ServiceSubject` captures the entity upon which the service is performed: the dog being groomed, the patient receiving care, the garment being laundered, the item being repaired.

**Structural distinctiveness:**

- **The service acts on the subject.** Other participants influence the engagement; the subject *receives* it. This is a category distinction.
- **Governance obligations bind to the subject.** Duty of care is to the dog, the patient, the garment — not to the payer or commissioner. Legally and professionally load-bearing. This is the structural face of [[principle-clinical-governance-first-class|A8 (clinical governance as first-class concern)]] extended to all service domains.
- **The subject's characteristics shape the service.** The dog's breed determines grooming approach. The patient's clinical state determines the pathway. The item's condition determines the repair process.
- **Multiple subjects trigger independent workflows.** Two items for repair trigger two independent tracks. Two clinical problems trigger two panels. This multiplicative relationship between subjects and workflows is structural. It connects to the [[concept-scenario-definition|simulation concepts (L1–L4)]] and to the temporality discussion (E005/E006 in the [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]]).
- **Status changes in the subject can trigger workflow.** A dog showing signs of distress triggers grooming adaptation. A patient's lab results trigger clinical review. A repair item's diagnosis triggers a parts order.

### 3.3 ServiceParticipant — who else is involved, in what role

`ServiceParticipant` captures any other entity involved in the service engagement in any defined role: the customer, the payer, the commissioner, the decision-maker, the referrer, the external expert.

**Structural distinctiveness:**

- **Open role vocabulary.** The set of participation roles is not closed. Customer, payer, commissioner, decision-maker, referrer are starting points, not a fixed list.
- **Multiple roles per entity.** A self-referring private patient is both customer and decision-maker (and also a service subject — instantiated separately via `ServiceSubject`). The framework supports this through separate instantiations.
- **Status changes in a participant can trigger workflow.** A commissioner's budget approval gates service delivery. An external expert's availability determines scheduling. A payer's payment status triggers or blocks next steps.
- **Relationships between participants.** Participants have relationships to each other and to service subjects — these are meaningful for governance, consent, and communication.

### 3.4 Why siblings, not a hierarchy

Making `ServiceSubject` a specialisation of `ServiceParticipant` (via `part def ServiceSubject :> ServiceParticipant`) would imply that everything true of a participant is true of a subject. This may be constraining:

- A service subject may not have a "role" in the same sense as a participant — the dog doesn't play a role in the engagement; it *is* the engagement's focus.
- A participant's attributes (role, relationship to engagement) don't all apply naturally to a subject (the dog's "role" is not "customer" or "commissioner" — it's something categorically different).
- Either can independently trigger workflows — they have parallel structural power, not a parent-child relationship.
- Hierarchy commits us to an inheritance relationship that may not hold under future evolution.

As siblings, each concept carries its own attributes, its own weight set, its own [[concept-comprehension-layer|comprehension]] content. They are related by [[ontara-ref-weighted-relationship-heuristics-and-config-2026-03-21|weighted relationships (B14)]] but not structurally locked. This follows the [[concept-design-decision-lifecycle|design decision lifecycle (J12)]] — we are at the experimentation stage, and sibling concepts preserve more freedom than a committed hierarchy. This is cleaner and more [[concept-non-constraining|non-constraining (J3)]].

---

## 4. Naming and Reserved Words

### 4.1 KerML reserved words check

The complete KerML 1.0 reserved words list (§8.2.2.6) was checked from the local reference at `02 ARCHITECTURE & MODELLING/Design & Build Reference/KerML-Reserved-Words.md`. Naming was also reviewed against the [[gsl-sysml-v2-syntax-reference|SysML v2 syntax reference]]. `subject` is **not** a KerML reserved word.

The full list: `about`, `abstract`, `alias`, `all`, `and`, `as`, `assoc`, `behavior`, `binding`, `bool`, `by`, `chains`, `class`, `classifier`, `comment`, `composite`, `conjugate`, `conjugates`, `conjugation`, `connector`, `const`, `crosses`, `datatype`, `default`, `dependency`, `derived`, `differences`, `disjoining`, `disjoint`, `doc`, `else`, `end`, `expr`, `false`, `feature`, `featured`, `featuring`, `filter`, `first`, `flow`, `for`, `from`, `function`, `hastype`, `if`, `implies`, `import`, `in`, `inout`, `interaction`, `intersects`, `inv`, `inverse`, `inverting`, `istype`, `language`, `library`, `locale`, `member`, `meta`, `metaclass`, `metadata`, `multiplicity`, `namespace`, `nonunique`, `not`, `null`, `of`, `or`, `ordered`, `out`, `package`, `portion`, `predicate`, `private`, `protected`, `public`, `redefines`, `redefinition`, `references`, `rep`, `return`, `specialization`, `specializes`, `standard`, `step`, `struct`, `subclassifier`, `subset`, `subsets`, `subtype`, `succession`, `then`, `to`, `true`, `type`, `typed`, `typing`, `unions`, `var`, `xor`.

### 4.2 SysML v2 contextual keywords

`subject` is a contextual keyword in SysML v2 — it appears in requirement definitions and case definitions as a special parameter. However, contextual keywords are only reserved within their specific syntactic context, not as general identifiers. `ServiceSubject` as a `part def` name is a compound identifier, not the bare keyword — it should be safe. The definitive test is Syside validation, which is Ella's step.

### 4.3 Chosen naming

- **`ServiceSubject`** — the entity the service acts on. Clear, direct, structurally descriptive.
- **`ServiceParticipant`** — any entity involved in the engagement in a defined role. General, open, accommodates all future roles.

---

## 5. Cross-Domain Validation

### 5.1 Paws (dog grooming)

| Entity | Concept | Notes |
|---|---|---|
| Dog | `ServiceSubject` | Receives grooming. Has independent welfare needs. Groomer's duty of care is to the dog. Breed/coat determines service approach. |
| Pet owner | `ServiceParticipant` (customer, payer, decision-maker) | Books, pays, states preferences, collects. Preferences may be overridden by duty of care to the subject. |

### 5.2 Suds (laundry)

| Entity | Concept | Notes |
|---|---|---|
| Garments | `ServiceSubject` | Receive the washing/pressing. Fabric type determines handling. Multiple garments may have different treatment requirements. |
| Person dropping off | `ServiceParticipant` (customer, payer) | May or may not be the garment owner. |
| Garment owner | `ServiceParticipant` (owner — may differ from customer) | In a shared household, the person dropping off may not own all items. |

### 5.3 Cafe (coffee shop)

| Entity | Concept | Notes |
|---|---|---|
| Customer | Both `ServiceSubject` and `ServiceParticipant` (customer, payer, decision-maker) | All roles and the subject collapse to one entity. Trivial instantiation — valid, not forced. |

### 5.4 Repair shop (from Ella's example)

| Entity | Concept | Notes |
|---|---|---|
| Item 1 (for repair) | `ServiceSubject` | Being repaired. Status: in progress, completed, collected. |
| Item 2 (for repair) | `ServiceSubject` | Being repaired. Status: pending parts — different timescale. |
| Item 3 (for quote) | `ServiceSubject` | Awaiting expert inspection before quote can be finalised. |
| Customer | `ServiceParticipant` (customer, payer) | Brought all three items. Collects item 1 and pays balance while items 2 and 3 are still in progress. |
| External expert | `ServiceParticipant` (expert, inspector) | Scheduled to inspect item 3. Their availability determines the quote timescale. |

This example demonstrates: three service subjects with independent status and workflow timescales, one customer whose payment status is linked to one completed subject, and an external participant whose involvement is triggered by the needs of one specific subject.

### 5.5 GSL (healthcare — target domain)

| Entity | Concept | Notes |
|---|---|---|
| Patient | `ServiceSubject` | Receives clinical care. Has clinical needs, rights, pathway status. May have multiple concurrent clinical problems, each a separate engagement thread. |
| Patient (self-referring) | `ServiceParticipant` (customer, decision-maker) | In private practice, also holds participant roles. |
| NHS ICB | `ServiceParticipant` (commissioner) | Commissions care. Approval gates access. |
| GP | `ServiceParticipant` (referrer) | Initiates pathway. May remain in shared care. |
| Carer/parent | `ServiceParticipant` (decision-maker) | Acts on behalf of patient lacking capacity or under 16. |
| Insurance company | `ServiceParticipant` (payer) | Pays for private care. May impose requirements. |
| Specialist clinician | `ServiceParticipant` (service provider) | Different clinicians for different problems. |

### 5.6 Financial advice (from Ella's example)

| Entity | Concept | Notes |
|---|---|---|
| Client A | Both `ServiceSubject` and `ServiceParticipant` (customer, jointly liable) | Receives the advice and is a party to the engagement. |
| Client B | Both `ServiceSubject` and `ServiceParticipant` (customer, jointly liable) | Same — joint and several liability means both are customers and both are subjects of the advisory service. |

---

## 6. Architectural Direction: The Participation Framework

### 6.1 What the General BMM provides now (Session 55)

Two foundational sibling concepts:

- **`ServiceSubject`** — what the service acts on. Attributes: name, entity description, independent needs, status, condition notes.
- **`ServiceParticipant`** — who else is involved, in what role. Attributes: name, role (open String), entity description, relationship to engagement, status.

Both in `BusinessModel::ServiceConcept`. Both General BMM, following the [[ontara-discussion-component-catalogue-model-assembly-2026-03-18|General/Tailored decomposition (B11)]]. Both with full annotation stacks (the [[pattern-metadata-driven-generation|metadata-driven generation pattern (D9)]]). Related by [[ontara-ref-weighted-relationship-heuristics-and-config-2026-03-21|weighted relationships (B14)]] to each other and to existing BMM concepts, assessed using the five [[ontara-ref-weighted-relationship-heuristics-and-config-2026-03-21|weight assignment heuristics (H1–H5)]].

### 6.2 What is deferred to future work (not foreclosed)

| Capability | Description | Connects to |
|---|---|---|
| **Role vocabulary** | Common participation roles as reusable vocabulary (enum, specialisation, or separate concept) | Design choice deferred until more domain experience |
| **Multiplicity patterns** | Expressing "this engagement has three service subjects and one customer" | May require a ServiceEngagement container concept |
| **Independent status tracking** | Per-subject and per-participant state machines and their influence on workflow | E005/E006 (temporality) in the [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]] |
| **Participant relationships** | First-class relationships between participants (owner-of, acting-on-behalf-of, referred-by) | May use SysML v2 association/connection mechanisms |
| **Subject-participant linkage** | Expressing which participants relate to which subjects | Many-to-many; may need a junction concept |
| **Workflow influence** | How subject status and participant status gate/trigger/modify pathways | ServiceDelivery layer, [[concept-clinical-pathway|clinical pathway]] modelling |
| **Engagement threading** | Multiple concurrent engagement threads per subject (patient with two clinical problems) | Temporal meta model (E006) |

---

## 7. Relationship to Existing Concepts

### 7.1 Register concepts exercised

| Concept | How |
|---|---|
| [[concept-non-constraining\|J3]] (non-constraining) | Framework designed to accommodate future roles without structural change. General/Tailored classification of individual roles explicitly rejected as constraining. Two sibling concepts rather than constraining hierarchy. |
| [[concept-cross-domain-validation\|J1]] (cross-domain validation) | Observation surfaced from Paws, validated across all four domains plus two additional examples (repair shop, financial advice) |
| [[concept-intrinsic-self-knowledge\|A10]] (intrinsic self-knowledge) | Both new concepts receive full annotation stacks. Comprehension content generated from model |
| [[concept-unity-principle\|A11]] (unity principle) | Weight relationships connect both concepts to existing BMM vocabulary and to each other |
| [[concept-co-evolution\|J2]] (co-evolution) | Model concepts introduced alongside generator update and console verification |
| [[concept-model-generates-everything\|A3]] (model generates everything) | All metadata derived from model annotations |
| [[concept-inception-capture\|J13]] (inception capture) | The participation framework insight captured in full at the moment of recognition |
| B11 (General/Tailored decomposition) | Both concepts are General BMM, per the [[ontara-discussion-component-catalogue-model-assembly-2026-03-18|Component Catalogue discussion]]. The framework's openness means domain-specific roles don't require Tailored meta model extension |

### 7.2 Connections to emergent ideas

| Emergent idea | Connection |
|---|---|
| E005/E006 (temporality) in the [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]] | Independent status tracking per subject and per participant has a temporal dimension — each evolves over time, potentially at different rates |
| E001 (graph visualisation) | Two new nodes in the relationship graph, with edges to existing concepts and to each other |
| E008 (configuration table) | New weights will appear in the weighted relationship configuration table |

### 7.3 Deferred items resolved

The original deferred item — "service subject ≠ customer" — is resolved by this discussion. The resolution is: the distinction is real, it is General, and it is part of a broader participation model expressed through two sibling concepts. The deferred item has been closed in the [[ontara-ref-master-register-design-concepts-tiered-2026-03-20|master register]] (O13 updated, O26 added) and replaced with tracked concepts (ServiceSubject, ServiceParticipant, and the participation framework as a future direction). The implementation plan is at [[ontara-stage-3-plan-phase-4-step-3-implementation-2026-03-21|Phase 4 Step 3 implementation plan]]. The [[ontara-ref-weighted-relationship-directionality-definition|directionality definition]] applies to all new weights — each directed edge is independently assessed per [[ontara-ref-weighted-relationship-heuristics-and-config-2026-03-21|H5 (non-commutativity)]].

---

*Discussion document prepared 21 March 2026. Session 55.*
