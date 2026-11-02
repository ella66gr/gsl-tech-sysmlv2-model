"""Status axis declarations: the structures, the checks, and the text reader (platform-general).

A canonical runtime type declares its state as status axes: ``part``
usages typed ``StatusAxis`` inside a ``part def`` (the General metamodel's
``BusinessMetamodelGeneral::CanonicalRuntime``). Each axis has a value
space, a default, the authorities that may write it, and its permitted
moves (``AxisTransition`` usages). A move may carry the event that
triggers it (``triggerEvent``) and preconditions (``AxisPrecondition``
usages) on an axis of the same instance or of one related instance.

What is read, for each ``part <name> : StatusAxis``:

- ``axisName``, ``defaultValue``, ``axisAuthority``;
- ``valueSpace``'s ``enumValues`` (in declared order) and ``valueShape``;
- each ``AxisTransition`` usage: ``fromValue``, ``toValue``,
  ``transitionLabel``, ``triggerEvent`` (optional), ``requiredAuthority``
  (optional; when absent the axis's authority applies);
- each ``AxisPrecondition`` usage inside a transition: ``relatedVia``
  (optional), ``requiredAxis``, ``requiredValues``, ``rejectionReason``.

There are two readers, and one set of checks (S0.5 Pass A2):

1. ``generation.resolved`` reads the declarations from OpenSysML's
   resolved model. The four axis generators (``state_machine``,
   ``ts_types``, ``constraint_evaluator``, ``temporal_workflow``) use it.
2. The text reader at the end of this module reads them from the source
   text. It stays only so that ``generation/tests/test_reader_comparison.py``
   can compare the two readers, and is removed in Pass A4.

Both readers return the same unchecked declarations (``TypeDecl`` and
below). ``check_types`` checks them and builds the ``AxisType`` objects the
generators read, so a fault in the model is reported in the same words
whichever reader found it. Values are the strings the model declares. A
value with no outgoing move is terminal.
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field

from generation.sysml_text import (
    ModelError,
    ModelFile,
    braced_body,
    find_all,
    mask_comments,
    remove_doc_blocks,
    top_level_members,
    upper_first,
)

# The authority whose writers are people through a surface: the next-action
# map offers only the moves it can make. A General metamodel value
# (BusinessMetamodelGeneral::CanonicalRuntime::AxisAuthority), not tenant content.
OPERATOR_AUTHORITY = "operatorSide"


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
# A field the model does not set is None (a list of authorities: empty).
# Nothing here is checked; check_types does that.


@dataclass
class PreconditionDecl:
    name: str
    related_via: str | None
    required_axis: str | None
    required_values: list[str] | None
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
    return Axis(type_name, d.usage, name, values, default, axis_auth, d.shape, moves)


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
    _check_preconditions(types)
    return types


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


# -- The text reader (kept for the reader comparison; removed in Pass A4) --
#
# Reads only what is written inside each part def: axes, moves and refs
# are not inherited through ``:>``, and an axis needs a body
# (``part <name> : StatusAxis { ... }``).


def _string(body: str, attr: str) -> str | None:
    m = re.search(rf"(?:\battribute\s+)?:>>\s*{attr}\s*=\s*\"([^\"]*)\"\s*;", body)
    return m.group(1) if m else None


def _strings(body: str, attr: str) -> list[str] | None:
    m = re.search(rf"(?:\battribute\s+)?:>>\s*{attr}\s*=\s*(\([^;]*\)|\"[^\"]*\")\s*;", body)
    if not m:
        return None
    return re.findall(r"\"([^\"]*)\"", m.group(1))


def _enum_refs(body: str, attr: str, enum: str) -> list[str] | None:
    m = re.search(rf"(?:\battribute\s+)?:>>\s*{attr}\s*=\s*([^;]*);", body)
    if not m:
        return None
    return re.findall(rf"\b{enum}::(\w+)", m.group(1))


def _usages(body: str, type_name: str) -> list[tuple[str, str]]:
    """Every ``part <name> : <type_name> { ... }`` in ``body``: (name, inner body)."""
    out = []
    pos = 0
    for m in re.finditer(rf"\bpart\s+(\w+)\s*:\s*{type_name}\s*\{{", body):
        if m.start() < pos:
            continue
        inner, close = braced_body(body, m.end() - 1)
        pos = close
        out.append((m.group(1), inner))
    return out


def _without_usages(body: str, type_name: str) -> str:
    """``body`` with each ``part x : <type_name> { ... }`` removed."""
    out, pos = [], 0
    for m in re.finditer(rf"\bpart\s+(\w+)\s*:\s*{type_name}\s*\{{", body):
        if m.start() < pos:
            continue
        _, close = braced_body(body, m.end() - 1)
        out.append(body[pos : m.start()])
        pos = close + 1
    out.append(body[pos:])
    return "".join(out)


def _value_space(body: str) -> tuple[list[str], str | None]:
    m = re.search(r"\bpart\s+(?::>>\s*)?valueSpace\b[^{;]*\{", body)
    if not m:
        return [], None
    inner, _ = braced_body(body, m.end() - 1)
    values = _strings(inner, "enumValues") or []
    shape = re.search(r":>>\s*valueShape\s*=\s*\w+::(\w+)\s*;", inner)
    return values, shape.group(1) if shape else None


def _text_axis(usage: str, body: str) -> AxisDecl:
    own = _without_usages(_without_usages(body, "AxisTransition"), r"ValueSpace")
    values, shape = _value_space(body)
    moves = []
    for tname, tbody in _usages(body, "AxisTransition"):
        town = _without_usages(tbody, "AxisPrecondition")
        pres = [
            PreconditionDecl(
                pname,
                _string(pbody, "relatedVia"),
                _string(pbody, "requiredAxis"),
                _strings(pbody, "requiredValues"),
                _string(pbody, "rejectionReason"),
            )
            for pname, pbody in _usages(tbody, "AxisPrecondition")
        ]
        moves.append(
            MoveDecl(
                tname,
                _string(town, "fromValue"),
                _string(town, "toValue"),
                _string(town, "transitionLabel"),
                _string(town, "triggerEvent"),
                _enum_refs(town, "requiredAuthority", "AxisAuthority") or [],
                pres,
            )
        )
    return AxisDecl(
        usage,
        _string(own, "axisName"),
        values,
        _string(own, "defaultValue"),
        _enum_refs(own, "axisAuthority", "AxisAuthority") or [],
        shape,
        moves,
    )


def _refs(body: str) -> dict[str, tuple[str, str | None]]:
    flat = top_level_members(remove_doc_blocks(body))
    out = {}
    for m in re.finditer(r"(?:^|;)\s*ref\s+(?:part\s+)?(\w+)\s*:\s*([\w:]+)\s*(?:\[([^\]]+)\])?\s*(?=;)", flat):
        out[m.group(1)] = (m.group(2).split("::")[-1], m.group(3))
    return out


def text_decls(files: list[ModelFile]) -> list[TypeDecl]:
    """Every part def that declares at least one status axis, in source order, unchecked."""
    decls: list[TypeDecl] = []
    for found in find_all(files, r"part\s+def"):
        body = mask_comments(found.body)
        usages = _usages(body, "StatusAxis")
        if not usages:
            continue
        axes = [_text_axis(u, b) for u, b in usages]
        decls.append(TypeDecl(found.name, found.qualified, found.source, axes, _refs(body)))
    return decls


def text_axis_types(files: list[ModelFile]) -> list[AxisType]:
    """The text reader's axis types, checked by the shared checks."""
    return check_types(text_decls(files))
