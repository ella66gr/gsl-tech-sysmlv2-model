---
tags:
  - discussion
  - architecture
date: 2026-03-29
status: working
session: 86
---
# Architectural Section Implementation Design: Five Decisions

*Ontara Platform — Discussion Paper*
**Date:** 29 March 2026 (Session 86)
**Purpose:** Design decisions for the SysML encoding of architectural sections (B27) and the `@ArchitecturalLocation` metadata def (E016), informed by the campus walk workstream (Sessions 84–85) and external research into MBSE best practice.
**Status:** Working document — detailed design. Precedes an implementation plan.
**Depends on:** [[ontara-discussion-architectural-campus-walk-2026-03-28|The Ontara Campus: Architectural Sections of the Dual-Stack Architecture]]

---

## Contents

- [[#1. Context|§1. Context]]
- [[#2. Decision 1 — Section Identification|§2. Decision 1 — Section Identification]]
- [[#3. Decision 2 — ArchitecturalSection Part Def Design|§3. Decision 2 — ArchitecturalSection Part Def Design]]
- [[#4. Decision 3 — ArchitecturalLocation Metadata Def Design|§4. Decision 3 — ArchitecturalLocation Metadata Def Design]]
- [[#5. Decision 4 — Generator Extension and the Prose Encoding Pattern|§5. Decision 4 — Generator Extension and the Prose Encoding Pattern]]
- [[#6. Decision 5 — Console View Design|§6. Decision 5 — Console View Design]]
- [[#7. The Model-as-Index Pattern|§7. The Model-as-Index Pattern]]
- [[#8. Implementation Considerations|§8. Implementation Considerations]]
- [[#9. Register Connections|§9. Register Connections]]
- [[#10. Open Questions Resolved|§10. Open Questions Resolved]]
- [[#11. Remaining Open Questions|§11. Remaining Open Questions]]
- [[#Related Documents|Related Documents]]

---

## 1. Context

The [[ontara-discussion-architectural-campus-walk-2026-03-28|campus walk workstream]] (Sessions 84–85) described all 20 architectural sections of the [[concept-dual-stack-architecture|dual-stack architecture]] using a five-facet template (purpose, representational modality, persistence, interfaces, domain illustration). This produced the concept of an [[ontara-ref-master-register|architectural section (B27)]] and a comprehensive discussion paper consolidating all 20 section descriptions.

The campus walk paper's §12 identified five open questions about how to encode this content in the SysML model. This paper records the design decisions reached during Session 86, addressing all five questions and resolving them into a coherent implementation design.

### 1.1 Input documents

- [[ontara-discussion-architectural-campus-walk-2026-03-28|"The Ontara Campus" discussion paper]] — the campus walk content, particularly §12 (Open Questions) and §10 (Summary Table)
- [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log E016]] — the original idea for `@ArchitecturalLocation` as a metadata def
- External research (Perplexity) on MBSE best practice for long prose in model metadata, ISO 42010 viewpoint templates, and model-driven document generation patterns

### 1.2 Design principles in play

The decisions in this paper are governed by:

- [[principle-intrinsic-self-knowledge|A10 (intrinsic self-knowledge)]] — the architecture should describe its own structural regions
- [[principle-unity-principle|A11 (unity principle)]] — the same comprehension metadata patterns that serve BMM elements should serve architectural sections
- [[principle-self-describing-system|A2 (self-describing system)]] — the system knows what its own sections are and can explain them
- [[principle-model-generates-everything|A3 (model generates everything)]] — section descriptions should be extractable by generators
- [[concept-co-evolution|J2 (co-evolution)]] — the model structure and the console view to present it are designed together
- [[concept-non-constraining|J3 (non-constraining)]] — decisions should not foreclose future development paths
- [[principle-two-meta-model-distinction|A4 (two meta model distinction)]] — architectural sections describe the system architecture (BSMM side), not the business (BMM side)

---

## 2. Decision 1 — Section Identification

**Question (§12, Open Question 3):** The campus walk numbered sections 1–20. Should sections be identified by number or by name, with ordering as a presentation concern?

**Decision: Name-based identity. Ordering is a presentation concern.**

### 2.1 Rationale

The 20 sections are semantically distinct, not positionally defined. "BFO" is BFO regardless of whether it is Section 1 or Section 0. "Operational Simulation" does not change meaning if a new section is inserted before it.

Precedent within Ontara supports this. The BMM concerns are named (ServiceConcept, ActivityModel, ResourcePlanning, FinancialPlanning, [[ontara-ref-master-register|GovernanceMapping]], [[concept-stakeholder-model|StakeholderModel]]), not numbered. When [[concept-stakeholder-model|StakeholderModel]] was added as the sixth concern, nothing broke — no renumbering, no identity confusion.

Making order a presentation property, not an identity property, preserves flexibility ([[concept-non-constraining|J3]]). A console view might order sections by group, by formalism, by persistence mechanism, by implementation status, or by tenant density. Different orderings serve different audiences.

### 2.2 Naming convention

Each section receives:

- A **kebab-case stable identifier** used as the primary key (e.g. `bfo`, `domain-ontologies`, `bmm-general-vocabulary`, `operational-simulation`, `reflective-simulation`, `knowledge-graph`, `operator`).
- A **friendly display name** for presentation (e.g. "BFO (Basic Formal Ontology)", "Domain Ontologies", "BMM General Vocabulary", "Operational Simulation").

Group membership (shared-foundation, left-stack, right-stack, cross-cutting, green-container, infrastructure) is an attribute of the section, not embedded in the name. A `presentationOrder` attribute drives display ordering without being identity.

### 2.3 The full naming inventory

| Kebab-case identifier | Display name | Group |
|---|---|---|
| `bfo` | BFO (Basic Formal Ontology) | shared-foundation |
| `domain-ontologies` | Domain Ontologies | left-stack |
| `bmm-general-vocabulary` | BMM General Vocabulary | left-stack |
| `business-instance` | Business Instance | left-stack |
| `operational-domains` | Operational Domains | left-stack |
| `business-process-patterns` | Business Process Patterns | left-stack |
| `system-ontological-categories` | System Ontological Categories | right-stack |
| `bsmm-general-vocabulary` | BSMM General Vocabulary | right-stack |
| `system-instance` | System Instance | right-stack |
| `system-domains` | System Domains | right-stack |
| `operational-simulation` | Operational Simulation | right-stack |
| `reflective-simulation` | Reflective Simulation | cross-cutting |
| `rules-and-constraints` | Rules and Constraints | green-container |
| `terminology-and-information-carriers` | Terminology and Information Carriers | infrastructure |
| `mapping-ontology` | Mapping Ontology | infrastructure |
| `knowledge-graph` | Knowledge Graph | infrastructure |
| `sysml-v2` | SysML v2 | infrastructure |
| `openehr` | openEHR | infrastructure |
| `temporal` | Temporal | infrastructure |
| `operator` | Operator | infrastructure |

---

## 3. Decision 2 — ArchitecturalSection Part Def Design

**Question (§12, Open Question 1):** Should each section be a separate `part def`, or should there be a single `ArchitecturalSection` with attributes?

**Decision: A single `ArchitecturalSection` part def, instantiated 20 times.**

### 3.1 Rationale

The sections share the same structural shape. Every section has a purpose, a representational modality, a persistence mechanism, interfaces, and a domain illustration. The five-facet template proved this — it worked uniformly across all 20 sections without needing per-section structural variation. This is the scenario where a single parameterised `part def` is correct.

The `part def` / `part` distinction ([[ontara-ref-master-register|I9]]) matters. The *concept* of an architectural section (what it means to be a bounded region of the architecture) is the `part def`. The 20 specific sections are `part` usages — instances. Creating 20 separate `part def`s would mean each section is treated as a *different kind of thing*, which they are not. They are 20 instances of the same kind of thing, distinguished by their attribute values.

The existing model follows this pattern. `ServiceOffering` is a single `part def`; [[domain-paws|Paws]] has five instances of it. The same logic applies to architectural sections.

### 3.2 Structural attributes on the part def

The `ArchitecturalSection` part def carries structural properties as attributes. Descriptive prose is carried by metadata annotations (§4), consistent with how BMM elements work.

```
part def ArchitecturalSection {
    attribute name : String;
    attribute displayName : String;
    attribute group : ArchitecturalGroup;
    attribute presentationOrder : Integer;
    attribute primaryFormalism : Formalism;
    attribute persistenceMechanism : String;
    attribute implementationStatus : ImplementationStatus;
    attribute docKey : String;
}
```

Supporting enums:

```
enum def ArchitecturalGroup {
    shared-foundation;
    left-stack;
    right-stack;
    cross-cutting;
    green-container;
    infrastructure;
}

enum def Formalism {
    OWL2DL;
    SysMLv2;
    Runtime;
    Mixed;
}

enum def ImplementationStatus {
    implemented;
    designed;
    referenced;
    not-started;
}
```

**Note:** The SysML v2 syntax for these enums and attributes needs verification against the [[ontara-ref-master-register|syntax reference]] before implementation. The above is illustrative of the design intent.

### 3.3 Package placement

The `ArchitecturalSection` part def describes the architecture of the system — this is BSMM content ([[principle-two-meta-model-distinction|A4]]). However, the BSMM package structure does not yet exist ([[ontara-ref-master-register|B8]] — the implicit gap). A provisional package placement is needed.

**Provisional placement:** A new package (e.g. `SystemModel::ArchitecturalStructure` or a top-level `ArchitecturalStructure` package) with a doc block explicitly marking the placement as provisional. When the BSMM vocabulary is elaborated, the content moves to its proper home. This respects [[concept-non-constraining|J3 (non-constraining)]] — the provisional nature is explicit rather than pretended to be settled.

---

## 4. Decision 3 — ArchitecturalLocation Metadata Def Design

**Question (§12, Open Question 2):** Single metadata def with five attributes or five separate metadata defs? How does it interact with existing comprehension metadata?

**Decision: A single `@ArchitecturalLocation` metadata def with four attributes, complementing the existing `@PurposiveDescription`.**

### 4.1 Structure

The five-facet template emerged as a coherent unit — the facets always appear together and were validated as a set across all 20 sections. A single metadata def preserves this coherence:

```
metadata def ArchitecturalLocation {
    attribute representationalModalitySummary : String;
    attribute persistenceSummary : String;
    attribute interfacesSummary : String;
    attribute domainIllustrationSummary : String;
}
```

### 4.2 Why four attributes, not five

The purpose facet is carried by the existing `@PurposiveDescription` metadata def, which already serves as the universal "why does this exist?" annotation across all model elements. Duplicating purpose text in both `@PurposiveDescription` and `@ArchitecturalLocation` would create a maintenance burden and potential drift.

`@ArchitecturalLocation` carries the four *additional* facets that are specific to architectural sections: representational modality, persistence, interfaces, and domain illustration. This is a complementary relationship — `@PurposiveDescription` provides the purpose, `@ArchitecturalLocation` provides the architectural characterisation.

### 4.3 Interaction with other comprehension metadata

| Metadata def | Applies to `ArchitecturalSection`? | Notes |
|---|---|---|
| `@UserFacing` | Yes | All 20 sections are user-facing — the operator should be able to navigate them |
| `@PurposiveDescription` | Yes | Carries the purpose facet, consistent with all other model elements |
| `@ArchitecturalLocation` | Yes (new) | Carries the four additional facets specific to architectural sections |
| `@Comprehension` | Yes, but traversal instructions need design | Structural traversal for sections differs from BMM elements — deferred to implementation |
| `@WeightedRelationship` | Deferred | Sections have directed relationships (interface connections), but weighting is secondary. Validate the basic structure first |
| `@CatalogueTag` | Possibly, with adapted facets | Or a new tag scheme for architectural content. To be resolved during implementation |

### 4.4 Short summary pattern

Following the research into MBSE best practice (§5), each `@ArchitecturalLocation` attribute carries a **short summary** (one to two sentences) rather than multi-paragraph prose. Full prose lives in the Obsidian vault, linked via the `docKey` attribute on the `part def`. See §5 for the full rationale.

---

## 5. Decision 4 — Generator Extension and the Prose Encoding Pattern

**Question (§12, Open Question 4):** How does `gen_model_introspection.py` extract architectural section metadata, and where does the descriptive prose live?

**Decision: Short structured summaries in the model, full prose in the vault. The model is the index; the Markdown is the body text.**

### 5.1 The long-prose problem

The campus walk descriptions contain substantial prose — several sentences to a full paragraph per facet, per section. Embedding this directly in SysML metadata annotation attributes raises practical concerns:

- **Tool UX:** SysML v2 editors (including Syside Modeler) become harder to navigate with very long string attribute values. Editors may not wrap or search across long strings comfortably.
- **Version control noise:** Small editorial changes inside long strings produce noisy diffs, especially if tools reformat whitespace.
- **Parser fragility:** `gen_model_introspection.py` uses regex-based text parsing. Multi-line strings with embedded newlines, markup, and escaping are brittle to extract reliably.
- **Cognitive load:** Reviewers opening the model to understand structure must wade through narrative prose rather than focusing on structural semantics.

### 5.2 External research

Perplexity research into MBSE best practice and ISO 42010 confirmed that the recommended pattern is:

- **Keep model-level annotation attributes short and structured** (one to two sentences per facet, plus tags/enums where possible).
- **Generate or link out to external documents for full multi-paragraph prose**, with clear traceability back to the model elements.
- **The five-facet template aligns with ISO 42010** viewpoint description "slots" (overview, concerns, stakeholders, model kinds, notations). Treating these as structured short properties aligns with the standard.

The research explicitly recommended against treating SysML metadata attributes as the home for multi-paragraph narrative.

### 5.3 The model-as-index / vault-as-body pattern

The resolution maps naturally onto Ontara's existing architecture:

**In the SysML model:** `@ArchitecturalLocation` carries short, structured summaries (one to two sentences per facet). The `docKey` attribute on the `ArchitecturalSection` part ties each section to its full prose in the Obsidian vault.

**In the Obsidian vault:** The full multi-paragraph prose lives in the [[ontara-discussion-architectural-campus-walk-2026-03-28|campus walk discussion paper]] (or a derivative standing reference document if the paper is later promoted). The `docKey` matches the section's kebab-case name, which maps to a heading in the Markdown.

**The generator assembles the structured content.** `gen_model_introspection.py` extracts the structural attributes and short summaries from the model, producing a JSON payload for the console's Architecture view. The full prose remains navigable in Obsidian — the console does not need to reach into the vault at runtime.

### 5.4 What this preserves

- **[[principle-intrinsic-self-knowledge|A10 (intrinsic self-knowledge)]]:** The model carries enough to describe each section meaningfully. The summaries are self-contained, not just pointers. The console can present useful content without reaching into the vault.
- **[[principle-model-generates-everything|A3 (model generates everything)]]:** The structural properties and summaries are model content, extractable by generators. The full prose is elaboration, not contradiction.
- **Practical editability:** Short strings in Syside are comfortable. Full prose is edited in Obsidian where Markdown editing is native. Version control diffs are clean on both sides.
- **ISO 42010 alignment:** The five-facet template mirrors viewpoint description slots; short structured properties align with the standard.

### 5.5 What it gives up

The full prose is not intrinsic to the model. If someone has only the `.sysml` files and not the vault, they get summaries but not the complete descriptions. This is a genuine trade-off against [[principle-intrinsic-self-knowledge|A10]], but a proportionate one: the summaries are substantive, and the linkage via `docKey` is explicit and deterministic.

### 5.6 Generator output structure

A new top-level key in `model-introspection.json`:

```json
"architecturalSections": [
  {
    "name": "bfo",
    "displayName": "BFO (Basic Formal Ontology)",
    "group": "shared-foundation",
    "presentationOrder": 1,
    "primaryFormalism": "OWL2DL",
    "persistenceMechanism": "triple-store",
    "implementationStatus": "referenced",
    "purposiveDescription": "The shared foundation spanning both stacks...",
    "representationalModalitySummary": "OWL 2 DL. Imported directly from OBO Foundry.",
    "persistenceSummary": "Target: triple store. Currently: referenced only.",
    "interfacesSummary": "Vertical downward to both domain ontologies and system ontological categories.",
    "domainIllustrationSummary": "Sam is a BFO Continuant bearing a Role...",
    "docKey": "bfo"
  }
]
```

The generator extracts: structural attributes from `part` usages, `@PurposiveDescription` text, `@ArchitecturalLocation` summary attributes, and the `docKey`. This extends the existing parse-and-extract pattern — an extension of mechanism, not a new mechanism.

### 5.7 Generator work characterisation

Extending `gen_model_introspection.py` is a `[Code]` task requiring iterative build-test cycles. The parser needs to recognise `ArchitecturalSection` part usages and extract their attributes and metadata annotation stacks. This is the same regex-based extraction the generator already performs for BMM `part def`s, adapted for `part` usages with redefined attributes.

---

## 6. Decision 5 — Console View Design

**Question (§12, Open Question 4, continued):** New console view or extension of existing views?

**Decision: A new dedicated "Architecture" view.**

### 6.1 Rationale

The existing 11 console views serve different purposes. The Glossary presents BMM element definitions. The Component Catalogue groups elements by facet. The Package Navigator shows the SysML package hierarchy. The Weighted Relationship Graph shows inter-element relationships. None is the right home for presenting the 20 structural regions of the architecture with their formalisms, persistence mechanisms, interfaces, and tenant-specific illustrations.

The content has a natural visual structure: six architectural groups (shared foundation, left stack, right stack, cross-cutting, green container, infrastructure) provide a clear organising frame. Within each group, sections can be listed with expandable detail panels showing the `@ArchitecturalLocation` facets and `@PurposiveDescription`.

### 6.2 Minimum viable version

A list view grouped by architectural group, each section expandable to show its metadata:

- Section header: display name, primary formalism badge, implementation status badge
- Expanded panel: `@PurposiveDescription` text, four `@ArchitecturalLocation` summaries
- Filterable by: group, formalism, implementation status
- Same SvelteKit + Flowbite component patterns as the existing Glossary view

This is straightforward `[Code]` work using established console patterns. The [[ontara-guide-claude-tooling|Claude Tooling Guide]] governs the Chat/Code allocation.

### 6.3 Documented stretch goal — spatial layout

A spatial view reflecting the [[concept-dual-stack-architecture|dual-stack architecture]] diagram layout: left stack on the left, right stack on the right, shared foundation spanning the top, infrastructure at the bottom, cross-cutting and green container in their architectural positions. Sections as clickable regions. Horizontal mapping lines between left and right stack pairs. Colour-coding by formalism or implementation status.

This would be a compelling expression of [[principle-self-describing-system|A2 (self-describing system)]] — the system visually presenting its own architecture. Scoped as a stretch goal that does not block the initial delivery.

---

## 7. The Model-as-Index Pattern

The resolution of the long-prose question (§5) surfaced a pattern that is potentially reusable beyond architectural sections.

**Pattern:** The SysML model carries structured metadata (identifiers, classifications, short summaries) and a `docKey` linking to full prose in the Obsidian vault. The model is the structural authority; the vault is the prose authority. Generators extract the model content; the vault content is navigable in Obsidian. For assembled documents (PDFs, reports), a future generator could splice model summaries with vault prose using the `docKey` linkage.

**Applicability:** Any model element that needs richer prose than a metadata attribute comfortably holds could use this pattern. Candidates include: pattern descriptions in the [[ontara-ref-master-register|PatternCatalogue]], detailed domain descriptions for demonstrator domains ([[domain-cafe|Cafe]], [[domain-suds|Suds]], [[domain-paws|Paws]]), elaborate governance requirement narratives. The pattern does not replace `@PurposiveDescription` for elements where one or two sentences suffice — it complements it for elements where the descriptive needs are larger.

**Captured as:** [[ontara-workflow-emergent-ideas-log|E017]] — the model-as-index / vault-as-body pattern for rich prose.

---

## 8. Implementation Considerations

### 8.1 Syside validation step

Before populating all 20 section instances, implement two sections fully (e.g. `bfo` and `operational-simulation` — one simple, one complex) and verify in Syside Modeler that:

- The metadata annotation blocks parse cleanly
- The short summary strings display acceptably in hover tooltips and editor panels
- The `part` usage with redefined attributes renders correctly
- The overall `.sysml` file remains readable and navigable

Only proceed with the remaining 18 sections after this validation passes.

### 8.2 Implementation sequence

The work divides naturally into `[Chat]` and `[Code]` tasks:

1. `[Chat]` — Write the `ArchitecturalSection` part def, enums, and two example instances with full metadata annotation stacks. Produce as a container artifact for Ella to add to the model.
2. `[Ella]` — Verify in Syside. Confirm the editing experience is acceptable.
3. `[Chat]` — Write the remaining 18 section instances with metadata. Container artifact.
4. `[Code]` — Extend `gen_model_introspection.py` to extract `ArchitecturalSection` part usages with their metadata. Iterative build-test.
5. `[Code]` — Build the Architecture console view (minimum viable version). Iterative build-test.
6. `[Chat]` — Session close, register updates, documentation.

### 8.3 Content source for short summaries

The short summaries for each section's `@ArchitecturalLocation` attributes will be condensed from the full prose in the [[ontara-discussion-architectural-campus-walk-2026-03-28|campus walk discussion paper]]. This is a `[Chat]` task per the [[ontara-guide-claude-tooling|Claude Tooling Guide]] — Claude drafts the summaries, Ella reviews. Each full description (several paragraphs per facet) needs distilling to one or two sentences.

### 8.4 Provisional package placement

The `ArchitecturalSection` part def and its 20 instances could live in:

- A new file: e.g. `model/architectural-structure.sysml`
- A new top-level package: `ArchitecturalStructure`
- With a doc block: marking placement as provisional pending BSMM vocabulary elaboration

This avoids entangling the work with the not-yet-designed BSMM package structure ([[ontara-ref-master-register|B8]]).

---

## 9. Register Connections

### Tier 1 principles honoured

| Principle | How honoured |
|---|---|
| [[principle-self-describing-system\|A2]] | The architecture describes its own structural regions as first-class model content |
| [[principle-model-generates-everything\|A3]] | Section descriptions are extractable by generators; structural properties are model content |
| [[principle-two-meta-model-distinction\|A4]] | Architectural sections are BSMM content — they describe the system architecture, not the business |
| [[principle-discipline-as-load-bearing-structure\|A9]] | Systematic design process: five questions addressed methodically with documented rationale |
| [[principle-intrinsic-self-knowledge\|A10]] | Summaries are self-contained model content; full prose linked via docKey. Proportionate trade-off acknowledged |
| [[principle-unity-principle\|A11]] | Same comprehension metadata patterns (PurposiveDescription, UserFacing, Comprehension) apply to sections as to BMM elements |
| [[concept-co-evolution\|J2]] | Model structure and console view designed together in the same session |
| [[concept-non-constraining\|J3]] | Name-based identity preserves ordering flexibility; provisional package placement preserves BSMM design freedom |

### Concepts exercised

| Concept | How exercised |
|---|---|
| [[ontara-ref-master-register\|B27]] (architectural section) | The concept being designed — SysML encoding resolved |
| [[concept-dual-stack-architecture\|B21]] (dual-stack architecture) | The architecture whose sections are being modelled |
| [[ontara-ref-master-register\|B8]] (BSMM implicit gap) | Provisional package placement acknowledges the gap without pretending to resolve it |
| [[ontara-ref-master-register\|I9]] (part def / part distinction) | Single part def, 20 instances — the distinction is load-bearing in this design |
| [[ontara-ref-master-register\|I14]] (comprehension layer) | Metadata annotation pattern extended to a new element kind |

### Emergent idea captured

| # | Idea | Connections |
|---|---|---|
| E017 | Model-as-index / vault-as-body pattern for rich prose | [[principle-intrinsic-self-knowledge\|A10]], [[principle-model-generates-everything\|A3]], [[concept-co-evolution\|J2]], ISO 42010 |

---

## 10. Open Questions Resolved

This paper resolves five of the nine open questions from §12 of the [[ontara-discussion-architectural-campus-walk-2026-03-28|campus walk discussion paper]]:

| # | Question | Resolution |
|---|---|---|
| 1 | `ArchitecturalSection` part def design | Single part def, 20 instances (§3) |
| 2 | `@ArchitecturalLocation` metadata def design | Single metadata def, four attributes, complementing `@PurposiveDescription` (§4) |
| 3 | Section numbering stability | Name-based identity; ordering is a presentation concern (§2) |
| 4 | Generator and console integration | New `architecturalSections` key in JSON; new "Architecture" console view (§5, §6) |
| — | Long prose encoding (sub-question of 4) | Model-as-index / vault-as-body pattern; short summaries in model, full prose in vault (§5) |

---

## 11. Remaining Open Questions

The following questions from the campus walk paper's §12 remain open. They are not prerequisites for implementing the five decisions in this paper, but will need resolution in due course:

| # | Question | Notes |
|---|---|---|
| 5 | BSMM vocabulary content | The specific `part def`s within each capability group need design. Separate workstream. |
| 6 | System ontological categories completeness | Whether Process, Information Content Entity, Process Boundary, and Quality are sufficient. Needs ontological analysis. |
| 7 | Operational domain representation | How to make implicit operational domains explicit. Related to business instance elaboration. |
| 8 | Reflective simulation processing formalism | Internal processing formalism is an open design question. Horizon item. |
| 9 | Tenant activation model | How section variation by tenant is represented. Related to [[ontara-ref-master-register|DomainDefinition (B15)]] and [[concept-multi-tenancy|tenant onboarding (A13)]]. |

---

## Related Documents

- [[ontara-discussion-architectural-campus-walk-2026-03-28|The Ontara Campus: Architectural Sections of the Dual-Stack Architecture]] — the campus walk content this paper designs the encoding for
- [[ontara-discussion-dual-stack-architecture-2026-03-26|Dual-Stack Architecture discussion paper (Session 73/74)]] — the architecture being described
- [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]] — E016 (original idea) and E017 (model-as-index pattern)
- [[ontara-ref-master-register|Master Concept Register]] — B27, B8, I9, I14
- [[ontara-ref-strategic-snapshot|Strategic Reference (Session 82)]] — current project orientation
- [[ontara-discussion-stakeholder-model-and-bsmm-vocabulary-2026-03-27|StakeholderModel and BSMM Vocabulary paper (Session 76)]] — BSMM capability groups context
- External research: Perplexity investigation into MBSE best practice for long prose in model metadata (Session 86)
- [[ontara-workflow-development-guide|Development Workflow Guide]] — governing operating agreement
- [[session-86-report-2026-03-29|Session 86 Report]]

---

*Discussion paper written Session 86 (29 March 2026). Working document — detailed design preceding implementation. GenderSense Limited.*
