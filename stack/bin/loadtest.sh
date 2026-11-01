#!/usr/bin/env bash
# README step 7. Load harness. Records the machine's processors and memory,
# and the store (product, Jena version, validation mode), beside the raw
# timings. Options are passed through, e.g.
#   bin/loadtest.sh                       # 500 orders, three paced readers
#   bin/loadtest.sh --orders 1000 --readers continuous --label stress
# Results: results/<set>/loadtest/<UTC time>-<os>-<arch>-<label>/.
set -eu
cd "$(dirname "$0")/.."
. bin/common.sh
label=dev
args=()
while [ $# -gt 0 ]; do
  if [ "$1" = "--label" ]; then label="$2"; shift 2; else args+=("$1"); shift; fi
done
# No hostname in the id: the repository is public.
id="$(date -u +%Y%m%dT%H%M%SZ)-$(uname -s | tr "[:upper:]" "[:lower:]")-$(uname -m)-$label"
sub="$RESULTS_SET/loadtest"
dir="results/$sub/$id"
mkdir -p "$dir"
{
  echo "run id:        $id"
  echo "recorded at:   $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "host:          $(uname -srm)"
  if [ "$(uname -s)" = "Darwin" ]; then
    echo "machine:       $(sysctl -n hw.model 2>/dev/null || echo ?)"
    echo "cpu:           $(sysctl -n machdep.cpu.brand_string)"
    echo "cores:         $(sysctl -n hw.ncpu) logical ($(sysctl -n hw.perflevel0.physicalcpu 2>/dev/null || echo ?) performance + $(sysctl -n hw.perflevel1.physicalcpu 2>/dev/null || echo ?) efficiency)"
    echo "memory:        $(( $(sysctl -n hw.memsize) / 1073741824 )) GiB"
    echo "os:            macOS $(sw_vers -productVersion)"
  else
    echo "machine:       $(cat /sys/devices/virtual/dmi/id/product_name 2>/dev/null || echo ?)"
    echo "cpu:           $(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2- | sed 's/^ //')"
    echo "cores:         $(nproc) logical"
    echo "memory:        $(awk '/MemTotal/ {printf "%.1f GiB", $2/1048576}' /proc/meminfo)"
    echo "os:            $( . /etc/os-release 2>/dev/null; echo "${PRETTY_NAME:-unknown}")"
    if command -v systemd-detect-virt >/dev/null 2>&1; then echo "virtualised:   $(systemd-detect-virt || true)"; fi
  fi
  echo "docker:        $(docker version --format '{{.Server.Version}} {{.Server.Os}}/{{.Server.Arch}}')"
  echo "docker VM/engine sees: $(docker info --format '{{.NCPU}} CPUs, {{.MemTotal}} bytes memory')"
  echo "store image:   $(docker inspect "$(docker compose ps -q store)" --format '{{.Config.Image}} {{.Image}}' 2>/dev/null || echo '(store not running)')"
  echo "store heap:    $(docker compose exec -T store sh -c 'echo $JAVA_OPTS')"
  echo "args:          ${args[*]:-(defaults)}"
} > "$dir/machine.txt"
cat "$dir/machine.txt"
docker compose exec -T --user "$(id -u):$(id -g)" gate node dist/cli/loadtest.js --out "$sub/$id" ${args[@]+"${args[@]}"}
