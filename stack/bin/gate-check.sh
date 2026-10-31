#!/usr/bin/env bash
# Checks the gate's write path against a stand-in store: a rejection the gate
# cannot read is rolled back and reported as a fault, and write() never
# rejects (S519). Needs the gate image (README step 4), not a running stack.
# Exit 0 = pass.
set -eu
cd "$(dirname "$0")/.."
exec docker compose run --rm --no-deps -T gate node dist/cli/gatecheck.js "$@"
