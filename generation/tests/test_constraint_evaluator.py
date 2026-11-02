from generation import constraint_evaluator
from generation.common import ModelError
from generation.tests.support import GenTestCase


class ConstraintEvaluatorTest(GenTestCase):
    def gen(self, constraint_package="Rules", spec_package="RuleSpecs"):
        return constraint_evaluator.generate(
            self.root / "rules" / "model",
            self.out,
            self.root,
            constraint_package,
            spec_package,
            self.root / "rules" / "platform",
            "Fixture",
            verbose=False,
        )

    def test_evaluators_from_any_tenant_package_names(self):
        self.gen()
        ev = self.read("constraint-evaluators.ts")
        self.assertIn("export function evaluateStaffPresent(", ev)
        self.assertIn("    (inputs.booked <= inputs.capacity)", ev)
        self.assertIn(" * Satisfies: WithinCapacity", ev)
        self.assertIn("    severity: 'critical',", ev)
        specs = self.read("constraint-specs.ts")
        self.assertIn("  'WithinCapacityConstraint': {", specs)
        self.assertIn("  'CapacityBands': {", specs)

    def test_header_names_inputs_and_carries_no_timestamp(self):
        self.gen()
        ev = self.read("constraint-evaluators.ts")
        self.assertTrue(ev.startswith(
            "// ============================================================\n"
            "// DO NOT EDIT — Generated from Fixture SysML v2 model\n"
            "// Source: rules/model/rules.sysml (FixtureTenant::Rules)\n"
            "// Generator: generation/constraint_evaluator.py\n"
            "// ============================================================\n\n"
        ))
        types = self.read("evaluation-types.ts")
        self.assertIn(
            "// Source: rules/platform/platform.sysml (PlatformFixture::LogicEngine, ::EvaluationSpecs)", types
        )
        for name in ("evaluation-types.ts", "constraint-evaluators.ts", "constraint-specs.ts"):
            self.assert_no_timestamp(self.read(name))

    def test_determinism(self):
        self.gen()
        first = [self.read(n) for n in ("evaluation-types.ts", "constraint-evaluators.ts", "constraint-specs.ts")]
        self.gen()
        second = [self.read(n) for n in ("evaluation-types.ts", "constraint-evaluators.ts", "constraint-specs.ts")]
        self.assertEqual(first, second)

    def test_unknown_package_is_an_error(self):
        with self.assertRaisesRegex(ModelError, "NoSuchPackage"):
            self.gen(constraint_package="NoSuchPackage")
