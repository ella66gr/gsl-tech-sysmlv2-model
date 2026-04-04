# Ontara Platform — SysML v2 Model and Tooling Repository

## What Ontara Is

**Ontara** is a service system development, delivery, and execution platform, particularly strong in supporting regulated care service delivery. A model serves as the single source of truth for what a service business is, how it works, what rules govern it, and how the technology platform supports it. The model *generates* the running system rather than merely documenting it, and *comprehends itself* — it can explain what it contains and why.

**GenderSense Limited (GSL)**, a private gender-affirming healthcare service, is the primary motivating use case and first production tenant. Ontara is the platform; GSL is one tenant of that platform.

## Architecture

Ontara maintains two distinct meta models connected by explicit horizontal mappings:

- **Business Meta Model (BMM)** — what a service business *is*. 34 elements across six concerns (ServiceConcept, ActivityModel, ResourcePlanning, FinancialPlanning, GovernanceMapping, StakeholderModel).
- **System Meta Model (SMM)** — how a business system *works*. Currently: ArchitecturalSection (20 section instances describing the dual-stack architecture).

The **dual-stack architecture** (Session 73) pairs these as two parallel vertical stacks with horizontal mappings at every tier. The knowledge graph (OWL 2 DL in GraphDB) serves as the eventual canonical store, with SysML v2 as an engineering projection. BFO 2020 is the mandatory upper ontology.

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
│   ├── imports/                    External ontologies (BFO 2020, CCO, IAO)
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
| Ontological formalism | OWL 2 DL — BFO 2020 + CCO + IAO |
| Triple store | GraphDB Free 10.x (OWL-Horst reasoning) |
| Ontology authoring | Protégé 5.6+ |
| OWL reasoning | Robot 1.9.8 (wrapping HermiT) |
| Console | SvelteKit + Svelte 5 runes + Flowbite Svelte + Tailwind v4 |
| 3D relationship graph | 3d-force-graph + Three.js r183 + three-spritetext |
| Generation pipeline | Python (7 generators + OWL pipeline reading .sysml, producing JSON/TS/Mermaid/Turtle) |
| Coffee Shop app | SvelteKit + Temporal + XState v5 + EHRbase CDR + PostgreSQL |
| Knowledge base | Obsidian (separate vault, not in this repo) |
| Development | macOS, VS Code |

## Current State (Session 134, April 2026)

- **Stage 5 — Knowledge Graph Implementation** Phases 1 and 2 are both formally closed. Phase 1 (taxonomy, Sessions 100–107): 34 OWL classes with BFO/CCO/IAO parentage, correspondence graph, generation pipeline, GraphDB loaded and validated. Phase 2 (ontological enrichment, Sessions 111–120): 6 concern-group disjointness declarations, 14 object properties (pipeline-generated from SysML typed refs), 9 cardinality restrictions, 96 reified weighted relationship individuals (702 triples), Robot + HermiT full OWL 2 DL consistency checking. Correspondence graph: 1,378 triples. 10-file ontology stack. 23-query SPARQL validation suite (5 groups, all passing).
- **Governance workstream** — vocabulary tier implemented and validated. Deontic governance architecture (Session 121), OWL class design (Session 125), governance ontology Turtle implemented (Session 126): `ontara-governance.ttl` in separate `ontara-gov:` namespace, 19 classes, 6 enum classes, 20 object properties, 16 data properties. MVP CQC Regulation 12 test individuals validated. First hand-authored ontology module outside BMM namespace.
- **Console navigation context** (Sessions 132–134): global NavigationStore with semantic breadcrumb trail, page state capture/restore, journey export to clipboard. Six routes migrated (glossary, ontology, catalogue, governance, coverage, relationships). NavLink replaces per-route `from` parameter workarounds.
- **BMM structurally complete** at General level — 34 elements, 96 weighted relationships, full comprehension metadata (34/34 @UserFacing, @PurposiveDescription, @Comprehension, @BfoType).
- **Console** has 13 views including an interactive 3D weighted relationship graph, a spatial visual architecture map, and an ontological hierarchy view with KG status panel.
- **Three demonstrator domains** validated (Cafe, Suds, Paws), with Ears (community ear care) outlined as a fifth domain (second clinical).

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

# Run OWL 2 DL reasoner (requires Robot JAR in tools/)
python scripts/reason_kg.py

# Run reasoner and save summary for console
python scripts/reason_kg.py --save-summary

# Run reasoner with violation test
python scripts/reason_kg.py --test-violation

# Validate knowledge graph (23-query SPARQL suite)
python scripts/validate_kg.py

# Reload pipeline output into GraphDB and validate
python scripts/validate_kg.py --load
```

## Companion Knowledge Base

The Obsidian vault (not in this repo) contains ~200 registered design concepts, 26 discussion papers, ~106 session reports (Sessions 28–133), and the full governance structure. The vault is under separate git version control.

Key documents: Strategic Reference, Master Concept Register, Development Workflow Guide, Architecture Principles (v3), SysML Modelling Strategy (v3), Service Business Meta Modelling (v2).

## Development Methodology

Three governing principles:

1. **Cross-domain validation** — every meta model concept must validate in at least two demonstrator domains.
2. **Co-evolution of model and tooling** — no modelling without the tool that makes it legible; no tool without model content that exercises it.
3. **Non-constraining architecture** — decisions should not foreclose future development paths.

Development is conducted through a structured session programme (currently Session 134) using Claude Chat (architecture, planning, governance), Claude Code (implementation), and Claude Cowork (cross-application tasks).

---

*README last updated: Session 134, 4 April 2026.*
