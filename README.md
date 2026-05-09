# Ontara Platform — SysML v2 Model and Tooling Repository

## What Ontara Is

**Ontara** is a service system development, delivery, and execution platform, particularly strong in supporting regulated care service delivery. A model serves as the single source of truth for what a service business is, how it works, what rules govern it, and how the technology platform supports it. The model *generates* the running system rather than merely documenting it, and *comprehends itself* — it can explain what it contains and why.

Ontara is not the name of one component. It is the name for the whole: every stratum from the upper ontologies that ground it, through the formalism governance zone, the business and system metamodels, tenant-configured models, the runtime substrate, binding realisation, and the user-, operator-, and developer-facing surfaces.

## Architecture

Ontara is organised by two orthogonal commitments: **eight ontological strata** running vertically, and **two sides** (business and system) running through the strata where they are divided — together forming the **stratified two-side architecture (A4)**.

| # | Stratum | Role |
|---|---|---|
| 1 | **Foundation** | Upper and mid-level ontologies: BFO 2020, CCO, IAO, PROV-O. Shared. OWL 2 DL only. |
| 2 | **Domain Ontologies** | Business Domain Ontologies (BDO) and System Ontological Categories (SOC) — domain-specific specialisations of BFO. |
| 3 | **Metamodel** | BMM (34 General `part def`s, 96 weighted relationships, across 6 concerns) on the business side; SMM (components, workflows, reasoning metamodel) on the system side. |
| 4 | **Configured Model** | Tenant-specific instantiations: Domain Business Model (DBM) and Domain System Model (DSM). |
| 5 | **State Representation (SRS)** | All runtime instance content: DBR (versioned continuant trajectories, business side) and DSR (event-sourced occurrent log, system side). Persisted as KG triples with epistemic tagging. Runtime instances carry multi-axis status — N named `StatusAxis` primitives (B71) per type, each advancing independently (B72). |
| 6 | **Substrate Reasoning** | Three Substrate Reasoner modules — Reflective (RSR), Projective (PSR), Generative (GSR). Unsided stratum: reasoners read across both sides and produce platform-wide content. PSR authors Scenario Specification Records (SSRs). |
| 7 | **Binding Realisation Layer (BRL)** | Six external binding classes (ESB, APB, WRB, HMB, IGB, SGB) — sole authoritative external write path to DBR and DSR. Applies canonical-edge contract, constraint gating, identity reconciliation, and provenance discipline. MRB (substrate-internal mapping binding) sits at stratum 5. |
| 8 | **Platform Realisation (PRS)** | Running infrastructure: GraphDB (KGR), EHRbase CDR, Ontara Developer Console (ODC), Ontara Portal (OTP), Ontara Simulation Runner (OSR), Ontara Surface Simulator (OSS), Temporal Workflow Engine (TWE), Terminology & Information Carriers (TIC), SysML v2 tooling. |

The **Formalism Governance Zone (FGZ)** governs the dual-formalism discipline — OWL 2 DL canonical, SysML v2 engineering projection — across strata 2 through 4. The knowledge graph (OWL 2 DL in GraphDB) is the canonical store; SysML v2 is the engineering projection. BFO 2020 is the mandatory upper ontology; PROV-O provides provenance tracking.

The **Integrated Trust, Security, Privacy & Governance Framework (IGF)** is a cross-stratum governance zone — not a stratum cell but a zone overlay spanning all eight strata — governing platform-wide security, identity, data governance, and regulatory compliance posture. IGF scoped at S376; discussion paper in progress (W-161).

## Repository Structure

```
gsl-sysml-model/
├── model/                          SysML v2 model files (engineering projection of KG-canonical content)
│   ├── gendersense.sysml           Root package — imports all domain packages
│   ├── business-model.sysml        BMM: 34 General part defs across 6 concern packages + 96 weighted relationships
│   ├── business-scenarios.sysml    Business scenario definitions
│   ├── business-strategy.sysml     Business strategy definitions
│   ├── architectural-structure.sysml  SMM: ArchitecturalSection + instances
│   ├── canonical-runtime.sysml     Multi-axis status primitive (B71/B72) — CanonicalRuntimeType, StatusAxis,
│   │                               ValueSpace, AxisTransition; Paws Booking five-axis declaration
│   ├── pattern-catalogue.sysml     Validated patterns + architectural principles
│   ├── foundation.sysml            MetadataLibrary, CommonTypes, StatePatterns
│   ├── enterprise.sysml            Organisation, Regulation, Strategy, Risk
│   ├── knowledge.sysml             CDS, Constraints, Logic, Decisions
│   ├── service-delivery.sysml      Clinical pathways, consent, governance
│   ├── platform.sysml              Portal, EHR, messaging, integration
│   └── operations.sysml            Finance, people, reporting
├── exercises/                      Demonstrator domain projections
│   ├── coffeeshop-demonstrator/    Cafe — full-stack reference implementation (SvelteKit + Temporal + EHRbase)
│   ├── paws-demonstrator/          Paws — appointment-based dog grooming (SysML projection)
│   ├── suds-demonstrator/          Suds — batch processing launderette (SysML projection)
│   └── minds-demonstrator/         Minds — counselling under professional-body regulation (SysML projection)
│                                   (Ears — clinical domain; SysML folder not yet materialised;
│                                   analytical intake, reasoning instances, and surface design in vault.)
├── scripts/                        Generation pipeline and tooling (Python)
│   ├── gen_model_introspection.py  Console data generator (JSON from SysML)
│   ├── gen_owl_pipeline.py         OWL/Turtle generator (BMM → ontara-bmm.ttl)
│   ├── gen_concept_graph.py        Mermaid + Obsidian concept graph
│   ├── gen_package_hierarchy.py    Package hierarchy generator
│   ├── gen_system_manifest.py      System manifest generator
│   ├── gen_constraint_evaluator.py Constraint evaluator (TypeScript)
│   ├── gen_decision_table_evaluator.py  Decision table evaluator (TypeScript)
│   ├── evaluate_automator.py       Automator evaluation script
│   ├── sysml_parser.py             SysML v2 parser (shared across generators)
│   ├── projection_engine.py        Projection engine
│   ├── validate_kg.py              Knowledge graph validation (SPARQL suite)
│   ├── reason_kg.py                OWL 2 DL reasoning (Robot + HermiT)
│   ├── diff_kg.py                  Round-trip diff engine
│   ├── kg_utils.py                 Shared KG utilities (GraphDB, SPARQL, IRI)
│   ├── setup_graphdb.py            GraphDB repository setup script
│   ├── substrate-authoring/        Substrate document authoring helpers and one-off scripts
│   ├── ontara                      CLI entry point
│   └── archive/                    Archived superseded generators (with provenance)
├── console/                        Ontara Developer Console (ODC) — SvelteKit + Svelte 5 — band 6/7 surface
│   ├── src/routes/                 12 routes: Home, Architecture, Catalogue, Coverage, Domains,
│   │                               Glossary, Governance, Meta-Model, Ontology, Packages, Patterns,
│   │                               Relationships (3D weighted graph)
│   └── static/data/                model-introspection.json (console data source)
├── portal/                         Ontara Portal (OTP) — SvelteKit + Svelte 5 — band 5 surface
│   ├── src/routes/(app)/
│   │   ├── domains/                Domain dashboard, context, catalogue, simulations
│   │   ├── substrate/              Substrate editor — TipTap/ProseMirror editor for substrate-canonical documents
│   │   └── profile/                User profile
│   └── data/                       portal.db (SQLite — portal app state, auto-created, gitignored)
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
│   │   └── ontara-domain.ttl       Domain identity vocabulary
│   ├── reasoning/                  Hand-authored reasoning metamodel vocabulary
│   │   ├── ontara-reasoning.ttl    42 classes, 15 named individuals, 40 object + 10 datatype properties
│   │   └── ears-reasoning-instances.ttl  ~83 Ears clinical domain reasoning instances
│   ├── imports/                    External ontologies (BFO 2020, CCO, IAO, PROV-O core subset)
│   ├── config/                     Mapping config (mapping-rules.yaml, cco-iri-lookup.json)
│   └── catalog-v001.xml            Robot IRI resolution catalogue
├── documentation/
│   ├── reference/                  SysML syntax reference, KerML reserved words, architecture diagrams
│   │   ├── gsl-sysml-v2-syntax-reference.md   Stable SysML syntax reference (check before writing .sysml)
│   │   ├── KerML-Reserved-Words.md            KerML reserved words (check before naming part defs)
│   │   ├── ONTARA ARCHITECTURE 3.graffle      Architecture diagram v3.4.x (OmniGraffle source)
│   │   └── ONTARA ARCHITECTURE 3.pdf          Architecture diagram (PDF export)
│   ├── archive/                    Legacy committed snapshots (predates vault/repo separation rule)
│   └── generated/                  Generated documentation
├── libraries/                      Shared SysML metadata definitions
├── concept-graph/                  Concept graph source
├── tools/                          External tool binaries (robot.jar, etc.)
├── instruction-sets/               Disposable Code instruction sets (ephemeral; not committed)
├── spikes/                         Experimental spikes
├── CLAUDE.md                       Claude Code project context (operational detail for Code sessions)
└── .claude/skills/                 Claude Code skills (build-substrate-doc, regen-markers, resolver-debug, migration-apply)
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
| Developer Console | SvelteKit + Svelte 5 runes + Flowbite Svelte + Tailwind v4 |
| Portal (substrate editor + domain surfaces) | SvelteKit + Svelte 5 runes + Flowbite Svelte + Tailwind v4 + SQLite (better-sqlite3) |
| Substrate editor | TipTap + ProseMirror (in the Portal at `/substrate/{slug}`) |
| 3D relationship graph | 3d-force-graph + Three.js + three-spritetext |
| Generation pipeline | Python (7 generators + OWL pipeline reading .sysml, producing JSON/TS/Mermaid/Turtle) |
| Canonical data store (concepts, work tracker, substrate docs) | PostgreSQL 16 (`ontara` database, Homebrew, localhost:5432) |
| Resolver service | FastAPI at localhost:7300; auto-started via launchd |
| Cafe demonstrator app | SvelteKit + Temporal + XState v5 + EHRbase CDR + PostgreSQL |
| Knowledge base | Obsidian (separate vault repo, not in this repo) |
| Development | macOS, VS Code |

## PostgreSQL `ontara` Database

The canonical `ontara` database (Homebrew PostgreSQL 16, `localhost:5432`) lives in the vault at `02 ONTARA/db/`. It holds:

- **Concept inventory** — all platform concepts with relationships, BFO types, and cross-domain validation evidence.
- **Work governance** — work item tracker (active items, DCR, OW register, EIL, risks).
- **Platform metadata** — strata, tenants, tenant–stratum landing state, tech stack, modelling paradigms.
- **Substrate document content** — `block`, `block_edge`, `document`, `document_block`, `revision` tables. Substrate-canonical documents (all major architecture references) are authored here and rendered to vault markdown by the resolver.

The **resolver service** (`http://localhost:7300`) is the authoritative write surface for all PostgreSQL-backed content. Direct SQL writes to marker-bound or substrate tables bypass the resolver's reconciliation and regen hooks and leave markdown stale. Writes go through the resolver admin UI or JSON API.

Liveness: `curl http://localhost:7300/healthz` → `{"status":"ok"}`.

## Substrate-Canonical Documents

A significant and growing class of vault reference documents are **substrate-canonical**: their source of truth is the PostgreSQL `block`/`block_edge`/`document` tables, and the vault `.md` file is a rendered surface produced by the resolver. The vault file is read-only from an editing perspective; changes flow through the substrate editor in the Portal (`http://localhost:5174/substrate/{slug}`) or via build scripts.

Documents in this class include: the Architecture & Principles family (eight sub-references + host), the BMM family (main, vocabulary, operational, domain clinical example), V1 Acceptance Specification, Stratum Landing Register, Tenant Landing Register, Modelling Paradigm Reference, and most major governance references.

## Key Commands

```bash
# Generate console data from SysML model
python3 scripts/gen_model_introspection.py --save

# Sync generated data to console
cd console && pnpm refresh-data

# Generate OWL/Turtle from BMM
python3 scripts/gen_owl_pipeline.py

# Run the console (dev mode — http://localhost:5173)
cd console && pnpm dev

# Run the portal (dev mode — http://localhost:5174)
cd portal && pnpm dev

# Resolver liveness
curl http://localhost:7300/healthz

# Restart resolver
launchctl kickstart -k gui/501/dev.ontara.resolver

# Run OWL 2 DL reasoner (requires tools/robot.jar; does NOT require GraphDB)
python3 scripts/reason_kg.py

# Validate knowledge graph (SPARQL suite; requires GraphDB at localhost:7200)
python3 scripts/validate_kg.py

# Reload full ontology stack into GraphDB and validate
python3 scripts/validate_kg.py --load

# Round-trip diff (compare pipeline output against GraphDB)
python3 scripts/diff_kg.py
```

Full command catalogues — resolver, marker regen, substrate build scripts, generator flags — are in `CLAUDE.md` and in the vault shell command reference.

## Companion Knowledge Base

The Obsidian vault (separate repo at `/Users/ellagreen/Obsidian/GenderSense`) is the primary home for all vault-resident material: foundations papers, architectural references (all now substrate-canonical, authored in the PostgreSQL `ontara` database and rendered to markdown), session reports and preparation notes, concept-graph notes (patterns, principles, concepts, domain notes), the work item tracker, the EIL, the workflow guide, the PostgreSQL database repository (`02 ONTARA/db/`), and supporting references.

Key documents in the vault:

| Document | Role |
|---|---|
| Architecture and Principles (host + 6 sub-references) | Canonical architectural commitments — 14 Tier-1 principles, 8-stratum two-side architecture, FGZ, BRL, reasoning metamodel, surface architecture. Substrate-canonical. |
| Governance and Clinical | Deontic governance architecture, satisfy traceability, clinical data (openEHR), IGF direction. Substrate-canonical. |
| Business Meta Model family (main + vocabulary + operational + domain clinical example) | 34 BMM General part defs, 6 concerns, annotation discipline, domain clinical mapping. Substrate-canonical. |
| V1 Acceptance Specification | Acceptance criteria for the five-tenant v1 milestone. Substrate-canonical. |
| Stratum Landing Register | Stratum-by-stratum landing state. Substrate-canonical. |
| Tenant Landing Register | Tenant × stratum landing grid. Substrate-canonical. |
| Workflow Guide | Operating agreement — session lifecycle, file handling, workflow discipline. |
| Work Item Tracker | Active work items, DCR, OW register. Database-backed marker sections. |
| Glossary | Full concept inventory (markdown export from PostgreSQL). Database-backed. |
| Emergent Ideas Log | Captured ideas in contraction discipline. Database-backed. |

The vault is under separate git version control (committed at every session close).

## Development Methodology

Three governing methodology principles (J-codes, Tier-1 binding):

1. **Cross-domain validation (J1)** — every metamodel concept must validate in at least two demonstrator domains before promotion.
2. **Co-evolution of model and tooling (J2)** — no modelling without the tool that makes it legible; no tool without model content that exercises it.
3. **Non-constraining architecture (J3)** — decisions should not foreclose future development paths.

Development is conducted through a structured session programme (currently Session 379) using Claude Chat (architecture, planning, governance), Claude Code (implementation), and Claude Cowork (cross-application tasks). From Session 241 the project is in a contraction and landing phase: the default response to any emergent possibility is capture in the Emergent Ideas Log, not diversion of landing work, with all new work tested against v1 acceptance criteria.

## Current State (Session 379, May 2026)

### Platform and architecture

- **Eight-stratum stratified two-side architecture** (A4, strengthened S208–S210). Architecture diagram at v3.4.1 (S372, OmniGraffle source in `documentation/reference/`). Sub-references authored S357–S364 as the Architecture & Principles family (W-139, nine stages): Stratified Architecture, Ontological Grounding, Canonicity and Formalism, SRS and Reasoning, Bindings and Realisation, Surfaces and Tooling, Governance and Clinical, plus the host document.
- **IGF (Integrated Trust, Security, Privacy & Governance Framework)** scoped at S376. Position framing complete; IGF reframed as cross-stratum governance zone (not a stratum cell). Discussion paper authoring in progress (W-161, Priority A). Architecture diagram revision to v3.5 (W-162) pending W-161.
- **Ontology stack:** 13-file stack, HermiT CONSISTENT. SPARQL validation suite across 12 groups. Round-trip diff engine operational.

### Substrate-canonical authoring

- **PostgreSQL `ontara` database** established as canonical content store from S290+. The resolver service at `localhost:7300` is the authoritative write surface. Substrate editor in the Portal (`localhost:5174/substrate/{slug}`) provides in-browser TipTap/ProseMirror editing.
- **Substrate-canonical document class** covers all major architecture references, the BMM family, V1 acceptance spec, stratum and tenant landing registers, and modelling paradigm reference. Build scripts in `db/exports/build-scripts/` serve as provenance; the resolver's render pipeline writes to vault on every update.
- **BMM family:** All four sub-references (main, vocabulary, operational, domain clinical example) migrated to substrate-canonical form (W-131, complete S353).

### Demonstrators and surface design

- **Five v1 demonstrator tenants:** Cafe (immediate retail), Paws (appointment-based personal service), Suds (batch processing), Ears (regulated clinical care), and Minds (counselling under professional-body regulation). All five have SysML projections; Minds demonstrator folder materialised.
- **User bands 1–3 design series complete across all five tenants** (Cafe S248–249, Paws S251/S254, Suds S262–S263, Ears S264–S265, Minds S270–S286). Fifteen-contract band-1 sets specified per tenant; persistent-subject-record (D32) validated pattern; clinical-encounter cluster contract ordering established; multi-axis status affordance patterns characterised.
- **User bands posture corpus review (W-119)** complete S378. 34 documents surveyed; three S1 findings (W-168, W-169, W-170 — posture reframe work, B/B/C priority).
- **Multi-axis status primitive (B71/B72)** specified S253; SysML projection in `canonical-runtime.sysml` with Paws Booking five-axis declaration. **Ontara Surface Simulator (OSS)** committed S251 as the v1 surface realiser.
- **GSL (GenderSense Limited)** remains the post-v1 production target. Not a v1 demonstrator. Ears is the v1 clinical demonstrator.

### Contraction posture

V1 acceptance: a locally-hosted platform running five concurrent tenant services, each able to simulate a period of operation, present band-appropriate surfaces, and answer queries about its performance. All Priority A work is tested against "does this block v1 landing?". Open Priority A items: W-161 (IGF discussion paper), W-162 (architecture diagram v3.5).

---

*README last updated: Session 379, 9 May 2026.*
