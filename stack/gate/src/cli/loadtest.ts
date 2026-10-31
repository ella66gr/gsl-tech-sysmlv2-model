// Load harness (S0.1, specification 2.5 item 8). Run by stack/bin/loadtest.sh.
//
// Writer: one, sequential. Each write is the 53-triple order
//   (fixtures/writes/order-53.ttl) plus the readiness rule and the labelling
//   step (fixtures/rules/) in the same transaction, POSTed to the gate's
//   /write endpoint over HTTP, with the stand-in shapes loaded.
// Readers: three, concurrent with the writer, querying GraphDB directly:
//   counter queue, kitchen-display (KDS) stream, operator board.
// Measures: per-write latency as the caller sees it (HTTP round trip to the
//   gate), plus the gate's own phase timings, and per-query reader latency.
//   Raw timings go to writes.csv and readers.csv; summary.json holds
//   p50/p95/max overall and per 100-write bucket (growth as records accumulate).
//
// Options:
//   --orders N            orders to write (default 500; the specification's minimum)
//   --readers paced|continuous|none
//                         paced (default): counter every 1 s, KDS every 0.5 s,
//                         board every 2 s. continuous: back-to-back, no pause.
//   --validation normal|bulk   (default normal)
//   --keep                do not clear the load-test graph first (accumulate)
//   --out <dir>           results subdirectory (bin/loadtest.sh sets this)
import * as fs from "node:fs";
import * as path from "node:path";
import * as os from "node:os";
import { GraphDB } from "../graphdb";
import { config, graphs, paths } from "../config";
import { orderWrite, runId } from "../fixtures";

const args = process.argv.slice(2);
const opt = (n: string, d: string) => { const i = args.indexOf(n); return i >= 0 ? args[i + 1] : d; };
const N = Number(opt("--orders", "500"));
const READERS = opt("--readers", "paced") as "paced" | "continuous" | "none";
const VALIDATION = opt("--validation", "normal") as "normal" | "bulk";
const KEEP = args.includes("--keep");
const OUT = path.join(paths.results, opt("--out", `loadtest/${new Date().toISOString().replace(/[:.]/g, "")}`));
const G = graphs.loadtest;
const db = new GraphDB();

const PFX = `PREFIX cafe: <urn:ontara:standin:cafe#> PREFIX rec: <urn:ontara:standin:rec#> `;

function pct(sorted: number[], p: number): number {
  // nearest-rank percentile
  if (!sorted.length) return NaN;
  const k = Math.max(1, Math.ceil((p / 100) * sorted.length));
  return sorted[k - 1];
}
const stats = (xs: number[]) => {
  const s = [...xs].sort((a, b) => a - b);
  const r = (x: number) => Math.round(x * 10) / 10;
  return { n: s.length, p50: r(pct(s, 50)), p95: r(pct(s, 95)), max: r(s[s.length - 1] ?? NaN), mean: r(s.reduce((a, b) => a + b, 0) / (s.length || 1)) };
};

interface ReaderDef { name: string; everyMs: number; query: () => string }
let kdsCursor = "1970-01-01T00:00:00Z";
const readers: ReaderDef[] = [
  {
    name: "counter-queue", everyMs: 1000,
    query: () => `${PFX} SELECT ?order ?placed ?status WHERE { GRAPH <${G}> { ?order a cafe:Order ; cafe:placedAt ?placed ; cafe:status ?status . } FILTER (?status != cafe:Collected) } ORDER BY ?placed LIMIT 20`,
  },
  {
    name: "kds-stream", everyMs: 500,
    query: () => `${PFX} SELECT ?order ?placed ?line ?item ?qty ?status WHERE { GRAPH <${G}> { ?order a cafe:Order ; cafe:placedAt ?placed ; cafe:hasLine ?line . ?line cafe:item ?item ; cafe:quantity ?qty ; cafe:status ?status . } FILTER (?placed > "${kdsCursor}"^^<http://www.w3.org/2001/XMLSchema#dateTime>) } ORDER BY ?placed`,
  },
  {
    name: "operator-board", everyMs: 2000,
    query: () => `${PFX} SELECT ?status (COUNT(DISTINCT ?order) AS ?orders) (SUM(?qty) AS ?items) (COUNT(DISTINCT ?r) AS ?records) WHERE { GRAPH <${G}> { ?order a cafe:Order ; cafe:status ?status ; cafe:hasLine ?l . ?l cafe:quantity ?qty . OPTIONAL { ?r rec:recordOf ?order ; rec:hasProvenanceMethod ?m } } } GROUP BY ?status`,
  },
];

async function main() {
  fs.mkdirSync(OUT, { recursive: true });
  const run = runId();
  console.log(`[load] run ${run}: ${N} orders, readers=${READERS}, validation=${VALIDATION}, graph <${G}>, out ${path.relative(paths.results, OUT)}`);

  if (!KEEP) {
    const r = await fetch(`${config.gateUrl}/write`, { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ updates: [`CLEAR SILENT GRAPH <${G}>`], label: "loadtest reset" }) });
    const j: any = await r.json();
    if (j.outcome !== "committed") throw new Error(`reset failed: ${JSON.stringify(j)}`);
  }
  const startSize = await db.size();
  const startGraph = await db.size(G);

  // Readers
  let stop = false;
  const readerRows: string[] = ["reader,started_utc,latency_ms,rows,ok,error"];
  const readerLat: Record<string, number[]> = {};
  const readerLoops = READERS === "none" ? [] : readers.map(async (rd) => {
    readerLat[rd.name] = [];
    while (!stop) {
      const t0 = performance.now(); const started = new Date().toISOString();
      let rows = 0, ok = true, err = "";
      try {
        const res = await db.select(rd.query(), 60_000);
        rows = res.length;
        if (rd.name === "kds-stream" && res.length) kdsCursor = res[res.length - 1].placed.value;
      } catch (e: any) { ok = false; err = String(e?.message ?? e).replace(/[\r\n,]/g, " ").slice(0, 200); }
      const ms = performance.now() - t0;
      readerLat[rd.name].push(ms);
      readerRows.push(`${rd.name},${started},${ms.toFixed(2)},${rows},${ok},${err}`);
      if (READERS === "paced") { const wait = rd.everyMs - ms; if (wait > 0) await new Promise((r) => setTimeout(r, wait)); }
    }
  });

  // Writer
  const writeRows: string[] = ["seq,order,started_utc,latency_ms,gate_total_ms,begin_ms,add_ms,updates_ms,commit_ms,rollback_ms,outcome,graph_triples_before"];
  const lat: number[] = [];
  const failures: any[] = [];
  let graphTriples = startGraph;
  const tRun = performance.now();
  for (let i = 1; i <= N; i++) {
    if (i === 1 || i % 50 === 0) graphTriples = await db.size(G); // outside the timed section
    const order = `urn:ontara:standin:cafe#order-${run}-${String(i).padStart(5, "0")}`;
    const body = JSON.stringify({ ...orderWrite(order, G), validation: VALIDATION, label: `load ${i}` });
    const started = new Date().toISOString();
    const t0 = performance.now();
    const r = await fetch(`${config.gateUrl}/write`, { method: "POST", headers: { "Content-Type": "application/json" }, body });
    const j: any = await r.json();
    const ms = performance.now() - t0;
    const t = j.timings ?? {};
    writeRows.push([i, order, started, ms.toFixed(2), (t.total ?? NaN).toFixed?.(2), (t.begin ?? 0).toFixed(2), (t.add ?? 0).toFixed(2), (t.updates ?? 0).toFixed(2), (t.commit ?? 0).toFixed(2), (t.rollback ?? 0).toFixed(2), j.outcome, graphTriples].join(","));
    if (j.outcome === "committed") lat.push(ms); else failures.push({ seq: i, outcome: j.outcome, detail: j });
    if (i % 100 === 0) console.log(`[load] ${i}/${N}  last=${ms.toFixed(0)} ms  p95 so far=${stats(lat).p95} ms`);
  }
  const elapsed = (performance.now() - tRun) / 1000;
  stop = true;
  await Promise.all(readerLoops);

  // Correctness spot-check: every order Ready and its derived record labelled.
  const check = await db.select(`${PFX} SELECT (COUNT(DISTINCT ?o) AS ?orders) (COUNT(DISTINCT ?ready) AS ?ready) (COUNT(DISTINCT ?lab) AS ?labelled) WHERE { GRAPH <${G}> { ?o a cafe:Order . OPTIONAL { ?o cafe:status cafe:Ready . BIND(?o AS ?ready) } OPTIONAL { ?rr rec:recordOf ?o ; rec:hasRealityMode ?m ; rec:hasProvenanceMethod ?pm . FILTER(STRENDS(STR(?rr), "/ready-record")) BIND(?rr AS ?lab) } } }`, 120_000);

  // Per-100 buckets (growth).
  const rows = writeRows.slice(1).map((l) => l.split(","));
  const buckets = [];
  for (let b = 0; b < N; b += 100) {
    const xs = rows.slice(b, b + 100).filter((x) => x[10] === "committed");
    buckets.push({ writes: `${b + 1}-${Math.min(b + 100, N)}`, graphTriplesAtStart: Number(rows[b]?.[11]), latency: stats(xs.map((x) => Number(x[3]))), commit: stats(xs.map((x) => Number(x[8]))) });
  }

  const summary = {
    kind: "development run (Mac runs do not count as the S0.1 pass figure; specification 2.5 item 8.4)",
    run, startedUtc: new Date(Date.now() - elapsed * 1000).toISOString(), elapsedSeconds: Math.round(elapsed * 10) / 10,
    config: { orders: N, readers: READERS, readerCadenceMs: READERS === "paced" ? Object.fromEntries(readers.map((r) => [r.name, r.everyMs])) : null, validation: VALIDATION, graph: G, repository: config.repository, rule: "fixtures/rules/order-readiness.rq + fixtures/rules/labelling.rq", write: "fixtures/writes/order-53.ttl", shapes: "fixtures/shapes/standin-shapes.ttl" },
    percentileMethod: "nearest rank, over committed writes; latency = HTTP round trip to the gate's /write as the caller sees it",
    writeLatencyMs: stats(lat),
    gatePhaseMs: { commit: stats(rows.map((x) => Number(x[8]))), updates: stats(rows.map((x) => Number(x[7]))), add: stats(rows.map((x) => Number(x[6]))), begin: stats(rows.map((x) => Number(x[5]))) },
    passThresholdMs: 500,
    p95WithinThreshold: stats(lat).p95 <= 500,
    failures: failures.length, failureSamples: failures.slice(0, 5),
    readers: Object.fromEntries(Object.entries(readerLat).map(([k, v]) => [k, stats(v)])),
    readerErrors: readerRows.filter((l) => l.split(",")[4] === "false").length,
    growthPer100Writes: buckets,
    repository: { explicitStatementsBefore: startSize, explicitStatementsAfter: await db.size(), loadtestGraphBefore: startGraph, loadtestGraphAfter: await db.size(G) },
    correctness: { orders: Number(check[0].orders.value), ordersReady: Number(check[0].ready.value), derivedRecordsLabelled: Number(check[0].labelled.value) },
    containerView: { cpus: os.cpus().length, cpuModel: os.cpus()[0]?.model, totalMemGiB: Math.round((os.totalmem() / 2 ** 30) * 100) / 100, note: "as seen inside the gate container (the Docker VM on a Mac); host figures are in machine.txt" },
  };
  fs.writeFileSync(path.join(OUT, "writes.csv"), writeRows.join("\n") + "\n");
  fs.writeFileSync(path.join(OUT, "readers.csv"), readerRows.join("\n") + "\n");
  fs.writeFileSync(path.join(OUT, "summary.json"), JSON.stringify(summary, null, 2) + "\n");
  console.log(`[load] done in ${summary.elapsedSeconds} s: write latency p50=${summary.writeLatencyMs.p50} p95=${summary.writeLatencyMs.p95} max=${summary.writeLatencyMs.max} ms; failures=${failures.length}; correctness=${JSON.stringify(summary.correctness)}`);
  console.log(`[load] results in results/${path.relative(paths.results, OUT)}/ (writes.csv, readers.csv, summary.json)`);
  if (failures.length) process.exitCode = 1;
}

main().catch((e) => { console.error(e); process.exit(2); });
