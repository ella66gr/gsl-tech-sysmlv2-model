// The store interface between the constraint gate and the runtime store.
// Brought onto main from the OP-134 spike (spike/op-134-store, B1) at S521,
// S0.1 pass 3, with one adapter: Apache Jena Fuseki with the Ontara
// validated-update module (store/fuseki.ts). The GraphDB, RDF4J and Oxigraph
// adapters stay on the spike branch.
//
// The gate, the bootstrap, the health check, the capability checks, the load
// harness and the regression check call only this interface.
import { HttpResult } from "./http";
import { ShaclResult } from "../report";

export type StoreKind = "fuseki";

export interface WriteRequest {
  graph?: string;            // named graph for `turtle`; default: the manual graph
  turtle?: string;           // triples to add
  updates?: string[];        // SPARQL Updates run in order, in the same request (and so the same transaction)
  label?: string;
}

// One request, so the whole request is reported as `commit`; the other
// phases stay for the shape of the S0.1 results files and are 0.
export interface Timings { begin: number; add: number; updates: number; commit: number; rollback: number; total: number }

// How the store's transaction ended, from the module's X-Ontara-Transaction
// header: "committed", "aborted", or "unknown" when the store sent no such
// header (for example the request never reached it, or it timed out).
export type TransactionEnd = "committed" | "aborted" | "unknown";

interface OutcomeCommon {
  timings: Timings;
  // The store's X-Ontara-Validation header for this write, verbatim: how the
  // module validated it ("targeted; changes=.. touched=.. focus=.." or
  // "whole ..."). null when the reply carried no header.
  validation: string | null;
  transaction: TransactionEnd;
}

export type WriteOutcome =
  | ({ outcome: "committed" } & OutcomeCommon)
  | ({
      outcome: "rejected";
      stage: string;
      shapes: string[];
      nodeShapes: string[];
      results: (ShaclResult & { nodeShape: string | null })[];
      rolledBack: boolean;
    } & OutcomeCommon)
  | ({
      outcome: "fault";
      stage: string;
      httpStatus: number | null;
      detail: string;
      rolledBack: boolean;
    } & OutcomeCommon);

export interface GraphLoad { ok: boolean; status: number; body: string }

// The module's status (GET /<dataset>/validated-update), as it reports it
// (stack/README.md section 8).
export interface ModuleStatus {
  module: string;                // "ontara-fuseki-validated-update <moduleVersion>"
  moduleVersion: string;         // pom.xml <version>, read from the jar manifest
  jenaVersion: string;
  jenaBuildVersion: string;
  fusekiVersion: string;
  store: string;
  unionDefaultGraph: boolean;
  // Measured at each status read: validationProbe.passed AND targetShapes > 0.
  validating: boolean;
  validationMode: string;
  engine: string;
  // The write path's own validation code, in this mode, run on a fixed
  // in-memory probe: each violation rejected, the conforming case committed.
  validationProbe: { passed: boolean; microseconds: number; cases: { case: string; expected: string; outcome: string; validation?: string }[] };
  shapesGraph: string;
  shapesTriples: number;
  targetShapes: number;          // shapes with a target in the shapes graph; -1 if it does not parse
  shapesError?: string;
  inference: string;
  // The listener that answered: "published" (the host's 127.0.0.1:7210;
  // standard endpoints read-only) or "stack-network" (read-write).
  listener: { name: string; port: number; standardWriteEndpoints: boolean };
}

export interface Store {
  readonly kind: StoreKind;
  readonly label: string;        // prefix for health-check names
  readonly dataset: string;
  readonly shapesGraph: string;
  withDataset(id: string): Store;

  // SPARQL and data, through the dataset's standard (unvalidated) endpoints
  select(query: string, timeoutMs?: number): Promise<any[]>;
  ask(query: string): Promise<boolean>;
  update(update: string): Promise<HttpResult>;   // direct, outside the gate: maintenance only
  replaceGraph(graph: string, data: string, contentType: string): Promise<GraphLoad>;
  size(graph?: string): Promise<number>;         // triples in named graphs (all, or one)
  shapesTriples(): Promise<number>;

  // The gate's write: triples plus SPARQL Updates, validated, all-or-nothing.
  // Never rejects: every failure is an outcome (S519, e42a70c).
  write(req: WriteRequest): Promise<WriteOutcome>;

  // The module's status for this (or another) dataset.
  status(id?: string): Promise<ModuleStatus>;
  // Datasets are fixed when the store starts; these are the ones it serves.
  datasets(): string[];
  // Empties a dataset (the capability scratch dataset), through the
  // unvalidated update endpoint.
  clearDataset(id: string): Promise<GraphLoad>;
}

export const SH = "http://www.w3.org/ns/shacl#";
export const ONTARA_SHAPES_GRAPH = "urn:ontara:stack:shapes";
export const RUNTIME_DATASET = "cafe-runtime";
export const SCRATCH_DATASET = "cafe-capability-scratch";
