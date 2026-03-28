# Session 81 Report

**Date:** 28 March 2026
**Session type:** Implementation
**Focus:** StakeholderModel SysML implementation (Priority A)

---

## Summary

Session 81 completed the StakeholderModel SysML implementation — the primary work item carried forward from Sessions 79 and 80. This is the first new BMM concern since [[concept-governance-first-class|GovernanceMapping]] (Session 42) and the largest single model addition since the comprehension metadata population (Sessions 49–55).

The work was prepared in Chat (instruction set design) and executed in Code (mechanical SysML writing). The instruction set specified every `part def`, attribute, annotation, enum value, and demonstrator instantiation verbatim — Claude Code (Sonnet 4.6) executed it as a transcription task with no architectural judgement required. The instruction set is archived as a container artifact (not vault document).

### Work completed

1. **Three enums in `Foundation::CommonTypes`.**
   - Extended existing `ReferralDirection` enum with `bidirectional` (previously only `inbound`/`outbound`).
   - Added `RelationshipNature` (6 values: regulatory, contractual, professional, advisory, commissioning, peer).
   - Added `DependencyCriticality` (3 values: essential, important, convenient).

2. **StakeholderModel package** in `BusinessModel` with six `part def`s, each carrying the full metadata annotation stack: `@CatalogueTag`, `@UserFacing`, `@PurposiveDescription`, `@Comprehension`, `@WeightedRelationship` (multiple per element).
   - StakeholderRelationship (C7a) — 3 outgoing weights, 10 attributes + 1 typed ref
   - CooperativeArrangement (C7b) — 3 outgoing weights, 8 attributes
   - ReferralPathway (C7c) — 2 outgoing weights, 8 attributes
   - ExternalDependency (C7d) — 3 outgoing weights, 8 attributes
   - CommunityRelationship (C7e) — 2 outgoing weights, 6 attributes
   - ParticipationModel (C7f) — 3 outgoing weights, 7 attributes + 1 typed ref

3. **Two cross-package typed refs** implementing the [[ontara-discussion-stakeholder-model-detailed-design-2026-03-28|Session 78 boundary decisions]]:
   - `StakeholderRelationship.relatedGovernanceRequirements : GovernanceRequirement[0..*]` — links to [[concept-governance-first-class|GovernanceMapping]]
   - `ParticipationModel.relatedServiceOffering : ServiceOffering[0..*]` — links to ServiceConcept

4. **Incoming weight annotation** on existing `GovernanceRequirement` → StakeholderRelationship (moderate).

5. **GSL instantiations** (7 parts): CQC regulatory relationship, ICB commissioning relationship, shared care cooperative arrangement, GP bidirectional referral pathway, specialist outbound referral pathway, pharmaceutical and laboratory dependencies, trans community relationship, shared decision-making participation model.

6. **Cafe instantiations** (6 parts): local authority food safety, landlord relationship, delivery platform partnership, coffee bean dependency, local neighbourhood community, counter ordering participation.

7. **Paws instantiations** (7 parts): animal welfare regulator, insurance relationship, vet partnership, vet referral pathway, grooming product dependency, local dog community, owner consultation participation.

8. **Generator verified clean.** `gen_model_introspection.py` picks up all 6 new elements with correct `bmmConcern = "StakeholderModel"`, 100% `@UserFacing`/`@PurposiveDescription` coverage, cross-domain instantiation counts correct. JSON synced to console.

9. **Syside verification.** All four modified files parse clean in Syside Modeler. Initial indexing delay caused a transient `reference-error` for `StakeholderRelationship` in the Cafe file — resolved on re-index. `dependencyName` (compound of KerML reserved word `dependency`) parses correctly.

10. **`BusinessModel` package doc block** updated from five concerns to six.

### Discovery during preparation

The existing `ReferralDirection` enum in `CommonTypes` already contained `inbound` and `outbound`. The [[ontara-discussion-stakeholder-model-detailed-design-2026-03-28|detailed design paper]] specified a three-value `ReferralDirection` as "new", but the instruction set correctly handled this as an extension rather than a duplicate creation.

---

## Metrics

| Metric | Before | After |
|---|---|---|
| BMM `part def`s (+ `requirement def`s) | 28 (+ 2) | 34 (+ 2) |
| BMM concerns | 5 (+ Activity Awareness) | 6 (+ Activity Awareness) |
| `@UserFacing` coverage | 28/28 | 34/34 |
| `@PurposiveDescription` coverage | 28/28 | 34/34 |
| `@Comprehension` coverage | 28/28 | 34/34 |
| `@WeightedRelationship` annotations | 79 | 96 (+17: 16 outgoing + 1 incoming) |
| Domain instantiations (StakeholderModel) | 0 | 20 (7 GSL + 6 Cafe + 7 Paws) |
| Enums in `CommonTypes` | — | +2 new, +1 extended |

---

## Register Concepts Exercised

### Tier 1 principles

| Principle | How honoured |
|---|---|
| [[principle-model-generates-everything\|A3]] (model generates everything) | All six new elements are SysML `part def`s with full metadata. Generator picks them up automatically. No hand-maintained data structures. |
| [[principle-two-meta-model-distinction\|A4]] (two meta model distinction) | All six elements are BMM concepts with appropriate doc blocks ("business meta model concept"). |
| [[principle-discipline-as-load-bearing-structure\|A9]] (discipline) | Four open questions resolved in Session 78 and treated as binding during implementation. Full metadata parity with existing BMM elements. KerML reserved word check performed. |
| [[principle-intrinsic-self-knowledge\|A10]] (intrinsic self-knowledge) | `@Comprehension` traversal schemas on all six elements. `surfaceEnumValues = true` for elements with typed enum attributes. |
| [[principle-unity-principle\|A11]] (unity principle) | 17 new `@WeightedRelationship` annotations. Same weights inform comprehension, graph, and future simulation. |
| [[concept-co-evolution\|J2]] (co-evolution) | Generator and console pick up new elements automatically. No console code changes required — validates the D9 architecture. |
| [[concept-cross-domain-validation\|J1]] (cross-domain validation) | All six elements instantiated in GSL, Cafe, and Paws. Variation in richness is appropriate and expected. |
| [[concept-non-constraining\|J3]] (non-constraining) | Closed enums extensible via Tailored `:>>` redefinition. Sibling pattern preserves independence. Cross-element weights within StakeholderModel deferred as candidates. |
| [[concept-multi-tenancy\|A13]] (multi-tenancy) | All elements are General — domain-neutral structural patterns. GSL instantiations sit alongside demonstrator instantiations with no structural privilege. |

### Concepts exercised

- [[concept-stakeholder-model|C7]], C7a–C7f — SysML implementation completed (was detailed design)
- [[concept-horizontal-mappings|B12]] (horizontal mappings) — two typed `ref` connections to other concerns
- [[concept-weighted-relationships|B14]] (weighted relationships) — 17 new annotations
- [[concept-general-tailored-decomposition|B11]] (General/Tailored decomposition) — all elements at General level

---

## Carried Forward

- **StakeholderModel cross-element weights (§5.8 of [[ontara-discussion-stakeholder-model-detailed-design-2026-03-28|detailed design paper]]).** Three candidate weights within StakeholderModel (CooperativeArrangement → StakeholderRelationship, ReferralPathway → StakeholderRelationship, ExternalDependency → CooperativeArrangement). Marked "candidates, not commitments" — to be assessed when the elements are exercised in practice.
- **Graph rendering refinements** (viewport fitting, bidirectional edge separation) — Code work, carried forward from Sessions 75–80. Addresses [[ontara-workflow-emergent-ideas-log|E001]].
- **[[ontara-service-business-meta-modelling|Service Business Meta Modelling v2]] revision** — needs a sixth section for StakeholderModel. Significant work — scope before starting.
- **Strategic snapshot refresh** — now 7 sessions stale (last refreshed Session 74). Past the 5-session threshold. Should be scheduled for Session 82.
- **YAML frontmatter standardisation** — convention established Session 80 but not yet applied to existing documents. Incremental as documents are next touched.
- **Vault git commit/push** — due this session (5-session cycle, Session 76 established). Ella to commit and push after placing documents.

---

*Session 81 report written 28 March 2026.*
