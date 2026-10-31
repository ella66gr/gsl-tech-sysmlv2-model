#!/usr/bin/env bash
# Sends one write through the gate. Paths are relative to stack/.
#   bin/write.sh fixtures/writes/known-good.ttl
#   bin/write.sh fixtures/writes/known-bad.ttl
#   bin/write.sh <file.ttl> [--graph IRI] [--run ID] [--bulk] [--update <file.rq>]...
# Exit 0 committed, 1 SHACL rejection, 2 fault.
set -eu
cd "$(dirname "$0")/.."
exec docker compose exec -T gate node dist/cli/write.js "$@"
