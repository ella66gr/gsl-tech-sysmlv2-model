#!/bin/bash
# GSL Documentation Archive Script
# Moves completed documentation into archive/, leaves reference/ and generated/ live.
# Creates a README explaining the arrangement.
#
# Run from: ~/Developer/gsl-tech/gsl-sysml-model

set -euo pipefail

REPO="$HOME/Developer/gsl-tech/gsl-sysml-model"
DOCS="$REPO/documentation"
ARCHIVE="$DOCS/archive"

echo "=== Step 1: Create archive directory structure ==="

mkdir -p "$ARCHIVE/design/architecture"
mkdir -p "$ARCHIVE/design/strategic/history-snapshot"
mkdir -p "$ARCHIVE/design/strategic/history-analysis-and-priorities"
mkdir -p "$ARCHIVE/session-reports/session history"
mkdir -p "$ARCHIVE/plans/csw"
mkdir -p "$ARCHIVE/plans/gsl/business meta model"
mkdir -p "$ARCHIVE/plans/gsl/knowledge-layer"
mkdir -p "$ARCHIVE/guides"

echo "  Directory structure created"

echo ""
echo "=== Step 2: Move files to archive ==="

# design/architecture/ — all .md files
for f in "$DOCS/design/architecture"/*.md; do
  [ -f "$f" ] && mv "$f" "$ARCHIVE/design/architecture/"
done
echo "  Moved: design/architecture/*.md"

# design/strategic/ — top-level .md files
for f in "$DOCS/design/strategic"/*.md; do
  [ -f "$f" ] && mv "$f" "$ARCHIVE/design/strategic/"
done
echo "  Moved: design/strategic/*.md"

# design/strategic/history-snapshot/
for f in "$DOCS/design/strategic/history-snapshot"/*.md; do
  [ -f "$f" ] && mv "$f" "$ARCHIVE/design/strategic/history-snapshot/"
done
echo "  Moved: design/strategic/history-snapshot/*.md"

# design/strategic/history-analysis-and-priorities/
for f in "$DOCS/design/strategic/history-analysis-and-priorities"/*.md; do
  [ -f "$f" ] && mv "$f" "$ARCHIVE/design/strategic/history-analysis-and-priorities/"
done
echo "  Moved: design/strategic/history-analysis-and-priorities/*.md"

# session-reports/ — top-level .md file(s)
for f in "$DOCS/session-reports"/*.md; do
  [ -f "$f" ] && mv "$f" "$ARCHIVE/session-reports/"
done
echo "  Moved: session-reports/*.md"

# session-reports/session history/
for f in "$DOCS/session-reports/session history"/*.md; do
  [ -f "$f" ] && mv "$f" "$ARCHIVE/session-reports/session history/"
done
echo "  Moved: session-reports/session history/*.md"

# plans/csw/
for f in "$DOCS/plans/csw"/*.md; do
  [ -f "$f" ] && mv "$f" "$ARCHIVE/plans/csw/"
done
echo "  Moved: plans/csw/*.md"

# plans/gsl/ — top-level .md files
for f in "$DOCS/plans/gsl"/*.md; do
  [ -f "$f" ] && mv "$f" "$ARCHIVE/plans/gsl/"
done
echo "  Moved: plans/gsl/*.md"

# plans/gsl/business meta model/
for f in "$DOCS/plans/gsl/business meta model"/*.md; do
  [ -f "$f" ] && mv "$f" "$ARCHIVE/plans/gsl/business meta model/"
done
echo "  Moved: plans/gsl/business meta model/*.md"

# plans/gsl/knowledge-layer/
for f in "$DOCS/plans/gsl/knowledge-layer"/*.md; do
  [ -f "$f" ] && mv "$f" "$ARCHIVE/plans/gsl/knowledge-layer/"
done
echo "  Moved: plans/gsl/knowledge-layer/*.md"

# guides/
for f in "$DOCS/guides"/*.md; do
  [ -f "$f" ] && mv "$f" "$ARCHIVE/guides/"
done
echo "  Moved: guides/*.md"

echo ""
echo "=== Step 3: Clean up empty directories ==="

# Remove now-empty source directories (only if empty, ignore errors)
rmdir "$DOCS/design/strategic/history-snapshot" 2>/dev/null || true
rmdir "$DOCS/design/strategic/history-analysis-and-priorities" 2>/dev/null || true
rmdir "$DOCS/design/strategic" 2>/dev/null || true
rmdir "$DOCS/design/architecture" 2>/dev/null || true
rmdir "$DOCS/design" 2>/dev/null || true
rmdir "$DOCS/session-reports/session history" 2>/dev/null || true
rmdir "$DOCS/session-reports" 2>/dev/null || true
rmdir "$DOCS/plans/csw" 2>/dev/null || true
rmdir "$DOCS/plans/gsl/business meta model" 2>/dev/null || true
rmdir "$DOCS/plans/gsl/knowledge-layer" 2>/dev/null || true
rmdir "$DOCS/plans/gsl" 2>/dev/null || true
rmdir "$DOCS/plans" 2>/dev/null || true
rmdir "$DOCS/guides" 2>/dev/null || true

echo "  Empty directories removed"

echo ""
echo "=== Step 4: Create README ==="

cat > "$DOCS/README.md" << 'EOF'
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
EOF

echo "  README.md created"

echo ""
echo "=== Verification ==="

ARCHIVE_COUNT=$(find "$ARCHIVE" -name "*.md" -type f | wc -l | tr -d ' ')
echo ""
echo "Archive contains: $ARCHIVE_COUNT .md files"
echo ""
echo "Live directories:"
ls -d "$DOCS/reference" 2>/dev/null && echo "  ✅ reference/ exists"
ls -d "$DOCS/generated" 2>/dev/null && echo "  ✅ generated/ exists"
echo ""
echo "Top-level documentation/:"
ls -1 "$DOCS"
echo ""

if [ "$ARCHIVE_COUNT" -ge 85 ]; then
  echo "✅ Archive looks correct ($ARCHIVE_COUNT files)."
  echo ""
  echo "Next steps:"
  echo "  git add documentation/"
  echo "  git commit -m 'refactor: move completed documentation to archive/, add README'"
else
  echo "⚠️  Expected ~88 files in archive, found $ARCHIVE_COUNT. Check manually."
fi
