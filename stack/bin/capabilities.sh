#!/usr/bin/env bash
# README step 7. SHACL capability checks; results in stack/results/.
# OP-134 spike: STORE_KIND (graphdb, rdf4j, fuseki, oxigraph) picks how the
# declared-predicates list is read, and CAP_OUT_DIR the results subfolder.
# Both default to the S0.1 stack's behaviour.
set -eu
cd "$(dirname "$0")/.."
kind="${STORE_KIND:-graphdb}"
out="results/${CAP_OUT_DIR:-}"
mkdir -p "$out"
case "$kind" in
  graphdb)
    echo "[cap] getSupportedShaclPredicates() via the GraphDB image's own RDF4J jars"
    docker compose exec -T "${STORE_SERVICE:-graphdb}" java -cp '/opt/graphdb/dist/lib/*' /opt/stack-tools/SupportedShaclPredicates.java \
      > "$out/shacl-supported-predicates.json" ;;
  rdf4j)
    echo "[cap] getSupportedShaclPredicates() via the RDF4J Server's own jars"
    docker compose exec -T "${STORE_SERVICE:-rdf4j}" java -cp '/usr/local/tomcat/webapps/rdf4j-server/WEB-INF/lib/*' /opt/stack-tools/SupportedShaclPredicates.java \
      > "$out/shacl-supported-predicates.json" ;;
  *)
    echo "[cap] getSupportedShaclPredicates(): not applicable to $kind (an RDF4J ShaclSail call)"
    printf '{\n  "applicable": false,\n  "reason": "getSupportedShaclPredicates() is an RDF4J ShaclSail call; %s does not use ShaclSail"\n}\n' "$kind" \
      > "$out/shacl-supported-predicates.json" ;;
esac
echo "[cap] written $out/shacl-supported-predicates.json"
docker compose exec -T -e CAP_OUT_DIR="${CAP_OUT_DIR:-}" --user "$(id -u):$(id -g)" gate node dist/cli/capabilities.js
