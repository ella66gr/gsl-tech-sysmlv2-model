# Knowledge Layer Elaboration — Phase 5 Implementation Plan

**Date:** 9 March 2026 (Session 12)
**Context:** Phase 5 of the Knowledge Layer Elaboration, as defined in the extended planning document. Phase 1 (Session 8) established the evaluation and self-knowledge data structures. Phase 2 (Session 9) established the LogicEngine component model. Phase 3 (Session 10) established the decision table representation pattern. Phase 4 (Session 11) elaborated the OutcomeFramework. Phase 5 explores code generation: prototyping generators that bridge the SysML model (representation layer) to executable TypeScript (execution layer).

**Parent plan:** `documentation/plans/gsl-plan-knowledge-layer-elaboration-2026-03-08-extended.md`
**Phase 1 plan:** `documentation/plans/gsl-plan-knowledge-layer-phase1-implementation-2026-03-08.md`
**Phase 2 plan:** `documentation/plans/gsl-plan-knowledge-layer-phase2-implementation-2026-03-09.md`
**Phase 3 plan:** `documentation/plans/gsl-plan-knowledge-layer-phase3-implementation-2026-03-09.md`
**Phase 4 plan:** `documentation/plans/gsl-plan-knowledge-layer-phase4-implementation-2026-03-09.md`
**Syntax reference:** `documentation/reference/gsl-sysml-v2-syntax-reference-v3.7-2026-03-09.md`
**Architecture decisions:** `documentation/architecture/gsl-architecture-decision-knowledge-evaluation.md`
**Validated patterns:** `documentation/architecture/gsl-validated-architectural-patterns.md`

---

## 1. Scope and Boundaries

### What Phase 5 delivers

Phase 5 shifts from SysML modelling to code generation prototyping. The Knowledge Layer now has comprehensive structural definitions (Phases 1–4): eight constraint evaluation specs, two decision table evaluation specs, ten outcome definitions, five self-knowledge layer components, and the full LogicEngine component model. Phase 5 asks: "given this model, what does the generated code look like?"

The extended plan defines five Phase 5 steps:

| Step | Activity | Deliverable |
|---|---|---|
| 5.1 | Design generator output format for constraint evaluators | TypeScript evaluation function shape |
| 5.2 | Prototype generator for one constraint | Working generated evaluator |
| 5.3 | Design generator output format for System Model Manifest | JSON/TypeScript manifest shape |
| 5.4 | Prototype manifest generator (Syside Automator or regex-based) | Working generated manifest from current model |
| 5.5 | Evaluate Prolog integration feasibility | Tau Prolog spike |

This plan elaborates these into a staged implementation with concrete deliverables at each stage.

### What Phase 5 delivers concretely

1. **Constraint evaluator generator** — a Python generator (`gen_constraint_evaluator.py`) that reads `constraint def` blocks from the ConstraintLibrary and `part consentSpec : ConstraintEvaluationSpec` usages from ClinicalDecisionSupport, and produces a TypeScript module exporting typed evaluation functions and a spec registry
2. **Decision table evaluator generator** — a Python generator (`gen_decision_table_evaluator.py`) that reads decision table row usages from DecisionModels and produces a TypeScript module exporting lookup functions
3. **System Model Manifest generator** — an extension to the existing `gen_package_hierarchy.py` (or a new `gen_system_manifest.py`) that produces a JSON manifest capturing the structural, constraint, pathway, entity lifecycle, and requirement inventories defined in the architecture decision document
4. **Tau Prolog feasibility spike** — a minimal TypeScript proof-of-concept loading Tau Prolog, defining a few clinical rules as Prolog facts/rules, and evaluating queries with explanation traces
5. **Generator design documentation** — capturing the output format decisions, generator architecture, and the relationship between regex-based parsing and the eventual Syside Automator migration

### What Phase 5 does NOT deliver

- **Production-ready generators** — these are prototypes that prove the generation pattern works against the current model. Production hardening is future work
- **Changes to the SysML model** — Phase 5 reads from the model; it does not modify it. If the model needs minor formatting adjustments to support reliable regex parsing, those changes are noted for a future session
- **Runtime evaluation engine** — the generators produce evaluation *functions*; the evaluation engine that invokes them at runtime (within Temporal activities) is a separate implementation concern
- **Temporal workflow generator extensions** — the existing `gen_temporal_workflow.py` needs extension to emit evaluation engine calls when it encounters `@LogicRule` or `@SafetyConstraint` metadata. This is noted as a future step, not a Phase 5 deliverable
- **CDR composition builder generators** — generating TypeScript composition builders from OPT XML depends on resolving the OPT generation blocker (Archetype Designer / Ocean Template Designer). Deferred
- **Syside Automator-based generators** — Phase 5 uses regex-based parsing, consistent with the existing generators. Automator migration is planned when the API stabilises (targeted Syside 1.0)

### Relationship to earlier phases

| Phase | Relationship to Phase 5 |
|---|---|
| **Phase 1 — Self-knowledge architecture** | Phase 1 defined EvaluationResult, InputDerivation, ConstraintEvaluationSpec, Deficit, SystemStateAssessment as part defs. Phase 5 generates TypeScript interfaces from these part defs and generates evaluation functions that produce EvaluationResult-shaped output. |
| **Phase 2 — LogicEngine component model** | Phase 2 defined the runtime components (ConstraintEvaluator, GoalProjector, GapAnalyser, etc.) as structural part defs describing responsibilities. Phase 5's generated evaluation functions are what the ConstraintEvaluator component would call at runtime. |
| **Phase 3 — DecisionModels** | Phase 3 modelled two decision tables (regimenSelection, stabilityAssessment) as SysML part usages with `:>>` redefined row values. Phase 5 generates TypeScript lookup functions from these table row definitions. |
| **Phase 4 — OutcomeFramework** | Phase 4 defined outcome definitions with embedded evaluation queries. Phase 5's manifest generator captures outcome definitions in the structural inventory. Outcome evaluator generation is a future extension following the same pattern as constraint evaluation. |
| **Coffee Shop Demonstrator** | Phase 5 generators follow the same architecture as the four validated demonstrator generators (`gen_typescript_types.py`, `gen_state_machines.py`, `gen_temporal_workflow.py`, `gen_mermaid_pathway.py`): Python scripts, regex-based SysML parsing, TypeScript output, `DO NOT EDIT` headers. |

### Relationship to existing generators

The existing generation pipeline (validated in the demonstrator) provides the template:

| Existing generator | Input | Output | Phase 5 parallel |
|---|---|---|---|
| `gen_typescript_types.py` | `part def`, `enum def` | TypeScript interfaces + enums | Phase 5 constraint/decision table generators produce similar TypeScript |
| `gen_state_machines.py` | `state def` | XState v5 machines | — |
| `gen_temporal_workflow.py` | `action def` + metadata | Temporal async workflows | Future: extend to emit evaluation calls |
| `gen_mermaid_pathway.py` | `action def` (domain) | Mermaid diagrams | — |
| `gen_package_hierarchy.py` | All `.sysml` | Package tree (markdown, OPML, HTML) | Phase 5 manifest generator extends this |

Phase 5 generators live in `scripts/` alongside `gen_package_hierarchy.py`, not in `exercises/coffeeshop-demonstrator/generators/`. They operate on the main model, not the exercise model.

### Files affected

| File | Expected changes |
|---|---|
| `scripts/gen_constraint_evaluator.py` | New — constraint evaluation function generator |
| `scripts/gen_decision_table_evaluator.py` | New — decision table lookup function generator |
| `scripts/gen_system_manifest.py` | New — System Model Manifest generator |
| `generated/constraint-evaluators.ts` | Generated — TypeScript evaluation functions |
| `generated/decision-table-evaluators.ts` | Generated — TypeScript decision table lookups |
| `generated/system-manifest.json` | Generated — JSON structural manifest |
| `spikes/tau-prolog-spike/` | New directory — Tau Prolog feasibility test |
| `documentation/architecture/gsl-architecture-decision-generator-design.md` | New — generator output format decisions |
| `documentation/reference/gsl-sysml-v2-syntax-reference-v3.8-*.md` | Updated if new syntax patterns discovered or generator-relevant findings recorded |
| `documentation/session-reports/gsl-session-report-2026-03-09-s12.md` | Session report |

---

## 2. Pre-flight Checks

| Check | Action | Status |
|---|---|---|
| 2.1 | Verify Phase 4 model changes committed to git (OutcomeFramework elaboration, 4 new enums in CommonTypes) | ☐ Ella to confirm |
| 2.2 | Run `gsl` to confirm hierarchy shows OutcomeFramework with 5 part defs, 4 use cases | ☐ Ella to confirm |
| 2.3 | Verify syntax reference has been renamed to v3.7 filename | ☐ Ella to confirm |
| 2.4 | Confirm `model/knowledge.sysml` parses clean in Syside | ☐ Ella to confirm |
| 2.5 | Confirm Python 3.10+ available (`python3 --version`) | ☐ Ella to confirm |
| 2.6 | Confirm Node.js available for Tau Prolog spike (`node --version`) | ☐ Ella to confirm |
| 2.7 | Review existing `gen_package_hierarchy.py` regex patterns for reuse in new generators | ☐ Part of Stage 1 analysis |

---

## 3. Generator Architecture Analysis

### 3.1 What the generators need to parse

Each generator reads different elements from the SysML model. The parsing requirements determine the regex patterns needed.

**Constraint evaluator generator — reads from two packages:**

From `Knowledge::ConstraintLibrary` (in `model/knowledge.sysml`):
- `constraint def` blocks: name, input attributes (name + type), `doc` block (describes the boolean expression), `satisfy` relationships
- Example: `constraint def BloodMonitoringIntervalConstraint { ... }`

From `Knowledge::ClinicalDecisionSupport` (in `model/knowledge.sysml`):
- `part specName : ConstraintEvaluationSpec { ... }` usages: the `:>>` redefined attributes (constraintName, requirementName, severity), plus the doc block describing input derivations
- Example: `part bloodMonitoringSpec : ConstraintEvaluationSpec { attribute :>> constraintName = "BloodMonitoringIntervalConstraint"; ... }`

**Decision table evaluator generator — reads from one package:**

From `Knowledge::DecisionModels` (in `model/knowledge.sysml`):
- `part def` for the table structure (column names and types)
- `part` usages for each row (`:>>` redefined attribute values)
- Example: row usages like `part row1 : RegimenSelectionRow { attribute :>> baselineTestosterone = HormoneLevel::low; ... }`

**System Model Manifest generator — reads from all files:**

From all `.sysml` files:
- Package hierarchy (already extracted by `gen_package_hierarchy.py`)
- `constraint def` inventory (name, inputs, satisfy targets)
- `action def` inventory (pathway names, step counts, metadata annotations)
- `state def` inventory (entity names, states, transitions)
- `requirement def` inventory (names, descriptions)
- `metadata def` inventory (names, attributes)
- `use case def` inventory (names)
- `part def` inventory (names, attributes)

### 3.2 Regex parsing strategy

The existing generators use a consistent approach:
1. Read the entire `.sysml` file as a string
2. Use regex patterns to extract element blocks (handling nested braces)
3. Parse attributes, names, and relationships from within each block
4. Produce structured Python dicts
5. Generate TypeScript (or other output) from the dicts

For Phase 5, the key parsing patterns are:

| Pattern | Regex shape | Complexity |
|---|---|---|
| `constraint def Name { ... }` | `r"constraint\s+def\s+(\w+)\s*\{([^}]*(?:\{[^}]*\}[^}]*)*)\}"` | Medium — same as `part def` |
| `attribute name : Type;` | `r"attribute\s+(\w+)\s*:\s*(\w+(?:::\w+)?)\s*;"` | Low — existing pattern |
| `attribute :>> name = "value";` | `r'attribute\s+:>>\s+(\w+)\s*=\s*"([^"]+)"\s*;'` (string) | Low — new for Phase 5 |
| `attribute :>> name = Enum::value;` | `r"attribute\s+:>>\s+(\w+)\s*=\s*(\w+)::(\w+)\s*;"` (enum) | Low — new for Phase 5 |
| `attribute :>> name = 42;` | `r"attribute\s+:>>\s+(\w+)\s*=\s*(\d+)\s*;"` (integer) | Low — new for Phase 5 |
| `satisfy requirement` | `r"satisfy\s+(\w+(?:::\w+(?:::\w+)*)?)\s*;"` | Low — existing |
| `part name : TypeDef { ... }` | `r"part\s+(\w+)\s*:\s*(\w+)\s*\{([^}]*(?:\{[^}]*\}[^}]*)*)\}"` | Medium — existing |
| `@MetadataName { ... }` | `r"@(\w+)\s*\{([^}]*)\}"` | Low — existing |
| `doc /\* ... \*/` | `r"doc\s*/\*([^*]*(?:\*(?!/)[^*]*)*)\*/"` | Medium — multiline |

The nested brace pattern (`[^}]*(?:\{[^}]*\}[^}]*)*`) handles one level of nesting. This is sufficient for all current model elements since constraint and part usages do not contain deeply nested blocks.

### 3.3 Generated output architecture

All generated files follow the established convention:
- `DO NOT EDIT` header with generation timestamp and source file reference
- TypeScript with strict typing
- No runtime dependencies beyond the project's own type definitions
- Self-contained — each generated module can be imported independently

### 3.4 Regex vs Automator decision

Phase 5 uses regex-based parsing because:
1. The existing generators use regex and the patterns are proven
2. The model's formatting is controlled (we write it ourselves, with consistent style)
3. Syside Automator API stability is targeted for 1.0 (not yet released as of Syside 0.8.5)
4. Regex generators serve as executable specifications for the Automator migration — if the regex generator produces X from input Y, the Automator generator must produce the same X

The Automator migration path is: (a) build regex generators that work, (b) build Automator equivalents, (c) diff outputs to verify, (d) retire regex generators. Phase 5 delivers (a).

---

## 4. Staged Implementation

### Stage 1 — Constraint evaluator generator design and output format

**Goal:** Define the TypeScript output shape for generated constraint evaluators and document the design decisions. This stage is design only — no code is written yet.

#### Step 1.1 — Define the generated evaluation function signature

Each constraint def in ConstraintLibrary becomes a TypeScript evaluation function. The function takes typed inputs and produces an `EvaluationResult`.

**Design target — generated evaluation function shape:**

```typescript
// ============================================================
// DO NOT EDIT — Generated from GenderSense SysML v2 model
// Source: model/knowledge.sysml (Knowledge::ConstraintLibrary)
// Generated: 2026-03-09T22:30:00Z
// ============================================================

import type { EvaluationResult, EvaluationOutcome, Severity } from './types';

/**
 * BloodMonitoringIntervalConstraint
 *
 * Satisfies: BloodMonitoringRequired (Enterprise::Regulation)
 * Severity: warning
 *
 * Checks whether monitoring bloods have been completed within
 * the required interval.
 */
export function evaluateBloodMonitoringInterval(
  inputs: {
    weeksSinceLastTest: number;
    requiredIntervalWeeks: number;
  }
): EvaluationResult {
  const outcome: EvaluationOutcome =
    inputs.weeksSinceLastTest <= inputs.requiredIntervalWeeks
      ? 'pass'
      : 'fail';

  return {
    constraintName: 'BloodMonitoringIntervalConstraint',
    outcome,
    severity: 'warning',
    satisfies: 'BloodMonitoringRequired',
    evaluatedInputs: [
      {
        name: 'weeksSinceLastTest',
        value: inputs.weeksSinceLastTest,
        source: 'derived',  // populated by evaluation engine at runtime
      },
      {
        name: 'requiredIntervalWeeks',
        value: inputs.requiredIntervalWeeks,
        source: 'derived',
      },
    ],
    expression: 'weeksSinceLastTest <= requiredIntervalWeeks',
    explanation: outcome === 'pass'
      ? `Monitoring bloods are within the required interval (${inputs.weeksSinceLastTest} weeks since last test, required every ${inputs.requiredIntervalWeeks} weeks).`
      : `Monitoring bloods are overdue (${inputs.weeksSinceLastTest} weeks since last test, required every ${inputs.requiredIntervalWeeks} weeks).`,
    timestamp: new Date().toISOString(),
  };
}
```

#### Step 1.2 — Define the evaluation spec registry shape

The generated spec registry is a TypeScript module exporting a map from constraint name to spec metadata. The evaluation engine looks up specs by name.

**Design target — generated spec registry shape:**

```typescript
// ============================================================
// DO NOT EDIT — Generated from GenderSense SysML v2 model
// Source: model/knowledge.sysml (Knowledge::ClinicalDecisionSupport)
// Generated: 2026-03-09T22:30:00Z
// ============================================================

import type { ConstraintEvaluationSpec, DataSourceType, Severity } from './types';

export const constraintSpecs: Record<string, ConstraintEvaluationSpec> = {
  ConsentRecordedConstraint: {
    constraintName: 'ConsentRecordedConstraint',
    requirementName: 'ConsentBeforeTreatment',
    severity: 'critical',
    inputDerivations: [
      // Input derivation detail is in doc blocks — not yet machine-parseable.
      // For now, this is a placeholder. When InputDerivation part usages
      // are elaborated with nested :>> (pending syntax test), the generator
      // will populate these fully.
    ],
  },
  BloodMonitoringIntervalConstraint: {
    constraintName: 'BloodMonitoringIntervalConstraint',
    requirementName: 'BloodMonitoringRequired',
    severity: 'warning',
    inputDerivations: [],
  },
  // ... one entry per ConstraintEvaluationSpec part usage in CDS
};
```

#### Step 1.3 — Define the shared types module shape

Generated types correspond to EvaluationResult, InputDerivation, and related part defs from the model.

**Design target — generated types shape:**

```typescript
// ============================================================
// DO NOT EDIT — Generated from GenderSense SysML v2 model
// Source: model/knowledge.sysml, model/foundation.sysml
// Generated: 2026-03-09T22:30:00Z
// ============================================================

export type EvaluationOutcome = 'pass' | 'fail' | 'indeterminate';
export type Severity = 'critical' | 'warning' | 'informational';
export type DataSourceType = 'cdr' | 'temporal' | 'platformService' | 'entityLifecycle';

export interface EvaluatedInput {
  name: string;
  value: unknown;
  source: string;
}

export interface EvaluationResult {
  constraintName: string;
  outcome: EvaluationOutcome;
  severity: Severity;
  satisfies: string;
  evaluatedInputs: EvaluatedInput[];
  expression: string;
  explanation: string;
  timestamp: string;
}

export interface ConstraintEvaluationSpec {
  constraintName: string;
  requirementName: string;
  severity: Severity;
  inputDerivations: InputDerivation[];
}

export interface InputDerivation {
  inputName: string;
  sourceType: DataSourceType;
  query: string;
  computation: string;
  fallbackOutcome: EvaluationOutcome;
  fallbackReason: string;
}
```

#### Step 1.4 — Document design decisions

**Decision 1: Boolean expression source.** The boolean expression for each constraint is currently described in the constraint def's doc block as natural language and as a `constraint` expression. The regex generator extracts the constraint expression if it follows the pattern `constraint expression { ... }` and translates it to TypeScript. If the expression is complex or not parseable, the generator emits a TODO placeholder and a comment referencing the doc block.

**Decision 2: Input derivation detail.** InputDerivation part usages in the current model have their detail in doc blocks rather than as nested `:>>` redefinitions (nested `:>>` is an untested syntax pattern). The generated spec registry therefore has empty `inputDerivations` arrays for now. The evaluation engine will need to populate these from configuration or from a future version of the generator that parses doc blocks or consumes Automator output. This is an acknowledged gap.

**Decision 3: Explanation generation.** Generated evaluation functions produce explanation strings by interpolating input values into template strings. The template is derived from the constraint's doc block description. For Phase 5, explanations are hand-authored in the generator template for the prototype constraint, with the intent to derive them automatically once the pattern is proven.

**Decision 4: One module per concern.** The generator produces three files: `types.ts` (shared type definitions), `constraint-evaluators.ts` (evaluation functions), and `constraint-specs.ts` (spec registry). This mirrors the separation of representation concerns in the model (CommonTypes, ConstraintLibrary, CDS).

**Acceptance criteria:**
- Output format documented in architecture decision document
- Design reviewed against EvaluationResult, ConstraintEvaluationSpec, and InputDerivation part defs from Phase 1
- Generated types are structurally consistent with the SysML part def attributes (verified by hand comparison)

---

### Stage 2 — Constraint evaluator generator implementation

**Goal:** Build the Python generator that reads ConstraintLibrary and CDS from `model/knowledge.sysml` and produces the three TypeScript files defined in Stage 1.

**File:** `scripts/gen_constraint_evaluator.py`

#### Step 2.1 — Build the constraint def parser

Parse `constraint def` blocks from `Knowledge::ConstraintLibrary`. For each constraint, extract:
- Name (e.g. `BloodMonitoringIntervalConstraint`)
- Input attributes (names and types)
- Doc block text
- `constraint` expression (if present)
- `satisfy` target (requirement name)

**Known parsing challenges:**
- The `constraint` keyword inside a `constraint def` body introduces the boolean expression. This nests, so the regex must handle `constraint def Name { ... constraint expression { ... } ... }`.
- `satisfy` references may be qualified names (e.g. `satisfy Enterprise::Regulation::BloodMonitoringRequired`).
- Some constraint defs may have `private import` lines that should be skipped.

**Test with:** Parse all eight constraint defs in ConstraintLibrary, print extracted data, verify against model by hand.

#### Step 2.2 — Build the evaluation spec parser

Parse `part specName : ConstraintEvaluationSpec { ... }` usages from `Knowledge::ClinicalDecisionSupport`. For each spec, extract:
- Usage name (e.g. `consentSpec`)
- `:>>` redefined attributes: `constraintName`, `requirementName`, `severity`
- Doc block text

**Test with:** Parse all eight constraint evaluation specs, print extracted data, verify against model.

#### Step 2.3 — Build the TypeScript emitter

From the parsed data, produce:
1. `generated/evaluation-types.ts` — type definitions from EvaluationResult, InputDerivation, and enum types
2. `generated/constraint-evaluators.ts` — one evaluation function per constraint def
3. `generated/constraint-specs.ts` — spec registry mapping constraint names to spec objects

The emitter uses string templates. Each evaluation function follows the pattern from Step 1.1. The boolean expression translation handles the common patterns:
- `a <= b` → `inputs.a <= inputs.b`
- `a == true` or just `a` → `inputs.a === true`
- `a && b` → `inputs.a && inputs.b`
- Compound expressions → parenthesised TypeScript

For constraints where the expression cannot be reliably parsed, emit:

```typescript
// TODO: Complex expression — implement manually from doc block:
// "Checks that all baseline bloods have been resulted and reviewed
//  by an appropriately qualified clinician."
const outcome: EvaluationOutcome = 'indeterminate';
```

#### Step 2.4 — Run the generator and verify output

```bash
cd ~/Developer/gsl-tech/gsl-sysml-model
python3 scripts/gen_constraint_evaluator.py
```

Verify:
- Three TypeScript files produced in `generated/`
- Eight evaluation functions (one per constraint)
- Eight spec registry entries (one per ConstraintEvaluationSpec usage)
- TypeScript compiles clean (if `tsc` is available; otherwise, manual review)
- `DO NOT EDIT` headers present with correct timestamps
- Evaluation functions produce correct EvaluationResult shape

**Git checkpoint:** `Add constraint evaluator generator (Phase 5, Stage 2)`

---

### Stage 3 — Decision table evaluator generator

**Goal:** Build a generator that reads decision table rows from DecisionModels and produces TypeScript lookup functions.

**File:** `scripts/gen_decision_table_evaluator.py`

#### Step 3.1 — Analyse the decision table model structure

The two decision tables in `Knowledge::DecisionModels` are modelled as:
- A `part def` defining the table's row structure (e.g. `part def RegimenSelectionRow`)
- Multiple `part` usages with `:>>` redefinitions representing individual rows (e.g. `part row1 : RegimenSelectionRow { attribute :>> baselineTestosterone = HormoneLevel::low; ... }`)
- A `DecisionTableEvaluationSpec` usage in CDS binding the table to its evaluation parameters

The generator needs to:
1. Identify which `part def` elements represent decision table row structures (heuristic: they are contained within the `DecisionModels` package)
2. Parse all `part` usages of that type
3. Extract `:>>` redefined attribute values (strings, enums, integers)
4. Determine which attributes are inputs and which are outputs (by convention: input attributes precede a comment separator `// --- Outputs ---` or by matching against the evaluation spec)

#### Step 3.2 — Design the generated lookup function shape

```typescript
// ============================================================
// DO NOT EDIT — Generated from GenderSense SysML v2 model
// Source: model/knowledge.sysml (Knowledge::DecisionModels)
// Generated: 2026-03-09T22:30:00Z
// ============================================================

import type { HormoneLevel, PatientPreference, Contraindication,
              Medication, Route, StartingDose } from './types';

export interface RegimenSelectionInput {
  baselineTestosterone: HormoneLevel;
  baselineOestradiol: HormoneLevel;
  patientPreference: PatientPreference;
  contraindications: Contraindication;
}

export interface RegimenSelectionOutput {
  medication: Medication;
  route: Route;
  startingDose: StartingDose;
}

export type RegimenSelectionRow = RegimenSelectionInput & RegimenSelectionOutput;

const regimenSelectionRows: RegimenSelectionRow[] = [
  // Row 1: low T, low E2, oestrogen preferred, no contraindications
  {
    baselineTestosterone: 'low',
    baselineOestradiol: 'low',
    patientPreference: 'oestrogen',
    contraindications: 'none',
    medication: 'estradiolValerate',
    route: 'transdermal',
    startingDose: 'standard',
  },
  // ... one entry per row usage
];

/**
 * Look up the recommended regimen based on input conditions.
 * Returns the first matching row, or null if no match.
 */
export function lookupRegimenSelection(
  input: RegimenSelectionInput
): RegimenSelectionOutput | null {
  const match = regimenSelectionRows.find(
    row =>
      row.baselineTestosterone === input.baselineTestosterone &&
      row.baselineOestradiol === input.baselineOestradiol &&
      row.patientPreference === input.patientPreference &&
      row.contraindications === input.contraindications
  );
  return match
    ? {
        medication: match.medication,
        route: match.route,
        startingDose: match.startingDose,
      }
    : null;
}
```

#### Step 3.3 — Implement the generator

Build `gen_decision_table_evaluator.py` following the same structure as Stage 2:
1. Parse `part def` row structures from DecisionModels
2. Parse `part` row usages with `:>>` redefinitions
3. Determine input/output split (by convention or marker comment)
4. Emit TypeScript row data arrays and lookup functions

**Parsing note:** The `:>>` parser from Stage 2 is reused here. The additional challenge is distinguishing enum literal values (`HormoneLevel::low`) from string values (`"estradiolValerate"`) and integer values (`12`). The existing patterns from Stage 2 Step 2.2 handle this.

#### Step 3.4 — Run and verify

```bash
python3 scripts/gen_decision_table_evaluator.py
```

Verify:
- TypeScript file produced with both regimenSelection and stabilityAssessment tables
- Correct row counts (9 rows for regimenSelection, 8 for stabilityAssessment — verify against model)
- Lookup functions return correct matches for known input combinations
- `DO NOT EDIT` headers present

**Git checkpoint:** `Add decision table evaluator generator (Phase 5, Stage 3)`

---

### Stage 4 — System Model Manifest generator

**Goal:** Build a generator that produces a comprehensive JSON manifest from the entire SysML model, as specified in the architecture decision document (Section 2).

**File:** `scripts/gen_system_manifest.py`

#### Step 4.1 — Analyse what already exists

`gen_package_hierarchy.py` already extracts:
- Package names and hierarchy (parent-child relationships)
- Doc block first sentences (used as descriptions)
- Element counts by type (parts, enums, constraints, use cases, states, metadata)
- Source file and line numbers

The manifest generator extends this extraction to provide deeper element-level detail.

**Design decision: extend or new file?**

Option A: Extend `gen_package_hierarchy.py` with a `--manifest` flag. Pro: reuses existing parsing code. Con: makes the hierarchy generator more complex.

Option B: New `gen_system_manifest.py` that imports shared parsing utilities from `gen_package_hierarchy.py`. Pro: clean separation. Con: requires extracting shared code.

Option C: New `gen_system_manifest.py` with its own parser, reusing regex patterns but not code. Pro: independent. Con: some duplication.

**Recommended: Option C for Phase 5.** The manifest parser needs different extraction depth (element names and attributes, not just counts). Duplication is acceptable for a prototype; shared utilities can be extracted when both generators are stable.

#### Step 4.2 — Define the manifest JSON schema

Following the architecture decision document, Section 2:

```json
{
  "modelVersion": "2026-03-09",
  "generatedAt": "2026-03-09T22:30:00Z",
  "generator": "gen_system_manifest.py",
  "sourceFiles": [
    "model/enterprise.sysml",
    "model/foundation.sysml",
    "model/knowledge.sysml",
    "model/operations.sysml",
    "model/platform.sysml",
    "model/service-delivery.sysml",
    "libraries/temporal-metadata/temporal-metadata.sysml"
  ],

  "packages": {
    "count": 64,
    "hierarchy": [
      {
        "name": "Enterprise",
        "description": "Defines the organisational, regulatory, strategic, and risk context.",
        "children": [
          { "name": "Organisation", "description": "...", "children": [] },
          { "name": "Regulation", "description": "...", "children": [],
            "elements": { "useCases": 4, "requirements": 8 } }
        ]
      }
    ]
  },

  "constraints": {
    "count": 8,
    "items": [
      {
        "name": "BloodMonitoringIntervalConstraint",
        "package": "Knowledge::ConstraintLibrary",
        "inputs": [
          { "name": "weeksSinceLastTest", "type": "Integer" },
          { "name": "requiredIntervalWeeks", "type": "Integer" }
        ],
        "satisfies": "BloodMonitoringRequired",
        "evaluationSpec": "bloodMonitoringSpec",
        "severity": "warning"
      }
    ]
  },

  "entityLifecycles": {
    "count": 4,
    "items": [
      {
        "name": "EpisodeLifecycle",
        "package": "ServiceDelivery::ClinicalEntities",
        "states": ["created", "active", "suspended", "completed", "cancelled"],
        "terminalStates": ["completed", "cancelled"]
      }
    ]
  },

  "requirements": {
    "count": 8,
    "items": [
      {
        "name": "BloodMonitoringRequired",
        "package": "Enterprise::Regulation",
        "description": "Every patient must have monitoring bloods within the defined interval."
      }
    ]
  },

  "pathways": {
    "count": 2,
    "items": [
      {
        "name": "HormoneTherapyInitiationDomain",
        "package": "ServiceDelivery::ClinicalPathways::HormoneTherapy",
        "type": "domain",
        "stepCount": 14,
        "metadataAnnotations": ["@LogicRule", "@DecisionTable", "@SafetyConstraint", "@ClinicalReviewGate"]
      }
    ]
  },

  "outcomes": {
    "count": 10,
    "items": [
      {
        "name": "oestradiolTarget",
        "package": "Knowledge::OutcomeFramework",
        "outcomeName": "OestradiolTherapeuticRange",
        "category": "clinical",
        "targetOperator": "within",
        "targetValue": "400",
        "targetUpperBound": "600"
      }
    ]
  },

  "metadata": {
    "count": 13,
    "items": [
      {
        "name": "TemporalWorkflow",
        "package": "TemporalMetadata",
        "attributes": ["workflowName"]
      }
    ]
  },

  "useCases": {
    "count": 0,
    "items": []
  }
}
```

**Note:** The `useCases` section captures the total count and names. Detailed use case content (actors, included use cases) is not extracted in Phase 5 because advanced use case syntax (`include use case`, `actor`) is not yet tested in the model.

#### Step 4.3 — Implement the manifest generator

Build `gen_system_manifest.py` with the following extraction passes:

1. **Pass 1 — Package hierarchy:** Reuse the nesting/indentation logic from `gen_package_hierarchy.py`. Build a tree of package objects with children.
2. **Pass 2 — Constraint inventory:** Parse `constraint def` blocks from Knowledge::ConstraintLibrary. For each, extract name, inputs, satisfy target. Cross-reference with ConstraintEvaluationSpec usages in CDS to attach severity and spec name.
3. **Pass 3 — Entity lifecycle inventory:** Parse `state def` blocks from ServiceDelivery::ClinicalEntities. For each, extract name, states, transitions, terminal states (reuse logic from `gen_state_machines.py`).
4. **Pass 4 — Requirement inventory:** Parse `requirement def` blocks from Enterprise::Regulation. For each, extract name and doc block description.
5. **Pass 5 — Pathway inventory:** Parse `action def` blocks from ServiceDelivery::ClinicalPathways. For each, extract name, count action steps, list metadata annotations found.
6. **Pass 6 — Outcome inventory:** Parse `part` usages of type `OutcomeDefinition` from Knowledge::OutcomeFramework. For each, extract `:>>` values.
7. **Pass 7 — Metadata inventory:** Parse `metadata def` blocks from Foundation::MetadataLibrary and TemporalMetadata. For each, extract name and attribute names.
8. **Assemble and emit:** Combine all passes into the JSON structure and write to `generated/system-manifest.json`.

#### Step 4.4 — Run and verify

```bash
python3 scripts/gen_system_manifest.py
```

Verify:
- JSON is valid (parseable by `python3 -m json.tool`)
- Package count matches `gsl` output (64 packages)
- Constraint count matches (8)
- Entity lifecycle count matches (4)
- Requirement count matches (8)
- Outcome definition count matches (10)
- Pathway inventory captures both domain and orchestration action defs
- Metadata count matches (9 in MetadataLibrary + 4 in TemporalMetadata = 13)

**Git checkpoint:** `Add System Model Manifest generator (Phase 5, Stage 4)`

---

### Stage 5 — Tau Prolog feasibility spike

**Goal:** Determine whether Tau Prolog (a pure JavaScript Prolog implementation) is viable for Tier 2 inference reasoning within the GenderSense architecture. This is an exploratory spike, not production code.

**Directory:** `spikes/tau-prolog-spike/`

#### Step 5.1 — Setup

```bash
mkdir -p spikes/tau-prolog-spike
cd spikes/tau-prolog-spike
npm init -y
npm install tau-prolog
```

Create `spike.ts` (or `spike.js` if TypeScript setup is too heavy for a spike).

#### Step 5.2 — Define test rules

Model a subset of the GenderSense clinical rules as Prolog facts and rules:

```prolog
% Facts about a patient (normally derived from CDR queries)
patient(patient_001).
has_consent(patient_001).
has_baseline_bloods(patient_001).
weeks_since_last_test(patient_001, 14).
required_interval(patient_001, 12).

% Eligibility rule
eligible_for_hormone_therapy(P) :-
    patient(P),
    has_consent(P),
    has_baseline_bloods(P).

% Blood monitoring check
monitoring_overdue(P) :-
    patient(P),
    weeks_since_last_test(P, Weeks),
    required_interval(P, Required),
    Weeks > Required.

% Compound deficit reasoning (Tier 2 value)
compound_risk(P) :-
    monitoring_overdue(P),
    prescription_expiring(P).

% Explanation support
why_eligible(P, Reason) :-
    has_consent(P),
    has_baseline_bloods(P),
    Reason = 'Consent recorded and baseline bloods reviewed'.

why_not_eligible(P, 'Missing consent') :-
    patient(P),
    \+ has_consent(P).

why_not_eligible(P, 'Missing baseline bloods') :-
    patient(P),
    \+ has_baseline_bloods(P).
```

#### Step 5.3 — Query from TypeScript

```typescript
import pl from 'tau-prolog';

const session = pl.create();

// Load the program
session.consult(prologProgram);

// Query: Is patient_001 eligible?
session.query('eligible_for_hormone_therapy(patient_001).');
session.answer(answer => {
  console.log('Eligible:', pl.format_answer(answer));
});

// Query: Why is patient_001 eligible?
session.query('why_eligible(patient_001, Reason).');
session.answer(answer => {
  console.log('Reason:', pl.format_answer(answer));
});

// Query: Is monitoring overdue?
session.query('monitoring_overdue(patient_001).');
session.answer(answer => {
  console.log('Monitoring overdue:', pl.format_answer(answer));
});

// Query: Compound risk?
session.query('compound_risk(patient_001).');
session.answer(answer => {
  console.log('Compound risk:', pl.format_answer(answer));
});
```

#### Step 5.4 — Evaluate feasibility criteria

| Criterion | Question | Pass/Fail |
|---|---|---|
| **Loads and runs** | Does Tau Prolog load the program and answer queries? | ☐ |
| **Negation as failure** | Does `\+ has_consent(P)` work for "why not eligible" queries? | ☐ |
| **Arithmetic comparison** | Does `Weeks > Required` work with numeric comparison? | ☐ |
| **Multiple answers** | Can we enumerate all reasons for non-eligibility? | ☐ |
| **Performance** | Is query response time < 10ms for individual patient queries? | ☐ |
| **Explanation traces** | Can we extract proof steps (which rules fired in what order)? | ☐ |
| **Temporal compatibility** | Can Tau Prolog run inside a Temporal V8 isolate (no Node.js APIs required)? | ☐ Theoretical assessment |
| **Bundle size** | What is the Tau Prolog module size? Is it reasonable for a Temporal worker bundle? | ☐ |
| **Rule generation** | Could a generator produce Prolog rules from SysML constraint defs? | ☐ Design assessment |

#### Step 5.5 — Document findings

Write a spike summary covering:
- What worked, what didn't
- Performance characteristics
- Explanation trace quality
- Temporal compatibility assessment
- Recommendation: adopt / defer / reject for Tier 2 reasoning

**Git checkpoint:** `Add Tau Prolog feasibility spike (Phase 5, Stage 5)`

---

### Stage 6 — Documentation, verification, and session close

#### Step 6.1 — Generator design architecture decision document

Write `documentation/architecture/gsl-architecture-decision-generator-design.md` covering:
- Generator output format decisions (from Stage 1)
- Regex vs Automator strategy and migration path
- Generated file inventory and their roles
- The relationship between generated evaluation functions and the LogicEngine component model
- The System Model Manifest's relationship to the self-knowledge architecture
- Tau Prolog findings and Tier 2 recommendation
- Future generator targets (composition builders, Temporal workflow extensions)

#### Step 6.2 — Validated architectural patterns update

Update `documentation/architecture/gsl-validated-architectural-patterns.md` Section 9 (Generation Pipeline) with:
- Constraint evaluator generator in the generators table
- Decision table evaluator generator in the generators table
- System Model Manifest generator in the generators table
- Updated "Future generators" section to reflect Phase 5 progress

#### Step 6.3 — Syntax reference update

If Phase 5 reveals any new syntax patterns or parsing-relevant findings (e.g. consistent formatting patterns that generators depend on), update the syntax reference. Phase 5 is read-only against the model, so no new *SysML syntax* patterns are expected. However, the reference may benefit from a new section documenting "generator-relevant formatting conventions" — consistent patterns that generators rely on.

**Decision criterion for v3.8:** Only produce v3.8 if there are genuinely new verified syntax findings. Generator formatting conventions are documented in the generator design architecture decision document, not the syntax reference.

#### Step 6.4 — Session report

Write session report covering:
- Stages completed and outcomes
- Generator output verification results
- Tau Prolog spike findings
- Design decisions made
- Repository state after session
- Recommended next steps

#### Step 6.5 — Git final commit

Stage and commit all remaining changes. Message: `Complete Knowledge Layer Phase 5: Generator exploration`

---

## 5. Execution Order and Dependencies

```
Pre-flight checks (Stage 0)
    │
    ▼
Stage 1: Constraint evaluator design        ← no code dependencies
    │   (output format, type definitions,       (design stage only)
    │    architecture decisions)
    │
    ▼
Stage 2: Constraint evaluator generator      ← depends on Stage 1
    │   (Python generator → TypeScript           (implements the design)
    │    evaluation functions + spec registry)
    │
    ▼
Stage 3: Decision table evaluator generator  ← depends on Stage 2
    │   (Python generator → TypeScript           (reuses :>> parsing patterns)
    │    table lookup functions)
    │
    ▼
Stage 4: System Model Manifest generator     ← independent of Stages 2–3
    │   (Python generator → JSON manifest)       (reuses regex patterns, different extraction)
    │
    ▼
Stage 5: Tau Prolog spike                    ← independent of Stages 1–4
    │   (Node.js spike, separate directory)       (exploratory, no dependencies)
    │
    ▼
Stage 6: Documentation + Session close       ← depends on all above
```

Stages 4 and 5 are independent of each other and of Stages 2–3. They could be done in any order, or in parallel if time-sharing between Claude and Ella. Stage 6 is always last.

**Critical path:** Stage 1 → Stage 2 → Stage 3. Stages 4 and 5 are off the critical path.

**Time-boxing note:** The extended plan describes Phase 5 as "optional, time-permitting." If time is constrained, the priority order is:
1. **Stage 1** (design) — highest value: defines the generation target for all future work
2. **Stage 2** (constraint evaluator) — proves the constraint-to-TypeScript pipeline
3. **Stage 4** (manifest) — delivers the self-knowledge infrastructure foundation
4. **Stage 3** (decision table evaluator) — extends the proven pattern to tables
5. **Stage 5** (Tau Prolog) — exploratory, least urgency
6. **Stage 6** (documentation) — always needed but scales to what was completed

---

## 6. Identified Risks

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| **Regex parsing breaks on unexpected formatting** in constraint defs or evaluation specs | Medium | Medium | Test against the actual model file first. The model's formatting is controlled (we wrote it), but constraint defs have more complex structure than part defs. If regex fails, fall back to line-by-line parsing or a simpler extraction that captures names and attributes without the full expression. |
| **Boolean constraint expressions are not uniformly parseable** from the SysML `constraint` expression syntax | Medium | Low | For constraints with complex or compound expressions, emit a `TODO` placeholder with the doc block description. The generator doesn't need to translate every expression — proving the pipeline for simple expressions (comparison, boolean AND/OR) is the Phase 5 goal. |
| **Tau Prolog doesn't support negation-as-failure or arithmetic comparison** | Low | Low | Tau Prolog documentation claims ISO Prolog compliance including `\+` and `is`. If these features are missing or buggy, document the limitation and assess SWI-Prolog WASM as an alternative. The spike is intentionally disposable. |
| **Decision table input/output split is ambiguous** in the SysML model | Low | Low | The model uses comment separators (`// --- Outputs ---`) to mark the split. If this convention is not consistently applied, the generator can use the evaluation spec's doc block or a configuration file to specify which attributes are inputs vs outputs. |
| **Generated TypeScript doesn't compile** due to type mismatches or missing imports | Low | Medium | If `tsc` is available, run it as a verification step. Otherwise, manual review against the type definitions. Phase 5 generators are prototypes; strict compilation is a nice-to-have, not a blocker. |
| **Manifest generator produces incorrect element counts** compared to `gsl` output | Medium | Low | Both generators parse the same files with different regex. Cross-check counts. Discrepancies indicate a parsing difference that should be investigated and resolved. |
| **gen_package_hierarchy.py parser relies on indentation** for hierarchy depth, which the manifest generator needs to replicate | Low | Low | Study the existing parser's depth-tracking logic before building the manifest generator. Reuse the same approach even if not sharing code. |
| **Scope creep into runtime evaluation engine** | Medium | Low | Phase 5 produces generators and generated code. The evaluation engine that calls the generated functions at runtime is explicitly out of scope. The design documents note the boundary. |

---

## 7. Design Principles for Phase 5 Generators

### 7.1 Generator as bridge, not destination

Generators are a means of maintaining the separation principle: the SysML model is the source of truth, the TypeScript code is derived. The generators are infrastructure. They should be as simple as possible while producing correct output. Clever generators that embed domain logic are an anti-pattern — domain logic lives in the model.

### 7.2 Fail loudly, degrade gracefully

If a generator cannot parse a model element, it should emit a clear warning (to stderr) and produce a commented placeholder in the output rather than silently skipping the element or crashing. The generated file should always be syntactically valid TypeScript/JSON even when individual elements could not be fully translated.

### 7.3 Round-trip verifiability

The generated output should be verifiable against the model by a human reader without needing to understand the generator internals. This means: constraint names in the generated code match constraint names in the model, attribute names match, doc block descriptions appear as comments, and the structure of the generated code mirrors the structure of the model.

### 7.4 Generation is a build step

Generated files are committed to the repository (not gitignored) so that changes are visible in diffs. This is consistent with the existing practice for `gen_package_hierarchy.py` outputs. The `DO NOT EDIT` header makes the generated status clear.

### 7.5 Automator is the destination

Every regex pattern used in Phase 5 generators is a candidate for replacement by Syside Automator's `evaluate_filter` or `evaluate_feature` calls. The regex generators serve as executable specifications: they define what the output should look like. The Automator generators will produce the same output more robustly. Phase 5 generators should be written with this migration in mind — clean data extraction → clean output generation, with the extraction step as the replaceable component.

---

## 8. Relationship to the Extended Plan's Success Criteria

| Extended Plan Success Criterion | Phase 5 Contribution |
|---|---|
| 1. Every rule evaluation produces a structured, self-explaining result | Generated evaluation functions produce EvaluationResult with explanation strings (Stage 2) |
| 2. Evaluation architecture connects CDR data to constraint evaluation | Generated spec registry maps constraints to input derivation specs — input derivation detail is placeholder but the binding structure is generated (Stage 2) |
| 3. Five layers of self-knowledge architecturally defined | System Model Manifest provides Layer 1 (structural self-knowledge) as a generated artefact (Stage 4) |
| 4. System Model Manifest concept is specified | Manifest generator produces the manifest from the model (Stage 4) |
| 5. Decision tables representable and traceable | Decision table evaluator generator produces lookup functions from model (Stage 3) |
| 6. Outcome definitions exist | Already delivered (Phase 4). Manifest captures outcomes in structural inventory (Stage 4) |
| 7. Three-tier reasoning stack concretely defined | Tau Prolog spike informs Tier 2 feasibility (Stage 5). Tier 1 is generated TypeScript (Stages 2–3) |
| 8. A generator pathway exists | Stages 2, 3, and 4 deliver working generator prototypes |
| 9. Gap analysis pattern defined as generalisation | Already delivered (Phase 2). Generated manifest enables the structural side of gap analysis |

---

## 9. Future Work Enabled by Phase 5

Phase 5 deliverables open several follow-on work streams:

**Immediate follow-on:**
- **Temporal workflow generator extension** — extend `gen_temporal_workflow.py` to emit `evaluationEngine.evaluate("constraintName", patient)` calls when it encounters `@LogicRule` or `@SafetyConstraint` metadata annotations on action steps
- **Composition builder generator** — once the OPT generation blocker is resolved, generate TypeScript composition builders from openEHR templates
- **Outcome evaluator generator** — extend the constraint evaluator pattern to generate outcome evaluation functions from OutcomeDefinition usages

**Medium-term:**
- **Syside Automator migration** — rewrite Phase 5 generators using Automator's semantic model access, using the regex generator outputs as verification baselines
- **Evaluation engine runtime** — build the TypeScript module that loads generated specs, resolves inputs via InputDerivation queries, calls generated evaluation functions, and produces EvaluationResults. This is the component that the LogicEngine::ConstraintEvaluator part def describes structurally
- **Manifest-driven UI** — build a clinician/admin dashboard that reads the System Model Manifest to display constraint inventory, pathway inventory, and entity lifecycle state
- **Scheduled governance Temporal workflow** — use the manifest + generated evaluators to run population-level constraint evaluation as a scheduled Temporal cron workflow (the Phase D governance audit generalisation)

**Longer-term:**
- **Prolog rule generation** — if the Tau Prolog spike is positive, build a generator that produces Prolog rules from SysML constraint defs for Tier 2 compound reasoning
- **Full CI/CD generation pipeline** — pre-commit hooks that regenerate all generated artefacts when `.sysml` files change, with diff checks to catch unexpected output changes

---

*Plan prepared 9 March 2026 (Session 12). Implements Phase 5 of the Knowledge Layer Elaboration extended plan.*
