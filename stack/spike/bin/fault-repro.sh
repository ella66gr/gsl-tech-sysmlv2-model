#!/usr/bin/env bash
# OP-134 spike follow-up (S519, Part B item 1): deterministic reproduction of
# the Fuseki write fault (S518 spike return §3.2).
#
#   JENA_VERSION=5.6.0|6.2.0 [FUSEKI_VALIDATION=whole|targeted] \
#     spike/bin/fault-repro.sh [--good N] [--bad K] [--label L]
#
# 1. Starts the Fuseki configuration on a FRESH store: FUSEKI_DATA points the
#    module at a new, empty TDB2 directory inside the volume
#    (/fuseki/databases/fault-<run>), so nothing is deleted and earlier data is
#    untouched. The bootstrap loads the knowledge graph and the stand-in shapes
#    into it, exactly as on any start.
# 2. Sends K known-bad writes (default 1; fixtures/writes/known-bad.ttl), then
#    N known-good writes (default 60; fixtures/writes/known-good.ttl), one at a
#    time through the gate (bin/write.sh), each with a fresh IRI. Records every
#    write's outcome: committed, rejected or fault, with the fault detail.
# 3. Counts the good records stored, then restarts the store container (its
#    in-memory node caches go) and reads every quad back through the Graph
#    Store Protocol (GET /cafe-runtime/data): a node-table defect that left
#    committed data unreadable shows here, after a restart, if not before.
# 4. Keeps the store's log (the module logs every fault's stack trace).
#
# Results: results/spike-op134/fuseki/fault/<run>/ (outcomes.csv, writes.jsonl,
# summary.json, store.log, readback-*.txt). Never restore or delete them.
# The stack is left up, on the fault run's data directory; spike.sh ... up
# without FUSEKI_DATA returns it to the default directory.
set -eu
cd "$(dirname "$0")/../.."          # stack/
GOOD=60; BAD=1; LABEL=repro
while [ $# -gt 0 ]; do
  case "$1" in
    --good) GOOD="$2"; shift 2 ;;
    --bad) BAD="$2"; shift 2 ;;
    --label) LABEL="$2"; shift 2 ;;
    *) echo "unknown option $1" >&2; exit 2 ;;
  esac
done
[ "$GOOD" -ge 50 ] || { echo "--good must be at least 50 (brief Part B item 1)" >&2; exit 2; }
export JENA_VERSION="${JENA_VERSION:-5.6.0}" FUSEKI_VALIDATION="${FUSEKI_VALIDATION:-whole}"
S=spike/bin/spike.sh
run="$(date -u +%Y%m%dT%H%M%SZ)-jena-$JENA_VERSION-$FUSEKI_VALIDATION-$LABEL"
out="results/spike-op134/fuseki/fault/$run"
mkdir -p "$out"
export FUSEKI_DATA="/fuseki/databases/fault-$run"
echo "[fault] run $run: Jena $JENA_VERSION, validation $FUSEKI_VALIDATION, fresh store at $FUSEKI_DATA, $BAD bad then $GOOD good"
since="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
"$S" fuseki up > "$out/up.log" 2>&1 || { cat "$out/up.log"; echo "[fault] up failed" >&2; exit 1; }
grep -E 'bootstrap|dataset=|UP in' "$out/up.log" | tail -4
status="$(curl -fsS http://127.0.0.1:7210/cafe-runtime/validated-update)"
echo "$status" > "$out/module-status.json"
echo "[fault] module: $status"
graph="urn:ontara:stack:graph:fault-$run"
echo "seq,kind,iri,outcome,http,exit,fault_detail,validation" > "$out/outcomes.csv"
: > "$out/writes.jsonl"
send() {   # kind seq file
  local kind="$1" seq="$2" file="$3" rid="fr$(printf '%03d' "$seq")-$(date -u +%H%M%S)"
  set +e; json="$(bin/write.sh "$file" --graph "$graph" --run "$rid" 2>&1)"; rc=$?; set -e
  printf '%s\n' "$json" | jq -c --arg kind "$kind" --argjson seq "$seq" '. + {seq: $seq, kind: $kind}' >> "$out/writes.jsonl" 2>/dev/null \
    || printf '{"seq":%s,"kind":"%s","unparsed":%s}\n' "$seq" "$kind" "$(printf '%s' "$json" | jq -Rs .)" >> "$out/writes.jsonl"
  local outcome http detail validation iri
  outcome="$(printf '%s' "$json" | jq -r '.outcome // "unparsed"' 2>/dev/null || echo unparsed)"
  http="$(printf '%s' "$json" | jq -r '.http // ""' 2>/dev/null || true)"
  detail="$(printf '%s' "$json" | jq -r 'if .outcome == "fault" then .detail else "" end' 2>/dev/null | tr ',\n\r' '   ' | cut -c1-300 || true)"
  validation="$(printf '%s' "$json" | jq -r '.validation // ""' 2>/dev/null | tr ',' ';' || true)"
  if [ "$kind" = bad ]; then iri="urn:ontara:standin:cafe#bad-$rid"; else iri="urn:ontara:standin:cafe#good-$rid"; fi
  echo "$seq,$kind,$iri,$outcome,$http,$rc,$detail,$validation" >> "$out/outcomes.csv"
  printf '%s %3d %-9s %s\n' "$kind" "$seq" "$outcome" "$(printf '%s' "$detail" | cut -c1-90)"
}
seq=0
for _ in $(seq 1 "$BAD"); do seq=$((seq + 1)); send bad "$seq" fixtures/writes/known-bad.ttl; done
for _ in $(seq 1 "$GOOD"); do seq=$((seq + 1)); send good "$seq" fixtures/writes/known-good.ttl; done

q() { curl -sS -m 120 -X POST http://127.0.0.1:7210/cafe-runtime/query -H 'Accept: application/sparql-results+json' --data-urlencode "query=$1"; }
countq="SELECT (COUNT(DISTINCT ?s) AS ?n) WHERE { GRAPH <$graph> { ?s a <urn:ontara:standin:rec#PlatformRecord> . FILTER(STRSTARTS(STR(?s), \"urn:ontara:standin:cafe#good-\")) } }"
stored_before="$(q "$countq" | jq -r '.results.bindings[0].n.value' 2>/dev/null || echo error)"
# Read every quad back, before and after a store restart.
# The dump goes to a temporary file outside the results folder (it is
# knowledge-graph sized); its outcome is kept in readback-<label>.txt.
dump="$(mktemp -t ontara-fault-readback)"
readback() {  # label
  local code err
  code="$(curl -sS -m 300 -o "$dump" -w '%{http_code}' -H 'Accept: application/n-quads' http://127.0.0.1:7210/cafe-runtime/data 2>"$dump.err")" || code="curl-error"
  err="$(tr '\n,' '  ' < "$dump.err" | cut -c1-200)"
  local lines; lines="$(wc -l < "$dump" | tr -d ' ')"
  local goods; goods="$(grep -c "cafe#good-fr" "$dump" || true)"
  local tail; tail="$(tail -c 400 "$dump" | tr '\n' ' ')"
  printf 'http=%s quads=%s quads-naming-a-good-record=%s curl=%s\nlast bytes: %s\n' "$code" "$lines" "$goods" "$err" "$tail" > "$out/readback-$1.txt"
  : > "$dump"
  echo "http=$code quads=$lines good-record-quads=$goods"
}
rb_before="$(readback before-restart)"
"$S" fuseki compose logs --no-color --no-log-prefix --since "$since" store > "$out/store.log" 2>&1 || true
"$S" fuseki compose restart store > /dev/null 2>&1
for _ in $(seq 1 60); do curl -fsS -o /dev/null http://127.0.0.1:7210/cafe-runtime/validated-update 2>/dev/null && break; sleep 2; done
stored_after="$(q "$countq" | jq -r '.results.bindings[0].n.value' 2>/dev/null || echo error)"
rb_after="$(readback after-restart)"
"$S" fuseki compose logs --no-color --no-log-prefix --since "$since" store > "$out/store.log" 2>&1 || true

c() { awk -F, -v k="$1" -v o="$2" 'NR > 1 && $2 == k && $4 == o' "$out/outcomes.csv" | wc -l | tr -d ' '; }
jq -n --arg run "$run" --arg jena "$JENA_VERSION" --arg mode "$FUSEKI_VALIDATION" --arg data "$FUSEKI_DATA" --arg graph "$graph" \
  --argjson good "$GOOD" --argjson bad "$BAD" \
  --arg bc "$(c bad committed)" --arg br "$(c bad rejected)" --arg bf "$(c bad fault)" \
  --arg gc "$(c good committed)" --arg gr "$(c good rejected)" --arg gf "$(c good fault)" \
  --arg sb "$stored_before" --arg sa "$stored_after" --arg rbb "$rb_before" --arg rba "$rb_after" \
  --arg traces "$(grep -c 'FAULT (aborted)' "$out/store.log" || true)" \
  --arg first "$(awk -F, 'NR > 1 && $4 == "fault" { print $1; exit }' "$out/outcomes.csv")" \
  '{run: $run, kind: "development run (Mac)", jenaVersion: $jena, validation: $mode, freshStoreDirectory: $data, graph: $graph,
    sequence: "\($bad) known-bad write(s), then \($good) known-good writes, one at a time through the gate",
    bad: {sent: $bad, committed: ($bc|tonumber), rejected: ($br|tonumber), fault: ($bf|tonumber)},
    good: {sent: $good, committed: ($gc|tonumber), rejected: ($gr|tonumber), fault: ($gf|tonumber)},
    firstFaultSeq: (if $first == "" then null else ($first|tonumber) end),
    goodRecordsStored: {beforeRestart: $sb, afterRestart: $sa},
    fullReadBack: {beforeRestart: $rbb, afterRestart: $rba, note: "http status and quad count of GET /cafe-runtime/data (N-Quads); details in readback-*.txt"},
    faultStackTracesInStoreLog: ($traces|tonumber),
    expectedUnderASoundStore: "bad: all rejected; good: all committed; zero faults; every good record stored and readable after restart"}' > "$out/summary.json"
cat "$out/summary.json"
echo "[fault] results in $out/"
