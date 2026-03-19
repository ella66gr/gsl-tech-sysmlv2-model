# Ontara — Stage 2 Phase 6: Suds Governance Traceability

## Detailed Implementation Plan

**Date:** 19 March 2026 (Session 42)
**Prepared by:** Claude, in discussion with Ella Green
**Status:** For review and agreement before implementation
**Parent plan:** [[ontara-stage-2-plan-2026-03-19|Stage 2 Detailed Implementation Plan]]
**Scope:** Complete the COSHH `requirement → constraint → satisfy → audit evidence` traceability chain in the Suds demonstrator, with full co-evolution: model changes, generator extension, and a console governance traceability view.

---

## 1. Objective

Establish governance traceability as a working, visible capability in the Ontara platform by:

1. Introducing General governance vocabulary in the BMM (`GovernanceRequirement` requirement def, `AuditEvidenceRecord` part def)
2. Completing the COSHH satisfy chain in the Suds demonstrator (requirement → constraint → satisfy → evidence)
3. Extending the generator to extract requirement defs, constraint defs, satisfy relationships, and audit evidence records
4. Building a console Governance Traceability view that visualises the satisfy chain

This exercises [[concept-governance-first-class|A8]] (governance as first-class concern), [[concept-governance-in-toy-domains|J8]] (governance in toy domains), [[concept-co-evolution|J2]] (co-evolution), and [[concept-cross-domain-validation|B2]] (vertical mappings — requirement to audit evidence).

---

## 2. Design Decisions (Agreed — Session 42 Discussion)

| # | Decision | Choice | Rationale |
|---|---|---|---|
| P6-D1 | General vs domain-specific `requirement def` | **General** — new `GovernanceRequirement` requirement def in new `BusinessModel::GovernanceMapping` sub-package | The attribute structure (ID, title, source, description, evidence required) is domain-independent. Reusable for COSHH, CQC, GDPR, food hygiene. |
| P6-D2 | BMM location | **New `GovernanceMapping` sub-package** in `BusinessModel` | Anticipated in BMM Phase 7 design. Governance vocabulary deserves its own home alongside ServiceConcept, ActivityModel, ResourcePlanning, FinancialPlanning. |
| P6-D3 | Constraint def — General or domain-specific | **Domain-specific** — constraint def in `SudsGovernance` | Governance constraints are regulation-specific. COSHH testable conditions differ from CQC, food hygiene, GDPR. Mirrors clinical constraints in `Knowledge::ConstraintLibrary`. Premature generalisation avoided. |
| P6-D4 | Audit evidence model | **New General `AuditEvidenceRecord` part def** in `BusinessModel::GovernanceMapping` | Audit evidence records are domain-independent (every regulated business has them). Cleaner semantics than reusing ExternalReference. Stronger generalisation test. |
| P6-D5 | Generator and console scope | **Full co-evolution (G3)** — model + generator extension + console governance traceability view | Standing commitment [[concept-co-evolution|J2]]. Model content without tooling counterpart violates co-evolution. |

---

## 3. Implementation Chunks

The work is divided into four chunks, each with a clear deliverable.

### Chunk 1 — BMM GovernanceMapping Sub-package

**What:** Add the new `GovernanceMapping` sub-package to `business-model.sysml` with two new General definitions: `GovernanceRequirement` (requirement def) and `AuditEvidenceRecord` (part def).

**Approach:**

Add a new sub-package at the end of `business-model.sysml`, after `FinancialPlanning`. The package needs:

```
BusinessModel::GovernanceMapping
├── requirement def GovernanceRequirement    (General vocabulary)
│     attributes: requirementId, title, regulatorySource,
│                 complianceDescription, evidenceRequired
└── part def AuditEvidenceRecord             (General vocabulary)
      attributes: evidenceType, evidenceDescription,
                  retentionPeriod, responsibleRole, frequency
```

**`GovernanceRequirement`** — a `requirement def` with:
- `attribute requirementId : String;` — unique identifier (e.g. "SUDS-GOV-001")
- `attribute title : String;` — human-readable title
- `attribute regulatorySource : String;` — which regulation/standard
- `attribute complianceDescription : String;` — what compliance means (NB: `description` alone risks collision with any inherited SysML `description` — use compound name per standing convention)
- `attribute evidenceRequired : String;` — what records demonstrate compliance

Note: `subject` is optional on `requirement def`. For the General vocabulary, omit `subject` — domain-specific requirement usages can add it if needed.

**`AuditEvidenceRecord`** — a `part def` with:
- `attribute evidenceType : String;` — e.g. "risk assessment", "training record", "inspection log"
- `attribute evidenceDescription : String;` — what this record contains
- `attribute retentionPeriod : String;` — how long to keep it (e.g. "5 years", "duration of employment + 6 years")
- `attribute responsibleRole : String;` — who produces/maintains it
- `attribute frequency : String;` — how often it's produced (e.g. "annually", "per training event")

**Metadata annotations:**

Both definitions get `@CatalogueTag` and `@UserFacing` annotations (Position A — prefix):

- `GovernanceRequirement`: `@CatalogueTag { bmmConcern = "Governance"; classification = "General"; }` and `@UserFacing { friendlyName = "Governance Requirement"; shortDescription = "A regulatory or standards obligation that the business must satisfy, with evidence."; }`
- `AuditEvidenceRecord`: `@CatalogueTag { bmmConcern = "Governance"; classification = "General"; }` and `@UserFacing { friendlyName = "Audit Evidence Record"; shortDescription = "A record that demonstrates compliance with a governance requirement."; }`

**Imports required:** `private import Foundation::MetadataLibrary::*;` — already present at `BusinessModel` package level.

**Syntax reference check:**
- `requirement def` with business-domain attributes: verified §7, confirmed working in syntax tests
- `attribute` names: all compound names, avoiding reserved words. `description` is not reserved per §10 confirmed-safe list, but we use `complianceDescription` and `evidenceDescription` for clarity and to avoid any confusion with inherited attributes
- `@CatalogueTag` and `@UserFacing` on `part def`: verified in Stage 2 Phase 1 (v3.14). `@CatalogueTag` on `requirement def` is **not yet tested** — Ella to verify in Syside. If it fails, the tags can be deferred to a later syntax investigation

**Deliverable:** Updated `business-model.sysml` with `GovernanceMapping` sub-package containing two new definitions.

**Syside validation:** Required. New sub-package, new requirement def, new part def, and first use of `@CatalogueTag` on a requirement def.

**Register updates:** Add `GovernanceRequirement` and `AuditEvidenceRecord` to the generator's `bmm_types` set in `classify_meta_model_layer()`. Add `GovernanceMapping` to `BMM_PACKAGES`. Update `ActivityCostAllocation` entry (O6) — three BMM part defs previously uninstantiated, now down to two after `AuditEvidenceRecord` is added but before Suds instances.

**Best suited to:** Claude Chat (design and writing the SysML). Ella for Syside validation.

---

### Chunk 2 — Suds COSHH Satisfy Chain

**What:** Refactor `SudsGovernance` to use the new General vocabulary and complete the traceability chain: `GovernanceRequirement` usage → `constraint def` → `satisfy` → `AuditEvidenceRecord` usages.

**Approach:**

The existing `SudsGovernance` package has:
- `requirement coshhCompliance` — a bare requirement (not typed by a def). **Refactor** to type it against `GovernanceRequirement`.
- `ExternalReference` instances (`coshhGuidance`, `detergentSafetyDataSheet`) — these stay as-is. They are regulatory source documents, not audit evidence.

The refactored package structure:

```
SudsGovernance
├── import BusinessModel::GovernanceMapping::*
├── import BusinessModel::ServiceConcept::ExternalReference  (existing)
│
├── requirement coshhCompliance : GovernanceRequirement       (refactored)
│     :>> requirementId, title, regulatorySource, etc.
│
├── constraint def CoshhStorageConstraint                    (new, domain-specific)
│     in chemicalCount : Integer
│     in allHaveSds : Boolean
│     in storageCompliant : Boolean
│     (allHaveSds and storageCompliant)                      (bare expression, no semicolon)
│
├── constraint def CoshhTrainingConstraint                   (new, domain-specific)
│     in monthsSinceTraining : Integer
│     in requiredMaxMonths : Integer
│     (monthsSinceTraining <= requiredMaxMonths)
│
├── constraint coshhStorageCheck : CoshhStorageConstraint     (usage)
├── constraint coshhTrainingCheck : CoshhTrainingConstraint   (usage)
│
├── satisfy requirement coshhStorageSatisfied : GovernanceRequirement
│     by coshhStorageCheck                                   (in SudsGovernance, not in BMM)
│
├── satisfy requirement coshhTrainingSatisfied : GovernanceRequirement
│     by coshhTrainingCheck
│
├── part coshhRiskAssessment : AuditEvidenceRecord            (new)
│     :>> evidenceType = "risk assessment"
│     :>> evidenceDescription = "..."
│     :>> retentionPeriod = "5 years"
│     :>> responsibleRole = "Shop manager"
│     :>> frequency = "annually and on introduction of new chemicals"
│
├── part sdsRegister : AuditEvidenceRecord                   (new)
│     :>> evidenceType = "document register"
│     ...
│
├── part staffTrainingRecord : AuditEvidenceRecord           (new)
│     :>> evidenceType = "training record"
│     ...
│
├── part storageInspectionLog : AuditEvidenceRecord          (new)
│     :>> evidenceType = "inspection log"
│     ...
│
├── part coshhGuidance : ExternalReference                   (existing — unchanged)
└── part detergentSafetyDataSheet : ExternalReference        (existing — unchanged)
```

**Critical syntax considerations:**

1. **`satisfy` form:** Must use `satisfy requirement localName : ReqDef by constraintUsage;` — the correct named-and-typed form (syntax reference §7). The local name must be unique (not shadow the requirement usage name).

2. **`satisfy` package separation:** The `requirement def GovernanceRequirement` is in `BusinessModel::GovernanceMapping`. The `satisfy` is in `SudsGovernance`. Different packages ✅.

3. **`constraint def` body:** Bare expression, no semicolon. Boolean operators `and`, `<=` confirmed in syntax reference §7.

4. **`constraint` usage:** `constraint coshhStorageCheck : CoshhStorageConstraint;` — usage of the domain-specific constraint def. The `satisfy` targets this usage.

5. **Reserved words check:** `constraint` is a reserved word but only as a keyword — `CoshhStorageConstraint` as a def name is safe (compound name). Attribute names `chemicalCount`, `allHaveSds`, `storageCompliant`, `monthsSinceTraining`, `requiredMaxMonths` are all compound names and safe.

6. **`@CatalogueTag` on constraint defs and satisfy relationships:** Not yet verified. Defer tagging these until Syside confirms. The constraint defs and satisfy relationships will still appear in the generator output through new extraction patterns (Chunk 3).

**Imports required:** Add `private import BusinessModel::GovernanceMapping::*;` to `SudsGovernance`. Keep existing `private import BusinessModel::ServiceConcept::ExternalReference;` — or switch to wildcard if needed for `AuditEvidenceRecord` (which is in `GovernanceMapping`, not `ServiceConcept`, so the existing import stays, and the new wildcard covers the new types).

**Deliverable:** Refactored `SudsGovernance` in `suds.sysml` with full traceability chain.

**Syside validation:** Required. First use of `satisfy` in the demonstrator exercises. First domain-specific `constraint def`. First `AuditEvidenceRecord` instances.

**Best suited to:** Claude Chat (writing the SysML, requires design judgement on constraint structure). Ella for Syside validation.

---

### Chunk 3 — Generator Extension

**What:** Extend `gen_model_introspection.py` to extract `requirement def`, `constraint def`, `constraint` usages, `satisfy` relationships, and `AuditEvidenceRecord` part instances. Produce a governance traceability structure in the JSON output.

**Approach:**

The generator already extracts:
- `part def` and `part` usages (coverage matrix)
- `requirement` usages typed by a `requirement def` (via `requirement_pattern`)
- `@CatalogueTag` and `@UserFacing` annotations
- Facet summaries

It does **not** currently extract:
- `requirement def` declarations (only usages)
- `constraint def` declarations
- `constraint` usages
- `satisfy` relationships

**New regex patterns needed:**

```python
# requirement def GovernanceRequirement {
requirement_def_pattern = re.compile(
    r'^\s*requirement\s+def\s+(\w+)(?:\s*\{)?'
)

# constraint def CoshhStorageConstraint {
constraint_def_pattern = re.compile(
    r'^\s*constraint\s+def\s+(\w+)(?:\s*\{)?'
)

# constraint coshhStorageCheck : CoshhStorageConstraint;
constraint_usage_pattern = re.compile(
    r'^\s*constraint\s+(\w+)\s*:\s*(\w+(?:::\w+)*)'
)

# satisfy requirement localName : ReqDef
#     by constraintUsage;
satisfy_pattern = re.compile(
    r'^\s*satisfy\s+requirement\s+(\w+)\s*:\s*(\w+(?:::\w+)*)'
)
# The "by" target is on the next line:
satisfy_by_pattern = re.compile(
    r'^\s*by\s+(\w+)\s*;'
)
```

**New JSON output structure:**

Add a top-level `"governanceTraceability"` section to the JSON alongside `coverageMatrix`:

```json
{
  "governanceTraceability": {
    "requirementDefs": [
      {
        "name": "GovernanceRequirement",
        "package": "GovernanceMapping",
        "layer": "bmm",
        "attributes": [...],
        "doc": "...",
        "catalogueTag": {...},
        "userFacing": {...}
      }
    ],
    "constraintDefs": [
      {
        "name": "CoshhStorageConstraint",
        "package": "SudsGovernance",
        "sourceDomain": "suds",
        "doc": "..."
      }
    ],
    "satisfyChains": [
      {
        "satisfyName": "coshhStorageSatisfied",
        "requirementDef": "GovernanceRequirement",
        "constraintUsage": "coshhStorageCheck",
        "constraintDef": "CoshhStorageConstraint",
        "sourceDomain": "suds",
        "package": "SudsGovernance"
      }
    ],
    "requirementInstances": [
      {
        "name": "coshhCompliance",
        "typedBy": "GovernanceRequirement",
        "sourceDomain": "suds",
        "package": "SudsGovernance",
        "attributes": [...]
      }
    ],
    "auditEvidenceInstances": [
      {
        "name": "coshhRiskAssessment",
        "typedBy": "AuditEvidenceRecord",
        "sourceDomain": "suds",
        "package": "SudsGovernance",
        "attributes": [...]
      }
    ]
  }
}
```

**Classification updates:**

- Add `GovernanceMapping` to `BMM_PACKAGES`
- Add `GovernanceRequirement` (as requirement def — new kind) and `AuditEvidenceRecord` to `bmm_types` in `classify_meta_model_layer()`
- New element kinds: `"requirement_def"`, `"constraint_def"`, `"constraint"`, `"satisfy"`

**Coverage matrix impact:**

`AuditEvidenceRecord` is a `part def` with `part` usages, so it flows through the existing coverage matrix automatically. The new Suds `AuditEvidenceRecord` instances will appear as green cells. `GovernanceRequirement` is a `requirement def` — its typed usages should also appear in a new "requirement coverage" section or integrated into the existing matrix.

**Deliverable:** Updated `gen_model_introspection.py` with governance traceability extraction. Updated JSON output with `governanceTraceability` section. Re-run and copy to `console/static/data/`.

**Best suited to:** Claude Chat (builds on the generator Claude wrote; requires understanding of regex patterns and JSON structure). Could delegate the mechanical `bmm_types` / `BMM_PACKAGES` updates to Claude Code.

---

### Chunk 4 — Console Governance Traceability View

**What:** Build a `/governance` page in the console that visualises the satisfy traceability chain: requirement → constraint → satisfy → audit evidence.

**Approach:**

**Route:** `console/src/routes/governance/+page.svelte` and `+page.ts`.

**Data loader (`+page.ts`):** Load `model-introspection.json`, extract `governanceTraceability` section. Type definitions in a new `$lib/types/governance.ts`.

**Page layout — two sections:**

**Section A — Traceability Chain Visualisation**

A visual representation of the satisfy chain for each governance requirement. For each requirement instance:

```
┌─────────────────────────┐
│  REQUIREMENT             │
│  COSHH Compliance        │
│  SUDS-GOV-001            │
│  Source: HSE COSHH 2002  │
└────────────┬─────────────┘
             │ satisfies
     ┌───────┴───────┐
     ▼               ▼
┌──────────┐   ┌──────────┐
│ CONSTRAINT│   │ CONSTRAINT│
│ Storage   │   │ Training  │
│ Check     │   │ Check     │
└─────┬─────┘   └─────┬─────┘
      │               │
      ▼               ▼
┌──────────┐   ┌──────────┐
│ EVIDENCE  │   │ EVIDENCE  │
│ Records   │   │ Records   │
│ • Risk    │   │ • Staff   │
│   assess. │   │   training│
│ • SDS     │   │   record  │
│   register│   │           │
│ • Storage │   │           │
│   inspec. │   │           │
└───────────┘   └───────────┘
```

This could be rendered as:
- **Option 1:** A vertical card-chain layout (cards connected by vertical lines). Each card is a styled Flowbite card. Simple, works well for 1–3 chains.
- **Option 2:** An SVG flow diagram. More visual, but more implementation effort.

Recommendation: **Option 1** (card chain) for this iteration. The data is small (1 requirement, 2 constraints, 4 evidence records). A card-chain layout is clear, quick to build, and consistent with the catalogue's card-based design. An SVG visualisation can be added in Stage 3 when there's more governance content to display.

**Section B — Evidence Records Table**

A table listing all `AuditEvidenceRecord` instances across domains, with columns: Evidence Type, Description, Retention Period, Responsible Role, Frequency, Domain.

**Section C — External References**

The existing `ExternalReference` instances in `SudsGovernance` (regulatory source documents) displayed as a reference list — distinct from audit evidence.

**Navigation:**

- Add "Governance" to the sidebar navigation in `+layout.svelte`
- Cross-link: clicking a requirement in the governance view links to its coverage matrix entry; clicking an evidence record links to its catalogue entry

**Console types (`$lib/types/governance.ts`):**

```typescript
export interface GovernanceRequirementInstance {
  name: string;
  typedBy: string;
  sourceDomain: string;
  package: string;
  attributes: Array<{ name: string; value?: string; type?: string }>;
}

export interface ConstraintDef {
  name: string;
  package: string;
  sourceDomain: string;
  doc: string;
}

export interface SatisfyChain {
  satisfyName: string;
  requirementDef: string;
  constraintUsage: string;
  constraintDef: string;
  sourceDomain: string;
  package: string;
}

export interface AuditEvidenceInstance {
  name: string;
  typedBy: string;
  sourceDomain: string;
  package: string;
  attributes: Array<{ name: string; value?: string }>;
}

export interface GovernanceTraceability {
  requirementDefs: Array<{ name: string; package: string; layer: string; doc: string }>;
  constraintDefs: ConstraintDef[];
  satisfyChains: SatisfyChain[];
  requirementInstances: GovernanceRequirementInstance[];
  auditEvidenceInstances: AuditEvidenceInstance[];
}
```

**Deliverable:** Working `/governance` page with traceability chain visualisation, evidence records table, and external references. Sidebar navigation updated.

**Best suited to:** Claude Chat (interactive Svelte UI work with design judgement).

---

## 4. Implementation Sequence

```
Chunk 1: BMM GovernanceMapping        →  Syside validation checkpoint
Chunk 2: Suds COSHH satisfy chain     →  Syside validation checkpoint
Chunk 3: Generator extension          →  Re-run generator, inspect JSON
Chunk 4: Console governance view      →  Visual review
```

Chunks 1 and 2 are model work requiring Syside validation. Chunks 3 and 4 are code work that can proceed once the model validates. The sequence is strict — each chunk depends on the previous.

**Syside validation checkpoints:**

1. **After Chunk 1:** Does `GovernanceMapping` sub-package parse? Do `GovernanceRequirement` (requirement def) and `AuditEvidenceRecord` (part def) validate? Does `@CatalogueTag` work on a requirement def?
2. **After Chunk 2:** Does the refactored `SudsGovernance` parse? Do the constraint defs validate? Does `satisfy` resolve correctly across packages? Do the AuditEvidenceRecord instances validate?

---

## 5. Risk Register

| Risk | Likelihood | Mitigation |
|---|---|---|
| `@CatalogueTag` on `requirement def` not supported in Syside 0.8.5 | Medium — not yet tested | Defer tagging requirement defs. They still appear in the governance traceability JSON via the new extraction patterns. Tag support can be added later. |
| `satisfy` across exercise → model package boundary fails | Low — syntax reference confirms cross-package satisfy works | If it fails, move the satisfy into a sub-package within suds.sysml that imports both. |
| `constraint def` with Boolean operators fails in Syside | Low — syntax reference §7 confirms `and`, `<=` work | Simplify to single-condition constraints if needed. |
| Generator regex fails on multi-line `satisfy ... by` | Medium — `satisfy` and `by` are on separate lines | Handle in parser: when `satisfy` is matched, look ahead for `by` on the next non-blank line. |
| Phase 6 exceeds 1-session scope due to G3 (full co-evolution) | Medium | Chunk 4 (console view) can be simplified to a minimal card layout. A richer SVG visualisation can be deferred to Stage 3. |

---

## 6. Master Register Concepts Exercised

| Concept | How |
|---|---|
| [[concept-governance-first-class\|A8]] (governance as first-class concern) | Full satisfy traceability chain from requirement to audit evidence |
| [[concept-model-generates-everything\|A3]] (model generates everything) | Governance traceability generated from model into console |
| [[principle-coffeeshop-first\|A5]] (validate in toy domains) | COSHH governance in Suds demonstrates the pattern before GSL/CQC |
| [[concept-co-evolution\|J2]] (co-evolution) | Model, generator, and console all advance together (G3) |
| [[concept-cross-domain-validation\|J1]] (cross-domain validation) | GovernanceRequirement and AuditEvidenceRecord are General — validate in Suds, reusable for GSL |
| [[concept-governance-in-toy-domains\|J8]] (governance in toy domains) | Primary exercise of this concept |
| [[concept-vertical-mappings\|B2]] (vertical mappings) | Requirement → constraint → satisfy → evidence is a vertical mapping |
| [[concept-design-decision-lifecycle\|J12]] (design decision lifecycle) | Constraint defs at domain level (experimentation); may generalise later |
| [[concept-general-tailored\|B11]] (General/Tailored) | GovernanceRequirement and AuditEvidenceRecord are General; constraint defs are domain-specific (Tailored equivalent) |

---

## 7. Claude Code / Cowork Task Identification

| Chunk | Claude Chat | Claude Code | Ella |
|---|---|---|---|
| 1: BMM GovernanceMapping | Design and write the SysML | — | Syside validation; verify `@CatalogueTag` on requirement def |
| 2: Suds satisfy chain | Design and write the SysML | Could write AuditEvidenceRecord instances from agreed specs | Syside validation |
| 3: Generator extension | Design regex patterns, JSON structure, classification updates | Mechanical updates: add to `BMM_PACKAGES`, `bmm_types`, `DOMAIN_PACKAGES` | Re-run generator, review output |
| 4: Console governance view | Full implementation (Svelte UI, types, data loading, layout) | — | Visual review and feedback |

**Claude Code instructions (if used for Chunk 2 mechanical parts):**

> In `exercises/suds-demonstrator/model/suds.sysml`, in the `SudsGovernance` package, add the following `part` usages of `AuditEvidenceRecord` after the existing `ExternalReference` instances. Follow the same `attribute :>>` redefinition pattern as the existing Suds elements. Each part usage should have a doc block. The specific instances and their attribute values are: [list provided after Chunk 1 validates].

**Claude Code instructions (if used for Chunk 3 mechanical updates):**

> In `scripts/gen_model_introspection.py`: (1) Add `"GovernanceMapping"` to the `BMM_PACKAGES` set. (2) Add `"GovernanceRequirement"` and `"AuditEvidenceRecord"` to the `bmm_types` set in the `classify_meta_model_layer` function. Verify no duplicates.

---

## 8. Exit Criteria for Phase 6

- [ ] `GovernanceMapping` sub-package exists in `business-model.sysml` with `GovernanceRequirement` (requirement def) and `AuditEvidenceRecord` (part def)
- [ ] Both definitions have `@CatalogueTag` and `@UserFacing` annotations (or `@CatalogueTag` on requirement def deferred with finding documented)
- [ ] `SudsGovernance` refactored: `coshhCompliance` typed by `GovernanceRequirement`
- [ ] At least one `constraint def` defined in `SudsGovernance`
- [ ] At least one `satisfy` relationship connecting requirement to constraint
- [ ] At least 3 `AuditEvidenceRecord` instances in `SudsGovernance`
- [ ] Existing `ExternalReference` instances unchanged
- [ ] All model changes validate in Syside
- [ ] Generator extracts governance traceability data into JSON
- [ ] `AuditEvidenceRecord` instances appear in coverage matrix
- [ ] Console `/governance` page displays the satisfy traceability chain
- [ ] Sidebar navigation includes "Governance" link
- [ ] Master register updated with new concepts and instance counts

---

## 9. What This Phase Defers

- SVG/diagram visualisation of traceability chains (card layout sufficient for 1 requirement)
- `@CatalogueTag` on `constraint def` and `satisfy` (not yet verified in Syside)
- Cafe (CSW) governance content — no governance requirements in the coffee shop domain yet. Cross-domain governance comparison deferred to Stage 3 / Paws.
- Integration with the five-layer self-knowledge architecture (GoalProjector consuming governance requirements) — this is a Stage 3+ concern
- `verify` relationships — not supported in Syside 0.8.5

---

*Phase 6 implementation plan prepared 19 March 2026 (Session 42). For review and agreement before implementation begins.*
