# Ontara — Claude Code Project Context

## What This Is

Ontara is a service system development and delivery platform built on SysML v2 and OWL 2 DL. The SysML model and the OWL ontology stack together are the single source of truth for platform structure — generators produce console data, evaluators, ontology files, and other downstream artefacts. The sole developer and architect is Ella Green.

Ontara is in its **contraction phase** (from S241), driving toward a v1 working prototype. V1 acceptance is defined in the vault at `02 ONTARA/01 Ontara START HERE/ontara-ref-v1-acceptance.md`. The v1 prototype is a locally-hosted platform running concurrent demonstrator tenants — currently Cafe, Paws, Suds, Ears, and Minds — each able to simulate a period of operation, present band-appropriate user surfaces, and answer queries about its performance. **GSL (GenderSense Limited)** is the production target *post-v1*; it is not a v1 demonstrator.

## Architecture in Brief

- **Two meta models:** Business Meta Model (BMM — what a service business *is*) and Service Meta Model (SMM — how a system *works*). They are distinct and connected by explicit mappings. Note: SMM was previously called BSMM (Business System Meta Model). Renamed S92. The SysML section name `bsmm-general-vocabulary` is a structural identifier and stays.
- **Eight strata** (per Architecture Principles v5.3 §3): Foundation → Domain Ontologies → Metamodel → Configured Model → State Representation (SRS) → Substrate Reasoning → Binding Realisation Layer (BRL) → Platform Realisation (PRS). Strengthened A4 (S208–S210) commits the Knowledge Graph as the canonical SRS substrate (B22).
- **Five v1 demonstrator tenants:** Cafe (coffee shop, full app prior art), Paws (dog grooming), Suds (laundry), Ears (clinical / regulated-care, furthest-progressed clinical demonstrator, W-015), Minds (counselling / professional-body-regulated). Cross-domain validation discipline (J1) requires every BMM concept to validate in at least two demonstrators.
- **Six BMM concerns:** ServiceConcept, ActivityModel, ResourcePlanning, FinancialPlanning, GovernanceMapping, StakeholderModel (sixth concern added S81). 34 BMM General `part def`s.
- **Comprehension architecture:** Every BMM General `part def` carries `@CatalogueTag`, `@BfoType`, `@UserFacing`, `@PurposiveDescription`, `@Comprehension`, and `@WeightedRelationship` annotations. 34/34 coverage; 96 weighted relationships. Tenant projections (`paws.sysml`, `minds.sysml`, etc.) carry doc blocks only — annotation semantics are inherited via `:>` and `part` instantiation.
- **Knowledge graph:** Dual-formalism — SysML v2 for structure, OWL 2 DL for ontological semantics. BFO 2020 as upper ontology, CCO + IAO + PROV-O core subset as mid-level. GraphDB Free as triple store. Three-stratum graph: metamodel / domain / correspondence. Full OWL 2 DL reasoning via HermiT (Robot). Stage 7 Phase 1+2+3 complete — HermiT CONSISTENT. Hand-authored modules: `ontara-governance.ttl`, `ontara-domain.ttl`, `ontara-reasoning.ttl` (42 classes, 15 named individuals, 40 object properties, 10 datatype properties, PROV-O dual subclassing, STAMP/STPA safety structures, FRAM-ready function/variability slots), `ears-reasoning-instances.ttl` (~83 named individuals, S166). 13-file ontology stack. **66-query SPARQL validation suite across 12 groups.** MVP CQC Regulation 12 test individuals validated.
- **PostgreSQL `ontara` repository** (lives in the vault at `02 ONTARA/db/`): canonical store for concepts, concept relationships, EIL entries, risks, the work tracker (DCR, active work items, OW register). Surfaced through (a) generated markdown exports (`ontara-ref-glossary.md`, etc.) regenerated on every database write, and (b) the **resolver service** at `http://localhost:7300/`. Concept additions and changes flow through database migrations or the resolver admin UI, not through markdown edits.

## Two Repos, Kept Separate

Ontara work spans two git repos. They have different content responsibilities and **vault-resident material is NOT mirrored into the SysML repo**.

- **SysML repo** (`~/Developer/gsl-tech/gsl-sysml-model`, this repo) — SysML model source (`.sysml`), hand-authored OWL modules (`.ttl`), generation scripts, generated artefacts, the SysML syntax reference, demonstrator app code (cafe), the Ontara Console, the Portal, this `CLAUDE.md`, and code-adjacent material (plans, notes Ella places in the repo).
- **Vault repo** (`/Users/ellagreen/Obsidian/GenderSense`) — foundations papers, reference documents, session reports and preparation notes, discussion papers, concept graph notes, plans, the glossary, the work tracker, the V&A reference, the workflow guide, the EIL, the PostgreSQL `db/` repository, and any other vault material.

Claude does not propose `cp` commands that copy vault documents into the SysML repo and does not propose overwriting `documentation/archive/` with vault content. The historical `documentation/archive/` retains earlier in-repo material; it is not a target for new vault mirroring.

## SysML Repository Layout

```
model/                     # Core SysML v2 model (13 .sysml files)
exercises/
  coffeeshop-demonstrator/ # Cafe demonstrator: full running app (SvelteKit + Temporal + EHRbase + PostgreSQL)
  suds-demonstrator/       # Suds (laundry) BMM instance
  paws-demonstrator/       # Paws (dog grooming) BMM instance
console/                   # Ontara Console (SvelteKit + Svelte 5 runes + Flowbite Svelte + Tailwind v4)
portal/                    # Ontara Portal (SvelteKit + Svelte 5 runes + Flowbite Svelte + Tailwind v4 + SQLite)
scripts/                   # Python generators, shared modules, and shell tools
  archive/                 # Archived superseded generators (with provenance)
generated/                 # All generated output (DO NOT EDIT manually)
  ontara/model-introspection.json  # Console data source
  ontology/                # Generated OWL/Turtle and mapping IR (5 files)
ontology/                  # Knowledge graph config and imported ontologies
  axioms/                  # Hand-authored OWL axioms (ontara-bmm-axioms.ttl)
  config/                  # Mapping rules (YAML), CCO IRI lookup (JSON)
  governance/              # Hand-authored governance ontology (ontara-governance.ttl) + test individuals
  domain/                  # Hand-authored domain identity ontology (ontara-domain.ttl)
  reasoning/               # Hand-authored reasoning metamodel (ontara-reasoning.ttl) + Ears instances
  imports/                 # BFO 2020, CCO, IAO, PROV-O core ontology files
  catalog-v001.xml         # XML catalog for Robot IRI resolution
tools/                     # External tooling
  robot.jar                # Robot OWL tool (wraps HermiT reasoner)
documentation/
  reference/               # SysML syntax ref, KerML reserved words
  archive/                 # Historical in-repo material (not for new vault mirroring)
libraries/                 # Shared libraries
concept-graph/             # Generated concept graph (Mermaid + Obsidian)
spikes/                    # Experimental code
.claude/skills/            # Claude Code skills
CLAUDE.md                  # this file
```

## Key File Paths

- **SysML model files:** `model/*.sysml` (13 files: architectural-structure, business-model, business-scenarios, business-strategy, canonical-runtime, enterprise, foundation, gendersense, knowledge, operations, pattern-catalogue, platform, service-delivery)
- **Tenant projections:** Paws and Minds projections under `exercises/<tenant>-demonstrator/`. Tenant projections specialise BMM General `part def`s and carry **doc blocks only** — annotations are inherited.
- **Console app:** `console/` (SvelteKit, uses pnpm)
- **Console data:** `console/static/data/model-introspection.json` (sync via `pnpm refresh-data`, defined as `cp ../generated/ontara/model-introspection.json static/data/`)
- **Introspection generator:** `scripts/gen_model_introspection.py`
- **OWL pipeline generator:** `scripts/gen_owl_pipeline.py`
- **Shared SysML parser:** `scripts/sysml_parser.py` (used by introspection and OWL pipeline generators; S104)
- **Shared KG utilities:** `scripts/kg_utils.py` (GraphDB connection, SPARQL queries, IRI shortening; used by `validate_kg.py` and `diff_kg.py`; S137)
- **GraphDB setup:** `scripts/setup_graphdb.py`
- **OWL 2 DL reasoner:** `scripts/reason_kg.py` (HermiT via Robot)
- **Hand-authored axioms:** `ontology/axioms/ontara-bmm-axioms.ttl`
- **Hand-authored reasoning vocabulary:** `ontology/reasoning/ontara-reasoning.ttl`
- **Ears reasoning instances:** `ontology/reasoning/ears-reasoning-instances.ttl`
- **PROV-O core subset:** `ontology/imports/prov-core.ttl`
- **Robot JAR:** `tools/robot.jar`
- **XML catalog:** `ontology/catalog-v001.xml`
- **Other generators:** `scripts/gen_concept_graph.py`, `scripts/gen_package_hierarchy.py`, `scripts/gen_system_manifest.py`, `scripts/gen_constraint_evaluator.py`, `scripts/gen_decision_table_evaluator.py`, `scripts/projection_engine.py`, `scripts/diff_kg.py`, `scripts/validate_kg.py`
- **Mapping rules:** `ontology/config/mapping-rules.yaml`
- **CCO IRI lookup:** `ontology/config/cco-iri-lookup.json`
- **SysML syntax reference:** `documentation/reference/gsl-sysml-v2-syntax-reference.md` (stable filename — versioned snapshots in `documentation/reference/syntax-versions/`)
- **KerML reserved words:** `documentation/reference/KerML-Reserved-Words.md` (vault canonical copy at `02 ONTARA/02 Ontara DEVELOPMENT/Ontara REFERENCE & GUIDES/ontara-ref-authority-kerml-reserved-words.md`)
- **`ontara` shell toolkit:** `scripts/ontara` (renamed from `gsl` at S65)

## PostgreSQL `ontara` Database (in the vault)

The `ontara` PostgreSQL database lives on the macOS host (Homebrew Postgres 16). Its repository (schema, migrations, queries, resolver service code, exports) is **inside the vault** at `/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/db/`. From inside the SysML repo, the database is reached via:

- **Direct psql** — `psql -d ontara …` (peer auth, no password). Migrations: `psql -d ontara -f path/to/migration.sql`.
- **Resolver HTTP service** — `http://localhost:7300/`. Public read views (concepts, EIL, risks, work items, OW register, DCR). Token-protected write surface at `/api/{ct}` and `/admin/{ct}`. Token at `02 ONTARA/db/resolver/.ontara-token`.
- **Postgres MCP** (when in a Claude Desktop session) — TCP via Docker bridge, used for ad-hoc inspection.

Full reach details and the `pg_hba.conf` setup are in the vault at `02 ONTARA/02 Ontara DEVELOPMENT/Ontara REFERENCE & GUIDES/ontara-ref-guide-db-access.md`. The shell command catalogue (resolver service control, generator commands, console operations) is in the vault at `ontara-ref-guide-shell-commands.md`.

## Tech Stack

- **Console:** SvelteKit + Svelte 5 (runes) + Flowbite Svelte + Tailwind v4. Package manager: pnpm. Dev port: 5173. **Navigation infrastructure (S133):** `NavigationStore` in `$lib/stores/navigation.svelte.ts` with `NavigationProvider`, `NavLink`, `Breadcrumb`. Routes opt in incrementally — see `$lib/types/navigation.ts` for the `PageStateContract`. The console currently has 12 routes: Home, Architecture, Catalogue, Coverage, Domains, Glossary, Governance, Meta-Model, Ontology, Packages, Patterns, Relationships.
- **Portal:** SvelteKit + Svelte 5 (runes) + Flowbite Svelte + Tailwind v4 + SQLite (better-sqlite3) + bcryptjs. Package manager: pnpm. Dev port: 5174. Warm teal theme distinct from console's cool slate. 10 module definitions (6 business + 2 generative + 2 analytical). Database `portal/data/portal.db` is auto-created and gitignored. Routes: `(app)/` group for authenticated pages, auth pages at root level. **Portal constraints:** (1) Pure logic shared between server and client must go in `$lib/modules/`, not `$lib/server/` (SvelteKit enforces `$lib/server/` as server-only — OW-19). (2) Client-only APIs (`localStorage`, `document`) must use `$effect` + `browser` guard from `$app/environment` (OW-20). (3) Svelte 5 `{@const}` must be a direct child of logic blocks — use `$derived` in script block or `{@const}` directly inside `{#if}` / `{#each}` / `{#snippet}` (OW-25). (4) When changing the SQLite schema, stop the dev server and delete all three files (`portal.db`, `portal.db-shm`, `portal.db-wal`) before restarting (OW-21).
- **Cafe Demonstrator** (`exercises/coffeeshop-demonstrator/`): SvelteKit + Temporal (workflow engine) + EHRbase (CDR) + PostgreSQL. pnpm workspace monorepo with packages: web, temporal, shared.
- **Generators:** Python 3. Standard library for introspection generator. OWL pipeline requires `rdflib` and `PyYAML` (`pip3 install rdflib PyYAML`).
- **Knowledge graph:** GraphDB Free 10.x (local Java app, port 7200). Robot (wraps HermiT, `tools/robot.jar`) for OWL 2 DL consistency checking. BFO 2020 + CCO 2.0 + IAO + PROV-O (core subset) as imported ontologies. Reasoning runtime ~20 minutes against the 13-file stack.
- **Resolver / database:** Local Homebrew PostgreSQL 16. The resolver is a FastAPI service auto-started via launchd (LaunchAgent at `~/Library/LaunchAgents/dev.ontara.resolver.plist`).
- **Model editing:** Syside Modeler (VS Code extension for SysML v2). Claude cannot run Syside — only Ella can verify SysML parses.

## Console Commands

```bash
cd console
pnpm dev              # Start console dev server (http://localhost:5173)
pnpm build            # Production build
pnpm refresh-data     # Copy generated/ontara/model-introspection.json to static/data/
```

## Portal Commands

```bash
cd portal
pnpm dev              # Start portal dev server (http://localhost:5174)
pnpm build            # Production build
```

## Generator Commands

```bash
# From repo root
python3 scripts/gen_model_introspection.py --save --pretty   # Generate console data
python3 scripts/gen_concept_graph.py                          # Generate concept graph
python3 scripts/gen_package_hierarchy.py                      # View package hierarchy
python3 scripts/gen_system_manifest.py                        # Generate manifest
python3 scripts/gen_constraint_evaluator.py                   # Generate constraint evaluators
python3 scripts/gen_decision_table_evaluator.py               # Generate decision tables
```

## Knowledge Graph Commands

```bash
# OWL pipeline
python3 scripts/gen_owl_pipeline.py                # Generate OWL ontology + correspondence + mapping IR (writes to generated/ontology/)

# GraphDB setup and validation (require GraphDB running on :7200)
python3 scripts/setup_graphdb.py                   # Create repo and load ontology stack
python3 scripts/validate_kg.py                     # Validate against currently-loaded content
python3 scripts/validate_kg.py --load              # Reload pipeline output, then validate
python3 scripts/validate_kg.py --load-only         # Reload only (skip validation)
python3 scripts/validate_kg.py --verbose           # Show all result rows
python3 scripts/diff_kg.py                         # Round-trip diff: generated OWL vs live store
python3 scripts/diff_kg.py --verbose
python3 scripts/diff_kg.py --json-only

# OWL 2 DL Reasoning (requires Java + tools/robot.jar — does NOT require GraphDB)
python3 scripts/reason_kg.py                       # Reason over full 13-file ontology stack
python3 scripts/reason_kg.py --test-violation      # Inject contradiction, confirm reasoner catches it
python3 scripts/reason_kg.py --save-summary        # Save reasoning-summary.json (uses rdflib, no GraphDB)
```

## Infrastructure Dependencies

**GraphDB Free** (localhost:7200) is required by `validate_kg.py`, `diff_kg.py`, `setup_graphdb.py`. It is NOT required by:

- `reason_kg.py` — Robot + HermiT operate directly on Turtle files; `--save-summary` uses rdflib.
- `gen_owl_pipeline.py` — reads SysML, writes Turtle. No GraphDB dependency.
- `gen_model_introspection.py` — reads SysML, writes JSON. No GraphDB dependency.
- Console / portal dev servers — read static JSON, not GraphDB.

**Resolver service** (localhost:7300) is required for: writes to PostgreSQL-canonical content (concepts, EIL, work tracker, OW register, DCR, risks). Auto-started on login; status checks via `curl http://localhost:7300/health`.

If a task instruction says "run reason_kg.py --save-summary", do NOT attempt to load GraphDB or run validate_kg.py unless explicitly instructed. These are independent operations.

## Cafe Demonstrator Commands

```bash
cd exercises/coffeeshop-demonstrator/
docker compose -f docker-compose.ehrbase.yml up -d  # Start EHRbase + PostgreSQL
pnpm dev:temporal                                     # Start Temporal worker
pnpm dev:web                                          # Start web frontend
pnpm generate                                         # Regenerate from SysML model
```

## Critical Data Sync Rule

After running `gen_model_introspection.py --save`, sync to the console:

```bash
cd console && pnpm refresh-data
```

## SysML Conventions

- **Always check** `documentation/reference/gsl-sysml-v2-syntax-reference.md` before writing new `.sysml` code. Syside syntax differs from the SysML v2 spec.
- **Always check** `documentation/reference/KerML-Reserved-Words.md` before naming `part def`s, attributes, or other identifiers. `subject` is NOT KerML-reserved but IS a SysML v2 contextual keyword.
- **Doc blocks** on every `part def` or `metadata def` must include meta model classification: `/* business meta model concept */` or `/* system meta model concept */`. Under the strengthened A4, the doc block records the stratum-and-side locus.
- **`part def` vs `part`:** A `part def` is a meta model concept (abstract definition). A `part` is an instance (concrete usage). Do not conflate them.
- **General vs Tailored:** BMM components are classified as General (common across most service businesses, in `business-model.sysml`) or Tailored (sector-specific, in tenant or domain modules).
- **Annotation placement (Position A):** All six BMM annotation types (`@CatalogueTag`, `@BfoType`, `@UserFacing`, `@PurposiveDescription`, `@Comprehension`, `@WeightedRelationship`) on a BMM General `part def` are placed **before** the `part def` declaration, in standard order. Inline placement parses but is not used.
- **Tenant projections carry doc blocks only.** No inline annotations on `part` usages or specialising `part def`s — annotation semantics are inherited via `:>` and instantiation. Putting an annotation on a `part` usage produces a "No Feature named '<attribute>' found" error; putting one on a specialising `part def` produces metaclass-binding ambiguity.
- **Enum value verification.** Before delivering any SysML referencing `EnumName::value`, verify each value against the actual `enum def` in source. Do not infer from semantics. (Discovered S275.)
- **Multi-package imports.** Each package needs its own `private import` for every enum/type referenced. `Foundation::CommonTypes` hosts shared enums and must be imported in every using package. (Discovered S275 in multi-package tenant projection.)

## Development Principles

- **Co-evolution (J2):** Never add model content without tooling to make it legible. Never build tooling without model content to exercise it.
- **Non-constraining (J3):** Decisions should not foreclose future development paths.
- **Model generates everything (A3):** SysML is the single source of truth for structure; OWL ontology stack is the canonical form for ontological semantics. Generated artefacts are derived, not authoritative.
- **Cross-domain validation (J1):** New BMM concepts must validate in at least two demonstrators.
- **Discipline as load-bearing structure (A9):** Workflow practices propagate reliability through the platform. Skipping a step is not saving time — it is introducing structural risk.
- **Contraction default (S241):** During contraction, the default response to an emergent possibility is capture in the EIL, not divert landing work. New features must be justified against "does this block landing?" not "is this architecturally interesting?"

## Commit Convention

- **Code commits at the end of a task** with a descriptive commit message, unless Ella has asked to review before committing. Do not leave uncommitted changes for Ella to commit manually.
- Commit messages reference the session number: `Session NN: description of changes`
- The vault repo and the SysML repo are committed independently. Vault material in vault repo, SysML repo material here. Ella drives the vault commit; Claude Code may handle the SysML repo commit.

## Ontara Toolkit

The `ontara` shell script (`scripts/ontara`) provides quick access to the package hierarchy:

```bash
ontara              # Terminal tree view (default)
ontara save         # Export all formats (Markdown, OPML, HTML, OmniOutliner)
ontara html         # Export and open interactive mindmap
ontara oo           # Export and open in OmniOutliner
ontara diff         # Compare model vs proposal
ontara model        # Open model directory in editor
ontara help         # Show all commands
```

Set up alias in `~/.zshrc`:

```bash
alias ontara='~/Developer/gsl-tech/gsl-sysml-model/scripts/ontara'
```

## Obsidian Vault (via CLI)

The Obsidian CLI (v1.12+, GA) provides terminal control of the running Obsidian Desktop app via IPC. All operations go through Obsidian's internal API — file moves auto-update wikilinks, property changes are immediately indexed.

**Prerequisites:** Obsidian must be running. CLI enabled in Settings → General. The vault parameter must come first.

**Full reference:** See the `/vault` skill (`.claude/skills/vault/SKILL.md`) for complete command reference, and the vault's CLI reference document (`ontara-ref-guide-obsidian-cli-commands.md`) for the comprehensive command catalogue.

### Core commands

```bash
# Read
obsidian vault=GenderSense read file="path/from/vault/root.md"

# Create (silent = don't open in GUI)
obsidian vault=GenderSense create name="path/to/new-file.md" content="..." silent

# Append / Prepend
obsidian vault=GenderSense append file="path/to/file.md" content="..."
obsidian vault=GenderSense prepend file="path/to/file.md" content="..."

# Move a FILE (auto-updates wikilinks) — files only, not folders
obsidian vault=GenderSense move file="old/path.md" to="new/folder/"

# Delete (moves to trash by default)
obsidian vault=GenderSense delete file="path/to/file.md"

# Search
obsidian vault=GenderSense search query="search term"
obsidian vault=GenderSense search:context query="search term" limit=10
obsidian vault=GenderSense search query="search term" format=json

# Properties
obsidian vault=GenderSense properties file="path/to/note"
obsidian vault=GenderSense property:set path="path/to/note" name="status" value="active"

# Listing and discovery
obsidian vault=GenderSense files
obsidian vault=GenderSense folders
obsidian vault=GenderSense outline file="path/to/note"

# Links and vault health
obsidian vault=GenderSense backlinks file="note"
obsidian vault=GenderSense unresolved
obsidian vault=GenderSense orphans

# Tags
obsidian vault=GenderSense tags counts sort=count
obsidian vault=GenderSense tags:rename old=oldtag new=newtag

# Help
obsidian help
obsidian help <command>
```

### Folder operations (eval workaround)

The CLI has no native folder rename/move. Use `eval` with `app.fileManager.renameFile()`:

```bash
obsidian vault=GenderSense eval code="(async () => { const f = app.vault.getAbstractFileByPath('old/folder/path'); if (f) { await app.fileManager.renameFile(f, 'new/folder/path'); return 'done'; } return 'not found'; })()"
```

This goes through Obsidian's API so wikilinks are updated. Allow 1 second between sequential renames.

### Behavioural guardrail

**If a CLI command fails, STOP and report the error.** Do NOT attempt workarounds using eval, JavaScript API calls, or raw filesystem operations without explicit approval from Ella.

### Key facts

- Vault root: `/Users/ellagreen/Obsidian/GenderSense`
- Ontara content root: `02 ONTARA/`
- File paths are relative to vault root; `.md` extension usually optional
- Always use `obsidian move` instead of raw `mv` — the CLI preserves wikilinks
- All vault documents must use `[[filename|display text]]` wikilinks — no plain text vault references

---

## Working With Ella

- Ella leads all design and architectural decisions. Ask before making non-trivial changes.
- The Obsidian vault at `/Users/ellagreen/Obsidian/GenderSense/` is the primary working environment for documents and planning.
- Claude Code should use the Obsidian CLI (`/vault` skill) for any vault operation that might change file paths or structure (create, move/rename, delete notes or folders), so Obsidian keeps wikilinks and indexing correct.
- Claude Code may use filesystem MCP tools for **read-only operations and in-place content edits** in the vault (listing, reading files, updating text) but **must not** rename, move, or delete vault files via filesystem MCP.
- Claude Chat can continue to access the vault via MCP filesystem tools when working outside Claude Code.
- Vault-resident material is committed in the vault repo only; do not propose `cp` operations that mirror vault documents into this repo.
- Do not overwrite files Ella may have edited without checking first.
- "Shall I go ahead?" is a genuine question, not rhetorical.
