// Build step: bundles the workflow code once, at image build time, so the
// worker starts without bundling at runtime.
import * as fs from "node:fs";
import * as path from "node:path";
import { bundleWorkflowCode } from "@temporalio/worker";

async function main() {
  const { code } = await bundleWorkflowCode({ workflowsPath: require.resolve("../workflows") });
  const out = path.join(__dirname, "..", "workflow-bundle.js");
  fs.writeFileSync(out, code);
  console.log(`workflow bundle written: ${out} (${code.length} bytes)`);
}
main().catch((e) => { console.error(e); process.exit(1); });
