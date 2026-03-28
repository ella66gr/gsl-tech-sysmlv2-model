# Session 84 — Report

**Date:** 28 March 2026
**Type:** Mixed (Discussion + Housekeeping)
**Continuity:** Follows [[session-83-report-2026-03-28|Session 83]] (YAML frontmatter batch application, [[concept-stakeholder-model|StakeholderModel]] cross-element weight assessment)

---

## Summary

Session 84 departed from the prepared agenda (Stage 4 graph rendering refinements, horizon scoping) at Ella's direction. The session introduced the concept of an architectural "campus walk" — a systematic exercise to describe every structural region of the [[concept-dual-stack-architecture|dual-stack architecture]], using the [[domain-paws|Paws]] demonstrator domain as the illustrative guide.

The session achieved three things: (1) established the naming convention "architectural section" for the bounded regions of the dual-stack architecture, registered as [[ontara-ref-master-register|B27]]; (2) produced detailed descriptions of the first six architectural sections (BFO through to business process patterns — the shared foundation and the complete left stack); and (3) captured an emergent idea ([[ontara-workflow-emergent-ideas-log|E016]]) about the five-facet description template mapping to an `@ArchitecturalLocation` metadata def.

This is Part 1 of a two-part workstream. Part 2 (next session) will cover the right stack (Sections 7–11), cross-cutting concerns (Section 12), and infrastructure sections (Sections 13–20). A discussion paper will follow, then an implementation plan.

The architectural diagram used throughout the session is `ontara_dual_stack_v6_reflective_cross_cut.svg`.

---

## Work Completed

### 1. Architectural Section concept (B27)

The dual-stack architecture diagram contains approximately 20 distinct structural regions — boxes representing layers, stacks, cross-cutting concerns, and infrastructure. Until this session, these regions had no collective name. Ella proposed "section" after considering alternatives (region, zone, division, locus, precinct, enclosure, functional-zone, structural-zone). The term was validated against SysML and [[ontara-ref-kerml-reserved-words|KerML reserved words]] (no conflict), BFO vocabulary (no conflict), and existing Ontara terminology (no ambiguity in context).

**Registered as [[ontara-ref-master-register|B27]]** (Architectural section, T2) in the [[ontara-ref-master-register|master register]]: "A bounded region of the dual-stack architecture with a characteristic purpose, representational formalism, persistence mechanism, and set of interfaces to neighbouring sections."

### 2. Campus walk — Sections 1–6 described

Each section was described using a five-facet template that emerged during the exercise:

1. **Purpose** — what this section is for, what happens here
2. **Representational modality** — what formalism the content takes (OWL 2 DL, SysML v2, runtime state), noting both current state and target (KG-as-canonical direction, [[concept-knowledge-graph|B22]])
3. **Persistence** — where content physically lives
4. **Interfaces** — vertical (instantiation), horizontal (mapping), cross-cutting connections
5. **Paws illustration** — concrete content for the Paws domain, how it arrived here

Sections completed:

| # | Section | Stack | Key points |
|---|---|---|---|
| 1 | BFO — Basic Formal Ontology | Shared | ISO standard upper ontology. OWL 2 DL. Provides categorical framework (Continuant, Occurrent, Role, etc.) that classifies everything below. Mandatory ([[ontara-ref-master-register|B18]]). Invisible to users but determines valid reasoning patterns. |
| 2 | Domain ontologies | Left | Mid-level BFO-aligned ontologies (OGMS, IAO, OCE, GSSO, OBI). OWL 2 DL. Tenant-specific semantic grounding — Paws uses OCE; GSL would use OGMS+GSSO. Multi-tenancy ([[concept-multi-tenancy|A13]]) made concrete through ontology selection. |
| 3 | BMM General vocabulary | Left | 34 part defs across six concerns. SysML v2. The classification engine — raw business information mapped to structural templates. Paws uses exclusively General vocabulary (no Tailored needed). Currently SysML-primary; target KG with SysML as projection. |
| 4 | Business instance (Paws) | Left | Part usages — concrete populated data. SysML v2. 51+ elements across services, people, spaces, finance, stakeholders. Relation binding happens here. User has most agency at this layer. |
| 5 | Operational domains | Left (green container) | How the business actually operates — in business language, not system language. Nine domains identified for Paws (booking, scheduling, finance, CRM, inventory, compliance, reporting, marketing, documents). Key Session 73 insight: these are still business model content, not system descriptions. |
| 6 | Business process patterns | Left (green container) | Dynamic behaviour and flows. Three abstraction levels: archetypes (universal), patterns (BMM-parameterised), instances/sketches (domain-specific). This is the crossing point — business process patterns compile to executable artefacts on the right stack. Process sketch DSL proposed. |

### 3. Emergent idea captured (E016)

The five-facet description template maps naturally to a new `@ArchitecturalLocation` metadata def in SysML, with attributes for purpose, representationalModality, persistence, interfaces, and domainIllustration. This would make the architectural descriptions first-class model content — generatable, navigable in the console, consistent with the comprehension architecture ([[principle-intrinsic-self-knowledge|A10]], [[principle-unity-principle|A11]]). Content-first approach: validate the template through use before formalising.

### 4. Reading and context

Extensive reading at session open:

- [[session-84-preparation-note|Session 84 preparation note]]
- [[ontara-workflow-development-guide|Workflow guide]] (v2)
- [[ontara-ref-strategic-snapshot|Strategic reference]] (Session 82)
- [[ontara-ref-master-register|Master register]] (full)
- [[ontara-discussion-paper-process-specification-layer|Process specification layer paper]] (Session 72, revised Session 75)
- [[ontara-discussion-dual-stack-architecture-2026-03-26|Dual-stack architecture discussion paper]] (Session 73/74)
- [[paws-vertical-connection-map|Paws vertical connection map]]
- [[paws-domain-description|Paws domain description]]
- [[paws-design-note-2026-03-19|Paws design note]] (Session 44)
- [[ontara-research-(perplexity) - ontology-dsl-mapping-sync|Perplexity research: ontology-DSL-mapping-sync]] (OWL/SysML integration, Temporal DSL, mapping ontologies)
- Uploaded SVG: `ontara_dual_stack_v6_reflective_cross_cut.svg` (the current architecture diagram, v6)

---

## Register Concepts Exercised

| Concept | How exercised |
|---|---|
| [[concept-dual-stack-architecture|B21]] (dual-stack architecture) | The entire session is structured around the dual-stack diagram |
| [[concept-knowledge-graph|B22]] (knowledge graph as canonical store) | Each section description notes current vs target representational modality |
| [[ontara-ref-master-register|B24]] (mapping ontology) | Identified as the formalism boundary between OWL and SysML sections |
| [[ontara-ref-master-register|B18]] (BFO as upper ontology) | Section 1 — detailed description of BFO's role |
| [[concept-ontology-stack|B19]] (ontology stack) | Section 2 — mid-level ontologies and tenant-specific selection |
| [[principle-two-meta-model-distinction|A4]] (two meta model distinction) | The left/right stack split is A4 made spatial |
| [[principle-intrinsic-self-knowledge|A10]] (intrinsic self-knowledge) | [[ontara-workflow-emergent-ideas-log|E016]] — the architecture describing itself |
| [[concept-multi-tenancy|A13]] (multi-tenancy) | Paws as a tenant exercising the architecture |
| [[concept-co-evolution|J2]] (co-evolution) | Descriptions produced alongside console integration planning |
| [[concept-inception-capture|J13]] (inception capture) | [[ontara-workflow-emergent-ideas-log|E016]] captured during the work |

### New concept introduced

| # | Concept | Tier | Summary |
|---|---|---|---|
| B27 | Architectural section | T2 | A bounded region of the dual-stack architecture with a characteristic purpose, representational formalism, persistence mechanism, and set of interfaces |

---

## Emergent Ideas

| # | Idea | Status |
|---|---|---|
| E016 | `@ArchitecturalLocation` metadata def — five-facet template for architectural section descriptions | Captured. Provisional routing: design after campus walk content stabilises. |

---

## Tier 1 Principles Honoured

| Principle | How honoured |
|---|---|
| [[principle-separation-representation-execution|A1]] (separation of representation and execution) | Each section description explicitly notes which representational formalism applies |
| [[principle-self-describing-system|A2]] (self-describing system) | The campus walk is the system describing its own architecture |
| [[principle-model-generates-everything|A3]] (model generates everything) | Target: section descriptions as SysML metadata, extractable by generators |
| [[principle-two-meta-model-distinction|A4]] (two meta model distinction) | The dual-stack structure is the spatial expression of A4 |
| [[principle-discipline-as-load-bearing-structure|A9]] (discipline as load-bearing structure) | Systematic five-facet template applied consistently across all six sections |
| [[principle-intrinsic-self-knowledge|A10]] (intrinsic self-knowledge) | The architecture comprehends its own structural regions |
| [[principle-unity-principle|A11]] (unity principle) | The same comprehension architecture (metadata defs, generator extraction, console presentation) applies to sections as to BMM elements |
| [[concept-co-evolution|J2]] (co-evolution) | Descriptions and console integration planned together |
| [[concept-non-constraining|J3]] (non-constraining) | Each section description notes current state *and* target, preserving the KG-as-canonical direction |

---

## Open Questions

1. **SysML encoding of architectural sections.** The `ArchitecturalSection` part def and `@ArchitecturalLocation` metadata def need detailed design — deferred until the full campus walk is complete and the template has been validated across all 20 sections.
2. **Right-stack sections (7–11).** Descriptions needed for system ontological categories, BSMM General vocabulary, system instance, system domains, and operational simulation. Planned for Part 2.
3. **Cross-cutting and infrastructure sections (12–20).** Reflective simulation, rules/constraints, terminology, mapping ontology, canonical store components, operator. Planned for Part 2.
4. **Generator and console integration.** How to extend `gen_model_introspection.py` and what console view to present architectural sections. Planned for implementation phase after discussion paper.

---

*Session 84 report — 28 March 2026 — GenderSense Limited*
