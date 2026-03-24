---
name: syntax-check
description: Look up SysML v2 syntax and KerML reserved words before writing model code
allowed-tools: Bash, Read
---

# SysML Syntax Check

Before writing or modifying any `.sysml` file, check the project's syntax reference and reserved words.

## Steps

1. Read the syntax reference:
   ```
   cat documentation/reference/gsl-sysml-v2-syntax-reference.md
   ```

2. If the work involves naming new elements, also check reserved words:
   ```
   cat documentation/reference/KerML-Reserved-Words.md
   ```

3. If `$ARGUMENTS` is provided, search for that specific construct in the syntax reference:
   ```
   grep -i "$ARGUMENTS" documentation/reference/gsl-sysml-v2-syntax-reference.md
   ```

## Key Syside Differences from the Spec

These are common traps — the syntax reference has the full list:

- Initial pseudostate syntax differs
- Decide/merge node syntax differs
- Succession syntax differs
- `subject` is NOT a KerML reserved word but IS a SysML v2 contextual keyword
- Metadata annotation syntax: `@MetadataName { key = value; }`
