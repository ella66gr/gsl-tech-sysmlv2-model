# Session 43 Report — Stage 2 Phase 5: Viewpoint/View Investigation & Stage 2 Exit

**Date:** 19 March 2026
**Session type:** Investigation and planning
**Duration:** Standard session
**Participants:** Ella Green, Claude (Opus 4.6)

---

## 1. Summary

This session completed Stage 2 Phase 5 (SysML viewpoint/view investigation) and produced the Stage 3 detailed plan, meeting the final two Stage 2 exit criteria. **Stage 2 is now formally complete (13/13 criteria met).**

Six test case files were written and verified in Syside 0.8.5. The results were significantly better than expected: `viewpoint def`, `view def`, `view` usage, `expose` (wildcard, named, cross-package), and `filter` (trivial and metadata-based) all parse and resolve correctly. The Syside visualizer renders viewpoint defs and — crucially — evaluates `expose` declarations, rendering exposed elements across packages via "Visualize view (labs)". `rendering def` and `render` fail. `frame concern` and `stakeholder` in viewpoint defs trigger subject parameter errors.

The recommendation is to adopt views partially in Stage 3: model views as structured declarations, evaluate via generator and console. The test file naming convention was also revised — `.sysml.verified`/`.failed` suffixes retired in favour of `VERIFIED`/`FAILED`/`MIXED` annotations in doc block headers, as the suffix convention breaks Syside's language server activation.

---

## 2. Context

Sessions 38–42 completed Stage 2 Phases 1–4 and 6. Phase 5 (viewpoint/view investigation) was the final implementation phase. The Stage 3 plan was the remaining exit criterion.

---

## 3. Phase 5 Investigation Results

### 3.1 Test Case Results

| Test | Construct | Result |
|---|---|---|
| 1a | `viewpoint def` (bare, with doc) | ✅ Parses |
| 1b | `viewpoint def` + `frame concern` | ✗ Subject parameter position error |
| 1c | `viewpoint def` + `stakeholder` | ✗ Cascading from 1b |
| 2a–c | `view def`, `view` typed, `view` untyped | ✅ All parse |
| 3a–c | `expose` wildcard, named, multi-package | ✅ All parse and resolve |
| 4a–b | `filter true`, `filter @MetadataType` | ✅ All parse |
| 5a–c | `rendering def`, `render` in view | ✗ All fail (reference-error) |
| 6a–b | Cross-package `expose` against BMM | ✅ All parse and resolve |

### 3.2 Bonus Finding: Syside Visualizer

Right-clicking a `viewpoint def` shows both "Visualize element (labs)" and "Visualize view (labs)" in the context menu. The visualizer renders viewpoint defs as `«viewpoint def» Name :> ViewpointCheck` with doc content.

Most significantly, "Visualize view (labs)" on a `view` with cross-package `expose` **evaluates the expose declarations and renders the exposed elements** as `«part def»` cards with attributes and doc blocks. This is Tier 2+ support — stronger than the January 2026 Sensmetry forum post suggested.

### 3.3 Tier Assessment

| Tier | Status |
|---|---|
| Tier 1 — Parser support | ✅ Confirmed for core constructs |
| Tier 2 — Semantic resolution | ✅ Confirmed — cross-package expose resolves |
| Tier 2+ — View evaluation | ✅ Confirmed — "Visualize view (labs)" evaluates exposed elements |
| Tier 3 — `rendering def` | ✗ Not available |

### 3.4 Recommendation

Adopt partially in Stage 3: model views as structured declarations, evaluate via generator and console. The `@CatalogueTag`-based dynamic grouping remains the primary interaction; modelled views complement it with curated, architect-defined perspectives. Stage 3 Phase 4 is the designated experimentation phase.

---

## 4. Stage 3 Plan

The Stage 3 detailed plan was produced with seven phases:

| Phase | Scope | Estimate |
|---|---|---|
| 1 | Paws domain model (third demonstrator) | 2–3 sessions |
| 2 | Glossary view in console | 1–2 sessions |
| 3 | Expand @UserFacing coverage to ≥75% | 1 session |
| 4 | Modelled views — experimentation | 2–3 sessions |
| 5 | Pattern Graph view in console | 2–3 sessions |
| 6 | BSMM extraction into named package | 2–3 sessions |
| 7 | Assembly workspace — design only | 1–2 sessions |

Total estimate: 11–17 sessions. Phases are largely independent, with Phase 7 coming last as it depends on having catalogue, patterns, both meta models, and views in place.

---

## 5. Design Decisions

| # | Decision | Choice | Rationale |
|---|---|---|---|
| P5-D1 | Test file location | `model/syntax-tests/` | Consistent with existing convention |
| P5-D2 | Test file naming | `VERIFIED`/`FAILED`/`MIXED` in doc block headers; `.sysml` extension retained | Old `.verified`/`.failed` suffix convention breaks Syside language server |
| P5-D3 | Findings note location | Obsidian `Research & Exploration/` | Exploratory research, not a discussion |
| P5-D4 | Cross-package test | Uses live model packages | Realistic test of the actual use case |

---

## 6. Syntax Findings

Eight new findings for the syntax reference (v3.15, new §12):

| Finding | Status |
|---|---|
| `viewpoint def` (bare) | ✅ Works |
| `viewpoint def` + `frame concern` | ✗ Fails (subject parameter position) |
| `viewpoint def` + `stakeholder` | ⚠️ Partial (cascading, needs isolation) |
| `view def` and `view` usage | ✅ Works |
| `expose` (wildcard, named, cross-package) | ✅ Works |
| `filter` (trivial and metadata-based) | ✅ Works |
| `rendering def` | ✗ Fails (reference-error) |
| `render` in view | ✗ Fails (cascading) |

---

## 7. Documents Produced

- [[ontara-stage-2-plan-phase-5-implementation-2026-03-19|Phase 5 Implementation Plan]]
- [[ontara-investigation-sysml-viewpoints-2026-03-19|Viewpoint/View Investigation Findings]]
- [[ontara-stage-3-plan-2026-03-19|Stage 3 Detailed Plan]]
- This session report
- Next session preparation note

---

## 8. Master Register Updates

| Entry | Change |
|---|---|
| **O24 (new)** | SysML v2 viewpoint/view investigation complete. Core constructs verified. Recommendation: adopt partially in Stage 3. |

**Concepts exercised:** [[concept-non-constraining|J3]] (investigated before committing), [[concept-design-decision-lifecycle|J12]] (moved from investigation to informed recommendation), [[concept-model-generates-everything|A3]] (perspectival groupings can be model-level declarations), [[concept-co-evolution|J2]] (understanding model capability before building tooling).

---

## 9. Convention Change

**Test file naming:** The `.sysml.verified` / `.sysml.failed` suffix convention was retired. Files ending in non-`.sysml` extensions are not recognised by Syside's language server — no syntax highlighting, no parsing, no error checking. New convention: all test files retain `.sysml` extension with `VERIFIED` / `FAILED` / `MIXED` status annotation in the doc block header. Existing historical files with old suffixes are left as-is.

---

## 10. Stage 2 Exit Criteria — Final Status

All 13 criteria met:

- [x] `@CatalogueTag` metadata def exists and validates
- [x] `@UserFacing` metadata def exists and validates
- [x] BMM `part def`s tagged with "concern" and "classification" dimensions
- [x] At least 10–15 BMM `part def`s have `@UserFacing` metadata (12)
- [x] Generator produces JSON with tag facets, user-facing metadata, facet summaries
- [x] Component Catalogue view working with multi-axis "group by" and element detail
- [x] Catalogue displays friendly names where available
- [x] Suds model has full BMM coverage comparable to Cafe
- [x] Suds design note written with General/Tailored observations
- [x] COSHH satisfy traceability chain completed (Session 42)
- [x] **SysML viewpoint/view investigation completed with findings (Session 43)**
- [x] Cross-links between catalogue and coverage matrix working
- [x] **Stage 3 detailed plan produced (Session 43)**

**Stage 2 is complete.**

---

## 11. Next Steps

1. **Begin Stage 3 Phase 1: Paws domain model** — the third demonstrator domain.
2. **Ella:** Copy session documents to Obsidian (findings note → Research & Exploration, plans → Plans, report → Session Reports).
3. **Ella:** Verify the rendering test file is clean after the `ViewRenderingTests` package rename.

---

*Session report prepared 19 March 2026. Session 43.*
