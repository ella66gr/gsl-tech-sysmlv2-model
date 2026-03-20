# SysML v2 Syntax Reference — Syside Modeler

> **Version:** 3.7 — 9 March 2026
> **Previous version:** v3.6 (9 March 2026). Full version history in `documentation/reference/versions/`
> **Purpose:** Concise reference for writing `.sysml` files against Syside Modeler.
> Consult before writing new SysML code. Update as new patterns are verified.
>
> **Companion documents:**
> - `gsl-validated-architectural-patterns.md` — integration patterns, generation pipelines, design rationale
> - `gsl-guide-repo-conventions.md` — file structure, generators, git practices, `gsl` toolkit
>
> **What's new in v3.7:** Knowledge Layer Phase 4 (OutcomeFramework) — `:>>` with boolean literal defaults, 10 `:>>` redefinitions in a single part usage, `@OpenEhrArchetype` on part def containing `:>>` usages. 16 additional common English words confirmed safe as enum literals (78 total).

---

## Environment

- **Syside Modeler** 0.8.5 (VS Code extension, 1 March 2026). Full SysML v2.0 support claimed.
- **Syside Automator** 0.8.5 (Python, PyPI). Semantic model access via `evaluate_filter` and `evaluate_feature`.
- **SysML v2.0** (OMG ratified July 2025) / **KerML 1.0**
- **Standard import:** `private import ScalarValues::*;` required at top of each package
- **Cross-project imports:** Syside resolves across all `.sysml` files in the VS Code workspace folder tree

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

**Boolean literal defaults** also work (verified v3.7):

```sysml
part baselinePoint : MeasurementPoint {
    attribute :>> isRepeating = false;             // boolean literal ✅
}
part annualPoint : MeasurementPoint {
    attribute :>> isRepeating = true;              // boolean literal ✅
}
```

**Part def specialisation with `:>>`** — inherited attributes can be redefined on a specialised part def (verified v3.6):

```sysml
part def RegimenSelectionTable :> DecisionTableDef {
    attribute :>> tableName = "regimenSelection";         // string on specialised def ✅
    attribute :>> hitPolicy = HitPolicy::unique;           // enum on specialised def ✅
}
```

**Scale:** Ten `:>>` redefinitions in a single part usage verified (v3.7, outcome definitions). Seven verified previously (v3.6, decision table rows).

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

### Safe enum literal names (verified v3.5, extended v3.6, v3.7)

**v3.5 (24 words):** `entity`, `system`, `pass`, `fail`, `domain`, `platform`, `patient`, `cohort`, `pathway`, `clinical`, `operational`, `infrastructure`, `governance`, `automatic`, `recommended`, `advisory`, `healthy`, `degraded`, `unreachable`, `critical`, `warning`, `informational`, `cdr`, `temporal`

**v3.6 (38 additional words, 62 total):** `low`, `normal`, `high`, `suppressed`, `oestrogen`, `testosterone`, `combined`, `noContraindication`, `vteRisk`, `liverDisease`, `cardiacRisk`, `multiple`, `oral`, `transdermal`, `intramuscular`, `subcutaneous`, `estradiolValerate`, `estradiolGel`, `estradiolPatch`, `testosteroneUndecanoate`, `testosteroneEnantate`, `testosteroneGel`, `standardDose`, `reduced`, `satisfied`, `neutral`, `dissatisfied`, `stable`, `improving`, `adjustmentNeeded`, `concerning`, `continueCurrentRegimen`, `adjustDose`, `reduceMonitoringInterval`, `increaseMonitoringInterval`, `clinicalReviewUrgent`, `unique`, `firstMatch`, `collect`

**v3.7 (16 additional words, 78 total):** `pending`, `measured`, `targetMet`, `targetNotMet`, `baseline`, `threeMonthly`, `sixMonthly`, `annually`, `adHoc`, `patientReported`, `adherence`, `safety`, `within`, `greaterThan`, `lessThan`, `equalTo`

### Cross-package enum usage

Enum types imported via `private import Foundation::CommonTypes::*;` resolve as attribute types and as literal values in `:>>` redefinitions (verified v3.5).

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

### Boolean operators in constraint bodies

`implies`, `and`, `or`, `>=`, `<=`, `==`, `::` (enum reference), `( )` (grouping)

### Satisfy relationships

```sysml
// In a DIFFERENT package from the requirement def:
private import Enterprise::Regulation::*;

constraint bloodMonitoringCheck : BloodMonitoringIntervalConstraint;

satisfy requirement BloodMonitoringRequired
    by bloodMonitoringCheck;      // target must be a usage, not a def
```

**Trap:** `satisfy` in the same package as the `requirement def` causes `namespace-distinguishability` shadow warning. Keep them in separate packages.

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

**General rule:** Avoid short generic English words as identifiers. Use compound names (`referralAccepted`, `feedbackComment`, `standardDose`, `monitoringAction`). All enum literals listed in Section 3 are confirmed safe.

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
| `part x : Type[1..*];` | `x: Type[];` (array) |

---

## TODO: Patterns Not Yet Verified

- [ ] Port definitions and connections
- [ ] `metadata def` with non-scalar attribute types (e.g. enum-valued metadata attributes)
- [ ] `metadata def` specialisation (one metadata def extending another)
- [ ] `metadata def` applied to `state def` or `requirement def` elements
- [ ] `use case def` with `include use case`, `extend use case`, `subject`, `actor`
- [ ] SysML v2 `view` and `viewpoint` elements — Sensmetry forum (Jan 2026) confirms rendering from modelled views is "still a work in progress." Deferred.
- [ ] Syside CLI `viz` command for headless diagram export
- [ ] Generator: `gen_temporal_workflow.py` emitting `tryTransition()` from `@StateTransitionTrigger`
- [ ] Generator: `Promise.all()` from SysML `fork`/`join`
- [ ] Nested `:>>` redefinition inside contained parts inside part usages

---

## Version History

| Version | Date | Key additions |
|---|---|---|
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

*Restructured 8 March 2026 (Session 8). Updated 9 March 2026 (Session 11, Phase 4).*
