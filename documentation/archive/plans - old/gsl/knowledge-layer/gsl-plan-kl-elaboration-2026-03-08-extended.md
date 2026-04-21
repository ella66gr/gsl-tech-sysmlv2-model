# Knowledge Layer Elaboration — Planning Document (Extended)

**Date:** 8 March 2026
**Context:** CDR Exercise complete. All integration patterns validated. The Knowledge layer is the next major elaboration target — clinical decision support, safety constraints, logic/reasoning, decision models, outcome measurement, and system self-knowledge.

**Revision note:** This version extends the original plan to incorporate structural and operational self-knowledge as a first-class concern within the evaluation architecture. Phase 1 is substantially expanded; subsequent phases are updated to reflect the wider scope. The extension was motivated by the recognition that the self-describing property articulated in the Modelling Strategy (Section 3.1) requires the system to report on its own state and identify deficits, not only to explain individual clinical rule evaluations.

**Supersedes:** gsl-plan-knowledge-layer-elaboration-2026-03-08.md (original, non-extended version retained for history)

---

## 1. Purpose

The Knowledge layer is where the self-describing property of the GenderSense architecture becomes most powerful. It explicitly models the clinical reasoning that governs patient care: eligibility rules, safety constraints, prescribing protocols, monitoring schedules, decision logic, and outcome definitions. These aren't documentation — they're evaluable, auditable, self-explaining computational artefacts that drive the system's behaviour.

The CDR exercise validated the data persistence and query patterns. The demonstrator validated process orchestration and governance audit. This work connects the two: rules evaluated against CDR data, producing deterministic, explainable results that inform pathway execution and clinician/patient decision-making.

**This plan now also addresses a broader concern:** the system's capacity to report on its own structural and operational state, to compare that state against defined goals, and to identify and communicate deficits. This is the difference between a system that can explain "why did this rule fire for this patient?" and a system that can answer "what is the current state of the service, where is it falling short, and what would bring it closer to where it should be?"

### What this work must achieve

1. **Establish the evaluation architecture:** How rules defined in the SysML model are evaluated at runtime — what evaluates them, how inputs are derived, how results are produced.
2. **Establish the self-knowledge architecture:** How the system represents and queries its own structural definition, operational state, and goal state — and how it computes and communicates the gaps between them.
3. **Elaborate the LogicEngine package:** Define the evaluation infrastructure, including the self-explanation requirement.
4. **Elaborate the DecisionModels package:** Define the decision table pattern and its relationship to constraints.
5. **Elaborate the OutcomeFramework package:** Define how outcomes are measured and how they feed back into pathway refinement.
6. **Design the integration points:** How the knowledge layer connects to the CDR (data source), pathways (consumer), governance (audit), patient-facing interfaces (guidance), and the system's own model (structural self-knowledge).

---

## 2. Current State

### 2.1 What exists

**Knowledge::ConstraintLibrary** — Eight concrete constraint defs with satisfy relationships to requirements in Enterprise::Regulation. Boolean expressions with typed inputs. Well-structured, formally correct in SysML, but no runtime evaluation target.

**Knowledge::ClinicalDecisionSupport** — Three use case defs (eligibility, monitoring alerts, pathway guidance). No structural elaboration.

**Knowledge::LogicEngine** — Doc block only. Notes Prolog, TypeScript evaluator, DMN engine as possibilities. Decision explicitly deferred.

**Knowledge::DecisionModels** — Doc block only. References DMN-style decision tables.

**Knowledge::OutcomeFramework** — One part def (OutcomeDefinition) with minimal attributes.

**Knowledge::LearningCycles** — Two use case defs (propose refinement, review and approve).

**Knowledge::Analytics** — One part def (DataContract), doc block describing Tier 3 reasoning.

**No structural self-knowledge infrastructure exists.** The model describes the system, but the running system has no mechanism to query the model's description of itself. The self-describing property is latent in the model; it is not yet operationalised.

### 2.2 What the constraints already tell us

The ConstraintLibrary constraints have a consistent shape:
- Typed boolean inputs derived from CDR data or entity lifecycle state
- Boolean expression composing the inputs
- satisfy relationship to a governance requirement
- Doc block describing the runtime data derivation

This shape is the seed of the evaluation pattern. Each constraint is already an implicit specification for: "query the CDR for X, evaluate Y, report the result with explanation."

### 2.3 What the pathway already tells us

The hormone therapy initiation pathway references the knowledge layer at every clinical decision point via metadata annotations:
- `@LogicRule { ruleName = "hormoneEligibility"; }` — eligibility evaluation
- `@DecisionTable { tableName = "regimenSelection"; }` — protocol selection
- `@DecisionTable { tableName = "stabilityAssessment"; }` — monitoring decision
- `@SafetyConstraint { constraintName = "prescribing-safety-check"; severity = "critical"; }` — safety gate
- `@ClinicalReviewGate` — human decision informed by rule evaluation results

These annotations name evaluations that need to exist. The knowledge layer must define them.

### 2.4 What the architecture already implies about self-knowledge

The Modelling Strategy (Section 3.1) states: *"model the system so it can explain itself. This means that reporting on activity, decision logic, structural semantics, constraints, governance, entity and relationship ontologies, and similar features are all first-class citizens of the environment."*

The Architecture Principles document describes aggregation across authoritative sources (Temporal for process state, CDR for clinical data, external services for operational data) for front-end views. The governance audit pattern (CDR exercise Phase D) compares expected state against actual state for a specific rule.

What is not yet designed is the generalisation: the system querying all of its authoritative sources against all of its defined goals to produce a composite self-assessment. This is the infrastructure gap that Phase 1 now addresses.

---

## 3. Design Questions

### 3.1 The self-explanation requirement

Every rule evaluation must be able to explain itself: what inputs were used, what rules were applied, what the result was, and why. This isn't a debugging feature — it's a clinical governance and patient safety requirement. A clinician needs to understand why a safety check failed. A patient needs to understand why they're eligible or not. An auditor needs to trace from outcome back through every decision.

This shapes the runtime choice significantly. The evaluation engine must produce **structured explanation traces**, not just boolean results.

**Proposed evaluation result shape:**

```
EvaluationResult {
  ruleName: string              — which rule was evaluated
  outcome: pass | fail | indeterminate
  inputs: [                     — what data was used
    { name: "weeksSinceLastTest", value: 14, source: "AQL: LabResult for patient X" }
  ]
  expression: string            — the rule as evaluated
  explanation: string           — human-readable explanation
  timestamp: datetime           — when evaluated
  constraints: [                — if compound, sub-evaluations
    { constraintName: "...", outcome: pass, ... }
  ]
  requirement: string           — governance requirement this satisfies
}
```

This is the unit of knowledge evaluation. Every rule, at every point in the system, produces one of these. They're persisted (CDR or audit log), queryable, and presentable to clinicians, patients, and auditors.

### 3.2 The self-knowledge requirement (new)

The self-explanation requirement addresses individual rule evaluations. The self-knowledge requirement addresses the system's capacity to report on itself as a whole. Five distinct layers of self-knowledge are needed, each building on the one below.

**Layer 1 — Structural self-knowledge: "what am I?"**

The system can describe its own architecture: what packages, pathways, entities, constraints, requirements, and integrations exist, and how they relate to each other. This is the model itself, made queryable at runtime.

At design time, this is already available via Syside Modeler and Syside Automator. At runtime, the system needs a **System Model Manifest** — a machine-readable, queryable representation of the SysML model's structure, generated as part of the build pipeline. This is not the full SysML model; it is a projection of the model's structural and relational content into a format the running system can interrogate.

The manifest answers questions like: "what pathways exist?", "what constraints apply to the hormone therapy pathway?", "what requirements does constraint X satisfy?", "what entity lifecycles are defined?", "what external integrations are specified?"

**Layer 2 — Operational self-knowledge: "what state am I in?"**

The system can report on its current operational state by aggregating across its authoritative data sources:
- **Process state** — from Temporal: which workflows are running, at which step, which are blocked, which have failed or timed out.
- **Clinical data state** — from the CDR via AQL: what has been recorded, what is overdue, what entity lifecycle states are current.
- **Entity lifecycle state** — from XState (or Temporal workflow state encoding entity state): what state is each tracked entity in.
- **Infrastructure state** — from platform services: is the CDR reachable, are Temporal workers running, are external integrations healthy.

This is the same aggregation pattern the architecture already describes for front-end views, applied reflexively. The operational state is not a separate data store; it is a set of queries against existing authoritative sources.

**Layer 3 — Goal-state knowledge: "what should I be?"**

The system can articulate what its operational state *should* look like. Goals derive from three sources within the model:
- **Requirements** — from Enterprise::Regulation and ClinicalGovernance: every patient should have monitoring bloods within N weeks, pathway deviations should be reviewed within M days.
- **Constraints** — from Knowledge::ConstraintLibrary: safety constraints, eligibility rules, monitoring schedules that define operational expectations.
- **Outcome definitions** — from Knowledge::OutcomeFramework: clinical targets, adherence thresholds, service-level expectations.

Goal-state knowledge is already encoded in the model. What is needed is a formalised way to project it into a comparable shape against operational state — essentially, the expected-state side of the governance audit pattern, generalised beyond a single rule.

**Layer 4 — Gap analysis: "where am I falling short?"**

The comparison of Layer 2 (actual) against Layer 3 (goal) produces a set of deficits. Each deficit is a structured record:

```
Deficit {
  domain: string                  — which area (clinical, operational, infrastructure)
  scope: patient | cohort | system
  description: string             — what the gap is
  goalReference: string           — which requirement / constraint / outcome definition
  actualState: any                — what was found
  expectedState: any              — what was expected
  severity: critical | warning | informational
  detectedAt: datetime
  affectedEntities: [             — patients, workflows, services affected
    { entityType: "...", entityId: "...", currentState: "..." }
  ]
  evaluationResults: [            — supporting EvaluationResult records
    { ... }
  ]
}
```

This is the generalisation of Phase D's governance audit. Phase D compared expected compositions against actual compositions for a single rule. The gap analysis applies the same pattern across all defined goals and all operational dimensions, producing a composite picture.

**Layer 5 — Remediation reasoning: "what would close the gap?"**

Given a deficit, the system reasons about what actions would resolve it. Three categories:

- **Deterministic remediation:** The pathway model already defines what should happen next. If a blood test is overdue, the pathway specifies "schedule blood test." The system can identify the specific action step and either trigger it automatically (if the pathway permits) or surface it as a recommendation.
- **Compound remediation:** Multiple deficits interact. A patient has overdue bloods *and* a missed appointment *and* an expiring prescription. The system needs to reason about priority, sequencing, and resource constraints. This is where Tier 2 inference (Prolog-style reasoning about relationships between deficits and available actions) becomes valuable.
- **Advisory remediation:** For structural or systemic deficits ("the average referral-to-appointment time exceeds the target"), remediation is not a single action but a strategic concern. The system can surface the deficit with supporting data; it cannot prescribe the solution. This connects to Knowledge::Analytics and Tier 3 advisory reasoning.

The key architectural principle: **Layers 1–4 are deterministic and must produce structured, auditable results.** Layer 5 is partially deterministic (for single-deficit, pathway-defined actions) and partially advisory (for compound and systemic issues). The boundary between "the system acts" and "the system advises" is explicit and governed.

### 3.3 The runtime evaluation target

Three credible options, not mutually exclusive:

**Option A: TypeScript constraint evaluator (generated from SysML)**

Extend the existing generation pipeline. A new generator reads `constraint def` blocks from the SysML model and produces TypeScript evaluation functions that take typed inputs, evaluate the boolean expression, and produce structured EvaluationResult objects with explanation traces.

Pros: Consistent with existing architecture. TypeScript is the project language. Generator pattern is proven. Runs natively in Temporal activities and SvelteKit endpoints.

Cons: Boolean expressions only — no forward/backward chaining, no inference. Fine for Tier 1 constraints but limited for complex reasoning.

**Option B: Embedded Prolog (Tau Prolog or SWI-Prolog WASM)**

A logic programming engine for rules that involve inference, chaining, and reasoning over relationships. Prolog naturally produces explanation traces (proof trees). Rules can be expressed declaratively and the engine handles evaluation order.

Pros: Natural fit for clinical reasoning. Self-explaining by design. Handles complex rule relationships (contraindication cascades, multi-factor eligibility). A Prolog-based system can answer "why" questions about its conclusions. Also a natural fit for compound remediation reasoning in Layer 5.

Cons: Different language/paradigm. Integration with TypeScript/Temporal requires a bridge. Tau Prolog is pure JS but limited; SWI-Prolog WASM is more capable but heavier. Developer unfamiliarity (though Ella has expressed interest).

**Option C: DMN engine for decision tables**

A Decision Model and Notation engine for structured decision tables. Decision tables are inherently self-documenting — the table shows all possible input combinations and their outcomes. Clinicians can read and validate them directly.

Pros: Clinician-readable. Deterministic. Standardised (OMG DMN). Natural fit for protocol selection, dosing decisions, risk stratification. Some DMN engines produce explanation output.

Cons: Limited to tabular decisions — not suitable for constraint evaluation or inference chains. Another technology to integrate.

**Proposed approach: A + B, with C deferred**

Start with **Option A** (generated TypeScript evaluator) for Tier 1 constraints and for Layers 1–4 of self-knowledge (structural queries, operational state aggregation, goal-state projection, and gap analysis are all expressible as deterministic TypeScript). This extends the proven generator pattern and handles the existing constraint defs immediately.

Explore **Option B** (Prolog) for Tier 2 reasoning where inference chains, contraindication cascades, compound deficit reasoning, and "why" queries are needed. Prolog is particularly interesting for Layer 5 compound remediation, where the system reasons about relationships between multiple deficits and available actions.

**Option C** (DMN) is deferred. Decision tables can be modelled as SysML constructs (the DecisionModels package) and evaluated by either the TypeScript evaluator or the Prolog engine. A dedicated DMN engine is an optimisation, not a necessity.

### 3.4 How inputs are derived from the CDR

The constraint doc blocks describe input derivation narratively ("weeksSinceLastTest is derived from the most recent LabResult"). This needs to be formalised:

```
InputDerivation {
  inputName: "weeksSinceLastTest"
  aqlQuery: "SELECT ... FROM EHR e CONTAINS ... WHERE ..."
  computation: "dateDiff(now, resultDate, weeks)"
  fallback: "indeterminate if no LabResult exists"
}
```

This is the bridge between the CDR (validated in the exercise) and the knowledge layer. Each constraint input has an AQL query that produces the raw data and a computation that derives the typed input value. The evaluation engine runs the queries, derives the inputs, evaluates the constraint, and produces the explanation trace.

**Where this lives in the model:** Input derivations could be modelled as attributes on the constraint defs themselves, or as a separate mapping layer in ClinicalDecisionSupport. The latter is probably cleaner — it separates "what the rule is" (ConstraintLibrary) from "how to get the data for the rule" (CDS input derivation mappings).

**Self-knowledge extension:** The same InputDerivation pattern applies to operational state queries. "How many workflows are currently blocked?" requires a Temporal query rather than an AQL query, but the structure is identical: a named input, a query against an authoritative source, a computation, and a fallback. The InputDerivation pattern should be source-agnostic — CDR, Temporal, platform services — with the query type and target as parameters.

### 3.5 Decision tables as SysML constructs

Decision tables map input conditions to outcomes. For hormone therapy:

**Regimen selection table:**

| Baseline T | Baseline E2 | Patient preference | Contraindications | → Medication | → Route | → Starting dose |
|---|---|---|---|---|---|---|
| Low | Low | Oestrogen preferred | None | Estradiol | Transdermal | 50mcg |
| Low | Low | Oestrogen preferred | VTE risk | Estradiol | Transdermal | 50mcg |
| Low | Low | Testosterone preferred | None | Testosterone | IM injection | 250mg |
| ... | ... | ... | ... | ... | ... | ... |

SysML v2 doesn't have a native decision table construct. Options:
- Model as a set of constraint defs (one per row — verbose but formally correct)
- Model as a part def with structured attributes representing the table (readable but not evaluable in SysML)
- Model as a metadata-annotated element with the table encoded as structured string attributes (pragmatic but hacky)
- Define a `@DecisionTable` metadata pattern that the generator reads to produce evaluation code

The last option is most consistent with the architecture. The metadata already exists (`@DecisionTable { tableName = "regimenSelection"; }`). The table content could live in a companion data file (JSON/YAML) referenced by the metadata, or in the SysML doc block in a structured format.

### 3.6 Outcome measurement

OutcomeFramework needs to define:
- **What outcomes are measured** (clinical targets achieved, monitoring adherence, patient satisfaction, adverse events)
- **When outcomes are measured** (at defined intervals, at pathway milestones, on discharge)
- **How outcomes are captured** (CDR compositions, self-assessment tools, clinician recording)
- **How outcomes feed back** (into LearningCycles, into constraint refinement, into pathway modification)

The outcome data is CDR data — captured as openEHR compositions via the same patterns validated in the exercise. The distinction is that OutcomeFramework defines which compositions constitute outcomes, at what measurement points, and against what criteria.

### 3.7 The System State Assessment as a composite structure (new)

The EvaluationResult is the atomic unit: one rule, one evaluation, one explanation. The system needs a composite structure that aggregates across multiple evaluations and operational queries to produce a whole-system picture.

```
SystemStateAssessment {
  assessmentId: string
  timestamp: datetime
  scope: full | domain | pathway | patient
  scopeFilter: string              — e.g. "HormoneTherapy", "patient:X"

  structuralSummary: {             — Layer 1: what the system is
    packagesCount: int
    pathwaysCount: int
    constraintsCount: int
    requirementsCount: int
    entityLifecyclesCount: int
    integrationsCount: int
    modelVersion: string
  }

  operationalSummary: {            — Layer 2: current state
    activeWorkflows: int
    blockedWorkflows: int
    failedWorkflows: int
    overdueItems: int              — items past their goal-state deadline
    entityStateCounts: [           — e.g. { entity: "Prescription", state: "active", count: 42 }
      { entityType: string, state: string, count: int }
    ]
    infrastructureHealth: [
      { service: string, status: healthy | degraded | unreachable }
    ]
  }

  goalCompliance: {                — Layer 3 vs Layer 2
    totalGoals: int
    goalsMet: int
    goalsUnmet: int
    goalsIndeterminate: int
  }

  deficits: [Deficit]              — Layer 4: the gaps

  remediations: [                  — Layer 5: what could close them
    {
      deficitRef: string
      actionType: automatic | recommended | advisory
      description: string
      pathwayStep: string          — if deterministic, which model element
      confidence: deterministic | inferred | advisory
    }
  ]

  evaluationResults: [EvaluationResult]  — supporting detail
}
```

This structure is not a new data store. It is computed on demand by querying existing authoritative sources and running existing evaluation logic. It can be produced for a single patient (scope: patient), a clinical pathway (scope: pathway), a domain (scope: domain), or the entire system (scope: full). Scheduled Temporal workflows can produce periodic assessments; on-demand requests can produce point-in-time assessments.

The SystemStateAssessment is the primary output of the self-knowledge infrastructure. It is what makes the self-describing property concrete and operational.

---

## 4. Proposed Work Breakdown

### Phase 1 — Evaluation and self-knowledge architecture design

**Goal:** Establish the evaluation result shape, input derivation pattern, explanation trace format, and the self-knowledge layer architecture. No code — this is design work in the SysML model and documentation.

Phase 1 is divided into two tracks that are designed together because they share the same foundational patterns (structured results, input derivation, explanation traces) but address different scopes (individual rule evaluation vs. whole-system self-knowledge).

#### Track A — Rule evaluation architecture

| Step | Activity | Deliverable |
|---|---|---|
| 1A.1 | Define EvaluationResult as a part def | Foundation::CommonTypes or Knowledge::LogicEngine |
| 1A.2 | Define InputDerivation pattern (source-agnostic: CDR, Temporal, platform) | Knowledge::ClinicalDecisionSupport |
| 1A.3 | Define ExplanationTrace structure | Knowledge::LogicEngine |
| 1A.4 | Map existing constraint defs to input derivations | Knowledge::ClinicalDecisionSupport |
| 1A.5 | Design the evaluation invocation pattern (how pathways call evaluations) | Architecture decision document |

#### Track B — Self-knowledge architecture

| Step | Activity | Deliverable |
|---|---|---|
| 1B.1 | Define the System Model Manifest concept — what structural information the running system needs about itself, and how it is generated from the SysML model | Architecture decision document |
| 1B.2 | Define the Operational State Query pattern — how the system queries its own operational state across Temporal, CDR, and platform services, using the source-agnostic InputDerivation from 1A.2 | Knowledge::LogicEngine or new package (see design note below) |
| 1B.3 | Define Goal State Projection — how requirements, constraints, and outcome definitions are projected into a comparable shape against operational state | Knowledge::ClinicalDecisionSupport |
| 1B.4 | Define the Deficit structure as a part def | Foundation::CommonTypes |
| 1B.5 | Define the SystemStateAssessment as a composite part def | Foundation::CommonTypes or Knowledge::LogicEngine |
| 1B.6 | Design the remediation classification pattern — how deficits are mapped to automatic, recommended, or advisory actions, and where the deterministic/advisory boundary sits | Knowledge::ClinicalDecisionSupport + architecture decision document |
| 1B.7 | Design the assessment invocation pattern — on-demand, scheduled (Temporal cron), and triggered (by deficit detection) | Architecture decision document |

**Design note — where self-knowledge lives in the model:**

There is a question about whether the self-knowledge infrastructure belongs in an existing package or a new one. Three options:

- **In Knowledge::LogicEngine** — because self-knowledge is a form of reasoning and the evaluation infrastructure is shared. This is the simplest option and avoids proliferating packages.
- **In Knowledge::Analytics** — because system self-assessment is an analytical capability and Analytics already has a doc block about BI/predictive/ML. This is conceptually defensible but conflates operational self-knowledge (deterministic, Tier 1) with analytical intelligence (Tier 3).
- **In a new Knowledge::SystemSelfKnowledge package** — because the self-knowledge concern is architecturally distinct from clinical rule evaluation and from predictive analytics. This is the cleanest separation but adds a package.

Recommended: start in Knowledge::LogicEngine alongside the evaluation infrastructure, since the foundational patterns (InputDerivation, structured results, explanation traces) are shared. If it grows large enough to warrant separation, extract to a dedicated package later. The package hierarchy can accommodate this without disruption.

### Phase 2 — LogicEngine elaboration

**Goal:** Flesh out the LogicEngine package with the evaluation infrastructure, the self-knowledge query infrastructure, and the three-tier stack.

| Step | Activity | Deliverable |
|---|---|---|
| 2.1 | Model Tier 1 evaluator (deterministic constraint evaluation) | LogicEngine part defs and use cases |
| 2.2 | Model the operational state aggregator — the component that executes source-agnostic queries against Temporal, CDR, and platform services | LogicEngine part defs |
| 2.3 | Model the gap analyser — the component that compares operational state against goal state and produces Deficit records | LogicEngine part defs |
| 2.4 | Model Tier 2 evaluator (inference and reasoning), including compound deficit reasoning | LogicEngine part defs, Prolog exploration notes |
| 2.5 | Model Tier 3 interface (advisory, ML/LLM) | LogicEngine part defs (interface only) |
| 2.6 | Define the self-explanation API — covering both individual EvaluationResults and composite SystemStateAssessments | LogicEngine structural model |

### Phase 3 — DecisionModels elaboration

**Goal:** Define the decision table pattern and model the hormone therapy decision tables.

| Step | Activity | Deliverable |
|---|---|---|
| 3.1 | Design the SysML decision table representation | DecisionModels pattern + syntax test |
| 3.2 | Model regimenSelection table | DecisionModels |
| 3.3 | Model stabilityAssessment table | DecisionModels |
| 3.4 | Connect tables to pathway annotations | Verified traceability |

### Phase 4 — OutcomeFramework elaboration

**Goal:** Define outcome measurement for the hormone therapy pathway.

| Step | Activity | Deliverable |
|---|---|---|
| 4.1 | Define clinical outcomes for hormone therapy initiation | OutcomeFramework part defs |
| 4.2 | Define measurement points and intervals | OutcomeFramework |
| 4.3 | Design outcome-to-pathway feedback pattern | LearningCycles integration |
| 4.4 | Design outcome capture as CDR compositions | openEHR archetype considerations |
| 4.5 | Connect outcome definitions to goal-state projection (from 1B.3) — outcomes are goals; unmet outcomes are deficits | OutcomeFramework + Knowledge::ClinicalDecisionSupport |

### Phase 5 — Generator exploration (optional, time-permitting)

**Goal:** Prototype the constraint-to-TypeScript generator and the System Model Manifest generator.

| Step | Activity | Deliverable |
|---|---|---|
| 5.1 | Design generator output format for constraint evaluators | TypeScript evaluation function shape |
| 5.2 | Prototype generator for one constraint | Working generated evaluator |
| 5.3 | Design generator output format for System Model Manifest | JSON/TypeScript manifest shape |
| 5.4 | Prototype manifest generator (Syside Automator or regex-based) | Working generated manifest from current model |
| 5.5 | Evaluate Prolog integration feasibility | Tau Prolog spike |

---

## 5. Relationship to Existing Architecture

### 5.1 The knowledge layer evaluates; pathways consume

Pathways reference evaluations via metadata annotations (`@LogicRule`, `@DecisionTable`, `@SafetyConstraint`). The knowledge layer defines what those evaluations are and how they work. At runtime, Temporal activities invoke evaluations as part of pathway execution. Evaluation results flow back into the pathway (proceed/block) and into the CDR (audit record).

### 5.2 The CDR provides inputs; the knowledge layer queries them

Every constraint input is ultimately derived from CDR data via AQL. The input derivation mappings formalise what the constraint doc blocks already describe narratively. The evaluation infrastructure runs the AQL queries, derives the inputs, and feeds them to the evaluator.

### 5.3 Temporal and platform services also provide inputs (new)

The source-agnostic InputDerivation pattern recognises that not all evaluation inputs come from the CDR. Operational state queries draw from Temporal (process state), platform services (infrastructure health), and entity lifecycle state (XState or Temporal-encoded). The same derivation pattern — named input, query, computation, fallback — applies regardless of source.

### 5.4 Governance audits are batch evaluations

The governance audit pattern (validated in Phase D) is the same as point-of-care evaluation, just applied across a population rather than for a single patient. The same rules, the same inputs, the same explanation traces — but queried in bulk and aggregated into a report.

### 5.5 System self-assessment generalises the governance audit (new)

The Phase D governance audit asked: "for this specific rule, which patients are compliant and which are not?" The SystemStateAssessment asks: "across all rules, all pathways, all operational dimensions — where does the system stand relative to its goals?" This is not a different pattern; it is the governance audit pattern applied at every level of the system simultaneously, producing a composite rather than a single-rule result.

The scheduled governance audit Temporal workflow recommended in the CDR exercise summary (Section 4.6) becomes one invocation of the self-assessment infrastructure, scoped to clinical governance. Other invocations might scope to operational health, pathway throughput, or infrastructure status.

### 5.6 Patient-facing guidance derives from the same rules

When the architecture principle says "a change to a monitoring guideline updates the model, which regenerates the constraint logic, which changes both clinician alerts and patient-facing information simultaneously" — the knowledge layer is where that happens. The evaluation result, with its explanation trace, is the source for both the clinician's decision support alert and the patient's self-management guidance.

### 5.7 The System Model Manifest closes the representation-execution gap (new)

The Architecture Principles document establishes that execution components consume the representation layer but do not define it. The System Model Manifest is the mechanism by which the running system has access to the representation layer's structural content. Without it, the system can execute pathways (because Temporal workflows are generated from the model) and validate data (because the CDR enforces archetype constraints) — but it cannot answer questions about its own design. The manifest makes the model's structural and relational content available to the execution layer as read-only reference data.

This preserves the separation principle: the manifest is a generated, derived artefact (like Temporal workflows and XState machines). The source of truth remains the SysML model. The manifest is regenerated whenever the model changes.

---

## 6. What This Intentionally Defers

- **Prolog implementation** — explored and evaluated, but not built until clinical rules demand inference capabilities beyond boolean constraints
- **DMN engine integration** — decision tables modelled in SysML; dedicated DMN engine is an optimisation
- **ML/LLM integration** — Tier 3 is interface-only; advisory capabilities depend on data volume and clinical validation
- **Cross-pathway rule sharing** — the hormone therapy constraints are pathway-specific; generalisation happens when a second pathway is modelled
- **External clinical knowledge sources** — NICE guidelines, BNF integration, drug interaction databases are integration concerns, not modelling concerns
- **Full manifest generation** — the manifest concept is designed; the generator is prototyped if time permits but is not a Phase 1 blocker
- **Compound remediation reasoning** — Layer 5 compound and advisory remediation is architecturally specified but implementation is deferred until the Prolog exploration matures and real deficit patterns are observed
- **Generated package hierarchy overview** — the markdown tree derived from the SysML model is a natural first output of the manifest generator, but it is a convenience, not a prerequisite

---

## 7. Success Criteria

The knowledge layer elaboration is successful if:

1. **Every rule evaluation produces a structured, self-explaining result** that can be presented to clinicians, patients, and auditors
2. **The evaluation architecture connects CDR data to constraint evaluation** via a formalised, source-agnostic input derivation pattern that also accommodates Temporal and platform service queries
3. **The five layers of self-knowledge are architecturally defined** with concrete structures (EvaluationResult, Deficit, SystemStateAssessment) and clear boundaries between deterministic and advisory reasoning
4. **The System Model Manifest concept is specified** — what it contains, how it is generated, and how the running system queries it
5. **Decision tables are representable in the SysML model** and traceable to pathway decision points
6. **Outcome definitions exist for the hormone therapy pathway** with measurement points and feedback mechanisms, connected to the goal-state projection
7. **The three-tier reasoning stack is concretely defined** with clear boundaries between deterministic evaluation, inference, and advisory intelligence
8. **A generator pathway exists** (even if not yet built) for producing evaluation code and the System Model Manifest from the SysML model
9. **The gap analysis pattern is defined** as a generalisation of the Phase D governance audit, applicable at patient, pathway, domain, and whole-system scope

---

*Plan prepared 8 March 2026 (Session 6), extended 8 March 2026 (Session 7). Companion to the Architecture Principles document, the CDR Exercise Summary, and the Hormone Therapy Initiation Modelling Plan.*
