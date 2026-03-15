# Discussion Paper: The Concept Graph — Navigable Knowledge Architecture for a Multi-Domain Model-Driven Platform

**Project:** GenderSense (GSL)
**Date:** 14 March 2026 (Session 29)
**Status:** Discussion paper — captures strategic and architectural thinking
**Context:** Post CSW Extension (10 phases, 10 sessions). 29 sessions, 72+ SysML packages, 22 validated architectural patterns, two formally distinguished meta models, two active domains (GSL clinical, CSW demonstrator), a third domain on the horizon (addictions/drug and alcohol). The project has reached a scale where the relationships between its concepts, patterns, and implementations exceed the capacity of working memory and linear documentation.
**Companion documents:** `gsl-service-business-meta-modelling.md` (two meta models), `gsl-architecture-clarification-two-meta-models-2026-03-14.md` (guard rails), `gsl-plan-workstream-concept-graph-2026-03-14.md` (implementation plan)

---

## 1. Why the Concept Graph Is Needed

### 1.1 The scale problem

The GSL project has grown across 29 sessions from a single coffee shop action flow to a 72-package SysML model spanning clinical pathways, a five-layer self-knowledge architecture, a seven-phase business meta model, a running demonstrator with nine frontend pages and 19 API routes, and a strategic architecture for patient self-service across four generational stages. The model is accompanied by discussion papers, specifications, session reports, a work analysis with nine workstreams, and a growing body of validated architectural patterns.

Each of these artefacts contains ideas, designs, decisions, and implementations that relate to other artefacts in non-obvious ways. The composite order concept (deferred in Session 22) relates to the multi-workflow clinical plan (discussed in the self-service paper), which relates to the existing `FulfilDrink` workflow pattern (validated in Session 2), which generalises to any scenario where a single decision triggers concurrent workflows — including an addictions service where a single assessment triggers referrals to detox, counselling, and prescribing pathways simultaneously.

These connections exist. They are real and architecturally significant. But they are currently implicit — scattered across session reports, embedded in doc blocks, referenced in the work analysis by item number, and held together by the founder's memory supplemented by Claude reviewing uploaded documents at the start of each session. This approach has been remarkably productive, but it does not scale.

### 1.2 The multi-domain imperative

The project is not building one system. It is building a framework for modelling service businesses and their supporting systems. The coffee shop is the first demonstrator. Gender-affirming healthcare is the first real service. Addictions care is a plausible second. Each domain instantiates the same pair of meta models (business and system) with different domain-specific types.

The architectural patterns that emerge from building the coffee shop demonstrator — catalogue-as-UI-contract, kanban-as-process-dashboard, audit-as-timeline, persistence policy as queryable reasoning — are not coffee shop patterns. They are *domain-agnostic patterns* that the coffee shop happened to validate first. When GSL builds its clinical formulary, it should be immediately apparent that the four-layer item model (item → catalogue → inventory → external reference) has already been designed, validated, and implemented in another domain. When Sam's addictions service needs concurrent referral workflows, it should be apparent that the composite order pattern — currently deferred — is the same structural problem.

Without a concept graph, each new domain rediscovers patterns that already exist elsewhere in the project. With a concept graph, the patterns are catalogued, their cross-domain instantiations are tracked, and the architectural investment compounds rather than being repeated.

### 1.3 The self-describing system principle

The project's architectural thesis is that the system should be self-describing — it knows what it is, what it does, why it does it, and what rules govern it, because all of that is encoded in the model. The concept graph extends this principle to the meta level: the system also knows *what patterns compose it*, which of those patterns have been validated, where they've been instantiated, and what remains to be done. The model describes not just the business and its system, but the architectural knowledge that produced them.

This is not documentation. Documentation sits alongside the system and is maintained separately. The concept graph is *part of the model* — it lives in SysML, is queryable by generators, and is maintained with the same rigour as the rest of the model. It is the difference between a system that can answer "what is the patient's pathway status?" and a system that can also answer "what architectural pattern does this pathway use, where else has that pattern been applied, and what remains to be built?"

---

## 2. What the Concept Graph Contains

The concept graph tracks four kinds of entities and the relationships between them.

### 2.1 Architectural patterns

A pattern is a reusable structural or behavioural template that applies across domains. It describes *how* something is built, not *what* is built. Examples:

- **Two-layer action flow** — domain-level process description separated from orchestration-level execution detail. Validated in both CSW and GSL. Business system meta model pattern.
- **Catalogue-as-UI-contract** — domain model attributes (available sizes, dietary flags, provision type) drive UI structure directly. Validated in CSW (Counter page). Business system meta model pattern.
- **Four-layer item model** — item definition → catalogue entry → inventory record → external references. Validated in CSW, designed as a meta model concept. Business meta model pattern.
- **Persistence policy as queryable reasoning** — the system carries explicit, auditable rationale for where each domain concept is persisted. Validated in CSW. Business system meta model pattern.

Each pattern carries metadata: name, description, which meta model it belongs to (business or system), its maturity level, and where it has been instantiated across domains.

### 2.2 Domain concepts

A domain concept is a concrete type that instantiates a meta model abstraction in a specific domain. `CoffeeShop::CatalogueEntry` (with `ref item : MenuItem`, typed `AvailabilityStatus` enum, and `pricePence : Integer`) is a domain concept that instantiates the business meta model's generic `BusinessModel::ServiceConcept::CatalogueEntry` (with `String` attributes). A future `GSL::FormularyEntry` would be another instantiation of the same meta model concept.

The concept graph tracks which meta model concepts have been instantiated in which domains, and at what maturity level. This directly supports the multi-domain imperative: when a new domain is added, the concept graph answers "what generic patterns exist that this domain should instantiate?"

### 2.3 Deferred decisions and open items

Not everything is a pattern yet. The composite order model (Session 22) is a deferred decision. The data release model (self-service paper §12.2) is a discussion point. The OptionEvaluator (Session 25) is a designed component that hasn't been implemented. These are future patterns, nascent ideas, or open architectural questions.

The concept graph tracks them alongside patterns, linking each deferred item to the patterns it relates to and the domains it would affect. "Composite orders" links to the "multi-workflow orchestration" pattern (which doesn't exist yet), to the clinical plan concept in GSL, and to the concurrent referral scenario in an addictions service. When the time comes to build it, the full context is navigable.

### 2.4 Cross-domain analogues

The concept graph makes explicit the relationship between things that are structurally the same but named differently across domains:

| CSW | GSL | Addictions |
|---|---|---|
| Menu item | Medication | Intervention |
| Catalogue entry | Formulary entry | Service catalogue entry |
| Order | Clinical plan | Treatment plan |
| Drink preparation workflow | Hormone therapy initiation pathway | Detox pathway |
| Counter page | Patient portal order screen | Referral intake screen |
| Manager GUI | Clinical admin dashboard | Service manager dashboard |

These are not merely analogies — they are *instantiations of the same meta model concepts*. The concept graph formalises this, making it possible to navigate from any domain-specific concept to its generic pattern and then to its analogues in other domains.

---

## 3. The Architectural Approach

### 3.1 SysML as the formal layer

The concept graph lives in the SysML model as a `Foundation::PatternCatalogue` package. Patterns are `part def`s. Domain instantiations are part usages with domain-specific attributes. The model describes its own patterns using the same language it uses to describe everything else.

This is consistent with the project's foundational principle: knowledge lives in the representation layer, not in application code or documentation. The concept graph is representation-layer knowledge about the system's own architectural composition.

The PatternCatalogue is itself a business system meta model concept — it describes how the system is structured, not what the business offers. It lives in Foundation because it is cross-cutting: any package may reference patterns, and any domain may instantiate them.

### 3.2 Obsidian as the navigation layer

The Obsidian vault provides the exploration and discursive layer. Each pattern, concept, and discussion topic gets a note with consistent frontmatter linking to the SysML element. Obsidian's native features — backlinks, graph view, tags, folder structure — provide the navigability without requiring investment in complex plugin infrastructure.

The key principle: **Obsidian is driven from the model, not the other way around.** The SysML PatternCatalogue is the source of truth for what patterns exist, their maturity, and their cross-domain instantiations. Obsidian notes are the space for thinking about patterns discursively — design rationale, open questions, clinical analogues, architectural implications — with links back to the formal model.

If a pattern exists in Obsidian but not in SysML, it's a discussion topic. If it exists in SysML, it's formalised. The migration from one to the other is a deliberate act of architectural maturation.

### 3.3 The MCP bridge

The Model Context Protocol bridge between Obsidian and Claude's session context is the operational glue. If it works, Claude can read both the SysML model (via filesystem MCP) and the Obsidian vault (via the obsidian-mcp-tools plugin) during sessions, cross-referencing patterns, concepts, and discussions in real time. This transforms session efficiency: instead of uploading documents and asking Claude to review everything, the concept graph is directly navigable.

If the MCP bridge doesn't work, the concept graph still has value — it's just accessed via uploads rather than direct reads. The architectural benefit is unchanged; only the operational convenience differs.

---

## 4. Relationship to the Two Meta Models

The concept graph sits above the two meta models. It catalogues the patterns that compose both, without being part of either.

```
┌─────────────────────────────────────────────────────────┐
│                    Concept Graph                         │
│        (Foundation::PatternCatalogue)                    │
│                                                         │
│  Catalogues patterns, tracks cross-domain               │
│  instantiations, links deferred items                   │
│  to architectural context                               │
└────────────────┬────────────────────┬───────────────────┘
                 │                    │
    ┌────────────▼──────────┐  ┌─────▼─────────────────┐
    │  Business Meta Model  │  │ Business System        │
    │                       │  │ Meta Model             │
    │  ServiceConcept       │  │                        │
    │  ActivityModel        │  │ Foundation             │
    │  ResourcePlanning     │  │ ServiceDelivery        │
    │  FinancialPlanning    │  │ Platform               │
    │                       │  │ Knowledge              │
    │  (what the business   │  │ Operations             │
    │   is)                 │  │                        │
    │                       │  │ (how the system works) │
    └────────────┬──────────┘  └─────┬─────────────────┘
                 │                    │
    ┌────────────▼────────────────────▼───────────────────┐
    │              Domain Instantiations                   │
    │                                                     │
    │  CSW (coffee shop) │ GSL (clinical) │ Addictions    │
    │                    │                │ (future)      │
    └─────────────────────────────────────────────────────┘
```

Each pattern in the concept graph is classified as belonging to the business meta model, the system meta model, or crossing both. This classification is enforced by a `MetaModelHome` enum on the `Pattern` part def. The two meta model distinction — the architectural guarantee that business changes and system changes can be iterated independently — is thus embedded in the concept graph itself.

---

## 5. What the Concept Graph Enables

### 5.1 Cross-domain pattern discovery

"Show me all validated patterns that have a CSW instantiation but no GSL instantiation." This is the immediate practical benefit — it surfaces the architectural debt between the demonstrator and the clinical domain. When GSL clinical development begins in earnest, the concept graph provides the roadmap of patterns to instantiate.

### 5.2 Deferred item contextualisation

Every deferred item in the work analysis exists in a context of related patterns, cross-domain analogues, and architectural implications. Today that context is reconstructed by reading session reports. With the concept graph, the context is navigable: "composite orders" links to "multi-workflow orchestration", which links to "clinical plan" in GSL and "concurrent referral" in addictions, which links to the self-service paper's discussion of patient-initiated pathways. The full thread is one traversal.

### 5.3 Onboarding and communication

When explaining the project to a new collaborator (Sam, a potential investor, a clinical advisor, a developer), the concept graph provides a structured entry point. Rather than narrating 29 sessions of history, you can show the pattern catalogue: "here are the architectural patterns we've validated, here's where they've been implemented, here's what they look like in each domain, and here's what remains to be built." The graph view in Obsidian makes this visually navigable.

### 5.4 Architectural impact analysis

When a proposed change affects a pattern, the concept graph shows the blast radius. Changing the two-layer action flow pattern affects every pathway in every domain. Adding a new persistence layer affects every PersistencePolicy instance. The concept graph makes these dependencies explicit and traceable.

### 5.5 Multi-service architecture validation

The strongest test of a pattern is whether it works in a second domain. The concept graph tracks this explicitly. A pattern that's validated in CSW but untested in GSL is an assumption. A pattern that's validated in both is a proven architectural component. The concept graph makes the validation status visible across the entire pattern portfolio.

---

## 6. What the Concept Graph Is Not

**It is not a project management tool.** It does not track timelines, assignments, or sprint progress. The work analysis and next-steps documents continue to serve that function.

**It is not a replacement for session reports.** Session reports capture the narrative of what happened, the decisions made, the findings discovered. The concept graph captures the structural relationships between the artefacts produced.

**It is not a documentation system.** The SysML model, its doc blocks, the discussion papers, and the session reports are the documentation. The concept graph is a *navigation layer* over that documentation — it tells you where to look, not what you'll find when you get there.

**It is not a knowledge graph in the AI/ML sense.** It does not use embeddings, vector search, or semantic similarity. It is a structured, hand-curated graph of architectural concepts with explicit, typed relationships. Its value comes from precision and curation, not from scale or automated inference.

---

## 7. The Cognitive Style Fit

The concept graph is designed for a cognitive style that favours top-down delimitation, extracting generalisable abstractions, and building rigorous models. It provides the "nothing is off the map" assurance at the pattern level, just as the SysML package hierarchy provides it at the system level. It is a model of the model — the system's knowledge about its own architectural composition.

The SysML-first approach keeps the cognitive investment focused on the representation language that drives the entire platform. The Obsidian layer provides the discursive space without requiring mastery of a separate formal system. The MCP bridge (if it works) eliminates the friction of context transfer between the thinking space and the session workspace.

The concept graph is the tool that makes it possible to hold a 72-package model, 29 sessions of architectural decisions, two meta models, multiple domains, and a horizon of future services in a navigable structure rather than in one person's head.

---

## 8. Relationship to Prior Discussion

This paper builds on:

- **Session 26 discussion** — first articulation of the concept graph need, Option C decision (SysML-first + Obsidian navigation), agreement to position as Phase 10 companion workstream.
- **`gsl-service-business-meta-modelling.md` §1** — the two meta model distinction that the concept graph must respect and enforce.
- **`gsl-architecture-clarification-two-meta-models-2026-03-14.md`** — the guard rails that apply to the concept graph's own classification system.
- **`gsl-platform-sysml-modelling-strategy.md` §3.1** — the self-describing system principle that the concept graph extends to the meta level.
- **Strategic snapshot §5** — the 22 validated architectural patterns that seed the concept graph.

---

*Discussion paper prepared 14 March 2026 (Session 29). Captures the strategic and architectural rationale for the Concept Graph workstream.*
