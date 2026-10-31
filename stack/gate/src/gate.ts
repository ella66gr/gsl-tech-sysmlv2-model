// The constraint gate's write path (S0.1, specification 2.5 item 4), behind the
// store interface (OP-134 spike, B1). The S0.1 write path itself moved,
// unchanged, to store/rdf4j-txn-write.ts; each store adapter supplies `write`.
// The Access Decision Evaluator is consulted from S0.7, not here.
import { openStore, Store } from "./store";
import { WriteRequest, WriteOutcome } from "./store/types";

export type { WriteRequest, WriteOutcome, Timings } from "./store/types";

let runtime: Store | null = null;
export const runtimeStore = (): Store => (runtime ??= openStore());

// `s` defaults to the runtime repository; the capability checks pass a
// scratch repository so they never change the runtime repository's shapes.
export function write(req: WriteRequest, s: Store = runtimeStore()): Promise<WriteOutcome> {
  return s.write(req);
}
