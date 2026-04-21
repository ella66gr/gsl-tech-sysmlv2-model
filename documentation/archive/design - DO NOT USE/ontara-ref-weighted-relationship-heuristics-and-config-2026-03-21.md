# Ontara — Weighted Relationship Heuristics and Configuration Reference

**Date:** 21 March 2026 (Session 54)
**Status:** Working reference. Governs interpretation and assignment of `@WeightedRelationship` annotations.
**Parent concepts:** [[concept-weighted-relationships|B14]] (weighted relationships), [[ontara-ref-weighted-relationship-directionality-definition|directionality definition]]
**Informed by:** Sessions 51–54 (weight population across all four batches)

---

## 1. Purpose

This document captures the heuristics established through four batches of weight assignment discussions (Sessions 52–54) and provides a complete configuration table of all `@WeightedRelationship` annotations in the BMM. It serves three purposes:

1. **Consistency reference** — when assigning new weights (e.g. for new BMM elements), apply these heuristics to ensure consistency with existing assignments.
2. **Review tool** — when reviewing or reconfiguring the weight model, use the table to see the complete picture and the rationale behind each assignment.
3. **Audit trail** — the heuristics document the reasoning principles that were applied, not just the outcomes.

All weight data is stored in the SysML model (`@WeightedRelationship` annotations with `target`, `strength`, and `rationale` attributes). This document is a companion reference, not a parallel data source. The model is the source of truth per [[principle-model-generates-everything|A3]].

---

## 2. Weight Assignment Heuristics

These heuristics were established inductively through discussion and refined through the consistency review. They are not rigid rules — they are patterns of reasoning that have proven consistent across 70 weight assignments.

### H1. Definitional vs characterising relationships

**Strong** weights are appropriate when A *defines* B or B *is structurally typed by* A — a change to A means B's fundamental identity or structural commitments are affected.

**Moderate** weights are appropriate when A *characterises* B — a change to A means B's quantitative profile, commercial terms, or operational parameters may need updating, but B's fundamental identity is unaffected.

**Test:** "If A changes, does B need to reconsider *what it is* (strong) or *how it is described* (moderate)?"

**Examples:**
- ResourceType → ResourceInstance: **strong** (instances are *typed by* the type — definitional)
- ResourceInstance → ResourceType: **moderate** (instance *characterises* type's available capacity — characterising)
- ServiceOffering → PricingModel: **strong** (offering change forces repricing — definitional)
- PricingModel → ServiceOffering: **moderate** (pricing change doesn't redefine what the offering *is* — characterising)

### H2. Quantitative changes don't force qualitative reassessment

A change to volume, budget, price, or cost does not automatically require reassessing *what something is*. Changing how much of something you do, or how much it costs, is a different kind of change from redefining the thing itself.

**Test:** "If I change the *amount* or *price* of A, do I need to reconsider *what B is*?"

**Examples:**
- ActivityBudget → ActivityType: **moderate** (revised planned volumes don't redefine the activity type)
- CostDriver → ResourceType: **moderate** (revised unit cost doesn't redefine the resource category)
- PricingModel → ServiceOffering: **moderate** (changing from per-episode to subscription doesn't change what the service delivers)

### H3. One-way relationships exist

Some concepts are pure receivers — they receive influence but do not radiate it. Not every concept needs outgoing weights. The absence of outgoing weights is a structural fact, not a gap to fill.

**Test:** "If A changes, does *any* other concept genuinely need reassessment?" If the answer is "only indirectly, through the concept that defines A," then A may be a pure receiver.

**Example:**
- AuditEvidenceRecord: **zero outgoing weights**. The evidence proves compliance; changing the evidence format does not influence the governance requirement, the resource constraints, or any other structural concept. The requirement defines what evidence is needed, not the reverse.

### H4. Mediated connections are weaker than direct connections

If A affects B only through an intermediary C (where A → C and C → B both exist), then A → B should be weaker than A → C.

**Test:** "Is there an intermediary concept that carries the effect? If so, the direct weight should be stronger than the mediated one."

**Examples:**
- ServiceOffering → ResourceType: **moderate** (mediated through ActivityType and Capability)
- DifferentiationClaim → ServiceOffering: **weak** (mediated through ValueProposition)
- ActivityCostAllocation → UnitEconomics: **moderate** (mediated through CostDriver)

### H5. Non-commutativity is real — justify both directions independently

The weight A → B and the weight B → A are separate structural facts. Symmetry is a coincidence of independent assessment, not a default. Many important relationships are asymmetric.

**Test:** "Does the same reasoning apply in both directions, or does the nature of the relationship change when reversed?"

**Common asymmetry patterns:**
- **Definitional in one direction, characterising in the reverse:** ActivityType → ActivityCostAllocation (strong) vs ActivityCostAllocation → ActivityType (moderate)
- **Strong requirement in one direction, no influence in reverse:** GovernanceRequirement → AuditEvidenceRecord (strong) vs AuditEvidenceRecord → GovernanceRequirement (none)
- **Hub radiates strongly, periphery reflects moderately:** ResourceType → ResourceConstraint (strong) vs ResourceConstraint → ResourceType (strong — but this is symmetric because constraints *do* redefine the type's effective availability)

---

## 3. Structural Patterns Observed

### 3.1 Hub elements carry the most and strongest weights

Structurally central concepts radiate more influence:

| Element | Outgoing weights | Strong | Character |
|---|---|---|---|
| ServiceOffering | 8 | 4 | Central service concept |
| ActivityType | 6 | 2 | Central activity concept |
| ResourceType | 6 | 2 | Central resource concept |
| Capability | 4 | 2 | Bridge: resources → offerings |
| CostDriver | 4 | 1 | Bridge: resources → finance |

### 3.2 Leaf/downstream elements carry fewer and weaker weights

Operational, derived, or aggregating concepts receive more than they radiate:

| Element | Outgoing weights | Strong | Character |
|---|---|---|---|
| AuditEvidenceRecord | 0 | 0 | Pure receiver |
| ActivityRecord | 1 | 0 | Operational artefact |
| ExternalReference | 1 | 0 | Near-leaf |
| Channel | 2 | 0 | Operational connector |
| FinancialProjection | 2 | 0 | Downstream aggregator |
| UnitEconomics | 2 | 0 | Derived characteriser |

### 3.3 Bridge concepts are strongly coupled in both directions

Concepts that connect two BMM concerns tend to carry strong weights toward both sides:

- **Capability:** strong → ServiceOffering (what it enables) + strong → ResourceType (what it requires)
- **ActivityCostAllocation:** connects ActivityModel to FinancialPlanning (all moderate — the bridge is characterising, not definitional)

### 3.4 Inputs define; outputs characterise

Within FinancialPlanning, the pattern is clear: structural inputs (PricingModel, CostDriver) carry strong weights to the concepts they feed, while derived outputs (UnitEconomics, FinancialProjection) carry only moderate weights. Inputs *define* the financial structure; outputs *describe* the consequences.

---

## 4. Complete Weight Table

All 70 `@WeightedRelationship` annotations in the BMM, ordered by source element within each BMM concern. Cross-package targets marked with ✦.

### ServiceConcept (22 weights, 7 elements)

| Source | Target | Strength | Batch | Rationale |
|---|---|---|---|---|
| CustomerSegment | ValueProposition | strong | B1 | Segment defines who propositions are for |
| CustomerSegment | ServiceOffering | strong | B1 | Segment defines who offerings serve |
| CustomerSegment | Channel | moderate | B1 | Segment may affect channels; many-to-many |
| ValueProposition | ServiceOffering | strong | B1 | Proposition defines what offering must deliver |
| ValueProposition | CustomerSegment | strong | B1 | Proposition is made to a specific segment |
| ValueProposition | DifferentiationClaim | moderate | B1 | Proposition may require reviewing claims; claims can lag |
| ServiceOffering | ValueProposition | strong | B1 | Offering realises a proposition |
| ServiceOffering | CustomerSegment | strong | B1 | Offering exists for defined segments |
| ServiceOffering | PricingModel ✦ | strong | B1 | Offering directly affects how it is priced |
| ServiceOffering | ActivityType ✦ | strong | B1 | Offering requires activities to deliver it |
| ServiceOffering | Channel | moderate | B1 | Offering may affect delivery channels; loose coupling |
| ServiceOffering | CatalogueEntry | moderate | B1 | Offering may require updating catalogue; operational |
| ServiceOffering | DifferentiationClaim | moderate | B1 | Offering may affect claims; mediated through proposition |
| ServiceOffering | ResourceType ✦ | moderate | B1 | Offering may affect resources; mediated through activities |
| Channel | CustomerSegment | moderate | B1 | Channel serves segments; operational many-to-many |
| Channel | ServiceOffering | moderate | B1 | Channel delivers offerings; loose coupling |
| DifferentiationClaim | ValueProposition | strong | B1 | Claim exists to substantiate a proposition |
| DifferentiationClaim | ServiceOffering | weak | B1 | Claim relates to offerings indirectly via proposition |
| CatalogueEntry | ServiceOffering | moderate | B1 | Catalogue records what is offered; operational wrapper |
| CatalogueEntry | ExternalReference | moderate | B1 | Catalogue links to external knowledge; four-layer model |
| CatalogueEntry | InventoryRecord ✦ | moderate | B1 | Catalogue may require updating inventory records |
| ExternalReference | CatalogueEntry | moderate | B1 | External ref may require reviewing catalogue entries |

### ActivityModel (14 weights, 5 elements — ActivityType from pilot S51, remainder from B4)

| Source | Target | Strength | Batch | Rationale |
|---|---|---|---|---|
| ActivityType | ActivityCostAllocation | strong | Pilot | Cost allocation structurally determined by type |
| ActivityType | ActivityGranularity | strong | Pilot | Granularity level directly governs how type is tracked |
| ActivityType | ActivityBudget | moderate | Pilot | Budgets aggregate by type; indirect via cost allocation |
| ActivityType | ActivityRecord | moderate | Pilot | Records typed by type; record is operational artefact |
| ActivityType | ResourceType ✦ | moderate | Pilot | Resources consumed by activities; many-to-many |
| ActivityType | Channel ✦ | weak | Pilot | Channels deliver services containing activities; distant |
| ActivityRecord | ActivityType | moderate | B4 | Record reflects type; operational change doesn't redefine type |
| ActivityBudget | ActivityType | moderate | B4 | Budget quantifies type; volume change doesn't redefine type |
| ActivityBudget | FinancialProjection ✦ | moderate | B4 | Budget feeds projection; projection aggregates many inputs |
| ActivityGranularity | ActivityType | moderate | B4 | Granularity governs tracking; policy change doesn't redefine type |
| ActivityGranularity | ActivityRecord | moderate | B4 | Granularity determines record detail; records produced by system |
| ActivityCostAllocation | ActivityType | moderate | B4 | Allocation maps cost to type; financial change doesn't redefine type |
| ActivityCostAllocation | CostDriver ✦ | moderate | B4 | Allocation uses driver rates; allocation method doesn't redefine driver |
| ActivityCostAllocation | UnitEconomics ✦ | moderate | B4 | Allocation feeds unit economics; mediated through cost drivers |

### ResourcePlanning (18 weights, 7 elements)

| Source | Target | Strength | Batch | Rationale |
|---|---|---|---|---|
| ResourceType | ResourceInstance | strong | B2 | Instances typed by type; type change requires instance reassessment |
| ResourceType | ResourceConstraint | strong | B2 | Constraints scoped to type; type change affects constraint applicability |
| ResourceType | Capability | moderate | B2 | Capabilities use resources; resilient to substitution within category |
| ResourceType | CapacityModel | moderate | B2 | Capacity depends on resource config; mediated through config |
| ResourceType | CostDriver ✦ | moderate | B2 | Cost profile links type to driver; structural not definitional |
| ResourceType | ActivityType ✦ | moderate | B2 | Activities consume resources; many-to-many, context-dependent |
| ResourceInstance | ResourceType | moderate | B2→B4 corr. | Instance characterises type's available capacity; operational not definitional |
| ResourceInstance | CapacityModel | moderate | B2 | Instance affects throughput; capacity aggregates across instances |
| Capability | ServiceOffering ✦ | strong | B2 | Capabilities enable offerings; can't offer what you can't deliver |
| Capability | ResourceType | strong | B2 | Capabilities defined by resource combinations |
| Capability | ObjectiveCapabilityMapping | moderate | B2 | Capability change may affect strategic mapping; declared connection |
| Capability | CapacityModel | moderate | B2 | Capability change may affect throughput; indirect |
| CapacityModel | ResourceType | moderate | B2 | Capacity claims about resource config; type exists independently |
| CapacityModel | ResourceConstraint | moderate | B2 | Higher throughput may require reviewing constraints |
| ResourceConstraint | ResourceType | strong | B2 | Constraint change directly affects type's effective availability |
| ResourceConstraint | CapacityModel | moderate | B2 | Constraint change may affect throughput assumptions |
| InventoryRecord | CatalogueEntry ✦ | strong | B2 | Stock change requires reviewing catalogue availability status |
| ObjectiveCapabilityMapping | Capability | strong | B2 | Mapping change affects capabilities' strategic justification |

### FinancialPlanning (14 weights, 5 elements)

| Source | Target | Strength | Batch | Rationale |
|---|---|---|---|---|
| PricingModel | RevenueStream | strong | B3 | Pricing change directly affects revenue mechanism |
| PricingModel | ServiceOffering ✦ | moderate | B3 | Pricing characterises offering commercially; offering defined independently |
| PricingModel | UnitEconomics | moderate | B3 | Pricing affects revenue-per-unit; unit economics also depend on costs |
| CostDriver | ResourceType ✦ | moderate | B3→B4 corr. | Cost driver characterises resource financially; type defined independently |
| CostDriver | UnitEconomics | strong | B3 | Cost drivers are direct input to cost-per-unit calculation |
| CostDriver | ActivityCostAllocation ✦ | moderate | B3 | Driver and allocation both in cost structure; allocation is mapping mechanism |
| CostDriver | RevenueStream | moderate | B3 | Cost and revenue together determine profitability; indirect |
| RevenueStream | PricingModel | strong | B3 | Stream references pricing model; stream change may require pricing reassessment |
| RevenueStream | FinancialProjection | strong | B3 | Projection aggregates streams; stream change requires projection update |
| RevenueStream | UnitEconomics | moderate | B3 | Stream informs revenue side; unit economics are per-offering |
| UnitEconomics | ServiceOffering ✦ | moderate | B3 | Unit economics characterise viability; offering defined independently |
| UnitEconomics | FinancialProjection | moderate | B3 | Unit economics feed projection; projection aggregates many inputs |
| FinancialProjection | RevenueStream | moderate | B3 | Projection change may require reviewing streams; streams exist independently |
| FinancialProjection | CostDriver | moderate | B3 | Projection change may require reviewing costs; drivers exist independently |

### GovernanceMapping (2 weights, 1 weighted element + 1 pure receiver)

| Source | Target | Strength | Batch | Rationale |
|---|---|---|---|---|
| GovernanceRequirement | AuditEvidenceRecord | strong | B4 | Requirement defines what evidence must be produced |
| GovernanceRequirement | ResourceConstraint ✦ | moderate | B4 | Requirements may impose resource constraints; not all do |

AuditEvidenceRecord: **zero outgoing weights** (pure receiver).

---

## 5. Summary Statistics

| Metric | Value |
|---|---|
| Total weights | 70 |
| Weighted elements | 25 / 26 |
| Pure receivers | 1 (AuditEvidenceRecord) |
| Strong | 23 (33%) |
| Moderate | 45 (64%) |
| Weak | 2 (3%) |
| Cross-package | 16 (23%) |
| Symmetric pairs (both directions exist) | 14 |
| Asymmetric pairs (both exist, different strengths) | 6 |
| One-way relationships (only one direction) | ~20 |

### By BMM concern

| Concern | Elements | Weights | Strong | Moderate | Weak |
|---|---|---|---|---|---|
| ServiceConcept | 7 | 22 | 10 | 11 | 1 |
| ActivityModel | 5 | 14 | 2 | 11 | 1 |
| ResourcePlanning | 7 | 18 | 6 | 12 | 0 |
| FinancialPlanning | 5 | 14 | 5 | 9 | 0 |
| GovernanceMapping | 1 (+1 pure) | 2 | 1 | 1 | 0 |
| **Total** | **25 (+1)** | **70** | **23** | **45** | **2** |

---

## 6. Known Limitations

- **Cross-package weights (16 of 70)** do not surface in the glossary until O25 (typed-ref migration, Phase 5). The weights exist in the model and are extracted by the generator, but the glossary's package-proximity heuristic cannot resolve them.
- **[[concept-weighted-relationships|B14]] remains at experimentation stage ([[concept-design-decision-lifecycle|J12]]).** The weight model is an agreed experiment, not a convention. The heuristics in this document are inductively derived and may be revised as the model evolves.
- **Ordinal strengths only.** The current model uses four ordinal levels (strong, moderate, weak, contextual). Hybrid evolution to numeric weights is architecturally permitted per [[concept-non-constraining|J3]].
- **No `contextual` weights yet assigned.** The fourth strength level exists in the enum but has not been used in any of the 70 assignments. It may be appropriate for relationships that vary significantly by domain instantiation.

---

## Related Documents

- [[ontara-ref-weighted-relationship-directionality-definition|Directionality Definition]] — semantics of directed edges
- [[concept-weighted-relationships|B14]] — register entry for weighted relationships
- [[ontara-stage-3-plan-phase-4-implementation-2026-03-21|Phase 4 Implementation Plan]] — the plan that governs this work
- [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]] — E001 (graph visualisation), E008 (configuration table view)
- [[ontara-ref-master-register-design-concepts-tiered-2026-03-20|Master Register]] — governing principles and concept inventory

---

*Reference document prepared Session 54, 21 March 2026.*
