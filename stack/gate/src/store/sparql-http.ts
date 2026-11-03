// SPARQL 1.1 Protocol and Graph Store Protocol calls to a Fuseki dataset's
// standard endpoints (query, update, data). Standard protocol only. These
// endpoints do NOT validate: only the module's validated-update does, and
// only the gate's write path uses it (store/fuseki.ts). update() and
// putGraph() work only against the store's stack-network listener (3030);
// on the published listener (the host's 127.0.0.1:7210) they are refused.
import { http, HttpResult } from "./http";

export class SparqlHttp {
  constructor(readonly queryUrl: string, readonly updateUrl: string, readonly gspUrl: string) {}

  async select(query: string, timeoutMs?: number): Promise<any[]> {
    const r = await http("POST", this.queryUrl, { body: query, contentType: "application/sparql-query", accept: "application/sparql-results+json", timeoutMs });
    if (r.status !== 200) throw new Error(`SELECT failed: HTTP ${r.status}: ${r.body.slice(0, 500)}`);
    return JSON.parse(r.body).results.bindings;
  }
  async ask(query: string): Promise<boolean> {
    const r = await http("POST", this.queryUrl, { body: query, contentType: "application/sparql-query", accept: "application/sparql-results+json" });
    if (r.status !== 200) throw new Error(`ASK failed: HTTP ${r.status}: ${r.body.slice(0, 500)}`);
    return JSON.parse(r.body).boolean === true;
  }
  // Direct, unvalidated update: maintenance only (bootstrap, capability scratch).
  update(update: string, timeoutMs?: number): Promise<HttpResult> {
    return http("POST", this.updateUrl, { body: update, contentType: "application/sparql-update", timeoutMs });
  }
  putGraph(graph: string, data: string, contentType: string): Promise<HttpResult> {
    return http("PUT", `${this.gspUrl}?graph=${encodeURIComponent(graph)}`, { body: data, contentType, timeoutMs: 600_000 });
  }
  getGraph(graph: string, accept = "application/n-triples"): Promise<HttpResult> {
    return http("GET", `${this.gspUrl}?graph=${encodeURIComponent(graph)}`, { accept, timeoutMs: 30_000 });
  }
  async count(graph?: string): Promise<number> {
    // Explicit triples in named graphs. All stack content lives in named
    // graphs, and a union default graph would double-count a default-graph branch.
    const q = graph ? `SELECT (COUNT(*) AS ?n) WHERE { GRAPH <${graph}> { ?s ?p ?o } }` : `SELECT (COUNT(*) AS ?n) WHERE { GRAPH ?g { ?s ?p ?o } }`;
    const r = await this.select(q, 120_000);
    return Number(r[0]?.n?.value ?? 0);
  }
}
