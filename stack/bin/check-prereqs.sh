#!/usr/bin/env bash
# README step 2. Checks the procedure's declared prerequisites and fails
# loudly if one is missing: Docker Engine (daemon reachable), the Compose
# plugin and git, and that the stack's ports are free. Nothing else is
# assumed present on the machine. No licence is needed (since S521).
set -u
cd "$(dirname "$0")/.."
. bin/common.sh
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

for p in "${STORE_PORT:-7210}" "${GATE_PORT:-7220}"; do
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
