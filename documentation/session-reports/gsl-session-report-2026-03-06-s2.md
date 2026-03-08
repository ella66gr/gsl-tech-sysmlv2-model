# GenderSense SysML v2 Modelling — Session Report (Syntax Verification + CDR Planning)

## 6 March 2026 (Session 2)

**Purpose:** Comprehensive progress report for continuity into the next chat session. This session addressed unverified syntax patterns from the 7.3 deferred list (five patterns tested) and produced the full planning document for the Coffee Shop CDR Extension Exercise.

---

## 1. Session Objectives and Outcomes

### Completed

- **Syntax verification:** Five test files created, all five patterns tested in Syside Modeler 0.8.5, results recorded in syntax reference v3.3
  - `decide` / `merge` control nodes — **verified working**
  - `fork` / `join` for parallel actions — **verified working**
  - `state def` specialisation (`:>`) — **verified working**
  - Guard conditions on action flow transitions — **confirmed not supported** (three variants tested)
  - `verify` relationships — **confirmed not supported**
- **CDR exercise planning:** Full planning document produced for the Coffee Shop CDR Extension Exercise (Sections 1–12, five-phase work breakdown)
- **Syntax reference updated:** Versioned from v3.2 to v3.3 with five new sections, updated TODO list, and Phase 3 traps table correction

---

## 2. Repository State

### Files Modified

| File | Changes |
|---|---|
| `documentation/gsl-sysml-v2-syntax-reference-v3.3-2026-03-06.md` | Versioned from v3.2; 5 new sections (3 verified, 2 failed), updated TODO list, Phase 3 traps corrected |
| `documentation/gsl-coffeeshop-cdr-exercise-plan-2026-03-06.md` | New — full planning document for CDR extension exercise |
| `model/syntax-tests/test-decide-merge.sysml` | New — decide/merge test (parsed clean) |
| `model/syntax-tests/test-fork-join.sysml` | New — fork/join test (parsed clean after casing fix) |
| `model/syntax-tests/test-guard-conditions.sysml` | New — guard conditions test (all variants failed) |
| `model/syntax-tests/test-state-specialisation.sysml` | New — state def specialisation test (parsed clean) |
| `model/syntax-tests/test-verify.sysml` | New — verify relationships test (failed) |

### Git commits recommended

1. **Syntax test files** — five test files in `model/syntax-tests/`
2. **Syntax reference v3.3** — version bump with all five findings documented
3. **CDR exercise plan** — planning document for the coffee shop CDR extension

---

## 3. Syntax Verification Results

### Verified working (3 of 5)

#### 3.1 `decide` / `merge` control nodes

Previously failed in earlier Syside versions with reference errors. Now work in 0.8.5. `decide nodeName;` creates a named decision point with multiple `then` branches. `merge nodeName;` creates a named convergence point. Both are referenceable features in the action flow. Functionally equivalent to action-node decisions but semantically explicit — preferable at clinical decision points for diagram clarity.

#### 3.2 `fork` / `join` for parallel actions

Named `fork` and `join` control nodes create parallel branches and synchronisation points. Three-way parallelism tested and verified. Maps to `Promise.all()` in Temporal workflow generation. Directly applicable to GenderSense for concurrent clinical activities.

**Trap discovered:** Names are case-sensitive. `then getcup;` with `action getCup;` causes a reference error. Always match case exactly.

#### 3.3 `state def` specialisation (`:>`)

Base `state def` can be specialised with additional states and/or transitions via `:>`. Inherited states and transitions are available in the specialisation. `exhibit state` works with specialised state defs on part defs. Two variants tested: adding new states + transitions, and adding only new transitions. Both work.

This means entity lifecycles in `ClinicalEntities` could optionally specialise `Foundation::StatePatterns::StandardLifecycle`. The current standalone approach remains valid; specialisation is available when lifecycle reuse becomes valuable.

### Confirmed not supported (2 of 5)

#### 3.4 Guard conditions on action flow transitions

Three variants tested, all fail:
- **Variant A:** `then target if condition;` with `in item` parameter — `parameter-membership-owning-type` error
- **Variant B:** `transition first source if condition then target;` — same error
- **Variant C:** Guard with `attribute` instead of `in item` — `reference-error` on target names; the `if` guard breaks name resolution entirely

The workaround (unguarded multiple `then` lines with doc comments describing the condition) remains the only viable approach. This is already the pattern used in both the coffee shop demonstrator and the hormone therapy pathway.

#### 3.5 `verify` relationships

`verify requirement X by Y;` — parser does not recognise `verify` as a statement-level keyword. Returns `Unexpected 'verify'` with a full token expectation list. Verification traceability must be handled outside SysML.

**Additional finding:** `satisfy` in the same package as the `requirement def` it references causes a `namespace-distinguishability` warning. The satisfy usage auto-names itself after the requirement, creating a shadow. This does not affect the GenderSense model (satisfy and requirement def are in different packages) but is documented as a general rule: keep satisfy relationships in a different package from their requirement defs.

---

## 4. CDR Exercise Plan Summary

The planning document (`gsl-coffeeshop-cdr-exercise-plan-2026-03-06.md`) covers:

1. **Purpose and rationale** — validating openEHR integration via the coffee shop domain before clinical data
2. **Technical stack** — EHRbase 2.11.0 Docker, Archetype Designer, existing demonstrator infrastructure, TypeScript REST integration
3. **Archetype/template design** — three archetypes (ORDER_RECORD, PREPARATION_EVENT, CUSTOMER_FEEDBACK) mapping to RM classes (OBSERVATION, ACTION, EVALUATION), three templates, terminology binding patterns
4. **Temporal activity patterns** — workflow activities commit compositions via `ehrbase-client.ts` module, EHR creation strategy, error handling via Temporal retry
5. **AQL query patterns** — entity view queries, SvelteKit API endpoints, process view vs entity view comparison
6. **Form-driven data entry** — customer feedback form as a non-workflow data path, validating that CDR data is indistinguishable regardless of entry mechanism
7. **Population-level governance query** — data completeness audit ("does every completed order have a preparation record?"), AQL or application-level join pattern
8. **SysML model updates** — exploratory `@OpenEhrArchetype` metadata pattern, Platform::EHR package elaboration
9. **Five-phase work breakdown** — A: infrastructure, B: Temporal integration, C: querying/forms, D: governance audit, E: model updates — each with step-by-step deliverables and exit criteria
10. **Deferred items, risks, success criteria**

---

## 5. Syntax Reference Status

The syntax reference has been versioned to **v3.3** (6 March 2026, session 2) and renamed to `gsl-sysml-v2-syntax-reference-v3.3-2026-03-06.md`.

### Changes in v3.3

- New section: **Decide/Merge Control Nodes** with working constructs and comparison to action-node pattern
- New section: **Fork/Join for Parallel Actions** with working constructs, three-way parallelism example, and case-sensitivity trap
- New section: **State Def Specialisation** with base/specialised lifecycle pattern and exhibit state verification
- New section: **Guard Conditions on Action Flow Transitions** documenting all three failed variants with specific error messages
- New section: **Verify Relationships** documenting parser failure and satisfy namespace-distinguishability trap
- Phase 3 traps table: updated to note decide/merge now work in 0.8.5
- TODO list: 5 items marked as done (3 verified, 2 confirmed not working), annotations added to satisfy entry

### TODO list status after v3.3

| Status | Count | Items |
|---|---|---|
| Done (verified working) | 13 | decide/merge, fork/join, state def specialisation, satisfy, use case def, exhibit state, clinical metadata, backward then, sibling import, Automator, re-test decide/merge/fork/join, entity lifecycles, same-file import |
| Done (confirmed not working) | 2 | Guard conditions, verify relationships |
| Remaining | 9 | Port defs, metadata non-scalar types, metadata specialisation, metadata on part/state/requirement defs, generator extension, Promise.all generation, advanced use case relationships, view/viewpoint, Syside CLI viz |

---

## 6. Recommended Next Steps

### 6.1 Immediate: Execute CDR exercise Phase A

Stand up EHRbase locally, design archetypes and templates in Archetype Designer, upload templates, and commit a hand-crafted composition. This is the infrastructure phase — everything else depends on it.

### 6.2 Immediate: Git commit this session's work

Three commits recommended:
1. Syntax test files (`model/syntax-tests/`)
2. Syntax reference v3.3 (with v3.2 preserved in git history)
3. CDR exercise planning document

### 6.3 Near-term: Consider using decide/merge in existing pathways

Now that `decide`/`merge` are verified, the hormone therapy pathway's decision points (`assessStabilityDecision`) could optionally be refactored to use `decide`/`merge` instead of action nodes. This is a readability improvement, not a functional change — the existing pattern works. Consider doing this when the pathway is next touched.

### 6.4 Near-term: Consider fork/join for concurrent pathway steps

The hormone therapy pathway currently has sequential steps that could clinically run in parallel (e.g. ordering bloods and providing patient information). When the monitoring pathway is modelled, `fork`/`join` should be considered for genuinely concurrent activities.

---

## 7. Working Practices Reminder

- **Syntax reference first:** Now at `documentation/gsl-sysml-v2-syntax-reference-v3.3-2026-03-06.md`
- **Version the syntax reference:** Bump version at the start of any session that adds verified findings
- **Verify in Syside:** All new patterns tested and results captured
- **Phase exit criteria:** Documented what was verified, what traps were found, TODO list updated
- **Git commits at checkpoints:** Commit when model + verification are known-good
- **MCP filesystem access:** Claude reads/writes files directly via MCP. Ella runs shell commands and pastes output back
- **Syside Modeler version:** 0.8.5 (VS Code extension, 1 March 2026)
- **Test files:** Syntax test files live in `model/syntax-tests/` and should remain for future re-testing

---

## 8. Repository Consolidation

Decision taken to consolidate GenderSense development artefacts into a single monorepo (`gsl-sysml-model`). The coffee shop demonstrator, metadata library, and model files all live in one repo. Rationale: the separation was creating friction (cross-repo imports, duplicated context, uncertainty about where things live), and the coffee shop demonstrator's value going forward is as a reference implementation within the GenderSense project.

### New structure

```
gsl-sysml-model/
├── model/              # SysML v2 model files
├── libraries/          # Shared SysML libraries (temporal-metadata)
├── exercises/          # Proof-of-concept implementations (coffeeshop-demonstrator)
├── scripts/            # Automation scripts
└── documentation/      # Project-level docs
```

### Actions taken

- Created `libraries/temporal-metadata/` with `temporal-metadata.sysml` (from `sysml-metadata-lib/`)
- Created `exercises/` directory for demonstrator (shell copy needed)
- Updated `.gitignore` for Node.js/pnpm/SvelteKit artefacts
- `coffeeshop-exercise` → archived as `coffeeshop-exercise-archive`
- `gsl-newsletter-control-panel` stays separate (different concern)
- Consolidation plan documented in `gsl-repo-consolidation-plan.md`

### Import verification needed

After copying the demonstrator and moving the metadata lib, verify that `private import TemporalMetadata::*;` in `service-delivery.sysml` still resolves in Syside. Syside resolves by package name, not file path, so it should work as long as both files are in the same workspace folder tree.

---

*Report generated at end of session 2, 6 March 2026. For use as context in subsequent chat session.*
