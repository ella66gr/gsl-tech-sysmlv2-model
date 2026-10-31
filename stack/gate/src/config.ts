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
