#!/usr/bin/env bash
# OP-134 spike follow-up (S519, Part C): offline TDB2 integrity check
# (dev.ontara.spike.NodeTableCheck, compiled into the module jar) of one Fuseki database directory.
# Stops the store (TDB2 allows one JVM per directory), runs the check in the
# store image against the same volume, then starts the store again. Read-only:
# it opens the database in a READ transaction and reads the files.
#
#   JENA_VERSION=5.6.0|6.2.0 spike/bin/fault-check.sh <data dir in the volume> <output file>
#   e.g. spike/bin/fault-check.sh /fuseki/databases/cafe-runtime results/.../nodetable-check.txt
set -eu
cd "$(dirname "$0")/../.."          # stack/
dir="${1:?database directory inside the store volume}"; outfile="${2:?output file}"
export JENA_VERSION="${JENA_VERSION:-5.6.0}"
S=spike/bin/spike.sh
"$S" fuseki compose stop store > /dev/null 2>&1
set +e
"$S" fuseki compose run --rm --no-deps -T --entrypoint java store \
  -cp '/opt/ontara-fuseki/*:/opt/ontara-fuseki/lib/*' dev.ontara.spike.NodeTableCheck "$dir" 2>&1 | grep -v -E '^ Container .* (Creating|Created)$' > "$outfile"
rc=${PIPESTATUS[0]}
set -e
"$S" fuseki compose start store > /dev/null 2>&1
for _ in $(seq 1 60); do curl -fsS -o /dev/null http://127.0.0.1:7210/cafe-runtime/validated-update 2>/dev/null && break; sleep 2; done
grep -E '^(Jena|PHYSICAL|LOGICAL|  zero run)' "$outfile" | head -30
exit $rc
