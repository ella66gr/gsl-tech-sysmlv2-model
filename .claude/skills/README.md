# Ontara — Claude Code Skills

Custom skills for the Ontara development workflow. These are loaded automatically by Claude Code and available as slash commands.

## Available Commands

| Command | Description |
|---|---|
| `/generate` | Regenerate model-introspection.json from SysML and sync to console. Use `/generate all` to run all generators. |
| `/console` | Start the Ontara Console dev server. Also: `/console build`, `/console refresh` |
| `/coffeeshop` | Start the Coffee Shop demonstrator (Docker + Temporal + Web). Also: `/coffeeshop stop`, `/coffeeshop generate` |
| `/commit <session> <msg>` | Git commit with session-number convention |
| `/syntax-check [term]` | Look up SysML syntax reference and KerML reserved words |
| `/model-edit [file]` | Guided SysML model editing with safety checks |
| `/archive <type> <path>` | Copy enriched documents from Obsidian vault to repo archive |
| `/status` | Show repo state, generated file freshness, sync status, running services |

## Adding New Skills

Create a new directory under `.claude/skills/<name>/` with a `SKILL.md` file. Use YAML frontmatter for configuration (name, description, allowed-tools). See existing skills for the pattern.

## Relationship to CLAUDE.md

`CLAUDE.md` (repo root) provides persistent project context loaded every session. Skills provide executable workflows invoked on demand. They are complementary — CLAUDE.md is the "what and why", skills are the "how".
