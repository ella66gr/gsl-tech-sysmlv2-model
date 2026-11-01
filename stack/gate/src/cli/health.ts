// The health check command: calls the gate's /health endpoint and prints the
// result. Exit 0 = pass, 1 = fail, 2 = gate unreachable.
//   --json           print the full result
//   --record <dir>   also write the full result to results/<dir>/<UTC time>-health.json
import * as fs from "node:fs";
import * as path from "node:path";
import { config, paths } from "../config";

async function main() {
  const args = process.argv.slice(2);
  const ri = args.indexOf("--record");
  const record = ri >= 0 ? args[ri + 1] : null;
  let r: Response;
  try {
    r = await fetch(`${config.gateUrl}/health`, { signal: AbortSignal.timeout(120_000) });
  } catch (e) {
    console.error(`HEALTH: gate unreachable at ${config.gateUrl}: ${e}`);
    process.exit(2);
  }
  const h: any = await r.json();
  for (const c of h.checks) console.log(`${c.pass ? "PASS" : "FAIL"}  ${c.name}  (${c.ms} ms)`);
  if (args.includes("--json")) console.log(JSON.stringify(h, null, 2));
  if (record) {
    const dir = path.join(paths.results, record);
    fs.mkdirSync(dir, { recursive: true });
    const file = path.join(dir, `${new Date().toISOString().replace(/[:.]/g, "").replace(/\d{3}Z$/, "Z")}-health.json`);
    fs.writeFileSync(file, JSON.stringify(h, null, 2) + "\n");
    console.log(`recorded: results/${path.relative(paths.results, file)}`);
  }
  console.log(`HEALTH: ${h.status.toUpperCase()}  run=${h.run}  dataset=${h.dataset}  store=${h.store}`);
  process.exit(h.status === "pass" ? 0 : 1);
}
main();
