# Ontara Platform — SysML v2 Model and Tooling Repository

## What Ontara Is

**Ontara** is a service system development, delivery, and execution platform, particularly strong in supporting regulated care service delivery. A model serves as the single source of truth for what a service business is, how it works, what rules govern it, and how the technology platform supports it. The model *generates* the running system rather than merely documenting it, and *comprehends itself* — it can explain what it contains and why.

## Architecture

Ontara maintains an architecture with two distinct 'stacks' modelling both the business (service) itself and the systems of the business, connected by explicit horizontal mappings. The architecture operates across four levels:

1. **Metamodels** — the templates defining what a model can contain. The **Business Meta Model (BMM)** defines what a service business model can contain: 34 elements across six concerns (ServiceConcept, ActivityModel, ResourcePlanning, FinancialPlanning, GovernanceMapping, StakeholderModel). The **System Meta Model (SMM)** defines what a service system model can contain: components, workflows, bindings, pattern instantiations, governance hooks, plus the reasoning metamodel as a cross-cutting SMM extension. Metamodels are static and have no runtime state of their own.
2. **Configured models** — a specific tenant's instantiation of the metamodel templates. The cafe Business Model (BM) and System Model (SM); the Paws BM and SM; the Suds BM and SM; eventually the GSL BM and SM. Configured models change only when the architect or tenant admin edits configuration.
3. **Runtime instances** — the individuated, time-stamped entities that come into existence as a configured business runs: orders, workflow executions, governance evaluations, simulation runs. These are held in the Business Runtime (BR) and System Runtime (SR) substrate.
4. **Realising components** — the external systems and infrastructure that bindings connect to: Temporal clusters, EHRbase CDR, PostgreSQL, payment processors. Their internal state is observed via binding pipelines and projected into BR/BS.

The **dual-stack architecture** (Session 73) pairs the BM/SM stacks as two parallel vertical structures with horizontal mappings at each tier. The knowledge graph (OWL 2 DL in GraphDB) serves as the eventual canonical store, with SysML v2 as an engineering projection. BFO 2020 is the mandatory upper ontology; PROV-O provides provenance tracking at the platform level.

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

## Current State (Session 226, April 2026)

- **All three foundations papers complete** (W-049 closed). Architecture Principles v5 (Sessions 210–211): strengthened A4 (stratified two-side architecture, six strata, two sides, ten loci), KG-canonical binding (B22), coordinate framework binding (A12), BS → SR rename, SRS/PRS strata named, five-principle unification hypothesis Test 1 passed. Platform Modelling Strategy v5 (S216): KG-canonical inversion formalised (OWL 2 DL canonical; SysML v2 engineering projection). SBMM v4 (S218): General/Tailored sub-structuring with four-criterion framework and 50-element audit; Tests 2 and 3 of unification hypothesis passed.
- **Eighth systematic documentation review complete** (Sessions 224–225, W-061). F1–F65 findings across Tier 1 reference documents, Tier 2 foundations papers, and Tier 3 concept-graph sweep. Reference corpus now fully characterised; fix batch (W-068/W-069) in execution at S226.
- **Stage 9 architectural foundation complete** (Sessions 192–200). Four foundation papers establish the basis for Stage 9. *Connecting the Stacks* (S192–193) defines eight design decisions and seven open questions. *BS Substrate and Bindings* (S197) establishes BR, SR, and bindings as first-class elements. *Surface Families* (S199) establishes the seven-user-band framing, headless five-layer architecture, and state placement discipline. *The Architect-Analyst Workspace* (S198, revised S200) locates the architect-analyst surface at user band 6.
- **Stage 8 — Ontara Portal formally closed** (Sessions 175–185, W-037). Auth, domain management, 10-module catalogue, two lifecycle state machines, progressive governance with 20 typed constraints (8 hard, 6 soft, 6 graded), promotion/demotion, simulation with comparative analytics, production visual treatment.
- **Ears clinical domain intake complete** (Sessions 160–168). Coverage map (86.2% Full), ~83 reasoning instance individuals, HermiT CONSISTENT on 13-file stack, SPARQL suite 66 queries.
- **Stage 7 — Reasoning Metamodel** (Sessions 148–158) formally closed S159. `ontara-reasoning.ttl`: 42 OWL classes, 15 named individuals, 40 object + 10 datatype properties. Three-way constraint hierarchy, decision mode routing, SEPIO evidence architecture.
- **Foundations papers:** Architecture Principles v5 (S211), Platform Modelling Strategy v5 (S216), Service Business Meta Modelling v4 (S218).
- **Ontology stack:** 13-file stack, HermiT CONSISTENT. SPARQL validation suite: 66 queries in 12 groups. Round-trip diff: 288 semantic units.
- **Console** has 13 views including 3D weighted relationship graph, visual architecture map, and Reasoning Vocabulary Explorer. BMM structurally complete — 34 core elements, 96 weighted relationships.
- **Vision and Architecture Reference** at v12 (Session 201). Refresh to v13 pending (W-059) once reference corpus fixes are applied.

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

The Obsidian vault (not in this repo) contains ~232 registered design concepts across 16 sections (A–P), 42 discussion papers, ~225 session reports (Sessions 28–S225), 37 live EIL entries (E001–E037), and the full governance structure including an Observation and Watchpoint Register (~110 items). The vault is under separate git version control.

Key documents: Strategic Reference, Vision and Architecture Reference (v12), Master Concept Register, Development Workflow Guide, Architecture Principles (v5), Platform Modelling Strategy (v5), Service Business Meta Modelling (v4), Modelling Paradigm Reference.

## Development Methodology

Three governing principles:

1. **Cross-domain validation** — every meta model concept must validate in at least two demonstrator domains.
2. **Co-evolution of model and tooling** — no modelling without the tool that makes it legible; no tool without model content that exercises it.
3. **Non-constraining architecture** — decisions should not foreclose future development paths.

Development is conducted through a structured session programme (currently Session 226) using Claude Chat (architecture, planning, governance), Claude Code (implementation), and Claude Cowork (cross-application tasks).

---

*README last updated: Session 226, 16 April 2026.*
