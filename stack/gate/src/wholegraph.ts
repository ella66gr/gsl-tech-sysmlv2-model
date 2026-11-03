// The whole-graph check (S0.5 Pass B4; H-0640; ADR-014 §4.3 and §4.4
// condition 2; D2, Ella S521). It validates the whole runtime dataset outside
// the write path, and carries the three placement queries (Cyril, S0.5 Pass B
// step 2 §3: P1 one home graph, P2 runtime instances only in runtime graphs,
// P3 every graph known) beside the SHACL run. It covers what no per-write check
// catches (ADR-014 §4.3): counts and aggregates across resources (E1), a
// knowledge-graph change that falsifies runtime data (E2), constraints that
// become false with time alone (E3), unbounded paths (E4), shapes that break
// the shape-authoring rule (F11), and the bootstrap's unvalidated loads.
//
// D2: each run writes a report file and one log line, and takes NO automatic
// action: it never writes to the store, never stops a write, never alerts.
//
// Where it runs, and why that is off the write path:
//   - the SHACL run and the placement queries run inside the store, in the
//     module's whole-graph-check operation, in ONE read transaction (one
//     snapshot for the whole report). A read transaction takes no write lock:
//     TDB2 readers and the writer never block each other. No write calls it;
//   - it is called by the `whole-graph-check` Compose service (its own
//     container; cli/wholegraph.ts --schedule) on the schedule, and by the
//     bootstrap after every knowledge-graph load. Never by the gate's server,
//     its evaluation, the Write Stamping Stage or any rule;
//   - by hand: stack/bin/whole-graph-check.sh.
//
// Report: results/<dir>/<UTC time>-<trigger>.json, and latest.json (a copy of
// the newest), and one line appended to results/<dir>/whole-graph-check.log
// and printed. <dir> is whole-graph-check for the runtime stack (host
// stack/results/whole-graph-check/, git-ignored). Format: FORMAT below; its
// fields are stable, and S0.9's health view reads latest.json.
import * as fs from "node:fs";
import * as path from "node:path";
import { randomUUID } from "node:crypto";
import { Store, WholeGraphCheckResult } from "./store";
import { paths, wholeGraphCheck as settings } from "./config";
import { branch, placementTokens, TENANT } from "./graphs";
import { fillPlacement, PLACEMENT_QUERIES } from "./cli/placement";

export const FORMAT = "ontara-whole-graph-check/1";

export interface WholeGraphReport {
  format: string;
  runId: string;
  trigger: string;                  // knowledge-graph-load | schedule | manual | scoping-suite | ...
  startedAt: string;
  durationMs: number;
  dataset: string;
  store: { module: string; jenaVersion: string; validationMode: string } | null;
  declaredBranches: { tenant: string; dhbId: string; dbr: string; dsr: string }[];
  triplesChecked: { namedGraphs: number; storedDefaultGraph: number; total: number; graphs: number } | null;
  shacl: WholeGraphCheckResult["shacl"] | null;
  placement: { query: string; rows: number; sample?: Record<string, string>[]; error?: string; ms: number }[];
  clean: boolean;                   // SHACL conforms, every placement query returned no rows, no error
  fault: string | null;             // the check could not run
  context?: Record<string, unknown>;
  reportFile?: string;
}

const compact = (iso: string) => iso.replace(/[-:]/g, "").replace(/\.\d+Z$/, "Z");

// One run. Never throws: a run that cannot complete is a report with `fault`.
export async function runWholeGraphCheck(store: Store, opts: { trigger: string; dir?: string; context?: Record<string, unknown>; write?: boolean }): Promise<WholeGraphReport> {
  const started = new Date();
  const rep: WholeGraphReport = {
    format: FORMAT, runId: randomUUID().slice(0, 8), trigger: opts.trigger, startedAt: started.toISOString(), durationMs: 0,
    dataset: store.dataset, store: null, declaredBranches: [], triplesChecked: null, shacl: null, placement: [], clean: false, fault: null,
    ...(opts.context ? { context: opts.context } : {}),
  };
  try {
    const st = await store.status();
    rep.store = { module: st.module, jenaVersion: st.jenaVersion, validationMode: st.validationMode };
    if (!st.rrb?.dhbId) throw new Error(`the store reports no Reality Reference Branch for /${store.dataset}`);
    // Pass B: the only declared DHB is the RRB (no declaration records yet).
    const rrb = branch(TENANT, st.rrb.dhbId);
    rep.declaredBranches = [{ tenant: rrb.tenant, dhbId: rrb.dhbId, dbr: rrb.dbr, dsr: rrb.dsr }];
    const tokens = placementTokens([rrb]);
    const queries = PLACEMENT_QUERIES.map((f) => ({ name: f.replace(/\.rq$/, ""), query: fillPlacement(fs.readFileSync(path.join(paths.fixtures, "placement", f), "utf8"), tokens) }));
    const r = await store.wholeGraphCheck(queries);
    rep.triplesChecked = { ...r.triplesChecked, total: r.triplesChecked.namedGraphs + r.triplesChecked.storedDefaultGraph };
    rep.shacl = r.shacl;
    rep.placement = r.queries.map((q) => ({ query: q.name, rows: q.rows, ...(q.sample && q.sample.length ? { sample: q.sample } : {}), ...(q.error ? { error: q.error } : {}), ms: q.ms }));
    const errors = [r.shacl.error, ...r.queries.map((q) => q.error)].filter(Boolean);
    if (errors.length) rep.fault = `part of the check could not run: ${errors.join("; ")}`;
    rep.clean = !rep.fault && r.shacl.conforms && r.queries.every((q) => q.rows === 0);
  } catch (e: any) {
    rep.fault = String(e?.message ?? e);
    rep.clean = false;
  }
  rep.durationMs = Date.now() - started.getTime();
  if (opts.write !== false) writeReport(rep, opts.dir ?? settings.dir);
  console.log(logLine(rep));
  return rep;
}

export function logLine(r: WholeGraphReport): string {
  const t = r.triplesChecked;
  const shacl = !r.shacl ? "not run" : r.shacl.error ? "ERROR" : r.shacl.conforms ? "conforms" : `VIOLATIONS ${r.shacl.results} (${Object.entries(r.shacl.byShape ?? {}).map(([k, v]) => `${k.replace(/^.*[#/]/, "")}=${v}`).join(" ")})`;
  const pl = r.placement.map((p) => `${p.query.split("-")[0]}=${p.rows}`).join(" ");
  return `[whole-graph-check] ${r.startedAt} trigger=${r.trigger} dataset=${r.dataset} triples=${t ? t.total : "?"} shacl=${shacl} ${pl || "placement=not run"} ` +
    `${r.fault ? `FAULT=${JSON.stringify(r.fault.slice(0, 300))}` : r.clean ? "result=clean" : "result=FINDINGS (no automatic action)"} ms=${r.durationMs}${r.reportFile ? ` report=${r.reportFile}` : ""}`;
}

function writeReport(r: WholeGraphReport, dir: string) {
  try {
    const abs = path.join(paths.results, dir);
    fs.mkdirSync(abs, { recursive: true });
    const name = `${compact(r.startedAt)}-${r.trigger}-${r.runId}.json`;
    r.reportFile = path.posix.join("results", dir, name);
    const text = JSON.stringify(r, null, 2) + "\n";
    fs.writeFileSync(path.join(abs, name), text);
    fs.writeFileSync(path.join(abs, "latest.json"), text);
    fs.appendFileSync(path.join(abs, "whole-graph-check.log"), logLine(r) + "\n");
    // Keep the newest `keep` reports; latest.json and the log stay.
    const reports = fs.readdirSync(abs).filter((f) => /^\d{8}T\d{6}Z-.*\.json$/.test(f)).sort();
    for (const f of reports.slice(0, Math.max(0, reports.length - settings.keep))) fs.rmSync(path.join(abs, f), { force: true });
  } catch (e: any) {
    console.error(`[whole-graph-check] could not write the report under results/${dir}: ${e?.message ?? e}`);
  }
}
