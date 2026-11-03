// Sends one write through the gate, for manual and verification use.
//   node dist/cli/write.js <turtle-file> [--run ID] [--update <rq-file>]... [--remove IRI]...
// {{RUN}} in the files is replaced by --run or a fresh id. Paths may be
// absolute or relative to /stack (e.g. fixtures/writes/known-bad.ttl).
// There is no --graph (S0.5 Pass B3): the gate's Write Stamping Stage sets
// the graph from the request's Declared History Branch (at Stage 0 the Reality
// Reference Branch) and the content's side; an update names its graphs only
// as {{DBR}} and {{DSR}}, which the gate binds. --remove names an instance to
// remove from the branch's graphs (repeatable).
// Prints the gate's JSON reply, including the store's X-Ontara-Validation
// header as `validation`. Exit 0 committed, 1 rejected or refused, 2 fault/other.
import * as fs from "node:fs";
import * as path from "node:path";
import { config } from "../config";
import { fill, runId } from "../fixtures";

const args = process.argv.slice(2);
const opt = (name: string) => { const i = args.indexOf(name); return i >= 0 ? args.splice(i, 2)[1] : undefined; };
if (args.includes("--graph")) {
  console.error("--graph is gone (S0.5 Pass B3): the graph is derived by the gate's Write Stamping Stage, never accepted from the writer. Name a rule's graphs as {{DBR}} / {{DSR}}.");
  process.exit(2);
}
const run = opt("--run") ?? runId();
const updates: string[] = [];
for (let u = opt("--update"); u; u = opt("--update")) updates.push(u);
const remove: string[] = [];
for (let r = opt("--remove"); r; r = opt("--remove")) remove.push(r);
const file = args[0];
const resolve = (p: string) => (path.isAbsolute(p) ? p : path.join(config.stackDir, p));
const read = (p: string) => fill(fs.readFileSync(resolve(p), "utf8"), { RUN: run });

async function main() {
  const body = {
    turtle: file ? read(file) : undefined,
    updates: updates.map(read),
    remove: remove.map((x) => x.replace(/\{\{RUN\}\}/g, run)),
    label: `cli ${file ?? ""}`,
  };
  const r = await fetch(`${config.gateUrl}/write`, { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(body) });
  const j: any = await r.json();
  console.log(JSON.stringify({ http: r.status, run, ...j }, null, 2));
  process.exit(j.outcome === "committed" ? 0 : j.outcome === "rejected" || j.outcome === "refused" ? 1 : 2);
}
main().catch((e) => { console.error(e); process.exit(2); });
