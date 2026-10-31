// The constraint gate's write path, kept thin (S0.1, specification 2.5 item 4).
//
//   begin transaction -> add triples -> run updates (rules, labelling) -> commit
//
// GraphDB reports a SHACL rejection and a server fault both as HTTP 500, so
// the body's media type tells them apart. After any failure once the
// transaction is open, the gate rolls back explicitly (DELETE on the
// transaction), because a rejected commit can leave the repository lock held
// (S515 notes 2.7). The Access Decision Evaluator is consulted from S0.7, not here.
// Moved from src/gate.ts (OP-134 spike, B1) with three mechanical changes:
// imports; the shared types now live in ./types; nodeShapeOf reads the
// adapter's shapes graph instead of the config constant. Used by the GraphDB
// and RDF4J Server adapters, which speak the same RDF4J transaction protocol.
import { GraphDB, HttpResult } from "./graphdb-client";
import { looksLikeShaclRejection, parseReport } from "../report";
import { WriteRequest, Timings, WriteOutcome } from "./types";

const now = () => performance.now();

// Names the node shape that owns a property shape, so a rejection names a
// shape a person can find in the shapes file. Only runs on a rejection.
async function nodeShapeOf(db: GraphDB, shapesGraph: string, propertyShape: string | null): Promise<string | null> {
  if (!propertyShape || propertyShape.startsWith("_:")) return null;
  try {
    // The shapes graph is not visible to SPARQL in GraphDB; use getStatements.
    const lines = await db.statements({ pred: "http://www.w3.org/ns/shacl#property", obj: propertyShape, graph: shapesGraph });
    const m = lines[0]?.match(/^<([^>]+)>/);
    return m ? m[1] : propertyShape; // a node shape with a direct constraint names itself
  } catch {
    return null;
  }
}

// `db` is the adapter's repository client (the runtime repository, or the
// capability checks' scratch repository).
export async function rdf4jTransactionWrite(req: WriteRequest, db: GraphDB, shapesGraph: string, defaultGraph: string): Promise<WriteOutcome> {
  const t: Timings = { begin: 0, add: 0, updates: 0, commit: 0, rollback: 0, total: 0 };
  const t0 = now();
  let location: string | null = null;
  let stage = "begin";

  const finish = () => { t.total = now() - t0; return t; };

  const rollback = async (): Promise<number | null> => {
    if (!location) return null;
    const r0 = now();
    try {
      const r = await db.txnRollback(location);
      return r.status;
    } catch {
      return null;
    } finally {
      t.rollback = now() - r0;
    }
  };

  const failed = async (r: HttpResult): Promise<WriteOutcome> => {
    if (looksLikeShaclRejection(r.contentType, r.body)) {
      const report = parseReport(r.body);
      const rollbackStatus = await rollback();
      const results = await Promise.all(
        report.results.map(async (x) => ({ ...x, nodeShape: await nodeShapeOf(db, shapesGraph, x.sourceShape) })),
      );
      const nodeShapes = [...new Set(results.map((x) => x.nodeShape).filter((s): s is string => !!s))];
      return {
        outcome: "rejected", stage, shapes: report.shapes, nodeShapes, results,
        rolledBack: rollbackStatus === 204 || rollbackStatus === 200, rollbackStatus, timings: finish(),
      };
    }
    const rollbackStatus = await rollback();
    return {
      outcome: "fault", stage, httpStatus: r.status, detail: r.body.slice(0, 2000),
      rolledBack: rollbackStatus === 204 || rollbackStatus === 200, rollbackStatus, timings: finish(),
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
      const r = await db.txnAdd(location, req.turtle, req.graph ?? defaultGraph);
      t.add = now() - s;
      if (r.status >= 300) return failed(r);
    }

    stage = "update";
    s = now();
    for (const u of req.updates ?? []) {
      const r = await db.txnUpdate(location, u);
      if (r.status >= 300) { t.updates = now() - s; return failed(r); }
    }
    t.updates = now() - s;

    stage = "commit";
    s = now();
    const c = await db.txnCommit(location);
    t.commit = now() - s;
    if (c.status >= 300) return failed(c);
    location = null; // committed: nothing to roll back
    return { outcome: "committed", timings: finish() };
  } catch (e: any) {
    const httpResult: HttpResult | undefined = e?.result;
    if (httpResult) return failed(httpResult);
    const rollbackStatus = await rollback();
    return {
      outcome: "fault", stage, httpStatus: null, detail: String(e?.message ?? e),
      rolledBack: rollbackStatus === 204 || rollbackStatus === 200, rollbackStatus, timings: finish(),
    };
  }
}

