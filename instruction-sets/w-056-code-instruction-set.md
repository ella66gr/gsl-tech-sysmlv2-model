# Claude Code Instruction Set — W-056 Reference Document Discoverability

**Session origin:** S219 (15 April 2026)
**Work item:** W-056 — Reference document discoverability discipline (E035 Facet 1, refined under E037 TLA discipline)
**Authoritative scope document:** `w-056-candidate-list-revised.md` (S219 working artefact, agreed by Ella)
**Repo root:** `~/Developer/gsl-tech/gsl-sysml-model`
**Vault root:** `/Users/ellagreen/Obsidian/GenderSense`
**Vault scope:** `02 ONTARA/`

---

## Objective

Execute the W-056 discoverability rename pass:

1. Rename 2 vault files via Obsidian CLI (auto-updating wikilinks).
2. Add `version` and `abbreviation` YAML frontmatter fields to 28 reference documents.
3. Verify no broken wikilinks remain.
4. Commit the vault changes with a session-referencing message.

This instruction set is **vault-only**. No repo (`~/Developer/gsl-tech/gsl-sysml-model`) changes are made. Commit and push the vault repo at the end.

---

## Pre-flight checks

Run these checks before any modification. Halt and report if any fails.

1. **Obsidian CLI available.** Confirm `obsidian --version` returns a version string. If not, install per the Obsidian CLI command reference at `02 ONTARA/02 Ontara Development/Ontara Reference & Guides/ontara - reference/ontara-ref-obsidian-cli-command-reference.md`.
2. **Vault git status clean.** `cd /Users/ellagreen/Obsidian/GenderSense && git status --porcelain` should return empty. If not, halt — Ella has uncommitted work.
3. **Vault on the working branch.** `git rev-parse --abbrev-ref HEAD` — confirm the expected branch (likely `main`).
4. **All 28 target files exist.** Verify each path in the Step 2 table exists. Halt if any is missing.

---

## Step 1 — Rename two files via Obsidian CLI

Use `obsidian move` for each rename — this preserves wikilinks across the vault by auto-rewriting them.

### Rename 1: V&A Reference

```
Current:  02 ONTARA/01 —— START HERE ——/ontara-ref-vision-architecture.md
New:      02 ONTARA/01 —— START HERE ——/ontara-ref (v&a) vision-architecture.md
```

Command (adapt to actual `obsidian move` syntax — verify against the Obsidian CLI reference doc):

```bash
obsidian move \
  "02 ONTARA/01 —— START HERE ——/ontara-ref-vision-architecture.md" \
  "02 ONTARA/01 —— START HERE ——/ontara-ref (v&a) vision-architecture.md"
```

After the move, capture and report: number of wikilinks updated, list of files modified.

### Rename 2: Emergent Ideas Log (EIL)

```
Current:  02 ONTARA/01 —— START HERE ——/ontara-workflow-emergent-ideas-log.md
New:      02 ONTARA/01 —— START HERE ——/ontara-workflow (eil) emergent-ideas-log.md
```

Command:

```bash
obsidian move \
  "02 ONTARA/01 —— START HERE ——/ontara-workflow-emergent-ideas-log.md" \
  "02 ONTARA/01 —— START HERE ——/ontara-workflow (eil) emergent-ideas-log.md"
```

After the move, capture and report: number of wikilinks updated, list of files modified.

**Verification after Step 1:** Run `grep -r "ontara-ref-vision-architecture" "02 ONTARA/" 2>/dev/null` and `grep -r "ontara-workflow-emergent-ideas-log" "02 ONTARA/" 2>/dev/null`. **Expect zero results** (other than possibly archived superseded copies in `07 Ontara History & Archive/` which are intentionally preserved). Report any unexpected matches.

---

## Step 2 — Add YAML frontmatter fields to 28 files

For each file, **insert** `version` and `abbreviation` fields into the existing YAML frontmatter (between the existing `---` delimiters). Do **not** modify or remove any existing fields (`tags`, `date`, `status`, `session`, etc.). Place the new fields after `status:` and before `session:` if `session:` exists, otherwise at the end of the YAML block before the closing `---`.

**Field value rules:**

- `version:` — use the value from the table. `n/a` is a literal string (not omitted).
- `abbreviation:` — use the value from the table. All values are lowercase strings, unquoted unless they contain special characters; the `&` character in `v&a` is safe in YAML unquoted, but if the YAML linter complains, quote as `"v&a"`.

**Idempotency:** If a file already has either field, **update** the value rather than duplicating. If the existing value matches the table value, no action needed for that field.

### File table

Paths are relative to the vault root `/Users/ellagreen/Obsidian/GenderSense`.

| # | File path | `version` | `abbreviation` |
|---|---|---|---|
| 1 | `02 ONTARA/01 —— START HERE ——/ontara-non-technical-overview.md` | `n/a` | `overview` |
| 2 | `02 ONTARA/01 —— START HERE ——/ontara-ref-master-register.md` | `n/a` | `master register` |
| 3 | `02 ONTARA/01 —— START HERE ——/ontara-ref-modelling-paradigms.md` | *(see existing header — preserve current version label)* | `modelling paradigms` |
| 4 | `02 ONTARA/01 —— START HERE ——/ontara-ref-strategic-snapshot.md` | *(preserve)* | `snapshot` |
| 5 | `02 ONTARA/01 —— START HERE ——/ontara-ref (v&a) vision-architecture.md` *(post-Step 1)* | `v12` | `v&a` |
| 6 | `02 ONTARA/01 —— START HERE ——/ontara-ref-work-item-tracker.md` | `n/a` | `tracker` |
| 7 | `02 ONTARA/01 —— START HERE ——/ontara-workflow-close-only-2.3.md` | `n/a` | `close-only` |
| 8 | `02 ONTARA/01 —— START HERE ——/ontara-workflow (eil) emergent-ideas-log.md` *(post-Step 1)* | `n/a` | `eil` |
| 9 | `02 ONTARA/01 —— START HERE ——/ontara-workflow-guide.md` | `v2` | `workflow guide` |
| 10 | `02 ONTARA/01 —— START HERE ——/—— ARCHITECTURE INDEX ——.md` | `n/a` | `architecture index` |
| 11 | `02 ONTARA/02 Ontara Development/Ontara Reference & Guides/ontara - reference/ontara -- reference index --.md` | `n/a` | `reference index` |
| 12 | `02 ONTARA/02 Ontara Development/Ontara Reference & Guides/ontara - reference/ontara-ref-kerml-reserved-words.md` | `n/a` | `kerml reserved words` |
| 13 | `02 ONTARA/02 Ontara Development/Ontara Reference & Guides/ontara - reference/ontara-ref-obsidian-cli-command-reference.md` | `n/a` | `obsidian cli` |
| 14 | `02 ONTARA/02 Ontara Development/Ontara Reference & Guides/ontara - reference/ontara-ref-pattern-catalogue-cross-reference-convention.md` | `n/a` | `pattern catalogue cross-reference` |
| 15 | `02 ONTARA/02 Ontara Development/Ontara Reference & Guides/ontara - reference/ontara-ref-shell-commands.md` | *(preserve — existing v2)* | `shell commands` |
| 16 | `02 ONTARA/02 Ontara Development/Ontara Reference & Guides/ontara - reference/ontara-ref-spike-hookmark-convention.md` | `n/a` | `spike hookmark` |
| 17 | `02 ONTARA/02 Ontara Development/Ontara Reference & Guides/ontara - reference/ontara-ref-weighted-relationship-directionality-definition.md` | `n/a` | `wr directionality` |
| 18 | `02 ONTARA/02 Ontara Development/Ontara Reference & Guides/ontara - reference/ontara-ref-weighted-relationship-heuristics-and-config.md` | `n/a` | `wr heuristics` |
| 19 | `02 ONTARA/02 Ontara Development/Ontara Reference & Guides/ontara - reference/ontara-ref-wildcard-import-collision.md` | `n/a` | `wildcard import collision` |
| 20 | `02 ONTARA/02 Ontara Development/Ontara Reference & Guides/ontara - guides/ontara-guide-claude-tooling.md` | *(preserve)* | `claude tooling` |
| 21 | `02 ONTARA/02 Ontara Development/Ontara Reference & Guides/ontara - guides/ontara-guide-editing-package-hierarchy.md` | `n/a` | `package hierarchy` |
| 22 | `02 ONTARA/02 Ontara Development/Ontara Reference & Guides/ontara - guides/ontara-guide-git-quick-reference.md` | `n/a` | `git quick reference` |
| 23 | `02 ONTARA/02 Ontara Development/Ontara Reference & Guides/ontara - guides/ontara-guide-tree-command.md` | `n/a` | `tree command` |
| 24 | `02 ONTARA/04 Ontara Architecture/ontara-architecture-platform-principles.md` | `v5` | `architecture principles` |
| 25 | `02 ONTARA/04 Ontara Architecture/ontara-architecture (pms) platform-modelling-strategy.md` | `v5` | `pms` |
| 26 | `02 ONTARA/04 Ontara Architecture/ontara-architecture (sbmm) service-business-meta-modelling.md` | `v4` | `sbmm` |
| 27 | `02 ONTARA/04 Ontara Architecture/ontara-architecture-clarification-two-meta-models.md` | *(preserve)* | `two meta models` |
| 28 | `02 ONTARA/04 Ontara Architecture/ontara-architecture-decision-knowledge-evaluation.md` | *(preserve)* | `knowledge evaluation` |

**Implementation guidance.** A short Python script using `python-frontmatter` or a Bash script using `awk`/`sed` can do this idempotently. Recommended: Python for safety, since YAML insertion is parser-dependent. Pseudocode:

```python
import frontmatter

for path, version, abbreviation in TARGET_FILES:
    post = frontmatter.load(path)
    # Preserve existing version if file's value differs from "n/a" placeholder
    if version != "PRESERVE":
        post.metadata['version'] = version
    elif 'version' not in post.metadata:
        post.metadata['version'] = 'n/a'  # fallback for files marked PRESERVE but with no existing field
    post.metadata['abbreviation'] = abbreviation
    frontmatter.dump(post, path)
```

For the *(preserve)* entries: read the file's existing header for the version (e.g. workflow guide says "v2", PMS says "v5"). If absent, use `n/a` and report.

**Report after Step 2:** number of files modified, any files where the existing version differed from the table expectation, any YAML parse failures.

---

## Step 3 — Post-edit verification

1. **Wikilink integrity.** Run a vault-wide check that all wikilinks resolve. Suggested approach:

   ```bash
   # Find all wikilinks
   grep -rho '\[\[[^]|]*' "02 ONTARA/" | sort -u | sed 's/^\[\[//' > /tmp/all-wikilink-targets.txt
   # Find all .md filenames (without extension) and headings
   find "02 ONTARA/" -name "*.md" -exec basename {} .md \; | sort -u > /tmp/all-filenames.txt
   ```

   For each wikilink target that does not match a filename, verify it is a heading-link (contains `#`) or a known intentional pattern. Report any unresolved wikilinks.

2. **YAML validity.** Run a YAML parser over each of the 28 modified files. Report any that fail to parse.

3. **The two renamed files exist at their new paths and not at their old paths.**

---

## Step 4 — Git commit and push

If all verification passes:

```bash
cd /Users/ellagreen/Obsidian/GenderSense

git add -A

git commit -m "S219 W-056: reference document discoverability discipline

- Renamed 2 files with TLA in parentheses:
  - ontara-ref-vision-architecture.md → ontara-ref (v&a) vision-architecture.md
  - ontara-workflow-emergent-ideas-log.md → ontara-workflow (eil) emergent-ideas-log.md
- Added 'version' and 'abbreviation' YAML fields to 28 reference documents
- Wikilinks auto-updated by Obsidian CLI

W-056 (E035 Facet 1) executed under E037 TLA discipline.
See w-056-candidate-list-revised.md (S219 working artefact) for scope."

git push
```

**Do NOT use `--amend`** per OW-157 (commit-amend-after-push rewrites history).

---

## Failure handling

- **If Step 1 (rename) partially fails:** halt before Step 2. Report which rename succeeded and which did not. Wikilink integrity will be partially compromised; do not proceed to YAML edits until Ella decides whether to roll back or continue.
- **If Step 2 (YAML) partially fails:** continue with the files that succeed; report failures by filename. YAML failures are isolated per file — one failure does not block others.
- **If Step 3 (verification) reports unresolved wikilinks:** halt. Do not commit. Report the list of unresolved wikilinks for Ella to inspect.
- **If Step 4 (git) fails:** report the git error verbatim. Do not retry automatically.

---

## Out of scope (do not touch)

- The repo at `~/Developer/gsl-tech/gsl-sysml-model` — this is a vault-only operation.
- Any concept graph notes in `02 ONTARA/03 Ontara Concept Graph/` — concept graph is excluded from W-056 per the candidate list §6.
- Any discussion papers in `02 ONTARA/04 Ontara Architecture/` other than the two foundations papers (PMS, SBMM) and the two architecture-named files (#27, #28) listed in the table — discussion papers are content-named and out of scope.
- Any session reports or preparation notes in `02 ONTARA/02 Ontara Development/Ontara Session Reports & Preparation/` — these are historical records, not standing references.
- Any files in `02 ONTARA/07 Ontara History & Archive/` — superseded versions stay as they are.
- The TLA prose migrations (KG → DKG, BR → DBR, SR → DSR, BM → DBM, SM → DSM, OW → OWR) and the SBMM → PMM foundations paper reframe — these are separate work items (W-060 through W-066), not W-056.

---

## Reporting back to Ella

On completion, produce a brief summary including:
- Number of files renamed (target: 2)
- Number of files YAML-modified (target: 28)
- Approximate count of wikilinks auto-updated by Obsidian CLI during renames
- Any anomalies (preserved versions that were unexpectedly missing, files where YAML insertion required manual review, any wikilink resolution warnings)
- Git commit hash and push status

This summary belongs in the chat session that runs Code, not in the vault.
