// Reads a SHACL validation report returned by the store on a rejected write
// (the Fuseki module sends N-Triples, application/shacl-validation-report+n-triples).
import { parseNQuads, Quad, Term, termText } from "./nquads";

const SH = "http://www.w3.org/ns/shacl#";
const RDF_TYPE = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type";

export const REPORT_CONTENT_TYPE = "application/shacl-validation-report";

export interface ShaclResult {
  focusNode: string | null;
  path: string | null;
  value: string | null;
  sourceShape: string | null;
  sourceShapeIsBlank: boolean;
  component: string | null;
  severity: string | null;
  message: string | null;
}

export interface ShaclReport {
  conforms: boolean;
  results: ShaclResult[];
  shapes: string[];
}

// A SHACL rejection is recognised by the report media type, or failing that
// by a report body (sh:ValidationReport with sh:conforms false).
export function looksLikeShaclRejection(contentType: string | null, body: string): boolean {
  if (contentType && contentType.toLowerCase().includes(REPORT_CONTENT_TYPE)) return true;
  return body.includes(`<${SH}ValidationReport>`) && body.includes(`<${SH}conforms> "false"`);
}

export function parseReport(body: string): ShaclReport {
  const quads = parseNQuads(body);
  const key = (t: Term) => (t.kind === "bnode" ? `_:${t.value}` : t.kind === "iri" ? t.value : termText(t));
  const bySubject = new Map<string, Quad[]>();
  for (const q of quads) {
    const k = key(q.s);
    if (!bySubject.has(k)) bySubject.set(k, []);
    bySubject.get(k)!.push(q);
  }
  const one = (subj: string, pred: string): Term | null => {
    const q = bySubject.get(subj)?.find((x) => x.p.kind === "iri" && x.p.value === pred);
    return q ? q.o : null;
  };
  let conforms = true;
  const results: ShaclResult[] = [];
  for (const q of quads) {
    if (q.p.value === `${SH}conforms` && q.o.kind === "literal") conforms = q.o.value === "true";
    if (q.p.value === RDF_TYPE && q.o.kind === "iri" && q.o.value === `${SH}ValidationResult`) {
      const r = key(q.s);
      const src = one(r, `${SH}sourceShape`);
      const t = (x: Term | null) => (x ? termText(x) : null);
      results.push({
        focusNode: t(one(r, `${SH}focusNode`)),
        path: t(one(r, `${SH}resultPath`)),
        value: t(one(r, `${SH}value`)),
        sourceShape: t(src),
        sourceShapeIsBlank: src?.kind === "bnode",
        component: t(one(r, `${SH}sourceConstraintComponent`)),
        severity: t(one(r, `${SH}resultSeverity`)),
        message: one(r, `${SH}resultMessage`)?.value ?? null,
      });
    }
  }
  const shapes = [...new Set(results.map((r) => r.sourceShape).filter((s): s is string => !!s))];
  return { conforms, results, shapes };
}
