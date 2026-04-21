# Ontara — Stage 3 Phase 4 Implementation Plan: Comprehension Population

**Date:** 21 March 2026 (Session 52)
**Prepared by:** Claude (Opus 4.6), in discussion with Ella Green
**Status:** For review and agreement
**Parent plan:** [[ontara-stage-3-plan-2026-03-19|Stage 3 Plan]] (Phase 4 replaces the original Phase 4 scope — see §1.1)
**Prerequisite:** Phase 3 complete (Steps 1–4, Sessions 49–51)
**Informed by:** [[session-52-preparation-note|Session 52 preparation note]], [[ontara-master-register-design-concepts-tiered-2026-03-20|Tiered Master Register]], [[ontara-development-workflow-guide-2026-03-17|Workflow Guide]]

---

## 1. Objective

Phase 4 **populates** the comprehension architecture established in Phase 3. Where Phase 3 proved the pattern on a single element (ActivityType), Phase 4 extends it across the full BMM vocabulary: `@Comprehension` traversal schemas on all 26 elements, `@WeightedRelationship` annotations on elements beyond the pilot, and resolution of the carried-forward "service subject ≠ customer" meta model question.

By the end of Phase 4, the Ontara Console glossary should provide intrinsic comprehension content — structural facts, domain instantiations, related concepts, and weighted relationships — for every BMM element, not just the pilot.

### 1.1 Relationship to the Original Stage 3 Plan

The original Stage 3 plan (Session 43) defined Phase 4 as "Modelled Views — Experimentation". The actual Phase 3 evolved far beyond the original Phase 3 scope ("Expand @UserFacing Coverage") into a four-step comprehension architecture workstream (Sessions 49–51) that introduced `@PurposiveDescription`, `@Comprehension`, `@WeightedRelationship`, `RelationshipStrength`, and the intrinsic self-knowledge principle (A10).

This new Phase 4 is the natural next step from that evolved Phase 3. The original Phases 4–7 (modelled views, pattern graph, BSMM extraction, assembly workspace design) remain valid work but are deferred to a new Stage 4 (see §8).

---

## 2. Design Principles

| Principle | Phase 4 relevance |
|---|---|
| [[concept-intrinsic-self-knowledge\|A10]] (intrinsic self-knowledge) | Bulk `@Comprehension` population means every element can explain its own structure |
| [[concept-unity-principle\|A11]] (unity principle) | Expanding weights ensures the relationship model serves comprehension, and later reasoning/governance/assembly |
| [[concept-co-evolution\|J2]] (co-evolution) | Generator and glossary must be re-run after each model change to verify the pipeline |
| [[concept-non-constraining\|J3]] (non-constraining) | Weight assignments are ordinal (experimentation stage, J12); they don't foreclose hybrid/numeric evolution |
| [[concept-model-generates-everything\|A3]] (model generates everything) | All comprehension content derived from model annotations, not hardcoded in the console |
| [[concept-design-decision-lifecycle\|J12]] (design decision lifecycle) | B14 (weighted relationships) remains at experimentation stage; bulk application tests the pattern at scale |

---

## 3. Phasing

Phase 4 has three steps with a clear dependency chain.

### Step 1: Bulk `@Comprehension` Application (~1 session)

**What:** Apply `@Comprehension` metadata annotations to the 25 remaining BMM elements in `business-model.sysml`. ActivityType already has one (Session 50). Then run the generator, copy JSON to console, and verify the glossary.

**Why:** The traversal schema is proven on ActivityType. The remaining elements need the same annotation so the generator can discover and surface their structural facts (attributes, enum values, domain instantiations, related concepts) in the glossary.

**Detailed work:**

1. **Claude Code** applies 25 `@Comprehension` blocks following the instructions prepared in Session 52 (`claude-code-instructions-comprehension-bulk-s52.md`). The `surfaceEnumValues` flag is `true` for 4 elements (ActivityRecord, ActivityBudget, ActivityGranularity, PricingModel) and `false` for the other 21.

2. **Ella validates** in Syside that the annotated model parses cleanly.

3. **Run the generator:**
   ```bash
   cd ~/Developer/gsl-tech/gsl-sysml-model
   python scripts/gen_model_introspection.py --save --pretty
   cp generated/ontara/model-introspection.json console/static/data/model-introspection.json
   ```

4. **Verify in the console:**
   - Every glossary entry should now show intrinsic comprehension content (attributes, domain instantiations, related concepts).
   - Elements with enum-typed attributes should show the enum values.
   - The comprehension coverage stat should read 26/26 (100%).

5. **Fix any issues** in the generator or console display that emerge from the bulk application.

**Deliverables:**
- 25 new `@Comprehension` annotations in `business-model.sysml`
- Updated `model-introspection.json` (both generated and console copies)
- Verified glossary display for all 26 elements

**Best suited to:**
- **Claude Code:** The 25 annotation insertions (instructions already prepared).
- **Claude Chat:** Generator troubleshooting, console fixes if needed.
- **Ella:** Syside validation.

**Git checkpoint:**
```bash
cd ~/Developer/gsl-tech/gsl-sysml-model

git add model/business-model.sysml
git add generated/ontara/model-introspection.json
git add console/static/data/model-introspection.json

git commit -m "S52: Phase 4 Step 1 — @Comprehension annotations on all 26 BMM elements (25 new + 1 existing). surfaceEnumValues=true for 4 enum-typed elements. Full comprehension coverage."

git push
```

---

### Step 2: Weight Population (~2–3 sessions)

**What:** Design and apply `@WeightedRelationship` annotations to BMM elements beyond the ActivityType pilot. Work in batches: discuss weights for a group of elements, agree strengths and rationale, apply via Claude Code, regenerate, verify glossary display.

**Why:** The pilot (Session 51) established 6 weights on ActivityType. The glossary shows them with warm-to-cool dot bars. But one element with weights doesn't demonstrate that the weight model generalises. Applying weights to additional elements validates B14 at scale, enriches the glossary, and builds the relationship data that the unity principle (A11) says should eventually inform reasoning, governance, and assembly.

**Approach — batched by BMM concern:**

The weight population is not purely mechanical — each element's relationships require architectural judgement about what is structurally related and how strongly. The work therefore alternates between discussion (agree weights) and application (Claude Code inserts annotations).

**Batch 1: ServiceConcept** (7 elements)
- ServiceOffering is the natural centre — it connects to ActivityType, ResourceType, PricingModel, Channel, CustomerSegment, CatalogueEntry.
- ValueProposition connects to CustomerSegment, ServiceOffering, DifferentiationClaim.
- CustomerSegment connects to Channel, ValueProposition, ServiceOffering.
- Channel, DifferentiationClaim, CatalogueEntry, ExternalReference: fewer relationships, simpler weight sets.

**Batch 2: ResourcePlanning** (7 elements)
- ResourceType connects to ResourceInstance, Capability, ActivityType, ResourceConstraint, CostDriver.
- Capability connects to ServiceOffering, ResourceType, ObjectiveCapabilityMapping.
- CapacityModel, ResourceConstraint, InventoryRecord, ObjectiveCapabilityMapping: supporting concepts.

**Batch 3: FinancialPlanning** (5 elements)
- PricingModel connects to ServiceOffering, RevenueStream, UnitEconomics.
- CostDriver connects to ResourceType, ActivityCostAllocation, UnitEconomics.
- RevenueStream, UnitEconomics, FinancialProjection: aggregating concepts.

**Batch 4: ActivityModel remainder + GovernanceMapping** (5 elements)
- ActivityRecord, ActivityBudget, ActivityGranularity, ActivityCostAllocation already have weight targets from ActivityType's outgoing weights — now apply the reverse direction.
- GovernanceRequirement and AuditEvidenceRecord — governance traceability relationships.

**For each batch:**
1. **Discussion** (Claude Chat + Ella): For each element, propose candidate targets and strengths. Ella reviews and adjusts. Document the rationale.
2. **Application** (Claude Code): Insert `@WeightedRelationship` annotations following the established pattern (Position A, after `@Comprehension`, multiple per element).
3. **Validation** (Ella): Syside parse check.
4. **Generation + verification** (Claude Chat): Run generator, check glossary display.

**Known limitation to acknowledge:** Cross-package relationships (e.g. ResourceType in ResourcePlanning referenced from ActivityType in ActivityModel) currently don't surface in the glossary because traversal uses package-proximity heuristics. The weights exist in the model — they'll appear when O25 (typed-ref migration, Phase 5) is completed. This is accepted and documented.

**Deliverables:**
- `@WeightedRelationship` annotations on 20+ elements (target: every element with 2+ meaningful relationships)
- Weight rationale captured in session reports
- Updated `model-introspection.json`
- Verified glossary display with dot bars for all weighted elements

**Estimated weight count:** ActivityType has 6 weights. Most elements will have 2–5 relationships. Estimate: 60–80 total weight annotations across the BMM.

**Best suited to:**
- **Claude Chat:** Design discussion for each batch — proposing targets, strengths, rationale. Generator and console verification.
- **Claude Code:** Mechanical annotation insertion once weights are agreed. Instructions per batch: "In `model/business-model.sysml`, add the following `@WeightedRelationship` annotations to [element], in Position A after the `@Comprehension` block: [list of target/strength/rationale triplets]."
- **Ella:** Review weight proposals, Syside validation.

**Git checkpoint** (one per batch):
```bash
git add model/business-model.sysml
git add generated/ontara/model-introspection.json
git add console/static/data/model-introspection.json

git commit -m "S5N: Phase 4 Step 2, Batch N — @WeightedRelationship on [elements]. [count] new weight annotations."

git push
```

---

### Step 3: Service Subject ≠ Customer Resolution (~1 session)

**What:** Resolve the carried-forward discussion from Session 44: in Paws, the service subject (the dog) is not the customer (the owner). Determine whether the BMM needs structural change to accommodate this, implement any agreed changes, and close the deferred item.

**Why:** This is the oldest unresolved meta model question. If the BMM implicitly assumes customer = service recipient, that's a conceptual gap that applies to healthcare (patient vs. carer, patient vs. commissioner) as well as to Paws and potentially Suds (the person dropping off laundry vs. the owner of the garments). Resolving it now, while we're actively working on BMM annotations, means any structural change can be reflected in the comprehension metadata.

**Possible outcomes:**

**(a) No structural change needed.** The existing vocabulary already accommodates this: CustomerSegment describes who pays, ServiceOffering describes what's delivered, and the "recipient" is implicit in the domain instantiation. Document the reasoning and close the item.

**(b) New BMM concept.** Introduce a `ServiceSubject` or `ServiceRecipient` `part def` — a lightweight concept that records who/what the service is actually performed on, distinct from CustomerSegment. Apply `@CatalogueTag`, `@UserFacing`, `@PurposiveDescription`, `@Comprehension`, and `@WeightedRelationship`. Update Paws (and optionally Suds/Cafe) instantiations.

**(c) Attribute-level refinement.** Add attributes to existing `part def`s (e.g. `serviceSubjectType : String` on ServiceOffering) rather than introducing a new concept. Lighter touch, but potentially less clean.

**Work sequence:**
1. **Discussion** (Claude Chat + Ella): Review the observation, assess implications across domains, decide between options (a), (b), (c).
2. **Implementation** (if (b) or (c)): Model change, annotation, generator run, console verification.
3. **Documentation:** Session report captures the decision and rationale. Master register updated — either close the deferred item or add a new concept.

**Deliverables:**
- Decision documented in session report
- Model changes (if any) with full annotation stack
- Deferred item in register either closed or converted to a tracked concept
- Updated `model-introspection.json` (if model changed)

**Best suited to:**
- **Claude Chat:** Discussion and analysis. Implementation if needed.
- **Ella:** Design decision authority.

---

## 4. Dependencies and Ordering

```
Step 1 (@Comprehension bulk) ──→ Step 2 (Weight population) ──→ Step 3 (Service subject ≠ customer)
```

Step 1 must come first — the generator needs `@Comprehension` annotations in place before weight annotations make full sense in the glossary (the dot bar display is part of the comprehension content).

Step 2 is the main body of work. It depends on Step 1 being complete.

Step 3 is logically independent but benefits from being last: if it introduces a new concept, that concept can receive the full annotation stack (`@CatalogueTag` through `@WeightedRelationship`) in one pass, and the weight discussion can reference the relationships already established in Step 2.

---

## 5. Estimated Effort

| Step | Estimate |
|---|---|
| Step 1: Bulk `@Comprehension` | ~1 session (mostly Claude Code + generator run) |
| Step 2: Weight population | ~2–3 sessions (4 discussion+application batches) |
| Step 3: Service subject resolution | ~1 session (discussion + optional implementation) |
| **Total** | **~4–5 sessions** |

---

## 6. Exit Criteria

Phase 4 is complete when:

- [ ] All 26 BMM elements have `@Comprehension` annotations (100% coverage)
- [ ] `@WeightedRelationship` annotations applied to 20+ elements with agreed strengths
- [ ] Glossary displays intrinsic comprehension content for all 26 elements
- [ ] Glossary displays weight-prioritised related concepts (dot bars) for all weighted elements
- [ ] Service subject ≠ customer question resolved and documented
- [ ] Generator and console data files updated and in sync
- [ ] Master register updated (O20, O21 updated; any new concepts added; deferred item resolved)
- [ ] Session reports written for each session
- [ ] Git commits for each step/batch

---

## 7. Register Concepts Exercised

| Concept | How exercised |
|---|---|
| [[concept-intrinsic-self-knowledge\|A10]] (intrinsic self-knowledge) | Full BMM comprehension coverage |
| [[concept-unity-principle\|A11]] (unity principle) | Weight model generalised beyond pilot element |
| [[concept-weighted-relationships\|B14]] (weighted relationships) | Scaled from 6 to ~70+ weight annotations |
| [[concept-co-evolution\|J2]] (co-evolution) | Model annotations → generator → console at every step |
| [[concept-non-constraining\|J3]] (non-constraining) | Ordinal weights; experimentation stage (J12) |
| [[concept-model-generates-everything\|A3]] (model generates everything) | All comprehension content from model, not console logic |
| [[concept-cross-domain-validation\|J1]] (cross-domain validation) | Service subject question surfaces from Paws cross-domain work |
| [[concept-design-decision-lifecycle\|J12]] (design decision lifecycle) | B14 at experimentation; bulk application tests the pattern at scale |

**At risk of neglect (monitor):**

| Concept | Risk |
|---|---|
| B12 (horizontal mappings) | Not directly addressed in Phase 4. Monitor. |
| O2 (BSMM extraction) | Remains deferred. Phase 4 is BMM-focused. |
| O3 (second clinical pathway) | Not Phase 4 scope. |

---

## 8. Relationship to Stage 4

Phase 4 completes the comprehension population. **Phase 5** (O25: string-to-typed-ref migration) is the natural next step — it unlocks cross-package weight traversal and makes the model more formally navigable.

After Phase 5, Stage 3 will have delivered:

| Phase | Deliverable | Status |
|---|---|---|
| Phase 1 | Paws demonstrator | Complete (S44) |
| Phase 2 | Glossary view | Complete (S45) |
| Phase 3 | Comprehension metadata (4 steps) | Complete (S49–51) |
| Phase 4 | Comprehension population (3 steps) | This plan |
| Phase 5 | Typed-ref migration (O25) | Future plan |

**Stage 4** will address the original Stage 3 Phases 4–7 (modelled views, pattern graph, BSMM extraction, assembly workspace design) which are about structural navigation, presentation, and construction — a different concern from comprehension. The comprehension architecture (Stage 3) provides the foundation that Stage 4's features will lean on.

A revised high-level plan recognising this Stage 3/Stage 4 split should be produced at the next strategic review or at the start of Stage 4 planning.

---

## 9. Claude Code Task Summary

| Step | Claude Code instruction | Scope |
|---|---|---|
| Step 1 | `claude-code-instructions-comprehension-bulk-s52.md` (already prepared) | 25 insertions in `business-model.sysml` |
| Step 2, Batch 1 | To be prepared after weight discussion | ~15–20 insertions (ServiceConcept elements) |
| Step 2, Batch 2 | To be prepared after weight discussion | ~15–20 insertions (ResourcePlanning elements) |
| Step 2, Batch 3 | To be prepared after weight discussion | ~10–15 insertions (FinancialPlanning elements) |
| Step 2, Batch 4 | To be prepared after weight discussion | ~10–15 insertions (ActivityModel remainder + GovernanceMapping) |
| Step 3 | If structural change agreed | 1 new element + annotations |

---

*Phase 4 implementation plan prepared 21 March 2026 (Session 52).*
