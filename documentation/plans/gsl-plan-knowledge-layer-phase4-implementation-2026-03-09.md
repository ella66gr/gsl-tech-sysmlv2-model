# Knowledge Layer Elaboration — Phase 4 Implementation Plan

**Date:** 9 March 2026 (Session 11)
**Context:** Phase 4 of the Knowledge Layer Elaboration, as defined in the extended planning document. Phase 1 (Session 8) established the evaluation and self-knowledge data structures. Phase 2 (Session 9) established the LogicEngine component model. Phase 3 (Session 10) established the decision table representation pattern and modelled the two hormone therapy decision tables. Phase 4 elaborates the OutcomeFramework package — currently a single minimal part def — into a comprehensive outcome measurement model for hormone therapy.

**Parent plan:** `documentation/plans/gsl-plan-knowledge-layer-elaboration-2026-03-08-extended.md`
**Phase 1 plan:** `documentation/plans/gsl-plan-knowledge-layer-phase1-implementation-2026-03-08.md`
**Phase 2 plan:** `documentation/plans/gsl-plan-knowledge-layer-phase2-implementation-2026-03-09.md`
**Phase 3 plan:** `documentation/plans/gsl-plan-knowledge-layer-phase3-implementation-2026-03-09.md`
**Syntax reference:** `documentation/reference/gsl-sysml-v2-syntax-reference-v3.6-2026-03-09.md`
**Architecture decisions:** `documentation/architecture/gsl-architecture-decision-knowledge-evaluation.md`
**Validated patterns:** `documentation/architecture/gsl-validated-architectural-patterns.md`

---

## 1. Scope and Boundaries

### What Phase 4 delivers

Phase 4 elaborates the `Knowledge::OutcomeFramework` package into a working model of clinical outcome measurement for the hormone therapy initiation pathway. OutcomeFramework currently contains a single minimal `OutcomeDefinition` part def with three string attributes. This phase replaces it with a comprehensive structural model that:

1. **Defines the outcome taxonomy** — what kinds of outcomes are measured (clinical, adherence, safety, patient-reported) and how they are categorised
2. **Models specific outcomes for hormone therapy** — concrete outcome definitions with target values, therapeutic ranges, and measurement criteria
3. **Defines measurement points and intervals** — when outcomes are assessed during the hormone therapy pathway (3-month, 6-month, 12-month, ongoing)
4. **Establishes the outcome-to-goal-state connection** — outcomes are goals; unmet outcomes become deficits in the self-knowledge architecture (connecting to Phase 1's GoalProjector and GapAnalyser in LogicEngine)
5. **Designs the outcome capture pattern** — how outcome data enters the CDR as openEHR compositions, linking to the validated CDR integration patterns
6. **Defines the outcome-to-LearningCycles feedback pattern** — how outcome data feeds into pathway refinement, closing the learn-and-adapt loop described in the Modelling Strategy (Section 6.3)
7. **Adds use cases** for outcome recording, measurement, evaluation, and pathway feedback

### What Phase 4 does NOT deliver

- **Runtime code or generators** — outcome measurement runtime is a Phase 5+ concern
- **openEHR archetype design** — Phase 4 identifies which archetypes are needed and annotates with `@OpenEhrArchetype` metadata where appropriate, but does not design the archetype internals (that is a separate CDR design task)
- **Changes to LogicEngine component model** — Phase 2 is complete; Phase 4 connects to it conceptually (outcomes feed GoalProjector) but does not modify LogicEngine's structural content
- **Changes to DecisionModels or ConstraintLibrary** — the stability assessment decision table already references outcomes implicitly (patient satisfaction, hormone levels); Phase 4 formalises the outcome definitions that feed those inputs but does not modify the tables or constraints themselves
- **Actual clinical outcome targets** — outcome definitions use representative, clinically plausible values for modelling purposes, not validated clinical protocol data; real targets will be loaded from clinical sources before runtime use
- **Elaboration of LearningCycles** — Phase 4 designs the *connection* from OutcomeFramework to LearningCycles (the feedback interface) but does not elaborate LearningCycles into a full process model; that is future work
- **Analytics / Tier 3 integration** — the outcome data stream is a natural feed for Analytics, but the data contract definition is deferred

### Relationship to earlier phases

| Phase | Relationship to Phase 4 |
|---|---|
| **Phase 1 — Self-knowledge architecture** | Outcome definitions are a *goal source* for Layer 3 (goal-state knowledge). The GoalProjector projects outcomes into expected conditions; the GapAnalyser compares against CDR data and produces Deficit records for unmet outcomes. This is the primary architectural connection. |
| **Phase 2 — LogicEngine component model** | The GoalProjector (Phase 2, Stage 3) consumes outcome definitions as one of its three goal sources (alongside requirements and constraints). Phase 4 defines the outcome side of that interface. The AssessmentOrchestrator includes outcome goal compliance in SystemStateAssessments. |
| **Phase 3 — DecisionModels** | The stabilityAssessment decision table uses inputs (hormone levels, patient satisfaction) that are also outcome measures. Phase 4 formalises the outcome definitions that those inputs represent. The relationship is informational, not structural — DecisionModels is not modified. |
| **Existing constraints** | `BloodMonitoringIntervalConstraint` checks monitoring adherence, which is also an outcome (adherence outcome). The constraint evaluates a specific rule; the outcome tracks the longitudinal pattern. Both contribute to the same goal-state projection but through different mechanisms. |

### Relationship to the pathway

The hormone therapy domain-layer action flow has several steps that produce or consume outcome data:

- **`scheduleMonitoringBloods` / `awaitMonitoringResults` / `reviewMonitoringResults`** — these pathway steps generate the clinical data that outcome measurement evaluates (hormone levels, side effects)
- **`assessStabilityDecision`** — consumes outcome data to determine stability classification (via the stabilityAssessment decision table)
- **`confirmStable` / `transitionToOngoingCare`** — reached when outcomes indicate stability; this is the positive outcome endpoint of the initiation pathway
- **`adjustDose`** — reached when outcomes indicate adjustment needed; this represents an intermediate outcome that feeds back into the monitoring cycle

Outcome measurement sits alongside the pathway, not inside it. The pathway produces data; the outcome framework evaluates that data against defined targets at defined intervals. The pathway may be complete (patient transitioned to ongoing care) while outcome measurement continues (12-month outcomes, long-term monitoring).

### Files affected

| File | Expected changes |
|---|---|
| `model/knowledge.sysml` | OutcomeFramework package: restructured with new part defs, enums, use cases, updated doc block |
| `model/foundation.sysml` | CommonTypes: new enums if required by outcome type definitions (see Stage 1 analysis) |
| `documentation/reference/gsl-sysml-v2-syntax-reference-v3.7-*.md` | Updated if new syntax patterns are verified or traps discovered |
| `documentation/session-reports/gsl-session-report-2026-03-09-s11.md` | Session report |

---

## 2. Pre-flight Checks

| Check | Action | Status |
|---|---|---|
| 2.1 | Verify Phase 3 model changes committed to git (DecisionModels elaboration, 9 new enums in CommonTypes) | ☐ Ella to confirm |
| 2.2 | Run `gsl` to confirm hierarchy shows DecisionModels with 5 part defs, 1 enum, 2 use cases | ☐ Ella to confirm |
| 2.3 | Verify OutcomeFramework package currently has one part def (OutcomeDefinition) with three string attributes | ☐ Confirmed from model read |
| 2.4 | Confirm syntax reference v3.6 is current, and filename has been renamed from v3.5 | ☐ Ella to confirm |
| 2.5 | Open `knowledge.sysml` in Syside to confirm clean parse before modifications | ☐ Ella to confirm |
| 2.6 | Verify `@OpenEhrArchetype` metadata def exists in `Foundation::MetadataLibrary` | ☐ Confirmed from model read |

---

## 3. Clinical Domain Analysis: Hormone Therapy Outcomes

Before modelling, we need to understand what outcomes matter clinically. This analysis draws on the hormone therapy pathway model and standard clinical governance practice for gender-affirming hormone therapy.

### 3.1 Outcome categories

Four categories of outcome are relevant to hormone therapy initiation:

**Clinical outcomes** — measurable physiological results of treatment:
- Hormone levels within therapeutic range (oestradiol or testosterone target ranges depending on therapy direction)
- Haematological safety markers within safe limits (haemoglobin/haematocrit for testosterone; VTE risk markers for oestrogen)
- Metabolic safety markers stable (liver function, lipids, fasting glucose)
- Prolactin within normal range

**Adherence outcomes** — whether the process is being followed:
- Monitoring bloods completed at defined intervals (already covered by `BloodMonitoringIntervalConstraint`, but the outcome tracks the longitudinal adherence pattern, not just the point-in-time check)
- Clinic appointments attended
- Prescription collection / medication adherence

**Safety outcomes** — adverse events and side effect tracking:
- Side effect severity at each monitoring point (already an input to the stabilityAssessment decision table)
- Adverse event occurrence (serious adverse events requiring intervention)
- Contraindication emergence (new contraindications developing during treatment)

**Patient-reported outcomes (PROs)** — the patient's experience:
- Treatment satisfaction (already an input to the stabilityAssessment decision table)
- Quality of life measures
- Goal attainment (patient's own treatment goals being met)
- Mental health and wellbeing indicators

### 3.2 Measurement points

Hormone therapy outcomes are measured at defined intervals:

| Measurement point | Timing | Primary focus |
|---|---|---|
| Baseline | Before treatment initiation | Pre-treatment values for comparison |
| 3-month | ~12 weeks post-initiation | Initial response: are hormones moving toward target? Early side effects? |
| 6-month | ~26 weeks post-initiation | Mid-term response: target range achieved? Stable? Side effect profile? |
| 12-month | ~52 weeks post-initiation | Long-term response: sustained target levels? Patient satisfaction? Transition to annual monitoring? |
| Annual | Every 12 months after stabilisation | Ongoing surveillance: continued target levels, emerging risks, continued satisfaction |

Each measurement point collects a defined set of outcome data. Not all outcomes are measured at every point — clinical outcomes (bloods) are measured at all points; PROs may be measured less frequently.

### 3.3 Target values and therapeutic ranges

Outcome definitions need target values to enable goal-state projection. For modelling purposes:

- **Oestradiol (feminising therapy):** target range 400–600 pmol/L at trough
- **Testosterone (masculinising therapy):** target range 10–30 nmol/L at trough
- **Testosterone (feminising therapy suppression):** target < 2 nmol/L
- **Oestradiol (masculinising therapy suppression):** target < 200 pmol/L

These are representative values. The actual ranges depend on the specific clinical protocol and should be loaded from the validated clinical source before runtime use. The model captures the *structure* (outcome with target range) not the exact clinical values.

### 3.4 Relationship to the self-knowledge goal-state

Each outcome definition implies a goal. The GoalProjector (Phase 2) transforms this into a GoalProjection:

```
OutcomeDefinition: "Oestradiol within 400–600 pmol/L at 6-month measurement"
  → GoalProjection:
      goalName: "oestradiol-6month-target"
      goalSource: "OutcomeFramework::OestradiolTherapeuticRange"
      expectedCondition: "AQL returns a LabResult composition for this patient
          with test = 'oestradiol', value between 400 and 600, within 2 weeks
          of the 6-month measurement date"
      evaluationQuery: "SELECT ... FROM EHR e CONTAINS ... WHERE ..."
```

If the AQL query returns no result, or a result outside target, the GapAnalyser produces a Deficit:

```
Deficit:
  deficitDomain: clinical
  scope: patient
  goalReference: "OestradiolTherapeuticRange"
  actualState: "No oestradiol result within 6-month window" or "520 pmol/L — out of range"
  expectedState: "Result between 400–600 pmol/L"
  severity: warning (overdue) or critical (out of range)
  remediationCategory: recommended (schedule blood test / clinical review)
```

This is the concrete connection between OutcomeFramework and the self-knowledge architecture.

---

## 4. Design Approach

### 4.1 Structural pattern

The outcome framework uses the same `part def` + `part usage` + `:>>` redefinition pattern validated in Phases 1 and 3. An abstract `OutcomeDefinition` (replacing the current minimal version) provides the common structure. Concrete outcome definitions are part usages with `:>>` redefinitions of all attributes — the same pattern as `ConstraintEvaluationSpec` instances and decision table rows.

Measurement schedules are modelled as a separate `MeasurementSchedule` part def with contained `MeasurementPoint` instances, because the schedule structure is reusable across outcomes and logically separate from the outcome definition itself.

### 4.2 Enum analysis for Phase 4

The outcome model needs typed vocabularies. Some are already available; some are new.

| Concept | Available? | Notes |
|---|---|---|
| Outcome category | **New:** `OutcomeCategory` | clinical, adherence, safety, patientReported |
| Outcome status | **New:** `OutcomeStatus` | pending, measured, targetMet, targetNotMet, indeterminate |
| Measurement frequency | **New:** `MeasurementFrequency` | baseline, threeMonthly, sixMonthly, annually, adHoc |
| Severity | **Exists:** `Foundation::CommonTypes::Severity` | Reused for adverse event severity |
| EvaluationOutcome | **Exists:** `Foundation::CommonTypes::EvaluationOutcome` | Reused for outcome evaluation results |
| HormoneLevel | **Exists (Phase 3):** `Foundation::CommonTypes::HormoneLevel` | Reused for target range categorisation |
| PatientSatisfaction | **Exists (Phase 3):** `Foundation::CommonTypes::PatientSatisfaction` | Reused for PRO outcomes |
| StabilityClassification | **Exists (Phase 3):** `Foundation::CommonTypes::StabilityClassification` | Reused for stability outcomes |
| Comparison operator for targets | **New:** `ComparisonOperator` | within, greaterThan, lessThan, equalTo — needed for target range expression |

**New enums needed: 4** (OutcomeCategory, OutcomeStatus, MeasurementFrequency, ComparisonOperator)

These belong in `Foundation::CommonTypes` because outcome measurement concepts may be referenced from ClinicalGovernance, ClinicalDecisionSupport, and potentially LearningCycles.

### 4.3 Syntax risk assessment

Phase 4 uses only patterns already validated in Phases 1–3:

| Pattern | Validated in | Risk |
|---|---|---|
| `part def` with typed attributes | All phases | None |
| `part usage` with `:>>` string/enum redefinition | Phase 1, 3 | None |
| `part usage` with `:>>` integer redefinition | Phase 3 (v3.6) | None |
| Contained `part` with multiplicity `[0..*]` | Phase 1 (v3.5) | None |
| `@OpenEhrArchetype` metadata on `part def` | CDR Exercise (v3.4) | None |
| Cross-package enum imports from CommonTypes | All phases | None |
| `use case def` with doc blocks | All phases | None |

**New enum literal names to verify:**

| Literal | Risk | Notes |
|---|---|---|
| `pending`, `measured`, `targetMet`, `targetNotMet` | LOW | Compound names, no SysML conflict expected |
| `baseline` | LOW | Not a SysML keyword |
| `threeMonthly`, `sixMonthly`, `annually` | LOW | Compound names |
| `adHoc` | LOW | Compound name; `ad` and `hoc` are not keywords |
| `patientReported` | LOW | Compound name |
| `adherence`, `safety` | LOW | Common English but not SysML keywords |
| `within`, `greaterThan`, `lessThan`, `equalTo` | **LOW-MEDIUM** | `within` is not a SysML v2 keyword. `greaterThan` / `lessThan` are safe compound forms |

No HIGH-risk literals identified. All follow the compound-name pattern that has been consistently safe.

### 4.4 Package structure after elaboration

```
Knowledge::OutcomeFramework
├── (imports Foundation::CommonTypes, Foundation::MetadataLibrary)
│
├── OutcomeDefinition (part def — abstract outcome interface)
│   ├── Common attributes: outcomeName, description, category, etc.
│   ├── Target specification: targetOperator, targetValue, targetUnit, etc.
│   └── Measurement link: measurementFrequency, evaluationQuery
│
├── MeasurementSchedule (part def — schedule for a pathway)
│   ├── scheduleName, pathwayRef, description
│   └── part measurementPoints : MeasurementPoint[0..*]
│
├── MeasurementPoint (part def — a single assessment point)
│   ├── pointName, timingWeeks, description
│   └── isRepeating, repeatIntervalWeeks
│
├── OutcomeEvaluationResult (part def — result of outcome measurement)
│   ├── Links to OutcomeDefinition, patient, measurement point
│   ├── actualValue, targetMet status
│   └── Links to EvaluationResult (LogicEngine) for audit chain
│
├── OutcomeFeedbackRecord (part def — LearningCycles interface)
│   ├── patternDescription, affectedOutcome, cohortSize
│   └── proposedAction, severity
│
├── Concrete outcome definitions (part usages with :>>)
│   ├── Clinical: oestradiolTarget, testosteroneMascTarget,
│   │            testosteroneSuppressionTarget, haematologySafety,
│   │            metabolicSafety
│   ├── Adherence: monitoringAdherence, appointmentAdherence
│   ├── Safety: adverseEventTracking
│   └── PRO: treatmentSatisfaction, goalAttainment
│
├── Hormone therapy measurement schedule (part usage)
│   └── Measurement points: baseline, threeMonth, sixMonth,
│       twelveMonth, annualMonitoring
│
├── openEHR annotation on OutcomeEvaluationResult
│
└── Use cases
    ├── RecordOutcomeMeasurement
    ├── EvaluateOutcomeAgainstTarget
    ├── ProduceOutcomeReport
    └── FeedOutcomeToLearningCycle
```

---

## 5. Staged Implementation

### Stage 1 — New enums in Foundation::CommonTypes

**Goal:** Add the outcome vocabulary enums needed by the OutcomeFramework structural model.

**File:** `model/foundation.sysml` → `Foundation::CommonTypes`

Add after the existing MonitoringAction enum (last enum from Phase 3):

```sysml
        // Added Session 11: Knowledge Layer Phase 4 (OutcomeFramework)

        enum def OutcomeCategory {
            doc /* Category of a clinical outcome measure.
                 * Determines which outcomes are collected at
                 * each measurement point and how they are
                 * reported. */
            clinical;
            adherence;
            safety;
            patientReported;
        }

        enum def OutcomeStatus {
            doc /* Status of an individual outcome measurement
                 * against its defined target.
                 * pending: measurement due but not yet taken
                 * measured: data collected, not yet evaluated
                 * targetMet: evaluated and within target
                 * targetNotMet: evaluated and outside target
                 * indeterminate: data insufficient for evaluation */
            pending;
            measured;
            targetMet;
            targetNotMet;
            indeterminate;
        }

        enum def MeasurementFrequency {
            doc /* How often an outcome is measured. Determines
                 * which measurement points include this outcome. */
            baseline;
            threeMonthly;
            sixMonthly;
            annually;
            adHoc;
        }

        enum def ComparisonOperator {
            doc /* How a target value is compared against an actual
                 * measurement. Used in OutcomeDefinition to specify
                 * the target condition.
                 * within: actual falls within a range (uses
                 *   targetValue and targetUpperBound)
                 * greaterThan: actual exceeds a threshold
                 * lessThan: actual is below a threshold
                 * equalTo: actual matches exactly */
            within;
            greaterThan;
            lessThan;
            equalTo;
        }
```

**Acceptance criteria:**
- All four enums parse clean in Syside
- No naming conflicts with existing CommonTypes enums
- All enum literals resolve without reserved-word errors
- Hover tooltips show doc blocks

**Syntax risk — LOW:** All proposed literals are compound names or uncommon English words. None are SysML keywords based on the reserved word list (v3.6).

**Git checkpoint:** Commit after Stage 1. Message: `Add outcome measurement enums to CommonTypes`

---

### Stage 2 — OutcomeFramework restructure and core part defs

**Goal:** Replace the current minimal `OutcomeDefinition` with a comprehensive outcome definition model. Add `MeasurementPoint`, `MeasurementSchedule`, `OutcomeEvaluationResult`, and `OutcomeFeedbackRecord` part defs. Add concrete outcome definitions, measurement points, and the hormone therapy schedule as part usages with `:>>`. Add use cases.

**File:** `model/knowledge.sysml` → `Knowledge::OutcomeFramework`

**Replace** the current package content entirely. The full SysML code is provided in Appendix A.

**Acceptance criteria:**
- All part defs parse clean (OutcomeDefinition, MeasurementPoint, MeasurementSchedule, OutcomeEvaluationResult, OutcomeFeedbackRecord)
- All part usages with `:>>` parse clean (10 outcome definitions, 5 measurement points, 1 schedule)
- Cross-package enum imports resolve (new enums from Stage 1, existing Severity)
- Boolean attribute `:>>` redefinition works (`isRepeating = false` / `true`)
- Integer attribute `:>>` redefinition works (`timingWeeksFromInitiation = 12`) — already validated v3.6
- Hover tooltips show doc blocks for all elements
- `gsl` hierarchy shows updated element counts for OutcomeFramework
- All four use case defs parse clean

**Syntax risk:**
- **Boolean `:>>` defaults** (`isRepeating = false`): Not explicitly listed as tested in the syntax reference. String and enum literal defaults are validated (v3.5). Integer literal defaults are validated (v3.6). Boolean literal defaults are structurally identical and should work. If they fail, fall back to an enum (YesNo or similar) or remove the attribute and document in the doc block. **Risk: LOW-MEDIUM.**
- **10 `:>>` redefinitions in a single part usage** (OutcomeDefinition usages redefine all 10 attributes): Phase 3 validated 7. Modest increase. **Risk: LOW.**
- All other patterns are validated.

**Git checkpoint:** Commit after Stage 2. Message: `Elaborate OutcomeFramework with outcome definitions and measurement schedule`

---

### Stage 3 — openEHR annotations

**Goal:** Add `@OpenEhrArchetype` metadata annotation to `OutcomeEvaluationResult`, establishing traceability between the outcome model and CDR archetype layer.

**File:** `model/knowledge.sysml` → `Knowledge::OutcomeFramework`

Add inside the `OutcomeEvaluationResult` part def body, before the doc block:

```sysml
        part def OutcomeEvaluationResult {
            @OpenEhrArchetype {
                archetypeId = "openEHR-EHR-EVALUATION.outcome_assessment.v0";
                rmClass = "EVALUATION";
            }
            doc /* [existing doc block] */
            // ... existing attributes ...
        }
```

**Annotation decisions:**

| Part def | Annotated? | Rationale |
|---|---|---|
| `OutcomeEvaluationResult` | Yes | Outcome assessments are clinical evaluations persisted in the CDR |
| `OutcomeFeedbackRecord` | No | Governance artefact, may live in audit store rather than CDR |
| `OutcomeDefinition` | No | Model-level definition, not a CDR composition |
| `MeasurementPoint` / `MeasurementSchedule` | No | Model-level scheduling structures, not CDR data |

**Acceptance criteria:**
- `@OpenEhrArchetype` annotation parses on `OutcomeEvaluationResult`
- Cross-package import of `MetadataLibrary` already present in the package imports
- Hover tooltip shows metadata

**Syntax risk — NONE:** This pattern is validated (v3.4, CDR Exercise Phase E).

**Git checkpoint:** Commit with Stage 2 if small, or separately. Message: `Add openEHR archetype annotation to outcome evaluation result`

---

### Stage 4 — CDS and LearningCycles doc block updates

**Goal:** Update the ClinicalDecisionSupport and LearningCycles doc blocks to reference the OutcomeFramework, establishing the conceptual connections without modifying structural content.

**File:** `model/knowledge.sysml`

**CDS doc block addition** (add after the existing elaboration note):

```
             * Goal-state projection:
             * The GoalProjector (LogicEngine) consumes three goal
             * sources: requirements (Enterprise::Regulation),
             * constraint evaluation specs (here), and outcome
             * definitions (Knowledge::OutcomeFramework). Outcome
             * definitions are self-contained — they specify both
             * the target and the evaluation query, so a separate
             * evaluation spec is not needed for them.
```

**LearningCycles doc block update** — replace the current doc block with expanded version referencing OutcomeFeedbackRecord, and update use case doc blocks to reference outcome feedback. Full text provided in Appendix B.

**Acceptance criteria:**
- Updated doc blocks parse clean
- No structural changes to CDS or LearningCycles
- Updated use case doc blocks in LearningCycles parse clean

**Git checkpoint:** Message: `Update CDS and LearningCycles doc blocks for outcome framework connections`

---

### Stage 5 — Verification, documentation, and session close

#### Step 5.1 — Full model verification

Open the entire workspace in Syside and verify clean parse across all files. Changes span two files:

- `model/foundation.sysml` — CommonTypes: 4 new enums
- `model/knowledge.sysml` — OutcomeFramework: restructured with 5 part defs, 10 outcome usages, 5 measurement point usages, 1 schedule usage, 4 use cases, 1 openEHR annotation; CDS: updated doc block; LearningCycles: updated doc block and use case doc blocks

Check for:
- All new part defs parse clean
- All `:>>` redefinitions resolve (string, enum, integer, and boolean literals)
- Cross-package enum imports resolve
- `@OpenEhrArchetype` annotation on OutcomeEvaluationResult resolves
- Existing model elements unaffected
- Boolean literal `:>>` (`isRepeating = false` / `true`) parses — **this is the one new syntax question**
- Hover tooltips show doc blocks for all new elements

#### Step 5.2 — Run `gsl save`

Regenerate all hierarchy outputs. Updated element counts expected:

- CommonTypes: 2 parts, **25 enums** (+4 from Phase 4)
- OutcomeFramework: **5 part defs**, **4 use cases** (replacing the previous 1 part def, 0 use cases)

#### Step 5.3 — Syntax reference update

**New patterns to verify:**

| Pattern | Notes |
|---|---|
| `:>>` with boolean literal default | `attribute :>> isRepeating = false;` — if confirmed, add to v3.7 Section 2 |
| 10 `:>>` redefinitions in a single part usage | OutcomeDefinition usages redefine all 10 attributes — exercises scale beyond Phase 3's 7 |

**New safe enum literals (if verified):**
`pending`, `measured`, `targetMet`, `targetNotMet`, `baseline`, `threeMonthly`, `sixMonthly`, `annually`, `adHoc`, `patientReported`, `adherence`, `safety`, `within`, `greaterThan`, `lessThan`, `equalTo` (16 new literals)

**Decision criterion for v3.7:** If boolean literal `:>>` defaults are a genuinely new verified pattern (they are not listed as tested in v3.6), produce v3.7. Otherwise, note confirming evidence for existing patterns in the session report.

#### Step 5.4 — Traceability verification

Verify the outcome-to-self-knowledge traceability chain:

```
Knowledge::OutcomeFramework
  oestradiolTarget : OutcomeDefinition
    outcomeName = "OestradiolTherapeuticRange"
    targetOperator = ComparisonOperator::within
    targetValue = "400", targetUpperBound = "600"
        ↓ (goal-state projection)
Knowledge::LogicEngine
  GoalProjector
    projects outcome definitions into GoalProjections
        ↓ (gap analysis)
  GapAnalyser
    compares CDR data against GoalProjection
    evaluationQuery: AQL for LabResult with testName='oestradiol'
        ↓ (if target not met)
  Deficit
    goalReference = "OestradiolTherapeuticRange"
    severity = warning
    remediationCategory = recommended
        ↓ (in SystemStateAssessment)
  SystemStateAssessment
    deficits[]: includes the unmet outcome
    evaluationResults[]: includes the supporting evidence
```

And the outcome-to-learning-cycle chain:

```
Knowledge::OutcomeFramework
  ProduceOutcomeReport (use case)
    aggregated outcome data shows pattern
        ↓
  OutcomeFeedbackRecord
    patternDescription, affectedOutcome, cohortSize
        ↓
Knowledge::LearningCycles
  ProposePathwayRefinement (use case)
    receives feedback record as input
        ↓
  ReviewAndApproveChange (use case)
    clinical governance review
        ↓ (if approved)
  Update SysML model → regenerate → changed pathway/protocol
```

#### Step 5.5 — Session report

Write session report covering:
- What was completed (which stages, which steps)
- Syntax findings (boolean `:>>`, 10 redefinitions at scale, new safe literals)
- Design decisions made (no separate evaluation spec for outcomes, self-contained OutcomeDefinition, OutcomeFeedbackRecord as LearningCycles interface)
- Repository state after session
- Recommended next steps (Phase 5 — Generator exploration)

#### Step 5.6 — Git final commit

Stage and commit all remaining changes. Message: `Complete Knowledge Layer Phase 4: OutcomeFramework elaboration`

---

## 6. Execution Order and Dependencies

```
Pre-flight checks (Stage 0)
    │
    ▼
Stage 1: New enums in CommonTypes              ← no dependencies beyond clean model
    │   (4 outcome vocabulary enums)
    │
    ▼
Stage 2: OutcomeFramework restructure          ← depends on Stage 1
    │   (5 part defs, 10 outcome usages,         (uses enums from Stage 1)
    │    5 measurement point usages,
    │    1 schedule usage, 4 use cases)
    │
    ▼
Stage 3: openEHR annotation                   ← depends on Stage 2
    │   (@OpenEhrArchetype on                     (annotates part def from Stage 2)
    │    OutcomeEvaluationResult)
    │
    ▼
Stage 4: CDS + LearningCycles doc updates     ← depends on Stage 2
    │   (doc block updates only,                   (references OutcomeFramework)
    │    no structural changes)
    │
    ▼
Stage 5: Verification + Documentation         ← depends on all above
```

Stages 3 and 4 are independent of each other and could be done in any order after Stage 2. Stage 5 is always last.

---

## 7. Identified Risks

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Boolean literal `:>>` (`false` / `true`) fails in Syside | Low | Low | Replace `isRepeating : Boolean` with an enum (`RepeatMode` with `once` and `repeating`) or remove the attribute and document in the doc block. The attribute is informational, not structurally critical. |
| 10 `:>>` redefinitions in one part usage causes Syside performance issues | Low | Low | Phase 3 validated 7 without issues. 10 is a modest increase. If problems arise, split OutcomeDefinition into two part defs (target + metadata) to reduce redefinition count per usage. |
| `targetValue` and `targetUpperBound` as String limits type safety | Design concern, not syntax risk | Low | String is used because target values may be numeric ("400"), categorical ("satisfied"), or descriptive ("complete"). A typed alternative would require separate part defs for numeric vs. categorical outcomes. String is pragmatic for the model; the generated evaluator can apply type-specific comparison logic based on the `targetOperator`. |
| Overmodelling: too many outcome definitions for a first pass | Medium | Low | 10 outcome definitions is a reasonable number for a comprehensive pathway. Each represents a distinct clinical concern. If the package feels unwieldy, outcome definitions could be grouped into sub-sections with comment separators (already the plan: clinical, adherence, safety, PRO). |
| MeasurementSchedule does not formally contain outcome definition references | Design concern | Low | MeasurementPoint does not have a `ref` to specific OutcomeDefinitions. The association is documented in doc blocks. A formal association would require `ref requiredOutcomes : OutcomeDefinition[0..*]` on MeasurementPoint — this should work syntactically but adds complexity. Consider adding in a refinement pass if the informal association is insufficient. |
| `evaluationQuery` attribute contains pseudo-AQL | Design concern | Low | The evaluation queries are illustrative, not executable. They indicate the query shape. Actual AQL will be defined when the InputDerivation instances are elaborated with real CDR schemas. |

---

## 8. Design Decisions

### 8.1 OutcomeDefinition as a self-contained structure (no separate evaluation spec)

Unlike constraints and decision tables, which have separate evaluation specs in CDS, outcome definitions embed their evaluation query directly. This is because:
- Outcome evaluation is not triggered by pathway step annotations (there is no `@Outcome` metadata on action steps). It is triggered by measurement schedule timing.
- The evaluation query for outcomes is simpler: check CDR for a measurement at the expected time against the expected target. The InputDerivation pattern is appropriate for constraint evaluation (where inputs come from multiple sources with complex computation); outcome evaluation is typically a single AQL query.
- Adding a separate spec would create 10 additional spec usages in CDS with no additional information beyond what the OutcomeDefinition already contains.

If outcome evaluation becomes more complex (composite outcomes requiring multi-source derivation), evaluation specs can be introduced later without restructuring.

### 8.2 MeasurementPoint as a standalone part def

Measurement points are modelled as a standalone part def with concrete usages, rather than as attributes or enums on OutcomeDefinition. This is because:
- Different outcomes may be measured at different points (not all outcomes at every point)
- Measurement points have their own attributes (timing, description, repeat schedule)
- The measurement schedule is a pathway-level concern (shared across all outcomes for that pathway), not an outcome-level concern

### 8.3 MeasurementSchedule contains MeasurementPoints but does not formally reference OutcomeDefinitions

The association between measurement points and outcome definitions is documented in doc blocks rather than modelled as formal `ref` relationships. This keeps the model simpler while the outcome framework is being established. If formal traceability is needed (e.g. for a generator that produces a measurement checklist), `ref` relationships can be added in a refinement pass.

### 8.4 OutcomeFeedbackRecord as the LearningCycles interface

The feedback loop from outcomes to pathway refinement goes through a structured record (OutcomeFeedbackRecord) rather than through a direct connection. This preserves the governance boundary: the feedback record is evidence that feeds into a human review process, not an automatic trigger for pathway modification. The record captures the pattern, the evidence, and a proposed action — the governance body decides whether to act on it.

### 8.5 Target values as strings, comparison by operator

Target values are modelled as `String` attributes with a `ComparisonOperator` enum specifying how to compare. This accommodates numeric targets ("400", compared `within` a range), categorical targets ("satisfied", compared as enum membership), and descriptive targets ("complete", compared as existence checks). The generated evaluator will dispatch to type-specific comparison logic based on the operator and unit.

A more rigorous alternative would define separate part defs for numeric outcomes (with `Real` target values) and categorical outcomes (with enum target values). This is cleaner but significantly increases the part def count without corresponding modelling benefit at this stage. The string-based approach is pragmatic and can be refined if the generated evaluator needs stronger typing.

### 8.6 Representative clinical values

All clinical values (hormone level targets, safety thresholds, timing intervals) are representative for modelling purposes. This is explicitly noted in the OutcomeFramework doc block and in individual outcome doc blocks. The modelling purpose is to validate the structural pattern and the traceability chain, not to encode the clinical protocol. Real values will be loaded from clinical sources before runtime use.

### 8.7 Outcome measurement points vs pathway steps

Measurement points are defined in OutcomeFramework, not as pathway steps. The pathway defines *what happens clinically* (blood tests, consultations, prescribing decisions). The outcome framework defines *what to measure and when*. The connection is temporal: a measurement point at 12 weeks implies that the pathway should have produced relevant CDR data (monitoring bloods, consultation records) by that time. If the data is missing, that is an adherence deficit.

This separation means outcome measurement can continue after the pathway is formally complete. A patient who has transitioned to ongoing care still has annual outcome measurements — these are not part of the initiation pathway but are part of the outcome framework.

---

## 9. Model Element Counts After Phase 4 (Projected)

### New elements in CommonTypes

| Element type | Count | Names |
|---|---|---|
| Enum defs | +4 | OutcomeCategory, OutcomeStatus, MeasurementFrequency, ComparisonOperator |

### New elements in OutcomeFramework

| Element type | Count | Names |
|---|---|---|
| Part defs | +5 (net +4, replacing 1) | OutcomeDefinition (restructured), MeasurementPoint, MeasurementSchedule, OutcomeEvaluationResult, OutcomeFeedbackRecord |
| Part usages (outcomes) | +10 | oestradiolTarget, testosteroneMascTarget, testosteroneSuppressionTarget, haematologySafety, metabolicSafety, monitoringAdherence, appointmentAdherence, adverseEventTracking, treatmentSatisfaction, goalAttainment |
| Part usages (measurement points) | +5 | baselinePoint, threeMonthPoint, sixMonthPoint, twelveMonthPoint, annualMonitoringPoint |
| Part usages (schedule) | +1 | hormoneTherapySchedule |
| Use case defs | +4 | RecordOutcomeMeasurement, EvaluateOutcomeAgainstTarget, ProduceOutcomeReport, FeedOutcomeToLearningCycle |

### Cumulative model element counts after Phase 4

| Package | Part defs | Enum defs | Constraint defs | Use case defs | State defs | Metadata defs |
|---|---|---|---|---|---|---|
| Foundation::MetadataLibrary | — | — | — | — | — | 9 |
| Foundation::CommonTypes | 2 | **25** (+4) | — | — | — | — |
| Foundation::StatePatterns | — | — | — | — | 1 | — |
| Knowledge::ClinicalDecisionSupport | 3 | — | — | 3 | — | — |
| Knowledge::ConstraintLibrary | — | — | 8 | — | — | — |
| Knowledge::LogicEngine | 21 | — | — | 4 | — | — |
| Knowledge::DecisionModels | 5 | 1 | — | 2 | — | — |
| Knowledge::OutcomeFramework | **5** (+4) | — | — | **4** (+4) | — | — |
| Knowledge::LearningCycles | — | — | — | 2 | — | — |
| Knowledge::Analytics | 1 | — | — | — | — | — |

---

## 10. Estimated Effort

| Stage | Estimated time | Notes |
|---|---|---|
| Pre-flight | 5–10 min | Ella: Syside checks, git status |
| Stage 1 | 10–15 min | 4 enums in CommonTypes — straightforward, low-risk literals |
| Stage 2 | 40–55 min | Largest stage: 5 part defs, 16 part usages with `:>>`, 4 use cases. Boolean `:>>` to verify. |
| Stage 3 | 5–10 min | Single `@OpenEhrArchetype` annotation |
| Stage 4 | 10–15 min | Doc block updates to CDS and LearningCycles |
| Stage 5 | 15–25 min | Verification, syntax reference check, session report |
| **Total** | **~1.5–2.5 hours** | Single session |

---

## 11. Recommended Next Steps After Phase 4

### Phase 5 — Generator exploration

With the full Knowledge Layer structural model complete (evaluation architecture, component model, decision tables, outcome framework), Phase 5 explores the generation side:

- **Constraint-to-TypeScript generator:** Read `constraint def` blocks from ConstraintLibrary and produce TypeScript evaluation functions with structured EvaluationResult output
- **Decision-table-to-TypeScript generator:** Read decision table part defs from DecisionModels and produce TypeScript table evaluation functions
- **System Model Manifest generator:** Extend `gen_package_hierarchy.py` to extract deeper element information (constraints, requirements, outcomes, entity lifecycles) into a JSON manifest
- **Evaluate Syside Automator** for semantic model access as an alternative to regex-based parsing

### Test nested `:>>` syntax (deferred from Phase 1, still deferred)

The nested `:>>` redefinition pattern remains deferred. Phase 4 does not exercise it. If the OutcomeDefinition pattern grows to need nested parts (e.g. complex target specifications as contained parts), this will become relevant.

### LearningCycles elaboration (future)

Phase 4 defines the *interface* from OutcomeFramework to LearningCycles (OutcomeFeedbackRecord, updated use case doc blocks). Full LearningCycles elaboration — modelling the refinement process as an action flow with governance gates — is a natural follow-on but is not part of the Knowledge Layer Elaboration plan.

### Analytics data contract (future)

OutcomeFramework produces structured outcome data that is a natural feed for Analytics (Tier 3). Defining the data contract between OutcomeFramework and Analytics is a future concern that depends on the analytics architecture decisions.

---

## Appendix A — Full SysML Code for OutcomeFramework Package

The complete replacement content for `Knowledge::OutcomeFramework` in `model/knowledge.sysml`:

```sysml
    package OutcomeFramework {
        private import ScalarValues::*;
        private import Foundation::CommonTypes::*;
        private import Foundation::MetadataLibrary::*;

        doc /* Outcome definitions, measurement points, structured outcome
             * capture, and outcome-to-pathway feedback for clinical
             * outcome measurement.
             *
             * Records not just that a patient was treated, but the specific
             * regimen, monitoring results at defined intervals, whether
             * clinical targets were achieved, and any adverse events. Over
             * time this builds a dataset that informs pathway refinement
             * via LearningCycles.
             *
             * Architectural role — outcomes are goals:
             * Each OutcomeDefinition implies an expected state. The
             * GoalProjector (Knowledge::LogicEngine) projects outcome
             * definitions into GoalProjections. The GapAnalyser compares
             * actual outcome data (from CDR) against these projections and
             * produces Deficit records for unmet outcomes. This connects
             * OutcomeFramework directly to the five-layer self-knowledge
             * architecture (Phase 1) — outcomes are the third goal source
             * alongside requirements (Enterprise::Regulation) and
             * constraints (Knowledge::ConstraintLibrary).
             *
             * Data capture — outcomes are CDR compositions:
             * Outcome measurements are captured as openEHR compositions
             * in the CDR via the same two data paths validated in the CDR
             * exercise: workflow-driven (Temporal activities commit
             * compositions during pathway execution) and form-driven
             * (clinician records outcome data directly). The outcome
             * framework defines which compositions constitute outcomes,
             * at which measurement points, and against which targets.
             *
             * Feedback loop — outcomes drive pathway refinement:
             * Aggregated outcome data feeds into LearningCycles:
             * capture structured outcomes → analyse patterns → propose
             * pathway refinement → clinical governance review → update
             * model → regenerate. The model is the mechanism for both
             * capturing and enacting the learning.
             *
             * Elaborated Session 11: Knowledge Layer Phase 4.
             * Connects to Phase 1 (self-knowledge data structures),
             * Phase 2 (GoalProjector, GapAnalyser), and Phase 3
             * (decision tables that consume outcome-derived inputs). */

        // =============================================================
        // Core structural definitions
        // =============================================================

        part def OutcomeDefinition {
            doc /* A defined clinical outcome with target criteria and
                 * measurement specification.
                 *
                 * Each outcome definition specifies:
                 * - What is being measured (name, description, category)
                 * - What the target is (value, range, comparison operator)
                 * - How often it is measured (frequency)
                 * - How to query the CDR for actual data (evaluation query)
                 *
                 * Outcome definitions are the input to goal-state
                 * projection. The GoalProjector transforms each
                 * definition into a GoalProjection that the GapAnalyser
                 * evaluates against CDR data.
                 *
                 * Concrete outcomes are modelled as part usages with
                 * :>> attribute redefinitions, following the
                 * ConstraintEvaluationSpec and decision table row
                 * patterns established in Phases 1 and 3. */
            attribute outcomeName : String;
            attribute description : String;
            attribute category : OutcomeCategory;
            attribute frequency : MeasurementFrequency;
            attribute targetOperator : ComparisonOperator;
            attribute targetValue : String;
            attribute targetUpperBound : String;
            attribute targetUnit : String;
            attribute evaluationQuery : String;
            attribute severity : Severity;
        }

        part def MeasurementPoint {
            doc /* A defined point in time at which outcome measurements
                 * are collected. Each measurement point specifies when
                 * it occurs (weeks from treatment initiation), what
                 * outcomes are assessed, and what the clinical focus is.
                 *
                 * Measurement points are contained within a
                 * MeasurementSchedule. At runtime, the evaluation
                 * infrastructure checks whether due measurement points
                 * have corresponding CDR data — a missing measurement
                 * at a due point produces an adherence deficit. */
            attribute pointName : String;
            attribute timingWeeksFromInitiation : Integer;
            attribute description : String;
            attribute isRepeating : Boolean;
            attribute repeatIntervalWeeks : Integer;
        }

        part def MeasurementSchedule {
            doc /* A complete measurement schedule for a clinical
                 * pathway. Defines the sequence of measurement points
                 * and associates each point with the outcomes to be
                 * measured.
                 *
                 * One schedule per pathway. The schedule is the bridge
                 * between the pathway's temporal structure (when things
                 * happen) and the outcome framework's measurement
                 * structure (what to measure and when). */
            attribute scheduleName : String;
            attribute pathwayRef : String;
            attribute description : String;
            part measurementPoints : MeasurementPoint[0..*];
        }

        part def OutcomeEvaluationResult {
            @OpenEhrArchetype {
                archetypeId = "openEHR-EHR-EVALUATION.outcome_assessment.v0";
                rmClass = "EVALUATION";
            }
            doc /* The result of evaluating an outcome measurement
                 * against its target. Links the outcome definition,
                 * the patient, the measurement point, the actual
                 * value obtained, and whether the target was met.
                 *
                 * Structurally parallel to EvaluationResult in
                 * LogicEngine — both are structured, auditable
                 * records of a comparison against an expected state.
                 * The key difference is that EvaluationResult records
                 * a point-in-time constraint check, while
                 * OutcomeEvaluationResult records a longitudinal
                 * clinical outcome measurement.
                 *
                 * At runtime, these are persisted as CDR compositions
                 * or audit records, queryable for governance reporting
                 * and patient-facing outcome summaries. */
            attribute outcomeRef : String;
            attribute patientId : String;
            attribute measurementPointRef : String;
            attribute measuredAt : String;
            attribute actualValue : String;
            attribute actualUnit : String;
            attribute outcomeStatus : OutcomeStatus;
            attribute clinicianNotes : String;
        }

        // =============================================================
        // Outcome-to-LearningCycles feedback interface
        // =============================================================

        part def OutcomeFeedbackRecord {
            doc /* A structured record linking aggregated outcome data
                 * to a pathway refinement proposal. This is the
                 * interface between OutcomeFramework and LearningCycles.
                 *
                 * When outcome patterns are identified (e.g. a
                 * significant proportion of patients not reaching
                 * target at 6 months on a particular regimen), the
                 * pattern is captured as a feedback record that
                 * feeds into LearningCycles::ProposePathwayRefinement.
                 *
                 * The feedback record is not an automatic trigger —
                 * it surfaces the pattern with supporting data for
                 * clinical governance review. The decision to modify
                 * the pathway or protocol is a human governance
                 * decision, consistent with the remediation boundary
                 * principle (automatic / recommended / advisory). */
            attribute feedbackId : String;
            attribute patternDescription : String;
            attribute affectedOutcome : String;
            attribute affectedPathway : String;
            attribute cohortSize : Integer;
            attribute observationPeriod : String;
            attribute proposedAction : String;
            attribute severity : Severity;
            attribute detectedAt : String;
        }

        // =============================================================
        // Concrete outcome definitions — Hormone Therapy
        //
        // Representative clinically plausible values for modelling
        // purposes. Actual clinical target ranges will be loaded
        // from the validated prescribing protocol before runtime use.
        // =============================================================

        // --- Clinical outcomes ---

        part oestradiolTarget : OutcomeDefinition {
            doc /* Target oestradiol level for feminising hormone
                 * therapy. Measured at each monitoring blood test.
                 * Target range is trough level (measured immediately
                 * before next dose or at a standardised time point).
                 *
                 * Representative target: 400–600 pmol/L.
                 * Source: Endocrine Society guidelines / local protocol. */
            attribute :>> outcomeName = "OestradiolTherapeuticRange";
            attribute :>> description = "Serum oestradiol within therapeutic target range at trough";
            attribute :>> category = OutcomeCategory::clinical;
            attribute :>> frequency = MeasurementFrequency::threeMonthly;
            attribute :>> targetOperator = ComparisonOperator::within;
            attribute :>> targetValue = "400";
            attribute :>> targetUpperBound = "600";
            attribute :>> targetUnit = "pmol/L";
            attribute :>> evaluationQuery = "AQL: LabResult where testName='oestradiol' for patient within measurement window";
            attribute :>> severity = Severity::warning;
        }

        part testosteroneMascTarget : OutcomeDefinition {
            doc /* Target testosterone level for masculinising
                 * hormone therapy. Measured at each monitoring
                 * blood test.
                 *
                 * Representative target: 10–30 nmol/L.
                 * Source: Endocrine Society guidelines / local protocol. */
            attribute :>> outcomeName = "TestosteroneTherapeuticRange";
            attribute :>> description = "Serum testosterone within therapeutic target range";
            attribute :>> category = OutcomeCategory::clinical;
            attribute :>> frequency = MeasurementFrequency::threeMonthly;
            attribute :>> targetOperator = ComparisonOperator::within;
            attribute :>> targetValue = "10";
            attribute :>> targetUpperBound = "30";
            attribute :>> targetUnit = "nmol/L";
            attribute :>> evaluationQuery = "AQL: LabResult where testName='testosterone' for patient within measurement window";
            attribute :>> severity = Severity::warning;
        }

        part testosteroneSuppressionTarget : OutcomeDefinition {
            doc /* Target testosterone suppression for feminising
                 * hormone therapy. Testosterone should be suppressed
                 * below the threshold once oestradiol is at target.
                 *
                 * Representative target: < 2 nmol/L.
                 * Source: Endocrine Society guidelines / local protocol. */
            attribute :>> outcomeName = "TestosteroneSuppression";
            attribute :>> description = "Serum testosterone suppressed below threshold on feminising therapy";
            attribute :>> category = OutcomeCategory::clinical;
            attribute :>> frequency = MeasurementFrequency::threeMonthly;
            attribute :>> targetOperator = ComparisonOperator::lessThan;
            attribute :>> targetValue = "2";
            attribute :>> targetUpperBound = "";
            attribute :>> targetUnit = "nmol/L";
            attribute :>> evaluationQuery = "AQL: LabResult where testName='testosterone' for patient on feminising therapy";
            attribute :>> severity = Severity::warning;
        }

        part haematologySafety : OutcomeDefinition {
            doc /* Haematological safety monitoring. For masculinising
                 * therapy: haemoglobin and haematocrit must remain
                 * within safe limits (polycythaemia risk). For
                 * feminising therapy: VTE risk markers monitored.
                 *
                 * Representative target: haematocrit < 0.54.
                 * Source: Local protocol / Endocrine Society. */
            attribute :>> outcomeName = "HaematologySafety";
            attribute :>> description = "Haematological safety markers within safe limits";
            attribute :>> category = OutcomeCategory::safety;
            attribute :>> frequency = MeasurementFrequency::threeMonthly;
            attribute :>> targetOperator = ComparisonOperator::lessThan;
            attribute :>> targetValue = "0.54";
            attribute :>> targetUpperBound = "";
            attribute :>> targetUnit = "L/L";
            attribute :>> evaluationQuery = "AQL: LabResult where testName='haematocrit' for patient within measurement window";
            attribute :>> severity = Severity::critical;
        }

        part metabolicSafety : OutcomeDefinition {
            doc /* Metabolic safety monitoring: liver function tests
                 * and lipid profile within acceptable limits. Both
                 * oestrogen and testosterone therapy can affect
                 * hepatic and lipid markers.
                 *
                 * This is a composite outcome — multiple lab values
                 * are assessed. The evaluationQuery returns a set
                 * of results; all must be within limits for the
                 * outcome to be met.
                 *
                 * Representative: LFTs within 3x upper limit of normal. */
            attribute :>> outcomeName = "MetabolicSafety";
            attribute :>> description = "Liver function and lipid profile within acceptable limits";
            attribute :>> category = OutcomeCategory::safety;
            attribute :>> frequency = MeasurementFrequency::sixMonthly;
            attribute :>> targetOperator = ComparisonOperator::lessThan;
            attribute :>> targetValue = "3";
            attribute :>> targetUpperBound = "";
            attribute :>> targetUnit = "xULN";
            attribute :>> evaluationQuery = "AQL: LabResult where testName in ('ALT','GGT') for patient within measurement window";
            attribute :>> severity = Severity::warning;
        }

        // --- Adherence outcomes ---

        part monitoringAdherence : OutcomeDefinition {
            doc /* Whether monitoring bloods are completed within
                 * the defined schedule. This is the longitudinal
                 * pattern of the BloodMonitoringIntervalConstraint
                 * — the constraint checks one point in time; this
                 * outcome tracks the pattern across all measurement
                 * points.
                 *
                 * Target: 100% of scheduled monitoring bloods
                 * completed within the allowed window. */
            attribute :>> outcomeName = "MonitoringAdherence";
            attribute :>> description = "Monitoring blood tests completed at all scheduled measurement points";
            attribute :>> category = OutcomeCategory::adherence;
            attribute :>> frequency = MeasurementFrequency::threeMonthly;
            attribute :>> targetOperator = ComparisonOperator::equalTo;
            attribute :>> targetValue = "complete";
            attribute :>> targetUpperBound = "";
            attribute :>> targetUnit = "";
            attribute :>> evaluationQuery = "AQL: count of LabResult compositions vs count of due measurement points";
            attribute :>> severity = Severity::warning;
        }

        part appointmentAdherence : OutcomeDefinition {
            doc /* Whether scheduled clinical appointments are
                 * attended. Missed appointments may indicate
                 * disengagement, access barriers, or dissatisfaction.
                 *
                 * Target: all scheduled appointments attended or
                 * rescheduled within acceptable window. */
            attribute :>> outcomeName = "AppointmentAdherence";
            attribute :>> description = "Scheduled clinical appointments attended or rescheduled within window";
            attribute :>> category = OutcomeCategory::adherence;
            attribute :>> frequency = MeasurementFrequency::threeMonthly;
            attribute :>> targetOperator = ComparisonOperator::equalTo;
            attribute :>> targetValue = "complete";
            attribute :>> targetUpperBound = "";
            attribute :>> targetUnit = "";
            attribute :>> evaluationQuery = "AQL: appointment attendance record for patient within measurement window";
            attribute :>> severity = Severity::informational;
        }

        // --- Safety outcomes ---

        part adverseEventTracking : OutcomeDefinition {
            doc /* Tracking of adverse events during treatment.
                 * Any adverse event of warning severity or above
                 * is captured and evaluated.
                 *
                 * Target: no critical adverse events. Warning-level
                 * events are expected to be managed; critical events
                 * trigger urgent clinical review. */
            attribute :>> outcomeName = "AdverseEventTracking";
            attribute :>> description = "No critical adverse events; warning-level events managed and documented";
            attribute :>> category = OutcomeCategory::safety;
            attribute :>> frequency = MeasurementFrequency::threeMonthly;
            attribute :>> targetOperator = ComparisonOperator::equalTo;
            attribute :>> targetValue = "none-critical";
            attribute :>> targetUpperBound = "";
            attribute :>> targetUnit = "";
            attribute :>> evaluationQuery = "AQL: adverse event compositions for patient with severity >= critical";
            attribute :>> severity = Severity::critical;
        }

        // --- Patient-reported outcomes ---

        part treatmentSatisfaction : OutcomeDefinition {
            doc /* Patient-reported treatment satisfaction, captured
                 * during monitoring consultations. Also an input to
                 * the stabilityAssessment decision table.
                 *
                 * Target: patient satisfied or neutral. Dissatisfied
                 * status triggers exploration of concerns and
                 * potential pathway adjustment. */
            attribute :>> outcomeName = "TreatmentSatisfaction";
            attribute :>> description = "Patient-reported satisfaction with treatment progress";
            attribute :>> category = OutcomeCategory::patientReported;
            attribute :>> frequency = MeasurementFrequency::sixMonthly;
            attribute :>> targetOperator = ComparisonOperator::within;
            attribute :>> targetValue = "satisfied";
            attribute :>> targetUpperBound = "neutral";
            attribute :>> targetUnit = "";
            attribute :>> evaluationQuery = "AQL: consultation composition with satisfaction assessment for patient";
            attribute :>> severity = Severity::informational;
        }

        part goalAttainment : OutcomeDefinition {
            doc /* Patient-reported goal attainment — whether the
                 * patient feels their personal treatment goals are
                 * being met. This is distinct from clinical targets
                 * (which are physiological) and from satisfaction
                 * (which is about the service experience).
                 *
                 * Captured via structured self-assessment at 6-month
                 * and 12-month points.
                 *
                 * Target: patient reports goals being met or
                 * progressing. */
            attribute :>> outcomeName = "GoalAttainment";
            attribute :>> description = "Patient-reported progress toward personal treatment goals";
            attribute :>> category = OutcomeCategory::patientReported;
            attribute :>> frequency = MeasurementFrequency::sixMonthly;
            attribute :>> targetOperator = ComparisonOperator::within;
            attribute :>> targetValue = "met";
            attribute :>> targetUpperBound = "progressing";
            attribute :>> targetUnit = "";
            attribute :>> evaluationQuery = "AQL: self-assessment composition with goal attainment for patient";
            attribute :>> severity = Severity::informational;
        }

        // =============================================================
        // Hormone Therapy Measurement Schedule
        //
        // Defines the measurement points for the hormone therapy
        // initiation pathway and associates each point with the
        // outcomes to be collected.
        // =============================================================

        part baselinePoint : MeasurementPoint {
            doc /* Baseline measurements before treatment initiation.
                 * Pre-treatment values establish the reference for
                 * all subsequent outcome evaluation.
                 *
                 * Outcomes collected: all clinical (hormone levels,
                 * haematology, metabolic), baseline PROs. */
            attribute :>> pointName = "Baseline";
            attribute :>> timingWeeksFromInitiation = 0;
            attribute :>> description = "Pre-treatment baseline assessment. All clinical and safety bloods, initial PROs.";
            attribute :>> isRepeating = false;
            attribute :>> repeatIntervalWeeks = 0;
        }

        part threeMonthPoint : MeasurementPoint {
            doc /* First monitoring assessment at approximately
                 * 12 weeks post-initiation.
                 *
                 * Primary focus: initial hormone response. Are
                 * levels moving toward target? Any early side
                 * effects or safety concerns?
                 *
                 * Outcomes collected: all clinical, adherence,
                 * safety. PROs if concerns flagged. */
            attribute :>> pointName = "ThreeMonth";
            attribute :>> timingWeeksFromInitiation = 12;
            attribute :>> description = "First monitoring assessment. Initial hormone response, early safety review.";
            attribute :>> isRepeating = false;
            attribute :>> repeatIntervalWeeks = 0;
        }

        part sixMonthPoint : MeasurementPoint {
            doc /* Mid-term assessment at approximately 26 weeks.
                 *
                 * Primary focus: target achievement. Have therapeutic
                 * ranges been reached? Stability assessment. Full
                 * safety panel. Patient satisfaction and goal
                 * attainment.
                 *
                 * This is the first point at which the
                 * stabilityAssessment decision table may declare a
                 * patient stable (12+ weeks on current dose). */
            attribute :>> pointName = "SixMonth";
            attribute :>> timingWeeksFromInitiation = 26;
            attribute :>> description = "Mid-term assessment. Target achievement, stability, full safety panel, PROs.";
            attribute :>> isRepeating = false;
            attribute :>> repeatIntervalWeeks = 0;
        }

        part twelveMonthPoint : MeasurementPoint {
            doc /* Long-term assessment at approximately 52 weeks.
                 *
                 * Primary focus: sustained target levels, long-term
                 * safety, treatment satisfaction, readiness for
                 * transition to annual monitoring or shared care.
                 *
                 * Successful outcomes at this point typically trigger
                 * transition to ongoing care (annual monitoring,
                 * potentially shared care with GP). */
            attribute :>> pointName = "TwelveMonth";
            attribute :>> timingWeeksFromInitiation = 52;
            attribute :>> description = "Long-term assessment. Sustained targets, safety, transition readiness.";
            attribute :>> isRepeating = false;
            attribute :>> repeatIntervalWeeks = 0;
        }

        part annualMonitoringPoint : MeasurementPoint {
            doc /* Annual ongoing monitoring after stabilisation.
                 * Repeats every 52 weeks from the 12-month point.
                 *
                 * Primary focus: continued target levels, emerging
                 * long-term risks (metabolic, haematological),
                 * continued satisfaction. */
            attribute :>> pointName = "AnnualMonitoring";
            attribute :>> timingWeeksFromInitiation = 104;
            attribute :>> description = "Annual ongoing monitoring. Continued targets, long-term safety, satisfaction.";
            attribute :>> isRepeating = true;
            attribute :>> repeatIntervalWeeks = 52;
        }

        part hormoneTherapySchedule : MeasurementSchedule {
            doc /* Measurement schedule for the hormone therapy
                 * initiation pathway.
                 *
                 * Defines the standard measurement points from
                 * baseline through the first year and into ongoing
                 * annual monitoring. Individual patients may have
                 * additional ad-hoc measurement points triggered
                 * by the stabilityAssessment decision table
                 * (e.g. increased monitoring frequency if adjustment
                 * needed). */
            attribute :>> scheduleName = "HormoneTherapyInitiationSchedule";
            attribute :>> pathwayRef = "ServiceDelivery::ClinicalPathways::HormoneTherapy";
            attribute :>> description = "Standard measurement schedule for hormone therapy from baseline through annual monitoring";
        }

        // =============================================================
        // Use cases
        // =============================================================

        use case def RecordOutcomeMeasurement {
            doc /* Capture an outcome measurement for a patient at
                 * a specific measurement point. Data may enter via
                 * the workflow (Temporal activity commits composition)
                 * or via form entry (clinician or patient records
                 * directly).
                 *
                 * Both paths produce the same CDR composition type.
                 * The composition is tagged with the measurement
                 * point and outcome definition references for
                 * queryability. */
        }

        use case def EvaluateOutcomeAgainstTarget {
            doc /* Evaluate a recorded outcome measurement against
                 * its defined target. Produces an
                 * OutcomeEvaluationResult.
                 *
                 * This is conceptually parallel to EvaluateConstraint
                 * in LogicEngine: both compare actual data against
                 * an expected condition. The difference is that
                 * constraint evaluation is point-in-time (is this
                 * condition met right now?) while outcome evaluation
                 * is longitudinal (is this target being met across
                 * the measurement schedule?).
                 *
                 * At a population level, this use case feeds into
                 * governance reporting: what proportion of patients
                 * are achieving target at each measurement point? */
        }

        use case def ProduceOutcomeReport {
            doc /* Generate an outcome report for a patient, cohort,
                 * or pathway. Aggregates OutcomeEvaluationResults
                 * across measurement points to show the longitudinal
                 * outcome profile.
                 *
                 * Three reporting scopes:
                 * - Patient: individual outcome trajectory showing
                 *   values at each measurement point against targets
                 * - Cohort: population outcome summary showing what
                 *   proportion of patients meet targets at each point
                 * - Pathway: overall pathway effectiveness assessment
                 *   across all outcome categories
                 *
                 * Reports are derivable from CDR data via AQL.
                 * The report structure is a natural input to the
                 * SystemStateAssessment (Layer 4 — unmet outcome
                 * targets are deficits). */
        }

        use case def FeedOutcomeToLearningCycle {
            doc /* When outcome patterns indicate a potential
                 * pathway issue (e.g. a significant proportion of
                 * patients not reaching target on a regimen, or
                 * emerging safety signals), package the evidence
                 * as an OutcomeFeedbackRecord and feed it into
                 * LearningCycles::ProposePathwayRefinement.
                 *
                 * This is the closing connection in the learning
                 * loop: outcomes → evidence → proposal → governance
                 * review → model update → regeneration.
                 *
                 * Detection can be automated (scheduled Temporal
                 * workflow that analyses outcome patterns) or
                 * manual (clinician notices a trend and initiates
                 * feedback). The governance review step is always
                 * human. */
        }
    }
```

---

## Appendix B — Updated LearningCycles Package

The replacement content for `Knowledge::LearningCycles` in `model/knowledge.sysml`:

```sysml
    package LearningCycles {
        private import ScalarValues::*;

        doc /* Pathway refinement process, evidence review, change control
             * governance. Itself modelled as an action flow.
             *
             * Cycle: capture structured outcomes → analyse patterns →
             * propose pathway refinement → clinical governance review →
             * update model → regenerate. The model is the mechanism for
             * both capturing and enacting the learning.
             *
             * Input from OutcomeFramework:
             * OutcomeFeedbackRecord captures evidence of outcome patterns
             * (e.g. cohort not reaching targets on a specific regimen)
             * and feeds into ProposePathwayRefinement. Detection may be
             * automated (scheduled Temporal workflow analysing outcome
             * data) or clinician-initiated.
             *
             * Input from SystemStateAssessment:
             * Advisory-category deficits identified in gap analysis
             * (systemic issues that cannot be resolved by a single action)
             * also feed into the learning cycle as evidence for pathway
             * or protocol review.
             *
             * The governance review step is always human — the learning
             * cycle does not automatically modify the model. This is
             * consistent with the remediation boundary principle:
             * automatic actions are limited to deterministic,
             * pathway-defined steps; pathway changes require governance
             * approval. */

        use case def ProposePathwayRefinement {
            doc /* Initiate a pathway change proposal based on outcome
                 * data, OutcomeFeedbackRecords, or advisory deficits
                 * from SystemStateAssessments. */
        }

        use case def ReviewAndApproveChange {
            doc /* Clinical governance review and approval of a proposed
                 * pathway or protocol change. Approved changes are
                 * enacted by updating the SysML model and regenerating
                 * affected artefacts. */
        }
    }
```

---

*Plan prepared 9 March 2026 (Session 11). Implements Phase 4 of the Knowledge Layer Elaboration extended plan.*
