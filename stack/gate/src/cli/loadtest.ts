// Load harness (S0.1, specification 2.5 item 8). Run by stack/bin/loadtest.sh.
//
// Writer: one, sequential. Each write is the 54-triple order
//   (fixtures/writes/order-54.ttl; axis values in B8 form, S0.5 Pass B8) plus
//   the readiness rule and the labelling step (fixtures/rules/) in the same
//   transaction, POSTed to the gate's /write endpoint over HTTP, with the
//   runtime shapes loaded: the stand-in record shape, Cyril's two-sided core
//   readiness shapes (S521) and the Cafe's generated axis shapes (B8; the
//   bootstrap's RUNTIME_SHAPE_FILES), not the stand-in SPARQL constraint.
// Readers: three, concurrent with the writer, querying the store directly:
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
//   --keep                do not clear the load-test graph first (accumulate)
//   --out <dir>           results subdirectory (bin/loadtest.sh sets this)
//   --writers N           OP-134 spike (R7): N concurrent writers, each writing
//                         --orders orders into its own run-scoped graph (writer 1
//                         uses the load-test graph, so --writers 1 is the S0.1
//                         harness unchanged). Readers query writer 1's graph.
//   --shapes runtime|standin|core-only
//                         runtime (default, S521): what the bootstrap loads,
//                         the core-only stand-in file, Cyril's two-sided
//                         readiness shapes (fixtures/shapes/spike-two-sided-readiness.ttl)
//                         and the Cafe's generated axis shapes (S0.5 Pass B8).
//                         standin: the S0.1 stand-in shapes, with the SPARQL
//                         constraint (for comparison with pass 1 only).
//                         core-only: the record shape alone (diagnostic).
//                         Any other set is loaded for the run and the runtime
//                         shapes are restored after.
//
// The store is recorded with every run (specification 2.5 item 8.5): the
// module's status (product, Jena version, validation mode) goes into
// summary.json and machine.txt, and every write's X-Ontara-Validation header
// into writes.csv. A write validated in any mode but the expected one
// (targeted), or with no header, is a configuration fault: the summary says
// the run is not valid as a measure, and the harness exits 3.
//   --reject-every K      (S519, OP-134 follow-up Part B item 2) before every
//                         K-th order, the writer sends one known-bad write
//                         (fixtures/writes/known-bad.ttl, a fresh IRI each
//                         time) to its graph. Its outcome is recorded as its
//                         own writes.csv row (kind "bad"); a store that is
//                         sound rejects it and then commits the next order.
//                         Latency figures and growth buckets count orders only.
import * as fs from "node:fs";
import * as path from "node:path";
import * as os from "node:os";
import { runtimeStore } from "../gate";
import { readFixture, readStackFile, ORDER_FIXTURE } from "../fixtures";
import { config, graphs, paths, RUNTIME_SHAPE_FILES, validatedAs } from "../config";
import { orderWrite, runId } from "../fixtures";

const args = process.argv.slice(2);
const opt = (n: string, d: string) => { const i = args.indexOf(n); return i >= 0 ? args[i + 1] : d; };
const N = Number(opt("--orders", "500"));
const READERS = opt("--readers", "paced") as "paced" | "continuous" | "none";
const KEEP = args.includes("--keep");
const OUT = path.join(paths.results, opt("--out", `loadtest/${new Date().toISOString().replace(/[:.]/g, "")}`));
const G = graphs.loadtest;
const WRITERS = Number(opt("--writers", "1"));
const SHAPES = opt("--shapes", "runtime") as "runtime" | "standin" | "core-only";
if (!["runtime", "standin", "core-only"].includes(SHAPES)) throw new Error(`--shapes ${SHAPES}: runtime, standin or core-only`);
const SHAPE_FILES = SHAPES === "runtime" ? RUNTIME_SHAPE_FILES : SHAPES === "core-only" ? ["fixtures/shapes/standin-shapes-core-only.ttl"] : ["fixtures/shapes/standin-shapes.ttl"];
const SHAPES_FILE = SHAPE_FILES.join(" + ");
const shapesTurtle = (files = SHAPE_FILES) => files.map((f) => readStackFile(f)).join("\n");
const REJECT_EVERY = Number(opt("--reject-every", "0"));
const EXPECT_MODE = config.expectedValidationMode;
const writerGraph = (w: number) => (w === 1 ? G : `${G}-w${w}`);
const db = runtimeStore();

// Axis values are read through the generated predicates (S0.5 Pass B8).
const PFX = `PREFIX cafe: <urn:ontara:standin:cafe#> PREFIX rec: <urn:ontara:standin:rec#> PREFIX ontara-cafe: <https://ontara.dev/ontology/tenant/cafe/> `;

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
    query: () => `${PFX} SELECT ?order ?placed ?status WHERE { GRAPH <${G}> { ?order a ontara-cafe:Order ; cafe:placedAt ?placed ; ontara-cafe:orderLifecycle ?status . } FILTER (?status != ontara-cafe:OrderLifecycle-collected) } ORDER BY ?placed LIMIT 20`,
  },
  {
    name: "kds-stream", everyMs: 500,
    query: () => `${PFX} SELECT ?order ?placed ?line ?item ?qty ?status WHERE { GRAPH <${G}> { ?order a ontara-cafe:Order ; cafe:placedAt ?placed ; cafe:hasLine ?line . ?line cafe:menuItem ?item ; cafe:quantity ?qty ; ontara-cafe:orderLinePreparation ?status . } FILTER (?placed > "${kdsCursor}"^^<http://www.w3.org/2001/XMLSchema#dateTime>) } ORDER BY ?placed`,
  },
  {
    name: "operator-board", everyMs: 2000,
    query: () => `${PFX} SELECT ?status (COUNT(DISTINCT ?order) AS ?orders) (SUM(?qty) AS ?items) (COUNT(DISTINCT ?r) AS ?records) WHERE { GRAPH <${G}> { ?order a ontara-cafe:Order ; ontara-cafe:orderLifecycle ?status ; cafe:hasLine ?l . ?l cafe:quantity ?qty . OPTIONAL { ?r rec:recordOf ?order ; rec:hasProvenanceMethod ?m } } } GROUP BY ?status`,
  },
];

async function main() {
  fs.mkdirSync(OUT, { recursive: true });
  const run = runId();
  // The store, read from the module before the run (recorded with the run).
  const storeStatus = await db.status();
  const storeLine = `Apache Jena Fuseki ${storeStatus.fusekiVersion} (Jena ${storeStatus.jenaVersion}, image built for ${storeStatus.jenaBuildVersion}), ${storeStatus.module}, ${storeStatus.store}, validation mode ${storeStatus.validationMode}`;
  const machine = path.join(OUT, "machine.txt");
  fs.appendFileSync(machine, `store:         ${storeLine}\nstore status:  ${JSON.stringify(storeStatus)}\nexpected mode: ${EXPECT_MODE} (every write's X-Ontara-Validation header is checked)\nshapes:        ${SHAPES_FILE}\n`);
  console.log(`[load] run ${run}: ${N} orders x ${WRITERS} writer(s), readers=${READERS}, shapes=${SHAPES_FILE}, reject-every=${REJECT_EVERY || "off"}, store: ${storeLine}, graph <${G}>, out ${path.relative(paths.results, OUT)}`);

  if (!KEEP) {
    for (let w = 1; w <= WRITERS; w++) {
      const r = await fetch(`${config.gateUrl}/write`, { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ updates: [`CLEAR SILENT GRAPH <${writerGraph(w)}>`], label: "loadtest reset" }) });
      const j: any = await r.json();
      if (j.outcome !== "committed") throw new Error(`reset failed: ${JSON.stringify(j)}`);
    }
  }
  const shapesLoad = await db.replaceGraph(db.shapesGraph, shapesTurtle(), "text/turtle");
  if (!shapesLoad.ok) throw new Error(`loading ${SHAPES_FILE}: HTTP ${shapesLoad.status} ${shapesLoad.body}`);
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

  // Writers
  const writeRows: string[] = ["seq,writer,order,started_utc,ended_utc,latency_ms,gate_total_ms,begin_ms,add_ms,updates_ms,commit_ms,rollback_ms,outcome,graph_triples_before,kind,validation,fault_detail"];
  const bad = { sent: 0, rejected: 0, fault: 0, committed: 0, other: 0 };
  const badFaults: any[] = [];
  const csvSafe = (x: any) => String(x ?? "").replace(/[\r\n,]/g, " ").slice(0, 300);
  const lat: number[] = [];
  const latBy: Record<number, number[]> = {};
  const failures: any[] = [];
  const intervals: [number, number][] = [];
  const storeErrors: { at: string; error: string }[] = [];
  const tRun = performance.now();
  const writer = async (w: number) => {
    const g = writerGraph(w);
    latBy[w] = [];
    let graphTriples = w === 1 ? startGraph : 0;
    for (let i = 1; i <= N; i++) {
      if (REJECT_EVERY > 0 && i % REJECT_EVERY === 0) {
        const badIri = `urn:ontara:standin:cafe#bad-${run}-w${w}-${String(i).padStart(5, "0")}`;
        const badBody = JSON.stringify({ graph: g, turtle: readFixture("writes/known-bad.ttl").replace(/<urn:ontara:standin:cafe#bad-\{\{RUN\}\}>/g, `<${badIri}>`), label: `load w${w} bad before ${i}` });
        const bStarted = new Date().toISOString(); const b0 = performance.now();
        const br = await fetch(`${config.gateUrl}/write`, { method: "POST", headers: { "Content-Type": "application/json" }, body: badBody });
        const bj: any = await br.json(); const b1 = performance.now();
        bad.sent++; if (bj.outcome in bad) (bad as any)[bj.outcome]++; else bad.other++;
        if (bj.outcome !== "rejected") badFaults.push({ before: i, writer: w, outcome: bj.outcome, detail: bj.detail ?? bj });
        const bt = bj.timings ?? {};
        writeRows.push([i, w, badIri, bStarted, new Date().toISOString(), (b1 - b0).toFixed(2), (bt.total ?? NaN).toFixed?.(2), (bt.begin ?? 0).toFixed(2), (bt.add ?? 0).toFixed(2), (bt.updates ?? 0).toFixed(2), (bt.commit ?? 0).toFixed(2), (bt.rollback ?? 0).toFixed(2), bj.outcome, graphTriples, "bad", csvSafe(bj.validation), bj.outcome === "fault" ? csvSafe(bj.detail) : ""].join(","));
      }
      if (i === 1 || i % 50 === 0) graphTriples = await db.size(g).catch((e: any) => { storeErrors.push({ at: `w${w} write ${i} size`, error: String(e?.message ?? e).slice(0, 300) }); return -1; }); // outside the timed section
      const order = `urn:ontara:standin:cafe#order-${run}-w${w}-${String(i).padStart(5, "0")}`;
      const body = JSON.stringify({ ...orderWrite(order, g), label: `load w${w} ${i}` });
      const started = new Date().toISOString();
      const t0 = performance.now();
      const r = await fetch(`${config.gateUrl}/write`, { method: "POST", headers: { "Content-Type": "application/json" }, body });
      const j: any = await r.json();
      const t1 = performance.now();
      const ms = t1 - t0;
      intervals.push([t0, t1]);
      const t = j.timings ?? {};
      writeRows.push([i, w, order, started, new Date().toISOString(), ms.toFixed(2), (t.total ?? NaN).toFixed?.(2), (t.begin ?? 0).toFixed(2), (t.add ?? 0).toFixed(2), (t.updates ?? 0).toFixed(2), (t.commit ?? 0).toFixed(2), (t.rollback ?? 0).toFixed(2), j.outcome, graphTriples, "order", csvSafe(j.validation), j.outcome === "fault" ? csvSafe(j.detail) : ""].join(","));
      if (j.outcome === "committed") { lat.push(ms); latBy[w].push(ms); } else failures.push({ seq: i, writer: w, outcome: j.outcome, detail: j });
      if (i % 100 === 0) console.log(`[load] w${w} ${i}/${N}  last=${ms.toFixed(0)} ms  p95 so far=${stats(latBy[w]).p95} ms`);
    }
  };
  await Promise.all(Array.from({ length: WRITERS }, (_, k) => writer(k + 1)));
  const elapsed = (performance.now() - tRun) / 1000;
  stop = true;
  await Promise.all(readerLoops);

  // Correctness spot-check: every order ready (lifecycle OrderLifecycle-ready)
  // and its derived record labelled.
  // OP-134 spike: the S0.1 query bound ?ready and ?lab and then reused them as
  // aggregate aliases, which SPARQL 1.1 forbids (18.2.4.1). GraphDB and RDF4J
  // accept it; Jena rejects it. Aliases renamed; the counts are unchanged.
  const checkGraph = (g: string) => db.select(`${PFX} SELECT (COUNT(DISTINCT ?o) AS ?orders) (COUNT(DISTINCT ?readyOrder) AS ?ready) (COUNT(DISTINCT ?labRecord) AS ?labelled) WHERE { GRAPH <${g}> { ?o a ontara-cafe:Order . OPTIONAL { ?o ontara-cafe:orderLifecycle ontara-cafe:OrderLifecycle-ready . BIND(?o AS ?readyOrder) } OPTIONAL { ?rr rec:recordOf ?o ; rec:hasRealityMode ?m ; rec:hasProvenanceMethod ?pm . FILTER(STRENDS(STR(?rr), "/ready-record")) BIND(?rr AS ?labRecord) } } }`, 120_000);
  const failedCheck = (e: any, at: string) => { storeErrors.push({ at, error: String(e?.message ?? e).slice(0, 300) }); return [{ orders: { value: "-1" }, ready: { value: "-1" }, labelled: { value: "-1" } }]; };
  const check = await checkGraph(G).catch((e) => failedCheck(e, "correctness check"));
  const checkByWriter: any = {};
  for (let w = 1; w <= WRITERS; w++) { const c = (await checkGraph(writerGraph(w)).catch((e) => failedCheck(e, `correctness check w${w}`)))[0]; checkByWriter[`w${w}`] = { orders: Number(c.orders.value), ordersReady: Number(c.ready.value), derivedRecordsLabelled: Number(c.labelled.value) }; }
  // Restore the runtime shapes (the bootstrap's) if this run loaded others.
  if (SHAPES !== "runtime") await db.replaceGraph(db.shapesGraph, shapesTurtle(RUNTIME_SHAPE_FILES), "text/turtle");

  // Concurrency: did writes overlap in time? Sum of write latencies over the
  // wall time of the writing phase (1.0 = one at a time), and the share of the
  // writing phase during which two or more writes were in flight.
  const sumLat = intervals.reduce((a, [x, y]) => a + (y - x), 0);
  const ev = intervals.flatMap(([x, y]) => [[x, 1], [y, -1]] as [number, number][]).sort((a, b) => a[0] - b[0] || a[1] - b[1]);
  let inFlight = 0, last = ev[0]?.[0] ?? 0, overlapMs = 0, maxInFlight = 0;
  for (const [tm, d] of ev) { if (inFlight >= 2) overlapMs += tm - last; inFlight += d; maxInFlight = Math.max(maxInFlight, inFlight); last = tm; }

  // Per-100 buckets (growth).
  // Columns: 0 seq, 1 writer, 2 order, 3 started, 4 ended, 5 latency, 6 gate total, 7 begin, 8 add, 9 updates, 10 commit, 11 rollback, 12 outcome, 13 graph triples.
  // Growth buckets are writer 1's writes (the single-writer harness's rows).
  const allRows = writeRows.slice(1).map((l) => l.split(","));
  const rows = allRows.filter((x) => x[14] === "order");
  const rows1 = rows.filter((x) => x[1] === "1");
  const buckets = [];
  for (let b = 0; b < N; b += 100) {
    const xs = rows1.slice(b, b + 100).filter((x) => x[12] === "committed");
    buckets.push({ writes: `${b + 1}-${Math.min(b + 100, N)}`, graphTriplesAtStart: Number(rows1[b]?.[13]), latency: stats(xs.map((x) => Number(x[5]))), commit: stats(xs.map((x) => Number(x[10]))) });
  }

  // How each write was validated (column 15, the X-Ontara-Validation header).
  const modeOf = (h: string) => (h ? h.split(/[; ]/)[0] : "(no header)");
  const tally = (xs: string[][]) => xs.reduce((a: Record<string, number>, x) => { const k = modeOf(x[15]); a[k] = (a[k] ?? 0) + 1; return a; }, {});
  const badRows = allRows.filter((x) => x[14] === "bad");
  const notInMode = rows.filter((x) => !validatedAs(x[15], EXPECT_MODE));
  const badNotInMode = badRows.filter((x) => !validatedAs(x[15], EXPECT_MODE));
  const validationCheck = {
    expectedMode: EXPECT_MODE,
    orderWritesByMode: tally(rows), knownBadWritesByMode: REJECT_EVERY > 0 ? tally(badRows) : null,
    orderWritesNotInExpectedMode: notInMode.length, knownBadWritesNotInExpectedMode: badNotInMode.length,
    missingHeader: [...rows, ...badRows].filter((x) => !x[15]).length,
    samplesNotInExpectedMode: [...notInMode, ...badNotInMode].slice(0, 5).map((x) => ({ seq: Number(x[0]), kind: x[14], validation: x[15] || null })),
    note: "the per-run reset (CLEAR SILENT GRAPH, outside the timed writes) is validated whole by the module's fall-back rule and is not counted",
  };
  const configurationFault = validationCheck.orderWritesNotInExpectedMode + validationCheck.knownBadWritesNotInExpectedMode > 0;

  const summary = {
    kind: "development run (Mac runs do not count as the S0.1 pass figure; specification 2.5 item 8.4)",
    run, startedUtc: new Date(Date.now() - elapsed * 1000).toISOString(), elapsedSeconds: Math.round(elapsed * 10) / 10,
    store: { product: `Apache Jena Fuseki ${storeStatus.fusekiVersion}`, jenaVersion: storeStatus.jenaVersion, jenaBuildVersion: storeStatus.jenaBuildVersion, module: storeStatus.module, storage: storeStatus.store, validationMode: storeStatus.validationMode, engine: storeStatus.engine, statusReadBeforeRun: storeStatus },
    validation: validationCheck,
    validAsMeasure: !configurationFault,
    configurationFault: configurationFault ? `writes validated other than ${EXPECT_MODE}, or with no X-Ontara-Validation header: a configuration fault; the run is invalid as a measure (specification 2.8 item 9)` : null,
    config: { orders: N, rejectEvery: REJECT_EVERY || null, writers: WRITERS, writerGraphs: Array.from({ length: WRITERS }, (_, k) => writerGraph(k + 1)), store: db.kind, readers: READERS, readerCadenceMs: READERS === "paced" ? Object.fromEntries(readers.map((r) => [r.name, r.everyMs])) : null, graph: G, dataset: config.dataset, rule: "fixtures/rules/order-readiness.rq + fixtures/rules/labelling.rq", write: `fixtures/${ORDER_FIXTURE}`, shapes: SHAPES_FILE, shapesGraph: db.shapesGraph },
    percentileMethod: "nearest rank, over committed order writes; latency = HTTP round trip to the gate's /write as the caller sees it (writes.csv column latency_ms, rows with kind=order and outcome=committed)",
    writeLatencyMs: stats(lat),
    gatePhaseMs: { commit: stats(rows.map((x) => Number(x[10]))), updates: stats(rows.map((x) => Number(x[9]))), add: stats(rows.map((x) => Number(x[8]))), begin: stats(rows.map((x) => Number(x[7]))) },
    writeLatencyMsByWriter: Object.fromEntries(Object.entries(latBy).map(([k, v]) => [`w${k}`, stats(v)])),
    throughputWritesPerSecond: Math.round(((rows.length - failures.length) / elapsed) * 100) / 100,
    concurrency: { writers: WRITERS, sumOfWriteLatencyOverWallTime: Math.round((sumLat / (elapsed * 1000)) * 100) / 100, shareOfWritingTimeWithTwoOrMoreInFlight: Math.round((overlapMs / (elapsed * 1000)) * 1000) / 1000, maxWritesInFlight: maxInFlight, note: "client-side view: a write is in flight from request to reply. With one gate and a store that serialises, latency rises with writers and throughput stays flat." },
    passThresholdMs: 500,
    p95WithinThreshold: stats(lat).p95 <= 500,
    failures: failures.length, failureSamples: failures.slice(0, 5),
    orderOutcomes: { committed: rows.filter((x) => x[12] === "committed").length, rejected: rows.filter((x) => x[12] === "rejected").length, fault: rows.filter((x) => x[12] === "fault").length },
    rejectedWritesInMix: REJECT_EVERY > 0 ? { every: REJECT_EVERY, ...bad, notRejectedSamples: badFaults.slice(0, 5), note: "known-bad writes sent by --reject-every; a sound store rejects every one and commits every order" } : null,
    faultsTotal: rows.filter((x) => x[12] === "fault").length + bad.fault,
    readers: Object.fromEntries(Object.entries(readerLat).map(([k, v]) => [k, stats(v)])),
    readerErrors: readerRows.filter((l) => l.split(",")[4] === "false").length,
    growthPer100Writes: buckets,
    dataset: { triplesBefore: startSize, triplesAfter: await db.size().catch(() => -1), loadtestGraphBefore: startGraph, loadtestGraphAfter: await db.size(G).catch(() => -1) },
    storeErrors,
    correctness: { orders: Number(check[0].orders.value), ordersReady: Number(check[0].ready.value), derivedRecordsLabelled: Number(check[0].labelled.value) },
    correctnessByWriter: checkByWriter,
    containerView: { cpus: os.cpus().length, cpuModel: os.cpus()[0]?.model, totalMemGiB: Math.round((os.totalmem() / 2 ** 30) * 100) / 100, note: "as seen inside the gate container (the Docker VM on a Mac); host figures are in machine.txt" },
  };
  fs.writeFileSync(path.join(OUT, "writes.csv"), writeRows.join("\n") + "\n");
  fs.writeFileSync(path.join(OUT, "readers.csv"), readerRows.join("\n") + "\n");
  fs.writeFileSync(path.join(OUT, "summary.json"), JSON.stringify(summary, null, 2) + "\n");
  console.log(`[load] done in ${summary.elapsedSeconds} s: write latency p50=${summary.writeLatencyMs.p50} p95=${summary.writeLatencyMs.p95} max=${summary.writeLatencyMs.max} ms; failures=${failures.length}; faults=${summary.faultsTotal}${REJECT_EVERY ? ` bad=${JSON.stringify(bad)}` : ""}; correctness=${JSON.stringify(summary.correctness)}`);
  console.log(`[load] store: ${storeLine}; writes by validation mode: ${JSON.stringify(validationCheck.orderWritesByMode)}; not ${EXPECT_MODE}: ${validationCheck.orderWritesNotInExpectedMode + validationCheck.knownBadWritesNotInExpectedMode}`);
  fs.appendFileSync(machine, `validation:    order writes by mode ${JSON.stringify(validationCheck.orderWritesByMode)}; not ${EXPECT_MODE}: ${validationCheck.orderWritesNotInExpectedMode}; missing header: ${validationCheck.missingHeader}\n`);
  if (configurationFault) { console.error(`[load] CONFIGURATION FAULT: ${summary.configurationFault}`); process.exitCode = 3; }
  console.log(`[load] results in results/${path.relative(paths.results, OUT)}/ (writes.csv, readers.csv, summary.json)`);
  if (failures.length) process.exitCode = 1;
}

main().catch((e) => { console.error(e); process.exit(2); });
