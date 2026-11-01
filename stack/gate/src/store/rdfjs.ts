// Turtle parsing and SPARQL Update data blocks for the Fuseki adapter, with
// Oxigraph's JavaScript build (WASM) used as an RDF parser and serialiser
// only: no Oxigraph store runs anywhere in the stack. Trimmed at S521 from
// the spike's file, which also loaded shacl-engine for the Oxigraph adapter.
// eslint-disable-next-line @typescript-eslint/no-var-requires
const ox = require("oxigraph");

// Turtle into quads in one named graph. Throws on a parse error.
export function parseTurtleInto(turtle: string, graph: string): any[] {
  const s = new ox.Store();
  s.load(turtle, { format: "text/turtle", to_graph_name: ox.namedNode(graph) });
  return [...s.match()];
}

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
    const body = st.dump({ format: "application/n-triples", from_graph_name: ox.defaultGraph() }).trim();
    parts.push(g ? `GRAPH <${g}> {\n${body}\n}` : body);
  }
  return parts.join("\n");
}
