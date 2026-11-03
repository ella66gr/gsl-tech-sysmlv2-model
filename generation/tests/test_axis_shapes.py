"""The runtime form of an axis value (S0.5 Pass B8, H-0647): IRI rules, checks, shapes, Stage 3g.

On the fixture model: the IRI rules of ``generation.axis_iris``; the four
checks ``generation.status_axes`` adds for them; the membership and subject
shapes ``generation.axis_shapes`` writes; and the declarations and runtime
vocabulary the OWL pipeline's Stage 3g writes. Then one cross-check on the
committed Cafe outputs, the only place the two generated files meet: the
``sh:in`` lists of ``axis-shapes.ttl`` hold exactly the ``AxisValue``
individuals of ``ontara-tenant-types.ttl``, each in one list.
"""

import sys
import types as pytypes
from pathlib import Path

from rdflib import Graph, Literal, Namespace, URIRef
from rdflib.collection import Collection
from rdflib.namespace import OWL, RDF, RDFS, SKOS

from generation import axis_iris, axis_shapes, resolved
from generation.common import ModelError
from generation.tests.support import GenTestCase

REPO = Path(__file__).resolve().parents[2]
SHOP = "shop/domain/shop.sysml"
SH = Namespace("http://www.w3.org/ns/shacl#")
AX = Namespace(axis_iris.AXIS_NS)
BMM = Namespace(axis_iris.BMM_NS)
O = Namespace(axis_iris.tenant_ontology_ns("shop"))
D = Namespace(axis_iris.tenant_data_ns("shop"))
SHP = Namespace(axis_iris.tenant_shapes_ns("shop"))

FLAG_AXIS = (
    "        part {usage} : StatusAxis {{\n"
    '            :>> axisName = "{name}";\n'
    "            :>> axisAuthority = (AxisAuthority::operatorSide);\n"
    '            :>> defaultValue = "clear";\n'
    '            part :>> valueSpace : ValueSpace {{ :>> enumValues = ("clear", "raised"); }}\n'
    "            part clearToRaised : AxisTransition {{\n"
    '                :>> fromValue = "clear"; :>> toValue = "raised"; :>> transitionLabel = "Raise flag";\n'
    "            }}\n"
    "        }}\n"
)


def pipeline():
    """scripts/gen_owl_pipeline.py, imported as a module (it puts the repository on sys.path itself)."""
    scripts = str(REPO / "scripts")
    if scripts not in sys.path:
        sys.path.insert(0, scripts)
    import gen_owl_pipeline

    return gen_owl_pipeline


class AxisShapesTest(GenTestCase):
    def types(self):
        return resolved.load(self.root / "shop", self.root).axis_types()

    def gen(self):
        return self.quietly(axis_shapes.generate, self.root / "shop", self.out, self.root, "shop", "Shop")

    def shapes(self) -> Graph:
        self.gen()
        return Graph().parse(self.out / axis_shapes.OUT_FILE, format="turtle")

    # -- the IRI rules ---------------------------------------------------

    def test_iri_rules(self):
        ticket = {a.name: a for t in self.types() for a in t.axes if t.name == "Ticket"}
        stage = ticket["stage"]
        self.assertEqual(axis_iris.predicate_iri("shop", stage), "https://ontara.dev/ontology/tenant/shop/ticketStage")
        self.assertEqual(
            axis_iris.value_iri("shop", stage, "inPreparation"),
            "https://ontara.dev/ontology/tenant/shop/TicketStage-inPreparation",
        )
        self.assertEqual(axis_iris.axis_decl_iri("shop", stage), "https://ontara.dev/data/shop/reasoning/ticket-stage-axis")
        self.assertEqual(axis_iris.value_space_iri("shop", stage), "https://ontara.dev/data/shop/reasoning/ticket-stage-values")
        self.assertEqual(
            axis_iris.move_iri("shop", stage, "readyToCollected"),
            "https://ontara.dev/data/shop/reasoning/ticket-stage-readyToCollected",
        )
        self.assertEqual(
            axis_iris.precondition_iri("shop", "TicketTask", "ticketUnderWay"),
            "https://ontara.dev/data/shop/reasoning/tickettask-ticketUnderWay",
        )
        self.assertEqual(
            axis_iris.shape_locals(stage), ("TicketStageAxisShape", "TicketStageAxisShape-value", "TicketStageAxisSubjectShape")
        )
        self.assertEqual(axis_iris.tenant_shapes_ns("shop"), "https://ontara.dev/ontology/tenant/shop/shapes#")

    # -- the four checks -------------------------------------------------

    def test_model_errors(self):
        cases = [
            (
                ':>> enumValues = ("unpaid", "paid", "waived");',
                ':>> enumValues = ("unpaid", "paid", "waived", "part-paid");',
                "value 'part-paid' cannot be used in an IRI",
            ),
            (
                "        part paymentAxis : StatusAxis {",
                FLAG_AXIS.format(usage="taskWorkAxis", name="taskWork") + "\n        part paymentAxis : StatusAxis {",
                "would share the runtime predicate 'ticketTaskWork'",
            ),
            (
                "    part def TicketTask {",
                "    part def TICKETTASK {\n" + FLAG_AXIS.format(usage="flagAxis", name="flag")
                + "    }\n\n    part def TicketTask {",
                "differ only in case",
            ),
            (
                ':>> transitionLabel = "payment received";',
                ':>> transitionLabel = "payment received";\n'
                "                part settled : AxisPrecondition {\n"
                '                    :>> requiredAxis = "stage";\n'
                '                    :>> requiredValues = ("placed");\n'
                '                    :>> rejectionReason = "Fixture: a second precondition named settled.";\n'
                "                }",
                "share the usage name 'settled'",
            ),
        ]
        for old, new, msg in cases:
            with self.subTest(msg=msg):
                self.tearDown()
                self.setUp()
                self.edit(SHOP, old, new)
                with self.assertRaisesRegex(ModelError, msg):
                    self.gen()

    def test_the_fixture_passes_the_checks(self):
        self.assertEqual([t.name for t in self.types()], ["Ticket", "TicketTask"])

    # -- the shapes ------------------------------------------------------

    def test_membership_and_subject_shape_per_axis(self):
        g = self.shapes()
        for t in self.types():
            for ax in t.axes:
                node, prop, subject = (SHP[x] for x in axis_iris.shape_locals(ax))
                pred = URIRef(axis_iris.predicate_iri("shop", ax))
                with self.subTest(axis=ax.ident):
                    self.assertIn((node, RDF.type, SH.NodeShape), g)
                    self.assertIn((node, SH.targetClass, O[t.name]), g)
                    self.assertIn((node, SH.property, prop), g)
                    self.assertIn((prop, SH.path, pred), g)
                    self.assertIn((prop, SH.minCount, Literal(1)), g)
                    self.assertIn((prop, SH.maxCount, Literal(1)), g)
                    members = list(Collection(g, g.value(prop, SH["in"])))
                    self.assertEqual(members, [URIRef(axis_iris.value_iri("shop", ax, v)) for v in ax.values])
                    self.assertIn((subject, SH.targetSubjectsOf, pred), g)
                    self.assertIn((subject, SH["class"], O[t.name]), g)
        self.assertEqual(len(set(g.subjects(RDF.type, SH.NodeShape))), 6)

    def test_messages_use_the_display_name(self):
        text = self.gen().read_text(encoding="utf-8")
        self.assertIn('"A Ticket Task has exactly one work value, one of: waiting, working, done."@en', text)
        self.assertIn('"Only a Ticket carries the payment axis."@en', text)
        self.assertEqual(axis_shapes.display_name("OrderLine", "Order Line"), "Order Line")
        self.assertEqual(axis_shapes.display_name("TicketTask", None), "Ticket Task")

    def test_determinism_and_header(self):
        self.gen()
        first = self.read(axis_shapes.OUT_FILE)
        self.gen()
        self.assertEqual(first, self.read(axis_shapes.OUT_FILE))
        self.assertTrue(first.startswith("# ===="))
        self.assertIn("# Generator: generation/axis_shapes.py", first)
        self.assert_no_timestamp(first)

    def test_a_bad_tenant_slug_is_refused(self):
        with self.assertRaisesRegex(ModelError, "lower-case slug"):
            self.quietly(axis_shapes.generate, self.root / "shop", self.out, self.root, "Shop Tenant", None)

    # -- Stage 3g of the OWL pipeline ------------------------------------

    def test_stage3g_declarations_and_vocabulary(self):
        p = pipeline()
        g = Graph()
        n = 0
        for t in self.types():
            elem = pytypes.SimpleNamespace(source_domain="shop", name=t.name, user_facing={}, axis_type=t)
            n += p.stage3g_axis_vocabulary(g, elem)
        self.assertEqual(n, 3)
        task = D["tickettask-work-axis"]
        self.assertIn((task, RDF.type, BMM.StatusAxis), g)
        self.assertIn((task, RDFS.label, Literal("Ticket task work axis", lang="en")), g)
        self.assertIn((task, RDFS.comment, Literal("Fixture work axis.", lang="en")), g)
        self.assertIn((task, AX.axisDeclaredOn, O.TicketTask), g)
        self.assertIn((task, AX.valuePredicate, O.ticketTaskWork), g)
        self.assertIn((task, AX.hasValueSpace, D["tickettask-work-values"]), g)
        # a move with no triggerEvent: none written; its authority is the axis's
        waive = D["ticket-payment-unpaidToWaived"]
        self.assertEqual(list(g.objects(waive, AX.triggerEvent)), [])
        self.assertEqual(
            sorted(str(x) for x in g.objects(waive, AX.requiredAuthority)), ["operatorSide", "systemSide"]
        )
        # a precondition through a reference, and one on the same instance
        pre = D["tickettask-ticketUnderWay"]
        self.assertIn((D["tickettask-work-waitingToWorking"], AX.hasPrecondition, pre), g)
        self.assertIn((pre, AX.relatedVia, Literal("ticket")), g)
        self.assertEqual(sorted(str(x) for x in g.objects(pre, AX.requiredValue)), ["inPreparation", "ready"])
        self.assertEqual(list(g.objects(D["ticket-settled"], AX.relatedVia)), [])
        # the runtime vocabulary
        self.assertIn((O.ticketStage, RDF.type, OWL.ObjectProperty), g)
        self.assertIn((O.ticketStage, RDFS.subPropertyOf, AX.hasAxisValue), g)
        self.assertIn((O.ticketStage, RDFS.label, Literal("ticket stage", lang="en")), g)
        v = O["TicketStage-inPreparation"]
        self.assertIn((v, RDF.type, AX.AxisValue), g)
        self.assertIn((v, RDFS.label, Literal("in preparation", lang="en")), g)
        self.assertIn((v, SKOS.notation, Literal("inPreparation")), g)
        self.assertIn((D["ticket-stage-values"], AX.permitsValue, v), g)
        self.assertEqual(len(set(g.subjects(RDF.type, AX.AxisValue))), 5 + 3 + 3)


class CommittedCafeOutputsTest(GenTestCase):
    """The committed Cafe shapes name exactly the committed tenant-types values."""

    def test_shapes_and_tenant_types_agree(self):
        shapes = Graph().parse(REPO / "exercises/coffeeshop-demonstrator/generated/axis-shapes.ttl", format="turtle")
        tt = Graph().parse(REPO / "generated/ontology/ontara-tenant-types.ttl", format="turtle")
        lists = [list(Collection(shapes, o)) for o in shapes.objects(None, SH["in"])]
        in_shapes = [v for lst in lists for v in lst]
        values = set(tt.subjects(RDF.type, AX.AxisValue))
        self.assertEqual(len(in_shapes), len(set(in_shapes)), "a value appears in two sh:in lists")
        self.assertEqual(set(in_shapes), values)
        self.assertEqual(len(values), 12)
        # each shape's predicate is the one its axis declaration names
        paths = set(shapes.objects(None, SH.path))
        declared = set(tt.objects(None, AX.valuePredicate))
        self.assertEqual(paths, declared)
        for p in paths:
            self.assertIn((p, RDFS.subPropertyOf, AX.hasAxisValue), tt)
