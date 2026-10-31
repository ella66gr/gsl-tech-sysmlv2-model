// The health check command: calls the gate's /health endpoint and prints the
// result. Exit 0 = pass, 1 = fail, 2 = gate unreachable.
import { config } from "../config";

async function main() {
  let r: Response;
  try {
    r = await fetch(`${config.gateUrl}/health`, { signal: AbortSignal.timeout(120_000) });
  } catch (e) {
    console.error(`HEALTH: gate unreachable at ${config.gateUrl}: ${e}`);
    process.exit(2);
  }
  const h: any = await r.json();
  for (const c of h.checks) console.log(`${c.pass ? "PASS" : "FAIL"}  ${c.name}  (${c.ms} ms)`);
  if (process.argv.includes("--json")) console.log(JSON.stringify(h, null, 2));
  console.log(`HEALTH: ${h.status.toUpperCase()}  run=${h.run}  repository=${h.repository}${h.store && h.store !== "graphdb" ? `  store=${h.store}` : ""}`);
  process.exit(h.status === "pass" ? 0 : 1);
}
main();
