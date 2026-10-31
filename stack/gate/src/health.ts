// The S0.1 health check (H-0268; specification 2.5 item 6). Tests each service
// through the client the Cafe uses, not a liveness ping:
//   1. GraphDB: SPARQL probes of the knowledge graph return the expected
//      content, and the runtime repository reports SHACL on;
//   2. the gate (over its own HTTP API): a known-good stand-in write commits,
//      a known-bad one comes back as a SHACL rejection naming the shape, and a
//      write after that commits, which shows the lock was released;
//   3. Temporal: a no-op workflow starts and completes.
import { GraphDB, param } from "./graphdb";
import { config, graphs } from "./config";
import { readFixture, fill, runId } from "./fixtures";
import { runNoop } from "./temporal";

interface Check { name: string; pass: boolean; ms: number; detail: any }

const db = new GraphDB();
const EXPECTED_SHAPE = "urn:ontara:standin:shapes#RecordModeMethodShape";

async function gateWrite(body: any, timeoutMs = 20_000): Promise<{ http: number; json: any }> {
  const r = await fetch(`${config.gateUrl}/write`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
    signal: AbortSignal.timeout(timeoutMs),
  });
  return { http: r.status, json: await r.json() };
}

async function timed(name: string, fn: () => Promise<{ pass: boolean; detail: any }>): Promise<Check> {
  const t = performance.now();
  try {
    const { pass, detail } = await fn();
    return { name, pass, ms: Math.round(performance.now() - t), detail };
  } catch (e: any) {
    return { name, pass: false, ms: Math.round(performance.now() - t), detail: { error: String(e?.message ?? e) } };
  }
}

export async function runHealth() {
  const run = runId();
  const started = new Date().toISOString();
  const checks: Check[] = [];

  // 1. GraphDB
  checks.push(await timed("graphdb: knowledge-graph content", async () => {
    const probes = JSON.parse(readFixture("health/kg-expectations.json")).probes as { name: string; ask: string }[];
    const results = [];
    for (const p of probes) results.push({ probe: p.name, result: await db.ask(p.ask) });
    return { pass: results.every((r) => r.result === true), detail: results };
  }));
  checks.push(await timed("graphdb: runtime repository has SHACL on", async () => {
    const cfg = await db.repositoryConfig();
    const detail = { repository: config.repository, isShacl: param(cfg, "isShacl"), validationEnabled: param(cfg, "validationEnabled") };
    return { pass: detail.isShacl === "true" && detail.validationEnabled === "true", detail };
  }));

  // 2. The gate
  const good = (id: string) => ({ graph: graphs.health, turtle: fill(readFixture("writes/known-good.ttl"), { RUN: id }), label: "health known-good" });
  checks.push(await timed("gate: known-good write commits", async () => {
    const r = await gateWrite(good(`${run}-a`));
    return { pass: r.http === 200 && r.json.outcome === "committed", detail: { http: r.http, outcome: r.json.outcome, timings: r.json.timings } };
  }));
  checks.push(await timed("gate: known-bad write is a SHACL rejection naming the shape", async () => {
    const r = await gateWrite({ graph: graphs.health, turtle: fill(readFixture("writes/known-bad.ttl"), { RUN: `${run}-b` }), label: "health known-bad" });
    const pass = r.http === 422 && r.json.outcome === "rejected" && (r.json.nodeShapes ?? []).includes(EXPECTED_SHAPE) && r.json.rolledBack === true;
    return { pass, detail: { http: r.http, outcome: r.json.outcome, shapes: r.json.shapes, nodeShapes: r.json.nodeShapes, components: (r.json.results ?? []).map((x: any) => x.component), rolledBack: r.json.rolledBack } };
  }));
  checks.push(await timed("gate: write after the rejection commits (lock released)", async () => {
    const r = await gateWrite(good(`${run}-c`), 15_000);
    return { pass: r.http === 200 && r.json.outcome === "committed", detail: { http: r.http, outcome: r.json.outcome, timings: r.json.timings } };
  }));
  // Housekeeping, not a pass criterion: empty the health graph through the gate.
  const cleanup = await gateWrite({ updates: [`CLEAR SILENT GRAPH <${graphs.health}>`], label: "health cleanup" }).catch((e) => ({ http: 0, json: { outcome: String(e) } }));

  // 3. Temporal
  checks.push(await timed("temporal: no-op workflow starts and completes", async () => {
    const r = await runNoop(run);
    return { pass: r.result === `noop:${run}`, detail: r };
  }));

  const pass = checks.every((c) => c.pass);
  return { status: pass ? "pass" : "fail", run, started, repository: config.repository, checks, cleanup: { http: cleanup.http, outcome: cleanup.json.outcome } };
}
