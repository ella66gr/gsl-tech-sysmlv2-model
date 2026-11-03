// Minimal HTTP client for the store adapter. Node's built-in fetch only.
// (Moved out of the S0.1 GraphDB client, graphdb.ts, at S521 pass 3.)

export interface HttpResult {
  status: number;
  contentType: string | null;
  body: string;
  headers: Headers;
}

const DEFAULT_TIMEOUT_MS = 60_000;

export async function http(
  method: string,
  url: string,
  opts: { body?: string; contentType?: string; accept?: string; timeoutMs?: number; headers?: Record<string, string> } = {},
): Promise<HttpResult> {
  const headers: Record<string, string> = { ...(opts.headers ?? {}) };
  if (opts.contentType) headers["Content-Type"] = opts.contentType;
  if (opts.accept) headers["Accept"] = opts.accept;
  const res = await fetch(url, {
    method,
    headers,
    body: opts.body,
    signal: AbortSignal.timeout(opts.timeoutMs ?? DEFAULT_TIMEOUT_MS),
  });
  const body = await res.text();
  return { status: res.status, contentType: res.headers.get("content-type"), body, headers: res.headers };
}
