---
name: vault
description: Interact with the Obsidian vault via the Obsidian CLI. Read, create, append, and search vault documents.
allowed-tools: Bash
---

# Obsidian Vault Operations

Interact with the GenderSense Obsidian vault using the Obsidian CLI. Obsidian must be running.

**Vault name:** GenderSense
**Vault path:** `/Users/ellagreen/Obsidian/GenderSense`
**Key content root:** `02 ONTARA ARCHITECTURE & MODELLING/`

## Important: vault parameter

The `vault=GenderSense` parameter must come FIRST after `obsidian`, before any command.

## Commands

### Read a vault document

```bash
obsidian vault=GenderSense read file="02 ONTARA ARCHITECTURE & MODELLING/Ontara Platform Development/Ontara Reference & Guides/ontara-workflow-emergent-ideas-log.md"
```

### Create a new document

```bash
obsidian vault=GenderSense create name="02 ONTARA ARCHITECTURE & MODELLING/Ontara Platform Development/Ontara Session Reports, Prep & Handover/Sessions 61-70/session-62-preparation-note.md" content="# Session 62 Preparation Note\n\n..."
```

### Append to a document (e.g. Emergent Ideas Log)

```bash
obsidian vault=GenderSense append file="02 ONTARA ARCHITECTURE & MODELLING/Ontara Platform Development/Ontara Reference & Guides/ontara-workflow-emergent-ideas-log.md" content="\n\n### E010 — New idea title\n\n..."
```

### Search vault by filename/path

```bash
obsidian vault=GenderSense search query="ontara-ref-strategic"
```

### Search vault content

```bash
obsidian vault=GenderSense search:context query="weighted relationship"
```

## Usage with arguments

- `/vault read <relative-path>` — Read a vault document
- `/vault append <relative-path> <content>` — Append content to a document
- `/vault create <relative-path> <content>` — Create a new document
- `/vault search <query>` — Search by filename
- `/vault search-content <query>` — Search by content

## Key vault locations

| What | Path from vault root |
|---|---|
| Reference & Guides | `02 ONTARA ARCHITECTURE & MODELLING/Ontara Platform Development/Ontara Reference & Guides/` |
| Session Reports (61-70) | `02 ONTARA ARCHITECTURE & MODELLING/Ontara Platform Development/Ontara Session Reports, Prep & Handover/Sessions 61-70/` |
| Plans (Stage 4) | `02 ONTARA ARCHITECTURE & MODELLING/Ontara Platform Development/Ontara Plans/Stage 4/` |
| Emergent Ideas Log | `02 ONTARA ARCHITECTURE & MODELLING/Ontara Platform Development/Ontara Reference & Guides/ontara-workflow-emergent-ideas-log.md` |
| Master Register | `02 ONTARA ARCHITECTURE & MODELLING/Ontara Platform Development/Ontara Reference & Guides/ontara-ref-master-register-design-concepts-tiered-2026-03-20.md` |
| Concept Graph | `02 ONTARA ARCHITECTURE & MODELLING/Ontara Concept Graph/` |
| Foundations | `02 ONTARA ARCHITECTURE & MODELLING/Ontara Foundations/` |
| Discussion Papers | `02 ONTARA ARCHITECTURE & MODELLING/Ontara Exploratory & Discussion Papers/` |
| Demonstrators | `02 ONTARA ARCHITECTURE & MODELLING/Ontara Demonstrators/` |

## Wikilink convention

All vault documents must use `[[filename|display text]]` wikilinks for internal references. When creating or appending content, always use wikilinks — never plain text vault references. This is a binding commitment (A9).

## Notes

- Obsidian must be running for the CLI to work.
- File paths are relative to the vault root, not absolute filesystem paths.
- The CLI operates through the Obsidian app, so changes trigger Obsidian's sync and link-update mechanisms.
- Always check that the vault parameter comes first: `obsidian vault=GenderSense <command>`.
