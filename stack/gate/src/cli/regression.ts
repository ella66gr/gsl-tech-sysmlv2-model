// The abort-defect regression check's driver (specification 2.5 item 11;
// ADR-014 §4.4 condition 3). Ported at S521 from the OP-134 spike's
// spike/bin/fault-repro.sh. stack/bin/regression-check.sh runs it inside the
// gate container, in steps, between the store restarts it makes:
//
//   wait      --out D --label L                 wait for the store; record its module status
//   writes    --out D --graph G --bad K --good N --run R
//                                               K known-bad then N known-good writes, one at a
//                                               time, through the gate's HTTP API
//   verify    --out D --graph G --label L       count the good records (SPARQL), then read every
//                                               quad back through the Graph Store Protocol
//   summarise --out D --good N --bad K          judge the run; summary.json; exit 0 PASS, 1 FAIL
//
// Jena GH-3877 (5.x and 6.0.x): after an aborted write that read uncached
// nodes, a later write leaves a zero-filled gap in nodes-data.obj and a
// committed node becomes unreadable. Every write is reported committed, yet
// a record is lost on restart. The check fails if any good write is lost or
// unreadable, or on any fault.
import * as fs from "node:fs";
import * as path from "node:path";
import { config, paths } from "../config";
import { openStore } from "../store";
import { fill, readFixture } from "../fixtures";

const args = process.argv.slice(2);
const cmd = args[0];
const opt = (n: string, d = "") => { const i = args.indexOf(n); return i >= 0 ? args[i + 1] : d; };
const OUT = path.join(paths.results, opt("--out"));
const db = openStore();
const GOOD_PREFIX = "urn:ontara:standin:cafe#good-rg";
const BAD_PREFIX = "urn:ontara:standin:cafe#bad-rg";

const jsonOut = (name: string, x: any) => fs.writeFileSync(path.join(OUT, name), JSON.stringify(x, null, 2) + "\n");
const csvSafe = (x: any) => String(x ?? "").replace(/[\r\n,]/g, " ").slice(0, 300);

async function waitStore() {
  const label = opt("--label", "status");
  for (let i = 0; i < 180; i++) {
    try {
      const s = await db.status();
      jsonOut(`module-status-${label}.json`, s);
      console.log(`[regression] store up (${label}): Jena ${s.jenaVersion} (built for ${s.jenaBuildVersion}), ${s.module}, validation ${s.validationMode}, shapes ${s.shapesTriples} triples`);
      return;
    } catch { await new Promise((r) => setTimeout(r, 1000)); }
  }
  console.error("[regression] store did not answer within 180 s");
  process.exit(2);
}

async function writes() {
  const graph = opt("--graph"), run = opt("--run");
  const BAD = Number(opt("--bad", "1")), GOOD = Number(opt("--good", "60"));
  const rows = ["seq,kind,iri,outcome,http,transaction,validation,fault_detail"];
  const jsonl: string[] = [];
  let seq = 0;
  const send = async (kind: "bad" | "good") => {
    seq++;
    const rid = `rg${String(seq).padStart(3, "0")}-${run}`;
    const file = kind === "bad" ? "writes/known-bad.ttl" : "writes/known-good.ttl";
    const iri = `urn:ontara:standin:cafe#${kind}-${rid}`;
    let http = 0, j: any;
    try {
      const r = await fetch(`${config.gateUrl}/write`, {
        method: "POST", headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ graph, turtle: fill(readFixture(file), { RUN: rid }), label: `regression ${kind} ${seq}` }),
        signal: AbortSignal.timeout(120_000),
      });
      http = r.status; j = await r.json();
    } catch (e: any) { j = { outcome: "fault", detail: `no reply from the gate: ${String(e?.message ?? e)}` }; }
    jsonl.push(JSON.stringify({ seq, kind, iri, http, ...j }));
    rows.push([seq, kind, iri, j.outcome, http, j.transaction ?? "", csvSafe(j.validation), j.outcome === "fault" ? csvSafe(j.detail) : ""].join(","));
    console.log(`${kind} ${String(seq).padStart(3)} ${String(j.outcome).padEnd(9)} ${j.outcome === "fault" ? String(j.detail).slice(0, 90) : (j.validation ?? "")}`);
  };
  for (let i = 0; i < BAD; i++) await send("bad");
  for (let i = 0; i < GOOD; i++) await send("good");
  fs.writeFileSync(path.join(OUT, "outcomes.csv"), rows.join("\n") + "\n");
  fs.writeFileSync(path.join(OUT, "writes.jsonl"), jsonl.join("\n") + "\n");
}

// Reads every quad of the dataset through GET /<dataset>/data (N-Quads),
// streaming, without keeping the dump: counts quads and the quads that name a
// good or bad record of this check, and records whether the stream ended
// cleanly. On a GH-3877 store the read breaks off part-way.
async function readBack() {
  const url = `${config.storeUrl}/${config.dataset}/data`;
  const out: any = { url, http: null, quads: 0, goodRecordQuads: 0, badRecordQuads: 0, complete: false, error: null, lastBytes: "" };
  try {
    const r = await fetch(url, { headers: { Accept: "application/n-quads" }, signal: AbortSignal.timeout(600_000) });
    out.http = r.status;
    const reader = r.body!.getReader();
    const dec = new TextDecoder();
    let rest = "";
    for (;;) {
      const { done, value } = await reader.read();
      if (done) break;
      const text = rest + dec.decode(value, { stream: true });
      const lines = text.split("\n");
      rest = lines.pop() ?? "";
      for (const l of lines) {
        if (!l.trim()) continue;
        out.quads++;
        if (l.includes(GOOD_PREFIX)) out.goodRecordQuads++;
        if (l.includes(BAD_PREFIX)) out.badRecordQuads++;
      }
      out.lastBytes = (out.lastBytes + text).slice(-300);
    }
    if (rest.trim()) { out.trailingPartialLine = rest.slice(0, 300); }
    // A complete N-Quads dump ends on a newline; a broken one stops mid-line.
    out.complete = r.status === 200 && !rest.trim();
  } catch (e: any) {
    out.error = String(e?.message ?? e).slice(0, 500);
  }
  return out;
}

async function verify() {
  const graph = opt("--graph"), label = opt("--label");
  const q = `SELECT (COUNT(DISTINCT ?s) AS ?n) WHERE { GRAPH <${graph}> { ?s a <urn:ontara:standin:rec#PlatformRecord> . FILTER(STRSTARTS(STR(?s), "${GOOD_PREFIX}")) } }`;
  const qb = `SELECT (COUNT(DISTINCT ?s) AS ?n) WHERE { GRAPH ?g { ?s ?p ?o . FILTER(STRSTARTS(STR(?s), "${BAD_PREFIX}")) } }`;
  const res: any = { label, at: new Date().toISOString() };
  try { res.goodRecordsStored = Number((await db.select(q, 120_000))[0]?.n?.value ?? -1); } catch (e: any) { res.goodRecordsStored = null; res.countError = String(e?.message ?? e).slice(0, 500); }
  try { res.badRecordsStored = Number((await db.select(qb, 120_000))[0]?.n?.value ?? -1); } catch (e: any) { res.badRecordsStored = null; res.badCountError = String(e?.message ?? e).slice(0, 500); }
  res.readBack = await readBack();
  jsonOut(`readback-${label}.json`, res);
  console.log(`[regression] ${label}: good records stored ${res.goodRecordsStored}, bad records stored ${res.badRecordsStored}; read-back http=${res.readBack.http} quads=${res.readBack.quads} complete=${res.readBack.complete}${res.readBack.error ? ` error=${res.readBack.error}` : ""}`);
}

function summarise() {
  const GOOD = Number(opt("--good", "60")), BAD = Number(opt("--bad", "1"));
  const read = (f: string) => { const p = path.join(OUT, f); return fs.existsSync(p) ? fs.readFileSync(p, "utf8") : null; };
  const params = JSON.parse(read("params.json") ?? "{}");
  const rows = (read("outcomes.csv") ?? "").trim().split("\n").slice(1).filter(Boolean).map((l) => l.split(","));
  const count = (kind: string, outcome: string) => rows.filter((r) => r[1] === kind && r[3] === outcome).length;
  const before = JSON.parse(read("readback-before-restart.json") ?? "null");
  const after = JSON.parse(read("readback-after-restart.json") ?? "null");
  const status = JSON.parse(read("module-status-before-writes.json") ?? "null");
  const nt = read("nodetable-check.txt") ?? "";
  const bdf = read("bdf-truncate-check.txt") ?? "";
  const storeLog = read("store.log") ?? "";
  const physical = nt.split("\n").filter((l) => l.startsWith("PHYSICAL "));
  const zeroRuns = physical.reduce((a, l) => a + Number((l.match(/zero runs >= \d+: (\d+)/) ?? [])[1] ?? NaN), 0);
  const logical = nt.split("\n").find((l) => l.startsWith("LOGICAL ")) ?? "";
  const faultTraces = (storeLog.match(/FAULT \(aborted\)/g) ?? []).length;
  const modes = rows.reduce((a: Record<string, number>, r) => { const k = r[6] ? r[6].split(/[; ]/)[0] : "(no header)"; a[k] = (a[k] ?? 0) + 1; return a; }, {});
  const checks: { name: string; pass: boolean; detail: any }[] = [
    { name: "module status: validating, the run's mode", pass: !!status && status.validating === true && status.validationMode === params.mode, detail: status && { jenaVersion: status.jenaVersion, jenaBuildVersion: status.jenaBuildVersion, module: status.module, validationMode: status.validationMode } },
    { name: `the ${BAD} known-bad write(s) rejected`, pass: count("bad", "rejected") === BAD, detail: { rejected: count("bad", "rejected"), committed: count("bad", "committed"), fault: count("bad", "fault") } },
    { name: `all ${GOOD} known-good writes committed`, pass: count("good", "committed") === GOOD, detail: { committed: count("good", "committed"), rejected: count("good", "rejected"), fault: count("good", "fault") } },
    { name: "every write validated in the run's mode", pass: rows.length === GOOD + BAD && rows.every((r) => (r[6] ?? "").split(/[; ]/)[0] === params.mode), detail: modes },
    { name: "good records stored before the restart", pass: before?.goodRecordsStored === GOOD, detail: before && { goodRecordsStored: before.goodRecordsStored, badRecordsStored: before.badRecordsStored } },
    { name: "good records stored after the restart", pass: after?.goodRecordsStored === GOOD && after?.badRecordsStored === 0, detail: after && { goodRecordsStored: after.goodRecordsStored, badRecordsStored: after.badRecordsStored, countError: after.countError ?? null } },
    { name: "full read-back after the restart complete, and equal to the read-back before it", pass: !!after && after.readBack.complete === true && !!before && before.readBack.complete === true && after.readBack.quads === before.readBack.quads && after.readBack.goodRecordQuads === before.readBack.goodRecordQuads && after.readBack.goodRecordQuads > 0, detail: { before: before?.readBack && { http: before.readBack.http, quads: before.readBack.quads, goodRecordQuads: before.readBack.goodRecordQuads, complete: before.readBack.complete, error: before.readBack.error }, after: after?.readBack && { http: after.readBack.http, quads: after.readBack.quads, goodRecordQuads: after.readBack.goodRecordQuads, complete: after.readBack.complete, error: after.readBack.error } } },
    { name: "no fault stack trace in the store log", pass: faultTraces === 0 && storeLog.length > 0, detail: { faultTraces, storeLogBytes: storeLog.length } },
    { name: "offline node-table check: no zero-filled run in nodes-data.obj", pass: physical.length > 0 && zeroRuns === 0, detail: physical },
    { name: "offline node-table check: every quad read", pass: /^LOGICAL read every quad: \d+ quads, no error/.test(logical), detail: logical },
    { name: "Jena file-layer check (BdfTruncateCheck): sound", pass: /SOUND/.test(bdf), detail: bdf.trim().split("\n").filter((l) => l.startsWith("Jena ")) },
  ];
  const pass = checks.every((c) => c.pass);
  const summary = {
    result: pass ? "PASS" : "FAIL",
    kind: params.kind ?? "regression check",
    ...params,
    sequence: `${BAD} known-bad write(s), then ${GOOD} known-good writes, one at a time through the gate`,
    checks,
    expectedUnderASoundStore: "bad rejected; every good write committed; zero faults; every good record stored and readable after the restart; node table clean",
    files: ["params.json", "bootstrap.log", "preload/ (load harness run)", "module-status-*.json", "outcomes.csv", "writes.jsonl", "readback-before-restart.json", "readback-after-restart.json", "store.log", "nodetable-check.txt", "bdf-truncate-check.txt"],
  };
  jsonOut("summary.json", summary);
  for (const c of checks) console.log(`${c.pass ? "PASS" : "FAIL"}  ${c.name}`);
  console.log(`REGRESSION CHECK: ${summary.result}  (${params.runId ?? ""}; Jena ${status?.jenaVersion ?? "?"}, ${params.mode} validation)`);
  process.exit(pass ? 0 : 1);
}

async function main() {
  fs.mkdirSync(OUT, { recursive: true });
  switch (cmd) {
    case "wait": return waitStore();
    case "writes": return writes();
    case "verify": return verify();
    case "summarise": return summarise();
    default: console.error(`unknown step: ${cmd}`); process.exit(2);
  }
}
main().catch((e) => { console.error(e); process.exit(2); });
