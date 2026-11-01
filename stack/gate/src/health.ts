// The S0.1 health check (H-0268; specification 2.5 item 6). Tests each service
// through the client the Cafe uses, not a liveness ping:
//   1. the store: SPARQL probes of the knowledge graph return the expected
//      content, and the module's status reports validating on, the expected
//      mode (targeted), the pinned Jena version and shapes loaded;
//   2. the gate (over its own HTTP API): a known-good stand-in write commits,
//      a known-bad one comes back as a SHACL rejection naming the shape, and
//      a write after that commits; the rejected record is not stored, which
//      shows the rejected write left nothing behind. Every write must carry
//      an X-Ontara-Validation header naming the expected mode;
//   3. Temporal: a no-op workflow starts and completes.
import { runtimeStore } from "./gate";
import { config, graphs, validatedAs } from "./config";
import { readFixture, fill, runId } from "./fixtures";
import { runNoop } from "./temporal";

interface Check { name: string; pass: boolean; ms: number; detail: any }

const db = runtimeStore();
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

const mode = config.expectedValidationMode;
const inMode = (j: any) => validatedAs(j?.validation, mode);

export async function runHealth() {
  const run = runId();
  const started = new Date().toISOString();
  const checks: Check[] = [];
  let storeStatus: any = null;

  // 1. The store
  checks.push(await timed("store: knowledge-graph content", async () => {
    const probes = JSON.parse(readFixture("health/kg-expectations.json")).probes as { name: string; ask: string }[];
    const results = [];
    for (const p of probes) results.push({ probe: p.name, result: await db.ask(p.ask) });
    return { pass: results.every((r) => r.result === true), detail: results };
  }));
  checks.push(await timed(`store: module validating, ${mode} mode, Jena ${config.expectedJenaVersion}, shapes loaded`, async () => {
    const s = await db.status();
    storeStatus = s;
    const detail = {
      dataset: config.dataset, module: s.module, validating: s.validating, validationMode: s.validationMode,
      jenaVersion: s.jenaVersion, jenaBuildVersion: s.jenaBuildVersion, shapesGraph: s.shapesGraph, shapesTriples: s.shapesTriples,
      unionDefaultGraph: s.unionDefaultGraph, inference: s.inference,
      expected: { validationMode: mode, jenaVersion: config.expectedJenaVersion },
    };
    const pass = s.validating === true && s.validationMode === mode && s.jenaVersion === config.expectedJenaVersion
      && s.jenaBuildVersion === config.expectedJenaVersion && s.shapesTriples > 0 && s.unionDefaultGraph === true && s.inference === "none";
    return { pass, detail };
  }));

  // 2. The gate
  const good = (id: string) => ({ graph: graphs.health, turtle: fill(readFixture("writes/known-good.ttl"), { RUN: id }), label: "health known-good" });
  const badIri = `urn:ontara:standin:cafe#bad-${run}-b`;
  checks.push(await timed("gate: known-good write commits", async () => {
    const r = await gateWrite(good(`${run}-a`));
    return { pass: r.http === 200 && r.json.outcome === "committed" && inMode(r.json), detail: { http: r.http, outcome: r.json.outcome, validation: r.json.validation, timings: r.json.timings } };
  }));
  checks.push(await timed("gate: known-bad write is a SHACL rejection naming the shape", async () => {
    const r = await gateWrite({ graph: graphs.health, turtle: fill(readFixture("writes/known-bad.ttl"), { RUN: `${run}-b` }), label: "health known-bad" });
    const pass = r.http === 422 && r.json.outcome === "rejected" && (r.json.nodeShapes ?? []).includes(EXPECTED_SHAPE) && r.json.rolledBack === true && inMode(r.json);
    return { pass, detail: { http: r.http, outcome: r.json.outcome, shapes: r.json.shapes, nodeShapes: r.json.nodeShapes, components: (r.json.results ?? []).map((x: any) => x.component), messages: (r.json.results ?? []).map((x: any) => x.message), rolledBack: r.json.rolledBack, transaction: r.json.transaction, validation: r.json.validation } };
  }));
  checks.push(await timed("gate: write after the rejection commits, and the rejected record is not stored", async () => {
    const r = await gateWrite(good(`${run}-c`), 15_000);
    const rejectedStored = await db.ask(`ASK { GRAPH ?g { <${badIri}> ?p ?o } }`);
    return { pass: r.http === 200 && r.json.outcome === "committed" && inMode(r.json) && rejectedStored === false, detail: { http: r.http, outcome: r.json.outcome, validation: r.json.validation, rejectedRecordStored: rejectedStored, timings: r.json.timings } };
  }));
  // Housekeeping, not a pass criterion: empty the health graph through the
  // gate. (A CLEAR is validated whole, by the module's fall-back rule.)
  const cleanup = await gateWrite({ updates: [`CLEAR SILENT GRAPH <${graphs.health}>`], label: "health cleanup" }).catch((e) => ({ http: 0, json: { outcome: String(e) } }));

  // 3. Temporal
  checks.push(await timed("temporal: no-op workflow starts and completes", async () => {
    const r = await runNoop(run);
    return { pass: r.result === `noop:${run}`, detail: r };
  }));

  const pass = checks.every((c) => c.pass);
  return {
    status: pass ? "pass" : "fail", run, started,
    store: storeStatus ? `Apache Jena Fuseki ${storeStatus.fusekiVersion}, ${storeStatus.module}, ${storeStatus.validationMode} validation` : "unreachable",
    dataset: config.dataset, checks,
    cleanup: { http: cleanup.http, outcome: cleanup.json.outcome, validation: (cleanup.json as any).validation ?? null },
  };
}
