"""The shared reader over OpenSysML's resolved model (S0.5 Pass A2, A3).

The generators (A2) and the OWL pipeline's Stage 1 (A3,
``scripts/gen_owl_pipeline.py``) read the model through this module, not
through the source text: OpenSysML parses and resolves the model, and the
reader walks the result. It runs only inside ``make gen``, the generation
tests and ``make qa-pipeline``, on the authoring rig's virtual environment
(``make venv``, ``GEN_PYTHON``); nothing a generator writes imports
``opensysml`` (``generation/tests/test_no_opensysml_import.py``).

How a model is loaded:

1. The tenant documents, then every ``.sysml`` file under the repository's
   ``model/`` (the General metamodel, where ``StatusAxis`` is declared) and
   ``libraries/``: the scope ``make parse-check`` loads each exercise with.
   For a generator (``load``), the tenant documents are every ``.sysml``
   file under the tenant model folder, in sorted path order; for the OWL
   pipeline (``load_files``), the files its Stage 1 names. The platform
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

The element graph (``ResolvedModel.elements``, for the OWL pipeline):
OpenSysML's API JSON export, which carries what the symbol API omits in
0.11.0: every element with its source line and column, its owner, its
order among its owner's members, and the metadata usages (the
``@Annotation { ... }`` blocks) with their values. ``ElementGraph`` indexes
it. Annotations are bound by position for now (S0.5 Pass A3): a metadata
usage written with ``about`` annotates what it names; any other annotates
the next member of its owning namespace, in declaration order, that is not
documentation or a comment, which is the rule the text parser applies. A
metadata usage with no member after it binds to nothing. Under SysML v2,
an annotation with no ``about`` annotates its owning namespace; the
convention that makes the model say what the position says is S0.6's.
"""

from __future__ import annotations

import hashlib
import json
import warnings
from collections import defaultdict
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
        self._elements: ElementGraph | None = None

    def elements(self) -> "ElementGraph":
        """The model's element graph (API JSON), converted once and kept."""
        if self._elements is None:
            with warnings.catch_warnings():
                warnings.simplefilter("ignore", opensysml.ExperimentalFeatureWarning)
                data = json.loads(str(self.model.convert("api-json")))
            self._elements = ElementGraph(data, [name for name, _ in self.documents[: self.tenant_count]])
        return self._elements

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


def documents(model_folder: Path, root: Path, also: tuple[Path, ...] = ()) -> tuple[list[tuple[str, str]], int]:
    """The (name, text) documents for a tenant folder, tenant first, and the tenant count.

    ``also`` names further folders to load with it, as platform content (not
    tenant documents): a generator's ``--platform-model``. A folder whose files
    are already among the repository's platform folders adds nothing.
    """
    folder = model_folder.resolve()
    if not folder.is_dir():
        raise ModelError(f"model folder not found: {folder}")
    tenant = _sysml_files(folder)
    if not tenant:
        raise ModelError(f"no .sysml files under {folder}")
    extra = []
    for d in also:
        d = d.resolve()
        if not d.is_dir():
            raise ModelError(f"platform model folder not found: {d}")
        extra += _sysml_files(d)
    return file_documents(tenant, root, extra)


def file_documents(
    tenant: list[Path], root: Path, extra: list[Path] | None = None
) -> tuple[list[tuple[str, str]], int]:
    """The (name, text) documents for the given tenant files, in that order, then ``extra``, then the platform's.

    ``extra`` files are loaded after the tenant's, named like them, and are
    not tenant documents; any that is a tenant file or a repository platform
    file is skipped (it is loaded already).
    """
    if not tenant:
        raise ModelError("no tenant documents to load")
    seen = {p.resolve() for p in tenant}
    platform = [p for d in PLATFORM_FOLDERS for p in _sysml_files(REPO / d) if p.resolve() not in seen]
    platform_set = {p.resolve() for p in platform}
    extra = [p for p in (extra or []) if p.resolve() not in seen and p.resolve() not in platform_set]
    platform_docs = [(rel_path(p, REPO), p.read_text(encoding="utf-8")) for p in platform]
    taken = {name for name, _ in platform_docs}
    tenant_docs = []
    for p in list(tenant) + extra:
        name = rel_path(p, root)
        if name in taken:  # a tenant file named like a platform file: keep them apart
            name = p.resolve().as_posix()
        tenant_docs.append((name, p.read_text(encoding="utf-8")))
    return tenant_docs + platform_docs, len(tenant)


def _load(docs: list[tuple[str, str]], n: int) -> ResolvedModel:
    key = (n,) + tuple((name, hashlib.sha256(text.encode("utf-8")).hexdigest()) for name, text in docs)
    if key not in _LOADED:
        _LOADED[key] = ResolvedModel(docs, n)
    return _LOADED[key]


def load(model_folder: Path, root: Path, also: tuple[Path, ...] = ()) -> ResolvedModel:
    """The resolved model for a tenant folder: loaded once per process, again only when a file changes.

    ``also``: further platform folders to load with it (``documents``).
    """
    return _load(*documents(model_folder, root, tuple(also)))


def load_files(files: list[Path], root: Path) -> ResolvedModel:
    """The resolved model for the given tenant files (in that order), with the platform folders."""
    return _load(*file_documents(list(files), root))


# -- The element graph (API JSON) ----------------------------------------

_SKIP_IN_POSITION = {"Documentation", "Comment", "TextualRepresentation"}
_PACKAGE_TYPES = {"Package", "LibraryPackage"}


class ElementGraph:
    """OpenSysML's API JSON elements, indexed, with annotations bound to elements.

    ``tenant_documents`` are the names of the tenant documents, in load
    order; ``tenant_elements`` yields only elements declared in them.
    """

    def __init__(self, data: list[dict], tenant_documents: list[str]):
        self.data = data
        self.tenant_documents = list(tenant_documents)
        self.by_id: dict[str, dict] = {e["@id"]: e for e in data}
        self._doc: dict[str, str | None] = {}
        members: dict[str, list[dict]] = defaultdict(list)
        for e in data:
            if "sysx:memberIndex" in e and not e["@type"].endswith("Membership") and e.get("owner"):
                members[e["owner"]["@id"]].append(e)
        for v in members.values():
            v.sort(key=lambda e: e["sysx:memberIndex"])
        self.members = dict(members)
        self.annotations_by_element: dict[str, list[dict]] = defaultdict(list)
        self.unbound: list[dict] = []
        self._bind()

    # -- structure ---------------------------------------------------------

    @staticmethod
    def _refs(e: dict, key: str) -> list[dict]:
        v = e.get(key)
        if not v:
            return []
        return v if isinstance(v, list) else [v]

    def get(self, e: dict, key: str) -> list[dict]:
        """The elements ``e`` refers to under ``key``, in order."""
        return [self.by_id[r["@id"]] for r in self._refs(e, key) if r.get("@id") in self.by_id]

    def owner(self, e: dict) -> dict | None:
        o = e.get("owner")
        return self.by_id.get(o["@id"]) if o else None

    def document(self, e: dict) -> str | None:
        """The name of the document that declares ``e``."""
        chain = []
        cur: dict | None = e
        found = None
        while cur is not None:
            if cur["@id"] in self._doc:
                found = self._doc[cur["@id"]]
                break
            chain.append(cur["@id"])
            if "sysx:sourceDocument" in cur:
                found = cur["sysx:sourceDocument"]
                break
            cur = self.owner(cur)
        for i in chain:
            self._doc[i] = found
        return found

    def packages(self, e: dict) -> list[str]:
        """The names of the packages that enclose ``e``, outermost first."""
        out = []
        cur = self.owner(e)
        while cur is not None:
            if cur["@type"] in _PACKAGE_TYPES and cur.get("declaredName"):
                out.append(cur["declaredName"])
            cur = self.owner(cur)
        return out[::-1]

    def qualified_name(self, e: dict | None) -> str:
        return (e or {}).get("qualifiedName") or ""

    def tenant_elements(self) -> list[tuple[int, dict]]:
        """(document index, element) for every element declared in a tenant document, in source order."""
        index = {name: i for i, name in enumerate(self.tenant_documents)}
        out = []
        for e in self.data:
            if "sysx:sourceLine" not in e:
                continue
            d = self.document(e)
            if d in index:
                out.append((index[d], e))
        out.sort(key=lambda x: (x[0], x[1]["sysx:sourceLine"], x[1].get("sysx:sourceColumn", 0)))
        return out

    # -- annotations -------------------------------------------------------

    def _bind(self) -> None:
        for e in self.data:
            if e["@type"] == "MetadataUsage" and e.get("annotatedElement"):
                for target in self._refs(e, "annotatedElement"):
                    self.annotations_by_element[target["@id"]].append(e)
        for mem in self.members.values():
            pending: list[dict] = []
            for e in mem:
                if e["@type"] == "MetadataUsage" and not e.get("annotatedElement"):
                    pending.append(e)
                    continue
                if e["@type"] in _SKIP_IN_POSITION:
                    continue
                self.annotations_by_element[e["@id"]].extend(pending)
                pending = []
            self.unbound.extend(pending)

    def metadata_name(self, mu: dict) -> str:
        """The metadata definition's name, e.g. ``BfoType``."""
        defs = self.get(mu, "type")
        return (defs[0].get("declaredName") or "") if defs else ""

    def _feature_name(self, f: dict) -> str:
        for r in self.get(f, "redefines"):
            if r.get("declaredName"):
                return r["declaredName"]
        return f.get("declaredName") or f["@id"].split("__")[-1]

    def _value(self, ref: dict | None):
        if not ref:
            return None
        v = self.by_id.get(ref["@id"], {})
        t = v.get("@type")
        if t in ("LiteralString", "LiteralBoolean", "LiteralInteger", "LiteralRational"):
            return v.get("value")
        if t == "FeatureReferenceExpression":
            target = self.by_id.get((v.get("referent") or {}).get("@id"), {})
            return target.get("declaredName") or v.get("sysx:sourceText")
        return v.get("sysx:sourceText")

    def metadata_values(self, mu: dict) -> dict:
        """The values a metadata usage sets, by feature name, in written order.

        A string, boolean or number literal gives its value; an enumeration
        literal (``RelationshipStrength::strong``) gives the literal's name.
        """
        out = {}
        for f in self.get(mu, "ownedMember"):
            out[self._feature_name(f)] = self._value(f.get("value"))
        return out

    def annotations(self, e: dict) -> list[tuple[str, dict]]:
        """(metadata name, values) for each annotation bound to ``e``, in source order."""
        mus = sorted(
            self.annotations_by_element.get(e["@id"], []),
            key=lambda m: (m.get("sysx:sourceLine", 0), m.get("sysx:memberIndex", 0)),
        )
        return [(self.metadata_name(m), self.metadata_values(m)) for m in mus]

    # -- for the generators (S0.5 Pass A4) ---------------------------------

    def owned_annotations(self, e: dict) -> list[tuple[str, dict]]:
        """(metadata name, values) for each annotation of ``e`` by SysML v2 meaning, in source order.

        That is every metadata usage written inside ``e``'s body without
        ``about``, and every one written ``about`` ``e`` anywhere. This is
        ownership, not position: the generators' annotations (``@TemporalWorkflow``,
        ``@TemporalSignal`` and the like) are written inside what they describe.
        """
        mus = [m for m in self.members.get(e["@id"], []) if m["@type"] == "MetadataUsage" and not m.get("annotatedElement")]
        mus += [
            m for m in self.annotations_by_element.get(e["@id"], [])
            if m.get("annotatedElement") and m not in mus
        ]
        mus.sort(key=lambda m: (m.get("sysx:sourceLine", 0), m.get("sysx:memberIndex", 0)))
        return [(self.metadata_name(m), self.metadata_values(m)) for m in mus]

    def metadata(self, e: dict, name: str) -> dict | None:
        """The values of ``e``'s first ``@name`` annotation (``owned_annotations``), or None."""
        return next((v for n, v in self.owned_annotations(e) if n == name), None)

    def member_list(self, e: dict) -> list[dict]:
        """``e``'s owned members, in declaration order."""
        return list(self.members.get(e["@id"], []))

    def source(self, e: dict) -> str:
        """``document (Qualified::Name)``, for a generated-file header."""
        return f"{self.document(e)} ({e.get('qualifiedName') or ''})"

    def definitions(self, api_type: str, name: str | None = None) -> list[dict]:
        """Every named element of ``api_type`` declared in a tenant document, in source order."""
        return [
            e for _, e in self.tenant_elements()
            if e["@type"] == api_type and e.get("declaredName") and (name is None or e["declaredName"] == name)
        ]

    def find_one(self, api_type: str, name: str, what: str) -> dict:
        """Exactly one ``api_type`` named ``name`` in the tenant documents, or a ModelError."""
        found = self.definitions(api_type, name)
        if not found:
            raise ModelError(f"{what} {name!r} not found in the model folder")
        if len(found) > 1:
            where = ", ".join(self.document(x) or "?" for x in found)
            raise ModelError(f"{what} {name!r} is declared more than once: {where}")
        return found[0]


def axis_types(model_folder: Path, root: Path) -> list[AxisType]:
    """Every tenant part def with at least one status axis, own or inherited, checked."""
    return load(model_folder, root).axis_types()
