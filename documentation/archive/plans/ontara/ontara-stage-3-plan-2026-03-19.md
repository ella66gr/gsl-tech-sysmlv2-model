# Ontara — Stage 3 Detailed Plan

**Date:** 19 March 2026 (Session 43)
**Prepared by:** Claude, in discussion with Ella Green
**Status:** Working document — for review and agreement
**Parent plan:** [[ontara-high-level-plan-2026-03-18|Ontara High-Level Development Plan]]
**Prerequisite:** Stage 2 complete (13/13 exit criteria met with this document)
**Informed by:** [[ontara-stage-2-plan-2026-03-19|Stage 2 Plan]] §8 (deferrals), [[ontara-investigation-sysml-viewpoints-2026-03-19|Viewpoint Investigation findings]], [[ontara-master-register-design-concepts-2026-03-17|Master Concept Register]]

---

## 1. Objective

Stage 3 extends the Ontara platform along three axes: **breadth** (third demonstrator domain), **depth** (modelled views, glossary, pattern graph), and **structural clarity** (BSMM extraction). By the end of Stage 3, the platform should demonstrate that the meta model and tooling generalise convincingly across three domains, that the console provides multiple complementary navigation perspectives, and that both business and system meta models are explicitly named and navigable.

Stage 3 builds on the strong foundations of Stage 2: the Component Catalogue with multi-axis grouping, the governance traceability chain, the `@CatalogueTag` and `@UserFacing` metadata system, and the confirmed SysML viewpoint/view syntax support.

---

## 2. Design Principles Entering Stage 3

These carry forward from Stage 2 and the master register. Stage 3 does not introduce new foundational principles — it operationalises existing ones at greater scale.

| Principle | Stage 3 relevance |
|---|---|
| [[concept-cross-domain-validation\|J1]] (cross-domain validation) | Paws is the third domain. Three-domain validation is the threshold for confident generalisation. |
| [[concept-co-evolution\|J2]] (co-evolution) | Every model extension has a corresponding console or generator extension. |
| [[concept-non-constraining\|J3]] (non-constraining) | Modelled views enter "experimentation" phase (J12). BSMM extraction must not break existing model structure. |
| [[concept-model-generates-everything\|A3]] (model generates everything) | Modelled views, glossary data, and pattern graph all generated from the SysML model. |
| [[concept-design-decision-lifecycle\|J12]] (design decision lifecycle) | Several Stage 2 "experimentation" items (tagging, viewpoints) may advance to "discovered convention." |

---

## 3. Phasing

Stage 3 is divided into seven phases. The ordering reflects dependencies but allows some parallelism. Each phase has clear deliverables and should be reviewable before the next begins. Detailed implementation plans will be produced at the start of each phase, as established in Stage 2.

### Phase 1: Paws Domain Model (2–3 sessions)

**What:** Create the Paws (dog grooming) demonstrator domain, modelling all five BMM concerns at comparable depth to Cafe and Suds. Write a Paws design note with General/Tailored observations.

**Why:** Three-domain validation (J1). Paws is deliberately different from Cafe (hospitality/retail) and Suds (laundry/processing) — it's an appointment-based personal service business. This exercises the meta model in a new interaction pattern: scheduled appointments, variable service durations, client/animal relationships, repeat bookings.

**Key questions:**
- Does the BMM vocabulary accommodate appointment-based services without strain?
- Does `ServiceOffering` need specialisation for services with variable duration?
- What governance requirements apply? (Animal welfare, insurance, health & safety — distinct from COSHH)
- How does the client/pet relationship map to BMM concepts? (Customer → CustomerSegment, but the "service recipient" is the animal, not the paying customer)

**Deliverables:**
- `exercises/paws-demonstrator/model/paws.sysml` — full domain model
- Paws design note in Obsidian `Demonstrators/Paws (Dog Grooming)/`
- Generator re-run producing updated JSON with three-domain coverage matrix
- `@CatalogueTag` and `@UserFacing` annotations on any new Paws-specific part defs

**Register concepts exercised:** J1, A5, B11, J8 (governance in toy domains), C1–C6.

**Best suited to:** Claude Chat for design decisions and model writing. Claude Code for mechanical application of `@CatalogueTag` annotations once the model structure is agreed. Ella for Syside validation.

---

### Phase 2: Glossary View (1–2 sessions)

**What:** Build the Glossary view in the console — a searchable, browsable list of all `@UserFacing` elements with friendly names, short descriptions, and cross-references.

**Why:** The `@UserFacing` metadata created in Stage 2 is the data foundation for the glossary. The glossary operationalises I15 and completes the comprehension layer (I14). Sam (the non-technical future user) needs a way to look up terms.

**Tasks:**
- Build `/glossary` console page with alphabetical listing, search, and filtering by BMM concern
- Each glossary entry shows: friendly name, SysML identifier, short description, doc block excerpt, tags, domain instantiation count
- Cross-links to Component Catalogue element detail and coverage matrix
- Coverage stat: "N of M elements have glossary entries"

**Deliverables:**
- Working `/glossary` page in the console
- Sidebar navigation updated

**Register concepts exercised:** I15 (glossary), I14 (comprehension layer), [[concept-co-evolution\|J2]] (co-evolution — metadata + view).

**Best suited to:** Claude Chat for full implementation. Interactive UI work requiring Svelte 5 patterns.

---

### Phase 3: Expand @UserFacing Coverage (1 session)

**What:** Extend `@UserFacing` annotations to achieve ≥75% coverage of BMM `part def`s. Currently at 12 elements (41.7%). Target: 18–20 elements.

**Why:** The glossary is only useful if most elements have friendly names and descriptions. This is a co-evolution (J2) obligation — the glossary view exists (Phase 2), so the model data must keep pace.

**Deliverables:**
- Updated `business-model.sysml` with additional `@UserFacing` annotations
- Generator re-run
- Glossary and catalogue reflecting the expanded coverage

**Register concepts exercised:** I14/I14a, J2, D9.

**Best suited to:** Claude Code for the mechanical annotation application (following agreed descriptions). Claude Chat for drafting the friendly names and short descriptions. Instructions for Code: "In `model/business-model.sysml`, add `@UserFacing { friendlyName = \"...\"; shortDescription = \"...\"; }` to each `part def` listed in [file], using Position A (prefix). Verify no syntax errors."

---

### Phase 4: Modelled Views — Experimentation (2–3 sessions)

**What:** Define a small set of modelled views in the SysML model, extend the generator to extract them, and add a "Curated Views" section to the Component Catalogue.

**Why:** The Phase 5 investigation (Session 43) confirmed that `view def`, `view`, `expose`, and `filter` work in Syside 0.8.5, including cross-package expose with view evaluation in the visualizer. This phase moves from "investigation" to "experimentation" (J12).

**Tasks:**
1. **Define 3–5 initial views** in a new `Foundation::ViewDefinitions` package (or co-located with the model packages they relate to — to be decided):
   - Governance Elements View — all governance-related elements across domains
   - Financial Model View — cost drivers, pricing, unit economics, projections
   - Service Concept View — service offerings, value propositions, customer segments
   - Cross-Domain Coverage View — elements instantiated in all three domains
   - (Optionally) a viewpoint def for each, documenting the stakeholder concern

2. **Extend the generator** to parse `view` usages and `expose` declarations, resolve exposed elements, and produce a `views` section in the JSON.

3. **Add "Curated Views" to the Component Catalogue** — a section listing modelled views. Clicking a view shows its exposed elements using the existing catalogue element rendering (friendly names, tags, domain instantiation). This complements the existing dynamic "group by" axes.

**Open questions to resolve at phase start:**
- Where should view definitions live? `Foundation::ViewDefinitions`, a new top-level `Views` package, or alongside the packages they expose?
- Should views satisfy viewpoints (the spec's intended relationship), or should we use a simpler typed-ref association?
- Should the generator interpret `filter` expressions, or just pass them through as text?

**Deliverables:**
- View definitions in the SysML model
- Generator extension producing view data in JSON
- Console "Curated Views" section in Component Catalogue
- Design note documenting the view modelling approach

**Register concepts exercised:** A3, J2, J3, J12, O24.

**Best suited to:** Claude Chat for design decisions, generator extension, and console implementation. Claude Code for mechanical SysML writing of view definitions once the pattern is agreed.

---

### Phase 5: Pattern Graph View (2–3 sessions)

**What:** Build a Pattern Graph view in the console — a visual/navigable representation of the 22 validated patterns, their typed relationships (dependsOn, enables, motivatedBy, etc.), and their domain instantiation status.

**Why:** The PatternCatalogue in SysML already contains 22 patterns with 8 principles and 43 typed `ref` relationships (built in Session 31). This is rich structural data that currently exists only in the model files and Obsidian concept notes. The Pattern Graph makes it navigable and visual, consistent with I4 (pattern and meta model adequacy tracking).

**Tasks:**
1. **Extend the generator** (or create a new `gen_pattern_graph.py`) to extract patterns, principles, and their typed `ref` relationships from `pattern-catalogue.sysml`. Produce a graph-ready JSON structure.
2. **Build `/patterns` console page** with:
   - Interactive graph visualisation (D3.js or similar) showing patterns as nodes, relationships as typed edges
   - Node details panel: pattern name, doc block, domain instantiations, related principles
   - Filtering by relationship type (dependsOn, enables, motivatedBy, etc.)
   - Domain overlay: colour-code nodes by instantiation status (CSW/Suds/Paws)
3. **Cross-link to Component Catalogue** — patterns reference the `part def`s they contain; catalogue elements link back to their pattern.

**Deliverables:**
- Pattern graph JSON generation
- Working `/patterns` page with interactive graph
- Cross-links between patterns and catalogue

**Register concepts exercised:** B10 (two-layer concept graph), K (semantic vocabulary), I4 (pattern tracking), D9 (metadata-driven generation).

**Best suited to:** Claude Chat for the full implementation. Graph visualisation requires interactive design judgement.

---

### Phase 6: BSMM Extraction (2–3 sessions)

**What:** Extract the Business System Meta Model into a named, navigable package structure. The BSMM concepts (PersistencePolicy, AgencyClassification, GoalProjection, etc.) are currently distributed across Foundation, Knowledge, ServiceDelivery, Platform, Operations, and PatternCatalogue. This phase promotes them into a named `BusinessSystemModel` (or similar) package.

**Why:** O2 is one of the longest-standing identified gaps. The two meta model distinction (A4) is a load-bearing architectural concept, but only the BMM has explicit package structure. The BSMM exists only implicitly. As the console grows, presenting "both meta models" requires both to be explicitly structured.

**Tasks:**
1. **Audit existing BSMM concepts** — catalogue every `part def`, `metadata def`, `constraint def` etc. that belongs to the BSMM across all current packages.
2. **Design the BSMM package structure** — sub-packages mirroring the BMM's concern-based organisation, or a different structure suited to system concepts (process, platform, data, knowledge, operations).
3. **Implement the extraction** — create the `BusinessSystemModel` package with sub-packages. Move or alias existing BSMM elements. Ensure all cross-references resolve.
4. **Tag BSMM elements** — apply `@CatalogueTag` and `@UserFacing` annotations.
5. **Generator and console updates** — the coverage matrix, catalogue, and any views should now show BSMM elements alongside BMM elements.

**Risk:** This is a structural refactoring that touches many packages. Must be planned carefully to avoid breaking existing cross-references. Non-constraining (J3) — the extraction should not change the semantics of any element, only its location.

**Deliverables:**
- `BusinessSystemModel` package with sub-packages
- All BSMM elements tagged and annotated
- Generator and console showing both meta models
- Design note documenting the extraction decisions

**Register concepts exercised:** A4, B8, O2, O7, N1, N2.

**Best suited to:** Claude Chat for the audit and design. Claude Code for mechanical moves and tag application once the structure is agreed. Ella for Syside validation of cross-reference resolution.

---

### Phase 7: Console Assembly Workspace — Design (1–2 sessions)

**What:** Produce a detailed design for the console assembly workspace (I2, I9) — the dual-canvas concept where a system designer assembles a business model from meta model components. This is **design only**, not implementation. Implementation is Stage 4.

**Why:** The assembly workspace is the Ontara Console's defining feature — the reason it exists beyond being a model browser. But it's premature to implement it before the component catalogue, pattern graph, and both meta models are in place. Stage 3 produces the design so that Stage 4 can implement it with clarity.

**Tasks:**
1. **Requirements capture** — what does Ella (as system designer) need the assembly workspace to do? What interactions? What feedback?
2. **Design the dual-canvas layout** — Business Canvas (left) showing business model components, System Canvas (right) showing system model components, with vertical traceability between them.
3. **Design the assembly interaction** — drag components from the catalogue, configure parameters, see coverage validation, receive guidance from the comprehension layer.
4. **Identify prerequisites** — what model/generator/console capabilities must exist before implementation can begin?

**Deliverables:**
- Assembly workspace design document in Obsidian
- Interaction mockups or wireframes (if useful)
- Stage 4 prerequisites checklist

**Register concepts exercised:** I2 (assembly workspace), I9 (dual canvas), I11 (progressive validation), B12 (horizontal mappings).

**Best suited to:** Claude Chat for the design discussion. Claude Cowork could assist with mockup generation if visual wireframes are desired.

---

## 4. Dependencies and Ordering

```
Phase 1 (Paws) ──────────────────────────────────┐
                                                   │
Phase 2 (Glossary) ──→ Phase 3 (@UserFacing) ─────┤
                                                   │
Phase 4 (Modelled Views) ─────────────────────────┤
                                                   ├──→ Phase 7 (Assembly Design)
Phase 5 (Pattern Graph) ──────────────────────────┤
                                                   │
Phase 6 (BSMM Extraction) ────────────────────────┘
```

- **Phases 1–6 are largely independent** and can be reordered based on priority.
- **Phase 1 (Paws)** should come early — three-domain validation strengthens everything else.
- **Phase 2 → Phase 3** is a sequential dependency (glossary view before expanding coverage makes the coverage gap visible and motivating).
- **Phase 7 (Assembly Design)** comes last as it depends on having the catalogue, patterns, both meta models, and views all in place.

**Suggested ordering:** 1 → 2 → 3 → 4 → 5 → 6 → 7 (but can be adjusted based on energy, interest, and emerging priorities).

---

## 5. Estimated Total Effort

| Phase | Estimate |
|---|---|
| Phase 1: Paws domain model | 2–3 sessions |
| Phase 2: Glossary view | 1–2 sessions |
| Phase 3: @UserFacing expansion | 1 session |
| Phase 4: Modelled views experimentation | 2–3 sessions |
| Phase 5: Pattern Graph view | 2–3 sessions |
| Phase 6: BSMM extraction | 2–3 sessions |
| Phase 7: Assembly workspace design | 1–2 sessions |
| **Total** | **11–17 sessions** |

---

## 6. Stage 3 Exit Criteria

Stage 3 is complete when:

- [ ] Paws domain model created with full BMM coverage and design note written
- [ ] Three-domain coverage matrix operational (Cafe, Suds, Paws)
- [ ] Glossary view working in the console with search and filtering
- [ ] `@UserFacing` coverage ≥75% of BMM `part def`s
- [ ] At least 3 modelled views defined in SysML, generated into JSON, and visible in the console
- [ ] Pattern Graph view working in the console with interactive navigation
- [ ] BSMM extracted into named package structure with tags and annotations
- [ ] Console showing both BMM and BSMM elements in catalogue and coverage matrix
- [ ] Assembly workspace design document produced
- [ ] Session reports written and master register reviewed
- [ ] Stage 4 plan produced (or decision that Stage 4 scope is clear enough to proceed)

---

## 7. What Stage 3 Defers to Stage 4+

- **Assembly workspace implementation** — Stage 3 produces the design; Stage 4 implements.
- **Simulation capability** (L1–L4) — conceptualised but not yet designed in detail.
- **Second clinical pathway** (O3) — architecture claims to generalise but only one pathway exists.
- **Runtime knowledge evaluation** (O1) — constraint evaluators, decision tables at runtime.
- **User-defined groupings** — console-side custom grouping definitions.
- **Form generation from model** (M4) — major surface area, deferred.

---

## 8. Claude Code / Cowork Task Summary

| Phase | Claude Chat | Claude Code | Claude Cowork | Ella |
|---|---|---|---|---|
| Phase 1 (Paws) | Design decisions, model writing | `@CatalogueTag` bulk application | — | Syside validation |
| Phase 2 (Glossary) | Full console implementation | — | — | Review |
| Phase 3 (@UserFacing) | Draft descriptions | Bulk annotation application | — | Review |
| Phase 4 (Views) | Design, generator, console | SysML view writing from specs | — | Syside validation |
| Phase 5 (Pattern Graph) | Full implementation | — | — | Review |
| Phase 6 (BSMM) | Audit, design, generator | Mechanical moves, tagging | — | Syside validation |
| Phase 7 (Assembly Design) | Design discussion | — | Mockup generation | Review, requirements |

---

## 9. Register Concepts Relevant to Stage 3

**Directly exercised:**

| Concept | How |
|---|---|
| A3 (model generates everything) | Views, glossary, pattern graph all generated from model |
| A4 (two meta model distinction) | BSMM extraction makes both meta models explicit |
| A5 (validate in toy domains) | Paws is the third domain |
| B8 (BSMM currently implicit) | Resolved by Phase 6 |
| B10 (two-layer concept graph) | Pattern graph in console |
| B11 (General/Tailored) | Three-domain comparison reveals classification |
| I2 (assembly workspace) | Designed in Phase 7 |
| I4 (pattern tracking) | Pattern graph view |
| I14/I15 (comprehension / glossary) | Glossary view and expanded @UserFacing |
| J1 (cross-domain validation) | Three domains |
| J2 (co-evolution) | Every phase pairs model + tooling |
| J12 (design decision lifecycle) | Modelled views advance from investigation to experimentation |
| O2 (BSMM extraction) | Resolved by Phase 6 |
| O24 (viewpoint investigation) | Findings applied in Phase 4 |

**At risk of neglect (monitor):**

| Concept | Risk |
|---|---|
| B12 (horizontal mappings) | Business ↔ system mappings. Phase 6 creates the structure; horizontal mappings need explicit attention. |
| I11 (progressive validation) | Not implemented until assembly workspace. Phase 7 design should address this. |
| O1 (runtime knowledge evaluation) | Remains deferred. Monitor whether Stage 3 work creates opportunities. |
| O3 (second clinical pathway) | Still only one pathway. Not Stage 3 scope but watch for drift. |

---

*Stage 3 plan prepared 19 March 2026 (Session 43). Stage 2 exit criterion 13/13 met with this document.*
