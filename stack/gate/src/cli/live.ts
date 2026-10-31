// Container healthcheck: the gate answers /live.
fetch("http://localhost:7220/live", { signal: AbortSignal.timeout(3000) })
  .then((r) => process.exit(r.status === 200 ? 0 : 1))
  .catch(() => process.exit(1));
