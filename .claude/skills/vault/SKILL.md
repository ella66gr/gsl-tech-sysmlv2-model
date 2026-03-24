---
name: vault
description: Interact with the Obsidian vault via the Obsidian CLI (v1.12+). Read, create, append, prepend, move, delete, and search vault documents. Manage properties, tags, links, and tasks. Folder operations via eval workaround.
allowed-tools: Bash
---

# Obsidian Vault Operations

Interact with the GenderSense Obsidian vault using the official Obsidian CLI (v1.12+). Obsidian must be running. The CLI operates as a remote control for the running Obsidian app via IPC — all operations go through Obsidian's internal API, so file moves automatically update wikilinks and property changes are immediately indexed.

**Vault name:** GenderSense
**Vault path:** `/Users/ellagreen/Obsidian/GenderSense`
**Key content root:** `02 ONTARA ARCHITECTURE & MODELLING/`

## Important: vault parameter

The `vault=GenderSense` parameter must come **FIRST** after `obsidian`, before any command.

```bash
obsidian vault=GenderSense <command> [param=value ...] [flag ...]
```

Parameters use `key=value` format. Quote values with spaces. Flags are bare words (no `--` prefix), except `--copy`. For multiline content use `\n` for newline. File paths are relative to the vault root; `.md` extension is usually optional.

---

## Behavioural Guardrail

**If a CLI command fails, STOP and report the error to Ella.** Do NOT attempt workarounds using `eval`, JavaScript API calls, raw filesystem operations, or any other approach without explicit approval from Ella. This is a binding rule.

---

## File Operations

### Read a vault document

```bash
obsidian vault=GenderSense read file="02 ONTARA ARCHITECTURE & MODELLING/Ontara Platform Development/Ontara Reference & Guides/ontara-workflow-emergent-ideas-log.md"
```

### Create a new document

```bash
obsidian vault=GenderSense create name="02 ONTARA ARCHITECTURE & MODELLING/Ontara Platform Development/Ontara Session Reports, Prep & Handover/Sessions 61-70/session-63-preparation-note.md" content="# Session 63 Preparation Note\n\n..." silent
```

Use `silent` flag to prevent the note from opening in the Obsidian GUI.

### Create from template

```bash
obsidian vault=GenderSense create name="path/to/note" template="TemplateName"
```

### Append to a document

```bash
obsidian vault=GenderSense append file="02 ONTARA ARCHITECTURE & MODELLING/Ontara Platform Development/Ontara Reference & Guides/ontara-workflow-emergent-ideas-log.md" content="\n\n### E012 — New idea title\n\n..."
```

### Prepend to a document (after frontmatter)

```bash
obsidian vault=GenderSense prepend file="path/to/note.md" content="Inserted after frontmatter"
```

### Move a file (auto-updates wikilinks)

```bash
obsidian vault=GenderSense move file="old/path/note.md" to="new/folder/"
```

**CRITICAL: `move` works on FILES only, not folders.** For folder operations, see the Folder Operations section below.

### Delete a vault document

```bash
# Move to trash (default, safe)
obsidian vault=GenderSense delete file="path/to/note.md"

# Permanently delete (bypass trash — use with caution)
obsidian vault=GenderSense delete file="path/to/note.md" permanent
```

---

## Search

### Search by content (full-text)

```bash
obsidian vault=GenderSense search query="weighted relationship"
```

### Search with context (grep-like, shows surrounding lines)

```bash
obsidian vault=GenderSense search:context query="weighted relationship" limit=10
```

### Search with JSON output (for scripting)

```bash
obsidian vault=GenderSense search query="weighted relationship" format=json
```

---

## Listing and Discovery

### List all files

```bash
obsidian vault=GenderSense files
obsidian vault=GenderSense files total   # Count only
```

### List folder structure

```bash
obsidian vault=GenderSense folders
```

### File metadata

```bash
obsidian vault=GenderSense file file="path/to/note"
```

### Heading outline

```bash
obsidian vault=GenderSense outline file="path/to/note"
```

---

## Properties (Frontmatter)

### Read all properties

```bash
obsidian vault=GenderSense properties file="path/to/note"
```

### Read a specific property

```bash
obsidian vault=GenderSense property:read path="path/to/note" name="status"
```

### Set a property

```bash
obsidian vault=GenderSense property:set path="path/to/note" name="status" value="active"
```

### Remove a property

```bash
obsidian vault=GenderSense property:remove path="path/to/note" name="draft"
```

**Note:** `property:set` stores values as strings. For list-type values, edit frontmatter directly or use `eval` (with Ella's approval).

---

## Tags

```bash
obsidian vault=GenderSense tags                          # List all tags
obsidian vault=GenderSense tags counts sort=count        # Tags with counts, sorted
obsidian vault=GenderSense tag tag="#ontara"              # Files with a specific tag
obsidian vault=GenderSense tags:rename old=meeting new=meetings  # Bulk rename
```

---

## Links

```bash
obsidian vault=GenderSense links file="note"             # Outgoing links
obsidian vault=GenderSense backlinks file="note"         # Incoming links
obsidian vault=GenderSense unresolved                    # Broken wikilinks
obsidian vault=GenderSense orphans                       # Notes with no incoming links
obsidian vault=GenderSense deadends                      # Notes with no outgoing links
```

---

## Tasks

```bash
obsidian vault=GenderSense tasks                         # All incomplete tasks
obsidian vault=GenderSense tasks all                     # All tasks (done + todo)
obsidian vault=GenderSense tasks done                    # Completed only
obsidian vault=GenderSense task path="note" line=12 toggle  # Toggle completion
```

---

## Daily Notes

```bash
obsidian vault=GenderSense daily                         # Open today's daily note
obsidian vault=GenderSense daily:read                    # Print today's content
obsidian vault=GenderSense daily:append content="- [ ] Task"   # Append to today
obsidian vault=GenderSense daily:prepend content="## Morning"  # Prepend to today
obsidian vault=GenderSense daily:path                    # Show daily note path
```

---

## Folder Operations (eval workaround)

The CLI has no native folder rename/move command. Use `eval` with `app.fileManager.renameFile()` in an async IIFE pattern. **This requires explicit approval from Ella.**

### Rename a single folder

```bash
obsidian vault=GenderSense eval code="(async () => { const f = app.vault.getAbstractFileByPath('02 ONTARA ARCHITECTURE & MODELLING/Ontara - START HERE'); if (f) { await app.fileManager.renameFile(f, '02 ONTARA ARCHITECTURE & MODELLING/01 Ontara - START HERE'); return 'done'; } return 'not found'; })()"
```

### Important notes on eval

- `app.fileManager.renameFile()` goes through Obsidian's API, so wikilinks are updated automatically.
- The async IIFE `(async () => { ... })()` is required because `renameFile` is asynchronous.
- Always verify the result — `'done'` means success, `'not found'` means the path was wrong.
- Allow a short pause (1 second) between sequential folder renames to let Obsidian process.
- `eval` uses internal API that may change across Obsidian versions. Use standard commands when possible.

---

## Not Supported / Workarounds

| Operation | Status | Workaround |
|---|---|---|
| **Folder rename/move** | Not a CLI command | `eval` with `app.fileManager.renameFile()` (see above) |
| **Setting list-type properties** | `property:set` stores as string | Edit frontmatter directly or use `eval` |
| **Complex plugin config** | Not exposed via CLI | Edit `data.json` with Obsidian closed |
| **High-volume bulk operations (3000+ files)** | Sequential CLI is slow | Use Python scripts for bulk processing |
| **Editing existing note content (find-and-replace)** | No CLI command | Read via CLI, edit externally, or use `eval` |

---

## Key Vault Locations

| What | Path from vault root |
|---|---|
| Reference & Guides | `02 ONTARA ARCHITECTURE & MODELLING/02 Ontara Platform Development/Ontara Reference & Guides/` |
| Session Reports (61-70) | `02 ONTARA ARCHITECTURE & MODELLING/02 Ontara Platform Development/Ontara Session Reports, Prep & Handover/Sessions 61-70/` |
| Plans (Stage 4) | `02 ONTARA ARCHITECTURE & MODELLING/02 Ontara Platform Development/Ontara Plans/Stage 4/` |
| Emergent Ideas Log | `02 ONTARA ARCHITECTURE & MODELLING/02 Ontara Platform Development/Ontara Reference & Guides/ontara-workflow-emergent-ideas-log.md` |
| Master Register | `02 ONTARA ARCHITECTURE & MODELLING/02 Ontara Platform Development/Ontara Reference & Guides/ontara-ref-master-register-design-concepts-tiered-2026-03-20.md` |
| Concept Graph | `02 ONTARA ARCHITECTURE & MODELLING/03 Ontara Concept Graph/` |
| Foundations | `02 ONTARA ARCHITECTURE & MODELLING/04 Ontara Foundations/` |
| Discussion Papers | `02 ONTARA ARCHITECTURE & MODELLING/05 Ontara Exploratory & Discussion Papers/` |
| Demonstrators | `02 ONTARA ARCHITECTURE & MODELLING/06 Ontara Demonstrators/` |
| CLI Reference | `02 ONTARA ARCHITECTURE & MODELLING/02 Ontara Platform Development/Ontara Reference & Guides/ontara-ref-obsidian-cli-command-reference.md` |

---

## Wikilink Convention

All vault documents must use `[[filename|display text]]` wikilinks for internal references. When creating or appending content, always use wikilinks — never plain text vault references. This is a binding commitment (A9).

---

## Getting Help

```bash
obsidian help              # List all commands
obsidian help <command>    # Help for a specific command
```

`obsidian help` is always authoritative for the installed version. If something in this skill file contradicts `obsidian help`, the help output is correct.

---

## Output Formats

Several commands support `format=` for different output:

| Format | Use case |
|---|---|
| `text` | Human-readable (default) |
| `json` | Pipe through `jq` or programmatic use |
| `csv` / `tsv` | Spreadsheet export |
| `paths` | File paths only (for piping) |

Check `obsidian help <command>` for supported formats per command.
