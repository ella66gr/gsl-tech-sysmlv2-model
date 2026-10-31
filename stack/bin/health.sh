#!/usr/bin/env bash
# README step 6. The S0.1 health check: one command, calling the gate's
# /health endpoint. Exit 0 = pass. Add --json for the full result.
set -eu
cd "$(dirname "$0")/.."
exec docker compose exec -T gate node dist/cli/health.js "$@"
