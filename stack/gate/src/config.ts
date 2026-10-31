// Runtime configuration, from the Compose environment.
import * as path from "node:path";

export const config = {
  graphdbUrl: process.env.GRAPHDB_URL ?? "http://graphdb:7200",
  repository: process.env.GRAPHDB_REPOSITORY ?? "cafe-runtime",
  temporalAddress: process.env.TEMPORAL_ADDRESS ?? "temporal:7233",
  temporalNamespace: process.env.TEMPORAL_NAMESPACE ?? "default",
  gateUrl: process.env.GATE_URL ?? "http://localhost:7220",
  port: Number(process.env.GATE_PORT_INTERNAL ?? 7220),
  stackDir: process.env.STACK_DIR ?? "/stack",
  healthTaskQueue: "stack-health",
  // OP-134 spike (B1): which store adapter the gate uses. Unset = graphdb, so
  // the S0.1 stack (compose.yaml) runs exactly as before.
  storeKind: (process.env.STORE_KIND ?? "graphdb") as "graphdb" | "rdf4j" | "fuseki" | "oxigraph",
  storeUrl: process.env.STORE_URL ?? process.env.GRAPHDB_URL ?? "http://graphdb:7200",
  storeVersion: process.env.STORE_VERSION ?? "",
  rdf4jDelegate: (process.env.RDF4J_DELEGATE ?? "native") as "native" | "lmdb",
  oxigraphStagingUrl: process.env.OXIGRAPH_STAGING_URL ?? "http://oxigraph-staging:7878",
  oxigraphScratchUrl: process.env.OXIGRAPH_SCRATCH_URL ?? "http://oxigraph-scratch:7878",
  // Results subdirectory for the capability checks (the spike writes per configuration).
  capabilityOutDir: process.env.CAP_OUT_DIR ?? "",
};

export const paths = {
  fixtures: path.join(config.stackDir, "fixtures"),
  results: path.join(config.stackDir, "results"),
  kgSource: path.join(config.stackDir, "kg-source"),
};

// Named graphs used by the stack at S0.1. Provisional: S0.5 sets the real
// named-graph scheme. The shapes graph is RDF4J's fixed default.
export const graphs = {
  shapes: "http://rdf4j.org/schema/rdf4j#SHACLShapeGraph",
  health: "urn:ontara:stack:graph:health",
  loadtest: "urn:ontara:stack:graph:loadtest",
  manual: "urn:ontara:stack:graph:manual",
  capability: "urn:ontara:stack:graph:capability",
};

// RDF4J's Bulk validation setting. Only the full name works; the short form
// "ValidationApproach=Bulk" is silently ignored (S515 notes section 2.4).
export const BULK_SETTING =
  "transaction-setting__org.eclipse.rdf4j.sail.shacl.ShaclSail.TransactionSettings.ValidationApproach";
