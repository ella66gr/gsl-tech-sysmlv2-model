# Knowledge Layer Elaboration — Phase 1 Implementation Plan

**Date:** 8 March 2026 (Session 8)
**Context:** Phase 1 of the Knowledge Layer Elaboration, as defined in the extended planning document. This plan breaks down the Track A (rule evaluation architecture) and Track B (self-knowledge architecture) steps into concrete, implementable SysML modelling tasks with acceptance criteria. All work in this phase is design work in the SysML model — no runtime code.

**Parent plan:** `documentation/plans/gsl-plan-knowledge-layer-elaboration-2026-03-08-extended.md`
**Syntax reference:** `documentation/reference/gsl-sysml-v2-syntax-reference-v3.4-2026-03-08.md`

---

## 1. Scope and Boundaries

### What Phase 1 delivers

- Concrete SysML part defs, enumerations, and structural elements that define the evaluation and self-knowledge architecture
- Formalised input derivation patterns connecting CDR data to constraint evaluation
- The EvaluationResult, ExplanationTrace, Deficit, and SystemStateAssessment structures as SysML part defs
- The System Model Manifest concept defined in an architecture decision document
- Design decisions documented for evaluation invocation and assessment invocation patterns

### What Phase 1 does NOT deliver

- Runtime code or generators (Phase 5)
- Elaborated LogicEngine internals (Phase 2)
- Decision table representations (Phase 3)
- Outcome definitions (Phase 4)
- Any Prolog or DMN integration

### Files affected

| File | Expected changes |
|---|---|
| `model/knowledge.sysml` | LogicEngine and ClinicalDecisionSupport packages elaborated with new part defs, enums, use cases |
| `model/foundation.sysml` | CommonTypes extended with shared evaluation types (EvaluationOutcome enum, severity enum, scope enum) |
| `documentation/reference/gsl-sysml-v2-syntax-reference-v3.5-*.md` | Updated if new syntax patterns are verified or traps discovered |
| `documentation/architecture/gsl-architecture-decision-knowledge-evaluation.md` | New. Architecture decision document for evaluation invocation and System Model Manifest |
| `documentation/session-reports/gsl-session-report-2026-03-08-s8.md` | New. Session report |

---

## 2. Pre-flight Checks

Before starting modelling work, confirm the following:

| Check | Action | Status |
|---|---|---|
| 2.1 | Verify `platform.sysml` parses clean in Syside (14 new packages from Session 7) | ☐ Ella to confirm |
| 2.2 | Run `gsl save` to regenerate hierarchy outputs after any Syside fixes | ☐ Ella to run |
| 2.3 | Confirm syntax reference v3.4 is current and accessible | ☐ Verified — `/documentation/reference/gsl-sysml-v2-syntax-reference-v3.4-2026-03-08.md` |
| 2.4 | Open `knowledge.sysml` and `foundation.sysml` in Syside to confirm clean parse before modifications | ☐ Ella to confirm |

---

## 3. Implementation Steps

### Stage 1 — Foundation types for the evaluation architecture

**Goal:** Establish the shared enumerations and small types that both Track A and Track B structures depend on. These go in `Foundation::CommonTypes` because they are consumed across multiple Knowledge sub-packages.

#### Step 1.1 — EvaluationOutcome enum

**File:** `model/foundation.sysml` → `Foundation::CommonTypes`

```sysml
enum def EvaluationOutcome {
    doc /* Result of evaluating a constraint, rule, or goal.
         * Three-valued: pass (condition met), fail (condition not met),
         * indeterminate (insufficient data to evaluate). */
    pass;
    fail;
    indeterminate;
}
```

**Acceptance:** Parses clean in Syside. Hover tooltip shows doc string.

#### Step 1.2 — Severity enum

**File:** `model/foundation.sysml` → `Foundation::CommonTypes`

```sysml
enum def Severity {
    doc /* Severity classification for deficits, constraints,
         * and audit findings. */
    critical;
    warning;
    informational;
}
```

**Acceptance:** Parses clean.

#### Step 1.3 — AssessmentScope enum

**File:** `model/foundation.sysml` → `Foundation::CommonTypes`

```sysml
enum def AssessmentScope {
    doc /* Scope at which an evaluation or assessment is performed. */
    patient;
    cohort;
    pathway;
    domain;
    system;
}
```

**Acceptance:** Parses clean.

#### Step 1.4 — DataSourceType enum

**File:** `model/foundation.sysml` → `Foundation::CommonTypes`

```sysml
enum def DataSourceType {
    doc /* Authoritative data source for input derivation.
         * Source-agnostic pattern: the same InputDerivation
         * structure works regardless of where data comes from. */
    cdr;        // openEHR CDR via AQL
    temporal;   // Temporal workflow state and history
    platform;   // Platform services (infrastructure, identity)
    entity;     // Entity lifecycle state (XState / Temporal-encoded)
}
```

**Acceptance:** Parses clean. Note: `entity` must be tested — not a known reserved word but confirm it doesn't shadow anything in KerML.

**Git checkpoint:** Commit after Stage 1 if all four enums parse clean. Message: `Add evaluation foundation types to CommonTypes`

---

### Stage 2 — Track A: EvaluationResult and ExplanationTrace (Steps 1A.1, 1A.3)

**Goal:** Define the atomic unit of rule evaluation and its explanation structure. These are the core data shapes that every constraint evaluation produces.

#### Step 2.1 — EvaluatedInput part def

**File:** `model/knowledge.sysml` → `Knowledge::LogicEngine`

```sysml
part def EvaluatedInput {
    doc /* A single input value used in a rule evaluation.
         * Records what data was used, where it came from,
         * and how it was derived — supporting the self-explanation
         * requirement for clinical governance and patient safety. */
    attribute inputName : String;
    attribute inputValue : String;     // serialised value
    attribute sourceType : DataSourceType;
    attribute sourceQuery : String;    // AQL, Temporal query, or API call
    attribute derivedAt : String;      // ISO datetime
}
```

**Acceptance:** Parses clean. Import of `Foundation::CommonTypes::*` must be added to LogicEngine (or already present via parent package import — check).

**Design note:** `inputValue` is typed as String (serialised) because SysML v2 does not support union types or `any`. At runtime, the TypeScript equivalent would be `unknown` or a branded type. The serialised form is adequate for the model's purpose (structural definition and traceability).

#### Step 2.2 — ExplanationTrace part def

**File:** `model/knowledge.sysml` → `Knowledge::LogicEngine`

```sysml
part def ExplanationTrace {
    doc /* A structured explanation of how a rule evaluation reached
         * its conclusion. Supports three audiences:
         * - Clinicians: why did this safety check pass or fail?
         * - Patients: why am I eligible or not?
         * - Auditors: trace from outcome through every decision.
         *
         * The trace is the clinical governance artefact that makes
         * the self-explaining requirement concrete. */
    attribute ruleExpression : String;     // the rule as evaluated
    attribute humanExplanation : String;   // plain-language explanation
    part evaluatedInputs : EvaluatedInput[0..*];
}
```

**Acceptance:** Parses clean. Containment (`part evaluatedInputs`) creates a structural nesting — verify that `[0..*]` multiplicity on a contained part works in Syside.

**Syntax risk:** The `part name : PartDef[0..*]` multiplicity syntax on contained parts has not been explicitly verified in the syntax reference. If Syside rejects it, fall back to `part evaluatedInputs : EvaluatedInput;` (unbounded by default) and document the finding.

#### Step 2.3 — EvaluationResult part def

**File:** `model/knowledge.sysml` → `Knowledge::LogicEngine`

```sysml
part def EvaluationResult {
    doc /* The atomic unit of knowledge evaluation. Every rule, at
         * every point in the system, produces one of these.
         *
         * EvaluationResults are persisted (CDR or audit log),
         * queryable, and presentable to clinicians, patients,
         * and auditors. They are the structured output of Tier 1
         * deterministic evaluation.
         *
         * The same structure is produced whether the evaluation is
         * invoked at point-of-care (single patient, single rule)
         * or in a governance audit (population, multiple rules). */
    attribute ruleName : String;
    attribute outcome : EvaluationOutcome;
    attribute evaluatedAt : String;          // ISO datetime
    attribute constraintRef : String;        // reference to ConstraintLibrary def
    attribute requirementRef : String;       // reference to satisfied requirement
    part explanation : ExplanationTrace;
    part subEvaluations : EvaluationResult[0..*];
}
```

**Acceptance:** Parses clean. Self-referential containment (`subEvaluations : EvaluationResult[0..*]`) is needed for compound constraints — verify Syside handles recursive part containment.

**Syntax risk:** Recursive containment may not be supported. If it fails, model `subEvaluations` as a reference (`ref part`) or omit and document as a known limitation for runtime implementation.

**Git checkpoint:** Commit after Stage 2. Message: `Add EvaluationResult, ExplanationTrace, EvaluatedInput to LogicEngine`

---

### Stage 3 — Track A: InputDerivation pattern (Steps 1A.2, 1A.4)

**Goal:** Formalise the bridge between authoritative data sources (CDR, Temporal, platform) and constraint inputs. This is the source-agnostic query pattern that the extended plan identified as shared between rule evaluation and self-knowledge.

#### Step 3.1 — InputDerivation part def

**File:** `model/knowledge.sysml` → `Knowledge::ClinicalDecisionSupport`

```sysml
part def InputDerivation {
    doc /* Defines how a single constraint input is derived from an
         * authoritative data source. The derivation pattern is
         * source-agnostic: the same structure describes AQL queries
         * against the CDR, Temporal workflow state queries, and
         * platform service API calls.
         *
         * Each input in a constraint def has a corresponding
         * InputDerivation that specifies the query, computation,
         * and fallback behaviour. This formalises what the
         * ConstraintLibrary doc blocks describe narratively. */
    attribute inputName : String;
    attribute sourceType : DataSourceType;
    attribute query : String;              // AQL, Temporal API call, etc.
    attribute computation : String;        // derivation logic (e.g. dateDiff)
    attribute fallbackOutcome : EvaluationOutcome;
    attribute fallbackReason : String;     // why indeterminate, if applicable
}
```

**Acceptance:** Parses clean. Imports from Foundation::CommonTypes resolve.

#### Step 3.2 — ConstraintEvaluationSpec part def

**File:** `model/knowledge.sysml` → `Knowledge::ClinicalDecisionSupport`

```sysml
part def ConstraintEvaluationSpec {
    doc /* Binds a constraint definition to its input derivations,
         * forming a complete evaluation specification. This is the
         * unit that the evaluation engine consumes: it knows which
         * constraint to evaluate and how to get every input.
         *
         * Separates "what the rule is" (ConstraintLibrary) from
         * "how to get the data for the rule" (ClinicalDecisionSupport). */
    attribute constraintName : String;     // matches ConstraintLibrary def name
    attribute requirementName : String;    // matches Enterprise::Regulation req
    attribute severity : Severity;
    part inputDerivations : InputDerivation[0..*];
}
```

**Acceptance:** Parses clean.

#### Step 3.3 — Map existing constraints to evaluation specs

**File:** `model/knowledge.sysml` → `Knowledge::ClinicalDecisionSupport`

Create one `ConstraintEvaluationSpec` part usage for each of the eight constraints in `ConstraintLibrary`. This is the most substantial modelling task in Stage 3.

Example for `BloodMonitoringIntervalConstraint`:

```sysml
part bloodMonitoringSpec : ConstraintEvaluationSpec {
    doc /* Evaluation specification for blood monitoring interval.
         * Two inputs derived from CDR and prescribing protocol. */
    attribute :>> constraintName = "BloodMonitoringIntervalConstraint";
    attribute :>> requirementName = "BloodMonitoringRequired";
    attribute :>> severity = Severity::warning;

    part :>> inputDerivations {
        part weeksSinceLastTestDerivation : InputDerivation {
            attribute :>> inputName = "weeksSinceLastTest";
            attribute :>> sourceType = DataSourceType::cdr;
            attribute :>> query = "SELECT MAX(r/data/events/time) FROM EHR e CONTAINS OBSERVATION r WHERE r/name/value='LabResult' AND e/ehr_id/value=:ehrId";
            attribute :>> computation = "dateDiff(now, resultDate, weeks)";
            attribute :>> fallbackOutcome = EvaluationOutcome::indeterminate;
            attribute :>> fallbackReason = "No LabResult exists for this patient";
        }

        part requiredIntervalDerivation : InputDerivation {
            attribute :>> inputName = "requiredIntervalWeeks";
            attribute :>> sourceType = DataSourceType::entity;
            attribute :>> query = "Prescription.monitoringInterval for active prescription";
            attribute :>> computation = "direct value lookup";
            attribute :>> fallbackOutcome = EvaluationOutcome::indeterminate;
            attribute :>> fallbackReason = "No active prescription found";
        }
    }
}
```

**Syntax risk — HIGH:** The nested attribute redefinition pattern (`:>>` inside contained parts inside a part usage) is complex. This has NOT been verified in the syntax reference. The modelling intent is clear but the exact syntax may need adjustment.

**Fallback approach if nested redefinition fails:** Define the eight evaluation specs as flat part usages with string-valued attribute lists rather than nested containment. Less elegant but achieves the same traceability purpose. Document the syntax finding.

**Full list of specs to create:**

| # | Spec name | Constraint | Inputs | Primary source |
|---|---|---|---|---|
| 1 | `consentSpec` | ConsentRecordedConstraint | consentRecorded | CDR |
| 2 | `informationSpec` | PatientInformationProvidedConstraint | informationProvided | CDR |
| 3 | `baselineBloodsSpec` | BaselineBloodsReviewedConstraint | allBaselineTestsResulted, allBaselineResultsReviewed | CDR + entity |
| 4 | `clinicalReviewSpec` | ClinicalReviewCompletedConstraint | reviewCompleted | CDR |
| 5 | `regimenProtocolSpec` | RegimenWithinProtocolConstraint | medicationApproved, routeApproved, doseWithinRange | CDR + DecisionModels |
| 6 | `bloodMonitoringSpec` | BloodMonitoringIntervalConstraint | weeksSinceLastTest, requiredIntervalWeeks | CDR + entity |
| 7 | `doseAdjustmentSpec` | DoseAdjustmentReviewedConstraint | clinicalReviewCompleted, currentResultsReviewed | CDR |
| 8 | `sharedCareSpec` | SharedCareAcceptedConstraint | sharedCareProtocolSent, gpPracticeAccepted | CDR + entity |

**Implementation approach:** Start with spec #6 (bloodMonitoringSpec, shown above) as the syntax test case. If the nested pattern works, complete all eight. If it fails, switch to the flat fallback pattern and complete all eight in that form.

**Git checkpoint:** Commit after Stage 3. Message: `Add InputDerivation pattern and constraint evaluation specs to CDS`

---

### Stage 4 — Track B: Deficit and SystemStateAssessment (Steps 1B.4, 1B.5)

**Goal:** Define the composite structures for system self-knowledge — the gap analysis output and the whole-system assessment.

#### Step 4.1 — DeficitDomain enum

**File:** `model/foundation.sysml` → `Foundation::CommonTypes`

```sysml
enum def DeficitDomain {
    doc /* Domain classification for a deficit. */
    clinical;
    operational;
    infrastructure;
    governance;
}
```

#### Step 4.2 — RemediationCategory enum

**File:** `model/foundation.sysml` → `Foundation::CommonTypes`

```sysml
enum def RemediationCategory {
    doc /* How a deficit can be addressed. Defines the boundary
         * between deterministic system action and advisory output.
         * automatic: the pathway model defines the next step and
         *   the system can trigger it.
         * recommended: a specific action is identified but requires
         *   human decision.
         * advisory: the deficit is systemic or compound and the
         *   system surfaces it with supporting data. */
    automatic;
    recommended;
    advisory;
}
```

#### Step 4.3 — Deficit part def

**File:** `model/knowledge.sysml` → `Knowledge::LogicEngine`

```sysml
part def Deficit {
    doc /* A structured record of a gap between the system's actual
         * operational state and its goal state. Generalises the
         * Phase D governance audit pattern from a single rule to
         * any operational dimension.
         *
         * Each deficit references the goal it falls short of
         * (requirement, constraint, or outcome definition), the
         * actual state found, and the expected state. Supporting
         * EvaluationResult records provide the evidence chain.
         *
         * Deficits are computed, not stored — they are the output
         * of comparing Layer 2 (operational state) against Layer 3
         * (goal state) in the self-knowledge architecture. */
    attribute deficitDomain : DeficitDomain;
    attribute scope : AssessmentScope;
    attribute description : String;
    attribute goalReference : String;
    attribute actualState : String;
    attribute expectedState : String;
    attribute severity : Severity;
    attribute detectedAt : String;          // ISO datetime
    attribute remediationCategory : RemediationCategory;
    attribute remediationDescription : String;
    part supportingEvaluations : EvaluationResult[0..*];
}
```

**Acceptance:** Parses clean. Cross-package reference to `EvaluationResult` requires import of `Knowledge::LogicEngine::*` within the same file (sibling package import — verified in syntax reference v3.2).

#### Step 4.4 — ServiceHealthStatus enum

**File:** `model/foundation.sysml` → `Foundation::CommonTypes`

```sysml
enum def ServiceHealthStatus {
    doc /* Health status of an infrastructure service. */
    healthy;
    degraded;
    unreachable;
}
```

#### Step 4.5 — SystemStateAssessment part def

**File:** `model/knowledge.sysml` → `Knowledge::LogicEngine`

```sysml
part def SystemStateAssessment {
    doc /* The composite output of the self-knowledge infrastructure.
         * Aggregates across all five layers of self-knowledge to
         * produce a whole-system picture.
         *
         * Not a new data store — computed on demand by querying
         * existing authoritative sources (Temporal, CDR, platform
         * services) and running existing evaluation logic.
         *
         * Can be scoped: a single patient, a clinical pathway,
         * a domain, or the entire system. Scheduled Temporal cron
         * workflows produce periodic assessments; on-demand requests
         * produce point-in-time assessments.
         *
         * This is the primary artefact of the self-describing
         * property: the system's own structured report on itself. */
    attribute assessmentId : String;
    attribute assessedAt : String;          // ISO datetime
    attribute scope : AssessmentScope;
    attribute scopeFilter : String;
    attribute modelVersion : String;

    // Layer 1 — Structural summary
    attribute packagesCount : Integer;
    attribute pathwaysCount : Integer;
    attribute constraintsCount : Integer;
    attribute requirementsCount : Integer;
    attribute entityLifecyclesCount : Integer;

    // Layer 3 vs Layer 2 — Goal compliance summary
    attribute totalGoals : Integer;
    attribute goalsMet : Integer;
    attribute goalsUnmet : Integer;
    attribute goalsIndeterminate : Integer;

    // Layer 4 — Deficits
    part deficits : Deficit[0..*];

    // Layer 5 — Evaluation evidence
    part evaluationResults : EvaluationResult[0..*];
}
```

**Acceptance:** Parses clean. This is the largest single part def in the session — verify all attributes resolve.

**Design note:** Layer 2 (operational summary) and Layer 5 (remediation recommendations) are represented as attributes and contained parts within SystemStateAssessment rather than as separate part defs. If the structure becomes unwieldy, extract OperationalSummary and RemediationRecommendation as separate part defs in a later stage. Keep it simple now.

**Git checkpoint:** Commit after Stage 4. Message: `Add Deficit, SystemStateAssessment, and supporting enums for self-knowledge architecture`

---

### Stage 5 — Track A: Evaluation invocation pattern (Step 1A.5) + Track B: System Model Manifest and assessment patterns (Steps 1B.1, 1B.2, 1B.3, 1B.6, 1B.7)

**Goal:** Capture the design decisions that connect the structural definitions (Stages 1–4) to the runtime architecture. This stage produces an architecture decision document rather than SysML code — the decisions inform Phase 2 (LogicEngine elaboration) and Phase 5 (generator exploration).

#### Step 5.1 — Architecture decision document

**File:** `documentation/architecture/gsl-architecture-decision-knowledge-evaluation.md`

Document the following decisions with rationale:

**5.1.1 — Evaluation invocation pattern**

How pathways call evaluations at runtime. The pathway action flow contains metadata annotations (`@LogicRule`, `@SafetyConstraint`) that name evaluations. At runtime:

- The generated Temporal activity for an annotated step calls the evaluation engine
- The evaluation engine looks up the `ConstraintEvaluationSpec` by constraint name
- It runs the `InputDerivation` queries against the appropriate data sources
- It evaluates the constraint with the derived inputs
- It produces an `EvaluationResult` with a full `ExplanationTrace`
- The result is returned to the activity, which proceeds or blocks based on the outcome
- The result is also committed to the CDR (or audit log) for governance traceability

**5.1.2 — System Model Manifest concept**

What the running system needs to know about its own structure:

- Package hierarchy (names, descriptions, relationships)
- Pathway inventory (which pathways exist, their steps, decision points)
- Constraint inventory (which constraints exist, what requirements they satisfy)
- Entity lifecycle inventory (which entities have state machines, their states and transitions)
- Integration inventory (which external services are referenced)
- Metadata annotations inventory (which elements carry which metadata)

Generation approach: a new generator (regex-based initially, Syside Automator later) reads the `.sysml` model files and produces a JSON manifest. The manifest is a build artefact, regenerated on model change. The running system reads it as a static configuration file.

The existing `gen_package_hierarchy.py` is a partial prototype of this — it already extracts structural information from the model. The manifest generator extends this with deeper element extraction.

**5.1.3 — Operational State Query pattern**

How the system queries its own operational state (Layer 2). Uses the same `InputDerivation` structure from Track A, but scoped to operational rather than clinical queries:

- Temporal queries: active workflows, blocked workflows, failed workflows, workflow step distribution
- CDR queries: composition counts by archetype, overdue monitoring items, entity state distribution
- Platform queries: service health checks, infrastructure status

Each operational query is an `InputDerivation` with `sourceType` identifying the authoritative source.

**5.1.4 — Goal State Projection pattern**

How requirements, constraints, and outcome definitions are projected into a comparable shape (Layer 3). Goals derive from three model sources:

- Requirements in `Enterprise::Regulation` → expected compliance state
- Constraints in `Knowledge::ConstraintLibrary` → expected evaluation outcomes
- Outcome definitions in `Knowledge::OutcomeFramework` → expected clinical targets

Each goal is expressed as an expected value or condition. The gap analysis (Layer 4) compares the projected goal state against the queried operational state, producing `Deficit` records for any mismatches.

**5.1.5 — Remediation classification**

How deficits map to actions (Layer 5):

- **Automatic:** The deficit maps to a single, pathway-defined next step. The system can trigger it (e.g., schedule overdue blood test). Tier 1 deterministic.
- **Recommended:** A specific action is identifiable but requires human decision (e.g., clinical review needed). System surfaces the recommendation. Tier 1 deterministic.
- **Advisory:** The deficit is systemic or compound. No single action resolves it. System surfaces the deficit with supporting data for human analysis. Tier 2/3 territory — deferred to Prolog exploration and later phases.

**5.1.6 — Assessment invocation patterns**

Three triggers for producing a `SystemStateAssessment`:

- **On-demand:** Clinician or administrator requests a point-in-time assessment via a platform endpoint. Scoped to patient, pathway, domain, or full system.
- **Scheduled:** Temporal cron workflow runs periodic assessments (e.g., daily clinical governance audit, weekly operational health check). Produces and stores assessment records.
- **Triggered:** A critical deficit detected during point-of-care evaluation triggers an immediate scoped assessment to determine whether the deficit is isolated or systemic.

**Acceptance:** Document written, reviewed, and committed.

#### Step 5.2 — LogicEngine use case defs

**File:** `model/knowledge.sysml` → `Knowledge::LogicEngine`

Add use case defs that make the evaluation and self-knowledge capabilities explicit:

```sysml
use case def EvaluateConstraint {
    doc /* Evaluate a single constraint for a specific patient
         * or context. Derives inputs from authoritative sources,
         * evaluates the constraint expression, and produces a
         * structured EvaluationResult with explanation trace. */
}

use case def PerformGapAnalysis {
    doc /* Compare operational state against goal state for a
         * defined scope (patient, pathway, domain, system).
         * Produces a set of Deficit records identifying where
         * actual state falls short of expected state. */
}

use case def ProduceSystemStateAssessment {
    doc /* Aggregate structural self-knowledge, operational state,
         * goal compliance, deficits, and remediation recommendations
         * into a composite SystemStateAssessment. The primary
         * output of the self-describing property. */
}

use case def ExplainEvaluationResult {
    doc /* Given an EvaluationResult, produce a human-readable
         * explanation suitable for the requesting audience
         * (clinician, patient, auditor). */
}
```

**Acceptance:** Parses clean.

**Git checkpoint:** Commit after Stage 5. Message: `Add evaluation architecture decision document and LogicEngine use cases`

---

### Stage 6 — Verification, documentation, and session close

#### Step 6.1 — Full model verification

Open the entire workspace in Syside and verify clean parse across all files. The changes touch `foundation.sysml` and `knowledge.sysml` — both of which are imported by other files. Check for:

- Import resolution (especially `Knowledge::LogicEngine::*` from within `Knowledge::ClinicalDecisionSupport`)
- No naming conflicts with new enums and part defs
- Hover tooltips show doc strings correctly

#### Step 6.2 — Run `gsl save`

Regenerate all hierarchy outputs. The new LogicEngine and ClinicalDecisionSupport elements should appear in the generated views with correct element counts.

#### Step 6.3 — Syntax reference update

If any new syntax patterns were verified or traps discovered during the session, produce `gsl-sysml-v2-syntax-reference-v3.5-2026-03-08.md` with:

- Multiplicity on contained parts (`part name : PartDef[0..*]`)
- Recursive self-referential containment (`part subX : XDef[0..*]` within `XDef`)
- Nested attribute redefinition (`:>>` inside contained parts) — if tested
- Any new reserved word discoveries

If no new findings, no new version needed.

#### Step 6.4 — Session report

Write `gsl-session-report-2026-03-08-s8.md` covering:

- What was completed (which stages, which steps)
- Syntax findings (what worked, what failed, workarounds applied)
- Design decisions made
- Repository state after session
- Recommended next steps (Phase 2 — LogicEngine elaboration)

#### Step 6.5 — Git final commit

Stage and commit all remaining changes. Message: `Complete Knowledge Layer Phase 1: evaluation and self-knowledge architecture`

---

## 4. Execution Order and Dependencies

```
Pre-flight checks (Stage 0)
    │
    ▼
Stage 1: Foundation types (enums)           ← no dependencies
    │
    ▼
Stage 2: EvaluationResult + ExplanationTrace ← depends on Stage 1 enums
    │
    ├──▶ Stage 3: InputDerivation + specs    ← depends on Stage 1 enums
    │                                           (independent of Stage 2
    │                                            for syntax testing;
    │                                            conceptually linked)
    ▼
Stage 4: Deficit + SystemStateAssessment     ← depends on Stages 1 + 2
    │
    ▼
Stage 5: Architecture decisions + use cases  ← depends on Stages 1–4
    │                                           (documents the designs)
    ▼
Stage 6: Verification + documentation        ← depends on all above
```

Stages 2 and 3 can be worked in parallel or in either order. Stage 3 has the highest syntax risk (nested `:>>` redefinition) so could be started first to identify any blockers early.

---

## 5. Identified Risks

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Multiplicity on contained parts (`[0..*]`) not supported | Medium | Medium | Fall back to unbounded containment (remove multiplicity) |
| Recursive self-referential containment rejected | Medium | High | Use `ref part` instead, or model as flat with string references |
| Nested `:>>` redefinition in contained parts fails | High | High | Fall back to flat part usages with string attributes (Stage 3 fallback) |
| `entity` is a reserved word or shadows KerML | Low | Low | Rename to `entityState` in DataSourceType enum |
| Import resolution across sibling packages within `Knowledge` fails | Low | High | Already verified (syntax reference v3.2) but reconfirm |

---

## 6. Success Criteria (Phase 1)

Mapped to the parent plan's success criteria:

| Parent criterion | Phase 1 contribution |
|---|---|
| 1. Every rule evaluation produces a structured, self-explaining result | EvaluationResult, ExplanationTrace, EvaluatedInput defined as part defs |
| 2. Evaluation architecture connects CDR data to constraint evaluation via source-agnostic input derivation | InputDerivation part def, ConstraintEvaluationSpec, eight constraint-to-spec mappings |
| 3. Five layers of self-knowledge architecturally defined | Deficit, SystemStateAssessment part defs; five-layer architecture documented in decision document |
| 4. System Model Manifest concept specified | Section 5.1.2 of architecture decision document |
| 8. Generator pathway exists | Decision document describes generation approach; existing `gen_package_hierarchy.py` identified as partial prototype |
| 9. Gap analysis pattern defined as generalisation of Phase D | PerformGapAnalysis use case; Deficit structure; decision document section 5.1.4 |

Criteria 5, 6, 7 are addressed in Phases 2–4 (not Phase 1).

---

## 7. Estimated Effort

| Stage | Estimated time | Notes |
|---|---|---|
| Pre-flight | 5–10 min | Ella: Syside checks |
| Stage 1 | 15–20 min | Four small enums, straightforward |
| Stage 2 | 20–30 min | Three part defs, syntax testing for multiplicity and recursion |
| Stage 3 | 30–45 min | High syntax risk; eight specs with nested derivations |
| Stage 4 | 20–30 min | Two major part defs + two small enums |
| Stage 5 | 30–40 min | Architecture decision document (text, not SysML) + four use case defs |
| Stage 6 | 15–20 min | Verification, syntax reference update, session report |
| **Total** | **~2.5–3 hours** | Single session, or split across two if syntax issues require iteration |

---

*Plan prepared 8 March 2026 (Session 8). Implements Phase 1 of the Knowledge Layer Elaboration extended plan.*
