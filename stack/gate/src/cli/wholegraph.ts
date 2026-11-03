// The whole-graph check's command (S0.5 Pass B4; wholegraph.ts says what it
// checks and why it is off the write path).
//   node dist/cli/wholegraph.js --schedule              the whole-graph-check service: a run every
//                                                        ONTARA_WHOLE_GRAPH_CHECK_INTERVAL seconds
//                                                        (compose.yaml, default 300), runs never overlapping
//   node dist/cli/wholegraph.js --once [--trigger NAME]  one run (bin/whole-graph-check.sh: --trigger manual)
// --once exits 0 when the run is clean, 1 when it found something, 2 when it
// could not run. --schedule never exits on a finding or a fault: D2, no
// automatic action; each run's report and log line say what it found.
import { runtimeStore } from "../gate";
import { wholeGraphCheck as settings } from "../config";
import { runWholeGraphCheck } from "../wholegraph";

async function main() {
  const a = process.argv.slice(2);
  const arg = (k: string) => { const i = a.indexOf(k); return i >= 0 ? a[i + 1] : undefined; };
  const store = runtimeStore();
  if (a.includes("--schedule")) {
    const every = settings.intervalSeconds;
    if (!Number.isFinite(every) || every < 5) throw new Error(`ONTARA_WHOLE_GRAPH_CHECK_INTERVAL must be a number of seconds, at least 5, not ${process.env.ONTARA_WHOLE_GRAPH_CHECK_INTERVAL}`);
    console.log(`[whole-graph-check] scheduled every ${every} s on /${store.dataset}; reports in results/${settings.dir}/ (keeping ${settings.keep}); no automatic action`);
    let stopping = false;
    for (const sig of ["SIGTERM", "SIGINT"]) process.on(sig, () => { stopping = true; process.exit(0); });
    // The bootstrap ran the check at the knowledge-graph load; the first
    // scheduled run is one interval after this service starts.
    while (!stopping) {
      await new Promise((r) => setTimeout(r, every * 1000));
      await runWholeGraphCheck(store, { trigger: "schedule" });
    }
    return;
  }
  const r = await runWholeGraphCheck(store, { trigger: arg("--trigger") ?? "manual" });
  process.exit(r.fault ? 2 : r.clean ? 0 : 1);
}
main().catch((e) => { console.error(e); process.exit(2); });
