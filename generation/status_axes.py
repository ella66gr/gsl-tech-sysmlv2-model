"""Status axis declarations: the structures and the checks (platform-general).

A canonical runtime type declares its state as status axes: ``part``
usages typed ``StatusAxis`` inside a ``part def`` (the General metamodel's
``BusinessMetamodelGeneral::CanonicalRuntime``). Each axis has a value
space, a default, the authorities that may write it, and its permitted
moves (``AxisTransition`` usages). A move may carry the event that
triggers it (``triggerEvent``) and preconditions (``AxisPrecondition``
usages) on an axis of the same instance or of one related instance.

What is read, for each ``part <name> : StatusAxis``:

- ``axisName``, ``axisDescription`` (optional), ``defaultValue``, ``axisAuthority``;
- ``valueSpace``'s ``enumValues`` (in declared order) and ``valueShape``;
- each ``AxisTransition`` usage: ``fromValue``, ``toValue``,
  ``transitionLabel``, ``triggerEvent`` (optional), ``requiredAuthority``
  (optional; when absent the axis's authority applies);
- each ``AxisPrecondition`` usage inside a transition: ``relatedVia``
  (optional), ``requiredAxis``, ``requiredValues``, ``rejectionReason``.

``generation.resolved`` reads the declarations from OpenSysML's resolved
model as unchecked ``TypeDecl`` objects (and below); ``check_types`` checks
them and builds the ``AxisType`` objects the four axis generators
(``state_machine``, ``ts_types``, ``constraint_evaluator``,
``temporal_workflow``) read. Until S0.5 Pass A4 a text reader here returned
the same declarations, checked by the same code, and a test compared the
two on every tenant model and fixture; both were removed when no generator
read the text any more. Values are the strings the model declares. A
value with no outgoing move is terminal.

Since S0.5 Pass B8 (H-0647) each value is also a named individual at
runtime, with one generated predicate per axis (``generation.axis_iris``).
So the checks also keep the IRIs those rules mint safe and distinct: every
value string is letters and digits, starting with a letter; no two axes of
one model share a predicate (``Axis.lower_ident``); no two axis-bearing types
share a lower-cased name (the declaration IRIs use it); and precondition
usage names are unique within a type (their IRI omits the axis and the move).
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field

from generation.common import ModelError, upper_first

# The authority whose writers are people through a surface: the next-action
# map offers only the moves it can make. A General metamodel value
# (BusinessMetamodelGeneral::CanonicalRuntime::AxisAuthority), not tenant content.
OPERATOR_AUTHORITY = "operatorSide"

# A value string becomes part of an IRI and of a Turtle prefixed name
# (generation.axis_iris: {Type}{Axis}-{value}), so it is letters and digits,
# starting with a letter (S0.5 Pass B8).
VALUE_PATTERN = re.compile(r"^[A-Za-z][A-Za-z0-9]*$")


# -- The checked structures the generators read -------------------------


@dataclass
class Precondition:
    name: str
    related_via: str | None
    required_axis: str
    required_values: list[str]
    rejection_reason: str
    related_type: str = ""  # filled by the checks: the type that holds required_axis


@dataclass
class Move:
    name: str
    source: str
    target: str
    label: str
    event: str | None
    authorities: list[str]  # effective: the move's own, else the axis's
    preconditions: list[Precondition] = field(default_factory=list)

    @property
    def event_name(self) -> str:
        """The event that triggers the move; the move's usage name when the model gives none."""
        return self.event or self.name


@dataclass
class Axis:
    type_name: str
    usage: str  # e.g. lifecycleAxis
    name: str  # axisName, e.g. lifecycle
    values: list[str]
    default: str
    authorities: list[str]
    shape: str | None
    moves: list[Move]
    description: str | None = None  # axisDescription

    @property
    def ident(self) -> str:
        """``Order`` + ``lifecycle`` -> ``OrderLifecycle``."""
        return self.type_name + upper_first(re.sub(r"\W", "", self.name))

    @property
    def lower_ident(self) -> str:
        return self.ident[:1].lower() + self.ident[1:]

    @property
    def terminal_values(self) -> list[str]:
        out = {m.source for m in self.moves}
        return [v for v in self.values if v not in out]


@dataclass
class AxisType:
    name: str
    qualified: str  # enclosing packages and the name, e.g. Shop::Ticket
    source: str  # ``path (Qualified::Name)``, for a generated-file header
    axes: list[Axis]
    refs: dict[str, tuple[str, str | None]]  # ref name -> (type, multiplicity)


# -- The unchecked declarations both readers return ---------------------
#
# A single-valued field the model does not set is None; a multi-valued one
# is the empty list (generation.resolved reads an unset feature as the empty
# sequence). Nothing here is checked; check_types does that.


@dataclass
class PreconditionDecl:
    name: str
    related_via: str | None
    required_axis: str | None
    required_values: list[str]
    rejection_reason: str | None


@dataclass
class MoveDecl:
    name: str
    source: str | None  # fromValue
    target: str | None  # toValue
    label: str | None
    event: str | None
    required_authority: list[str]  # the move's own; empty when it names none
    preconditions: list[PreconditionDecl]


@dataclass
class AxisDecl:
    usage: str
    name: str | None  # axisName
    values: list[str]
    default: str | None
    authority: list[str]  # axisAuthority
    shape: str | None
    moves: list[MoveDecl]
    description: str | None = None  # axisDescription


@dataclass
class TypeDecl:
    name: str
    qualified: str
    source: str
    axes: list[AxisDecl]
    refs: dict[str, tuple[str, str | None]]


# -- The checks (one set, for both readers) -----------------------------


def check_axis(type_name: str, d: AxisDecl) -> Axis:
    """One axis, checked, as the generators read it."""
    where = f"{type_name}::{d.usage}"
    name = d.name
    if not name:
        raise ModelError(f"axis {where} has no axisName")
    values = list(d.values)
    if not values:
        raise ModelError(f"axis {where} has no enumValues in its valueSpace")
    if len(set(values)) != len(values):
        raise ModelError(f"axis {where} declares a value twice")
    for v in values:
        if not VALUE_PATTERN.match(v):
            raise ModelError(
                f"axis {where}: value {v!r} cannot be used in an IRI "
                "(letters and digits only, starting with a letter)"
            )
    default = d.default
    if default is None:
        raise ModelError(f"axis {where} has no defaultValue")
    if default not in values:
        raise ModelError(f"axis {where}: defaultValue {default!r} is not one of its values")
    axis_auth = list(d.authority)
    moves: list[Move] = []
    for md in d.moves:
        mwhere = f"{where}::{md.name}"
        src, dst = md.source, md.target
        if src is None or dst is None:
            raise ModelError(f"move {mwhere} needs fromValue and toValue")
        for end in (src, dst):
            if end not in values:
                raise ModelError(f"move {mwhere} names {end!r}, which is not a value of axis {name!r}")
        auth = list(md.required_authority) or axis_auth
        if not auth:
            raise ModelError(f"move {mwhere} names no authority (requiredAuthority or the axis's axisAuthority)")
        stray = [a for a in auth if axis_auth and a not in axis_auth]
        if stray:
            raise ModelError(f"move {mwhere} requires {', '.join(stray)}, which axis {name!r} does not name")
        pres = []
        for pd in md.preconditions:
            if not pd.required_axis or not pd.required_values or not pd.rejection_reason:
                raise ModelError(
                    f"precondition {mwhere}::{pd.name} needs requiredAxis, requiredValues and rejectionReason"
                )
            pres.append(
                Precondition(pd.name, pd.related_via, pd.required_axis, list(pd.required_values), pd.rejection_reason)
            )
        moves.append(Move(md.name, src, dst, md.label or "", md.event, auth, pres))
    seen: set[tuple[str, str]] = set()
    for mv in moves:
        if (mv.source, mv.target) in seen:
            raise ModelError(f"axis {where} declares the move {mv.source} -> {mv.target} twice")
        seen.add((mv.source, mv.target))
    by_event: dict[tuple[str, str], str] = {}
    for mv in moves:
        key = (mv.source, mv.event_name)
        if key in by_event:
            raise ModelError(
                f"axis {where}: event {mv.event_name!r} from {mv.source!r} is ambiguous "
                f"({by_event[key]} and {mv.name})"
            )
        by_event[key] = mv.name
    return Axis(type_name, d.usage, name, values, default, axis_auth, d.shape, moves, d.description)


def check_types(decls: list[TypeDecl]) -> list[AxisType]:
    """Every declared type with at least one axis, checked, in the readers' order."""
    types: list[AxisType] = []
    for td in decls:
        if not td.axes:
            continue
        axes = [check_axis(td.name, a) for a in td.axes]
        names = [a.name for a in axes]
        if len(set(names)) != len(names):
            raise ModelError(f"type {td.name!r} declares an axisName twice")
        types.append(AxisType(td.name, td.qualified, td.source, axes, dict(td.refs)))
    seen = [t.name for t in types]
    if len(set(seen)) != len(seen):
        raise ModelError("two part defs with status axes share a name: " + ", ".join(sorted(seen)))
    _check_runtime_iris(types)
    _check_preconditions(types)
    return types


def _check_runtime_iris(types: list[AxisType]) -> None:
    """The IRIs ``generation.axis_iris`` mints from this model are distinct (S0.5 Pass B8)."""
    by_lower: dict[str, str] = {}
    for t in types:
        key = t.name.lower()
        if key in by_lower:
            raise ModelError(
                f"part defs {by_lower[key]!r} and {t.name!r} with status axes differ only in case: "
                "their axis declaration IRIs would collide"
            )
        by_lower[key] = t.name
    predicates: dict[str, str] = {}
    for t in types:
        for ax in t.axes:
            where = f"{t.name}::{ax.usage}"
            if ax.lower_ident in predicates:
                raise ModelError(
                    f"axes {predicates[ax.lower_ident]} and {where} would share the runtime predicate "
                    f"{ax.lower_ident!r}"
                )
            predicates[ax.lower_ident] = where
        pre_names: dict[str, str] = {}
        for ax in t.axes:
            for mv in ax.moves:
                for p in mv.preconditions:
                    where = f"{t.name}::{ax.usage}::{mv.name}::{p.name}"
                    if p.name in pre_names:
                        raise ModelError(
                            f"preconditions {pre_names[p.name]} and {where} share the usage name {p.name!r}: "
                            f"precondition names must be unique within {t.name!r}"
                        )
                    pre_names[p.name] = where


def _check_preconditions(types: list[AxisType]) -> None:
    by_name = {t.name: t for t in types}
    for t in types:
        for ax in t.axes:
            for mv in ax.moves:
                for p in mv.preconditions:
                    where = f"precondition {t.name}::{ax.usage}::{mv.name}::{p.name}"
                    if p.related_via is None:
                        target = t
                    else:
                        if p.related_via not in t.refs:
                            raise ModelError(f"{where}: relatedVia {p.related_via!r} is not a ref of {t.name!r}")
                        rtype, mult = t.refs[p.related_via]
                        if mult and mult.strip() not in ("1", "0..1", "1..1"):
                            raise ModelError(f"{where}: relatedVia {p.related_via!r} must be single-valued, is [{mult}]")
                        if rtype not in by_name:
                            raise ModelError(f"{where}: {p.related_via!r} refers to {rtype!r}, which declares no axes")
                        target = by_name[rtype]
                    axis = next((a for a in target.axes if a.name == p.required_axis), None)
                    if axis is None:
                        raise ModelError(f"{where}: {target.name!r} has no axis {p.required_axis!r}")
                    bad = [v for v in p.required_values if v not in axis.values]
                    if bad:
                        raise ModelError(f"{where}: {', '.join(bad)} not a value of {target.name}.{axis.name}")
                    p.related_type = target.name


def all_axes(types: list[AxisType]) -> list[Axis]:
    return [a for t in types for a in t.axes]
