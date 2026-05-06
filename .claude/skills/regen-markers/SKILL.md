---
name: regen-markers
description: Run one or all marker exporters from db/exports/ to regenerate marker-bound sections in vault markdown from PostgreSQL rows. Supports dry-run preview and live-write modes; verifies frontmatter session bump after live runs.
allowed-tools: Bash, Read
---

# Regenerate Marker Sections

Marker-bound sections in vault markdown are regenerated from `ontara` PostgreSQL rows by the exporter modules under `02 ONTARA/db/exports/`. Each exporter exposes:

- A `regenerate_<scope>(output=None, dry_run=False)` function returning `tuple[int, int]` (row count, character count).
- An aggregate `regenerate_<topic>_section()` that calls the family in order.

When the resolver writes a row through the spec-driven engine, the spec's `regenerate_hook` is called automatically and the host marker section is rewritten. This skill is for **manual regen** — useful after schema changes, content edits via direct SQL, or post-migration reconciliation.

## Usage

`/regen-markers <marker-id-or-aggregate>`

Examples:
- `/regen-markers strata-table` — regenerate the Stratified Architecture §3 marker only.
- `/regen-markers strata-section` — regenerate all six markers in the strata family across five host documents.
- `/regen-markers all` — regenerate every marker section the exporters know about.

## Pre-flight

1. Verify resolver is running (regen depends on `db.exports.common.current_session()` reading the session pointer):
   ```bash
   curl http://localhost:7300/healthz
   ```
2. Confirm the session pointer is current:
   ```bash
   cat "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/db/.ontara-session"
   ```
3. List available exporters:
   ```bash
   ls "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/db/exports/"
   ```

## Steps

1. **Identify the right exporter.** Marker IDs map to exporter functions:

   | Marker ID | Exporter function | Module |
   |---|---|---|
   | `strata-va-table` | `regenerate_va_strata` | `db/exports/strata.py` |
   | `strata-table` | `regenerate_arch_strata` | `db/exports/strata.py` |
   | `strata-bmm-table` | `regenerate_bmm_strata` | `db/exports/strata.py` |
   | `strata-v1-requirements` | `regenerate_v1_acceptance_strata` | `db/exports/strata.py` |
   | `landing-status-codes`, `strata-landing-summary` | `regenerate_landing_strata` | `db/exports/strata.py` |
   | `landing-status-codes-short` | `regenerate_landing_tenants_status_codes` | `db/exports/strata.py` |
   | `work-items-table` | `regenerate_work_items_section` | `db/exports/work_tracker.py` |
   | `dcr-rows-table` | `regenerate_dcr_section` | `db/exports/work_tracker.py` |
   | `ow-register-table` | `regenerate_ow_section` | `db/exports/work_tracker.py` |
   | `concepts-*` markers | `regenerate_concepts_section` | `db/exports/concepts.py` |
   | `eil-table` | `regenerate_eil_section` | `db/exports/eil.py` |
   | `risks-table` | `regenerate_risks_section` | `db/exports/risks.py` |

   If unsure, search for the marker ID:
   ```bash
   grep -rn "M_.* = " "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/db/exports/"
   ```

2. **Dry-run the exporter** to preview the output to stdout:
   ```bash
   cd "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA"
   python3 -c "import sys; sys.path.insert(0, 'db'); from exports.strata import regenerate_arch_strata; regenerate_arch_strata(dry_run=True)"
   ```
   Verify: the table renders correctly, columns align, expected row count.

3. **Show Ella the dry-run output** before live execution. Pause for review.

4. **Live run** the exporter:
   ```bash
   python3 -c "import sys; sys.path.insert(0, 'db'); from exports.strata import regenerate_arch_strata; regenerate_arch_strata()"
   ```
   The function:
   - Resolves the marker file via `find_section_marker_file(M_ID)`.
   - Calls `replace_marked_section(target, M_ID, table)` to rewrite the marker section.
   - Bumps the host file's frontmatter `session:` and `date:` via `bump_frontmatter()`.

5. **Verify the host file** was written correctly:
   ```bash
   # Spot-check the marker block
   grep -A 1 "<!-- ontara:begin <marker-id> -->" "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/01 Ontara START HERE/<host-file>.md"

   # Confirm frontmatter session bump
   head -10 "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/01 Ontara START HERE/<host-file>.md"
   ```

6. **Aggregate run** (multiple markers across multiple files):
   ```bash
   python3 -c "import sys; sys.path.insert(0, 'db'); from exports.strata import regenerate_strata_section; regenerate_strata_section()"
   ```
   This calls every exporter in the family. Each writes its own host file and bumps its own frontmatter.

## Critical Rules

- **Marker content is overwritten on regen** — never edit the section between `<!-- ontara:begin -->` and `<!-- ontara:end -->` markers by hand.
- **Frontmatter bump is automatic** when the exporter is called via the function (not when the table is rendered to stdout via `dry_run=True`). Live writes always bump.
- **Adjacent host documents** — when one row is written via the resolver but multiple host files surface the same data (e.g. the strata family), the regen hook calls all of them. A direct SQL write skips this; manual regen via this skill is the recovery path.
- **`output=`** parameter is reserved for special cases (e.g. test fixtures); leave it `None` for normal use so the exporter resolves the canonical host file.

## On Failure

- **`find_section_marker_file` returns None:** the marker ID is not present in any vault file. Either the host document hasn't been placed yet, or the marker pair is malformed (typo in `begin` or `end`).
- **`replace_marked_section` raises:** the marker pair is malformed. Open the host file and check the begin/end markers are present and correctly spelled.
- **Frontmatter bump silent failure:** check the host file's frontmatter is valid YAML. A missing `---` or invalid YAML key will silently break the bump.
- **Multiple host files for one marker:** the exporter resolves the first match. If a marker ID exists in two files unintentionally, the second is stale. Audit with:
  ```bash
  grep -rn "<!-- ontara:begin <marker-id> -->" "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/"
  ```

## Notes

- Marker-bound writes via the resolver admin UI or `/api/{ct}` endpoints automatically trigger regen. This skill is for manual regen only.
- See `db/exports/common.py` for the shared rendering helpers.
- See vault `ontara-ref-guide-using-claude-tools.md` §2.2 — bulk marker work is a soft handoff trigger.
