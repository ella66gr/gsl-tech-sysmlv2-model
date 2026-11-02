#!/usr/bin/env python3
"""
General element list generator (platform-general).

Lists, from a tenant's model, each General metamodel element the tenant
instantiates, with the instance names (S518, S0.3, decision 4: at Stage 0
selection is implied by instantiation, so the selected elements are
generated from the model, never hand-listed).

A General element is a definition (``part def``, ``action def`` and so on)
inside one of the packages named by ``--general-package``, read from the
platform model folder. The tenant instantiates it by:

- a usage typed by it (``part x : Element``, ``ref x : Element``, ...),
  written anywhere in the tenant model, at any depth;
- a tenant definition that specialises it (``part def X :> Element``);
- a usage typed by such a tenant definition, listed with the definition it
  goes through.

Attribute features are not instantiations and are left out, as are
enumeration, attribute, calculation, constraint, port, interface and
metadata definitions. The model is read through OpenSysML's resolved model
(generation.resolved, S0.5 Pass A4), loaded with the platform model folder,
so every type name is resolved as the model resolves it, imports included:
a tenant definition's ``:>`` (its first specialisation) and a usage's type
are the definitions OpenSysML resolves them to. The usages read are the
named ones typed with ``:``; the kind listed is the keyword they are written
with (``part``, ``ref``, ``item``, ``action``, ``state``, ``occurrence``,
``requirement``, ``use case``, ``ref part``, ``ref item``). A requirement's
``subject`` is not an instantiation.

The output is a plain text file, sorted throughout, so the same model always
gives the same bytes:

    Pkg::Sub::Element
      def Tenant::Specialisation
      part Tenant::Pkg::usageName
      part Tenant::Pkg::otherUsage (via Tenant::Specialisation)

Usage (from the repository root):
    python3 -m generation.element_list --model <tenant model folder> --out <folder> \\
        --platform-model <platform model folder> --general-package <name> [--general-package ...] \\
        [--filename general-elements.txt] [--model-name <name>]
"""

from __future__ import annotations

import sys
from pathlib import Path

if __package__ in (None, ""):
    sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from generation import resolved
from generation.output import base_parser, header, write
from generation.common import ModelError, rel_path

# Definitions that are not instantiated as elements (API JSON element types).
NOT_ELEMENTS = {
    "MetadataDefinition",
    "EnumerationDefinition",
    "AttributeDefinition",
    "CalculationDefinition",
    "ConstraintDefinition",
    "PortDefinition",
    "InterfaceDefinition",
}

# Usage element types read, and the keyword each is written with.
USAGE_KINDS = {
    "PartUsage": "part",
    "ItemUsage": "item",
    "OccurrenceUsage": "occurrence",
    "ActionUsage": "action",
    "PerformActionUsage": "action",
    "StateUsage": "state",
    "ExhibitStateUsage": "state",
    "RequirementUsage": "requirement",
    "SatisfyRequirementUsage": "requirement",
    "ReferenceUsage": "ref",
    "UseCaseUsage": "use case",
}


def _definitions(graph: resolved.ElementGraph, elements) -> dict[str, str | None]:
    """Qualified name -> its first specialisation (qualified), for every element definition among ``elements``."""
    out: dict[str, str | None] = {}
    for e in elements:
        if not e["@type"].endswith("Definition") or e["@type"] in NOT_ELEMENTS or not e.get("declaredName"):
            continue
        sup = graph.get(e, "specializes")
        out[e["qualifiedName"]] = sup[0].get("qualifiedName") if sup else None
    return out


def general_root(q: str | None, tenant: dict[str, str | None], general: dict[str, str | None]) -> tuple[str | None, str | None]:
    """The General def that ``q`` is or specialises, and the tenant def it goes through."""
    seen = set()
    via = None
    while q and q not in seen:
        seen.add(q)
        if q in general:
            return q, via
        if q not in tenant:
            return None, None
        if via is None:
            via = q
        q = tenant[q]
    return None, None


def _usage_kind(graph: resolved.ElementGraph, e: dict) -> str | None:
    kind = USAGE_KINDS.get(e["@type"])
    if kind is None:
        return None
    if kind == "ref":
        membership = graph.by_id.get((e.get("owningMembership") or {}).get("@id"), {})
        if membership.get("@type") != "FeatureMembership":  # a subject, a parameter
            return None
    elif kind in ("part", "item") and e.get("isReference"):
        kind = f"ref {kind}"
    return kind


def collect(graph: resolved.ElementGraph, packages: list[str]) -> dict[str, list[str]]:
    general = {
        q: s for q, s in _definitions(graph, graph.data).items() if q.split("::", 1)[0] in packages
    }
    if not general:
        raise ModelError("no definitions found in the named General packages: " + ", ".join(packages))
    tenant_elements = [e for _, e in graph.tenant_elements()]
    tenant = _definitions(graph, tenant_elements)

    listing: dict[str, set[str]] = {}
    for q, sup in tenant.items():
        if sup:
            root, _ = general_root(sup, tenant, general)
            if root:
                listing.setdefault(root, set()).add(f"def {q}")
    for e in tenant_elements:
        if not e.get("declaredName") or not e.get("ownedTyping"):
            continue
        kind = _usage_kind(graph, e)
        if kind is None:
            continue
        types = graph.get(e, "type")
        if not types:
            continue
        root, via = general_root(types[0].get("qualifiedName"), tenant, general)
        if root is None:
            continue
        listing.setdefault(root, set()).add(f"{kind} {e['qualifiedName']}" + (f" (via {via})" if via else ""))
    return {q: sorted(v) for q, v in sorted(listing.items())}


def render(listing: dict[str, list[str]], head: str) -> str:
    lines = [head.rstrip("\n"), ""]
    for q, entries in listing.items():
        lines.append(q)
        lines.extend(f"  {e}" for e in entries)
    return "\n".join(lines) + "\n"


def generate(
    model: Path,
    out: Path,
    root: Path,
    platform_model: Path,
    packages: list[str],
    filename: str,
    model_name: str | None,
) -> Path:
    graph = resolved.load(model, root, also=(platform_model,)).elements()
    listing = collect(graph, packages)
    sources = [rel_path(model, root) + "/", "General packages: " + ", ".join(packages)]
    path = write(out, filename, render(listing, header(__file__, sources, model_name, comment="#")))
    count = sum(len(v) for v in listing.values())
    print(f"wrote {path} ({len(listing)} General elements, {count} instances)")
    return path


def main(argv: list[str] | None = None) -> int:
    p = base_parser("List the General metamodel elements a tenant model instantiates.")
    p.add_argument("--platform-model", required=True, type=Path, help="platform model folder")
    p.add_argument(
        "--general-package", required=True, action="append", dest="packages",
        help="a top-level General package (repeat for each)",
    )
    p.add_argument("--filename", default="general-elements.txt", help="output file name (default: general-elements.txt)")
    a = p.parse_args(argv)
    try:
        generate(a.model, a.out, a.root, a.platform_model, a.packages, a.filename, a.model_name)
    except ModelError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
