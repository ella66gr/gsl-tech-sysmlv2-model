// One-shot bootstrap, run by the `bootstrap` Compose service before the gate
// starts. Exits non-zero, loudly, on any failure; the gate then never starts.
//
//  1. the store answers, and the module's status on both datasets (the
//     runtime dataset and the capability scratch dataset) reads: the
//     validation probe passed (the write path's own validation, in this
//     mode, rejects known violations), the expected mode (targeted), the
//     pinned Jena version (the image's own build argument and the version
//     actually loaded), TDB2 with the union graph as the default graph, and
//     no inference. `validating` itself may read false here: it is false
//     until the shapes graph holds a shape with a target (README section 8);
//     The runtime dataset must also report its Reality Reference Branch
//     (rrb.dhbId, a lower-case UUID v4 the store generated when it created
//     the dataset from empty; S0.5 Pass B3), and the shapes graph the
//     templates name (graphs.ts);
//  2. the runtime shapes (config.ts RUNTIME_SHAPE_FILES: the stand-in record
//     shape, the two-sided readiness shapes and the Cafe's generated axis
//     shapes) are loaded into the runtime dataset's shapes graph
//     (https://ontara.dev/graph/shapes) and read back;
//  3. the knowledge graph is (re)loaded into B28's three model-content graphs
//     (S0.5 Pass B3 item 2; fixtures/kg/manifest.json names each file's graph
//     by key, graphs.ts names the graphs): kg/domain and kg/correspondence;
//     kg/metamodel stays empty at Stage 0. The first file of a graph replaces
//     it, the others are added;
//  4. the module's status is read once more: validating (probe passed and
//     shapes with targets in place), and the shapes count equal to what was
//     written. Only then does the bootstrap succeed.
//
// Steps 2 and 3 are the one sanctioned unvalidated write (Graph Store
// Protocol PUT): they reach the store on its stack-network listener (3030),
// whose standard endpoints accept writes; the published listener's do not.
//
// Datasets are declared in the store's own configuration (the module starts
// the two TDB2 datasets; stack/store/module), not created here.
import * as fs from "node:fs";
import * as path from "node:path";
import { openStore, ModuleStatus, SCRATCH_DATASET } from "../store";
import { config, paths, RUNTIME_SHAPE_FILES } from "../config";
import { readFixture, readStackFile } from "../fixtures";
import { KG_GRAPHS, KgGraph, SHAPES_GRAPH, isDhbId, branch, TENANT } from "../graphs";

const db = openStore();

function die(msg: string): never {
  console.error("\n" + "!".repeat(78));
  console.error(`BOOTSTRAP FAILED: ${msg}`);
  console.error("The store must not be used unvalidated. Do not continue: see the README, section 6 (Recovery).");
  console.error("!".repeat(78) + "\n");
  process.exit(2);
}

// `loaded`: the shapes are expected in place, so `validating` itself must be
// true; before the load, only the probe (the engine) is required.
function checkStatus(id: string, s: ModuleStatus, loaded: boolean) {
  const problems: string[] = [];
  if (s.validationProbe?.passed !== true) problems.push(`validationProbe.passed=${s.validationProbe?.passed}, expected true (probe: ${JSON.stringify(s.validationProbe?.cases)})`);
  if (loaded && s.validating !== true) problems.push(`validating=${s.validating} (targetShapes=${s.targetShapes}${s.shapesError ? `, ${s.shapesError}` : ""}), expected true`);
  if (s.validationMode !== config.expectedValidationMode) problems.push(`validationMode=${s.validationMode}, expected ${config.expectedValidationMode}`);
  if (s.jenaVersion !== config.expectedJenaVersion) problems.push(`jenaVersion (loaded)=${s.jenaVersion}, expected ${config.expectedJenaVersion}`);
  if (s.jenaBuildVersion !== config.expectedJenaVersion) problems.push(`jenaBuildVersion (image build argument)=${s.jenaBuildVersion}, expected ${config.expectedJenaVersion}`);
  if (s.store !== "TDB2") problems.push(`store=${s.store}, expected TDB2`);
  if (s.unionDefaultGraph !== true) problems.push(`unionDefaultGraph=${s.unionDefaultGraph}, expected true`);
  if (s.inference !== "none") problems.push(`inference=${s.inference}, expected none (OP-134 R4)`);
  if (s.shapesGraph !== SHAPES_GRAPH || db.shapesGraph !== SHAPES_GRAPH) problems.push(`shapesGraph=${s.shapesGraph}, expected ${SHAPES_GRAPH} (graphs.ts)`);
  if (id === config.dataset && !(s.rrb && isDhbId(s.rrb.dhbId))) problems.push(`rrb=${JSON.stringify(s.rrb)}: the runtime dataset reports no Reality Reference Branch identifier (a lower-case UUID v4)`);
  if (problems.length) die(`module status on /${id} does not read as required: ${problems.join("; ")}. Raw status: ${JSON.stringify(s)}`);
}

const line = (id: string, s: ModuleStatus) =>
  `[bootstrap] status /${id}: module="${s.module}" validating=${s.validating} probe=${s.validationProbe?.passed ? "passed" : "FAILED"} mode=${s.validationMode} jena=${s.jenaVersion} (built for ${s.jenaBuildVersion}) store=${s.store} unionDefaultGraph=${s.unionDefaultGraph} inference=${s.inference} shapesGraph=<${s.shapesGraph}> shapesTriples=${s.shapesTriples} targetShapes=${s.targetShapes}`;

async function main() {
  const t0 = Date.now();
  console.log(`[bootstrap] store ${config.storeUrl}, runtime dataset /${config.dataset}; required: validating, ${config.expectedValidationMode} mode, Jena ${config.expectedJenaVersion}`);

  // 1. module status on both datasets
  let first: ModuleStatus | null = null;
  for (let i = 0; ; i++) {
    try { first = await db.status(); break; }
    catch (e: any) { if (i >= 120) die(`store not reachable at ${config.storeUrl} after 120 s: ${e?.message ?? e}`); await new Promise((r) => setTimeout(r, 1000)); }
  }
  console.log(`[bootstrap] Apache Jena Fuseki ${first!.fusekiVersion} (Jena ${first!.jenaVersion}); licence: none needed (Apache-2.0)`);
  for (const id of [config.dataset, SCRATCH_DATASET]) {
    const s = id === config.dataset ? first! : await db.status(id).catch((e) => die(`status of /${id}: ${e?.message ?? e}`));
    console.log(line(id, s));
    checkStatus(id, s, false);
  }
  const rrb = branch(TENANT, first!.rrb!.dhbId);
  console.log(`[bootstrap] Reality Reference Branch of ${TENANT}: dhbId ${rrb.dhbId} (generated by the store ${first!.rrb!.generatedAt}, kept with it); runtime graphs <${rrb.dbr}> and <${rrb.dsr}>`);

  // 2. shapes (replace the shapes graph)
  for (const f of RUNTIME_SHAPE_FILES) if (!fs.existsSync(path.join(config.stackDir, f))) die(`runtime shapes file missing: ${f} (is the repository complete, and make gen run?)`);
  const shapes = RUNTIME_SHAPE_FILES.map((f) => readStackFile(f)).join("\n");
  const s = await db.replaceGraph(db.shapesGraph, shapes, "text/turtle");
  if (!s.ok) die(`loading shapes: HTTP ${s.status}: ${s.body.slice(0, 1000)}`);
  const shapeTriples = await db.shapesTriples();
  if (shapeTriples === 0) die(`shapes graph <${db.shapesGraph}> reads back empty`);
  console.log(`[bootstrap] shapes loaded into <${db.shapesGraph}>: ${shapeTriples} triples from ${RUNTIME_SHAPE_FILES.join(" + ")} (read back by SPARQL)`);

  // 3. knowledge graph
  const manifest = JSON.parse(readFixture("kg/manifest.json"));
  const started = new Set<string>();
  for (const f of manifest.files as { path: string; graph: KgGraph; contentType: string }[]) {
    const file = path.join(paths.kgSource, f.path);
    if (!fs.existsSync(file)) die(`knowledge-graph file missing: ${f.path} (is the repository complete?)`);
    const g = KG_GRAPHS[f.graph];
    if (!g) die(`manifest names graph ${JSON.stringify(f.graph)}, which is not a knowledge-graph graph (${Object.keys(KG_GRAPHS).join(", ")})`);
    const ts = Date.now();
    const first = !started.has(g);
    started.add(g);
    const r = first ? await db.replaceGraph(g, fs.readFileSync(file, "utf8"), f.contentType) : await db.appendGraph(g, fs.readFileSync(file, "utf8"), f.contentType);
    if (!r.ok) die(`loading ${f.path} into <${g}>: HTTP ${r.status}: ${r.body.slice(0, 1000)}`);
    console.log(`[bootstrap] kg <${g}> ${first ? "replaced by" : "added"} ${f.path}: graph now ${await db.size(g)} triples (${Date.now() - ts} ms)`);
  }
  for (const [k, g] of Object.entries(KG_GRAPHS)) console.log(`[bootstrap] kg ${k}: <${g}> ${await db.size(g)} triples`);
  console.log(`[bootstrap] runtime dataset holds ${await db.size()} triples in named graphs`);

  // 4. read the status back once more, with the shapes in place
  const after = await db.status();
  console.log(line(config.dataset, after));
  checkStatus(config.dataset, after, true);
  if (after.shapesTriples !== shapeTriples) die(`module reports ${after.shapesTriples} shapes triples, ${shapeTriples} were loaded`);
  console.log(`[bootstrap] OK in ${((Date.now() - t0) / 1000).toFixed(1)} s: validating, ${after.validationMode} mode, Jena ${after.jenaVersion}, ${after.shapesTriples} shapes triples`);
}

main().catch((e) => die(String(e?.stack ?? e)));
