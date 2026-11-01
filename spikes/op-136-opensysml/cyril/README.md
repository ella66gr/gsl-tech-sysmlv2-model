# OP-136 Step 2 (Cyril): the semantic side

Branch `spike/op-136-opensysml`; never merged. Report:
`session-519-op-136-step2-cyril.md` in the vault's Sessions 511-520 folder.
Environment: as `../README.md` ("Environment"), plus `rdflib==7.6.0` and
`pyyaml==6.0.3` in the same venv (the pipeline imports both). Nothing writes
outside `results/` or the scratch folder you name; nothing touches
`generated/`.

| File | Item | What it is |
|---|---|---|
| `owl_reads.py` | (a) | Rebuilds the OWL pipeline's input elements from the resolved model and runs `gen_owl_pipeline` stages 2-3 on both routes; compares the graphs with each other and with the committed `generated/ontology/` files |
| `owl_faults.py` | (a) | Four model edits (three layout-only) on scratch copies, through both routes |
| `acceptance/cafe-s04-acceptance.sysml` | (d) | The worked acceptance: `PreparationAwaitsPayment`, written from the Stage 0 specification |
| `acceptance/run_acceptance.py` | (d) | The acceptance and the committed E6 test, side by side, on seven cases |
| `rdf_crosscheck.py` | (f) | `sysml -convert ttl` on BMM General; SPARQL CONSTRUCT rebuilds the canonical-runtime family's OWL slice; compared with the committed OWL |
| `results/` | | The kept output of each |

## Rerun (from the repository root)

```sh
S=/path/to/scratch                     # Hugo's scratch folder, with venv/ and dl-grpc/
export OPENSYSML_BINARY=$S/dl-grpc/sysml-grpc-darwin-arm64 OPENSYSML_RECORD_CACHE=0

# (a) expected: VERDICT: ALL ISOMORPHIC, exit 0 (about 12 s)
$S/venv/bin/python -I spikes/op-136-opensysml/cyril/owl_reads.py --out $S/check/owl-reads
# (a) expected: the four sections of results/owl-faults/summary.txt (about 60 s)
$S/venv/bin/python -I spikes/op-136-opensysml/cyril/owl_faults.py $S/check/faults --out $S/check/owl-faults

# (d) the worked example on the Cafe model as it is. Expected: "fails",
#     "Required condition evaluated to false: exists(body)", exit 1
sysml -no-record-cache model libraries exercises/coffeeshop-demonstrator/model \
  spikes/op-136-opensysml/cyril/acceptance/cafe-s04-acceptance.sysml -satisfy
# (d) all seven cases with the E6 test; expected: the table in results/acceptance/summary.txt
python3 spikes/op-136-opensysml/cyril/acceptance/run_acceptance.py $S/check/acc --out $S/check/acceptance

# (f) expected: ISOMORPHIC (95 triples each), exit 0 (about 90 s)
VENV_PYTHON=$S/venv/bin/python python3 spikes/op-136-opensysml/cyril/rdf_crosscheck.py $S/check/rdf --out $S/check/rdf-export
```

`sysml` is the pinned brew v0.11.0. The JSON and Turtle outputs are
deterministic; only timing lines change between runs.
