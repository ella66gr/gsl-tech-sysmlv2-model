// RDF4J Server 6.1.0 adapter. The data path is the GraphDB client's RDF4J
// REST half (SPARQL, statements, /size, transactions), unchanged: RDF4J
// Server speaks the same protocol. Only the administration differs.
//
// Repository configuration source: the template RDF4J ships for a native
// store with SHACL, `native-shacl.ttl`, read from
// rdf4j-repository-api-6.1.0.jar!/org/eclipse/rdf4j/repository/config/native-shacl.ttl
// in the eclipse/rdf4j-workbench:6.1.0-tomcat image (source:
// github.com/eclipse-rdf4j/rdf4j, core/repository/api/src/main/resources/
// org/eclipse/rdf4j/repository/config/native-shacl.ttl). Filled with the
// template's own defaults, except:
//   - triple indexes "spoc,posc,cspo": the context index, to match GraphDB's
//     enableContextIndex=true (the stack separates content by named graph);
//   - the LMDB variant puts rdf4j:LmdbStore (with the lmdb.ttl template's
//     defaults) as the ShaclSail delegate. RDF4J ships no lmdb-shacl template.
// Neither stack has an inferencer sail, so there is no store-side inference (R4).
import { GraphDB, HttpResult, http } from "./graphdb-client";
import { rdf4jTransactionWrite } from "./rdf4j-txn-write";
import { Store, WriteRequest, WriteOutcome, RepoReadBack, StoreInfo, GraphLoad, RDF4J_SHAPES_GRAPH, notApplicable } from "./types";
import { config, graphs } from "../config";

// RDF4J Server rejects a commit with HTTP 409 and the SHACL report as
// application/shacl-validation-report+rdf+json, whatever Accept asks for
// (found in the spike; GraphDB answers 500 with N-Quads). The shared report
// parser reads N-Triples, so this client translates RDF/JSON on commit. The
// moved write path itself is unchanged.
function rdfJsonToNTriples(json: string): string {
  const esc = (v: string) => v.replace(/\\/g, "\\\\").replace(/"/g, '\\"').replace(/\n/g, "\\n").replace(/\r/g, "\\r");
  const node = (v: string) => (v.startsWith("_:") ? v : `<${v}>`);
  const obj = (o: any) => o.type === "uri" ? `<${o.value}>` : o.type === "bnode" ? o.value : `"${esc(o.value)}"${o.lang ? `@${o.lang}` : o.datatype ? `^^<${o.datatype}>` : ""}`;
  const lines: string[] = [];
  const d = JSON.parse(json);
  for (const [s, preds] of Object.entries<any>(d)) for (const [p, objs] of Object.entries<any>(preds)) for (const o of objs) lines.push(`${node(s)} <${p}> ${obj(o)} .`);
  return lines.join("\n") + "\n";
}
class Rdf4jServerClient extends GraphDB {
  withRepo(repo: string) { return new Rdf4jServerClient(this.base, repo); }
  async txnCommit(location: string): Promise<HttpResult> {
    const r = await super.txnCommit(location);
    if (r.status >= 300 && (r.contentType ?? "").includes("rdf+json")) {
      try { return { ...r, body: rdfJsonToNTriples(r.body), contentType: "application/shacl-validation-report+n-triples (translated from RDF/JSON)" }; } catch { return r; }
    }
    return r;
  }
}

const INFERENCER_TYPES = ["SchemaCachingRDFSInferencer", "ForwardChainingRDFSInferencer", "DirectTypeHierarchyInferencer", "CustomGraphQueryInferencer", "RDFSInferencer"];

export function rdf4jShaclConfig(id: string, title: string, delegate: "native" | "lmdb"): string {
  const native = `
        config:sail.impl [
            config:sail.type "rdf4j:ShaclSail" ;
            config:delegate [
                config:sail.type "openrdf:NativeStore" ;
                config:sail.iterationCacheSyncThreshold "10000";
                config:sail.slowQueryLogThresholdSeconds "0" ;
                config:sail.slowQueryLogFirstResultThresholdSeconds "0" ;
                config:native.tripleIndexes "spoc,posc,cspo";
                config:sail.defaultQueryEvaluationMode "STRICT"
            ]
        ]`;
  const lmdb = `
        config:sail.impl [
            config:sail.type "rdf4j:ShaclSail" ;
            config:delegate [
                config:sail.type "rdf4j:LmdbStore" ;
                config:sail.iterationCacheSyncThreshold 2097152 ;
                lmdb:tripleIndexes "spoc,posc,cspo" ;
                lmdb:tripleDBSize 1073741824 ;
                lmdb:valueDBSize 1073741824 ;
                lmdb:autoGrow true ;
                config:sail.defaultQueryEvaluationMode "STANDARD"
            ]
        ]`;
  return `@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>.
@prefix config: <tag:rdf4j.org,2023:config/>.
@prefix lmdb: <http://rdf4j.org/config/sail/lmdb#>.
[] a config:Repository ;
    config:rep.id "${id}" ;
    rdfs:label "${title.replace(/"/g, "'")}" ;
    config:rep.impl [
        config:rep.type "openrdf:SailRepository" ;${delegate === "lmdb" ? lmdb : native}
    ].
`;
}

export class Rdf4jStore implements Store {
  readonly kind = "rdf4j" as const;
  readonly label = "rdf4j";
  readonly shapesGraph = RDF4J_SHAPES_GRAPH;
  readonly client: GraphDB;
  constructor(client: GraphDB, readonly delegate: "native" | "lmdb") { this.client = client instanceof Rdf4jServerClient ? client : new Rdf4jServerClient(client.base, client.repo); }
  get repository() { return this.client.repo; }
  withRepo(id: string) { return new Rdf4jStore(this.client.withRepo(id), this.delegate); }

  select(q: string, timeoutMs?: number) { return this.client.select(q, timeoutMs); }
  ask(q: string) { return this.client.ask(q); }
  update(u: string): Promise<HttpResult> { return this.client.update(u); }
  async replaceGraph(g: string, data: string, ct: string): Promise<GraphLoad> {
    const r = await this.client.replaceGraph(g, data, ct);
    return { ok: r.status === 204, status: r.status, body: r.body };
  }
  size(graph?: string) { return this.client.size(graph); }
  async shapesTriples() { return (await this.client.statements({ graph: this.shapesGraph })).length; }
  async shapesGraphSparqlCount() {
    const r = await this.client.select(`SELECT (COUNT(*) AS ?n) WHERE { GRAPH <${this.shapesGraph}> { ?s ?p ?o } }`);
    return Number(r[0]?.n?.value ?? 0);
  }
  write(req: WriteRequest): Promise<WriteOutcome> { return rdf4jTransactionWrite(req, this.client, this.shapesGraph, graphs.manual); }

  async preflight() {
    const i = await this.info();
    return { lines: [`${i.product}; SHACL engine ${i.shaclEngine}; delegate ${this.delegate}`, `licence: not applicable (BSD-3-Clause, no licence key)`] };
  }
  async info(): Promise<StoreInfo> {
    const p = await http("GET", `${this.client.base}/protocol`);
    return { product: `RDF4J Server ${config.storeVersion || "(version not reported by the server)"}`, version: config.storeVersion, shaclEngine: `RDF4J ShaclSail ${config.storeVersion}`, raw: { protocol: p.body.trim() } };
  }
  async licence() { return notApplicable("Eclipse RDF4J is BSD-3-Clause open source; it has no licence key or edition"); }
  async listRepositories() {
    const r = await http("GET", `${this.client.base}/repositories`, { accept: "application/sparql-results+json" });
    if (r.status !== 200) throw new Error(`list repositories: HTTP ${r.status}: ${r.body.slice(0, 300)}`);
    return JSON.parse(r.body).results.bindings.map((b: any) => b.id.value);
  }
  async createRepository(id: string, title: string) {
    const r = await http("PUT", `${this.client.base}/repositories/${id}`, { body: rdf4jShaclConfig(id, title, this.delegate), contentType: "text/turtle" });
    return { ok: r.status === 204 || r.status === 200 || r.status === 201, status: r.status, body: r.body, note: `from RDF4J's native-shacl.ttl template (delegate ${this.delegate})` };
  }
  async deleteRepository(id: string) {
    const r = await http("DELETE", `${this.client.base}/repositories/${id}`);
    return { ok: r.status === 204 || r.status === 200, status: r.status };
  }
  async readBack(id = this.repository): Promise<RepoReadBack> {
    const r = await http("GET", `${this.client.base}/repositories/${id}/config`, { accept: "text/turtle" });
    if (r.status !== 200) throw new Error(`repository config ${id}: HTTP ${r.status}: ${r.body.slice(0, 300)}`);
    const ttl = r.body;
    const shacl = /ShaclSail/.test(ttl);
    const delegate = (ttl.match(/"((?:openrdf|rdf4j):(?:NativeStore|LmdbStore|MemoryStore))"/) ?? [])[1] ?? "unknown";
    const inferencer = INFERENCER_TYPES.find((t) => ttl.includes(t));
    const disabled = /validationEnabled>?\s*(?:"false"|false)/.test(ttl);
    return {
      shacl: String(shacl), validationEnabled: String(!disabled), inference: inferencer ? inferencer : "none",
      shaclLocus: "store",
      line: `sail=rdf4j:ShaclSail(${shacl}) delegate=${delegate} inferencer=${inferencer ?? "none"} validationEnabled=${!disabled} shapesGraph=${this.shapesGraph} (read back from GET /repositories/${id}/config)`,
      raw: ttl,
    };
  }
}
