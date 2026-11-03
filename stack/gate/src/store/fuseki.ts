// Apache Jena Fuseki adapter, with Ontara's validated-update module
// (stack/store/module). Ported from the OP-134 spike at S521, S0.1 pass 3.
//
// Fuseki runs each update request as one transaction, so a gate write and
// its rules go as ONE SPARQL Update request:
//   INSERT DATA { GRAPH <g> { ...the write's triples... } } ; rule 1 ; rule 2 ...
// to /{dataset}/validated-update. The module runs the request inside one TDB2
// write transaction, validates it with jena-shacl (targeted or whole, set when
// the store starts), and commits or aborts. It answers:
//   200  committed
//   422  SHACL rejection, with the validation report (N-Triples); aborted
//   400  the request does not parse (no transaction was begun)
//   500  any other fault; aborted
// with X-Ontara-Transaction (committed or aborted) and X-Ontara-Validation
// (how the write was validated). The store has already aborted in every
// failing case, so the gate sends no rollback: the S519 rollback-before-read
// fix (e42a70c) has nothing to act on here. Its other half stands: write()
// never rejects, and every failure, including a report the gate cannot read
// or a request that never reaches the store, comes back as an outcome.
//
// Writes sent to a dataset's standard /update or /data endpoints are NOT
// validated: only the module's endpoint validates. Those endpoints accept
// writes only on the store's stack-network listener (store:3030, which the
// stack's containers use); the listener published to the host
// (127.0.0.1:7210) serves them read-only (README section 8).
import { http, HttpResult } from "./http";
import { SparqlHttp } from "./sparql-http";
import { parseTurtleInto, dataBlock } from "./rdfjs";
import { Store, WriteRequest, WriteOutcome, GraphLoad, Timings, ModuleStatus, TransactionEnd,
         ONTARA_SHAPES_GRAPH, RUNTIME_DATASET, SCRATCH_DATASET, SH } from "./types";
import { looksLikeShaclRejection, parseReport } from "../report";
import { graphs } from "../config";

const PROVISIONED = [RUNTIME_DATASET, SCRATCH_DATASET];

export class FusekiStore implements Store {
  readonly kind = "fuseki" as const;
  readonly label = "store";
  readonly shapesGraph = ONTARA_SHAPES_GRAPH;
  readonly sparql: SparqlHttp;
  constructor(readonly base: string, readonly dataset: string) {
    const ds = `${base}/${dataset}`;
    this.sparql = new SparqlHttp(`${ds}/query`, `${ds}/update`, `${ds}/data`);
  }
  get datasetUrl() { return `${this.base}/${this.dataset}`; }
  withDataset(id: string) { return new FusekiStore(this.base, id); }

  select(q: string, timeoutMs?: number) { return this.sparql.select(q, timeoutMs); }
  ask(q: string) { return this.sparql.ask(q); }
  update(u: string): Promise<HttpResult> { return this.sparql.update(u); }
  async replaceGraph(g: string, data: string, ct: string): Promise<GraphLoad> {
    const r = await this.sparql.putGraph(g, data, ct);
    return { ok: r.status === 200 || r.status === 201 || r.status === 204, status: r.status, body: r.body };
  }
  size(graph?: string) { return this.sparql.count(graph); }
  shapesTriples() { return this.sparql.count(this.shapesGraph); }

  // Names the node shape that owns a property shape, so a rejection names a
  // shape a person can find in the shapes file. Never throws.
  async nodeShapeOf(propertyShape: string | null): Promise<string | null> {
    if (!propertyShape || propertyShape.startsWith("_:")) return null;
    const r = await this.sparql.select(`SELECT ?n WHERE { GRAPH <${this.shapesGraph}> { ?n <${SH}property> <${propertyShape}> } } LIMIT 1`).catch(() => []);
    return r[0]?.n?.value ?? propertyShape; // a node shape with a direct constraint names itself
  }

  // Never rejects (S519, e42a70c): every failure becomes an outcome.
  async write(req: WriteRequest): Promise<WriteOutcome> {
    const t: Timings = { begin: 0, add: 0, updates: 0, commit: 0, rollback: 0, total: 0 };
    const t0 = performance.now();
    const finish = () => { t.total = performance.now() - t0; return t; };
    let stage = "add";
    let validation: string | null = null;
    let transaction: TransactionEnd = "unknown";
    const fault = (httpStatus: number | null, detail: string): WriteOutcome => ({
      outcome: "fault", stage, httpStatus, detail, rolledBack: transaction === "aborted", transaction, validation, timings: finish(),
    });
    try {
      const ops: string[] = [];
      if (req.turtle && req.turtle.trim()) {
        const s = performance.now();
        const quads = parseTurtleInto(req.turtle, req.graph ?? graphs.manual);
        ops.push(`INSERT DATA {\n${dataBlock(quads)}\n}`);
        t.add = performance.now() - s;
      }
      for (const u of req.updates ?? []) ops.push(u);
      if (!ops.length) return fault(null, "nothing to write: give turtle and/or updates");
      stage = "commit";
      const s = performance.now();
      let r: HttpResult;
      try {
        r = await http("POST", `${this.datasetUrl}/validated-update`, { body: ops.join(" ;\n"), contentType: "application/sparql-update", timeoutMs: 600_000 });
      } catch (e: any) {
        // The request failed or timed out without a reply: whether the store
        // committed is not known, so the outcome says "unknown", never "rolled back".
        t.commit = performance.now() - s;
        return fault(null, `no reply from the store: ${String(e?.message ?? e)}`);
      }
      t.commit = performance.now() - s;
      validation = r.headers.get("x-ontara-validation");
      const tx = r.headers.get("x-ontara-transaction");
      transaction = tx === "committed" || tx === "aborted" ? tx : "unknown";
      if (r.status === 200 || r.status === 204) {
        return { outcome: "committed", timings: finish(), validation, transaction };
      }
      if (r.status === 422 && looksLikeShaclRejection(r.contentType, r.body)) {
        stage = "validate";
        let report;
        try {
          report = parseReport(r.body);
        } catch (e: any) {
          return fault(r.status, `SHACL rejection report unreadable (${String(e?.message ?? e)}); body starts: ${r.body.slice(0, 2000)}`);
        }
        const results = await Promise.all(report.results.map(async (x) => ({ ...x, nodeShape: await this.nodeShapeOf(x.sourceShape) })));
        const nodeShapes = [...new Set(results.map((x) => x.nodeShape).filter((x): x is string => !!x))];
        return { outcome: "rejected", stage, shapes: report.shapes, nodeShapes, results, rolledBack: transaction === "aborted", transaction, validation, timings: finish() };
      }
      return fault(r.status, r.body.slice(0, 2000));
    } catch (e: any) {
      // A Turtle parse error, or anything else before the request was sent.
      return fault(null, String(e?.message ?? e));
    }
  }

  async status(id = this.dataset): Promise<ModuleStatus> {
    const r = await http("GET", `${this.base}/${id}/validated-update`, { accept: "application/json", timeoutMs: 10_000 });
    if (r.status !== 200) throw new Error(`validated-update status /${id}: HTTP ${r.status}: ${r.body.slice(0, 300)}`);
    return JSON.parse(r.body);
  }
  datasets() { return [...PROVISIONED]; }
  async clearDataset(id: string): Promise<GraphLoad> {
    const r = await new FusekiStore(this.base, id).update("CLEAR ALL");
    return { ok: r.status === 200 || r.status === 204, status: r.status, body: r.body };
  }
}
