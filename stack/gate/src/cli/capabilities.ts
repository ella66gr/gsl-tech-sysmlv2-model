// SHACL capability checks (S0.1, specification 2.5 item 7; S515 paper 7 item 3).
// Run by stack/bin/capabilities.sh, which first writes
// results/shacl-supported-predicates.json from getSupportedShaclPredicates().
//
// Everything runs in a scratch SHACL repository (created from GraphDB's JSON
// default config, deleted at the end), never in the runtime repository.
// Writes go through the gate's own write path (in-process).
//
//   1. sh:equals, sh:disjoint, sh:lessThan, sh:closed (and a few neighbours):
//      the declared list, plus an empirical test of each (bad write rejected,
//      good write committed).
//   2. the labelling step and the inline VALUES binding a mapping rule needs.
//   3. whether a core shape's sh:message (and a SPARQL constraint's) comes back
//      in GraphDB's rejection report.
// An unsupported component is a result, not a failure (input to S0.6).
import * as fs from "node:fs";
import * as path from "node:path";
import { GraphDB, shaclRepositoryConfig, param } from "../graphdb";
import { write, WriteOutcome } from "../gate";
import { config, graphs, paths } from "../config";
import { readFixture, orderWrite, fill } from "../fixtures";

const SCRATCH = "cafe-capability-scratch";
const SH = "http://www.w3.org/ns/shacl#";
const G = graphs.capability;
const base = new GraphDB();
const db = base.withRepo(SCRATCH);

const PFX = `@prefix sh: <${SH}> . @prefix ex: <urn:ontara:stack:cap#> . @prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> . @prefix xsd: <http://www.w3.org/2001/XMLSchema#> .\n`;

function brief(o: WriteOutcome) {
  if (o.outcome === "committed") return { outcome: o.outcome };
  if (o.outcome === "rejected") return { outcome: o.outcome, shapes: o.shapes, nodeShapes: o.nodeShapes, components: o.results.map((r) => r.component), messages: o.results.map((r) => r.message), rolledBack: o.rolledBack };
  return { outcome: o.outcome, stage: o.stage, httpStatus: o.httpStatus, detail: o.detail.slice(0, 400) };
}

async function loadShapes(ttl: string) {
  const r = await db.replaceGraph(graphs.shapes, ttl, "text/turtle");
  return { status: r.status, body: r.status === 204 ? "" : r.body.slice(0, 600) };
}

async function clearData() {
  await db.update(`CLEAR SILENT GRAPH <${G}>`);
}

interface ComponentTest { predicate: string; shape: string; bad: string; good: string; note?: string }

const componentTests: ComponentTest[] = [
  {
    predicate: "sh:equals",
    shape: `ex:EqShape a sh:NodeShape ; sh:targetClass ex:EqT ; sh:property [ sh:path ex:a ; sh:equals ex:b ] .`,
    bad: `ex:eq1 a ex:EqT ; ex:a 1 ; ex:b 2 .`,
    good: `ex:eq2 a ex:EqT ; ex:a 1 ; ex:b 1 .`,
  },
  {
    predicate: "sh:disjoint",
    shape: `ex:DisShape a sh:NodeShape ; sh:targetClass ex:DisT ; sh:property [ sh:path ex:a ; sh:disjoint ex:b ] .`,
    bad: `ex:dis1 a ex:DisT ; ex:a 1 ; ex:b 1 .`,
    good: `ex:dis2 a ex:DisT ; ex:a 1 ; ex:b 2 .`,
  },
  {
    predicate: "sh:lessThan",
    shape: `ex:LtShape a sh:NodeShape ; sh:targetClass ex:LtT ; sh:property [ sh:path ex:start ; sh:lessThan ex:end ] .`,
    bad: `ex:lt1 a ex:LtT ; ex:start "2026-10-31T10:00:00Z"^^xsd:dateTime ; ex:end "2026-10-31T09:00:00Z"^^xsd:dateTime .`,
    good: `ex:lt2 a ex:LtT ; ex:start "2026-10-31T09:00:00Z"^^xsd:dateTime ; ex:end "2026-10-31T10:00:00Z"^^xsd:dateTime .`,
  },
  {
    predicate: "sh:lessThanOrEquals",
    shape: `ex:LteShape a sh:NodeShape ; sh:targetClass ex:LteT ; sh:property [ sh:path ex:start ; sh:lessThanOrEquals ex:end ] .`,
    bad: `ex:lte1 a ex:LteT ; ex:start 5 ; ex:end 3 .`,
    good: `ex:lte2 a ex:LteT ; ex:start 3 ; ex:end 3 .`,
  },
  {
    predicate: "sh:closed",
    shape: `ex:ClosedShape a sh:NodeShape ; sh:targetClass ex:ClosedT ; sh:closed true ; sh:ignoredProperties ( rdf:type ) ; sh:property [ sh:path ex:a ] .`,
    bad: `ex:cl1 a ex:ClosedT ; ex:a 1 ; ex:extra 2 .`,
    good: `ex:cl2 a ex:ClosedT ; ex:a 1 .`,
  },
  {
    predicate: "sh:xone",
    shape: `ex:XoneShape a sh:NodeShape ; sh:targetClass ex:XoneT ; sh:xone ( [ sh:path ex:a ; sh:minCount 1 ] [ sh:path ex:b ; sh:minCount 1 ] ) .`,
    bad: `ex:x1 a ex:XoneT ; ex:a 1 ; ex:b 1 .`,
    good: `ex:x2 a ex:XoneT ; ex:a 1 .`,
    note: "not in the S515 paper's list; tested because it is absent from getSupportedShaclPredicates()",
  },
  {
    predicate: "sh:alternativePath inside sh:path sequence",
    shape: `ex:SeqAltShape a sh:NodeShape ; sh:targetClass ex:SeqAltT ; sh:property [ sh:path ( ex:p [ sh:alternativePath ( ex:q ex:r ) ] ) ; sh:minCount 1 ] .`,
    bad: `ex:sa1 a ex:SeqAltT ; ex:p ex:mid1 . ex:mid1 ex:other 1 .`,
    good: `ex:sa2 a ex:SeqAltT ; ex:p ex:mid2 . ex:mid2 ex:r 1 .`,
    note: "Saskia's shape 6 needs this (S515 paper 7 item 4)",
  },
  {
    predicate: "sh:zeroOrMorePath",
    shape: `ex:StarShape a sh:NodeShape ; sh:targetClass ex:StarT ; sh:property [ sh:path [ sh:zeroOrMorePath ex:p ] ; sh:maxCount 2 ] .`,
    bad: `ex:st1 a ex:StarT ; ex:p ex:st1b . ex:st1b ex:p ex:st1c .`,
    good: `ex:st2 a ex:StarT .`,
    note: "documented as unsupported (S515 notes 6); recorded for completeness",
  },
];

async function testComponent(t: ComponentTest, declared: Set<string> | null) {
  await clearData();
  const iri = t.predicate.startsWith("sh:") && !t.predicate.includes(" ") ? SH + t.predicate.slice(3) : null;
  const load = await loadShapes(PFX + t.shape);
  let bad: any = null, good: any = null;
  if (load.status === 204) {
    bad = brief(await write({ graph: G, turtle: PFX + t.bad, label: `cap ${t.predicate} bad` }, db));
    good = brief(await write({ graph: G, turtle: PFX + t.good, label: `cap ${t.predicate} good` }, db));
  }
  let verdict: string;
  if (load.status !== 204) verdict = "shape refused at load";
  else if (bad.outcome === "rejected" && good.outcome === "committed") verdict = "supported (enforced)";
  else if (bad.outcome === "committed" && good.outcome === "committed") verdict = "NOT enforced (shape accepted, violation stored)";
  else verdict = `unexpected (bad=${bad.outcome}, good=${good.outcome})`;
  return {
    predicate: t.predicate,
    declaredSupported: iri && declared ? declared.has(iri) : null,
    verdict, shapeLoad: load, badWrite: bad, goodWrite: good, note: t.note ?? null,
  };
}

// ---- 2. labelling step and inline VALUES binding
async function testRuleRunner() {
  await clearData();
  const standin = readFixture("shapes/standin-shapes.ttl");
  const load = await loadShapes(standin);
  if (load.status !== 204) return { error: `stand-in shapes did not load: ${JSON.stringify(load)}` };

  const order = (n: string) => `urn:ontara:standin:cafe#cap-order-${n}`;
  const out: any[] = [];
  const ask = (q: string) => db.ask(`PREFIX cafe: <urn:ontara:standin:cafe#> PREFIX rec: <urn:ontara:standin:rec#> ${q}`);

  // Orders written without the rule: all lines Ready, status Placed.
  const plain = (o: string, edit?: (ttl: string) => string) => {
    const w = orderWrite(o, G, { rule: false });
    return { graph: G, turtle: edit ? edit(w.turtle) : w.turtle };
  };
  const ruleAndLabel = (o: string, withLabel = true) => {
    const w = orderWrite(o, G);
    return withLabel ? w.updates : [w.updates[0]];
  };

  // 2a. VALUES binding confines the rule to the bound order.
  const a = order("A"), b = order("B");
  const wa = await write(plain(a), db), wb = await write(plain(b), db);
  const ra = await write({ graph: G, updates: ruleAndLabel(a), label: "cap rule bound to A" }, db);
  const aReady = await ask(`ASK { <${a}> cafe:status cafe:Ready }`);
  const bReady = await ask(`ASK { <${b}> cafe:status cafe:Ready }`);
  const aLabel = await db.select(`PREFIX rec: <urn:ontara:standin:rec#> SELECT ?mode ?method WHERE { <${a}/ready-record> rec:hasRealityMode ?mode ; rec:hasProvenanceMethod ?method }`);
  out.push({
    test: "2a inline VALUES binding: rule bound to order A, order B also eligible",
    setup: [brief(wa), brief(wb)], ruleWrite: brief(ra),
    orderA_Ready: aReady, orderB_Ready: bReady,
    derivedRecordLabel: aLabel.map((x) => ({ mode: x.mode.value, method: x.method.value })),
    pass: ra.outcome === "committed" && aReady && !bReady && aLabel.length === 1,
  });

  // 2b. Labelling picks the weakest input method.
  const c = order("C");
  const wc = await write(plain(c, (t) => t
    .replace(`<${c}/line/2/record> rec:hasProvenanceMethod rec:DirectMethod`, `<${c}/line/2/record> rec:hasProvenanceMethod rec:InferredMethod`)
    .replace(`<${c}/line/3/record> rec:hasProvenanceMethod rec:DirectMethod`, `<${c}/line/3/record> rec:hasProvenanceMethod rec:PredictedMethod`)), db);
  const rc = await write({ graph: G, updates: ruleAndLabel(c), label: "cap weakest method" }, db);
  const cLabel = await db.select(`PREFIX rec: <urn:ontara:standin:rec#> SELECT ?mode ?method WHERE { <${c}/ready-record> rec:hasRealityMode ?mode ; rec:hasProvenanceMethod ?method }`);
  out.push({
    test: "2b labelling: inputs Direct, Inferred, Predicted -> derived record gets PredictedMethod",
    setup: brief(wc), ruleWrite: brief(rc),
    derivedRecordLabel: cLabel.map((x) => ({ mode: x.mode.value, method: x.method.value })),
    pass: rc.outcome === "committed" && cLabel.length === 1 && cLabel[0].method.value.endsWith("PredictedMethod") && cLabel[0].mode.value.endsWith("RealMode"),
  });

  // 2c. Mixed input modes: labelling writes no mode, the record shape rejects, all rolled back.
  const d = order("D");
  const wd = await write(plain(d, (t) => t.replace(`<${d}/line/4/record> rec:hasRealityMode rec:RealMode`, `<${d}/line/4/record> rec:hasRealityMode rec:SimulatedMode`)), db);
  const rd = await write({ graph: G, updates: ruleAndLabel(d), label: "cap mixed modes" }, db);
  const dReady = await ask(`ASK { <${d}> cafe:status cafe:Ready }`);
  const dRec = await ask(`ASK { <${d}/ready-record> ?p ?o }`);
  out.push({
    test: "2c labelling: inputs Real and Simulated -> no mode written -> SHACL rejection, rule output rolled back",
    setup: brief(wd), ruleWrite: brief(rd), orderD_Ready_after: dReady, derivedRecordExists_after: dRec,
    pass: rd.outcome === "rejected" && !dReady && !dRec,
  });

  // 2d. Rule without the labelling step: rejected.
  const e = order("E");
  const we = await write(plain(e), db);
  const re = await write({ graph: G, updates: ruleAndLabel(e, false), label: "cap rule without labelling" }, db);
  out.push({
    test: "2d rule run without the labelling step -> SHACL rejection (derived record has no mode or method)",
    setup: brief(we), ruleWrite: brief(re),
    pass: re.outcome === "rejected",
  });

  // 2e. The whole order write with rule and labelling in one transaction (the load harness's write).
  const f = order("F");
  const wf = await write(orderWrite(f, G), db);
  const fReady = await ask(`ASK { <${f}> cafe:status cafe:Ready . <${f}/ready-record> rec:hasRealityMode rec:RealMode ; rec:hasProvenanceMethod rec:DirectMethod }`);
  out.push({
    test: "2e order write + readiness rule + labelling in one transaction (the load harness write)",
    write: brief(wf), orderF_ReadyAndLabelled: fReady,
    pass: wf.outcome === "committed" && fReady,
  });
  return out;
}

// ---- 3. sh:message in the rejection report
async function testMessages() {
  await clearData();
  const load = await loadShapes(readFixture("shapes/standin-shapes.ttl"));
  const core = await write({ graph: G, turtle: fill(readFixture("writes/known-bad.ttl"), { RUN: "msg" }) }, db);
  // SPARQL constraint: a typed order marked Ready with an open line, in one write.
  const o = "urn:ontara:standin:cafe#cap-order-M";
  const t = orderWrite(o, G, { rule: false }).turtle
    .replace(`<${o}> cafe:status cafe:Placed`, `<${o}> cafe:status cafe:Ready`)
    .replace(`<${o}/line/4> cafe:status cafe:Ready`, `<${o}/line/4> cafe:status cafe:InProgress`);
  const sparql = await write({ graph: G, turtle: t }, db);
  const msgs = (w: WriteOutcome) => (w.outcome === "rejected" ? w.results.map((r) => r.message) : null);
  return {
    shapesLoad: load.status,
    coreShape: { write: brief(core), messages: msgs(core), messageReturned: (msgs(core) ?? []).some((m) => !!m) },
    sparqlConstraint: { write: brief(sparql), messages: msgs(sparql), messageReturned: (msgs(sparql) ?? []).some((m) => !!m) },
  };
}

// ---- 4. observed in passing, useful for S0.5's named-graph scheme
async function testNamedGraphScope() {
  await clearData();
  await loadShapes(readFixture("shapes/standin-shapes.ttl"));
  const bad = await write({ graph: "urn:ontara:stack:graph:capability-other", turtle: fill(readFixture("writes/known-bad.ttl"), { RUN: "ng" }) }, db);
  const sparqlVisible = await db.select(`SELECT (COUNT(*) AS ?n) WHERE { GRAPH <${graphs.shapes}> { ?s ?p ?o } }`);
  const stmts = await db.statements({ graph: graphs.shapes });
  return {
    shapesApplyToDataInAnyNamedGraph: bad.outcome === "rejected",
    shapesGraphTriplesVisibleToSparqlGraphQuery: Number(sparqlVisible[0]?.n?.value ?? 0),
    shapesGraphTriplesViaStatementsApi: stmts.length,
  };
}

// ---- 5. R4: no store-side inference (OP-134 requirements paper, R4; ADR-013)
// Loads a real knowledge-graph module (the platform record module) into a KG
// graph in the scratch repository, writes an instance of a class that has a
// superclass there, and checks that the store added nothing: no rdf:type
// triple for any superclass, and the default graph grows by exactly the
// triples written. The scratch repository is built from the same config as
// the runtime repository, so this tests the runtime repository's ruleset.
async function testNoInference() {
  const RDFS = "http://www.w3.org/2000/01/rdf-schema#";
  const kgGraph = "urn:ontara:stack:kg:ontara-record";
  const cls = "https://ontara.dev/ontology/record/PlatformRecord";
  const inst = "urn:ontara:stack:cap#r4-instance";
  await clearData();
  const kgFile = path.join(paths.kgSource, "ontology/record/ontara-record.ttl");
  const kgLoad = await db.replaceGraph(kgGraph, fs.readFileSync(kgFile, "utf8"), "text/turtle");
  const supers = (await db.select(`SELECT DISTINCT ?sup WHERE { GRAPH <${kgGraph}> { <${cls}> <${RDFS}subClassOf> ?sup . FILTER (isIRI(?sup)) } }`)).map((b) => b.sup.value as string);
  const count = async () => Number((await db.select(`SELECT (COUNT(*) AS ?n) WHERE { ?s ?p ?o }`))[0].n.value);
  const before = await count();
  const turtle = `<${inst}> a <${cls}> ; <${RDFS}label> "R4 check instance" .`;
  const written = 2;
  const w = await write({ graph: G, turtle, label: "cap R4 no inference" }, db);
  const after = await count();
  const values = supers.map((s) => `<${s}>`).join(" ");
  const superTypeTriples = supers.length
    ? (await db.select(`SELECT DISTINCT ?sup WHERE { VALUES ?sup { ${values} } { <${inst}> a ?sup } UNION { GRAPH ?g { <${inst}> a ?sup } } }`)).map((b) => b.sup.value)
    : [];
  const aboutInstance = (await db.select(`SELECT DISTINCT ?p ?o WHERE { { <${inst}> ?p ?o } UNION { GRAPH ?g { <${inst}> ?p ?o } } }`)).length;
  // Clean the KG graph out of the scratch repository again.
  await db.update(`CLEAR SILENT GRAPH <${kgGraph}>`);
  const pass = w.outcome === "committed" && supers.length > 0 && superTypeTriples.length === 0 && after - before === written && aboutInstance === written;
  return {
    test: "R4: a write of an instance of a class with a superclass in the knowledge graph produces no extra triples",
    kgModule: "ontology/record/ontara-record.ttl", kgLoadStatus: kgLoad.status,
    class: cls, superclassesInKg: supers,
    write: brief(w), triplesWritten: written,
    defaultGraphCountBefore: before, defaultGraphCountAfter: after, defaultGraphDelta: after - before,
    triplesAboutInstance: aboutInstance, superclassTypeTriplesFound: superTypeTriples,
    pass,
  };
}

async function main() {
  const startedAt = new Date().toISOString();
  const declaredPath = path.join(paths.results, "shacl-supported-predicates.json");
  let declaredJson: any = null;
  let declared: Set<string> | null = null;
  if (fs.existsSync(declaredPath)) {
    declaredJson = JSON.parse(fs.readFileSync(declaredPath, "utf8"));
    declared = new Set(declaredJson.predicates);
  } else {
    console.warn(`WARNING: ${declaredPath} missing; run bin/capabilities.sh, not this script directly`);
  }

  // scratch repository
  const repos = await base.listRepositories();
  if (repos.includes(SCRATCH)) await base.deleteRepository(SCRATCH);
  const cr = await base.createRepository(await shaclRepositoryConfig(base, SCRATCH, "S0.1 capability checks (scratch, deleted after)"));
  if (cr.status !== 201) throw new Error(`create ${SCRATCH}: HTTP ${cr.status} ${cr.body}`);
  const cfg = await base.repositoryConfig(SCRATCH);
  if (param(cfg, "isShacl") !== "true") throw new Error(`${SCRATCH} isShacl=${param(cfg, "isShacl")}`);

  const result: any = { startedAt, graphdb: await base.version(), scratchRepository: SCRATCH, runtimeRepositoryTouched: false };
  try {
    const asked = ["equals", "disjoint", "lessThan", "closed"].map((p) => SH + p);
    result.item1_declared = declared ? {
      source: declaredJson.source, rdf4j: declaredJson.rdf4jShaclJarVersion,
      asked: Object.fromEntries(asked.map((p) => ["sh:" + p.slice(SH.length), declared!.has(p)])),
      alsoAbsent: ["xone", "zeroOrMorePath", "oneOrMorePath", "zeroOrOnePath", "rule", "ask"].filter((p) => !declared!.has(SH + p)).map((p) => "sh:" + p),
    } : null;
    result.item1_empirical = [];
    for (const t of componentTests) {
      const r = await testComponent(t, declared);
      console.log(`[cap] ${t.predicate}: declared=${r.declaredSupported} -> ${r.verdict}`);
      result.item1_empirical.push(r);
    }
    result.item2_ruleRunner = await testRuleRunner();
    for (const r of result.item2_ruleRunner) console.log(`[cap] ${r.pass ? "PASS" : "FAIL"} ${r.test}`);
    result.item3_messages = await testMessages();
    console.log(`[cap] sh:message returned: core=${result.item3_messages.coreShape.messageReturned} sparql=${result.item3_messages.sparqlConstraint.messageReturned}`);
    result.item4_namedGraphs = await testNamedGraphScope();
    console.log(`[cap] named graphs: ${JSON.stringify(result.item4_namedGraphs)}`);
    result.item5_noInference = await testNoInference();
    result.item5_noInference.runtimeRepositoryRuleset = param(await base.repositoryConfig(config.repository), "ruleset");
    result.item5_noInference.scratchRepositoryRuleset = param(cfg, "ruleset");
    console.log(`[cap] ${result.item5_noInference.pass ? "PASS" : "FAIL"} R4 no store-side inference: ruleset=${result.item5_noInference.scratchRepositoryRuleset} (runtime ${result.item5_noInference.runtimeRepositoryRuleset}), delta=${result.item5_noInference.defaultGraphDelta} for ${result.item5_noInference.triplesWritten} written, superclass types=${JSON.stringify(result.item5_noInference.superclassTypeTriplesFound)}`);
  } finally {
    const d = await base.deleteRepository(SCRATCH);
    result.scratchDeleted = d.status === 200 || d.status === 204;
  }
  result.finishedAt = new Date().toISOString();

  fs.writeFileSync(path.join(paths.results, "shacl-capabilities.json"), JSON.stringify(result, null, 2) + "\n");
  fs.writeFileSync(path.join(paths.results, "shacl-capabilities.md"), markdown(result));
  console.log(`[cap] written results/shacl-capabilities.json and results/shacl-capabilities.md`);
  // R4 is a binding requirement, not a component survey: a failure fails the script.
  if (!result.item5_noInference?.pass) { console.error(`[cap] R4 CHECK FAILED: the store added triples a declared writer did not write`); process.exitCode = 1; }
}

function markdown(r: any): string {
  const L: string[] = [];
  L.push(`# SHACL capability checks (S0.1)`, ``);
  L.push(`Generated by \`stack/bin/capabilities.sh\` at ${r.finishedAt}. GraphDB ${r.graphdb.productVersion} (${r.graphdb.productType}), RDF4J ${r.graphdb.sesame}. Scratch repository \`${r.scratchRepository}\`, deleted after: ${r.scratchDeleted}. Full detail: \`shacl-capabilities.json\`.`, ``);
  L.push(`## 1. Components`, ``, `| Component | In getSupportedShaclPredicates() | Tested behaviour |`, `|---|---|---|`);
  for (const t of r.item1_empirical) L.push(`| ${t.predicate} | ${t.declaredSupported === null ? "n/a" : t.declaredSupported ? "yes" : "**no**"} | ${t.verdict} |`);
  if (r.item1_declared) L.push(``, `Also absent from the declared list: ${r.item1_declared.alsoAbsent.join(", ")}.`);
  L.push(``, `## 2. Labelling step and inline VALUES binding`, ``, `| Test | Result |`, `|---|---|`);
  for (const t of r.item2_ruleRunner) L.push(`| ${t.test} | ${t.pass ? "pass" : "**FAIL**"} |`);
  const m = r.item3_messages;
  L.push(``, `## 3. sh:message in the rejection report`, ``);
  L.push(`1. Core shape: message returned = **${m.coreShape.messageReturned}** (${JSON.stringify(m.coreShape.messages)}).`);
  L.push(`2. SHACL-SPARQL constraint: message returned = **${m.sparqlConstraint.messageReturned}** (${JSON.stringify(m.sparqlConstraint.messages)}).`);
  const n = r.item4_namedGraphs;
  L.push(``, `## 4. Named graphs (observed, for S0.5)`, ``);
  L.push(`1. Shapes apply to data written into any named graph: ${n.shapesApplyToDataInAnyNamedGraph}.`);
  L.push(`2. The shapes graph is visible to a SPARQL \`GRAPH\` query: ${n.shapesGraphTriplesVisibleToSparqlGraphQuery} triples; through the RDF4J statements API: ${n.shapesGraphTriplesViaStatementsApi} triples.`);
  const i = r.item5_noInference;
  if (i) {
    L.push(``, `## 5. R4: no store-side inference`, ``);
    L.push(`Result: **${i.pass ? "pass" : "FAIL"}**. Scratch repository ruleset \`${i.scratchRepositoryRuleset}\`; runtime repository ruleset \`${i.runtimeRepositoryRuleset}\`.`, ``);
    L.push(`1. Knowledge-graph module loaded: \`${i.kgModule}\`; \`<${i.class}>\` has superclasses ${i.superclassesInKg.map((s: string) => `\`<${s}>\``).join(", ")}.`);
    L.push(`2. Written: ${i.triplesWritten} triples (the instance's type and label), outcome ${i.write.outcome}.`);
    L.push(`3. Default-graph triple count grew by ${i.defaultGraphDelta} (${i.defaultGraphCountBefore} to ${i.defaultGraphCountAfter}); triples about the instance: ${i.triplesAboutInstance}.`);
    L.push(`4. \`rdf:type\` triples for a superclass found: ${i.superclassTypeTriplesFound.length ? i.superclassTypeTriplesFound.map((s: string) => `\`<${s}>\``).join(", ") : "none"}.`);
  }
  return L.join("\n") + "\n";
}

main().catch((e) => { console.error(e); process.exit(1); });
