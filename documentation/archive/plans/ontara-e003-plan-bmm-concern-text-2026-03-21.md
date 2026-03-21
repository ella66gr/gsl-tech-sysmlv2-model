# Ontara — E003 Implementation Plan: BMM Concern Explanatory Text

**Date:** 21 March 2026 (Session 57)
**Source:** Emergent Ideas Log E003 (Session 53)
**Purpose:** Add package-level purposive descriptions to BMM concern packages, extend the generator and glossary to surface them.
**Status:** Implementation plan — awaiting syntax spike result.

---

## 1. Objective

When a user selects a BMM Concern from the glossary filter dropdown (e.g. "ServiceConcept", "ActivityModel"), a panel should appear explaining what that concern group is about — before the individual elements are listed. This requires purposive descriptions at the package level, extracted by the generator and displayed by the console.

This exercises [[principle-intrinsic-self-knowledge|A10 (intrinsic self-knowledge)]] at the package level — the model explains its own organisational structure — and extends the [[pattern-metadata-driven-generation|D9 (metadata-driven generation)]] pattern from element-level to package-level.

---

## 2. Pre-requisite: Syntax Spike

**Status: UNTESTED** — `@PurposiveDescription` (or any `@metadata`) applied to a `package` declaration has not been verified in Syside 0.8.5.

### Spike test

Create `model/syntax-tests/test-metadata-on-package.sysml`:

```sysml
package TestPackageAnnotation {
    private import ScalarValues::*;
    private import Foundation::MetadataLibrary::*;

    @PurposiveDescription {
        description = "Test: can a package carry a purposive description annotation?";
    }
    package TestSubPackage {
        @PurposiveDescription {
            description = "Test: can a sub-package carry a purposive description annotation?";
        }
        part def TestElement {
            attribute name : String;
        }
    }
}
```

**Executor:** Claude Code (create file), Ella (verify in Syside).

**If it works:** Proceed with the implementation plan below.

**If it fails:** Fallback approach: use the package `doc` block (already present on all BMM packages) as the source of concern-level descriptions. The generator already extracts doc blocks. The purposive framing text would be added as a new section within the doc block, delineated by a marker comment (e.g. `* @purposive: ...`), and the generator would parse it out. Less clean than a proper annotation, but workable.

---

## 3. Implementation (assuming syntax spike passes)

### Step 1: Add `@PurposiveDescription` to BMM packages

**Executor:** Claude Code
**Scope:** Five BMM sub-packages in `model/business-model.sysml`, plus `GovernanceMapping` (same file).

| Package | Description content |
|---|---|
| `ServiceConcept` | What your business offers, to whom, and why — the value proposition, customer segments, service offerings, channels, and differentiation claims that define why your business exists. |
| `ActivityModel` | Everything your business does, classified and tracked — the activity types, cost allocations, and granularity policies that make resource consumption visible across all five concerns. |
| `ResourcePlanning` | What your business needs in order to operate — the people, equipment, premises, technology, and external services that deliver your capabilities, and the constraints that limit them. |
| `FinancialPlanning` | How money flows through your business — the revenue streams, cost drivers, unit economics, pricing models, and projections that determine whether the business model works financially. |
| `GovernanceMapping` | How your business demonstrates compliance — the governance requirements, audit evidence, and traceability chains that connect obligations to proof. |

### Step 2: Extend the generator

**Executor:** Claude Code or Chat
**Scope:** `scripts/gen_model_introspection.py`

Add extraction of `@PurposiveDescription` on package declarations. The current parser skips annotations on packages (annotations are only attached to elements following them). Changes needed:

1. When a `@PurposiveDescription` annotation is encountered before a `package` declaration, attach it to the package entry in the output JSON.
2. Add a new top-level `"packageDescriptions"` field to the JSON output, keyed by package name, containing the purposive text.
3. Cross-reference with the `bmmConcern` facet dimension so the console can look up the description for each concern group.

### Step 3: Extend the glossary view

**Executor:** Claude Code or Chat
**Scope:** Console glossary component (Svelte)

When a BMM Concern filter is active, display the concern-level purposive description in a panel above the element list. Style distinctively — perhaps a tinted info panel — to distinguish concern-level explanation from element-level content.

### Step 4: Regenerate JSON and verify

Standard regeneration and sync. Ella verifies in the console.

---

## 4. Execution Assignment

| Step | Executor | Notes |
|---|---|---|
| Syntax spike | Claude Code + Ella | Create test file, verify in Syside |
| Step 1 (model) | Claude Code | Small — 5 annotations |
| Step 2 (generator) | Claude Code | Moderate — parser extension |
| Step 3 (console) | Claude Code | Moderate — Svelte component update |
| Step 4 (verify) | Claude Chat + Ella | Regenerate, check |

**Total scope:** Small. Achievable in one focused session after the syntax spike is confirmed.

---

## 5. Concept Register Impacts

- [[principle-intrinsic-self-knowledge|A10]] (intrinsic self-knowledge): Extended from element-level to package-level.
- [[pattern-metadata-driven-generation|D9]] (metadata-driven generation): Extended to package annotations.
- I15 (glossary): Enhanced with concern-level context.
- E003 (emergent ideas log): Routed and resolved.
- Syntax reference: Updated with metadata-on-package finding (pass or fail).

---

*Plan produced 21 March 2026, Session 57.*
