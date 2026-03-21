# Ontara — Stage 4 High-Level Plan: Structural Navigation and Construction

**Date:** 21 March 2026 (Session 57)
**Prepared by:** Claude, in discussion with Ella Green
**Builds on:** Stage 3 completion (Sessions 37–57), [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]] (E001–E008), [[ontara-ref-master-register-design-concepts-tiered-2026-03-20|Master Concept Register]]
**Status:** High-level plan — for review, discussion and refinement

---

## 1. Where We Are

Stage 3 (Comprehension and Cross-Domain Validation) is closing with Phase 5. Its achievements:

- **Three demonstrator domains** ([[domain-cafe|Cafe]], [[domain-suds|Suds]], [[domain-paws|Paws]]) with full BMM coverage — the [[concept-cross-domain-validation|cross-domain validation]] threshold met.
- **28 BMM elements** with 100% annotation coverage (`@CatalogueTag`, `@UserFacing`, `@PurposiveDescription`, `@Comprehension`).
- **79 [[concept-weighted-relationships|weighted relationships]]** across 27 weighted elements, with directional semantics, five heuristics, and a full [[ontara-ref-weighted-relationship-heuristics-and-config-2026-03-21|configuration reference]].
- **[[concept-comprehension-layer|Comprehension layer]]** working end-to-end: model annotations → generator → console glossary with weight-aware dot bar, inline expand/collapse, and cross-links.
- **Service subject ≠ customer resolved** — ServiceSubject and ServiceParticipant as sibling General BMM concepts.
- **Phase 5 ([[deferred-string-to-typed-ref-migration|O25]])** — typed ref migration — closes the remaining structural debt, unlocking cross-package weight traversal.
- **Vault fully reorganised** — consistent naming, binding wikilink rule, comprehensive enrichment.

The console now makes the model comprehensible element-by-element. What it does not yet do is make the model **navigable as a connected structure** — the relationships between elements are described in the glossary but not traversable visually — or **constructible** — the user cannot yet build or modify model configurations through the console.

---

## 2. Stage 4 Objective

**Make the model's structure visually navigable and begin the transition from comprehension to construction.**

Stage 3 answered "what is each element?" Stage 4 answers "how do the elements relate to each other?" and begins answering "how do I build something with them?" This transition from comprehension to construction operationalises the [[ontara-ref-vision-architecture|Ontara vision]] of a platform that is not just self-describing ([[principle-self-describing-system|A2]]) but actively supports the architect in composing new service businesses.

---

## 3. Stage 4 Phases

### Phase 1 — Weighted Relationship Graph

**Source:** [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]] E001, E008

**Objective:** An interactive force-directed graph view in the Ontara Console displaying BMM elements as nodes and weighted relationships as directed edges. The visual face of the comprehension layer — making the relationship structure that is currently buried in annotation metadata directly visible and explorable.

**Deliverables:**
- Interactive force-directed graph (D3.js) in the console
- Nodes sized by connectivity, coloured by BMM concern
- Directed edges coloured/styled by relationship strength (strong/moderate/weak)
- Click-to-focus: selecting a node highlights its direct relationships and shows the element's glossary entry
- Filter by BMM concern, relationship strength, or individual element
- Bidirectional linking: graph ↔ glossary (click a node → scroll to glossary entry; click a glossary entry → highlight in graph)

**Model work:** None — the data already exists in `@WeightedRelationship` annotations and is extracted into `model-introspection.json`. This is a pure console phase.

**Relationship to E008:** The weighted relationship configuration table (E008) is a complementary tabular view of the same data. It could be delivered alongside the graph as a second tab within the same view, or as a Phase 1b follow-on. The table supports systematic review; the graph supports spatial intuition. Both consume the same JSON data.

### Phase 2 — Cross-Package Navigation

**Objective:** Make the console navigable *across* views, not just within them. Currently each view (glossary, coverage matrix, component catalogue, governance) is self-contained. Phase 2 connects them.

**Deliverables:**
- **Deep linking:** Every element in every view has a stable URL. Clicking a cross-reference in the glossary navigates to that element's entry in the component catalogue (or vice versa).
- **Breadcrumb navigation:** Show the user's current position in the model hierarchy (package → sub-package → element) with clickable ancestors.
- **Typed ref navigation:** With Phase 5 (O25) complete, the model contains formal typed references between elements. The console should surface these as navigable links — "this CostDriver references this ResourceType" becomes a clickable connection.
- **"Where is this used?" panel:** For any element, show all places it appears — which domains instantiate it, which elements reference it (via typed refs), which weighted relationships involve it.

**Model work:** Minimal — depends on Phase 5 typed refs being complete.

### Phase 3 — BMM Concern Group Descriptions (E003)

**Objective:** Package-level purposive descriptions in the glossary (per the E003 plan produced in this session). Gated on the syntax spike for metadata annotations on `package` declarations.

**Deliverables:**
- `@PurposiveDescription` on five BMM sub-packages
- Generator extended to extract package-level annotations
- Glossary displays concern-level description panel when filtering by BMM Concern

**Note:** This is a small, self-contained phase. It may be executed alongside Phase 1 or Phase 2 depending on the syntax spike result.

### Phase 4 — Structural Completeness Visualisation

**Objective:** Answer "what's missing?" visually. The coverage matrix already shows which elements are instantiated in which domains. Phase 4 enriches this with completeness assessment.

**Deliverables:**
- **Completeness heatmap:** Extend the coverage matrix with colour coding — fully instantiated (all required elements present) → partially instantiated → minimal → unmodelled.
- **Gap identification:** For each domain, list the BMM elements that have not yet been instantiated, grouped by concern.
- **Pattern coverage overlay:** Show which of the 22 validated patterns have been exercised in each domain (currently tracked in the register but not visualised).
- **Completeness levels (I4):** Level 1 (instance coverage), Level 2 (pattern coverage), Level 3 (meta model adequacy) — display all three.

**Model work:** May require additional metadata to define "required" vs "optional" elements per domain context. This connects to the meta model subsetting / templating question (B9, O15) — which elements are *expected* for a given type of business?

### Phase 5 — Assembly Workspace Prototype

**Objective:** The first step toward construction. A workspace where the user can select BMM elements to include in a new business model configuration, with real-time completeness feedback.

This is the beginning of the dual-canvas vision (I2) — but starting with the business canvas only, and starting with selection (checkbox/toggle) rather than drag-and-drop. The full drag-and-drop canvas (I9) with Svelvet/Svelte Flow is a future evolution. The dependency hints operationalise [[principle-unity-principle|A11 (unity principle)]] — the same weight data that informs comprehension now guides construction.

**Deliverables:**
- **Configuration builder:** A view that shows all General BMM elements as a checklist/toggle set. The user selects which elements apply to their business. As elements are selected, completeness indicators update.
- **Dependency hints:** When an element is selected, related elements (via weighted relationships) are highlighted — "if you include ServiceOffering, you probably also need PricingModel (strong) and Channel (moderate)."
- **Configuration export:** Save the selection as a named configuration (the seed of a Model Catalogue entry, I8).
- **Feedback loop to glossary:** From the assembly workspace, the user can drill into any element's glossary entry for its purposive description and comprehension content.

**Model work:** Mechanism for representing Model Catalogue entries in SysML (O18 — currently unresolved). This is a design question that should be addressed during Phase 5 detailed planning.

---

## 4. Cross-Cutting Concerns

### 4.1 Strategic snapshot update

The current strategic snapshot (Session 48) predates the completion of Stage 3. A revised snapshot should be produced at the close of Stage 3 (after Phase 5 implementation) or at the start of Stage 4 Phase 1. This ensures the governance documentation reflects the current state before new work begins.

### 4.2 BSMM extraction (O2)

The dual-canvas vision requires the BSMM to be as navigable as the BMM. Currently BSMM concepts are distributed across Foundation, Knowledge, ServiceDelivery, Platform, Operations, PatternCatalogue. Stage 4 Phase 5 (assembly workspace) will surface this as a practical issue — the system canvas needs a BSMM equivalent of the BMM Component Catalogue. BSMM extraction should be planned as a Stage 4 or Stage 5 workstream.

### 4.3 Emergent ideas integration

Several emergent ideas (E001–E008) feed directly into Stage 4:

| Idea | Feeds into |
|---|---|
| E001 (graph visualisation) | Phase 1 |
| E003 (BMM concern text) | Phase 3 |
| E008 (configuration table) | Phase 1b or Phase 2 |
| E005 (temporality) | Deferred — discussion paper needed, not Stage 4 scope |
| E007 (Hookmark) | Standing practice improvement, not a phase |

### 4.4 Reasoning formalisms (M7)

Stage 4 does not depend on resolving the reasoning formalisms question. The graph visualisation and assembly workspace use the existing ordinal weight data. Inferential comprehension (Register 2+, I18) remains a horizon capability that Stage 4 prepares for but does not implement.

---

## 5. Sequencing and Dependencies

```
Phase 5 (O25, typed refs) ──┐
                             ├─── Phase 1 (Graph view)
E003 syntax spike ───────────┤
                             ├─── Phase 3 (Concern descriptions)
                             │
Phase 1 ─────────────────────┼─── Phase 2 (Cross-package navigation)
                             │
Phase 2 ─────────────────────┼─── Phase 4 (Completeness visualisation)
                             │
Phase 4 ─────────────────────┴─── Phase 5 (Assembly workspace prototype)
```

Phase 1 and Phase 3 can run in parallel. Phases 2–5 are sequential.

---

## 6. Execution Approach

Each phase should follow the established workflow: detailed implementation plan → discussion → agreement → implementation → session report. Per the workflow guide, detailed plans should identify which steps are best suited to Claude Code, Claude Chat, or Claude Cowork.

**Estimated scope:** Phase 1 is the largest (D3.js graph view, likely 2–3 sessions). Phase 3 is the smallest (1 session or less). Phases 2, 4, 5 are moderate (1–2 sessions each). Total: approximately 7–12 sessions for Stage 4.

---

## 7. Concept Register Impacts

**Concepts exercised:**
- [[principle-intrinsic-self-knowledge|A10]] (intrinsic self-knowledge) — graph and assembly workspace show what the model knows about its own structure
- [[principle-unity-principle|A11]] (unity principle) — weight data driving comprehension (glossary), navigation (graph), and construction guidance (assembly hints)
- [[concept-weighted-relationships|B14]] (weighted relationships) — the primary data source for the graph view
- [[pattern-metadata-driven-generation|D9]] (metadata-driven generation) — all views consume generated JSON from model metadata
- I2 (dual canvas) — Phase 5 begins the business canvas
- I4 (three completeness levels) — Phase 4
- I7 (Component Catalogue) — cross-linked from all new views
- I8 (Model Catalogue) — Phase 5 creates the first entries
- I9 (assembly workspace) — Phase 5 prototype
- I11 (progressive validation) — Phase 5
- [[concept-co-evolution|J2]] (co-evolution) — every phase includes both console and model considerations

**New concepts likely to emerge:**
- Concept for the graph view (I-section, new entry)
- Concept for the configuration table (I-section, new entry)
- Concept for deep-linking/cross-view navigation (I-section, new entry)
- Resolution of O18 (SysML mechanism for Model Catalogue entries)

---

## 8. What Stage 4 Does Not Cover

- **System canvas / BSMM side of the dual canvas.** Stage 4 builds the business canvas only.
- **Drag-and-drop canvas interaction.** Stage 4 uses selection/toggle, not spatial DnD.
- **Inferential comprehension (Register 2+, I18).** The reasoning engine is not implemented in Stage 4.
- **Second clinical pathway.** Remains a separate workstream.
- **Temporality as architectural concern (E005/E006).** Needs a discussion paper, not implementation.
- **Simulation (L1–L4).** Horizon capability.

---

## 9. Immediate Next Steps

1. **Ella reviews this plan.** Discussion and refinement.
2. **Complete Phase 5 (O25) implementation** — the typed ref migration that closes Stage 3.
3. **E003 syntax spike** — verify metadata annotations on packages.
4. **Strategic snapshot update** — revised snapshot at Stage 3/4 boundary.
5. **Detailed implementation plan for Stage 4 Phase 1** — the weighted relationship graph view.

---

*High-level plan prepared 21 March 2026, Session 57. For review and refinement by Ella Green.*
