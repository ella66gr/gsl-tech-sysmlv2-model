# GenderSense SysML v2 Modelling — Session Report

## 6 March 2026 (Session 3)

**Purpose:** Comprehensive progress report for continuity into the next chat session. This session completed three substantial pieces of work: (1) resolved all five unverified syntax patterns from the session 1 deferred list, (2) produced the full planning document for the Coffee Shop CDR Extension Exercise, and (3) consolidated the GenderSense development artefacts into a single monorepo.

---

## 1. Session Objectives and Outcomes

### 1.1 Objectives set at session start

1. Address syntax patterns still unverified (Section 7.3 of the session 1 report)
2. Undertake step 9.1 — Coffee Shop CDR Extension Exercise

### 1.2 Completed

- **Task 1 — Syntax verification:** Five separate test files created in `model/syntax-tests/`, all five tested in Syside Modeler 0.8.5, results recorded in syntax reference v3.3
  - `decide` / `merge` control nodes — **verified working**
  - `fork` / `join` for parallel actions — **verified working** (after fixing a casing typo)
  - `state def` specialisation (`:>`) — **verified working**
  - Guard conditions on action flow transitions — **confirmed not supported** (three variants tested, all fail)
  - `verify` relationships — **confirmed not supported** (parser rejects keyword)
- **Task 2 — CDR exercise planning:** Full planning document produced (`gsl-coffeeshop-cdr-exercise-plan-2026-03-06.md`), covering EHRbase setup, archetype/template design, Temporal integration patterns, AQL queries, form-driven entry, governance audit, and a five-phase work breakdown with exit criteria
- **Task 3 — Repository consolidation** (emerged during session): Consolidated `coffeeshop-demonstrator`, `sysml-metadata-lib`, and `gsl-sysml-model` into a single monorepo. Archived `coffeeshop-exercise`. Cleaned up root-level Python skeleton files.
- **Syntax reference updated:** Versioned from v3.2 to v3.3 with five new sections, updated TODO list, Phase 3 traps table correction, and updated version history
- **Failed test files renamed:** `.sysml.failed` extension prevents Syside from parsing them while preserving evidence
- **`.gitignore` updated:** Covers `node_modules/`, `pnpm-lock.yaml`, `.svelte-kit/`, `dist/`, `.DS_Store` for the consolidated monorepo

### 1.3 Not started (deferred to next session)

- CDR exercise execution (Phase A onwards) — the planning document was the deliverable for this session

---

## 2. Repository State

### 2.1 Repository

- **GitHub:** `ella66gr/gsl-tech-sysmlv2-model`
- **Local path:** `~/Developer/gsl-tech/gsl-sysml-model/`

### 2.2 Consolidated monorepo structure

```
gsl-sysml-model/
├── model/                        # SysML v2 model files (7 packages + syntax tests)
│   ├── enterprise.sysml
│   ├── foundation.sysml
│   ├── gendersense.sysml
│   ├── knowledge.sysml
│   ├── operations.sysml
│   ├── platform.sysml
│   ├── service-delivery.sysml
│   └── syntax-tests/
│       ├── test-decide-merge.sysml           (verified ✅)
│       ├── test-fork-join.sysml              (verified ✅)
│       ├── test-state-specialisation.sysml   (verified ✅)
│       ├── test-guard-conditions.sysml.failed (not supported ✗)
│       └── test-verify.sysml.failed          (not supported ✗)
│
├── libraries/
│   └── temporal-metadata/
│       └── temporal-metadata.sysml           (moved from sysml-metadata-lib/)
│
├── exercises/
│   └── coffeeshop-demonstrator/              (moved from standalone repo)
│       ├── documentation/                    (11 phase journals and specs)
│       ├── generators/                       (4 Python generators)
│       ├── generated/                        (5 generated artefacts)
│       ├── model/domain/                     (orchestration SysML)
│       └── packages/                         (pnpm monorepo: shared, temporal, web)
│
├── scripts/
│   └── evaluate_automator.py
│
├── documentation/                            (13 project-level documents)
│   ├── gsl-architecture-principles.md
│   ├── gsl-sysml-modelling-strategy.md
│   ├── gsl-sysml-v2-syntax-reference-v3.3-2026-03-06.md
│   ├── gsl-coffeeshop-cdr-exercise-plan-2026-03-06.md
│   ├── gsl-hormone-initiation-modelling-plan-2026-03-06.md
│   ├── gsl-repo-consolidation-plan.md
│   ├── gsl-session-report-2026-03-06.md      (session 1)
│   ├── gsl-session-report-2026-03-06-s2.md   (interim, superseded by this report)
│   ├── gsl-package-hierarchy-proposal.md
│   ├── gsl-github-initialisation-guide.md
│   ├── gsl-sysml-v2-syntax-reference-v1.0-2026-03-01.md
│   └── gsl-sysml-v2-syntax-reference-v2.0-2026-03-03.md
│
├── .gitignore
└── README.md
```

### 2.3 Parent directory state (~/Developer/gsl-tech/)

```
gsl-tech/
├── gsl-sysml-model/              # The monorepo — all GenderSense development
├── coffeeshop-exercise-archive/  # Archived — Phase 1-4 SysML learning exercise
├── gsl-newsletter-control-panel/ # Separate concern — GenderInfo profile editors
├── PDF docs/                     # Reference material
└── .env                          # Environment config
```

Cleaned up this session: `coffeeshop-demonstrator/` (moved into monorepo then deleted), `sysml-metadata-lib/` (moved into monorepo then deleted), `pyproject.toml`, `src/`, `tests/`, `.venv/` (skeleton Python project, deleted).

### 2.4 Git commits (4 commits this session)

1. **`feat: verify 5 deferred syntax patterns in Syside 0.8.5`** — syntax test files, syntax reference v3.3
2. **`docs: add Coffee Shop CDR Extension Exercise planning document`** — CDR exercise plan
3. **`refactor: consolidate into monorepo`** — exercises/, libraries/, .gitignore, consolidation plan
4. **`docs: add session 2 report (6 March 2026)`** — interim session report

All four commits pushed to `origin main` (GitHub).

---

## 3. Syntax Verification Results (Task 1)

### 3.1 Summary

| Pattern | Result | Test file | Practical impact |
|---|---|---|---|
| `decide` / `merge` | ✅ Verified | `test-decide-merge.sysml` | Explicit decision/convergence semantics available for pathway diagrams |
| `fork` / `join` | ✅ Verified | `test-fork-join.sysml` | Parallel activities modelable; maps to `Promise.all()` in Temporal |
| `state def` specialisation (`:>`) | ✅ Verified | `test-state-specialisation.sysml` | Entity lifecycles can specialise `StandardLifecycle` |
| Guard conditions | ✗ Not supported | `test-guard-conditions.sysml.failed` | Continue using doc comments on unguarded branches |
| `verify` relationships | ✗ Not supported | `test-verify.sysml.failed` | Verification traceability stays outside SysML |

### 3.2 Decide / merge control nodes — VERIFIED

Previously failed in earlier Syside versions with "No Feature named 'X' found" reference errors. Now work in Syside 0.8.5.

`decide nodeName;` creates a named decision point; multiple `then` lines after it create branches. `merge nodeName;` creates a named convergence point; multiple actions can `then` into it. Both are referenceable features in the action flow.

Functionally equivalent to the existing action-node-as-decision-point pattern (verified in the demonstrator), but semantically explicit — `decide` and `merge` render differently in diagrams and make the intent clearer. For GenderSense, preferable at explicit clinical decision points.

### 3.3 Fork / join for parallel actions — VERIFIED

Named `fork` and `join` control nodes create parallel branches and synchronisation points. `fork nodeName;` followed by multiple `then` lines creates concurrent branches. `join nodeName;` synchronises — all forked branches must reach the join before proceeding.

Three-way parallelism tested (three concurrent actions converging on a single join). Maps directly to `Promise.all()` in Temporal workflow generation.

**Trap discovered:** Action names are case-sensitive. `then getcup;` with `action getCup;` causes a reference error. The original test file had this typo; fixed to `then getCup;` and the file parsed clean.

For GenderSense: directly applicable for concurrent clinical activities (e.g. ordering bloods and sending patient information simultaneously, notifying multiple parties in parallel).

### 3.4 State def specialisation (`:>`) — VERIFIED

`state def SubType :> BaseType { ... }` inherits all states and transitions from the base state def. Additional states can be added. Additional transitions (including transitions from inherited states to new states) can be added. A specialisation can add only transitions without new states.

Two variants tested, both clean:
- **Variant A:** Specialise `BaseLifecycle` with two new states (`dispatched`, `delivered`) and two new transitions
- **Variant B:** Specialise `BaseLifecycle` with only two new transitions (from inherited states)

`exhibit state lifecycle : SpecialisedStateDef;` works on part defs — verified with both specialised variants.

For GenderSense: entity lifecycles in `ClinicalEntities` could optionally specialise `Foundation::StatePatterns::StandardLifecycle` instead of duplicating the base pattern. The current standalone approach remains valid and is not broken; specialisation is available when lifecycle reuse becomes valuable or when the number of entity lifecycles grows.

### 3.5 Guard conditions on action flow transitions — NOT SUPPORTED

Three variants tested, all fail in Syside 0.8.5:

| Variant | Syntax | Error |
|---|---|---|
| A: Guard on `then` with `in item` | `then applyDiscount if isLargeOrder;` | `parameter-membership-owning-type` — guard breaks parameter ownership rules |
| B: Guard on `transition` | `transition first assessOrder if isLargeOrder then applyDiscount;` | Same `parameter-membership-owning-type` error |
| C: Guard with `attribute` | `then applyDiscount if isLargeOrder;` (where `isLargeOrder` is an `attribute`, not `in item`) | `reference-error` on target names — the `if` guard breaks Syside's ability to resolve `then` targets entirely |

The workaround — unguarded multiple `then` lines from a decision action (or `decide` node), with the guard condition described in `doc` comments — remains the only viable approach. This is already the pattern used in both the coffee shop demonstrator and the hormone therapy pathway. The `decide` node now being available makes the decision point more explicit in diagrams even without formal guards.

### 3.6 Verify relationships — NOT SUPPORTED

`verify requirement X by Y;` — the parser does not recognise `verify` as a valid statement-level keyword. Returns `Unexpected 'verify'` with a full token expectation list. Interestingly, `verify` appears in the expected token list as a keyword (suggesting the parser knows about it as a reserved word), but it cannot start a statement in the current Syside grammar.

**Additional finding — satisfy namespace-distinguishability trap:** When `satisfy requirement X by Y;` appears in the **same package** as `requirement def X`, Syside raises a `namespace-distinguishability` warning. The `satisfy` relationship creates an implicit `SatisfyRequirementUsage` named `X`, which shadows the `requirement def X` declared in the same scope.

This does not affect the GenderSense model because `satisfy` relationships are in `Knowledge::ConstraintLibrary` while `requirement def` declarations are in `Enterprise::Regulation` — different packages, no shadowing. Documented as a general rule: always keep `satisfy` (and presumably `verify`, if it ever works) in a different package from the `requirement def` it references.

For GenderSense: verification traceability must be handled outside SysML — in documentation, test suites, or governance audit reports. `satisfy` remains the primary formal traceability mechanism in the model.

---

## 4. CDR Exercise Plan (Task 2)

### 4.1 Document produced

`documentation/gsl-coffeeshop-cdr-exercise-plan-2026-03-06.md` — comprehensive planning document following the same structure as the hormone initiation modelling plan.

### 4.2 Scope

The exercise validates openEHR CDR integration patterns using the coffee shop domain as a safe proxy before applying them to clinical data. It extends the Coffee Shop Demonstrator (which validated process orchestration) with the data persistence layer.

### 4.3 Key design decisions in the plan

**Archetypes:** Three archetypes mapped to openEHR RM classes:
- `coffeeshop-ORDER_RECORD` → `OBSERVATION` (point-in-time event: what was ordered)
- `coffeeshop-PREPARATION_EVENT` → `ACTION` (intervention with state machine: drink preparation)
- `coffeeshop-CUSTOMER_FEEDBACK` → `EVALUATION` (judgement about outcome: satisfaction rating)

**Templates:** Three templates, each corresponding to one Temporal activity or one form submission. One composition per clinical event — keeps data focused and queryable.

**Integration pattern:** TypeScript `ehrbase-client.ts` module wrapping the EHRbase REST API, consumed by Temporal activities. Canonical JSON format for compositions. One EHR per customer (mirrors one EHR per patient).

**Two data paths validated:** Workflow-driven (Temporal activities commit compositions during process execution) and form-driven (standalone feedback form commits compositions outside any workflow). Both produce identical, queryable data in the CDR.

**Governance audit:** Population-level data completeness query — "does every completed order have a preparation record?" — as a proxy for clinical audit patterns.

### 4.4 Five-phase work breakdown

| Phase | Focus | Key deliverables |
|---|---|---|
| A | Infrastructure | EHRbase Docker, archetype/template design in Archetype Designer, template upload, test composition commit |
| B | Temporal integration | `ehrbase-client.ts`, modified `validateOrder` and `prepareDrink` activities with CDR commits |
| C | Querying and entity views | AQL queries, SvelteKit entity view endpoints, feedback form (non-workflow data path) |
| D | Governance audit | Population-level data completeness query, audit report |
| E | Model updates (optional) | `@OpenEhrArchetype` metadata pattern exploration, Platform::EHR package elaboration |

### 4.5 Priority ordering (per Ella's ranking)

1. Archetype/template design for coffee shop data
2. Temporal activity patterns for committing compositions
3. AQL query patterns for entity views
4. Population-level governance query pattern

---

## 5. Repository Consolidation (Task 3)

### 5.1 Rationale

The separation between `gsl-sysml-model`, `coffeeshop-demonstrator`, and `sysml-metadata-lib` was creating increasing friction: cross-repo imports, duplicated context in session reports, and uncertainty about where new artefacts belong. The CDR extension exercise would have made this worse — the implementation code goes in the demonstrator but the planning and findings are GenderSense concerns.

The coffee shop demonstrator's value going forward is as a reference implementation within the GenderSense project, not as an independent product. The metadata library is consumed by both the model and the demonstrator. A single monorepo with `model/`, `libraries/`, `exercises/`, `documentation/`, `scripts/` is the natural structure.

### 5.2 Actions taken

| Action | Detail |
|---|---|
| Created `libraries/temporal-metadata/` | Copied `temporal-metadata.sysml` from `sysml-metadata-lib/temporal/`, updated location comment |
| Created `exercises/coffeeshop-demonstrator/` | rsync'd from standalone repo (excluding `.git` and `node_modules`) |
| Updated `.gitignore` | Added `node_modules/`, `pnpm-lock.yaml`, `.svelte-kit/`, `dist/`, `.DS_Store` |
| Renamed failed test files | `.sysml` → `.sysml.failed` to prevent Syside parse errors |
| Archived `coffeeshop-exercise` | Renamed to `coffeeshop-exercise-archive` at `gsl-tech/` level |
| Deleted `coffeeshop-demonstrator/` | Original standalone repo (copy safely in monorepo) |
| Deleted `sysml-metadata-lib/` | Original standalone directory (copy safely in monorepo) |
| Deleted root-level Python skeleton | `pyproject.toml`, `src/`, `tests/`, `.venv/` |
| Created consolidation plan | `documentation/gsl-repo-consolidation-plan.md` |

### 5.3 Import verification

Confirmed in Syside Modeler that `private import TemporalMetadata::*;` in `service-delivery.sysml` resolves correctly. Syside resolves packages by name within the workspace folder tree, not by file path, so the move is transparent to the model files.

### 5.4 What stays separate

- `gsl-newsletter-control-panel/` — different concern (GenderInfo profile editors), different tech stack, no model dependency
- `coffeeshop-exercise-archive/` — historical learning exercise, completed, archived
- `PDF docs/` — reference material, not version-controlled code

---

## 6. Syntax Reference Status

### 6.1 Version

Versioned to **v3.3** (6 March 2026, session 2). File: `documentation/gsl-sysml-v2-syntax-reference-v3.3-2026-03-06.md`.

### 6.2 Changes in v3.3

- New section: **Decide/Merge Control Nodes** — working constructs, key points, comparison to action-node pattern
- New section: **Fork/Join for Parallel Actions** — working constructs, three-way parallelism, case-sensitivity trap
- New section: **State Def Specialisation** — base/specialised lifecycle pattern, additional states, additional transitions, exhibit state verification
- New section: **Guard Conditions on Action Flow Transitions** — three failed variants with specific error messages and workaround
- New section: **Verify Relationships** — parser failure detail and `satisfy` namespace-distinguishability trap
- **Phase 3 traps table:** Updated to note that `decide`/`merge` now work in Syside 0.8.5 (previously listed as errors)
- **TODO list:** 5 items marked as done (3 verified working, 2 confirmed not working), annotation added to `satisfy` entry regarding namespace trap

### 6.3 TODO list status after v3.3

| Status | Count | Items |
|---|---|---|
| Done (verified working) | 13 | decide/merge, fork/join, state def specialisation, satisfy, use case def, exhibit state, clinical metadata, backward then, sibling import, Automator, re-test decide/merge/fork/join, entity lifecycles, same-file import |
| Done (confirmed not working) | 2 | Guard conditions, verify relationships |
| Deferred (tooling not ready) | 1 | view/viewpoint elements |
| Remaining (untested) | 8 | Port defs, metadata non-scalar types, metadata specialisation, metadata on part/state/requirement defs, generator extension, Promise.all generation, advanced use case relationships, Syside CLI viz |

---

## 7. Design Decisions

### 7.1 Failed test file convention

Failed syntax test files are renamed from `.sysml` to `.sysml.failed`. This prevents Syside from parsing them (avoiding persistent errors in the Problems panel) while preserving the evidence alongside the passing tests. The syntax reference documents all findings in full; the files are supplementary reference material.

### 7.2 Monorepo over multi-repo

The decision to consolidate was driven by the trajectory of the project: the coffee shop demonstrator, metadata library, and model were increasingly interdependent, and the CDR extension exercise would have deepened those dependencies. A monorepo with clear subdirectories (`model/`, `libraries/`, `exercises/`, `documentation/`, `scripts/`) provides the "nothing is off the map" assurance described in the modelling strategy while keeping each concern in its place.

### 7.3 Decide/merge vs action nodes for decisions

Both patterns work. The choice is a readability preference: `decide`/`merge` make decision and convergence semantics explicit in diagrams, while action nodes require the reader to infer the pattern from multiple `then` lines. For GenderSense clinical pathways, `decide`/`merge` are recommended at explicit clinical decision points. The existing hormone therapy pathway uses action nodes and is not broken; consider refactoring when the pathway is next touched.

### 7.4 State def specialisation adoption

State def specialisation is now verified but not immediately adopted. The four entity lifecycles in `ClinicalEntities` currently use standalone state defs (duplicating the base pattern from `Foundation::StatePatterns::StandardLifecycle`). This works and is clear. Specialisation would reduce duplication but adds a layer of abstraction. The recommendation is to adopt specialisation when the number of entity lifecycles grows or when a change to the base pattern needs to propagate to all entities simultaneously.

---

## 8. Companion Documents

These documents are current as of this session and should be available to the next session:

1. **`gsl-sysml-v2-syntax-reference-v3.3-2026-03-06.md`** — Living syntax reference, versioned and updated this session (5 new sections)
2. **`gsl-architecture-principles.md`** — Separation principle, openEHR CDR, governance patterns (unchanged from 4 March)
3. **`gsl-sysml-modelling-strategy.md`** — Comprehensive modelling rationale, three-tier reasoning stack, concentric rings (unchanged from 4 March)
4. **`gsl-package-hierarchy-proposal.md`** — Tree diagram of the package hierarchy (unchanged)
5. **`gsl-hormone-initiation-modelling-plan-2026-03-06.md`** — Modelling plan from session 1; all substantive steps completed
6. **`gsl-coffeeshop-cdr-exercise-plan-2026-03-06.md`** — CDR extension exercise plan (new this session)
7. **`gsl-repo-consolidation-plan.md`** — Consolidation rationale and execution plan (new this session)
8. **`gsl-session-report-2026-03-06.md`** — Session 1 report (hormone therapy pathway modelling)

---

## 9. Recommended Next Steps

### 9.1 Immediate: Execute CDR exercise Phase A

Stand up EHRbase locally (Docker Compose), design archetypes and templates in Archetype Designer, upload templates via the Definition API, create a test EHR, and commit a hand-crafted composition. This is the infrastructure phase — everything else in the CDR exercise depends on it. The planning document has the Docker Compose configuration and step-by-step deliverables.

### 9.2 Near-term: Consider decide/merge in existing pathways

The hormone therapy pathway's `assessStabilityDecision` action step is semantically a decision point. Now that `decide`/`merge` are verified, it could be refactored to use `decide assessStabilityDecision;` instead of `action assessStabilityDecision;`. This is a readability improvement, not a functional change. Consider doing this when the pathway is next touched.

### 9.3 Near-term: Consider fork/join for concurrent pathway steps

When the monitoring pathway (`MonitorHormoneTherapy`) is modelled, `fork`/`join` should be considered for genuinely concurrent activities. The initiation pathway has some steps that could clinically run in parallel (ordering bloods and providing patient information) but were modelled sequentially for simplicity.

### 9.4 Near-term: Elaborate the monitoring pathway

The hormone initiation pathway transitions to an ongoing monitoring pathway via `transitionToOngoingCare`. Modelling `MonitorHormoneTherapy` would validate the pattern of one workflow spawning another and would exercise the new `fork`/`join` capability for concurrent monitoring activities.

### 9.5 Medium-term: Decision model for regimen selection

The `selectRegimen` step references a decision table. Modelling the regimen selection decision table in `Knowledge::DecisionModels` would exercise DMN-style decision modelling and connect the pathway to the knowledge layer.

---

## 10. Working Practices Reminder

- **Syntax reference first:** Now at `documentation/gsl-sysml-v2-syntax-reference-v3.3-2026-03-06.md`
- **Version the syntax reference:** Bump version number and rename file at the start of any session that adds verified findings, not at the end
- **Verify in Syside:** All new patterns should be tested in Syside Modeler 0.8.5 and results captured in the syntax reference
- **Failed tests:** Rename to `.sysml.failed` to preserve evidence without causing Syside errors
- **Phase exit criteria:** Document what was verified, what traps were found, and update the TODO list
- **Git commits at checkpoints:** Commit when model + verification are known-good. Use selective staging (`git add <files>`) for logical commit grouping
- **MCP filesystem access:** Claude has access to `~/Developer/gsl-tech/` and can read/write files directly. Ella runs shell commands and pastes output back
- **Syside Modeler version:** 0.8.5 (VS Code extension, 1 March 2026)
- **Development environment:** macOS (MacBook Pro), Python 3.12, VS Code
- **Monorepo:** All GenderSense development artefacts now live in `gsl-sysml-model/` — model, libraries, exercises, documentation, scripts

---

*Report generated at end of session 2, 6 March 2026. Supersedes the interim report (`gsl-session-report-2026-03-06-s2.md`). For use as context in subsequent chat session.*
