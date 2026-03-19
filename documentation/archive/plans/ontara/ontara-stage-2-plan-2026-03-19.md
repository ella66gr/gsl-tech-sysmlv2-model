# Ontara — Stage 2 Detailed Implementation Plan

**Date:** 19 March 2026 (Session 38)
**Prepared by:** Claude, in discussion with Ella Green
**Status:** Working document — for review and agreement before implementation
**Parent plan:** [[ontara-high-level-plan-2026-03-18|Ontara High-Level Development Plan]]
**Informed by:** [[ontara-discussion-element-grouping-viewpoints-comprehension-2026-03-19|Element Grouping, Viewpoints and Comprehension discussion]]
**Scope:** Stage 2 — Catalogue, Classification and Tagging

---

## 1. Objective

Build the Component Catalogue view with multi-axis grouping, establish the `@Tag` metadata annotation in SysML, expand the Suds business model to full BMM coverage, and begin the comprehension layer with `@UserFacing` metadata. By the end of Stage 2, Ella should be able to browse the full set of meta model elements in the catalogue, group them by any available axis (BMM concern, classification, domain, package), drill into groups to see individual elements, and see which elements are instantiated across domains — with friendly names and short descriptions replacing raw SysML identifiers where available.

Stage 2 operationalises the **multi-level coherence** principle established in the Session 38 discussion: the catalogue must present elements at comprehensible scale (3–5 chunks per level), with progressive decomposition, and the grouping axes must serve the user's comprehension needs — not just the model's engineering structure.

---

## 2. Design Decisions Entering Stage 2

These were agreed during Session 38 discussion (see [[ontara-discussion-element-grouping-viewpoints-comprehension-2026-03-19|discussion document]]) and shape the plan.

| Decision | Summary |
|---|---|
| **Atomic unit** | The catalogue presents individual elements (typically `part def`s). Groupings are a presentation concern, not fixed model granularity. Resolves O19. |
| **Multi-axis grouping** | The catalogue supports "group by" as a core interaction — not just filtering. Grouping axes include BMM concern, General/Tailored classification, domain, SysML package, and any tag dimension. |
| **General-purpose `@Tag`** | A single `@Tag` metadata def with string `dimension` and `value` attributes. No privileged tag dimensions — General/Tailored is an ordinary tag. |
| **Coverage matrix remains binary** | No "not applicable" vs "not yet modelled" distinction in Stage 2. Console-layer annotation may be added if needed. |
| **Multi-level coherence** | Views present 3–5 groups at each level, with progressive decomposition. Detail dissolves at high levels and crystallises on drill-down. |
| **SysML viewpoint/view investigation** | Added as a research item — understand `viewpoint def` / `view def` support before committing to a mechanism for modelled perspectival groupings. |
| **Design decision lifecycle (J12)** | We deliberately preserve freedom now and expect to tighten into opinionated configuration through use. |

---

## 3. Phasing

Stage 2 is divided into six phases. They are ordered by dependency but some can proceed in parallel. Each phase has a clear deliverable and should be reviewable before the next begins.

### Phase 1: Tag Metadata in SysML

**What:** Define the `@Tag` metadata annotation in `Foundation::MetadataLibrary` and apply initial tags to existing meta model `part def`s.

**Why first:** The catalogue's grouping capability depends on tag data in the generated JSON. Without tags, the only available grouping axes are package structure and BMM/BSMM layer — too few for meaningful multi-axis navigation. This is the model infrastructure that everything else in Stage 2 depends on.

**Tasks:**

1. **Check the SysML syntax reference** for metadata def patterns. The existing metadata defs in `Foundation::MetadataLibrary` (e.g. `AgencyClassification`, `OpenEhrArchetype`) provide a verified pattern.

2. **Define `@Tag` in `Foundation::MetadataLibrary`:**
   ```sysml
   metadata def Tag {
       doc /* General-purpose tagging metadata for catalogue
            * classification and dynamic grouping. Applied to
            * any element to classify it across one or more
            * dimensions.
            *
            * dimension: the classification axis (e.g. "concern",
            *   "classification", "sector", "deliveryMode").
            * value: the classification value within that dimension
            *   (e.g. "ServiceConcept", "General", "hospitality").
            *
            * Multiple @Tag annotations may be applied to a single
            * element across different dimensions. The generator
            * reads all @Tag annotations and produces a faceted
            * structure in JSON.
            *
            * Business system meta model concept. */
       attribute dimension : String;
       attribute :>> value : String;
   }
   ```
   **SYNTAX NOTE:** `value` is a KerML reserved word (KerML v1.0 §8.2.2.6). If Syside rejects `attribute value : String;`, use `attribute tagValue : String;` instead. Ella to verify in Syside before proceeding.

3. **Define `@UserFacing` in `Foundation::MetadataLibrary`:**
   ```sysml
   metadata def UserFacing {
       doc /* Human-readable metadata for the comprehension layer.
            * Applied to any element that should be comprehensible
            * to non-specialist users of the console.
            *
            * friendlyName: a short, lay-language name
            *   (e.g. "Pricing Model" for PricingModel).
            * shortDescription: a brief explanation (1–2 sentences)
            *   in plain language.
            *
            * Generated into the console as tooltips, glossary
            * entries, and info panel content. Consistent with
            * I14 (comprehension layer) and A3 (model generates
            * everything).
            *
            * Business system meta model concept. */
       attribute friendlyName : String;
       attribute shortDescription : String;
   }
   ```

4. **Apply initial `@Tag` annotations to BMM `part def`s in `business-model.sysml`.** Start with two dimensions:
   - `dimension = "concern"` — values: "ServiceConcept", "ActivityModel", "ResourceCapability", "FinancialModel", "Governance" (mapping to C1–C5)
   - `dimension = "classification"` — values: "General" or "Tailored"
   
   Target: tag all BMM `part def`s that are clearly General (ServiceOffering, CustomerSegment, ValueProposition, PricingModel, CostDriver, UnitEconomics, ResourceType, Capability, ActivityType, etc.). Where the classification is uncertain, leave untagged — we'll discover the answer through cross-domain work.

5. **Apply initial `@UserFacing` annotations to 10–15 BMM `part def`s** — the most commonly encountered ones (ServiceOffering, PricingModel, ActivityType, ResourceType, CostDriver). This is enough to test the comprehension layer without attempting exhaustive coverage.

6. **Verify in Syside.** All new metadata defs parse. All `@Tag` and `@UserFacing` applications resolve. No regressions in existing model files.

**Deliverable:** Updated `foundation.sysml` with `Tag` and `UserFacing` metadata defs. Updated `business-model.sysml` with initial `@Tag` and `@UserFacing` annotations on BMM `part def`s. Validated in Syside.

**Effort estimate:** 1–2 sessions.

**Register concepts exercised:** I10 (tagging system), I14/I14a (comprehension layer), B11 (General/Tailored as tag), D9 (metadata-driven generation), N1 (doc blocks on new defs).

**Best suited to:** Claude Chat for the metadata def design; Ella for Syside validation; Claude Code for bulk application of `@Tag` annotations across `part def`s (mechanical, repetitive, following a clear pattern). Claude Code instructions: "In `model/business-model.sysml`, add `@Tag { dimension = "concern"; tagValue = "ServiceConcept"; }` to each `part def` in the `ServiceConcept` package. Repeat for each BMM concern package. Then add `@Tag { dimension = "classification"; tagValue = "General"; }` to `part def`s listed in [file]. Verify no syntax errors."

---

### Phase 2: Generator Extension — Catalogue JSON

**What:** Extend `gen_model_introspection.py` (or create a new `gen_component_catalogue.py`) to extract `@Tag` and `@UserFacing` metadata from the model and produce catalogue-ready JSON.

**Why:** The console needs structured JSON that includes tag facets and user-facing metadata for each element. The existing introspection JSON has element names, types, packages, and doc blocks — but no tag data.

**Tasks:**

1. **Extend the regex parser** to extract `@Tag` and `@UserFacing` annotations. Pattern to match:
   ```
   @Tag { dimension = "..."; tagValue = "..."; }
   @UserFacing { friendlyName = "..."; shortDescription = "..."; }
   ```
   These annotations appear immediately before or after the element they annotate (verify the exact placement pattern once Phase 1 is complete and validated in Syside).

2. **Extend the JSON output** to include per-element tag and user-facing data:
   ```json
   {
     "name": "PricingModel",
     "type": "part def",
     "package": "BusinessModel::FinancialPlanning",
     "layer": "bmm",
     "docBlock": "...",
     "tags": [
       { "dimension": "concern", "value": "FinancialModel" },
       { "dimension": "classification", "value": "General" }
     ],
     "userFacing": {
       "friendlyName": "Pricing Model",
       "shortDescription": "How prices are set for services — per-item, per-kg, subscription, or other basis."
     },
     "instances": {
       "csw": ["cswPricingModel"],
       "suds": ["sudsStandardPricing"]
     }
   }
   ```

3. **Add a facet summary** to the JSON — a top-level object listing all dimensions and their distinct values, with element counts per value. This allows the console to build "group by" controls dynamically from whatever dimensions exist in the data:
   ```json
   {
     "facets": {
       "concern": {
         "values": ["ServiceConcept", "ActivityModel", "ResourceCapability", "FinancialModel", "Governance"],
         "counts": { "ServiceConcept": 8, "ActivityModel": 6, ... }
       },
       "classification": {
         "values": ["General", "Tailored"],
         "counts": { "General": 22, "Tailored": 5 }
       }
     }
   }
   ```

4. **Re-run the generator** and inspect the output. Verify that all tagged elements appear with correct facet data.

**Deliverable:** Updated generator producing JSON with tag facets, user-facing metadata, and facet summaries. JSON copied to `console/static/data/`.

**Effort estimate:** 1 session.

**Register concepts exercised:** A3 (model generates everything), D9 (metadata-driven generation), E6–E8 (generator pipeline).

**Best suited to:** Claude Chat for generator design and implementation (builds on the existing `gen_model_introspection.py` which Claude wrote in Session 35). Claude Code could handle the mechanical parts (file I/O, JSON restructuring) if the regex patterns are well-specified.

---

### Phase 3: Suds — Full BMM Coverage

**What:** Expand the Suds domain model to cover all BMM concerns at comparable depth to CSW. Apply `@Tag` annotations to Suds `part def`s where applicable.

**Why:** The catalogue and coverage matrix need a second domain with substantial content. Co-evolution (J2) — model content must keep pace with console capability. The cross-domain comparison (J1) requires enough Suds content to surface which meta model elements are truly General and which need domain-specific adaptation.

**Tasks:**

1. **Audit current Suds coverage against CSW.** Using the coverage matrix (already built in Stage 1), identify which BMM `part def`s CSW instantiates but Suds does not. Target: fill all gaps where the concept applies to a laundry service.

2. **Expand Suds model content.** Areas likely to need additions:
   - **ActivityModel:** ActivityGranularity policies for each activity (how finely the laundry tracks work). Activity cost allocations if not already present.
   - **FinancialPlanning:** Expand cost drivers, add BreakEvenAnalysis or FinancialProjection if CSW has these.
   - **Governance:** Strengthen the COSHH requirement — add the `satisfy` traceability chain (requirement → constraint → audit evidence) to exercise J8 fully.
   - **ResourcePlanning:** Capacity model, operating hours constraints.

3. **Apply `@Tag` annotations to Suds-specific `part def`s** (if any are introduced). Most Suds elements will be `part` usages of existing BMM `part def`s and won't need their own tags. But if Suds introduces any new `part def`s (Tailored concepts), tag them with `dimension = "classification"; tagValue = "Tailored"`.

4. **Apply `@UserFacing` annotations to key Suds elements** — enough to test comprehension layer rendering in the Suds domain context.

5. **Write the Suds design note** (`Demonstrators/Suds (Laundry)/suds-domain-design.md`). This was deferred from Stage 1 and should now be written with concrete observations:
   - Which BMM `part def`s transferred directly from CSW (General)?
   - Which needed Suds-specific adaptation or extension (Tailored)?
   - Were any meta model gaps exposed — concepts Suds needs that the BMM doesn't yet express?
   - Observations on cross-domain comparison methodology.

6. **Re-run the generator** and verify the expanded Suds content appears correctly in the JSON.

**Deliverable:** Expanded `suds.sysml` with full BMM coverage. Suds design note written. Generator producing updated JSON reflecting the expanded model. Coverage matrix showing substantial Suds column.

**Effort estimate:** 2–3 sessions.

**Register concepts exercised:** J1 (cross-domain validation), J8 (governance in toy domains), B11 (General/Tailored via tags), A5 (validate in toy domains).

**Best suited to:** Claude Chat for the design decisions (what to model, how to classify). Claude Code for mechanical expansion of the Suds model file once the design is agreed — "Add the following `part` usages to `SudsResourceFinancial` package: [list]. Follow the same attribute `:>>` redefinition pattern as existing Suds elements."

---

### Phase 4: Component Catalogue View — Core

**What:** Build the Component Catalogue view in the console with multi-axis "group by" as the core interaction.

**Why:** This is the primary Stage 2 console deliverable. It operationalises multi-level coherence — presenting meta model elements in comprehensible groups with progressive decomposition, governed by the 3–5 chunk principle.

**Tasks:**

1. **Design the catalogue page layout** (`/catalogue`). Two-panel layout:
   - **Left panel:** Grouping controls and grouped element list.
     - "Group by" dropdown: BMM concern, classification, domain coverage, SysML package, or any tag dimension (dynamically populated from the facet summary in the JSON).
     - The grouped list shows 3–5 top-level groups (or however many the chosen axis produces — the 3–5 principle informs design, not an enforced ceiling).
     - Each group is a collapsible card showing group name, element count, and a brief summary.
     - Expanding a group reveals its elements. If a group contains more than ~7 elements, sub-grouping is offered (e.g., within "ServiceConcept" concern, sub-group by classification).
   - **Right panel:** Element detail. Clicking an element shows:
     - Friendly name (from `@UserFacing`) and SysML identifier
     - Short description (from `@UserFacing`)
     - Doc block (from SysML)
     - Tags (all dimensions and values)
     - Cross-domain instantiation: which domains have instances of this `part def`, with instance names
     - Parent package and meta model layer (BMM/BSMM)

2. **Add filter controls** alongside grouping:
   - Text search across element names, friendly names, descriptions
   - Filter by meta model layer (BMM/BSMM/both)
   - Filter by tag value (e.g., show only "General" elements, or only "Governance" concern)
   - Filters narrow within the current grouping — they don't change the grouping axis.

3. **Implement the "group by" logic.** This is a data transformation, not a UI concern:
   ```typescript
   function groupElements(elements, axis) {
     // axis = "concern" | "classification" | "package" | "domain" | ...
     // Returns: Map<string, Element[]>
     // For tag-based axes: group by the tag value for that dimension
     // For "package": group by parent package
     // For "domain": group by which domains instantiate the element
   }
   ```
   Use Svelte 5 `$derived` to reactively recompute the grouped view when the axis or filters change.

4. **Progressive decomposition.** When a group is large, offer sub-grouping. The sub-group axis should be a different dimension from the primary group axis. For example:
   - Primary: group by concern → expand "FinancialModel" → sub-group by classification (General/Tailored)
   - Primary: group by classification → expand "General" → sub-group by concern
   
   For Stage 2, support two levels of grouping (primary + one sub-group). Deeper nesting can be added in Stage 3 if needed.

5. **Cross-link to coverage matrix.** Clicking the domain instantiation data in the detail panel links to the coverage matrix filtered to that element. Clicking an element in the coverage matrix links to its catalogue detail view.

6. **Comprehension layer rendering.** Where `@UserFacing` metadata exists, display the friendly name prominently and the SysML identifier in secondary text. Where it doesn't exist, display the SysML identifier with a visual indicator that the comprehension metadata is missing (a subtle "no description available" note — not an error, just an invitation to add it).

**Deliverable:** A working `/catalogue` page with multi-axis grouping, element detail, cross-domain instantiation data, and comprehension layer rendering. Ella can browse the meta model by any available grouping axis and drill into elements.

**Effort estimate:** 2–3 sessions.

**Register concepts exercised:** I7 (Component Catalogue), I6 (filtered views), I10 (tagging as grouping enabler), I14 (comprehension layer), I12 (architect's tool), multi-level coherence.

**Best suited to:** Claude Chat for the full implementation. This is interactive UI work that requires design judgement, Svelte 5 reactive patterns, and iterative refinement — not suitable for Claude Code's batch-oriented style.

---

### Phase 5: SysML Viewpoint/View Investigation

**What:** Research the `viewpoint def` and `view def` constructs in SysML v2, test them in Syside, and assess their suitability for expressing modelled perspectival groupings.

**Why:** The Session 38 discussion established that anticipated, stable viewpoints belong in the SysML model (consistent with A3). But we agreed not to commit to a mechanism until we understand what's available. This phase is the investigation — it produces a finding, not a commitment.

**Tasks:**

1. **Review the SysML v2 specification** for `viewpoint def`, `view def`, `rendering def`, `expose`, and `filter` constructs. What can they express? Can a view select arbitrary elements from across packages? Can views be hierarchically composed (a view containing sub-views)?

2. **Write test cases** in `model/syntax-tests/`:
   - A simple viewpoint selecting elements by type (all `part def`s with a specific tag)
   - A viewpoint composing elements from multiple packages
   - A hierarchical view (top-level groups, each containing sub-selections)
   - A viewpoint with filter criteria

3. **Verify in Syside.** Do the test cases parse? Does Syside render them? Are there limitations?

4. **Assess suitability.** Write a brief findings note:
   - Can `viewpoint def` / `view def` express the kinds of groupings we need?
   - Is Syside support adequate, or are there gaps?
   - What would a generator need to do to produce catalogue-consumable JSON from viewpoint definitions?
   - Recommendation: adopt, defer, or pursue an alternative mechanism.

5. **If viewpoint/view is not adequate**, note what would be needed instead and capture as an open question for Stage 3.

**Deliverable:** Syntax test files in `model/syntax-tests/`. Findings note in Obsidian (`Discussion Papers/ontara-investigation-sysml-viewpoints-2026-MM-DD.md`). Recommendation on whether to adopt viewpoints for modelled perspectival groupings.

**Effort estimate:** 1 session (investigation, not implementation).

**Register concepts exercised:** J3 (non-constraining — investigate before committing), J12 (design decision lifecycle — experimentation phase).

**Best suited to:** Claude Chat for the specification review and test case design. Ella for Syside verification (Claude cannot run Syside). Claude Code could write the test case `.sysml` files from specifications.

---

### Phase 6: Suds Governance Traceability

**What:** Strengthen the COSHH governance requirement in the Suds model to exercise the full `requirement → constraint → satisfy → audit evidence` traceability chain.

**Why:** J8 (governance in toy domains) is a standing commitment. The initial Suds model has a COSHH requirement but does not yet exercise the full satisfy chain. This phase completes the governance picture and validates that the traceability pattern works in a non-health context.

**Tasks:**

1. **Check the syntax reference** for `requirement def`, `satisfy`, and `constraint def` patterns.

2. **Expand the COSHH requirement** in `suds.sysml`:
   - Define the requirement in detail (chemical storage, handling procedures, staff training records, COSHH assessment documentation).
   - Define a `constraint def` that formalises the testable condition (e.g., "all chemicals stored in COSHH-compliant cabinet", "COSHH assessment completed within 12 months").
   - Connect via `satisfy` — which model elements satisfy which constraint.
   - Define the audit evidence pattern — what records demonstrate compliance.

3. **Cross-reference the CSW governance pattern.** The CSW demonstrator may have a lighter governance model. Compare to understand what's General about governance traceability and what's domain-Tailored.

4. **Tag the governance elements** with `@Tag { dimension = "concern"; tagValue = "Governance"; }`.

5. **Verify the traceability chain appears in the generated JSON** and is visible in the catalogue and coverage matrix.

**Deliverable:** Expanded governance model in `suds.sysml` with full satisfy traceability. Governance elements visible in the catalogue and coverage matrix.

**Effort estimate:** 1 session.

**Register concepts exercised:** A8 (governance as first-class concern), J8 (governance in toy domains), B2 (vertical mappings — requirement to audit evidence).

**Best suited to:** Claude Chat for the design. Claude Code for the mechanical SysML writing once the structure is agreed.

---

## 4. Data Flow Summary (Stage 2)

The Stage 1 data flow remains unchanged. Stage 2 extends it with richer metadata:

```
SysML model files (.sysml)
  ├── @Tag annotations (new)
  ├── @UserFacing annotations (new)
  └── existing structure (packages, part defs, part usages, requirements)
    │
    ▼
gen_model_introspection.py (extended in Phase 2)
    │
    ▼
generated/ontara/model-introspection.json
  ├── elements with tag facets (new)
  ├── elements with userFacing metadata (new)
  ├── facet summary (new)
  └── existing coverage matrix data
    │
    ▼ (copied to console/static/data/)
    │
    ▼
Console SvelteKit app
  ├── /coverage — coverage matrix (Stage 1, unchanged)
  ├── /packages — package navigator (Stage 1, unchanged)
  └── /catalogue — Component Catalogue (new, Phase 4)
       ├── "Group by" axis control
       ├── Grouped element list with progressive decomposition
       ├── Element detail with comprehension layer
       └── Cross-links to /coverage
```

---

## 5. Dependencies and Prerequisites

| Phase | Depends on | Notes |
|---|---|---|
| Phase 1 (Tag metadata in SysML) | Stage 1 complete | Ella validates `@Tag` syntax in Syside — critical path |
| Phase 2 (Generator extension) | Phase 1 | Needs tagged model content to extract |
| Phase 3 (Suds expansion) | Phase 1 (for tagging Suds content) | Can begin structural expansion before Phase 1 completes |
| Phase 4 (Catalogue view) | Phase 2 (JSON with facets) | Core console work |
| Phase 5 (Viewpoint investigation) | Nothing — can run any time | Independent research |
| Phase 6 (Suds governance) | Phase 1 (for tagging) | Can run in parallel with Phase 4 |

**Critical path:** Phase 1 → Phase 2 → Phase 4. Phases 3, 5, and 6 are parallel tracks.

**Syside validation checkpoints:** Phase 1 (new metadata defs) and Phase 5 (viewpoint tests) both require Ella to validate in Syside. These are the two points where Claude's work pauses for validation.

---

## 6. Estimated Total Effort

| Phase | Estimate |
|---|---|
| Phase 1: Tag metadata in SysML | 1–2 sessions |
| Phase 2: Generator extension | 1 session |
| Phase 3: Suds full BMM coverage | 2–3 sessions |
| Phase 4: Component Catalogue view | 2–3 sessions |
| Phase 5: Viewpoint investigation | 1 session |
| Phase 6: Suds governance traceability | 1 session |
| **Total** | **8–11 sessions** |

As with Stage 1, this is a rough guide. Some phases may go faster (Phase 2 extends existing code), some may surface issues (Phase 1 syntax validation, Phase 5 findings).

---

## 7. Stage 2 Exit Criteria

Stage 2 is complete when:

- [ ] `@Tag` metadata def exists in `Foundation::MetadataLibrary` and validates in Syside
- [ ] `@UserFacing` metadata def exists in `Foundation::MetadataLibrary` and validates in Syside
- [ ] BMM `part def`s are tagged with at least "concern" and "classification" dimensions
- [ ] At least 10–15 BMM `part def`s have `@UserFacing` friendly names and short descriptions
- [ ] The generator produces JSON with tag facets, user-facing metadata, and facet summaries
- [ ] The Component Catalogue view (`/catalogue`) is working with multi-axis "group by" and element detail
- [ ] Catalogue displays friendly names where available and falls back to SysML identifiers where not
- [ ] Suds model has full BMM coverage comparable to CSW, with COSHH satisfy traceability chain
- [ ] Suds design note written with General/Tailored classification observations
- [ ] SysML viewpoint/view investigation completed with findings documented
- [ ] Cross-links between catalogue and coverage matrix are working
- [ ] Session report written and master register reviewed
- [ ] Stage 3 detailed plan produced

---

## 8. What This Plan Defers

- **User-defined groupings** — agreed to be on the roadmap but not Stage 2. The console presents system-defined grouping axes derived from model metadata.
- **Console-layer annotation on coverage matrix cells** — agreed approach for "N/A" / "deferred" states, but not prioritised for Stage 2 unless the need becomes pressing.
- **Modelled perspectival groupings in SysML** — Phase 5 investigates the mechanism; actual modelling of viewpoints is Stage 3 at earliest.
- **Dual-canvas / assembly workspace** — Stage 3 (I2, I9).
- **Pattern Graph view** — Stage 3.
- **Paws domain model** — Stage 3. Stage 2 focuses on deepening Suds.
- **Glossary view** (I15) — The `@UserFacing` metadata created in Stage 2 is the data foundation for the glossary. The glossary UI view is a natural Stage 3 addition.
- **BSMM extraction** (O2) — remains an identified gap. Stage 2 focuses on BMM elements. BSMM tagging and catalogue presentation is a natural Stage 3 extension.

---

## 9. Master Register Concepts Relevant to Stage 2

**Directly exercised:**

| Concept | How |
|---|---|
| A3 (model generates everything) | `@Tag` and `@UserFacing` metadata in the model, generated into console JSON |
| A5 (validate in toy domains) | Suds expansion and cross-domain comparison |
| A8 (governance first-class) | Suds COSHH satisfy traceability chain |
| B11 (General/Tailored) | Applied as a tag dimension, discovered through Suds comparison |
| D9 (metadata-driven generation) | Generator extended to extract new metadata types |
| I7 (Component Catalogue) | Built as the primary Stage 2 console deliverable |
| I10 (tagging system) | `@Tag` metadata def defined and applied |
| I14/I14a (comprehension layer) | `@UserFacing` metadata and console rendering |
| I12 (console as architect's tool) | Catalogue designed for Ella's cognitive style |
| J1 (cross-domain validation) | Suds full BMM coverage |
| J2 (co-evolution) | Model metadata and catalogue view built together |
| J3 (non-constraining) | Flexible tag mechanism, viewpoint investigation before commitment |
| J8 (governance in toy domains) | Suds COSHH satisfy chain |
| J12 (design decision lifecycle) | Tag mechanism at "experimentation" phase, viewpoints at "investigation" |

**At risk of neglect (monitor):**

| Concept | Risk |
|---|---|
| I4 Level 2/3 (pattern and meta model adequacy tracking) | Stage 2 focuses on Level 1 (instance coverage). Level 2/3 remain unaddressed. |
| B12 (horizontal mappings) | Business ↔ system side mappings not yet addressed. Console currently shows BMM only. |
| O2 (BSMM extraction) | Becomes more pressing as the catalogue needs to present both meta models. |
| I11 (progressive validation) | Not yet implemented. Will become relevant when assembly workspace is built. |

---

## 10. Claude Code / Cowork Task Identification

For reference when executing the plan:

| Phase | Claude Chat | Claude Code | Ella |
|---|---|---|---|
| Phase 1 | Metadata def design, tag assignment decisions | Bulk `@Tag` application across `part def`s | Syside validation |
| Phase 2 | Generator design and implementation | Mechanical JSON restructuring if needed | Review output |
| Phase 3 | Design decisions on what to model | Mechanical SysML writing from agreed specs | Syside validation |
| Phase 4 | Full catalogue UI implementation | — | Review and feedback |
| Phase 5 | Specification review, test case design | Write test `.sysml` files from specs | Syside validation |
| Phase 6 | Governance traceability design | SysML writing from agreed specs | Syside validation |

---

*Stage 2 implementation plan prepared 19 March 2026 (Session 38). For review and agreement before implementation begins.*
