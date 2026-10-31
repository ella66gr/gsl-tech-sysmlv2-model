#!/usr/bin/env bash
# README step 7. SHACL capability checks; results in stack/results/.
set -eu
cd "$(dirname "$0")/.."
echo "[cap] getSupportedShaclPredicates() via the GraphDB image's own RDF4J jars"
docker compose exec -T graphdb java -cp '/opt/graphdb/dist/lib/*' /opt/stack-tools/SupportedShaclPredicates.java \
  > results/shacl-supported-predicates.json
echo "[cap] written results/shacl-supported-predicates.json"
docker compose exec -T --user "$(id -u):$(id -g)" gate node dist/cli/capabilities.js
