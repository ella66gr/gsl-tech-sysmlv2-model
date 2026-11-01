#!/usr/bin/env bash
# README step 8. The abort-defect regression check (specification 2.5 item 11;
# ADR-014 §4.4 condition 3), ported at S521 from the OP-134 spike's
# spike/bin/fault-repro.sh. It runs the stack's own store image under the
# conditions that corrupted Jena 5.6.0 at S519 (apache/jena#3877):
#
#   1. a fresh store (a new TDB2 directory), loaded by the stack's own bootstrap;
#   2. stored history: --preload orders written through the load harness;
#   3. cold caches: the store restarted before the first write;
#   4. --bad known-bad write(s), then --good known-good writes (at least 50),
#      one at a time through the gate;
#   5. the good records counted and every quad read back, then a restart, and
#      the count and read-back again;
#   6. the offline node-table check (store stopped) and the Jena file-layer
#      check (BdfTruncateCheck).
#
# It PASSES only if every good write is stored and readable after the
# restart, with no fault; it exits 1 otherwise (2 if it could not run).
# Defaults are the S519 follow-up's parameters: whole-mode validation (which
# reads every node in the aborted write, the condition the defect needs),
# --preload 300, --cold, 1 bad, 60 good.
#
#   bin/regression-check.sh                       # the standing check
#   bin/regression-check.sh --mode targeted       # the runtime's own mode, as a second leg
#   bin/regression-check.sh --label X --good N --bad K --preload N
#   Positive control only (never the runtime): --image <store image> --expect-jena <version>
#
# It runs as its own Compose project (ontara-cafe-regression; regression/compose.yaml),
# with its own network and volume and no published ports, so the runtime
# stack's data is never touched, and it may run while the stack is up. Each
# run's TDB2 directory is kept in the volume ontara-cafe-regression_store-data
# (README section 6 says how to remove them). Needs the images from README step 3.
# Results: results/<set>/regression/<run>/ with summary.json.
set -eu
cd "$(dirname "$0")/.."
. bin/common.sh
MODE=whole; PRELOAD=300; GOOD=60; BAD=1; LABEL=standing; IMAGE=""; EXPECT_JENA=""
while [ $# -gt 0 ]; do
  case "$1" in
    --mode) MODE="$2"; shift 2 ;;
    --preload) PRELOAD="$2"; shift 2 ;;
    --good) GOOD="$2"; shift 2 ;;
    --bad) BAD="$2"; shift 2 ;;
    --label) LABEL="$2"; shift 2 ;;
    --image) IMAGE="$2"; shift 2 ;;
    --expect-jena) EXPECT_JENA="$2"; shift 2 ;;
    *) echo "unknown option $1" >&2; exit 2 ;;
  esac
done
case "$MODE" in whole|targeted) ;; *) echo "--mode must be whole or targeted" >&2; exit 2 ;; esac
[ "$GOOD" -ge 50 ] || { echo "--good must be at least 50 (specification 2.5 item 11)" >&2; exit 2; }
[ "$BAD" -ge 1 ] || { echo "--bad must be at least 1" >&2; exit 2; }
[ "$PRELOAD" -ge 1 ] || { echo "--preload must be at least 1: stored history is a condition of the check" >&2; exit 2; }

export COMPOSE_FILE="compose.yaml:regression/compose.yaml"
export COMPOSE_PROJECT_NAME="ontara-cafe-regression"
export REGRESSION_VALIDATION="$MODE"
export REGRESSION_STORE_IMAGE="${IMAGE:-ontara-cafe-stack/store:local}"
for img in "$REGRESSION_STORE_IMAGE" ontara-cafe-stack/gate:local; do
  docker image inspect "$img" >/dev/null 2>&1 || { echo "image $img not found: build the stack's images first (README step 3: docker compose build)" >&2; exit 2; }
done
if [ -n "$(docker compose ps -q 2>/dev/null)" ]; then echo "a regression check is already running (project $COMPOSE_PROJECT_NAME); wait for it, or 'COMPOSE_FILE=$COMPOSE_FILE COMPOSE_PROJECT_NAME=$COMPOSE_PROJECT_NAME docker compose down'" >&2; exit 2; fi
jena_label="$(docker image inspect "$REGRESSION_STORE_IMAGE" --format '{{index .Config.Labels "dev.ontara.jena-version"}}' 2>/dev/null || true)"
[ -n "$jena_label" ] && [ "$jena_label" != "<no value>" ] || jena_label="$(docker image inspect "$REGRESSION_STORE_IMAGE" --format '{{range .Config.Env}}{{println .}}{{end}}' | sed -n 's/^JENA_VERSION=//p')"
run="$(date -u +%Y%m%dT%H%M%SZ)-jena-${jena_label:-unknown}-$MODE-$LABEL"
rel="$RESULTS_SET/regression/$run"
out="results/$rel"
mkdir -p "$out"
export REGRESSION_FUSEKI_DATA="/fuseki/databases/run-$run"
u="$(id -u):$(id -g)"
G="urn:ontara:stack:graph:regression-$run"
image_id="$(docker image inspect "$REGRESSION_STORE_IMAGE" --format '{{.Id}}')"
kind="regression check"; [ -n "$IMAGE" ] && kind="POSITIVE CONTROL (not the stack's image): $IMAGE"
printf '{\n  "runId": "%s",\n  "kind": "%s",\n  "storeImage": "%s",\n  "storeImageId": "%s",\n  "imageJenaVersion": "%s",\n  "mode": "%s",\n  "preloadOrders": %s,\n  "coldCachesBeforeFirstWrite": true,\n  "bad": %s,\n  "good": %s,\n  "freshStoreDirectory": "%s",\n  "graph": "%s",\n  "host": "%s",\n  "startedUtc": "%s"\n}\n' \
  "$run" "$kind" "$REGRESSION_STORE_IMAGE" "$image_id" "${jena_label:-unknown}" "$MODE" "$PRELOAD" "$BAD" "$GOOD" "$REGRESSION_FUSEKI_DATA" "$G" "$(uname -sm)" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$out/params.json"
since="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "[regression] run $run: $kind; store image $REGRESSION_STORE_IMAGE (Jena ${jena_label:-?}), $MODE validation, fresh store at $REGRESSION_FUSEKI_DATA; preload $PRELOAD, cold, $BAD bad then $GOOD good"
gate() { docker compose exec -T --user "$u" gate node dist/cli/regression.js "$@" --out "$rel"; }
down() { docker compose down >/dev/null 2>&1 || true; }
trap down EXIT
fail_run() { echo "[regression] could not run: $1" >&2; docker compose logs --no-color --no-log-prefix store > "$out/store.log" 2>&1 || true; exit 2; }

docker compose up -d --wait store > "$out/up.log" 2>&1 || fail_run "store did not start (see $out/up.log)"
expect=(); [ -n "$EXPECT_JENA" ] && expect=(-e "EXPECTED_JENA_VERSION=$EXPECT_JENA")
docker compose run --rm --no-deps -T ${expect[@]+"${expect[@]}"} bootstrap > "$out/bootstrap.log" 2>&1 || { cat "$out/bootstrap.log"; fail_run "bootstrap failed (see $out/bootstrap.log)"; }
grep -E 'status /cafe-runtime|OK in' "$out/bootstrap.log" | tail -2
docker compose up -d --wait --no-deps gate >> "$out/up.log" 2>&1 || fail_run "gate did not start"
echo "[regression] preload: $PRELOAD orders through the load harness (no readers)"
docker compose exec -T --user "$u" gate node dist/cli/loadtest.js --orders "$PRELOAD" --readers none --out "$rel/preload" > "$out/preload.log" 2>&1 || { tail -5 "$out/preload.log"; fail_run "preload failed (see $out/preload.log)"; }
grep -E '^\[load\] (done|store)' "$out/preload.log"
echo "[regression] cold: restarting the store before the first write"
docker compose restart store > /dev/null 2>&1
gate wait --label before-writes
gate writes --graph "$G" --bad "$BAD" --good "$GOOD" --run "${run%%-*}" > "$out/writes.log" 2>&1 || true
awk '{print $1, $3}' "$out/writes.log" | sort | uniq -c
gate verify --graph "$G" --label before-restart
echo "[regression] restarting the store"
docker compose restart store > /dev/null 2>&1
gate wait --label after-restart
gate verify --graph "$G" --label after-restart
docker compose logs --no-color --no-log-prefix --since "$since" store > "$out/store.log" 2>&1 || true
echo "[regression] offline checks (store stopped)"
docker compose stop store > /dev/null 2>&1
docker compose run --rm --no-deps -T --entrypoint java store -cp '/opt/ontara-fuseki/*:/opt/ontara-fuseki/lib/*' dev.ontara.spike.NodeTableCheck "$REGRESSION_FUSEKI_DATA/cafe-runtime" > "$out/nodetable-check.txt" 2>&1 || true
docker compose run --rm --no-deps -T --entrypoint java store -cp '/opt/ontara-fuseki/*:/opt/ontara-fuseki/lib/*' dev.ontara.spike.BdfTruncateCheck > "$out/bdf-truncate-check.txt" 2>&1 || true
grep -E '^(Jena|PHYSICAL|LOGICAL|  zero run)' "$out/nodetable-check.txt" "$out/bdf-truncate-check.txt" | sed 's#^results/[^:]*/##' | head -20
set +e
gate summarise --good "$GOOD" --bad "$BAD"
rc=$?
set -e
echo "[regression] results in $out/ (summary.json)"
exit "$rc"
