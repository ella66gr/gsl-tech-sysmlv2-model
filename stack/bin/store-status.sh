#!/usr/bin/env bash
# Reads the store module's status from the store itself (GET
# /<dataset>/validated-update, for both datasets) and checks it: validating
# on, targeted mode, Jena 6.2.0, shapes loaded. Exit 0 = as required.
#   bin/store-status.sh          the full status as JSON, then STORE STATUS: OK
#   bin/store-status.sh --line   one line
set -eu
cd "$(dirname "$0")/.."
exec docker compose exec -T gate node dist/cli/status.js "$@"
