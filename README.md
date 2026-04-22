# Ontara Platform — SysML v2 Model and Tooling Repository

## What Ontara Is

**Ontara** is a service system development, delivery, and execution platform, particularly strong in supporting regulated care service delivery. A model serves as the single source of truth for what a service business is, how it works, what rules govern it, and how the technology platform supports it. The model *generates* the running system rather than merely documenting it, and *comprehends itself* — it can explain what it contains and why.

## Architecture

Ontara is organised by two orthogonal commitments: **eight ontological strata** running vertically, and **two sides** (business and system) running through the strata where they are divided — together forming the **stratified two-side architecture**.

| # | Stratum | Role |
|---|---|---|
| 1 | **Foundation** | Upper and mid-level ontologies: BFO 2020, CCO, IAO, PROV-O. Shared. OWL 2 DL only. |
| 2 | **Domain Ontologies** | Business Domain Ontologies (BDO) and System Ontological Categories (SOC) — domain-specific specialisations of BFO. |
| 3 | **Metamodel** | BMM (36 part defs + 2 requirement defs across 6 concerns + Foundation::DomainRegistry) on the business side; SMM (components, workflows, reasoning metamodel) on the system side. |
| 4 | **Configured Model** | Tenant-specific instantiations: Domain Business Model (DBM) and Domain System Model (DSM). |
| 5 | **State Representation (SRS)** | All runtime instance content: DBR (versioned continuant trajectories, business side) and DSR (event-sourced occurrent log, system side). Persisted as KG triples with epistemic tagging. |
| 6 | **Substrate Reasoning** | Three Substrate Reasoner modules — Reflective (RSR), Projective (PSR), Generative (GSR). Unsided stratum: reasoners read across both sides of the substrate and produce platform-wide content. PSR authors Scenario Specification Records (SSRs). |
| 7 | **Binding Layer (BRL)** | Six external binding classes (ESB, APB, WRB, HMB, IGB, SGB) — sole authoritative write path to DBR and DSR. Applies canonical-edge contract, constraint gating, identity reconciliation, and provenance discipline. MRB (substrate-internal mapping binding) sits at stratum 5. |
| 8 | **Platform Realisation (PRS)** | Running infrastructure: GraphDB (KGR), EHRbase CDR, Ontara Customer Portal (OCP), Ontara Developer Console (ODC), Terminology & Information Carriers (TIC), SysML v2 tooling, Ontara Simulation Runner (OSR), Ontara Surface Simulator (OSS), Temporal Workflow Engine (TWE). |

The **Formalism Governance Zone (FGZ)** governs the dual-formalism discipline — OWL 2 DL canonical, SysML v2 engineering projection — across strata 2 through 4. The knowledge graph (OWL 2 DL in GraphDB) is the canonical store; SysML v2 is the engineering projection. BFO 2020 is the mandatory upper ontology; PROV-O provides provenance tracking.

## Repository Structure

```
gsl-sysml-model/
├── model/                          SysML v2 model files (source of truth)
│   ├── gendersense.sysml           Root package — imports all domain packages
│   ├── business-model.sysml        BMM: 36 part defs + 2 requirement defs across 6 concern packages
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
├── instruction-sets/               Disposable Code instruction sets (ephemeral; not committed)
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

## Current State (Session 254, April 2026)

- **Eight-stratum architecture** (Sessions 232–236, v3.0.0 diagram). Extended from six to eight strata: Substrate Reasoning (stratum 6, unsided since S246), Binding Realisation Layer / BRL (stratum 7), Platform Realisation / PRS (stratum 8). The Formalism Boundary Layer (FBL) renamed to Formalism Governance Zone (FGZ). BRL has six external binding classes (ESB, APB, WRB, HMB, IGB, SGB); MRB sits at stratum 5 as substrate-internal mapping.
- **Contraction and landing phase active from S241.** V1 acceptance specification produced (S241). Stratum and tenant landing registers established (S241). Workflow Guide updated to v4 (S241) with contraction discipline, corpus sweep obligation, and governance word-limit discipline. Governance sweep completed S252.
- **Foundations papers fully complete** (W-049 closed). Architecture Principles v5.1 (S231): strengthened A4 (stratified two-side architecture), KG-canonical binding (B22), coordinate framework binding (A12), SRS/PRS strata named, §5.6a absorbing modelling-strategy content. Platform Modelling Strategy v5 dissolved (S231) — content absorbed into AP v5.1. SBMM v4 (S218): General/Tailored sub-structuring. Five-principle unification hypothesis Tests 1–3 passed.
- **Stage 9 architectural foundation complete** (Sessions 192–236). Six foundation papers establish the basis for Stage 9: *Connecting the Stacks* (S192–193); *BS Substrate and Bindings* (S197, establishing DBR/DSR); *The Architect-Analyst Workspace* (S198/S200); *Surface Families* (S199, seven-user-band framing and headless five-layer architecture); *BRL and Experience-API* (S234); *BRL Binding Class Specifications* workshop (S236). Surface design work underway under W-084: cafe band 1 (S248), cafe bands 2–3 (S249), Paws band 1 (S251), Paws bands 2–3 (S254). Multi-axis status primitive (B71/B72) specified S253; Ontara Surface Simulator (OSS, I21) committed as first-class PRS component S251.
- **Stage 8 — Ontara Portal formally closed** (Sessions 175–185). Auth, domain management, 10-module catalogue, two lifecycle state machines, progressive governance with 20 typed constraints (8 hard, 6 soft, 6 graded), promotion/demotion, simulation with comparative analytics, production visual treatment. Stage 9 portal reframing pending (substrate replacement SQLite → KG-resident DBR/DSR).
- **Ears clinical domain intake complete** (Sessions 160–168). Coverage map (86.2% Full), ~83 reasoning instance individuals, HermiT CONSISTENT on 13-file stack, SPARQL suite 66 queries.
- **Ontology stack:** 13-file stack, HermiT CONSISTENT. SPARQL validation suite: 66 queries in 12 groups. Round-trip diff: 288 semantic units.
- **Console** has 13 views including 3D weighted relationship graph, visual architecture map, and Reasoning Vocabulary Explorer. BMM structurally complete — 36 part defs + 2 requirement defs, 96 weighted relationships.
- **Vision and Architecture Reference** at v14 (Session 243, full rewrite against eight-stratum architecture and landing posture). Next refresh due ~S255.

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

The Obsidian vault (not in this repo) contains ~262 registered design concepts across 16 sections (A–P), 42 discussion papers, ~253 session reports (Sessions 28–S253), 4 active EIL entries (with ~37 archived stubs), and the full governance structure including an Observation and Watchpoint Register. The vault is under separate git version control.

Key documents: Strategic Reference, Vision and Architecture Reference (v14), Master Concept Register, Development Workflow Guide (v4), Architecture Principles (v5.1), Business Metamodels (v4), V1 Acceptance Specification, Stratum Landing Register, Tenant Landing Register.

## Development Methodology

Three governing principles:

1. **Cross-domain validation** — every meta model concept must validate in at least two demonstrator domains.
2. **Co-evolution of model and tooling** — no modelling without the tool that makes it legible; no tool without model content that exercises it.
3. **Non-constraining architecture** — decisions should not foreclose future development paths.

Development is conducted through a structured session programme (currently Session 254) using Claude Chat (architecture, planning, governance), Claude Code (implementation), and Claude Cowork (cross-application tasks). From Session 241 the project is in a contraction and landing phase, with all new work tested against v1 acceptance criteria.

---

*README last updated: Session 254, 22 April 2026.*
