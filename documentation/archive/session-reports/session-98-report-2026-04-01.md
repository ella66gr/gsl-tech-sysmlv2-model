---
tags:
  - session-report
date: 2026-04-01
status: current
session: 98
---
# Session 98 Report — 1 April 2026
> `= this.file.path`

**Session type:** Discussion / Implementation design
**Focus:** `@BfoType` metadata definition and BFO mapping table — the first concrete application of BFO categories to the BMM vocabulary.

---

## Summary

Session 98 completed Priority A from the [[session-97-report-2026-04-01|Session 97]] forward plan: designing the `@BfoType` metadata definition and producing the complete BFO mapping table for all 34 annotated BMM elements. This is the bridge between "BFO is mandatory" (decided Session 73, twenty-five sessions ago) and the [[ontara-discussion-knowledge-graph-architecture-2026-04-01|knowledge graph]] implementation — each BMM `part def` now has a specified BFO category and mid-level ontology parent.

Two deliverables were produced:

1. **Discussion paper** ([[ontara-discussion-bfo-type-mapping-2026-04-01|ontara-discussion-bfo-type-mapping-2026-04-01.md]]) — the `@BfoType` metadata def design, BFO category primer, complete mapping table with rationale for all 34 elements, six mapping principles, and analysis of unmapped elements.

2. **Claude Code instruction document** (`session-98-code-instructions-bfotype-annotations.md`) — step-by-step instructions for applying the annotations: add the metadata def to `Foundation::MetadataLibrary`, then insert 34 `@BfoType` annotations into `business-model.sysml` in the correct annotation ordering position.

The [[ontara-ref-strategic-snapshot|strategic snapshot]] refresh (Priority A secondary goal) was not reached due to context constraints. It remains due — now 5 sessions stale.

---

## Key Design Decisions

### D1: `@BfoType` metadata def — three String attributes

Three attributes: `bfoClass` (BFO 2020 class name), `midLevelClass` (CCO/IAO/OGMS class in `prefix:ClassName` format), `mappingNotes` (brief rationale). All String-typed — the BFO and mid-level class inventories are large and externally governed; enum defs would duplicate the OWL hierarchies. Validation happens at pipeline Stage 4 against loaded OWL ontologies.

### D2: Annotation ordering — `@BfoType` after `@CatalogueTag`

Updated ordering: `@CatalogueTag → @BfoType → @UserFacing → @PurposiveDescription → @Comprehension → @WeightedRelationship(s)`. `@BfoType` is a classification annotation (what an element *is* ontologically), so it belongs with `@CatalogueTag` (what an element is in BMM structural terms).

### D3: Dominant mapping pattern — GenericallyDependentContinuant

27 of 34 elements map to BFO:GenericallyDependentContinuant. This is expected and correct: the BMM describes the structural logic of a service business — plans, specifications, records, claims, relationships. These are information-level entities that depend on bearers but can migrate between them. Four elements map to Role (ServiceSubject, ServiceParticipant, Channel, ResourceInstance), one to Disposition (Capability).

### D4: Six elements need Ontara domain ontology classes

ServiceSubject, ServiceParticipant, StakeholderRelationship, CommunityRelationship have no established mid-level ontology parent. CustomerSegment and Capability have imperfect mid-level mappings. These are candidates for `ontara:` namespace classes in the domain ontology layer, as anticipated by the ontology stack architecture (B19).

### D5: BusinessScenarios `part def`s deferred

The 11 BusinessScenarios `part def`s and StrategicObjective `requirement def` are deferred from `@BfoType` annotation. They are projection mechanics / computational infrastructure, not domain-semantic BMM vocabulary. They will receive annotations when the mapping pipeline reaches them.

---

## Mapping Principles Established

Six principles govern the BFO mapping:

1. **Map the `part def`, not its instances.** The `@BfoType` annotation applies to the meta model concept (structural template), not the demonstrator instances.
2. **Domain-semantic, not notation-semantic.** Consistent with [[ontara-discussion-knowledge-graph-architecture-2026-04-01|Session 97]] D6.
3. **Most BMM `part def`s are GenericallyDependentContinuant.** Expected for an information-level meta model.
4. **Roles are extrinsic.** [[concept-service-subject|ServiceSubject]], [[concept-service-participant|ServiceParticipant]], Channel, ResourceInstance — identity depends on context, not intrinsic nature.
5. **PlanSpecification vs InformationContentEntity.** PlanSpecification governs future action; InformationContentEntity records or characterises.
6. **Ontara domain classes needed.** Six concepts confirm the need for an `ontara:` namespace layer.

---

## Register Concepts Exercised

### Tier 1

- [[principle-model-generates-everything|A3]] (model generates everything) — ontological grounding made explicit at the SysML source
- [[principle-two-meta-model-distinction|A4]] (two meta model distinction) — mapping scoped to BMM; SMM deferred
- [[principle-discipline-as-load-bearing-structure|A9]] (discipline as load-bearing structure) — annotation convention and ordering rule
- [[principle-intrinsic-self-knowledge|A10]] (intrinsic self-knowledge) — BFO grounding declared on the element itself
- [[concept-co-evolution|J2]] (co-evolution) — `@BfoType` creates model content the pipeline will consume
- [[concept-non-constraining|J3]] (non-constraining) — String attributes avoid constraining the ontology vocabulary

### Tier 2

- [[ontara-ref-master-register|B18]] (BFO — mandatory) — first concrete application of BFO categories to BMM
- [[ontara-ref-master-register|B19]] (ontology stack) — mid-level mappings to CCO, IAO established; need for `ontara:` layer confirmed
- [[concept-knowledge-graph|B22]] (knowledge graph as canonical store) — mapping table feeds the domain graph
- [[ontara-ref-master-register|B23]] (OWL 2 DL as mandatory) — annotation values will be validated against loaded OWL
- [[ontara-ref-master-register|B24]] (mapping ontology) — `@BfoType` is the SysML-side input to the correspondence graph

---

## Emergent Ideas

No new emergent ideas captured this session. The observation about six elements needing Ontara domain ontology classes (D4) is anticipated by B19 and does not constitute a new architectural idea — it confirms an existing commitment.

---

## Deliverables

| Deliverable | Filename | Vault location |
|---|---|---|
| Discussion paper: @BfoType mapping | `ontara-discussion-bfo-type-mapping-2026-04-01.md` | `05 Ontara Exploratory & Discussion Papers/Knowledge & Platform Infrastructure/` |
| Code instructions: apply annotations | `session-98-code-instructions-bfotype-annotations.md` | `02 Ontara Platform Development/Ontara Session Reports, Prep & Handover/Sessions 91-100/` |
| Session report | `session-98-report-2026-04-01.md` | `02 Ontara Platform Development/Ontara Session Reports, Prep & Handover/Sessions 91-100/` |
| Preparation note | `session-99-preparation-note.md` | `02 Ontara Platform Development/Ontara Session Reports, Prep & Handover/Sessions 91-100/` |

---

*Session 98 report written 1 April 2026. The first concrete application of BFO categories to the BMM vocabulary — 34 elements mapped, 6 mapping principles established, annotation convention updated.*
