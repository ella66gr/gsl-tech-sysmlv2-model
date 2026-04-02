# Next Session Preparation — Session 106
> `= this.file.path`

**Date prepared:** 2 April 2026 (end of Session 105)
**Purpose:** Concise handover for the next working session.

---

## Where We Are

[[session-105-report-2026-04-02|Session 105]] completed [[session-100-kg-implementation-plan|Stage 5 Phase 1]] Step 4 — the OWL pipeline generator (`gen_owl_pipeline.py`) is operational, producing 34 DomainClass elements via declarative mapping rules and `rdflib`. Three output files: `ontara-bmm.ttl` (175 triples), `ontara-correspondence.ttl` (306 triples), `mapping-ir.json` (723 elements). The hardcoded `gen_ontara_bmm.py` is archived to `scripts/archive/` with provenance. CLAUDE.md received a substantial update. Console build verified clean (carried-forward item closed). Code committed as `0efc2d5` (pipeline) and `bf99f1a` (CLAUDE.md).

Infrastructure state: GraphDB running with 80,127 statements. Pipeline generating from SysML source via shared parser. Three-stratum graph partially populated (domain + correspondence; metamodel deferred).

**Stage 5 Phase 1 progress:** Steps 1–4 complete (Sessions 101–105). Steps 5–6 remain.

---

## What the Next Session Should Do

### Priority A: Stage 5 Phase 1 Step 5 — Load, Reason, and Validate [Code + Chat]

This is the next step in the [[session-100-kg-implementation-plan|KG implementation plan]] §3 Step 5:

1. **[Chat] Design validation SPARQL queries.** A test suite confirming correctness:
   - Structural: "List all BMM classes and their BFO parent" → 34 rows
   - Structural: "Which BMM classes are subclasses of BFO:Role?" → should match mapping table
   - Instance: defer to Phase 1 extension (no `DomainIndividual` yet)
   - Correspondence: "Which OWL class maps to SysML `CustomerSegment`?" → `ontara-bmm:CustomerSegment`
   - Correspondence: "Which SysML elements have no OWL mapping?" → only non-BMM elements
   - Inference: "Which BMM classes are BFO:Continuant (including inferred)?"

2. **[Code] Reload pipeline-generated `ontara-bmm.ttl` into GraphDB.** The current loaded version is from the hardcoded generator (Session 102). Reload from the pipeline output. Also load the new `ontara-correspondence.ttl`.

3. **[Code] Implement validation suite** (`scripts/validate_kg.py`) — runs SPARQL queries against GraphDB and reports pass/fail.

Estimated effort: 1 session.

### Priority B: Strategic Snapshot Refresh [Chat]

The [[ontara-ref-strategic-snapshot|strategic snapshot]] (Session 99) now says "Implementation not yet started" for the KG architecture — this is incorrect (Steps 1–4 complete). §4.2, §4.3, and §8 need updating. This is a standard archive-before-refresh per [[ontara-workflow-development-guide|workflow guide]] §6.4.

Specific updates needed:
- §4.1 history: Sessions 101–105
- §4.2 current state: KG architecture row should show Steps 1–4 complete; console commit closed
- §4.3 what comes next: Step 5 validation, then Step 6 documentation
- §7 code repository: update scripts count (now includes `gen_owl_pipeline.py`, `sysml_parser.py`), add `ontology/` and `generated/ontology/`
- §8 technology stack: `rdflib`, `PyYAML` as pipeline dependencies

Depends on: [[ontara-discussion-bfo-type-mapping-2026-04-01|@BfoType mapping paper]] (Session 98), [[ontara-discussion-knowledge-graph-architecture-2026-04-01|KG architecture paper]] (Session 97)

### Priority C: Carried Forward Governance

In priority order:
- **BSMM→SMM annotation pass** — 2–3 remaining papers (`intrinsic-self-knowledge-v2`, `vision-concepts-principles`, possibly 1–2 early papers)
- **[[ontara-workflow-emergent-ideas-log|E018]] update** — [[ontara-guide-claude-tooling|Claude Tooling Guide]] update for MCP/Vite HMR finding
- **[[ontara-workflow-emergent-ideas-log|E009]]** — `CostDriver.linkedResource` multiplicity fix (`[0..1]` → `[0..*]`)
- **[[domain-suds|Suds]] [[concept-stakeholder-model|StakeholderModel]] gap** — Suds lacks StakeholderModel instantiations
- **[[ontara-stage-4-high-level-plan-2026-03-21|Stage 4]] Phase 1 formal closure**

---

## Documents to Read at Session Start

1. This preparation note
2. The **[[session-100-kg-implementation-plan|KG implementation plan]]** — §3 Step 5 is the primary working reference
3. The new `scripts/gen_owl_pipeline.py` — the pipeline generator (produced Session 105)
4. The generated `ontara-correspondence.ttl` — new this session, needs loading into GraphDB
5. `scripts/setup_graphdb.py` — the existing GraphDB setup/verification script

---

## Key Principles to Remember

- **SMM (not BSMM)** is the project terminology. The `bsmm-general-vocabulary` SysML section name is a structural identifier and stays.
- **Domain-semantic, not notation-semantic** mapping. Map meaning to the knowledge graph, not SysML syntax.
- **[[ontara-ref-master-register|Authority zones (B29)]]** govern round-trip: SysML-authoritative for structure, OWL-authoritative for ontological semantics, shared-constrained for labels/definitions.
- **[[ontara-ref-master-register|Three-stratum graph (B28)]]:** metamodel / domain / correspondence. The correspondence graph is first-class architecture.
- **Annotation ordering:** `@CatalogueTag → @BfoType → @UserFacing → @PurposiveDescription → @Comprehension → @WeightedRelationship(s)`.
- **IRI scheme:** `https://ontara.dev/ontology/` for vocabulary, `https://ontara.dev/data/` for instances.
- **CCO 2.0 namespace:** `https://www.commoncoreontologies.org/` — uses opaque numeric IRIs (`ont00001xxx`). Lookup in `ontology/config/cco-iri-lookup.json`.
- **Stage 5 Phase 1** is the current workstream. Six steps, ~6–9 sessions. Steps 1–4 complete (Sessions 101–105). Step 5 next.
- **`GovernanceRequirement` is a `requirement_def`**, not a `part_def` — mapping rules must account for both construct types in BMM packages.
- **Contents indices must use Obsidian-native format** `[[#heading|display text]]`, never GFM-style `[text](#anchor)`.
- **Systematic documentation review** next due ~Session 110 (per [[ontara-workflow-development-guide|workflow guide]] §7.3).
- **Repo README.md** next currency check at Session 114 (10-session threshold, updated Session 104).

---

## Standing Working Rules

- Use MCP filesystem tools for the local filesystem, not bash/view on MCP paths.
- Repo root: `~/Developer/gsl-tech/gsl-sysml-model`
- Obsidian vault: `/Users/ellagreen/Obsidian/GenderSense`
- Use `edit_file` for existing documents, never `write_file` on files Ella may have edited.
- Do not treat "shall I go ahead?" as rhetorical.
- **All vault references must be wikilinks.** No exceptions.
- **Enrichment happens on the vault copy, not the container artifact.**
- **Standing reference documents use stable filenames** (§6.4).
- **All container artifacts must be presented via `present_files`.**
- **E018 (MCP filesystem edits and Vite HMR) — under review.** Ella's experience contradicts the original report.
- **Version history tables** are standard in standing reference document headers (Session 96).
- **KG implementation plan location:** `/02 ONTARA ARCHITECTURE & MODELLING/02 Ontara Platform Development/Ontara Plans/Stage 5/session-100-kg-implementation-plan`
- **Repo README.md** — next currency check at Session 114 (10-session threshold, updated Session 104).

---

*Preparation note written 2 April 2026 at the close of Session 105.*
