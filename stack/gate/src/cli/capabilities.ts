// SHACL capability checks (S0.1, specification 2.5 item 7; S515 paper 7 item 3).
// Run by stack/bin/capabilities.sh, once per validation mode: against the
// stack's store (targeted) and against a second, short-lived container of the
// same image started with ONTARA_VALIDATION=whole (whole). Then
// `--combine` writes one table of both.
//
// Everything runs in the capability scratch dataset (cafe-capability-scratch,
// emptied before and after), never in the runtime dataset. Writes go through
// the gate's own write path (in-process), and so through the module's
// validated-update endpoint. Every validated write's X-Ontara-Validation
// header is checked against the mode expected (--mode).
//
//   1. per SHACL component a Stage 0 shape may use: a shape, a violating write
//      (rejected expected) and a conforming one (committed expected). Fuseki
//      has no counterpart to GraphDB's getSupportedShaclPredicates(), and an
//      enforcement test is the stronger check (specification 2.5 item 7.1).
//   2. the labelling step and the inline VALUES binding a mapping rule needs.
//   3. whether a core shape's sh:message (and a SPARQL constraint's) comes back
//      in the module's rejection report.
//   4. named-graph observations, for S0.5.  5. R4, no store-side inference.
//   6. the S515 five-case in-transaction test.  7. the stand-in SPARQL
//      constraint's line-only case.  8. sh:rule.  9. Cyril's two-sided
//      readiness shapes (S519), with the rest of the runtime shapes.
// An unenforced component is a result, not a failure (input to S0.6).
//
// Since S0.5 Pass B8 the order write (fixtures/writes/order-54.ttl), the
// readiness rule and the readiness shapes carry axis values as the generated
// predicates and value IRIs (ontara-cafe:orderLifecycle, orderPayment,
// orderLinePreparation), and items 2, 3, 7 and 9 read and write them so.
//
//   node dist/cli/capabilities.js --out <dir under results/> --mode targeted|whole
//   node dist/cli/capabilities.js --combine <dir under results/>
import * as fs from "node:fs";
import * as path from "node:path";
import { write as gateWrite, WriteOutcome } from "../gate";
import { openStore, SCRATCH_DATASET, WriteRequest, Store } from "../store";
import { config, graphs, paths, validatedAs, RUNTIME_SHAPE_FILES } from "../config";
import { readFixture, readStackFile, orderWrite, fill } from "../fixtures";

const args = process.argv.slice(2);
const opt = (n: string, d: string) => { const i = args.indexOf(n); return i >= 0 ? args[i + 1] : d; };
const MODE = opt("--mode", config.expectedValidationMode);
const SCRATCH = SCRATCH_DATASET;
const SH = "http://www.w3.org/ns/shacl#";
const G = graphs.capability;
const base = openStore();
const db = base.withDataset(SCRATCH);
const OUT = path.join(paths.results, opt("--out", "capabilities"));

// Every validated write, with how the module validated it.
const seen: { label: string; outcome: string; validation: string | null }[] = [];
async function write(req: WriteRequest, s: Store): Promise<WriteOutcome> {
  const o = await gateWrite(req, s);
  seen.push({ label: req.label ?? "", outcome: o.outcome, validation: o.validation });
  return o;
}

const PFX = `@prefix sh: <${SH}> . @prefix ex: <urn:ontara:stack:cap#> . @prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> . @prefix xsd: <http://www.w3.org/2001/XMLSchema#> .\n`;

// The Cafe's axis vocabulary (S0.5 Pass B8): an order's lifecycle and a line's
// preparation, each its own generated predicate with its own value IRIs.
const OC = "https://ontara.dev/ontology/tenant/cafe/";
const Q_PFX = `PREFIX cafe: <urn:ontara:standin:cafe#> PREFIX rec: <urn:ontara:standin:rec#> PREFIX ontara-cafe: <${OC}> `;
const isLine = (s: string) => s.includes("/line/");
const axisOf = (s: string) => (isLine(s) ? { p: `${OC}orderLinePreparation`, v: `${OC}OrderLinePreparation-` } : { p: `${OC}orderLifecycle`, v: `${OC}OrderLifecycle-` });
// One axis move as one request: DELETE DATA of the old value, INSERT DATA of the new.
const setAxis = (s: string, from: string, to: string) => { const a = axisOf(s); return `DELETE DATA { GRAPH <${G}> { <${s}> <${a.p}> <${a.v}${from}> } } ; INSERT DATA { GRAPH <${G}> { <${s}> <${a.p}> <${a.v}${to}> } }`; };
// The order's lifecycle triple and a line's preparation triple as the order write's Turtle has them.
const lifecycleLine = (o: string, v: string) => `<${o}> ontara-cafe:orderLifecycle ontara-cafe:OrderLifecycle-${v} .`;
const preparationLine = (line: string, v: string) => `<${line}> ontara-cafe:orderLinePreparation ontara-cafe:OrderLinePreparation-${v} .`;

// `validation`: how the store validated the write, where the adapter says
// (the Fuseki module's X-Ontara-Validation header, S519); absent otherwise.
function brief(o: WriteOutcome) {
  const v = { validation: o.validation };
  if (o.outcome === "committed") return { outcome: o.outcome, ...v };
  if (o.outcome === "rejected") return { outcome: o.outcome, shapes: o.shapes, nodeShapes: o.nodeShapes, components: o.results.map((r) => r.component), messages: o.results.map((r) => r.message), rolledBack: o.rolledBack, ...v };
  return { outcome: o.outcome, stage: o.stage, httpStatus: o.httpStatus, detail: o.detail.slice(0, 400), ...v };
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
    note: "not in the S515 paper's list; tested because GraphDB's ShaclSail did not enforce it (S517)",
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
    note: "documented as unsupported by GraphDB (S515 notes 6); recorded for completeness",
  },
  {
    predicate: "sh:oneOrMorePath",
    shape: `ex:PlusShape a sh:NodeShape ; sh:targetClass ex:PlusT ; sh:property [ sh:path [ sh:oneOrMorePath ex:p ] ; sh:maxCount 1 ] .`,
    bad: `ex:pl1 a ex:PlusT ; ex:p ex:pl1b . ex:pl1b ex:p ex:pl1c .`,
    good: `ex:pl2 a ex:PlusT ; ex:p ex:pl2b .`,
    note: "OP-134 spike: GraphDB's ShaclSail did not enforce it",
  },
  {
    predicate: "sh:zeroOrOnePath",
    shape: `ex:OptShape a sh:NodeShape ; sh:targetClass ex:OptT ; sh:property [ sh:path [ sh:zeroOrOnePath ex:p ] ; sh:maxCount 1 ] .`,
    bad: `ex:op1 a ex:OptT ; ex:p ex:op1b .`,
    good: `ex:op2 a ex:OptT .`,
    note: "OP-134 spike: GraphDB's ShaclSail did not enforce it. The path reaches the node itself plus ex:p, so one ex:p value makes two values",
  },
  {
    predicate: "sh:inversePath",
    shape: `ex:InvShape a sh:NodeShape ; sh:targetClass ex:InvT ; sh:property [ sh:path [ sh:inversePath ex:p ] ; sh:maxCount 1 ] .`,
    bad: `ex:in1 a ex:InvT . ex:in1a ex:p ex:in1 . ex:in1b ex:p ex:in1 .`,
    good: `ex:in2 a ex:InvT . ex:in2a ex:p ex:in2 .`,
    note: "OP-134 spike: tested beside the other paths",
  },
  {
    predicate: "sh:ask",
    shape: `ex:PositiveComponent a sh:ConstraintComponent ; sh:parameter [ sh:path ex:positive ] ; sh:propertyValidator [ a sh:SPARQLAskValidator ; sh:message "must be positive" ; sh:ask "ASK { FILTER ($value > 0) }" ] . ex:AskShape a sh:NodeShape ; sh:targetClass ex:AskT ; sh:property [ sh:path ex:v ; ex:positive true ] .`,
    bad: `ex:ak1 a ex:AskT ; ex:v -1 .`,
    good: `ex:ak2 a ex:AskT ; ex:v 5 .`,
    note: "OP-134 spike: SHACL-SPARQL custom constraint component with an ASK validator; GraphDB's ShaclSail did not enforce it",
  },
];

async function testComponent(t: ComponentTest) {
  await clearData();
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
  const ask = (q: string) => db.ask(`${Q_PFX} ${q}`);
  const READY = "ontara-cafe:orderLifecycle ontara-cafe:OrderLifecycle-ready";

  // Orders written without the rule: in preparation and paid, all lines ready.
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
  const aReady = await ask(`ASK { <${a}> ${READY} }`);
  const bReady = await ask(`ASK { <${b}> ${READY} }`);
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
  const dReady = await ask(`ASK { <${d}> ${READY} }`);
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
  const fReady = await ask(`ASK { <${f}> ${READY} . <${f}/ready-record> rec:hasRealityMode rec:RealMode ; rec:hasProvenanceMethod rec:DirectMethod }`);
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
  // SPARQL constraint: a typed order marked ready with a line in preparation, in one write.
  const o = "urn:ontara:standin:cafe#cap-order-M";
  const w0 = orderWrite(o, G, { rule: false }).turtle;
  if (!w0.includes(lifecycleLine(o, "inPreparation")) || !w0.includes(preparationLine(`${o}/line/4`, "ready"))) throw new Error("item 3: the order fixture no longer has the lines this test edits");
  const t = w0
    .replace(lifecycleLine(o, "inPreparation"), lifecycleLine(o, "ready"))
    .replace(preparationLine(`${o}/line/4`, "ready"), preparationLine(`${o}/line/4`, "inPreparation"));
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
  const sparqlVisible = await db.shapesTriples();
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
    shapesGraphReadRoute: "SPARQL GRAPH query on an ordinary named graph",
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

// ---- 7. The stand-in SPARQL constraint's line-only case (S515 notes §2.4; ADR-014 §4.3):
// an existing ready order has one line set back to in preparation, line
// triple only. Whole mode catches it; targeted mode does not, because the write does
// not touch the order the constraint targets. Expected, and the reason the
// load harness uses the two-sided shapes (S521).
async function testSparqlNonTargetChange() {
  await clearData();
  await loadShapes(readFixture("shapes/standin-shapes.ttl"));
  const o = "urn:ontara:standin:cafe#cap-order-N";
  const setup = await write(orderWrite(o, G), db); // order + rule + labelling: ready
  const flip = await write({ graph: G, label: "cap line-only change",
    updates: [setAxis(`${o}/line/4`, "ready", "inPreparation")] }, db);
  return { setup: brief(setup), lineOnlyChange: brief(flip), caught: flip.outcome === "rejected" };
}

// ---- 9. OP-134 follow-up (S519, Part D item 3): Cyril's two-sided readiness
// shapes (fixtures/shapes/spike-two-sided-readiness.ttl), loaded as the
// runtime set the bootstrap loads (config.ts RUNTIME_SHAPE_FILES: with the
// core-only stand-in file and, since S0.5 Pass B8, the generated axis shapes)
// in place of the stand-in SPARQL constraint. Each case starts from a cleared
// graph and one fresh order written as the load harness writes it (order in
// preparation and paid, four lines ready, readiness rule and labelling in the
// same write, so the order ends ready), then sends one write.
//   A  line-only write against a ready order (line/4 ready -> inPreparation): rejected expected
//   B  legitimate per-line collection (line/1 ready -> collected, others ready): committed expected
//   C  order-only write: an order with line/4 inPreparation set inPreparation -> ready (rule off): rejected expected
//   D  case B against the stand-in shapes (SPARQL constraint): observed, no expectation
//      (the stand-in requires every line ready; Cyril §4.1 says legitimate data breaks it)
async function testTwoSidedReadiness() {
  const twoSided = RUNTIME_SHAPE_FILES.map((f) => readStackFile(f)).join("\n");
  const standin = readFixture("shapes/standin-shapes.ttl");
  const setStatus = setAxis;
  const statusOf = async (s: string) => (await db.select(`SELECT ?st WHERE { GRAPH <${G}> { <${s}> <${axisOf(s).p}> ?st } }`)).map((b: any) => b.st.value.replace(OC, ""));
  const cases: any[] = [];
  const run = async (id: string, name: string, shapes: "two-sided" | "standin", expect: "committed" | "rejected" | null,
                     prepare: (o: string) => Promise<any[]>, act: (o: string) => string, watch: (o: string) => string[]) => {
    await clearData();
    const load = await loadShapes(shapes === "two-sided" ? twoSided : standin);
    const o = `urn:ontara:standin:cafe#cap-2s-${id}`;
    const setup = await prepare(o);
    const before: any = {}; for (const s of watch(o)) before[s.replace(o, "<order>")] = await statusOf(s);
    const w = await write({ graph: G, label: `cap two-sided ${id}`, updates: [act(o)] }, db);
    const after: any = {}; for (const s of watch(o)) after[s.replace(o, "<order>")] = await statusOf(s);
    cases.push({ case: `${id}: ${name}`, shapes, shapesLoad: load.status, setup: setup.map(brief), statusBefore: before, write: brief(w), statusAfter: after, expect, pass: expect === null ? null : w.outcome === expect });
  };
  const placeReady = async (o: string) => [await write(orderWrite(o, G), db)];
  await run("A", "line-only write against a ready order (line/4 ready -> inPreparation)", "two-sided", "rejected", placeReady,
    (o) => setStatus(`${o}/line/4`, "ready", "inPreparation"), (o) => [o, `${o}/line/4`]);
  await run("B", "legitimate per-line collection (line/1 ready -> collected, lines 2-4 ready)", "two-sided", "committed", placeReady,
    (o) => setStatus(`${o}/line/1`, "ready", "collected"), (o) => [o, `${o}/line/1`]);
  await run("C", "order-only write: order with line/4 inPreparation set inPreparation -> ready", "two-sided", "rejected",
    async (o) => [await write(orderWrite(o, G, { rule: false }), db), await write({ graph: G, label: "cap two-sided C prep", updates: [setStatus(`${o}/line/4`, "ready", "inPreparation")] }, db)],
    (o) => setStatus(o, "inPreparation", "ready"), (o) => [o, `${o}/line/4`]);
  await run("D", "case B against the stand-in shapes (SPARQL constraint)", "standin", null, placeReady,
    (o) => setStatus(`${o}/line/1`, "ready", "collected"), (o) => [o, `${o}/line/1`]);
  return { shapesFile: `the runtime shapes: ${RUNTIME_SHAPE_FILES.join(" + ")}`, cases, pass: cases.filter((c) => c.pass !== null).every((c) => c.pass) };
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
// graph in the scratch dataset, writes an instance of a class that has a
// superclass there, and checks that the store added nothing: no rdf:type
// triple for any superclass, and the default graph grows by exactly the
// triples written. The scratch dataset is served by the same module as the
// runtime dataset, so this tests the runtime store's (absent) inference.
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
  // Clean the KG graph out of the scratch dataset again.
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
  if (args.includes("--combine")) return combine(opt("--combine", "capabilities"));
  const startedAt = new Date().toISOString();
  fs.mkdirSync(OUT, { recursive: true });

  // The scratch dataset: its status must read the validation probe passed, in
  // this run's mode; emptied first. (`validating` reads false here: the
  // scratch dataset holds no shapes between runs; each case loads its own.)
  const scratchStatus = await db.status();
  if (scratchStatus.validationProbe?.passed !== true || scratchStatus.validationMode !== MODE) {
    throw new Error(`/${SCRATCH} status: validationProbe.passed=${scratchStatus.validationProbe?.passed} mode=${scratchStatus.validationMode}; this run expects ${MODE}`);
  }
  const cr = await base.clearDataset(SCRATCH);
  if (!cr.ok) throw new Error(`clearing ${SCRATCH}: HTTP ${cr.status} ${cr.body}`);

  const result: any = {
    startedAt, mode: MODE, storeUrl: config.storeUrl,
    store: { product: `Apache Jena Fuseki ${scratchStatus.fusekiVersion}`, jenaVersion: scratchStatus.jenaVersion, jenaBuildVersion: scratchStatus.jenaBuildVersion, module: scratchStatus.module, validationMode: scratchStatus.validationMode, engine: scratchStatus.engine },
    scratchDataset: SCRATCH, scratchCleared: true, runtimeDatasetTouched: false,
  };
  try {
    result.item1_empirical = [];
    for (const t of componentTests) {
      const r = await testComponent(t);
      console.log(`[cap ${MODE}] ${t.predicate}: ${r.verdict}`);
      result.item1_empirical.push(r);
    }
    result.item2_ruleRunner = await testRuleRunner();
    for (const r of result.item2_ruleRunner) console.log(`[cap ${MODE}] ${r.pass ? "PASS" : "FAIL"} ${r.test}`);
    result.item3_messages = await testMessages();
    console.log(`[cap ${MODE}] sh:message returned: core=${result.item3_messages.coreShape.messageReturned} sparql=${result.item3_messages.sparqlConstraint.messageReturned}`);
    result.item4_namedGraphs = await testNamedGraphScope();
    console.log(`[cap ${MODE}] named graphs: ${JSON.stringify(result.item4_namedGraphs)}`);
    result.item5_noInference = await testNoInference();
    result.item5_noInference.runtimeDatasetInference = (await base.status()).inference;
    result.item5_noInference.scratchDatasetInference = scratchStatus.inference;
    result.item6_s515FiveCase = await testS515FiveCase();
    console.log(`[cap ${MODE}] ${result.item6_s515FiveCase.pass ? "PASS" : "FAIL"} S515 five-case in-transaction test: ${result.item6_s515FiveCase.cases.map((c: any) => `${c.case.split(":")[0]}=${c.write.outcome}`).join(" ")}; after=${JSON.stringify(result.item6_s515FiveCase.after)}`);
    result.item7_sparqlNonTargetChange = await testSparqlNonTargetChange();
    console.log(`[cap ${MODE}] stand-in SPARQL constraint, line-only change caught: ${result.item7_sparqlNonTargetChange.caught}`);
    result.item9_twoSidedReadiness = await testTwoSidedReadiness();
    for (const c of result.item9_twoSidedReadiness.cases) console.log(`[cap ${MODE}] ${c.pass === null ? "OBSERVED" : c.pass ? "PASS" : "FAIL"} two-sided ${c.case}: ${c.write.outcome}${c.expect ? ` (expected ${c.expect})` : ""}${c.write.validation ? ` [${c.write.validation}]` : ""}`);
    result.item8_shRule = await testShRule();
    console.log(`[cap ${MODE}] sh:rule: ${result.item8_shRule.verdict}`);
    console.log(`[cap ${MODE}] ${result.item5_noInference.pass ? "PASS" : "FAIL"} R4 no store-side inference: inference=${result.item5_noInference.scratchDatasetInference} (runtime ${result.item5_noInference.runtimeDatasetInference}), delta=${result.item5_noInference.defaultGraphDelta} for ${result.item5_noInference.triplesWritten} written, superclass types=${JSON.stringify(result.item5_noInference.superclassTypeTriplesFound)}`);
  } finally {
    const d = await base.clearDataset(SCRATCH);
    result.scratchClearedAfter = d.ok;
  }
  // How every validated write was validated.
  const modeOf = (h: string | null) => (h ? h.split(/[; ]/)[0] : "(no header)");
  const byMode = seen.reduce((a: Record<string, number>, x) => { const k = modeOf(x.validation); a[k] = (a[k] ?? 0) + 1; return a; }, {});
  const off = seen.filter((x) => !validatedAs(x.validation, MODE));
  result.validation = { expectedMode: MODE, validatedWrites: seen.length, byMode, notInExpectedMode: off.length, samplesNotInExpectedMode: off.slice(0, 10) };
  result.finishedAt = new Date().toISOString();

  fs.writeFileSync(path.join(OUT, `shacl-capabilities-${MODE}.json`), JSON.stringify(result, null, 2) + "\n");
  fs.writeFileSync(path.join(OUT, `shacl-capabilities-${MODE}.md`), markdown(result));
  console.log(`[cap ${MODE}] ${seen.length} validated writes, by mode ${JSON.stringify(byMode)}; not ${MODE}: ${off.length}`);
  console.log(`[cap ${MODE}] written results/${path.relative(paths.results, OUT)}/shacl-capabilities-${MODE}.json and .md`);
  // R4 is a binding requirement, not a component survey: a failure fails the script.
  if (!result.item5_noInference?.pass) { console.error(`[cap ${MODE}] R4 CHECK FAILED: the store added triples a declared writer did not write`); process.exitCode = 1; }
  if (off.length) { console.error(`[cap ${MODE}] CONFIGURATION FAULT: ${off.length} write(s) not validated ${MODE} (or no X-Ontara-Validation header)`); process.exitCode = 3; }
}

// Both modes in one table (specification 2.5 item 7.1).
function combine(dir: string) {
  const d = path.join(paths.results, dir);
  const read = (m: string) => { const f = path.join(d, `shacl-capabilities-${m}.json`); return fs.existsSync(f) ? JSON.parse(fs.readFileSync(f, "utf8")) : null; };
  const t = read("targeted"), w = read("whole");
  if (!t || !w) { console.error(`[cap] --combine needs shacl-capabilities-targeted.json and -whole.json in results/${dir}`); process.exit(1); }
  const L: string[] = [];
  const pf = (x: any) => (x === true ? "pass" : x === false ? "**FAIL**" : "n/a");
  L.push(`# SHACL capability checks (S0.1 pass 3, Fuseki)`, ``);
  L.push(`Generated by \`stack/bin/capabilities.sh\`. Store: ${t.store.product}, Jena ${t.store.jenaVersion}, ${t.store.module}. Targeted run finished ${t.finishedAt}, against the stack's store; whole run finished ${w.finishedAt}, against a short-lived container of the same image with \`ONTARA_VALIDATION=whole\`. Each ran in the scratch dataset \`${t.scratchDataset}\`, emptied before and after. Detail: \`shacl-capabilities-targeted.json\` and \`shacl-capabilities-whole.json\`, with their \`.md\` files.`, ``);
  L.push(`Validated writes: targeted ${t.validation.validatedWrites}, by mode ${JSON.stringify(t.validation.byMode)}; whole ${w.validation.validatedWrites}, by mode ${JSON.stringify(w.validation.byMode)}.`, ``);
  L.push(`## 1. Components`, ``, `| Component | Targeted | Whole |`, `|---|---|---|`);
  for (const a of t.item1_empirical) { const b = w.item1_empirical.find((x: any) => x.predicate === a.predicate); L.push(`| ${a.predicate} | ${a.verdict} | ${b?.verdict ?? "n/a"} |`); }
  L.push(``, `## 2. Labelling step and inline VALUES binding`, ``, `| Test | Targeted | Whole |`, `|---|---|---|`);
  for (const a of t.item2_ruleRunner) { const b = w.item2_ruleRunner.find((x: any) => x.test === a.test); L.push(`| ${a.test} | ${pf(a.pass)} | ${pf(b?.pass)} |`); }
  L.push(``, `## 3. sh:message in the rejection report`, ``, `| Shape | Targeted | Whole |`, `|---|---|---|`);
  L.push(`| Core shape | ${t.item3_messages.coreShape.messageReturned} | ${w.item3_messages.coreShape.messageReturned} |`);
  L.push(`| SHACL-SPARQL constraint | ${t.item3_messages.sparqlConstraint.messageReturned} | ${w.item3_messages.sparqlConstraint.messageReturned} |`);
  L.push(``, `Core-shape messages (targeted): ${JSON.stringify(t.item3_messages.coreShape.messages)}.`);
  L.push(``, `## 4. Named graphs (observed, for S0.5)`, ``, `| Observation | Targeted | Whole |`, `|---|---|---|`);
  for (const k of ["shapesApplyToDataInAnyNamedGraph", "shapesGraphTriplesVisibleToSparqlGraphQuery", "shapeInOrdinaryNamedGraphEnforced"]) L.push(`| ${k} | ${t.item4_namedGraphs[k]} | ${w.item4_namedGraphs[k]} |`);
  L.push(``, `## 5. R4: no store-side inference`, ``, `Targeted: **${pf(t.item5_noInference.pass)}** (delta ${t.item5_noInference.defaultGraphDelta} for ${t.item5_noInference.triplesWritten} written). Whole: **${pf(w.item5_noInference.pass)}** (delta ${w.item5_noInference.defaultGraphDelta}).`);
  L.push(``, `## 6. The S515 five-case in-transaction test`, ``, `| Case | Expected | Targeted | Whole |`, `|---|---|---|---|`);
  for (const a of t.item6_s515FiveCase.cases) { const b = w.item6_s515FiveCase.cases.find((x: any) => x.case === a.case); L.push(`| ${a.case} | ${a.expect} | ${a.write.outcome} | ${b?.write.outcome ?? "n/a"} |`); }
  L.push(``, `Result: targeted **${pf(t.item6_s515FiveCase.pass)}**, whole **${pf(w.item6_s515FiveCase.pass)}**.`);
  L.push(``, `## 7. Stand-in SPARQL constraint, line-only change`, ``, `Caught: targeted **${t.item7_sparqlNonTargetChange.caught}**, whole **${w.item7_sparqlNonTargetChange.caught}**. Targeted mode is expected to miss it (ADR-014 §4.3): the write does not touch the order the constraint targets.`);
  L.push(``, `## 8. sh:rule`, ``, `Targeted: ${t.item8_shRule.verdict}. Whole: ${w.item8_shRule.verdict}.`);
  L.push(``, `## 9. Two-sided readiness shapes (Cyril, S519)`, ``, `| Case | Shapes | Expected | Targeted | Whole |`, `|---|---|---|---|---|`);
  for (const a of t.item9_twoSidedReadiness.cases) { const b = w.item9_twoSidedReadiness.cases.find((x: any) => x.case === a.case); L.push(`| ${a.case} | ${a.shapes} | ${a.expect ?? "observed"} | ${a.write.outcome}${a.pass === false ? " **(unexpected)**" : ""} | ${b ? b.write.outcome + (b.pass === false ? " **(unexpected)**" : "") : "n/a"} |`); }
  L.push(``, `Result: targeted **${pf(t.item9_twoSidedReadiness.pass)}**, whole **${pf(w.item9_twoSidedReadiness.pass)}**.`);
  const out = path.join(d, "shacl-capabilities.md");
  fs.writeFileSync(out, L.join("\n") + "\n");
  console.log(`[cap] written results/${path.relative(paths.results, out)}`);
}

function markdown(r: any): string {
  const L: string[] = [];
  L.push(`# SHACL capability checks (S0.1 pass 3), ${r.mode} mode`, ``);
  L.push(`Generated by \`stack/bin/capabilities.sh\` at ${r.finishedAt}. Store: ${r.store.product}, Jena ${r.store.jenaVersion}, ${r.store.module}, validation mode ${r.store.validationMode}. Scratch dataset \`${r.scratchDataset}\`, emptied before and after (${r.scratchClearedAfter}). Validated writes: ${r.validation.validatedWrites}, by mode ${JSON.stringify(r.validation.byMode)}, not ${r.mode}: ${r.validation.notInExpectedMode}. Full detail: \`shacl-capabilities-${r.mode}.json\`.`, ``);
  L.push(`## 1. Components`, ``, `| Component | Tested behaviour |`, `|---|---|`);
  for (const t of r.item1_empirical) L.push(`| ${t.predicate} | ${t.verdict} |`);
  L.push(``, `## 2. Labelling step and inline VALUES binding`, ``, `| Test | Result |`, `|---|---|`);
  for (const t of r.item2_ruleRunner) L.push(`| ${t.test} | ${t.pass ? "pass" : "**FAIL**"} |`);
  const m = r.item3_messages;
  L.push(``, `## 3. sh:message in the rejection report`, ``);
  L.push(`1. Core shape: message returned = **${m.coreShape.messageReturned}** (${JSON.stringify(m.coreShape.messages)}).`);
  L.push(`2. SHACL-SPARQL constraint: message returned = **${m.sparqlConstraint.messageReturned}** (${JSON.stringify(m.sparqlConstraint.messages)}).`);
  const n = r.item4_namedGraphs;
  L.push(``, `## 4. Named graphs (observed, for S0.5)`, ``);
  L.push(`1. Shapes apply to data written into any named graph: ${n.shapesApplyToDataInAnyNamedGraph}.`);
  L.push(`2. The shapes graph is visible to a SPARQL \`GRAPH\` query: ${n.shapesGraphTriplesVisibleToSparqlGraphQuery} triples.`);
  const i = r.item5_noInference;
  if (i) {
    L.push(``, `## 5. R4: no store-side inference`, ``);
    L.push(`Result: **${i.pass ? "pass" : "FAIL"}**. Scratch dataset inference \`${i.scratchDatasetInference}\`; runtime dataset inference \`${i.runtimeDatasetInference}\`.`, ``);
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
  if (x) L.push(``, `## 7. Stand-in SPARQL constraint, line-only change`, ``, `An existing ready order has one line set back to in preparation (line triple only). Caught: **${x.caught}** (validation: ${x.lineOnlyChange.validation}).`);
  const ts = r.item9_twoSidedReadiness;
  if (ts) {
    L.push(``, `## 9. Two-sided readiness shapes (S519; Cyril's note §4.2)`, ``, `Shapes: ${ts.shapesFile}. Result: **${ts.pass ? "pass" : "FAIL"}** (cases with an expectation).`, ``, `| Case | Shapes | Expected | Outcome | Validation | Status before -> after |`, `|---|---|---|---|---|---|`);
    for (const c of ts.cases) L.push(`| ${c.case} | ${c.shapes} | ${c.expect ?? "observed"} | ${c.write.outcome}${c.pass === false ? " **(unexpected)**" : ""}${c.write.nodeShapes?.length ? ` (${c.write.nodeShapes.join(", ")})` : ""} | ${c.write.validation ?? "n/a"} | ${JSON.stringify(c.statusBefore)} -> ${JSON.stringify(c.statusAfter)} |`);
  }
  const ru = r.item8_shRule;
  if (ru) L.push(``, `## 8. sh:rule (SHACL Advanced Features)`, ``, `${ru.verdict}.`);
  return L.join("\n") + "\n";
}

main().catch((e) => { console.error(e); process.exit(1); });
