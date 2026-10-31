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
import { openStore } from "../store";
import { config, paths } from "../config";
import { readFixture } from "../fixtures";

// OP-134 spike (B1): every store call goes through the store interface, so
// the same bootstrap serves each configuration. For GraphDB the steps,
// read-back line and failure banners are as before.
const db = openStore();

function die(msg: string): never {
  console.error("\n" + "!".repeat(78));
  console.error(`BOOTSTRAP FAILED: ${msg}`);
  console.error("!".repeat(78) + "\n");
  process.exit(2);
}

async function main() {
  const t0 = Date.now();
  console.log(`[bootstrap] ${db.kind} ${config.storeUrl}, repository ${config.repository}`);

  // 0. wait for the store (OP-134 spike: the RDF4J and Oxigraph images have no
  //    tool for a Compose healthcheck, so the bootstrap waits; GraphDB is
  //    already healthy when this starts, so it passes at once).
  for (let i = 0; ; i++) {
    try { await db.listRepositories(); break; }
    catch (e: any) { if (i >= 120) die(`store not reachable at ${config.storeUrl} after 120 s: ${e?.message ?? e}`); await new Promise((r) => setTimeout(r, 1000)); }
  }

  // 1. product, version, licence (GraphDB: the licence must be valid)
  const pre = await db.preflight();
  for (const l of pre.lines) console.log(`[bootstrap] ${l}`);
  if (pre.error) die(pre.error);

  // 2. repository
  const repos = await db.listRepositories();
  if (!repos.includes(config.repository)) {
    const r = await db.createRepository(config.repository, "Ontara Cafe runtime (KG + runtime state; S0.1)");
    if (!r.ok) die(`create repository ${config.repository}: HTTP ${r.status}: ${r.body.slice(0, 500)}`);
    console.log(`[bootstrap] created repository ${config.repository} ${r.note ?? ""}`);
  } else {
    console.log(`[bootstrap] repository ${config.repository} already exists`);
  }

  // 3. read the configuration back
  const rb = await db.readBack();
  console.log(`[bootstrap] read back: ${rb.line}`);
  if (rb.shacl !== "true") {
    die(`repository ${config.repository} reads back isShacl=${rb.shacl}. SHACL cannot be switched on after creation. ` +
        `Fix the repository config (JSON, isShacl=true), delete the repository (README "Recovery") and run again. Do not continue.`);
  }
  if (rb.validationEnabled !== "true") die(`validationEnabled is ${rb.validationEnabled}`);
  if (rb.inference !== "empty" && rb.inference !== "none") {
    die(`repository ${config.repository} reads back ruleset=${rb.inference}; the runtime repository must have no ` +
        `store-side inference (ruleset=empty, OP-134 R4). A ruleset cannot be changed after creation: delete the repository (README "Recovery") and run again.`);
  }

  // 4. shapes (replace the shapes graph)
  const shapes = readFixture("shapes/standin-shapes.ttl");
  const s = await db.replaceGraph(db.shapesGraph, shapes, "text/turtle");
  if (!s.ok) die(`loading shapes: HTTP ${s.status}: ${s.body.slice(0, 1000)}`);
  const shapeTriples = await db.shapesTriples();
  if (shapeTriples === 0) die(`shapes graph <${db.shapesGraph}> reads back empty`);
  console.log(`[bootstrap] shapes loaded into <${db.shapesGraph}>: ${shapeTriples} triples (read back via ${db.kind === "graphdb" || db.kind === "rdf4j" ? "getStatements" : "SPARQL"})`);

  // 5. knowledge graph
  const manifest = JSON.parse(readFixture("kg/manifest.json"));
  for (const f of manifest.files) {
    const file = path.join(paths.kgSource, f.path);
    if (!fs.existsSync(file)) die(`knowledge-graph file missing: ${f.path} (looked for ${file})`);
    const g = manifest.graphPrefix + f.graph;
    const ts = Date.now();
    const r = await db.replaceGraph(g, fs.readFileSync(file, "utf8"), f.contentType);
    if (!r.ok) die(`loading ${f.path} into <${g}>: HTTP ${r.status}: ${r.body.slice(0, 1000)}`);
    console.log(`[bootstrap] kg <${g}> ${await db.size(g)} triples (${Date.now() - ts} ms) from ${f.path}`);
  }
  console.log(`[bootstrap] repository size ${await db.size()} explicit statements`);
  console.log(`[bootstrap] OK in ${((Date.now() - t0) / 1000).toFixed(1)} s`);
}

main().catch((e) => die(String(e?.stack ?? e)));
