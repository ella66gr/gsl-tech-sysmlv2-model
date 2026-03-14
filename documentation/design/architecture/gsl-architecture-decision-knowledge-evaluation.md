# Architecture Decision: Knowledge Layer Evaluation and Self-Knowledge

**Date:** 8 March 2026 (Session 8)
**Status:** Accepted
**Context:** Knowledge Layer Elaboration Phase 1, Stages 1–4 complete. This document captures the design decisions that connect the SysML structural definitions to the runtime architecture.

---

## 1. Evaluation Invocation Pattern

### Decision

Pathway action flows invoke constraint evaluations via the existing metadata annotation mechanism. The generated Temporal activity for an annotated step calls the evaluation engine, which resolves the evaluation spec, derives inputs, evaluates the constraint, and returns a structured result.

### Flow

1. A pathway action step carries a metadata annotation (e.g. `@LogicRule { ruleName = "hormoneEligibility"; }` or `@SafetyConstraint { constraintName = "prescribing-safety-check"; severity = "critical"; }`)
2. The Temporal workflow generator produces an activity call that includes the annotation metadata
3. At runtime, the activity implementation calls the evaluation engine with the constraint name
4. The evaluation engine looks up the corresponding `ConstraintEvaluationSpec` in the evaluation spec registry (loaded from the model or generated as a TypeScript module)
5. For each `InputDerivation` in the spec, the engine queries the appropriate authoritative source (CDR via AQL, Temporal API, platform service endpoint, entity lifecycle state)
6. The engine derives typed input values from query results using the specified computation
7. If any input query fails or returns no data, the engine applies the fallback (typically `indeterminate` with a reason)
8. The engine evaluates the constraint expression with the derived inputs
9. The engine produces an `EvaluationResult` containing: outcome (pass/fail/indeterminate), the `ExplanationTrace` with all `EvaluatedInput` records, constraint and requirement references
10. The result is returned to the calling activity
11. The activity proceeds or blocks based on the outcome
12. The result is committed to the CDR (or a dedicated audit log) as a governance record

### Rationale

This pattern preserves the separation principle: the pathway model declares *that* an evaluation is needed (via metadata annotation), the evaluation spec declares *how* to get the data (via input derivations), and the constraint def declares *what* the rule is (via the boolean expression). No process logic is embedded in application code. The evaluation engine is a generic runtime component that consumes model-derived specifications.

The same evaluation engine serves both point-of-care invocation (single patient, triggered by pathway execution) and governance audit invocation (population, triggered by scheduled workflow). The only difference is scope: one patient vs. an AQL query returning a cohort.

### Generator implications

The existing Temporal workflow generator needs a minor extension: when it encounters `@LogicRule` or `@SafetyConstraint` metadata on an action step, it generates an activity that calls the evaluation engine rather than (or in addition to) the standard activity implementation. This is a Phase 5 concern.

A new generator reads `ConstraintEvaluationSpec` part usages from the SysML model and produces a TypeScript evaluation spec registry — a module exporting a map from constraint name to spec object. This replaces the need to parse SysML at runtime.

---

## 2. System Model Manifest

### Decision

The running system has access to a machine-readable projection of the SysML model's structural and relational content, generated as a build artefact. This is the System Model Manifest.

### What the manifest contains

| Section | Content | Source in model |
|---|---|---|
| Package hierarchy | Names, descriptions, parent-child relationships, element counts | All `.sysml` files (already extracted by `gen_package_hierarchy.py`) |
| Pathway inventory | Pathway names, steps, decision points, metadata annotations | `ServiceDelivery::ClinicalPathways` action defs |
| Constraint inventory | Constraint names, input signatures, satisfied requirements, evaluation specs | `Knowledge::ConstraintLibrary` + `Knowledge::ClinicalDecisionSupport` |
| Entity lifecycle inventory | Entity names, states, transitions, events | `ServiceDelivery::ClinicalEntities` state defs |
| Requirement inventory | Requirement names, descriptions, satisfy relationships | `Enterprise::Regulation` requirement defs |
| Integration inventory | External service references, activity signatures | `Platform::Integration` + metadata annotations |
| Metadata inventory | Which elements carry which metadata annotations | All files, filtered by metadata def |

### Generation approach

**Phase 1 (current):** The manifest is a concept. The existing `gen_package_hierarchy.py` is a partial prototype — it already extracts package names, descriptions, and element counts.

**Phase 2–5 (future):** A dedicated manifest generator extends the hierarchy generator to extract deeper element information. Two implementation paths:

- **Regex-based:** Extends the existing Python parser. Adequate for controlled formatting but fragile. Quick to build.
- **Syside Automator:** Uses `Compiler.evaluate_filter` for semantic model access. More robust, handles arbitrary formatting, supports metadata filtering. Requires Automator API stability (targeted for Syside 1.0, Q1 2026).

Recommended: start with regex-based for the hierarchy and constraint sections (these have the most controlled formatting). Migrate to Automator when the API stabilises.

### Output format

JSON, structured by section. Example shape:

```json
{
  "modelVersion": "2026-03-08",
  "generatedAt": "2026-03-08T20:30:00Z",
  "packages": {
    "count": 64,
    "hierarchy": [ ... ]
  },
  "constraints": {
    "count": 8,
    "items": [
      {
        "name": "BloodMonitoringIntervalConstraint",
        "inputs": ["weeksSinceLastTest", "requiredIntervalWeeks"],
        "satisfies": "BloodMonitoringRequired",
        "severity": "warning",
        "evaluationSpec": "bloodMonitoringSpec"
      }
    ]
  },
  "pathways": { ... },
  "entityLifecycles": { ... },
  "requirements": { ... }
}
```

The manifest is a static file, read by the running system at startup or on configuration refresh. It is regenerated whenever the model changes (ideally via a pre-commit hook or CI step).

### What the manifest enables

- **Layer 1 (structural self-knowledge):** The system can answer "what pathways exist?", "what constraints apply to hormone therapy?", "what requirements does this constraint satisfy?" without parsing SysML at runtime.
- **SystemStateAssessment structural summary:** The `packagesCount`, `pathwaysCount`, `constraintsCount` etc. attributes are populated from the manifest.
- **Future: model-aware UI components:** A clinician-facing dashboard could display the constraint inventory, show which constraints apply to a given patient's pathway, and link evaluation results back to the model elements that defined them.

---

## 3. Operational State Query Pattern

### Decision

The system queries its own operational state using the same `InputDerivation` pattern as constraint evaluation, but scoped to operational rather than clinical concerns. The pattern is source-agnostic: the query structure is identical regardless of whether the data source is the CDR, Temporal, or a platform service.

### Operational query categories

| Category | Source | Example queries |
|---|---|---|
| Process state | Temporal | Active workflows by type, blocked workflows, failed workflows, average step duration, workflows past SLA |
| Clinical data state | CDR (AQL) | Patients with overdue monitoring, composition counts by archetype type, entity lifecycle state distribution |
| Entity lifecycle state | XState / Temporal | Counts by entity type and state (e.g. 42 active prescriptions, 7 pending referrals) |
| Infrastructure health | Platform services | CDR reachable, Temporal workers running, external integrations healthy |

### How this connects to SystemStateAssessment

The `ProduceSystemStateAssessment` use case:

1. Reads the System Model Manifest for Layer 1 (structural summary)
2. Executes operational state queries for Layer 2 (operational summary)
3. Projects goal state from requirements, constraints, and outcome definitions for Layer 3
4. Compares Layer 2 against Layer 3 to produce `Deficit` records for Layer 4
5. Classifies each deficit's remediation category for Layer 5
6. Assembles the composite `SystemStateAssessment`

Each step uses existing infrastructure: the manifest (generated), the evaluation engine (for constraint evaluation), AQL queries (validated in CDR exercise), Temporal API queries (standard), and platform health checks (standard HTTP).

---

## 4. Goal State Projection

### Decision

Goals are projected from three sources within the model into a comparable shape against operational state. Each goal is expressed as an expected condition that can be evaluated against actual data.

### Goal sources

| Source | Example | Projected as |
|---|---|---|
| Requirements (`Enterprise::Regulation`) | "Every patient must have monitoring bloods within 12 weeks" | Expected: for each active patient, a LabResult composition exists within 12 weeks of the last one |
| Constraints (`Knowledge::ConstraintLibrary`) | `BloodMonitoringIntervalConstraint` | Expected: `weeksSinceLastTest <= requiredIntervalWeeks` evaluates to `pass` for every active patient |
| Outcome definitions (`Knowledge::OutcomeFramework`) | "Hormone levels within therapeutic range at 6 months" | Expected: outcome measurement composition exists at the defined interval with values within target |

### Relationship to governance audit

The Phase D governance audit compared expected compositions against actual compositions for a single rule. Goal state projection generalises this: every requirement, constraint, and outcome definition implies an expected operational state. The gap analysis evaluates all of them, producing a deficit for each unmet goal.

This is not a different pattern — it is the governance audit pattern applied comprehensively rather than for a single rule.

---

## 5. Remediation Classification

### Decision

Each deficit is classified into one of three remediation categories, defining the boundary between deterministic system action and advisory output.

| Category | Criteria | System behaviour | Tier |
|---|---|---|---|
| **Automatic** | The pathway model defines the next step for this deficit. The action is unambiguous and permitted without human decision. | System triggers the action (e.g. schedule overdue blood test, send reminder notification) | Tier 1 |
| **Recommended** | A specific action is identifiable but requires human judgement or authorisation. | System surfaces the recommendation to the appropriate clinician with supporting EvaluationResult evidence | Tier 1 |
| **Advisory** | The deficit is systemic, compound, or structural. No single action resolves it. | System surfaces the deficit with supporting data for human analysis. May involve multiple interacting deficits. | Tier 2/3 |

### Boundary governance

The boundary between automatic and recommended is a clinical safety decision, not a technical one. It must be explicitly defined in the model for each constraint/pathway combination. The default for any new deficit is `recommended` — the system never takes automatic clinical action unless the model explicitly permits it.

Compound remediation (multiple interacting deficits) and advisory remediation (systemic issues) are deferred to Tier 2 (Prolog exploration) and Tier 3 (advisory intelligence). The architecture accommodates them; the implementation is not yet needed.

---

## 6. Assessment Invocation Patterns

### Decision

Three triggers for producing a `SystemStateAssessment`:

| Trigger | Mechanism | Typical scope | Frequency |
|---|---|---|---|
| **On-demand** | Platform API endpoint called by clinician or admin UI | Patient, pathway, or domain | Ad hoc |
| **Scheduled** | Temporal cron workflow | Domain or full system | Daily (clinical governance), weekly (operational health) |
| **Triggered** | Critical deficit detected during point-of-care evaluation triggers a broader scoped assessment | Pathway or domain | Event-driven |

### Scheduled assessment as Temporal workflow

The scheduled assessment is itself a Temporal workflow — the same infrastructure that orchestrates clinical pathways. The workflow:

1. Reads the manifest for structural context
2. Executes scoped operational state queries
3. Evaluates all in-scope constraints for the relevant population
4. Compares against goal state projections
5. Produces a `SystemStateAssessment` record
6. Stores the assessment (CDR composition or dedicated audit store)
7. If critical deficits are found, optionally triggers notification or contingency workflows

This is the direct evolution of the Phase D governance audit recommendation (CDR exercise summary Section 4.6): "scheduled governance audits as Temporal workflows."

### Triggered assessment

When a point-of-care evaluation produces a `fail` outcome with `critical` severity, the evaluation engine can optionally trigger a scoped assessment to determine whether the deficit is isolated (one patient) or systemic (pattern across the cohort). This is a future capability — the architecture supports it via the same assessment infrastructure, just invoked reactively rather than on a schedule.

---

## 7. Relationship to Existing Architecture

| Principle | How this decision honours it |
|---|---|
| **Separation of representation and execution** | Rules live in the model (ConstraintLibrary). Evaluation specs live in the model (CDS). The runtime engine consumes generated specs. No rule logic is embedded in application code. |
| **Process knowledge lives in the model** | Evaluation invocation is declared via metadata annotations on pathway steps. The generator produces the glue code. |
| **Views aggregate from authoritative sources** | SystemStateAssessment queries Temporal, CDR, and platform services. No separate data store is created. |
| **Governance is first-class** | Every evaluation produces a structured, auditable result. Population-level governance is the same pattern as point-of-care evaluation, just at different scope. |
| **Execution components are replaceable** | The evaluation engine is a TypeScript module consuming specs. Temporal, EHRbase, and platform services are accessed via their standard APIs. Any could be replaced without changing the evaluation architecture. |

---

*Architecture decision document prepared 8 March 2026 (Session 8). Companion to the Knowledge Layer Elaboration extended plan and Phase 1 implementation plan.*
