#!/usr/bin/env bash
# The whole-graph check, run by hand (S0.5 Pass B4; README section 4, "The
# whole-graph check"). One run against the running stack's runtime dataset,
# in the whole-graph-check service's container (the gate's if that service is
# not running): a whole-graph SHACL validation and the three placement
# queries, in one read transaction in the store, never on the write path. It
# writes a report (results/whole-graph-check/<time>-manual-<id>.json and
# latest.json) and appends its log line to results/whole-graph-check/whole-graph-check.log.
# No automatic action.
#
#   bin/whole-graph-check.sh            exit 0 clean, 1 findings, 2 could not run
#   bin/whole-graph-check.sh --latest   prints the newest report (any trigger) and its log line
set -eu
cd "$(dirname "$0")/.."
. bin/common.sh
if [ "${1:-}" = "--latest" ]; then
  f=results/whole-graph-check/latest.json
  [ -f "$f" ] || { echo "no report yet: $f" >&2; exit 2; }
  cat "$f"; tail -1 results/whole-graph-check/whole-graph-check.log; exit 0
fi
svc=whole-graph-check
docker compose ps --status running --services 2>/dev/null | grep -qx "$svc" || svc=gate
docker compose ps --status running --services 2>/dev/null | grep -qx "$svc" || { echo "the stack is not running (README step 4)" >&2; exit 2; }
exec docker compose exec -T --user "$(id -u):$(id -g)" "$svc" node dist/cli/wholegraph.js --once --trigger manual
