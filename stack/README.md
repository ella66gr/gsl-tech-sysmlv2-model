# Ontara Cafe runtime stack (Plan B Stage 0, S0.1)

This folder is the Cafe's runtime: GraphDB 11.3.1 with SHACL validating in the write transaction, a thin TypeScript constraint gate, and Temporal. It runs in Docker Compose on one machine. This README is the rebuild procedure: follow section 2 from the top on any machine and you reach a passing health check.

The stack depends on nothing on the host except Docker Engine, the Compose plugin, git and a GraphDB Free licence file. It does **not** use the Mac's authoring rig: not the native `ontara` Postgres database, not the resolver, not the vault, not GraphDB Desktop or its `ontara-dev` repository.

Specification: Plan B Stage 0 specification (vault slug `cafe-plan-b-stage-0-specification`) section 2. Built at S517 (pass 1).

## 1. What runs

| Service | Image | Role | Host port |
|---|---|---|---|
| `graphdb` | `ontotext/graphdb:11.3.1` (pinned by digest) | Knowledge graph and runtime state, one repository `cafe-runtime`, SHACL on | `127.0.0.1:7210` |
| `bootstrap` | built here (`ontara-cafe-stack/gate:local`) | One-shot: creates the repository, checks `isShacl`, loads shapes and the knowledge graph, then exits | none |
| `gate` | built here | The constraint gate: `/write`, `/health`, `/live` | `127.0.0.1:7220` |
| `worker` | built here | Temporal worker serving the health check's no-op workflow only | none |
| `temporal` | `temporalio/server:1.32.0` | Temporal server | none (stack network only) |
| `temporal-postgresql` | `postgres:16.10` | Temporal's own store (not the `ontara` database) | none |
| `temporal-schema`, `temporal-namespace` | `temporalio/admin-tools:1.32.0` | One-shot: Temporal schema setup and the `default` namespace | none |

Ports bind to `127.0.0.1` only; nothing is exposed on the network. GraphDB is on 7210, not 7200, so scripts aimed at GraphDB Desktop (7200) can never reach the stack by mistake. Data lives in two named volumes: `ontara-cafe-stack_graphdb-data` and `ontara-cafe-stack_temporal-postgres-data`.

## 2. Rebuild procedure

Run every command from a terminal. Commands after step 1 run inside `stack/`.

### Step 1. Get the repository

```bash
git clone https://github.com/ella66gr/gsl-tech-sysmlv2-model.git gsl-sysml-model
cd gsl-sysml-model/stack
```

On the Mac, where the repository already exists: `cd ~/Developer/gsl-tech/gsl-sysml-model/stack`.

### Step 2. Supply the GraphDB licence (named step)

The GraphDB Free licence for version 11.3 is a file Ontotext issues per copy. It is **never** placed in or copied into this repository; `.gitignore` refuses `*.license`, `*.licence` and `graphdb.license*` anywhere in the tree, and `stack/.env` is ignored too.

1. Put the licence file somewhere outside the repository.
   - Mac: it is already at `~/Library/Application Support/GraphDB/work/graphdb.license`.
   - Ubuntu: for example `mkdir -p ~/graphdb && cp <wherever-you-received-it>/graphdb.license ~/graphdb/`.
   - Read section 8 (licence terms) before installing on a second machine.
2. Create `stack/.env` naming the file by its absolute path:

   ```bash
   # (.env.example documents the optional settings.)
   # Mac:
   printf 'GRAPHDB_LICENSE_FILE="%s"\n' "$HOME/Library/Application Support/GraphDB/work/graphdb.license" > .env
   # Ubuntu (adjust the path):
   printf 'GRAPHDB_LICENSE_FILE="%s"\n' "$HOME/graphdb/graphdb.license" > .env
   ```

The licence is mounted into the GraphDB container read-only as a Compose secret (`/run/secrets/graphdb_license`) and read in place. If `GRAPHDB_LICENSE_FILE` is unset, every `docker compose` command stops with `GRAPHDB_LICENSE_FILE is not set. Follow README step 2.`

### Step 3. Check the prerequisites

```bash
bin/check-prereqs.sh
```

Expected last line: `PREREQUISITES: OK`. It checks Docker Engine (daemon reachable), the Compose plugin, git, that the licence file named in `.env` is readable and outside the repository, and that ports 7210 and 7220 are free. Anything missing prints `MISSING/FAIL` and the script exits 1. Nothing else is assumed present: no Node, Java, Python, curl or make on the host.

On Ubuntu, Docker Engine and the Compose plugin come from Docker's apt repository (`docker-ce`, `docker-compose-plugin`; see docs.docker.com/engine/install/ubuntu). Add your user to the `docker` group, then log out and in, so `docker` runs without `sudo`.

### Step 4. Build the gate image on this machine

```bash
docker compose build
```

This is the only image the stack builds, and it is built here, by this command, on the machine that runs it (S0.1 image rule): the Mac is arm64, the laptop x86_64, and nothing built on one is carried to the other. The other images are pulled, pinned by tag and multi-arch digest. First build takes about 20 s plus downloads.

### Step 5. Start the stack

```bash
docker compose up -d --wait
docker compose logs bootstrap
```

`up --wait` returns when every service is healthy or has completed. It returns non-zero, and the gate does not start, if the bootstrap fails. The bootstrap log must show:

```
[bootstrap] licence: valid=true product=free version=11.3 ...
[bootstrap] created repository cafe-runtime from GraphDB's JSON default config      (first start only)
[bootstrap] read back: isShacl=true validationEnabled=true ruleset=empty enableContextIndex=true ...
[bootstrap] shapes loaded into <http://rdf4j.org/schema/rdf4j#SHACLShapeGraph>: 32 triples (read back via getStatements)
[bootstrap] kg <urn:ontara:stack:kg:...> ... (12 lines)
[bootstrap] OK in ... s
```

If the repository reads back `isShacl` as anything but `true`, or a ruleset other than `empty`, the bootstrap prints a `BOOTSTRAP FAILED` banner and exits 2. Do not continue: see section 6, "Recovery".

**Why `ruleset=empty`.** The runtime repository does no store-side inference (OP-134 requirements paper, R4, S518). Under ADR-013 every triple in the runtime store is written by a declared writer and carries its mode and method. GraphDB's default ruleset, `rdfsplus-optimized`, materialises inferences at ingest, such as an `rdf:type` triple for every superclass of a written instance, and those triples have no writer, mode or method. Derived content is the Substrate Reasoners' to write, as a declared writer. Up to S518 the repository was created with GraphDB's default; a repository's ruleset is fixed when it is created, so a data volume from before S518 must be recreated (section 6, "Recovery", or `docker compose down -v`).

### Step 6. Health check

```bash
bin/health.sh            # add --json for the full result
```

Expected: six `PASS` lines and `HEALTH: PASS`. Exit code 0 on pass, 1 on fail, 2 if the gate is unreachable. The same check is the endpoint `GET http://127.0.0.1:7220/health` (200 pass, 503 fail). It tests each service through the client the Cafe uses (H-0268):

1. GraphDB: SPARQL probes of the knowledge graph return the expected content (`fixtures/health/kg-expectations.json`), and the runtime repository reports `isShacl=true`.
2. The gate, over its HTTP API: a known-good stand-in write commits; a known-bad one comes back as a SHACL rejection naming `sis:RecordModeMethodShape`; a further write commits, showing the repository lock was released.
3. Temporal: a no-op workflow starts and completes.

Steps 3 to 6 can be run, and timed, in one go with `bin/rebuild.sh` (prints `PROCEDURE ELAPSED: N s`).

### Step 7. SHACL capability checks

```bash
bin/capabilities.sh
```

Writes `results/shacl-supported-predicates.json`, `results/shacl-capabilities.json` and `results/shacl-capabilities.md`. It runs in a scratch SHACL repository (`cafe-capability-scratch`), created from the same config as the runtime repository and deleted by the script; the runtime repository is not touched (its ruleset is read, not changed). An unsupported component is a result, not a failure.

Section 5 of the results is the R4 check (no store-side inference): it loads the platform record module, writes an instance of `PlatformRecord` (which has two superclasses there), and confirms that no `rdf:type` triple for a superclass appears and that the triple count grows by exactly the triples written. R4 is a binding requirement, so a failure there makes the script exit 1.

### Step 8. Load test

```bash
bin/loadtest.sh                                   # 500 orders, three paced readers
bin/loadtest.sh --orders 500 --readers continuous --label stress
```

Each run writes `results/loadtest/<UTC time>-<os>-<arch>-<label>/` with `machine.txt` (processors, memory, Docker), `writes.csv` (raw per-write timings), `readers.csv` (raw per-query timings) and `summary.json` (p50, p95, maximum, per-100-write growth, correctness check). Options: `--orders N`, `--readers paced|continuous|none`, `--validation normal|bulk`, `--keep` (do not clear earlier load-test data), `--label NAME`.

The pass figure is p95 at or under 500 ms, measured in the clean-machine Ubuntu virtual machine (specification 2.5 item 8.4). **Runs on the Mac are development runs and do not count.**

To bring results back from the laptop: commit the new `results/loadtest/...` folder, or copy it.

## 3. Sending a write through the gate

From `stack/`:

```bash
bin/write.sh fixtures/writes/known-good.ttl     # exit 0, "outcome": "committed", HTTP 200
bin/write.sh fixtures/writes/known-bad.ttl      # exit 1, "outcome": "rejected", HTTP 422
```

The known-bad write is a record with a mode and no provenance method. The reply names `"shapes": ["urn:ontara:standin:shapes#RecordModeMethodShape-method"]`, `"nodeShapes": ["urn:ontara:standin:shapes#RecordModeMethodShape"]`, the component `sh:MinCountConstraintComponent`, the shape's `sh:message`, and `"rolledBack": true`. `{{RUN}}` in a fixture becomes a fresh id each time (fix it with `--run ID`). Other options: `--graph IRI` (default `urn:ontara:stack:graph:manual`), `--bulk`, `--update file.rq` (repeatable; SPARQL Update in the same transaction).

From the host with curl, if present. curl does not replace the `{{RUN}}` token, and `<urn:ontara:standin:cafe#good-{{RUN}}>` is not a valid IRI, so posting a fixture file as it stands returns HTTP 502 with `"outcome": "fault"`, `"stage": "add"`, `"detail": "Transaction handling error: Invalid IRI value"` and `"rolledBack": true`. Substitute the token first:

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
| `POST /write` | JSON `{ "graph": IRI, "turtle": "...", "updates": ["SPARQL Update", ...], "validation": "normal" or "bulk" }`, or `text/turtle` with `?graph=` | 200 `committed`; 422 `rejected` (SHACL: shapes, node shapes, results, `rolledBack`); 502 `fault` (stage, HTTP status, detail, `rolledBack`); 400 bad request |
| `GET /health` | | 200 pass, 503 fail, JSON with each check |
| `GET /live` | | 200 (liveness only; used by the container healthcheck) |

A write opens an RDF4J transaction, adds the triples to the named graph, runs the updates in order, and commits. GraphDB answers both a SHACL rejection and a server fault with HTTP 500; the gate tells them apart by the reply's media type (`application/shacl-validation-report+n-quads`), falling back to the report body. After any failure once the transaction is open it rolls back explicitly (`DELETE` on the transaction), because a rejected commit can leave the repository lock held. `validation: "bulk"` sends RDF4J's Bulk setting under its full name, `transaction-setting__org.eclipse.rdf4j.sail.shacl.ShaclSail.TransactionSettings.ValidationApproach=Bulk`; the short form is silently ignored. The gate does not consult the Access Decision Evaluator; that arrives at S0.7.

## 4. Repository decision: one repository

The canonical knowledge graph and the runtime state share **one** repository, `cafe-runtime`, separated by named graphs. Reasons:

1. **Rules and shapes must see both in one transaction.** MRB mapping rules run as SPARQL Update inside the write transaction and read the tenant's configured model (rule declarations at CML); shapes may need class definitions from the knowledge graph. GraphDB transactions do not span repositories, and a federated read from a second repository would sit outside the transaction.
2. **The Free licence caps repositories at five.** One repository per tenant fits v1's five demonstrator tenants (Cafe, Paws, Suds, Ears, Minds). Two per tenant would not.
3. **A second repository buys no throughput.** The Free licence runs on one CPU core, and queries ran one at a time on it at S515, whichever repository they hit.
4. **Separation is still available,** by named graph: replacing the knowledge graph is a per-graph `PUT`, and the context index is switched on (`enableContextIndex=true`) for graph-scoped queries.

Consequences for S0.5's named-graph scheme: SHACL shapes apply to data in every named graph (tested, `results/shacl-capabilities.md` section 4), so the scheme cannot exempt the knowledge graph from shapes by placement. Shapes must target runtime classes. The shapes graph itself is invisible to SPARQL in GraphDB and is read through the statements API.

Graph IRIs used now, all provisional until S0.5:

| Graph | Holds |
|---|---|
| `urn:ontara:stack:kg:<module>` | one per knowledge-graph file (`fixtures/kg/manifest.json`: the 12-file General-only stack) |
| `http://rdf4j.org/schema/rdf4j#SHACLShapeGraph` | the stand-in shapes |
| `urn:ontara:stack:graph:loadtest` | load-harness orders (cleared at the start of each run) |
| `urn:ontara:stack:graph:health` | health-check writes (cleared after each check) |
| `urn:ontara:stack:graph:manual` | `bin/write.sh` writes |

## 5. Files

| Path | What it is |
|---|---|
| `compose.yaml` | The stack |
| `.env.example` | Template for `.env` (licence path, optional ports and heap) |
| `.gitignore` | Ignores `.env` and any licence file |
| `bin/check-prereqs.sh` | Step 3 |
| `bin/rebuild.sh` | Steps 3 to 6, timed |
| `bin/health.sh` | Step 6 |
| `bin/capabilities.sh` | Step 7 |
| `bin/loadtest.sh` | Step 8 |
| `bin/write.sh` | One write through the gate |
| `gate/` | The gate, bootstrap, worker, health check, capability checks and load harness (TypeScript, Node 22). `package-lock.json` pins every dependency |
| `graphdb/tools/SupportedShaclPredicates.java` | Calls `ShaclSail.getSupportedShaclPredicates()` with the GraphDB image's own jars |
| `temporal/scripts/`, `temporal/dynamicconfig/` | Temporal schema setup and namespace scripts, from `temporalio/samples-server` (MIT) |
| `fixtures/shapes/standin-shapes.ttl` | Stand-in shapes (Hugo, S515): the record mode-and-method core shape and the order-readiness SPARQL constraint. Not canon; S0.6 replaces them |
| `fixtures/writes/order-53.ttl` | The 53-triple order write (order, four lines, five records) |
| `fixtures/rules/order-readiness.rq` | The readiness rule, bound to one order by an inline `VALUES` clause |
| `fixtures/rules/labelling.rq` | The platform labelling step: mode from the inputs, weakest input method |
| `fixtures/writes/known-good.ttl`, `known-bad.ttl` | The health check's and `bin/write.sh`'s stand-in writes |
| `fixtures/kg/manifest.json` | Knowledge-graph files and their graphs |
| `fixtures/health/kg-expectations.json` | The health check's knowledge-graph probes |
| `results/` | Capability results and load-test runs |

Temporal is in its documented single-machine form, `temporalio/samples-server` `compose/docker-compose-postgres.yml`, without Elasticsearch and without the web UI. One change from upstream: a typo (`MAX_ATTdMPTS`) in the namespace script is corrected. The schema script is unchanged; it is safe to re-run on the persistent volume, because `temporal-sql-tool create` tolerates an existing database and `setup-schema` skips a newer schema (checked at S517).

## 6. Stop, tear down, recovery

```bash
docker compose stop                 # stop, keep containers and data
docker compose down                 # remove containers, keep data volumes
docker compose down -v              # remove containers AND both data volumes (full reset)
docker image rm ontara-cafe-stack/gate:local    # also remove the built image
```

After `down -v`, start again at step 4. GraphDB Desktop and the stack must not run at the same time (specification 2.4): stop the stack before starting Desktop.

**Recovery: `isShacl` reads false, or the ruleset is not `empty`.** Neither SHACL nor the ruleset can be changed after a repository is created. Delete the repository and let the bootstrap recreate it from the JSON config:

```bash
docker compose exec graphdb curl -s -X DELETE http://localhost:7200/rest/repositories/cafe-runtime
docker compose up -d --wait --force-recreate bootstrap gate worker
```

**Recovery: a write hangs after a rejection.** The gate always rolls back, so this should not occur. If it does, restart GraphDB (`docker compose restart graphdb`) and report it: it means a transaction was left open.

## 7. Troubleshooting

| Symptom | Cause and fix |
|---|---|
| `GRAPHDB_LICENSE_FILE is not set` | Step 2 not done, or `.env` is not in `stack/` |
| GraphDB unhealthy; `docker compose logs graphdb` shows `No license was set` or every call returns 500 | Licence file not found or not valid for 11.3; check the path in `.env` |
| `bootstrap` exits 2 | Read `docker compose logs bootstrap`; the banner says why |
| `port ... in use` in step 3 | Something else holds 7210 or 7220; set `GRAPHDB_PORT` / `GATE_PORT` in `.env` |
| Health check fails at Temporal | `docker compose logs worker temporal`; the worker retries its connection for two minutes |
| A shape loads but is not enforced | Some SHACL features are dropped without an error reply: see `results/shacl-capabilities.md` |

## 8. GraphDB Free licence terms that bear on this stack

From Ontotext's End-User License Agreement as shipped in this image (`/opt/graphdb/dist/doc/ONTOTEXT_LICENSE_AGREEMENT.txt`) and published at https://graphdb.ontotext.com/LICENSE-GraphDB.txt. This is a reading of the text, not legal advice.

1. Article 1.7: "You may not re-license, reproduce or distribute any License Key except with the express written permission of Licensor."
2. Article 7.1: Ontotext "will send an email with a License Key file for each copy of the Licensed Software."
3. Article 2.2: copies of the software are allowed "for back-up and archival purposes only."
4. Article 3.3: GraphDB Free is "only for non-production purposes (development, staging, testing). Any production usage of GraphDB Free is explicitly prohibited."

So a second installation, such as the Linux laptop, should run on its own licence key from Ontotext, or on Ontotext's written permission to reuse this one, not on a copy of the Mac's file.
