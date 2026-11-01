#!/usr/bin/env bash
# Runs README steps 2 to 5 in order and reports the elapsed time (test path 1
# times the procedure). Step 1 (clone) is done by hand first.
set -eu
cd "$(dirname "$0")/.."
. bin/common.sh
t0=$(date +%s)
stamp() { echo; echo "=== $1  (+$(( $(date +%s) - t0 )) s)"; }
stamp "step 2: prerequisites";              bin/check-prereqs.sh
stamp "step 3: build the store and gate images"; docker compose build
stamp "step 4: start the stack";            docker compose up -d --wait
docker compose logs --no-log-prefix bootstrap | grep -v ' kg <'
stamp "step 5: health check";               bin/health.sh --record
stamp "done"
echo "PROCEDURE ELAPSED: $(( $(date +%s) - t0 )) s"
