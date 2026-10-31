// Oxigraph 0.5.13 adapter, with SHACL validated in the gate (configuration 4).
//
// Oxigraph has no SHACL and no transaction that spans HTTP requests. One
// SPARQL Update request is applied atomically (all-or-nothing; tested in the
// spike, and Oxigraph's Store::update runs in one storage transaction). So the
// gate does this for each write, holding a lock:
//
//   1. lock      an in-process mutex per store: one write at a time through this
//                gate process, so no write validates against a graph another
//                write is about to change. (A second gate process would not
//                share it: there is no check-and-commit.)
//   2. read set  quads the write may read: the write's subjects and the IRIs its
//                updates bind (VALUES), expanded HOPS times along outgoing
//                edges, and along incoming edges for nodes with at most
//                FANIN_CAP incoming non-type edges. A heuristic, stated here and
//                in the spike report: a rule or shape that reaches further
//                computes or validates on partial data.
//   3. effect    the read set goes into an in-memory staging Oxigraph started
//                with --union-default-graph (the same semantics as the store);
//                the write's triples and updates run there, in order; the diff
//                of staging before and after is the write's effect.
//   4. validate  shacl-engine (SHACL Core + SHACL-SPARQL via Comunica) over the
//                staging result, focus nodes = every IRI in the effect. Graphs
//                are merged for validation, so shapes apply in every graph.
//   5. commit    only if it conforms: one update request, DELETE DATA + INSERT
//                DATA of the effect. Nothing reaches the store on a rejection.
//
// Graph-management updates (CLEAR, DROP, ...) cannot be replayed on a read
// set; they are sent straight to the store, unvalidated, and the outcome says so.
import { http, HttpResult } from "./graphdb-client";
import { SparqlHttp } from "./sparql-http";
import { ox, parseTurtleInto, parseNQuads, toNQuads, dataBlock, quadKey, shaclEngine } from "./rdfjs";
import { Store, WriteRequest, WriteOutcome, RepoReadBack, StoreInfo, GraphLoad, Timings, ONTARA_SHAPES_GRAPH, notApplicable, SH } from "./types";
import { parseReport } from "../report";
import { config, graphs } from "../config";

const HOPS = Number(process.env.OXIGRAPH_READSET_HOPS ?? 3);
const FANIN_CAP = Number(process.env.OXIGRAPH_READSET_FANIN_CAP ?? 64);
const RDF_TYPE = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type";
const MGMT = /^\s*(?:(?:PREFIX|BASE)\s+[^\n]*\n\s*)*(CLEAR|DROP|CREATE|LOAD|COPY|MOVE|ADD)\b/i;

class Mutex {
  private tail: Promise<void> = Promise.resolve();
  lock(): Promise<() => void> {
    let release!: () => void;
    const next = new Promise<void>((r) => (release = r));
    const prev = this.tail;
    this.tail = prev.then(() => next);
    return prev.then(() => release);
  }
}
const locks = new Map<string, Mutex>();
const lockFor = (url: string) => { if (!locks.has(url)) locks.set(url, new Mutex()); return locks.get(url)!; };

// IRIs a SPARQL Update binds: inside VALUES blocks only (not PREFIX, GRAPH or USING IRIs).
function valuesIris(update: string): string[] {
  const out: string[] = [];
  const re = /VALUES[^{]*\{([\s\S]*?)\}/gi;
  for (let m = re.exec(update); m; m = re.exec(update)) for (const i of m[1].matchAll(/<([^>\s]+)>/g)) out.push(i[1]);
  return out;
}

export class OxigraphStore implements Store {
  readonly kind = "oxigraph" as const;
  readonly label = "oxigraph";
  readonly shapesGraph = ONTARA_SHAPES_GRAPH;
  readonly sparql: SparqlHttp;
  readonly staging: SparqlHttp;
  private shapesCache: { nt: string; validator: any; shapes: any[] } | null = null;

  constructor(readonly base: string, readonly repository: string) {
    const url = repository === "cafe-capability-scratch" ? config.oxigraphScratchUrl : base;
    this.base = url;
    this.sparql = new SparqlHttp(`${url}/query`, `${url}/update`, `${url}/store`);
    const st = config.oxigraphStagingUrl;
    this.staging = new SparqlHttp(`${st}/query`, `${st}/update`, `${st}/store`);
  }
  withRepo(id: string) { return new OxigraphStore(config.storeUrl, id); }

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

  // Shapes are held in the store (graph urn:ontara:stack:shapes) and read on
  // every write; the compiled validator is reused while they are unchanged.
  private async validator() {
    const r = await this.sparql.getGraph(this.shapesGraph);
    const nt = r.status === 200 ? r.body : "";
    if (this.shapesCache && this.shapesCache.nt === nt) return this.shapesCache;
    const { Validator, sparqlValidations, rdf } = await shaclEngine();
    const shapes = parseNQuads(nt);
    const ds = rdf.dataset(); for (const q of shapes) ds.add(rdf.quad(q.subject, q.predicate, q.object));
    const validator = new Validator(ds, { factory: rdf, validations: sparqlValidations });
    this.shapesCache = { nt, validator, shapes };
    return this.shapesCache;
  }

  private async readSet(seeds: string[]): Promise<{ quads: any[]; skippedHubs: string[] }> {
    const quads = new Map<string, any>();
    const seen = new Set<string>(seeds);
    const skippedHubs: string[] = [];
    let frontier = [...new Set(seeds)];
    const values = (xs: string[]) => xs.map((x) => `<${x}>`).join(" ");
    const add = (b: any) => {
      const term = (t: any) => t.type === "uri" ? ox.namedNode(t.value) : t.type === "bnode" ? ox.blankNode(t.value) : t["xml:lang"] ? ox.literal(t.value, t["xml:lang"]) : ox.literal(t.value, ox.namedNode(t.datatype ?? "http://www.w3.org/2001/XMLSchema#string"));
      const q = ox.quad(term(b.s), term(b.p), term(b.o), ox.namedNode(b.g.value));
      quads.set(quadKey(q), q);
      return q;
    };
    for (let hop = 0; hop < HOPS && frontier.length; hop++) {
      const next: string[] = [];
      const out = await this.sparql.select(`SELECT ?s ?p ?o ?g WHERE { VALUES ?s { ${values(frontier)} } GRAPH ?g { ?s ?p ?o } }`, 60_000);
      for (const b of out) { add(b); if (b.o.type === "uri" && b.p.value !== RDF_TYPE && !seen.has(b.o.value)) { seen.add(b.o.value); next.push(b.o.value); } }
      const fan = await this.sparql.select(`SELECT ?o (COUNT(*) AS ?n) WHERE { VALUES ?o { ${values(frontier)} } GRAPH ?g { ?s ?p ?o } FILTER (?p != <${RDF_TYPE}>) } GROUP BY ?o`, 60_000);
      const small = fan.filter((b) => Number(b.n.value) <= FANIN_CAP).map((b) => b.o.value);
      skippedHubs.push(...fan.filter((b) => Number(b.n.value) > FANIN_CAP).map((b) => b.o.value));
      if (small.length) {
        const inc = await this.sparql.select(`SELECT ?s ?p ?o ?g WHERE { VALUES ?o { ${values(small)} } GRAPH ?g { ?s ?p ?o } FILTER (?p != <${RDF_TYPE}>) }`, 60_000);
        for (const b of inc) { add(b); if (b.s.type === "uri" && !seen.has(b.s.value)) { seen.add(b.s.value); next.push(b.s.value); } }
      }
      frontier = next;
    }
    return { quads: [...quads.values()], skippedHubs: [...new Set(skippedHubs)] };
  }

  private async nodeShapeOf(shapes: any[], propertyShape: string | null): Promise<string | null> {
    if (!propertyShape || propertyShape.startsWith("_:")) return null;
    const q = shapes.find((x) => x.predicate.value === `${SH}property` && x.object.value === propertyShape);
    return q ? q.subject.value : propertyShape;
  }

  async write(req: WriteRequest): Promise<WriteOutcome> {
    const t: Timings = { begin: 0, add: 0, updates: 0, commit: 0, rollback: 0, total: 0, lockWait: 0, readSet: 0, effect: 0, validate: 0 };
    const t0 = performance.now();
    const finish = () => { t.total = performance.now() - t0; return t; };
    const fault = (stage: string, httpStatus: number | null, detail: string): WriteOutcome =>
      ({ outcome: "fault", stage, httpStatus, detail: detail.slice(0, 2000), rolledBack: true, rollbackStatus: null, timings: finish() });
    const updates = req.updates ?? [];
    const mgmt = updates.filter((u) => MGMT.test(u));

    const release = await lockFor(this.base).lock();
    t.lockWait = performance.now() - t0;
    try {
      // Graph-management only: straight to the store, unvalidated (said so).
      if (mgmt.length) {
        if (mgmt.length !== updates.length || (req.turtle && req.turtle.trim())) return fault("plan", null, "gate-side validation cannot combine graph-management operations (CLEAR, DROP, ...) with data in one write");
        const s = performance.now();
        const r = await this.sparql.update(updates.join(" ;\n"));
        t.commit = performance.now() - s;
        if (r.status >= 300) return fault("commit", r.status, r.body);
        return { outcome: "committed", timings: finish(), note: "graph-management operation sent to the store unvalidated: the gate cannot replay it on a read set" };
      }

      // 1. The write's own triples.
      let s = performance.now();
      const graph = req.graph ?? graphs.manual;
      let own: any[] = [];
      try { if (req.turtle && req.turtle.trim()) own = parseTurtleInto(req.turtle, graph); } catch (e: any) { return fault("add", null, String(e?.message ?? e)); }
      t.add = performance.now() - s;

      // 2. Read set.
      s = performance.now();
      const seeds = [...new Set([...own.filter((q) => q.subject.termType === "NamedNode").map((q) => q.subject.value), ...updates.flatMap(valuesIris)])];
      const rs = await this.readSet(seeds);
      t.readSet = performance.now() - s;

      // 3. Effect, computed in staging.
      s = performance.now();
      let r = await this.staging.update("CLEAR ALL");
      if (r.status >= 300) return fault("effect", r.status, `staging clear: ${r.body}`);
      const before = new Map(rs.quads.map((q) => [quadKey(q), q]));
      if (rs.quads.length) {
        r = await http("POST", `${config.oxigraphStagingUrl}/store`, { body: toNQuads(rs.quads), contentType: "application/n-quads" });
        if (r.status >= 300) return fault("effect", r.status, `staging load: ${r.body}`);
      }
      if (own.length) {
        r = await this.staging.update(`INSERT DATA {\n${dataBlock(own)}\n}`);
        if (r.status >= 300) return fault("add", r.status, r.body);
      }
      const su = performance.now();
      for (const u of updates) {
        r = await this.staging.update(u);
        if (r.status >= 300) { t.updates = performance.now() - su; return fault("update", r.status, r.body); }
      }
      t.updates = performance.now() - su;
      const dump = await http("GET", `${config.oxigraphStagingUrl}/store`, { accept: "application/n-quads", timeoutMs: 60_000 });
      if (dump.status !== 200) return fault("effect", dump.status, `staging dump: ${dump.body}`);
      const afterQuads = parseNQuads(dump.body);
      const after = new Map(afterQuads.map((q) => [quadKey(q), q]));
      const added = [...after].filter(([k]) => !before.has(k)).map(([, q]) => q);
      const removed = [...before].filter(([k]) => !after.has(k)).map(([, q]) => q);
      t.effect = performance.now() - s;

      // 4. Validate the effect's focus nodes against the staging result.
      s = performance.now();
      const { validator, shapes } = await this.validator();
      const { rdf } = await shaclEngine();
      const data = rdf.dataset();
      for (const q of afterQuads) data.add(rdf.quad(q.subject, q.predicate, q.object));
      const focus = new Map<string, any>();
      for (const q of [...added, ...removed]) for (const term of [q.subject, q.object]) if (term.termType === "NamedNode") focus.set(`N:${term.value}`, rdf.namedNode(term.value)); else if (term.termType === "BlankNode") focus.set(`B:${term.value}`, rdf.blankNode(term.value));
      const report = await validator.validate({ dataset: data, terms: [...focus.values()] });
      t.validate = performance.now() - s;
      if (!report.conforms) {
        const parsed = parseReport(toNQuads(report.dataset));
        const results = await Promise.all(parsed.results.map(async (x) => ({ ...x, nodeShape: await this.nodeShapeOf(shapes, x.sourceShape) })));
        const nodeShapes = [...new Set(results.map((x) => x.nodeShape).filter((x): x is string => !!x))];
        return { outcome: "rejected", stage: "validate", shapes: parsed.shapes, nodeShapes, results, rolledBack: true, rollbackStatus: null, timings: finish(), note: `nothing was sent to the store; read set ${rs.quads.length} quads, effect +${added.length}/-${removed.length}, ${focus.size} focus nodes` };
      }

      // 5. Commit the effect as one update request.
      s = performance.now();
      const ops: string[] = [];
      if (removed.length) ops.push(`DELETE DATA {\n${dataBlock(removed)}\n}`);
      if (added.length) ops.push(`INSERT DATA {\n${dataBlock(added)}\n}`);
      if (ops.length) {
        r = await this.sparql.update(ops.join(" ;\n"), 120_000);
        t.commit = performance.now() - s;
        if (r.status >= 300) return fault("commit", r.status, r.body);
      }
      return { outcome: "committed", timings: finish(), note: `read set ${rs.quads.length} quads (hubs skipped: ${rs.skippedHubs.length}), effect +${added.length}/-${removed.length}, ${focus.size} focus nodes` };
    } catch (e: any) {
      return fault("gate", null, String(e?.stack ?? e));
    } finally {
      release();
    }
  }

  async preflight() {
    return { lines: [`Oxigraph ${config.storeVersion} at ${this.base}; SHACL validated in the gate (shacl-engine), staging ${config.oxigraphStagingUrl}`, `licence: not applicable (MIT OR Apache-2.0, no licence key)`] };
  }
  async info(): Promise<StoreInfo> {
    return { product: `Oxigraph ${config.storeVersion}`, version: config.storeVersion, shaclEngine: "shacl-engine 1.1.3 in the gate (SHACL-SPARQL via Comunica)" };
  }
  async licence() { return notApplicable("Oxigraph is MIT OR Apache-2.0 open source; it has no licence key or edition"); }
  async listRepositories() { return ["cafe-runtime", "cafe-capability-scratch"]; }
  async createRepository(id: string, _title: string) {
    const r = await new OxigraphStore(config.storeUrl, id).update("CLEAR ALL");
    return { ok: r.status === 204 || r.status === 200, status: r.status, body: r.body, note: "one Oxigraph server per dataset: the scratch dataset is a second in-memory server, cleared not created" };
  }
  async deleteRepository(id: string) {
    const r = await new OxigraphStore(config.storeUrl, id).update("CLEAR ALL");
    return { ok: r.status === 204 || r.status === 200, status: r.status, note: "cleared, not deleted" };
  }
  async readBack(_id?: string): Promise<RepoReadBack> {
    const shapes = await this.shapesTriples().catch(() => -1);
    return {
      shacl: "true", validationEnabled: "true", inference: "none", shaclLocus: "gate",
      line: `store=Oxigraph ${config.storeVersion} (no SHACL, no inference) shacl=in the gate (shacl-engine) shapesGraph=${this.shapesGraph} (${shapes} triples) staging=${config.oxigraphStagingUrl} readSetHops=${HOPS} fanInCap=${FANIN_CAP}`,
    };
  }
}
