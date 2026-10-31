// The store interface between the constraint gate and the runtime store
// (OP-134 spike, B1). One adapter per configuration:
//   graphdb   GraphDB 11.3.1 (the control): RDF4J transactions + GraphDB REST administration
//   rdf4j     RDF4J Server 6.1.0: RDF4J transactions + RDF4J REST administration
//   fuseki    Apache Jena Fuseki 5.6.0 with the Ontara validated-update module
//   oxigraph  Oxigraph 0.5.13, SHACL validated in the gate
//
// The health check, the capability checks and the load harness call only this
// interface, so each configuration runs the same tests. Where a store cannot
// offer something, the adapter says so (NotApplicable, or a `note`); it never
// fakes it.
import { HttpResult } from "./graphdb-client";
import { ShaclResult } from "../report";

export type StoreKind = "graphdb" | "rdf4j" | "fuseki" | "oxigraph";

export interface NotApplicable { applicable: false; reason: string }
export const notApplicable = (reason: string): NotApplicable => ({ applicable: false, reason });
export const isNotApplicable = (x: any): x is NotApplicable => !!x && x.applicable === false;

export interface WriteRequest {
  graph?: string;            // named graph for `turtle`; default: the manual graph
  turtle?: string;           // triples to add
  updates?: string[];        // SPARQL Updates run in order, same transaction
  validation?: "normal" | "bulk";
  label?: string;
}

export interface Timings { begin: number; add: number; updates: number; commit: number; rollback: number; total: number; [phase: string]: number }

export type WriteOutcome =
  | { outcome: "committed"; timings: Timings; note?: string }
  | {
      outcome: "rejected";
      stage: string;
      shapes: string[];
      nodeShapes: string[];
      results: (ShaclResult & { nodeShape: string | null })[];
      rolledBack: boolean;
      rollbackStatus: number | null;
      timings: Timings;
      note?: string;
    }
  | {
      outcome: "fault";
      stage: string;
      httpStatus: number | null;
      detail: string;
      rolledBack: boolean;
      rollbackStatus: number | null;
      timings: Timings;
    };

export interface GraphLoad { ok: boolean; status: number; body: string }

// What the bootstrap and the health check read back about a repository.
export interface RepoReadBack {
  shacl: string;              // "true" when SHACL is validated in the write path (store or gate)
  validationEnabled: string;  // "true" unless validation is switched off
  inference: string;          // "empty" (GraphDB ruleset) or "none" (no inferencer); anything else fails R4
  shaclLocus: "store" | "gate";
  line: string;               // the bootstrap's read-back line
  raw?: any;
}

export interface StoreInfo { product: string; version: string; shaclEngine: string; raw?: any }

export interface Store {
  readonly kind: StoreKind;
  readonly label: string;        // prefix for health-check names
  readonly repository: string;
  readonly shapesGraph: string;  // where this configuration holds the shapes (store-specific: R8)
  withRepo(id: string): Store;

  // SPARQL and data
  select(query: string, timeoutMs?: number): Promise<any[]>;
  ask(query: string): Promise<boolean>;
  update(update: string): Promise<HttpResult>;   // direct, outside the gate: maintenance only
  replaceGraph(graph: string, data: string, contentType: string): Promise<GraphLoad>;
  size(graph?: string): Promise<number>;         // explicit triples (all named graphs, or one)
  shapesTriples(): Promise<number>;              // the shapes graph, read by the store's own route
  shapesGraphSparqlCount(): Promise<number>;     // the shapes graph, read by a SPARQL GRAPH query

  // The gate's write: triples plus SPARQL Updates, validated, all-or-nothing.
  write(req: WriteRequest): Promise<WriteOutcome>;

  // Administration
  preflight(): Promise<{ lines: string[]; error?: string }>;  // product, version, licence
  info(): Promise<StoreInfo>;
  licence(): Promise<any | NotApplicable>;
  listRepositories(): Promise<string[]>;
  createRepository(id: string, title: string): Promise<GraphLoad & { note?: string }>;
  deleteRepository(id: string): Promise<{ ok: boolean; status: number; note?: string }>;
  readBack(id?: string): Promise<RepoReadBack>;
}

export const SH = "http://www.w3.org/ns/shacl#";
export const RDF4J_SHAPES_GRAPH = "http://rdf4j.org/schema/rdf4j#SHACLShapeGraph";
export const ONTARA_SHAPES_GRAPH = "urn:ontara:stack:shapes";
