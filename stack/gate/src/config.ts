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
};

// Named graphs used by the stack at S0.1. Provisional: S0.5 sets the real
// named-graph scheme.
export const graphs = {
  shapes: "urn:ontara:stack:shapes",
  health: "urn:ontara:stack:graph:health",
  loadtest: "urn:ontara:stack:graph:loadtest",
  manual: "urn:ontara:stack:graph:manual",
  capability: "urn:ontara:stack:graph:capability",
};

// The shapes the bootstrap loads into the runtime dataset (S521, pass 3):
// the stand-in record shape (core) and Cyril's two-sided core readiness
// shapes, in place of the S0.1 stand-in SPARQL readiness constraint, which
// targeted validation misses in its line-only case (ADR-014 §4.3). The load
// harness measures with these (specification 2.5 item 8.1).
export const RUNTIME_SHAPE_FILES = ["shapes/standin-shapes-core-only.ttl", "shapes/spike-two-sided-readiness.ttl"];

// A write was validated in the expected mode when its X-Ontara-Validation
// header starts with the mode's name ("targeted; ..." or "whole ...").
export const validatedAs = (header: string | null | undefined, mode: string) =>
  !!header && (header === mode || header.startsWith(`${mode};`) || header.startsWith(`${mode} `));
