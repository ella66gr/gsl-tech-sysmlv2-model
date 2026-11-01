// The constraint gate's write path (S0.1, specification 2.5 item 4), kept
// thin, behind the store interface (store/). One adapter at pass 3: Fuseki
// with Ontara's validated-update module (store/fuseki.ts).
//
// A write is one SPARQL Update request: the triples as INSERT DATA, then the
// rules (labelling, readiness), validated by the module before commit. The
// module answers 200 on commit, 422 with the SHACL report on a rejection and
// 500 on a fault, and has already aborted the transaction in each failing
// case, so the gate needs no rollback. write() never rejects (S519, e42a70c).
// The Access Decision Evaluator is consulted from S0.7, not here.
import { openStore, Store } from "./store";
import { WriteRequest, WriteOutcome } from "./store/types";

export type { WriteRequest, WriteOutcome, Timings } from "./store/types";

let runtime: Store | null = null;
export const runtimeStore = (): Store => (runtime ??= openStore());

// `s` defaults to the runtime dataset; the capability checks pass the
// scratch dataset so they never change the runtime dataset's shapes.
export function write(req: WriteRequest, s: Store = runtimeStore()): Promise<WriteOutcome> {
  return s.write(req);
}
