---
tags:
  - session-report
date: 2026-04-01
status: complete
session: 102
---
# Session 102 Report — Ontara BMM Ontology Generation and Loading
> `= this.file.path`

**Date:** 1 April 2026
**Session type:** Implementation (Chat + Code)
**Duration:** Full session
**Previous session:** [[session-101-report-2026-04-01|Session 101]] (1 April 2026) — GraphDB setup and ontology stack loading

---

## Contents

- [[#1. Session Objectives|§1. Session Objectives]]
- [[#2. What Was Done|§2. What Was Done]]
- [[#3. Key Decisions|§3. Key Decisions]]
- [[#4. Key Finding — CCO 2.0 Opaque Identifiers|§4. Key Finding — CCO 2.0 Opaque Identifiers]]
- [[#5. Deliverables|§5. Deliverables]]
- [[#6. Register Connections|§6. Register Connections]]
- [[#7. Emergent Ideas|§7. Emergent Ideas]]
- [[#8. What Was Not Done|§8. What Was Not Done]]
- [[#9. Observations|§9. Observations]]

---

## 1. Session Objectives

From the [[session-102-preparation-note|Session 102 preparation note]]:

- **Priority A [Chat + Code]:** Stage 5 Phase 1 Step 2 — resolve three design decisions, then generate and load the Ontara BMM ontology (`ontara-bmm.ttl`) into GraphDB. Primary reference: [[session-100-kg-implementation-plan|KG implementation plan]] §3 Step 2.
- **Priority B [Code]:** Console commit (carried forward since Session 91).
- **Priority C:** Carried forward governance items.

---

## 2. What Was Done

### 2.1 Three design decisions resolved ✓

| # | Decision | Resolution |
|---|---|---|
| S102-D1 | **IRI minting convention** | Confirmed: `https://ontara.dev/ontology/bmm/{ElementName}`. Consistent with [[ontara-discussion-knowledge-graph-architecture-2026-04-01\|Session 97]] §8 IRI scheme. |
| S102-D2 | **Mid-level positioning** | Subclass of mid-level class only where available (BFO parent inferred via imported ontology hierarchy). Where no mid-level mapping exists, subclass BFO directly. Ontara domain classes deferred ([[concept-non-constraining\|J3]]). |
| S102-D3 | **Annotation properties** | Yes — `rdfs:label` (from `@UserFacing.friendlyName`), `rdfs:comment` (from `@UserFacing.shortDescription`), `skos:definition` (from `@PurposiveDescription.description`). Exercises the shared-constrained [[ontara-ref-master-register\|authority zone (B29)]] from the start. |

### 2.2 Generator script written ✓

`scripts/gen_ontara_bmm.py` — a Python script that generates the Ontara BMM ontology in Turtle format. Key design:

- **BFO and IAO IRIs hardcoded** — these use stable OBO PURLs (`http://purl.obolibrary.org/obo/BFO_0000xxx`, `IAO_0000xxx`).
- **CCO IRIs resolved dynamically** via SPARQL against GraphDB (`--resolve-cco` flag), stored in `ontology/config/cco-iri-lookup.json`. This was necessary because CCO 2.0 uses opaque numeric identifiers (§4 below).
- **Complete mapping data for all 34 BMM elements** embedded in the script, sourced from the `@BfoType`, `@UserFacing`, and `@PurposiveDescription` annotations on `model/business-model.sysml`. Mapping data from the [[ontara-discussion-bfo-type-mapping-2026-04-01|@BfoType mapping discussion paper]] ([[session-98-report-2026-04-01|Session 98]]).
- Four modes: `--resolve-cco` (populate CCO lookup), `--save` (generate and save), `--verify` (check lookup completeness), `--dry-run` (print to stdout).

### 2.3 CCO IRI resolution ✓

Ella ran `python scripts/gen_ontara_bmm.py --resolve-cco` against the live GraphDB instance. Three CCO classes resolved:

| CCO notation | rdfs:label | Resolved IRI |
|---|---|---|
| `CCO:Agent` | Agent | `https://www.commoncoreontologies.org/ont00001017` |
| `CCO:ArtifactFunction` | Artifact Function | `https://www.commoncoreontologies.org/ont00000323` |
| `CCO:GroupOfAgents` | Group of Agents | `https://www.commoncoreontologies.org/ont00000300` |

Lookup saved to `ontology/config/cco-iri-lookup.json`.

### 2.4 Ontology generated — 34/34 parent IRIs resolved ✓

Ella ran `python scripts/gen_ontara_bmm.py --save`. Output: `generated/ontology/ontara-bmm.ttl`, 24,458 bytes, 175 triples. All 34 BMM classes resolved to their correct parent: 26 to IAO classes, 4 to CCO classes (via the resolved lookup), and 4 directly to BFO classes (ServiceSubject, ServiceParticipant, StakeholderRelationship, CommunityRelationship — these have no mid-level mapping, as expected from the [[ontara-discussion-bfo-type-mapping-2026-04-01\|Session 98 mapping table]] §6 principle P6).

Validated in the container with rdflib: parses cleanly, 34 `owl:Class` declarations, 34/34 with `rdfs:label`, `rdfs:subClassOf`, and `skos:definition`. The four BFO-direct classes are the six elements identified as needing Ontara domain ontology classes in the [[ontara-discussion-bfo-type-mapping-2026-04-01|mapping paper]] §6 principle P6 — deferred per [[concept-non-constraining|J3]].

### 2.5 Ontology loaded into GraphDB ✓

Ella uploaded `ontara-bmm.ttl` via the GraphDB Workbench Import UI. **175 statements added**. Repository total rose to 80,127 statements (24,488 explicit + 55,639 inferred).

Note: the import used "From data" target graph, loading into the default graph rather than the `https://ontara.dev/graph/domain` named graph. This is acceptable for Phase 1 validation — the triples are queryable. The `load_graphdb.py` script (Step 5) will target the domain named graph explicitly.

The curl command printed by the generator had a URL-encoding issue with angle brackets in the `context` parameter. This is a minor bug to fix in the generator's output message.

### 2.6 SPARQL verification — 34/34 BMM classes confirmed ✓

Query against GraphDB confirmed all 34 Ontara BMM classes present with correct labels:

- ServiceConcept: 9 classes (CustomerSegment, ValueProposition, ServiceOffering, Channel, DifferentiationClaim, ServiceSubject, ServiceParticipant, CatalogueEntry, ExternalReference)
- ActivityModel: 5 classes (ActivityType, ActivityRecord, ActivityBudget, ActivityGranularity, ActivityCostAllocation)
- ResourcePlanning: 7 classes (ResourceType, ResourceInstance, Capability, CapacityModel, ResourceConstraint, InventoryRecord, ObjectiveCapabilityMapping)
- FinancialPlanning: 6 classes (RevenueStream, CostDriver, UnitEconomics, PricingModel, FinancialProjection)
- GovernanceMapping: 2 classes (GovernanceRequirement, AuditEvidenceRecord)
- StakeholderModel: 6 classes (StakeholderRelationship, CooperativeArrangement, ReferralPathway, ExternalDependency, CommunityRelationship, ParticipationModel)

OWL-Horst inference is computing the full transitive `rdfs:subClassOf` closure — a query for subclass parents returns 660 rows (each class inherits through the full BFO → CCO/IAO → Ontara chain plus anonymous class expressions). This confirms the reasoning is working correctly.

---

## 3. Key Decisions

| # | Decision | Status |
|---|---|---|
| S102-D1 | IRI convention: `https://ontara.dev/ontology/bmm/{ElementName}` | **Confirmed** |
| S102-D2 | Mid-level positioning: subclass mid-level only; BFO direct where no mid-level | **Confirmed** |
| S102-D3 | Annotation properties: `rdfs:label`, `rdfs:comment`, `skos:definition` from existing metadata | **Confirmed** |

---

## 4. Key Finding — CCO 2.0 Opaque Identifiers

**CCO 2.0 uses opaque numeric identifiers** (`cco:ont00001xxx`) rather than human-readable class names. This was discovered during the session when examining the downloaded `CommonCoreOntologiesMerged.ttl`. Classes are declared as e.g. `cco:ont00001017` with `rdfs:label "Agent"@en`, not as `cco:Agent`.

This has implications for the pipeline:

1. **The `@BfoType.midLevelClass` values** in the SysML annotations use `CCO:ClassName` notation (e.g. `CCO:GroupOfAgents`). These are human-readable labels, not IRIs. The pipeline must resolve them via SPARQL label lookup.
2. **The `--resolve-cco` pattern** established in this session — query GraphDB for `rdfs:label` matches, store the label→IRI mapping in a config file — is the right approach and should be extended to cover any future CCO classes referenced by the mapping.
3. **The [[ontara-discussion-bfo-type-mapping-2026-04-01\|BFO mapping discussion paper]]** uses `CCO:ClassName` notation throughout. This notation is correct as a human-readable reference but should not be confused with actual CCO IRIs. The `cco-iri-lookup.json` file is the authoritative mapping.

This finding was anticipated by risk KG-R3 in the [[session-100-kg-implementation-plan\|implementation plan]]: "CCO mid-level IRI resolution — `@BfoType.midLevelClass` uses `prefix:ClassName` format. Actual CCO IRIs may differ." The `--resolve-cco` mechanism resolves it cleanly.

---

## 5. Deliverables

| # | Deliverable | Type | Location |
|---|---|---|---|
| 1 | `scripts/gen_ontara_bmm.py` | Python generator | Repo `scripts/` |
| 2 | `ontology/config/cco-iri-lookup.json` | CCO IRI config | Repo `ontology/config/` |
| 3 | `generated/ontology/ontara-bmm.ttl` | Generated ontology | Repo `generated/ontology/` |
| 4 | This session report | Session report | Container artifact → vault |
| 5 | Session 103 preparation note | Preparation note | Container artifact → vault |

---

## 6. Register Connections

### Tier 1 principles exercised

| Principle | How exercised |
|---|---|
| [[principle-separation-representation-execution\|A1]] | OWL classes generated from SysML metadata — changes originate in representation. [[ontara-ref-master-register\|Authority zones (B29)]]: SysML-authoritative for structure, shared-constrained for labels/definitions. |
| [[principle-self-describing-system\|A2]] / [[principle-intrinsic-self-knowledge\|A10]] | `rdfs:label`, `rdfs:comment`, and `skos:definition` derived from `@UserFacing` and `@PurposiveDescription` — the ontology inherits the model's self-describing properties. |
| [[principle-model-generates-everything\|A3]] | Generator reads `@BfoType` annotations from SysML and produces OWL — the model generates the ontology. Refinement for dual-formalism: "the combined SysML + OWL representation generates everything." |
| [[principle-two-meta-model-distinction\|A4]] | Ontology scoped to BMM only. SMM deferred. Clear boundary maintained. |
| [[principle-discipline-as-load-bearing-structure\|A9]] | Generator is deterministic (same input → same output). CCO lookup is version-controlled. Validation via rdflib parse + SPARQL query. |
| [[concept-co-evolution\|J2]] | Model content (`@BfoType` annotations) and pipeline tool (generator) built together. |
| [[concept-non-constraining\|J3]] | Ontara domain classes (for elements with no mid-level mapping) deferred — BFO direct subclass for now. Can be added later without changing any existing declarations. rdflib enables format switching. |

### Tier 2 concepts directly exercised

- [[concept-ontological-grounding\|B18]] (BFO mandatory) — 34 BMM classes positioned under BFO categories
- [[ontara-ref-master-register\|B19]] (ontology stack) — CCO and IAO mid-level mappings realised as `rdfs:subClassOf` assertions
- [[concept-knowledge-graph\|B22]] (KG as canonical store) — **first Ontara content in the knowledge graph**
- [[ontara-ref-master-register\|B23]] (OWL 2 DL mandatory) — OWL classes authored, loaded, and reasoned over
- [[ontara-ref-master-register\|B24]] (mapping ontology) — IRI minting convention established; correspondence graph records designed (not yet populated)
- [[ontara-ref-master-register\|B28]] (three-stratum graph) — domain graph populated with Ontara BMM content
- [[ontara-ref-master-register\|B29]] (authority zones) — shared-constrained zone exercised (`rdfs:label`/`rdfs:comment`/`skos:definition` from SysML metadata)

### New register entries

None this session — implementation of established architecture, no new concepts introduced.

---

## 7. Emergent Ideas

No new emergent ideas captured this session.

---

## 8. What Was Not Done

- **Priority B (console commit)** — carried forward. Requires terminal access (Claude Code). Now pending since Session 91.
- **Priority C (governance items)** — all carried forward. [[ontara-workflow-emergent-ideas-log\|E017]] routing status, [[ontara - index-research-background\|Research & Background]] index (19+ sessions stale), BSMM→SMM discussion paper annotation pass, [[ontara-guide-claude-tooling\|Claude Tooling Guide]] [[ontara-workflow-emergent-ideas-log\|E018]] update, [[ontara-workflow-emergent-ideas-log\|E009]] CostDriver multiplicity fix, [[domain-suds\|Suds]] [[concept-stakeholder-model\|StakeholderModel]] gap, Stage 4 Phase 1 formal closure.
- **Protégé validation** — the generated Turtle was validated by rdflib and loaded into GraphDB without errors, but was not opened in Protégé for visual class hierarchy inspection. Can be done at any time.
- **Named graph targeting** — the ontology was loaded into the default graph via the GraphDB UI rather than the `https://ontara.dev/graph/domain` named graph. The data is queryable but not separated by stratum. To be addressed when `load_graphdb.py` is built (Step 5).
- **Curl command bug** — the generator prints a curl command for loading into GraphDB that has a URL-encoding issue with angle brackets. Minor fix needed.

---

## 9. Observations

This session completed Step 2 of the six-step [[session-100-kg-implementation-plan\|knowledge graph implementation plan]]. The three design decisions were resolved quickly (IRI convention, mid-level positioning, annotation properties), and the generator was written and tested in Chat, then run by Ella via terminal.

The key practical finding was that **CCO 2.0 uses opaque numeric IRIs**, not human-readable class names. This was anticipated as a risk (KG-R3) but the specifics could only be discovered by examining the actual ontology file. The `--resolve-cco` SPARQL lookup pattern resolves it cleanly and will scale as more CCO classes are referenced.

The ontology loaded on the first attempt — 175 statements, all 34 classes confirmed via SPARQL. The OWL-Horst reasoner computed the full transitive closure (660 inferred `rdfs:subClassOf` relationships), confirming that the BFO → CCO/IAO → Ontara BMM class hierarchy is being processed correctly.

**Milestone: Ontara's own content is in the [[concept-knowledge-graph|knowledge graph]] for the first time.** The 34 BMM elements exist as OWL classes, positioned under their BFO categories, with human-readable labels and definitions projected from the SysML model. This is the concrete beginning of the [[concept-dual-stack-architecture|dual-formalism platform]].

---

*Session 102 report written 1 April 2026.*
