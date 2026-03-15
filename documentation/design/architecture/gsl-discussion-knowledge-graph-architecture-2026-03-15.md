# Discussion Paper: Knowledge Graph Architecture for the Concept Graph

**Project:** GenderSense (GSL)
**Date:** 15 March 2026 (Session 31)
**Status:** Discussion paper — captures the design discussion and architectural decision
**Context:** Concept Graph workstream Stages 1–4 complete (Session 30). PatternCatalogue SysML package operational with 22 patterns, 33 domain instantiations. Obsidian vault with concept graph navigation layer. Three enhancement ideas raised by Ella at the start of this session.

---

## 1. The Three Enhancement Ideas

### 1.1 Hookmark — Cross-Desktop Bidirectional Linking

**What:** Hookmark is a macOS application (already installed and licensed) that creates bidirectional links between items across link-friendly applications — Obsidian notes, VS Code files, Finder documents, emails, web pages, PDFs.

**Value:** The project's artefacts span multiple applications. Hookmark would allow direct navigation from a pattern note in Obsidian to the corresponding `.sysml` file in VS Code, from a session report to the discussion paper it references, from an email about clinical governance to the relevant architectural principle. Obsidian's backlinks only work within Obsidian; Hookmark extends bidirectional linking across the entire desktop.

**Integration:** Hookmark has a verified Obsidian integration (requires "Allow URI callbacks" in Obsidian settings). The `hook://file/` URI scheme is recommended for robustness — it survives file renames and moves. Works with VS Code, Finder, Mail, Safari.

**Limitation:** Hookmark cannot currently be programmatically controlled — links are created manually through the Hookmark UI (typically ⌃H to invoke the contextual window). This means Claude cannot create or maintain Hookmark links during sessions. The practice must be manual and habitual.

**Status:** Agreed. Spike planned — hook key artefacts together, evaluate navigation payoff.

### 1.2 Visualisation — Mermaid Projections from the Model

**What:** Generating navigable visual projections of the concept graph from the SysML model, using Mermaid as the primary output format. These diagrams embed in Obsidian, documentation, and GitHub.

**Value:** The concept graph is a graph — it should be visible as one. Generated Mermaid diagrams are projections of the model, not hand-maintained artefacts. When the model changes, the diagrams are regenerated.

**Layer B approach (agreed):** Mermaid generation from the SysML model is the highest-value investment. A Python generator reads `pattern-catalogue.sysml`, extracts patterns and their typed `ref` relationships, and produces multiple Mermaid views: overview, dependency chains, motivation (patterns → principles), cross-domain analogues, maturity, and impact analysis.

**Tom Sawyer SysML v2 Viewer (horizon item):** The standalone web-based viewer would add value for stakeholder-facing views. Syside Modeler already integrates Tom Sawyer's visualisation technology for its built-in diagram views. The standalone viewer connects to SysML v2 API-compliant repositories and renders interactive graphical views with automatic layout. Positioned for investigation when stakeholder communication becomes a priority.

**Other visualisation approaches (horizon items):**
- Tom Sawyer views in VS Code (beyond what Syside already provides)
- Tom Sawyer web-based visualisation of repo sources
- D2, Graphviz, or Structurizr for specific view types

**Status:** Layer B agreed and will be implemented. Tom Sawyer and other approaches captured as horizon items (see §7).

### 1.3 Knowledge Graph — Semantic Relationships Between Patterns

**What:** A typed relationship layer that goes beyond the PatternCatalogue's "this pattern exists and has been instantiated here" to capture "this pattern depends on that pattern, was motivated by this principle, enables that capability, and is structurally analogous to this concept in another domain."

**This was the substantive architectural discussion.** See §2–5 for the full analysis and decision.

---

## 2. The Architectural Decision: Four Options Evaluated

### Option 1: SysML-native relationships (typed `ref` on Pattern)

Add typed `ref` fields to the `Pattern` part def: `ref dependsOn : Pattern[0..*]`, `ref enables : Pattern[0..*]`, `ref motivatedBy : ArchitecturalPrinciple[0..*]`, etc. Add an `ArchitecturalPrinciple` part def. All semantic relationships live in the SysML model.

**Pros:** Single source of truth. Model generates everything — consistent with the foundational principle. Syside validates relationships — type errors caught at parse time. Portable — anyone who picks up the `.sysml` files gets the relationships. Uses verified syntax (`ref` to `Pattern` multi-valued, confirmed Session 30).

**Cons:** Verbose — each pattern grows by several lines per relationship. Per-relationship annotations (the "why" behind a dependency) would be expensive in SysML. Hard to browse the `.sysml` file directly (though this is less relevant given the decision that SysML serves as a precise engineering substrate, not a human reading format).

### Option 2: YAML layer alongside SysML

A YAML file declares typed semantic relationships. A generator reads both the SysML catalogue and the YAML to produce Mermaid views.

**Pros:** Lightweight, easy to bulk-edit. YAML parsing is trivial for generators. Can evolve independently from the SysML model.

**Cons:** Parallel structure that could drift from the SysML. Not validated by Syside — a relationship could reference a deleted pattern silently. Violates the "SysML is the single source of truth" principle. The YAML is core architectural knowledge dressed up as a lightweight artefact.

### Option 3: Local graph database (Neo4j / Memgraph)

Load RDF/OWL triples derived from the SysML model into a graph database. Query with Cypher/SPARQL.

**Pros:** Powerful query language. Transitive traversals, shortest paths, centrality analysis.

**Cons:** Significant operational complexity. Another infrastructure component to maintain. Over-engineered for the current scale (~50 relationships across ~22 patterns).

### Option 4: Obsidian-only (structured linking with Dataview)

Obsidian's graph view plus Dataview queries over structured frontmatter.

**Pros:** Zero new infrastructure. Already the navigation layer.

**Cons:** Untyped relationships (Obsidian links are "related to", not "depends on"). Dataview is a non-trivial learning investment. Obsidian is not the formal layer — it's the thinking space. Core architectural knowledge would live in the wrong substrate.

---

## 3. The Decision: SysML-Native with Generator Pipeline (Hybrid of Options 1 and 2)

**Ella's challenge:** "If we are privileging SysML v2 as our modelling substrate, then we should properly examine the pros and cons of setting it aside for something else."

**Ella's framing:** "It is already the case that I cannot — and do not expect to — read the SysML for myself and fully grasp all the meaning. To me, it serves as a precisely-engineered representation that will basically always need translating into a human-consumable view for consideration and explanation. Just like in the early days of computing with machine code, assembly languages and FORTRAN."

**The decided architecture:**

1. **SysML is the source of truth for relationships.** `Pattern` gets typed `ref` fields. `ArchitecturalPrinciple` is a new part def. All semantic relationships are model-resident, validated by Syside.

2. **The generator pipeline reads SysML and emits everything downstream.** The Python generator parses `pattern-catalogue.sysml`, extracts patterns and their `ref` relationships, and produces: Mermaid diagrams (multiple views), optionally YAML as an intermediate representation (generated, not maintained), and Obsidian note stubs with semantic relationships pre-populated.

3. **Obsidian carries the discursive layer.** The "why" behind each relationship, the design rationale, the open questions — these stay in Obsidian notes. Obsidian is the high-level language; SysML is the compiled binary.

4. **No maintained YAML file.** The YAML created earlier in this session becomes a temporary scaffold — useful as a specification of what the SysML `ref` fields should contain — and is then either deleted or relegated to a generated artefact.

**Why this is the right decision:**

- Consistent with the foundational principle: the model generates everything.
- No parallel structure to drift. The generator reads one source.
- Syside validates relationships. A reference to a deleted pattern errors immediately.
- The "verbosity" concern is manageable — each relationship adds one line per pattern (`ref :>> dependsOn = (patternA, patternB);`). Per-relationship annotations belong in Obsidian, not SysML.
- The YAML file created earlier serves as a complete specification of the relationships to encode. It is consumed by the implementation, not maintained alongside it.

---

## 4. The Relationship Vocabulary

Ten typed predicates, each with a semantic inverse:

| Predicate | Meaning | Inverse |
|---|---|---|
| `dependsOn` | X requires Y to function or make sense | `enables` |
| `enables` | X makes Y possible or practical | `dependsOn` |
| `motivatedBy` | X was designed to fulfil principle Y | `motivates` |
| `generalises` | X is a more abstract version of Y | `specialises` |
| `specialises` | X is a more specific version of Y | `generalises` |
| `constrains` | X limits or governs Y | `constrainedBy` |
| `analogueTo` | X in domain A ≡ Y in domain B | `analogueTo` |
| `extends` | X adds capability on top of Y | `extendedBy` |
| `validates` | X provides evidence that Y works | `validatedBy` |
| `composedWith` | X and Y are used together | `composedWith` |

**SysML representation:** Each predicate becomes a `ref` field on the `Pattern` part def:

```sysml
part def Pattern {
    // ... existing attributes ...
    ref dependsOn : Pattern[0..*];
    ref enables : Pattern[0..*];
    ref motivatedBy : ArchitecturalPrinciple[0..*];
    ref generalises : Pattern[0..*];
    ref constrains : Pattern[0..*];
    ref extends : Pattern[0..*];
    ref validatedBy : Pattern[0..*];
    ref composedWith : Pattern[0..*];
}
```

**Not modelled as `ref` in SysML:** `analogueTo` links domain-specific concepts (e.g. `CSW::MenuItem` ↔ `GSL::Medication`), not patterns. These are cross-domain concept mappings that may be modelled differently — either as a separate `DomainAnalogue` part def or as structured documentation in Obsidian.

---

## 5. Architectural Principles as a New Entity Type

The motivation chain (pattern → principle) introduces `ArchitecturalPrinciple` as a new part def in the PatternCatalogue:

```sysml
part def ArchitecturalPrinciple {
    attribute principleName : String;
    attribute description : String;
    attribute sourceDocument : String;
}
```

Eight principles identified:

1. **Separation of representation and execution** — the foundational architectural commitment
2. **Self-describing system** — the system knows what it is and why
3. **Model generates everything** — corollary of separation; SysML as single source of truth
4. **Two meta model distinction** — business and system meta models are distinct and independently iterable
5. **Validate in coffee shop first** — standing practice since Session 1
6. **Deterministic/auditable reasoning** — clinical decisions use inspectable logic, not probabilistic inference
7. **Patient autonomy and informed choice** — generational self-service roadmap
8. **Clinical governance as first-class concern** — auditability is structural, not bolted on

---

## 6. What Was Already Built (Premature but Potentially Useful)

During this session, before the architectural discussion was completed, several artefacts were created. Their status given the decided architecture:

| Artefact | Location | Status post-decision |
|---|---|---|
| `concept-graph/concept-graph-relationships.yaml` | sysml-model repo | **Temporary scaffold.** Contains the specification of ~50 relationships to encode as SysML `ref` fields. Will be consumed by the implementation, then either deleted or relegated to generated output. |
| `scripts/gen_concept_graph.py` | sysml-model repo | **Needs updating.** Currently reads YAML. Must be refactored to read SysML `ref` fields directly. The view generation logic (overview, dependencies, motivation, analogues, maturity, impact) is reusable. |
| 5 principle notes + index | Obsidian vault | **Keep.** The discursive content about principles is correctly positioned in Obsidian. The principles themselves will also be formalised in SysML as `ArchitecturalPrinciple` instances. |
| Updated Concept Graph Index | Obsidian vault | **Needs revision.** References the "three-layer architecture" with YAML as a maintained layer. Should be updated to reflect the two-layer architecture (SysML + Obsidian, with generators between). |
| Updated pattern template | Obsidian vault | **Keep.** The "Semantic Relationships" section is correct — patterns should show their relationships in Obsidian notes. |
| Updated `pattern-two-layer-action-flow.md` | Obsidian vault | **Keep.** Exemplar for how semantic relationships appear in pattern notes. Content derived from the YAML specification and is correct. |
| Discussion paper (first version) | Downloaded | **Superseded by this document.** |

---

## 7. Horizon Items — Captured for Later Consideration

The following items were raised in this session and are agreed as worth pursuing but not in the current workstream:

### 7.1 Tom Sawyer SysML v2 Viewer — Standalone Web Deployment

**What:** Deploy the Tom Sawyer SysML v2 Viewer (on-premises or AWS) to provide interactive, stakeholder-facing graphical views of the GSL model. Supports automatic layout, colour-coding, nested navigation, and sequence diagrams. Version 2.0 broadens graphical coverage of the SysML v2 spec.

**Value:** Stakeholder communication (Sam, investors, clinical advisors, developers). A navigable graphical view of the entire model without requiring Syside or VS Code.

**Prerequisite:** Requires a SysML v2 API-compliant repository, not just `.sysml` files on disk. The OMG pilot implementation repository, or a compatible one, would need to be running.

**When:** When stakeholder communication becomes a priority or when the model's complexity exceeds what Mermaid projections can usefully convey.

### 7.2 Tom Sawyer Views in VS Code (Beyond Syside)

**What:** Investigate whether Tom Sawyer's Model-Based Engineering plugin or SysML v2 Viewer can provide richer visualisation within the VS Code environment than Syside's built-in diagram views.

**When:** If Syside's views become limiting for day-to-day modelling work.

### 7.3 Tom Sawyer Web-Based Visualisation of Repo Sources

**What:** Use Tom Sawyer's graph visualisation technology to create web-based views that connect to the Git repository's source files, showing relationships between `.sysml` files, packages, and their dependency graph.

**When:** When the repo's structural complexity justifies dedicated visualisation tooling.

### 7.4 Additional Diagramming Approaches

**D2:** Modern text-to-diagram language with concise syntax. Good for architecture and system overviews.

**Graphviz/DOT:** Excellent for algorithmic or graph-heavy views (dependency graphs, state transitions). Claude can generate DOT and Graphviz handles layout.

**Structurizr:** C4-model-oriented. Define model plus views as code, then render diagrams.

**When:** When specific view types are needed that Mermaid cannot adequately represent, or when C4 model alignment becomes important.

---

## 8. Relationship to Prior Documents

| Document | Relationship |
|---|---|
| `gsl-discussion-concept-graph-2026-03-14.md` | Established the need for a concept graph and the SysML-first + Obsidian-navigation architecture. This document extends it with the semantic relationship layer and the hybrid decision. |
| `gsl-architecture-clarification-two-meta-models-2026-03-14.md` | The two meta model distinction applies to the concept graph: patterns are classified by meta model home, and the distinction itself is an architectural principle. |
| `gsl-platform-architecture-principles.md` | Source document for several architectural principles now formalised in the concept graph. |
| `gsl-plan-concept-graph-implementation-2026-03-15.md` | Implementation plan for Stages 1–8 of the concept graph workstream. This document covers the Session 31 enhancement — extending the concept graph with semantic relationships. |
| `gsl-session-report-2026-03-15-s30.md` | Session 30 report covering Stages 1–4. The syntax findings (typed `ref` to metadata def and enum def) are directly relevant to the SysML-native relationship implementation. |

---

*Discussion paper prepared 15 March 2026 (Session 31). Captures the knowledge graph architecture discussion and the decision to use SysML-native relationships with a generator pipeline.*
