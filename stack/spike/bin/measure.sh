#!/usr/bin/env bash
# OP-134 spike B3 items 4 and 5: the same load series on every configuration.
#   spike/bin/measure.sh <configuration>
# 1. stage0             500 orders, three paced readers (bin/loadtest.sh defaults)
# 2. growth3000-sparql  3,000 orders, paced readers, stand-in shapes (with the SPARQL constraint)
# 3. growth3000-core    3,000 orders, paced readers, core-only shapes (no SPARQL constraint)
# 4. writers1-cont      500 orders, one writer, continuous readers (the R7 baseline)
# 5. writers3-cont      500 orders per writer, three writers on their own graphs, continuous readers
# Each run clears its graphs first, so each starts from the knowledge graph alone.
set -u
cd "$(dirname "$0")/../.."
cfg="${1:?configuration}"
S=spike/bin/spike.sh
run() { echo; echo "=== $cfg $*  ($(date -u +%H:%M:%SZ))"; "$S" "$cfg" loadtest "$@" 2>&1 | grep -E '^\[load\] (run|done|results)|Error|error' ; }
run --label stage0
run --orders 3000 --label growth3000-sparql
run --orders 3000 --shapes core-only --label growth3000-core
run --readers continuous --label writers1-cont
run --writers 3 --readers continuous --label writers3-cont
echo; echo "=== $cfg series done ($(date -u +%H:%M:%SZ))"
