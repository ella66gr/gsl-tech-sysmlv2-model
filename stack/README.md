# Ontara Cafe runtime stack (Plan B Stage 0, S0.1)

This folder is the Cafe's runtime: Apache Jena Fuseki on Jena 6.2.0 with Ontara's validated-update module, which validates every write with SHACL inside its write transaction; a thin TypeScript constraint gate; and Temporal. It runs in Docker Compose on one machine. This README is the rebuild procedure: follow section 2 from the top on any machine and you reach a passing health check.

The stack depends on nothing on the host except Docker Engine, the Compose plugin and git. It needs no licence. It does **not** use the Mac's authoring rig: not the native `ontara` Postgres database, not the resolver, not the vault, not GraphDB Desktop or its `ontara-dev` repository. GraphDB Desktop may run beside it; they share no port.

Specification: Plan B Stage 0 specification (vault slug `cafe-plan-b-stage-0-specification`) section 2. The runtime store decision: ADR-014 (vault slug `ontara-adr-014-runtime-triple-store`). Built on GraphDB at S517 (pass 1); moved to Fuseki at S521 (pass 3).

## 1. What runs

| Service | Image | Role | Host port |
|---|---|---|---|
| `store` | built here (`ontara-cafe-stack/store:local`, `store/`) | Apache Jena Fuseki 6.2.0, TDB2, with the validated-update module in targeted mode. Two datasets: `cafe-runtime` (knowledge graph and runtime state) and `cafe-capability-scratch` | `127.0.0.1:7210` |
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
[bootstrap] status /cafe-runtime: module="ontara-fuseki-validated-update 0.2.0" validating=true mode=targeted jena=6.2.0 (built for 6.2.0) store=TDB2 unionDefaultGraph=true inference=none ...
[bootstrap] status /cafe-capability-scratch: ... validating=true mode=targeted jena=6.2.0 ...
[bootstrap] shapes loaded into <urn:ontara:stack:shapes>: 84 triples from shapes/standin-shapes-core-only.ttl + shapes/spike-two-sided-readiness.ttl (read back by SPARQL)
[bootstrap] kg <urn:ontara:stack:kg:...> ... (12 lines)
[bootstrap] status /cafe-runtime: ... shapesTriples=84
[bootstrap] OK in ... s: validating, targeted mode, Jena 6.2.0, 84 shapes triples
```

The bootstrap reads the module's status (`GET /<dataset>/validated-update`) on both datasets before it writes anything, and again after loading. Unless the status reads validating on, targeted mode, Jena 6.2.0 (both the version loaded and the image's build argument), TDB2 with the union graph as default graph, no inference and, after loading, the shapes in place, it prints a `BOOTSTRAP FAILED` banner and exits 2. Do not continue: never use the store unvalidated (section 6, "Recovery").

### Step 5. Health check

```bash
bin/health.sh --record       # add --json for the full result
```

Expected: six `PASS` lines and `HEALTH: PASS`. Exit code 0 on pass, 1 on fail, 2 if the gate is unreachable. `--record` also writes the full result to `results/fuseki-<UTC date>/health/<time>-health.json`. The same check is the endpoint `GET http://127.0.0.1:7220/health` (200 pass, 503 fail). It tests each service through the client the Cafe uses (H-0268):

1. The store: SPARQL probes of the knowledge graph return the expected content (`fixtures/health/kg-expectations.json`), and the module's status reads validating on, targeted mode, Jena 6.2.0 and shapes loaded.
2. The gate, over its HTTP API: a known-good stand-in write commits; a known-bad one comes back as a SHACL rejection naming `sis:RecordModeMethodShape`; a further write commits, and the rejected record is not stored, which shows the rejected write left nothing behind. Each write must carry an `X-Ontara-Validation` header naming targeted mode.
3. Temporal: a no-op workflow starts and completes.

Steps 2 to 5 can be run, and timed, in one go with `bin/rebuild.sh` (prints `PROCEDURE ELAPSED: N s`).

To read the store's status yourself: `bin/store-status.sh` (expected last line `STORE STATUS: OK`; `--line` for one line), or from the host, if curl is present, `curl -s http://127.0.0.1:7210/cafe-runtime/validated-update`.

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

Each write is the 53-triple order with the readiness rule and the labelling step in the same request. The shapes are the runtime set the bootstrap loads: the stand-in record shape and Cyril's two-sided core readiness shapes (not the S0.1 stand-in SPARQL constraint, which targeted validation misses in its line-only case; ADR-014 §4.3). Each run writes `results/fuseki-<UTC date>/loadtest/<UTC time>-<os>-<arch>-<label>/` with:

1. `machine.txt`: the machine (model, processors, memory, Docker), the store image, and the store as its module reports it (product, Jena version, validation mode);
2. `writes.csv`: raw per-write timings, one row per write, with each write's `X-Ontara-Validation` header in the `validation` column (the latency is `latency_ms`, the HTTP round trip to the gate);
3. `readers.csv`: raw per-query reader timings;
4. `summary.json`: p50, p95 and maximum, per-100-write growth, the correctness check, the store, and the count of writes by validation mode.

A write validated in any mode but targeted, or with no `X-Ontara-Validation` header, is a configuration fault: the summary says `validAsMeasure: false` and the script exits 3. Fix the configuration and run again. Options: `--orders N`, `--readers paced|continuous|none`, `--shapes runtime|standin|core-only`, `--reject-every K` (a known-bad write before every Kth order), `--writers N`, `--keep` (do not clear earlier load-test data), `--label NAME`.

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

Options: `--mode whole|targeted`, `--preload N`, `--good N` (at least 50), `--bad K`, `--label NAME`. A positive control, to show the check fails on a defective store, names another image: `bin/regression-check.sh --image <image> --expect-jena <version> --label positive-control`. Never point the runtime stack at such an image.

## 3. Sending a write through the gate

From `stack/`:

```bash
bin/write.sh fixtures/writes/known-good.ttl     # exit 0, "outcome": "committed", HTTP 200
bin/write.sh fixtures/writes/known-bad.ttl      # exit 1, "outcome": "rejected", HTTP 422
```

The known-bad write is a record with a mode and no provenance method. The reply names `"shapes": ["urn:ontara:standin:shapes#RecordModeMethodShape-method"]`, `"nodeShapes": ["urn:ontara:standin:shapes#RecordModeMethodShape"]`, the component `sh:MinCountConstraintComponent`, the shape's `sh:message`, `"rolledBack": true`, `"transaction": "aborted"`, and `"validation": "targeted; changes=2 touched=3 focus=1"` (the store's `X-Ontara-Validation` header). The known-good reply carries `"transaction": "committed"` and its own `validation`. `{{RUN}}` in a fixture becomes a fresh id each time (fix it with `--run ID`). Other options: `--graph IRI` (default `urn:ontara:stack:graph:manual`), `--update file.rq` (repeatable; SPARQL Update in the same request).

From the host with curl, if present. curl does not replace the `{{RUN}}` token, and `<urn:ontara:standin:cafe#good-{{RUN}}>` is not a valid IRI, so posting a fixture file as it stands returns HTTP 502 with `"outcome": "fault"`, `"stage": "add"` and a parser error (`Invalid IRI code point '{'`), before the store is reached. Substitute the token first:

```bash
sed "s/{{RUN}}/curl-$(date +%s)/g" fixtures/writes/known-good.ttl | \
  curl -s -w '\nHTTP %{http_code}\n' -X POST 'http://127.0.0.1:7220/write?graph=urn:ontara:stack:graph:manual' \
  -H 'Content-Type: text/turtle' --data-binary @-
# HTTP 200, "outcome": "committed"

sed "s/{{RUN}}/curl-$(date +%s)/g" fixtures/writes/known-bad.ttl | \
  curl -s -w '\nHTTP %{http_code}\n' -X POST 'http://127.0.0.1:7220/write?graph=urn:ontara:stack:graph:manual' \
  -H 'Content-Type: text/turtle' --data-binary @-
# HTTP 422, "outcome": "rejected", the same shapes as above, "rolledBack": true
```

### The gate's API

| Call | Body | Replies |
|---|---|---|
| `POST /write` | JSON `{ "graph": IRI, "turtle": "...", "updates": ["SPARQL Update", ...] }`, or `text/turtle` with `?graph=` | 200 `committed`; 422 `rejected` (SHACL: shapes, node shapes, results, `rolledBack`); 502 `fault` (stage, HTTP status, detail, `rolledBack`); 400 bad request. Every reply carries `validation` (the store's `X-Ontara-Validation` header, or `null`) and `transaction` (`committed`, `aborted` or `unknown`) |
| `GET /health` | | 200 pass, 503 fail, JSON with each check |
| `GET /live` | | 200 (liveness only; used by the container healthcheck) |

A write goes to the store as one SPARQL Update request, `INSERT DATA` of the triples into the named graph followed by the updates in order, to the module's endpoint `/cafe-runtime/validated-update`. The module runs the request in one TDB2 write transaction, validates it with jena-shacl, and commits or aborts. It answers 200 on commit, 422 with the SHACL validation report (N-Triples) on a rejection, 400 if the request does not parse, and 500 on a fault. It has already aborted the transaction in each failing case, so the gate sends no rollback. The gate never fails without an outcome: a report it cannot read, a fault, or a store that does not answer all come back as a `fault` (`bin/gate-check.sh` checks this against a stand-in store; expected last line `GATE CHECK: PASS (7 of 7)`). When the store does not answer, `transaction` is `unknown`, and the gate does not claim a rollback.

**Targeted validation** (ADR-014 §3). The module records the quads a request adds or deletes, and validates the subject and object of each against every shape that targets them. A request containing anything other than `INSERT DATA`, `DELETE DATA` or `DELETE/INSERT ... WHERE` (for example `CLEAR`) is validated whole, and its header says so. Targeted validation is sound only for shapes written under the shape-authoring rule (ADR-014 §4.3).

**Writes that bypass validation.** Fuseki's standard endpoints on each dataset (`/query`, `/update`, `/data`) do not validate. The bootstrap loads the knowledge graph and the shapes through `/data` (Graph Store Protocol), and the capability checks empty their scratch dataset through `/update`. Only the gate's write path uses `validated-update`. Both are reachable on `127.0.0.1:7210`. S0.5 builds the store's production configuration.

The gate does not consult the Access Decision Evaluator; that arrives at S0.7.

## 4. Dataset decision: one runtime dataset

The canonical knowledge graph and the runtime state share **one** TDB2 dataset, `cafe-runtime`, separated by named graphs. The capability scratch dataset, `cafe-capability-scratch`, holds only the capability checks' test data. Both are declared in the store's own configuration (the module starts them; `store/module/src/main/java/dev/ontara/spike/OntaraFuseki.java`), each with its union graph as the default graph. Reasons for one runtime dataset:

1. **Rules and shapes must see both inside one transaction.** A write and its MRB rules run as one SPARQL Update request in one TDB2 write transaction, and that transaction is per dataset. The rules read the tenant's configured model (rule declarations at CML) and the shapes may need class definitions from the knowledge graph. A second dataset would sit outside the transaction.
2. **The union default graph makes this plain SPARQL.** With the union graph as default, a rule's `WHERE` clause and the module's validation see the knowledge graph and runtime state together, with no `GRAPH` clause or dataset name in the rule.
3. **Separation is still available,** by named graph: replacing the knowledge graph is a per-graph `PUT`.
4. **Pass 1's licence reason has gone.** GraphDB Free capped repositories at five; Fuseki has no such limit. A per-tenant dataset remains possible, so this is a choice, not a constraint.

Consequences for S0.5's named-graph scheme:

1. The data validated is the union graph, so shapes apply to data in every named graph, including the knowledge graph and the shapes graph itself (tested: `capabilities/shacl-capabilities.md` section 4). The scheme cannot exempt the knowledge graph from shapes by placement; shapes must target runtime classes.
2. The module reads shapes only from `urn:ontara:stack:shapes`; a shape placed in any other named graph is not enforced (tested, section 4).
3. Knowledge-graph loads go through the unvalidated Graph Store Protocol, so nothing checks a load against the shapes. That is what ADR-014's whole-graph check at every knowledge-graph load covers (S0.5 pass B).

Graph IRIs used now, all provisional until S0.5:

| Graph | Holds |
|---|---|
| `urn:ontara:stack:kg:<module>` | one per knowledge-graph file (`fixtures/kg/manifest.json`: the 12-file General-only stack) |
| `urn:ontara:stack:shapes` | the runtime shapes (`standin-shapes-core-only.ttl` and `spike-two-sided-readiness.ttl`) |
| `urn:ontara:stack:graph:loadtest` | load-harness orders (cleared at the start of each run) |
| `urn:ontara:stack:graph:health` | health-check writes (cleared after each check) |
| `urn:ontara:stack:graph:manual` | `bin/write.sh` writes |

## 5. Files

| Path | What it is |
|---|---|
| `compose.yaml` | The stack; the Jena version pin and the validation mode |
| `.env.example` | Optional local overrides (ports, heap); copy to `.env` |
| `.gitignore` | Ignores `.env` |
| `store/Dockerfile` | The store image: builds the module with Maven, refuses Jena below 6.1.0 |
| `store/module/` | Ontara's validated-update module for Fuseki (`OntaraFuseki.java`), and the offline checks `NodeTableCheck.java` and `BdfTruncateCheck.java`. Ported unchanged from the OP-134 spike at S521; S0.5 builds its production configuration |
| `bin/common.sh` | Shared by the scripts: the results folder name (`fuseki-<UTC date>`, or `RESULTS_SET`) and the optional `.env` |
| `bin/check-prereqs.sh` | Step 2 |
| `bin/rebuild.sh` | Steps 2 to 5, timed |
| `bin/health.sh` | Step 5 |
| `bin/store-status.sh` | Reads and checks the module's status from the store |
| `bin/capabilities.sh` | Step 6 |
| `bin/loadtest.sh` | Step 7 |
| `bin/regression-check.sh`, `regression/compose.yaml` | Step 8 |
| `bin/write.sh` | One write through the gate |
| `bin/gate-check.sh` | Checks the gate's write path against a stand-in store. Needs the gate image (step 3), not a running stack. Expected last line `GATE CHECK: PASS (7 of 7)` |
| `gate/` | The gate, bootstrap, worker, health check, capability checks, load harness and the regression check's driver (TypeScript, Node 22). `gate/src/store/` is the store interface and its one adapter, Fuseki. `package-lock.json` pins every dependency |
| `temporal/scripts/`, `temporal/dynamicconfig/` | Temporal schema setup and namespace scripts, from `temporalio/samples-server` (MIT) |
| `fixtures/shapes/standin-shapes-core-only.ttl` | The stand-in record shape (Hugo, S515). Not canon; S0.6 replaces it |
| `fixtures/shapes/spike-two-sided-readiness.ttl` | Cyril's two-sided core readiness shapes (S519), in the stand-in vocabulary. Not canon |
| `fixtures/shapes/standin-shapes.ttl` | The S0.1 stand-in shapes with the SPARQL readiness constraint. Used only by the capability checks and `loadtest --shapes standin`; it does not follow the shape-authoring rule and must not be copied (ADR-014 §4.3) |
| `fixtures/writes/order-53.ttl` | The 53-triple order write (order, four lines, five records) |
| `fixtures/rules/order-readiness.rq` | The readiness rule, bound to one order by an inline `VALUES` clause |
| `fixtures/rules/labelling.rq` | The platform labelling step: mode from the inputs, weakest input method |
| `fixtures/writes/known-good.ttl`, `known-bad.ttl` | The health check's and `bin/write.sh`'s stand-in writes |
| `fixtures/kg/manifest.json` | Knowledge-graph files and their graphs |
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

After `down -v`, start again at step 4 (step 3 if the images were removed too).

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
| `bin/regression-check.sh` says a regression check is already running | An earlier run did not finish; take its project down (section 6) |
