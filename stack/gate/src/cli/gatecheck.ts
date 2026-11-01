// Checks the gate's write path against a stand-in store (S519; ported to the
// Fuseki adapter at S521, S0.1 pass 3). Run by stack/bin/gate-check.sh. Needs
// no running stack: an in-process HTTP server stands in for Fuseki's
// validated-update and query endpoints and answers each case as scripted.
//
// The invariant kept from S519 (e42a70c): write() never rejects, and every
// failure becomes an outcome. The S519 rollback-before-read half fell away
// with GraphDB: the module aborts its own transaction before it answers, so
// the gate sends no rollback, and the check now asserts it sends nothing
// after the write request except the node-shape lookup.
//
//   1. parseable 422 rejection -> rejected, node shape named, rolledBack (aborted)
//   2. unparseable 422 rejection -> fault, "unreadable" with the body's start, rolledBack
//   3. 500 fault, transaction aborted -> fault, rolledBack
//   4. no store at all (connection refused) -> fault, transaction "unknown", not rolledBack
//   5. 200 commit -> committed, the X-Ontara-Validation header recorded verbatim
//   6. 200 commit with no X-Ontara-Validation header -> committed, validation null
//      (the load harness and capability checks treat this as a configuration fault)
//   7. a Turtle parse error -> fault before any request is sent
//
// Exit 0 when every case passes, 1 otherwise.
import * as http from "node:http";
import { AddressInfo } from "node:net";
import { FusekiStore } from "../store/fuseki";
import { WriteOutcome } from "../gate";

const SH = "http://www.w3.org/ns/shacl#";
const RDF_TYPE = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type";
const SHAPE = "urn:ontara:standin:shapes#RecordModeMethodShape";
const PROPERTY_SHAPE = `${SHAPE}-method`;
const TARGETED = "targeted; changes=2 touched=3 focus=1";

const UNPARSEABLE = "this is not an N-Triples report: the store sent something else";
const PARSEABLE = [
  `_:r <${RDF_TYPE}> <${SH}ValidationReport> .`,
  `_:r <${SH}conforms> "false"^^<http://www.w3.org/2001/XMLSchema#boolean> .`,
  `_:r <${SH}result> _:v .`,
  `_:v <${RDF_TYPE}> <${SH}ValidationResult> .`,
  `_:v <${SH}focusNode> <urn:ontara:standin:cafe#check-record> .`,
  `_:v <${SH}sourceShape> <${PROPERTY_SHAPE}> .`,
  `_:v <${SH}sourceConstraintComponent> <${SH}MinCountConstraintComponent> .`,
  `_:v <${SH}resultSeverity> <${SH}Violation> .`,
  `_:v <${SH}resultMessage> "A record with a mode must carry a provenance method." .`,
].join("\n");

interface Scripted { status: number; contentType: string; body: string; headers: Record<string, string> }
const REPORT_TYPE = "application/shacl-validation-report+n-triples";

// A stand-in Fuseki: /cafe-runtime/validated-update answers `reply`;
// /cafe-runtime/query answers the node-shape lookup. Every request is logged.
async function standIn(reply: Scripted): Promise<{ base: string; calls: string[]; close: () => Promise<void> }> {
  const calls: string[] = [];
  const server = http.createServer((req, res) => {
    const chunks: Buffer[] = [];
    req.on("data", (c) => chunks.push(c));
    req.on("end", () => {
      const url = req.url ?? "";
      calls.push(`${req.method} ${url.split("?")[0]}`);
      if (url.startsWith("/cafe-runtime/validated-update")) {
        res.writeHead(reply.status, { "Content-Type": reply.contentType, ...reply.headers });
        return res.end(reply.body);
      }
      if (url.startsWith("/cafe-runtime/query")) {
        res.writeHead(200, { "Content-Type": "application/sparql-results+json" });
        return res.end(JSON.stringify({ head: { vars: ["n"] }, results: { bindings: [{ n: { type: "uri", value: SHAPE } }] } }));
      }
      res.writeHead(404); res.end();
    });
  });
  await new Promise<void>((r) => server.listen(0, "127.0.0.1", () => r()));
  const port = (server.address() as AddressInfo).port;
  return { base: `http://127.0.0.1:${port}`, calls, close: () => new Promise<void>((r) => server.close(() => r())) };
}

async function attempt(base: string, problems: string[], turtle = "<urn:a> <urn:b> <urn:c> ."): Promise<WriteOutcome | null> {
  try {
    return await new FusekiStore(base, "cafe-runtime").write({ graph: "urn:ontara:stack:graph:check", turtle, label: "gate check" });
  } catch (e: any) {
    problems.push(`write() rejected: ${String(e?.message ?? e)}`);
    return null;
  }
}

interface Case { name: string; run: () => Promise<string[]> } // returns problems

const scripted = (name: string, reply: Scripted, check: (o: WriteOutcome, calls: string[], problems: string[]) => void): Case => ({
  name,
  run: async () => {
    const problems: string[] = [];
    const s = await standIn(reply);
    try {
      const o = await attempt(s.base, problems);
      if (o) check(o, s.calls, problems);
      const extra = s.calls.filter((c) => c !== "POST /cafe-runtime/validated-update" && c !== "POST /cafe-runtime/query");
      if (extra.length) problems.push(`unexpected calls after the write (the gate must send no rollback): ${extra.join(", ")}`);
      if (s.calls.filter((c) => c === "POST /cafe-runtime/validated-update").length !== 1) problems.push(`expected exactly one write request (calls: ${s.calls.join(", ")})`);
    } finally { await s.close(); }
    return problems;
  },
});

const cases: Case[] = [
  scripted("parseable 422 rejection: rejected, node shape named, rolled back by the store",
    { status: 422, contentType: REPORT_TYPE, body: PARSEABLE, headers: { "X-Ontara-Transaction": "aborted", "X-Ontara-Validation": TARGETED } },
    (o, _c, p) => {
      if (o.outcome !== "rejected") return void p.push(`outcome ${o.outcome}, expected rejected`);
      if (!o.nodeShapes.includes(SHAPE)) p.push(`nodeShapes ${JSON.stringify(o.nodeShapes)}, expected ${SHAPE}`);
      if (!o.rolledBack || o.transaction !== "aborted") p.push(`rolledBack ${o.rolledBack}, transaction ${o.transaction}`);
      if (o.validation !== TARGETED) p.push(`validation ${o.validation}, expected the header verbatim`);
    }),
  scripted("unparseable 422 rejection: fault, says the report was unreadable",
    { status: 422, contentType: REPORT_TYPE, body: UNPARSEABLE, headers: { "X-Ontara-Transaction": "aborted", "X-Ontara-Validation": TARGETED } },
    (o, _c, p) => {
      // A body that is not N-Triples may parse as an empty report rather than
      // throw; either way it must not come back as a committed write.
      if (o.outcome === "committed") return void p.push("outcome committed for a 422");
      if (o.outcome === "fault") {
        if (!o.detail.includes("unreadable") || !o.detail.includes(UNPARSEABLE.slice(0, 20))) p.push(`detail does not say the report was unreadable with the body's start: ${o.detail.slice(0, 120)}`);
        if (!o.rolledBack) p.push("rolledBack false although the store said aborted");
      } else if (o.outcome === "rejected") {
        p.push("an unreadable report came back as a rejection with no shapes; expected a fault");
      }
    }),
  scripted("500 fault, transaction aborted: fault, rolled back by the store",
    { status: 500, contentType: "text/plain", body: "fault: org.apache.jena.tdb2.TDBException: NodeTableTRDF/Read", headers: { "X-Ontara-Transaction": "aborted", "X-Ontara-Validation": TARGETED } },
    (o, _c, p) => {
      if (o.outcome !== "fault") return void p.push(`outcome ${o.outcome}, expected fault`);
      if (o.httpStatus !== 500) p.push(`httpStatus ${o.httpStatus}`);
      if (!o.rolledBack || o.transaction !== "aborted") p.push(`rolledBack ${o.rolledBack}, transaction ${o.transaction}`);
    }),
  {
    name: "no store (connection refused): fault, transaction unknown, not reported as rolled back",
    run: async () => {
      const problems: string[] = [];
      const s = await standIn({ status: 200, contentType: "application/json", body: "{}", headers: {} });
      const base = s.base; await s.close(); // nothing listens on this port now
      const o = await attempt(base, problems);
      if (o) {
        if (o.outcome !== "fault") problems.push(`outcome ${o.outcome}, expected fault`);
        else {
          if (o.transaction !== "unknown") problems.push(`transaction ${o.transaction}, expected unknown`);
          if (o.rolledBack) problems.push("rolledBack true: the gate cannot know that");
          if (!o.detail.includes("no reply from the store")) problems.push(`detail: ${o.detail.slice(0, 120)}`);
        }
      }
      return problems;
    },
  },
  scripted("200 commit: committed, X-Ontara-Validation recorded verbatim",
    { status: 200, contentType: "application/json", body: '{"outcome": "committed"}', headers: { "X-Ontara-Transaction": "committed", "X-Ontara-Validation": TARGETED } },
    (o, _c, p) => {
      if (o.outcome !== "committed") return void p.push(`outcome ${o.outcome}, expected committed`);
      if (o.validation !== TARGETED) p.push(`validation ${o.validation}, expected ${TARGETED}`);
      if (o.transaction !== "committed") p.push(`transaction ${o.transaction}`);
    }),
  scripted("200 commit with no X-Ontara-Validation header: committed, validation null",
    { status: 200, contentType: "application/json", body: '{"outcome": "committed"}', headers: { "X-Ontara-Transaction": "committed" } },
    (o, _c, p) => {
      if (o.outcome !== "committed") return void p.push(`outcome ${o.outcome}, expected committed`);
      if (o.validation !== null) p.push(`validation ${o.validation}, expected null`);
    }),
  {
    name: "Turtle parse error: fault before any request is sent",
    run: async () => {
      const problems: string[] = [];
      const s = await standIn({ status: 200, contentType: "application/json", body: "{}", headers: {} });
      try {
        const o = await attempt(s.base, problems, "<urn:a> <urn:b> .");
        if (o && o.outcome !== "fault") problems.push(`outcome ${o.outcome}, expected fault`);
        if (s.calls.length) problems.push(`requests sent: ${s.calls.join(", ")}`);
      } finally { await s.close(); }
      return problems;
    },
  },
];

async function main() {
  let failed = 0;
  for (const c of cases) {
    const problems = await c.run();
    console.log(`${problems.length ? "FAIL" : "PASS"}  ${c.name}`);
    for (const p of problems) console.log(`      ${p}`);
    if (problems.length) failed++;
  }
  console.log(failed ? `GATE CHECK: FAIL (${failed} of ${cases.length})` : `GATE CHECK: PASS (${cases.length} of ${cases.length})`);
  process.exit(failed ? 1 : 0);
}

main().catch((e) => { console.error(e); process.exit(1); });
