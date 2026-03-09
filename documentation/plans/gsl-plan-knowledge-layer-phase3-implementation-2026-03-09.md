# Knowledge Layer Elaboration — Phase 3 Implementation Plan

**Date:** 9 March 2026 (Session 10)
**Context:** Phase 3 of the Knowledge Layer Elaboration, as defined in the extended planning document. Phase 1 (Session 8) established the evaluation and self-knowledge data structures. Phase 2 (Session 9) established the LogicEngine component model (16 part defs, 4 elaborated use cases). Phase 3 designs the decision table representation pattern and models the two hormone therapy decision tables.

**Parent plan:** `documentation/plans/gsl-plan-knowledge-layer-elaboration-2026-03-08-extended.md`
**Phase 1 plan:** `documentation/plans/gsl-plan-knowledge-layer-phase1-implementation-2026-03-08.md`
**Phase 2 plan:** `documentation/plans/gsl-plan-knowledge-layer-phase2-implementation-2026-03-09.md`
**Syntax reference:** `documentation/reference/gsl-sysml-v2-syntax-reference-v3.5-2026-03-08.md`
**Architecture decisions:** `documentation/architecture/gsl-architecture-decision-knowledge-evaluation.md`
**Validated patterns:** `documentation/architecture/gsl-validated-architectural-patterns.md`

---

## 1. Scope and Boundaries

### What Phase 3 delivers

Phase 3 elaborates the `Knowledge::DecisionModels` package — currently a doc block with no structural content — into a working representation of clinical decision tables within the SysML model. It addresses a specific architectural question: how do we represent tabular decision logic in SysML v2 (which has no native decision table construct) in a way that is formally traceable, clinician-readable in the model, and generatable to runtime evaluation code?

Specifically:

- A **decision table representation pattern** — a reusable SysML structural pattern for encoding decision tables as part defs with typed inputs, outputs, and row-level rules
- The **regimenSelection** decision table — maps baseline hormones, patient preference, and contraindications to medication, route, and starting dose for the hormone therapy initiation pathway
- The **stabilityAssessment** decision table — maps monitoring results, time-on-treatment, and clinical indicators to a stability classification and monitoring interval adjustment
- **Traceability connections** from the decision tables to the pathway annotations (`@DecisionTable { tableName = "regimenSelection"; }` and `@DecisionTable { tableName = "stabilityAssessment"; }` in `ServiceDelivery::ClinicalPathways::HormoneTherapy`) and to the existing ConstraintLibrary constraint (`RegimenWithinProtocolConstraint`)
- Updated DecisionModels doc block reflecting the elaborated content
- New use case defs for decision table evaluation

### What Phase 3 does NOT deliver

- Runtime code or generators — the TypeScript decision table evaluator is a Phase 5 concern
- Changes to LogicEngine — Phase 2 component model is complete; DecisionModels integrates with it via the existing `@DecisionTable` metadata invocation pattern and the ConstraintEvaluator
- A dedicated DMN engine — decision tables are modelled as SysML structures and will be evaluated by the same Tier 1 infrastructure (generated TypeScript)
- Changes to ConstraintLibrary — the `RegimenWithinProtocolConstraint` already exists; Phase 3 models the decision table it references but does not modify the constraint itself
- Changes to Foundation::CommonTypes — new enums only if the decision table pattern requires value types not already defined (assessment below suggests two new enums are likely needed)
- Actual clinical protocol data — the decision table rows use representative, clinically plausible values for modelling purposes, not validated prescribing protocol data; real data will be loaded from a clinical source before any runtime use

### Relationship to Phase 2

Phase 2 established the evaluation infrastructure. Phase 3 feeds into it:

| Phase 2 component | Phase 3 relationship |
|---|---|
| ConstraintEvaluator | Decision tables are consumed via the same evaluation pathway — the `@DecisionTable` metadata triggers the evaluator, which looks up the table spec |
| EvaluationSpecRegistry | Decision table specs are registered alongside constraint evaluation specs |
| InputResolver | Decision table inputs are derived from the same authoritative sources (CDR, entity state) using the same InputDerivation pattern |
| ExplanationBuilder | Decision table evaluations produce EvaluationResults with the same ExplanationTrace structure — the trace shows which row matched and why |

### Relationship to the pathway

The hormone therapy domain-layer action flow has two `@DecisionTable` annotations:

1. **`selectRegimen`** step: `@DecisionTable { tableName = "regimenSelection"; }` — selects the medication, route, and starting dose
2. **`assessStabilityDecision`** step: `@DecisionTable { tableName = "stabilityAssessment"; }` — determines whether the regimen is stable or requires dose adjustment

These annotations name decision tables that Phase 3 defines. The pathway also has `@ClinicalReviewGate` on `selectRegimen`, meaning the decision table result is a recommendation to the clinician, not an automatic action — the clinician makes the final prescribing decision informed by the table output.

### Files affected

| File | Expected changes |
|---|---|
| `model/knowledge.sysml` | DecisionModels package: new part defs (table pattern, two tables, supporting types), new use cases, updated doc block |
| `model/foundation.sysml` | CommonTypes: new enums if required by decision table value types (see Stage 2 analysis) |
| `documentation/reference/gsl-sysml-v2-syntax-reference-v3.6-*.md` | Updated if new syntax patterns are verified or traps discovered |
| `documentation/session-reports/gsl-session-report-2026-03-09-s10.md` | Session report |

---

## 2. Pre-flight Checks

| Check | Action | Status |
|---|---|---|
| 2.1 | Verify Phase 2 model changes committed to git (16 new part defs in LogicEngine) | ☐ Ella to confirm |
| 2.2 | Run `gsl` to confirm hierarchy shows LogicEngine with 21 part defs, 4 use cases | ☐ Ella to confirm |
| 2.3 | Verify DecisionModels package currently has doc block only, no structural content | ☐ Confirmed from model read |
| 2.4 | Confirm syntax reference v3.5 is current | ☐ Confirmed — uploaded to this session |
| 2.5 | Open `knowledge.sysml` in Syside to confirm clean parse before modifications | ☐ Ella to confirm |
| 2.6 | Verify `@DecisionTable` metadata def exists in `Foundation::MetadataLibrary` with `tableName : String` | ☐ Confirmed from model read |

---

## 3. Design Approach: Decision Tables as SysML Part Defs

### 3.1 The representation problem

SysML v2 has no native decision table construct. DMN (Decision Model and Notation) is a separate OMG standard with its own notation, execution semantics, and tooling. We need to represent tabular decision logic within SysML v2 in a way that is:

1. **Formally correct** — uses standard SysML v2 constructs that Syside parses cleanly
2. **Self-describing** — the table can be read and understood from the model, with doc blocks explaining each input, output, and row
3. **Traceable** — rows can be traced to the `@DecisionTable` metadata annotations on pathway steps, and to the constraints they inform
4. **Generatable** — the table structure maps cleanly to a TypeScript evaluation function (Phase 5)
5. **Clinician-reviewable** — the table content is visible in the Syside model explorer and doc tooltips, not buried in opaque encoding

### 3.2 Approach considered and rejected

**Approach A: One constraint def per table row.** Each row becomes a separate `constraint def` with a boolean expression matching the row's input conditions. This is formally rigorous but impractical — a table with 12 rows produces 12 constraint defs that are individually meaningful only in the context of the table. It obscures the tabular structure and makes the table hard to read as a whole.

**Approach B: Table content in doc blocks or structured string attributes.** The table is encoded as formatted text in a doc block or as a JSON string attribute. This is readable but not formally structured — the table content is opaque to generators and to Syside's semantic model.

**Approach C: Metadata-annotated elements with table rows as structured attributes.** Encode the table as metadata attributes. This pushes too much content into metadata, which is designed for generator configuration, not domain knowledge.

### 3.3 Selected approach: Structural part def pattern

Model each decision table as a set of cooperating `part def` elements:

1. **A table definition** (`part def`) with typed input and output attributes — defines the table's interface (what goes in, what comes out)
2. **Row definitions** (`part def` specialising the table) with `:>>` attribute redefinitions — each row is a concrete instance of the table with specific input conditions and output values
3. **Supporting enum defs** — typed vocabularies for input and output values (medication names, routes, dose ranges, stability classifications)

This approach uses only validated SysML patterns:
- `part def` with attributes (validated extensively)
- `part def` specialisation with `:>` (validated v3.3)
- `:>>` attribute redefinition with string and enum literal defaults (validated v3.5)
- Enum defs with safe literal names (validated v3.5)

**However:** There is one significant syntax question. The `:>>` pattern was validated on **part usages** (e.g. `part consentSpec : ConstraintEvaluationSpec { attribute :>> constraintName = "..."; }`) — instances. Using `:>>` on a **part def specialisation** (e.g. `part def Row1 :> DecisionTableRow { attribute :>> ... }`) is structurally equivalent but has not been explicitly tested in Syside. This needs a syntax test.

**Alternative if `:>>` on part def specialisation fails:** Fall back to part usages (instances) for table rows, exactly as the ConstraintEvaluationSpec pattern works. This is already validated and would work — but it means rows are usages, not defs, which is semantically slightly different (instances vs. types). Either approach serves the purpose.

### 3.4 Pattern structure

```
DecisionModels
├── DecisionTableDef (abstract table interface)
│   ├── attribute tableName : String
│   ├── attribute hitPolicy : HitPolicy
│   └── doc /* describes the table's purpose and semantics */
│
├── RegimenSelectionTable :> DecisionTableDef
│   ├── Inputs:  baselineTestosterone, baselineOestradiol, patientPreference, contraindications
│   ├── Outputs: medication, administrationRoute, startingDose
│   ├── Row definitions (part usages with :>> redefinitions)
│   └── doc /* clinical protocol reference */
│
├── StabilityAssessmentTable :> DecisionTableDef
│   ├── Inputs:  hormoneLevel, timeOnTreatmentWeeks, sideEffectSeverity, patientSatisfaction
│   ├── Outputs: stabilityClassification, monitoringAction
│   └── Row definitions (part usages with :>> redefinitions)
│
├── Supporting enums (HitPolicy, HormoneLevel, StabilityClassification, etc.)
└── Use cases (EvaluateDecisionTable, ...)
```

### 3.5 Hit policy

DMN decision tables have a "hit policy" that defines how to handle multiple matching rows. The relevant policies for clinical decision tables are:

- **Unique (U):** Exactly one row matches. If zero or more than one match, the result is an error. This is the safest policy for safety-critical decisions.
- **First (F):** Rows are ordered; the first matching row wins. Useful for priority-based rules.
- **Collect (C):** All matching rows contribute to the output. Useful for accumulating recommendations.

For hormone therapy: `regimenSelection` uses **Unique** (exactly one protocol combination should match for a given set of inputs). `stabilityAssessment` uses **Unique** (a patient's monitoring results map to exactly one stability classification).

### 3.6 Relationship to the @DecisionTable metadata

The pathway annotation `@DecisionTable { tableName = "regimenSelection"; }` names a table. At runtime, the evaluation flow is:

1. Temporal activity encounters `@DecisionTable` annotation
2. Looks up the table by name in the registry (analogous to `EvaluationSpecRegistry` for constraints)
3. Derives input values from authoritative sources (CDR, entity state) using InputDerivation pattern
4. Evaluates the table: finds the matching row based on input conditions
5. Returns the output values (medication, route, dose) as a structured result with an ExplanationTrace showing which row matched and why
6. The clinician reviews the recommendation at the `@ClinicalReviewGate`

The decision table is effectively a specialised form of constraint evaluation. The `RegimenWithinProtocolConstraint` in ConstraintLibrary checks that the *chosen* regimen is within protocol bounds — the decision table *recommends* a regimen within those bounds. The table and the constraint work in sequence: table recommends → clinician decides → constraint validates.

---

## 4. Foundation: New Enum Defs in CommonTypes

Before modelling the decision tables, we need typed vocabularies for the clinical values. Some values are already represented (e.g. `Severity` for side effects) but several new enums are needed.

### Stage 1 — New enums in Foundation::CommonTypes

**Goal:** Add the clinical vocabulary enums that the decision tables will use as typed input and output values.

#### Step 1.1 — Enum analysis

The regimenSelection table needs:

| Input/Output | Values | Enum needed? |
|---|---|---|
| baselineTestosterone | low, normal, high, suppressed | Yes: `HormoneLevel` |
| baselineOestradiol | low, normal, high, suppressed | Reuses `HormoneLevel` |
| patientPreference | oestrogen, testosterone, combined | Yes: `TherapyPreference` |
| contraindications | none, vteRisk, liverDisease, cardiacRisk, multiple | Yes: `ContraindicationCategory` |
| medication | estradiolValerate, estradiolGel, estradiolPatch, testosteroneUndecanoate, testosteroneEnantate, testosteroneGel | Yes: `HormoneMediation` |
| administrationRoute | oral, transdermal, intramuscular, subcutaneous | Yes: `AdministrationRoute` |
| startingDose | A string/description — but better as an enum of dose categories to keep things typed | Yes: `DoseCategory` |

The stabilityAssessment table needs:

| Input/Output | Values | Enum needed? |
|---|---|---|
| hormoneLevel | Reuses `HormoneLevel` | No (already defined above) |
| timeOnTreatmentWeeks | Integer — scalar, no enum needed | No |
| sideEffectSeverity | Reuses `Severity` from existing CommonTypes | No |
| patientSatisfaction | satisfied, neutral, dissatisfied | Yes: `PatientSatisfaction` |
| stabilityClassification | stable, improving, adjustmentNeeded, concerning | Yes: `StabilityClassification` |
| monitoringAction | continueCurrentRegimen, adjustDose, reduceMonitoringInterval, increaseMonitoringInterval, clinicalReviewUrgent | Yes: `MonitoringAction` |

**Total new enums: 8**

1. `HormoneLevel` — low, normal, high, suppressed
2. `TherapyPreference` — oestrogen, testosterone, combined
3. `ContraindicationCategory` — none, vteRisk, liverDisease, cardiacRisk, multiple
4. `HormoneMedication` — estradiolValerate, estradiolGel, estradiolPatch, testosteroneUndecanoate, testosteroneEnantate, testosteroneGel
5. `AdministrationRoute` — oral, transdermal, intramuscular, subcutaneous
6. `DoseCategory` — low, standard, reduced, high
7. `PatientSatisfaction` — satisfied, neutral, dissatisfied
8. `StabilityClassification` — stable, improving, adjustmentNeeded, concerning
9. `MonitoringAction` — continueCurrentRegimen, adjustDose, reduceMonitoringInterval, increaseMonitoringInterval, clinicalReviewUrgent

(Revised to 9 — MonitoringAction is separate from StabilityClassification.)

**Also needed in DecisionModels (not CommonTypes):**

10. `HitPolicy` — unique, first, collect (decision-table-specific, belongs in DecisionModels)

#### Step 1.2 — Syntax risk assessment for new enums

All proposed enum literal names need checking against the reserved word list and the safe enum literals list (syntax reference Section 3).

| Literal | Risk | Notes |
|---|---|---|
| `low`, `normal`, `high` | LOW | Standard English words, not SysML keywords. Not previously verified but structurally identical to safe literals like `healthy`, `degraded` |
| `suppressed` | LOW | Past participle, same pattern as `recommended` (verified safe) |
| `oestrogen`, `testosterone` | LOW | Clinical domain terms, no SysML conflict |
| `combined` | LOW | Common word but no SysML conflict expected |
| `none` | **MEDIUM** | Could potentially conflict with a KerML keyword or predefined literal. Needs explicit testing. If it fails, use `noContraindication` instead |
| `vteRisk`, `liverDisease`, `cardiacRisk` | LOW | Compound names, safe pattern |
| `multiple` | LOW | Common word, no SysML conflict expected |
| `oral`, `transdermal`, `intramuscular`, `subcutaneous` | LOW | Clinical terms, no SysML conflict |
| `estradiolValerate`, `estradiolGel`, etc. | LOW | Compound clinical terms |
| `stable`, `improving` | LOW | `stable` is not a SysML keyword |
| `standard` | **CONFIRMED TRAP** | SysML v2 / KerML reserved word — parse error in Syside. Use `standardDose` instead |
| `action` | **CONFIRMED TRAP** | SysML v2 keyword (`action def`, `action`). Cannot be used as an attribute name. Use `monitoringAction` instead |
| `adjustmentNeeded`, `concerning` | LOW | Compound / uncommon as keywords |
| `satisfied`, `neutral`, `dissatisfied` | LOW | Standard English, no SysML conflict expected |
| `continueCurrentRegimen`, `adjustDose`, etc. | LOW | Long compound names, safe |
| `unique`, `first`, `collect` | **MEDIUM** | DMN terminology. `first` could potentially conflict (used in transition syntax). Test explicitly. If `first` fails, use `firstMatch` instead |

**Mitigation:** Test any MEDIUM-risk literals in a syntax-tests file before committing to the model.

#### Step 1.3 — SysML code for new enums in CommonTypes

**File:** `model/foundation.sysml` → `Foundation::CommonTypes`

Add after the existing `ServiceHealthStatus` enum (last enum before the closing `}` of CommonTypes):

```sysml
        // Added Session 10: Knowledge Layer Phase 3 (DecisionModels)

        enum def HormoneLevel {
            doc /* Categorised hormone level from blood test results.
                 * Used in decision tables for regimen selection and
                 * stability assessment. */
            low;
            normal;
            high;
            suppressed;
        }

        enum def TherapyPreference {
            doc /* Patient's preference for hormone therapy type.
                 * Captures the direction of therapy as expressed
                 * by the patient during assessment. */
            oestrogen;
            testosterone;
            combined;
        }

        enum def ContraindicationCategory {
            doc /* Categorised contraindication status for prescribing
                 * decisions. Simplification of the full clinical
                 * assessment into categories that drive protocol
                 * selection. */
            noContraindication;
            vteRisk;
            liverDisease;
            cardiacRisk;
            multiple;
        }

        enum def HormoneMedication {
            doc /* Hormone therapy medications in the prescribing
                 * protocol. Each entry represents a specific
                 * pharmaceutical product. */
            estradiolValerate;
            estradiolGel;
            estradiolPatch;
            testosteroneUndecanoate;
            testosteroneEnantate;
            testosteroneGel;
        }

        enum def AdministrationRoute {
            doc /* Route of medication administration. */
            oral;
            transdermal;
            intramuscular;
            subcutaneous;
        }

        enum def DoseCategory {
            doc /* Categorised starting dose level. Maps to specific
                 * dose values per medication in the prescribing
                 * protocol. The dose category determines the actual
                 * dose based on medication-specific tables. */
            low;
            standard;
            reduced;
            high;
        }

        enum def PatientSatisfaction {
            doc /* Patient-reported satisfaction with treatment
                 * progress. Captured during monitoring consultations. */
            satisfied;
            neutral;
            dissatisfied;
        }

        enum def StabilityClassification {
            doc /* Clinical classification of regimen stability.
                 * Output of the stabilityAssessment decision table. */
            stable;
            improving;
            adjustmentNeeded;
            concerning;
        }

        enum def MonitoringAction {
            doc /* Recommended monitoring action based on stability
                 * assessment. Output of the stabilityAssessment
                 * decision table. */
            continueCurrentRegimen;
            adjustDose;
            reduceMonitoringInterval;
            increaseMonitoringInterval;
            clinicalReviewUrgent;
        }
```

**Acceptance criteria:**
- All nine enums parse clean in Syside
- No naming conflicts with existing CommonTypes enums
- All enum literals resolve without reserved-word errors
- Hover tooltips show doc blocks

**Syntax risk — LOW overall, MEDIUM for `none` and `first`:** We avoid `none` by using `noContraindication`. The `first` risk applies to HitPolicy in DecisionModels, not here. If any literal fails, substitute with a compound name (the doc block describes the intended meaning).

**Git checkpoint:** Commit after Stage 1. Message: `Add clinical vocabulary enums for decision tables to CommonTypes`

---

## 5. Decision Table Representation Pattern

### Stage 2 — Core pattern and syntax test

**Goal:** Establish the reusable decision table pattern as SysML part defs, and run a syntax test for the `:>>` pattern on part def specialisation if not already covered by Phase 1 testing.

#### Step 2.1 — Syntax test: `:>>` on part usages for table rows

The Phase 1 ConstraintEvaluationSpec pattern already validates `:>>` on part usages:

```sysml
part consentSpec : ConstraintEvaluationSpec {
    attribute :>> constraintName = "ConsentRecordedConstraint";
    attribute :>> severity = Severity::critical;
}
```

The decision table rows will follow the **same pattern** — part usages (instances) of a table row part def, with `:>>` redefinition of input and output attributes. This is already validated. No new syntax test needed for this pattern.

**However:** The rows will have more `:>>` redefinitions per instance (6–7 attributes redefined vs. 2–3 in the constraint specs). This exercises the pattern at greater scale but does not introduce new syntax. Risk is LOW.

#### Step 2.2 — DecisionTableDef and DecisionTableRow

**File:** `model/knowledge.sysml` → `Knowledge::DecisionModels`

```sysml
    package DecisionModels {
        private import ScalarValues::*;
        private import Foundation::CommonTypes::*;

        doc /* DMN-style decision tables modelled as SysML part defs
             * with typed inputs, outputs, and row-level rules.
             * Deterministic and auditable — clinicians can read and
             * validate the tables directly from the model.
             *
             * Decision tables are a specialised form of constraint
             * evaluation. The @DecisionTable metadata annotation on
             * pathway steps triggers evaluation via the same
             * ConstraintEvaluator infrastructure in LogicEngine.
             * The table recommends an output; the clinician makes
             * the final decision at a @ClinicalReviewGate.
             *
             * Representation pattern:
             * - DecisionTableDef: abstract table interface with
             *   common metadata (name, hit policy, description)
             * - Concrete table part defs specialise DecisionTableDef
             *   and declare typed input and output attributes
             * - Table rows are part usages of the table's row def,
             *   with :>> attribute redefinitions providing the
             *   concrete input conditions and output values
             *
             * Two decision tables for the hormone therapy pathway:
             * - regimenSelection: baseline data → medication, route,
             *   starting dose
             * - stabilityAssessment: monitoring data → stability
             *   classification, monitoring action
             *
             * Elaborated Session 10: Knowledge Layer Phase 3. */

        // =============================================================
        // Decision table pattern definitions
        // =============================================================

        enum def HitPolicy {
            doc /* How a decision table resolves when evaluating.
                 * Based on DMN hit policy semantics.
                 * unique: exactly one row must match (error otherwise)
                 * firstMatch: rows are ordered, first match wins
                 * collect: all matching rows contribute to output */
            unique;
            firstMatch;
            collect;
        }

        part def DecisionTableDef {
            doc /* Abstract definition for a decision table. Concrete
                 * tables specialise this with their specific input
                 * and output attributes.
                 *
                 * Each table has a name (matching the @DecisionTable
                 * annotation in the pathway), a hit policy, and a
                 * description of its clinical purpose.
                 *
                 * This part def provides common metadata; it is
                 * not intended to be instantiated directly. */
            attribute tableName : String;
            attribute hitPolicy : HitPolicy;
            attribute tableDescription : String;
        }
```

**Acceptance:** Parses clean. `HitPolicy` enum parses with `firstMatch` (avoiding bare `first`). `DecisionTableDef` is a simple part def with scalar and enum attributes.

---

### Stage 3 — Regimen Selection Decision Table

**Goal:** Model the `regimenSelection` decision table — the clinical protocol that maps baseline data and patient preference to the recommended hormone therapy regimen.

#### Step 3.1 — Clinical context

The regimen selection decision table supports the `selectRegimen` step in the hormone therapy initiation pathway. It takes the following inputs (derived from CDR data and patient assessment):

- **Baseline testosterone level** (from baseline bloods) — categorised as low/normal/high/suppressed
- **Baseline oestradiol level** (from baseline bloods) — categorised as low/normal/high/suppressed
- **Patient preference** (from assessment) — oestrogen/testosterone/combined therapy
- **Contraindication category** (from clinical assessment) — summarised risk profile

And produces:

- **Recommended medication** — specific pharmaceutical product
- **Administration route** — how the medication is given
- **Starting dose category** — categorised dose level (maps to specific dose per medication)

The clinician reviews this recommendation at the `@ClinicalReviewGate` before prescribing. The recommendation is advisory — the clinician may override it based on clinical judgement, but the override is logged as a deviation from protocol.

#### Step 3.2 — RegimenSelectionRow and RegimenSelectionTable

**File:** `model/knowledge.sysml` → `Knowledge::DecisionModels`

```sysml
        // =============================================================
        // Regimen Selection Decision Table
        //
        // Maps baseline investigation results, patient preference,
        // and contraindication status to the recommended hormone
        // therapy regimen (medication, route, starting dose).
        //
        // Referenced by: @DecisionTable { tableName = "regimenSelection"; }
        // on selectRegimen step in HormoneTherapy pathway.
        //
        // Consumed by: ConstraintEvaluator via EvaluationSpecRegistry.
        // Validated against: RegimenWithinProtocolConstraint.
        // =============================================================

        part def RegimenSelectionRow {
            doc /* A single row in the regimen selection decision
                 * table. Each row maps a combination of input
                 * conditions to a recommended regimen.
                 *
                 * Concrete rows redefine all attributes with
                 * specific values using :>> redefinition. */

            // --- Inputs (conditions) ---
            attribute baselineTestosterone : HormoneLevel;
            attribute baselineOestradiol : HormoneLevel;
            attribute therapyPreference : TherapyPreference;
            attribute contraindication : ContraindicationCategory;

            // --- Outputs (recommendations) ---
            attribute medication : HormoneMedication;
            attribute administrationRoute : AdministrationRoute;
            attribute startingDose : DoseCategory;
        }

        part def RegimenSelectionTable :> DecisionTableDef {
            doc /* Regimen selection decision table for hormone
                 * therapy initiation.
                 *
                 * Hit policy: Unique — exactly one row should match
                 * for any valid combination of inputs. If no row
                 * matches, the evaluation returns indeterminate
                 * with a recommendation for clinician judgement.
                 *
                 * Clinical source: GenderSense Prescribing Protocol
                 * (version and date to be recorded when real
                 * protocol data is loaded).
                 *
                 * Note: the rows below use representative,
                 * clinically plausible values for modelling
                 * purposes. Actual prescribing protocol data
                 * will be loaded from the validated clinical
                 * source before any runtime use. */

            attribute :>> tableName = "regimenSelection";
            attribute :>> hitPolicy = HitPolicy::unique;
            attribute :>> tableDescription = "Maps baseline hormones, patient preference, and contraindications to recommended regimen";

            // --- Oestrogen therapy rows ---

            part row01 : RegimenSelectionRow {
                doc /* Oestrogen preference, no contraindications,
                     * low baseline — standard transdermal patch. */
                attribute :>> baselineTestosterone = HormoneLevel::normal;
                attribute :>> baselineOestradiol = HormoneLevel::low;
                attribute :>> therapyPreference = TherapyPreference::oestrogen;
                attribute :>> contraindication = ContraindicationCategory::noContraindication;
                attribute :>> medication = HormoneMedication::estradiolPatch;
                attribute :>> administrationRoute = AdministrationRoute::transdermal;
                attribute :>> startingDose = DoseCategory::standard;
            }

            part row02 : RegimenSelectionRow {
                doc /* Oestrogen preference, VTE risk —
                     * transdermal preferred over oral to avoid
                     * first-pass hepatic effects. Reduced dose. */
                attribute :>> baselineTestosterone = HormoneLevel::normal;
                attribute :>> baselineOestradiol = HormoneLevel::low;
                attribute :>> therapyPreference = TherapyPreference::oestrogen;
                attribute :>> contraindication = ContraindicationCategory::vteRisk;
                attribute :>> medication = HormoneMedication::estradiolPatch;
                attribute :>> administrationRoute = AdministrationRoute::transdermal;
                attribute :>> startingDose = DoseCategory::reduced;
            }

            part row03 : RegimenSelectionRow {
                doc /* Oestrogen preference, liver disease —
                     * transdermal to bypass hepatic metabolism. */
                attribute :>> baselineTestosterone = HormoneLevel::normal;
                attribute :>> baselineOestradiol = HormoneLevel::low;
                attribute :>> therapyPreference = TherapyPreference::oestrogen;
                attribute :>> contraindication = ContraindicationCategory::liverDisease;
                attribute :>> medication = HormoneMedication::estradiolGel;
                attribute :>> administrationRoute = AdministrationRoute::transdermal;
                attribute :>> startingDose = DoseCategory::reduced;
            }

            part row04 : RegimenSelectionRow {
                doc /* Oestrogen preference, cardiac risk —
                     * transdermal, low starting dose with close
                     * monitoring. */
                attribute :>> baselineTestosterone = HormoneLevel::normal;
                attribute :>> baselineOestradiol = HormoneLevel::low;
                attribute :>> therapyPreference = TherapyPreference::oestrogen;
                attribute :>> contraindication = ContraindicationCategory::cardiacRisk;
                attribute :>> medication = HormoneMedication::estradiolPatch;
                attribute :>> administrationRoute = AdministrationRoute::transdermal;
                attribute :>> startingDose = DoseCategory::low;
            }

            part row05 : RegimenSelectionRow {
                doc /* Oestrogen preference, multiple contraindications —
                     * requires specialist review. Lowest-risk option
                     * as starting point for discussion. */
                attribute :>> baselineTestosterone = HormoneLevel::normal;
                attribute :>> baselineOestradiol = HormoneLevel::low;
                attribute :>> therapyPreference = TherapyPreference::oestrogen;
                attribute :>> contraindication = ContraindicationCategory::multiple;
                attribute :>> medication = HormoneMedication::estradiolGel;
                attribute :>> administrationRoute = AdministrationRoute::transdermal;
                attribute :>> startingDose = DoseCategory::low;
            }

            // --- Testosterone therapy rows ---

            part row06 : RegimenSelectionRow {
                doc /* Testosterone preference, no contraindications —
                     * standard IM injection. */
                attribute :>> baselineTestosterone = HormoneLevel::low;
                attribute :>> baselineOestradiol = HormoneLevel::normal;
                attribute :>> therapyPreference = TherapyPreference::testosterone;
                attribute :>> contraindication = ContraindicationCategory::noContraindication;
                attribute :>> medication = HormoneMedication::testosteroneUndecanoate;
                attribute :>> administrationRoute = AdministrationRoute::intramuscular;
                attribute :>> startingDose = DoseCategory::standard;
            }

            part row07 : RegimenSelectionRow {
                doc /* Testosterone preference, needle aversion or
                     * patient preference for self-administration —
                     * transdermal gel. */
                attribute :>> baselineTestosterone = HormoneLevel::low;
                attribute :>> baselineOestradiol = HormoneLevel::high;
                attribute :>> therapyPreference = TherapyPreference::testosterone;
                attribute :>> contraindication = ContraindicationCategory::noContraindication;
                attribute :>> medication = HormoneMedication::testosteroneGel;
                attribute :>> administrationRoute = AdministrationRoute::transdermal;
                attribute :>> startingDose = DoseCategory::standard;
            }

            part row08 : RegimenSelectionRow {
                doc /* Testosterone preference, cardiac risk —
                     * gel preferred over injection for more stable
                     * serum levels. Reduced starting dose. */
                attribute :>> baselineTestosterone = HormoneLevel::low;
                attribute :>> baselineOestradiol = HormoneLevel::normal;
                attribute :>> therapyPreference = TherapyPreference::testosterone;
                attribute :>> contraindication = ContraindicationCategory::cardiacRisk;
                attribute :>> medication = HormoneMedication::testosteroneGel;
                attribute :>> administrationRoute = AdministrationRoute::transdermal;
                attribute :>> startingDose = DoseCategory::reduced;
            }

            part row09 : RegimenSelectionRow {
                doc /* Testosterone preference, liver disease —
                     * transdermal to avoid hepatic first-pass.
                     * Standard dose (testosterone is not primarily
                     * hepatically metabolised at standard doses). */
                attribute :>> baselineTestosterone = HormoneLevel::low;
                attribute :>> baselineOestradiol = HormoneLevel::normal;
                attribute :>> therapyPreference = TherapyPreference::testosterone;
                attribute :>> contraindication = ContraindicationCategory::liverDisease;
                attribute :>> medication = HormoneMedication::testosteroneGel;
                attribute :>> administrationRoute = AdministrationRoute::transdermal;
                attribute :>> startingDose = DoseCategory::standard;
            }
        }
```

**Acceptance criteria:**
- `RegimenSelectionRow` parses clean with typed enum attributes
- `RegimenSelectionTable :> DecisionTableDef` parses clean (specialisation)
- All `:>>` redefinitions in `RegimenSelectionTable` resolve (tableName, hitPolicy, tableDescription from parent)
- All row part usages with `:>>` enum literal redefinitions parse clean
- Hover tooltips show doc blocks for table and each row
- No naming conflicts

**Syntax risk — LOW-MEDIUM:** The pattern is structurally identical to the validated ConstraintEvaluationSpec pattern but exercises it at greater scale (7 redefined attributes per row vs. 2–3 per spec, and 9 rows). The parent `:>>` redefinitions on the table itself (tableName, hitPolicy, tableDescription) are a `part def` specialisation with `:>>`, which is slightly different from a part usage with `:>>`. If the parent `:>>` fails, move those to a part usage pattern instead:

```sysml
// Fallback if :> + :>> on part def fails:
part regimenSelectionTable : DecisionTableDef {
    attribute :>> tableName = "regimenSelection";
    // ... (usage, not def specialisation)
}
```

**Git checkpoint:** Commit after Stage 3. Message: `Add regimenSelection decision table to DecisionModels`

---

### Stage 4 — Stability Assessment Decision Table

**Goal:** Model the `stabilityAssessment` decision table — determines whether a patient's hormone therapy regimen is stable and what monitoring action to take next.

#### Step 4.1 — Clinical context

The stability assessment decision table supports the `assessStabilityDecision` step in the monitoring cycle of the hormone therapy pathway. It takes:

- **Hormone level** (from latest monitoring bloods) — categorised against therapeutic range
- **Time on treatment** (weeks since initiation or last dose change) — integer
- **Side effect severity** (from monitoring consultation) — uses existing `Severity` enum
- **Patient satisfaction** (from monitoring consultation)

And produces:

- **Stability classification** — stable / improving / adjustmentNeeded / concerning
- **Monitoring action** — what happens next in the pathway

The stability classification feeds directly into the pathway branch at `assessStabilityDecision`: stable → confirmStable → transitionToOngoingCare; adjustmentNeeded → adjustDose → repeat monitoring cycle.

#### Step 4.2 — StabilityAssessmentRow and StabilityAssessmentTable

**File:** `model/knowledge.sysml` → `Knowledge::DecisionModels`

```sysml
        // =============================================================
        // Stability Assessment Decision Table
        //
        // Maps monitoring results, time on treatment, and patient-
        // reported outcomes to a stability classification and
        // recommended monitoring action.
        //
        // Referenced by: @DecisionTable { tableName = "stabilityAssessment"; }
        // on assessStabilityDecision step in HormoneTherapy pathway.
        //
        // Drives the monitoring cycle branch: stable patients proceed
        // to confirmStable; patients needing adjustment loop back
        // to adjustDose -> scheduleMonitoringBloods.
        // =============================================================

        part def StabilityAssessmentRow {
            doc /* A single row in the stability assessment decision
                 * table. Each row maps monitoring indicators to a
                 * stability classification and recommended action. */

            // --- Inputs (conditions) ---
            attribute hormoneLevel : HormoneLevel;
            attribute minimumWeeksOnTreatment : Integer;
            attribute sideEffectSeverity : Severity;
            attribute satisfaction : PatientSatisfaction;

            // --- Outputs (recommendations) ---
            attribute classification : StabilityClassification;
            attribute action : MonitoringAction;
        }

        part def StabilityAssessmentTable :> DecisionTableDef {
            doc /* Stability assessment decision table for hormone
                 * therapy monitoring.
                 *
                 * Hit policy: Unique — exactly one classification
                 * should result from any valid input combination.
                 *
                 * The table is evaluated at each monitoring review
                 * point (typically every 3 months during titration,
                 * every 6-12 months once stable).
                 *
                 * Note: minimumWeeksOnTreatment uses integer
                 * comparison rather than enum matching. In the
                 * generated evaluator, rows with integer inputs
                 * use range checks rather than equality. The
                 * values shown in rows represent the minimum
                 * weeks threshold for that row to be eligible. */

            attribute :>> tableName = "stabilityAssessment";
            attribute :>> hitPolicy = HitPolicy::unique;
            attribute :>> tableDescription = "Maps monitoring indicators to stability classification and monitoring action";

            // --- Stable regimen rows ---

            part row01 : StabilityAssessmentRow {
                doc /* Normal hormones, 12+ weeks, no significant
                     * side effects, patient satisfied — stable.
                     * Continue current regimen, standard monitoring. */
                attribute :>> hormoneLevel = HormoneLevel::normal;
                attribute :>> minimumWeeksOnTreatment = 12;
                attribute :>> sideEffectSeverity = Severity::informational;
                attribute :>> satisfaction = PatientSatisfaction::satisfied;
                attribute :>> classification = StabilityClassification::stable;
                attribute :>> action = MonitoringAction::continueCurrentRegimen;
            }

            part row02 : StabilityAssessmentRow {
                doc /* Normal hormones, 12+ weeks, no significant
                     * side effects, patient neutral — stable but
                     * explore satisfaction concerns. Continue
                     * regimen with reduced monitoring interval. */
                attribute :>> hormoneLevel = HormoneLevel::normal;
                attribute :>> minimumWeeksOnTreatment = 12;
                attribute :>> sideEffectSeverity = Severity::informational;
                attribute :>> satisfaction = PatientSatisfaction::neutral;
                attribute :>> classification = StabilityClassification::stable;
                attribute :>> action = MonitoringAction::reduceMonitoringInterval;
            }

            // --- Improving but not yet stable ---

            part row03 : StabilityAssessmentRow {
                doc /* Normal hormones but less than 12 weeks on
                     * treatment — too early to declare stable.
                     * Continue and recheck. */
                attribute :>> hormoneLevel = HormoneLevel::normal;
                attribute :>> minimumWeeksOnTreatment = 0;
                attribute :>> sideEffectSeverity = Severity::informational;
                attribute :>> satisfaction = PatientSatisfaction::satisfied;
                attribute :>> classification = StabilityClassification::improving;
                attribute :>> action = MonitoringAction::continueCurrentRegimen;
            }

            // --- Adjustment needed ---

            part row04 : StabilityAssessmentRow {
                doc /* Low hormone levels — dose likely insufficient.
                     * Adjust dose upward. */
                attribute :>> hormoneLevel = HormoneLevel::low;
                attribute :>> minimumWeeksOnTreatment = 12;
                attribute :>> sideEffectSeverity = Severity::informational;
                attribute :>> satisfaction = PatientSatisfaction::dissatisfied;
                attribute :>> classification = StabilityClassification::adjustmentNeeded;
                attribute :>> action = MonitoringAction::adjustDose;
            }

            part row05 : StabilityAssessmentRow {
                doc /* High hormone levels — dose may need reducing.
                     * Adjust dose downward. */
                attribute :>> hormoneLevel = HormoneLevel::high;
                attribute :>> minimumWeeksOnTreatment = 12;
                attribute :>> sideEffectSeverity = Severity::informational;
                attribute :>> satisfaction = PatientSatisfaction::satisfied;
                attribute :>> classification = StabilityClassification::adjustmentNeeded;
                attribute :>> action = MonitoringAction::adjustDose;
            }

            part row06 : StabilityAssessmentRow {
                doc /* Normal hormones but warning-level side effects —
                     * may need route or formulation change.
                     * Increase monitoring, clinical review. */
                attribute :>> hormoneLevel = HormoneLevel::normal;
                attribute :>> minimumWeeksOnTreatment = 0;
                attribute :>> sideEffectSeverity = Severity::warning;
                attribute :>> satisfaction = PatientSatisfaction::dissatisfied;
                attribute :>> classification = StabilityClassification::adjustmentNeeded;
                attribute :>> action = MonitoringAction::increaseMonitoringInterval;
            }

            // --- Concerning ---

            part row07 : StabilityAssessmentRow {
                doc /* Critical side effects regardless of hormone
                     * levels — urgent clinical review. */
                attribute :>> hormoneLevel = HormoneLevel::normal;
                attribute :>> minimumWeeksOnTreatment = 0;
                attribute :>> sideEffectSeverity = Severity::critical;
                attribute :>> satisfaction = PatientSatisfaction::dissatisfied;
                attribute :>> classification = StabilityClassification::concerning;
                attribute :>> action = MonitoringAction::clinicalReviewUrgent;
            }

            part row08 : StabilityAssessmentRow {
                doc /* Suppressed hormone levels — possible over-
                     * suppression. Urgent review to assess dose
                     * and clinical status. */
                attribute :>> hormoneLevel = HormoneLevel::suppressed;
                attribute :>> minimumWeeksOnTreatment = 0;
                attribute :>> sideEffectSeverity = Severity::informational;
                attribute :>> satisfaction = PatientSatisfaction::neutral;
                attribute :>> classification = StabilityClassification::concerning;
                attribute :>> action = MonitoringAction::clinicalReviewUrgent;
            }
        }
```

**Acceptance criteria:**
- Same as Stage 3 — all part defs, `:>>` redefinitions, and enum references parse clean
- Integer default (`minimumWeeksOnTreatment = 12`) parses in `:>>` redefinition
- Cross-package enum import resolves for `Severity` (from CommonTypes, used alongside the new enums)

**Syntax risk — LOW-MEDIUM:** Same pattern as Stage 3, with the addition of integer literal `:>>` redefinition (`attribute :>> minimumWeeksOnTreatment = 12;`). Integer literals in `:>>` are not explicitly listed in the syntax reference as tested, though they should work if string and enum literals do. If integer `:>>` fails, fall back to documenting the value in the doc block and removing the `:>>` for that attribute.

**Git checkpoint:** Commit after Stage 4. Message: `Add stabilityAssessment decision table to DecisionModels`

---

### Stage 5 — Decision Table Evaluation Specs

**Goal:** Create ConstraintEvaluationSpec-style evaluation specs for the two decision tables, establishing the bridge between the pathway's `@DecisionTable` annotations and the evaluation infrastructure in LogicEngine.

#### Step 5.1 — Design decision: where do evaluation specs for tables live?

**Option A:** In `Knowledge::ClinicalDecisionSupport`, alongside the constraint evaluation specs. This is consistent — CDS holds all evaluation specs regardless of whether they evaluate constraints or decision tables.

**Option B:** In `Knowledge::DecisionModels`, co-located with the tables they evaluate. This keeps table + spec together.

**Recommended: Option A.** CDS is already the established home for "how to evaluate" specs. DecisionModels defines "what the table is." This preserves the separation between definition and evaluation that works well for constraints.

#### Step 5.2 — DecisionTableEvaluationSpec part def

**File:** `model/knowledge.sysml` → `Knowledge::ClinicalDecisionSupport`

Add after the existing ConstraintEvaluationSpec usages:

```sysml
        // =============================================================
        // Decision table evaluation specifications
        //
        // Parallel to ConstraintEvaluationSpecs, these bind decision
        // tables to their input derivations. The same InputDerivation
        // pattern applies: each table input is derived from an
        // authoritative data source.
        // =============================================================

        part def DecisionTableEvaluationSpec {
            doc /* Binds a decision table to its input derivations
                 * and evaluation metadata, parallel to
                 * ConstraintEvaluationSpec for constraints.
                 *
                 * The tableName matches the @DecisionTable metadata
                 * annotation on pathway steps. The evaluation
                 * infrastructure resolves the name to this spec,
                 * derives inputs, evaluates the table, and returns
                 * the matching row's outputs. */
            attribute tableName : String;
            attribute description : String;
            part inputDerivations : InputDerivation[0..*];
        }

        part regimenSelectionSpec : DecisionTableEvaluationSpec {
            doc /* Evaluation spec for the regimenSelection decision
                 * table. Derives four inputs from CDR and clinical
                 * assessment data. */
            attribute :>> tableName = "regimenSelection";
            attribute :>> description = "Derives inputs for regimen selection from baseline bloods and assessment";
        }

        part stabilityAssessmentSpec : DecisionTableEvaluationSpec {
            doc /* Evaluation spec for the stabilityAssessment
                 * decision table. Derives inputs from monitoring
                 * bloods, treatment history, and consultation
                 * data. */
            attribute :>> tableName = "stabilityAssessment";
            attribute :>> description = "Derives inputs for stability assessment from monitoring data and consultation";
        }
```

**Acceptance criteria:**
- `DecisionTableEvaluationSpec` part def parses clean
- Both spec usages with `:>>` parse clean
- `InputDerivation[0..*]` part containment resolves (cross-package reference within CDS, where InputDerivation is already defined)

**Git checkpoint:** Commit after Stage 5. Message: `Add decision table evaluation specs to ClinicalDecisionSupport`

---

### Stage 6 — Use Cases and Traceability

**Goal:** Add use case defs for decision table evaluation and update the DecisionModels doc block. Verify traceability from pathway annotations through to the table definitions.

#### Step 6.1 — Use case defs in DecisionModels

**File:** `model/knowledge.sysml` → `Knowledge::DecisionModels`

Add after the table definitions:

```sysml
        // =============================================================
        // Use cases
        // =============================================================

        use case def EvaluateDecisionTable {
            doc /* Evaluate a decision table for a specific patient
                 * and clinical context.
                 *
                 * Invoked when a pathway step annotated with
                 * @DecisionTable is reached. The evaluation:
                 * 1. Resolves the table by name via the registry
                 * 2. Derives input values from authoritative sources
                 * 3. Matches inputs against table rows per hit policy
                 * 4. Returns the matching row's output values as a
                 *    structured recommendation
                 * 5. Produces an EvaluationResult with ExplanationTrace
                 *    showing which row matched and why
                 *
                 * The result is a recommendation, not an automatic
                 * action — the clinician reviews it at a
                 * @ClinicalReviewGate before proceeding.
                 *
                 * Component allocation: ConstraintEvaluator (same
                 * Tier 1 infrastructure as constraint evaluation). */
        }

        use case def ValidateDecisionAgainstTable {
            doc /* After a clinician makes a prescribing decision,
                 * validate that the chosen regimen appears in the
                 * decision table. If the clinician overrides the
                 * table recommendation, the override is logged
                 * as a protocol deviation with clinical justification.
                 *
                 * This is the bridge to RegimenWithinProtocolConstraint
                 * in ConstraintLibrary: the table recommends, the
                 * constraint validates. */
        }
```

#### Step 6.2 — Traceability verification

After all stages are committed, verify the traceability chain:

```
ServiceDelivery::ClinicalPathways::HormoneTherapy
  selectRegimen step
    @DecisionTable { tableName = "regimenSelection"; }
        ↓ (name lookup)
Knowledge::ClinicalDecisionSupport
  regimenSelectionSpec : DecisionTableEvaluationSpec
    attribute :>> tableName = "regimenSelection"
        ↓ (table definition)
Knowledge::DecisionModels
  RegimenSelectionTable :> DecisionTableDef
    attribute :>> tableName = "regimenSelection"
    part row01..row09 : RegimenSelectionRow
        ↓ (post-decision validation)
Knowledge::ConstraintLibrary
  RegimenWithinProtocolConstraint
    (validates that chosen regimen is within protocol)
```

And similarly for stabilityAssessment:

```
  assessStabilityDecision step
    @DecisionTable { tableName = "stabilityAssessment"; }
        ↓
  stabilityAssessmentSpec : DecisionTableEvaluationSpec
        ↓
  StabilityAssessmentTable :> DecisionTableDef
    part row01..row08 : StabilityAssessmentRow
        ↓ (drives pathway branch)
  adjustDose (if adjustmentNeeded) or confirmStable (if stable)
```

#### Step 6.3 — DecisionModels doc block update

The doc block was set in Stage 2 (Step 2.2 above) with the full content. Verify it is accurate after all stages are complete. If any structural changes occurred during implementation, update accordingly.

**Git checkpoint:** Commit after Stage 6. Message: `Add decision table use cases and verify traceability`

---

### Stage 7 — Verification, Documentation, and Session Close

#### Step 7.1 — Full model verification

Open the entire workspace in Syside and verify clean parse across all files. Changes span two files:

- `model/foundation.sysml` — CommonTypes: 9 new enums
- `model/knowledge.sysml` — DecisionModels: HitPolicy enum + DecisionTableDef + 2 row defs + 2 table defs (with 17 total rows) + 2 use cases; CDS: DecisionTableEvaluationSpec + 2 evaluation spec usages

Check for:
- All new part defs parse clean
- All `:>>` redefinitions resolve (string, enum, and integer literals)
- Cross-package enum imports resolve (new CommonTypes enums used in DecisionModels)
- Existing model elements unaffected (LogicEngine, ConstraintLibrary untouched)
- No naming conflicts between new enum literals and existing names
- Hover tooltips show doc blocks for all new elements

#### Step 7.2 — Run `gsl save`

Regenerate all hierarchy outputs. Updated element counts expected:

- CommonTypes: 2 parts, **21 enums** (+9 from Phase 3)
- DecisionModels: should show new part defs, use cases, and the HitPolicy enum

#### Step 7.3 — Syntax reference update

**New patterns to document if verified:**

- `:>>` with integer literal defaults (e.g. `attribute :>> minimumWeeksOnTreatment = 12;`)
- Part def specialisation with `:>>` on the specialised def's inherited attributes (e.g. `part def RegimenSelectionTable :> DecisionTableDef { attribute :>> tableName = "regimenSelection"; }`)
- Multiple `:>>` redefinitions in a single part usage (7 attributes per row — exercises scale)
- Enum literals: `low`, `normal`, `high`, `suppressed`, `noContraindication`, `firstMatch`, `neutral`, `stable`, `improving`, `adjustmentNeeded`, `concerning`, `reduced`, `oral`, `transdermal`, `intramuscular`, `subcutaneous` — all to be added to the safe literals list if verified

**Potential new traps:**

- `none` as an enum literal (avoided by using `noContraindication`)
- `first` as an enum literal (avoided by using `firstMatch`)
- Integer literal `:>>` (if it fails, this is a new trap to document)

If no new findings beyond confirming existing patterns, a v3.6 may not be needed — note the confirming evidence in the session report instead. However, if integer `:>>` or part def specialisation `:>>` are new verified patterns, v3.6 is warranted.

**Decision criterion for v3.6:** If at least one genuinely new syntax pattern is verified (not just a confirmed re-use of an existing pattern at larger scale), produce v3.6. Otherwise, note findings in the session report.

#### Step 7.4 — Session report

Write `gsl-session-report-2026-03-09-s10.md` covering:
- What was completed (which stages, which steps)
- Syntax findings (integer `:>>`, part def specialisation `:>>`, new safe literals)
- Design decisions made (representation pattern, hit policy, table-spec separation)
- Repository state after session
- Recommended next steps (Phase 4 — OutcomeFramework elaboration)

#### Step 7.5 — Git final commit

Stage and commit all remaining changes. Message: `Complete Knowledge Layer Phase 3: DecisionModels elaboration`

---

## 6. Execution Order and Dependencies

```
Pre-flight checks (Stage 0)
    │
    ▼
Stage 1: New enums in CommonTypes              ← no dependencies beyond clean model
    │   (9 clinical vocabulary enums)
    │
    ▼
Stage 2: Core pattern (DecisionTableDef,       ← depends on Stage 1 (HitPolicy enum
    │    HitPolicy enum)                          defined in DecisionModels; clinical
    │                                              enums from CommonTypes imported)
    │
    ▼
Stage 3: regimenSelection table                ← depends on Stages 1-2
    │   (RegimenSelectionRow,                     (uses enums from Stage 1,
    │    RegimenSelectionTable with 9 rows)         pattern from Stage 2)
    │
    ▼
Stage 4: stabilityAssessment table             ← depends on Stages 1-2
    │   (StabilityAssessmentRow,                  (parallel-eligible with Stage 3,
    │    StabilityAssessmentTable with 8 rows)     but sequential is safer)
    │
    ▼
Stage 5: Evaluation specs in CDS              ← depends on Stages 3-4
    │   (DecisionTableEvaluationSpec,             (names must match table names)
    │    regimenSelectionSpec,
    │    stabilityAssessmentSpec)
    │
    ▼
Stage 6: Use cases and traceability           ← depends on Stages 3-5
    │   (EvaluateDecisionTable,                   (references tables and specs)
    │    ValidateDecisionAgainstTable,
    │    traceability verification)
    │
    ▼
Stage 7: Verification + Documentation         ← depends on all above
```

Stages 1–2 are foundational. Stages 3–4 depend on the enums and pattern; they could theoretically be worked in parallel but sequential is safer for `:>>` validation (verify the pattern works on the first table before committing the second). Stage 5 depends on the tables being named. Stages 6–7 are documentation and verification.

---

## 7. Identified Risks

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| `:>>` with integer literal fails in Syside | Low | Medium | Fall back to documenting the value in doc block; remove the `:>>` for that attribute only |
| `:>>` on `part def` specialisation (inherited attribute) fails | Low-Medium | Medium | Fall back to part usage pattern instead of specialisation (same as ConstraintEvaluationSpec pattern — already validated) |
| `none` as enum literal conflicts with SysML/KerML | Avoided | — | Already using `noContraindication` instead |
| `first` as enum literal conflicts with `first` keyword (used in state transitions) | Avoided | — | Already using `firstMatch` instead |
| New enum literals conflict with SysML reserved words | Low | Low | All proposed literals are compound clinical terms or verified-safe patterns; test any uncertain ones in syntax-tests first |
| Table row count makes DecisionModels package unwieldy | Low | Low | 17 rows across 2 tables is manageable; each row has a clear clinical purpose; extraction to sub-packages if needed later |
| Over-modelling: too many `:>>` redefinitions per row | Medium | Low | 7 attributes per row is the most `:>>` redefinitions in a single part usage to date; if Syside performance degrades, reduce to fewer rows as representative samples |
| Clinical data accuracy | N/A for modelling | — | All values are representative for modelling purposes; real protocol data loaded before runtime use; doc blocks note this explicitly |
| `HitPolicy` enum in DecisionModels rather than CommonTypes | Low (design risk) | Low | HitPolicy is decision-table-specific vocabulary, not a general clinical type; keeping it in DecisionModels is the right layering |

---

## 8. Design Decisions

### 8.1 Part usages for table rows, not part def specialisations

Table rows are modelled as **part usages** (`part row01 : RegimenSelectionRow { ... }`) inside the table def, not as part def specialisations (`part def Row01 :> RegimenSelectionRow { ... }`). This follows the validated ConstraintEvaluationSpec pattern and is semantically correct: each row is an *instance* of the row shape with specific values, not a new type.

### 8.2 Table def as part def specialisation of DecisionTableDef

The `RegimenSelectionTable :> DecisionTableDef` pattern uses part def specialisation to inherit common table metadata (tableName, hitPolicy, tableDescription). This is a new use of `:>>` on a part def rather than a part usage. If it fails, the fallback is to make the table a part usage instead:

```sysml
part regimenSelectionTable : DecisionTableDef { ... }
```

This is slightly less clean (the table is an instance, not a type) but functionally equivalent and already validated.

### 8.3 Row defs separate from table defs

`RegimenSelectionRow` is defined as a standalone part def, then used inside `RegimenSelectionTable`. This is cleaner than defining the row shape inline in the table — it separates the row schema from the row instances. The row def could potentially be shared across tables if they have the same shape (not the case here, but the pattern supports it).

### 8.4 Clinical vocabulary in CommonTypes, HitPolicy in DecisionModels

Clinical vocabulary enums (HormoneLevel, HormoneMedication, AdministrationRoute, etc.) belong in `Foundation::CommonTypes` because they are clinical domain terms that may be used elsewhere in the model (e.g. in ClinicalEntities, in Platform::PrescribingSystem). `HitPolicy` is a decision-table-specific concept that has no meaning outside DecisionModels — it stays local.

### 8.5 Evaluation specs in CDS, not in DecisionModels

`DecisionTableEvaluationSpec` and its instances live in `Knowledge::ClinicalDecisionSupport`, parallel to `ConstraintEvaluationSpec`. This preserves the established separation: the "what" (table definition) lives in DecisionModels; the "how to evaluate" (derivation spec) lives in CDS. Consumers (LogicEngine's ConstraintEvaluator, EvaluationSpecRegistry) look in one place for all evaluation specs.

### 8.6 Representative clinical data, not validated protocol data

The decision table rows contain representative, clinically plausible values. This is explicitly noted in doc blocks. The modelling purpose is to validate the SysML representation pattern and the traceability chain, not to encode the actual prescribing protocol. Before any runtime use, real protocol data will be loaded from the validated clinical source and the rows updated accordingly.

### 8.7 Integer `:>>` for minimumWeeksOnTreatment

The stability assessment table uses an integer attribute (`minimumWeeksOnTreatment`) with `:>>` redefinition. This is a natural representation for "how long has the patient been on treatment" — it's a continuous value that doesn't fit cleanly into an enum. At runtime, the generated evaluator will use range comparison (>=) rather than equality for this attribute. The doc block on the table notes this distinction.

---

## 9. Model Element Counts After Phase 3 (Projected)

### New elements in CommonTypes

| Element type | Count | Names |
|---|---|---|
| Enum defs | +9 | HormoneLevel, TherapyPreference, ContraindicationCategory, HormoneMedication, AdministrationRoute, DoseCategory, PatientSatisfaction, StabilityClassification, MonitoringAction |

### New elements in DecisionModels

| Element type | Count | Names |
|---|---|---|
| Enum defs | +1 | HitPolicy |
| Part defs | +5 | DecisionTableDef, RegimenSelectionRow, RegimenSelectionTable, StabilityAssessmentRow, StabilityAssessmentTable |
| Part usages (rows) | +17 | 9 rows in RegimenSelectionTable, 8 rows in StabilityAssessmentTable |
| Use case defs | +2 | EvaluateDecisionTable, ValidateDecisionAgainstTable |

### New elements in ClinicalDecisionSupport

| Element type | Count | Names |
|---|---|---|
| Part defs | +1 | DecisionTableEvaluationSpec |
| Part usages (specs) | +2 | regimenSelectionSpec, stabilityAssessmentSpec |

### Cumulative model element counts after Phase 3

| Package | Part defs | Enum defs | Constraint defs | Use case defs | State defs | Metadata defs |
|---|---|---|---|---|---|---|
| Foundation::MetadataLibrary | — | — | — | — | — | 9 |
| Foundation::CommonTypes | 2 | **21** (+9) | — | — | — | — |
| Foundation::StatePatterns | — | — | — | — | 1 | — |
| Knowledge::ClinicalDecisionSupport | **3** (+1) | — | — | 3 | — | — |
| Knowledge::ConstraintLibrary | — | — | 8 | — | — | — |
| Knowledge::LogicEngine | 21 | — | — | 4 | — | — |
| Knowledge::DecisionModels | **5** (+5) | **1** (+1) | — | **2** (+2) | — | — |
| Knowledge::OutcomeFramework | 1 | — | — | — | — | — |
| Knowledge::Analytics | 1 | — | — | — | — | — |

---

## 10. Estimated Effort

| Stage | Estimated time | Notes |
|---|---|---|
| Pre-flight | 5–10 min | Ella: Syside checks, git status |
| Stage 1 | 15–20 min | 9 enums in CommonTypes — straightforward, main risk is enum literal testing |
| Stage 2 | 10–15 min | HitPolicy enum + DecisionTableDef pattern (small, foundational) |
| Stage 3 | 25–35 min | RegimenSelectionTable with 9 rows — largest single stage, many `:>>` redefinitions |
| Stage 4 | 20–30 min | StabilityAssessmentTable with 8 rows — similar to Stage 3, integer `:>>` to verify |
| Stage 5 | 10–15 min | DecisionTableEvaluationSpec + 2 spec usages in CDS |
| Stage 6 | 10–15 min | 2 use cases + traceability verification |
| Stage 7 | 15–25 min | Verification, syntax reference check, session report |
| **Total** | **~2–3 hours** | Single session |

---

## 11. Recommended Next Steps After Phase 3

### Phase 4 — OutcomeFramework elaboration

With the evaluation infrastructure (Phase 2) and decision tables (Phase 3) complete, Phase 4 defines the outcome measurement layer for the hormone therapy pathway. Outcomes connect to the GoalProjector (Phase 2) as goal sources — unmet outcomes become deficits. This closes the loop between the self-knowledge architecture and clinical outcome measurement.

Phase 4 scope (from extended plan, Section 4):
- Define clinical outcomes for hormone therapy initiation (target hormone ranges, adherence, side effect profile, patient satisfaction)
- Define measurement points and intervals (3-month, 6-month, 12-month assessments)
- Design outcome-to-pathway feedback pattern (how outcomes feed into LearningCycles)
- Design outcome capture as CDR compositions (openEHR archetype considerations)
- Connect outcome definitions to goal-state projection (outcomes are goals; unmet outcomes are deficits)

### Phase 5 — Generator exploration

Prototype the constraint-to-TypeScript generator, the decision-table-to-TypeScript generator, and the System Model Manifest generator. The Phase 2 component model and Phase 3 decision table model define the generation targets.

### Test nested `:>>` syntax (deferred from Phase 1, still deferred)

The nested `:>>` redefinition pattern (InputDerivation instances inside ConstraintEvaluationSpec usages) remains deferred. Phase 3 does not exercise this pattern — the decision table evaluation specs use the same flat `:>>` pattern as the constraint evaluation specs.

---

*Plan prepared 9 March 2026 (Session 10). Implements Phase 3 of the Knowledge Layer Elaboration extended plan.*
