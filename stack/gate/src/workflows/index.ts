// The only workflow deployed to Temporal at S0.1: a no-op the health check
// starts and waits for. S0.6 adds the fulfilment workflow.
export async function noop(token: string): Promise<string> {
  return `noop:${token}`;
}
