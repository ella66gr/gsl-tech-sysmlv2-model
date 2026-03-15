# GSL Workstream: Concept Graph — Pattern Catalogue and Cross-Domain Concept Registry

**Date:** 14 March 2026
**Status:** Planned — next workstream
**Context:** Post CSW Extension (10 phases, Sessions 20–29). 29 sessions, 72+ SysML packages, 22 validated architectural patterns, two meta models (business and system), two domains (GSL clinical, CSW coffee shop), a third domain on the horizon (addictions/drug and alcohol). The project has reached a scale where the web of relationships between patterns, concepts, deferred items, and cross-domain analogues exceeds working memory.
**Origin:** Session 26 discussion (captured in `gsl-plan-next-steps-and-deferred-items.md` §2, "Pattern Catalogue and Cross-Domain Concept Registry"). Confirmed as Phase 10 companion in Session 26, deferred during Phase 10 execution, re-raised Session 29.
**Estimated effort:** 2 sessions (4–8 stages)

---

## 1. The Problem

The project needs a way to reliably navigate between ideas, designs, deferred items, and implementations across any domain (GSL, CSW, future addictions service, other demonstrators). The current approach — holding it in memory, plus session documents, plus asking Claude to review everything — has worked for 29 sessions but is reaching its limits. Specifically:

- **Cross-domain pattern tracking.** The composite order pattern in CSW relates to the multi-workflow clinical plan in GSL, which would also apply to an addictions service where a single assessment triggers concurrent referrals. These links exist implicitly but are not navigable.
- **Meta model concept → domain instantiation tracking.** `CatalogueEntry` exists as a business meta model part def and as a CSW domain type. When GSL needs a formulary, it should be immediately apparent that the pattern exists and where it's been instantiated.
- **Deferred decision → pattern → implementation tracing.** "Composite orders" is a deferred item (Session 22). It relates to the "multi-workflow orchestration" architectural pattern. It has a clinical analogue. It has been discussed but not designed. These links are scattered across session reports and the work analysis.
- **Multi-service architecture.** The model must accommodate multiple services (gender-affirming care, addictions, others) without duplicating the meta model. Patterns are domain-agnostic; instantiations are domain-specific. This needs to be explicit and navigable.

---

## 2. The Decision (Session 26)

**SysML-first (Option C).** Formal concept definitions live in the SysML model. Obsidian serves as the exploration and navigation layer, driven from the model. Cognitive investment goes into SysML v2, not into learning Dataview or other Obsidian plugin infrastructure.

---

## 3. Design Decisions to Resolve

### 3.1 How do patterns reference heterogeneous meta model elements?

A pattern like "catalogue-as-UI-contract" relates to `CatalogueEntry` (a part def in ServiceConcept), to the Counter page (an implementation artefact), and to the principle that domain model attributes drive UI structure. The pattern is a higher-order concept that *describes how* something is used, not the thing itself.

**The question:** Can a single `ref` target multiple SysML element kinds (part defs, metadata defs, enum defs, action defs)?

**Options:**
- (a) Typed `ref` links per element kind: `ref relatedPartDefs : SomeType[0..*]`, `ref relatedMetadataDefs : SomeOther[0..*]`. Verbose but precise. Requires a common supertype or separate refs per kind.
- (b) String references for cross-model links, `ref` only for domain instantiations. Pragmatic — the pattern says `relatedElements = "ServiceConcept::CatalogueEntry, MetadataLibrary::AgencyClassification"` as documentation, and uses typed `ref` only where the target type is homogeneous.
- (c) A single `ref relatedConcepts : ConceptReference[0..*]` where `ConceptReference` is a lightweight part def that wraps a name + package path + element kind. Structured but without requiring type-level polymorphism.

**Resolution approach:** Try option (a) in a syntax test file at the start of Session 30. If `ref` to a `metadata def` type works (untested — syntax reference TODO), option (a) is viable. If not, fall back to option (b) or (c). The syntax investigation is itself valuable regardless.

### 3.2 How is maturity tracked per domain?

A pattern might be "validated" in CSW and "discussion" in GSL. Maturity is per-domain-instantiation, not per-pattern.

**Resolution:** The `Pattern` part def carries its own maturity (has the pattern been generalised into a meta model?). Each domain instantiation is a separate part usage with its own maturity attribute. Example:

```
part catalogueAsUiContract : Pattern {
    attribute :>> patternName = "Catalogue-as-UI-contract";
    attribute :>> maturity = PatternMaturity::validated;  // as a meta model concept
    attribute :>> metaModelClassification = MetaModelHome::business;
}

part cswCatalogueAsUiContract : DomainInstantiation {
    ref pattern : Pattern = catalogueAsUiContract;
    attribute :>> domain = "CSW";
    attribute :>> maturity = PatternMaturity::validated;
    attribute :>> implementationRef = "Counter page (Phase 5)";
}

part gslFormularyAsUiContract : DomainInstantiation {
    ref pattern : Pattern = catalogueAsUiContract;
    attribute :>> domain = "GSL";
    attribute :>> maturity = PatternMaturity::discussion;
    attribute :>> implementationRef = "";
}
```

### 3.3 Where is the boundary between PatternCatalogue and existing meta model elements?

`CatalogueEntry` is already in the business meta model. The PatternCatalogue shouldn't duplicate it — it should reference it. But "kanban-as-process-dashboard" is a validated pattern with no corresponding meta model part def.

**Resolution:** The PatternCatalogue accommodates both:
- **Formalised patterns** — patterns that have a corresponding meta model element. The pattern references the element. Example: the "four-layer item model" pattern references `CatalogueEntry`, `InventoryRecord`, `ExternalReference`.
- **Architectural guidance patterns** — patterns that describe how to use the system but don't have a structural counterpart. Example: "kanban-as-process-dashboard", "audit-as-timeline", "hand-crafted SVG for stable pathways". These exist only as Pattern instances with descriptive attributes.

### 3.4 How does Obsidian connect without Dataview?

**Resolution:** Obsidian native features only:
- Folder per entity type: `patterns/`, `concepts/`, `discussions/`, `deferred/`
- Consistent frontmatter: `sysml_element`, `meta_model`, `domains`, `maturity`, `tags`
- Tags for filtering: `#meta-model/business`, `#meta-model/system`, `#domain/csw`, `#domain/gsl`, `#maturity/validated`
- Backlinks and graph view for navigation
- No Dataview queries — just structured notes with standard Obsidian linking

### 3.5 Is the MCP bridge a prerequisite?

**Resolution:** Investigate in Session 30 as a setup spike. If it works, it transforms session efficiency. If not, fall back to uploads. Not a blocker for the SysML work.

---

## 4. SysML Design

### New package: `Foundation::PatternCatalogue`

```sysml
package PatternCatalogue {
    private import ScalarValues::*;

    doc /* Cross-domain concept registry and architectural pattern
         * catalogue. The model describes its own patterns.
         *
         * Business system meta model concept — this package is
         * itself part of the system meta model (it describes how
         * the system is structured, not what the business offers).
         *
         * Two kinds of entries:
         * - Patterns: reusable architectural or business model
         *   templates (e.g. "catalogue-as-UI-contract")
         * - Domain instantiations: where a pattern has been
         *   implemented in a specific domain (e.g. CSW Counter
         *   page, GSL formulary)
         *
         * Source: Session 26 discussion, Session 29 workstream plan. */

    enum def PatternMaturity {
        doc /* Lifecycle stage of a pattern or instantiation. */
        discussion;       // identified in conversation, not yet designed
        designed;         // structurally specified, not yet implemented
        implemented;      // built in at least one domain
        validated;        // built, tested, and confirmed as reusable
    }

    enum def MetaModelHome {
        doc /* Which meta model a pattern primarily belongs to.
             * Per gsl-architecture-clarification-two-meta-models. */
        business;         // business meta model (what the business is)
        businessSystem;   // business system meta model (how the system works)
        crossCutting;     // spans both meta models
    }

    enum def PatternKind {
        doc /* Whether a pattern has been formalised into a meta
             * model element or exists as architectural guidance. */
        formalised;       // has a corresponding part def / metadata def
        guidance;         // architectural guidance, no structural counterpart
    }

    part def Pattern {
        doc /* A reusable architectural or business model template.
             * Domain-agnostic — describes a structural or behavioural
             * approach that applies across domains. */
        attribute patternName : String;
        attribute description : String;
        attribute maturity : PatternMaturity;
        attribute metaModelClassification : MetaModelHome;
        attribute kind : PatternKind;
        attribute relatedElements : String;     // meta model elements this pattern relates to
        attribute sourceSession : String;       // when the pattern was first identified
        attribute validatedIn : String;         // which domains have validated it
    }

    part def DomainInstantiation {
        doc /* A specific implementation of a pattern in a domain.
             * Tracks where a pattern has been built and at what
             * maturity level. */
        attribute domain : String;              // "CSW", "GSL", "Addictions"
        attribute maturity : PatternMaturity;
        attribute implementationRef : String;   // what was built (page, API, model element)
        attribute sessionRef : String;          // when it was built
        attribute notes : String;
    }
}
```

**Note:** The `relatedElements` and `implementationRef` attributes use String rather than typed `ref`. This is the pragmatic option (3.1b) pending the syntax investigation. If typed cross-element refs work, these can be upgraded.

---

## 5. Seeding: Patterns to Catalogue

The strategic snapshot lists 22 validated architectural patterns. The work analysis has deferred items. The discussion papers have conceptual patterns. The initial seed should cover at least the core set:

### Business meta model patterns

| Pattern | Maturity | CSW | GSL |
|---|---|---|---|
| Four-layer item model (item → catalogue → inventory → external ref) | validated | ✓ | discussion |
| Activity taxonomy (five categories) | validated | ✓ | ✓ |
| Scenario comparison and projection | validated | — | ✓ |
| Persistence policy as queryable reasoning | validated | ✓ | — |

### Business system meta model patterns

| Pattern | Maturity | CSW | GSL |
|---|---|---|---|
| Two-layer action flow (domain + orchestration) | validated | ✓ | ✓ |
| Metadata-driven generation | validated | ✓ | ✓ |
| XState in Temporal (pure state machine enforcement) | validated | ✓ | — |
| Three-persistence-layer architecture | validated | ✓ | designed |
| Catalogue-as-UI-contract | validated | ✓ | — |
| Kanban-as-process-dashboard | validated | ✓ | — |
| Audit-as-timeline data source | validated | ✓ | — |
| Hand-crafted SVG for stable pathways | validated | ✓ | — |
| Infrastructure health as application concern | validated | ✓ | — |
| Multi-source metrics with graceful degradation | validated | ✓ | — |
| Agency classification on pathway actions | designed | — | — |
| Notification triggers on state transitions | discussion | — | — |

### Deferred / conceptual patterns

| Pattern | Status | Related to |
|---|---|---|
| Composite order / multi-workflow orchestration | deferred (Session 22) | Clinical plan, addictions concurrent referrals |
| Self-assessment dashboard (KL Increment 3) | landing zone built | Five-layer self-knowledge |
| OptionEvaluator / "Help Me Choose" | designed | Informed Choice Engine, Generation 3 self-service |
| Data release model (patient-facing) | discussion | Self-service, CoPHR |

---

## 6. Obsidian Vault Structure

```
gsl-vault/
├── patterns/
│   ├── pattern-two-layer-action-flow.md
│   ├── pattern-catalogue-as-ui-contract.md
│   ├── pattern-persistence-policy.md
│   └── ...
├── concepts/
│   ├── concept-catalogue-entry.md
│   ├── concept-agency-classification.md
│   └── ...
├── discussions/
│   ├── discussion-composite-orders.md
│   ├── discussion-self-service-generations.md
│   └── ...
├── domains/
│   ├── domain-csw.md
│   ├── domain-gsl.md
│   └── domain-addictions.md
└── templates/
    ├── template-pattern.md
    ├── template-concept.md
    └── template-discussion.md
```

### Frontmatter schema (pattern template)

```yaml
---
sysml_element: Foundation::PatternCatalogue::twoLayerActionFlow
meta_model: system          # business | system | cross-cutting
kind: formalised            # formalised | guidance
maturity: validated
domains:
  - csw: validated
  - gsl: validated
related_elements:
  - ServiceDelivery::ClinicalPathways
  - Foundation::MetadataLibrary::TemporalWorkflow
source_session: 1
tags:
  - pattern
  - meta-model/system
  - domain/csw
  - domain/gsl
  - maturity/validated
---
```

---

## 7. Phases

### Session 30: Foundation and Seeding

**Stage 1: Syntax investigation** (30 min)
- Test `ref` to `metadata def` types and `ref` to `enum def` types in a syntax test file
- Determine whether option (a), (b), or (c) from §3.1 is viable
- Document findings in syntax reference

**Stage 2: PatternCatalogue SysML package** (45 min)
- Create `Foundation::PatternCatalogue` with `Pattern`, `DomainInstantiation`, and supporting enums
- Instantiate the core set of patterns (at least 10–12 from §5)
- Verify in Syside

**Stage 3: Obsidian vault setup** (30 min)
- Create vault structure with folders and templates
- Attempt MCP bridge setup (`obsidian-mcp-tools` plugin)
- Create 3–5 pattern notes to establish the template
- Test: can Claude read vault notes via MCP?

**Stage 4: Cross-reference convention** (15 min)
- Document the naming convention between SysML elements and Obsidian notes
- Document the frontmatter schema
- Add convention to `gsl-guide-repo-conventions.md`

**Commit:** `"Foundation: PatternCatalogue package — concept graph (Session 30)"`

### Session 31: Population and Integration

**Stage 5: Full pattern population** (60 min)
- Instantiate all 22+ validated patterns from the strategic snapshot
- Add deferred/conceptual patterns from work analysis and discussion papers
- Add domain instantiation usages for CSW and GSL

**Stage 6: Obsidian population** (45 min)
- Create Obsidian notes for all catalogued patterns
- Create concept notes for key meta model elements
- Create discussion notes for major deferred items
- Verify backlinks and graph view navigation

**Stage 7: Integration test** (30 min)
- Navigate a cross-domain question end-to-end: "What CSW patterns have no GSL instantiation?"
- Navigate from a deferred item to its related patterns and analogues
- Test Claude reading vault + filesystem in a single query (if MCP bridge works)

**Stage 8: Documentation** (15 min)
- Design rationale document
- Updated conventions guide
- Workstream complete

---

## 8. What This Workstream Does Not Do

- **Does not restructure the existing SysML model.** The PatternCatalogue is additive — a new package in Foundation. Existing packages are unchanged.
- **Does not require Dataview or complex Obsidian plugins.** Native Obsidian features only (backlinks, tags, graph view, folder structure, frontmatter).
- **Does not model Sam's addictions service.** The architecture accommodates it — a `domain-addictions.md` Obsidian note and a placeholder domain entry — but no clinical modelling is attempted.
- **Does not replace the session documents.** Session reports, strategic snapshots, and the work analysis continue as before. The concept graph complements them with navigable cross-domain links.

---

*Workstream plan prepared 14 March 2026 (Session 29). Implements the Phase 10 companion agreed in Session 26.*
