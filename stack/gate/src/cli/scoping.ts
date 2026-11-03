// The scoping test suite (S0.5 Pass B2; ADR-014 §4.4 condition 1): automated
// tests of what the store module's targeted validation checks, and of the
// named-graph scheme's write rules, against the module itself. Run by
// bin/scoping-test.sh (and `make stack-scoping-test` at the repository root)
// in the suite's OWN Compose project (ontara-cafe-scoping; scoping/compose.yaml):
// a fresh store of the stack's own image, loaded by the stack's own bootstrap,
// its data inside the container, so the runtime stack's data is never touched.
//
// The seven groups of specification §6.5 item B2, each case named "<group>.<n>":
//   1  each update form validated in targeted mode: INSERT DATA, DELETE DATA,
//      DELETE/INSERT WHERE (conforming and violating), and that targeted means
//      targeted (an untouched violation is not looked at);
//   2  each other form (CLEAR, DROP, LOAD, ADD, MOVE, COPY) falls back to
//      whole-graph validation, with the X-Ontara-Validation header saying so;
//   3  requests mixing forms;
//   4  each shape form S0.6 will use (Cyril, S0.5 Pass B step 2 §2: F1 to F10),
//      with violating and conforming writes, and the four kinds no per-write
//      check catches (ADR-014 §4.3; E1 to E4) shown as whole-graph only;
//   5  the known blind spot (F11): a shape that breaks the shape-authoring rule
//      is missed by targeted validation and caught by a whole-graph validation
//      of the same data;
//   6  the scheme's refusals (B3 item 4), through the suite's gate and directly
//      against the module, in targeted and in whole mode;
//   7  two store behaviours D1 could not confirm: where a default-graph write
//      lands and whether validation sees it; and whether the standard
//      endpoints are closed to writes from outside the stack's network.
//
// The whole-graph validation used by groups 4 and 5 (change 1 of step 4) is
// the module's own whole-graph path: a request that changes nothing and is
// not one of the three targeted forms (ADD SILENT GRAPH <g> TO GRAPH <g>), so
// the module validates every shape against the whole union graph and answers
// 200 (conforms) or 422 (the report), aborting in either case nothing changed.
//
//   node dist/cli/scoping.js --out <rel>                the suite (inside the suite's network)
//   node dist/cli/scoping.js --outside <url> --out <rel> group 7's outside leg, from a container
//                                                        NOT on the stack's network
//   node dist/cli/scoping.js --summarise <rel>          combines the legs into summary.json and
//                                                        cases.md; exit 0 only if every case passed
// <rel> is a folder under results/. Exit 2 on a fault.
import * as fs from "node:fs";
import * as path from "node:path";
import * as nodeHttp from "node:http";
import { randomUUID } from "node:crypto";
import { http, HttpResult } from "../store/http";
import { openStore, WritePolicy } from "../store";
import { parseReport, ShaclReport } from "../report";
import { config, paths, RUNTIME_SHAPE_FILES } from "../config";
import { readFixture, readStackFile, orderWrite, fill } from "../fixtures";
import { parseTurtleInto, dataBlock } from "../store/rdfjs";
import { branch, Branch, KG_GRAPHS, SHAPES_GRAPH, STORED_DEFAULT_GRAPH, TENANT, placementTokens, bindBranch } from "../graphs";
import { writePolicy } from "../gate";
import { fillPlacement, PLACEMENT_QUERIES } from "./placement";

const DS = "cafe-runtime";
const STORE = config.storeUrl;                                   // the suite's store, stack-network listener
const PUBLISHED_INSIDE = STORE.replace(/:3030$/, ":3031");       // the same store's published listener, by name
const WHOLE = process.env.SCOPING_WHOLE_STORE_URL ?? "http://store-whole:3030";
const GATE = config.gateUrl;
const SELF_HOST = process.env.SCOPING_SELF_HOST ?? "gate";      // this container, as the store reaches it (LOAD)
const LOAD_PORT = 7299;

const RDFS = "http://www.w3.org/2000/01/rdf-schema#";
const PFX = `PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <${RDFS}>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX prov: <http://www.w3.org/ns/prov#>
PREFIX cafe: <urn:ontara:standin:cafe#>
PREFIX rec: <urn:ontara:standin:rec#>
PREFIX sp: <urn:ontara:standin:scoping#>
PREFIX ontara-cafe: <https://ontara.dev/ontology/tenant/cafe/>
PREFIX o: <https://ontara.dev/data/cafe/order/>
`;

const SHAPES = {
  runtime: RUNTIME_SHAPE_FILES,
  axis: "tenant-generated/cafe/axis-shapes.ttl",
  readiness: "fixtures/shapes/spike-two-sided-readiness.ttl",
  probe: "fixtures/scoping/shapes/scope-probe.ttl",
  forms: "fixtures/scoping/shapes/forms.ttl",
  timeOnly: "fixtures/scoping/shapes/time-only.ttl",
  blindspot: "fixtures/scoping/shapes/blindspot.ttl",
  e1Subselect: "fixtures/scoping/shapes/e1-subselect.ttl",
};

// ------------------------------------------------------------- the cases
export interface Case { group: number; id: string; name: string; expected: string; observed: string; pass: boolean; validation?: string | null; detail?: string }
const cases: Case[] = [];
function record(c: Case) {
  cases.push(c);
  console.log(`${c.pass ? "PASS" : "FAIL"}  ${c.id.padEnd(6)} ${c.name}\n        expected: ${c.expected}\n        observed: ${c.observed}${c.validation ? `\n        X-Ontara-Validation: ${c.validation}` : ""}`);
}

const ln = (iri: string | null | undefined) => (iri ?? "").replace(/^.*[#/]/, "");

// ------------------------------------------------- the module's write endpoint
interface VU { status: number; outcome: string; mode: string; validation: string | null; txn: string | null; report: ShaclReport | null; refusal: any; body: string }
function modeOf(h: string | null): string {
  if (!h) return "no header";
  if (h.startsWith("targeted")) return "targeted";
  if (h.startsWith("whole")) return "whole";
  if (h.startsWith("not")) return "not validated";
  return h;
}
async function vu(base: string, body: string, policy?: WritePolicy, dataset = DS): Promise<VU> {
  const r = await http("POST", `${base}/${dataset}/validated-update`, {
    body, contentType: "application/sparql-update", timeoutMs: 120_000,
    headers: policy ? { "X-Ontara-Write-Policy": JSON.stringify(policy) } : undefined,
  });
  const validation = r.headers.get("x-ontara-validation");
  const outcome = r.status === 200 ? "committed" : r.status === 422 ? "rejected" : r.status === 403 ? "refused" : r.status === 405 ? "refused (405)" : r.status === 400 ? "bad request (400)" : r.status === 500 ? "fault (500)" : `HTTP ${r.status}`;
  let report: ShaclReport | null = null, refusal: any = null;
  if (r.status === 422) report = parseReport(r.body);
  if (r.status === 403) { try { refusal = JSON.parse(r.body); } catch { refusal = null; } }
  return { status: r.status, outcome, mode: modeOf(validation), validation, txn: r.headers.get("x-ontara-transaction"), report, refusal, body: r.body };
}
const shapesOf = (r: VU) => [...new Set((r.report?.results ?? []).map((x) => ln(x.sourceShape)).filter((x) => x))].sort();
const focusOf = (r: VU) => [...new Set((r.report?.results ?? []).map((x) => ln(x.focusNode)))].sort();

interface Want { outcome: string; mode?: string; shapes?: string[]; focus?: string[]; rules?: string[]; notShapes?: string[] }
function check(group: number, id: string, name: string, r: VU, w: Want, extra?: { pass?: boolean; note?: string }) {
  const sh = shapesOf(r), fo = focusOf(r);
  const rules: string[] = r.refusal?.rules ?? [];
  let pass = r.outcome === w.outcome && (!w.mode || r.mode === w.mode);
  if (w.shapes) pass &&= w.shapes.every((s) => sh.includes(s));
  if (w.notShapes) pass &&= w.notShapes.every((s) => !sh.includes(s));
  if (w.focus) pass &&= w.focus.every((f) => fo.includes(f));
  if (w.rules) pass &&= w.rules.every((x) => rules.includes(x));
  if (extra?.pass === false) pass = false;
  const exp = [w.outcome, w.mode, w.shapes?.length ? `shapes ${w.shapes.join(", ")}` : "", w.focus?.length ? `on ${w.focus.join(", ")}` : "", w.rules?.length ? `rule ${w.rules.join(", ")}` : "", w.notShapes?.length ? `not ${w.notShapes.join(", ")}` : ""].filter(Boolean).join(", ");
  const obs = [r.outcome, r.mode !== "no header" ? r.mode : (r.status === 405 ? "" : "no header"), sh.length ? `shapes ${sh.join(", ")}` : "", fo.length && sh.length ? `on ${fo.join(", ")}` : "", rules.length ? `rule ${rules.join(", ")}` : "", extra?.note ?? "", r.status >= 500 || r.status === 400 ? r.body.slice(0, 300) : ""].filter(Boolean).join(", ");
  record({ group, id, name, expected: exp, observed: obs, pass, validation: r.validation });
}

// The module's whole-graph validation of the data as it stands: a request
// that changes nothing and is not a targeted form (README section 3).
async function wholeGraph(base: string, g: string): Promise<VU> {
  return vu(base, `ADD SILENT GRAPH <${g}> TO GRAPH <${g}>`);
}
function checkWhole(group: number, id: string, name: string, r: VU, conforms: boolean, shapes: string[] = [], focus: string[] = []) {
  check(group, id, name, r, conforms ? { outcome: "committed", mode: "whole" } : { outcome: "rejected", mode: "whole", shapes, focus });
}

// ------------------------------------------------------------- the store
const db = openStore(DS, STORE);
async function must(r: Promise<HttpResult> | Promise<{ ok: boolean; status: number; body: string }>, what: string) {
  const x: any = await r;
  const ok = x.ok ?? (x.status >= 200 && x.status < 300);
  if (!ok) throw new Error(`${what}: HTTP ${x.status}: ${String(x.body).slice(0, 500)}`);
}
async function setShapes(files: string[]) {
  const ttl = files.map((f) => readStackFile(f)).join("\n");
  await must(db.replaceGraph(SHAPES_GRAPH, ttl, "text/turtle"), `shapes ${files.join(" + ")}`);
}
const ttl = (rel: string) => readFixture(rel);
let rrb: Branch;
async function resetBranch(b: Branch = rrb, base = STORE) {
  const s = base === STORE ? db : openStore(DS, base);
  await must(s.update(`DROP SILENT GRAPH <${b.dbr}> ; DROP SILENT GRAPH <${b.dsr}>`), "reset branch");
}
async function loadBase(extra = "") {
  await resetBranch();
  await must(db.appendGraph(rrb.dbr, ttl("scoping/data/base.ttl"), "text/turtle"), "base data");
  if (extra) await must(db.update(`${PFX} INSERT DATA { GRAPH <${rrb.dbr}> { ${extra} } }`), "base extra");
}
async function countAll(base = STORE): Promise<number> {
  const s = base === STORE ? db : openStore(DS, base);
  const r = await s.select(`SELECT (COUNT(*) AS ?n) WHERE { { GRAPH ?g { ?s ?p ?o } } UNION { GRAPH <${STORED_DEFAULT_GRAPH}> { ?s ?p ?o } } }`);
  return Number(r[0]?.n?.value ?? -1);
}
async function countGraph(g: string): Promise<number> { return db.size(g); }

// Graph-wrapped update forms, in the suite's prefixes.
const ins = (g: string, body: string) => `INSERT DATA { GRAPH <${g}> { ${body} } }`;
const del = (g: string, body: string) => `DELETE DATA { GRAPH <${g}> { ${body} } }`;
const mod = (g: string, d: string, i: string, w: string) => `DELETE { GRAPH <${g}> { ${d} } } INSERT { GRAPH <${g}> { ${i} } } WHERE { GRAPH <${g}> { ${w} } }`;
const req = (...ops: string[]) => PFX + ops.join(" ;\n");

// ------------------------------------------------------------- group 1
async function group1() {
  console.log("\n== Group 1: the three update forms validated in targeted mode (with the runtime write policy)");
  await setShapes([...SHAPES.runtime, SHAPES.probe]);
  await resetBranch();
  const pol = writePolicy(rrb);
  const O = `urn:ontara:standin:cafe#order-scoping-g1`;
  const order = orderWrite(O);
  const orderData = dataBlock(parseTurtleInto(order.turtle, rrb.dbr));

  let r = await vu(STORE, `INSERT DATA {\n${orderData}\n}`, pol);
  check(1, "1.1", "INSERT DATA, conforming (the 54-triple order, no rule)", r, { outcome: "committed", mode: "targeted" },
    { pass: /focus=([1-9]\d*)/.test(r.validation ?? ""), note: "focus > 0" });
  r = await vu(STORE, req(ins(rrb.dbr, "sp:n1 a sp:T")), pol);
  check(1, "1.2", "INSERT DATA, violating (an sp:T with no sp:p)", r, { outcome: "rejected", mode: "targeted", shapes: ["ProbeShape-p"], focus: ["n1"] });
  r = await vu(STORE, req(ins(rrb.dbr, `<${O}/line/1> ontara-cafe:orderLinePreparation ontara-cafe:OrderLifecycle-ready`)), pol);
  check(1, "1.3", "INSERT DATA, violating (a second preparation value, from another axis)", r, { outcome: "rejected", mode: "targeted", shapes: ["OrderLinePreparationAxisShape-value"] });
  r = await vu(STORE, req(del(rrb.dbr, `<${O}> cafe:counter "counter-1"`)), pol);
  check(1, "1.4", "DELETE DATA, conforming (a triple no shape needs)", r, { outcome: "committed", mode: "targeted" });
  r = await vu(STORE, req(del(rrb.dbr, `<${O}> ontara-cafe:orderPayment ontara-cafe:OrderPayment-paid`)), pol);
  check(1, "1.5", "DELETE DATA, violating (the order's only payment value)", r, { outcome: "rejected", mode: "targeted", shapes: ["OrderPaymentAxisShape-value"] });
  // The readiness rule makes a record that only the labelling step completes
  // (mode and method), so the two go in one request, as on the runtime path.
  const rule = [fill(ttl("rules/order-readiness.rq"), { O, EXEC: `${O}/exec/readiness` }), fill(ttl("rules/labelling.rq"), { EXEC: `${O}/exec/readiness` })].map((u) => bindBranch(u, rrb)).join(" ;\n");
  r = await vu(STORE, rule, pol);
  const ready = await db.ask(`ASK { GRAPH <${rrb.dbr}> { <${O}> <https://ontara.dev/ontology/tenant/cafe/orderLifecycle> <https://ontara.dev/ontology/tenant/cafe/OrderLifecycle-ready> } }`);
  check(1, "1.6", "DELETE/INSERT WHERE, conforming (the readiness rule, inPreparation to ready, with the labelling step: both DELETE/INSERT WHERE forms)", r, { outcome: "committed", mode: "targeted" }, { pass: ready, note: `order ready after: ${ready}` });
  r = await vu(STORE, req(mod(rrb.dbr, `<${O}/line/1> ontara-cafe:orderLinePreparation ?v`, `<${O}/line/1> ontara-cafe:orderLinePreparation ontara-cafe:OrderLinePreparation-inPreparation`, `<${O}/line/1> ontara-cafe:orderLinePreparation ?v`)), pol);
  check(1, "1.7", "DELETE/INSERT WHERE, violating (a line leaves ready on a ready order)", r, { outcome: "rejected", mode: "targeted", shapes: ["LineReadinessTwoSidedShape"] });
  r = await vu(STORE, req(`INSERT { GRAPH <${rrb.dbr}> { <${O}> cafe:note "insert-where" } } WHERE { GRAPH <${rrb.dbr}> { <${O}> a ontara-cafe:Order } }`), pol);
  check(1, "1.8", "INSERT ... WHERE (the DELETE/INSERT form with no DELETE), conforming", r, { outcome: "committed", mode: "targeted" });
  // How the module records what a request touched (the subject and object of
  // every quad it changed), probed on the forms a rule may take.
  r = await vu(STORE, req(`WITH <${rrb.dbr}> DELETE { <${O}> ontara-cafe:orderPayment ?v } WHERE { <${O}> ontara-cafe:orderPayment ?v }`), pol);
  check(1, "1.12", "DELETE/INSERT WHERE in the WITH <graph> form, violating (removes the order's payment value)", r, { outcome: "rejected", mode: "targeted", shapes: ["OrderPaymentAxisShape-value"] });
  r = await vu(STORE, req(`DELETE { GRAPH ?g { <${O}/line/2> ontara-cafe:orderLinePreparation ?v } } WHERE { GRAPH ?g { <${O}/line/2> ontara-cafe:orderLinePreparation ?v } }`), pol);
  check(1, "1.13", "DELETE/INSERT WHERE over a graph variable (GRAPH ?g), violating (removes a line's preparation value)", r, { outcome: "rejected", mode: "targeted", shapes: ["OrderLinePreparationAxisShape-value"] });
  r = await vu(STORE, req(ins(rrb.dbr, `<${O}> cafe:hasLine _:b . _:b a ontara-cafe:OrderLine ; cafe:lineOf <${O}>`)), pol);
  check(1, "1.14", "INSERT DATA of a blank-node line with no preparation value: the blank node is touched and validated", r, { outcome: "rejected", mode: "targeted", shapes: ["OrderLinePreparationAxisShape-value"] });
  // Targeted means targeted: a violation the request does not touch is not looked at.
  await must(db.update(req(ins(rrb.dbr, "sp:v a sp:T"))), "seed sp:v (unvalidated)");
  r = await vu(STORE, req(ins(rrb.dbr, `<${O}> cafe:note "untouched violation present"`)), pol);
  check(1, "1.9", "Targeted means targeted: with an untouched violation (sp:v, seeded unvalidated) in the graph, a conforming INSERT DATA commits", r, { outcome: "committed", mode: "targeted" });
  r = await vu(STORE, req(`DELETE WHERE { GRAPH <${rrb.dbr}> { <${O}> cafe:note ?n } }`));
  check(1, "1.10", "DELETE WHERE (the shorthand form) is not one of the three targeted forms: it falls back to whole-graph validation (no policy; sp:v present)", r, { outcome: "rejected", mode: "whole", focus: ["v"] });
  r = await vu(STORE, req(`DELETE WHERE { GRAPH <${rrb.dbr}> { <${O}> cafe:note ?n } }`), pol);
  check(1, "1.11", "DELETE WHERE with the runtime write policy is refused as a whole-graph operation", r, { outcome: "refused", rules: ["operation"] });
  await resetBranch();
}

// ------------------------------------------------------------- group 2
// State S0: dbr {n a T; n p 1}, dsr {k note "x"}. V: sp:v a sp:T (violates) in dbr.
// State S1: dbr {n a T},        dsr {n p 1}.
let loadServer: nodeHttp.Server | null = null;
const LOADS: Record<string, string> = {
  "/scoping/load-conforming.ttl": "<urn:ontara:standin:scoping#m> a <urn:ontara:standin:scoping#T> ; <urn:ontara:standin:scoping#p> 1 .\n",
  "/scoping/load-violating.ttl": "<urn:ontara:standin:scoping#m> a <urn:ontara:standin:scoping#T> .\n",
};
function startLoadServer(): Promise<void> {
  return new Promise((res) => {
    loadServer = nodeHttp.createServer((q, s) => {
      const body = LOADS[q.url ?? ""];
      if (!body) { s.writeHead(404); s.end(); return; }
      s.writeHead(200, { "Content-Type": "text/turtle" }); s.end(body);
    });
    loadServer.listen(LOAD_PORT, "0.0.0.0", () => res());
  });
}
const loadUrl = (f: string) => `http://${SELF_HOST}:${LOAD_PORT}/scoping/${f}`;

async function state(which: "S0" | "S1", withV: boolean) {
  await resetBranch();
  const dbr = which === "S0" ? "sp:n a sp:T ; sp:p 1 ." : "sp:n a sp:T .";
  const dsr = which === "S0" ? `sp:k sp:note "x" .` : "sp:n sp:p 1 .";
  await must(db.update(req(ins(rrb.dbr, dbr + (withV ? " sp:v a sp:T ." : "")), ins(rrb.dsr, dsr))), `state ${which}`);
}

async function group2() {
  console.log("\n== Group 2: the other forms fall back to whole-graph validation, and the header says so (no policy: they act on whole graphs)");
  await setShapes([...SHAPES.runtime, SHAPES.probe]);
  await startLoadServer();
  const D = rrb.dbr, S = rrb.dsr;
  const forms: { op: string; conforming: string; introduces?: string; why?: string }[] = [
    { op: "CLEAR", conforming: `CLEAR GRAPH <${S}>`, introduces: `CLEAR GRAPH <${S}>` },
    { op: "DROP", conforming: `DROP GRAPH <${S}>`, introduces: `DROP GRAPH <${S}>` },
    { op: "LOAD", conforming: `LOAD <${loadUrl("load-conforming.ttl")}> INTO GRAPH <${S}>`, introduces: `LOAD <${loadUrl("load-violating.ttl")}> INTO GRAPH <${S}>` },
    { op: "ADD", conforming: `ADD GRAPH <${D}> TO GRAPH <${S}>`, why: "ADD copies triples between named graphs, so the union graph that is validated does not change: it cannot introduce a violation" },
    { op: "MOVE", conforming: `MOVE GRAPH <${D}> TO GRAPH <${S}>`, introduces: `MOVE GRAPH <${D}> TO GRAPH <${S}>` },
    { op: "COPY", conforming: `COPY GRAPH <${D}> TO GRAPH <${S}>`, introduces: `COPY GRAPH <${D}> TO GRAPH <${S}>` },
  ];
  let i = 0;
  for (const f of forms) {
    i++;
    await state("S0", false);
    let r = await vu(STORE, f.conforming);
    check(2, `2.${i}a`, `${f.op}, conforming: falls back to whole-graph validation and commits`, r, { outcome: "committed", mode: "whole" },
      { pass: (r.validation ?? "").includes("other than INSERT DATA"), note: "header names the fallback" });
    await state("S0", true);
    const before = await countAll();
    r = await vu(STORE, f.conforming);
    const after = await countAll();
    check(2, `2.${i}b`, `${f.op} with a violation it does not touch (sp:v): the whole graph is validated, so it is rejected`, r, { outcome: "rejected", mode: "whole", shapes: ["ProbeShape-p"], focus: ["v"] },
      { pass: before === after, note: `store unchanged: ${before === after}` });
    if (f.introduces) {
      await state("S1", false);
      const b2 = await countAll();
      r = await vu(STORE, f.introduces);
      const a2 = await countAll();
      check(2, `2.${i}c`, `${f.op} that itself makes a violation (an sp:T loses or lacks its sp:p): rejected by the whole-graph fallback`, r, { outcome: "rejected", mode: "whole", shapes: ["ProbeShape-p"] },
        { pass: b2 === a2, note: `store unchanged: ${b2 === a2}` });
    } else {
      record({ group: 2, id: `2.${i}c`, name: `${f.op} that itself makes a violation`, expected: "not applicable", observed: `not applicable: ${f.why}`, pass: true });
    }
  }
  loadServer?.close();
  await resetBranch();
}

// ------------------------------------------------------------- group 3
async function group3() {
  console.log("\n== Group 3: requests mixing forms");
  await setShapes([...SHAPES.runtime, SHAPES.probe]);
  const D = rrb.dbr, S = rrb.dsr;
  await state("S0", false);
  let r = await vu(STORE, req(ins(D, "sp:m a sp:T ; sp:p 2"), `CLEAR SILENT GRAPH <${S}>`));
  check(3, "3.1", "INSERT DATA ; CLEAR (conforming): the whole request falls back to whole-graph validation", r, { outcome: "committed", mode: "whole" });
  await state("S0", true);
  r = await vu(STORE, req(ins(D, "sp:m a sp:T ; sp:p 2"), `CLEAR SILENT GRAPH <${S}>`));
  check(3, "3.2", "INSERT DATA ; CLEAR with an untouched violation (sp:v): the targeted part does not narrow the validation", r, { outcome: "rejected", mode: "whole", focus: ["v"] });
  await state("S0", false);
  r = await vu(STORE, req(ins(D, "sp:m a sp:T"), `CLEAR SILENT GRAPH <${S}>`));
  check(3, "3.3", "INSERT DATA (violating) ; CLEAR: the inserted violation is caught in whole mode", r, { outcome: "rejected", mode: "whole", shapes: ["ProbeShape-p"], focus: ["m"] });
  await state("S0", true);
  r = await vu(STORE, req(ins(D, "sp:m a sp:T ; sp:p 2"), mod(D, "sp:n sp:p ?x", "sp:n sp:p 3", "sp:n sp:p ?x")));
  check(3, "3.4", "INSERT DATA ; DELETE/INSERT WHERE (two targeted forms), untouched sp:v present: stays targeted and commits", r, { outcome: "committed", mode: "targeted" });
  await state("S0", false);
  r = await vu(STORE, req(ins(D, "sp:m a sp:T ; sp:p 2"), mod(D, "sp:n sp:p ?x", "sp:n sp:q 3", "sp:n sp:p ?x")));
  check(3, "3.5", "INSERT DATA ; DELETE/INSERT WHERE that removes sp:n's only sp:p: caught in targeted mode", r, { outcome: "rejected", mode: "targeted", shapes: ["ProbeShape-p"], focus: ["n"] });
  r = await vu(STORE, req(ins(D, "sp:m a sp:T ; sp:p 2"), `CLEAR SILENT GRAPH <${S}>`), writePolicy(rrb));
  check(3, "3.6", "INSERT DATA ; CLEAR with the runtime write policy: refused (a runtime write may not act on whole graphs)", r, { outcome: "refused", rules: ["operation"] });
  await resetBranch();
}

// ------------------------------------------------------------- group 4
async function group4() {
  console.log("\n== Group 4: the shape forms S0.6 will use (Cyril, step 2 §2), targeted and whole-graph");
  const formsSet = [SHAPES.axis, SHAPES.readiness, SHAPES.forms, SHAPES.timeOnly];
  await setShapes(formsSet);
  await must(db.appendGraph(KG_GRAPHS.domain, ttl("scoping/data/kg-standin.ttl"), "text/turtle"), "kg stand-in");
  const pol = writePolicy(rrb);
  const G = rrb.dbr;
  const W = () => wholeGraph(STORE, G);
  const ready = req(del(G, "o:A-2 ontara-cafe:orderLinePreparation ontara-cafe:OrderLinePreparation-inPreparation . o:A ontara-cafe:orderLifecycle ontara-cafe:OrderLifecycle-inPreparation"),
                    ins(G, "o:A-2 ontara-cafe:orderLinePreparation ontara-cafe:OrderLinePreparation-collected . o:A ontara-cafe:orderLifecycle ontara-cafe:OrderLifecycle-ready"));
  const regress = req(mod(G, "o:A-1 ontara-cafe:orderLinePreparation ?v", "o:A-1 ontara-cafe:orderLinePreparation ontara-cafe:OrderLinePreparation-inPreparation", "o:A-1 ontara-cafe:orderLinePreparation ?v"));

  await loadBase();
  checkWhole(4, "4.0", "The base data and the knowledge graph conform to every form's shape (whole-graph)", await W(), true);

  type C = { id: string; name: string; update: string; want: Want; whole?: { conforms: boolean; shapes?: string[] }; setup?: string; setupWrite?: string };
  const list: C[] = [
    { id: "4.F1a", name: "F1 closed value set: a move to a member value (DELETE/INSERT WHERE) commits", update: req(mod(G, "o:A-2 ontara-cafe:orderLinePreparation ?v", "o:A-2 ontara-cafe:orderLinePreparation ontara-cafe:OrderLinePreparation-ready", "o:A-2 ontara-cafe:orderLinePreparation ?v")), want: { outcome: "committed", mode: "targeted" }, whole: { conforms: true } },
    { id: "4.F1b", name: "F1: an order created without its payment axis", update: req(ins(G, "o:B a ontara-cafe:Order ; ontara-cafe:orderLifecycle ontara-cafe:OrderLifecycle-placed ; cafe:hasLine o:A-1")), want: { outcome: "rejected", mode: "targeted", shapes: ["OrderPaymentAxisShape-value"], focus: ["B"] } },
    { id: "4.F1c", name: "F1: a second preparation value", update: req(ins(G, "o:A-1 ontara-cafe:orderLinePreparation ontara-cafe:OrderLinePreparation-collected")), want: { outcome: "rejected", mode: "targeted", shapes: ["OrderLinePreparationAxisShape-value"], focus: ["A-1"] } },
    { id: "4.F1d", name: "F1: another axis's value on a line", update: req(del(G, "o:A-1 ontara-cafe:orderLinePreparation ontara-cafe:OrderLinePreparation-ready"), ins(G, "o:A-1 ontara-cafe:orderLinePreparation ontara-cafe:OrderLifecycle-ready")), want: { outcome: "rejected", mode: "targeted", shapes: ["OrderLinePreparationAxisShape-value"], focus: ["A-1"] } },
    { id: "4.F1e", name: "F1: a literal instead of the value IRI", update: req(del(G, "o:A-1 ontara-cafe:orderLinePreparation ontara-cafe:OrderLinePreparation-ready"), ins(G, `o:A-1 ontara-cafe:orderLinePreparation "ready"`)), want: { outcome: "rejected", mode: "targeted", shapes: ["OrderLinePreparationAxisShape-value"], focus: ["A-1"] } },
    { id: "4.F1f", name: "F1: the value deleted (DELETE DATA only)", update: req(del(G, "o:A ontara-cafe:orderPayment ontara-cafe:OrderPayment-paid")), want: { outcome: "rejected", mode: "targeted", shapes: ["OrderPaymentAxisShape-value"], focus: ["A"] } },
    { id: "4.F2a", name: "F2 subject typing: an axis triple on a menu item", update: req(ins(G, "cafe:Croissant ontara-cafe:orderLinePreparation ontara-cafe:OrderLinePreparation-ready")), want: { outcome: "rejected", mode: "targeted", shapes: ["OrderLinePreparationAxisSubjectShape"], focus: ["Croissant"] } },
    { id: "4.F2b", name: "F2: a line's type deleted, its axis triple left", update: req(del(G, "o:A-2 a ontara-cafe:OrderLine")), want: { outcome: "rejected", mode: "targeted", shapes: ["OrderLinePreparationAxisSubjectShape"], focus: ["A-2"] } },
    { id: "4.F3a", name: "F3 two-sided readiness: the order set ready while a line is in preparation (order side)", update: req(del(G, "o:A ontara-cafe:orderLifecycle ontara-cafe:OrderLifecycle-inPreparation"), ins(G, "o:A ontara-cafe:orderLifecycle ontara-cafe:OrderLifecycle-ready")), want: { outcome: "rejected", mode: "targeted", shapes: ["OrderReadinessTwoSidedShape"], focus: ["A"] } },
    { id: "4.F3b", name: "F3: per-line collection (one line collected, one ready, the order ready) commits", update: ready, want: { outcome: "committed", mode: "targeted" }, whole: { conforms: true } },
    { id: "4.F3c", name: "F3: a line-only regression on a ready order is caught by the line side", setupWrite: ready, update: regress, want: { outcome: "rejected", mode: "targeted", shapes: ["LineReadinessTwoSidedShape"], focus: ["A-1"] } },
    { id: "4.F4", name: "F4 bounded count: nine more lines (eleven)", update: req(ins(G, Array.from({ length: 9 }, (_, k) => `o:A cafe:hasLine o:A-x${k} . o:A-x${k} a ontara-cafe:OrderLine ; cafe:lineOf o:A ; cafe:menuItem cafe:FlatWhite ; cafe:quantity 1 ; ontara-cafe:orderLinePreparation ontara-cafe:OrderLinePreparation-queued .`).join(" "))), want: { outcome: "rejected", mode: "targeted", shapes: ["OrderLineCountShape-lines"], focus: ["A"] } },
    { id: "4.F5a", name: "F5 inverse-pair equality (sh:inversePath + sh:equals): a line claims an order that does not list it", update: req(ins(G, "o:C-1 a ontara-cafe:OrderLine ; cafe:lineOf o:A ; cafe:menuItem cafe:FlatWhite ; cafe:quantity 1 ; ontara-cafe:orderLinePreparation ontara-cafe:OrderLinePreparation-queued")), want: { outcome: "rejected", mode: "targeted", shapes: ["LineInversePairShape-order", "OrderInversePairShape-lines"], focus: ["C-1", "A"] } },
    { id: "4.F5b", name: "F5: the order drops hasLine to a line that still names it", update: req(del(G, "o:A cafe:hasLine o:A-2")), want: { outcome: "rejected", mode: "targeted", shapes: ["LineInversePairShape-order", "OrderInversePairShape-lines"], focus: ["A-2", "A"] } },
    { id: "4.F5c", name: "F5: a new line written with both links commits", update: req(ins(G, "o:A cafe:hasLine o:A-3 . o:A-3 a ontara-cafe:OrderLine ; cafe:lineOf o:A ; cafe:menuItem cafe:FlatWhite ; cafe:quantity 1 ; ontara-cafe:orderLinePreparation ontara-cafe:OrderLinePreparation-ready")), want: { outcome: "committed", mode: "targeted" }, whole: { conforms: true } },
    { id: "4.F6", name: "F6 uniqueness through a slot: a second order takes display slot 047", update: req(ins(G, "o:D a ontara-cafe:Order ; ontara-cafe:orderLifecycle ontara-cafe:OrderLifecycle-placed ; ontara-cafe:orderPayment ontara-cafe:OrderPayment-unpaid ; cafe:displayNumberSlot cafe:slot-047 ; cafe:hasLine o:D-1 . o:D-1 a ontara-cafe:OrderLine ; cafe:lineOf o:D ; cafe:menuItem cafe:FlatWhite ; cafe:quantity 1 ; ontara-cafe:orderLinePreparation ontara-cafe:OrderLinePreparation-queued")), want: { outcome: "rejected", mode: "targeted", shapes: ["DisplayNumberSlotShape-orders"], focus: ["slot-047"] } },
    { id: "4.F7a", name: "F7 reference typing: a line names an untyped item", update: req(del(G, "o:A-2 cafe:menuItem cafe:Croissant"), ins(G, "o:A-2 cafe:menuItem cafe:Mystery")), want: { outcome: "rejected", mode: "targeted", shapes: ["LineMenuItemShape-item", "ReferencedMenuItemShape"], focus: ["A-2", "Mystery"] } },
    { id: "4.F7b", name: "F7: a named item loses its type (the object-side twin catches it)", update: req(del(G, "cafe:Croissant a cafe:MenuItem")), want: { outcome: "rejected", mode: "targeted", shapes: ["ReferencedMenuItemShape"], focus: ["Croissant"] } },
    { id: "4.F8a", name: "F8 literal constraints: quantity 0", update: req(del(G, "o:A-2 cafe:quantity 2"), ins(G, "o:A-2 cafe:quantity 0")), want: { outcome: "rejected", mode: "targeted", shapes: ["LineQuantityShape-quantity"], focus: ["A-2"] } },
    { id: "4.F8b", name: "F8: quantity as a string", update: req(del(G, "o:A-2 cafe:quantity 2"), ins(G, `o:A-2 cafe:quantity "2"`)), want: { outcome: "rejected", mode: "targeted", shapes: ["LineQuantityShape-quantity"], focus: ["A-2"] } },
    { id: "4.F9a", name: "F9 conditional exclusion (one-sided by intent): a line written with a vegan item and dairy milk", update: req(del(G, "o:A-1 cafe:menuItem cafe:FlatWhite ; cafe:milk cafe:Oat"), ins(G, "o:A-1 cafe:menuItem cafe:OatLatte ; cafe:milk cafe:Whole")), want: { outcome: "rejected", mode: "targeted", shapes: ["VeganNoDairyShape"], focus: ["A-1"] } },
    { id: "4.F9b", name: "F9: the catalogue write that makes an item vegan after a dairy line exists is missed by targeted validation and found by the whole-graph check", setup: "o:A-1 cafe:milk cafe:Whole .", update: req(del(G, "cafe:FlatWhite cafe:isVegan false"), ins(G, "cafe:FlatWhite cafe:isVegan true")), want: { outcome: "committed", mode: "targeted" }, whole: { conforms: false, shapes: ["VeganNoDairyShape"] } },
    { id: "4.F10", name: "F10 SHACL-SPARQL on the resource its own write can falsify: a Direct record derived from an Inferred one", update: req(ins(G, "o:r3 rec:hasProvenanceMethod rec:DirectMethod ; prov:wasDerivedFrom o:r2")), want: { outcome: "rejected", mode: "targeted", shapes: ["WeakestMethodShape"], focus: ["r3"] } },
    { id: "4.F10b", name: "F10: an Inferred record derived from an Inferred one commits", update: req(ins(G, "o:r4 rec:hasProvenanceMethod rec:InferredMethod ; prov:wasDerivedFrom o:r2")), want: { outcome: "committed", mode: "targeted" }, whole: { conforms: true } },
  ];
  // F9's setup needs the dairy milk on A-1 (a conforming state: FlatWhite is not vegan yet).
  for (const c of list) {
    await loadBase();
    if (c.setup) await must(db.update(`${PFX} DELETE DATA { GRAPH <${G}> { o:A-1 cafe:milk cafe:Oat } } ; INSERT DATA { GRAPH <${G}> { ${c.setup} } }`), `${c.id} setup`);
    if (c.setupWrite) { const s = await vu(STORE, c.setupWrite, pol); if (s.outcome !== "committed") throw new Error(`${c.id} set-up write was ${s.outcome}: ${s.body.slice(0, 300)}`); }
    const r = await vu(STORE, c.update, pol);
    check(4, c.id, c.name, r, c.want);
    if (c.whole) checkWhole(4, `${c.id}w`, `${c.id}, the same data validated whole`, await W(), c.whole.conforms, c.whole.shapes ?? []);
  }

  // E1: an aggregate on a resource the summarised writes do not touch.
  const DAY = `o:A cafe:day "2026-11-03" . cafe:sum-1103 a cafe:DailySummary ; cafe:day "2026-11-03" ; cafe:orderCount 1 .`;
  const NEW = `o:E a ontara-cafe:Order ; cafe:day "2026-11-03" ; ontara-cafe:orderLifecycle ontara-cafe:OrderLifecycle-placed ; ontara-cafe:orderPayment ontara-cafe:OrderPayment-unpaid ; cafe:hasLine o:E-1 . o:E-1 a ontara-cafe:OrderLine ; cafe:lineOf o:E ; cafe:menuItem cafe:FlatWhite ; cafe:quantity 1 ; ontara-cafe:orderLinePreparation ontara-cafe:OrderLinePreparation-queued .`;
  await loadBase(DAY);
  let r = await vu(STORE, req(ins(G, NEW)), pol);
  check(4, "4.E1a", "E1 aggregate: a new order of the day, the summary not rewritten: missed by targeted validation", r, { outcome: "committed", mode: "targeted" });
  checkWhole(4, "4.E1aw", "4.E1a, the same data validated whole: the stale count is found", await W(), false, ["DailySummaryCountShape"], ["sum-1103"]);
  await loadBase(DAY);
  r = await vu(STORE, req(ins(G, NEW), del(G, "cafe:sum-1103 cafe:orderCount 1"), ins(G, "cafe:sum-1103 cafe:orderCount 3")), pol);
  check(4, "4.E1b", "E1 following the rule (the summary rewritten in the same request), wrongly: caught", r, { outcome: "rejected", mode: "targeted", shapes: ["DailySummaryCountShape"], focus: ["sum-1103"] });
  await loadBase(DAY);
  r = await vu(STORE, req(ins(G, NEW), del(G, "cafe:sum-1103 cafe:orderCount 1"), ins(G, "cafe:sum-1103 cafe:orderCount 2")), pol);
  check(4, "4.E1c", "E1 following the rule, rightly: commits", r, { outcome: "committed", mode: "targeted" });
  checkWhole(4, "4.E1cw", "4.E1c, the same data validated whole", await W(), true);

  // E1 with a sub-select (Cyril's finding 6), its shape loaded alone.
  await setShapes([SHAPES.e1Subselect]);
  const st = await db.status();
  await loadBase(DAY);
  const wrong = await vu(STORE, req(ins(G, NEW), del(G, "cafe:sum-1103 cafe:orderCount 1"), ins(G, "cafe:sum-1103 cafe:orderCount 3")), pol);
  await loadBase(DAY);
  const right = await vu(STORE, req(ins(G, NEW), del(G, "cafe:sum-1103 cafe:orderCount 1"), ins(G, "cafe:sum-1103 cafe:orderCount 2")), pol);
  const enforced = wrong.outcome === "rejected" && shapesOf(wrong).includes("DailySummaryCountSubselectShape") && right.outcome === "committed";
  const refusedAtParse = !!st.shapesError || st.targetShapes < 0;
  record({ group: 4, id: "4.E1s", name: "E1 written with a SHACL-SPARQL sub-select using $this (Cyril's finding 6): does Jena accept and enforce it?",
    expected: "either accepted and enforced (a wrong count rejected, a right count committed) or refused cleanly when the shapes are read",
    observed: `shapes parse: ${refusedAtParse ? `NO (${st.shapesError ?? "targetShapes " + st.targetShapes})` : `yes (targetShapes ${st.targetShapes})`}; wrong count: ${wrong.outcome}${shapesOf(wrong).length ? ` (${shapesOf(wrong).join(", ")})` : ""}${wrong.status >= 500 ? ` ${wrong.body.slice(0, 200)}` : ""}; right count: ${right.outcome}`,
    pass: enforced || (refusedAtParse && wrong.outcome !== "committed"), validation: wrong.validation });
  await setShapes(formsSet);

  // E2: a knowledge-graph change that falsifies runtime data.
  await loadBase();
  r = await vu(STORE, req(`DELETE DATA { GRAPH <${KG_GRAPHS.domain}> { cafe:Drink rdfs:subClassOf cafe:MenuItem } }`));
  check(4, "4.E2", "E2 a knowledge-graph change (Drink no longer a MenuItem; no policy, as a knowledge-graph load stands in): missed by targeted validation", r, { outcome: "committed", mode: "targeted" });
  checkWhole(4, "4.E2w", "4.E2, the same data validated whole: every line naming a drink is found", await W(), false, ["LineMenuItemShape-item", "ReferencedMenuItemShape"]);
  await must(db.appendGraph(KG_GRAPHS.domain, ttl("scoping/data/kg-standin.ttl"), "text/turtle"), "kg stand-in restored");

  // E3: a constraint that becomes false with time alone.
  await loadBase();
  const due = new Date(Date.now() + 4000).toISOString();
  r = await vu(STORE, req(ins(G, `o:T a ontara-cafe:Order ; ontara-cafe:orderLifecycle ontara-cafe:OrderLifecycle-placed ; ontara-cafe:orderPayment ontara-cafe:OrderPayment-unpaid ; cafe:hasLine o:T-1 ; cafe:collectBy "${due}"^^xsd:dateTime . o:T-1 a ontara-cafe:OrderLine ; cafe:lineOf o:T ; cafe:menuItem cafe:FlatWhite ; cafe:quantity 1 ; ontara-cafe:orderLinePreparation ontara-cafe:OrderLinePreparation-queued`)), pol);
  check(4, "4.E3a", "E3 time-only (NOW()): an order with a collect-by time 4 s ahead commits (true when written)", r, { outcome: "committed", mode: "targeted" });
  checkWhole(4, "4.E3b", "E3: validated whole at once, it conforms", await W(), true);
  await new Promise((res) => setTimeout(res, 5000));
  checkWhole(4, "4.E3c", "E3: validated whole 5 s later, with no write in between, it is found", await W(), false, ["CollectByShape"], ["T"]);

  // E4: an unbounded path.
  await loadBase();
  r = await vu(STORE, req(ins(G, "o:q1 rec:quarantines o:r1")), pol);
  check(4, "4.E4", "E4 unbounded path (sh:oneOrMorePath): quarantining an ancestor is missed by targeted validation", r, { outcome: "committed", mode: "targeted" });
  checkWhole(4, "4.E4w", "4.E4, the same data validated whole: the descendant is found", await W(), false, ["NoQuarantinedAncestryShape-ancestry"], ["r2"]);
  await loadBase();
  r = await vu(STORE, req(ins(G, "o:q2 rec:quarantines o:r2 . o:r5 rec:hasProvenanceMethod rec:InferredMethod ; prov:wasDerivedFrom o:r2")), pol);
  check(4, "4.E4b", "E4: a new record whose own ancestry is quarantined, in one request: caught (the new record is touched)", r, { outcome: "rejected", mode: "targeted", shapes: ["NoQuarantinedAncestryShape-ancestry"], focus: ["r5"] });

  await must(db.update(`${PFX} DELETE DATA { GRAPH <${KG_GRAPHS.domain}> { cafe:Drink rdfs:subClassOf cafe:MenuItem } }`), "kg stand-in removed");
  await resetBranch();
}

// ------------------------------------------------------------- group 5
async function group5() {
  console.log("\n== Group 5: the known blind spot (F11, a shape that breaks the shape-authoring rule)");
  const pol = writePolicy(rrb);
  const G = rrb.dbr;
  await must(db.appendGraph(KG_GRAPHS.domain, ttl("scoping/data/kg-standin.ttl"), "text/turtle"), "kg stand-in");
  const ready = req(del(G, "o:A-2 ontara-cafe:orderLinePreparation ontara-cafe:OrderLinePreparation-inPreparation . o:A ontara-cafe:orderLifecycle ontara-cafe:OrderLifecycle-inPreparation"),
                    ins(G, "o:A-2 ontara-cafe:orderLinePreparation ontara-cafe:OrderLinePreparation-collected . o:A ontara-cafe:orderLifecycle ontara-cafe:OrderLifecycle-ready"));
  const regress = req(mod(G, "o:A-1 ontara-cafe:orderLinePreparation ?v", "o:A-1 ontara-cafe:orderLinePreparation ontara-cafe:OrderLinePreparation-inPreparation", "o:A-1 ontara-cafe:orderLinePreparation ?v"));

  await setShapes([SHAPES.axis, SHAPES.blindspot]);
  await loadBase();
  let r = await vu(STORE, ready, pol);
  check(5, "5.1", "Set-up: the order ready, one line ready and one collected (one-sided readiness shape loaded, no line-side twin)", r, { outcome: "committed", mode: "targeted" });
  checkWhole(5, "5.2", "Set-up validated whole: conforms", await wholeGraph(STORE, G), true);
  r = await vu(STORE, regress, pol);
  check(5, "5.3", "The line-only regression on the ready order is MISSED by targeted validation: it commits (the order is not touched, so the order-side shape is not run)", r, { outcome: "committed", mode: "targeted" });
  checkWhole(5, "5.4", "The same data validated whole: the order breaks the one-sided readiness shape", await wholeGraph(STORE, G), false, ["OneSidedReadinessShape"], ["A"]);
  await setShapes([SHAPES.axis, SHAPES.readiness]);
  await loadBase();
  r = await vu(STORE, ready, pol);
  if (r.outcome !== "committed") throw new Error(`5.5 set-up was ${r.outcome}`);
  r = await vu(STORE, regress, pol);
  check(5, "5.5", "Contrast: with the two-sided shapes (the rule followed), the same write is rejected by the line side", r, { outcome: "rejected", mode: "targeted", shapes: ["LineReadinessTwoSidedShape"], focus: ["A-1"] });
  await must(db.update(`${PFX} DELETE DATA { GRAPH <${KG_GRAPHS.domain}> { cafe:Drink rdfs:subClassOf cafe:MenuItem } }`), "kg stand-in removed");
  await resetBranch();
}

// ------------------------------------------------------------- group 6
async function gateWrite(body: unknown, opts: { turtleGraph?: string } = {}): Promise<{ status: number; j: any }> {
  const r = opts.turtleGraph !== undefined
    ? await http("POST", `${GATE}/write?graph=${encodeURIComponent(opts.turtleGraph)}`, { body: String(body), contentType: "text/turtle", timeoutMs: 60_000 })
    : await http("POST", `${GATE}/write`, { body: JSON.stringify(body), contentType: "application/json", timeoutMs: 60_000 });
  let j: any = null; try { j = JSON.parse(r.body); } catch { j = { raw: r.body.slice(0, 300) }; }
  return { status: r.status, j };
}
function checkGate(id: string, name: string, g: { status: number; j: any }, want: { outcome: string; stage?: string; rules?: string[] }, unchanged: boolean | null) {
  const rules: string[] = g.j?.rules ?? [];
  const pass = g.j?.outcome === want.outcome && (!want.stage || g.j?.stage === want.stage) && (want.rules ?? []).every((x) => rules.includes(x)) && unchanged !== false;
  record({ group: 6, id, name,
    expected: [want.outcome, want.stage ? `at ${want.stage}` : "", want.rules?.length ? `rule ${want.rules.join(", ")}` : "", unchanged === null ? "" : "store unchanged"].filter(Boolean).join(", "),
    observed: [`HTTP ${g.status} ${g.j?.outcome}`, g.j?.stage ? `at ${g.j.stage}` : "", rules.length ? `rule ${rules.join(", ")}` : "", unchanged === null ? "" : `store unchanged: ${unchanged}`, g.j?.outcome === "fault" ? String(g.j?.detail).slice(0, 200) : ""].filter(Boolean).join(", "),
    pass, validation: g.j?.validation ?? null });
}

async function group6() {
  console.log("\n== Group 6: the scheme's refusals (B3 item 4), through the suite's gate, and against the module in both modes");
  await setShapes(SHAPES.runtime);
  await resetBranch();
  // A second DHB. Only the RRB exists at Stage 0 (Pass B writes no declaration),
  // so the suite makes one: a fresh lower-case UUID v4 through the templates,
  // its graph seeded with no policy (stack network), as a second branch's write would leave it.
  const other = branch(TENANT, randomUUID());
  const NH = "urn:ontara:standin:cafe#order-scoping-not-home";
  const nhSeed = `INSERT DATA { GRAPH <${other.dbr}> { <${NH}> a <https://ontara.dev/ontology/tenant/cafe/Order> ; <https://ontara.dev/ontology/tenant/cafe/orderLifecycle> <https://ontara.dev/ontology/tenant/cafe/OrderLifecycle-placed> ; <https://ontara.dev/ontology/tenant/cafe/orderPayment> <https://ontara.dev/ontology/tenant/cafe/OrderPayment-unpaid> } }`;
  const seeded = await vu(STORE, nhSeed);
  if (seeded.outcome !== "committed") throw new Error(`group 6 seed of the second DHB: ${seeded.outcome} ${seeded.body.slice(0, 300)}`);
  const M = (s: string) => `<urn:ontara:standin:scoping#${s}> <${RDFS}comment> "scoping refusal test"`;

  const viaGate = async (id: string, name: string, body: unknown, want: { outcome: string; stage?: string; rules?: string[] }, opts: { turtleGraph?: string } = {}) => {
    const b = await countAll();
    const g = await gateWrite(body, opts);
    const a = await countAll();
    checkGate(id, name, g, want, want.outcome === "committed" ? null : a === b);
    return g;
  };
  const O = "urn:ontara:standin:cafe#order-scoping-g6";
  await viaGate("6.0", "Control: a conforming order through the gate commits (into the RRB's dbr)", orderWrite(O), { outcome: "committed" });
  await viaGate("6.1", "Rule default-graph: a quad in the default graph", { updates: [`INSERT DATA { ${M("dg")} }`] }, { outcome: "refused", stage: "store", rules: ["default-graph"] });
  let k = 0;
  for (const [name, g] of [...Object.entries(KG_GRAPHS), ["shapes", SHAPES_GRAPH]] as [string, string][]) {
    k++;
    await viaGate(`6.2${"abcd"[k - 1]}`, `Rule knowledge-graph-or-shapes: a runtime write into ${name === "shapes" ? "the shapes graph" : `kg/${name}`}`, { updates: [`INSERT DATA { GRAPH <${g}> { ${M("kg")} } }`] }, { outcome: "refused", stage: "store", rules: ["knowledge-graph-or-shapes"] });
  }
  await viaGate("6.2e", "Rule knowledge-graph-or-shapes: a runtime DELETE DATA from kg/domain (ontara-cafe:Order a owl:Class)", { updates: [`DELETE DATA { GRAPH <${KG_GRAPHS.domain}> { <https://ontara.dev/ontology/tenant/cafe/Order> a <http://www.w3.org/2002/07/owl#Class> } }`] }, { outcome: "refused", stage: "store", rules: ["knowledge-graph-or-shapes"] });
  await viaGate("6.3", "Rule other-branch: one request writing into the RRB's dbr and a second DHB's dbr (a request spanning two DHBs)", { updates: [`INSERT DATA { GRAPH <{{DBR}}> { ${M("span1")} } GRAPH <${other.dbr}> { ${M("span2")} } }`] }, { outcome: "refused", stage: "store", rules: ["other-branch"] });
  await viaGate("6.4", "Rule not-home: a triple about an instance whose home is a second DHB (seeded there), sent as Turtle: the WSS places it in the RRB, the module refuses it", { turtle: `<${NH}> <urn:ontara:standin:cafe#counter> "counter-2" .` }, { outcome: "refused", stage: "store", rules: ["not-home"] });
  await viaGate("6.5", "Rule operation: CLEAR of the branch's own dbr graph", { updates: ["CLEAR GRAPH <{{DBR}}>"] }, { outcome: "refused", stage: "store", rules: ["operation"] });
  await viaGate("6.6", "Rule outside-scheme: a write into the retired provisional graph urn:ontara:stack:graph:manual", { updates: [`INSERT DATA { GRAPH <urn:ontara:stack:graph:manual> { ${M("manual")} } }`] }, { outcome: "refused", stage: "store", rules: ["outside-scheme"] });
  await viaGate("6.7a", "Rule graph-from-writer: a JSON write naming its graph", { turtle: orderWrite(`${O}-named`).turtle, graph: rrb.dbr }, { outcome: "refused", stage: "gate", rules: ["graph-from-writer"] });
  await viaGate("6.7b", "Rule graph-from-writer: a text/turtle write with ?graph=", orderWrite(`${O}-named2`).turtle, { outcome: "refused", stage: "gate", rules: ["graph-from-writer"] }, { turtleGraph: KG_GRAPHS.domain });
  await viaGate("6.8", "Rule no-readable-side: an untyped subject", { turtle: `${M("untyped")} .` }, { outcome: "refused", stage: "gate", rules: ["no-readable-side"] });
  // remove's scope: the branch's two graphs only.
  const RM = "urn:ontara:standin:cafe#order-scoping-remove";
  await vu(STORE, `INSERT DATA { GRAPH <${rrb.dbr}> { <${RM}> <${RDFS}comment> "here" } GRAPH <${other.dbr}> { <${RM}> <${RDFS}comment> "there" } }`);
  const g = await gateWrite({ remove: [RM] });
  const inRrb = await db.ask(`ASK { GRAPH <${rrb.dbr}> { <${RM}> ?p ?o } }`), inOther = await db.ask(`ASK { GRAPH <${other.dbr}> { <${RM}> ?p ?o } }`);
  record({ group: 6, id: "6.9", name: "A request's remove list acts only on its own DHB's two graphs", expected: "committed; gone from the RRB's dbr; still in the second DHB's dbr", observed: `HTTP ${g.status} ${g.j?.outcome}; in RRB dbr after: ${inRrb}; in second DHB's dbr after: ${inOther}`, pass: g.j?.outcome === "committed" && !inRrb && inOther, validation: g.j?.validation ?? null });
  // The published listener refuses validated-update writes.
  const pub = await vu(PUBLISHED_INSIDE, req(ins(rrb.dbr, M("published"))), writePolicy(rrb));
  check(6, "6.10", "The published listener (3031) refuses a validated-update write, even with a policy", pub, { outcome: "refused (405)" });

  // The same refusals in whole mode, against the module directly (store-whole).
  const ws = openStore(DS, WHOLE);
  const wst = await ws.status();
  const wrrb = branch(TENANT, wst.rrb!.dhbId);
  const wother = branch(TENANT, randomUUID());
  const wpol = writePolicy(wrrb);
  await vu(WHOLE, nhSeed.replace(other.dbr, wother.dbr));
  const W = async (id: string, name: string, body: string, want: Want) => {
    const b = await countAll(WHOLE); const r = await vu(WHOLE, body, wpol); const a = await countAll(WHOLE);
    check(6, id, name, r, want, want.outcome === "committed" ? undefined : { pass: a === b, note: `store unchanged: ${a === b}` });
  };
  await W("6.11a", "Whole mode: a conforming write commits (control)", `INSERT DATA { GRAPH <${wrrb.dbr}> { ${M("w-ok")} } }`, { outcome: "committed", mode: "whole" });
  await W("6.11b", "Whole mode: default-graph", `INSERT DATA { ${M("w-dg")} }`, { outcome: "refused", rules: ["default-graph"] });
  await W("6.11c", "Whole mode: knowledge-graph-or-shapes (kg/domain)", `INSERT DATA { GRAPH <${KG_GRAPHS.domain}> { ${M("w-kg")} } }`, { outcome: "refused", rules: ["knowledge-graph-or-shapes"] });
  await W("6.11d", "Whole mode: knowledge-graph-or-shapes (the shapes graph)", `INSERT DATA { GRAPH <${SHAPES_GRAPH}> { ${M("w-sh")} } }`, { outcome: "refused", rules: ["knowledge-graph-or-shapes"] });
  await W("6.11e", "Whole mode: other-branch (two DHBs in one request)", `INSERT DATA { GRAPH <${wrrb.dbr}> { ${M("w-s1")} } GRAPH <${wother.dbr}> { ${M("w-s2")} } }`, { outcome: "refused", rules: ["other-branch"] });
  await W("6.11f", "Whole mode: not-home", `INSERT DATA { GRAPH <${wrrb.dbr}> { <${NH}> <urn:ontara:standin:cafe#counter> "counter-2" } }`, { outcome: "refused", rules: ["not-home"] });
  await W("6.11g", "Whole mode: operation (CLEAR)", `CLEAR GRAPH <${wrrb.dbr}>`, { outcome: "refused", rules: ["operation"] });
  await W("6.11h", "Whole mode: outside-scheme", `INSERT DATA { GRAPH <urn:ontara:stack:graph:manual> { ${M("w-man")} } }`, { outcome: "refused", rules: ["outside-scheme"] });

  await must(db.update(`DROP SILENT GRAPH <${other.dbr}>`), "drop the second DHB's graph");
  await resetBranch();
}

// ------------------------------------------------------------- group 7
// Each write route of a Fuseki dataset. `marker` is a triple no other test writes.
function writeRoutes(ds: string, g: string, mk: string) {
  const triple = `<urn:ontara:standin:scoping#${mk}> <${RDFS}comment> "endpoint closure test" .`;
  const upd = `INSERT DATA { GRAPH <${g}> { ${triple} } }`;
  const nq = `<urn:ontara:standin:scoping#${mk}> <${RDFS}comment> "endpoint closure test" <${g}> .\n`;
  const patch = `TX .\nA <urn:ontara:standin:scoping#${mk}> <${RDFS}comment> "endpoint closure test" <${g}> .\nTC .\n`;
  const q = (s: string) => `?graph=${encodeURIComponent(s)}`;
  return [
    { route: `POST /${ds}/update (sparql-update)`, method: "POST", path: `/${ds}/update`, body: upd, ct: "application/sparql-update" },
    { route: `POST /${ds}/update (form update=)`, method: "POST", path: `/${ds}/update`, body: `update=${encodeURIComponent(upd)}`, ct: "application/x-www-form-urlencoded" },
    { route: `POST /${ds} (form update=)`, method: "POST", path: `/${ds}`, body: `update=${encodeURIComponent(upd)}`, ct: "application/x-www-form-urlencoded" },
    { route: `POST /${ds} (sparql-update)`, method: "POST", path: `/${ds}`, body: upd, ct: "application/sparql-update" },
    { route: `PUT /${ds}/data?graph=`, method: "PUT", path: `/${ds}/data${q(g)}`, body: triple, ct: "text/turtle" },
    { route: `POST /${ds}/data?graph=`, method: "POST", path: `/${ds}/data${q(g)}`, body: triple, ct: "text/turtle" },
    { route: `DELETE /${ds}/data?graph=`, method: "DELETE", path: `/${ds}/data${q(g)}`, body: undefined, ct: undefined },
    { route: `PUT /${ds}/data?default`, method: "PUT", path: `/${ds}/data?default`, body: triple, ct: "text/turtle" },
    { route: `POST /${ds}/data?default`, method: "POST", path: `/${ds}/data?default`, body: triple, ct: "text/turtle" },
    { route: `PUT /${ds}?graph=`, method: "PUT", path: `/${ds}${q(g)}`, body: triple, ct: "text/turtle" },
    { route: `POST /${ds}?graph=`, method: "POST", path: `/${ds}${q(g)}`, body: triple, ct: "text/turtle" },
    { route: `DELETE /${ds}?graph=`, method: "DELETE", path: `/${ds}${q(g)}`, body: undefined, ct: undefined },
    { route: `POST /${ds} (n-quads)`, method: "POST", path: `/${ds}`, body: nq, ct: "application/n-quads" },
    { route: `PUT /${ds} (n-quads)`, method: "PUT", path: `/${ds}`, body: nq, ct: "application/n-quads" },
    { route: `PATCH /${ds} (RDF Patch)`, method: "PATCH", path: `/${ds}`, body: patch, ct: "application/rdf-patch" },
    { route: `POST /${ds}/patch (RDF Patch)`, method: "POST", path: `/${ds}/patch`, body: patch, ct: "application/rdf-patch" },
    { route: `POST /${ds}/validated-update`, method: "POST", path: `/${ds}/validated-update`, body: upd, ct: "application/sparql-update" },
  ];
}

// The closure, tested against one listener. Reads of the store go through
// `readBase` (any listener serves reads). "Unchanged" is checked three ways:
// the total triple count, the marker triple absent, and the delete target
// (a triple left in the RRB's dbr for the DELETE and PUT routes to act on)
// still present. Returns one case per route.
export const DELETE_TARGET = "urn:ontara:standin:scoping#delete-target";
export async function closure(group: number, idPrefix: string, where: string, base: string, readBase: string, expectRefused: boolean, routes?: string[]) {
  const reader = openStore(DS, readBase);
  const st = await reader.status();
  const b = branch(TENANT, st.rrb!.dhbId);
  const out: Case[] = [];
  const marker = `marker-${idPrefix.replace(/\./g, "-")}`;
  const snap = async () => ({
    total: Number((await reader.select(`SELECT (COUNT(*) AS ?n) WHERE { { GRAPH ?g { ?s ?p ?o } } UNION { GRAPH <${STORED_DEFAULT_GRAPH}> { ?s ?p ?o } } }`))[0]?.n?.value ?? -1),
    marker: await reader.ask(`ASK { { GRAPH ?g { <urn:ontara:standin:scoping#${marker}> ?p ?o } } UNION { GRAPH <${STORED_DEFAULT_GRAPH}> { <urn:ontara:standin:scoping#${marker}> ?p ?o } } }`),
    target: await reader.ask(`ASK { GRAPH <${b.dbr}> { <${DELETE_TARGET}> ?p ?o } }`),
  });
  let n = 0;
  for (const rt of writeRoutes(DS, b.dbr, marker)) {
    if (routes && !routes.includes(rt.route)) continue;
    n++;
    const before = await snap();
    let status = 0, err = "";
    try {
      const r = await http(rt.method, `${base}${rt.path}`, { body: rt.body, contentType: rt.ct, timeoutMs: 30_000 });
      status = r.status;
    } catch (e: any) { err = String(e?.cause?.code ?? e?.message ?? e); }
    const after = await snap();
    const same = before.total === after.total && !after.marker && before.target === after.target;
    const ok2xx = status >= 200 && status < 300;
    const pass = err ? false : expectRefused ? (!ok2xx && same && before.target) : ok2xx;
    out.push({ group, id: `${idPrefix}.${n}`, name: `${where}: ${rt.route}`,
      expected: expectRefused ? "refused (not 2xx); store unchanged (count, no marker, delete target kept)" : "accepted (2xx)",
      observed: err ? `no reply: ${err}` : `HTTP ${status}; ${same ? "store unchanged" : `store CHANGED (triples ${before.total} to ${after.total}, marker ${after.marker}, delete target ${before.target} to ${after.target})`}${expectRefused && !before.target ? "; delete target missing before the request" : ""}`, pass });
  }
  return out;
}
async function seedDeleteTarget() {
  await must(db.update(`INSERT DATA { GRAPH <${rrb.dbr}> { <${DELETE_TARGET}> <${RDFS}comment> "a triple for the DELETE and PUT routes to act on" } }`), "seed the delete target");
}

async function group7() {
  console.log("\n== Group 7: two store behaviours D1 could not confirm");
  await setShapes(SHAPES.runtime);
  await resetBranch();
  // 7.1 Where a default-graph write lands, and whether validation sees it.
  const DG = "urn:ontara:standin:cafe#order-scoping-default-graph";
  const where = async (base: string) => {
    const s = openStore(DS, base);
    const stored = await s.ask(`ASK { GRAPH <${STORED_DEFAULT_GRAPH}> { <${DG}> ?p ?o } }`);
    const union = await s.ask(`ASK { <${DG}> ?p ?o }`);
    const named = (await s.select(`SELECT DISTINCT ?g WHERE { GRAPH ?g { <${DG}> ?p ?o } }`)).map((x: any) => x.g.value);
    return { stored, union, named };
  };
  const body = `INSERT DATA { <${DG}> a <https://ontara.dev/ontology/tenant/cafe/Order> }`;
  for (const [id, label, base] of [["7.1a", "targeted", STORE], ["7.1b", "whole", WHOLE]] as const) {
    if (base === WHOLE) await setShapesOn(WHOLE, SHAPES.runtime);
    const r = await vu(base, body);
    const w = await where(base);
    const s2 = openStore(DS, base);
    const whole = await wholeGraph(base, (await branchOf(base)).dbr);
    const pass = r.outcome === "committed" && w.stored && !w.union && w.named.length === 0 && whole.outcome === "committed";
    record({ group: 7, id, name: `A default-graph write sent straight to the module (stack network, no policy), ${label} mode: an Order with neither axis value, which every axis shape would reject if it saw it`,
      expected: "committed; stored in Jena's stored default graph (urn:x-arq:DefaultGraph); not in the union default graph nor in any named graph; a whole-graph validation of the dataset still conforms: invisible to validation",
      observed: `${r.outcome} (${r.validation}); in the stored default graph: ${w.stored}; in the union default graph: ${w.union}; in named graphs: ${w.named.length ? w.named.join(", ") : "none"}; whole-graph validation: ${whole.outcome}${whole.report ? ` (${shapesOf(whole).join(", ")})` : ""}`,
      pass, validation: r.validation });
    await must(s2.update(`DELETE DATA { GRAPH <${STORED_DEFAULT_GRAPH}> { <${DG}> a <https://ontara.dev/ontology/tenant/cafe/Order> } }`), "remove the default-graph write");
    const gone = await where(base);
    record({ group: 7, id: `${id}x`, name: `The ${label}-mode default-graph triple is removed by naming urn:x-arq:DefaultGraph in an update`, expected: "gone", observed: gone.stored ? "still there" : "gone", pass: !gone.stored });
  }
  // The unvalidated /update endpoint lands it in the same place.
  await must(db.update(body), "default-graph write via /update");
  const w3 = await where(STORE);
  record({ group: 7, id: "7.1c", name: "The same write through Fuseki's unvalidated /update (stack network) lands in the same place", expected: "stored default graph only", observed: `stored default graph: ${w3.stored}; union: ${w3.union}; named: ${w3.named.length}`, pass: w3.stored && !w3.union && w3.named.length === 0 });
  // The placement queries see it (B4's backstop for exactly this).
  const tokens = placementTokens([rrb]);
  const rows: Record<string, any[]> = {};
  for (const f of PLACEMENT_QUERIES) rows[f] = await db.select(fillPlacement(fs.readFileSync(path.join(paths.fixtures, "placement", f), "utf8"), tokens), 120_000);
  const p2 = rows["P2-runtime-instances-in-runtime-graphs.rq"].some((x: any) => x.g?.value === STORED_DEFAULT_GRAPH && x.x?.value === DG);
  const p3 = rows["P3-known-graphs.rq"].some((x: any) => x.g?.value === STORED_DEFAULT_GRAPH);
  record({ group: 7, id: "7.1d", name: "The placement queries see the default-graph instance (P2: a runtime instance outside a runtime graph; P3: a non-empty stored default graph)", expected: "P2 and P3 each report it under urn:x-arq:DefaultGraph", observed: `P2: ${p2}; P3: ${p3}`, pass: p2 && p3 });
  await must(db.update(`DELETE DATA { GRAPH <${STORED_DEFAULT_GRAPH}> { <${DG}> a <https://ontara.dev/ontology/tenant/cafe/Order> } }`), "remove");

  // 7.2 The standard endpoints, inside the network: the published listener refuses every write route; the stack-network listener accepts them (control).
  const st = await db.status();
  const pubStatus = await openStore(DS, PUBLISHED_INSIDE).status();
  record({ group: 7, id: "7.2.0", name: "The published listener (3031) serves reads: the module's status and a query", expected: "status 200 from listener published, standardWriteEndpoints false; query answers", observed: `listener ${pubStatus.listener?.name}, standardWriteEndpoints ${pubStatus.listener?.standardWriteEndpoints}; query answered ${(await countAll(PUBLISHED_INSIDE)) >= 0}`, pass: pubStatus.listener?.name === "published" && pubStatus.listener?.standardWriteEndpoints === false && st.listener?.name === "stack-network" });
  await seedDeleteTarget();
  for (const c of await closure(7, "7.2", "Published listener 3031, from inside the network", PUBLISHED_INSIDE, STORE, true)) record(c);
  for (const c of await closure(7, "7.3", "Stack-network listener 3030 (control: the same requests are accepted there)", STORE, STORE, false,
    [`POST /${DS}/update (sparql-update)`, `POST /${DS}/update (form update=)`, `POST /${DS}?graph=`, `POST /${DS}/data?graph=`, `POST /${DS} (n-quads)`, `PATCH /${DS} (RDF Patch)`])) record(c);
  // Left for the outside leg (bin/scoping-test.sh runs it next): the RRB's dbr
  // holds only the delete target, so "unchanged" means something there too.
  await resetBranch();
  await seedDeleteTarget();
}
async function setShapesOn(base: string, files: string[]) {
  const s = openStore(DS, base);
  await must(s.replaceGraph(SHAPES_GRAPH, files.map((f) => readStackFile(f)).join("\n"), "text/turtle"), `shapes on ${base}`);
}
async function branchOf(base: string): Promise<Branch> { const s = await openStore(DS, base).status(); return branch(TENANT, s.rrb!.dhbId); }

// ------------------------------------------------------------- the outside leg
// Run from a container that is NOT on the stack's network: it reaches the
// store only through the port published on the host.
async function outside(url: string, rel: string) {
  let reached = false, detail = "";
  try { const s = await openStore(DS, url).status(); reached = s.listener?.name === "published"; detail = `listener ${s.listener?.name}`; }
  catch (e: any) { detail = String(e?.cause?.code ?? e?.message ?? e); }
  const out: Case[] = [];
  out.push({ group: 7, id: "7.4.0", name: `From outside the stack's network (${url}): the published port answers reads`, expected: "status 200 from the published listener", observed: reached ? detail : `not reached: ${detail}`, pass: reached });
  if (reached) out.push(...(await closure(7, "7.4", "From outside the stack's network, through the published port", url, url, true)));
  const dir = path.join(paths.results, rel);
  fs.mkdirSync(dir, { recursive: true });
  fs.writeFileSync(path.join(dir, "outside.json"), JSON.stringify({ url, reached, cases: out }, null, 2) + "\n");
  for (const c of out) console.log(`${c.pass ? "PASS" : "FAIL"}  ${c.id.padEnd(6)} ${c.name}\n        expected: ${c.expected}\n        observed: ${c.observed}`);
  process.exit(reached ? 0 : 3);
}

// ------------------------------------------------------------- summary
function summarise(rel: string) {
  const dir = path.join(paths.results, rel);
  const read = (f: string) => (fs.existsSync(path.join(dir, f)) ? JSON.parse(fs.readFileSync(path.join(dir, f), "utf8")) : null);
  const inside = read("inside.json"), outsideLeg = read("outside.json"), startup = read("startup-refusal.json");
  const all: Case[] = [...(inside?.cases ?? []), ...(outsideLeg?.cases ?? []), ...(startup?.cases ?? [])];
  const missing: string[] = [];
  if (!inside) missing.push("inside.json (the suite did not finish)");
  if (!outsideLeg) missing.push("outside.json (the outside leg did not run)");
  if (!startup) missing.push("startup-refusal.json (the start-up refusal case did not run)");
  const groups = [1, 2, 3, 4, 5, 6, 7];
  const byGroup = groups.map((g) => ({ group: g, cases: all.filter((c) => c.group === g).length, failed: all.filter((c) => c.group === g && !c.pass).length }));
  const failed = all.filter((c) => !c.pass);
  const pass = failed.length === 0 && missing.length === 0 && byGroup.every((g) => g.cases > 0);
  const titles: Record<number, string> = { 1: "Targeted forms", 2: "Other forms fall back to whole", 3: "Mixed requests", 4: "Shape forms F1 to F10, and E1 to E4", 5: "The known blind spot (F11)", 6: "The scheme's refusals", 7: "Default-graph writes; endpoint closure" };
  const summary = { suite: "stack scoping test suite (S0.5 Pass B2)", pass, cases: all.length, failed: failed.length, missing, byGroup, store: inside?.store, ranUtc: inside?.ranUtc, elapsedSeconds: inside?.elapsedSeconds };
  fs.writeFileSync(path.join(dir, "summary.json"), JSON.stringify({ ...summary, cases: all }, null, 2) + "\n");
  const md = [
    `# Scoping test suite: ${pass ? "PASS" : "FAIL"} (${all.length - failed.length} of ${all.length} cases)`, "",
    `Run ${inside?.ranUtc ?? "?"} on ${inside?.store?.module ?? "?"}, Jena ${inside?.store?.jenaVersion ?? "?"}, mode ${inside?.store?.validationMode ?? "?"}, RRB ${inside?.store?.rrb ?? "?"} (the suite's own store, project ontara-cafe-scoping).`, "",
    ...(missing.length ? [`Missing: ${missing.join("; ")}`, ""] : []),
    "| Group | Cases | Failed |", "|---|---|---|", ...byGroup.map((g) => `| ${g.group}. ${titles[g.group]} | ${g.cases} | ${g.failed} |`), "",
    "| Case | Name | Expected | Observed | Result |", "|---|---|---|---|---|",
    ...all.map((c) => `| ${c.id} | ${c.name.replace(/\|/g, "\\|")} | ${c.expected.replace(/\|/g, "\\|")} | ${c.observed.replace(/\|/g, "\\|")}${c.validation ? ` (\`${c.validation}\`)` : ""} | ${c.pass ? "PASS" : "FAIL"} |`), "",
  ].join("\n");
  fs.writeFileSync(path.join(dir, "cases.md"), md);
  for (const g of byGroup) console.log(`group ${g.group} (${titles[g.group]}): ${g.cases} case(s), ${g.failed} failed`);
  for (const c of failed) console.log(`FAILED ${c.id} ${c.name}: expected ${c.expected}; observed ${c.observed}`);
  for (const m of missing) console.log(`MISSING ${m}`);
  console.log(`SCOPING TEST SUITE: ${pass ? "PASS" : "FAIL"} (${all.length - failed.length} of ${all.length} cases)`);
  process.exit(pass ? 0 : 1);
}

// ------------------------------------------------------------- main
async function main() {
  const a = process.argv.slice(2);
  const arg = (k: string) => { const i = a.indexOf(k); return i >= 0 ? a[i + 1] : undefined; };
  const rel = arg("--out") ?? arg("--summarise");
  if (!rel) throw new Error("--out <results folder> (or --summarise <folder>) is required");
  if (a.includes("--summarise")) return summarise(rel);
  if (arg("--outside")) return outside(arg("--outside")!, rel);

  const t0 = Date.now();
  const st = await db.status();
  if (!st.validating || st.validationMode !== "targeted") throw new Error(`the suite's store is not validating in targeted mode: ${JSON.stringify({ validating: st.validating, mode: st.validationMode })}`);
  rrb = branch(TENANT, st.rrb!.dhbId);
  console.log(`[scoping] store ${STORE} (${st.module}, Jena ${st.jenaVersion}, ${st.validationMode}); RRB ${rrb.dhbId}; whole-mode store ${WHOLE}; gate ${GATE}`);
  const groups: [string, () => Promise<void>][] = [["1", group1], ["2", group2], ["3", group3], ["4", group4], ["5", group5], ["6", group6], ["7", group7]];
  const only = arg("--groups")?.split(",");
  let fault: string | null = null;
  for (const [n, f] of groups) {
    if (only && !only.includes(n)) continue;
    try { await f(); }
    catch (e: any) { fault = `group ${n}: ${e?.stack ?? e}`; console.error(`[scoping] FAULT in ${fault}`); record({ group: Number(n), id: `${n}.fault`, name: `group ${n} could not complete`, expected: "no fault", observed: String(e?.message ?? e).slice(0, 400), pass: false }); }
  }
  await setShapes(SHAPES.runtime).catch(() => undefined);
  const dir = path.join(paths.results, rel);
  fs.mkdirSync(dir, { recursive: true });
  fs.writeFileSync(path.join(dir, "inside.json"), JSON.stringify({
    ranUtc: new Date(t0).toISOString(), elapsedSeconds: Math.round((Date.now() - t0) / 100) / 10,
    store: { url: STORE, module: st.module, jenaVersion: st.jenaVersion, validationMode: st.validationMode, rrb: rrb.dhbId }, fault, cases,
  }, null, 2) + "\n");
  console.log(`[scoping] inside: ${cases.filter((c) => c.pass).length} of ${cases.length} passed in ${((Date.now() - t0) / 1000).toFixed(1)} s`);
  process.exit(fault ? 2 : 0);
}
if (require.main === module) main().catch((e) => { console.error(e); process.exit(2); });
