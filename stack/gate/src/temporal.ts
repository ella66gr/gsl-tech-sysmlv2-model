// Temporal client: starts the no-op workflow and waits for it to complete.
import { Connection, Client } from "@temporalio/client";
import { config } from "./config";

let client: Client | null = null;

async function getClient(): Promise<Client> {
  if (client) return client;
  const connection = await Connection.connect({ address: config.temporalAddress, connectTimeout: "10s" });
  client = new Client({ connection, namespace: config.temporalNamespace });
  return client;
}

export async function runNoop(token: string, timeoutMs = 30_000): Promise<{ workflowId: string; result: string }> {
  const c = await getClient();
  const workflowId = `stack-health-noop-${token}`;
  const handle = await c.workflow.start("noop", {
    taskQueue: config.healthTaskQueue,
    workflowId,
    args: [token],
    workflowExecutionTimeout: `${Math.ceil(timeoutMs / 1000)}s`,
  });
  const result = await Promise.race([
    handle.result() as Promise<string>,
    new Promise<string>((_, rej) => setTimeout(() => rej(new Error(`no-op workflow did not complete in ${timeoutMs} ms`)), timeoutMs)),
  ]);
  return { workflowId, result };
}
