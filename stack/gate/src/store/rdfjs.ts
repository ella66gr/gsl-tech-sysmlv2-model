// RDF parsing and serialisation for the non-RDF4J adapters: Oxigraph's
// JavaScript build (WASM) parses Turtle and writes N-Triples / N-Quads.
// shacl-engine and rdf-ext are ES modules, loaded by dynamic import from this
// CommonJS build.
// eslint-disable-next-line @typescript-eslint/no-var-requires
const ox = require("oxigraph");

const dynImport = new Function("s", "return import(s)") as (s: string) => Promise<any>;
let esm: Promise<{ Validator: any; sparqlValidations: any; rdf: any }> | null = null;
export function shaclEngine() {
  if (!esm) esm = (async () => {
    const se = await dynImport("shacl-engine");
    const sp = await dynImport("shacl-engine/sparql.js");
    const rdf = (await dynImport("rdf-ext")).default;
    return { Validator: se.Validator, sparqlValidations: sp.validations, rdf };
  })();
  return esm;
}

export { ox };

// Turtle into quads in one named graph. Throws on a parse error.
export function parseTurtleInto(turtle: string, graph: string): any[] {
  const s = new ox.Store();
  s.load(turtle, { format: "text/turtle", to_graph_name: ox.namedNode(graph) });
  return [...s.match()];
}

export function parseNQuads(nq: string): any[] {
  const s = new ox.Store();
  if (nq.trim()) s.load(nq, { format: "application/n-quads" });
  return [...s.match()];
}

// One N-Triples/N-Quads line per quad (Oxigraph's own serialiser).
export function toNQuads(quads: Iterable<any>): string {
  const s = new ox.Store();
  for (const q of quads) s.add(ox.fromQuad(q));
  return s.dump({ format: "application/n-quads" });
}

export function termNT(t: any): string {
  const s = new ox.Store();
  s.add(ox.quad(ox.namedNode("urn:x:s"), ox.namedNode("urn:x:p"), ox.fromTerm(t)));
  const line = s.dump({ format: "application/n-triples" }).trim();
  return line.slice("<urn:x:s> <urn:x:p> ".length, -2).trim();
}

export const quadKey = (q: any) => `${q.subject.termType}:${q.subject.value}|${q.predicate.value}|${termKey(q.object)}|${q.graph.termType}:${q.graph.value}`;
export const termKey = (t: any) => t.termType === "Literal" ? `L:${t.value}@${t.language}^^${t.datatype?.value}` : `${t.termType}:${t.value}`;

// SPARQL Update DATA blocks for a set of quads, grouped by graph.
export function dataBlock(quads: any[]): string {
  const byGraph = new Map<string, any>();
  for (const q of quads) {
    const g = q.graph.termType === "DefaultGraph" ? "" : q.graph.value;
    if (!byGraph.has(g)) byGraph.set(g, new ox.Store());
    byGraph.get(g)!.add(ox.quad(ox.fromTerm(q.subject), ox.fromTerm(q.predicate), ox.fromTerm(q.object)));
  }
  const parts: string[] = [];
  for (const [g, st] of byGraph) {
    const body = st.dump({ format: "application/n-triples" }).trim();
    parts.push(g ? `GRAPH <${g}> {\n${body}\n}` : body);
  }
  return parts.join("\n");
}
