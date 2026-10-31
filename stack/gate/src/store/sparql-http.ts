// SPARQL 1.1 Protocol and Graph Store Protocol calls, for the adapters whose
// stores are not RDF4J-based (Fuseki, Oxigraph). Standard protocol only.
import { http, HttpResult } from "./graphdb-client";

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
  // N-Quads of a CONSTRUCT-free read: SELECT ?s ?p ?o ?g rows, returned as RDF/JS-ready bindings.
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
