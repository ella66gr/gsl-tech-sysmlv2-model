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
import { write, WriteOutcome, runtimeStore } from "../gate";
import { isNotApplicable } from "../store";
import { config, graphs, paths } from "../config";
import { readFixture, orderWrite, fill } from "../fixtures";

const SCRATCH = "cafe-capability-scratch";
const SH = "http://www.w3.org/ns/shacl#";
const G = graphs.capability;
// OP-134 spike (B1): through the store interface. The scratch repository is
// created by the adapter (GraphDB: JSON default config; RDF4J: native-shacl
// template; Fuseki and Oxigraph: a pre-provisioned dataset, cleared).
const base = runtimeStore();
const db = base.withRepo(SCRATCH);
const OUT = path.join(paths.results, config.capabilityOutDir);

const PFX = `@prefix sh: <${SH}> . @prefix ex: <urn:ontara:stack:cap#> . @prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> . @prefix xsd: <http://www.w3.org/2001/XMLSchema#> .\n`;

function brief(o: WriteOutcome) {
  if (o.outcome === "committed") return { outcome: o.outcome };
  if (o.outcome === "rejected") return { outcome: o.outcome, shapes: o.shapes, nodeShapes: o.nodeShapes, components: o.results.map((r) => r.component), messages: o.results.map((r) => r.message), rolledBack: o.rolledBack };
  return { outcome: o.outcome, stage: o.stage, httpStatus: o.httpStatus, detail: o.detail.slice(0, 400) };
}

async function loadShapes(ttl: string) {
  const r = await db.replaceGraph(db.shapesGraph, ttl, "text/turtle");
  return { status: r.status, ok: r.ok, body: r.ok ? "" : r.body.slice(0, 600) };
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
  {
    predicate: "sh:oneOrMorePath",
    shape: `ex:PlusShape a sh:NodeShape ; sh:targetClass ex:PlusT ; sh:property [ sh:path [ sh:oneOrMorePath ex:p ] ; sh:maxCount 1 ] .`,
    bad: `ex:pl1 a ex:PlusT ; ex:p ex:pl1b . ex:pl1b ex:p ex:pl1c .`,
    good: `ex:pl2 a ex:PlusT ; ex:p ex:pl2b .`,
    note: "OP-134 spike: absent from GraphDB's declared list",
  },
  {
    predicate: "sh:zeroOrOnePath",
    shape: `ex:OptShape a sh:NodeShape ; sh:targetClass ex:OptT ; sh:property [ sh:path [ sh:zeroOrOnePath ex:p ] ; sh:maxCount 1 ] .`,
    bad: `ex:op1 a ex:OptT ; ex:p ex:op1b .`,
    good: `ex:op2 a ex:OptT .`,
    note: "OP-134 spike: absent from GraphDB's declared list. The path reaches the node itself plus ex:p, so one ex:p value makes two values",
  },
  {
    predicate: "sh:inversePath",
    shape: `ex:InvShape a sh:NodeShape ; sh:targetClass ex:InvT ; sh:property [ sh:path [ sh:inversePath ex:p ] ; sh:maxCount 1 ] .`,
    bad: `ex:in1 a ex:InvT . ex:in1a ex:p ex:in1 . ex:in1b ex:p ex:in1 .`,
    good: `ex:in2 a ex:InvT . ex:in2a ex:p ex:in2 .`,
    note: "OP-134 spike: in GraphDB's declared list; tested beside the other paths",
  },
  {
    predicate: "sh:ask",
    shape: `ex:PositiveComponent a sh:ConstraintComponent ; sh:parameter [ sh:path ex:positive ] ; sh:propertyValidator [ a sh:SPARQLAskValidator ; sh:message "must be positive" ; sh:ask "ASK { FILTER ($value > 0) }" ] . ex:AskShape a sh:NodeShape ; sh:targetClass ex:AskT ; sh:property [ sh:path ex:v ; ex:positive true ] .`,
    bad: `ex:ak1 a ex:AskT ; ex:v -1 .`,
    good: `ex:ak2 a ex:AskT ; ex:v 5 .`,
    note: "OP-134 spike: SHACL-SPARQL custom constraint component with an ASK validator; absent from GraphDB's declared list",
  },
];

async function testComponent(t: ComponentTest, declared: Set<string> | null) {
  await clearData();
  const iri = t.predicate.startsWith("sh:") && !t.predicate.includes(" ") ? SH + t.predicate.slice(3) : null;
  const load = await loadShapes(PFX + t.shape);
  let bad: any = null, good: any = null;
  if (load.ok) {
    bad = brief(await write({ graph: G, turtle: PFX + t.bad, label: `cap ${t.predicate} bad` }, db));
    good = brief(await write({ graph: G, turtle: PFX + t.good, label: `cap ${t.predicate} good` }, db));
  }
  let verdict: string;
  if (!load.ok) verdict = "shape refused at load";
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
  if (!load.ok) return { error: `stand-in shapes did not load: ${JSON.stringify(load)}` };

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
  const sparqlVisible = await db.shapesGraphSparqlCount();
  const stmts = await db.shapesTriples();
  // A shape placed in an ordinary named graph (not the store's shapes graph):
  // is it enforced? Tells whether the shapes graph is the only place shapes live.
  await clearData();
  const elsewhere = "urn:ontara:stack:graph:capability-shapes-elsewhere";
  const placed = await db.replaceGraph(elsewhere, PFX + `ex:ElseShape a sh:NodeShape ; sh:targetClass ex:ElseT ; sh:property [ sh:path ex:a ; sh:minCount 1 ] .`, "text/turtle");
  const elseBad = await write({ graph: G, turtle: PFX + `ex:else1 a ex:ElseT .`, label: "cap shape elsewhere" }, db);
  await db.update(`CLEAR SILENT GRAPH <${elsewhere}>`);
  return {
    shapesApplyToDataInAnyNamedGraph: bad.outcome === "rejected",
    shapesGraph: db.shapesGraph,
    shapesGraphTriplesVisibleToSparqlGraphQuery: sparqlVisible,
    shapesGraphTriplesViaStatementsApi: stmts,
    shapesGraphReadRoute: db.kind === "graphdb" || db.kind === "rdf4j" ? "RDF4J statements API (getStatements, context=shapes graph)" : "SPARQL GRAPH query on an ordinary named graph",
    shapeInOrdinaryNamedGraphEnforced: placed.ok ? elseBad.outcome === "rejected" : `shape not placed: HTTP ${placed.status}`,
  };
}

// ---- 6. The S515 five-case in-transaction test (S515 step 1 notes §2.2), on
// the stand-in record shape (the same mode-and-method shape, stand-in names).
async function testS515FiveCase() {
  await clearData();
  const load = await loadShapes(readFixture("shapes/standin-shapes.ttl"));
  const REC = `@prefix rec: <urn:ontara:standin:rec#> . @prefix c: <urn:ontara:stack:cap:s515#> .\n`;
  const ask = (q: string) => db.ask(`PREFIX rec: <urn:ontara:standin:rec#> PREFIX c: <urn:ontara:stack:cap:s515#> ${q}`);
  const cases: any[] = [];
  const run = async (name: string, req: any, expect: "committed" | "rejected") => {
    const o = await write({ graph: G, label: `cap s515 ${name}`, ...req }, db);
    cases.push({ case: name, expect, write: brief(o), pass: o.outcome === expect });
  };
  await run("good: record with one mode, one method", { turtle: REC + `c:rec1 a rec:PlatformRecord ; rec:hasRealityMode rec:RealMode ; rec:hasProvenanceMethod rec:DirectMethod .` }, "committed");
  await run("bad A: no method", { turtle: REC + `c:rec2 a rec:PlatformRecord ; rec:hasRealityMode rec:RealMode .` }, "rejected");
  await run("bad B: two modes", { turtle: REC + `c:rec3 a rec:PlatformRecord ; rec:hasRealityMode rec:RealMode , rec:SimulatedMode ; rec:hasProvenanceMethod rec:DirectMethod .` }, "rejected");
  await run("bad C: second method added to an existing good record", { turtle: REC + `c:rec1 rec:hasProvenanceMethod rec:InferredMethod .` }, "rejected");
  await run("bad D: method outside the allowed list", { turtle: REC + `c:rec4 a rec:PlatformRecord ; rec:hasRealityMode rec:RealMode ; rec:hasProvenanceMethod rec:GuessedMethod .` }, "rejected");
  await run("bad E: deleting the only method of an existing record", { updates: [`PREFIX rec: <urn:ontara:standin:rec#> DELETE DATA { GRAPH <${G}> { <urn:ontara:stack:cap:s515#rec1> rec:hasProvenanceMethod rec:DirectMethod } }`] }, "rejected");
  await run("mixed F: good rec5 and bad rec6 in one request", { turtle: REC + `c:rec5 a rec:PlatformRecord ; rec:hasRealityMode rec:RealMode ; rec:hasProvenanceMethod rec:DirectMethod . c:rec6 a rec:PlatformRecord ; rec:hasRealityMode rec:RealMode .` }, "rejected");
  const after = {
    rec1IntactWithOriginalModeAndMethod: await ask(`ASK { c:rec1 rec:hasRealityMode rec:RealMode ; rec:hasProvenanceMethod rec:DirectMethod . FILTER NOT EXISTS { c:rec1 rec:hasProvenanceMethod rec:InferredMethod } }`),
    anyOfRec2to6Stored: await ask(`ASK { VALUES ?r { c:rec2 c:rec3 c:rec4 c:rec5 c:rec6 } ?r ?p ?o }`),
  };
  return { shapesLoad: load.status, cases, after, pass: cases.every((c) => c.pass) && after.rec1IntactWithOriginalModeAndMethod && !after.anyOfRec2to6Stored };
}

// ---- 7. SHACL-SPARQL re-check when a write does not touch the target (S515 notes §2.4):
// an existing Ready order has one line set back to InProgress, line triple only.
async function testSparqlNonTargetChange() {
  await clearData();
  await loadShapes(readFixture("shapes/standin-shapes.ttl"));
  const o = "urn:ontara:standin:cafe#cap-order-N";
  const setup = await write(orderWrite(o, G), db); // order + rule + labelling: Ready
  const flip = (bulk: boolean) => write({ graph: G, validation: bulk ? "bulk" : "normal", label: `cap line-only ${bulk ? "bulk" : "normal"}`,
    updates: [`PREFIX cafe: <urn:ontara:standin:cafe#> DELETE DATA { GRAPH <${G}> { <${o}/line/4> cafe:status cafe:Ready } } ; INSERT DATA { GRAPH <${G}> { <${o}/line/4> cafe:status cafe:InProgress } }`] }, db);
  const normal = await flip(false);
  let bulk: WriteOutcome | null = null;
  if (normal.outcome === "committed") {
    // put the line back (unchecked direction), then try again under Bulk
    await write({ graph: G, updates: [`PREFIX cafe: <urn:ontara:standin:cafe#> DELETE DATA { GRAPH <${G}> { <${o}/line/4> cafe:status cafe:InProgress } } ; INSERT DATA { GRAPH <${G}> { <${o}/line/4> cafe:status cafe:Ready } }`] }, db);
    bulk = await flip(true);
  }
  return {
    setup: brief(setup),
    lineOnlyChangeNormal: brief(normal), caughtNormal: normal.outcome === "rejected",
    lineOnlyChangeBulk: bulk ? brief(bulk) : "not run (normal already caught it)", caughtBulk: bulk ? bulk.outcome === "rejected" : null,
  };
}

// ---- 8. sh:rule (SHACL Advanced Features): does the store execute a triple rule?
// If it does, that is store-side derivation, which R4 forbids.
async function testShRule() {
  await clearData();
  const load = await loadShapes(PFX + `ex:RuleShape a sh:NodeShape ; sh:targetClass ex:RuleT ; sh:rule [ a sh:TripleRule ; sh:subject sh:this ; sh:predicate ex:derived ; sh:object true ] .`);
  const w = load.ok ? await write({ graph: G, turtle: PFX + `ex:ru1 a ex:RuleT .`, label: "cap sh:rule" }, db) : null;
  const derived = load.ok ? await db.ask(`ASK { { <urn:ontara:stack:cap#ru1> <urn:ontara:stack:cap#derived> ?o } UNION { GRAPH ?g { <urn:ontara:stack:cap#ru1> <urn:ontara:stack:cap#derived> ?o } } }`) : null;
  return {
    predicate: "sh:rule", shapeLoad: load, write: w ? brief(w) : null,
    verdict: !load.ok ? "shape refused at load" : derived ? "EXECUTED (the store derived a triple: store-side derivation)" : "not executed (rule ignored; no triple derived)",
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
  fs.mkdirSync(OUT, { recursive: true });
  const declaredPath = path.join(OUT, "shacl-supported-predicates.json");
  let declaredJson: any = null;
  let declared: Set<string> | null = null;
  if (fs.existsSync(declaredPath)) {
    declaredJson = JSON.parse(fs.readFileSync(declaredPath, "utf8"));
    declared = declaredJson.applicable === false ? null : new Set(declaredJson.predicates);
  } else {
    console.warn(`WARNING: ${declaredPath} missing; run bin/capabilities.sh, not this script directly`);
  }

  // scratch repository
  const repos = await base.listRepositories();
  if (repos.includes(SCRATCH)) await base.deleteRepository(SCRATCH);
  const cr = await base.createRepository(SCRATCH, "S0.1 capability checks (scratch, deleted after)");
  if (!cr.ok) throw new Error(`create ${SCRATCH}: HTTP ${cr.status} ${cr.body}`);
  const cfg = await base.readBack(SCRATCH);
  if (cfg.shacl !== "true") throw new Error(`${SCRATCH} isShacl=${cfg.shacl}`);

  const result: any = { startedAt, store: { kind: base.kind, ...(await base.info()) }, scratchRepository: SCRATCH, scratchCreation: cr.note ?? null, scratchReadBack: cfg.line, runtimeRepositoryTouched: false };
  if (declaredJson?.applicable === false) result.item1_declaredNotApplicable = declaredJson.reason;
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
    result.item5_noInference.runtimeRepositoryRuleset = (await base.readBack()).inference;
    result.item5_noInference.scratchRepositoryRuleset = cfg.inference;
    result.item6_s515FiveCase = await testS515FiveCase();
    console.log(`[cap] ${result.item6_s515FiveCase.pass ? "PASS" : "FAIL"} S515 five-case in-transaction test: ${result.item6_s515FiveCase.cases.map((c: any) => `${c.case.split(":")[0]}=${c.write.outcome}`).join(" ")}; after=${JSON.stringify(result.item6_s515FiveCase.after)}`);
    result.item7_sparqlNonTargetChange = await testSparqlNonTargetChange();
    console.log(`[cap] SHACL-SPARQL line-only change caught: normal=${result.item7_sparqlNonTargetChange.caughtNormal} bulk=${result.item7_sparqlNonTargetChange.caughtBulk}`);
    result.item8_shRule = await testShRule();
    console.log(`[cap] sh:rule: ${result.item8_shRule.verdict}`);
    console.log(`[cap] ${result.item5_noInference.pass ? "PASS" : "FAIL"} R4 no store-side inference: ruleset=${result.item5_noInference.scratchRepositoryRuleset} (runtime ${result.item5_noInference.runtimeRepositoryRuleset}), delta=${result.item5_noInference.defaultGraphDelta} for ${result.item5_noInference.triplesWritten} written, superclass types=${JSON.stringify(result.item5_noInference.superclassTypeTriplesFound)}`);
  } finally {
    const d = await base.deleteRepository(SCRATCH);
    result.scratchDeleted = d.ok;
  }
  result.finishedAt = new Date().toISOString();

  fs.writeFileSync(path.join(OUT, "shacl-capabilities.json"), JSON.stringify(result, null, 2) + "\n");
  fs.writeFileSync(path.join(OUT, "shacl-capabilities.md"), markdown(result));
  console.log(`[cap] written ${path.relative(config.stackDir, OUT)}/shacl-capabilities.json and shacl-capabilities.md`);
  // R4 is a binding requirement, not a component survey: a failure fails the script.
  if (!result.item5_noInference?.pass) { console.error(`[cap] R4 CHECK FAILED: the store added triples a declared writer did not write`); process.exitCode = 1; }
}

function markdown(r: any): string {
  const L: string[] = [];
  L.push(`# SHACL capability checks (S0.1)`, ``);
  L.push(`Generated by \`stack/bin/capabilities.sh\` at ${r.finishedAt}. Store: ${r.store.product}; SHACL engine: ${r.store.shaclEngine}. Scratch repository \`${r.scratchRepository}\`${r.scratchCreation ? ` (${r.scratchCreation})` : ""}, deleted after: ${r.scratchDeleted}. Full detail: \`shacl-capabilities.json\`.`, ``);
  L.push(`## 1. Components`, ``, `| Component | In getSupportedShaclPredicates() | Tested behaviour |`, `|---|---|---|`);
  for (const t of r.item1_empirical) L.push(`| ${t.predicate} | ${t.declaredSupported === null ? "n/a" : t.declaredSupported ? "yes" : "**no**"} | ${t.verdict} |`);
  if (r.item1_declared) L.push(``, `Also absent from the declared list: ${r.item1_declared.alsoAbsent.join(", ")}.`);
  if (r.item1_declaredNotApplicable) L.push(``, `Declared list: not applicable (${r.item1_declaredNotApplicable}).`);
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
  if (n.shapesGraph) L.push(``, `Named graphs, further (OP-134 spike): shapes graph \`<${n.shapesGraph}>\`, read through ${n.shapesGraphReadRoute}; a shape placed in an ordinary named graph is enforced: ${n.shapeInOrdinaryNamedGraphEnforced}.`);
  const f = r.item6_s515FiveCase;
  if (f) {
    L.push(``, `## 6. The S515 five-case in-transaction test`, ``, `Result: **${f.pass ? "pass" : "FAIL"}**.`, ``, `| Case | Expected | Outcome |`, `|---|---|---|`);
    for (const c of f.cases) L.push(`| ${c.case} | ${c.expect} | ${c.write.outcome}${c.pass ? "" : " **(unexpected)**"} |`);
    L.push(``, `After: rec1 intact with its original mode and method = ${f.after.rec1IntactWithOriginalModeAndMethod}; any of rec2 to rec6 stored = ${f.after.anyOfRec2to6Stored}.`);
  }
  const x = r.item7_sparqlNonTargetChange;
  if (x) L.push(``, `## 7. SHACL-SPARQL re-check on a write that does not touch the target`, ``, `An existing Ready order has one line set back to InProgress (line triple only). Caught under normal validation: **${x.caughtNormal}**; under Bulk: **${x.caughtBulk === null ? "not run" : x.caughtBulk}**.`);
  const ru = r.item8_shRule;
  if (ru) L.push(``, `## 8. sh:rule (SHACL Advanced Features)`, ``, `${ru.verdict}.`);
  return L.join("\n") + "\n";
}

main().catch((e) => { console.error(e); process.exit(1); });
