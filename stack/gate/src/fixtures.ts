// Reads the stack's fixtures and fills in their {{TOKEN}} placeholders.
import * as fs from "node:fs";
import * as path from "node:path";
import { randomUUID } from "node:crypto";
import { config, paths } from "./config";
import { BRANCH_TOKENS } from "./graphs";

export function readFixture(rel: string): string {
  return fs.readFileSync(path.join(paths.fixtures, rel), "utf8");
}

// A file by its path under config.stackDir (fixtures/..., tenant-generated/...).
export function readStackFile(rel: string): string {
  return fs.readFileSync(path.join(config.stackDir, rel), "utf8");
}

// Fills a fixture's tokens. {{DBR}} and {{DSR}} (a rule's graphs) are left as
// they are unless given: on the runtime write path the Write Stamping Stage
// binds them, never the writer (S0.5 Pass B3).
export function fill(template: string, values: Record<string, string>): string {
  return template.replace(/\{\{([A-Z]+)\}\}/g, (m, k: string) => {
    if (k in values) return values[k];
    if (k in BRANCH_TOKENS) return m;
    throw new Error(`fixture token {{${k}}} has no value`);
  });
}

export const runId = () => randomUUID().slice(0, 8);

export const ORDER_NS = "urn:ontara:standin:cafe#order-";
export const EXEC_NS = "urn:ontara:standin:cafe#exec-";

// The 54-triple order write (axis values in B8 form: S0.5 Pass B8) plus the
// readiness rule and the labelling step, as one gate write request. The
// order arrives in preparation and paid, every line ready, so the rule makes
// the permitted move inPreparation -> ready on every write. No graph: the
// rules keep their {{DBR}} token for the Write Stamping Stage (S0.5 Pass B3).
export const ORDER_FIXTURE = "writes/order-54.ttl";
export function orderWrite(orderIri: string, opts: { rule?: boolean } = {}) {
  const t = new Date().toISOString();
  const turtle = fill(readFixture(ORDER_FIXTURE), { O: orderIri, T: t });
  const exec = `${orderIri}/exec/readiness`;
  const updates = opts.rule === false ? [] : [
    fill(readFixture("rules/order-readiness.rq"), { O: orderIri, EXEC: exec }),
    fill(readFixture("rules/labelling.rq"), { EXEC: exec }),
  ];
  return { turtle, updates };
}

// Every subject the order write (with its rules) creates, so a writer can
// remove its own order by IRI (Ella, S525: no CLEAR of a branch graph).
export function orderSubjects(orderIri: string): string[] {
  const lines = [1, 2, 3, 4];
  return [orderIri, `${orderIri}/record`, `${orderIri}/ready-record`, `${orderIri}/exec/readiness`,
          ...lines.map((n) => `${orderIri}/line/${n}`), ...lines.map((n) => `${orderIri}/line/${n}/record`)];
}
