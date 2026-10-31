# OP-134 runtime-store spike (S518)

Branch `spike/op-134-store` only; never merged. Four configurations of the Cafe runtime store, each run through the same S0.1 health check, capability checks and load harness via the gate's store interface (`stack/gate/src/store/`).

| Configuration | Folder | Store | SHACL |
|---|---|---|---|
| `graphdb` | `graphdb/` | GraphDB 11.3.1, ruleset `empty` (the control) | in the store (RDF4J ShaclSail 5.2.2) |
| `rdf4j` | `rdf4j/` | RDF4J Server 6.1.0 (`eclipse/rdf4j-workbench:6.1.0-tomcat`), NativeStore | in the store (ShaclSail 6.1.0) |
| `rdf4j-lmdb` | `rdf4j-lmdb/` | the same, LmdbStore | in the store (ShaclSail 6.1.0) |
| `fuseki` | `fuseki/` | Apache Jena Fuseki 5.6.0, TDB2, with the `validated-update` module (`fuseki/module/`), built here | in the store (jena-shacl `GraphValidation.update`, whole union graph) |
| `oxigraph` | `oxigraph/` | Oxigraph 0.5.13 (store, staging, scratch) | in the gate (shacl-engine 1.1.3) |

## Running one configuration

From `stack/`. Only one stack may be up at a time (they share ports 7210 and 7220), and GraphDB Desktop must not run; `up` refuses otherwise. The S0.1 stack (`stack/compose.yaml`) must be down too.

```bash
spike/bin/spike.sh <configuration> up             # build, start, print the bootstrap
spike/bin/spike.sh <configuration> health         # bin/health.sh; also results/spike-op134/<configuration>/health.json
spike/bin/spike.sh <configuration> capabilities   # bin/capabilities.sh -> results/spike-op134/<configuration>/
spike/bin/spike.sh <configuration> write fixtures/writes/known-bad.ttl   # exit 1, "rejected", shape named, rolledBack true
spike/bin/spike.sh <configuration> loadtest [args]                      # bin/loadtest.sh -> results/spike-op134/<configuration>/loadtest/
spike/bin/measure.sh <configuration>              # the full load series used in the spike
spike/bin/summarise.sh <configuration>            # one table row per load run
spike/bin/spike.sh <configuration> down           # keep data volumes (down-v removes them)
```

The GraphDB configuration reads the licence path from `stack/.env` (README step 2).

## Known hazards found by the spike

1. **RDF4J (both stores), three writers with continuous readers:** latency climbs to seconds, the 2 GB heap runs out, and acknowledged commits were later missing (every order after 188 on NativeStore, after 100 or 101 on LMDB, out of 500 per writer). Count orders per graph after any such run.
2. **RDF4J Server answers a SHACL rejection with HTTP 409 and an RDF/JSON report;** the RDF4J adapter translates it. A parse failure before rollback leaves the repository lock held: restart the store (stack README §6).
3. **Oxigraph:** validation is in the gate, on a heuristic read set (see `gate/src/store/oxigraph.ts`); the gate lock is per process.
