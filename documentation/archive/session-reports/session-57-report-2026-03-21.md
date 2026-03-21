# Session 57 Report — Phase 5 Plan, E003 Plan, Stage 4 High-Level Plan

**Date:** 21 March 2026
**Session type:** Planning and design
**Participants:** Ella Green, Claude (Opus 4.6)

---

## 1. Summary

Session 57 was a planning session that produced three deliverables covering the close of Stage 3, a small enhancement, and the next major development stage. No model or code changes were made — all output is planning documentation.

**Key results:**
- **Phase 5 ([[deferred-string-to-typed-ref-migration|O25]]) detailed implementation plan** — string-to-typed-ref migration across 12 BMM `part def` attributes, ~53 instance redefinitions, 7 files. Ready for Claude Code execution.
- **E003 implementation plan** — BMM Concern explanatory text in the [[concept-comprehension-layer|glossary]]. Gated on a syntax spike (metadata annotations on `package` declarations).
- **[[ontara-stage-4-high-level-plan-2026-03-21|Stage 4 high-level plan]]** — Structural Navigation and Construction. Five phases: [[concept-weighted-relationships|weighted relationship]] graph, cross-package navigation, concern descriptions, completeness visualisation, assembly workspace prototype.

**Three design decisions agreed:**
1. Create a `subscriptionBundle : ServiceOffering` composite usage for `subscriptionUnitEconomics.offering`
2. Make `CostDriver.linkedResource` a `ref linkedResource : ResourceType[0..1]` (optional multiplicity)
3. Create missing `ResourceType` usages in Suds and Paws where string conventions masked under-specification

---

## 2. Work Performed

### 2.1 Context Establishment

Read and reviewed:
- [[session-57-preparation-note|Session 57 preparation note]] (Session 56 handover)
- [[ontara-workflow-development-guide-2026-03-21|Development workflow guide]] (updated Session 56)
- [[ontara-ref-master-register-design-concepts-tiered-2026-03-20|Master concept register]] (full Tier 1 quick reference + relevant sections)
- [[deferred-string-to-typed-ref-migration|Deferred item note for O25]] (string-to-typed-ref migration)
- All BMM `part def` declarations in `model/business-model.sysml`
- All domain exercise files: `coffeeshop-business-model.sysml`, `coffeeshop-resource-financial.sysml`, `suds.sysml`, `paws.sysml`
- `model/business-scenarios.sysml` and `model/business-strategy.sysml`
- Full generator source: `scripts/gen_model_introspection.py`
- SysML syntax reference v3.17 (complete)
- [[ontara-ref-strategic-snapshot-2026-03-20-s48|Strategic snapshot]] (Session 48) and [[ontara-high-level-plan-2026-03-18|high-level plan]] (Session 37)
- [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]] (E001–E008)

### 2.2 Phase 5 Detailed Implementation Plan (O25)

**Comprehensive audit** of all String-typed attributes across every BMM `part def` declaration. Each attribute classified as:

- **Category A (12 attributes):** Cross-references to other model elements — migrate to typed `ref`
- **Category B:** Genuine text fields — remain String
- **Category C (7 attributes):** Deferred with documented rationale (e.g. `clinicalPathwayRef` crosses BMM/BSMM boundary)

**Nine implementation steps** defined with executor assignments (Claude Code for Steps 2–6, Claude Chat for Steps 7–8, Ella for Step 9). Detailed mapping tables produced for every instance redefinition across GSL core, Cafe, Suds, and Paws.

**Risk assessment** covering cross-package refs, sibling-package imports, empty refs, missing ResourceType usages, and generator compatibility.

**Concept register impacts** identified: A3, A10, A11, B14 strengthened; O25 closed; O21 updated; I15 enhanced.

### 2.3 E003 Implementation Plan

Small, self-contained plan for adding `@PurposiveDescription` at the BMM package level, extending the generator, and extending the glossary.

**Gated on syntax spike:** Metadata annotations on `package` declarations have not been verified in Syside 0.8.5. Test file specified. Fallback approach defined (parse from `doc` blocks).

**Four implementation steps** with executor assignments.

### 2.4 Stage 4 High-Level Plan

Five-phase plan for Structural Navigation and Construction:

1. **Phase 1 — Weighted Relationship Graph** (E001): D3.js force-directed graph in the console. Nodes by element, edges by weighted relationship. The visual face of the comprehension layer.
2. **Phase 2 — Cross-Package Navigation:** Deep linking, breadcrumbs, typed ref navigation, "where is this used?" panel.
3. **Phase 3 — BMM Concern Group Descriptions** (E003): Package-level purposive descriptions in the glossary.
4. **Phase 4 — Structural Completeness Visualisation:** Completeness heatmap, gap identification, pattern coverage overlay.
5. **Phase 5 — Assembly Workspace Prototype:** Configuration builder with selection/toggle, dependency hints from weighted relationships, configuration export (seed of Model Catalogue, I8).

**Estimated scope:** 7–12 sessions. Phases 1 and 3 can run in parallel; Phases 2–5 are sequential.

---

## 3. Tier 1 Compliance Check

| Principle | Status |
|---|---|
| [[principle-separation-representation-execution|A1]] (separation of representation/execution) | Not directly exercised — planning session |
| A2 (self-describing system) | Supported — Phase 5 plan strengthens machine-navigable structure |
| [[principle-model-generates-everything|A3]] (model generates everything) | Strengthened — typed refs replace string conventions |
| [[principle-two-meta-model-distinction|A4]] (two meta model distinction) | Respected — Phase 5 scope is BMM only; BSMM deferred items identified |
| A6 (deterministic/auditable reasoning) | Not directly exercised |
| [[principle-discipline-as-load-bearing-structure|A9]] (discipline as load-bearing structure) | Honoured — comprehensive audit before implementation; three plans with clear execution steps |
| [[principle-intrinsic-self-knowledge|A10]] (intrinsic self-knowledge) | Strengthened — typed refs enable machine traversal; E003 extends intrinsic explanations to package level |
| [[principle-unity-principle|A11]] (unity principle) | Enabled — typed refs unlock cross-package weight traversal for the graph view |
| [[concept-co-evolution|J2]] (co-evolution) | Satisfied — Phase 5 co-evolution check confirms model improvement feeds existing tooling; Stage 4 plan maintains model/tooling lockstep |
| [[concept-non-constraining|J3]] (non-constraining) | Respected — Phase 5 defers Category C attributes that would prematurely constrain; Stage 4 Phase 5 uses selection not DnD, preserving design options |

---

## 4. Concepts Exercised or Referenced

| Concept | How exercised |
|---|---|
| [[deferred-string-to-typed-ref-migration|O25]] (string-to-typed-ref migration) | Full detailed plan produced; 12 attributes audited and classified |
| [[concept-weighted-relationships|B14]] (weighted relationships) | Central to Stage 4 Phase 1 (graph view) and Phase 5 (assembly hints) |
| I15 (glossary) | Enhanced by Phase 5 (cross-package traversal) and E003 (concern descriptions) |
| E001 (graph visualisation) | Routed into Stage 4 Phase 1 |
| E003 (BMM concern text) | Standalone plan produced |
| E008 (configuration table) | Referenced as Phase 1b companion |
| I2 (dual canvas) | Stage 4 Phase 5 begins the business canvas |
| I8 (Model Catalogue) | Stage 4 Phase 5 creates first entries |
| I9 (assembly workspace) | Stage 4 Phase 5 prototype |
| O2 (BSMM extraction) | Identified as Stage 4/5 cross-cutting concern |

---

## 5. Documents Produced

| Document | Type | Destination |
|---|---|---|
| [[ontara-stage-3-plan-phase-5-implementation-2026-03-21|Phase 5 implementation plan]] | Implementation plan | Vault: Ontara Plans / Stage 3 |
| [[ontara-e003-plan-bmm-concern-text-2026-03-21|E003 plan]] | Implementation plan | Vault: Ontara Plans / Stage 3 |
| [[ontara-stage-4-high-level-plan-2026-03-21|Stage 4 high-level plan]] | High-level plan | Vault: Ontara Plans / Stage 4 |
| This session report | Session report | Vault: Session Reports, Prep & Handover / Sessions 51-60 |
| Session 58 preparation note | Preparation note | Vault: Session Reports, Prep & Handover / Sessions 51-60 |

---

## 6. Next Steps

1. Ella places all five documents in the vault
2. Claude enriches vault copies with wikilinks
3. Pre-migration git commit
4. Phase 5 implementation via Claude Code
5. E003 syntax spike (parallel with Phase 5 verification)
6. Strategic snapshot update at Stage 3/4 boundary

---

*Session report written 21 March 2026.*
