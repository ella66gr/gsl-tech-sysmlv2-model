# Concept Graph Workstream — Detailed Implementation Plan

**Workstream:** Pattern Catalogue and Cross-Domain Concept Registry
**Date:** 15 March 2026 (Session 30)
**Status:** Implementation plan — ready for execution
**Source plan:** `gsl-plan-workstream-concept-graph-2026-03-14.md`
**Discussion paper:** `gsl-discussion-concept-graph-2026-03-14.md`
**Prerequisites:** CSW Extension workstream complete (Phases 1–10, Sessions 20–29). Two meta models formally distinguished. 22+ validated architectural patterns. Syntax reference v3.11.
**Estimated effort:** 8 stages across 2 sessions (Sessions 30–31)

---

## Goal

Build a navigable, model-resident knowledge architecture that catalogues the project's architectural patterns, tracks their cross-domain instantiations, links deferred decisions to their architectural context, and makes explicit the structural analogies between the coffee shop, clinical, and future domains. The concept graph is the project's self-knowledge about its own architectural composition.

### What this workstream delivers

1. **SysML `Foundation::PatternCatalogue` package** — formal definitions of `Pattern`, `DomainInstantiation`, and supporting enums, plus initial pattern instances covering the 22+ validated patterns and key deferred/conceptual items.

2. **Obsidian vault** — folder structure, templates, and an initial population of pattern, concept, and discussion notes with frontmatter linking to SysML elements. Native Obsidian features only (backlinks, tags, graph view).

3. **Cross-reference convention** — documented naming convention between SysML elements and Obsidian notes, added to the repo conventions guide.

4. **MCP bridge assessment** — attempt to connect the Obsidian vault to the session workspace via MCP. If it works, session efficiency is transformed. If not, the vault is accessed via uploads.

### What this workstream does not do

- Does not restructure existing SysML packages. PatternCatalogue is additive.
- Does not require Dataview or complex Obsidian plugins.
- Does not model Sam's addictions service beyond placeholder entries.
- Does not replace session documents, strategic snapshots, or the work analysis.
- Does not attempt typed cross-element `ref` links unless the syntax investigation (Stage 1) confirms they work. Falls back to String references.

---

## Architecture Overview

### New files

| File | Location | Purpose |
|---|---|---|
| `pattern-catalogue.sysml` | `model/` | New top-level model file for `Foundation::PatternCatalogue` |
| `test-ref-to-metadata-def.sysml` | `model/syntax-tests/` | Syntax investigation: can `ref` target a `metadata def` type? |

### Modified files

| File | Change |
|---|---|
| `model/foundation.sysml` | Add `private import Foundation::PatternCatalogue::*;` (if needed — see Stage 2 design note) |
| `model/gendersense.sysml` | Add import for PatternCatalogue if the root assembly file imports all packages |
| `documentation/guides/gsl-guide-repo-conventions.md` | Add §PatternCatalogue–Obsidian cross-reference convention |

### New non-model artefacts

| Artefact | Location | Purpose |
|---|---|---|
| Obsidian vault | `~/Developer/gsl-tech/gsl-vault/` (outside the sysml-model repo) | Navigation and exploration layer |
| Vault templates | `gsl-vault/templates/` | Consistent frontmatter schema for pattern, concept, discussion notes |

### Design note: separate file for PatternCatalogue

The PatternCatalogue is placed in its own `.sysml` file rather than appending to `foundation.sysml`. Rationale:

- `foundation.sysml` is already substantial (cross-cutting types, metadata library, common types, generation pipeline).
- PatternCatalogue will grow as patterns are catalogued — potentially 30–50 instances in steady state.
- A separate file makes it easy to see the concept graph as a coherent unit.
- Syside resolves cross-file packages within the same workspace — no structural barrier.
- The package is still `Foundation::PatternCatalogue` (nested inside Foundation) even though it lives in a separate file. **However:** Syside does NOT merge same-named packages across files. Therefore `pattern-catalogue.sysml` declares `package Foundation { package PatternCatalogue { ... } }` — the outer `Foundation` wrapper is required for namespace resolution but must not duplicate any content from `foundation.sysml`.

**Risk: Syside may reject the duplicate `Foundation` package declaration across files.** If so, the fallback is to make `PatternCatalogue` a top-level sibling package (`package PatternCatalogue { ... }`) that imports from Foundation. This is architecturally less clean but functionally identical. The syntax investigation in Stage 1 will test this.

---

## Risk Assessment

### R1: Duplicate package declaration across files

**Risk:** Syside 0.8.5 may reject `package Foundation { package PatternCatalogue { ... } }` in `pattern-catalogue.sysml` when `foundation.sysml` already declares `package Foundation { ... }`. The syntax reference (§1) states "Syside does NOT merge same-named packages across files — this triggers `global-namespace-distinguishability` errors."

**Resolution:** Test in Stage 1. If it fails, fall back to a top-level `package PatternCatalogue { ... }` that does `private import Foundation::CommonTypes::*;` etc. Update the architecture documentation to note PatternCatalogue is conceptually part of Foundation but structurally a sibling package due to Syside limitations.

### R2: `ref` to heterogeneous element kinds

**Risk:** The workstream plan §3.1 identifies the question of whether a `Pattern` can hold typed `ref` links to `metadata def`, `enum def`, `action def`, and `part def` targets. If `ref relatedPartDefs : SomeType[0..*]` doesn't work for heterogeneous target types, the pattern's relationships become String-only.

**Resolution:** Stage 1 syntax investigation. Test `ref` to a `metadata def` type (the most uncertain case). If typed refs work, use option (a) — typed refs per element kind. If not, use option (b) — String references for cross-model links, as already proposed in the workstream plan §4 design. The fallback is already designed and ready.

### R3: Scale of initial seeding

**Risk:** Instantiating all 22+ patterns plus deferred items plus domain instantiations in a single session could be time-consuming and error-prone. Each pattern needs a `part` usage with 8+ attribute redefinitions.

**Resolution:** Prioritise the core set in Session 30 (Stage 2: 10–12 patterns). Complete the full population in Session 31 (Stage 5). Commit after the core set so progress is not lost.

### R4: Obsidian MCP bridge

**Risk:** The `obsidian-mcp-tools` plugin may not work, may not be maintained for current Obsidian versions, or may require configuration that blocks session progress.

**Resolution:** Time-boxed to 20 minutes in Stage 3. If it doesn't work within that window, proceed with manual vault setup. The vault has value regardless of MCP connectivity.

### R5: `system` reserved word in pattern names or enum literals

**Risk:** Session 29 discovered that `system` is a KerML reserved word causing silent parse failures. The MetaModelHome enum uses `businessSystem` — which is safe (compound word). But any pattern names or descriptions that include the word `system` as a standalone identifier could trigger the same issue.

**Resolution:** Already mitigated by the Session 29 naming convention. All enum literals use compound camelCase. String attributes are not affected (reserved words only matter for identifiers). No action needed beyond maintaining awareness.

---

## Stages

### Stage 1: Syntax Investigation — Package Nesting and Cross-Element Refs

**Goal:** Resolve the two open syntax questions before writing production SysML. This stage produces findings that determine the architectural approach for Stages 2–5.

**Time estimate:** 30 minutes

**Work:**

1. **Read the syntax reference** (`documentation/reference/gsl-sysml-v2-syntax-reference-v3.11-2026-03-11.md`).

2. **Test A: Nested package declaration across files.**

   Create `model/syntax-tests/test-pattern-catalogue-nesting.sysml`:

   ```sysml
   // =========================================================================
   // SYNTAX TEST: Nested package in a separate file
   //
   // Purpose: Can we declare package Foundation { package PatternCatalogue {} }
   //          in a separate file when foundation.sysml already declares
   //          package Foundation { ... }?
   //
   // Expected: Syside will reject this with global-namespace-distinguishability
   //           error. If so, PatternCatalogue becomes a top-level package.
   // =========================================================================

   package Foundation {
       package SyntaxTestNestedPackage {
           private import ScalarValues::*;

           doc /* Test: does Syside allow a second file to add a nested
                * package inside an already-declared outer package? */

           part def TestNestedElement {
               attribute testName : String;
           }
       }
   }
   ```

   **Check in Syside.** If clean: PatternCatalogue nests inside Foundation. If error: PatternCatalogue is a top-level package.

3. **Test B: `ref` to a `metadata def` type.**

   Create `model/syntax-tests/test-ref-to-metadata-def.sysml`:

   ```sysml
   // =========================================================================
   // SYNTAX TEST: ref targeting a metadata def type
   //
   // Purpose: Can a part def hold ref x : SomeMetadataDef?
   //          Needed for PatternCatalogue to reference related metadata defs.
   //
   // Also tests: ref to enum def, ref to action def (cross-package).
   // =========================================================================

   package SyntaxTestRefToMetadataDef {
       private import ScalarValues::*;
       private import Foundation::MetadataLibrary::*;

       doc /* Test: ref targeting metadata def, enum def, action def types. */

       // Test A: ref to a metadata def
       part def TestRefToMetadata {
           attribute holderName : String;
           ref relatedMetadata : ClinicalReviewGate;  // metadata def from MetadataLibrary
       }

       // Test B: ref to an enum def
       part def TestRefToEnum {
           attribute holderName : String;
           ref relatedEnum : AgencyType;  // enum def from MetadataLibrary
       }
   }
   ```

   **Check in Syside.** Document which `ref` target kinds work and which don't.

4. **Record findings.** Update the session notes with outcomes. These findings determine whether Stage 2 uses typed refs (option a) or String references (option b/c) for the `Pattern.relatedElements` attribute.

5. **Clean up.** Rename test files with `.verified` or `.failed` suffix per established convention. Delete the nesting test (it was only needed to decide the package structure).

**Commit:** No commit — syntax tests are exploratory. The nesting test file is deleted after evaluation. The ref test file is retained with appropriate suffix.

---

### Stage 2: PatternCatalogue SysML Package — Definitions and Core Patterns

**Goal:** Create the PatternCatalogue package with type definitions and seed 10–12 core patterns. This is the formal layer of the concept graph.

**Time estimate:** 45–60 minutes

**Work:**

1. **Create `model/pattern-catalogue.sysml`.**

   The package structure depends on Stage 1 findings:
   - **If nesting works:** `package Foundation { package PatternCatalogue { ... } }`
   - **If nesting fails (expected):** `package PatternCatalogue { private import Foundation::CommonTypes::*; ... }`

2. **Define the type system:**

   ```sysml
   // =========================================================================
   // PATTERN CATALOGUE — Cross-domain concept registry
   //
   // The model describes its own architectural patterns.
   // Business system meta model concept — placed in Foundation (or as
   // a sibling package) for cross-cutting access.
   //
   // Source: Session 26 discussion, Session 29 workstream plan,
   //         Session 30 implementation.
   // =========================================================================

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
            * Source: Session 26 discussion, Session 29–30. */

       // -- Classification enums --------------------------------

       enum def PatternMaturity {
           doc /* Lifecycle stage of a pattern or instantiation. */
           discussion;
           designed;
           implemented;
           validated;
       }

       enum def MetaModelHome {
           doc /* Which meta model a pattern primarily belongs to.
                * Per gsl-architecture-clarification-two-meta-models. */
           business;
           businessSystem;
           crossCutting;
       }

       enum def PatternKind {
           doc /* Whether a pattern has been formalised into a meta
                * model element or exists as architectural guidance. */
           formalised;
           guidance;
       }

       // -- Core type definitions -------------------------------

       part def Pattern {
           doc /* A reusable architectural or business model template.
                * Domain-agnostic — describes a structural or behavioural
                * approach that applies across domains.
                *
                * The relatedElements attribute uses String references
                * to meta model elements. If future syntax investigation
                * confirms typed cross-element refs work, these can be
                * upgraded to typed ref links. */
           attribute patternName : String;
           attribute description : String;
           attribute maturity : PatternMaturity;
           attribute metaModelClassification : MetaModelHome;
           attribute kind : PatternKind;
           attribute relatedElements : String;
           attribute sourceSession : String;
           attribute validatedIn : String;
       }

       part def DomainInstantiation {
           doc /* A specific implementation of a pattern in a domain.
                * Tracks where a pattern has been built and at what
                * maturity level. */
           attribute domain : String;
           attribute maturity : PatternMaturity;
           attribute implementationRef : String;
           attribute sessionRef : String;
           attribute notes : String;
       }
   ```

   **Note:** If Stage 1 confirms typed `ref` to metadata/enum defs works, add typed refs to `Pattern` alongside or replacing `relatedElements : String`. The workstream plan §3.1 option (a) would look like:

   ```sysml
       part def Pattern {
           // ... existing attributes ...
           ref relatedPartDefs : ??? [0..*];      // typed refs
           ref relatedMetadataDefs : ??? [0..*];   // typed refs
           // relatedElements : String retained for non-ref-able targets
       }
   ```

   However, `ref` requires a specific part def / metadata def as the type — it cannot target a generic "any element" supertype. Unless all referenced elements share a common supertype (they don't — part defs and metadata defs are different KerML metaclasses), option (a) requires one `ref` per target type. This is verbose but precise. **Likely outcome: String references (option b) are the pragmatic choice** for the initial implementation, with typed refs added for specific homogeneous collections if the syntax works.

3. **Seed the core pattern instances.**

   Instantiate 10–12 patterns from the strategic snapshot §5, covering both meta models:

   **Business meta model patterns:**

   ```sysml
       // -- Business meta model patterns -------------------------

       part fourLayerItemModel : Pattern {
           attribute :>> patternName = "Four-layer item model";
           attribute :>> description = "Item definition to catalogue entry to inventory record to external references. Separates intrinsic properties from business decisions from operational state from external knowledge.";
           attribute :>> maturity = PatternMaturity::validated;
           attribute :>> metaModelClassification = MetaModelHome::business;
           attribute :>> kind = PatternKind::formalised;
           attribute :>> relatedElements = "BusinessModel::ServiceConcept::CatalogueEntry, BusinessModel::ServiceConcept::ExternalReference, BusinessModel::ResourcePlanning::InventoryRecord";
           attribute :>> sourceSession = "Session 20 (CSW Phase 1)";
           attribute :>> validatedIn = "CSW";
       }

       part activityTaxonomy : Pattern {
           attribute :>> patternName = "Activity taxonomy";
           attribute :>> description = "Five activity categories (clinical, operational, administrative, technical, governance) as a generic classification for any service business.";
           attribute :>> maturity = PatternMaturity::validated;
           attribute :>> metaModelClassification = MetaModelHome::business;
           attribute :>> kind = PatternKind::formalised;
           attribute :>> relatedElements = "BusinessModel::ActivityModel::ActivityCategory";
           attribute :>> sourceSession = "Session 15 (Business Meta Model Phase 3)";
           attribute :>> validatedIn = "CSW, GSL";
       }

       part scenarioComparisonProjection : Pattern {
           attribute :>> patternName = "Scenario comparison and projection";
           attribute :>> description = "Two-variant scenario modelling with Python projection engine and sensitivity analysis. Compares strategic alternatives quantitatively.";
           attribute :>> maturity = PatternMaturity::validated;
           attribute :>> metaModelClassification = MetaModelHome::business;
           attribute :>> kind = PatternKind::formalised;
           attribute :>> relatedElements = "BusinessModel::ScenarioModelling::ScenarioDefinition, BusinessModel::ScenarioModelling::ScenarioComparison";
           attribute :>> sourceSession = "Session 17 (Business Meta Model Phase 5)";
           attribute :>> validatedIn = "GSL";
       }

       part persistencePolicyAsReasoning : Pattern {
           attribute :>> patternName = "Persistence policy as queryable reasoning";
           attribute :>> description = "System carries explicit, auditable rationale for where each domain concept is persisted and why. Maps domain concepts to persistence layers with characteristics and justification.";
           attribute :>> maturity = PatternMaturity::validated;
           attribute :>> metaModelClassification = MetaModelHome::business;
           attribute :>> kind = PatternKind::formalised;
           attribute :>> relatedElements = "Foundation::CommonTypes::PersistencePolicy, Foundation::CommonTypes::PersistenceLayer, Foundation::CommonTypes::DataCharacteristic";
           attribute :>> sourceSession = "Session 20 (CSW Phase 1), formalised Session 29 (Phase 10)";
           attribute :>> validatedIn = "CSW";
       }
   ```

   **Business system meta model patterns (core set):**

   ```sysml
       // -- Business system meta model patterns ------------------

       part sysmlAsSingleSourceOfTruth : Pattern {
           attribute :>> patternName = "SysML v2 as single source of truth";
           attribute :>> description = "Model generates execution layer: TypeScript types, XState machines, Temporal workflows, Mermaid diagrams. Knowledge lives in the representation layer.";
           attribute :>> maturity = PatternMaturity::validated;
           attribute :>> metaModelClassification = MetaModelHome::businessSystem;
           attribute :>> kind = PatternKind::guidance;
           attribute :>> relatedElements = "Foundation::GenerationPipeline";
           attribute :>> sourceSession = "Session 1";
           attribute :>> validatedIn = "CSW, GSL";
       }

       part twoLayerActionFlow : Pattern {
           attribute :>> patternName = "Two-layer pathway modelling";
           attribute :>> description = "Domain-level process description separated from orchestration-level execution detail. Domain layer for clinical governance; orchestration layer for system execution.";
           attribute :>> maturity = PatternMaturity::validated;
           attribute :>> metaModelClassification = MetaModelHome::businessSystem;
           attribute :>> kind = PatternKind::formalised;
           attribute :>> relatedElements = "ServiceDelivery::ClinicalPathways, Foundation::MetadataLibrary::TemporalWorkflow";
           attribute :>> sourceSession = "Session 1";
           attribute :>> validatedIn = "CSW, GSL";
       }

       part catalogueAsUiContract : Pattern {
           attribute :>> patternName = "Catalogue-as-UI-contract";
           attribute :>> description = "Domain model attributes (available sizes, dietary flags, provision type) drive UI structure directly. The catalogue is the contract between the model and the frontend.";
           attribute :>> maturity = PatternMaturity::validated;
           attribute :>> metaModelClassification = MetaModelHome::businessSystem;
           attribute :>> kind = PatternKind::guidance;
           attribute :>> relatedElements = "CoffeeShop::CatalogueEntry";
           attribute :>> sourceSession = "Session 24 (CSW Phase 5)";
           attribute :>> validatedIn = "CSW";
       }

       part kanbanAsProcessDashboard : Pattern {
           attribute :>> patternName = "Kanban-as-process-dashboard";
           attribute :>> description = "XState lifecycle states map to kanban columns. Process state drives operational queue visualisation.";
           attribute :>> maturity = PatternMaturity::validated;
           attribute :>> metaModelClassification = MetaModelHome::businessSystem;
           attribute :>> kind = PatternKind::guidance;
           attribute :>> relatedElements = "ServiceDelivery::ClinicalPathways, Foundation::MetadataLibrary::StateTransitionTrigger";
           attribute :>> sourceSession = "Session 26 (CSW Phase 7)";
           attribute :>> validatedIn = "CSW";
       }

       part threeLayerPersistence : Pattern {
           attribute :>> patternName = "Three-persistence-layer architecture";
           attribute :>> description = "CDR for clinical data (archetype-validated, versioned), PostgreSQL for business data (CRUD, transactions, joins), Temporal for process state (durable execution). Each layer has distinct characteristics and access patterns.";
           attribute :>> maturity = PatternMaturity::validated;
           attribute :>> metaModelClassification = MetaModelHome::businessSystem;
           attribute :>> kind = PatternKind::formalised;
           attribute :>> relatedElements = "Foundation::CommonTypes::PersistenceLayer";
           attribute :>> sourceSession = "Session 20 (CSW Phase 1)";
           attribute :>> validatedIn = "CSW";
       }

       part fiveLayerSelfKnowledge : Pattern {
           attribute :>> patternName = "Five-layer self-knowledge architecture";
           attribute :>> description = "ConstraintEvaluator, OperationalStateAggregator, GoalProjector, GapAnalyser, RemediationPlanner. Domain-agnostic self-assessment architecture validated as applicable beyond healthcare.";
           attribute :>> maturity = PatternMaturity::validated;
           attribute :>> metaModelClassification = MetaModelHome::businessSystem;
           attribute :>> kind = PatternKind::formalised;
           attribute :>> relatedElements = "Knowledge::SelfKnowledge";
           attribute :>> sourceSession = "Session 10 (Knowledge Layer Phase 3)";
           attribute :>> validatedIn = "GSL";
       }
   ```

   **Deferred / conceptual patterns (2–3 to establish the pattern):**

   ```sysml
       // -- Deferred / conceptual patterns -----------------------

       part compositeOrderOrchestration : Pattern {
           attribute :>> patternName = "Composite order / multi-workflow orchestration";
           attribute :>> description = "Single decision triggers concurrent workflows. One order contains multiple items, each with its own fulfilment workflow. Deferred in CSW (Session 22), relates to clinical plan multi-pathway and addictions concurrent referrals.";
           attribute :>> maturity = PatternMaturity::discussion;
           attribute :>> metaModelClassification = MetaModelHome::businessSystem;
           attribute :>> kind = PatternKind::guidance;
           attribute :>> relatedElements = "ServiceDelivery::ClinicalPathways (future multi-pathway)";
           attribute :>> sourceSession = "Session 22 (deferred)";
           attribute :>> validatedIn = "";
       }

       part agencyClassificationOnActions : Pattern {
           attribute :>> patternName = "Agency classification on pathway actions";
           attribute :>> description = "Annotating pathway action nodes with who performs them (patient, clinician, automated, collaborative) and at what authority model version. Supports generational self-service roadmap.";
           attribute :>> maturity = PatternMaturity::designed;
           attribute :>> metaModelClassification = MetaModelHome::businessSystem;
           attribute :>> kind = PatternKind::formalised;
           attribute :>> relatedElements = "Foundation::MetadataLibrary::AgencyClassification, Foundation::MetadataLibrary::AgencyType";
           attribute :>> sourceSession = "Session 25 (self-service paper), formalised Session 29";
           attribute :>> validatedIn = "";
       }
   ```

4. **Seed domain instantiation examples (3–4):**

   ```sysml
       // -- Domain instantiations (examples) --------------------

       part cswFourLayerItemModel : DomainInstantiation {
           attribute :>> domain = "CSW";
           attribute :>> maturity = PatternMaturity::validated;
           attribute :>> implementationRef = "CoffeeShop::MenuItem, CoffeeShop::CatalogueEntry, CoffeeShop::InventoryRecord, CoffeeShop::ExternalReference. Counter page, Manager GUI, Records page.";
           attribute :>> sessionRef = "Sessions 20–25";
           attribute :>> notes = "Full four-layer model implemented and validated in the demonstrator. 11 menu items, 4 PostgreSQL tables, CRUD API.";
       }

       part gslFourLayerItemModel : DomainInstantiation {
           attribute :>> domain = "GSL";
           attribute :>> maturity = PatternMaturity::discussion;
           attribute :>> implementationRef = "";
           attribute :>> sessionRef = "Identified Session 20";
           attribute :>> notes = "Clinical analogue: Medication to FormularyEntry to ClinicalStock to BNF/SPC references. Not yet modelled.";
       }

       part cswCatalogueAsUiContract : DomainInstantiation {
           attribute :>> domain = "CSW";
           attribute :>> maturity = PatternMaturity::validated;
           attribute :>> implementationRef = "Counter page — dynamic form driven by catalogue attributes (availableSizes, dietaryFlags, provisionType).";
           attribute :>> sessionRef = "Session 24 (CSW Phase 5)";
           attribute :>> notes = "Category-conditional form fields. Domain model hierarchy drives form structure.";
       }

       part gslCatalogueAsUiContract : DomainInstantiation {
           attribute :>> domain = "GSL";
           attribute :>> maturity = PatternMaturity::discussion;
           attribute :>> implementationRef = "";
           attribute :>> sessionRef = "";
           attribute :>> notes = "Clinical analogue: Patient portal order screen driven by formulary attributes (eligible medications, dosage options, monitoring requirements).";
       }
   ```

5. **Close the package.** Ensure the closing brace is correct.

6. **Verify in Syside.** Zero errors, zero warnings on the new file. Check that existing files are unaffected.

7. **Update the root assembly file** (`gendersense.sysml`) if it imports all packages — add `private import PatternCatalogue::*;` (or `Foundation::PatternCatalogue::*;` if nesting worked).

**Commit:** `"Foundation: PatternCatalogue package — concept graph definitions and core patterns (Session 30, Stage 2)"`

---

### Stage 3: Obsidian Vault Setup and MCP Bridge Attempt

**Goal:** Create the Obsidian vault structure, attempt MCP bridge, and create 3–5 initial pattern notes.

**Time estimate:** 30–40 minutes (20 min MCP bridge time-box + 10–20 min vault setup)

**Work:**

1. **Create the vault directory structure:**

   ```
   ~/Developer/gsl-tech/gsl-vault/
   ├── patterns/
   ├── concepts/
   ├── discussions/
   ├── domains/
   ├── deferred/
   └── templates/
   ```

   The vault lives outside the `gsl-sysml-model` repo — it is a companion artefact, not part of the SysML project.

2. **Create template files:**

   **`templates/template-pattern.md`:**
   ```markdown
   ---
   sysml_element: PatternCatalogue::{{element_name}}
   meta_model: {{business|businessSystem|crossCutting}}
   kind: {{formalised|guidance}}
   maturity: {{discussion|designed|implemented|validated}}
   domains:
     - csw: {{maturity}}
     - gsl: {{maturity}}
   related_elements:
     - {{package::element}}
   source_session: {{N}}
   tags:
     - pattern
     - meta-model/{{type}}
     - domain/{{domain}}
     - maturity/{{level}}
   ---

   # {{Pattern Name}}

   ## Description

   {{One-paragraph description of the pattern.}}

   ## Cross-Domain Analogues

   | CSW | GSL | Addictions |
   |---|---|---|
   | {{csw_instance}} | {{gsl_instance}} | {{addictions_instance}} |

   ## Related Patterns

   - [[pattern-{{related}}]]

   ## Design Rationale

   {{Why this pattern exists, what problem it solves, what alternatives were considered.}}

   ## Source

   - Session {{N}}: {{brief description}}
   - Discussion paper: {{if applicable}}
   ```

   **`templates/template-concept.md`:**
   ```markdown
   ---
   sysml_element: {{Package::Element}}
   meta_model: {{business|businessSystem}}
   element_kind: {{part_def|enum_def|metadata_def|action_def}}
   defined_in_session: {{N}}
   domains:
     - csw: {{instantiated|not_yet}}
     - gsl: {{instantiated|not_yet}}
   tags:
     - concept
     - meta-model/{{type}}
   ---

   # {{Concept Name}}

   ## Purpose

   {{What this concept represents in the meta model.}}

   ## Domain Instantiations

   - **CSW:** {{CoffeeShop::SpecificType}}
   - **GSL:** {{not yet modelled / GenderSense::SpecificType}}

   ## Related Patterns

   - [[pattern-{{related}}]]
   ```

   **`templates/template-discussion.md`:**
   ```markdown
   ---
   status: {{open|resolved|deferred}}
   related_patterns:
     - [[pattern-{{related}}]]
   related_concepts:
     - [[concept-{{related}}]]
   source_session: {{N}}
   tags:
     - discussion
     - status/{{status}}
   ---

   # {{Discussion Topic}}

   ## Context

   {{What prompted this discussion.}}

   ## Key Points

   {{Summary of the discussion.}}

   ## Resolution

   {{How it was resolved, or why it's deferred.}}

   ## Related

   - [[pattern-{{related}}]]
   - Session {{N}} report
   ```

3. **Create domain index notes:**

   **`domains/domain-csw.md`:**
   ```markdown
   ---
   domain: CSW
   full_name: Coffee Shop World
   status: active
   sessions: 1–29
   tags:
     - domain
     - domain/csw
   ---

   # Coffee Shop World (CSW)

   Standing development practice and proof-of-concept demonstrator.
   Every new architectural capability gets a coffee shop equivalent
   before clinical implementation.

   ## Key Artefacts

   - SysML: `CoffeeShop` package (`model/coffeeshop.sysml` in exercises)
   - Business model: `CoffeeShopBusinessModel` package
   - Running app: SvelteKit + Temporal + EHRbase + PostgreSQL
   - 9 frontend pages, 19 API routes, 1 Temporal workflow

   ## Validated Patterns

   - [[pattern-four-layer-item-model]]
   - [[pattern-catalogue-as-ui-contract]]
   - [[pattern-kanban-as-process-dashboard]]
   - [[pattern-three-layer-persistence]]
   - ...
   ```

   **`domains/domain-gsl.md`** and **`domains/domain-addictions.md`** (placeholder) similarly.

4. **Create 3–5 initial pattern notes** to establish the template:

   - `patterns/pattern-four-layer-item-model.md`
   - `patterns/pattern-two-layer-action-flow.md`
   - `patterns/pattern-catalogue-as-ui-contract.md`
   - `patterns/pattern-persistence-policy.md`
   - `patterns/pattern-five-layer-self-knowledge.md`

   Each follows the template, with the frontmatter linking to the SysML `PatternCatalogue` element and tags for filtering.

5. **MCP bridge attempt (time-boxed: 20 minutes):**

   - Check if `obsidian-mcp-tools` community plugin exists and is compatible with current Obsidian version.
   - If available: install, configure, test read access from Claude's MCP session.
   - If not available or non-functional within 20 minutes: document as "deferred — manual vault access via uploads" and move on.

   **MCP bridge success criteria:** Claude can read at least one vault note via MCP during a session. If yes, the bridge is operational. If no, it's a convenience item for a future session.

**Commit:** `"Obsidian vault: initial structure, templates, 5 pattern notes (Session 30, Stage 3)"`

Shell command (vault is outside the sysml-model repo, so this is a separate git init or simply untracked):
```bash
# The vault is not part of the sysml-model git repo.
# If you want to version it separately:
cd ~/Developer/gsl-tech/gsl-vault
git init
git add -A
git commit -m "Obsidian vault: initial structure, templates, 5 pattern notes (Session 30)"
```

---

### Stage 4: Cross-Reference Convention and Documentation

**Goal:** Document the naming convention between SysML elements and Obsidian notes. Update the repo conventions guide.

**Time estimate:** 15–20 minutes

**Work:**

1. **Define the naming convention:**

   | SysML element | Obsidian note | Rule |
   |---|---|---|
   | `part fourLayerItemModel : Pattern` | `patterns/pattern-four-layer-item-model.md` | camelCase → kebab-case, prefixed with entity type |
   | `part cswFourLayerItemModel : DomainInstantiation` | (included in the pattern note's "Domain Instantiations" section) | Domain instantiations don't get separate notes |
   | `part def CatalogueEntry` (in BusinessModel) | `concepts/concept-catalogue-entry.md` | PascalCase → kebab-case, prefixed with `concept-` |
   | Deferred item (no SysML element yet) | `deferred/deferred-composite-orders.md` | kebab-case, prefixed with `deferred-` |
   | Discussion topic | `discussions/discussion-self-service-generations.md` | kebab-case, prefixed with `discussion-` |

   **Frontmatter `sysml_element` field:** Fully qualified SysML path (e.g. `PatternCatalogue::fourLayerItemModel`). Empty string if no SysML element exists yet (discussion topics, deferred items not yet formalised).

   **Tags:** Follow the taxonomy:
   - Entity type: `#pattern`, `#concept`, `#discussion`, `#deferred`
   - Meta model: `#meta-model/business`, `#meta-model/system`, `#meta-model/cross-cutting`
   - Domain: `#domain/csw`, `#domain/gsl`, `#domain/addictions`
   - Maturity: `#maturity/discussion`, `#maturity/designed`, `#maturity/implemented`, `#maturity/validated`

2. **Update `documentation/guides/gsl-guide-repo-conventions.md`** — add a new section documenting the PatternCatalogue–Obsidian cross-reference convention.

3. **Create a `gsl-vault/README.md`** in the Obsidian vault explaining the vault's purpose, its relationship to the SysML model, and the cross-reference convention.

**Commit (sysml-model repo):** Combined with Stage 2 if small, or separate: `"Documentation: PatternCatalogue–Obsidian cross-reference convention (Session 30, Stage 4)"`

---

### Session 30 checkpoint

At the end of Stage 4, Session 30 delivers:
- Syntax investigation findings (documented)
- `PatternCatalogue` SysML package with type definitions and 10–12 core patterns
- Obsidian vault with structure, templates, and 3–5 initial notes
- Cross-reference convention documented

**Git state after Session 30:**
```bash
cd ~/Developer/gsl-tech/gsl-sysml-model

# Stage 1 syntax test (if retained)
git add model/syntax-tests/test-ref-to-metadata-def.sysml*
git commit -m "Syntax test: ref to metadata def type (Session 30, Stage 1)"

# Stage 2 + 4 (main deliverable)
git add model/pattern-catalogue.sysml model/gendersense.sysml documentation/guides/gsl-guide-repo-conventions.md
git commit -m "Foundation: PatternCatalogue package — concept graph definitions and core patterns (Session 30)"
```

---

### Stage 5: Full Pattern Population

**Goal:** Instantiate all remaining patterns from the strategic snapshot, the work analysis deferred items, and the discussion papers.

**Time estimate:** 60 minutes

**Session:** 31

**Work:**

1. **Add remaining validated patterns** (those not in the core set from Stage 2). From the strategic snapshot §5, the full list of 22 patterns includes:

   **Business system meta model patterns still to add:**
   - Metadata-driven generation
   - XState in Temporal (pure state machine enforcement)
   - Split-view management layout
   - Category-conditional form fields
   - Cross-page data consistency
   - Audit-as-timeline data source
   - Process + domain + governance unified view
   - CDR source provenance badges
   - Auto-loading entity views
   - Infrastructure health as application-level concern
   - Multi-source metrics aggregation with graceful degradation
   - Two-layer model visualisation in the UI
   - Hand-crafted SVG for stable pathway diagrams

   Each follows the established `part x : Pattern { ... }` template from Stage 2.

2. **Add deferred/conceptual patterns:**
   - Self-assessment dashboard (KL Increment 3) — maturity: `designed` (landing zone built, implementation not started)
   - OptionEvaluator / "Help Me Choose" — maturity: `designed`
   - Data release model (patient-facing) — maturity: `discussion`
   - Notification triggers on state transitions — maturity: `discussion`

3. **Add domain instantiations** for all patterns where CSW or GSL has an implementation or a known analogue. Each validated pattern with a CSW implementation gets a `DomainInstantiation` usage. GSL patterns that are discussed but not implemented get `discussion` maturity.

4. **Verify in Syside.** The file will be substantial (potentially 300–500 lines) — ensure clean parse.

**Commit:** `"PatternCatalogue: full pattern population — 22+ patterns, domain instantiations (Session 31, Stage 5)"`

---

### Stage 6: Obsidian Full Population

**Goal:** Create Obsidian notes for all catalogued patterns, key meta model concepts, and major deferred items.

**Time estimate:** 45 minutes

**Session:** 31

**Work:**

1. **Pattern notes** — one per pattern in the SysML catalogue. Follow the template. Each note has frontmatter linking to the SysML element and backlinks to related patterns and concepts.

   Target: ~25 pattern notes covering all validated + designed + discussion patterns.

2. **Concept notes** — one per key meta model element. Priority concepts:
   - `concept-catalogue-entry.md` (business meta model)
   - `concept-inventory-record.md` (business meta model)
   - `concept-persistence-policy.md` (system meta model)
   - `concept-agency-classification.md` (system meta model)
   - `concept-clinical-pathway.md` (system meta model)
   - `concept-self-knowledge-architecture.md` (system meta model)
   - `concept-scenario-definition.md` (business meta model)

   Target: 7–10 concept notes.

3. **Discussion / deferred notes:**
   - `deferred/deferred-composite-orders.md`
   - `deferred/deferred-system-meta-model-extraction.md`
   - `discussions/discussion-self-service-generations.md`
   - `discussions/discussion-two-phase-generation.md`

   Target: 4–6 discussion/deferred notes.

4. **Verify backlinks.** Open the vault in Obsidian, check that backlinks and graph view show the expected connections. The graph should show clusters around the two meta models and the three domains.

**Commit (vault repo):**
```bash
cd ~/Developer/gsl-tech/gsl-vault
git add -A
git commit -m "Obsidian vault: full population — patterns, concepts, discussions (Session 31)"
```

---

### Stage 7: Integration Test

**Goal:** Navigate real cross-domain questions end-to-end using the concept graph.

**Time estimate:** 30 minutes

**Session:** 31

**Work:**

1. **Test query 1: "What CSW patterns have no GSL instantiation?"**

   Navigate in SysML: find all `DomainInstantiation` usages where `domain = "CSW"` and `maturity = validated`, then check for corresponding `domain = "GSL"` instantiations of the same pattern. The answer should surface the patterns that represent architectural debt between the demonstrator and the clinical domain.

   Navigate in Obsidian: use the graph view filtered by `#domain/csw` and `#maturity/validated`, then check which pattern notes also have `#domain/gsl`.

   **Expected result:** A list of ~10 patterns validated in CSW with no GSL equivalent (e.g. catalogue-as-UI-contract, kanban-as-process-dashboard, etc.). This is the roadmap for GSL clinical development.

2. **Test query 2: "What is the full context for the composite order deferred item?"**

   Navigate from `deferred/deferred-composite-orders.md` → follow backlinks to `pattern-composite-order-orchestration.md` → follow related patterns to `pattern-two-layer-action-flow.md` → check domain instantiations for CSW and GSL → follow to `discussion-self-service-generations.md` for the patient self-service context.

   **Expected result:** The full thread from deferred item → architectural pattern → cross-domain analogues → strategic context is navigable in 3–4 hops.

3. **Test query 3 (if MCP bridge works): "Read the vault note for catalogue-as-UI-contract and the SysML definition for CatalogueEntry in a single session."**

   This tests Claude's ability to cross-reference Obsidian discursive content with SysML formal definitions during a session.

4. **Document findings.** Note any gaps, missing links, or navigation friction. These become refinement tasks for future sessions.

**No commit** — this is a verification step. Any fixes are folded into Stage 8.

---

### Stage 8: Documentation and Workstream Completion

**Goal:** Final documentation pass. Workstream complete.

**Time estimate:** 20 minutes

**Session:** 31

**Work:**

1. **Design rationale document:** `gsl-architecture-concept-graph-design-rationale-2026-03-XX.md` — captures the key decisions, what worked, what didn't, and the integration test results. Brief (1–2 pages).

2. **Update `gsl-guide-repo-conventions.md`** with any additional conventions discovered during Stages 5–7.

3. **Update `gsl-plan-next-steps-and-deferred-items.md`:**
   - Move "Pattern Catalogue and Cross-Domain Concept Registry" from candidate workstreams to completed.
   - Add any new deferred items discovered during the concept graph build.
   - Note the MCP bridge status.

4. **Syntax reference update** — if Stage 1 produced new findings (nested package across files, ref to metadata def type), add them to the syntax reference as a new version.

5. **Session report** — covers both Sessions 30 and 31 (or separate reports per session).

**Commit:**
```bash
cd ~/Developer/gsl-tech/gsl-sysml-model
git add -A
git commit -m "Documentation: concept graph design rationale, conventions, completion (Session 31, Stage 8)"
```

---

## Summary of Deliverables

### Session 30 (Stages 1–4)

| Stage | Deliverable | Effort |
|---|---|---|
| 1 | Syntax investigation: package nesting + ref to metadata def | 30 min |
| 2 | `pattern-catalogue.sysml` with type system + 10–12 core patterns | 45–60 min |
| 3 | Obsidian vault structure, templates, 3–5 notes, MCP bridge attempt | 30–40 min |
| 4 | Cross-reference convention documentation | 15–20 min |
| **Total** | | **~2–2.5 hours** |

### Session 31 (Stages 5–8)

| Stage | Deliverable | Effort |
|---|---|---|
| 5 | Full pattern population (22+ patterns, domain instantiations) | 60 min |
| 6 | Obsidian full population (~40 notes) | 45 min |
| 7 | Integration test (3 cross-domain queries) | 30 min |
| 8 | Documentation, conventions, workstream completion | 20 min |
| **Total** | | **~2.5 hours** |

### Git Commits (sysml-model repo)

| # | Message | Stages |
|---|---|---|
| 1 | `Syntax test: ref to metadata def type (Session 30, Stage 1)` | 1 |
| 2 | `Foundation: PatternCatalogue package — concept graph definitions and core patterns (Session 30)` | 2, 4 |
| 3 | `PatternCatalogue: full pattern population — 22+ patterns, domain instantiations (Session 31, Stage 5)` | 5 |
| 4 | `Documentation: concept graph design rationale, conventions, completion (Session 31, Stage 8)` | 8 |

### Git Commits (vault repo — separate)

| # | Message | Stages |
|---|---|---|
| 1 | `Obsidian vault: initial structure, templates, 5 pattern notes (Session 30)` | 3 |
| 2 | `Obsidian vault: full population — patterns, concepts, discussions (Session 31)` | 6 |

---

## Design Decisions Summary

| Decision | Resolution | Source |
|---|---|---|
| Package structure | Top-level `PatternCatalogue` (expected) or nested in Foundation (if Syside allows) | Stage 1 test |
| Cross-element references | String (pragmatic, option b) unless Stage 1 confirms typed refs work | §3.1 of workstream plan |
| Maturity tracking | Per-pattern + per-domain-instantiation (separate `PatternMaturity` values) | §3.2 of workstream plan |
| Obsidian approach | Native features only — no Dataview, no complex plugins | Session 26 decision |
| MCP bridge | Time-boxed attempt; not a prerequisite | §3.5 of workstream plan |
| Vault location | Outside sysml-model repo (`~/Developer/gsl-tech/gsl-vault/`) | Separation of concerns |

---

## Syntax Investigations

| Pattern | Stage | Status | Fallback |
|---|---|---|---|
| Nested package declaration across files | 1 | To test | Top-level sibling package |
| `ref` to `metadata def` type | 1 | To test | String reference |
| `ref` to `enum def` type | 1 | To test | String reference |

---

## What Comes After

The concept graph workstream produces the infrastructure. Future enrichment happens organically:

- **New patterns** are added to the SysML catalogue and get an Obsidian note as they are identified.
- **New domain instantiations** are added when patterns are implemented in GSL clinical or other domains.
- **Deferred items** migrate from `discussion` to `designed` to `validated` as work progresses.
- **The MCP bridge** (if deferred) can be revisited in any future session without workstream overhead.
- **Generator integration** — a future generator could produce Obsidian notes from the SysML catalogue, eliminating manual synchronisation. This is a natural extension of the "model generates everything" principle but is not in scope for this workstream.

---

*Concept Graph workstream implementation plan prepared 15 March 2026. Session 30.*
