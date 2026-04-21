---
tags:
  - plan
  - architecture
  - ontology
date: 2026-04-01
status: current
session: 100
---
# Knowledge Graph Implementation Plan — Stage KG-1
> `= this.file.path`

**Date:** 1 April 2026 (Session 100)
**Purpose:** Concrete implementation plan for the first stage of Ontara's knowledge graph pipeline. Takes the architectural design (Session 97) and BFO mapping (Sessions 98–99) from design to running code.
**Depends on:** [[ontara-discussion-knowledge-graph-architecture-2026-04-01|Knowledge Graph Architecture]] ([[session-97-report-2026-04-01|Session 97]]), [[ontara-discussion-bfo-type-mapping-2026-04-01|@BfoType Mapping]] ([[session-98-report-2026-04-01|Session 98]]), [[session-99-report-2026-04-01|Session 99]] `@BfoType` annotations
**Status:** Plan — to be agreed and then executed across subsequent sessions.

---

## Contents

- [§1. Stage Designation](#1-stage-designation)
- [§2. Scope and Success Criteria](#2-scope-and-success-criteria)
- [§3. The Plan — Six Steps](#3-the-plan--six-steps)
- [§4. Validation Subset](#4-validation-subset)
- [§5. New Repo Structure](#5-new-repo-structure)
- [§6. Dependencies and Tooling](#6-dependencies-and-tooling)
- [§7. Risk Notes](#7-risk-notes)
- [§8. Register Connections](#8-register-connections)
- [§9. Estimated Session Allocation](#9-estimated-session-allocation)

---

## 1. Stage Designation

This work warrants a new **Stage 5** designation: **Knowledge Graph Implementation**.

Rationale: the knowledge graph is a new architectural capability, not an extension of an existing workstream. It introduces a second formalism (OWL 2 DL), a new persistence layer (GraphDB), a new pipeline (five stages), and a new representational stratum (the [[ontara-ref-master-register|three-stratum graph (B28)]]). It is comparable in scope and architectural significance to Stage 2 (console build) and Stage 3 ([[concept-comprehension-layer|comprehension architecture]]). It supersedes the remaining [[ontara-stage-4-high-level-plan-2026-03-21|Stage 4]] phases in priority — Stage 4 Phases 2–5 remain valid but are now secondary to KG implementation.

**Stage 5 — Knowledge Graph Implementation**

| Phase | Focus | Character |
|---|---|---|
| **Phase 1** | Foundation — GraphDB + OWL ontology + pipeline Stages 1–3 | This plan |
| Phase 2 | Reasoning and validation — pipeline Stage 4 | HermiT/Pellet integration, SPARQL validation queries |
| Phase 3 | Round-trip — pipeline Stage 5 + correspondence graph | Diff engine, OWL→SysML patch generation |
| Phase 4 | Console integration | KG data surfaced in the Ontara Console |
| Phase 5 | [[domain-ears|Ears]] demonstrator | OGMS adoption, clinical validation in the KG |

This plan covers **Phase 1** only.

---

## 2. Scope and Success Criteria

### What Phase 1 delivers

1. GraphDB Free running locally with an Ontara repository
2. BFO 2020, CCO, and IAO loaded as imported ontologies
3. An authored Ontara platform ontology (`ontara-bmm.ttl`) declaring all 34 BMM `part def`s as OWL classes with BFO parent mappings
4. A Python pipeline (Steps 1–3) that reads `.sysml` files, classifies elements via a mapping IR, and outputs OWL/Turtle
5. The three named graphs (metamodel, domain, correspondence) populated for the validation subset
6. SPARQL queries demonstrating that the knowledge graph can answer questions about the model

### Success criteria

- `ontara-bmm.ttl` loads in Protégé without errors
- GraphDB accepts the ontology, runs OWL-Horst inference, and the inferred class hierarchy is correct
- The pipeline produces identical Turtle output when run twice on the same input (deterministic)
- A SPARQL query can answer: "which BMM elements are subclasses of BFO:Role?" and return the correct set
- A SPARQL query over the correspondence graph can answer: "which OWL class does the SysML `part def CustomerSegment` map to?"
- Round-trip: the correspondence graph records for the validation subset are complete and consistent

---

## 3. The Plan — Six Steps

### Step 1: GraphDB Setup and Ontology Stack Loading [Code]

**What:** Install GraphDB Free locally (macOS). Create the `ontara-dev` repository. Download and load BFO 2020 OWL, CCO, and IAO.

**Detailed tasks:**

1. Download GraphDB Free 10.x from Ontotext (free registration required). Install via `.dmg` or Homebrew if available.
2. Start GraphDB, create repository `ontara-dev` with OWL-Horst (Optimized) ruleset.
3. Configure three named graphs:
   - `https://ontara.dev/graph/metamodel` — SysML structural traceability
   - `https://ontara.dev/graph/domain` — BFO-grounded domain semantics
   - `https://ontara.dev/graph/correspondence` — mapping records
4. Download ontology files:
   - BFO 2020: `https://raw.githubusercontent.com/BFO-ontology/BFO-2020/master/bfo-core.owl` (OWL/XML) or the Turtle distribution
   - CCO: from the Common Core Ontologies GitHub repository (`CommonCoreOntologies/cco-merged/MergedAllCoreOntology.ttl` or individual modules)
   - IAO: `https://raw.githubusercontent.com/information-artifact-ontology/IAO/master/src/ontology/iao.owl`
5. Import BFO → CCO → IAO into the `ontara-dev` repository's domain graph (import order matters — BFO first, then CCO which imports BFO, then IAO).
6. Verify: SPARQL query `SELECT ?class WHERE { ?class rdfs:subClassOf <http://purl.obolibrary.org/obo/BFO_0000002> }` should return BFO:Continuant subclasses plus CCO/IAO extensions.

**Deliverable:** Running GraphDB instance with ontology stack loaded and verified.

**Who:** Ella (GraphDB installation requires browser download and registration). Claude Code can assist with SPARQL verification queries and repo configuration scripts.

**Estimated effort:** 1 session (possibly partial).

**Notes:**
- GraphDB Free runs as a local Java application on port 7200 by default.
- No Docker required for development — native macOS installation is simpler.
- CCO is modular (11 sub-ontologies). For Phase 1, load the merged file (`MergedAllCoreOntology`) to avoid import resolution complexity. Individual modules can be adopted later.
- OGMS is deferred to Phase 5 (Ears demonstrator). Not needed for the BMM-only validation in Phase 1.

---

### Step 2: Author the Ontara BMM Ontology [Chat + Code]

**What:** Create the first Ontara OWL file — `ontara-bmm.ttl` — declaring all 34 BMM `part def`s as OWL classes, each positioned under its BFO parent class as declared by its `@BfoType` annotation ([[ontara-discussion-bfo-type-mapping-2026-04-01|Session 98 mapping table]]).

**Detailed tasks:**

1. **[Chat] Design the ontology structure.** Review the complete `@BfoType` mapping table from the [[ontara-discussion-bfo-type-mapping-2026-04-01|Session 98 discussion paper]]. Decide:
   - Class naming convention: `ontara:CustomerSegment` or `ontara-bmm:CustomerSegment`?
   - How to handle the CCO mid-level mappings (subclass chains: BMM class → CCO class → BFO class, or BMM class → BFO class with CCO annotation?)
   - Whether to include `rdfs:label`, `rdfs:comment`, and `skos:definition` from the existing `@UserFacing` and `@PurposiveDescription` metadata.

2. **[Code] Generate `ontara-bmm.ttl`.** This can be hand-authored in Turtle or generated from a Python script that reads `@BfoType` annotations from the SysML files. Recommended approach: **generate it** — this establishes the pipeline pattern and ensures consistency.

   The generator reads `business-model.sysml`, `business-scenarios.sysml`, `business-strategy.sysml`, and `model/governance-mapping.sysml` (if separate), extracts all `@BfoType` annotations, and produces Turtle declarations:

   ```turtle
   @prefix ontara-bmm: <https://ontara.dev/ontology/bmm/> .
   @prefix bfo: <http://purl.obolibrary.org/obo/> .
   @prefix cco: <http://www.ontologyrepository.com/CommonCoreOntologies/> .
   @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
   @prefix owl: <http://www.w3.org/2002/07/owl#> .

   ontara-bmm:CustomerSegment a owl:Class ;
       rdfs:subClassOf bfo:BFO_0000031 ;  # GenericallyDependentContinuant
       rdfs:label "Customer Segment" ;
       rdfs:comment "A defined group of customers with shared needs." .
   ```

3. **[Code] Validate in Protégé.** Open `ontara-bmm.ttl` in Protégé, verify class hierarchy, check for import resolution issues.

4. **[Code] Load into GraphDB.** Import `ontara-bmm.ttl` into the domain named graph. Run OWL-Horst inference. Verify the inferred hierarchy.

**Deliverable:** `ontara-bmm.ttl` in the repo, loaded into GraphDB, with 34 OWL classes correctly positioned under BFO.

**Estimated effort:** 1–2 sessions. Design decisions (task 1) are the bottleneck — the generation and loading are mechanical.

**Design decisions to resolve at this step:**
- **IRI minting convention.** The [[ontara-discussion-knowledge-graph-architecture-2026-04-01|KG architecture paper]] (§8) specifies `https://ontara.dev/ontology/bmm/` as the namespace. Each BMM element becomes `ontara-bmm:{ElementName}`. Confirm this.
- **Mid-level positioning.** Where a `@BfoType` declares both a `bfoClass` and a `midLevelClass`, should the OWL class be declared as `rdfs:subClassOf` of the mid-level class (which itself is a subclass of the BFO class), or should both be declared? Recommended: **subclass of the mid-level class only** — the BFO parent is inferred through the imported ontology's existing class hierarchy.
- **Annotation properties.** Include `rdfs:label` (from `@UserFacing.friendlyName`), `rdfs:comment` (from `@UserFacing.shortDescription`), and `skos:definition` (from `@PurposiveDescription.description`)? Recommended: **yes, include all three** — this exercises the shared-constrained authority zone from the start.

---

### Step 3: Extend the SysML Parser — Pipeline Stage 1 [Code]

**What:** Extend `gen_model_introspection.py` to extract `@BfoType` annotations into the JSON output, and create a new generator `gen_owl_pipeline.py` that produces the mapping intermediate representation (IR).

**Detailed tasks:**

1. **[Code] Add `@BfoType` extraction to `gen_model_introspection.py`.** The annotation parser already captures all annotations generically in `elem.annotations`, but `@BfoType` needs a dedicated property (like `catalogue_tag`, `user_facing`, etc.) to make it first-class in the JSON. Add:
   - `self.bfo_type = {}` to `SysmlElement.__init__`
   - `elif a_name == "BfoType": elem.bfo_type = dict(a_attrs)` to `attach_annotations`
   - `if self.bfo_type: d["bfoType"] = self.bfo_type` to `to_dict`
   - `@BfoType` to the generator's docstring header
   - Update summary statistics to include BFO type coverage count

2. **[Code] Create `gen_owl_pipeline.py` — a new generator.** This is the heart of the pipeline. It reads `.sysml` files (reusing the parser from `gen_model_introspection.py` or importing it as a module) and produces:
   - A **mapping IR** (JSON or Python dict) classifying each element as: `DomainClass`, `DomainProperty`, `DomainIndividual`, `MetadataAnnotation`, `StructuralOnly`, or `Excluded`
   - The classification rules are declarative and version-controlled (a mapping specification, not embedded logic)

**Architecture decision: shared parser or independent?** The existing `gen_model_introspection.py` is a monolithic script (~800 lines). For Phase 1, the recommended approach is:

- **Extract the SysML parser into a shared module** (`scripts/sysml_parser.py`) that both `gen_model_introspection.py` and `gen_owl_pipeline.py` import. This avoids code duplication and ensures both generators parse identically.
- This is a refactoring task but a modest one — the parser is already well-structured as functions and a data class. The extraction is mechanical.

**Deliverable:** Updated `gen_model_introspection.py` with `@BfoType` support. New `gen_owl_pipeline.py` with Stage 1 (parse) capability. Shared parser module.

**Estimated effort:** 1–2 sessions. The parser refactoring is the largest task.

---

### Step 4: Mapping IR and OWL Generation — Pipeline Stages 2–3 [Code]

**What:** Implement the classification rules (Stage 2) and OWL/Turtle output (Stage 3) in `gen_owl_pipeline.py`.

**Detailed tasks:**

1. **[Code] Implement the mapping IR (Stage 2).** For each parsed SysML element, apply classification rules:

   | SysML construct | Has `@BfoType`? | Classification |
   |---|---|---|
   | `part def` in BMM package | Yes | `DomainClass` |
   | `part def` in BMM package | No | `StructuralOnly` (flag for review) |
   | `part` usage (demonstrator instance) | Parent def is `DomainClass` | `DomainIndividual` |
   | `enum def` in BMM package | — | `DomainEnumeration` |
   | Typed attribute on `DomainClass` | — | `DomainProperty` |
   | `metadata def` | — | `MetadataAnnotation` (metamodel graph, not domain graph) |
   | Anything in SMM/Foundation | — | `StructuralOnly` (Phase 1 excludes SMM) |

   The classification rules are stored as a declarative specification (YAML or Python dict) in the repo — not embedded in procedural code. This makes the mapping reviewable and version-controllable.

2. **[Code] Implement OWL/Turtle output (Stage 3).** Using `rdflib` (Python library — will need `pip install rdflib`). For each `DomainClass` element:
   - Mint IRI: `https://ontara.dev/ontology/bmm/{ElementName}`
   - Declare `owl:Class`
   - Add `rdfs:subClassOf` pointing to the `@BfoType.midLevelClass` IRI (or `@BfoType.bfoClass` if no mid-level mapping)
   - Add `rdfs:label` from `@UserFacing.friendlyName`
   - Add `rdfs:comment` from `@UserFacing.shortDescription`
   - Add `skos:definition` from `@PurposiveDescription.description`

   For each `DomainIndividual`:
   - Mint IRI: `https://ontara.dev/data/{domain}/{InstanceName}`
   - Declare `rdf:type` pointing to the corresponding `DomainClass` IRI

   For each `DomainProperty`:
   - Mint IRI: `https://ontara.dev/ontology/bmm/{ClassName}/{propertyName}`
   - Declare `owl:DatatypeProperty` or `owl:ObjectProperty` depending on attribute type
   - Add `rdfs:domain` and `rdfs:range`

3. **[Code] Generate correspondence graph records.** For each mapped element, produce a triple in the correspondence graph:
   - SysML element stable ID (file path + element name + line number)
   - Source hash (for change detection)
   - OWL entity IRI
   - Mapping category
   - Authority zone (`SysML-authoritative` for structure, `shared-constrained` for labels)
   - Generation timestamp

4. **[Code] Output.** The generator produces:
   - `generated/ontology/ontara-bmm.ttl` — the domain ontology
   - `generated/ontology/ontara-metamodel.ttl` — the metamodel graph
   - `generated/ontology/ontara-correspondence.ttl` — the correspondence records
   - `generated/ontology/mapping-ir.json` — the intermediate representation (for debugging and review)

**Deliverable:** Complete pipeline Stages 1–3. Running `python scripts/gen_owl_pipeline.py --save` produces Turtle files ready for GraphDB import.

**Estimated effort:** 2–3 sessions. This is the most substantial implementation work.

---

### Step 5: Load, Reason, and Validate [Code + Chat]

**What:** Load the generated Turtle into GraphDB, run inference, and validate with SPARQL queries.

**Detailed tasks:**

1. **[Code] Write a GraphDB loading script.** Python script using `SPARQLWrapper` or GraphDB's REST API to:
   - Clear and reload each named graph
   - Trigger inference
   - Run a validation query suite

2. **[Chat] Design validation SPARQL queries.** A test suite that confirms correctness:

   **Structural queries:**
   - "List all BMM classes and their BFO parent" → should return 34 rows
   - "Which BMM classes are subclasses of BFO:Role?" → should match the mapping table
   - "Which BMM classes are subclasses of BFO:Process?" → should match
   - "Which BMM classes have no mid-level ontology parent?" → should be empty (or flagged)

   **Instance queries:**
   - "List all Cafe domain individuals and their types" → should match demonstrator instances
   - "Which BMM classes have instances in more than one domain?" → cross-domain coverage

   **Correspondence queries:**
   - "Which OWL class maps to SysML part def `CustomerSegment`?" → `ontara-bmm:CustomerSegment`
   - "Which SysML elements have no OWL mapping?" → should be only SMM/structural elements
   - "When was the last sync for each mapping?" → timestamps present

   **Inference queries:**
   - "Which BMM classes are BFO:Continuant (including inferred)?" → should include all via mid-level inheritance
   - "Which BMM classes are BFO:Occurrent (including inferred)?" → process-typed elements

3. **[Code] Implement the validation suite as a Python script** (`scripts/validate_kg.py`) that runs the queries and reports pass/fail.

**Deliverable:** Validation suite. All queries passing. Generated Turtle in the repo.

**Estimated effort:** 1 session.

---

### Step 6: Documentation and Governance [Chat]

**What:** Update project documentation to reflect the new KG capability.

**Detailed tasks:**

1. **[Chat] Update the master register.** New entries or updates for: Stage 5 designation, pipeline stages, GraphDB selection (confirming D4), IRI scheme in use.
2. **[Chat] Update the strategic snapshot** if this constitutes a stage/phase boundary (it does — Stage 5 Phase 1).
3. **[Chat] Write a brief implementation notes document** for the vault, recording practical lessons learned (GraphDB configuration, CCO import issues, `rdflib` patterns, etc.).
4. **[Chat] Update `CLAUDE.md` and skills** in the repo — new scripts, new generated output paths, new conventions.

**Deliverable:** Governance documents current. Repo documentation updated.

**Estimated effort:** Partial session (incorporated into session close sequences).

---

## 4. Validation Subset

Phase 1 validates the full pipeline with **all 34 BMM elements** (not a subset). Rationale:

- All 34 already have `@BfoType` annotations (Session 99). There is no additional modelling work.
- The pipeline should handle the full set from the start — it's only 34 classes.
- Subsetting would create a false sense of simplicity and defer integration issues.

For **demonstrator instances** (ABox), validate with **[[domain-cafe|Cafe]] only** initially (it has the most complete coverage — full BMM + [[concept-stakeholder-model|StakeholderModel]]), then extend to [[domain-paws|Paws]] and [[domain-suds|Suds]].

---

## 5. New Repo Structure

```
scripts/
    sysml_parser.py              ← NEW: shared parser module (extracted from gen_model_introspection.py)
    gen_model_introspection.py   ← MODIFIED: imports sysml_parser, adds @BfoType
    gen_owl_pipeline.py          ← NEW: pipeline Stages 1–3
    validate_kg.py               ← NEW: SPARQL validation suite
    load_graphdb.py              ← NEW: GraphDB loading/reload script

generated/
    ontara/
        model-introspection.json ← existing
    ontology/                    ← NEW directory
        ontara-bmm.ttl           ← generated domain ontology
        ontara-metamodel.ttl     ← generated metamodel graph
        ontara-correspondence.ttl ← generated correspondence records
        mapping-ir.json          ← generated mapping IR (debug/review)

ontology/                        ← NEW top-level directory
    imports/                     ← downloaded external ontologies (BFO, CCO, IAO)
    config/                      ← mapping specification, GraphDB config
        mapping-rules.yaml       ← declarative classification rules
        graphdb-config.ttl       ← repository configuration
```

The `ontology/imports/` directory contains downloaded copies of external ontologies — version-pinned and committed to the repo. This ensures reproducibility and avoids network dependency during generation.

---

## 6. Dependencies and Tooling

| Dependency | Purpose | Installation |
|---|---|---|
| **GraphDB Free 10.x** | Triple store | Download from Ontotext, manual install |
| **Protégé 5.6+** | Ontology authoring and debugging | Download from Stanford, manual install |
| **rdflib** (Python) | OWL/Turtle generation | `pip install rdflib` |
| **SPARQLWrapper** (Python) | GraphDB REST API / SPARQL queries | `pip install SPARQLWrapper` |
| **PyYAML** (Python) | Mapping specification parsing | `pip install PyYAML` (if not already present) |

All Python dependencies are standard, well-maintained packages. No exotic or experimental libraries.

---

## 7. Risk Notes

| # | Risk | Mitigation |
|---|---|---|
| KG-R1 | **CCO import complexity.** CCO is modular with inter-module imports. Loading the merged file may introduce unexpected axioms. | Start with merged file. If issues arise, load individual modules selectively. |
| KG-R2 | **BFO IRI resolution.** BFO 2020 uses OBO PURLs (`http://purl.obolibrary.org/obo/BFO_0000xxx`), which differ from human-readable labels. The `@BfoType.bfoClass` attribute uses labels (e.g. "Role"), not IRIs. | Build a label→IRI lookup table in the pipeline (trivial — BFO has ~35 classes). |
| KG-R3 | **CCO mid-level IRI resolution.** `@BfoType.midLevelClass` uses `prefix:ClassName` format (e.g. "CCO:ActOfServiceProvision"). Actual CCO IRIs may differ. | Research exact CCO IRI patterns before Step 2. Build a verified lookup table. |
| KG-R4 | **Parser refactoring risk.** Extracting the shared parser module could introduce regressions in `gen_model_introspection.py`. | Run `gen_model_introspection.py --save` before and after refactoring. Diff the output — must be byte-identical. |
| KG-R5 | **GraphDB Java dependency.** GraphDB requires Java 11+. May conflict with other Java installations on macOS. | Check `java -version` before installation. Use SDKMAN if multiple versions needed. |

---

## 8. Register Connections

### Tier 1 principles exercised

| Principle | How exercised |
|---|---|
| [[principle-separation-representation-execution|A1]] | [[ontara-ref-master-register|Authority zones (B29)]]/[[ontara-workflow-emergent-ideas-log|E020]] implemented at the formalism boundary. Changes originate in SysML and propagate to KG. |
| [[principle-self-describing-system|A2]]/[[principle-intrinsic-self-knowledge|A10]] | [[concept-knowledge-graph|Knowledge graph]] extends self-description to ontological semantics. `rdfs:label` and `skos:definition` are intrinsic. |
| [[principle-model-generates-everything|A3]] | Refined: the combined SysML + OWL representation generates everything. Pipeline produces OWL from SysML. |
| [[principle-two-meta-model-distinction|A4]] | Domain graph reflects the BMM/SMM distinction — Phase 1 maps BMM only. |
| [[principle-discipline-as-load-bearing-structure|A9]] | Pipeline is deterministic, repeatable, version-controlled. Validation suite enforces correctness. |
| [[principle-unity-principle|A11]] | Domain graph is the single semantic authority for ontological content. |
| [[concept-co-evolution|J2]] | KG pipeline co-evolves with the SysML model. New model content → regenerate → reload. |
| [[concept-non-constraining|J3]] | SPARQL abstraction enables store switching. rdflib enables format switching. OML remains adoptable. |

### Tier 2 concepts directly exercised

- [[ontara-ref-master-register|B18]] (BFO mandatory) — BFO loaded and used as upper ontology
- [[concept-knowledge-graph|B22]] (KG as canonical store) — first concrete step toward the directional commitment
- [[ontara-ref-master-register|B23]] (OWL 2 DL mandatory) — OWL classes authored and reasoned over
- [[ontara-ref-master-register|B24]] (mapping ontology) → correspondence graph populated
- [[ontara-ref-master-register|B28]] (three-stratum graph) — three named graphs implemented
- [[ontara-ref-master-register|B29]] (authority zones) — classification rules encode authority zone policy

---

## 9. Estimated Session Allocation

| Step | Sessions | Mode | Notes |
|---|---|---|---|
| Step 1: GraphDB setup | ~1 | [Code] + Ella manual | Installation is manual; SPARQL verification scripted |
| Step 2: Ontara BMM ontology | 1–2 | [Chat] + [Code] | Design decisions first, then generation |
| Step 3: Parser extension | 1–2 | [Code] | Shared module extraction is the main task |
| Step 4: Mapping IR + OWL generation | 2–3 | [Code] | The substantial implementation work |
| Step 5: Load, reason, validate | ~1 | [Code] + [Chat] | Validation query design is [Chat] |
| Step 6: Documentation | Partial | [Chat] | Incorporated into session closes |
| **Total** | **~6–9 sessions** | | Sessions 101–109 approximately |

This is a realistic estimate. The work is substantial but well-bounded — the architecture is designed, the BFO mapping exists, and the SysML parser is proven. The main unknowns are CCO/IAO import mechanics and the parser refactoring scope.

---

## Related Documents

- [[ontara-discussion-knowledge-graph-architecture-2026-04-01|Knowledge Graph Architecture]] ([[session-97-report-2026-04-01|Session 97]]) — the architectural design this plan implements
- [[ontara-discussion-bfo-type-mapping-2026-04-01|@BfoType Mapping]] ([[session-98-report-2026-04-01|Session 98]]) — the BFO mapping table
- [[ontara-ref-strategic-snapshot|Strategic Snapshot]] — current project state
- [[ontara-ref-master-register|Master Concept Register]] — concept register
- [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]] — E019 (three-stratum graph), E020 (authority zones)
- [[ontara-discussion-dual-stack-architecture-2026-03-26|Dual-Stack Architecture]] ([[session-73-report|Session 73/74]]) — the architectural context

---

*Implementation plan written 1 April 2026 (Session 100). Takes the knowledge graph architecture from design to implementation. The first concrete step in Ontara's transition to a dual-formalism platform.*
