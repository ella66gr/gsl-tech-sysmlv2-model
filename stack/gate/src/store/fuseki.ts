// Apache Jena Fuseki adapter (5.6.0 at S518; 5.6.0 or 6.2.0 from S519), with the Ontara validated-update module
// (stack/spike/fuseki/module). Fuseki takes each update request as one
// transaction, so a gate write and its rules go as ONE SPARQL Update request:
//   INSERT DATA { GRAPH <g> { ...the write's triples... } } ; rule 1 ; rule 2 ...
// to /{dataset}/validated-update, where the module runs the request inside
// jena-shacl's GraphValidation.update over the dataset's union graph and
// aborts the transaction if the result does not conform.
//
// Not offered, said explicitly:
//   - separate phase timings: one request, so begin/add/updates are 0 and the
//     whole request is reported as `commit`;
//   - RDF4J's Bulk validation setting: the module's mode (whole or targeted,
//     set when the store starts; S519) decides, so `validation: "bulk"`
//     changes nothing here. Each outcome's `validation` field carries the
//     module's X-Ontara-Validation header: how that write was validated;
//   - creating repositories: datasets are fixed when the server starts. The
//     scratch dataset `cafe-capability-scratch` is pre-provisioned, and
//     "create" and "delete" clear it.
// Writes sent to the dataset's standard /update or /data endpoints are NOT
// validated: only the module's endpoint validates.
import { http, HttpResult } from "./graphdb-client";
import { SparqlHttp } from "./sparql-http";
import { parseTurtleInto, dataBlock } from "./rdfjs";
import { Store, WriteRequest, WriteOutcome, RepoReadBack, StoreInfo, GraphLoad, Timings, ONTARA_SHAPES_GRAPH, notApplicable, SH } from "./types";
import { looksLikeShaclRejection, parseReport } from "../report";
import { graphs } from "../config";

const PROVISIONED = ["cafe-runtime", "cafe-capability-scratch"];

export class FusekiStore implements Store {
  readonly kind = "fuseki" as const;
  readonly label = "fuseki";
  readonly shapesGraph = ONTARA_SHAPES_GRAPH;
  readonly sparql: SparqlHttp;
  constructor(readonly base: string, readonly repository: string) {
    const ds = `${base}/${repository}`;
    this.sparql = new SparqlHttp(`${ds}/query`, `${ds}/update`, `${ds}/data`);
  }
  get datasetUrl() { return `${this.base}/${this.repository}`; }
  withRepo(id: string) { return new FusekiStore(this.base, id); }

  select(q: string, timeoutMs?: number) { return this.sparql.select(q, timeoutMs); }
  ask(q: string) { return this.sparql.ask(q); }
  update(u: string): Promise<HttpResult> { return this.sparql.update(u); }
  async replaceGraph(g: string, data: string, ct: string): Promise<GraphLoad> {
    const r = await this.sparql.putGraph(g, data, ct);
    return { ok: r.status === 200 || r.status === 201 || r.status === 204, status: r.status, body: r.body };
  }
  size(graph?: string) { return this.sparql.count(graph); }
  shapesTriples() { return this.sparql.count(this.shapesGraph); }
  shapesGraphSparqlCount() { return this.sparql.count(this.shapesGraph); }

  async nodeShapeOf(propertyShape: string | null): Promise<string | null> {
    if (!propertyShape || propertyShape.startsWith("_:")) return null;
    const r = await this.sparql.select(`SELECT ?n WHERE { GRAPH <${this.shapesGraph}> { ?n <${SH}property> <${propertyShape}> } } LIMIT 1`).catch(() => []);
    return r[0]?.n?.value ?? propertyShape;
  }

  async write(req: WriteRequest): Promise<WriteOutcome> {
    const t: Timings = { begin: 0, add: 0, updates: 0, commit: 0, rollback: 0, total: 0 };
    const t0 = performance.now();
    const finish = () => { t.total = performance.now() - t0; return t; };
    let stage = "add";
    try {
      const ops: string[] = [];
      if (req.turtle && req.turtle.trim()) {
        const s = performance.now();
        const quads = parseTurtleInto(req.turtle, req.graph ?? graphs.manual);
        ops.push(`INSERT DATA {\n${dataBlock(quads)}\n}`);
        t.add = performance.now() - s;
      }
      for (const u of req.updates ?? []) ops.push(u);
      stage = "commit";
      const s = performance.now();
      const r = await http("POST", `${this.datasetUrl}/validated-update`, { body: ops.join(" ;\n"), contentType: "application/sparql-update", timeoutMs: 600_000 });
      t.commit = performance.now() - s;
      const validation = r.headers.get("x-ontara-validation") ?? undefined;
      if (r.status === 200 || r.status === 204) return { outcome: "committed", timings: finish(), note: "one request: whole-request time reported as commit", validation } as WriteOutcome;
      if (r.status === 422 && looksLikeShaclRejection(r.contentType, r.body)) {
        const report = parseReport(r.body);
        const results = await Promise.all(report.results.map(async (x) => ({ ...x, nodeShape: await this.nodeShapeOf(x.sourceShape) })));
        const nodeShapes = [...new Set(results.map((x) => x.nodeShape).filter((x): x is string => !!x))];
        const aborted = r.headers.get("x-ontara-transaction") === "aborted";
        return { outcome: "rejected", stage: "validate", shapes: report.shapes, nodeShapes, results, rolledBack: aborted, rollbackStatus: null, timings: finish(), note: "the module aborted the TDB2 write transaction (X-Ontara-Transaction header)", validation } as WriteOutcome;
      }
      return { outcome: "fault", stage, httpStatus: r.status, detail: r.body.slice(0, 2000), rolledBack: r.headers.get("x-ontara-transaction") === "aborted", rollbackStatus: null, timings: finish(), validation } as WriteOutcome;
    } catch (e: any) {
      return { outcome: "fault", stage, httpStatus: null, detail: String(e?.message ?? e), rolledBack: true, rollbackStatus: null, timings: finish() };
    }
  }

  async moduleStatus(id = this.repository): Promise<any> {
    const r = await http("GET", `${this.base}/${id}/validated-update`, { accept: "application/json" });
    if (r.status !== 200) throw new Error(`validated-update status ${id}: HTTP ${r.status}: ${r.body.slice(0, 300)}`);
    return JSON.parse(r.body);
  }
  async preflight() {
    const s = await this.moduleStatus();
    return { lines: [`Apache Jena Fuseki ${s.fusekiVersion} (Jena ${s.jenaVersion}), module ${s.module}`, `licence: not applicable (Apache-2.0, no licence key)`] };
  }
  async info(): Promise<StoreInfo> {
    const s = await this.moduleStatus();
    return { product: `Apache Jena Fuseki ${s.fusekiVersion}`, version: s.fusekiVersion, shaclEngine: `jena-shacl ${s.jenaVersion} (${s.engine})`, raw: s };
  }
  async licence() { return notApplicable("Apache Jena is Apache-2.0 open source; it has no licence key or edition"); }
  async listRepositories() { return PROVISIONED; }
  async createRepository(id: string, _title: string) {
    if (!PROVISIONED.includes(id)) return { ok: false, status: 0, body: `dataset ${id} is not provisioned; Fuseki datasets are fixed at server start`, note: "not offered" };
    const r = await new FusekiStore(this.base, id).update("CLEAR ALL");
    return { ok: r.status === 200 || r.status === 204, status: r.status, body: r.body, note: "pre-provisioned dataset: cleared, not created" };
  }
  async deleteRepository(id: string) {
    const r = await new FusekiStore(this.base, id).update("CLEAR ALL");
    return { ok: r.status === 200 || r.status === 204, status: r.status, note: "pre-provisioned dataset: cleared, not deleted" };
  }
  async readBack(id = this.repository): Promise<RepoReadBack> {
    const s = await this.moduleStatus(id);
    return {
      shacl: String(s.validating === true), validationEnabled: String(s.validating === true), inference: s.inference,
      shaclLocus: "store",
      line: `dataset=/${id} store=${s.store} unionDefaultGraph=${s.unionDefaultGraph} validatedUpdate=${s.validating} engine=${s.engine} shapesGraph=${s.shapesGraph} inference=${s.inference}`,
      raw: s,
    };
  }
}
