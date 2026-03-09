# Validated Architectural Patterns — SysML v2 Model-Driven Architecture

**Date:** 8 March 2026 (created), 9 March 2026 (updated Session 12)
**Context:** Patterns validated across the Coffee Shop Exercise, Coffee Shop Demonstrator (Phases A–D), CDR Extension Exercise (Phases A–E), Hormone Therapy Pathway modelling, Knowledge Layer Phases 1–5.

**Companion documents:**
- `documentation/reference/gsl-sysml-v2-syntax-reference-v3.7-2026-03-09.md` — concise syntax lookup
- `documentation/guides/gsl-guide-repo-conventions.md` — file structure, generators, git practices

---

## 1. Two-Layer Action Flow Architecture

| Layer | Audience | Generator target |
|---|---|---|
| **Domain** | Governance reviewers, clinical leads | Mermaid pathway diagrams |
| **Orchestration** | Runtime execution | Temporal TypeScript workflows |

The domain layer describes the clinical process as a clinician would describe it. The orchestration layer describes how the system manages it — activity boundaries, signal waits, timeouts, state transitions.

Both are SysML `action def` blocks. The domain layer uses plain actions and doc blocks. The orchestration layer uses metadata annotations (`@TemporalWorkflow`, `@TemporalActivity`, `@TemporalSignal`, `@StateTransitionTrigger`) to mark generation targets.

**Validated:** Coffee Shop Demonstrator Phase B. Same model produces both governance documentation and executable code.

---

## 2. Metadata-Driven Generation

SysML v2 `metadata def` annotations replace fragile approaches (doc block parsing, auxiliary YAML) with first-class, tool-validated generator configuration.

### Pattern

1. Define metadata defs in a shared library (`Foundation::MetadataLibrary` or `TemporalMetadata`)
2. Import into the consuming package
3. Annotate model elements with `@MetadataName { attribute = "value"; }`
4. Generator reads annotations to produce target artefacts

### Verified metadata → generation mappings

| Metadata | Applied to | Generates |
|---|---|---|
| `@TemporalWorkflow` | `action def` | Temporal async workflow function |
| `@TemporalActivity` | `action` step | `await activityName(...)` call |
| `@TemporalSignal` | `action` step | `defineSignal()` + `setHandler()` + `await condition()` |
| `@StateTransitionTrigger` | `action` step | XState `tryTransition()` call (currently hand-written) |
| `@ClinicalReviewGate` | `action` step | Human-task wait point (design, not yet generated) |
| `@SafetyConstraint` | `action` step | Evaluation engine invocation (design, not yet generated) |
| `@OpenEhrArchetype` | `part def` | Model-CDR traceability (queryable via Automator) |
| `@OpenEhrTemplate` | `part def` | Template-level traceability |

### Clinical metadata library

Six clinical metadata defs in `Foundation::MetadataLibrary`: `@ClinicalReviewGate`, `@ConsentRequired`, `@AuditPoint`, `@LogicRule`, `@DecisionTable`, `@SafetyConstraint`. All verified on action steps via cross-package import (v3.2). Multiple annotations per step work.

---

## 3. XState in Temporal — Pure State Machine Enforcement

XState v5 pure transition functions run inside Temporal's deterministic V8 isolate:

```typescript
import { initialTransition, transition } from 'xstate';
let [machineState] = initialTransition(orderLifecycleMachine);

function tryTransition(currentSnapshot, eventType) {
  const [nextSnapshot] = transition(orderLifecycleMachine, currentSnapshot, { type: eventType });
  return nextSnapshot;
}
```

**Key validations (Phase C):**
- Temporal's webpack bundler resolves XState (v5.28.0, 161 KiB) into the V8 isolate
- `initialTransition()` and `transition()` are deterministic and survive Temporal replay
- XState rejects invalid transitions independently — defence in depth
- Temporal query handlers expose XState state to external clients (web UI reads current state without affecting workflow)
- Durable execution verified: killed worker mid-workflow, restarted, continued via web UI. Temporal replays from event history, XState produces same state deterministically.

### Signal chain

```
SysML:      @TemporalSignal { signalName = "baristaStarted"; }
Temporal:   defineSignal('baristaStarted')
Shared:     SIGNAL_BARISTA_STARTED = 'baristaStarted'
SvelteKit:  handle.signal('baristaStarted')
```

String identity across all layers. `@coffeeshop/shared` package holds constants. SysML model is the authoritative source.

---

## 4. openEHR CDR Integration via Metadata

SysML `part def` elements annotated with `@OpenEhrArchetype` and `@OpenEhrTemplate` provide machine-queryable traceability between the structural model and the CDR archetype layer.

```sysml
part def OrderRecord {
    @OpenEhrArchetype {
        archetypeId = "openEHR-EHR-OBSERVATION.order_record.v0";
        rmClass = "OBSERVATION";
    }
    attribute drinkName : DrinkName;     // at0005 | DV_CODED_TEXT
}
```

Per-element mapping uses inline `//` comments (machine metadata on attributes not supported — see syntax reference).

**Validated:** CDR Exercise Phase E. Cross-project import resolves. Hover tooltip shows metadata. Queryable via Syside Automator `evaluate_filter`.

---

## 5. Satisfy Traceability Chain

Requirements → Constraints → Runtime checks → Audit evidence.

```
Enterprise::Regulation          requirement def BloodMonitoringRequired
        ↓ (satisfy)
Knowledge::ConstraintLibrary    constraint bloodMonitoringCheck : BloodMonitoringIntervalConstraint
        ↓ (evaluation spec)
Knowledge::CDS                  part bloodMonitoringSpec : ConstraintEvaluationSpec
        ↓ (generated evaluator — Phase 5)
generated/constraint-evaluators.ts   evaluateBloodMonitoringInterval(inputs)
        ↓ (generated spec registry — Phase 5)
generated/constraint-specs.ts        constraintSpecs['BloodMonitoringIntervalConstraint']
        ↓ (runtime — not yet built)
Temporal activity               evaluationEngine.evaluate("BloodMonitoringIntervalConstraint", patient)
        ↓ (audit)
CDR / audit log                 EvaluationResult composition
```

**Validated:** `satisfy` relationships (v3.1). Evaluation spec pattern with `:>>` redefinition (v3.5). Generated evaluator functions and spec registry (Phase 5, Session 12). End-to-end runtime chain is designed but not yet built.

---

## 6. Evaluation Spec Pattern (`:>>` Redefinition)

A general structural template (part def) with concrete instances (part usages) that redefine attributes with specific values:

```sysml
part def ConstraintEvaluationSpec {
    attribute constraintName : String;
    attribute severity : Severity;
    part inputDerivations : InputDerivation[0..*];
}

part consentSpec : ConstraintEvaluationSpec {
    attribute :>> constraintName = "ConsentRecordedConstraint";
    attribute :>> severity = Severity::critical;
}
```

This pattern separates "what the rule is" (ConstraintLibrary) from "how to evaluate it" (CDS evaluation specs). Eight concrete specs map to all eight ConstraintLibrary constraints. Two DecisionTableEvaluationSpecs follow the same pattern for decision tables.

**Validated:** v3.5. String and enum literal defaults both work. Integer (v3.6) and boolean (v3.7) literal defaults also work. Input derivation detail is in doc blocks; nested `:>>` inside contained parts not yet tested.

---

## 7. Entity Lifecycle State Machines

Core domain entities have lifecycle `state def` blocks connected via `exhibit state`:

| Entity | States | Terminal |
|---|---|---|
| Episode | created → active → suspended → completed / cancelled | completed, cancelled |
| Prescription | drafted → authorised → dispensed → active → completed / cancelled | completed, cancelled |
| LabResult | requested → collected → resulted → reviewed → actioned / cancelled | actioned, cancelled |
| Referral | drafted → sent → acknowledged → referralAccepted / declined → completed / cancelled | declined, completed, cancelled |

State def specialisation (`:>`) works for extending base patterns with additional states and transitions. `exhibit state` works with specialised defs.

**Validated:** Four entity lifecycles (v3.2). Specialisation (v3.3).

---

## 8. Five-Layer Self-Knowledge Architecture

Designed in Knowledge Layer Phase 1. Structural definitions in the model. Layer 1 now has a generated runtime artefact (System Model Manifest, Phase 5).

| Layer | Question | Source | SysML structure | Runtime artefact |
|---|---|---|---|---|
| 1. Structural | "What am I?" | System Model Manifest (generated) | — | `generated/system-manifest.json` ✅ |
| 2. Operational | "What state am I in?" | Temporal, CDR, platform services | InputDerivation | Not yet built |
| 3. Goal-state | "What should I be?" | Requirements, constraints, outcomes | ConstraintEvaluationSpec | `generated/constraint-specs.ts` ✅ |
| 4. Gap analysis | "Where am I falling short?" | Layer 2 vs Layer 3 comparison | Deficit part def | Not yet built |
| 5. Remediation | "What would close the gap?" | Deterministic / compound / advisory | RemediationCategory enum | Not yet built |

Composite output: `SystemStateAssessment` part def. Computed on demand, not a separate data store.

See: `documentation/architecture/gsl-architecture-decision-knowledge-evaluation.md`

---

## 9. Generation Pipeline

### Demonstrator generators (Coffee Shop)

| Generator | Input | Output | Location |
|---|---|---|---|
| `gen_typescript_types.py` | Structural model | TypeScript interfaces + enums | `exercises/coffeeshop-demonstrator/generators/` |
| `gen_state_machines.py` | `state def` | XState v5 machines | `exercises/coffeeshop-demonstrator/generators/` |
| `gen_temporal_workflow.py` | Annotated orchestration `action def` | Temporal async workflow | `exercises/coffeeshop-demonstrator/generators/` |
| `gen_mermaid_pathway.py` | Domain `action def` | Mermaid diagrams | `exercises/coffeeshop-demonstrator/generators/` |

### Model-level generators

| Generator | Input | Output | Location |
|---|---|---|---|
| `gen_package_hierarchy.py` | All `.sysml` files | Multi-format hierarchy views (markdown, OPML, HTML, OmniOutliner) | `scripts/` |
| `gen_constraint_evaluator.py` | `constraint def` + `ConstraintEvaluationSpec` usages | 3 TypeScript files: types, evaluation functions, spec registry | `scripts/` |
| `gen_decision_table_evaluator.py` | `DecisionTableDef` + row usages | TypeScript lookup functions + evaluate wrappers | `scripts/` |
| `gen_system_manifest.py` | All `.sysml` files | JSON structural manifest (8 inventory sections) | `scripts/` |

**Validated (Phase 5, Session 12):** All three new generators parse the current model correctly and produce well-formed output. Constraint evaluator translates all eight boolean expressions to TypeScript. Decision table evaluator extracts 17 rows across 2 tables with correct input/output split. Manifest generator cross-checks against `gsl` package hierarchy (8 constraints, 8 requirements, 4 lifecycles, 10 outcomes, 2 tables, 13 metadata, 100 use cases).

### Generated output inventory

| File | Generator | Content |
|---|---|---|
| `generated/evaluation-types.ts` | `gen_constraint_evaluator.py` | EvaluationResult, Severity, InputDerivation, ConstraintEvaluationSpec |
| `generated/constraint-evaluators.ts` | `gen_constraint_evaluator.py` | 8 evaluation functions + function registry |
| `generated/constraint-specs.ts` | `gen_constraint_evaluator.py` | 8 constraint specs + 2 decision table specs |
| `generated/decision-table-evaluators.ts` | `gen_decision_table_evaluator.py` | 2 tables (9 + 8 rows), lookup functions, evaluate wrappers |
| `generated/system-manifest.json` | `gen_system_manifest.py` | Structural manifest: constraints, requirements, lifecycles, pathways, outcomes, tables, metadata, use cases |

### Key principles

- Generated files carry `DO NOT EDIT` headers with timestamp and source reference
- Current generators use regex text parsing (adequate for controlled formatting)
- Syside Automator (semantic model access) is the planned replacement — all 10 evaluation tests passed (v3.1)
- Regex generators serve as executable specifications for Automator migration: same input → same output
- Generation policy decisions (e.g. `ref` → full object vs ID-only) are generator config, not model concerns
- Generators fail loudly and degrade gracefully — unparseable expressions emit `TODO` placeholders, never broken output

### Future generators (designed, not built)

- Temporal workflow generator extension: emit `evaluationEngine.evaluate()` calls from `@LogicRule` / `@SafetyConstraint` metadata
- Composition builder generator: OPT XML → TypeScript CDR composition builders
- Outcome evaluator generator: `OutcomeDefinition` usages → TypeScript outcome evaluation functions
- Prolog rule generator: `constraint def` → Tau Prolog rules (contingent on Tier 2 adoption)

---

## 10. CDR Integration Patterns

Validated across CDR Exercise Phases A–E. See `gsl-cdr-exercise-summary-2026-03-08.md` for full details.

**Two data paths, one CDR:** Workflow-driven (Temporal activities commit compositions) and form-driven (SvelteKit endpoints commit directly) both produce the same structured, queryable data.

**Two views onto the same data:** Process view (Temporal workflow state) and entity view (AQL queries by archetype type) are complementary perspectives. No data duplication.

**Application-level join for governance:** Two AQL queries joined in TypeScript by EHR ID. Necessary because EHRbase 2.11.0 doesn't support complex AQL (NOT EXISTS, aggregation).

**Composition builder per template:** Dedicated builder function per template maps application values to canonical JSON. Hand-maintained for coffee shop; should be generated for clinical archetypes.

**EHRbase client as shared infrastructure:** TypeScript client module in shared package, consumed by both Temporal activities and SvelteKit endpoints. `getOrCreateEhr` pattern for idempotent EHR resolution.

---

## 11. Tau Prolog for Tier 2 Reasoning

Feasibility validated in Phase 5 spike (Session 12). 16/16 tests passed.

**What Tau Prolog is:** A pure JavaScript ISO Prolog implementation. Runs in any JS environment including Temporal's deterministic V8 isolate. 566 KiB bundle size.

**What it enables (beyond Tier 1 TypeScript):**

- **Compound deficit reasoning:** Given multiple Deficit records, reason about interactions (e.g. overdue bloods AND missing consent AND expiring prescription), priority ordering, and compound remediation. This is natural in Prolog but awkward in imperative code.
- **"Why not" explanation:** Negation as failure (`\+`) produces structured explanations listing every unmet prerequisite, not just the first failure.
- **Inference chains:** Forward and backward chaining over clinical rule relationships (contraindication cascades, multi-factor eligibility assessment).
- **Arithmetic evaluation:** Numeric comparison (`=<`, `>`, `is`) works for monitoring interval checks and threshold-based rules.

**Performance:** 2.40ms per eligibility query, 3.67ms per deficit enumeration (100 iterations). Well within Temporal activity time budgets.

**Temporal compatibility:** Pure JavaScript, no Node.js APIs. Same compatibility profile as XState (validated in Phase C demonstrator). Should run in Temporal's V8 isolate without issues.

**Adoption recommendation:** Conditional. Adopt for Tier 2 reasoning when clinical rules demand compound inference beyond Tier 1 boolean constraints. The current constraint library is fully served by generated TypeScript. Tier 2 becomes valuable as clinical pathway complexity grows — particularly for compound deficit reasoning in Layer 5 remediation and for contraindication cascade analysis.

**Rule generation path:** SysML constraint defs have a consistent shape (typed inputs, boolean expression, satisfy relationship). A generator could produce Prolog rules mechanically: each constraint becomes a rule, each input becomes a fact query, each negated prerequisite becomes a `why_not` rule.

See: `spikes/tau-prolog-spike/spike.mjs`

---

*Extracted from monolithic syntax reference 8 March 2026 (Session 8). Updated 9 March 2026 (Session 12: Phase 5 generators, Tau Prolog spike).*
