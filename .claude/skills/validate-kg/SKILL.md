---
name: validate-kg
description: Validate the knowledge graph against the SPARQL test suite
allowed-tools: Bash
---

# Validate Knowledge Graph

Run the KG validation suite against GraphDB.

## Steps

1. From the repo root:
   ```
   python3 scripts/validate_kg.py
   ```

2. Report the validation summary.

If `$ARGUMENTS` is "load" or "reload", run with `--load`:
```
python3 scripts/validate_kg.py --load
```
