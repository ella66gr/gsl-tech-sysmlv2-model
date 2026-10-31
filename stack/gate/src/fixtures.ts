// Reads the stack's fixtures and fills in their {{TOKEN}} placeholders.
import * as fs from "node:fs";
import * as path from "node:path";
import { randomUUID } from "node:crypto";
import { paths } from "./config";

export function readFixture(rel: string): string {
  return fs.readFileSync(path.join(paths.fixtures, rel), "utf8");
}

export function fill(template: string, values: Record<string, string>): string {
  return template.replace(/\{\{([A-Z]+)\}\}/g, (m, k: string) => {
    if (!(k in values)) throw new Error(`fixture token {{${k}}} has no value`);
    return values[k];
  });
}

export const runId = () => randomUUID().slice(0, 8);

export const ORDER_NS = "urn:ontara:standin:cafe#order-";
export const EXEC_NS = "urn:ontara:standin:cafe#exec-";

// The 53-triple order write plus the readiness rule and the labelling step,
// as one gate write request.
export function orderWrite(orderIri: string, graph: string, opts: { rule?: boolean } = {}) {
  const t = new Date().toISOString();
  const turtle = fill(readFixture("writes/order-53.ttl"), { O: orderIri, T: t });
  const exec = `${orderIri}/exec/readiness`;
  const updates = opts.rule === false ? [] : [
    fill(readFixture("rules/order-readiness.rq"), { O: orderIri, EXEC: exec, G: graph }),
    fill(readFixture("rules/labelling.rq"), { EXEC: exec, G: graph }),
  ];
  return { graph, turtle, updates };
}
