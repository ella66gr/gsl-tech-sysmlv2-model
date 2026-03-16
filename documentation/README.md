# Documentation

## How documentation works in this project

Documents are authored and maintained in the **GenderSense Obsidian vault** (`~/Obsidian/GenderSense`). The Obsidian vault is the primary knowledge base — documents there are enriched with cross-references, wikilinks, and frontmatter, and sync across devices via Obsidian Sync.

This directory holds **crystallised snapshots** committed at the point of completion. The Obsidian version may subsequently diverge (corrections, enrichment, annotation) and that divergence is intentional — the two copies serve different purposes.

## Directory structure

```
documentation/
├── README.md          ← this file
├── archive/           ← frozen copies of completed documents
│   ├── design/        ← architecture papers, strategic snapshots, discussions
│   ├── session-reports/  ← session reports (S00–S34)
│   ├── plans/         ← implementation plans (CSW, BMM, KL, GSL)
│   └── guides/        ← repo conventions, tooling guides
├── reference/         ← LIVE: syntax reference, KerML docs (updated each session)
└── generated/         ← LIVE: build artefacts (package hierarchy outputs)
```

## Workflow for new documents

1. Author the document in the Obsidian vault (in its permanent location, with wikilinks and frontmatter)
2. At session end, copy the document into `archive/` under the appropriate subdirectory
3. Commit with a message noting it's the as-completed snapshot

## Session numbering

Sessions use a global sequence (S00–S34 as of March 2026). The session reports in `archive/session-reports/` use disambiguated filenames: `gsl-session-report-YYYY-MM-DD-sNN.md`.

## See also

- `GSL-Obsidian-Documentation-Migration-Plan.md` in the Obsidian vault (`00 INDEX/`)
- `Session Index.md` in the Obsidian vault (`10 DEVELOPMENT LOG/`)
