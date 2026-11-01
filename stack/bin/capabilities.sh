#!/usr/bin/env bash
# README step 6. SHACL capability checks, in both validation modes
# (specification 2.5 item 7), through the store interface:
#   1. targeted: against the running stack's store, in its capability scratch
#      dataset (the runtime dataset is not touched);
#   2. whole: against a second, short-lived container of the same store image
#      started with ONTARA_VALIDATION=whole, its data inside the container
#      (removed with it), on the stack's network, with no published port;
#   3. both written into one table.
# Results: results/<set>/capabilities/shacl-capabilities.md (both modes),
# shacl-capabilities-targeted.{json,md}, shacl-capabilities-whole.{json,md}.
# An unenforced component is a result, not a failure. The script fails on
# R4 (store-side inference), or if any write was not validated in the mode
# expected (a configuration fault).
set -eu
cd "$(dirname "$0")/.."
. bin/common.sh
out="$RESULTS_SET/capabilities"
mkdir -p "results/$out"
u="$(id -u):$(id -g)"
whole="${COMPOSE_PROJECT_NAME:-ontara-cafe-stack}-capabilities-whole"
echo "[cap] 1 of 3: targeted mode, the stack's store"
docker compose exec -T --user "$u" gate node dist/cli/capabilities.js --out "$out" --mode targeted
echo "[cap] 2 of 3: whole mode, a short-lived container of the same image ($whole)"
docker rm -f "$whole" >/dev/null 2>&1 || true
docker compose run -d --rm --no-deps --name "$whole" -e ONTARA_VALIDATION=whole -e FUSEKI_DATA=/tmp/capabilities-whole store >/dev/null
trap 'docker rm -f "$whole" >/dev/null 2>&1 || true' EXIT
rc=0
docker compose exec -T --user "$u" -e "STORE_URL=http://$whole:3030" gate sh -c \
  'for i in $(seq 1 90); do node -e "fetch(process.env.STORE_URL + \"/cafe-capability-scratch/validated-update\").then(r => process.exit(r.ok ? 0 : 1), () => process.exit(1))" && exit 0; sleep 1; done; echo "whole-mode store did not start" >&2; exit 1' || rc=$?
[ "$rc" -eq 0 ] && { docker compose exec -T --user "$u" -e "STORE_URL=http://$whole:3030" gate node dist/cli/capabilities.js --out "$out" --mode whole || rc=$?; }
docker logs "$whole" > "results/$out/whole-mode-store.log" 2>&1 || true
docker rm -f "$whole" >/dev/null 2>&1 || true
trap - EXIT
[ "$rc" -eq 0 ] || { echo "[cap] whole-mode pass failed (exit $rc); see results/$out/whole-mode-store.log" >&2; exit "$rc"; }
echo "[cap] 3 of 3: both modes in one table"
docker compose exec -T --user "$u" gate node dist/cli/capabilities.js --combine "$out"
