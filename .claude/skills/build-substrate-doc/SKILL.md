---
name: build-substrate-doc
description: Author a build_sNNN_*.py script to create a substrate-canonical vault document via the resolver. Validates PM schema, runs dry-run, executes against the resolver, writes vault output, verifies marker pass-through.
allowed-tools: Bash, Read, Write, Edit
---

# Build Substrate Document

Authors a one-off Python build script that creates a substrate-canonical vault document by:

1. Defining a `BLOCKS` list of ProseMirror-shaped blocks.
2. Validating PM schema (text-node shape, allowed mark types, no nested paragraphs).
3. Resetting any pre-existing document (NULL `current_revision_id` BEFORE deleting revisions — FK constraint on `document_current_revision_fk`).
4. Creating the document + root block via direct SQL.
5. POSTing mutations to `/v1/documents/{id}/mutations` (createBlock + insertChild ops).
6. Verifying via `target=return` render (0 warnings expected).
7. Placing via `target=vault` render. New scripts omit `path=` — the renderer walks the vault and matches `document.slug` against frontmatter `slug:` fields (W-148 / W-149 / S367). Renames in Obsidian require zero resolver-side action. Legacy scripts that pass `path=` continue to work (explicit path wins). The frontmatter must include `slug: <slug>` matching the database `document.slug`.

The build script lives in the vault at `02 ONTARA/db/scratch/build_sNNN_<work-item>.py`. It is a one-off authoring script — kept for provenance, not run again after placement.

## Usage

`/build-substrate-doc <slug>`

Example: `/build-substrate-doc ontara-ref-arch-stratified-architecture`

## Pre-flight

1. Verify resolver is running:
   ```bash
   curl http://localhost:7300/healthz
   # → {"status":"ok"}
   ```
2. Read the resolver token:
   ```bash
   cat "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/db/resolver/.ontara-token"
   ```
3. Confirm scratch directory exists:
   ```bash
   ls "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/db/scratch/"
   ```
4. Read the canonical reference build script for shape:
   ```
   /Users/ellagreen/Obsidian/GenderSense/02 ONTARA/db/scratch/build_s359_w139_stage2.py
   ```

## Steps

1. **Read the content brief.** The slug, title, frontmatter, block list, entity bindings, and any markers must be specified by Ella before authoring begins. If any of these are missing, ask before proceeding.

2. **Author the build script** at `02 ONTARA/db/scratch/build_sNNN_<work-item>.py`. Include:
   - Inline-content helpers: `t()`, `bold()`, `italic()`, `code()`, `wl()` (wikilink), `it_wl()` (italic wikilink).
   - Block builders: `H(level, text)`, `P(*runs, entity_type, entity_id)`, `PRINCIPLE(...)`, `TABLE(content)`, `TR(*cells)`, `TH(*runs)`, `TD(*runs)`.
   - PM-schema validator (text node has non-empty string `text`; marks in `{bold, italic, code, wikilink}`; no `paragraph` or `heading` nested inside another).
   - Frontmatter dict (abbreviation, date, session, status, tags, version).
   - Block list assembled in document order.
   - `reset_document()` that NULLs `current_revision_id` BEFORE deleting revisions.
   - `create_document()` (direct SQL: `INSERT INTO block` for root, `INSERT INTO document`, `INSERT INTO document_block`).
   - `assemble_ops()` (createBlock + insertChild pairs, contiguous ordinals).
   - `post_mutations()` (POST to `/v1/documents/{doc_id}/mutations` with `X-Ontara-Token`).
   - `render_return()` for verification.
   - Pre-flight assertions: block count, type distribution, binding count, allowed marks.
   - `--dry-run` flag that runs validation only.

3. **Dry-run the script** to validate shape without touching the database:
   ```bash
   cd "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/db/scratch"
   python3 build_sNNN_<work-item>.py --dry-run
   ```
   Expected output: PM-schema validator OK, marks pre-flight OK, block count OK, bindings OK.

4. **Live run** the script. Reset any pre-existing document, create the document fresh, post mutations, render via `target=return`:
   ```bash
   python3 build_sNNN_<work-item>.py
   ```
   Verify: HTTP 200, `acceptedOperations` count matches expected, render returns 0 warnings.

5. **Verify marker pass-through** if the document hosts marker pairs:
   - Check the rendered markdown contains the verbatim `<!-- ontara:begin {marker-id} -->` and `<!-- ontara:end {marker-id} -->`.
   - Check no HTML-comment escaping (`&lt;!--` should NOT appear).

6. **Show Ella the rendered markdown** before vault placement. Pause for review.

7. **Place via vault render.** New scripts omit `path=` — the renderer walks the vault and matches `document.slug` against frontmatter `slug:` fields (W-148 / W-149 / S367):
   ```bash
   TOKEN=$(cat "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/db/resolver/.ontara-token")
   curl -sS -X POST "http://localhost:7300/v1/documents/<slug>/render?target=vault" \
     -H "X-Ontara-Token: $TOKEN" | python3 -m json.tool
   ```
   Expected: `{"target": "vault", "path": "<absolute path>", "bytes": <n>, "warnings": []}`. If the response is HTTP 400 with "slug … does not resolve in the vault", the rendered file was deleted or its frontmatter `slug:` field was edited away. Renames in Obsidian require zero action — the next render finds the file by slug. Passing `path=<vault-relative-path>` still works and overrides the slug lookup.

8. **Record provenance** in the session report and the work tracker. Note the doc UUID, the revision UUID, byte count, marker pass-through status, any warnings.

## Critical Rules

- **`reset_document()` order:** NULL `current_revision_id` BEFORE deleting revisions. FK constraint on `document_current_revision_fk` will violate otherwise.
- **Adjacent same-mark inline runs** (e.g. two `code()` calls back-to-back) trigger a `<!--/-->` separator from the renderer (W-S346). Merge them into a single run with combined text.
- **Render `target='vault'`** resolves the output location either from the `path=` query param or by matching `document.slug` against frontmatter `slug:` fields in the vault (W-148 / W-149 / S367). Renames in Obsidian require zero resolver-side action. The legacy `_substrate-rendered/` staging directory is retired.
- **Allowed marks:** `bold`, `italic`, `code`, `wikilink`. No others.
- **PM-schema text-node rule:** every text node has a non-empty string `text`. Empty `text=""` poisons the Tiptap editor mount (OW-S342-1).
- **Build scripts are not run twice.** After placement, the script is provenance only. If a fix is needed, edit the substrate via the editor or a new patch script.

## On Failure

- **PM-schema validator fails:** the offending node path is in the error. Fix the block builder.
- **HTTP 400 on mutations:** read the error body. Common causes: invalid mark name, empty text, malformed entity binding (entity_type without entity_id or vice versa).
- **HTTP 409 on edge insert:** the edge already exists. The reset_document didn't clean fully; check the FK ordering.
- **FK violation on reset:** `current_revision_id` was not NULLed first. Reorder the SQL.
- **Render returns warnings:** read each warning and address before placement. Common: missing entity targets, broken transcludes, marker-block content collisions.

## Notes

- Build scripts live in the vault under `02 ONTARA/db/scratch/`, NOT in the SysML repo.
- Build scripts are committed to the vault repo for provenance.
- The resolver session pointer at `02 ONTARA/db/.ontara-session` is consumed by the regen pipeline for frontmatter session bumps; the build script does not write to it.
- See vault `ontara-ref-guide-using-claude-tools.md` for handoff triggers — substantial build script authoring is a §2.1 hard trigger for Code.
