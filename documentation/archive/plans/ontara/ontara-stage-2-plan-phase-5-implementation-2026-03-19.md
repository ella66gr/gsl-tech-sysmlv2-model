# Ontara — Stage 2 Phase 5 Implementation Plan: SysML Viewpoint/View Investigation

**Date:** 19 March 2026 (Session 43)
**Prepared by:** Claude, in discussion with Ella Green
**Status:** For review and agreement before implementation
**Parent plan:** [[ontara-stage-2-plan-2026-03-19|Stage 2 Detailed Implementation Plan]]
**Session:** 43
**Phase type:** Investigation (produces findings and recommendation, not committed architecture)

---

## 1. Objective

Investigate the SysML v2 `viewpoint def`, `view def`, `view`, `expose`, `filter`, and `rendering` constructs. Determine what Syside 0.8.5 supports at the parser level. Produce a findings note with a recommendation on whether to adopt modelled viewpoints for expressing perspectival groupings in the Ontara model, defer until tooling matures, or pursue an alternative mechanism.

This is a **research phase** — it produces a finding, not a commitment. Consistent with J3 (non-constraining) and J12 (design decision lifecycle: we are at the "investigation" stage, before "experimentation").

---

## 2. Background and Context

### 2.1 What the SysML v2 specification defines

SysML v2 Clause 8.2.2.26 ("Views and Viewpoints") defines the following constructs:

**`view def`** — A view definition. Can contain standard definition body items, `filter` expressions, and a `render` member. Syntactically:
```
ViewDefinition = OccurrenceDefinitionPrefix 'view' 'def'
    DefinitionDeclaration ViewDefinitionBody
```

**`view`** (usage) — A concrete view. Can contain `expose` declarations (selecting model elements to present), `filter` expressions (narrowing the selection), and a `render` member. Syntactically:
```
ViewUsage = OccurrenceUsagePrefix 'view'
    UsageDeclaration ViewUsageBody

ViewUsageBody contains:
    - DefinitionBodyItem
    - expose declarations
    - filter expressions
    - render member
```

**`expose`** — Follows the same grammar as `import` (both `MembershipImport` and `NamespaceImport` forms). This means `expose` can select specific named elements or wildcard-import all members of a package.

**`viewpoint def`** — A viewpoint definition. Structurally a specialisation of `requirement def` (uses `RequirementBody`). Can express stakeholder concerns and required constraint expressions. Syntactically:
```
ViewpointDefinition = OccurrenceDefinitionPrefix 'viewpoint' 'def'
    DefinitionDeclaration RequirementBody
```

**`viewpoint`** (usage) — A concrete viewpoint. Uses `ConstraintUsageDeclaration` + `RequirementBody`.

**`rendering def` / `rendering`** — Specifies how a view should be rendered. Eight standard rendering definitions in the SysML library: General (gv), Interconnection (iv), Action Flow (av), State Transition (stv), Sequence (sv), Geometry (gev), Grid (grv), Browser (bv).

**`filter`** — An `ElementFilterMember` containing an expression. Narrows the elements presented by a view.

### 2.2 Known Syside status

- **Sensmetry forum (7 January 2026):** A user asked how to obtain the result of a modelled view (with filter and rendering). Daumantas (Sensmetry) responded: *"This is still a work in progress and not yet possible from Automator."* Also clarified that viewpoints are structurally requirements. No timeline given ("it will be available when it is ready").
- **Syside 0.8.5 (1 March 2026):** Added `Visualize element (labs)` — targeted element visualization via right-click. But this is *not* modelled view evaluation; it is an ad-hoc tool-side visualization feature.
- **Syntax reference TODO:** "SysML v2 `view` and `viewpoint` elements — Sensmetry forum (Jan 2026) confirms rendering from modelled views is 'still a work in progress.' Deferred."

### 2.3 What we want to know

The investigation has three tiers:

**Tier 1 — Parser support (critical):** Does Syside parse `viewpoint def`, `view def`, `view`, `expose`, `filter`, `render` without errors? Parser support is the prerequisite for everything else. If the syntax doesn't parse, there's nothing further to investigate.

**Tier 2 — Semantic support:** If parsing works, do the constructs resolve correctly? Does `expose` actually select elements from other packages? Does `filter` narrow selections? Do viewpoint/view satisfy relationships resolve?

**Tier 3 — Rendering / evaluation (stretch):** Can Syside evaluate a view and render its contents? The January 2026 forum response suggests this is not yet available, but 0.8.5 may have made progress.

### 2.4 Why this matters for Ontara

The Session 38 discussion established that anticipated, stable viewpoints belong in the SysML model (consistent with A3 — model generates everything). The Component Catalogue currently provides dynamic grouping via `@CatalogueTag` metadata and generator-extracted facets. Modelled viewpoints could complement this by expressing curated, architect-defined perspectives directly in the model — if the tooling supports it. If not, we need to know so we can design an alternative mechanism or defer.

---

## 3. Test Case Specifications

Six test cases, ordered from simple to complex. Each is designed to isolate a specific question. All test files go to `model/syntax-tests/` following existing naming conventions.

### Test Case 1: Minimal viewpoint def

**File:** `test-viewpoint-def.sysml`
**Question:** Does Syside parse a basic `viewpoint def`?
**Approach:** Define a viewpoint with a doc block and a `frame` concern. Viewpoints are structurally requirement defs, so they should accept requirement body syntax.

```sysml
package ViewpointTests {
    private import ScalarValues::*;

    viewpoint def GovernanceViewpoint {
        doc /* Viewpoint for stakeholders concerned with
             * regulatory compliance and audit evidence. */

        frame concern governanceConcern {
            doc /* How does the system demonstrate compliance
                 * with regulatory requirements? */
        }
    }
}
```

**Expected outcomes:**
- ✅ Parses → viewpoint def is supported at parser level
- ✗ Parse error → fundamental syntax not yet supported

**Fallback:** If `frame concern` syntax fails, try without it (bare viewpoint def with doc only). Also try `stakeholder` keyword.

**Syntax notes:** `frame`, `concern`, and `stakeholder` are all SysML reserved words. The exact body syntax follows `RequirementBody` (from BNF), so requirement-like constructs should be valid.

### Test Case 2: Minimal view def and view usage

**File:** `test-view-def.sysml`
**Question:** Does Syside parse `view def` and `view` usage?
**Approach:** Define a view def and a concrete view usage.

```sysml
package ViewTests {
    private import ScalarValues::*;

    view def GovernanceView {
        doc /* A view presenting governance-related elements. */
    }

    view governanceOverview : GovernanceView {
        doc /* Concrete governance overview for the system. */
    }
}
```

**Expected outcomes:**
- ✅ Parses → view def and view usage both supported
- ✗ Parse error on `view def` → fundamental syntax not supported
- ✗ Parse error on `view` usage only → def works but usage has issues

### Test Case 3: View with expose

**File:** `test-view-expose.sysml`
**Question:** Does `expose` work to select elements from other packages?
**Approach:** Create a view that exposes elements from a local package using both wildcard and named forms.

```sysml
package ExposeTests {
    private import ScalarValues::*;

    package SampleDomain {
        part def Widget {
            attribute widgetName : String;
        }
        part def Gadget {
            attribute gadgetName : String;
        }
    }

    view widgetView {
        doc /* View exposing only Widget from SampleDomain. */
        expose SampleDomain::Widget;
    }

    view allDomainView {
        doc /* View exposing all members of SampleDomain. */
        expose SampleDomain::*;
    }
}
```

**Expected outcomes:**
- ✅ Both forms parse → expose syntax is functional at parser level
- ✗ Named expose fails, wildcard works (or vice versa) → partial support
- ✗ Both fail → expose not yet supported

### Test Case 4: View with filter

**File:** `test-view-filter.sysml`
**Question:** Does `filter` work within a view body?
**Approach:** Create a view with an `expose` and a `filter` expression.

```sysml
package FilterTests {
    private import ScalarValues::*;

    package SampleElements {
        part def AlphaComponent {
            attribute componentName : String;
        }
        part def BetaComponent {
            attribute componentName : String;
        }
    }

    view filteredView {
        doc /* View with a filter expression. */
        expose SampleElements::*;
        filter @SampleElements;
    }
}
```

**Syntax notes:** The `filter` keyword inside a view body takes an `OwnedExpression`. The exact expression language for filtering by metadata annotation or element type is not well-documented in the intro material. Possible forms to test:
- `filter @MetadataType;` — filter by metadata presence
- `filter istype PartDefinition;` — filter by metatype (from KerML)

If the basic form fails, try increasingly simpler expressions until we find what (if anything) the parser accepts.

**Fallback forms to try:**
```sysml
filter true;                           // trivial expression
filter istype PartDefinition;          // metatype filter
```

### Test Case 5: View with rendering

**File:** `test-view-rendering.sysml`
**Question:** Does `render` work inside a view?
**Approach:** Create a view with a render member referencing a rendering def (or the standard library General rendering if accessible).

```sysml
package RenderingTests {
    private import ScalarValues::*;

    rendering def SimpleTableRendering {
        doc /* A simple table rendering for test purposes. */
    }

    view renderedView {
        doc /* View with a rendering specification. */
        render SimpleTableRendering;
    }
}
```

**Alternative form if the above fails:**

```sysml
    view renderedView {
        render rendering : SimpleTableRendering;
    }
```

**Syntax notes:** From the BNF, `ViewRenderingMember = 'render' ViewRenderingUsage`, and `ViewRenderingUsage` follows `RenderingUsage` syntax. The exact textual form needs verification.

### Test Case 6: Cross-package view exposing model elements

**File:** `test-view-cross-package.sysml`
**Question:** Can a view expose elements from a separate model package (simulating the real use case of a view selecting BMM elements)?
**Approach:** Import from the actual model and create a view that exposes elements from `BusinessModel`.

```sysml
package CrossPackageViewTests {
    private import ScalarValues::*;
    private import BusinessModel::GovernanceMapping::*;

    view governanceElementsView {
        doc /* View exposing governance elements from the BMM. */
        expose BusinessModel::GovernanceMapping::*;
    }
}
```

**Expected outcomes:**
- ✅ Parses and the expose resolves → cross-package views are feasible for our use case
- ✗ Parses but expose doesn't resolve → scoping issue
- ✗ Parse error → syntax issue with cross-package expose

---

## 4. Implementation Chunks

### Chunk 1: Write test case files (Claude Chat)

Write all six test case files to `model/syntax-tests/`. Each file is self-contained except Test Case 6 which imports from the live model.

**Approach:** Start with the simplest test case (Test Case 1) and work up. This ordering means if early tests fail, we still get useful data about parser support limits.

**Claude Code suitability:** Not suitable — this is design work, not mechanical repetition. The test cases need to be carefully crafted for syntax investigation.

### Chunk 2: Syside verification (Ella)

Ella opens each test file in Syside 0.8.5 and records:
- Does it parse? (No red error indicators in the VS Code problems panel)
- Are there any warnings?
- Does the Syside visualizer show anything for the view elements?
- For Test Case 6: Does the cross-package import resolve?

**Recording format:** For each test case, note:
- File name
- Outcome: ✅ Parses / ⚠️ Parses with warnings / ✗ Parse error
- Error text (if any)
- Visualizer behaviour (if anything renders)
- Any unexpected behaviour

### Chunk 3: Produce findings note (Claude Chat)

Based on the verification results, produce a findings note covering:

1. **Summary table** — which constructs parse, which don't
2. **Tier assessment** — where is Syside support: Tier 1 (parsing only), Tier 2 (semantic resolution), Tier 3 (rendering/evaluation)?
3. **Implications for Ontara** — what can and can't we do with modelled views right now
4. **Recommendation** — one of:
   - **Adopt now:** If parsing + semantic resolution work, we can model viewpoints/views and have the generator extract them (even if Syside can't render them natively). Views become a model-level declaration of perspectival groupings, extracted by the generator into JSON for the console.
   - **Adopt partially:** If parsing works but semantics are incomplete, we could define viewpoints (which are requirement-like) for documentation purposes and use a custom generator to interpret them, without relying on `expose`/`filter` semantics.
   - **Defer:** If parsing is unreliable or the constructs don't work well enough to be useful, defer viewpoints to Stage 3+ and continue with the existing `@CatalogueTag` metadata-driven approach for perspectival groupings.
   - **Alternative mechanism:** If viewpoints aren't viable, propose a concrete alternative (e.g. modelled grouping `part def`s, metadata-driven virtual views defined in the generator or console).
5. **Syntax reference updates** — new findings for the syntax reference (one entry per construct tested)
6. **Generator implications** — if views/viewpoints are adopted, what would the generator need to extract?

### Chunk 4: Update syntax reference and master register (Claude Chat)

- Update syntax reference (v3.15) with the viewpoint/view findings
- Mark the TODO item as resolved (either "verified" or "confirmed not supported")
- Update master register if any new concepts or gap status changes result

---

## 5. Fallback Strategy

The test cases are ordered by dependency. If early tests fail, later tests are skipped:

| If this fails... | Then skip... | And conclude... |
|---|---|---|
| Test 1 (viewpoint def) | Tests 4, 5, 6 | Viewpoints not parser-supported. Try minimal view def (Test 2) independently. |
| Test 2 (view def) | Tests 3, 4, 5, 6 | Views not parser-supported. Conclude: defer or alternative. |
| Test 3 (expose) | Tests 4, 6 | Views parse but can't select elements. Limited value. |
| Test 4 (filter) | — | Filter not supported. Views still useful with expose alone. |
| Test 5 (rendering) | — | Render not supported. Expected given Jan 2026 forum post. |
| Test 6 (cross-package) | — | Cross-package expose not working. Limits real-world use. |

**Minimum viable outcome:** Even if only Test 1 and Test 2 pass (viewpoint def and view def parse), that tells us the constructs are recognised by the parser and can be used as structured declarations in the model — even if `expose`, `filter`, and `render` don't yet work. The generator could still extract viewpoint/view definitions as structured metadata.

---

## 6. Design Decisions to Confirm Before Implementation

| # | Question | Options | Recommendation |
|---|---|---|---|
| P5-D1 | Test file location | `model/syntax-tests/` (established convention) | `model/syntax-tests/` — consistent with existing test files |
| P5-D2 | File naming | Follow existing `.sysml` / `.sysml.verified` / `.sysml.failed` convention | Yes — rename after verification per the established convention |
| P5-D3 | Findings note location | Obsidian `Discussion Papers/` or `Research & Exploration/` | `Research & Exploration/` — this is exploratory research, not a discussion between positions |
| P5-D4 | Should Test Case 6 import from the live model? | Yes (realistic test) vs. No (self-contained) | Yes — the real question is whether cross-package expose works with our actual model structure |

---

## 7. Effort Estimate

| Activity | Estimate | Who |
|---|---|---|
| Write test case files | 15–20 minutes | Claude Chat |
| Syside verification | 15–20 minutes | Ella |
| Produce findings note | 20–30 minutes | Claude Chat |
| Update syntax reference + register | 10–15 minutes | Claude Chat |
| **Total** | **~1 hour** | — |

This is comfortably within a single session. If verification reveals unexpected parser support (e.g., everything works), we may want to extend the investigation to explore what a generator extraction for viewpoints would look like — but that would be a follow-on discussion, not part of this phase.

---

## 8. Deliverables

1. **Six test case files** in `model/syntax-tests/` (renamed with `.verified` / `.failed` suffix after Syside testing)
2. **Findings note** in Obsidian `Research & Exploration/` — `ontara-investigation-sysml-viewpoints-2026-03-19.md`
3. **Syntax reference update** — v3.15 with viewpoint/view findings
4. **Master register update** — mark TODO resolved, update O14 or other affected gaps
5. **Recommendation** — adopt / adopt partially / defer / alternative

---

## 9. Register Concepts Exercised

| Concept | How |
|---|---|
| J3 (non-constraining) | Investigating before committing to a mechanism |
| J12 (design decision lifecycle) | At the "investigation" stage; outcome determines whether to enter "experimentation" |
| A3 (model generates everything) | If viewpoints work, they become model-level declarations of perspectival groupings |
| J2 (co-evolution) | Understanding what the model can express before building tooling to consume it |
| N10 (check syntax reference) | Syntax reference checked; new findings will be added |

---

## 10. Claude Code / Cowork Task Identification

| Activity | Best suited to |
|---|---|
| Test case file design and writing | **Claude Chat** — requires design judgement about what to test and how to structure fallbacks |
| Syside verification | **Ella** — Claude cannot run Syside |
| Findings note | **Claude Chat** — synthesis and recommendation |
| Syntax reference mechanical update | **Claude Code** — could handle the mechanical edits to the syntax reference file once findings are known. Instructions: "In `documentation/reference/gsl-sysml-v2-syntax-reference-v3.13-2026-03-15.md`, add new entries to the TODO section and Section 8 (Metadata) or create a new Section 12 (Views and Viewpoints) with the verified/failed findings from the test cases. Update version to v3.15." |
| Master register update | **Claude Chat** — requires judgement about which gaps are affected |

---

*Phase 5 implementation plan prepared 19 March 2026 (Session 43). For review and agreement before implementation begins.*
