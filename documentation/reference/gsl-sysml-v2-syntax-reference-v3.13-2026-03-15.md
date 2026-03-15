# SysML v2 Syntax Reference — Syside Modeler

> **Version:** 3.13 — 15 March 2026
> **Previous version:** v3.12 (15 March 2026). Full version history in `documentation/reference/versions/`
> **Purpose:** Concise reference for writing `.sysml` files against Syside Modeler.
> Consult before writing new SysML code. Update as new patterns are verified.
>
> **Companion documents:**
> - `gsl-validated-architectural-patterns.md` — integration patterns, generation pipelines, design rationale
> - `gsl-guide-repo-conventions.md` — file structure, generators, git practices, `gsl` toolkit
>
> **What's new in v3.13:** Session 31 Knowledge Graph Enhancement. `ref :>> fieldName = (targetA, targetB);` tuple redefinition between peer part usages verified — single target, multi-valued tuple, circular refs, cross-type refs, and forward references all work. This is the syntax used for the PatternCatalogue semantic relationship layer (~43 typed ref links).

---

## Environment

- **Syside Modeler** 0.8.5 (VS Code extension, 1 March 2026). Full SysML v2.0 support claimed.
- **Syside Automator** 0.8.5 (Python, PyPI). Semantic model access via `evaluate_filter` and `evaluate_feature`.
- **SysML v2.0** (OMG ratified July 2025) / **KerML 1.0**
- **Standard import:** `private import ScalarValues::*;` required at top of each package
- **Cross-project imports:** Syside resolves across all `.sysml` files in the VS Code workspace folder tree

**Cross-project specific named imports:** Do NOT work in Syside 0.8.5. `private import Foundation::CommonTypes::PersistencePolicy;` fails with "No Membership named 'PersistencePolicy' found." Use wildcard form: `private import Foundation::CommonTypes::*;` (verified v3.12, Session 29).

**⚠️ Wildcard import name collision (v3.12):** When two `private import X::*;` statements bring in types with the same name (e.g. `CoffeeShop::CatalogueEntry` and `BusinessModel::ServiceConcept::CatalogueEntry`), Syside resolves silently to one definition — no warning. Type-errors appear downstream on `:>>` redefinitions, not at the import site. **Fix:** Qualify the ambiguous type with its full package path: `part x : CoffeeShop::CatalogueEntry { ... }`. See `gsl-guide-repo-conventions.md` §9 for the standing convention.

---

## 1. Packages and Imports

```sysml
package MyPackage {
    private import ScalarValues::*;
    private import OtherPackage::*;
    private import OtherPackage::SubPackage::*;

    doc /* Package documentation — attaches to enclosing element.
         * Valid inside package, part def, action def, state def,
         * metadata def, use case def, constraint def, requirement def. */
}
```

**Multi-file model:** Each file declares a standalone top-level package. A root file assembles them via `private import`. Syside does NOT merge same-named packages across files — this triggers `global-namespace-distinguishability` errors.

**Sibling package import:** `private import SameTopLevel::SiblingPackage::*;` from within the same file resolves correctly (verified v3.2).

**Cross-project import of enum-typed attributes:** When a part def in package A has an attribute typed as an enum def from package A, and package B imports from A, the enum type and its literals (`EnumName::literal`) both resolve correctly through the import chain. Verified v3.8: `BusinessModel::ActivityModel::ActivityCategory` used as an attribute type and in `:>>` redefinitions from the exercises directory. Extended v3.10: `BusinessModel::ScenarioModelling::GrowthShape` with camelCase literal `sCurve` resolves correctly from exercises directory.

---

## 2. Part Definitions and Attributes

```sysml
part def MenuItem {
    attribute name : String;
    attribute price : Real;
}

part def Drink :> MenuItem {                  // specialisation
    attribute size : DrinkSize;
    ref customer : Customer;                  // reference (independent)
    part orderLines : OrderLine[1..*];        // composition (contained)
    part subItems : Drink[0..*];              // recursive self-containment ✅ (v3.5)
}
```

**Multiplicity on contained parts:** `part x : XDef[0..*]` works (verified v3.5).

**Recursive self-referential containment:** A `part def` can contain a part typed by itself (verified v3.5).

### References with multiplicity (verified v3.11)

```sysml
part def ScenarioDefinition {
    ref activeServiceOfferings : ServiceOffering[0..*];   // cross-package ref ✅
    attribute activeOfferingsDescription : String;
}
```

**`ref x : Type[0..*]` across packages:** Works with both `[0..*]` and `[1..*]` multiplicity. The ref type can be a part def from a different package, resolved via import. Verified v3.11 with `ServiceOffering` imported from `BusinessModel::ServiceConcept`.

**`ref` inside `requirement def`:** Also works (verified v3.11):

```sysml
requirement def StrategicObjective {
    ref relatedScenarios : ScenarioDefinition[0..*];   // ref in req def ✅
}
```

### ref :>> redefinition with tuple syntax (verified v3.13)

Inside a part usage, `ref :>>` can redefine a multi-valued ref field with a parenthesised tuple of peer part usages:

```sysml
part def Pattern {
    ref dependsOn : Pattern[0..*];
    ref motivatedBy : ArchitecturalPrinciple[0..*];
}

part patternA : Pattern {
    ref :>> dependsOn = (patternB, patternC);           // multi-valued tuple ✅
    ref :>> motivatedBy = (principleAlpha);               // single-target tuple ✅
}

part patternB : Pattern {
    ref :>> dependsOn = (patternA);                       // circular ref ✅
}
```

**Verified (Session 31):**
- Single-target tuple: `ref :>> field = (target);` ✅
- Multi-valued tuple: `ref :>> field = (targetA, targetB);` ✅
- Circular refs between peer parts ✅ (no ownership cycle — refs are not containment)
- Cross-type tuple: Pattern instance referencing ArchitecturalPrinciple peer parts ✅
- Forward references: referencing a part declared later in the same package ✅

This syntax is used for the PatternCatalogue semantic relationship layer (~43 typed ref links across 20 patterns).

### Attribute redefinition with `:>>`

Inside a part usage (instance), redefine inherited attributes with default values:

```sysml
part def ConstraintEvaluationSpec {
    attribute constraintName : String;
    attribute severity : Severity;
}

part consentSpec : ConstraintEvaluationSpec {
    attribute :>> constraintName = "ConsentRecordedConstraint";   // string literal ✅
    attribute :>> severity = Severity::critical;                  // enum literal ✅
}
```

Both string literal and enum literal defaults work (verified v3.5).

**Integer literal defaults** also work (verified v3.6):

```sysml
part row01 : StabilityAssessmentRow {
    attribute :>> minimumWeeksOnTreatment = 12;   // integer literal ✅
}
```

**Real literal defaults** also work (verified v3.9):

```sysml
part clinicianMonth1to9 : ResourceInstance {
    attribute :>> costPerUnit = 2500.0;            // real literal ✅
}
part drinkUnitEconomics : UnitEconomics {
    attribute :>> revenuePerUnit = 3.50;           // real literal ✅
    attribute :>> costPerUnit = 1.90;              // real literal ✅
    attribute :>> marginPerUnit = 1.60;            // real literal ✅
}
```

**Negative Real literal defaults** work (verified v3.10):

```sysml
part outputMonth1 : ProjectionOutput {
    attribute :>> margin = -3288.0;                // negative real ✅
    attribute :>> cumulativeCashFlow = -18500.0;    // negative real ✅
}
```

**Boolean literal defaults** also work (verified v3.7):

```sysml
part baselinePoint : MeasurementPoint {
    attribute :>> isRepeating = false;             // boolean literal ✅
}
part annualPoint : MeasurementPoint {
    attribute :>> isRepeating = true;              // boolean literal ✅
}
```

**All four scalar types confirmed in `:>>`** (v3.9): String, Integer, Real, Boolean — all work as literal defaults in `:>>` redefinitions. Enum literal defaults also work (both cross-package and same-package). Negative Real literals work (v3.10).

**`:>>` redefinitions in requirement usages** work identically to part usages (verified v3.11):

```sysml
requirement objectivePatientCohort : StrategicObjective {
    attribute :>> objectiveName = "Build active patient cohort";  // ✅
    attribute :>> status = "planned";                              // ✅
}
```

**Mixed-type `:>>` redefinitions** — String, Integer, Real, and enum literals in the same file across multiple part usages (verified v3.9, extending v3.8):

```sysml
part assessmentUnitEconomics : UnitEconomics {
    attribute :>> offeringRef = "Initial Assessment";     // string ✅
    attribute :>> revenuePerUnit = 600.0;                 // real ✅
    attribute :>> costPerUnit = 350.0;                    // real ✅
    attribute :>> marginPerUnit = 250.0;                  // real ✅
    attribute :>> breakdownNotes = "Clinician 2hrs...";   // string ✅
}
part perEpisodePricing : PricingModel {
    attribute :>> pricingType = PricingType::perEpisode;  // enum (same-package) ✅
    attribute :>> basePrice = 3.50;                       // real ✅
}
```

**Part def specialisation with `:>>`** — inherited attributes can be redefined on a specialised part def (verified v3.6):

```sysml
part def RegimenSelectionTable :> DecisionTableDef {
    attribute :>> tableName = "regimenSelection";         // string on specialised def ✅
    attribute :>> hitPolicy = HitPolicy::unique;           // enum on specialised def ✅
}
```

**Scale:** Eighteen `:>>` redefinitions across multiple part usages in a single sub-package (v3.10, ScenarioModelling projection parameters). Ten in a single part usage (v3.7, outcome definitions). Seven in a single usage (v3.6, decision table rows).

**Not yet tested:** Nested `:>>` redefinition inside contained parts inside part usages.

---

## 3. Enumerations

```sysml
enum def DrinkSize { small; medium; large; }

enum def EvaluationOutcome {
    doc /* Doc blocks work inside enum defs. */
    pass;
    fail;
    indeterminate;
}
```

**CamelCase enum literals:** Syside lexer accepts camelCase enum literals with leading lowercase (verified v3.10): `sCurve` in `GrowthShape` enum.

**Multiple enum defs in same sub-package:** Two or more enum defs coexist without conflict. Both usable as attribute types and in `:>>` redefinitions within the same file and from cross-project imports (verified v3.10: `GrowthShape` + `VarianceSource` in ScenarioModelling).

### Safe enum literal names (verified v3.5, extended v3.6, v3.7, v3.9, v3.10)

**v3.5 (24 words):** `entity`, `system`, `pass`, `fail`, `domain`, `platform`, `patient`, `cohort`, `pathway`, `clinical`, `operational`, `infrastructure`, `governance`, `automatic`, `recommended`, `advisory`, `healthy`, `degraded`, `unreachable`, `critical`, `warning`, `informational`, `cdr`, `temporal`

**v3.6 (38 additional words, 62 total):** `low`, `normal`, `high`, `suppressed`, `oestrogen`, `testosterone`, `combined`, `noContraindication`, `vteRisk`, `liverDisease`, `cardiacRisk`, `multiple`, `oral`, `transdermal`, `intramuscular`, `subcutaneous`, `estradiolValerate`, `estradiolGel`, `estradiolPatch`, `testosteroneUndecanoate`, `testosteroneEnantate`, `testosteroneGel`, `standardDose`, `reduced`, `satisfied`, `neutral`, `dissatisfied`, `stable`, `improving`, `adjustmentNeeded`, `concerning`, `continueCurrentRegimen`, `adjustDose`, `reduceMonitoringInterval`, `increaseMonitoringInterval`, `clinicalReviewUrgent`, `unique`, `firstMatch`, `collect`

**v3.7 (16 additional words, 78 total):** `pending`, `measured`, `targetMet`, `targetNotMet`, `baseline`, `threeMonthly`, `sixMonthly`, `annually`, `adHoc`, `patientReported`, `adherence`, `safety`, `within`, `greaterThan`, `lessThan`, `equalTo`

**v3.9 (5 additional words, 83 total):** `perEpisode`, `subscription`, `tiered`, `slidingScale`, `flatFee`

**v3.10 (9 additional words, 92 total):** `linear`, `stepped`, `sCurve`, `custom`, `volume`, `price`, `mix`, `timing`, `envelope`

### Cross-package enum usage

Enum types imported via `private import Foundation::CommonTypes::*;` resolve as attribute types and as literal values in `:>>` redefinitions (verified v3.5). Also verified from exercises directory via `private import BusinessModel::ActivityModel::*;` (v3.8). Same-package enum `:>>` also works: `PricingType::perEpisode` within `FinancialPlanning` (v3.9). CamelCase literals resolve through cross-project imports: `GrowthShape::sCurve` from exercises directory (v3.10).

---

## 4. State Machines

```sysml
attribute def PreparationStarted;    // events as attribute defs
attribute def PreparationComplete;

state def OrderLifecycle {
    initial;              // standalone pseudostate — NOT a modifier
    state placed;
    state inPreparation;
    state ready;

    transition placed_to_inPreparation
        first placed
        accept PreparationStarted
        then inPreparation;

    transition inPreparation_to_ready
        first inPreparation
        accept PreparationComplete
        then ready;
}
```

### Connecting to structural model

```sysml
part def Order {
    exhibit state orderLifecycle : OrderLifecycle;
}
```

### State def specialisation

```sysml
state def SpecialisedLifecycle :> BaseLifecycle {
    state dispatched;                              // additional state
    transition active_to_dispatched                // additional transition
        first active accept ItemDispatched then dispatched;
}
```

`exhibit state` works with specialised state defs (verified v3.3).

### ⚠️ Traps

| Trap | Error | Fix |
|---|---|---|
| `initial state placed;` | Parse error | `initial;` then `state placed;` — separate declarations |
| `state ordered;` | `ordered` is a keyword | Use `requested` or synonym |
| `state accepted;` | Shadows KerML `accepted` | Prefix: `referralAccepted` |

---

## 5. Action Flows

```sysml
action def FulfilDrink {
    in item orderLine : OrderLine;

    action receiveOrder;
    then checkDrinkType;

    action checkDrinkType;
    then prepareHot;              // branch 1
    then prepareCold;             // branch 2 (multiple then = branching)

    action prepareHot { doc /* ... */ }
    then assembleDrink;           // convergence (multiple → same target)

    action prepareCold { }
    then assembleDrink;

    action assembleDrink;
}
```

**`then` is positional** — chains from the action declaration immediately above it.

**Backward `then` reference:** `then earlierAction;` resolves by name within the enclosing `action def`, creating loops (verified v3.2).

### ⚠️ Traps

| Trap | Error | Fix |
|---|---|---|
| `succession X then Y;` (standalone) | Reference error | Use `then Y;` chained after action declaration |
| `then X if condition;` (guard) | Parse error / parameter-membership-owning-type | Not supported. Use doc comments for conditions |

---

## 6. Control Nodes

### Decide / Merge (verified v3.3)

```sysml
decide decideDrinkType;
then prepareHot;
then prepareCold;

action prepareHot { }
then mergeAfterPrep;

action prepareCold { }
then mergeAfterPrep;

merge mergeAfterPrep;
then serveDrink;
```

### Fork / Join (verified v3.3)

```sysml
fork forkPreparation;
then prepareEspresso;
then steamMilk;

action prepareEspresso { }
then joinPreparation;

action steamMilk { }
then joinPreparation;

join joinPreparation;
then assembleDrink;
```

Three or more parallel branches work. Names are case-sensitive.

---

## 7. Requirements and Constraints

```sysml
requirement def BloodMonitoringRequired {
    doc /* Patients must have blood tests at defined intervals. */
    subject patient : Patient;
    attribute monitoringIntervalWeeks : Integer;
}

constraint def BloodMonitoringIntervalConstraint {
    in weeksSinceLastTest : Integer;
    in requiredIntervalWeeks : Integer;

    weeksSinceLastTest <= requiredIntervalWeeks    // bare expression, NO semicolon
}
```

**`requirement def` with business-domain attributes** (verified v3.11): requirement defs can contain arbitrary typed attributes, `ref` with multiplicity, and `subject` (typed or untyped). Not limited to clinical/regulatory requirements:

```sysml
requirement def StrategicObjective {
    subject genderSenseService;                         // untyped subject ✅
    attribute objectiveName : String;
    ref relatedScenarios : ScenarioDefinition[0..*];    // ref in req def ✅
}

requirement objectivePatientCohort : StrategicObjective {
    attribute :>> objectiveName = "Build active patient cohort";  // ✅
}
```

### Boolean operators in constraint bodies

`implies`, `and`, `or`, `>=`, `<=`, `==`, `::` (enum reference), `( )` (grouping)

### Satisfy relationships

```sysml
// In a DIFFERENT package from the requirement def:
private import Enterprise::Regulation::*;

constraint bloodMonitoringCheck : BloodMonitoringIntervalConstraint;

satisfy requirement BloodMonitoringRequired
    by bloodMonitoringCheck;      // target must be a constraint usage
```

**Trap:** `satisfy` in the same package as the `requirement def` causes `namespace-distinguishability` shadow warning. Keep them in separate packages.

**⚠️ Critical trap (v3.11):** `satisfy requirement X by partUsage` **fails** with `type-error`. The `by` target must be a constraint or requirement usage — **not** a `part` usage. `satisfy` is designed for requirement→constraint traceability. For requirement→capability (part) traceability, use a dedicated mapping part def with typed `ref` instead.

**⚠️ Satisfy naming traps (v3.11):**

| Form | Problem |
|---|---|
| `satisfy requirement importedReq by target;` | `namespace-distinguishability` — creates local usage shadowing import |
| `satisfy requirement localName : reqUsage by target;` | `usage-feature-typing` — usages must be typed by classifiers, not other usages. Will become error in v0.9. |
| `satisfy requirement localName : ReqDef by constraintUsage;` | ✅ Correct form — unique local name, typed by classifier (def), constraint target |

**`verify` relationships:** Not supported in Syside 0.8.5 (`Unexpected 'verify'`).

---

## 8. Metadata Definitions

### Declaring

```sysml
metadata def TemporalWorkflow {
    doc /* Marks an action def as a Temporal workflow. */
    attribute workflowName : String;
    attribute taskQueue : String;
}
```

### Applying

```sysml
action def MyWorkflow {
    @TemporalWorkflow {
        workflowName = "fulfilDrink";    // bare assignment, no 'attribute' keyword
        taskQueue = "coffeeshop";        // semicolon-terminated
    }
}

action myStep {
    @TemporalActivity { activityName = "validate"; }
    @StateTransitionTrigger { eventName = "OrderPlaced"; }    // multiple annotations OK
}
```

### Where metadata works

| Target | Status |
|---|---|
| `action def` body | ✅ Works |
| `action` step body (must have braces) | ✅ Works |
| `part def` body | ✅ Works (verified v3.4) |
| `part def` body alongside `:>>` usages | ✅ Works (verified v3.7) |
| `attribute` body | ✗ Fails — parser rejects `@` inside attribute bodies |
| `state def`, `requirement def` | Not tested |
| Simple `action name;` (no braces) | ✗ Fails — needs body to hold annotation |
| Enum-typed attribute on `metadata def` | ✅ Works (v3.12, Session 29). Enum and metadata def must be in same package. |

### References to metadata def and enum def types (verified v3.12)

`ref` can target `metadata def` and `enum def` types, both singular and multi-valued:

```sysml
part def TestRefToMetadata {
    ref relatedMetadata : ClinicalReviewGate;         // ref to metadata def ✅
    ref relatedMetadataList : ClinicalReviewGate[0..*]; // multi-valued ✅
    ref relatedEnum : AgencyType;                      // ref to enum def ✅
    ref relatedEnumList : AgencyType[0..*];            // multi-valued ✅
}
```

Verified Session 30 (Concept Graph workstream). All four patterns parse cleanly.

### Per-attribute documentation workaround

```sysml
part def OrderRecord {
    @OpenEhrArchetype { archetypeId = "openEHR-EHR-OBSERVATION.order_record.v0"; rmClass = "OBSERVATION"; }
    attribute drinkName : DrinkName;     // at0005 | DV_CODED_TEXT
    attribute feedbackComment : String;  // at0003 | DV_TEXT
}
```

Use `@metadata` on `part def` for machine-queryable traceability; `//` comments on attributes for per-element mapping. `doc /* */` after semicolon-terminated attributes also fails.

---

## 9. Use Case Definitions

```sysml
use case def EvaluateEligibility {
    doc /* Determine whether a patient meets eligibility criteria. */
}
```

Basic `use case def` with `doc` verified (v3.1). Advanced patterns (`include use case`, `extend use case`, `subject`, `actor`) not yet tested.

---

## 10. Reserved Words and Name Traps

| Word | Problem | Context |
|---|---|---|
| `ordered` | SysML v2 keyword (multiplicity modifier) | State names, attribute names |
| `accepted` | Shadows KerML `StatePerformances::StatePerformance::accepted` | State names |
| `comment` | SysML v2 keyword (`comment about`) | Attribute names |
| `standard` | KerML reserved (standard library namespace) | Enum literals, attribute names (v3.6) |
| `action` | SysML v2 keyword (`action def`, `action`) | Attribute names (v3.6) |
| `default` | KerML reserved | Attribute names (v3.10 — identified from KerML 1.0 §8.2.2.6, not tested) |
| `system` | KerML reserved | Enum literals (v3.12 — Session 29). Silent parse failure: Foundation package becomes unresolvable, cascading reference-errors. No error at the literal itself. Use `automated` or compound names. |

### Confirmed safe as attribute names

The following words were explicitly tested and confirmed safe: `channel`, `level`, `source`, `target`, `scope`, `basis` (v3.8), `category`, `limit` (v3.9), `output` (v3.10), `type` (v3.7), `name`, `description`, `route`, `direction`, `strategicObjectiveRef`, `contextName`, `currentVariant`, `governanceNotes`, `objectiveRef`, `activeServiceOfferings`, `enabledServiceOfferings`, `supportingCapabilities`, `activeOfferingsDescription`, `enabledOfferingsDescription`, `regulatorySourceDescription`, `strategicHorizonMonths` (v3.11).

**Compound names with reserved words:** `objectiveRef` is safe (`objective` is a SysML keyword). `currentVariant` is safe (`variant` is a SysML keyword). Compound names avoid the reserved word restriction (v3.11).

### Confirmed safe as enum literal names (near reserved words)

`stepped` (near `step`), `sCurve` (camelCase) — both confirmed v3.10.

**General rule:** Avoid short generic English words as identifiers. Use compound names (`referralAccepted`, `feedbackComment`, `standardDose`, `monitoringAction`). All enum literals listed in Section 3 are confirmed safe.

### Part def name collision with package names

**Trap (v3.11):** A part def named `BusinessModel` inside `Enterprise::Strategy` creates ambiguity with the top-level `BusinessModel` package. This was resolved by renaming to `StrategicContext`. Avoid naming part defs identically to top-level packages.

### KerML/SysML reserved words to avoid as attribute names

The following are reserved keywords from KerML 1.0 section 8.2.2.6 and SysML 2.0 that have been identified as relevant to business/clinical modelling attribute naming: `abstract`, `accept`, `action`, `alias`, `all`, `allocation`, `and`, `as`, `assert`, `assign`, `attribute`, `binding`, `comment`, `connection`, `constraint`, `decide`, `default`, `dependency`, `doc`, `else`, `end`, `entry`, `enum`, `event`, `exhibit`, `exit`, `filter`, `first`, `flow`, `fork`, `frame`, `if`, `import`, `in`, `include`, `inout`, `interface`, `istype`, `item`, `join`, `loop`, `merge`, `message`, `metadata`, `not`, `objective`, `occurrence`, `of`, `or`, `ordered`, `out`, `package`, `parallel`, `part`, `perform`, `port`, `private`, `public`, `readonly`, `ref`, `render`, `requirement`, `return`, `satisfy`, `send`, `snapshot`, `specializes`, `state`, `subject`, `subsets`, `succession`, `then`, `to`, `transition`, `type`, `variant`, `variation`, `verify`, `view`, `viewpoint`.

**Safe practice:** Always use compound names when in doubt (e.g. `constraintName` not `constraint`, `triggerEvent` not `trigger`, `pricingType` not `type`).

---

## 11. Type Mapping: SysML v2 → TypeScript

| SysML v2 | TypeScript |
|---|---|
| `String` | `string` |
| `Boolean` | `boolean` |
| `Integer` | `number` |
| `Real` | `number` |
| `enum def X` | `enum X` |
| `part def X` | `interface X` |
| `part def X :> Y` | `interface X extends Y` |
| `ref x : Type;` | `x: Type;` (reference) |
| `ref x : Type[0..*];` | `x: Type[];` (reference array, v3.11) |
| `part x : Type[1..*];` | `x: Type[];` (array) |

---

## TODO: Patterns Not Yet Verified

- [ ] Port definitions and connections
- [x] `metadata def` with non-scalar attribute types (e.g. enum-valued metadata attributes) — **verified v3.12** (Session 29)
- [ ] `metadata def` specialisation (one metadata def extending another)
- [ ] `metadata def` applied to `state def` or `requirement def` elements
- [ ] `use case def` with `include use case`, `extend use case`, `subject`, `actor`
- [ ] SysML v2 `view` and `viewpoint` elements — Sensmetry forum (Jan 2026) confirms rendering from modelled views is "still a work in progress." Deferred.
- [ ] Syside CLI `viz` command for headless diagram export
- [ ] Generator: `gen_temporal_workflow.py` emitting `tryTransition()` from `@StateTransitionTrigger`
- [ ] Generator: `Promise.all()` from SysML `fork`/`join`
- [ ] Nested `:>>` redefinition inside contained parts inside part usages
- [ ] `ref` to a `requirement def` as a type (e.g. `ref regulatoryReq : ConsentBeforeTreatment`) — deferred from Phase 7
- [x] `ref :>> fieldName = (peerPartA, peerPartB);` — tuple redefinition between peer part usages — **verified v3.13** (Session 31)

---

## Version History

| Version | Date | Key additions |
|---|---|---|
| 3.13 | 15 Mar 2026 | `ref :>>` tuple redefinition verified (single, multi-valued, circular, cross-type, forward reference). PatternCatalogue knowledge graph: 43 typed ref links across 20 patterns. |
| 3.12 | 15 Mar 2026 | `ref x : MetadataDef` and `ref x : EnumDef` verified (singular + multi-valued), `system` reserved word (silent failure), enum-typed attribute on metadata def verified, cross-project specific named imports fail, **wildcard import name collision** (silent resolution, downstream type-errors), multi-valued enum attribute on part def verified |
| 3.11 | 11 Mar 2026 | `ref x : Type[0..*]` across packages, `ref` in `requirement def`, `requirement def` with business attributes, **satisfy by part usage fails** (critical finding), satisfy naming traps (shadow, usage-feature-typing), `:>>` in requirement usages, part def / package name collision trap, 12 new safe attribute names |
| 3.10 | 11 Mar 2026 | Negative Real `:>>` verified, `output`/`stepped`/`sCurve` confirmed safe, camelCase enum literals verified, multiple enum defs in same sub-package, `default` flagged as reserved, 9 new safe enum literals (92 total) |
| 3.9 | 10 Mar 2026 | Real `:>>` defaults verified, `category` and `limit` safe, same-package enum `:>>`, 5 new safe enum literals, KerML reserved word reference list added |
| 3.8 | 10 Mar 2026 | Six attribute names confirmed safe (`channel`, `level`, `source`, `target`, `scope`, `basis`), cross-project enum-typed attribute import verified, mixed String+Integer `:>>` in single usage |
| 3.7 | 9 Mar 2026 | Boolean `:>>` defaults, 10 `:>>` in one usage, `@OpenEhrArchetype` alongside `:>>`, 16 new safe enum literals |
| 3.6 | 9 Mar 2026 | Integer `:>>` defaults, part def specialisation with `:>>`, seven `:>>` in one usage, `standard` and `action` reserved, 38 new safe enum literals |
| 3.5 | 8 Mar 2026 | Multiplicity on contained parts, recursive containment, `:>>` redefinition, cross-package enum imports |
| 3.4 | 8 Mar 2026 | openEHR metadata on part defs, `@metadata` on attribute fails, `comment` reserved, `//` comments on attributes |
| 3.3 | 6 Mar 2026 | `decide`/`merge`, `fork`/`join`, state def specialisation, guard conditions fail, `verify` fails |
| 3.2 | 6 Mar 2026 | Entity lifecycle state machines, `exhibit state`, reserved name traps, clinical metadata on actions, backward `then`, sibling import |
| 3.1 | 5 Mar 2026 | Syside 0.8.5, `use case def`, package hierarchy verification, Automator evaluation |
| 3.0 | 3 Mar 2026 | Phase C integration (XState in Temporal + SvelteKit), metadata-driven generation |
| 2.0 | 3 Mar 2026 | Metadata definitions, Temporal workflow generator, two-layer architecture |
| 1.0 | 1 Mar 2026 | Initial: structural, state machines, action flows, requirements, constraints, generation |

Previous versions preserved in `documentation/reference/versions/`.

---

*Restructured 8 March 2026 (Session 8). Updated 15 March 2026 (Sessions 29–31, CSW Phase 10 + Concept Graph + Knowledge Graph Enhancement).*
