# Knowledge Layer Elaboration — Phase 2 Implementation Plan

**Date:** 9 March 2026 (Session 9)
**Context:** Phase 2 of the Knowledge Layer Elaboration, as defined in the extended planning document. Phase 1 (Session 8) established the evaluation and self-knowledge architecture: foundation enums, EvaluationResult/ExplanationTrace/EvaluatedInput in LogicEngine, InputDerivation/ConstraintEvaluationSpec in ClinicalDecisionSupport, Deficit/SystemStateAssessment in LogicEngine, four use cases, and the architecture decision document covering evaluation invocation, System Model Manifest, operational state queries, goal projection, remediation classification, and assessment invocation.

**Parent plan:** `documentation/plans/gsl-plan-knowledge-layer-elaboration-2026-03-08-extended.md`
**Phase 1 plan:** `documentation/plans/gsl-plan-knowledge-layer-phase1-implementation-2026-03-08.md`
**Syntax reference:** `documentation/reference/gsl-sysml-v2-syntax-reference-v3.5-2026-03-08.md`
**Architecture decisions:** `documentation/architecture/gsl-architecture-decision-knowledge-evaluation.md`
**Validated patterns:** `documentation/architecture/gsl-validated-architectural-patterns.md`

---

## 1. Scope and Boundaries

### What Phase 2 delivers

Phase 2 fleshes out the LogicEngine package with the component-level structures that make the Phase 1 architecture operational. Phase 1 defined the *data shapes* (EvaluationResult, Deficit, SystemStateAssessment) and the *design decisions* (how evaluations are invoked, how state is queried, how deficits are classified). Phase 2 defines the *components* that produce those data shapes — the evaluator, the aggregator, the gap analyser, the self-explanation API — and models the three-tier reasoning stack as concrete structural elements.

Specifically:

- The Tier 1 evaluator as a structural component model with defined interfaces and internal structure
- The operational state aggregator component — the thing that queries Temporal, CDR, and platform services to produce the operational summary for Layer 2
- The gap analyser component — the thing that compares Layer 2 against Layer 3 and emits Deficit records
- The Tier 2 evaluator interface (Prolog exploration boundary) with compound deficit reasoning
- The Tier 3 advisory interface (ML/LLM boundary, interface only)
- The self-explanation API — how the system exposes individual EvaluationResults and composite SystemStateAssessments to consumers (clinician UI, patient portal, governance dashboards, audit endpoints)
- Updated LogicEngine doc block and use case elaborations reflecting the component model

### What Phase 2 does NOT deliver

- Runtime code or generators (Phase 5)
- Decision table patterns or specific decision table content (Phase 3)
- Outcome measurement definitions (Phase 4)
- Actual Prolog or DMN implementation — only the interface boundaries
- Changes to ConstraintLibrary or ClinicalDecisionSupport (those were elaborated in Phase 1)
- Changes to Foundation::CommonTypes (Phase 1 established all needed enums; new enums only if component modelling reveals gaps)

### Relationship to Phase 1

Phase 2 builds directly on Phase 1 structures:

| Phase 1 deliverable | Phase 2 usage |
|---|---|
| EvaluationResult, ExplanationTrace, EvaluatedInput | Output types of the Tier 1 evaluator component |
| InputDerivation, ConstraintEvaluationSpec | Input specifications consumed by the Tier 1 evaluator |
| Deficit | Output type of the gap analyser component |
| SystemStateAssessment | Output type of the assessment orchestrator (composed from all component outputs) |
| EvaluateConstraint use case | Elaborated with component allocation |
| PerformGapAnalysis use case | Elaborated with component allocation |
| ProduceSystemStateAssessment use case | Elaborated with component allocation |
| ExplainEvaluationResult use case | Elaborated with self-explanation API design |
| Architecture decision document | Design rationale informing component boundaries |

### Files affected

| File | Expected changes |
|---|---|
| `model/knowledge.sysml` | LogicEngine package: new part defs (components), elaborated use cases, updated doc block |
| `model/foundation.sysml` | CommonTypes: new enums only if component modelling reveals gaps (unlikely — Phase 1 was thorough) |
| `documentation/reference/gsl-sysml-v2-syntax-reference-v3.6-*.md` | Updated if new syntax patterns are verified or traps discovered |
| `documentation/session-reports/gsl-session-report-2026-03-09-s9.md` | Session report |

---

## 2. Pre-flight Checks

| Check | Action | Status |
|---|---|---|
| 2.1 | Verify Phase 1 model changes parse clean in Syside (seven new enums in CommonTypes, all LogicEngine and CDS additions) | ☐ Ella to confirm |
| 2.2 | Verify pending git commits from Session 8 are committed (documentation restructuring, architecture decision document, session report, plan) | ☐ Ella to confirm |
| 2.3 | Run `gsl save` to confirm generated hierarchy reflects Phase 1 element counts | ☐ Ella to run |
| 2.4 | Confirm syntax reference v3.5 is current and accessible | ☐ Verified — uploaded to this session |
| 2.5 | Open `knowledge.sysml` in Syside to confirm clean parse before modifications | ☐ Ella to confirm |

---

## 3. Design Approach: Components as Part Defs

### Why model components in SysML?

The Phase 1 architecture decision document describes runtime components (evaluation engine, operational state aggregator, gap analyser) in prose. Phase 2 makes these concrete as SysML `part def` elements within LogicEngine. This serves three purposes:

1. **Structural traceability:** Use cases can be allocated to components. The model answers "which component implements EvaluateConstraint?" formally, not just narratively.
2. **Interface clarity:** Each component's inputs, outputs, and dependencies are explicit typed attributes. The model defines what each component needs and what it produces.
3. **Generation pathway:** Component part defs with typed interfaces are the natural input for a future TypeScript interface/class generator. The component model becomes the specification from which runtime modules are generated.

### Component modelling pattern

Each component is a `part def` with:
- A doc block describing its purpose, responsibilities, and tier allocation
- Input attributes or references describing what it consumes
- Output attributes or references describing what it produces
- Contained parts where internal structure is relevant (e.g. the evaluator contains an explanation builder)

This is the same `part def` pattern used throughout the model. No new SysML constructs are needed.

### What "component" means at this stage

These are design-time structural definitions, not runtime deployment units. Each `part def` represents a logical component with a defined responsibility boundary. At runtime, each will become a TypeScript module or class. The model does not prescribe the deployment topology (monolith vs. microservice vs. Temporal activity); that is an execution-layer concern.

---

## 4. Implementation Steps

### Stage 1 — Tier 1 Evaluator Component

**Goal:** Model the deterministic constraint evaluator — the core runtime component that consumes ConstraintEvaluationSpecs, derives inputs from authoritative sources, evaluates constraint expressions, and produces EvaluationResults with full explanation traces.

#### Step 1.1 — ConstraintEvaluator part def

**File:** `model/knowledge.sysml` → `Knowledge::LogicEngine`

```sysml
part def ConstraintEvaluator {
    doc /* The Tier 1 deterministic constraint evaluation component.
         * Consumes ConstraintEvaluationSpecs from
         * ClinicalDecisionSupport, derives inputs from authoritative
         * sources (CDR via AQL, Temporal, platform services), evaluates
         * constraint boolean expressions, and produces structured
         * EvaluationResults with full ExplanationTraces.
         *
         * This is a generic runtime component: it does not contain
         * any specific clinical logic. All rule knowledge comes from
         * the ConstraintLibrary (what the rule is) and the
         * ConstraintEvaluationSpec (how to get the data). The
         * evaluator is the execution engine that connects the two.
         *
         * Invocation: pathway action steps annotated with @LogicRule
         * or @SafetyConstraint generate Temporal activities that call
         * this component. See architecture decision document,
         * Section 1 (Evaluation Invocation Pattern).
         *
         * Scope: evaluates one constraint for one context (typically
         * one patient). Population-level evaluation (governance audit)
         * wraps this in a loop over a patient cohort — same component,
         * iterated. */
    attribute evaluatorId : String;

    // --- Capabilities ---
    part inputResolver : InputResolver;
    part expressionEvaluator : ExpressionEvaluator;
    part explanationBuilder : ExplanationBuilder;
}
```

**Acceptance:** Parses clean in Syside. Contained parts reference part defs defined in Steps 1.2–1.4.

#### Step 1.2 — InputResolver part def

**File:** `model/knowledge.sysml` → `Knowledge::LogicEngine`

```sysml
part def InputResolver {
    doc /* Resolves constraint inputs from authoritative data sources.
         * For each InputDerivation in a ConstraintEvaluationSpec,
         * the resolver executes the specified query against the
         * appropriate source (CDR, Temporal, platform service),
         * applies the computation to derive a typed value, and
         * handles fallback if the query fails or returns no data.
         *
         * Source-agnostic: the resolver dispatches based on the
         * InputDerivation's sourceType attribute. The query format
         * varies by source (AQL for CDR, API call for Temporal,
         * HTTP for platform services) but the resolution pattern
         * is identical.
         *
         * Produces EvaluatedInput records as output — these feed
         * both the expression evaluator (for the constraint check)
         * and the explanation builder (for the audit trace). */
    attribute resolverId : String;
}
```

#### Step 1.3 — ExpressionEvaluator part def

**File:** `model/knowledge.sysml` → `Knowledge::LogicEngine`

```sysml
part def ExpressionEvaluator {
    doc /* Evaluates a constraint's boolean expression given resolved
         * input values. For Tier 1, this is straightforward boolean
         * evaluation: the constraint def's expression is evaluated
         * with the derived input values substituted.
         *
         * Returns an EvaluationOutcome (pass, fail, indeterminate).
         * Indeterminate arises when one or more inputs could not be
         * resolved and the fallback outcome propagates.
         *
         * In a future generated implementation, this component is
         * replaced by generated TypeScript functions — one per
         * constraint def. The generated function takes typed inputs
         * and returns the boolean result directly, with the
         * expression evaluation compiled rather than interpreted. */
    attribute evaluatorId : String;
}
```

#### Step 1.4 — ExplanationBuilder part def

**File:** `model/knowledge.sysml` → `Knowledge::LogicEngine`

```sysml
part def ExplanationBuilder {
    doc /* Assembles ExplanationTrace records from the evaluation
         * context: the resolved inputs (EvaluatedInput records),
         * the constraint expression as evaluated, and a
         * human-readable explanation of the outcome.
         *
         * Supports three audiences:
         * - Clinicians: technical but accessible explanation of
         *   why a safety check passed or failed, with data values
         * - Patients: plain-language explanation suitable for
         *   self-management interfaces
         * - Auditors: full formal trace with data provenance
         *
         * The audience parameter determines explanation depth and
         * language register. All three are derived from the same
         * underlying EvaluatedInput and expression data — the
         * difference is presentation, not content. */
    attribute builderId : String;
}
```

**Git checkpoint:** Commit after Stage 1. Message: `Add Tier 1 ConstraintEvaluator component model to LogicEngine`

---

### Stage 2 — Operational State Aggregator

**Goal:** Model the component that queries the system's own operational state across all authoritative sources, producing the Layer 2 data for SystemStateAssessment.

#### Step 2.1 — OperationalStateAggregator part def

**File:** `model/knowledge.sysml` → `Knowledge::LogicEngine`

```sysml
part def OperationalStateAggregator {
    doc /* Queries the system's operational state across all
         * authoritative data sources: Temporal (process state),
         * CDR (clinical data state), entity lifecycle state, and
         * platform services (infrastructure health).
         *
         * Uses the same source-agnostic InputDerivation pattern
         * as the ConstraintEvaluator, but scoped to operational
         * rather than clinical queries. Each operational query
         * is an InputDerivation with the appropriate sourceType.
         *
         * Produces a structured OperationalSnapshot — the Layer 2
         * content of a SystemStateAssessment.
         *
         * Query categories:
         * - Process state (Temporal): active, blocked, failed
         *   workflows; workflow step distribution; SLA adherence
         * - Clinical data state (CDR via AQL): composition counts
         *   by archetype, overdue monitoring items, recording
         *   completeness
         * - Entity lifecycle state: counts by entity type and
         *   state (e.g. 42 active prescriptions, 7 pending
         *   referrals)
         * - Infrastructure health: CDR reachable, Temporal workers
         *   running, external integrations responding
         *
         * See architecture decision document, Section 3
         * (Operational State Query Pattern). */
    attribute aggregatorId : String;
    part processStateQuery : OperationalQuery;
    part clinicalDataQuery : OperationalQuery;
    part entityStateQuery : OperationalQuery;
    part infrastructureQuery : OperationalQuery;
}
```

#### Step 2.2 — OperationalQuery part def

**File:** `model/knowledge.sysml` → `Knowledge::LogicEngine`

```sysml
part def OperationalQuery {
    doc /* A single operational state query against an authoritative
         * source. Structurally identical to InputDerivation but
         * scoped to operational rather than clinical data.
         *
         * The query returns a structured result (count, list, or
         * status) rather than a single typed value. This is a
         * wider interface than InputDerivation, which derives a
         * single constraint input.
         *
         * At runtime, implemented as a TypeScript function that
         * calls the appropriate API (Temporal client, EHRbase
         * REST/AQL, platform health endpoint). */
    attribute queryName : String;
    attribute sourceType : DataSourceType;
    attribute query : String;
    attribute description : String;
}
```

#### Step 2.3 — OperationalSnapshot part def

**File:** `model/knowledge.sysml` → `Knowledge::LogicEngine`

```sysml
part def OperationalSnapshot {
    doc /* A point-in-time capture of the system's operational
         * state, produced by the OperationalStateAggregator.
         * This is the Layer 2 content that feeds into gap
         * analysis and the SystemStateAssessment.
         *
         * Not persisted as a separate data store — computed
         * on demand. The snapshot captures the query results
         * at a specific moment for comparison against goals. */
    attribute capturedAt : String;          // ISO datetime
    attribute scope : AssessmentScope;

    // Process state summary
    attribute activeWorkflows : Integer;
    attribute blockedWorkflows : Integer;
    attribute failedWorkflows : Integer;
    attribute workflowsPastSla : Integer;

    // Clinical data summary
    attribute overdueMonitoringItems : Integer;
    attribute totalActivePatients : Integer;

    // Infrastructure health
    attribute cdrStatus : ServiceHealthStatus;
    attribute temporalStatus : ServiceHealthStatus;
    attribute externalIntegrationsHealthy : Integer;
    attribute externalIntegrationsTotal : Integer;
}
```

**Syntax risk — LOW:** This stage uses only patterns validated in Phase 1: part defs with scalar attributes, contained parts with typed references, cross-package enum imports. No new syntax patterns needed.

**Git checkpoint:** Commit after Stage 2. Message: `Add OperationalStateAggregator and OperationalSnapshot to LogicEngine`

---

### Stage 3 — Gap Analyser

**Goal:** Model the component that compares operational state (Layer 2) against goal state (Layer 3) and produces Deficit records (Layer 4). This is the generalisation of the Phase D governance audit pattern.

#### Step 3.1 — GapAnalyser part def

**File:** `model/knowledge.sysml` → `Knowledge::LogicEngine`

```sysml
part def GapAnalyser {
    doc /* Compares the system's operational state (Layer 2,
         * OperationalSnapshot) against its goal state (Layer 3,
         * projected from requirements, constraints, and outcome
         * definitions) and produces Deficit records for every
         * unmet goal.
         *
         * This is the direct generalisation of the Phase D
         * governance audit: Phase D compared expected compositions
         * against actual compositions for a single rule. The gap
         * analyser applies the same pattern across all defined
         * goals and all operational dimensions.
         *
         * Goal sources:
         * - Requirements (Enterprise::Regulation) → expected
         *   compliance conditions
         * - Constraints (Knowledge::ConstraintLibrary) → expected
         *   evaluation pass outcomes for all active patients
         * - Outcome definitions (Knowledge::OutcomeFramework) →
         *   expected clinical target achievement
         *
         * Each goal is projected as an expected condition. The
         * analyser evaluates the condition against operational
         * data and emits a Deficit if the condition is not met.
         *
         * See architecture decision document, Section 4
         * (Goal State Projection). */
    attribute analyserId : String;
    part goalProjector : GoalProjector;
}
```

#### Step 3.2 — GoalProjector part def

**File:** `model/knowledge.sysml` → `Knowledge::LogicEngine`

```sysml
part def GoalProjector {
    doc /* Projects goals from model sources (requirements,
         * constraints, outcome definitions) into a comparable
         * shape against operational state.
         *
         * Each goal is expressed as a GoalProjection: an expected
         * condition that can be evaluated against actual data.
         * The projection mechanism varies by source:
         *
         * - Requirement goals: "every active patient has a
         *   LabResult within N weeks" → AQL query counting
         *   patients without recent LabResults
         * - Constraint goals: "BloodMonitoringIntervalConstraint
         *   evaluates to pass for every active patient" →
         *   batch constraint evaluation across cohort
         * - Outcome goals: "hormone levels within therapeutic
         *   range at 6-month measurement point" → AQL query
         *   against outcome compositions
         *
         * The projector does not evaluate goals — it transforms
         * them into a shape the gap analyser can compare against
         * operational data. */
    attribute projectorId : String;
}
```

#### Step 3.3 — GoalProjection part def

**File:** `model/knowledge.sysml` → `Knowledge::LogicEngine`

```sysml
part def GoalProjection {
    doc /* A single goal projected from the model into a shape
         * comparable against operational state. The unit of
         * comparison for gap analysis.
         *
         * Each projection names the goal source (requirement,
         * constraint, or outcome definition), the expected
         * condition, and the query needed to check actual state.
         * The gap analyser evaluates the query and compares
         * the result against the expected condition. */
    attribute goalName : String;
    attribute goalSource : String;         // requirement, constraint, or outcome def name
    attribute expectedCondition : String;  // human-readable expected state
    attribute evaluationQuery : String;    // query to check actual state
    attribute scope : AssessmentScope;
}
```

**Git checkpoint:** Commit after Stage 3. Message: `Add GapAnalyser, GoalProjector, and GoalProjection to LogicEngine`

---

### Stage 4 — Tier 2 and Tier 3 Interfaces

**Goal:** Model the boundaries between the three reasoning tiers. Tier 2 (Prolog/inference) and Tier 3 (ML/LLM advisory) are interfaces only — the architectural space is reserved and the contract is defined, but no implementation detail is modelled.

#### Step 4.1 — InferenceEvaluator part def (Tier 2)

**File:** `model/knowledge.sysml` → `Knowledge::LogicEngine`

```sysml
part def InferenceEvaluator {
    doc /* Tier 2 reasoning interface: inference chains,
         * contraindication cascades, compound deficit reasoning,
         * and "why" queries.
         *
         * Where Tier 1 (ConstraintEvaluator) evaluates single
         * boolean constraints, Tier 2 reasons about relationships
         * between multiple constraints, deficits, and available
         * actions. This is the architectural space for Prolog-style
         * logic programming.
         *
         * Key capabilities (interface only, not yet implemented):
         *
         * - Contraindication cascade: given a proposed medication,
         *   trace through all interaction rules, existing
         *   medications, and patient conditions to produce a
         *   compound safety assessment with full inference chain
         * - Compound deficit reasoning: given multiple Deficit
         *   records, identify interactions (e.g. overdue bloods
         *   AND missed appointment AND expiring prescription),
         *   reason about priority and sequencing, and produce
         *   a compound remediation recommendation
         * - "Why" queries: given an EvaluationResult, trace
         *   backward through the inference chain to explain
         *   not just what the result is but why the inputs
         *   have their current values
         *
         * Runtime target: Tau Prolog (pure JS, embeddable in
         * Temporal activities) or SWI-Prolog WASM. Decision
         * deferred until clinical rules demand inference beyond
         * Tier 1 boolean constraints.
         *
         * Produces EvaluationResults with the same structure as
         * Tier 1, but subEvaluations may form deeper trees
         * reflecting the inference chain. */
    attribute evaluatorId : String;
    attribute reasoningEngine : String;    // e.g. "tau-prolog", "swi-prolog-wasm"
}
```

#### Step 4.2 — AdvisoryInterface part def (Tier 3)

**File:** `model/knowledge.sysml` → `Knowledge::LogicEngine`

```sysml
part def AdvisoryInterface {
    doc /* Tier 3 advisory interface: ML/LLM-augmented intelligence.
         * Powerful but probabilistic, always advisory rather than
         * authoritative. Cannot override Tier 1 or Tier 2 logic.
         *
         * Capabilities (interface boundary only):
         *
         * - Pattern recognition across patient cohorts
         * - Natural language processing of unstructured clinical
         *   notes
         * - Predictive analytics (trajectory-based dose adjustment
         *   suggestions, capacity forecasting)
         * - Literature synthesis for clinical guideline updates
         * - Advisory remediation for systemic deficits where no
         *   single deterministic action resolves the gap
         *
         * Architectural constraints:
         * - All Tier 3 outputs are labelled as advisory
         * - Tier 3 cannot modify pathway state or trigger
         *   automatic actions
         * - Tier 3 outputs are presented alongside (never instead
         *   of) Tier 1/2 deterministic results
         * - Clinical validation is required before any Tier 3
         *   capability is surfaced to clinicians or patients
         *
         * Implementation deferred. The interface exists to ensure
         * the architecture accommodates ML/LLM capabilities
         * without compromising the deterministic foundation. */
    attribute interfaceId : String;
    attribute modelType : String;         // e.g. "llm", "ml-classifier", "predictive"
    attribute confidenceThreshold : Real; // minimum confidence for surfacing
}
```

**Git checkpoint:** Commit after Stage 4. Message: `Add Tier 2 InferenceEvaluator and Tier 3 AdvisoryInterface to LogicEngine`

---

### Stage 5 — Self-Explanation API and Assessment Orchestrator

**Goal:** Model how the system exposes evaluation results and self-assessments to consumers, and the component that orchestrates the production of SystemStateAssessments.

#### Step 5.1 — SelfExplanationService part def

**File:** `model/knowledge.sysml` → `Knowledge::LogicEngine`

```sysml
part def SelfExplanationService {
    doc /* The API surface through which consumers access the
         * system's self-knowledge and evaluation explanations.
         *
         * Four consumer categories, each with different needs:
         *
         * - Clinician UI: point-of-care evaluation results with
         *   clinical context. "Why did this safety check fail?"
         *   with data values and rule references.
         * - Patient portal: plain-language explanations for
         *   self-management. "Why am I eligible / not eligible?"
         *   with actionable guidance.
         * - Governance dashboard: population-level assessment
         *   summaries, deficit inventories, compliance rates,
         *   trend analysis over assessment history.
         * - Audit endpoint: full formal traces with data
         *   provenance, constraint references, requirement
         *   traceability. Exportable for regulatory submission.
         *
         * All four are views onto the same underlying data
         * (EvaluationResults, SystemStateAssessments). The
         * service applies audience-appropriate filtering,
         * explanation depth, and presentation format.
         *
         * Implements the ExplainEvaluationResult use case. */
    attribute serviceId : String;
}
```

#### Step 5.2 — AssessmentOrchestrator part def

**File:** `model/knowledge.sysml` → `Knowledge::LogicEngine`

```sysml
part def AssessmentOrchestrator {
    doc /* Orchestrates the production of SystemStateAssessments
         * by coordinating the other LogicEngine components.
         *
         * Assessment production sequence:
         * 1. Read System Model Manifest for Layer 1 (structural
         *    summary — packages, pathways, constraints, etc.)
         * 2. Invoke OperationalStateAggregator for Layer 2
         *    (operational snapshot)
         * 3. Invoke GoalProjector for Layer 3 (project all
         *    in-scope goals)
         * 4. Invoke GapAnalyser for Layer 4 (compare Layers 2
         *    and 3, produce Deficit records)
         * 5. Classify each Deficit's remediation category for
         *    Layer 5
         * 6. For Tier 1 deficits with deterministic remediation,
         *    identify the specific pathway action step
         * 7. For compound deficits, optionally invoke
         *    InferenceEvaluator (Tier 2) for reasoning
         * 8. Assemble the composite SystemStateAssessment
         *
         * Invocation patterns (from architecture decision
         * document, Section 6):
         * - On-demand: platform API call, scoped by caller
         * - Scheduled: Temporal cron workflow (daily clinical
         *   governance, weekly operational health)
         * - Triggered: critical deficit in point-of-care
         *   evaluation triggers broader scoped assessment
         *
         * Implements the ProduceSystemStateAssessment use case.
         * The orchestrator itself is a natural candidate for a
         * Temporal workflow — it coordinates multiple queries
         * and evaluations that may take non-trivial time. */
    attribute orchestratorId : String;
    ref constraintEvaluator : ConstraintEvaluator;
    ref operationalAggregator : OperationalStateAggregator;
    ref gapAnalyser : GapAnalyser;
    ref explanationService : SelfExplanationService;
}
```

**Syntax risk — LOW-MEDIUM:** The `ref` keyword referencing other part defs defined in the same package should work (similar to `ref customer : Customer` pattern in the syntax reference). If Syside rejects `ref` to part defs in the same package (as opposed to a different package), fall back to typed attributes (`attribute constraintEvaluator : String;` with name-based binding described in doc block).

**Git checkpoint:** Commit after Stage 5. Message: `Add SelfExplanationService and AssessmentOrchestrator to LogicEngine`

---

### Stage 6 — Evaluation Spec Registry and Composite Patterns

**Goal:** Model the registry pattern for evaluation specs and the composite evaluation pattern for compound rules. These fill the gap between the individual components (Stages 1–5) and the end-to-end evaluation flow.

#### Step 6.1 — EvaluationSpecRegistry part def

**File:** `model/knowledge.sysml` → `Knowledge::LogicEngine`

```sysml
part def EvaluationSpecRegistry {
    doc /* A runtime registry of ConstraintEvaluationSpecs, loaded
         * from the model (or generated as a TypeScript module)
         * at system startup.
         *
         * The registry resolves constraint names to their full
         * evaluation specifications: which inputs to derive,
         * from which sources, with what computations, and what
         * fallback behaviour. This is the lookup table that
         * the ConstraintEvaluator consults when invoked.
         *
         * Generation approach (from architecture decision
         * document, Section 1):
         * - A generator reads ConstraintEvaluationSpec part
         *   usages from Knowledge::ClinicalDecisionSupport
         * - It produces a TypeScript module exporting a map
         *   from constraint name to spec object
         * - The registry loads this module at startup
         *
         * This replaces the need to parse SysML at runtime.
         * The registry is a static, generated artefact — it
         * changes only when the model is updated and the
         * generator re-run. */
    attribute registryId : String;
    attribute specCount : Integer;
    attribute modelVersion : String;
}
```

#### Step 6.2 — EvaluationContext part def

**File:** `model/knowledge.sysml` → `Knowledge::LogicEngine`

```sysml
part def EvaluationContext {
    doc /* The runtime context for a single evaluation invocation.
         * Captures the scope (which patient, which pathway step),
         * the trigger (point-of-care, governance audit, triggered
         * assessment), and any ambient data already available
         * (to avoid redundant queries).
         *
         * Passed to the ConstraintEvaluator alongside the
         * ConstraintEvaluationSpec. The evaluator uses the
         * context to parameterise InputDerivation queries
         * (e.g. substituting the patient's EHR ID into AQL). */
    attribute contextId : String;
    attribute patientId : String;
    attribute pathwayStepRef : String;
    attribute triggerType : String;        // point-of-care, governance-audit, triggered
    attribute scope : AssessmentScope;
}
```

**Git checkpoint:** Commit after Stage 6. Message: `Add EvaluationSpecRegistry and EvaluationContext to LogicEngine`

---

### Stage 7 — Use Case Elaboration and Component Allocation

**Goal:** Elaborate the four Phase 1 use cases with component allocations and richer descriptions that reflect the component model.

#### Step 7.1 — Elaborate EvaluateConstraint

**File:** `model/knowledge.sysml` → `Knowledge::LogicEngine`

Replace the existing use case def with:

```sysml
use case def EvaluateConstraint {
    doc /* Evaluate a single constraint for a specific patient
         * or context.
         *
         * Component allocation:
         * 1. EvaluationSpecRegistry resolves the constraint name
         *    to its ConstraintEvaluationSpec
         * 2. InputResolver derives each input from its
         *    authoritative source per the spec
         * 3. ExpressionEvaluator evaluates the constraint
         *    boolean expression with derived inputs
         * 4. ExplanationBuilder assembles the ExplanationTrace
         * 5. ConstraintEvaluator composes the EvaluationResult
         *
         * Invoked by:
         * - Temporal activities generated from pathway steps
         *   annotated with @LogicRule or @SafetyConstraint
         * - Governance audit workflows iterating over a patient
         *   cohort
         * - Triggered assessment when a deficit is detected
         *
         * Produces: one EvaluationResult with full
         * ExplanationTrace per invocation. */
}
```

#### Step 7.2 — Elaborate PerformGapAnalysis

Replace with:

```sysml
use case def PerformGapAnalysis {
    doc /* Compare operational state against goal state for a
         * defined scope (patient, pathway, domain, system).
         *
         * Component allocation:
         * 1. GoalProjector projects all in-scope goals from
         *    requirements, constraints, and outcome definitions
         * 2. OperationalStateAggregator captures current state
         *    (or receives a pre-computed OperationalSnapshot)
         * 3. GapAnalyser compares each GoalProjection against
         *    operational data
         * 4. For each unmet goal, a Deficit record is produced
         *    with severity, remediation category, and supporting
         *    EvaluationResult evidence
         *
         * Scope determines breadth:
         * - Patient: all goals applicable to one patient
         * - Pathway: all goals for a specific clinical pathway
         * - Domain: all goals within a domain (clinical,
         *   operational, infrastructure)
         * - System: all goals across all domains
         *
         * Produces: a set of Deficit records. */
}
```

#### Step 7.3 — Elaborate ProduceSystemStateAssessment

Replace with:

```sysml
use case def ProduceSystemStateAssessment {
    doc /* Aggregate structural self-knowledge, operational state,
         * goal compliance, deficits, and remediation
         * recommendations into a composite SystemStateAssessment.
         *
         * Component allocation: AssessmentOrchestrator coordinates
         * the full five-layer assembly:
         * - Layer 1: reads System Model Manifest (structural)
         * - Layer 2: invokes OperationalStateAggregator
         * - Layer 3: invokes GoalProjector
         * - Layer 4: invokes GapAnalyser
         * - Layer 5: classifies remediation categories
         *
         * Three invocation triggers:
         * - On-demand: API call from clinician or admin UI
         * - Scheduled: Temporal cron workflow
         * - Triggered: critical deficit escalation
         *
         * Produces: one SystemStateAssessment. */
}
```

#### Step 7.4 — Elaborate ExplainEvaluationResult

Replace with:

```sysml
use case def ExplainEvaluationResult {
    doc /* Given an EvaluationResult or SystemStateAssessment,
         * produce an audience-appropriate explanation.
         *
         * Component allocation: SelfExplanationService renders
         * the underlying data (EvaluatedInputs, ExplanationTraces,
         * Deficit records) into the appropriate format for the
         * requesting consumer.
         *
         * Audience rendering:
         * - Clinician: data values, rule references, clinical
         *   context, recommended actions
         * - Patient: plain-language explanation, actionable
         *   guidance, self-management prompts
         * - Auditor: full trace, data provenance, requirement
         *   traceability, exportable format
         * - Dashboard: summary statistics, trend indicators,
         *   deficit inventory, compliance rates */
}
```

**Git checkpoint:** Commit after Stage 7. Message: `Elaborate LogicEngine use cases with component allocations`

---

### Stage 8 — LogicEngine Doc Block Update

**Goal:** Update the LogicEngine doc block to reflect the full component model.

#### Step 8.1 — Updated LogicEngine doc block

Replace the existing doc block with a version that describes the component inventory and their relationships:

```sysml
doc /* Inference rules, Prolog-style reasoning, deterministic
     * constraint evaluation, and system self-knowledge
     * infrastructure. Explicit architectural space for logic
     * programming.
     *
     * Component inventory:
     * - ConstraintEvaluator: Tier 1 deterministic evaluation
     *   (InputResolver, ExpressionEvaluator, ExplanationBuilder)
     * - OperationalStateAggregator: Layer 2 operational state
     *   queries across Temporal, CDR, and platform services
     * - GapAnalyser: Layer 4 comparison of operational state
     *   against goal state (GoalProjector)
     * - AssessmentOrchestrator: coordinates five-layer
     *   SystemStateAssessment production
     * - SelfExplanationService: audience-appropriate rendering
     *   of evaluation results and assessments
     * - EvaluationSpecRegistry: runtime lookup of constraint
     *   evaluation specifications
     * - InferenceEvaluator: Tier 2 interface (Prolog boundary)
     * - AdvisoryInterface: Tier 3 interface (ML/LLM boundary)
     *
     * Data structures (Phase 1):
     * - EvaluationResult, ExplanationTrace, EvaluatedInput
     * - Deficit, SystemStateAssessment
     * - OperationalSnapshot, OperationalQuery
     * - GoalProjection, EvaluationContext
     *
     * Three-tier reasoning stack:
     * Tier 1 — TypeScript constraint evaluator (generated from
     *   SysML). Boolean constraints with structured explanation
     *   traces. Handles ConstraintLibrary evaluation and
     *   Layers 1-4 of self-knowledge.
     * Tier 2 — Embedded Prolog for inference chains,
     *   contraindication cascades, compound deficit reasoning.
     *   Layer 5 compound remediation.
     * Tier 3 — ML/LLM advisory interface. Cannot override
     *   Tier 1/2 logic.
     *
     * Elaborated Session 8 (Phase 1: data structures) and
     * Session 9 (Phase 2: component model). */
```

---

### Stage 9 — Verification, Documentation, and Session Close

#### Step 9.1 — Full model verification

Open the entire workspace in Syside and verify clean parse across all files. The changes are confined to `knowledge.sysml` (LogicEngine package only). Check for:

- All new part defs parse clean
- Contained parts (`part inputResolver : InputResolver;`) resolve within the same package
- References (`ref constraintEvaluator : ConstraintEvaluator;`) resolve within the same package
- Cross-package enum imports still resolve (Foundation::CommonTypes enums in new part defs)
- No naming conflicts
- Hover tooltips show doc strings correctly

#### Step 9.2 — Run `gsl save`

Regenerate all hierarchy outputs. The new LogicEngine elements should appear with updated counts.

#### Step 9.3 — Syntax reference update

If new patterns are verified or traps discovered:

- `ref` to part defs within the same package (expected to work, but not previously verified with this many refs)
- Contained parts referencing part defs defined later in the same package (forward reference within package)
- Any new reserved word discoveries

If no new findings beyond confirming existing patterns, a v3.6 may not be needed — note the confirming evidence in the session report instead.

#### Step 9.4 — Session report

Write `gsl-session-report-2026-03-09-s9.md` covering:

- What was completed (which stages, which steps)
- Syntax findings (what worked, what failed, workarounds applied)
- Design decisions made
- Repository state after session
- Recommended next steps (Phase 3 — DecisionModels elaboration)

#### Step 9.5 — Git final commit

Stage and commit all remaining changes. Message: `Complete Knowledge Layer Phase 2: LogicEngine component model`

---

## 5. Execution Order and Dependencies

```
Pre-flight checks (Stage 0)
    │
    ▼
Stage 1: Tier 1 Evaluator component        ← depends on Phase 1 data structures
    │   (ConstraintEvaluator, InputResolver,
    │    ExpressionEvaluator, ExplanationBuilder)
    │
    ▼
Stage 2: Operational State Aggregator       ← depends on Phase 1 enums
    │   (OperationalStateAggregator,           (DataSourceType, AssessmentScope,
    │    OperationalQuery, OperationalSnapshot)  ServiceHealthStatus)
    │
    ▼
Stage 3: Gap Analyser                       ← depends on Phase 1 structures
    │   (GapAnalyser, GoalProjector,           (Deficit, EvaluationResult)
    │    GoalProjection)
    │
    ├──▶ Stage 4: Tier 2+3 Interfaces       ← independent of Stages 2-3
    │       (InferenceEvaluator,                (can be worked in parallel)
    │        AdvisoryInterface)
    │
    ▼
Stage 5: Self-Explanation + Orchestrator    ← depends on Stages 1-3
    │   (SelfExplanationService,               (references all components)
    │    AssessmentOrchestrator)
    │
    ▼
Stage 6: Registry + Context                 ← depends on Stage 1
    │   (EvaluationSpecRegistry,               (completes evaluator pattern)
    │    EvaluationContext)
    │
    ▼
Stage 7: Use Case Elaboration               ← depends on Stages 1-6
    │   (component allocations)                 (references all components)
    │
    ▼
Stage 8: Doc Block Update                   ← depends on all above
    │
    ▼
Stage 9: Verification + Documentation       ← depends on all above
```

Stages 1–3 must be sequential (each builds on the previous). Stage 4 can be worked in parallel with Stages 2–3 or after Stage 1. Stages 5–6 require all prior components to exist. Stages 7–8 are documentation updates that require the full component inventory.

---

## 6. Identified Risks

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| `ref` to part defs within same package not supported | Low | Medium | Fall back to typed attributes with string-based binding |
| Forward references within package (part def A contains part of type B, B defined later) | Low | Low | Reorder declarations — define leaf part defs before composite part defs |
| Package becomes too large (LogicEngine approaching 300+ lines) | Medium | Low | Acceptable for now; extract to sub-packages later if warranted. The parent plan anticipated this ("extract to a dedicated package later if the concern grows large enough") |
| Over-modelling risk: too many component part defs for structures that are ultimately simple TypeScript modules | Medium | Medium | Keep component part defs focused on interface contracts (inputs/outputs) not internal implementation. If a component's model is just a doc block and an ID, that's fine — the value is in the formal relationship and allocation, not in attribute-level detail |
| `Real` type for confidenceThreshold on AdvisoryInterface | Low | Low | Already verified in syntax reference (Section 2) |

---

## 7. Design Decisions

### 7.1 Components in LogicEngine, not in Platform::Orchestration

The runtime components modelled in Phase 2 are logical components in the Knowledge layer, not deployment components in the Platform layer. This preserves the separation principle: the Knowledge layer defines *what* the system knows and *how it reasons*; the Platform layer defines *where things run*. The ConstraintEvaluator is a knowledge concern (it evaluates knowledge); Temporal is a platform concern (it provides durable execution). The evaluator runs *within* Temporal activities, but it is defined *in* the Knowledge layer.

### 7.2 Flat component hierarchy (no sub-packages yet)

All Phase 2 components live directly in `Knowledge::LogicEngine`. This is the simplest option and follows the parent plan's recommendation to "start in LogicEngine alongside the evaluation infrastructure" and "extract to a dedicated package later if the concern grows large enough." If LogicEngine becomes unwieldy, natural extraction boundaries exist:

- `Knowledge::LogicEngine::Evaluation` — ConstraintEvaluator, InputResolver, ExpressionEvaluator, ExplanationBuilder, EvaluationSpecRegistry, EvaluationContext
- `Knowledge::LogicEngine::SelfKnowledge` — OperationalStateAggregator, GapAnalyser, GoalProjector, AssessmentOrchestrator, SelfExplanationService
- `Knowledge::LogicEngine::Reasoning` — InferenceEvaluator, AdvisoryInterface

This extraction is a future concern, not a Phase 2 deliverable.

### 7.3 Component granularity

The component decomposition follows the single-responsibility principle: each component has one clearly defined job. The ConstraintEvaluator coordinates evaluation but delegates input resolution, expression evaluation, and explanation building to sub-components. This granularity is intentional — it makes the generation target clear (each component becomes a TypeScript module with a defined interface) and supports testability (each component can be tested in isolation with mock inputs).

### 7.4 OperationalSnapshot as a separate part def

The operational state data could have been modelled as attributes directly on SystemStateAssessment (Phase 1 put some Layer 2 attributes there: activeWorkflows, etc.). Phase 2 extracts the operational state into OperationalSnapshot as a first-class structure. This creates a clean boundary: the aggregator produces a snapshot, the gap analyser consumes it, and the assessment orchestrator includes it. The Phase 1 SystemStateAssessment attributes for Layer 2 data become redundant once the snapshot is adopted — this can be cleaned up during or after this session.

**Decision needed during implementation:** Whether to remove the Layer 2 scalar attributes from SystemStateAssessment and replace them with `part operationalSnapshot : OperationalSnapshot;`, or keep both for now. Recommendation: add the OperationalSnapshot part to SystemStateAssessment and keep the scalar attributes as a summary view. Clean up in a later session if the duplication causes confusion.

---

## 8. Success Criteria (Phase 2)

Mapped to the parent plan's success criteria:

| Parent criterion | Phase 2 contribution |
|---|---|
| 1. Every rule evaluation produces a structured, self-explaining result | ConstraintEvaluator component model with InputResolver, ExpressionEvaluator, and ExplanationBuilder defines how this happens |
| 2. Evaluation architecture connects CDR data to constraint evaluation | InputResolver component formalises the runtime data derivation pathway; EvaluationSpecRegistry formalises the lookup |
| 3. Five layers of self-knowledge architecturally defined | OperationalStateAggregator (Layer 2), GoalProjector (Layer 3), GapAnalyser (Layer 4), remediation in AssessmentOrchestrator (Layer 5) — all as concrete components |
| 7. Three-tier reasoning stack concretely defined | ConstraintEvaluator (Tier 1), InferenceEvaluator (Tier 2), AdvisoryInterface (Tier 3) — with clear boundaries |
| 8. Generator pathway exists | EvaluationSpecRegistry formalises the generated artefact; component interfaces define the generation targets |
| 9. Gap analysis pattern defined as generalisation of Phase D | GapAnalyser, GoalProjector, and GoalProjection model the generalised pattern as concrete components |

---

## 9. Model Element Counts After Phase 2 (Projected)

### New elements in LogicEngine

| Element type | Count | Names |
|---|---|---|
| Part defs | +13 | ConstraintEvaluator, InputResolver, ExpressionEvaluator, ExplanationBuilder, OperationalStateAggregator, OperationalQuery, OperationalSnapshot, GapAnalyser, GoalProjector, GoalProjection, InferenceEvaluator, AdvisoryInterface, SelfExplanationService, AssessmentOrchestrator, EvaluationSpecRegistry, EvaluationContext |

**Correction:** That's 16 new part defs. Total LogicEngine part defs after Phase 2: 5 (Phase 1) + 16 (Phase 2) = 21.

### LogicEngine cumulative inventory

| Element type | Phase 1 | Phase 2 additions | Total |
|---|---|---|---|
| Part defs | 5 | 16 | 21 |
| Use case defs | 4 | 0 (elaborated, not added) | 4 |
| Enum defs | 0 | 0 | 0 |

---

## 10. Estimated Effort

| Stage | Estimated time | Notes |
|---|---|---|
| Pre-flight | 5–10 min | Ella: Syside checks, git status |
| Stage 1 | 20–25 min | Four part defs (evaluator + three sub-components) |
| Stage 2 | 15–20 min | Three part defs (aggregator, query, snapshot) |
| Stage 3 | 15–20 min | Three part defs (analyser, projector, projection) |
| Stage 4 | 10–15 min | Two part defs (Tier 2 + Tier 3 interfaces) |
| Stage 5 | 15–20 min | Two part defs (explanation service + orchestrator with refs) |
| Stage 6 | 10–15 min | Two part defs (registry + context) |
| Stage 7 | 15–20 min | Four use case elaborations (replace existing) |
| Stage 8 | 5–10 min | Doc block update |
| Stage 9 | 15–20 min | Verification, syntax reference check, session report |
| **Total** | **~2–3 hours** | Single session |

---

## 11. Recommended Next Steps After Phase 2

### Phase 3 — DecisionModels elaboration

With the evaluation component model complete, Phase 3 designs the decision table representation pattern and models the two hormone therapy decision tables (regimenSelection, stabilityAssessment). These tables are consumed by the ConstraintEvaluator via the same metadata-driven invocation pattern.

### Phase 4 — OutcomeFramework elaboration

Outcome definitions for the hormone therapy pathway, with measurement points and intervals. Outcomes connect to the GoalProjector as goal sources — unmet outcomes become deficits.

### Test nested `:>>` syntax (deferred from Phase 1)

If time permits, test the nested attribute redefinition pattern in a syntax-tests file. Success would allow the eight Phase 1 ConstraintEvaluationSpec usages to be enriched with their full InputDerivation detail directly in the model.

---

*Plan prepared 9 March 2026 (Session 9). Implements Phase 2 of the Knowledge Layer Elaboration extended plan.*
