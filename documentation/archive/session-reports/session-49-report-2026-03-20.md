# Session 49 Report — Phase 3 Steps 1–2: Syntax Spike and Purposive Descriptions

**Date:** 20 March 2026
**Session type:** Implementation and design discussion
**Participants:** Ella Green, Claude (Opus 4.6)

---

## 1. Summary

Session 49 began Phase 3 implementation (comprehension metadata), completing Steps 1 and 2 and advancing the Step 3 design. The session resolved two open design questions, verified a critical syntax capability, introduced a new metadata def (`@PurposiveDescription`), achieved 100% annotation coverage across all 26 BMM elements, and extended the generator and console glossary to display the new content. A standing architectural commitment (string-to-typed-ref migration) was identified and captured.

**Key results:**
- **Step 1 complete:** Syntax spike confirmed `ref` inside `metadata def` works in Syside 0.8.5 — all six test patterns pass. Syntax reference updated to v3.16.
- **Step 2 complete:** `@PurposiveDescription` metadata def created. 26 annotations applied (2 by Claude Chat as exemplars, 24 by Claude Code). 14 new `@UserFacing` annotations added (1 by Claude Chat, 13 by Claude Code). Generator extended. Console glossary displays purposive descriptions. 100% coverage verified.
- **Step 3 design advanced:** 3b approach (declarative flags with smart generator) agreed. Four boolean flags defined. Hybrid discovery mechanism (package proximity for pilot, typed refs as architectural direction). Deferred item O25 created for string-to-typed-ref migration.
- **Generator bug fix:** Coverage matrix now includes `requirement_def` elements (previously only `part_def`), fixing the 25/26 glossary count.

---

## 2. Work Performed

### 2.1 Step 1: Syntax Spike — `ref` inside `metadata def`

Created `model/syntax-tests/test-ref-inside-metadata-def.sysml` with six test patterns:
- Test A: singular `ref target : PartDef` inside `metadata def` ✅
- Test B: multi-valued `ref targets : PartDef[0..*]` inside `metadata def` ✅
- Test C: `ref related : MetadataDef` inside `metadata def` ✅
- Test D: `ref depthEnum : EnumDef` inside `metadata def` ✅
- Test E: annotation application of metadata defs with ref fields ✅
- Test F: mixed attributes + refs + enum attribute (realistic `@Comprehension` pattern) ✅

Ella validated all six in Syside. Syntax reference updated to v3.16.

**Implication:** `@Comprehension` traversal targets can use formal typed model references (A3-preferable path). This unblocks Step 3.

### 2.2 Design Decisions (Q2 and Q3)

**S49-D1 — Separate `@PurposiveDescription` metadata def** (not extension of `@UserFacing`). Grounds: conceptual discipline, J3 (non-constraining), clean comprehension architecture seams, independent evolution. The purposive description is functionally different from a tooltip — it's the beginning of the authored comprehension frame.

**S49-D2 — Position A prefix for all comprehension annotations.** Grounds: A10 (the element carries its own comprehension instructions at the point of definition), A2 (self-describing), proven Syside syntax. Options B (separate section) and C (separate file) both carry untested `about` clause risk.

**S49-D3 — Annotation ordering convention:** `@CatalogueTag` → `@UserFacing` → `@PurposiveDescription` → `@Comprehension` (future). Structural/mechanical → semantic/comprehension.

### 2.3 Step 2: Apply 26 Purposive Descriptions

**Metadata def:** Created `PurposiveDescription` in `Foundation::MetadataLibrary` with single `description : String` attribute. Single attribute is deliberate — drill targets are a presentation concern; the model structure already contains the relationships.

**Exemplar annotations (Claude Chat):**
- Activity Type (#8) — `@PurposiveDescription` added after existing `@UserFacing`
- Channel (#4) — both `@UserFacing` and `@PurposiveDescription` added (new element)

**Bulk application (Claude Code):**
- 11 elements: `@PurposiveDescription` added (Group A — already had `@UserFacing`)
- 13 elements: both `@UserFacing` and `@PurposiveDescription` added (Group B — new)
- Claude Code instruction file produced with exact SysML annotation text, verification checklist, and critical rules
- All verification checks passed: 26 `@PurposiveDescription`, 26 `@UserFacing`, 26 `@CatalogueTag`, correct ordering, bracket matching, semicolons, no body modifications

**14 new `shortDescription` one-liners** written for the ✦ elements (concise tooltip text, distinct from the longer purposive descriptions).

### 2.4 Generator and Console Co-evolution (J2)

**Generator (`gen_model_introspection.py`):**
- `SysmlElement` extended with `purposive_description` field
- `attach_annotations` handles `PurposiveDescription`
- `to_dict` includes `purposiveDescription` in JSON output
- `build_coverage_matrix` includes `purposiveDescription` on matrix entries
- `build_coverage_matrix` now includes `requirement_def` elements (fix for GovernanceRequirement being excluded)
- `build_coverage_matrix` now maps `requirement` usages alongside `part` usages
- `build_comprehension_summary` reports `@PurposiveDescription` count and coverage percentage
- `build_governance_traceability` includes `purposiveDescription` on requirement defs
- Diagnostic output reports `@PurposiveDescription` coverage

**Console types (`catalogue.ts`):**
- `PurposiveDescription` interface added
- `CatalogueElement` extended with optional `purposiveDescription`
- `ComprehensionSummary` extended with `purposiveDescriptionCount`, `purposiveCoveragePercent`, `missingPurposiveDescription`

**Console glossary loader (`glossary/+page.ts`):**
- Maps `purposiveDescription` from JSON into glossary entries
- Default comprehension summary includes new fields

**Console glossary view (`glossary/+page.svelte`):**
- Purposive description rendered under heading "What this means for your service" in expanded view
- Positioned between `@UserFacing` short description and model documentation excerpt
- Purposive description text included in search scope

**Verified:** Generator produces 100% coverage. Glossary displays 26 of 26. Purposive descriptions render correctly.

### 2.5 Step 3 Design Discussion

Discussed `@Comprehension` design at three levels of annotation explicitness:
- **3a (maximal annotation):** Every traversal instruction explicit. Rejected — duplicates structural information, violates A10.
- **3b (declarative flags with smart generator):** Annotation declares categories of content; generator discovers structural facts. **Agreed.**
- **3c (structural convention with overrides):** Implicit defaults, annotation only for overrides. Deferred — too opaque at this stage (J12).

**Four boolean flags agreed for `@Comprehension`:**
- `surfaceEnumValues` — show associated enum values
- `surfaceDomainInstantiations` — show cross-domain usage counts
- `surfaceRelatedConcepts` — show structurally related elements
- `surfaceAttributes` — show element's own attributes

**Related concept discovery discussion:**
Five mechanisms analysed (package proximity, attribute type references, name heuristics, explicit refs, hybrid). Ella confirmed strong preference for typed refs over naming conventions — naming heuristics are fragile hacks contrary to the platform's robustness principles. Hybrid approach adopted for pilot (package proximity as default), with typed `ref` attributes as the explicit architectural direction.

**O25 created** — string-to-typed-ref migration deferred item with full rationale and scope.

---

## 3. Decisions

| # | Decision | Choice | Rationale |
|---|---|---|---|
| S49-D1 | `@PurposiveDescription` structure | Separate metadata def (not `@UserFacing` extension) | Conceptual discipline, J3, clean comprehension seams, independent evolution |
| S49-D2 | Annotation placement | Position A prefix for all comprehension annotations | A10, A2, proven Syside syntax, untested `about` clause risk in alternatives |
| S49-D3 | Annotation ordering | `@CatalogueTag` → `@UserFacing` → `@PurposiveDescription` → `@Comprehension` | Structural/mechanical → semantic/comprehension |
| S49-D4 | `@Comprehension` design level | 3b (declarative flags with smart generator) | Balances model-is-source-of-truth (A3) with practical annotation cost; generator handles structural discovery |
| S49-D5 | Related concept discovery | Hybrid: package proximity for pilot, typed refs as direction | Naming heuristics are fragile; typed refs are the principled path; package proximity is adequate for pilot |
| S49-D6 | String-to-ref migration | Captured as deferred item O25 | Medium-term architectural improvement; not a pilot blocker; benefits comprehension, weighted relationships, and IDE navigability |

---

## 4. Documents Produced

1. **Syntax test file** — `model/syntax-tests/test-ref-inside-metadata-def.sysml` — in repo
2. **Claude Code instruction file** — `claude-code-step2-instructions.md` — container artifact
3. **Deferred item: string-to-typed-ref migration** — `deferred-string-to-typed-ref-migration.md` — placed in Obsidian Concept Graph/deferred/
4. This session report — container artifact
5. Session 50 preparation note — container artifact

---

## 5. Concepts Exercised

| Concept | How |
|---|---|
| **A3 (model generates everything)** | `@PurposiveDescription` is modelled in SysML, generated into JSON, consumed by console |
| **A10 (intrinsic self-knowledge)** | Purposive descriptions are the authored frame; `@Comprehension` (Step 3) will provide the intrinsic content |
| **A11 (unity principle)** | Step 3 design discussion grounded in the principle that the same relationship model informs all subsystems |
| **J2 (co-evolution)** | Every model change (annotations) has generator and console counterparts; all three advanced together |
| **J3 (non-constraining)** | Single-attribute `@PurposiveDescription`; four-flag `@Comprehension`; both designed for extension |
| **J12 (design decision lifecycle)** | 3b chosen as experimentation stage; 3c deferred as discovered convention stage |
| **A9 (discipline)** | Following the implementation plan, checking register, capturing decisions |

---

## 6. Master Register — Updates

| Item | Change |
|---|---|
| O20 | Updated: Phase 3 Steps 1–2 complete. 100% `@UserFacing` and `@PurposiveDescription` coverage. Step 3 design advanced. |
| O21 | Updated: Glossary now 26/26 entries (100%). Displays three content layers. |
| O25 | **New:** String-to-typed-ref migration deferred item. |
| Register history | Updated with Session 49 changes. |

---

## 7. Git Commands

```bash
cd ~/Developer/gsl-tech/gsl-sysml-model

# Stage all Session 49 changes
git add model/foundation.sysml
git add model/business-model.sysml
git add model/syntax-tests/test-ref-inside-metadata-def.sysml
git add documentation/reference/gsl-sysml-v2-syntax-reference.md
git add scripts/gen_model_introspection.py
git add generated/ontara/model-introspection.json
git add console/src/lib/types/catalogue.ts
git add console/src/routes/glossary/+page.ts
git add console/src/routes/glossary/+page.svelte
git add console/static/data/model-introspection.json

git commit -m "S49: Phase 3 Steps 1-2 — syntax spike (ref in metadata def), @PurposiveDescription metadata + 26 annotations, generator + console glossary extension, coverage matrix fix for requirement_def, syntax reference v3.16"

git push
```

### Archive commands

```bash
# Archive session report to repo
cp "/Users/ellagreen/Obsidian/GenderSense/02 ARCHITECTURE & MODELLING/Ontara/Session Reports, Prep & Handover/session-49-report-2026-03-20.md" documentation/archive/session-reports/

git add documentation/archive/session-reports/session-49-report-2026-03-20.md
git commit -m "S49: Archive session report"
git push
```

---

## 8. Next Steps

1. **Session 50: Step 3 — implement `@Comprehension` metadata.** Design is advanced: 3b approach, four boolean flags, package-proximity discovery for pilot, Activity Type as pilot element. Need to: create the metadata def, apply to Activity Type, extend generator for traversal discovery, extend console glossary to display dynamic content.
2. **Step 4 (ordinal weight pilot)** follows Step 3.
3. **Queued discussion (carried forward):** Service subject ≠ customer — meta model implications.

---

*Session report prepared 20 March 2026. Session 49.*
