// Runs the three placement queries (Cyril, S0.5 Pass B step 2, §3; B4 will
// carry them in the whole-graph check, at every knowledge-graph load and on a
// schedule). Each query names its graphs only through tokens, filled here from
// the templates module (graphs.ts) and the declared DHBs. In Pass B the only
// declared DHB is the Reality Reference Branch, read from the store's status;
// Pass B writes no declaration record, so there is nothing else to read.
//   node dist/cli/placement.js [--json]
// Prints each query's rows (breaches). Exit 0 when all three return no rows,
// 1 when any returns a row, 2 on a fault.
import * as fs from "node:fs";
import * as path from "node:path";
import { paths } from "../config";
import { runtimeStore } from "../gate";
import { requestBranch } from "../wss";
import { placementTokens } from "../graphs";

export const PLACEMENT_QUERIES = ["P1-one-home-graph.rq", "P2-runtime-instances-in-runtime-graphs.rq", "P3-known-graphs.rq"];

export function fillPlacement(text: string, tokens: Record<string, string>): string {
  return text.replace(/\{\{([A-Z_]+)\}\}/g, (m, k: string) => {
    if (!(k in tokens)) throw new Error(`placement query token {{${k}}} has no value`);
    return tokens[k];
  });
}

async function main() {
  const db = runtimeStore();
  const rrb = await requestBranch(db);
  const tokens = placementTokens([rrb]);
  const out: any = { declaredBranches: [{ tenant: rrb.tenant, dhbId: rrb.dhbId, dbr: rrb.dbr, dsr: rrb.dsr }], queries: [] as any[] };
  for (const f of PLACEMENT_QUERIES) {
    const q = fillPlacement(fs.readFileSync(path.join(paths.fixtures, "placement", f), "utf8"), tokens);
    const t0 = performance.now();
    const rows = (await db.select(q, 120_000)).map((b: any) => Object.fromEntries(Object.entries(b).map(([k, v]: [string, any]) => [k, v.value])));
    out.queries.push({ query: f, rows: rows.length, ms: Math.round(performance.now() - t0), sample: rows.slice(0, 10) });
  }
  if (process.argv.includes("--json")) console.log(JSON.stringify(out, null, 2));
  else for (const q of out.queries) console.log(`${q.rows === 0 ? "PASS" : "FOUND"}  ${q.query}: ${q.rows} row(s) (${q.ms} ms)${q.rows ? "\n  " + q.sample.map((r: any) => JSON.stringify(r)).join("\n  ") : ""}`);
  process.exit(out.queries.every((q: any) => q.rows === 0) ? 0 : 1);
}
if (require.main === module) main().catch((e) => { console.error(e); process.exit(2); });
