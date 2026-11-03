// The Write Stamping Stage (WSS): ADR-015 §4 item 8 (H-0648), S0.5 Pass B3
// item 5. Every runtime write passes through it before it is stored. It is a
// role of its own: it does not evaluate the request (that is the gate's
// evaluation, gate.ts, which applies the write rules) and it writes no record
// (the gate's decision records arrive with the Access Decision Evaluator at
// S0.7). At Stage 0 it runs in the gate's service.
//
// At this pass it sets one platform value, the graph (recorded time, mode and
// method are not in Pass B's scope), from fixed sources only; nothing the
// writer sends can set it:
//
//   1. the Declared History Branch (DHB): the one the request's binding
//      instance belongs to. At Stage 0 every binding instance belongs to the
//      Cafe's Reality Reference Branch (RRB), the only DHB, so the DHB is the
//      RRB, whose identifier the store reports (status rrb.dhbId; generated
//      when the store was created from empty). Pass C's Runtime Identity
//      Registrar and S0.6's bindings make this a lookup per binding instance;
//   2. the side, dbr or dsr, read from the content:
//        - an instance of a canonical runtime type takes the side of what its
//          type is. The DBR holds business-side continuant trajectories and
//          the DSR the system-side occurrent log, so a type grounded (through
//          its @BfoType) under BFO continuant goes to dbr, and under BFO
//          occurrent to dsr. The type's grounding is read from the knowledge
//          graph (kg/domain), never from the writer. Order and OrderLine are
//          information content entities, so continuants: dbr;
//        - a platform record goes in the graph of the content it records
//          (ADR-011 §4.3): the side of what its rec:recordOf names. Only the
//          stand-in record vocabulary links a record to its content at Stage 0;
//          the real record module's link is H-0087's, at Pass C;
//        - a blank node takes the side of the subject that names it;
//        - anything else has no readable side, and the write is refused (rule
//          "no-readable-side"): the WSS does not guess;
//   3. the graph: the DHB's graph on that side, through the templates (graphs.ts).
//
// It also binds the {{DBR}} and {{DSR}} tokens by which rules name their
// graphs, and turns a request's `remove` list (instances the writer removes,
// by IRI) into one DELETE/INSERT WHERE over the DHB's two graphs.
// eslint-disable-next-line @typescript-eslint/no-var-requires
const ox = require("oxigraph");
import { Store } from "./store";
import { Branch, branch, bindBranch, KG_GRAPHS, Side, TENANT } from "./graphs";
import { Refusal } from "./store/types";

const RDF_TYPE = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type";
const STANDIN_RECORD = "urn:ontara:standin:rec#PlatformRecord";
const STANDIN_RECORD_OF = "urn:ontara:standin:rec#recordOf";
const CANONICAL_RUNTIME_TYPE = "https://ontara.dev/ontology/bmm/CanonicalRuntimeType";
const BFO_CONTINUANT = "http://purl.obolibrary.org/obo/BFO_0000002";
const BFO_OCCURRENT = "http://purl.obolibrary.org/obo/BFO_0000003";
const PLACEHOLDER_GRAPH = "urn:ontara:wss:unplaced";

// A runtime write as the writer sends it. No graph: the WSS sets it.
export interface RuntimeWrite {
  turtle?: string;      // triples, placed by side
  updates?: string[];   // SPARQL Updates; their graphs only as {{DBR}} / {{DSR}}, bound here
  remove?: string[];    // instance IRIs whose statements in the DHB's graphs are removed
  label?: string;
}

export interface Stamped {
  branch: Branch;
  quads: any[];
  updates: string[];
  placement: Record<string, Side>;   // subject -> side, for the record of the write
}

let rrb: Branch | null = null;
// The request's DHB. Stage 0: the RRB, read once from the store's status.
export async function requestBranch(store: Store): Promise<Branch> {
  if (rrb) return rrb;
  const s = await store.status();
  if (!s.rrb?.dhbId) throw new Error(`the store reports no Reality Reference Branch for /${store.dataset} (module status rrb is ${JSON.stringify(s.rrb)})`);
  rrb = branch(TENANT, s.rrb.dhbId);
  return rrb;
}

const classSide = new Map<string, Side | null>();
async function sideOfClass(store: Store, cls: string): Promise<Side | null> {
  if (classSide.has(cls)) return classSide.get(cls)!;
  const rows = await store.select(
    `PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
     SELECT DISTINCT ?kind WHERE { GRAPH <${KG_GRAPHS.domain}> {
       <${cls}> rdfs:subClassOf* <${CANONICAL_RUNTIME_TYPE}> .
       VALUES ?kind { <${BFO_CONTINUANT}> <${BFO_OCCURRENT}> }
       <${cls}> rdfs:subClassOf* ?kind } }`);
  const kinds = rows.map((r: any) => r.kind.value);
  const side: Side | null = kinds.length !== 1 ? null : kinds[0] === BFO_CONTINUANT ? "dbr" : "dsr";
  classSide.set(cls, side);
  return side;
}

const key = (t: any) => (t.termType === "BlankNode" ? `_:${t.value}` : t.value);

export async function stamp(w: RuntimeWrite, store: Store): Promise<{ stamped: Stamped } | { refused: Refusal[] }> {
  const b = await requestBranch(store);
  const quads: any[] = [];
  const placement: Record<string, Side> = {};
  const refused: Refusal[] = [];

  if (w.turtle && w.turtle.trim()) {
    const st = new ox.Store();
    st.load(w.turtle, { format: "text/turtle", to_graph_name: ox.namedNode(PLACEHOLDER_GRAPH) });
    const triples: any[] = [...st.match()];
    const bySubject = new Map<string, any[]>();
    for (const q of triples) { const k = key(q.subject); if (!bySubject.has(k)) bySubject.set(k, []); bySubject.get(k)!.push(q); }
    const typesIn = (s: string) => (bySubject.get(s) ?? []).filter((q) => q.predicate.value === RDF_TYPE && q.object.termType === "NamedNode").map((q) => q.object.value as string);
    const storedTypes = async (s: string) => (await store.select(`SELECT DISTINCT ?t WHERE { GRAPH ?g { <${s}> <${RDF_TYPE}> ?t } }`)).map((r: any) => r.t.value as string);

    const sideOf = async (s: string, depth = 0): Promise<Side | null> => {
      if (depth > 3) return null;
      if (s.startsWith("_:")) {
        const parent = triples.find((q) => key(q.object) === s && key(q.subject) !== s);
        return parent ? sideOf(key(parent.subject), depth + 1) : null;
      }
      let types = typesIn(s);
      if (!types.length) types = await storedTypes(s);
      if (!types.length) return null;
      const sides = new Set<Side | null>();
      for (const t of types) {
        if (t === STANDIN_RECORD) {
          const of = (bySubject.get(s) ?? []).filter((q) => q.predicate.value === STANDIN_RECORD_OF).map((q) => key(q.object));
          const ofStored = of.length ? of : (await store.select(`SELECT DISTINCT ?x WHERE { GRAPH ?g { <${s}> <${STANDIN_RECORD_OF}> ?x } }`)).map((r: any) => r.x.value as string);
          if (!ofStored.length) { sides.add(null); continue; }
          for (const x of ofStored) sides.add(await sideOf(x, depth + 1));
        } else sides.add(await sideOfClass(store, t));
      }
      return sides.size === 1 && !sides.has(null) ? [...sides][0]! : null;
    };

    for (const s of bySubject.keys()) {
      const side = await sideOf(s);
      if (!side) {
        refused.push({ rule: "no-readable-side", detail: `${s}: no side (dbr or dsr) can be read from its content: not an instance of a canonical runtime type grounded under BFO continuant or occurrent, nor a record of one` });
        continue;
      }
      placement[s] = side;
      const g = ox.namedNode(b[side]);
      for (const q of bySubject.get(s)!) quads.push(ox.quad(q.subject, q.predicate, q.object, g));
    }
  }
  if (refused.length) return { refused };

  const updates = (w.updates ?? []).map((u) => bindBranch(u, b));
  for (const u of updates) {
    const left = /\{\{([A-Z]+)\}\}/.exec(u);
    if (left) refused.push({ rule: "unbound-token", detail: `update leaves {{${left[1]}}} unbound: the gate binds only {{DBR}} and {{DSR}}` });
  }
  if (w.remove && w.remove.length) {
    const bad = w.remove.filter((x) => !/^[^\s<>"{}|\\^`]+:[^\s<>"{}|\\^`]+$/.test(x));
    if (bad.length) refused.push({ rule: "bad-remove", detail: `not IRIs: ${bad.slice(0, 3).join(", ")}` });
    else updates.push(`DELETE { GRAPH ?g { ?s ?p ?o } } WHERE { VALUES ?g { <${b.dbr}> <${b.dsr}> } VALUES ?s { ${w.remove.map((x) => `<${x}>`).join(" ")} } GRAPH ?g { ?s ?p ?o } }`);
  }
  if (refused.length) return { refused };
  return { stamped: { branch: b, quads, updates, placement } };
}
