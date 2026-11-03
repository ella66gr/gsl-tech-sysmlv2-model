// Runtime configuration, from the Compose environment.
import * as path from "node:path";

export const config = {
  storeUrl: process.env.STORE_URL ?? "http://store:3030",
  dataset: process.env.STORE_DATASET ?? "cafe-runtime",
  // What the bootstrap and the health check require of the store's module
  // status (specification 2.5 items 3 and 6). Set in compose.yaml: the Jena
  // version is the pinned build argument; the mode is targeted (ADR-014).
  expectedJenaVersion: process.env.EXPECTED_JENA_VERSION ?? "6.2.0",
  expectedValidationMode: process.env.EXPECTED_VALIDATION_MODE ?? "targeted",
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
  // Each tenant's generated folder, mounted read-only by compose.yaml
  // (the Cafe's at tenant-generated/cafe; S0.5 Pass B8).
  tenantGenerated: path.join(config.stackDir, "tenant-generated"),
};

// Graph names come from the named-graph scheme's templates, graphs.ts (S0.5
// Pass B3). The S0.1 provisional graphs are gone (Ella, S525): the health
// check's, the load harness's and bin/write.sh's writes go into the Reality
// Reference Branch's dbr/dsr graphs through the Write Stamping Stage, like any
// runtime write. One provisional graph stays, by decision: the capability
// checks' graph, which lives only in the scratch dataset
// (cafe-capability-scratch), never in the runtime dataset.
export const CAPABILITY_GRAPH = "urn:ontara:stack:graph:capability";

// The shapes the bootstrap loads into the runtime dataset, as paths under
// config.stackDir: the stand-in record shape (core) and Cyril's two-sided core
// readiness shapes (S521, pass 3), in place of the S0.1 stand-in SPARQL
// readiness constraint, which targeted validation misses in its line-only case
// (ADR-014 §4.3); and the Cafe's generated axis membership and subject shapes
// (S0.5 Pass B8, H-0647; generation/axis_shapes.py, written by make gen into
// the Cafe's generated folder, a build output). The load harness measures with
// these (specification 2.5 item 8.1).
export const RUNTIME_SHAPE_FILES = [
  "fixtures/shapes/standin-shapes-core-only.ttl",
  "fixtures/shapes/spike-two-sided-readiness.ttl",
  "tenant-generated/cafe/axis-shapes.ttl",
];

// A write was validated in the expected mode when its X-Ontara-Validation
// header starts with the mode's name ("targeted; ..." or "whole ...").
export const validatedAs = (header: string | null | undefined, mode: string) =>
  !!header && (header === mode || header.startsWith(`${mode};`) || header.startsWith(`${mode} `));
