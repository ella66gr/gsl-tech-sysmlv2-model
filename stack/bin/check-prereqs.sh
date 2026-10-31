#!/usr/bin/env bash
# README step 3. Checks the procedure's declared prerequisites and fails
# loudly if one is missing: Docker Engine (daemon reachable), the Compose
# plugin, git, and the GraphDB licence named in stack/.env. Nothing else is
# assumed present on the machine.
set -u
cd "$(dirname "$0")/.."
fail=0
say()  { printf '%-34s %s\n' "$1" "$2"; }
bad()  { say "$1" "MISSING/FAIL: $2"; fail=1; }

if command -v docker >/dev/null 2>&1; then
  if v=$(docker version --format '{{.Server.Version}} ({{.Server.Os}}/{{.Server.Arch}})' 2>/dev/null); then
    say "Docker Engine" "$v"
  else
    bad "Docker Engine" "docker CLI found but the daemon is not reachable (is it running? is this user in the docker group?)"
  fi
  if cv=$(docker compose version --short 2>/dev/null); then say "Docker Compose plugin" "$cv"; else bad "Docker Compose plugin" "'docker compose' not available"; fi
else
  bad "Docker Engine" "docker not on PATH"
fi
if command -v git >/dev/null 2>&1; then say "git" "$(git --version)"; else bad "git" "git not on PATH"; fi

if [ ! -f .env ]; then
  bad "stack/.env" "missing; do README step 2"
else
  # shellcheck disable=SC1091
  set -a; . ./.env; set +a
  if [ -z "${GRAPHDB_LICENSE_FILE:-}" ]; then bad "GRAPHDB_LICENSE_FILE" "not set in stack/.env"
  elif [ ! -r "$GRAPHDB_LICENSE_FILE" ]; then bad "GRAPHDB_LICENSE_FILE" "not readable: $GRAPHDB_LICENSE_FILE"
  else
    case "$(cd "$(dirname "$GRAPHDB_LICENSE_FILE")" && pwd -P)/" in
      "$(cd .. && pwd -P)/"*) bad "GRAPHDB_LICENSE_FILE" "is inside the repository; keep it outside: $GRAPHDB_LICENSE_FILE" ;;
      *) say "GraphDB licence" "readable, $(wc -c < "$GRAPHDB_LICENSE_FILE" | tr -d ' ') bytes, outside the repository" ;;
    esac
  fi
fi

for p in "${GRAPHDB_PORT:-7210}" "${GATE_PORT:-7220}"; do
  if (exec 3<>"/dev/tcp/127.0.0.1/$p") 2>/dev/null; then
    if docker compose ps --status running --format '{{.Service}}' 2>/dev/null | grep -q .; then
      say "port $p" "in use (this stack is already running)"
    else
      bad "port $p" "in use by something else on 127.0.0.1"
    fi
  else
    say "port $p" "free"
  fi
done

if [ "$fail" -ne 0 ]; then
  echo; echo "PREREQUISITES: FAIL. Fix the items above before continuing." >&2; exit 1
fi
echo; echo "PREREQUISITES: OK"
