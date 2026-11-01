"""OP-136 Step 2 (a): can the resolved model feed the OWL pipeline?

Spike code on ``spike/op-136-opensysml``; never merged. Writes nothing
outside ``--out``; never touches ``generated/``.

What it does, per pipeline domain (``gen_owl_pipeline.DOMAIN_SOURCES``):

1. The text route: ``sysml_parser.parse_sysml_file`` on exactly the files
   ``gen_owl_pipeline.stage1_parse`` reads (each model dir globbed
   ``*.sysml``, non-recursive, ``test-``/``spike-`` excluded).
2. The resolved route: the same documents, loaded through the OpenSysML
   Python client with ``model/`` and ``libraries/`` (the ``parse-check``
   scope), rebuilt into ``sysml_parser.SysmlElement`` objects carrying the
   fields the pipeline reads:

   - name, kind, owning package, top-level package, source file and line;
   - ``specialises``: the first ``:>`` target, resolved (symbol graph);
   - refs: owned reference usages with resolved type and multiplicity
     (symbol graph);
   - the six BMM annotations with typed values (API JSON form: the
     symbol API does not list metadata usages in 0.11.0).

   An annotation is bound to an element in one of three ways, in this
   order: (i) it names the element with ``about`` (``annotatedElement``);
   (ii) it is written inside the element's body (its owner is the element);
   (iii) neither: it is owned by a package with no annotated element - which
   in SysML v2 means it annotates *that package* - and is bound to the next
   owned member in declaration order (``sysx:memberIndex``). Route (iii) is
   the positional rule ``sysml_parser`` applies to text, applied to resolved
   structure; it is reported separately, with any annotation it cannot bind.

3. Both element lists go through the pipeline's own Stage 2 (classify) and
   Stage 3 (3a domain, 3b correspondence, 3c properties, 3e weights,
   3g tenant types). The resulting graphs are compared by RDF isomorphism.

Run from the repository root:

    python -I spikes/op-136-opensysml/cyril/owl_reads.py --out <dir>

Exit status 0 when every graph is isomorphic, 1 otherwise.
"""

from __future__ import annotations

import argparse
import json
import sys
import time
import warnings
from collections import Counter, defaultdict
from pathlib import Path

warnings.simplefilter("ignore")  # ExperimentalFeatureWarning on convert("api-json")

REPO = Path(__file__).resolve().parents[3]
for p in (REPO / "scripts", REPO):
    if str(p) not in sys.path:
        sys.path.insert(0, str(p))

import opensysml  # noqa: E402
from rdflib.compare import isomorphic, graph_diff, to_isomorphic  # noqa: E402

import gen_owl_pipeline as gop  # noqa: E402
from sysml_parser import SysmlElement, parse_sysml_file  # noqa: E402

KIND = {"partDef": "part_def", "requirementDef": "requirement_def"}
BMM_ANN = ("CatalogueTag", "BfoType", "UserFacing", "PurposiveDescription",
           "Comprehension", "WeightedRelationship")
SKIP_MEMBER_TYPES = {"Documentation", "Comment", "TextualRepresentation"}


def pipeline_files(domain: str) -> list[Path]:
    out = []
    for d in gop.DOMAIN_SOURCES[domain]["model_dirs"]:
        if not d.exists():
            continue
        for f in sorted(d.glob("*.sysml")):
            if any(f.name.startswith(p) for p in gop.EXCLUDE_PATTERNS):
                continue
            out.append(f)
    return out


def text_elements(domain: str) -> list[SysmlElement]:
    els = []
    for f in pipeline_files(domain):
        els.extend(parse_sysml_file(f, domain, repo_root=REPO))
    return els


class Resolved:
    def __init__(self, domain: str):
        self.domain = domain
        self.own = pipeline_files(domain)
        own_set = {p.resolve() for p in self.own}
        rest = []
        for d in ("model", "libraries"):
            rest += sorted((REPO / d).rglob("*.sysml"), key=lambda p: p.as_posix())
        rest = [p for p in rest if p.resolve() not in own_set]
        files = self.own + rest
        t0 = time.time()
        self.model = opensysml.parse_sources([str(p) for p in files])
        self.parse_s = time.time() - t0
        errs = [d for d in self.model.diagnostics if str(getattr(d, "severity", "")).lower().endswith("error")]
        if errs or not self.model.ok:
            raise SystemExit(f"{domain}: OpenSysML reports errors: {errs or self.model.diagnostics}")
        t0 = time.time()
        self.els = json.loads(str(self.model.convert("api-json")))
        self.convert_s = time.time() - t0
        self.by = {e["@id"]: e for e in self.els}
        self.by_qn = {e["qualifiedName"]: e for e in self.els if e.get("qualifiedName")}
        self.members = defaultdict(list)
        for e in self.els:
            if e.get("@type", "").endswith("Membership") or "sysx:memberIndex" not in e:
                continue
            o = e.get("owner", {}).get("@id")
            if o:
                self.members[o].append(e)
        for v in self.members.values():
            v.sort(key=lambda e: e["sysx:memberIndex"])
        # root symbol of each own document, in load order
        self.roots = list(self.model.roots)[: len(self.own)]
        self.binding = {}      # metadata usage id -> (element api id, route)
        self.unbound = []      # package-owned BMM metadata usages bound to nothing
        self._bind_all()

    # -- annotation values (API JSON) -------------------------------------

    def _feature_name(self, f: dict) -> str:
        rd = f.get("redefines") or []
        if not isinstance(rd, list):
            rd = [rd]
        for r in rd:
            t = self.by.get(r["@id"] if isinstance(r, dict) else r)
            if t and t.get("declaredName"):
                return t["declaredName"]
        return f["@id"].split("__")[-1]

    def _value(self, v: dict | None):
        if not v:
            return None
        ve = self.by.get(v["@id"], {})
        t = ve.get("@type")
        if t in ("LiteralString", "LiteralBoolean", "LiteralInteger", "LiteralRational"):
            return ve.get("value")
        if t == "FeatureReferenceExpression":
            ref = self.by.get(ve.get("referent", {}).get("@id"), {})
            return ref.get("declaredName") or ve.get("sysx:sourceText")
        return ve.get("sysx:sourceText")

    def metadata_name(self, mu: dict) -> str:
        t = (mu.get("type") or [{}])[0].get("@id", "")
        return t.split("__")[-1]

    def metadata_values(self, mu: dict) -> dict:
        out = {}
        for m in mu.get("ownedMember", []) or []:
            f = self.by.get(m["@id"])
            if f is None:
                continue
            out[self._feature_name(f)] = self._value(f.get("value"))
        return out

    # -- binding ----------------------------------------------------------

    def _bind_all(self):
        for e in self.els:
            if e.get("@type") != "MetadataUsage":
                continue
            ae = e.get("annotatedElement")
            if ae:
                self.binding[e["@id"]] = (ae[0]["@id"], "about")
                continue
            owner = self.by.get(e.get("owner", {}).get("@id"), {})
            if owner.get("@type") not in ("Package", "LibraryPackage"):
                self.binding[e["@id"]] = (owner.get("@id"), "owned-by-element")
        # positional: package-owned, no annotatedElement
        for owner_id, mem in self.members.items():
            owner = self.by.get(owner_id, {})
            if owner.get("@type") not in ("Package", "LibraryPackage"):
                continue
            buf = []
            for e in mem:
                t = e.get("@type")
                if t == "MetadataUsage" and not e.get("annotatedElement"):
                    buf.append(e)
                    continue
                if t in SKIP_MEMBER_TYPES:
                    continue
                for mu in buf:
                    self.binding[mu["@id"]] = (e["@id"], "positional")
                buf = []
            for mu in buf:
                if self.metadata_name(mu) in BMM_ANN:
                    self.unbound.append(mu["@id"])

    def annotations_of(self, api_id: str) -> list[tuple[str, dict, str]]:
        if not hasattr(self, "_by_target"):
            self._by_target = defaultdict(list)
            for mu_id, (target, route) in self.binding.items():
                self._by_target[target].append((mu_id, route))
        out = []
        for mu_id, route in self._by_target.get(api_id, []):
            if True:
                mu = self.by[mu_id]
                out.append((mu.get("sysx:memberIndex", 0), mu.get("sysx:sourceLine", 0),
                            self.metadata_name(mu), self.metadata_values(mu), route))
        out.sort(key=lambda x: (x[1], x[0]))
        return [(n, v, r) for _, _, n, v, r in out]

    # -- elements -----------------------------------------------------------

    def _walk(self, sym, pkgs: list[str], rel: str, out: list):
        for c in sym.children():
            if c.kind == "package":
                self._walk(c, pkgs + [c.name], rel, out)
            elif c.kind in KIND:
                out.append(self._element(c, pkgs, rel))

    def _element(self, s, pkgs: list[str], rel: str) -> SysmlElement:
        api = self.by_qn.get(s.id, {})
        sup = next((sp.target_id for sp in s.specializations if sp.kind == "specializes" and sp.target_id), "")
        el = SysmlElement(
            kind=KIND[s.kind], name=s.name,
            parent_package=pkgs[-1] if pkgs else "", top_level_package=pkgs[0] if pkgs else "",
            specialises=sup, source_file=rel, source_domain=self.domain,
            line_number=api.get("sysx:sourceLine", 0),
        )
        attrs = []
        for c in s.children():
            if c.kind != "referenceUsage" or not c.name:
                continue
            tq = c.type_facts.resolved_id if c.type_facts else ""
            a = {"name": c.name, "type": tq.split("::")[-1], "isRef": True}
            if tq and tq != a["type"]:
                a["qualifiedType"] = tq
            mult = (c.metadata or {}).get("multiplicity")
            if mult:
                a["multiplicity"] = mult
            attrs.append(a)
        el.attributes = attrs
        el.routes = Counter()
        for name, vals, route in self.annotations_of(api.get("@id", "")):
            el.routes[route] += 1
            if name == "CatalogueTag":
                el.catalogue_tag = dict(vals)
            elif name == "UserFacing":
                el.user_facing = dict(vals)
            elif name == "PurposiveDescription":
                el.purposive_description = dict(vals)
            elif name == "Comprehension":
                el.comprehension = {k: bool(v) for k, v in vals.items()}
            elif name == "WeightedRelationship":
                el.weighted_relationships.append(dict(vals))
            elif name == "BfoType":
                el.bfo_type = dict(vals)
            el.annotations.append({"name": name, "attrs": dict(vals)})
        return el

    def elements(self) -> list[SysmlElement]:
        out = []
        for path, root in zip(self.own, self.roots):
            rel = str(path.relative_to(REPO))
            for c in root.children():
                if c.kind == "package":
                    self._walk(c, [c.name], rel, out)
                elif c.kind in KIND:
                    out.append(self._element(c, [], rel))
        return out


# -- comparison ---------------------------------------------------------------

READ_FIELDS = ("parent_package", "top_level_package", "source_file", "line_number",
               "bfo_type", "user_facing", "purposive_description", "weighted_relationships",
               "catalogue_tag", "comprehension")


def ref_view(el: SysmlElement) -> list:
    return sorted((a["name"], a["type"], a.get("multiplicity") or "1")
                  for a in el.attributes if a.get("isRef"))


def spec_view(el: SysmlElement) -> str:
    return (el.specialises or "").split("::")[-1]


def compare_elements(text: list, res: list) -> tuple[list[str], dict]:
    diffs = []
    tk = {(e.kind, e.parent_package, e.name): e for e in text if e.kind in KIND.values()}
    rk = {(e.kind, e.parent_package, e.name): e for e in res}
    for k in sorted(set(tk) - set(rk)):
        diffs.append(f"only in text reader: {k}")
    for k in sorted(set(rk) - set(tk)):
        diffs.append(f"only in resolved reader: {k}")
    stats = Counter()
    for k in sorted(set(tk) & set(rk)):
        t, r = tk[k], rk[k]
        stats["elements"] += 1
        for f in READ_FIELDS:
            tv, rv = getattr(t, f), getattr(r, f)
            if tv != rv:
                diffs.append(f"{k[2]} ({k[1]}): {f}: text={json.dumps(tv, ensure_ascii=False)[:200]} resolved={json.dumps(rv, ensure_ascii=False)[:200]}")
        if spec_view(t) != spec_view(r):
            diffs.append(f"{k[2]} ({k[1]}): specialises: text={t.specialises!r} resolved={r.specialises!r}")
        if ref_view(t) != ref_view(r):
            diffs.append(f"{k[2]} ({k[1]}): refs: text={ref_view(t)} resolved={ref_view(r)}")
        for route, n in getattr(r, "routes", {}).items():
            stats[f"annotations bound {route}"] += n
        for a in t.annotations:
            if a["name"] in BMM_ANN:
                stats[f"@{a['name']}"] += 1
    return diffs, stats


def run_pipeline(elements, rules, cco):
    classified, ir = gop.stage2_classify(elements, rules)
    g_dom, n_cls, _ = gop.stage3_generate_domain(classified, cco)
    g_corr = gop.stage3_generate_correspondence(classified, cco)
    g_prop, n_prop, deferred, prop_records = gop.stage3c_generate_properties(classified)
    g_w, n_w, weight_records, _ = gop.stage3e_generate_weights(classified)
    g_t, n_t, _ = gop.stage3g_generate_tenant_types(classified, cco)
    # 3d and 3f, as gen_owl_pipeline.main() appends them to the correspondence graph.
    from rdflib import Literal
    from rdflib.namespace import RDF, XSD
    C, AX, BMM = gop.ONTARA_CORR, gop.ONTARA_AX, gop.ONTARA_BMM
    for rec in prop_records:
        u = C[f"map-prop-{rec['propertyName']}"]
        g_corr.add((u, RDF.type, C["PropertyMappingRecord"]))
        g_corr.add((u, C["sysmlElementName"], Literal(f"{rec['owningClass']}.{rec['refName']}")))
        g_corr.add((u, C["owlEntity"], AX[rec["propertyName"]]))
        g_corr.add((u, C["classification"], Literal("ObjectProperty")))
        g_corr.add((u, C["authorityZone"], Literal("shared-constrained")))
        g_corr.add((u, C["multiplicity"], Literal(rec["multiplicity"])))
        g_corr.add((u, C["isFunctional"], Literal(rec["isFunctional"], datatype=XSD.boolean)))
    for rec in weight_records:
        u = C[f"map-{rec['individualName']}"]
        g_corr.add((u, RDF.type, C["WeightMappingRecord"]))
        g_corr.add((u, C["sysmlElementName"], Literal(rec["source"])))
        g_corr.add((u, C["owlEntity"], BMM[rec["individualName"]]))
        g_corr.add((u, C["classification"], Literal("WeightedRelationship")))
        g_corr.add((u, C["authorityZone"], Literal("shared-constrained")))
        g_corr.add((u, C["sysmlSourceFile"], Literal(rec["sysmlSourceFile"])))
        g_corr.add((u, C["sysmlLineNumber"], Literal(rec["sysmlLineNumber"], datatype=XSD.integer)))
        g_corr.add((u, C["weightTarget"], Literal(rec["target"])))
        g_corr.add((u, C["weightStrength"], Literal(rec["strength"])))
    counts = {k: v for k, v in ir["summary"].items() if k != "StructuralOnly"}
    return {"3a-domain": g_dom, "3b-correspondence": g_corr, "3c-properties": g_prop,
            "3e-weights": g_w, "3g-tenant-types": g_t}, {
        "classes": n_cls, "properties": n_prop, "deferred": len(deferred),
        "weights": n_w, "tenantTypes": n_t, **counts}


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", type=Path, default=Path(__file__).resolve().parent / "results")
    args = ap.parse_args()
    out = args.out
    out.mkdir(parents=True, exist_ok=True)
    rules = gop.load_mapping_rules()
    cco = gop.load_cco_lookup()

    all_text, all_res, report, ok = [], [], [], True
    for domain in gop.DOMAIN_SOURCES:
        if not pipeline_files(domain):
            report.append(f"## {domain}: no model files (skipped, as the pipeline does)")
            continue
        text = text_elements(domain)
        r = Resolved(domain)
        res = r.elements()
        diffs, stats = compare_elements(text, res)
        all_text += text
        all_res += res
        report.append(f"## {domain}: {len(pipeline_files(domain))} files; parse {r.parse_s:.2f}s, api-json {r.convert_s:.2f}s")
        report.append("   " + ", ".join(f"{k} {v}" for k, v in sorted(stats.items())))
        if r.unbound:
            report.append(f"   unbound package-owned BMM annotations: {r.unbound}")
        report += [f"   DIFF {d}" for d in diffs] or ["   element fields: IDENTICAL"]
        (out / f"{domain}.elements.text.json").write_text(json.dumps(
            [e.to_dict() for e in text if e.kind in KIND.values()], indent=1, ensure_ascii=False) + "\n")
        (out / f"{domain}.elements.resolved.json").write_text(json.dumps(
            [e.to_dict() for e in res], indent=1, ensure_ascii=False) + "\n")

    gt, ct = run_pipeline(all_text, rules, cco)
    gr, cr = run_pipeline(all_res, rules, cco)
    report.append("## pipeline stages 2-3 on all domains")
    report.append(f"   counts text     {json.dumps(ct, sort_keys=True)}")
    report.append(f"   counts resolved {json.dumps(cr, sort_keys=True)}")
    for name in gt:
        same = isomorphic(gt[name], gr[name])
        ok &= same
        report.append(f"   {name}: {len(gt[name])} triples text, {len(gr[name])} resolved: {'ISOMORPHIC' if same else 'DIFFERENT'}")
        if not same:
            _, a, b = graph_diff(to_isomorphic(gt[name]), to_isomorphic(gr[name]))
            for s, p, o in sorted(a)[:20]:
                report.append(f"      - text only: {s.n3()} {p.n3()} {o.n3()[:120]}")
            for s, p, o in sorted(b)[:20]:
                report.append(f"      + resolved only: {s.n3()} {p.n3()} {o.n3()[:120]}")
        gr[name].serialize(str(out / f"{name}.resolved.ttl"), format="turtle")
    # The committed outputs on main, for reference: the text route must reproduce them.
    committed = {"3a-domain": "ontara-bmm.ttl", "3c-properties": "ontara-bmm-properties.ttl",
                 "3e-weights": "ontara-bmm-weights.ttl", "3g-tenant-types": "ontara-tenant-types.ttl",
                 "3b-correspondence": "ontara-correspondence.ttl"}
    from rdflib import Graph
    for name, fn in committed.items():
        p = REPO / "generated" / "ontology" / fn
        if p.exists():
            g = Graph().parse(str(p))
            report.append(f"   committed {fn}: text route {'ISOMORPHIC' if isomorphic(g, gt[name]) else 'DIFFERENT'}, resolved route {'ISOMORPHIC' if isomorphic(g, gr[name]) else 'DIFFERENT'}")
        else:
            report.append(f"   committed {fn}: not present")
    report.append(f"VERDICT: {'ALL ISOMORPHIC' if ok else 'DIFFERENT'}")
    text = "\n".join(report) + "\n"
    (out / "owl-reads.txt").write_text(text)
    print(text, end="")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
