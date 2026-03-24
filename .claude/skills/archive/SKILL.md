---
name: archive
description: Archive documents from the Obsidian vault to the repo documentation/archive
allowed-tools: Bash
disable-model-invocation: true
---

# Archive Documents to Repo

Copy enriched documents from the Obsidian vault to the repo archive. Documents must be wikilink-enriched in the vault BEFORE archiving.

## Usage

`/archive <type> <source-path>`

Where `<type>` is one of:
- `strategic` → `documentation/archive/strategic/`
- `plan` → `documentation/archive/plans/`
- `session-report` → `documentation/archive/session-reports/`
- `design` → `documentation/archive/design/`

## Example

```
/archive session-report "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA ARCHITECTURE & MODELLING/Ontara Platform Development/Ontara Session Reports, Prep & Handover/Sessions 61-70/session-61-report-2026-03-23.md"
```

## Steps

1. Verify the source file exists.
2. Copy to the appropriate archive directory.
3. Show the git commands to stage the new file:
   ```bash
   git add documentation/archive/<type>/<filename>
   ```
4. Do NOT commit — that's a separate step via `/commit`.

## Notes

- Preparation notes are vault-only. Do NOT archive them to the repo.
- The vault path is: `/Users/ellagreen/Obsidian/GenderSense/`
- Always verify with Ella that wikilink enrichment is complete before archiving.
