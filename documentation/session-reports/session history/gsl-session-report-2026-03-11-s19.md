# Session Report — 11 March 2026 (Session 19)

**Project:** GenderSense (GSL)
**Focus:** Business Meta Model Implementation — Phase 7 (Governance Mapping and Strategy Elaboration)
**Duration:** Single session
**Outcome:** Phase 7 complete. Formal cross-references established between business model, strategy, and governance layers. StrategicObjective restructured to requirement def. Significant `satisfy` limitation discovered and documented.

---

## 1. Objectives and Outcomes

| Objective | Outcome |
|---|---|
| Stage 1 — Syntax verification (ref multiplicity, satisfy) | ✅ Complete — `ref x : Type[0..*]` across packages verified. `satisfy by partUsage` fails (significant finding). |
| Stage 2 — StrategicObjective restructuring | ✅ Complete — part def → requirement def with typed ref to ScenarioDefinition |
| Stage 3 — Formal ref additions | ✅ Complete — ScenarioDefinition, Capability, ResourceConstraint all upgraded |
| Stage 4 — Satisfy + Enterprise enrichment | ✅ Complete with design change — ObjectiveCapabilityMapping replaces satisfy; Enterprise::Strategy enriched |
| Stage 5 — Coffee shop demonstrator | ✅ Complete — StrategicObjective requirement + ObjectiveCapabilityMapping |
| Stage 6 — Documentation and commit | ✅ This report + syntax reference v3.11 |

---

## 2. Primary Architectural Finding: `satisfy` Limitation

**`satisfy requirement X by partUsage` does not work in Syside 0.8.5.** The `by` target must conform to the requirement's subject type. When the target is a `part` usage (e.g., a Capability), Syside reports `type-error: partUsage does not conform to ScalarValues::String`. This persists even with an untyped subject.

The verified `satisfy` pattern in the codebase (Enterprise::Regulation → Knowledge::ConstraintLibrary) works because the `by` target is a `constraint` usage, which has a different conformance relationship with requirement subjects.

**Implication:** `satisfy` is designed for requirement→constraint traceability, not requirement→capability (part) traceability. This is a fundamental Syside limitation, not a syntax error.

**Resolution:** Objective→Capability traceability is expressed via `ObjectiveCapabilityMapping` — a dedicated part def with typed `ref supportingCapabilities : Capability[1..*]`. This provides structural, queryable traceability that generators can follow, while keeping StrategicObjective as a `requirement def` for formal correctness and future use with constraint-typed satisfiers.

**Additional `satisfy` findings:**

- `satisfy requirement X` (bare form) creates a local usage named `X` that triggers `namespace-distinguishability` shadow warning.
- `satisfy requirement localName : reqUsage` (typed by usage, not def) triggers `usage-feature-typing` warning — "will be upgraded to error in Syside v0.9".
- `satisfy requirement localName : ReqDef` (typed by classifier) avoids the typing warning but the `by partUsage` type-error persists.

---

## 3. Files Created

| File | Purpose |
|---|---|
| `model/syntax-tests/test-ref-multiplicity-cross-package.sysml` | Syntax verification — ref with multiplicity across packages (all tests pass) |
| `model/syntax-tests/test-satisfy-business-requirement.sysml.failed` | Syntax verification — satisfy by part usage (documented failure) |

---

## 4. Files Modified

| File | Changes |
|---|---|
| `model/business-strategy.sysml` | StrategicObjective: `part def` → `requirement def`. Four usages: `part` → `requirement`. Added `subject`, `ref relatedScenarios : ScenarioDefinition[0..*]`. Removed `relatedCapabilities` attribute. Added `BusinessScenarios::ScenarioDefinition` import. |
| `model/business-scenarios.sysml` | ScenarioDefinition: added `ref activeServiceOfferings : ServiceOffering[0..*]`, renamed `activeOfferings` to `activeOfferingsDescription`. Added `BusinessModel::ServiceConcept::ServiceOffering` import. Two scenario usages updated. |
| `model/business-model.sysml` | Capability: added `ref enabledServiceOfferings : ServiceConcept::ServiceOffering[0..*]`, renamed `enabledOfferings` to `enabledOfferingsDescription`. ResourceConstraint: renamed `regulatorySource` to `regulatorySourceDescription`. Added `ObjectiveCapabilityMapping` part def with four GSL instantiations. All capability and constraint usages updated. |
| `model/enterprise.sysml` | Strategy: renamed `BusinessModel` part def to `StrategicContext` (avoids package name collision). Partnership: added `strategicObjectiveRef`. Added `gslStrategicContext` instantiation. Doc blocks updated. |
| `exercises/coffeeshop-demonstrator/model/coffeeshop-scenarios.sysml` | Three ScenarioDefinition usages updated (`activeOfferingsDescription`). Added `kioskProfitability` requirement (StrategicObjective) and `kioskProfitabilityMapping` (ObjectiveCapabilityMapping). Added `BusinessModel::ResourcePlanning::ObjectiveCapabilityMapping` import. |
| `exercises/coffeeshop-demonstrator/model/coffeeshop-resource-financial.sysml` | Capability and ResourceConstraint usages updated for renamed attributes. |

---

## 5. Syntax Findings (v3.11)

### New verified patterns

| Pattern | Status | Detail |
|---|---|---|
| `ref x : Type[0..*]` across packages | ✅ Verified | ref with multiplicity to a cross-package part def. Tested with `[0..*]` and `[1..*]`. |
| `ref` inside `requirement def` | ✅ Verified | ref attributes within requirement definitions parse correctly. |
| `requirement def` with business-domain attributes | ✅ Verified | Non-clinical requirement defs with arbitrary typed attributes, including refs. |
| `requirement` usage with `:>>` redefinitions | ✅ Verified | Requirement usages (not just part usages) support `:>>` attribute redefinitions. |
| Multiple `satisfy` for same requirement (with naming) | ⚠️ Parses but type-error | The syntax parses, but `by partUsage` triggers type-error. Works only for constraint targets. |

### New traps

| Trap | Error | Detail |
|---|---|---|
| `satisfy requirement X by partUsage` | `type-error` | Part usages do not conform to requirement subject type. Use only with constraint usages. |
| `satisfy requirement X` (bare, imported X) | `namespace-distinguishability` | Creates local usage shadowing the import. Use named form or avoid for part targets entirely. |
| `satisfy requirement localName : reqUsage` (typed by usage) | `usage-feature-typing` | Usages should only be typed by Classifiers. Will become error in Syside v0.9. |
| `Enterprise::Strategy::BusinessModel` name collision | Ambiguity risk | Part def named `BusinessModel` collides with top-level `BusinessModel` package. Renamed to `StrategicContext`. |

### Safe attribute names confirmed

- `strategicObjectiveRef` — safe
- `strategyRef` — safe
- `regulatorySourceDescription` — safe
- `activeOfferingsDescription` — safe
- `enabledOfferingsDescription` — safe
- `activeServiceOfferings` — safe
- `enabledServiceOfferings` — safe
- `supportingCapabilities` — safe
- `objectiveRef` — safe (`objective` is a SysML keyword, but compound name `objectiveRef` is safe)
- `contextName` — safe
- `currentVariant` — safe (`variant` is a SysML keyword, but `currentVariant` is safe)
- `governanceNotes` — safe

---

## 6. Design Decisions

### StrategicObjective as requirement def (not part def)

Ella's decision: preserve formal correctness for future predictability. Even though `satisfy` doesn't currently work with part-usage targets, having StrategicObjective as a `requirement def` means it is structurally available for future `satisfy` relationships to constraint usages (e.g., constraint defs that formally evaluate whether success criteria are met).

### ObjectiveCapabilityMapping (not satisfy)

The traceability from objectives to capabilities uses a dedicated mapping part def with `ref supportingCapabilities : Capability[1..*]`, rather than `satisfy` relationships. This provides typed, structural, queryable traceability while respecting the Syside limitation. Naming convention (`patientCohortMapping`, `sharedCareMapping`, etc.) provides the human-readable link.

### Enterprise::Strategy stays import-free

Enterprise does not import from Business* packages. Cross-references are via String attributes and doc blocks. This preserves the layering principle: the outer ring (Enterprise) does not depend on inner-ring packages. The enriched `StrategicContext` part def provides the enterprise-level anchor; detailed strategy lives in BusinessStrategy.

### ResourceConstraint formal ref deferred

A `ref` from ResourceConstraint to Enterprise::Regulation requirement defs was planned but deferred. The target is a `requirement def`, and the syntax for `ref` pointing to a requirement def (as opposed to a part def) needs separate investigation. The string attribute `regulatorySourceDescription` remains.

---

## 7. Dependency Direction After Phase 7

```
BusinessStrategy
    → BusinessScenarios::ScenarioDefinition    (ref in StrategicObjective)

BusinessScenarios
    → BusinessModel::ServiceConcept::ServiceOffering  (ref in ScenarioDefinition)
    → Knowledge::LogicEngine::*                        (existing, Phase 6B)
    → Foundation::CommonTypes::*                       (existing, Phase 6B)

BusinessModel::ResourcePlanning
    (no imports from BusinessStrategy — satisfy removed)

Enterprise
    (no imports from Business* packages — outer ring clean)

CoffeeshopScenarios
    → BusinessStrategy::*                              (existing)
    → BusinessModel::ResourcePlanning::ObjectiveCapabilityMapping  (new)
```

---

## 8. Git Commits

| Commit | Content |
|---|---|
| Stage 1 | Syntax tests — ref multiplicity (passes) and satisfy business requirement (documented failure) |
| Stage 2 | StrategicObjective restructuring — part def → requirement def, four usages migrated |
| Stage 3 | Formal ref additions — ScenarioDefinition, Capability, ResourceConstraint |
| Stage 4 | ObjectiveCapabilityMapping + Enterprise::Strategy enrichment |
| Stage 5 | Coffee shop demonstrator — StrategicObjective requirement + mapping |

---

## 9. Coffee Shop Demonstrator Extension

**Capability demonstrated:** Governance/strategy cross-references in a non-clinical domain.

**What was built:** One StrategicObjective requirement (`kioskProfitability` — reach profitability within 6 months) and one ObjectiveCapabilityMapping linking it to the kiosk's drink-serving capability.

**What was learned:** The `requirement def` StrategicObjective works identically for a coffee shop business objective as for a clinical service objective. The ObjectiveCapabilityMapping pattern is proportionate for the toy domain — it doesn't feel over-engineered.

**Clinical implementation confidence:** High. The formal cross-reference patterns (typed refs, requirement defs, mapping part defs) are domain-agnostic. The `satisfy` limitation is a Syside constraint, not an architectural one — the mapping pattern provides equivalent structural traceability.

---

## 10. Phase 7 Success Criteria Assessment

| Criterion | Result |
|---|---|
| StrategicObjective is a `requirement def` | ✅ With `satisfy` traceability via mapping pattern instead |
| At least one formal `ref` replaces a string reference | ✅ Three: ScenarioDefinition→ServiceOffering, Capability→ServiceOffering, StrategicObjective→ScenarioDefinition |
| Enterprise::Strategy enriched | ✅ StrategicContext part def + gslStrategicContext instantiation |
| No circular import dependencies | ✅ Dependency direction preserved |
| All model files parse clean | ✅ All production files clean |
| Syntax findings documented | ✅ v3.11 — ref multiplicity verified, satisfy limitation documented |
| Coffee shop parity | ✅ StrategicObjective + ObjectiveCapabilityMapping in non-clinical domain |

**Phase 7 is complete. The Business Meta Model implementation plan (Phases 1–7) is complete.**

---

## 11. Deferred Items

### Items completed in this session

- ~~Formal `ref` from ScenarioDefinition to ServiceOffering~~ — Done (Phase 7)
- ~~Formal `satisfy` from StrategicObjective to Capability~~ — Replaced by ObjectiveCapabilityMapping (satisfy limitation)
- ~~Governance cross-references (BusinessStrategy → Enterprise::Strategy)~~ — Done (Phase 7)

### Items remaining (post-Phase 7)

- Formal `ref` from ResourceConstraint to Enterprise::Regulation requirement defs — deferred (needs `ref` to requirement def investigation)
- Variant C elaboration — deferred (beyond Phase 7 scope)
- `activePatientsTotal` / `actualPatientCount` domain-specific naming — standing item
- Sensitivity "dominant" text formatting — minor
- Coffee shop subscription scenario not wired into projection engine — low priority

### New potential workstreams

- Coffee shop Knowledge Layer increments (constraint evaluation, decision table, system self-assessment) — standing items from demonstrator integration plan
- Broader model review with real parameter values — informed by Phase 5/6 projection comparison
- System Meta Model extraction — contingent on model stability across two clinical pathways

---

## 12. Recommendation for Next Session

The Business Meta Model implementation plan (Phases 1–7) is now complete. Three natural next directions:

**Option A — Coffee Shop Knowledge Layer Increments.** The three increments from the demonstrator integration plan (constraint evaluation at a pathway step, decision table for drink routing, system self-assessment) have not yet been executed. These would exercise the Knowledge layer in a running system and validate the generators are domain-agnostic.

**Option B — Second Clinical Pathway.** Model a second clinical pathway (e.g., ongoing monitoring, shared care transition) to test whether the architecture generalises across pathways. This would also trigger the cross-pathway rule sharing work deferred from the Knowledge Layer.

**Option C — Model Consolidation Review.** Step back and review the complete model across all packages. The model has grown substantially through Phases 1–7 and the Knowledge Layer elaboration. A consolidation review would identify naming inconsistencies, doc block gaps, and opportunities for structural simplification.

The coffee shop Knowledge Layer increments (Option A) are probably the highest-value next step — they exercise running code against the architecture, which is a different kind of validation from the structural modelling work in Phases 1–7.

---

*Session 19 report. Phase 7 of the Business Meta Model implementation complete. Business Meta Model plan (Phases 1–7) complete.*
