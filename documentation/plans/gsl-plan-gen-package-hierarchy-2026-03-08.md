# Generated Package Hierarchy Pipeline — Plan

**Date:** 8 March 2026 (Session 7)
**Purpose:** Ensure the package hierarchy overview stays current, visible, and correct as the model evolves.

---

## 1. The Problem

The package hierarchy proposal was a hand-written document that drifted from the model. This will happen again unless the hierarchy is generated from the model rather than maintained separately. Additionally, a terminal tree is useful for verification but not ideal for architectural thinking — you want something visual that you can see at a glance and explore.

## 2. The Solution

A single Python script (`scripts/gen_package_hierarchy.py`) that reads all `.sysml` files and emits the package hierarchy in four formats, plus a diff mode for checking alignment with the proposal. No dependencies beyond Python standard library.

## 3. Output Formats

### Markdown tree (default)

```bash
python scripts/gen_package_hierarchy.py
```

Writes `documentation/gsl-generated-package-hierarchy.md`. A text tree with one-line descriptions from doc blocks and element counts in brackets. Good for terminal review and GitHub rendering.

### Mermaid mindmap

```bash
python scripts/gen_package_hierarchy.py --format=mermaid
```

Writes `documentation/gsl-generated-package-hierarchy.mermaid.md`. A Mermaid mindmap diagram in a markdown code fence. Renders visually in Obsidian, GitHub, and VS Code markdown preview. Best for quick visual overview within your existing tools.

### OPML outline

```bash
python scripts/gen_package_hierarchy.py --format=opml
```

Writes `documentation/gsl-generated-package-hierarchy.opml`. Opens in OmniOutliner, iThoughts, MindNode, or any OPML-capable tool on macOS. Best for structural thinking — expand/collapse, rearrange mentally, see the full architecture as an outline. Notes on each node include the doc block summary, element counts, and source file location.

To open: `open documentation/gsl-generated-package-hierarchy.opml`

### Markmap HTML mindmap

```bash
python scripts/gen_package_hierarchy.py --format=markmap
```

Writes `documentation/gsl-generated-package-hierarchy.html`. A self-contained HTML file that renders an interactive, zoomable, collapsible mindmap in any browser. Best for visual exploration — scroll to zoom, drag to pan, click nodes to collapse/expand. Requires internet connection on first load (pulls D3 and markmap from CDN).

To open: `open documentation/gsl-generated-package-hierarchy.html`

### All formats at once

```bash
python scripts/gen_package_hierarchy.py --format=all
```

Generates all four formats in one run.

## 4. Diff Mode

```bash
python scripts/gen_package_hierarchy.py --diff
```

Compares the model against the hand-written proposal and reports:

- Packages in the model but not in the proposal (with source file and line number)
- Packages in the proposal but not in the model (with suggested SysML code to add)

The suggested SysML is a skeleton — package declaration, import, and doc block placeholder — that you can paste into the appropriate `.sysml` file and flesh out in Syside.

## 5. Daily Workflow

### After any model change in Syside

1. Verify clean parse in Syside
2. Run: `python scripts/gen_package_hierarchy.py --format=all`
3. Glance at the terminal output for file paths
4. Open the markmap in browser or the OPML in your outliner for a visual check
5. Commit the model changes and regenerated files together

### Quick review

```bash
python scripts/gen_package_hierarchy.py --stdout  # terminal preview
python scripts/gen_package_hierarchy.py --diff     # check alignment
```

### Adding a new package

1. Decide where it goes (which parent package, which `.sysml` file)
2. Add the `package` declaration with `doc` block in Syside
3. Verify clean parse
4. Run `python scripts/gen_package_hierarchy.py --format=all`
5. Check the visual output — does it appear where expected?
6. Commit

## 6. Reverse Direction — Guided Editing

The `--diff` mode provides the reverse path. If the proposal contains packages that the model doesn't, the diff output gives you the exact SysML skeleton to add. The workflow:

1. Update the proposal with your intended structural change
2. Run `--diff` — it will show what's missing from the model
3. Copy the suggested SysML into the right file
4. Elaborate the doc block and add use case defs in Syside
5. Regenerate to confirm alignment

Over time, as the generated hierarchy replaces the proposal as the canonical document, you'll work model-first and the visual outputs are the review step.

## 7. File Locations

| Format | Path | Opens in |
|---|---|---|
| Markdown | `documentation/gsl-generated-package-hierarchy.md` | Any text editor, GitHub |
| Mermaid | `documentation/gsl-generated-package-hierarchy.mermaid.md` | Obsidian, VS Code, GitHub |
| OPML | `documentation/gsl-generated-package-hierarchy.opml` | OmniOutliner, iThoughts, MindNode |
| Markmap HTML | `documentation/gsl-generated-package-hierarchy.html` | Any browser |

## 8. Future Enhancements

- **Pre-commit hook** — auto-regenerate on commit so files are always current
- **Syside Automator mode** (`--mode=syside`) — semantic model access for accurate element counting and relationship traversal
- **Traceability overlay** — show satisfy/verify relationships in the mindmap
- **Clickable source links** — markmap nodes link to the `.sysml` file and line

## 9. No Dependencies

Pure Python standard library. Works on any Python 3.7+. macOS ships with this.

---

*Plan written 8 March 2026 (Session 7), updated with multi-format support.*
