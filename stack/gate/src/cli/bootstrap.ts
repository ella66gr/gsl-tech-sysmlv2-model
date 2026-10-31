// One-shot bootstrap, run by the `bootstrap` Compose service before the gate
// starts. Exits non-zero, loudly, on any failure; the gate then never starts.
//
//  1. the licence is loaded and valid (Free, 11.3);
//  2. the runtime repository exists, created from GraphDB's own JSON default
//     config with isShacl=true and ruleset=empty (never from Turtle);
//  3. the configuration is read back: isShacl must be "true" and the ruleset
//     "empty" (no store-side inference, OP-134 R4);
//  4. the stand-in shapes are loaded into rdf4j:SHACLShapeGraph;
//  5. the knowledge-graph files are (re)loaded, one named graph per file.
import * as fs from "node:fs";
import * as path from "node:path";
import { GraphDB, shaclRepositoryConfig, param } from "../graphdb";
import { config, graphs, paths } from "../config";
import { readFixture } from "../fixtures";

const db = new GraphDB();

function die(msg: string): never {
  console.error("\n" + "!".repeat(78));
  console.error(`BOOTSTRAP FAILED: ${msg}`);
  console.error("!".repeat(78) + "\n");
  process.exit(2);
}

async function main() {
  const t0 = Date.now();
  console.log(`[bootstrap] GraphDB ${config.graphdbUrl}, repository ${config.repository}`);

  // 1. licence
  const v = await db.version();
  const lic = await db.license();
  console.log(`[bootstrap] GraphDB ${v.productVersion} (${v.productType}), RDF4J ${v.sesame}`);
  console.log(`[bootstrap] licence: valid=${lic.valid} product=${lic.productType} version=${lic.version} licensee="${lic.licensee}" maxCpuCores=${lic.maxCpuCores} expiry=${lic.expiryDate}`);
  if (lic.valid !== true || lic.present !== true) die(`GraphDB licence not valid: ${JSON.stringify({ valid: lic.valid, present: lic.present, message: lic.message })}`);
  if (v.productVersion !== "11.3.1") die(`expected GraphDB 11.3.1, found ${v.productVersion}`);
  if (lic.version !== "11.3") console.warn(`[bootstrap] WARNING: licence is for ${lic.version}, the stack pins 11.3.1`);

  // 2. repository
  const repos = await db.listRepositories();
  if (!repos.includes(config.repository)) {
    const cfg = await shaclRepositoryConfig(db, config.repository, "Ontara Cafe runtime (KG + runtime state; S0.1)");
    const r = await db.createRepository(cfg);
    if (r.status !== 201) die(`create repository ${config.repository}: HTTP ${r.status}: ${r.body.slice(0, 500)}`);
    console.log(`[bootstrap] created repository ${config.repository} from GraphDB's JSON default config`);
  } else {
    console.log(`[bootstrap] repository ${config.repository} already exists`);
  }

  // 3. read the configuration back
  const cfg = await db.repositoryConfig();
  const isShacl = param(cfg, "isShacl");
  console.log(`[bootstrap] read back: isShacl=${isShacl} validationEnabled=${param(cfg, "validationEnabled")} ruleset=${param(cfg, "ruleset")} enableContextIndex=${param(cfg, "enableContextIndex")} shapesGraph=${param(cfg, "shapesGraph")} transactionalValidationLimit=${param(cfg, "transactionalValidationLimit")}`);
  if (isShacl !== "true") {
    die(`repository ${config.repository} reads back isShacl=${isShacl}. SHACL cannot be switched on after creation. ` +
        `Fix the repository config (JSON, isShacl=true), delete the repository (README "Recovery") and run again. Do not continue.`);
  }
  if (param(cfg, "validationEnabled") !== "true") die(`validationEnabled is ${param(cfg, "validationEnabled")}`);
  if (param(cfg, "ruleset") !== "empty") {
    die(`repository ${config.repository} reads back ruleset=${param(cfg, "ruleset")}; the runtime repository must have no ` +
        `store-side inference (ruleset=empty, OP-134 R4). A ruleset cannot be changed after creation: delete the repository (README "Recovery") and run again.`);
  }

  // 4. shapes (replace the shapes graph)
  const shapes = readFixture("shapes/standin-shapes.ttl");
  const s = await db.replaceGraph(graphs.shapes, shapes, "text/turtle");
  if (s.status !== 204) die(`loading shapes: HTTP ${s.status}: ${s.body.slice(0, 1000)}`);
  const shapeTriples = (await db.statements({ graph: graphs.shapes })).length;
  if (shapeTriples === 0) die(`shapes graph <${graphs.shapes}> reads back empty`);
  console.log(`[bootstrap] shapes loaded into <${graphs.shapes}>: ${shapeTriples} triples (read back via getStatements)`);

  // 5. knowledge graph
  const manifest = JSON.parse(readFixture("kg/manifest.json"));
  for (const f of manifest.files) {
    const file = path.join(paths.kgSource, f.path);
    if (!fs.existsSync(file)) die(`knowledge-graph file missing: ${f.path} (looked for ${file})`);
    const g = manifest.graphPrefix + f.graph;
    const ts = Date.now();
    const r = await db.replaceGraph(g, fs.readFileSync(file, "utf8"), f.contentType);
    if (r.status !== 204) die(`loading ${f.path} into <${g}>: HTTP ${r.status}: ${r.body.slice(0, 1000)}`);
    console.log(`[bootstrap] kg <${g}> ${await db.size(g)} triples (${Date.now() - ts} ms) from ${f.path}`);
  }
  console.log(`[bootstrap] repository size ${await db.size()} explicit statements`);
  console.log(`[bootstrap] OK in ${((Date.now() - t0) / 1000).toFixed(1)} s`);
}

main().catch((e) => die(String(e?.stack ?? e)));
