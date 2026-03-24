---
name: model-edit
description: Edit SysML model files with safety checks and conventions
allowed-tools: Bash, Read, Write, Edit
---

# Edit SysML Model Files

Guided workflow for making changes to the SysML v2 model.

## Before editing

1. **Read the syntax reference** — always:
   ```bash
   cat documentation/reference/gsl-sysml-v2-syntax-reference.md
   ```

2. **Check reserved words** if adding new names:
   ```bash
   cat documentation/reference/KerML-Reserved-Words.md
   ```

3. **Read the target file** to understand current structure before making changes.

## Conventions to follow

- Every `part def` must have a doc block with meta model classification:
  ```
  doc /* Business Meta Model — [General|Tailored] — [ConcernName] */
  ```
- Use `@CatalogueTag`, `@UserFacing`, `@PurposiveDescription`, `@Comprehension`, and `@WeightedRelationship` annotations where applicable.
- General BMM vocabulary is used by all domains. Tailored vocabulary is sector-specific.
- `part def` = abstract definition (meta model level). `part` = concrete instance (domain level). Never conflate.

## After editing

1. Remind Ella to verify the file parses in Syside Modeler — Claude cannot do this.
2. If new concepts were introduced, note them for the master register update.
3. If the change affects the introspection generator's output, run `/generate` to regenerate.

## If `$ARGUMENTS` is provided

Read and display the specified model file:
```bash
cat model/$ARGUMENTS.sysml
```
