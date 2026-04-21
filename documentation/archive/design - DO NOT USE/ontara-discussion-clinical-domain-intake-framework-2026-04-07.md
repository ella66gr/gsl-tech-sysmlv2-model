---
tags:
  - architecture
  - discussion
  - methodology
  - domain-intake
date: 2026-04-07
status: working
session: 160
---
# Clinical Domain Intake Framework: A Methodology for Domain Characterisation, Ingestion, and Platform Fitness Validation

*Ontara Platform — Discussion Paper*

**Date:** 7 April 2026 (Session 160)
**Purpose:** Establishes a structured methodology for characterising clinical service domains, ingesting them into the Ontara platform, and using the intake process to validate platform vocabulary fitness and identify extension points. Builds on the Paws demonstrator intake precedent (Sessions 43–44) and extends it for the additional complexity of clinical domains. Introduces the feature taxonomy, the proforma intake schema, the coverage map concept, and a tooling roadmap.
**Status:** Working document — methodology design.

**Depends on:**
- [[paws-domain-description|Paws domain description]], [[paws-vertical-connection-map|vertical connection map]], and [[paws-design-note-2026-03-19|design note]] (Sessions 43–44)
- [[ontara-architecture-business-meta-modelling|Service Business Meta Modelling]] (v3, Session 154)
- [[ontara-discussion-institutionalised-reasoning-2026-04-05|Institutionalised Reasoning]] (Session 146) — reasoning metamodel
- [[ontara-discussion-coordinate-framework-revisited-2026-04-05|The Coordinate Framework Revisited]] (Session 147) — coordinate space, constraint geometry, epistemic reconciliation
- [[ontara-discussion-deontic-governance-architecture-2026-04-03|Deontic Governance Architecture]] (Session 121) — governance vocabulary
- [[ontara-discussion-domain-identity-dual-stack-2026-04-05|Domain Identity in the Dual-Stack Architecture]] (Session 142) — DomainIdentity/DomainConfiguration
- [[ontara-discussion-knowledge-graph-architecture-2026-04-01|Knowledge Graph Architecture]] (Session 97) — three-stratum graph, authority zones, pipeline

---

## Contents

- [[#1. Why This Paper|§1. Why This Paper]]
- [[#2. What the Paws Precedent Established|§2. What the Paws Precedent Established]]
- [[#3. What Clinical Domains Add|§3. What Clinical Domains Add]]
- [[#4. The Three Dimensions of Model Constraint|§4. The Three Dimensions of Model Constraint]]
- [[#5. The Feature Taxonomy|§5. The Feature Taxonomy]]
- [[#6. The Proforma Intake Schema|§6. The Proforma Intake Schema]]
- [[#7. The Coverage Map|§7. The Coverage Map]]
- [[#8. Ears as First Clinical Intake|§8. Ears as First Clinical Intake]]
- [[#9. Tooling Roadmap|§9. Tooling Roadmap]]
- [[#10. Relationship to the Dual-Stack Architecture|§10. Relationship to the Dual-Stack Architecture]]
- [[#11. Design Decisions|§11. Design Decisions]]
- [[#12. Open Questions|§12. Open Questions]]
- [[#13. Register Connections|§13. Register Connections]]

---

## 1. Why This Paper

Stage 7 (Sessions 146–158) produced a rich reasoning metamodel vocabulary — 42 OWL classes covering reasoning contexts, evidence architecture, constraint hierarchy, heuristic packs, decision mode routing, safety control structures, and more. The vocabulary is structurally validated (HermiT CONSISTENT, 56/56 SPARQL queries passing, cross-domain class-level validation). But it has never been populated with real domain content. The same applies, to a lesser degree, to the deontic governance vocabulary (Sessions 121–131) and the OGMS clinical ontological layer.

The architectural risk is not that these vocabularies are structurally inconsistent — that has been tested — but that they may not fit the domain content they are meant to describe. This is a representational adequacy problem, not a logical consistency problem, and structural tests cannot detect it. The only way to discover mismatches is to attempt to express real domain content using the vocabulary. The sooner this is done, the lower the cost of correction — before subsequent workstreams build layers on top of assumptions that haven't been validated against reality.

This paper establishes the methodology for doing that validation systematically, not just for the immediate Ears demonstrator but as a repeatable process for any clinical domain — and ultimately any service domain — that the platform will ingest. The methodology has three components:

1. **A feature taxonomy** that characterises domains along typed dimensions, locating each service in the space of possible services.
2. **A proforma intake schema** that structures the systematic capture of a specific domain's significant features, mapped to meta model elements.
3. **A coverage map** that records which platform vocabulary elements are exercised by each intake question, where gaps exist, and where the branching points in the meta model's design tree lie.

Together, these constitute a new platform capability: the ability to characterise what the platform can currently describe, where its representational boundaries are, and how to extend them. This is a form of platform self-knowledge that complements A2 (self-describing system) and A10 (intrinsic self-knowledge) — not "the system knows what it is" but "the system knows what it can and cannot currently model."

---

## 2. What the Paws Precedent Established

The Paws demonstrator intake (Sessions 43–44) established a three-document pattern:

**The domain description** — a rich, narrative account of the business in full colour. Sue and Sam's dog grooming salon, with Pol at reception (her five-year-old son Jim, her rescue dog Ollie, her calm manner, the biscuit tin). This demonstrated that the platform can ingest messy, human business data — including "softer" information that gives the simulation texture and relatability without clogging the structured model.

**The vertical connection map** — the systematic mapping from ontology categories through BMM General vocabulary through business instance to generated systems. This is where analytical rigour lives. Every piece of domain data traces upward to its meta model parent and downward to the systems it drives. The vertical connection map revealed concrete meta model insights: ServiceSubject as distinct from Customer, ConstrainableResource as a scheduling concept, the governance posture spectrum across demonstrator domains.

**The design note** — cross-domain observations, BMM adequacy assessment, and resolved design decisions. This is where the *learning* lives — what the exercise revealed about the meta model's fitness for the domain. The design note confirmed that all 51 Paws elements used exclusively BMM General vocabulary with no new Tailored part defs required.

This pattern transfers directly to clinical domains. The domain description becomes the rich narrative of the clinical service (and its people). The vertical connection map becomes the systematic mapping through the extended vocabulary stack (BMM + reasoning + governance + OGMS). The design note becomes the coverage gap analysis.

What the Paws exercise did not do — because the domain didn't require it — was exercise clinical reasoning, governance at depth, safety structures, clinical ontological primitives, or information governance. A clinical domain intake framework must extend the Paws pattern to cover these dimensions.

---

## 3. What Clinical Domains Add

Clinical service domains exercise platform capabilities that non-clinical domains do not touch. These additional dimensions are what make the clinical intake framework architecturally significant.

### 3.1 Clinical reasoning

A dog grooming service has no decision-making that exercises the reasoning metamodel. A clinical service has assessment → diagnosis → treatment decision chains where Claims are asserted, EvidenceLines are constructed from clinical findings, and ReasoningActivities produce decisions that determine the patient's pathway. The three-way constraint hierarchy becomes concrete: clinical contraindications are HardConstraints ("never irrigate a perforated eardrum"), clinical guidelines contain GradedRules ("olive oil softening for 3–5 days improves outcomes"), and resource preferences are SoftConstraints ("prefer microsuction over irrigation where both are available").

For the Ears domain specifically: the pre-appointment triage is a decision structure with red flags as HardConstraints. The procedure selection (irrigation vs microsuction vs manual removal) is a clinical decision exercising the full evidence architecture. The contraindication screening maps to the SEPIO pattern — a Claim about patient suitability, supported by EvidenceLines from history and otoscopy, producing a decision with a declared InterpretiveFrame.

### 3.2 Governance density

Paws has a single general duty of care under the Animal Welfare Act. A clinical service operates under multiple overlapping governance regimes:

- **Service regulation:** CQC registration and inspection (regulated activities: treatment of disease, disorder or injury; diagnostic and screening procedures).
- **Professional regulation:** NMC for nurses, GMC for medical oversight, HCPC for audiologists — each with scope-of-practice and competency frameworks.
- **Clinical guideline compliance:** NICE guidance on earwax removal, local commissioning standards, evidence-based protocols.
- **Employment and workforce governance:** mandatory training (BLS, IPC, safeguarding), competency sign-off, revalidation support.
- **Information governance:** UK GDPR, Data Protection Act 2018, Caldicott principles, DPIA requirements, clinical record retention.

The deontic governance vocabulary (Obligations, Prohibitions as HardConstraints via the reasoning-governance alignment) gets exercised at a depth Paws never approached. Each governance regime generates a set of obligations that must be traced through to evidence of compliance.

### 3.3 Clinical ontological primitives

Non-clinical domains map to BFO through generic categories. Clinical domains map through OGMS — clinical encounter, symptom, assessment, diagnosis, treatment process, treatment outcome. The Ears domain is the first to instantiate these primitives with real content. The clinical pathway (triage → assessment → procedure → post-procedure → follow-up) is a sequence of OGMS-typed entities, each with specific clinical semantics that the generic BMM ActivityModel does not capture.

### 3.4 Safety and clinical risk

The STAMP/STPA structures from Phase 3 of Stage 7 (SafetyConstraint, ControlStructure, ControlLoop, ControlAction, UnsafeControlAction) get their first real exercise. The clinician is a Controller. The irrigation procedure is a ControlAction. "Irrigating a perforated eardrum" is an UnsafeControlAction of type "providing causes hazard." The pre-procedure screening is a ControlLoop with feedback from otoscopic examination. The FRAM-ready slots (FRAMFunction, VariabilityProfile) model the variability in clinical practice — how the procedure adapts to individual patient presentation.

### 3.5 Information governance

Clinical services handle special category health data under GDPR Article 9, with specific requirements around consent, retention, sharing, and Caldicott principles. Otoscopic images are clinical records. Patient contact details are personal data. The information governance dimension exercises governance vocabulary elements that Paws (basic personal data) and Suds (COSHH records) did not reach.

---

## 4. The Three Dimensions of Model Constraint

Models are necessarily and desirably constrained. Three dimensions of constraint shape what any model can express:

### 4.1 Ontological scope

What kinds of things can the model talk about? The BMM's six concerns define the ontological scope for service businesses: service concept, activity, resources, finance, governance, stakeholders. The reasoning metamodel extends this to reasoning contexts, decisions, evidence, constraints. The OGMS layer extends it further to clinical encounters, symptoms, diagnoses, treatments. Each extension widens the ontological scope — the set of things the platform can represent.

### 4.2 Level of abstraction

How much detail can the model express? The BMM operates at the level of ServiceOfferings, ResourceTypes, and GovernanceRequirements — structural categories, not individual appointments or stock items. The business instance layer adds specific parameterisation. The runtime layer adds operational detail. Each layer adds resolution. The question for any domain feature is: at which level of abstraction does the platform currently represent it, and is that sufficient?

### 4.3 Characteristics of causal relations

How does the model express that things affect each other? The weighted relationships (96 across 33 elements) express "if A changes, how much does B need reassessment?" The constraint hierarchy (Hard/Soft/Graded) expresses how rules compose and override. The STAMP/STPA structures express control-theoretic causation (controller → control action → controlled process, with feedback loops). Each causal formalism captures different kinds of influence.

### 4.4 The branching-point principle

These constraints are not defects — they are the design choices that make the model useful rather than an "anything machine." But they must be conscious and documented. The goal is to have explicit branching points in the meta model's design tree: when a new domain feature cannot be expressed, the architect can trace back up the tree and see exactly where the constraining choice was made. The choice is then either: (a) the constraint is correct and the feature is out of scope, or (b) the constraint should be relaxed and the meta model extended.

The coverage map (§7) makes these branching points operational. For each domain feature that the platform cannot currently express, the coverage map records which dimension of constraint is responsible (ontological scope, abstraction level, or causal formalism) and where in the meta model hierarchy the extension point lies.

---

## 5. The Feature Taxonomy

The feature taxonomy characterises clinical service domains along typed dimensions. Each dimension has a defined value space. A specific domain is characterised by its position across all dimensions. This is analogous to the coordinate framework (A12) applied to domains themselves — domains as points in a feature space.

### 5.1 Pathway topology

How complex is the clinical journey's shape?

| Value | Description | Example |
|---|---|---|
| Linear | Single path from presentation to discharge | Ears (straightforward cases) |
| Branching | Decision points create alternative paths | Ears (irrigation vs microsuction vs referral) |
| Cyclical | Repeating episodes with the same patient | Ears (recurrent wax), chronic disease management |
| Episodic | Discrete episodes with intervals between | Vaccination programmes, periodic screening |
| Continuous | Ongoing management without clear episodes | Long-term condition management, mental health |
| Compound | Multiple interacting pathways for one patient | GAHT (endocrine + mental health + surgical) |

### 5.2 Decision structure

What kinds of reasoning drive the pathway?

| Value | Description | Example |
|---|---|---|
| Algorithmic | Protocol-driven, guideline-following | Ears triage (red flag screening) |
| Heuristic | Clinical judgement with soft rules | Ears procedure selection |
| Probabilistic | Risk-based, Bayesian updating | Diagnostic reasoning, prognostic assessment |
| Mixed | Combination of the above | Most real clinical services |

### 5.3 Temporal profile

What is the time shape of the service?

| Value | Description | Example |
|---|---|---|
| Acute | Single encounter or very short course | Ears, minor injury |
| Short-course | Days to weeks | Post-operative follow-up, short therapy course |
| Chronic | Ongoing management, months to years | GAHT, diabetes, mental health |
| Preventive | Periodic, scheduled | Screening programmes, health checks |
| Episodic-recurrent | Recurring acute episodes | Recurrent ear wax, migraine management |

### 5.4 Risk profile

What can go wrong and how seriously?

| Value | Description | Example |
|---|---|---|
| Procedural | Injury from the procedure itself | Ears (perforation, infection, vertigo) |
| Diagnostic | Missed or incorrect diagnosis | Failing to identify cholesteatoma behind wax |
| Prescribing | Medication errors or interactions | GAHT hormone prescribing |
| Safeguarding | Vulnerability, consent, capacity | Care home patients, patients with dementia |
| Systemic | Failure in the system, not the individual | Booking system loses referral, equipment failure |

### 5.5 Governance density

How thick is the governance layer?

| Value | Description | Example |
|---|---|---|
| Generally governed | Basic business regulation only | Cafe, Paws |
| Lightly regulated | Sector-specific but light-touch | Simple retail pharmacy |
| Moderately regulated | CQC registration, professional regulation | Ears |
| Heavily regulated | Multiple overlapping regimes, audit-intensive | GAHT, hospital services |

### 5.6 Stakeholder complexity

How many actors and relationships?

| Value | Description | Example |
|---|---|---|
| Solo practitioner | Single provider, direct patient relationship | Simple private practice |
| Small team | Small clinical team, single site | Ears clinic |
| Multi-disciplinary | Multiple clinical professions collaborating | Community mental health |
| Multi-agency | Multiple organisations involved | GAHT (GP + gender service + endocrine + surgical + mental health) |

### 5.7 Information intensity

How much clinical information flows?

| Value | Description | Example |
|---|---|---|
| Minimal records | Brief clinical notes per encounter | Ears (single procedure note) |
| Structured records | Template-driven clinical records | Primary care consultations |
| Complex longitudinal | Long-term records across multiple encounters | GAHT, chronic disease |
| Shared across organisations | Records flowing between providers | Multi-agency pathways |

### 5.8 Financial structure

How does money work?

| Value | Description | Example |
|---|---|---|
| Simple private pay | Patient pays per episode | Ears (self-pay) |
| Insurance-based | Third-party payer | Private medical insurance |
| Commissioned | NHS/ICB contract (block, blended, activity-based) | Ears (potential ICB tender) |
| Mixed economy | Multiple funding sources for the same service | Ears (self-pay + commissioned) |

### 5.9 Ears characterisation

Applying the taxonomy to the Ears domain:

| Dimension | Value | Notes |
|---|---|---|
| Pathway topology | Branching | Predominantly linear but with decision points (procedure selection, referral) |
| Decision structure | Mixed (algorithmic + heuristic) | Red flag screening is algorithmic; procedure choice is heuristic |
| Temporal profile | Acute / Episodic-recurrent | Single encounter per episode, but patients return with recurrent wax |
| Risk profile | Procedural + Diagnostic + Safeguarding | Perforation risk, missed pathology, care home vulnerable adults |
| Governance density | Moderately regulated | CQC + NMC + NICE + GDPR Article 9 |
| Stakeholder complexity | Small team | Nurse specialists + admin + medical advisory + GP/ENT referral |
| Information intensity | Minimal records | Brief procedure note, otoscopy images, consent |
| Financial structure | Mixed economy | Self-pay primary, with potential ICB commissioning |

---

## 6. The Proforma Intake Schema

The proforma structures the systematic capture of a specific domain's features. It is designed as a reusable template — the same schema applies to any clinical service, with domain-specific content filling the fields. Each section maps to specific meta model elements and identifies which platform vocabulary is being exercised.

### 6.1 Domain identity and context

**Purpose:** Establish what this service is and where it sits in the platform's domain registry.

| Field | Type | Maps to | Notes |
|---|---|---|---|
| Domain name | String | DomainIdentity.name | The human-readable name |
| Domain character | String | DomainIdentity.character | Brief description of the service type |
| Regulatory tier | Enum (4 values) | DomainConfiguration.regulatoryTier | Generally governed / Lightly regulated / Moderately regulated / Sector-regulated |
| Jurisdiction | Enum | DomainConfiguration.jurisdiction | England / Scotland / Wales / etc. |
| Feature taxonomy position | Structured (§5) | *(new — not yet in meta model)* | The domain's characterisation across all feature dimensions |
| Domain narrative | Free text | *(contextual — not directly modelled)* | Background, history, motivation for the service. The "colour" that makes the domain relatable |

### 6.2 Service concept

**Purpose:** What value is delivered, to whom, and why.

| Field | Type | Maps to |
|---|---|---|
| Value proposition | Structured text | ValueProposition |
| Clinical scope | Structured text | *(clinical extension of ServiceOffering)* |
| Indications | List | *(OGMS: symptoms/conditions warranting the service)* |
| Exclusions and red flags | List | *(reasoning metamodel: HardConstraints)* |
| Service settings | List | *(facility types, including domiciliary)* |
| Target patient population | Structured text | CustomerSegment |
| Service offerings | List of offerings | ServiceOffering (one per distinct service) |
| Differentiation claims | List | DifferentiationClaim |

### 6.3 Clinical pathway

**Purpose:** The procedural structure from presentation to discharge.

| Field | Type | Maps to |
|---|---|---|
| Patient journey stages | Ordered list of stages | ActivityType (per stage) |
| Per stage: clinical activities | Structured | ActivityType (per activity within stage) |
| Per stage: decision points | Structured | ReasoningActivity, with triggering conditions |
| Per stage: clinical assessments | Structured | OGMS assessment, producing Claims |
| Per stage: inputs and outputs | Structured | Information/artefacts consumed and produced |
| Referral and escalation criteria | Structured | HardConstraint (when to refer out) |
| Domiciliary pathway variant | Structured | Variant pathway for home visits |

### 6.4 Clinical reasoning and decision points

**Purpose:** What decisions are made, on what basis, with what constraints.

| Field | Type | Maps to |
|---|---|---|
| Pre-appointment triage decisions | Structured | ReasoningActivity + HardConstraint (red flags) |
| Assessment-to-procedure decisions | Structured | ReasoningActivity + Claim + EvidenceLine |
| Contraindication logic | Structured | HardConstraint (absolute) or GradedRule (relative) |
| Procedure selection criteria | Structured | Decision with declared InterpretiveFrame |
| Post-procedure decisions | Structured | ReasoningActivity (follow-up, referral) |
| Heuristic knowledge | Free text | HeuristicPack (typed by family) |

### 6.5 Governance landscape

**Purpose:** What regulatory and governance obligations apply.

| Field | Type | Maps to |
|---|---|---|
| Service regulation | Structured | Obligation (CQC regulated activities) |
| Professional regulation | Structured per role | Obligation (NMC/GMC/HCPC requirements) |
| Clinical guideline compliance | Structured | GradedRule or HardConstraint per guideline |
| Employment and training governance | Structured | Obligation (mandatory training, competency) |
| Information governance | Structured | Obligation (GDPR, Caldicott, DPIA) |
| Governance-reasoning alignment | Annotation | Which obligations are HardConstraints in the reasoning vocabulary |

### 6.6 Clinical risk and safety

**Purpose:** What can go wrong, how serious is it, how is it mitigated.

| Field | Type | Maps to |
|---|---|---|
| Clinical risks | List with severity | SafetyConstraint per risk |
| Control structures | Structured | ControlStructure, ControlLoop |
| Control actions | Structured per procedure | ControlAction (procedure steps) |
| Unsafe control actions | Structured | UnsafeControlAction (4 STPA types) |
| Mitigation measures | Structured per risk | ControlLoop feedback, SafetyConstraint |
| Variability profile | Free text | FRAMFunction, VariabilityProfile |
| Emergency protocols | Structured | HardConstraint (emergency response) |

### 6.7 Workforce and resources

**Purpose:** Who delivers, what equipment, what competencies.

| Field | Type | Maps to |
|---|---|---|
| Clinical roles | List with competency requirements | Role, ResourceType (personnel) |
| Non-clinical roles | List | Role, ResourceType (personnel) |
| Medical oversight | Structured | StakeholderRelationship or Role |
| Competency framework | Structured per role | Obligation (training, sign-off, revalidation) |
| Premises and facilities | Structured | Facility, Room |
| Clinical equipment | List with maintenance requirements | Equipment (ResourceType) |
| Consumables and supplies | List | Consumable (ResourceType) |
| Portable/domiciliary kit | List | Equipment subset for domiciliary |

### 6.8 Financial model

**Purpose:** How is it funded, what are the unit economics.

| Field | Type | Maps to |
|---|---|---|
| Revenue streams | List | RevenueStream |
| Pricing structure | Structured | PricingModel, PricingRule |
| Cost structure (fixed) | Structured by category | CostDriver (fixed) |
| Cost structure (variable) | Structured by category | CostDriver (variable) |
| Commissioning arrangements | Structured | CooperativeArrangement (ICB contracts) |
| Financial controls | List | *(operational — SMM territory)* |

### 6.9 Stakeholder relationships

**Purpose:** Who does the service interact with, how, and why.

| Field | Type | Maps to |
|---|---|---|
| Referral pathways (inbound) | Structured | ReferralPathway |
| Referral pathways (outbound) | Structured | ReferralPathway |
| Partnership arrangements | Structured | CooperativeArrangement |
| External dependencies | List | ExternalDependency |
| Patient participation model | Structured | ParticipationModel |
| Community relationships | Structured | CommunityRelationship |
| Regulatory relationships | Structured | StakeholderRelationship (dual-classified with GovernanceMapping) |

### 6.10 Service experience and context

**Purpose:** The softer dimension — patient journey experience, environmental factors, the "feel" of the service. Demonstrates that the platform can absorb rich contextual information without it clogging the structured model.

| Field | Type | Maps to |
|---|---|---|
| Patient personas | Narrative per persona | *(contextual — simulation input)* |
| Typical patient journey narrative | Free text | *(contextual — drives scenario design)* |
| Staff personas and personal details | Narrative per person | *(contextual — simulation texture)* |
| Environmental description | Free text | *(contextual — premises atmosphere, locality)* |
| Day-in-the-life narrative | Free text | *(contextual — operational rhythm)* |

These fields are explicitly *not* modelled as meta model elements. They are ingested as contextual data that enriches simulation, supports user engagement, and demonstrates the platform's absorptive capacity. The Paws precedent (Pol's rescue dog Ollie, the biscuit tin) established that this kind of information has value without needing to be structurally modelled.

---

## 7. The Coverage Map

The coverage map is the artefact that makes the platform's scope boundaries conscious and documented. For each proforma field, it records:

### 7.1 Coverage status

| Status | Meaning |
|---|---|
| **Full** | The platform has vocabulary that directly expresses this feature. The mapping from proforma field to meta model element is straightforward. |
| **Partial** | The platform has vocabulary that approximately expresses this feature, but with semantic friction — the fit is imperfect and may require workarounds or simplification. |
| **Gap — clear extension point** | The platform cannot currently express this feature, but the meta model has an identifiable point where vocabulary could be added without structural redesign. |
| **Gap — structural** | The platform cannot currently express this feature, and doing so would require revisiting a structural decision in the meta model design tree. |
| **Out of scope** | The feature is deliberately not modelled. This is a conscious constraint, not an oversight. |
| **Contextual** | The feature is captured as free text / narrative for simulation and engagement purposes, not as structured vocabulary. |

### 7.2 Branching-point annotation

For every gap (clear extension point or structural), the coverage map records:

- **Which dimension of constraint** is responsible (ontological scope, abstraction level, or causal formalism).
- **Where in the meta model hierarchy** the constraining choice was made — the specific part def, OWL class, or design decision that creates the boundary.
- **What extension would be needed** — a brief description of the vocabulary addition or structural change required.
- **What the architectural cost of extension would be** — trivial (add a subclass), moderate (add a new property domain), or significant (revisit a design decision).

### 7.3 Accumulation across domains

As more domains are ingested through the framework, the coverage map fills in. Features that are exercised by multiple domains gain validation. Features that remain as gaps across multiple domains become candidates for meta model extension — their absence is not domain-specific but a genuine platform limitation. Features that are gaps for one domain but full coverage for another reveal where the meta model's scope boundaries lie.

This accumulation is the mechanism by which the platform learns what it can and cannot model — not theoretically, but empirically, driven by real domain content.

---

## 8. Ears as First Clinical Intake

The Ears domain (community-based earwax removal) is the first clinical service to be processed through the intake framework. The Perplexity workup provides a substantial starting point across all ten sections of the proforma. What remains is:

### 8.1 What the Perplexity workup provides

Sections 1–10 of the workup map well onto the proforma schema. The clinical pathway (section 3) is detailed enough to drive reasoning vocabulary instantiation. The governance landscape (section 2) is rich — CQC, NMC, NICE, GDPR. The risk and safety framework (section 9) maps to STAMP/STPA structures. The financial model (section 7) includes both self-pay and commissioned revenue.

### 8.2 What needs to be added

- **Named personnel and personal details.** The Paws precedent established that every Ontara domain needs named people with human texture. The Ears service needs a lead nurse specialist, support staff, a receptionist, and perhaps a medical advisory GP — all with names, personal details, and quirks that give the simulation personality.
- **Specific instantiation.** The Perplexity workup describes the generic shape of an ear care service. The Ontara intake needs a *specific* fictional business — a named service, at a specific location, with specific premises, specific equipment brands, specific pricing, a specific GP practice relationship. The generic description becomes the template; the specific instantiation becomes the domain model.
- **Vertical connection mapping.** Following the Paws precedent, every element of the domain description needs to be mapped through the vocabulary stack: ontology (BFO/OGMS) → BMM General / reasoning / governance vocabulary → business instance → generated systems. This is where coverage gaps become visible.
- **Reasoning instance content.** The triage decision, contraindication screening, procedure selection, and post-procedure assessment need to be expressed as concrete reasoning vocabulary individuals: specific Claims, EvidenceLines, ReasoningActivities, HardConstraints, GradedRules. This is the primary validation target — does the reasoning vocabulary actually fit?

### 8.3 Proposed intake sequence

1. **Session N:** Enrich the Ears domain description with named personnel, specific business details, and narrative context. Place in the vault under `05 Ontara Demonstrators/Ears (Community Ear Care)/`.
2. **Session N+1:** Produce the Ears vertical connection map, systematically mapping every domain element through the vocabulary stack. Identify coverage gaps as they emerge.
3. **Session N+2:** Produce the Ears coverage map — the formal record of what the platform can express and where the gaps are. Populate the first reasoning instances (triage decision, contraindication screening).
4. **Session N+3:** Complete reasoning instance population (procedure selection, post-procedure assessment). Produce the Ears design note with cross-domain observations and BMM/reasoning adequacy assessment.

This sequence may compress or expand based on what emerges — but the ordering (description → mapping → gap analysis → instance population → design note) follows the Paws precedent.

---

## 9. Tooling Roadmap

The intake framework is initially a methodology executed by hand — structured documents, systematic analysis, manual mapping. Over time, tooling should automate the repetitive parts and make the analytical parts queryable. The roadmap follows the principle of building tooling from concrete experience, not theoretical design.

### 9.1 Phase 0: Manual execution (current)

Execute the Ears intake entirely by hand using the proforma schema and coverage map as document templates. Learn what is tedious, what is error-prone, what needs to be queryable.

### 9.2 Phase 1: Schema-driven proforma

Build a structured authoring tool — likely a console feature — that walks through the proforma schema section by section. The tool knows what fields exist, what types they take, which are required vs optional, and how they map to meta model elements. Partially completed proformas are saved and revisable. This replaces the manual markdown document with a guided form.

### 9.3 Phase 2: Gap analyser

Given a completed or partially completed proforma, compare the specified features against the platform's current vocabulary and report coverage status for each field. This requires a machine-readable representation of the coverage map — likely OWL individuals recording which vocabulary elements exist and what domain features they express.

### 9.4 Phase 3: Projection engine

Take a completed proforma and generate OWL individuals, SysML part usages, and configuration artefacts. This extends the existing generation pipeline — `gen_owl_pipeline.py` already projects SysML into OWL. The projection engine adds a path from the structured proforma into both formalisms.

### 9.5 Phase 4: Simulation bootstrapper

Take the generated model artefacts and produce a runnable simulation scenario — Temporal workflow definitions, initial state, test data. This is the step that gets from proforma to running system.

The key principle is: **do it by hand first, then automate what you learned.** Phase 0 with Ears will reveal what Phases 1–4 need to do.

---

## 10. Relationship to the Dual-Stack Architecture

Looking at the dual-stack architecture, the intake framework touches multiple layers:

**Above the formalism boundary (OWL 2 DL):**
- Domain ontology individuals (OGMS-typed clinical entities)
- Reasoning vocabulary individuals (Claims, EvidenceLines, ReasoningActivities)
- Governance vocabulary individuals (Obligations, compliance evidence)
- Domain identity individuals (DomainIdentity + DomainConfiguration)

**At the formalism boundary:**
- Correspondence graph mapping records linking SysML elements to OWL individuals

**Below the formalism boundary (SysML v2):**
- BMM business instance part usages (ServiceOfferings, ResourceTypes, etc.)
- SMM elements where applicable (generated system structures)

**In the rules and constraints container:**
- Clinical constraints (contraindications, guidelines, governance obligations)
- Safety constraints (STAMP/STPA structures)

**In the reflective simulation:**
- The softer contextual information (personas, narratives, environmental description) feeds the reflective simulation's ability to make the system relatable and understandable

The intake framework is thus a cross-cutting methodology — it produces artefacts that live in multiple layers of the dual-stack. The proforma schema defines what information is captured; the projection (manual initially, automated later) determines where each piece of information lands in the architecture.

---

## 11. Design Decisions

### S160-D1: The intake framework is a platform capability, not a one-off methodology

The framework is designed for repeated use across multiple domains. Its artefacts (feature taxonomy, proforma schema, coverage map) are platform-level resources that evolve as the meta model evolves.

### S160-D2: Manual execution first, then tool-driven

The Ears intake will be executed entirely by hand. Tooling will be designed from the concrete experience of manual execution, not from theoretical requirements.

### S160-D3: The coverage map records branching points explicitly

Every gap in the coverage map is annotated with which dimension of constraint is responsible and where in the meta model the extension point lies. This makes the platform's scope boundaries conscious and navigable.

### S160-D4: Contextual information is deliberately not modelled as vocabulary

Softer information (personas, narratives, environmental texture) is captured in the proforma but is not projected into OWL or SysML. It is simulation and engagement input, not structural vocabulary. The Paws precedent established this principle.

### S160-D5: The feature taxonomy applies to domains, not just clinical services

Although this paper focuses on clinical domains, the feature taxonomy concept generalises to any service domain. Clinical-specific dimensions (OGMS primitives, clinical risk types) extend a core taxonomy that would also characterise non-clinical services. The Paws and Suds characterisations would use the same dimensional structure with different values.

---

## 12. Open Questions

### S160-Q1: Where does the feature taxonomy live in the model?

The feature taxonomy characterises domains along typed dimensions. Should this be expressed in SysML (part defs for dimensions, enumerated value spaces), in OWL (as extensions to the domain identity vocabulary), or in both? The SysML representation preserves A3; the OWL representation enables SPARQL querying of domain characteristics. Both have merit.

### S160-Q2: How does the coverage map relate to the architecture map?

The architecture map (console view, Session 92) shows the platform's structural sections with implementation status. The coverage map shows the platform's representational reach against domain content. Are these two views of the same underlying concept, or genuinely separate artefacts?

### S160-Q3: What is the right granularity for coverage assessment?

Coverage can be assessed at the level of proforma sections (coarse — "governance is partially covered"), individual fields (medium — "CQC registration obligations are fully covered"), or individual domain entities (fine — "this specific contraindication maps to HardConstraint"). Finer granularity is more useful but more expensive. The Ears intake will test what granularity is practical.

### S160-Q4: How should the proforma handle domain features that span multiple BMM concerns?

Some domain features — for example, a clinical competency requirement — touch ResourcePlanning (who has the competency), GovernanceMapping (what requires the competency), and StakeholderModel (professional body relationship). The proforma schema assigns features to sections, but cross-cutting features need explicit treatment. The Paws vertical connection map handled this implicitly; the clinical intake may need to be more systematic.

### S160-Q5: Commissioning as a stakeholder or financial concern?

The Ears workup describes ICB commissioning as both a financial structure (block/blended/activity-based tariffs) and a stakeholder relationship (contractual arrangement with a commissioning body). The BMM has CooperativeArrangement in StakeholderModel and RevenueStream in FinancialPlanning. Is the current vocabulary sufficient, or does commissioning need specific treatment?

---

## 13. Register Connections

| Concept | Relationship |
|---|---|
| [[principle-self-describing-system\|A2]] (self-describing system) | The coverage map extends self-description to "the system knows what it can model" |
| [[concept-cross-domain-validation\|A5]] (validate in toy domains first) | [[domain-ears\|Ears]] is the clinical "toy domain" — validates clinical patterns at lower complexity before [[domain-gsl\|GSL]] |
| [[principle-discipline-as-load-bearing-structure\|A9]] (discipline as load-bearing structure) | The intake methodology is a disciplined, repeatable process — not ad hoc domain exploration |
| [[principle-intrinsic-self-knowledge\|A10]] (intrinsic self-knowledge) | The coverage map is intrinsic self-knowledge about representational reach |
| [[concept-coordinate-framework\|A12]] (coordinate framework) | The feature taxonomy is A12 applied to domains — domains as points in feature space |
| [[concept-multi-tenancy\|A13]] (multi-tenancy) | Every domain is a tenant instantiation; the intake framework is how tenants enter the platform |
| [[concept-co-evolution\|J2]] (co-evolution) | The intake drives both model validation (vocabulary fitness) and tooling requirements (console features) |
| [[concept-non-constraining\|J3]] (non-constraining) | The branching-point annotation preserves extensibility by making constraints explicit |
| [[concept-domain-identity\|B15]] (domain identity) | The domain identity section of the proforma maps directly to DomainIdentity/DomainConfiguration |
| [[concept-authority-zones\|B29]] (authority zones) | The coverage map must respect authority zones — OWL-authoritative for ontological semantics, SysML-authoritative for structure |

---

*Clinical Domain Intake Framework — Ontara Session 160 Discussion Paper. Designed to establish a repeatable methodology for domain characterisation, ingestion, and platform fitness validation, building on the Paws precedent (Sessions 43–44) and grounded in the Ears demonstrator as first clinical exercise.*
