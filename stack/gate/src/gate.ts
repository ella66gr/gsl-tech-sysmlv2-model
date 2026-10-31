// The constraint gate's write path, kept thin (S0.1, specification 2.5 item 4).
//
//   begin transaction -> add triples -> run updates (rules, labelling) -> commit
//
// GraphDB reports a SHACL rejection and a server fault both as HTTP 500, so
// the body's media type tells them apart. After any failure once the
// transaction is open, the gate rolls back explicitly (DELETE on the
// transaction), because a rejected commit can leave the repository lock held
// (S515 notes 2.7). The rollback comes first, before the report is read or
// anything else that could throw, and write() never rejects: every failure
// becomes an outcome (S519; the OP-134 spike saw a report that failed to parse
// skip the rollback and leave the lock held). The Access Decision Evaluator is
// consulted from S0.7, not here.
import { GraphDB, HttpResult } from "./graphdb";
import { config, graphs } from "./config";
import { looksLikeShaclRejection, parseReport, ShaclReport, ShaclResult } from "./report";

export interface WriteRequest {
  graph?: string;            // named graph for `turtle`; default: the manual graph
  turtle?: string;           // triples to add
  updates?: string[];        // SPARQL Updates run in order, same transaction
  validation?: "normal" | "bulk";
  label?: string;
}

export interface Timings { begin: number; add: number; updates: number; commit: number; rollback: number; total: number }

export type WriteOutcome =
  | { outcome: "committed"; timings: Timings }
  | {
      outcome: "rejected";
      stage: string;
      shapes: string[];
      nodeShapes: string[];
      results: (ShaclResult & { nodeShape: string | null })[];
      rolledBack: boolean;
      rollbackStatus: number | null;
      timings: Timings;
    }
  | {
      outcome: "fault";
      stage: string;
      httpStatus: number | null;
      detail: string;
      rolledBack: boolean;
      rollbackStatus: number | null;
      timings: Timings;
    };

const defaultDb = new GraphDB();
const now = () => performance.now();

// Names the node shape that owns a property shape, so a rejection names a
// shape a person can find in the shapes file. Only runs on a rejection.
async function nodeShapeOf(db: GraphDB, propertyShape: string | null): Promise<string | null> {
  if (!propertyShape || propertyShape.startsWith("_:")) return null;
  try {
    // The shapes graph is not visible to SPARQL in GraphDB; use getStatements.
    const lines = await db.statements({ pred: "http://www.w3.org/ns/shacl#property", obj: propertyShape, graph: graphs.shapes });
    const m = lines[0]?.match(/^<([^>]+)>/);
    return m ? m[1] : propertyShape; // a node shape with a direct constraint names itself
  } catch {
    return null;
  }
}

// `db` defaults to the runtime repository; the capability checks pass a
// scratch repository so they never change the runtime repository's shapes.
export async function write(req: WriteRequest, db: GraphDB = defaultDb): Promise<WriteOutcome> {
  const t: Timings = { begin: 0, add: 0, updates: 0, commit: 0, rollback: 0, total: 0 };
  const t0 = now();
  let location: string | null = null;
  let stage = "begin";

  const finish = () => { t.total = now() - t0; return t; };

  // Never throws. Runs at most once per write: the location is cleared first.
  const rollback = async (): Promise<number | null> => {
    if (!location) return null;
    const txn = location;
    location = null;
    const r0 = now();
    try {
      const r = await db.txnRollback(txn);
      return r.status;
    } catch {
      return null;
    } finally {
      t.rollback = now() - r0;
    }
  };

  // Never throws: rolls back first, then reads the reply.
  const failed = async (r: HttpResult): Promise<WriteOutcome> => {
    const rollbackStatus = await rollback();
    const rolledBack = rollbackStatus === 204 || rollbackStatus === 200;
    const fault = (detail: string): WriteOutcome => ({
      outcome: "fault", stage, httpStatus: r.status, detail, rolledBack, rollbackStatus, timings: finish(),
    });
    const body = String(r.body ?? "");
    if (!looksLikeShaclRejection(r.contentType, body)) return fault(body.slice(0, 2000));
    let report: ShaclReport;
    try {
      report = parseReport(body);
    } catch (e: any) {
      return fault(`SHACL rejection report unreadable (${String(e?.message ?? e)}); body starts: ${body.slice(0, 2000)}`);
    }
    const results = await Promise.all(
      report.results.map(async (x) => ({ ...x, nodeShape: await nodeShapeOf(db, x.sourceShape) })),
    );
    const nodeShapes = [...new Set(results.map((x) => x.nodeShape).filter((s): s is string => !!s))];
    return {
      outcome: "rejected", stage, shapes: report.shapes, nodeShapes, results,
      rolledBack, rollbackStatus, timings: finish(),
    };
  };

  try {
    let s = now();
    const b = await db.begin(req.validation === "bulk");
    location = b.location;
    t.begin = now() - s;

    stage = "add";
    if (req.turtle && req.turtle.trim()) {
      s = now();
      const r = await db.txnAdd(location, req.turtle, req.graph ?? graphs.manual);
      t.add = now() - s;
      if (r.status >= 300) return await failed(r);
    }

    stage = "update";
    s = now();
    for (const u of req.updates ?? []) {
      const r = await db.txnUpdate(location, u);
      if (r.status >= 300) { t.updates = now() - s; return await failed(r); }
    }
    t.updates = now() - s;

    stage = "commit";
    s = now();
    const c = await db.txnCommit(location);
    t.commit = now() - s;
    if (c.status >= 300) return await failed(c);
    location = null; // committed: nothing to roll back
    return { outcome: "committed", timings: finish() };
  } catch (e: any) {
    const httpResult: HttpResult | undefined = e?.result;
    if (httpResult) return await failed(httpResult);
    const rollbackStatus = await rollback();
    return {
      outcome: "fault", stage, httpStatus: null, detail: String(e?.message ?? e),
      rolledBack: rollbackStatus === 204 || rollbackStatus === 200, rollbackStatus, timings: finish(),
    };
  }
}

export const repositoryId = () => config.repository;
