# Repository Consolidation Plan

**Date:** 6 March 2026
**Purpose:** Consolidate GenderSense development artefacts into a single monorepo

---

## Current state

```
~/Developer/gsl-tech/
├── coffeeshop-exercise/          # Phase 1-4 SysML learning (archivable)
├── coffeeshop-demonstrator/      # Four-phase demonstrator (active, moving in)
├── gsl-sysml-model/              # SysML model, docs, syntax ref (becomes the monorepo)
├── sysml-metadata-lib/           # Shared metadata defs (moving in)
├── gsl-newsletter-control-panel/ # GenderInfo profile editors (separate concern, stays)
├── pyproject.toml                # Skeleton Python project (ignorable)
├── src/, tests/, .venv/          # Skeleton Python project (ignorable)
└── PDF docs/                     # Reference documents
```

## Proposed consolidated structure

The repo is `gsl-sysml-model` → keep the name for now (GitHub remote is `ella66gr/gsl-tech-sysmlv2-model`), consider renaming to `gendersense` or `gsl-dev` later when runtime code arrives.

```
gsl-sysml-model/
├── model/                        # SysML v2 model files (unchanged)
│   ├── enterprise.sysml
│   ├── foundation.sysml
│   ├── gendersense.sysml
│   ├── knowledge.sysml
│   ├── operations.sysml
│   ├── platform.sysml
│   ├── service-delivery.sysml
│   └── syntax-tests/             # Syntax verification files (already here)
│
├── libraries/                    # Shared SysML libraries
│   └── temporal-metadata/        # ← from sysml-metadata-lib/temporal/
│       └── temporal-metadata.sysml
│
├── exercises/                    # Proof-of-concept implementations
│   └── coffeeshop-demonstrator/  # ← from coffeeshop-demonstrator/
│       ├── model/                #    SysML orchestration model
│       ├── generators/           #    Python generators
│       ├── generated/            #    Generated artefacts
│       ├── packages/             #    pnpm monorepo (shared, temporal, web)
│       ├── documentation/        #    Phase journals, specs, summaries
│       ├── package.json
│       ├── pnpm-workspace.yaml
│       └── ...
│
├── scripts/                      # Automation scripts (already here)
│   └── evaluate_automator.py
│
├── documentation/                # Project-level docs (already here)
│   ├── gsl-architecture-principles.md
│   ├── gsl-sysml-modelling-strategy.md
│   ├── gsl-coffeeshop-cdr-exercise-plan-2026-03-06.md
│   ├── gsl-hormone-initiation-modelling-plan-2026-03-06.md
│   ├── gsl-session-report-2026-03-06.md
│   ├── gsl-session-report-2026-03-06-s2.md
│   ├── gsl-sysml-v2-syntax-reference-v3.3-2026-03-06.md
│   └── ...
│
└── README.md
```

## What moves where

| Source | Destination | Action |
|---|---|---|
| `sysml-metadata-lib/temporal/` | `gsl-sysml-model/libraries/temporal-metadata/` | Move (then update imports in model files) |
| `coffeeshop-demonstrator/` (entire tree) | `gsl-sysml-model/exercises/coffeeshop-demonstrator/` | Move |
| `coffeeshop-exercise/` | Archive (rename to `coffeeshop-exercise-archive/` at gsl-tech level) | Rename in place |

## Import path changes required

The SysML files that import from `TemporalMetadata::*` resolve via workspace folder scanning. After moving the metadata lib, the `.sysml` file is at a different path but still within the same workspace. Syside resolves packages by name, not by file path, so **no import statement changes are needed** — as long as both `libraries/temporal-metadata/temporal-metadata.sysml` and the model files are in the same Syside workspace folder tree.

**Verify after move:** Open Syside, confirm `private import TemporalMetadata::*;` still resolves in `service-delivery.sysml`.

## What stays separate

| Repo | Reason |
|---|---|
| `gsl-newsletter-control-panel/` | Different concern (GenderInfo/profile editors), different tech stack, no model dependency |
| `PDF docs/` | Reference material, not version-controlled code |
| Root-level `pyproject.toml`, `src/`, `tests/`, `.venv/` | Skeleton; can be cleaned up later |

## Git considerations

The `coffeeshop-demonstrator` has its own git history. Two options:
1. **Simple copy:** Copy the files into the monorepo and commit. History lives in the original repo (which can be archived on GitHub).
2. **Subtree merge:** Use `git subtree add` to preserve history. More complex but history is accessible.

Recommendation: **Simple copy** for now. The demonstrator's history is preserved in its GitHub repo. The consolidation commit in `gsl-sysml-model` records the state at the point of integration. The original `coffeeshop-demonstrator` repo can be archived on GitHub with a README pointing to its new home.
