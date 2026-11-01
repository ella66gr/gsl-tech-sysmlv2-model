#!/usr/bin/env bash
# README step 5. The S0.1 health check: one command, calling the gate's
# /health endpoint. Exit 0 = pass. Options:
#   --json     print the full result
#   --record   also write it to results/<set>/health/<UTC time>-health.json
set -eu
cd "$(dirname "$0")/.."
. bin/common.sh
args=()
for a in "$@"; do if [ "$a" = "--record" ]; then args+=(--record "$RESULTS_SET/health"); else args+=("$a"); fi; done
exec docker compose exec -T --user "$(id -u):$(id -g)" gate node dist/cli/health.js ${args[@]+"${args[@]}"}
