# Plan: Business Meta Model Phase 7 — Governance Mapping and Strategy Elaboration

**Project:** GenderSense (GSL)
**Date:** 11 March 2026
**Status:** Draft for review
**Parent plan:** `gsl-plan-business-meta-model-implementation-2026-03-10.md` (Phase 7, section 9)
**Predecessor:** Phase 6 complete (Session 18) — file split, Operations expansion, steering cycle wiring

---

## 1. Purpose

Complete the Business Meta Model package by establishing formal cross-references between the business model, strategy, and governance layers. This is the final phase of the implementation plan — it upgrades the string-based references that were deliberately deferred during Phases 1–6 ("formal references will be added once the shapes stabilise") into typed SysML relationships.

Three structural upgrades:

1. **Formal `ref` from ScenarioDefinition to ServiceOffering** — replacing string `activeOfferings` with a typed reference.
2. **Formal `satisfy` from StrategicObjective to Capability** — modelling strategic objectives as `requirement def` and expressing that they are satisfied by capabilities.
3. **Governance cross-references** — wiring Enterprise::Strategy to BusinessStrategy, and ResourceConstraint to Enterprise::Regulation.

**Design principle:** Formal correctness is preferred over convenience. Typed references and satisfy relationships provide future predictability — downstream tooling (generators, validators, traceability reports) can rely on structural relationships rather than parsing string conventions.

---

## 2. Scope Boundary

**In scope:**

- Syntax verification: `ref` with multiplicity across packages (unverified pattern)
- Restructure StrategicObjective from `part def` to `requirement def`
- Add `satisfy` relationships from StrategicObjective requirements to Capability usages
- Add formal `ref` from ScenarioDefinition to ServiceOffering (cross-package)
- Enrich Enterprise::Strategy to reference BusinessStrategy types
- Add `ref` from ResourceConstraint to Enterprise::Regulation requirement defs
- Coffee shop demonstrator parity: lightweight governance/strategy cross-references
- Documentation updates and session report

**Out of scope:**

- Variant C elaboration (deferred beyond Phase 7)
- Runtime implementation of any traceability mechanism
- Changes to the Knowledge layer or Foundation layer
- Changes to ProjectionEngine or any generators
- Simulation harness design (deferred workstream)

---

## 3. Architectural Approach: Upgrading String References to Typed Relationships

Phases 1–3 deliberately used string attributes for cross-references: `clinicalPathwayRef : String`, `enabledOfferings : String`, `relatedCapabilities : String`, `regulatorySource : String`. The rationale was sound — avoid coupling during the exploratory phase. The shapes have now stabilised through six phases of iterative development.

Phase 7 upgrades these to typed SysML relationships where the target element exists in the model. String references remain for cross-references to elements that are not yet structurally elaborated (e.g., `clinicalPathwayRef` to specific clinical pathway names — the pathways exist but the formal ref pattern across ServiceConcept → ServiceDelivery::ClinicalPathways has broader coupling implications that are out of scope).

**What changes:**

| Element | Current | Phase 7 |
|---|---|---|
| `StrategicObjective` | `part def` with string attributes | `requirement def` with typed attributes + `satisfy` relationships |
| `ScenarioDefinition.activeOfferings` | `attribute : String` | `ref activeOfferings : ServiceOffering[0..*]` |
| `BusinessModelVariant.activeOfferings` | `attribute : String` | Remains `String` (variant descriptions are summary-level) |
| `Capability.enabledOfferings` | `attribute : String` | `ref enabledOfferings : ServiceOffering[0..*]` |
| `ResourceConstraint.regulatorySource` | `attribute : String` | `ref regulatoryRef : Regulation requirement defs` (new attribute alongside existing string) |
| `Enterprise::Strategy::BusinessModel` | Placeholder part def | Enriched with `ref` to BusinessStrategy types |
| `Enterprise::Strategy::Partnership` | Placeholder part def | Enriched with `ref` to BusinessStrategy types |
| `StrategicObjective.relatedCapabilities` | `attribute : String` | Replaced by `satisfy` relationship |
| `StrategicObjective.relatedScenarios` | `attribute : String` | `ref relatedScenarios : ScenarioDefinition[0..*]` |

**What does NOT change:**

- `ServiceOffering.clinicalPathwayRef` — remains String (cross-domain coupling deferred)
- `BusinessModelVariant` attributes — remain String (summary descriptions, not structural references)
- `PivotScenario` from/to variant references — remain String (narrative-level)
- `ProjectionParameter.sourceRef` — remains String (loosely coupled by design)

---

## 4. Pre-flight Checks and Syntax Verification

### 4.1 Critical: `ref` with Multiplicity Across Packages

**Status:** Unverified in syntax reference v3.10.

The syntax reference verifies `ref customer : Customer` (singular ref within a package) and `part x : Type[0..*]` (composition with multiplicity). The combination `ref x : Type[0..*]` across packages has not been explicitly tested.

**Verification approach:** Create a minimal syntax test in `model/syntax-tests/` before modifying production files.

```sysml
// syntax-tests/ref-multiplicity-test.sysml
package RefMultiplicityTest {
    private import ScalarValues::*;
    private import BusinessModel::ServiceConcept::*;

    part def TestHolder {
        ref offerings : ServiceOffering[0..*];
    }

    part testInstance : TestHolder {
        // Can we redeclare/populate the ref in an instance?
    }
}
```

**If this fails:** Fall back to `ref offerings : ServiceOffering` (singular) or retain string attributes with doc block noting the intent. Document the finding in the syntax reference.

**If this succeeds:** Proceed with the formal ref pattern. Document in syntax reference as a new verified pattern.

### 4.2 Critical: `requirement def` with Typed Attributes and `satisfy`

**Status:** Verified for clinical requirements (Enterprise::Regulation). The verified pattern uses `subject` and typed attributes within `requirement def`, and `satisfy requirement X by Y` in a different package.

**New aspect to verify:** Using `satisfy requirement StrategicObjectiveX by capabilityY` where the requirement def has business-domain attributes (not clinical). Structurally this should be identical — `satisfy` does not inspect the content of the requirement def — but worth confirming in a syntax test.

**Additional verification:** `requirement def` with `ref` attributes (e.g., `ref relatedScenarios : ScenarioDefinition[0..*]`). Combining `requirement def` with `ref` is untested.

### 4.3 Pre-flight Verification Sequence

```
1. Create syntax-tests/ref-multiplicity-cross-package.sysml
   → Verify: ref x : Type[0..*] across packages
   → Verify: ref x : Type[0..*] inside a requirement def
2. Create syntax-tests/satisfy-business-requirement.sysml
   → Verify: satisfy requirement (non-clinical requirement def) by (capability usage)
3. Run Syside parse on both test files
4. If both pass → proceed to production stages
5. If either fails → document the failure, design fallback, proceed with available patterns
```

### 4.4 Reserved Word Check

Proposed new names:

- `regulatoryRef` — safe (not a KerML reserved word)
- `strategicObjectiveRef` — safe
- `strategyRef` — safe
- `variantRef` — `variant` is a SysML keyword. `variantRef` as a compound name should be safe (reserved words apply to exact matches, not compounds), but worth verifying. If problematic, use `businessVariantRef`.

---

## 5. Stage 1 — Syntax Verification and Pre-flight

### Scope

Create syntax test files and verify the two critical unverified patterns. Establish confidence before modifying production files.

### Deliverables

**Test 1: `ref` with multiplicity across packages**

A minimal file in `model/syntax-tests/` that imports `BusinessModel::ServiceConcept::ServiceOffering` and declares `ref offerings : ServiceOffering[0..*]` inside a part def. Also test inside a `requirement def`.

**Test 2: `satisfy` with business-domain requirement def**

A minimal file that declares a test `requirement def` with business attributes, creates a test usage, and uses `satisfy requirement TestReq by testUsage`.

### Acceptance Criteria

- Both test files parse without errors in Syside, OR
- Failures are documented and fallback patterns designed
- Syntax reference updated with findings

### Estimated Effort

15–20 minutes.

---

## 6. Stage 2 — StrategicObjective Restructuring

### Scope

Convert `StrategicObjective` from `part def` to `requirement def` in `business-strategy.sysml`. Migrate the four existing instantiations. This is the most significant structural change in Phase 7.

### 6.1 Requirement Def Conversion

**Current:**

```sysml
part def StrategicObjective {
    attribute objectiveName : String;
    attribute description : String;
    attribute targetDate : String;
    attribute successCriteria : String;
    attribute relatedCapabilities : String;
    attribute relatedScenarios : String;
    attribute status : String;
}
```

**Proposed:**

```sysml
requirement def StrategicObjective {
    doc /* A defined business goal with a timeframe, success
         * criteria, and traceability to capabilities that
         * satisfy it and scenarios that parameterise it.
         *
         * Modelled as requirement def (not part def) to enable
         * formal satisfy relationships from objectives to
         * capabilities, preserving structural traceability for
         * future tooling. Phase 7 restructuring.
         *
         * subject: the business or service system that must
         * satisfy this objective.
         *
         * satisfy relationships are in BusinessModel::
         * ResourcePlanning (different package, per Syside
         * constraint on satisfy in same package as req def). */
    subject genderSenseService : String;
    attribute objectiveName : String;
    attribute description : String;
    attribute targetDate : String;
    attribute successCriteria : String;
    attribute status : String;
    // relatedCapabilities: replaced by satisfy relationships
    // relatedScenarios: replaced by ref (if ref-in-req-def verifies)
    //   OR retained as String attribute (if ref-in-req-def fails)
}
```

**Key changes:**

- `part def` → `requirement def`
- Added `subject` (required for requirement defs — identifies what must satisfy the requirement)
- Removed `relatedCapabilities : String` — replaced by `satisfy` relationships in ResourcePlanning
- `relatedScenarios` — upgraded to `ref relatedScenarios : ScenarioDefinition[0..*]` if syntax test passes, otherwise retained as String

### 6.2 Instantiation Migration

The four existing instantiations change from `part` to `requirement`:

```sysml
// Current:
part objectivePatientCohort : StrategicObjective { ... }

// Proposed:
requirement objectivePatientCohort : StrategicObjective { ... }
```

All `:>>` redefinitions remain identical. The `relatedCapabilities` attribute is removed from each instantiation (replaced by satisfy relationships in Stage 4).

**Import requirement:** If `ref relatedScenarios` is added, BusinessStrategy needs to import `BusinessScenarios::ScenarioDefinition` (or `BusinessScenarios::*`). This creates a new cross-package dependency: BusinessStrategy → BusinessScenarios. This is architecturally sound — a strategic objective naturally references the scenario that parameterises its achievement.

### 6.3 Impact Assessment

| File | Change |
|---|---|
| `model/business-strategy.sysml` | StrategicObjective: `part def` → `requirement def`. Four usages: `part` → `requirement`. Remove `relatedCapabilities` attribute from def and usages. Add import from BusinessScenarios if ref pattern works. |
| No other files import StrategicObjective | No cascade impact. BusinessStrategy is only imported by `gendersense.sysml` (wildcard) and no other package references StrategicObjective by name. |

### Acceptance Criteria

- `business-strategy.sysml` parses without errors
- All four requirement usages compile with `:>>` redefinitions
- `gendersense.sysml` still resolves the wildcard import

### Estimated Effort

30–40 minutes.

---

## 7. Stage 3 — Formal `ref` Additions

### Scope

Add typed `ref` relationships to ScenarioDefinition, Capability, and ResourceConstraint, replacing string references. Contingent on Stage 1 syntax verification results.

### 7.1 ScenarioDefinition — `ref` to ServiceOffering

**In:** `model/business-scenarios.sysml`

**Change:** Add to ScenarioDefinition part def:

```sysml
ref activeServiceOfferings : ServiceOffering[0..*];
```

**Import required:** `private import BusinessModel::ServiceConcept::ServiceOffering;` (or `::*`)

This creates a new dependency: BusinessScenarios → BusinessModel::ServiceConcept. Architecturally correct — scenarios reference which offerings they activate.

**Existing `activeOfferings : String` attribute:** Retain as `activeOfferingsDescription : String` (renamed to avoid name collision) for the human-readable summary. The `ref` provides structural traceability; the string provides readable context.

**Instantiation updates:** Each ScenarioDefinition usage adds `:>>` redefinitions for the ref. This needs syntax verification — can you `:>>` a `ref` with specific usages? If not, we use the ref at the def level and populate via doc blocks.

### 7.2 Capability — `ref` to ServiceOffering

**In:** `model/business-model.sysml` (ResourcePlanning sub-package)

**Change:** Add to Capability part def:

```sysml
ref enabledServiceOfferings : ServiceOffering[0..*];
```

Since both Capability and ServiceOffering are within BusinessModel, this is a same-file ref. Should be straightforward.

**Existing `enabledOfferings : String` attribute:** Rename to `enabledOfferingsDescription : String`.

### 7.3 ResourceConstraint — `ref` to Enterprise::Regulation

**In:** `model/business-model.sysml` (ResourcePlanning sub-package)

**Change:** Add to ResourceConstraint part def:

```sysml
ref regulatoryRequirementRef : Enterprise::Regulation requirement defs
```

**Design question:** The regulatory requirements in Enterprise::Regulation are `requirement def` declarations, not usages. Can a `ref` point to a `requirement def`? This is structurally different from pointing to a `part def`. If this doesn't work, we can use `attribute regulatoryRequirementName : String` and rely on the doc block cross-reference (status quo).

**Import required:** `private import Enterprise::Regulation::*;` in the ResourcePlanning sub-package.

**Fallback:** If `ref` to `requirement def` doesn't work in Syside, add a string attribute `regulatoryRequirementRef : String` with the fully-qualified name, and document the limitation.

### 7.4 Contingency: If `ref` with Multiplicity Fails

If Stage 1 syntax tests reveal that `ref x : Type[0..*]` doesn't parse:

- Use singular `ref activeServiceOffering : ServiceOffering` (first/primary offering only)
- Retain String attributes for multi-valued references
- Document the limitation in the syntax reference
- Note as a future item: revisit when Syside supports multiplicity on refs

### Acceptance Criteria

- `business-scenarios.sysml` parses with new imports and ref attributes
- `business-model.sysml` (ResourcePlanning) parses with new ref attributes
- Cross-package refs resolve correctly
- Existing instantiations still compile

### Estimated Effort

40–50 minutes (includes careful verification of each ref pattern).

---

## 8. Stage 4 — Satisfy Relationships and Enterprise Enrichment

### Scope

Add `satisfy` relationships from StrategicObjective requirements to Capability usages. Enrich Enterprise::Strategy to reference BusinessStrategy.

### 8.1 Satisfy Relationships

**Location:** BusinessModel::ResourcePlanning (different package from the `requirement def`, per verified Syside constraint).

**Pattern:**

```sysml
// In ResourcePlanning, after Capability usages:
private import BusinessStrategy::*;

satisfy requirement objectivePatientCohort
    by prescribingCapability;

satisfy requirement objectiveSharedCare
    by prescribingCapability;

satisfy requirement objectiveBreakEven
    by prescribingCapability;    // break-even depends on clinical capability
    // Note: also depends on financial model — but satisfy targets a single usage

satisfy requirement objectivePlatformLaunch
    by assessmentCapability;
```

**Design note:** `satisfy` creates a one-to-one relationship (one requirement satisfied by one element). Where an objective is satisfied by multiple capabilities, we pick the primary one and document the others in a doc block. An alternative is multiple `satisfy` statements for the same requirement — this needs syntax verification (can the same requirement have multiple `satisfy by` in the same package?).

**Import required:** BusinessModel::ResourcePlanning needs `private import BusinessStrategy::*;` to access the requirement usages.

### 8.2 Enterprise::Strategy Enrichment

**Current state:** Enterprise::Strategy has two lightweight part defs:

```sysml
part def Partnership {
    attribute partnerName : String;
    attribute nature : String;
}

part def BusinessModel {
    attribute modelName : String;
    attribute description : String;
}
```

**Proposed enrichment:**

```sysml
part def Partnership {
    attribute partnerName : String;
    attribute nature : String;
    attribute strategicObjectiveRef : String;   // references BusinessStrategy objectives
    doc /* Strategic partnerships that support the business
         * strategy. Cross-references BusinessStrategy::
         * StrategicObjective by name. */
}

part def StrategicContext {
    doc /* Connects the enterprise-level strategic context to the
         * detailed business strategy and scenario modelling.
         * This is the structural bridge between the outer ring
         * (Enterprise) and the business model layer.
         *
         * The Enterprise::Strategy package provides the
         * organisational anchoring; BusinessStrategy provides
         * the operational detail.
         *
         * Cross-references:
         * - BusinessStrategy::StrategicObjective — detailed goals
         * - BusinessStrategy::BusinessModelVariant — alternative
         *   configurations under consideration
         * - BusinessStrategy::PivotScenario — transition plans
         * - BusinessScenarios::ScenarioDefinition — parameterised
         *   evaluable scenarios */
    attribute contextName : String;
    attribute currentVariant : String;          // which BusinessModelVariant is active
    attribute strategicHorizonMonths : Integer;
    attribute governanceNotes : String;         // how strategy decisions are governed
}
```

**Note on `BusinessModel` name collision:** Enterprise::Strategy currently has a part def called `BusinessModel`. This name now collides with the top-level `BusinessModel` package. Rename to `StrategicContext` to avoid ambiguity and better reflect its purpose as the enterprise-level strategic anchor.

**Import approach:** Enterprise does NOT import BusinessStrategy. The cross-references are via String attributes and doc blocks. This preserves the one-way dependency direction: BusinessStrategy → Enterprise (for satisfy/ref) but NOT Enterprise → BusinessStrategy. The outer ring (Enterprise) should not depend on inner-ring packages.

### 8.3 GSL Instantiation

Add one illustrative `StrategicContext` usage in Enterprise::Strategy:

```sysml
part gslStrategicContext : StrategicContext {
    attribute :>> contextName = "GenderSense Strategic Context 2026";
    attribute :>> currentVariant = "Lean Clinical (Variant A)";
    attribute :>> strategicHorizonMonths = 24;
    attribute :>> governanceNotes = "Sole founder governance. Clinical governance via CQC registration. Strategic decisions informed by projection comparison and actuals tracking.";
}
```

### Acceptance Criteria

- `satisfy` relationships compile in ResourcePlanning
- Enterprise::Strategy parses with enriched types and renamed part def
- No circular import dependencies created
- `gendersense.sysml` resolves all wildcard imports

### Estimated Effort

30–40 minutes.

---

## 9. Stage 5 — Coffee Shop Demonstrator Parity

### Scope

Add lightweight governance/strategy cross-references to the coffee shop demonstrator, validating that the formal patterns work in a non-clinical domain.

### Deliverables

**In `coffeeshop-scenarios.sysml` or a new `coffeeshop-strategy.sysml`:**

**Option A (preferred if file is small):** Add to existing `coffeeshop-scenarios.sysml`:

- One `requirement` usage of StrategicObjective: "Reach profitability within 6 months"
- One illustrative `satisfy` relationship if the pattern is in the right package context

**Option B (if scope warrants):** New file `coffeeshop-strategy.sysml`:

- One StrategicObjective requirement: kiosk profitability target
- One BusinessModelVariant (already exists — just add a `ref` to it if pattern works)
- Demonstrate the satisfy → capability pattern for a coffee shop capability

**Design note:** The coffee shop demonstrator doesn't have a ResourcePlanning equivalent with Capability usages. If satisfy requires a capability usage, we'd need to add a minimal coffee shop capability first. Assess whether this is proportionate — a single `part kioskBaristaCapability : Capability` with a `satisfy` might be sufficient.

### Acceptance Criteria

- Coffee shop demonstrator files parse without errors
- At least one formal cross-reference (ref or satisfy) validates in the non-clinical domain
- The pattern feels proportionate for a coffee shop (not over-engineered)

### Estimated Effort

20–30 minutes.

---

## 10. Stage 6 — Documentation and Commit

### Deliverables

**Syntax reference update (v3.11):**

New verified patterns (contingent on Stage 1 results):
- `ref x : Type[0..*]` — ref with multiplicity across packages
- `ref` inside `requirement def` — ref attributes within requirement definitions
- `requirement def` with business-domain attributes and `satisfy`
- Multiple `satisfy` for the same requirement (if tested)
- `StrategicContext` rename from `BusinessModel` avoiding package name collision

New reserved word / naming findings (if any).

**Session report**

**Updated deferred items:**
- Strike through Phase 7 items (formal ref, satisfy, governance cross-references)
- Note any new deferred items discovered during implementation

**Git commits:**

| Commit | Content |
|---|---|
| Stage 1 | Syntax tests for ref multiplicity and satisfy business requirement |
| Stage 2 | StrategicObjective restructuring (part def → requirement def) |
| Stage 3 | Formal ref additions (ScenarioDefinition, Capability, ResourceConstraint) |
| Stage 4 | Satisfy relationships + Enterprise::Strategy enrichment |
| Stage 5 | Coffee shop demonstrator parity |

### Estimated Effort

20 minutes (documentation), plus commit cycle.

---

## 11. File Impact Assessment

### Files modified

| File | Expected changes |
|---|---|
| `model/business-strategy.sysml` | StrategicObjective: `part def` → `requirement def`. Four usages: `part` → `requirement`. Add BusinessScenarios import. ~170 lines, moderate restructuring. |
| `model/business-scenarios.sysml` | Add BusinessModel::ServiceConcept import. Add `ref` to ScenarioDefinition. Rename `activeOfferings` to `activeOfferingsDescription`. ~850 lines, minor additions. |
| `model/business-model.sysml` | ResourcePlanning: add `ref` to Capability and ResourceConstraint. Add satisfy relationships. Add Enterprise::Regulation import. ~860 lines, moderate additions. |
| `model/enterprise.sysml` | Strategy: rename `BusinessModel` → `StrategicContext`. Enrich Partnership. Add GSL instantiation. ~minor restructuring. |
| `exercises/coffeeshop-demonstrator/model/coffeeshop-scenarios.sysml` | Add StrategicObjective requirement + cross-reference. |

### Files created

| File | Purpose |
|---|---|
| `model/syntax-tests/ref-multiplicity-cross-package.sysml` | Syntax verification |
| `model/syntax-tests/satisfy-business-requirement.sysml` | Syntax verification |

### Files not modified

| File | Rationale |
|---|---|
| `model/foundation.sysml` | No Foundation changes needed |
| `model/knowledge.sysml` | No Knowledge layer changes needed |
| `model/operations.sysml` | No operational changes |
| `model/service-delivery.sysml` | No service delivery changes |
| `model/platform.sysml` | No platform changes |
| `model/gendersense.sysml` | No new top-level packages added |
| `scripts/projection_engine.py` | No engine changes |

---

## 12. Key Structural Questions

### Q1: Can `ref x : Type[0..*]` cross packages?

Verified patterns: `ref x : Type` (singular, same package), `part x : Type[0..*]` (composition with multiplicity). The combination is unverified. Stage 1 tests this.

### Q2: Can a `requirement def` contain `ref` attributes?

The verified pattern has `subject` and `attribute` inside `requirement def`. Adding `ref` inside `requirement def` is untested. Stage 1 tests this.

### Q3: Can one `requirement` have multiple `satisfy by` statements?

The verified pattern shows one satisfy per requirement. Multiple satisfiers for one requirement (e.g., `objectivePatientCohort` satisfied by both `prescribingCapability` and `assessmentCapability`) is untested. If it fails, use one satisfy per requirement and document additional satisfiers in doc blocks.

### Q4: What is the `subject` of a StrategicObjective?

In clinical requirements, `subject patient : Patient` identifies the entity that must satisfy the requirement. For a strategic objective, the subject is the business/service itself. We use `subject genderSenseService : String` as a lightweight approach. If Syside requires a typed subject referencing an existing part def, we may need to define a minimal `ServiceSystem` part def in Foundation or use a more generic subject.

### Q5: Does renaming `Enterprise::Strategy::BusinessModel` to `StrategicContext` affect any imports?

Only `gendersense.sysml` imports `Enterprise::*` (wildcard). No other file imports `Enterprise::Strategy::BusinessModel` by name. The rename should be safe. Verify by checking that `gendersense.sysml` still parses after the change.

---

## 13. Estimated Scope

| Stage | Estimated effort | Primary deliverable |
|---|---|---|
| Stage 1 — Syntax verification | 15–20 min | Two syntax test files, findings documented |
| Stage 2 — StrategicObjective restructuring | 30–40 min | requirement def + four migrated usages |
| Stage 3 — Formal ref additions | 40–50 min | Typed refs in ScenarioDefinition, Capability, ResourceConstraint |
| Stage 4 — Satisfy + Enterprise enrichment | 30–40 min | Satisfy relationships + enriched Enterprise::Strategy |
| Stage 5 — Coffee shop demonstrator | 20–30 min | Lightweight governance/strategy cross-refs |
| Stage 6 — Documentation and commit | 20 min | Syntax ref v3.11, session report, deferred items |

Total: approximately 2.5–3 hours.

---

## 14. Success Criteria

Phase 7 is successful if:

1. **StrategicObjective is a `requirement def`** with `satisfy` relationships to Capability usages, preserving formal traceability for future tooling.
2. **At least one formal `ref`** replaces a string reference (ScenarioDefinition → ServiceOffering or Capability → ServiceOffering), establishing the typed cross-reference pattern.
3. **Enterprise::Strategy is enriched** with a `StrategicContext` part def that bridges the outer ring to the business model layer.
4. **No circular import dependencies** are introduced. The dependency direction flows inward: BusinessStrategy → Enterprise (satisfy), BusinessScenarios → BusinessModel::ServiceConcept (ref), BusinessModel::ResourcePlanning → BusinessStrategy (satisfy) + Enterprise::Regulation (ref).
5. **All model files parse clean** in Syside after all changes.
6. **Syntax verification results are documented** — whether patterns succeed or fail, the findings are recorded in the syntax reference.
7. **Coffee shop parity** validates at least one formal cross-reference in a non-clinical domain.

---

## 15. Dependency Direction Summary

After Phase 7, the import dependency graph for the business/strategy/enterprise triangle is:

```
BusinessStrategy
    → BusinessScenarios          (ref to ScenarioDefinition)
    [no import from Enterprise]  (cross-refs via String + doc blocks)

BusinessScenarios
    → BusinessModel::ServiceConcept   (ref to ServiceOffering)
    → Knowledge::LogicEngine          (existing, Phase 6B)
    → Foundation::CommonTypes         (existing, Phase 6B)

BusinessModel::ResourcePlanning
    → BusinessStrategy               (satisfy requirement by capability)
    → Enterprise::Regulation          (ref to regulatory requirement defs)

Enterprise
    [no imports from Business* packages]  (outer ring does not depend on inner)
```

This preserves the layering principle: Enterprise is the outermost ring and depends on nothing inward. BusinessModel and BusinessStrategy depend on Enterprise (for regulatory traceability) and on each other (objectives → scenarios, scenarios → offerings). The Knowledge layer is referenced by BusinessScenarios (for steering cycle wiring, Phase 6B) but does not reference back.

---

*Plan prepared 11 March 2026. Phase 7 of the Business Meta Model implementation — governance mapping and strategy elaboration.*
