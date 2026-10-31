// GraphDB adapter (the control). The existing S0.1 code, moved and not
// rewritten: the client is src/store/graphdb-client.ts (was src/graphdb.ts),
// the write is src/store/rdf4j-txn-write.ts (was src/gate.ts), and the
// preflight is the licence and version check that was in cli/bootstrap.ts.
import { GraphDB, HttpResult, shaclRepositoryConfig, param } from "./graphdb-client";
import { rdf4jTransactionWrite } from "./rdf4j-txn-write";
import { Store, WriteRequest, WriteOutcome, RepoReadBack, StoreInfo, GraphLoad, RDF4J_SHAPES_GRAPH } from "./types";
import { graphs } from "../config";

export class GraphDBStore implements Store {
  readonly kind = "graphdb" as const;
  readonly label = "graphdb";
  readonly shapesGraph = RDF4J_SHAPES_GRAPH;
  constructor(readonly client: GraphDB) {}
  get repository() { return this.client.repo; }
  withRepo(id: string) { return new GraphDBStore(this.client.withRepo(id)); }

  select(q: string, timeoutMs?: number) { return this.client.select(q, timeoutMs); }
  ask(q: string) { return this.client.ask(q); }
  update(u: string): Promise<HttpResult> { return this.client.update(u); }
  async replaceGraph(g: string, data: string, ct: string): Promise<GraphLoad> {
    const r = await this.client.replaceGraph(g, data, ct);
    return { ok: r.status === 204, status: r.status, body: r.body };
  }
  size(graph?: string) { return this.client.size(graph); }
  // The shapes graph is invisible to SPARQL in GraphDB; read it through getStatements (S517).
  async shapesTriples() { return (await this.client.statements({ graph: this.shapesGraph })).length; }
  async shapesGraphSparqlCount() {
    const r = await this.client.select(`SELECT (COUNT(*) AS ?n) WHERE { GRAPH <${this.shapesGraph}> { ?s ?p ?o } }`);
    return Number(r[0]?.n?.value ?? 0);
  }
  write(req: WriteRequest): Promise<WriteOutcome> { return rdf4jTransactionWrite(req, this.client, this.shapesGraph, graphs.manual); }

  async preflight() {
    const lines: string[] = [];
    const v = await this.client.version();
    const lic = await this.client.license();
    lines.push(`GraphDB ${v.productVersion} (${v.productType}), RDF4J ${v.sesame}`);
    lines.push(`licence: valid=${lic.valid} product=${lic.productType} version=${lic.version} licensee="${lic.licensee}" maxCpuCores=${lic.maxCpuCores} expiry=${lic.expiryDate}`);
    if (lic.valid !== true || lic.present !== true) return { lines, error: `GraphDB licence not valid: ${JSON.stringify({ valid: lic.valid, present: lic.present, message: lic.message })}` };
    if (v.productVersion !== "11.3.1") return { lines, error: `expected GraphDB 11.3.1, found ${v.productVersion}` };
    if (lic.version !== "11.3") lines.push(`WARNING: licence is for ${lic.version}, the stack pins 11.3.1`);
    return { lines };
  }
  async info(): Promise<StoreInfo> {
    const v = await this.client.version();
    return { product: `GraphDB ${v.productVersion} (${v.productType})`, version: v.productVersion, shaclEngine: `RDF4J ShaclSail ${v.sesame}`, raw: v };
  }
  licence() { return this.client.license(); }
  listRepositories() { return this.client.listRepositories(); }
  async createRepository(id: string, title: string) {
    const r = await this.client.createRepository(await shaclRepositoryConfig(this.client, id, title));
    return { ok: r.status === 201, status: r.status, body: r.body, note: "from GraphDB's JSON default config" };
  }
  async deleteRepository(id: string) {
    const r = await this.client.deleteRepository(id);
    return { ok: r.status === 200 || r.status === 204, status: r.status };
  }
  async readBack(id = this.repository): Promise<RepoReadBack> {
    const cfg = await this.client.repositoryConfig(id);
    return {
      shacl: String(param(cfg, "isShacl")), validationEnabled: String(param(cfg, "validationEnabled")), inference: String(param(cfg, "ruleset")),
      shaclLocus: "store",
      line: `isShacl=${param(cfg, "isShacl")} validationEnabled=${param(cfg, "validationEnabled")} ruleset=${param(cfg, "ruleset")} enableContextIndex=${param(cfg, "enableContextIndex")} shapesGraph=${param(cfg, "shapesGraph")} transactionalValidationLimit=${param(cfg, "transactionalValidationLimit")}`,
      raw: cfg,
    };
  }
}
