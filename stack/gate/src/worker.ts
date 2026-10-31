// Temporal worker serving the health check's no-op workflow.
import * as path from "node:path";
import { NativeConnection, Worker } from "@temporalio/worker";
import { config } from "./config";

async function connect(): Promise<NativeConnection> {
  for (let i = 1; ; i++) {
    try {
      return await NativeConnection.connect({ address: config.temporalAddress });
    } catch (e) {
      if (i >= 60) throw e;
      console.log(`[worker] Temporal not reachable yet (attempt ${i}), retrying`);
      await new Promise((r) => setTimeout(r, 2000));
    }
  }
}

async function main() {
  const connection = await connect();
  const worker = await Worker.create({
    connection,
    namespace: config.temporalNamespace,
    taskQueue: config.healthTaskQueue,
    workflowBundle: { codePath: path.join(__dirname, "workflow-bundle.js") },
  });
  console.log(`[worker] polling task queue ${config.healthTaskQueue} on ${config.temporalAddress}`);
  await worker.run();
}

main().catch((e) => { console.error(e); process.exit(1); });
