#!/usr/bin/env bash
# Runs README steps 3 to 6 in order and reports the elapsed time (test path 1
# times the procedure). Steps 1-2 (clone, licence) are done by hand first.
set -eu
cd "$(dirname "$0")/.."
t0=$(date +%s)
stamp() { echo; echo "=== $1  (+$(( $(date +%s) - t0 )) s)"; }
stamp "step 3: prerequisites";        bin/check-prereqs.sh
stamp "step 4: build the gate image"; docker compose build
stamp "step 5: start the stack";      docker compose up -d --wait
docker compose logs bootstrap | sed -n '/read back/p;/OK in/p'
stamp "step 6: health check";         bin/health.sh
stamp "done"
echo "PROCEDURE ELAPSED: $(( $(date +%s) - t0 )) s"
