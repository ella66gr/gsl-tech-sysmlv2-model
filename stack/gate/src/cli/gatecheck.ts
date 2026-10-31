// Checks the gate's write path against a stand-in store (S519). Run by
// stack/bin/gate-check.sh. Needs no running stack: the stand-in is passed as
// write()'s `db` and records every call in order.
//
// The invariant: write() never rejects, and once a transaction is open every
// failure rolls it back before anything else (reading the report, looking up
// node shapes). The OP-134 spike saw a report that failed to parse skip the
// rollback and leave the repository lock held.
//
//   1. unparseable rejection at the add stage -> fault, exactly one rollback
//   2. unparseable rejection at the commit stage -> fault, exactly one rollback
//   3. parseable rejection -> rejected, rollback before any node-shape lookup
//
// Exit 0 when every case passes, 1 otherwise.
import { GraphDB, HttpResult } from "../graphdb";
import { write, WriteOutcome } from "../gate";
import { REPORT_CONTENT_TYPE } from "../report";

const SH = "http://www.w3.org/ns/shacl#";
const RDF_TYPE = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type";
const SHAPE = "urn:ontara:standin:shapes#RecordModeMethodShape";
const PROPERTY_SHAPE = `${SHAPE}-method`;
const TXN = "http://standin/repositories/cafe-runtime/transactions/check";

const reply = (status: number, contentType: string | null, body: string): HttpResult =>
  ({ status, contentType, body, headers: new Headers() });

const rejection = (body: string) => reply(500, `${REPORT_CONTENT_TYPE}+n-quads`, body);
const UNPARSEABLE = "this is not an N-Quads report: the store sent something else";
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

// A stand-in store. `fail` names the stage that answers with `failure`;
// everything else succeeds.
function standIn(fail: "add" | "commit", failure: HttpResult) {
  const calls: string[] = [];
  const ok = reply(204, null, "");
  const db = {
    async begin() { calls.push("begin"); return { location: TXN, result: reply(201, null, "") }; },
    async txnAdd() { calls.push("add"); return fail === "add" ? failure : ok; },
    async txnUpdate() { calls.push("update"); return ok; },
    async txnCommit() { calls.push("commit"); return fail === "commit" ? failure : ok; },
    async txnRollback() { calls.push("rollback"); return ok; },
    async statements() { calls.push("statements"); return [`<${SHAPE}> <${SH}property> <${PROPERTY_SHAPE}> .`]; },
  };
  return { db: db as unknown as GraphDB, calls };
}

interface Case { name: string; run: () => Promise<string[]> } // returns problems

async function attempt(db: GraphDB, problems: string[]): Promise<WriteOutcome | null> {
  try {
    return await write({ graph: "urn:ontara:stack:graph:check", turtle: "<urn:a> <urn:b> <urn:c> .", label: "gate check" }, db);
  } catch (e: any) {
    problems.push(`write() rejected: ${String(e?.message ?? e)}`);
    return null;
  }
}

const unparseable = (stage: "add" | "commit"): Case => ({
  name: `unparseable rejection at the ${stage} stage: fault, exactly one rollback`,
  run: async () => {
    const problems: string[] = [];
    const { db, calls } = standIn(stage, rejection(UNPARSEABLE));
    const o = await attempt(db, problems);
    const rollbacks = calls.filter((c) => c === "rollback").length;
    if (o) {
      if (o.outcome !== "fault") problems.push(`outcome ${o.outcome}, expected fault`);
      else {
        if (o.stage !== stage) problems.push(`stage ${o.stage}, expected ${stage}`);
        if (!o.detail.includes("unreadable") || !o.detail.includes(UNPARSEABLE.slice(0, 20))) problems.push(`detail does not say the report was unreadable with the body's start: ${o.detail.slice(0, 120)}`);
        if (!o.rolledBack) problems.push("rolledBack false");
      }
    }
    if (rollbacks !== 1) problems.push(`${rollbacks} rollback calls, expected 1 (calls: ${calls.join(" ")})`);
    return problems;
  },
});

const parseable: Case = {
  name: "parseable rejection: rejected, rollback before any node-shape lookup",
  run: async () => {
    const problems: string[] = [];
    const { db, calls } = standIn("add", rejection(PARSEABLE));
    const o = await attempt(db, problems);
    if (o) {
      if (o.outcome !== "rejected") problems.push(`outcome ${o.outcome}, expected rejected`);
      else {
        if (!o.nodeShapes.includes(SHAPE)) problems.push(`nodeShapes ${JSON.stringify(o.nodeShapes)}, expected ${SHAPE}`);
        if (!o.rolledBack) problems.push("rolledBack false");
      }
    }
    const rb = calls.indexOf("rollback"), lookup = calls.indexOf("statements");
    if (calls.filter((c) => c === "rollback").length !== 1) problems.push(`expected exactly one rollback (calls: ${calls.join(" ")})`);
    if (lookup < 0) problems.push(`no node-shape lookup (calls: ${calls.join(" ")})`);
    else if (rb < 0 || rb > lookup) problems.push(`node-shape lookup before rollback (calls: ${calls.join(" ")})`);
    return problems;
  },
};

async function main() {
  let failed = 0;
  for (const c of [unparseable("add"), unparseable("commit"), parseable]) {
    const problems = await c.run();
    console.log(`${problems.length ? "FAIL" : "PASS"}  ${c.name}`);
    for (const p of problems) console.log(`      ${p}`);
    if (problems.length) failed++;
  }
  console.log(failed ? `GATE CHECK: FAIL (${failed} of 3)` : "GATE CHECK: PASS (3 of 3)");
  process.exit(failed ? 1 : 0);
}

main().catch((e) => { console.error(e); process.exit(1); });
