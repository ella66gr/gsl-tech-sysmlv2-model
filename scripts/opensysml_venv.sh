#!/usr/bin/env bash
# The OpenSysML authoring venv (Plan B Stage 0, S0.5 Pass A5, Session 522).
#
#   scripts/opensysml_venv.sh ensure  <version> <venv> <python>
#   scripts/opensysml_venv.sh refresh <version> <venv> <python>
#
# Called by `make venv` / `make venv-refresh`; <version> is the Makefile's
# SYSML_VERSION, so there is no second version number to edit. The venv holds:
#
#   - the Python client `opensysml==<version>`, from the release wheel;
#   - the gRPC service `sysml-grpc` at the same release, as <venv>/bin/sysml-grpc.
#
# Both come from https://github.com/Open-MBEE/OpenSysML/releases/tag/v<version>
# and are checked against that release's SHA256SUMS.txt; the binary is also
# checked against the digest the installed client pins for its own release
# (opensysml/release-digests.json), which ties the binary to the client.
#
# `ensure` is cheap when the venv is current: it reads the stamp file
# <venv>/opensysml.stamp and runs `sysml-grpc -version`, and rebuilds only on
# a mismatch (a new SYSML_VERSION, another platform, a missing or wrong binary,
# a missing client, a broken interpreter). `refresh` always rebuilds.
#
# It deletes <venv> only when <venv> carries this script's ownership marker, so
# a venv made by hand at the same path is never removed: it stops instead.
#
# The venv is authoring-rig tooling for `make gen` and the OWL pipeline only.
# Nothing under stack/ uses it: the Cafe's runtime never depends on the rig.

set -euo pipefail

usage() { echo "usage: $0 ensure|refresh <version> <venv> <python>" >&2; exit 2; }
[ $# -eq 4 ] || usage
mode=$1 version=$2 venv=$3 base_python=$4
case "$mode" in ensure|refresh) ;; *) usage ;; esac

repo=Open-MBEE/OpenSysML
release_url="https://github.com/$repo/releases/download/v$version"
marker="$venv/.ontara-opensysml-venv"
stamp="$venv/opensysml.stamp"

fail() { echo "=== OPENSYSML VENV FAILED: $*" >&2; exit 1; }

case "$(uname -s)" in
	Darwin) goos=darwin ;;
	Linux) goos=linux ;;
	*) fail "unsupported OS $(uname -s)" ;;
esac
case "$(uname -m)" in
	arm64|aarch64) goarch=arm64 ;;
	x86_64|amd64) goarch=amd64 ;;
	*) fail "unsupported machine $(uname -m)" ;;
esac
asset="sysml-grpc-$goos-$goarch"
wheel="opensysml-$version-py3-none-any.whl"
want_stamp="opensysml $version; sysml-grpc v$version; $asset"

why=""
current() {
	[ -f "$marker" ] && [ -f "$stamp" ] || { why="no stamp"; return 1; }
	[ "$(cat "$stamp")" = "$want_stamp" ] || { why="stamp says: $(cat "$stamp")"; return 1; }
	[ -x "$venv/bin/python" ] && "$venv/bin/python" -c '' 2>/dev/null || { why="its python does not run"; return 1; }
	local found
	found="$("$venv/bin/sysml-grpc" -version 2>/dev/null | head -1)" || true
	[ "$found" = "sysml-grpc version v$version" ] || { why="its sysml-grpc reports '${found:-nothing}'"; return 1; }
	compgen -G "$venv/lib/python*/site-packages/opensysml-$version.dist-info" >/dev/null \
		|| { why="opensysml $version is not installed in it"; return 1; }
}

if [ "$mode" = ensure ] && current; then
	exit 0
fi

if [ -e "$venv" ] && [ ! -f "$marker" ]; then
	fail "$venv exists but was not made by this script (no $marker). Move it aside, then run make venv."
fi

if [ -e "$venv" ]; then
	echo "=== opensysml venv: rebuilding $venv (${why:-refresh asked for}; wanted: $want_stamp)"
	rm -rf "$venv"
else
	echo "=== opensysml venv: creating $venv ($want_stamp)"
fi

"$base_python" -c 'import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)' \
	|| fail "$base_python is older than Python 3.10, which opensysml needs"
"$base_python" -m venv "$venv"
touch "$marker"

dl="$venv/downloads"
mkdir -p "$dl"
for f in SHA256SUMS.txt "$wheel" "$asset"; do
	curl -fsSL --retry 3 --retry-delay 2 -o "$dl/$f" "$release_url/$f" \
		|| fail "could not download $release_url/$f"
done

sha() { shasum -a 256 "$1" | cut -d' ' -f1; }
listed() { awk -v n="$1" '$2 == n || $2 == "*"n { print $1 }' "$dl/SHA256SUMS.txt"; }
for f in "$wheel" "$asset"; do
	want="$(listed "$f")"
	[ -n "$want" ] || fail "$f is not listed in the v$version SHA256SUMS.txt"
	got="$(sha "$dl/$f")"
	[ "$got" = "$want" ] || fail "$f digest $got does not match SHA256SUMS.txt ($want)"
done

# The checked wheel first, by name so pip records no file URL; then its
# dependencies (grpcio, protobuf, sigstore) from PyPI, within its own bounds.
pip=("$venv/bin/python" -m pip install --disable-pip-version-check --quiet)
"${pip[@]}" --no-index --no-deps --find-links "$dl" "opensysml==$version" \
	|| fail "pip could not install $wheel"
"${pip[@]}" "opensysml==$version" || fail "pip could not install the dependencies of opensysml $version"

# The client pins the service digest for its own release; the binary must match it.
pinned="$("$venv/bin/python" -I -c '
import sys
from opensysml.binary import pinned_digest
print(pinned_digest(sys.argv[1], sys.argv[2], sys.argv[3]) or "")
' "v$version" "$asset" "$repo")"
[ -n "$pinned" ] || fail "opensysml $version pins no digest for $asset at v$version"
[ "$pinned" = "$(sha "$dl/$asset")" ] || fail "$asset does not match the digest opensysml $version pins ($pinned)"

install -m 0755 "$dl/$asset" "$venv/bin/sysml-grpc"
rm -rf "$dl"

found="$("$venv/bin/sysml-grpc" -version 2>&1 | head -1)"
[ "$found" = "sysml-grpc version v$version" ] || fail "sysml-grpc reports '$found', wanted v$version"
client="$("$venv/bin/python" -I -c 'import opensysml; print(opensysml.__version__)')"
[ "$client" = "$version" ] || fail "opensysml reports $client, wanted $version"

"$venv/bin/python" -m pip freeze --disable-pip-version-check >"$venv/pip-freeze.txt"
printf '%s\n' "$want_stamp" >"$stamp"
echo "=== opensysml venv ready: $want_stamp ($venv/pip-freeze.txt lists the packages)"
