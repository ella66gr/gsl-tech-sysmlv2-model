# Ontara — Claude Code Project Context

## What This Is

Ontara is a service system development and delivery platform built on SysML v2. The SysML model is the single source of truth — it generates everything. The primary production use case is GenderSense Limited (GSL), a private gender-affirming healthcare service. The sole developer and architect is Ella Green.

## Architecture in Brief

- **Two meta models:** Business Meta Model (BMM — what a service business *is*) and Service Meta Model (SMM — how a system *works*). They are distinct and connected by explicit mappings. Note: SMM was previously called BSMM (Business System Meta Model). Renamed Session 92. The SysML section name `bsmm-general-vocabulary` is a structural identifier and stays.
- **Six layers:** L6 SysML v2 language → L5 BMM → L4 SMM → L3 Business model instances → L2 System model instances → L1 Runtime
- **Three demonstrator domains:** Cafe (coffee shop, full app), Suds (laundry, BMM only), Paws (dog grooming, BMM only) — used for cross-domain validation
- **Six BMM concerns:** ServiceConcept, ActivityModel, ResourcePlanning, FinancialPlanning, GovernanceMapping, StakeholderModel (Session 81). 34 General elements.
- **Comprehension architecture:** Every BMM element has @BfoType, @UserFacing, @PurposiveDescription, @Comprehension, and @WeightedRelationship annotations. 34/34 coverage, 96 weighted relationships. @BfoType maps each element to its BFO 2020 category and mid-level ontology parent.
- **Knowledge graph (Stage 5):** Dual-formalism platform — SysML v2 for structure, OWL 2 DL for ontological semantics. BFO 2020 as upper ontology, CCO + IAO as mid-level. GraphDB Free as triple store. Three-stratum graph: metamodel / domain / correspondence. Full OWL 2 DL reasoning via HermiT (Robot). Phase 2 Block A complete: disjointness axioms, 14 object properties, existential/cardinality restrictions, 96 reified weighted relationships. 7-file ontology stack reasons consistent.

## Repository Layout

```
model/                     # Core SysML v2 model (12 .sysml files)
exercises/
  coffeeshop-demonstrator/ # Full running app (SvelteKit + Temporal + EHRbase + PostgreSQL)
  suds-demonstrator/       # Laundry BMM instance
  paws-demonstrator/       # Dog grooming BMM instance
console/                   # Ontara Console (SvelteKit + Svelte 5 runes + Flowbite Svelte + Tailwind v4)
scripts/                   # Python generators, shared modules, and shell tools
  archive/                 # Archived superseded generators (with provenance)
  reason_kg.py             # OWL 2 DL reasoning via Robot + HermiT
generated/                 # All generated output (DO NOT EDIT manually)
  ontara/model-introspection.json  # Console data source
  ontology/                # Generated OWL/Turtle and mapping IR (5 files)
ontology/                  # Knowledge graph config and imported ontologies
  axioms/                  # Hand-authored OWL axioms (ontara-bmm-axioms.ttl)
  config/                  # Mapping rules (YAML), CCO IRI lookup (JSON)
  imports/                 # BFO 2020, CCO, IAO ontology files
  catalog-v001.xml         # XML catalog for Robot IRI resolution
tools/                     # External tooling
  robot.jar                # Robot OWL tool (wraps HermiT reasoner)
documentation/
  reference/               # SysML syntax ref, KerML reserved words
  archive/                 # Committed snapshots (strategic, plans, session-reports, design)
libraries/                 # Shared libraries
concept-graph/             # Generated concept graph (Mermaid + Obsidian)
spikes/                    # Experimental code
```

## Key File Paths

- **SysML model files:** `model/*.sysml` (12 files: architectural-structure, business-model, business-scenarios, business-strategy, enterprise, foundation, gendersense, knowledge, operations, pattern-catalogue, platform, service-delivery)
- **Demonstrator models:** `exercises/coffeeshop-demonstrator/model/`, `exercises/suds-demonstrator/`, `exercises/paws-demonstrator/`
- **Console app:** `console/` (SvelteKit, uses pnpm)
- **Console data:** `console/static/data/model-introspection.json` (copied from `generated/ontara/`)
- **Introspection generator:** `scripts/gen_model_introspection.py`
- **OWL pipeline generator:** `scripts/gen_owl_pipeline.py` (Stage 5 — reads SysML, classifies via mapping rules, outputs OWL/Turtle)
- **Shared SysML parser:** `scripts/sysml_parser.py` (used by introspection and OWL pipeline generators)
- **GraphDB setup:** `scripts/setup_graphdb.py`
- **OWL 2 DL reasoner:** `scripts/reason_kg.py` (HermiT via Robot)
- **Hand-authored axioms:** `ontology/axioms/ontara-bmm-axioms.ttl` (disjointness, object properties, restrictions)
- **Robot JAR:** `tools/robot.jar` (OWL tool, wraps HermiT)
- **XML catalog:** `ontology/catalog-v001.xml` (local IRI resolution for Robot/Protégé)
- **Other generators:** `scripts/gen_concept_graph.py`, `scripts/gen_package_hierarchy.py`, `scripts/gen_system_manifest.py`, `scripts/gen_constraint_evaluator.py`, `scripts/gen_decision_table_evaluator.py`, `scripts/projection_engine.py`
- **Mapping rules:** `ontology/config/mapping-rules.yaml` (declarative classification rules for SysML→OWL)
- **CCO IRI lookup:** `ontology/config/cco-iri-lookup.json` (opaque CCO IRIs resolved from GraphDB)
- **SysML syntax reference:** `documentation/reference/gsl-sysml-v2-syntax-reference.md`
- **KerML reserved words:** `documentation/reference/KerML-Reserved-Words.md`
- **Existing CLI tool:** `scripts/ontara` (shell script for package hierarchy views — renamed from `gsl` Session 65)

## Tech Stack

- **Console:** SvelteKit + Svelte 5 (runes) + Flowbite Svelte + Tailwind v4. Package manager: pnpm.
- **Coffee Shop Demonstrator:** SvelteKit + Temporal (workflow engine) + EHRbase (CDR) + PostgreSQL. pnpm workspace monorepo with packages: web, temporal, shared.
- **Generators:** Python 3. No virtual env required. Introspection generator uses standard library only. OWL pipeline generator requires `rdflib` and `PyYAML` (`pip3 install rdflib PyYAML`).
- **Knowledge graph:** GraphDB Free 10.x (local Java app, port 7200). Robot (wraps HermiT reasoner, `tools/robot.jar`) for full OWL 2 DL consistency checking. Protégé 5.6+ for ontology debugging. BFO 2020 + CCO 2.0 + IAO as imported ontologies. Reasoning runtime ~10 minutes with 7-file stack.
- **Model editing:** Syside Modeler (VS Code extension for SysML v2). Claude cannot run Syside — only Ella can verify SysML parses.

## Console Commands

```bash
# From repo root
cd console
pnpm dev              # Start console dev server (usually http://localhost:5173)
pnpm build            # Production build
pnpm run refresh-data # Copy generated JSON to console static dir
```

## Generator Commands

```bash
# From repo root
python3 scripts/gen_model_introspection.py --save --pretty   # Generate console data
python3 scripts/gen_concept_graph.py                          # Generate concept graph
python3 scripts/gen_package_hierarchy.py                      # View package hierarchy
python3 scripts/gen_system_manifest.py --save                 # Generate manifest
python3 scripts/gen_constraint_evaluator.py --save            # Generate constraint evaluators
python3 scripts/gen_decision_table_evaluator.py --save        # Generate decision tables
```

## Knowledge Graph Commands

```bash
# From repo root
python3 scripts/gen_owl_pipeline.py --save         # Generate OWL ontology + correspondence + mapping IR
python3 scripts/gen_owl_pipeline.py --validate      # Compare output to baseline (graph isomorphism)
python3 scripts/gen_owl_pipeline.py --resolve-cco   # Populate CCO IRI lookup from GraphDB
python3 scripts/gen_owl_pipeline.py --verify         # Check CCO lookup completeness
python3 scripts/gen_owl_pipeline.py --ir-only        # Print mapping IR (classification) only
python3 scripts/gen_owl_pipeline.py --dry-run        # Print Turtle to stdout
python3 scripts/setup_graphdb.py --verify            # Verify GraphDB repository state
python3 scripts/validate_kg.py                   # Validate KG against SPARQL test suite
python3 scripts/validate_kg.py --load             # Reload pipeline output into GraphDB + validate
python3 scripts/validate_kg.py --load-only        # Reload pipeline output into GraphDB

# OWL 2 DL Reasoning (requires Java 11+, tools/robot.jar)
python3 scripts/reason_kg.py                       # Reason over full 7-file ontology stack
python3 scripts/reason_kg.py --verbose             # Show detailed output
python3 scripts/reason_kg.py --test-violation      # Inject contradiction, confirm reasoner catches it
python3 scripts/reason_kg.py --output results      # Save inferred ontology to file
```

Generated ontology outputs (in `generated/ontology/`):
- `ontara-bmm.ttl` — domain ontology (34 OWL classes)
- `ontara-bmm-properties.ttl` — 14 object properties with domains, ranges, and characteristics
- `ontara-bmm-weights.ttl` — 96 reified weighted relationship individuals
- `ontara-correspondence.ttl` — SysML↔OWL mapping records (class + property + weight)
- `mapping-ir.json` — full classification intermediate representation

Hand-authored axiom file (in `ontology/axioms/`):
- `ontara-bmm-axioms.ttl` — disjointness declarations, existential/cardinality restrictions (OWL-authoritative per B29)

## Coffee Shop Demonstrator Commands

```bash
# From exercises/coffeeshop-demonstrator/
docker compose -f docker-compose.ehrbase.yml up -d  # Start EHRbase + PostgreSQL
pnpm dev:temporal                                     # Start Temporal worker
pnpm dev:web                                          # Start web frontend
pnpm generate                                         # Regenerate from SysML model
```

## Critical Data Sync Rule

After running `gen_model_introspection.py --save`, always sync to the console:
```bash
cp generated/ontara/model-introspection.json console/static/data/model-introspection.json
```
Or use `cd console && pnpm run refresh-data`.

## SysML Conventions

- **Always check** `documentation/reference/gsl-sysml-v2-syntax-reference.md` before writing new `.sysml` code. Syside syntax differs from the SysML v2 spec.
- **Always check** `documentation/reference/KerML-Reserved-Words.md` before choosing names for part defs, attributes, or other identifiers. `subject` is NOT reserved in KerML but IS a SysML v2 contextual keyword.
- **Doc blocks** on every `part def` must include meta model classification (Business Meta Model or Business System Meta Model).
- **`part def` vs `part`:** A `part def` is a meta model concept (abstract definition). A `part` is an instance (concrete usage). Do not conflate them.
- **General vs Tailored:** BMM components are classified as General (common to most service businesses) or Tailored (sector-specific).
- **Metadata annotations:** `@CatalogueTag`, `@BfoType`, `@UserFacing`, `@PurposiveDescription`, `@Comprehension`, `@WeightedRelationship`, `@ArchitecturalLocation` — all in the Foundation metadata library. Canonical ordering: CatalogueTag → BfoType → UserFacing → PurposiveDescription → Comprehension → WeightedRelationship(s).

## Development Principles

- **Co-evolution (J2):** Never add model content without tooling to make it legible. Never build tooling without model content to exercise it.
- **Non-constraining (J3):** Decisions should not foreclose future development paths.
- **Model generates everything (A3):** SysML is the single source of truth.
- **Cross-domain validation (J1):** New BMM concepts must validate in at least two demonstrator domains.

## Commit Convention

- **Code should always commit at the end of a task**, with a descriptive commit message, unless there is a specific reason not to (e.g. Ella has asked to review before committing). Do not leave uncommitted changes for Ella to commit manually.
- Commit messages reference the session number: `Session NN: description of changes`
- Repo archive paths: `documentation/archive/strategic/`, `documentation/archive/plans/`, `documentation/archive/session-reports/`, `documentation/archive/design/`

## Ontara Toolkit

The `ontara` shell script (`scripts/ontara`) provides quick access to the package hierarchy:
```bash
ontara              # Terminal tree view (default)
ontara save         # Export all formats (Markdown, OPML, HTML, OmniOutliner)
ontara html         # Export and open interactive mindmap
ontara oo           # Export and open in OmniOutliner
ontara diff         # Compare model vs proposal
ontara files        # List model and generated files
ontara model        # Open repo in VS Code
ontara help         # Show all commands
```

Set up alias in `~/.zshrc`:
```bash
alias ontara='~/Developer/gsl-tech/gsl-sysml-model/scripts/ontara'
```

## Obsidian Vault (via CLI)

The Obsidian CLI (v1.12+, GA) provides terminal control of the running Obsidian Desktop app via IPC. All operations go through Obsidian's internal API — file moves auto-update wikilinks, property changes are immediately indexed.

**Prerequisites:** Obsidian must be running. CLI enabled in Settings → General. The vault parameter must come first.

**Full reference:** See the `/vault` skill (`.claude/skills/vault/SKILL.md`) for complete command reference with all syntax details, and the vault's CLI reference document (`ontara-ref-obsidian-cli-command-reference.md`) for the comprehensive 130+ command catalogue.

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

# Search (full-text, with context, or JSON output)
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
obsidian vault=GenderSense unresolved    # Broken wikilinks
obsidian vault=GenderSense orphans       # Notes with no incoming links

# Tags
obsidian vault=GenderSense tags counts sort=count
obsidian vault=GenderSense tags:rename old=oldtag new=newtag

# Help (always authoritative for installed version)
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
- Ontara content root: `02 ONTARA ARCHITECTURE & MODELLING/`
- File paths are relative to vault root; `.md` extension usually optional
- Always use `obsidian move` instead of raw `mv` — the CLI preserves wikilinks
- All vault documents must use `[[filename|display text]]` wikilinks — no plain text vault references



---

## Working With Ella

- Ella leads all design and architectural decisions. Ask before making non-trivial changes.
- The Obsidian vault at `/Users/ellagreen/Obsidian/GenderSense/` is the primary working environment for documents and planning. Claude Code can access the vault via the Obsidian CLI (`/vault` skill). Claude Chat accesses it via MCP filesystem tools.
- Do not overwrite files Ella may have edited without checking first.
- "Shall I go ahead?" is a genuine question, not rhetorical.
