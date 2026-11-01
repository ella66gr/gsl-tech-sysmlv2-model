"""OP-136 spike: status axis declarations read through OpenSysML (Python client).

Spike code on ``spike/op-136-opensysml``; never merged. It reads what
``generation/status_axes.py`` reads, but from OpenSysML's resolved model
instead of the source text, and returns the same objects
(``generation.status_axes.AxisType`` / ``Axis`` / ``Move`` /
``Precondition``), checked by the same rules, so a generator could take
either.

How it reads:

1. ``opensysml.parse_sources`` loads the tenant model folder together with
   ``model/`` (the General metamodel, where ``StatusAxis`` is declared) and
   ``libraries/``, the scope ``make parse-check`` uses for each exercise.
   A load with any error diagnostic is refused.
2. The tenant's part defs come from the standard Query RPC
   (``@type = PartDefinition``), scoped to the top-level packages of the
   tenant's own documents, in declaration order.
3. Structure is walked on the symbol graph: a type's effective features are
   its own children plus those of every def it specialises (``:>``),
   nearest first, a redefinition (``:>>``) masking what it redefines. An
   axis is a part usage whose type, own or through the feature it redefines,
   is or specialises ``StatusAxis``; a move is one whose type is or
   specialises ``AxisTransition``; a precondition likewise for
   ``AxisPrecondition``.
4. Values are evaluated, not parsed: ``Model.eval(<feature>,
   context_symbol_id=<owner>)``. Enumeration literals come back as
   ``EnumLiteral`` (the literal's own name is kept), a one-element sequence
   as a scalar (normalised to a list where a list is wanted), and an unset
   optional feature as ``Undetermined``.

Unlike ``status_axes.py``, axes, moves and refs are inherited through
``:>``, and a subtype may redefine an inherited axis to add moves.
"""

from __future__ import annotations

import sys
from dataclasses import dataclass
from pathlib import Path

import opensysml
from opensysml.enumeration import EnumLiteral

# The repository's generation package, imported by path: this module is run
# with ``python -I``, which leaves the working directory off sys.path.
REPO = Path(__file__).resolve().parents[2]
if str(REPO) not in sys.path:
    sys.path.insert(0, str(REPO))

from generation.status_axes import (  # noqa: E402
    Axis,
    AxisType,
    Move,
    Precondition,
    _check_preconditions,
)
from generation.sysml_text import ModelError, rel_path  # noqa: E402

CR = "BusinessMetamodelGeneral::CanonicalRuntime"
STATUS_AXIS = f"{CR}::StatusAxis"
AXIS_TRANSITION = f"{CR}::AxisTransition"
AXIS_PRECONDITION = f"{CR}::AxisPrecondition"

PLATFORM_FOLDERS = ("model", "libraries")


@dataclass(frozen=True)
class ResolvedFound:
    """Stands in for ``sysml_text.Found`` where the generators read it."""

    qualified: str
    rel: str  # the document the type is declared in, relative to the root

    @property
    def source(self) -> str:
        return f"{self.rel} ({self.qualified})"


class Reader:
    """One loaded model and the walks over it."""

    def __init__(self, model_folder: Path, root: Path = REPO, platform: tuple[str, ...] = PLATFORM_FOLDERS):
        self.root = root.resolve()
        folder = model_folder.resolve()
        tenant = sorted(folder.rglob("*.sysml"), key=lambda p: p.as_posix())
        if not tenant:
            raise ModelError(f"no .sysml files under {folder}")
        rest = []
        for d in platform:
            rest += sorted((self.root / d).rglob("*.sysml"), key=lambda p: p.as_posix())
        rest = [p for p in rest if p.resolve() not in {t.resolve() for t in tenant}]
        # Tenant documents first, so roots[:len(tenant)] are the tenant's.
        self.files = tenant + rest
        self.model = opensysml.parse_sources([str(p) for p in self.files])
        errors = [d for d in self.model.diagnostics if str(getattr(d, "severity", "")).lower().endswith("error")]
        if errors or not self.model.ok:
            raise ModelError("OpenSysML reports errors: " + "; ".join(str(d) for d in (errors or self.model.diagnostics)))
        self.package_file: dict[str, str] = {}
        for path, root_sym in zip(tenant, self.model.roots):
            for child in root_sym.children():
                self.package_file[child.id] = rel_path(path, self.root)
        self._sym: dict[str, object] = {}

    # -- symbols ---------------------------------------------------------

    def sym(self, fqn: str):
        if fqn not in self._sym:
            self._sym[fqn] = self.model.get(fqn)
        return self._sym[fqn]

    def _edges(self, s, kinds: tuple[str, ...]) -> list[str]:
        return [sp.target_id for sp in s.specializations if sp.kind in kinds and sp.target_id]

    def is_or_specialises(self, def_id: str, target: str, seen: set | None = None) -> bool:
        if def_id == target:
            return True
        seen = seen or set()
        if def_id in seen:
            return False
        seen.add(def_id)
        s = self.sym(def_id)
        return s is not None and any(
            self.is_or_specialises(t, target, seen) for t in self._edges(s, ("specializes",))
        )

    def feature_types(self, s) -> list[str]:
        """The defs typing a usage: its own typing, else the typing of the feature it redefines."""
        own = self._edges(s, ("typing",))
        if not own and s.type_facts and s.type_facts.resolved_id:
            own = [s.type_facts.resolved_id]
        if own:
            return own
        for t in self._edges(s, ("redefines", "subsets")):
            r = self.sym(t)
            if r is not None:
                own = self.feature_types(r)
                if own:
                    return own
        return []

    def typed(self, s, target: str) -> bool:
        return any(self.is_or_specialises(t, target) for t in self.feature_types(s))

    def effective_children(self, s, follow: tuple[str, ...], _seen: frozenset = frozenset()) -> list:
        """The features ``s`` has: inherited along ``follow`` edges, then its own.

        Inherited features come first, in the supertype's order; an own
        feature that redefines one takes its place; own features that
        redefine nothing follow, in declaration order. An inherited feature
        is returned as the symbol that declares it. A feature reached twice
        (a diamond) is listed once.
        """
        if s.id in _seen:
            return []
        seen = _seen | {s.id}
        inherited: list = []
        for t in self._edges(s, follow):
            sup = self.sym(t)
            if sup is not None:
                for c in self.effective_children(sup, follow, seen):
                    if all(c.id != x.id for x in inherited):
                        inherited.append(c)
        own = list(s.children())
        redefiner = {}
        for c in own:
            for t in self._edges(c, ("redefines",)):
                redefiner.setdefault(t, c)
        out: list = []
        for c in inherited:
            r = redefiner.get(c.id)
            if r is not None:
                if all(r.id != x.id for x in out):
                    out.append(r)
            elif not any(o.name and o.name == c.name for o in own):
                out.append(c)
        for c in own:
            if all(c.id != x.id for x in out):
                out.append(c)
        return out

    # -- values ----------------------------------------------------------

    def value(self, owner: str, feature: str):
        v = self.model.eval(feature, context_symbol_id=owner)
        if type(v).__name__ == "Undetermined":
            return None
        return v

    @staticmethod
    def _literal(v) -> str:
        if isinstance(v, EnumLiteral):
            return v.literal_id.split("::")[-1]
        return str(v)

    def string(self, owner: str, feature: str) -> str | None:
        v = self.value(owner, feature)
        return None if v is None else str(v)

    def strings(self, owner: str, feature: str) -> list[str] | None:
        v = self.value(owner, feature)
        if v is None:
            return None
        return [str(x) for x in (v if isinstance(v, (list, tuple)) else [v])]

    def literals(self, owner: str, feature: str) -> list[str] | None:
        v = self.value(owner, feature)
        if v is None:
            return None
        return [self._literal(x) for x in (v if isinstance(v, (list, tuple)) else [v])]

    # -- the axes --------------------------------------------------------

    def tenant_part_defs(self) -> list[str]:
        if not self.package_file:
            return []
        rows = self.model.query(
            scope=list(self.package_file),
            select=["qualifiedName"],
            where={"@type": "PrimitiveConstraint", "operator": "=", "property": "@type", "value": ["PartDefinition"]},
        )
        return [r.id for r in rows]

    def file_of(self, fqn: str) -> str:
        best = max((p for p in self.package_file if fqn == p or fqn.startswith(p + "::")), key=len, default=None)
        return self.package_file.get(best, "?")

    def read_axis(self, type_name: str, ax) -> Axis:
        a = ax.id
        where = f"{type_name}::{ax.name}"
        name = self.string(a, "axisName")
        if not name:
            raise ModelError(f"axis {where} has no axisName")
        values = self.strings(a, "valueSpace.enumValues") or []
        if not values:
            raise ModelError(f"axis {where} has no enumValues in its valueSpace")
        if len(set(values)) != len(values):
            raise ModelError(f"axis {where} declares a value twice")
        default = self.string(a, "defaultValue")
        if default is None:
            raise ModelError(f"axis {where} has no defaultValue")
        if default not in values:
            raise ModelError(f"axis {where}: defaultValue {default!r} is not one of its values")
        shape = self.literals(a, "valueSpace.valueShape")
        axis_auth = self.literals(a, "axisAuthority") or []
        moves = []
        for t in self.effective_children(ax, ("redefines",)):
            if t.kind != "partUsage" or not self.typed(t, AXIS_TRANSITION):
                continue
            m, mwhere = t.id, f"{where}::{t.name}"
            src, dst = self.string(m, "fromValue"), self.string(m, "toValue")
            if src is None or dst is None:
                raise ModelError(f"move {mwhere} needs fromValue and toValue")
            for end in (src, dst):
                if end not in values:
                    raise ModelError(f"move {mwhere} names {end!r}, which is not a value of axis {name!r}")
            auth = self.literals(m, "requiredAuthority") or axis_auth
            if not auth:
                raise ModelError(f"move {mwhere} names no authority (requiredAuthority or the axis's axisAuthority)")
            stray = [x for x in auth if axis_auth and x not in axis_auth]
            if stray:
                raise ModelError(f"move {mwhere} requires {', '.join(stray)}, which axis {name!r} does not name")
            pres = []
            for p in self.effective_children(t, ("redefines",)):
                if p.kind != "partUsage" or not self.typed(p, AXIS_PRECONDITION):
                    continue
                req_axis = self.string(p.id, "requiredAxis")
                req_vals = self.strings(p.id, "requiredValues")
                reason = self.string(p.id, "rejectionReason")
                if not req_axis or not req_vals or not reason:
                    raise ModelError(
                        f"precondition {mwhere}::{p.name} needs requiredAxis, requiredValues and rejectionReason"
                    )
                pres.append(Precondition(p.name, self.string(p.id, "relatedVia"), req_axis, req_vals, reason))
            moves.append(Move(t.name, src, dst, self.string(m, "transitionLabel") or "", self.string(m, "triggerEvent"), auth, pres))
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
                    f"axis {where}: event {mv.event_name!r} from {mv.source!r} is ambiguous ({by_event[key]} and {mv.name})"
                )
            by_event[key] = mv.name
        return Axis(type_name, ax.name, name, values, default, axis_auth, shape[0] if shape else None, moves)

    def refs(self, td) -> dict[str, tuple[str, str | None]]:
        out = {}
        for c in self.effective_children(td, ("specializes",)):
            if c.kind != "referenceUsage" or self._edges(c, ("redefines",)):
                continue
            tf = c.type_facts
            tname = (tf.resolved_id or tf.declared) if tf else c.metadata.get("type", "")
            out[c.name] = (tname.split("::")[-1], c.metadata.get("multiplicity"))
        return out

    def axis_types(self) -> list[AxisType]:
        types = []
        for fqn in self.tenant_part_defs():
            td = self.sym(fqn)
            usages = [
                c for c in self.effective_children(td, ("specializes",))
                if c.kind == "partUsage" and self.typed(c, STATUS_AXIS)
            ]
            if not usages:
                continue
            axes = [self.read_axis(td.name, u) for u in usages]
            names = [a.name for a in axes]
            if len(set(names)) != len(names):
                raise ModelError(f"type {td.name!r} declares an axisName twice")
            types.append(AxisType(ResolvedFound(fqn, self.file_of(fqn)), td.name, axes, self.refs(td)))
        seen = [t.name for t in types]
        if len(set(seen)) != len(seen):
            raise ModelError("two part defs with status axes share a name: " + ", ".join(sorted(seen)))
        _check_preconditions(types)
        return types


def axis_types(model_folder: Path, root: Path = REPO) -> list[AxisType]:
    """Every part def of the tenant folder with at least one status axis, own or inherited, checked."""
    return Reader(model_folder, root).axis_types()
