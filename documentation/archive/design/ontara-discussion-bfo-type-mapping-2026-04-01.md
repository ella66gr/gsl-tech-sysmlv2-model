---
tags:
  - discussion
  - architecture
  - ontology
date: 2026-04-01
status: working
session: 98
---
# Discussion Paper: @BfoType Metadata Definition and BFO Mapping Table
> `= this.file.path`

*Ontara Platform — Discussion Paper*
**Date:** 1 April 2026 (Session 98)
**Purpose:** Specifies the `@BfoType` metadata definition for annotating BMM `part def`s with their BFO categories and mid-level ontology parents. Includes the complete mapping table for all 34 annotated BMM elements. Serves as both a design document and an instruction set for applying the annotations in SysML.
**Status:** Working document — implementation specification.
**Depends on:** [[ontara-discussion-knowledge-graph-architecture-2026-04-01|Knowledge Graph Architecture]] (Session 97), [[ontara-discussion-ontological-grounding-2026-03-22|Ontological Grounding for the Coordinate Framework]] (Session 59)

---

## Contents

- [[#1. Design Rationale|§1. Design Rationale]]
- [[#2. Metadata Definition|§2. Metadata Definition]]
- [[#3. Annotation Ordering Convention|§3. Annotation Ordering Convention]]
- [[#4. BFO Category Primer|§4. BFO Category Primer]]
- [[#5. Complete BFO Mapping Table|§5. Complete BFO Mapping Table]]
- [[#6. Mapping Principles|§6. Mapping Principles]]
- [[#7. Unmapped Elements|§7. Unmapped Elements]]
- [[#8. Register Connections|§8. Register Connections]]

---

## 1. Design Rationale

Session 97 decided that each BMM `part def` will carry a `@BfoType` metadata annotation declaring its BFO category. This serves three purposes:

1. **Human-readable documentation.** Any reader of the SysML model can see the ontological grounding of each element without consulting an external mapping document.
2. **Pipeline input.** The `@BfoType` annotation is the input to Stage 2 of the five-stage Python mapping pipeline ([[ontara-discussion-knowledge-graph-architecture-2026-04-01|Session 97]] §6.5) — the classification step that determines how each SysML element projects into the OWL domain graph.
3. **Consistency enforcement.** Making the BFO mapping explicit at the source forces disciplined ontological thinking at the point of element creation, not as an afterthought ([[principle-discipline-as-load-bearing-structure|A9]]).

### 1.1 Why String attributes, not enums

All three attributes are `String`-typed. The BFO and mid-level ontology class inventories are large and externally governed — BFO has ~35 classes, CCO has hundreds, OGMS and IAO add more. Maintaining SysML `enum def`s that duplicate these hierarchies would be fragile and counterproductive. The authoritative class hierarchies live in OWL; the SysML annotations reference them by name. The mapping pipeline validates these names against the loaded OWL ontologies at Stage 4 (reason/validate). This preserves [[concept-non-constraining|J3 (non-constraining)]] — all options remain open.

### 1.2 Scope

`@BfoType` is applied to all 34 elements that carry the full comprehension metadata set (`@CatalogueTag`, `@UserFacing`, `@PurposiveDescription`, `@Comprehension`, `@WeightedRelationship`). These are the domain-semantic BMM vocabulary — the elements that will project into the OWL domain graph.

The 11 BusinessScenarios `part def`s (ScenarioDefinition, ProjectionParameter, GrowthAssumption, ProjectionFormula, ProjectionTimeline, ProjectionOutput, SensitivityParameter, ScenarioComparison, PeriodActuals, VarianceAnalysis, ForecastBaseline) and the StrategicObjective `requirement def` in BusinessStrategy are **deferred** ([[concept-co-evolution|J2]] — they will receive annotations when the pipeline that consumes them is built) from `@BfoType` annotation. They are projection mechanics and operational instrumentation — closer to IAO information content entities than BFO domain categories. They will receive `@BfoType` annotations when the knowledge graph pipeline reaches them, with a likely blanket mapping to `IAO:InformationContentEntity` or a CCO planning/computational subclass.

---

## 2. Metadata Definition

The `@BfoType` metadata def is placed in `Foundation::MetadataLibrary`, consistent with all other cross-cutting metadata definitions ([[principle-model-generates-everything|A3]]).

```sysml
metadata def BfoType {
    doc /* BFO ontological grounding annotation. Declares the
         * BFO 2020 category and mid-level ontology parent for
         * a BMM or SMM element.
         *
         * This annotation is the input to Stage 2 of the
         * OWL mapping pipeline — the classification step that
         * determines how each SysML element projects into the
         * knowledge graph's domain graph stratum.
         *
         * bfoClass: the BFO 2020 class name. Uses the standard
         *   BFO label (e.g. "Role", "Process", "Quality",
         *   "GenericallyDependentContinuant"). Validated against
         *   the loaded BFO OWL file at pipeline Stage 4.
         * midLevelClass: the CCO, IAO, OGMS, or other mid-level
         *   ontology class that this element maps to. Uses
         *   prefix:ClassName format (e.g. "CCO:ActOfServiceProvision",
         *   "IAO:InformationContentEntity"). Empty string if no
         *   mid-level mapping is identified yet.
         * mappingNotes: brief rationale for the classification,
         *   especially where the mapping is non-obvious or where
         *   alternatives were considered.
         *
         * Ontological grounding (B18, B19). OWL 2 DL (B23).
         * Knowledge graph (B22). Mapping ontology (B24).
         * Domain-semantic mapping (Session 97 D6).
         * System meta model concept.
         * Session 98. */
    attribute bfoClass : String;
    attribute midLevelClass : String;
    attribute mappingNotes : String;
}
```

---

## 3. Annotation Ordering Convention

The existing ordering convention (documented in `@WeightedRelationship` doc block and enforced during enrichment) is:

```
@CatalogueTag → @UserFacing → @PurposiveDescription → @Comprehension → @WeightedRelationship(s)
```

`@BfoType` is a classification annotation — it declares what an element *is* in ontological terms. It belongs with `@CatalogueTag` (which declares what an element is in BMM structural terms). The updated ordering:

```
@CatalogueTag → @BfoType → @UserFacing → @PurposiveDescription → @Comprehension → @WeightedRelationship(s)
```

`@BfoType` is always a single annotation per element (one BFO grounding per concept), placed immediately after `@CatalogueTag`.

---

## 4. BFO Category Primer

BFO 2020 (ISO/IEC 21838-2:2021) provides the upper ontology. The categories relevant to the BMM mapping are:

**Continuants** (entities that persist through time):

- **IndependentContinuant** — entities that can exist on their own (material entities, spatial regions). Not directly used for BMM concepts — too general.
  - **MaterialEntity** — physical objects. Not directly used for BMM `part def`s (they are abstract structural templates, not physical things).
- **SpecificallyDependentContinuant** — entities that depend on a specific bearer.
  - **Quality** — measurable/observable properties inherent in a bearer (a person's height, an item's weight).
  - **RealizableEntity** — entities that are realised through processes.
    - **Role** — a realizable entity that comes into being when a bearer takes on a social/functional position. Crucially: roles are *extrinsic* — they depend on context, not intrinsic nature.
    - **Disposition** — an intrinsic tendency to behave in a certain way under certain conditions.
    - **Function** — a disposition selected for by design or natural selection.
- **GenericallyDependentContinuant** — entities that depend on some bearer but can migrate between bearers (patterns, plans, specifications, information content).

**Occurrents** (entities that unfold in time):

- **Process** — something that happens, with temporal parts.
- **ProcessBoundary** — the instantaneous temporal boundary of a process.
- **TemporalRegion** — intervals and instants of time.

**Key CCO classes used in the mapping:**

- `CCO:ActOfServiceProvision` — a process of providing a service
- `CCO:Agent` — a material entity with agency (person, organisation)
- `CCO:ActOfCommercialExchange` — buying/selling
- `CCO:ActOfPlanning` — processes of making plans
- `CCO:ArtifactFunction` — designed function of an artefact
- `CCO:InformationBearingEntity` — entities that carry information
- `CCO:GroupOfAgents` — collections of agents

**Key IAO classes:**

- `IAO:InformationContentEntity` — the content of an information-bearing entity (a document's meaning, not the physical paper)
- `IAO:PlanSpecification` — a plan: a specification of objectives and means
- `IAO:ObjectiveSpecification` — a specification of a desired state of affairs
- `IAO:MeasurementDatum` — a measured value

---

## 5. Complete BFO Mapping Table

### 5.1 ServiceConcept (9 elements)

| # | Part Def | bfoClass | midLevelClass | mappingNotes |
|---|---|---|---|---|
| 1 | CustomerSegment | GenericallyDependentContinuant | CCO:GroupOfAgents | A segment is an abstract grouping — it characterises a class of agents, not a physical entity. It can be instantiated across different agent populations. CCO:GroupOfAgents because it denotes a collection defined by shared characteristics. |
| 2 | ValueProposition | GenericallyDependentContinuant | IAO:PlanSpecification | A value proposition is a specification of promised value — an information content entity that describes what will be delivered and why. It migrates between bearers (documents, conversations, marketing materials). |
| 3 | ServiceOffering | GenericallyDependentContinuant | IAO:PlanSpecification | A service offering is a packaged specification of what can be delivered. It is not the delivery itself (that would be a Process) but the plan/template for delivery. Subclass of IAO:PlanSpecification — it specifies what the service includes, its scope, and its pricing basis. |
| 4 | Channel | Role | CCO:ArtifactFunction | A channel is a role played by a medium or platform in the context of connecting the business to its customers. The same website can be an acquisition channel and a delivery channel — the channel identity is extrinsic, depending on how it is used. CCO:ArtifactFunction because it describes the designed function of the channel artefact in the service system. |
| 5 | DifferentiationClaim | GenericallyDependentContinuant | IAO:InformationContentEntity | A claim is an assertion — a piece of information content. It is about the service but is not itself a service or a role. It has truth conditions and evidence bases. |
| 6 | ServiceSubject | Role | — | The entity *upon which* a service is performed. This is a role, not an intrinsic identity — the same dog is a pet at home and a service subject at the groomer. BFO:Role is the correct category because the subject status is extrinsic and context-dependent. No established mid-level class; candidate for an Ontara domain ontology class `ontara:ServiceSubjectRole`. |
| 7 | ServiceParticipant | Role | — | An entity involved in a service engagement in a defined role. Like ServiceSubject, this is explicitly a role — the same person can be customer, payer, and decision-maker simultaneously. BFO:Role. Candidate for `ontara:ServiceParticipantRole`. |
| 8 | CatalogueEntry | GenericallyDependentContinuant | IAO:InformationContentEntity | A catalogue entry is a record — an information content entity that links an item definition to business-context properties (price, availability, status). It is about the item, not the item itself. |
| 9 | ExternalReference | GenericallyDependentContinuant | IAO:InformationContentEntity | A pointer to knowledge that lives outside the system. An information content entity whose purpose is referential — it denotes but does not contain the external knowledge. |

### 5.2 ActivityModel (5 elements)

| # | Part Def | bfoClass | midLevelClass | mappingNotes |
|---|---|---|---|---|
| 10 | ActivityType | GenericallyDependentContinuant | IAO:PlanSpecification | An activity type is a *template* for a kind of activity — not the activity itself. It specifies what the activity involves, its category, expected duration, and frequency. The actual doing is a Process; the type is the specification that governs what counts as that kind of doing. |
| 11 | ActivityRecord | GenericallyDependentContinuant | IAO:InformationContentEntity | A recorded instance of an activity — an information content entity that documents what happened. The activity itself was a Process; the record is information about that process. |
| 12 | ActivityBudget | GenericallyDependentContinuant | IAO:PlanSpecification | A planned allocation of activity volume — a forward-looking specification. IAO:PlanSpecification because it specifies desired future states (planned volumes, periods). |
| 13 | ActivityGranularity | GenericallyDependentContinuant | IAO:PlanSpecification | A policy declaration about tracking precision — a specification of how the system should observe and record. IAO:PlanSpecification because it governs how the system will operate. |
| 14 | ActivityCostAllocation | GenericallyDependentContinuant | IAO:InformationContentEntity | A mapping from activity to financial cost — an information content entity that connects two domains (activity and finance). Characterising, not process-like. |

### 5.3 ResourcePlanning (7 elements)

| # | Part Def | bfoClass | midLevelClass | mappingNotes |
|---|---|---|---|---|
| 15 | ResourceType | GenericallyDependentContinuant | IAO:PlanSpecification | A resource type is a category specification — it defines what a kind of resource is (personnel, technology, estate), its acquisition characteristics, and cost profile. The actual resource (a specific clinician, a specific server) is an IndependentContinuant; the type is the specification that classifies it. |
| 16 | ResourceInstance | Role | CCO:Agent | A resource instance is a planning-level archetype — "a prescribing clinician at 0.5 FTE". This is a role: the same person can be a ResourceInstance in one capacity model and a different ResourceInstance in another. Mid-level: CCO:Agent for personnel types; more general for non-personnel. The mapping pipeline should specialise based on the `category` attribute (personnel → CCO:Agent; technology → CCO:Artifact; etc.). |
| 17 | Capability | Disposition | CCO:ArtifactFunction | A capability is an organised ability — a disposition of the business to produce a defined service function given the right resource configuration. BFO:Disposition because it describes what the business *can* do, not what it *is* doing. CCO:ArtifactFunction because the capability is designed (not naturally occurring). |
| 18 | CapacityModel | GenericallyDependentContinuant | IAO:InformationContentEntity | A capacity model is a planning assertion — an information content entity that relates resource configuration to throughput. It is a claim about the system, not a property of the system itself. |
| 19 | ResourceConstraint | GenericallyDependentContinuant | IAO:InformationContentEntity | A constraint on resource availability — an information content entity that records a limit. The limit may be externally imposed (regulatory) or internally declared (practical). The constraint itself is information; its effect is felt through processes. |
| 20 | InventoryRecord | GenericallyDependentContinuant | IAO:MeasurementDatum | A point-in-time stock record — an information content entity recording a measured quantity. IAO:MeasurementDatum because it captures a measurement (quantity on hand) at a specific time. |
| 21 | ObjectiveCapabilityMapping | GenericallyDependentContinuant | IAO:InformationContentEntity | A declared traceability connection — an information content entity that links a strategic objective to capabilities. The mapping is an assertion, not a process or a role. |

### 5.4 FinancialPlanning (6 elements)

| # | Part Def | bfoClass | midLevelClass | mappingNotes |
|---|---|---|---|---|
| 22 | RevenueStream | GenericallyDependentContinuant | IAO:PlanSpecification | A mechanism by which income is generated — a specification of how money flows in. Not itself a process (the actual transaction is a CCO:ActOfCommercialExchange); the stream is the structural specification. |
| 23 | CostDriver | GenericallyDependentContinuant | IAO:InformationContentEntity | A structural factor that generates cost — an information content entity that characterises a resource's cost behaviour. The cost driver is about the resource, not the resource itself. |
| 24 | UnitEconomics | GenericallyDependentContinuant | IAO:InformationContentEntity | The financial profile of one unit of service — a computed/declared information content entity combining revenue, cost, and margin figures. |
| 25 | PricingModel | GenericallyDependentContinuant | IAO:PlanSpecification | The logic that determines what a customer pays — a specification of pricing rules. IAO:PlanSpecification because it governs future commercial exchanges. |
| 26 | FinancialProjection | GenericallyDependentContinuant | IAO:PlanSpecification | A forward-looking financial picture — a specification combining assumptions into a projected future. IAO:PlanSpecification because it is explicitly a planning instrument. |

### 5.5 GovernanceMapping (2 elements)

| # | Element | bfoClass | midLevelClass | mappingNotes |
|---|---|---|---|---|
| 27 | GovernanceRequirement (req def) | GenericallyDependentContinuant | IAO:ObjectiveSpecification | A governance obligation — a specification of a desired/required state of affairs. IAO:ObjectiveSpecification because it specifies what must be achieved (compliance with a regulatory standard). The requirement is about the obligation; the actual compliance is a Process. |
| 28 | AuditEvidenceRecord | GenericallyDependentContinuant | IAO:InformationContentEntity | A record demonstrating compliance — an information content entity that provides evidence. The evidence record is about a process (the compliance activity); it is not itself a process. |

### 5.6 StakeholderModel (6 elements)

| # | Part Def | bfoClass | midLevelClass | mappingNotes |
|---|---|---|---|---|
| 29 | StakeholderRelationship | GenericallyDependentContinuant | — | A typed, ongoing relationship — this is a relational entity that depends on both parties but is not itself a bearer of qualities in the way a Role is. BFO:GenericallyDependentContinuant because the relationship pattern can be instantiated between different pairs of entities. Candidate for `ontara:StakeholderRelation`. Not a BFO:Role (the relationship is between entities, not a role played by one entity). Not a BFO:Process (the relationship persists, it is not a temporal unfolding). |
| 30 | CooperativeArrangement | GenericallyDependentContinuant | IAO:PlanSpecification | A formalised agreement — a specification of shared responsibilities, protocols, and outcomes. The arrangement as an entity is informational; the joint delivery it governs is a Process. IAO:PlanSpecification because it specifies how cooperation will work. |
| 31 | ReferralPathway | GenericallyDependentContinuant | IAO:PlanSpecification | A structured route specification — defines direction, criteria, protocol, and expected response times. The pathway as a concept is a plan; actual referrals flowing through it are Processes. |
| 32 | ExternalDependency | GenericallyDependentContinuant | IAO:InformationContentEntity | A record of asymmetric reliance — an information content entity that characterises what the business depends on. The dependency relationship itself is informational; its consequences are felt through resource availability (Roles and Processes). |
| 33 | CommunityRelationship | GenericallyDependentContinuant | — | The business's constitutive connection to a community. Like StakeholderRelationship, this is relational and depends on both parties. BFO:GenericallyDependentContinuant. Candidate for `ontara:CommunityRelation`. |
| 34 | ParticipationModel | GenericallyDependentContinuant | IAO:PlanSpecification | A specification of how customers/patients participate — describes roles, information contribution, decision involvement, self-service scope. The model is a plan; actual participation is a Process. IAO:PlanSpecification. |

---

## 6. Mapping Principles

Six principles governed the mapping decisions:

**P1. Map the `part def`, not its instances ([[concept-part-def-part-distinction|I9]]).** A `part def` is a meta model concept — a structural template. The instances (`part` usages in demonstrators) map differently. `ServiceOffering` as a `part def` is a specification type; `initialAssessment : ServiceOffering` is an instance of that specification. The `@BfoType` annotation applies to the `part def`.

**P2. Domain-semantic, not notation-semantic.** Consistent with [[ontara-discussion-knowledge-graph-architecture-2026-04-01|Session 97]] decision D6. We ask "what does this BMM concept represent in the domain?" not "what SysML construct is it?"

**P3. Most BMM `part def`s are GenericallyDependentContinuant.** This is expected and correct. The BMM describes the structural logic of a service business — plans, specifications, records, claims, relationships. These are information-level entities that depend on bearers but can migrate between them (a pricing model can be documented, communicated, revised). Only concepts that are inherently about *what entities do or can do* map to Role or Disposition.

**P4. Roles are extrinsic.** ServiceSubject, ServiceParticipant, Channel, and ResourceInstance are roles — their identity depends on context, not intrinsic nature. The dog is a service subject only while at the groomer; the website is a channel only in the context of the business's service delivery.

**P5. IAO:PlanSpecification vs IAO:InformationContentEntity.** The distinction: a PlanSpecification specifies a desired future state or governs future action (ServiceOffering, ActivityType, ActivityBudget, PricingModel, FinancialProjection, RevenueStream). An InformationContentEntity records, characterises, or references (ActivityRecord, CatalogueEntry, CostDriver, UnitEconomics, AuditEvidenceRecord).

**P6. Ontara domain classes needed.** Six BMM concepts have no established mid-level ontology parent: [[concept-service-subject|ServiceSubject]], [[concept-service-participant|ServiceParticipant]], StakeholderRelationship, CommunityRelationship, CustomerSegment (partially — mapped to CCO:GroupOfAgents but imperfectly), and Capability (partially — mapped to CCO:ArtifactFunction but arguable). These are candidates for an Ontara-specific domain ontology layer sitting between CCO/IAO and the BMM vocabulary in the knowledge graph. This is anticipated by the [[ontara-ref-master-register|ontology stack architecture (B19)]] and does not introduce a new architectural decision.

---

## 7. Unmapped Elements

### 7.1 BusinessScenarios `part def`s (deferred)

11 `part def`s: ScenarioDefinition, ProjectionParameter, GrowthAssumption, ProjectionFormula, ProjectionTimeline, ProjectionOutput, SensitivityParameter, ScenarioComparison, PeriodActuals, VarianceAnalysis, ForecastBaseline.

These are projection mechanics — computational infrastructure for driving the business model. They will likely map to IAO:InformationContentEntity subclasses. Deferred to a future session when the mapping pipeline reaches them and when they receive full comprehension metadata.

### 7.2 StrategicObjective `requirement def` (deferred)

Maps naturally to IAO:ObjectiveSpecification (like GovernanceRequirement). Deferred because it lives in BusinessStrategy and does not yet carry the full comprehension metadata set.

### 7.3 ArchitecturalSection `part def` (SMM, different scope)

[[concept-architectural-section|ArchitecturalSection]] is SMM content ([[ontara-ref-master-register|B27]]), not BMM. Its BFO mapping is a different exercise — it describes the system architecture itself, not the business domain. Deferred to the SMM ontological grounding workstream.

---

## 8. Register Connections

### Tier 1 principles exercised

- [[principle-model-generates-everything|A3]] (model generates everything) — `@BfoType` makes ontological grounding explicit at the source, consistent with model-as-single-source-of-truth
- [[principle-two-meta-model-distinction|A4]] (two meta model distinction) — mapping scoped to BMM; SMM mapping deferred
- [[principle-discipline-as-load-bearing-structure|A9]] (discipline as load-bearing structure) — the annotation convention and ordering rule propagate consistency
- [[principle-intrinsic-self-knowledge|A10]] (intrinsic self-knowledge) — BFO grounding is declared on the element itself, not in an external document
- [[concept-co-evolution|J2]] (co-evolution) — `@BfoType` creates model content that the mapping pipeline will consume
- [[concept-non-constraining|J3]] (non-constraining) — String-typed attributes avoid constraining the BFO/mid-level class vocabulary

### Concepts directly exercised

- [[ontara-ref-master-register|B18]] (BFO — mandatory) — first concrete application of BFO categories to BMM elements
- [[ontara-ref-master-register|B19]] (ontology stack) — mid-level mappings to CCO, IAO established
- [[concept-knowledge-graph|B22]] (knowledge graph as canonical store) — mapping table feeds the domain graph
- [[ontara-ref-master-register|B23]] (OWL 2 DL as mandatory) — annotation values will be validated against loaded OWL ontologies
- [[ontara-ref-master-register|B24]] (mapping ontology) — `@BfoType` is the SysML-side input to the correspondence graph

### New observations

- Six BMM concepts need Ontara-specific domain ontology classes (P6 above). This confirms the need for an `ontara:` namespace in the domain ontology layer, as anticipated by B19.
- The BusinessScenarios `part def`s are a distinct category — projection mechanics / computational infrastructure — that may warrant a separate mapping pass with different BFO/IAO patterns.

---

## Related Documents

- [[ontara-discussion-knowledge-graph-architecture-2026-04-01|Knowledge Graph Architecture]] (Session 97)
- [[ontara-discussion-ontological-grounding-2026-03-22|Ontological Grounding for the Coordinate Framework]] (Session 59)
- [[ontara-discussion-dual-stack-architecture-2026-03-26|Dual-Stack Architecture]] (Session 73/74)
- [[ontara-service-business-meta-modelling|Service Business Meta Modelling (v2)]]
- [[ontara-ref-master-register|Master Concept Register]]
- [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]]

---

*Discussion paper written 1 April 2026 (Session 98). First concrete application of BFO categories to the BMM vocabulary — the bridge between "BFO is mandatory" (Session 73) and "here is how each element maps" (this session).*
