---
tags:
  - architecture
  - discussion
  - governance
date: 2026-04-03
status: working
session: 121
---
# Deontic Governance Architecture: An Obligation Vocabulary and Compliance Framework for the Ontara Platform

*Ontara Platform — Discussion Paper*

**Date:** 3 April 2026 (Session 121)
**Purpose:** Foundational design for the Clinical and Operational Governance workstream — a deontic logic-grounded obligation vocabulary, a three-tier compliance architecture (library, activation, operations), and integration with the existing Ontara dual-stack architecture including simulation, projection, audit, and the coordinate framework.
**Status:** Working document — detailed design. First paper in the governance workstream.
**Depends on:** [[ontara-discussion-dual-stack-architecture-2026-03-26|Dual-Stack Architecture (Sessions 73–74)]], [[ontara-discussion-knowledge-graph-architecture-2026-04-01|Knowledge Graph Architecture (Session 97)]]

---

## Contents

- [[#1. Motivation and Architectural Context|§1. Motivation and Architectural Context]]
- [[#2. The Problem: Governance as Operational Infrastructure|§2. The Problem: Governance as Operational Infrastructure]]
- [[#3. Deontic Logic Foundations|§3. Deontic Logic Foundations]]
- [[#4. BFO and IAO Grounding|§4. BFO and IAO Grounding]]
- [[#5. The Obligation Vocabulary|§5. The Obligation Vocabulary]]
- [[#6. Normative Instruments and Source Authority|§6. Normative Instruments and Source Authority]]
- [[#7. The Governance Framework Library|§7. The Governance Framework Library]]
- [[#8. Framework Activation and Obligation Binding|§8. Framework Activation and Obligation Binding]]
- [[#9. Operational Compliance|§9. Operational Compliance]]
- [[#10. Governance in the Coordinate Space|§10. Governance in the Coordinate Space]]
- [[#11. Governance-Aware Simulation|§11. Governance-Aware Simulation]]
- [[#12. Temporal Governance State and Audit|§12. Temporal Governance State and Audit]]
- [[#13. The Ingestion Pipeline|§13. The Ingestion Pipeline]]
- [[#14. Integration with the Existing Architecture|§14. Integration with the Existing Architecture]]
- [[#15. The CQC Archetype|§15. The CQC Archetype]]
- [[#16. Design Decisions and Open Questions|§16. Design Decisions and Open Questions]]
- [[#17. Register Connections|§17. Register Connections]]

---

## 1. Motivation and Architectural Context

One of the founding purposes of the Ontara platform is to enable service operators — particularly in regulated care delivery — to establish, operate, and demonstrate governance of their services with a degree of rigour, confidence, and insight that is not achievable through conventional means.

The conventional situation is this: a service operator setting up a new healthcare service faces a landscape of regulatory, legal, professional, and contractual obligations. CQC registration requirements, GDPR data protection obligations, employment law duties, health and safety regulations, professional body standards (GMC, NMC), NHS commissioning frameworks, clinical safety standards (DCB0129/DCB0160), information governance requirements (NHS DSPT) — each with its own documentation, its own compliance evidence requirements, its own inspection regime, and its own update cycle. These obligations are expressed as semi-structured prose in dozens of documents. The mapping from "what the regulation says" to "what our specific service must do" is performed manually, maintained in spreadsheets and policy documents, and verified through periodic inspections that are labour-intensive for both the provider and the regulator.

The result is a governance posture that is:
- **Fragile.** Compliance evidence is scattered, manually assembled, and goes stale silently.
- **Opaque.** The connection between a specific regulatory clause and the specific service element that satisfies it is implicit, undocumented, or documented only in the heads of key staff.
- **Reactive.** Compliance problems are discovered at inspection, not detected in real time.
- **Static.** The compliance posture is assessed periodically (CQC inspections may be years apart), not continuously monitored.
- **Non-generative.** The governance knowledge embedded in compliance work does not inform service design, operational decisions, or strategic planning. It sits in a silo.

Ontara's thesis is that all of this is solvable. The platform can ingest governance requirements in their original form, decompose them into a formally represented obligation set, bind those obligations to the specific service model, monitor compliance in real time, project the governance consequences of proposed changes, simulate governance scenarios, and produce structured audit evidence on demand.

This is not an add-on feature. It is one of the primary reasons the platform's architecture has been designed as it has. The self-describing system ([[principle-self-describing-system|A2]]), the governance traceability chain ([[principle-clinical-governance-first-class|A8]]), the knowledge graph as canonical store ([[concept-knowledge-graph|B22]]) with OWL reasoning ([[concept-bfo-ontological-grounding|B23]]), the coordinate framework with projections ([[concept-coordinate-space-snapshots|L8]], [[concept-goal-seeking-computation|L9]]), the reflective simulation ([[concept-reflective-simulation|L6]]) with valence ([[concept-valence|L7]]) — these are not abstract capabilities. They are the infrastructure for a governance engine.

This paper designs the missing piece: the **obligation vocabulary** — the representational primitives that make governance requirements machine-readable, semantically rich, and computationally active.

## 2. The Problem: Governance as Operational Infrastructure

The key insight is that governance requirements should not be treated as a separate concern bolted onto a service model. They should be **integrated into the model as first-class participants in the system's reasoning**.

This means:

1. **Obligations are entities in the knowledge graph.** They have identity, properties, relationships, temporal history, and participate in reasoning — just like service offerings, activity types, and resource types.

2. **Compliance state is a dimension of business state.** The system's understanding of "how is the business doing?" includes governance health alongside operational, financial, and clinical metrics.

3. **Governance constraints shape the feasible space.** When the system reasons about what the business can do (simulation, goal-seeking, design guidance), governance obligations define the boundaries of the permissible — not as external checks applied after the fact, but as constraints built into the reasoning itself.

4. **Governance has temporal depth.** Compliance is not a snapshot — it is a trajectory. The system tracks not just "are we compliant now?" but "have we been compliant?", "are we becoming more or less compliant?", "when did compliance status change and why?", and "what is our projected compliance posture if nothing changes?"

5. **Governance frameworks are shared, maintained infrastructure.** Pre-formalised regulatory frameworks are available at platform level, maintained by governance experts, versioned with explicit currency claims, and activatable by any tenant whose service falls within their scope. A service operator starting a new healthcare service does not build their compliance material from scratch — they activate the relevant frameworks and the system binds obligations to their service model.

## 3. Deontic Logic Foundations

Deontic logic is the formal study of normative concepts — obligation, permission, and prohibition. The classical system, Standard Deontic Logic (SDL, von Wright 1951), introduces three modal operators:

- **O(φ)** — it is obligatory that φ (φ must be the case)
- **P(φ)** — it is permitted that φ (φ may be the case)
- **F(φ)** — it is forbidden that φ (φ must not be the case)

These are interdefinable: F(φ) ≡ O(¬φ) and P(φ) ≡ ¬O(¬φ). Permission is the dual of obligation; prohibition is obligation-of-the-negation.

SDL is propositional and operates in a possible-worlds semantics: an obligation holds when all "ideal" or "permissible" alternatives to the current world satisfy the obligated proposition. This is elegant but insufficient for practical regulatory modelling, which requires:

- **Conditional norms.** Most regulatory obligations are conditional: "if you provide regulated activity X, then you must...". The condition is not a logical precondition — it is a scope delimiter that determines whether the obligation is *active* for a given service.
- **Defeasibility.** Regulatory norms can conflict, and some override others. Employment law provides minimum standards; a contractual obligation may impose higher standards. A general prohibition may have statutory exceptions. The system must handle norm priority and exception without collapsing into inconsistency.
- **Temporal qualification.** Obligations have effective dates, expiry conditions, periodic assessment cycles, and deadline structures. "You must complete a fire risk assessment annually" is a temporally qualified obligation.
- **First-order quantification.** Real obligations range over individuals and classes: "every member of staff must have a DBS check" quantifies over the class of staff members. Propositional SDL cannot express this.
- **Evidence and compliance.** Classical deontic logic has no native concept of evidence or compliance state — it models what *ought* to be, not how one *demonstrates* that it is.

For Ontara's purposes, we do not implement a full deontic logic reasoner. Instead, we adopt the **deontic vocabulary** — the conceptual primitives of obligation, permission, prohibition, and their structural properties — and represent them as OWL classes in the knowledge graph, where OWL 2 DL reasoning handles classification, consistency checking, and constraint evaluation. This follows the approach advocated by Francesconi and Governatori (2022) and validated in the construction-domain compliance checking work (Arxiv 2504.05951): deontic modalities are represented as ontological classes, and compliance checking is performed by OWL reasoners rather than dedicated deontic logic engines.

The advantage: we stay within OWL 2 DL (our binding commitment, [[concept-bfo-ontological-grounding|B23]]), we use our existing reasoner infrastructure (Robot + HermiT), and we avoid the decidability problems that arise with full modal deontic logic in OWL.

## 4. BFO and IAO Grounding

Where do deontic entities sit in BFO? This question has been directly addressed by Donohue (2017), "Toward a BFO-Based Deontic Ontology," from Barry Smith's group at the National Center for Ontological Research (NCOR). Donohue evaluates four candidate categorisations:

1. **Relational quality** — rejected. An obligation between parties A and B is not a single quality inhering in both; it is two distinct entities (obligation in one, claim in the other) even if mutually dependent.

2. **Role** — rejected. A BFO role inheres in a bearer in virtue of an extrinsic relational property. But an obligation is not something that inheres in a person the way a role does — it is an informational entity that *directs* behaviour.

3. **Socio-legal generically dependent continuant** (from the Document Acts Ontology) — rejected as a primary categorisation. While obligations often arise through document acts (signing a contract, passing a law), the obligation itself is not best understood as a socio-legal GDC.

4. **Directive information entity** (from IAO) — **endorsed.** An obligation is a species of *directive information entity*: an information content entity whose concretizations indicate to their bearer that certain acts are to be performed or certain states of affairs are to be obtained.

This places the obligation vocabulary squarely within IAO, which is already in our [[concept-ontology-stack|ontology stack]]. The BFO path is:

```
BFO:entity
  → BFO:continuant
    → BFO:generically_dependent_continuant
      → IAO:information_content_entity
        → IAO:directive_information_entity
          → ontara:DeonticDirective
```

This grounding has several desirable properties:

- **Generic dependence.** A deontic directive is a generically dependent continuant — it can be concretized in multiple bearers. A CQC regulation applies to every registered provider; each provider bears a concretization of the same obligation. This captures the universal/particular distinction essential for the governance framework library.

- **Directiveness.** A directive information entity is not merely descriptive — it directs its bearer toward or away from states of affairs. This is precisely the nature of regulatory obligations: they tell you what you must, may, or must not do.

- **IAO compatibility.** IAO already provides information content entity, document, data item, and other classes that the obligation vocabulary needs to reference (e.g., evidence records are IAO information content entities).

- **Existing stack alignment.** BFO → CCO → IAO is already loaded in our knowledge graph. The deontic vocabulary extends IAO rather than introducing a new mid-level ontology.

## 5. The Obligation Vocabulary

### 5.1 Deontic directives

The core vocabulary defines four species of deontic directive:

**`DeonticDirective`** — subclass of `IAO:directive_information_entity`. The root class for all formally represented normative requirements. Every deontic directive has: a deontic modality, a content (what is required/permitted/prohibited), a subject (who bears the directive), an applicability scope, and provenance to a normative instrument.

- **`Obligation`** — a deontic directive requiring a state of affairs to obtain or an action to be performed by the bearer. "The registered person shall ensure that persons employed for the purposes of carrying on the regulated activity are fit to do so."

- **`Permission`** — a deontic directive allowing a state of affairs to obtain or an action to be performed. "The service may provide treatment to patients under the age of 18 with appropriate safeguards." Permissions are not merely the absence of prohibition — they are positive authorisations that may carry their own conditions and evidential requirements.

- **`Prohibition`** — a deontic directive requiring a state of affairs not to obtain or an action not to be performed. "No person shall carry on a regulated activity unless registered with the Commission."

- **`RegulatoryPower`** — a deontic directive conferring capacity to create, modify, or extinguish deontic relations. "The Commission may at any time vary or remove any condition of registration." Powers are second-order: they operate on the obligation landscape itself, not directly on service operations.

### 5.2 Structural properties of deontic directives

Every deontic directive carries the following structural properties, forming the **anatomy of a norm**:

**Subject (bearer).** The entity or class of entities that bears the directive. In regulatory contexts, this is typically a provider, registered manager, nominated individual, or class of staff. In Ontara terms, the subject maps to an element of the service model — a role in ResourcePlanning, an organisational entity, or the service itself.

**Content (object).** The state of affairs or action that the directive governs. "Persons employed are fit" is the content of a fitness-for-purpose obligation. Content can be:
- **State-oriented:** a condition that must (or must not) obtain — "premises are suitable"
- **Action-oriented:** an action that must (or must not) be performed — "conduct a risk assessment"
- **Achievement-oriented:** an outcome that must be reached — "ensure effective governance"

**Applicability conditions.** The circumstances under which the directive is active. Most regulatory obligations are conditional: "if your service provides treatment..." The applicability scope determines which obligations from a governance framework bind to a specific service model during framework activation (§8). Applicability conditions can reference:
- Regulated activities (CQC-specific)
- Service types and characteristics
- Organisational form (individual, partnership, organisation)
- Jurisdictional scope
- Temporal conditions (effective date ranges)
- Other obligations (an obligation may be conditional on another obligation being active)

**Exception conditions (defeasibility).** Circumstances under which the directive is overridden, suspended, or modified. Exceptions are explicit and traceable — they are not implicit logical negations but authored relationships between norms. An exception references the overriding norm and the conditions under which the override applies. This handles regulatory defeasibility within the monotonic constraints of OWL 2 DL: exceptions are modelled as explicit class restrictions rather than non-monotonic inference rules.

**Temporal scope.** When and how the directive applies over time:
- **Continuous:** must be satisfied at all times (e.g., "premises must be safe")
- **Periodic:** must be satisfied at regular intervals (e.g., "annual fire risk assessment")
- **Triggered:** activated by an event (e.g., "notify CQC within 28 days of a change")
- **Deadline-bounded:** must be satisfied by a specific date
- **Transitional:** applies during a defined transition period

**Evidential specification.** What constitutes evidence of compliance. This is critical for the operational layer — an obligation without a clear evidential specification is unverifiable. Evidence types include:
- Documents (policies, procedures, risk assessments, training records)
- Records (audit logs, incident reports, clinical records, staff records)
- Processes (complaints procedure, governance meetings, supervision cycles)
- Qualifications (DBS checks, professional registrations, training certificates)
- Inspections (premises checks, equipment maintenance, external audits)
- Declarations (statement of purpose, self-assessments)

Each evidential specification carries a freshness requirement (how recently the evidence must have been produced or reviewed) and a sufficiency standard (what level of evidence is adequate).

**Regulatory source (provenance).** The normative instrument from which the directive derives (§6). Every directive traces to a specific clause, section, or regulation in one or more source instruments.

**Sanction profile.** The consequences of non-compliance. This is not a full legal analysis but a structured indicator: severity classification (administrative, enforcement, criminal), enforcement mechanism (inspection, complaint, prosecution), and potential outcomes (warning, condition, suspension, cancellation, prosecution). The sanction profile informs risk assessment and prioritisation.

### 5.3 Obligation composition

Regulatory obligations frequently have composite structure:

**Obligation groups.** A high-level organising category that collects related obligations. CQC's five key questions (safe, effective, caring, responsive, well-led) are obligation groups. An obligation group has a compliance state derived from its constituent obligations.

**Composite obligations.** An obligation that decomposes into sub-obligations, all of which must be satisfied for the composite to be satisfied. "The service must be well-led" decomposes into specific obligations about governance structures, leadership competence, improvement culture, and regulatory engagement.

**Alternative obligations.** An obligation that can be satisfied by any one of several alternative means. "The provider must demonstrate financial viability through [accountant's statement OR bank reference OR FCA-regulated firm's assessment]."

**Cascading obligations.** An obligation whose activation triggers further obligations. "If you register for the regulated activity 'treatment', you must also [have a registered manager] AND [maintain a statement of purpose] AND [notify CQC of specified events]."

## 6. Normative Instruments and Source Authority

The obligation vocabulary must be regime-agnostic — it must work for any governance framework, not just CQC. This requires a rich taxonomy of **normative instruments**: the source documents from which deontic directives are derived.

### 6.1 Instrument types

| Type | Character | Examples |
|---|---|---|
| **Primary legislation** | Statute enacted by Parliament; highest domestic authority | Health and Social Care Act 2008, Data Protection Act 2018, Equality Act 2010, Health and Safety at Work etc. Act 1974 |
| **Secondary legislation** | Regulations made under statutory powers | HSCA 2008 (Regulated Activities) Regulations 2014, GDPR (as retained EU law) |
| **Statutory guidance** | Guidance issued under statutory authority; regulators must "have regard to" | CQC scope of registration guidance, NICE guidelines |
| **Regulatory standards** | Standards set by a regulator as conditions of registration or licensing | CQC fundamental standards, GMC Good Medical Practice |
| **Professional standards** | Standards set by a professional body governing individual practitioners | NMC Code, HCPC Standards of Proficiency |
| **Codes of practice** | Non-statutory but influential guidance | Caldicott Principles, NHS Code of Confidentiality |
| **Technical standards** | Specifications for technical compliance | NHS DSPT, DCB0129/DCB0160, Cyber Essentials Plus, ISO 27001 |
| **Commissioning frameworks** | Requirements set by commissioners as conditions of service contracts | NHS Standard Contract, ICB commissioning specifications |
| **Contractual obligations** | Requirements arising from contracts | Service level agreements, partnership agreements, insurance conditions |
| **Internal standards** | Self-imposed quality or governance standards | Organisational policies, quality frameworks, clinical protocols |
| **Case law** | Judicial interpretation of statutory or common law obligations | Employment tribunal precedents, judicial review rulings |

### 6.2 Instrument properties

Every normative instrument carries:

- **Identity:** title, reference number, issuing authority
- **Instrument type:** from the taxonomy above
- **Authority type:** statutory / quasi-statutory / professional / contractual / voluntary / internal
- **Jurisdiction:** territorial scope (England, UK, EU, international) and sectoral scope (healthcare, all sectors)
- **Effective date:** when the instrument came into force
- **Currency status:** current / amended / superseded / repealed, with dates
- **Version lineage:** links to previous and subsequent versions
- **Enforcement mechanism:** how non-compliance is detected and sanctioned
- **Issuing authority:** the body responsible for the instrument, with its own properties (authority type, jurisdiction, relationship to other bodies)

### 6.3 Instrument relationships

Normative instruments relate to each other:

- **Derives from:** secondary legislation derives from primary legislation
- **Implements:** regulations implement statutory provisions
- **Interprets:** case law interprets statute; guidance interprets regulations
- **Supersedes:** a new version supersedes an old one
- **Cross-references:** instruments frequently reference each other
- **Conflicts with:** instruments may impose conflicting requirements (handled through the priority/defeasibility mechanism)

## 7. The Governance Framework Library

### 7.1 What a governance framework is

A **governance framework** is a curated, versioned, machine-readable collection of deontic directives drawn from one or more coherent normative sources, maintained at platform level and activatable by tenants.

A governance framework is not a normative instrument itself — it is Ontara's **formalisation** of one or more normative instruments. "CQC Registration for Healthcare Services (England)" is a governance framework that formalises obligations derived from the Health and Social Care Act 2008, the Regulated Activities Regulations 2014, CQC's scope of registration guidance, and the fundamental standards.

### 7.2 Framework properties

- **Identity:** name, version, unique identifier
- **Scope:** jurisdictional (England), sectoral (healthcare, social care, both), service type applicability
- **Source instruments:** the normative instruments from which the framework's directives are derived, with specific clause references
- **Formalisation provenance:** who formalised this framework, when, through what process, using what version of the source instruments
- **Endorsement status:** whether the formalisation has been reviewed or endorsed by any authoritative body. Levels: `unreviewed` (machine-generated draft), `expert-reviewed` (reviewed by a domain expert), `authority-endorsed` (endorsed by the regulatory body itself), `community-validated` (reviewed and validated by a community of practitioners)
- **Currency date:** the date up to which the framework reflects the current state of the source instruments. "Current as of 3 April 2026" means the formaliser has verified that no changes to the source instruments since that date affect the framework's content.
- **Version lineage:** links to previous versions, with structured diffs showing what changed between versions
- **Directive count:** the number of deontic directives in the framework, by modality
- **Applicability conditions:** the conditions under which the framework as a whole is relevant to a service (e.g., "applicable to any provider of regulated activities in England")

### 7.3 The library as platform infrastructure

The governance framework library is **platform-level shared infrastructure** — it is not per-tenant. This aligns with the multi-tenancy principle ([[concept-multi-tenancy|A13]]): the frameworks are platform capabilities; each tenant's activation of a framework is a tenant-level operation.

The library is maintained by governance experts (initially Ella, eventually a broader community or professional service). Maintenance includes:

- Monitoring source instruments for changes (new legislation, revised guidance, updated standards)
- Re-running the ingestion pipeline (§13) against revised source documents
- Producing structured diffs between framework versions
- Propagating update notifications to all tenants with active activations
- Reviewing and updating endorsement status

### 7.4 Framework composition

A tenant's governance posture is typically composed of multiple activated frameworks. A UK private healthcare service might activate:

- CQC Registration (healthcare)
- GDPR Data Protection
- Health and Safety at Work
- Employment Law (England)
- NHS DSPT (information governance)
- DCB0129/DCB0160 (clinical safety)
- GMC Good Medical Practice (if employing doctors)
- Controlled Drugs (if applicable)

These frameworks may overlap (multiple frameworks imposing obligations on the same topic) or interact (one framework's obligations creating applicability conditions for another). The system must handle both overlap (detecting redundancy and identifying the most stringent applicable obligation) and interaction (tracing cross-framework dependency chains).

## 8. Framework Activation and Obligation Binding

### 8.1 The activation process

When a tenant activates a governance framework, the system performs the following:

1. **Applicability assessment.** Each deontic directive in the framework is evaluated against the tenant's service model. The directive's applicability conditions are compared with the service model's properties (regulated activities, service types, organisational form, staff composition, premises). The result is a classification of each directive as: `applicable`, `not applicable`, `conditionally applicable` (depends on a condition not yet determinable), or `indeterminate` (requires human resolution).

2. **Obligation binding.** Each applicable directive is bound to the specific element(s) of the service model it governs. "You must have a registered manager" binds to a role in ResourcePlanning. "You must maintain a complaints procedure" binds to a process in ActivityModel. "Premises must be suitable" binds to a location in ResourcePlanning. The binding creates a `BoundObligation` — an instance-level entity connecting the directive to the service model element.

3. **Gap identification.** The system identifies service model elements that are required by bound obligations but do not yet exist. "You must have a registered manager" when no such role is defined is a structural gap, not just a compliance gap.

4. **Cross-framework reconciliation.** When multiple activated frameworks impose obligations on the same topic, the system identifies overlaps, flags conflicts, and where possible determines the most stringent applicable standard. Reconciliation results are presented to the operator for confirmation.

5. **Operator review.** The complete set of bound obligations, gap analyses, and reconciliation results is presented to the operator for review and confirmation. Indeterminate applicability assessments are resolved through operator input. The activation is not finalised until the operator confirms.

### 8.2 Binding properties

A `BoundObligation` carries:

- **Directive reference:** link to the deontic directive in the governance framework
- **Service model target:** the specific element(s) of the tenant's service model to which the obligation is bound
- **Applicability reasoning:** a structured record of why this directive was assessed as applicable — which conditions were evaluated, which service model properties were matched
- **Activation date:** when this binding was created
- **Binding status:** `active`, `suspended` (temporarily not enforced), `withdrawn` (no longer applicable due to service model change), `superseded` (replaced by a revised directive from a framework update)
- **Compliance state:** the current compliance state of this specific binding (§9)

## 9. Operational Compliance

### 9.1 Compliance states

Each bound obligation has a compliance state drawn from a defined vocabulary:

| State | Meaning |
|---|---|
| `compliant` | The obligation is currently satisfied; evidence is adequate and current |
| `non-compliant` | The obligation is not currently satisfied; a gap or breach exists |
| `partially-compliant` | Some but not all aspects of the obligation are satisfied |
| `evidence-stale` | The obligation was previously compliant but evidence has exceeded its freshness threshold |
| `not-yet-assessed` | The obligation is active but no compliance assessment has been performed |
| `not-applicable` | The obligation has been assessed as not applicable to this service |
| `under-remediation` | A non-compliance has been identified and a remediation plan is in progress |

### 9.2 Evidence management

Each bound obligation has associated evidence records. An evidence record is an IAO information content entity that provides compliance evidence for one or more bound obligations. Properties:

- **Evidence type:** document, record, process, qualification, inspection, declaration (from §5.2)
- **Content:** reference to the actual evidence artefact (or the artefact itself if stored in Ontara)
- **Production date:** when the evidence was created or last reviewed
- **Freshness threshold:** how recent the evidence must be for the obligation to remain in `compliant` state
- **Sufficiency assessment:** whether this evidence (alone or in combination with other evidence) is sufficient to demonstrate compliance
- **Provenance:** who produced the evidence, under what circumstances

### 9.3 Continuous compliance monitoring

The system monitors compliance state continuously, not periodically:

- **Evidence freshness tracking.** When evidence exceeds its freshness threshold, the bound obligation transitions from `compliant` to `evidence-stale` and an alert is raised.
- **Service model change detection.** When the service model changes (new service line, staffing change, premises change), the system re-evaluates applicability conditions across all activated frameworks. New obligations may activate; existing obligations may become inapplicable.
- **Framework update propagation.** When a governance framework in the library is updated, all tenants with active activations receive a structured notification. New, revised, and withdrawn obligations are clearly identified. The tenant reviews and confirms the update.

### 9.4 Compliance assessment

A `ComplianceAssessment` is a point-in-time evaluation of the tenant's governance posture:

- **Scope:** which frameworks, which obligation groups, or the complete posture
- **Assessment date:** when the assessment was performed
- **Results:** per-obligation compliance state, evidence summary, gap list
- **Aggregate metrics:** percentage compliant by framework, by obligation group, by BMM concern
- **Trend indicators:** comparison with previous assessments — improving, stable, declining
- **Risk indicators:** obligations with approaching evidence deadlines, obligations under remediation, high-severity non-compliances

## 10. Governance in the Coordinate Space

Governance is a dimension of the coordinate space ([[concept-coordinate-framework|A12]]). Every bound obligation has a compliance state that changes over time. The aggregate governance posture of a service is a composite position across all its bound obligations. This means governance participates fully in the coordinate framework's capabilities:

### 10.1 Compliance as coordinate position

Each obligation group (or individual bound obligation) defines an axis or axis family in the coordinate space. The compliance state at any point in time is a position on that axis. The service's overall governance posture is a point in a high-dimensional governance subspace.

### 10.2 Governance trajectories

Because compliance state is temporally indexed, the system can compute governance trajectories — the path the service traces through the governance subspace over time. Trajectories reveal patterns:

- **Improving trajectory:** compliance state moving from partial toward full compliance across multiple obligation groups
- **Declining trajectory:** evidence going stale, gaps emerging, remediation falling behind
- **Oscillating trajectory:** compliance achieved before inspection, lapsing afterward — a structural governance problem
- **Stable trajectory:** sustained compliance — the target state

### 10.3 Governance in snapshots

Coordinate space snapshots ([[concept-coordinate-space-snapshots|L8]]) include governance state in all five epistemic types:

- **Current:** the live compliance posture
- **Historical:** the compliance posture at any past point in time
- **Goal:** the target governance posture (e.g., "achieve CQC Outstanding on all five domains")
- **Hypothetical:** "if we add this service line, what is the projected governance posture?"
- **Projected:** where the governance posture is heading given current trajectories

## 11. Governance-Aware Simulation

### 11.1 Obligations as constraints in the operational simulation

The operational simulation ([[concept-operational-simulation|L5]]) models the running business. Governance obligations enter the simulation as **constraints on the state space**: states that violate obligations are marked as impermissible; states that satisfy all obligations are within the feasible region.

When the simulation evaluates a proposed operational change — "reduce staffing to 80%", "extend opening hours", "add a new service line" — it checks the resulting state against all bound obligations and reports governance consequences alongside operational consequences.

### 11.2 Governance in the reflective simulation

The reflective simulation ([[concept-reflective-simulation|L6]]) reads compliance state as one of its inputs. Governance health is a dimension of the reflective simulation's assessment of "how is the business doing?"

Valence ([[concept-valence|L7]]) — the operator's declared conception of good vs bad performance — naturally includes governance commitments. An operator may declare:

- "CQC compliance is non-negotiable — any projected breach is a red alert regardless of other metrics"
- "I want to exceed minimum standards on the 'well-led' domain — target: upper quartile"
- "GDPR compliance is table-stakes; report by exception only"
- "Employment law compliance is critical given our growth trajectory — flag any staffing change that affects obligations"

These valence declarations weight the reflective simulation's governance assessment.

### 11.3 Goal-seeking with governance constraints

Goal-seeking computation ([[concept-goal-seeking-computation|L9]]) treats governance obligations as constraints on the search space:

- **Obligations and prohibitions** define hard constraints — no valid path crosses a prohibition; no reachable goal state violates an active obligation.
- **Permissions** define the available action space — the set of permissible actions the system can consider.
- **Regulatory powers** define the meta-actions available — the capacity to modify the obligation landscape (e.g., applying to CQC to vary registration conditions).

When searching for a path from current state to goal state in the coordinate space, the system respects governance constraints as boundaries of the feasible region. This is where the deontic modalities become computationally significant.

## 12. Temporal Governance State and Audit

### 12.1 Temporal depth

Every entity in the governance model is temporally indexed:

- **Library tier:** Framework versions, instrument amendments, currency dates
- **Activation tier:** Activation dates, binding history, applicability reassessments
- **Operational tier:** Compliance state transitions, evidence submissions, gap identifications, remediation actions, assessment results

Each state change is an event with provenance: who, when, why, with what evidence.

### 12.2 Historical analysis

The temporally rich governance state supports analytical queries:

- "Show compliance history for [framework] over [period]"
- "When did our CQC 'safe' domain compliance drop below threshold?"
- "Which obligations have been under remediation for more than [duration]?"
- "How has our overall governance posture changed since [date]?"
- "Compare governance posture at [date1] with [date2] — what improved, what declined?"

### 12.3 Audit as structured temporal query

Audit becomes a structured query over the knowledge graph, not a document assembly exercise. An audit package for a CQC inspection includes:

- The complete set of applicable obligations from the activated CQC framework
- Current compliance state for each obligation
- Evidence chain for each obligation (with freshness status)
- Compliance history trajectory
- Gap analysis with remediation status
- Cross-framework interactions (where CQC obligations overlap with GDPR, employment law, etc.)

This is producible on demand because the information is intrinsic to the system's operational state — it is not compiled retrospectively.

### 12.4 Predictive governance

Using compliance trajectories and evidence freshness tracking, the system can predict governance risks:

- "Evidence for [obligation] expires in 30 days — schedule renewal"
- "Based on current trajectory, [obligation group] is at risk of non-compliance by [date]"
- "The proposed staffing reduction triggers [N] new obligations that are not yet addressed"
- "Framework [X] was updated 60 days ago; you have not yet reviewed the changes"

## 13. The Ingestion Pipeline

### 13.1 The ingestion problem

Governance documents are semi-structured prose with implicit structure: nested obligations, conditional applicability, cross-references to legislation, ambiguous scope, and domain-specific terminology. Transforming this into the formally represented obligation vocabulary is the ingestion problem.

### 13.2 Supervised LLM-assisted decomposition

The ingestion pipeline uses LLM capability to perform the heavy lifting of structural decomposition, with a domain expert reviewing, confirming, and refining the output. The process is:

1. **Source document intake.** The governance document enters the pipeline. The system identifies the instrument type, jurisdiction, authority, and effective date.

2. **Structural decomposition.** The LLM decomposes the document into candidate deontic directives, identifying for each: the deontic modality (obligation/permission/prohibition/power), the subject (who is obliged), the content (what is required), applicability conditions, temporal scope, evidential implications, and source reference (clause/section).

3. **Ambiguity flagging.** Where the text is ambiguous — unclear scope, implicit conditions, vague evidential requirements — the system flags these for expert resolution rather than guessing.

4. **Expert review.** The domain expert reviews each candidate directive: confirms the modality, refines the content, resolves ambiguities, adds or corrects applicability conditions, specifies evidential requirements, and links to related directives in other frameworks.

5. **Framework assembly.** The confirmed directives are assembled into a governance framework with metadata (§7.2).

6. **Validation.** The assembled framework is loaded into the knowledge graph and validated: OWL reasoning checks for internal consistency, SPARQL queries verify structural completeness (every directive has a source, every obligation has at least one evidential specification), and cross-framework relationship queries identify overlaps with existing frameworks in the library.

### 13.3 Incremental update

When a source document is revised, the ingestion pipeline is re-run against the new version, producing a structured diff against the existing framework:

- **New directives:** obligations added in the revision
- **Revised directives:** obligations whose content, conditions, or evidential requirements have changed
- **Withdrawn directives:** obligations removed in the revision
- **Unchanged directives:** obligations unaffected by the revision

The diff is reviewed by the domain expert and applied to the framework. Update notifications propagate to all tenants with active activations.

## 14. Integration with the Existing Architecture

### 14.1 BMM integration — GovernanceMapping enrichment

The existing GovernanceMapping concern (C5) in the BMM provides the meta model anchor. The obligation vocabulary enriches GovernanceMapping's existing elements:

- `GovernanceRequirement` gains deontic modality, applicability conditions, temporal scope, evidential specification, and source instrument reference — becoming the BMM-level expression of a deontic directive.
- `ComplianceProcess` gains binding to specific governance frameworks and obligation groups.
- `AuditEvidenceRecord` gains freshness tracking, sufficiency assessment, and links to specific bound obligations.

New BMM General elements may be needed:
- `GovernanceFramework` (or `GovernanceFrameworkActivation`) — representing a tenant's adoption of a framework
- `BoundObligation` — the instance-level binding of a directive to a service model element
- `ComplianceAssessment` — a point-in-time governance posture evaluation

### 14.2 Knowledge graph integration

The obligation vocabulary sits in the domain graph stratum ([[ontara-ref-master-register|B28]]), grounded in BFO via IAO. Governance frameworks are collections of OWL individuals (deontic directives) with rich property relationships. Compliance states, evidence records, and assessments are also knowledge graph entities.

Authority zones ([[ontara-ref-master-register|B29]]) apply: the obligation vocabulary (class definitions, property characteristics) is OWL-authoritative; the structural representation of frameworks and their integration with the BMM is expressed in both SysML and OWL with explicit correspondence.

### 14.3 Satisfy traceability chain

The existing satisfy traceability pattern (requirement → constraint → evaluator → evidence) in the [[ontara-ref-master-register|PatternCatalogue]] is the execution pattern for compliance checking. The obligation vocabulary provides the *content* that flows through this pattern: deontic directives are the requirements; applicability conditions and evidential specifications are the constraints; the compliance monitoring system is the evaluator; evidence records are the evidence.

### 14.4 Weighted relationships

Governance obligations participate in the weighted relationship model ([[concept-weighted-relationships|B14]]). The weight of a governance relationship captures how strongly a change in one element affects governance obligations on another. For example, a change to staffing levels (ResourcePlanning) has a strong weight toward employment law obligations (GovernanceMapping) — if staffing changes, employment obligations need reassessment. The unity principle ([[principle-unity-principle|A11]]) ensures the same weights inform comprehension, governance monitoring, and simulation.

## 15. The CQC Archetype

To ground the vocabulary in concrete reality, consider CQC registration as an illustrative archetype (the design is regime-agnostic; CQC is one instance).

### 15.1 Framework structure

A "CQC Registration for Healthcare Services (England)" governance framework would contain:

- **Source instruments:** Health and Social Care Act 2008; HSCA 2008 (Regulated Activities) Regulations 2014; CQC Registration Regulations 2009; CQC Scope of Registration Guidance; Fundamental Standards Guidance
- **Obligation groups:** mapping to CQC's five key questions — Safe, Effective, Caring, Responsive, Well-led
- **Directives:** decomposed from the Key Lines of Enquiry (KLOEs), each traced to specific regulations
- **Applicability conditions:** regulated activity types (treatment, diagnostic and screening, surgical procedures, etc.)

### 15.2 Activation example

A private gender-affirming healthcare service (GSL) activates the CQC framework:

1. **Applicability assessment:** The service provides regulated activities "treatment" and "diagnostic and screening procedures." The system activates all obligations applicable to these activities and the organisational form (organisation with registered manager).

2. **Obligation binding:** "Persons employed must be fit" binds to all clinical staff roles in ResourcePlanning. "Premises must be suitable" binds to the service's registered location. "A complaints procedure must be maintained" binds to a process in ActivityModel. "A statement of purpose must be maintained" binds to a governance document in GovernanceMapping.

3. **Gap identification:** If the service model does not yet define a complaints procedure, this appears as a structural gap — not just a compliance gap but a missing element of the service design.

### 15.3 Operational governance

Once activated and bound:

- The system monitors DBS check currency for all staff (evidence freshness tracking against the obligation "persons employed must be fit")
- When a new clinical service is added, the system evaluates whether additional regulated activities are triggered and whether new obligations activate
- Before a CQC inspection, the system produces a structured compliance package: every applicable obligation, current evidence, compliance history, gap analysis
- The reflective simulation reports governance health alongside clinical and operational metrics

### 15.4 Beyond CQC

The same service simultaneously activates GDPR, employment law, NHS DSPT, and DCB0129/DCB0160 frameworks. The system tracks all of these in the same coordinate space, with the same temporal depth, the same simulation integration, and the same audit capability. Cross-framework overlaps (e.g., CQC's data security requirements and GDPR's data protection requirements both governing the same clinical records) are identified and reconciled.

## 16. Design Decisions and Open Questions

### 16.1 Decisions taken in this paper

| ID | Decision | Rationale |
|---|---|---|
| S121-D1 | Deontic directives are BFO/IAO directive information entities | Donohue (2017) analysis; aligns with existing ontology stack |
| S121-D2 | Regime-agnostic vocabulary | Governance requirements come from multiple sources; no single regime is privileged |
| S121-D3 | Three-tier architecture (library, activation, operations) | Separates maintained shared infrastructure from tenant-specific binding from operational monitoring |
| S121-D4 | Defeasibility via explicit exception conditions, not non-monotonic reasoning | Preserves OWL 2 DL monotonicity (B23); exceptions are authored and traceable (A6) |
| S121-D5 | Governance framework library as platform-level shared infrastructure | Multi-tenancy principle (A13); frameworks are capabilities, activations are tenant-level |
| S121-D6 | Compliance state is a coordinate dimension | Enables governance participation in projection, simulation, and goal-seeking |

### 16.2 Open questions

| ID | Question | Implications |
|---|---|---|
| S121-Q1 | Should `GovernanceFramework` be a new BMM General element or an SMM-side concept? | Affects which meta model it belongs to; the framework library is arguably platform infrastructure (SMM), while activation is business model (BMM) |
| S121-Q2 | How granular should obligation decomposition be? | Too fine-grained and the framework becomes unmanageable; too coarse and compliance checking is imprecise. Need heuristics from real-world experience. |
| S121-Q3 | What is the OWL class structure for the full deontic vocabulary? | Needs detailed OWL modelling — class hierarchy, object properties, data properties, restrictions. A follow-up design task. |
| S121-Q4 | How does the ingestion pipeline handle legislative cross-references? | A statute may say "subject to section X" — the pipeline must follow and resolve these references. Affects pipeline design. |
| S121-Q5 | What is the MVP implementation path? | A phased approach starting with a single framework (CQC) and basic activation/binding, before building full simulation integration. Needs a plan. |
| S121-Q6 | How should the Ears demonstrator relate to this workstream? | Ears is a clinical demonstrator that could exercise the CQC governance framework. Could be combined. |
| S121-Q7 | What is the relationship to E011 (IG and cybersecurity)? | E011 identified IG/cyber as a foundational modelling concern. The governance framework library subsumes part of this — GDPR, NHS DSPT, and Cyber Essentials could be frameworks in the library. |

## 17. Register Connections

### 17.1 Existing concepts exercised

| Concept | How exercised |
|---|---|
| [[principle-self-describing-system\|A2]] (self-describing system) | The system knows its own governance obligations and compliance state |
| [[principle-clinical-governance-first-class\|A8]] (clinical governance as first-class concern) | Governance obligations are first-class entities in the knowledge graph, not a separate compliance layer |
| [[principle-discipline-as-load-bearing-structure\|A9]] (discipline) | Formal obligation representation propagates governance rigour from design through operation |
| [[principle-intrinsic-self-knowledge\|A10]] (intrinsic self-knowledge) | Compliance state is computed from live system state, not stored as static assessment |
| [[principle-unity-principle\|A11]] (unity principle) | The same governance model informs comprehension, simulation, goal-seeking, and audit |
| [[concept-coordinate-framework\|A12]] (coordinate framework) | Compliance is a dimension of the coordinate space; governance has trajectories and snapshots |
| [[concept-multi-tenancy\|A13]] (multi-tenancy) | Framework library is platform-level; activation is tenant-level |
| [[concept-knowledge-graph\|B22]] (knowledge graph as canonical store) | Obligations, compliance states, and evidence records live in the knowledge graph |
| [[concept-bfo-ontological-grounding\|B23]] (OWL 2 DL) | Deontic vocabulary is OWL 2 DL, grounded in BFO via IAO |
| [[concept-operational-simulation\|L5]] (operational simulation) | Governance constraints shape the simulation's state space |
| [[concept-reflective-simulation\|L6]] (reflective simulation) | Reads compliance state as input; governance health informs assessment |
| [[concept-valence\|L7]] (valence) | Operator declares governance preferences as valence anchors |
| [[concept-coordinate-space-snapshots\|L8]] (coordinate space snapshots) | Governance state in all five epistemic types |
| [[concept-goal-seeking-computation\|L9]] (goal-seeking computation) | Obligations as hard constraints; permissions as action space |

### 17.2 New concepts for registration

| Proposed code | Concept | Tier | Section |
|---|---|---|---|
| TBD | Deontic directive vocabulary | T2 | B (structural architecture) |
| TBD | Governance framework library | T2 | B (structural architecture) |
| TBD | Framework activation and obligation binding | T3 | C or I (BMM concern or platform concept) |
| TBD | Normative instrument taxonomy | T3 | B (structural architecture) |
| TBD | Compliance as coordinate dimension | T3 | L (simulation) or B (structural) |
| TBD | Supervised ingestion pipeline | T3 | E (generation pipeline) |

---

*Discussion paper produced 3 April 2026 (Session 121). First paper in the Clinical and Operational Governance workstream.*
