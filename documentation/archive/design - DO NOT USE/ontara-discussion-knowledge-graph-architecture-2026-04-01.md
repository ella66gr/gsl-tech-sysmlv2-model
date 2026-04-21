---
tags:
  - discussion
  - architecture
  - ontology
date: 2026-04-01
status: working
session: 97
---
# Discussion Paper: Knowledge Graph Architecture and Ontological Grounding Implementation
> `= this.file.path`

*Ontara Platform — Discussion Paper*
**Date:** 1 April 2026 (Session 97)
**Purpose:** Captures the architectural decisions and design for implementing BFO, domain ontologies, and the knowledge graph — the top layers of the dual-stack architecture. This is Ontara's transition from "BFO is mandatory" (decided Session 73) to a concrete implementation architecture.
**Status:** Working document — architectural design. Decisions identified; binding status per discussion paper pipeline convention.
**Depends on:** [[ontara-discussion-dual-stack-architecture-2026-03-26|Dual-Stack Architecture]] (Session 73/74), [[ontara-discussion-ontological-grounding-2026-03-22|Ontological Grounding for the Coordinate Framework]] (Session 59)

---

## Contents

- [[#1. Context and Motivation|§1. Context and Motivation]]
- [[#2. Five Architectural Questions|§2. Five Architectural Questions]]
- [[#3. Q1 — Bringing In BFO: OWL 2 DL Direct|§3. Q1 — Bringing In BFO: OWL 2 DL Direct]]
- [[#4. Q2 — Mid-Level Ontology Commitments|§4. Q2 — Mid-Level Ontology Commitments]]
- [[#5. Q3 — Triple Store Selection|§5. Q3 — Triple Store Selection]]
- [[#6. Q4 — The Mapping Discipline|§6. Q4 — The Mapping Discipline]]
- [[#7. Q5 — Relationship to the Existing SysML Model|§7. Q5 — Relationship to the Existing SysML Model]]
- [[#8. The IRI Scheme|§8. The IRI Scheme]]
- [[#9. Emergent Ideas|§9. Emergent Ideas]]
- [[#10. Decisions Summary|§10. Decisions Summary]]
- [[#11. Register Connections|§11. Register Connections]]
- [[#12. What Comes Next|§12. What Comes Next]]

---

## 1. Context and Motivation

Session 73 made three binding architectural decisions: BFO as mandatory upper ontology ([[ontara-ref-master-register|B18]]), OWL 2 DL as mandatory ontological formalism ([[ontara-ref-master-register|B23]]), and the [[concept-knowledge-graph|knowledge graph as canonical store (B22)]] as a directional commitment. Session 59's [[ontara-discussion-ontological-grounding-2026-03-22|ontological grounding paper]] provided the theoretical mapping between BFO categories and Ontara's BMM concepts. Two Perplexity research documents explored the ontology stack, domain coordinates, and SysML↔OWL mapping patterns.

Twenty-four sessions later, the top three rows of the [[concept-dual-stack-architecture|dual-stack architecture]] — BFO, domain ontologies, and the formalism boundary — remain "Referenced" or "Designed" status in the visual architecture map. No OWL artefacts exist. No triple store is chosen. No mapping discipline is defined.

This session addresses that gap: making the ontological grounding layers real. The knowledge graph representation will be the canonical source of the model's ontological semantics, maintaining 100% round-trip consistency with SysML v2 through an explicit, engineered mapping discipline.

---

## 2. Five Architectural Questions

The discussion was structured around five questions:

1. **What does "bringing in BFO" actually mean in practice?** — The authoring approach and tooling.
2. **Which mid-level ontologies do we commit to?** — Platform-level vs sector-level vs deferred.
3. **Where does it live?** — Triple store selection.
4. **How do OWL and SysML talk to each other?** — The mapping discipline (B24).
5. **What's the relationship to the existing SysML model?** — What changes, what stays.

---

## 3. Q1 — Bringing In BFO: OWL 2 DL Direct

### 3.1 The decision

**Author ontologies directly in OWL 2 DL** using Turtle/Manchester syntax. Use Protégé for authoring, debugging, and visual class hierarchy inspection. Build a Python-owned bidirectional mapping pipeline for SysML v2 ↔ OWL synchronisation.

### 3.2 Alternatives evaluated

Three approaches were assessed:

- **Approach A (annotation-only):** Add `@BfoType` metadata to SysML `part def`s without creating OWL artefacts. Insufficient for the knowledge graph as canonical store commitment ([[concept-knowledge-graph|B22]]).
- **Approach B (OWL direct):** Create actual OWL 2 DL files, persist in a triple store, build a Python mapping pipeline. **Selected.**
- **Approach C (openCAESAR/OML):** Use JPL's Ontological Modeling Language as an intermediary. OML compiles to OWL 2 DL and offers a more systems-engineering-native authoring experience.

### 3.3 Why OML was not adopted

Perplexity Pro research investigated seven specific questions about the OML/openCAESAR ecosystem. Key findings:

1. **OML does not solve the round-trip problem.** Even with OML, the SysML v2 ↔ OWL synchronisation architecture must be explicitly engineered. OML changes how you author ontologies, not how the two formalisms communicate.
2. **The Flexo-SysMLv2 OWL ontology for SysML v2 is non-normative and still evolving.** No published coverage map. Known challenges with open-world OWL vs closed-world SysML semantics.
3. **OML's VS Code support is still maturing.** Eclipse/Rosetta is the more complete IDE. The Gradle/Java toolchain is an additional dependency in Ontara's Python/SvelteKit stack.
4. **No published BFO-aligned case studies** at a scale or domain comparable to Ontara.
5. **The OWL escape hatch is clean.** OML compiles to OWL 2 DL, so adopting OML later as an authoring convenience is straightforward if the ecosystem matures.

**OML is parked as a potential future convenience, not an architectural dependency.** This preserves [[concept-non-constraining|J3 (non-constraining)]] — all options remain open.

### 3.4 The minimum viable ontological artefact

The first concrete deliverable will be:

1. An **Ontara upper ontology OWL file** importing BFO and declaring BMM/SMM concepts as subclasses of BFO categories
2. A **namespace and IRI scheme** for Ontara's ontological entities (§8)
3. A **chosen triple store** with the ontology stack loaded (§5)

---

## 4. Q2 — Mid-Level Ontology Commitments

### 4.1 The ontology stack

The three-layer architecture from Session 59 is retained:

```
Domain ontologies (per-tenant)
    ↑
Mid-level: CCO, IAO, OGMS (+ others)
    ↑
Upper ontology: BFO
```

### 4.2 Platform-level vs sector-level

The [[concept-multi-tenancy|multi-tenancy principle (A13)]] determines the layering:

| Level | Ontologies | Rationale |
|---|---|---|
| **Platform** (all tenants) | BFO + CCO + IAO | Every service business has agents, acts, information artefacts, commercial exchange, temporal structure |
| **Healthcare sector** | + OGMS | Clinical primitives for healthcare tenants |
| **Tenant-specific** | Per-domain extensions | Each tenant's unique axes and value spaces |

### 4.3 Commitment structure

**Binding (adopt now, platform-level):**

- **BFO (Basic Formal Ontology)** — already binding (B18). ISO/IEC 21838-2:2021. ~35 classes. The fundamental continuant/occurrent distinction, roles, dispositions, qualities, processes.
- **CCO (Common Core Ontologies)** — eleven BFO-aligned sub-ontologies covering agents, acts, artefacts, events, time, information entities, geospatial entities, currencies, units of measure. US DoD/IC baseline standard (January 2024), under IEEE evaluation. Provides the enterprise and service business vocabulary the BMM's concepts are grounded in.
- **IAO (Information Artifact Ontology)** — BFO-aligned, covers information entities: documents, reports, measurements, codes, forms, records, specifications. Grounds the comprehension architecture, governance traceability chain, audit evidence, and metadata annotations.

**Binding (adopt now, healthcare sector):**

- **OGMS (Ontology for General Medical Science)** — BFO-aligned clinical primitives: disease, disease course, diagnosis, symptom, sign, clinical encounter, treatment plan, treatment process. Driven by the new [[domain-ears|Ears (Community Ear Care)]] demonstrator — Ontara's second clinical domain — and needed for [[domain-gsl|GSL]].

**On OGMS and gender-affirming care:** Gender identity (self-identified, a BFO quality), gender incongruence (ICD-11 HA60, a diagnostic classification), and gender dysphoria (a symptom — distress arising from incongruence) are three discrete, related entities with clear BFO typings. There is no difficulty or practical contest between these if the modelling is precise and the discussion properly informed. OGMS will be extended where GAHT modelling requires precision beyond its base vocabulary.

**Directional (acknowledged, not yet binding):**

- **OCE (Ontology of Commercial Exchange)** — BFO-aligned, built on CCO. Commercial transactions, contracts, service exchanges. To be evaluated when FinancialPlanning and StakeholderModel move to the knowledge graph.
- **GSSO (Gender, Sex, and Sexual Orientation Ontology)** — GSL-specific. To be evaluated alongside OGMS extension for GAHT.

**Deferred:**

- **OBI (Ontology for Biomedical Investigations)** — laboratory/research-oriented. To be evaluated if laboratory investigation modelling becomes relevant.

### 4.4 The Ears demonstrator

Session 97 introduced **Ears (Community Ear Care Service)** as Ontara's fifth demonstrator domain and second clinical domain. A community-based ear care service built around ear irrigation for cerumen impaction, with a simple procedural pathway (referral → assessment → pre-treatment → intervention → post-procedure check → follow-up).

Ears serves as the clinical equivalent of [[domain-cafe|Cafe]] — a clean, bounded domain for validating clinical meta model patterns without the complexity of long-term therapy management. It is the OGMS adoption driver: the first domain to exercise OGMS clinical primitives in the knowledge graph. See [[domain-ears|domain note]] for full outline.

---

## 5. Q3 — Triple Store Selection

### 5.1 Requirements

The triple store must support: OWL 2 DL reasoning (or work with an external reasoner), SPARQL 1.1, named graphs (for the three-stratum architecture, §6.2), reasonable scale for Ontara's near-term needs (tens of thousands of triples), good developer experience on macOS, programmatic access from Python, and free/open-source availability for development.

### 5.2 Candidates evaluated

Four candidates were assessed in detail:

- **Apache Jena Fuseki** — open source, SPARQL 1.1, configurable reasoning (RDFS/OWL fragments), Docker-friendly. The openCAESAR default. Limitation: no built-in full OWL 2 DL reasoning.
- **Ontotext GraphDB Free** — free edition, forward-chaining OWL-Horst reasoning built in, excellent query performance, rich web UI, SPARQL 1.1, named graphs, SHACL validation. Limitation: OWL-Horst is not full OWL 2 DL.
- **Stardog** — commercial with Community edition. The only candidate with built-in full OWL 2 DL reasoning (embedded Pellet 3.0, backward-chaining). Limitation: commercial licensing, memory constraints for full DL reasoning.
- **Blazegraph** — open source, formerly used by Wikidata. **No longer actively developed.** Not a responsible choice for new architecture.

### 5.3 Decision: two-tier approach

| Component | Choice | Rationale |
|---|---|---|
| **Primary triple store** | GraphDB Free | Best developer experience, built-in OWL-Horst reasoning, fast queries, free |
| **Full OWL 2 DL reasoning** | HermiT (or Pellet) as external pipeline step | Full DL classification and consistency checking without commercial dependency |
| **Fallback / alternative** | Apache Jena Fuseki | Fully open source, no commercial risk, standard SPARQL |
| **Future re-evaluation** | Stardog | If production needs in-line DL reasoning at scale |

The two-tier pattern: GraphDB handles storage, querying, and built-in OWL-Horst inference (subclass hierarchy, domain/range, property characteristics, transitivity, inverse). HermiT or Pellet runs externally as a pipeline validation step for full OWL 2 DL consistency checking and classification.

### 5.4 Non-constraining verification

The SPARQL 1.1 endpoint abstraction means the triple store is a swappable component. The Python pipeline talks to a SPARQL endpoint URL, not a GraphDB-specific API. Switching to Fuseki, Stardog, or any other SPARQL-compliant store means changing a configuration value.

---

## 6. Q4 — The Mapping Discipline

### 6.1 The foundational principle: domain-semantic, not notation-semantic

The mapping between SysML v2 and OWL 2 DL is **domain-semantic**: we map the *meaning* of business and system model concepts to ontological representations, not the *notation* in which they are authored.

We do not ask "how do I represent every SysML syntax node in OWL." We ask "which SysML constructs express domain commitments that deserve canonical semantic representation in the knowledge graph?"

This is [[principle-separation-representation-execution|A1]] applied at the formalism boundary: SysML is the engineering representation (structural decomposition, interfaces, states, workflows). OWL is the ontological representation (class axioms, property characteristics, BFO-grounded semantics, inferential knowledge). Each does what it does best.

### 6.2 Three-stratum knowledge graph architecture (E019)

The knowledge graph is internally organised into three separable graph strata:

1. **Metamodel graph** — represents SysML v2 constructs themselves (packages, part defs, metadata defs). Tooling and traceability infrastructure, not domain semantics. Kept separate to prevent SysML notation concepts from polluting the ontological layer.

2. **Domain graph** — represents Ontara's business and domain semantics, aligned to BFO/CCO/IAO/OGMS. The canonical semantic layer. This is where [[principle-intrinsic-self-knowledge|A10]] (intrinsic self-knowledge) and [[principle-unity-principle|A11]] (unity principle) operate.

3. **Correspondence graph** — stores explicit `sysmlElement ↔ owlEntity` mappings with provenance, sync state, generation timestamps, and authority-zone policy. The concrete realisation of [[ontara-ref-master-register|B24]] (mapping ontology). The heart of safe round-trip synchronisation.

Each stratum is a named graph in GraphDB, independently addressable via SPARQL.

### 6.3 Authority zones for round-trip governance (E020)

Rather than naïve bidirectional synchronisation, the mapping uses explicit authority zones:

- **SysML-authoritative:** structural decomposition, interfaces, states, workflows, allocations, views, package hierarchy, instance-level configuration. Changes originate in `.sysml` files and propagate to the knowledge graph.
- **OWL-authoritative:** class axioms, property characteristics, disjointness, existential restrictions, imported upper/mid-level ontological semantics, domain ontology extensions, SPARQL-derived inferences. Changes originate in OWL and propagate to SysML as annotations or metadata.
- **Shared but constrained:** labels, definitions, annotations, trace links, selected taxonomic structures. Editable from either side with explicit merge rules recorded in the correspondence graph.

The knowledge graph does not freely rewrite arbitrary SysML files. It emits patches only for the narrow set of shared constructs declared as safely reconstructible.

### 6.4 Domain graph mapping table

| SysML construct | OWL mapping | BFO grounding |
|---|---|---|
| BMM `part def` (structural) | OWL class, subclass of BFO category | BFO:IndependentContinuant or BFO:DependentContinuant |
| BMM `part def` (role) | OWL class, subclass of BFO:Role | BFO:Role |
| BMM `part def` (process) | OWL class, subclass of BFO:Process | BFO:Process |
| Typed attributes | OWL data/object properties | BFO:Quality for measurable properties |
| Typed `ref` cross-references | OWL object properties | CCO/BFO relationship semantics |
| `@WeightedRelationship` | Reified OWL relationship (n-ary) | Custom Ontara relation |
| `@PurposiveDescription` | IAO:TextualEntity linked to described class | IAO:InformationContentEntity |
| Enum values | OWL named individuals | Domain-specific |
| Demonstrator `part` usages | OWL named individuals | Instance of corresponding class |

### 6.5 Five-stage Python pipeline

The mapping pipeline extends Ontara's existing generation pattern:

**Stage 1: Parse SysML → Internal AST.** Extends `gen_model_introspection.py`. Produces a Python data structure with stable element identifiers, package hierarchy, part defs, attributes, metadata annotations, and demonstrator instances.

**Stage 2: Project to Mapping IR.** Classifies each element into mapping categories: `DomainClass`, `DomainProperty`, `DomainIndividual`, `MetadataAnnotation`, `StructuralOnly`, `Excluded`. The classification rules are a declarative mapping specification in the repo — version-controlled and reviewable.

**Stage 3: Map IR to OWL/RDF.** Transforms the classified IR into OWL axioms and RDF triples using `rdflib`. Outputs Turtle files or SPARQL INSERT operations targeting GraphDB's named graphs.

**Stage 4: Reason and Validate.** Two sub-steps: (a) GraphDB's built-in OWL-Horst inference for common patterns; (b) external HermiT/Pellet for full OWL 2 DL consistency checking. Plus SPARQL-based domain-specific validation queries.

**Stage 5: Round-trip Diff.** Computes diffs between current knowledge graph state and last-known SysML-synchronised state (via the correspondence graph). For OWL-authoritative or shared-constrained changes, generates a report of proposed SysML patches. Initially human-reviewed; automation level increases as confidence in the mapping grows.

### 6.6 The correspondence graph in detail

Each record in the correspondence graph captures:

- Stable SysML element ID and file path
- SysML source hash (for change detection)
- OWL entity IRI
- Mapping category and authority zone
- Generation timestamp and sync state (in-sync / SysML-changed / OWL-changed / conflict)

Stored as RDF triples in a named graph within GraphDB. SPARQL queries answer: "which OWL entities have no SysML source?", "which SysML elements changed since last sync?", "which mappings are in conflict?"

---

## 7. Q5 — Relationship to the Existing SysML Model

### 7.1 What exists today

34 BMM `part def`s across 6 concern packages with full comprehension metadata (34/34 `@UserFacing`, `@PurposiveDescription`, `@Comprehension`). 96 `@WeightedRelationship` annotations. 20 `ArchitecturalSection` `part` usages. Demonstrator instances across Cafe, Suds, Paws. 22 PatternCatalogue patterns with 33 domain instantiations.

### 7.2 BFO type annotations

Each BMM `part def` will carry a new `@BfoType` metadata annotation declaring its BFO category. This annotation serves as both human-readable documentation and the input to the mapping pipeline's Stage 2 classification.

### 7.3 The additive principle

The existing SysML model does not need refactoring. The BFO mapping is additive: new metadata annotations, a new generator stage, and a new output target (OWL/GraphDB). The existing generator, console, and comprehension architecture continue to work unchanged. The knowledge graph is a new parallel representation, not a replacement. Consistent with [[concept-co-evolution|J2 (co-evolution)]].

---

## 8. The IRI Scheme

Ontara owns the `ontara.dev` TLD (Google Registry) and `ontara.co.uk`. The IRI scheme uses `ontara.dev` as the namespace authority:

```
https://ontara.dev/ontology/          — Ontara platform ontology namespace
https://ontara.dev/ontology/bmm/      — BMM vocabulary classes
https://ontara.dev/ontology/smm/      — SMM vocabulary classes
https://ontara.dev/ontology/mapping/  — Correspondence graph vocabulary
https://ontara.dev/data/cafe/         — Cafe demonstrator instance data
https://ontara.dev/data/paws/         — Paws instance data
https://ontara.dev/data/ears/         — Ears instance data
https://ontara.dev/data/suds/         — Suds instance data
https://ontara.dev/data/gsl/          — GSL tenant instance data
```

The `/ontology/` vs `/data/` split separates TBox (classes, properties, axioms) from ABox (individuals, assertions). IRIs are permanent once minted. The domain can serve ontology files as linked data when ready.

---

## 9. Emergent Ideas

Two emergent ideas were captured during this session:

- **E019 — Three-stratum knowledge graph architecture:** metamodel / domain / correspondence graph strata. The correspondence graph is the first-class mapping layer that makes round-trip tractable. See §6.2.

- **E020 — Authority zones for round-trip governance:** SysML-authoritative vs OWL-authoritative vs shared-constrained constructs. The operational discipline that prevents synchronisation fragility. See §6.3.

Both recorded in the [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]] with full context and connections.

---

## 10. Decisions Summary

| # | Decision | Status | Rationale |
|---|---|---|---|
| D1 | OWL 2 DL direct (not OML) for ontology authoring | **Binding** | OML does not solve round-trip; adds dependency risk; OWL escape hatch preserved |
| D2 | BFO + CCO + IAO as platform-level ontology stack | **Binding** | Enterprise semantics (CCO), information artefacts (IAO) are platform-universal |
| D3 | OGMS as healthcare sector ontology | **Binding** | Driven by Ears demonstrator and GSL; clinical primitives needed now |
| D4 | GraphDB Free as primary triple store | **Binding** | Best developer experience, built-in OWL-Horst, free, SPARQL-standard |
| D5 | HermiT/Pellet as external DL reasoner | **Binding** | Full OWL 2 DL without commercial dependency |
| D6 | Domain-semantic mapping (not notation-semantic) | **Binding** | Map meaning, not syntax |
| D7 | Three-stratum graph architecture (E019) | **Binding** | Metamodel / domain / correspondence separation |
| D8 | Authority zones for round-trip governance (E020) | **Binding** | SysML-authoritative / OWL-authoritative / shared-constrained |
| D9 | IRI scheme under `https://ontara.dev/` | **Binding** | Owned TLD; permanent namespace |
| D10 | OCE adoption | Directional | To be evaluated for FinancialPlanning/StakeholderModel |
| D11 | GSSO adoption | Directional | To be evaluated alongside OGMS extension for GAHT |
| D12 | Stardog re-evaluation | Deferred | If production needs in-line DL reasoning |
| D13 | OML re-evaluation | Deferred | If authoring friction warrants investigation |

---

## 11. Register Connections

### Tier 1 principles exercised

- [[principle-separation-representation-execution|A1]] — applied at the formalism boundary: authority zones determine which formalism is authoritative for which content
- [[principle-self-describing-system|A2]] — the knowledge graph extends self-description to ontological semantics
- [[principle-model-generates-everything|A3]] — refined: the *combined* SysML + OWL representation generates everything
- [[principle-two-meta-model-distinction|A4]] — the domain graph reflects the BMM/SMM distinction with BFO grounding
- [[principle-discipline-as-load-bearing-structure|A9]] — authority zones and the correspondence graph are disciplined practices
- [[principle-intrinsic-self-knowledge|A10]] — operates over the domain graph
- [[principle-unity-principle|A11]] — the domain graph is the single semantic authority
- [[concept-co-evolution|J2]] — knowledge graph evolves alongside SysML model and console
- [[concept-non-constraining|J3]] — all decisions verified non-constraining; SPARQL abstraction enables store switching; OML adoption remains possible

### Concepts directly exercised

- [[ontara-ref-master-register|B18]] (BFO — mandatory) — implementation architecture defined
- [[ontara-ref-master-register|B22]] (knowledge graph as canonical store) — three-stratum architecture designed
- [[ontara-ref-master-register|B23]] (OWL 2 DL as mandatory) — authoring and reasoning approach defined
- [[ontara-ref-master-register|B24]] (mapping ontology) — correspondence graph is the concrete realisation

### New register candidates

- **Three-stratum graph architecture** (E019) — proposed T2, Section B
- **Authority zones** (E020) — proposed T2 or T3, Section B or N
- **Ears demonstrator domain** — new demonstrator entry
- **BFO + CCO + IAO + OGMS as adopted ontology stack** — update to B18/B19

---

## 12. What Comes Next

### Immediate (next 1–3 sessions)

1. **`@BfoType` metadata def and BFO mapping table.** Design the metadata def, produce the complete mapping table for all 34 BMM `part def`s, apply annotations. Bounded, high-value exercise.
2. **GraphDB setup.** Install GraphDB Free locally. Create the Ontara repository. Load BFO, CCO, IAO, OGMS. Verify reasoning and SPARQL querying.
3. **First OWL file.** Author the Ontara platform ontology importing BFO and declaring BMM vocabulary classes with BFO parent mappings.

### Near-term (next 3–6 sessions)

4. **Pipeline Stage 1–3 prototype.** Extend `gen_model_introspection.py` to produce OWL/Turtle output. Initial mapping IR and rules layer.
5. **Ears demonstrator design.** Detailed domain design exercising OGMS clinical primitives.
6. **Correspondence graph design.** Detailed schema for the mapping records.

### Medium-term

7. **Pipeline Stages 4–5.** Reasoning/validation integration and round-trip diff.
8. **Console integration.** Knowledge graph data surfaced in the Ontara Console.
9. **Authority zone refinement.** As the mapping pipeline matures, the shared-constrained zone can expand.

---

## Related Documents

- [[ontara-discussion-dual-stack-architecture-2026-03-26|Dual-Stack Architecture]] (Session 73/74)
- [[ontara-discussion-ontological-grounding-2026-03-22|Ontological Grounding for the Coordinate Framework]] (Session 59)
- [[ontara-research-(perplexity) - ontologies & domain coordinates|Perplexity: Ontologies and Domain Coordinates]]
- [[ontara-research-(perplexity) - ontology-dsl-mapping-sync|Perplexity: Ontology-DSL Mapping and Sync]]
- [[ontara-discussion-architectural-campus-walk-2026-03-28|The Ontara Campus]] (Sessions 84–85)
- [[ontara-discussion-visual-architecture-page-2026-03-31|Visual Architecture Page]] (Session 92)
- [[ontara-ref-master-register|Master Concept Register]]
- [[ontara-ref-vision-architecture|Vision and Architecture Reference]]
- [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]] (E019, E020)
- [[domain-ears|Ears (Community Ear Care) domain note]]

---

*Discussion paper written 1 April 2026 (Session 97). The transition from architectural commitment to implementation design for Ontara's ontological grounding. Informed by Perplexity Pro research on OML/openCAESAR ecosystem maturity, SysML↔OWL mapping patterns, and triple store selection.*
