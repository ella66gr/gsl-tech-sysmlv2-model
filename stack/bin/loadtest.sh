#!/usr/bin/env bash
# README step 8. Load harness. Records the machine's processors and memory
# beside the raw timings. Options are passed through, e.g.
#   bin/loadtest.sh                       # 500 orders, paced readers
#   bin/loadtest.sh --orders 1000 --readers continuous --label stress
set -eu
cd "$(dirname "$0")/.."
label=dev
args=()
while [ $# -gt 0 ]; do
  if [ "$1" = "--label" ]; then label="$2"; shift 2; else args+=("$1"); shift; fi
done
# No hostname in the id: the repository is public.
id="$(date -u +%Y%m%dT%H%M%SZ)-$(uname -s | tr "[:upper:]" "[:lower:]")-$(uname -m)-$label"
# OP-134 spike: RESULTS_SUBDIR puts runs under results/spike-op134/<configuration>/loadtest.
sub="${RESULTS_SUBDIR:-loadtest}"
dir="results/$sub/$id"
mkdir -p "$dir"
{
  echo "run id:        $id"
  echo "recorded at:   $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "host:          $(uname -srm)"
  if [ "$(uname -s)" = "Darwin" ]; then
    echo "cpu:           $(sysctl -n machdep.cpu.brand_string)"
    echo "cores:         $(sysctl -n hw.ncpu) logical ($(sysctl -n hw.perflevel0.physicalcpu 2>/dev/null || echo ?) performance + $(sysctl -n hw.perflevel1.physicalcpu 2>/dev/null || echo ?) efficiency)"
    echo "memory:        $(( $(sysctl -n hw.memsize) / 1073741824 )) GiB"
    echo "os:            macOS $(sw_vers -productVersion)"
  else
    echo "cpu:           $(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2- | sed 's/^ //')"
    echo "cores:         $(nproc) logical"
    echo "memory:        $(awk '/MemTotal/ {printf "%.1f GiB", $2/1048576}' /proc/meminfo)"
    echo "os:            $( . /etc/os-release 2>/dev/null; echo "${PRETTY_NAME:-unknown}")"
    if command -v systemd-detect-virt >/dev/null 2>&1; then echo "virtualised:   $(systemd-detect-virt || true)"; fi
  fi
  echo "docker:        $(docker version --format '{{.Server.Version}} {{.Server.Os}}/{{.Server.Arch}}')"
  echo "docker VM/engine sees: $(docker info --format '{{.NCPU}} CPUs, {{.MemTotal}} bytes memory')"
  case "${STORE_KIND:-graphdb}" in
    graphdb)
      echo "graphdb heap:  $(docker compose exec -T "${STORE_SERVICE:-graphdb}" sh -c 'echo ${GDB_HEAP_SIZE:-default}')"
      echo "graphdb licence: Free (maxCpuCores=1), see bootstrap log" ;;
    *)
      echo "store:         ${STORE_KIND} (${STORE_DESCRIPTION:-see the spike compose file})" ;;
  esac
  echo "args:          ${args[*]:-(defaults)}"
} > "$dir/machine.txt"
cat "$dir/machine.txt"
docker compose exec -T --user "$(id -u):$(id -g)" gate node dist/cli/loadtest.js --out "$sub/$id" ${args[@]+"${args[@]}"}
