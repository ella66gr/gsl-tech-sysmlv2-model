// The runtime named-graph scheme's names: the one set of graph-name templates
// (S0.5 Pass B3 item 9; H-0078; D1 Option A, Ella S521/S522; names per OP-138
// Part 1, Ella S525). Read by the gate's write path (the Write Stamping Stage,
// wss.ts, and the write policy), the rules (their {{DBR}} and {{DSR}} tokens),
// the bootstrap, the health check, the load harness, the regression check and
// the placement queries (and, at B4, the whole-graph check). No other file
// spells a graph name of the scheme.
//
//   https://ontara.dev/graph/dhb/{tenant}/{dhbId}/dbr   a Declared History Branch's
//   https://ontara.dev/graph/dhb/{tenant}/{dhbId}/dsr   business and system sides
//   https://ontara.dev/graph/kg/metamodel               the knowledge graph (B28's three
//   https://ontara.dev/graph/kg/domain                  model-content graphs; metamodel
//   https://ontara.dev/graph/kg/correspondence          stays empty at Stage 0)
//   https://ontara.dev/graph/shapes                     the SHACL shapes
//
// A Declared History Branch (DHB) is one line of recorded history; the
// tenant's one continuous real DHB is its Reality Reference Branch (RRB). At
// Stage 0 the Cafe's RRB is the only DHB. Its identifier, dhbId, is a
// lower-case UUID v4 generated once by the store when it creates the runtime
// dataset from empty, kept beside it in the data volume, and reported in the
// store module's status (rrb.dhbId); it is never committed. Pass B writes no
// declaration record for it.

export const GRAPH_BASE = "https://ontara.dev/graph/";
export const RUNTIME_GRAPH_ROOT = `${GRAPH_BASE}dhb/`;

export type Side = "dbr" | "dsr";
export const SIDES: Side[] = ["dbr", "dsr"];

// The tenant whose runtime this stack is. One tenant per runtime dataset.
export const TENANT = process.env.ONTARA_TENANT ?? "cafe";

export const KG_GRAPHS = {
  metamodel: `${GRAPH_BASE}kg/metamodel`,
  domain: `${GRAPH_BASE}kg/domain`,
  correspondence: `${GRAPH_BASE}kg/correspondence`,
} as const;
export type KgGraph = keyof typeof KG_GRAPHS;

export const SHAPES_GRAPH = `${GRAPH_BASE}shapes`;

// Jena's name for the stored default graph (not the union): the placement
// queries read it explicitly, because a union default graph hides it.
export const STORED_DEFAULT_GRAPH = "urn:x-arq:DefaultGraph";

const UUID_V4 = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/;
const TENANT_SLUG = /^[a-z][a-z0-9-]*$/;

export function isDhbId(id: string): boolean { return UUID_V4.test(id); }

// A DHB's graph on one side.
export function dhbGraph(tenant: string, dhbId: string, side: Side): string {
  if (!TENANT_SLUG.test(tenant)) throw new Error(`tenant ${JSON.stringify(tenant)} is not a tenant slug`);
  if (!isDhbId(dhbId)) throw new Error(`dhbId ${JSON.stringify(dhbId)} is not a lower-case UUID v4`);
  return `${RUNTIME_GRAPH_ROOT}${tenant}/${dhbId}/${side}`;
}

export interface Branch { tenant: string; dhbId: string; dbr: string; dsr: string }
export function branch(tenant: string, dhbId: string): Branch {
  return { tenant, dhbId, dbr: dhbGraph(tenant, dhbId, "dbr"), dsr: dhbGraph(tenant, dhbId, "dsr") };
}

// Reads a graph IRI back into its parts, or null if it is not a well-formed runtime graph.
export function parseRuntimeGraph(iri: string): { tenant: string; dhbId: string; side: Side } | null {
  const m = /^https:\/\/ontara\.dev\/graph\/dhb\/([a-z][a-z0-9-]*)\/([^/]+)\/(dbr|dsr)$/.exec(iri);
  if (!m || !isDhbId(m[2])) return null;
  return { tenant: m[1], dhbId: m[2], side: m[3] as Side };
}

// Graphs no runtime write may change (write rule 2).
export const PROTECTED_GRAPHS = [...Object.values(KG_GRAPHS), SHAPES_GRAPH];

// Every graph the scheme knows for a set of declared DHBs (placement query P3).
export function knownGraphs(declared: Branch[]): string[] {
  return [...Object.values(KG_GRAPHS), SHAPES_GRAPH, ...declared.flatMap((b) => [b.dbr, b.dsr])];
}

// The runtime roots (placement query P2): every runtime instance is typed with
// a subclass of one of them. Pass C adds the DHB's own class.
export const RUNTIME_ROOTS = [
  "https://ontara.dev/ontology/bmm/CanonicalRuntimeType",
  "https://ontara.dev/ontology/record/PlatformRecord",
];

// The placement queries' tokens (Cyril, S0.5 Pass B step 2, §3.1 item 2).
export function placementTokens(declared: Branch[]): Record<string, string> {
  return {
    RUNTIME_GRAPH_ROOT,
    STORED_DEFAULT_GRAPH,
    RUNTIME_ROOTS: RUNTIME_ROOTS.map((r) => `<${r}>`).join(" "),
    KNOWN_GRAPHS: knownGraphs(declared).map((g) => `<${g}>`).join(", "),
  };
}

// The tokens a rule names its graphs by. The Write Stamping Stage binds them
// to the request's DHB; a writer never supplies them.
export const BRANCH_TOKENS: Record<string, Side> = { DBR: "dbr", DSR: "dsr" };
export function bindBranch(template: string, b: { dbr: string; dsr: string }): string {
  return template.replace(/\{\{(DBR|DSR)\}\}/g, (_m, k: string) => (k === "DBR" ? b.dbr : b.dsr));
}
