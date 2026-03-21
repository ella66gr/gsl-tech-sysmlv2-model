# Ontara — Stage 3 Phase 5 Detailed Implementation Plan

## String-to-Typed-Ref Migration (O25)

**Date:** 21 March 2026 (Session 57)
**Purpose:** Migrate string-typed cross-references in BMM `part def` attributes to typed `ref` attributes. Closes Stage 3.
**Status:** Implementation plan — awaiting approval.

---

## 1. Objective and Rationale

Many BMM `part def` attributes currently use `String` to reference other model elements by name (e.g. `attribute activityType : String;` where the value holds the name of an `ActivityType`). This is fragile, opaque to tooling, and contrary to core principles:

- **[[principle-model-generates-everything|A3 (model generates everything)]]:** Structural relationships should be in the model, not in string conventions.
- **[[principle-intrinsic-self-knowledge|A10 (intrinsic self-knowledge)]]:** The comprehension engine needs machine-navigable relationships, not heuristic string matching.
- **[[principle-unity-principle|A11 (unity principle)]]:** [[concept-weighted-relationships|Weighted relationships]] need formal element references, not string targets.
- **Syside IDE benefit:** Typed `ref` attributes give hover, go-to-definition, and find-references.
- **Glossary unlock:** Cross-package weight traversal in the [[concept-comprehension-layer|console glossary]] currently cannot work because cross-references are opaque strings. Typed refs make these navigable.

---

## 2. Scope

### 2.1 Audit of all String-typed attributes across BMM `part def` declarations

**Methodology:** Every `attribute x : String` on every BMM `part def` was examined. Each was classified as a genuine text field (remains String), a cross-reference to another model element (migrates to typed `ref`), or a deferred case (remains String, with documented rationale).

### 2.2 Classification results

#### Category A — Migrate to typed `ref` (12 attributes)

These hold the *name* of another BMM element and should become `ref` attributes.

| # | Part def | Current attribute | Target type | Package scope |
|---|---|---|---|---|
| A1 | `ValueProposition` | `targetSegment : String` | `ref targetSegment : CustomerSegment` | Same package (ServiceConcept) |
| A2 | `ActivityRecord` | `activityType : String` | `ref activityType : ActivityType` | Same package (ActivityModel) |
| A3 | `ActivityBudget` | `activityType : String` | `ref activityType : ActivityType` | Same package (ActivityModel) |
| A4 | `ActivityCostAllocation` | `activityType : String` | `ref activityType : ActivityType` | Same package (ActivityModel) |
| A5 | `ResourceInstance` | `resourceType : String` | `ref resourceType : ResourceType` | Same package (ResourcePlanning) |
| A6 | `ResourceConstraint` | `affectedResource : String` | `ref affectedResource : ResourceType` | Same package (ResourcePlanning) |
| A7 | `CostDriver` | `linkedResource : String` | `ref linkedResource : ResourceType` | Same package (FinancialPlanning → ResourcePlanning) |
| A8 | `RevenueStream` | `pricingModelRef : String` | `ref pricingModel : PricingModel` | Same package (FinancialPlanning) |
| A9 | `UnitEconomics` | `offeringRef : String` | `ref offering : ServiceOffering` | Cross-package (FinancialPlanning → ServiceConcept) |
| A10 | `FinancialProjection` | `scenarioRef : String` | `ref scenario : ScenarioDefinition` | Cross-package (FinancialPlanning → BusinessScenarios) |
| A11 | `InventoryRecord` | `catalogueEntryReference : String` | `ref catalogueEntry : CatalogueEntry` | Cross-package (ResourcePlanning → ServiceConcept) |
| A12 | `ObjectiveCapabilityMapping` | `objectiveRef : String` | `ref objective : StrategicObjective` | Cross-package (ResourcePlanning → BusinessStrategy) |

**Already typed refs (no change needed):**

- `Capability.enabledServiceOfferings : ServiceOffering[0..*]` — already a typed ref (Phase 7).
- `ObjectiveCapabilityMapping.supportingCapabilities : Capability[1..*]` — already a typed ref.
- `ScenarioDefinition.activeServiceOfferings : ServiceOffering[0..*]` — already a typed ref (Phase 7).
- `StrategicObjective.relatedScenarios : ScenarioDefinition[0..*]` — already a typed ref (Phase 7).

#### Category B — Genuine text fields (remain String, no action)

All `description`, `notes`, `assumptions`, `segmentName`, `statement`, `basis`, `name`, `scope`, `pricingBasis`, `trajectory`, `expression`, etc. These are human-readable prose, not references.

#### Category C — Deferred (remain String, with rationale)

| Attribute | Rationale |
|---|---|
| `ServiceOffering.clinicalPathwayRef` | Points to BSMM pathway constructs. Crosses BMM/BSMM boundary. Target types unstable. Domain exercises use it as a process name string. Defer to future BSMM extraction workstream. |
| `PricingModel.applicableOfferings` | Comma-separated list of offering names. Would need migration to `ref applicableOfferings : ServiceOffering[0..*]` but the current list-as-string pattern is used differently in each domain. Defer — low value relative to complexity. |
| `ScenarioComparison.scenarioRefs` | Comma-separated list. Same pattern as above. Defer. |
| `SensitivityParameter.parameterRef` | References a `ProjectionParameter` by name within the same package. Low priority — sensitivity analysis is illustrative. |
| `ForecastBaseline.scenarioRef` | String reference to a scenario name. Could be typed, but the baseline is a snapshot — the name is adequate. Low priority. |
| `ForecastBaseline.parameterSnapshot` | Long descriptive string. Not a reference. |
| `ProjectionParameter.sourceRef` | Contains package-qualified path strings (e.g. `"FinancialPlanning::perEpisodePricing"`). These are informational cross-references, not navigable model refs. Defer. |

### 2.3 Impact summary

- **12 `part def` attribute declarations** change from `attribute x : String` to `ref x : TargetType`
- **~53 instance redefinitions** change from `attribute :>> x = "string value"` to `ref :>> x = peerPartUsage` (or tuple syntax for multi-valued)
- **4 files** in the main model touched: `business-model.sysml` (primary), potentially `business-scenarios.sysml` and `business-strategy.sysml` for import adjustments
- **3 domain exercise files** touched: `coffeeshop-business-model.sysml`, `coffeeshop-resource-financial.sysml`, `suds.sysml`, `paws.sysml`
- **1 generator file** reviewed and updated if needed: `gen_model_introspection.py`
- **1 JSON data file** regenerated: `model-introspection.json` (both copies)

---

## 3. Implementation Steps

### Step 1: Model audit confirmation and pre-migration snapshot

**Executor:** Claude Chat (this session)
**Status:** Complete — the audit above covers all BMM `part def` declarations.

**Deliverable:** This plan document.

**Pre-migration:** Ella commits current state to git before any model changes begin, providing a clean rollback point.

### Step 2: Migrate `part def` declarations in `business-model.sysml`

**Executor:** Claude Code
**Scope:** All 12 Category A attributes.
**Approach:** For each attribute in the audit table:

1. Change `attribute x : String;` to `ref x : TargetType;` on the `part def`.
2. If the target type is in a different package, verify the required `private import` already exists at the package level. Add if missing.
3. Preserve the attribute name where possible. Where the current name includes a `Ref` suffix that becomes redundant (e.g. `pricingModelRef`), rename to the cleaner form (e.g. `pricingModel`). Where the current name is already clean (e.g. `activityType`), keep it.
4. Update the `part def`'s doc block if it mentions the string convention (e.g. "references a CustomerSegment by name" → remove or update).

**Name changes (attribute renames):**

| Current name | New name | Rationale |
|---|---|---|
| `pricingModelRef` | `pricingModel` | `Ref` suffix redundant — it's now a typed ref |
| `offeringRef` | `offering` | Same |
| `objectiveRef` | `objective` | Same |
| `catalogueEntryReference` | `catalogueEntry` | `Reference` suffix redundant |
| `linkedResource` | `linkedResource` | Keep — name is descriptive |
| `affectedResource` | `affectedResource` | Keep — name is descriptive |
| `targetSegment` | `targetSegment` | Keep |
| `activityType` | `activityType` | Keep (3 part defs) |
| `resourceType` | `resourceType` | Keep |
| `scenarioRef` | `scenario` | `Ref` suffix redundant |

**Import additions needed in `business-model.sysml`:**

- `FinancialPlanning` needs `private import BusinessModel::ResourcePlanning::ResourceType;` — but since this is same-file sibling-package import, a wildcard `private import BusinessModel::ResourcePlanning::*;` may be needed. Verify Syside resolution.
- `FinancialPlanning` may need `private import BusinessScenarios::ScenarioDefinition;` for `FinancialProjection.scenario`.
- `ResourcePlanning` may need `private import BusinessModel::ServiceConcept::CatalogueEntry;` for `InventoryRecord.catalogueEntry`.
- `ResourcePlanning` may need `private import BusinessStrategy::StrategicObjective;` for `ObjectiveCapabilityMapping.objective`.

**Critical syntax note:** Cross-package specific named imports don't work in Syside 0.8.5 (syntax reference §1). Use wildcard form: `private import BusinessScenarios::*;`.

**Claude Code instructions:**

```
Read the Phase 5 implementation plan at [vault path]. Read the SysML syntax 
reference at documentation/reference/gsl-sysml-v2-syntax-reference.md (§1 on 
imports, §2 on ref attributes).

In model/business-model.sysml, perform the following 12 attribute migrations 
on part def declarations only (do not touch part usages yet):

[Table of 12 migrations from §2.2 Category A]

For each:
1. Change `attribute x : String;` to `ref x : TargetType;`
2. If renaming (see name changes table), update the attribute name
3. Add any needed package-level imports (use wildcard form)
4. Update the doc block if it mentions string conventions

Do not modify any part usages (instances). Do not modify exercise files.
Commit message: "Phase 5 Step 2: migrate 12 part def declarations to typed refs"
```

### Step 3: Update GSL core instances in `business-model.sysml`

**Executor:** Claude Code
**Scope:** All GSL-specific `part` usages in `business-model.sysml` that redefine migrated attributes.
**Approach:** For each instance that uses `:>> migratedAttribute = "string value"`:

1. Change `attribute :>> x = "string value"` to `ref :>> x = peerPartUsageName`.
2. The peer part usage must be a sibling in the same package (or imported). Identify the correct target by matching the string value to the part usage name.

**Mapping of string values to part usage targets (GSL core instances):**

| Part usage | Attribute | Old string value | New ref target |
|---|---|---|---|
| `fasterAccess` | `targetSegment` | `"Self-referring individuals"` | `selfReferringIndividuals` |
| `integratedDigitalClinical` | `targetSegment` | `"Self-referring individuals"` | `selfReferringIndividuals` |
| `specialistExpertise` | `targetSegment` | `"GP-referred patients"` | `gpReferredPatients` |
| `holisticCareModel` | `targetSegment` | `"Self-referring individuals"` | `selfReferringIndividuals` |
| `clinicianMonth1to9` | `resourceType` | `"Prescribing clinician"` | `prescribingClinician` |
| `clinicianMonth10to24` | `resourceType` | `"Prescribing clinician"` | `prescribingClinician` |
| `adminInstance` | `resourceType` | `"Administrative support"` | `administrativeSupport` |
| `coachInstance` | `resourceType` | `"Gender identity coach"` | `genderCoach` |
| `moderatorInstance` | `resourceType` | `"Community moderator"` | `communityModerator` |
| `secondClinicianMonth6to24` | `resourceType` | `"Prescribing clinician"` | `prescribingClinician` |
| `maxPatientsPerClinician` | `affectedResource` | `"Prescribing clinician"` | `prescribingClinician` |
| `prescribingQualification` | `affectedResource` | `"Prescribing clinician"` | `prescribingClinician` |
| `clinicianCost` | `linkedResource` | `"Prescribing clinician"` | `prescribingClinician` |
| `adminCost` | `linkedResource` | `"Administrative support"` | `administrativeSupport` |
| `platformCost` | `linkedResource` | `"Technology platform"` | `technologyPlatform` |
| `insuranceCost` | `linkedResource` | `"Professional indemnity insurance"` | `professionalIndemnity` |
| `labCost` | `linkedResource` | `"Laboratory services"` | `laboratoryServices` |
| `overheadCost` | `linkedResource` | `""` (empty) | Remove or leave as attribute if no target exists |
| `coachCost` | `linkedResource` | `"Gender identity coach"` | `genderCoach` |
| `moderatorCost` | `linkedResource` | `"Community moderator"` | `communityModerator` |
| `assessmentRevenue` | `pricingModelRef` → `pricingModel` | `"perEpisodePricing"` | `perEpisodePricing` |
| `monitoringRevenue` | `pricingModelRef` → `pricingModel` | `"perEpisodePricing"` | `perEpisodePricing` |
| `subscriptionRevenue` | `pricingModelRef` → `pricingModel` | `"subscriptionPricing"` | `subscriptionPricing` |
| `assessmentUnitEconomics` | `offeringRef` → `offering` | `"Initial Assessment"` | `initialAssessment` |
| `monitoringUnitEconomics` | `offeringRef` → `offering` | `"Ongoing Monitoring (quarterly)"` | `ongoingMonitoring` |
| `subscriptionUnitEconomics` | `offeringRef` → `offering` | `"Subscription (monthly)"` | *No exact target* — see note |
| `leanClinicalProjection` | `scenarioRef` → `scenario` | `"Lean Clinical (Variant A)"` | `leanClinicalScenario` (cross-package) |
| `fullPlatformProjection` | `scenarioRef` → `scenario` | `"Full Platform (Variant B)"` | `fullPlatformScenario` (cross-package) |

**Special cases:**

- `overheadCost.linkedResource = ""` — empty string, no target. Options: (a) make the ref optional with `[0..1]` multiplicity on the part def, or (b) keep a parallel `linkedResourceDescription : String` on the part def. Recommended: make the `part def` declaration `ref linkedResource : ResourceType[0..1];` to handle this.
- `subscriptionUnitEconomics.offering` — the string value `"Subscription (monthly)"` doesn't match any single `ServiceOffering` usage. The subscription combines Coaching, Education, and Community. Options: (a) create a composite `subscriptionBundle : ServiceOffering` usage, or (b) make the ref `[0..*]` and point to all three. Recommended: keep as `ref offering : ServiceOffering` (singular) and create a `subscriptionBundle : ServiceOffering` usage, or use a descriptive attribute alongside the ref. **Decision needed from Ella.**
- Cross-package refs to `BusinessScenarios` (`leanClinicalScenario`, `fullPlatformScenario`): these are in a different top-level package. The `FinancialPlanning` package will need `private import BusinessScenarios::*;`. Verify the ref redefinition resolves across files.

**Claude Code instructions:**

```
Read the Phase 5 implementation plan. In model/business-model.sysml, update all 
GSL core part usages that redefine the 12 migrated attributes.

For each instance listed in the Step 3 mapping table:
1. Change `attribute :>> oldName = "string value"` to `ref :>> newName = targetPartUsage`
2. Use the exact part usage names from the mapping table
3. For CostDriver.linkedResource with empty string, remove the redefinition line 
   (the ref will be unset, which is valid for [0..1] multiplicity)
4. For cross-package refs, verify imports exist

Commit message: "Phase 5 Step 3: update GSL core instances to typed ref redefinitions"
```

### Step 4: Update Cafe exercise instances

**Executor:** Claude Code
**Scope:** `coffeeshop-business-model.sysml` and `coffeeshop-resource-financial.sysml`
**Approach:** Same pattern as Step 3. Map string values to peer part usage names within the Cafe files.

**Key mappings (Cafe):**

| File | Part usage | Attribute | New ref target |
|---|---|---|---|
| `coffeeshop-resource-financial.sysml` | `foodHygiene` | `affectedResource` | `barista` |
| `coffeeshop-resource-financial.sysml` | `drinkSales` | `pricingModel` | `perDrinkPricing` |
| `coffeeshop-resource-financial.sysml` | `baristaCost` | `linkedResource` | `barista` |
| `coffeeshop-resource-financial.sysml` | `ingredientCost` | `linkedResource` | `ingredientStock` |
| `coffeeshop-resource-financial.sysml` | `rentCost` | `linkedResource` | `counterSpace` |
| `coffeeshop-resource-financial.sysml` | `drinkUnitEconomics` | `offering` | `drinkOrder` (cross-file) |

**Import additions needed:** `CoffeeshopResourceFinancial` may need to import from `CoffeeShopBusinessModel` for the `drinkOrder` ref target. This is a cross-file, cross-package ref — verify resolution.

**Note on ActivityRecord/ActivityBudget/ActivityCostAllocation:** The Cafe exercise doesn't instantiate these part defs, so no changes needed for those.

### Step 5: Update Suds exercise instances

**Executor:** Claude Code
**Scope:** `suds.sysml` (single file containing both business model and governance)

**Key mappings (Suds):**

| Part usage | Attribute | New ref target |
|---|---|---|
| `coshhRegulations` | `affectedResource` | *No peer ResourceType usage — see note* |
| `laundryRevenue` | `pricingModel` | `perKgPricing` |
| `staffCosts` | `linkedResource` | `laundryOperator` |
| `utilityCosts` | `linkedResource` | `washingMachines` |
| `chemicalCosts` | `linkedResource` | `detergentsAndChemicals` |
| `rentCosts` | `linkedResource` | `shopPremises` |
| `standardWashEconomics` | `offering` | `standardWash` |
| `delicatesWashEconomics` | `offering` | `delicatesWash` |
| `expressWashEconomics` | `offering` | `expressWash` |

**Special case:** `coshhRegulations.affectedResource = "Detergents and chemicals"` — Suds has a `ResourceType` usage for detergents (`detergentsAndChemicals` or similar). Need to verify the exact part usage name. If no `ResourceType` usage exists for "Detergents and chemicals", one must be created to serve as the ref target.

**Same pattern applies to `utilityCosts.linkedResource = "Washing machines and dryers"` and `chemicalCosts.linkedResource = "Detergents and chemicals"` — verify that the Suds file has matching `ResourceType` usages for these.**

**Action needed:** Read the Suds file's ResourceType/ResourceInstance section carefully to confirm exact part usage names. If ResourceType usages are missing for some referenced resources, they must be created as part of this step. This is architecturally appropriate — the model was under-specified where string conventions masked missing structural declarations.

### Step 6: Update Paws exercise instances

**Executor:** Claude Code
**Scope:** `paws.sysml` (single file)

**Key mappings (Paws):** Same pattern as Suds. Map string values to peer ResourceType usages. Verify all referenced resources have corresponding part usages. Create missing ResourceType usages if needed.

### Step 7: Generator review and update

**Executor:** Claude Chat or Code
**Scope:** `scripts/gen_model_introspection.py`

The generator already handles `ref` attributes in its `parse_attributes` function. Review needed:

1. **`parse_attributes`** — currently has a regex for `ref x : Type`. Confirm it handles the new `ref` declarations correctly.
2. **`build_comprehension_content`** — uses same-package proximity for `surfaceRelatedConcepts`. Typed refs provide a more reliable path. Consider whether the generator should now traverse typed refs for related concept discovery (enhancement opportunity, not blocking).
3. **Attribute rename handling** — the console/glossary uses attribute names from the JSON. Renamed attributes (e.g. `pricingModelRef` → `pricingModel`) will appear differently. Verify the console displays correctly with the new names.

**Expected outcome:** Minimal or no generator changes needed. The existing regex parsing handles both `attribute` and `ref` declarations.

### Step 8: Regenerate model introspection JSON

**Executor:** Claude Chat (provide shell commands) or Claude Code
**Scope:** Run the generator, copy output to console static data.

```bash
cd ~/Developer/gsl-tech/gsl-sysml-model
python scripts/gen_model_introspection.py --save --pretty
cp generated/ontara/model-introspection.json console/static/data/model-introspection.json
```

Verify the JSON output:
- All 12 migrated attributes now appear as `"isRef": true` in the element data
- Attribute names reflect the renames
- Coverage matrix, comprehension content, and facet summaries are unaffected
- No regression in element counts or domain coverage

### Step 9: Ella verifies in Syside

**Executor:** Ella
**Scope:** Open all modified `.sysml` files in Syside Modeler. Verify:

1. No parse errors or warnings
2. Typed refs resolve with hover showing target element
3. Go-to-definition works on ref redefinitions (`:>> x = peerPart`)
4. Cross-package refs resolve correctly
5. Cross-file refs (e.g. Cafe resource-financial → Cafe business model) resolve

---

## 4. Risk Assessment

| Risk | Mitigation |
|---|---|
| Cross-package `ref` fails in some configurations | Syntax reference §2 confirms cross-package `ref` and `ref :>>` tuple syntax. Verified v3.11 and v3.13. |
| Sibling-package import within same file | Known to work (syntax ref §1). `private import BusinessModel::ResourcePlanning::*;` from within `BusinessModel::FinancialPlanning`. |
| `ref :>>` redefinition with part usage target | Verified v3.13 (PatternCatalogue). `ref :>> field = peerPartUsage` works. |
| Missing ResourceType usages in Suds/Paws | Some CostDriver and ResourceConstraint string values reference resources that don't have explicit ResourceType usages. Steps 5–6 include creating these. |
| Empty string refs (e.g. `overheadCost.linkedResource = ""`) | Make the ref `[0..1]` multiplicity on the part def. Unset refs are valid. |
| `subscriptionUnitEconomics.offering` — no single target | Decision needed from Ella. Options: composite usage, multi-valued ref, or descriptive string alongside. |
| Generator breaks on renamed attributes | Unlikely — generator reads structural declarations, not names. Verify in Step 8. |
| Console display regression | Regenerated JSON may change attribute names in the glossary. Minor cosmetic — verify in Step 8. |

---

## 5. Concept Register Impacts

| Concept | Impact |
|---|---|
| [[principle-model-generates-everything|A3]] (model generates everything) | Strengthened — structural relationships now in the model, not string conventions. |
| [[principle-intrinsic-self-knowledge|A10]] (intrinsic self-knowledge) | Enabled — comprehension traversal can now follow typed refs across packages. |
| [[principle-unity-principle|A11]] (unity principle) | Enabled — weighted relationship targets can be validated against typed ref targets. |
| [[concept-weighted-relationships|B14]] (weighted relationships) | Unlocked — cross-package weight traversal now possible. |
| [[deferred-string-to-typed-ref-migration|O25]] (deferred item) | Closed — migration complete. |
| I15 (glossary) | Enhanced — cross-package related concepts now navigable. |
| O21 (glossary coverage) | Updated — "cross-package weights do not display until O25" becomes resolved. |

---

## 6. Co-evolution Check ([[concept-co-evolution|J2]])

**Model change:** 12 `part def` attributes migrated from String to typed ref.
**Tooling change:** Generator already handles refs. Console benefits from richer data. No new tooling needed — this is a pure model improvement that existing tooling consumes.

The [[concept-co-evolution|co-evolution]] principle is satisfied: the model change improves what the existing tooling can discover, without requiring new tooling to make it legible.

---

## 7. Deliverables

1. Updated `model/business-model.sysml` — 12 typed ref declarations, ~25 GSL instance updates
2. Updated `exercises/coffeeshop-demonstrator/model/coffeeshop-business-model.sysml` (if needed)
3. Updated `exercises/coffeeshop-demonstrator/model/coffeeshop-resource-financial.sysml` — ~6 instance updates
4. Updated `exercises/suds-demonstrator/model/suds.sysml` — ~9 instance updates + possible new ResourceType usages
5. Updated `exercises/paws-demonstrator/model/paws.sysml` — similar scope to Suds
6. Updated `generated/ontara/model-introspection.json` and `console/static/data/model-introspection.json`
7. Updated master concept register (O25 closed, O21 updated)
8. Updated deferred item note ([[deferred-string-to-typed-ref-migration]] — mark as resolved)

---

## 8. Execution Order and Tool Assignment

| Step | Description | Executor | Dependency |
|---|---|---|---|
| 1 | Audit and plan | Claude Chat | — |
| — | Git commit (pre-migration snapshot) | Ella | Step 1 |
| 2 | Migrate part def declarations | Claude Code | Git commit |
| 3 | Update GSL core instances | Claude Code | Step 2 |
| 4 | Update Cafe instances | Claude Code | Step 2 |
| 5 | Update Suds instances | Claude Code | Step 2 |
| 6 | Update Paws instances | Claude Code | Step 2 |
| 7 | Generator review | Claude Chat/Code | Steps 2–6 |
| 8 | Regenerate JSON | Claude Chat/Code | Steps 2–7 |
| 9 | Syside verification | Ella | Steps 2–6 |

Steps 2–6 can be run as a single Claude Code session with one combined commit, or as separate commits per step. Recommended: one combined commit after Steps 2–6, then a second commit after Step 8 (generated files).

---

## 9. Open Questions for Ella

1. **`subscriptionUnitEconomics.offering`**: The string value `"Subscription (monthly)"` doesn't match any single `ServiceOffering` usage. Options: (a) create a `subscriptionBundle : ServiceOffering` composite usage, (b) make the ref `[0..*]` and point to Coaching + Education + Community, (c) keep this one as a descriptive string. Recommendation: (a) — cleanest.

2. **`overheadCost.linkedResource = ""`**: The overhead cost driver has no linked resource. Recommendation: make `CostDriver.linkedResource` a `ref linkedResource : ResourceType[0..1]` (optional). This lets `overheadCost` simply omit the ref.

3. **Suds/Paws missing ResourceType usages**: Some CostDriver and ResourceConstraint instances reference resources (e.g. "Detergents and chemicals", "Washing machines and dryers", "Grooming consumables") that may not have corresponding `ResourceType` part usages. Should we create these as part of this migration (architecturally correct — the model was under-specified), or defer?

---

*Plan produced 21 March 2026, Session 57.*
