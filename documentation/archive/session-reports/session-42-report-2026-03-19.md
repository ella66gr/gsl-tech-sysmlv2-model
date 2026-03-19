# Session 42 Report — Stage 2 Phase 6: COSHH Governance Traceability Chain

**Date:** 19 March 2026
**Session type:** Planning and implementation
**Duration:** Standard session
**Participants:** Ella Green, Claude (Opus 4.6)

---

## 1. Summary

This session completed Stage 2 Phase 6 — the full COSHH governance traceability chain in the Suds demonstrator with co-evolution across model, generator, and console. A new `GovernanceMapping` sub-package was added to the BMM with two General definitions (`GovernanceRequirement` requirement def and `AuditEvidenceRecord` part def). The `SudsGovernance` package was refactored with the complete satisfy chain: typed requirement → domain-specific constraint defs → satisfy relationships → audit evidence records. The generator was extended to extract all governance constructs, and a new `/governance` console view was built with traceability chain visualisation and domain/type filtering.

Additionally, a pre-existing issue with `sudsValueProposition` was fixed (`promiseStatement` → `description`, `evidenceBasis` added).

---

## 2. Context

Sessions 38–41 completed Stage 2 Phases 1–4 (tag metadata, generator extension, Suds full BMM coverage, component catalogue). Phase 5 (viewpoint investigation) and Phase 6 (governance traceability) were the remaining phases before Stage 2 exit. Phase 6 was selected for this session because it builds directly on the governance content from Session 41 (ExternalReference instances) and completes a standing commitment: [[concept-governance-first-class|A8]] (governance as first-class concern) and [[concept-governance-in-toy-domains|J8]] (governance in toy domains).

---

## 3. Design Decisions

Five design decisions were discussed and agreed before implementation:

| # | Decision | Choice | Rationale |
|---|---|---|---|
| P6-D1 | General vs domain-specific requirement def | **General** `GovernanceRequirement` in new `BusinessModel::GovernanceMapping` sub-package | Attribute structure (ID, title, source, description, evidence) is domain-independent. Reusable for COSHH, CQC, GDPR, food hygiene. |
| P6-D2 | BMM location | **New `GovernanceMapping` sub-package** | Anticipated in BMM Phase 7 design. Governance vocabulary deserves its own home. |
| P6-D3 | Constraint def scope | **Domain-specific** in `SudsGovernance` | Governance constraints are regulation-specific. COSHH testable conditions differ from CQC, food hygiene, GDPR. Mirrors clinical constraints in `Knowledge::ConstraintLibrary`. |
| P6-D4 | Audit evidence model | **New General `AuditEvidenceRecord` part def** in GovernanceMapping | Domain-independent — every regulated business has evidence records. Cleaner semantics than reusing ExternalReference. |
| P6-D5 | Generator and console scope | **Full co-evolution (G3)** — model + generator + console | Standing commitment [[concept-co-evolution|J2]]. |

---

## 4. Implementation

### 4.1 Chunk 1: BMM GovernanceMapping Sub-package

Added `GovernanceMapping` sub-package to `business-model.sysml` containing:

- **`requirement def GovernanceRequirement`** — General vocabulary with attributes: `requirementId`, `title`, `regulatorySource`, `complianceDescription`, `evidenceRequired`. Tagged with `@CatalogueTag { bmmConcern = "Governance"; classification = "General"; }` and `@UserFacing`.
- **`part def AuditEvidenceRecord`** — General vocabulary with attributes: `evidenceType`, `evidenceDescription`, `retentionPeriod`, `responsibleRole`, `frequency`. Tagged with `@CatalogueTag` and `@UserFacing`.

Validated in Syside. `@CatalogueTag` on `requirement def` confirmed working — new syntax finding.

### 4.2 Chunk 2: Suds COSHH Satisfy Chain

Refactored `SudsGovernance` package in `suds.sysml`:

- **Requirement:** `coshhCompliance` refactored from bare requirement to typed `requirement coshhCompliance : GovernanceRequirement` with `:>>` attribute redefinitions.
- **Constraint defs (domain-specific):**
  - `CoshhStorageConstraint` — `allSubstancesHaveSds and storageAreaCompliant`
  - `CoshhTrainingConstraint` — `monthsSinceTraining <= requiredMaxMonths`
- **Constraint usages:** `coshhStorageCheck`, `coshhTrainingCheck`
- **Satisfy relationships:**
  - `satisfy requirement coshhStorageSatisfied : GovernanceRequirement by coshhStorageCheck;`
  - `satisfy requirement coshhTrainingSatisfied : GovernanceRequirement by coshhTrainingCheck;`
- **Audit evidence records (4):** `coshhRiskAssessment`, `sdsRegister`, `staffTrainingRecord`, `storageInspectionLog` — all typed by `AuditEvidenceRecord`.
- **ExternalReferences:** `coshhGuidance` and `detergentSafetyDataSheet` preserved unchanged.

New import: `private import BusinessModel::GovernanceMapping::*;`

Validated in Syside. Cross-package satisfy (exercise → model) confirmed working.

### 4.3 Chunk 3: Generator Extension

Extended `gen_model_introspection.py` with:

- New regex patterns: `requirement_def_pattern`, `constraint_def_pattern`, `constraint_usage_pattern`, `satisfy_pattern`, `satisfy_by_pattern`
- New element extraction for all four construct types, including multi-line `satisfy ... by` lookahead
- New `build_governance_traceability()` function assembling requirement defs, constraint defs, satisfy chains, requirement instances, and audit evidence instances
- Classification updates: `GovernanceMapping` added to `BMM_PACKAGES`; `AuditEvidenceRecord` and `ActivityCostAllocation` added to `bmm_types`
- JSON output: new `governanceTraceability` top-level section
- Diagnostics: governance traceability summary in stderr

Generator output verified: 2 satisfy chains correctly resolved, 4 audit evidence instances, `AuditEvidenceRecord` appearing in coverage matrix with `suds:4`.

### 4.4 Chunk 4: Console Governance View

Built `/governance` page with:

- **Summary stats:** 5 stat cards (requirement defs, instances, constraint defs, satisfy chains, evidence records)
- **Traceability chain visualisation:** Expandable requirement cards with nested sections — compliance description, evidence required, constraint cards (blue), audit evidence cards (green) connected by a vertical border-line
- **Filter panel:** Type dropdown (filter by requirement def type) and Domain dropdown. Count display ("N of M requirements"). Clear filters link. Filters apply to all three sections: traceability chains, evidence records table, and constraint definitions.
- **Evidence records table:** All `AuditEvidenceRecord` instances with type, frequency, responsible role, retention period, domain
- **Constraint definitions section:** Domain-specific constraint defs (excluding core model)

Sidebar navigation updated with "Governance" link (shield icon) in Model Explorer section.

### 4.4 Pre-existing Fix

Fixed `sudsValueProposition` in `suds.sysml`:
- `promiseStatement` → `description` (attribute didn't exist on `ValueProposition` part def)
- Added `evidenceBasis` attribute

---

## 5. Syntax Findings

Three new syntax findings for the reference (v3.14 update):

| Finding | Status | Notes |
|---|---|---|
| `@CatalogueTag` on `requirement def` | ✅ Works | First use of metadata annotation on a requirement def. Both `@CatalogueTag` and `@UserFacing` parse cleanly. |
| `satisfy requirement localName : ReqDef by constraintUsage;` across exercise → model package boundary | ✅ Works | `GovernanceRequirement` def in `BusinessModel::GovernanceMapping`, satisfy in `SudsGovernance` (exercise directory). Cross-project import resolves correctly. |
| `constraint def` with Boolean `and` and `<=` operators | ✅ Works | Bare expression body (no semicolon). `allSubstancesHaveSds and storageAreaCompliant` and `monthsSinceTraining <= requiredMaxMonths` both parse. |

---

## 6. Documents Produced

- [[ontara-stage-2-plan-phase-6-implementation-2026-03-19|Phase 6 Implementation Plan]] — detailed plan with 4 chunks, design decisions P6-D1 through P6-D5
- This session report
- Next session preparation note

---

## 7. Master Register Updates

| Entry | Change |
|---|---|
| **O6** | Updated — `AuditEvidenceRecord` now has 4 Suds instances. Two BMM part defs remain uninstantiated (ActivityBudget, ActivityRecord). Down from three. |
| **O15 (new)** | GovernanceMapping sub-package added to BMM. Two General definitions: `GovernanceRequirement` (requirement def), `AuditEvidenceRecord` (part def). |
| **O16 (new)** | Governance traceability view added to console (`/governance`). Domain and type filtering. |

**Concepts exercised:** [[concept-governance-first-class|A8]] (governance as first-class concern), [[concept-model-generates-everything|A3]] (model generates everything — governance traceability generated into console), [[principle-coffeeshop-first|A5]] (validate in toy domains), [[concept-co-evolution|J2]] (co-evolution — model + generator + console), [[concept-cross-domain-validation|J1]] (GovernanceRequirement and AuditEvidenceRecord are General), [[concept-governance-in-toy-domains|J8]] (primary exercise), [[concept-vertical-mappings|B2]] (requirement → constraint → satisfy → evidence), [[concept-design-decision-lifecycle|J12]] (constraint defs domain-specific — experimentation phase), [[concept-general-tailored|B11]] (General defs + domain-specific constraints).

---

## 8. Stage 2 Exit Criteria — Status

- [x] `@CatalogueTag` metadata def exists and validates in Syside
- [x] `@UserFacing` metadata def exists and validates in Syside
- [x] BMM `part def`s tagged with "concern" and "classification" dimensions
- [x] At least 10–15 BMM `part def`s have `@UserFacing` metadata (12 currently)
- [x] Generator produces JSON with tag facets, user-facing metadata, facet summaries
- [x] Component Catalogue view working with multi-axis "group by" and element detail
- [x] Catalogue displays friendly names where available, falls back to SysML identifiers
- [x] Suds model has full BMM coverage comparable to Cafe
- [x] Suds design note written with General/Tailored observations
- [x] COSHH satisfy traceability chain completed *(Session 42)*
- [ ] SysML viewpoint/view investigation completed with findings *(Phase 5 — remaining)*
- [x] Cross-links between catalogue and coverage matrix working
- [ ] Stage 3 detailed plan produced

**10 of 13 exit criteria complete. Remaining: Phase 5 (viewpoint investigation) and Stage 3 plan.**

---

## 9. Next Steps

1. **Phase 5: SysML viewpoint/view investigation** — the one remaining implementation phase. Research session: test `viewpoint def` / `view def` in Syside, produce findings note.
2. **Stage 3 detailed plan** — once Phase 5 is complete, produce the Stage 3 plan to close Stage 2.
3. **Syntax reference update** — add the three new findings from this session to v3.14.
4. **Ella: re-run generator, commit Session 42 changes** (commit commands provided in session).

---

*Session report prepared 19 March 2026. Session 42.*
