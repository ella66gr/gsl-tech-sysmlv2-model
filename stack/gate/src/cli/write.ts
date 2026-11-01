// Sends one write through the gate, for manual and verification use.
//   node dist/cli/write.js <turtle-file> [--graph IRI] [--run ID] [--update <rq-file>]...
// {{RUN}} in the files is replaced by --run or a fresh id. Paths may be
// absolute or relative to /stack (e.g. fixtures/writes/known-bad.ttl).
// Prints the gate's JSON reply, including the store's X-Ontara-Validation
// header as `validation`. Exit 0 committed, 1 rejected, 2 fault/other.
import * as fs from "node:fs";
import * as path from "node:path";
import { config, graphs } from "../config";
import { fill, runId } from "../fixtures";

const args = process.argv.slice(2);
const opt = (name: string) => { const i = args.indexOf(name); return i >= 0 ? args.splice(i, 2)[1] : undefined; };
const run = opt("--run") ?? runId();
const graph = opt("--graph") ?? graphs.manual;
const updates: string[] = [];
for (let u = opt("--update"); u; u = opt("--update")) updates.push(u);
const file = args[0];
const resolve = (p: string) => (path.isAbsolute(p) ? p : path.join(config.stackDir, p));
const read = (p: string) => fill(fs.readFileSync(resolve(p), "utf8"), { RUN: run, G: graph });

async function main() {
  const body = {
    graph,
    turtle: file ? read(file) : undefined,
    updates: updates.map(read),
    label: `cli ${file ?? ""}`,
  };
  const r = await fetch(`${config.gateUrl}/write`, { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(body) });
  const j: any = await r.json();
  console.log(JSON.stringify({ http: r.status, run, graph, ...j }, null, 2));
  process.exit(j.outcome === "committed" ? 0 : j.outcome === "rejected" ? 1 : 2);
}
main().catch((e) => { console.error(e); process.exit(2); });
