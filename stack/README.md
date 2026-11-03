# Ontara Cafe runtime stack (Plan B Stage 0, S0.1)

This folder is the Cafe's runtime: Apache Jena Fuseki on Jena 6.2.0 with Ontara's validated-update module, which validates every write with SHACL inside its write transaction; a thin TypeScript constraint gate; and Temporal. It runs in Docker Compose on one machine. This README is the rebuild procedure: follow section 2 from the top on any machine and you reach a passing health check.

The stack depends on nothing on the host except Docker Engine, the Compose plugin and git. It needs no licence. It does **not** use the Mac's authoring rig: not the native `ontara` Postgres database, not the resolver, not the vault, not GraphDB Desktop or its `ontara-dev` repository. GraphDB Desktop may run beside it; they share no port.

Specification: Plan B Stage 0 specification (vault slug `cafe-plan-b-stage-0-specification`) section 2. The runtime store decision: ADR-014 (vault slug `ontara-adr-014-runtime-triple-store`). Built on GraphDB at S517 (pass 1); moved to Fuseki at S521 (pass 3).

## 1. What runs

| Service | Image | Role | Host port |
|---|---|---|---|
| `store` | built here (`ontara-cafe-stack/store:local`, `store/`) | Apache Jena Fuseki 6.2.0, TDB2, with the validated-update module (version 0.4.0) in targeted mode. Two datasets: `cafe-runtime` (knowledge graph and runtime state) and `cafe-capability-scratch`. Configuration: section 8 | `127.0.0.1:7210` (read-only listener; section 8) |
| `bootstrap` | built here (`ontara-cafe-stack/gate:local`, `gate/`) | One-shot: checks the module's status, loads the shapes and the knowledge graph, checks again, then exits | none |
| `gate` | built here | The constraint gate: `/write`, `/health`, `/live` | `127.0.0.1:7220` |
| `worker` | built here | Temporal worker serving the health check's no-op workflow only | none |
| `temporal` | `temporalio/server:1.32.0` | Temporal server | none (stack network only) |
| `temporal-postgresql` | `postgres:16.10` | Temporal's own store (not the `ontara` database) | none |
| `temporal-schema`, `temporal-namespace` | `temporalio/admin-tools:1.32.0` | One-shot: Temporal schema setup and the `default` namespace | none |

Ports bind to `127.0.0.1` only; nothing is exposed on the network. The store is on 7210, not GraphDB Desktop's 7200, so scripts aimed at GraphDB Desktop can never reach the stack by mistake. Data lives in two named volumes: `ontara-cafe-stack_store-data` and `ontara-cafe-stack_temporal-postgres-data`.

**The Jena version is pinned at 6.2.0** in `compose.yaml` (`x-jena-version`). It is the store image's build argument and what the bootstrap and the health check require the running module to report. The store's `Dockerfile` refuses to build any version below 6.1.0: Jena before 6.1.0 has a TDB2 abort defect (apache/jena#3877) that silently loses confirmed writes (ADR-014 §6). Upgrade it deliberately, and run the regression check (step 8) at every change of version.

## 2. Rebuild procedure

Run every command from a terminal. Commands after step 1 run inside `stack/`.

### Step 1. Get the repository

```bash
git clone https://github.com/ella66gr/gsl-tech-sysmlv2-model.git gsl-sysml-model
cd gsl-sysml-model/stack
```

On the Mac, where the repository already exists: `cd ~/Developer/gsl-tech/gsl-sysml-model/stack`.

### Step 2. Check the prerequisites

```bash
bin/check-prereqs.sh
```

Expected last line: `PREREQUISITES: OK`. It checks Docker Engine (daemon reachable), the Compose plugin and git, and that ports 7210 and 7220 are free. Anything missing prints `MISSING/FAIL` and the script exits 1. Nothing else is assumed present: no Node, Java, Maven, Python, curl or make on the host. No licence is needed.

On Ubuntu, Docker Engine and the Compose plugin come from Docker's apt repository (`docker-ce`, `docker-compose-plugin`; see docs.docker.com/engine/install/ubuntu). Add your user to the `docker` group, then log out and in, so `docker` runs without `sudo`.

Ports or the store's heap can be changed in an optional `stack/.env` (see `.env.example`). The stack needs none of it.

### Step 3. Build the store and gate images on this machine

```bash
docker compose build
```

These are the only images the stack builds, and they are built here, by this command, on the machine that runs them (S0.1 image rule): the Mac is arm64, the clean machine x86_64, and nothing built on one is carried to the other. The store image compiles the validation module with Maven inside the build and downloads Jena 6.2.0 from Maven Central; the gate image installs its npm packages from `package-lock.json`. The build needs internet access. The other images are pulled, pinned by tag and multi-arch digest.

The store build stops at its first step, before downloading anything, if the Jena version is below 6.1.0:

```
JENA_VERSION=5.6.0 is below 6.1.0: Jena before 6.1.0 has the TDB2 abort defect (apache/jena#3877; ADR-014). Refusing to build.
```

### Step 4. Start the stack

```bash
docker compose up -d --wait
docker compose logs --no-log-prefix bootstrap
```

`up --wait` returns when every service is healthy or has completed. It returns non-zero, and the gate does not start, if the bootstrap fails. The bootstrap log must show:

```
[bootstrap] Apache Jena Fuseki 6.2.0 (Jena 6.2.0); licence: none needed (Apache-2.0)
[bootstrap] status /cafe-runtime: module="ontara-fuseki-validated-update 0.4.0" validating=true probe=passed mode=targeted jena=6.2.0 (built for 6.2.0) store=TDB2 unionDefaultGraph=true inference=none ... targetShapes=...
[bootstrap] status /cafe-capability-scratch: module="ontara-fuseki-validated-update 0.4.0" validating=false probe=passed mode=targeted jena=6.2.0 ... targetShapes=0
[bootstrap] Reality Reference Branch of cafe: dhbId <a lower-case UUID v4> (generated by the store ..., kept with it); runtime graphs <https://ontara.dev/graph/dhb/cafe/<dhbId>/dbr> and <.../dsr>
[bootstrap] shapes loaded into <https://ontara.dev/graph/shapes>: 147 triples from fixtures/shapes/standin-shapes-core-only.ttl + fixtures/shapes/spike-two-sided-readiness.ttl + tenant-generated/cafe/axis-shapes.ttl (read back by SPARQL)
[bootstrap] kg <https://ontara.dev/graph/kg/domain> replaced by ontology/imports/bfo-core.owl: ... (then 13 lines "added", and kg/correspondence)
[bootstrap] kg metamodel: <https://ontara.dev/graph/kg/metamodel> 0 triples
[bootstrap] kg domain: <https://ontara.dev/graph/kg/domain> 23327 triples
[bootstrap] kg correspondence: <https://ontara.dev/graph/kg/correspondence> 1400 triples
[bootstrap] status /cafe-runtime: ... validating=true probe=passed ... shapesTriples=147 targetShapes=9
[bootstrap] OK in ... s: validating, targeted mode, Jena 6.2.0, 147 shapes triples
```

The bootstrap reads the module's status (`GET /<dataset>/validated-update`) on both datasets before it writes anything, and again after loading. Before loading it requires the validation probe passed (the write path's own validation rejects known violations), targeted mode, Jena 6.2.0 (both the version loaded and the image's build argument), TDB2 with the union graph as default graph and no inference; `validating` may read `false` at that point, on a new store or on the scratch dataset, because no shapes are loaded yet (section 8). It also requires the runtime dataset to report its Reality Reference Branch identifier (`rrb`; section 4) and the shapes graph `https://ontara.dev/graph/shapes`. After loading it requires `validating=true`, and the shapes count it wrote. Otherwise it prints a `BOOTSTRAP FAILED` banner and exits 2. Do not continue: never use the store unvalidated (section 6, "Recovery").

### Step 5. Health check

```bash
bin/health.sh --record       # add --json for the full result
```

Expected: six `PASS` lines and `HEALTH: PASS`. Exit code 0 on pass, 1 on fail, 2 if the gate is unreachable. `--record` also writes the full result to `results/fuseki-<UTC date>/health/<time>-health.json`. The same check is the endpoint `GET http://127.0.0.1:7220/health` (200 pass, 503 fail). It tests each service through the client the Cafe uses (H-0268):

1. The store: SPARQL probes of the knowledge graph's three graphs return the expected content (`fixtures/health/kg-expectations.json`: the BMM, the record module, BFO, the Cafe's tenant types, axis declarations and reasoning module in `kg/domain`, the correspondence records in `kg/correspondence`, `kg/metamodel` empty), and the module's status reads `validating=true` (measured; section 8), targeted mode, Jena 6.2.0 and shapes loaded.
2. The gate, over its HTTP API: a known-good stand-in write (an order and a record of it) commits, into the Reality Reference Branch's `dbr` graph; a known-bad one comes back as a SHACL rejection naming `sis:RecordModeMethodShape`; a further write commits, and the rejected record is not stored, which shows the rejected write left nothing behind. Each write must carry an `X-Ontara-Validation` header naming targeted mode. The check then removes its own instances by IRI through the gate.
3. Temporal: a no-op workflow starts and completes.

Steps 2 to 5 can be run, and timed, in one go with `bin/rebuild.sh` (prints `PROCEDURE ELAPSED: N s`).

To read the store's status yourself: `bin/store-status.sh` (expected last line `STORE STATUS: OK`; `--line` for one line), or from the host, if curl is present, `curl -s http://127.0.0.1:7210/cafe-runtime/validated-update` (its `listener` field reads `published`). The fields are described in section 8.

### Step 6. SHACL capability checks

```bash
bin/capabilities.sh
```

Runs the checks twice, through the store interface, in the capability scratch dataset (the runtime dataset is not touched):

1. in targeted mode, against the stack's own store;
2. in whole mode, against a second, short-lived container of the same store image started with `ONTARA_VALIDATION=whole` (no published port, its data inside the container, removed when the script ends).

For each SHACL component the Stage 0 shapes may use, it loads a shape and sends a violating and a conforming write; it tests the labelling step and the inline `VALUES` binding a mapping rule needs; whether `sh:message` comes back in the rejection report; the S515 five-case test; R4 (no store-side inference); `sh:rule`; and Cyril's two-sided readiness shapes. Results: `results/fuseki-<date>/capabilities/shacl-capabilities.md` (both modes in one table) and `shacl-capabilities-targeted.json`/`.md`, `shacl-capabilities-whole.json`/`.md`. An unenforced component is a result, not a failure. The script exits non-zero if R4 fails, or if any write was validated in a mode other than the one expected (a configuration fault).

### Step 7. Load test

```bash
bin/loadtest.sh                                   # 500 orders, three paced readers
bin/loadtest.sh --orders 500 --readers continuous --label stress
```

Each write is the 54-triple order (`fixtures/writes/order-54.ttl`) with the readiness rule and the labelling step in the same request. The order arrives in preparation and paid, with every line ready, so the rule makes the move `inPreparation` to `ready` on every write. Axis values are in their runtime form (S0.5 Pass B8): one triple per axis, through the generated predicate, with a value IRI from the axis's declared set. The shapes are the runtime set the bootstrap loads: the stand-in record shape, Cyril's two-sided core readiness shapes (not the S0.1 stand-in SPARQL constraint, which targeted validation misses in its line-only case; ADR-014 §4.3) and the Cafe's generated axis shapes. Each run writes `results/fuseki-<UTC date>/loadtest/<UTC time>-<os>-<arch>-<label>/` with:

1. `machine.txt`: the machine (model, processors, memory, Docker), the store image, and the store as its module reports it (product, Jena version, validation mode);
2. `writes.csv`: raw per-write timings, one row per write, with each write's `X-Ontara-Validation` header in the `validation` column (the latency is `latency_ms`, the HTTP round trip to the gate);
3. `readers.csv`: raw per-query reader timings;
4. `summary.json`: p50, p95 and maximum, per-100-write growth, the correctness check, the store, and the count of writes by validation mode.

Every order goes into the Reality Reference Branch's `dbr` graph, placed by the gate (the harness sends no graph); with `--writers N` every writer writes there, as the runtime does. Nothing is cleared before a run, and after the run the harness removes its own orders by IRI through the gate, unless `--keep` (accumulate across runs; the regression check's preload keeps its orders). The correctness check counts the run's own orders.

A write validated in any mode but targeted, or with no `X-Ontara-Validation` header, is a configuration fault: the summary says `validAsMeasure: false` and the script exits 3. Fix the configuration and run again. Options: `--orders N`, `--readers paced|continuous|none`, `--shapes runtime|standin|core-only`, `--reject-every K` (a known-bad write before every Kth order), `--writers N`, `--keep` (keep this run's orders), `--label NAME`.

The pass figure is p95 at or under 500 ms, measured on the clean machine (specification 2.5 item 8.4). **Runs on the Mac are development runs and do not count.** To bring results back from another machine: commit the new `results/...` folder, or copy it.

### Step 8. Abort-defect regression check

```bash
bin/regression-check.sh
```

Expected last lines: eleven `PASS` lines and `REGRESSION CHECK: PASS`, exit 0. It runs the stack's own store image under the conditions that corrupted Jena 5.6.0 (ADR-014 §4.4 condition 3; specification 2.5 item 11):

1. a fresh store, in a new TDB2 directory, loaded by the stack's own bootstrap;
2. stored history: 300 orders written through the load harness;
3. cold caches: the store restarted before the first write;
4. one known-bad write, then 60 known-good writes, one at a time through the gate;
5. the good records counted and every quad read back, then a store restart, and the count and read-back again;
6. the offline node-table check (`NodeTableCheck`, with the store stopped: no zero-filled run in `nodes-data.obj`, and every quad readable) and the Jena file-layer check (`BdfTruncateCheck`).

It passes only if every good write is stored and readable after the restart, with no fault. It exits 1 on any lost or unreadable good write or any fault, and 2 if it could not run. It validates in whole mode by default, because the defect needs the aborted write to read nodes, and whole-mode validation reads them all. In targeted mode the aborted write reads too few, and a 5.6.0 store passes the store-level criteria (only the file-layer check catches it; S521): `--mode targeted` is a second leg, never the standing check. Results: `results/fuseki-<date>/regression/<run>/summary.json`, with every write's outcome (`outcomes.csv`), the read-backs, the store's log and both offline checks. It takes under a minute on the Mac.

It runs as its own Compose project (`ontara-cafe-regression`, `regression/compose.yaml`) with its own network and volume and no published port, so it never touches the runtime stack's data and may run while the stack is up. It needs the images from step 3. Run it here, on the clean machine, and at every change of Jena version.

Options: `--mode whole|targeted`, `--preload N`, `--good N` (at least 50), `--bad K`, `--label NAME`. A positive control, to show the check fails on a defective store, names another image: `bin/regression-check.sh --image <image> --expect-jena <version> --label positive-control`. Never point the runtime stack at such an image. The image must carry the current module (0.4.0 or later: package `dev.ontara.store`, two listeners, the measured status); the S521 positive-control image `ontara-spike/fuseki:5.6.0` carries the spike module and no longer runs under this check.

### Step 9. Scoping test suite

```bash
bin/scoping-test.sh                 # or, from the repository root: make stack-scoping-test
```

Expected last line `SCOPING TEST SUITE: PASS (160 of 160 cases)`, exit 0 (1 if any case failed, 2 if it could not run). It takes about 35 s on the Mac. It is ADR-014 §4.4 condition 1: an automated test of what targeted validation checks (specification §6.5 item B2). Run it at every change of the module, the gate's write path or the Jena version.

It runs as its own Compose project (`ontara-cafe-scoping`, `scoping/compose.yaml`), with its own network: a fresh store of the stack's own image in targeted mode, loaded by the stack's own bootstrap; a second store in whole mode; and the stack's own gate. Both stores keep their data inside their containers, and the script ends with `down -v` on its own project only, so nothing is kept and the runtime stack's data is never touched. It may run while the stack is up. It needs the images from step 3, built from the same commit (it says so if the gate image has no suite). The suite's store publishes its read-only listener on `127.0.0.1:7211` (`SCOPING_STORE_PORT`), so that one leg can write to it from a container on no stack network.

Its cases, by the seven groups of B2 (the code is `gate/src/cli/scoping.ts`; the shapes and data it loads are `fixtures/scoping/`):

1. **Targeted forms** (1.1 to 1.14), written with the runtime write policy. `INSERT DATA`, `DELETE DATA` and `DELETE/INSERT WHERE` (the readiness rule with the labelling step; `INSERT ... WHERE`; the `WITH <graph>` form; a `GRAPH ?g` variable; a blank-node instance), each conforming and violating, validated `targeted`. With a violation already in the graph that the request does not touch, a conforming targeted write commits: targeted means targeted. `DELETE WHERE` (the shorthand form) is not one of the three: it falls back to whole-graph validation, and with a write policy it is refused (`operation`).
2. **The other forms fall back to whole-graph validation** (2.1 to 2.6, each a to c). For `CLEAR`, `DROP`, `LOAD`, `ADD`, `MOVE` and `COPY`: (a) a conforming request commits, with `X-Ontara-Validation: whole (targeted mode: request has an operation other than ...)`; (b) with an untouched violation in the graph it is rejected, so the whole graph was validated; (c) a request that itself makes a violation is rejected (not applicable to `ADD`, which cannot change the union graph). `LOAD` reads a file the suite serves from the gate container.
3. **Mixed requests** (3.1 to 3.6). A targeted form plus `CLEAR` is validated whole, whether the violation is untouched or inserted; two targeted forms stay targeted; with a write policy, a mix that includes `CLEAR` is refused.
4. **The shape forms S0.6 will use** (Cyril, S0.5 Pass B step 2 §2), loaded with the Cafe's axis shapes and the two-sided readiness shapes: F1 to F10, each with violating and conforming writes, and E1 to E4, the four kinds no per-write check catches (ADR-014 §4.3), each committed by targeted validation and found by the module's whole-graph validation of the same data (E1 a stale aggregate; E2 a knowledge-graph change; E3 a constraint that becomes false with time alone, found 5 s later with no write; E4 an unbounded path). Also: E1 written with a SHACL-SPARQL sub-select, which Jena accepts and enforces.
5. **The known blind spot** (5.1 to 5.5). With the one-sided readiness shape (F11, `fixtures/scoping/shapes/blindspot.ttl`, which breaks the shape-authoring rule), a line-only regression on a ready order commits under targeted validation, and a whole-graph validation of the same data reports the order. With the two-sided shapes, the same write is rejected.
6. **The scheme's refusals** (6.0 to 6.12). Through the suite's gate: `default-graph`, `knowledge-graph-or-shapes` (each `kg` graph and the shapes graph, and a deletion from `kg/domain`), `other-branch`, `not-home`, `operation`, `outside-scheme`, `graph-from-writer` and `no-readable-side`, each with the store unchanged; a conforming order commits; `remove` acts only on the request's own branch. A second Declared History Branch is made for 6.3, 6.4 and 6.9 from a fresh UUID through the templates, its graph seeded with no policy (only the RRB exists at Stage 0). The published listener refuses a `validated-update` write (405). Against the whole-mode store directly, the same rules refuse in whole mode. Last, a runtime dataset whose identifier file is removed is refused at start.
7. **Two store behaviours** (7.1 to 7.4). **A default-graph write** sent straight to the module (no policy, which only the stack network allows) commits, in either mode, into Jena's stored default graph (`urn:x-arq:DefaultGraph`). That graph is in neither the union default graph nor any named graph, so validation never sees it: a whole-graph validation still conforms. The placement queries P2 and P3 do report it. **The standard endpoints**: every write route of a dataset (17 of them: update, form and protocol, Graph Store Protocol on `/data` and on the dataset, quads, RDF Patch, `validated-update`) is refused on the published listener and leaves the store unchanged. This is tested from inside the network against `store:3031` and from a container outside every stack network through the published port. The same requests are accepted on the stack-network listener (control).

Results: `results/<set>/scoping/<run>/`: `cases.md` (every case: group, expected, observed, the `X-Ontara-Validation` header), `summary.json`, the legs' `inside.json`, `outside.json` and `startup-refusal.json`, and the logs.

The whole-graph validation the suite uses in groups 4, 5 and 7 is the module's own whole-graph path: a request that changes nothing and is not a targeted form (`ADD SILENT GRAPH <g> TO GRAPH <g>`), answered 200 (conforms) or 422 (with the report).

## 3. Sending a write through the gate

From `stack/`:

```bash
bin/write.sh fixtures/writes/known-good.ttl     # exit 0, "outcome": "committed", HTTP 200
bin/write.sh fixtures/writes/known-bad.ttl      # exit 1, "outcome": "rejected", HTTP 422
```

Each fixture is an order and a stand-in record of it, so the gate can read the record's side from what it records (section 4). The known-bad record has a mode and no provenance method. The reply names `"shapes": ["urn:ontara:standin:shapes#RecordModeMethodShape-method"]`, `"nodeShapes": ["urn:ontara:standin:shapes#RecordModeMethodShape"]`, the component `sh:MinCountConstraintComponent`, the shape's `sh:message`, `"rolledBack": true`, `"transaction": "aborted"`, and `"validation": "targeted; ..."` (the store's `X-Ontara-Validation` header). The known-good reply carries `"transaction": "committed"` and its own `validation`. `{{RUN}}` in a fixture becomes a fresh id each time (fix it with `--run ID`). There is no `--graph`: the gate sets the graph (section 4), and a request that names one is refused. Other options: `--update file.rq` (repeatable; SPARQL Update in the same request, naming its graphs only as `{{DBR}}` and `{{DSR}}`, which the gate binds), `--remove IRI` (repeatable; removes that instance's statements from the branch's graphs).

From the host with curl, if present. curl does not replace the `{{RUN}}` token, and `<urn:ontara:standin:cafe#good-{{RUN}}>` is not a valid IRI, so posting a fixture file as it stands returns HTTP 502 with `"outcome": "fault"`, `"stage": "add"` and a parser error (`Invalid IRI code point '{'`), before the store is reached. Substitute the token first:

```bash
sed "s/{{RUN}}/curl-$(date +%s)/g" fixtures/writes/known-good.ttl | \
  curl -s -w '\nHTTP %{http_code}\n' -X POST 'http://127.0.0.1:7220/write' \
  -H 'Content-Type: text/turtle' --data-binary @-
# HTTP 200, "outcome": "committed"

sed "s/{{RUN}}/curl-$(date +%s)/g" fixtures/writes/known-bad.ttl | \
  curl -s -w '\nHTTP %{http_code}\n' -X POST 'http://127.0.0.1:7220/write' \
  -H 'Content-Type: text/turtle' --data-binary @-
# HTTP 422, "outcome": "rejected", the same shapes as above, "rolledBack": true
```

### The gate's API

| Call | Body | Replies |
|---|---|---|
| `POST /write` | JSON `{ "turtle": "...", "updates": ["SPARQL Update", ...], "remove": [IRI, ...] }`, or `text/turtle`. No graph: a `"graph"` field or a `?graph=` is refused | 200 `committed`; 403 `refused` (a write rule of the named-graph scheme: `stage` gate or store, `rules`, `violations`, section 4); 422 `rejected` (SHACL: shapes, node shapes, results, `rolledBack`); 502 `fault` (stage, HTTP status, detail, `rolledBack`); 400 bad request. Every reply carries `validation` (the store's `X-Ontara-Validation` header, or `null`) and `transaction` (`committed`, `aborted` or `unknown`) |
| `GET /health` | | 200 pass, 503 fail, JSON with each check |
| `GET /live` | | 200 (liveness only; used by the container healthcheck) |

A write goes through the gate's evaluation (the write rules), then the Write Stamping Stage (which sets the graph), then to the store as one SPARQL Update request, `INSERT DATA` of the placed triples followed by the updates in order, to the module's endpoint `/cafe-runtime/validated-update` on `store:3030`, with the request's write policy in the header `X-Ontara-Write-Policy` (section 4). The module runs the request in one TDB2 write transaction, applies the write policy to the quads it changed, validates it with jena-shacl, and commits or aborts. It answers 200 on commit, 403 on a write-policy refusal, 422 with the SHACL validation report (N-Triples) on a rejection, 400 if the request does not parse, and 500 on a fault. It has already aborted the transaction in each failing case, so the gate sends no rollback. The gate never fails without an outcome: a report it cannot read, a fault, or a store that does not answer all come back as a `fault` (`bin/gate-check.sh` checks this against a stand-in store; expected last line `GATE CHECK: PASS (7 of 7)`). When the store does not answer, `transaction` is `unknown`, and the gate does not claim a rollback.

**Targeted validation** (ADR-014 §3). The module records the quads a request adds or deletes, and validates the subject and object of each against every shape that targets them. A request containing anything other than `INSERT DATA`, `DELETE DATA` or `DELETE/INSERT ... WHERE` (for example `CLEAR`) is validated whole, and its header says so. Targeted validation is sound only for shapes written under the shape-authoring rule (ADR-014 §4.3).

**Writes that bypass validation.** Fuseki's standard write endpoints on each dataset (`/update`, `/data`, Graph Store Protocol and quads on the dataset itself, RDF Patch) do not validate. Since S0.5 Pass B1 they accept writes only on the store's stack-network listener (`store:3030`), which is not published: the bootstrap loads the knowledge graph and the shapes through it (Graph Store Protocol `PUT`, the one sanctioned unvalidated write), and the capability checks empty their scratch dataset through it (`/update`). On `127.0.0.1:7210`, the published listener, they are read-only, and every write to them is refused (404, 405 or 400 `No operation for request`). Since S0.5 Pass B3 the published listener refuses writes to `validated-update` too (405; its status `GET` stays): a write sent straight to the module would skip the gate's write rules and its Write Stamping Stage. Only the gate's write path writes through `validated-update`. Section 8 has the full table.

The gate does not consult the Access Decision Evaluator; that arrives at S0.7.

## 4. Dataset decision: one runtime dataset

The canonical knowledge graph and the runtime state share **one** TDB2 dataset, `cafe-runtime`, separated by named graphs. The capability scratch dataset, `cafe-capability-scratch`, holds only the capability checks' test data. Both are declared in the store's own configuration (the module starts them; `store/module/src/main/java/dev/ontara/store/OntaraFuseki.java`; section 8), each with its union graph as the default graph. Reasons for one runtime dataset:

1. **Rules and shapes must see both inside one transaction.** A write and its MRB rules run as one SPARQL Update request in one TDB2 write transaction, and that transaction is per dataset. The rules read the tenant's configured model (rule declarations at CML) and the shapes may need class definitions from the knowledge graph. A second dataset would sit outside the transaction.
2. **The union default graph serves validation and reads.** With the union graph as default, the module's validation sees the knowledge graph and runtime state together. Rules name their graphs (section 4, the scheme), and read the knowledge graph through the union or by name.
3. **Separation is still available,** by named graph: replacing the knowledge graph is a per-graph `PUT`.
4. **Pass 1's licence reason has gone.** GraphDB Free capped repositories at five; Fuseki has no such limit. A per-tenant dataset remains possible, so this is a choice, not a constraint.

Consequences for S0.5's named-graph scheme:

1. The data validated is the union graph, so shapes apply to data in every named graph, including the knowledge graph and the shapes graph itself (tested: `capabilities/shacl-capabilities.md` section 4). The scheme cannot exempt the knowledge graph from shapes by placement; shapes must target runtime classes.
2. The module reads shapes only from `https://ontara.dev/graph/shapes`; a shape placed in any other named graph is not enforced (tested, section 4).
3. Knowledge-graph loads go through the unvalidated Graph Store Protocol, so nothing checks a load against the shapes. That is what ADR-014's whole-graph check at every knowledge-graph load covers (S0.5 pass B).

### The named-graph scheme (S0.5 Pass B3; H-0078)

The graph names live in one module, `gate/src/graphs.ts`, read by the gate, its Write Stamping Stage, the rules (through their tokens), the bootstrap, the health check, the load harness, the regression check and the placement queries. No other file spells them.

| Graph | Holds |
|---|---|
| `https://ontara.dev/graph/dhb/{tenant}/{dhbId}/dbr` | A Declared History Branch's business side: canonical runtime instances whose type is a BFO continuant (the order, its lines), and the records of them |
| `https://ontara.dev/graph/dhb/{tenant}/{dhbId}/dsr` | Its system side: instances whose type is a BFO occurrent, and the records of them (nothing at Stage 0) |
| `https://ontara.dev/graph/kg/domain` | The knowledge graph: the 12-file General-only stack, the Cafe's tenant types (with their axis declarations and runtime axis vocabulary) and the Cafe's reasoning module (`fixtures/kg/manifest.json`) |
| `https://ontara.dev/graph/kg/correspondence` | The correspondence records (`ontara-correspondence.ttl`) |
| `https://ontara.dev/graph/kg/metamodel` | Named; empty at Stage 0 |
| `https://ontara.dev/graph/shapes` | The runtime shapes |

**The Reality Reference Branch (RRB).** A Declared History Branch (DHB) is one line of recorded history; the Cafe's one continuous real DHB is its RRB, and at Stage 0 the only DHB. Its identifier, `dhbId`, is a lower-case UUID v4 that the store module generates once, when it creates `cafe-runtime` from empty, and keeps beside it in the data volume (`/fuseki/databases/cafe-runtime.rrb.json`). The module reports it in its status (`rrb`); the gate and the bootstrap read it from there. It is never committed, and nothing is written into the store for it (Pass B writes no declaration record). A store restart keeps it. `docker compose down -v` deletes it with the data: the next start is a new installation with a new identifier. A runtime dataset that exists without the file predates the scheme, and the module refuses to start on it (rebuild from empty).

**The Write Stamping Stage (WSS)** (`gate/src/wss.ts`; ADR-015 §4 item 8) sets the graph of every runtime write, from fixed sources only; a writer never supplies it. The DHB is the one the request's binding instance belongs to: at Stage 0 always the RRB. The side is read from the content: an instance of a canonical runtime type goes to `dbr` if its type is grounded (in `kg/domain`) under BFO continuant and to `dsr` if under BFO occurrent; a stand-in record goes to the side of what its `rec:recordOf` names (ADR-011 §4.3); content with no readable side is refused. The WSS also binds the `{{DBR}}`/`{{DSR}}` tokens by which rules name their graphs (`fixtures/rules/`), and turns a request's `remove` list into one `DELETE/INSERT WHERE` over the branch's two graphs. It is a role separate from the gate's evaluation, in the same service at Stage 0.

**The four write rules.** The gate's evaluation refuses a request that names a graph (rule `graph-from-writer`), and decides the request's write policy: it may change only its DHB's `dbr` and `dsr` graphs. The module applies the policy to the exact quads the request adds or deletes, inside the write transaction and before validation, and aborts with 403 naming the rule: `default-graph` (a quad in the default graph), `knowledge-graph-or-shapes` (a quad in a `kg` graph or the shapes graph, added or deleted), `other-branch` (a quad in another DHB's graph: a request spanning two DHBs), `not-home` (a subject written here that has statements in another DHB's graph), `outside-scheme` (any other graph, for example a retired provisional one) and `operation` (`CLEAR`, `DROP`, `LOAD`, `ADD`, `MOVE`, `COPY`: they act on whole graphs). Writes with no policy header, sent from the stack network only, are not checked: that is how tests seed breaches for the placement queries. A default-graph quad sent that way lands in Jena's stored default graph (`urn:x-arq:DefaultGraph`), which the union default graph excludes, so validation never sees it; the placement queries P2 and P3 report it (scoping suite, case 7.1).

**The placement queries** (`fixtures/placement/`, Cyril's P1 to P3; `node dist/cli/placement.js` in the gate container) take their graph names from `graphs.ts`. Each returns no rows on a sound store.

**What stays outside the scheme.** The capability checks keep their graph, `urn:ontara:stack:graph:capability`, in the scratch dataset `cafe-capability-scratch`, which never holds runtime content (Ella, S525). The S0.1 graphs `health`, `loadtest` and `manual` are retired: their writes go into the RRB like any runtime write, and each removes only its own instances afterwards, by IRI.

## 5. Files

| Path | What it is |
|---|---|
| `compose.yaml` | The stack; the Jena version pin and the validation mode. The bootstrap and the gate mount the repository's `ontology/` and `generated/ontology/` (the knowledge graph) and the Cafe's generated folder, `exercises/coffeeshop-demonstrator/generated/` (as `/stack/tenant-generated/cafe`, for its axis shapes), all read-only: build outputs, never the authoring rig |
| `.env.example` | Optional local overrides (ports, heap); copy to `.env` |
| `.gitignore` | Ignores `.env` |
| `store/Dockerfile` | The store image: builds the module with Maven, refuses Jena below 6.1.0, and fails unless the jar's name and manifest carry `pom.xml`'s version |
| `store/module/` | Ontara's validated-update module for Fuseki, version 0.4.0 (`pom.xml`, `groupId` `dev.ontara`): the server `dev.ontara.store.OntaraFuseki`, and the offline checks `dev.ontara.store.check.NodeTableCheck` and `dev.ontara.store.check.BdfTruncateCheck`. Ported from the OP-134 spike at S521; production configuration since S0.5 Pass B1 (section 8) |
| `bin/common.sh` | Shared by the scripts: the results folder name (`fuseki-<UTC date>`, or `RESULTS_SET`) and the optional `.env` |
| `bin/check-prereqs.sh` | Step 2 |
| `bin/rebuild.sh` | Steps 2 to 5, timed |
| `bin/health.sh` | Step 5 |
| `bin/store-status.sh` | Reads and checks the module's status from the store |
| `bin/capabilities.sh` | Step 6 |
| `bin/loadtest.sh` | Step 7 |
| `bin/regression-check.sh`, `regression/compose.yaml` | Step 8 |
| `bin/scoping-test.sh`, `scoping/compose.yaml` | Step 9: the scoping test suite, in its own Compose project |
| `bin/write.sh` | One write through the gate |
| `bin/gate-check.sh` | Checks the gate's write path against a stand-in store. Needs the gate image (step 3), not a running stack. Expected last line `GATE CHECK: PASS (7 of 7)` |
| `gate/` | The gate, bootstrap, worker, health check, capability checks, load harness and the regression check's driver (TypeScript, Node 22). `gate/src/store/` is the store interface and its one adapter, Fuseki. `package-lock.json` pins every dependency |
| `temporal/scripts/`, `temporal/dynamicconfig/` | Temporal schema setup and namespace scripts, from `temporalio/samples-server` (MIT) |
| `fixtures/shapes/standin-shapes-core-only.ttl` | The stand-in record shape (Hugo, S515). Not canon; S0.6 replaces it |
| `fixtures/shapes/spike-two-sided-readiness.ttl` | Cyril's two-sided core readiness shapes (S519), on the generated axis predicates and values since S0.5 Pass B8. Not canon |
| `../exercises/coffeeshop-demonstrator/generated/axis-shapes.ttl` | The Cafe's axis shapes, generated by `make gen` (`generation/axis_shapes.py`; S0.5 Pass B8): per status axis, exactly one value from the declared set (`sh:in`), and only an instance of the declaring type carries it. Never edited by hand |
| `fixtures/shapes/standin-shapes.ttl` | The S0.1 stand-in shapes with the SPARQL readiness constraint. Used only by the capability checks and `loadtest --shapes standin`; it does not follow the shape-authoring rule and must not be copied (ADR-014 §4.3) |
| `fixtures/writes/order-54.ttl` | The 54-triple order write (order, four lines, five records), axis values in their runtime form; `menuItem` for the line's item (was `order-53.ttl` until S0.5 Pass B8) |
| `fixtures/rules/order-readiness.rq` | The readiness rule, bound to one order by an inline `VALUES` clause; it makes only the permitted move `inPreparation` to `ready` |
| `fixtures/rules/labelling.rq` | The platform labelling step: mode from the inputs, weakest input method |
| `fixtures/writes/known-good.ttl`, `known-bad.ttl` | The health check's and `bin/write.sh`'s stand-in writes |
| `fixtures/kg/manifest.json` | Knowledge-graph files and the `kg` graph (by key) each goes to |
| `fixtures/scoping/` | The scoping suite's shapes (Cyril's F4 to F10, E1 and E4 forms and the F11 blind spot, copied from his S0.5 Pass B step 2 files; a probe shape; an E3 time-only shape; E1 with a sub-select) and its stand-in data. Loaded only into the suite's own store, never into the runtime |
| `gate/src/cli/scoping.ts` | The scoping suite's cases |
| `fixtures/placement/` | The three placement queries (P1 one home graph, P2 runtime instances only in runtime graphs, P3 every graph known), with tokens filled from `gate/src/graphs.ts` |
| `gate/src/graphs.ts` | The named-graph scheme's templates: the one place graph names are spelled |
| `gate/src/wss.ts` | The Write Stamping Stage |
| `fixtures/health/kg-expectations.json` | The health check's knowledge-graph probes |
| `results/` | Results: `fuseki-<date>/` from S521 on (health, capabilities, load tests, regression checks); `loadtest/` and `shacl-*` are the pass 1 GraphDB results of S517, kept as the record of how S0.1 was first proven |

Temporal is in its documented single-machine form, `temporalio/samples-server` `compose/docker-compose-postgres.yml`, without Elasticsearch and without the web UI. One change from upstream: a typo (`MAX_ATTdMPTS`) in the namespace script is corrected. The schema script is unchanged; it is safe to re-run on the persistent volume, because `temporal-sql-tool create` tolerates an existing database and `setup-schema` skips a newer schema (checked at S517).

## 6. Stop, tear down, recovery

```bash
docker compose stop                 # stop, keep containers and data
docker compose down                 # remove containers, keep data volumes
docker compose down -v              # remove containers AND both data volumes (full reset)
docker image rm ontara-cafe-stack/gate:local ontara-cafe-stack/store:local    # also remove the built images
```

After `down -v`, start again at step 4 (step 3 if the images were removed too). `down -v` deletes the Reality Reference Branch's identifier with the data: the store generates a new one, a new installation (section 4).

The regression check keeps each run's TDB2 directory (about 250 MB) in its own volume, `ontara-cafe-regression_store-data`, for diagnosis. To remove them all (this deletes them; there is no undo):

```bash
COMPOSE_FILE=compose.yaml:regression/compose.yaml COMPOSE_PROJECT_NAME=ontara-cafe-regression docker compose down -v
```

**Recovery: the bootstrap fails.** Read `docker compose logs bootstrap`; the banner says which status field is wrong. The mode comes from `compose.yaml` (`x-validation-mode`, `targeted`) and the Jena version from the image's build argument (`x-jena-version`). If the image was built with another version, rebuild it (`docker compose build store`) and start again (`docker compose up -d --wait --force-recreate`). Never edit the bootstrap to accept a store it rejected.

**Recovery: a write fails with a fault naming `NodeTableTRDF/Read`.** That is the signature of a damaged TDB2 node table (apache/jena#3877 on Jena before 6.1.0). Stop writing, keep the volume, run the regression check, and report it.

## 7. Troubleshooting

| Symptom | Cause and fix |
|---|---|
| The store build stops with `Refusing to build` | The Jena version is below 6.1.0 or not N.N.N. Keep `x-jena-version` at the pinned version |
| `bootstrap` exits 2 | Read `docker compose logs bootstrap`; the banner says why (section 6) |
| `port ... in use` in step 2 | Something else holds 7210 or 7220; set `STORE_PORT` / `GATE_PORT` in `.env` |
| Health check fails at Temporal | `docker compose logs worker temporal`; the worker retries its connection for two minutes |
| Health check fails on a knowledge-graph probe | The knowledge graph changed (for example the BMM gained a class): update `fixtures/health/kg-expectations.json` deliberately |
| `bin/loadtest.sh` exits 3 | A write was validated other than targeted, or carried no `X-Ontara-Validation` header: a configuration fault (section 2, step 7) |
| `bin/scoping-test.sh` says a scoping run is already running, or port 7211 is in use | An earlier run did not finish: `COMPOSE_FILE=compose.yaml:scoping/compose.yaml COMPOSE_PROJECT_NAME=ontara-cafe-scoping docker compose down -v` (that project only). Or set `SCOPING_STORE_PORT` |
| `bin/regression-check.sh` says a regression check is already running | An earlier run did not finish; take its project down (section 6) |
| A write from the host to `127.0.0.1:7210/<dataset>/update` or `/data` returns 404, 405 or 400 | By design: the published listener is read-only (section 8). Write through the gate (`bin/write.sh`, `127.0.0.1:7220/write`); maintenance loads run inside the stack's network |
| The store's status reads `validating: false` | Either no shape with a target is loaded in that dataset's shapes graph (normal for `cafe-capability-scratch` between capability runs, and for a new store before the bootstrap), or `validationProbe.passed` is `false`, which means the module's validation code did not reject a known violation: stop and report it |

## 8. The store's configuration

The store is Ontara's validated-update module running Apache Jena Fuseki embedded (`store/module/`, `dev.ontara.store.OntaraFuseki`). This section is its configuration as built since S0.5 Pass B1 (S525).

| Setting | Value | Where it is set |
|---|---|---|
| Module version | **0.4.0** | `store/module/pom.xml` `<version>`, and only there. Maven writes it into the jar's name (`ontara-fuseki-validated-update-0.4.0.jar`) and manifest (`Implementation-Version`); the module's status reads it from the manifest (`module`, `moduleVersion`); the image build fails if name and manifest disagree with `pom.xml`, and the module refuses to start without it |
| Jena (and Fuseki) version | 6.2.0; never below 6.1.0 | `compose.yaml` `x-jena-version`, passed as the image's build argument; the `Dockerfile` refuses below 6.1.0 (section 1) |
| Datasets | `cafe-runtime` (knowledge graph and runtime state; section 4) and `cafe-capability-scratch` (capability checks only). TDB2, each with its union graph as the default graph | Fixed in `OntaraFuseki.java` (`DATASETS`); data in `/fuseki/databases/<dataset>` (`FUSEKI_DATA`), on the volume `ontara-cafe-stack_store-data` |
| Shapes graph | `https://ontara.dev/graph/shapes` (since S0.5 Pass B3), read at the start of each write's transaction; a shape in any other graph is not enforced | `SHAPES_GRAPH` (default in `OntaraFuseki.java`; not set by `compose.yaml`) |
| Validation mode | `targeted` (whole-graph for any request with an operation other than `INSERT DATA`, `DELETE DATA` or `DELETE/INSERT WHERE`; section 3) | `compose.yaml` `x-validation-mode`, as `ONTARA_VALIDATION`; the module's own default is `whole`; any other value stops it |
| Inference | none (OP-134 R4) | No reasoner is configured; the capability checks test it (R4) |
| Listeners | `3030` on the stack network (`FUSEKI_PORT`) and `3031` published (`FUSEKI_PUBLISHED_PORT`), in one JVM over the same datasets | `store/Dockerfile` (`ENV`); `compose.yaml` publishes only `3031`, as `127.0.0.1:${STORE_PORT:-7210}` |

### Which endpoints accept writes, from where

Per dataset (`/cafe-runtime`, `/cafe-capability-scratch`), tested at S525 from the host and from inside the network:

| Endpoint | Validates? | From the host, `127.0.0.1:7210` (listener 3031) | From the stack network, `store:3030` |
|---|---|---|---|
| `POST /<ds>/validated-update` | Yes (SHACL in the write transaction; the request's write policy) | **Refused (405)** since S0.5 Pass B3 | Accepted |
| `GET /<ds>/validated-update` (the status) | n/a | Served | Served |
| `/<ds>/query`, `/<ds>/sparql`, `GET /<ds>?query=` | n/a (read) | Served | Served |
| `GET /<ds>/data`, `/<ds>/get`, `GET /<ds>` | n/a (read) | Served | Served |
| `POST /<ds>/update`, `POST /<ds>` with `update=` | **No** | Refused (404, 400) | Accepted |
| `PUT`, `POST`, `DELETE` on `/<ds>/data?graph=` or `?default` | **No** | Refused (405) | Accepted |
| `PUT`, `POST`, `DELETE` on `/<ds>?graph=`, quads on `/<ds>` | **No** | Refused (405) | Accepted |
| RDF Patch: `PATCH /<ds>`, `POST /<ds>/patch` | **No** | Refused (400, 404) | Accepted |

Users of the stack-network listener's unvalidated writes: the bootstrap (shapes and knowledge-graph load, Graph Store Protocol `PUT`: the one sanctioned unvalidated write, which ADR-014's whole-graph check covers); the capability checks (scratch dataset only); the load harness's shapes replacement (`loadtest --shapes`). The gate's write path uses `validated-update`.

**Why two listeners.** The closure does not depend on where a request comes from: Fuseki's unvalidated write routes do not exist on the published listener, so no source address (and no guess about how Docker Desktop's port forwarding presents the host) is involved. Only `3031` is published. The stack's containers reach `store:3030` by name on the stack network. Alternatives not taken: a source-address filter (depends on Docker's forwarding, which differs between Docker Desktop and Linux); HTTP authentication on the write endpoints (adds a secret to generate, store and rotate); a reverse proxy (another image and configuration to maintain).

**What it does not do.** It stops unvalidated writes reaching the store through the port published on the host. It is not a boundary against the machine's own user: anyone who can run `docker` on the machine can reach `3030` (for example with `docker compose exec`), and on Linux the host can address a container's own IP directly. On a single-user Stage 0 machine those are the same person who can run the bootstrap.

### The module's status

`GET /<dataset>/validated-update` returns one JSON object. Its fields:

| Field | Meaning |
|---|---|
| `module`, `moduleVersion` | `ontara-fuseki-validated-update 0.4.0`, `0.4.0`: from the jar manifest |
| `jenaVersion`, `fusekiVersion` | The Jena version loaded (`org.apache.jena.Jena.VERSION`) |
| `jenaBuildVersion` | The image's build argument (`JENA_VERSION`) |
| `store` | `TDB2` when the dataset is a TDB2 database (measured: `DatabaseMgr.isTDB2`) |
| `unionDefaultGraph` | Read from the dataset's context |
| `validating` | **Measured at each status read.** `true` only when both (1) `validationProbe.passed` and (2) `targetShapes > 0`. So it reads `true` when a write to this dataset would be checked against at least one targeted shape by validation code that has just rejected known violations. It reads `false` on a store with no shapes loaded (a new store before the bootstrap; `cafe-capability-scratch` between capability runs), when the shapes graph does not parse (`shapesError`), or when the probe fails |
| `validationProbe` | The write path's own validation code (`runAndValidate`, which every write runs), in this store's mode, run on a fresh in-memory dataset (never the store) holding one probe shape: a violating `INSERT DATA` (targeted path), a violating `INSERT DATA` followed by `CLEAR` (whole-graph path) and a conforming `INSERT DATA`. `passed` is `true` when both violations are rejected and the conforming case commits. Each case's outcome and `X-Ontara-Validation` text is listed. It takes a few milliseconds |
| `validationMode`, `engine` | The configured mode, and how it validates |
| `shapesGraph`, `shapesTriples`, `targetShapes` | The shapes graph, its triple count, and the number of shapes in it with a target (`-1` if it does not parse) |
| `inference` | `none`: no reasoner is configured |
| `rrb` | The runtime dataset's Reality Reference Branch: `dhbId` and `generatedAt` (section 4); `null` for `cafe-capability-scratch` |
| `listener` | Which listener answered: `published` (port 3031, `standardWriteEndpoints: false`) or `stack-network` (3030, `true`) |

The bootstrap, the health check, `bin/store-status.sh`, the capability checks and the regression check read this status. Before the shapes are loaded they require `validationProbe.passed`; with the shapes loaded they require `validating`.

### Building it

`docker compose build` (step 3), or `bin/rebuild.sh` (steps 2 to 5), builds the module inside the store image from `store/module/` with Maven; nothing is built on the host. To change the module's version, change `pom.xml` `<version>` and rebuild: the jar name, the manifest and the status follow.
