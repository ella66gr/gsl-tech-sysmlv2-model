// The constraint gate's HTTP service.
//   POST /write   JSON { turtle?, updates?, remove?, label? }, or text/turtle
//                 200 committed | 403 refused (a write rule of the named-graph
//                 scheme) | 422 rejected (SHACL) | 502 fault | 400 bad request.
//                 No graph: the Write Stamping Stage sets it (S0.5 Pass B3); a
//                 request naming one (JSON "graph", or ?graph=) is refused.
//   GET  /health  the S0.1 health check: 200 pass | 503 fail
//   GET  /live    liveness only (used by the container healthcheck)
import * as http from "node:http";
import { write, RuntimeWrite } from "./gate";
import { runHealth } from "./health";
import { config } from "./config";

function send(res: http.ServerResponse, status: number, body: unknown) {
  const text = JSON.stringify(body, null, 2);
  res.writeHead(status, { "Content-Type": "application/json", "Content-Length": Buffer.byteLength(text) });
  res.end(text);
}

function readBody(req: http.IncomingMessage): Promise<string> {
  return new Promise((resolve, reject) => {
    const chunks: Buffer[] = [];
    req.on("data", (c) => chunks.push(c));
    req.on("end", () => resolve(Buffer.concat(chunks).toString("utf8")));
    req.on("error", reject);
  });
}

const STATUS = { committed: 200, refused: 403, rejected: 422, fault: 502 } as const;

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url ?? "/", "http://gate");
  try {
    if (req.method === "GET" && url.pathname === "/live") return send(res, 200, { status: "live" });
    if (req.method === "GET" && url.pathname === "/health") {
      const h = await runHealth();
      return send(res, h.status === "pass" ? 200 : 503, h);
    }
    if (req.method === "POST" && url.pathname === "/write") {
      const raw = await readBody(req);
      const ct = (req.headers["content-type"] ?? "").toLowerCase();
      let wr: RuntimeWrite & { graph?: unknown };
      if (ct.includes("text/turtle")) {
        wr = { turtle: raw, ...(url.searchParams.has("graph") ? { graph: url.searchParams.get("graph") } : {}) };
      } else {
        try { wr = JSON.parse(raw); } catch { return send(res, 400, { outcome: "bad-request", detail: "body is not JSON or text/turtle" }); }
      }
      if (!wr.turtle && !(wr.updates && wr.updates.length) && !(wr.remove && wr.remove.length)) return send(res, 400, { outcome: "bad-request", detail: "nothing to write: give turtle, updates and/or remove" });
      const out = await write(wr);
      if (out.outcome !== "committed") console.log(`[gate] ${out.outcome} at ${out.stage}${wr.label ? ` (${wr.label})` : ""}; validation: ${out.validation ?? "(no X-Ontara-Validation header)"}`);
      return send(res, STATUS[out.outcome], out);
    }
    send(res, 404, { error: "not found" });
  } catch (e: any) {
    send(res, 500, { outcome: "fault", stage: "gate", detail: String(e?.stack ?? e) });
  }
});

server.listen(config.port, "0.0.0.0", () => console.log(`[gate] listening on :${config.port}, dataset ${config.dataset} at ${config.storeUrl} (Fuseki, validated-update; graphs set by the Write Stamping Stage)`));
