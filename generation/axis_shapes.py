#!/usr/bin/env python3
"""
Axis membership shapes generator (platform-general; S0.5 Pass B8, H-0647).

Writes ``axis-shapes.ttl``: per status axis of every type in the tenant
model, two SHACL Core shapes on the runtime form of the axis (Cyril, S0.5
Pass B step 2, §1.7):

- a membership shape: ``sh:targetClass`` the declaring type, one property
  shape on the axis's generated predicate with ``sh:minCount 1``,
  ``sh:maxCount 1`` and ``sh:in`` the axis's value IRIs, so an instance
  carries exactly one value and it is one of the declared set;
- a subject shape: ``sh:targetSubjectsOf`` the predicate, with ``sh:class``
  the declaring type, so only an instance of that type carries it.

Membership is ``sh:in``, not ``sh:class``: it depends on nothing in the
knowledge graph, and a writer cannot satisfy it by typing its own value.
Both shapes are about one resource with paths of length 1, so they follow
the shape-authoring rule (ADR-014 §4.3). Property shapes are named, so a
rejection names a findable shape. The IRIs come from
``generation.axis_iris``, the rules the OWL pipeline's Stage 3g also uses
for the predicates and values it writes into the tenant-types ontology.

The file is written from a text template, not an RDF serialiser, so the same
model always gives the same bytes. Types and axes are in the readers' order.

Usage (from the repository root):
    python3 -m generation.axis_shapes --model <tenant model folder> --out <folder> \\
        --tenant <slug> [--model-name <name>]
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

if __package__ in (None, ""):
    sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from generation import axis_iris, resolved
from generation.common import ModelError
from generation.output import base_parser, header, write
from generation.status_axes import Axis, AxisType

OUT_FILE = "axis-shapes.ttl"
SH = "http://www.w3.org/ns/shacl#"


def display_name(type_name: str, friendly: str | None) -> str:
    """The type's ``@UserFacing.friendlyName``, else its name split into words (``TicketTask`` -> ``Ticket Task``)."""
    if friendly:
        return friendly
    return re.sub(r"(?<=[a-z0-9])(?=[A-Z])", " ", type_name)


def friendly_names(rm: resolved.ResolvedModel, types: list[AxisType]) -> dict[str, str]:
    """Type name -> display name, from each part def's ``@UserFacing`` as the OWL pipeline binds it (by position)."""
    graph = rm.elements()
    out = {}
    for t in types:
        friendly = None
        for e in graph.definitions("PartDefinition", t.name):
            if e.get("qualifiedName") != t.qualified:
                continue
            values = dict(graph.annotations(e)).get("UserFacing") or {}
            friendly = values.get("friendlyName") or None
        out[t.name] = display_name(t.name, friendly)
    return out


def _lit(s: str) -> str:
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"@en'


def _article(name: str) -> str:
    return "An" if name[:1].upper() in "AEIOU" else "A"


def render_axis(tenant: str, t: AxisType, ax: Axis, name: str) -> str:
    node, prop, subject = axis_iris.shape_locals(ax)
    cls = f"ontara-{tenant}:{t.name}"
    pred = f"ontara-{tenant}:{axis_iris.predicate_local(ax)}"
    values = " ".join(f"ontara-{tenant}:{axis_iris.value_local(ax, v)}" for v in ax.values)
    shp = f"ontara-{tenant}-shp"
    art = _article(name)
    member_msg = f"{art} {name} has exactly one {ax.name} value, one of: " + ", ".join(ax.values) + "."
    subject_msg = f"Only {art.lower()} {name} carries the {ax.name} axis."
    return (
        f"# {name}, {ax.name} axis ({t.qualified}::{ax.usage})\n"
        f"{shp}:{node} a sh:NodeShape ;\n"
        f"    sh:targetClass {cls} ;\n"
        f"    sh:property {shp}:{prop} .\n"
        f"{shp}:{prop} a sh:PropertyShape ;\n"
        f"    sh:path {pred} ;\n"
        f"    sh:minCount 1 ;\n"
        f"    sh:maxCount 1 ;\n"
        f"    sh:in ( {values} ) ;\n"
        f"    sh:message {_lit(member_msg)} .\n"
        f"{shp}:{subject} a sh:NodeShape ;\n"
        f"    sh:targetSubjectsOf {pred} ;\n"
        f"    sh:class {cls} ;\n"
        f"    sh:message {_lit(subject_msg)} .\n"
    )


def render(tenant: str, types: list[AxisType], names: dict[str, str], head: str) -> str:
    prefixes = (
        f"@prefix sh: <{SH}> .\n"
        f"@prefix ontara-{tenant}: <{axis_iris.tenant_ontology_ns(tenant)}> .\n"
        f"@prefix ontara-{tenant}-shp: <{axis_iris.tenant_shapes_ns(tenant)}> .\n"
    )
    blocks = [render_axis(tenant, t, ax, names[t.name]) for t in types for ax in t.axes]
    return head + prefixes + "".join("\n" + b for b in blocks)


def generate(model: Path, out: Path, root: Path, tenant: str, model_name: str | None) -> Path:
    if not re.fullmatch(r"[a-z][a-z0-9-]*", tenant):
        raise ModelError(f"--tenant {tenant!r}: a lower-case slug (letters, digits and hyphens) is needed")
    rm = resolved.load(model, root)
    types = rm.axis_types()
    if not types:
        raise ModelError("no part def in the model folder declares a status axis (part x : StatusAxis)")
    names = friendly_names(rm, types)
    head = header(__file__, [t.source for t in types], model_name, comment="#")
    path = write(out, OUT_FILE, render(tenant, types, names, head))
    n = sum(len(t.axes) for t in types)
    print(f"wrote {OUT_FILE}: {len(types)} types, {n} axes, {2 * n} node shapes")
    return path


def main(argv: list[str] | None = None) -> int:
    p = base_parser("Generate the SHACL membership and subject shapes of every status axis's runtime form.")
    p.add_argument("--tenant", required=True, help="tenant slug, as in the tenant ontology namespace (e.g. the IRI segment)")
    a = p.parse_args(argv)
    try:
        generate(a.model, a.out, a.root, a.tenant, a.model_name)
    except ModelError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
