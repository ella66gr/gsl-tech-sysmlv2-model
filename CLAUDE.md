# Ontara — Claude Code Project Context

## What This Is

Ontara is a service system development and delivery platform built on SysML v2. The SysML model is the single source of truth — it generates everything. The primary production use case is GenderSense Limited (GSL), a private gender-affirming healthcare service. The sole developer and architect is Ella Green.

## Architecture in Brief

- **Two meta models:** Business Meta Model (BMM — what a service business *is*) and Business System Meta Model (BSMM — how a system *works*). They are distinct and connected by explicit mappings.
- **Six layers:** L6 SysML v2 language → L5 BMM → L4 BSMM → L3 Business model instances → L2 System model instances → L1 Runtime
- **Three demonstrator domains:** Cafe (coffee shop, full app), Suds (laundry, BMM only), Paws (dog grooming, BMM only) — used for cross-domain validation
- **Comprehension architecture:** Every BMM element has @UserFacing, @PurposiveDescription, @Comprehension, and @WeightedRelationship annotations. 28/28 coverage, 79 weighted relationships.

## Repository Layout

```
model/                     # Core SysML v2 model (11 .sysml files)
exercises/
  coffeeshop-demonstrator/ # Full running app (SvelteKit + Temporal + EHRbase + PostgreSQL)
  suds-demonstrator/       # Laundry BMM instance
  paws-demonstrator/       # Dog grooming BMM instance
console/                   # Ontara Console (SvelteKit + Svelte 5 runes + Flowbite Svelte + Tailwind v4)
scripts/                   # Python generators and shell tools
generated/                 # All generated output (DO NOT EDIT manually)
  ontara/model-introspection.json  # Console data source
documentation/
  reference/               # SysML syntax ref, KerML reserved words
  archive/                 # Committed snapshots (strategic, plans, session-reports, design)
libraries/                 # Shared libraries
concept-graph/             # Generated concept graph (Mermaid + Obsidian)
spikes/                    # Experimental code
```

## Key File Paths

- **SysML model files:** `model/*.sysml` (11 files: business-model, foundation, knowledge, service-delivery, platform, operations, enterprise, business-scenarios, business-strategy, pattern-catalogue, gendersense)
- **Demonstrator models:** `exercises/coffeeshop-demonstrator/model/`, `exercises/suds-demonstrator/`, `exercises/paws-demonstrator/`
- **Console app:** `console/` (SvelteKit, uses pnpm)
- **Console data:** `console/static/data/model-introspection.json` (copied from `generated/ontara/`)
- **Introspection generator:** `scripts/gen_model_introspection.py`
- **Other generators:** `scripts/gen_concept_graph.py`, `scripts/gen_package_hierarchy.py`, `scripts/gen_system_manifest.py`, `scripts/gen_constraint_evaluator.py`, `scripts/gen_decision_table_evaluator.py`, `scripts/projection_engine.py`
- **SysML syntax reference:** `documentation/reference/gsl-sysml-v2-syntax-reference.md`
- **KerML reserved words:** `documentation/reference/KerML-Reserved-Words.md`
- **Existing CLI tool:** `scripts/gsl` (shell script for package hierarchy views)

## Tech Stack

- **Console:** SvelteKit + Svelte 5 (runes) + Flowbite Svelte + Tailwind v4. Package manager: pnpm.
- **Coffee Shop Demonstrator:** SvelteKit + Temporal (workflow engine) + EHRbase (CDR) + PostgreSQL. pnpm workspace monorepo with packages: web, temporal, shared.
- **Generators:** Python 3. No virtual env required — standard library plus regex parsing.
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
- **Metadata annotations:** `@CatalogueTag`, `@UserFacing`, `@PurposiveDescription`, `@Comprehension`, `@WeightedRelationship` — all in the Foundation metadata library.

## Development Principles

- **Co-evolution (J2):** Never add model content without tooling to make it legible. Never build tooling without model content to exercise it.
- **Non-constraining (J3):** Decisions should not foreclose future development paths.
- **Model generates everything (A3):** SysML is the single source of truth.
- **Cross-domain validation (J1):** New BMM concepts must validate in at least two demonstrator domains.

## Commit Convention

- Commit messages reference the session number: `Session NN: description of changes`
- Repo archive paths: `documentation/archive/strategic/`, `documentation/archive/plans/`, `documentation/archive/session-reports/`, `documentation/archive/design/`

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
