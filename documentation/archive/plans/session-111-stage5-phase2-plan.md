---
tags:
  - plan
  - knowledge-graph
date: 2026-04-02
status: current
session: 111
---
# Stage 5 Phase 2 — Ontological Enrichment, Reasoning, and Console Integration

**Date:** 2 April 2026 (Session 111)
**Purpose:** Implementation plan for Stage 5 Phase 2, extending the knowledge graph from a taxonomy (Phase 1) to a richly axiomatised ontology with full OWL 2 DL reasoning and console-visible results.
**Status:** Plan. Awaiting agreement before implementation begins.
**Depends on:** [[session-100-kg-implementation-plan|Stage 5 Phase 1]] (Sessions 100–107, closed)

---

## Contents

- [[#1. Context and Motivation|§1. Context and Motivation]]
- [[#2. Phase 2 Scope|§2. Phase 2 Scope]]
- [[#3. Work Breakdown|§3. Work Breakdown]]
- [[#4. Design Decisions|§4. Design Decisions]]
- [[#5. Session Allocation|§5. Session Allocation]]
- [[#6. Success Criteria|§6. Success Criteria]]
- [[#7. Risks and Mitigations|§7. Risks and Mitigations]]
- [[#8. Register Connections|§8. Register Connections]]

---

## 1. Context and Motivation

[[session-100-kg-implementation-plan|Phase 1]] (Sessions 100–107) delivered a working [[concept-knowledge-graph|knowledge graph]] foundation: 34 OWL classes in the domain graph, each with a single `rdfs:subClassOf` assertion to its BFO/CCO/IAO parent, plus labels, comments, and SKOS definitions. GraphDB's OWL-Horst reasoning provides transitive subclass chains — all 34 BMM classes confirmed as BFO:Continuant. The correspondence graph holds 306 triples (34 mapping records with provenance). The pipeline (`gen_owl_pipeline.py`) generates domain and correspondence Turtle from SysML via declarative mapping rules.

This is a **taxonomy** — it classifies what things *are* but does not express what they *must be like* or how they *relate to each other*. The BMM in SysML already encodes significant structural knowledge that the OWL ontology does not yet capture: typed `ref` relationships between `part def`s, multiplicity constraints, the concern group structure, and the 96 weighted relationships. OWL 2 DL can express all of this as formal axioms — disjointness declarations, object properties with domains and ranges, existential and universal restrictions, cardinality constraints. A full OWL 2 DL reasoner (HermiT or Pellet) can then check consistency and infer new knowledge that OWL-Horst cannot.

The motivation is architectural: if the [[concept-knowledge-graph|knowledge graph]] is to become the canonical store ([[ontara-ref-master-register|B22]], directional), it must carry ontological knowledge that goes beyond what SysML can express. Phase 2 is where the knowledge graph starts to earn that role.

[[ontara-stage-4-high-level-plan-2026-03-21|Stage 4]] is on hold — the 3D graph infrastructure is proven and will benefit more from later work when there is more content to represent.

---

## 2. Phase 2 Scope

Phase 2 has two sequential blocks:

**Block A — KG deep work (Sessions ~112–119).** Ontological enrichment and full OWL 2 DL reasoning. No console work.

**Block B — Console integration pass (Sessions ~120–122).** Surface KG data in the Ontara Console.

This is Option B from the Session 111 scoping discussion: deep KG work first, then a focused console integration pass. Rationale: avoid context-switching between Python/SPARQL/OWL and Svelte/TypeScript, design console views against a complete and stable data model, and allow deep focus on the ontological work.

---

## 3. Work Breakdown

### Block A — KG Deep Work

#### Step 1: Disjointness axioms [Chat + Protégé]

**What:** Declare the six BMM concern groups as mutually disjoint. No class can be a member of more than one concern group.

**Specifically:**
- `owl:AllDisjointClasses` across the six concern groups (ServiceConcept, ActivityModel, ResourcePlanning, FinancialPlanning, GovernanceMapping, StakeholderModel)
- Each concern group gets a union class collecting its members — e.g. `ontara-bmm:ServiceConceptElement owl:equivalentClass (ontara-bmm:CustomerSegment or ontara-bmm:ValueProposition or ... )`
- The six union classes are declared `owl:disjointWith` each other
- ServiceSubject and ServiceParticipant (BFO:Role) may need special handling — they sit in ServiceConcept but their BFO category (Role) is structurally different from the other ServiceConcept elements (GDC)

**Authored in:** Protégé (OWL-authoritative per [[ontara-ref-master-register|B29]] — disjointness is ontological semantics, not derivable from SysML structure). Saved as a separate OWL file (`ontara-bmm-axioms.ttl` or similar) and loaded into GraphDB alongside the pipeline-generated `ontara-bmm.ttl`.

**Validation:** Run HermiT/Pellet (Step 4) — should confirm consistency. Then deliberately introduce a misclassification and verify the reasoner catches it.

#### Step 2: Object property declarations [Chat + Protégé, then pipeline extension]

**What:** Declare OWL object properties corresponding to the typed `ref` attributes in the SysML BMM.

**Known typed refs in `business-model.sysml`:**
1. `ValueProposition.targetSegment → CustomerSegment`
2. `CatalogueEntry.linkedOffering → ServiceOffering`
3. `InventoryRecord.linkedCatalogueEntry → CatalogueEntry`
4. `ActivityCostAllocation.linkedActivityType → ActivityType`
5. `ActivityCostAllocation.linkedCostDriver → CostDriver`
6. `Capability.primaryResourceType → ResourceType`
7. `RevenueStream.linkedPricingModel → PricingModel`
8. `RevenueStream.linkedSegment → CustomerSegment`
9. `CostDriver.linkedResource → ResourceType [0..*]`
10. `GovernanceRequirement.linkedAuditEvidence → AuditEvidenceRecord`
11. `StakeholderRelationship.linkedGovernanceRequirement → GovernanceRequirement [0..1]`
12. `ParticipationModel.relatedServiceOffering → ServiceOffering [0..*]`

**Approach — hybrid:**
- **Phase 1 (hand-authored):** Declare all 12 object properties in Protégé with domain, range, and characteristics (functional where multiplicity is `[0..1]` or `[1]`). Add to `ontara-bmm-axioms.ttl`. This proves the axioms and lets the reasoner check them immediately.
- **Phase 2 (pipeline):** Extend `gen_owl_pipeline.py` to extract typed `ref` attributes from the SysML parser output, add a new mapping rule category (`ObjectProperty`) to `mapping-rules.yaml`, and generate the property declarations automatically. The hand-authored versions become the validation target for the generated versions. Once the pipeline matches, the hand-authored declarations can be retired or kept as a cross-check.

**Validation:** SPARQL queries confirming domain/range assertions. Reasoner consistency check. Deliberate violation test (e.g. assert a `targetSegment` pointing to a `CostDriver` — reasoner should flag inconsistency).

#### Step 3: Existential and cardinality restrictions [Chat + Protégé]

**What:** Express structural constraints that the BMM encodes informally.

**Candidate axioms:**
- `ServiceOffering SubClassOf hasTargetSegment some CustomerSegment` — every offering must target at least one segment
- `GovernanceRequirement SubClassOf hasAuditEvidence some AuditEvidenceRecord` — every requirement must have evidence
- `RevenueStream SubClassOf hasLinkedPricingModel exactly 1 PricingModel` — each revenue stream has exactly one pricing model
- `RevenueStream SubClassOf hasLinkedSegment exactly 1 CustomerSegment` — each revenue stream targets exactly one segment
- `CostDriver SubClassOf hasLinkedResource some ResourceType` — every cost driver links to at least one resource (now that multiplicity is `[0..*]`, the existential restriction says "at least one when used")
- `ValueProposition SubClassOf hasTargetSegment exactly 1 CustomerSegment` — each proposition targets exactly one segment
- `Capability SubClassOf hasPrimaryResource some ResourceType` — capabilities require resources

**Caution:** These restrictions must be carefully assessed. SysML multiplicity `[0..1]` means "zero or one" — which is *not* the same as an OWL existential restriction ("at least one"). Only multiplicities with a non-zero lower bound (`[1]`, `[1..*]`) become existential restrictions. The `[0..1]` and `[0..*]` cases become `maxCardinality` or remain unconstrained. This is a mapping subtlety that needs a design decision (S111-D1).

**Authored in:** Protégé (OWL-authoritative). These are ontological assertions about what BMM concepts *must* be like — they go beyond what SysML's structural model expresses.

#### Step 4: HermiT/Pellet integration [Code]

**What:** Integrate a full OWL 2 DL reasoner and run it against the enriched ontology.

**Options:**
- **HermiT** via the OWL API (Java). Can be called from Python via `py4j` or `jpype`, or run as a standalone Java command.
- **Pellet** (now Stardog's open-source fork, **Openllet**). Also Java-based, similar integration options.
- **Robot** (`robot.obolibrary.org`) — a command-line OWL tool that wraps HermiT/ELK. Potentially the simplest integration: `robot reason --reasoner HermiT --input ontara-bmm-full.ttl --output ontara-bmm-inferred.ttl`.

**Recommended:** Robot. It's a single JAR, runs from the command line, wraps HermiT, and is widely used in the BFO/OBI/CCO community (which is our ontology stack). A new script (`scripts/reason_kg.py` or a shell wrapper) would invoke Robot, capture the output, and report consistency status and inferred axioms.

**Deliverable:** A script that loads all ontology files (BFO, CCO, IAO, `ontara-bmm.ttl`, `ontara-bmm-axioms.ttl`), runs HermiT via Robot, and reports: (a) consistency (pass/fail), (b) unsatisfiable classes (if any), (c) count of inferred axioms. Integrate into the existing validation workflow alongside `validate_kg.py`.

#### Step 5: Pipeline extension — typed ref extraction [Code]

**What:** Extend the SysML parser and OWL pipeline to automatically extract typed `ref` attributes and generate object property declarations.

**Specifically:**
- Extend `sysml_parser.py` to capture typed `ref` attributes alongside existing attribute parsing (name, target type, multiplicity)
- Add `ObjectProperty` classification to `mapping-rules.yaml`
- Extend `gen_owl_pipeline.py` to generate `owl:ObjectProperty` declarations with `rdfs:domain`, `rdfs:range`, and functional characteristics from multiplicity
- Extend `ontara-correspondence.ttl` to include property mapping records
- Validate generated output against the hand-authored axioms from Step 2

#### Step 6: Weighted relationship mapping [Chat + Code]

**What:** Map the 96 `@WeightedRelationship` annotations to OWL object properties or annotation properties.

**Design question (S111-D2):** Weighted relationships are not simple object properties — they carry strength and rationale, and they are directed and non-commutative. Options:
- **OWL annotation properties** on classes (lightweight, doesn't participate in reasoning)
- **Reified relationships** — each weight becomes an individual of type `ontara-bmm:WeightedRelationship` with properties for source, target, strength, and rationale (heavyweight, but queryable and reasoning-accessible)
- **N-ary relation pattern** — OWL best practice for relationships with attributes

**Recommendation:** Reified relationships. They align with the [[principle-unity-principle|unity principle (A11)]] — the same weight data should be queryable in the KG, not just decorative annotations. The strength and rationale attributes are genuine knowledge. The correspondence graph already demonstrates the reification pattern (mapping records are reified relationships).

**Deliverable:** Pipeline extension to extract `@WeightedRelationship` annotations and generate reified relationship individuals in the domain graph. 96 new individuals with source/target/strength/rationale properties.

#### Step 7: Documentation and governance [Chat]

**What:** Update KG architecture paper with Phase 2 findings. Register new concepts if any emerge. Validate SPARQL suite. Formal Phase 2 closure assessment.

### Block B — Console Integration Pass

#### Step 8: BFO category and ontological context display [Code]

**What:** Surface `@BfoType` data already in `model-introspection.json` in the Glossary, Component Catalogue, and Architecture views. Each BMM element shows its BFO category and mid-level ontology parent. Lightweight — the data is already generated, just not displayed.

#### Step 9: Ontological hierarchy visualisation [Code]

**What:** A new console view (or tab within the existing Architecture view) showing the BFO → CCO/IAO → BMM class hierarchy as a navigable tree. Data source: SPARQL query against GraphDB, or a pre-generated JSON file from the pipeline.

**Design decision (S111-D3):** Live SPARQL vs. pre-generated JSON. Live SPARQL is more dynamic but requires GraphDB running. Pre-generated JSON is offline-safe and consistent with the existing `model-introspection.json` pattern. Recommendation: pre-generated JSON for Phase 2 (consistent with current architecture), with live SPARQL as a Phase 3/4 capability.

#### Step 10: Reasoning status and weighted relationships in console [Code]

**What:** Display reasoning results (consistency status, inferred relationships) and the reified weighted relationships from the KG. This gives the console user a view of what the knowledge graph *knows* beyond what the SysML model *says*.

---

## 4. Design Decisions

| # | Decision | Options | Recommendation | Status |
|---|---|---|---|---|
| S111-D1 | How SysML multiplicity maps to OWL restrictions | (a) `[0..1]` → maxCardinality 1; `[1]` → exactly 1; `[0..*]` → unconstrained; `[1..*]` → minCardinality 1. (b) Treat all refs as existential regardless of lower bound | (a) — faithful to the SysML semantics | Open |
| S111-D2 | How weighted relationships are represented in OWL | (a) Annotation properties (b) Reified individuals (c) N-ary relation pattern | (b) Reified — queryable, reasoning-accessible, consistent with correspondence graph pattern | Open |
| S111-D3 | Console KG data source: live SPARQL vs pre-generated JSON | (a) Live SPARQL queries to GraphDB (b) Pre-generated JSON from pipeline | (b) Pre-generated JSON for Phase 2, consistent with existing `model-introspection.json` pattern | Open |
| S111-D4 | Axiom file strategy: single file or multiple | (a) One `ontara-bmm-axioms.ttl` (b) Separate files per axiom type (disjointness, properties, restrictions) | (a) Single file — simpler; can split later if it grows | Open |
| S111-D5 | Reasoner tool selection | (a) Robot + HermiT (b) Openllet direct (c) py4j bridge to OWL API | (a) Robot — single JAR, command-line, used by BFO/CCO community | Open |

---

## 5. Session Allocation

**Block A — KG deep work**

| Step | Description | Est. sessions | Tool | Notes |
|---|---|---|---|---|
| 1 | Disjointness axioms | 1 | Chat + Protégé | Hand-author in Protégé; load into GraphDB |
| 2 | Object property declarations (hand-authored) | 1 | Chat + Protégé | 12 properties with domains, ranges, characteristics |
| 3 | Existential and cardinality restrictions | 1 | Chat + Protégé | Careful assessment of each multiplicity mapping |
| 4 | HermiT/Pellet integration via Robot | 1–2 | Code | Install Robot JAR, write wrapper script, run against full ontology |
| 5 | Pipeline extension — typed ref extraction | 1–2 | Code | Parser + mapping rules + generator + validation |
| 6 | Weighted relationship mapping | 1–2 | Chat + Code | Design reification schema; pipeline extension for 96 weights |
| 7 | Documentation and governance | 1 | Chat | KG architecture paper update, register, closure |

**Block A subtotal: 7–10 sessions**

**Block B — Console integration pass**

| Step | Description | Est. sessions | Tool | Notes |
|---|---|---|---|---|
| 8 | BFO category display | 1 | Code | Data already in JSON; console rendering only |
| 9 | Ontological hierarchy visualisation | 1–2 | Code | New view/tab; pre-generated JSON from pipeline |
| 10 | Reasoning status + weighted relationships | 1 | Code | Display inferred knowledge and reified weights |

**Block B subtotal: 3–4 sessions**

**Phase 2 total estimate: 10–14 sessions**

---

## 6. Success Criteria

**Block A:**
1. Enriched ontology with disjointness axioms, 12+ object properties, and existential/cardinality restrictions — loaded in GraphDB
2. Full OWL 2 DL consistency check passing via HermiT (Robot)
3. Deliberate violation tests demonstrating that the reasoner catches: (a) cross-concern misclassification, (b) domain/range violations, (c) cardinality violations
4. Pipeline generates object property declarations automatically from SysML typed refs — validated against hand-authored axioms
5. 96 weighted relationships represented as reified individuals in the domain graph
6. Validation SPARQL suite extended with new queries for properties, restrictions, and weighted relationships

**Block B:**
7. BFO category and mid-level parent displayed for every BMM element in the Glossary
8. Ontological hierarchy navigable as a tree in the console
9. Reasoning status (consistency, inferred axiom count) visible in the console
10. Reified weighted relationships queryable and displayable from KG data

---

## 7. Risks and Mitigations

| # | Risk | Mitigation |
|---|---|---|
| R1 | Robot JAR may have Java version compatibility issues on macOS | Test early (Step 4). Fallback: Openllet or py4j bridge. |
| R2 | BFO + CCO + IAO combined ontology may be too large for HermiT to reason over efficiently | Test with full stack in Step 4. If performance is an issue, use ELK (OWL 2 EL profile) for routine checks and HermiT for full checks on demand. |
| R3 | SysML multiplicity semantics may not map cleanly to OWL restrictions in all cases | S111-D1 captures the design decision. Conservative approach: only assert what is clearly justified. Document edge cases. |
| R4 | Weighted relationship reification generates many triples (96 × ~5 properties each = ~480 new triples) | Manageable given current scale (24,663 + 306 existing). Monitor graph size. |
| R5 | Hand-authored axioms and pipeline-generated axioms may drift | Step 5 explicitly validates pipeline output against hand-authored axioms. Pipeline becomes the authority once validated. |

---

## 8. Register Connections

### Tier 1 principles engaged

| Principle | How engaged |
|---|---|
| [[principle-model-generates-everything|A3]] (Model generates everything) | Pipeline extension generates OWL from SysML — the model remains the source |
| [[principle-discipline-as-load-bearing-structure|A9]] (Discipline as load-bearing structure) | Formal plan, phased approach, validation at each step |
| [[principle-intrinsic-self-knowledge|A10]] (Intrinsic self-knowledge) | The [[concept-knowledge-graph|knowledge graph]] explains what things are, how they relate, and what constraints govern them |
| [[principle-unity-principle|A11]] (Unity principle) | [[concept-weighted-relationships|Weighted relationships]] in the KG, consistent with the SysML model and the console |
| [[concept-co-evolution|J2]] (Co-evolution) | Console integration in Block B ensures KG capabilities are visible |
| [[concept-non-constraining|J3]] (Non-constraining) | OWL axioms complement SysML — neither formalism forecloses the other |

### Tier 2 concepts exercised

| Concept | How exercised |
|---|---|
| [[concept-ontology-stack|B18]] (BFO) | BFO disjointness patterns, class hierarchy reasoning |
| [[concept-ontology-stack|B19]] (Ontology stack) | CCO/IAO properties used in domain/range declarations |
| [[concept-knowledge-graph|B22]] (Knowledge graph as canonical store) | KG moves from taxonomy to richly axiomatised ontology — earns the canonical role |
| [[ontara-ref-master-register|B23]] (OWL 2 DL) | Full reasoner integration — the mandatory formalism is now fully exercised |
| [[ontara-ref-master-register|B24]] (Mapping ontology) | Correspondence graph extended with property mapping records |
| [[ontara-ref-master-register|B28]] (Three-stratum graph) | Domain graph enriched; correspondence graph extended |
| [[ontara-ref-master-register|B29]] (Authority zones) | Axioms are OWL-authoritative; pipeline extensions are SysML-authoritative; shared-constrained zone expanded |

---

*Plan produced Session 111, 2 April 2026. Supersedes the medium-term items in the [[ontara-discussion-knowledge-graph-architecture-2026-04-01|KG architecture paper]] §12.*
