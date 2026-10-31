#!/usr/bin/env bash
# OP-134 spike: one line per load-test run of a configuration, from summary.json.
#   spike/bin/summarise.sh <configuration>
set -eu
cd "$(dirname "$0")/../.."
cfg="${1:?configuration}"
printf '| Run folder | orders x writers | readers | shapes | p50 | p95 | max | p95 1st/last 100 | throughput w/s | concurrency (sum lat / wall) | failures | correct |\n|---|---|---|---|---|---|---|---|---|---|---|---|\n'
for d in results/spike-op134/"$cfg"/loadtest/*/; do
  f="$d/summary.json"; [ -f "$f" ] || { echo "| \`$(basename "$d")\` | (no summary: run did not finish) |"; continue; }
  jq -r --arg run "$(basename "$d")" '
    "| `\($run)` | \(.config.orders) x \(.config.writers // 1) | \(.config.readers) | \(.config.shapes | sub("fixtures/shapes/";"")) | \(.writeLatencyMs.p50) | \(.writeLatencyMs.p95) | \(.writeLatencyMs.max) | \(.growthPer100Writes[0].latency.p95) / \(.growthPer100Writes[-1].latency.p95) | \(.throughputWritesPerSecond // "-") | \(.concurrency.sumOfWriteLatencyOverWallTime // "-") | \(.failures) | \((.correctnessByWriter // {w1: .correctness}) | to_entries | map("\(.value.ordersReady)/\(.value.orders)") | join(" ")) |"' "$f"
done
