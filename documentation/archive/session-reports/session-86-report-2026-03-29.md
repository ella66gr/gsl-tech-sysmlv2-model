---
tags:
  - session-report
date: 2026-03-29
status: current
session: 86
---
# Session 86 Report — 29 March 2026

**Session type:** Discussion
**Date:** 29 March 2026
**Focus:** Implementation design for ArchitecturalSection ([[ontara-ref-master-register|B27]]) and @ArchitecturalLocation ([[ontara-workflow-emergent-ideas-log|E016]])

---

## Summary

Session 86 was a focused discussion session addressing the five open design questions from the campus walk workstream (Sessions 84–85). All five questions from §12 of the [[ontara-discussion-architectural-campus-walk-2026-03-28|campus walk discussion paper]] were resolved into a coherent implementation design, captured in a new [[ontara-discussion-architectural-section-implementation-design-2026-03-29|discussion paper]].

The session also incorporated external research (Perplexity) into MBSE best practice for long prose in model metadata, which informed a key design decision about where descriptive content should live. This research surfaced a reusable pattern — the model-as-index / vault-as-body pattern — captured as E017 in the [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]].

---

## Decisions Reached

### Decision 1 — Section Identification

Name-based identity with ordering as a presentation concern. Each section gets a kebab-case stable identifier (e.g. `bfo`, `operational-simulation`, `knowledge-graph`) and a friendly display name. Group membership and presentation order are attributes, not embedded in the name. This follows the precedent set by BMM concerns (named, not numbered) and respects the [[concept-non-constraining|non-constraining principle (J3)]].

### Decision 2 — ArchitecturalSection Part Def Design

A single `ArchitecturalSection` part def, instantiated 20 times. The sections share the same structural shape — the five-facet template worked uniformly across all 20 without per-section variation. This honours the [[ontara-ref-master-register|part def / part distinction (I9)]]: the concept is the part def, the 20 specific sections are instances. Structural attributes (name, displayName, group, presentationOrder, primaryFormalism, persistenceMechanism, implementationStatus, docKey) live on the part def. Descriptive content lives on metadata annotations.

### Decision 3 — @ArchitecturalLocation Metadata Def Design

A single `@ArchitecturalLocation` metadata def with four attributes (representationalModalitySummary, persistenceSummary, interfacesSummary, domainIllustrationSummary), complementing the existing `@PurposiveDescription` which carries the purpose facet. This avoids duplicating purpose text and keeps `@PurposiveDescription` as the universal "why" annotation across all model elements. `@UserFacing` and `@Comprehension` apply as normal. `@WeightedRelationship` between sections is deferred.

### Decision 4 — Generator Extension and Prose Encoding

Short structured summaries in the model; full prose in the Obsidian vault. The model is the index; the Markdown is the body text. This was informed by Perplexity research into MBSE best practice and ISO 42010, which confirmed that long multi-paragraph prose in SysML metadata attributes causes problems with tool UX, version control noise, parser fragility, and cognitive load. The `docKey` attribute on each `ArchitecturalSection` instance links to the full prose in the vault. A new `architecturalSections` top-level key in `model-introspection.json` carries the extracted data.

### Decision 5 — Console View Design

A new dedicated "Architecture" view in the Ontara Console. The existing views serve different purposes and none is the right home for architectural section navigation. Minimum viable version: a list view grouped by architectural group, each section expandable to show its metadata, filterable by group/formalism/implementation status. Stretch goal: a spatial layout reflecting the dual-stack architecture diagram.

---

## Deliverables

| Deliverable | Location |
|---|---|
| [[ontara-discussion-architectural-section-implementation-design-2026-03-29|Discussion paper: "Architectural Section Implementation Design: Five Decisions"]] | 05 Ontara Exploratory & Discussion Papers / Foundational Architecture |
| [[ontara-workflow-emergent-ideas-log|Emergent idea E017]]: model-as-index / vault-as-body pattern | [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]] |

---

## Register Concepts Exercised

| Concept | How exercised |
|---|---|
| [[ontara-ref-master-register|B27]] (architectural section) | The concept being designed — SysML encoding resolved |
| [[concept-dual-stack-architecture|B21]] (dual-stack architecture) | The architecture whose sections are being modelled |
| [[ontara-ref-master-register|B8]] (BSMM implicit gap) | Provisional package placement acknowledges the gap |
| [[ontara-ref-master-register|I9]] (part def / part distinction) | Single part def, 20 instances — distinction is load-bearing |
| [[ontara-ref-master-register|I14]] (comprehension layer) | Metadata annotation pattern extended to a new element kind |
| [[principle-intrinsic-self-knowledge|A10]] (intrinsic self-knowledge) | Architecture describes its own structure; proportionate trade-off on prose location |
| [[principle-unity-principle|A11]] (unity principle) | Same comprehension patterns apply to sections as to BMM elements |
| [[principle-self-describing-system|A2]] (self-describing system) | The system knows what its own sections are |
| [[principle-model-generates-everything|A3]] (model generates everything) | Section descriptions are model content, extractable by generators |
| [[principle-two-meta-model-distinction|A4]] (two meta model distinction) | Sections are BSMM content, not BMM |
| [[concept-co-evolution|J2]] (co-evolution) | Model structure and console view designed in the same session |
| [[concept-non-constraining|J3]] (non-constraining) | Name-based identity; provisional package placement |
| [[principle-discipline-as-load-bearing-structure|A9]] (discipline) | Systematic five-question design process with documented rationale |

---

## Emergent Ideas Captured

| # | Idea | Session |
|---|---|---|
| E017 | Model-as-index / vault-as-body pattern: SysML model carries structured metadata and short summaries with a `docKey` linking to full prose in the Obsidian vault. Reusable beyond architectural sections. | 86 |

---

## Tier 1 Principles Honoured

- **A1 (separation of representation and execution):** Not directly exercised — no runtime work this session.
- **A2 (self-describing system):** Central to the session — the architecture is being made self-describing through first-class model content.
- **A3 (model generates everything):** The design ensures section descriptions are extractable by the generation pipeline.
- **A4 (two meta model distinction):** Architectural sections are explicitly placed on the BSMM side. Provisional package placement preserves design freedom.
- **A9 (discipline):** Five questions addressed systematically with documented rationale. Research incorporated before committing.
- **A10 (intrinsic self-knowledge):** The architecture describes its own structural regions. The prose trade-off is acknowledged and proportionate.
- **A11 (unity principle):** The same comprehension metadata patterns serve architectural sections and BMM elements.
- **J2 (co-evolution):** Model structure and console view designed together.
- **J3 (non-constraining):** Name-based identity preserves ordering flexibility. Provisional package placement preserves BSMM design freedom.

---

## Open Questions

The five design questions from the campus walk §12 are resolved. Five remaining questions (BSMM vocabulary content, system ontological categories completeness, operational domain representation, reflective simulation processing formalism, tenant activation model) remain open as separate workstreams — they are not prerequisites for implementing the decisions in this session.

---

*Session 86 report. GenderSense Limited.*
