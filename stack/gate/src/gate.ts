// The constraint gate's write path (S0.1, specification 2.5 item 4; S0.5 Pass
// B3), kept thin, behind the store interface (store/). One adapter: Fuseki
// with Ontara's validated-update module (store/fuseki.ts).
//
// A runtime write goes through three roles, in this order:
//   1. the gate's evaluation: the named-graph scheme's four write rules
//      (B3 item 4). The gate refuses a request that names a graph itself
//      (rule "graph-from-writer": the graph is derived, never accepted), and
//      decides the request's write policy: the only graphs it may change are
//      its Declared History Branch's dbr and dsr graphs; the knowledge-graph
//      and shapes graphs are protected. The store module applies the policy
//      to the exact quads the request changes, inside its write transaction
//      (default-graph quads, writes into the knowledge graph or the shapes,
//      a request spanning two DHBs, a write to an instance whose home is
//      another DHB), and aborts with a refusal naming the rule;
//   2. the Write Stamping Stage (wss.ts), a separate role: sets the graph;
//   3. the store: one SPARQL Update request (the placed triples as INSERT DATA,
//      then the updates in order), validated by the module before commit. It
//      answers 200 on commit, 403 on a write-policy refusal, 422 with the SHACL
//      report on a rejection and 500 on a fault, and has already aborted the
//      transaction in each failing case, so the gate needs no rollback.
//      write() never rejects (S519, e42a70c).
// The gate writes no decision record yet: the Access Decision Evaluator and
// its records arrive at S0.7.
import { openStore, Store } from "./store";
import { WriteRequest, WriteOutcome, WritePolicy, Timings, SCRATCH_DATASET } from "./store/types";
import { stamp, RuntimeWrite } from "./wss";
import { PROTECTED_GRAPHS, RUNTIME_GRAPH_ROOT, Branch } from "./graphs";

export type { WriteRequest, WriteOutcome, Timings } from "./store/types";
export type { RuntimeWrite } from "./wss";

let runtime: Store | null = null;
export const runtimeStore = (): Store => (runtime ??= openStore());

const zero = (): Timings => ({ begin: 0, add: 0, updates: 0, commit: 0, rollback: 0, total: 0 });

// The gate's evaluation: the write policy for a request in a branch.
export function writePolicy(b: Branch): WritePolicy {
  return { allowedGraphs: [b.dbr, b.dsr], protectedGraphs: PROTECTED_GRAPHS, runtimeGraphPrefix: RUNTIME_GRAPH_ROOT };
}

// A runtime write: evaluation, then the WSS, then the store.
export async function write(req: RuntimeWrite & { graph?: unknown }): Promise<WriteOutcome> {
  const t0 = performance.now();
  if (req.graph !== undefined && req.graph !== null) {
    return { outcome: "refused", stage: "gate", rules: ["graph-from-writer"], violations: [{ rule: "graph-from-writer", graph: String(req.graph), detail: "a writer never names the graph: the Write Stamping Stage derives it from the request's Declared History Branch and the content's side" }],
             rolledBack: false, transaction: "unknown", validation: null, timings: { ...zero(), total: performance.now() - t0 }, detail: "refused by the write rule graph-from-writer (nothing was sent to the store)" };
  }
  const store = runtimeStore();
  let st;
  try { st = await stamp(req, store); }
  catch (e: any) { return { outcome: "fault", stage: "stamp", httpStatus: null, detail: String(e?.message ?? e), rolledBack: false, transaction: "unknown", validation: null, timings: { ...zero(), total: performance.now() - t0 } }; }
  if ("refused" in st) {
    const rules = [...new Set(st.refused.map((r) => r.rule))];
    return { outcome: "refused", stage: "gate", rules, violations: st.refused, rolledBack: false, transaction: "unknown", validation: null, timings: { ...zero(), total: performance.now() - t0 },
             detail: `refused by the write rule${rules.length === 1 ? "" : "s"} ${rules.join(", ")} (nothing was sent to the store)` };
  }
  const s = st.stamped;
  const out = await store.write({ quads: s.quads, updates: s.updates, policy: writePolicy(s.branch), label: req.label });
  out.timings.total = performance.now() - t0;
  return out;
}

// The capability checks' write: straight to the adapter, in the scratch
// dataset only, which never holds runtime content and is outside the scheme.
export function writeScratch(req: WriteRequest, s: Store): Promise<WriteOutcome> {
  if (s.dataset !== SCRATCH_DATASET) throw new Error(`writeScratch is for /${SCRATCH_DATASET} only, not /${s.dataset}`);
  return s.write(req);
}
