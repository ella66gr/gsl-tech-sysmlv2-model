// Minimal N-Triples / N-Quads line parser: enough to read GraphDB's SHACL
// validation report (application/shacl-validation-report+n-quads).

export type Term =
  | { kind: "iri"; value: string }
  | { kind: "bnode"; value: string }
  | { kind: "literal"; value: string; lang?: string; datatype?: string };

export interface Quad { s: Term; p: Term; o: Term; g?: Term }

function unescape(s: string): string {
  return s.replace(/\\(u[0-9a-fA-F]{4}|U[0-9a-fA-F]{8}|[tbnrf"'\\])/g, (_m, e: string) => {
    if (e[0] === "u" || e[0] === "U") return String.fromCodePoint(parseInt(e.slice(1), 16));
    return ({ t: "\t", b: "\b", n: "\n", r: "\r", f: "\f", '"': '"', "'": "'", "\\": "\\" } as Record<string, string>)[e];
  });
}

function readTerm(line: string, i: number): [Term, number] {
  while (line[i] === " " || line[i] === "\t") i++;
  const c = line[i];
  if (c === "<") {
    const end = line.indexOf(">", i);
    return [{ kind: "iri", value: unescape(line.slice(i + 1, end)) }, end + 1];
  }
  if (c === "_") {
    let j = i + 2;
    while (j < line.length && !/[\s]/.test(line[j])) j++;
    return [{ kind: "bnode", value: line.slice(i + 2, j) }, j];
  }
  if (c === '"') {
    let j = i + 1;
    while (j < line.length) {
      if (line[j] === "\\") { j += 2; continue; }
      if (line[j] === '"') break;
      j++;
    }
    const value = unescape(line.slice(i + 1, j));
    j++;
    if (line[j] === "@") {
      let k = j + 1;
      while (k < line.length && /[A-Za-z0-9-]/.test(line[k])) k++;
      return [{ kind: "literal", value, lang: line.slice(j + 1, k) }, k];
    }
    if (line[j] === "^" && line[j + 1] === "^") {
      const [dt, k] = readTerm(line, j + 2);
      return [{ kind: "literal", value, datatype: dt.value }, k];
    }
    return [{ kind: "literal", value }, j];
  }
  throw new Error(`cannot parse term at ${i}: ${line.slice(i, i + 40)}`);
}

export function parseNQuads(text: string): Quad[] {
  const out: Quad[] = [];
  for (const raw of text.split(/\r?\n/)) {
    const line = raw.trim();
    if (!line || line.startsWith("#")) continue;
    let [s, i] = readTerm(line, 0);
    let p: Term, o: Term; [p, i] = readTerm(line, i); [o, i] = readTerm(line, i);
    let g: Term | undefined;
    const rest = line.slice(i).trim();
    if (rest !== "." && rest.length > 0) { [g] = readTerm(line, i); }
    out.push({ s, p, o, g });
  }
  return out;
}

export function termText(t: Term): string {
  if (t.kind === "iri") return t.value;
  if (t.kind === "bnode") return `_:${t.value}`;
  return t.lang ? `"${t.value}"@${t.lang}` : t.value;
}
