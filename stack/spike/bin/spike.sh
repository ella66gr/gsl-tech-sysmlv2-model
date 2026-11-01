#!/usr/bin/env bash
# OP-134 store spike: runs one configuration's stack and the S0.1 scripts
# against it, unchanged, through the gate's store interface.
#
#   spike/bin/spike.sh <configuration> <command> [args]
#
# configurations: graphdb (control), rdf4j, rdf4j-lmdb, fuseki, oxigraph
# fuseki variants (S519, OP-134 follow-up), from the environment:
#   JENA_VERSION=5.6.0|6.2.0      (default 5.6.0, the S518 build)
#   FUSEKI_VALIDATION=whole|targeted  (default whole, the S518 behaviour)
# Each Jena version is its own Compose project (and so its own volumes); 5.6.0
# keeps the S518 project name. With either variable set, results go under
# results/spike-op134/fuseki/s519/jena-<version>-<mode>/, so the S518 results
# stay as they were.
# commands:
#   up            build and start (refuses if another Ontara stack, or GraphDB Desktop, is up)
#   down          stop and remove containers, keep data volumes
#   down-v        stop and remove containers and data volumes
#   bootstrap-log the bootstrap's output
#   health        bin/health.sh, result also saved to results/spike-op134/<cfg>/health.json
#   capabilities  bin/capabilities.sh, results in results/spike-op134/<cfg>/
#   loadtest ...  bin/loadtest.sh ..., runs in results/spike-op134/<cfg>/loadtest/
#   write ...     bin/write.sh ...
#   compose ...   docker compose ... (with this configuration's files)
set -eu
cd "$(dirname "$0")/../.."          # stack/
cfg="${1:?configuration}"; shift
cmd="${1:?command}"; shift
[ -f "spike/$cfg/compose.yaml" ] || { echo "no such configuration: $cfg" >&2; exit 2; }
export COMPOSE_FILE="spike/common.yaml:spike/$cfg/compose.yaml"
export COMPOSE_PROJECT_NAME="ontara-spike-$cfg"
export CAP_OUT_DIR="spike-op134/$cfg"
if [ "$cfg" = fuseki ]; then
  s519=0; { [ -n "${JENA_VERSION:-}" ] || [ -n "${FUSEKI_VALIDATION:-}" ]; } && s519=1
  export JENA_VERSION="${JENA_VERSION:-5.6.0}" FUSEKI_VALIDATION="${FUSEKI_VALIDATION:-whole}"
  case "$JENA_VERSION" in 5.6.0) ;; *) export COMPOSE_PROJECT_NAME="ontara-spike-fuseki-jena${JENA_VERSION//./}" ;; esac
  [ "$s519" = 1 ] && export CAP_OUT_DIR="spike-op134/fuseki/s519/jena-$JENA_VERSION-$FUSEKI_VALIDATION"
fi
case "$cfg" in
  graphdb)    export STORE_KIND=graphdb  STORE_DESCRIPTION="GraphDB 11.3.1, ruleset empty" ;;
  rdf4j)      export STORE_KIND=rdf4j    STORE_DESCRIPTION="RDF4J Server 6.1.0, NativeStore + ShaclSail" ;;
  rdf4j-lmdb) export STORE_KIND=rdf4j    STORE_DESCRIPTION="RDF4J Server 6.1.0, LmdbStore + ShaclSail" ;;
  fuseki)     export STORE_KIND=fuseki   STORE_DESCRIPTION="Jena Fuseki $JENA_VERSION TDB2 + validated-update module ($FUSEKI_VALIDATION validation)" ;;
  oxigraph)   export STORE_KIND=oxigraph STORE_DESCRIPTION="Oxigraph 0.5.13, SHACL in the gate (shacl-engine 1.1.3)" ;;
esac
export STORE_SERVICE=store
export RESULTS_SUBDIR="${RESULTS_SUBDIR_OVERRIDE:-$CAP_OUT_DIR/loadtest}"
# The GraphDB licence path (README step 2) is needed to parse any file that names the secret.
if [ -f .env ]; then set -a; . ./.env; set +a; fi
: "${GRAPHDB_LICENSE_FILE:=/dev/null}"; export GRAPHDB_LICENSE_FILE

others() {
  docker ps --format '{{.Label "com.docker.compose.project"}}' | sort -u | grep -E '^ontara-' | grep -v -x "$COMPOSE_PROJECT_NAME" || true
}
case "$cmd" in
  up)
    o="$(others)"; if [ -n "$o" ]; then echo "REFUSED: another Ontara stack is up: $o. Take it down first (one stack at a time)." >&2; exit 3; fi
    if pgrep -f 'GraphDB Desktop|graphdb-desktop' >/dev/null 2>&1 || (exec 3<>/dev/tcp/127.0.0.1/7200) 2>/dev/null; then
      echo "REFUSED: GraphDB Desktop appears to be running (process or port 7200). Quit it first (stack README section 6)." >&2; exit 3
    fi
    t0=$(date +%s)
    docker compose up -d --build --wait
    docker compose logs --no-log-prefix bootstrap | grep -v ' kg <'
    echo "UP in $(( $(date +%s) - t0 )) s"
    ;;
  down)          docker compose down ;;
  down-v)        docker compose down -v ;;
  bootstrap-log) docker compose logs --no-log-prefix bootstrap ;;
  health)
    mkdir -p "results/$CAP_OUT_DIR"
    set +e; bin/health.sh --json "$@" > "results/$CAP_OUT_DIR/health.out"; rc=$?; set -e
    grep -E '^(PASS|FAIL|HEALTH)' "results/$CAP_OUT_DIR/health.out"
    sed -n '/^{/,/^}/p' "results/$CAP_OUT_DIR/health.out" > "results/$CAP_OUT_DIR/health.json"; rm -f "results/$CAP_OUT_DIR/health.out"
    exit $rc ;;
  capabilities)  bin/capabilities.sh "$@" ;;
  loadtest)      bin/loadtest.sh "$@" ;;
  write)         bin/write.sh "$@" ;;
  compose)       docker compose "$@" ;;
  *) echo "unknown command: $cmd" >&2; exit 2 ;;
esac
