from generation import mermaid_pathway
from generation.tests.support import GenTestCase


class MermaidPathwayTest(GenTestCase):
    def gen(self):
        return self.quietly(mermaid_pathway.generate, self.root / "shop", self.out, self.root, "ServeTicket", None)

    def test_branch_and_convergence(self):
        self.gen()
        text = self.read("serve-ticket-pathway.mmd")
        self.assertIn("flowchart TD", text)
        self.assertIn("    receive([Receive])", text)  # first step
        self.assertIn("    finish([Finish])", text)  # terminal step
        self.assertIn("    check --> pathA", text)
        self.assertIn("    check --> pathB", text)
        self.assertIn("    pathA --> finish", text)
        self.assertIn("    pathB --> finish", text)
        self.assertIn("    style check fill:#FF9800", text)  # branch point
        self.assertNotIn("```", text)

    def test_header_and_determinism(self):
        self.gen()
        first = self.read("serve-ticket-pathway.mmd")
        self.gen()
        self.assertEqual(first, self.read("serve-ticket-pathway.mmd"))
        self.assertTrue(first.startswith("%% ===="))
        self.assertIn("%% Generator: generation/mermaid_pathway.py", first)
        self.assert_no_timestamp(first)
