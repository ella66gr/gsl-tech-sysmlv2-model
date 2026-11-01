"""OP-136 spike: what OpenSysML's resolved model exposes for one type.

python -I spikes/op-136-opensysml/sample_type.py <model folder> <Qualified::Type> > out.json

Reports, for the type: its documentation (Query RPC), its specialisations and
typed references and attributes (symbol graph), and every metadata usage
(annotation) in the type's owning package, with what each annotates, its
metadata definition, its feature values and its source line (API JSON form).
"""
import json, sys, warnings
from pathlib import Path
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import opensysml_axes as oa

warnings.simplefilter("ignore")
r = oa.Reader(Path(sys.argv[1]))
fqn = sys.argv[2]
t = r.sym(fqn)
doc = r.model.query(scope=[fqn], select=["documentation"],
                    where={"@type": "PrimitiveConstraint", "operator": "=", "property": "@id", "value": [fqn]})
out = {
    "type": fqn,
    "kind": t.kind,
    "documentation": doc[0].properties.get("documentation") if doc else None,
    "specializations": [{"kind": s.kind, "target": s.target_id} for s in t.specializations],
    "features": [
        {"name": c.name, "kind": c.kind, "type": (c.type_facts.resolved_id if c.type_facts else None),
         "multiplicity": c.metadata.get("multiplicity")}
        for c in r.effective_children(t, ("specializes",))
    ],
    "unnamed_members": [
        {"id": e.id, "@type": e.type, "type": e.properties.get("type")}
        for e in r.model.query(scope=[fqn], select=["@type", "type", "owner"])
        if e.properties.get("owner") == fqn and "@" in e.id.split("::")[-1] and e.type != "Documentation"
    ],
}
pkg = fqn.rsplit("::", 1)[0]
elements = json.loads(str(r.model.convert("api-json")))
by_id = {e["@id"]: e for e in elements}
ann = []
for e in elements:
    if e.get("@type") != "MetadataUsage" or e.get("owner", {}).get("@id") != pkg.replace("::", "__"):
        continue
    values = {}
    for m in e.get("ownedMember", []):
        f = by_id.get(m["@id"], {})
        name = (f.get("declaredName") or m["@id"].split("__")[-1])
        v = f.get("value")
        ve = by_id.get(v["@id"], {}) if isinstance(v, dict) else {}
        values[name] = ve.get("value", ve.get("sysx:sourceText"))
    ann.append({
        "id": e["@id"], "metadataDefinition": [x["@id"] for x in e.get("type", [])],
        "annotatedElement": e.get("annotatedElement"), "owner": e["owner"]["@id"],
        "sourceLines": [e.get("sysx:sourceLine"), e.get("sysx:sourceEndLine")],
        "values": values,
    })
out["package_metadata_usages"] = ann
out["type_source_line"] = next((e.get("sysx:sourceLine") for e in elements if e.get("@id") == fqn.replace("::", "__")), None)
json.dump(out, sys.stdout, indent=2, ensure_ascii=False)
print()
