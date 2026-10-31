// Thin GraphDB / RDF4J REST client. Node's built-in fetch only.
// Moved unchanged from src/graphdb.ts (OP-134 spike, B1). The RDF4J
// transaction protocol (/repositories/{id}/transactions) and the SPARQL and
// statements calls are standard RDF4J REST, shared by the GraphDB and RDF4J
// Server adapters; the "management (GraphDB REST)" section is GraphDB-only.
import { config, BULK_SETTING } from "../config";

export interface HttpResult {
  status: number;
  contentType: string | null;
  body: string;
  headers: Headers;
}

const DEFAULT_TIMEOUT_MS = 60_000;

export async function http(
  method: string,
  url: string,
  opts: { body?: string; contentType?: string; accept?: string; timeoutMs?: number } = {},
): Promise<HttpResult> {
  const headers: Record<string, string> = {};
  if (opts.contentType) headers["Content-Type"] = opts.contentType;
  if (opts.accept) headers["Accept"] = opts.accept;
  const res = await fetch(url, {
    method,
    headers,
    body: opts.body,
    signal: AbortSignal.timeout(opts.timeoutMs ?? DEFAULT_TIMEOUT_MS),
  });
  const body = await res.text();
  return { status: res.status, contentType: res.headers.get("content-type"), body, headers: res.headers };
}

export const ctx = (iri: string) => encodeURIComponent(`<${iri}>`);

export class GraphDB {
  constructor(readonly base = config.graphdbUrl, readonly repo = config.repository) {}

  get repoUrl() {
    return `${this.base}/repositories/${this.repo}`;
  }

  withRepo(repo: string) {
    return new GraphDB(this.base, repo);
  }

  // ---- SPARQL
  async select(query: string, timeoutMs?: number): Promise<any[]> {
    const r = await http("POST", this.repoUrl, {
      body: query,
      contentType: "application/sparql-query",
      accept: "application/sparql-results+json",
      timeoutMs,
    });
    if (r.status !== 200) throw new Error(`SELECT failed: HTTP ${r.status}: ${r.body.slice(0, 500)}`);
    return JSON.parse(r.body).results.bindings;
  }

  async ask(query: string): Promise<boolean> {
    const r = await http("POST", this.repoUrl, {
      body: query,
      contentType: "application/sparql-query",
      accept: "application/sparql-results+json",
    });
    if (r.status !== 200) throw new Error(`ASK failed: HTTP ${r.status}: ${r.body.slice(0, 500)}`);
    return JSON.parse(r.body).boolean === true;
  }

  // Direct (non-transactional) update. Used only by bootstrap/maintenance.
  async update(update: string): Promise<HttpResult> {
    return http("POST", `${this.repoUrl}/statements`, { body: update, contentType: "application/sparql-update" });
  }

  // Replace a named graph's contents with a file's triples.
  async replaceGraph(graph: string, data: string, contentType: string): Promise<HttpResult> {
    return http("PUT", `${this.repoUrl}/statements?context=${ctx(graph)}`, {
      body: data,
      contentType,
      timeoutMs: 600_000,
    });
  }

  // RDF4J statements API (getStatements). Unlike SPARQL, this can read the
  // SHACL shapes graph: GraphDB hides rdf4j:SHACLShapeGraph from SPARQL GRAPH
  // queries and from /size (found S517).
  async statements(q: { subj?: string; pred?: string; obj?: string; graph?: string }): Promise<string[]> {
    const p = new URLSearchParams();
    if (q.subj) p.set("subj", `<${q.subj}>`);
    if (q.pred) p.set("pred", `<${q.pred}>`);
    if (q.obj) p.set("obj", `<${q.obj}>`);
    if (q.graph) p.set("context", `<${q.graph}>`);
    const r = await http("GET", `${this.repoUrl}/statements?${p}`, { accept: "application/n-triples", timeoutMs: 10_000 });
    if (r.status !== 200) throw new Error(`statements: HTTP ${r.status}: ${r.body.slice(0, 300)}`);
    return r.body.split(/\r?\n/).filter((l) => l.trim() && !l.startsWith("#"));
  }

  async size(graph?: string): Promise<number> {
    const q = graph ? `?context=${ctx(graph)}` : "";
    const r = await http("GET", `${this.repoUrl}/size${q}`);
    if (r.status !== 200) throw new Error(`size failed: HTTP ${r.status}: ${r.body.slice(0, 300)}`);
    return Number(r.body.trim());
  }

  // ---- RDF4J transactions
  async begin(bulk = false): Promise<{ location: string; result: HttpResult }> {
    const q = bulk ? `?${BULK_SETTING}=Bulk` : "";
    const result = await http("POST", `${this.repoUrl}/transactions${q}`);
    const location = result.headers.get("location");
    if (result.status !== 201 || !location) {
      throw Object.assign(new Error(`begin failed: HTTP ${result.status}`), { result });
    }
    return { location, result };
  }

  txnAdd(location: string, turtle: string, graph: string) {
    return http("PUT", `${location}?action=ADD&context=${ctx(graph)}`, { body: turtle, contentType: "text/turtle" });
  }

  txnUpdate(location: string, update: string) {
    return http("PUT", `${location}?action=UPDATE`, { body: update, contentType: "application/sparql-update" });
  }

  txnCommit(location: string) {
    return http("PUT", `${location}?action=COMMIT`);
  }

  txnRollback(location: string) {
    return http("DELETE", location, { timeoutMs: 30_000 });
  }

  // ---- management (GraphDB REST)
  async listRepositories(): Promise<string[]> {
    const r = await http("GET", `${this.base}/rest/repositories`, { accept: "application/json" });
    if (r.status !== 200) throw new Error(`list repositories: HTTP ${r.status}: ${r.body.slice(0, 300)}`);
    return JSON.parse(r.body).map((x: any) => x.id);
  }

  async defaultConfig(): Promise<any> {
    const r = await http("GET", `${this.base}/rest/repositories/default-config/graphdb`, { accept: "application/json" });
    if (r.status !== 200) throw new Error(`default-config: HTTP ${r.status}: ${r.body.slice(0, 300)}`);
    return JSON.parse(r.body);
  }

  async createRepository(cfg: any): Promise<HttpResult> {
    return http("POST", `${this.base}/rest/repositories`, {
      body: JSON.stringify(cfg),
      contentType: "application/json",
    });
  }

  async deleteRepository(id: string): Promise<HttpResult> {
    return http("DELETE", `${this.base}/rest/repositories/${id}`);
  }

  async repositoryConfig(id = this.repo): Promise<any> {
    const r = await http("GET", `${this.base}/rest/repositories/${id}`, { accept: "application/json" });
    if (r.status !== 200) throw new Error(`repository config ${id}: HTTP ${r.status}: ${r.body.slice(0, 300)}`);
    return JSON.parse(r.body);
  }

  async license(): Promise<any> {
    const r = await http("GET", `${this.base}/rest/graphdb-settings/license`, { accept: "application/json" });
    if (r.status !== 200) throw new Error(`licence: HTTP ${r.status}: ${r.body.slice(0, 300)}`);
    return JSON.parse(r.body);
  }

  async version(): Promise<any> {
    const r = await http("GET", `${this.base}/rest/info/version`, { accept: "application/json" });
    return JSON.parse(r.body);
  }
}

// Builds a SHACL-enabled repository config from GraphDB's own JSON default
// config (never Turtle: a Turtle config silently gave isShacl false at S515),
// with SHACL on, the context index on and the empty ruleset.
export async function shaclRepositoryConfig(db: GraphDB, id: string, title: string): Promise<any> {
  const cfg = await db.defaultConfig();
  cfg.id = id;
  cfg.title = title;
  cfg.params.id.value = id;
  cfg.params.title.value = title;
  cfg.params.isShacl.value = "true";
  // Named graphs carry the stack's separation of KG and runtime state (one
  // repository; see README "Repository decision"), so index contexts.
  cfg.params.enableContextIndex.value = "true";
  // No store-side inference on runtime content (OP-134 requirements paper R4;
  // ADR-013): every triple is a declared writer's and carries its mode and
  // method. GraphDB's default ruleset (rdfsplus-optimized) materialises
  // inferences at ingest, so use the empty ruleset. A ruleset is fixed when a
  // repository is created; changing it means recreating the repository.
  cfg.params.ruleset.value = "empty";
  return cfg;
}

export function param(cfg: any, name: string): string | undefined {
  return cfg?.params?.[name]?.value;
}
