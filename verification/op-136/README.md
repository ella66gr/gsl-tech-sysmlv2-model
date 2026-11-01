# OP-136 — Code's verification (brief §7)

Run by Claude Code on 2026-11-01, separately from the specialists' reports.

1. Spike reader (`compare.py`) rerun on Cafe, Paws and the inheritance fixture into this folder. Verdicts: cafe DIFFERENT (only the `item` ref), paws IDENTICAL, inherit DIFFERENT (text reader 2 types, OpenSysML 5). All six JSON outputs are byte-identical to `spikes/op-136-opensysml/results/`.
2. Cyril's worked example: `sysml -satisfy` on the Cafe as it stands gives `violated`, exit 1 (`cyril-satisfy-cafe.txt`). The seven-case runner (`cyril-acceptance/summary.txt`) matches Cyril's recorded summary once test timings are stripped.
3. 0.12.0 flag finding re-checked: PR #1754 (merged 2026-11-01, head aeaf962) removes only `-to` and `-pdf-*` (`pr1754.diff`). `cmd/sysml/usage.go` at `develop` 92a93e9 still declares `version`, `validate`, `no-record-cache` and `json` (`develop-cmd-sysml-usage.go`, lines 783/795/801/814).
4. main/origin main untouched, sysml v0.11.0, no servers or containers left running: see the commit message.
