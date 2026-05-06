---
name: resolver-debug
description: Inspect resolver state — running process, healthz, recent logs, registered specs, and route inventory. Read-only diagnostic; does not modify the resolver or its data.
allowed-tools: Bash, Read
---

# Resolver Debug

Read-only diagnostic for the Ontara resolver service at `http://localhost:7300/`. Use when:

- A write to a marker-bound or substrate endpoint fails unexpectedly.
- An exporter regen complains the resolver is unreachable.
- A new spec was added and the route inventory needs verifying.
- After editing resolver code or specs, before running a live test.

This skill does NOT restart the resolver — that is a separate `launchctl kickstart` call, surfaced explicitly when a code change requires it.

## Usage

`/resolver-debug` (no arguments — runs the full diagnostic battery)

`/resolver-debug routes` (route inventory only)

`/resolver-debug specs` (spec registry only)

`/resolver-debug logs` (recent log lines only)

## Steps

### 1. Liveness

```bash
# Should return JSON: {"status":"ok"}
curl -sS http://localhost:7300/healthz

# HTML admin landing — confirms the FastAPI app is mounted
curl -sS -o /dev/null -w "%{http_code}\n" http://localhost:7300/
```

If `/healthz` does not respond, the resolver is not running. Restart with:

```bash
launchctl kickstart -k gui/501/dev.ontara.resolver
sleep 2
curl -sS http://localhost:7300/healthz
```

### 2. Process inspection

```bash
# Find the resolver process
launchctl list | grep dev.ontara.resolver
# → "PID  STATUS  dev.ontara.resolver"
# Status 0 = running. Non-zero = last exit code.

# Or via ps
ps aux | grep -E "uvicorn|fastapi|main.py" | grep -v grep
```

### 3. Recent logs

```bash
# Default log path (LaunchAgent stdout/stderr)
tail -50 /tmp/ontara-resolver.log

# Or system log if LaunchAgent uses StandardOutPath/StandardErrorPath there
cat ~/Library/Logs/dev.ontara.resolver.log 2>/dev/null | tail -50
```

If logs show repeated 5xx errors or import failures, the resolver started but is failing on requests — check the most recent code change.

### 4. Spec registry

The resolver registers content-type specs at import time. Each spec defines: table, columns, validation rules, marker IDs, regenerate hook.

```bash
# List spec modules
ls "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/db/resolver/specs/"

# Confirm a specific spec is loaded by hitting its admin route
curl -sS -o /dev/null -w "%{http_code}\n" http://localhost:7300/admin/work-items
# → 401 (auth required) means the route exists. 404 means the spec didn't register.
```

### 5. Route inventory

The resolver exposes:

- **Public read views:** `/concepts`, `/eil`, `/work`, `/ow`, `/dcr`, `/risks`, `/document/{slug}`, etc. — HTML; no auth.
- **JSON API (auth required):** `/api/{ct}` (GET list, POST create, GET detail by key, PATCH update, DELETE delete, POST action).
- **Admin UI (cookie auth):** `/admin/{ct}` (HTML form-based create/edit/delete).
- **Substrate write API (token auth):** `/v1/documents/{id_or_slug}/mutations`, `/v1/documents/{id_or_slug}/render`, `/v1/documents/{id_or_slug}/projection`, `/v1/documents/{id_or_slug}/compose`, `/v1/audit/bindings`, `/v1/registry/binding/validate`.
- **Health:** `/healthz` (JSON), `/health` (HTML admin landing).

To probe a specific route:

```bash
TOKEN=$(cat "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/db/resolver/.ontara-token")

# JSON API list (read)
curl -sS -H "X-Ontara-Token: $TOKEN" http://localhost:7300/api/work-items | python3 -m json.tool | head -20

# Substrate render (verification)
curl -sS -X POST -H "X-Ontara-Token: $TOKEN" \
  "http://localhost:7300/v1/documents/<slug>/render?target=return" | python3 -m json.tool
```

### 6. Database connection

The resolver connects to local PostgreSQL via the connection pool configured in `db/resolver/main.py`. If the resolver starts but every request returns 5xx with a `psycopg.OperationalError`, the database is the issue:

```bash
# Verify Postgres is running
psql -d ontara -c "SELECT 1" 2>&1 | head -5

# Verify resolver's expected database exists
psql -d ontara -c "\dt" | head -20
```

### 7. Spec-driven engine sanity

If a single content type is misbehaving (validation rejection, regen failure):

```bash
# Read the spec
cat "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/db/resolver/specs/<ct>_spec.py"

# Read the engine output for that content type
TOKEN=$(cat "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/db/resolver/.ontara-token")
curl -sS -H "X-Ontara-Token: $TOKEN" "http://localhost:7300/api/<ct>?limit=1" | python3 -m json.tool
```

## On Failure

- **`/healthz` 200 but admin returns 500:** spec registration failed at import. Check resolver logs for the import-time traceback.
- **`/healthz` 200 but `/api/work-items` returns 401:** auth token mismatch. Re-read the token file and try again.
- **`/healthz` 200, all routes 404:** the FastAPI app started but no routers registered. Check `db/resolver/main.py` for router includes.
- **`/healthz` no response, `launchctl list` shows status 0:** the launchd entry says running but the port isn't bound. Check `lsof -iTCP:7300 -sTCP:LISTEN` to confirm.
- **Substrate render returns warnings:** the document loaded but rendering had issues (broken bindings, missing transclude targets). Read each warning verbatim.

## Notes

- The resolver is read by other tools too — Claude Chat reaches it via shell MCP, the regen pipeline imports `db/exports/common.py:current_session()` which reads `db/.ontara-session`.
- After editing resolver code or specs, restart with `launchctl kickstart -k gui/501/dev.ontara.resolver` — code changes are not hot-reloaded.
- See vault `ontara-ref-guide-db-access.md` for the full reach catalogue.
- See vault `ontara-ref-guide-using-claude-tools.md` §2.1 — debugging that requires reading >2 source files is a hard handoff trigger; this skill is the in-Code execution surface for that.
