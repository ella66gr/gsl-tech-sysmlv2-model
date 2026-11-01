# OP-136 spike — status axes through OpenSysML (S519)

Branch `spike/op-136-opensysml`; never merged. Report:
`session-519-op-136-step1-hugo.md` in the vault's Sessions 511-520 folder.

| File | What it is |
|---|---|
| `opensysml_axes.py` | The reader: status axes from OpenSysML's resolved model, returned as `generation.status_axes` objects, checked by the same rules |
| `compare.py` | Runs `generation/status_axes.py` and the reader on one model folder; writes `results/<label>.text.json`, `.opensysml.json`, `.diff.txt` |
| `sample_type.py` | What the resolved model exposes for one type (documentation, specialisations, features, the package's annotations) |
| `fixtures/inherit/inherit.sysml` | Types that inherit axes through `:>`, and one that redefines an axis to add a move |
| `results/` | The kept comparison output, the Order sample and the Mermaid tree render |

## Environment (nothing global)

The OpenSysML Python client 0.11.0 in a venv, and the v0.11.0 `sysml-grpc`
release binary, named by `OPENSYSML_BINARY` so the client never downloads into
`~/.opensysml/`. `OPENSYSML_RECORD_CACHE=0` keeps the run off the shared record
cache, as `make parse-check`'s `-no-record-cache` does.

```sh
VENV=/path/to/scratch/venv            # any empty folder
DL=/path/to/scratch/dl-grpc           # its own empty folder
python3 -m venv "$VENV"
mkdir -p "$DL" && gh release download v0.11.0 -R Open-MBEE/OpenSysML -D "$DL" \
  -p sysml-grpc-darwin-arm64 -p opensysml-0.11.0-py3-none-any.whl -p SHA256SUMS.txt
(cd "$DL" && grep -E 'sysml-grpc-darwin-arm64$|opensysml-0.11.0-py3-none-any.whl' SHA256SUMS.txt | shasum -a 256 -c)
chmod +x "$DL/sysml-grpc-darwin-arm64"
"$VENV/bin/python" -m pip install "$DL/opensysml-0.11.0-py3-none-any.whl"
export OPENSYSML_BINARY="$DL/sysml-grpc-darwin-arm64" OPENSYSML_RECORD_CACHE=0
```

## Rerun (from the repository root)

```sh
"$VENV/bin/python" -I spikes/op-136-opensysml/compare.py cafe    exercises/coffeeshop-demonstrator/model
"$VENV/bin/python" -I spikes/op-136-opensysml/compare.py paws    exercises/paws-demonstrator/model
"$VENV/bin/python" -I spikes/op-136-opensysml/compare.py inherit spikes/op-136-opensysml/fixtures/inherit
```

Expected: `cafe: DIFFERENT` (one difference, the `item` ref; see the report),
`paws: IDENTICAL`, `inherit: DIFFERENT` (the reader adds UrgentTicket,
EscalatedTicket and ReopenableTicket; Desk and Ticket are identical). Exit
status is 1 for DIFFERENT. The JSON files are deterministic; only the timing
line at the end of each `.diff.txt` changes between runs. Use `--out DIR` to
write somewhere other than `results/`.
