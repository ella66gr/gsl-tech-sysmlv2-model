# Session 121 Report — Index Merge, Forward Planning, and Deontic Governance Architecture

**Date:** 3 April 2026 (Session 121)
**Type:** Mixed — Housekeeping + Discussion (Chat)
**Plan:** None (post-Phase-2 planning session)

---

## Contents

- [[#1. Summary|§1. Summary]]
- [[#2. Index Merge|§2. Index Merge]]
- [[#3. Forward Planning Discussion|§3. Forward Planning Discussion]]
- [[#4. Deontic Governance Architecture — Discussion Paper|§4. Deontic Governance Architecture — Discussion Paper]]
- [[#5. Register Concepts Exercised|§5. Register Concepts Exercised]]
- [[#6. Emergent Ideas|§6. Emergent Ideas]]
- [[#7. Tier 1 Principles Honoured|§7. Tier 1 Principles Honoured]]
- [[#8. Open Items and Deferred Work|§8. Open Items and Deferred Work]]

---

## 1. Summary

Session 121 opened a new chapter in the Ontara development programme. Following the formal closure of Stage 5 Phase 2 and the vault restructure in Session 120, this session completed a housekeeping task (merging two architecture paper index files), conducted a forward planning discussion that established three priority workstreams, and produced a substantial foundational discussion paper for the first of those workstreams: the Clinical and Operational Governance architecture.

The discussion paper — "[[ontara-discussion-deontic-governance-architecture-2026-04-03|Deontic Governance Architecture]]: An Obligation Vocabulary and Compliance Framework for the Ontara Platform" — is the most significant new architectural contribution since the [[ontara-discussion-dual-stack-architecture-2026-03-26|dual-stack architecture paper]] (Session 73). It introduces a deontic logic-grounded obligation vocabulary, a three-tier compliance architecture (library, activation, operations), and full integration with the existing [[concept-dual-stack-architecture|dual-stack architecture]] including simulation, projection, audit, and the [[concept-coordinate-framework|coordinate framework]].

## 2. Index Merge

Two index files coexisted in `04 Ontara Architecture` following the Session 120 vault restructure: [[ontara-architecture-papers-index|ontara-architecture-papers-index.md]] (the main index with curated reading order) and `ontara - index-exploratory-discussion-papers.md` (a thematically organised discussion papers index). These were merged into a single consolidated index.

Changes made to `ontara-architecture-papers-index.md`:
- Title updated to "Ontara Architecture — Papers Index"
- Introductory text updated to reflect the single flat folder structure and YAML-based document maturity
- Thematic description sentences added to 8 sections (adopted from the discussion papers index)
- 4 discussion papers added that were in the old index but missing from the main one: Vision/Concepts (Session 35), StakeholderModel (Sessions 76, 78), Self-Service (Session 28)
- "Generation & Execution" section consolidated into "Knowledge & Evaluation" (removing a thin legacy section)
- BSMM→SMM terminology corrected in the dual-stack paper description
- Session 34 KG architecture paper noted as superseded in scope by the Session 97 paper
- YAML frontmatter updated (date, session, status)
- Revision history updated

The old file was renamed to `DUPLICATE-TO-DELETE-ontara - index-exploratory-discussion-papers.md`. A cross-check confirmed every paper in the `04 Ontara Architecture` folder is accounted for in the merged index.

## 3. Forward Planning Discussion

With both Stage 5 phases closed, all governance backlogs clear, and the vault freshly restructured, a forward planning discussion identified candidate workstreams and established priorities.

Candidate workstreams assessed:
- Stage 5 Phase 3 (round-trip diff engine, SPARQL extension, live SPARQL console)
- Stage 4 Phase 2 (console structural navigation)
- [[ontara-workflow-emergent-ideas-log|E021]] (global console navigation context)
- [[domain-ears|Ears]] demonstrator (fifth domain, second clinical)
- SMM General vocabulary elaboration ([[ontara-ref-master-register|B25]])
- [[ontara-workflow-emergent-ideas-log|E011]] (IG and cybersecurity as foundational concern)
- [[ontara-workflow-emergent-ideas-log|E013]] (ontologically-informed console view differentiation)

Ella identified her priorities as:

1. **Clinical and Operational Governance** — a new workstream not on the initial candidate list. The ability for Ontara to ingest governance requirements, represent them formally, and use them operationally for compliance monitoring, simulation, projection, and audit. This has been a founding motivation for the platform's architecture since the start of the project.
2. **Stage 5 Phase 3** — continuing the knowledge graph workstream
3. **[[ontara-workflow-emergent-ideas-log|E021]]** — global console navigation context

The governance workstream was identified as the immediate focus for this session.

## 4. Deontic Governance Architecture — Discussion Paper

The core work of the session: a substantial discussion paper establishing the foundational design for the Clinical and Operational Governance workstream.

### Key architectural contributions

**Deontic vocabulary grounded in BFO/IAO.** Following Donohue (2017), deontic entities (obligations, permissions, prohibitions, regulatory powers) are categorised as species of [[concept-bfo-ontological-grounding|IAO]] directive information entity — generically dependent continuants that direct behaviour. This places the vocabulary within the existing [[concept-ontology-stack|ontology stack]] (BFO → CCO → IAO).

**Anatomy of a norm.** A deontic directive carries: subject (bearer), content (what is required), deontic modality (obligation/permission/prohibition/power), applicability conditions, exception conditions (for defeasibility), temporal scope, evidential specification, regulatory source, and sanction profile. Obligation composition patterns include obligation groups, composite obligations, alternative obligations, and cascading obligations.

**Normative instrument taxonomy.** A regime-agnostic taxonomy of source documents: primary legislation, secondary legislation, statutory guidance, regulatory standards, professional standards, codes of practice, technical standards, commissioning frameworks, contractual obligations, internal standards, and case law. Each instrument carries authority type, jurisdiction, enforcement mechanism, currency status, and version lineage.

**Three-tier architecture.** The compliance framework operates at three levels:
- **Library tier (platform level):** The Governance Framework Library — curated, versioned, machine-readable collections of deontic directives maintained as shared platform infrastructure. Frameworks carry formalisation provenance and endorsement status.
- **Activation tier (tenant level):** Framework activation evaluates applicability against the tenant's service model, binds obligations to specific service model elements, identifies structural gaps, and reconciles cross-framework overlaps.
- **Operational tier:** Continuous compliance monitoring with defined compliance states, evidence management with freshness tracking, service model change detection, and framework update propagation.

**Governance as a coordinate dimension.** Compliance state is a position in the [[concept-coordinate-framework|coordinate space]] ([[concept-coordinate-framework|A12]]). Governance trajectories, snapshots across all five [[concept-epistemic-modality|epistemic types]] ([[concept-coordinate-space-snapshots|L8]]), governance-aware simulation ([[concept-operational-simulation|L5]]/[[concept-reflective-simulation|L6]]), [[concept-valence|valence]]-weighted governance assessment ([[concept-valence|L7]]), and [[concept-goal-seeking-computation|goal-seeking]] with governance constraints ([[concept-goal-seeking-computation|L9]]) are all designed into the architecture.

**Temporal governance state and audit.** Every entity in the governance model is temporally indexed. Audit becomes a structured temporal query over the [[concept-knowledge-graph|knowledge graph]] — producible on demand because the information is intrinsic to the system's operational state.

**Supervised ingestion pipeline.** LLM-assisted decomposition of governance documents into the obligation vocabulary, with domain expert review, ambiguity flagging, and incremental update capability.

### Design decisions taken

| ID | Decision |
|---|---|
| S121-D1 | Deontic directives are BFO/IAO directive information entities |
| S121-D2 | Regime-agnostic vocabulary (no single governance regime privileged) |
| S121-D3 | Three-tier architecture (library, activation, operations) |
| S121-D4 | Defeasibility via explicit exception conditions, not non-monotonic reasoning |
| S121-D5 | Governance framework library as platform-level shared infrastructure |
| S121-D6 | Compliance state is a coordinate dimension |

### Open questions identified

Seven open questions (S121-Q1 through Q7) covering: BMM vs SMM placement of GovernanceFramework, obligation decomposition granularity, detailed OWL class structure, legislative cross-reference handling, MVP implementation path, Ears demonstrator relationship, and E011 relationship.

## 5. Register Concepts Exercised

| Concept | How exercised |
|---|---|
| [[principle-self-describing-system\|A2]] (self-describing system) | The governance architecture makes the system's own obligations and compliance state intrinsically knowable |
| [[principle-clinical-governance-first-class\|A8]] (clinical governance) | Governance elevated from a BMM concern to a full architectural workstream with its own vocabulary, ontological grounding, and simulation integration |
| [[principle-discipline-as-load-bearing-structure\|A9]] (discipline) | Index merge housekeeping; formal obligation representation propagates governance rigour |
| [[principle-intrinsic-self-knowledge\|A10]] (intrinsic self-knowledge) | Compliance state computed from live system state, not stored as static assessment |
| [[principle-unity-principle\|A11]] (unity principle) | Same governance model informs comprehension, simulation, goal-seeking, and audit |
| [[concept-coordinate-framework\|A12]] (coordinate framework) | Compliance as a coordinate dimension with trajectories and snapshots |
| [[concept-multi-tenancy\|A13]] (multi-tenancy) | Framework library is platform-level; activation is tenant-level |
| [[concept-knowledge-graph\|B22]] (knowledge graph) | Obligations, compliance states, and evidence records live in the knowledge graph |
| [[concept-bfo-ontological-grounding\|B23]] (OWL 2 DL) | Deontic vocabulary grounded in BFO via IAO, within OWL 2 DL |
| [[concept-weighted-relationships\|B14]] (weighted relationships) | Governance obligations participate in the weighted relationship model |
| [[concept-operational-simulation\|L5]] (operational simulation) | Governance constraints shape the simulation's state space |
| [[concept-reflective-simulation\|L6]] (reflective simulation) | Reads compliance state as input |
| [[concept-valence\|L7]] (valence) | Operator declares governance preferences as valence anchors |
| [[concept-coordinate-space-snapshots\|L8]] (coordinate space snapshots) | Governance state in all five epistemic types |
| [[concept-goal-seeking-computation\|L9]] (goal-seeking computation) | Obligations as hard constraints; permissions as action space |
| [[concept-non-constraining\|J3]] (non-constraining) | Regime-agnostic design; no single governance framework is privileged |

## 6. Emergent Ideas

No new emergent ideas captured this session. The governance workstream itself was identified as a priority during forward planning, but its architectural foundations draw on long-established concepts ([[principle-clinical-governance-first-class|A8]], [[ontara-workflow-emergent-ideas-log|E011]], GovernanceMapping) rather than representing a new emergent insight. [[ontara-workflow-emergent-ideas-log|E011]] (IG and cybersecurity) is partially subsumed by the governance framework library concept — GDPR, NHS DSPT, and Cyber Essentials could be frameworks in the library.

## 7. Tier 1 Principles Honoured

| Principle | How honoured |
|---|---|
| [[principle-self-describing-system\|A2]] (self-describing system) | Governance architecture makes obligations and compliance intrinsically knowable |
| [[principle-clinical-governance-first-class\|A8]] | Directly realised: governance as a first-class, computationally active system capability |
| [[principle-discipline-as-load-bearing-structure\|A9]] (discipline) | Index merge; formal session lifecycle followed |
| [[principle-intrinsic-self-knowledge\|A10]] (intrinsic self-knowledge) | Compliance state dynamically computed, not static |
| [[principle-unity-principle\|A11]] (unity principle) | One governance model serves comprehension, simulation, goal-seeking, and audit |
| [[concept-co-evolution\|J2]] (co-evolution) | Discussion paper produced alongside forward planning for implementation |
| [[concept-non-constraining\|J3]] (non-constraining) | Regime-agnostic design; vocabulary accommodates any governance framework |

## 8. Open Items and Deferred Work

1. **Delete `DUPLICATE-TO-DELETE-ontara - index-exploratory-discussion-papers.md`** from `04 Ontara Architecture` — Ella to delete from Obsidian.
2. **Run `reason_kg.py --save-summary`** — replace mock `reasoning-summary.json` with live version. Carried forward from Session 120.
3. **Deontic governance — next steps:** Resolve open questions S121-Q1 through Q7. Produce detailed OWL class design for the deontic vocabulary. Develop MVP implementation plan (S121-Q5). Consider CQC framework as first ingestion target.
4. **Stage 5 Phase 3 scoping** — second priority workstream. Round-trip diff engine, SPARQL validation extension, live SPARQL console integration.
5. **E021 design session** — third priority workstream. Global console navigation context.
6. **Systematic documentation review** — next due ~Session 123 (2 sessions away).
7. **Repo README.md currency check** — next due ~Session 124.
8. **Console data source currency check** — next due ~Session 128.
9. **F3 (DISPLAY_OVERRIDES cleanup)** — low priority, carried forward.

---

*Session 121 report produced 3 April 2026.*
