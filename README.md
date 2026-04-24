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
| 5 | **State Representation (SRS)** | All runtime instance content: DBR (versioned continuant trajectories, business side) and DSR (event-sourced occurrent log, system side). Persisted as KG triples with epistemic tagging. Canonical runtime instances carry multi-axis status — N named `StatusAxis` primitives (B71) per type, each advancing independently (B72). |
| 6 | **Substrate Reasoning** | Three Substrate Reasoner modules — Reflective (RSR), Projective (PSR), Generative (GSR). Unsided stratum: reasoners read across both sides of the substrate and produce platform-wide content. PSR authors Scenario Specification Records (SSRs). |
| 7 | **Binding Realisation Layer (BRL)** | Six external binding classes (ESB, APB, WRB, HMB, IGB, SGB) — sole authoritative external write path to DBR and DSR. Applies canonical-edge contract, constraint gating, identity reconciliation, and provenance discipline. MRB (substrate-internal mapping binding) sits at stratum 5. |
| 8 | **Platform Realisation (PRS)** | Running infrastructure: GraphDB (KGR), EHRbase CDR, Ontara Tenant Portal (OTP), Ontara Developer Console (ODC), Terminology & Information Carriers (TIC), SysML v2 tooling, Ontara Simulation Runner (OSR), Ontara Surface Simulator (OSS), Temporal Workflow Engine (TWE). |

The **Formalism Governance Zone (FGZ)** governs the dual-formalism discipline — OWL 2 DL canonical, SysML v2 engineering projection — across strata 2 through 4. The knowledge graph (OWL 2 DL in GraphDB) is the canonical store; SysML v2 is the engineering projection. BFO 2020 is the mandatory upper ontology; PROV-O provides provenance tracking.

## Repository Structure

```
gsl-sysml-model/
├── model/                          SysML v2 model files (engineering projection of KG-canonical content)
│   ├── gendersense.sysml           Root package — imports all domain packages
│   ├── business-model.sysml        BMM: 36 part defs + 2 requirement defs across 6 concern packages
│   ├── business-scenarios.sysml    Business scenario definitions
│   ├── business-strategy.sysml     Business strategy definitions
│   ├── architectural-structure.sysml  SMM: ArchitecturalSection + 20 instances
│   ├── canonical-runtime.sysml     Multi-axis status primitive (B71/B72) — CanonicalRuntimeType, StatusAxis, ValueSpace, AxisTransition; Paws Booking five-axis declaration
│   ├── pattern-catalogue.sysml     22 validated patterns, 8 principles
│   ├── foundation.sysml            MetadataLibrary, CommonTypes, StatePatterns
│   ├── enterprise.sysml            Organisation, Regulation, Strategy, Risk
│   ├── knowledge.sysml             CDS, Constraints, Logic, Decisions
│   ├── service-delivery.sysml      Clinical pathways, consent, governance
│   ├── platform.sysml              Portal, EHR, messaging, integration
│   └── operations.sysml            Finance, people, reporting
├── exercises/                      Demonstrator domains (SysML-present)
│   ├── coffeeshop-demonstrator/    Cafe — full-stack reference implementation
│   ├── suds-demonstrator/          Suds — batch processing launderette
│   └── paws-demonstrator/          Paws — appointment-based dog grooming
│                                   (Ears — clinical domain; analytical intake and surface design in vault;
│                                   SysML folder not yet materialised.)
├── scripts/                        Generation pipeline (Python)
│   ├── gen_model_introspection.py  Console data generator (JSON from SysML)
│   ├── gen_owl_pipeline.py         OWL/Turtle generator (BMM → ontara-bmm.ttl)
│   ├── gen_concept_graph.py        Mermaid + Obsidian concept graph
│   ├── gen_package_hierarchy.py    Package hierarchy generator
│   ├── gen_system_manifest.py      System manifest generator
│   ├── gen_constraint_evaluator.py Constraint evaluator (TypeScript)
│   ├── gen_decision_table_evaluator.py  Decision table evaluator (TypeScript)
│   ├── sysml_parser.py             SysML v2 parser (shared across generators)
│   ├── projection_engine.py        Projection engine
│   ├── validate_kg.py              Knowledge graph validation (SPARQL suite)
│   ├── reason_kg.py                OWL 2 DL reasoning (Robot + HermiT)
│   ├── diff_kg.py                  Round-trip diff engine (288 semantic units)
│   ├── kg_utils.py                 Shared KG utilities (GraphDB, SPARQL, IRI)
│   ├── setup_graphdb.py            GraphDB repository setup script
│   ├── ontara                      CLI entry point
│   └── archive-documentation.sh    Vault → repo archive helper
├── console/                        Ontara Console (SvelteKit + Svelte 5) — band 6/7 surface (partial)
│   ├── src/                        13 views: Home, Coverage Matrix, Package Navigator,
│   │                               Component Catalogue, Glossary, Governance, Meta-Model,
│   │                               Patterns, Domain Views, Weighted Relationship Graph (3D),
│   │                               Architecture (visual map), Ontology (BFO hierarchy + KG status),
│   │                               Reasoning Vocabulary Explorer
│   │   └── lib/                    Shared stores (NavigationStore), components (NavLink,
│   │                               Breadcrumb, NavigationProvider), types
│   └── static/data/                model-introspection.json (console data source)
├── portal/                         Ontara Portal (SvelteKit + Svelte 5 + SQLite) — band 5 surface
│   ├── src/
│   │   ├── routes/(app)/domains/   Domain dashboard, context, catalogue, simulations
│   │   └── lib/
│   │       ├── server/db/          SQLite schema, seed data, domain/module/context queries
│   │       ├── server/modules/     Server-side module operations
│   │       ├── server/simulation/  Batch event generation, metrics, simulation runs
│   │       ├── modules/            Shared logic: lifecycle, composition, epistemic, impact, metrics
│   │       ├── context/            Svelte 5 reactive stores (auth, domain)
│   │       └── types.ts            All portal type definitions
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
│   ├── reference/                  SysML syntax reference, versioned snapshots, architecture diagrams
│   ├── archive/                    Legacy committed snapshots (predates vault/repo separation rule)
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
| Modelling language | SysML v2 (OMG ratified July 2025) — engineering projection of KG-canonical content |
| Modelling tool | Syside Modeler (VS Code extension) |
| Canonical ontological formalism | OWL 2 DL — BFO 2020 + CCO + IAO + PROV-O (core subset) |
| Triple store | GraphDB Free 10.x (OWL-Horst reasoning) |
| Ontology authoring | Protégé 5.6+ |
| OWL reasoning | Robot 1.9.8 (wrapping HermiT) — full OWL 2 DL consistency checking |
| Console | SvelteKit + Svelte 5 runes + Flowbite Svelte + Tailwind v4 |
| Portal | SvelteKit + Svelte 5 runes + Flowbite Svelte + Tailwind v4 + SQLite (better-sqlite3) |
| 3D relationship graph | 3d-force-graph + Three.js r183 + three-spritetext |
| Generation pipeline | Python (7 generators + OWL pipeline reading .sysml, producing JSON/TS/Mermaid/Turtle) |
| Coffee Shop app | SvelteKit + Temporal + XState v5 + EHRbase CDR + PostgreSQL |
| Knowledge base | Obsidian (separate vault, not in this repo) |
| Development | macOS, VS Code |

## Current State (Session 269, April 2026)

- **Eight-stratum architecture** (Sessions 232–236, v3.0.0 diagram). Substrate Reasoning (stratum 6, unsided since S246), Binding Realisation Layer / BRL (stratum 7), Platform Realisation / PRS (stratum 8). The Formalism Boundary Layer renamed to Formalism Governance Zone (FGZ). BRL has six external binding classes (ESB, APB, WRB, HMB, IGB, SGB); MRB sits at stratum 5 as substrate-internal mapping.
- **Contraction and landing phase active from S241.** V1 acceptance specification, stratum landing register, and tenant landing register established S241. Workflow Guide at v4 with contraction discipline, corpus sweep obligation (J16), and governance word-limit discipline. Plural non-GSL clinical demonstrators are the v1 clinical test ground, with Ears the furthest-progressed; GSL is the post-v1 production target.
- **Foundations papers complete at v5.3 / v5 / v15.** Architecture Principles v5.3 (S266 targeted extension — B71/B72 positioning, multi-axis status as generalised SRS feature, OSR/OSS as realising components). Business Metamodels v5 (S261 full conceptual rewrite integrating 43 sessions of architectural accumulation). Vision and Architecture Reference v15 (S256 full rewrite). Platform Modelling Strategy v5 dissolved S231 with content absorbed into AP.
- **User bands 1–3 design series complete across all four tenants.** Cafe (S248–S249), Paws (S251, S254), Suds (S262–S263), Ears (S264–S265). Fifteen-contract band 1 sets specified per tenant; composite-surface patterns validated across four domains; persistent-subject-record (D32) promoted to validated pattern with three sharpenings; four multi-axis affordance patterns characterised; clinical-encounter cluster contract ordering established; longitudinal-workflow infrastructure common across five workflow types.
- **Multi-axis status primitive (B71/B72)** specified S253; first SysML projection landed S255 in `canonical-runtime.sysml` with Paws `Booking` five-axis declaration. **Ontara Surface Simulator (OSS, I21)** committed S251 as the v1 surface realiser — shared platform infrastructure rendering tenant surface specifications interactively against the full experience-API / binding / workflow / substrate stack.
- **Stage 8 — Ontara Portal formally closed** (Sessions 175–185). Auth, domain management, 10-module catalogue, two lifecycle state machines, progressive governance with 20 typed constraints (8 hard, 6 soft, 6 graded), promotion/demotion, simulation with comparative analytics. Stage 9 portal reframing pending (substrate replacement SQLite → KG-resident DBR/DSR through bindings).
- **Ears clinical domain** analytical intake complete (Sessions 160–168; 86.2% Full coverage; ~83 reasoning instance individuals). Surface design complete bands 1–3 (S264–S265) — richest clinical test of the architecture with five-axis ClinicalEncounter, three-field orderingParty / actingParty / beneficiary vocabulary stress-tested against LPA scenarios, meta-constraint / triage-before-booking pattern, composite-setting-modifier (BP-09) validated as parameterised-variant realisation.
- **Ontology stack:** 13-file stack, HermiT CONSISTENT. SPARQL validation suite 66 queries in 12 groups. Round-trip diff 288 semantic units.
- **Console** has 13 views including 3D weighted relationship graph, visual architecture map, and Reasoning Vocabulary Explorer. BMM structurally complete — 36 part defs + 2 requirement defs, 96 weighted relationships.
- **Governance housekeeping** (S266–S268): AP v5.3 propagation across register, V&A, and v1 acceptance; glossary refreshed with nine new entries including B61, B69, D32, D33, D34, J19, OSS; thirteen new concept-graph notes created; W-102 unescaped-pipe-in-wikilink sweep closed on evidence across seven target documents.

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

The Obsidian vault (not in this repo) contains ~265 registered design concepts across 16 sections (A–P) in four tiers, ~50 discussion papers with stratum-locus-prefixed naming (foundation / model / substrate / reasoning / surface / platform), ~267 session reports (Sessions 28–S268), ~98 concept-graph notes (patterns, principles, concepts, domains, deferred), 2 active EIL entries (with ~37 archived stubs), and the full governance structure including an Observation and Watchpoint Register. The vault is under separate git version control.

Key documents: Strategic Reference, Vision and Architecture Reference (v15), Master Concept Register, Development Workflow Guide (v4), Architecture Principles (v5.3), Business Metamodels (v5), Glossary, V1 Acceptance Specification, Stratum Landing Register, Tenant Landing Register, Emergent Ideas Log, Work Item Tracker.

## Development Methodology

Three governing principles:

1. **Cross-domain validation** — every meta model concept must validate in at least two demonstrator domains.
2. **Co-evolution of model and tooling** — no modelling without the tool that makes it legible; no tool without model content that exercises it.
3. **Non-constraining architecture** — decisions should not foreclose future development paths.

Development is conducted through a structured session programme (currently Session 269) using Claude Chat (architecture, planning, governance), Claude Code (implementation), and Claude Cowork (cross-application tasks). From Session 241 the project is in a contraction and landing phase: the default response to an emergent possibility is capture in the Emergent Ideas Log, not diversion of landing work, with all new work tested against v1 acceptance criteria.

---

*README last updated: Session 269, 24 April 2026.*
