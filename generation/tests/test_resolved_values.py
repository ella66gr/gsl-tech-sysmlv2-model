"""How the resolved reader reads a value, whatever OpenSysML version is installed (S527).

OpenSysML 0.11.0 reads an unset feature as ``opensysml.Undetermined``;
0.12.0, following KerML, reads an unset feature with an open multiplicity
as the empty sequence, ``[]``. ``generation.resolved`` reads both the same:
a single-value read gives None, a multi-value read the empty list.

No model is parsed here. Each test hands ``ResolvedModel`` a stub model
whose ``eval`` returns the value forms under test, so the tests pin the
reader's rule, not what the installed OpenSysML happens to return. The
``Undetermined`` and ``EnumLiteral`` objects are made without their
constructors, whose arguments may differ between versions.
"""

from __future__ import annotations

import unittest
from dataclasses import dataclass, field

import opensysml

from generation.common import ModelError
from generation.resolved import AXIS_PRECONDITION, AXIS_TRANSITION, STATUS_AXIS, ResolvedModel


def undetermined():
    """An ``Undetermined``, as 0.11.0 returns for an unset feature (made without its constructor)."""
    return object.__new__(opensysml.Undetermined)


def enum_literal(name: str):
    """An ``EnumLiteral`` naming ``name``; the reader reads only its ``literal_id``."""
    lit = object.__new__(opensysml.EnumLiteral)
    object.__setattr__(lit, "literal_id", f"Fixture::Enumeration::{name}")
    return lit


# The two forms an unset feature takes: 0.11.0's and 0.12.0's.
UNSET_FORMS = {"Undetermined (0.11.0)": undetermined, "[] (0.12.0)": list}


class StubModel:
    """Stands in for ``opensysml``'s model: ``eval`` from a table, the rest from stub symbols."""

    def __init__(self, values: dict, unset=undetermined, roots: list | None = None):
        self.table = values
        self.unset = unset
        self.roots = roots or []

    def eval(self, feature: str, context_symbol_id: str):
        key = (context_symbol_id, feature)
        return self.table[key]() if key in self.table else self.unset()

    def get(self, fqn: str):
        return None


def reader(model: StubModel, documents: list[tuple[str, str]] | None = None) -> ResolvedModel:
    """A ``ResolvedModel`` over a stub model, without parsing anything."""
    rm = ResolvedModel.__new__(ResolvedModel)
    rm.documents = documents or []
    rm.tenant_count = len(rm.documents)
    rm.model = model
    rm._sym = {}
    rm._decls = None
    rm._elements = None
    return rm


class ValueFormsTest(unittest.TestCase):
    """Each accessor, fed each value form OpenSysML can return."""

    OWNER, FEATURE = "Fixture::Thing::someAxis", "someFeature"

    def read(self, accessor: str, raw):
        rm = reader(StubModel({(self.OWNER, self.FEATURE): lambda: raw() if callable(raw) else raw}))
        return getattr(rm, accessor)(self.OWNER, self.FEATURE)

    def test_unset_reads_the_same_in_both_forms(self):
        """Undetermined (0.11.0) and [] (0.12.0): None for a single read, [] for a multi read."""
        expected = {"string": None, "literal": None, "strings": [], "literals": [], "values": []}
        for form, make in UNSET_FORMS.items():
            for accessor, want in expected.items():
                with self.subTest(form=form, accessor=accessor):
                    self.assertEqual(self.read(accessor, make), want)

    def test_none_reads_as_unset(self):
        for accessor, want in {"string": None, "literal": None, "strings": [], "literals": []}.items():
            with self.subTest(accessor=accessor):
                self.assertEqual(self.read(accessor, lambda: None), want)

    def test_single_value(self):
        """A plain value: itself for a single read, a list of one for a multi read."""
        self.assertEqual(self.read("string", lambda: "ready"), "ready")
        self.assertEqual(self.read("strings", lambda: "ready"), ["ready"])
        self.assertEqual(self.read("literal", lambda: enum_literal("systemSide")), "systemSide")
        self.assertEqual(self.read("literals", lambda: enum_literal("systemSide")), ["systemSide"])

    def test_sequence_of_one(self):
        """A one-item list or tuple is that item for a single read, never its text ("['ready']")."""
        for name, make in {"list": lambda: ["ready"], "tuple": lambda: ("ready",)}.items():
            with self.subTest(form=name):
                self.assertEqual(self.read("string", make), "ready")
                self.assertEqual(self.read("strings", make), ["ready"])
        self.assertEqual(self.read("literal", lambda: [enum_literal("systemSide")]), "systemSide")
        self.assertEqual(self.read("literals", lambda: [enum_literal("systemSide")]), ["systemSide"])

    def test_sequence_of_several(self):
        """A multi read gives every item, in order; a single read refuses, naming owner and feature."""
        self.assertEqual(self.read("strings", lambda: ["paid", "waived"]), ["paid", "waived"])
        self.assertEqual(
            self.read("literals", lambda: [enum_literal("systemSide"), enum_literal("operatorSide")]),
            ["systemSide", "operatorSide"],
        )
        for accessor in ("string", "literal"):
            with self.subTest(accessor=accessor):
                with self.assertRaises(ModelError) as cm:
                    self.read(accessor, lambda: ["paid", "waived"])
                self.assertEqual(
                    str(cm.exception), f"{self.OWNER}: {self.FEATURE} has 2 values, where the reader takes one"
                )


# -- Through the status-axis walk and its checks --------------------------


@dataclass
class Spec:
    kind: str
    target_id: str


@dataclass
class Sym:
    """A stub symbol: what the reader's walk reads of one."""

    id: str
    kind: str
    typed: str | None = None
    kids: list = field(default_factory=list)
    type_facts: object = None

    @property
    def name(self) -> str:
        return self.id.split("::")[-1]

    @property
    def specializations(self) -> list[Spec]:
        return [Spec("typing", self.typed)] if self.typed else []

    def children(self) -> list:
        return self.kids


T = "Fixture::Ticket"
AX = f"{T}::stageAxis"


def ticket_model(values: dict, unset, precondition: bool = True) -> ResolvedModel:
    """One part def, ``Ticket``, with one axis, ``stageAxis``; ``values`` are the evaluated features.

    Moves: ``placedToReady`` and ``placedToCancelled`` leave ``triggerEvent``
    unset, ``readyToCollected`` sets it; ``readyToCollected`` has one
    precondition, ``settled``, on the same instance (``relatedVia`` unset),
    unless ``precondition`` is False.
    """
    pre = Sym(f"{AX}::readyToCollected::settled", "partUsage", AXIS_PRECONDITION)
    moves = [
        Sym(f"{AX}::placedToReady", "partUsage", AXIS_TRANSITION),
        Sym(f"{AX}::placedToCancelled", "partUsage", AXIS_TRANSITION),
        Sym(f"{AX}::readyToCollected", "partUsage", AXIS_TRANSITION, kids=[pre] if precondition else []),
    ]
    axis = Sym(AX, "partUsage", STATUS_AXIS, kids=moves)
    root = Sym("Fixture", "package", kids=[Sym(T, "partDef", kids=[axis])])
    return reader(StubModel(values, unset=unset, roots=[root]), [("ticket.sysml", "")])


def ticket_values(overrides: dict | None = None) -> dict:
    values = {
        (AX, "axisName"): lambda: "stage",
        (AX, "valueSpace.enumValues"): lambda: ["placed", "ready", "collected", "cancelled"],
        (AX, "defaultValue"): lambda: "placed",
        (AX, "axisAuthority"): lambda: [enum_literal("systemSide")],
        (f"{AX}::readyToCollected", "triggerEvent"): lambda: "Collected",
        (f"{AX}::readyToCollected::settled", "requiredAxis"): lambda: "stage",
        (f"{AX}::readyToCollected::settled", "requiredValues"): lambda: ["ready"],
        (f"{AX}::readyToCollected::settled", "rejectionReason"): lambda: "The ticket is not ready.",
    }
    values.update(overrides or {})
    for m in ("placedToReady", "placedToCancelled", "readyToCollected"):
        src, dst = m.split("To")
        values.setdefault((f"{AX}::{m}", "fromValue"), lambda s=src: s)
        values.setdefault((f"{AX}::{m}", "toValue"), lambda d=dst: d[:1].lower() + d[1:])
        values.setdefault((f"{AX}::{m}", "transitionLabel"), lambda m=m: m)
    return values


class UnsetThroughTheChecksTest(unittest.TestCase):
    """An unset feature, in either form, read by ``axis_types`` and checked by ``check_types``."""

    def axis(self, unset, overrides: dict | None = None, precondition: bool = True):
        types = ticket_model(ticket_values(overrides), unset, precondition).axis_types()
        self.assertEqual([t.name for t in types], ["Ticket"])
        return types[0].axes[0]

    def test_move_with_no_trigger_event_takes_its_usage_name(self):
        """A lone move with no triggerEvent: the event is None and event_name its usage name, never "[]".

        This is the silent case: with one such move, and no precondition
        whose unset relatedVia a check would see, no check sees the value,
        so only this test stands between "[]" and the generated output.
        """
        for form, unset in UNSET_FORMS.items():
            with self.subTest(form=form):
                ax = self.axis(unset, {(f"{AX}::placedToCancelled", "triggerEvent"): lambda: "Cancelled"}, precondition=False)
                moves = {m.name: m for m in ax.moves}
                self.assertIsNone(moves["placedToReady"].event)
                self.assertEqual(moves["placedToReady"].event_name, "placedToReady")
                self.assertEqual(moves["placedToCancelled"].event_name, "Cancelled")
                self.assertEqual(moves["readyToCollected"].event_name, "Collected")

    def test_two_moves_from_one_value_with_no_trigger_event_are_not_ambiguous(self):
        """placedToReady and placedToCancelled both leave triggerEvent unset: each takes its own name.

        The event-ambiguity check passes on both forms (the form of the Paws
        failure on 0.12.0: event '[]' from one value named by two moves).
        """
        for form, unset in UNSET_FORMS.items():
            with self.subTest(form=form):
                events = [(m.source, m.event_name) for m in self.axis(unset).moves]
                self.assertEqual(
                    events, [("placed", "placedToReady"), ("placed", "placedToCancelled"), ("ready", "Collected")]
                )

    def test_unset_fields_of_the_axis_and_move(self):
        """relatedVia, valueShape, axisDescription, requiredAuthority unset: None, None, None and the axis's authority."""
        for form, unset in UNSET_FORMS.items():
            with self.subTest(form=form):
                ax = self.axis(unset)
                pre = next(m for m in ax.moves if m.name == "readyToCollected").preconditions[0]
                self.assertIsNone(pre.related_via)
                self.assertEqual(pre.related_type, "Ticket")
                self.assertEqual(pre.required_values, ["ready"])
                self.assertIsNone(ax.shape)
                self.assertIsNone(ax.description)
                self.assertEqual([m.authorities for m in ax.moves], [["systemSide"]] * 3)

    def test_unset_required_values_is_refused_as_before(self):
        """requiredValues unset, in either form, is refused with the existing message."""
        for form, unset in UNSET_FORMS.items():
            with self.subTest(form=form):
                values = ticket_values()
                del values[(f"{AX}::readyToCollected::settled", "requiredValues")]
                with self.assertRaises(ModelError) as cm:
                    ticket_model(values, unset).axis_types()
                self.assertEqual(
                    str(cm.exception),
                    "precondition Ticket::stageAxis::readyToCollected::settled "
                    "needs requiredAxis, requiredValues and rejectionReason",
                )


if __name__ == "__main__":
    unittest.main()
