// Prints the store module's status for both datasets (GET
// /<dataset>/validated-update), read from the store itself. Run by
// stack/bin/store-status.sh. Exit 0 when both read the validation probe
// passed, the expected mode and the pinned Jena version, and the runtime
// dataset also reads validating (shapes with targets loaded); 1 otherwise; 2
// if the store is unreachable. The capability scratch dataset holds shapes
// only during a capability run, so its `validating` reads false between runs
// (README section 8).
import { openStore, SCRATCH_DATASET } from "../store";
import { config } from "../config";

async function main() {
  const db = openStore();
  let ok = true;
  const out: any = { expected: { validating: true, validationMode: config.expectedValidationMode, jenaVersion: config.expectedJenaVersion }, datasets: {} };
  for (const id of [config.dataset, SCRATCH_DATASET]) {
    let s: any;
    try { s = await db.status(id); } catch (e: any) { console.error(`STORE STATUS: unreachable: ${e?.message ?? e}`); process.exit(2); }
    out.datasets[id] = s;
    const good = s.validationProbe?.passed === true && s.validationMode === config.expectedValidationMode && s.jenaVersion === config.expectedJenaVersion
      && s.jenaBuildVersion === config.expectedJenaVersion && (id !== config.dataset || (s.validating === true && s.shapesTriples > 0));
    if (!good) ok = false;
  }
  if (process.argv.includes("--line")) {
    const s = out.datasets[config.dataset];
    console.log(`Apache Jena Fuseki ${s.fusekiVersion} (Jena ${s.jenaVersion}, built for ${s.jenaBuildVersion}), ${s.module}, validating ${s.validating}, validation ${s.validationMode}, ${s.store}, shapes ${s.shapesTriples} triples (${s.targetShapes} with targets)`);
  } else {
    console.log(JSON.stringify(out, null, 2));
    console.log(`STORE STATUS: ${ok ? "OK" : "NOT AS REQUIRED"}`);
  }
  process.exit(ok ? 0 : 1);
}
main();
