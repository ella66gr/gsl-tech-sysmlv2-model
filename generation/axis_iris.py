"""The IRIs of a status axis's runtime form (platform-general; S0.5 Pass B8, H-0647).

One module holds every IRI rule for the axis vocabulary, so the OWL
pipeline (``scripts/gen_owl_pipeline.py`` Stage 3g, which writes the
predicates, the values and the axis declarations into the tenant-types
ontology) and ``generation.axis_shapes`` (which writes the membership
shapes) cannot disagree. The rules are Cyril's (S0.5 Pass B step 2, §1.3).

For tenant slug ``t``, a type ``T`` (its SysML name) with an axis whose
``axisName`` is ``a``, a value string ``v``, a move usage name ``m`` and a
precondition usage name ``p``; ``ident`` is ``Axis.ident`` (``T`` + upper-first
``a``) and ``lower_ident`` its lower-first form:

- tenant ontology namespace  ``https://ontara.dev/ontology/tenant/{t}/``
- axis predicate             ``{ns}{lower_ident}``
- axis value                 ``{ns}{ident}-{v}``
- StatusAxis declaration     ``https://ontara.dev/data/{t}/reasoning/{lower(T)}-{a}-axis``
- ValueSpace                 ``.../reasoning/{lower(T)}-{a}-values``
- AxisTransition             ``.../reasoning/{lower(T)}-{a}-{m}``
- AxisPrecondition           ``.../reasoning/{lower(T)}-{p}``
- shapes                     ``https://ontara.dev/ontology/tenant/{t}/shapes#{ident}AxisShape``,
                             ``...AxisShape-value``, ``...AxisSubjectShape``

The hyphen keeps every value IRI apart from every class (a SysML name has
no hyphen) and from every predicate (lower-first, no hyphen). The checks
that keep the minted IRIs safe and distinct are in
``generation.status_axes`` (value strings, predicate and declaration
collisions, precondition names). This module names no tenant.
"""

from __future__ import annotations

from generation.status_axes import Axis

ONTOLOGY_BASE = "https://ontara.dev/ontology/tenant/"
DATA_BASE = "https://ontara.dev/data/"

# The platform's axis vocabulary (ontology/axioms/ontara-bmm-axioms.ttl).
AXIS_NS = "https://ontara.dev/ontology/bmm/axis#"
BMM_NS = "https://ontara.dev/ontology/bmm/"


def tenant_ontology_ns(tenant: str) -> str:
    """The tenant's ontology (TBox) namespace, as Stage 3g mints its classes (Ella, S519)."""
    return f"{ONTOLOGY_BASE}{tenant}/"


def tenant_data_ns(tenant: str) -> str:
    """The tenant's reasoning-data namespace, where the axis declarations live."""
    return f"{DATA_BASE}{tenant}/reasoning/"


def tenant_shapes_ns(tenant: str) -> str:
    """The tenant's shapes namespace (follows ``https://ontara.dev/ontology/joins/shapes#``)."""
    return f"{ONTOLOGY_BASE}{tenant}/shapes#"


def class_iri(tenant: str, type_name: str) -> str:
    return f"{tenant_ontology_ns(tenant)}{type_name}"


def predicate_local(axis: Axis) -> str:
    return axis.lower_ident


def value_local(axis: Axis, value: str) -> str:
    return f"{axis.ident}-{value}"


def predicate_iri(tenant: str, axis: Axis) -> str:
    return f"{tenant_ontology_ns(tenant)}{predicate_local(axis)}"


def value_iri(tenant: str, axis: Axis, value: str) -> str:
    return f"{tenant_ontology_ns(tenant)}{value_local(axis, value)}"


def _decl(tenant: str, axis: Axis, suffix: str) -> str:
    return f"{tenant_data_ns(tenant)}{axis.type_name.lower()}-{axis.name}-{suffix}"


def axis_decl_iri(tenant: str, axis: Axis) -> str:
    return _decl(tenant, axis, "axis")


def value_space_iri(tenant: str, axis: Axis) -> str:
    return _decl(tenant, axis, "values")


def move_iri(tenant: str, axis: Axis, move_name: str) -> str:
    return _decl(tenant, axis, move_name)


def precondition_iri(tenant: str, type_name: str, precondition_name: str) -> str:
    """Omits the axis and the move: precondition usage names are unique within a type (checked)."""
    return f"{tenant_data_ns(tenant)}{type_name.lower()}-{precondition_name}"


def shape_locals(axis: Axis) -> tuple[str, str, str]:
    """(membership node shape, its property shape, subject shape), as local names."""
    return f"{axis.ident}AxisShape", f"{axis.ident}AxisShape-value", f"{axis.ident}AxisSubjectShape"
