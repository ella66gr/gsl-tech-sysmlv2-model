"""The shared reader over OpenSysML's resolved model (S0.5 Pass A2).

The generators read a tenant's model through this module, not through the
source text: OpenSysML parses and resolves the model, and the reader walks
the result. It runs only inside ``make gen`` and the generation tests, on
the authoring rig's virtual environment (``make venv``, ``GEN_PYTHON``);
nothing a generator writes imports ``opensysml``
(``generation/tests/test_no_opensysml_import.py``).

How a model is loaded:

1. Every ``.sysml`` file under the tenant model folder, in sorted path
   order, then every ``.sysml`` file under the repository's ``model/`` (the
   General metamodel, where ``StatusAxis`` is declared) and ``libraries/``:
   the scope ``make parse-check`` loads each exercise with. The platform
   folders always come from this repository, whatever ``--root`` is.
2. The files are read here and passed to OpenSysML as (name, text) pairs,
   so what is parsed is exactly what was read. A tenant file is named by
   its path relative to ``root`` (as in a generated-file header), a
   platform file by its path relative to the repository.
3. ``opensysml.parse_sources(..., strict=True)``: any error in the model
   raises, and is re-raised as ``generation.sysml_text.ModelError`` with
   OpenSysML's own message. A fault of the client or of its gRPC service
   (``ConnectionError``, ``StaleServiceError`` and the like) is not a
   model fault and is raised as it is.
4. One load per model per process: the result is kept, keyed by the name
   and SHA-256 of every file loaded, so a changed file is loaded again and
   an unchanged model is not.

How status axes are read (``ResolvedModel.axis_decls``):

1. The tenant's part defs, found by walking each tenant document's
   namespace tree in declaration order, so each is placed in the document
   that declares it.
2. A type's features are its own members plus those of every def it
   specialises (``:>``), nearest first, a redefinition (``:>>``) taking the
   place of what it redefines. An axis is a part usage whose type, its own
   or that of the feature it redefines, is or specialises ``StatusAxis``; a
   move one whose type is or specialises ``AxisTransition``, inside the axis
   (and the axis it redefines); a precondition likewise for
   ``AxisPrecondition``, inside the move. Refs are the type's reference
   usages, inherited ones included, that redefine nothing.
3. Values are evaluated, not parsed: ``Model.eval(<feature>,
   context_symbol_id=<owner>)``. An enumeration literal is read as its own
   name, a one-element sequence as a list where a list is wanted, and an
   unset feature (``Undetermined``) as None.

The declarations are checked by ``generation.status_axes.check_types``,
the same checks the text reader's declarations get.
"""

from __future__ import annotations

import hashlib
from pathlib import Path

import opensysml

from generation.status_axes import (
    AxisDecl,
    AxisType,
    MoveDecl,
    PreconditionDecl,
    TypeDecl,
    check_types,
)
from generation.sysml_text import ModelError, rel_path

REPO = Path(__file__).resolve().parent.parent
PLATFORM_FOLDERS = ("model", "libraries")

CR = "BusinessMetamodelGeneral::CanonicalRuntime"
STATUS_AXIS = f"{CR}::StatusAxis"
AXIS_TRANSITION = f"{CR}::AxisTransition"
AXIS_PRECONDITION = f"{CR}::AxisPrecondition"


def _sysml_files(folder: Path) -> list[Path]:
    return sorted(folder.rglob("*.sysml"), key=lambda p: p.as_posix())


class ResolvedModel:
    """One tenant model folder, loaded with the platform folders, and the walks over it."""

    def __init__(self, documents: list[tuple[str, str]], tenant_count: int):
        self.documents = documents
        self.tenant_count = tenant_count
        try:
            self.model = opensysml.parse_sources(documents, strict=True)
        except (opensysml.ModelError, opensysml.ModelFileNotFoundError) as e:
            raise ModelError(f"OpenSysML: {e}") from e
        if len(self.model.roots) != len(documents):
            raise ModelError(
                f"OpenSysML returned {len(self.model.roots)} document roots for {len(documents)} documents"
            )
        self._sym: dict[str, object] = {}
        self._decls: list[TypeDecl] | None = None

    # -- symbols ---------------------------------------------------------

    def sym(self, fqn: str):
        if fqn not in self._sym:
            self._sym[fqn] = self.model.get(fqn)
        return self._sym[fqn]

    @staticmethod
    def edges(s, kinds: tuple[str, ...]) -> list[str]:
        return [sp.target_id for sp in s.specializations if sp.kind in kinds and sp.target_id]

    def is_or_specialises(self, def_id: str, target: str, seen: set | None = None) -> bool:
        if def_id == target:
            return True
        seen = set() if seen is None else seen
        if def_id in seen:
            return False
        seen.add(def_id)
        s = self.sym(def_id)
        return s is not None and any(self.is_or_specialises(t, target, seen) for t in self.edges(s, ("specializes",)))

    def feature_types(self, s) -> list[str]:
        """The defs typing a usage: its own typing, else the typing of the feature it redefines."""
        own = self.edges(s, ("typing",))
        if not own and s.type_facts and s.type_facts.resolved_id:
            own = [s.type_facts.resolved_id]
        if own:
            return own
        for t in self.edges(s, ("redefines", "subsets")):
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
        for t in self.edges(s, follow):
            sup = self.sym(t)
            if sup is not None:
                for c in self.effective_children(sup, follow, seen):
                    if all(c.id != x.id for x in inherited):
                        inherited.append(c)
        own = list(s.children())
        redefiner = {}
        for c in own:
            for t in self.edges(c, ("redefines",)):
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

    def tenant_definitions(self, kind: str) -> list[tuple[str, object]]:
        """(document name, symbol) for every definition of ``kind`` in the tenant documents, in declaration order."""
        out: list[tuple[str, object]] = []

        def walk(doc: str, s) -> None:
            for c in s.children():
                if c.kind == kind:
                    out.append((doc, c))
                if c.kind == "package" or c.kind.endswith("Def"):
                    walk(doc, c)

        tops: dict[str, str] = {}
        for (doc, _), root in zip(self.documents[: self.tenant_count], self.model.roots):
            for c in root.children():
                if c.id in tops:
                    raise ModelError(
                        f"package {c.id!r} is declared at the top of two documents ({tops[c.id]}, {doc}); "
                        "the resolved reader cannot place its members"
                    )
                tops[c.id] = doc
            walk(doc, root)
        return out

    # -- values ----------------------------------------------------------

    def value(self, owner: str, feature: str):
        v = self.model.eval(feature, context_symbol_id=owner)
        if isinstance(v, opensysml.Undetermined):
            return None
        return v

    @staticmethod
    def _literal(v) -> str:
        if isinstance(v, opensysml.EnumLiteral):
            return v.literal_id.split("::")[-1]
        return str(v)

    @staticmethod
    def _as_list(v) -> list:
        return list(v) if isinstance(v, (list, tuple)) else [v]

    def string(self, owner: str, feature: str) -> str | None:
        v = self.value(owner, feature)
        return None if v is None else str(v)

    def strings(self, owner: str, feature: str) -> list[str] | None:
        v = self.value(owner, feature)
        return None if v is None else [str(x) for x in self._as_list(v)]

    def literals(self, owner: str, feature: str) -> list[str] | None:
        v = self.value(owner, feature)
        return None if v is None else [self._literal(x) for x in self._as_list(v)]

    # -- status axes -----------------------------------------------------

    def _axis_decl(self, ax) -> AxisDecl:
        a = ax.id
        shape = self.literals(a, "valueSpace.valueShape")
        moves = []
        for t in self.effective_children(ax, ("redefines",)):
            if t.kind != "partUsage" or not self.typed(t, AXIS_TRANSITION):
                continue
            pres = [
                PreconditionDecl(
                    p.name,
                    self.string(p.id, "relatedVia"),
                    self.string(p.id, "requiredAxis"),
                    self.strings(p.id, "requiredValues"),
                    self.string(p.id, "rejectionReason"),
                )
                for p in self.effective_children(t, ("redefines",))
                if p.kind == "partUsage" and self.typed(p, AXIS_PRECONDITION)
            ]
            moves.append(
                MoveDecl(
                    t.name,
                    self.string(t.id, "fromValue"),
                    self.string(t.id, "toValue"),
                    self.string(t.id, "transitionLabel"),
                    self.string(t.id, "triggerEvent"),
                    self.literals(t.id, "requiredAuthority") or [],
                    pres,
                )
            )
        return AxisDecl(
            ax.name,
            self.string(a, "axisName"),
            self.strings(a, "valueSpace.enumValues") or [],
            self.string(a, "defaultValue"),
            self.literals(a, "axisAuthority") or [],
            shape[0] if shape else None,
            moves,
        )

    def _refs(self, td) -> dict[str, tuple[str, str | None]]:
        out = {}
        for c in self.effective_children(td, ("specializes",)):
            if c.kind != "referenceUsage" or self.edges(c, ("redefines",)):
                continue
            tf = c.type_facts
            tname = (tf.resolved_id or tf.declared) if tf else c.metadata.get("type", "")
            out[c.name] = ((tname or "").split("::")[-1], c.metadata.get("multiplicity"))
        return out

    def axis_decls(self) -> list[TypeDecl]:
        """Every tenant part def with at least one status axis, own or inherited, unchecked."""
        if self._decls is None:
            decls = []
            for doc, td in self.tenant_definitions("partDef"):
                usages = [
                    c
                    for c in self.effective_children(td, ("specializes",))
                    if c.kind == "partUsage" and self.typed(c, STATUS_AXIS)
                ]
                if not usages:
                    continue
                axes = [self._axis_decl(u) for u in usages]
                decls.append(TypeDecl(td.name, td.id, f"{doc} ({td.id})", axes, self._refs(td)))
            self._decls = decls
        return self._decls

    def axis_types(self) -> list[AxisType]:
        """The axis types, checked by the shared checks (``status_axes.check_types``)."""
        return check_types(self.axis_decls())


# -- Loading, once per model per process ---------------------------------

_LOADED: dict[tuple, ResolvedModel] = {}


def documents(model_folder: Path, root: Path) -> tuple[list[tuple[str, str]], int]:
    """The (name, text) documents for a tenant folder, tenant first, and the tenant count."""
    folder = model_folder.resolve()
    if not folder.is_dir():
        raise ModelError(f"model folder not found: {folder}")
    tenant = _sysml_files(folder)
    if not tenant:
        raise ModelError(f"no .sysml files under {folder}")
    seen = {p.resolve() for p in tenant}
    platform = [p for d in PLATFORM_FOLDERS for p in _sysml_files(REPO / d) if p.resolve() not in seen]
    platform_docs = [(rel_path(p, REPO), p.read_text(encoding="utf-8")) for p in platform]
    taken = {name for name, _ in platform_docs}
    tenant_docs = []
    for p in tenant:
        name = rel_path(p, root)
        if name in taken:  # a tenant file named like a platform file: keep them apart
            name = p.resolve().as_posix()
        tenant_docs.append((name, p.read_text(encoding="utf-8")))
    return tenant_docs + platform_docs, len(tenant_docs)


def load(model_folder: Path, root: Path) -> ResolvedModel:
    """The resolved model for a tenant folder: loaded once per process, again only when a file changes."""
    docs, n = documents(model_folder, root)
    key = (n,) + tuple((name, hashlib.sha256(text.encode("utf-8")).hexdigest()) for name, text in docs)
    if key not in _LOADED:
        _LOADED[key] = ResolvedModel(docs, n)
    return _LOADED[key]


def axis_types(model_folder: Path, root: Path) -> list[AxisType]:
    """Every tenant part def with at least one status axis, own or inherited, checked."""
    return load(model_folder, root).axis_types()
