---
name: migration-apply
description: Apply a numbered SQL migration via psql, verify it ran, run the relevant export regen, and record provenance in the session report. Reads the migration first; never applies blindly.
allowed-tools: Bash, Read
---

# Apply Database Migration

Applies a numbered migration file from `02 ONTARA/db/migrations/NNN_*.sql` to the local `ontara` PostgreSQL database. The migration is read first, presented for confirmation, applied via `psql -f`, verified, and any affected exporter regen is run.

## Usage

`/migration-apply <path-to-migration>`

Examples:
- `/migration-apply 02 ONTARA/db/migrations/041_add_strata_landing_status.sql`
- `/migration-apply db/migrations/042_work_item_acceptance.sql`

## Pre-flight

1. Verify Postgres is running:
   ```bash
   psql -d ontara -c "SELECT 1" 2>&1 | head -3
   ```
2. Confirm the migration file exists:
   ```bash
   ls -l "<migration-path>"
   ```
3. Verify the resolver is running (so post-migration regen will work):
   ```bash
   curl http://localhost:7300/healthz
   ```

## Steps

1. **Read the migration file in full.** Do not skim. Identify:
   - Tables created, dropped, or altered.
   - Columns added, removed, or renamed.
   - Indexes, constraints, triggers added or dropped.
   - Data migrations (UPDATE / INSERT / DELETE statements).
   - Whether the migration is reversible. Many are not — there is no down-migration convention in this repo.

2. **Confirm with Ella** before applying. Show:
   - The migration filename.
   - A brief summary of what it changes (3–5 bullet points).
   - Whether it is reversible.
   - Any tables or marker exporters that will need regen after.

3. **Apply the migration:**
   ```bash
   cd "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA"
   psql -d ontara -f "<migration-path>"
   ```
   `psql -f` runs in a single transaction by default in modern Postgres, so a failure mid-file rolls back. If the migration uses explicit `BEGIN/COMMIT`, that takes precedence.

4. **Verify the migration ran.** Depending on the migration:
   - **Schema change:** introspect the affected table(s):
     ```bash
     psql -d ontara -c "\d+ <table-name>"
     ```
   - **Data migration:** count or spot-check the affected rows:
     ```bash
     psql -d ontara -c "SELECT count(*) FROM <table>"
     psql -d ontara -c "SELECT * FROM <table> LIMIT 3"
     ```
   - **Index or constraint:** confirm via `\d+` (indexes appear in the bottom block) or `\dn+` for constraints.

5. **Run affected exporter regen** if the migration changed marker-bound table content. The regen replays the (possibly new) row shape into vault markdown:
   ```bash
   python3 -c "import sys; sys.path.insert(0, 'db'); from exports.<module> import regenerate_<topic>_section; regenerate_<topic>_section()"
   ```
   Skip this step if the migration only added schema and no rows yet exist with the new shape.

6. **Restart the resolver** if the migration added a new content type or changed a spec's expected schema — the resolver loads specs at import time:
   ```bash
   launchctl kickstart -k gui/501/dev.ontara.resolver
   sleep 2
   curl http://localhost:7300/healthz
   ```

7. **Record provenance.** In the session report, note:
   - Migration filename and number.
   - Brief summary of changes.
   - Verification queries run and their output.
   - Any exporters re-run.
   - Whether the resolver was restarted.

## Critical Rules

- **Read before applying.** A migration that drops a column is not reversible without backup. A migration that re-numbers rows or rewrites primary keys can break wikilinks or rendered markdown.
- **No interactive psql sessions for migrations.** Always `psql -f <file>`. Multi-statement files in interactive mode are subject to autocommit edge cases.
- **No direct ALTER on substrate tables** (`block`, `block_edge`, `document`, `document_block`, `revision`) without confirming with Ella — these tables carry reconciliation logic in the resolver and changes need coordinated code updates.
- **Migrations are committed to the vault repo** as part of the C6 close commit. Do not apply a migration without expecting to commit it.
- **Numbered migrations are append-only.** Once a migration is applied to Ella's local database, do not edit the file — write a new migration instead.

## On Failure

- **`psql -d ontara -f <file>` returns non-zero with a SQL error:** the transaction rolled back. Read the error verbatim. Common causes:
  - Column already exists (migration already partially applied).
  - Foreign key violation (rows reference a target that doesn't exist yet).
  - Type mismatch on a default value.
  - Constraint violation (existing rows don't satisfy the new constraint).
- **Migration applied but exporter regen fails:** the spec is out of date with the new schema. The resolver needs a restart and the spec may need updating in code (a Code task).
- **Migration applied, resolver fails to start:** check the resolver logs. Most likely a spec validation at import time. The migration may need a follow-up to backfill required columns before the spec accepts it.
- **Partially applied migration:** if `psql -f` failed mid-file but some statements committed (e.g. the migration didn't wrap in `BEGIN`), recovery requires writing a hand-crafted patch. Stop and ask Ella.

## Notes

- Migration files live at `02 ONTARA/db/migrations/NNN_<description>.sql` in the vault.
- The schema reference at `02 ONTARA/db/schema/` is a flattened view; it is regenerated separately and lags migrations.
- The Postgres MCP (in Claude Desktop sessions) is read-only for routine work — migrations always go through `psql -f` for transactional integrity and error visibility.
- See vault `ontara-ref-guide-db-access.md` §9 for the migration discipline.
- See vault `ontara-ref-guide-using-claude-tools.md` §2.2 — migration authoring is a soft handoff trigger; this skill covers application, which is the after-authoring step.
