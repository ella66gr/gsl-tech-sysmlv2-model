# Knowledge Layer Elaboration — Planning Document

**Date:** 8 March 2026
**Context:** CDR Exercise complete. All integration patterns validated. The Knowledge layer is the next major elaboration target — clinical decision support, safety constraints, logic/reasoning, decision models, and outcome measurement.

---

## 1. Purpose

The Knowledge layer is where the self-describing property of the GenderSense architecture becomes most powerful. It explicitly models the clinical reasoning that governs patient care: eligibility rules, safety constraints, prescribing protocols, monitoring schedules, decision logic, and outcome definitions. These aren't documentation — they're evaluable, auditable, self-explaining computational artefacts that drive the system's behaviour.

The CDR exercise validated the data persistence and query patterns. The demonstrator validated process orchestration and governance audit. This work connects the two: rules evaluated against CDR data, producing deterministic, explainable results that inform pathway execution and clinician/patient decision-making.

### What this work must achieve

1. **Establish the evaluation architecture:** How rules defined in the SysML model are evaluated at runtime — what evaluates them, how inputs are derived, how results are produced.
2. **Elaborate the LogicEngine package:** Define the evaluation infrastructure, including the self-explanation requirement.
3. **Elaborate the DecisionModels package:** Define the decision table pattern and its relationship to constraints.
4. **Elaborate the OutcomeFramework package:** Define how outcomes are measured and how they feed back into pathway refinement.
5. **Design the integration points:** How the knowledge layer connects to the CDR (data source), pathways (consumer), governance (audit), and patient-facing interfaces (guidance).

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

### 3.2 The runtime evaluation target

Three credible options, not mutually exclusive:

**Option A: TypeScript constraint evaluator (generated from SysML)**

Extend the existing generation pipeline. A new generator reads `constraint def` blocks from the SysML model and produces TypeScript evaluation functions that take typed inputs, evaluate the boolean expression, and produce structured EvaluationResult objects with explanation traces.

Pros: Consistent with existing architecture. TypeScript is the project language. Generator pattern is proven. Runs natively in Temporal activities and SvelteKit endpoints.

Cons: Boolean expressions only — no forward/backward chaining, no inference. Fine for Tier 1 constraints but limited for complex reasoning.

**Option B: Embedded Prolog (Tau Prolog or SWI-Prolog WASM)**

A logic programming engine for rules that involve inference, chaining, and reasoning over relationships. Prolog naturally produces explanation traces (proof trees). Rules can be expressed declaratively and the engine handles evaluation order.

Pros: Natural fit for clinical reasoning. Self-explaining by design. Handles complex rule relationships (contraindication cascades, multi-factor eligibility). A Prolog-based system can answer "why" questions about its conclusions.

Cons: Different language/paradigm. Integration with TypeScript/Temporal requires a bridge. Tau Prolog is pure JS but limited; SWI-Prolog WASM is more capable but heavier. Developer unfamiliarity (though Ella has expressed interest).

**Option C: DMN engine for decision tables**

A Decision Model and Notation engine for structured decision tables. Decision tables are inherently self-documenting — the table shows all possible input combinations and their outcomes. Clinicians can read and validate them directly.

Pros: Clinician-readable. Deterministic. Standardised (OMG DMN). Natural fit for protocol selection, dosing decisions, risk stratification. Some DMN engines produce explanation output.

Cons: Limited to tabular decisions — not suitable for constraint evaluation or inference chains. Another technology to integrate.

**Proposed approach: A + B, with C deferred**

Start with **Option A** (generated TypeScript evaluator) for Tier 1 constraints. This extends the proven generator pattern and handles the existing constraint defs immediately. The generator produces functions that evaluate constraints and produce explanation traces.

Explore **Option B** (Prolog) for Tier 2 reasoning where inference chains, contraindication cascades, and "why" queries are needed. This is the more architecturally interesting work but can be developed alongside the TypeScript evaluator, not instead of it.

**Option C** (DMN) is deferred. Decision tables can be modelled as SysML constructs (the DecisionModels package) and evaluated by either the TypeScript evaluator or the Prolog engine. A dedicated DMN engine is an optimisation, not a necessity.

### 3.3 How inputs are derived from the CDR

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

### 3.4 Decision tables as SysML constructs

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

### 3.5 Outcome measurement

OutcomeFramework needs to define:
- **What outcomes are measured** (clinical targets achieved, monitoring adherence, patient satisfaction, adverse events)
- **When outcomes are measured** (at defined intervals, at pathway milestones, on discharge)
- **How outcomes are captured** (CDR compositions, self-assessment tools, clinician recording)
- **How outcomes feed back** (into LearningCycles, into constraint refinement, into pathway modification)

The outcome data is CDR data — captured as openEHR compositions via the same patterns validated in the exercise. The distinction is that OutcomeFramework defines which compositions constitute outcomes, at what measurement points, and against what criteria.

---

## 4. Proposed Work Breakdown

### Phase 1 — Evaluation architecture design

**Goal:** Establish the evaluation result shape, input derivation pattern, and explanation trace format. No code — this is design work in the SysML model and documentation.

| Step | Activity | Deliverable |
|---|---|---|
| 1.1 | Define EvaluationResult as a part def | Foundation::CommonTypes or Knowledge::LogicEngine |
| 1.2 | Define InputDerivation pattern | Knowledge::ClinicalDecisionSupport |
| 1.3 | Define ExplanationTrace structure | Knowledge::LogicEngine |
| 1.4 | Map existing constraint defs to input derivations | Knowledge::ClinicalDecisionSupport |
| 1.5 | Design the evaluation invocation pattern (how pathways call evaluations) | Architecture decision document |

### Phase 2 — LogicEngine elaboration

**Goal:** Flesh out the LogicEngine package with the evaluation infrastructure, including the three-tier stack.

| Step | Activity | Deliverable |
|---|---|---|
| 2.1 | Model Tier 1 evaluator (deterministic constraint evaluation) | LogicEngine part defs and use cases |
| 2.2 | Model Tier 2 evaluator (inference and reasoning) | LogicEngine part defs, Prolog exploration notes |
| 2.3 | Model Tier 3 interface (advisory, ML/LLM) | LogicEngine part defs (interface only) |
| 2.4 | Define the self-explanation API | LogicEngine structural model |

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

### Phase 5 — Generator exploration (optional, time-permitting)

**Goal:** Prototype the constraint-to-TypeScript generator.

| Step | Activity | Deliverable |
|---|---|---|
| 5.1 | Design generator output format | TypeScript evaluation function shape |
| 5.2 | Prototype generator for one constraint | Working generated evaluator |
| 5.3 | Evaluate Prolog integration feasibility | Tau Prolog spike |

---

## 5. Relationship to Existing Architecture

### 5.1 The knowledge layer evaluates; pathways consume

Pathways reference evaluations via metadata annotations (`@LogicRule`, `@DecisionTable`, `@SafetyConstraint`). The knowledge layer defines what those evaluations are and how they work. At runtime, Temporal activities invoke evaluations as part of pathway execution. Evaluation results flow back into the pathway (proceed/block) and into the CDR (audit record).

### 5.2 The CDR provides inputs; the knowledge layer queries them

Every constraint input is ultimately derived from CDR data via AQL. The input derivation mappings formalise what the constraint doc blocks already describe narratively. The evaluation infrastructure runs the AQL queries, derives the inputs, and feeds them to the evaluator.

### 5.3 Governance audits are batch evaluations

The governance audit pattern (validated in Phase D) is the same as point-of-care evaluation, just applied across a population rather than for a single patient. The same rules, the same inputs, the same explanation traces — but queried in bulk and aggregated into a report.

### 5.4 Patient-facing guidance derives from the same rules

When the architecture principle says "a change to a monitoring guideline updates the model, which regenerates the constraint logic, which changes both clinician alerts and patient-facing information simultaneously" — the knowledge layer is where that happens. The evaluation result, with its explanation trace, is the source for both the clinician's decision support alert and the patient's self-management guidance.

---

## 6. What This Intentionally Defers

- **Prolog implementation** — explored and evaluated, but not built until clinical rules demand inference capabilities beyond boolean constraints
- **DMN engine integration** — decision tables modelled in SysML; dedicated DMN engine is an optimisation
- **ML/LLM integration** — Tier 3 is interface-only; advisory capabilities depend on data volume and clinical validation
- **Cross-pathway rule sharing** — the hormone therapy constraints are pathway-specific; generalisation happens when a second pathway is modelled
- **External clinical knowledge sources** — NICE guidelines, BNF integration, drug interaction databases are integration concerns, not modelling concerns

---

## 7. Success Criteria

The knowledge layer elaboration is successful if:

1. **Every rule evaluation produces a structured, self-explaining result** that can be presented to clinicians, patients, and auditors
2. **The evaluation architecture connects CDR data to constraint evaluation** via a formalised input derivation pattern
3. **Decision tables are representable in the SysML model** and traceable to pathway decision points
4. **Outcome definitions exist for the hormone therapy pathway** with measurement points and feedback mechanisms
5. **The three-tier reasoning stack is concretely defined** with clear boundaries between deterministic evaluation, inference, and advisory intelligence
6. **A generator pathway exists** (even if not yet built) for producing evaluation code from the SysML model

---

*Plan prepared 8 March 2026 (Session 6). Companion to the Architecture Principles document, the CDR Exercise Summary, and the Hormone Therapy Initiation Modelling Plan.*
