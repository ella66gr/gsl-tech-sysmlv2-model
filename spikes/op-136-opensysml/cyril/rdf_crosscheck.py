"""OP-136 Step 2 (f): OpenSysML's RDF export as a cross-check on the OWL pipeline.

Spike code; never merged. Writes only under ``--out``.

1. ``sysml -convert ttl`` (pinned v0.11.0) on the BMM General model and the
   projection metadata it uses, twice, to see whether the export is
   byte-stable.
2. SPARQL CONSTRUCT over the export rebuilds the canonical-runtime family's
   slice of the pipeline's OWL: the ``owl:Class`` declarations, parents,
   labels, comments and definitions (Stage 3a) and the weighted-relationship
   individuals (Stage 3e). It applies the mapping ``mapping-rules.yaml``
   documents, with the IRI lookup tables of ``gen_owl_pipeline.py`` written
   in as VALUES. The annotation binding is done in SPARQL: a package-owned
   metadata usage with no annotated element belongs to the next owned
   member that is not a metadata usage or documentation.
3. The rebuilt slice is compared by RDF isomorphism with the same slice of
   the committed ``generated/ontology/ontara-bmm.ttl`` and
   ``ontara-bmm-weights.ttl``. Neither Python reader is involved, so
   agreement is independent evidence.
4. ``--fault``: the same on a scratch copy with CustomerSegment-style
   damage applied to StatusAxis (its ``@UserFacing`` brace on the next line,
   valid SysML), set against the TEXT route's output on that copy, to show
   the cross-check catching a pipeline misreading.

    python3 spikes/op-136-opensysml/cyril/rdf_crosscheck.py <scratch dir> [--out DIR]
"""

from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
sys.path.insert(0, str(REPO / "scripts"))
import gen_owl_pipeline as gop  # noqa: E402
from rdflib import Graph, URIRef  # noqa: E402
from rdflib.compare import graph_diff, isomorphic, to_isomorphic  # noqa: E402

SYSML = os.environ.get("SYSML", "/opt/homebrew/bin/sysml")
INPUTS = ["model/business-metamodel-general.sysml", "model/projection-metadata.sysml"]
FAMILY_PACKAGE = "CanonicalRuntime"
BMM_PACKAGES = ["ServiceConcept", "ActivityModel", "ResourcePlanning", "FinancialPlanning",
                "GovernanceMapping", "StakeholderModel", "CanonicalRuntime"]

PREFIXES = """
PREFIX sysml: <https://www.omg.org/spec/SysML#>
PREFIX sysx:  <urn:opensysml:sysml:>
PREFIX md:    <urn:sysmlv2:element:ProjectionMetadata__>
PREFIX owl:   <http://www.w3.org/2002/07/owl#>
PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos:  <http://www.w3.org/2004/02/skos/core#>
PREFIX xsd:   <http://www.w3.org/2001/XMLSchema#>
PREFIX bmm:   <https://ontara.dev/ontology/bmm/>
"""

# ?m (a metadata usage of type md:<META>) belongs to ?d by the positional rule.
BOUND = """
    ?{m} a sysml:MetadataUsage ; sysml:type md:{meta} ; sysml:owner ?pkg ; sysx:memberIndex ?{m}i .
    FILTER NOT EXISTS {{ ?{m} sysml:annotatedElement ?{m}any }}
    FILTER (?{m}i < ?j)
    FILTER NOT EXISTS {{
        ?{m}x sysml:owner ?pkg ; sysx:memberIndex ?{m}k .
        FILTER (?{m}k > ?{m}i && ?{m}k < ?j)
        FILTER NOT EXISTS {{ ?{m}x a sysml:MetadataUsage }}
        FILTER NOT EXISTS {{ ?{m}x a sysml:Documentation }}
    }}
"""


def value(m: str, feature: str, var: str) -> str:
    return f"""
    ?{m} sysml:ownedMember ?{m}_{var} . ?{m}_{var} sysml:redefines ?{m}_{var}d .
    ?{m}_{var}d sysml:declaredName "{feature}" .
    ?{m}_{var} sysml:value ?{m}_{var}v .
    {{ ?{m}_{var}v sysml:value ?{var} }} UNION {{ ?{m}_{var}v sysml:referent ?{m}_{var}r . ?{m}_{var}r sysml:declaredName ?{var} }}
"""


def domain_class(d: str = "d", pkgs=BMM_PACKAGES) -> str:
    vals = " ".join(f'"{p}"' for p in pkgs)
    return f"""
    ?{d} a sysml:PartDefinition ; sysml:owner ?pkg ; sysml:declaredName ?name ; sysx:memberIndex ?j .
    ?pkg sysml:declaredName ?pkgName . VALUES ?pkgName {{ {vals} }}
""" + BOUND.format(m="bt", meta="BfoType")


def lookup_values(cco: dict) -> tuple[str, str]:
    mids = {**gop.IAO_IRI_LOOKUP, **cco}
    mid = " ".join(f'("{k}" <{v}>)' for k, v in sorted(mids.items()))
    bfo = " ".join(f'("{k}" <{v}>)' for k, v in sorted(gop.BFO_IRI_LOOKUP.items()))
    return mid, bfo


def q_classes(cco: dict) -> str:
    mid, bfo = lookup_values(cco)
    return PREFIXES + f"""
CONSTRUCT {{
    ?cls a owl:Class ; rdfs:subClassOf ?parent ; rdfs:label ?label ; rdfs:comment ?comment ; skos:definition ?definition .
}} WHERE {{
    {domain_class(pkgs=[FAMILY_PACKAGE])}
    BIND (IRI(CONCAT(STR(bmm:), ?name)) AS ?cls)
    {value("bt", "bfoClass", "bfoClass")}
    OPTIONAL {{ {value("bt", "midLevelClass", "midLevel")} }}
    OPTIONAL {{ VALUES (?bfoClass ?bfoIri) {{ {bfo} }} }}
    OPTIONAL {{ VALUES (?midLevel ?midIri) {{ {mid} }} }}
    BIND (IF(BOUND(?midLevel) && ?midLevel != "" && BOUND(?midIri), ?midIri, ?bfoIri) AS ?parent)
    OPTIONAL {{ {BOUND.format(m="uf", meta="UserFacing")}
        OPTIONAL {{ {value("uf", "friendlyName", "fn")} FILTER(?fn != "") }}
        OPTIONAL {{ {value("uf", "shortDescription", "sd")} FILTER(?sd != "") }} }}
    OPTIONAL {{ {BOUND.format(m="pd", meta="PurposiveDescription")}
        {value("pd", "description", "desc")} FILTER(?desc != "") }}
    BIND (STRLANG(?fn, "en") AS ?label)
    BIND (STRLANG(?sd, "en") AS ?comment)
    BIND (STRLANG(?desc, "en") AS ?definition)
}}
"""


def q_weights() -> str:
    return PREFIXES + f"""
CONSTRUCT {{
    ?w a owl:NamedIndividual, bmm:WeightedRelationship ;
       bmm:weightSource ?src ; bmm:weightTarget ?tgt ;
       bmm:weightStrength ?strength ; bmm:weightRationale ?rationale ; rdfs:label ?label .
}} WHERE {{
    {domain_class(pkgs=[FAMILY_PACKAGE])}
    {BOUND.format(m="wr", meta="WeightedRelationship")}
    {value("wr", "target", "target")}
    {value("wr", "strength", "s")}
    OPTIONAL {{ {value("wr", "rationale", "r")} FILTER(?r != "") }}
    FILTER EXISTS {{
        ?t a sysml:PartDefinition ; sysml:declaredName ?target ; sysml:owner ?tpkg ; sysx:memberIndex ?tj .
        ?tpkg sysml:declaredName ?tpkgName . VALUES ?tpkgName {{ {" ".join(f'"{p}"' for p in BMM_PACKAGES)} }}
        ?tb a sysml:MetadataUsage ; sysml:type md:BfoType ; sysml:owner ?tpkg ; sysx:memberIndex ?tbi .
        FILTER (?tbi < ?tj)
        FILTER NOT EXISTS {{ ?tx sysml:owner ?tpkg ; sysx:memberIndex ?tk . FILTER (?tk > ?tbi && ?tk < ?tj)
            FILTER NOT EXISTS {{ ?tx a sysml:MetadataUsage }} FILTER NOT EXISTS {{ ?tx a sysml:Documentation }} }}
    }}
    BIND (IRI(CONCAT(STR(bmm:), "weight-", ?name, "-to-", ?target)) AS ?w)
    BIND (IRI(CONCAT(STR(bmm:), ?name)) AS ?src)
    BIND (IRI(CONCAT(STR(bmm:), ?target)) AS ?tgt)
    BIND (STRDT(?s, xsd:string) AS ?strength)
    BIND (STRDT(?r, xsd:string) AS ?rationale)
    BIND (STRLANG(CONCAT(?name, " \\u2192 ", ?target, " (", ?s, ")"), "en") AS ?label)
}}
"""


def family_slice(classes_ttl: Path, weights_ttl: Path, names: set[str]) -> Graph:
    g = Graph()
    cg = Graph().parse(str(classes_ttl))
    for n in names:
        for t in cg.triples((gop.ONTARA_BMM[n], None, None)):
            g.add(t)
    wg = Graph().parse(str(weights_ttl))
    for w in set(wg.subjects(gop.ONTARA_BMM["weightSource"], None)):
        src = wg.value(w, gop.ONTARA_BMM["weightSource"])
        if str(src).rsplit("/", 1)[-1] in names:
            for t in wg.triples((w, None, None)):
                g.add(t)
    return g


def export(root: Path, out: Path) -> tuple[int, str]:
    r = subprocess.run([SYSML, "-no-record-cache", *INPUTS, "-convert", "ttl", "-o", str(out)],
                       cwd=root, capture_output=True, text=True)
    return r.returncode, (r.stderr or r.stdout).strip().splitlines()[0] if (r.stderr or r.stdout) else ""


def rebuild(export_ttl: Path, cco: dict) -> tuple[Graph, set[str], int]:
    g = Graph().parse(str(export_ttl))
    rebuilt = Graph()
    for t in g.query(q_classes(cco)):
        rebuilt.add(t)
    names = {str(s).rsplit("/", 1)[-1] for s in rebuilt.subjects(None, URIRef("http://www.w3.org/2002/07/owl#Class"))}
    for t in g.query(q_weights()):
        rebuilt.add(t)
    return rebuilt, names, len(g)


def compare(a: Graph, b: Graph, la: str, lb: str, lines: list[str]) -> bool:
    same = isomorphic(a, b)
    lines.append(f"   {la} ({len(a)} triples) vs {lb} ({len(b)} triples): {'ISOMORPHIC' if same else 'DIFFERENT'}")
    if not same:
        _, x, y = graph_diff(to_isomorphic(a), to_isomorphic(b))
        for s, p, o in sorted(x)[:12]:
            lines.append(f"      only in {la}: {s.n3()} {p.n3()} {o.n3()[:100]}")
        for s, p, o in sorted(y)[:12]:
            lines.append(f"      only in {lb}: {s.n3()} {p.n3()} {o.n3()[:100]}")
    return same


def main() -> int:
    scratch = Path(sys.argv[1]).resolve()
    out = Path(sys.argv[sys.argv.index("--out") + 1]).resolve() if "--out" in sys.argv else HERE / "results" / "rdf-export"
    out.mkdir(parents=True, exist_ok=True)
    scratch.mkdir(parents=True, exist_ok=True)
    cco = gop.load_cco_lookup()
    lines = []

    # 1. export, twice
    # The full export (9.5 MB) is regenerable, so it stays in scratch; its digest is recorded.
    e1, e2 = scratch / "bmm-general.sysml-convert.ttl", scratch / "second-export.ttl"
    rc1, note = export(REPO, e1)
    rc2, _ = export(REPO, e2)
    lines.append("## 1. sysml -convert ttl (pinned v0.11.0) on " + " ".join(INPUTS))
    lines.append(f"   exit {rc1}, {e1.stat().st_size} bytes; note printed: {note[:160]}")
    lines.append(f"   second run byte-identical: {e1.read_bytes() == e2.read_bytes()}")
    import hashlib
    lines.append(f"   sha256 {hashlib.sha256(e1.read_bytes()).hexdigest()} (kept in scratch: {e1})")

    # 2-3. rebuild the family slice and compare with the committed OWL
    rebuilt, names, n = rebuild(e1, cco)
    (out / "canonical-runtime-family.rebuilt-from-export.ttl").write_text(rebuilt.serialize(format="turtle"))
    committed = family_slice(REPO / "generated/ontology/ontara-bmm.ttl", REPO / "generated/ontology/ontara-bmm-weights.ttl", names)
    (out / "canonical-runtime-family.committed-slice.ttl").write_text(committed.serialize(format="turtle"))
    lines.append(f"## 2-3. canonical-runtime family rebuilt by SPARQL CONSTRUCT from the export ({n} triples)")
    lines.append(f"   classes rebuilt: {sorted(names)}")
    ok = compare(rebuilt, committed, "rebuilt from export", "committed OWL slice", lines)

    # 4. a layout-only fault: the export still agrees with the committed OWL; the text route does not
    if "--no-fault" not in sys.argv:
        root = scratch / "fault"
        if root.exists():
            shutil.rmtree(root)
        for rel in ["model", "libraries", "scripts", "ontology/config", "generated/ontology",
                    "exercises/coffeeshop-demonstrator/model", "exercises/paws-demonstrator/model",
                    "exercises/gendersense/model"]:
            shutil.copytree(REPO / rel, root / rel, ignore=shutil.ignore_patterns("__pycache__"))
        (root / "spikes/op-136-opensysml/cyril").mkdir(parents=True)
        shutil.copy2(HERE / "owl_reads.py", root / "spikes/op-136-opensysml/cyril/owl_reads.py")
        f = root / INPUTS[0]
        old = '            friendlyName = "Status Axis";'
        t = f.read_text()
        i = t.index(old)
        j = t.rindex("@UserFacing {", 0, i)
        f.write_text(t[:j] + "@UserFacing\n        {" + t[j + len("@UserFacing {"):])
        rc, _ = export(root, scratch / "fault-export.ttl")
        fr, fnames, _ = rebuild(scratch / "fault-export.ttl", cco)
        venv_py = os.environ.get("VENV_PYTHON")
        lines.append("## 4. fault: StatusAxis's @UserFacing with its opening brace on the next line (valid SysML; export exit %d)" % rc)
        compare(fr, committed, "rebuilt from faulted export", "committed OWL slice", lines)
        if venv_py:
            subprocess.run([venv_py, "-I", str(root / "spikes/op-136-opensysml/cyril/owl_reads.py"), "--out", str(scratch / "fault-owl")],
                           cwd=root, capture_output=True, text=True)
            text_route = family_slice(scratch / "fault-owl/3a-domain.text.ttl", scratch / "fault-owl/3e-weights.text.ttl", names)
            compare(fr, text_route, "rebuilt from faulted export", "text-route pipeline on the faulted model", lines)
        else:
            lines.append("   (set VENV_PYTHON to the OpenSysML venv's python to run the text route on the fault)")
        shutil.rmtree(root)
    lines.append(f"VERDICT: {'export rebuild ISOMORPHIC with the committed OWL slice' if ok else 'DIFFERENT'}")
    text = "\n".join(lines) + "\n"
    (out / "crosscheck.txt").write_text(text)
    print(text, end="")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
