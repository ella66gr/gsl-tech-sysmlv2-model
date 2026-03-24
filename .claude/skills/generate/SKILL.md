---
name: generate
description: Regenerate model introspection JSON from SysML and sync to console
allowed-tools: Bash
---

# Regenerate Model Introspection

Run the model introspection generator and sync the output to the console's static data directory.

## Steps

1. From the repo root, run the introspection generator:
   ```
   python3 scripts/gen_model_introspection.py --save --pretty
   ```

2. Sync the generated JSON to the console:
   ```
   cp generated/ontara/model-introspection.json console/static/data/model-introspection.json
   ```

3. Report what changed: count of part defs, part usages, metadata annotations extracted.

If `$ARGUMENTS` is "all", also run:
```
python3 scripts/gen_concept_graph.py
python3 scripts/gen_system_manifest.py --save
python3 scripts/gen_package_hierarchy.py --save
python3 scripts/gen_constraint_evaluator.py --save
python3 scripts/gen_decision_table_evaluator.py --save
```
