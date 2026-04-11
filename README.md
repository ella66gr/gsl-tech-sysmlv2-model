# Ontara Platform — SysML v2 Model and Tooling Repository

## What Ontara Is

**Ontara** is a service system development, delivery, and execution platform, particularly strong in supporting regulated care service delivery. A model serves as the single source of truth for what a service business is, how it works, what rules govern it, and how the technology platform supports it. The model *generates* the running system rather than merely documenting it, and *comprehends itself* — it can explain what it contains and why.

## Architecture

Ontara maintains two distinct meta models connected by explicit horizontal mappings:

- **Business Meta Model (BMM)** — what a service business *is*. 34 elements across six concerns (ServiceConcept, ActivityModel, ResourcePlanning, FinancialPlanning, GovernanceMapping, StakeholderModel).
- **System Meta Model (SMM)** — how a business system *works*. ArchitecturalSection (20 section instances describing the dual-stack architecture), plus the reasoning metamodel as a cross-cutting SMM extension.

The **dual-stack architecture** (Session 73) pairs these as two parallel vertical stacks with horizontal mappings at every tier. The knowledge graph (OWL 2 DL in GraphDB) serves as the eventual canonical store, with SysML v2 as an engineering projection. BFO 2020 is the mandatory upper ontology; PROV-O provides provenance tracking at the platform level.

## Repository Structure

```
gsl-sysml-model/
├── model/                          SysML v2 model files (source of truth)
│   ├── gendersense.sysml           Root package — imports all domain packages
│   ├── business-model.sysml        BMM: 34 part defs across 6 concern packages
│   ├── business-scenarios.sysml    Business scenario definitions
│   ├── business-strategy.sysml     Business strategy definitions
│   ├── architectural-structure.sysml  SMM: ArchitecturalSection + 20 instances
│   ├── pattern-catalogue.sysml     22 validated patterns, 8 principles
│   ├── foundation.sysml            MetadataLibrary, CommonTypes, StatePatterns
│   ├── enterprise.sysml            Organisation, Regulation, Strategy, Risk
│   ├── knowledge.sysml             CDS, Constraints, Logic, Decisions
│   ├── service-delivery.sysml      Clinical pathways, consent, governance
│   ├── platform.sysml              Portal, EHR, messaging, integration
│   └── operations.sysml            Finance, people, reporting
├── exercises/                      Demonstrator domains
│   ├── coffeeshop-demonstrator/    Cafe — full-stack reference implementation
│   ├── suds-demonstrator/          Suds — batch processing launderette
│   └── paws-demonstrator/          Paws — appointment-based dog grooming
├── scripts/                        Generation pipeline (Python)
│   ├── gen_model_introspection.py  Console data generator (JSON from SysML)
│   ├── gen_owl_pipeline.py          OWL/Turtle generator (BMM → ontara-bmm.ttl)
│   ├── gen_concept_graph.py        Mermaid + Obsidian concept graph
│   ├── gen_package_hierarchy.py    Package hierarchy generator
│   ├── gen_system_manifest.py      System manifest generator
│   ├── gen_constraint_evaluator.py Constraint evaluator (TypeScript)
│   ├── gen_decision_table_evaluator.py  Decision table evaluator (TypeScript)
│   ├── sysml_parser.py             SysML v2 parser (shared across generators)
│   ├── projection_engine.py        Projection engine
│   ├── validate_kg.py              Knowledge graph validation (SPARQL suite)
│   ├── reason_kg.py               OWL 2 DL reasoning (Robot + HermiT)
│   ├── diff_kg.py                  Round-trip diff engine (288 semantic units)
│   ├── kg_utils.py                 Shared KG utilities (GraphDB, SPARQL, IRI)
│   ├── setup_graphdb.py            GraphDB repository setup script
│   ├── ontara                      CLI entry point
│   └── archive-documentation.sh    Vault → repo archive helper
├── console/                        Ontara Console (SvelteKit + Svelte 5)
│   ├── src/                        13 views: Home, Coverage Matrix, Package Navigator,
│   │                               Component Catalogue, Glossary, Governance, Meta-Model,
│   │                               Patterns, Domain Views, Weighted Relationship Graph (3D),
│   │                               Architecture (visual map), Ontology (BFO hierarchy + KG status)
│   │   └── lib/                    Shared stores (NavigationStore), components (NavLink,
│   │                               Breadcrumb, NavigationProvider), types
│   └── static/data/                model-introspection.json (console data source)
├── portal/                         Ontara Portal (SvelteKit + Svelte 5 + SQLite)
│   ├── src/
│   │   ├── routes/(app)/domains/   Domain dashboard, context, catalogue, simulations
│   │   └── lib/
│   │       ├── server/db/           SQLite schema, seed data, domain/module/context queries
│   │       ├── server/modules/      Server-side module operations
│   │       ├── server/simulation/   Batch event generation, metrics, simulation runs
│   │       ├── modules/             Shared logic: lifecycle, composition, epistemic, impact, metrics
│   │       ├── context/             Svelte 5 reactive stores (auth, domain)
│   │       └── types.ts             All portal type definitions
│   └── data/                       portal.db (SQLite, auto-created, gitignored)
├── generated/                      Generated artefacts (DO NOT EDIT)
│   ├── ontara/                     model-introspection.json
│   ├── ontology/                   OWL/Turtle output (ontara-bmm.ttl, etc.)
│   ├── concept-graph/              Mermaid diagrams
│   └── projections/                Projection engine output
├── ontology/                       Ontological assets
│   ├── axioms/                     Hand-authored OWL axioms (ontara-bmm-axioms.ttl)
│   ├── governance/                 Hand-authored governance ontology + test individuals
│   │   ├── ontara-governance.ttl   19 classes, 6 enum classes, 20 object properties, 16 data properties
│   │   ├── cqc-reg12-individuals.ttl  MVP test individuals (CQC Regulation 12)
│   │   └── catalog-v001.xml        Governance module catalog for Robot
│   ├── domain/                     Hand-authored domain identity vocabulary
│   │   └── ontara-domain.ttl       2 classes, 6 enum classes, 8+8 properties, 8 individuals
│   ├── reasoning/                  Hand-authored reasoning metamodel vocabulary
│   │   ├── ontara-reasoning.ttl    42 classes, 15 named individuals, 40 object + 10 datatype properties
│   │   └── ears-reasoning-instances.ttl  ~83 Ears clinical domain reasoning instances
│   ├── imports/                    External ontologies (BFO 2020, CCO, IAO, PROV-O core subset)
│   ├── config/                     Mapping config (mapping-rules.yaml, cco-iri-lookup.json)
│   └── catalog-v001.xml            Robot IRI resolution catalogue
├── documentation/
│   ├── reference/                  SysML syntax reference, versioned snapshots
│   ├── archive/                    Committed vault snapshots (session reports, plans, design docs)
│   └── generated/                  Generated documentation
├── libraries/                      Shared SysML metadata definitions
├── concept-graph/                  Concept graph source
├── tools/                          External tool binaries (robot.jar, etc.)
├── spikes/                         Experimental spikes
├── CLAUDE.md                       Claude Code project context
└── .claude/skills/                 Claude Code skills
```

## Technology Stack

| Component | Technology |
|---|---|
| Modelling language | SysML v2 (OMG ratified July 2025) |
| Modelling tool | Syside Modeler (VS Code extension) |
| Ontological formalism | OWL 2 DL — BFO 2020 + CCO + IAO + PROV-O (core subset) |
| Triple store | GraphDB Free 10.x (OWL-Horst reasoning) |
| Ontology authoring | Protégé 5.6+ |
| OWL reasoning | Robot 1.9.8 (wrapping HermiT) |
| Console | SvelteKit + Svelte 5 runes + Flowbite Svelte + Tailwind v4 |
| Portal | SvelteKit + Svelte 5 runes + Flowbite Svelte + Tailwind v4 + SQLite (better-sqlite3) |
| 3D relationship graph | 3d-force-graph + Three.js r183 + three-spritetext |
| Generation pipeline | Python (7 generators + OWL pipeline reading .sysml, producing JSON/TS/Mermaid/Turtle) |
| Coffee Shop app | SvelteKit + Temporal + XState v5 + EHRbase CDR + PostgreSQL |
| Knowledge base | Obsidian (separate vault, not in this repo) |
| Development | macOS, VS Code |

## Current State (Session 194, April 2026)

- **Post-Stage-8 direction established** (Sessions 192–193). Discussion paper — *Connecting the Stacks: Toward a Live, Model-Grounded System* — captures the strategic direction for Stage 9: connecting the currently isolated islands (SysML model, console, portal, execution layer, customer-facing UI) into a coherent, model-grounded system. Eight design decisions (S192-D1 through D8) and seven open questions (Q1–Q7) define the Stage 9 agenda. Key clarifications: (a) SMM runtime state and BMM runtime state are architecturally distinct and require separate stores and update paths; (b) the horizontal mappings at runtime are the rules that keep both sides synchronised; (c) the portal's module catalogue must be derived from the SysML model rather than hand-seeded (S192-D7). The concrete proving ground is the existing coffee shop demonstrator.
- **Concept graph note content currency complete** (Sessions 189–191, W-039/W-040). All ~97 concept graph notes reviewed and updated. W-039: six principle notes rewritten to current quality standard (A1, A2, A3, A4, A7, A8). W-040: 9 new notes created (B11, B12, B25, B30–B32, B34–B35, H1), 27 notes rewritten; concept count 60→70. All four concept graph templates updated.
- **Stage 8 — Ontara Portal formally closed** (Sessions 175–185, W-037). 11 sessions, within the 19–31 session estimate. Phase 1 (S175): user auth, domain CRUD, multi-domain switching, empty dashboard. Phase 2 (S176): 10-module catalogue (6 business + 2 generative + 2 analytical), schema-driven configuration, two intersecting lifecycle state machines (installation + operational), dashboard as state landscape. Phase 3 (S178): domain context model structured by 6 BMM concerns, module wiring via shared concern overlap, composition guidance with lifecycle impact warnings. Phase 4 (S179–181): epistemic dimension (production/hypothesis/projection as settable property), batch event generation (2 generator types, simplified/realistic fidelity), simulation runs, Comparative Dashboard with side-by-side metrics and health scores. Phase 5 (S182–185): progressive governance (exploratory/advisory/enforced), 20 typed constraints (8 hard, 6 soft, 6 graded), promotion path with 5-prerequisite wizard, demotion, production visual treatment, lifecycle governance guards. All 10 Phase 5 success criteria met.
- **Ears clinical domain intake complete** (Sessions 160–168). Clinical Domain Intake Framework methodology (S160) applied to Ears (Community Ear Care) — five artefacts: domain description, vertical connection map, coverage map (86.2% Full across 65 proforma fields), ~83 reasoning instance individuals (`ears-reasoning-instances.ttl`), design note. 25/42 reasoning classes exercised with clinical content. Vocabulary assessed as adequate at Ears-level complexity. HermiT CONSISTENT on 13-file ontology stack. SPARQL suite extended to 66 queries in 12 groups (10 new Ears Instance queries). Observation and Watchpoint Register established (12 items).
- **Stage 7 — Reasoning Metamodel** (Sessions 148–158) formally closed Session 159. All five phases (0–4) complete, 33/35 success criteria met (2 explicitly deferred pending instance data). `ontara-reasoning.ttl`: 42 OWL classes covering reasoning contexts, goals/obstacles/measures, decisions/plans, three-way constraint hierarchy with CombinationAlgebra, knowledge sources/heuristics (6 typed families with HeuristicPack), decision mode routing (4 Cynefin-mapped modes), SEPIO evidence architecture, structured probabilistic reasoning types, STAMP/STPA safety control structures, and FRAM-ready slots. 15 named individuals, 40 object properties, 10 datatype properties. 7 PROV-O dual-subclassed classes. 2 cross-module governance alignment axioms. Console: Reasoning Vocabulary Explorer (42 classes in 7 colour-coded modules, 15 individuals, 50 properties, 32 cross-module axioms) + extended KG Status (8 stat cards, module summary).
- **PROV-O imported** (Session 150). `prov-core.ttl` — W3C PROV-O core subset (3 Starting Point classes, 9 object properties, 3 datatype properties, 73 triples). Dual subclassing pattern: reasoning classes inherit from both BFO and PROV-O parents.
- **Foundations papers refreshed** — Architecture Principles to v4.1, Platform Modelling Strategy to v4.1, Service Business Meta Modelling to v3.1 (Session 170, light touch-up from v4/v4/v3 at Session 154).
- **Stage 5 — Knowledge Graph Implementation** Phases 1–3 formally closed. Three layers of automated QA: SPARQL validation (66 queries, 12 groups), OWL 2 DL reasoning (HermiT), round-trip diff (288 semantic units). 13-file ontology stack.
- **Domain Identity and Governance Convergence** (Stage 6, Sessions 141–144) — Block A complete. Dual-stack domain identity: `DomainIdentity` (BMM) + `DomainConfiguration` (SMM) in SysML, `ontara-domain.ttl` in OWL. A13 (multi-tenancy) promoted to binding T1.
- **Governance workstream** — vocabulary tier implemented and validated. Deontic governance architecture (Session 121), OWL class design (Session 125), governance ontology Turtle implemented (Session 126): `ontara-governance.ttl` in separate `ontara-gov:` namespace. MVP CQC Regulation 12 test individuals validated. Governance–reasoning alignment: Obligation and Prohibition declared as HardConstraint subclasses (Session 151).
- **Console navigation context** (Sessions 132–134): global NavigationStore with semantic breadcrumb trail, page state capture/restore, journey export. Six routes migrated.
- **BMM structurally complete** at General level — 36 elements (including DomainIdentity + DomainConfiguration), 96 weighted relationships, full comprehension metadata (34/34 @UserFacing, @PurposiveDescription, @Comprehension, @BfoType).
- **Console** has 13 views including an interactive 3D weighted relationship graph, a spatial visual architecture map, and an Ontology view with BFO hierarchy, Reasoning Vocabulary Explorer, and KG Status panel.
- **Five demonstrator domains** validated: Cafe, Suds, Paws (cross-domain reasoning validation), plus Ears (community ear care) — analytical intake complete (Sessions 161–168).
- **Sixth systematic documentation review** completed (Session 172). Modelling Paradigm Reference created (Session 173) — new standing reference document cataloguing 11 modelling paradigms. Downstream concept note check convention established.
- **Vision and Architecture Reference refreshed to v11** (Session 187). Full rewrite incorporating all of Stage 8 (Phases 1–5, Sessions 170–186). New §4 (The Ontara Portal, §4.1–4.10). 18 sessions incorporated.

## Key Commands

```bash
# Generate console data from SysML model
python scripts/gen_model_introspection.py --save

# Generate OWL/Turtle from BMM
python scripts/gen_owl_pipeline.py

# Run the console (dev mode)
cd console && pnpm dev

# Build the console
cd console && pnpm build

# Run the portal (dev mode — auto-creates SQLite DB)
cd portal && pnpm dev

# Build the portal
cd portal && pnpm build

# Run OWL 2 DL reasoner (requires Robot JAR in tools/; does NOT require GraphDB)
python scripts/reason_kg.py

# Run reasoner and save summary for console (dynamic counts + reasoning vocabulary)
python scripts/reason_kg.py --save-summary

# Run reasoner with deliberate misclassification test
python scripts/reason_kg.py --test-violation

# Validate knowledge graph (66-query SPARQL suite; requires GraphDB)
python scripts/validate_kg.py

# Reload full 13-file ontology stack into GraphDB and validate
python scripts/validate_kg.py --load

# Round-trip diff (compare pipeline output against GraphDB)
python scripts/diff_kg.py
```

## Companion Knowledge Base

The Obsidian vault (not in this repo) contains ~212 registered design concepts across 16 sections (A–P), 37 discussion papers, ~166 session reports (Sessions 28–193), 30 emergent ideas log entries, and the full governance structure including an Observation and Watchpoint Register (35 items). The vault is under separate git version control.

Key documents: Strategic Reference, Master Concept Register, Development Workflow Guide, Architecture Principles (v4.1), SysML Modelling Strategy (v4.1), Service Business Meta Modelling (v3.1), Modelling Paradigm Reference.

## Development Methodology

Three governing principles:

1. **Cross-domain validation** — every meta model concept must validate in at least two demonstrator domains.
2. **Co-evolution of model and tooling** — no modelling without the tool that makes it legible; no tool without model content that exercises it.
3. **Non-constraining architecture** — decisions should not foreclose future development paths.

Development is conducted through a structured session programme (currently Session 194) using Claude Chat (architecture, planning, governance), Claude Code (implementation), and Claude Cowork (cross-application tasks).

---

*README last updated: Session 194, 11 April 2026.*
