# Ontara — Claude Code Project Context

## What This Is

Ontara is a service system development and delivery platform. The platform model is **one bounded model in two canonical forms** (AC-19, ADR-007): the ontology form (OWL 2 DL / RDF, held in the knowledge graph) and the textual form (the PostgreSQL `ontara` substrate database). The SysML v2 model in this repo is an **engineering projection** of the ontology form: it is authored where its expressiveness wins and generated into OWL, and it is not itself canonical. Generators produce console data, evaluators, ontology files and other downstream artefacts. The sole developer and architect is Ella Green.

The project is in a **steady state, staged by mandate** (AC-17). The current stage is **Plan B Stage 0, the first Cafe build**: the first stage of the Cafe proof. The stage sequence runs Cafe proof → a second tenant → v1 acceptance. Every task is measured by the stage test: *does the Cafe need this to run as a genuine tenant of the platform, at the current stage?* Work that fails it needs Ella's explicit yes before it starts. The programme mandate is the vault document with slug `ontara-ref-gv-programme-mandate`; Stage 0 is specified, step by step, in slug `cafe-plan-b-stage-0-specification`.

V1 (slug `ontara-ref-db-v1-acceptance`) is a locally-hosted platform running plural concurrent tenants (AC-18), listed in the tenant landing register (slug `ontara-ref-db-landing-tenants`): currently Cafe, Paws, Suds, Ears and Minds, each able to simulate a period of operation, present band-appropriate user surfaces, and answer queries about its performance. **GSL (GenderSense Limited)** is the production target *post-v1*; it is not a v1 demonstrator.

**Stage 0 decisions already taken** (S515–S517), which code in this repo must respect:

- The Cafe's runtime runs as its own stack in Docker Compose and **never depends on the Mac's authoring rig** (S516).
- Runtime state is held as triples in GraphDB; GraphDB's own SHACL validates in the write transaction.
- MRB mapping rules are SPARQL Update, each held as the body of an RDF rule declaration in the tenant's configured model. Rules are **written in Turtle, in a `rules/` folder beside each tenant's model, not in SysML** (S517). Their declaration vocabulary will live in a shared, OWL-only declared-writer module at PML, named at S0.6 (ADR-014).

## Architecture in Brief

- **Two meta models:** Business Meta Model (BMM — what a service business *is*) and System Meta Model (SMM — how a system *works*). They are distinct and connected by explicit mappings. Note: SMM was previously called BSMM (Business System Meta Model). Renamed S92. The SysML section name `bsmm-general-vocabulary` is a structural identifier and stays.
- **Nine layers** (S429 rename; replaces the former eight-stratum terminology — "strata" is retired): OFL (Ontology Foundation Layer) → ODL (Ontology Domain Layer) → PML (Platform Metamodel Layer) → CML (Configured Model Layer) → KRL (Knowledge Representation Layer) → IRL (Internal Reaction Layer, inserted at S429 to house MRB) → SRL (Substrate Reasoning Layer) → BRL (Binding Realisation Layer) → PRL (Platform Realisation Layer). Strengthened A4 (S208–S210) commits the Knowledge Graph as the canonical KRL substrate (B22).
- **Demonstrator tenants** (the tenant landing register's current set): Cafe (coffee shop; the existing app is prior art to be audited, not replaced unaudited), Paws (dog grooming), Suds (laundry), Ears (clinical / regulated care), Minds (counselling / professional-body-regulated). Cross-domain validation discipline (J1) requires every BMM concept to validate in at least two demonstrators.
- **Six BMM concerns:** ServiceConcept, ActivityModel, ResourcePlanning, FinancialPlanning, GovernanceMapping, StakeholderModel (sixth concern added S81). 34 concern `part def`s sit directly under `BusinessMetamodelGeneral`; the BMM element table holds 53 elements in all, adding `BusinessScenarios`, `BusinessStrategy`, `CanonicalRuntime` and `DomainIdentityTypes`.
- **Comprehension architecture:** Every BMM General `part def` carries `@CatalogueTag`, `@BfoType`, `@UserFacing`, `@PurposiveDescription`, `@Comprehension`, and `@WeightedRelationship` annotations. 34/34 coverage; 98 weighted relationships. Tenant projections (`paws.sysml`, `minds.sysml`, etc.) carry doc blocks only — annotation semantics are inherited via `:>` and `part` instantiation.
- **Knowledge graph:** OWL 2 DL is the canonical form for formal axiomatic content (AC-07); SysML v2 is its engineering projection. BFO 2020 as upper ontology, CCO + IAO + PROV-O core subset as mid-level (AC-08). GraphDB as triple store. Full OWL 2 DL reasoning via HermiT (Robot). Hand-authored modules: `ontara-governance.ttl`, `ontara-domain.ttl`, `ontara-reasoning.ttl` (42 classes, 15 named individuals, 40 object properties, 10 datatype properties, PROV-O dual subclassing, STAMP/STPA safety structures, FRAM-ready function/variability slots), `ears-reasoning-instances.ttl` (~83 named individuals, S166). The ontology stack is the set `scripts/reason_kg.py` loads; the SPARQL validation suite is in `scripts/validate_kg.py`.
- **PostgreSQL `ontara` repository** (lives in the vault at `02 ONTARA/db/`): the textual canonical form (AC-19): concepts, concept relationships, EIL entries, risks, the DCR, the OW register, the harvest register, strata, tenants, BMM elements, modelling paradigms, tech stack, and substrate-canonical document content. **Work items live in Plane (project `OP`), not in the database** (S441). Surfaced through (a) generated markdown exports (the glossary, slug `ontara-ref-rs-glossary`, etc.) regenerated on every database write, (b) the **resolver service** at `http://localhost:7310/`, and (c) **substrate documents** rendered from the substrate block tables. Concept additions and changes flow through database migrations or the resolver admin UI, not through markdown edits.
- **Substrate-canonical documents** (from S290+): a growing class of vault references (the Architecture & Principles family, the BMM family, the IGF references, the coherence ledger and others) are stored as ProseMirror block trees in the substrate tables (`block`, `block_edge`, `document`, `revision`) and rendered to vault markdown via the resolver. The vault `.md` is the rendered surface; the database is the source of truth. Editing the rendered markdown by hand is a category error; edits flow through the substrate editor (Portal) or build scripts (one-off authoring).

## Two Repos, Kept Separate

Ontara work spans two git repos. They have different content responsibilities and **vault-resident material is NOT mirrored into the SysML repo**.

- **SysML repo** (`~/Developer/gsl-tech/gsl-sysml-model`, this repo) — SysML model source (`.sysml`), hand-authored OWL modules (`.ttl`), generation scripts, generated artefacts, the SysML syntax reference, demonstrator app code (cafe), the Ontara Console, the Portal, this `CLAUDE.md`, and code-adjacent material (plans, notes Ella places in the repo).
- **Vault repo** (`/Users/ellagreen/Obsidian/GenderSense`) — foundations papers, reference documents, session reports and preparation notes, discussion papers, concept graph notes, plans, the glossary, the work tracker, the V&A reference, the workflow guide, the EIL, the PostgreSQL `db/` repository (schema, migrations, queries, resolver service code, exports, build scripts), and any other vault material.

Claude does not propose `cp` commands that copy vault documents into the SysML repo and does not propose overwriting `documentation/archive/` with vault content. The historical `documentation/archive/` retains earlier in-repo material; it is not a target for new vault mirroring.

## SysML Repository Layout

```
model/                     # Metamodel and platform apparatus (6 .sysml files; ADR-012)
  business-metamodel-general.sysml       # BusinessMetamodelGeneral (BMG): six concerns + BusinessScenarios,
                                         #   BusinessStrategy, CanonicalRuntime, DomainIdentityTypes
  system-metamodel-general.sysml         # SystemMetamodelGeneral (SMG)
  system-metamodel-domain-clinical.sysml # SystemMetamodelDomainClinical (SMD, clinical sector)
  projection-metadata.sysml              # ProjectionMetadata: generators' annotation schema (no layer)
  architectural-structure.sysml          # ArchitecturalStructure: platform description (no layer)
  pattern-catalogue.sysml                # PatternCatalogue: platform description (no layer)
  syntax-tests/                          # Syside syntax tests (not model content)
exercises/                 # Tenant models (Configured Model layer); a tenant never imports another tenant
  gendersense/model/       # GenderSense (GSL) tenant model: 10 files, root GenderSense + 9 packages prefixed Gsl
  coffeeshop-demonstrator/ # Cafe demonstrator: model/ + full running app (SvelteKit + Temporal + EHRbase + PostgreSQL)
  suds-demonstrator/       # Suds (laundry) tenant model
  paws-demonstrator/       # Paws (dog grooming) tenant model
  minds-demonstrator/      # Minds (counselling) tenant model
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
libraries/                 # Shared libraries (temporal-metadata: TemporalMetadata, apparatus, no layer)
concept-graph/             # Generated concept graph (Mermaid + Obsidian)
spikes/                    # Experimental code
.claude/skills/            # Claude Code skills
CLAUDE.md                  # this file
```

## Key File Paths

- **SysML model files:** `model/*.sysml` (6 files: architectural-structure, business-metamodel-general, pattern-catalogue, projection-metadata, system-metamodel-domain-clinical, system-metamodel-general). Package classes, allocation and import rules: ADR-012 in the vault.
- **Tenant models:** GSL in `exercises/gendersense/model/` (10 files: gendersense, gsl-business-model, gsl-common-types, gsl-domain-registration, gsl-enterprise, gsl-knowledge, gsl-operations, gsl-platform, gsl-scenarios, gsl-service-delivery); Cafe, Suds, Paws and Minds under `exercises/<tenant>-demonstrator/model/`. Tenant models specialise BMM General `part def`s and carry **doc blocks only** — annotations are inherited.
- **Package-direction check:** `scripts/check_package_direction.sh` runs ADR-012 rules R1 to R8. Run it after any change to a package, an import or a model file; it must end `RESULT: PASS`.
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
- **Other generators:** `scripts/gen_concept_graph.py`, `scripts/gen_package_hierarchy.py`, `scripts/gen_system_manifest.py`, `scripts/gen_decision_table_evaluator.py`, `scripts/projection_engine.py`, `scripts/diff_kg.py`, `scripts/validate_kg.py`
- **Platform generation package:** `generation/` (tenant-free generators for the Cafe's types, XState machine and lifecycle guard, Temporal workflow, Mermaid pathway, the E6 constraint evaluators, and each tenant's General element list (S0.3); tests on fixture models in `generation/tests/`; A3 exception list in `generation/A3-EXCEPTIONS.md`). Generated files are never edited by hand.
- **Mapping rules:** `ontology/config/mapping-rules.yaml`
- **CCO IRI lookup:** `ontology/config/cco-iri-lookup.json`
- **SysML syntax reference:** `documentation/reference/gsl-sysml-v2-syntax-reference.md` (stable filename — versioned snapshots in `documentation/reference/syntax-versions/`)
- **KerML reserved words:** `documentation/reference/KerML-Reserved-Words.md` (vault canonical copy at `02 ONTARA/02 Ontara DEVELOPMENT/Ontara REFERENCE & GUIDES/ontara-ref-authority-kerml-reserved-words.md`)
- **`ontara` shell toolkit:** `scripts/ontara` (renamed from `gsl` at S65)

## PostgreSQL `ontara` Database (in the vault)

The `ontara` PostgreSQL database lives on the macOS host (Homebrew Postgres 16). Its repository (schema, migrations, queries, resolver service code, exports including build-scripts) is **inside the vault** at `/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/db/`. From inside the SysML repo, the database is reached via:

- **Direct psql** — `psql -d ontara …` (peer auth, no password). Migrations: `psql -d ontara -f path/to/migration.sql`.
- **Resolver HTTP service** — `http://localhost:7310/`. Public read views (concepts, EIL, risks, OW register, DCR, harvest register). Token-protected write surface at `/api/{ct}` and `/admin/{ct}`. Token at `02 ONTARA/db/resolver/.ontara-token`.
- **Postgres MCP** (when in a Claude Desktop session) — TCP via Docker bridge, used for ad-hoc inspection.

Full reach details and the `pg_hba.conf` setup are in the vault document with slug `ontara-ref-guide-db-access`. The shell command catalogue (resolver service control, generator commands, console operations) is in slug `ontara-ref-guide-shell-commands`. **Find vault documents by their frontmatter `slug:` line, not by filename** (search with `grep -rl` for `slug: <slug>`): filenames are Ella's to change at any time, and a slug never changes.

## Substrate, Resolver, and Exporter

This section covers the present-day write architecture for vault content backed by the database. Added S359 (was missing from earlier CLAUDE.md). The vault at `02 ONTARA/db/` is laid out as:

```
db/
  exports/                # marker-bound exporters — Python modules that regenerate
                          # marker sections in vault markdown from PostgreSQL rows
    build-scripts/        # substrate-doc build scripts (build_sNNN_*.py); kept as
                          # provenance / audit trail
  migrations/             # numbered SQL migration files (NNN_description.sql)
  queries/                # standing read queries for inspection and tooling
  resolver/               # FastAPI resolver service (substrate, write, admin, API)
  schema/                 # canonical schema reference
  .ontara-session  # canonical session pointer (single integer)
  .ontara-token    # resolver auth token (gitignored)
```

### Resolver service

- FastAPI service at `http://localhost:7310/`. Auto-started via launchd (`~/Library/LaunchAgents/dev.ontara.resolver.plist`).
- Liveness: `curl http://localhost:7310/healthz` returns `{"status":"ok"}`. The `/health` endpoint is the HTML admin landing page.
- Restart: `launchctl kickstart -k gui/501/dev.ontara.resolver`.
- Auth: `X-Ontara-Token: <token>` header for write APIs; cookie auth for the admin UI (set once via `/admin/login`).
- Surfaces:
  - `/admin/{ct}` — HTML admin UI for marker-bound content types (concepts, EIL, harvest entries, OW register, DCR, risks, etc.).
  - `/api/{ct}` — JSON API for the same content types (GET / POST / PATCH / DELETE). `POST /api/{ct}` has no trailing slash: with one it reaches the GET-only list and returns a misleading 405.
  - `/api/{ct}/{key}/rename` — identity rename (OP-87, ADR-006).
  - `/v1/documents/{id}/mutations` — substrate write API (createBlock, insertChild, addEdge, removeEdge, patchBlockContent, moveBlock). There is no `deleteBlock`: `removeEdge` detaches a block. The body key is `operations`, with snake_case per-op keys.
  - `/v1/documents/{id}/render?target=vault[&path=...]` — substrate render to vault markdown. When `path=` is omitted, the renderer walks the vault tree and matches `document.slug` against frontmatter `slug:` fields (W-148 / W-149 / S367); renames in Obsidian require zero resolver-side action. When `path=` is supplied, it wins (preserves existing build scripts).
  - `/v1/audit/document-paths` — walks every `document` row and returns `{resolved, missing, ambiguous}` lists for batch path-health checks (W-149).
- Specs live in `db/resolver/specs/`. Each marker-bound content type has a `*_spec.py` (concepts_spec.py, dcr_spec.py, etc.). Specs declare columns, validation rules, regenerate hooks, and pre-create hooks (e.g. harvest-code allocation). Spec and exporter edits take effect only after a resolver restart.

### Marker-bound writes

Vault markdown documents host content canonically held in PostgreSQL via marker pairs:

```markdown
<!-- ontara:begin {marker-id} -->
... content regenerated from DB on every write ...
<!-- ontara:end {marker-id} -->
```

Content between markers is **overwritten on regen** and must not be edited by hand. Edits flow through:

- The resolver admin UI at `http://localhost:7310/admin/{ct}` (form-based).
- The JSON API at `http://localhost:7310/api/{ct}` (programmatic).
- Direct SQL (rare; bypasses regen and leaves markdown stale).

After any DB row write through the spec-driven engine, the spec's `regenerate_hook` is called automatically; the marker section in the host document is rewritten. **Direct SQL writes do not trigger regen** and so leave the markdown out of sync until the next manual regen call.

### Exporters

Modules under `db/exports/` regenerate marker sections from DB rows. Each exporter exposes:

- A `regenerate_<scope>(output=None, dry_run=False)` function with a `tuple[int, int]` return.
- An aggregate `regenerate_<topic>_section()` that calls the family's exporters in order.
- Markdown rendering helpers via `db/exports/common.py` (`format_markdown_table`, `replace_marked_section`, `bump_frontmatter`, `find_section_marker_file`, `current_session`).

The `db/exports/strata.py` module is the canonical example, regenerating six markers across five host documents (V&A, Stratified Architecture, BMM, V1 acceptance, stratum landing register, tenant landing register). The `regenerate_strata_section()` aggregate is wired as the regen hook for `strata` rows.

### Substrate documents

Substrate-canonical documents are stored as ProseMirror block trees in:

- `block` — individual blocks. Block types: `heading`, `paragraph`, `table`, `principle` (entity-bound; renders as `> [!principle] {label}` callout), `code` (props-lifted: language + text in props), `important` / `note` / `warning` (W-134 / S365 — typographic prose-only callouts, no entity binding; render as `> [!important]` / `> [!note]` / `> [!warning]`), `marker_section` (W-147 / S367 — atomic, props-only block carrying `marker_id`, `kind_label`, `admin_path`, `admin_label`; renders to the canonical marker-bound preamble with the body owned by the regen pipeline), and `document_root` (carries frontmatter in props). All have `props`, `content`, and optional `entity_type` + `entity_id` bindings (only `principle` and entity-binding paragraphs use the latter).
- `block_edge` — edges between blocks: `contains` (parent → child, ordered by ordinal), `transcludes`, `cites`, `mentions`, `instance_of`.
- `document` — document identity (slug, title, root_block_id, current_revision_id).
- `document_block` — flat membership table reconciled from `contains` reachability (W-126).
- `revision` — revision history per document.

Build scripts (`db/exports/build-scripts/build_sNNN_*.py`) author substrate documents programmatically. The standard shape is:

1. Define block helpers (`P()`, `H()`, `TABLE()`, `PRINCIPLE()` etc.).
2. Build a `BLOCKS` list with content, entity bindings, and structure.
3. Validate PM schema (text node shape, mark types, no nested paragraphs).
4. Reset existing document if any (NULL `current_revision_id` BEFORE deleting revisions — FK constraint).
5. Create document + root block via direct SQL.
6. POST mutations to `/v1/documents/{id}/mutations` to create blocks and contains-edges.
7. Render via `/v1/documents/{slug}/render?target=return` for verification.
8. Render via `/v1/documents/{slug}/render?target=vault&path=...` for placement.

`build_s372_arch_diagram.py` is the most complete reference for build script shape. A vault render (`target=vault`) also regenerates every marker section in the rendered file (OP-107, S508).

### Critical rules

- **Substrate writes go through the resolver, not direct SQL.** The resolver carries reconciliation logic (W-126, W-127) that direct SQL skips.
- **Marker-bound writes go through the resolver.** Direct SQL on `work_items`, `dcr_rows`, `concepts`, etc. bypasses regen.
- **`reset_document()` order:** NULL `current_revision_id` BEFORE deleting revisions (FK constraint on `document_current_revision_fk`). The trap: a first run succeeds because no revision row exists yet; the FK violation only surfaces on the second run after mutations have populated `current_revision_id`. Idempotent build scripts must NULL the column first. (S372 surfaced; S373 W-158 back-ported across 12 build scripts.)
- **PATCH identity-column rejection (S373):** The resolver's `PATCH /api/{ct}/{key}` endpoint rejects attempts to update identity columns with HTTP 400 + structured field error (`"Identity column cannot be updated via PATCH."`). It previously silently no-oped these updates, returning 200 while leaving the database unchanged. To rename a row's identity column (e.g. `stable_filename` on a DCR row), use `POST /api/{ct}/{key}/rename` (OP-87, ADR-006), which fires the regen hook. Do not rename by direct SQL.
- **Read before you PATCH a free-text field.** A PATCH replaces each field it names; carry over anything worth keeping.
- **Adjacent same-mark inline runs in a paragraph** (e.g. two `code` runs back-to-back) trigger a `<!--/-->` separator from the renderer (W-S346). Merge them into a single run with the combined text.
- **Render `target='vault'`** resolves the output path either from the `path=` query param or from `document.slug` matched against frontmatter `slug:` in the vault (W-148 / W-149 / S367). Substrate document identity is by slug; renaming a file in Obsidian requires zero resolver-side action — the next render finds it by slug. New build scripts omit `path=`. The legacy `_substrate-rendered/` staging directory is retired.
- **Work items live in Plane** (project `OP`, items `OP-NN`). The legacy `work_items` content type left behind at S441 is awaiting retirement (OP-129); do not write to it.

## Tech Stack

- **Console:** SvelteKit + Svelte 5 (runes) + Flowbite Svelte + Tailwind v4. Package manager: pnpm. Dev port: 5173. **Navigation infrastructure (S133):** `NavigationStore` in `$lib/stores/navigation.svelte.ts` with `NavigationProvider`, `NavLink`, `Breadcrumb`. Routes opt in incrementally — see `$lib/types/navigation.ts` for the `PageStateContract`. The console currently has 12 routes: Home, Architecture, Catalogue, Coverage, Domains, Glossary, Governance, Meta-Model, Ontology, Packages, Patterns, Relationships.
- **Portal:** SvelteKit + Svelte 5 (runes) + Flowbite Svelte + Tailwind v4 + SQLite (better-sqlite3) + bcryptjs. Package manager: pnpm. Dev port: 5174. Warm teal theme distinct from console's cool slate. 10 module definitions (6 business + 2 generative + 2 analytical). Database `portal/data/portal.db` is auto-created and gitignored. Routes: `(app)/` group for authenticated pages, auth pages at root level. **Portal constraints:** (1) Pure logic shared between server and client must go in `$lib/modules/`, not `$lib/server/` (SvelteKit enforces `$lib/server/` as server-only — OW-19). (2) Client-only APIs (`localStorage`, `document`) must use `$effect` + `browser` guard from `$app/environment` (OW-20). (3) Svelte 5 `{@const}` must be a direct child of logic blocks — use `$derived` in script block or `{@const}` directly inside `{#if}` / `{#each}` / `{#snippet}` (OW-25). (4) When changing the SQLite schema, stop the dev server and delete all three files (`portal.db`, `portal.db-shm`, `portal.db-wal`) before restarting (OW-21).
- **Cafe Demonstrator** (`exercises/coffeeshop-demonstrator/`): SvelteKit + Temporal (workflow engine) + EHRbase (CDR) + PostgreSQL. pnpm workspace monorepo with packages: web, temporal, shared. This app is prior art; the Stage 0 build follows the Stage 0 specification, not the app's existing structure.
- **Generators:** Python 3. Standard library for introspection generator. OWL pipeline requires `rdflib` and `PyYAML` (`pip3 install rdflib PyYAML`).
- **Knowledge graph:** GraphDB Free 10.x (local Java app, port 7200). Robot (wraps HermiT, `tools/robot.jar`) for OWL 2 DL consistency checking. BFO 2020 + CCO 2.0 + IAO + PROV-O (core subset) as imported ontologies. A full reasoning run takes around 20 minutes.
- **Resolver / database:** Local Homebrew PostgreSQL 16. The resolver is a FastAPI service auto-started via launchd (LaunchAgent at `~/Library/LaunchAgents/dev.ontara.resolver.plist`). Substrate write engine, marker-bound spec engine, and admin UI all in `db/resolver/`.
- **Substrate editor:** Portal hosts the substrate editor at `http://localhost:5174/substrate/{slug}` (TipTap + ProseMirror). Used for in-browser editing of substrate-canonical documents.
- **Model editing:** the free Syside Editor (VS Code extension `sensmetry.syside-editor`), which replaced Syside Modeler at S491; there is no Automator API or CLI. OpenSysML (`make parse-check`) is the SysML parse gate of record. Ella's Syside Editor check was retired as a gate at S519; the Syside Editor remains the editing tool. OpenSysML is pinned at v0.11.0 (`SYSML_VERSION` in the `Makefile`, `brew pin opensysml`; upgrade deliberately), and the accepted warnings are in `qa/parse-warnings-baseline.txt`. `scripts/check_package_direction.sh` is the scripted structural check.

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

## Resolver Commands

```bash
# Liveness
curl http://localhost:7310/healthz                      # JSON {"status":"ok"}
curl -I http://localhost:7310/                          # HTML admin landing

# Restart (after editing resolver code or specs)
launchctl kickstart -k gui/501/dev.ontara.resolver

# Tail logs
tail -f /tmp/ontara-resolver.log

# Token (for X-Ontara-Token header)
cat "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/db/resolver/.ontara-token"
```

## Generator Commands

```bash
# From repo root
python3 scripts/gen_model_introspection.py --save --pretty   # Generate console data
python3 scripts/gen_concept_graph.py                          # Generate concept graph
python3 scripts/gen_package_hierarchy.py                      # View package hierarchy
python3 scripts/gen_system_manifest.py                        # Generate manifest
make gen                                                      # Regenerate all generation/ output in place (Cafe + GenderSense E6, General element lists)
make gen-check                                                # Regenerate into scratch; fail on any difference from committed output, and on orphaned outputs (no longer generated)
make gen-test                                                 # generation/ tests on fixtures + Cafe lifecycle guard refusal check (Node 23.6+)
python3 scripts/gen_decision_table_evaluator.py               # Generate decision tables
scripts/check_package_direction.sh                            # ADR-012 import rules R1-R8 (must PASS)
make parse-check                                              # OpenSysML v0.11.0 over every .sysml file; fails on any error or non-baseline warning
```

## Marker Regen Commands

```bash
# From the vault (where db/ lives)
cd "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA"

# Single exporter, dry-run (preview to stdout)
python3 -c "import sys; sys.path.insert(0, 'db'); from exports.strata import regenerate_arch_strata; regenerate_arch_strata(dry_run=True)"

# Single exporter, live (writes to vault file)
python3 -c "import sys; sys.path.insert(0, 'db'); from exports.strata import regenerate_arch_strata; regenerate_arch_strata()"

# All exporters in a family
python3 -c "import sys; sys.path.insert(0, 'db'); from exports.strata import regenerate_strata_section; regenerate_strata_section()"
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
python3 scripts/reason_kg.py                       # Reason over the full ontology stack
python3 scripts/reason_kg.py --test-violation      # Inject contradiction, confirm reasoner catches it
python3 scripts/reason_kg.py --save-summary        # Save reasoning-summary.json (uses rdflib, no GraphDB)
```

## Infrastructure Dependencies

**GraphDB Free** (localhost:7200) is required by `validate_kg.py`, `diff_kg.py`, `setup_graphdb.py`. It is NOT required by:

- `reason_kg.py` — Robot + HermiT operate directly on Turtle files; `--save-summary` uses rdflib.
- `gen_owl_pipeline.py` — reads SysML, writes Turtle. No GraphDB dependency.
- `gen_model_introspection.py` — reads SysML, writes JSON. No GraphDB dependency.
- Console / portal dev servers — read static JSON, not GraphDB.

**Resolver service** (localhost:7310) is required for: writes to PostgreSQL-canonical content (concepts, EIL, harvest register, OW register, DCR, risks), substrate document mutations, and marker regeneration. Auto-started on login; status checks via `curl http://localhost:7310/healthz`.

If a task instruction says "run reason_kg.py --save-summary", do NOT attempt to load GraphDB or run validate_kg.py unless explicitly instructed. These are independent operations.

### Waiting on long runs

`make qa` (about 12 minutes), the stack's load tests and the spike's measurement series outlast a normal tool call. Wait on them in ways that end when the run ends.

1. **Run the command itself in the background** with your shell tool's background mode, and act on its completion notice. That needs no watcher.
2. **If you must wait on a log, poll the file in a bounded loop**, for example `for i in $(seq 1 360); do grep -q '^exit=' "$L" && break; sleep 5; done`.
3. **Never wait with `tail -f`.** Neither `grep -m1 -q PATTERN <(tail -n +1 -f "$L")` nor `tail -f "$L" | grep -m1 PATTERN` ends when the pattern appears. `grep` exits, but `tail` only notices on its next write, which never comes once the log stops growing, and the shell around it waits on `tail`. At S519 five such watchers sat idle for 8 to 11 hours, and one held a Desktop background task open overnight. macOS `tail` has no `--pid` option, so that is not a fix here.

## Cafe Demonstrator Commands

```bash
cd exercises/coffeeshop-demonstrator/
docker compose -f docker-compose.ehrbase.yml up -d  # Start EHRbase + PostgreSQL
pnpm dev:temporal                                     # Start Temporal worker
pnpm dev:web                                          # Start web frontend
pnpm generate                                         # Regenerate from SysML model (runs make gen-cafe)
```

## Critical Data Sync Rule

After running `gen_model_introspection.py --save`, sync to the console:

```bash
cd console && pnpm refresh-data
```

## SysML Conventions

- **Always check** `documentation/reference/gsl-sysml-v2-syntax-reference.md` before writing new `.sysml` code. Syside syntax differs from the SysML v2 spec.
- **Always check** `documentation/reference/KerML-Reserved-Words.md` before naming `part def`s, attributes, or other identifiers. `subject` is NOT KerML-reserved but IS a SysML v2 contextual keyword.
- **Doc blocks** on every `part def` or `metadata def` must include meta model classification: `/* business meta model concept */` or `/* system meta model concept */`. Under the strengthened A4, the doc block records the layer-and-side locus.
- **`part def` vs `part`:** A `part def` is a meta model concept (abstract definition). A `part` is an instance (concrete usage). Do not conflate them.
- **General vs Domain vs tenant:** metamodel content is General (sector-agnostic, in `BusinessMetamodelGeneral` or `SystemMetamodelGeneral`) or Domain (sector-specific, in a `…MetamodelDomain<Sector>` package; only `SystemMetamodelDomainClinical` exists). Content that belongs to one tenant goes in that tenant's packages under `exercises/`. The business side never imports the system side. See ADR-012.
- **Annotation placement (Position A):** All six BMM annotation types (`@CatalogueTag`, `@BfoType`, `@UserFacing`, `@PurposiveDescription`, `@Comprehension`, `@WeightedRelationship`) on a BMM General `part def` are placed **before** the `part def` declaration, in standard order. Inline placement parses but is not used.
- **Tenant projections carry doc blocks only.** No inline annotations on `part` usages or specialising `part def`s — annotation semantics are inherited via `:>` and instantiation. Putting an annotation on a `part` usage produces a "No Feature named '<attribute>' found" error; putting one on a specialising `part def` produces metaclass-binding ambiguity.
- **Enum value verification.** Before delivering any SysML referencing `EnumName::value`, verify each value against the actual `enum def` in source. Do not infer from semantics. (Discovered S275.)
- **Multi-package imports.** Each package needs its own `private import` for every enum/type referenced. Shared enums sit with the defs that use them in the General packages (for example `BusinessMetamodelGeneral::StakeholderModel`, `SystemMetamodelGeneral::LogicEngine`) and must be imported in every using package. (Discovered S275 in multi-package tenant projection; `Foundation` retired S515.)

## Development Principles

- **Co-evolution (J2):** Never add model content without tooling to make it legible. Never build tooling without model content to exercise it.
- **Non-constraining (J3):** Decisions should not foreclose future development paths.
- **Model generates everything (A3):** the canonical model — OWL 2 DL in the knowledge graph, with a SysML engineering projection for the parts that are projectable — is the single source of truth for generated artefacts. Generated code, documentation, configuration and console data are derived, not authoritative.
- **Cross-domain validation (J1):** New BMM concepts must validate in at least two demonstrators.
- **Discipline as load-bearing structure (A9):** Workflow practices propagate reliability through the platform. Skipping a step is not saving time — it is introducing structural risk.
- **The stage test (AC-17, programme mandate):** work is measured by whether the Cafe needs it to run as a genuine tenant at the current stage. An emergent possibility is captured in the EIL, not allowed to divert stage work. A Cafe-specific shortcut must not pass as platform-general (A13: only the metamodels are core).

## Commit Convention

- **Code commits at the end of a task** with a descriptive commit message, unless Ella has asked to review before committing. Do not leave uncommitted changes for Ella to commit manually.
- Commit messages reference the session number: `Session NN: description of changes`
- The vault repo and the SysML repo are committed independently. Vault material in vault repo, SysML repo material here. Ella drives the vault commit; Claude Code may handle the SysML repo commit.
- **Stage only the files your task changed** (`git add <path>`, never `git add -A`). **Never stage `documentation/reference/`**: those files are Ella's.
- **In a multi-agent (Pattern A) brief, only the orchestrator commits** to a shared repository; specialists return their changes uncommitted.

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

**Full reference:** See the `/vault` skill (`.claude/skills/vault/SKILL.md`) for complete command reference, and the vault's CLI reference document (slug `ontara-ref-guide-obsidian-cli-commands`) for the comprehensive command catalogue.

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
- Vault documents use `[[slug|display text]]` wikilinks — no plain text vault references. Links target the slug, which never changes; the resolver resolves it to the current filename at render (OP-127, OP-128).

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

---

*CLAUDE.md updated S359 (substrate / resolver / exporter section added; resolver commands added; marker regen commands added; substrate-canonical document class noted in Architecture in Brief). Tooling guide reference: vault slug `ontara-ref-guide-using-claude-tools`. DCR threshold 20 sessions. S431 housekeeping pass: nine-layer stack (OFL–PRL, S429) corrected from stale eight-strata text; layer-and-side locus terminology updated; resolver port verified at 7310. S516 (OP-132): repository layout, model files, package-direction check and General / Domain / tenant convention follow ADR-012. S517 currency pass: two canonical forms with SysML as projection (AC-19); steady state staged by mandate, current stage Plan B Stage 0, with the Stage 0 decisions taken so far (AC-17); tenants per the landing register (AC-18); BMM element counts; work items in Plane; resolver rename, no-trailing-slash and render-regeneration notes; Syside Editor in place of Modeler (S491); commit staging rules; slug-based vault references. S520: `make parse-check` named the SysML parse gate of record, Ella's Syside Editor check having been retired as a gate at S519.*
