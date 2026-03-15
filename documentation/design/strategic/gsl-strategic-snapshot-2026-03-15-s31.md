# GenderSense SysML Model — Strategic Snapshot

**Date:** 15 March 2026 (Session 31)
**Prepared by:** Claude (from direct review of the codebase and sessions 30–31)
**Scope:** The `gsl-sysml-model` project in its entirety
**Changes from previous version (Session 30):** Knowledge Graph Enhancement complete. PatternCatalogue now includes 8 `ArchitecturalPrinciple` instances, typed `ref` relationship fields on `Pattern`, and ~43 semantic relationships across 20 patterns. Generator reads SysML natively (YAML fallback retained). Obsidian vault updated to two-layer architecture. Syntax reference v3.13 with `ref :>>` tuple redefinition verified. Claude Code validated as handoff tool for Python implementation tasks.

---

## 1. What This Project Is

GenderSense Limited is building a model-driven clinical service management platform for gender-affirming healthcare. The `gsl-sysml-model` project is the representation layer: a SysML v2 model that serves as the single source of truth for what the business is, how its clinical services work, what rules govern them, and how the technology platform supports them.

The architectural thesis — validated through a running coffee shop demonstrator application and now extended across the full business system — is that the model generates the execution layer rather than merely documenting it. The model now also describes its own architectural patterns and the semantic relationships between them.

---

## 2. Scale and Maturity

### The model

| Metric | Value |
|---|---|
| Top-level packages | 11 (Enterprise, Foundation, Knowledge, ServiceDelivery, Platform, Operations, BusinessModel, BusinessScenarios, BusinessStrategy, PatternCatalogue, GenderSense root) |
| Total packages | 73 |
| Model files | 11 `.sysml` files |
| Largest file | `knowledge.sysml` — 114 KB |
| PatternCatalogue | 22 patterns, 8 principles, 33 domain instantiations, ~43 typed ref relationships |
| Concept graph (Obsidian) | ~37 notes (17 patterns, 8 principles, 3 domains, 1 deferred, 3 templates, indices) |

### The demonstrator

| Metric | Value |
|---|---|
| Frontend pages | 9 (Counter, Order Board, Management/Catalogue, Records, Audit Dashboard, Customer Voice, Pathway, System Status, Order Detail + Audit sub-pages) |
| API routes | 19 |
| Temporal workflows | 1 (FulfilDrink with XState lifecycle) |
| CDR integration | 3 archetypes, AQL queries, governance audit |
| PostgreSQL tables | 4 |
| Generated artefacts | TypeScript types, XState machine, Temporal workflow scaffold, Mermaid diagrams, concept graph views |
| Stack | SvelteKit + Tailwind v4 + Flowbite Svelte, Temporal, EHRbase, PostgreSQL |

### Sessions

| Range | Focus |
|---|---|
| 1–4 | Coffee shop demonstrator Phases A–D |
| 5–7 | Hormone therapy initiation clinical pathway |
| 8–12 | Knowledge layer elaboration (5 phases) |
| 13–19 | Business meta model (7 phases) |
| 20–29 | CSW Extension (10 phases) |
| 30 | Concept Graph workstream Stages 1–4 |
| **31** | **Knowledge Graph Enhancement Stages 1–6 (complete)** |

---

## 3. What Was Built in Session 31

### Knowledge Graph: SysML-Native Semantic Relationships

The PatternCatalogue now carries typed semantic relationships between patterns and architectural principles, all validated by Syside at parse time:

- **`ArchitecturalPrinciple` part def** with 8 instances (separation of representation/execution, self-describing system, model generates everything, two meta model distinction, coffeeshop first, deterministic reasoning, patient autonomy, clinical governance)
- **8 typed `ref` fields on `Pattern`** — dependsOn, enables, motivatedBy, generalises, constrains, extends, validatedBy, composedWith (all `[0..*]`)
- **`RelationshipKind` enum** — 9 predicates for future structured relationship parts
- **43 `ref :>>` redefinitions** across 20 patterns encoding the complete semantic relationship layer
- **Tuple syntax verified** — `ref :>> dependsOn = (patternA, patternB);` including circular refs, cross-type refs, and forward references

### Generator Pipeline: SysML-Native

`gen_concept_graph.py` refactored to read `ref :>>` redefinitions directly from SysML (default source). Infers cross-domain analogues from shared `DomainInstantiation` naming convention. Produces 6 Mermaid views: overview, dependencies, motivation, analogues, maturity, impact. YAML fallback via `--source=yaml`.

### Two-Layer Architecture Established

The concept graph now operates on a clear two-layer architecture:
1. **SysML** — source of truth for patterns, principles, relationships, instantiations
2. **Obsidian** — navigation and discursive layer for design rationale, open questions, clinical analogues

Generators sit between: they read SysML and produce human-consumable views (Mermaid, and potentially Obsidian note stubs in future).

### Claude Code Handoff Validated

Stage 4 (generator refactor) was successfully delegated to Claude Code. The hybrid workflow — Chat for SysML modelling and verification, Code for Python implementation — proved effective.

---

## 4. Validated Architectural Patterns (22)

### Business meta model (4)

| Pattern | Status | CSW | GSL |
|---|---|---|---|
| Four-layer item model | validated | ✓ | discussion |
| Activity taxonomy | validated | ✓ | ✓ |
| Scenario comparison and projection | validated | — | ✓ |
| Persistence policy as queryable reasoning | validated | ✓ | — |

### Business system meta model (16)

| Pattern | Status | CSW | GSL |
|---|---|---|---|
| SysML v2 as single source of truth | validated | ✓ | ✓ |
| Two-layer pathway modelling | validated | ✓ | ✓ |
| Five-layer self-knowledge | validated | — | ✓ |
| Three-persistence-layer architecture | validated | ✓ | designed |
| Metadata-driven generation | validated | ✓ | ✓ |
| XState in Temporal | validated | ✓ | — |
| Catalogue-as-UI-contract | validated | ✓ | — |
| Kanban-as-process-dashboard | validated | ✓ | — |
| Split-view management layout | validated | ✓ | — |
| Category-conditional form fields | validated | ✓ | — |
| Cross-page data consistency | validated | ✓ | — |
| Audit-as-timeline data source | validated | ✓ | — |
| Process + domain + governance unified view | validated | ✓ | — |
| CDR source provenance badges | validated | ✓ | — |
| Auto-loading entity views | validated | ✓ | — |
| Infrastructure health as app concern | validated | ✓ | — |

### Cross-cutting (1)

| Pattern | Status |
|---|---|
| Coffee shop demonstrator as standing practice | validated |

### Deferred/conceptual (6)

| Pattern | Status |
|---|---|
| Composite order / multi-workflow orchestration | discussion |
| Agency classification on actions | designed |
| Self-assessment dashboard (KL Increment 3) | designed |
| OptionEvaluator / Help Me Choose | designed |
| Data release model (patient-facing) | discussion |
| Notification triggers on transitions | discussion |

---

## 5. Current Architecture

```
Representation Layer (SysML v2)          Execution Layer
├── Enterprise (org, regulation)         ├── SvelteKit frontend (9 pages)
├── Foundation (metadata, types, state)  ├── Temporal workflows (FulfilDrink)
├── Knowledge (CDS, self-knowledge)      ├── XState v5 (OrderLifecycle)
├── ServiceDelivery (pathways, consent)  ├── EHRbase CDR (3 archetypes)
├── Platform (portal, EHR, booking)      ├── PostgreSQL (4 tables)
├── Operations (finance, people)         └── Generation pipeline (5 generators)
├── BusinessModel (concept, activity)
├── BusinessScenarios (projection)
├── BusinessStrategy (objectives)
└── PatternCatalogue (22 patterns,       → Mermaid views (6), Obsidian vault
     8 principles, 43 relationships)
```

---

## 6. Key Risks and Decisions Ahead

1. **No second pathway yet.** The architecture claims to generalise — a second clinical pathway would prove it.
2. **Knowledge Layer Increments unstarted.** Three landing zones built; constraint evaluation, decision tables, and self-assessment remain unexercised.
3. **Generation pipeline partial.** Four generators operational; five more designed but not built.
4. **Single developer.** Ella is sole developer, architect, and domain expert. The model-driven approach mitigates this (knowledge is in the model, not in someone's head) but execution bandwidth is limited.
5. **Clinical data layer untouched since Phase E.** CDR integration patterns validated; clinical archetypes not yet designed for GSL production use.

---

## 7. What Comes Next

Candidate workstreams (no active workstream):

1. **Knowledge Layer Increments 1–3** — constraint evaluation, decision tables, self-assessment. All landing zones ready. Highest-value next step for proving the knowledge architecture.
2. **Second Clinical Pathway** — proves generalisation. Triggers cross-pathway rule sharing.
3. **Model Consolidation Review** — full audit at workstream boundary. Recommended before starting a major new workstream.
4. **Hookmark Spike** — cross-desktop linking. Low effort, high convenience.

---

*Strategic snapshot prepared 15 March 2026 (Session 31).*
