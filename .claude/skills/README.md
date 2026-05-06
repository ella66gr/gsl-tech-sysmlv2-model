# Ontara — Claude Code Skills

Custom skills for the Ontara development workflow. These are loaded automatically by Claude Code and available as slash commands.

## Available Commands

### SysML-era skills

Skills covering SysML model authoring, console / portal / Cafe demonstrator dev surfaces, knowledge graph validation, and Obsidian vault operations.

| Command | Description |
|---|---|
| `/generate` | Regenerate `model-introspection.json` from SysML and sync to console. Use `/generate all` to run all generators. |
| `/console` | Start the Ontara Console dev server. Also: `/console build`, `/console refresh`. |
| `/coffeeshop` | Start the Cafe demonstrator (Docker + Temporal + Web). Also: `/coffeeshop stop`, `/coffeeshop generate`. |
| `/commit <session> <msg>` | Git commit with session-number convention. |
| `/syntax-check [term]` | Look up SysML syntax reference and KerML reserved words. |
| `/model-edit [file]` | Guided SysML model editing with safety checks. |
| `/archive <type> <path>` | Copy enriched documents from Obsidian vault to repo archive. |
| `/status` | Show repo state, generated file freshness, sync status, running services. |
| `/validate-kg` | Run the SPARQL validation suite and / or HermiT consistency checking on the ontology stack. |
| `/vault` | Obsidian CLI operations — read, create, move, search vault documents with wikilink preservation. |

### Substrate-era skills (added S359 W-142)

Skills covering the substrate / resolver / exporter machinery for marker-bound vault content. Authored to make handoffs from Chat to Code routine for build-script authoring, marker regeneration, resolver investigation, and database migration application.

| Command | Description |
|---|---|
| `/build-substrate-doc <slug>` | Author a `build_sNNN_*.py` script to create a substrate-canonical vault document via the resolver. Validates PM schema, runs dry-run, executes against the resolver, writes vault output, verifies marker pass-through. |
| `/regen-markers <marker-id-or-all>` | Run one or all marker exporters from `db/exports/`, with dry-run / live toggle and post-run frontmatter bump verification. |
| `/resolver-debug` | Inspect resolver state — running process, healthz, recent logs, registered specs, route inventory. |
| `/migration-apply <path>` | Apply a migration via `psql -f`, verify it ran, run the relevant export regen, record provenance. |

## Adding New Skills

Create a new directory under `.claude/skills/<name>/` with a `SKILL.md` file. Use YAML frontmatter for configuration (name, description, allowed-tools). See existing skills for the pattern.

A new skill is justified when (a) the same multi-step workflow has been run more than three times across recent sessions, (b) the workflow has steps that benefit from explicit ordering (dry-run before live, FK null before delete, etc.), or (c) the workflow is otherwise duplicated across multiple build scripts or instruction sets. Skills are **executable workflow** — the "how" — not the "what and why" (which lives in `CLAUDE.md`). One-off operations, single-command invocations, and architectural commitments do not justify a skill.

## Relationship to CLAUDE.md

`CLAUDE.md` (repo root) provides persistent project context loaded every session. Skills provide executable workflows invoked on demand. They are complementary — CLAUDE.md is the "what and why", skills are the "how".

For the standing reference on which Claude tool (Chat / Code / Cowork) is used for which work, see the vault document `02 ONTARA/02 Ontara DEVELOPMENT/Ontara REFERENCE & GUIDES/ontara-ref-guide-using-claude-tools.md` (Claude Tooling Guide v2). The Tooling Guide §6 specifies the canonical skills inventory; this README is the in-repo mirror of that inventory.
