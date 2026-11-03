#!/usr/bin/env bash
# Sends one write through the gate. Paths are relative to stack/.
#   bin/write.sh fixtures/writes/known-good.ttl
#   bin/write.sh fixtures/writes/known-bad.ttl
#   bin/write.sh <file.ttl> [--run ID] [--update <file.rq>]... [--remove IRI]...
# No --graph (S0.5 Pass B3): the gate's Write Stamping Stage sets the graph, in
# the Reality Reference Branch. Prints the gate's reply, with the store's
# X-Ontara-Validation header as "validation". Exit 0 committed, 1 SHACL
# rejection or write-rule refusal, 2 fault.
set -eu
cd "$(dirname "$0")/.."
exec docker compose exec -T gate node dist/cli/write.js "$@"
