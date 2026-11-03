#!/usr/bin/env bash
# The scoping test suite (S0.5 Pass B2; ADR-014 §4.4 condition 1): automated
# tests of what the store module's targeted validation checks, the fallback to
# whole-graph validation, the shape forms S0.6 will use, the known blind spot,
# the named-graph scheme's refusals, and two store behaviours (where a
# default-graph write lands; whether the standard endpoints are closed to
# writes from outside the stack's network). The cases are in
# gate/src/cli/scoping.ts; README section 2, step 9, lists them by group.
#
#   bin/scoping-test.sh                (or `make stack-scoping-test` at the repository root)
#
# It runs as its own Compose project (ontara-cafe-scoping; scoping/compose.yaml):
# a fresh store of the stack's own image in targeted mode, loaded by the
# stack's own bootstrap, its data inside the container; a second store in
# whole mode; the stack's own gate. The runtime stack's data, network and
# ports are never touched, and it may run while the stack is up. Nothing is
# kept: the stores' data is inside their containers, and `down -v` at the end,
# on this project only (ontara-cafe-scoping), removes the containers, its
# network and the one empty volume Compose declares for it
# (ontara-cafe-scoping_temporal-postgres-data; no Temporal runs here). It
# never names the stack's own project. It needs the images from README step 3,
# built from this commit.
#
# The suite's store publishes its read-only listener on
# 127.0.0.1:${SCOPING_STORE_PORT:-7211}, so one leg can test the endpoints
# from a container that is not on the stack's network (Docker's
# host.docker.internal; on Linux, if that cannot reach a loopback port, the
# leg is repeated with host networking).
#
# Exit 0 when every case passed; 1 when any failed; 2 if it could not run.
# Results: results/<set>/scoping/<run>/ (cases.md, summary.json, the legs'
# JSON, the logs).
set -eu
cd "$(dirname "$0")/.."
. bin/common.sh
export COMPOSE_FILE="compose.yaml:scoping/compose.yaml"
export COMPOSE_PROJECT_NAME="ontara-cafe-scoping"
PORT="${SCOPING_STORE_PORT:-7211}"
export SCOPING_STORE_PORT="$PORT"
GATE_IMAGE=ontara-cafe-stack/gate:local
for img in ontara-cafe-stack/store:local "$GATE_IMAGE"; do
  docker image inspect "$img" >/dev/null 2>&1 || { echo "image $img not found: build the stack's images first (README step 3: docker compose build)" >&2; exit 2; }
done
docker run --rm --entrypoint test "$GATE_IMAGE" -f /app/dist/cli/scoping.js \
  || { echo "the gate image has no scoping suite (dist/cli/scoping.js): rebuild the images from this commit (README step 3: docker compose build)" >&2; exit 2; }
if [ -n "$(docker compose ps -q 2>/dev/null)" ]; then echo "a scoping run is already running (project $COMPOSE_PROJECT_NAME); wait for it, or 'COMPOSE_FILE=$COMPOSE_FILE COMPOSE_PROJECT_NAME=$COMPOSE_PROJECT_NAME docker compose down'" >&2; exit 2; fi
if (exec 3<>"/dev/tcp/127.0.0.1/$PORT") 2>/dev/null; then echo "port $PORT is in use on 127.0.0.1: set SCOPING_STORE_PORT to a free port" >&2; exit 2; fi

run="$(date -u +%Y%m%dT%H%M%SZ)-scoping"
rel="$RESULTS_SET/scoping/$run"
out="results/$rel"
mkdir -p "$out"
u="$(id -u):$(id -g)"
down() { docker compose down -v >/dev/null 2>&1 || true; }   # this project only: COMPOSE_PROJECT_NAME is ontara-cafe-scoping
trap down EXIT
fail_run() { echo "[scoping] could not run: $1" >&2; docker compose logs --no-color store store-whole > "$out/stores.log" 2>&1 || true; exit 2; }
t0=$(date +%s)

echo "[scoping] run $run: project $COMPOSE_PROJECT_NAME, fresh stores (targeted and whole), the stack's own bootstrap and gate"
docker compose up -d --wait store store-whole > "$out/up.log" 2>&1 || fail_run "the stores did not start (see $out/up.log)"
docker compose run --rm --no-deps -T --user "$u" -e "ONTARA_WHOLE_GRAPH_CHECK_DIR=$rel/whole-graph-check" bootstrap > "$out/bootstrap.log" 2>&1 || { tail -20 "$out/bootstrap.log"; fail_run "bootstrap failed (see $out/bootstrap.log)"; }
grep -E 'Reality Reference Branch|whole-graph-check\]|OK in' "$out/bootstrap.log" | sed 's/^/  /'
docker compose up -d --wait --no-deps gate >> "$out/up.log" 2>&1 || fail_run "the gate did not start"

echo "[scoping] groups 1 to 7, inside the suite's network"
set +e
docker compose exec -T --user "$u" gate node dist/cli/scoping.js --out "$rel" > "$out/inside.log" 2>&1
rc_in=$?
set -e
grep -E '^(PASS|FAIL) ' "$out/inside.log" | awk '{print $1}' | sort | uniq -c | sed 's/^/  inside: /'
[ "$rc_in" -eq 0 ] || echo "[scoping] the inside leg exited $rc_in (see $out/inside.log)"

echo "[scoping] group 7, outside the stack's network: the published port 127.0.0.1:$PORT"
set +e
docker run --rm --add-host host.docker.internal:host-gateway --user "$u" -v "$PWD/results:/stack/results" \
  "$GATE_IMAGE" node dist/cli/scoping.js --outside "http://host.docker.internal:$PORT" --out "$rel" > "$out/outside.log" 2>&1
rc_out=$?
if [ "$rc_out" -eq 3 ]; then
  echo "[scoping] host.docker.internal did not reach the published port; repeating with host networking"
  docker run --rm --network host --user "$u" -v "$PWD/results:/stack/results" \
    "$GATE_IMAGE" node dist/cli/scoping.js --outside "http://127.0.0.1:$PORT" --out "$rel" >> "$out/outside.log" 2>&1
  rc_out=$?
fi
set -e
grep -E '^(PASS|FAIL) ' "$out/outside.log" | awk '{print $1}' | sort | uniq -c | sed 's/^/  outside: /'

echo "[scoping] group 6: a runtime dataset with no Reality Reference Branch identifier is refused at start (the whole-mode store)"
docker compose exec -T store-whole rm -f /tmp/scoping-store-whole/cafe-runtime.rrb.json
since="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
docker compose restart store-whole >/dev/null 2>&1 || true
state=""
for i in $(seq 1 60); do
  state="$(docker compose ps -a --format '{{.State}}' store-whole 2>/dev/null || true)"
  [ "$state" = "exited" ] && break
  sleep 1
done
docker compose logs --no-color --no-log-prefix --since "$since" store-whole > "$out/startup-refusal.log" 2>&1 || true
refused=false
grep -q "REFUSING TO START" "$out/startup-refusal.log" && [ "$state" = "exited" ] && refused=true
line="$(grep -m1 'REFUSING TO START' "$out/startup-refusal.log" | cut -c1-200 | sed 's/"/\\"/g')"
printf '{\n  "cases": [ { "group": 6, "id": "6.12", "name": "A runtime dataset that exists with no Reality Reference Branch identifier (its rrb.json removed) is refused at start", "expected": "the store exits, logging REFUSING TO START", "observed": "container %s; %s", "pass": %s } ]\n}\n' \
  "${state:-unknown}" "${line:-no REFUSING TO START line}" "$refused" > "$out/startup-refusal.json"

docker compose logs --no-color store store-whole gate > "$out/stores.log" 2>&1 || true
set +e
docker compose exec -T --user "$u" gate node dist/cli/scoping.js --summarise "$rel"
rc=$?
set -e
echo "[scoping] elapsed $(( $(date +%s) - t0 )) s; results in $out/ (cases.md, summary.json)"
[ "$rc_in" -eq 2 ] && rc=1
exit "$rc"
