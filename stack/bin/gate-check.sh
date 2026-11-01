#!/usr/bin/env bash
# Checks the gate's write path against a stand-in store (S519; Fuseki adapter
# since S521): every failure becomes an outcome and write() never rejects; a
# rejection names its shape; the gate sends no rollback (the store aborts its
# own transaction); the X-Ontara-Validation header is recorded. Needs the gate
# image (README step 3), not a running stack. Exit 0 = pass.
set -eu
cd "$(dirname "$0")/.."
exec docker compose run --rm --no-deps -T gate node dist/cli/gatecheck.js "$@"
